-- No physical Parts on server. Swept rays are authoritative; clients render only visuals.
local RunService=game:GetService('RunService')
local Math=require(game.ReplicatedStorage.MedievalRPG.Core.ActionMath)
local P={Active={},Count=0,ByOwner={},Serial=0,Effects=nil,Started=false}
function P.available(owner)return P.Count<64 and (P.ByOwner[owner] or 0)<4 end
function P.finish(id,shot)
 if not P.Active[id] then return end
 P.Active[id]=nil;P.Count-=1;P.ByOwner[shot.Owner]=math.max(0,(P.ByOwner[shot.Owner] or 1)-1)
 if P.Effects then P.Effects:FireAllClients({Kind='ProjectileEnd',Id=id,Position=shot.Position})end
end
function P.cancel(owner)
 for id,shot in P.Active do if shot.Owner==owner then P.finish(id,shot)end end
 P.ByOwner[owner]=nil
end
function P.launch(owner,origin,direction,speed,range,style,valid,impact)
 if not P.available(owner)then return false end
 if direction.Magnitude<0.99 or direction.Magnitude>1.01 then return false end
 P.Serial+=1;local id=P.Serial
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={owner.Character}
 local shot={Owner=owner,Position=origin,Direction=direction,Speed=speed,Remaining=range,Params=params,Valid=valid,Impact=impact}
 P.Active[id]=shot;P.Count+=1;P.ByOwner[owner]=(P.ByOwner[owner] or 0)+1
 if P.Effects then P.Effects:FireAllClients({Kind='Projectile',Id=id,Origin=origin,Direction=direction,Speed=speed,Range=range,Style=style})end
 return true
end
function P.step(dt)
 for id,s in P.Active do
  if not s.Valid()then P.finish(id,s);continue end
  local travel=Math.travel(s.Speed,s.Remaining,dt)
  local delta=s.Direction*travel
  local hit=workspace:Raycast(s.Position,delta,s.Params)
  if hit then
   s.Position=hit.Position;P.finish(id,s)
   local ok,err=xpcall(function()s.Impact(hit.Position,hit.Instance)end,debug.traceback)
   if not ok then warn(err)end
  else s.Position+=delta;s.Remaining-=travel;if s.Remaining<=0 then P.finish(id,s)end end
 end
end
function P.start(effects)
 P.Effects=effects;if P.Started then return end;P.Started=true
 RunService.Heartbeat:Connect(P.step)
end
return P
