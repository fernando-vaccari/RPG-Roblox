-- Stage 2 is opt-in. No combat, racial roll or general inventory is started.
local C={Version=1,MaxGold=1000000000,MaxStack=99,PromptDistance=12,SessionSeconds=90,
 ClassChangeProduct={Id=0,Robux=100},InnPrice=15,HealPrice=10,
 Ranks={'F','E','D','C','B','A','S'},
 RankRequirements={F={XP=0,Quests=0,Benefit='Registro e missões iniciais'},E={XP=100,Quests=2,Benefit='Novos contratos e estudos de classe'},D={XP=260,Quests=4,Benefit='Contratos das fronteiras'},C={XP=600,Quests=8,Benefit='Autorizações intermediárias de dungeon'},B={XP=1200,Quests=12,Benefit='Contratos veteranos'},A={XP=2400,Quests=18,Benefit='Contratos de elite'},S={XP=4800,Quests=28,Benefit='Reconhecimento máximo da guilda'}},
 Classes={Guerreiro={Text='Resistência e proteção; técnicas serão integradas depois.'},Espadachim={Text='Disciplina com lâminas; ataques pertencem à etapa de combate.'},Mago={Text='Estudo arcano; conjuração será integrada depois.'},Arqueiro={Legacy=true,Text='Classe anterior preservada; seleção inicial destaca as três classes principais.'}},
 Advanced={Tanque={Base='Guerreiro',Rank='E',Quest='CityTour'},['Valquíria']={Base='Guerreiro',Rank='D',Quest='ForestSurvey'},Samurai={Base='Espadachim',Rank='E',Quest='CityTour'},Assassino={Base='Espadachim',Rank='D',Quest='ShadowDiscovery'},Invocador={Base='Mago',Rank='E',Quest='RuneStudy'},Necromante={Base='Mago',Rank='D',Quest='ShadowDiscovery',Secret=true}},
 Spells={LuzGuia={Name='Luz-guia',School='Luz',Rank='E',Quest='RuneStudy',Price=20,RegistrationEnabled=true,Text='Registro de estudo disponível; conjuração em atualização futura.'},Chama={Name='Chama',School='Fogo',Rank='D',RegistrationEnabled=false,Text='Catálogo futuro; desbloqueio e conjuração indisponíveis.'}},
 Roles={},Definitions={},AmbientRoles={'Guard','Resident','Traveler','Artisan','Employee','Adventurer','Farmer'}}
local roles={
 GuildMaster={'Maelis','Mestre da Guilda','GuildHall'},Reception={'Iria','Recepcionista da Guilda','GuildHall'},
 Blacksmith={'Borin','Ferreiro','Blacksmith'},Weapons={'Aren','Comerciante de Armas','WeaponShop'},Armor={'Helga','Comerciante de Armaduras','Workshop'},General={'Nilo','Comerciante Geral','Market'},
 Classes={'Kael','Mestre de Classes','TrainingHall'},Magic={'Seren','Mestre de Magia','MagicShop'},Skills={'Darian','Mentor de Habilidades','TrainingHall'},Races={'Liora','Especialista em Raças','Temple'},Fusions={'Orin','Especialista em Fusões','Workshop'},
 Inn={'Mira','Estalajadeira','Tavern'},Healer={'Elian','Curandeiro','Temple'},Bank={'Cedric','Banqueiro','Market'},Guide={'Nara','Guia da Cidade','Stable'},Tutorial={'Theo','Guia de Novos Aventureiros','Spawn'},TravelShop={'Veyra','Mercadora Viajante','Market'},
 Dungeon={'Selwyn','Administrador de Dungeon','Dungeon'},
 Guard={'Sentinela','Guarda','Castle'},Resident={'Morador','Morador','SmallHouse'},Traveler={'Viajante','Viajante','Stable'},Artisan={'Artesão','Artesão','Workshop'},Employee={'Assistente','Funcionário de loja','Market'},Adventurer={'Aventureiro','Aventureiro','TrainingHall'},Farmer={'Camponês','Camponês','Barn'}}
for id,r in roles do C.Roles[id]={Name=r[1],Title=r[2],Template=r[3]} end
for _,role in {'GuildMaster','Reception','Blacksmith','Weapons','Armor','General','Classes','Magic','Skills','Races','Fusions','Inn','Healer','Bank','Guide','Tutorial','TravelShop'} do
 table.insert(C.Definitions,{Id='Valoria_'..role,Role=role,City='Valoria'})
end
for _,city in {'Arkheim','Eldoria','Durakh','Asterion'} do
 for _,role in {'Guide','General','Inn'} do table.insert(C.Definitions,{Id=city..'_'..role,Role=role,City=city}) end
end
for _,city in {'Valoria','Arkheim','Eldoria','Durakh','Asterion'} do
 for i,role in C.AmbientRoles do table.insert(C.Definitions,{Id=city..'_Ambient_'..role,Role=role,City=city,Ambient=true,Variant=i}) end
end
for _,id in {'MalgorthDepths','FallenSanctum'} do table.insert(C.Definitions,{Id=id..'_Administrator',Role='Dungeon',City=id,Dungeon=id}) end
return C
