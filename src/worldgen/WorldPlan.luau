-- Planejamento puro: os mesmos lotes são usados no editor e nos testes CLI.
local Plan={}
local function distance(a,b) return math.sqrt((a.X-b.X)^2+(a.Z-b.Z)^2) end
function Plan.clear(c,mathTerrain,x,z,radius)
    for _,road in c.Roads do if mathTerrain.segment(x,z,road.A,road.B)<radius+20 then return false end end
    return true
end
function Plan.build(c,mathTerrain,content)
    local plan={Cities={},Roads={},Trees={},Landmarks={},EnemySpawns={},Chests={}}
    for _,road in c.Roads do
        local segments={}
        local n=math.ceil(distance(road.A,road.B)/16)
        for i=0,n-1 do
            local a,b=i/n,(i+1)/n
            local function point(t)
                return {X=road.A.X+(road.B.X-road.A.X)*t,Z=road.A.Z+(road.B.Z-road.A.Z)*t,H=road.A.H+(road.B.H-road.A.H)*t}
            end
            local p,q=point(a),point(b)
            local x,z=(p.X+q.X)/2,(p.Z+q.Z)/2
            table.insert(segments,{A=p,B=q,Bridge=mathTerrain.riverDistance(c,x,z)<c.River.HalfWidth+c.River.BankWidth+16})
        end
        table.insert(plan.Roads,{Id=road.Id,Segments=segments,A=road.A,B=road.B})
    end
    for _,city in c.Cities do
        local result={Id=city.Id,Name=city.Name,X=city.X,Z=city.Z,H=city.Height,Radius=city.Radius,Lots={}}
        for index,kind in content.CityBuildings[city.Id] do
            local major=kind=="Castle" or kind=="ArcaneTower" or kind=="Forge"
            local radius=if major then 39 else 30
            local found
            if city.Id=='Valoria' and kind=='GuildHall' and c.Guild then
                table.insert(result.Lots,{Id=city.Id..'_'..index,Kind=kind,X=c.Guild.X+50,Z=c.Guild.Z,H=c.Guild.Height,Radius=30,Yaw=math.pi/2,External=true})
                continue
            end
            -- Espiral determinística: grandes edifícios primeiro, círculo conservador evita sobreposição rotacionada.
            for ring=1,9 do
                if found then break end
                local r=65+ring*32
                local slots=math.floor(2*math.pi*r/(radius*2+10))
                for slot=1,slots do
                    local angle=slot/slots*math.pi*2+index*0.31
                    local x,z=city.X+math.sin(angle)*r,city.Z+math.cos(angle)*r
                    local candidate={X=x,Z=z,Radius=radius}
                    local free=r+radius<city.Radius-5 and Plan.clear(c,mathTerrain,x,z,radius)
                    for _,lot in result.Lots do if distance(candidate,lot)<radius+lot.Radius+6 then free=false end end
                    if free then
                        found={Id=city.Id.."_"..index,Kind=kind,X=x,Z=z,H=city.Height,Radius=radius,Yaw=angle}
                        table.insert(result.Lots,found); break
                    end
                end
            end
            assert(found,"Sem lote seguro para "..city.Id.."/"..kind..". Amplie o raio ou reduza a lista.")
        end
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
            local angle=random()*math.pi*2
            local r=math.sqrt(random())*forest.Radius
            local x,z=forest.X+math.sin(angle)*r,forest.Z+math.cos(angle)*r
            local key=math.floor(x/20)..":"..math.floor(z/20)
            local free=not occupied[key] and r>70 and Plan.clear(c,mathTerrain,x,z,12) and mathTerrain.riverDistance(c,x,z)>65
            for _,city in c.Cities do if distance({X=x,Z=z},city)<city.Radius+30 then free=false end end
            if free then
                occupied[key]=true; count+=1
                table.insert(plan.Trees,{X=x,Z=z,H=mathTerrain.height(c,x,z),Scale=0.8+random()*0.8,Variant=count%3,Forest=forest.Id})
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
