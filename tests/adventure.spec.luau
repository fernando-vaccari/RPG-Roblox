local Defense=require('../src/shared/Core/DefenseRules')
local Combat=require('../src/shared/Core/CombatRules')
local Abilities=require('../src/shared/Config/AbilityConfig')
local Progress=require('../src/shared/Core/Progression')
local Catalog=require('../src/shared/Config/ContentConfig')
local Adventure=require('../src/shared/Core/AdventureRules')
local Config=require('../src/shared/Config/AdventureConfig')
local Dungeon=require('../src/shared/Core/DungeonRules')
local DConfig=require('../src/shared/Config/DungeonConfig')
local count=0
local function test(name,fn)fn();count+=1;print('PASSOU: '..name)end
local function fighter()return Combat.new(Combat.stats(Progress.new(),Abilities))end
test('parry tem janela precisa, direção e apenas um acerto por pressão',function()
 local s=fighter();assert(Defense.block(s,10,true))
 local damage,outcome=Defense.resolve(s,10.24,30,true,true);assert(damage==0 and outcome=='Parry')
 damage,outcome=Defense.resolve(s,10.24,30,true,true);assert(damage>0 and outcome=='Block')
 local late=fighter();Defense.block(late,10,true);assert(select(2,Defense.resolve(late,10.241,30,true,true))=='Block')
 local back=fighter();Defense.block(back,10,true);assert(select(2,Defense.resolve(back,10.1,30,false,true))=='Hit')
 local aoe=fighter();Defense.block(aoe,10,true);assert(select(2,Defense.resolve(aoe,10.1,30,true,false))=='Block')
end)
test('spam e segurar bloqueio não renovam parry',function()
 local s=fighter();Defense.block(s,1,true);assert(not Defense.block(s,1.2,true));assert(s.ParryUntil==1.24)
 Defense.block(s,1.3,false);Defense.block(s,1.31,true);assert(s.ParryUntil==0)
 Defense.block(s,1.7,false);Defense.block(s,1.71,true);assert(s.ParryUntil==1.95)
end)
test('quebra de postura bloqueia ataques e recupera com o tempo',function()
 local s=fighter();Defense.block(s,1,true)
 assert(select(2,Defense.resolve(s,2,40,true,false))=='Block')
 assert(select(2,Defense.resolve(s,2.2,40,true,false))=='Break')
 assert(not s.Blocking and s.Posture==100)
 assert(not Combat.primary(s,2.3,0.5) and not Defense.block(s,2.3,true))
 Defense.step(s,5,0.5);assert(s.Posture<100)
 s.DodgeUntil=6;assert(select(2,Defense.resolve(s,5.1,999,false,false))=='Dodge')
end)
test('postura inimiga interrompe golpes e crítico independe de raça',function()
 local e={Def={Boss=true},Pending={},Swing={}}
 assert(not Defense.pressure(e,10,55));assert(Defense.pressure(e,11,55));assert(not e.Pending and not e.Swing and e.StunnedUntil==12.2)
 local crits=0;for ticket=1,100 do if Defense.critical(ticket)>1 then crits+=1 end end;assert(crits==8)
 assert(not pcall(Defense.critical,0))
end)
test('tutorial é idempotente, preserva marcos e não concede dinheiro',function()
 local p=Progress.new();Adventure.restore(p,nil,Config)
 assert(Adventure.current(p,Config).Id=='Move');assert(Adventure.event(p,Config,'Parry'));assert(not Adventure.event(p,Config,'Parry'))
 assert(not Adventure.event(p,Config,'GiveGold'));assert(p.Gold==100 and p.XP==0)
 local raw=p.Adventure;Adventure.restore(p,raw,Config);assert(p.Adventure.Tutorial.Parry)
 for _,step in Config.Tutorial do Adventure.event(p,Config,step.Id) end;assert(Adventure.current(p,Config)==nil)
end)
test('armadura exige equipamento e migra posse antiga sem apagar itens',function()
 local p=Progress.new();p.Inventory.Armor=1
 local base=Combat.stats(p,Abilities).Health;p.Armor='Armor';assert(Combat.stats(p,Abilities).Health==base+40)
 assert(not Progress.sell(p,Catalog,'Armor'));p.Armor='';assert(Progress.sell(p,Catalog,'Armor'))
 local old=Progress.sanitize({Inventory={Armor=1}},Catalog);assert(old.Armor=='Armor')
 local unequipped=Progress.sanitize({Inventory={Armor=1},Armor=''},Catalog);assert(unequipped.Armor=='')
end)
test('capacidade e compras não perdem Gold nem duplica a escolha inicial',function()
 local c=table.clone(Catalog);c.InventorySlots=1
 local p=Progress.new();p.Gold=2000;p.Inventory.Potion=1
 assert(not Progress.buy(p,c,'Katana','ShopWeapons') and p.Gold==2000)
 assert(not Progress.choose(p,c,'Staff') and not p.StarterChosen)
 assert(Progress.buy(p,c,'Potion','ShopPotions'));assert(p.Inventory.Potion==2)
 p.Inventory.Potion=nil;assert(Progress.choose(p,c,'Staff'));assert(p.Class=='Mago')
 assert(not Progress.choose(p,c,'Longsword'))
end)
test('ranks dependem de XP e missões; missões avançadas rejeitam Rank F',function()
 local p=Progress.new();Progress.register(p);p.XP=2000
 Progress.promote(p,Catalog);assert(p.Rank=='F')
 for _,id in {'FirstSteps','Wolves','Herb','Ruins'} do p.Quests[id]={Count=Catalog.Quests[id].Required,Claimed=true} end
 Progress.promote(p,Catalog);assert(p.Rank=='E')
 assert(not Progress.accept(p,Catalog,'VesperaHerald'));assert(Progress.accept(p,Catalog,'AsterionCrown'))
 local loaded=Progress.sanitize(p,Catalog);assert(loaded.Rank=='E')
end)
test('30 andares possuem títulos, seis layouts e dificuldade crescente',function()
 local titles,layouts,total={},{},0
 for _,id in DConfig.Order do
  local previous=0
  for n=1,DConfig.Dungeons[id].Floors do
   local f=Dungeon.floor(DConfig,id,n);assert(not titles[f.Name]);titles[f.Name]=true;layouts[f.Layout]=true
   assert(#f.Enemies>=1 and #f.Enemies<=4 and f.Scale>previous);previous=f.Scale
   for _,kind in f.Enemies do assert(Catalog.Enemies[kind]) end
   total+=1
  end
 end
 local types=0;for _ in layouts do types+=1 end
 assert(total==30 and types==6);assert(not pcall(Dungeon.floor,DConfig,'MalgorthDepths',11))
end)
test('andar não avança por morte falsa, repetida ou antes de eliminar todos',function()
 local run=Dungeon.newRun(DConfig,'MalgorthDepths',{1,2},'test',100)
 Dungeon.beginFloor(run,{'a','b'});assert(not Dungeon.advance(run,DConfig))
 assert(not Dungeon.kill(run,'fake'));assert(Dungeon.kill(run,'a'));assert(not Dungeon.kill(run,'a'))
 assert(run.Remaining==1 and not Dungeon.advance(run,DConfig));assert(Dungeon.kill(run,'b'));assert(Dungeon.advance(run,DConfig) and run.Floor==2)
 assert(not Dungeon.eliminate(run,1));assert(Dungeon.eliminate(run,2) and run.State=='Failed')
 assert(not Dungeon.advance(run,DConfig));assert(not pcall(Dungeon.newRun,DConfig,'MalgorthDepths',{1,1},'dup',100))
 local studio=Dungeon.newRun(DConfig,'MalgorthDepths',{-1,-2},'studio-clients',100);assert(studio.Members[-2])
end)
test('expedições completas preservam progresso e recompensam cada andar uma vez',function()
 local p=Progress.new();Dungeon.restore(p,nil,DConfig)
 for _,id in DConfig.Order do
  local run=Dungeon.newRun(DConfig,id,{1},id,100)
  for floor=1,DConfig.Dungeons[id].Floors do
   Dungeon.beginFloor(run,{'guardian'});Dungeon.kill(run,'guardian')
   assert(Dungeon.reward(p,DConfig,id,floor));local gold=p.Gold
   assert(not Dungeon.reward(p,DConfig,id,floor) and p.Gold==gold)
   assert(Dungeon.advance(run,DConfig))
  end
  assert(run.State=='Complete' and p.Expedition.Clears[id])
 end
 local old=p.Expedition;Dungeon.restore(p,old,DConfig);assert(p.Expedition.Best.FallenSanctum==20)
 assert(not Dungeon.reward(p,DConfig,'fake',1))
end)
test('migração de reservas rejeita membros inválidos e não inventa progresso',function()
 local p=Progress.new();Dungeon.restore(p,{Best={MalgorthDepths=999},Ticket={Dungeon='MalgorthDepths',Run='a',Expires=1000,Members={2,2,0,'bad'}}},DConfig)
 assert(p.Expedition.Best.MalgorthDepths==0 and #p.Expedition.Ticket.Members==1)
 assert(not Dungeon.reward(p,DConfig,'MalgorthDepths',2))
end)
print(count..' cenários Eldravyn passaram; não substituem testes no Roblox Studio.')
