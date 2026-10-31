#!/usr/bin/env python3
"""Add NPCs to the existing Place, preserve original scene/scripts and a passive installer."""
import xml.etree.ElementTree as ET,json,hashlib,copy
from npc_host import ROOT,run
from npc_placements import generate,SOURCE,index_tree,name
from bake_continent import make_model,namespace,read_attributes,add_attributes,run_rojo
OUT=ROOT/'delivery-npcs/stage-02'
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def digest(node):return hashlib.sha256(ET.tostring(node,encoding='utf-8')).hexdigest()
def attributes(node,values):
    p=node.find('Properties');attrs=read_attributes(p);attrs.update(values)
    old=p.find('./BinaryString[@name="AttributesSerialize"]')
    if old is not None:p.remove(old)
    add_attributes(p,attrs)
def rename(node,value):node.find('./Properties/string[@name="Name"]').text=value
def build():
    OUT.mkdir(parents=True,exist_ok=True)
    positions=generate()
    api=json.loads((ROOT/'.tools/roblox-api.json').read_text())
    classes={c['Name']:c for c in api['Classes']};enums={e['Name']+'.'+i['Name']:i['Value'] for e in api['Enums'] for i in e['Items']}
    raw=run((ROOT/'scripts/npc_json.luau').read_text()+'\n'+(ROOT/'scripts/export_npcs.luau').read_text(),'npc-export')
    scene=json.loads(next(l[10:] for l in raw.splitlines() if l.startswith('NPC_SCENE:')))
    npcroot=make_model(scene,classes,enums);namespace(npcroot,'npc_')
    package=OUT/'Eldravyn-NPCs-Stage2.rbxmx';run_rojo(ROOT/'npc-package.project.json',package)
    package_root=ET.parse(package).getroot();namespace(package_root,'package_')
    package_model=package_root.find('Item')
    for s in package_model.iter('Item'):
        if s.get('class') in ('Script','LocalScript'):assert s.findtext('./Properties/bool[@name="Disabled"]')=='true','Installer scripts must be inert'
    source_hash=sha(SOURCE);tree=ET.parse(SOURCE);root=tree.getroot();idx=index_tree(root)
    original_world=idx['Workspace/GeneratedWorld'];before=digest(original_world)
    terrain=idx.get('Workspace/Terrain');terrain_before=digest(terrain) if terrain is not None else None
    original_scripts={p:(i.get('class'),i.findtext('./Properties/*[@name="Source"]')) for p,i in idx.items() if i.get('class') in ('Script','LocalScript','ModuleScript')}
    runtime=[]
    for src,dest,parent in [('Shared','EldravynNPC','ReplicatedStorage'),('Server','EldravynNPC','ServerScriptService'),('Client','EldravynNPCClient','StarterPlayer/StarterPlayerScripts')]:
        node=copy.deepcopy(next(c for c in package_model.findall('Item') if name(c)==src));wrapper=ET.Element('roblox');wrapper.append(node);namespace(wrapper,'installed_');rename(node,dest);attributes(node,{'NPCInstallVersion':1})
        for script in node.iter('Item'):
            if script.get('class') in ('Script','LocalScript'):script.find('./Properties/bool[@name="Disabled"]').text='false'
        assert parent+'/'+dest not in idx;idx[parent].append(node);runtime.append(node)
    idx['Workspace'].append(npcroot.find('Item'));attributes(idx['Workspace'],{'EldravynNPCStage2':True,'StudioSessionPreview':True})
    idx['ServerStorage'].append(package_model)
    place=OUT/'Eldravyn-Monumental-NPCs.rbxlx';tree.write(place,encoding='utf-8',xml_declaration=True)
    check=ET.parse(place).getroot();newidx=index_tree(check)
    assert digest(newidx['Workspace/GeneratedWorld'])==before,'GeneratedWorld changed'
    assert (digest(newidx['Workspace/Terrain']) if terrain_before else None)==terrain_before,'Terrain changed'
    for p,(cls,source) in original_scripts.items():assert newidx[p].get('class')==cls and newidx[p].findtext('./Properties/*[@name="Source"]')==source,('Original script changed',p)
    assert sha(SOURCE)==source_hash,'Original file changed'
    refs=[i.get('referent') for i in check.iter('Item')];assert len(set(refs))==len(refs),'Duplicate XML referents'
    referents=set(refs)
    for ref in check.iter('Ref'):assert ref.text in (None,'null','nil') or ref.text in referents,('Dangling ref',ref.text)
    npcs=newidx['Workspace/EldravynNPCs']
    humanoids=[i for i in npcs.iter('Item') if i.get('class')=='Humanoid'];prompts=[i for i in npcs.iter('Item') if i.get('class')=='ProximityPrompt']
    assert len(humanoids)==len(positions['NPCs'])==len(prompts)==66
    assert all(i.findtext('./Properties/token[@name="RigType"]')==str(enums['HumanoidRigType.R15']) for i in humanoids)
    # All packaged scripts must equal repository source; no downloaded runtime/asset dependencies.
    source_texts={p.read_text() for p in (ROOT/'src').rglob('*.luau')}
    for container in [package_model,*runtime]:
        for i in container.iter('Item'):
            if i.get('class') in ('ModuleScript','Script','LocalScript'):assert i.findtext('./Properties/*[@name="Source"]') in source_texts,name(i)
    report={'stage':2,'source':str(SOURCE.relative_to(ROOT)),'source_sha256':source_hash,'user_383MB_file_available':False,'npcs':66,'original_scripts_preserved':len(original_scripts),'generated_world_subtree_sha256':before,'terrain_subtree_sha256':terrain_before,'terrain_written':False,'terrain_pending_in_supplied_base':True,'studio_executed':False,'antivirus_executed':False,'outputs':[{'file':p.name,'bytes':p.stat().st_size,'sha256':sha(p)} for p in [place,package]]}
    (OUT/'MANIFEST.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    (OUT/'SHA256SUMS.txt').write_text(''.join(v['sha256']+'  '+v['file']+'\n' for v in report['outputs']))
    print(json.dumps(report,ensure_ascii=False,indent=2))
if __name__=='__main__':build()
