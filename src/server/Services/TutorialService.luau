local Shared=game.ReplicatedStorage.MedievalRPG
local Config=require(Shared.Config.AdventureConfig)
local Rules=require(Shared.Core.AdventureRules)
local Data=require(script.Parent.DataService)
local Security=require(script.Parent.AntiExploitService)
local T={Origins={},OnState=nil}
function T.event(player,event)
 local profile=Data.get(player)
 if profile and Rules.event(profile,Config,event) and T.OnState then T.OnState(player) end
end
function T.step(player)
 local root=Security.alive(player);local s=Data.get(player)
 if not root or not s then return end
 if not T.Origins[player] then T.Origins[player]=root.Position end
 if (root.Position-T.Origins[player]).Magnitude>=12 then T.event(player,'Move') end
 if s.StarterChosen then T.event(player,'Weapon') end
 if s.Rank~='' then T.event(player,'Guild') end
 if s.Quests.FirstSteps and s.Quests.FirstSteps.Claimed then T.event(player,'Quest') end
end
function T.clear(player)T.Origins[player]=nil end
return T
