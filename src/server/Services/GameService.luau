local Players=game:GetService('Players')
local Prompts=game:GetService('ProximityPromptService')
local Shared=game.ReplicatedStorage.MedievalRPG
local Config=require(Shared.Config.WorldConfig)
local Catalog=require(Shared.Config.ContentConfig)
local Rules=require(Shared.Core.Progression)
local Data=require(script.Parent.DataService)
local Security=require(script.Parent.AntiExploitService)
local Inventory=require(script.Parent.InventoryService)
local Combat=require(script.Parent.CombatService)
local Enemies=require(script.Parent.EnemyService)
local Dungeon=require(script.Parent.DungeonService)
local Abilities=require(Shared.Config.AbilityConfig)
local CombatRules=require(Shared.Core.CombatRules)
local Identity=require(script.Parent.IdentityService)
local Purchase=require(script.Parent.PurchaseService)
local Tester=require(script.Parent.TesterService)
local Expedition=require(script.Parent.ExpeditionService)
local Tutorial=require(script.Parent.TutorialService)
local Siege=require(script.Parent.SiegeService)
local Service={Remote=nil,FX=nil}
function Service.notice(p,text) Service.Remote:FireClient(p,{Type='Notice',Text=text}) end
function Service.state(p)
    local s=Data.get(p)
    if s then
        p:SetAttribute('ProfileStatus','Ready')
        Identity.syncClass(s)
        local public=table.clone(s.Identity);public.Receipts=nil
        local copy={Adventure=s.Adventure,Expedition={Best=s.Expedition.Best,Clears=s.Expedition.Clears},StarterChosen=s.StarterChosen,Armor=s.Armor,TesterAllowed=Tester.allowed(),Identity=public,ServerTime=os.time(),Purchases={RacialRetry=Purchase.available('RacialRetry'),BasicPack=Purchase.available('BasicPack'),PremiumPack=Purchase.available('PremiumPack')},Gold=s.Gold,XP=s.XP,Rank=s.Rank,Class=s.Class,Equipment=s.Equipment,Unlocks=s.Unlocks,Inventory=s.Inventory,Quests=s.Quests,Spawn=s.Spawn,Persistent=Data.Persistent}
        Service.Remote:FireClient(p,{Type='State',State=copy,Party=Dungeon.status(p)})
    elseif Data.Sessions[p] and Data.Sessions[p].Frozen then
        p:SetAttribute('ProfileStatus','Unavailable')
    end
end
local function owned(part)
    local cursor=part
    while cursor and cursor~=workspace do
        if (cursor.Name=='GeneratedWorld' or cursor.Name=='GeneratedDungeon') and cursor:GetAttribute('ProjectId')=='ProjectMedievalRPG' then return cursor end
        cursor=cursor.Parent
    end
    return nil
end
function Service.dialogue(p,part,role,city)
    local d=Catalog.Dialogue[role] or Catalog.Dialogue.Citizen
    Security.open(p,part,role,city)
    local localText=Catalog.CityDialogue[city] and Catalog.CityDialogue[city][role] or d.Text
    local npc=part:FindFirstAncestorOfClass('Model')
    if npc and npc:GetAttribute('LocalDialogue') then localText=npc:GetAttribute('LocalDialogue') end
    Service.Remote:FireClient(p,{Type='Dialogue',Role=role,City=city,Name=npc and npc:GetAttribute('DisplayTitle') or d.Name,Text='['..city..'] '..localText,Items=Catalog.Shops[role],Party=Dungeon.status(p)})
    Service.state(p)
end
function Service.prompt(prompt,p)
    local part=prompt.Parent
    if not part or not part:IsA('BasePart') or not owned(part) or not Security.near(p,part,15) or not Security.allow(p,'prompt',0.3) then return end
    local state=Data.get(p)
    if not state then Service.notice(p,'Perfil indisponível; aguarde ou reconecte.');return end
    if owned(part).Name=='GeneratedDungeon' and state.Rank=='' and not part:GetAttribute('ReturnPortal') then Service.notice(p,'A dungeon exige registro na guilda.');return end
    local model=part:FindFirstAncestorOfClass('Model')
    if model and model:GetAttribute('NpcId') then
        local role=model:GetAttribute('Role')
        Identity.event(state,'Talk:'..(model:GetAttribute('City') or '')..':'..role)
        if role=='Mage' then Identity.event(state,'Mage') end
        Rules.event(state,Catalog,'Talk:'..(model:GetAttribute('City') or '')..':'..role,1)
        if role=='Mage' then Rules.event(state,Catalog,'Mage',1) end
        Service.dialogue(p,part,role,model:GetAttribute('City') or 'Região')
    elseif model and model:GetAttribute('ChestId') then
        if model:GetAttribute('FloorLocked') and not Expedition.canChest(p,model) then Service.notice(p,'Limpe o andar atual da sua expedição antes de abrir o baú.');return end
        local dungeon=owned(part)
        if model:GetAttribute('BossLocked') and not dungeon:GetAttribute('BossDefeated') then Service.notice(p,'Derrote Malgorth para abrir este baú.');return end
        local ok,msg=Rules.chest(state,Catalog,model:GetAttribute('ChestId'),model:GetAttribute('Rarity'))
        Service.notice(p,msg)
        if ok then Service.FX:FireClient(p,{Kind='Chest',Position=part.Position}) end
    elseif part:GetAttribute('ExpeditionNext') then
        local _,msg=Expedition.advance(p,part);Service.notice(p,msg)
    elseif part:GetAttribute('QuestBoard') then Service.dialogue(p,part,'Quest', 'Quadro de avisos')
    elseif part:GetAttribute('Objective') then
        Identity.event(state,part:GetAttribute('Objective'))
        if part:GetAttribute('Objective')=='Ruins' then
            local region=part:FindFirstAncestorOfClass('Model')
            if region and Identity.discover(state,region.Name) then Service.notice(p,'Uma história secreta foi descoberta. Veja sua árvore de evolução.') end
        end
        Rules.event(state,Catalog,part:GetAttribute('Objective'),1);Service.notice(p,'Objetivo investigado. Consulte suas missões.')
    elseif part:GetAttribute('ReturnPortal') then
        local _,msg=Dungeon.returnPlayer(p);Service.notice(p,msg)
    end
    Service.state(p)
end
function Service.action(p,action,value)
    if action=='Control' then
        if type(value)=='string' and ({BlockOn=true,BlockOff=true,RunOn=true,RunOff=true,Dodge=true})[value] and Security.allow(p,'control:'..value,0.05) then Combat.control(p,value) end
        return
    end
    if type(action)~='string' or #action>30 or not Security.allow(p,'remote',0.1) then return end
    if action=='TesterPreview' then
        if type(value)~='string' or #value>30 then return end
        local result,msg=Tester.preview(p,value)
        if result then Service.Remote:FireClient(p,{Type='Preview',Preview=result})else Service.notice(p,msg)end
        return
    end
    if action=='Hello' then Service.state(p);return end
    local state=Data.get(p)
    if not state then return end
    if action=='Attack' then
        if type(value)=='table' and type(value.Mode)=='string' and #value.Mode<=50 then Combat.attack(p,value.Target,value.Mode) end
        return
    end
    if action=='Control' and type(value)=='string' then Combat.control(p,value);return end
    if value~=nil and type(value)~='string' and type(value)~='number' then return end
    if type(value)=='string' and #value>80 then return end
    local context=Security.context(p)
    local ok,msg=false,'Converse novamente com o NPC.'
    if action=='TutorialInventory' then
        Tutorial.event(p,'Inventory');return -- records presentation only; grants no XP/Gold/items
    elseif action=='CreateCharacter' and Security.alive(p) then
        if table.find({'Longsword','Katana','Staff','Bow'},value) then
            ok,msg=Rules.choose(state,Catalog,value)
            if ok then Inventory.sync(p,state,Combat);Tutorial.event(p,'Weapon') end
        end
    elseif ({RacialStart=true,RacialClaim=true,ClassStart=true,ClassClaim=true,ClassSelect=true,FusionGold=true,Fuse=true,Purchase=true})[action] then
        ok,msg=Identity.action(p,action,value)
        if ok then
            local fresh=Data.get(p)
            if fresh then
                if action=='ClassSelect' then Inventory.sync(p,fresh,Combat);Combat.changeClass(p) end
                if action=='RacialClaim' then Identity.appearance(p) end
            end
        end
    elseif action=='Potion' then
        local hum=p.Character and p.Character:FindFirstChildOfClass('Humanoid')
        if hum and hum.Health>0 and hum.Health<hum.MaxHealth and (state.Inventory.Potion or 0)>0 and Security.allow(p,'potion',2) then
            state.Inventory.Potion-=1;hum.Health=math.min(hum.MaxHealth,hum.Health+50);ok,msg=true,'Vida recuperada.'
        else msg='Sem poção ou vida já completa.' end
    elseif action=='UnequipArmor' then state.Armor='';Inventory.sync(p,state,Combat);ok,msg=true,'Armadura guardada.'
    elseif action=='Unequip' then state.Equipment='';Inventory.sync(p,state,Combat);ok,msg=true,'Arma guardada.'
    elseif action=='Equip' then
        local item=Catalog.Items[value]
        if item and (state.Inventory[value] or 0)>0 then
            if item.Kind=='Armor' then state.Armor=value;Inventory.sync(p,state,Combat);ok,msg=true,'Armadura equipada.'
            elseif item.Kind=='Weapon' and (state.Class=='' or Abilities.Classes[state.Class] and Abilities.Classes[state.Class].Weapon==value) then
                state.Equipment=value;Inventory.sync(p,state,Combat);ok,msg=true,'Equipado.'
            else msg='Este equipamento não corresponde à sua classe.' end
        end
    elseif context then
        local role=context.Role
        if action=='Learn' and (role=='ShopMagic' or role=='Equipment' or role=='Mage') then ok,msg=CombatRules.unlock(state,value,Abilities)
        elseif action=='Sell' and role=='Merchant' then ok,msg=Rules.sell(state,Catalog,value);if ok then Inventory.sync(p,state,Combat) end
        elseif action=='Buy' then ok,msg=Rules.buy(state,Catalog,value,role);if ok then Inventory.sync(p,state,Combat) end
        elseif action=='Choose' and role=='Equipment' then ok,msg=Rules.choose(state,Catalog,value);if ok then Inventory.sync(p,state,Combat) end
        elseif action=='Register' and role=='Guild' then ok,msg=Rules.register(state)
        elseif action=='Accept' and (role=='Guild' or role=='Quest') then ok,msg=Rules.accept(state,Catalog,value)
        elseif action=='Claim' and role=='Guild' then ok,msg=Rules.claimQuest(state,Catalog,value)
        elseif action=='Inn' and role=='Inn' then
            for _,city in Config.Cities do if city.Id==context.City then state.Spawn=city.Id;ok,msg=true,'Hospedaria registrada.' end end
        elseif action=='Heal' and role=='Healer' then
            local hum=p.Character and p.Character:FindFirstChildOfClass('Humanoid')
            if hum and hum.Health>0 then hum.Health=hum.MaxHealth;ok,msg=true,'Feridas curadas.' end
        elseif string.sub(action,1,7)=='Dungeon' and role=='Dungeon' then ok,msg=Dungeon.action(p,string.sub(action,8),if type(value)=='number' then value else nil)
        end
    end
    if ok then local fresh=Data.get(p);if fresh then fresh.Revision+=1 end end
    Service.notice(p,msg);Service.state(p)
end
local function character(p,char)
    local root=char:WaitForChild('HumanoidRootPart',10)
    if not root then return end
    local deadline=os.clock()+15
    while not Data.get(p) and os.clock()<deadline do task.wait(0.1) end
    local s=Data.get(p)
    if not s then return end
    local dungeon=workspace:FindFirstChild('GeneratedDungeon')
    local world=workspace:FindFirstChild('GeneratedWorld')
    if world and world:GetAttribute('Status')=='Complete' then
        if Expedition.Run and Expedition.Run.Eliminated[p.UserId] then Expedition.leave(p) end
        for _,city in Config.Cities do
            if city.Id==s.Spawn then char:PivotTo(CFrame.new(city.X,city.Height+6,city.Z));break end
        end
        p:SetAttribute('InDungeon',false)
    elseif dungeon and dungeon:GetAttribute('Status')=='Complete' then
        if game:GetService('RunService'):IsStudio() and Config.StudioDungeonTest and not Data.Persistent and s.Equipment=='' then
            Rules.register(s);Rules.choose(s,Catalog,'Staff');s.Inventory.Potion=5;s.Inventory.Armor=1;s.Armor='Armor'
            Service.notice(p,'TESTE STUDIO da dungeon: kit volátil de cajado, couraça e cinco poções. Nada será salvo.')
        end
        char:PivotTo(CFrame.new(dungeon:GetAttribute('SpawnPosition')));p:SetAttribute('InDungeon',true)
        if s.Expedition and s.Expedition.Ticket then
            local admitted,msg=Expedition.admit(p,dungeon);Service.notice(p,msg)
            s=Data.get(p);if not admitted and not s then return end
        elseif Expedition.Run and Expedition.Run.Eliminated[p.UserId] then Expedition.leave(p) end
    else Service.notice(p,'Mapa ausente: pare Play e gere pelo Command Bar no editor.') end
    Combat.clear(p)
    Identity.appearance(p)
    local mortality=char:FindFirstChildOfClass('Humanoid')
    if mortality then mortality.Died:Connect(function()
        Combat.clear(p);Expedition.eliminate(p);Data.noteDeath(p);Service.state(p)
    end) end
    Inventory.sync(p,s,Combat)
    local hum=char:FindFirstChildOfClass('Humanoid');if hum then hum.Health=hum.MaxHealth end
    Service.state(p)
end
function Service.start(remote,fx)
    require(script.Parent.ProjectileService).start(fx)
    Service.Remote,Service.FX=remote,fx;Combat.FX=fx;Dungeon.Notice=Service.notice
    Tutorial.OnState=Service.state;Combat.OnAction=Tutorial.event
    Expedition.Notice=Service.notice;Expedition.OnState=Service.state
    Expedition.OnComplete=function(profile,id)Rules.event(profile,Catalog,'Dungeon:'..id,1)end
    Siege.Notice=Service.notice;Siege.OnState=Service.state
    Enemies.CanTarget=Expedition.allowed
    Dungeon.OnDungeonReady=function(map) Enemies.scan(map) end
    Purchase.OnGrant=Service.state
    Purchase.OnPending=function(p) Service.notice(p,'Compra pendente de gravação; não compre novamente. A plataforma tentará entregar o mesmo recibo. Reconecte se o perfil ficar bloqueado.') end
    Purchase.start()
    Enemies.OnKill=function(e)
        Expedition.killed(e)
        for p,damage in e.Contributors do
            local state=Data.get(p)
            if state and damage>0 and Security.near(p,e.Root,130) then
                state.Gold=math.min(1000000000,state.Gold+e.Def.Reward);state.XP=math.min(1000000000,state.XP+e.Def.XP)
                Rules.grantItem(state,Catalog,'Ore')
                Identity.event(state,e.Kind)
                Identity.fragments(state,e.Kind,e.Spawn.Root)
                Rules.event(state,Catalog,e.Kind,1);Service.state(p)
            end
        end
        Siege.killed(e)
    end
    remote.OnServerEvent:Connect(function(p,a,v)
        local ok,err=xpcall(function() Service.action(p,a,v) end,debug.traceback)
        if not ok then warn(err);Service.notice(p,'Não foi possível concluir a ação; consulte Output.') end
    end)
    Prompts.PromptTriggered:Connect(function(prompt,p)
        local ok,err=xpcall(function() Service.prompt(prompt,p) end,debug.traceback)
        if not ok then warn(err) end
    end)
    local function add(p)
        p:SetAttribute('ProfileStatus','Loading')
        p.CharacterAdded:Connect(function(char) character(p,char) end)
        task.spawn(function()
            local ok,msg=Data.load(p)
            if p.Parent==Players then p:SetAttribute('ProfileStatus',if ok then 'Ready' else 'Unavailable');Service.notice(p,msg);if ok then Service.state(p) end end
        end)
        if p.Character then task.spawn(character,p,p.Character) end
    end
    Players.PlayerAdded:Connect(add)
    Players.PlayerRemoving:Connect(function(p) Combat.clear(p);Expedition.leave(p);Tutorial.clear(p);Dungeon.leave(p,true);Security.clear(p);Data.remove(p) end)
    for _,p in Players:GetPlayers() do add(p) end
    for _,name in {'GeneratedWorld','GeneratedDungeon'} do local r=workspace:FindFirstChild(name);if r then Enemies.scan(r) end end
    Enemies.OnWarning=function(data)fx:FireAllClients(data)end
    Enemies.OnPlayerHit=Combat.hurt
    task.spawn(function()
        while task.wait(0.25) do
            Combat.tick(0.25)
            Expedition.step();Siege.step()
            for _,p in Players:GetPlayers() do
                local state=Data.get(p);local root=Security.alive(p)
                if state and root then
                    Tutorial.step(p)
                    if Identity.refresh(state) then Data.save(p,false);Service.state(p) end
                    for _,list in {Config.Cities,Config.Forests} do for _,region in list do
                        if (Vector2.new(root.Position.X,root.Position.Z)-Vector2.new(region.X,region.Z)).Magnitude<region.Radius then local identityChanged=Identity.event(state,'Visit:'..region.Id);if Rules.event(state,Catalog,'Visit:'..region.Id,1) or identityChanged then Service.state(p) end end
                    end end
                elseif Data.Sessions[p] and Data.Sessions[p].Frozen then p:SetAttribute('ProfileStatus','Unavailable') end
            end
        end
    end)
    Data.start();Dungeon.start();Enemies.start()
end
return Service
