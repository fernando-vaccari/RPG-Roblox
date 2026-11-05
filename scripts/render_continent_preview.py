#!/usr/bin/env python3
"""Render actual exported geometry for composition review, outside Roblox Studio.

Usage: python3 scripts/render_continent_preview.py
Requires Blender and Pillow. No remote assets, generated concept art or game code
execution. Terrain is a sampled design surface, NOT baked Roblox Terrain. Native
Part/WedgePart/Ball/Cylinder geometry is reconstructed from exported transforms.
Studio materials, atmosphere, lights, physics and LOD are not reproduced.
Nearby SurfaceGui labels use their source text with approximate Blender font/fit.
These pictures cannot validate how the place looks/runs in Studio.
"""
from pathlib import Path
import argparse
import hashlib
import json
import math
import os
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


def parser():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--input', type=Path, default=ROOT / 'build/continent-scene.json')
    p.add_argument('--output-dir', type=Path, default=ROOT / 'build/previews')
    p.add_argument('--views', nargs='+', choices=['capital', 'forest', 'continent', 'houses'], default=['capital', 'forest', 'continent', 'houses'])
    p.add_argument('--width', type=int, default=1600)
    p.add_argument('--blender-worker', action='store_true')
    return p


def primitives():
    # Roblox X/Y/Z coordinates, normalized half extents.
    cube = ([(x, y, z) for x in (-.5, .5) for y in (-.5, .5) for z in (-.5, .5)],
            [(0, 1, 3, 2), (4, 6, 7, 5), (0, 4, 5, 1), (2, 3, 7, 6), (0, 2, 6, 4), (1, 5, 7, 3)])
    # Wedge slopes from -Y/-Z to +Y/+Z, along local Z; full rear at +Z.
    wedge = ([(-.5, -.5, -.5), (.5, -.5, -.5), (-.5, -.5, .5), (.5, -.5, .5), (-.5, .5, .5), (.5, .5, .5)],
             [(1, 3, 2, 0), (3, 5, 4, 2), (4, 5, 1, 0), (2, 4, 0), (5, 3, 1)])
    vertices, faces = [], []
    for x in (-.5, .5):
        for i in range(12):
            a = i * math.tau / 12
            vertices.append((x, math.sin(a) * .5, math.cos(a) * .5))
    faces += [tuple(range(11, -1, -1)), tuple(range(12, 24))]
    for i in range(12):
        j = (i + 1) % 12
        faces.append((i, j, j + 12, i + 12))
    cylinder = (vertices, [tuple(reversed(face)) for face in faces])
    vertices, faces = [(0, -.5, 0)], []
    for ring in range(1, 6):
        theta = ring * math.pi / 6
        for i in range(10):
            a = i * math.tau / 10
            vertices.append((math.sin(theta) * math.sin(a) * .5, -math.cos(theta) * .5, math.sin(theta) * math.cos(a) * .5))
    vertices.append((0, .5, 0))
    for i in range(10):
        j = (i + 1) % 10
        faces += [(0, 1 + j, 1 + i), (51, 41 + i, 41 + j)]
        for ring in range(4):
            a = 1 + ring * 10
            faces.append((a + i, a + j, a + 10 + j, a + 10 + i))
    return {'Block': cube, 'WedgePart': wedge, 'Cylinder': cylinder, 'Ball': (vertices, faces)}


def worker(args):
    import bpy
    from mathutils import Vector, Matrix
    source_bytes = args.input.read_bytes()
    source_hash = hashlib.sha256(source_bytes).hexdigest()
    data = json.loads(source_bytes)
    args.output_dir.mkdir(parents=True, exist_ok=True)
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)
    shapes = primitives()
    groups = {}
    smooth_faces = {}
    rendered = skipped = 0
    unsupported = {}
    def walk(node):
        yield node
        for child in node.get('Children', []):
            yield from walk(child)
    all_nodes = list(walk(data['Scene']))
    by_name = {node['Properties'].get('Name'): node for node in all_nodes}
    for node in all_nodes:
        kind, p = node['Class'], node['Properties']
        if kind not in ('Part', 'WedgePart', 'SpawnLocation'):
            if kind not in ('Folder', 'Model'):
                unsupported[kind] = unsupported.get(kind, 0) + 1
            continue
        if p.get('Transparency', 0) >= .85:
            skipped += 1
            continue
        size = p['Size']['Value']
        matrix = p['CFrame']['Value']
        color = tuple(round(x, 5) for x in p.get('Color', {'Value': [.5, .5, .5]})['Value'])
        shape = 'WedgePart' if kind == 'WedgePart' else p.get('Shape', 'PartType.Block').split('.')[-1]
        vertices, faces = shapes[shape]
        mesh_v, mesh_f = groups.setdefault(color, ([], []))
        offset = len(mesh_v)
        x, y, z, *r = matrix
        for v in vertices:
            vx, vy, vz = (v[i] * size[i] for i in range(3))
            wx = x + r[0] * vx + r[1] * vy + r[2] * vz
            wy = y + r[3] * vx + r[4] * vy + r[5] * vz
            wz = z + r[6] * vx + r[7] * vy + r[8] * vz
            mesh_v.append((wx, -wz, wy))
        if shape == 'Ball':
            smooth_faces.setdefault(color, []).extend(range(len(mesh_f), len(mesh_f) + len(faces)))
        mesh_f.extend(tuple(offset + i for i in f) for f in faces)
        rendered += 1
    terrain = data.get('TerrainPreview')
    assert terrain and terrain.get('Rows'), 'Export actual TerrainMath height grid; do not substitute a flat ground plane.'
    rows, step = terrain['Rows'], terrain['Step']
    nx, nz = len(rows[0]), len(rows)
    verts = [(terrain['OriginX'] + x * step, -(terrain['OriginZ'] + z * step), rows[z][x]) for z in range(nz) for x in range(nx)]
    faces = [(z * nx + x, (z + 1) * nx + x, (z + 1) * nx + x + 1, z * nx + x + 1) for z in range(nz - 1) for x in range(nx - 1)]
    terrain_v, terrain_f = groups.setdefault((.30, .43, .24), ([], []))
    terrain_offset = len(terrain_v)
    terrain_v.extend(verts)
    terrain_f.extend(tuple(terrain_offset + i for i in f) for f in faces)
    water_v, water_f = [], []
    water = terrain.get('WaterRows', [])
    for z in range(len(water) - 1):
        for x in range(len(water[z]) - 1):
            levels = [water[z + dz][x + dx] for dx, dz in ((0, 0), (0, 1), (1, 1), (1, 0))]
            # Deliberately avoid painting water over land at coarse boundary cells.
            if all(isinstance(n, (int, float)) and not isinstance(n, bool) for n in levels):
                k = len(water_v)
                water_v.extend((terrain['OriginX'] + (x + dx) * step, -(terrain['OriginZ'] + (z + dz) * step), levels[i] + .2) for i, (dx, dz) in enumerate(((0, 0), (0, 1), (1, 1), (1, 0))))
                water_f.append((k, k + 1, k + 2, k + 3))
    water_mesh_v, water_mesh_f = groups.setdefault((.28, .55, .64), ([], []))
    water_offset = len(water_mesh_v)
    water_mesh_v.extend(water_v)
    water_mesh_f.extend(tuple(water_offset + i for i in f) for f in water_f)
    polygons = 0
    for index, (color, (vertices, faces)) in enumerate(groups.items()):
        if not faces:
            continue
        mesh = bpy.data.meshes.new('ExportedGeometry')
        mesh.from_pydata(vertices, [], faces)
        mesh.update()
        for face_index in smooth_faces.get(color, []):
            mesh.polygons[face_index].use_smooth = True
        ob = bpy.data.objects.new('ActualGeometry_%03d' % index, mesh)
        bpy.context.collection.objects.link(ob)
        mat = bpy.data.materials.new('SourceColor')
        mat.diffuse_color = (*color, 1)
        ob.data.materials.append(mat)
        polygons += len(faces)
    scene = bpy.context.scene
    scene.render.engine = 'BLENDER_WORKBENCH'
    scene.render.resolution_x = args.width
    scene.render.resolution_y = round(args.width * 9 / 16)
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = 'PNG'
    scene.render.film_transparent = False
    scene.display.shading.light = 'STUDIO'
    scene.display.shading.studiolight_rotate_z = math.radians(25)
    scene.display.shading.color_type = 'MATERIAL'
    scene.display.shading.show_shadows = True
    scene.display.shading.show_cavity = True
    scene.display.shading.cavity_type = 'BOTH'
    scene.display.shading.curvature_ridge_factor = 1.3
    scene.display.shading.curvature_valley_factor = 1.0
    scene.display.shading.cavity_ridge_factor = 1.2
    scene.display.shading.cavity_valley_factor = 1.2
    scene.display.shading.show_specular_highlight = False
    scene.display.shading.background_type = 'WORLD'
    scene.world.color = (.45, .65, .75)
    scene.view_settings.view_transform = 'Standard'
    bpy.ops.object.camera_add()
    camera = bpy.context.object
    camera.data.clip_end = 20000
    camera.data.lens = 45
    scene.camera = camera
    def anchor(name, fallback):
        node = by_name.get(name)
        return tuple(node['Properties']['CFrame']['Value'][:3]) if node else fallback
    cx, cy, cz = anchor('Valoria_Services', (0, 44, 1000))
    city_radius = by_name.get('Valoria_Services', {}).get('Attributes', {}).get('Radius', 560)
    fx, fy, fz = anchor('Nocthar_Clearing', (-1000, 44, 1000))
    world_width = (nx - 1) * step
    houses = [n for n in all_nodes if n.get('Attributes', {}).get('Template') in ('Tavern', 'SmallHouse', 'LargeHouse')
              and n['Properties'].get('Name', '').startswith('Valoria_')]
    # A facade view uses its actual foundation transform, including the authored yaw.
    house = next((n for n in houses if n.get('Attributes', {}).get('Template') == 'Tavern'), houses[0] if houses else None)
    foundation = next((n for n in walk(house) if n['Properties'].get('Name') == 'Foundation'), None) if house else None
    def relative_house(v):
        if not foundation:
            return (cx + v[0], cy + v[1], cz + v[2])
        x, y, z, *r = foundation['Properties']['CFrame']['Value']
        return (x + sum(r[i] * v[i] for i in range(3)),
                y + sum(r[3 + i] * v[i] for i in range(3)),
                z + sum(r[6 + i] * v[i] for i in range(3)))
    views = {
        'capital': ((cx + city_radius * 1.22, cy + city_radius * .98, cz + city_radius * 1.48), (cx, cy + 26, cz), 43),
        'forest': ((fx + world_width * .075, fy + 235, fz + world_width * .095), (fx, fy + 48, fz), 40),
        'continent': ((world_width * .9, world_width * 1.2, world_width * .9), (0, 35, 0), 43),
        'houses': (relative_house((39, 27, -72)), relative_house((0, 13, -6)), 45),
    }
    # SurfaceGui typography is an approximation, sourced from actual TextLabel
    # values rather than invented labels. Limit it to the inspected neighbourhood.
    text_objects = 0
    house_focus = relative_house((0, 0, 0))
    if 'houses' in args.views:
        conversion = Matrix(((1, 0, 0, 0), (0, 0, -1, 0), (0, 1, 0, 0), (0, 0, 0, 1)))
        front = Matrix(((-1, 0, 0, 0), (0, 1, 0, 0), (0, 0, -1, 0), (0, 0, 0, 1)))
        for node in all_nodes:
            props = node['Properties']
            if node['Class'] != 'Part' or 'CFrame' not in props:
                continue
            x, y, z, *r = props['CFrame']['Value']
            if sum((a - b) ** 2 for a, b in zip((x, y, z), house_focus)) > 110 ** 2:
                continue
            for gui in node.get('Children', []):
                if gui['Class'] != 'SurfaceGui' or gui['Properties'].get('Face') != 'NormalId.Front':
                    continue
                for label in gui.get('Children', []):
                    if label['Class'] != 'TextLabel':
                        continue
                    label_props = label['Properties']
                    text_value = label_props.get('Text', '')
                    if not text_value:
                        continue
                    curve = bpy.data.curves.new('ActualSurfaceGuiText', 'FONT')
                    curve.body = text_value
                    curve.align_x = 'CENTER'
                    curve.align_y = 'CENTER'
                    curve.size = 1
                    ob = bpy.data.objects.new('ApproximatedGuiLabel', curve)
                    bpy.context.collection.objects.link(ob)
                    bpy.context.view_layer.update()
                    size = props['Size']['Value']
                    scale = min(size[0] * .92 / max(ob.dimensions.x, .01), size[1] * .78 / max(ob.dimensions.y, .01))
                    transform = Matrix(((r[0], r[1], r[2], x), (r[3], r[4], r[5], y), (r[6], r[7], r[8], z), (0, 0, 0, 1)))
                    offset = Matrix.Translation((0, 0, -size[2] / 2 - .025))
                    ob.matrix_world = conversion @ transform @ offset @ front @ Matrix.Diagonal((scale, scale, scale, 1))
                    mat = bpy.data.materials.new('ActualTextColor')
                    mat.diffuse_color = (*label_props.get('TextColor3', {'Value': [1, .85, .5]})['Value'], 1)
                    ob.data.materials.append(mat)
                    text_objects += 1

    def converted(p):
        return Vector((p[0], -p[2], p[1]))
    for view in args.views:
        eye, target, lens = views[view]
        camera.location = converted(eye)
        direction = converted(target) - camera.location
        camera.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
        camera.data.lens = lens
        scene.render.filepath = str(args.output_dir / (view + '.png'))
        bpy.ops.render.render(write_still=True)
    report = {
        'source_sha256': source_hash,
        'rendered_native_parts': rendered, 'hidden_parts_skipped': skipped,
        'polygons': polygons, 'omitted_nonmesh_instances': unsupported,
        'terrain_source': 'TerrainMath sampled design heights, not native voxel serialization',
        'terrain_sample_step': step, 'renderer': 'Blender Workbench',
        'studio_executed': False, 'gameplay_or_performance_validated': False,
        'limitations': ['Studio material/light/atmosphere rendering is not reproduced', 'SurfaceGui text uses actual label values but approximate Blender font/fit', 'Partial transparency approximated as opaque', 'Ball/cylinder surfaces tessellated for preview', 'Sampled water omits shoreline cells crossing dry land'],
        'views': args.views,
        'camera_positions_roblox': views,
        'world_width_studs': world_width,
        'approximated_surfacegui_text_objects': text_objects,
        'house_view_model': house['Properties'].get('Name') if house else None,
    }
    (args.output_dir / 'PREVIEW_REPORT.json').write_text(json.dumps(report, indent=2) + '\n')


def main():
    args = parser().parse_args(sys.argv[sys.argv.index('--') + 1:] if '--' in sys.argv else None)
    if args.blender_worker:
        worker(args)
        return
    from PIL import Image, ImageDraw, ImageFont
    render_env = dict(os.environ, MESA_SHADER_CACHE_DIR=str(ROOT / 'build/mesa-shader-cache'))
    subprocess.run(['blender', '--background', '--threads', '4', '--python', str(Path(__file__).resolve()), '--', '--blender-worker', '--input', str(args.input.resolve()), '--output-dir', str(args.output_dir.resolve()), '--width', str(args.width), '--views', *args.views], check=True, env=render_env)
    font_file = '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
    report = json.loads((args.output_dir / 'PREVIEW_REPORT.json').read_text())
    for view in args.views:
        path = args.output_dir / (view + '.png')
        im = Image.open(path).convert('RGB')
        draw = ImageDraw.Draw(im)
        size = max(15, args.width // 75)
        font = ImageFont.truetype(font_file, size)
        draw.rectangle((0, 0, im.width, size * 3), fill=(20, 29, 35))
        draw.text((20, 9), 'ELDRAVYN | ' + {'capital': 'Valoria — muralhas e bairros', 'forest': 'Nocthar — floresta monumental', 'continent': f"Continente de {report['world_width_studs']:,} × {report['world_width_studs']:,} studs", 'houses': 'Arquitetura e placas das fachadas'}[view], font=font, fill=(237, 224, 195))
        note = 'Prévia da geometria exportada • Blender • Terrain amostrado • NÃO é captura do Roblox Studio'
        note_font = font
        while draw.textlength(note, font=note_font) > im.width - 40:
            note_font = ImageFont.truetype(font_file, note_font.size - 1)
        draw.text((20, size + 13), note, font=note_font, fill=(179, 197, 207))
        im.save(path)
    print('Offline mesh previews written to', args.output_dir)


if __name__ == '__main__':
    main()
