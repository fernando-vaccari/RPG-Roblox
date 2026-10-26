-- One bounded defense event per server, only near an occupied city frontier.
local Players=game:GetService('Players')
local Shared=game.ReplicatedStorage.MedievalRPG
local World=require(Shared.Config.WorldConfig)
local Config=require(Shared.Config.AdventureConfig).DefenseEvent
local Data=require(script.Parent.DataService)
local Security=require(script.Parent.AntiExploitService)
local Progress=require(Shared.Core.Progression)
local Catalog=require(Shared.Config.ContentConfig)
local E={Current=nil,Next=0,Notice=nil,OnState=nil}
function E.step()
 local now=os.time();local event=E.Current
 if event then
  if now>=event.Expires then
   for _,m in event.Markers do m:SetAttribute('Enabled',false) end
   for _,p in Players:GetPlayers() do if E.Notice then E.Notice(p,'A defesa de '..event.City..' terminou. A próxima convocação chegará pelos sinos.') end end
   E.Current=nil
  end
  return
 end
 if now<E.Next then return end
 local map=workspace:FindFirstChild('GeneratedWorld')
 if not map or map:GetAttribute('Status')~='Complete' then return end
 local choice,markers
 for _,city in {'Valoria','Arkheim'} do
  local found={}
  for _,marker in map.EnemySpawns:GetChildren() do if marker:GetAttribute('DefenseCity')==city then table.insert(found,marker) end end
  if #found>0 then for _,p in Players:GetPlayers() do
   if Data.get(p) and Security.near(p,found[1],Config.Radius) then choice=city;markers=found;break end
  end end
  if choice then break end
 end
 if not choice then return end
 E.Next=now+Config.Interval
 E.Current={City=choice,Markers=markers,Remaining=#markers,Kills={},Contributors={},Expires=now+Config.Duration,Id=now}
 for _,m in markers do m:SetAttribute('Defeated',false);m:SetAttribute('Enabled',true) end
 for _,p in Players:GetPlayers() do if Security.near(p,markers[1],Config.Radius) and E.Notice then E.Notice(p,'Sinos de '..choice..': derrote cinco invasores junto ao estandarte em quatro minutos!') end end
end
function E.killed(enemy)
 local event=E.Current;local marker=enemy.Spawn and enemy.Spawn.Marker
 if not event or not marker or marker:GetAttribute('DefenseCity')~=event.City or not table.find(event.Markers,marker) or event.Kills[marker] then return end
 event.Kills[marker]=true;event.Remaining-=1
 for p,damage in enemy.Contributors do if damage>0 and Security.near(p,enemy.Root,Config.Radius) then event.Contributors[p]=true end end
 if event.Remaining~=0 then return end
 E.Current=nil -- settle exactly once, before yielding for persistence
 for _,m in event.Markers do m:SetAttribute('Enabled',false) end
 for p in event.Contributors do
  if Data.get(p) then
   local ok=Data.transaction(p,function(s)
    local claims=s.Adventure.DefenseClaims
    if (claims[event.City] or 0)>=event.Id then return false,'Defesa já recompensada.' end
    claims[event.City]=event.Id
    s.Gold=math.min(1e9,s.Gold+Config.Gold);s.XP=math.min(1e9,s.XP+Config.XP)
    Progress.event(s,Catalog,'Defense:'..event.City,1)
    return true,'Defesa concluída.'
   end)
   if E.Notice then E.Notice(p,if ok then 'Cidade defendida: +80 Gold e +100 XP. Consulte sua missão.' else 'A recompensa da defesa não foi confirmada; perfil indisponível.') end
   if E.OnState then E.OnState(p) end
  end
 end
end
return E
