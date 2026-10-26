local Players=game:GetService('Players')
local UIS=game:GetService('UserInputService')
-- The custom inventory equips Tools itself; avoid a second overlapping mobile hotbar.
task.spawn(function()
    for _=1,3 do
        local ok=pcall(function()game:GetService('StarterGui'):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false);game:GetService('StarterGui'):SetCoreGuiEnabled(Enum.CoreGuiType.Health,false)end)
        if ok then return end
        task.wait(1)
    end
end)
local remoteFolder=game.ReplicatedStorage:WaitForChild('MedievalRPG'):WaitForChild('Remotes')
local remote=remoteFolder:WaitForChild('Action')
local ui=require(script.Parent.Controllers.UIController).start(remote)
require(script.Parent.Controllers.WorldController).start(ui,remoteFolder:WaitForChild('Effects'))
local Abilities=require(game.ReplicatedStorage.MedievalRPG.Config.AbilityConfig)
local mouse=Players.LocalPlayer:GetMouse()
ui.GetAim=function()
    local camera=workspace.CurrentCamera
    if UIS.TouchEnabled and camera then
        local size=camera.ViewportSize
        local ray=camera:ViewportPointToRay(size.X/2,size.Y/2)
        local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={Players.LocalPlayer.Character}
        local hit=workspace:Raycast(ray.Origin,ray.Direction*160,params)
        return hit and hit.Position or ray.Origin+ray.Direction*160
    end
    return mouse.Hit.Position
end
local bound=setmetatable({}, {__mode='k'})
local function bind(tool)
    if not tool:IsA('Tool') or not tool:GetAttribute('ItemId') or bound[tool] then return end
    bound[tool]=true
    tool.Activated:Connect(function()ui.attack('Primary')end)
end
local function character(char)
    char.ChildAdded:Connect(bind)
    for _,v in char:GetChildren() do bind(v) end
end
Players.LocalPlayer.CharacterAdded:Connect(character)
if Players.LocalPlayer.Character then character(Players.LocalPlayer.Character) end
UIS.InputBegan:Connect(function(input,processed)
    if processed then return end
    local slots=ui.State and Abilities.Slots[ui.State.Class]
    for i,key in {Enum.KeyCode.Z,Enum.KeyCode.X,Enum.KeyCode.C,Enum.KeyCode.V} do
        if input.KeyCode==key and slots then ui.attack(slots[i]);return end
    end
    if input.UserInputType==Enum.UserInputType.MouseButton2 then ui.attack('Heavy')
    elseif input.KeyCode==Enum.KeyCode.F then remote:FireServer('Control','BlockOn')
    elseif input.KeyCode==Enum.KeyCode.LeftShift then remote:FireServer('Control','RunOn')
    elseif input.KeyCode==Enum.KeyCode.LeftControl then remote:FireServer('Control','Dodge')
    elseif input.KeyCode==Enum.KeyCode.R then remote:FireServer('Attack',{Mode='Racial'})
    elseif input.KeyCode==Enum.KeyCode.L then ui.identity()
    elseif input.KeyCode==Enum.KeyCode.M then ui.menu()
    elseif input.KeyCode==Enum.KeyCode.K then ui.skills()
    elseif input.KeyCode==Enum.KeyCode.Q then remote:FireServer('Attack',{Mode='Pulse',Target=mouse.Hit.Position})
    elseif input.KeyCode==Enum.KeyCode.J then ui.quests()
    elseif input.KeyCode==Enum.KeyCode.I then ui.inventory() end
end)

UIS.InputEnded:Connect(function(input)
 if input.KeyCode==Enum.KeyCode.F then remote:FireServer('Control','BlockOff') end
 if input.KeyCode==Enum.KeyCode.LeftShift then remote:FireServer('Control','RunOff') end
end)
