-- Continente monumental de 6.144 studs: novas áreas, mantendo os IDs do RPG.
-- Coordenadas horizontais ampliadas; casas, portas e alturas continuam em escala de avatar.
return table.freeze({
    Audio = {Impact='',Cast='',Dodge=''}, -- Somente IDs reais próprios após upload.
    MaxCombatFX = 20,
    EnableStudioTester = false, -- opt-in, somente Studio sem persistência; nunca concede ao perfil real.
    ProjectId = "ProjectMedievalRPG",
    SchemaVersion = 4,
    LayoutRevision = "MonumentalContinent-03-6144",
    MonumentalMap = true,
    WorldSize = 6144,
    Seed = 12345,
    Quality = "LOW",
    Resolution = 4, -- Terrain exige voxels de 4 studs.
    ChunkSize = 128,
    MinY = -32,
    MaxY = 192,
    BaseHeight = 40,
    Amplitude = 36,
    Frequency = 0.0012,
    MountainHeight = 62,
    CityBlend = 120,
    MaxChunks = 4096,
    DungeonPlaceId = 0, -- Configure com ID real do segundo Place.
    ReturnPlaceId = 0,
    EnableDataStore = true, -- Identidade permanente requer gravação confirmada; modo volátil não sorteia raça.
    StudioDungeonTest = true,
    DayLengthSeconds = 1200,
    -- Authored control points: sampled as smooth curves by TerrainMath.roadPaths.
    -- Explicit heights keep grades bounded while the terrain blends to each route.
    Roads = {
        {Id="RoyalRoad",A={X=0,Z=1500,H=44},B={X=0,Z=-1275,H=48},Points={{X=0,Z=1500,H=44},{X=0,Z=915,H=44},{X=180,Z=690,H=46},{X=-165,Z=75,H=47},{X=-225,Z=-525,H=54},{X=0,Z=-645,H=48},{X=0,Z=-1275,H=48}}},
        {Id="ArcaneRoad",A={X=0,Z=1500,H=44},B={X=1725,Z=-225,H=48},Points={{X=0,Z=1500,H=44},{X=0,Z=915,H=44},{X=930,Z=780,H=51},{X=1275,Z=525,H=48},{X=1725,Z=345,H=48},{X=1725,Z=-225,H=48}}},
        {Id="ForgeRoad",A={X=0,Z=1500,H=44},B={X=-1725,Z=-225,H=52},Points={{X=0,Z=1500,H=44},{X=0,Z=915,H=44},{X=-1020,Z=780,H=55},{X=-1020,Z=255,H=56},{X=-1170,Z=-225,H=52},{X=-1725,Z=-225,H=52}}},
        {Id="AbyssRoad",A={X=0,Z=-1275,H=48},B={X=0,Z=-2550,H=48},Points={{X=0,Z=-1275,H=48},{X=0,Z=-1905,H=48},{X=-112.5,Z=-2235,H=52},{X=0,Z=-2550,H=48}}},
        {Id="SylvarinTrail",A={X=1725,Z=-225,H=48},B={X=1650,Z=-1650,H=44},Width=12,Points={{X=1725,Z=-225,H=48},{X=1725,Z=-795,H=48},{X=1890,Z=-1050,H=51},{X=1515,Z=-1185,H=49},{X=1650,Z=-1650,H=44}}},
        {Id="NoctharTrail",A={X=-1725,Z=-225,H=52},B={X=-1500,Z=1500,H=44},Width=12,Points={{X=-1725,Z=-225,H=52},{X=-1725,Z=330,H=52},{X=-1980,Z=600,H=58},{X=-1785,Z=930,H=51},{X=-1500,Z=1500,H=44}}},
        {Id="AsterionRoad",A={X=0,Z=1500,H=44},B={X=1725,Z=1800,H=64},Points={{X=0,Z=1500,H=44},{X=0,Z=2355,H=44},{X=750,Z=2505,H=50},{X=1140,Z=2295,H=64},{X=1725,Z=1800,H=64}}},
        {Id="GuildRoad",A={X=0,Z=1500,H=44},B={X=0,Z=2535,H=44},Width=16,Points={{X=0,Z=1500,H=44},{X=0,Z=2355,H=44},{X=0,Z=2535,H=44}}},
        {Id="VesperaTrail",A={X=-1725,Z=-225,H=52},B={X=-1620,Z=-1755,H=60},Width=12,Points={{X=-1725,Z=-225,H=52},{X=-1725,Z=-780,H=52},{X=-1860,Z=-1215,H=64},{X=-1620,Z=-1755,H=60}}},
        {Id="SanctumTrail",A={X=-1620,Z=-1755,H=60},B={X=-1350,Z=-2520,H=64},Width=12,Points={{X=-1620,Z=-1755,H=60},{X=-1785,Z=-2085,H=64},{X=-1515,Z=-2280,H=66},{X=-1350,Z=-2520,H=64}}},
    },
    MountainRanges = {
        {Id="DorsalDasForjas",A={X=-2610,Z=2325},B={X=-2535,Z=-2310},Width=345,Height=62},
        {Id="CoroaSetentrional",A={X=-2580,Z=-2685},B={X=2550,Z=-2640},Width=277.5,Height=58},
        {Id="AgulhasCelestes",A={X=2565,Z=-1995},B={X=2610,Z=1710},Width=255,Height=50},
    },
    Valleys = {
        {A={X=-2475,Z=1065},B={X=2250,Z=660},Width=255,Depth=8},
        {A={X=450,Z=-1950},B={X=930,Z=1650},Width=180,Depth=6},
    },
    River = { Z=450, Meander=105, Frequency=1/675, HalfWidth=24, BankWidth=60, WaterY=32, BedY=22 },
    Lake = {X=2325,Z=900,Radius=120,Bank=192,WaterY=32,BedY=20},
    AdditionalLakes = {
        {Id="AlpineMirror",X=-2175,Z=-2025,Radius=78,Bank=144,WaterY=64,BedY=52},
        {Id="SouthMere",X=-630,Z=2355,Radius=105,Bank=66,WaterY=32,BedY=22},
    },
    ScenicReservations = {
        {Id="MalgorthGate",X=0,Z=-2550,Radius=135,Height=48},
        {Id="SanctumGate",X=-1350,Z=-2520,Radius=135,Height=64},
        {Id="SylvarinCave",X=1662,Z=-1560,Radius=45,Blend=32,Height=44},
        {Id="NoctharCave",X=-1488,Z=1590,Radius=45,Blend=32,Height=44},
        {Id="VesperaCave",X=-1608,Z=-1665,Radius=45,Blend=32,Height=60},
        {Id="MeadowCamp",X=1200,Z=2750,Radius=105,Height=51},
        {Id="MossVillage",X=2280,Z=-900,Radius=105,Height=65},
        {Id="BrokenWatch",X=-2325,Z=720,Radius=105,Height=70},
        {Id="RoyalOverlook",X=660,Z=-2175,Radius=52.5,Height=54},
        {Id="HiddenSanctuary",X=-780,Z=-2085,Radius=60,Height=48},
    },
    Cities = {
        { Id = "Valoria", Name = "Valoria • Cidade da Aurora", Theme = "Crown", X=0, Z=1500, Radius=840, Height = 44 },
        { Id = "Arkheim", Name = "Arkheim • Vigília das Sombras", Theme = "Gothic", X=0, Z=-1275, Radius=660, Height = 48 },
        { Id = "Eldoria", Name = "Eldoria • Cidade das Raízes", Theme = "Forest", X=1725, Z=-225, Radius=630, Height = 48 },
        { Id = "Durakh", Name = "Durakh • Coração das Montanhas", Theme = "Mountain", X=-1725, Z=-225, Radius=630, BoundaryBlend=210, Height = 52 },
        { Id = "Asterion", Name = "Asterion • Coroa Celeste", Theme = "Arcane", X=1725, Z=1800, Radius=630, Height = 64 },
    },
    Forests = {
        { Id = "Sylvarin", Name = "Sylvarin • Bosque Esmeralda", Theme = "Emerald", X=1650, Z=-1650, Radius=780 },
        { Id = "Nocthar", Name = "Nocthar • Floresta dos Ancestrais", Theme = "Ancient", X=-1500, Z=1500, Radius=810 },
        { Id = "Vespera", Name = "Véspera • Floresta Sombria", Theme = "Shadow", X=-1620, Z=-1755, Radius=750 },
    },
    DungeonEntrance = { X=0, Z=-2550 },
    SecondDungeonEntrance = {X=-1350,Z=-2520},
    Guild = {X=0,Z=2535,Height=44},
    QualityProfiles = {
        LOW = { TreesPerForest = 480, DecorationBudget = 200, ActiveEnemies = 16 },
        MEDIUM = { TreesPerForest = 720, DecorationBudget = 400, ActiveEnemies = 24 },
        HIGH = { TreesPerForest = 1000, DecorationBudget = 700, ActiveEnemies = 32 },
    },
})
