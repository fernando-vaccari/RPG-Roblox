local Players=game:GetService('Players')
local Shared=game.ReplicatedStorage.MedievalRPG
local Catalog=require(Shared.Config.ContentConfig)
local Abilities=require(Shared.Config.AbilityConfig)
local IdentityConfig=require(Shared.Config.IdentityConfig)
local UI={SkillButtons={},Settings={Quality='LOW',ReducedMotion=false,Sound=true},Cooldowns={},State=nil,Role=nil,City=nil,Party=nil,Remote=nil}
local color={Bg=Color3.fromRGB(30,29,35),Panel=Color3.fromRGB(48,43,43),Gold=Color3.fromRGB(232,195,116),Text=Color3.fromRGB(239,230,208)}
local function label(parent,text,size)
    local l=Instance.new('TextLabel');l.BackgroundTransparency=1;l.TextColor3=color.Text;l.Font=Enum.Font.Garamond
    l.TextSize=size or 20;l.TextWrapped=true;l.TextXAlignment=Enum.TextXAlignment.Left;l.Text=text;l.Parent=parent;return l
end
local function corner(parent) local c=Instance.new('UICorner');c.CornerRadius=UDim.new(0,7);c.Parent=parent end
function UI.send(action,value) UI.Remote:FireServer(action,value) end
function UI.notice(text)
    UI.Toast.Text=text;UI.Toast.Visible=true;UI.Toast:SetAttribute('Shown',os.clock())
    local time=UI.Toast:GetAttribute('Shown')
    task.delay(6,function() if UI.Toast:GetAttribute('Shown')==time then UI.Toast.Visible=false end end)
end
function UI.button(text,action,value,parent)
    local b=Instance.new('TextButton');b.Size=UDim2.new(1,-12,0,36);b.BackgroundColor3=color.Panel;b.TextColor3=color.Gold
    b.TextSize=16;b.Font=Enum.Font.Garamond;b.TextWrapped=true;b.Text=text;if not parent or parent==UI.List then b.AutomaticSize=Enum.AutomaticSize.Y end;corner(b);b.Parent=parent or UI.List
    b.Activated:Connect(function() if type(action)=='function' then action() else UI.send(action,value) end end)
    return b
end
function UI.info(text)
 local l=label(UI.List,text,17);l.Size=UDim2.new(1,-12,0,32);l.AutomaticSize=Enum.AutomaticSize.Y;return l
end
function UI.menu()
 UI.clear();UI.Panel.Visible=true;UI.Role=nil;UI.View='Menu';UI.Title.Text='Crônicas do Continente';UI.Dialogue.Text='Sua jornada, equipamentos e objetivos em um só lugar.'
 for _,entry in {{'Continuar',function()UI.Panel.Visible=false end},{'Inventário',UI.inventory},{'Missões',UI.quests},{'Mapa do continente',UI.map},{'Classes e habilidades',UI.skills},{'Linhagem e fusões',UI.identity},{'Configurações',UI.settings},{'VIP e pacotes',UI.offers}}do UI.button(entry[1],entry[2])end
 if UI.TesterAllowed then UI.button('Admin Tester • prévia segura',UI.tester)end
end
function UI.map()
 UI.clear();UI.Panel.Visible=true;UI.Role=nil;UI.View='Map';UI.Title.Text='Atlas do Continente';UI.Dialogue.Text='Norte para cima. Toque numa região para ver seu nome e coordenadas; as linhas indicam rotas terrestres.'
 local world=require(game.ReplicatedStorage.MedievalRPG.Config.WorldConfig)
 local canvas=Instance.new('Frame');canvas.Size=UDim2.new(1,-12,0,330);canvas.BackgroundColor3=Color3.fromRGB(45,69,53);canvas.Parent=UI.List
 local square=Instance.new('UIAspectRatioConstraint');square.AspectRatio=1;square.Parent=canvas
 for _,road in world.Roads do
  local dx,dz=road.B.X-road.A.X,road.B.Z-road.A.Z
  local line=Instance.new('Frame');line.AnchorPoint=Vector2.new(0.5,0.5)
  line.Position=UDim2.fromScale(0.5+(road.A.X+road.B.X)/2/world.WorldSize,0.5+(road.A.Z+road.B.Z)/2/world.WorldSize)
  line.Size=UDim2.fromScale(math.sqrt(dx*dx+dz*dz)/world.WorldSize,0.009);line.Rotation=math.deg(math.atan2(dz,dx));line.BorderSizePixel=0;line.BackgroundColor3=color.Gold;line.Parent=canvas
 end
 local function region(id,name,x,z)
  local button=UI.button(id,function()UI.notice(name..' • X '..x..' / Z '..z)end,nil,canvas)
  button.AnchorPoint=Vector2.new(0.5,0.5);button.Position=UDim2.fromScale(0.5+x/world.WorldSize,0.5+z/world.WorldSize);button.Size=UDim2.fromScale(0.23,0.08);button.TextSize=12
 end
 for _,list in {world.Cities,world.Forests}do for _,r in list do region(r.Id,r.Name,r.X,r.Z)end end
 region('Malgorth','Entrada da dungeon',world.DungeonEntrance.X,world.DungeonEntrance.Z)
 local root=Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
 if root then UI.info('Posição ao abrir: X '..math.floor(root.Position.X)..' / Z '..math.floor(root.Position.Z))end
 UI.button('Menu principal',UI.menu)
end
function UI.settings()
 UI.clear();UI.Panel.Visible=true;UI.Role=nil;UI.View='Settings';UI.Title.Text='Configurações';UI.Dialogue.Text='Preferências locais para efeitos e acessibilidade. Não alteram dano, IA ou recompensas.'
 for _,q in {'LOW','MEDIUM','HIGH'}do UI.button('Qualidade: '..q..(if UI.Settings.Quality==q then ' ✓' else ''),function()UI.Settings.Quality=q;UI.settings()end)end
 UI.button('Movimento reduzido: '..tostring(UI.Settings.ReducedMotion),function()UI.Settings.ReducedMotion=not UI.Settings.ReducedMotion;UI.settings()end)
 UI.button('Sons próprios: '..tostring(UI.Settings.Sound),function()UI.Settings.Sound=not UI.Settings.Sound;UI.settings()end)
 UI.button('Menu principal',UI.menu)
end
function UI.offers()
 UI.clear();UI.Panel.Visible=true;UI.Role=nil;UI.View='Offers';UI.Title.Text='VIP e pacotes';UI.Dialogue.Text='Nenhuma compra será ativada sem produto oficial e benefício aprovado.'
 UI.info('VIP e pacotes iniciais: benefícios e preços aguardam definição do criador. Não são vendidos nem simulados com benefícios inventados.')
 UI.info('Produtos já planejados: retry racial 150 Robux; 3 básicas 79; 3 premium 149. Veja Linhagem para elegibilidade. Compras indisponíveis nesta versão.')
 UI.button('Linhagem e tentativas',UI.identity);UI.button('Menu principal',UI.menu)
end
function UI.tester()
 UI.clear();UI.Panel.Visible=true;UI.Role=nil;UI.View='Tester';UI.Title.Text='Admin Tester • sem gravação';UI.Dialogue.Text='Relatório de benefícios aprovados. Nunca modifica Gold, raça, créditos reais ou recibos.'
 if not UI.TesterAllowed then UI.info('Desativado. Exige Studio, EnableStudioTester=true e persistência desligada.');return end
 for _,key in {'RacialRetry','BasicPack','PremiumPack'}do UI.button('Prévia: '..key,'TesterPreview',key)end
end
function UI.clear()
    UI.SkillButtons={}
    for _,child in UI.List:GetChildren() do if child:IsA('GuiObject') then child:Destroy() end end
end
function UI.quests()
    UI.clear();UI.Panel.Visible=true;UI.Role=nil;UI.View='Quests';UI.Title.Text='Diário de missões';UI.Dialogue.Text='Aceite missões na guilda ou com exploradores; entregue recompensas na guilda.'
    if not UI.State then return end
    local ids={};for id in Catalog.Quests do table.insert(ids,id)end;table.sort(ids)
    for _,id in ids do
        local q=Catalog.Quests[id]
        local s=UI.State.Quests[id]
        if s then
            UI.button(q.Name..': '..s.Count..'/'..q.Required..(if s.Claimed then ' • concluída' else ''),function() UI.notice('Para entregar, converse com a Guilda.') end)
        end
    end
end
function UI.inventory()
    UI.clear();UI.Panel.Visible=true;UI.Role=nil;UI.View='Inventory';UI.Title.Text='Inventário';UI.Dialogue.Text='Equipe uma arma ou use uma poção. Preços e saldo são calculados no servidor.'
    if not UI.State then return end
    UI.button('Linhagem, classes e fragmentos',UI.identity)
    UI.button('Desequipar arma','Unequip')
    for id,count in UI.State.Inventory do
        local item=Catalog.Items[id]
        if item and count>0 then
            UI.button(item.Name..' ×'..count,if item.Kind=='Consumable' then 'Potion' elseif item.Kind=='Weapon' then 'Equip' else function() UI.notice(if item.Kind=='Armor' then 'Couraça equipada automaticamente: +40 vida máxima.' elseif item.Kind=='Quest' then 'Item reservado à sua missão.' else 'Material negociável: procure um mercador.') end,id)
        end
    end
end
function UI.skills()
    UI.clear();UI.Panel.Visible=true;UI.Role=nil;UI.View='Skills';UI.Title.Text='Classes e habilidades'
    UI.Dialogue.Text='Classe desbloqueada pela missão inicial. Aprenda habilidades com o mestre de armas ou arcanista; custos e níveis são validados no servidor.'
    local class=UI.State and UI.State.Class or ''
    for id,skill in Abilities.Skills do
        if skill.Class==class or Abilities.Classes[class] and Abilities.Classes[class].Base==skill.Class then
            local text=skill.Name..' • Nv '..skill.Level..' • Mana '..skill.Mana..' / Stamina '..skill.Stamina..' • CD '..skill.Cooldown..'s'
            local button=UI.button(text,function()UI.send('Attack',{Mode=id})end)
            UI.SkillButtons[id]={Button=button,Text=text}
            if skill.Level<=1 or UI.State and UI.State.Unlocks[id] then UI.info('Disponível • '..skill.Name)else UI.button('Aprender '..skill.Name..' • '..skill.Price..' Gold','Learn',id)end
        end
    end
end
function UI.identity()
    UI.clear();UI.Panel.Visible=true;UI.Role=nil;UI.View='Identity';UI.Title.Text='Linhagem • Classes • Fusões'
    UI.button('Habilidades da classe',UI.skills)
    local state=UI.State;local s=state and state.Identity
    if not s then UI.Dialogue.Text='Aguardando perfil de identidade.';return end
    local race=IdentityConfig.Races[s.Race]
    UI.Dialogue.Text=(race and (race.Name..' • '..race.Identity) or 'Raça pendente: exige persistência confirmada.')..' | Classe: '..(state.Class~='' and state.Class or 'indefinida')..' | Fragmentos: '..s.Fragments
    local function info(text) UI.info(text) end
    if race then
        info('Traços: Vida '..race.Health..' • Mana '..race.Mana..' • Stamina '..race.Stamina..'. Raridade não multiplica dano.')
        info('Evolução: '..(s.Evolution~='' and s.Evolution or race.Evolution)..' • missão + '..IdentityConfig.EvolutionFragments..' fragmentos')
        local q=s.Racial;info('Missão racial: '..q.Status)
        if not race.Secret or s.Discoveries[race.Secret] then
            for i,step in race.Steps do info(step.Event..' • '..(q.Counts[tostring(i)] or 0)..'/'..step.Count) end
        else info('História racial secreta: procure sinais nas ruínas.') end
        if q.ReadyAt>(UI.ServerTime or 0) then info('Espera: '..math.ceil((q.ReadyAt-(UI.ServerTime or 0))/60)..' min (atualize para consultar)') end
        UI.button('Iniciar / repetir missão racial','RacialStart')
        UI.button('Concluir evolução racial','RacialClaim')
        UI.button('Usar habilidade racial (R)',function()UI.send('Attack',{Mode='Racial'})end)
        info('Créditos de nova tentativa: '..s.RetryCredits)
        if UI.Purchases and UI.Purchases.RacialRetry then UI.button('Nova tentativa • 150 Robux • janela oficial','Purchase','RacialRetry')
        else info('Nova tentativa paga indisponível. A repetição gratuita após 24h permanece disponível.') end
    end
    for _,base in IdentityConfig.PrimaryClasses do info('Classe principal: '..base) end
    info('Arqueiro preservado como classe alternativa compatível.')
    for id,def in IdentityConfig.Advanced do
        local challenge=s.Challenges[id]
        info(def.Base..' → '..id..' • nível '..def.Level..' • '..(s.Classes[id] and 'desbloqueada' or 'bloqueada'))
        if def.Secret and not s.Discoveries[def.Secret] then info('Missão secreta ainda não descoberta.')
        else
            for i,step in def.Steps do info(step.Event..' • '..(challenge and challenge.Counts[tostring(i)] or 0)..'/'..step.Count) end
            UI.button('Iniciar desafio: '..id,'ClassStart',id)
            UI.button('Concluir desafio: '..id,'ClassClaim',id)
        end
    end
    for id,unlocked in s.Classes do if unlocked then UI.button('Selecionar '..id,'ClassSelect',id) end end
    local week=math.floor(((UI.ServerTime or 0)+3*86400)/604800)
    local used=if week>s.Fusion.Week then 0 else s.Fusion.FreeUsed
    info('Fusões semanais: '..math.max(0,IdentityConfig.Fusion.WeeklyFree-used)..' grátis • '..s.Fusion.Basic..' básicas • '..s.Fusion.Premium..' premium')
    info('Combinações aguardam definição. Nenhuma tentativa/fragmento será consumido.')
    UI.info('Serviço de fusão em preparação. Tentativas e fragmentos permanecem guardados; compra com Gold indisponível.')
    for _,entry in {{'BasicPack',79},{'PremiumPack',149}} do
        if UI.Purchases and UI.Purchases[entry[1]] then UI.button('Pacote 3 • '..entry[2]..' Robux','Purchase',entry[1]) end
    end
    UI.button('Atualizar identidade','Hello')
end
function UI.dialogue(data)
    UI.View='Dialogue'
    UI.Role,UI.City,UI.Party=data.Role,data.City,data.Party
    UI.Panel.Visible=true;UI.Title.Text=data.Name;UI.Dialogue.Text=data.Text
    UI.render()
end
function UI.render()
    local role=UI.Role
    if not role then return end
    UI.clear()
    for _,id in Catalog.Shops[role] or {} do
        local item=Catalog.Items[id]
        UI.button(item.Name..' • '..item.Price..' Gold','Buy',id)
    end
    if role=='Merchant' and UI.State then
        for id,count in UI.State.Inventory do
            local item=Catalog.Items[id]
            if item and item.Price and item.Kind~='Quest' and count>0 then UI.button('Vender '..item.Name..' • '..math.floor(item.Price*0.4)..' Gold','Sell',id) end
        end
    end
    if role=='Equipment' or role=='ShopMagic' or role=='Mage' then UI.button('Abrir habilidades',UI.skills) end
    if role=='Guild' or role=='Quest' then
        if role=='Guild' and (not UI.State or UI.State.Rank=='')then UI.button('Registrar como aventureiro Rank F','Register')else UI.info('Guilda • Rank '..(UI.State and UI.State.Rank or 'pendente'))end
        local ids={};for id in Catalog.Quests do table.insert(ids,id)end;table.sort(ids)
        for _,id in ids do
            local q=Catalog.Quests[id]
            local s=UI.State and UI.State.Quests[id]
            if not s then
                local ready=true;for _,pre in q.Prerequisites or {}do if not UI.State or not UI.State.Quests[pre] or not UI.State.Quests[pre].Claimed then ready=false end end
                if not UI.State or UI.State.Rank=='' then ready=false end
                if ready then UI.info(q.Description..' • '..q.Gold..' Gold / '..q.XP..' XP');UI.button('Aceitar: '..q.Name,'Accept',id)else UI.info(q.Name..' • requer '..table.concat(q.Prerequisites or {},', '))end
            elseif not s.Claimed then
                UI.button(q.Name..' • '..s.Count..'/'..q.Required..(if role=='Guild' then ' • Entregar' else ''),if role=='Guild' then 'Claim' else function() UI.notice('Volte à Guilda para entregar.') end,id)
            end
        end
    elseif role=='Equipment' then
        for _,id in {'Longsword','Katana','Staff','Bow'} do UI.button((if id=='Bow' then 'Alternativa: Arqueiro' else if id=='Katana' then 'Espadachim' elseif id=='Staff' then 'Mago' else 'Guerreiro')..' • '..Catalog.Items[id].Name..' grátis','Choose',id) end
    elseif role=='Inn' then UI.button('Definir esta cidade como retorno','Inn')
    elseif role=='Healer' then UI.button('Receber cura gratuita','Heal')
    elseif role=='Dungeon' then
        UI.button('Atualizar estado do grupo','Hello')
        local p=UI.Party or {}
        if p.Leader then
            UI.info('Grupo '..p.Leader..' • '..(p.State or ''))
            for _,m in p.Members or {} do UI.info(m.Name..(if m.Confirmed then ' ✓ confirmado' else ' • aguardando')) end
            UI.button('Confirmar minha presença','DungeonConfirm')
            UI.button('Iniciar (líder)','DungeonStart')
            UI.button('Sair do grupo','DungeonLeave')
        else
            UI.button('Entrar sozinho','DungeonSolo');UI.button('Criar grupo até quatro','DungeonCreate')
            local input=Instance.new('TextBox');input.Size=UDim2.new(1,-12,0,36);input.PlaceholderText='Código numérico do líder';input.Text='';input.TextSize=18;input.TextColor3=color.Text;input.BackgroundColor3=color.Panel;input.ClearTextOnFocus=false;input.Parent=UI.List;corner(input)
            UI.button('Entrar com código',function() local code=tonumber(input.Text);if code then UI.send('DungeonJoin',code) end end)
        end
    end
    UI.button('Informações',function() UI.notice(UI.Dialogue.Text) end)
end
function UI.update(data)
    UI.State,UI.Party=data.State,data.Party;UI.ServerTime=data.ServerTime;UI.Purchases=data.Purchases;UI.TesterAllowed=data.State.TesterAllowed
    local s=data.State
    UI.Hud.Text=string.format('VALORIA • RPG    Gold: %d    XP: %d    Rank: %s    Classe: %s\n%s',s.Gold,s.XP,if s.Rank=='' then 'sem registro' else s.Rank,if s.Class=='' then 'indefinida' else s.Class,if s.Persistent then 'Salvamento automático' else 'TESTE DE SESSÃO • sem salvamento')
    if UI.Panel.Visible then
        if UI.Role then UI.render() elseif UI.View=='Inventory' then UI.inventory() elseif UI.View=='Quests' then UI.quests() elseif UI.View=='Identity' then UI.identity() elseif UI.View=='Skills' then UI.skills() end
    end
end
function UI.start(remote)
    UI.Remote=remote
    local gui=Instance.new('ScreenGui');gui.Name='MedievalRPG';gui.ResetOnSpawn=false;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=Players.LocalPlayer:WaitForChild('PlayerGui')
    local menuButton=UI.button('Menu',UI.menu,nil,gui);menuButton.Size=UDim2.fromOffset(74,32);menuButton.Position=UDim2.new(1,-82,1,-132)
    local hud=label(gui,'Carregando perfil...',18);hud.Size=UDim2.new(1,-20,0,60);hud.Position=UDim2.fromOffset(10,4);UI.Hud=hud
    local toast=label(gui,'',20);toast.Size=UDim2.new(0.8,0,0,70);toast.Position=UDim2.fromScale(0.1,0.18);toast.TextXAlignment=Enum.TextXAlignment.Center;toast.Visible=false;UI.Toast=toast
    local region=label(gui,'',25);region.Size=UDim2.fromScale(0.7,0.07);region.Position=UDim2.fromScale(0.15,0.1);region.TextXAlignment=Enum.TextXAlignment.Center;UI.Region=region
    local panel=Instance.new('Frame');panel.AnchorPoint=Vector2.new(0.5,0.5);panel.BackgroundColor3=color.Bg;panel.Size=UDim2.fromScale(0.85,0.64);panel.Position=UDim2.fromScale(0.5,0.56);panel.Visible=false;corner(panel);panel.Parent=gui;UI.Panel=panel
    local max=Instance.new('UISizeConstraint');max.MaxSize=Vector2.new(600,550);max.Parent=panel
    local title=label(panel,'',25);title.Size=UDim2.new(1,-50,0,40);title.Position=UDim2.fromOffset(12,4);UI.Title=title
    local close=Instance.new('TextButton');close.Text='×';close.Size=UDim2.fromOffset(35,35);close.Position=UDim2.new(1,-40,0,4);close.BackgroundTransparency=1;close.TextColor3=color.Gold;close.TextSize=30;close.Parent=panel;close.Activated:Connect(function()panel.Visible=false;UI.Role=nil end)
    local dialogue=label(panel,'',16);dialogue.Size=UDim2.new(1,-24,0,90);dialogue.Position=UDim2.fromOffset(12,45);UI.Dialogue=dialogue
    local list=Instance.new('ScrollingFrame');list.BackgroundTransparency=1;list.BorderSizePixel=0;list.Size=UDim2.new(1,-24,1,-150);list.Position=UDim2.fromOffset(12,140);list.AutomaticCanvasSize=Enum.AutomaticSize.Y;list.CanvasSize=UDim2.new();list.ScrollBarThickness=5;list.Parent=panel;UI.List=list
    local layout=Instance.new('UIListLayout');layout.Padding=UDim.new(0,5);layout.Parent=list
    local resources=label(gui,'',16);resources.Size=UDim2.new(0.7,0,0,45);resources.Position=UDim2.fromOffset(10,60)
    local bars={}
    for index,entry in {{'Vida',Color3.fromRGB(188,73,72)},{'Mana',Color3.fromRGB(82,120,214)},{'Stamina',Color3.fromRGB(99,172,112)},{'XP',color.Gold}} do
        local bar=Instance.new('Frame');bar.Size=UDim2.new(0.16,0,0,6);bar.Position=UDim2.new(0.01+(index-1)*0.17,0,0,106);bar.BackgroundColor3=color.Panel;bar.Parent=gui
        local fill=Instance.new('Frame');fill.Size=UDim2.fromScale(1,1);fill.BackgroundColor3=entry[2];fill.BorderSizePixel=0;fill.Parent=bar;bars[index]=fill
    end
    task.spawn(function()
        while gui.Parent do
            local p=Players.LocalPlayer;local hum=p.Character and p.Character:FindFirstChildOfClass('Humanoid')
            resources.Text=string.format('Nv %d   Vida %d/%d   Mana %d/%d   Stamina %d/%d   XP %d/%d',p:GetAttribute('Level') or 1,hum and hum.Health or 0,hum and hum.MaxHealth or 100,p:GetAttribute('Mana') or 0,p:GetAttribute('MaxMana') or 0,p:GetAttribute('Stamina') or 0,p:GetAttribute('MaxStamina') or 0,p:GetAttribute('LevelXP') or 0,p:GetAttribute('NextXP') or 80)
            local values={{hum and hum.Health or 0,hum and hum.MaxHealth or 100},{p:GetAttribute('Mana') or 0,p:GetAttribute('MaxMana') or 1},{p:GetAttribute('Stamina') or 0,p:GetAttribute('MaxStamina') or 1},{p:GetAttribute('LevelXP') or 0,p:GetAttribute('NextXP') or 1}}
            for i,v in values do bars[i].Size=UDim2.fromScale(math.clamp(v[1]/math.max(1,v[2]),0,1),1) end
            for id,entry in UI.SkillButtons do
                if entry.Button.Parent then
                    local remaining=math.max(0,math.ceil((UI.Cooldowns[id] or 0)-os.clock()))
                    entry.Button.Text=entry.Text..(if remaining>0 then ' • '..remaining..'s' else '')
                    entry.Button.Active=remaining==0
                end
            end
            task.wait(0.2)
        end
    end)
    local combatButtons=Instance.new('Frame');combatButtons.BackgroundTransparency=1;combatButtons.Size=UDim2.new(1,-16,0,38);combatButtons.Position=UDim2.new(0,8,1,-92);combatButtons.Parent=gui
    local row=Instance.new('UIListLayout');row.FillDirection=Enum.FillDirection.Horizontal;row.Padding=UDim.new(0,4);row.Parent=combatButtons
    for _,entry in {{'Pesado',function()UI.send('Attack',{Mode='Heavy'})end},{'Esquiva',function()UI.send('Control','Dodge')end},{'Bloquear',function()UI.Blocking=not UI.Blocking;UI.send('Control',if UI.Blocking then 'BlockOn' else 'BlockOff')end},{'Correr',function()UI.Running=not UI.Running;UI.send('Control',if UI.Running then 'RunOn' else 'RunOff')end},{'Linhagem',UI.identity}} do
        local b=UI.button(entry[1],entry[2],nil,combatButtons);b.Size=UDim2.new(0.19,0,1,0)
    end
    local buttons=Instance.new('Frame');buttons.BackgroundTransparency=1;buttons.Size=UDim2.new(1,-16,0,40);buttons.Position=UDim2.new(0,8,1,-48);buttons.Parent=gui
    local line=Instance.new('UIListLayout');line.FillDirection=Enum.FillDirection.Horizontal;line.Padding=UDim.new(0,6);line.Parent=buttons
    for _,entry in {{'Missões',UI.quests},{'Inventário',UI.inventory},{'Poção',function()UI.send('Potion')end},{'Pulso (Q)',function() UI.send('Attack',{Mode='Pulse'}) end}} do
        local b=UI.button(entry[1],entry[2],nil,buttons);b.Size=UDim2.new(0.23,0,1,0)
    end
    remote.OnClientEvent:Connect(function(data)
        if type(data)~='table' then return end
        if data.Type=='State' then UI.update(data)
        elseif data.Type=='Dialogue' then UI.dialogue(data)
        elseif data.Type=='Preview' then
            local p=data.Preview;UI.notice('PRÉVIA SEM GRAVAÇÃO • '..p.Grant..': '..p.Before..' → '..p.After)
        elseif data.Type=='Notice' then UI.notice(data.Text) end
    end)
    UI.send('Hello')
    task.delay(2,function() if not UI.State then UI.send('Hello') end end)
    return UI
end
return UI
