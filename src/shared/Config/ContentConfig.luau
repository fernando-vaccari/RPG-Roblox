-- Todo asset geométrico é próprio. Sem meshes, roupas ou animações de terceiros.
local Catalog = {
    CityBuildings = {
        Valoria = {"GuildHall","Tavern","Blacksmith","WeaponShop","MagicShop","PotionShop","Market","TrainingHall","Temple","Barn","Windmill","Stable","GuardTower","SmallHouse","MediumHouse","SmallHouse","LargeHouse"},
        Arkheim = {"Castle","Barracks","TrainingHall","Blacksmith","ArmorShop","WeaponShop","Tavern","MagicShop","Library","WatchTower","Stable","Market","LargeHouse","MediumHouse","LargeHouse","SmallHouse"},
        Eldoria = {"ArcaneTower","MagicSchool","Library","MagicShop","StaffShop","PotionShop","Market","Tavern","Temple","AlchemyLab","TrainingHall","SmallHouse","MediumHouse","LargeHouse"},
        Durakh = {"Forge","SmithGuild","WeaponShop","ArmorShop","MaterialShop","Tavern","Mine","Market","Workshop","Barracks","SmallHouse","MediumHouse","LargeHouse"},
    },
    Labels = {
        GuildHall="Guilda dos Aventureiros",Tavern="Hospedaria",Blacksmith="Ferreiro",WeaponShop="Armas",MagicShop="Magias",
        PotionShop="Poções",ArmorShop="Armaduras",Market="Mercado",TrainingHall="Campo de Treino",Temple="Templo",
        Barn="Celeiro",Windmill="Moinho",Stable="Estábulo",GuardTower="Posto da Guarda",Castle="Castelo Real",
        Barracks="Quartel",Library="Biblioteca",WatchTower="Torre de Vigia",ArcaneTower="Torre Arcana",
        MagicSchool="Escola Arcana",StaffShop="Cajados",AlchemyLab="Alquimia",Forge="Grande Forja",
        SmithGuild="Guilda dos Ferreiros",MaterialShop="Minérios",Mine="Mina",Workshop="Oficina",
        SmallHouse="Residência",MediumHouse="Casa de Artesão",LargeHouse="Solar",
    },
    Roles = {
        GuildHall="Guild", Tavern="Inn", Blacksmith="ShopWeapons",WeaponShop="ShopWeapons",MagicShop="ShopMagic",
        PotionShop="ShopPotions",ArmorShop="ShopArmor",Market="Merchant",TrainingHall="Equipment",Temple="Healer",
        Forge="ShopWeapons",SmithGuild="ShopWeapons",MaterialShop="Merchant",Mine="Quest",Workshop="Merchant",
        ArcaneTower="Mage",MagicSchool="Mage",StaffShop="ShopMagic",AlchemyLab="ShopPotions",Library="Lore",
        Barracks="Guard",GuardTower="Guard",WatchTower="Guard",Castle="Guard",Stable="Traveler",
    },
    CityDialogue = {
        Valoria = {ShopWeapons="A primeira lâmina deve servir à sua coragem, não ao seu orgulho. A guilda o espera na borda da vila.",Guild="Valoria acolhe novos viajantes. O registro é gratuito; os bandidos de Nocthar serão sua primeira prova."},
        Arkheim = {ShopWeapons="Forjamos as lâminas da guarda real. Arkheim precisa de aventureiros que protejam a estrada do norte.",Guard="O capitão mantém as muralhas, mas as runas de Malgorth inquietam os sentinelas."},
        Eldoria = {ShopMagic="A torre de Eldoria ensina controle antes de poder. O cajado oferece faísca e pulso arcano sem custo de aprendizado.",Mage="Ouça os cristais: Sylvarin ainda resiste à corrupção. Investigue as ruínas e leve seu relato à guilda."},
        Durakh = {ShopWeapons="O minério destas montanhas alimenta nossa forja. Uma arma honesta vale 500 Gold, sem negociação com a sombra.",Merchant="As caravanas de Durakh precisam das entregas da guilda; aceite a missão e traga os suprimentos até a praça."},
    },
    Dialogue = {
        Guild={Name="Maelis, Mestre da Guilda",Text="A jornada começa com um compromisso. Registre-se no Rank F, escolha sua arma no campo de treino e elimine três bandidos em Nocthar. Volte a mim para receber sua classe."},
        Inn={Name="Hospedeiro",Text="Uma cama quente e uma lareira acesa. Posso registrar seu retorno nesta cidade."},
        ShopWeapons={Name="Ferreiro",Text="Aço temperado nas forjas de Durakh. Escolha com cuidado; uma nova arma custa 500 Gold."},
        ShopMagic={Name="Arcanista",Text="O cajado canaliza duas técnicas iniciais: faísca e pulso arcano. Use os botões da interface para alternar."},
        ShopPotions={Name="Alquimista",Text="Ervas de Sylvarin, destiladas com paciência. Uma poção recupera sua vida."},
        ShopArmor={Name="Armeiro",Text="Esta couraça aumenta sua vida máxima enquanto equipada."},
        Merchant={Name="Mercador",Text="Minha caravana cruza todas as estradas. Tenho provisões para sua viagem."},
        Equipment={Name="Mestre de Armas",Text="Escolha seu primeiro equipamento gratuitamente. Após Primeiros Passos, a guilda reconhecerá sua classe."},
        Healer={Name="Sacerdotisa",Text="Descanse um instante. Posso curar suas feridas sem custo."},
        Mage={Name="Mestre Arcano",Text="As runas ao norte despertaram. Conhecimento e coragem devem caminhar juntos."},
        Guard={Name="Guarda",Text="Mantenha a estrada. Bandidos se escondem na floresta a sudoeste."},
        Traveler={Name="Viajante",Text="As pontes ligam nossas cidades. Busque a torre azul a leste e a forja no oeste."},
        Lore={Name="Bibliotecário",Text="Malgorth foi selado sob um castelo. As ruínas guardam vestígios de um juramento quebrado."},
        Quest={Name="Explorador",Text="A guilda mantém missões de caça e exploração. Confira seus objetivos e prepare-se."},
        Citizen={Name="Morador",Text="Que os sinos anunciem dias tranquilos. Nossa cidade vive do trabalho de todos."},
        Dungeon={Name="Guardião da Dungeon",Text="O Abismo exige aventureiros registrados. Grupos de até quatro devem confirmar presença junto a mim."},
    },
    Items = {
        Katana={Name="Katana",Price=500,Class="Espadachim",Damage=18,Range=11,Cooldown=0.65,Kind="Weapon"},
        Longsword={Name="Espada longa",Price=500,Class="Guerreiro",Damage=24,Range=12,Cooldown=0.9,Kind="Weapon"},
        Staff={Name="Cajado",Price=500,Class="Mago",Damage=16,Range=65,Cooldown=0.85,Kind="Weapon"},
        Bow={Name="Arco",Price=500,Class="Arqueiro",Damage=20,Range=90,Cooldown=0.9,Kind="Weapon"},
        Potion={Name="Poção",Price=30,Kind="Consumable",Heal=50},
        Armor={Name="Couraça",Price=250,Kind="Armor",Health=40},
    },
    Shops = {ShopWeapons={"Katana","Longsword","Bow"}, ShopMagic={"Staff"}, ShopPotions={"Potion"},ShopArmor={"Armor"},Merchant={"Potion"}},
    Quests = {
        FirstSteps={Name="Primeiros Passos",Target="Bandit",Required=3,Gold=180,XP=120},
        Wolves={Name="Lobos de Sylvarin",Target="Wolf",Required=5,Gold=100,XP=80},
        Ruins={Name="Memórias da Ruína",Target="Ruins",Required=1,Gold=60,XP=40},
        Herb={Name="Erva Rara",Target="Herb",Required=1,Gold=50,XP=30},
        Supplies={Name="Entrega a Durakh",Target="Supplies",Required=1,Gold=70,XP=40},
        Mage={Name="Conselho Arcano",Target="Mage",Required=1,Gold=50,XP=30},
    },
    Enemies = {
        Bandit={Name="Bandido",Health=60,Damage=7,Speed=12,Reward=12,XP=12,Color={112,72,55}},
        Wolf={Name="Lobo",Health=45,Damage=6,Speed=15,Reward=10,XP=10,Color={135,141,143}},
        Slime={Name="Slime",Health=30,Damage=4,Speed=8,Reward=8,XP=8,Color={93,199,130}},
        DarkWolf={Name="Lobo Sombrio",Health=80,Damage=10,Speed=15,Reward=18,XP=18,Color={64,59,92}},
        Skeleton={Name="Esqueleto Corrompido",Health=90,Damage=10,Speed=10,Reward=20,XP=20,Color={213,203,170}},
        Demon={Name="Soldado Demoníaco",Health=120,Damage=12,Speed=11,Reward=25,XP=25,Color={133,40,57}},
        Shadow={Name="Guardião das Sombras",Health=160,Damage=14,Speed=10,Reward=30,XP=30,Color={61,35,88}},
        Knight={Name="Cavaleiro Corrompido",Health=450,Damage=18,Speed=9,Reward=80,XP=70,Color={63,58,75}},
        Malgorth={Name="Lorde Malgorth",Health=1400,Damage=22,Speed=8,Reward=250,XP=250,Color={173,40,58}},
    },
    ChestRewards = {Common=30,Uncommon=50,Rare=90,Epic=140,Legendary=220},
    Ranks={"F","E","D","C","B","A","S"},
}

Catalog.Items.SupplyParcel={Name='Suprimentos da Guilda',Kind='Quest',Rarity='Common'}
Catalog.Items.Ore={Name='Minério de Durakh',Price=20,Kind='Material',Rarity='Common'}
Catalog.Items.Potion.Rarity='Common';Catalog.Items.Armor.Rarity='Uncommon'
for _,item in Catalog.Items do item.Rarity=item.Rarity or 'Common' end
Catalog.Enemies.SylvarinBoss={Name='Cervo Ancestral de Sylvarin',Health=800,Damage=16,Speed=12,Reward=180,XP=300,Color={64,171,124},Boss=true}
Catalog.Enemies.NoctharBoss={Name='Sentinela de Nocthar',Health=1000,Damage=18,Speed=10,Reward=200,XP=400,Color={90,47,128},Boss=true}
Catalog.Enemies.Malgorth.Boss=true
Catalog.Quests.Main02={Name='O Chamado de Arkheim',Target='Visit:Arkheim',Required=1,Gold=110,XP=200,Category='Main',Prerequisites={'FirstSteps'},Description='Investigue a corrupção e cumpra o objetivo: Visit:Arkheim.'}
Catalog.Quests.Main03={Name='O Capitão e o Selo',Target='Talk:Arkheim:Guard',Required=1,Gold=125,XP=240,Category='Main',Prerequisites={'Main02'},Description='Investigue a corrupção e cumpra o objetivo: Talk:Arkheim:Guard.'}
Catalog.Quests.Main04={Name='A Luz de Eldoria',Target='Visit:Eldoria',Required=1,Gold=140,XP=280,Category='Main',Prerequisites={'Main03'},Description='Investigue a corrupção e cumpra o objetivo: Visit:Eldoria.'}
Catalog.Quests.Main05={Name='Sussurros de Sylvarin',Target='Visit:Sylvarin',Required=1,Gold=155,XP=320,Category='Main',Prerequisites={'Main04'},Description='Investigue a corrupção e cumpra o objetivo: Visit:Sylvarin.'}
Catalog.Quests.Main06={Name='Lobos nas Trilhas',Target='Wolf',Required=3,Gold=170,XP=360,Category='Main',Prerequisites={'Main05'},Description='Investigue a corrupção e cumpra o objetivo: Wolf.'}
Catalog.Quests.Main07={Name='O Guardião Ancestral',Target='SylvarinBoss',Required=1,Gold=185,XP=400,Category='Main',Prerequisites={'Main06'},Description='Investigue a corrupção e cumpra o objetivo: SylvarinBoss.'}
Catalog.Quests.Main08={Name='Ferro contra a Sombra',Target='Visit:Durakh',Required=1,Gold=200,XP=440,Category='Main',Prerequisites={'Main07'},Description='Investigue a corrupção e cumpra o objetivo: Visit:Durakh.'}
Catalog.Quests.Main09={Name='Suprimentos para Durakh',Target='Supplies',Required=1,Gold=215,XP=480,Category='Main',Prerequisites={'Main08'},Description='Investigue a corrupção e cumpra o objetivo: Supplies.'}
Catalog.Quests.Main10={Name='A Queda de Nocthar',Target='Bandit',Required=3,Gold=230,XP=520,Category='Main',Prerequisites={'Main09'},Description='Investigue a corrupção e cumpra o objetivo: Bandit.'}
Catalog.Quests.Main11={Name='O Sentinela Corrompido',Target='NoctharBoss',Required=1,Gold=245,XP=560,Category='Main',Prerequisites={'Main10'},Description='Investigue a corrupção e cumpra o objetivo: NoctharBoss.'}
Catalog.Quests.Main12={Name='O Conselho Arcano',Target='Mage',Required=1,Gold=260,XP=600,Category='Main',Prerequisites={'Main11'},Description='Investigue a corrupção e cumpra o objetivo: Mage.'}
Catalog.Quests.Main13={Name='As Ruínas do Juramento',Target='Ruins',Required=1,Gold=275,XP=640,Category='Main',Prerequisites={'Main12'},Description='Investigue a corrupção e cumpra o objetivo: Ruins.'}
Catalog.Quests.Main14={Name='O Cavaleiro do Abismo',Target='Knight',Required=1,Gold=290,XP=680,Category='Main',Prerequisites={'Main13'},Description='Investigue a corrupção e cumpra o objetivo: Knight.'}
Catalog.Quests.Main15={Name='Lorde Malgorth',Target='Malgorth',Required=1,Gold=305,XP=720,Category='Main',Prerequisites={'Main14'},Description='Investigue a corrupção e cumpra o objetivo: Malgorth.'}
Catalog.Quests.FirstSteps.Category='Main'
Catalog.Quests.Wolves.Category='Side'
Catalog.Quests.Ruins.Category='Side'
Catalog.Quests.Herb.Category='Side'
Catalog.Quests.Supplies.Category='Side'
Catalog.Quests.Mage.Category='Side'
Catalog.Quests.Side01={Name='Patrulha Real',Target='Visit:Arkheim',Required=1,Gold=58,XP=75,Category='Side'}
Catalog.Quests.Side02={Name='Ferro de Durakh',Target='Visit:Durakh',Required=1,Gold=66,XP=90,Category='Side'}
Catalog.Quests.Side03={Name='Caminho Arcano',Target='Visit:Eldoria',Required=1,Gold=74,XP=105,Category='Side'}
Catalog.Quests.Side04={Name='Paz em Valoria',Target='Visit:Valoria',Required=1,Gold=82,XP=120,Category='Side'}
Catalog.Quests.Side05={Name='O Bosque Vivo',Target='Visit:Sylvarin',Required=1,Gold=90,XP=135,Category='Side'}
Catalog.Quests.Side06={Name='Sombras Distantes',Target='Visit:Nocthar',Required=1,Gold=98,XP=150,Category='Side'}
Catalog.Quests.Side07={Name='Bandidos da Estrada',Target='Bandit',Required=3,Gold=106,XP=165,Category='Side'}
Catalog.Quests.Side08={Name='Caça aos Lobos',Target='Wolf',Required=3,Gold=114,XP=180,Category='Side'}
Catalog.Quests.Side09={Name='Geleias Verdes',Target='Slime',Required=3,Gold=122,XP=195,Category='Side'}
Catalog.Quests.Side10={Name='Ossos Antigos',Target='Skeleton',Required=3,Gold=130,XP=210,Category='Side'}
Catalog.Quests.Side11={Name='Guarda Demoníaca',Target='Demon',Required=3,Gold=138,XP=225,Category='Side'}
Catalog.Quests.Side12={Name='Lembranças de Pedra',Target='Ruins',Required=1,Gold=146,XP=240,Category='Side'}
Catalog.Quests.Side13={Name='Coleta Verde',Target='Herb',Required=1,Gold=154,XP=255,Category='Side'}
Catalog.Quests.Side14={Name='Palavras de Sabedoria',Target='Mage',Required=1,Gold=162,XP=270,Category='Side'}
Catalog.Quests.Side15={Name='O Cavaleiro Caído',Target='Knight',Required=1,Gold=170,XP=285,Category='Side'}
local objectives={Bandit='Derrote bandidos em Nocthar para proteger as caravanas.',Wolf='Derrote lobos em Sylvarin sem perder de vista as trilhas.',Slime='Controle os slimes nas clareiras de Sylvarin.',Skeleton='Derrote esqueletos nas regiões corrompidas.',Demon='Derrote soldados no interior do Abismo.',Knight='Derrote o Cavaleiro Corrompido na antecâmara.',Malgorth='Derrote Lorde Malgorth e encerre a ameaça ao continente.',SylvarinBoss='Enfrente o guardião ancestral na clareira de Sylvarin.',NoctharBoss='Derrote o sentinela nas ruínas de Nocthar.',Mage='Converse com um mestre arcano em Eldoria.',Ruins='Investigue um altar nas ruínas florestais.',Herb='Colete erva rara junto às clareiras.',Supplies='Receba o pacote ao aceitar e entregue-o no marco de suprimentos da praça de Durakh.'}
for _,q in Catalog.Quests do
 q.Description=objectives[q.Target] or (if string.sub(q.Target,1,6)=='Visit:' then 'Explore '..string.sub(q.Target,7)..' e reconheça a região.' else 'Converse com a guarda de Arkheim para receber as ordens do capitão.')
end
return Catalog
