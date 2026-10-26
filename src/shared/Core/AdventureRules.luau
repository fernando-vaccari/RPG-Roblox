local A={}
function A.restore(profile,raw,config)
 raw=if type(raw)=='table' then raw else {}
 profile.Adventure={Version=config.Version,Tutorial={},DefenseClaims={}}
 for _,city in {'Valoria','Arkheim'} do
  local stamp=type(raw.DefenseClaims)=='table' and raw.DefenseClaims[city]
  if type(stamp)=='number' and stamp==stamp and stamp%1==0 and stamp>=0 and stamp<=1e12 then profile.Adventure.DefenseClaims[city]=stamp end
 end
 for _,step in config.Tutorial do
  if type(raw.Tutorial)=='table' and raw.Tutorial[step.Id]==true then profile.Adventure.Tutorial[step.Id]=true end
 end
 -- Existing characters retain their accomplishments; practice objectives remain available.
 if profile.StarterChosen then profile.Adventure.Tutorial.Weapon=true end
 if profile.Rank~='' then profile.Adventure.Tutorial.Guild=true end
 if profile.Quests.FirstSteps and profile.Quests.FirstSteps.Claimed then profile.Adventure.Tutorial.Quest=true end
end
function A.event(profile,config,event)
 if not profile.Adventure then A.restore(profile,nil,config) end
 for _,step in config.Tutorial do
  if step.Id==event and not profile.Adventure.Tutorial[event] then profile.Adventure.Tutorial[event]=true;return true end
 end
 return false
end
function A.current(profile,config)
 for i,step in config.Tutorial do if not profile.Adventure or not profile.Adventure.Tutorial[step.Id] then return step,i end end
 return nil,#config.Tutorial+1
end
return A
