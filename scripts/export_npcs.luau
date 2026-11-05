local C=require(game.ReplicatedStorage.EldravynNPC.NPCConfig)
local P=require(game.ReplicatedStorage.EldravynNPC.PlacementConfig)
local F=require(game.ServerStorage.NPCInstall.R15Factory)
local scene=Instance.new('Folder');scene.Name='EldravynNPCs';scene:SetAttribute('NPCInstallVersion',1);scene.Parent=workspace
local cities={}
for _,definition in C.Definitions do
 local folder=cities[definition.City]
 if not folder then folder=Instance.new('Folder');folder.Name=definition.City;folder.Parent=scene;cities[definition.City]=folder end
 local position=P.NPCs[definition.Id]
 F.create(folder,definition,C.Roles[definition.Role],CFrame.new(table.unpack(position.Position))*CFrame.Angles(0,position.Yaw,0))
end
local ids={};local nextId=0
local function assign(node)nextId+=1;ids[node]=nextId;for _,child in node:GetChildren()do assign(child)end end
assign(scene)
local function typed(v)
 local kind=type(v)
 if kind=='nil' or kind=='boolean' or kind=='string' then return v end
 if kind=='number' then assert(v==v and math.abs(v)<math.huge);return v end
 assert(kind=='table','Unsupported exported value')
 if v._class then return {Type='Ref',Value=assert(ids[v],'Reference outside NPC scene')}end
 if v.Position and type(v.R)=='table' then return {Type='CFrame',Value={v.Position.X,v.Position.Y,v.Position.Z,table.unpack(v.R)}}end
 if v.R and v.G and v.B then return {Type='Color3',Value={v.R,v.G,v.B}}end
 if type(v.X)=='table' and v.X.Scale then return {Type='UDim2',Value={v.X.Scale,v.X.Offset,v.Y.Scale,v.Y.Offset}}end
 if v.Scale then return {Type='UDim',Value={v.Scale,v.Offset}}end
 if v.X~=nil and v.Y~=nil then return {Type='Vector3',Value={v.X,v.Y,v.Z or 0}}end
 error('Unsupported NPC export data')
end
local function node(n)
 local properties,attributes,children={},{},{}
 for key,value in n._props do if key~='Parent' and key~='Position' and key~='AssemblyLinearVelocity' then properties[key]=typed(value)end end
 for key,value in n._attrs do attributes[key]=typed(value)end
 for _,child in n:GetChildren()do table.insert(children,node(child))end
 return {Id=ids[n],Class=n.ClassName,Properties=properties,Attributes=attributes,Children=children}
end
assert(env.VoxelWrites==0)
print('NPC_SCENE:'..json(node(scene)))
