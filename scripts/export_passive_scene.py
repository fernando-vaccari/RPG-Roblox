#!/usr/bin/env python3
"""Create an editor-only data scene, excluding ALL project executable code.

Not a malware remover or an antivirus verdict. The original stays untouched.
No artifact code is evaluated, imported or executed.
"""
from pathlib import Path
import copy
import hashlib
import json
import struct
import xml.etree.ElementTree as ET

ROOT=Path(__file__).resolve().parents[1]
SOURCE=ROOT/'delivery-map/task-01/Eldravyn-Continent.rbxlx'
SOURCE_SHA='a08fd280bd8835943f3e29c0777196e277831cb39e1405560cc892779fc49dab'
DEST=ROOT/'delivery-map/passive-scene'
NAME='Eldravyn-Continent-SceneryOnly.rbxlx'
ALLOWED={'Workspace','Folder','Model','Part','WedgePart','SpawnLocation','SurfaceGui',
         'TextLabel','PointLight','Lighting','Atmosphere','BloomEffect',
         'ColorCorrectionEffect','SunRaysEffect','Sky'}

def sha(data):return hashlib.sha256(data).hexdigest()

def geometry_digest(element):
    """Compare retained structure/properties exactly, except custom metadata."""
    digest=hashlib.sha256()
    def walk(node):
        if node.get('name')=='AttributesSerialize':return
        token=json.dumps([node.tag,sorted(node.attrib.items()),(node.text or '').strip()],ensure_ascii=False).encode('utf-8')
        digest.update(struct.pack('<I',len(token)));digest.update(token)
        for child in node:walk(child)
        digest.update(b'\x00')
    walk(element);return digest.hexdigest()

def main():
    data=SOURCE.read_bytes();assert sha(data)==SOURCE_SHA,'Unexpected source; review it separately'
    assert b'<!DOCTYPE' not in data and b'<!ENTITY' not in data
    original=ET.fromstring(data)
    output=ET.Element('roblox',original.attrib)
    original_digests={}
    for kind in ('Workspace','Lighting'):
        nodes=original.findall('./Item[@class="'+kind+'"]');assert len(nodes)==1
        original_digests[kind]=geometry_digest(nodes[0])
        kept=copy.deepcopy(nodes[0])
        assert all(n.get('class') in ALLOWED for n in kept.iter('Item'))
        for props in kept.iter('Properties'):
            for prop in list(props):
                if prop.get('name')=='AttributesSerialize':props.remove(prop)
        output.append(kept)
    instances=output.findall('.//Item')
    assert not any(n.get('class') in ('Script','LocalScript','ModuleScript','PackageLink') for n in instances)
    assert not output.findall('.//BinaryString') and not output.findall('.//SharedString')
    assert not output.findall('.//Properties/*[@name="Source"]')
    assert not output.findall('.//Properties/*[@name="LinkedSource"]')
    ids=[n.get('referent') for n in instances];assert len(ids)==len(set(ids))
    for ref in output.findall('.//Ref'):assert ref.text in ids or ref.text in ('null','nil')
    parts=sum(n.get('class') in ('Part','WedgePart','SpawnLocation') for n in instances)
    assert parts==20001
    for kind,digest in original_digests.items():
        assert geometry_digest(output.find('./Item[@class="'+kind+'"]'))==digest
    DEST.mkdir(parents=True,exist_ok=True)
    path=DEST/NAME
    ET.ElementTree(output).write(path,encoding='utf-8',xml_declaration=False)
    parsed=ET.parse(path).getroot()
    for kind,digest in original_digests.items():
        assert geometry_digest(parsed.find('./Item[@class="'+kind+'"]'))==digest
    assert sha(SOURCE.read_bytes())==SOURCE_SHA,'Original must stay untouched'
    digest=sha(path.read_bytes())
    manifest={'file':NAME,'bytes':path.stat().st_size,'sha256':digest,'source_sha256':SOURCE_SHA,
        'purpose':'editor-only passive scenery inspection','base_parts':parts,
        'user_script_instances':0,'source_properties':0,'binary_string_properties':0,
        'retained_geometry_and_lighting_match_original':True,
        'custom_integration_attributes_excluded':True,'native_terrain_baked':False,
        'terrain_generator_included':False,'studio_executed':False,
        'antivirus_scan_executed':False,'defender_verdict':'unknown; no clearance claimed'}
    (DEST/'MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n')
    (DEST/'SHA256SUMS.txt').write_text(digest+'  '+NAME+'\n')
    print(json.dumps(manifest,indent=2))

if __name__=='__main__':main()
