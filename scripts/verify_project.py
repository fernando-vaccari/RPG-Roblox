#!/usr/bin/env python3
"""Validate compiled Place contents and unresolved dependency mappings."""
from pathlib import Path
import xml.etree.ElementTree as ET
import re
import hashlib
import json
ROOT=Path(__file__).resolve().parents[1]
expected={p.stem for p in (ROOT/'src').rglob('*.luau') if not p.name.endswith(('.server.luau','.client.luau'))}
manifest={'title':'Eldravyn: Rise of Shadows','scenes_baked':False,'prepare_command':'require(game.ServerStorage.MedievalWorldgen.WorldGenerator).PrepareStudio()','studio_tested':False,'places':[]}
for name in ['ProjectMedievalRPG.rbxlx','ProjectMedievalRPG_Dungeon.rbxlx']:
    root=ET.parse(ROOT/'build'/name).getroot()
    items=root.findall('.//Item')
    parents={child:parent for parent in root.iter() for child in parent}
    def ancestors(item):
        result=[]
        while item in parents:
            item=parents[item]
            if item.tag=='Item':result.append(item.get('class'))
        return result
    modules={i.find("./Properties/string[@name='Name']").text for i in items if i.get('class')=='ModuleScript'}
    assert modules==expected,(expected-modules,modules-expected)
    graph={n:set() for n in modules}
    for item in items:
        if item.get('class')!='ModuleScript':continue
        module=item.find("./Properties/string[@name='Name']").text
        source=item.find("./Properties/*[@name='Source']").text or ''
        source=re.sub(r'GetService\([^)]*\)','Service',source)
        for expression in re.findall(r'require\(([^)]+)\)',source):
            target=expression.strip().split('.')[-1]
            if re.fullmatch(r'[A-Za-z_][A-Za-z0-9_]*',target):
                assert target in modules,(module,'dependência não encontrada',target)
                graph[module].add(target)
    active,done=set(),set()
    def visit(node):
        assert node not in active,('Dependência circular',node)
        if node in done:return
        active.add(node)
        for dependency in graph[node]:visit(dependency)
        active.remove(node);done.add(node)
    for node in graph:visit(node)
    scripts=[i for i in items if i.get('class') in ('Script','LocalScript')]
    assert len(scripts)==2
    for item in scripts:
        source=item.find("./Properties/*[@name='Source']").text
        assert 'GenerateNewWorld(' not in source,'Geração indevida no runtime'
        assert ('ServerScriptService' if item.get('class')=='Script' else 'StarterPlayerScripts') in ancestors(item),'Bootstrap no serviço errado'
    for item in items:
        if item.get('class')=='ModuleScript':
            module=item.find("./Properties/string[@name='Name']").text
            if (ROOT/'src/worldgen'/f'{module}.luau').is_file():assert 'ServerStorage' in ancestors(item)
            if (ROOT/'src/shared/Core'/f'{module}.luau').is_file():assert 'ReplicatedStorage' in ancestors(item)
    role=[i for i in items if i.get('class')=='StringValue' and i.find("./Properties/string[@name='Name']").text=='MedievalPlaceKind']
    assert len(role)==1 and role[0].find("./Properties/string[@name='Value']").text==('Dungeon' if '_Dungeon' in name else 'World')
    manifest['places'].append({'file':name,'modules':len(modules),'server_scripts':1,'client_scripts':1,'sha256':hashlib.sha256((ROOT/'build'/name).read_bytes()).hexdigest()})
    print(f'PASSOU: {name}: {len(modules)} módulos sem ciclos/referências ausentes, dois bootstraps de runtime, sem geração massiva automática.')
(ROOT/'build/BUILD_MANIFEST.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
