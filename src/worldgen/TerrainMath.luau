-- Núcleo puro. math.noise está disponível tanto em Luau CLI quanto no Studio.
local TerrainMath = {}
local function finite(n)
    return type(n) == "number" and n == n and math.abs(n) < math.huge
end
local function smooth(t)
    t = math.clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end

function TerrainMath.validate(c)
    assert(c.ProjectId == "ProjectMedievalRPG", "Identidade de projeto inválida")
    for _, key in { "WorldSize", "Seed", "ChunkSize", "MinY", "MaxY", "BaseHeight",
        "Amplitude", "Frequency", "MountainHeight", "CityBlend", "MaxChunks" } do
        assert(finite(c[key]), "Configuração numérica inválida: " .. key)
    end
    assert(c.Resolution == 4, "Resolution deve ser 4")
    assert(c.WorldSize > 0 and c.WorldSize <= 8000 and c.WorldSize % 8 == 0, "WorldSize inválido")
    assert(c.Seed % 1 == 0 and math.abs(c.Seed) <= 1000000, "Seed deve ser inteiro entre -1000000 e 1000000")
    assert(c.ChunkSize >= 32 and c.ChunkSize <= 256 and c.ChunkSize % 4 == 0, "ChunkSize inválido")
    assert(c.MinY % 4 == 0 and c.MaxY % 4 == 0 and c.MinY < c.MaxY, "Limites verticais inválidos")
    assert(c.MaxY - c.MinY <= 512, "Volume vertical excessivo")
    assert(c.Amplitude >= 0 and c.Frequency > 0 and c.MountainHeight >= 0 and c.CityBlend > 0, "Relevo inválido")
    assert(c.BaseHeight - c.Amplitude > c.MinY + 4, "Solo pode ficar abaixo do volume")
    assert(c.BaseHeight + c.Amplitude + c.MountainHeight < c.MaxY - 4, "Relevo pode ultrapassar MaxY")
    assert(c.QualityProfiles[c.Quality], "Qualidade inválida")
    assert(#c.Cities >= 4 and #c.Forests >= 2, "Conteúdo legado deve ser preservado")
    local ids = {}
    for _, regions in { c.Cities, c.Forests } do
        for _, region in regions do
            assert(type(region.Id) == "string" and not ids[region.Id], "ID ausente ou duplicado")
            ids[region.Id] = true
            for _, key in { "X", "Z", "Radius" } do
                assert(finite(region[key]), "Região inválida: " .. key)
            end
            assert(region.Radius > 0, "Raio deve ser positivo")
            assert(math.abs(region.X) + region.Radius + c.CityBlend < c.WorldSize / 2
                and math.abs(region.Z) + region.Radius + c.CityBlend < c.WorldSize / 2, "Região fora do continente")
        end
    end
    for i, city in c.Cities do
        assert(finite(city.Height) and city.Height > c.MinY + 4 and city.Height < c.MaxY - 4, "Altura da cidade inválida")
        for j = i + 1, #c.Cities do
            local other = c.Cities[j]
            local distance = math.sqrt((city.X - other.X)^2 + (city.Z - other.Z)^2)
            assert(distance > city.Radius + other.Radius + 2 * c.CityBlend, "Reservas de cidades se sobrepõem")
        end
    end
    assert(finite(c.DungeonEntrance.X) and finite(c.DungeonEntrance.Z), "Entrada inválida")
    assert(math.abs(c.DungeonEntrance.X) < c.WorldSize/2 and math.abs(c.DungeonEntrance.Z) < c.WorldSize/2, "Entrada fora do mapa")
    assert(math.ceil(c.WorldSize / c.ChunkSize)^2 <= c.MaxChunks, "Orçamento de chunks excedido")
    local profile=c.QualityProfiles[c.Quality]
    for key,limit in {TreesPerForest=1000,DecorationBudget=2000,ActiveEnemies=64} do
        assert(finite(profile[key]) and profile[key]%1==0 and profile[key]>0 and profile[key]<=limit,"Orçamento inválido: "..key)
    end
    assert(type(c.River)=="table" and type(c.Roads)=="table" and #c.Roads>=3,"Rio e rotas são obrigatórios")
    for _,key in {"Z","Meander","Frequency","HalfWidth","BankWidth","WaterY","BedY"} do assert(finite(c.River[key]),"Rio inválido: "..key) end
    local river=c.River
    assert(river.HalfWidth>=8 and river.BankWidth>=24 and river.Meander>=0 and river.Frequency>0,"Margens do rio inválidas")
    assert(river.BedY>c.MinY+4 and river.BedY<river.WaterY and river.WaterY<c.MaxY-4,"Alturas do rio inválidas")
    assert(math.abs(river.Z)+river.Meander+river.HalfWidth+river.BankWidth<c.WorldSize/2,"Rio fora do continente")
    local roadIds={}
    for _,road in c.Roads do
        assert(type(road.Id)=="string" and not roadIds[road.Id],"ID de estrada inválido/duplicado");roadIds[road.Id]=true
        for _,point in {road.A,road.B} do
            assert(type(point)=="table" and finite(point.X) and finite(point.Z) and finite(point.H),"Extremo de estrada inválido")
            assert(math.abs(point.X)<c.WorldSize/2 and math.abs(point.Z)<c.WorldSize/2 and point.H>river.WaterY+8 and point.H<c.MaxY-4,"Estrada fora do volume transitável")
        end
        local length=math.sqrt((road.A.X-road.B.X)^2+(road.A.Z-road.B.Z)^2)
        assert(length>=32 and math.abs(road.A.H-road.B.H)/length<0.15,"Estrada curta/demasiado íngreme")
    end
    return true
end

function TerrainMath.baseHeight(c, x, z)
    local seed = c.Seed * 0.0137
    local f = c.Frequency
    local hills = math.noise(x*f, z*f, seed) * 0.72
        + math.noise(x*f*2, z*f*2, seed + 19) * 0.28
    local west = math.exp(-((x + c.WorldSize*0.39)/(c.WorldSize*0.13))^2)
    local north = math.exp(-((z + c.WorldSize*0.40)/(c.WorldSize*0.12))^2)
    local ridge = (west * 0.7 + north * 0.3) * c.MountainHeight
    local h = c.BaseHeight + hills*c.Amplitude + ridge
    for _, city in c.Cities do
        local distance = math.sqrt((x-city.X)^2 + (z-city.Z)^2)
        local blend = smooth((distance-city.Radius)/c.CityBlend)
        h = city.Height + (h-city.Height)*blend
    end
    return h
end

function TerrainMath.signature(c)
    local tokens={}
    for _,key in {"WorldSize","Seed","MinY","MaxY","BaseHeight","Amplitude","Frequency","MountainHeight","CityBlend"} do table.insert(tokens,tostring(c[key])) end
    if c.River then for _,key in {"Z","Meander","Frequency","HalfWidth","BankWidth","WaterY","BedY"} do table.insert(tokens,tostring(c.River[key])) end end
    if c.Lake then for _,key in {'X','Z','Radius','Bank','WaterY','BedY'} do table.insert(tokens,tostring(c.Lake[key])) end end
    if c.Guild then for _,key in {'X','Z','Height'} do table.insert(tokens,tostring(c.Guild[key])) end end
    for _,city in c.Cities do for _,key in {"Id","X","Z","Radius","Height"} do table.insert(tokens,tostring(city[key])) end end
    for _,forest in c.Forests do for _,key in {"Id","X","Z","Radius"} do table.insert(tokens,tostring(forest[key])) end end
    for _,road in c.Roads or {} do
        table.insert(tokens,road.Id)
        for _,p in {road.A,road.B} do for _,key in {"X","Z","H"} do table.insert(tokens,tostring(p[key])) end end
    end
    return table.concat(tokens,"|")
end

function TerrainMath.segment(x,z,a,b)
    local dx,dz=b.X-a.X,b.Z-a.Z
    local t=math.clamp(((x-a.X)*dx+(z-a.Z)*dz)/(dx*dx+dz*dz),0,1)
    return math.sqrt((x-a.X-t*dx)^2+(z-a.Z-t*dz)^2),t
end
function TerrainMath.riverDistance(c,x,z)
    if not c.River then return math.huge end
    return math.abs(z-(c.River.Z+c.River.Meander*math.sin(x*c.River.Frequency)))
end
function TerrainMath.height(c,x,z)
    local h=TerrainMath.baseHeight(c,x,z)
    local river=TerrainMath.riverDistance(c,x,z)
    for _,road in c.Roads or {} do
        local distance,t=TerrainMath.segment(x,z,road.A,road.B)
        local weight=1-smooth((distance-14)/32)
        h=h+(road.A.H+(road.B.H-road.A.H)*t-h)*weight
    end
    -- Cidades permanecem planas; leito só corta fora de suas reservas.
    if c.River then
        local r=c.River
        local blend=smooth((river-r.HalfWidth)/r.BankWidth)
        h=r.BedY+(h-r.BedY)*blend
    end
    for _,city in c.Cities do
        local d=math.sqrt((x-city.X)^2+(z-city.Z)^2)
        local blend=smooth((d-city.Radius)/c.CityBlend)
        h=city.Height+(h-city.Height)*blend
    end
    if c.Guild then
        local g=c.Guild;local d=math.sqrt((x-g.X)^2+(z-g.Z)^2)
        h=g.Height+(h-g.Height)*smooth((d-100)/48)
    end
    if c.Lake then
        local l=c.Lake;local d=math.sqrt((x-l.X)^2+(z-l.Z)^2)
        h=l.BedY+(h-l.BedY)*smooth((d-l.Radius)/l.Bank)
    end
    return h
end
function TerrainMath.column(c,x,z)
    local h=TerrainMath.height(c,x,z)
    local water=if c.River and TerrainMath.riverDistance(c,x,z)<c.River.HalfWidth+c.River.BankWidth and h<c.River.WaterY then c.River.WaterY else nil
    if c.Lake then local l=c.Lake;if (x-l.X)^2+(z-l.Z)^2<(l.Radius+l.Bank)^2 and h<l.WaterY then water=l.WaterY end end
    local bank=c.River and TerrainMath.riverDistance(c,x,z)<c.River.HalfWidth+c.River.BankWidth and h<c.River.WaterY+7
    return h,water,if bank then (if water then 'Mud' else 'Sand')else 'Grass'
end

function TerrainMath.chunks(c)
    local result = {}
    local half = c.WorldSize/2
    for x = -half, half-1, c.ChunkSize do
        for z = -half, half-1, c.ChunkSize do
            table.insert(result, { X=x, Z=z, Width=math.min(c.ChunkSize, half-x), Depth=math.min(c.ChunkSize, half-z) })
        end
    end
    return result
end

function TerrainMath.voxel(c, x, y, z)
    local h,water,surface = TerrainMath.column(c, x, z)
    local occupancy = math.clamp((h-y)/c.Resolution + 0.5, 0, 1)
    local material = "Rock"
    if y >= h-8 then
        material = if h > c.BaseHeight + c.MountainHeight*0.65 then "Rock" else surface
    elseif y > h-20 then
        material = "Ground"
    end
    if occupancy==0 and water and y<water then occupancy=math.clamp((water-y)/4+0.5,0,1);material='Water'
    elseif water and y>=h-8 then material='Mud' end
    if occupancy==0 then material='Air' end
    return material, occupancy
end
return TerrainMath
