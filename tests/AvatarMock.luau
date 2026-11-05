-- Test-only additions: content strings are synthetic, never real Roblox assets.
local M={}
function M.install(env)
 local priorType=env.typeof
 env.typeof=function(v)if type(v)=='table'and v._class then return'Instance'end;return priorType(v)end
 local CF=env.CFrame;local priorNew=CF.new
 CF.new=function(...)
  local v={...};local c=priorNew(v[1],v[2],v[3]);if #v==12 then c.R={table.unpack(v,4,12)}end;return c
 end
 local cm=getmetatable(CF.new());local ci=cm.__index
 cm.__index=function(t,k)if k=='GetComponents'then return function(a)return a.Position.X,a.Position.Y,a.Position.Z,table.unpack(a.R)end end;return ci(t,k)end
 local proto=getmetatable(env.game);local prior=proto.__index
 proto.__index=function(t,k)
  if k=='GetScale'then return function(a)return a:GetAttribute('MockScale')or 1 end end
  local value=prior(t,k)
  if value==nil and t:IsA('SurfaceAppearance')and(k=='ColorMap'or k=='MetalnessMap'or k=='RoughnessMap'or k=='NormalMap')then return''end
  if value==nil and t:IsA('MeshPart')and(k=='MeshId'or k=='TextureID')then return''end
  return value
 end
 local collection=env.Instance.new('Folder');collection.Name='CollectionService';collection.Parent=env.game
 local tags,added,removed={},{},{}
 local function signal()
  local s={Items={}};function s:Connect(fn)local c={Connected=true};self.Items[c]=fn;function c:Disconnect()self.Connected=false end;return c end
  function s:Fire(...)for c,fn in self.Items do if c.Connected then fn(...)end end end;return s
 end
 local methods={}
 function methods:AddTag(node,tag)tags[tag]=tags[tag]or{};tags[tag][node]=true;if added[tag]then added[tag]:Fire(node)end end
 function methods:RemoveTag(node,tag)if tags[tag]then tags[tag][node]=nil end;if removed[tag]then removed[tag]:Fire(node)end end
 function methods:GetTagged(tag)local out={};for node in tags[tag]or{}do if node.Parent then table.insert(out,node)end end;return out end
 function methods:GetInstanceAddedSignal(tag)added[tag]=added[tag]or signal();return added[tag]end
 function methods:GetInstanceRemovedSignal(tag)removed[tag]=removed[tag]or signal();return removed[tag]end
 local last=proto.__index;proto.__index=function(t,k)if t==collection and methods[k]then return methods[k]end;return last(t,k)end
 return env
end
return M
