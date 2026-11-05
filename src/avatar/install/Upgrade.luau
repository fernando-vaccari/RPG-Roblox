-- Editor-only mesh art migration, preserving the existing instances and gameplay.
local Upgrade={Version=3}
local root=script.Parent
local Catalog=require(root.Shared.AvatarCatalog)
local Appearance=require(root.AvatarAppearance)
local Run=game:GetService('RunService')
local SS=game:GetService('ServerStorage')
local function editor()assert(Run:IsStudio()and not Run:IsRunning(),'Pare Play/Run e use a Command Bar do Studio em Edit.')end
local function folder(name,parent)local f=Instance.new('Folder');f.Name=name;f.Parent=parent;return f end
local function ref(name,value,parent)local r=Instance.new('ObjectValue');r.Name=name;r.Value=value;r.Parent=parent;return r end
local function source(node)return(node.Source:gsub('\r\n','\n'))end
local function npcs()
 local group=workspace:FindFirstChild('EldravynNPCs');assert(group and group:GetAttribute('NPCInstallVersion')==1,'Instalação Stage 2 ausente; não será recriada.')
 local out,ids={},{}
 for _,npc in group:GetDescendants()do if npc:IsA('Model')and npc:GetAttribute('EldravynNPCId')then
  local id=npc:GetAttribute('EldravynNPCId');assert(not ids[id],'NPC duplicado: '..id);ids[id]=true
  local key=Catalog.NPCs[id];local def=key and Catalog.Models[key];assert(def and def.Role==npc:GetAttribute('NPCRole')and def.City==npc:GetAttribute('City'),'Tema/identidade incompatível: '..id)
  table.insert(out,{NPC=npc,Id=id})
 end end
 assert(#out>0,'Nenhum NPC existente');table.sort(out,function(a,b)return a.Id<b.Id end);return out
end
local function templateReady(key)
 local templates=root:FindFirstChild('ImportedTemplates');local t=templates and templates:FindFirstChild(key);assert(t,'Falta importar/registrar: '..key)
 for _,bone in Catalog.Models[key].Bones do local p=t:FindFirstChild(bone);assert(p and p:IsA('MeshPart'),'Mesh registrado incompleto: '..key..'/'..bone)end
end
local function extraPlan()
 local server=game:GetService('ServerScriptService'):FindFirstChild('MedievalServer');local services=server and server:FindFirstChild('Services');local enemy=services and services:FindFirstChild('EnemyService')
 if enemy then assert(enemy:IsA('ModuleScript')and(source(enemy)==source(root.EnemyServiceBaseline)or source(enemy)==source(root.EnemyServiceTemplate)),'EnemyService personalizado: revise o adaptador antes de aplicar; nenhuma alteração realizada.')end
 for parent,name in {[game:GetService('ReplicatedStorage')]='EldravynAvatarShared',[SS]='EldravynEnemyAvatarLibrary',[game:GetService('StarterPlayer').StarterPlayerScripts]='EldravynAvatarClient'}do assert(not parent:FindFirstChild(name),'Nome da camada Avatar já ocupado: '..name)end
 return enemy
end
function Upgrade.Report()
 editor();local items=npcs();local registered=require(root.RegisterImported).Report()
 print('[Avatar] '..#items..' NPCs existentes. Aplique somente após registrar todos os grupos FBX.')
 return{NPCs=#items,Registered=registered,ArtVersion=workspace:GetAttribute('EldravynAvatarArtVersion'),StudioValidated=false}
end
local function rollback(backup,strict)
 if strict then
  assert(backup:GetAttribute('State')=='Applied','Backup Avatar incompleto')
  for _,record in backup.Modules:GetChildren()do assert(record.Installed.Value and record.Installed.Value.Parent==record.TargetParent.Value and source(record.Installed.Value)==record:GetAttribute('InstalledSource'),'Módulo modificado após atualização; exporte suas mudanças antes de reverter.')end
  for _,record in backup.Models:GetChildren()do assert(record.NPC.Value and record.Visuals.Value and record.Visuals.Value.Parent==record.NPC.Value,'Camada V2 alterada depois do upgrade; restaure sua cópia antes de reverter.')end
  for _,record in backup.Sources:GetChildren()do assert(record.Value and record.Value.Parent and source(record.Value)==record:GetAttribute('Source'),'Biblioteca Avatar personalizada; exporte suas alterações antes de reverter.')end
 end
 for _,record in backup.Models:GetChildren()do
  for _,item in record.Installed:GetChildren()do if item.Value then item.Value:Destroy()end end
  for _,body in record.Bodies:GetChildren()do if body.Value then body.Value.Transparency=body:GetAttribute('Transparency')end end
  for _,old in record.Decor:GetChildren()do old.Parent=record.Visuals.Value end
  for _,key in {'VisualPartCount','VisualStyle','AvatarArtVersion'}do record.Visuals.Value:SetAttribute(key,record.VisualAttributes:GetAttribute(key))end
  record.NPC.Value:SetAttribute('AvatarArtVersion',nil)
 end
 if backup:GetAttribute('Mode')=='Stage2'and workspace:GetAttribute('EldravynNPCVisualVersion')==2 then
  require(root.CoreV2.NPCVisualUpgrade).Rollback()
  for _,row in npcs()do row.NPC:SetAttribute('AvatarArtVersion',nil)end
 end
 for _,record in backup.Modules:GetChildren()do
  if record.Installed.Value then record.Installed.Value:Destroy()end
  local original=record:FindFirstChild('Original');if original then original.Name='EnemyService';original.Parent=record.TargetParent.Value end
 end
 for _,record in backup.Additions:GetChildren()do if record.Value then record.Value:Destroy()end end
 workspace:SetAttribute('EldravynAvatarArtVersion',nil);backup:SetAttribute('State','RolledBack');backup.Name='EldravynAvatarRollback_'..game:GetService('HttpService'):GenerateGUID(false)
end
function Upgrade.Rollback()
 editor();local backup=SS:FindFirstChild('EldravynAvatarBackupV3');assert(backup,'Backup Avatar não encontrado');rollback(backup,true)
 print('[Avatar] Aparência anterior restaurada; NPCs, posições, serviços e mapa preservados.');return{Restored=true}
end
function Upgrade.Apply()
 editor();local rows=npcs();local version=workspace:GetAttribute('EldravynAvatarArtVersion')
 if version==3 then
  local backup=SS:FindFirstChild('EldravynAvatarBackupV3');assert(backup and backup:GetAttribute('State')=='Applied','Backup Avatar ausente')
  for _,row in rows do assert(row.NPC:GetAttribute('AvatarArtVersion')==3 and row.NPC:FindFirstChild('NPCV2Visuals'),'Instalação Avatar parcial')end
  assert(SS:FindFirstChild('EldravynEnemyAvatarLibrary')and game:GetService('ReplicatedStorage'):FindFirstChild('EldravynAvatarShared')and game:GetService('StarterPlayer').StarterPlayerScripts:FindFirstChild('EldravynAvatarClient'),'Dependência Avatar ausente; instalação parcial não será reaplicada.')
  return{Already=true,Count=#rows}
 end
 assert(version==nil and not SS:FindFirstChild('EldravynAvatarBackupV3'),'Versão/backup Avatar incompatível')
 for _,row in rows do assert(row.NPC:GetAttribute('AvatarArtVersion')==nil,'Atributo Avatar já ocupado');templateReady(Catalog.NPCs[row.Id])end
 for _,key in Catalog.Enemies do templateReady(key)end
 local enemy=extraPlan();local base=workspace:GetAttribute('EldravynNPCVisualVersion');assert(base==nil or base==2,'Base visual incompatível')
 local core=require(root.CoreV2.NPCVisualUpgrade);core.Plan()
 local rig=require(root.CoreV2.Authoring.NPCRigAdapter);local styles=require(root.CoreV2.Runtime.Shared.NPCAppearanceConfig)
 local prepared={}
 if base==2 then
  local ok,err=pcall(function()for _,row in rows do
   row.Rig=rig.inspect(row.NPC);row.Visual=Appearance.build(row.Rig,styles.forNPC(row.Id,row.NPC:GetAttribute('NPCRole'),row.NPC:GetAttribute('City')));table.insert(prepared,row.Visual.Folder)
  end end)
  if not ok then for _,p in prepared do p:Destroy()end;error(err)end
 end
 local backup=folder('EldravynAvatarBackupV3',SS);backup:SetAttribute('State','Preparing');backup:SetAttribute('Mode',if base==nil then'Stage2'else'V2')
 folder('Models',backup);folder('Modules',backup);folder('Additions',backup);folder('Sources',backup)
 local ok,err=pcall(function()
  if base==nil then core.Apply()
  else for _,row in rows do
   local npc=row.NPC;local record=folder(row.Id,backup.Models);ref('NPC',npc,record);ref('Visuals',npc.NPCV2Visuals,record);folder('Decor',record);folder('Bodies',record);folder('Installed',record)
   local attributes=folder('VisualAttributes',record);for _,key in {'VisualPartCount','VisualStyle','AvatarArtVersion'}do attributes:SetAttribute(key,npc.NPCV2Visuals:GetAttribute(key))end
   for body,changes in row.Visual.Changes do local r=ref(body.Name,body,record.Bodies);r:SetAttribute('Transparency',body.Transparency);body.Transparency=changes.Transparency end
   for _,child in npc.NPCV2Visuals:GetChildren()do child.Parent=record.Decor end
   for _,child in row.Visual.Folder:GetChildren()do ref(child.Name,child,record.Installed);child.Parent=npc.NPCV2Visuals end;row.Visual.Folder:Destroy()
   npc.NPCV2Visuals:SetAttribute('VisualPartCount',row.Visual.Count);npc.NPCV2Visuals:SetAttribute('VisualStyle',Catalog.NPCs[row.Id]);npc.NPCV2Visuals:SetAttribute('AvatarArtVersion',3)
  end end
  for _,row in rows do row.NPC:SetAttribute('AvatarArtVersion',3)end
  local shared=root.Shared:Clone();shared.Name='EldravynAvatarShared';ref('Shared',shared,backup.Additions);shared.Parent=game:GetService('ReplicatedStorage')
  local library=folder('EldravynEnemyAvatarLibrary');ref('Enemies',library,backup.Additions)
  local templates=folder('Templates',library)
  for _,key in Catalog.Enemies do root.ImportedTemplates[key]:Clone().Parent=templates end
  root.EnemyRuntime.Factory:Clone().Parent=library;root.EnemyRuntime.ProxyRig:Clone().Parent=library;root.Shared.AvatarCatalog:Clone().Parent=library
  library:SetAttribute('Ready',true);library.Parent=SS
  local client=root.Client:Clone();client.Name='EldravynAvatarClient';ref('Client',client,backup.Additions);client.Parent=game:GetService('StarterPlayer').StarterPlayerScripts
  client.Bootstrap.Disabled=false
  for _,addition in {shared,library,client}do for _,node in addition:GetDescendants()do if node:IsA('LuaSourceContainer')then local r=ref(node.Name,node,backup.Sources);r:SetAttribute('Source',source(node))end end end
  if enemy and source(enemy)~=source(root.EnemyServiceTemplate)then
   local record=folder('EnemyService',backup.Modules);ref('TargetParent',enemy.Parent,record)
   local new=root.EnemyServiceTemplate:Clone();new.Name='EnemyService';ref('Installed',new,record);record:SetAttribute('InstalledSource',source(new))
   local parent=enemy.Parent;enemy.Name='Original';enemy.Parent=record;new.Parent=parent
  end
  backup:SetAttribute('State','Applied');workspace:SetAttribute('EldravynAvatarArtVersion',3)
 end)
 if not ok then
  local restored,reason=pcall(rollback,backup,false);for _,f in prepared do if not f.Parent then f:Destroy()end end
  assert(restored,tostring(err)..' | Falha de reversão: '..tostring(reason));error('Atualização Avatar cancelada e revertida: '..tostring(err))
 end
 print('[Avatar] '..#rows..' NPCs atualizados com meshes importados. Biblioteca de inimigos instalada; spawns/combate não iniciados.')
 return{Updated=#rows,EnemyModels=14,EnemyServiceAdapted=enemy~=nil,Backup=backup.Name}
end
function Upgrade.PreviewEnemy(kind)
 editor();local library=SS:FindFirstChild('EldravynEnemyAvatarLibrary');assert(library and library:GetAttribute('Ready'),'Aplique após registrar as malhas')
 local previews=workspace:FindFirstChild('EldravynAvatarPreviews')or folder('EldravynAvatarPreviews',workspace)
 local model=require(library.Factory).create(previews,Catalog.Models[assert(Catalog.Enemies[kind],'Tipo desconhecido')].Label,Vector3.new(0,20,0),Color3.new(1,1,1),true,kind)
 model.PrimaryPart.Anchored=true;model:SetAttribute('AvatarPreviewOnly',true);return model
end
return Upgrade
