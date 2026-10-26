local G=require(script.Parent.Geometry)
local Content=require(script.Parent.ContentGenerator)
local D={}
function D.GenerateDungeon(options)
    options=options or {}
    assert(not game:GetService('RunService'):IsRunning() or options.StudioTest==true and game:GetService('RunService'):IsStudio(), 'Dungeon do editor só pode ser gerada fora do Play')
    assert(not workspace:FindFirstChild('GeneratedDungeon'),'GeneratedDungeon já existe; nada foi substituído')
    assert(options.StudioTest==true or not workspace:FindFirstChild('GeneratedWorld'),'Use outro Place para a dungeon')
    local origin=options.Origin or Vector3.new(0,20,0)
    local Expeditions=require(script.Parent.ExpeditionGenerator)
    Expeditions.preflight(origin)
    local params=OverlapParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={workspace.Terrain}
    assert(#workspace:GetPartBoundsInBox(CFrame.new(origin+Vector3.new(30,35,330)),Vector3.new(220,100,800),params)==0,'Área da dungeon contém objetos existentes')
    local volume=Region3.new(origin+Vector3.new(-80,-15,-70),origin+Vector3.new(140,85,730)):ExpandToGrid(4)
    local _,occupied=workspace.Terrain:ReadVoxels(volume,4)
    for _,plane in occupied do for _,row in plane do for _,fill in row do
        assert(fill==0,'Área da dungeon contém Terrain existente; use um Place novo')
    end end end
    local m=G.model(workspace,'GeneratedDungeon'); m:SetAttribute('ProjectId','ProjectMedievalRPG'); m:SetAttribute('BossDefeated',false)
    m:SetAttribute('StudioTest',options.StudioTest==true); m:SetAttribute('Status','Generating')
    m:SetAttribute('Origin',origin)
    for _,name in {'Rooms','EnemySpawns','TreasureChests','Traps','CinematicMarkers','NPCs'} do local f=Instance.new('Folder');f.Name=name;f.Parent=m end
    local ok,err=xpcall(function()
        local titles={'Salão do Juramento','Galeria das Sombras','Ponte do Abismo','Salão das Lâminas','Capela Corrompida','Antecâmara do Cavaleiro','Trono de Malgorth'}
        for i,title in titles do
            local room=G.model(m.Rooms,'Room'..i); room:SetAttribute('RoomName',title)
            local cf=CFrame.new(origin+Vector3.new(0,0,(i-1)*110)); local width=if i==7 then 84 else 52
            if i==3 then
                for _,side in {-1,1}do G.part(room,'AbysmPlatform',Vector3.new(width,3,20),cf*CFrame.new(0,0,side*22),G.Palette.Stone,Enum.Material.Slate)end
                G.part(room,'AbysmBridge',Vector3.new(16,3,24),cf,G.Palette.Stone,Enum.Material.Cobblestone)
                for _,side in {-1,1}do G.part(room,'BridgeRail',Vector3.new(1,3,24),cf*CFrame.new(side*8.5,3,0),G.Palette.Stone,Enum.Material.Slate)end
            else G.part(room,'Floor',Vector3.new(width,3,62),cf,G.Palette.Stone,Enum.Material.Slate)end
            for _,x in {-width/2,width/2} do
                for _,z in {-21,21} do G.part(room,'SideWall',Vector3.new(3,24,20),cf*CFrame.new(x,12,z),G.Palette.Stone,Enum.Material.Slate) end
                if i~=3 or x<0 then G.part(room,'ClosedSide',Vector3.new(3,24,22),cf*CFrame.new(x,12,0),G.Palette.Stone,Enum.Material.Slate)end
                G.part(room,'SideLintel',Vector3.new(3,10,22),cf*CFrame.new(x,20,0),G.Palette.Stone,Enum.Material.Slate)
            end
            for _,z in {-31,31} do
                for _,side in {-1,1} do G.part(room,'DoorWall',Vector3.new((width-16)/2,24,3),cf*CFrame.new(side*(width+16)/4,12,z),G.Palette.Stone,Enum.Material.Cobblestone) end
                G.part(room,'ArchLintel',Vector3.new(16,8,3),cf*CFrame.new(0,20,z),G.Palette.Stone,Enum.Material.Cobblestone)
            end
            G.part(room,'Ceiling',Vector3.new(width,2,62),cf*CFrame.new(0,28,0),Color3.fromRGB(53,45,61),Enum.Material.Slate)
            for _,x in {-width/2+5,width/2-5} do G.torch(room,cf*CFrame.new(x,6,0),true) end
            for _,x in {-width/2+5,width/2-5}do
                G.part(room,'PillarFoot',Vector3.new(5,2,5),cf*CFrame.new(x,2,22),G.Palette.Stone,Enum.Material.Cobblestone)
                G.part(room,'Pillar',Vector3.new(2,20,2),cf*CFrame.new(x,12,22),G.Palette.Stone,Enum.Material.Slate)
            end
            if i==5 then G.part(room,'CorruptedAltar',Vector3.new(12,4,8),cf*CFrame.new(15,3,12),G.Palette.Stone,Enum.Material.CrackedLava)end
            if i==7 then
                G.part(room,'ThroneDais',Vector3.new(20,2,10),cf*CFrame.new(0,2,20),G.Palette.Stone,Enum.Material.Cobblestone)
                G.part(room,'ThroneBack',Vector3.new(8,12,2),cf*CFrame.new(0,9,24),Color3.fromRGB(97,39,53),Enum.Material.Slate)
                for _,side in {-1,1}do G.crystal(room,cf*CFrame.new(side*30,8,20),Color3.fromRGB(185,62,107),1.5)end
            end
            G.sign(room,title,cf*CFrame.new(0,23,-29),30)
            if i<7 then
                local bridge=G.model(m.Rooms,'Corridor'..i)
                G.part(bridge,'Deck',Vector3.new(16,2,50),cf*CFrame.new(0,0,55),G.Palette.Stone,Enum.Material.Cobblestone)
                for _,x in {-9,9} do G.part(bridge,'Rail',Vector3.new(2,3,50),cf*CFrame.new(x,2,55),G.Palette.Stone,Enum.Material.Slate) end
            end
            if i==4 then
                local trap=G.detail(m.Traps,'DemonRune',Vector3.new(12,0.2,12),cf*CFrame.new(0,1.7,0),Color3.fromRGB(208,47,78),Enum.Material.Neon)
                trap:SetAttribute('TrapDamage',12)
            end
            if i>1 then
                local kind=if i==7 then 'Malgorth' elseif i==6 then 'Knight' elseif i==5 then 'Shadow' elseif i%2==0 then 'Demon' else 'Skeleton'
                Content.enemyMarker(m.EnemySpawns,'DungeonEnemy'..i,origin+Vector3.new(0,2,(i-1)*110),kind)
            end
            task.wait()
        end
        -- Sala secreta e ligação lateral explorável.
        local secret=G.model(m.Rooms,'SecretRoom')
        G.part(secret,'SecretFloor',Vector3.new(80,3,24),CFrame.new(origin+Vector3.new(54,0,220)),G.Palette.Stone,Enum.Material.Slate)
        for _,z in {-13,13}do G.part(secret,'SecretRail',Vector3.new(70,5,2),CFrame.new(origin+Vector3.new(59,3,z+220)),G.Palette.Stone,Enum.Material.Slate)end
        G.part(secret,'SecretBack',Vector3.new(2,16,24),CFrame.new(origin+Vector3.new(95,8,220)),G.Palette.Stone,Enum.Material.Slate)
        Content.chest(m.TreasureChests,'MalgorthSecret',origin+Vector3.new(86,2,220),'Epic')
        Content.chest(m.TreasureChests,'MalgorthReward',origin+Vector3.new(18,2,680),'Legendary',true)
        local portal=G.part(m,'ReturnPortal',Vector3.new(10,16,2),CFrame.new(origin+Vector3.new(0,9,690)),Color3.fromRGB(98,127,241),Enum.Material.Neon)
        portal.CanCollide=false; portal:SetAttribute('ReturnPortal',true); G.prompt(portal,'Retornar','Portal de retorno')
        local spawn=Instance.new('SpawnLocation');spawn.Name='DungeonSpawn';spawn.Anchored=true;spawn.Neutral=true
        spawn.Size=Vector3.new(10,1,10);spawn.Position=origin+Vector3.new(0,2,-18);spawn.Parent=m
        m:SetAttribute('SpawnPosition',spawn.Position+Vector3.new(0,4,0))
        Content.npc(m.NPCs,'DepthsReception',origin+Vector3.new(-16,2,-18),'Dungeon','Malgorth'):SetAttribute('DungeonId','MalgorthDepths')
        Content.npc(m.NPCs,'SanctumReception',origin+Vector3.new(16,2,-18),'Dungeon','Vespera'):SetAttribute('DungeonId','FallenSanctum')
        local retreat=G.detail(m,'LobbyReturn',Vector3.new(6,9,2),CFrame.new(origin+Vector3.new(18,6,-25)),Color3.fromRGB(101,158,180),Enum.Material.Neon)
        retreat:SetAttribute('ReturnPortal',true);G.prompt(retreat,'Retornar','Continente')
        G.marker(m.CinematicMarkers,'BossShot',origin+Vector3.new(0,20,610),{ShotName='MalgorthArena',RegionName='Abismo de Malgorth',CameraPosition=origin+Vector3.new(0,20,610),LookAtPosition=origin+Vector3.new(0,8,660),Duration=8,Category='Boss'})
        Expeditions.build(m,origin)
        m:SetAttribute('Status','Complete')
    end,debug.traceback)
    if not ok then m:SetAttribute('Status','Failed');error(err,0) end
    print('[Dungeon] Mapa separado gerado. Teleporte real NÃO TESTADO. Salve o Place.')
    return m
end
return D
