#!/usr/bin/env python3
"""Label technical previews of the actual original mesh library, outside Studio."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parents[1]
folder=ROOT/'docs/avatar-style/previews';folder.mkdir(exist_ok=True)
font=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',23)
small=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',17)
def sheet(rows,columns,name):
 w,h=510,680;image=Image.new('RGB',(w*columns,100+h*((len(rows)+columns-1)//columns)),(24,29,39));d=ImageDraw.Draw(image)
 d.text((18,16),'ELDRAVYN • AVATARES E CRIATURAS',font=font,fill=(235,211,164))
 d.text((18,54),'Malhas/UV/texturas reais • render Blender • importação no Studio pendente',font=small,fill=(210,216,225))
 for i,(key,label)in enumerate(rows):
  x=(i%columns)*w;y=100+(i//columns)*h
  original=Image.open(ROOT/'build/avatar-renders'/(key+'.png')).convert('RGB').resize((w,638))
  image.paste(original,(x,y));d.text((x+12,y+647),label,font=small,fill=(237,228,205))
 image.save(folder/name)
sheet([('NPC_Arkheim_Ambient_Guard','Guarda de Arkheim'),('NPC_Valoria_GuildMaster','Mestre da guilda'),('NPC_Valoria_Blacksmith','Ferreiro'),('NPC_Valoria_Magic','Mestre de magia'),('NPC_Eldoria_General','Comerciante de Eldoria'),('NPC_Durakh_Inn','Estalajadeira de Durakh')],3,'npcs.png')
sheet([('ENEMY_Demon','Soldado demoníaco'),('ENEMY_Knight','Cavaleiro corrompido'),('ENEMY_Skeleton','Esqueleto corrompido'),('ENEMY_Wolf','Lobo'),('ENEMY_Malgorth','Lorde Malgorth'),('ENEMY_SylvarinBoss','Cervo ancestral de Sylvarin'),('ENEMY_Slime','Slime'),('ENEMY_NoctharBoss','Sentinela de Nocthar')],4,'inimigos.png')
Image.open(ROOT/'build/avatar-renders/NPC_Arkheim_Ambient_Guard.png').save(folder/'guarda.png')
print('Prévias compostas a partir dos renders da geometria real.')
