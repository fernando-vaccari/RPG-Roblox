-- Native geometry only. Builds off-scene; caller owns commit/backup/rollback.
local F={}
local function build(rig,style,folder)
 local count=0
 local color=function(rgb)return Color3.fromRGB(table.unpack(rgb))end
 local palette={Skin=color(style.Skin),Hair=color(style.HairColor),Eyes=color(style.Eyes),Cloth=color(style.Cloth),Accent=color(style.Accent),Metal=color(style.Metal),Leather=color(style.Leather),Linen=color(style.Linen),Dark=Color3.fromRGB(29,28,33),White=Color3.fromRGB(246,240,220)}
 local function part(name,body,size,offset,tone,material,shape,rotation,detail)
  local p=if shape=='Wedge' then Instance.new('WedgePart') else Instance.new('Part')
  p.Name=name;p.Size=Vector3.new(table.unpack(size));p.CFrame=rig.Bodies[body].CFrame*CFrame.new(table.unpack(offset))*(rotation or CFrame.new())
  p.Color=palette[tone];p.Material=material or Enum.Material.Fabric
  if shape and shape~='Wedge' then p.Shape=if shape=='Ball' then Enum.PartType.Ball else Enum.PartType.Cylinder end
  p.Anchored=false;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Massless=true;p.CastShadow=false
  p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
  p:SetAttribute('NPCVisualOwner',2);p:SetAttribute('VisualDetail',detail or 1);p:SetAttribute('VisualBody',body);p.Parent=folder
  local weld=Instance.new('WeldConstraint');weld.Name='VisualWeld';weld.Part0=rig.Bodies[body];weld.Part1=p;weld.Parent=p
  count+=1;return p
 end
 local function plate(name,body,size,offset,tone,rotation,detail)return part(name,body,size,offset,tone,Enum.Material.Metal,'Ball',rotation,detail)end
 local function trim(name,body,size,offset,tone,rotation)return part(name,body,size,offset,tone,Enum.Material.Metal,nil,rotation,2)end
 local function disc(name,body,diameter,offset,tone,depth)
  return part(name,body,{depth or .07,diameter,diameter},offset,tone,Enum.Material.Metal,'Cylinder',CFrame.Angles(0,math.pi/2,0),2)
 end
 -- Expressive original face: layered eyes, iris, catchlight, eyelids, brows and smile.
 for _,side in {-1,1}do
  part('Ear'..side,'Head',{.25,.38,.27},{side*.68,-.03,.03},'Skin',Enum.Material.SmoothPlastic,'Ball')
  part('EyeWhite'..side,'Head',{.28,.36,.065},{side*.27,.045,-.555},'White',Enum.Material.SmoothPlastic,'Ball')
  part('Iris'..side,'Head',{.13,.26,.042},{side*.27,.035,-.594},'Eyes',Enum.Material.SmoothPlastic,'Ball',nil,2)
  part('Pupil'..side,'Head',{.057,.18,.025},{side*.27,.035,-.618},'Dark',Enum.Material.SmoothPlastic,'Ball',nil,2)
  part('Catchlight'..side,'Head',{.045,.06,.02},{side*.27-.025,.105,-.635},'White',Enum.Material.SmoothPlastic,'Ball',nil,2)
  part('UpperLid'..side,'Head',{.30,.055,.07},{side*.27,.215,-.556},'Hair',Enum.Material.SmoothPlastic,nil,CFrame.Angles(0,0,side*.10),2)
  part('Brow'..side,'Head',{.29,.05,.06},{side*.27,.31,-.525},'Hair',Enum.Material.SmoothPlastic,nil,CFrame.Angles(0,0,-side*.10),2)
 end
 part('Nose','Head',{.12,.17,.13},{0,-.065,-.58},'Skin',Enum.Material.SmoothPlastic,'Ball',nil,2)
 part('Smile','Head',{.20,.028,.035},{0,-.29,-.526},'Leather',Enum.Material.SmoothPlastic,nil,nil,2)
 for _,s in {-1,1}do part('SmileCorner'..s,'Head',{.075,.025,.035},{s*.123,-.275,-.52},'Leather',Enum.Material.SmoothPlastic,nil,CFrame.Angles(0,0,s*.30),2)end
 -- Curved cap, swept wedge locks and rear layers instead of the V1 hair block.
 part('HairCrown','Head',{1.43,.65,1.19},{0,.48,.09},'Hair',Enum.Material.SmoothPlastic,'Ball')
 for i=1,7 do
  local x=(i-4)*.19;local len=.42+((i+style.Variant)%3)*.12
  part('Fringe'..i,'Head',{.20,len,.29},{x,.34-(i%2)*.06,-.48},'Hair',Enum.Material.SmoothPlastic,'Wedge',CFrame.Angles(0,0,math.pi-.25+x*.3)*CFrame.Angles(0,math.pi/2,0))
 end
 for _,s in {-1,1}do
  for i=1,3 do
   local length=if style.Hair=='Long' then .9+i*.12 elseif style.Hair=='Braided' then .7+i*.1 else .42+i*.12
   part('SideLock'..s..'_'..i,'Head',{.23,length,.32},{s*(.57+(i%2)*.055),.13-length*.18,.02+(i-2)*.22},'Hair',Enum.Material.SmoothPlastic,'Wedge',CFrame.Angles(0,0,math.pi-s*.16)*CFrame.Angles(0,math.pi/2,0))
  end
 end
 if style.Hair=='Braided' then
  for i=1,4 do part('Braid'..i,'Head',{.30,.32,.30},{.44,-.20-i*.23,.39},'Hair',Enum.Material.SmoothPlastic,'Ball',nil,2)end
  disc('BraidClasp','Head',.20,{.44,-1.18,.24},'Accent')
 elseif style.Hair=='Long' then
  for i=-1,1 do part('BackHair'..i,'Head',{.42,1.05,.32},{i*.38,-.12,.47},'Hair',Enum.Material.SmoothPlastic,'Wedge',CFrame.Angles(math.pi,0,i*.10))end
 end
 -- Tailored layers, collar, cuffs, boot wraps and buckles.
 part('Doublet','UpperTorso',{1.91,1.25,.20},{0,-.02,-.49},'Cloth',Enum.Material.Fabric,'Ball')
 for _,s in {-1,1}do
  part('Collar'..s,'UpperTorso',{.41,.41,.19},{s*.34,.57,-.43},'Linen',Enum.Material.Fabric,'Wedge',CFrame.Angles(0,0,s*.33))
  part('Lapel'..s,'UpperTorso',{.23,.91,.10},{s*.71,.03,-.62},'Leather',Enum.Material.SmoothPlastic,nil,CFrame.Angles(0,0,-s*.13))
  local side=if s==-1 then 'Left' else 'Right'
  part('Cuff'..side,side..'LowerArm',{.22,.66,.72},{0,-.34,0},'Leather',Enum.Material.SmoothPlastic,'Cylinder',CFrame.Angles(0,0,math.pi/2))
  part('CuffEdge'..side,side..'LowerArm',{.065,.68,.74},{0,-.28,0},'Accent',Enum.Material.Metal,'Cylinder',CFrame.Angles(0,0,math.pi/2),2)
  part('Boot'..side,side..'LowerLeg',{.61,.76,.81},{0,-.16,0},'Leather',Enum.Material.SmoothPlastic,'Cylinder',CFrame.Angles(0,0,math.pi/2))
  part('BootToe'..side,side..'Foot',{.88,.48,1.27},{0,0,-.03},'Leather',Enum.Material.SmoothPlastic,'Ball')
  for i=1,2 do part('BootStrap'..side..i,side..'LowerLeg',{.11,.80,.84},{0,.03-(i-1)*.23,0},'Dark',Enum.Material.SmoothPlastic,'Cylinder',CFrame.Angles(0,0,math.pi/2),2)end
  disc('BootClasp'..side,side..'LowerLeg',.14,{s*.21,.03,-.44},'Accent')
 end
 part('Belt','LowerTorso',{1.91,.23,1.01},{0,.08,0},'Leather',Enum.Material.SmoothPlastic)
 trim('Buckle','LowerTorso',{.29,.24,.10},{0,.08,-.58},'Accent')
 trim('BuckleInset','LowerTorso',{.17,.12,.11},{0,.08,-.60},'Dark')
 part('BeltPouch','LowerTorso',{.48,.55,.30},{.65,-.30,-.47},'Leather',Enum.Material.SmoothPlastic)
 disc('PouchClasp','LowerTorso',.12,{.65,-.20,-.64},'Accent')
 if style.Robe then
  -- Split skirts follow the legs: no rigid robe spanning both knees.
  for _,s in {-1,1}do local side=if s==-1 then 'Left' else 'Right'
   part('RobePanel'..side,side..'UpperLeg',{.94,1.53,.14},{0,-.12,-.48},'Cloth')
   trim('RobeHem'..side,side..'UpperLeg',{.94,.09,.16},{0,-.83,-.50},'Accent')
   for i=-1,1,2 do part('RobeFold'..side..i,side..'UpperLeg',{.06,1.34,.05},{i*.27,-.13,-.57},'Linen',Enum.Material.Fabric,nil,nil,2)end
  end
 else
  for _,s in {-1,1}do part('CoatTail'..s,'LowerTorso',{.78,.77,.16},{s*.49,-.64,.47},'Cloth',Enum.Material.Fabric,'Wedge',CFrame.Angles(0,math.pi,0))end
 end
 if style.Cape then
  local length=if style.Style=='Commander' or style.Robe then 2.35 else 1.55
  part('CapeMantle','UpperTorso',{2.02,.31,1.02},{0,.50,.17},'Cloth',Enum.Material.Fabric,'Ball')
  for i=-1,1 do part('CapeFold'..i,'UpperTorso',{.64,length,.13},{i*.60,.20-length/2,.68},'Cloth',Enum.Material.Fabric,'Wedge',CFrame.Angles(.10,0,i*.045))end
  for _,s in {-1,1}do disc('CapeClasp'..s,'UpperTorso',.23,{s*.70,.46,-.60},'Accent')end
 end
 if style.Armor then
  plate('ForgedBreastplate','UpperTorso',{1.72,1.16,.30},{0,-.04,-.56},'Metal')
  for _,s in {-1,1}do
   trim('BreastplateEdge'..s,'UpperTorso',{.07,.99,.10},{s*.65,-.03,-.73},'Accent',CFrame.Angles(0,0,s*.20))
   local side=if s==-1 then 'Left' else 'Right'
   for layer=1,2 do plate('Pauldron'..side..layer,side..'UpperArm',{.83,.35,.97},{s*.03,.42-(layer-1)*.25,0},if layer==1 then 'Metal' else 'Accent')end
   plate('Vambrace'..side,side..'LowerArm',{.59,.59,.19},{0,-.02,-.36},'Metal')
   plate('KneeGuard'..side,side..'UpperLeg',{.69,.45,.18},{0,-.44,-.44},'Metal')
  end
  disc('GuildSeal','UpperTorso',.39,{0,.23,-.79},'Accent',.08)
  for _,a in {0,math.pi/2}do trim('CompassRay'..a,'UpperTorso',{.055,.26,.04},{0,.23,-.86},'Dark',CFrame.Angles(0,0,a))end
 else
  disc('Pendant','UpperTorso',.22,{0,.31,-.66},'Accent')
  for i=1,3 do disc('CoatButton'..i,'UpperTorso',.09,{.10,.08-i*.20,-.63},'Accent')end
 end
 if style.Apron then
  part('ApronBib','UpperTorso',{1.24,1.11,.08},{0,-.08,-.70},if style.Style=='Host' then 'Linen' else 'Leather',if style.Style=='Host' then Enum.Material.Fabric else Enum.Material.SmoothPlastic)
  part('ApronSkirt','LowerTorso',{1.32,.77,.09},{0,-.50,-.59},if style.Style=='Host' then 'Linen' else 'Leather',Enum.Material.SmoothPlastic)
  part('ApronPocket','LowerTorso',{.56,.28,.06},{-.28,-.38,-.67},'Cloth')
  for i=1,3 do part('WorkWear'..i,'UpperTorso',{.14,.035,.02},{(i-2)*.25,-.30+(i%2)*.12,-.75},'Dark',Enum.Material.Fabric,nil,CFrame.Angles(0,0,.35),2)end
 end
 if style.Helmet then
  plate('HelmetCap','Head',{1.52,.62,1.30},{0,.49,.09},'Metal')
  trim('HelmetBrow','Head',{1.37,.13,.17},{0,.38,-.51},'Accent')
  for _,s in {-1,1}do plate('CheekGuard'..s,'Head',{.26,.65,.39},{s*.68,-.06,.05},'Metal')end
  if style.Variant==1 then part('HelmetCrest','Head',{.17,.48,.85},{0,.92,.12},'Cloth',Enum.Material.Fabric,'Wedge')end
 elseif style.Hat then
  part('StrawBrim','Head',{.13,1.92,1.92},{0,.67,.05},'Linen',Enum.Material.Fabric,'Cylinder',CFrame.Angles(0,0,math.pi/2))
  part('StrawCrown','Head',{.58,1.10,1.10},{0,.93,.05},'Linen',Enum.Material.Fabric,'Cylinder',CFrame.Angles(0,0,math.pi/2))
 elseif style.Style=='Mage' then
  part('MageCowl','Head',{1.55,.53,1.20},{0,.53,.20},'Cloth',Enum.Material.Fabric,'Ball')
  disc('CowlGem','Head',.17,{0,.58,-.45},'Accent')
 end
 if style.Monocle then
  for i=0,7 do local a=i*math.pi/4;trim('LensRim'..i,'Head',{.14,.035,.035},{.27+math.cos(a)*.185,.045+math.sin(a)*.185,-.655},'Accent',CFrame.Angles(0,0,a+math.pi/2))end
  local glass=disc('Lens','Head',.32,{.27,.045,-.680},'White',.03);glass.Transparency=.70;glass.Material=Enum.Material.Glass
  trim('LensChain','Head',{.025,.41,.025},{.53,-.18,-.47},'Accent',CFrame.Angles(0,0,-.20))
 end
 if style.Sword then
  local tilt=CFrame.Angles(0,0,-.27)
  part('SwordSheath','LowerTorso',{.27,1.65,.24},{-.98,-.65,.35},'Leather',Enum.Material.SmoothPlastic,nil,tilt)
  trim('SheathTip','LowerTorso',{.30,.19,.27},{-1.20,-1.43,.35},'Metal',tilt)
  part('SwordGrip','LowerTorso',{.18,.46,.19},{-.67,.50,.35},'Dark',Enum.Material.SmoothPlastic,nil,tilt)
  trim('SwordGuard','LowerTorso',{.64,.10,.21},{-.73,.25,.35},'Accent',tilt)
 end
 if style.Shield then
  plate('Shield','LeftLowerArm',{.74,1.08,.16},{-.31,.02,.12},'Metal',CFrame.Angles(0,math.pi/2,0))
  part('ShieldEmblem','LeftLowerArm',{.045,.56,.40},{-.41,.04,.12},'Cloth',Enum.Material.Fabric)
 end
 if style.Book then
  part('BookCover','LeftHand',{.68,.10,.76},{0,.10,-.37},'Leather',Enum.Material.SmoothPlastic)
  part('BookPages','LeftHand',{.60,.09,.67},{0,.18,-.37},'Linen',Enum.Material.SmoothPlastic)
  for i=1,3 do part('BookWriting'..i,'LeftHand',{.40,.015,.025},{0,.235,-.57+i*.11},'Dark',Enum.Material.SmoothPlastic,nil,nil,2)end
 end
 if style.Hammer then
  part('HammerGrip','RightHand',{.15,1.05,.15},{0,-.22,-.12},'Leather',Enum.Material.Wood)
  part('HammerHead','RightHand',{.67,.31,.31},{0,.35,-.12},'Metal',Enum.Material.Metal)
  trim('HammerBand','RightHand',{.14,.33,.33},{0,.35,-.12},'Accent')
  -- An unfinished, blunt weapon blank for forging/inspection; decorative only.
  part('BlankTang','LeftHand',{.09,.32,.10},{0,-.18,-.22},'Dark',Enum.Material.Metal)
  part('ForgingBlank','LeftHand',{.16,1.0,.06},{0,-.80,-.22},'Metal',Enum.Material.Metal)
  part('ForgingTip','LeftHand',{.06,.35,.16},{0,-1.45,-.22},'Metal',Enum.Material.Metal,'Wedge',CFrame.Angles(0,0,math.pi)*CFrame.Angles(0,math.pi/2,0))
 end
 if style.Staff then
  part('StaffShaft','RightHand',{.15,3.9,.15},{.10,.35,-.11},'Leather',Enum.Material.Wood)
  disc('StaffBinding','RightHand',.34,{.10,2.13,-.11},'Accent')
  local orb=part('ArcaneOrb','RightHand',{.30,.30,.30},{.10,2.42,-.11},'Eyes',Enum.Material.Neon,'Ball');orb.Transparency=.25;orb:SetAttribute('NPCVisualEffect',true)
  for i=1,3 do part('StaffRune'..i,'RightHand',{.03,.15,.03},{.18,1.2+i*.23,-.20},'Accent',Enum.Material.Metal,nil,CFrame.Angles(0,0,.7),2)end
 end
 if style.Cup then
  part('Tankard','RightHand',{.43,.52,.43},{0,-.05,-.28},'Leather',Enum.Material.Wood,'Cylinder',CFrame.Angles(0,0,math.pi/2))
  trim('TankardRim','RightHand',{.46,.06,.46},{0,.20,-.28},'Metal')
 end
 if style.Backpack then
  part('TravelPack','UpperTorso',{1.05,1.35,.58},{0,-.13,.89},'Leather',Enum.Material.SmoothPlastic)
  part('Bedroll','UpperTorso',{1.28,.46,.46},{0,.71,.91},'Linen',Enum.Material.Fabric,'Cylinder')
  for _,s in {-1,1}do part('PackStrap'..s,'UpperTorso',{.12,1.27,.08},{s*.43,0,-.66},'Leather',Enum.Material.SmoothPlastic)end
 end
 if style.Style=='Warden' then for i=1,3 do disc('WardenKey'..i,'LowerTorso',.17,{.87,-.17-i*.15,-.32},'Accent')end end
 local changes={}
 for name,p in rig.Bodies do if name~='HumanoidRootPart' then
  local gloves=name:find('Hand') and (style.Armor or style.Hammer)
  local skin=name=='Head' or (name:find('Hand') and not gloves)
  changes[p]={Color=if skin then palette.Skin else if name:find('Leg') or name:find('Foot') then palette.Dark else palette.Cloth,Material=if skin then Enum.Material.SmoothPlastic else Enum.Material.Fabric}
  if gloves then changes[p].Color=palette.Leather;changes[p].Material=Enum.Material.SmoothPlastic end
  if p:IsA('Part') then
   if name=='Head' or name:find('Hand') or name:find('Foot') then changes[p].Shape=Enum.PartType.Ball
   else
    -- Continuous sleeves/trousers rather than disconnected ellipsoids. The
    -- original rig body and its coordinate frame stay intact under this shell.
    local shell=part('Tailored'..name,name,{p.Size.Y,p.Size.X,p.Size.Z},{0,0,0},if name:find('Leg') then 'Dark' else 'Cloth',Enum.Material.Fabric,'Cylinder',CFrame.Angles(0,0,math.pi/2))
    shell.CastShadow=true;changes[p].Transparency=1
   end
  end
 end end
 if rig.Bodies.Head:IsA('Part') then changes[rig.Bodies.Head].Shape=Enum.PartType.Ball;changes[rig.Bodies.Head].Size=Vector3.new(1.38,1.30,1.18)end
 assert(count<=style.MaxParts,'Orçamento visual excedido: '..style.Id..' '..count)
 folder:SetAttribute('VisualPartCount',count);folder:SetAttribute('VisualStyle',style.Style)
 return {Folder=folder,Changes=changes,Count=count}
end
function F.build(rig,style)
 local folder=Instance.new('Folder');folder.Name='NPCV2Visuals';folder:SetAttribute('NPCVisualOwner',2)
 local ok,result=pcall(build,rig,style,folder)
 if not ok then folder:Destroy();error(result)end
 return result
end
return F
