-- Pure authoritative NPC transactions. Never call this module with client prices/events.
local R={}
function R.integer(v,min,max)return type(v)=='number' and v==v and v%1==0 and v>=min and v<=max end
local function copy(v)if type(v)~='table' then return v end;local n={};for k,x in v do n[k]=copy(x)end;return n end
function R.restore(s,raw,C)
 local n=raw and raw.NPC
 if n~=nil then
  assert(type(n)=='table' and n.Version==1,'Extensão NPC incompatível; perfil preservado')
  for _,key in {'Bank','Completed','ClassCredits','AdmissionSeq'} do assert(R.integer(n[key],0,C.MaxGold),'Dado NPC inválido: '..key)end
  for _,key in {'Quests','Tickets','Upgrades','Magic','Tutorial','History','Discovered','Consumption'} do assert(type(n[key])=='table','Tabela NPC inválida: '..key)end
  s.NPC=copy(n)
 else s.NPC={Version=1,Bank=0,Completed=0,ClassCredits=0,AdmissionSeq=0,Quests={},Tickets={},Upgrades={},Magic={},Tutorial={Step=0,Skipped=false},History={},Discovered={},Consumption={}} end
 assert(R.integer(s.NPC.Tutorial.Step,0,4) and type(s.NPC.Tutorial.Skipped)=='boolean','Tutorial inválido')
 assert(s.NPC.PendingHeal==nil or s.NPC.PendingHeal==C.HealPrice,'Cura pendente inválida')
 for id,value in s.NPC.Magic do assert(C.Spells[id] and value==true,'Registro de magia inválido')end
 for key,value in s.NPC.Tickets do assert(C.Dungeon.Tickets[key] and R.integer(value,0,C.MaxStack),'Ticket persistido inválido')end
 for key,value in s.NPC.Upgrades do assert(C.Items[key] and R.integer(value,0,C.Upgrade.Max),'Melhoria persistida inválida')end
 for key,q in s.NPC.Quests do
  assert(C.Quests[key] and type(q)=='table' and type(q.Counts)=='table' and (q.Status=='Active' or q.Status=='Claimed'),'Missão NPC inválida')
  for i,o in C.Quests[key].Objectives do assert(R.integer(q.Counts[i],0,o.Need),'Contagem inválida')end
  assert(q.LastClaim==nil or R.integer(q.LastClaim,0,100000000000),'Data de missão inválida')
 end
 if raw then
  if table.find(C.Ranks,raw.Rank) then s.Rank=raw.Rank end
  if C.Classes[raw.Class] or C.Advanced[raw.Class] then s.Class=raw.Class end
  -- NPC class evolution uses its own completed-contract proof, not combat challenges.
  for id,e in C.Advanced do
   local q=s.NPC.Quests[e.Quest]
   if raw.Identity and raw.Identity.Classes and raw.Identity.Classes[id]==true and q and q.Status=='Claimed' and R.rank(s,C,e.Rank) then s.Identity.Classes[id]=true end
  end
  s.Identity.CurrentClass=s.Class
 end
 return s
end
function R.rank(s,C,needed)return (table.find(C.Ranks,s.Rank) or 0)>=(table.find(C.Ranks,needed) or 99)end
function R.completed(s,id)local q=s.NPC.Quests[id];return q~=nil and q.Status=='Claimed' end
local function history(s,text,now)
 table.insert(s.NPC.History,{Text=text,At=now});if #s.NPC.History>32 then table.remove(s.NPC.History,1)end
end
function R.register(s,C,now)
 if s.Rank~='' then return false,'Registro já existente.' end
 s.Rank='F';history(s,'Registro no rank F',now);return true,'Registro concluído: rank F.'
end
function R.promote(s,C,now)
 local index=table.find(C.Ranks,s.Rank)
 if not index or index==#C.Ranks then return false,'Registro necessário ou rank máximo atingido.' end
 local rank=C.Ranks[index+1];local req=C.RankRequirements[rank]
 if s.XP<req.XP or s.NPC.Completed<req.Quests then return false,'Requisitos de promoção ainda não cumpridos.' end
 s.Rank=rank;history(s,'Promoção para '..rank,now);return true,'Promovido ao rank '..rank..'.'
end
function R.accept(s,C,id,now)
 local q=C.Quests[id];local old=s.NPC.Quests[id]
 if not q or not R.rank(s,C,q.Rank) then return false,'Missão ou rank indisponível.' end
 if q.SecretRegion and not s.NPC.Discovered[q.SecretRegion] then return false,'Contrato ainda não descoberto.' end
 if old and (old.Status=='Active' or not q.Cooldown or now<(old.LastClaim or 0)+q.Cooldown) then return false,'Contrato ativo, concluído ou em espera.' end
 local counts={};for _ in q.Objectives do table.insert(counts,0)end
 s.NPC.Quests[id]={Status='Active',Counts=counts,LastClaim=old and old.LastClaim};return true,'Missão aceita. Os objetivos começam agora.'
end
function R.abandon(s,_,id)
 local q=s.NPC.Quests[id]
 if not q or q.Status~='Active' then return false,'Missão não está ativa.' end
 -- Keep the previous claim timestamp for repeatable ticket contracts.
 if q.LastClaim then q.Status='Claimed' else s.NPC.Quests[id]=nil end
 return true,'Missão abandonada.'
end
function R.event(s,C,event,source)
 if type(event)~='string' then return false end
 if string.sub(event,1,7)=='Combat:' and source~='CombatAdapter' then return false end
 local changed=false
 local region=string.match(event,'^Visit:(.+)$')
 if region and not s.NPC.Discovered[region] then s.NPC.Discovered[region]=true;changed=true end
 for id,state in s.NPC.Quests do
  local q=C.Quests[id]
  if q and state.Status=='Active' then for i,o in q.Objectives do
   if o.Event==event and state.Counts[i]<o.Need then state.Counts[i]+=1;changed=true end
  end end
 end
 local t=s.NPC.Tutorial
 local target=({[0]='Talk:Tutorial',[1]='Talk:GuildMaster',[2]='Talk:Reception',[3]='Talk:Guide'})[t.Step]
 if not t.Skipped and event==target then t.Step+=1;changed=true end
 return changed
end
function R.claim(s,C,id,now)
 local q,state=C.Quests[id],s.NPC.Quests[id]
 if not q or not state or state.Status~='Active' then return false,'Contrato não está ativo ou recompensa já entregue.' end
 for i,o in q.Objectives do if state.Counts[i]<o.Need then return false,'Objetivos pendentes.' end end
 if q.Ticket and (s.NPC.Tickets[q.Ticket] or 0)>=C.MaxStack then return false,'Limite de tickets; nenhuma recompensa consumida.' end
 if s.Gold+q.Gold>C.MaxGold or s.XP+q.XP>C.MaxGold or s.NPC.Completed>=C.MaxGold then return false,'Limite de saldo; recompensa preservada.' end
 state.Status='Claimed';state.LastClaim=now;s.Gold+=q.Gold;s.XP+=q.XP;s.NPC.Completed+=1
 if q.Ticket then s.NPC.Tickets[q.Ticket]=(s.NPC.Tickets[q.Ticket] or 0)+1 end
 return true,'Contrato concluído; recompensa registrada.'
end
function R.buy(s,C,id,role)
 local item=C.Items[id]
 if not item or not table.find(C.Shops[role] or {},id) then return false,'Item não vendido por este NPC.' end
 if not R.rank(s,C,item.MinRank) then return false,'Rank insuficiente.' end
 local count=s.Inventory[id] or 0;local limit=if item.Kind=='Weapon' or item.Kind=='Armor' then 1 else C.MaxStack
 if count>=limit or s.Gold<item.Price then return false,'Saldo insuficiente ou limite de propriedade atingido.' end
 s.Gold-=item.Price;s.Inventory[id]=count+1;return true,'Compra registrada. Nenhum ataque ou efeito foi ativado.'
end
function R.sell(s,C,id,role)
 local item=C.Items[id]
 if not item or not table.find(C.Shops[role] or {},id) or not item.Sell or (s.Inventory[id] or 0)<1 then return false,'Item indisponível para venda.' end
 if s.Equipment==id or s.Armor==id then return false,'Item equipado no sistema anterior; venda bloqueada.' end
 if (s.NPC.Upgrades[id] or 0)>0 then return false,'Peça aprimorada preservada; venda indisponível.' end
 if s.Gold+item.Sell>C.MaxGold then return false,'Saldo máximo atingido.' end
 s.Inventory[id]-=1;if s.Inventory[id]==0 then s.Inventory[id]=nil end;s.Gold+=item.Sell;return true,'Venda registrada.'
end
function R.bank(s,C,direction,amount)
 if not R.integer(amount,1,C.MaxGold) then return false,'Valor inválido.' end
 if direction=='Deposit' and s.Gold>=amount and s.NPC.Bank+amount<=C.MaxGold then s.Gold-=amount;s.NPC.Bank+=amount
 elseif direction=='Withdraw' and s.NPC.Bank>=amount and s.Gold+amount<=C.MaxGold then s.NPC.Bank-=amount;s.Gold+=amount
 else return false,'Saldo insuficiente ou limite excedido.' end
 return true,'Operação bancária registrada.'
end
function R.upgradeCost(s,C,id)
 local item=C.Items[id];local level=s.NPC.Upgrades[id] or 0
 if not item or (item.Kind~='Weapon' and item.Kind~='Armor') or (s.Inventory[id] or 0)<1 or level>=C.Upgrade.Max then return nil end
 return {Level=level,Gold=(level+1)*C.Upgrade.GoldPerLevel,Ore=(level+1)*C.Upgrade.OrePerLevel}
end
function R.upgrade(s,C,id)
 local cost=R.upgradeCost(s,C,id)
 if not cost or s.Gold<cost.Gold or (s.Inventory.Ore or 0)<cost.Ore then return false,'Peça, nível ou recursos insuficientes.' end
 s.Gold-=cost.Gold;s.Inventory.Ore-=cost.Ore;if s.Inventory.Ore==0 then s.Inventory.Ore=nil end
 s.NPC.Upgrades[id]=cost.Level+1;return true,'Aprimoramento +'..(cost.Level+1)..' registrado; cálculo de combate não é ativado.'
end
function R.ticket(s,C,key)
 local t=C.Dungeon.Tickets[key]
 if not t or not R.rank(s,C,t.Rank) then return false,'Ticket ou rank inválido.' end
 if s.Gold<t.Price or (s.NPC.Tickets[key] or 0)>=C.MaxStack then return false,'Saldo insuficiente ou limite de tickets.' end
 s.Gold-=t.Price;s.NPC.Tickets[key]=(s.NPC.Tickets[key] or 0)+1;return true,'Ticket específico comprado.'
end
function R.admit(s,C,key,now)
 local t=C.Dungeon.Tickets[key];local d=t and C.Dungeon.Dungeons[t.Dungeon]
 if not d or not d.EntryEnabled or not d.InteriorReady or not R.integer(d.PlaceId,1,9007199254740991) then return false,'Interior/destino não habilitado; nenhum ticket consumido.' end
 if not R.rank(s,C,t.Rank) or (s.NPC.Tickets[key] or 0)<1 or s.NPC.Admission and s.NPC.Admission.Status=='Pending' then return false,'Rank, ticket ou entrada pendente inválidos.' end
 s.NPC.Tickets[key]-=1;s.NPC.AdmissionSeq+=1
 s.NPC.Admission={Id=s.NPC.AdmissionSeq,Ticket=key,At=now,Status='Pending'}
 s.NPC.Consumption[key]=(s.NPC.Consumption[key] or 0)+1
 return true,'Ticket consumido e admissão registrada.'
end
function R.confirmArrival(s,C,id,key,placeId)
 local a=s.NPC.Admission;local t=C.Dungeon.Tickets[key];local d=t and C.Dungeon.Dungeons[t.Dungeon]
 if not a or a.Id~=id or a.Ticket~=key or a.Status~='Pending' or not d or not d.EntryEnabled or not d.InteriorReady or not R.integer(placeId,1,9007199254740991) or d.PlaceId~=placeId then return false,'Admissão/destino não autorizado.' end
 a.Status='Arrived';return true,'Chegada confirmada pelo adaptador do servidor.'
end
function R.refundAdmission(s,C,id)
 local a=s.NPC.Admission
 if not a or a.Id~=id or a.Status~='Pending' then return false,'Admissão já finalizada.' end
 if (s.NPC.Tickets[a.Ticket] or 0)>=C.MaxStack then return false,'Limite impede devolução automática; admissão preservada.' end
 s.NPC.Tickets[a.Ticket]=(s.NPC.Tickets[a.Ticket] or 0)+1;a.Status='Refunded'
 return true,'Teleporte não iniciado; ticket devolvido uma única vez.'
end
function R.choose(s,C,id,now)
 if not C.Classes[id] or C.Classes[id].Legacy then return false,'Classe inicial inválida.' end
 if s.Class~='' then
  if s.Class==id or s.NPC.ClassCredits<1 then return false,'Classe já escolhida. Uma troca exige crédito oficial.' end
  s.NPC.ClassCredits-=1
 end
 s.Class=id;s.Identity.CurrentClass=id;s.Identity.Classes[id]=true;history(s,'Classe escolhida: '..id,now)
 return true,'Classe registrada; habilidades não foram ativadas.'
end
function R.evolve(s,C,id,now)
 local e=C.Advanced[id]
 if not e or s.Class~=e.Base or not R.rank(s,C,e.Rank) or not R.completed(s,e.Quest) then return false,'Evolução exige classe, rank e missão específicos.' end
 s.Class=id;s.Identity.CurrentClass=id;s.Identity.Classes[id]=true;history(s,'Evolução de classe: '..id,now);return true,'Evolução de classe registrada.'
end
function R.magic(s,C,id)
 local m=C.Spells[id]
 if not m or not m.RegistrationEnabled then return false,'Estudo indisponível nesta atualização.' end
 if s.NPC.Magic[id] or not R.rank(s,C,m.Rank) or not R.completed(s,m.Quest) or s.Gold<m.Price then return false,'Registro existente ou requisitos pendentes.' end
 s.Gold-=m.Price;s.NPC.Magic[id]=true;return true,'Estudo registrado. Conjuração permanece indisponível.'
end
function R.classReceipt(s,receipt)
 if s.Identity.Receipts[receipt] then return true,'Recibo já registrado.' end
 local count=0;for _ in s.Identity.Receipts do count+=1 end
 if count>=1024 or s.NPC.ClassCredits>=1000000 then return false,'Histórico requer manutenção; recibo permanece pendente.' end
 s.Identity.Receipts[receipt]=true;s.NPC.ClassCredits+=1;return true,'Crédito de troca recebido.'
end
function R.inn(s,C,npcId,city,now)
 if s.Gold<C.InnPrice then return false,'Moedas insuficientes.' end
 s.Gold-=C.InnPrice;s.NPC.ReturnNPC=npcId;s.NPC.RestAt=now;s.Spawn=city;return true,'Hospedagem registrada; retorno definido nesta estalagem.'
end
function R.tutorial(s,_,mode)
 if mode=='Skip' then s.NPC.Tutorial.Skipped=true
 elseif mode=='Review' then s.NPC.Tutorial.Skipped=false;s.NPC.Tutorial.Step=0
 else return false,'Opção inválida.' end
 return true,'Tutorial atualizado.'
end
return R
