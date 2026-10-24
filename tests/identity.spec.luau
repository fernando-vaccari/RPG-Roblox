local C=require('../src/shared/Config/IdentityConfig')
local I=require('../src/shared/Core/IdentityRules')
local P=require('../src/shared/Core/Progression')
local Catalog=require('../src/shared/Config/ContentConfig')
local Combat=require('../src/shared/Core/CombatRules')
local Abilities=require('../src/shared/Config/AbilityConfig')
local passed=0
local function test(name,fn)fn();passed+=1;print('PASSOU: '..name)end
local function fresh(race)
 local p=P.new();p.Identity=I.new();p.Identity.Race=race or 'Humano';p.Rank='F';return p
end
local function productConfig()
 local c=table.clone(C);c.Products={}
 local id=101 -- Identificadores APENAS do teste, nunca do catálogo publicado.
 for key,p in C.Products do c.Products[key]=table.clone(p);c.Products[key].Id=id;id+=1 end
 return c
end
local function complete(profile,steps,now)
 for _,s in steps do for _=1,s.Count do I.event(profile,C,s.Event,now) end end
end
test('100 tickets provam exatamente 70/12/8/6/4 e fronteiras',function()
 assert(I.validate(C));local counts={}
 for ticket=1,100 do local race=I.pick(C,ticket);counts[race]=(counts[race] or 0)+1 end
 for id,race in C.Races do assert(counts[id]==race.Weight)end
 assert(I.pick(C,70)=='Humano' and I.pick(C,71)=='Elfo' and I.pick(C,82)=='Elfo' and I.pick(C,83)=='ElfoNegro' and I.pick(C,97)=='Anjo')
 assert(not pcall(I.pick,C,0) and not pcall(I.pick,C,101) and not pcall(I.pick,C,0/0))
end)
test('atribuição única e migração preservam raça, Gold e classe',function()
 local p=P.new();I.restore(p,nil,C);local race,created=I.assign(p,C,97);assert(race=='Anjo' and created)
 assert(I.assign(p,C,1)=='Anjo');p.Gold=777
 local migrated=P.sanitize(p,Catalog);I.restore(migrated,p.Identity,C)
 assert(migrated.Gold==777 and migrated.Identity.Race=='Anjo')
 assert(not pcall(I.restore,migrated,{Race='RaçaCorrompida'},C))
end)
test('raças raras trocam recursos, não ganham multiplicador de dano',function()
 for id,r in C.Races do
  assert(r.Health+r.Mana+r.Stamina==0)
  local p=fresh(id);local stats=Combat.stats(p,Abilities);local ordinary=Combat.stats(P.new(),Abilities)
  assert(stats.Damage==ordinary.Damage and stats.Health+stats.Mana+stats.Stamina==ordinary.Health+ordinary.Mana+ordinary.Stamina)
  assert(Abilities.RacialSkills[id])
 end
end)
test('falha e exatos 86400 segundos, sem produto configurado',function()
 local p=fresh();assert(I.startRacial(p,C,15,100));assert(I.fail(p,C,200));assert(not I.fail(p,C,300))
 assert(p.Identity.Racial.ReadyAt==86600)
 assert(not I.startRacial(p,C,15,86599));assert(I.startRacial(p,C,15,86600))
 assert(not I.grantReceipt(p,C,'zero',0))
end)
test('expiração é absoluta e não reinicia relógio ao reconectar',function()
 local p=fresh();I.startRacial(p,C,15,100)
 local deadline=p.Identity.Racial.Deadline
 local saved=P.sanitize(p,Catalog);I.restore(saved,p.Identity,C);I.refresh(saved,C,deadline+200)
 assert(saved.Identity.Racial.ReadyAt==deadline+86400)
 I.refresh(saved,C,deadline+300);assert(saved.Identity.Racial.ReadyAt==deadline+86400)
end)
test('crédito oficial permite retry sem alterar raça e não duplica',function()
 local c=productConfig();local p=fresh('Elfo');I.startRacial(p,c,15,100);I.fail(p,c,110)
 assert(I.grantReceipt(p,c,'receipt-racial',c.Products.RacialRetry.Id))
 assert(I.grantReceipt(p,c,'receipt-racial',c.Products.RacialRetry.Id));assert(p.Identity.RetryCredits==1)
 assert(I.startRacial(p,c,15,111));assert(p.Identity.RetryCredits==0 and p.Identity.Race=='Elfo')
end)
test('fragmentos jamais substituem desafio, evolução é única',function()
 local p=fresh();p.Identity.Fragments=1000
 assert(not I.claimRacial(p,C,100));assert(I.startRacial(p,C,15,100))
 complete(p,C.Races.Humano.Steps,101);assert(I.claimRacial(p,C,102))
 local fragments=p.Identity.Fragments;assert(not I.claimRacial(p,C,103));assert(p.Identity.Fragments==fragments)
 assert(p.Identity.Race=='Humano' and p.Identity.Evolution==C.Races.Humano.Evolution)
end)
test('segredo obrigatório, requisitos e seis classes avançadas persistem',function()
 for id,def in C.Advanced do
  local p=fresh();p.Class=def.Base;p.Identity.Classes[def.Base]=true
  assert(not I.startClass(p,C,id,def.Level-1))
  if def.Secret then assert(not I.startClass(p,C,id,def.Level));assert(I.discover(p,C,def.Secret))end
  assert(I.startClass(p,C,id,def.Level));assert(not I.claimClass(p,C,id))
  complete(p,def.Steps,500);assert(I.claimClass(p,C,id));assert(I.selectClass(p,C,id))
  local restored=P.sanitize(p,Catalog);I.restore(restored,p.Identity,C)
  assert(restored.Class==id and restored.Identity.Classes[id]);assert(not I.claimClass(p,C,id))
  assert(Combat.canUse(id,def.Base,Abilities));assert(#Abilities.Slots[id]==4)
 end
 assert(not I.selectClass(fresh(),C,'Necromante'))
end)
test('missão racial secreta exige descoberta e morte falha somente a tentativa ativa',function()
 local p=fresh('Anjo');assert(not I.startRacial(p,C,15,100))
 I.discover(p,C,'Dawn');assert(I.startRacial(p,C,15,100));assert(I.fail(p,C,101))
 assert(not I.fail(p,C,102))
end)
test('semanas UTC: três gratuitas, créditos persistem, relógio não anda para trás',function()
 local p=fresh();local monday=4*86400
 I.refresh(p,C,monday);p.Identity.Fusion.FreeUsed=3;p.Identity.Fusion.Basic=2;p.Identity.Fusion.Premium=3
 I.refresh(p,C,monday+604799);assert(p.Identity.Fusion.FreeUsed==3)
 I.refresh(p,C,monday+604800);assert(p.Identity.Fusion.FreeUsed==0 and p.Identity.Fusion.Basic==2 and p.Identity.Fusion.Premium==3)
 p.Identity.Fusion.FreeUsed=1;I.refresh(p,C,monday);assert(p.Identity.Fusion.FreeUsed==1)
end)
test('catálogo vazio não cobra Gold/tentativas/fragmentos e recibos de pacotes são idempotentes',function()
 local c=productConfig();local p=fresh();p.Gold=5000;p.Identity.Fragments=20;I.refresh(p,c,100)
 assert(not I.buyFusion(p,c,'Basic'));assert(not I.fuse(p,c,'inventada',100))
 assert(p.Gold==5000 and p.Identity.Fusion.FreeUsed==0 and p.Identity.Fragments==20)
 for _,key in {'BasicPack','PremiumPack'} do
  local product=c.Products[key];I.grantReceipt(p,c,key,product.Id);I.grantReceipt(p,c,key,product.Id)
  assert(p.Identity.Fusion[product.Grant]==3)
 end
 assert(not I.grantReceipt(p,c,'unknown',99999))
end)
test('as 24 habilidades anteriores e arqueiro continuam disponíveis',function()
 local base=0;for _,skill in Abilities.Skills do if not Abilities.Classes[skill.Class].Base then base+=1 end end
 assert(base==24 and Abilities.Classes.Arqueiro and Catalog.Items.Bow)
 assert(table.find(C.Fusion.Pools.Basic,'Arqueiro') and table.find(C.Fusion.Pools.Premium,'Necromante'))
 for _,id in C.Fusion.Pools.Basic do assert(not C.Advanced[id]) end
 for _,id in C.Fusion.Pools.Premium do assert(C.Advanced[id]) end
 assert(#C.PrimaryClasses==3 and #C.LegacyClasses==1)
end)
print(passed..' cenários de identidade passaram; Roblox/recibos reais NÃO TESTADOS.')
