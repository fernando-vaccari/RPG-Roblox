-- Configuração sem dependências do engine: compartilhada com os testes CLI.
return table.freeze({
    Audio = {Impact='',Cast='',Dodge=''}, -- Somente IDs reais próprios após upload.
    MaxCombatFX = 20,
    EnableStudioTester = false, -- opt-in, somente Studio sem persistência; nunca concede ao perfil real.
    ProjectId = "ProjectMedievalRPG",
    SchemaVersion = 3,
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
        { Id="AsterionRoad", A={X=0,Z=1000,H=44}, B={X=1150,Z=1200,H=64} },
        { Id="GuildRoad", A={X=0,Z=1000,H=44}, B={X=0,Z=1480,H=44} },
        { Id="VesperaTrail", A={X=-1150,Z=-150,H=52}, B={X=-1080,Z=-1170,H=60} },
        { Id="SanctumTrail", A={X=-1080,Z=-1170,H=60}, B={X=-900,Z=-1680,H=64} },
    },
    River = { Z=300, Meander=70, Frequency=1/450, HalfWidth=16, BankWidth=40, WaterY=32, BedY=22 },
    Lake = {X=1550,Z=600,Radius=80,Bank=64,WaterY=32,BedY=20},
    Cities = {
        { Id = "Valoria", Name = "Valoria • Cidade da Aurora", X = 0, Z = 1000, Radius = 330, Height = 44 },
        { Id = "Arkheim", Name = "Arkheim • Bastião Real", X = 0, Z = -850, Radius = 380, Height = 48 },
        { Id = "Eldoria", Name = "Eldoria • Cidade das Raízes", X = 1150, Z = -150, Radius = 340, Height = 48 },
        { Id = "Durakh", Name = "Durakh • Cidade das Caravanas", X = -1150, Z = -150, Radius = 330, Height = 52 },
        { Id = "Asterion", Name = "Asterion • Coroa Celeste", X = 1150, Z = 1200, Radius = 360, Height = 64 },
    },
    Forests = {
        { Id = "Sylvarin", Name = "Bosque de Sylvarin", X = 1100, Z = -1100, Radius = 400 },
        { Id = "Nocthar", Name = "Floresta de Nocthar", X = -1000, Z = 1000, Radius = 400 },
        { Id = "Vespera", Name = "Véspera • Floresta do Eclipse", X = -1080, Z = -1170, Radius = 390 },
    },
    DungeonEntrance = { X = 0, Z = -1700 },
    SecondDungeonEntrance = {X=-900,Z=-1680},
    Guild = {X=0,Z=1480,Height=44},
    QualityProfiles = {
        LOW = { TreesPerForest = 100, DecorationBudget = 200, ActiveEnemies = 16 },
        MEDIUM = { TreesPerForest = 200, DecorationBudget = 400, ActiveEnemies = 24 },
        HIGH = { TreesPerForest = 350, DecorationBudget = 700, ActiveEnemies = 32 },
    },
})
