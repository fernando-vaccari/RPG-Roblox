local Players=game:GetService('Players')
local Run=game:GetService('RunService')
local Shared=game.ReplicatedStorage.EldravynNPCVisualV2
local Config=require(Shared.NPCVisualConfig)
local Appearance=require(Shared.NPCAppearanceConfig)
local Motion=require(Shared.NPCMotion)
local Policy=require(Shared.NPCVisualPolicy)
local Animation=require(script.Parent.NPCAnimationController)
local Attention=require(script.Parent.NPCAttentionController)
local Manager={Current=nil}
function Manager.start(folder,localPlayer,mobile)
 if Manager.Current and not Manager.Current.Stopped then return Manager.Current end
 local self={Entries={},Connections={},Stopped=false,Scan=0,People={},Selected={},EffectSelection={},Effects=0};Manager.Current=self
 function self:remove(npc)
  local e=self.Entries[npc];if not e then return end;e.Animation:destroy()
  for _,p in e.Details do if p.Part.Parent then p.Part.LocalTransparencyModifier=p.Original end end
  for _,p in e.Effects do if p.Part.Parent then p.Part.Transparency=p.Transparency;p.Part.Size=p.Size end end
  self.Entries[npc]=nil;self.Selected[npc]=nil;self.EffectSelection[npc]=nil
 end
 function self:add(npc)
  if self.Stopped or self.Entries[npc] or not npc:IsA('Model') or npc:GetAttribute('NPCVisualVersion')~=2 or not npc.PrimaryPart then return end
  local hum=npc:FindFirstChildOfClass('Humanoid');if not hum or not hum:FindFirstChildOfClass('Animator') then return end
  local id=npc:GetAttribute('EldravynNPCId');if type(id)~='string' then return end
  local style=Appearance.forNPC(id,npc:GetAttribute('NPCRole'),npc:GetAttribute('City'))
  local e={NPC=npc,Root=npc.PrimaryPart,Style=style,Phase=(Appearance.hash(id)%1000)/79,Animation=Animation.new(npc),Attention=Attention.new(npc),Details={},Effects={},Accum=0,GreetUntil=0,LastPosition=npc.PrimaryPart.Position,Speed=0,WasSelected=false}
  for _,p in npc:GetDescendants()do if p:IsA('BasePart') then
   if p:GetAttribute('VisualDetail')==2 then table.insert(e.Details,{Part=p,Original=p.LocalTransparencyModifier})end
   if p:GetAttribute('NPCVisualEffect') then table.insert(e.Effects,{Part=p,Transparency=p.Transparency,Size=p.Size})end
  end end
  self.Entries[npc]=e
 end
 function self:scan(now)
  local character=localPlayer.Character;local origin=character and character:FindFirstChild('HumanoidRootPart')
  local camera=workspace.CurrentCamera;local position=origin and origin.Position or camera and camera.CFrame.Position
  self.People={}
  for _,p in Players:GetPlayers()do local c=p.Character;local root=c and c:FindFirstChild('HumanoidRootPart');local h=c and c:FindFirstChildOfClass('Humanoid')
   if root and h and h.Health>0 then table.insert(self.People,{Id=p.UserId,Position=root.Position+Vector3.new(0,1.5,0)})end
  end
  local candidates={}
  for npc,e in self.Entries do
   if not npc:IsDescendantOf(folder) then self:remove(npc);continue end
   local distance=if position then (e.Root.Position-position).Magnitude else math.huge;e.Distance=distance
   table.insert(candidates,{Key=npc,Id=npc:GetAttribute('EldravynNPCId'),Distance=distance,Active=npc:GetAttribute('NPCV2Speaker')==localPlayer.UserId})
  end
  self.Selected=Policy.select(candidates,mobile,Config.Performance)
  self.EffectSelection={};local effectCount=0
  for _,candidate in candidates do
   local e=self.Entries[candidate.Key]
   if self.Selected[candidate.Key]=='Full' and #e.Effects>0 and effectCount<Config.Performance.Effects then self.EffectSelection[candidate.Key]=true;effectCount+=1 end
  end
  for npc,e in self.Entries do
   local selected=self.Selected[npc];local detailed=selected=='Full' and e.Distance<Appearance.DetailDistance
   if detailed~=e.Detailed then e.Detailed=detailed;for _,p in e.Details do if p.Part.Parent then p.Part.LocalTransparencyModifier=if detailed then p.Original else 1 end end end
   if not selected and e.WasSelected then e.Animation:stop(true)end
   if selected and not e.WasSelected then e.LastPosition=e.Root.Position;e.Accum=0 end
   e.WasSelected=selected~=nil
   if not self.EffectSelection[npc] then for _,p in e.Effects do if p.Part.Parent then p.Part.Transparency=.65;p.Part.Size=p.Size end end end
  end
 end
 function self:step(dt,now)
  if self.Stopped then return end
  self.Scan+=dt;if self.Scan>=Config.Performance.ScanSeconds then self.Scan=0;self:scan(now)end
  local effects=0
  for npc,tier in self.Selected do
   local e=self.Entries[npc];if not e then continue end
   local full=tier=='Full';local hz=if not full then Config.Performance.ReducedHz elseif mobile then Config.Performance.MobileHz else Config.Performance.DesktopHz
   e.Accum+=dt;if e.Accum<1/hz then e.Animation:afterAnimation();continue end
   local elapsed=math.min(e.Accum,.25);e.Accum=0
   local speed=(e.Root.Position-e.LastPosition).Magnitude/elapsed;e.LastPosition=e.Root.Position;e.Speed=speed
   local attention=Attention.update(e.Attention,self.People,now,elapsed)
   if attention.Greeting then e.GreetUntil=now+1.4 end
   local state=npc:GetAttribute('NPCV2State') or 'Idle'
   if state=='Talk' or npc:GetAttribute('NPCV2Speaker') then state='Talk'
   elseif speed>.22 then state=if speed>4.5 then 'Run' else 'Walk'
   elseif now<e.GreetUntil then state='Greet'
   elseif state=='Work' then state=Motion.work(e.Style.Work,now,e.Phase,Config.Behavior.WorkCycle)
   elseif state~='Observe' then state='Idle'end
   if not full and state~='Walk' and state~='Run' then state='Idle'end
   e.Animation:update(state,now,elapsed,e.Phase,attention,not full)
   local effect=self.EffectSelection[npc]==true
   if effect then effects+=1 end
   for _,p in e.Effects do if p.Part.Parent then
    p.Part.Transparency=if effect and state=='Arcane' then .28+.12*math.sin(now*3) else .65
    p.Part.Size=p.Size*(if effect and state=='Arcane' then 1+.09*math.sin(now*3) else 1)
   end end
  end
  self.Effects=effects
 end
 function self:destroy()
  if self.Stopped then return end;self.Stopped=true
  for _,connection in self.Connections do connection:Disconnect()end
  local npcs={};for npc in self.Entries do table.insert(npcs,npc)end;for _,npc in npcs do self:remove(npc)end
  table.clear(self.Connections);table.clear(self.People);table.clear(self.Selected);table.clear(self.EffectSelection)
  if Manager.Current==self then Manager.Current=nil end
 end
 local function discover(node)
  if node:IsA('Model') then self:add(node)else local npc=node:FindFirstAncestorOfClass('Model');if npc and npc:IsDescendantOf(folder) then self:add(npc)end end
 end
 for _,node in folder:GetDescendants()do if node:IsA('Model') then self:add(node)end end
 table.insert(self.Connections,folder.DescendantAdded:Connect(discover))
 table.insert(self.Connections,folder.DescendantRemoving:Connect(function(node)if self.Entries[node] then self:remove(node)end end))
 table.insert(self.Connections,folder.Destroying:Connect(function()self:destroy()end))
 table.insert(self.Connections,Run.PreAnimation:Connect(function()for npc in self.Selected do local e=self.Entries[npc];if e then e.Animation:beforeAnimation()end end end))
 table.insert(self.Connections,Run.PreSimulation:Connect(function(dt)self:step(dt,workspace:GetServerTimeNow())end))
 self:scan(workspace:GetServerTimeNow());return self
end
return Manager
