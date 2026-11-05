-- One bounded cosmetic scheduler. Never starts AI or sends combat intentions.
local Run=game:GetService('RunService')
local Players=game:GetService('Players')
local Collection=game:GetService('CollectionService')
local Animation=require(script.Parent.NPCAnimationController)
local Controller={Current=nil}
function Controller.start()
 if Controller.Current then return Controller.Current end
 local self={Entries={},Connections={},Selected={},Scan=0,Stopped=false};Controller.Current=self
 function self:remove(model)
  local e=self.Entries[model];if not e then return end
  e.Animation:destroy();for joint in e.Joints do if joint.Parent then joint.Transform=CFrame.new()end end
  if e.Blob and e.Blob.Parent then e.Blob.Size=e.BlobSize end
  self.Entries[model]=nil;self.Selected[model]=nil
 end
 function self:add(model)
  if self.Entries[model]or not model:IsA('Model')or model:GetAttribute('AvatarArtVersion')~=3 or not model:GetAttribute('AvatarEnemyKind')or not model.PrimaryPart then return end
  local h=model:FindFirstChildOfClass('Humanoid');local visuals=model:FindFirstChild('AvatarEnemyVisuals');if not h or not visuals then return end
  local e={Model=model,Root=model.PrimaryPart,Humanoid=h,Kind=model:GetAttribute('AvatarRigKind'),Animation=Animation.new(model),Joints={},Last=model.PrimaryPart.Position,Accum=0}
  for _,node in model:GetDescendants()do if node:IsA('Motor6D')and node.Name:match('^Avatar_')then e.Joints[node]=node.Name:sub(8)end end
  e.Blob=visuals:FindFirstChild('Avatar_Blob');if e.Blob then e.BlobSize=e.Blob.Size end
  self.Entries[model]=e
 end
 function self:scan()
  for model in self.Entries do if not model:IsDescendantOf(workspace)then self:remove(model)end end
  local player=Players.LocalPlayer;local root=player and player.Character and player.Character:FindFirstChild('HumanoidRootPart');local rows={}
  if root then for model,e in self.Entries do local d=(e.Root.Position-root.Position).Magnitude;if d<100 and e.Humanoid.Health>0 then table.insert(rows,{Model=model,Distance=d})end end end
  table.sort(rows,function(a,b)return a.Distance<b.Distance end)
  local nextSelection={};for i=1,math.min(10,#rows)do nextSelection[rows[i].Model]=true end
  for model in self.Selected do if not nextSelection[model]and self.Entries[model]then self.Entries[model].Animation:stop(true)end end
  self.Selected=nextSelection
 end
 function self:step(dt,now)
  if self.Stopped then return end;self.Scan+=dt;if self.Scan>=1 then self.Scan=0;self:scan()end
  for model in self.Selected do
   local e=self.Entries[model];if not e then continue end;e.Accum+=dt
   if e.Accum<.05 then e.Animation:afterAnimation();continue end
   local elapsed=e.Accum;e.Accum=0;local speed=(e.Root.Position-e.Last).Magnitude/math.max(elapsed,.001);e.Last=e.Root.Position
   if e.Humanoid.Health<=0 then e.Animation:stop(true);continue end
   local state=model:GetAttribute('State');local pose=if state=='WINDUP'then'Inspect'elseif state=='ATTACK'then'Forge'elseif speed>.3 then'Walk'else'Idle'
   if e.Kind=='R15'then e.Animation:update(pose,now,elapsed,0,nil,false)
   elseif e.Kind=='Quadruped'then
    for joint,bone in e.Joints do
     local sign=if bone=='FrontLeft'or bone=='HindRight'then 1 else-1
     local angle=if bone:find('Front')or bone:find('Hind')then math.sin(now*7)*.48*sign*(if speed>.3 then 1 else 0)elseif bone=='BeastHead'then math.sin(now*1.1)*.045 else math.sin(now*1.7)*.10
     joint.Transform=joint.Transform:Lerp(CFrame.Angles(angle,0,0),.3)
    end
   elseif e.Blob and e.Blob.Parent then local pulse=math.sin(now*4)*.055;e.Blob.Size=Vector3.new(e.BlobSize.X*(1-pulse/2),e.BlobSize.Y*(1+pulse),e.BlobSize.Z*(1-pulse/2))end
  end
 end
 function self:destroy()
  if self.Stopped then return end;self.Stopped=true;for _,c in self.Connections do c:Disconnect()end
  local list={};for model in self.Entries do table.insert(list,model)end;for _,model in list do self:remove(model)end;table.clear(self.Selected);Controller.Current=nil
 end
 table.insert(self.Connections,Run.PreAnimation:Connect(function()for model in self.Selected do local e=self.Entries[model];if e then e.Animation:beforeAnimation()end end end))
 table.insert(self.Connections,Run.PreSimulation:Connect(function(dt)self:step(dt,workspace:GetServerTimeNow())end))
 for _,model in Collection:GetTagged('EldravynAvatarEnemy')do self:add(model)end
 table.insert(self.Connections,Collection:GetInstanceAddedSignal('EldravynAvatarEnemy'):Connect(function(model)self:add(model)end))
 table.insert(self.Connections,Collection:GetInstanceRemovedSignal('EldravynAvatarEnemy'):Connect(function(model)self:remove(model)end))
 self:scan();return self
end
return Controller
