local G=require(script.Parent.Geometry)
local Buildings=require(script.Parent.BuildingGenerator)
local Shared=game.ReplicatedStorage.MedievalRPG
local Catalog=require(Shared.Config.ContentConfig)
local Rig=require(Shared.RigFactory)
local C={}
local function color(t) return Color3.fromRGB(t[1],t[2],t[3]) end
function C.npc(parent,id,position,role,city)
    local dialogue=Catalog.Dialogue[role] or Catalog.Dialogue.Citizen
    local paint=if city=='Eldoria' then Color3.fromRGB(94,73,148) elseif city=='Durakh' then Color3.fromRGB(86,81,72) else Color3.fromRGB(91,119,130)
    local model,_,root=Rig.create(parent,dialogue.Name,position,paint,false,role)
    model.Name=id; model:SetAttribute('NpcId',id); model:SetAttribute('Role',role); model:SetAttribute('City',city)
    G.prompt(root,'Conversar',dialogue.Name)
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
    local cf=CFrame.new(t.X,t.H,t.Z); local s=t.Scale
    local m=G.model(parent,'Tree_'..t.Variant)
    G.part(m,'Trunk',Vector3.new(2*s,18*s,2*s),cf*CFrame.new(0,9*s,0),G.Palette.Wood,Enum.Material.Wood)
    local dark=t.Forest=='Nocthar'
    for i=1,3 do
        local canopy=color(if dark then {49,65+i*7,66} else {68+i*12,125+i*12,76})
        local size=if t.Variant==0 then Vector3.new(16-i*3,10,16-i*3)*s else Vector3.new(16-i,9,13+i)*s
        G.detail(m,'Canopy',size,cf*CFrame.new(if t.Variant==0 then 0 else math.sin(i+t.Variant)*3*s,(14+i*4)*s,0),canopy,Enum.Material.Grass,Enum.PartType.Ball)
    end
    if t.Variant==2 then G.detail(m,'GroundShrub',Vector3.new(5,2,4)*s,cf*CFrame.new(4,1,2),color(if dark then {70,76,81}else{82,129,71}),Enum.Material.Grass,Enum.PartType.Ball)end
    G.beam(m,cf:PointToWorldSpace(Vector3.new(0,10*s,0)),cf:PointToWorldSpace(Vector3.new(6*s,17*s,0)),s,G.Palette.Wood,Enum.Material.Wood)
    return m
end
function C.cities(root,c,plan,checkpoint)
    for _,city in plan.Cities do
        print('[Cidade] '..city.Name)
        local parent=G.model(root.Cities,city.Id)
        parent:SetAttribute('RegionName',city.Name)
        local cf=CFrame.new(city.X,city.H,city.Z)
        G.part(parent,'Plaza',Vector3.new(64,0.5,64),cf,Color3.fromRGB(149,147,128),Enum.Material.Cobblestone)
        local well=G.model(parent,'Well')
        G.part(well,'Basin',Vector3.new(10,3,10),cf*CFrame.new(23,1.5,0),G.Palette.Stone,Enum.Material.Cobblestone)
        G.detail(well,'Water',Vector3.new(8,0.3,8),cf*CFrame.new(23,3,0),Color3.fromRGB(85,161,186),Enum.Material.Glass)
        for _,x in {18,28} do G.part(well,'Post',Vector3.new(0.8,10,0.8),cf*CFrame.new(x,5,0),G.Palette.Wood,Enum.Material.Wood) end
        G.part(well,'Canopy',Vector3.new(13,1,12),cf*CFrame.new(23,10,0),G.Palette.Roof,Enum.Material.Slate)
        for index,lot in city.Lots do
            local _,pos,role=Buildings.build(parent,lot,city.Id,index)
            local npc=C.npc(root.NPCs,lot.Id..'_NPC',pos,role,city.Id)
            npc:PivotTo(CFrame.lookAt(npc.PrimaryPart.Position,Vector3.new(city.X,npc.PrimaryPart.Position.Y,city.Z)))
            checkpoint()
        end
        local radius
        for _,config in c.Cities do if config.Id==city.Id then radius=config.Radius-6 end end
        -- Muralha com vãos reservados às rotas. Nada fecha uma estrada.
        if city.Id=='Arkheim' or city.Id=='Valoria' then
            for i=1,64 do
                local a=i/64*math.pi*2
                local x,z=city.X+math.sin(a)*radius,city.Z+math.cos(a)*radius
                local free=true
                for _,road in c.Roads do
                    local dx,dz=road.B.X-road.A.X,road.B.Z-road.A.Z
                    local t=math.clamp(((x-road.A.X)*dx+(z-road.A.Z)*dz)/(dx*dx+dz*dz),0,1)
                    if math.sqrt((x-road.A.X-t*dx)^2+(z-road.A.Z-t*dz)^2)<30 then free=false end
                end
                if free then
                    local h=if city.Id=='Arkheim' then 12 else 6
                    local frame=CFrame.new(x,city.H+h/2,z)*CFrame.Angles(0,a,0)
                    G.part(parent,'CityWall',Vector3.new(radius*math.pi/32+1,h,3),frame,G.Palette.Stone,Enum.Material.Cobblestone)
                    if i%2==0 then G.part(parent,'Merlon',Vector3.new(3,2,3),frame*CFrame.new(0,h/2+1,0),G.Palette.Stone,Enum.Material.Cobblestone) end
                end
            end
        end
        for _,offset in {Vector3.new(-24,0,-24),Vector3.new(24,0,24)} do G.torch(parent,cf*CFrame.new(offset+Vector3.new(0,2,0)),true) end
        local board=G.sign(parent,'MISSÕES • GUILDA',cf*CFrame.new(-23,5,0),12)
        board:SetAttribute('QuestBoard',true); G.prompt(board,'Consultar','Quadro de missões')
        local handoff=G.marker(root.InteractiveObjects,city.Id..'_Supplies',Vector3.new(city.X-24,city.H+3,city.Z+12),{Objective='Supplies'})
        if city.Id=='Durakh' then handoff.Transparency=0; G.prompt(handoff,'Entregar','Suprimentos') end
        G.marker(root.CinematicMarkers,city.Id..'_Shot',Vector3.new(city.X,city.H+60,city.Z+120),{
            ShotName=city.Id..'_Plaza',RegionName=city.Name,CameraPosition=Vector3.new(city.X,city.H+60,city.Z+120),LookAtPosition=Vector3.new(city.X,city.H+10,city.Z),Duration=8,Category='City'})
        checkpoint()
    end
end
function C.roads(root,plan,checkpoint)
    for _,route in plan.Roads do
        local parent=G.model(root.Roads,route.Id)
        parent:SetAttribute('RouteId',route.Id)
        for i,s in route.Segments do
            local a,b=Vector3.new(s.A.X,s.A.H+0.5,s.A.Z),Vector3.new(s.B.X,s.B.H+0.5,s.B.Z)
            local cf=CFrame.lookAt((a+b)/2,b)
            G.part(parent,if s.Bridge then 'BridgeDeck' else 'Road',Vector3.new(18,0.7,(b-a).Magnitude+0.2),cf,
                if s.Bridge then G.Palette.Wood else Color3.fromRGB(149,128,93),if s.Bridge then Enum.Material.WoodPlanks else Enum.Material.Ground)
            if s.Bridge then
                local bridge=G.model(root.Bridges,route.Id..'_'..i)
                for _,side in {-1,1} do
                    G.part(bridge,'Rail',Vector3.new(0.5,0.8,(b-a).Magnitude+0.2),cf*CFrame.new(side*9,3,0),G.Palette.Wood,Enum.Material.Wood)
                    G.part(bridge,'Support',Vector3.new(1,18,1),cf*CFrame.new(side*8,-9,0),G.Palette.Stone,Enum.Material.Cobblestone)
                end
            end
        end
        G.sign(parent,route.Id,CFrame.new(route.A.X+15,route.A.H+5,route.A.Z),14)
        checkpoint()
    end
end
function C.forests(root,c,plan,checkpoint)
    local chestOverrides={}
    local folders={}
    for _,f in c.Forests do folders[f.Id]=G.model(root.Forests,f.Id); folders[f.Id]:SetAttribute('RegionName',f.Name) end
    for i,t in plan.Trees do C.tree(folders[t.Forest],t); if i%20==0 then checkpoint() end end
    for _,land in plan.Landmarks do
        local cf=CFrame.new(land.X,land.H,land.Z)
        local parent=folders[land.Id]
        -- Clareira central: ruínas, altar, missão e acampamento.
        for i=1,6 do
            local a=i/6*math.pi*2
            G.part(parent,'RuinedPillar',Vector3.new(4,8+i%3*3,4),cf*CFrame.new(math.sin(a)*35,4,math.cos(a)*35),G.Palette.Stone,Enum.Material.Rock)
        end
        local altar=G.part(parent,'Altar',Vector3.new(10,3,7),cf*CFrame.new(0,1.5,0),G.Palette.Stone,Enum.Material.Slate)
        altar:SetAttribute('Objective','Ruins'); G.prompt(altar,'Investigar','Ruínas antigas')
        local herb=G.crystal(parent,cf*CFrame.new(20,2,12),Color3.fromRGB(107,237,152),0.5)
        herb:SetAttribute('Objective','Herb'); G.prompt(herb,'Coletar','Erva rara')
        C.npc(root.NPCs,land.Id..'_Explorer',Vector3.new(land.X-20,land.H,land.Z), 'Quest',land.Id)
        if land.Id=='Nocthar' then
            for i=1,3 do G.part(parent,'BanditTent',Vector3.new(12,7,10),cf*CFrame.new(i*18-36,3.5,-40)*CFrame.Angles(0,0,0.2),Color3.fromRGB(91,75,61),Enum.Material.Fabric) end
            G.sign(parent,'O selo está quebrado...',cf*CFrame.new(0,6,-15),20)
        end
        -- Small explorable cave in the reserved clearing, without deleting Terrain or adding loot IDs.
        local caveZ=land.Z+45
        local caveY=require(script.Parent.TerrainMath).height(c,land.X,caveZ)
        local cave=G.model(parent,'HiddenCave');local caveFrame=CFrame.new(land.X,caveY,caveZ)
        G.part(cave,'CaveFoundation',Vector3.new(24,5,24),caveFrame,G.Palette.Stone,Enum.Material.Rock)
        for _,side in {-1,1}do G.part(cave,'CaveSide',Vector3.new(4,11,24),caveFrame*CFrame.new(side*11,7,0),G.Palette.Stone,Enum.Material.Rock)end
        G.part(cave,'CaveRoof',Vector3.new(26,4,26),caveFrame*CFrame.new(0,14,0),G.Palette.Stone,Enum.Material.Rock)
        for i=1,3 do G.part(cave,'CaveStep',Vector3.new(8,i*0.8,2),caveFrame*CFrame.new(0,i*0.4,-19+i*2),G.Palette.Stone,Enum.Material.Rock)end
        for _,side in {-1,1}do
            G.detail(cave,'EntranceBoulder',Vector3.new(8,11,8),caveFrame*CFrame.new(side*11,7,-9),G.Palette.Stone,Enum.Material.Rock,Enum.PartType.Ball)
        end
        G.detail(cave,'CaveCrown',Vector3.new(24,6,23),caveFrame*CFrame.new(0,15,1),G.Palette.Stone,Enum.Material.Rock,Enum.PartType.Ball)
        G.part(cave,'CaveBack',Vector3.new(24,11,3),caveFrame*CFrame.new(0,7,11),G.Palette.Stone,Enum.Material.Rock)
        G.crystal(cave,caveFrame*CFrame.new(7,6,5),if land.Id=='Sylvarin' then Color3.fromRGB(95,188,171)else Color3.fromRGB(155,97,177),0.5)
        chestOverrides[land.Id..'Chest5']=Vector3.new(land.X,caveY+2.6,caveZ+5)
        for i=1,8 do
            local r=15+i*2
            G.detail(parent,'Rock',Vector3.new(3+i%3,2,4),cf*CFrame.new(math.sin(i*2)*r,0.8,math.cos(i*2)*r),G.Palette.Stone,Enum.Material.Rock,Enum.PartType.Ball)
        end
        G.marker(root.CinematicMarkers,land.Id..'_Shot',Vector3.new(land.X,land.H+25,land.Z+65),{
            ShotName=land.Id,RegionName=land.Id,CameraPosition=Vector3.new(land.X,land.H+25,land.Z+65),LookAtPosition=Vector3.new(land.X,land.H+8,land.Z),Duration=7,Category='Forest'})
        C.enemyMarker(root.EnemySpawns,land.Id..'_Boss',Vector3.new(land.X+45,land.H,land.Z),if land.Id=='Sylvarin' then 'SylvarinBoss' else 'NoctharBoss')
        checkpoint()
    end
    for _,s in plan.EnemySpawns do C.enemyMarker(root.EnemySpawns,s.Id,Vector3.new(s.X,s.H,s.Z),s.Kind) end
    for _,chest in plan.Chests do C.chest(root.TreasureChests,chest.Id,chestOverrides[chest.Id] or Vector3.new(chest.X,chest.H,chest.Z),chest.Rarity) end
end
function C.entrance(root,c,terrain)
    local d=c.DungeonEntrance
    local pos=Vector3.new(d.X,terrain.height(c,d.X,d.Z),d.Z)
    local cf=CFrame.new(pos); local m=root.DungeonEntrance
    G.part(m,'StairPlatform',Vector3.new(60,2,40),cf,G.Palette.Stone,Enum.Material.Cobblestone)
    for _,x in {-20,20} do
        G.part(m,'GateTower',Vector3.new(12,36,12),cf*CFrame.new(x,18,0),G.Palette.Stone,Enum.Material.Slate)
        G.crystal(m,cf*CFrame.new(x,38,0),Color3.fromRGB(210,58,107),2)
        G.torch(m,cf*CFrame.new(x,7,9),true)
    end
    G.part(m,'Lintel',Vector3.new(48,7,10),cf*CFrame.new(0,30,0),G.Palette.Stone,Enum.Material.Slate)
    for i=1,5 do G.part(m,'Stairs',Vector3.new(30,i,4),cf*CFrame.new(0,i/2,28-i*4),G.Palette.Stone,Enum.Material.Cobblestone) end
    G.sign(m,'ABISMO DE MALGORTH',cf*CFrame.new(0,23,6),26)
    C.npc(root.NPCs,'DungeonGuardian',pos+Vector3.new(0,1,15),'Dungeon','Malgorth')
    G.marker(root.CinematicMarkers,'DungeonShot',pos+Vector3.new(0,48,100),{ShotName='DungeonGate',RegionName='Malgorth',CameraPosition=pos+Vector3.new(0,48,100),LookAtPosition=pos+Vector3.new(0,20,0),Duration=8,Category='Dungeon'})
end
return C
