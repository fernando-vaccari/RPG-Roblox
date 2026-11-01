local Appearance=require(game.ReplicatedStorage.EldravynNPCVisualV2.NPCAppearanceConfig)
local Factory=require(game.ServerStorage.NPCV2Install.NPCVisualFactory)
local Rig=require(game.ServerStorage.NPCV2Install.NPCRigAdapter)
local Base=require(game.ServerStorage.NPCInstall.R15Factory)
local Config=require(game.ReplicatedStorage.EldravynNPC.NPCConfig)
local root=Instance.new('Folder');root.Name='EldravynNPCs';root:SetAttribute('NPCInstallVersion',1);root.Parent=workspace
local max,total,models=0,0,{}
for i,def in Config.Definitions do
 local npc=Base.create(root,def,Config.Roles[def.Role],CFrame.new(i*10,0,0))
 local rig=Rig.inspect(npc);local style=Appearance.forNPC(def.Id,def.Role,def.City)
 local visual=Factory.build(rig,style)
 max=math.max(max,visual.Count);total+=visual.Count
 assert(visual.Count>=55 and visual.Count<=Appearance.MaxVisualParts,def.Id..' count '..visual.Count)
 for _,node in visual.Folder:GetDescendants()do
  if node:IsA('BasePart') then assert(not node.CanCollide and not node.CanQuery and not node.CanTouch and node.Massless)end
  assert(not node:IsA('BaseScript') and not node:IsA('ParticleEmitter'))
 end
 assert(npc.PrimaryPart.CFrame.Position.X==i*10 and npc:GetAttribute('NPCRole')==def.Role)
 table.insert(models,npc)
end
assert(#models==66 and env.VoxelWrites==0)
print('PASSOU V2: 66 aparências construídas sem alterar rig/identidade/posição; '..total..' adornos, máximo '..max..' por NPC.')
