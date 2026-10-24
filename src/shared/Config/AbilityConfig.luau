local A={MaxLevel=100,XPBase=80,XPGrowth=35,Classes={
 Espadachim={Weapon='Katana',Health=100,Mana=70,Stamina=120,Damage=1.1,Defense=2,Speed=18},
 Guerreiro={Weapon='Longsword',Health=130,Mana=60,Stamina=110,Damage=1.2,Defense=8,Speed=16},
 Mago={Weapon='Staff',Health=90,Mana=150,Stamina=90,Damage=1,Defense=0,Speed=16},
 Arqueiro={Weapon='Bow',Health=100,Mana=90,Stamina=110,Damage=1.05,Defense=2,Speed=18},
},Skills={},Slots={
 Espadachim={'WindCut','CrossCut','BladeStorm','MoonSlash'},Guerreiro={'Cleave','EarthBreaker','IronGuard','WarCry'},
 Mago={'Fireball','IceBolt','Lightning','Heal'},Arqueiro={'PiercingArrow','ArrowFan','FocusShot','RainOfArrows'},
}}
local function skill(id,name,class,level,damage,range,radius,mana,stamina,cd,effect)
 A.Skills[id]={Id=id,Name=name,Class=class,Level=level,Damage=damage,Range=range,Radius=radius,Mana=mana,Stamina=stamina,Cooldown=cd,Effect=effect or 'Hit',Description=name..': efeito autoritativo, alcance '..range..' studs.',Price=if class=='Mago' then level*30 else 0}
end
skill('WindCut','Corte do Vento','Espadachim',1,30,32,0,10,8,4)
skill('CrossCut','Corte Cruzado','Espadachim',5,45,12,8,15,12,6)
skill('BladeStorm','Tempestade de Lâminas','Espadachim',12,38,14,14,22,18,10)
skill('MoonSlash','Lua Partida','Espadachim',20,80,38,6,35,25,16,'Stun')
skill('Cleave','Fenda de Aço','Guerreiro',1,38,14,9,5,18,5)
skill('EarthBreaker','Ruptura da Terra','Guerreiro',5,55,18,16,15,25,8,'Stun')
skill('IronGuard','Guarda de Ferro','Guerreiro',12,0,0,0,15,12,16,'Guard')
skill('WarCry','Grito de Guerra','Guerreiro',20,40,20,20,20,20,20,'Stun')
skill('PiercingArrow','Flecha Perfurante','Arqueiro',1,35,110,0,8,8,4)
skill('ArrowFan','Leque de Flechas','Arqueiro',5,30,70,10,15,12,7)
skill('FocusShot','Disparo Preciso','Arqueiro',12,75,130,0,24,16,12)
skill('RainOfArrows','Chuva de Flechas','Arqueiro',20,55,85,18,35,25,18)
skill('Fireball','Bola de Fogo','Mago',1,32,80,0,12,0,3,'Burn')
skill('FireExplosion','Explosão Ígnea','Mago',5,50,55,14,22,0,8,'Burn')
skill('FlameField','Campo de Chamas','Mago',12,25,50,18,30,0,12,'Burn')
skill('IceBolt','Projétil Congelante','Mago',1,24,80,0,12,0,4,'Slow')
skill('IceWave','Onda Glacial','Mago',6,32,50,14,22,0,8,'Slow')
skill('IceExplosion','Explosão de Gelo','Mago',14,50,60,18,32,0,13,'Slow')
skill('Lightning','Descarga Elétrica','Mago',1,28,70,0,14,0,4,'Stun')
skill('ChainLightning','Raio em Cadeia','Mago',8,32,65,18,25,0,9,'Chain')
skill('ThunderImpact','Impacto Elétrico','Mago',18,65,70,14,38,0,15,'Stun')
skill('Heal','Cura Individual','Mago',1,40,0,0,18,0,8,'Heal')
skill('GroupHeal','Cura em Área','Mago',8,35,20,20,28,0,12,'Heal')
skill('Regenerate','Regeneração','Mago',16,8,0,0,32,0,18,'Regen')
local advanced={
 Tanque={Base='Guerreiro',Health=145,Mana=55,Stamina=105,Damage=1.05,Defense=12,Speed=14,Effect='Guard'},
 ['Valquíria']={Base='Guerreiro',Health=115,Mana=90,Stamina=100,Damage=1.1,Defense=5,Speed=18,Effect='Heal'},
 Samurai={Base='Espadachim',Health=100,Mana=75,Stamina=115,Damage=1.15,Defense=2,Speed=18,Effect='Stun'},
 Assassino={Base='Espadachim',Health=85,Mana=85,Stamina=120,Damage=1.2,Defense=0,Speed=20,Effect='Burn'},
 Invocador={Base='Mago',Health=100,Mana=145,Stamina=85,Damage=0.95,Defense=1,Speed=16,Effect='Summon'},
 Necromante={Base='Mago',Health=95,Mana=145,Stamina=90,Damage=1,Defense=1,Speed=16,Effect='Drain'},
}
for class,def in advanced do
 def.Weapon=A.Classes[def.Base].Weapon;A.Classes[class]=def;A.Slots[class]={}
 for index,name in {'Juramento','Técnica','Domínio','Ascensão'} do
  local id=class..index;local effect=if index==1 then def.Effect else (if index==3 then 'Slow' else 'Hit')
  skill(id,name..' de '..class,class,if index==1 then 1 else 15+index*5,if effect=='Guard' then 0 elseif effect=='Summon' then 12 elseif effect=='Heal' then 35 else 25+index*8,if def.Base=='Mago' then 65 else 18,if index==4 then 16 else 0,10+index*4,if def.Base=='Mago' then 0 else 8,index*3+4,effect)
  table.insert(A.Slots[class],id)
 end
end
A.RaceModifiers={Humano={Health=5,Mana=-5,Stamina=0},Elfo={Health=-10,Mana=10,Stamina=0},ElfoNegro={Health=0,Mana=8,Stamina=-8},Demonio={Health=0,Mana=-10,Stamina=10},Anjo={Health=-5,Mana=5,Stamina=0}}
A.RacialSkills={
 Humano={Name='Fôlego Resoluto',Effect='RestoreStamina',Power=25},
 Elfo={Name='Sopro Silvestre',Effect='Heal',Power=25},
 ElfoNegro={Name='Foco do Crepúsculo',Effect='RestoreMana',Power=25},
 Demonio={Name='Vontade de Brasa',Effect='Guard',Power=0},
 Anjo={Name='Graça da Aurora',Effect='Regen',Power=0},
}
-- Mechanical/visual delivery per ability, not a client-selected damage style.
for id,s in A.Skills do
 s.Style=if s.Effect=='Burn' then 'Fire' elseif s.Effect=='Slow' then 'Ice' elseif s.Effect=='Stun' or s.Effect=='Chain' then 'Lightning' elseif s.Effect=='Heal' or s.Effect=='Regen' then 'Heal' elseif s.Class=='Arqueiro' then 'Arrow' elseif s.Effect=='Drain' then 'Shadow' else 'Steel'
 if id=='Fireball' or id=='FireExplosion' or id=='IceBolt' or s.Class=='Arqueiro' then s.ProjectileSpeed=if s.Class=='Arqueiro' then 165 else 95 end
 if id=='FlameField' then s.Duration=5 end
end
return A
