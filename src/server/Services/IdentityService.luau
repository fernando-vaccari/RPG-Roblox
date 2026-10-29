local Shared=game.ReplicatedStorage.MedievalRPG
local Config=require(Shared.Config.IdentityConfig)
local Rules=require(Shared.Core.IdentityRules)
local Stats=require(Shared.Core.CombatRules)
local Abilities=require(Shared.Config.AbilityConfig)
local Data=require(script.Parent.DataService)
local Purchase=require(script.Parent.PurchaseService)
local Security=require(script.Parent.AntiExploitService)
local Service={}
function Service.refresh(profile)
 local before=profile.Identity.Racial.Status
 Rules.refresh(profile,Config,os.time())
 return before~=profile.Identity.Racial.Status
end
function Service.event(profile,event)
 return Rules.event(profile,Config,event,os.time())
end
function Service.discover(profile,region)
 local found=false
 for id,secret in Config.Secrets do if secret.Region==region then found=Rules.discover(profile,Config,id) or found end end
 return found
end
function Service.action(player,action,value)
 local p=Data.get(player);if not Security.alive(player) then return false,'Personagem precisa estar vivo.' end
 if not p or p.Identity.Race=='' then return false,'Identidade requer persistência confirmada.' end
 if not Security.allow(player,'identityAction',1) then return false,'Aguarde antes de outra operação de identidade.' end
 local now=os.time()
 if action=='Purchase' then return Purchase.prompt(player,value) end
 return Data.changeIdentity(player,function(profile)
    local level=Stats.level(profile.XP,Abilities)
    if action=='RacialStart' then return Rules.startRacial(profile,Config,level,now)
    elseif action=='RacialClaim' then return Rules.claimRacial(profile,Config,now)
    elseif action=='ClassStart' then return Rules.startClass(profile,Config,value,level)
    elseif action=='ClassClaim' then return Rules.claimClass(profile,Config,value)
    elseif action=='ClassSelect' then return Rules.selectClass(profile,Config,value)
    elseif action=='FusionGold' then return Rules.buyFusion(profile,Config,value)
    elseif action=='Fuse' then return Rules.fuse(profile,Config,value,now) end
    return false,'Ação de identidade inválida.'
 end)
end

function Service.syncClass(profile)
 for _,id in {'Guerreiro','Espadachim','Mago','Arqueiro'} do if profile.Class==id then profile.Identity.Classes[id]=true end end
 profile.Identity.CurrentClass=profile.Class
end
function Service.fragments(profile,enemy,root)
 local cursor=root;local valid=false
 while cursor and cursor~=workspace do
  if cursor.Name=='GeneratedDungeon' and cursor:GetAttribute('ProjectId')=='ProjectMedievalRPG' then valid=true;break end
  cursor=cursor.Parent
 end
 if not valid then return end
 local amount=Config.DungeonFragments[enemy]
 if amount then profile.Identity.Fragments=math.min(1000000,profile.Identity.Fragments+amount) end
end
function Service.appearance(player)
 local p=Data.get(player);local char=player.Character;local race=p and Config.Races[p.Identity.Race]
 if not char or not race then return end
 local old=char:FindFirstChild('MedievalRaceAppearance');if old then old:Destroy() end
 local head=char:FindFirstChild('Head');if not head then return end
 local folder=Instance.new('Folder');folder.Name='MedievalRaceAppearance';folder.Parent=char
 local color=Color3.fromRGB(table.unpack(race.Color))
 local function piece(name,size,cf)
  local part=Instance.new('Part');part.Name=name;part.Size=size;part.CFrame=head.CFrame*cf;part.Color=color
  part.Material=Enum.Material.SmoothPlastic;part.Massless=true;part.CanCollide=false;part.CanTouch=false;part.CanQuery=false;part.Parent=folder
  local weld=Instance.new('WeldConstraint');weld.Part0=head;weld.Part1=part;weld.Parent=part
 end
 if race.Shape=='Ears' or race.Shape=='DarkEars' then
  for _,side in {-1,1} do piece('Ear',Vector3.new(0.7,0.3,0.35),CFrame.new(side*1.1,0,0)*CFrame.Angles(0,0,side*0.3)) end
 elseif race.Shape=='Horns' then
  for _,side in {-1,1} do piece('Horn',Vector3.new(0.25,1.1,0.25),CFrame.new(side*0.65,0.8,0)*CFrame.Angles(0,0,-side*0.3)) end
 elseif race.Shape=='Halo' then
  for i=1,8 do local a=i*math.pi/4;piece('Halo',Vector3.new(0.5,0.12,0.15),CFrame.new(math.sin(a)*0.8,1,math.cos(a)*0.8)*CFrame.Angles(0,a,0)) end
 else piece('Crest',Vector3.new(0.35,0.35,0.12),CFrame.new(0,0.3,-0.6)) end
 if p.Identity.Evolution~='' then piece('EvolvedSigil',Vector3.new(0.2,0.65,0.2),CFrame.new(0,1.5,0)) end
 char:SetAttribute('OriginalRace',p.Identity.Race);char:SetAttribute('RaceEvolution',p.Identity.Evolution)
end
return Service
