local Upgrade=require(pkg.NPCVisualUpgrade)
local scenarios=0
local function test(name,fn)fn();scenarios+=1;print('PASSOU V2 MIGRAÇÃO: '..name)end
local oldData=game.ServerScriptService.EldravynNPC.NPCDataService;local oldDialog=game.ServerScriptService.EldravynNPC.DialogueService
local oldRules=game.ReplicatedStorage.EldravynNPC.Rules;local oldPlacement=game.ReplicatedStorage.EldravynNPC.PlacementConfig
local oldService=game.ServerScriptService.EldravynNPC.NPCService
local oldSource=oldService.Source
models.Valoria_GuildMaster:SetAttribute('NPCVisualStyle','anotação anterior preservada')
test('preflight recusa scripts customizados antes de tocar NPCs',function()
 oldService.Source..='\n-- customização local'
 local ok,err=pcall(Upgrade.Apply);assert(not ok and tostring(err):find('Script customizado'),err)
 assert(not game.ServerStorage:FindFirstChild('EldravynNPCVisualBackupV2') and models.Valoria_GuildMaster.Hair)
 oldService.Source=oldSource
end)
test('preflight recusa Animate ativo e IDs duplicados',function()
 local script=Instance.new('LocalScript');script.Name='Animate';script.Disabled=false;script.Parent=models.Valoria_GuildMaster
 assert(not pcall(Upgrade.Apply));script:Destroy()
 local copy=models.Valoria_GuildMaster:Clone();copy.Parent=npcs
 assert(not pcall(Upgrade.Apply));copy:Destroy();assert(not workspace:GetAttribute('EldravynNPCVisualVersion'))
end)
test('dependência V1 ausente aborta antes de modificar aparência',function()
 local rules=game.ReplicatedStorage.EldravynNPC.Rules;local parent=rules.Parent;rules.Parent=nil
 assert(not pcall(Upgrade.Apply));assert(models.Valoria_GuildMaster.Hair and not models.Valoria_GuildMaster:FindFirstChild('NPCV2Visuals'))
 rules.Parent=parent
end)
test('falha no meio da migração reverte visuais, sem apagar NPC',function()
 env.FailMutation=function(target,key,_)return target==models.Valoria_Weapons.Head and key=='Color'end
 local ok,err=pcall(Upgrade.Apply);assert(not ok and tostring(err):find('revertida'),err)
 for id,before in original do
  assert(models[id]==before.NPC and models[id].Hair==before.Decor and models[id].Head.Size==before.Size)
  assert(not models[id]:FindFirstChild('NPCV2Visuals') and not models[id]:GetAttribute('NPCVisualVersion'))
 end
 assert(not game.ServerStorage:FindFirstChild('EldravynNPCVisualBackupV2'))
end)
test('atualiza 66 instâncias no lugar, preservando atributos, rig, prompts e posições',function()
 assert(Upgrade.Apply().Updated==66)
 for id,before in original do
  local npc=models[id];assert(npc==before.NPC and npc.Head==before.Head and npc.PrimaryPart.CFrame==before.Root)
  assert(npc:FindFirstChildOfClass('Humanoid')==before.Humanoid and npc:FindFirstChild('NPCInteraction',true)==before.Prompt)
  for key,value in before.Attributes do assert(npc:GetAttribute(key)==value,id..' atributo '..key)end
  assert(npc:GetAttribute('NPCVisualVersion')==2 and npc.NPCV2Visuals)
 end
 assert(game.ServerScriptService.EldravynNPC.NPCDataService==oldData and game.ServerScriptService.EldravynNPC.DialogueService==oldDialog)
 assert(game.ReplicatedStorage.EldravynNPC.Rules==oldRules and game.ReplicatedStorage.EldravynNPC.PlacementConfig==oldPlacement)
 assert(sentinel.Parent==world and sentinel.Position.Z==100 and env.VoxelWrites==0)
end)
test('segunda aplicação idempotente e sem novos NPCs/controladores',function()
 local count=#npcs:GetDescendants();local serverCount=#game.ServerScriptService.EldravynNPC:GetChildren()
 assert(Upgrade.Apply().Already);assert(#npcs:GetDescendants()==count and #game.ServerScriptService.EldravynNPC:GetChildren()==serverCount)
end)
test('instalação incompleta é detectada sem recriar dependências ou NPCs',function()
 local dependency=game.StarterPlayer.StarterPlayerScripts.EldravynNPCClient.NPCAnimationController;local parent=dependency.Parent
 dependency.Parent=nil;local ok,err=pcall(Upgrade.Apply);assert(not ok and tostring(err):find('Dependência V2 ausente'),err)
 dependency.Parent=parent;assert(Upgrade.Apply().Already)
end)
test('serviços existentes operam com os mesmos modelos atualizados',function()
 local Data=require(oldData);local Rules=require(oldRules);local Registry=require(game.ReplicatedStorage.EldravynNPC.Registry)
 local player=env.createPlayer(9021);assert(Data.load(player))
 assert(Data.change(player,function(s)return Rules.register(s,Registry,100)end))
 assert(Data.change(player,function(s)return Rules.buy(s,Registry,'Ore','General')end))
 assert(Data.get(player).Gold==88 and Data.get(player).Inventory.Ore==1)
 local menu=require(game.ServerScriptService.EldravynNPC.NPCActionService).menu(player,models.Valoria_General,'Shop')
 assert(#menu.Options>0 and models.Valoria_General:GetAttribute('NPCRole')=='General')
end)
test('rollback conserva alterações externas e restaura os objetos V1 originais',function()
 models.Valoria_GuildMaster:SetAttribute('UserNote','preservar')
 local installed=game.ServerScriptService.EldravynNPC.NPCService;local current=installed.Source;installed.Source..='\n-- alteração posterior'
 assert(not pcall(Upgrade.Rollback));assert(workspace:GetAttribute('EldravynNPCVisualVersion')==2)
 installed.Source=current
 local config=game.ReplicatedStorage.EldravynNPCVisualV2.NPCVisualConfig;local previous=config.Source;config.Source..='\n-- IDs próprios'
 assert(not pcall(Upgrade.Rollback));assert(config.Parent and models.Valoria_GuildMaster.NPCV2Visuals)
 config.Source=previous;assert(Upgrade.Rollback().Restored)
 for id,before in original do
  local npc=models[id];assert(npc==before.NPC and npc.PrimaryPart.CFrame==before.Root and npc.Hair==before.Decor)
  assert(npc.Head.Size==before.Size and npc.Head.Shape==before.Shape and npc.Head.Color==before.Color)
  assert(npc.UpperTorso.Transparency==0 and npc.LeftUpperArm.Transparency==0)
  assert(not npc:FindFirstChild('NPCV2Visuals'))
 end
 assert(models.Valoria_GuildMaster:GetAttribute('UserNote')=='preservar')
 assert(models.Valoria_GuildMaster:GetAttribute('NPCVisualStyle')=='anotação anterior preservada')
 assert(game.ServerScriptService.EldravynNPC.NPCService==oldService and client.NPCInteractionClient==oldClient and not oldClient.Disabled)
 assert(not game.ReplicatedStorage:FindFirstChild('EldravynNPCVisualV2') and not workspace:GetAttribute('EldravynNPCVisualVersion'))
end)
test('reaplicação após rollback funciona; mapa e NPCs originais conservados',function()
 assert(Upgrade.Apply().Updated==66 and Upgrade.Apply().Already);assert(env.VoxelWrites==0 and #world:GetChildren()==1)
end)
print('PASSOU V2 MIGRAÇÃO TOTAL: '..scenarios)
