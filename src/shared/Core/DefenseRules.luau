-- All times come from the server. Holding guard does not renew the parry window.
local D={ParryWindow=0.24,ParryCooldown=0.65,BreakSeconds=1.4,MaxPosture=100}
function D.init(s)
 s.Posture=s.Posture or 0;s.BrokenUntil=s.BrokenUntil or 0
 s.ParryUntil=s.ParryUntil or 0;s.NextParry=s.NextParry or 0;s.LastPressure=s.LastPressure or -100
end
function D.block(s,now,on)
 D.init(s)
 if not on then s.Blocking=false;s.ParryUntil=0;return true end
 if s.Blocking or now<s.RecoverUntil or now<s.BrokenUntil or s.Stamina<10 then return false end
 s.Blocking=true;s.Sprinting=false
 if now>=s.NextParry then s.ParryUntil=now+D.ParryWindow;s.NextParry=now+D.ParryCooldown end
 return true
end
function D.step(s,now,dt)
 D.init(s)
 if now>=s.BrokenUntil and now-s.LastPressure>1 then s.Posture=math.max(0,s.Posture-math.clamp(dt,0,0.5)*(if s.Blocking then 8 else 24)) end
end
function D.resolve(s,now,amount,front,parryable)
 D.init(s)
 if now<s.DodgeUntil then return 0,'Dodge' end
 if s.Blocking and front and now>=s.BrokenUntil then
  if parryable and now<=s.ParryUntil and s.ParryUntil>0 then
   s.ParryUntil=0;s.Posture=math.max(0,s.Posture-30);s.Stamina=math.max(0,s.Stamina-3)
   return 0,'Parry'
  end
  local pressure=math.clamp(amount*1.8,15,60)
  s.Posture=math.min(D.MaxPosture,s.Posture+pressure);s.LastPressure=now
  s.Stamina=math.max(0,s.Stamina-10)
  if s.Posture>=D.MaxPosture or s.Stamina==0 then
   s.Blocking=false;s.Sprinting=false;s.ParryUntil=0;s.BrokenUntil=now+D.BreakSeconds
   s.RecoverUntil=math.max(s.RecoverUntil,s.BrokenUntil)
   return amount,'Break'
  end
  return amount*0.25,'Block'
 end
 return amount,'Hit'
end
function D.pressure(enemy,now,amount)
 enemy.Posture=math.min(100,(enemy.Posture or 0)+amount);enemy.LastPressure=now
 if enemy.Posture<100 then return false end
 enemy.Posture=0;enemy.StunnedUntil=now+(if enemy.Def and enemy.Def.Boss then 1.2 else 2)
 enemy.Pending=nil;enemy.Swing=nil;return true
end
function D.critical(ticket)
 assert(type(ticket)=='number' and ticket%1==0 and ticket>=1 and ticket<=100)
 return if ticket<=8 then 1.35 else 1 -- fixed 8%, independent of race/rarity
end
return D
