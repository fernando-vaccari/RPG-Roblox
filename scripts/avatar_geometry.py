"""Original mesh authoring in Roblox studs. No catalog assets or runtime code.

R15 bone centers match the existing NPCs. Vertices/UVs form continuous meshes;
Blender is only used to smooth, export FBX/glTF and render these exact shapes.
"""
import math, random
from collections import defaultdict

R15={
 'LowerTorso':(0,3,0),'UpperTorso':(0,4,0),'Head':(0,5.25,0),
 'LeftUpperArm':(-1.35,4,0),'LeftLowerArm':(-1.35,3,0),'LeftHand':(-1.35,2.3,0),
 'RightUpperArm':(1.35,4,0),'RightLowerArm':(1.35,3,0),'RightHand':(1.35,2.3,0),
 'LeftUpperLeg':(-.5,1.95,0),'LeftLowerLeg':(-.5,.9,0),'LeftFoot':(-.5,.25,-.1),
 'RightUpperLeg':(.5,1.95,0),'RightLowerLeg':(.5,.9,0),'RightFoot':(.5,.25,-.1)}
QUAD={'BeastBody':(0,1.5,0),'BeastHead':(0,1.7,-1.15),'FrontLeft':(-.48,.7,-.75),
 'FrontRight':(.48,.7,-.75),'HindLeft':(-.48,.7,.85),'HindRight':(.48,.7,.85),'BeastTail':(0,1.6,1.4)}
COLORS={
 'Skin':(215,170,125),'SkinDeep':(147,95,65),'SkinPale':(237,204,171),
 'Steel':(118,131,145),'Silver':(186,196,205),'Gold':(187,132,43),'Bronze':(144,91,46),
 'BlackSteel':(40,44,54),'Bone':(211,199,168),'Leather':(72,43,26),'LeatherLight':(126,83,44),
 'ClothNavy':(29,46,78),'ClothRed':(105,25,34),'ClothGreen':(31,76,51),'ClothBrown':(92,61,35),
 'ClothPurple':(64,38,90),'Linen':(219,205,166),'White':(228,224,210),'Black':(16,16,21),
 'HairBrown':(54,33,22),'HairBlond':(165,120,57),'HairSilver':(156,160,164),
 'Mail':(81,91,102),'Wood':(88,59,37),'Rune':(60,150,165),'DemonSkin':(109,34,37),
 'DemonEye':(223,146,42),'Slime':(55,141,77),'Fur':(99,105,111),'DarkFur':(42,35,59),
 'Paper':(224,208,166),'Face':(215,170,125),'DemonFace':(109,34,37),'SkullFace':(211,199,168),
 'WraithFace':(28,23,42),'GreenEye':(100,189,140),'Crimson':(152,34,42),'Rope':(146,117,73),
}
SWATCHES=list(COLORS);TILES=8;TILE=128
PALETTES={'Valoria':('ClothNavy','Gold'),'Arkheim':('ClothRed','Bronze'),
 'Eldoria':('ClothGreen','Silver'),'Durakh':('ClothBrown','Bronze'),'Asterion':('ClothPurple','Silver'),
 'MalgorthDepths':('ClothRed','BlackSteel'),'FallenSanctum':('ClothNavy','Silver')}

def add(a,b):return tuple(x+y for x,y in zip(a,b))
def sub(a,b):return tuple(x-y for x,y in zip(a,b))
def mul(a,b):return tuple(x*b for x in a)
def dot(a,b):return sum(x*y for x,y in zip(a,b))
def cross(a,b):return (a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0])
def unit(a):return mul(a,1/max(math.sqrt(dot(a,a)),1e-9))
def rotate(p,angles):
 x,y,z=p;rx,ry,rz=angles
 x,y=x*math.cos(rz)-y*math.sin(rz),x*math.sin(rz)+y*math.cos(rz)
 x,z=x*math.cos(ry)+z*math.sin(ry),-x*math.sin(ry)+z*math.cos(ry)
 y,z=y*math.cos(rx)-z*math.sin(rx),y*math.sin(rx)+z*math.cos(rx)
 return x,y,z
def tile_uv(mat,u,v):
 i=SWATCHES.index(mat);return ((i%TILES+.035+u*.93)/TILES,1-(i//TILES+.035+(1-v)*.93)/TILES)

class Model:
 def __init__(self,key,label,kind='R15',origin=(0,0,0)):
  self.key,self.label,self.kind,self.origin=key,label,kind,origin;self.parts={}
 def mesh(self,bone,vertices,faces,mat,uv=None):
  item=self.parts.setdefault(bone,{'Vertices':[],'Faces':[],'UV':[],'Materials':[]})
  offset=len(item['Vertices']);item['Vertices'].extend(vertices)
  for f in faces:
   item['Faces'].append([offset+i for i in f]);item['Materials'].append(mat)
   coords=uv if uv else [(0,0),(1,0),(1,1),(0,1)]
   item['UV'].append([tile_uv(mat,*coords[i%len(coords)]) for i in range(len(f))])
 def loft(self,bone,rings,mat,n=16,power=.5):
  vertices=[]
  for y,w,d,x,z in rings:
   for i in range(n):
    a=2*math.pi*i/n;c,s=math.cos(a),math.sin(a)
    vertices.append((x+math.copysign(abs(c)**power,c)*w/2,y,z+math.copysign(abs(s)**power,s)*d/2))
  faces=[list(range(n-1,-1,-1))]
  for j in range(len(rings)-1):
   for i in range(n):faces.append([j*n+i,j*n+(i+1)%n,(j+1)*n+(i+1)%n,(j+1)*n+i])
  faces.append(list(range((len(rings)-1)*n,len(rings)*n)));self.mesh(bone,vertices,faces,mat)
 def rounded(self,bone,center,size,mat,bevel=.08):
  x,y,z=center;w,h,d=size;b=min(bevel,h*.25,w*.25,d*.25)
  self.loft(bone,[(y-h/2,w-b*2,d-b*2,x,z),(y-h/2+b,w,d,x,z),
   (y+h/2-b,w,d,x,z),(y+h/2,w-b*2,d-b*2,x,z)],mat)
 def sphere(self,bone,c,size,mat,rings=7,n=16):
  x,y,z=c;w,h,d=size
  self.loft(bone,[(y+math.cos(math.pi-i*math.pi/rings)*h/2,
   max(.006,math.sin(i*math.pi/rings)*w),max(.006,math.sin(i*math.pi/rings)*d),x,z)for i in range(rings+1)],mat,n,1)
 def tube(self,bone,points,radii,mat,n=8):
  verts=[]
  for i,c in enumerate(points):
   tangent=unit(sub(points[min(i+1,len(points)-1)],points[max(0,i-1)]))
   axis=(0,1,0) if abs(dot(tangent,(0,1,0)))<.94 else (1,0,0)
   a=unit(cross(tangent,axis));b=cross(tangent,a);r=radii[i] if isinstance(radii,list) else radii
   rw,rd=r if isinstance(r,tuple) else (r,r)
   for k in range(n):
    ang=k*math.tau/n;verts.append(add(c,add(mul(a,math.cos(ang)*rw),mul(b,math.sin(ang)*rd))))
  faces=[list(range(n-1,-1,-1))]
  for i in range(len(points)-1):
   for k in range(n):faces.append([i*n+k,i*n+(k+1)%n,(i+1)*n+(k+1)%n,(i+1)*n+k])
  faces.append(list(range((len(points)-1)*n,len(points)*n)));self.mesh(bone,verts,faces,mat)
 def plaque(self,bone,outline,z,depth,mat):
  v=[(x,y,z+dz)for dz in (-depth/2,depth/2)for x,y in outline];n=len(outline)
  self.mesh(bone,v,[list(range(n-1,-1,-1)),list(range(n,2*n))]+[[i,(i+1)%n,(i+1)%n+n,i+n]for i in range(n)],mat)
 def face(self,mat='Face'):
  # UV the actual head surface. No raised rectangle or 3D eyeballs.
  item=self.parts['Head']
  for i,face in enumerate(item['Faces']):
   points=[item['Vertices'][v]for v in face]
   if max(p[2]for p in points)<.001 and min(p[2]for p in points)<-.19 and max(p[1]for p in points)-min(p[1]for p in points)>.01:
    item['Materials'][i]=mat;item['UV'][i]=[tile_uv(mat,max(0,min(1,(p[0]+.665)/1.33)),max(0,min(1,(p[1]-4.72)/1.04)))for p in points]
 def hair(self,style='Short',mat='HairBrown'):
  self.sphere('Head',(0,5.67,.06),(1.43,.51,1.13),mat,rings=10,n=24)
  for side in (-1,1):
   self.tube('Head',[(side*.49,5.74,.05),(side*.66,5.52,.01),(side*.64,5.22,.03)],[(.18,.20),(.13,.18),(.04,.08)],mat)
  for i in range(7):
   x=(i-3)*.16
   a,b,c=(x-.16,5.83,.02),(x-.05,5.74,-.30),(x+.10,5.56-(i%3)*.035,-.48)
   points=[add(add(mul(a,(1-t)**2),mul(b,2*t*(1-t))),mul(c,t*t))for t in [j/9 for j in range(10)]]
   self.tube('Head',points,[(.15*(1-j/10)**.55,.12*(1-j/10)**.55)for j in range(10)],mat,n=12)
  if style=='Braided':
   for side in (-1,1):
    for i in range(10):
     t=i/9;self.sphere('Head',(side*.57+math.sin(t*19)*.035,5.25-t*.75,.43),(.20,.22,.20),mat,rings=4,n=8)
   self.tube('Head',[(-.60,4.52,.43),(-.58,4.58,.43)],.10,'Gold')
  if style=='Long':
   for i in range(5):
    x=(i-2)*.24;self.tube('Head',[(x,5.62,.43),(x*1.15,5.04,.54),(x*1.1,4.56,.55)],[(.19,.16),(.18,.12),(.03,.04)],mat)
 def curve(self,bone,center,scale,mat='Gold',mirror=1):
  # Original engraved scroll, a tapered spiral rather than a copied emblem.
  pts=[]
  for i in range(20):
   t=i/19;a=t*math.tau*1.15;r=scale*(1-t*.76)
   pts.append((center[0]+mirror*math.cos(a)*r,center[1]+math.sin(a)*r,center[2]))
  self.tube(bone,pts,[.024*(1-i/26)for i in range(20)],mat,n=6)
 def collar(self,cloth,metal):
  self.tube('UpperTorso',[(-.6,4.59,-.40),(-.26,4.64,-.51),(0,4.44,-.57),(.26,4.64,-.51),(.6,4.59,-.40)],.045,metal)
 def cape(self,cloth):
  verts=[];faces=[]
  for j in range(9):
   t=j/8
   for i in range(13):
    u=i/12;verts.append(((u-.5)*(1.82+.38*t),4.49-2.23*t,.54+.19*t+.06*math.cos(u*math.pi*8)))
  for j in range(8):
   for i in range(12):faces.append([j*13+i,j*13+i+1,(j+1)*13+i+1,(j+1)*13+i])
  self.mesh('UpperTorso',verts,faces,cloth)
  self.tube('UpperTorso',[(v[0],v[1]-.01,v[2]-.005)for v in verts[-13:]],.025,'Gold')
 def book(self):
  p=R15['LeftHand'];c=add(p,(0,-.01,-.29));self.rounded('LeftHand',c,(.65,.12,.83),'Leather',.025)
  self.rounded('LeftHand',add(c,(0,.085,0)),(.58,.08,.75),'Paper',.01)
  self.rounded('LeftHand',add(c,(-.28,.04,0)),(.06,.15,.85),'Gold',.01)
 def sword(self,bone='LowerTorso',held=False,metal='Silver'):
  x,y,z=R15[bone] if held else (-.98,2.92,.35)
  self.tube(bone,[(x,y+.25,z),(x,y-.16,z)],.075,'Leather',n=10)
  self.rounded(bone,(x,y-.18,z),(.64,.08,.15),'Gold',.035)
  self.plaque(bone,[(x-.10,y-.21),(x+.10,y-.21),(x+.13,y-1.53),(x,y-1.85),(x-.13,y-1.53)],z,.07,metal if held else 'Leather')
  self.tube(bone,[(x,y-.24,z-.045),(x,y-1.70,z-.045)],.014,'Gold' if not held else 'Steel',n=6)
 def shield(self,cloth,metal):
  x,y=-1.60,3.03;outline=[(x-.43,y+.64),(x+.43,y+.64),(x+.54,y+.29),(x+.39,y-.41),(x,y-.76),(x-.39,y-.41),(x-.54,y+.29)]
  self.plaque('LeftLowerArm',outline,-.42,.16,'Steel');self.plaque('LeftLowerArm',[(x+(a-x)*.86,y+(b-y)*.88)for a,b in outline],-.515,.03,cloth)
  self.tube('LeftLowerArm',[(a,b,-.54)for a,b in outline+[outline[0]]],.035,metal)
  for side in (-1,1):self.curve('LeftLowerArm',(x+side*.17,y+.03,-.56),.17,metal,side)
 def armor(self,cloth,metal):
  outline=[(-.83,4.45),(-.51,4.62),(-.25,4.48),(.25,4.48),(.51,4.62),(.83,4.45),(.67,3.48),(0,3.36),(-.67,3.48)]
  self.plaque('UpperTorso',outline,-.59,.17,cloth)
  self.tube('UpperTorso',[(x,y,-.70)for x,y in outline+[outline[0]]],.035,metal)
  for side in (-1,1):
   self.curve('UpperTorso',(side*.36,4.02,-.71),.25,metal,side)
   self.curve('UpperTorso',(side*.35,4.39,-.72),.10,metal,side)
   arm=('Left'if side<0 else 'Right')+'UpperArm'
   self.loft(arm,[(4.18,.94,1.10,side*1.36,.04),(4.30,1.03,1.16,side*1.36,.04),(4.59,.97,1.14,side*1.31,.03),(4.70,.73,.86,side*1.26,.02)],cloth,power=.7)
   self.tube(arm,[(side*1.36+math.cos(a)*.48,4.28,.04+math.sin(a)*.57)for a in [i*math.tau/24 for i in range(25)]],.035,metal)
   self.curve(arm,(side*1.37,4.48,-.55),.13,metal,side)
   fore=('Left'if side<0 else 'Right')+'LowerArm';leg=('Left'if side<0 else 'Right')+'LowerLeg'
   self.rounded(fore,(side*1.35,2.96,-.35),(.62,.62,.16),'Steel',.06)
   self.curve(fore,(side*1.35,3.0,-.445),.16,metal,side)
   self.rounded(leg,(side*.5,.97,-.38),(.59,.77,.14),'Steel',.08)
   self.tube(leg,[(side*.5-.24,.67,-.47),(side*.5,.60,-.49),(side*.5+.24,.67,-.47)],.025,metal)
  self.plaque('UpperTorso',[(-.15,4.30),(0,4.43),(.15,4.30),(0,4.03)],-.76,.035,metal)
 def helmet(self,cloth,metal):
  self.loft('Head',[(5.49,1.46,1.15,0,.02),(5.72,1.47,1.17,0,.03),(5.92,1.22,1.02,0,.06),(6.00,.80,.68,0,.06),(6.04,.12,.12,0,.06)],cloth,n=24,power=1)
  self.tube('Head',[(-.67,5.53,-.39),(-.42,5.59,-.58),(0,5.62,-.61),(.42,5.59,-.58),(.67,5.53,-.39)],.04,metal)
  for s in (-1,1):
   self.plaque('Head',[(s*.58,5.58),(s*.76,5.42),(s*.68,4.95),(s*.48,5.09)],-.05,.50,cloth)
   self.curve('Head',(s*.43,5.78,-.43),.13,metal,s)
  self.tube('Head',[(0,5.57,-.61),(0,5.86,-.47),(0,6.05,-.07)],.035,metal)
  self.tube('Head',[(0,6.03,.08),(0,6.28,.17),(0,6.31,.38)],[(.10,.07),(.07,.09),(.02,.05)],cloth,n=8)

def humanoid(key,label,role,city='Valoria',variant=0,enemy=None):
 m=Model(key,label);cloth,metal=PALETTES[city];skin='Skin';hair='HairBrown'
 armor=role in ('Guard','GuildMaster','Classes','Armor','Dungeon','Knight','Malgorth','Demon')
 robe=role in ('Magic','Races','Fusions','Healer','Shadow','NoctharBoss')
 if enemy in ('Demon','Malgorth'):skin='DemonSkin';cloth='Crimson';metal='BlackSteel'
 if enemy in ('Shadow','NoctharBoss','Knight','FallenRegent','VesperaBoss'):cloth='ClothPurple';metal='BlackSteel'
 if enemy in ('Shadow','NoctharBoss','VesperaBoss'):skin='BlackSteel'
 if enemy=='Skeleton':skin='Bone';cloth='BlackSteel'
 if role=='Healer':cloth='White';metal='Gold'
 if role=='GuildMaster':hair='HairSilver'
 if role in ('Inn','Farmer'):hair='HairBlond'
 # Tapered, bevelled avatar body; distinct from boxes or stacked cylinders.
 m.loft('UpperTorso',[(3.32,1.46,.76,0,0),(3.45,1.66,.88,0,0),(4.32,2.0,1.0,0,0),(4.63,1.90,.91,0,0),(4.69,1.55,.78,0,0)],'Mail'if armor else cloth)
 m.rounded('LowerTorso',(0,3.0,0),(1.64,.86,.83),cloth,.12)
 m.loft('Head',[(4.72,1.10,.87,0,0),(4.80,1.33,1.04,0,0),(5.65,1.33,1.04,0,0),(5.76,1.12,.86,0,0)],skin,n=32,power=.65)
 for side in (-1,1):
  name='Left'if side<0 else 'Right';x=side*1.35
  m.loft(name+'UpperArm',[(3.46,.61,.63,x,0),(3.53,.75,.73,x,0),(4.43,.82,.83,x,0),(4.55,.63,.66,x,0)],'Mail'if armor else cloth)
  m.loft(name+'LowerArm',[(2.52,.57,.59,x,0),(2.62,.65,.67,x,0),(3.38,.69,.69,x,0),(3.45,.60,.61,x,0)],'Mail'if armor else skin if role in ('Blacksmith','Artisan','Farmer') else cloth)
  glove='Leather'if armor or role in ('Blacksmith','Artisan') else skin
  m.rounded(name+'Hand',(x,2.30,-.01),(.53,.43,.56),glove,.13)
  for finger in range(4):m.tube(name+'Hand',[(x-.19+finger*.125,2.20,-.08),(x-.19+finger*.125,2.10,-.10)],.069,glove,n=8)
  m.sphere(name+'Hand',(x-side*.28,2.31,-.10),(.18,.30,.23),glove,rings=5,n=10)
  for bone,y,h,w,d in [('UpperLeg',1.95,1.18,.79,.78),('LowerLeg',.9,1.03,.70,.68)]:
   m.loft(name+bone,[(y-h/2,w*.84,d*.84,side*.5,0),(y-h/2+.07,w,d,side*.5,0),(y+h/2-.07,w,d,side*.5,0),(y+h/2,w*.88,d*.9,side*.5,0)],cloth if robe else 'BlackSteel')
  m.rounded(name+'Foot',(side*.5,.24,-.19),(.79,.48,1.26),'Leather',.12)
  m.rounded(name+'LowerLeg',(side*.5,.76,.015),(.73,.77,.73),'Leather',.06)
  m.tube(name+'LowerLeg',[(side*.5+math.cos(a)*.375,1.02,math.sin(a)*.375)for a in [i*math.tau/20 for i in range(21)]],.026,metal)
 m.rounded('LowerTorso',(0,3.08,0),(1.74,.20,.92),'Leather',.04)
 m.rounded('LowerTorso',(0,3.08,-.51),(.30,.25,.08),metal,.025)
 m.rounded('LowerTorso',(.67,2.79,-.40),(.43,.52,.28),'LeatherLight',.09)
 m.tube('UpperTorso',[(-.65,4.49,-.48),(-.18,3.91,-.56),(.54,3.39,-.46)],.048,'Leather')
 m.face('DemonFace'if enemy in ('Demon','Malgorth') else 'SkullFace'if enemy=='Skeleton' else 'WraithFace'if enemy in ('Shadow','NoctharBoss','VesperaBoss') else 'Face')
 if enemy!='Skeleton':m.hair('Long'if robe else 'Braided'if role in ('Inn','Reception') else 'Short',hair)
 if armor:m.armor(cloth,metal)
 else:
  m.collar(cloth,metal)
  for i in range(4):m.sphere('UpperTorso',(.13,4.20-i*.19,-.52),(.07,.07,.04),metal,rings=3,n=8)
 if role in ('Guard','Knight'):m.helmet(cloth,metal);m.shield(cloth,metal);m.sword('RightHand'if enemy else 'LowerTorso',bool(enemy))
 if role in ('GuildMaster','Classes','Dungeon','Demon','Malgorth'):m.cape(cloth);m.sword('RightHand'if enemy else 'LowerTorso',bool(enemy),metal)
 if role in ('Blacksmith','Artisan','Inn','Farmer','Armor','Employee'):
  apron='Linen'if role=='Inn' else 'Leather'
  m.plaque('UpperTorso',[(-.56,4.36),(.56,4.36),(.70,3.40),(-.70,3.40)],-.60,.065,apron)
  m.plaque('LowerTorso',[(-.64,3.00),(.64,3.00),(.69,2.27),(-.69,2.27)],-.51,.07,apron)
  m.rounded('LowerTorso',(-.22,2.66,-.57),(.49,.27,.06),cloth,.025)
 if role in ('Blacksmith','Artisan'):
  m.tube('RightHand',[(1.35,1.83,-.1),(1.35,2.63,-.1)],.07,'Wood')
  m.rounded('RightHand',(1.35,2.58,-.10),(.57,.29,.27),'Steel',.045)
 if role=='Inn':
  m.loft('RightHand',[(2.12,.34,.34,1.35,-.30),(2.58,.40,.40,1.35,-.30)],'Wood',n=16,power=1)
  m.tube('RightHand',[(1.35+math.cos(a)*.205,2.58,-.30+math.sin(a)*.205)for a in [i*math.tau/20 for i in range(21)]],.028,'Silver')
 if robe:
  m.cape(cloth)
  for side in (-1,1):
   bone=('Left'if side<0 else 'Right')+'UpperLeg'
   m.plaque(bone,[(side*.5-.46,2.59),(side*.5+.46,2.59),(side*.5+.48,1.38),(side*.5-.48,1.38)],-.47,.06,cloth)
   m.tube(bone,[(side*.5-.44,1.4,-.52),(side*.5+.44,1.4,-.52)],.025,metal)
 if role in ('Magic','Fusions','Races','NoctharBoss','Shadow'):
  m.tube('RightHand',[(1.4,.2,-.14),(1.4,4.26,-.14)],.065,'Wood')
  m.tube('RightHand',[(1.2,4.1,-.14),(1.08,4.48,-.14),(1.4,4.74,-.14),(1.72,4.48,-.14),(1.6,4.1,-.14)],.045,metal)
  m.sphere('RightHand',(1.4,4.42,-.14),(.37,.43,.37),'Rune',rings=4,n=6)
 if enemy in ('Shadow','NoctharBoss','VesperaBoss'):
  for s in (-1,1):m.loft('Head',[(4.74,.30,.83,s*.64,.12),(5.55,.33,1.14,s*.61,.04),(5.85,.24,.96,s*.48,.10)],cloth)
  m.sphere('Head',(0,5.75,.11),(1.56,.48,1.20),cloth,n=24)
 if enemy=='FallenRegent':
  for i in range(8):
   a=i*math.tau/8;x,z=math.cos(a)*.61,math.sin(a)*.52
   m.tube('Head',[(x,5.73,z),(x,6.11,z)],[.10,.012],'Gold',n=6)
 if role in ('Magic','Races','Fusions','GuildMaster','Reception','Bank'):m.book()
 if role=='Farmer':
  m.loft('Head',[(5.70,1.95,1.65,0,.04),(5.79,1.95,1.65,0,.04)],'Rope',n=24,power=1)
  m.loft('Head',[(5.77,1.12,1.02,0,.05),(6.10,.80,.76,0,.05)],'Rope',n=24,power=.7)
 if role in ('Guide','Tutorial','Adventurer','Traveler','Resident','TravelShop','Skills'):
  m.cape(cloth)
 if role in ('TravelShop','Traveler','Adventurer'):
  m.rounded('UpperTorso',(0,3.85,.88),(1.14,1.33,.57),'Leather',.16)
  m.tube('UpperTorso',[(-.71,4.66,.86),(.71,4.66,.86)],.18,'Linen',n=12)
 if enemy in ('Demon','Malgorth'):
  for s in (-1,1):
   m.tube('Head',[(s*.51,5.65,.18),(s*.80,6.02,.22),(s*.80,6.42,.1),(s*.61,6.58,-.04)],[.19,.15,.08,.006],'Bone',n=10)
   m.curve('UpperTorso',(s*.33,4.04,-.73),.26,'Gold',s)
  m.tube('LowerTorso',[(0,2.95,.43),(.35,2.0,.80),(.71,1.8,1.0),(.94,2.15,1.05)],[.11,.08,.05,.008],'DemonSkin')
 if enemy=='Malgorth':
  for s in (-1,1):
   p=[(s*.6,4.45,.60),(s*2.6,5.35,.66),(s*2.20,4.25,.88),(s*2.65,3.1,1.00),(s*1.18,3.70,.73)]
   m.mesh('UpperTorso',p,[[0,1,2],[0,2,4],[4,2,3]],'ClothRed')
   m.tube('UpperTorso',p+[p[0]],.065,'BlackSteel')
 if enemy=='Skeleton':
  # Bone geometry replaces cloth silhouette, without a grey box torso.
  for bone in list(m.parts):
   if bone not in ('Head',):m.parts.pop(bone)
  for bone,c in R15.items():
   if bone=='Head':continue
   length=1.1 if 'Upper' in bone else .85 if 'Lower' in bone else .42
   if 'Torso'in bone:
    m.tube(bone,[(0,c[1]-.47,0),(0,c[1]+.48,0)],.10,'Bone')
    if bone=='UpperTorso':
     for y in (3.65,3.85,4.05,4.25):
      for s in (-1,1):m.tube(bone,[(0,y,.02),(s*.65,y+.09,-.04),(s*.61,y-.02,-.37),(s*.16,y-.12,-.45)],.062,'Bone')
   else:m.tube(bone,[add(c,(0,-length/2,0)),add(c,(0,length/2,0))],.115 if 'Leg'in bone else .085,'Bone')
 return m

def creature(key,label,species):
 m=Model(key,label,'Blob'if species=='Slime'else'Quadruped');fur='DarkFur'if species=='DarkWolf'else'Wood'if species=='Deer'else'Fur'
 if species=='Slime':
  m.sphere('Blob',(0,.95,0),(2.4,1.9,2.18),'Slime',rings=12,n=32)
  for x in (-.40,.40):m.sphere('Blob',(x,1.12,-.98),(.13,.23,.05),'Black',rings=5,n=10)
  m.tube('Blob',[(-.18,.82,-1.01),(0,.77,-1.04),(.18,.82,-1.01)],.025,'Black')
  return m
 m.sphere('BeastBody',(0,1.47,.12),(1.25,1.30,2.12),fur,n=20,rings=10)
 m.sphere('BeastBody',(0,1.59,-.58),(1.08,1.34,1.04),fur,n=20)
 m.sphere('BeastHead',(0,1.95,-1.17),(.84,.91,.91),fur,n=20)
 m.sphere('BeastHead',(0,1.68,-1.71),(.56,.43,.85),fur,n=16)
 m.sphere('BeastHead',(0,1.76,-2.03),(.31,.21,.18),'Black',n=12)
 for s in (-1,1):
  m.tube('BeastHead',[(s*.27,2.20,-1.03),(s*.45,2.67,-.96)],[.18,.008],fur,n=8)
  m.sphere('BeastHead',(s*.35,2.02,-1.44),(.09,.13,.10),'DemonEye'if species=='DarkWolf'else'Black',n=10,rings=5)
  for front,z in ((True,-.73),(False,.87)):
   bone=('Front'if front else'Hind')+('Left'if s<0 else'Right');x=s*.46
   m.tube(bone,[(x,1.44,z),(x,.73,z+.13),(x,.29,z-.02)],[.20,.13,.095],fur,n=10)
   m.sphere(bone,(x,.20,z-.15),(.39,.33,.57),'Black'if species=='Deer'else fur,n=12,rings=5)
   if species!='Deer':
    for finger in (-1,0,1):m.tube(bone,[(x+finger*.09,.18,z-.29),(x+finger*.09,.16,z-.43)],[.028,.004],'Bone',n=6)
 if species=='Deer':
  for s in (-1,1):
   trunk=[(s*.25,2.26,-1.03),(s*.52,2.91,-.91),(s*.74,3.40,-.81),(s*1.02,3.64,-.75)]
   m.tube('BeastHead',trunk,[.11,.08,.06,.01],'Bone')
   for i in (1,2):m.tube('BeastHead',[trunk[i],add(trunk[i],(-s*.1,.38,-.04)),add(trunk[i],(-s*.03,.55,-.10))],[.065,.04,.006],'Bone')
  m.sphere('BeastBody',(0,1.82,-.08),(1.35,.26,1.35),'ClothGreen')
  m.tube('BeastTail',[(0,1.6,1.06),(0,1.84,1.44)],[.11,.04],fur)
 else:m.tube('BeastTail',[(0,1.5,1.04),(.14,1.48,1.67),(.28,1.16,2.03)],[(.21,.23),(.22,.24),(.015,.03)],fur,n=12)
 return m
