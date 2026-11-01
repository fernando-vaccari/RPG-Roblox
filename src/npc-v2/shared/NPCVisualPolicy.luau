local P={}
function P.clipId(id)return type(id)=='string' and id:match('^rbxassetid://[1-9]%d*$')~=nil end
function P.attention(x,y,z,active,c)
 local distance=math.sqrt(x*x+y*y+z*z)
 if distance>c.Distance or distance<.01 then return 0,0,0,false end
 local yaw=math.atan2(-x,-z);local pitch=math.atan2(y,math.sqrt(x*x+z*z))
 if not active and math.abs(yaw)>math.rad(c.HalfField) then return 0,0,0,false end
 return math.clamp(yaw, -math.rad(c.HeadYaw), math.rad(c.HeadYaw)),math.clamp(pitch,-math.rad(c.HeadPitch),math.rad(c.HeadPitch)),math.clamp(yaw*.22,-math.rad(c.TorsoYaw),math.rad(c.TorsoYaw)),true
end
function P.select(candidates,mobile,config)
 table.sort(candidates,function(a,b)if a.Active~=b.Active then return a.Active end;if a.Distance~=b.Distance then return a.Distance<b.Distance end;return a.Id<b.Id end)
 local result={};local full,reduced=0,0;local cap=if mobile then config.MobileFull else config.DesktopFull
 for _,entry in candidates do
  if entry.Distance<=config.FullDistance and full<cap then result[entry.Key]='Full';full+=1
  elseif entry.Distance<=config.ReducedDistance and reduced<config.Reduced then result[entry.Key]='Reduced';reduced+=1 end
 end
 return result
end
return P
