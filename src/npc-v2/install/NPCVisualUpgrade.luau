-- Editor-only additive visual migration. Original NPC instances and services survive.
local Upgrade={Version=2}
local Http=game:GetService('HttpService')
local function source(node)
 local ok,value=pcall(function()return node.Source end)
 assert(ok and type(value)=='string','Execute pela Command Bar do Studio em Edit; leitura de Source não autorizada.')
 return (value:gsub('\r\n','\n'))
end
local function folder(name,parent)local n=Instance.new('Folder');n.Name=name;n.Parent=parent;return n end
local function ref(name,value,parent)local n=Instance.new('ObjectValue');n.Name=name;n.Value=value;n.Parent=parent;return n end
local function enumName(value)return tostring(value):match('([^%.]+)$')end
local visualAttributes={'NPCVisualVersion','NPCVisualStyle','NPCV2State','NPCV2Speaker','NPCV2PatrolFloorValid'}
local function matchingTree(installed,template)
 if not installed or installed.ClassName~=template.ClassName then return false end
 if template:IsA('LuaSourceContainer') and source(installed)~=source(template) then return false end
 if #installed:GetChildren()~=#template:GetChildren() then return false end
 for _,child in template:GetChildren()do if not matchingTree(installed:FindFirstChild(child.Name),child) then return false end end
 return true
end
local function editor()assert(game:GetService('RunService'):IsStudio() and not game:GetService('RunService'):IsRunning(),'Pare Play/Run. Atualize uma cópia salva no editor do Studio.')end
local function context()
 local package=script.Parent
 local npcs=workspace:FindFirstChild('EldravynNPCs');assert(npcs and npcs:GetAttribute('NPCInstallVersion')==1,'Instalação NPC V1 compatível não encontrada; nada será criado do zero.')
 local rs=game:GetService('ReplicatedStorage');local ss=game:GetService('ServerScriptService')
 local shared=rs:FindFirstChild('EldravynNPC');local server=ss:FindFirstChild('EldravynNPC')
 local starter=game:GetService('StarterPlayer'):FindFirstChild('StarterPlayerScripts');local client=starter and starter:FindFirstChild('EldravynNPCClient')
 assert(shared and server and client and shared:FindFirstChild('NPCConfig') and shared:FindFirstChild('PlacementConfig'),'Dependências NPC V1 ausentes')
 assert(server:FindFirstChild('DialogueService') and server:FindFirstChild('NPCDataService') and client:FindFirstChild('NPCDialogueClient'),'Serviços originais ausentes')
 for _,pair in {{shared,{'NPCConfig','PlacementConfig','Registry','Rules','DialogueConfig','ShopConfig','QuestConfig','DungeonTicketConfig'}},{server,{'NPCService','AmbientService','DataService','NPCDataService','NPCActionService','DialogueService','QuestService','PurchaseService','Placement'}},{client,{'NPCDialogueClient'}}}do
  for _,name in pair[2]do local dependency=pair[1]:FindFirstChild(name);assert(dependency and dependency:IsA('ModuleScript'),'Dependência V1 ausente/incompatível: '..name)end
 end
 local bootstrap=server:FindFirstChild('Bootstrap');assert(bootstrap and bootstrap:IsA('Script'),'Bootstrap original ausente; V2 não cria outro servidor')
 assert(package:FindFirstChild('Runtime') and package:FindFirstChild('Baselines') and package:FindFirstChild('Authoring'),'Pacote V2 incompleto')
 local replacements={{Parent=server,Name='NPCService',Template=package.Runtime.Replacements.NPCService},{Parent=server,Name='AmbientService',Template=package.Runtime.Replacements.AmbientService},{Parent=client,Name='NPCInteractionClient',Template=package.Runtime.Replacements.NPCInteractionClient}}
 return {Package=package,NPCs=npcs,Shared=shared,Server=server,Client=client,RS=rs,SS=ss,Replacements=replacements}
end
function Upgrade.Plan()
 editor();local ctx=context();local rig=require(ctx.Package.Authoring.NPCRigAdapter);local appearance=require(ctx.Package.Runtime.Shared.NPCAppearanceConfig)
 local list,seen={},{}
 for _,npc in ctx.NPCs:GetDescendants()do if npc:IsA('Model') and npc:GetAttribute('EldravynNPCId') then
  local id=npc:GetAttribute('EldravynNPCId');assert(not seen[id],'NPC duplicado antes da atualização: '..id);seen[id]=true
  local structure=rig.inspect(npc);local style=appearance.forNPC(id,npc:GetAttribute('NPCRole'),npc:GetAttribute('City'))
  table.insert(list,{NPC=npc,Id=id,Rig=structure,Style=style,Position=structure.Bodies.HumanoidRootPart.CFrame})
 end end
 assert(#list>0,'Nenhum NPC identificado; mapa preservado');table.sort(list,function(a,b)return a.Id<b.Id end)
 local version=workspace:GetAttribute('EldravynNPCVisualVersion')
 assert(version==nil or version==2,'Versão visual desconhecida; migração interrompida')
 if version==2 then
  local backup=ctx.SS:FindFirstChild('EldravynNPCVisualBackupV2')
  assert(backup and backup:GetAttribute('State')=='Applied','Backup V2 ausente/incompleto; não repetir uma migração parcial')
  for _,row in list do assert(row.NPC:GetAttribute('NPCVisualVersion')==2 and row.NPC:FindFirstChild('NPCV2Visuals'),'Instalação mista; reverta/inspecione antes de atualizar novamente')end
  assert(ctx.RS:FindFirstChild('EldravynNPCVisualV2'),'Dependência visual ausente')
  for _,row in ctx.Replacements do assert(row.Parent:FindFirstChild(row.Name),'Adaptador ausente: '..row.Name)end
  for _,pair in {{ctx.Package.Runtime.Shared,ctx.RS.EldravynNPCVisualV2},{ctx.Package.Runtime.Server,ctx.Server},{ctx.Package.Runtime.Client,ctx.Client}}do
   for _,module in pair[1]:GetChildren()do assert(pair[2]:FindFirstChild(module.Name),'Dependência V2 ausente: '..module.Name)end
  end
  return {Already=true,Count=#list,Context=ctx,List=list}
 end
 assert(not ctx.SS:FindFirstChild('EldravynNPCVisualBackupV2'),'Backup anterior existe; inspecione ou reverta antes de continuar')
 assert(not ctx.RS:FindFirstChild('EldravynNPCVisualV2'),'Nome da biblioteca visual já ocupado')
 for _,row in list do assert(row.NPC:GetAttribute('NPCVisualVersion')==nil and not row.NPC:FindFirstChild('NPCV2Visuals'),'Camada visual preexistente não será sobrescrita')end
 for _,row in ctx.Replacements do
  local old=row.Parent:FindFirstChild(row.Name);assert(old,'Adaptador original ausente: '..row.Name)
  assert(old.ClassName==row.Template.ClassName,'Tipo do adaptador incompatível: '..row.Name)
  local baseline=ctx.Package.Baselines:FindFirstChild(row.Name);assert(baseline,'Baseline ausente')
  local current=source(old)
  assert(current==source(baseline) or current==source(row.Template),'Script customizado: '..row.Name..'. Revise a adaptação; nenhuma mudança aplicada.')
  row.Original=old;row.Replace=current~=source(row.Template)
 end
 for _,pair in {{ctx.Package.Runtime.Server,ctx.Server},{ctx.Package.Runtime.Client,ctx.Client}}do
  for _,module in pair[1]:GetChildren()do assert(not pair[2]:FindFirstChild(module.Name),'Nome V2 já ocupado: '..module.Name)end
 end
 -- Return plain facts from Report(); Apply keeps these object references private in this module.
 return {Already=false,Count=#list,Context=ctx,List=list}
end
function Upgrade.Report()
 local plan=Upgrade.Plan();local ids={};for _,row in plan.List do table.insert(ids,row.Id)end
 local report={Version=2,Already=plan.Already,Count=plan.Count,NPCs=ids,MapChanges=0,DataStoreChanges=0,PublishedAssetsRequired=0}
 print('[NPC V2] '..Http:JSONEncode(report));return report
end
local function rollback(backup,strict)
 if strict then
  assert(backup:GetAttribute('State')=='Applied','Backup não está em estado reversível')
  for _,record in backup.Modules:GetChildren()do
   local installed=record.Installed.Value;local parent=record.TargetParent.Value
   assert(installed and installed.Parent==parent and source(installed)==record.Source.Value,'Módulo V2 foi alterado após upgrade; rollback automático interrompido: '..record.Name)
  end
  for _,record in backup.Additions:GetChildren()do
   assert(record.Value and record.Value.Parent==record.TargetParent.Value and matchingTree(record.Value,record.Snapshot),'Biblioteca V2 foi alterada; salve sua customização antes do rollback: '..record.Name)
  end
 end
 for _,record in backup.Models:GetChildren()do
  local npc=record.NPC.Value
  if npc then
   local visuals=record:FindFirstChild('InstalledVisuals');if visuals and visuals.Value then visuals.Value:Destroy()end
   for _,bodyRecord in record.Bodies:GetChildren()do
    local part=bodyRecord.Target.Value
    if part then
     part.Color=bodyRecord:GetAttribute('Color');part.Material=Enum.Material[bodyRecord:GetAttribute('Material')]
     if bodyRecord:GetAttribute('Size') then part.Size=bodyRecord:GetAttribute('Size')end
     if bodyRecord:GetAttribute('Shape') then part.Shape=Enum.PartType[bodyRecord:GetAttribute('Shape')]end
     if bodyRecord:GetAttribute('Transparency')~=nil then part.Transparency=bodyRecord:GetAttribute('Transparency')end
    end
   end
   for _,item in record.Decor:GetChildren()do item.Parent=npc end
   for _,key in visualAttributes do npc:SetAttribute(key,record.Attributes:GetAttribute(key))end
  end
 end
 for _,record in backup.Modules:GetChildren()do
  if record.Installed.Value then record.Installed.Value:Destroy()end
  local original=record:FindFirstChild('Original');local parent=record.TargetParent.Value
  if original and parent then
   original.Name=record:GetAttribute('OriginalName');original.Parent=parent
   if original:IsA('BaseScript') then original.Disabled=record:GetAttribute('OriginalDisabled')end
  end
 end
 for _,record in backup.Additions:GetChildren()do if record.Value then record.Value:Destroy()end end
 workspace:SetAttribute('EldravynNPCVisualVersion',nil)
 backup:SetAttribute('State','RolledBack')
 -- Keep the audit record, now empty of live original objects; never delete a NPC.
 backup.Name='EldravynNPCVisualRollback_'..Http:GenerateGUID(false)
 return true
end
function Upgrade.Rollback()
 editor();local ctx=context();local backup=ctx.SS:FindFirstChild('EldravynNPCVisualBackupV2');assert(backup,'Backup V2 não encontrado')
 rollback(backup,true);print('[NPC V2] Visual/controle V1 restaurados. NPCs, posições, serviços e mapa preservados.');return {Restored=true}
end
function Upgrade.Apply()
 local plan=Upgrade.Plan();if plan.Already then print('[NPC V2] Já aplicado; nenhum NPC duplicado.');return {Already=true,Count=plan.Count}end
 local ctx=plan.Context;local factory=require(ctx.Package.Authoring.NPCVisualFactory);local rig=require(ctx.Package.Authoring.NPCRigAdapter)
 local prepared={}
 local ready,prepareError=pcall(function()for _,row in plan.List do row.Visual=factory.build(row.Rig,row.Style);table.insert(prepared,row.Visual.Folder)end end)
 if not ready then for _,f in prepared do f:Destroy()end;error(prepareError)end
 local backup=folder('EldravynNPCVisualBackupV2',ctx.SS);backup:SetAttribute('State','Preparing');backup:SetAttribute('Version',2)
 folder('Models',backup);folder('Modules',backup);folder('Additions',backup)
 local ok,err=pcall(function()
  for _,row in plan.List do
   local record=folder(row.Id,backup.Models);ref('NPC',row.NPC,record);folder('Bodies',record);folder('Decor',record)
   local attributes=folder('Attributes',record);for _,key in visualAttributes do attributes:SetAttribute(key,row.NPC:GetAttribute(key))end
   for part,change in row.Visual.Changes do
    local body=folder(part.Name,record.Bodies);ref('Target',part,body)
    body:SetAttribute('Color',part.Color);body:SetAttribute('Material',enumName(part.Material))
    if change.Size then body:SetAttribute('Size',part.Size)end
    if change.Shape then body:SetAttribute('Shape',enumName(part.Shape or Enum.PartType.Block))end
    if change.Transparency~=nil then body:SetAttribute('Transparency',part.Transparency)end
    for key,value in change do part[key]=value end
   end
   for _,child in row.NPC:GetChildren()do if child:IsA('BasePart') and rig.LegacyDecor[child.Name] then child.Parent=record.Decor end end
   ref('InstalledVisuals',row.Visual.Folder,record);row.Visual.Folder.Parent=row.NPC
   row.NPC:SetAttribute('NPCVisualVersion',2);row.NPC:SetAttribute('NPCVisualStyle',row.Style.Style)
   assert(row.Rig.Bodies.HumanoidRootPart.CFrame==row.Position,'Root foi movido durante migração')
  end
  local function addition(name,clone,parent)
   local record=ref(name,clone,backup.Additions);ref('TargetParent',parent,record)
   local snapshot=clone:Clone();snapshot.Name='Snapshot';snapshot.Parent=record
   clone:SetAttribute('NPCVisualOwner',2);clone.Parent=parent
  end
  local shared=ctx.Package.Runtime.Shared:Clone();shared.Name='EldravynNPCVisualV2';addition('Shared',shared,ctx.RS)
  for _,pair in {{ctx.Package.Runtime.Server,ctx.Server},{ctx.Package.Runtime.Client,ctx.Client}}do
   for _,template in pair[1]:GetChildren()do addition(template.Name,template:Clone(),pair[2])end
  end
  for _,row in ctx.Replacements do if row.Replace then
   local record=folder(row.Name,backup.Modules);ref('TargetParent',row.Parent,record)
   record:SetAttribute('OriginalName',row.Original.Name)
   local disabled=if row.Original:IsA('BaseScript') then row.Original.Disabled else nil
   record:SetAttribute('OriginalDisabled',disabled)
   local replacement=row.Template:Clone();replacement.Name=row.Name;replacement:SetAttribute('NPCVisualOwner',2)
   ref('Installed',replacement,record);local text=Instance.new('StringValue');text.Name='Source';text.Value=source(replacement);text.Parent=record
   row.Original.Name='Original';row.Original.Parent=record
   if row.Original:IsA('BaseScript') then row.Original.Disabled=true;replacement.Disabled=disabled end
   replacement.Parent=row.Parent
  end end
  workspace:SetAttribute('EldravynNPCVisualVersion',2);backup:SetAttribute('State','Applied');backup:SetAttribute('Count',plan.Count)
 end)
 if not ok then
  local restored,reason=pcall(rollback,backup,false)
  for _,f in prepared do if not f.Parent then f:Destroy()end end
  if not restored then error(tostring(err)..' | Falha de reversão: '..tostring(reason)..'. Backup preservado para recuperação.')end
  error('Migração cancelada e revertida: '..tostring(err))
 end
 print('[NPC V2] '..plan.Count..' NPCs atualizados no lugar. Backup criado; mapa e economia não alterados. Salve a cópia e teste Play.')
 return {Updated=plan.Count,Version=2,Backup=backup.Name}
end
return Upgrade
