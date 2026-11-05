-- Small, bounded patrols for ambient residents only. No pathfinding or combat AI.
local Players=game:GetService('Players')
local TweenService=game:GetService('TweenService')
local Placement=require(script.Parent.Placement)
local Ambient={}
local mobile={Resident=true,Traveler=true,Farmer=true,Adventurer=true}
function Ambient.start(npcs,folder)
 if workspace:GetAttribute('EldravynNPCVisualVersion')==2 then return require(script.Parent.NPCBehaviorController).start(npcs,folder)end
 local homes={};for _,npc in npcs do
  if npc:GetAttribute('AmbientNPC') and mobile[npc:GetAttribute('NPCRole')] and npc.PrimaryPart then homes[npc]={Frame=npc.PrimaryPart.CFrame,Away=false}end
 end
 task.spawn(function()
  while folder.Parent do
   task.wait(10);local active=0
   for npc,home in homes do
    if active>=4 then break end
    local root=npc.PrimaryPart;local nearby=false
    if not root or (npc:GetAttribute('NPCSpeakingUntil') or 0)>os.clock() then continue end
    for _,player in Players:GetPlayers()do local p=player.Character and player.Character:FindFirstChild('HumanoidRootPart');if p and (p.Position-root.Position).Magnitude<75 then nearby=true;break end end
    if not nearby then continue end
    local target=home.Frame*(if home.Away then CFrame.new() else CFrame.new(2.5,0,0))
    local delta=target.Position-root.Position;local valid=true;local feet
    for step=0,4 do
     local point=root.Position+delta*(step/4)-Vector3.new(0,3,0)
     feet=Placement.safe(point,{folder},point.Y)
     if not feet or math.abs(feet.Y-point.Y)>0.7 then valid=false;break end
    end
    for other in homes do if other~=npc and other.PrimaryPart and (other.PrimaryPart.Position-target.Position).Magnitude<6 then valid=false;break end end
    if valid and feet then
     active+=1;home.Away=not home.Away
     local destination=target+Vector3.new(0,feet.Y+3-target.Position.Y,0)
     TweenService:Create(root,TweenInfo.new(2,Enum.EasingStyle.Linear),{CFrame=destination}):Play()
    end
   end
  end
 end)
end
return Ambient
