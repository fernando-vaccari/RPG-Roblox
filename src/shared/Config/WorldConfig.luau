-- Configuração sem dependências do engine: compartilhada com os testes CLI.
return table.freeze({
    Audio = {Impact='',Cast='',Dodge=''}, -- Somente IDs reais próprios após upload.
    MaxCombatFX = 20,
    EnableStudioTester = false, -- opt-in, somente Studio sem persistência; nunca concede ao perfil real.
    ProjectId = "ProjectMedievalRPG",
    SchemaVersion = 2,
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
    Roads = {
        { Id="RoyalRoad", A={X=0,Z=1000,H=44}, B={X=0,Z=-850,H=48} },
        { Id="ArcaneRoad", A={X=0,Z=1000,H=44}, B={X=1150,Z=-150,H=48} },
        { Id="ForgeRoad", A={X=0,Z=1000,H=44}, B={X=-1150,Z=-150,H=52} },
        { Id="AbyssRoad", A={X=0,Z=-850,H=48}, B={X=0,Z=-1700,H=48} },
        { Id="SylvarinTrail", A={X=1150,Z=-150,H=48}, B={X=1100,Z=-1100,H=44} },
        { Id="NoctharTrail", A={X=-1150,Z=-150,H=52}, B={X=-1000,Z=1000,H=44} },
    },
    River = { Z=300, Meander=70, Frequency=1/450, HalfWidth=16, BankWidth=40, WaterY=32, BedY=22 },
    Cities = {
        { Id = "Valoria", Name = "Vila de Valoria", X = 0, Z = 1000, Radius = 240, Height = 44 },
        { Id = "Arkheim", Name = "Reino de Arkheim", X = 0, Z = -850, Radius = 320, Height = 48 },
        { Id = "Eldoria", Name = "Eldoria", X = 1150, Z = -150, Radius = 240, Height = 48 },
        { Id = "Durakh", Name = "Durakh", X = -1150, Z = -150, Radius = 240, Height = 52 },
    },
    Forests = {
        { Id = "Sylvarin", Name = "Bosque de Sylvarin", X = 1100, Z = -1100, Radius = 400 },
        { Id = "Nocthar", Name = "Floresta de Nocthar", X = -1000, Z = 1000, Radius = 400 },
    },
    DungeonEntrance = { X = 0, Z = -1700 },
    QualityProfiles = {
        LOW = { TreesPerForest = 100, DecorationBudget = 200, ActiveEnemies = 16 },
        MEDIUM = { TreesPerForest = 200, DecorationBudget = 400, ActiveEnemies = 24 },
        HIGH = { TreesPerForest = 350, DecorationBudget = 700, ActiveEnemies = 32 },
    },
})
