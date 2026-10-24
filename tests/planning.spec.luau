local c=require('../src/shared/Config/WorldConfig')
local content=require('../src/shared/Config/ContentConfig')
local terrain=require('../src/worldgen/TerrainMath')
local planner=require('../src/worldgen/WorldPlan')
local plan=planner.build(c,terrain,content)
assert(#plan.Cities==4 and #plan.Roads==6)
local total=0
for _,city in plan.Cities do
    assert(#city.Lots==#content.CityBuildings[city.Id])
    total+=#city.Lots
    for i,a in city.Lots do
        assert(planner.clear(c,terrain,a.X,a.Z,a.Radius))
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
        assert(math.abs(s.A.H-s.B.H)<1)
    end
end
assert(bridges>0)
assert(#plan.Trees>=160 and #plan.Chests==10 and #plan.EnemySpawns==12)
for _,t in plan.Trees do assert(planner.clear(c,terrain,t.X,t.Z,12)) end
local copy=planner.build(c,terrain,content)
assert(copy.Trees[1].X==plan.Trees[1].X)
print('PASSOU: '..total..' lotes sem sobreposição, seis rotas contínuas, '..bridges..' segmentos de ponte, '..#plan.Trees..' árvores determinísticas, spawns e baús.')

-- Conectividade topológica por extremos compartilhados: as quatro cidades são alcançáveis.
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
    assert(#qPlan.Trees>=copyConfig.QualityProfiles[quality].TreesPerForest*2*0.8)
end
print('PASSOU: grafo alcança quatro cidades e todos os perfis de qualidade respeitam densidade mínima.')
