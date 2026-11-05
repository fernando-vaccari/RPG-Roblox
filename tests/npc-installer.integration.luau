local shared=game.ReplicatedStorage.EldravynNPC
local config=require(shared.NPCConfig);local positions=require(shared.PlacementConfig)
local install=game.ServerStorage.NPCInstall;local installer=require(install.Installer)
env.OnClone=function(old,new)if loaders[old] then loaders[new]=loaders[old]end end
local sharedCopy=shared:Clone();sharedCopy.Name='Shared';sharedCopy.Parent=install
local serverCopy=game.ServerScriptService.EldravynNPC:Clone();serverCopy.Name='Server';serverCopy.Parent=install
local clientCopy=game.ReplicatedStorage.TestNPCClient:Clone();clientCopy.Name='Client';clientCopy.Parent=install
for _,dest in {serverCopy,clientCopy}do local boot=Instance.new(if dest==serverCopy then 'Script' else 'LocalScript');boot.Name='Bootstrap';boot.Disabled=true;boot.Parent=dest end
local author=Instance.new('Folder');author.Name='Authoring';author.Parent=install
for _,module in {install.Placement,install.R15Factory}do module:Clone().Parent=author end
shared:Destroy();game.ServerScriptService.EldravynNPC:Destroy()
-- Actual anchor data from PlacementConfig, reconstructed for isolated placement tests.
local world=Instance.new('Model');world.Name='GeneratedWorld';world.Parent=workspace;world:SetAttribute('TerrainPending',false)
local function anchor(path,frame)
 local node=world;local segments=path:split('/')
 for index,name in segments do
  local c=node:FindFirstChild(name)
  if not c then c=Instance.new(if index==#segments then 'Part' else 'Folder');c.Name=name;c.Parent=node end
  node=c
 end
 node.CFrame=frame;return node
end
for _,entry in positions.NPCs do
 local offset=Vector3.new(table.unpack(entry.Offset));local p=Vector3.new(table.unpack(entry.Position));local yaw=CFrame.Angles(0,entry.Yaw,0)
 anchor(entry.Anchor,CFrame.new(p-yaw:PointToWorldSpace(offset))*yaw)
end
for _,entry in positions.Regions do anchor(entry.Anchor,CFrame.new(0,45,0))end
env.Height=function(x,z)
 local closest,dist=nil,math.huge
 for _,e in positions.NPCs do local d=(e.Position[1]-x)^2+(e.Position[3]-z)^2;if d<dist then closest=e;dist=d end end
 return closest.Position[2]-.12
end
-- A collision must abort before any destination is cloned or anything is enabled.
env.OccupiedParts=true
local obstacle=Instance.new('Part');obstacle.CanCollide=true;env.BoxParts={obstacle}
local ok,err=pcall(installer.Install);assert(not ok and tostring(err):find('Piso/obstáculo'),err);assert(not game.ReplicatedStorage:FindFirstChild('EldravynNPC'));assert(not workspace:FindFirstChild('EldravynNPCs'))
assert(env.VoxelWrites==0);print('PASSOU NPC MOCK: instalador aborta com obstáculo e preserva mapa/destinos')
env.OccupiedParts=false;env.BoxParts=nil
local legacy=require(install.R15Factory).create(world,{Id='ExistingBorin',Role='Blacksmith',City='Valoria'},config.Roles.Blacksmith,CFrame.new(100,44,0))
local report=installer.Install();assert(report.Installed==65 and #report.Skipped==1 and legacy.Parent==world)
assert(workspace:GetAttribute('EldravynNPCStage2')==true and workspace:GetAttribute('StudioSessionPreview')==true)
local count=#workspace.EldravynNPCs:GetDescendants();assert(installer.Install().Existing);assert(#workspace.EldravynNPCs:GetDescendants()==count)
print('PASSOU NPC MOCK: instalador idempotente, equivalente preservado, scripts só ativam após instalação')
-- The bootstrap waits for native Terrain completion; never invokes the generator.
world:SetAttribute('TerrainPending',true)
local service=require(game.ServerScriptService.EldravynNPC.NPCService);service.start();assert(not service.Started and env.VoxelWrites==0)
world:SetAttribute('TerrainPending',false);service.start();assert(service.Started and env.VoxelWrites==0)
local A=require(game.ServerScriptService.EldravynNPC.NPCActionService);local n=0;for _ in A.NPCs do n+=1 end;assert(n==65 and A.Locations.Valoria_GuildMaster and not A.Locations.Valoria_Ambient_Guard)
print('PASSOU NPC MOCK: inicialização de 65 NPCs instalados, terreno pendente bloqueia, nenhum combate iniciado')
-- Cleanup belongs only to test-owned installation, never the world.
workspace.EldravynNPCs:Destroy();game.ReplicatedStorage.EldravynNPC:Destroy()
local conflict=Instance.new('Folder');conflict.Name='EldravynNPC';conflict.Parent=game.ReplicatedStorage
assert(not pcall(installer.Install));assert(conflict.Parent==game.ReplicatedStorage and world.Parent==workspace)
print('PASSOU NPC MOCK: nome de destino ocupado não é sobrescrito')
