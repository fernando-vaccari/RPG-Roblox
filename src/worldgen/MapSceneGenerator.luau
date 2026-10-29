-- Map-only authoring. Existing RPG runtime/services are not started by this path.
local Run=game:GetService('RunService')
local Config=require(game.ReplicatedStorage.MedievalRPG.Config.WorldConfig)
local TerrainMath=require(script.Parent.TerrainMath)
local Terrain=require(script.Parent.TerrainGenerator)
local Plan=require(script.Parent.WorldPlan)
local Content=require(script.Parent.ContentGenerator)
local Catalog=require(game.ReplicatedStorage.MedievalRPG.Config.ContentConfig)
local Scene={}
local folders={'TerrainMarkers','Roads','Bridges','Cities','Forests','DungeonEntrance','Ruins','Decorations','Spawns','InteractiveObjects','TreasureChests','NPCSpawns','EnemySpawns','CinematicMarkers','NPCs'}
local function editor()
    assert(not Run:IsRunning(),'Execute no editor, fora de Play/Run')
end
local function unownedParts(c,root)
    local p=OverlapParams.new();p.FilterType=Enum.RaycastFilterType.Exclude
    p.FilterDescendantsInstances=if root then {workspace.Terrain,root} else {workspace.Terrain}
    assert(#workspace:GetPartBoundsInBox(CFrame.new(0,(c.MinY+c.MaxY)/2,0),Vector3.new(c.WorldSize,c.MaxY-c.MinY,c.WorldSize),p)==0,
        'A área contém objetos externos ao cenário. Nada foi sobrescrito; use uma cópia nova.')
end
function Scene.generate(config)
    editor();local c=config or Config;TerrainMath.validate(c)
    assert(not workspace:FindFirstChild('GeneratedWorld'),'Um continente já existe; foi preservado')
    unownedParts(c)
    local root=Instance.new('Folder');root.Name='GeneratedWorld'
    root:SetAttribute('ProjectId',c.ProjectId);root:SetAttribute('SchemaVersion',c.SchemaVersion)
    root:SetAttribute('ConfigSignature',TerrainMath.signature(c));root:SetAttribute('Seed',c.Seed)
    root:SetAttribute('SceneOnly',true);root:SetAttribute('TerrainPending',true)
    root:SetAttribute('Status','AuthoringGeometry');root:SetAttribute('ChunksWritten',0);root.Parent=workspace
    local ok,err=xpcall(function()
        Terrain.assertEmpty(workspace.Terrain,c,TerrainMath.chunks(c),function()task.wait()end)
        for _,name in folders do local f=Instance.new('Folder');f.Name=name;f.Parent=root end
        local plan=Plan.build(c,TerrainMath,Catalog)
        Content.roads(root,plan,function()task.wait()end)
        Content.cities(root,c,plan,function()task.wait()end)
        Content.forests(root,c,plan,function()task.wait()end)
        Content.entrance(root,c,TerrainMath)
        require(script.Parent.DecorationGenerator).generate(root.Decorations,c,plan,TerrainMath)
        Content.integrationMarkers(root,c,plan,TerrainMath)
        local city=c.Cities[1]
        local spawn=Instance.new('SpawnLocation');spawn.Name='ValoriaSpawn';spawn.Size=Vector3.new(10,1,10)
        spawn.Position=Vector3.new(city.X,city.Height+1,city.Z);spawn.Anchored=true;spawn.Neutral=true
        spawn.Color=Color3.fromRGB(150,148,131);spawn.Material=Enum.Material.Cobblestone;spawn.Parent=root.Spawns
        root:SetAttribute('PreparedGeometry',true);root:SetAttribute('Status','AwaitingTerrain')
        workspace:SetAttribute('EldravynMapOnly',true)
        require(script.Parent.MapEnvironment).apply('Day')
    end,debug.traceback)
    if not ok then root:SetAttribute('Status','GeometryFailed');root:SetAttribute('Error',tostring(err));error(err,0)end
    Scene.validate(c)
    print('[Eldravyn mapa] Geometria construída. Terrain nativo ainda pendente; execute PrepareStudio() no editor e salve.')
    return root
end
function Scene.completeTerrain(config)
    editor();local c=config or Config
    local root=workspace:FindFirstChild('GeneratedWorld')
    assert(root and root:GetAttribute('ProjectId')==c.ProjectId and root:GetAttribute('SceneOnly')==true,'Cenário próprio ausente')
    assert(root:GetAttribute('ConfigSignature')==TerrainMath.signature(c),'Geografia incompatível; abra o novo Place em outra cópia')
    if root:GetAttribute('Status')=='Complete' and not root:GetAttribute('TerrainPending') then return Scene.validate(c) end
    assert(root:GetAttribute('Status')=='AwaitingTerrain' and root:GetAttribute('ChunksWritten')==0,
        'Cenário incompleto ou Terrain parcial. Reabra a cópia anterior à geração; nada foi apagado.')
    root:SetAttribute('Status','TerrainPreflight')
    local attempted=false
    local function checkpoint()
        assert(root.Parent==workspace and not root:GetAttribute('CancelRequested'),'Geração cancelada; preserve a cópia para diagnóstico')
        task.wait()
    end
    local ok,err=xpcall(function()
        unownedParts(c,root)
        local chunks=TerrainMath.chunks(c)
        Terrain.assertEmpty(workspace.Terrain,c,chunks,function(i,n)
            if i%32==0 or i==n then print('[Preflight mapa] '..i..'/'..n)end
            checkpoint()
        end)
        root:SetAttribute('Status','WritingTerrain')
        for i,chunk in chunks do
            attempted=true;root:SetAttribute('LastAttemptedChunk',i)
            Terrain.writeChunk(workspace.Terrain,c,chunk);root:SetAttribute('ChunksWritten',i)
            if i%16==0 or i==#chunks then print('[Terrain mapa] '..i..'/'..#chunks)end
            checkpoint()
        end
        root:SetAttribute('TerrainPending',false);root:SetAttribute('Status','Complete')
    end,debug.traceback)
    if not ok then
        root:SetAttribute('Status',if attempted then 'FailedPartialTerrain' else 'AwaitingTerrain')
        root:SetAttribute('Error',tostring(err));error(err,0)
    end
    require(script.Parent.MapEnvironment).apply('Day')
    local camera=workspace.CurrentCamera
    if camera then
        local city=c.Cities[1]
        local focus=Vector3.new(city.X,city.Height+24,city.Z)
        camera.CFrame=CFrame.lookAt(focus+Vector3.new(100,100,190),focus)
        camera.Focus=CFrame.new(focus)
    end
    return Scene.validate(c)
end
function Scene.validate(config)
    local c=config or Config;local root=assert(workspace:FindFirstChild('GeneratedWorld'),'Mapa ausente')
    assert(root:GetAttribute('SceneOnly')==true and root:GetAttribute('ProjectId')==c.ProjectId)
    assert(#root.Cities:GetChildren()==5 and #root.Forests:GetChildren()==3,'Regiões incompletas')
    assert(#root.Roads:GetChildren()==#c.Roads and #root.Bridges:GetChildren()>0,'Conexões incompletas')
    assert(root.Spawns:FindFirstChild('ValoriaSpawn'),'Spawn ausente')
    assert(root:FindFirstChild('IntegrationPoints') and #root.IntegrationPoints:GetChildren()>10,'Integrações ausentes')
    local parts=0
    for _,node in root:GetDescendants()do
        assert(not node:IsA('Humanoid') and not node:IsA('ProximityPrompt'),'Gameplay inesperado no cenário')
        assert(not node:GetAttribute('EnemyId') and not node:GetAttribute('NpcId') and not node:GetAttribute('ChestId'),'Marcador de gameplay ativo')
        if node:IsA('BasePart')then assert(node.Anchored,'Peça de cenário solta');parts+=1 end
    end
    return {Parts=parts,SceneOnly=true,TerrainPending=root:GetAttribute('TerrainPending')==true,StudioVisualsValidated=false}
end
return Scene
