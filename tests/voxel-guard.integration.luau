-- Bundled by scripts/integration.py. API-shaped data, NOT an engine test.
do
    local terrain=require(game.ServerStorage.MedievalWorldgen.TerrainGenerator)
    local function voxels(size,occupied,material)
        local materials,occupancy={Size=size},{Size=size}
        for x=1,size.X do
            materials[x],occupancy[x]={},{}
            for y=1,size.Y do
                materials[x][y],occupancy[x][y]={},{}
                for z=1,size.Z do
                    local fill=if occupied then occupied(x,y,z) else 0
                    materials[x][y][z]=if fill==0 then Enum.Material.Air else material or Enum.Material.Rock
                    occupancy[x][y][z]=fill
                end
            end
        end
        return materials,occupancy
    end
    local size=Vector3.new(2,3,4) -- Unequal axes catch swapped dimensions/off-by-one.
    local c={MinY=0,MaxY=12}
    local chunks={{X=0,Z=0,Width=8,Depth=16}}
    local reader={}
    function reader:ReadVoxels(region,resolution)
        assert(resolution==4 and region.Size.X==8 and region.Size.Y==12 and region.Size.Z==16)
        return voxels(size)
    end
    local checkpoints=0
    terrain.assertEmpty(reader,c,chunks,function(i,total)assert(i==1 and total==1);checkpoints+=1 end)
    assert(checkpoints==1)
    local m,o=voxels(size)
    assert(typeof(m.Size)=='Vector3' and typeof(o.Size)=='Vector3')
    assert(not pcall(function()for _ in o.Size do end end),'Host must reject iterating a Vector3')
    print('PASSOU MOCK: ReadVoxels com Size Vector3 nas duas tabelas valida região vazia não cúbica sem iterar metadados.')

    -- Every coordinate, including the last voxel on each axis, must protect
    -- both solids and partially occupied water. No material-only shortcut.
    for x=1,size.X do for y=1,size.Y do for z=1,size.Z do
        for _,case in {{Fill=1,Material=Enum.Material.Rock},{Fill=0.25,Material=Enum.Material.Water}} do
            function reader:ReadVoxels()
                return voxels(size,function(ix,iy,iz)return if ix==x and iy==y and iz==z then case.Fill else 0 end,case.Material)
            end
            local ok,err=pcall(terrain.assertEmpty,reader,c,chunks,function()error('Checkpoint indevido')end)
            assert(not ok and string.find(tostring(err),'Terrain existente',1,true),tostring(err))
        end
    end end end
    print('PASSOU MOCK: 48 casos de sólido/água fracionária em todos os voxels 2x3x4 bloqueiam a geração, incluindo bordas.')

    for _,bad in {{}, {Size=Vector3.new(0,3,4)}, {Size=size,{{0}}}} do
        function reader:ReadVoxels()return {},bad end
        assert(not pcall(terrain.assertEmpty,reader,c,chunks,function()error('Checkpoint indevido')end))
    end
    print('PASSOU MOCK: retorno sem Size, dimensão zero ou voxel ausente falha fechado, sem liberar escrita.')

    local world=require(game.ServerStorage.MedievalWorldgen.WorldGenerator)
    local config=require(game.ReplicatedStorage.MedievalRPG.Config.WorldConfig)
    local mathTerrain=require(game.ServerStorage.MedievalWorldgen.TerrainMath)
    local total=#mathTerrain.chunks(config)
    local before=env.VoxelWrites
    local firstRead=env.VoxelReads or 0
    env.ReadVoxelsFixture=function(_,_,call)
        return voxels(Vector3.new(1,1,1),function()return if call-firstRead==total then 0.25 else 0 end,Enum.Material.Water)
    end
    local ok,err=pcall(world.GenerateNewWorld)
    assert(not ok and string.find(tostring(err),'Terrain existente',1,true),tostring(err))
    assert(env.VoxelReads-firstRead==total and env.VoxelWrites==before)
    assert(not workspace:FindFirstChild('GeneratedWorld'),'Preflight failed before any Terrain write; lock should be removed')
    print('PASSOU MOCK: água apenas no último chunk do continente é recusada antes de qualquer WriteVoxels; Terrain preservado.')

    local dConfig=require(game.ReplicatedStorage.MedievalRPG.Config.DungeonConfig)
    local floors=0;for _,id in dConfig.Order do floors+=dConfig.Dungeons[id].Floors end
    for _,case in {{Read=floors,Error='Terrain existente na área da expedição'},{Read=floors+1,Error='Área da dungeon contém Terrain existente'}} do
        firstRead=env.VoxelReads
        env.ReadVoxelsFixture=function(_,_,call)
            return voxels(Vector3.new(1,1,1),function()return if call-firstRead==case.Read then 0.25 else 0 end,Enum.Material.Water)
        end
        ok,err=pcall(world.GenerateDungeon)
        assert(not ok and string.find(tostring(err),case.Error,1,true),tostring(err))
        assert(env.VoxelReads-firstRead==case.Read and env.VoxelWrites==before)
        assert(not workspace:FindFirstChild('GeneratedDungeon'),'Dungeon must not be created over occupied Terrain')
    end
    print('PASSOU MOCK: água no último andar e na área legada bloqueia a dungeon antes de criar qualquer cenário.')

    -- Adding floors must also leave an existing owned legacy dungeon intact.
    local legacy=Instance.new('Model');legacy.Name='GeneratedDungeon';legacy.Parent=workspace
    legacy:SetAttribute('ProjectId',config.ProjectId);legacy:SetAttribute('Status','Complete');legacy:SetAttribute('Origin',Vector3.new())
    local sentinel=Instance.new('Folder');sentinel.Name='LegacySentinel';sentinel.Parent=legacy
    env.ReadVoxelsFixture=function()return voxels(Vector3.new(1,1,1),function()return 1 end)end
    ok,err=pcall(world.AddExpeditions)
    assert(not ok and string.find(tostring(err),'Terrain existente na área da expedição',1,true),tostring(err))
    assert(legacy.Parent==workspace and legacy.LegacySentinel==sentinel and #legacy:GetChildren()==1)
    assert(env.VoxelWrites==before and not legacy:FindFirstChild('Expeditions'))
    legacy:Destroy();env.ReadVoxelsFixture=nil
    print('PASSOU MOCK: AddExpeditions preserva dungeon legada e recusa novos andares sobre Terrain ocupado.')
end
