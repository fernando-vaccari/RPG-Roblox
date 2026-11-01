-- Isolated authoring fixtures. Exports actual factory geometry + authored poses.
-- Does not open/modify the delivered Place or GeneratedWorld.
local C=require(game.ReplicatedStorage.EldravynNPC.NPCConfig)
local Factory=require(game.ServerStorage.NPCInstall.R15Factory)
local Rig=require(game.ServerStorage.NPCV2Install.NPCRigAdapter)
local Visual=require(game.ServerStorage.NPCV2Install.NPCVisualFactory)
local Appearance=require(game.ReplicatedStorage.EldravynNPCVisualV2.NPCAppearanceConfig)
local Motion=require(game.ReplicatedStorage.EldravynNPCVisualV2.NPCMotion)
local definitions={};for _,d in C.Definitions do definitions[d.Id]=d end
local scenes={}
for _,sample in {
 {'Valoria_GuildMaster','Mestre de guilda • V1','V1',false},
 {'Valoria_GuildMaster','Mestre de guilda • V2','Idle',true},
 {'Valoria_GuildMaster','Mestre de guilda • documentos','Documents',true},
 {'Valoria_Ambient_Guard','Guarda • observação','Observe',true},
 {'Valoria_Blacksmith','Ferreiro • trabalho','Forge',true},
 {'Valoria_Magic','Mago • estudo','Study',true},
 {'Arkheim_General','Comerciante • negociação','Trade',true},
 {'Durakh_Inn','Estalajadeiro • atendimento','Serve',true},
}do
 local definition=assert(definitions[sample[1]],sample[1])
 local npc=Factory.create(workspace,definition,C.Roles[definition.Role],CFrame.new())
 if sample[4] then
  local result=Visual.build(Rig.inspect(npc),Appearance.forNPC(definition.Id,definition.Role,definition.City))
  for _,p in npc:GetChildren()do if p:IsA('BasePart') and Rig.LegacyDecor[p.Name] then p:Destroy()end end
  for part,changes in result.Changes do for key,value in changes do part[key]=value end end
  result.Folder.Parent=npc
 end
 local adorns={};for _,w in npc:GetDescendants()do if w:IsA('WeldConstraint') then table.insert(adorns,{Body=w.Part0,Part=w.Part1,Local=w.Part0.CFrame:ToObjectSpace(w.Part1.CFrame)})end end
 local pose=if sample[4] then Motion.pose(sample[3],1.6,.3,false) else {}
 local joints={};for _,j in npc:GetDescendants()do if j:IsA('Motor6D') then table.insert(joints,j)end end
 local solved={[npc.PrimaryPart]=true}
 for _=1,8 do for _,j in joints do if solved[j.Part0] and not solved[j.Part1] then
  local angles=pose[j.Name] or {0,0,0}
  j.Part1.CFrame=j.Part0.CFrame*j.C0*CFrame.Angles(table.unpack(angles))*j.C1:Inverse();solved[j.Part1]=true
 end end end
 for _,w in adorns do w.Part.CFrame=w.Body.CFrame*w.Local end
 local parts={}
 for _,p in npc:GetDescendants()do if p:IsA('BasePart') then
  local cf=p.CFrame
  table.insert(parts,{Name=p.Name,Class=p.ClassName,Size={p.Size.X,p.Size.Y,p.Size.Z},CFrame={cf.Position.X,cf.Position.Y,cf.Position.Z,table.unpack(cf.R)},
   Color={p.Color.R,p.Color.G,p.Color.B},Material=tostring(p.Material),Shape=tostring(p.Shape or ''),Transparency=p.Transparency or 0})
 end end
 table.insert(scenes,{Id=sample[1],Label=sample[2],Pose=sample[3],Parts=parts});npc:Destroy()
end
assert(env.VoxelWrites==0)
print('NPC_V2_PREVIEW:'..json({Scenes=scenes,StudioRender=false,Description='Geometria nativa do código; poses calculadas pelas mesmas juntas R15. Render offline.'}))
