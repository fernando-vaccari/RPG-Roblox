local Players=game:GetService('Players')
local UIS=game:GetService('UserInputService')
local remoteFolder=game.ReplicatedStorage:WaitForChild('MedievalRPG'):WaitForChild('Remotes')
local remote=remoteFolder:WaitForChild('Action')
local ui=require(script.Parent.Controllers.UIController).start(remote)
require(script.Parent.Controllers.WorldController).start(ui,remoteFolder:WaitForChild('Effects'))
local Abilities=require(game.ReplicatedStorage.MedievalRPG.Config.AbilityConfig)
local mouse=Players.LocalPlayer:GetMouse()
local bound=setmetatable({}, {__mode='k'})
local function bind(tool)
    if not tool:IsA('Tool') or not tool:GetAttribute('ItemId') or bound[tool] then return end
    bound[tool]=true
    tool.Activated:Connect(function() remote:FireServer('Attack',{Mode='Primary',Target=mouse.Hit.Position}) end)
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
        if input.KeyCode==key and slots then remote:FireServer('Attack',{Mode=slots[i],Target=mouse.Hit.Position});return end
    end
    if input.UserInputType==Enum.UserInputType.MouseButton2 then remote:FireServer('Attack',{Mode='Heavy',Target=mouse.Hit.Position})
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
