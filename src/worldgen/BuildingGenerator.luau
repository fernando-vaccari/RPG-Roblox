local G=require(script.Parent.Geometry)
local Plan=require(script.Parent.ArchitecturalPlan)
local Catalog=require(game.ReplicatedStorage.MedievalRPG.Config.ContentConfig)
local Interiors=require(game.ReplicatedStorage.MedievalRPG.Core.InteriorPlan)
local B={}
local function rgb(t)return Color3.fromRGB(table.unpack(t))end
function B.build(parent,lot,city,index)
 local spec=Plan.build(lot.Kind,city,index,lot)
 local kind,theme=lot.Kind,spec.Theme
 local m=G.model(parent,lot.Id)
 m:SetAttribute('Template',kind);m:SetAttribute('ArchitecturalTheme',theme.Id)
 m:SetAttribute('Variant',spec.Variant);m:SetAttribute('District',spec.District);m:SetAttribute('ExplorableInterior',spec.Interior)
 local cf=CFrame.new(lot.X,lot.H,lot.Z)*CFrame.Angles(0,lot.Yaw,0)
 local w,d,h=spec.Width,spec.Depth,spec.Height
 local stone,plaster,wood,roof,metal,glass=rgb(theme.Stone),rgb(theme.Plaster),rgb(theme.Wood),rgb(theme.Roof),rgb(theme.Metal),rgb(theme.Glass)
 local function part(name,size,x,y,z,color,material,detail,rotation,shape)
  local frame=cf*CFrame.new(x,y,z)*(rotation or CFrame.new())
  local p=(if detail then G.detail else G.part)(m,name,size,frame,color or stone,material or Enum.Material.Cobblestone,shape)
  if detail then p.CastShadow=false end
  return p
 end
 local function beam(name,a,b,width,color)
  local p=G.beam(m,cf:PointToWorldSpace(a),cf:PointToWorldSpace(b),width,color or wood,Enum.Material.Wood)
  p.Name=name;p.CanCollide=false;p.CanQuery=false;p.CastShadow=false;return p
 end
 -- Footings descend into the city platform; no floating plinth or Terrain edits.
 part('Foundation',Vector3.new(w+2,2,d+2),0,-0.8,0)
 part('Floor',Vector3.new(w,0.8,d),0,0.4,0,wood,Enum.Material.WoodPlanks)
 part('Back',Vector3.new(w,h,1),0,h/2,d/2,plaster,Enum.Material.Limestone)
 for _,side in {-1,1} do
  part('SideWall',Vector3.new(1,h,d),side*w/2,h/2,0,plaster,if city=='Durakh' or city=='Arkheim' then Enum.Material.Slate else Enum.Material.Limestone)
  part('DoorSide',Vector3.new((w-8)/2,h,1),side*(w+8)/4,h/2,-d/2,plaster,Enum.Material.Limestone)
  part('DoorJamb',Vector3.new(0.65,10,1.6),side*4.35,5,-d/2,stone)
  for _,z in {-d/2,d/2} do
   part('CornerPier',Vector3.new(1.1,h+0.6,1.1),side*w/2,h/2,z,if city=='Durakh' or city=='Arkheim' then stone else wood,if city=='Durakh' or city=='Arkheim' then Enum.Material.Cobblestone else Enum.Material.Wood)
  end
  if side==1 then for _,y in {4,h-1}do
   -- Split front beams preserve the full doorway; back beams span the rear.
   for _,x in {-1,1}do part('TimberRail',Vector3.new((w-9)/2,0.55,0.8),x*(w+9)/4,y,-d/2-0.1,wood,Enum.Material.Wood,true)end
   part('RearRail',Vector3.new(w,0.55,0.8),0,y,d/2+0.1,wood,Enum.Material.Wood,true)
  end end
 end
 part('DoorLintel',Vector3.new(8,h-10,1),0,10+(h-10)/2,-d/2,wood,Enum.Material.Wood)
 part('StoneDoorCrown',Vector3.new(9,0.9,1.8),0,10.2,-d/2,stone,Enum.Material.Cobblestone,true)
 for i=1,3 do part('Step',Vector3.new(8,0.3*i,1.4),0,0.15*i,-d/2-4.1+i*1.2,stone)end
 local function window(x,y,z,sideFace)
  local rotation=if sideFace then CFrame.Angles(0,math.pi/2,0) else CFrame.new()
  local frame=cf*CFrame.new(x,y,z)*rotation
  local function trim(name,size,dx,dy,dz,color,mat)
   local p=G.detail(m,name,size,frame*CFrame.new(dx,dy,dz),color,mat);p.CastShadow=false;return p
  end
  trim('WindowRecess',Vector3.new(4.8,5.8,0.45),0,0,0,wood,Enum.Material.Wood)
  trim('WindowGlass',Vector3.new(3.8,4.8,0.25),0,0,-0.25,glass,Enum.Material.Glass)
  trim('WindowMullion',Vector3.new(0.25,5,0.35),0,0,-0.45,wood,Enum.Material.Wood)
  trim('WindowTransom',Vector3.new(4,0.25,0.35),0,0.4,-0.45,wood,Enum.Material.Wood)
  trim('WindowSill',Vector3.new(5.3,0.45,1),0,-2.9,-0.2,stone,Enum.Material.Cobblestone)
  if spec.Windows=='Lancet' then
   for _,side in {-1,1}do trim('LancetArch',Vector3.new(0.45,3,0.5),side*1.1,2.4,-0.5,stone,Enum.Material.Slate).CFrame=frame*CFrame.new(side*1.1,2.4,-0.5)*CFrame.Angles(0,0,side*0.55)end
  elseif spec.Windows=='Crystal' then
   trim('ArcaneKeystone',Vector3.new(0.8,1.5,0.7),0,3,-0.45,metal,Enum.Material.Metal)
  elseif spec.Variant%2==0 then
   for _,side in {-1,1}do trim('Shutter',Vector3.new(1.2,4.8,0.4),side*3,0,-0.25,roof,Enum.Material.WoodPlanks)end
  end
 end
 for _,side in {-1,1}do
  window(side*w*0.32,8,-d/2-0.5,false)
  if h>24 then window(side*w*0.3,h-7,-d/2-0.5,false)end
  window(side*(w/2+0.45),math.min(10,h-5),d*0.16,true)
 end
 local rise=spec.Rise;local half=w/2+2
 local slope=math.atan2(rise,half);local length=math.sqrt(half*half+rise*rise)
 for _,side in {-1,1}do
  part('PitchedRoof',Vector3.new(length,0.8,d+5),side*half/2,h+rise/2,0,roof,Enum.Material.Slate,false,CFrame.Angles(0,0,-side*slope))
  part('Eave',Vector3.new(0.6,0.8,d+6),side*half,h,0,wood,Enum.Material.Wood,true)
  for _,z in {-d/2,d/2}do beam('GableRafter',Vector3.new(side*half,h,z),Vector3.new(0,h+rise,z),0.65)end
 end
 for _,z in {-d/2,d/2}do
  for _,side in {-1,1}do
   local gable=Instance.new('WedgePart');gable.Name='GableInfill';gable.Size=Vector3.new(0.8,rise,w/2)
   gable.CFrame=cf*CFrame.new(side*w/4,h+rise/2,z)*CFrame.Angles(0,-side*math.pi/2,0)
   gable.Color=plaster;gable.Material=Enum.Material.Limestone;gable.Anchored=true
   gable.CanCollide=false;gable.CanQuery=false;gable.CanTouch=false;gable.CastShadow=false;gable.Parent=m
  end
  beam('KingPost',Vector3.new(0,h,z-0.4),Vector3.new(0,h+rise,z-0.4),0.55)
 end
 part('RidgeCap',Vector3.new(0.8,0.7,d+6),0,h+rise,0,metal,Enum.Material.Metal,true)
 if spec.Roof=='Dormer' or spec.Roof=='CrossGable' then
  local z=-d*0.18
  part('Dormer',Vector3.new(7,4,5),-w*0.24,h+3,z,plaster,Enum.Material.Limestone,true)
  for _,side in {-1,1}do part('DormerRoof',Vector3.new(4.7,0.65,6),-w*0.24+side*1.8,h+6,z,roof,Enum.Material.Slate,true,CFrame.Angles(0,0,-side*0.5))end
  part('DormerGlass',Vector3.new(3.2,2.3,0.4),-w*0.24,h+3,-d*0.18-2.6,glass,Enum.Material.Glass,true)
 end
 if not spec.Tower then
  part('ChimneyStack',Vector3.new(2.8,8,3.2),w*0.3,h+4,d*0.25,stone,Enum.Material.Brick)
  part('ChimneyCap',Vector3.new(3.7,0.7,4.1),w*0.3,h+8.2,d*0.25,metal,Enum.Material.Slate,true)
 end
 if kind=='Tavern' or kind=='LargeHouse' or kind=='GuildHall' then
  part('JettyFloor',Vector3.new(w+1.5,0.65,d+1.5),0,11,0,wood,Enum.Material.Wood,true)
  part('Balcony',Vector3.new(12,0.65,4.5),0,11.4,-d/2-1.8,wood,Enum.Material.WoodPlanks)
  for _,side in {-1,1}do part('BalconySide',Vector3.new(0.6,2.8,4),side*6,13,-d/2-1.7,wood,Enum.Material.Wood,true)end
  part('BalconyRail',Vector3.new(12,0.5,0.5),0,14.2,-d/2-3.8,wood,Enum.Material.Wood,true)
  for x=-5,5,2 do part('Baluster',Vector3.new(0.35,2.5,0.35),x,12.9,-d/2-3.8,wood,Enum.Material.Wood,true)end
 end
 if kind=='Castle' or kind=='Barracks' or spec.Tower then
  local towerH=if kind=='Castle' then h+17 elseif spec.Tower then h+5 else h+8
  for _,side in {-1,1}do
   local x=side*(w/2+3)
   part('Turret',Vector3.new(8,towerH,8),x,towerH/2,d/2-4,stone)
   part('TurretCornice',Vector3.new(9,1,9),x,towerH-2,d/2-4,metal,Enum.Material.Slate,true)
   for i=-1,1 do part('Battlement',Vector3.new(1.6,2.8,2),x+i*3,towerH+1,d/2-8,stone)end
   if theme.Id=='Gothic' or theme.Id=='Arcane' or spec.Tower then
    for _,roofSide in {-1,1}do part('SteepSpire',Vector3.new(7.8,0.8,10),x+roofSide*2.7,towerH+5,d/2-4,roof,Enum.Material.Slate,true,CFrame.Angles(0,0,-roofSide*1))end
    part('Finial',Vector3.new(0.6,6,0.6),x,towerH+12,d/2-4,metal,Enum.Material.Metal,true)
   end
   local banner=part('Banner',Vector3.new(3.2,8,0.2),x,towerH-8,d/2-8.2,roof,Enum.Material.Fabric,true);banner:SetAttribute('Flutter',true)
  end
 end
 if theme.Id=='Woodland' then
  for _,side in {-1,1}do
   beam('BranchBrace',Vector3.new(side*w/2,2,-d/2),Vector3.new(side*(w/2+2),h-3,-d/2),1.1)
   part('WindowPlanter',Vector3.new(5,1.2,2),side*w*0.32,4.2,-d/2-1.1,wood,Enum.Material.WoodPlanks,true)
   part('PlanterLeaves',Vector3.new(5,1.7,2),side*w*0.32,5.3,-d/2-1.1,roof,Enum.Material.Grass,true,nil,Enum.PartType.Ball)
  end
 elseif theme.Id=='Mountain' or theme.Id=='Gothic' then
  for _,side in {-1,1}do
   part('ButtressFoot',Vector3.new(3,3,4),side*(w/2+1),1.5,-d*0.28,stone)
   part('Buttress',Vector3.new(1.8,h*0.65,2),side*(w/2+0.7),h*0.325,-d*0.28,stone,Enum.Material.Slate)
  end
 elseif theme.Id=='Arcane' then
  for _,side in {-1,1}do local crystal=G.crystal(m,cf*CFrame.new(side*(w/2-2),h+rise+1,0),glass,0.7);crystal.CastShadow=false end
 end
 local role=Catalog.Roles[kind] or 'Citizen'
 if Catalog.Shops[role] or role=='Guild' then
  part('Counter',Vector3.new(9,2.8,2.8),-8,1.4,-d/2-5.8,wood,Enum.Material.WoodPlanks)
  part('Awning',Vector3.new(12,0.45,7),-8,8,-d/2-4.3,roof,Enum.Material.Fabric,true,CFrame.Angles(-0.12,0,0))
  for _,x in {-13,-3.8}do part('AwningPost',Vector3.new(0.5,8,0.5),x,4,-d/2-7.5,wood,Enum.Material.Wood)end
 end
 if kind=='Forge' or kind=='Blacksmith' or kind=='SmithGuild' then
  part('Furnace',Vector3.new(8,7,7),w/2-5,3.5,-d/2-5,stone,Enum.Material.Brick)
  part('Embers',Vector3.new(5,2,0.4),w/2-5,3,-d/2-8.7,Color3.fromRGB(234,123,55),Enum.Material.Neon,true)
  part('Anvil',Vector3.new(5,2,2),-w/2+5,3.8,-d/2-5,metal,Enum.Material.Metal)
 elseif kind=='Windmill' then
  for i=0,3 do part('MillSail',Vector3.new(2,15,0.5),0,h+6,-d/2-2,Color3.fromRGB(217,207,171),Enum.Material.Fabric,true,CFrame.Angles(0,0,i*math.pi/2)*CFrame.new(0,7,0))end
 elseif kind=='Library' then
  for i=1,4 do part('Bookshelf',Vector3.new(10,0.8,2),0,i*2,d/2-2,wood,Enum.Material.WoodPlanks);part('Books',Vector3.new(9,1.4,1.4),0,i*2+1,d/2-2,roof,Enum.Material.Fabric,true)end
 elseif kind=='Market' then
  for _,side in {-1,1}do part('MarketCrate',Vector3.new(3,2.5,3),side*8,1.3,-d/2-5,wood,Enum.Material.WoodPlanks)end
 end
 if spec.Interior then
  local furniture=G.model(m,'Interior')
  for _,item in Interiors.build(kind,w,d,h)do
   local tint=if item.Material=='Fabric' then roof elseif item.Material=='Neon' then glass else wood
   local p=G.part(furniture,item.Name,Vector3.new(table.unpack(item.Size)),cf*CFrame.new(table.unpack(item.Position)),tint,Enum.Material[item.Material])
   if not item.Collide then p.CanCollide=false;p.CanQuery=false;p.CastShadow=false end
  end
 end
 local sign=G.sign(m,Catalog.Labels[kind] or kind,cf*CFrame.new(0,12,-d/2-1),math.min(20,w));sign:SetAttribute('IntegrationRole',role)
 if spec.Interior then
  part('LanternBracket',Vector3.new(0.4,0.4,2),4.9,8,-d/2-0.7,metal,Enum.Material.Metal,true)
  part('LanternGlow',Vector3.new(0.9,1.4,0.9),4.9,7,-d/2-1.3,glass,Enum.Material.Neon,true)
 end
 return m,cf:PointToWorldSpace(Vector3.new(0,0,-d/2-8)),role
end
return B
