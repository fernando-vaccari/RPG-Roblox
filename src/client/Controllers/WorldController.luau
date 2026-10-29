local Players=game:GetService('Players')
local Lighting=game:GetService('Lighting')
local RunService=game:GetService('RunService')
local Tween=game:GetService('TweenService')
local Debris=game:GetService('Debris')
local Config=require(game.ReplicatedStorage.MedievalRPG.Config.WorldConfig)
local Environment=require(game.ReplicatedStorage.MedievalRPG.Core.EnvironmentRules)
local W={}
function W.start(ui,effects)
    local projectiles={};local rain={};local lastVisual=os.clock()
    local palette={Heal=Color3.fromRGB(121,222,170),Fire=Color3.fromRGB(255,121,52),Ice=Color3.fromRGB(118,220,250),Lightning=Color3.fromRGB(243,228,112),Arrow=Color3.fromRGB(194,165,105),Shadow=Color3.fromRGB(163,96,203),Steel=Color3.fromRGB(220,224,234)}
    local poses=setmetatable({}, {__mode='k'})
    local weatherLabel=Instance.new('TextLabel');weatherLabel.Size=UDim2.fromOffset(120,22);weatherLabel.Position=UDim2.new(1,-135,0,206);weatherLabel.BackgroundTransparency=1;weatherLabel.TextColor3=Color3.fromRGB(223,222,201);weatherLabel.TextSize=13;weatherLabel.Parent=ui.Hud.Parent
    local weatherGrade=Instance.new('ColorCorrectionEffect');weatherGrade.Name='LocalWeatherGrade';weatherGrade.Parent=Lighting
    local currentWeather=''
    local current='';local rigs={};local flags={};local updateAt=0;local nextScan=0;local fxWindow=0;local fxCount=0
    local localGrade=Instance.new('ColorCorrectionEffect');localGrade.Name='NoctharLocalGrade';localGrade.Parent=Lighting
    local map=Instance.new('Frame');map.Size=UDim2.fromOffset(130,130);map.Position=UDim2.new(1,-138,0,72);map.BackgroundColor3=Color3.fromRGB(36,62,47);map.BackgroundTransparency=0.15;map.Parent=ui.Hud.Parent
    local title=Instance.new('TextLabel');title.Size=UDim2.new(1,0,0,20);title.Text='N ↑   Continente';title.BackgroundTransparency=1;title.TextColor3=Color3.new(1,1,1);title.TextSize=12;title.Parent=map
    local dot=Instance.new('Frame');dot.Size=UDim2.fromOffset(5,5);dot.AnchorPoint=Vector2.new(0.5,0.5);dot.BackgroundColor3=Color3.new(1,1,1);dot.Parent=map
    for _,city in Config.Cities do
        local label=Instance.new('TextLabel');label.BackgroundTransparency=1;label.Size=UDim2.fromOffset(34,16);label.Text=string.sub(city.Id,1,3);label.TextSize=10;label.TextColor3=Color3.fromRGB(242,210,123);label.Position=UDim2.fromScale(0.5+city.X/Config.WorldSize,0.5+city.Z/Config.WorldSize);label.AnchorPoint=Vector2.new(0.5,0.5);label.Parent=map
    end
    local d=Instance.new('TextLabel');d.Size=UDim2.fromOffset(12,12);d.Text='D';d.BackgroundTransparency=1;d.TextColor3=Color3.fromRGB(241,80,107);d.Position=UDim2.fromScale(0.5,0.5+Config.DungeonEntrance.Z/Config.WorldSize);d.Parent=map
    local boss=Instance.new('TextLabel');boss.Size=UDim2.fromScale(0.6,0.04);boss.Position=UDim2.fromScale(0.2,0.21);boss.BackgroundColor3=Color3.fromRGB(59,26,36);boss.TextColor3=Color3.fromRGB(244,191,181);boss.TextScaled=true;boss.Visible=false;boss.Parent=ui.Hud.Parent
    effects.OnClientEvent:Connect(function(data)
        if data.Kind=='Cast' or data.Kind=='Defense' or data.Kind=='MeleeWarning' then
            local char=Players.LocalPlayer.Character;local r=char and char:FindFirstChild('HumanoidRootPart')
            if not r or (r.Position-data.Position).Magnitude>130 then return end
            if os.clock()-fxWindow>=1 then fxWindow=os.clock();fxCount=0 end
            if data.Kind~='MeleeWarning' then
                fxCount+=1;if fxCount>math.min(Config.MaxCombatFX,Environment.Profiles[ui.Settings.Quality].FX) then return end
            end
            local anchor=Instance.new('Part');anchor.Name='ActionFeedback';anchor.Size=Vector3.new(0.15,0.15,0.15);anchor.Position=data.Position+Vector3.new(0,4,0);anchor.Anchored=true;anchor.Transparency=1;anchor.CanCollide=false;anchor.CanTouch=false;anchor.CanQuery=false;anchor.Parent=workspace
            local billboard=Instance.new('BillboardGui');billboard.Size=UDim2.fromOffset(160,36);billboard.AlwaysOnTop=true;billboard.Parent=anchor
            local text=Instance.new('TextLabel');text.BackgroundTransparency=1;text.Size=UDim2.fromScale(1,1);text.Font=Enum.Font.Garamond;text.TextSize=20;text.TextColor3=palette[data.Style] or Color3.fromRGB(247,204,103);text.Parent=billboard
            text.Text=if data.Kind=='MeleeWarning' then '⚔ APARÁVEL' elseif data.Outcome=='Parry' then 'APARO!' elseif data.Outcome=='Break' then 'GUARDA QUEBRADA' elseif data.Outcome=='Block' then 'BLOQUEIO' elseif data.Outcome=='Dodge' then 'ESQUIVA' else ''
            Debris:AddItem(anchor,data.Seconds or 0.65)
            if data.Kind=='Cast' then
                local actor=Players:GetPlayerByUserId(data.Actor);local model=actor and actor.Character
                if model and not ui.Settings.ReducedMotion then
                    for _,joint in model:GetDescendants() do
                        if joint:IsA('Motor6D') and (joint.Name=='RightShoulder' or joint.Name=='Right Shoulder') then
                            local pose=poses[joint] or {Base=joint.C0,Serial=0};poses[joint]=pose;pose.Serial+=1;local serial=pose.Serial
                            Tween:Create(joint,TweenInfo.new(0.12),{C0=pose.Base*CFrame.Angles(-0.8,0,if data.Mode=='Heavy' then 0.8 else 0.35)}):Play()
                            task.delay(0.18,function()if joint.Parent and pose.Serial==serial then Tween:Create(joint,TweenInfo.new(0.18),{C0=pose.Base}):Play() end end)
                        end
                    end
                end
            end
            return
        end
        if data.Kind=='Burst' then
            local root=Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
            if not root or (root.Position-data.Position).Magnitude>180 then return end
            if os.clock()-fxWindow>=1 then fxWindow=os.clock();fxCount=0 end
            fxCount+=1;if fxCount>math.min(Config.MaxCombatFX,Environment.Profiles[ui.Settings.Quality].FX) then return end
            local p=Instance.new('Part');p.Name='LocalExplosion';p.Shape=Enum.PartType.Ball;p.Size=Vector3.new(1,1,1);p.Position=data.Position
            p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Material=Enum.Material.Neon;p.Transparency=0.75;p.Color=palette[data.Style] or Color3.fromRGB(178,156,228);p.Parent=workspace
            local size=Vector3.new(data.Radius*2,data.Radius*2,data.Radius*2)
            if ui.Settings.ReducedMotion then p.Size=size;p.Transparency=0.9 else Tween:Create(p,TweenInfo.new(0.4),{Size=size,Transparency=1}):Play()end
            Debris:AddItem(p,0.5);return
        end
        if data.Kind=='ProjectileEnd' then
            local p=projectiles[data.Id];if p then p.Part:Destroy();projectiles[data.Id]=nil end;return
        elseif data.Kind=='Projectile' then
            local r=Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
            local count=0;for _ in projectiles do count+=1 end
            if not r or (r.Position-data.Origin).Magnitude>180 or count>=math.min(Config.MaxCombatFX,Environment.Profiles[ui.Settings.Quality].FX) then return end
            local p=Instance.new('Part');p.Name='LocalProjectile';p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
            p.Color=palette[data.Style] or Color3.fromRGB(135,150,244);p.Material=Enum.Material.Neon
            p.Size=if data.Style=='Arrow' then Vector3.new(0.15,0.15,3) else Vector3.new(1.2,1.2,1.2)
            if data.Style~='Arrow'then p.Shape=Enum.PartType.Ball end
            p.CFrame=CFrame.lookAt(data.Origin,data.Origin+data.Direction);p.Parent=workspace
            projectiles[data.Id]={Part=p,Origin=data.Origin,Direction=data.Direction,Speed=data.Speed,Range=data.Range,Travel=0}
            return
        elseif data.Kind=='Warning' then
            local r=Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
            if not r or (r.Position-data.Position).Magnitude>180 then return end
            local disk=Instance.new('Part');disk.Name='DangerTelegraph';disk.Size=Vector3.new(0.15,data.Radius*2,data.Radius*2)
            disk.Shape=Enum.PartType.Cylinder;disk.CFrame=CFrame.new(data.Position-Vector3.new(0,(data.HeightOffset or 3)-0.1,0))*CFrame.Angles(0,0,math.pi/2)
            disk.Color=if data.Friendly then Color3.fromRGB(231,163,67)else Color3.fromRGB(244,78,62);disk.Material=Enum.Material.Neon;disk.Transparency=0.65;disk.Anchored=true;disk.CanCollide=false;disk.CanQuery=false;disk.CanTouch=false;disk.Parent=workspace
            if (data.InnerRadius or 0)>0 then
                local safe=Instance.new('Part');safe.Name='SafeCenter';safe.Shape=Enum.PartType.Cylinder;safe.Size=Vector3.new(0.16,data.InnerRadius*2,data.InnerRadius*2);safe.CFrame=disk.CFrame+Vector3.new(0,0.1,0)
                safe.Color=Color3.fromRGB(83,197,153);safe.Transparency=0.35;safe.Material=Enum.Material.Neon;safe.Anchored=true;safe.CanCollide=false;safe.CanTouch=false;safe.CanQuery=false;safe.Parent=workspace;Debris:AddItem(safe,data.Seconds)
            end
            Debris:AddItem(disk,data.Seconds);if not data.Friendly then ui.notice(data.Name..(if (data.InnerRadius or 0)>0 then ' • centro verde é seguro!'else ' • saia da área vermelha!'))end;return
        end
        if data.Kind=='Cooldown' then
            ui.Cooldowns[data.Id]=os.clock()+(data.Seconds or 0)
            return end
        if data.Kind=='Hit' and typeof(data.A)=='Vector3' and typeof(data.B)=='Vector3' then
            local midpoint=(data.A+data.B)/2
            local char=Players.LocalPlayer.Character;local r=char and char:FindFirstChild('HumanoidRootPart')
            if not r or (r.Position-midpoint).Magnitude>180 then return end
            if os.clock()-fxWindow>=1 then fxWindow=os.clock();fxCount=0 end
            fxCount+=1;if fxCount>math.min(Config.MaxCombatFX,Environment.Profiles[ui.Settings.Quality].FX)then return end
            local audio=Config.Audio.Impact
            if ui.Settings.Sound and type(audio)=='string' and string.match(audio,'^rbxassetid://%d+$') then
                local sound=Instance.new('Sound');sound.SoundId=audio;sound.Volume=0.25;sound.Parent=workspace.CurrentCamera;sound:Play();Debris:AddItem(sound,2)
            end
            local p=Instance.new('Part');p.Name='LocalCombatFX';p.Size=Vector3.new(0.15,0.15,(data.B-data.A).Magnitude);p.CFrame=CFrame.lookAt(midpoint,data.B)
            p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Material=Enum.Material.Neon;p.Color=palette[data.Style] or (if data.Magic then Color3.fromRGB(135,118,253) else Color3.fromRGB(244,211,145));p.Parent=workspace;Debris:AddItem(p,0.15)
            if data.Damage then
                local anchor=Instance.new('Part');anchor.Size=Vector3.new(0.1,0.1,0.1);anchor.Position=data.B;anchor.Transparency=1;anchor.Anchored=true;anchor.CanCollide=false;anchor.CanQuery=false;anchor.Parent=workspace
                local billboard=Instance.new('BillboardGui');billboard.Size=UDim2.fromOffset(100,40);billboard.AlwaysOnTop=true;billboard.Parent=anchor
                local number=Instance.new('TextLabel');number.Size=UDim2.fromScale(1,1);number.BackgroundTransparency=1;number.Text=tostring(data.Damage)..(if data.Critical then '!' else '');number.TextSize=if data.Critical then 28 else 24;number.TextColor3=Color3.fromRGB(255,207,103);number.Parent=billboard;Debris:AddItem(anchor,0.7)
            end
        elseif data.Kind=='Chest' then ui.notice('Tesouro recebido! O saque é individual.') end
    end)
    RunService.Heartbeat:Connect(function()
        local now=os.clock();local visualDelta=math.min(0.1,now-lastVisual);lastVisual=now
        for id,p in projectiles do
            p.Travel+=p.Speed*visualDelta
            if not p.Part.Parent or p.Travel>=p.Range then p.Part:Destroy();projectiles[id]=nil
            else local pos=p.Origin+p.Direction*p.Travel;p.Part.CFrame=CFrame.lookAt(pos,pos+p.Direction)end
        end
        if now-updateAt<0.2 then return end;updateAt=now
        local char=Players.LocalPlayer.Character;local root=char and char:FindFirstChild('HumanoidRootPart')
        if not root then return end
        map.Visible=not ui.Compact;weatherLabel.Visible=not ui.Compact
        boss.Size=if ui.Compact then UDim2.new(0.4,-16,0,22) else UDim2.fromScale(0.6,0.04)
        boss.Position=if ui.Compact then UDim2.fromOffset(10,172) else UDim2.new(0.2,0,0,218)
        local weather=Environment.weather(workspace:GetServerTimeNow())
        if weather~=currentWeather then
            currentWeather=weather
            Tween:Create(weatherGrade,TweenInfo.new(4),{TintColor=if weather=='Clear' then Color3.new(1,1,1)else Color3.fromRGB(209,219,235),Brightness=if weather=='Clear'then 0 else -0.03}):Play()
        end
        weatherLabel.Text=if weather=='Rain' then 'Chuva' elseif weather=='Mist' then 'Névoa' else 'Céu aberto'
        local quality=Environment.Profiles[ui.Settings.Quality]
        local bloom=Lighting:FindFirstChild('MedievalBloom');if bloom then bloom.Intensity=quality.Bloom end
        local rainCount=if weather=='Rain' then quality.Rain else 0
        for i=1,24 do
            local p=rain[i]
            if i<=rainCount then
                if not p then
                    p=Instance.new('Part');p.Name='LocalRain';p.Size=Vector3.new(0.06,1.6,0.06);p.Color=Color3.fromRGB(155,184,201);p.Transparency=0.45;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Parent=workspace;rain[i]=p
                end
                local y=22-(now*26+i*3)%24;p.Position=root.Position+Vector3.new(math.sin(i*13)*16,y,math.cos(i*7)*16);p.Transparency=0.45
            elseif p then p.Transparency=1 end
        end
        local region='Terras Livres';local dark=false
        for _,list in {Config.Cities,Config.Forests} do
            for _,r in list do
                if (Vector2.new(root.Position.X,root.Position.Z)-Vector2.new(r.X,r.Z)).Magnitude<r.Radius then region=r.Name;dark=r.Id=='Nocthar' end
            end
        end
        if Players.LocalPlayer:GetAttribute('InDungeon') then region=Players.LocalPlayer:GetAttribute('DungeonName') or 'Abismo • Recepção e salas legadas' end
        if region~=current then
            current=region;ui.Region.Text=region
            Tween:Create(localGrade,TweenInfo.new(2),{TintColor=if dark then Color3.fromRGB(174,176,207) else Color3.new(1,1,1),Brightness=if dark then -0.06 else 0}):Play()
        end
        dot.Visible=not Players.LocalPlayer:GetAttribute('InDungeon')
        title.Text=if Players.LocalPlayer:GetAttribute('InDungeon')then 'Interior separado'else 'N ↑ Continente'
        dot.Position=UDim2.fromScale(math.clamp(0.5+root.Position.X/Config.WorldSize,0,1),math.clamp(0.5+root.Position.Z/Config.WorldSize,0,1))
        -- Cache limitado a modelos carregados pelo streaming; evita varrer Workspace por frame.
        if now>=nextScan then
            nextScan=now+3
            table.clear(rigs);table.clear(flags)
            for _,name in {'GeneratedWorld','GeneratedDungeon'} do
                local world=workspace:FindFirstChild(name)
                if world then
                    local cities=world:FindFirstChild('Cities')
                    if cities then
                        for _,p in cities:GetDescendants() do
                            if p:IsA('BasePart') and p:GetAttribute('Flutter') then table.insert(flags,{Part=p,Base=p.CFrame}) end
                        end
                    end
                    local npcs=world:FindFirstChild('NPCs')
                    if npcs then for _,m in npcs:GetChildren() do if m:IsA('Model') then table.insert(rigs,m) end end end
                    for _,m in world:GetChildren() do if m:IsA('Model') and m:GetAttribute('EnemyKind') then table.insert(rigs,m) end end
                    local expeditions=world:FindFirstChild('Expeditions')
                    if expeditions then for _,tower in expeditions:GetChildren() do for _,floor in tower:GetChildren() do
                        if floor:GetAttribute('Active') then for _,m in floor:GetChildren() do if m:IsA('Model') and m:GetAttribute('EnemyKind') then table.insert(rigs,m) end end end
                    end end end
                end
            end
        end
        for _,entry in flags do
            if not ui.Settings.ReducedMotion and entry.Part.Parent and (entry.Part.Position-root.Position).Magnitude<150 then entry.Part.CFrame=entry.Base*CFrame.Angles(0,math.sin(now*1.5)*0.04,0) end
        end
        boss.Visible=false
        for _,model in rigs do
            local r=model:FindFirstChild('HumanoidRootPart')
            if r and (r.Position-root.Position).Magnitude<120 then
                local torso=model:FindFirstChild('Torso')
                if torso and not ui.Settings.ReducedMotion then
                    for _,j in torso:GetChildren() do
                        if j:IsA('Motor6D') then
                            if j.Name=='Left Shoulder' or j.Name=='Right Shoulder' then j.Transform=CFrame.Angles(if model:GetAttribute('State')=='WINDUP' then -1.4 else math.sin(now*2+r.Position.X)*0.07,0,0)
                            elseif j.Name=='Left Hip' or j.Name=='Right Hip' then
                                local moving=r.AssemblyLinearVelocity.Magnitude>1
                                j.Transform=CFrame.Angles(if moving then math.sin(now*7)*(if j.Name=='Left Hip' then 0.35 else -0.35) else 0,0,0)
                            end
                        end
                    end
                end
                if model:GetAttribute('Boss')==true then boss.Text=model.Name..'  '..math.ceil(model:GetAttribute('Health') or 0)..' / '..(model:GetAttribute('HealthMax') or 1400);boss.Visible=true end
            end
        end
    end)
end
return W
