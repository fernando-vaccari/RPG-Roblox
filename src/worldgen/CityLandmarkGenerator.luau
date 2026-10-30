-- Civic silhouettes, built from native geometry only. No NPC or gameplay logic.
local G=require(script.Parent.Geometry)
local Plan=require(script.Parent.ArchitecturalPlan)
local L={}
local function rgb(c)return Color3.fromRGB(table.unpack(c))end
-- The capital's nave and bell towers establish a readable silhouette above the roofs.
-- All geometry is local; there are no external assets, loaders or gameplay triggers.
local function monumentalCivic(parent,city)
 local theme=Plan.Themes[city.Id] or Plan.Themes.Valoria
 local m=G.model(parent,'MonumentalCivic_'..city.Id)
 m:SetAttribute('LandmarkId',city.Id..'_MonumentalCivic');m:SetAttribute('IntegrationOnly',true)
 m:SetAttribute('ArchitecturalTheme',theme.Id)
 local stone,roof,metal=rgb(theme.Stone),rgb(theme.Roof),rgb(theme.Metal)
 local frame=CFrame.new(city.X-58,city.H,city.Z-60)
 local function p(name,size,x,y,z,color,material,detail,rot)
  return (if detail then G.detail else G.part)(m,name,size,frame*CFrame.new(x,y,z)*(rot or CFrame.new()),color or stone,material or Enum.Material.Limestone)
 end
 local function roofPair(name,width,depth,base,rise,x,z)
  local half=width/2;local angle=math.atan2(rise,half)
  for _,side in {-1,1}do
   p(name,Vector3.new(math.sqrt(half*half+rise*rise),1.4,depth),x+side*half/2,base+rise/2,z,roof,Enum.Material.Slate,false,CFrame.Angles(0,0,-side*angle))
   for _,endZ in {-depth/2,depth/2}do
    local g=Instance.new('WedgePart');g.Name=name..'Gable';g.Size=Vector3.new(0.8,rise,half)
    g.CFrame=frame*CFrame.new(x+side*half/2,base+rise/2,z+endZ)*CFrame.Angles(0,-side*math.pi/2,0)
    g.Anchored=true;g.Color=stone;g.Material=Enum.Material.Limestone;g.CanTouch=false;g.Parent=m
   end
  end
 end
 if city.Id=='Valoria' or city.Id=='Arkheim' then
  m:SetAttribute('LandmarkName',if city.Id=='Valoria' then 'Catedral da Coroa Solar' else 'Catedral dos Juramentos')
  local naveH=if city.Id=='Valoria' then 60 else 68
  p('NaveFoundation',Vector3.new(54,2,82),0,-0.6,0)
  p('NaveFloor',Vector3.new(50,0.6,78),0,0.3,0,stone,Enum.Material.Marble)
  p('ApseWall',Vector3.new(52,naveH,3),0,naveH/2,-39)
  for _,side in {-1,1}do
   p('NaveSide',Vector3.new(2,naveH,80),side*25,naveH/2,0)
   p('PortalPier',Vector3.new(17,naveH,3),side*17.5,naveH/2,39)
   p('PortalArchivolt',Vector3.new(11,3,5),side*4.5,23,39,stone,nil,false,CFrame.Angles(0,0,-side*0.5))
   for _,z in {-30,-10,10}do
    p('FlyingButtressFoot',Vector3.new(4,9,7),side*30,4.5,z)
    p('FlyingButtress',Vector3.new(3,39,5),side*29,24,z,stone,Enum.Material.Cobblestone)
    p('ButtressBrace',Vector3.new(2.5,16,4),side*27,48,z,stone,nil,false,CFrame.Angles(0,0,side*0.3))
    p('LancetWindow',Vector3.new(0.4,21,5),side*26.1,37,z,rgb(theme.Glass),Enum.Material.Glass,true)
    p('LancetMullion',Vector3.new(0.5,23,0.5),side*26.4,37,z,metal,Enum.Material.Metal,true)
    p('AisleColumn',Vector3.new(2,38,2),side*18,19,z)
   end
   local tx=side*23
   p('BellTower',Vector3.new(14,103,14),tx,51.5,29,stone,Enum.Material.Cobblestone)
   for _,y in {28,61,90,103}do p('TowerCornice',Vector3.new(16,1.5,16),tx,y,29,stone,Enum.Material.Limestone)end
   p('BellOpening',Vector3.new(5,13,0.4),tx,91,36.2,Color3.fromRGB(41,40,37),Enum.Material.Slate,true)
   for _,dx in {-5,5}do p('BelfryPier',Vector3.new(2,16,2),tx+dx,113,34,stone)end
   roofPair('BellSpire',19,19,120,34,tx,29)
   p('BellFinial',Vector3.new(1,8,1),tx,158,29,metal,Enum.Material.Metal,true)
  end
  p('PortalHeader',Vector3.new(18,naveH-25,3),0,25+(naveH-25)/2,39)
  p('RoseWindowRim',Vector3.new(1,16,16),0,44,41,metal,Enum.Material.Metal,true,CFrame.Angles(0,math.pi/2,0)).Shape=Enum.PartType.Cylinder
  p('RoseWindowGlass',Vector3.new(1.2,13.5,13.5),0,44,41.4,rgb(theme.Glass),Enum.Material.Glass,true,CFrame.Angles(0,math.pi/2,0)).Shape=Enum.PartType.Cylinder
  for i=0,5 do p('RoseTracery',Vector3.new(0.5,13,0.7),0,44,42.2,metal,Enum.Material.Metal,true,CFrame.Angles(0,0,i*math.pi/6))end
  roofPair('NaveRoof',58,86,naveH,28,0,0)
  p('CrossingTower',Vector3.new(16,31,18),0,naveH+35,-9)
  roofPair('CrossingSpire',22,23,naveH+51,56,0,-9)
  p('SunFinial',Vector3.new(1.3,13,1.3),0,naveH+113.5,-9,metal,Enum.Material.Metal,true)
  p('SunCrossbar',Vector3.new(8,1.1,1.1),0,naveH+115,-9,metal,Enum.Material.Metal,true)
  for _,side in {-1,1}do for z=-23,22,15 do
   p('NavePew',Vector3.new(12,2,3),side*12,1,z,rgb(theme.Wood),Enum.Material.WoodPlanks)
  end end
  p('Altar',Vector3.new(14,3,6),0,1.5,-29,stone,Enum.Material.Marble)
 else
  -- Each secondary city's high landmark is distinct, sharing only a reserved footprint.
  local height=if city.Id=='Durakh' then 112 elseif city.Id=='Asterion' then 154 else 125
  m:SetAttribute('LandmarkName',if city.Id=='Durakh' then 'Bastião das Sete Forjas' elseif city.Id=='Asterion' then 'Observatório das Sete Estrelas' else 'Grande Árvore da Aliança')
  if city.Id=='Eldoria' then
   p('AncientTrunk',Vector3.new(14,height,14),0,height/2,0,rgb(theme.Wood),Enum.Material.Wood)
   for i=1,7 do
    local a=i*2.399;local x,z=math.sin(a)*23,math.cos(a)*24
    G.beam(m,frame:PointToWorldSpace(Vector3.new(0,height*0.5,0)),frame:PointToWorldSpace(Vector3.new(x,height*0.81+(i%3)*8,z)),4,rgb(theme.Wood),Enum.Material.Wood)
    local crown=p('AncientCanopy',Vector3.new(35,24,37),x,height*0.83+(i%3)*8,z,roof,Enum.Material.Grass,true);crown.Shape=Enum.PartType.Ball
   end
   p('RootHallDeck',Vector3.new(40,2,38),0,8,0,rgb(theme.Wood),Enum.Material.WoodPlanks)
   for i=1,8 do p('RootHallStep',Vector3.new(12,i,3),0,i/2,43-i*3,stone)end
  else
   p('CitadelFooting',Vector3.new(50,3,64),0,0,0)
   p('HighKeep',Vector3.new(32,height-30,40),0,(height-30)/2,0,stone,if city.Id=='Asterion' then Enum.Material.Marble else Enum.Material.Cobblestone)
   for _,side in {-1,1}do
    p('CitadelPier',Vector3.new(7,height,8),side*22,height/2,17)
    for _,z in {-26,26}do p('KeepButtress',Vector3.new(7,height*0.72,7),side*19,height*0.36,z)end
    for y=24,height-30,24 do p('KeepWindow',Vector3.new(3,10,0.5),side*10,y,20.3,rgb(theme.Glass),Enum.Material.Glass,true)end
   end
   for y=24,height-20,24 do p('KeepCornice',Vector3.new(37,2,45),0,y,0,metal,Enum.Material.Slate)end
   if city.Id=='Asterion' then
    roofPair('ObservatorySpire',42,48,height-30,48,0,0)
    p('StarFinial',Vector3.new(2,10,2),0,height+24,0,metal,Enum.Material.Metal,true)
   else
    p('BastionParapet',Vector3.new(37,6,45),0,height-27,0)
    for x=-16,16,8 do p('BastionMerlon',Vector3.new(4,6,6),x,height-21,22,stone)end
    roofPair('ForgeHallRoof',36,44,height-24,18,0,0)
   end
  end
 end
 return m
end

-- Continuous high ramparts are cut at real route crossings and four radial avenues.
-- Gate passages remain open at ground level. Metadata makes clearances testable.
function L.fortifications(parent,city,config)
 local theme=Plan.Themes[city.Id] or Plan.Themes.Valoria
 local terrain=require(script.Parent.TerrainMath)
 local stone=rgb(theme.Stone);local trim=Color3.fromRGB(math.min(255,theme.Stone[1]+22),math.min(255,theme.Stone[2]+20),math.min(255,theme.Stone[3]+18))
 local all=G.model(parent,'MonumentalFortifications');all:SetAttribute('IntegrationOnly',true)
 local radius=city.Radius-6
 local heights={Valoria=104,Arkheim=96,Eldoria=80,Durakh=92,Asterion=88}
 local routes=terrain.roadPaths(config)
 local function ring(name,r,h)
  local model=G.model(all,name);model:SetAttribute('Radius',r);model:SetAttribute('WallHeight',h)
  -- Reserve the full road corridor across the wall band. Nearby crossings
  -- merge into one wider gate instead of discarding one crossing's position.
  local intervals={}
  local function reserve(a,halfWidth)
   a=(a+math.pi*2)%(math.pi*2)
   table.insert(intervals,{Lo=a-halfWidth/r,Hi=a+halfWidth/r})
  end
  for i=0,3 do reserve(i*math.pi/2,24)end
  for _,route in routes do
   for i=2,#route.Points do
    local a,b=route.Points[i-1],route.Points[i]
    local ax,az=a.X-city.X,a.Z-city.Z;local dx,dz=b.X-a.X,b.Z-a.Z
    local aa=dx*dx+dz*dz
    if aa==0 then continue end
    for _,band in {-40,0,40}do
     local rr=r+band
     local bb=2*(ax*dx+az*dz);local cc=ax*ax+az*az-rr*rr
     local det=bb*bb-4*aa*cc
     if det>=0 then for _,t in {(-bb-math.sqrt(det))/(2*aa),(-bb+math.sqrt(det))/(2*aa)}do
      if t>=0 and t<=1 then reserve(math.atan2(ax+t*dx,az+t*dz),(route.Width or 20)/2+14)end
     end end
    end
   end
  end
  table.sort(intervals,function(a,b)return a.Lo<b.Lo end)
  local merged={}
  for _,interval in intervals do
   local last=merged[#merged]
   if last and (interval.Lo-last.Hi)*r<64 then last.Hi=math.max(last.Hi,interval.Hi)
   else table.insert(merged,{Lo=interval.Lo,Hi=interval.Hi})end
  end
  if #merged>1 and (merged[1].Lo+math.pi*2-merged[#merged].Hi)*r<64 then
   merged[1].Lo=merged[#merged].Lo-math.pi*2
   table.remove(merged)
  end
  local gates={}
  for _,interval in merged do
   local angle=(interval.Lo+interval.Hi)/2
   local halfArc=(interval.Hi-interval.Lo)*r/2
   table.insert(gates,{Angle=angle,Half=math.max(24,halfArc+2),South=interval.Lo<=0 and interval.Hi>=0})
  end
  table.sort(gates,function(a,b)return a.Angle<b.Angle end)
  local panels={}
  for index,g in gates do
   local nextGate=gates[index%#gates+1]
   local last=nextGate.Angle+(if index==#gates then math.pi*2 else 0)
   local start,finish=g.Angle+(g.Half+26)/r,last-(nextGate.Half+26)/r
   if finish>start then
    local n=math.ceil((finish-start)*r/32)
    for j=1,n do
     local da=(finish-start)/n
     table.insert(panels,{Angle=start+(j-0.5)*da,Width=2*r*math.sin(da/2),Radius=r*math.cos(da/2)})
    end
   end
  end
  local function frame(a,y)return CFrame.new(city.X+math.sin(a)*r,city.H+y,city.Z+math.cos(a)*r)*CFrame.Angles(0,a,0)end
  local function piece(name,size,cf,color,detail)
   local p=(if detail then G.detail else G.part)(model,name,size,cf,color or stone,Enum.Material.Limestone)
   if detail then p.CastShadow=false end
   return p
  end
  for i,panel in panels do
   local a,chord=panel.Angle,panel.Width
   do
    local cf=CFrame.new(city.X+math.sin(a)*panel.Radius,city.H,city.Z+math.cos(a)*panel.Radius)*CFrame.Angles(0,a,0)
    piece('RampartPanel',Vector3.new(chord+1,h,14),cf*CFrame.new(0,h/2,0))
    piece('WallFooting',Vector3.new(chord+1,6,19),cf*CFrame.new(0,2,0),trim)
    piece('WallCornice',Vector3.new(chord+1,2,18),cf*CFrame.new(0,h-3,0),trim)
    piece('WallWalk',Vector3.new(chord+1,1.5,20),cf*CFrame.new(0,h,0),trim)
    piece('OuterParapet',Vector3.new(chord+1,3,2),cf*CFrame.new(0,h+2,8),stone)
    piece('InnerParapet',Vector3.new(chord+1,3,1.6),cf*CFrame.new(0,h+2,-8),stone)
    piece('WallButtress',Vector3.new(3.5,h+4,5),cf*CFrame.new(chord/2,h/2+1,8),trim)
    for _,x in {-chord/3,0,chord/3}do piece('Crenellation',Vector3.new(4,3.5,3),cf*CFrame.new(x,h+5.1,8),stone)end
    if i%4==0 then
     piece('WatchTurret',Vector3.new(16,h+15,22),cf*CFrame.new(0,(h+15)/2,6),stone)
     piece('WatchCrown',Vector3.new(19,2,25),cf*CFrame.new(0,h+15,6),trim)
     for _,side in {-1,1}do piece('WatchMerlon',Vector3.new(4,5,5),cf*CFrame.new(side*7,h+18,16),stone)end
     piece('ArrowSlit',Vector3.new(1.2,7,0.3),cf*CFrame.new(0,h-9,17.15),Color3.fromRGB(44,43,40),true)
    end
   end
  end
  for index,g in gates do
   local a,half=g.Angle,g.Half
   local gate=G.model(model,'Gate_'..index);gate:SetAttribute('OpeningWidth',half*2);gate:SetAttribute('OpeningHeight',30)
   gate:SetAttribute('GateAngle',a);gate:SetAttribute('Radius',r)
   local cf=frame(a,0)
   local function p(name,size,x,y,z,color,detail,rot)
    return (if detail then G.detail else G.part)(gate,name,size,cf*CFrame.new(x,y,z)*(rot or CFrame.new()),color or stone,Enum.Material.Limestone)
   end
   for _,side in {-1,1}do
    p('GateTower',Vector3.new(26,h+14,28),side*(half+13),(h+14)/2,0)
    p('GateTowerFoot',Vector3.new(28,6,31),side*(half+14),3,0,trim)
    for _,y in {h*0.4,h*0.7,h+14}do p('GateCornice',Vector3.new(29,2,31),side*(half+13),y,0,trim)end
    p('GateArchHaunch',Vector3.new(16,6,22),side*(half-7),37,0,trim,false,CFrame.Angles(0,0,side*0.42))
    p('RaisedPortcullisRail',Vector3.new(1.5,16,1),side*(half-4),49,10,Color3.fromRGB(70,65,58),true)
    p('GateBanner',Vector3.new(8,23,0.4),side*(half+13),h-10,14.3,rgb(theme.Roof),true)
    for _,x in {-8,0,8}do p('GateMerlon',Vector3.new(4,5,4),side*(half+13)+x,h+18,14,stone)end
   end
   p('GateLintel',Vector3.new(half*2+3,h-39,24),0,39+(h-39)/2,0,stone)
   p('GateKeystone',Vector3.new(10,7,26),0,40,0,trim)
   p('GateWalk',Vector3.new(half*2+54,2,28),0,h+1,0,trim)
   -- Stair access runs tangentially inside the outer south gate; lanes reserve this strip.
   if g.South and name=='OuterRing' then
    local cf=frame(0,0) -- fixed authored stair reserve beside the south avenue
    local steps=math.ceil(h);local flights=4;local per=math.ceil(steps/flights)
    local stair=G.model(gate,'RampartStair')
    for step=1,steps do
     local flight=math.floor((step-1)/per);local n=(step-1)%per
     local x=if flight%2==0 then -90+n*2 else -90+(per-1-n)*2
     local z=-25-flight*9
     G.part(stair,'StairTread',Vector3.new(2.2,1.1,8),cf*CFrame.new(x,step-0.5,z),stone,Enum.Material.Cobblestone)
     if n==per-1 or step==steps then G.part(stair,'StairLanding',Vector3.new(8,1,17),cf*CFrame.new(x,step,z-4.5),trim,Enum.Material.Cobblestone)end
    end
    local endX=if (flights-1)%2==0 then -90+(per-1)*2 else -90
    G.part(stair,'AccessBridge',Vector3.new(8,1,48),cf*CFrame.new(endX,h,-30),trim,Enum.Material.Cobblestone)
   end
  end
  return model
 end
 ring('OuterRing',radius,heights[city.Id] or 88)
 if city.Id=='Valoria' then ring('InnerRing',city.InnerWallRadius or 330,66)end
 return all
end

function L.build(parent,city,_config)
 if _config.MonumentalMap then
  local ancestor=parent
  while ancestor do
   if ancestor:GetAttribute("SceneOnly")==true then return monumentalCivic(parent,city)end
   ancestor=ancestor.Parent
  end
 end
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
