-- Standalone map inspection bootstrap. No RPG services or world generation.
local RunService=game:GetService('RunService')
local Players=game:GetService('Players')
local RS=game:GetService('ReplicatedStorage')
local Environment=require(game:GetService('ServerStorage').MedievalWorldgen.MapEnvironment)
Environment.apply(workspace:GetAttribute('MapEnvironmentPreset') or 'Day')
local root=workspace:FindFirstChild('GeneratedWorld') or workspace:FindFirstChild('GeneratedContinent')
if not root or root:GetAttribute('TerrainPending')==true then
    Players.CharacterAutoLoads=false
    warn('[Eldravyn mapa] Terrain pendente. Pare Play e conclua a preparação pelo guia antes de caminhar.')
end
local controls=Instance.new('Folder');controls.Name='EldravynMapPreview';controls.Parent=RS
local remote=Instance.new('RemoteEvent');remote.Name='Environment';remote.Parent=controls
local limits={}
remote.OnServerEvent:Connect(function(player,preset)
    -- Visual review controls are editor-only and never expose production changes.
    if not RunService:IsStudio() or type(preset)~='string' or #preset>12 then return end
    local now=os.clock();if now<(limits[player] or 0) then return end;limits[player]=now+0.5
    if not ({Dawn=true,Day=true,Sunset=true,Night=true,Rain=true,Fog=true,Storm=true})[preset] then return end
    Environment.apply(preset)
end)
Players.PlayerRemoving:Connect(function(player)limits[player]=nil end)
print('[Eldravyn mapa] Inspeção visual iniciada. Nenhum serviço de gameplay foi carregado.')
