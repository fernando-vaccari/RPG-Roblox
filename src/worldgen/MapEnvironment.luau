-- Environment inspection presets; no time simulation or weather gameplay.
local Environment={}
local presets={
    Dawn={Time=6.4,Brightness=1.7,Exposure=0.02,Density=0.24,Haze=1.3,Color={238,203,168},Decay={134,147,179},Ambient={102,87,119},Outdoor={150,132,142}},
    Day={Time=10.5,Brightness=2.2,Exposure=0.03,Density=0.19,Haze=0.8,Color={202,222,239},Decay={133,155,180},Ambient={88,91,111},Outdoor={143,151,164}},
    Sunset={Time=17.65,Brightness=1.8,Exposure=0.02,Density=0.26,Haze=1.4,Color={246,190,145},Decay={146,116,156},Ambient={109,81,112},Outdoor={162,127,137}},
    Night={Time=0.6,Brightness=1.15,Exposure=-0.03,Density=0.23,Haze=1.1,Color={126,146,183},Decay={64,79,123},Ambient={59,63,90},Outdoor={85,96,126}},
    Rain={Time=13.5,Brightness=1.45,Exposure=-0.04,Density=0.31,Haze=1.8,Color={161,181,192},Decay={108,127,147},Ambient={89,101,119},Outdoor={127,143,155}},
    Fog={Time=7.2,Brightness=1.65,Exposure=0,Density=0.43,Haze=2.7,Color={200,212,205},Decay={149,164,162},Ambient={104,117,123},Outdoor={151,165,164}},
    Storm={Time=15.4,Brightness=1.2,Exposure=-0.08,Density=0.35,Haze=2.2,Color={140,157,177},Decay={78,94,126},Ambient={71,80,105},Outdoor={103,119,143}},
}
local function effect(lighting,class,name)
    local item=lighting:FindFirstChild(name)
    assert(not item or item:IsA(class),'Objeto de iluminação reservado com classe incorreta: '..name)
    if not item then item=Instance.new(class);item.Name=name;item.Parent=lighting end
    return item
end
local function rgb(values)return Color3.fromRGB(table.unpack(values))end
function Environment.apply(name)
    local p=presets[name]
    assert(p,'Preset visual desconhecido')
    local lighting=game:GetService('Lighting')
    lighting.ClockTime=p.Time;lighting.Brightness=p.Brightness;lighting.ExposureCompensation=p.Exposure
    lighting.Ambient=rgb(p.Ambient);lighting.OutdoorAmbient=rgb(p.Outdoor)
    lighting.GlobalShadows=true;lighting.EnvironmentDiffuseScale=0.55;lighting.EnvironmentSpecularScale=0.38
    lighting.ShadowSoftness=0.5
    local atmosphere=effect(lighting,'Atmosphere','EldravynMapAtmosphere')
    atmosphere.Density=p.Density;atmosphere.Haze=p.Haze;atmosphere.Offset=0.12
    atmosphere.Color=rgb(p.Color);atmosphere.Decay=rgb(p.Decay);atmosphere.Glare=0.1
    local bloom=effect(lighting,'BloomEffect','EldravynMapBloom')
    bloom.Intensity=0.075;bloom.Size=18;bloom.Threshold=1.5
    local grade=effect(lighting,'ColorCorrectionEffect','EldravynMapGrade')
    grade.Saturation=0.07;grade.Contrast=0.08;grade.Brightness=0
    local sun=effect(lighting,'SunRaysEffect','EldravynMapSunRays')
    sun.Intensity=if name=='Day' or name=='Dawn' or name=='Sunset' then 0.025 else 0
    sun.Spread=0.65
    local sky=effect(lighting,'Sky','EldravynMapSky')
    sky.CelestialBodiesShown=true;sky.StarCount=1800;sky.SunAngularSize=9;sky.MoonAngularSize=6
    lighting:SetAttribute('MapEnvironmentPreset',name)
    workspace:SetAttribute('MapEnvironmentPreset',name)
    return name
end
return Environment
