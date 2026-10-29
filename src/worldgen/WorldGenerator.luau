local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local Config = require(game:GetService("ReplicatedStorage").MedievalRPG.Config.WorldConfig)
local TerrainMath = require(script.Parent.TerrainMath)
local TerrainGenerator = require(script.Parent.TerrainGenerator)
local Validation = require(script.Parent.ValidationGenerator)
local Plan = require(script.Parent.WorldPlan)
local Content = require(script.Parent.ContentGenerator)
local Catalog = require(game.ReplicatedStorage.MedievalRPG.Config.ContentConfig)
local WorldGenerator = {}

local folders = { "TerrainMarkers", "Roads", "Bridges", "Cities", "Forests", "DungeonEntrance", "Ruins",
    "Decorations", "Spawns", "InteractiveObjects", "TreasureChests", "NPCSpawns", "EnemySpawns", "CinematicMarkers", "NPCs" }

function WorldGenerator.PreviewGeneration(config)
    local c = config or Config
    TerrainMath.validate(c)
    local chunks = TerrainMath.chunks(c)
    local report = {
        ProjectId = c.ProjectId, Seed = c.Seed, WorldSize = c.WorldSize,
        Chunks = #chunks, Voxels = (c.WorldSize/4)^2 * ((c.MaxY-c.MinY)/4),
        CitiesReserved = #c.Cities, ForestsReserved = #c.Forests,
        ImplementedPhase = 11, TerrainWritten = false,
    }
    local plan = Plan.build(c, TerrainMath, Catalog)
    report.Buildings = 0
    for _, city in plan.Cities do report.Buildings += #city.Lots end
    report.Trees = #plan.Trees
    print(string.format("[Preview] %dx%d studs, %d chunks, %d voxels. Continente completo: terreno, rotas, cidades, florestas e marcadores de gameplay.",
        c.WorldSize, c.WorldSize, report.Chunks, report.Voxels))
    return report
end

local function marker(parent, name, position, radius, kind)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = Vector3.new(4, 4, 4)
    part.Position = position
    part.Anchored = true
    part.CanCollide, part.CanTouch, part.CanQuery = false, false, false
    part.Transparency = 1
    part:SetAttribute("RegionId", name)
    part:SetAttribute("Radius", radius)
    part:SetAttribute("Kind", kind)
    part.Parent = parent
    return part
end

function WorldGenerator.GenerateNewWorld(config)
    assert(not RunService:IsRunning(), "Execute pela Command Bar no modo de edição, fora do Play/Run.")
    assert(script:IsDescendantOf(ServerStorage), "Gerador deve estar em ServerStorage")
    local c = config or Config
    local report = WorldGenerator.PreviewGeneration(c)
    assert(not workspace:FindFirstChild("GeneratedWorld"),
        "GeneratedWorld já existe. Use regeneração seletiva ou outro Place; Terrain não será substituído.")

    -- O folder é também o lock: criado antes de qualquer yield.
    local root = Instance.new("Folder")
    root.Name = "GeneratedWorld"
    root:SetAttribute("ProjectId", c.ProjectId)
    root:SetAttribute("SchemaVersion", c.SchemaVersion)
    root:SetAttribute("Seed", c.Seed)
    root:SetAttribute("ConfigSignature",TerrainMath.signature(c))
    root:SetAttribute("Status", "Preflight")
    root:SetAttribute("ChunksWritten", 0)
    root:SetAttribute("CancelRequested", false)
    root.Parent = workspace
    local wrote = false
    local function checkpoint()
        assert(root.Parent == workspace, "Lock removido durante geração")
        assert(not root:GetAttribute("CancelRequested"), "Geração cancelada; consulte ChunksWritten antes de qualquer recuperação.")
        task.wait()
    end
    local ok, result = xpcall(function()
        print("[01/09] Conferindo a área; nenhum voxel escrito ainda...")
        local params = OverlapParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { root, workspace.Terrain }
        local parts = workspace:GetPartBoundsInBox(CFrame.new(0, (c.MinY+c.MaxY)/2, 0),
            Vector3.new(c.WorldSize, c.MaxY-c.MinY, c.WorldSize), params)
        assert(#parts == 0, "Há Parts na área do terreno (incluindo possível Baseplate). Use um Place vazio; objetos existentes foram preservados.")
        local chunks = TerrainMath.chunks(c)
        TerrainGenerator.assertEmpty(workspace.Terrain, c, chunks, function(i, total)
            if i % 32 == 0 or i == total then print(string.format("[Preflight] %d/%d", i, total)) end
            checkpoint()
        end)
        print("[02/09] Gerando terreno por chunks...")
        root:SetAttribute("Status", "WritingTerrain")
        for i, chunk in chunks do
            -- Marca antes da chamada: uma falha do engine pode deixar escrita parcial.
            wrote = true
            root:SetAttribute("LastAttemptedChunk", i)
            TerrainGenerator.writeChunk(workspace.Terrain, c, chunk)
            root:SetAttribute("ChunksWritten", i)
            if i % 16 == 0 or i == #chunks then print(string.format("[Terreno] %d/%d", i, #chunks)) end
            checkpoint()
        end
        print("[03/09] Criando reservas e spawn inicial...")
        for _, name in folders do
            local folder = Instance.new("Folder")
            folder.Name, folder.Parent = name, root
        end
        for _, city in c.Cities do
            marker(root.TerrainMarkers, city.Id, Vector3.new(city.X, city.Height+2, city.Z), city.Radius, "CityReservation")
        end
        for _, forest in c.Forests do
            marker(root.TerrainMarkers, forest.Id, Vector3.new(forest.X, TerrainMath.height(c, forest.X, forest.Z)+2, forest.Z), forest.Radius, "ForestReservation")
        end
        local d = c.DungeonEntrance
        marker(root.TerrainMarkers, "Malgorth", Vector3.new(d.X, TerrainMath.height(c,d.X,d.Z)+2,d.Z), 60, "DungeonReservation")
        local city = c.Cities[1]
        local spawn = Instance.new("SpawnLocation")
        spawn.Name, spawn.Anchored, spawn.Neutral = "ValoriaSpawn", true, true
        spawn.Size = Vector3.new(10, 1, 10)
        spawn.Position = Vector3.new(city.X, city.Height+1, city.Z)
        spawn.Material = Enum.Material.Cobblestone
        spawn.Color = Color3.fromRGB(170, 164, 140)
        spawn.Parent = root.Spawns
        assert(#root.TerrainMarkers:GetChildren() == #c.Cities+#c.Forests+1 and spawn.Parent, "Validação das reservas falhou")
        local plan=Plan.build(c,TerrainMath,Catalog)
        print('[04/09] Estradas e pontes...'); Content.roads(root,plan,checkpoint)
        print('[05/09] Cidades e NPCs...'); Content.cities(root,c,plan,checkpoint)
        print('[06/09] Florestas, inimigos e baús...'); Content.forests(root,c,plan,checkpoint)
        print('[07/09] Entrada da dungeon e decoração...'); Content.entrance(root,c,TerrainMath)
        require(script.Parent.DecorationGenerator).generate(root.Decorations,c,plan,TerrainMath)
        print('[08/09] Validação...')
        report.Checks = Validation.validate(workspace, c)
        for _, check in report.Checks do
            assert(check.Status ~= "FALHOU", "Validação falhou: " .. check.Name)
        end
        root:SetAttribute("Status", "Complete")
        report.TerrainWritten = true
        report.ChunksWritten = #chunks
        print("[09/09] Continente gerado. Salve o Place e valide no Play. Dungeon: gere em outro Place.")
        return report
    end, debug.traceback)
    if not ok then
        if wrote then
            root:SetAttribute("Status", "FailedPartialTerrain")
            root:SetAttribute("Error", tostring(result))
            warn("Geração interrompida. Terrain parcial preservado; não repita em cima dele. Reabra a cópia salva antes da geração.")
        else
            root:Destroy() -- Nenhuma escrita de Terrain ocorreu.
        end
        error(result, 0)
    end
    return result
end

function WorldGenerator.ValidateWorld(config)
    return Validation.validate(workspace, config or Config)
end
-- One editor command for files built by either Rojo project. It never deletes old maps.
function WorldGenerator.PrepareStudio(options)
    assert(RunService:IsStudio() and not RunService:IsRunning(),'Prepare no editor do Studio, antes de Play')
    options=options or {}
    local kind=ServerStorage:FindFirstChild('MedievalPlaceKind')
    assert(kind and (kind.Value=='World' or kind.Value=='Dungeon' or kind.Value=='Map'),'Use um dos Places gerados pelo projeto Rojo')
    if kind.Value=='Map' then
        local scene=require(script.Parent.MapSceneGenerator)
        if not workspace:FindFirstChild('GeneratedWorld') then scene.generate() end
        local report=scene.completeTerrain()
        workspace:SetAttribute('EldravynPrepared',true)
        print('[Eldravyn] Continente preparado. Salve a cópia antes de Play. Validação visual/desempenho pendentes.')
        return report
    end
    if kind.Value=='World' then
        local existing=workspace:FindFirstChild('GeneratedWorld')
        if not existing then WorldGenerator.GenerateNewWorld() else
            assert(existing:GetAttribute('ProjectId')==Config.ProjectId and existing:GetAttribute('Status')=='Complete','Mapa existente incompleto/desconhecido; foi preservado')
            assert(existing:GetAttribute('ConfigSignature')==TerrainMath.signature(Config),'O mapa salvo usa outra geografia. Abra o build em uma cópia nova; seu mapa foi preservado.')
            for _,check in WorldGenerator.ValidateWorld() do assert(check.Status~='FALHOU',check.Name) end
        end
    else
        local existing=workspace:FindFirstChild('GeneratedDungeon')
        if not existing then WorldGenerator.GenerateDungeon() else
            assert(existing:GetAttribute('ProjectId')==Config.ProjectId and existing:GetAttribute('Status')=='Complete','Dungeon existente incompleta/desconhecida; foi preservada')
            if not existing:FindFirstChild('Expeditions') then WorldGenerator.AddExpeditions() end
        end
    end
    workspace:SetAttribute('StudioSessionPreview',options.Persistent~=true)
    workspace:SetAttribute('EldravynPrepared',true)
    print('[Eldravyn] Cenário preparado. Salve como uma cópia .rbxl/.rbxlx e clique Play. Prévia Studio: '..tostring(options.Persistent~=true)..'. Não publica o jogo.')
    return {Kind=kind.Value,StudioSessionPreview=options.Persistent~=true,Status='Prepared',RequiresSave=true}
end

-- Substituições seletivas preservam o conteúdo anterior em ServerStorage.
function WorldGenerator.RegenerateCity(id) return require(script.Parent.RegenerationService).city(id) end
function WorldGenerator.RegenerateForest(id) return require(script.Parent.RegenerationService).forest(id) end
function WorldGenerator.RegenerateDecorations() return require(script.Parent.RegenerationService).decorations() end
function WorldGenerator.RegenerateNPCMarkers() return require(script.Parent.RegenerationService).markers() end
function WorldGenerator.RegenerateGeneratedWorld()
    error("Substituição global de Terrain bloqueada. Gere em um Place novo para preservar voxels e mapas editados.",0)
end
function WorldGenerator.GenerateDungeon(options)
    return require(script.Parent.DungeonInteriorGenerator).GenerateDungeon(options)
end
function WorldGenerator.GenerateMapScene(config)
    return require(script.Parent.MapSceneGenerator).generate(config)
end
function WorldGenerator.ValidateMapScene(config)
    return require(script.Parent.MapSceneGenerator).validate(config)
end
function WorldGenerator.AddExpeditions()
    assert(not RunService:IsRunning(),'Execute fora do Play')
    local map=workspace:FindFirstChild('GeneratedDungeon')
    assert(map and map:GetAttribute('ProjectId')==Config.ProjectId and map:GetAttribute('Status')=='Complete','Dungeon própria completa ausente')
    assert(not map:FindFirstChild('Expeditions'),'Expedições já existem; nenhuma substituição será feita')
    local origin=map:GetAttribute('Origin') or map:GetAttribute('SpawnPosition')-Vector3.new(0,6,-18)
    local generator=require(script.Parent.ExpeditionGenerator)
    generator.preflight(origin)
    return generator.build(map,origin)
end
return WorldGenerator
