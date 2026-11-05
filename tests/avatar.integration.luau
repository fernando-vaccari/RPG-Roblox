local passed=0
local function test(name,fn)fn();passed+=1;print('PASSOU AVATAR MOCK: '..name)end
local originals={};for id,npc in models do originals[id]={NPC=npc,Root=npc.PrimaryPart.CFrame,Head=npc.Head,Size=npc.Head.Size,Hum=npc:FindFirstChildOfClass('Humanoid'),Prompt=npc:FindFirstChild('NPCInteraction',true),Visuals=npc:FindFirstChild('NPCV2Visuals')}end
local enemyBefore=actualEnemy
test('sem FBX registrado, aplicação aborta sem trocar NPC/mapa',function()
 local ok,err=pcall(Art.Apply);assert(not ok and tostring(err):find('Falta importar/registrar'),err)
 assert(not game.ServerStorage:FindFirstChild('EldravynAvatarBackupV3')and sentinel.Parent==world)
end)
test('importação rejeita código e assets não publicados sem mutação',function()
 local f=importedGroup('Valoria');local injected=Instance.new('Script');injected.Parent=f
 assert(not pcall(Register.Apply,f));injected:Destroy()
 local p;for _,n in f:GetChildren()do if n:IsA('MeshPart')and n.MeshId~=''then p=n;break end end
 local id=p.MeshId;p.MeshId='rbxtemp://not-published';assert(not pcall(Register.Apply,f));p.MeshId=id
 assert(not avatar:FindFirstChild('ImportedTemplates'));f:Destroy()
end)
test('FBX de outra revisão é rejeitado antes de registrar modelos',function()
 local f=importedGroup('Valoria');f:FindFirstChild('ELDRAVYN_ART_'..Catalog.ArtRevision:gsub('%W','_')):Destroy()
 assert(not pcall(Register.Apply,f)and not avatar:FindFirstChild('ImportedTemplates'));f:Destroy()
end)
test('quatro grupos: 80 modelos normalizados por escala/rotação; fontes intactas',function()
 local total=0
 for _,group in {'Valoria','North','South','Dungeons'}do
  local f=importedGroup(group);local before=#f:GetDescendants();total+=Register.Apply(f).Registered;assert(#f:GetDescendants()==before)
  assert(not pcall(Register.Apply,f));f:Destroy()
 end
 assert(total==80 and #avatar.ImportedTemplates:GetChildren()==80)
 local head=avatar.ImportedTemplates.NPC_Valoria_GuildMaster.Head;near(head.Position.Y,5.25);near(head.Size.X,.8);near(head.CFrame.R[1],1)
 assert(#Register.Report().Missing==0)
end)
test('falha injetada cancela e reverte a migração',function()
 env.FailMutation=function(target,key,_)return target==models.Valoria_Weapons.Head and key=='Transparency'end
 local ok,err=pcall(Art.Apply);assert(not ok and tostring(err):find('revert'),err)
 assert(not workspace:GetAttribute('EldravynAvatarArtVersion'))
 for id,before in originals do assert(models[id]==before.NPC and models[id].PrimaryPart.CFrame==before.Root and models[id].Head==before.Head)end
end)
test('aplica meshes nas mesmas 66 instâncias e conserva serviços/identidade',function()
 models.Valoria_GuildMaster.Head.CFrame*=CFrame.Angles(.15,0,0)
 local result=Art.Apply();assert(result.Updated==66 and result.EnemyModels==14)
 for id,before in originals do
  local npc=models[id];assert(npc==before.NPC and npc.PrimaryPart.CFrame==before.Root and npc.Head==before.Head and npc.Head.Size==before.Size)
  assert(npc:FindFirstChildOfClass('Humanoid')==before.Hum and npc:FindFirstChild('NPCInteraction',true)==before.Prompt)
  assert(npc:GetAttribute('EldravynNPCId')==id and npc:GetAttribute('AvatarArtVersion')==3 and npc.Head.Transparency==1)
  local meshes=0;for _,p in npc.NPCV2Visuals:GetChildren()do assert(p:IsA('MeshPart')and not p.CanCollide and not p.CanQuery);meshes+=1 end;assert(meshes==15)
  if id=='Valoria_GuildMaster'then near(npc.NPCV2Visuals.Avatar_Head.CFrame.R[5],npc.Head.CFrame.R[5])end
 end
 assert(require(avatar.CoreV2.Runtime.Shared.NPCConfig or game.ReplicatedStorage.EldravynNPC.NPCConfig))
 assert(sentinel.Parent==world and env.VoxelWrites==0)
end)
test('reaplicação idempotente e EnemyService original guardado',function()
 local count=#npcs:GetDescendants();assert(Art.Apply().Already and #npcs:GetDescendants()==count)
 workspace:SetAttribute('EldravynAvatarRevision',nil);assert(not pcall(Art.Apply));assert(#npcs:GetDescendants()==count);workspace:SetAttribute('EldravynAvatarRevision',Catalog.ArtRevision)
 assert(enemyBefore.Parent~=game.ServerScriptService.MedievalServer.Services)
 assert(game.ServerStorage.EldravynEnemyAvatarLibrary:GetAttribute('Ready'))
 local shared=game.ReplicatedStorage.EldravynAvatarShared;shared.Parent=nil;assert(not pcall(Art.Apply));shared.Parent=game.ReplicatedStorage
end)
local enemyModels={}
test('14 inimigos: rigs, meshes, tags e consultas de dano, sem novos spawns/loot',function()
 local library=game.ServerStorage.EldravynEnemyAvatarLibrary;local factory=require(library.Factory);local count=0
 for kind,key in Catalog.Enemies do
  local model,hum,root=factory.create(workspace,kind,Vector3.new(count*5,0,-15),Color3.new(1,1,1),true,kind)
  assert(hum.RigType==Enum.HumanoidRigType.R15 and root==model.PrimaryPart and not root.Anchored)
  assert(not model:GetAttribute('EldravynNPCId')and not model:FindFirstChild('NPCInteraction',true))
  assert(model:GetAttribute('AvatarEnemyKind')==kind and #model.AvatarEnemyVisuals:GetChildren()==#Catalog.Models[key].Bones)
  for _,p in model.AvatarEnemyVisuals:GetChildren()do assert(p:IsA('MeshPart')and p.CanQuery and not p.CanCollide)end
  table.insert(enemyModels,model);count+=1
 end
 assert(count==14 and env.VoxelWrites==0 and #world:GetChildren()==1)
end)
local player
test('EnemyService real usa o factory opcional e conserva vida/dano configurados',function()
 env.Height=function()return 0 end
 player=env.createPlayer(88001);local char=Instance.new('Model');char.Parent=workspace
 local r=Instance.new('Part');r.Name='HumanoidRootPart';r.CFrame=CFrame.new(0,3,0);r.Parent=char
 local h=Instance.new('Humanoid');h.Health=100;h.Parent=char;player.Character=char;game.Players.LocalPlayer=player
 local scope=Instance.new('Folder');scope.Name='IsolatedEnemyTest';scope.Parent=workspace
 local spawns=Instance.new('Folder');spawns.Name='EnemySpawns';spawns.Parent=scope
 local marker=Instance.new('Part');marker.Name='TestDemon';marker.Position=Vector3.new(0,0,-6);marker:SetAttribute('EnemyKind','Demon');marker.Parent=spawns
 local E=require(game.ServerScriptService.MedievalServer.Services.EnemyService);E.scan(scope);E.step()
 local current=E.Spawns[1].Enemy;assert(current and current.Model:FindFirstChild('AvatarEnemyVisuals'))
 local def=require(game.ReplicatedStorage.MedievalRPG.Config.ContentConfig).Enemies.Demon
 assert(current.Hum.MaxHealth==def.Health and current.Damage==def.Damage and current.Hum.WalkSpeed==def.Speed)
 assert(not E.damage(current.Model,player,0/0)and E.damage(current.Model,player,9)and current.Hum.Health==def.Health-9)
 game:GetService('CollectionService'):RemoveTag(current.Model,'EldravynAvatarEnemy');E.clearScope(scope);scope:Destroy();assert(not next(E.Active))
end)
test('cliente limita animação a dez inimigos e libera tags/conexões',function()
 local controller=require(game.StarterPlayer.StarterPlayerScripts.EldravynAvatarClient.EnemyAnimationClient).start()
 assert(controller==require(game.StarterPlayer.StarterPlayerScripts.EldravynAvatarClient.EnemyAnimationClient).start())
 local count=0;for _ in controller.Selected do count+=1 end;assert(count==10)
 for i=1,180 do controller:step(1/60,300+i/60)end
 local first=enemyModels[1];assert(controller.Entries[first]);game:GetService('CollectionService'):RemoveTag(first,'EldravynAvatarEnemy');assert(not controller.Entries[first])
 local conns=table.clone(controller.Connections);controller:destroy();for _,c in conns do assert(not c.Connected)end
end)
test('rollback restaura a versão anterior e mantém modelos/NPCs existentes',function()
 local custom=game.ServerStorage.EldravynEnemyAvatarLibrary.Factory;local old=custom.Source;custom.Source..='\n-- customização posterior'
 assert(not pcall(Art.Rollback));assert(models.Valoria_GuildMaster:GetAttribute('AvatarArtVersion')==3);custom.Source=old
 assert(Art.Rollback().Restored)
 for id,before in originals do
  local npc=models[id];assert(npc==before.NPC and npc.PrimaryPart.CFrame==before.Root and npc.Head.Size==before.Size and not npc:GetAttribute('AvatarArtVersion'))
  if START_WITH_V2 then assert(npc.NPCV2Visuals==before.Visuals and not npc.NPCV2Visuals:GetChildren()[1]:IsA('MeshPart'))else assert(not npc:FindFirstChild('NPCV2Visuals'))end
 end
 assert(game.ServerScriptService.MedievalServer.Services.EnemyService==enemyBefore)
 assert(not game.ServerStorage:FindFirstChild('EldravynEnemyAvatarLibrary')and not game.ReplicatedStorage:FindFirstChild('EldravynAvatarShared'))
 for _,model in enemyModels do assert(model.Parent==workspace)end
 assert(env.VoxelWrites==0 and sentinel.Parent==world)
end)
print('PASSOU AVATAR MOCK TOTAL: '..passed..' ('..(if START_WITH_V2 then'base V2'else'base Stage 2')..'; sem Roblox Studio, uploads ou assets reais)')
