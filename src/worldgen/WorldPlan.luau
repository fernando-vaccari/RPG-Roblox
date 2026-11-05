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
    local preferred={Castle={0,242},ArcaneTower={198,-140},Forge={-198,-140},Market={-140,-140},Tavern={140,-140},Library={198,198},Temple={-198,198}}
    for _,city in c.Cities do
        local capital=city.Id=='Valoria'
        local inner=if capital then math.floor(city.Radius*0.60) else nil
        local result={Id=city.Id,Name=city.Name,Theme=city.Theme,X=city.X,Z=city.Z,H=city.Height,Radius=city.Radius,Lots={},Streets={},
            Monumental=true,InnerWallRadius=inner,CivicRadius=150,OuterWallRadius=city.Radius-6}
        -- Continuous boulevards join the four gates; ring streets give every
        -- frontage access without corridors through neighbouring buildings.
        local edge=city.Radius-12
        table.insert(result.Streets,{A={X=city.X-edge,Z=city.Z,H=city.Height},B={X=city.X+edge,Z=city.Z,H=city.Height},Width=28})
        table.insert(result.Streets,{A={X=city.X,Z=city.Z-edge,H=city.Height},B={X=city.X,Z=city.Z+edge,H=city.Height},Width=28})
        local rings={}
        for radius=180,city.Radius-50,58 do
            if not inner or math.abs(radius-inner)>50 then table.insert(rings,radius) end
        end
        local candidates={}
        for ring,radius in rings do
            if radius>city.Radius-40 then continue end
            local streetRadius=radius-28
            local pieces=math.ceil(math.pi*2*streetRadius/24)
            for segment=1,pieces do
                local a,b=(segment-1)/pieces*math.pi*2,segment/pieces*math.pi*2
                table.insert(result.Streets,{A={X=city.X+math.sin(a)*streetRadius,Z=city.Z+math.cos(a)*streetRadius,H=city.Height},
                    B={X=city.X+math.sin(b)*streetRadius,Z=city.Z+math.cos(b)*streetRadius,H=city.Height},Width=8,Ring=ring})
            end
            local count=math.floor(math.pi*2*radius/13)
            for i=1,count do
                local angle=(i-1+(ring%2)*0.5)/count*math.pi*2
                local dx,dz=math.sin(angle)*radius,math.cos(angle)*radius
                if math.abs(dx)>40 and math.abs(dz)>40 then
                    table.insert(candidates,{X=city.X+dx,Z=city.Z+dz,DX=dx,DZ=dz,Yaw=angle,Ring=ring,
                        StreetX=city.X+math.sin(angle)*streetRadius,StreetZ=city.Z+math.cos(angle)*streetRadius})
                end
            end
        end
        local assigned,lotGrid={},{}
        local function reserve(lot)
            local key=math.floor(lot.X/64)..":"..math.floor(lot.Z/64)
            lotGrid[key]=lotGrid[key] or {};table.insert(lotGrid[key],lot)
        end
        local function free(candidate,radius)
            if not Plan.clear(c,mathTerrain,candidate.X,candidate.Z,radius) then return false end
            if math.abs(candidate.DX)<radius+18 or math.abs(candidate.DZ)<radius+18 then return false end
            -- Reserve the switchback stair at the south gate, including landings.
            if candidate.DX+radius+4>-94 and candidate.DX-radius-4<-36
                and candidate.DZ+radius+4>result.OuterWallRadius-61 and candidate.DZ-radius-4<result.OuterWallRadius-21 then return false end
            local radial=math.sqrt(candidate.DX^2+candidate.DZ^2)
            if radial-radius<result.CivicRadius or radial+radius>result.OuterWallRadius-20 or inner and math.abs(radial-inner)<radius+20 then return false end
            local gx,gz=math.floor(candidate.X/64),math.floor(candidate.Z/64)
            for x=gx-2,gx+2 do for z=gz-2,gz+2 do
                for _,lot in lotGrid[x..":"..z] or {} do
                    if distance(candidate,lot)<=radius+lot.Radius+6 then return false end
                end
            end end
            return true
        end
        local function place(index,kind,visual,radius,residential)
            local desired=preferred[visual] or {((index%2)*2-1)*198,((math.floor(index/2)%2)*2-1)*198}
            local found,best
            for _,candidate in candidates do
                if free(candidate,radius) then
                    local targetRing=(index-#content.CityBuildings[city.Id]-1)%#rings+1
                    local score=if residential then math.abs(candidate.Ring-targetRing)*1000000+(candidate.DX-desired[1])^2+(candidate.DZ-desired[2])^2 else (candidate.DX-desired[1])^2+(candidate.DZ-desired[2])^2
                    if not best or score<best then best=score;found=candidate end
                end
            end
            if not found then return false end
            local dx,dz=found.DX,found.DZ
            assigned[index]={Id=if residential then city.Id..'_Residential_'..index else city.Id..'_'..index,Kind=kind,X=found.X,Z=found.Z,H=city.Height,Radius=radius,Yaw=found.Yaw,
                District=(if inner and math.sqrt(dx*dx+dz*dz)<inner then 'OldTown' else 'OuterWard')..'_'..found.Ring,
                Variation=index%4,VisualKind=visual,Interior=not residential and services[visual]==true,Theme=city.Theme,
                StreetX=found.StreetX,StreetZ=found.StreetZ,Residential=residential,Infill=residential,DetailTier=if residential then 1 else 0}
            reserve(assigned[index])
            return true
        end
        local specs={}
        for index,kind in content.CityBuildings[city.Id] do
            local visual=if capital and kind=='GuardTower' then 'Castle' else kind
            local major=visual=='Castle' or visual=='ArcaneTower' or visual=='Forge'
            table.insert(specs,{Index=index,Kind=kind,VisualKind=visual,Radius=if major then 39 else 30})
        end
        table.sort(specs,function(a,b)if a.Radius~=b.Radius then return a.Radius>b.Radius end;return a.Index<b.Index end)
        for _,spec in specs do
            local index,kind=spec.Index,spec.Kind
            if capital and kind=='GuildHall' and c.Guild then
                assigned[index]={Id=city.Id..'_'..index,Kind=kind,X=c.Guild.X+50,Z=c.Guild.Z,H=c.Guild.Height,Radius=30,Yaw=math.pi/2,External=true,District='GuildRoad',Variation=index%4,Interior=true,Theme=city.Theme}
            else
                assert(place(index,kind,spec.VisualKind,spec.Radius,false),'Sem lote seguro: '..city.Id..'/'..kind)
            end
        end
        local original=#content.CityBuildings[city.Id]
        local target=if capital then 360 else 180
        for index=original+1,target do
            if not place(index,if index%5==0 then 'LargeHouse' else 'SmallHouse',nil,24,true) then break end
        end
        for index=1,target do if assigned[index] then table.insert(result.Lots,assigned[index]) end end
        assert(#result.Lots>=(if capital then 300 else 140),'Densidade urbana insuficiente: '..city.Id..' '..#result.Lots)
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
        for _=1,target*30 do
            if count>=target then break end
            -- Four composed groves around two deliberate open clearings.
            local grove=math.floor(random()*4)+1
            local offsets={{-0.43,-0.36},{0.44,-0.32},{0.37,0.40},{-0.40,0.37}}
            local anchor=offsets[grove]
            local angle=random()*math.pi*2
            local r=math.sqrt(random())*forest.Radius*0.42
            local x,z=forest.X+anchor[1]*forest.Radius+math.sin(angle)*r,forest.Z+anchor[2]*forest.Radius+math.cos(angle)*r
            local radial=distance({X=x,Z=z},forest)
            local key=math.floor(x/24)..":"..math.floor(z/24)
            local scale=1+random()*0.4
            local rootRadius=16*scale
            local h,water=mathTerrain.column(c,x,z)
            local free=not occupied[key] and radial>80 and radial<forest.Radius and not water and Plan.clear(c,mathTerrain,x,z,rootRadius) and mathTerrain.riverDistance(c,x,z)>65
            for _,city in c.Cities do if distance({X=x,Z=z},city)<city.Radius+rootRadius+20 then free=false end end
            for _,site in c.ScenicReservations or {} do if distance({X=x,Z=z},site)<site.Radius+rootRadius+20 then free=false end end
            if free then
                occupied[key]=true;count+=1
                local variant=if forest.Id=='Vespera' and count%3~=0 then 3 elseif forest.Id=='Nocthar' and count%3==0 then 4 else count%5
                table.insert(plan.Trees,{X=x,Z=z,H=h,Scale=scale,Monumental=true,RootRadius=rootRadius,Variant=variant,Forest=forest.Id,Cluster=grove,Theme=forest.Theme})
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
