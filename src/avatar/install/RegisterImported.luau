-- Studio authoring only; geometry is imported/published by Roblox's 3D Importer.
-- Never loads catalog models, executes imported code, or invents asset IDs.
local Register={}
local Catalog=require(script.Parent.Shared.AvatarCatalog)
local Frame=require(script.Parent.Shared.ImportFrame)
local function editor()local r=game:GetService('RunService');assert(r:IsStudio() and not r:IsRunning(),'Use o editor do Studio, com Play/Run parado.')end
local function vec(v)return {v.X,v.Y,v.Z}end
local function folder(name,parent)local f=Instance.new('Folder');f.Name=name;f.Parent=parent;return f end
local function normalized(part,basis,origin)
 local p=Frame.point(basis,vec(part.Position));local c={part.CFrame:GetComponents()}
 local x=Frame.direction(basis,{c[4],c[7],c[10]});local y=Frame.direction(basis,{c[5],c[8],c[11]});local z=Frame.direction(basis,{c[6],c[9],c[12]})
 return CFrame.new(p[1]-origin[1],p[2]-origin[2],p[3]-origin[3],x[1],y[1],z[1],x[2],y[2],z[2],x[3],y[3],z[3])
end
local function texture(part)
 local sa=part:FindFirstChildOfClass('SurfaceAppearance');local id=if sa then sa.ColorMap else part.TextureID
 assert(Frame.asset(id),'Atlas não publicado/importado em '..part.Name..'. Importe as texturas no Studio junto do FBX.')
 if sa then for _,key in {'NormalMap','MetalnessMap','RoughnessMap'}do local value=sa[key];assert(value=='' or Frame.asset(value),'Mapa PBR inválido: '..part.Name..'/'..key)end end
 return sa
end
function Register.Apply(imported)
 editor();assert(typeof(imported)=='Instance' and imported~=workspace and imported:IsDescendantOf(game),'Selecione o Model de UM arquivo FBX importado, não o Workspace inteiro.')
 local samples,parts,seen,group={},{},{},nil
 local revisionName='ELDRAVYN_ART_'..Catalog.ArtRevision:gsub('%W','_');local revisionFound=false
 for _,node in imported:GetDescendants()do
  assert(not node:IsA('LuaSourceContainer'),'O grupo importado contém scripts; somente o FBX original é aceito.')
  local marker=node.Name:match('^ELDRAVYN_CAL_([OXYZ])$')
  if node.Name==revisionName then assert(node:IsA('BasePart')and not revisionFound,'Marcador de revisão duplicado/inválido');revisionFound=true
  elseif marker then assert(node:IsA('BasePart') and not samples[marker],'Marcador duplicado/inválido');samples[marker]=vec(node.Position)
  elseif node:IsA('MeshPart') then
   local key,bone=node.Name:match('^(.-)__(.+)$');local def=key and Catalog.Models[key]
   assert(def and table.find(def.Bones,bone),'Nome de mesh desconhecido: '..node.Name..'. Preserve os nomes durante a importação.')
   assert(group==nil or group==def.Group,'Mais de um grupo FBX selecionado; registre cada arquivo separadamente.');group=def.Group
   assert(not seen[node.Name],'Mesh duplicado: '..node.Name);seen[node.Name]=true
   assert(Frame.asset(node.MeshId),'Mesh sem ID publicado: '..node.Name);texture(node)
   parts[key]=parts[key]or{};parts[key][bone]=node
  end
 end
 assert(group,'Nenhuma malha de avatar encontrada');assert(revisionFound,'Revisão do FBX incompatível. Importe os arquivos arredondados desta entrega, preservando o marcador de revisão.');local basis=Frame.basis(samples)
 local count=0
 for key,def in Catalog.Models do if def.Group==group then
  assert(parts[key],'Modelo ausente: '..key);for _,bone in def.Bones do assert(parts[key][bone],'Peça ausente: '..key..'/'..bone)end;count+=1
 end end
 local root=script.Parent;local installed=root:FindFirstChild('ImportedTemplates')
 if installed then
  for key in parts do assert(not installed:FindFirstChild(key),'Grupo já registrado: '..group..'. Mantenha a biblioteca existente ou importe uma nova cópia do pacote para atualizar assets.')end
 end
 local prepared=folder('PreparedAvatarTemplates')
 local ok,err=pcall(function()
  for key,nodes in parts do
   local model=folder(key,prepared);local def=Catalog.Models[key];model:SetAttribute('AvatarGroup',group);model:SetAttribute('AvatarRigKind',def.Kind)
   for bone,node in nodes do
    local clone=node:Clone();clone.Name=bone
    -- MeshPart content is retained; only audited appearance children survive.
    for _,child in clone:GetChildren()do if not child:IsA('SurfaceAppearance') then child:Destroy()end end
    clone.Size=node.Size/basis.Scale;clone.CFrame=normalized(node,basis,def.Origin)
    clone.Anchored=false;clone.Massless=true;clone.CanCollide=false;clone.CanQuery=false;clone.CanTouch=false;clone.DoubleSided=true
    clone:SetAttribute('AvatarBone',bone);clone:SetAttribute('AvatarTemplate',key);clone:SetAttribute('VisualDetail',1);clone.Parent=model
   end
  end
 end)
 if not ok then prepared:Destroy();error(err)end
 if not installed then installed=folder('ImportedTemplates',root);installed:SetAttribute('AvatarVersion',3)end
 for _,model in prepared:GetChildren()do model.Parent=installed end;prepared:Destroy()
 print('[Avatar] '..count..' modelos registrados do grupo '..group..'. Nenhum NPC/mapa foi alterado.')
 return {Group=group,Registered=count}
end
function Register.Report()
 local installed=script.Parent:FindFirstChild('ImportedTemplates');local missing={};local ready=0
 for key in Catalog.Models do if installed and installed:FindFirstChild(key) then ready+=1 else table.insert(missing,key)end end
 table.sort(missing);print('[Avatar] '..ready..' modelos registrados; '..#missing..' pendentes de Import 3D.');return {Ready=ready,Missing=missing}
end
function Register.SetPBR(colorMap,metalnessMap,roughnessMap)
 editor();assert(workspace:GetAttribute('EldravynAvatarArtVersion')==nil,'Configure PBR antes de Apply; reverta a camada Avatar para editar os templates.')
 for _,id in {colorMap,metalnessMap,roughnessMap}do assert(Frame.asset(id),'Use o ID real de cada PNG publicado na sua conta.')end
 local templates=script.Parent:FindFirstChild('ImportedTemplates');assert(templates,'Registre os FBX antes dos mapas PBR')
 local count=0
 for _,p in templates:GetDescendants()do if p:IsA('MeshPart')then
  local surface=p:FindFirstChildOfClass('SurfaceAppearance')or Instance.new('SurfaceAppearance');surface.Name='AvatarPBR';surface.ColorMap=colorMap;surface.MetalnessMap=metalnessMap;surface.RoughnessMap=roughnessMap;surface.Parent=p;count+=1
 end end
 return{Meshes=count}
end
return Register
