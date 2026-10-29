-- Configuração sem dependências do engine: compartilhada com os testes CLI.
return table.freeze({
    Audio = {Impact='',Cast='',Dodge=''}, -- Somente IDs reais próprios após upload.
    MaxCombatFX = 20,
    EnableStudioTester = false, -- opt-in, somente Studio sem persistência; nunca concede ao perfil real.
    ProjectId = "ProjectMedievalRPG",
    SchemaVersion = 4,
    LayoutRevision = "AuthoredContinent-01",
    WorldSize = 4000,
    Seed = 12345,
    Quality = "LOW",
    Resolution = 4, -- Terrain exige voxels de 4 studs.
    ChunkSize = 128,
    MinY = -32,
    MaxY = 192,
    BaseHeight = 40,
    Amplitude = 36,
    Frequency = 0.0018,
    MountainHeight = 62,
    CityBlend = 100,
    MaxChunks = 4096,
    DungeonPlaceId = 0, -- Configure com ID real do segundo Place.
    ReturnPlaceId = 0,
    EnableDataStore = true, -- Identidade permanente requer gravação confirmada; modo volátil não sorteia raça.
    StudioDungeonTest = true,
    DayLengthSeconds = 1200,
    -- Authored control points: sampled as smooth curves by TerrainMath.roadPaths.
    -- Explicit heights keep grades bounded while the terrain blends to each route.
    Roads = {
        {Id="RoyalRoad",A={X=0,Z=1000,H=44},B={X=0,Z=-850,H=48},Points={{X=0,Z=1000,H=44},{X=0,Z=610,H=44},{X=120,Z=460,H=46},{X=-110,Z=50,H=47},{X=-150,Z=-350,H=54},{X=0,Z=-430,H=48},{X=0,Z=-850,H=48}}},
        {Id="ArcaneRoad",A={X=0,Z=1000,H=44},B={X=1150,Z=-150,H=48},Points={{X=0,Z=1000,H=44},{X=0,Z=610,H=44},{X=620,Z=520,H=51},{X=850,Z=350,H=48},{X=1150,Z=230,H=48},{X=1150,Z=-150,H=48}}},
        {Id="ForgeRoad",A={X=0,Z=1000,H=44},B={X=-1150,Z=-150,H=52},Points={{X=0,Z=1000,H=44},{X=0,Z=610,H=44},{X=-680,Z=520,H=55},{X=-680,Z=170,H=56},{X=-780,Z=-150,H=52},{X=-1150,Z=-150,H=52}}},
        {Id="AbyssRoad",A={X=0,Z=-850,H=48},B={X=0,Z=-1700,H=48},Points={{X=0,Z=-850,H=48},{X=0,Z=-1270,H=48},{X=-75,Z=-1490,H=52},{X=0,Z=-1700,H=48}}},
        {Id="SylvarinTrail",A={X=1150,Z=-150,H=48},B={X=1100,Z=-1100,H=44},Width=12,Points={{X=1150,Z=-150,H=48},{X=1150,Z=-530,H=48},{X=1260,Z=-700,H=51},{X=1010,Z=-790,H=49},{X=1100,Z=-1100,H=44}}},
        {Id="NoctharTrail",A={X=-1150,Z=-150,H=52},B={X=-1000,Z=1000,H=44},Width=12,Points={{X=-1150,Z=-150,H=52},{X=-1150,Z=220,H=52},{X=-1320,Z=400,H=58},{X=-1190,Z=620,H=51},{X=-1000,Z=1000,H=44}}},
        {Id="AsterionRoad",A={X=0,Z=1000,H=44},B={X=1150,Z=1200,H=64},Points={{X=0,Z=1000,H=44},{X=370,Z=1000,H=48},{X=620,Z=1070,H=58},{X=750,Z=1200,H=64},{X=1150,Z=1200,H=64}}},
        {Id="GuildRoad",A={X=0,Z=1000,H=44},B={X=0,Z=1480,H=44},Width=16,Points={{X=0,Z=1000,H=44},{X=0,Z=1370,H=44},{X=0,Z=1480,H=44}}},
        {Id="VesperaTrail",A={X=-1150,Z=-150,H=52},B={X=-1080,Z=-1170,H=60},Width=12,Points={{X=-1150,Z=-150,H=52},{X=-1150,Z=-520,H=52},{X=-1240,Z=-810,H=64},{X=-1080,Z=-1170,H=60}}},
        {Id="SanctumTrail",A={X=-1080,Z=-1170,H=60},B={X=-900,Z=-1680,H=64},Width=12,Points={{X=-1080,Z=-1170,H=60},{X=-1190,Z=-1390,H=64},{X=-1010,Z=-1520,H=66},{X=-900,Z=-1680,H=64}}},
    },
    MountainRanges = {
        {Id="DorsalDasForjas",A={X=-1740,Z=1550},B={X=-1690,Z=-1540},Width=230,Height=62},
        {Id="CoroaSetentrional",A={X=-1720,Z=-1790},B={X=1700,Z=-1760},Width=185,Height=58},
        {Id="AgulhasCelestes",A={X=1710,Z=-1330},B={X=1740,Z=1140},Width=170,Height=50},
    },
    Valleys = {
        {A={X=-1650,Z=710},B={X=1500,Z=440},Width=170,Depth=8},
        {A={X=300,Z=-1300},B={X=620,Z=1100},Width=120,Depth=6},
    },
    River = { Z=300, Meander=70, Frequency=1/450, HalfWidth=16, BankWidth=40, WaterY=32, BedY=22 },
    Lake = {X=1550,Z=600,Radius=80,Bank=128,WaterY=32,BedY=20},
    AdditionalLakes = {
        {Id="AlpineMirror",X=-1450,Z=-1350,Radius=52,Bank=96,WaterY=64,BedY=52},
        {Id="SouthMere",X=-420,Z=1570,Radius=70,Bank=44,WaterY=32,BedY=22},
    },
    ScenicReservations = {
        {Id="MalgorthGate",X=0,Z=-1700,Radius=90,Height=48},
        {Id="SanctumGate",X=-900,Z=-1680,Radius=90,Height=64},
        {Id="SylvarinCave",X=1108,Z=-1040,Radius=30,Blend=32,Height=44},
        {Id="NoctharCave",X=-992,Z=1060,Radius=30,Blend=32,Height=44},
        {Id="VesperaCave",X=-1072,Z=-1110,Radius=30,Blend=32,Height=60},
        {Id="MeadowCamp",X=440,Z=1250,Radius=70,Height=51},
        {Id="MossVillage",X=1520,Z=-600,Radius=70,Height=65},
        {Id="BrokenWatch",X=-1550,Z=480,Radius=70,Height=70},
        {Id="RoyalOverlook",X=440,Z=-1450,Radius=35,Height=54},
        {Id="HiddenSanctuary",X=-520,Z=-1390,Radius=40,Height=48},
    },
    Cities = {
        { Id = "Valoria", Name = "Valoria • Cidade da Aurora", Theme = "Crown", X = 0, Z = 1000, Radius = 360, Height = 44 },
        { Id = "Arkheim", Name = "Arkheim • Vigília das Sombras", Theme = "Gothic", X = 0, Z = -850, Radius = 380, Height = 48 },
        { Id = "Eldoria", Name = "Eldoria • Cidade das Raízes", Theme = "Forest", X = 1150, Z = -150, Radius = 360, Height = 48 },
        { Id = "Durakh", Name = "Durakh • Coração das Montanhas", Theme = "Mountain", X = -1150, Z = -150, Radius = 360, Height = 52 },
        { Id = "Asterion", Name = "Asterion • Coroa Celeste", Theme = "Arcane", X = 1150, Z = 1200, Radius = 360, Height = 64 },
    },
    Forests = {
        { Id = "Sylvarin", Name = "Sylvarin • Bosque Esmeralda", Theme = "Emerald", X = 1100, Z = -1100, Radius = 400 },
        { Id = "Nocthar", Name = "Nocthar • Floresta dos Ancestrais", Theme = "Ancient", X = -1000, Z = 1000, Radius = 400 },
        { Id = "Vespera", Name = "Véspera • Floresta Sombria", Theme = "Shadow", X = -1080, Z = -1170, Radius = 390 },
    },
    DungeonEntrance = { X = 0, Z = -1700 },
    SecondDungeonEntrance = {X=-900,Z=-1680},
    Guild = {X=0,Z=1480,Height=44},
    QualityProfiles = {
        LOW = { TreesPerForest = 160, DecorationBudget = 200, ActiveEnemies = 16 },
        MEDIUM = { TreesPerForest = 240, DecorationBudget = 400, ActiveEnemies = 24 },
        HIGH = { TreesPerForest = 360, DecorationBudget = 700, ActiveEnemies = 32 },
    },
})
