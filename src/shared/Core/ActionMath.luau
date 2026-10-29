-- Pure budgets used by the runtime, including large-frame protection.
local M={}
function M.travel(speed,remaining,dt)
 assert(type(speed)=='number' and speed>0 and speed<1000)
 assert(type(dt)=='number' and dt==dt)
 return math.min(math.max(0,remaining),speed*math.clamp(dt,0,0.1))
end
function M.boss(kind,phase,index)
 local names=if kind=='Malgorth' then {'Ruptura do Trono','Círculo da Condenação'} elseif kind=='SylvarinBoss' then {'Raízes do Juramento','Vigília do Bosque'} else {'Pulso Sombrio','Eco das Ruínas'}
 return {Name=names[index%2+1],Radius=if phase==2 then 24 else 14,Windup=if phase==2 then 1.4 else 1.2,InnerRadius=if index%2==0 then (if phase==2 then 9.6 else 5.6)else 0,Height=if index%2==0 then 4 else 10,Multiplier=if index%2==0 then 1.2 else 1.4,Cooldown=if phase==2 then 6 else 9}
end
function M.inArea(horizontal,vertical,pattern)
 return horizontal<=pattern.Radius and horizontal>=(pattern.InnerRadius or 0) and math.abs(vertical)<=(pattern.Height or 10)
end
return M
