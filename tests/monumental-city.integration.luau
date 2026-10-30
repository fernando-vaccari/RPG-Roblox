-- Checks actual constructed parts in the limited host, not engine physics or FPS.
do
    local config=require(game.ReplicatedStorage.MedievalRPG.Config.WorldConfig)
    local terrain=require(game.ServerStorage.MedievalWorldgen.TerrainMath)
    local planner=require(game.ServerStorage.MedievalWorldgen.WorldPlan)
    local catalog=require(game.ReplicatedStorage.MedievalRPG.Config.ContentConfig)
    local architecture=require(game.ServerStorage.MedievalWorldgen.ArchitecturalPlan)
    local plan=planner.build(config,terrain,catalog)
    local root=assert(workspace:FindFirstChild('GeneratedWorld'))
    local buildings,gates,signs,parts=0,0,0,0
    for _,part in root:GetDescendants() do
        if part:IsA('BasePart') then parts+=1 end
    end
    assert(parts<100000,'Monumental native-part budget exceeded: '..parts)

    local function inBox(part,point)
        local p=part.CFrame:PointToObjectSpace(point)
        return math.abs(p.X)<part.Size.X/2-0.001
            and math.abs(p.Y)<part.Size.Y/2-0.001
            and math.abs(p.Z)<part.Size.Z/2-0.001
    end
    local function spatialIndex(model,h)
        local cells={}
        for _,part in model:GetDescendants() do
            if not part:IsA('BasePart') or part.CanCollide==false then continue end
            local minX,minY,minZ,maxX,maxY,maxZ=math.huge,math.huge,math.huge,-math.huge,-math.huge,-math.huge
            for _,x in {-1,1} do for _,y in {-1,1} do for _,z in {-1,1} do
                local p=part.CFrame:PointToWorldSpace(Vector3.new(x*part.Size.X/2,y*part.Size.Y/2,z*part.Size.Z/2))
                minX,minY,minZ=math.min(minX,p.X),math.min(minY,p.Y),math.min(minZ,p.Z)
                maxX,maxY,maxZ=math.max(maxX,p.X),math.max(maxY,p.Y),math.max(maxZ,p.Z)
            end end end
            if maxY<h+2 or minY>h+10 then continue end
            for x=math.floor(minX/64),math.floor(maxX/64) do
                for z=math.floor(minZ/64),math.floor(maxZ/64) do
                    local key=x..':'..z;cells[key]=cells[key] or {};table.insert(cells[key],part)
                end
            end
        end
        return function(point,context)
            local key=math.floor(point.X/64)..':'..math.floor(point.Z/64)
            for _,part in cells[key] or {} do
                assert(not inBox(part,point),context..' obstructed by '..part.Name..' in '..part.Parent.Name)
            end
        end
    end

    for _,city in plan.Cities do
        local model=assert(root.Cities:FindFirstChild(city.Id))
        local clear=spatialIndex(model,city.H)
        assert(#city.Lots>=(if city.Id=='Valoria' then 300 else 140),'Insufficient city density: '..city.Id)
        local fort=assert(model:FindFirstChild('MonumentalFortifications'),'Missing high walls: '..city.Id)
        local outer=assert(fort:FindFirstChild('OuterRing'))
        assert(outer:GetAttribute('WallHeight')>=80)
        assert(outer:GetAttribute('Radius')>=600)
        if city.Id=='Valoria' then
            local inner=assert(fort:FindFirstChild('InnerRing'),'Capital lost concentric walls')
            assert(inner:GetAttribute('WallHeight')>=60 and inner:GetAttribute('Radius')<outer:GetAttribute('Radius'))
        end
        for _,ring in fort:GetChildren() do
            local radius=ring:GetAttribute('Radius')
            for _,route in plan.Roads do
                for _,segment in route.Segments do
                    for _,t in {0,0.5,1} do
                        local x=segment.A.X+(segment.B.X-segment.A.X)*t
                        local z=segment.A.Z+(segment.B.Z-segment.A.Z)*t
                        if math.abs(math.sqrt((x-city.X)^2+(z-city.Z)^2)-radius)<32 then
                            local dx,dz=segment.B.X-segment.A.X,segment.B.Z-segment.A.Z
                            local length=math.sqrt(dx*dx+dz*dz)
                            for _,offset in {-(route.Width or 20)/2+1,0,(route.Width or 20)/2-1}do
                                for _,y in {3,6,9} do
                                    clear(Vector3.new(x-dz/length*offset,city.H+y,z+dx/length*offset),
                                        city.Id..'/'..route.Id..' full-width route through '..ring.Name)
                                end
                            end
                        end
                    end
                end
            end
            for _,gate in ring:GetChildren() do
                local angle=gate:GetAttribute('GateAngle')
                if angle==nil then continue end
                gates+=1
                assert(gate:GetAttribute('OpeningWidth')>=40 and gate:GetAttribute('OpeningHeight')>=30)
                local r=gate:GetAttribute('Radius')
                local frame=CFrame.new(city.X+math.sin(angle)*r,city.H,city.Z+math.cos(angle)*r)*CFrame.Angles(0,angle,0)
                -- A six-stud-wide walking corridor through the entire gate, including stairs.
                for _,x in {-3,0,3} do for z=-40,40,4 do for _,y in {3,6,9} do
                    clear(frame:PointToWorldSpace(Vector3.new(x,y,z)),city.Id..'/'..ring.Name..'/'..gate.Name)
                end end end
            end
        end
        -- Keep the cardinal streets open, including the civic square/spawn vicinity.
        for d=-city.Radius+80,city.Radius-80,12 do
            for _,offset in {-3,0,3} do for _,y in {3,6,9} do
                clear(Vector3.new(city.X+offset,city.H+y,city.Z+d),city.Id..' north/south avenue')
                clear(Vector3.new(city.X+d,city.H+y,city.Z+offset),city.Id..' east/west avenue')
            end end
        end
        for index,lot in city.Lots do
            buildings+=1
            local house=assert(model:FindFirstChild(lot.Id),'Missing planned house: '..lot.Id)
            local actual=table.clone(lot);actual.Kind=lot.VisualKind or lot.Kind
            local spec=architecture.build(actual.Kind,city.Id,index,actual)
            local frame=CFrame.new(lot.X,lot.H,lot.Z)*CFrame.Angles(0,lot.Yaw,0)
            local found=false
            for _,part in house:GetDescendants() do
                if not part:IsA('BasePart') then continue end
                local gui=part:FindFirstChildOfClass('SurfaceGui')
                if not gui then continue end
                local label=gui:FindFirstChildOfClass('TextLabel')
                if not label then continue end
                assert(type(label.Text)=='string' and #label.Text>3 and label.Visible~=false)
                assert(gui.Enabled~=false and gui.Face==Enum.NormalId.Front)
                assert(part.CanCollide==false and (part.Transparency or 0)<1,'Facade sign not visible/nonblocking')
                local p=frame:PointToObjectSpace(part.Position)
                local ahead=frame:PointToObjectSpace(part.CFrame:PointToWorldSpace(Vector3.new(0,0,-1)))
                assert(p.Z<-spec.Depth/2 and p.Y>=10,'Sign not in front of facade: '..lot.Id)
                assert(ahead.Z<p.Z-0.95,'Sign faces away from street: '..lot.Id)
                if not lot.Residential and (actual.Kind=='Tavern' or actual.Kind=='LargeHouse' or actual.Kind=='GuildHall') then
                    assert(p.Z<-spec.Depth/2-4.2,'Balcony obscures facade sign: '..lot.Id)
                end
                found=true;signs+=1
            end
            assert(found,'House has no identifying facade sign: '..lot.Id)
            for _,x in {-2,0,2} do for _,y in {3,6,8} do
                for z=-spec.Depth/2-8,-spec.Depth/2+2,2 do
                    clear(frame:PointToWorldSpace(Vector3.new(x,y,z)),lot.Id..' doorway')
                end
            end end
        end
    end
    assert(gates>=24 and signs>=buildings)
    print('PASSOU MAPA: '..buildings..' edifícios com placas frontais, '..gates..' portões e avenidas livres em amostras geométricas; '..parts..' Parts. Não é teste de física/FPS no Studio.')
end
