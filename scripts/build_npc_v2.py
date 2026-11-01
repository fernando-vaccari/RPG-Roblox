#!/usr/bin/env python3
"""Build a passive update-only model. Never rewrites an existing Place/map/package."""
import hashlib,json,re,subprocess,xml.etree.ElementTree as ET
from npc_host import ROOT,BIN
from npc_placements import index_tree

OUT=ROOT/'delivery-npcs/visual-v2'
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def source_map(root):
    return {path:(node.get('class'),node.findtext('./Properties/*[@name="Source"]'))
            for path,node in index_tree(root).items() if node.get('class') in ('ModuleScript','Script','LocalScript')}

def build():
    inspection=json.loads((ROOT/'docs/npc-v2/INSPECTION.json').read_text())
    source=ROOT/inspection['source'];assert sha(source)==inspection['sha256'],'Original Place changed'
    for name,digest in inspection['protected_sources'].items():assert sha(ROOT/name)==digest,('Protected source changed',name)
    original=ET.parse(source).getroot();original_index=index_tree(original);world=original_index['Workspace/GeneratedWorld']
    # INSPECTION used ElementTree's default us-ascii serialization (XML entities).
    assert hashlib.sha256(ET.tostring(world,encoding='us-ascii')).hexdigest()==inspection['generated_world_xml_sha256']
    for module,parent in [('NPCService','ServerScriptService/EldravynNPC'),('AmbientService','ServerScriptService/EldravynNPC'),('NPCInteractionClient','StarterPlayer/StarterPlayerScripts/EldravynNPCClient')]:
        original_source=original_index[parent+'/'+module].findtext('./Properties/*[@name="Source"]')
        assert (ROOT/'src/npc-v2/baseline'/f'{module}.luau').read_text()==original_source.replace('\r\n','\n'),('Baseline mismatch',module)
    del original,original_index,world
    OUT.mkdir(parents=True,exist_ok=True)
    output=OUT/'Eldravyn-NPC-Overhaul-V2.rbxmx'
    subprocess.run([str(BIN/'rojo'),'build','npc-visual-v2.project.json','--output',str(output)],cwd=ROOT,check=True)
    root=ET.parse(output).getroot();items=list(root.iter('Item'));refs=[i.get('referent') for i in items]
    assert len(refs)==len(set(refs))
    for ref in root.iter('Ref'):assert ref.text in ('null','nil',None) or ref.text in refs
    scripts=[i for i in items if i.get('class') in ('Script','LocalScript')]
    assert len(scripts)==1 and scripts[0].get('class')=='LocalScript'
    assert scripts[0].findtext('./Properties/bool[@name="Disabled"]')=='true','Package must be passive'
    assert not any(i.get('class') in ('Terrain','Part','MeshPart','Humanoid','RemoteEvent','RemoteFunction') for i in items),'Update package must not install duplicate actors/map/services'
    texts={p.read_text() for p in (ROOT/'src').rglob('*.luau')}
    mapped=source_map(root)
    for path,(_,text) in mapped.items():assert text in texts,('Unmapped source',path)
    # Native fallback only; no injected runtime, asset downloads or new stores.
    forbidden=r'\b(?:loadstring|getfenv|setfenv)\s*\(|(?:GetAsync|PostAsync|RequestAsync|GetDataStore|InsertService|LoadAsset)\s*\(|require\s*\(\s*\d'
    for path in (ROOT/'src/npc-v2').rglob('*.luau'):
        if 'baseline' not in path.parts:assert not re.search(forbidden,path.read_text()),str(path)
    assert "Id='rbxassetid://" not in (ROOT/'src/npc-v2/shared/NPCVisualConfig.luau').read_text()
    # Parse package with Roblox DOM implementation in Rojo, then compare sources.
    project=ROOT/'build/npc-v2-roundtrip.project.json'
    project.write_text(json.dumps({'name':'NPCVisualRoundtrip','tree':{'$className':'DataModel','ServerStorage':{'$className':'ServerStorage','EldravynNPCVisualUpgradeV2':{'$path':str(output)}}}}))
    roundtrip=ROOT/'build/npc-v2-roundtrip.rbxlx'
    subprocess.run([str(BIN/'rojo'),'build',str(project),'--output',str(roundtrip)],cwd=ROOT,check=True)
    reparsed=source_map(ET.parse(roundtrip).getroot())
    assert sorted(mapped.values())==sorted(reparsed.values()),'Source/class changed during XML roundtrip'
    report={'version':'NPC Visual V2','baseline_commit':'0f21f59','original_place':inspection['source'],
        'original_place_sha256':inspection['sha256'],'generated_world_xml_sha256':inspection['generated_world_xml_sha256'],
        'protected_source_count':len(inspection['protected_sources']),'original_place_written':False,'map_or_terrain_written':False,
        'npcs':66,'roles':25,'source_modules':len(mapped)-1,'local_scripts':1,'active_scripts_in_package':0,
        'required_external_assets':0,'published_animation_ids':[],
        'checks':['protected file hashes','GeneratedWorld subtree hash','XML references','exact repository sources','passive scripts','Rojo XML roundtrip','focused static source scan'],
        'studio_executed':False,'antivirus_executed':False,'fps_measured':False,
        'outputs':[{'file':output.name,'bytes':output.stat().st_size,'sha256':sha(output)}]}
    (OUT/'MANIFEST.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    (OUT/'SHA256SUMS.txt').write_text(''.join(row['sha256']+'  '+row['file']+'\n' for row in report['outputs']))
    (ROOT/'docs/npc-v2/PACKAGE_SOURCES.json').write_text(json.dumps({path:{'class':cls,'sha256':hashlib.sha256(text.encode()).hexdigest()} for path,(cls,text) in mapped.items()},ensure_ascii=False,indent=2)+'\n')
    assert sha(source)==inspection['sha256']
    print(f'PASSOU V2 PACOTE: {len(mapped)} scripts correspondem às fontes; importação Rojo preserva fontes/classes; {len(inspection["protected_sources"])} fontes protegidas e Place/mapa original idênticos. Studio/antivírus não executados.')
    print(json.dumps(report['outputs'],indent=2))

if __name__=='__main__':build()
