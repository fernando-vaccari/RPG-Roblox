-- Extra test-only primitives. Does not simulate Roblox physics/rendering/network.
local Extra={}
function Extra.install(env)
 local CF,V=env.CFrame,env.Vector3
 local cm=getmetatable(CF.new());local old=cm.__index
 local function quaternion(r)
  local trace=r[1]+r[5]+r[9]
  if trace>0 then local s=math.sqrt(trace+1)*2;return {(r[8]-r[6])/s,(r[3]-r[7])/s,(r[4]-r[2])/s,s/4}
  elseif r[1]>r[5] and r[1]>r[9] then local s=math.sqrt(1+r[1]-r[5]-r[9])*2;return {s/4,(r[2]+r[4])/s,(r[3]+r[7])/s,(r[8]-r[6])/s}
  elseif r[5]>r[9] then local s=math.sqrt(1+r[5]-r[1]-r[9])*2;return {(r[2]+r[4])/s,s/4,(r[6]+r[8])/s,(r[3]-r[7])/s}
  else local s=math.sqrt(1+r[9]-r[1]-r[5])*2;return {(r[3]+r[7])/s,(r[6]+r[8])/s,s/4,(r[4]-r[2])/s}end
 end
 cm.__index=function(t,k)
  if k=='Inverse' then return function(a)
   local r=a.R;local n=CF.new(-a:PointToObjectSpace(V.new()));n.Position=a:PointToObjectSpace(V.new());n.R={r[1],r[4],r[7],r[2],r[5],r[8],r[3],r[6],r[9]};return n
  end end
  if k=='ToObjectSpace' then return function(a,b)return a:Inverse()*b end end
  if k=='Lerp' then return function(a,b,alpha)
   local x,y=quaternion(a.R),quaternion(b.R);local dot=0;for i=1,4 do dot+=x[i]*y[i]end
   if dot<0 then for i=1,4 do y[i]=-y[i]end;dot=-dot end
   local w1,w2=1-alpha,alpha
   if dot<.9995 then local theta=math.acos(math.clamp(dot,-1,1));w1=math.sin((1-alpha)*theta)/math.sin(theta);w2=math.sin(alpha*theta)/math.sin(theta)end
   local q,length={},0;for i=1,4 do q[i]=x[i]*w1+y[i]*w2;length+=q[i]^2 end;length=math.sqrt(length);for i=1,4 do q[i]/=length end
   local qx,qy,qz,qw=table.unpack(q);local n=CF.new(a.Position+(b.Position-a.Position)*alpha)
   n.R={1-2*(qy*qy+qz*qz),2*(qx*qy-qz*qw),2*(qx*qz+qy*qw),2*(qx*qy+qz*qw),1-2*(qx*qx+qz*qz),2*(qy*qz-qx*qw),2*(qx*qz-qy*qw),2*(qy*qz+qx*qw),1-2*(qx*qx+qy*qy)};return n
  end end
  return old(t,k)
 end
 local function signal()
  local s={Handlers={}}
  function s:Connect(fn)local connection={Connected=true};self.Handlers[connection]=fn;function connection:Disconnect()self.Connected=false end;return connection end
  function s:Fire(...)for c,fn in self.Handlers do if c.Connected then fn(...)end end end
  return s
 end
 local proto=getmetatable(env.game);local priorIndex,priorNew=proto.__index,proto.__newindex
 local methods={}
 local tracks={};env.AnimationLoads=0;env.ActiveTweens={};env.CreatedTweens=0
 function methods:GetAttributes()return table.clone(self._attrs)end
 function methods:GetState()return self._attrs.MockState or env.Enums.HumanoidStateType.Running end
 function methods:GetPlayingAnimationTracks()
  local result={};for _,t in tracks[self] or {} do if t.IsPlaying then table.insert(result,t)end end;return result
 end
 function methods:LoadAnimation(_)
  if env.AnimationFailure then error('mock animation load failure')end
  env.AnimationLoads+=1
  local track={IsPlaying=false,Length=2,Destroyed=false}
  function track:Play()self.IsPlaying=true end
  function track:Stop()self.IsPlaying=false end
  function track:Destroy()self:Stop();self.Destroyed=true end
  tracks[self]=tracks[self] or {};table.insert(tracks[self],track);return track
 end
 function methods:Create(object,_,props)
  env.CreatedTweens+=1;local tween={Object=object,Props=props,Cancelled=false,Destroyed=false}
  function tween:Play()env.ActiveTweens[self]=true end
  function tween:Cancel()self.Cancelled=true;env.ActiveTweens[self]=nil end
  function tween:Destroy()self.Destroyed=true;env.ActiveTweens[self]=nil end
  function tween:Advance(alpha)
   for key,value in self.Props do if key=='CFrame' then self.Object.CFrame=self.Object.CFrame:Lerp(value,alpha)else self.Object[key]=value end end
  end
  return tween
 end
 proto.__index=function(t,k)
  if methods[k] then return methods[k]end
  local result=priorIndex(t,k)
  if type(result)=='table' and result.Handlers and not result.V2 then
   result=signal();result.V2=true;t._props[k]=result
  end
  if result==nil and (k=='LocalTransparencyModifier' or k=='Transparency') and t:IsA('BasePart') then return 0 end
  if result==nil and k=='Transform' and t:IsA('Motor6D') then return CF.new()end
  if result==nil and k=='Shape' and t:IsA('Part') then return env.Enums.PartType.Block end
  return result
 end
 proto.__newindex=function(t,k,v)
  if env.FailMutation and env.FailMutation(t,k,v) then env.FailMutation=nil;error('Injected V2 migration failure')end
  priorNew(t,k,v)
 end
 env.OnClone=function(oldNode,newNode)if env.CopyLoader then env.CopyLoader(oldNode,newNode)end end
 return env
end
return Extra
