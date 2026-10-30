-- Appended by bake_continent.py after the explicitly simulated authoring host.
-- This emits scene data only; it does NOT execute Roblox Studio or Terrain.
do
    local config=require(game.ReplicatedStorage.MedievalRPG.Config.WorldConfig)
    local terrain=require(game.ServerStorage.MedievalWorldgen.TerrainMath)
    env.Height=function(x,z)return terrain.height(config,x,z)end
    -- The integration mock's yaw-only lookAt is insufficient for baked slopes.
    -- Compose yaw and elevation using the existing matrix implementation.
    env.CFrame.lookAt=function(a,b)
        local d=b-a
        local yaw=math.atan2(-d.X,-d.Z)
        local pitch=math.atan2(d.Y,math.sqrt(d.X*d.X+d.Z*d.Z))
        return env.CFrame.new(a)*env.CFrame.Angles(0,yaw,0)*env.CFrame.Angles(pitch,0,0)
    end
    local generator=require(game.ServerStorage.MedievalWorldgen.WorldGenerator)
    local scene=generator.GenerateMapScene()
    local report=generator.ValidateMapScene()
    assert(scene:GetAttribute('SceneOnly') and scene:GetAttribute('TerrainPending'))
    assert(env.VoxelWrites==0,'Offline exporter must never pretend to write Terrain')

    local ids={};local nextId=0
    local function assign(node)
        nextId+=1;ids[node]=nextId
        for _,child in node:GetChildren()do assign(child)end
    end
    assign(scene);assign(game.Lighting)
    local function typed(v)
        local kind=type(v)
        if kind=='nil' or kind=='boolean' or kind=='string' then return v end
        if kind=='number' then assert(v==v and math.abs(v)<math.huge,'Non-finite scene number');return v end
        assert(kind=='table','Unsupported exported value: '..kind)
        if v._class then return {Type='Ref',Value=assert(ids[v],'Reference outside scene export')} end
        if v.Position and type(v.R)=='table' then
            return {Type='CFrame',Value={v.Position.X,v.Position.Y,v.Position.Z,table.unpack(v.R)}}
        end
        if v.R and v.G and v.B then return {Type='Color3',Value={v.R,v.G,v.B}} end
        if type(v.X)=='table' and v.X.Scale then
            return {Type='UDim2',Value={v.X.Scale,v.X.Offset,v.Y.Scale,v.Y.Offset}}
        end
        if v.Scale then return {Type='UDim',Value={v.Scale,v.Offset}} end
        if v.X~=nil and v.Y~=nil then return {Type='Vector3',Value={v.X,v.Y,v.Z or 0}} end
        error('Unrecognized scene data value')
    end
    local function node(n)
        local properties,attributes,children={},{},{}
        for key,value in n._props do
            if key~='Parent' and key~='Position' and key~='AssemblyLinearVelocity' then properties[key]=typed(value)end
        end
        for key,value in n._attrs do attributes[key]=typed(value)end
        for _,child in n:GetChildren()do table.insert(children,node(child))end
        return {Id=ids[n],Class=n.ClassName,Properties=properties,Attributes=attributes,Children=children}
    end
    local function quote(s)
        return '"'..string.gsub(s,'[%z\1-\31\\"]',function(c)
            if c=='"'then return '\\"'elseif c=='\\'then return '\\\\'end
            return string.format('\\u%04x',string.byte(c))
        end)..'"'
    end
    local function json(v)
        if type(v)=='string'then return quote(v)end
        if type(v)=='number'then return string.format('%.17g',v)end
        if type(v)=='boolean'then return if v then 'true'else 'false'end
        if v==nil then return 'null'end
        local parts={}
        if #v>0 then for _,item in v do table.insert(parts,json(item))end;return '['..table.concat(parts,',')..']'end
        local keys={};for key in v do table.insert(keys,key)end;table.sort(keys)
        for _,key in keys do table.insert(parts,quote(key)..':'..json(v[key]))end
        return '{'..table.concat(parts,',')..'}'
    end
    -- Review-only surface sampling. This is NOT serialized native Roblox Terrain.
    local surface={Step=32,OriginX=-config.WorldSize/2,OriginZ=-config.WorldSize/2,Rows={},WaterRows={}}
    for z=-config.WorldSize/2,config.WorldSize/2,32 do
        local row,waterRow={},{}
        for x=-config.WorldSize/2,config.WorldSize/2,32 do
            local h,water=terrain.column(config,x,z)
            table.insert(row,h);table.insert(waterRow,water or false)
        end
        table.insert(surface.Rows,row);table.insert(surface.WaterRows,waterRow)
    end
    print('ELDRAVYN_SCENE_JSON:'..json({Scene=node(scene),Lighting=node(game.Lighting),Report=report,TerrainPreview=surface,
        WorkspaceAttributes=workspace._attrs,StudioExecuted=false,TerrainBaked=false}))
end
