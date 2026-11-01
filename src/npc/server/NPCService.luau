local Players=game:GetService('Players')
local Shared=game.ReplicatedStorage:WaitForChild('EldravynNPC')
local C=require(Shared.Registry)
local Data=require(script.Parent.NPCDataService)
local Actions=require(script.Parent.NPCActionService)
local Dialogue=require(script.Parent.DialogueService)
local Purchase=require(script.Parent.PurchaseService)
local Placement=require(script.Parent.Placement)
local Service={Started=false}
local function remote(parent,name)
 local value=parent:FindFirstChild(name)
 if not value then value=Instance.new('RemoteEvent');value.Name=name;value.Parent=parent end
 assert(value:IsA('RemoteEvent'));return value
end
function Service.start()
 if Service.Started then return end
 local world=workspace:FindFirstChild('GeneratedWorld');local folder=workspace:FindFirstChild('EldravynNPCs')
 assert(world and folder,'Instale os NPCs no mapa antes de iniciar.')
 if world:GetAttribute('TerrainPending')==true then warn('[NPC] Terrain pendente. Use PrepareStudio em Edit antes de testar. Nenhum terreno será gerado no runtime.');return end
 Service.Started=true
 local remotes=Shared:FindFirstChild('RemoteEvents') or Instance.new('Folder');remotes.Name='RemoteEvents';remotes.Parent=Shared
 local view,action=remote(remotes,'View'),remote(remotes,'Action');Dialogue.start(view,action)
 for _,npc in folder:GetDescendants()do
  local id=npc:GetAttribute('EldravynNPCId')
  if npc:IsA('Model') and id then
   assert(not Actions.NPCs[id],'NPC duplicado: '..id);Actions.NPCs[id]=npc
   local root=npc:FindFirstChild('HumanoidRootPart');local prompt=npc:FindFirstChild('NPCInteraction',true)
   local entry=require(Shared.PlacementConfig).NPCs[id]
   local visualV2=workspace:GetAttribute('EldravynNPCVisualVersion')==2 and npc:GetAttribute('NPCVisualVersion')==2
   local frame=if visualV2 then require(script.Parent.NPCPositionAdapter).frame(npc,world,entry,folder,Placement) else entry and Placement.frame(world,entry,folder,true)
   if root and prompt and frame then
    if not visualV2 then npc:PivotTo(frame*CFrame.new(0,3,0))end;prompt.Enabled=true
    prompt.Triggered:Connect(function(player)Dialogue.open(player,npc)end)
    if not npc:GetAttribute('AmbientNPC') then Actions.Locations[id]={Name=C.Roles[npc:GetAttribute('NPCRole')].Title..' • '..npc:GetAttribute('City'),Position=frame.Position}end
   else
    if prompt then prompt.Enabled=false end
    warn('[NPC] Posição não validada; interação desativada: '..id)
   end
  end
 end
 local regions={}
 for id,entry in require(Shared.PlacementConfig).Regions do
  local anchor=Placement.resolve(world,entry.Anchor)
  if anchor and anchor:IsA('BasePart') then
   local record={Name=entry.Name,Position=anchor.Position,Radius=entry.Radius}
   regions[id]=record;Actions.Locations[id]=record
  end
 end
 Purchase.registerProduct('NPCClassChange',C.ClassChangeProduct,require(Shared.Rules).classReceipt)
 Purchase.OnGrant=function(p)Dialogue.close(p);view:FireClient(p,{Notice='Crédito oficial registrado. Converse novamente com o mestre de classes.'})end
 Purchase.start();Data.start()
 require(script.Parent.AmbientService).start(Actions.NPCs,folder)
 local function onCharacter(player,character)
  local root=character:WaitForChild('HumanoidRootPart',10);if not root then return end
  local state=Data.get(player);local id=state and state.NPC.ReturnNPC;local npc=id and Actions.NPCs[id]
  if not npc or not npc.PrimaryPart then return end
  -- Return beside the inn only if a fresh floor/clearance query succeeds.
  local position=npc.PrimaryPart.Position+npc.PrimaryPart.CFrame.LookVector*5-Vector3.new(0,3,0)
  local safe=Placement.safe(position,{folder,character},position.Y)
  if safe then root.CFrame=CFrame.new(safe+Vector3.new(0,3,0))end
 end
 local function joined(player)
  local ok,message=Data.load(player)
  if player.Parent~=Players then return end
  if not ok then view:FireClient(player,{Notice=message});return end
  local state=Data.get(player)
  if state and state.NPC.PendingHeal then
   Data.change(player,function(s)s.Gold=math.min(C.MaxGold,s.Gold+s.NPC.PendingHeal);s.NPC.PendingHeal=nil;return true end)
  end
  player.CharacterAdded:Connect(function(character)onCharacter(player,character)end)
  if player.Character then onCharacter(player,player.Character)end
  view:FireClient(player,{Notice=if Data.Persistent then 'Perfil NPC carregado.' else 'Prévia Studio: progresso temporário, sem persistência ou compras Robux.'})
 end
 Players.PlayerAdded:Connect(joined);Players.PlayerRemoving:Connect(Data.remove)
 for _,player in Players:GetPlayers()do task.spawn(joined,player)end
 -- A single low-frequency scheduler. Only meaningful progress writes to the profile.
 task.spawn(function()
  local visits={}
  while Service.Started do
   task.wait(2)
   for _,player in Players:GetPlayers()do
    local character=player.Character;local root=character and character:FindFirstChild('HumanoidRootPart')
    local hum=character and character:FindFirstChildOfClass('Humanoid')
    if root and hum and hum.Health>0 and Data.get(player) then
     local previous=visits[player] or {};local current={}
     for id,region in regions do
      if (root.Position-region.Position).Magnitude<region.Radius then
       current[id]=true;if previous[id] then Data.event(player,'Visit:'..id,'Exploration')end
      end
     end
     visits[player]=current
    end
    local session=Dialogue.Sessions[player]
    if session and not session.Busy and (os.clock()>session.Expires or not Dialogue.near(player,session.NPC)) then Dialogue.close(player)end
   end
   for player in visits do if player.Parent~=Players then visits[player]=nil end end
  end
 end)
 print('[NPC] Etapa 2 iniciada. Combate, conjuração, fusões e interiores de dungeon permanecem fora desta etapa.')
end
return Service
