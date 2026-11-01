return {
 Version=2,
 Attention={Distance=22,HalfField=80,HeadYaw=44,HeadPitch=20,TorsoYaw=11,Response=7,GreetingCooldown=14},
 Performance={ScanSeconds=0.5,FullDistance=48,ReducedDistance=100,DesktopFull=12,MobileFull=8,Reduced=8,DesktopHz=30,MobileHz=20,ReducedHz=6,Effects=3,Particles=0},
 Behavior={Tick=0.2,ActiveDistance=90,MaxMoving=4,PatrolRadius=3,Speed=1.6,Pause=5,WorkCycle=12},
 -- Empty IDs intentionally use authored procedural poses. Configure ONLY owned/authorized published assets.
 Animations={
  Idle={Id='',Priority='Idle',Looped=true},Walk={Id='',Priority='Movement',Looped=true},Run={Id='',Priority='Movement',Looped=true},
  Greet={Id='',Priority='Action2',Looped=false},Talk={Id='',Priority='Action2',Looped=true},
  Forge={Id='',Priority='Action',Looped=true},Inspect={Id='',Priority='Action',Looped=true},Organize={Id='',Priority='Action',Looped=true},
  Study={Id='',Priority='Action',Looped=true},Arcane={Id='',Priority='Action',Looped=true},Trade={Id='',Priority='Action',Looped=true},
  Documents={Id='',Priority='Action',Looped=true},Serve={Id='',Priority='Action',Looped=true},Orient={Id='',Priority='Action',Looped=true},Observe={Id='',Priority='Idle',Looped=true},
 },
 FadeSeconds=0.22,
}
