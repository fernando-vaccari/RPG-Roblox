-- Núcleo puro, relógio e sorteio injetados pelo servidor. Nenhuma dependência do engine.
local I={}
local function int(v,min,max) return type(v)=='number' and v==v and v%1==0 and v>=min and v<=max end
function I.validate(c)
 local total=0;local seen={}
 for _,id in c.RaceOrder do local r=c.Races[id];assert(r and not seen[id] and int(r.Weight,1,100));seen[id]=true;total+=r.Weight end
 assert(total==100,'Probabilidades raciais devem somar exatamente 100')
 local products={}
 for _,p in c.Products do assert(int(p.Id,0,1e15) and int(p.Amount,1,100));if p.Id>0 then assert(not products[p.Id],'ID de produto duplicado');products[p.Id]=true end end
 for _,a in c.Advanced do assert(table.find(c.PrimaryClasses,a.Base) and a.Level>=1 and #a.Steps>0) end
 return true
end
function I.pick(c,ticket)
 assert(int(ticket,1,100),'Ticket fora de 1..100');local bound=0
 for _,id in c.RaceOrder do bound+=c.Races[id].Weight;if ticket<=bound then return id end end
 error('Probabilidades inválidas')
end
function I.new()
 return {Version=1,Race='',Evolution='',Classes={},Discoveries={},Challenges={},Racial={Status='Idle',Counts={},ReadyAt=0,Deadline=0},Fusion={Week=0,FreeUsed=0,Basic=0,Premium=0},Fragments=0,RetryCredits=0,Receipts={}}
end
local function stepsDone(steps,counts)
 for i,step in steps do if (counts[tostring(i)] or 0)<step.Count then return false end end;return true
end
local function cleanCounts(steps,raw)
 local counts={}
 if type(raw)=='table' then for i,step in steps do local v=raw[tostring(i)];counts[tostring(i)]=if int(v,0,step.Count) then v else 0 end end
 return counts
end
function I.restore(profile,raw,c)
 local out=I.new();raw=if type(raw)=='table' then raw else {}
 if raw.Race~=nil and raw.Race~='' then assert(c.Races[raw.Race],'Raça persistida inválida; não sortear novamente');out.Race=raw.Race end
 for _,key in {'Fragments','RetryCredits'} do if int(raw[key],0,1000000) then out[key]=raw[key] end end
 for id in c.Secrets do if type(raw.Discoveries)=='table' and raw.Discoveries[id]==true then out.Discoveries[id]=true end end
 if type(raw.Receipts)=='table' then
  for id,v in raw.Receipts do if type(id)=='string' and #id<=200 and v==true then out.Receipts[id]=true end end
 end
 local f=raw.Fusion
 if type(f)=='table' then for key,max in {Week=1000000,FreeUsed=c.Fusion.WeeklyFree,Basic=1000000,Premium=1000000} do if int(f[key],0,max) then out.Fusion[key]=f[key] end end end
 -- Base classes saved by the old system remain unlocked; advanced classes need challenge proof.
 for _,id in {'Guerreiro','Espadachim','Mago','Arqueiro'} do
  if profile.Class==id or type(raw.Classes)=='table' and raw.Classes[id]==true then out.Classes[id]=true end
 end
 for id,def in c.Advanced do
  local v=type(raw.Challenges)=='table' and raw.Challenges[id]
  if type(v)=='table' then
   local counts=cleanCounts(def.Steps,v.Counts)
   local completed=v.Status=='Complete' and stepsDone(def.Steps,counts)
   out.Challenges[id]={Status=if completed then 'Complete' elseif v.Status=='Active' then 'Active' else 'Idle',Counts=counts}
   if completed then out.Classes[id]=true;out.Classes[def.Base]=true end
  end
 end
 local race=c.Races[out.Race];local rq=raw.Racial
 if race and type(rq)=='table' then
  out.Racial.Counts=cleanCounts(race.Steps,rq.Counts)
  if int(rq.ReadyAt,0,1e12) then out.Racial.ReadyAt=rq.ReadyAt end
  if int(rq.Deadline,0,1e12) then out.Racial.Deadline=rq.Deadline end
  if rq.Status=='Complete' and stepsDone(race.Steps,out.Racial.Counts) then out.Racial.Status='Complete'
  elseif rq.Status=='Active' or rq.Status=='Failed' then out.Racial.Status=rq.Status end
  if out.Racial.Status=='Complete' and raw.Evolution==race.Evolution then out.Evolution=race.Evolution end
 end
 profile.Identity=out
 if type(raw.CurrentClass)=='string' and out.Classes[raw.CurrentClass] then profile.Class=raw.CurrentClass end
 out.CurrentClass=profile.Class
 return out
end
function I.assign(profile,c,ticket)
 local s=profile.Identity
 if s.Race~='' then assert(c.Races[s.Race]);return s.Race,false end
 s.Race=I.pick(c,ticket);return s.Race,true
end
function I.week(now) return math.floor((now+3*86400)/604800) end -- Monday 00:00 UTC
function I.refresh(profile,c,now)
 local s=profile.Identity;local week=I.week(now)
 if week>s.Fusion.Week then s.Fusion.Week=week;s.Fusion.FreeUsed=0 end
 if s.Racial.Status=='Active' and now>=s.Racial.Deadline then I.fail(profile,c,s.Racial.Deadline) end
end
function I.fail(profile,c,now)
 local q=profile.Identity.Racial
 if q.Status~='Active' then return false end
 q.Status='Failed';q.ReadyAt=now+c.RetrySeconds;q.Deadline=0;return true
end
function I.startRacial(profile,c,level,now)
 local s=profile.Identity;I.refresh(profile,c,now);local r=c.Races[s.Race]
 if not r or s.Evolution~='' or s.Racial.Status=='Active' or s.Racial.Status=='Complete' then return false,'Missão racial indisponível.' end
 if profile.Rank=='' or level<c.RacialLevel or r.Secret and not s.Discoveries[r.Secret] then return false,'Faltam nível, registro ou descoberta racial.' end
 if now<s.Racial.ReadyAt then
  if s.RetryCredits<1 then return false,'Aguarde 24 horas ou use um crédito de nova tentativa.' end
  s.RetryCredits-=1
 end
 s.Racial={Status='Active',Counts={},ReadyAt=0,Deadline=now+c.RacialDuration};return true,'Missão racial iniciada. Morte ou prazo encerrado causa falha.'
end
function I.startClass(profile,c,id,level)
 local def=c.Advanced[id];local s=profile.Identity
 if not def or not s.Classes[def.Base] or level<def.Level or def.Secret and not s.Discoveries[def.Secret] then return false,'Requisitos de classe/desafio não cumpridos.' end
 if s.Challenges[id] and s.Challenges[id].Status~='Idle' then return false,'Desafio já iniciado/concluído.' end
 s.Challenges[id]={Status='Active',Counts={}};return true,'Desafio de classe iniciado.'
end
local function advance(steps,q,event)
 local changed=false
 if not q or q.Status~='Active' then return false end
 for i,step in steps do
  local key=tostring(i);local before=q.Counts[key] or 0
  if step.Event==event then q.Counts[key]=math.min(step.Count,before+1);changed=changed or q.Counts[key]~=before end
 end
 return changed
end
function I.event(profile,c,event,now)
 I.refresh(profile,c,now);local s=profile.Identity;local changed=false
 local r=c.Races[s.Race];if r then changed=advance(r.Steps,s.Racial,event) end
 for id,def in c.Advanced do changed=advance(def.Steps,s.Challenges[id],event) or changed end
 return changed
end
function I.claimRacial(profile,c,now)
 I.refresh(profile,c,now);local s=profile.Identity;local r=c.Races[s.Race]
 if not r or s.Racial.Status~='Active' or not stepsDone(r.Steps,s.Racial.Counts) then return false,'Complete o desafio racial obrigatório.' end
 if s.Fragments<c.EvolutionFragments then return false,'Faltam fragmentos de dungeon; eles não substituem a missão.' end
 s.Fragments-=c.EvolutionFragments;s.Racial.Status='Complete';s.Racial.Deadline=0;s.Evolution=r.Evolution
 return true,'Evolução racial conquistada.'
end
function I.claimClass(profile,c,id)
 local s=profile.Identity;local def=c.Advanced[id];local q=s.Challenges[id]
 if not def or not q or q.Status~='Active' or not stepsDone(def.Steps,q.Counts) then return false,'Desafio ainda incompleto.' end
 q.Status='Complete';s.Classes[id]=true;return true,'Classe avançada desbloqueada.'
end
function I.selectClass(profile,c,id)
 local s=profile.Identity
 if profile.Class==id then return false,'Classe já está ativa.' end
 if not s.Classes[id] then return false,'Classe bloqueada.' end
 profile.Class=id;s.CurrentClass=id;return true,'Classe selecionada; equipe a arma correspondente.'
end
function I.discover(profile,c,id)
 if not c.Secrets[id] or profile.Identity.Discoveries[id] then return false end
 profile.Identity.Discoveries[id]=true;return true
end
function I.grantReceipt(profile,c,receiptId,productId)
 local s=profile.Identity
 if type(receiptId)~='string' or #receiptId==0 or #receiptId>200 then return false end
 local product
 for _,p in c.Products do if p.Id>0 and p.Id==productId then product=p end end
 if not product then return false end
 if s.Receipts[receiptId] then return true end
 if product.Grant=='Retry' then s.RetryCredits=math.min(1000000,s.RetryCredits+product.Amount)
 else s.Fusion[product.Grant]=math.min(1000000,s.Fusion[product.Grant]+product.Amount) end
 s.Receipts[receiptId]=true;return true
end
function I.buyFusion(profile,c,kind)
 if next(c.Fusion.Recipes)==nil then return false,'Catálogo de fusões aguarda definição; nenhuma moeda foi cobrada.' end
 if kind~='Basic' then return false,'Compra com Gold disponível somente para tentativa básica.' end
 if profile.Gold<c.Fusion.GoldPrice then return false,'Gold insuficiente.' end
 profile.Gold-=c.Fusion.GoldPrice;profile.Identity.Fusion.Basic+=c.Fusion.GoldPack;return true,'Tentativa básica adquirida.'
end
function I.fuse(profile,c,id,now)
 I.refresh(profile,c,now)
 -- Não há algoritmo/resultado autorizado ainda. Não debitar tentativas nem fragmentos.
 return false,'Fusão desativada: combinações e resultados aguardam definição do criador.'
end
return I
