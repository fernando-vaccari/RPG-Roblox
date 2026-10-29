local M=require('../src/shared/Core/ActionMath')
local Interiors=require('../src/shared/Core/InteriorPlan')
local Preview=require('../src/shared/Core/BenefitPreview')
local Config=require('../src/shared/Config/IdentityConfig')
local Env=require('../src/shared/Core/EnvironmentRules')
local P=require('../src/shared/Core/Progression')
local I=require('../src/shared/Core/IdentityRules')
local Catalog=require('../src/shared/Config/ContentConfig')
local n=0;local function test(name,f)f();n+=1;print('PASSOU: '..name)end
test('avanço de projétil limita frame e não ultrapassa alcance',function()
 assert(M.travel(100,50,0.1)==10);assert(M.travel(100,3,0.1)==3)
 assert(M.travel(100,100,10)==10);assert(M.travel(100,100,-1)==0)
 assert(not pcall(M.travel,100,10,0/0))
end)
test('avisos de chefes têm janela positiva e fases distintas',function()
 for _,kind in {'Malgorth','SylvarinBoss','NoctharBoss'}do
  local a,b=M.boss(kind,1,1),M.boss(kind,2,2)
  assert(a.Windup>=1 and b.Windup>=1 and a.Radius<b.Radius and b.Cooldown<a.Cooldown and a.Name~=b.Name)
  assert(M.inArea(1,0,a) and not M.inArea(1,0,b) and M.inArea(20,0,b) and not M.inArea(20,30,b))
 end
end)
test('móveis respeitam orçamento e deixam faixa de entrada central livre',function()
 for _,list in Catalog.CityBuildings do for _,kind in list do
  local items=Interiors.build(kind,28,30,20);assert(#items<=15 and #items>=10)
  for _,s in items do
   assert(s.Size[1]>0 and s.Size[2]>0 and s.Size[3]>0)
   if s.Collide and s.Position[2]<8 and s.Position[3]-s.Size[3]/2<0 then
    assert(math.abs(s.Position[1])-s.Size[1]/2>=3.5,'Entrada bloqueada: '..kind..'/'..s.Name)
   end
  end
 end end
end)
test('prévias de benefícios aprovados não alteram saldo, raça ou recibos',function()
 local p=P.new();p.Identity=I.new();p.Identity.Race='Humano'
 for _,key in {'RacialRetry','BasicPack','PremiumPack'}do
  local r=assert(Preview.report(p,Config,key));assert(r.Preview and r.After-r.Before==Config.Products[key].Amount)
 end
 assert(not Preview.report(p,Config,'VIP'))
 assert(p.Gold==100 and p.Identity.RetryCredits==0 and next(p.Identity.Receipts)==nil and p.Identity.Race=='Humano')
end)
test('clima determinístico e qualidade LOW sem partículas de chuva',function()
 assert(Env.weather(0)=='Clear' and Env.weather(300)=='Mist' and Env.weather(600)=='Rain' and Env.weather(1200)=='Clear')
 assert(Env.Profiles.LOW.Rain==0 and Env.Profiles.HIGH.Rain<=24 and Env.Profiles.LOW.FX<Env.Profiles.HIGH.FX)
end)
test('vender e recomprar arma não depende de reconexão nem cria saldo negativo',function()
 local p=P.new();p.Gold=1000
 assert(P.buy(p,Catalog,'Katana','ShopWeapons'));assert(P.sell(p,Catalog,'Katana'))
 assert(p.Inventory.Katana==nil and p.Gold==700)
 assert(P.buy(p,Catalog,'Katana','ShopWeapons'));assert(p.Gold==200 and p.Inventory.Katana==1)
 assert(not P.buy(p,Catalog,'Katana','ShopWeapons'));assert(p.Gold==200)
end)
test('habilidades iniciais disponíveis não podem cobrar aprendizado redundante',function()
 local Rules=require('../src/shared/Core/CombatRules');local Skills=require('../src/shared/Config/AbilityConfig')
 local p=P.new();p.Class='Mago';p.Gold=100
 assert(not Rules.unlock(p,'Fireball',Skills));assert(p.Gold==100 and not p.Unlocks.Fireball)
end)
print(n..' cenários de qualidade passaram; estética/FPS reais NÃO TESTADOS.')
