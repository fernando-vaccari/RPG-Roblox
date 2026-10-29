local R={}
function R.level(xp,c)
 local level=1
 while level<c.MaxLevel and xp>=c.XPBase+(level-1)*c.XPGrowth do xp-=c.XPBase+(level-1)*c.XPGrowth;level+=1 end
 return level,xp,c.XPBase+(level-1)*c.XPGrowth
end
function R.canUse(class,skillClass,c)
 return class==skillClass or c.Classes[class]~=nil and c.Classes[class].Base==skillClass
end
function R.stats(profile,c)
 local level=R.level(profile.XP,c);local base=c.Classes[profile.Class] or {Health=100,Mana=80,Stamina=100,Damage=1,Defense=0,Speed=16}
 local race=c.RaceModifiers and profile.Identity and c.RaceModifiers[profile.Identity.Race] or {Health=0,Mana=0,Stamina=0}
 return {Level=level,Health=base.Health+race.Health+(level-1)*5+(if profile.Armor=='Armor' and (profile.Inventory.Armor or 0)>0 then 40 else 0),Mana=base.Mana+race.Mana+(level-1)*3,Stamina=base.Stamina+race.Stamina+(level-1),Damage=base.Damage*(1+(level-1)*0.025),Defense=base.Defense+math.floor((level-1)/4),Speed=base.Speed}
end
function R.new(stats)
 return {Mana=stats.Mana,Stamina=stats.Stamina,Posture=0,BrokenUntil=0,Cooldowns={},Combo=0,LastPrimary=-100,RecoverUntil=0,DodgeUntil=0,GuardUntil=0,Blocking=false,Sprinting=false}
end
function R.step(s,stats,dt)
 dt=math.clamp(dt,0,0.5)
 s.Mana=math.min(stats.Mana,s.Mana+dt*6)
 s.Stamina=math.clamp(s.Stamina+dt*(if s.Sprinting or s.Blocking then -8 else 16),0,stats.Stamina)
 if s.Stamina==0 then s.Sprinting=false;s.Blocking=false end
end
function R.reserve(s,id,now,mana,stamina,cooldown,recovery)
 if now<s.RecoverUntil or now<(s.Cooldowns[id] or 0) or s.Blocking or s.Mana<mana or s.Stamina<stamina then return false end
 s.Mana-=mana;s.Stamina-=stamina;s.Cooldowns[id]=now+cooldown;s.RecoverUntil=now+(recovery or 0.25);return true
end
function R.primary(s,now,delay)
 if not R.reserve(s,'Primary',now,0,6,delay,delay*0.8) then return nil end
 s.Combo=if now-s.LastPrimary>1.4 then 1 else s.Combo%4+1;s.LastPrimary=now
 return s.Combo,if s.Combo==4 then 1.65 else 1
end
function R.unlock(profile,id,config)
 local skill=config.Skills[id]
 if not skill or not R.canUse(profile.Class,skill.Class,config) or R.level(profile.XP,config)<skill.Level then return false,'Classe/nível insuficiente.' end
 if skill.Level<=1 then return false,'Habilidade inicial já disponível sem compra.' end
 profile.Unlocks=profile.Unlocks or {}
 if profile.Unlocks[id] then return false,'Habilidade já aprendida.' end
 if profile.Gold<skill.Price then return false,'Gold insuficiente.' end
 profile.Gold-=skill.Price;profile.Unlocks[id]=true;return true,'Habilidade aprendida.'
end
return R
