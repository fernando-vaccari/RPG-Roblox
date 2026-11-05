#!/usr/bin/env python3
from npc_host import ROOT,run,luau
fixture='local CLIENT_V2_SOURCE='+luau((ROOT/'src/npc/client/NPCInteractionClient.client.luau').read_text())+'\n'+(ROOT/'tests/npc-v2-fixture.luau').read_text()
for v2 in (False,True):
    body=fixture+'\nlocal START_WITH_V2='+str(v2).lower()+'\nlocal AVATAR_BOOTSTRAP_SOURCE='+luau((ROOT/'src/avatar/client/Bootstrap.client.luau').read_text())+'\n'
    body+=(ROOT/'tests/avatar-fixture.luau').read_text()+'\n'+(ROOT/'tests/avatar.integration.luau').read_text()
    print(run(body,'avatar-v2'if v2 else'avatar-stage2',v2=True,avatar=True),end='')
