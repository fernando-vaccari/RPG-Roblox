-- Single existing DataStore and session owner; no second economy/profile writer.
local Shared=game.ReplicatedStorage.EldravynNPC
local C=require(Shared.Registry)
local Legacy=require(game.ReplicatedStorage.MedievalRPG.Config.ContentConfig)
-- Register ownership-only catalogue extension in an older Studio copy, without rewriting its scripts.
Legacy.Items.TravelRelic=Legacy.Items.TravelRelic or {Name=C.Items.TravelRelic.Name,Price=250,Kind='Material',Rarity='Rare'}
local Data=require(script.Parent.DataService)
local Rules=require(Shared.Rules)
local Service={Persistent=Data.Persistent}
Service.get=Data.get;Service.load=Data.load;Service.remove=Data.remove;Service.start=Data.start
function Service.change(player,fn)
 return Data.transaction(player,function(s)
  local ok,message=fn(s)
  if ok then s.Revision+=1 end
  return ok,message
 end)
end
function Service.event(player,event,source)
 local current=Data.get(player);if not current then return false end
 -- Avoid a DataStore write when no objective, discovery or tutorial step changes.
 local Http=game:GetService('HttpService');local probe=Http:JSONDecode(Http:JSONEncode(current))
 if not Rules.event(probe,C,event,source) then return false end
 return Service.change(player,function(s)return Rules.event(s,C,event,source),'Progresso registrado.'end)
end
return Service
