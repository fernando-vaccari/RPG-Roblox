local Shared=game.ReplicatedStorage.EldravynNPC
local C=require(Shared.Registry)
local R=require(Shared.Rules)
local Data=require(script.Parent.NPCDataService)
local Purchase=require(script.Parent.PurchaseService)
local A={Locations={},NPCs={},DungeonAdapter=nil}
local function sorted(t)local keys={};for key in t do table.insert(keys,key)end;table.sort(keys);return keys end
local function objective(event)
 local kind,id=event:match('^([^:]+):(.+)$')
 if kind=='Talk' then return 'Conversar com '..(C.Roles[id] and C.Roles[id].Title or id)
 elseif kind=='Visit' then return 'Visitar '..id
 elseif kind=='Combat' then return 'Derrotar '..(if id=='Bandit' then 'bandidos' else id)..' (combate futuro)'end
 return 'Objetivo de exploração'
end
local function money(s)return 'Moedas: '..s.Gold..' | Banco: '..s.NPC.Bank end
function A.menu(player,npc,page)
 local s=Data.get(player);if not s then return {Text='Perfil indisponível. Nenhuma operação será realizada.',Options={}} end
 local role=npc:GetAttribute('NPCRole');local words=C.Dialogue[role] or C.Dialogue.Ambient
 local result={Text=words.Greeting..'\n'..money(s),Options={}}
 local function text(v)result.Text=v..'\n'..money(s)end
 local function option(label,command,value,extra,enabled)
  table.insert(result.Options,{Label=label,Command=command,Value=value,Extra=extra,Enabled=enabled~=false})
 end
 local function menu(label,target)option(label,'Page',target)end
 local function doAction(label,command,value,extra,enabled)option(label,command,value,extra,enabled)end
 page=page or 'Root'
 if page=='Lore' then
  local lines=C.Dialogue.AmbientLines[role]
  text(words.Lore..(if lines then '\n'..table.concat(lines,'\n') else ''))
 elseif page=='History' and role=='GuildMaster' then
  local rows={'Rank: '..(if s.Rank=='' then 'não registrado' else s.Rank)}
  for _,h in s.NPC.History do table.insert(rows,h.Text..' • '..os.date('!%d/%m/%Y',h.At)) end;text(table.concat(rows,'\n'))
 elseif page=='Ranks' and role=='GuildMaster' then
  local rows={};for _,rank in C.Ranks do local q=C.RankRequirements[rank];table.insert(rows,rank..': '..q.XP..' XP, '..q.Quests..' contratos • '..q.Benefit)end
  text('Atual: '..s.Rank..' | XP: '..s.XP..' | contratos: '..s.NPC.Completed..'\n'..table.concat(rows,'\n'))
  doAction('Solicitar próxima promoção','Promote')
 elseif page:sub(1,7)=='Quests:' and role=='Reception' then
  local rank=page:sub(8);text('Contratos de rank '..rank)
  for _,id in sorted(C.Quests) do local q=C.Quests[id]
   if q.Rank==rank and not q.Ticket and (not q.SecretRegion or s.NPC.Discovered[q.SecretRegion]) then menu(q.Name,'Quest:'..id)end
  end
 elseif page:sub(1,6)=='Quest:' and (role=='Reception' or role=='Dungeon') then
  local id=page:sub(7);local q=C.Quests[id]
  if not q or q.Ticket and role=='Dungeon' and C.Dungeon.Tickets[q.Ticket].Dungeon~=npc:GetAttribute('DungeonId') then text('Contrato indisponível.')
  elseif q.SecretRegion and not s.NPC.Discovered[q.SecretRegion] then text('Contrato ainda não descoberto.')
  else
   local state=s.NPC.Quests[id];local rows={q.Name,q.Description,'Rank '..q.Rank..' | '..q.Gold..' moedas | '..q.XP..' XP'}
   for i,o in q.Objectives do table.insert(rows,objective(o.Event)..' • '..(state and state.Counts[i] or 0)..'/'..o.Need)end
   if q.Ticket then table.insert(rows,'Recompensa: 1 ticket '..C.Dungeon.Tickets[q.Ticket].Name..'. Repetição após 24h.')end
   if q.FutureCombat then table.insert(rows,'Combate futuro: só eventos de adaptador autorizado no servidor podem avançar.')end
   if state and state.LastClaim then table.insert(rows,'Última entrega: '..os.date('!%d/%m %H:%M UTC',state.LastClaim))end
   text(table.concat(rows,'\n'));doAction('Aceitar contrato','Accept',id)
   if state and state.Status=='Active' then doAction('Abandonar contrato','Abandon',id);doAction('Entregar contrato','Claim',id)end
  end
 elseif page=='Shop' and C.Shops[role] then
  text('Catálogo • '..C.Roles[role].Title..'\nCompras ficam registradas; consumíveis não produzem efeitos nesta etapa.')
  for _,id in C.Shops[role] do local item=C.Items[id]
   menu(item.Name..' • '..item.Price..' moedas • '..item.Rarity,'Item:'..id)
  end
 elseif page:sub(1,5)=='Item:' and C.Shops[role] then
  local id=page:sub(6);local item=C.Items[id]
  if item and table.find(C.Shops[role],id) then
   text(item.Name..' • '..item.Rarity..'\nRank '..item.MinRank..' | propriedade: '..(s.Inventory[id] or 0)..'\n'..(item.Note or 'Registro de propriedade; sem equipar ou atacar.'))
   doAction('Comprar por '..item.Price..' moedas','Buy',id,role)
   doAction('Vender por '..item.Sell..' moedas','Sell',id,role)
  else text('Item indisponível.')end
 elseif page=='Upgrades' and role=='Blacksmith' then
  text('Melhorias registradas, sem alterar dano ou defesa nesta etapa.')
  for _,id in sorted(C.Items) do local cost=R.upgradeCost(s,C,id)
   if cost then doAction(C.Items[id].Name..' +'..cost.Level..' → +'..(cost.Level+1)..' • '..cost.Gold..' moedas + '..cost.Ore..' minérios','Upgrade',id)
   elseif (s.NPC.Upgrades[id] or 0)>=C.Upgrade.Max then doAction(C.Items[id].Name..' +'..s.NPC.Upgrades[id]..' • nível máximo','Upgrade',id,nil,false)end
  end
 elseif page=='Bank' and role=='Bank' then
  text('Depósitos e saques são persistidos na mesma transação.')
  for _,amount in {10,50,100,500} do
   doAction('Depositar '..amount..' moedas','Deposit',amount,nil,s.Gold>=amount)
   doAction('Sacar '..amount..' moedas','Withdraw',amount,nil,s.NPC.Bank>=amount)
  end
  if s.Gold>0 then doAction('Depositar saldo: '..s.Gold,'Deposit',s.Gold)end
  if s.NPC.Bank>0 then doAction('Sacar saldo: '..s.NPC.Bank,'Withdraw',s.NPC.Bank)end
 elseif page=='Classes' and role=='Classes' then
  text('Classe atual: '..(if s.Class=='' then 'não escolhida' else s.Class)..'\nCréditos de troca: '..s.NPC.ClassCredits)
  for _,id in {'Guerreiro','Espadachim','Mago'} do
   doAction(id..': '..C.Classes[id].Text,'Choose',id,nil,s.Class=='' or s.NPC.ClassCredits>0)
  end
  doAction('Comprar crédito de troca • 100 Robux','ClassPurchase',nil,nil,Purchase.available('NPCClassChange'))
  if not Purchase.available('NPCClassChange') then result.Text..='\nCompra desativada: configure o produto oficial de 100 Robux e persistência.'end
  for _,id in sorted(C.Advanced) do local e=C.Advanced[id]
   doAction(e.Base..' → '..id..' • Rank '..e.Rank..' + '..(if e.Secret and not s.NPC.Discovered.Vespera then 'contrato secreto ainda não descoberto' else C.Quests[e.Quest].Name),'Evolve',id,nil,s.Class==e.Base and R.rank(s,C,e.Rank) and R.completed(s,e.Quest))
  end
 elseif page=='Magic' and role=='Magic' then
  text('Escolas de magia • registros de estudo, sem conjuração.')
  for _,id in sorted(C.Spells) do local m=C.Spells[id]
   doAction(m.Name..' ('..m.School..') • '..m.Text..' Rank '..m.Rank..(if m.Quest then ' + '..C.Quests[m.Quest].Name else '')..(if m.Price then ' • '..m.Price..' moedas' else '')..(if s.NPC.Magic[id] then ' • estudo registrado' else ''),'Magic',id,nil,m.RegistrationEnabled and not s.NPC.Magic[id] and R.rank(s,C,m.Rank) and R.completed(s,m.Quest))
  end
 elseif page=='Directions' and role=='Guide' then
  text('Escolha um destino existente. A marcação dura 45 segundos.')
  for _,id in sorted(A.Locations) do menu(A.Locations[id].Name,'Direction:'..id)end
 elseif page:sub(1,10)=='Direction:' and role=='Guide' then
  local id=page:sub(11);if A.Locations[id] then text(A.Locations[id].Name);option('Marcar destino','Mark',id)end
 elseif page:sub(1,7)=='Ticket:' and role=='Dungeon' then
  local key=page:sub(8);local t=C.Dungeon.Tickets[key];local d=t and C.Dungeon.Dungeons[t.Dungeon]
  if not t or t.Dungeon~=npc:GetAttribute('DungeonId') then text('Ticket indisponível.')
  else
   text(t.Name..'\nRank '..t.Rank..' | possui '..(s.NPC.Tickets[key] or 0)..' ticket(s)\n'..d.RewardPreview)
   menu('Missão para obter este ticket','Quest:'..t.Quest)
   doAction('Comprar ticket por '..t.Price..' moedas','TicketBuy',key)
   local enabled=A.DungeonAdapter~=nil and d.EntryEnabled and d.InteriorReady and d.PlaceId>0
   doAction('Solicitar entrada neste andar','Enter',key,nil,enabled)
   if not enabled then result.Text..='\nEntrada indisponível: interior/destino ainda não integrado. Tickets não serão consumidos.'end
  end
 elseif page=='Root' then
  if role=='GuildMaster' then doAction('Registrar aventureiro • rank F','Register',nil,nil,s.Rank=='');menu('Rank, requisitos e benefícios','Ranks');menu('Histórico de progressão','History')
  elseif role=='Reception' then for _,rank in C.Ranks do menu('Missões de rank '..rank,'Quests:'..rank)end
  elseif C.Shops[role] then menu('Comprar e vender','Shop')
  elseif role=='Blacksmith' then menu('Aprimorar equipamento','Upgrades')
  elseif role=='Bank' then menu('Saldo, depósito e saque','Bank')
  elseif role=='Classes' then menu('Escolha, evolução e troca de classe','Classes')
  elseif role=='Magic' then menu('Escolas e registros de estudo','Magic')
  elseif role=='Guide' then menu('Serviços e regiões','Directions')
  elseif role=='Dungeon' then
   local id=npc:GetAttribute('DungeonId');local d=C.Dungeon.Dungeons[id];text(d.Name..' • '..d.Floors..' andares\n'..words.Greeting)
   for floor=1,d.Floors do menu('Andar '..floor..' • ticket e contrato','Ticket:'..id..':'..floor)end
  elseif role=='Inn' then doAction('Hospedagem e ponto de retorno • '..C.InnPrice..' moedas','Inn')
  elseif role=='Healer' then
   local hum=player.Character and player.Character:FindFirstChildOfClass('Humanoid')
   local compatible=hum and hum.Health>0 and hum.Health<hum.MaxHealth
   doAction('Curar • '..C.HealPrice..' moedas','Heal',nil,nil,compatible==true)
   if not compatible then result.Text..='\nCura indisponível: personagem sem ferimentos ou vida incompatível.'end
  elseif role=='Tutorial' then
   local lessons={'Fale comigo para começar.','Visite Maelis na guilda.','Consulte a recepcionista.','Peça uma indicação à guia.','Tutorial concluído; contratos e exploração estão disponíveis.'}
   result.Text..='\n'..lessons[math.clamp(s.NPC.Tutorial.Step+1,1,#lessons)]..'\n'..words.Lore
   doAction('Pular tutorial','Tutorial','Skip');doAction('Revisar tutorial','Tutorial','Review')
  elseif role=='Races' then
   local race=s.Identity.Race;local catalog=require(game.ReplicatedStorage.MedievalRPG.Config.IdentityConfig)
   result.Text..='\nRaça atual: '..(catalog.Races[race] and catalog.Races[race].Name or 'ainda não registrada')..'\nEvolução: '..(if s.Identity.Evolution=='' then 'nenhuma' else s.Identity.Evolution)
   for _,id in catalog.RaceOrder do local r=catalog.Races[id];result.Text..='\n'..r.Name..': '..r.Identity..' → '..r.Evolution end
   result.Text..='\nAlteração de raça e fusão indisponíveis nesta etapa.'
  elseif role=='Skills' then
   result.Text..='\n'..words.Lore..'\nPlanejado: técnicas por classe, domínio por uso e desafios específicos. Níveis/custos aguardam definição; nenhuma técnica pode ser comprada agora.'
  elseif role=='Fusions' then
   result.Text..='\n'..words.Lore..'\nPlanejado: combinações autorizadas de habilidades ou linhagens, missões e materiais específicos. Catálogo, resultados e custos desta integração aguardam definição; nenhuma combinação está ativa.' end
  menu('Conversar sobre a região','Lore')
 else text('Esta opção não pertence ao NPC.')end
 if page~='Root' then menu('Voltar','Root')end
 option('Encerrar conversa','Close')
 return result
end
function A.execute(player,npc,option)
 local cmd,v,extra=option.Command,option.Value,option.Extra
 if cmd=='ClassPurchase' then return Purchase.prompt(player,'NPCClassChange') end
 if cmd=='Enter' then
  local t=C.Dungeon.Tickets[v];local d=t and C.Dungeon.Dungeons[t.Dungeon]
  if not d or not A.DungeonAdapter or not d.EntryEnabled or not d.InteriorReady or d.PlaceId<=0 then return false,'Destino indisponível; nenhum ticket consumido.'end
  local valid,ready=pcall(A.DungeonAdapter.ValidateDestination,d,t.Floor)
  if not valid or not ready then return false,'Destino não validado; nenhum ticket consumido.'end
  local ok,msg=Data.change(player,function(s)return R.admit(s,C,v,os.time())end)
  if not ok then return ok,msg end
  local id=Data.get(player).NPC.Admission.Id
  local started,result=pcall(A.DungeonAdapter.Enter,player,d,t.Floor,id)
  if not started or not result then return Data.change(player,function(s)return R.refundAdmission(s,C,id)end)end
  return true,'Admissão registrada; o adaptador deve confirmar a chegada no servidor.'
 end
 local hum=player.Character and player.Character:FindFirstChildOfClass('Humanoid')
 local ok,message=Data.change(player,function(s)
  local now=os.time()
  if cmd=='Register' then return R.register(s,C,now)
  elseif cmd=='Promote' then return R.promote(s,C,now)
  elseif cmd=='Accept' then return R.accept(s,C,v,now)
  elseif cmd=='Abandon' then return R.abandon(s,C,v)
  elseif cmd=='Claim' then return R.claim(s,C,v,now)
  elseif cmd=='Buy' then return R.buy(s,C,v,extra)
  elseif cmd=='Sell' then return R.sell(s,C,v,extra)
  elseif cmd=='Deposit' or cmd=='Withdraw' then return R.bank(s,C,cmd,v)
  elseif cmd=='Upgrade' then return R.upgrade(s,C,v)
  elseif cmd=='TicketBuy' then return R.ticket(s,C,v)
  elseif cmd=='Choose' then return R.choose(s,C,v,now)
  elseif cmd=='Evolve' then return R.evolve(s,C,v,now)
  elseif cmd=='Magic' then return R.magic(s,C,v)
  elseif cmd=='Tutorial' then return R.tutorial(s,C,v)
  elseif cmd=='Inn' then return R.inn(s,C,npc:GetAttribute('EldravynNPCId'),npc:GetAttribute('City'),now)
  elseif cmd=='Heal' then
   if not hum or hum.Parent~=player.Character or hum.Health<=0 or hum.Health>=hum.MaxHealth or s.Gold<C.HealPrice or s.NPC.PendingHeal then return false,'Vida incompatível, cura desnecessária ou moedas insuficientes.'end
   s.Gold-=C.HealPrice;s.NPC.PendingHeal=C.HealPrice;return true,'Serviço de cura registrado.'
  end
  return false,'Operação inválida.'
 end)
 if ok and cmd=='Heal' then
  local healed=hum and hum.Parent==player.Character and hum.Health>0
  if healed then hum.Health=hum.MaxHealth end
  local settled=Data.change(player,function(s)
   if not s.NPC.PendingHeal then return false end
   if not healed then s.Gold+=s.NPC.PendingHeal end;s.NPC.PendingHeal=nil;return true
  end)
  if not settled then return false,'Confirmação pendente; o serviço será conciliado na próxima conexão.'end
 end
 return ok,message
end
return A
