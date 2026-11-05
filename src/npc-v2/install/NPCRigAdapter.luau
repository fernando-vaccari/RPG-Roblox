-- Inspect and retain the installed R15 bodies, joints, Humanoid and prompt.
local R={}
R.BodyNames={'HumanoidRootPart','LowerTorso','UpperTorso','Head','LeftUpperArm','LeftLowerArm','LeftHand','RightUpperArm','RightLowerArm','RightHand','LeftUpperLeg','LeftLowerLeg','LeftFoot','RightUpperLeg','RightLowerLeg','RightFoot'}
R.Joints={Root={'HumanoidRootPart','LowerTorso'},Waist={'LowerTorso','UpperTorso'},Neck={'UpperTorso','Head'}}
for _,side in {'Left','Right'}do
 R.Joints[side..'Shoulder']={'UpperTorso',side..'UpperArm'};R.Joints[side..'Elbow']={side..'UpperArm',side..'LowerArm'}
 R.Joints[side..'Wrist']={side..'LowerArm',side..'Hand'};R.Joints[side..'Hip']={'LowerTorso',side..'UpperLeg'}
 R.Joints[side..'Knee']={side..'UpperLeg',side..'LowerLeg'};R.Joints[side..'Ankle']={side..'LowerLeg',side..'Foot'}
end
R.LegacyDecor={Hair=true,Mouth=true,Belt=true,Robe=true,HatBrim=true,HatCrown=true,DecorativeStaff=true,Breastplate=true,Apron=true,HammerHandle=true,HammerHead=true,VestTrim=true,Satchel=true,['Eye-0.3']=true,['Eye0.3']=true,['Pauldron-1']=true,['Pauldron1']=true}
function R.inspect(npc)
 assert(npc:IsA('Model') and type(npc:GetAttribute('EldravynNPCId'))=='string','NPC V2: modelo sem identificador')
 local bodies,motors={},{}
 for _,name in R.BodyNames do local p=npc:FindFirstChild(name);assert(p and p:IsA('BasePart'),'Corpo R15 ausente: '..npc.Name..'/'..name);bodies[name]=p end
 local hum=npc:FindFirstChildOfClass('Humanoid');assert(hum and hum.RigType==Enum.HumanoidRigType.R15,'Humanoid R15 obrigatório')
 assert(hum:FindFirstChildOfClass('Animator'),'Animator original ausente')
 local prompt=npc:FindFirstChild('NPCInteraction',true);assert(prompt and prompt:IsA('ProximityPrompt') and prompt.Parent==bodies.Head,'Prompt original incompatível')
 assert(npc.PrimaryPart==bodies.HumanoidRootPart and bodies.HumanoidRootPart.Anchored,'Rig V1 exige root ancorado; nenhuma alteração automática')
 for _,node in npc:GetDescendants()do
  if node:IsA('BaseScript') then assert(node.Disabled,'Script de animação/comportamento ativo no NPC: '..node.Name)end
  if node:IsA('Motor6D') and R.Joints[node.Name] then assert(not motors[node.Name],'Motor duplicado');motors[node.Name]=node end
 end
 for name,pair in R.Joints do local j=motors[name];assert(j and j.Part0==bodies[pair[1]] and j.Part1==bodies[pair[2]],'Junta R15 incompatível: '..name)end
 return {Bodies=bodies,Motors=motors,Humanoid=hum,Prompt=prompt}
end
return R
