#!/usr/bin/env python3
from pathlib import Path
import os
import subprocess
ROOT=Path(__file__).resolve().parents[1]
name='luau.exe' if os.name=='nt' else 'luau'
result=subprocess.run([str(ROOT/'.tools/bin'/name),'scripts/catalogs.luau'],cwd=ROOT,check=True,capture_output=True,text=True)
(ROOT/'docs/CATALOGS.md').write_text('\n'.join(line.rstrip() for line in result.stdout.splitlines())+'\n',encoding='utf-8')
print('Catálogos atualizados: raças, classes, habilidades, missões, NPCs e produtos desativados.')
