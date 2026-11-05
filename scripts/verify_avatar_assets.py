#!/usr/bin/env python3
"""Re-import exported FBX with Blender and compare real mesh bounds/UVs/names.
This verifies the source files, not Roblox Studio import or asset permissions.
"""
from pathlib import Path
import hashlib,json,shutil,subprocess,sys
ROOT=Path(__file__).resolve().parents[1]

def worker():
 import bpy
 data=json.loads((ROOT/'build/avatar-rounded-scene.json').read_text());reports=[]
 for group in ['Valoria','North','South','Dungeons']:
  bpy.ops.wm.read_factory_settings(use_empty=True)
  path=ROOT/'build/avatar-rounded-fbx-probe'/f'Eldravyn_{group}.fbx'
  bpy.ops.import_scene.fbx(filepath=str(path),use_image_search=False)
  meshes={o.name:o for o in bpy.context.scene.objects if o.type=='MESH'}
  expected={m['Key']+'__'+bone:(m,p)for m in data['Models']if m['Group']==group for bone,p in m['Parts'].items()}
  assert set(meshes)==set(expected)|{'ELDRAVYN_CAL_'+c for c in 'OXYZ'}|{'ELDRAVYN_ART_'+data['ArtRevision'].replace('-','_')},('Wrong mesh names/count',group)
  max_error=0;triangles=0
  for name,(model,part)in expected.items():
   o=meshes[name];assert o.data.uv_layers.active and len(o.data.materials)==1,name
   for poly in o.data.polygons:triangles+=len(poly.vertices)-2
   world=[o.matrix_world@v.co for v in o.data.vertices];origin=model['Origin']
   raw=[(v[0]+origin[0],-v[2]-origin[2],v[1]+origin[1])for v in part['Vertices']]
   for axis in range(3):
    for fn in (min,max):
     error=abs(fn(v[axis]for v in world)-fn(v[axis]for v in raw));max_error=max(max_error,error);assert error<.001,(name,error)
   for uv in o.data.uv_layers.active.data:assert 0<=uv.uv.x<=1 and 0<=uv.uv.y<=1
   images=[n.image for n in o.data.materials[0].node_tree.nodes if n.type=='TEX_IMAGE'and n.image]
   assert any('Color'in im.name for im in images),('No color atlas after FBX reimport',name)
  reports.append({'group':group,'meshes':len(expected),'triangles':triangles,'bounds_error_max':max_error,'uv_and_atlas':True})
 (ROOT/'build/avatar-rounded-fbx-roundtrip.json').write_text(json.dumps({'art_revision':data['ArtRevision'],'blender_version':bpy.app.version_string,'roblox_studio':False,'groups':reports},indent=2)+'\n')

if __name__=='__main__':
 if '--worker'in sys.argv:worker()
 else:
  folder=ROOT/'build/avatar-rounded-fbx-probe';folder.mkdir(exist_ok=True)
  for p in (ROOT/'assets/avatars-rounded/source').glob('*.fbx'):shutil.copyfile(p,folder/p.name)
  with(ROOT/'build/avatar-rounded-fbx-roundtrip.log').open('w')as log:subprocess.run(['blender','--background','--factory-startup','--threads','4','--python-exit-code','1','--python',str(Path(__file__).resolve()),'--','--worker'],stdout=log,stderr=subprocess.STDOUT,check=True)
  print((ROOT/'build/avatar-rounded-fbx-roundtrip.json').read_text())
