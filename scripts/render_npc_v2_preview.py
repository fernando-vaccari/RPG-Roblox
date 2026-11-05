#!/usr/bin/env python3
"""Offline Blender review of ACTUAL generated NPC parts and Motor6D pose equations.

No concept art, external assets, invented geometry or Roblox Studio claims.
Lighting/materials differ from Roblox; does not validate engine physics/FPS.
"""
from pathlib import Path
import json, math, subprocess, sys
ROOT=Path(__file__).resolve().parents[1]

def export():
    from npc_host import run
    raw=run((ROOT/'scripts/npc_json.luau').read_text()+'\n'+(ROOT/'scripts/export_npc_v2_preview.luau').read_text(),'npc-v2-preview',v2=True)
    data=json.loads(next(s.removeprefix('NPC_V2_PREVIEW:') for s in raw.splitlines() if s.startswith('NPC_V2_PREVIEW:')))
    (ROOT/'build/npc-v2-preview.json').write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')

def worker():
    import bpy
    from mathutils import Vector,Matrix
    from render_continent_preview import primitives
    source=json.loads((ROOT/'build/npc-v2-preview.json').read_text())
    output=ROOT/'build/npc-v2-renders';output.mkdir(exist_ok=True)
    bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
    scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=48
    scene.cycles.use_denoising=False;scene.render.resolution_x=720;scene.render.resolution_y=900;scene.render.resolution_percentage=100
    scene.world.color=(.18,.18,.18);scene.view_settings.view_transform='Standard';scene.view_settings.look='Medium High Contrast'
    scene.view_settings.exposure=0;scene.view_settings.gamma=1
    shapes=primitives();materials={}
    bpy.ops.mesh.primitive_plane_add(size=200,location=(0,0,-.05));floor=bpy.context.object
    mat=bpy.data.materials.new('neutral studio floor');mat.diffuse_color=(.17,.19,.22,1);floor.data.materials.append(mat)
    def area(name,location,power,size):
        data=bpy.data.lights.new(name,'AREA');data.energy=power;data.size=size
        obj=bpy.data.objects.new(name,data);scene.collection.objects.link(obj);obj.location=location
        obj.rotation_euler=(Vector((0,0,3))-obj.location).to_track_quat('-Z','Y').to_euler()
    area('Key',(-5,7,11),1100,5);area('Fill',(5,4,6),700,4);area('Rim',(1,-4,9),1200,4)
    camdata=bpy.data.cameras.new('OfflineCamera');cam=bpy.data.objects.new('OfflineCamera',camdata);scene.collection.objects.link(cam);scene.camera=cam
    camdata.type='ORTHO';camdata.ortho_scale=7.6
    cam.location=(4.4,15,8.0);cam.rotation_euler=(Vector((0,0,3.05))-cam.location).to_track_quat('-Z','Y').to_euler()
    conversion=Matrix(((1,0,0),(0,0,-1),(0,1,0)))
    def linear(v):return v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4
    for index,record in enumerate(source['Scenes']):
        objects=[]
        for p in record['Parts']:
            if p['Transparency']>=.98:continue
            shape='WedgePart' if p['Class']=='WedgePart' else p['Shape'].split('.')[-1] or 'Block'
            if shape=='Ball':
                bpy.ops.mesh.primitive_uv_sphere_add(segments=24,ring_count=16,radius=.5);obj=bpy.context.object
                for poly in obj.data.polygons:poly.use_smooth=True
            elif shape=='Cylinder':
                # Native Roblox cylinder longitudinal axis is local X.
                bpy.ops.mesh.primitive_cylinder_add(vertices=32,radius=.5,depth=1);obj=bpy.context.object
                for v in obj.data.vertices:v.co=Vector((v.co.z,v.co.y,-v.co.x))
                for poly in obj.data.polygons:poly.use_smooth=len(poly.vertices)==4
            else:
                verts,faces=shapes[shape];mesh=bpy.data.meshes.new(p['Name']);mesh.from_pydata(verts,[],faces);mesh.update()
                obj=bpy.data.objects.new(p['Name'],mesh);scene.collection.objects.link(obj)
            obj.name=p['Name'];objects.append(obj)
            x,y,z,*r=p['CFrame'];rotation=Matrix((r[0:3],r[3:6],r[6:9]));world=(conversion@rotation).to_4x4()
            world.translation=Vector((x,-z,y));obj.matrix_world=world;obj.scale=p['Size']
            key=(tuple(p['Color']),p['Material'],p['Transparency'])
            if key not in materials:
                m=bpy.data.materials.new(p['Name']+' material');m.use_nodes=True
                bsdf=m.node_tree.nodes.get('Principled BSDF');rgb=tuple(linear(v) for v in p['Color']);bsdf.inputs['Base Color'].default_value=(*rgb,1)
                bsdf.inputs['Metallic'].default_value=.65 if 'Metal' in p['Material'] else 0
                bsdf.inputs['Roughness'].default_value=.32 if 'Metal' in p['Material'] else .72 if 'Fabric' in p['Material'] else .45
                if 'Neon' in p['Material']:
                    (bsdf.inputs.get('Emission Color') or bsdf.inputs['Emission']).default_value=(*rgb,1);bsdf.inputs['Emission Strength'].default_value=.3
                if p['Transparency']>.4:
                    bsdf.inputs['Alpha'].default_value=1-p['Transparency'];m.blend_method='BLEND'
                materials[key]=m
            obj.data.materials.append(materials[key])
        scene.render.filepath=str(output/f'{index:02}.png');bpy.ops.render.render(write_still=True)
        for obj in objects:bpy.data.objects.remove(obj,do_unlink=True)

def compose():
    from PIL import Image,ImageDraw,ImageFont
    source=json.loads((ROOT/'build/npc-v2-preview.json').read_text())
    out=ROOT/'docs/npc-v2/previews';out.mkdir(parents=True,exist_ok=True)
    fontpath='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
    font=ImageFont.truetype(fontpath,22);small=ImageFont.truetype(fontpath,17)
    def sheet(indices,columns,path):
        width=600;tileh=792;rows=math.ceil(len(indices)/columns)
        result=Image.new('RGB',(width*columns,rows*tileh+100),(27,32,42));draw=ImageDraw.Draw(result)
        draw.text((20,14),'ELDRAVYN • NPC OVERHAUL V2',font=font,fill=(235,216,175))
        draw.text((20,48),'Geometria real do gerador • prévia Blender • não é captura do Roblox Studio',font=small,fill=(210,215,224))
        for slot,i in enumerate(indices):
            x=(slot%columns)*width;y=100+(slot//columns)*tileh
            image=Image.open(ROOT/'build/npc-v2-renders'/f'{i:02}.png').convert('RGB').resize((600,750))
            result.paste(image,(x,y));draw.text((x+15,y+756),source['Scenes'][i]['Label'],font=small,fill=(240,230,213))
        result.save(out/path)
    sheet([0,1],2,'guilda-antes-depois.png');sheet(list(range(2,8)),3,'profissoes.png')

if __name__=='__main__':
    if '--worker' in sys.argv:
        sys.path.insert(0,str(ROOT/'scripts'));worker()
    else:
        export()
        with (ROOT/'build/npc-v2-blender.log').open('w') as log:
            subprocess.run(['blender','--background','--factory-startup','--threads','4','--python-exit-code','1','--python',str(Path(__file__).resolve()),'--','--worker'],cwd=ROOT,stdout=log,stderr=subprocess.STDOUT,check=True)
        compose();print('Prévias da geometria real em docs/npc-v2/previews/ (Blender, sem Roblox Studio).')
