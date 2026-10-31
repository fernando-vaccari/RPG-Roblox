-- Uses an explicitly simulated host; engine rendering/physics/network remain manual.
workspace:SetAttribute('EldravynNPCStage2',true)
local C=require(game.ReplicatedStorage.EldravynNPC.Registry)
local R=require(game.ReplicatedStorage.EldravynNPC.Rules)
local Data=require(game.ServerScriptService.EldravynNPC.NPCDataService)
local Raw=require(game.ServerScriptService.EldravynNPC.DataService)
local A=require(game.ServerScriptService.EldravynNPC.NPCActionService)
local D=require(game.ServerScriptService.EldravynNPC.DialogueService)
local Purchase=require(game.ServerScriptService.EldravynNPC.PurchaseService)
local Factory=require(game.ServerStorage.NPCInstall.R15Factory)
local passed=0
local function test(name,fn)fn();passed+=1;print('PASSOU NPC MOCK: '..name)end
local function profile(id)local player=env.createPlayer(id);assert(Data.load(player));return player,Data.get(player)end
local function mutate(p,fn)local ok,message=Data.change(p,fn);assert(ok,message);return Data.get(p)end
local p,s=profile(801)
local function state()return Data.get(p)end
local folder=Instance.new('Folder');folder.Name='EldravynNPCs';folder.Parent=workspace
local models={}
test('66 R15, 15 motores, aparências, prompts e zero geometria de mapa',function()
 assert(#C.Definitions==66)
 for _,def in C.Definitions do
  local model=Factory.create(folder,def,C.Roles[def.Role],CFrame.new(0,0,0));models[def.Id]=model;A.NPCs[def.Id]=model
  assert(model.ModelStreamingMode==Enum.ModelStreamingMode.Atomic)
  local hum=model:FindFirstChildOfClass('Humanoid');assert(hum and hum.RigType==Enum.HumanoidRigType.R15)
  local motors,body,prompts=0,0,0
  for _,n in model:GetDescendants()do
   if n:IsA('Motor6D') then motors+=1;assert(n.Part0 and n.Part1)end
   if n:IsA('BasePart') then body+=1;assert(n.CanCollide==false and n.CanQuery==false)end
   if n:IsA('ProximityPrompt') then prompts+=1;assert(n.ActionText=='Conversar' and n.MaxActivationDistance==12)end
  end
  assert(motors==15 and body>=22 and prompts==1)
 end
 assert(env.VoxelWrites==0)
end)
test('perfil novo sem sorteio racial; registro F e sem promoção automática',function()
 assert(s.Identity.Race=='' and s.Class=='' and s.Rank=='');assert(not R.promote(s,C,100))
 s=mutate(p,function(v)return R.register(v,C,100)end);assert(s.Rank=='F')
 assert(not Data.change(p,function(v)return R.register(v,C,101)end))
 s=mutate(p,function(v)v.XP=10000;return true end);assert(s.Rank=='F')
end)
test('banco conserva moedas, rejeita negativos, NaN, infinito e frações',function()
 local total=state().Gold+state().NPC.Bank
 for _,v in {-1,0,0/0,math.huge,1.5,1000000001,'100'} do assert(not Data.change(p,function(x)return R.bank(x,C,'Deposit',v)end))end
 mutate(p,function(x)return R.bank(x,C,'Deposit',50)end);assert(state().Gold==50 and state().NPC.Bank==50)
 assert(not Data.change(p,function(x)return R.bank(x,C,'Withdraw',51)end))
 mutate(p,function(x)return R.bank(x,C,'Withdraw',50)end);assert(state().Gold+state().NPC.Bank==total)
end)
test('compra, venda, propriedade e ausência de equipar/consumir',function()
 assert(not Data.change(p,function(x)return R.buy(x,C,'Longsword','Bank')end))
 assert(not Data.change(p,function(x)return R.buy(x,C,'Longsword','Weapons')end))
 mutate(p,function(x)x.Gold=500;return true end)
 mutate(p,function(x)return R.buy(x,C,'Longsword','Weapons')end);assert(state().Gold==380 and state().Inventory.Longsword==1)
 assert(not Data.change(p,function(x)return R.buy(x,C,'Longsword','Weapons')end))
 mutate(p,function(x)return R.buy(x,C,'Armor','Armor')end);assert(state().Armor=='')
 mutate(p,function(x)return R.sell(x,C,'Armor','Armor')end);assert(not state().Inventory.Armor)
 mutate(p,function(x)return R.buy(x,C,'Potion','General')end);assert(state().Inventory.Potion==1 and state().Equipment=='')
end)
test('ferreiro confirma recursos e persiste aprimoramento sem dano',function()
 assert(not Data.change(p,function(x)return R.upgrade(x,C,'Longsword')end))
 mutate(p,function(x)x.Inventory.Ore=10;return true end)
 local gold=state().Gold
 mutate(p,function(x)return R.upgrade(x,C,'Longsword')end)
 assert(state().NPC.Upgrades.Longsword==1 and state().Gold==gold-30 and state().Inventory.Ore==8)
 assert(not Data.change(p,function(x)return R.sell(x,C,'Longsword','Weapons')end))
end)
test('missões: aceitar, progresso, abandono, entrega única e rank manual',function()
 mutate(p,function(x)return R.accept(x,C,'FirstContact',100)end)
 assert(not Data.change(p,function(x)return R.claim(x,C,'FirstContact',101)end))
 assert(Data.event(p,'Talk:Guide','Interaction'));assert(not Data.event(p,'Talk:Guide','Interaction'))
 assert(Data.event(p,'Talk:Blacksmith','Interaction'));mutate(p,function(x)return R.claim(x,C,'FirstContact',102)end)
 local gold=state().Gold;assert(not Data.change(p,function(x)return R.claim(x,C,'FirstContact',103)end));assert(state().Gold==gold)
 mutate(p,function(x)return R.accept(x,C,'RuneStudy',100)end);mutate(p,function(x)return R.abandon(x,C,'RuneStudy')end)
 assert(not state().NPC.Quests.RuneStudy);mutate(p,function(x)return R.accept(x,C,'RuneStudy',100)end)
 Data.event(p,'Talk:Magic','Interaction');Data.event(p,'Talk:Races','Interaction');mutate(p,function(x)return R.claim(x,C,'RuneStudy',105)end)
 assert(state().Rank=='F');mutate(p,function(x)return R.promote(x,C,106)end);assert(state().Rank=='E')
end)
test('30 tickets e contratos exclusivos; sem entrada, consumo ou alias',function()
 local seen={};local count=0
 for key,t in C.Dungeon.Tickets do count+=1;assert(not seen[t.Quest]);seen[t.Quest]=true;assert(C.Quests[t.Quest].Ticket==key)end
 assert(count==30 and C.Dungeon.Dungeons.MalgorthDepths.Floors==10 and C.Dungeon.Dungeons.FallenSanctum.Floors==20)
 mutate(p,function(x)x.Gold=1000;return R.ticket(x,C,'MalgorthDepths:1')end)
 mutate(p,function(x)return R.ticket(x,C,'FallenSanctum:1')end)
 assert(state().NPC.Tickets['MalgorthDepths:1']==1 and state().NPC.Tickets['FallenSanctum:1']==1)
 assert(not Data.change(p,function(x)return R.ticket(x,C,'fake:1')end))
 assert(not Data.change(p,function(x)return R.admit(x,C,'MalgorthDepths:1',100)end));assert(state().NPC.Tickets['MalgorthDepths:1']==1)
 local quest=C.Dungeon.Tickets['MalgorthDepths:1'].Quest
 mutate(p,function(x)return R.accept(x,C,quest,100)end)
 for _,o in C.Quests[quest].Objectives do Data.event(p,o.Event,'Exploration')end
 mutate(p,function(x)return R.claim(x,C,quest,200)end);assert(state().NPC.Tickets['MalgorthDepths:1']==2)
 assert(not Data.change(p,function(x)return R.accept(x,C,quest,201)end))
 mutate(p,function(x)return R.accept(x,C,quest,86600)end);mutate(p,function(x)return R.abandon(x,C,quest)end)
 assert(state().NPC.Quests[quest].LastClaim==200)
end)
test('admissão futura: consumo único, destino válido e devolução única',function()
 local dungeon=C.Dungeon.Dungeons.MalgorthDepths
 -- Temporary adapter fixture, never enables a shipped dungeon.
 dungeon.EntryEnabled=true;dungeon.InteriorReady=true;dungeon.PlaceId=991003
 local count=state().NPC.Tickets['MalgorthDepths:1']
 mutate(p,function(x)return R.admit(x,C,'MalgorthDepths:1',200)end)
 local id=state().NPC.Admission.Id;assert(state().NPC.Tickets['MalgorthDepths:1']==count-1)
 assert(not Data.change(p,function(x)return R.admit(x,C,'MalgorthDepths:1',201)end))
 assert(not Data.change(p,function(x)return R.confirmArrival(x,C,id,'MalgorthDepths:2',991003)end))
 assert(not Data.change(p,function(x)return R.confirmArrival(x,C,id,'MalgorthDepths:1',991004)end))
 mutate(p,function(x)return R.refundAdmission(x,C,id)end);assert(state().NPC.Tickets['MalgorthDepths:1']==count)
 assert(not Data.change(p,function(x)return R.refundAdmission(x,C,id)end))
 mutate(p,function(x)return R.admit(x,C,'MalgorthDepths:1',203)end);id=state().NPC.Admission.Id
 mutate(p,function(x)return R.confirmArrival(x,C,id,'MalgorthDepths:1',991003)end)
 assert(not Data.change(p,function(x)return R.refundAdmission(x,C,id)end))
 dungeon.EntryEnabled=false;dungeon.InteriorReady=false;dungeon.PlaceId=0
end)
test('classes, requisitos, estudo de magia e serviços futuros',function()
 assert(not state().Identity.Classes.Invocador,'Concluir requisitos não pode evoluir classe sem escolher no mestre')
 mutate(p,function(x)return R.choose(x,C,'Mago',100)end)
 assert(state().Class=='Mago' and state().Identity.CurrentClass=='Mago')
 assert(not Data.change(p,function(x)return R.choose(x,C,'Guerreiro',101)end))
 assert(not Data.change(p,function(x)return R.evolve(x,C,'Necromante',101)end))
 mutate(p,function(x)return R.evolve(x,C,'Invocador',102)end);assert(state().Class=='Invocador' and state().Identity.Classes.Invocador)
 mutate(p,function(x)return R.magic(x,C,'LuzGuia')end)
 assert(not Data.change(p,function(x)return R.magic(x,C,'LuzGuia')end))
 assert(not Data.change(p,function(x)return R.magic(x,C,'Chama')end))
 for _,role in {'Skills','Fusions'} do local view=A.menu(p,models['Valoria_'..role],'Root');for _,o in view.Options do assert(o.Command=='Page' or o.Command=='Close')end end
 assert(state().Identity.Race=='')
end)
test('banco, rank, classe, tickets, melhorias e tutorial sobrevivem à recarga',function()
 mutate(p,function(x)return R.inn(x,C,'Valoria_Inn','Valoria',200)end)
 mutate(p,function(x)return R.tutorial(x,C,'Skip')end)
 local gold=state().Gold;local count=state().NPC.Tickets['MalgorthDepths:1']
 Data.remove(p);assert(Data.load(p));assert(state().Gold==gold and state().Rank=='E' and state().Class=='Invocador')
 assert(state().NPC.Upgrades.Longsword==1 and state().NPC.Tickets['MalgorthDepths:1']==count and state().NPC.Tutorial.Skipped and state().NPC.ReturnNPC=='Valoria_Inn')
 assert(state().Identity.Race=='')
end)
test('recibo oficial único, preço 100 e produtos desativados por padrão',function()
 assert(C.ClassChangeProduct.Id==0)
 Purchase.registerProduct('NPCClassChange',C.ClassChangeProduct,R.classReceipt);assert(not Purchase.available('NPCClassChange'))
 assert(not Purchase.prompt(p,'NPCClassChange'))
 -- Mock-only synthetic product; never serialized into a delivery/config.
 C.ClassChangeProduct.Id=991001;env.ProductInfo.PriceInRobux=99;assert(not Purchase.prompt(p,'NPCClassChange'))
 env.ProductInfo.PriceInRobux=100;assert(Purchase.prompt(p,'NPCClassChange'))
 local r={PlayerId=p.UserId,PurchaseId='NPC_TEST_RECEIPT',ProductId=991001}
 assert(Purchase.process(r)==Enum.ProductPurchaseDecision.PurchaseGranted)
 assert(Purchase.process(r)==Enum.ProductPurchaseDecision.PurchaseGranted and state().NPC.ClassCredits==1)
 mutate(p,function(x)return R.choose(x,C,'Guerreiro',300)end);assert(state().NPC.ClassCredits==0 and state().Class=='Guerreiro')
 assert(Purchase.process({PlayerId=p.UserId,PurchaseId='UNKNOWN',ProductId=991002})==Enum.ProductPurchaseDecision.NotProcessedYet)
 env.Store.FailAfterCommit=true;r.PurchaseId='NPC_RECEIPT_RESPONSE_LOST'
 assert(Purchase.process(r)==Enum.ProductPurchaseDecision.NotProcessedYet and not Data.get(p))
 Data.remove(p);assert(Data.load(p));assert(Purchase.process(r)==Enum.ProductPurchaseDecision.PurchaseGranted and state().NPC.ClassCredits==1)
 C.ClassChangeProduct.Id=0
end)
test('dois jogadores, lock concorrente e UpdateAsync repetido',function()
 local other=env.createPlayer(p.UserId);assert(not Data.load(other));Data.remove(other)
 local second,ss=profile(802);assert(ss.Gold==100 and ss.NPC.Bank==0)
 env.Store.Replay=true;mutate(p,function(x)return R.bank(x,C,'Deposit',10)end);env.Store.Replay=false
 assert(Data.get(second).Gold==100)
 env.Store.AfterCallback=function()assert(not Data.change(p,function(x)x.Gold+=100000;return true end))end
 mutate(p,function(x)return R.bank(x,C,'Withdraw',10)end)
end)
test('resposta perdida após commit congela perfil e evita duplicação',function()
 local before=state().Gold
 env.Store.FailAfterCommit=true;assert(not Data.change(p,function(x)return R.bank(x,C,'Deposit',10)end));assert(not Data.get(p))
 Data.remove(p);assert(Data.load(p));assert(state().Gold==before-10 and state().NPC.Bank==10)
end)
test('falha de armazenamento não sobrescreve com defaults',function()
 local before=state().Gold;env.Store.Fail=true;assert(not Data.change(p,function(x)return R.bank(x,C,'Deposit',1)end));assert(not Data.get(p))
 env.Store.Fail=false;Data.remove(p);assert(Data.load(p));assert(state().Gold==before)
end)
test('combate futuro só progride com adaptador servidor e evento único',function()
 local Q=require(game.ServerScriptService.EldravynNPC.QuestService)
 mutate(p,function(x)return R.accept(x,C,'FutureHunt',300)end)
 assert(not Q.combatEvent(p,'Combat:Bandit','1'));assert(not Data.event(p,'Combat:Bandit','Client'))
 Q.CombatEnabled=true;assert(Q.combatEvent(p,'Combat:Bandit','1'));assert(not Q.combatEvent(p,'Combat:Bandit','1'));Q.CombatEnabled=false
 assert(state().NPC.Quests.FutureHunt.Counts[1]==1)
end)
local function character(player)
 local m=Instance.new('Model');m.Parent=workspace;local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Position=Vector3.new(0,3,2);root.Parent=m
 local hum=Instance.new('Humanoid');hum.Health=50;hum.MaxHealth=100;hum.Parent=m;player.Character=m;return root,hum
end
local root,hum=character(p)
local view=Instance.new('RemoteEvent');local action=Instance.new('RemoteEvent');D.start(view,action)
local function send(index,token)D.Limits[p]=0;return D.handle(p,{Token=token or D.Sessions[p].Token,Choice=index})end
local function choice(command)
 for i,o in D.Sessions[p].Options do if o.Command==command then return i end end;error('Missing action '..command)
end
test('diálogo: token, distância, confirmação, rejeição de replay e preço forjado',function()
 env.RayMiss=true;D.Limits[p]=0;assert(D.open(p,models.Valoria_Bank));assert(send(choice('Page')))
 local options=D.Sessions[p].Options;local index;for i,o in options do if o.Command=='Deposit' and o.Value==10 then index=i end end
 local before=state().Gold;assert(send(index));assert(state().Gold==before)
 local token=D.Sessions[p].Token
 assert(not send(1,'forged'));D.Limits[p]=0
 assert(D.handle(p,{Token=token,Choice=1,Price=-999,Gold=1000000,Command='Grant',Value=999}));assert(state().Gold==before-10)
 assert(not send(1,token));assert(state().Gold==before-10)
 root.Position=Vector3.new(1000,3,0);assert(not send(1));assert(not D.Sessions[p]);root.Position=Vector3.new(0,3,2)
 local wall=Instance.new('Part');wall.Parent=workspace;env.RayMiss=false;env.RayTarget=wall
 D.Limits[p]=0;assert(not D.open(p,models.Valoria_Bank));env.RayTarget=nil;env.RayMiss=true
 D.Limits[p]=0;D.open(p,models.Valoria_Bank);assert(send(choice('Close')));assert(not D.Sessions[p])
end)
test('cura Humanoid compatível, cobrança única e serviço sem feridas desativado',function()
 local before=state().Gold
 local ok,msg=A.execute(p,models.Valoria_Healer,{Command='Heal'});assert(ok,msg);assert(hum.Health==100 and state().Gold==before-C.HealPrice and not state().NPC.PendingHeal)
 assert(not A.execute(p,models.Valoria_Healer,{Command='Heal'}))
 local menu=A.menu(p,models.Valoria_Healer,'Root');assert(menu.Options[1].Enabled==false)
end)
test('UI comum abre/fecha, confirma e tem alvos de toque >= 44px',function()
 local UI=require(game.ReplicatedStorage.TestNPCClient.NPCDialogueClient)
 local ui=UI.new(p.PlayerGui,action)
 ui:receive({Token='test',Name='Maelis',Title='Guilda',Text='Bem-vindo',Options={{Label='Registrar',Enabled=true},{Label='Encerrar',Enabled=true}}})
 assert(ui.Panel.Visible and #ui.Buttons==2 and ui.Buttons[1].Size.Y.Offset>=44)
 ui:choose(1);assert(env.LastRequest[1].Token=='test' and env.LastRequest[1].Choice==1)
 ui:receive({Close=true});assert(not ui.Panel.Visible)
end)
test('menus de todos os NPCs e requisitos não inicializam serviços futuros',function()
 for _,def in C.Definitions do
  local menu=A.menu(p,models[def.Id],'Root');assert(type(menu.Text)=='string' and #menu.Options>0)
  for _,o in menu.Options do if o.Command=='Page' then local sub=A.menu(p,models[def.Id],o.Value);assert(sub.Text and sub.Options)end end
 end
 assert(env.VoxelWrites==0 and state().Identity.Race=='')
end)
print('PASSOU NPC MOCK TOTAL: '..passed)
