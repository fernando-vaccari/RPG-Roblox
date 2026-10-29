local Plan=require('../src/worldgen/ArchitecturalPlan')
local Catalog=require('../src/shared/Config/ContentConfig')
local count=0
local function test(name,fn)fn();count+=1;print('PASSOU: '..name)end
test('cinco gramáticas arquitetônicas mantêm identidades e paletas próprias',function()
 local ids,roofs={},{}
 for id,theme in Plan.Themes do
  assert(not ids[theme.Id]);ids[theme.Id]=true
  local key=table.concat(theme.Roof,',');assert(not roofs[key]);roofs[key]=true
  for _,name in {'Stone','Plaster','Wood','Roof','Metal','Glass'}do
   assert(#theme[name]==3)
   for _,v in theme[name]do assert(v>=0 and v<=255)end
  end
  assert(Plan.build('SmallHouse',id,1).Theme==theme)
 end
 assert(Plan.Themes.Valoria.Id=='Crown' and Plan.Themes.Eldoria.Id=='Woodland' and Plan.Themes.Durakh.Id=='Mountain' and Plan.Themes.Asterion.Id=='Arcane' and Plan.Themes.Arkheim.Id=='Gothic')
end)
test('catálogo integral tem dimensões positivas, portas transitáveis e limites estáveis',function()
 for city,kinds in Catalog.CityBuildings do for index,kind in kinds do
  local p=Plan.build(kind,city,index)
  assert(p.Width>0 and p.Width<=44 and p.Depth>0 and p.Depth<=40)
  assert(p.Height>p.DoorHeight and p.DoorWidth==8 and p.DoorHeight==10 and p.Rise>0)
  if kind=='Castle' then assert(p.Width==44 and p.Depth==40)end
  if kind=='Forge' then assert(p.Width==38 and p.Depth==34)end
  if kind=='ArcaneTower' then assert(p.Width==24 and p.Depth==24 and p.Height>=48)end
 end end
end)
test('interiores são seletivos e podem ser explicitamente reservados por lote',function()
 assert(Plan.build('GuildHall','Valoria',1).Interior)
 assert(Plan.build('Castle','Arkheim',1).Interior)
 assert(not Plan.build('SmallHouse','Valoria',1).Interior)
 assert(not Plan.build('Forge','Durakh',1,{Interior=false}).Interior)
 assert(Plan.build('SmallHouse','Eldoria',1,{Interior=true}).Interior)
end)
test('variações controladas alteram silhueta sem mudar identidade do lote',function()
 local silhouettes={}
 for i=0,3 do
  local p=Plan.build('SmallHouse','Valoria',5,{Variant=i,District='Crafts'})
  silhouettes[p.Roof..p.Width..p.Rise]=true
  assert(p.Variant==i and p.District=='Crafts')
 end
 local n=0;for _ in silhouettes do n+=1 end;assert(n==4)
 assert(Plan.build('SmallHouse','Valoria',5,{Variation=3}).Variant==3)
 assert(not pcall(Plan.build,'SmallHouse','Valoria',5,{Variant=-1}))
end)
print(count..' testes de gramática arquitetônica; renderização/colisões reais não executadas.')
