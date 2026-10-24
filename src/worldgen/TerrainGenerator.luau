local TerrainMath = require(script.Parent.TerrainMath)
local TerrainGenerator = {}

function TerrainGenerator.region(c, chunk)
    return Region3.new(Vector3.new(chunk.X, c.MinY, chunk.Z),
        Vector3.new(chunk.X + chunk.Width, c.MaxY, chunk.Z + chunk.Depth))
end

-- Executado em todos os chunks ANTES da primeira escrita. Não confunde
-- voxels de água com espaço livre e nunca limpa o Terrain global.
function TerrainGenerator.assertEmpty(terrain, c, chunks, checkpoint)
    for index, chunk in chunks do
        local _, occupancy = terrain:ReadVoxels(TerrainGenerator.region(c, chunk), 4)
        for _, plane in occupancy do
            for _, row in plane do
                for _, value in row do
                    assert(value == 0, "Terrain existente na área reservada. Use um Place novo ou altere o projeto; nada foi sobrescrito.")
                end
            end
        end
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
