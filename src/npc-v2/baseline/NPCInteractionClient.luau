local Players=game:GetService('Players')
local player=Players.LocalPlayer
local remotes=game.ReplicatedStorage:WaitForChild('EldravynNPC'):WaitForChild('RemoteEvents')
local ui=require(script.Parent.NPCDialogueClient).new(player:WaitForChild('PlayerGui'),remotes:WaitForChild('Action'))
local marker
remotes:WaitForChild('View').OnClientEvent:Connect(function(payload)
 ui:receive(payload)
 if payload.Marker then
  if marker then marker:Destroy()end
  marker=Instance.new('Part');marker.Name='NPCDestination';marker.Size=Vector3.new(0.5,0.5,0.5);marker.Transparency=1;marker.Anchored=true;marker.CanCollide=false;marker.CanTouch=false;marker.CanQuery=false;marker.Position=payload.Marker.Position+Vector3.new(0,10,0);marker.Parent=workspace
  local billboard=Instance.new('BillboardGui');billboard.Size=UDim2.fromOffset(240,64);billboard.AlwaysOnTop=true;billboard.Adornee=marker;billboard.Parent=marker
  local label=Instance.new('TextLabel');label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=0.2;label.BackgroundColor3=Color3.fromRGB(42,34,24);label.TextColor3=Color3.fromRGB(255,226,145);label.Font=Enum.Font.SourceSansBold;label.TextSize=18;label.TextWrapped=true;label.Text='◆ '..payload.Marker.Name;label.Parent=billboard
  local this=marker;task.delay(payload.Marker.Seconds,function()if this then this:Destroy()end;if marker==this then marker=nil end end)
 end
end)
game:GetService('UserInputService').InputBegan:Connect(function(input,processed)if not processed and input.KeyCode==Enum.KeyCode.Escape then ui:hide()end end)
-- Bounded local idle poses; no external Animation IDs or server frame loop.
local joints={};local elapsed=0
local function refresh()
 joints={};local folder=workspace:FindFirstChild('EldravynNPCs');local root=player.Character and player.Character:FindFirstChild('HumanoidRootPart')
 if not folder or not root then return end
 local nearest={}
 for _,npc in folder:GetDescendants()do if npc:IsA('Model') and npc:GetAttribute('EldravynNPCId') and npc.PrimaryPart then
  local distance=(npc.PrimaryPart.Position-root.Position).Magnitude;if distance<90 then table.insert(nearest,{NPC=npc,Distance=distance})end
 end end
 table.sort(nearest,function(a,b)return a.Distance<b.Distance end)
 for index=1,math.min(#nearest,12)do
  local npc=nearest[index].NPC;local torso=npc:FindFirstChild('UpperTorso');local neck=torso and torso:FindFirstChild('Neck')
  if neck then table.insert(joints,neck)end
 end
end
task.spawn(function()while true do refresh();task.wait(2)end end)
game:GetService('RunService').Heartbeat:Connect(function(dt)
 elapsed+=dt;for index,joint in joints do if joint.Parent then joint.Transform=CFrame.Angles(math.sin(elapsed*1.3+index)*0.025,math.sin(elapsed*0.8+index)*0.07,0)end end
end)
