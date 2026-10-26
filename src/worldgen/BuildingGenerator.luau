local G=require(script.Parent.Geometry)
local Catalog=require(game.ReplicatedStorage.MedievalRPG.Config.ContentConfig)
local Interiors=require(game.ReplicatedStorage.MedievalRPG.Core.InteriorPlan)
local B={}
local palette={Valoria=Color3.fromRGB(144,65,45),Arkheim=Color3.fromRGB(63,88,123),Eldoria=Color3.fromRGB(72,121,91),Durakh=Color3.fromRGB(136,94,56),Asterion=Color3.fromRGB(67,88,147)}
function B.build(parent,lot,city,index)
    local kind=lot.Kind
    local m=G.model(parent,lot.Id); m:SetAttribute('Template',kind)
    local cf=CFrame.new(lot.X,lot.H,lot.Z)*CFrame.Angles(0,lot.Yaw,0)
    local roofColor=palette[city] or G.Palette.Roof
    local width,depth,height=26+(index%3)*2,28+(index%2)*2,16+(index%3)*2
    if kind=='Castle' then width,depth,height=44,40,26 end
    if kind=='ArcaneTower' then width,depth,height=24,24,48 end
    if kind=='Forge' then width,depth,height=38,34,23 end
    local function part(name,size,x,y,z,color,mat)
        return G.part(m,name,size,cf*CFrame.new(x,y,z),color,mat)
    end
    part('Foundation',Vector3.new(width+2,2,depth+2),0,0,0,G.Palette.Stone,Enum.Material.Cobblestone)
    part('Floor',Vector3.new(width,1,depth),0,1,0,G.Palette.Wood,Enum.Material.WoodPlanks)
    part('Back',Vector3.new(width,height,1),0,height/2,-(-depth/2),G.Palette.Plaster,Enum.Material.Limestone)
    for _,side in {-1,1} do
        part('SideWall',Vector3.new(1,height,depth),side*width/2,height/2,0,G.Palette.Plaster,Enum.Material.Limestone)
        part('DoorSide',Vector3.new((width-7)/2,height,1),side*(width+7)/4,height/2,-depth/2,G.Palette.Plaster,Enum.Material.Limestone)
        for _,z in {-depth/2,depth/2} do
            part('TimberPost',Vector3.new(1.2,height+1,1.2),side*width/2,height/2,z,G.Palette.Wood,Enum.Material.Wood)
        end
        for _,y in {4,height-2} do
            if side==-1 and y<9 then
                for _,xSide in {-1,1} do part('TimberRail',Vector3.new((width-8)/2,0.6,1.3),xSide*(width+8)/4,y,-depth/2,G.Palette.Wood,Enum.Material.Wood) end
            else part('TimberRail',Vector3.new(width+1,0.6,1.3),0,y,side*depth/2,G.Palette.Wood,Enum.Material.Wood) end
        end
        local glass=part('Window',Vector3.new(4,4,0.25),side*width*0.32,9,-depth/2-0.7,Color3.fromRGB(241,200,103),Enum.Material.Glass)
        glass.CanCollide=false
        for _,dx in {-2.2,2.2} do part('WindowFrame',Vector3.new(0.4,4.8,0.6),side*width*0.32+dx,9,-depth/2-0.8,G.Palette.Wood,Enum.Material.Wood) end
        part('WindowSill',Vector3.new(5,0.5,1),side*width*0.32,6.5,-depth/2-0.8,G.Palette.Wood,Enum.Material.Wood)
    end
    part('DoorLintel',Vector3.new(7,height-9,1),0,9+(height-9)/2,-depth/2,G.Palette.Wood,Enum.Material.Wood)
    -- Porta aberta permanentemente: abertura livre de sete studs, sem bloqueio invisível.
    for _,side in {-1,1} do
        part('DoorFrame',Vector3.new(0.6,9,1.5),side*3.6,4.5,-depth/2,G.Palette.Wood,Enum.Material.Wood)
    end
    local rise=if kind=='ArcaneTower' then 14 else 7
    local slope=math.atan2(rise,width/2+2)
    local length=math.sqrt((width/2+2)^2+rise^2)
    for _,side in {-1,1} do
        G.part(m,'PitchedRoof',Vector3.new(length,1,depth+5),cf*CFrame.new(side*(width/4+1),height+rise/2,0)*CFrame.Angles(0,0,-side*slope),roofColor,Enum.Material.Slate)
    end
    part('Ridge',Vector3.new(1,1,depth+6),0,height+rise,0,G.Palette.Wood,Enum.Material.Wood)
    part('Chimney',Vector3.new(3,9,3),width/3,height+5,depth/4,G.Palette.Stone,Enum.Material.Brick)
    -- Balcão externo e acesso escalonado: as lojas funcionam sem atravessar paredes.
    local role=Catalog.Roles[kind] or 'Citizen'
    if Catalog.Shops[role] or role=='Guild' then
        part('Counter',Vector3.new(10,3,3),-8,2,-depth/2-6,G.Palette.Wood,Enum.Material.WoodPlanks)
        part('Awning',Vector3.new(13,0.5,8),-8,8,-depth/2-5,roofColor,Enum.Material.Fabric)
        for _,x in {-14,-4} do part('AwningPost',Vector3.new(0.5,8,0.5),x,4,-depth/2-9,G.Palette.Wood,Enum.Material.Wood) end
    end
    for i=1,3 do part('Step',Vector3.new(7,0.5,2),0,0.25*i,-depth/2-4+i,G.Palette.Stone,Enum.Material.Cobblestone) end
    G.sign(m,Catalog.Labels[kind] or kind,cf*CFrame.new(0,12,-depth/2-1),math.min(20,width))
    if kind=='Tavern' or kind=='LargeHouse' then
        part('Balcony',Vector3.new(13,0.7,5),0,11,-depth/2-2,G.Palette.Wood,Enum.Material.WoodPlanks)
        part('BalconyRail',Vector3.new(13,0.5,0.5),0,14,-depth/2-4.5,G.Palette.Wood,Enum.Material.Wood)
        for x=-6,6,3 do part('Baluster',Vector3.new(0.4,3,0.4),x,12.5,-depth/2-4.5,G.Palette.Wood,Enum.Material.Wood) end
    end
    if kind=='Castle' or kind=='GuardTower' or kind=='WatchTower' or kind=='Barracks' then
        local towerH=if kind=='Castle' then 38 else height+5
        for _,side in {-1,1} do
            local x=side*(width/2+4)
            part('Turret',Vector3.new(9,towerH,9),x,towerH/2,depth/2-4,G.Palette.Stone,Enum.Material.Cobblestone)
            for i=-1,1 do part('Battlement',Vector3.new(2,3,2),x+i*3,towerH+1,depth/2-8,G.Palette.Stone,Enum.Material.Cobblestone) end
            local flag=part('Banner',Vector3.new(3,8,0.3),x,towerH-6,depth/2-9,roofColor,Enum.Material.Fabric)
            flag:SetAttribute('Flutter',true)
        end
    elseif kind=='ArcaneTower' or kind=='MagicSchool' or kind=='MagicShop' or kind=='Temple' then
        for _,side in {-1,1} do G.crystal(m,cf*CFrame.new(side*7,height+rise+3,0),Color3.fromRGB(124,177,255),1) end
    elseif kind=='Forge' or kind=='Blacksmith' or kind=='SmithGuild' then
        part('Furnace',Vector3.new(9,7,7),width/2-5,4,-depth/2-5,G.Palette.Stone,Enum.Material.Brick)
        G.detail(m,'Embers',Vector3.new(6,2,1),cf*CFrame.new(width/2-5,3,-depth/2-9),Color3.fromRGB(255,105,33),Enum.Material.Neon)
        local anvil=part('Anvil',Vector3.new(5,2,2),-width/2+5,4,-depth/2-5,Color3.fromRGB(49,52,58),Enum.Material.Metal)
        anvil:SetAttribute('Forge',true)
    elseif kind=='Windmill' then
        part('MillTower',Vector3.new(8,30,8),0,15,0,G.Palette.Plaster,Enum.Material.Limestone)
        for i=0,3 do
            G.detail(m,'Sail',Vector3.new(2,16,0.5),cf*CFrame.new(0,24,-depth/2-2)*CFrame.Angles(0,0,i*math.pi/2)*CFrame.new(0,8,0),Color3.fromRGB(220,211,173),Enum.Material.Fabric)
        end
    elseif kind=='Stable' or kind=='Barn' then
        for i=-2,2 do part('FencePost',Vector3.new(0.7,4,0.7),i*5,2,-depth/2-10,G.Palette.Wood,Enum.Material.Wood) end
        part('FenceRail',Vector3.new(22,0.5,0.6),0,3,-depth/2-10,G.Palette.Wood,Enum.Material.Wood)
        if kind=='Barn' then
            part('FarmSoil',Vector3.new(6,0.4,18),width/2+5,0.4,0,Color3.fromRGB(89,68,43),Enum.Material.Ground)
            for row=1,3 do
                for z=-6,6,4 do part('Crop',Vector3.new(0.5,2,0.5),width/2+2+row*1.5,1.5,z,Color3.fromRGB(156,177,70),Enum.Material.Grass) end
            end
        end
        for i=1,4 do part('Hay',Vector3.new(4,3,4),width/2+3,1.5,depth/2-i*5,Color3.fromRGB(207,172,77),Enum.Material.Grass) end
    elseif kind=='Mine' then
        -- Galeria visitável, com piso e pórticos, não escava Terrain alheio.
        for i=1,3 do
            for _,x in {-5,5} do part('MineSupport',Vector3.new(1,7,1),x,3.5,-i*6,G.Palette.Wood,Enum.Material.Wood) end
            part('MineBeam',Vector3.new(12,1,1),0,7,-i*6,G.Palette.Wood,Enum.Material.Wood)
            G.crystal(m,cf*CFrame.new(8,2,-i*6),Color3.fromRGB(126,164,177),0.5)
        end
    elseif kind=='Market' then
        for _,x in {-9,9} do part('Stall',Vector3.new(7,3,5),x,2,-depth/2-5,G.Palette.Wood,Enum.Material.Wood) end
    elseif kind=='Library' then
        for i=1,4 do part('Bookshelf',Vector3.new(10,1,2),0,i*2,depth/2-2,G.Palette.Wood,Enum.Material.Wood); part('Books',Vector3.new(9,1.5,1.5),0,i*2+1,depth/2-2,roofColor,Enum.Material.Fabric) end
    elseif kind=='TrainingHall' then
        for _,x in {-8,8} do
            part('TrainingDummy',Vector3.new(3,5,2),x,3,-depth/2-6,G.Palette.Wood,Enum.Material.Wood)
            part('DummyArms',Vector3.new(7,1,1),x,5,-depth/2-6,G.Palette.Wood,Enum.Material.Wood)
        end
    end
    -- Furnished ground floor; central entry lane remains open.
    local furniture=G.model(m,'Interior')
    for _,spec in Interiors.build(kind,width,depth,height)do
        local tint=if spec.Material=='Fabric' then roofColor elseif spec.Material=='Neon' then Color3.fromRGB(247,207,132)else G.Palette.Wood
        local piece=G.part(furniture,spec.Name,Vector3.new(table.unpack(spec.Size)),cf*CFrame.new(table.unpack(spec.Position)),tint,Enum.Material[spec.Material])
        if not spec.Collide then piece.CanCollide=false;piece.CanQuery=false end
    end
    for _,side in {-1,1}do
        G.detail(m,'DiagonalTimber',Vector3.new(width*0.35,0.5,0.6),cf*CFrame.new(side*width*0.3,height*0.4,-depth/2-0.7)*CFrame.Angles(0,0,side*0.55),G.Palette.Wood,Enum.Material.Wood)
    end
    for i=1,2 do
        G.detail(m,'Barrel',Vector3.new(3,3,3),cf*CFrame.new(width/2+2,1.5,i*4),G.Palette.Wood,Enum.Material.WoodPlanks,Enum.PartType.Cylinder)
    end
    return m,cf:PointToWorldSpace(Vector3.new(0,0,-depth/2-8)),role
end
return B
