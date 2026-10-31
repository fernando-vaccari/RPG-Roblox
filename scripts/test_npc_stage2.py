#!/usr/bin/env python3
from npc_host import ROOT,run
print(run((ROOT/'tests/npc-stage2.integration.luau').read_text(),'npc-stage2-integration'),end='')

print(run((ROOT/'tests/npc-installer.integration.luau').read_text(),'npc-installer-integration'),end='')
