#!/usr/bin/env python3
"""Author original avatar meshes/UV/PBR textures and export Studio import sources.

No Roblox asset publishing is performed. FBX/GLB are real geometry; previews use
these same vertices, not concept illustrations. Requires Blender and Pillow.
"""
from pathlib import Path
import argparse,hashlib,json,math,random,subprocess,sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'scripts'))
from avatar_geometry import ART_REVISION,COLORS,SWATCHES,TILES,TILE,R15,QUAD,humanoid,creature
SOURCE=ROOT/'assets/avatars-rounded/source'
SCENE=ROOT/'build/avatar-rounded-scene.json'
RENDERS=ROOT/'build/avatar-rounded-renders'

def textures():
 from PIL import Image,ImageDraw
 folder=ROOT/'assets/avatars/textures';folder.mkdir(parents=True,exist_ok=True)
 color=Image.new('RGB',(TILES*TILE,TILES*TILE));metal=Image.new('RGB',color.size);rough=Image.new('RGB',color.size,(190,190,190))
 rng=random.Random(4917)
 for i,name in enumerate(SWATCHES):
  tile=Image.new('RGB',(TILE,TILE),COLORS[name]);px=tile.load();base=COLORS[name]
  amplitude=4 if name.startswith('Cloth')or name in ('Linen','Leather','Wood')else 2
  for y in range(TILE):
   for x in range(TILE):
    d=rng.randrange(-amplitude,amplitude+1)
    if name.startswith('Cloth')and(x%3==0 or y%3==0):d-=3
    if name=='Wood':d+=int(math.sin(x*.20+math.sin(y*.05)*.6)*7)
    px[x,y]=tuple(max(0,min(255,c+d))for c in base)
  draw=ImageDraw.Draw(tile)
  if name=='Mail':
   for y in range(-8,TILE,10):
    for x in range(-8,TILE,11):
     xx=x+(5 if (y//10)%2 else 0)
     draw.ellipse((xx,y,xx+8,y+8),outline=(149,158,169),width=1);draw.arc((xx,y+1,xx+8,y+9),0,180,fill=(30,36,44),width=1)
  if name in ('Face','DemonFace','SkullFace','WraithFace'):
   eyes=(16,14,13)if name=='Face'else(233,163,48)if name=='DemonFace'else(25,23,29)if name=='SkullFace'else(86,178,185)
   for x in (39,87):
    draw.ellipse((x-5,38,x+5,57),fill=eyes)
    if name!='Face':draw.line((x-9,33 if x<64 else 29,x+9,29 if x<64 else 33),fill=eyes,width=3)
   if name=='Face':draw.arc((34,47,94,90),15,165,fill=(44,27,21),width=3)
   elif name=='SkullFace':
    draw.rectangle((44,77,84,80),fill=eyes)
    for x in range(47,84,6):draw.line((x,73,x,84),fill=eyes,width=2)
   elif name=='DemonFace':draw.line((40,82,64,75,88,82),fill=(29,17,19),width=3)
  if name=='Paper':
   for y in range(20,110,9):
    length=rng.randrange(65,95);draw.line((16,y,length,y),fill=(72,61,44),width=1)
   draw.ellipse((95,98,111,114),outline=(136,43,37),width=3)
  ox=(i%TILES)*TILE;oy=(i//TILES)*TILE;color.paste(tile,(ox,oy))
  is_metal=name in ('Steel','Silver','Gold','Bronze','BlackSteel','Mail')
  metal.paste((235,235,235)if is_metal else(0,0,0),(ox,oy,ox+TILE,oy+TILE))
  value=85 if name in ('Gold','Silver')else 115 if is_metal else 210 if name.startswith('Cloth')else 155
  rough.paste((value,value,value),(ox,oy,ox+TILE,oy+TILE))
 for image,name in ((color,'Eldravyn_Color.png'),(metal,'Eldravyn_Metalness.png'),(rough,'Eldravyn_Roughness.png')):image.save(folder/name)

def definitions():
 from npc_host import run
 body=(ROOT/'scripts/npc_json.luau').read_text()+"\nprint('AVATAR_DEFS:'..json({NPCs=require(game.ReplicatedStorage.EldravynNPC.NPCConfig).Definitions,Enemies=require(game.ReplicatedStorage.MedievalRPG.Config.ContentConfig).Enemies}))"
 raw=run(body,'avatar-definitions');return json.loads(next(x.removeprefix('AVATAR_DEFS:')for x in raw.splitlines()if x.startswith('AVATAR_DEFS:')))

def author():
 defs=definitions();models=[];catalog={};counts={}
 for i,d in enumerate(defs['NPCs']):
  key='NPC_'+d['Id'];m=humanoid(key,d['Id'],d['Role'],d['City'],i)
  group='Valoria'if d['City']=='Valoria'else'North'if d['City']in('Arkheim','Eldoria')else'South'if d['City']in('Durakh','Asterion')else'Dungeons'
  counts[group]=counts.get(group,0)+1;index=counts[group]-1;m.origin=(6+(index%5)*7,0,6+(index//5)*8)
  record={'Key':key,'Label':m.label,'Kind':m.kind,'Origin':m.origin,'Group':group,'Parts':m.parts,'Bones':list(m.parts),'NPCId':d['Id'],'Role':d['Role'],'City':d['City']}
  models.append(record);catalog[key]={k:v for k,v in record.items()if k!='Parts'}
 for i,(kind,definition)in enumerate(sorted(defs['Enemies'].items())):
  key='ENEMY_'+kind
  if kind in ('Wolf','DarkWolf','SylvarinBoss','Slime'):m=creature(key,definition['Name'],'Deer'if kind=='SylvarinBoss'else kind)
  else:m=humanoid(key,definition['Name'],{'FallenRegent':'Knight','VesperaBoss':'Magic','Training':'Classes'}.get(kind,kind),'Valoria',i,kind)
  index=counts.get('Dungeons',0)+i;m.origin=(6+(index%5)*8,0,6+(index//5)*9)
  record={'Key':key,'Label':definition['Name'],'Kind':m.kind,'Origin':m.origin,'Group':'Dungeons','Parts':m.parts,'Bones':list(m.parts),'EnemyKind':kind}
  models.append(record);catalog[key]={k:v for k,v in record.items()if k!='Parts'}
 scene={'Version':3,'ArtRevision':ART_REVISION,'Coordinates':'Roblox studs; x right, y up, front -z','Models':models,'R15':R15,'Quadruped':QUAD,'AtlasSwatches':SWATCHES}
 SCENE.write_text(json.dumps(scene,ensure_ascii=False,separators=(',',':')))
 SOURCE.mkdir(parents=True,exist_ok=True);(SOURCE/'CATALOG.json').write_text(json.dumps(catalog,ensure_ascii=False,indent=2)+'\n')
 # Single generated data contract used by importer, rigs, themes and tests.
 from npc_host import luau
 data={'Version':3,'ArtRevision':ART_REVISION,'Models':catalog,'R15':R15,'Quadruped':QUAD,'NPCs':{d['Id']:'NPC_'+d['Id']for d in defs['NPCs']},'Enemies':{k:'ENEMY_'+k for k in defs['Enemies']}}
 (ROOT/'src/avatar/shared/AvatarCatalog.luau').write_text('-- Generated from original mesh authoring; gameplay catalog remains unchanged.\nreturn '+luau(json.loads(json.dumps(data)))+'\n')
 print('Authored',len(defs['NPCs']),'NPCs and',len(defs['Enemies']),'enemies;',sum(len(m['Parts'])for m in models),'mesh nodes.',flush=True)

def worker(args):
 import bpy,bmesh
 from mathutils import Vector
 scene_data=json.loads(SCENE.read_text());out=SOURCE;out.mkdir(exist_ok=True)
 bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
 scene=bpy.context.scene;scene.unit_settings.system='METRIC';scene.unit_settings.scale_length=1.0
 material=bpy.data.materials.new('EldravynOriginalAtlas');material.use_nodes=True;nodes=material.node_tree.nodes;links=material.node_tree.links;shader=nodes.get('Principled BSDF')
 for filename,slot in [('Color','Base Color'),('Metalness','Metallic'),('Roughness','Roughness')]:
  image=bpy.data.images.load(str(ROOT/'assets/avatars/textures'/f'Eldravyn_{filename}.png'));image.colorspace_settings.name='sRGB'if filename=='Color'else'Non-Color'
  tex=nodes.new('ShaderNodeTexImage');tex.image=image;links.new(tex.outputs['Color'],shader.inputs[slot])
 bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'build/avatar-material.blend'))
 groups={};by_key={}
 for record in scene_data['Models']:
  coll=bpy.data.collections.new(record['Key']);scene.collection.children.link(coll);by_key[record['Key']]=[]
  origin=record['Origin']
  for bone,p in record['Parts'].items():
   coords=[(v[0]+origin[0],-v[2]-origin[2],v[1]+origin[1])for v in p['Vertices']]
   mesh=bpy.data.meshes.new(record['Key']+'__'+bone);mesh.from_pydata(coords,[],p['Faces']);mesh.update()
   uv=mesh.uv_layers.new(name='UVMap')
   for poly,coords_uv in zip(mesh.polygons,p['UV']):
    for loop,xy in zip(poly.loop_indices,coords_uv):uv.data[loop].uv=xy
   bm=bmesh.new();bm.from_mesh(mesh);bmesh.ops.recalc_face_normals(bm,faces=bm.faces);bm.to_mesh(mesh);bm.free();mesh.update()
   for poly in mesh.polygons:poly.use_smooth=len(poly.vertices)==4 and poly.area<.5
   obj=bpy.data.objects.new(record['Key']+'__'+bone,mesh);coll.objects.link(obj);mesh.materials.append(material)
   obj['OriginalAuthoring']='Eldravyn';obj['AvatarTemplate']=record['Key'];obj['Bone']=bone;obj['RigKind']=record['Kind']
   groups.setdefault(record['Group'],[]).append(obj);by_key[record['Key']].append(obj)
 # Marker positions let registration compensate for FBX units, offset and axes.
 markers=[]
 for name,pos in [('O',(0,.5,0)),('X',(1,.5,0)),('Y',(0,1.5,0)),('Z',(0,.5,1))]:
  bpy.ops.mesh.primitive_cube_add(size=.10,location=(pos[0],-pos[2],pos[1]));obj=bpy.context.object;obj.name='ELDRAVYN_CAL_'+name;markers.append(obj)
 bpy.ops.mesh.primitive_cube_add(size=.10,location=(-1,0,.5));revision=bpy.context.object;revision.name='ELDRAVYN_ART_'+ART_REVISION.replace('-','_');markers.append(revision)
 if not args.preview_only:
  for group,objects in groups.items():
   bpy.ops.object.select_all(action='DESELECT')
   for obj in objects+markers:obj.select_set(True)
   bpy.context.view_layer.objects.active=objects[0]
   bpy.ops.export_scene.fbx(filepath=str(out/f'Eldravyn_{group}.fbx'),use_selection=True,object_types={'MESH'},use_mesh_modifiers=True,add_leaf_bones=False,axis_forward='-Z',axis_up='Y',path_mode='COPY',embed_textures=True,bake_anim=False)
  bpy.ops.object.select_all(action='SELECT');bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'build/EldravynAvatarLibrary.blend'))
 if args.export_only:return
 # Gallery renders actual exported meshes, no external character reference.
 for group in groups.values():
  for obj in group:obj.hide_render=True
 for obj in markers:obj.hide_render=True
 floor_mat=bpy.data.materials.new('ReviewFloor');floor_mat.diffuse_color=(.11,.13,.16,1)
 bpy.ops.mesh.primitive_plane_add(size=200);floor=bpy.context.object;floor.location.z=-.06;floor.data.materials.append(floor_mat)
 def light(name,pos,power,size):
  data=bpy.data.lights.new(name,'AREA');data.energy=power;data.size=size;obj=bpy.data.objects.new(name,data);scene.collection.objects.link(obj);obj.location=pos;obj.rotation_euler=(Vector((0,0,3))-obj.location).to_track_quat('-Z','Y').to_euler()
 light('Key',(-4,7,10),750,5);light('Fill',(5,3,6),470,4);light('Rim',(1,-5,7),900,4)
 cam_data=bpy.data.cameras.new('ReviewCamera');cam=bpy.data.objects.new('ReviewCamera',cam_data);scene.collection.objects.link(cam);scene.camera=cam;cam_data.type='ORTHO';cam_data.ortho_scale=7.7
 scene.render.engine='CYCLES';scene.cycles.samples=32;scene.cycles.use_denoising=False;scene.world.color=(.18,.18,.18)
 scene.render.resolution_x=720;scene.render.resolution_y=900;scene.render.resolution_percentage=100
 try:scene.view_settings.view_transform='AgX';scene.view_settings.look='AgX - Medium High Contrast'
 except TypeError:scene.view_settings.view_transform='Standard'
 preview=RENDERS;preview.mkdir(exist_ok=True)
 keys=args.keys or ['NPC_Valoria_Ambient_Guard','NPC_Arkheim_Ambient_Guard','NPC_Valoria_Blacksmith','NPC_Valoria_Magic','ENEMY_Demon','ENEMY_Wolf']
 for index,key in enumerate(keys):
  record=next(r for r in scene_data['Models']if r['Key']==key);offset=Vector((record['Origin'][0],-record['Origin'][2],record['Origin'][1]))
  objects=by_key[key]
  for obj in objects:obj.hide_render=False;obj.location=-offset
  target=Vector((0,0,1.55 if record['Kind']!='R15'else 3.1));cam.location=Vector((4.4,15,7.2))+target-Vector((0,0,3.1));cam.rotation_euler=(target-cam.location).to_track_quat('-Z','Y').to_euler()
  cam_data.ortho_scale=7.5 if record['Kind']=='R15'else 5.0
  scene.render.filepath=str(preview/(key+'.png'));bpy.ops.render.render(write_still=True)
  for obj in objects:obj.hide_render=True;obj.location=(0,0,0)
 (preview/'rendered.json').write_text(json.dumps(keys))

def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--worker',action='store_true');p.add_argument('--preview-only',action='store_true');p.add_argument('--export-only',action='store_true');p.add_argument('--keys',nargs='*');args=p.parse_args(sys.argv[sys.argv.index('--')+1:]if '--'in sys.argv else None)
 if args.worker:worker(args);return
 textures();author()
 cmd=['blender','--background','--factory-startup','--threads','4','--python-exit-code','1','--python',str(Path(__file__).resolve()),'--','--worker']
 if args.preview_only:cmd+=['--preview-only']
 if args.export_only:cmd+=['--export-only']
 if args.keys:cmd+=['--keys',*args.keys]
 with (ROOT/'build/avatar-rounded-blender.log').open('w')as log:subprocess.run(cmd,cwd=ROOT,stdout=log,stderr=subprocess.STDOUT,check=True)
 print('Meshes/UV/textures exported and offline previews rendered. Roblox import/publication NOT performed.')

if __name__=='__main__':main()
