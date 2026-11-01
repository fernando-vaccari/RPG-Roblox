local Shared=game.ReplicatedStorage.EldravynNPCVisualV2
local Policy=require(Shared.NPCVisualPolicy)
local Config=require(Shared.NPCVisualConfig).Attention
local A={}
function A.new(npc)
 return {NPC=npc,Head=npc:FindFirstChild('Head'),Root=npc:FindFirstChild('HumanoidRootPart'),Target=nil,LastGreeting=-math.huge,Yaw=0,Pitch=0,Torso=0}
end
function A.update(self,people,now,dt)
 local target,nearest=nil,Config.Distance;local activeId=self.NPC:GetAttribute('NPCV2Speaker')
 if not self.Head or not self.Root then return self end
 for _,record in people do
  local distance=(record.Position-self.Head.Position).Magnitude
  if record.Id==activeId and distance<=Config.Distance then target=record;break end
  if not activeId and distance<nearest then
   local localPoint=self.Root.CFrame:PointToObjectSpace(record.Position)
   local _,_,_,visible=Policy.attention(localPoint.X,localPoint.Y-2.25,localPoint.Z,false,Config)
   if visible then target=record;nearest=distance end
  end
 end
 local yaw,pitch,torso=0,0,0
 if target then
  local localPoint=self.Root.CFrame:PointToObjectSpace(target.Position)
  yaw,pitch,torso=Policy.attention(localPoint.X,localPoint.Y-2.25,localPoint.Z,target.Id==activeId,Config)
 end
 self.Greeting=false
 if target and not activeId and self.Target~=target.Id and now-self.LastGreeting>=Config.GreetingCooldown then self.Greeting=true;self.LastGreeting=now end
 self.Target=target and target.Id
 local alpha=1-math.exp(-Config.Response*math.min(dt,.25))
 self.Yaw+=(yaw-self.Yaw)*alpha;self.Pitch+=(pitch-self.Pitch)*alpha;self.Torso+=(torso-self.Torso)*alpha
 return self
end
return A
