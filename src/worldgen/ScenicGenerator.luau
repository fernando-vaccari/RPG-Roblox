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
function S.forest(parent,land,c,terrain,Content)
    local cf=CFrame.new(land.X,land.H,land.Z)
    local dark=land.Id=='Vespera'
    local tint=if dark then Color3.fromRGB(74,73,91) else Color3.fromRGB(119,130,110)
    local grove=G.model(parent,'HeartGrove')
    grove:SetAttribute('OpenClearingRadius',28)
    -- Deliberately offset the monument; the central clearing remains traversable.
    if land.Id=='Nocthar' then
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
            -- Original small wayside cottages, open fronts and pitched roofs.
            for i=1,3 do
                local x,z=site.X+(i-2)*31,site.Z+(i%2)*28
                local hc=terrain.height(c,x,z);local house=G.model(model,'WaysideCottage'..i);local f=CFrame.new(x,hc,z)
                G.part(house,'Foundation',Vector3.new(22,2,24),f,G.Palette.Stone,Enum.Material.Cobblestone)
                for _,side in {-1,1} do
                    G.part(house,'Side',Vector3.new(1,13,22),f*CFrame.new(side*10,7,0),Color3.fromRGB(183,171,138),Enum.Material.WoodPlanks)
                    G.part(house,'Roof',Vector3.new(13,1,26),f*CFrame.new(side*5.5,16,0)*CFrame.Angles(0,0,-side*0.48),Color3.fromRGB(95,112,89),Enum.Material.Slate)
                    G.part(house,'DoorJamb',Vector3.new(6,13,1),f*CFrame.new(side*7,7,-11),G.Palette.Wood,Enum.Material.Wood)
                end
                G.part(house,'Back',Vector3.new(22,13,1),f*CFrame.new(0,7,11),Color3.fromRGB(183,171,138),Enum.Material.WoodPlanks)
                G.part(house,'Lintel',Vector3.new(8,4,1),f*CFrame.new(0,12,-11),G.Palette.Wood,Enum.Material.Wood)
                G.part(house,'Chimney',Vector3.new(3,9,3),f*CFrame.new(6,17,5),G.Palette.Stone,Enum.Material.Brick)
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
