local R={}
local function int(n,lo,hi)return type(n)=='number' and n==n and n%1==0 and n>=lo and n<=hi end
function R.restore(profile,raw,c)
 raw=if type(raw)=='table' then raw else {}
 local out={Best={},Clears={},Ticket=nil}
 for id,d in c.Dungeons do
  local best=type(raw.Best)=='table' and raw.Best[id]
  out.Best[id]=if int(best,0,d.Floors) then best else 0
  out.Clears[id]=out.Best[id]==d.Floors and type(raw.Clears)=='table' and raw.Clears[id]==true
 end
 local t=raw.Ticket
 if type(t)=='table' and c.Dungeons[t.Dungeon] and type(t.Run)=='string' and #t.Run<=80 and #t.Run>0 and int(t.Expires,1,1e12) then
  local members={};local seen={}
  if type(t.Members)=='table' then for _,id in t.Members do
   if int(id,-1e15,1e15) and id~=0 and not seen[id] and #members<c.MaxPlayers then table.insert(members,id);seen[id]=true end
  end end
  if #members>0 then out.Ticket={Dungeon=t.Dungeon,Run=t.Run,Expires=t.Expires,Members=members} end
 end
 profile.Expedition=out;return out
end
function R.floor(c,id,n)
 local d=c.Dungeons[id];assert(d and int(n,1,d.Floors),'Andar inválido')
 local boss=n%5==0
 local layout=if boss then 'Arena' else c.Layouts[(n-1)%#c.Layouts+1]
 local enemies={}
 local roster=if id=='FallenSanctum' then {'Shadow','Demon','DarkWolf','Skeleton'} else {'Skeleton','Demon','DarkWolf','Shadow'}
 for i=1,if boss then 1 else 2+(if n>10 then 2 elseif n>5 then 1 else 0) do
  table.insert(enemies,if boss then (if n==d.Floors then d.FinalBoss else 'Knight') else roster[(n+i-2)%#roster+1])
 end
 return {Index=n,Name=d.Titles[n],Layout=layout,X=d.X,Y=(n-1)*96,Z=d.Z,Enemies=enemies,Boss=boss,Scale=1+(n-1)*0.07+(if id=='FallenSanctum' then 0.45 else 0)}
end
function R.newRun(c,id,members,nonce,now)
 assert(c.Dungeons[id] and #members>=1 and #members<=c.MaxPlayers)
 local allowed={};for _,uid in members do assert(int(uid,-1e15,1e15) and uid~=0 and not allowed[uid]);allowed[uid]=true end
 return {Id=id,Nonce=nonce,Floor=1,Members=allowed,Eliminated={},State='Fighting',Remaining=0,Killed={},Expires=now+c.RunSeconds}
end
function R.beginFloor(run,ids)
 run.Remaining=#ids;run.Killed={};run.Expected={}
 for _,id in ids do assert(not run.Expected[id]);run.Expected[id]=true end
 run.State=if #ids==0 then 'Cleared' else 'Fighting'
end
function R.kill(run,id)
 if run.State~='Fighting' or not run.Expected[id] or run.Killed[id] then return false end
 run.Killed[id]=true;run.Remaining-=1
 if run.Remaining==0 then run.State='Cleared' end
 return true
end
function R.advance(run,c)
 if run.State~='Cleared' then return false end
 if run.Floor==c.Dungeons[run.Id].Floors then run.State='Complete';return true end
 run.Floor+=1;run.State='Preparing';return true
end
function R.eliminate(run,uid)
 if not run.Members[uid] then return false end
 run.Eliminated[uid]=true
 for id in run.Members do if not run.Eliminated[id] then return false end end
 if run.State~='Complete' then run.State='Failed' end;return true
end
function R.reward(profile,c,id,floor)
 local d=c.Dungeons[id]
 if not d or not int(floor,1,d.Floors) then return false end
 local s=profile.Expedition
 if floor<=(s.Best[id] or 0) or floor~=(s.Best[id] or 0)+1 then return false end
 s.Best[id]=floor
 profile.Gold=math.min(1e9,profile.Gold+20+floor*5);profile.XP=math.min(1e9,profile.XP+30+floor*8)
 if floor==d.Floors then s.Clears[id]=true end
 return true
end
return R
