local TerrainMath = require(script.Parent.TerrainMath)
local TerrainGenerator = {}

function TerrainGenerator.region(c, chunk)
    return Region3.new(Vector3.new(chunk.X, c.MinY, chunk.Z),
        Vector3.new(chunk.X + chunk.Width, c.MaxY, chunk.Z + chunk.Depth))
end

-- ReadVoxels returns TWO 3D arrays, each with a non-array Size: Vector3 field.
-- Iterate numeric coordinates only; generalized iteration also visits Size.
-- Shared by continent, legacy dungeon and expedition preflights.
function TerrainGenerator.assertRegionEmpty(terrain, region, message)
    local _, occupancy = terrain:ReadVoxels(region, 4)
    local size = occupancy.Size
    assert(typeof(size) == "Vector3"
        and size.X >= 1 and size.Y >= 1 and size.Z >= 1
        and size.X % 1 == 0 and size.Y % 1 == 0 and size.Z % 1 == 0,
        "ReadVoxels retornou dimensões inválidas; geração bloqueada para preservar o Terrain.")
    for x = 1, size.X do
        local plane = occupancy[x]
        for y = 1, size.Y do
            local row = plane[y]
            for z = 1, size.Z do
                -- Any nonzero occupancy (including partial water) is occupied.
                -- Missing/unexpected cells also fail closed, never release writes.
                assert(row[z] == 0, message or "Terrain existente na área reservada. Use um Place novo ou altere o projeto; nada foi sobrescrito.")
            end
        end
    end
end

-- Executado em todos os chunks ANTES da primeira escrita. Não confunde
-- voxels de água com espaço livre e nunca limpa o Terrain global.
function TerrainGenerator.assertEmpty(terrain, c, chunks, checkpoint)
    for index, chunk in chunks do
        TerrainGenerator.assertRegionEmpty(terrain, TerrainGenerator.region(c, chunk))
        checkpoint(index, #chunks)
    end
end

function TerrainGenerator.writeChunk(terrain, c, chunk)
    local nx, ny, nz = chunk.Width/4, (c.MaxY-c.MinY)/4, chunk.Depth/4
    local materials, occupancy = table.create(nx), table.create(nx)
    for ix = 1, nx do
        materials[ix], occupancy[ix] = table.create(ny), table.create(ny)
        for iy = 1, ny do
            materials[ix][iy], occupancy[ix][iy] = table.create(nz), table.create(nz)
        end
        for iz = 1, nz do
            local h, water, surface = TerrainMath.column(c, chunk.X+(ix-0.5)*4, chunk.Z+(iz-0.5)*4)
            for iy = 1, ny do
                local y = c.MinY+(iy-0.5)*4
                local fill = math.clamp((h-y)/4 + 0.5, 0, 1)
                local material = Enum.Material.Rock
                if y >= h-8 and h <= c.BaseHeight+c.MountainHeight*0.65 then
                    material = Enum.Material[surface]
                elseif y < h-8 and y > h-20 then
                    material = Enum.Material.Ground
                end
                if fill == 0 and water and y < water then
                    fill = math.clamp((water-y)/4+0.5,0,1)
                    material = Enum.Material.Water
                elseif water and y >= h-8 then
                    material = Enum.Material.Mud
                end
                materials[ix][iy][iz] = if fill == 0 then Enum.Material.Air else material
                occupancy[ix][iy][iz] = fill
            end
        end
    end
    terrain:WriteVoxels(TerrainGenerator.region(c, chunk), 4, materials, occupancy)
end
return TerrainGenerator
