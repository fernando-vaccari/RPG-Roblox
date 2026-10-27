-- Civic silhouettes, built from native geometry only. No NPC or gameplay logic.
local G=require(script.Parent.Geometry)
local Plan=require(script.Parent.ArchitecturalPlan)
local L={}
local function rgb(c)return Color3.fromRGB(table.unpack(c))end
function L.build(parent,city,_config)
 local theme=Plan.Themes[city.Id] or Plan.Themes.Valoria
 local m=G.model(parent,'Civic_'..theme.Id);m:SetAttribute('ArchitecturalTheme',theme.Id)
 m:SetAttribute('LandmarkId',city.Id..'_Civic');m:SetAttribute('IntegrationOnly',true)
 local cf=CFrame.new(city.X-(if city.Id=='Eldoria' then 32 else 43),city.H,city.Z-(if city.Id=='Eldoria' then 18 else 27))
 local stone,wood,roof,metal,glass=rgb(theme.Stone),rgb(theme.Wood),rgb(theme.Roof),rgb(theme.Metal),rgb(theme.Glass)
 local function p(name,size,x,y,z,color,mat,detail,rotation,shape)
  local part=(if detail then G.detail else G.part)(m,name,size,cf*CFrame.new(x,y,z)*(rotation or CFrame.new()),color or stone,mat or Enum.Material.Cobblestone,shape)
  if detail then part.CastShadow=false end
  return part
 end
 local function beam(name,a,b,width,color)
  local part=G.beam(m,cf:PointToWorldSpace(a),cf:PointToWorldSpace(b),width,color or wood,Enum.Material.Wood)
  part.Name=name;return part
 end
 if city.Id=='Valoria' then
  m:SetAttribute('LandmarkName','Torre das Horas da Aurora')
  p('ClockFoundation',Vector3.new(16,2,16),0,0,0)
  p('ClockBase',Vector3.new(12,18,12),0,10,0)
  p('ClockShaft',Vector3.new(9,26,9),0,30,0,rgb(theme.Plaster),Enum.Material.Limestone)
  for _,side in {-1,1}do
   p('ClockCorner',Vector3.new(1,43,1),side*4.5,22,-4.5,wood,Enum.Material.Wood)
   p('BellPillar',Vector3.new(1.2,9,1.2),side*4.5,47,-4.5,wood,Enum.Material.Wood)
   p('BellPillar',Vector3.new(1.2,9,1.2),side*4.5,47,4.5,wood,Enum.Material.Wood)
   p('ClockRoof',Vector3.new(8.4,0.8,14),side*3.2,55,0,roof,Enum.Material.Slate,true,CFrame.Angles(0,0,-side*0.75))
  end
  p('BelfryFloor',Vector3.new(12,1,12),0,43,0,wood,Enum.Material.WoodPlanks)
  p('Bell',Vector3.new(3,3.4,3),0,47,0,metal,Enum.Material.Metal,true,nil,Enum.PartType.Ball)
  p('ClockFace',Vector3.new(0.4,6,6),0,34,-4.85,rgb(theme.Plaster),Enum.Material.Limestone,true,CFrame.Angles(0,math.pi/2,0),Enum.PartType.Cylinder)
  for i=1,12 do
   local a=i/12*math.pi*2
   p('ClockTick',Vector3.new(0.3,0.65,0.15),math.sin(a)*2.5,34+math.cos(a)*2.5,-5.2,metal,Enum.Material.Metal,true,CFrame.Angles(0,0,-a))
  end
  p('HourHand',Vector3.new(1.8,0.25,0.15),-0.6,34.4,-5.3,wood,Enum.Material.Wood,true,CFrame.Angles(0,0,-0.5))
  p('MinuteHand',Vector3.new(0.22,2.3,0.15),0,35,-5.3,wood,Enum.Material.Wood,true)
  p('ClockFinial',Vector3.new(0.7,6,0.7),0,61,0,metal,Enum.Material.Metal,true)
 elseif city.Id=='Eldoria' then
  m:SetAttribute('LandmarkName','Árvore do Primeiro Pacto')
  p('ElderTrunk',Vector3.new(6,39,6),0,19.5,0,wood,Enum.Material.Wood,false,CFrame.Angles(0,0,0.1))
  for i=1,5 do
   local a=i/5*math.pi*2
   local x,z=math.sin(a)*12,math.cos(a)*12
   beam('Root',Vector3.new(0,9,0),Vector3.new(x,0.5,z),1.7,wood)
   beam('ElderBranch',Vector3.new(0,23,0),Vector3.new(x,35+i,z),1.8,wood)
   p('ElderCrown',Vector3.new(18,14,18),x*0.6,36+i,z*0.6,roof,Enum.Material.Grass,true,nil,Enum.PartType.Ball)
  end
  for _,side in {-1,1}do
   p('RootBridgeDeck',Vector3.new(4,0.7,20),side*10,4,0,wood,Enum.Material.WoodPlanks)
   for _,z in {-9,0,9}do p('RootBridgePost',Vector3.new(0.6,4,0.6),side*12,6,z,wood,Enum.Material.Wood)end
   beam('WovenRail',Vector3.new(side*12,7,-9),Vector3.new(side*12,7,9),0.5,wood)
   for n=1,4 do p('BridgeStep',Vector3.new(4,0.9*n,2),side*10,0.45*n,-19+n*2,stone)end
  end
 elseif city.Id=='Durakh' then
  m:SetAttribute('LandmarkName','Galeria dos Mestres da Pedra')
  for _,x in {-9,9}do
   p('StoneAbutment',Vector3.new(5,9,13),x,4.5,0)
   p('GalleryPier',Vector3.new(3,17,3),x,8.5,5)
  end
  p('GalleryBridge',Vector3.new(23,1.2,11),0,10,0,stone,Enum.Material.Slate)
  for _,z in {-5,5}do
   p('GalleryParapet',Vector3.new(23,2.5,0.8),0,11.8,z)
   for x=-9,9,6 do p('GalleryMerlon',Vector3.new(2,1.2,1.2),x,13.5,z)end
  end
  for n=1,10 do p('GalleryStair',Vector3.new(7,n,1.5),0,n/2,-20+n*1.5,stone,Enum.Material.Slate)end
  p('ForgeChimney',Vector3.new(6,41,6),9,20.5,5,stone,Enum.Material.Brick)
  p('ChimneyCrown',Vector3.new(8,2,8),9,42,5,metal,Enum.Material.Metal)
  for _,x in {-9,9}do p('MineralVein',Vector3.new(1,6,0.3),x,5,-6.7,metal,Enum.Material.Metal,true)end
 elseif city.Id=='Asterion' then
  m:SetAttribute('LandmarkName','Obelisco das Constelações')
  p('RunicDais',Vector3.new(17,2,17),0,0,0,stone,Enum.Material.Marble)
  p('ArcaneShaft',Vector3.new(6,37,6),0,19.5,0,stone,Enum.Material.Marble)
  for _,side in {-1,1}do
   p('ArcaneRib',Vector3.new(0.6,38,0.6),side*3.1,20,-3.1,metal,Enum.Material.Metal,true)
   p('ObeliskCrown',Vector3.new(7.7,0.7,9),side*2.3,43,0,roof,Enum.Material.Slate,true,CFrame.Angles(0,0,-side*0.9))
   G.crystal(m,cf*CFrame.new(side*7,4,0),glass,0.9)
  end
  for i=1,6 do
   p('ConstellationRune',Vector3.new(1,0.5,0.3),if i%2==0 then -0.6 else 0.6,8+i*4,-3.2,glass,Enum.Material.Neon,true,CFrame.Angles(0,0,0.5))
  end
  p('FloatingCrystal',Vector3.new(3,8,3),0,51,0,glass,Enum.Material.Neon,true,CFrame.Angles(0,0,0.35))
 else
  m:SetAttribute('LandmarkName','Campanário do Juramento Partido')
  p('GothicBase',Vector3.new(15,4,15),0,1,0)
  p('GothicTower',Vector3.new(10,33,10),0,19.5,0,stone,Enum.Material.Slate)
  for _,side in {-1,1}do
   p('GothicButtress',Vector3.new(2.5,24,3),side*6,12,-2,stone,Enum.Material.Cobblestone)
   p('BelfryPier',Vector3.new(1.6,10,1.6),side*4,41,-4,stone,Enum.Material.Slate)
   p('GothicRoof',Vector3.new(11,0.8,14),side*3,50,0,roof,Enum.Material.Slate,true,CFrame.Angles(0,0,-side*1))
   p('GothicPinnacle',Vector3.new(1,12,1),side*6,39,-2,metal,Enum.Material.Metal,true)
  end
  p('BrokenBell',Vector3.new(4,3,3),1,4,-5,metal,Enum.Material.Metal,true,CFrame.Angles(0.2,0,0.7),Enum.PartType.Ball)
  p('LancetGlow',Vector3.new(2.5,12,0.3),0,24,-5.2,glass,Enum.Material.Glass,true)
  for _,side in {-1,1}do p('LancetRib',Vector3.new(0.45,4,0.6),side*0.8,31,-5.4,stone,Enum.Material.Slate,true,CFrame.Angles(0,0,side*0.5))end
 end
 return m
end
return L
