-- Planejamento puro: os mesmos lotes são usados no editor e nos testes CLI.
local Plan={}
local function distance(a,b) return math.sqrt((a.X-b.X)^2+(a.Z-b.Z)^2) end
function Plan.clear(c,mathTerrain,x,z,radius)
    return mathTerrain.roadDistance(c,x,z)>=radius+20
end
function Plan.build(c,mathTerrain,content)
    local plan={Cities={},Roads={},Trees={},Landmarks={},EnemySpawns={},Chests={}}
    for _,path in mathTerrain.roadPaths(c) do
        local segments={}
        for i=1,#path.Points-1 do
            local function groundPoint(point)
                local p=table.clone(point)
                if mathTerrain.riverDistance(c,p.X,p.Z)>=c.River.HalfWidth+c.River.BankWidth+40 then p.H=mathTerrain.height(c,p.X,p.Z) end
                return p
            end
            local p,q=groundPoint(path.Points[i]),groundPoint(path.Points[i+1])
            local x,z=(p.X+q.X)/2,(p.Z+q.Z)/2
            table.insert(segments,{A=p,B=q,Bridge=mathTerrain.riverDistance(c,x,z)<c.River.HalfWidth+c.River.BankWidth+40})
        end
        table.insert(plan.Roads,{Id=path.Id,Segments=segments,A=path.A,B=path.B,Points=path.Points,Width=path.Width})
    end
    local services={GuildHall=true,Tavern=true,Blacksmith=true,WeaponShop=true,MagicShop=true,Library=true,Forge=true,Castle=true,Temple=true,MagicSchool=true}
    local preferred={Castle={0,252},ArcaneTower={252,-84},Forge={-168,-168},Market={-84,-84},Tavern={84,-84},Library={168,168},Temple={-168,168}}
    for _,city in c.Cities do
        local result={Id=city.Id,Name=city.Name,Theme=city.Theme,X=city.X,Z=city.Z,H=city.Height,Radius=city.Radius,Lots={},Streets={}}
        -- A deliberately planned block system: lanes stay between 84-stud blocks.
        -- A free central cross and plaza connect to the cardinal city gates.
        for _,lane in {0,-126,126,-210,210} do
            local width=if lane==0 then 24 else 6
            table.insert(result.Streets,{A={X=city.X+lane,Z=city.Z-city.Radius+12,H=city.Height},B={X=city.X+lane,Z=city.Z+city.Radius-12,H=city.Height},Width=width})
            table.insert(result.Streets,{A={X=city.X-city.Radius+12,Z=city.Z+lane,H=city.Height},B={X=city.X+city.Radius-12,Z=city.Z+lane,H=city.Height},Width=width})
        end
        local candidates={}
        for row=-3,3 do for col=-3,3 do
            local x,z=col*84,row*84
            if col~=0 and row~=0 and math.sqrt(x*x+z*z)<city.Radius-44 then
                table.insert(candidates,{X=city.X+x,Z=city.Z+z,DX=x,DZ=z})
            end
        end end
        local specs={}
        for index,kind in content.CityBuildings[city.Id] do
            local visual=if city.Id=='Valoria' and kind=='GuardTower' then 'Castle' else kind
            local major=visual=='Castle' or visual=='ArcaneTower' or visual=='Forge'
            table.insert(specs,{Index=index,Kind=kind,VisualKind=visual,Radius=if major then 39 else 30,Major=major})
        end
        table.sort(specs,function(a,b)if a.Major~=b.Major then return a.Major end;return a.Index<b.Index end)
        local assigned={}
        for _,spec in specs do
            local index,kind,radius=spec.Index,spec.Kind,spec.Radius
            local visual=spec.VisualKind
            if city.Id=='Valoria' and kind=='GuildHall' and c.Guild then
                assigned[index]={Id=city.Id..'_'..index,Kind=kind,X=c.Guild.X+50,Z=c.Guild.Z,H=c.Guild.Height,Radius=30,Yaw=math.pi/2,External=true,District='GuildRoad',Variation=index%4,Interior=true,Theme=city.Theme}
                continue
            end
            local desired=preferred[visual] or {((index%2)*2-1)*168,((math.floor(index/2)%2)*2-1)*168}
            local found,best
            for _,candidate in candidates do
                local free=Plan.clear(c,mathTerrain,candidate.X,candidate.Z,radius)
                for _,lot in assigned do if distance(candidate,lot)<radius+lot.Radius+6 then free=false end end
                local score=(candidate.DX-desired[1])^2+(candidate.DZ-desired[2])^2
                if free and (not best or score<best) then best=score;found=candidate end
            end
            assert(found,'Sem quadra segura para '..city.Id..'/'..kind)
            local dx,dz=found.DX,found.DZ
            local yaw,streetX,streetZ
            if math.abs(dx)>math.abs(dz) then
                yaw=if dx>0 then math.pi/2 else -math.pi/2
                streetX=city.X+(if math.abs(dx)>=252 then (if dx>0 then 210 else -210) elseif math.abs(dx)>=168 then (if dx>0 then 126 else -126) else 0);streetZ=found.Z
            else
                yaw=if dz>0 then 0 else math.pi
                streetX=found.X;streetZ=city.Z+(if math.abs(dz)>=252 then (if dz>0 then 210 else -210) elseif math.abs(dz)>=168 then (if dz>0 then 126 else -126) else 0)
            end
            assigned[index]={Id=city.Id..'_'..index,Kind=kind,X=found.X,Z=found.Z,H=city.Height,Radius=radius,Yaw=yaw,
                District=(if dz<0 then 'North' else 'South')..(if dx<0 then 'West' else 'East'),Variation=index%4,VisualKind=visual,Interior=services[visual]==true,Theme=city.Theme,StreetX=streetX,StreetZ=streetZ}
        end
        for index=1,#content.CityBuildings[city.Id] do table.insert(result.Lots,assert(assigned[index])) end
        table.insert(plan.Cities,result)
    end
    -- Hash local independente de Random do engine: resultados idênticos no CLI/Studio.
    local state=math.max(1,c.Seed%2147483647)
    local function random()
        state=(state*48271)%2147483647
        return state/2147483647
    end
    for _,forest in c.Forests do
        local target=c.QualityProfiles[c.Quality].TreesPerForest
        local occupied={}
        local count=0
        for _=1,target*12 do
            if count>=target then break end
            -- Four composed groves around two deliberate open clearings.
            local grove=math.floor(random()*4)+1
            local offsets={{-0.43,-0.36},{0.44,-0.32},{0.37,0.40},{-0.40,0.37}}
            local anchor=offsets[grove]
            local angle=random()*math.pi*2
            local r=math.sqrt(random())*forest.Radius*0.42
            local x,z=forest.X+anchor[1]*forest.Radius+math.sin(angle)*r,forest.Z+anchor[2]*forest.Radius+math.cos(angle)*r
            local radial=distance({X=x,Z=z},forest)
            local key=math.floor(x/20)..":"..math.floor(z/20)
            local h,water=mathTerrain.column(c,x,z)
            local free=not occupied[key] and radial>80 and radial<forest.Radius and not water and Plan.clear(c,mathTerrain,x,z,12) and mathTerrain.riverDistance(c,x,z)>65
            for _,city in c.Cities do if distance({X=x,Z=z},city)<city.Radius+30 then free=false end end
            for _,site in c.ScenicReservations or {} do if distance({X=x,Z=z},site)<site.Radius+16 then free=false end end
            if free then
                occupied[key]=true;count+=1
                local variant=if forest.Id=='Vespera' and count%3~=0 then 3 elseif forest.Id=='Nocthar' and count%3==0 then 4 else count%5
                local scale=if forest.Id=='Nocthar' and count%13==0 then 2.1+random()*0.4 else 0.85+random()*0.85
                table.insert(plan.Trees,{X=x,Z=z,H=h,Scale=scale,Variant=variant,Forest=forest.Id,Cluster=grove,Theme=forest.Theme})
            end
        end
        assert(count>=target*0.8,"Densidade mínima da floresta não atingida")
        for i=1,6 do
            local x,z=forest.X+math.cos(i*1.9)*80,forest.Z+math.sin(i*1.9)*80
            table.insert(plan.EnemySpawns,{Id=forest.Id..i,X=x,Z=z,H=mathTerrain.height(c,x,z),Kind=if forest.Id=='Vespera' then (if i%2==0 then 'Demon' else 'DarkWolf') elseif forest.Id=="Nocthar" then (if i%3==0 then "Skeleton" else "Bandit") else (if i%3==0 then "Slime" else "Wolf")})
        end
        for i=1,5 do
            local x,z=forest.X+math.cos(i*2.1)*200,forest.Z+math.sin(i*2.1)*200
            table.insert(plan.Chests,{Id=forest.Id.."Chest"..i,X=x,Z=z,H=mathTerrain.height(c,x,z),Rarity=if i==5 then "Rare" else "Common"})
        end
        table.insert(plan.Landmarks,{Id=forest.Id,X=forest.X,Z=forest.Z,H=mathTerrain.height(c,forest.X,forest.Z)})
    end
    return plan
end
return Plan
