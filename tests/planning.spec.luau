local c=require('../src/shared/Config/WorldConfig')
local content=require('../src/shared/Config/ContentConfig')
local terrain=require('../src/worldgen/TerrainMath')
local planner=require('../src/worldgen/WorldPlan')
local plan=planner.build(c,terrain,content)
assert(#plan.Cities==5 and #plan.Roads==10)
local total=0
for _,city in plan.Cities do
    assert(#city.Lots>=(if city.Id=='Valoria' then 300 else 140))
    total+=#city.Lots
    for i,a in city.Lots do
        assert(a.External or planner.clear(c,terrain,a.X,a.Z,a.Radius))
        for j=i+1,#city.Lots do
            local b=city.Lots[j]
            assert(math.sqrt((a.X-b.X)^2+(a.Z-b.Z)^2)>a.Radius+b.Radius+6)
        end
    end
end
local bridges=0
for _,road in plan.Roads do
    assert(#road.Segments>0)
    for i,s in road.Segments do
        if s.Bridge then bridges+=1 end
        if i>1 then assert(s.A.X==road.Segments[i-1].B.X and s.A.Z==road.Segments[i-1].B.Z) end
        local length=math.sqrt((s.A.X-s.B.X)^2+(s.A.Z-s.B.Z)^2)
        assert(length>0 and length<20,'Comprimento da seção de estrada')
        assert(math.abs(s.A.H-s.B.H)/length<0.15,'Rampa rodoviária íngreme')
        if not s.Bridge then
            for _,point in {s.A,s.B} do
                if terrain.riverDistance(c,point.X,point.Z)>=c.River.HalfWidth+c.River.BankWidth+40 then
                    assert(math.abs(point.H-terrain.height(c,point.X,point.Z))<1e-8,'Estrada flutuante/enterrada')
                end
            end
        end
    end
end
assert(bridges>0)
assert(#plan.Trees>=160 and #plan.Chests==15 and #plan.EnemySpawns==18)
for _,t in plan.Trees do assert(planner.clear(c,terrain,t.X,t.Z,12)) end
local copy=planner.build(c,terrain,content)
assert(copy.Trees[1].X==plan.Trees[1].X)
print('PASSOU: '..total..' lotes sem sobreposição, dez rotas contínuas, '..bridges..' segmentos de ponte, '..#plan.Trees..' árvores determinísticas, spawns e baús.')

-- Conectividade topológica por extremos compartilhados: as cinco cidades são alcançáveis.
local function key(p)return p.X..':'..p.Z end
local graph={}
for _,r in c.Roads do
    local a,b=key(r.A),key(r.B);graph[a]=graph[a] or {};graph[b]=graph[b] or {}
    table.insert(graph[a],b);table.insert(graph[b],a)
end
local seen={}
local function visit(k)if seen[k]then return end;seen[k]=true;for _,other in graph[k] or {} do visit(other)end end
visit(key(c.Cities[1]));for _,city in c.Cities do assert(seen[key(city)],'Cidade desconectada: '..city.Id)end
for _,quality in {'LOW','MEDIUM','HIGH'} do
    local copyConfig=table.clone(c);copyConfig.Quality=quality
    local qPlan=planner.build(copyConfig,terrain,content)
    assert(#qPlan.Trees>=copyConfig.QualityProfiles[quality].TreesPerForest*#c.Forests*0.8)
end
print('PASSOU: grafo alcança cinco cidades e todos os perfis de qualidade respeitam densidade mínima.')

-- Districts replace the previous spiral; stable lot IDs and capital integration survive.
local distinct={}
for _,city in plan.Cities do
    distinct[city.Theme]=true
    assert(#city.Streets>200)
    for _,lot in city.Lots do
        if not lot.Residential then assert(lot.Kind==content.CityBuildings[city.Id][tonumber(lot.Id:match('_(%d+)$'))]) end
        assert(lot.District and lot.Variation~=nil and type(lot.Interior)=='boolean')
        if not lot.External then
            assert(math.abs(lot.X-city.X)>=lot.Radius+18 and math.abs(lot.Z-city.Z)>=lot.Radius+18)
            -- Porch segment cannot pass through another building footprint.
            local dx,dz=lot.StreetX-lot.X,lot.StreetZ-lot.Z
            local length=math.sqrt(dx*dx+dz*dz)
            local porch={X=lot.X+dx/length*23,Z=lot.Z+dz/length*23}
            for _,other in city.Lots do
                if other~=lot and not other.External then
                    local clearance=terrain.segment(other.X,other.Z,porch,{X=lot.StreetX,Z=lot.StreetZ})
                    assert(clearance>=other.Radius+3,'Caminho da porta cruza outra quadra')
                end
            end
        end
    end
end
local countThemes=0;for _ in distinct do countThemes+=1 end;assert(countThemes==5)
local capitalCastle=false;for _,lot in plan.Cities[1].Lots do capitalCastle=capitalCastle or lot.VisualKind=='Castle' end;assert(capitalCastle)
local bent=0
for _,road in plan.Roads do
    for _,point in road.Points do if terrain.segment(point.X,point.Z,road.A,road.B)>20 then bent+=1;break end end
end
assert(bent>=7,'Rotas devem acompanhar a composição, sem retornar a dez retas')
local species,groves={},{}
for _,tree in plan.Trees do
    species[tree.Variant]=true;groves[tree.Forest..tree.Cluster]=true
    local _,water=terrain.column(c,tree.X,tree.Z);assert(not water,'Árvore submersa')
end
assert(species[0] and species[1] and species[2] and species[3] and species[4])
local clusters=0;for _ in groves do clusters+=1 end;assert(clusters==12)
print('PASSOU: cinco temas/quadras planejadas, capital com castelo visual, caminhos de porta livres, curvas e doze bosquetes com cinco espécies.')

-- Expanded districts must stay on their plateau, clear of ramparts/civic reserve
-- and the physical stair footprint; metadata alone is insufficient.
assert(c.WorldSize==6144 and #terrain.chunks(c)==2304)
for _,city in plan.Cities do
    local original=0
    for _,lot in city.Lots do
        if not lot.Residential then original+=1 end
        if not lot.External then
            local dx,dz=lot.X-city.X,lot.Z-city.Z
            local radial=math.sqrt(dx*dx+dz*dz)
            assert(radial-lot.Radius>=city.CivicRadius-1e-8)
            assert(radial+lot.Radius<=city.OuterWallRadius-20+1e-8)
            if city.InnerWallRadius then assert(math.abs(radial-city.InnerWallRadius)>=lot.Radius+20-1e-8) end
            assert(not(dx+lot.Radius+4>-94 and dx-lot.Radius-4<-36
                and dz+lot.Radius+4>city.OuterWallRadius-61 and dz-lot.Radius-4<city.OuterWallRadius-21), 'Casa intersecta a escada da muralha')
        end
        for _,offset in {{0,0},{lot.Radius,0},{-lot.Radius,0},{0,lot.Radius},{0,-lot.Radius}} do
            assert(math.abs(terrain.height(c,lot.X+offset[1],lot.Z+offset[2])-lot.H)<0.001, 'Fundação atravessada por relevo: '..lot.Id)
        end
    end
    assert(original==#content.CityBuildings[city.Id], 'Identidades dos serviços legados alteradas')
end
for _,tree in plan.Trees do
    assert(tree.Monumental and tree.Scale>=1 and tree.Scale<=1.4)
    assert(planner.clear(c,terrain,tree.X,tree.Z,tree.RootRadius))
    for _,city in c.Cities do
        assert(math.sqrt((tree.X-city.X)^2+(tree.Z-city.Z)^2)>=city.Radius+tree.RootRadius+20)
    end
end
print('PASSOU: continente6144, fundações planas, corredores de muralhas/escadas livres e raízes fora das cidades/estradas.')
