local C=require('../src/shared/Config/AbilityConfig')
local Catalog=require('../src/shared/Config/ContentConfig')
local P=require('../src/shared/Core/Progression')
local R=require('../src/shared/Core/CombatRules')
local n=0
local function test(name,fn)fn();n+=1;print('PASSOU: '..name)end
test('progressão cumulativa 1–100 e atributos por classe',function()
 assert(R.level(0,C)==1 and R.level(80,C)==2 and R.level(1000000000,C)==100)
 for name in C.Classes do local p=P.new();p.Class=name;p.XP=1000000000;local s=R.stats(p,C);assert(s.Level==100 and s.Health>=580 and s.Mana>300)end
end)
test('combo de quatro golpes, reset e rejeição durante recovery',function()
 local s=R.new(R.stats(P.new(),C))
 for i=1,4 do local combo,mul=R.primary(s,i,0.3);assert(combo==i);assert(mul==(if i==4 then 1.65 else 1));assert(not R.primary(s,i+0.01,0.3))end
 assert(R.primary(s,8,0.3)==1)
end)
test('custos são atômicos, cooldown e stamina nunca negativos',function()
 local s=R.new(R.stats(P.new(),C));local mana=s.Mana
 assert(R.reserve(s,'Fire',1,10,20,3));assert(not R.reserve(s,'Fire',2,10,20,3));assert(s.Mana==mana-10)
 assert(not R.reserve(s,'Huge',5,999,0,1));s.Sprinting=true
 for _=1,200 do R.step(s,R.stats(P.new(),C),0.5)end
 assert(s.Stamina>=0 and not s.Sprinting)
end)
test('habilidades exigem classe/nível e aprendizado sem débito duplicado',function()
 local p=P.new();p.Gold=10000
 assert(not R.unlock(p,'IceExplosion',C));p.Class='Mago';assert(not R.unlock(p,'IceExplosion',C))
 p.XP=100000;assert(R.unlock(p,'IceExplosion',C));local gold=p.Gold;assert(not R.unlock(p,'IceExplosion',C));assert(p.Gold==gold)
 for class,ids in C.Slots do assert(#ids==4);for _,id in ids do assert(C.Skills[id].Class==class)end end
 local spells=0;for _,s in C.Skills do if s.Class=='Mago'then spells+=1 end end;assert(spells==12)
end)
test('campanha com 15 principais e 20 secundárias e pré-requisitos acíclicos',function()
 local main,side=0,0
 local supported={Bandit=true,Wolf=true,Slime=true,Skeleton=true,Demon=true,Knight=true,Malgorth=true,SylvarinBoss=true,NoctharBoss=true,Mage=true,Ruins=true,Herb=true,Supplies=true}
 for id,q in Catalog.Quests do
  if q.Category=='Main'then main+=1 elseif q.Category=='Side'then side+=1 end
  assert(supported[q.Target] or string.sub(q.Target,1,6)=='Visit:' or string.sub(q.Target,1,5)=='Talk:')
  local seen={};local function walk(key)assert(not seen[key]);seen[key]=true;for _,pre in Catalog.Quests[key].Prerequisites or {} do assert(Catalog.Quests[pre]);walk(pre)end;seen[key]=nil end;walk(id)
 end
 assert(main==15 and side==20)
 local p=P.new();P.register(p);assert(not P.accept(p,Catalog,'Main03'))
 p.Quests.FirstSteps.Claimed=true;assert(P.accept(p,Catalog,'Main02'))
end)
test('venda/desequipar não duplica escolha gratuita; classe/unlocks persistem',function()
 local p=P.new();P.register(p);P.choose(p,Catalog,'Katana');P.event(p,Catalog,'Bandit',3);P.claimQuest(p,Catalog,'FirstSteps')
 p.Equipment='';assert(not P.choose(p,Catalog,'Staff'));assert(P.sell(p,Catalog,'Katana'));assert(not P.sell(p,Catalog,'Katana'))
 p.Unlocks.WindCut=true;local loaded=P.sanitize(p,Catalog);assert(loaded.Class=='Espadachim' and loaded.StarterChosen and loaded.Unlocks.WindCut)
 assert(not P.choose(loaded,Catalog,'Staff'))
end)
print(n..' cenários de expansão passaram (regras puras; não testa física/áudio do Roblox).')
