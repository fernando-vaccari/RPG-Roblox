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
assert(#root.Cities:GetChildren()==5 and #root.NPCs:GetChildren()>=60)
for _,check in report.Checks do assert(check.Status~='FALHOU',check.Name) end
assert(not pcall(world.GenerateNewWorld));assert(workspace.GeneratedWorld==root)
local parts,npcs=0,0
for _,n in root:GetDescendants()do if n:IsA('BasePart')then parts+=1 end;if n:GetAttribute('NpcId')then npcs+=1 end end
print('PASSOU MOCK: continente/orquestração, recusas de ocupação e segunda geração; '..parts..' Parts e '..npcs..' NPCs.')
local npcCount=#root.NPCs:GetChildren()
world.RegenerateCity('Valoria')
assert(#root.Cities:GetChildren()==5 and #root.NPCs:GetChildren()==npcCount)
world.RegenerateForest('Sylvarin')
assert(#root.Forests:GetChildren()==3 and #root.EnemySpawns:GetChildren()==32 and #root.TreasureChests:GetChildren()==15)
world.RegenerateDecorations();world.RegenerateNPCMarkers()
assert(#root.NPCSpawns:GetChildren()==npcCount)
assert(not pcall(world.RegenerateGeneratedWorld))
assert(#game.ServerStorage.MedievalBackups:GetChildren()==4)
local placeKind=Instance.new('StringValue');placeKind.Name='MedievalPlaceKind';placeKind.Value='World';placeKind.Parent=game.ServerStorage
local writesBefore=env.VoxelWrites
local prepared=world.PrepareStudio()
assert(prepared.Status=='Prepared' and prepared.StudioSessionPreview and env.VoxelWrites==writesBefore)
assert(workspace.GeneratedWorld==root and workspace:GetAttribute('EldravynPrepared'))
world.PrepareStudio({Persistent=true});assert(workspace:GetAttribute('StudioSessionPreview')==false)
print('PASSOU MOCK: comando de preparação valida mapa já gerado sem reescrever Terrain e separa prévia de persistência.')
print('PASSOU MOCK: regenerações seletivas mantêm contagens e arquivam conteúdo anterior; Terrain não alterado.')
local dungeon=world.GenerateDungeon({Origin=Vector3.new(6000,30,0),StudioTest=true})
assert(#dungeon.Rooms:GetChildren()==14 and #dungeon.EnemySpawns:GetChildren()==6)
assert(dungeon:FindFirstChild('ReturnPortal') and #dungeon.TreasureChests:GetChildren()==2)
local dConfig=require(game.ReplicatedStorage.MedievalRPG.Config.DungeonConfig)
local floorCount,enemyCount=0,0
for _,id in dConfig.Order do
    local tower=dungeon.Expeditions:FindFirstChild(id);assert(#tower:GetChildren()==dConfig.Dungeons[id].Floors)
    for _,floor in tower:GetChildren() do
        assert(floor.NextFloor:GetAttribute('ExpeditionNext') and floor.RetreatPortal:GetAttribute('ReturnPortal'))
        assert(floor:GetAttribute('Active')==false and floor:GetAttribute('SpawnPosition'))
        for _,marker in floor.EnemySpawns:GetChildren() do assert(marker:GetAttribute('Enabled')==false and marker:GetAttribute('Once'));enemyCount+=1 end
        floorCount+=1
    end
end
assert(floorCount==30 and enemyCount>50)
print('PASSOU MOCK: 30 andares reais construídos com portais, baús, encontros desativados e seis arquétipos; legado preservado.')
-- Regression for a real front timber rail previously crossing every doorway.
local planned=require(game.ServerStorage.MedievalWorldgen.WorldPlan).build(config,mathTerrain,require(game.ReplicatedStorage.MedievalRPG.Config.ContentConfig))
for _,city in planned.Cities do for index,lot in city.Lots do
    local model=root.Cities[city.Id]:FindFirstChild(lot.Id);local frame=CFrame.new(lot.X,lot.H,lot.Z)*CFrame.Angles(0,lot.Yaw,0)
    local depth=if lot.Kind=='Castle' then 40 elseif lot.Kind=='ArcaneTower' then 24 elseif lot.Kind=='Forge' then 34 else 28+(index%2)*2
    for _,part in model:GetChildren() do
        if part:IsA('BasePart') and part.CanCollide~=false then
            local p=frame:PointToObjectSpace(part.Position)
            if math.abs(p.Z+depth/2)<0.8 and p.Y-part.Size.Y/2<8 and p.Y+part.Size.Y/2>2 then
                assert(math.abs(p.X)-part.Size.X/2>=3,'Porta obstruída: '..lot.Id..'/'..part.Name)
            end
        end
    end
end end
local guild=planned.Cities[1].Lots[1];assert(guild.External and math.abs(guild.Z-config.Cities[1].Z)>config.Cities[1].Radius)
print('PASSOU MOCK: entradas centrais não têm travessas colidíveis e guilda fica fora de Valoria (geometria, sem física real).')
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

-- New runtime integrations use actual services, with only platform APIs simulated.
for _,product in identityConfig.Products do product.Id=0 end
local gameService=require(game.ServerScriptService.MedievalServer.Services.GameService)
gameService.start(remote,effects)
local expeditions=require(game.ServerScriptService.MedievalServer.Services.ExpeditionService)
local dungeonService=require(game.ServerScriptService.MedievalServer.Services.DungeonService)
local security=require(game.ServerScriptService.MedievalServer.Services.AntiExploitService)
local tutorial=require(game.ServerScriptService.MedievalServer.Services.TutorialService)
local defense=require(game.ReplicatedStorage.MedievalRPG.Core.DefenseRules)
local expMap=world.GenerateDungeon({Origin=Vector3.new(9000,30,0),StudioTest=true})
local function adventurer(id)
    local p=player(id);assert(data.load(p));local s=data.get(p);rules.register(s);rules.choose(s,catalog,'Staff');s.XP=100000
    p.Character=Rig.create(workspace,'Adventurer'..id,Vector3.new(9000,32,-18),Color3.fromRGB(90,120,160),false,'Citizen')
    return p
end
local one,two,intruder=adventurer(201),adventurer(202),adventurer(203)
assert(expeditions.begin('MalgorthDepths',{one,two},expMap,'runtime-test'))
local f=expeditions.floor()
assert(not expeditions.advance(one,f.NextFloor),'Portal aceitou andar não limpo')
enemies.step()
local enemyModel,enemy
for m,e in enemies.Active do if e.Spawn.Root==f then enemyModel,enemy=m,e;break end end
assert(enemy)
intruder.Character:PivotTo(CFrame.new(enemy.Root.Position))
assert(not enemies.damage(enemyModel,intruder,99999),'Intruso danificou inimigo de outro grupo')
assert(not expeditions.canChest(intruder,f.TreasureChests:GetChildren()[1]))
print('PASSOU MOCK: serviço real bloqueia portal prematuro, dano e baú por jogador fora do grupo.')
local function clearFloor()
    local floor=expeditions.floor();enemies.step()
    local killed=0
    for model,e in table.clone(enemies.Active) do
        if e.Spawn and e.Spawn.Root==floor then assert(enemies.damage(model,one,99999));killed+=1 end
    end
    assert(killed>0 and expeditions.Run.State=='Cleared' and expeditions.Run.Remaining==0)
    return floor
end
local function atPortal(floor)
    for i,p in {one,two} do p.Character:PivotTo(CFrame.new(floor.NextFloor.Position+Vector3.new(i*3,0,-5))) end
end
for _,id in dConfig.Order do
    if id~='MalgorthDepths' then assert(expeditions.begin(id,{one,two},expMap,'second-run')) end
    for n=1,dConfig.Dungeons[id].Floors do
        local floor=clearFloor();assert(expeditions.canChest(one,floor.TreasureChests:GetChildren()[1]));atPortal(floor)
        assert(expeditions.advance(one,floor.NextFloor))
        assert(data.get(one).Expedition.Best[id]==n and data.get(two).Expedition.Best[id]==n)
        assert(not expeditions.advance(two,floor.NextFloor),'Portal antigo avançou duas vezes')
    end
    assert(expeditions.Run.State=='Complete' and data.get(one).Expedition.Clears[id])
end
assert(data.get(one).Identity.Fragments>=10,'Andares não concederam fragmentos')
assert(data.save(one,true));assert(data.load(one));assert(data.get(one).Expedition.Best.FallenSanctum==20)
print('PASSOU MOCK: serviços reais completam 10 + 20 andares em dupla, salvam ambos, preservam fragmentos e recusam portal repetido.')

assert(expeditions.begin('MalgorthDepths',{one,two},expMap,'replay-test'))
for n=1,10 do local floor=clearFloor();atPortal(floor);assert(expeditions.advance(one,floor.NextFloor)) end
assert(expeditions.Run.State=='Complete','BossDefeated antigo impediu uma nova tentativa')
print('PASSOU MOCK: segunda tentativa rearma todos os encontros, inclusive Malgorth, sem bloquear o chefe pelo estado anterior.')

-- Real combat hurt -> parry -> tutorial, followed by a normal telegraphed attack.
expeditions.leave(one);expeditions.leave(two);expeditions.leave(intruder)
one.Character:PivotTo(CFrame.new(0,60,0));combat.clear(one)
local sparring,sh,sr=Rig.create(workspace,'Sparring',Vector3.new(0,57,-5),Color3.fromRGB(120,120,120),true,'Training')
local spar={Model=sparring,Hum=sh,Root=sr,Kind='Training',Def=catalog.Enemies.Training,Home=sr.Position,Contributors={},PathAt=0,LastAttack=-100,Waypoint=1,PathBusy=false}
enemies.Active[sparring]=spar
local oldHealth=one.Character:FindFirstChildOfClass('Humanoid').Health
combat.control(one,'BlockOn');combat.hurt(one,10,sr.Position,spar,true)
assert(one.Character:FindFirstChildOfClass('Humanoid').Health==oldHealth and data.get(one).Adventure.Tutorial.Parry)
assert((spar.Posture or 0)==55)
combat.control(one,'BlockOff');spar.StunnedUntil=0;env.RayMiss=true
enemies.step();assert(spar.Swing and one.Character:FindFirstChildOfClass('Humanoid').Health==oldHealth)
spar.Swing.At=os.clock()-1;enemies.resolveSwing(spar,os.clock())
assert(one.Character:FindFirstChildOfClass('Humanoid').Health<oldHealth)
enemies.Active[sparring]=nil;sparring:Destroy();env.RayMiss=false
print('PASSOU MOCK: dano real aciona parry/tutorial e ataque comum só causa dano após windup; resolução separada da IA de 4 Hz.')

-- UI receives the exact public payload generated by GameService.
gameService.state(one);ui.update(env.LastClient.Data)
assert(ui.ServerTime==data.get(one).ServerTime or type(ui.ServerTime)=='number')
assert(ui.Purchases and ui.Purchases.RacialRetry==false)
ui.character();ui.tutorial();ui.expeditions();ui.refreshAdventure()
game.UserInputService.TouchEnabled=true
ui.start(remote);ui.update(env.LastClient.Data);ui.GetAim=function()return Vector3.new(1,2,3)end
ui.HotbarButtons[1].Activated:Fire()
assert(env.LastRequest[1]=='Attack' and env.LastRequest[2].Mode=='Fireball' and env.LastRequest[2].Target.X==1)
game.UserInputService.TouchEnabled=false
print('PASSOU MOCK: payload de horário/compras correto, menus de personagem/tutorial/expedição e hotbar touch emitem intenção com mira.')

-- Teleport is simulated; tickets are written through the real atomic DataService.
local a,b=adventurer(301),adventurer(302)
local guardian=expMap.NPCs.DepthsReception.HumanoidRootPart
for _,p in {a,b} do p.Character:PivotTo(guardian.CFrame);security.open(p,guardian,'Dungeon','Malgorth') end
settings.DungeonPlaceId=111;settings.ReturnPlaceId=222;env.Studio=false
assert(dungeonService.action(a,'Create'));assert(dungeonService.action(b,'Join',301))
assert(dungeonService.action(a,'Confirm'));assert(dungeonService.action(b,'Confirm'))
assert(dungeonService.action(a,'Start'))
assert(env.LastTeleport and env.LastTeleport.Place==111 and #env.LastTeleport.Players==2)
assert(not data.get(a) and not data.get(b))
assert(#env.Store.Records.Player_301.Data.Expedition.Ticket.Members==2)
-- New destination server simulation: no run has been admitted yet.
expeditions.Run=nil;expeditions.Participants={};expeditions.Map=nil
assert(data.load(a));assert(expeditions.admit(a,expMap));assert(expeditions.Run.State=='Gathering')
assert(data.load(b));assert(expeditions.admit(b,expMap));assert(expeditions.Run.State=='Fighting')
assert(not expeditions.admit(a,expMap) and env.Store.Records.Player_301.Data.Expedition.Ticket==nil)
assert(not expeditions.admit(intruder,expMap))
env.Studio=true;settings.DungeonPlaceId=0;settings.ReturnPlaceId=0
print('PASSOU MOCK: reserva de grupo gravada antes do teleporte simulado, espera pelos dois membros e consome tickets sem confiar em TeleportData.')

-- Lost response during settlement: retry cannot pay the earlier member twice.
one,two=a,b
local floor=clearFloor();atPortal(floor)
env.Store.FailAfterCommit=true
assert(not expeditions.advance(one,floor.NextFloor) and not data.get(one))
local committedGold=env.Store.Records.Player_301.Data.Gold
assert(data.load(one,data.Sessions[one].Token));assert(expeditions.advance(one,floor.NextFloor))
assert(data.get(one).Gold==committedGold and data.get(one).Expedition.Best.MalgorthDepths==1)
expeditions.eliminate(one);assert(expeditions.Run.State~='Failed')
expeditions.eliminate(two);assert(expeditions.Run.State=='Failed')
assert(not expeditions.advance(two,expeditions.floor().NextFloor))
print('PASSOU MOCK: resposta perdida após commit de andar mantém recompensa única; derrota de todo o grupo bloqueia avanço e preserva best floor.')

-- Preview must never silently replace production persistence, nor reroll ephemeral races.
local dataNode=game.ServerScriptService.MedievalServer.Services.DataService
workspace:SetAttribute('StudioSessionPreview',true)
env.Studio=false
local productionData=loaders[dataNode]();assert(productionData.Persistent)
env.Studio=true
local previewData=loaders[dataNode]();assert(not previewData.Persistent)
local previewPlayer=player(-1);local updates=env.Store.Updates
assert(previewData.load(previewPlayer));assert(previewData.get(previewPlayer).Identity.Race=='')
assert(previewData.save(previewPlayer,true));assert(env.Store.Updates==updates)
workspace:SetAttribute('StudioSessionPreview',false)
print('PASSOU MOCK: preparação libera prévia local sem APIs, não sorteia raça descartável e nunca desliga DataStore em produção.')

-- Actual authoritative actions: single creation, equipment compatibility, shop distance and tutorial credit.
local novice=player(401);assert(data.load(novice))
novice.Character=Rig.create(workspace,'Novice',Vector3.new(0,60,0),Color3.fromRGB(100,100,100),false,'Citizen')
gameService.action(novice,'CreateCharacter','Longsword')
assert(data.get(novice).Class=='Guerreiro' and novice.Character:FindFirstChildOfClass('Tool'))
security.clear(novice);gameService.action(novice,'CreateCharacter','Staff')
assert(not data.get(novice).Inventory.Staff)
local noviceState=data.get(novice);noviceState.Inventory.Staff=1;noviceState.Inventory.Armor=1
security.clear(novice);gameService.action(novice,'Equip','Staff');assert(noviceState.Equipment=='Longsword')
security.clear(novice);gameService.action(novice,'Equip','Armor');assert(noviceState.Armor=='Armor' and novice.Character:FindFirstChild('MedievalArmor'))
security.clear(novice);gameService.action(novice,'UnequipArmor');assert(noviceState.Armor=='' and not novice.Character:FindFirstChild('MedievalArmor'))
local money=noviceState.Gold;security.clear(novice);gameService.action(novice,'Buy','Potion');assert(noviceState.Gold==money)
security.open(novice,novice.Character.HumanoidRootPart,'ShopPotions','Valoria');security.Buckets[novice]={}
gameService.action(novice,'Buy','Potion');assert(noviceState.Gold==money-30 and noviceState.Inventory.Potion==1)
security.clear(novice);gameService.action(novice,'TutorialInventory');assert(noviceState.Adventure.Tutorial.Inventory and noviceState.Gold==money-30)
print('PASSOU MOCK: criação/arma única, equipar armadura real, arma incompatível, loja sem contexto e tutorial sem recompensa falsa.')

-- City defense runs through real spawn/death callbacks and transactional rewards.
local siege=require(game.ServerScriptService.MedievalServer.Services.SiegeService)
expeditions.leave(a);expeditions.leave(b)
local siegeMap=workspace.GeneratedWorld;siegeMap:SetAttribute('Status','Complete')
local spawnFolder=Instance.new('Folder');spawnFolder.Name='EnemySpawns';spawnFolder.Parent=siegeMap
local content=require(game.ServerStorage.MedievalWorldgen.ContentGenerator)
for i=1,5 do
    local marker=content.enemyMarker(spawnFolder,'SiegeFixture'..i,Vector3.new(i*3,60,20),'Demon')
    marker:SetAttribute('DefenseCity','Valoria');marker:SetAttribute('Enabled',false);marker:SetAttribute('Once',true)
end
noviceState.Rank='F';assert(rules.accept(noviceState,catalog,'ValoriaDefense'))
enemies.scan(siegeMap);siege.Next=0;siege.step();assert(siege.Current and siege.Current.Remaining==5)
enemies.step();local last
for model,e in table.clone(enemies.Active) do if e.Spawn and e.Spawn.Root==siegeMap then last=e;assert(enemies.damage(model,novice,99999)) end end
assert(not siege.Current and data.get(novice).Quests.ValoriaDefense.Count==1)
local defendedGold=data.get(novice).Gold;siege.killed(last);assert(data.get(novice).Gold==defendedGold)
assert(env.Store.Records.Player_401.Data.Adventure.DefenseClaims.Valoria)
print('PASSOU MOCK: defesa inicia por proximidade, cinco mortes concluem objetivo e a recompensa persistida não repete.')

-- Local server clients use negative IDs; the same actual group flow must accept four.
local four={adventurer(-11),adventurer(-12),adventurer(-13),adventurer(-14)}
for _,p in four do p.Character:PivotTo(guardian.CFrame);security.open(p,guardian,'Dungeon','Malgorth') end
assert(dungeonService.action(four[1],'Create'))
for i=2,4 do assert(dungeonService.action(four[i],'Join',-11)) end
local fifth=adventurer(-15);fifth.Character:PivotTo(guardian.CFrame);security.open(fifth,guardian,'Dungeon','Malgorth')
assert(not dungeonService.action(fifth,'Join',-11))
for _,p in four do assert(dungeonService.action(p,'Confirm')) end
assert(dungeonService.action(four[1],'Start'))
assert(expeditions.Run.State=='Fighting' and expeditions.Run.Members[-14] and not expeditions.Run.Members[-15])
local localFloor=expeditions.floor();enemies.step()
for model,e in table.clone(enemies.Active) do if e.Spawn and e.Spawn.Root==localFloor then assert(enemies.damage(model,four[1],99999)) end end
for i,p in four do p.Character:PivotTo(CFrame.new(localFloor.NextFloor.Position+Vector3.new(i*3,0,-5))) end
four[4].Character:PivotTo(CFrame.new(localFloor:GetAttribute('SpawnPosition')))
assert(not expeditions.advance(four[1],localFloor.NextFloor),'Grupo avançou sem reunir sobrevivente')
four[4].Character:PivotTo(CFrame.new(localFloor.NextFloor.Position))
assert(expeditions.advance(four[1],localFloor.NextFloor))
for _,p in four do assert(data.get(p).Expedition.Best.MalgorthDepths==1);expeditions.leave(p) end
print('PASSOU MOCK: grupo local de quatro IDs negativos entra, rejeita quinto e só avança quando todos os sobreviventes se reúnem.')

game.UserInputService.TouchEnabled=true
local function rect(node,w,h)
 local p,s=node.Position,node.Size
 return {X=p.X.Scale*w+p.X.Offset,Y=p.Y.Scale*h+p.Y.Offset,W=s.X.Scale*w+s.X.Offset,H=s.Y.Scale*h+s.Y.Offset}
end
local function overlap(a,b)return a.X<b.X+b.W and a.X+a.W>b.X and a.Y<b.Y+b.H and a.Y+a.H>b.Y end
for _,size in {{667,375},{844,390},{390,844}} do
 local w,h=size[1],size[2];ui.adapt(w,h)
 local guide,toast,hotbar=rect(ui.Guide,w,h),rect(ui.Toast,w,h),rect(ui.ActionFrames[1],w,h)
 assert(not overlap(guide,hotbar) and not overlap(toast,hotbar),'Tutorial/notificação cobre habilidade touch')
end
game.UserInputService.TouchEnabled=false
print('PASSOU MOCK: áreas calculadas de tutorial/notificação/hotbar não se sobrepõem em três viewports móveis; renderização real pendente.')
