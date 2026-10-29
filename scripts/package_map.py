#!/usr/bin/env python3
"""Deliver the materialized continent alone, with limitations outside the ZIP."""
from pathlib import Path
import hashlib
import json
import xml.etree.ElementTree as ET
import zipfile

ROOT=Path(__file__).resolve().parents[1]
DEST=ROOT/'delivery-map/task-01'
NAME='Eldravyn-Continent.rbxlx'

def main():
    manifest=json.loads((ROOT/'build/CONTINENT_MANIFEST.json').read_text())
    data=(ROOT/'build'/NAME).read_bytes()
    assert hashlib.sha256(data).hexdigest()==manifest['sha256'],'Build/manifest mismatch'
    assert manifest['geometry_baked'] is True and manifest['studio_executed'] is False
    root=ET.fromstring(data)
    classes=[i.get('class') for i in root.findall('.//Item')]
    assert sum(classes.count(c) for c in ('Part','WedgePart','SpawnLocation'))==manifest['report']['Parts']
    assert not any(c in classes for c in ('Humanoid','ProximityPrompt'))
    DEST.mkdir(parents=True,exist_ok=True)
    (DEST/NAME).write_bytes(data)
    archive=DEST/'Eldravyn-Continent-Task01.zip'
    with zipfile.ZipFile(archive,'w',compression=zipfile.ZIP_DEFLATED) as z:
        entry=zipfile.ZipInfo(NAME,(1980,1,1,0,0,0));entry.compress_type=zipfile.ZIP_DEFLATED
        entry.external_attr=0o100644<<16
        z.writestr(entry,data)
    with zipfile.ZipFile(archive) as z:
        assert z.namelist()==[NAME] and z.testzip() is None and z.read(NAME)==data
    (DEST/'CONTINENT_MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n')
    checks=[]
    for path in [DEST/NAME,archive]:
        digest=hashlib.sha256(path.read_bytes()).hexdigest()
        checks.append(digest+'  '+path.name)
        print(path.name,path.stat().st_size,'bytes',digest)
    (DEST/'SHA256SUMS.txt').write_text('\n'.join(checks)+'\n')
    print('ZIP contains one Place. Terrain completion/Studio/visual review remain pending; not antivirus clearance.')

if __name__=='__main__':main()
