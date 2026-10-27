#!/usr/bin/env python3
"""Read-only structural/static audit of the reported 0.6.1 archive.

This is NOT an antivirus, sandbox or proof that a file is harmless.
Never extracts or executes archive members; JSON evidence is written to build/.
"""
from pathlib import Path, PurePosixPath
import ast
import collections
import hashlib
import io
import json
import re
import stat
import struct
import subprocess
import wave
import xml.etree.ElementTree as ET
import zipfile

ROOT = Path(__file__).resolve().parents[1]
BASELINE = 'ad159de046f98198a191a0b33d8dc1fa80c1e472'
ARCHIVE = ROOT / 'delivery/RPG-Roblox-Windows11.zip'
OUTPUT = ROOT / 'build/security-archive-audit.json'


def sha(data):
    return hashlib.sha256(data).hexdigest()


def main():
    data = ARCHIVE.read_bytes()
    baseline = subprocess.run(
        ['git', 'show', BASELINE + ':delivery/RPG-Roblox-Windows11.zip'],
        cwd=ROOT, check=True, capture_output=True).stdout
    assert data == baseline, 'Archive differs from the reported baseline; review separately'
    eocd = data.rfind(b'PK\x05\x06')
    assert eocd >= 0 and eocd + 22 + struct.unpack_from('<H', data, eocd + 20)[0] == len(data)
    indicators = {
        'dynamic_execution': r'\b(?:loadstring|loadfile|dofile|getfenv|setfenv|eval|exec|__import__)\s*\(',
        'remote_asset_require': r'\brequire\s*\(\s*(?:\d|[\'\"]https?://)',
        'antivirus_changes_or_encoded_powershell': r'Add-MpPreference|Set-MpPreference|DisableRealtimeMonitoring|EncodedCommand|FromBase64String|Invoke-Expression',
        'roblox_external_code_or_http': r'\b(?:HttpGet|HttpPost|RequestAsync|PostAsync|LoadAsset|GetObjects)\s*\(',
    }
    result = {
        'scope': 'static and structural inspection, NOT antivirus clearance',
        'baseline_commit': BASELINE,
        'reported_detection': 'Trojan:Script/Ulthar.A!ml',
        'defender_affected_item': 'ZIP webfile; no inner member identified',
        'archive_sha256': sha(data), 'archive_bytes': len(data),
        'archive_matches_git_baseline': True,
        'defender_executed': False, 'studio_executed': False,
        'entries': [], 'places': [], 'code_pattern_hits': [],
    }
    with zipfile.ZipFile(io.BytesIO(data)) as z:
        assert z.testzip() is None
        names = z.namelist()
        assert len(names) == len(set(n.casefold() for n in names))
        assert min(i.header_offset for i in z.infolist()) == 0
        sources = {Path(n).stem: z.read(n).decode('utf-8') for n in names
                   if n.startswith('RPG-Roblox/src/') and n.endswith('.luau')
                   and not n.endswith(('.server.luau', '.client.luau'))}
        for info in z.infolist():
            name = info.filename
            path = PurePosixPath(name)
            assert name.startswith('RPG-Roblox/') and not path.is_absolute()
            assert all(p not in ('..', '.') and ':' not in p for p in path.parts)
            assert '\\' not in name and '\x00' not in name
            assert not info.flag_bits & 1, 'Encrypted member'
            assert not stat.S_ISLNK(info.external_attr >> 16), 'Symlink member'
            value = z.read(info)
            relative = name.removeprefix('RPG-Roblox/')
            suffix = path.suffix
            assert suffix in ('', '.json', '.md', '.luau', '.ps1', '.py', '.txt', '.wav', '.rbxlx')
            assert not value.startswith((b'MZ', b'\x7fELF', b'PK\x03\x04')), 'Unexpected executable/nested ZIP'
            entry = {'path': name, 'bytes': len(value), 'sha256': sha(value), 'type': suffix or 'gitignore'}
            local = ROOT / relative
            entry['matches_checkout_at_audit'] = local.is_file() and local.read_bytes() == value
            if suffix == '.wav':
                assert value[:4] == b'RIFF' and value[8:12] == b'WAVE'
                assert struct.unpack_from('<I', value, 4)[0] + 8 == len(value), 'Appended RIFF data'
                with wave.open(io.BytesIO(value)) as w:
                    entry['audio'] = dict(zip(('channels', 'sample_bytes', 'rate', 'frames', 'compression', 'description'), w.getparams()))
                    assert w.getcomptype() == 'NONE'
            else:
                text = value.decode('utf-8')
                assert '\x00' not in text, 'NUL in text'
                if suffix in ('.luau', '.py', '.ps1'):
                    for kind, pattern in indicators.items():
                        for match in re.finditer(pattern, text, re.I):
                            result['code_pattern_hits'].append({'path': name, 'kind': kind,
                                'line': text.count('\n', 0, match.start()) + 1, 'match': match.group()})
                    if suffix == '.py':
                        tree = ast.parse(text, filename=name) # Parse only; no import/exec.
                        entry['python_imports'] = sorted({alias.name for node in ast.walk(tree)
                            if isinstance(node, ast.Import) for alias in node.names}
                            | {node.module for node in ast.walk(tree) if isinstance(node, ast.ImportFrom)})
                if suffix == '.json':
                    json.loads(text)
                if suffix == '.rbxlx':
                    assert '<!DOCTYPE' not in text and '<!ENTITY' not in text
                    xml = ET.fromstring(text)
                    assert xml.tag == 'roblox'
                    assert not xml.findall('.//BinaryString') and not xml.findall('.//SharedString')
                    assert not xml.findall('.//Content') and not xml.findall('.//ContentId')
                    classes = collections.Counter(n.get('class') for n in xml.findall('.//Item'))
                    assert classes['ModuleScript'] == 48 and classes['Script'] == classes['LocalScript'] == 1
                    assert not classes['PackageLink']
                    matched = 0
                    for item in xml.findall('.//Item'):
                        kind = item.get('class')
                        if kind not in ('ModuleScript', 'Script', 'LocalScript'):
                            continue
                        module = item.find("./Properties/string[@name='Name']").text
                        source = item.find("./Properties/*[@name='Source']").text
                        expected = sources[module] if kind == 'ModuleScript' else z.read(
                            'RPG-Roblox/src/' + ('server/Main.server.luau' if kind == 'Script' else 'client/Main.client.luau')).decode('utf-8')
                        assert source == expected, (name, module, 'Unaccounted embedded source')
                        matched += 1
                    result['places'].append({'path': name, 'classes': dict(classes),
                        'embedded_sources_matching_archive_source': matched, 'sha256': sha(value)})
            result['entries'].append(entry)
        result['entry_count'] = len(names)
        result['extension_counts'] = dict(collections.Counter(Path(n).suffix or 'gitignore' for n in names))
        result['crc_valid'] = True
        result['unique_normal_paths_no_symlinks_or_encryption'] = True
    OUTPUT.parent.mkdir(exist_ok=True)
    OUTPUT.write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print('Audited', len(result['entries']), 'members; report:', OUTPUT.relative_to(ROOT))
    print('Embedded sources: 50 per Place, all equal to reviewed archive source')
    print('Targeted code pattern hits:', len(result['code_pattern_hits']))
    print('This does NOT determine the Defender verdict or prove the archive harmless.')


if __name__ == '__main__':
    main()
