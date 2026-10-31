"""Choose exterior NPC anchors by inspecting the existing XML, never generate a map."""
from pathlib import Path
import xml.etree.ElementTree as ET,json,math,collections
from bake_continent import read_attributes
from npc_host import ROOT,run,luau
SOURCE=ROOT/'delivery-map/monumental/Eldravyn-Monumental.rbxlx'
def name(n):return n.findtext('./Properties/string[@name="Name"]','')
def props(n):return n.find('Properties')
def frame(n):
    p=props(n).find('./CoordinateFrame[@name="CFrame"]');return [float(p.findtext(k)) for k in ['X','Y','Z','R00','R01','R02','R10','R11','R12','R20','R21','R22']]
def size(n):
    p=props(n).find('./Vector3[@name="size"]')
    if p is None:p=props(n).find('./Vector3[@name="Size"]')
    return [float(p.findtext(k)) for k in ['X','Y','Z']]
def transform(cf,v):return [cf[i]+sum(cf[3+3*i+j]*v[j] for j in range(3)) for i in range(3)]
def local(cf,v):return [sum(cf[3+3*j+i]*(v[j]-cf[j]) for j in range(3)) for i in range(3)]
def index_tree(root):
    index={}
    def visit(n,path):
        for child in n.findall('Item'):
            p=path+'/'+name(child) if path else name(child)
            # Named anchors are unique. Repeated decoration names aren't anchors.
            index.setdefault(p,child);visit(child,p)
    visit(root,'');return index

def generate():
    tree=ET.parse(SOURCE);index=index_tree(tree.getroot());world=index['Workspace/GeneratedWorld']
    prefix='Workspace/GeneratedWorld/'
    out=run((ROOT/'scripts/npc_json.luau').read_text()+"\nprint('CATALOG:'..json(require(game.ReplicatedStorage.EldravynNPC.NPCConfig)))",'npc-catalog')
    catalog=json.loads(next(l[8:] for l in out.splitlines() if l.startswith('CATALOG:')))
    grid=collections.defaultdict(list);parts=[]
    for n in world.iter('Item'):
        if n.get('class') not in ('Part','WedgePart','SpawnLocation','MeshPart'):continue
        if props(n).findtext('./bool[@name="CanCollide"]')=='false':continue
        cf=frame(n);sz=size(n);half=[sum(abs(cf[3+3*i+j])*sz[j]/2 for j in range(3)) for i in range(3)]
        record=(cf,sz,half,name(n));parts.append(record)
        for gx in range(math.floor((cf[0]-half[0])/32),math.floor((cf[0]+half[0])/32)+1):
            for gz in range(math.floor((cf[2]-half[2])/32),math.floor((cf[2]+half[2])/32)+1):grid[gx,gz].append(record)
    used=[]
    def clear(p):
        if any(math.hypot(p[0]-o[0],p[2]-o[2])<9 for o in used):return False
        seen=set();center=[p[0],p[1]+3.7,p[2]];box=[2.5,3.5,2.5]
        for gx in range(math.floor((p[0]-2.5)/32),math.floor((p[0]+2.5)/32)+1):
            for gz in range(math.floor((p[2]-2.5)/32),math.floor((p[2]+2.5)/32)+1):
                for cf,sz,half,n in grid[gx,gz]:
                    key=id(cf)
                    if key in seen:continue
                    seen.add(key)
                    if any(abs(center[i]-cf[i])>=half[i]+box[i] for i in range(3)):continue
                    delta=local(cf,center)
                    if any(abs(delta[i])>=sz[i]/2+sum(abs(cf[3+3*j+i])*box[j] for j in range(3)) for i in range(3)):continue
                    return False
        return True
    buildings={}
    for path,n in index.items():
        a=read_attributes(props(n))
        if a.get('Template') and path.startswith(prefix+'Cities/'):
            city=path.split('/')[3];buildings.setdefault(city,[]).append((path,n,a))
    placements={};locations=[]
    for definition in catalog['Definitions']:
        role=catalog['Roles'][definition['Role']];city=definition['City'];template=role['Template'];fallback=False
        if template=='Spawn':
            path=prefix+'Spawns/ValoriaSpawn';anchor=index[path];cf=frame(anchor);sz=size(anchor);ground=cf[1]-sz[1]/2
            candidates=[(x,ground-cf[1],z) for z in (8,-8,16,-16) for x in (8,-8,16,-16)]
            description='Exterior do spawn ValoriaSpawn'
        elif template=='Dungeon':
            gate='MalgorthGate' if definition['Dungeon']=='MalgorthDepths' else 'FallenSanctumGate';path=prefix+'DungeonEntrance/'+gate+'/Forecourt';anchor=index[path];cf=frame(anchor);sz=size(anchor);ground=cf[1]+sz[1]/2
            candidates=[(x,ground-cf[1]+.12,z) for z in (0,-8,8,-16,16) for x in (-16,16,-24,24,-32,32)]
            description='Pátio existente da entrada '+gate
        else:
            matches=[b for b in buildings[city] if b[2]['Template']==template]
            if not matches:matches=[b for b in buildings[city] if b[2]['Template']=='Market'];fallback=True
            assert matches,(city,template)
            # Spread ambient workers across another real building when one exists.
            b=matches[1 if definition.get('Ambient') and len(matches)>1 else 0]
            path=b[0]+'/Foundation';anchor=index.get(path)
            if anchor is None:path=b[0]+'/Floor';anchor=index[path]
            cf=frame(anchor);sz=size(anchor)
            floor=index.get(b[0]+'/Floor');ground=frame(floor)[1]-size(floor)[1]/2 if floor is not None else cf[1]+sz[1]/2
            candidates=[(x,ground-cf[1]+.12,-sz[2]/2-gap) for gap in (9,15,21,27,34) for x in (-10,10,-18,18,-26,26)]
            description=b[2]['DisplayName']+' • exterior, lateral da fachada'
        found=None
        for offset in candidates:
            pos=transform(cf,offset)
            if clear(pos):found=(offset,pos);break
        assert found,('No safe exterior candidate',definition['Id'],path)
        offset,pos=found;used.append(pos)
        entry={'Id':definition['Id'],'Anchor':path.removeprefix(prefix),'Offset':list(offset),'Position':pos,'Yaw':math.atan2(cf[5],cf[3]),'Location':description,'FutureBuilding':fallback}
        placements[definition['Id']]=entry
        locations.append({**definition,**entry,'Name':role['Name'],'Title':role['Title']})
    regions={}
    for path,n in index.items():
        a=read_attributes(props(n));kind=a.get('IntegrationKind')
        if kind in ('CityHub','EncounterClearing','DungeonApproach'):
            region_id=a['RegionId'];regions[region_id]={'Anchor':path.removeprefix(prefix),'Name':region_id,'Radius':min(a.get('Radius',40),100)}
    result={'NPCs':placements,'Regions':regions}
    (ROOT/'src/npc/shared/PlacementConfig.luau').write_text('-- Generated from the existing XML by scripts/npc_placements.py; no map generation.\nreturn '+luau(result)+'\n')
    (ROOT/'docs/npc-stage2/LOCATIONS.json').write_text(json.dumps(locations,ensure_ascii=False,indent=2)+'\n')
    print(f'NPC placement: {len(placements)} exterior points; collision boxes tested against {len(parts)} existing collidable parts.')
    return result
if __name__=='__main__':generate()
