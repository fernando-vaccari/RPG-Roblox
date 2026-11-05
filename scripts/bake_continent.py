#!/usr/bin/env python3
"""Materialize map geometry as native XML instances using Luau CLI + Rojo.

The authoring host is simulated. Native Terrain is NOT baked by this script;
the output explicitly requires one editor completion command in Roblox Studio.
Only the stdlib and the project's already installed Luau/Rojo tools are used.
"""
from pathlib import Path
import argparse
import base64
import hashlib
import json
import math
import os
import re
import struct
import subprocess
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
BUILD = ROOT / 'build'
BIN = ROOT / '.tools/bin'
SUFFIX = '.exe' if os.name == 'nt' else ''


def string_bytes(value):
    data = value.encode('utf-8')
    return struct.pack('<I', len(data)) + data


def attributes_bytes(attributes):
    """rbx-dom/rbxattr AttributesSerialize framing; no executable payload.

    Reference: RobloxAPI/rbxattr spec and rbx-dom rbx_types attributes writer.
    Supports only the actual types authored here, rejects everything else.
    """
    if not attributes:
        return b''
    data = bytearray(struct.pack('<I', len(attributes)))
    for name, value in sorted(attributes.items()):
        data += string_bytes(name)
        if isinstance(value, bool):
            data += b'\x03' + bytes([value])
        elif isinstance(value, str):
            data += b'\x02' + string_bytes(value)
        elif isinstance(value, (int, float)):
            assert math.isfinite(value)
            data += b'\x06' + struct.pack('<d', value)
        elif isinstance(value, dict) and value.get('Type') in ('Vector3', 'Color3'):
            data += bytes([0x11 if value['Type'] == 'Vector3' else 0x0F])
            data += struct.pack('<fff', *value['Value'])
        elif isinstance(value, dict) and value.get('Type') == 'CFrame':
            v = value['Value']
            data += b'\x14' + struct.pack('<fff', *v[:3]) + b'\x00' + struct.pack('<9f', *v[3:])
        else:
            raise ValueError('Unsupported attribute type: ' + name)
    return bytes(data)


def add_attributes(properties, attributes):
    if attributes:
        ET.SubElement(properties, 'BinaryString', name='AttributesSerialize').text = base64.b64encode(attributes_bytes(attributes)).decode('ascii')


def read_attributes(properties):
    """Decode the limited attribute types written here to verify Rojo round-trip."""
    element = properties.find('./BinaryString[@name="AttributesSerialize"]')
    if element is None or not element.text:
        return {}
    data = memoryview(base64.b64decode(element.text)); offset = 0
    def take(fmt):
        nonlocal offset
        values = struct.unpack_from(fmt, data, offset); offset += struct.calcsize(fmt)
        return values[0] if len(values) == 1 else list(values)
    def text():
        nonlocal offset
        length = take('<I'); result = bytes(data[offset:offset + length]).decode('utf-8'); offset += length
        return result
    result = {}
    for _ in range(take('<I')):
        name, kind = text(), take('<B')
        if kind == 2:
            result[name] = text()
        elif kind == 3:
            result[name] = bool(take('<B'))
        elif kind == 6:
            result[name] = take('<d')
        elif kind in (0x0F, 0x11):
            result[name] = {'Type': 'Color3' if kind == 0x0F else 'Vector3', 'Value': take('<fff')}
        else:
            raise ValueError('Unexpected round-trip attribute type: ' + str(kind))
    assert offset == len(data), 'Trailing attribute bytes'
    return result


def number(parent, name, value):
    assert math.isfinite(value)
    ET.SubElement(parent, name).text = format(value, '.17g')


def property_xml(parent, name, value, descriptor, enum_values):
    category, kind = descriptor['ValueType']['Category'], descriptor['ValueType']['Name']
    if category == 'Enum':
        assert isinstance(value, str) and value in enum_values, (name, value)
        ET.SubElement(parent, 'token', name=name).text = str(enum_values[value])
    elif category == 'Class':
        assert value.get('Type') == 'Ref'
        ET.SubElement(parent, 'Ref', name=name).text = 'scene_' + str(value['Value'])
    elif isinstance(value, bool):
        ET.SubElement(parent, 'bool', name=name).text = str(value).lower()
    elif isinstance(value, str):
        ET.SubElement(parent, 'string', name=name).text = value
    elif isinstance(value, (int, float)):
        tag = 'int64' if kind == 'int64' else 'int' if kind in ('int', 'int32') else 'float' if kind == 'float' else 'double'
        node = ET.SubElement(parent, tag, name=name)
        assert math.isfinite(value)
        node.text = format(value, '.17g')
    elif isinstance(value, dict):
        typ, values = value['Type'], value['Value']
        if kind == 'Vector2':
            typ, values = 'Vector2', values[:2]
        tag = 'CoordinateFrame' if typ == 'CFrame' else typ
        node = ET.SubElement(parent, tag, name=name)
        keys = {'Vector2': ('X', 'Y'), 'Vector3': ('X', 'Y', 'Z'), 'Color3': ('R', 'G', 'B'),
                'UDim': ('S', 'O'), 'UDim2': ('XS', 'XO', 'YS', 'YO'),
                'CFrame': ('X', 'Y', 'Z', 'R00', 'R01', 'R02', 'R10', 'R11', 'R12', 'R20', 'R21', 'R22')}[typ]
        for key, val in zip(keys, values):
            number(node, key, val)
    else:
        raise TypeError((name, kind, value))


def make_model(record, classes, enum_values):
    root = ET.Element('roblox', version='4')
    def find_property(kind, name):
        while kind in classes:
            entry = classes[kind]
            for prop in entry['Members']:
                if prop['MemberType'] == 'Property' and prop['Name'] == name:
                    return prop
            kind = entry['Superclass']
        raise ValueError('Unknown property ' + record['Class'] + '.' + name)
    def item(parent, row):
        node = ET.SubElement(parent, 'Item', {'class': row['Class'], 'referent': 'scene_' + str(row['Id'])})
        props = ET.SubElement(node, 'Properties')
        for key, value in sorted(row['Properties'].items()):
            desc = find_property(row['Class'], key)
            if not desc.get('Serialization', {}).get('CanLoad', False):
                continue
            property_xml(props, key, value, desc, enum_values)
        add_attributes(props, row['Attributes'])
        for child in row['Children']:
            item(node, child)
    item(root, record)
    return root


def luau(value):
    if value is None:
        return 'nil'
    if isinstance(value, bool):
        return str(value).lower()
    if isinstance(value, (int, float)):
        return str(value)
    if isinstance(value, str):
        return json.dumps(value, ensure_ascii=False)
    if isinstance(value, list):
        return '{' + ','.join(luau(v) for v in value) + '}'
    return '{' + ','.join('[' + luau(k) + ']=' + luau(v) for k, v in value.items()) + '}'


def author_scene(api):
    classes = {c['Name']: {'Super': c['Superclass'], 'NotCreatable': 'NotCreatable' in c.get('Tags', []),
        'Props': {m['Name']: True for m in c['Members'] if m['MemberType'] in ('Property', 'Callback')},
        'Events': {m['Name']: True for m in c['Members'] if m['MemberType'] == 'Event'}} for c in api['Classes']}
    enums = {e['Name']: {v['Name']: e['Name'] + '.' + v['Name'] for v in e['Items']} for e in api['Enums']}
    needed = {'DataModel', 'Workspace', 'ReplicatedStorage', 'ServerStorage', 'ServerScriptService', 'RunService',
        'Terrain', 'HttpService', 'Players', 'DataStoreService', 'Player', 'Lighting', 'TweenService', 'Debris',
        'MarketplaceService', 'PathfindingService', 'UserInputService', 'TeleportService', 'ProximityPromptService',
        'Atmosphere', 'BloomEffect', 'ColorCorrectionEffect', 'SunRaysEffect', 'Sky',
        'ModuleScript', 'Folder', 'Part', 'SurfaceGui', 'TextLabel', 'PointLight'}
    for path in (ROOT / 'src').rglob('*.luau'):
        needed.update(re.findall(r"Instance\.new\(['\"](\w+)['\"]\)", path.read_text()))
    for kind in list(needed):
        c = classes.get(kind)
        while c and c['Super'] in classes:
            needed.add(c['Super']); c = classes[c['Super']]
    classes = {k: v for k, v in classes.items() if k in needed}
    lines = ["local Mock=require('../tests/StudioMock')", 'local env=Mock.new(' + luau(enums) + ',' + luau(classes) + ')']
    for name in ['game', 'workspace', 'Instance', 'Vector3', 'CFrame', 'Color3', 'Vector2', 'UDim2', 'Region3',
                 'OverlapParams', 'RaycastParams', 'task', 'warn', 'UDim', 'TweenInfo', 'typeof']:
        lines.append(f'local {name}=env.{name}')
    lines += ['local Enum=env.Enums', 'local loaders,cache={},{}',
        'local function require(node) if cache[node]then return cache[node]end;assert(loaders[node],"Unmapped module");local r=loaders[node]();cache[node]=r;return r end']
    paths = {}
    for folder, mount in [('src/shared', 'game.ReplicatedStorage.MedievalRPG'), ('src/worldgen', 'game.ServerStorage.MedievalWorldgen')]:
        for path in [ROOT / folder] + sorted(p for p in (ROOT / folder).rglob('*') if p.is_dir()):
            expr = mount + ''.join('.' + p for p in path.relative_to(ROOT / folder).parts)
            parent, name = expr.rsplit('.', 1)
            lines.append(f'do local n=Instance.new("Folder");n.Name="{name}";n.Parent={parent} end')
        for path in sorted((ROOT / folder).rglob('*.luau')):
            expr = mount + ''.join('.' + p for p in path.relative_to(ROOT / folder).with_suffix('').parts)
            parent, name = expr.rsplit('.', 1); paths[path] = expr
            lines.append(f'do local n=Instance.new("ModuleScript");n.Name="{name}";n.Parent={parent} end')
    for path, expr in paths.items():
        lines.append(f'loaders[{expr}]=function()local script={expr}\n' + path.read_text() + '\nend')
    lines.append((ROOT / 'scripts/export_continent.luau').read_text())
    bundle = BUILD / 'export-continent.bundle.luau'
    bundle.write_text('\n'.join(lines), encoding='utf-8')
    result = subprocess.run([str(BIN / ('luau' + SUFFIX)), str(bundle)], cwd=ROOT, capture_output=True, text=True)
    if result.returncode:
        (BUILD / 'scene-authoring.log').write_text(result.stdout + result.stderr, encoding='utf-8')
        raise RuntimeError('Scene authoring failed; see build/scene-authoring.log:\n' + result.stderr[-4000:])
    for line in result.stdout.splitlines():
        if line.startswith('ELDRAVYN_SCENE_JSON:'):
            payload = json.loads(line.removeprefix('ELDRAVYN_SCENE_JSON:'))
            (BUILD / 'continent-scene.json').write_text(json.dumps(payload, ensure_ascii=False), encoding='utf-8')
            return payload
    raise RuntimeError('Authoring host did not emit a scene')


def namespace(root, prefix):
    names = {i.get('referent'): prefix + i.get('referent') for i in root.findall('.//Item')}
    for item in root.findall('.//Item'):
        item.set('referent', names[item.get('referent')])
    for ref in root.findall('.//Ref'):
        ref.text = names.get(ref.text, ref.text)


def run_rojo(project, output):
    subprocess.run([str(BIN / ('rojo' + SUFFIX)), 'build', str(project), '--output', str(output)], cwd=ROOT, check=True)


def bake(project, output, compact_xml=False):
    api = json.loads((ROOT / '.tools/roblox-api.json').read_text())
    classes = {c['Name']: c for c in api['Classes']}
    enums = {e['Name'] + '.' + v['Name']: v['Value'] for e in api['Enums'] for v in e['Items']}
    payload = author_scene(api)
    assert payload['StudioExecuted'] is False and payload['TerrainBaked'] is False
    scene_path, light_path = BUILD / 'ContinentScene.rbxmx', BUILD / 'ContinentLighting.rbxmx'
    ET.ElementTree(make_model(payload['Scene'], classes, enums)).write(scene_path, encoding='utf-8')
    ET.ElementTree(make_model(payload['Lighting'], classes, enums)).write(light_path, encoding='utf-8')
    # Rojo parses the XML and canonicalizes property aliases/types/attributes.
    scene_project = BUILD / 'scene-canonical.project.json'
    scene_project.write_text(json.dumps({'name': 'EldravynScene', 'tree': {'$className': 'DataModel',
        'Workspace': {'$className': 'Workspace', 'GeneratedWorld': {'$path': str(scene_path)}},
        'Lighting': {'$path': str(light_path)}}}), encoding='utf-8')
    canonical, base = BUILD / 'ContinentScene-canonical.rbxlx', BUILD / 'Continent-base.rbxlx'
    run_rojo(scene_project, canonical); run_rojo(project, base)
    root, scene = ET.parse(base).getroot(), ET.parse(canonical).getroot()
    namespace(root, 'base_'); namespace(scene, 'scene_')
    workspace = next(i for i in root.findall('./Item') if i.get('class') == 'Workspace')
    generated = next(i for i in scene.findall('./Item[@class="Workspace"]/Item')
        if i.find('./Properties/string[@name="Name"]').text == 'GeneratedWorld')
    root_attrs = read_attributes(generated.find('Properties'))
    for name in ('SceneOnly', 'TerrainPending', 'PreparedGeometry', 'Status', 'ConfigSignature', 'ProjectId'):
        assert root_attrs[name] == payload['Scene']['Attributes'][name], ('Attribute round-trip', name)
    workspace.append(generated)
    add_attributes(workspace.find('Properties'), payload['WorkspaceAttributes'])
    for prior in root.findall('./Item[@class="Lighting"]'):
        root.remove(prior)
    root.append(scene.find('./Item[@class="Lighting"]'))
    # Large maps exceed GitHub's file limit with deeply repeated indentation.
    # Keep normal XML tags, line breaks and all script text; omit only indentation.
    ET.indent(root, space='' if compact_xml else '  ')
    ET.ElementTree(root).write(output, encoding='utf-8', xml_declaration=False)
    items = root.findall('.//Item'); ids = [i.get('referent') for i in items]
    assert len(ids) == len(set(ids))
    for ref in root.findall('.//Ref'):
        assert ref.text in ids or ref.text in ('null', 'nil'), ('Dangling reference', ref.text)
    assert not any(i.get('class') in ('Humanoid', 'ProximityPrompt') for i in generated.findall('.//Item'))
    count = len(generated.findall('.//Item')) + 1
    manifest = {'file': output.name, 'sha256': hashlib.sha256(output.read_bytes()).hexdigest(),
        'scene_instances_baked': count, 'geometry_baked': True, 'native_terrain_baked': False,
        'compact_xml': compact_xml,
        'studio_executed': False, 'visual_quality_validated': False, 'requires_editor_completion': True,
        'prepare_command': 'require(game.ServerStorage.MedievalWorldgen.WorldGenerator).PrepareStudio()',
        'report': payload['Report']}
    (BUILD / 'CONTINENT_MANIFEST.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print('Geometry materialized:', count, 'native XML instances; Terrain and visual/physics validation still require Studio.')
    print(output.relative_to(ROOT), manifest['sha256'])
    return manifest


def self_test():
    # Attribute framing documented by rbx-dom/rbxattr, including UTF-8 byte length.
    values = {'Boolean': True, 'Number': 12345.0, 'String': 'é', 'Vector3': {'Type': 'Vector3', 'Value': [1, 2, 3]}}
    binary = attributes_bytes(values)
    assert struct.unpack_from('<I', binary)[0] == 4
    assert b'\x07\x00\x00\x00Boolean\x03\x01' in binary
    assert string_bytes('é') == b'\x02\x00\x00\x00\xc3\xa9'
    assert binary.endswith(b'\x11' + struct.pack('<fff', 1, 2, 3))
    assert attributes_bytes({}) == b''
    props = ET.Element('Properties'); add_attributes(props, values)
    assert read_attributes(props) == values
    api = json.loads((ROOT / '.tools/roblox-api.json').read_text())
    classes = {c['Name']: c for c in api['Classes']}
    enums = {e['Name'] + '.' + v['Name']: v['Value'] for e in api['Enums'] for v in e['Items']}
    model = {'Id': 1, 'Class': 'Model', 'Properties': {'Name': 'SerializationProbe',
        'PrimaryPart': {'Type': 'Ref', 'Value': 2}}, 'Attributes': values, 'Children': [
            {'Id': 2, 'Class': 'Part', 'Attributes': {}, 'Children': [], 'Properties': {
                'Name': 'ProbePart', 'Anchored': True, 'Material': 'Material.Slate', 'Shape': 'PartType.Ball',
                'Size': {'Type': 'Vector3', 'Value': [10, 2, 6]}, 'Color': {'Type': 'Color3', 'Value': [0.2, 0.4, 0.6]},
                'CFrame': {'Type': 'CFrame', 'Value': [1, 2, 3, 1, 0, 0, 0, 1, 0, 0, 0, 1]}}}]}
    path = BUILD / 'SceneExportProbe.rbxmx'
    ET.ElementTree(make_model(model, classes, enums)).write(path, encoding='utf-8')
    project = BUILD / 'scene-export-probe.project.json'
    project.write_text(json.dumps({'name': 'SceneExportProbe', 'tree': {'$className': 'DataModel',
        'Workspace': {'$className': 'Workspace', 'Probe': {'$path': str(path)}}}}))
    output = BUILD / 'SceneExportProbe.rbxlx'; run_rojo(project, output)
    tree = ET.parse(output).getroot(); parsed = tree.find('.//Item[@class="Model"]')
    assert read_attributes(parsed.find('Properties')) == values, 'Rojo must preserve serialized attributes'
    part = parsed.find('./Item[@class="Part"]')
    assert parsed.find('./Properties/Ref[@name="PrimaryPart"]').text == part.get('referent')
    assert [float(n.text) for n in part.find('./Properties/Vector3[@name="size"]')] == [10, 2, 6]
    assert part.find('./Properties/Color3uint8[@name="Color3uint8"]').text == '3368601'
    assert part.find('./Properties/token[@name="shape"]').text == str(enums['PartType.Ball'])
    print('PASSOU: scalar/UTF-8/vector attributes, XML aliases and object reference round-trip through Rojo; not an engine test.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--project', type=Path, default=ROOT / 'map.project.json')
    parser.add_argument('--output', type=Path, default=BUILD / 'Eldravyn-Continent.rbxlx')
    parser.add_argument('--self-test', action='store_true')
    parser.add_argument('--compact-xml', action='store_true', help='Omit XML indentation for large maps; preserve script text and line breaks')
    args = parser.parse_args(); BUILD.mkdir(exist_ok=True)
    if args.self_test:
        self_test()
    else:
        bake(args.project.resolve(), args.output.resolve(), args.compact_xml)
