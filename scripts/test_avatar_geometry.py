#!/usr/bin/env python3
"""Measure the authored meshes: circular profiles, curved armor, unchanged rig keys.
No renderer/Roblox simulation is involved in these geometry checks.
"""
from pathlib import Path
import json,math,unittest
ROOT=Path(__file__).resolve().parents[1]
DATA=json.loads((ROOT/'build/avatar-rounded-scene.json').read_text())
MODELS={m['Key']:m for m in DATA['Models']}

def vertices(key,bone,materials):
    p=MODELS[key]['Parts'][bone];indices={i for f,mat in zip(p['Faces'],p['Materials'])if mat in materials for i in f}
    return [p['Vertices'][i]for i in sorted(indices)]

class RoundedGeometry(unittest.TestCase):
    def test_head_is_cylindrical_not_superellipse_box(self):
        ring=[v for v in vertices('NPC_Valoria_Blacksmith','Head',{'Skin','Face'})if abs(v[1]-5.60)<1e-7]
        self.assertEqual(len(ring),32)
        for x,_,z in ring:self.assertAlmostEqual((x/.665)**2+(z/.52)**2,1,places=6)

    def test_arm_has_oval_cross_section(self):
        ring=[v for v in vertices('NPC_Valoria_Blacksmith','LeftUpperArm',{'ClothNavy'})if abs(v[1]-4.20)<1e-7]
        self.assertEqual(len(ring),24)
        for x,_,z in ring:self.assertAlmostEqual(((x+1.35)/.41)**2+(z/.42)**2,1,places=6)

    def test_cuirass_curves_in_depth(self):
        row=[v for v in vertices('NPC_Arkheim_Ambient_Guard','UpperTorso',{'ClothRed'})if abs(v[1]-3.95)<1e-7]
        self.assertEqual(len(row),34) # front/back, 17 samples each
        front={round(x,6):min(v[2]for v in row if abs(v[0]-x)<1e-7)for x,_,_ in row}
        self.assertGreater(front[.77]-front[0],.16)

    def test_rig_ids_origins_roles_unchanged(self):
        previous=json.loads((ROOT/'assets/avatars/source/CATALOG.json').read_text())
        current=json.loads((ROOT/'assets/avatars-rounded/source/CATALOG.json').read_text())
        self.assertEqual(previous,current)
        self.assertEqual(len(MODELS),80)
        self.assertEqual(sum(len(m['Parts'])for m in DATA['Models']),1162)

    def test_meshes_uv_and_budget(self):
        triangles=0
        for model in DATA['Models']:
            for part in model['Parts'].values():
                self.assertTrue(part['Vertices']and part['Faces'])
                for vertex in part['Vertices']:
                    self.assertTrue(all(math.isfinite(n)for n in vertex))
                for face,uv in zip(part['Faces'],part['UV']):
                    self.assertTrue(all(0<=i<len(part['Vertices'])for i in face));self.assertEqual(len(face),len(uv))
                    self.assertTrue(all(0<=n<=1 for point in uv for n in point));triangles+=len(face)-2
        self.assertLess(triangles,1_000_000) # entire source library, not one scene

if __name__=='__main__':unittest.main(verbosity=2)
