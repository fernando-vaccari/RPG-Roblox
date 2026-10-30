local c = require("../src/shared/Config/WorldConfig")
local mathTerrain = require("../src/worldgen/TerrainMath")
local count = 0
local function test(name, run)
    run()
    count += 1
    print("PASSOU: " .. name)
end
local function changed(key, value)
    local copy = table.clone(c)
    copy[key] = value
    return copy
end

test("configuração padrão e limites de entrada", function()
    assert(mathTerrain.validate(c))
    for _, bad in { changed("Resolution", 8), changed("ChunkSize", 130), changed("WorldSize", 4001),
        changed("Seed", 0/0), changed("MaxY", 60), changed("Quality", "ULTRA"), changed("MaxChunks", 1) } do
        assert(not pcall(mathTerrain.validate, bad))
    end
end)
test("chunks cobrem 6144x6144 sem buracos e respeitam voxel grid", function()
    local area, seen = 0, {}
    local chunks = mathTerrain.chunks(c)
    assert(#chunks == 2304)
    for _, chunk in chunks do
        assert(chunk.Width % 4 == 0 and chunk.Depth % 4 == 0)
        for x=chunk.X, chunk.X+chunk.Width-1, 4 do
            for z=chunk.Z, chunk.Z+chunk.Depth-1, 4 do
                local key = tostring(x) .. ":" .. tostring(z)
                assert(not seen[key], "Chunk sobreposto")
                seen[key] = true
                area += 16
            end
        end
    end
    assert(area == c.WorldSize*c.WorldSize)
end)
test("terreno contínuo, limitado e não plano em toda a extensão ampliada", function()
    local lo, hi = math.huge, -math.huge
    for x=-c.WorldSize/2,c.WorldSize/2,60 do
        for z=-c.WorldSize/2,c.WorldSize/2,60 do
            local h = mathTerrain.height(c,x,z)
            assert(h > c.MinY+4 and h < c.MaxY-4)
            lo,hi = math.min(lo,h), math.max(hi,h)
            assert(math.abs(h-mathTerrain.height(c,x+4,z)) < 4, "Degrau não jogável")
        end
    end
    assert(hi-lo > 25)
end)
test("plataformas reservadas para as cinco cidades", function()
    for _, city in c.Cities do
        for _, offset in { {0,0}, {city.Radius*0.5,0}, {0,-city.Radius*0.5} } do
            assert(math.abs(mathTerrain.height(c,city.X+offset[1],city.Z+offset[2])-city.Height) < 1e-8)
        end
    end
end)
test("seed determinística e seeds diferentes alteram o relevo", function()
    local different = false
    for x=-1900,1900,100 do
        local first = mathTerrain.height(c,x,300)
        assert(first == mathTerrain.height(c,x,300))
        different = different or math.abs(first-mathTerrain.height(changed("Seed",54321),x,300)) > 0.01
    end
    assert(different)
end)
test("ocupação voxel parcial e materiais de superfície/subsolo", function()
    local city = c.Cities[1]
    local material, occupancy = mathTerrain.voxel(c,city.X,city.Height,city.Z)
    assert(material == "Grass" and occupancy == 0.5)
    local _, air = mathTerrain.voxel(c,city.X,city.Height+4,city.Z)
    local rock, solid = mathTerrain.voxel(c,city.X,c.MinY,city.Z)
    assert(air == 0 and solid == 1 and rock == "Rock")
end)
test("configurações rejeitam cidades sobrepostas e IDs duplicados", function()
    local bad = table.clone(c)
    bad.Cities = table.clone(c.Cities)
    bad.Cities[2] = table.clone(c.Cities[1])
    assert(not pcall(mathTerrain.validate,bad))
end)
test("cadeias, lagos e reservas cênicas mantêm fundações e entradas livres", function()
    assert(#c.MountainRanges==3 and #c.AdditionalLakes==2 and c.SchemaVersion==4)
    for _,site in c.ScenicReservations do
        for _,offset in {{0,0},{-14,-17},{14,-17},{-14,17},{14,17}} do
            assert(math.abs(mathTerrain.height(c,site.X+offset[1],site.Z+offset[2])-site.Height)<1e-8,'Terrain invadiu cave/portal/estrutura: '..site.Id)
        end
    end
    for _,lake in c.AdditionalLakes do
        local h,water=mathTerrain.column(c,lake.X,lake.Z)
        assert(h==lake.BedY and water==lake.WaterY)
        assert(mathTerrain.voxel(c,lake.X,lake.WaterY-4,lake.Z)=='Water')
    end
end)
test("distância de estrada não confunde parâmetro t com distância e assinatura inclui controles", function()
    -- Regression: math.min(best, segment()) would also consume the second return t.
    local point=c.Cities[1];local distance=mathTerrain.roadDistance(c,point.X+84,point.Z+84)
    assert(distance>50 and distance<110)
    local modified=table.clone(c);modified.Roads=table.clone(c.Roads)
    modified.Roads[1]=table.clone(c.Roads[1]);modified.Roads[1].Points=table.clone(c.Roads[1].Points)
    modified.Roads[1].Points[2]=table.clone(c.Roads[1].Points[2]);modified.Roads[1].Points[2].X+=1
    assert(mathTerrain.signature(modified)~=mathTerrain.signature(c))
    local bad=table.clone(c);bad.ScenicReservations={{Id='Invalid',X=0,Z=0,Radius=30,Height=40,Blend=0}}
    assert(not pcall(mathTerrain.validate,bad))
end)
print(string.format("%d testes passaram; execução do engine Roblox NÃO TESTADA.",count))
