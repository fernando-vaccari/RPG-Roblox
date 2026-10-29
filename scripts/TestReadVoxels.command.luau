-- Optional read-only smoke test. Paste in Studio Command Bar, outside Play.
-- Compiled in cloud; MUST be executed in Roblox Studio for engine validation.
assert(game:GetService('RunService'):IsStudio() and not game:GetService('RunService'):IsRunning(),
    'Execute no editor do Roblox Studio, fora de Play/Run')
local guard=require(game.ServerStorage.MedievalWorldgen.TerrainGenerator)
local region=Region3.new(Vector3.new(0,0,0),Vector3.new(8,12,16))
local materials,occupancy=workspace.Terrain:ReadVoxels(region,4)
local expected=Vector3.new(2,3,4)
assert(typeof(materials.Size)=='Vector3' and materials.Size==expected,'materials.Size inesperado')
assert(typeof(occupancy.Size)=='Vector3' and occupancy.Size==expected,'occupancy.Size inesperado')
local occupied=false
for x=1,expected.X do for y=1,expected.Y do for z=1,expected.Z do
    local value=occupancy[x][y][z]
    assert(type(value)=='number' and value>=0 and value<=1,'Ocupação inválida')
    if value>0 then occupied=true end
end end end
local ok,err=pcall(guard.assertRegionEmpty,workspace.Terrain,region)
if occupied then
    assert(not ok and string.find(tostring(err),'Terrain existente',1,true),tostring(err))
else
    assert(ok,tostring(err))
end
print('[Eldravyn] PASSOU ReadVoxels real 2x3x4; região '..(if occupied then 'ocupada corretamente bloqueada' else 'vazia corretamente aceita')..'. Nenhum voxel escrito.')
