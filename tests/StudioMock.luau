-- Simulador limitado para testes de construção/orquestração. NÃO é Roblox.
local Mock={}
function Mock.new(enums,classes)
    local env={Enums=enums,Classes=classes,OccupiedParts=false,TerrainOccupied=false,VoxelWrites=0}
    local V={};local vm={}
    function V.new(x,y,z) if type(x)=='table' then return V.new(x.X,x.Y,x.Z) end;return setmetatable({X=x or 0,Y=y or 0,Z=z or 0},vm) end
    vm.__add=function(a,b)return V.new(a.X+b.X,a.Y+b.Y,a.Z+b.Z)end
    vm.__sub=function(a,b)return V.new(a.X-b.X,a.Y-b.Y,a.Z-b.Z)end
    vm.__unm=function(a)return V.new(-a.X,-a.Y,-a.Z)end
    vm.__mul=function(a,b)if type(a)=='number'then return b*a end;return V.new(a.X*b,a.Y*b,a.Z*b)end
    vm.__div=function(a,b)return a*(1/b)end
    vm.__iter=function()error('attempt to iterate over a Vector3 value',2)end
    vm.__index=function(t,k)
        if k=='Magnitude' then return math.sqrt(t.X*t.X+t.Y*t.Y+t.Z*t.Z)end
        if k=='Unit' then return t/t.Magnitude end
        if k=='Dot' then return function(a,b)return a.X*b.X+a.Y*b.Y+a.Z*b.Z end end
    end
    env.Vector3=V
    env.typeof=function(value)if getmetatable(value)==vm then return 'Vector3'else return typeof(value)end end
    local CF={};local cm={}
    local function make(p,r)return setmetatable({Position=p,R=r},cm)end
    local function rotate(r,v)return V.new(r[1]*v.X+r[2]*v.Y+r[3]*v.Z,r[4]*v.X+r[5]*v.Y+r[6]*v.Z,r[7]*v.X+r[8]*v.Y+r[9]*v.Z)end
    function CF.new(x,y,z)return make(V.new(x,y,z),{1,0,0,0,1,0,0,0,1})end
    function CF.Angles(x,y,z)
        local sx,cx=math.sin(x),math.cos(x);local sy,cy=math.sin(y),math.cos(y);local sz,cz=math.sin(z),math.cos(z)
        return make(V.new(),{cy*cz,-cy*sz,sy,cx*sz+sx*sy*cz,cx*cz-sx*sy*sz,-sx*cy,sx*sz-cx*sy*cz,sx*cz+cx*sy*sz,cx*cy})
    end
    function CF.lookAt(a,b)
        local d=b-a
        local horizontal=math.sqrt(d.X*d.X+d.Z*d.Z)
        return CF.new(a)*CF.Angles(0,math.atan2(-d.X,-d.Z),0)*CF.Angles(math.atan2(d.Y,horizontal),0,0)
    end
    cm.__mul=function(a,b)
        local r={}
        for row=0,2 do for col=0,2 do local n=0;for k=0,2 do n+=a.R[row*3+k+1]*b.R[k*3+col+1]end;r[row*3+col+1]=n end end
        return make(a.Position+rotate(a.R,b.Position),r)
    end
    cm.__add=function(a,b)return make(a.Position+b,a.R)end
    cm.__index=function(t,k)
        if k=='PointToWorldSpace' then return function(a,p)return a.Position+rotate(a.R,p)end end
        if k=='PointToObjectSpace' then return function(a,p)local v=p-a.Position;local r=a.R;return V.new(r[1]*v.X+r[4]*v.Y+r[7]*v.Z,r[2]*v.X+r[5]*v.Y+r[8]*v.Z,r[3]*v.X+r[6]*v.Y+r[9]*v.Z)end end
        if k=='LookVector' then return rotate(t.R,V.new(0,0,-1))end
    end
    CF.identity=CF.new();env.CFrame=CF
    local methods={};local mt={}
    local function signal()
        local event={Handlers={}}
        function event:Connect(fn)table.insert(self.Handlers,fn);return {Disconnect=function()end}end
        function event:Fire(...)for _,fn in self.Handlers do fn(...)end end
        return event
    end
    local function isA(node,kind)
        local c=node._class
        while c do if c==kind then return true end;c=classes[c] and classes[c].Super end
        return false
    end
    mt.__index=function(t,k)
        if k=='ClassName' then return t._class end
        if methods[k]then return methods[k]end
        if t._props[k]~=nil then return t._props[k]end
        local class=classes[t._class]
        while class do
            if class.Events[k]then local s=signal();t._props[k]=s;return s end
            class=classes[class.Super]
        end
        for _,c in t._children do if c.Name==k then return c end end
        return nil
    end
    mt.__newindex=function(t,k,v)
        if k=='Parent' then
            local old=t._props.Parent
            if old then for i,c in old._children do if c==t then table.remove(old._children,i);break end end end
            t._props.Parent=v;if v then table.insert(v._children,t)end
        else
            local class=classes[t._class];local known=false
            while class do if class.Props[k]then known=true;break end;class=classes[class.Super]end
            assert(known,'Propriedade inexistente no API dump: '..t._class..'.'..k)
            t._props[k]=v
            if k=='CFrame' then t._props.Position=v.Position end
            if k=='Position' then t._props.CFrame=CF.new(v) end
        end
    end
    function methods:IsA(k)return isA(self,k)end
    function methods:SetAttribute(k,v)self._attrs[k]=v end
    function methods:GetAttribute(k)return self._attrs[k]end
    function methods:GetChildren()return table.clone(self._children)end
    function methods:GetDescendants()local out={};local function walk(n)for _,c in n._children do table.insert(out,c);walk(c)end end;walk(self);return out end
    function methods:FindFirstChild(n,recursive)for _,c in self._children do if c.Name==n then return c end end;if recursive then for _,c in self:GetDescendants()do if c.Name==n then return c end end end end
    function methods:WaitForChild(n)return assert(self:FindFirstChild(n),'Mock WaitForChild ausente: '..n)end
    function methods:FindFirstChildOfClass(n)for _,c in self._children do if c.ClassName==n then return c end end end
    function methods:FindFirstAncestorOfClass(n)local p=self.Parent;while p do if p:IsA(n)then return p end;p=p.Parent end end
    function methods:IsDescendantOf(p)local n=self.Parent;while n do if n==p then return true end;n=n.Parent end;return false end
    function methods:Destroy()for _,c in self:GetChildren()do c:Destroy()end;self.Parent=nil end
    function methods:SetNetworkOwner(_)assert(not self.Anchored,'SetNetworkOwner em Part ancorado')end
    function methods:GetService(n)return self:WaitForChild(n)end
    function methods:BindToClose(fn)env.OnClose=fn end
    function methods:IsRunning()return false end
    function methods:IsStudio()return env.Studio~=false end
    function methods:ReadVoxels(region,resolution)
        assert(resolution==4)
        env.VoxelReads=(env.VoxelReads or 0)+1
        if env.ReadVoxelsFixture then return env.ReadVoxelsFixture(region,resolution,env.VoxelReads) end
        -- Compact fixture for orchestration, not the full region allocation.
        -- BOTH arrays must include the API's Size Vector3 metadata.
        local size=V.new(1,1,1)
        return {Size=size,{{enums.Material.Air}}},{Size=size,{{if env.TerrainOccupied then 1 else 0}}}
    end
    function methods:WriteVoxels(_,resolution,materials,occupancy)
        assert(resolution==4);env.VoxelWrites+=1
        if env.CaptureVoxels then env.LastVoxels={Materials=materials,Occupancy=occupancy}end
        assert(#materials==#occupancy)
        for x,plane in materials do
            for y,row in plane do for z,material in row do
                assert(material~=nil and occupancy[x][y][z]>=0 and occupancy[x][y][z]<=1)
            end end
        end
    end
    function methods:GetPartBoundsInBox()return if env.OccupiedParts then {self} else {} end
    function methods:TakeDamage(amount)
        local before=self.Health;self.Health=math.max(0,self.Health-amount)
        self.HealthChanged:Fire(self.Health)
        if before>0 and self.Health==0 then self.Died:Fire() end
    end
    function methods:EquipTool(tool)tool.Parent=self.Parent end
    function methods:FireClient(player,payload)env.LastClient={Player=player,Data=payload} end
    function methods:FireAllClients(payload)env.LastEffect=payload end
    function methods:SetTeleportData(data)self._attrs.TeleportData=data end
    function methods:TeleportAsync(place,list,options)
        if env.TeleportFail then error('Teleport failure fixture') end
        env.LastTeleport={Place=place,Players=list,Options=options}
    end
    function methods:MoveTo(position)self._attrs.MoveTarget=position end
    function methods:Raycast(origin,direction)
        if env.SweepTarget then
            local delta=env.SweepTarget.Position-origin
            local distance=direction.Magnitude
            if distance==0 then return nil end
            local projected=delta:Dot(direction.Unit)
            if projected>=0 and projected<=distance and (delta-direction.Unit*projected).Magnitude<=1 then return {Position=origin+direction.Unit*projected,Instance=env.SweepTarget}end
            return nil
        end
        if env.RayMiss then return nil end
        if env.RayTarget then return {Position=env.RayTarget.Position,Instance=env.RayTarget} end
        return {Position=V.new(origin.X,env.Height(origin.X,origin.Z),origin.Z),Instance=self.Terrain}
    end
    function methods:PivotTo(cf)
        local origin=self.PrimaryPart and self.PrimaryPart.Position or V.new()
        local delta=cf.Position-origin
        for _,p in self:GetDescendants()do if p:IsA('BasePart')then p.Position+=delta end end
    end
    function methods:GetServerTimeNow()return os.time()end
    function methods:ScaleTo(_)end
    local guid=0
    function methods:GenerateGUID()guid+=1;return 'MockGuid'..guid end
    local function deep(t)if type(t)~='table'then return t end;local out={};for k,v in t do out[k]=deep(v)end;return out end
    function methods:JSONEncode(t)return deep(t)end
    function methods:JSONDecode(t)return deep(t)end
    env.Store={Records={},Fail=false,Updates=0}
    function env.Store:UpdateAsync(key,fn)
        if self.Fail then error('Falha de DataStore simulada')end
        local out=fn(deep(self.Records[key]));self.Updates+=1
        if self.Replay then
            local first=deep(out);out=fn(deep(self.Records[key]))
            if first and first.Data and first.Data.Identity then assert(first.Data.Identity.Race==out.Data.Identity.Race,'Sorteio mudou em retry UpdateAsync') end
        end
        if self.AfterCallback then local hook=self.AfterCallback;self.AfterCallback=nil;hook() end
        if out~=nil then self.Records[key]=deep(out)end
        if self.FailAfterCommit then self.FailAfterCommit=false;error('Resposta perdida após commit simulado') end
        return deep(out)
    end
    function methods:GetDataStore(_)return env.Store end
    function methods:GetPlayers()local out={};for _,p in self:GetChildren() do if p:IsA('Player') then table.insert(out,p) end end;return out end
    function methods:GetPlayerByUserId(id)
        for _,p in self:GetChildren() do if p:IsA('Player') and p.UserId==id then return p end end
    end
    env.ProductInfo={IsForSale=true,PriceInRobux=150};env.PromptCount=0
    function methods:GetProductInfoAsync()return env.ProductInfo end
    function methods:PromptProductPurchase()env.PromptCount+=1 end
    env.Instance={new=function(kind)
        assert(classes[kind]and not classes[kind].NotCreatable,'Instance.new inválido: '..kind)
        local n=setmetatable({_class=kind,_children={},_attrs={},_props={Name=kind}},mt)
        if isA(n,'BasePart')then n.Size=V.new(4,1,2);n.CFrame=CF.identity;n.Anchored=false;n.AssemblyLinearVelocity=V.new() end
        if kind=='SpawnLocation'then n.Enabled=true end
        return n
    end}
    local function engine(kind,name,parent)
        local t=setmetatable({_class=kind,_children={},_attrs={},_props={Name=name}},mt)
        t.Parent=parent;return t
    end
    env.game=engine('DataModel','game')
    for _,pair in {{'Workspace','Workspace'},{'ReplicatedStorage','ReplicatedStorage'},{'ServerStorage','ServerStorage'},{'ServerScriptService','ServerScriptService'},{'RunService','RunService'},{'HttpService','HttpService'},{'Players','Players'},{'DataStoreService','DataStoreService'},{'Lighting','Lighting'},{'TweenService','TweenService'},{'Debris','Debris'},{'MarketplaceService','MarketplaceService'},{'PathfindingService','PathfindingService'},{'UserInputService','UserInputService'},{'TeleportService','TeleportService'},{'ProximityPromptService','ProximityPromptService'}}do engine(pair[1],pair[2],env.game)end
    env.workspace=env.game.Workspace;engine('Terrain','Terrain',env.workspace)
    env.createPlayer=function(id)local p=engine('Player','Player'..id,env.game.Players);p.UserId=id;p.DisplayName='Player'..id;engine('PlayerGui','PlayerGui',p);engine('Backpack','Backpack',p);return p end
    env.Color3={fromRGB=function(r,g,b)return {R=r/255,G=g/255,B=b/255}end,new=function(r,g,b)return {R=r,G=g,B=b}end}
    env.Vector2={new=function(x,y)return V.new(x,y,0)end}
    local function dim(scale,offset)return {Scale=scale or 0,Offset=offset or 0} end
    local function dim2(xs,xo,ys,yo)return {X=dim(xs,xo),Y=dim(ys,yo)}end
    env.UDim2={fromScale=function(x,y)return dim2(x,0,y,0)end,fromOffset=function(x,y)return dim2(0,x,0,y)end,new=dim2}
    env.UDim={new=dim}
    env.TweenInfo={new=function(...)return {...}end}
    env.Region3={new=function(a,b)return {Min=a,Max=b,Size=b-a,ExpandToGrid=function(self)return self end}end}
    env.OverlapParams={new=function()return {}end};env.RaycastParams=env.OverlapParams
    env.task={wait=function()end,delay=function()end,spawn=function()end}
    function methods:FireServer(...)env.LastRequest={...}end
    function methods:Create(object,_,props)return {Play=function()for key,value in props do object[key]=value end end}end
    function methods:AddItem()end
    env.warn=function(message) print('MOCK WARN: '..tostring(message))end
    return env
end
return Mock
