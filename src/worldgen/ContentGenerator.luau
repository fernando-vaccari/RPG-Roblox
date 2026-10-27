local G=require(script.Parent.Geometry)
local Buildings=require(script.Parent.BuildingGenerator)
local Shared=game.ReplicatedStorage.MedievalRPG
local Catalog=require(Shared.Config.ContentConfig)
local Rig=require(Shared.RigFactory)
local C={}
local Landmarks=require(script.Parent.LandmarkGenerator)
local Scenery=require(script.Parent.ScenicGenerator)
local function sceneOnly(root)return root:GetAttribute('SceneOnly')==true end
local function color(t) return Color3.fromRGB(t[1],t[2],t[3]) end
function C.npc(parent,id,position,role,city)
    local dialogue=Catalog.Dialogue[role] or Catalog.Dialogue.Citizen
    local paint=if city=='Eldoria' then Color3.fromRGB(94,73,148) elseif city=='Durakh' then Color3.fromRGB(86,81,72) else Color3.fromRGB(91,119,130)
    local model,_,root=Rig.create(parent,dialogue.Name,position,paint,false,role)
    model.Name=id; model:SetAttribute('NpcId',id); model:SetAttribute('Role',role); model:SetAttribute('City',city)
    if role=='Citizen' and Catalog.ResidentStories[city] then
        local hash=0;for i=1,#id do hash+=string.byte(id,i) end
        local name=Catalog.ResidentNames[hash%#Catalog.ResidentNames+1]
        model:SetAttribute('DisplayTitle',name..' • morador de '..city)
        model:SetAttribute('LocalDialogue',Catalog.ResidentStories[city][hash%#Catalog.ResidentStories[city]+1])
        model:FindFirstChildOfClass('Humanoid').DisplayName=name
    end
    G.prompt(root,'Conversar',model:GetAttribute('DisplayTitle') or dialogue.Name)
    return model
end
function C.chest(parent,id,pos,rarity,locked)
    local m=G.model(parent,id); m:SetAttribute('ChestId',id); m:SetAttribute('Rarity',rarity); m:SetAttribute('BossLocked',locked==true)
    G.part(m,'Base',Vector3.new(5,3,3),CFrame.new(pos+Vector3.new(0,1.5,0)),G.Palette.Wood,Enum.Material.WoodPlanks)
    local lid=G.part(m,'Lid',Vector3.new(5.2,1,3.2),CFrame.new(pos+Vector3.new(0,3.5,0)),G.Palette.Gold,Enum.Material.Metal)
    G.prompt(lid,'Abrir',rarity..' • Baú'); return m
end
function C.enemyMarker(parent,id,pos,kind)
    return G.marker(parent,id,pos,{EnemyId=id,EnemyKind=kind})
end
function C.tree(parent,t)
    local cf=CFrame.new(t.X,t.H,t.Z);local scale=t.Scale or 1
    local variant=(t.Variant or 0)%5;local ancient=variant==4
    local dark=t.Forest=='Vespera';local old=t.Forest=='Nocthar'
    local m=G.model(parent,'Tree_'..variant);m:SetAttribute('TreeVariant',variant);m:SetAttribute('ForestId',t.Forest)
    local wood=if variant==1 and not dark then Color3.fromRGB(178,177,149) elseif dark then Color3.fromRGB(65,58,67) else Color3.fromRGB(91,72,48)
    local leaf=if dark then Color3.fromRGB(56,66,77) elseif old then Color3.fromRGB(81,109,76) else Color3.fromRGB(77,137,77)
    local height=if ancient then 29 else 18+variant*2
    local thickness=if ancient then 4.8 else 2.2
    G.part(m,'Trunk',Vector3.new(height,thickness,thickness)*scale,cf*CFrame.new(0,height*0.5*scale,0)*CFrame.Angles(0,variant*0.7,math.pi/2+(if dark then 0.12 else 0.025)),wood,Enum.Material.Wood,Enum.PartType.Cylinder)
    local count=if variant==2 then 5 else 4
    for i=1,count do
        local a=i*2.399+variant*0.7
        local spread=if ancient then 9 elseif variant==2 then 1 else 5
        local crownY=if variant==2 then 11+i*3.4 else height-3+(i%3)*3
        local x,z=math.sin(a)*spread,math.cos(a)*spread
        local size=if variant==2 then Vector3.new(17-i*2.2,6,17-i*2.2) else Vector3.new(12+i%2*4,10,11+i%3*2)
        local crown=G.detail(m,'Canopy',size*scale,cf*CFrame.new(x*scale,crownY*scale,z*scale),leaf,Enum.Material.Grass,Enum.PartType.Ball)
        crown.CastShadow=not dark
        if variant~=2 then
            local branch=G.beam(m,cf:PointToWorldSpace(Vector3.new(0,height*0.55*scale,0)),cf:PointToWorldSpace(Vector3.new(x*scale,(crownY-2)*scale,z*scale)),(if ancient then 1.4 else 0.8)*scale,wood,Enum.Material.Wood)
            branch.CanCollide=false;branch.CanQuery=false
        end
    end
    if ancient or old then
        for i=1,4 do
            local a=i*math.pi/2+variant*0.4
            G.beam(m,cf:PointToWorldSpace(Vector3.new(math.sin(a)*2*scale,4*scale,math.cos(a)*2*scale)),cf:PointToWorldSpace(Vector3.new(math.sin(a)*9*scale,0.6*scale,math.cos(a)*9*scale)),(if ancient then 2.3 else 1.2)*scale,wood,Enum.Material.Wood)
        end
    end
    if variant%2==0 then Scenery.shrub(m,cf*CFrame.new(5*scale,0,2*scale),0.8*scale,dark) end
    return m
end
function C.cities(root,c,plan,checkpoint)
    for _,city in plan.Cities do
        print('[Cidade] '..city.Name)
        local parent=G.model(root.Cities,city.Id)
        parent:SetAttribute('RegionName',city.Name)
        local cf=CFrame.new(city.X,city.H,city.Z)
        G.part(parent,'Plaza',Vector3.new(64,0.5,64),cf,Color3.fromRGB(149,147,128),Enum.Material.Cobblestone)
        require(script.Parent.CityLandmarkGenerator).build(parent,city,c)
        for index,lot in city.Lots do
            local visible=lot
            if sceneOnly(root) and lot.VisualKind then
                visible=table.clone(lot);visible.Kind=lot.VisualKind
            end
            local _,pos,role=Buildings.build(parent,visible,city.Id,index)
            if not sceneOnly(root) then
                local npc=C.npc(root.NPCs,lot.Id..'_NPC',pos,role,city.Id)
                npc:PivotTo(CFrame.lookAt(npc.PrimaryPart.Position,Vector3.new(city.X,npc.PrimaryPart.Position.Y,city.Z)))
            end
            checkpoint()
        end
        local radius
        for _,config in c.Cities do if config.Id==city.Id then radius=config.Radius-6 end end
        -- Muralha com vãos reservados às rotas. Nada fecha uma estrada.
        if city.Id=='Arkheim' or city.Id=='Valoria' or city.Id=='Durakh' then
            for i=1,64 do
                local a=i/64*math.pi*2
                local x,z=city.X+math.sin(a)*radius,city.Z+math.cos(a)*radius
                local free=true
                if require(script.Parent.TerrainMath).roadDistance(c,x,z)<32 then free=false end
                if free then
                    local h=if city.Id=='Arkheim' then 12 else 6
                    local frame=CFrame.new(x,city.H+h/2,z)*CFrame.Angles(0,a,0)
                    G.part(parent,'CityWall',Vector3.new(radius*math.pi/32+1,h,3),frame,G.Palette.Stone,Enum.Material.Cobblestone)
                    if i%2==0 then G.part(parent,'Merlon',Vector3.new(3,2,3),frame*CFrame.new(0,h/2+1,0),G.Palette.Stone,Enum.Material.Cobblestone) end
                end
            end
        end
        for _,offset in {Vector3.new(-24,0,-24),Vector3.new(24,0,24)} do G.torch(parent,cf*CFrame.new(offset+Vector3.new(0,2,0)),true) end
        local board=G.sign(parent,if sceneOnly(root) then 'AVISOS • GUILDA' else 'MISSÕES • GUILDA',cf*CFrame.new(-23,5,0),12)
        if not sceneOnly(root) then board:SetAttribute('QuestBoard',true);G.prompt(board,'Consultar','Quadro de missões') end
        if not sceneOnly(root) then
            local handoff=G.marker(root.InteractiveObjects,city.Id..'_Supplies',Vector3.new(city.X-24,city.H+3,city.Z+12),{Objective='Supplies'})
            if city.Id=='Durakh' then handoff.Transparency=0;G.prompt(handoff,'Entregar','Suprimentos') end
        end
        G.marker(root.CinematicMarkers,city.Id..'_Shot',Vector3.new(city.X,city.H+60,city.Z+120),{
            ShotName=city.Id..'_Plaza',RegionName=city.Name,CameraPosition=Vector3.new(city.X,city.H+60,city.Z+120),LookAtPosition=Vector3.new(city.X,city.H+10,city.Z),Duration=8,Category='City'})
        Landmarks.city(parent,city,c,C)
        if not sceneOnly(root) then Landmarks.defenses(root,c,C,parent,city) end
        if city.Id=='Valoria' then Landmarks.camp(root,c,C,parent) end
        checkpoint()
    end
end
function C.roads(root,plan,checkpoint,config)
    local c=config or require(Shared.Config.WorldConfig)
    local terrain=require(script.Parent.TerrainMath)
    for _,route in plan.Roads do
        local parent=G.model(root.Roads,route.Id)
        parent:SetAttribute('RouteId',route.Id)
        for i,s in route.Segments do
            local a,b=Vector3.new(s.A.X,s.A.H+0.5,s.A.Z),Vector3.new(s.B.X,s.B.H+0.5,s.B.Z)
            local cf=CFrame.lookAt((a+b)/2,b)
            G.part(parent,if s.Bridge then 'BridgeDeck' else 'Road',Vector3.new(route.Width or 18,0.7,(b-a).Magnitude+0.2),cf,
                if s.Bridge then G.Palette.Wood else Color3.fromRGB(149,128,93),if s.Bridge then Enum.Material.WoodPlanks else Enum.Material.Ground)
            if s.Bridge then
                local bridge=G.model(root.Bridges,route.Id..'_'..i)
                for _,side in {-1,1} do
                    G.part(bridge,'Rail',Vector3.new(0.5,0.8,(b-a).Magnitude+0.2),cf*CFrame.new(side*((route.Width or 18)/2),3,0),G.Palette.Wood,Enum.Material.Wood)
                    local p=cf:PointToWorldSpace(Vector3.new(side*((route.Width or 18)/2-1),0,0))
                    local bed=terrain.height(c,p.X,p.Z)
                    local height=math.max(1,p.Y-bed+1)
                    G.part(bridge,'Support',Vector3.new(1.4,height,1.4),CFrame.new(p.X,bed+height/2-0.5,p.Z),G.Palette.Stone,Enum.Material.Cobblestone)
                end
            end
        end
        G.sign(parent,route.Id,CFrame.new(route.A.X+15,route.A.H+5,route.A.Z),14)
        checkpoint()
    end
end
function C.forests(root,c,plan,checkpoint)
    local chestOverrides={};local folders={}
    for _,f in c.Forests do
        folders[f.Id]=G.model(root.Forests,f.Id);folders[f.Id]:SetAttribute('RegionName',f.Name)
        folders[f.Id]:SetAttribute('ForestTheme',if f.Id=='Sylvarin' then 'Emerald' elseif f.Id=='Nocthar' then 'Ancient' else 'Shadow')
    end
    for i,t in plan.Trees do C.tree(folders[t.Forest],t);if i%20==0 then checkpoint() end end
    local terrain=require(script.Parent.TerrainMath)
    for _,land in plan.Landmarks do
        local parent=folders[land.Id];local cf=CFrame.new(land.X,land.H,land.Z)
        chestOverrides[land.Id..'Chest5']=Scenery.forest(parent,land,c,terrain,C)
        if not sceneOnly(root) then
            local altar=G.part(parent,'Altar',Vector3.new(10,3,7),cf*CFrame.new(0,1.5,0),G.Palette.Stone,Enum.Material.Slate)
            altar:SetAttribute('Objective','Ruins');G.prompt(altar,'Investigar','Ruínas antigas')
            local herb=G.crystal(parent,cf*CFrame.new(20,2,12),Color3.fromRGB(107,237,152),0.5)
            herb:SetAttribute('Objective','Herb');G.prompt(herb,'Coletar','Erva rara')
            C.npc(root.NPCs,land.Id..'_Explorer',Vector3.new(land.X-20,land.H,land.Z),'Quest',land.Id)
            C.enemyMarker(root.EnemySpawns,land.Id..'_Boss',Vector3.new(land.X+45,land.H,land.Z),if land.Id=='Sylvarin' then 'SylvarinBoss' elseif land.Id=='Vespera' then 'VesperaBoss' else 'NoctharBoss')
        end
        G.marker(root.CinematicMarkers,land.Id..'_Shot',Vector3.new(land.X,land.H+25,land.Z+65),{
            ShotName=land.Id,RegionName=land.Id,CameraPosition=Vector3.new(land.X,land.H+25,land.Z+65),LookAtPosition=Vector3.new(land.X,land.H+8,land.Z),Duration=7,Category='Forest'})
        checkpoint()
    end
    if not sceneOnly(root) then
        for _,spawn in plan.EnemySpawns do C.enemyMarker(root.EnemySpawns,spawn.Id,Vector3.new(spawn.X,spawn.H,spawn.Z),spawn.Kind) end
        for _,chest in plan.Chests do C.chest(root.TreasureChests,chest.Id,chestOverrides[chest.Id] or Vector3.new(chest.X,chest.H,chest.Z),chest.Rarity) end
    end
end
function C.entrance(root,c,terrain)
    local function gate(id,def,title,dungeonId,shadow)
        local pos=Vector3.new(def.X,terrain.height(c,def.X,def.Z),def.Z);local cf=CFrame.new(pos)
        local m=G.model(root.DungeonEntrance,id);m:SetAttribute('RegionId',id)
        m:SetAttribute('IntegrationKind','DungeonExterior');m:SetAttribute('IntegrationDungeonId',dungeonId)
        local stone=if shadow then Color3.fromRGB(72,69,82) else Color3.fromRGB(126,135,150)
        local glow=if shadow then Color3.fromRGB(169,79,111) else Color3.fromRGB(126,173,207)
        G.part(m,'Forecourt',Vector3.new(76,2,58),cf,stone,Enum.Material.Cobblestone)
        for _,side in {-1,1} do
            local x=side*25
            G.part(m,'TowerPlinth',Vector3.new(19,4,22),cf*CFrame.new(x,2,-2),stone,Enum.Material.Cobblestone)
            G.part(m,'GateTower',Vector3.new(13,43,16),cf*CFrame.new(x,23,-2),stone,Enum.Material.Slate)
            for _,dx in {-6,6} do G.part(m,'Buttress',Vector3.new(3,31,20),cf*CFrame.new(x+dx,16,-1)*CFrame.Angles(0,0,side*0.035),stone,Enum.Material.Rock) end
            for i=1,3 do
                G.part(m,'TowerCornice',Vector3.new(16,1.2,19),cf*CFrame.new(x,12+i*10,-2),Color3.fromRGB(105,111,125),Enum.Material.Cobblestone)
                G.detail(m,'RuneWindow',Vector3.new(3,5,0.3),cf*CFrame.new(x,11+i*8,6.15),glow,Enum.Material.Neon)
            end
            G.part(m,'SpireBase',Vector3.new(17,3,20),cf*CFrame.new(x,46,-2),stone,Enum.Material.Slate)
            G.crystal(m,cf*CFrame.new(x,52,-2),glow,2)
            G.part(m,'ArchHaunch',Vector3.new(16,5,12),cf*CFrame.new(side*13,36,-2)*CFrame.Angles(0,0,side*0.5),stone,Enum.Material.Cobblestone)
            G.part(m,'OuterColumn',Vector3.new(6,20,6),cf*CFrame.new(side*39,10,13),stone,Enum.Material.Cobblestone)
            G.torch(m,cf*CFrame.new(side*36,6,19),true)
            for i=1,4 do G.part(m,'ApproachPost',Vector3.new(2,3,2),cf*CFrame.new(side*34,2,20+i*5),stone,Enum.Material.Cobblestone) end
        end
        G.part(m,'Keystone',Vector3.new(9,7,13),cf*CFrame.new(0,40,-2),stone,Enum.Material.Slate)
        G.part(m,'UpperLintel',Vector3.new(58,4,17),cf*CFrame.new(0,45,-2),stone,Enum.Material.Slate)
        for i=1,4 do G.part(m,'StairTread',Vector3.new(28,i*0.25,4),cf*CFrame.new(0,i*0.125,22-i*4),stone,Enum.Material.Cobblestone) end
        -- The external threshold is open and inert; no false portal or prompt.
        G.sign(m,title,cf*CFrame.new(0,28,7),35)
        G.marker(m,id..'_Threshold',pos+Vector3.new(0,3,0),{IntegrationId=id,IntegrationKind='DungeonThreshold',DungeonId=dungeonId,OpeningWidth=34})
        if not sceneOnly(root) then
            C.npc(root.NPCs,if shadow then 'DungeonGuardian' else 'SanctumGuardian',pos+Vector3.new(0,1,15),'Dungeon',if shadow then 'Malgorth' else 'Vespera'):SetAttribute('DungeonId',dungeonId)
        end
        return pos
    end
    local pos=gate('MalgorthGate',c.DungeonEntrance,'ABISMO DE MALGORTH','MalgorthDepths',true)
    if c.SecondDungeonEntrance then gate('FallenSanctumGate',c.SecondDungeonEntrance,'SANTUÁRIO DO REINO CAÍDO','FallenSanctum',false) end
    G.marker(root.CinematicMarkers,'DungeonShot',pos+Vector3.new(0,48,100),{ShotName='DungeonGate',RegionName='Malgorth',CameraPosition=pos+Vector3.new(0,48,100),LookAtPosition=pos+Vector3.new(0,20,0),Duration=8,Category='Dungeon'})
end
function C.integrationMarkers(root,c,plan,terrain)
    assert(not root:FindFirstChild('IntegrationPoints'),'IntegrationPoints já existe; nada foi substituído')
    local folder=Instance.new('Folder');folder.Name='IntegrationPoints';folder.Parent=root
    for _,city in plan.Cities do
        G.marker(folder,city.Id..'_Services',Vector3.new(city.X,city.H+3,city.Z),{IntegrationId=city.Id,IntegrationKind='CityHub',RegionId=city.Id,Radius=city.Radius})
        for index,lot in city.Lots do
            local role=Catalog.Roles[lot.Kind] or 'Citizen'
            local p=CFrame.new(lot.X,lot.H,lot.Z)*CFrame.Angles(0,lot.Yaw,0)
            G.marker(folder,lot.Id..'_ServiceSlot',p:PointToWorldSpace(Vector3.new(0,3,-27)),{
                IntegrationId=lot.Id,IntegrationKind='ServiceSlot',RegionId=city.Id,DesignRole=role,BuildingKind=lot.Kind,SlotIndex=index})
        end
    end
    for _,forest in c.Forests do
        G.marker(folder,forest.Id..'_Clearing',Vector3.new(forest.X,terrain.height(c,forest.X,forest.Z)+3,forest.Z),{
            IntegrationId=forest.Id..'_Clearing',IntegrationKind='EncounterClearing',RegionId=forest.Id,Radius=28})
    end
    for _,entrance in {{Id='MalgorthDepths',Point=c.DungeonEntrance},{Id='FallenSanctum',Point=c.SecondDungeonEntrance}} do
        if entrance.Point then
            local p=entrance.Point
            G.marker(folder,entrance.Id..'_Approach',Vector3.new(p.X,terrain.height(c,p.X,p.Z)+3,p.Z+30),{
                IntegrationId=entrance.Id,IntegrationKind='DungeonApproach',RegionId=entrance.Id,Radius=28})
        end
    end
    return folder
end
return C
