-- Only trusted server code can invoke this adapter; no RemoteEvent exposes it.
local Data=require(script.Parent.NPCDataService)
local C=require(game.ReplicatedStorage.EldravynNPC.Registry)
local R=require(game.ReplicatedStorage.EldravynNPC.Rules)
local Q={CombatEnabled=false}
function Q.combatEvent(player,event,eventId)
 if not Q.CombatEnabled or type(event)~='string' or event:sub(1,7)~='Combat:' or type(eventId)~='string' or #eventId<1 or #eventId>100 then return false end
 local known=false;for _,q in C.Quests do for _,o in q.Objectives do if o.Event==event then known=true end end end
 if not known then return false end
 return Data.change(player,function(s)
  local ledger=s.NPC.CombatEvents or {};if ledger[eventId] then return false end
  local count=0;for _ in ledger do count+=1 end;if count>=1024 then return false,'Adaptador exige rotação segura do histórico.'end
  if not R.event(s,C,event,'CombatAdapter') then return false end
  ledger[eventId]=true;s.NPC.CombatEvents=ledger;return true,'Evento de combate registrado.'
 end)
end
return Q
