-- Original environmental kit. Scenery only: no prompts, rewards, actors or combat.
local G=require(script.Parent.Geometry)
local S={}
local moss=Color3.fromRGB(91,116,76)
local function small(parent,name,size,cf,color,material,shape)
    local p=G.detail(parent,name,size,cf,color,material,shape)
    p.CastShadow=false;p:SetAttribute('DetailTier',2);p:SetAttribute('DetailDistance',220)
    return p
end
function S.boulder(parent,cf,scale,tint)
    local m=G.model(parent,'WeatheredBoulder')
    G.part(m,'StoneMass',Vector3.new(9,6,7)*scale,cf*CFrame.Angles(0,0.4,0.17),tint or G.Palette.Stone,Enum.Material.Rock,Enum.PartType.Ball)
    small(m,'Moss',Vector3.new(6,0.45,4)*scale,cf*CFrame.new(0,2.8*scale,0),moss,Enum.Material.Grass,Enum.PartType.Ball)
    return m
end
function S.shrub(parent,cf,scale,dark)
    local tint=if dark then Color3.fromRGB(55,67,73) else Color3.fromRGB(73,123,66)
    for i=1,3 do
        small(parent,'Understory',Vector3.new(4-i*0.4,2+i*0.3,3)*scale,cf*CFrame.new((i-2)*1.8*scale,scale,math.sin(i)*scale),tint,Enum.Material.Grass,Enum.PartType.Ball)
    end
end
-- The silhouette is essential scenery, not a detail that LOW quality removes.
-- 12-18 native parts per tree, no imported meshes, scripts, particles or lights.
function S.monumentalTree(parent,t)
    local scale=t.Scale or 1
    local variant=(t.Variant or 0)%5
    local dark=t.Forest=='Vespera';local old=t.Forest=='Nocthar'
    local cf=CFrame.new(t.X,t.H,t.Z)*CFrame.Angles(0,variant*0.91,0)
    local model=G.model(parent,'CanopyTree_'..variant)
    model:SetAttribute('TreeVariant',variant);model:SetAttribute('ForestId',t.Forest)
    model:SetAttribute('MonumentalTree',true)
    local pine=variant==2
    local height=if pine then 72 elseif variant==4 then 65 else 48+variant*5
    local width=if variant==4 or old then 7.5 elseif variant==1 then 4 else 5.5
    local wood=if dark then Color3.fromRGB(68,61,75) elseif variant==1 then Color3.fromRGB(177,179,148) else Color3.fromRGB(89,74,52)
    local leaf=if dark then Color3.fromRGB(51,76,83) elseif old then Color3.fromRGB(69,105,75) else Color3.fromRGB(75,133,76)
    local crownRadius=if pine then 19 else 34
    model:SetAttribute('TreeHeight',(height+24)*scale)
    model:SetAttribute('CanopyRadius',crownRadius*scale)
    local function at(x,y,z)return cf:PointToWorldSpace(Vector3.new(x,y,z)*scale)end
    -- Embed the trunk foot to avoid a visibly floating base on rolling terrain.
    G.part(model,'AncientTrunk',Vector3.new(height+6,width,width)*scale,
        cf*CFrame.new(0,(height/2-3)*scale,0)*CFrame.Angles(0,0,math.pi/2),wood,Enum.Material.Wood,Enum.PartType.Cylinder)
    local roots=if pine then 3 else 4
    for i=1,roots do
        local a=i*math.pi*2/roots+0.35
        local root=G.beam(model,at(math.sin(a)*width*0.3,8,math.cos(a)*width*0.3),
            at(math.sin(a)*13,-1,math.cos(a)*13),2.6*scale,wood,Enum.Material.Wood)
        root.Name='ButtressRoot'
    end
    if pine then
        -- Broad cedar tiers narrow towards the crown instead of repeated spheres.
        for i=1,6 do
            local span=43-i*5
            local crown=G.detail(model,'Canopy',Vector3.new(span,16-i,span)*scale,
                cf*CFrame.new(math.sin(i)*1.6*scale,(25+i*7.4)*scale,math.cos(i)*1.6*scale),leaf,Enum.Material.Grass,Enum.PartType.Ball)
            crown.CastShadow=false
        end
        for i=1,2 do
            local limb=G.beam(model,at(0,29+i*7,0),at(13-i*3,36+i*7,i*4-6),2*scale,wood,Enum.Material.Wood)
            limb.Name='CedarBough';limb.CanCollide=false;limb.CanQuery=false;limb.CastShadow=false
        end
    else
        for i=1,3 do
            local a=i*2.399+variant*0.4
            local dx,dz=math.sin(a)*18,math.cos(a)*18
            local limb=G.beam(model,at(0,height*0.55,0),at(dx,height-4+i*2,dz),(2.8-i*0.25)*scale,wood,Enum.Material.Wood)
            limb.Name='CrownBough';limb.CanCollide=false;limb.CanQuery=false;limb.CastShadow=false
            for layer=1,2 do
                local span=if layer==1 then 35 else 27
                local tint=if layer==1 then leaf else Color3.fromRGB(
                    (if dark then 63 elseif old then 90 else 99),
                    (if dark then 86 elseif old then 125 else 151),
                    (if dark then 92 elseif old then 82 else 82))
                local crown=G.detail(model,'Canopy',Vector3.new(span,if layer==1 then 17 else 14,span-3)*scale,
                    cf*CFrame.new(dx*(if layer==1 then 0.8 else 0.4)*scale,(height-3+layer*8+i%2*3)*scale,dz*(if layer==1 then 0.8 else 0.4)*scale),tint,Enum.Material.Grass,Enum.PartType.Ball)
                crown.CastShadow=false
            end
        end
    end
    -- A single fern pair gives a visible forest floor without thousands of emitters.
    if variant==0 or variant==4 then
        for _,side in {-1,1} do
            small(model,'GroundFern',Vector3.new(8,2.5,4)*scale,
                cf*CFrame.new((7+side*2)*scale,scale,side*4*scale)*CFrame.Angles(0,side*0.6,side*0.15),leaf,Enum.Material.Grass,Enum.PartType.Ball)
        end
    end
    return model
end
function S.ruinedArch(parent,cf,tint)
    local m=G.model(parent,'ForgottenArch')
    for _,side in {-1,1} do
        G.part(m,'PillarFoot',Vector3.new(7,2,7),cf*CFrame.new(side*10,1,0),tint,Enum.Material.Cobblestone)
        G.part(m,'WeatheredColumn',Vector3.new(4,14,4),cf*CFrame.new(side*10,9,0),tint,Enum.Material.Rock)
        G.part(m,'ArchShoulder',Vector3.new(7,3,5),cf*CFrame.new(side*7,17,0)*CFrame.Angles(0,0,side*0.5),tint,Enum.Material.Slate)
    end
    G.part(m,'Keystone',Vector3.new(6,4,5),cf*CFrame.new(0,19,0),tint,Enum.Material.Slate)
    for i=1,4 do S.boulder(m,cf*CFrame.new(15+i*3,1,-i*3),0.4,tint) end
    return m
end
function S.cave(parent,cf,dark)
    local m=G.model(parent,'HiddenCave')
    local stone=if dark then Color3.fromRGB(68,69,84) else Color3.fromRGB(108,117,108)
    G.part(m,'CaveFloor',Vector3.new(30,2,36),cf,stone,Enum.Material.Rock)
    for _,side in {-1,1} do
        G.part(m,'CaveSide',Vector3.new(5,14,32),cf*CFrame.new(side*15,8,3),stone,Enum.Material.Rock)
        for i=1,3 do
            G.detail(m,'EntranceRock',Vector3.new(9-i,9,10),cf*CFrame.new(side*(14-i),4+i*4,-12)*CFrame.Angles(0,i*0.2,side*0.2),stone,Enum.Material.Rock,Enum.PartType.Ball)
        end
    end
    G.part(m,'CaveVault',Vector3.new(34,5,35),cf*CFrame.new(0,17,3),stone,Enum.Material.Rock)
    G.part(m,'CaveBack',Vector3.new(33,15,4),cf*CFrame.new(0,8,20),stone,Enum.Material.Rock)
    for i=1,3 do
        small(m,'Stalactite',Vector3.new(1.5,4+i,1.5),cf*CFrame.new(-10+i*6,12+i*0.5,9),stone,Enum.Material.Rock)
    end
    G.crystal(m,cf*CFrame.new(9,4,9),if dark then Color3.fromRGB(129,101,166) else Color3.fromRGB(104,171,163),0.7)
    for i=1,4 do S.boulder(m,cf*CFrame.new(18+i*2,1,-4+i*4),0.6,stone) end
    m:SetAttribute('IntegrationKind','Cave');m:SetAttribute('WalkableOpeningWidth',20)
    return m
end
local function monumentalGrove(grove,land,c,terrain)
    local dark=land.Id=='Vespera'
    local old=land.Id=='Nocthar'
    grove:SetAttribute('MonumentalSanctuary',true)
    grove:SetAttribute('OpenClearingRadius',28)
    grove:SetAttribute('DisplayName',if old then 'Raiz do Primeiro Mundo' elseif dark then 'Círculo das Vigílias' else 'Catedral das Folhas')
    -- The immense heart tree stands beside the clearing, never on its path.
    local x,z=land.X-49,land.Z-29
    S.monumentalTree(grove,{X=x,H=terrain.height(c,x,z),Z=z,Scale=if old then 2.1 else 1.65,
        Variant=if dark then 2 else 4,Forest=land.Id})
    local stone=if dark then Color3.fromRGB(79,76,93) elseif old then Color3.fromRGB(111,120,98) else Color3.fromRGB(159,171,130)
    if dark then
        -- Broken watch stones frame a cathedral-like void. No light emitters.
        for i=1,5 do
            local a=math.rad(38+i*47)
            local px,pz=land.X+math.sin(a)*48,land.Z+math.cos(a)*48
            if px<land.X-20 and pz<land.Z then continue end -- elder tree roots
            local cf=CFrame.new(px,terrain.height(c,px,pz),pz)*CFrame.Angles(0,a,0)
            G.part(grove,'WatchStonePlinth',Vector3.new(12,3,12),cf*CFrame.new(0,1.5,0),stone,Enum.Material.Cobblestone)
            G.part(grove,'WatchStone',Vector3.new(6,29+i*2,7),cf*CFrame.new(0,15+i,0)*CFrame.Angles(0,0,0.06),stone,Enum.Material.Slate)
            G.detail(grove,'StoneInlay',Vector3.new(0.8,18,0.25),cf*CFrame.new(0,17,-3.6),Color3.fromRGB(122,112,153),Enum.Material.SmoothPlastic)
        end
    else
        -- A column grove gives human-scale detail beneath the gigantic canopy.
        for _,offset in {{38,-31},{-34,39}} do
            local px,pz=land.X+offset[1],land.Z+offset[2]
            local cf=CFrame.new(px,terrain.height(c,px,pz),pz)*CFrame.Angles(0,if offset[1]>0 then -0.65 else 0.8,0)
            local arch=S.ruinedArch(grove,cf,stone)
            arch.Name=if old then 'RootboundReliquary' else 'LeafSanctuaryArch'
            for _,side in {-1,1} do
                G.detail(arch,'ClimbingMoss',Vector3.new(2,11,0.4),cf*CFrame.new(side*10,8,-2.2),moss,Enum.Material.Grass)
            end
        end
    end
    -- Flat stepping stones and fern islands leave the central 28-stud radius open.
    for i=1,8 do
        local a=i*2.399;local px,pz=land.X+math.sin(a)*56,land.Z+math.cos(a)*56
        if px<land.X-20 and pz<land.Z then continue end
        if math.abs(px-land.X)<24 and pz>land.Z+20 then continue end -- cave approach
        local cf=CFrame.new(px,terrain.height(c,px,pz),pz)*CFrame.Angles(0,a,0)
        S.shrub(grove,cf,1.4,dark)
        small(grove,'MossPlate',Vector3.new(9,0.5,6),cf*CFrame.new(0,0.35,0),moss,Enum.Material.Grass,Enum.PartType.Ball)
    end
end
function S.forest(parent,land,c,terrain,Content)
    local cf=CFrame.new(land.X,land.H,land.Z)
    local dark=land.Id=='Vespera'
    local tint=if dark then Color3.fromRGB(74,73,91) else Color3.fromRGB(119,130,110)
    local grove=G.model(parent,'HeartGrove')
    grove:SetAttribute('OpenClearingRadius',28)
    -- Deliberately offset the monument; the central clearing remains traversable.
    if c.MonumentalMap then
        monumentalGrove(grove,land,c,terrain)
    elseif land.Id=='Nocthar' then
        Content.tree(grove,{X=land.X-42,H=terrain.height(c,land.X-42,land.Z-25),Z=land.Z-25,Scale=2.25,Variant=4,Forest=land.Id})
        for i=1,5 do
            G.beam(grove,cf:PointToWorldSpace(Vector3.new(-42,1,-25)),cf:PointToWorldSpace(Vector3.new(-42+math.sin(i*1.3)*34,1,-25+math.cos(i*1.3)*34)),3,tint,Enum.Material.Wood)
        end
        S.ruinedArch(grove,cf*CFrame.new(25,0,-36)*CFrame.Angles(0,0.4,0),tint)
    elseif dark then
        for i=1,4 do
            local a=i*1.7
            G.part(grove,'CorruptedMenhir',Vector3.new(3,11+i,4),cf*CFrame.new(math.sin(a)*36,5+i*0.5,math.cos(a)*36)*CFrame.Angles(0,a,0.14),tint,Enum.Material.Slate)
        end
        S.ruinedArch(grove,cf*CFrame.new(-35,0,-32)*CFrame.Angles(0,0.3,0),tint)
    else
        S.ruinedArch(grove,cf*CFrame.new(-36,0,-29)*CFrame.Angles(0,-0.4,0),tint)
        for i=1,5 do S.shrub(grove,cf*CFrame.new(28+i*2,0,-24+i*5),0.75,false) end
    end
    local reservation
    for _,site in c.ScenicReservations or {} do if site.Id==land.Id..'Cave' then reservation=site;break end end
    local caveX,caveZ=if reservation then reservation.X else land.X+8,if reservation then reservation.Z else land.Z+60
    local caveY=terrain.height(c,caveX,caveZ)
    S.cave(parent,CFrame.new(caveX,caveY,caveZ),dark)
    -- Split approach trail skirts scenery and joins the open clearing.
    for _,side in {-1,1} do
        local fromX,fromZ=land.X+side*28,land.Z
        local toX,toZ=caveX+side*4,caveZ-20
        for i=0,7 do
            local aT,bT=i/8,(i+1)/8
            local ax,az=fromX+(toX-fromX)*aT,fromZ+(toZ-fromZ)*aT
            local bx,bz=fromX+(toX-fromX)*bT,fromZ+(toZ-fromZ)*bT
            local a=Vector3.new(ax,terrain.height(c,ax,az)+0.25,az)
            local b=Vector3.new(bx,terrain.height(c,bx,bz)+0.25,bz)
            G.detail(parent,'ForestTrail',Vector3.new(5,0.25,(b-a).Magnitude+0.15),CFrame.lookAt((a+b)/2,b),Color3.fromRGB(119,105,80),Enum.Material.Ground)
        end
    end
    for i=1,9 do
        local a=i*2.399;local r=32+i%3*8
        local x,z=land.X+math.sin(a)*r,land.Z+math.cos(a)*r
        S.boulder(parent,CFrame.new(x,terrain.height(c,x,z)+0.5,z),0.4+i%3*0.1,tint)
    end
    return Vector3.new(caveX,caveY+2,caveZ+10)
end
local function tent(parent,cf,tint)
    local width,depth,height=14,18,8
    for _,side in {-1,1} do
        G.part(parent,'TentCanvas',Vector3.new(11,0.4,depth),cf*CFrame.new(side*3.5,4,0)*CFrame.Angles(0,0,-side*0.8),tint,Enum.Material.Fabric)
        G.beam(parent,cf:PointToWorldSpace(Vector3.new(side*7,0,-9)),cf:PointToWorldSpace(Vector3.new(0,height,-9)),0.4,G.Palette.Wood,Enum.Material.Wood)
    end
    G.beam(parent,cf:PointToWorldSpace(Vector3.new(0,height,-9)),cf:PointToWorldSpace(Vector3.new(0,height,9)),0.4,G.Palette.Wood,Enum.Material.Wood)
end
function S.continent(parent,c,plan,terrain)
    local catalog={
        {Id='MeadowCamp',Kind='Camp',X=440,Z=1250,Name='Acampamento da Estrada Dourada'},
        {Id='MossVillage',Kind='Hamlet',X=1520,Z=-600,Name='Vila do Salgueiro'},
        {Id='BrokenWatch',Kind='Fort',X=-1550,Z=480,Name='Fortaleza do Sino Partido'},
        {Id='RoyalOverlook',Kind='Overlook',X=440,Z=-1450,Name='Mirante das Coroas'},
        {Id='HiddenSanctuary',Kind='Secret',X=-520,Z=-1390,Name='Jardim do Juramento'},
    }
    local folder=G.model(parent,'ScenicRegions')
    for _,site in catalog do
        for _,reservation in c.ScenicReservations or {} do
            if reservation.Id==site.Id then site.X,site.Z=reservation.X,reservation.Z;break end
        end
        local h=terrain.height(c,site.X,site.Z)
        local cf=CFrame.new(site.X,h,site.Z)
        local model=G.model(folder,site.Id)
        model:SetAttribute('RegionId',site.Id);model:SetAttribute('IntegrationKind',site.Kind)
        model:SetAttribute('DisplayName',site.Name)
        if site.Kind=='Camp' then
            for i=1,3 do tent(model,cf*CFrame.new((i-2)*24,0,12+(i%2)*8),Color3.fromRGB(135+i*8,121,86)) end
            for i=1,7 do S.boulder(model,cf*CFrame.new(math.sin(i)*5,0.5,-10+math.cos(i)*5),0.25) end
            G.detail(model,'Ashes',Vector3.new(6,0.2,6),cf*CFrame.new(0,0.2,-10),Color3.fromRGB(55,51,46),Enum.Material.Ground,Enum.PartType.Ball)
            for _,side in {-1,1} do G.part(model,'CampBench',Vector3.new(10,1.2,3),cf*CFrame.new(side*12,1.5,-10),G.Palette.Wood,Enum.Material.Wood) end
        elseif site.Kind=='Hamlet' then
            -- The hamlet shares the detailed facade/sign grammar of the city homes.
            local buildings=require(script.Parent.BuildingGenerator)
            for i=1,3 do
                local x,z=site.X+(i-2)*31,site.Z+(i%2)*28
                buildings.build(model,{Id='WaysideCottage'..i,Kind='SmallHouse',X=x,Z=z,H=terrain.height(c,x,z),
                    Yaw=0,Residential=true,Interior=false,Variation=i,District='Vila do Salgueiro'},'Eldoria',i)
            end
        elseif site.Kind=='Fort' then
            for _,side in {-1,1} do
                G.part(model,'RuinedTower',Vector3.new(13,24+side*4,13),cf*CFrame.new(side*25,12+side*2,0),Color3.fromRGB(91,99,100),Enum.Material.Cobblestone)
                for i=1,3 do G.part(model,'Merlon',Vector3.new(3,3,3),cf*CFrame.new(side*25+i*4-8,26+side*4,-6),G.Palette.Stone,Enum.Material.Cobblestone) end
                G.part(model,'BrokenWall',Vector3.new(25,11,4),cf*CFrame.new(side*28,5.5,28),G.Palette.Stone,Enum.Material.Cobblestone)
            end
            S.ruinedArch(model,cf,Color3.fromRGB(91,99,100))
        elseif site.Kind=='Overlook' then
            G.part(model,'ViewingTerrace',Vector3.new(42,3,24),cf,G.Palette.Stone,Enum.Material.Cobblestone)
            for _,side in {-1,1} do G.part(model,'Parapet',Vector3.new(2,3,24),cf*CFrame.new(side*20,3,0),G.Palette.Stone,Enum.Material.Cobblestone) end
            G.part(model,'BackParapet',Vector3.new(42,3,2),cf*CFrame.new(0,3,12),G.Palette.Stone,Enum.Material.Cobblestone)
            G.sign(model,site.Name,cf*CFrame.new(0,5,11),24)
        else
            S.ruinedArch(model,cf,Color3.fromRGB(137,145,125))
            for _,side in {-1,1} do S.shrub(model,cf*CFrame.new(side*18,0,8),1.7,false) end
        end
        local marker=G.marker(model,site.Id..'_Integration',Vector3.new(site.X,h+3,site.Z),{IntegrationId=site.Id,IntegrationKind=site.Kind})
        marker:SetAttribute('Radius',50)
    end
    return catalog
end
return S
