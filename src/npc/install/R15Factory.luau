-- Original native R15 topology, Motor6D joints and decorative clothing. No asset IDs.
local F={}
function F.create(parent,definition,role,frame)
 local m=Instance.new('Model');m.Name=definition.Id;m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 m:SetAttribute('EldravynNPCId',definition.Id);m:SetAttribute('NPCRole',definition.Role);m:SetAttribute('City',definition.City)
 m:SetAttribute('AmbientNPC',definition.Ambient==true);m:SetAttribute('NPCVersion',1)
 if definition.Dungeon then m:SetAttribute('DungeonId',definition.Dungeon) end
 local mage=definition.Role=='Magic' or definition.Role=='Races' or definition.Role=='Fusions'
 local guard=definition.Role=='Guard' or definition.Role=='Classes' or definition.Role=='GuildMaster'
 local skin=Color3.fromRGB(190+(definition.Variant or 1)*6,148+(definition.Variant or 1)*5,115+(definition.Variant or 1)*4)
 local cloth=if mage then Color3.fromRGB(70,71,122) elseif guard then Color3.fromRGB(72,95,117) elseif definition.Role=='Blacksmith' then Color3.fromRGB(95,67,49) else Color3.fromRGB(100,102,72)
 local pants=Color3.fromRGB(59,51,49);local metal=Color3.fromRGB(153,161,171)
 local parts,offsets={},{}
 local function part(name,size,offset,color)
  local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=frame*CFrame.new(offset);p.Color=color
  p.Material=Enum.Material.SmoothPlastic;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Massless=true
  p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=m
  parts[name]=p;offsets[name]=offset;return p
 end
 local root=part('HumanoidRootPart',Vector3.new(2,2,1),Vector3.new(0,3,0),cloth);root.Transparency=1;root.Anchored=true
 part('LowerTorso',Vector3.new(1.8,0.9,0.9),Vector3.new(0,3,0),cloth)
 part('UpperTorso',Vector3.new(2,1.4,1),Vector3.new(0,4,0),cloth)
 local head=part('Head',Vector3.new(1.4,1.1,1),Vector3.new(0,5.25,0),skin)
 for _,side in {'Left','Right'} do
  local x=if side=='Left' then -1 else 1
  part(side..'UpperArm',Vector3.new(0.65,1.1,0.75),Vector3.new(x*1.35,4,0),cloth)
  part(side..'LowerArm',Vector3.new(0.6,0.9,0.65),Vector3.new(x*1.35,3,0),if definition.Role=='Blacksmith' then skin else cloth)
  part(side..'Hand',Vector3.new(0.6,0.5,0.65),Vector3.new(x*1.35,2.3,0),if guard or definition.Role=='Blacksmith' then pants else skin)
  part(side..'UpperLeg',Vector3.new(0.8,1.2,0.8),Vector3.new(x*0.5,1.95,0),pants)
  part(side..'LowerLeg',Vector3.new(0.7,1,0.7),Vector3.new(x*0.5,0.9,0),pants)
  part(side..'Foot',Vector3.new(0.8,0.5,1.2),Vector3.new(x*0.5,0.25,-0.1),Color3.fromRGB(45,37,33))
 end
 local function joint(name,a,b,pivot)
  local motor=Instance.new('Motor6D');motor.Name=name;motor.Part0=parts[a];motor.Part1=parts[b]
  motor.C0=CFrame.new(pivot-offsets[a]);motor.C1=CFrame.new(pivot-offsets[b]);motor.Parent=parts[a]
  for _,body in {a,b} do local at=Instance.new('Attachment');at.Name=name..'RigAttachment';at.CFrame=CFrame.new(pivot-offsets[body]);at.Parent=parts[body] end
 end
 joint('Root','HumanoidRootPart','LowerTorso',Vector3.new(0,3,0));joint('Waist','LowerTorso','UpperTorso',Vector3.new(0,3.4,0));joint('Neck','UpperTorso','Head',Vector3.new(0,4.7,0))
 for _,side in {'Left','Right'} do local x=if side=='Left' then -1 else 1
  joint(side..'Shoulder','UpperTorso',side..'UpperArm',Vector3.new(x,4.4,0))
  joint(side..'Elbow',side..'UpperArm',side..'LowerArm',Vector3.new(x*1.35,3.45,0))
  joint(side..'Wrist',side..'LowerArm',side..'Hand',Vector3.new(x*1.35,2.55,0))
  joint(side..'Hip','LowerTorso',side..'UpperLeg',Vector3.new(x*0.5,2.55,0))
  joint(side..'Knee',side..'UpperLeg',side..'LowerLeg',Vector3.new(x*0.5,1.35,0))
  joint(side..'Ankle',side..'LowerLeg',side..'Foot',Vector3.new(x*0.5,0.4,0))
 end
 local function adorn(name,size,offset,color,body)
  body=body or 'UpperTorso';local p=part(name,size,offsets[body]+offset,color)
  local weld=Instance.new('WeldConstraint');weld.Part0=parts[body];weld.Part1=p;weld.Parent=p;return p
 end
 for _,x in {-0.3,0.3} do adorn('Eye'..x,Vector3.new(0.13,0.17,0.08),Vector3.new(x,0,-0.54),Color3.fromRGB(28,24,31),'Head') end
 adorn('Hair',Vector3.new(1.5,0.35,1.1),Vector3.new(0,0.5,0.05),pants,'Head')
 adorn('Mouth',Vector3.new(0.3,0.06,0.06),Vector3.new(0,-0.3,-0.54),pants,'Head')
 adorn('Belt',Vector3.new(1.95,0.22,1),Vector3.new(0,-0.1,0),pants,'LowerTorso')
 if mage then
  adorn('Robe',Vector3.new(1.9,1.5,1),Vector3.new(0,-0.5,0),cloth,'LowerTorso')
  adorn('HatBrim',Vector3.new(2,0.2,1.6),Vector3.new(0,0.6,0),cloth,'Head')
  adorn('HatCrown',Vector3.new(1,1.2,0.9),Vector3.new(0,1.1,0),cloth,'Head')
  adorn('DecorativeStaff',Vector3.new(0.22,4.8,0.22),Vector3.new(0.5,0.8,0),Color3.fromRGB(102,75,46),'RightHand')
 elseif guard then
  adorn('Breastplate',Vector3.new(1.85,1.2,0.2),Vector3.new(0,0,-0.6),metal)
  for _,x in {-1,1} do adorn('Pauldron'..x,Vector3.new(0.9,0.35,1),Vector3.new(x*1.2,0.5,0),metal) end
 elseif definition.Role=='Blacksmith' then
  adorn('Apron',Vector3.new(1.6,2,0.15),Vector3.new(0,-0.4,-0.6),Color3.fromRGB(84,51,32))
  adorn('HammerHandle',Vector3.new(0.2,1.3,0.2),Vector3.new(0,-0.3,0),pants,'RightHand')
  adorn('HammerHead',Vector3.new(0.9,0.4,0.4),Vector3.new(0,0.35,0),metal,'RightHand')
 else
  adorn('VestTrim',Vector3.new(0.2,1.3,0.15),Vector3.new(-0.5,0,-0.6),Color3.fromRGB(204,178,106))
  adorn('Satchel',Vector3.new(0.8,0.8,0.5),Vector3.new(0.9,-0.3,0.1),pants,'LowerTorso')
 end
 local hum=Instance.new('Humanoid');hum.RigType=Enum.HumanoidRigType.R15;hum.DisplayName=role.Name..' • '..role.Title;hum.HipHeight=2
 hum.MaxHealth=100;hum.Health=100;hum.BreakJointsOnDeath=false;hum.AutoRotate=false;hum.Parent=m
 local animator=Instance.new('Animator');animator.Parent=hum
 local prompt=Instance.new('ProximityPrompt');prompt.Name='NPCInteraction';prompt.ActionText='Conversar';prompt.ObjectText=role.Name..' • '..role.Title
 prompt.MaxActivationDistance=12;prompt.RequiresLineOfSight=true;prompt.HoldDuration=0;prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.Parent=head
 m.PrimaryPart=root;m.Parent=parent;return m
end
return F
