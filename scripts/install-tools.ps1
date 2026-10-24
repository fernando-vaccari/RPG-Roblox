$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$dest = Join-Path $root '.tools/bin'
New-Item -ItemType Directory -Force $dest | Out-Null
$assets = @(
    @{ Repo='rojo-rbx/rojo'; Tag='v7.7.1'; File='rojo-7.7.1-windows-x86_64.zip'; Hash='d4dfa3493a1613a43fc87312d6dac660d7c8bf38e6a99aa5dcd0d26154ba0b82'; Names=@('rojo.exe') },
    @{ Repo='luau-lang/luau'; Tag='0.744'; File='luau-windows.zip'; Hash='fde3e22c557aac6afe20a34e8050b7d8c290fa42638c04274a307ed5d0ef0db8'; Names=@('luau.exe','luau-analyze.exe','luau-compile.exe') }
)
foreach ($asset in $assets) {
    $temp = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
    New-Item -ItemType Directory $temp | Out-Null
    try {
        $zip = Join-Path $temp 'asset.zip'
        Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/$($asset.Repo)/releases/download/$($asset.Tag)/$($asset.File)" -OutFile $zip
        if ((Get-FileHash $zip -Algorithm SHA256).Hash.ToLowerInvariant() -ne $asset.Hash) { throw 'SHA-256 inválido. Instalação interrompida.' }
        Expand-Archive $zip (Join-Path $temp 'unpacked')
        foreach ($name in $asset.Names) {
            $found = @(Get-ChildItem (Join-Path $temp 'unpacked') -Recurse -Filter $name)
            if ($found.Count -ne 1) { throw "Binário ausente/ambíguo: $name" }
            Copy-Item $found[0].FullName (Join-Path $dest $name) -Force
        }
        Write-Host "Instalado e verificado: $($asset.Repo) $($asset.Tag)"
    } finally { Remove-Item $temp -Recurse -Force }
}
