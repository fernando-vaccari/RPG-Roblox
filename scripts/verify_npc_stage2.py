#!/usr/bin/env python3
"""Verify delivery hashes and parse native NPC XML through Rojo/rbx-dom (not Studio)."""
from pathlib import Path
import hashlib,json,xml.etree.ElementTree as ET,subprocess
from npc_host import ROOT,BIN
from npc_placements import index_tree,name
OUT=ROOT/'delivery-npcs/stage-02'
manifest=json.loads((OUT/'MANIFEST.json').read_text())
for row in manifest['outputs']:
    path=OUT/row['file']
    assert path.stat().st_size==row['bytes'] and hashlib.sha256(path.read_bytes()).hexdigest()==row['sha256']
assert hashlib.sha256((ROOT/manifest['source']).read_bytes()).hexdigest()==manifest['source_sha256']
root=ET.parse(OUT/'Eldravyn-Monumental-NPCs.rbxlx').getroot();idx=index_tree(root)
folder=idx['Workspace/EldravynNPCs'];wrapper=ET.Element('roblox',version='4');wrapper.append(folder)
probe=ROOT/'build/npc-serialization-probe.rbxmx';ET.ElementTree(wrapper).write(probe,encoding='utf-8')
project=ROOT/'build/npc-serialization-probe.project.json'
project.write_text(json.dumps({'name':'NPCSerializationProbe','tree':{'$className':'DataModel','Workspace':{'$className':'Workspace','NPCs':{'$path':str(probe)}}}}))
output=ROOT/'build/npc-serialization-probe.rbxlx'
subprocess.run([str(BIN/'rojo'),'build',str(project),'--output',str(output)],cwd=ROOT,check=True)
parsed=ET.parse(output).getroot();items=list(parsed.iter('Item'));byref={i.get('referent'):i for i in items}
models=[i for i in items if i.get('class')=='Model']
assert len(models)==66
for model in models:
    rootref=model.findtext('./Properties/Ref[@name="PrimaryPart"]');assert name(byref[rootref])=='HumanoidRootPart'
    motors=[i for i in model.iter('Item') if i.get('class')=='Motor6D'];assert len(motors)==15
    for joint in motors:
        for prop in ('Part0','Part1'):assert byref[joint.findtext('./Properties/Ref[@name="'+prop+'"]')].get('class')=='Part'
    hum=model.find('./Item[@class="Humanoid"]');assert hum is not None and hum.findtext('./Properties/token[@name="RigType"]')=='1'
    assert model.findtext('./Properties/token[@name="ModelStreamingMode"]')=='1' # Atomic
    assert len([i for i in model.iter('Item') if i.get('class')=='ProximityPrompt'])==1
print('PASSOU NPC XML: hashes originais/entrega; round-trip Rojo de 66 R15, 990 motores e prompts/referências. Studio não executado.')
