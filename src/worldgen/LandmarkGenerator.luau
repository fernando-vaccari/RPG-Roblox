local G=require(script.Parent.Geometry)
local L={}
local function sceneOnly(node)
 while node and node~=workspace do
  if node:GetAttribute('SceneOnly')==true then return true end
  node=node.Parent
 end
 return false
end
function L.city(parent,city,config,Content)
 local cf=CFrame.new(city.X,city.H,city.Z)
 local tint=if city.Id=='Eldoria' then Color3.fromRGB(92,154,108) elseif city.Id=='Asterion' then Color3.fromRGB(135,153,217) else G.Palette.Gold
 -- A furnished civic square with clear north/south and east/west crossing lanes.
 for _,side in {-1,1} do
  for _,z in {-23,23} do
   G.part(parent,'GardenBorder',Vector3.new(14,1.3,7),cf*CFrame.new(side*20,0.8,z),G.Palette.Stone,Enum.Material.Cobblestone)
   G.detail(parent,'FlowerBed',Vector3.new(12,0.8,5),cf*CFrame.new(side*20,1.8,z),Color3.fromRGB(71,123,76),Enum.Material.Grass)
   for i=1,3 do G.detail(parent,'Flower',Vector3.new(1.5,1,1.5),cf*CFrame.new(side*20+i*3-6,2.3,z),tint,Enum.Material.SmoothPlastic,Enum.PartType.Ball) end
  end
  G.part(parent,'PublicBench',Vector3.new(10,0.7,3),cf*CFrame.new(side*20,2,12),G.Palette.Wood,Enum.Material.WoodPlanks)
  for _,x in {-4,4} do G.part(parent,'BenchLeg',Vector3.new(0.7,2,2),cf*CFrame.new(side*20+x,1,12),G.Palette.Wood,Enum.Material.Wood) end
 end
 if city.Id=='Eldoria' then
  for _,x in {-48,48} do Content.tree(parent,{X=city.X+x,H=city.H,Z=city.Z+25,Scale=1.6,Variant=2,Forest='Sylvarin'}) end
 elseif city.Id=='Asterion' then
  for _,x in {-48,48} do
   G.part(parent,'CelestialObelisk',Vector3.new(5,24,5),cf*CFrame.new(x,12,28),G.Palette.Stone,Enum.Material.Marble)
   G.crystal(parent,cf*CFrame.new(x,28,28),tint,1.4)
  end
 elseif city.Id=='Durakh' then
  G.part(parent,'CaravanBed',Vector3.new(12,2,6),cf*CFrame.new(46,3,25),G.Palette.Wood,Enum.Material.WoodPlanks)
  for _,x in {42,50} do for _,z in {21,29} do G.part(parent,'CartWheel',Vector3.new(1,4,4),CFrame.new(city.X+x,city.H+2,city.Z+z),G.Palette.Wood,Enum.Material.Wood,Enum.PartType.Cylinder) end end
 end
 local cityConfig;for _,c in config.Cities do if c.Id==city.Id then cityConfig=c end end
 -- Short porch walks follow each facade; city streets are authored in the plan.
 for _,lot in city.Lots do
  if lot.External then continue end
  local frame=CFrame.new(lot.X,lot.H+0.3,lot.Z)*CFrame.Angles(0,lot.Yaw,0)
  local a=frame:PointToWorldSpace(Vector3.new(0,0,-23))
  local b=if lot.StreetX and lot.StreetZ then Vector3.new(lot.StreetX,lot.H+0.3,lot.StreetZ) else frame:PointToWorldSpace(Vector3.new(0,0,-36))
  if (b-a).Magnitude>0.5 then G.detail(parent,'Footpath',Vector3.new(6,0.2,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),Color3.fromRGB(142,138,122),Enum.Material.Cobblestone) end
 end
 for _,street in city.Streets or {} do
  local a=Vector3.new(street.A.X,city.H+0.28,street.A.Z);local b=Vector3.new(street.B.X,city.H+0.28,street.B.Z)
  G.detail(parent,'DistrictStreet',Vector3.new(street.Width or 12,0.25,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),Color3.fromRGB(139,137,123),Enum.Material.Cobblestone)
 end
 if cityConfig and city.Id=='Arkheim' then G.sign(parent,'O BASTIÃO RESISTE',cf*CFrame.new(0,9,cityConfig.Radius-22),26) end
end
function L.camp(root,c,Content,parent)
 local p=c.Guild;local cf=CFrame.new(p.X,p.Height,p.Z)
 G.part(parent,'GuildCamp',Vector3.new(150,0.5,130),cf,Color3.fromRGB(148,136,112),Enum.Material.Cobblestone)
 G.sign(parent,if sceneOnly(root) then 'GUILDA DOS AVENTUREIROS' else 'GUILDA • TREINO • RANK F',cf*CFrame.new(0,8,-56),30)
 if not sceneOnly(root) then
  local marker=Content.enemyMarker(root.EnemySpawns,'Valoria_Training',Vector3.new(p.X-35,p.Height+1,p.Z),'Training')
  marker:SetAttribute('Training',true)
  G.sign(parent,'ESPERE O AVISO • APARE COM F',cf*CFrame.new(-35,9,13),26)
 else
  G.sign(parent,'PÁTIO DE TREINAMENTO',cf*CFrame.new(-35,7,22),25)
  for _,side in {-1,1} do
   G.part(parent,'PracticePost',Vector3.new(2,6,2),cf*CFrame.new(-35+side*10,3,0),G.Palette.Wood,Enum.Material.Wood)
   G.part(parent,'PracticeArms',Vector3.new(7,0.7,0.7),cf*CFrame.new(-35+side*10,5,0),G.Palette.Wood,Enum.Material.Wood)
  end
 end
 for _,side in {-1,1} do G.torch(parent,cf*CFrame.new(side*65,3,-40),true) end
end
function L.defenses(root,c,Content,parent,city)
 do
  if city.Id~='Valoria' and city.Id~='Arkheim' then return end
  local z=city.Z-(city.Radius+60);local x=city.X+75
  local terrain=require(script.Parent.TerrainMath);local h=terrain.height(c,x,z)
  G.sign(parent,'FRONTEIRA • DEFENDA OS SINOS',CFrame.new(x,h+8,z),30)
  for i=1,5 do
   local px,pz=x+(i-3)*12,z+12
   local marker=Content.enemyMarker(root.EnemySpawns,city.Id..'_Defense_'..i,Vector3.new(px,terrain.height(c,px,pz),pz),'Demon')
   marker:SetAttribute('DefenseCity',city.Id);marker:SetAttribute('Enabled',false);marker:SetAttribute('Once',true)
  end
 end
end
function L.waterfall(root,c,terrain)
 local lake=c.Lake;if not lake then return end
 local p=Vector3.new(lake.X+lake.Radius-20,lake.WaterY,lake.Z)
 local m=G.model(root,'CascadeOfMemories')
 for _,side in {-1,1} do
  local bed=terrain.height(c,p.X+12,p.Z+side*13)
  local height=lake.WaterY+27-bed
  G.part(m,'CascadeRock',Vector3.new(16,height,22),CFrame.new(p.X+12,bed+height/2,p.Z+side*13),G.Palette.Stone,Enum.Material.Rock)
 end
 G.part(m,'UpperBasin',Vector3.new(22,3,20),CFrame.new(p+Vector3.new(12,25,0)),G.Palette.Stone,Enum.Material.Rock)
 local upper=G.detail(m,'UpperWater',Vector3.new(22,0.3,12),CFrame.new(p+Vector3.new(12,26.6,0)),Color3.fromRGB(137,200,210),Enum.Material.Glass);upper.Transparency=0.3
 local sheet=G.detail(m,'Waterfall',Vector3.new(0.7,28,11),CFrame.new(p+Vector3.new(1,13,0)),Color3.fromRGB(137,200,210),Enum.Material.Glass)
 sheet.Transparency=0.35
 for i=1,5 do G.detail(m,'Foam',Vector3.new(7,0.4,3),CFrame.new(p+Vector3.new(-i*3,0.2,i%2*3-2)),Color3.fromRGB(224,242,239),Enum.Material.SmoothPlastic,Enum.PartType.Ball) end
 local shoreX=lake.X-lake.Radius-lake.Bank-12
 if not sceneOnly(root) then
  local objective=G.marker(m,'LakeDiscovery',Vector3.new(shoreX,terrain.height(c,shoreX,lake.Z)+3,lake.Z),{Objective='LakeDiscovery'})
  objective.Transparency=0;G.prompt(objective,'Recordar','Lago das Memórias')
 else
  G.marker(m,'LakeDiscovery',Vector3.new(shoreX,terrain.height(c,shoreX,lake.Z)+3,lake.Z),{IntegrationId='LakeDiscovery',IntegrationKind='Discovery'})
 end
end
return L
