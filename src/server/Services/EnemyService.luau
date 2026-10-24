local Players=game:GetService('Players')
local Pathfinding=game:GetService('PathfindingService')
local Shared=game.ReplicatedStorage.MedievalRPG
local Rig=require(Shared.RigFactory)
local Catalog=require(Shared.Config.ContentConfig)
local Config=require(Shared.Config.WorldConfig)
local Security=require(script.Parent.AntiExploitService)
local Patterns=require(Shared.Core.ActionMath)
local E={Active={},Spawns={},SpawnSet={},OnKill=nil,Running=false}
local function nearest(pos,radius)
    local best,dist
    for _,p in Players:GetPlayers() do
        local root=Security.alive(p)
        if root then
            local d=(root.Position-pos).Magnitude
            if d<radius and (not dist or d<dist) then best,dist=p,d end
        end
    end
    return best,dist
end
function E.scan(root)
    local folder=root:FindFirstChild('EnemySpawns')
    if folder then
        for _,marker in folder:GetChildren() do
            if marker:IsA('BasePart') and not E.SpawnSet[marker] then
                E.SpawnSet[marker]=true;table.insert(E.Spawns,{Marker=marker,Next=0,Root=root})
            end
        end
    end
end
local function spawnEnemy(s)
    local kind=s.Marker:GetAttribute('EnemyKind');local def=Catalog.Enemies[kind]
    if not def then return end
    local paint=Color3.fromRGB(table.unpack(def.Color))
    local model,hum,root=Rig.create(s.Root,def.Name,s.Marker.Position,paint,true,kind)
    model:SetAttribute('EnemyKind',kind);model:SetAttribute('HealthMax',def.Health);model:SetAttribute('Health',def.Health)
    local health=def.Health;local heightOffset=3
    if def.Boss then
        local participants=0;for _,p in Players:GetPlayers()do local r=Security.alive(p);if r and (r.Position-s.Marker.Position).Magnitude<100 then participants+=1 end end
        health=math.floor(def.Health*(1+0.35*(math.clamp(participants,1,4)-1)))
        local scale=if kind=='Malgorth' then 2.2 else 1.7
        model:ScaleTo(scale);heightOffset=3*scale
        model:PivotTo(CFrame.new(s.Marker.Position+Vector3.new(0,heightOffset,0)))
        model:SetAttribute('Boss',true);model:SetAttribute('PartyScale',math.clamp(participants,1,4))
    end
    model:SetAttribute('HealthMax',health);model:SetAttribute('Health',health)
    hum.MaxHealth=health;hum.Health=health;hum.WalkSpeed=def.Speed
    local e={Model=model,Hum=hum,Root=root,Kind=kind,Def=def,MaxHealth=health,HeightOffset=heightOffset,Spawn=s,Home=s.Marker.Position,LastAttack=0,Contributors={},State='IDLE',PathAt=0,Waypoints=nil,Waypoint=1,PathBusy=false,Target=nil,LastSpecial=os.clock(),SpecialCooldown=5}
    s.Enemy=e;E.Active[model]=e
    hum.HealthChanged:Connect(function(h) if model.Parent then model:SetAttribute('Health',h) end end)
    hum.Died:Connect(function()
        e.State='DEAD';model:SetAttribute('State','DEAD')
        if kind=='Malgorth' then s.Root:SetAttribute('BossDefeated',true) end
        if E.OnKill then local ok,err=xpcall(function()E.OnKill(e)end,debug.traceback);if not ok then warn(err)end end
        E.Active[model]=nil;s.Enemy=nil;s.Next=os.clock()+(if kind=='Malgorth' or kind=='Knight' then 300 else 25)
        task.delay(4,function() if model.Parent then model:Destroy() end end)
    end)
end
function E.damage(model,player,damage)
    local e=E.Active[model]
    if not e or e.Hum.Health<=0 then return false end
    if type(damage)~='number' or damage~=damage or damage<=0 or damage>100000 then return false end
    local actual=math.min(damage,e.Hum.Health)
    e.Contributors[player]=(e.Contributors[player] or 0)+actual
    e.Hum:TakeDamage(actual);e.ReactionUntil=os.clock()+0.15;return true
end
local function pathTo(e,target)
    if e.PathBusy or os.clock()-e.PathAt<2 then return end
    e.PathAt=os.clock();e.PathBusy=true
    task.spawn(function()
        local path=Pathfinding:CreatePath({AgentRadius=2,AgentHeight=6,AgentCanJump=true})
        local ok=pcall(function() path:ComputeAsync(e.Root.Position,target) end)
        if e.Model.Parent and ok and path.Status==Enum.PathStatus.Success then
            e.Waypoints=path:GetWaypoints();e.Waypoint=2;e.PathGoal=target
        end
        e.PathBusy=false
    end)
end
function E.step()
    local now=os.clock();local count=0
    for _ in E.Active do count+=1 end
    local cap=Config.QualityProfiles[Config.Quality].ActiveEnemies
    for _,s in E.Spawns do
        if s.Marker.Parent and not s.Enemy and now>=s.Next and count<cap and nearest(s.Marker.Position,220) then
            if not (s.Marker:GetAttribute('EnemyKind')=='Malgorth' and s.Root:GetAttribute('BossDefeated')) then spawnEnemy(s);count+=1 end
        end
    end
    for model,e in E.Active do
        if not model.Parent or not e.Root.Parent then E.Active[model]=nil;e.Spawn.Enemy=nil;continue end
        if now<(e.BurnUntil or 0) and now-(e.LastBurn or 0)>0.75 and e.BurnOwner then e.LastBurn=now;E.damage(model,e.BurnOwner,5) end
        if e.Hum.Health<=0 then continue end
        e.Hum.WalkSpeed=if now<(e.SlowUntil or 0) then e.Def.Speed*0.5 else e.Def.Speed
        if now<(e.StunnedUntil or 0) then e.Pending=nil;e.Hum:MoveTo(e.Root.Position);continue end
        local homeDist=(e.Root.Position-e.Home).Magnitude
        if e.Pending and (homeDist>95 or now<(e.StunnedUntil or 0)) then e.Pending=nil end
        if e.Def.Boss and homeDist<=95 then
            local phase=if e.Hum.Health<(e.MaxHealth or e.Def.Health)*0.5 then 2 else 1;model:SetAttribute('Phase',phase)
            if not e.Pending and nearest(e.Root.Position,45) and now-(e.LastSpecial or now-2)>e.SpecialCooldown then
                e.PatternIndex=(e.PatternIndex or 0)+1
                local pattern=Patterns.boss(e.Kind,phase,e.PatternIndex)
                e.LastSpecial=now;e.SpecialCooldown=pattern.Cooldown
                e.Pending={At=now+pattern.Windup,Origin=e.Root.Position,Pattern=pattern}
                if E.OnWarning then E.OnWarning({Kind='Warning',Position=e.Root.Position,Radius=pattern.Radius,InnerRadius=pattern.InnerRadius,Seconds=pattern.Windup,HeightOffset=e.HeightOffset or 3,Name=pattern.Name,Phase=phase}) end
            end
            if e.Pending then
                e.Hum:MoveTo(e.Root.Position);model:SetAttribute('State','WINDUP')
                if now>=e.Pending.At then
                    local pending=e.Pending;e.Pending=nil
                    for _,p in Players:GetPlayers() do
                        local pr=Security.alive(p)
                        local delta=pr and pr.Position-pending.Origin
                        if delta and Patterns.inArea(Vector2.new(delta.X,delta.Z).Magnitude,delta.Y,pending.Pattern) then
                            local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={model}
                            local hit=workspace:Raycast(pending.Origin,pr.Position-pending.Origin,params)
                            if E.OnPlayerHit and (not hit or hit.Instance:IsDescendantOf(p.Character))then E.OnPlayerHit(p,e.Def.Damage*pending.Pattern.Multiplier,pending.Origin)end
                        end
                    end
                end
                continue
            end
        end
        local player,dist=nearest(e.Root.Position,90)
        local homeDist=(e.Root.Position-e.Home).Magnitude
        local target
        if homeDist>95 or not player then
            e.State=if homeDist>8 then 'RETURN' elseif math.floor(now/4)%2==0 then 'IDLE' else 'PATROL'
            target=e.Home+Vector3.new(math.sin(now*0.12)*5,3,math.cos(now*0.12)*5)
        elseif dist<7+(if e.Kind=='Malgorth' then 3 else 0) then
            e.State='ATTACK';e.Hum:MoveTo(e.Root.Position)
            local pRoot=Security.alive(player)
            local rayParams=RaycastParams.new();rayParams.FilterType=Enum.RaycastFilterType.Exclude;rayParams.FilterDescendantsInstances={model}
            local hit=pRoot and workspace:Raycast(e.Root.Position,pRoot.Position-e.Root.Position,rayParams)
            if pRoot and now-e.LastAttack>1.3 and (not hit or hit.Instance:IsDescendantOf(player.Character)) then
                e.LastAttack=now
                if E.OnPlayerHit then E.OnPlayerHit(player,e.Def.Damage,e.Root.Position) end
            end
        else e.State='CHASE';local r=Security.alive(player);target=r and r.Position end
        model:SetAttribute('State',e.State)
        if target and e.State~='IDLE' then
            if e.Waypoints and e.PathGoal and (target-e.PathGoal).Magnitude>18 then e.Waypoints=nil end
            pathTo(e,target)
            local points=e.Waypoints
            local wp=points and points[e.Waypoint]
            if wp then
                if (wp.Position-e.Root.Position).Magnitude<5 then e.Waypoint+=1;wp=points[e.Waypoint] end
                if wp then if wp.Action==Enum.PathWaypointAction.Jump then e.Hum.Jump=true end;e.Hum:MoveTo(wp.Position) end
            end
            -- Sem caminho válido não atravessa paredes tentando mover o CFrame.
        end
        if not nearest(e.Home,300) then
            E.Active[model]=nil;e.Spawn.Enemy=nil;e.Spawn.Next=now+3;model:Destroy()
        end
    end
    for _,d in workspace:GetChildren() do
        if d.Name=='GeneratedDungeon' and d:FindFirstChild('Traps') then
            for _,trap in d.Traps:GetChildren() do
                local active=math.floor(now/2)%2==0
                trap.Transparency=if active then 0 else 0.7
                if active then
                    for _,p in Players:GetPlayers() do
                        if Security.near(p,trap,7) and Security.allow(p,'trap',1) then if E.OnPlayerHit then E.OnPlayerHit(p,12,trap.Position) end end
                    end
                end
            end
        end
    end
end
function E.start()
    if E.Running then return end;E.Running=true
    task.spawn(function() while task.wait(0.25) do local ok,err=xpcall(E.step,debug.traceback);if not ok then warn(err) end end end)
end
return E
