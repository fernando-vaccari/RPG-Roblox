#!/usr/bin/env python3
"""Pinned official tools for Linux x86_64, TLS and upstream SHA-256 checked."""
import hashlib
import io
import os
from pathlib import Path
import platform
import urllib.request
import zipfile

ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / ".tools" / "bin"
ASSETS = [
    ("rojo-rbx/rojo", "v7.7.1", "rojo-7.7.1-linux-x86_64.zip",
     "00feb4fa0829a1dd72b49df2639da519a352bfe13cadcd83969e2ba2bb5693c4", ["rojo"]),
    ("luau-lang/luau", "0.744", "luau-ubuntu.zip",
     "6506f0852c623aaffcb28494aac16c26dc04a269ea0e16cc0aafc8c8ac79f3ec",
     ["luau", "luau-analyze", "luau-compile"]),
]

def main():
    if platform.system() != "Linux" or platform.machine() != "x86_64":
        raise SystemExit("Este instalador atende Linux x86_64. Veja README para Windows/macOS.")
    DEST.mkdir(parents=True, exist_ok=True)
    for repo, tag, asset, checksum, names in ASSETS:
        url = f"https://github.com/{repo}/releases/download/{tag}/{asset}"
        with urllib.request.urlopen(url, timeout=90) as response:
            data = response.read()
        if hashlib.sha256(data).hexdigest() != checksum:
            raise SystemExit(f"SHA-256 inválido: {asset}; nada deste arquivo foi instalado.")
        with zipfile.ZipFile(io.BytesIO(data)) as archive:
            for name in names:
                members = [m for m in archive.namelist() if Path(m).name == name]
                if len(members) != 1:
                    raise SystemExit(f"Binário ausente/ambíguo: {name}")
                target = DEST / name
                temp = DEST / (name + ".tmp")
                temp.write_bytes(archive.read(members[0]))
                temp.chmod(0o755)
                os.replace(temp, target)
        print(f"Instalado e verificado: {repo} {tag}")

if __name__ == "__main__":
    main()
