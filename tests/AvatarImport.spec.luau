local Frame=require('../src/avatar/shared/ImportFrame')
local Catalog=require('../src/avatar/shared/AvatarCatalog')
local count=0
local function test(name,fn)fn();count+=1;print('PASSOU AVATAR PURO: '..name)end
test('calibração remove escala/translação/rotação e conserva o espaço em studs',function()
 local basis=Frame.basis({O={30,41,90},X={30,41,92},Y={30,43,90},Z={28,41,90}})
 local p=Frame.point(basis,{26,45,96});assert(p[1]==3 and p[2]==2.5 and p[3]==2)
 local d=Frame.direction(basis,{0,0,1});assert(d[1]==1 and d[2]==0 and d[3]==0)
end)
test('marcadores inválidos, espelhamento, cisalhamento e escala desigual abortam',function()
 for _,points in {
  {O={0,0,0},X={0,0,0},Y={0,1,0},Z={0,0,1}},
  {O={0,0,0},X={1,0,0},Y={0,1,0},Z={0,0,-1}},
  {O={0,0,0},X={2,0,0},Y={0,1,0},Z={0,0,1}},
  {O={0,0,0},X={1,0,0},Y={.2,1,0},Z={0,0,1}},
  {O={0,0,0},X={1,0,0},Y={0,0/0,0},Z={0,0,1}},
 }do assert(not pcall(Frame.basis,points))end
end)
test('conteúdo precisa de URI Roblox publicada; nenhuma URL arbitrária é aceita',function()
 assert(Frame.asset('rbxassetid://12345')and Frame.asset('https://www.roblox.com/asset/?id=12345'))
 for _,s in {'','rbxassetid://0','rbxtemp://12345','file:///tmp/a.mesh','https://other.example/model.mesh','rbxassetid://-1',1}do assert(not Frame.asset(s))end
end)
test('catálogo cobre 66 NPCs e 14 inimigos, sem preços ou probabilidades novos',function()
 local npcs,enemies=0,0
 for id,key in Catalog.NPCs do npcs+=1;local def=Catalog.Models[key];assert(def.NPCId==id and #def.Bones==15 and def.Kind=='R15'and not def.Gold)end
 for kind,key in Catalog.Enemies do enemies+=1;assert(Catalog.Models[key].EnemyKind==kind)end
 assert(npcs==66 and enemies==14 and Catalog.Models.ENEMY_Wolf.Kind=='Quadruped'and Catalog.Models.ENEMY_Slime.Kind=='Blob')
end)
print('PASSOU AVATAR PURO TOTAL: '..count..'; sem Studio/IDs reais.')
