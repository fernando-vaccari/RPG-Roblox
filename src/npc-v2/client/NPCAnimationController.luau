local Shared=game.ReplicatedStorage.EldravynNPCVisualV2
local Config=require(Shared.NPCVisualConfig)
local Motion=require(Shared.NPCMotion)
local Policy=require(Shared.NPCVisualPolicy)
local Animation={}
local function playable(hum)
 if not hum or hum.Health<=0 then return false end
 local state=hum:GetState()
 return state~=Enum.HumanoidStateType.Dead and state~=Enum.HumanoidStateType.Ragdoll and state~=Enum.HumanoidStateType.Seated and state~=Enum.HumanoidStateType.FallingDown
end
function Animation.new(npc)
 local hum=npc:FindFirstChildOfClass('Humanoid');local self={NPC=npc,Humanoid=hum,Animator=hum and hum:FindFirstChildOfClass('Animator'),Joints={},Tracks={},Failed={},Assets={},Connections={},NativeOffsets={},NativeAttention={},State=nil,Current=nil,Owns=false,Released=false,External=false,CheckAt=0}
 for _,node in npc:GetDescendants()do if node:IsA('Motor6D') then self.Joints[node.Name]=node end end
 return setmetatable(self,{__index=Animation})
end
-- Remove our previous additive offsets BEFORE Animator samples the next frame.
-- Tracks may omit Neck/Waist; without this, attention would accumulate on them.
function Animation:beforeAnimation()
 for joint,offset in self.NativeOffsets do
  if joint.Parent and joint.Transform==offset.Applied then joint.Transform=offset.Base end
 end
 table.clear(self.NativeOffsets)
end
function Animation:afterAnimation()
 if not self.Current or not self.Current.IsPlaying or self.Current.Length<=0 or not self.Owns or self.External or not playable(self.Humanoid) then return end
 self:beforeAnimation()
 -- Reapply only these two cached offsets even on frames between budgeted pose
 -- updates, otherwise PreAnimation removal would make native attention flicker.
 for joint,desired in self.NativeAttention do if joint.Parent then
  local base=joint.Transform;local applied=base*desired
  self.NativeOffsets[joint]={Base=base,Applied=applied};joint.Transform=applied
 end end
end
function Animation:stop(reset)
 self:beforeAnimation()
 table.clear(self.NativeAttention)
 if self.Current then self.Current:Stop(Config.FadeSeconds);self.Current=nil end
 if reset and self.Owns then for _,joint in self.Joints do if joint.Parent then joint.Transform=CFrame.new()end end end
 self.Owns=false;self.State=nil
end
function Animation:destroy()
 if self.Released then return end;self:stop(true);self.Released=true
 for _,connection in self.Connections do connection:Disconnect()end
 for _,track in self.Tracks do track:Destroy()end
 for _,asset in self.Assets do asset:Destroy()end
 table.clear(self.Joints);table.clear(self.Tracks);table.clear(self.Assets)
end
function Animation:track(state)
 local def=Config.Animations[state]
 if not def or not Policy.clipId(def.Id) or self.Failed[state] or not self.Animator then return nil end
 if self.Tracks[state] then return self.Tracks[state]end
 local asset=Instance.new('Animation');asset.AnimationId=def.Id;table.insert(self.Assets,asset)
 local ok,track=pcall(function()return self.Animator:LoadAnimation(asset)end)
 if not ok then self.Failed[state]=true;warn('[NPC V2] Animação indisponível; fallback procedural: '..state);return nil end
 track.Priority=Enum.AnimationPriority[def.Priority];track.Looped=def.Looped;self.Tracks[state]=track;return track
end
function Animation:update(state,now,dt,phase,attention,reduced)
 self:beforeAnimation()
 if self.Released or not self.NPC.Parent or not playable(self.Humanoid) then self:stop(true);return end
 if now>=self.CheckAt then
  self.CheckAt=now+1;self.External=false
  local animate=self.NPC:FindFirstChild('Animate')
  if animate and animate:IsA('BaseScript') and not animate.Disabled then self.External=true end
  if self.Animator then for _,track in self.Animator:GetPlayingAnimationTracks()do
   local ours=false;for _,own in self.Tracks do if own==track then ours=true;break end end
   if not ours then self.External=true;break end
  end end
 end
 if self.External then self:stop(false);return end
 if self.State~=state then
  if self.Current then self.Current:Stop(Config.FadeSeconds)end
  self.State=state;self.Current=self:track(state)
  if self.Current then self.Current:Play(Config.FadeSeconds,1,1)end
 end
 local native=self.Current and self.Current.IsPlaying and self.Current.Length>0
 table.clear(self.NativeAttention)
 local pose=if native then {} else Motion.pose(state,now,phase,reduced)
 local alpha=1-math.exp(-10*math.min(dt,.25))
 for name,joint in self.Joints do
  if not joint.Parent then continue end
  local angles=pose[name] or {0,0,0};local desired=CFrame.Angles(angles[1],angles[2],angles[3])
  if name=='Neck' and attention then desired*=CFrame.Angles(attention.Pitch,attention.Yaw,0)
  elseif name=='Waist' and attention then desired*=CFrame.Angles(0,attention.Torso,0)end
  if native then
   if name=='Neck' or name=='Waist' then
    self.NativeAttention[joint]=desired
   end
  else joint.Transform=joint.Transform:Lerp(desired,alpha)end
 end
 self.Owns=true;if native then self:afterAnimation()end
end
return Animation
