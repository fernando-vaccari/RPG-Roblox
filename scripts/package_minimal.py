#!/usr/bin/env python3
"""Package ONLY two verified Places; no installer, tool or helper in the ZIP.

Reducing contents is not antivirus clearance. Preserve the previous delivery.
"""
from pathlib import Path
import hashlib
import json
import xml.etree.ElementTree as ET
import zipfile

ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / 'delivery-minimal/0.6.1'
NAMES = ('ProjectMedievalRPG.rbxlx', 'ProjectMedievalRPG_Dungeon.rbxlx')


def main():
    manifest = json.loads((ROOT / 'build/BUILD_MANIFEST.json').read_text())
    expected = {p['file']: p['sha256'] for p in manifest['places']}
    payloads = {}
    for name in NAMES:
        data = (ROOT / 'build' / name).read_bytes()
        assert hashlib.sha256(data).hexdigest() == expected[name], 'Stale/unverified build: ' + name
        assert ET.fromstring(data).tag == 'roblox'
        payloads[name] = data
    DEST.mkdir(parents=True, exist_ok=True)
    for name, data in payloads.items():
        (DEST / name).write_bytes(data)
    archive = DEST / 'Eldravyn-0.6.1-Places.zip'
    with zipfile.ZipFile(archive, 'w', compression=zipfile.ZIP_DEFLATED) as z:
        for name in NAMES:
            # Stable metadata for reproducible packaging; not an AV workaround.
            info = zipfile.ZipInfo(name, (1980, 1, 1, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o100644 << 16
            z.writestr(info, payloads[name])
    with zipfile.ZipFile(archive) as z:
        assert tuple(z.namelist()) == NAMES and z.testzip() is None
        for name in NAMES:
            assert z.read(name) == payloads[name]
    checks = []
    for path in [DEST / name for name in NAMES] + [archive]:
        checks.append(hashlib.sha256(path.read_bytes()).hexdigest() + '  ' + path.name)
    (DEST / 'SHA256SUMS.txt').write_text('\n'.join(checks) + '\n', encoding='utf-8')
    print('Minimal ZIP: exactly two Places, CRC valid; hashes outside ZIP.')
    print('\n'.join(checks))
    print('Antivirus/Studio not executed; no claim of safety.')


if __name__ == '__main__':
    main()
