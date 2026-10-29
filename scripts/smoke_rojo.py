#!/usr/bin/env python3
"""Read-only functional check of the pinned Rojo live-sync API."""
import re
import urllib.request

def read(path):
    with urllib.request.urlopen('http://127.0.0.1:34872' + path, timeout=10) as response:
        assert response.status == 200
        assert response.headers.get('Content-Type') == 'application/msgpack'
        return response.read()

metadata = read('/api/rojo')
assert b'ProjectMedievalRPG' in metadata and b'7.7.1' in metadata
# Rojo 7.7.1's MessagePack API encodes its root UUID as a 32-byte string.
match = re.search(rb'rootInstanceId\xd9\x20([a-f0-9]{32})', metadata)
assert match, 'rootInstanceId ausente no protocolo esperado'
tree = read('/api/read/' + match.group(1).decode('ascii'))
for expected in [b'WorldGenerator', b'WorldConfig', b'TerrainGenerator', b'ValidationGenerator', b'GenerateNewWorld', b'GameService', b'DungeonService', b'UIController', b'ContentGenerator']:
    assert expected in tree, 'Módulo/source ausente: ' + expected.decode()
print('PASSOU: API Rojo 7.7.1 entrega o projeto e os sources esperados (não testa conexão com Studio).')
