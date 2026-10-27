local Players=game:GetService('Players')
local RS=game:GetService('ReplicatedStorage')
local RunService=game:GetService('RunService')
local UIS=game:GetService('UserInputService')
local Lighting=game:GetService('Lighting')
local shared=RS:WaitForChild('MedievalRPG')
local Config=require(shared.Config.MapVisualConfig)
local Rules=require(shared.Core.MapVisualRules)
local controls=RS:WaitForChild('EldravynMapPreview')
local remote=controls:WaitForChild('Environment')
local state=Rules.new(UIS.TouchEnabled)
local managed=setmetatable({},{__mode='k'})
local function owned(item)
    local cursor=item.Parent
    while cursor and cursor~=workspace do
        if cursor:GetAttribute('SceneOnly')==true then return true end
        cursor=cursor.Parent
    end
    return false
end
local function track(item)
    if not owned(item) then return end
    if item:IsA('PointLight') or item:IsA('SpotLight') or item:IsA('SurfaceLight') then
        managed[item]={Kind='Light',Enabled=item.Enabled,Shadows=item.Shadows}
        item.Enabled=false -- Newly streamed lights wait for the nearest-light budget.
    elseif item:IsA('ParticleEmitter') then managed[item]={Kind='Particle',Enabled=item.Enabled}
    elseif item:IsA('BasePart') then
        managed[item]={Kind='Part',Shadow=item.CastShadow,Fine=(item:GetAttribute('DetailTier') or 0)>=2 and not item.CanCollide,
            Distance=item:GetAttribute('DetailDistance') or 180}
    end
end
for _,item in workspace:GetDescendants() do track(item) end
workspace.DescendantAdded:Connect(track)

local player=Players.LocalPlayer
local gui=Instance.new('ScreenGui');gui.Name='EldravynMapInspection';gui.ResetOnSpawn=false;gui.IgnoreGuiInset=false;gui.Parent=player:WaitForChild('PlayerGui')
local panel=Instance.new('Frame');panel.Name='Inspector';panel.Size=UDim2.new(0,270,0,148);panel.Position=UDim2.new(0,10,0,10)
panel.BackgroundColor3=Color3.fromRGB(27,34,43);panel.BackgroundTransparency=0.12;panel.Parent=gui
local function label(name,text,y,height)
    local item=Instance.new('TextLabel');item.Name=name;item.Text=text;item.TextWrapped=true;item.Font=Enum.Font.Garamond
    item.TextSize=16;item.TextColor3=Color3.fromRGB(231,218,183);item.BackgroundTransparency=1
    item.Size=UDim2.new(1,-16,0,height);item.Position=UDim2.new(0,8,0,y);item.Parent=panel;return item
end
label('Title','ELDRAVYN • Inspeção do continente',6,22)
local status=label('Status','Qualidade automática • revisão visual pendente',31,32)
local warning=label('Terrain','',104,36)
local function button(name,text,x,callback)
    local item=Instance.new('TextButton');item.Name=name;item.Text=text;item.Font=Enum.Font.Garamond;item.TextSize=16
    item.TextColor3=Color3.fromRGB(238,224,190);item.BackgroundColor3=Color3.fromRGB(58,68,78)
    item.TextSize=14;item.TextWrapped=true
    item.Size=UDim2.new(0,122,0,32);item.Position=UDim2.new(0,x,0,69);item.Parent=panel
    item.Activated:Connect(callback);return item
end
local modeIndex,presetIndex=1,2
local qualityButton
qualityButton=button('Quality','Qualidade: Automático',8,function()
    modeIndex=modeIndex%#Config.Modes+1;Rules.select(state,Config.Modes[modeIndex])
    qualityButton.Text='Qualidade: '..Config.Labels[state.Mode]
end)
local envButton
envButton=button('Environment','Ambiente: Dia',140,function()
    if not RunService:IsStudio() then return end
    presetIndex=presetIndex%#Config.Presets+1
    remote:FireServer(Config.Presets[presetIndex])
    envButton.Text='Ambiente: '..Config.PresetLabels[Config.Presets[presetIndex]]
end)
if not RunService:IsStudio() then envButton.Visible=false end
local function positionOf(item)
    local cursor=item
    while cursor and cursor~=workspace do
        if cursor:IsA('BasePart') then return cursor.Position end
        cursor=cursor.Parent
    end
end
local function update(profileName)
    local profile=Config.Profiles[profileName]
    local camera=workspace.CurrentCamera
    if not camera then return end
    local origin=camera.CFrame.Position
    local lights,particles={},{}
    for item,entry in managed do
        if not item.Parent then managed[item]=nil;continue end
        if entry.Kind=='Part' then
            -- Per-item state also catches parts streamed after a profile was selected.
            if entry.AppliedProfile~=profileName then
                item.CastShadow=entry.Shadow and profile.Shadows;entry.AppliedProfile=profileName
            end
            if entry.Fine then
                item.LocalTransparencyModifier=if Rules.distanceVisible((item.Position-origin).Magnitude,entry.Distance,profile,item.CanCollide) then 0 else 1
            end
        else
            local position=positionOf(item)
            local distance=if position then (position-origin).Magnitude else math.huge
            local limit=if entry.Kind=='Light' then profile.LightDistance else profile.ParticleDistance
            item.Enabled=false
            if entry.Enabled and distance<=limit then
                table.insert(if entry.Kind=='Light' then lights else particles,{Item=item,Distance=distance,Original=entry})
            end
        end
    end
    local function nearest(list,budget)
        table.sort(list,function(a,b)return a.Distance<b.Distance end)
        for index=1,math.min(budget,#list) do
            local entry=list[index];entry.Item.Enabled=true
            if entry.Original.Kind=='Light' then entry.Item.Shadows=false end
        end
    end
    nearest(lights,profile.Lights);nearest(particles,profile.Particles)
    local bloom=Lighting:FindFirstChild('EldravynMapBloom');if bloom then bloom.Intensity=profile.Bloom end
    local rays=Lighting:FindFirstChild('EldravynMapSunRays');if rays then rays.Enabled=profileName~='LOW' end
    local preset=workspace:GetAttribute('MapEnvironmentPreset') or 'Day'
    status.Text='Visual: '..Config.Labels[profileName]..' • '..(Config.PresetLabels[preset] or preset)..'\nExplore cidades, florestas e mirantes'
    local root=workspace:FindFirstChild('GeneratedWorld') or workspace:FindFirstChild('GeneratedContinent')
    warning.Text=if not root or root:GetAttribute('TerrainPending')==true then 'Terrain pendente: pare Play e siga o comando de preparação do guia.' else 'Inspeção do mapa • mouse e toque'
end
local elapsed=0
RunService.RenderStepped:Connect(function(dt)
    local profile=Rules.step(state,dt);elapsed+=dt
    if elapsed>=Config.UpdateSeconds then elapsed=0;update(profile) end
end)
