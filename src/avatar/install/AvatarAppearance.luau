-- True imported mesh shells bound to the existing R15, without replacing its rig.
local A={}
local Catalog=require(script.Parent.Shared.AvatarCatalog)
function A.build(rig,style)
 local key=Catalog.NPCs[style.Id];local def=key and Catalog.Models[key]
 assert(def and def.Role==style.Role and def.City==style.City,'Tema não registrado para '..tostring(style.Id))
 local templates=script.Parent:FindFirstChild('ImportedTemplates');local template=templates and templates:FindFirstChild(key)
 assert(template,'Importe e registre o FBX antes de atualizar: '..tostring(key))
 local folder=Instance.new('Folder');folder.Name='NPCV2Visuals';folder:SetAttribute('NPCVisualOwner',2);folder:SetAttribute('AvatarArtVersion',3)
 local changes={};local count=0
 local ok,err=pcall(function()
  local scale=rig.Humanoid.Parent:GetScale();assert(scale>0 and scale<10,'Escala do avatar incompatível')
  for _,bone in def.Bones do
   local source=template:FindFirstChild(bone);local body=rig.Bodies[bone];assert(source and source:IsA('MeshPart') and body,'Peça registrada incompatível: '..bone)
   local localFrame=CFrame.new(table.unpack(Catalog.R15[bone])):ToObjectSpace(source.CFrame)
   local components={localFrame:GetComponents()};for i=1,3 do components[i]*=scale end
   local mesh=source:Clone();mesh.Name='Avatar_'..bone;mesh.Size=source.Size*scale;mesh.CFrame=body.CFrame*CFrame.new(table.unpack(components));mesh.Anchored=false;mesh.CanCollide=false;mesh.CanQuery=false;mesh.CanTouch=false;mesh.Massless=true
   local weld=Instance.new('WeldConstraint');weld.Part0=body;weld.Part1=mesh;weld.Name='AvatarWeld';weld.Parent=mesh;mesh.Parent=folder;count+=1
  end
  for name,body in rig.Bodies do if name~='HumanoidRootPart' then changes[body]={Transparency=1}end end
 end)
 if not ok then folder:Destroy();error(err)end
 folder:SetAttribute('VisualPartCount',count);folder:SetAttribute('VisualStyle',key)
 return {Folder=folder,Changes=changes,Count=count}
end
return A
