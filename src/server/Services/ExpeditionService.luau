local Shared=game.ReplicatedStorage.MedievalRPG
local Config=require(Shared.Config.DungeonConfig)
local Rules=require(Shared.Core.DungeonRules)
local Data=require(script.Parent.DataService)
local Security=require(script.Parent.AntiExploitService)
local Enemies=require(script.Parent.EnemyService)
local Players=game:GetService('Players')
local X={Run=nil,Participants={},Map=nil,Notice=nil,OnState=nil,OnComplete=nil}
local function tell(p,text)if X.Notice then X.Notice(p,text) end end
function X.floorRoot(part)
 local node=part
 while node and node~=workspace do
  if node:GetAttribute('FloorIndex') and node:GetAttribute('DungeonId') then return node end
  node=node.Parent
 end
end
function X.floor()
 local run=X.Run;local ex=X.Map and X.Map:FindFirstChild('Expeditions')
 local tower=run and ex and ex:FindFirstChild(run.Id)
 return tower and tower:FindFirstChild('Floor'..run.Floor)
end
function X.member(p)
 local r=X.Run
 return r and r.Members[p.UserId] and X.Participants[p.UserId]==p and not r.Eliminated[p.UserId]
end
function X.allowed(p,scope)
 local floor=scope and X.floorRoot(scope)
 if not floor then return not X.member(p) end
 return X.member(p) and floor==X.floor() and (X.Run.State=='Fighting' or X.Run.State=='Cleared')
end
local function deactivate(floor)
 if not floor then return end
 floor:SetAttribute('Active',false)
 for _,m in floor.EnemySpawns:GetChildren() do m:SetAttribute('Enabled',false) end
 Enemies.clearScope(floor)
end
function X.sync()
 local r=X.Run;if not r then return end
 for _,p in X.Participants do
  p:SetAttribute('DungeonName',Config.Dungeons[r.Id].Name);p:SetAttribute('DungeonFloor',r.Floor)
  p:SetAttribute('DungeonFloors',Config.Dungeons[r.Id].Floors);p:SetAttribute('DungeonRemaining',r.Remaining)
  p:SetAttribute('DungeonState',r.State)
  if X.OnState then X.OnState(p) end
 end
end
function X.activate()
 local r=X.Run;local floor=assert(X.floor(),'Expedições ausentes: gere/atualize o segundo Place no editor')
 local expected={}
 for _,marker in floor.EnemySpawns:GetChildren() do
  marker:SetAttribute('Defeated',false);marker:SetAttribute('Enabled',true)
  table.insert(expected,marker:GetAttribute('EnemyId'))
 end
 for _,spawn in Enemies.Spawns do if spawn.Root==floor then spawn.Next=0 end end
 Rules.beginFloor(r,expected);floor:SetAttribute('Active',true);floor:SetAttribute('Cleared',false);floor:SetAttribute('BossDefeated',false)
 Enemies.scan(floor)
 local index=0
 for _,p in X.Participants do
  if X.member(p) and Security.alive(p) then
   p.Character:PivotTo(CFrame.new(floor:GetAttribute('SpawnPosition')+Vector3.new(index*4,0,0)))
   p:SetAttribute('InDungeon',true);index+=1
  end
 end
 X.sync()
end
function X.available(id,map)
 return Config.Dungeons[id]~=nil and map~=nil and map:FindFirstChild('Expeditions')~=nil
end
function X.begin(id,list,map,nonce)
 if X.Run and X.Run.State~='Complete' and X.Run.State~='Failed' then return false,'Já existe uma expedição neste servidor de teste.' end
 if not X.available(id,map) then return false,'Gere as expedições no Place da dungeon primeiro.' end
 local ids={};for _,p in list do table.insert(ids,p.UserId) end
 if #ids<1 or #ids>Config.MaxPlayers then return false,'Grupo inválido.' end
 deactivate(X.floor());X.Participants={};X.Map=map
 X.Run=Rules.newRun(Config,id,ids,nonce,os.time())
 for _,p in list do X.Participants[p.UserId]=p end
 X.activate();return true,'Expedição iniciada: '..Config.Dungeons[id].Name
end
function X.ticket(profile,id,nonce,now,members)
 if not Config.Dungeons[id] then return false,'Dungeon desconhecida.' end
 profile.Expedition.Ticket={Dungeon=id,Run=nonce,Expires=now+Config.TicketSeconds,Members=table.clone(members)}
 return true,'Entrada reservada.'
end
function X.admit(player,map)
 local profile=Data.get(player);local ticket=profile and profile.Expedition.Ticket
 if not ticket then return false,'Sem reserva de expedição. Entre pelo guardião do continente.' end
 if not X.available(ticket.Dungeon,map) or ticket.Expires<os.time() then return false,'Reserva expirada ou mapa ausente.' end
 local r=X.Run
 if not table.find(ticket.Members,player.UserId) then return false,'Reserva não pertence a este jogador.' end
 if r and (r.Nonce~=ticket.Run or r.Id~=ticket.Dungeon or r.State~='Gathering' or not r.Members[player.UserId]) then return false,'Grupo/entrada indisponível; retorne ao continente.' end
 local n=0;for _ in X.Participants do n+=1 end
 if n>=Config.MaxPlayers then return false,'Grupo completo.' end
 local accepted,msg=Data.transaction(player,function(s)
  if not s.Expedition.Ticket or s.Expedition.Ticket.Run~=ticket.Run then return false,'Reserva já consumida.' end
  s.Expedition.Ticket=nil;return true,'Entrada confirmada.'
 end)
 if not accepted then return false,msg end
 r=X.Run -- recheck after persistence yield; arrivals may interleave
 if not r then
  X.Map=map;X.Participants={}
  r=Rules.newRun(Config,ticket.Dungeon,ticket.Members,ticket.Run,os.time());X.Run=r
  r.State='Gathering';r.GatherUntil=os.time()+90
 end
 if r.Nonce~=ticket.Run or r.State~='Gathering' then return false,'Reserva não corresponde ao grupo que chegou.' end
 X.Participants[player.UserId]=player;player:SetAttribute('InDungeon',true)
 local all=true;for uid in r.Members do if not X.Participants[uid] or not Security.alive(X.Participants[uid]) then all=false end end
 if all then X.activate() else X.sync() end
 return true,if all then 'Grupo reunido. Primeiro andar iniciado.' else 'Aguardando o restante do grupo na recepção (até 90 segundos).'
end
function X.killed(enemy)
 local floor=enemy.Spawn and X.floorRoot(enemy.Spawn.Root)
 if not floor or floor~=X.floor() then return end
 if not Rules.kill(X.Run,enemy.Spawn.Marker:GetAttribute('EnemyId')) then return end
 if X.Run.State=='Cleared' then
  floor:SetAttribute('Cleared',true)
  for _,p in X.Participants do
   if X.member(p) and Security.alive(p) then tell(p,'Andar limpo. Reúna o grupo no portal para confirmar o progresso e avançar.') end
  end
 end
 X.sync()
end
function X.advance(player,portal)
 local r=X.Run;local floor=X.floorRoot(portal)
 if not X.member(player) or floor~=X.floor() or r.State~='Cleared' or not Security.near(player,portal,15) then return false,'Derrote todos os guardiões e alcance o portal do andar atual.' end
 -- Serialized before any DataStore yield; a second prompt cannot duplicate the settlement.
 local survivors={}
 for _,p in X.Participants do
  if X.member(p) then
   if not Security.near(p,portal,35) or not Data.get(p) then return false,'Todos os sobreviventes devem estar próximos do portal e com dados disponíveis.' end
   table.insert(survivors,p)
  end
 end
 if #survivors==0 then return false,'Sem sobreviventes.' end
 r.State='Saving';X.sync()
 for _,p in survivors do
  local ok=Data.transaction(p,function(s)
   Rules.reward(s,Config,r.Id,r.Floor)
   if r.Floor==Config.Dungeons[r.Id].Floors and X.OnComplete then X.OnComplete(s,r.Id) end
   return true,'Andar registrado.'
  end)
  if not ok then r.State='Cleared';X.sync();return false,'Progresso não confirmado para todo o grupo. Reconecte o perfil indisponível; não avance com dados incertos.' end
 end
 -- A death/leave during persistence may fail the run; never revive it implicitly.
 if r.State~='Saving' then X.sync();return false,'Expedição interrompida durante o salvamento.' end
 r.State='Cleared';Rules.advance(r,Config);deactivate(floor)
 if r.State=='Complete' then
  for _,p in survivors do tell(p,'Expedição concluída! Use o portal de retorno. Primeira conclusão salva.') end
  X.sync()
 else X.activate() end
 return true,'Progresso do andar confirmado.'
end
function X.canChest(player,model)
 local floor=X.floorRoot(model)
 return floor and X.member(player) and floor==X.floor() and floor:GetAttribute('Cleared')==true
end
function X.eliminate(player)
 local r=X.Run;if not r or not r.Members[player.UserId] then return end
 if Rules.eliminate(r,player.UserId) then deactivate(X.floor()) end
 tell(player,'Você caiu ou deixou a expedição. O melhor andar confirmado foi preservado; uma nova tentativa começa no primeiro andar.')
 X.sync()
end
function X.leave(player)
 X.eliminate(player);X.Participants[player.UserId]=nil
 for _,key in {'DungeonName','DungeonFloor','DungeonFloors','DungeonRemaining','DungeonState'} do player:SetAttribute(key,nil) end
end
function X.step()
 local r=X.Run;if not r or r.State=='Complete' or r.State=='Failed' then return end
 if r.State=='Gathering' and os.time()>=r.GatherUntil then
  r.State='Failed';X.sync()
  for _,p in X.Participants do tell(p,'O grupo não chegou completo. Use o retorno e forme uma nova expedição; nenhuma tentativa paga foi consumida.') end
  return
 end
 if os.time()>=r.Expires then r.State='Failed';deactivate(X.floor());X.sync();for _,p in X.Participants do tell(p,'O prazo da expedição terminou. Use o portal de retorno.') end end
 for _,p in X.Participants do if p.Parent~=Players then X.leave(p) end end
end
return X
