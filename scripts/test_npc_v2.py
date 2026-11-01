#!/usr/bin/env python3
from npc_host import ROOT,run,luau
print(run((ROOT/'tests/npc-v2-visual.integration.luau').read_text(),'npc-v2-visual',v2=True),end='')
fixture='local CLIENT_V2_SOURCE='+luau((ROOT/'src/npc/client/NPCInteractionClient.client.luau').read_text())+'\n'+(ROOT/'tests/npc-v2-fixture.luau').read_text()
print(run(fixture+'\n'+(ROOT/'tests/npc-v2-migration.integration.luau').read_text(),'npc-v2-migration',v2=True),end='')
print(run(fixture+'\n'+(ROOT/'tests/npc-v2-runtime.integration.luau').read_text(),'npc-v2-runtime',v2=True),end='')
