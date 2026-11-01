"""Limited test/authoring host; never runs Roblox Studio, physics or real DataStore."""
from pathlib import Path
import json,re,subprocess,os
ROOT=Path(__file__).resolve().parents[1]
BIN=ROOT/'.tools/bin'
def luau(v):
    if v is None:return 'nil'
    if isinstance(v,bool):return str(v).lower()
    if isinstance(v,(int,float)):return str(v)
    if isinstance(v,str):return json.dumps(v,ensure_ascii=False)
    if isinstance(v,list):return '{'+','.join(map(luau,v))+'}'
    return '{'+','.join('['+luau(k)+']='+luau(x) for k,x in v.items())+'}'
def bundle(body,v2=False):
    api=json.loads((ROOT/'.tools/roblox-api.json').read_text())
    classes={c['Name']:{'Super':c['Superclass'],'NotCreatable':'NotCreatable' in c.get('Tags',[]),'Props':{m['Name']:True for m in c['Members'] if m['MemberType'] in ('Property','Callback')},'Events':{m['Name']:True for m in c['Members'] if m['MemberType']=='Event'}} for c in api['Classes']}
    needed={'DataModel','Workspace','ServerStorage','ServerScriptService','ReplicatedStorage','Players','Player','Terrain','RunService','HttpService','DataStoreService','Lighting','TweenService','Debris','MarketplaceService','PathfindingService','UserInputService','TeleportService','ProximityPromptService','PlayerGui','Backpack','StarterPlayer','StarterPlayerScripts','Folder','ModuleScript','Model','Part','SpawnLocation','Camera','Script','LocalScript','StringValue','ObjectValue'}
    for path in (ROOT/'src').rglob('*.luau'):needed.update(re.findall(r"Instance\.new\(['\"](\w+)['\"]\)",path.read_text()))
    for k in list(needed):
        while k in classes:needed.add(k);k=classes[k]['Super']
    classes={k:c for k,c in classes.items() if k in needed}
    enums={e['Name']:{i['Name']:e['Name']+'.'+i['Name'] for i in e['Items']} for e in api['Enums']}
    lines=["local Mock=require('../tests/StudioMock')",'local env=Mock.new('+luau(enums)+','+luau(classes)+')']
    for name in ['game','workspace','Instance','Vector3','CFrame','Color3','Vector2','UDim2','UDim','OverlapParams','RaycastParams','task','warn','TweenInfo','typeof']:lines.append(f'local {name}=env.{name}')
    lines+=['local Enum=env.Enums','local loaders,cache={},{}','local function require(node) if cache[node] then return cache[node] end; assert(loaders[node],"NPC module missing: "..tostring(node and node.Name));local result=loaders[node](node);cache[node]=result;return result end']
    folders=set();paths={}
    def folder(expr):
        if expr in folders:return
        parent,name=expr.rsplit('.',1)
        if parent not in ('game.ReplicatedStorage','game.ServerScriptService','game.ServerStorage'):folder(parent)
        lines.append(f'do local n=Instance.new("Folder");n.Name="{name}";n.Parent={parent} end');folders.add(expr)
    mounts=[('src/shared','game.ReplicatedStorage.MedievalRPG'),('src/npc/shared','game.ReplicatedStorage.EldravynNPC'),('src/npc/server','game.ServerScriptService.EldravynNPC'),('src/npc/install','game.ServerStorage.NPCInstall'),('src/npc/client','game.ReplicatedStorage.TestNPCClient')]
    if v2:
        mounts += [('src/npc-v2/shared','game.ReplicatedStorage.EldravynNPCVisualV2'),('src/npc-v2/server','game.ServerScriptService.NPCV2Runtime'),('src/npc-v2/client','game.ReplicatedStorage.TestNPCV2Client'),('src/npc-v2/install','game.ServerStorage.NPCV2Install'),('src/npc-v2/baseline','game.ServerStorage.NPCV2Install.Baselines')]
    for base,mount in mounts:
        folder(mount)
        for path in sorted((ROOT/base).rglob('*.luau')):
            if path.name.endswith(('.server.luau','.client.luau')):continue
            expr=mount+''.join('.'+p for p in path.relative_to(ROOT/base).with_suffix('').parts)
            folder(expr.rsplit('.',1)[0]);paths[expr]=path
    paths['game.ServerScriptService.EldravynNPC.DataService']=ROOT/'src/server/Services/DataService.luau'
    paths['game.ServerScriptService.EldravynNPC.PurchaseService']=ROOT/'src/server/Services/PurchaseService.luau'
    paths['game.ServerScriptService.EldravynNPC.Placement']=ROOT/'src/npc/install/Placement.luau'
    for expr in paths:
        parent,name=expr.rsplit('.',1);lines.append(f'do local n=Instance.new("ModuleScript");n.Name="{name}";n.Source={luau(paths[expr].read_text())};n.Parent={parent} end')
    for expr,path in paths.items():lines.append(f'loaders[{expr}]=function(script)\n'+path.read_text()+'\nend')
    if v2:
        lines.insert(2,"local Extra=require('../tests/NPCV2Mock');Extra.install(env)")
    lines.append(body);return '\n'.join(lines)
def run(body,name='npc-host',v2=False):
    path=ROOT/'build'/f'{name}.luau';path.parent.mkdir(exist_ok=True);path.write_text(bundle(body,v2))
    result=subprocess.run([str(BIN/('luau.exe' if os.name=='nt' else 'luau')),str(path)],cwd=ROOT,capture_output=True,text=True)
    (ROOT/'build'/f'{name}.log').write_text(result.stdout+result.stderr)
    if result.returncode:raise RuntimeError(result.stdout[-4000:]+result.stderr[-4000:])
    return result.stdout
