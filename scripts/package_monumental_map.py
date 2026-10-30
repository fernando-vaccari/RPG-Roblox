#!/usr/bin/env python3
"""Deliver one inspectable Place, keeping all prior map deliveries untouched.

Structural verification is not an antivirus scan or Roblox Studio validation.
"""
from pathlib import Path
import hashlib
import json
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / 'delivery-map/monumental'
NAME = 'Eldravyn-Monumental.rbxlx'


def main():
    source = ROOT / 'build' / NAME
    data = source.read_bytes()
    digest = hashlib.sha256(data).hexdigest()
    manifest = json.loads((ROOT / 'build/CONTINENT_MANIFEST.json').read_text())
    assert manifest['file'] == NAME and manifest['sha256'] == digest
    assert manifest['geometry_baked'] and not manifest['native_terrain_baked']
    assert not manifest['studio_executed']
    root = ET.fromstring(data)
    items = root.findall('.//Item')
    ids = [item.get('referent') for item in items]
    assert len(ids) == len(set(ids))
    valid = set(ids) | {'null', 'nil'}
    assert all(ref.text in valid for ref in root.findall('.//Ref'))
    assert not any(i.get('class') in ('Humanoid', 'ProximityPrompt', 'PackageLink') for i in items)
    sources = {(p.stem, 'ModuleScript'): p for base in ('src/shared', 'src/worldgen')
               for p in (ROOT / base).rglob('*.luau')}
    sources[('MapPreview', 'Script')] = ROOT / 'src/map-preview/MapPreview.server.luau'
    sources[('MapPreview', 'LocalScript')] = ROOT / 'src/map-preview/MapPreview.client.luau'
    found = set()
    for item in items:
        props = item.find('Properties')
        src = props.find("./*[@name='Source']") if props is not None else None
        if src is not None:
            key = (props.findtext("./string[@name='Name']"), item.get('class'))
            assert key in sources and key not in found, key
            assert src.text == sources[key].read_text(), ('Source differs', key)
            found.add(key)
    assert found == set(sources)
    assert sum(i.get('class') in ('Part', 'WedgePart', 'SpawnLocation') for i in items) == manifest['report']['Parts']
    assert len(data) < 100 * 1024 * 1024, 'GitHub single-file limit; review actual geometry budget'
    manifest.update(antivirus_scan_executed=False, defender_verdict='unknown',
                    source_files_verified=len(found), bytes=len(data),
                    previous_deliveries_preserved=True)
    DEST.mkdir(parents=True, exist_ok=True)
    (DEST / NAME).write_bytes(data)
    (DEST / 'MANIFEST.json').write_text(json.dumps(manifest, indent=2) + '\n')
    (DEST / 'SHA256SUMS.txt').write_text(digest + '  ' + NAME + '\n')
    print(f'{NAME}: {len(data)} bytes; {len(found)} sources verified; SHA-256 {digest}')


if __name__ == '__main__':
    main()
