local Shared=game.ReplicatedStorage.MedievalRPG
local Catalog=require(Shared.Config.ContentConfig)
local Security=require(script.Parent.AntiExploitService)
local Data=require(script.Parent.DataService)
local Enemies=require(script.Parent.EnemyService)
local Config=require(Shared.Config.AbilityConfig)
local Rules=require(Shared.Core.CombatRules)
local Players=game:GetService('Players')
local Rig=require(Shared.RigFactory)
local Projectiles=require(script.Parent.ProjectileService)
local Combat={FX=nil,States={},Fields={}}
function Combat.clear(player)
 Projectiles.cancel(player)
 for i=#Combat.Fields,1,-1 do if Combat.Fields[i].Owner==player then table.remove(Combat.Fields,i)end end
 local old=Combat.States[player]
 if old and old.Summon then old.Summon.Model:Destroy() end
 Combat.States[player]=nil
end
function Combat.changeClass(player)
 Projectiles.cancel(player)
 for i=#Combat.Fields,1,-1 do if Combat.Fields[i].Owner==player then table.remove(Combat.Fields,i)end end
 local old=Combat.States[player]
 if old then
    if old.Summon then old.Summon.Model:Destroy();old.Summon=nil end
    old.GuardUntil=0;old.RegenUntil=0;old.Blocking=false
    local profile=Data.get(player)
    if profile then local stats=Rules.stats(profile,Config);old.Mana=math.min(old.Mana,stats.Mana);old.Stamina=math.min(old.Stamina,stats.Stamina) end
 end
end
function Combat.get(player)
    local profile=Data.get(player);if not profile then return nil end
    local stats=Rules.stats(profile,Config)
    if not Combat.States[player] then Combat.States[player]=Rules.new(stats) end
    return Combat.States[player],stats,profile
end
function Combat.hurt(player,amount,origin)
    local s,stats=Combat.get(player);local root=Security.alive(player)
    if not s or not root or os.clock()<s.DodgeUntil then return end
    local now=os.clock()
    if s.Blocking and s.Stamina>=10 and (not origin or (origin-root.Position).Unit:Dot(root.CFrame.LookVector)>0) then amount*=0.25;s.Stamina-=10 end
    if now<s.GuardUntil then amount*=0.5 end
    amount=math.max(1,math.floor(amount-stats.Defense))
    s.RecoverUntil=now+0.35
    player.Character:FindFirstChildOfClass('Humanoid'):TakeDamage(amount)
    if Combat.FX then Combat.FX:FireAllClients({Kind='Hit',A=origin or root.Position,B=root.Position,Damage=amount}) end
end
function Combat.control(player,mode)
    local s,stats=Combat.get(player);local root=Security.alive(player)
    if not s or not root then return end
    local now=os.clock()
    if mode=='BlockOff' then s.Blocking=false
    elseif mode=='BlockOn' and now>=s.RecoverUntil and s.Stamina>10 then s.Blocking=true;s.Sprinting=false
    elseif mode=='RunOff' then s.Sprinting=false
    elseif mode=='RunOn' and not s.Blocking and s.Stamina>10 then s.Sprinting=true
    elseif mode=='Dodge' and Rules.reserve(s,'Dodge',now,0,22,1,0.2) then
        s.DodgeUntil=now+0.32;root.AssemblyLinearVelocity=root.CFrame.LookVector*52+Vector3.new(0,root.AssemblyLinearVelocity.Y,0)
    end
end
function Combat.tick(dt)
    local now=os.clock()
    for i=#Combat.Fields,1,-1 do
        local field=Combat.Fields[i]
        if now>=field.Expires or not Security.alive(field.Owner) or field.Owner.Character~=field.Character then table.remove(Combat.Fields,i)
        elseif now>=field.Next then field.Next=now+1;Combat.impact(field.Owner,field.Position,nil,field.Spec)end
    end
    for _,p in Players:GetPlayers() do
        local s,stats,profile=Combat.get(p);local root=Security.alive(p)
        if s and root then
            Rules.step(s,stats,dt)
            local hum=p.Character:FindFirstChildOfClass('Humanoid');hum.MaxHealth=stats.Health
            hum.WalkSpeed=if s.Blocking then 8 elseif s.Sprinting then stats.Speed+10 else stats.Speed
            if os.clock()<(s.RegenUntil or 0) then hum.Health=math.min(hum.MaxHealth,hum.Health+(s.RegenRate or 8)*dt) end
            if s.Summon then
                local summon=s.Summon
                if os.clock()>summon.Expires or not summon.Model.Parent then summon.Model:Destroy();s.Summon=nil
                else
                    summon.Model:PivotTo(CFrame.new(root.Position+Vector3.new(4,0,4)))
                    if os.clock()>=summon.Next then
                        summon.Next=os.clock()+1.5
                        for model,enemy in Enemies.Active do
                            local delta=enemy.Root.Position-root.Position
                            if delta.Magnitude<50 then
                                local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={p.Character,summon.Model}
                                local hit=workspace:Raycast(root.Position,delta,params)
                                if not hit or hit.Instance:IsDescendantOf(model) then
                                    local endPos=enemy.Root.Position
                                    Enemies.damage(model,p,math.floor(12*stats.Damage))
                                    if Combat.FX then Combat.FX:FireAllClients({Kind='Hit',A=summon.Model.PrimaryPart.Position,B=endPos,Magic=true,Damage=12}) end
                                    break
                                end
                            end
                        end
                    end
                end
            end
            local level,progress,need=Rules.level(profile.XP,Config)
            for k,v in {Mana=s.Mana,MaxMana=stats.Mana,Stamina=s.Stamina,MaxStamina=stats.Stamina,Level=level,LevelXP=progress,NextXP=need} do p:SetAttribute(k,v) end
        end
    end
end
function Combat.apply(player,model,spec)
 local e=Enemies.Active[model];local root=Security.alive(player)
 if not e or not root or not Data.get(player) then return false end
 local pos=e.Root.Position
 if not Enemies.damage(model,player,spec.Damage) then return false end
 local now=os.clock()
 if spec.Effect=='Slow' then e.SlowUntil=now+4 end
 if spec.Effect=='Stun' then e.StunnedUntil=now+(if e.Kind=='Malgorth' then 0.2 else 0.9) end
 if spec.Effect=='Burn' then e.BurnUntil=now+4;e.BurnOwner=player end
 if spec.Effect=='Drain' then local h=player.Character:FindFirstChildOfClass('Humanoid');h.Health=math.min(h.MaxHealth,h.Health+math.floor(spec.Damage*0.2))end
 if Combat.FX then Combat.FX:FireAllClients({Kind='Hit',A=spec.Origin,B=pos,Magic=spec.Magic,Damage=spec.Damage,Effect=spec.Effect,Style=spec.Style})end
 return true
end
function Combat.impact(player,position,part,spec)
 if spec.Radius>0 and Combat.FX then Combat.FX:FireAllClients({Kind='Burst',Position=position,Radius=spec.Radius,Style=spec.Style})end
 local count=0
 for model,e in Enemies.Active do
  local direct=part and part:IsDescendantOf(model)
  if not direct and (spec.Radius==0 or (e.Root.Position-position).Magnitude>spec.Radius)then continue end
  if not direct then
   local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={player.Character}
   local hit=workspace:Raycast(position,e.Root.Position-position,params)
   if hit and not hit.Instance:IsDescendantOf(model)then continue end
  end
  if Combat.apply(player,model,spec)then count+=1 end
  if count>=8 then break end
 end
end
function Combat.attack(player,target,mode)
    local s,stats,profile=Combat.get(player);local root=Security.alive(player)
    if not s or not root then return end
    local item=Catalog.Items[profile.Equipment]
    local tool=player.Character:FindFirstChildOfClass('Tool')
    if mode~='Racial' and (not item or (profile.Inventory[profile.Equipment] or 0)<1 or not tool or tool:GetAttribute('ItemId')~=profile.Equipment) then return end
    item=item or {Damage=0,Range=0,Cooldown=1}
    if target~=nil and (typeof(target)~='Vector3' or target.X~=target.X or target.Y~=target.Y or target.Z~=target.Z or target.Magnitude>100000) then return end
    local skillDefinition=Config.Skills[mode]
    local projectileSpeed=skillDefinition and skillDefinition.ProjectileSpeed or (if mode=='Primary' and (profile.Equipment=='Bow' or profile.Equipment=='Staff') then 150 else nil)
    if projectileSpeed and not Projectiles.available(player) then return end
    local style=skillDefinition and skillDefinition.Style or (if profile.Equipment=='Bow' then 'Arrow' elseif profile.Equipment=='Staff' then 'Arcane' else 'Steel')
    if mode=='FlameField' and #Combat.Fields>=8 then return end
    local now=os.clock();local damage,range,radius,effect,combo=item.Damage,item.Range,0,'Hit',0
    if mode=='Racial' then
        local racial=profile.Identity and Config.RacialSkills[profile.Identity.Race]
        if not racial then return end
        if not Rules.reserve(s,'Racial',now,8,0,if profile.Identity.Evolution~='' then 18 else 20,0.25) then return end
        damage,range,radius,effect=racial.Power,0,0,racial.Effect
    elseif mode=='Primary' then
        local multiplier
        combo,multiplier=Rules.primary(s,now,if Rules.canUse(profile.Class,'Espadachim',Config) then 0.35 else item.Cooldown)
        if not combo then return end;damage*=multiplier
    elseif mode=='Heavy' then
        if not Rules.reserve(s,'Heavy',now,0,22,1.5,0.8) then return end
        damage*=2;range=14;radius=8;effect='Stun'
    elseif mode=='Pulse' and profile.Equipment=='Staff' then
        if not Rules.reserve(s,'Pulse',now,8,0,3,0.3) then return end
        damage,range,radius=26,16,16
    else
        local skill=Config.Skills[mode]
        if not skill or not Rules.canUse(profile.Class,skill.Class,Config) or stats.Level<skill.Level then return end
        if profile.Equipment~=Config.Classes[profile.Class].Weapon then return end
        if skill.Effect=='Summon' then
            local count=0;for _,state in Combat.States do if state.Summon then count+=1 end end
            if count>=16 and not s.Summon then return end
        end
        if skill.Level>1 and not profile.Unlocks[mode] then return end
        if not Rules.reserve(s,mode,now,skill.Mana,skill.Stamina,skill.Cooldown,0.45) then return end
        damage,range,radius,effect=skill.Damage,skill.Range,skill.Radius,skill.Effect
    end
    if Combat.FX then Combat.FX:FireClient(player,{Kind='Cooldown',Id=mode,Seconds=math.max(0,(s.Cooldowns[mode] or s.Cooldowns.Primary or now)-now),Combo=combo}) end
    if effect=='Summon' then
        if s.Summon then s.Summon.Model:Destroy() end
        local model=Rig.create(workspace,'Espírito de '..player.DisplayName,root.Position-Vector3.new(0,3,0),Color3.fromRGB(111,137,180),false,'Mage')
        s.Summon={Model=model,Expires=now+12,Next=now};return
    end
    if effect=='RestoreMana' then s.Mana=math.min(stats.Mana,s.Mana+damage);return end
    if effect=='RestoreStamina' then s.Stamina=math.min(stats.Stamina,s.Stamina+damage);return end
    if effect=='Guard' then s.GuardUntil=now+(if mode=='Racial' then 3 else 6);return end
    if effect=='Regen' then s.RegenRate=if mode=='Racial' then 3 else 8;s.RegenUntil=now+8;return end
    if effect=='Heal' then
        for _,p in Players:GetPlayers() do
            local r=Security.alive(p)
            if r and (p==player or radius>0 and (r.Position-root.Position).Magnitude<=radius) then
                local h=p.Character:FindFirstChildOfClass('Humanoid');h.Health=math.min(h.MaxHealth,h.Health+damage)
            end
        end
        return
    end
    local dir=if target and (target-root.Position).Magnitude>0.1 then (target-root.Position).Unit else root.CFrame.LookVector
    if projectileSpeed then
        local character=player.Character;local class=profile.Class
        local spec={Damage=math.floor(damage*stats.Damage),Radius=radius,Effect=effect,Origin=root.Position,Magic=profile.Equipment=='Staff',Style=style}
        Projectiles.launch(player,root.Position,dir,projectileSpeed,range,style,function()
            local current=Data.get(player);return current~=nil and player.Character==character and current.Class==class and Security.alive(player)~=nil
        end,function(at,part)Combat.impact(player,at,part,spec)end)
        return
    end
    local candidates={}
    for model,e in Enemies.Active do
        local delta=e.Root.Position-root.Position;local distance=delta.Magnitude
        if distance>0.1 and distance<=range and (radius>=range or delta.Unit:Dot(dir)>(if range>20 then 0.85 else 0)) then
            local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={player.Character}
            local hit=workspace:Raycast(root.Position,delta,params)
            if not hit or hit.Instance:IsDescendantOf(model) then table.insert(candidates,{Model=model,E=e,Distance=distance}) end
        end
    end
    table.sort(candidates,function(a,b)return a.Distance<b.Distance end)
    local center=candidates[1] and candidates[1].E.Root.Position
    if mode=='FlameField' then
        local point=center or root.Position+dir*math.min(range,25)
        local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={player.Character}
        local barrier=workspace:Raycast(root.Position,point-root.Position,params)
        if barrier and not center then point=barrier.Position end
        table.insert(Combat.Fields,{Owner=player,Character=player.Character,Position=point,Expires=now+5,Next=now+1,Spec={Radius=radius,Damage=math.max(1,math.floor(damage*stats.Damage*0.3)),Effect='Burn',Origin=point,Magic=true,Style='Fire'}})
        if Combat.FX then Combat.FX:FireAllClients({Kind='Warning',Position=point,Radius=radius,Seconds=5,HeightOffset=1,Name='Campo de Chamas',Friendly=true})end
    end
    if radius>0 and Combat.FX then Combat.FX:FireAllClients({Kind='Burst',Position=center or root.Position,Radius=radius,Style=style})end
    local hits=0
    for _,c in candidates do
        if hits>=8 or (radius==0 and hits>=1) then break end
        if radius>0 and center and (c.E.Root.Position-center).Magnitude>radius then continue end
        if Combat.apply(player,c.Model,{Damage=math.floor(damage*stats.Damage),Effect=effect,Origin=root.Position,Magic=profile.Equipment=='Staff',Style=style}) then hits+=1 end
    end
end
return Combat
