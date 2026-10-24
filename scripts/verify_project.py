#!/usr/bin/env python3
"""Validate compiled Place contents and unresolved dependency mappings."""
from pathlib import Path
import xml.etree.ElementTree as ET
import re
ROOT=Path(__file__).resolve().parents[1]
expected={p.stem for p in (ROOT/'src').rglob('*.luau') if not p.name.endswith(('.server.luau','.client.luau'))}
for name in ['ProjectMedievalRPG.rbxlx','ProjectMedievalRPG_Dungeon.rbxlx']:
    root=ET.parse(ROOT/'build'/name).getroot()
    items=root.findall('.//Item')
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
    print(f'PASSOU: {name}: {len(modules)} módulos sem ciclos/referências ausentes, dois bootstraps de runtime, sem geração massiva automática.')
