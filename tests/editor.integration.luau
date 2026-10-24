-- Executado pelo bundler scripts/integration.py. Host simulado, sem física.
local config=require(game.ReplicatedStorage.MedievalRPG.Config.WorldConfig)
local mathTerrain=require(game.ServerStorage.MedievalWorldgen.TerrainMath)
env.Height=function(x,z)return mathTerrain.height(config,x,z)end
local terrain=require(game.ServerStorage.MedievalWorldgen.TerrainGenerator)
terrain.writeChunk(workspace.Terrain,config,{X=0,Z=0,Width=32,Depth=32})
assert(env.VoxelWrites==1)
print('PASSOU MOCK: adaptador real WriteVoxels constrói matrizes válidas para um chunk 32x32.')
local originalWriter=terrain.writeChunk
-- A orquestração inteira não repete 56 milhões de voxels no mock.
terrain.writeChunk=function()env.VoxelWrites+=1 end
local world=require(game.ServerStorage.MedievalWorldgen.WorldGenerator)
env.OccupiedParts=true
assert(not pcall(world.GenerateNewWorld));assert(not workspace:FindFirstChild('GeneratedWorld'))
env.OccupiedParts=false;env.TerrainOccupied=true
assert(not pcall(world.GenerateNewWorld));assert(not workspace:FindFirstChild('GeneratedWorld'))
env.TerrainOccupied=false
local report=world.GenerateNewWorld()
assert(report.TerrainWritten and report.ChunksWritten==1024)
local root=workspace.GeneratedWorld
assert(root:GetAttribute('Status')=='Complete')
assert(#root.Cities:GetChildren()==4 and #root.NPCs:GetChildren()>=60)
for _,check in report.Checks do assert(check.Status~='FALHOU',check.Name) end
assert(not pcall(world.GenerateNewWorld));assert(workspace.GeneratedWorld==root)
local parts,npcs=0,0
for _,n in root:GetDescendants()do if n:IsA('BasePart')then parts+=1 end;if n:GetAttribute('NpcId')then npcs+=1 end end
print('PASSOU MOCK: continente/orquestração, recusas de ocupação e segunda geração; '..parts..' Parts e '..npcs..' NPCs.')
local npcCount=#root.NPCs:GetChildren()
world.RegenerateCity('Valoria')
assert(#root.Cities:GetChildren()==4 and #root.NPCs:GetChildren()==npcCount)
world.RegenerateForest('Sylvarin')
assert(#root.Forests:GetChildren()==2 and #root.EnemySpawns:GetChildren()==14 and #root.TreasureChests:GetChildren()==10)
world.RegenerateDecorations();world.RegenerateNPCMarkers()
assert(#root.NPCSpawns:GetChildren()==npcCount)
assert(not pcall(world.RegenerateGeneratedWorld))
assert(#game.ServerStorage.MedievalBackups:GetChildren()==4)
print('PASSOU MOCK: regenerações seletivas mantêm contagens e arquivam conteúdo anterior; Terrain não alterado.')
local dungeon=world.GenerateDungeon({Origin=Vector3.new(6000,30,0),StudioTest=true})
assert(#dungeon.Rooms:GetChildren()==14 and #dungeon.EnemySpawns:GetChildren()==6)
assert(dungeon:FindFirstChild('ReturnPortal') and #dungeon.TreasureChests:GetChildren()==2)
assert(not pcall(function()world.GenerateDungeon({Origin=Vector3.new(6000,30,0),StudioTest=true})end))
print('PASSOU MOCK: dungeon conectada, inimigos, recompensa e portal. Engine/teleporte real NÃO TESTADOS.')

-- Controllers reais constroem os painéis usando sinais/GUI simulados.
local uiPlayer=env.createPlayer(100);game.Players.LocalPlayer=uiPlayer
local Rig=require(game.ReplicatedStorage.MedievalRPG.RigFactory)
local char=Rig.create(workspace,'TestCharacter',Vector3.new(0,44,1000),Color3.fromRGB(90,100,110),false,'Citizen');uiPlayer.Character=char
local remote=Instance.new('RemoteEvent');local effects=Instance.new('RemoteEvent')
local ui=require(game.ReplicatedStorage.TestControllers.UIController).start(remote)
local rules=require(game.ReplicatedStorage.MedievalRPG.Core.Progression)
local catalog=require(game.ReplicatedStorage.MedievalRPG.Config.ContentConfig)
local state=rules.new();rules.register(state);rules.choose(state,catalog,'Staff')
ui.update({State=state,Party={}})
for role,dialogue in catalog.Dialogue do
    ui.dialogue({Role=role,City='Valoria',Party={},Name=dialogue.Name,Text=dialogue.Text})
    assert(ui.Panel.Visible and #ui.List:GetChildren()>1)
end
ui.dialogue({Role='Dungeon',City='Malgorth',Name='Guardião',Text='Grupo',Party={Leader=100,Members={{Id=100,Name='Teste',Confirmed=true}},State='Forming'}})
ui.quests();ui.inventory()
require(game.ReplicatedStorage.TestControllers.WorldController).start(ui,effects)
-- Fake TweenInfo is supplied by the host. No rendering/physics assertion.
game.RunService.Heartbeat:Fire()
print('PASSOU MOCK: diálogos de todos os papéis, lojas/grupos, inventário/diário e HUD/minimapa constroem sem propriedades inválidas.')
-- Falha parcial não remove Terrain/lock e exige recuperação explícita.
root:Destroy();dungeon:Destroy()
terrain.writeChunk=function()error('Falha de escrita simulada')end
assert(not pcall(world.GenerateNewWorld))
assert(workspace.GeneratedWorld:GetAttribute('Status')=='FailedPartialTerrain')
terrain.writeChunk=originalWriter
print('PASSOU MOCK: falha parcial preserva diagnóstico e impede reexecução destrutiva.')

-- Exercita o DataService real com UpdateAsync/locks e falhas simulados.
local configNode=game.ReplicatedStorage.MedievalRPG.Config.WorldConfig
local persistent=table.clone(config);persistent.EnableDataStore=true;cache[configNode]=persistent
local data=require(game.ServerScriptService.MedievalServer.Services.DataService)
local function player(id)return env.createPlayer(id)end
local p=player(1)
assert(data.load(p));assert(data.get(p).Gold==100)
data.get(p).Gold=222;assert(data.save(p,false));assert(env.Store.Records.Player_1.Data.Gold==222)
local other=player(1);assert(not data.load(other));assert(not data.get(other))
assert(data.save(p,true));assert(data.load(other));assert(data.get(other).Gold==222)
env.Store.Fail=true
assert(not data.save(other,false));assert(not data.get(other))
local third=player(3);local before=env.Store.Updates
assert(not data.load(third));assert(not data.get(third));assert(env.Store.Updates==before)
env.Store.Fail=false
assert(data.load(other,data.Sessions[other].Token));assert(data.get(other).Gold==222)
print('PASSOU MOCK: DataService real salva, impede sessão duplicada, congela em falha e não sobrescreve defaults após load falho.')

-- Identity and receipt paths use the REAL DataService/PurchaseService, simulated platform only.
local identityConfig=require(game.ReplicatedStorage.MedievalRPG.Config.IdentityConfig)
local identity=require(game.ReplicatedStorage.MedievalRPG.Core.IdentityRules)
local purchase=require(game.ServerScriptService.MedievalServer.Services.PurchaseService)
purchase.start()
assert(game.MarketplaceService.ProcessReceipt==purchase.process)
assert(not purchase.available('RacialRetry') and not purchase.available('BasicPack'))
local paid=player(42)
env.Store.Replay=true
assert(data.load(paid))
local original=data.get(paid).Identity.Race;assert(identityConfig.Races[original])
assert(data.save(paid,true));assert(data.load(paid));assert(data.get(paid).Identity.Race==original)
print('PASSOU MOCK: sorteio persistido uma vez, inclusive retry de callback e reconexão.')
-- Fixture product IDs are test-local; actual source configuration keeps every ID=0.
identityConfig.Products.RacialRetry.Id=101
identityConfig.Products.BasicPack.Id=102
identityConfig.Products.PremiumPack.Id=103
local profile=data.get(paid);profile.Identity.Racial={Status='Failed',Counts={},ReadyAt=os.time()+86400,Deadline=0}
assert(data.save(paid,false))
env.ProductInfo.PriceInRobux=149;assert(not purchase.prompt(paid,'RacialRetry'));assert(env.PromptCount==0)
env.ProductInfo.PriceInRobux=150;assert(purchase.prompt(paid,'RacialRetry'));assert(env.PromptCount==1)
assert(not purchase.prompt(paid,'BasicPack'));assert(env.PromptCount==1)
local receipt={PlayerId=42,ProductId=101,PurchaseId='fixture-official-receipt'}
env.Store.FailAfterCommit=true
assert(purchase.process(receipt)==Enum.ProductPurchaseDecision.NotProcessedYet)
assert(not data.get(paid))
assert(data.load(paid,data.Sessions[paid].Token))
assert(purchase.process(receipt)==Enum.ProductPurchaseDecision.PurchaseGranted)
assert(data.get(paid).Identity.RetryCredits==1)
assert(purchase.process(receipt)==Enum.ProductPurchaseDecision.PurchaseGranted)
assert(data.get(paid).Identity.RetryCredits==1)
local gold=data.get(paid).Gold
assert(data.changeIdentity(paid,function(nextState)nextState.Gold-=10;return true,'ok'end))
assert(purchase.process(receipt)==Enum.ProductPurchaseDecision.PurchaseGranted)
assert(data.get(paid).Gold==gold-10,'Replay de recibo reverteu progresso posterior')
assert(purchase.process({PlayerId=42,ProductId=999,PurchaseId='unknown'})==Enum.ProductPurchaseDecision.NotProcessedYet)
print('PASSOU MOCK: preço oficial, produto ausente, commit com resposta perdida e recibos duplicados sem dupla concessão/reversão de progresso.')
local savedRace=data.get(paid).Identity.Race
local changed=if savedRace=='Humano' then 'Anjo' else 'Humano'
data.get(paid).Identity.Race=changed
assert(not data.save(paid,false));assert(env.Store.Records.Player_42.Data.Identity.Race==savedRace)
assert(data.load(paid,data.Sessions[paid].Token));assert(data.get(paid).Identity.Race==savedRace)
print('PASSOU MOCK: tentativa de sobrescrever raça original é recusada na persistência.')
-- Menu construction with actual identity payload and procedural appearance for each race.
local payload=data.get(paid)
ui.update({State=payload,Party={},ServerTime=os.time(),Purchases={}});ui.identity()
assert(ui.View=='Identity' and #ui.List:GetChildren()>15)
local identityService=require(game.ServerScriptService.MedievalServer.Services.IdentityService)
paid.Character=char
for _,id in identityConfig.RaceOrder do
    payload.Identity.Race=id;identityService.appearance(paid)
    assert(char:FindFirstChild('MedievalRaceAppearance'))
end
payload.Identity.Race=savedRace
print('PASSOU MOCK: menu de linhagem/fusões e aparência própria das cinco raças constroem sem propriedades inválidas.')

local combat=require(game.ServerScriptService.MedievalServer.Services.CombatService)
local enemies=require(game.ServerScriptService.MedievalServer.Services.EnemyService)
local active=data.get(paid);active.XP=1000000;active.Class='Invocador';active.Equipment='Staff';active.Inventory.Staff=1
local tool=Instance.new('Tool');tool:SetAttribute('ItemId','Staff');tool.Parent=char
combat.attack(paid,nil,'Invocador1')
assert(combat.States[paid].Summon and combat.States[paid].Summon.Model.Parent==workspace)
local spirit=combat.States[paid].Summon.Model
combat.clear(paid);assert(not spirit.Parent)
active.Class='Necromante'
local target,hum,targetRoot=Rig.create(workspace,'EnemyFixture',char.HumanoidRootPart.Position+Vector3.new(0,-3,-8),Color3.fromRGB(90,90,90),true,'Skeleton')
hum.MaxHealth=500;hum.Health=500
char:FindFirstChildOfClass('Humanoid').Health=30
enemies.Active[target]={Root=targetRoot,Hum=hum,Contributors={}}
env.RayTarget=targetRoot
combat.attack(paid,nil,'Necromante1')
assert(hum.Health<500 and char:FindFirstChildOfClass('Humanoid').Health>30,'Dreno não aplicou dano/cura')
local mana=combat.States[paid].Mana;combat.attack(paid,nil,'Necromante1');assert(combat.States[paid].Mana==mana)
combat.changeClass(paid);assert(combat.States[paid].Mana<=mana,'Trocar classe reabasteceu mana')
combat.clear(paid);tool.Parent=nil;active.Identity.Race='Elfo';char:FindFirstChildOfClass('Humanoid').Health=20
combat.attack(paid,nil,'Racial');assert(char:FindFirstChildOfClass('Humanoid').Health==45)
local racialMana=combat.States[paid].Mana;combat.attack(paid,nil,'Racial');assert(combat.States[paid].Mana==racialMana)
combat.clear(paid);target:Destroy();enemies.Active[target]=nil;env.RayTarget=nil
print('PASSOU MOCK: CombatService real cria/limpa invocação, aplica dreno e habilidade racial; cooldown e troca de classe não reabastecem recursos.')

-- Re-read authoritative saved identity after temporary combat fixtures.
assert(data.load(paid,data.Sessions[paid].Token))
local racialProfile=data.get(paid);racialProfile.Rank='F';racialProfile.Identity.Racial={Status='Idle',Counts={},ReadyAt=0,Deadline=0}
for id in identityConfig.Secrets do racialProfile.Identity.Discoveries[id]=true end
env.Store.AfterCallback=function() data.noteDeath(paid) end
assert(data.changeIdentity(paid,function(nextState)return identity.startRacial(nextState,identityConfig,15,os.time())end))
assert(data.get(paid).Identity.Racial.Status=='Failed')
assert(env.Store.Records.Player_42.Data.Identity.Racial.Status=='Failed')
print('PASSOU MOCK: morte durante transação de início racial é registrada e persistida como falha, sem apagar recibos.')

-- Quality regression: committed receipt must survive leaving with an uncertain snapshot.
local exitPlayer=player(77);assert(data.load(exitPlayer))
local exitReceipt={PlayerId=77,ProductId=101,PurchaseId='fixture-exit-after-commit'}
env.Store.FailAfterCommit=true
assert(purchase.process(exitReceipt)==Enum.ProductPurchaseDecision.NotProcessedYet)
assert(not data.get(exitPlayer));assert(not data.save(exitPlayer,false))
data.remove(exitPlayer)
assert(env.Store.Records.Player_77.Data.Identity.Receipts[exitReceipt.PurchaseId])
assert(env.Store.Records.Player_77.Data.Identity.RetryCredits==1)
assert(data.load(exitPlayer));assert(purchase.process(exitReceipt)==Enum.ProductPurchaseDecision.PurchaseGranted)
assert(data.get(exitPlayer).Identity.RetryCredits==1)
local corrupt=player(78);env.Store.Records.Player_78={Data='corrupt-but-preserve'}
assert(not data.load(corrupt));assert(env.Store.Records.Player_78.Data=='corrupt-but-preserve')
local expired=player(79);assert(data.load(expired));data.get(expired).Gold=999
data.Sessions[expired].LeaseUntil=os.time()-1
assert(not data.get(expired));assert(not data.save(expired,false));data.remove(expired)
assert(env.Store.Records.Player_79.Data.Gold==100)
print('PASSOU MOCK: saída congelada preserva recibo confirmado; perfil malformado e lease expirado não sobrescrevem dados.')

-- Actual projectile scheduler: travel before hit, swept collision and per-owner limits.
local projectiles=require(game.ServerScriptService.MedievalServer.Services.ProjectileService)
local projectileProfile=data.get(paid);projectileProfile.Class='Mago';projectileProfile.XP=0;projectileProfile.Equipment='Staff';projectileProfile.Inventory.Staff=1
paid.Character=char;char:FindFirstChildOfClass('Humanoid').Health=100
local rangedTool=Instance.new('Tool');rangedTool:SetAttribute('ItemId','Staff');rangedTool.Parent=char
local victim,victimHum,victimRoot=Rig.create(workspace,'ProjectileVictim',char.HumanoidRootPart.Position+Vector3.new(0,-3,-20),Color3.fromRGB(90,90,90),true,'Bandit')
victimHum.MaxHealth=500;victimHum.Health=500
enemies.Active[victim]={Root=victimRoot,Hum=victimHum,Contributors={}}
env.SweepTarget=victimRoot
combat.clear(paid);combat.attack(paid,nil,'Fireball')
assert(projectiles.Count==1 and victimHum.Health==500)
projectiles.step(0.1);assert(victimHum.Health==500,'Acerto instantâneo indevido')
projectiles.step(0.1);projectiles.step(0.1)
assert(projectiles.Count==0 and victimHum.Health<500)
local healthAfter=victimHum.Health;projectiles.step(0.1);assert(victimHum.Health==healthAfter)
combat.clear(paid)
local wall=Instance.new('Part');wall.Position=char.HumanoidRootPart.Position+Vector3.new(0,0,-5);wall.Parent=workspace
env.SweepTarget=wall
combat.attack(paid,nil,'Fireball');projectiles.step(0.1)
assert(projectiles.Count==0 and victimHum.Health==healthAfter,'Parede não bloqueou projétil')
for _=1,4 do assert(projectiles.launch(paid,char.HumanoidRootPart.Position,Vector3.new(0,0,-1),100,50,'Arcane',function()return true end,function()end))end
assert(not projectiles.launch(paid,char.HumanoidRootPart.Position,Vector3.new(0,0,-1),100,50,'Arcane',function()return true end,function()end))
projectiles.cancel(paid);assert(projectiles.Count==0)
combat.clear(paid);wall:Destroy();rangedTool:Destroy();victim:Destroy();enemies.Active[victim]=nil;env.SweepTarget=nil;env.RayMiss=true
print('PASSOU MOCK: projétil real espera viagem, acerta uma vez, colide com parede e respeita/cancela limite por jogador.')

-- Boss attack cannot damage until the announced windup ends.
local bossModel,bossHum,bossRoot=Rig.create(workspace,'BossFixture',char.HumanoidRootPart.Position+Vector3.new(0,-3,-10),Color3.fromRGB(160,50,60),true,'Malgorth')
local bossDef=catalog.Enemies.Malgorth;bossHum.MaxHealth=bossDef.Health;bossHum.Health=bossDef.Health
local actor={Model=bossModel,Hum=bossHum,Root=bossRoot,Kind='Malgorth',Def=bossDef,Home=bossRoot.Position,Contributors={},PathAt=0,Waypoint=1,PathBusy=false,LastAttack=0,LastSpecial=os.clock()-20,SpecialCooldown=0}
enemies.Active[bossModel]=actor
local warnings,damage=0,0
local warning
enemies.OnWarning=function(payload)warnings+=1;warning=payload end
enemies.OnPlayerHit=function()damage+=1 end
enemies.step();assert(warnings==1 and damage==0 and actor.Pending)
actor.Pending.At=os.clock()-1;enemies.step();assert(damage>0 and not actor.Pending)
bossHum.Health=500;actor.LastSpecial=os.clock()-20;actor.SpecialCooldown=0
enemies.step();assert(bossModel:GetAttribute('Phase')==2 and warning.Radius==24 and warning.Seconds>=1)
actor.StunnedUntil=os.clock()+10;enemies.step();assert(not actor.Pending)
enemies.Active[bossModel]=nil;bossModel:Destroy();enemies.OnWarning=nil;enemies.OnPlayerHit=nil;env.RayMiss=false
print('PASSOU MOCK: chefe anuncia área antes do dano, muda fase e cancela windup quando interrompido.')

-- Approved benefits can be inspected without changing the stored wallet; no production admin path.
local tester=require(game.ServerScriptService.MedievalServer.Services.TesterService)
local settings=cache[configNode]
assert(not tester.allowed());settings.EnableStudioTester=true
local wasPersistent=data.Persistent;data.Persistent=false
env.Studio=false;assert(not tester.allowed())
env.Studio=true;assert(tester.allowed())
local wallet=data.get(paid).Identity.RetryCredits
assert(tester.preview(paid,'RacialRetry'));assert(data.get(paid).Identity.RetryCredits==wallet)
assert(not tester.preview(paid,'VIP'))
settings.EnableStudioTester=false;data.Persistent=wasPersistent
ui.menu();ui.settings();ui.offers();ui.TesterAllowed=false;ui.tester()
print('PASSOU MOCK: menu/configurações/ofertas constroem; Tester bloqueia produção e não altera créditos ou inventa VIP.')

local fieldProfile=data.get(paid);fieldProfile.Class='Mago';fieldProfile.XP=1000000;fieldProfile.Equipment='Staff';fieldProfile.Inventory.Staff=1;fieldProfile.Unlocks.FlameField=true
local fieldTool=Instance.new('Tool');fieldTool:SetAttribute('ItemId','Staff');fieldTool.Parent=char
local fieldEnemy,fieldHum,fieldRoot=Rig.create(workspace,'FieldVictim',char.HumanoidRootPart.Position+Vector3.new(0,-3,-20),Color3.fromRGB(80,80,80),true,'Skeleton')
fieldHum.MaxHealth=500;fieldHum.Health=500;enemies.Active[fieldEnemy]={Root=fieldRoot,Hum=fieldHum,Contributors={}}
env.RayMiss=true;combat.clear(paid);combat.attack(paid,nil,'FlameField');assert(#combat.Fields==1)
local afterInitial=fieldHum.Health;combat.Fields[1].Next=os.clock()-1;combat.tick(0.25)
assert(fieldHum.Health<afterInitial,'Campo persistente foi apenas visual')
combat.Fields[1].Expires=os.clock()-1;combat.tick(0.25);assert(#combat.Fields==0)
combat.clear(paid);fieldTool:Destroy();enemies.Active[fieldEnemy]=nil;fieldEnemy:Destroy();env.RayMiss=false
print('PASSOU MOCK: Campo de Chamas aplica pulsos autoritativos posteriores ao cast e expira sem manter dano infinito.')

-- TerrainMath sampling and the actual voxel adapter agree for river bed/water/air.
env.CaptureVoxels=true
originalWriter(workspace.Terrain,config,{X=0,Z=300,Width=4,Depth=4})
for iy=1,(config.MaxY-config.MinY)/4 do
 local material,fill=mathTerrain.voxel(config,2,config.MinY+(iy-0.5)*4,302)
 assert(env.LastVoxels.Materials[1][iy][1]==Enum.Material[material])
 assert(math.abs(env.LastVoxels.Occupancy[1][iy][1]-fill)<1e-9)
end
env.CaptureVoxels=false;env.LastVoxels=nil
print('PASSOU MOCK: adaptador de Terrain e amostragem pura concordam para leito, água e ar do rio.')

-- Real visual controller handlers, simulated Instances only (no rendering claim).
ui.Settings.Quality='LOW';ui.Settings.ReducedMotion=false
local at=char.HumanoidRootPart.Position
effects.OnClientEvent:Fire({Kind='Projectile',Id=999,Origin=at,Direction=Vector3.new(0,0,-1),Range=50,Speed=100,Style='Fire'})
local localProjectile=workspace:FindFirstChild('LocalProjectile');assert(localProjectile and not localProjectile.CanCollide and not localProjectile.CanQuery)
game.RunService.Heartbeat:Fire()
effects.OnClientEvent:Fire({Kind='ProjectileEnd',Id=999,Position=at});assert(not localProjectile.Parent)
effects.OnClientEvent:Fire({Kind='Burst',Position=at,Radius=8,Style='Ice'})
assert(workspace:FindFirstChild('LocalExplosion'))
effects.OnClientEvent:Fire({Kind='Warning',Position=at,Radius=14,Seconds=1.2,Name='Aviso de teste'})
assert(workspace:FindFirstChild('DangerTelegraph'))
effects.OnClientEvent:Fire({Kind='Hit',A=at,B=at+Vector3.new(0,0,-3),Damage=12,Style='Steel'})
assert(workspace:FindFirstChild('LocalCombatFX'))
print('PASSOU MOCK: controller visual cria/remove projétil, explosão, telegraph e indicador de impacto sem colisão física.')

ui.map();assert(ui.View=='Map' and #ui.List:GetChildren()>=3)
print('PASSOU MOCK: atlas preserva cidades/florestas/dungeon e desenha rotas configuradas com ações de consulta.')
