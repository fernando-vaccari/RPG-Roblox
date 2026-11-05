#!/usr/bin/env python3
"""Passive Studio integration package + integrity report for the authored FBX data.
Does not publish Roblox assets, insert IDs or modify any old delivery.
"""
import hashlib,json,subprocess,xml.etree.ElementTree as ET
from pathlib import Path
from npc_host import ROOT,BIN
from npc_placements import index_tree
OUT=ROOT/'delivery-npcs/avatar-style'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def sources(root):return sorted((n.get('class'),n.findtext('./Properties/*[@name="Source"]'))for n in root.iter('Item')if n.get('class')in('ModuleScript','LocalScript','Script'))
def build():
 inspect=json.loads((ROOT/'docs/npc-v2/INSPECTION.json').read_text())
 original=ROOT/inspect['source'];assert sha(original)==inspect['sha256']
 allowed='src/server/Services/EnemyService.luau'
 for name,digest in inspect['protected_sources'].items():
  if name!=allowed:assert sha(ROOT/name)==digest,('Protected source changed',name)
 base=subprocess.check_output(['git','show','9a6564c:'+allowed],cwd=ROOT)
 assert (ROOT/'src/avatar/install/EnemyServiceBaseline.luau').read_bytes()==base
 assert sha(ROOT/'delivery-npcs/visual-v2/Eldravyn-NPC-Overhaul-V2.rbxmx')=='5df96644973e6ad6094d96f73df2d5487a22eb2d35965dea772787c5e4dabb3c'
 OUT.mkdir(parents=True,exist_ok=True);output=OUT/'Eldravyn-Avatar-Integration.rbxmx'
 subprocess.run([str(BIN/'rojo'),'build','avatar-style.project.json','--output',str(output)],cwd=ROOT,check=True)
 root=ET.parse(output).getroot();items=list(root.iter('Item'));referents=[i.get('referent')for i in items];assert len(referents)==len(set(referents))
 for r in root.iter('Ref'):assert r.text in('null','nil',None)or r.text in referents
 scripts=[i for i in items if i.get('class')in('Script','LocalScript')]
 assert len(scripts)==2 and all(i.get('class')=='LocalScript'and i.findtext('./Properties/bool[@name="Disabled"]')=='true'for i in scripts)
 assert not any(i.get('class')in('Terrain','Part','MeshPart','RemoteEvent','RemoteFunction','Humanoid')for i in items)
 # All mesh content must originate from the user's actual Studio imports later.
 assert root.find('.//Content[@name="MeshId"]')is None
 known={p.read_text()for p in(ROOT/'src').rglob('*.luau')}
 for cls,text in sources(root):assert text in known,('Unknown source',cls)
 project=ROOT/'build/avatar-roundtrip.project.json';project.write_text(json.dumps({'name':'AvatarRoundtrip','tree':{'$className':'DataModel','ServerStorage':{'$className':'ServerStorage','EldravynAvatarUpgrade':{'$path':str(output)}}}}))
 roundtrip=ROOT/'build/avatar-roundtrip.rbxlx';subprocess.run([str(BIN/'rojo'),'build',str(project),'--output',str(roundtrip)],cwd=ROOT,check=True)
 assert sources(root)==sources(ET.parse(roundtrip).getroot())
 data=json.loads((ROOT/'assets/avatars/source/CATALOG.json').read_text());fbx=json.loads((ROOT/'build/avatar-fbx-roundtrip.json').read_text())
 files=[output,*sorted((ROOT/'assets/avatars/source').glob('*.fbx')),*sorted((ROOT/'assets/avatars/textures').glob('*.png'))]
 assert len(files)==8 and len(data)==80
 report={'version':3,'NPCs':66,'EnemyTypes':14,'mesh_nodes':sum(r['meshes']for r in fbx['groups']),
  'triangles_all_source_models':sum(r['triangles']for r in fbx['groups']),'fbx_roundtrip':fbx,'map_modified':False,
  'old_place_sha256':inspect['sha256'],'previous_v2_package_preserved':True,'protected_sources_unchanged':len(inspect['protected_sources'])-1,
  'existing_gameplay_hook':allowed,'published_Roblox_assets':False,'published_asset_ids':[],
  'ready_to_apply_before_Studio_import':False,'studio_executed':False,'fps_measured':False,'antivirus_executed':False,
  'required_manual_step':'Import the four authored FBX files and textures through Roblox Studio on the owner account; register them before Apply.',
  'files':[{'path':str(p.relative_to(ROOT)),'bytes':p.stat().st_size,'sha256':sha(p)}for p in files]}
 (OUT/'MANIFEST.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
 (OUT/'SHA256SUMS.txt').write_text(''.join(r['sha256']+'  '+r['path']+'\n'for r in report['files']))
 print('PASSOU AVATAR PACOTE: fontes/XML/Rojo e scripts passivos; arquivos originais preservados; 80 modelos FBX conferidos. Publicação/importação Roblox pendentes.')
 print(json.dumps({'package_bytes':output.stat().st_size,'package_sha256':sha(output),'mesh_nodes':report['mesh_nodes'],'triangles':report['triangles_all_source_models']},indent=2))
if __name__=='__main__':build()
