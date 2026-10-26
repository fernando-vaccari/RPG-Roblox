#!/usr/bin/env python3
"""Execute the actual editor modules with a limited, explicitly simulated host.
The public API dump checks property/enum names. This never claims Studio validation.
"""
from pathlib import Path
import json
import os
import subprocess
import urllib.request
ROOT=Path(__file__).resolve().parents[1]
BUILD=ROOT/'build'
BUILD.mkdir(exist_ok=True)
CACHE=ROOT/'.tools/roblox-api.json'
if not CACHE.exists():
    with urllib.request.urlopen('https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/API-Dump.json',timeout=60) as r:
        CACHE.write_bytes(r.read())
api=json.loads(CACHE.read_text())
def luau(value):
    if value is None:return 'nil'
    if isinstance(value,bool):return 'true' if value else 'false'
    if isinstance(value,(int,float)):return str(value)
    if isinstance(value,str):return json.dumps(value,ensure_ascii=False)
    if isinstance(value,list):return '{'+','.join(luau(v) for v in value)+'}'
    return '{'+','.join('['+luau(k)+']='+luau(v) for k,v in value.items())+'}'
classes={c['Name']:{'Super':c['Superclass'],'NotCreatable':'NotCreatable' in c.get('Tags',[]),'Props':{m['Name']:True for m in c['Members'] if m['MemberType'] in ('Property','Callback')},'Events':{m['Name']:True for m in c['Members'] if m['MemberType']=='Event'}} for c in api['Classes']}
enums={e['Name']:{i['Name']:e['Name']+'.'+i['Name'] for i in e['Items']} for e in api['Enums']}
import re
for file in (ROOT/'src').rglob('*.luau'):
    for enum,item in re.findall(r'Enum\.(\w+)\.(\w+)',file.read_text()):
        assert enum in enums and item in enums[enum], f'{file}: invalid Enum.{enum}.{item}'
# Limit serialized reflection to classes/enums actually needed by generators.
needed=set(['DataModel','Workspace','ReplicatedStorage','ServerStorage','ServerScriptService','RunService','Terrain','HttpService','Players','DataStoreService','Player','Lighting','TweenService','Debris','PlayerGui','MarketplaceService','PathfindingService','UserInputService','TeleportService','ProximityPromptService','Backpack','StringValue'])
for file in (ROOT/'src').rglob('*.luau'):
    needed.update(re.findall(r"Instance\.new\(['\"](\w+)['\"]\)",file.read_text()))
needed.update(['Part','Model','Folder','ModuleScript','SurfaceGui','TextLabel','PointLight'])
for k in list(needed):
    c=classes.get(k)
    while c and c['Super'] in classes:
        needed.add(c['Super']);c=classes[c['Super']]
classes={k:v for k,v in classes.items() if k in needed}
lines=["local Mock=require('../tests/StudioMock')",'local env=Mock.new('+luau(enums)+','+luau(classes)+')']
for name in ['game','workspace','Instance','Vector3','CFrame','Color3','Vector2','UDim2','Region3','OverlapParams','RaycastParams','task','warn','UDim','TweenInfo','typeof']:
    lines.append(f'local {name}=env.{name}')
lines+=['local Enum=env.Enums','local loaders,cache={},{ }','local function require(node) if cache[node]then return cache[node]end;assert(loaders[node],"Módulo não mapeado");local result=loaders[node]();cache[node]=result;return result end']
# Same hierarchy as Rojo, with a loader closure for each ModuleScript.
paths={}
lines.append('do local f=Instance.new("Folder");f.Name="MedievalServer";f.Parent=game.ServerScriptService end')
for base,mount in [('src/shared','game.ReplicatedStorage.MedievalRPG'),('src/worldgen','game.ServerStorage.MedievalWorldgen'),('src/server/Services','game.ServerScriptService.MedievalServer.Services'),('src/client/Controllers','game.ReplicatedStorage.TestControllers')]:
    for folder in [Path(base)]+sorted(p for p in (ROOT/base).rglob('*') if p.is_dir()):
        rel=folder.relative_to(Path(base)) if not folder.is_absolute() else folder.relative_to(ROOT/base)
        expr=mount+''.join('.'+p for p in rel.parts)
        parent,name=expr.rsplit('.',1)
        lines.append(f'do local f=Instance.new("Folder");f.Name="{name}";f.Parent={parent} end')
    for file in sorted((ROOT/base).rglob('*.luau')):
        rel=file.relative_to(ROOT/base).with_suffix('');expr=mount+''.join('.'+p for p in rel.parts)
        parent,name=expr.rsplit('.',1);paths[file]=expr
        lines.append(f'do local m=Instance.new("ModuleScript");m.Name="{name}";m.Parent={parent} end')
for file,expr in paths.items():
    lines.append(f'loaders[{expr}]=function() local script={expr}\n'+file.read_text()+'\nend')
lines.append((ROOT/'tests/editor.integration.luau').read_text())
file=BUILD/'editor.integration.luau';file.write_text('\n'.join(lines))
suffix='.exe' if os.name=='nt' else ''
subprocess.run([str(ROOT/'.tools/bin'/('luau'+suffix)),str(file)],cwd=ROOT,check=True)
