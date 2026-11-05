-- Isolated V1 installation used only in the simulated migration tests.
env.CopyLoader=function(old,new)if loaders[old] then loaders[new]=loaders[old]end end
local pkg=game.ServerStorage.NPCV2Install
local author=Instance.new('Folder');author.Name='Authoring';author.Parent=pkg
for _,name in {'NPCRigAdapter','NPCVisualFactory'}do pkg[name]:Clone().Parent=author end
local runtime=Instance.new('Folder');runtime.Name='Runtime';runtime.Parent=pkg
local shared=game.ReplicatedStorage.EldravynNPCVisualV2;shared.Name='Shared';shared.Parent=runtime
local server=game.ServerScriptService.NPCV2Runtime;server.Name='Server';server.Parent=runtime
local clientModules=game.ReplicatedStorage.TestNPCV2Client;clientModules.Name='Client';clientModules.Parent=runtime
local replacements=Instance.new('Folder');replacements.Name='Replacements';replacements.Parent=runtime
local bootstrap=Instance.new('Script');bootstrap.Name='Bootstrap';bootstrap.Disabled=false;bootstrap.Source='-- fixture: Service.start called explicitly by the test';bootstrap.Parent=game.ServerScriptService.EldravynNPC
for _,name in {'NPCService','AmbientService'}do
 local old=game.ServerScriptService.EldravynNPC[name];old:Clone().Parent=replacements;old.Source=pkg.Baselines[name].Source
end
local client=Instance.new('Folder');client.Name='EldravynNPCClient';client.Parent=game.StarterPlayer.StarterPlayerScripts
local ui=game.ReplicatedStorage.TestNPCClient.NPCDialogueClient:Clone();ui.Parent=client
local oldClient=Instance.new('LocalScript');oldClient.Name='NPCInteractionClient';oldClient.Source=pkg.Baselines.NPCInteractionClient.Source;oldClient.Disabled=false;oldClient.Parent=client
local nextClient=oldClient:Clone();nextClient.Source=CLIENT_V2_SOURCE;nextClient.Disabled=true;nextClient.Parent=replacements
local C=require(game.ReplicatedStorage.EldravynNPC.NPCConfig)
local base=require(game.ServerStorage.NPCInstall.R15Factory)
local npcs=Instance.new('Folder');npcs.Name='EldravynNPCs';npcs:SetAttribute('NPCInstallVersion',1);npcs.Parent=workspace
local world=Instance.new('Folder');world.Name='GeneratedWorld';world.Parent=workspace
local sentinel=Instance.new('Part');sentinel.Name='PreservedBuilding';sentinel.Position=Vector3.new(20,40,100);sentinel.Parent=world
local models={};local original={}
for i,definition in C.Definitions do
 local npc=base.create(npcs,definition,C.Roles[definition.Role],CFrame.new(i*10,0,0));models[definition.Id]=npc
 original[definition.Id]={NPC=npc,Attributes=npc:GetAttributes(),Root=npc.PrimaryPart.CFrame,Head=npc.Head,Humanoid=npc:FindFirstChildOfClass('Humanoid'),Prompt=npc:FindFirstChild('NPCInteraction',true),Decor=npc.Hair,Color=npc.Head.Color,Shape=npc.Head.Shape,Size=npc.Head.Size}
end
workspace:SetAttribute('EldravynNPCStage2',true);workspace:SetAttribute('StudioSessionPreview',true)
