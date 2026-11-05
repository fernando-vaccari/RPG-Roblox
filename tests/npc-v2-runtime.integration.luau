-- Deterministic runtime/control tests in the limited host, NOT Roblox physics.
local Upgrade=require(pkg.NPCVisualUpgrade)
assert(Upgrade.Apply().Updated==66)
local Config=require(game.ReplicatedStorage.EldravynNPCVisualV2.NPCVisualConfig)
local Appearance=require(game.ReplicatedStorage.EldravynNPCVisualV2.NPCAppearanceConfig)
local Motion=require(game.ReplicatedStorage.EldravynNPCVisualV2.NPCMotion)
local Policy=require(game.ReplicatedStorage.EldravynNPCVisualV2.NPCVisualPolicy)
local clients=game.StarterPlayer.StarterPlayerScripts.EldravynNPCClient
local Animation=require(clients.NPCAnimationController)
local Attention=require(clients.NPCAttentionController)
local Manager=require(clients.NPCPerformanceManager)
local server=game.ServerScriptService.EldravynNPC
local Behavior=require(server.NPCBehaviorController)
local Dialogue=require(server.DialogueService)
local function near(a,b,eps)assert(math.abs(a-b)<(eps or .00001),tostring(a)..' ~= '..tostring(b))end
local function count(t)local n=0;for _ in t do n+=1 end;return n end
local function character(player,pos)
 local c=Instance.new('Model');c.Name='TestCharacter';c.Parent=workspace
 local root=Instance.new('Part');root.Name='HumanoidRootPart';root.CFrame=CFrame.new(pos);root.Parent=c
 local hum=Instance.new('Humanoid');hum.Health=100;hum.Parent=c;player.Character=c;return root
end
local player1=env.createPlayer(8801);local player2=env.createPlayer(8802)
local npc=models.Valoria_GuildMaster;local position=npc.PrimaryPart.Position
local root1=character(player1,position+Vector3.new(0,0,-6));local root2=character(player2,position+Vector3.new(5,0,-8))
local passed=0
local function test(name,fn)fn();passed+=1;print('PASSOU V2 CONTROLE: '..name)end
test('15 poses finitas, distintas, curvas de locomoção e estados profissionais',function()
 local signatures={}
 for state,def in Config.Animations do
  assert(def.Id=='' and Enum.AnimationPriority[def.Priority])
  local signature=0
  for i=0,900 do for _,angles in Motion.pose(state,i/30,1,false)do
   for _,angle in angles do assert(angle==angle and math.abs(angle)<math.pi);signature+=angle end
  end end
  signatures[state]=signature
 end
 assert(signatures.Forge~=signatures.Study and signatures.Walk~=signatures.Run and signatures.Greet~=signatures.Idle)
 assert(Motion.pose('Forge',0,0).RightShoulder[1]>0 and Motion.pose('Walk',.25,0).RightKnee[1]<0)
 assert(Motion.work('Forge',0,0,12)=='Forge' and Motion.work('Forge',5,0,12)=='Inspect' and Motion.work('Forge',9,0,12)=='Organize')
 assert(Motion.work('Study',9,0,12)=='Arcane')
 assert(Motion.work('Trade',5,0,12)=='Organize' and Motion.work('Trade',9,0,12)=='Trade')
end)
test('atenção: distância, campo de visão, limites e prioridade do interlocutor',function()
 local cfg=Config.Attention
 local _,_,_,visible=Policy.attention(0,0,-23,false,cfg);assert(not visible)
 local _,_,_,behind=Policy.attention(0,0,6,false,cfg);assert(not behind)
 local yaw,pitch,torso,active=Policy.attention(10,10,2,true,cfg);assert(active)
 assert(math.abs(yaw)<=math.rad(cfg.HeadYaw) and math.abs(pitch)<=math.rad(cfg.HeadPitch) and math.abs(torso)<=math.rad(cfg.TorsoYaw))
 local a=Attention.new(npc);local people={{Id=8801,Position=position+Vector3.new(0,2.25,-5)},{Id=8802,Position=position+Vector3.new(4,2.25,-7)}}
 Attention.update(a,people,100,.03);assert(a.Target==8801 and a.Greeting)
 Attention.update(a,people,101,.03);assert(not a.Greeting)
 npc:SetAttribute('NPCV2Speaker',8802);Attention.update(a,people,102,.03);assert(a.Target==8802 and not a.Greeting and a.Yaw<0)
 npc:SetAttribute('NPCV2Speaker',nil);local initial=math.abs(a.Yaw)
 for i=1,60 do Attention.update(a,{},103+i/30,1/30)end
 assert(not a.Target and math.abs(a.Yaw)<initial/100)
 Attention.update(a,people,110,.03);assert(not a.Greeting)
 Attention.update(a,{},116,.03);Attention.update(a,people,117,.03);assert(a.Greeting)
end)
test('fallback procedural sem assets; transições, Humanoid e Animate respeitados',function()
 local a=Animation.new(npc);local n=env.AnimationLoads
 a:update('Forge',100,.1,0,nil,false);assert(a.Owns and a.Joints.RightElbow.Transform~=CFrame.new())
 local first=a.Joints.RightElbow.Transform;a:update('Talk',100.1,.01,0,nil,false)
 assert(a.State=='Talk' and a.Joints.RightElbow.Transform~=first and env.AnimationLoads==n)
 a.Humanoid.Health=0;a:update('Talk',101,.1,0,nil,false);assert(not a.Owns)
 near(a.Joints.Neck.Transform.R[1],1);a.Humanoid.Health=100
 for _,state in {Enum.HumanoidStateType.Seated,Enum.HumanoidStateType.Ragdoll,Enum.HumanoidStateType.FallingDown}do
  a.Humanoid:SetAttribute('MockState',state);a:update('Idle',102,.1,0,nil,false);assert(not a.Owns)
 end
 a.Humanoid:SetAttribute('MockState',nil)
 local external=Instance.new('LocalScript');external.Name='Animate';external.Disabled=false;external.Parent=npc
 a:update('Idle',104,.1,0,nil,false);assert(a.External and not a.Owns);external:Destroy()
 a:update('Idle',106,.1,0,nil,false);assert(a.Owns);a:destroy();a:destroy();assert(a.Released)
end)
test('AnimationTracks: cache, prioridade, transição e atenção sem acumular',function()
 assert(not Policy.clipId('123') and not Policy.clipId('rbxassetid://0') and not Policy.clipId('https://example.com'))
 -- IDs synthetic ONLY inside a fake Animator; never contact Roblox or ship them.
 Config.Animations.Idle.Id='rbxassetid://990001';Config.Animations.Talk.Id='rbxassetid://990002'
 local a=Animation.new(npc);local loads=env.AnimationLoads;local attention={Yaw=.25,Pitch=.1,Torso=.05}
 for i=1,300 do
  a:beforeAnimation();a:update('Idle',110+i/30,1/30,0,attention,false)
  a:beforeAnimation();a:afterAnimation();near(a.Joints.Neck.Transform.R[1],math.cos(.25))
 end
 assert(env.AnimationLoads==loads+1 and a.Current.Priority==Enum.AnimationPriority.Idle)
 near(a.Joints.Neck.Transform.R[1],math.cos(.25));local idle=a.Current
 a:update('Talk',121,.1,0,attention,false);assert(not idle.IsPlaying and a.Current.IsPlaying and env.AnimationLoads==loads+2)
 a:update('Idle',122,.1,0,attention,false);assert(a.Current==idle and env.AnimationLoads==loads+2)
 a:destroy();assert(idle.Destroyed and count(a.Tracks)==0)
 Config.Animations.Idle.Id='';Config.Animations.Talk.Id=''
end)
test('falha de asset cai em pose procedural e não repete LoadAnimation a cada frame',function()
 Config.Animations.Forge.Id='rbxassetid://990003';env.AnimationFailure=true
 local a=Animation.new(npc);for i=1,60 do a:update('Forge',130+i/30,1/30,0,nil,false)end
 assert(a.Failed.Forge and a.Owns and #a.Assets==1)
 env.AnimationFailure=false;Config.Animations.Forge.Id='';a:destroy()
 local other=Animation.new(npc);local foreign=other.Animator:LoadAnimation(Instance.new('Animation'));foreign:Play()
 other:update('Idle',140,.1,0,nil,false);assert(other.External and not other.Owns);foreign:Destroy();other:destroy()
end)
test('adaptador mantém posição e bloqueia patrulha quando piso é incompatível',function()
 local adapter=require(server.NPCPositionAdapter);local placement=require(server.Placement)
 env.Height=function()return 0 end;local before=npc.PrimaryPart.CFrame
 assert(adapter.frame(npc,world,nil,npcs,placement) and npc:GetAttribute('NPCV2PatrolFloorValid'))
 env.Height=function()return 20 end
 assert(adapter.frame(npc,world,nil,npcs,placement) and npc:GetAttribute('NPCV2PatrolFloorValid')==false)
 assert(npc.PrimaryPart.CFrame==before);env.Height=function()return 0 end;npc:SetAttribute('NPCV2PatrolFloorValid',nil)
end)
local behavior=Behavior.start(models,npcs)
local guard
for _,entry in behavior.Entries do if entry.Style.Patrol then guard=entry;break end end
assert(guard)
test('um scheduler; patrulha limitada e cancelamento imediato por sessão real de diálogo',function()
 assert(Behavior.start(models,npcs)==behavior)
 root1.CFrame=guard.Home*CFrame.new(0,0,-6);root2.CFrame=guard.Home*CFrame.new(4,0,-8)
 assert(behavior:move(guard,guard.Home*CFrame.new(2.5,0,0),200))
 local tween=guard.Tween;tween:Advance(.4);assert(guard.Moving)
 Dialogue.Sessions[player2]={NPC=guard.NPC,Expires=os.clock()+100,Busy=false}
 guard.NPC:FindFirstChild('NPCInteraction',true).Triggered:Fire(player2)
 assert(tween.Cancelled and tween.Destroyed and not guard.Moving and guard.State=='Talk' and guard.Speaker==8802)
 Dialogue.Sessions[player1]={NPC=guard.NPC,Expires=os.clock()+100,Busy=false}
 behavior:interaction(guard,os.clock());assert(guard.Speaker==8802,'interlocutor estável')
 Dialogue.Sessions[player2]=nil;behavior:interaction(guard,os.clock());assert(guard.Speaker==8801)
 Dialogue.Sessions[player1]=nil;behavior:interaction(guard,201);assert(guard.State=='Idle' and guard.ReturnPending)
 guard.NextMove=0;behavior:step(202);assert(guard.Moving and guard.Target==guard.Home)
 guard.Tween:Advance(1);behavior:step(guard.EndAt+1);assert(not guard.Moving);near((guard.Root.Position-guard.Home.Position).Magnitude,0)
end)
test('obstáculo novo, ausência de piso, distância e morte cancelam deslocamento',function()
 assert(behavior:move(guard,guard.Home*CFrame.new(2.5,0,0),220));local tween=guard.Tween
 local wall=Instance.new('Part');wall.CanCollide=true;env.BoxParts={wall}
 behavior:step(220.1);assert(tween.Cancelled and not guard.Moving and guard.State=='Observe')
 assert(not behavior:move(guard,guard.Home*CFrame.new(2.5,0,0),221));env.BoxParts=nil
 env.Height=function()return -20 end;assert(not behavior:move(guard,guard.Home*CFrame.new(2.5,0,0),222));env.Height=function()return 0 end
 assert(not behavior:move(guard,guard.Home*CFrame.new(4,0,0),223))
 assert(behavior:move(guard,guard.Home*CFrame.new(2.5,0,0),224));guard.Humanoid.Health=0;behavior:step(224.1);assert(not guard.Moving);guard.Humanoid.Health=100
 assert(behavior:move(guard,guard.Home*CFrame.new(2.5,0,0),225));root1.CFrame=CFrame.new(10000,0,0);root2.CFrame=root1.CFrame
 behavior:step(225.1);assert(not guard.Moving)
end)
test('trabalho interrompido no diálogo e retomado sem alterar serviços',function()
 local smith;for _,e in behavior.Entries do if e.NPC:GetAttribute('NPCRole')=='Blacksmith' then smith=e;break end end
 root1.CFrame=smith.Home*CFrame.new(0,0,-5);behavior:step(230);assert(smith.State=='Work')
 Dialogue.Sessions[player1]={NPC=smith.NPC,Expires=240,Busy=false};behavior:step(231);assert(smith.State=='Talk' and smith.Speaker==8801)
 Dialogue.Sessions[player1]=nil;behavior:step(232);assert(smith.State=='Work' and not smith.Speaker)
end)
test('limite global de quatro patrulhas e limpeza completa do servidor',function()
 local old=Config.Behavior.ActiveDistance;Config.Behavior.ActiveDistance=10000
 for _,e in behavior.Entries do e.NextMove=0 end
 behavior:step(250);local moving=0;for _,e in behavior.Entries do if e.Moving then moving+=1 end end
 assert(moving<=4 and moving>0);Config.Behavior.ActiveDistance=old
 local connections=table.clone(behavior.Connections);behavior:destroy();behavior:destroy()
 for _,c in connections do assert(not c.Connected)end
 assert(count(env.ActiveTweens)==0 and not Behavior.Current)
end)
test('120 NPCs simulados: limites desktop/mobile, distância, efeitos e limpeza',function()
 local crowd=Instance.new('Folder');crowd.Name='IsolatedTestCrowd';crowd.Parent=workspace
 for i=1,120 do
  local clone=models.Valoria_Magic:Clone();clone.Name='TestCrowd'..i;clone:SetAttribute('EldravynNPCId',clone.Name)
  clone.PrimaryPart.CFrame=CFrame.new((i%12)*2,3,math.floor(i/12)*2);clone:SetAttribute('NPCV2State','Work');clone.Parent=crowd
 end
 root1.CFrame=CFrame.new(0,3,-3);root2.CFrame=root1.CFrame*CFrame.new(3,0,0)
 local function check(manager,cap)
  assert(count(manager.Entries)==120);local full,reduced=0,0
  for _,tier in manager.Selected do if tier=='Full' then full+=1 else reduced+=1 end end
  assert(full==cap and reduced==8 and count(manager.EffectSelection)<=3)
  for i=1,300 do manager:step(1/60,300+i/60)end
  assert(count(manager.EffectSelection)<=3)
 end
 local manager=Manager.start(crowd,player1,false);assert(Manager.start(crowd,player1,false)==manager);check(manager,12)
 local distant=crowd.TestCrowd120;distant:SetAttribute('NPCV2Speaker',player1.UserId);manager:scan(310)
 assert(manager.Selected[distant]=='Full','interação ativa tem prioridade entre os próximos')
 local cached=manager.Entries[distant];crowd.DescendantRemoving:Fire(distant);distant.Parent=nil
 assert(not manager.Entries[distant] and cached.Animation.Released)
 distant.Parent=crowd;crowd.DescendantAdded:Fire(distant);assert(manager.Entries[distant])
 local connections=table.clone(manager.Connections);manager:destroy()
 for _,c in connections do assert(not c.Connected)end
 local mobile=Manager.start(crowd,player1,true);check(mobile,8)
 root1.CFrame=CFrame.new(10000,3,0);mobile:scan(320);assert(count(mobile.Selected)==0 and count(mobile.EffectSelection)==0)
 mobile:destroy();assert(not Manager.Current);crowd:Destroy()
end)
test('bootstrap V1 adaptado preserva posições e usa diálogos/prompts originais',function()
 env.Height=function()return 0 end
 local before={};for _,model in models do before[model]=model.PrimaryPart.Position end
 local service=require(server.NPCService);service.start();assert(service.Started and Behavior.Current)
 for model,pos in before do near((model.PrimaryPart.Position-pos).Magnitude,0)end
 local countBefore=#server:GetChildren();local current=Behavior.Current;service.start();assert(Behavior.Current==current and #server:GetChildren()==countBefore)
 assert(require(server.NPCDataService).load(player1))
 local smith=models.Valoria_Blacksmith;root1.CFrame=smith.PrimaryPart.CFrame*CFrame.new(0,0,-5)
 env.RayMiss=true;Dialogue.Limits[player1]=nil;smith:FindFirstChild('NPCInteraction',true).Triggered:Fire(player1)
 assert(Dialogue.Sessions[player1] and Dialogue.Sessions[player1].NPC==smith)
 current:step(os.clock());assert(smith:GetAttribute('NPCV2State')=='Talk' and smith:GetAttribute('NPCV2Speaker')==player1.UserId)
 Dialogue.close(player1);current:step(os.clock());assert(smith:GetAttribute('NPCV2State')=='Work')
 env.RayMiss=false;current:destroy()
end)
assert(env.VoxelWrites==0 and sentinel.Parent==world)
print('PASSOU V2 CONTROLE TOTAL: '..passed..' (host simulado; sem física, rede, FPS ou renderização Roblox)')
