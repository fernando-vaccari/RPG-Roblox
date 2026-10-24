$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
Push-Location $root
try {
    $bin = Join-Path $root '.tools/bin'
    $files = @(Get-ChildItem src,tests -Recurse -Filter '*.luau') + @(Get-ChildItem scripts -Filter '*.luau')
    foreach ($file in $files) {
        & (Join-Path $bin 'luau-compile.exe') $file.FullName | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "Compilação falhou: $($file.FullName)" }
    }
    $pure = @(Get-ChildItem src/shared/Core,src/shared/Config -Filter '*.luau') + @(Get-Item src/worldgen/TerrainMath.luau,src/worldgen/WorldPlan.luau)
    $purePaths = @($pure | ForEach-Object { $_.FullName })
    & (Join-Path $bin 'luau-analyze.exe') @purePaths
    if ($LASTEXITCODE -ne 0) { throw 'Análise de regras puras falhou' }
    foreach ($test in Get-ChildItem tests -Filter '*.spec.luau') {
        & (Join-Path $bin 'luau.exe') $test.FullName
        if ($LASTEXITCODE -ne 0) { throw "Teste falhou: $($test.Name)" }
    }
    New-Item -ItemType Directory -Force build | Out-Null
    & (Join-Path $bin 'rojo.exe') build default.project.json --output build/ProjectMedievalRPG.rbxlx
    if ($LASTEXITCODE -ne 0) { throw 'Build continente falhou' }
    & (Join-Path $bin 'rojo.exe') build dungeon.project.json --output build/ProjectMedievalRPG_Dungeon.rbxlx
    if ($LASTEXITCODE -ne 0) { throw 'Build dungeon falhou' }
    & (Join-Path $bin 'rojo.exe') sourcemap default.project.json --output build/sourcemap.json
    if ($LASTEXITCODE -ne 0) { throw 'Sourcemap Rojo falhou' }
    Write-Host 'Testes CLI e builds concluídos. Engine Roblox não testado por este comando.'
    Write-Host 'Integração simulada opcional (requer Python 3): py scripts/integration.py'
} finally { Pop-Location }
