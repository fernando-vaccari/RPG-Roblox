#!/usr/bin/env python3
"""Package source, documentation and both compiled Places without caches/secrets."""
from pathlib import Path
import hashlib
import zipfile
ROOT=Path(__file__).resolve().parents[1]
BUILD=ROOT/'build'
files=[ROOT/'.gitignore',ROOT/'default.project.json',ROOT/'dungeon.project.json']+sorted(ROOT.glob('*.md'))
for folder in ['src','scripts','tests','docs','assets']:
    files+=sorted(p for p in (ROOT/folder).rglob('*') if p.is_file() and '__pycache__' not in p.parts)
for name in ['ProjectMedievalRPG.rbxlx','ProjectMedievalRPG_Dungeon.rbxlx']:
    path=BUILD/name
    if not path.is_file():raise SystemExit('Execute scripts/check.py antes: '+str(path))
    files.append(path)
archive=BUILD/'RPG-Roblox-Windows11.zip'
with zipfile.ZipFile(archive,'w',compression=zipfile.ZIP_DEFLATED) as z:
    for file in files:z.write(file,Path('RPG-Roblox')/file.relative_to(ROOT))
with zipfile.ZipFile(archive) as z:
    assert z.testzip() is None
    assert len(z.namelist())==len(set(z.namelist()))
    assert all('/.git/' not in name and '/.tools/' not in name for name in z.namelist())
checks=[]
for path in [BUILD/'ProjectMedievalRPG.rbxlx',BUILD/'ProjectMedievalRPG_Dungeon.rbxlx',archive]:
    digest=hashlib.sha256(path.read_bytes()).hexdigest();checks.append(f'{digest}  {path.name}')
    print(path.name,path.stat().st_size,'bytes')
(BUILD/'SHA256SUMS.txt').write_text('\n'.join(checks)+'\n')
print('Pacote ZIP verificado; checksums em build/SHA256SUMS.txt')
