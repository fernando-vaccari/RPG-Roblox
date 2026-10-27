-- Map-only generation/preflight/serialization contract. Simulated host, NOT Studio.
local config=require(game.ReplicatedStorage.MedievalRPG.Config.WorldConfig)
local terrainMath=require(game.ServerStorage.MedievalWorldgen.TerrainMath)
env.Height=function(x,z)return terrainMath.height(config,x,z)end
local world=require(game.ServerStorage.MedievalWorldgen.WorldGenerator)
local terrain=require(game.ServerStorage.MedievalWorldgen.TerrainGenerator)
local originalWriter=terrain.writeChunk
local root=world.GenerateMapScene()
assert(root:GetAttribute('Status')=='AwaitingTerrain' and root:GetAttribute('TerrainPending') and env.VoxelWrites==0)
local report=world.ValidateMapScene()
assert(report.Parts>10000 and report.SceneOnly and report.TerrainPending)
local pieces=#root:GetDescendants()
print('PASSOU MAPA: cenário materializado com '..report.Parts..' Parts, cinco cidades/três florestas e spawn, sem Terrain escrito.')
local identities={}
for _,point in root.IntegrationPoints:GetChildren()do
    local id=point:GetAttribute('IntegrationId')
    assert(type(id)=='string' and not identities[id],'Integração duplicada');identities[id]=true
end
assert(#root.NPCs:GetChildren()==0 and #root.EnemySpawns:GetChildren()==0 and #root.TreasureChests:GetChildren()==0)
for _,n in root:GetDescendants()do
    assert(not n:IsA('ProximityPrompt') and not n:IsA('Humanoid'),'Gameplay criado na tarefa de mapa')
    assert(not n:GetAttribute('NpcId') and not n:GetAttribute('EnemyId') and not n:GetAttribute('ChestId'))
end
print('PASSOU MAPA: somente integrações identificadas, sem NPC funcional, inimigo, baú de recompensa ou prompt.')
local kind=Instance.new('StringValue');kind.Name='MedievalPlaceKind';kind.Value='Map';kind.Parent=game.ServerStorage
env.TerrainOccupied=true
assert(not pcall(world.PrepareStudio) and env.VoxelWrites==0)
assert(root:GetAttribute('Status')=='AwaitingTerrain' and #root:GetDescendants()==pieces)
env.TerrainOccupied=false;env.OccupiedParts=true
assert(not pcall(world.PrepareStudio) and env.VoxelWrites==0 and workspace.GeneratedWorld==root)
env.OccupiedParts=false
print('PASSOU MAPA: Terrain e objetos externos bloqueiam a preparação antes da escrita, preservando toda a geometria.')
terrain.writeChunk=function()env.VoxelWrites+=1 end
world.PrepareStudio()
assert(root:GetAttribute('Status')=='Complete' and not root:GetAttribute('TerrainPending'))
assert(env.VoxelWrites==#terrainMath.chunks(config) and #root:GetDescendants()==pieces)
local written=env.VoxelWrites
world.PrepareStudio()
assert(env.VoxelWrites==written and #root:GetDescendants()==pieces)
print('PASSOU MAPA: completar Terrain usa a geometria existente; segunda preparação não regenera nenhum objeto ou voxel.')
local lighting=require(game.ServerStorage.MedievalWorldgen.MapEnvironment)
for _,preset in {'Dawn','Day','Sunset','Night','Rain','Fog','Storm'}do lighting.apply(preset)end
local lightingCount=#game.Lighting:GetChildren();lighting.apply('Day');assert(#game.Lighting:GetChildren()==lightingCount)
print('PASSOU MAPA: sete presets de ambiente usam propriedades da API refletida e não duplicam efeitos de iluminação.')
-- Emulate a fresh serialized scene; only host metadata is changed, never engine Terrain.
root:SetAttribute('Status','AwaitingTerrain');root:SetAttribute('ChunksWritten',0);root:SetAttribute('TerrainPending',true)
terrain.writeChunk=function()error('Falha de escrita de Terrain simulada')end
assert(not pcall(world.PrepareStudio))
assert(root:GetAttribute('Status')=='FailedPartialTerrain' and workspace.GeneratedWorld==root and #root:GetDescendants()==pieces)
assert(not pcall(world.PrepareStudio),'Reexecução sobre possível Terrain parcial deve ser bloqueada')
terrain.writeChunk=originalWriter
print('PASSOU MAPA: falha de Terrain conserva cenário/diagnóstico e impede repetição sobre escrita parcial.')
