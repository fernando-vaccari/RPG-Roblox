-- One authoritative cosmetic-behavior scheduler; never mutates data, quests or services.
local Players=game:GetService('Players')
local Run=game:GetService('RunService')
local Tween=game:GetService('TweenService')
local Shared=game.ReplicatedStorage.EldravynNPCVisualV2
local Config=require(Shared.NPCVisualConfig).Behavior
local Appearance=require(Shared.NPCAppearanceConfig)
local Behavior={Current=nil}
function Behavior.start(npcs,folder)
 if Behavior.Current and not Behavior.Current.Stopped then return Behavior.Current end
 local Placement=require(script.Parent.Placement);local Dialogue=require(script.Parent.DialogueService)
 local self={Entries={},Connections={},Stopped=false,Accum=0};Behavior.Current=self
 local function state(e,name)if e.State~=name then e.State=name;e.NPC:SetAttribute('NPCV2State',name)end end
 function self:cancel(e)
  if e.Tween then e.Tween:Cancel();e.Tween:Destroy();e.Tween=nil end;e.Moving=false
 end
 function self:speaker(e,now)
  local candidates={}
  for player,s in Dialogue.Sessions do
   if player.Parent==Players and s.NPC==e.NPC and (s.Busy or (s.Expires or 0)>now) then table.insert(candidates,player)end
  end
  table.sort(candidates,function(a,b)return a.UserId<b.UserId end)
  for _,player in candidates do if player.UserId==e.Speaker then return player.UserId end end
  return candidates[1] and candidates[1].UserId
 end
 function self:interaction(e,now)
  local speaker=self:speaker(e,now)
  if speaker then self:cancel(e);e.Speaker=speaker;e.NPC:SetAttribute('NPCV2Speaker',speaker);state(e,'Talk');return true end
  if e.Speaker then e.Speaker=nil;e.NPC:SetAttribute('NPCV2Speaker',nil);e.NextMove=now+1;e.ReturnPending=(e.Root.Position-e.Home.Position).Magnitude>.06;state(e,'Idle')end
  return false
 end
 function self:clear(e,target)
  if e.NPC:GetAttribute('NPCV2PatrolFloorValid')==false then return false end
  local origin=e.Root.Position;local delta=target.Position-origin
  if (target.Position-e.Home.Position).Magnitude>Config.PatrolRadius+.05 then return false end
  local samples=math.max(1,math.ceil(delta.Magnitude/.35))
  for i=0,samples do
   local point=origin+delta*(i/samples)-Vector3.new(0,3,0)
   local floor=Placement.safe(point,{folder},point.Y)
   if not floor or math.abs(floor.Y-point.Y)>.65 then return false end
  end
  -- Prevent cosmetic actors crossing one another, even with collision disabled.
  for _,other in self.Entries do
   if other~=e and other.Root.Parent then
    local d=other.Root.Position-origin;local length=delta:Dot(delta)
    local t=if length>0 then math.clamp(d:Dot(delta)/length,0,1) else 0
    if (other.Root.Position-(origin+delta*t)).Magnitude<4.5 then return false end
   end
  end
  return true
 end
 function self:move(e,target,now)
  if not self:clear(e,target) then state(e,'Observe');e.NextMove=now+Config.Pause;return false end
  local distance=(target.Position-e.Root.Position).Magnitude
  if distance<.06 then e.ReturnPending=false;return false end
  local duration=distance/Config.Speed
  e.Tween=Tween:Create(e.Root,TweenInfo.new(duration,Enum.EasingStyle.Linear),{CFrame=target});e.Tween:Play()
  e.Target=target;e.EndAt=now+duration;e.Moving=true;state(e,'Walk');return true
 end
 function self:step(now)
  if self.Stopped then return end
  local people={};for _,player in Players:GetPlayers()do local char=player.Character;local root=char and char:FindFirstChild('HumanoidRootPart');local hum=char and char:FindFirstChildOfClass('Humanoid');if root and hum and hum.Health>0 then table.insert(people,root.Position)end end
  local moving=0;for _,e in self.Entries do if e.Moving then moving+=1 end end
  for _,e in self.Entries do
   if not e.NPC:IsDescendantOf(folder) or e.Humanoid.Health<=0 then self:cancel(e);state(e,'Idle');continue end
   if self:interaction(e,now) then continue end
   local near=false;for _,point in people do if (e.Root.Position-point).Magnitude<=Config.ActiveDistance then near=true;break end end
   if not near then self:cancel(e);state(e,'Idle');continue end
   if e.Moving then
    -- Re-query the remaining path so a new obstacle cancels movement.
    if not self:clear(e,e.Target) then self:cancel(e);e.NextMove=now+Config.Pause;state(e,'Observe')
    elseif now>=e.EndAt then
     self:cancel(e);e.ReturnPending=(e.Root.Position-e.Home.Position).Magnitude>.06;e.NextMove=now+Config.Pause;state(e,'Observe')
    end
   elseif e.Style.Patrol and now>=e.NextMove and moving<Config.MaxMoving then
    local away=(e.Root.Position-e.Home.Position).Magnitude>.06
    local target=if away or e.ReturnPending then e.Home else e.Home*CFrame.new(if e.Direction==1 then 2.5 else -2.5,0,0)
    if self:move(e,target,now) then moving+=1;if not away then e.Direction=-e.Direction end end
   else state(e,if e.Style.Patrol then 'Observe' else 'Work')end
  end
 end
 function self:destroy()
  if self.Stopped then return end;self.Stopped=true
  for _,c in self.Connections do c:Disconnect()end
  for _,e in self.Entries do self:cancel(e);if e.NPC.Parent then e.NPC:SetAttribute('NPCV2State',nil);e.NPC:SetAttribute('NPCV2Speaker',nil)end end
  table.clear(self.Entries);table.clear(self.Connections);if Behavior.Current==self then Behavior.Current=nil end
 end
 local ordered={};for id,npc in npcs do if npc:GetAttribute('NPCVisualVersion')==2 then table.insert(ordered,{Id=id,NPC=npc})end end
 table.sort(ordered,function(a,b)return a.Id<b.Id end)
 for index,row in ordered do
  local npc=row.NPC;local root=npc.PrimaryPart;local hum=npc:FindFirstChildOfClass('Humanoid')
  if root and hum then
   local e={NPC=npc,Root=root,Humanoid=hum,Home=root.CFrame,Style=Appearance.forNPC(row.Id,npc:GetAttribute('NPCRole'),npc:GetAttribute('City')),NextMove=os.clock()+2+(index%5),Direction=1}
   table.insert(self.Entries,e);state(e,'Idle')
   local prompt=npc:FindFirstChild('NPCInteraction',true)
   if prompt then table.insert(self.Connections,prompt.Triggered:Connect(function(player)
    local now=os.clock()
    if not self:interaction(e,now) and player and Dialogue.near(player,npc) then
     -- Listener order is not a contract: the original handler may not yet have
     -- opened its session. Pause only cosmetics after its existing proximity check.
     self:cancel(e);e.NextMove=now+Config.Tick*2;state(e,'Idle')
    end
   end))end
  end
 end
 table.insert(self.Connections,Run.Heartbeat:Connect(function(dt)self.Accum+=dt;if self.Accum>=Config.Tick then self.Accum=0;self:step(os.clock())end end))
 table.insert(self.Connections,folder.Destroying:Connect(function()self:destroy()end))
 return self
end
return Behavior
