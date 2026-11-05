-- Run from Command Bar in Edit mode on a saved COPY of the existing Place.
local I={Version=1}
function I.Install()
 assert(not game:GetService('RunService'):IsRunning(),'Pare Play antes de instalar NPCs.')
 local package=script.Parent
 local world=workspace:FindFirstChild('GeneratedWorld')
 assert(world,'GeneratedWorld não encontrado. Nenhum mapa será criado pelo instalador.')
 local rs=game:GetService('ReplicatedStorage');local ss=game:GetService('ServerScriptService')
 local starter=game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts')
 assert(rs:FindFirstChild('MedievalRPG'),'Biblioteca original MedievalRPG ausente; instalação interrompida.')
 local old=ss:FindFirstChild('MedievalServer')
 if old then assert(not old:IsA('Script') or old.Disabled,'Runtime RPG já ativo; integração específica necessária.') end
 if old then for _,v in old:GetDescendants()do assert(not v:IsA('Script') or v.Disabled,'Runtime RPG já ativo: exige integração específica para evitar dois escritores de perfil.')end end
 local destinations={{Parent=rs,Name='EldravynNPC',Source=package.Shared},{Parent=ss,Name='EldravynNPC',Source=package.Server},{Parent=starter,Name='EldravynNPCClient',Source=package.Client}}
 local root=workspace:FindFirstChild('EldravynNPCs')
 if root then
  assert(root:GetAttribute('NPCInstallVersion')==I.Version,'Pasta EldravynNPCs pertence a outro conteúdo; nada sobrescrito.')
  for _,d in destinations do assert(d.Parent:FindFirstChild(d.Name) and d.Parent[d.Name]:GetAttribute('NPCInstallVersion')==I.Version,'Instalação incompleta; nenhum conteúdo será substituído automaticamente.')end
  print('[NPC] Versão '..I.Version..' já instalada. Nenhum NPC duplicado.');return {Existing=true}
 end
 for _,d in destinations do assert(not d.Parent:FindFirstChild(d.Name),'Destino já ocupado: '..d.Name..'. Nenhum arquivo será sobrescrito.')end
 local config=require(package.Shared.NPCConfig);local positions=require(package.Shared.PlacementConfig)
 local placement=require(package.Authoring.Placement);local factory=require(package.Authoring.R15Factory)
 local frames,existing={},{}
 local aliases={Guild='GuildMaster',Merchant='General',Mage='Magic',Blacksmith='Blacksmith',Innkeeper='Inn',Guard='Guard'}
 for _,model in workspace:GetDescendants()do
  if model:IsA('Model') and model:FindFirstChildOfClass('Humanoid') then
   local role=model:GetAttribute('NPCRole') or model:GetAttribute('Role')
   role=aliases[role] or role;local city=model:GetAttribute('City') or model:GetAttribute('CityId')
   if not role then for key,entry in config.Roles do if model.Name==entry.Name or model.Name==entry.Title then role=key end end end
   if not city then local ancestor=model.Parent;while ancestor and ancestor~=workspace do
    if ({Valoria=true,Arkheim=true,Eldoria=true,Durakh=true,Asterion=true,MalgorthDepths=true,FallenSanctum=true})[ancestor.Name] then city=ancestor.Name;break end
    ancestor=ancestor.Parent
   end end
   assert(role and city,'NPC existente sem identificação: '..model.Name..'. Defina atributos NPCRole e City antes de instalar, para evitar duplicação.')
   existing[city..':'..role]=model
  end
 end
 -- Check every anchor before creating or enabling anything.
 local strict=world:GetAttribute('TerrainPending')~=true
 local staging=Instance.new('Folder');staging.Name='EldravynNPCs';staging:SetAttribute('NPCInstallVersion',I.Version)
 local skipped={}
 for _,definition in config.Definitions do
  if existing[definition.City..':'..definition.Role] then table.insert(skipped,definition.Id)
  else
   local frame,reason=placement.frame(world,assert(positions.NPCs[definition.Id]),staging,strict)
   if not frame then staging:Destroy();error(reason..'. Ajuste PlacementConfig à sua cópia antes de tentar novamente; mapa preservado.')end
   frames[definition.Id]=frame
  end
 end
 local created={};local previousStage=workspace:GetAttribute('EldravynNPCStage2');local previousPreview=workspace:GetAttribute('StudioSessionPreview')
 local ok,err=pcall(function()
  local cities={}
  for _,definition in config.Definitions do if frames[definition.Id] then
   local city=cities[definition.City]
   if not city then city=Instance.new('Folder');city.Name=definition.City;city.Parent=staging;cities[definition.City]=city end
   factory.create(city,definition,config.Roles[definition.Role],frames[definition.Id])
  end end
  for _,d in destinations do
   local clone=d.Source:Clone();clone.Name=d.Name;clone:SetAttribute('NPCInstallVersion',I.Version);table.insert(created,clone);clone.Parent=d.Parent
  end
  staging.Parent=workspace;table.insert(created,staging)
  workspace:SetAttribute('EldravynNPCStage2',true)
  if previousPreview==nil then workspace:SetAttribute('StudioSessionPreview',true)end
  for _,container in created do for _,node in container:GetDescendants()do if node:IsA('BaseScript') then node.Disabled=false end end end
 end)
 if not ok then
  for _,node in created do node:Destroy()end;staging:Destroy()
  workspace:SetAttribute('EldravynNPCStage2',previousStage);workspace:SetAttribute('StudioSessionPreview',previousPreview);error(err)
 end
 for _,id in skipped do warn('[NPC] Equivalente existente preservado, sem duplicar: '..id..'. Integre o diálogo deste personagem manualmente.')end
 print('[NPC] Instalação concluída sem editar GeneratedWorld/Terrain. Salve outra cópia e teste Play. Prévia Studio pode ser volátil.')
 return {Installed=#config.Definitions-#skipped,Skipped=skipped,TerrainTouched=false}
end
return I
