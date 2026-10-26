local Shared=game.ReplicatedStorage.MedievalRPG
local Catalog=require(Shared.Config.ContentConfig)
local Stats=require(Shared.Core.CombatRules)
local Abilities=require(Shared.Config.AbilityConfig)
local I={}
function I.tool(player,id,combat)
    local item=Catalog.Items[id]
    if not item or item.Kind~='Weapon' then return end
    local tool=Instance.new('Tool');tool.Name=item.Name;tool:SetAttribute('ItemId',id);tool.CanBeDropped=false
    local function piece(name,size,cf,color)
        local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.CanCollide=false;p.CanTouch=false;p.Massless=true
        p.Color=color;p.Material=Enum.Material.Metal;p.Parent=tool;return p
    end
    local handle=piece('Handle',Vector3.new(0.4,1.4,0.4),CFrame.identity,Color3.fromRGB(91,59,39))
    local blade=piece('Blade',if id=='Staff' then Vector3.new(0.5,5,0.5) elseif id=='Bow' then Vector3.new(0.3,4,0.4) else Vector3.new(0.45,4,0.2),CFrame.new(0,2.2,0),Color3.fromRGB(192,207,220))
    if id=='Staff' then blade.Color=Color3.fromRGB(129,100,222);blade.Material=Enum.Material.Neon end
    if id=='Bow' then blade.Color=Color3.fromRGB(114,74,43);blade.Material=Enum.Material.Wood end
    local weld=Instance.new('WeldConstraint');weld.Part0=handle;weld.Part1=blade;weld.Parent=blade
    if id=='Katana' or id=='Longsword' then
        local guard=piece('Guard',Vector3.new(1.5,0.2,0.4),CFrame.new(0,0.8,0),Color3.fromRGB(199,164,71))
        local w=Instance.new('WeldConstraint');w.Part0=handle;w.Part1=guard;w.Parent=guard
    elseif id=='Bow' then
        local stringPart=piece('BowString',Vector3.new(0.05,4,0.05),CFrame.new(0,1.5,-0.8),Color3.fromRGB(224,213,181))
        local w=Instance.new('WeldConstraint');w.Part0=handle;w.Part1=stringPart;w.Parent=stringPart
    end
    tool.Grip=CFrame.Angles(0,0,0)
    tool.Parent=player:FindFirstChildOfClass('Backpack')
    return tool
end
function I.sync(player,state,combat)
    for _,container in {player:FindFirstChildOfClass('Backpack'),player.Character} do
        if container then
            for _,child in container:GetChildren() do if child:IsA('Tool') and child:GetAttribute('ItemId') then child:Destroy() end end
        end
    end
    local hum=player.Character and player.Character:FindFirstChildOfClass('Humanoid')
    if state.Equipment~='' and (state.Inventory[state.Equipment] or 0)>0 then
        local tool=I.tool(player,state.Equipment,combat)
        if tool and tool.Parent and hum and hum.Health>0 then hum:EquipTool(tool) end
    end
    local char=player.Character
    if char then
        local old=char:FindFirstChild('MedievalArmor');if old then old:Destroy() end
        local torso=char:FindFirstChild('UpperTorso') or char:FindFirstChild('Torso')
        if torso and state.Armor=='Armor' and (state.Inventory.Armor or 0)>0 then
            local plate=Instance.new('Part');plate.Name='MedievalArmor';plate.Size=Vector3.new(torso.Size.X*0.95,torso.Size.Y*0.85,0.25)
            plate.CFrame=torso.CFrame*CFrame.new(0,0,-torso.Size.Z/2-0.1);plate.Color=Color3.fromRGB(116,132,151);plate.Material=Enum.Material.Metal
            plate.Massless=true;plate.CanCollide=false;plate.CanTouch=false;plate.CanQuery=false;plate.Parent=char
            local weld=Instance.new('WeldConstraint');weld.Part0=torso;weld.Part1=plate;weld.Parent=plate
        end
    end
    if hum then hum.MaxHealth=Stats.stats(state,Abilities).Health;hum.Health=math.min(hum.Health,hum.MaxHealth) end
end
return I
