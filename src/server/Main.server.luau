-- Runtime: inicializa serviços. NUNCA gera o continente ao entrar um jogador.
local RS=game:GetService('ReplicatedStorage')
local shared=RS:WaitForChild('MedievalRPG')
local remotes=Instance.new('Folder');remotes.Name='Remotes';remotes.Parent=shared
local action=Instance.new('RemoteEvent');action.Name='Action';action.Parent=remotes
local effects=Instance.new('RemoteEvent');effects.Name='Effects';effects.Parent=remotes
require(script.Parent.Services.GameService).start(action,effects)
local config=require(shared.Config.WorldConfig)
local Lighting=game:GetService('Lighting')
local function ownedEffect(class,name)
    local effect=Lighting:FindFirstChild(name)
    if not effect then effect=Instance.new(class);effect.Name=name;effect.Parent=Lighting end
    return effect
end
local atmosphere=ownedEffect('Atmosphere','MedievalAtmosphere');atmosphere.Density=0.2;atmosphere.Haze=1
local bloom=ownedEffect('BloomEffect','MedievalBloom');bloom.Intensity=0.12;bloom.Size=14;bloom.Threshold=1.4
local grade=ownedEffect('ColorCorrectionEffect','MedievalGrade');grade.Saturation=0.08;grade.Contrast=0.03
-- Um único relógio global; neblina por região é feita localmente pelo client.
task.spawn(function()
    while task.wait(1) do Lighting.ClockTime=(Lighting.ClockTime+24/math.max(60,config.DayLengthSeconds))%24 end
end)
print('[MedievalRPG] Runtime iniciado. Sem geração automática de Terrain.')
