-- Engine-free architectural grammar shared by geometry and structural tests.
local P={}
P.Themes={
 Valoria={Id='Crown',Stone={158,146,124},Plaster={231,217,181},Wood={94,60,40},Roof={146,65,43},Metal={161,137,83},Glass={250,209,128},Height=0},
 Eldoria={Id='Woodland',Stone={126,143,121},Plaster={204,214,172},Wood={77,74,45},Roof={64,111,85},Metal={162,143,82},Glass={220,235,155},Height=2},
 Durakh={Id='Mountain',Stone={116,126,133},Plaster={153,154,140},Wood={81,59,43},Roof={109,79,57},Metal={153,110,69},Glass={255,186,105},Height=2},
 Asterion={Id='Arcane',Stone={175,183,196},Plaster={218,222,228},Wood={78,68,101},Roof={79,87,148},Metal={161,156,193},Glass={143,214,247},Height=4},
 Arkheim={Id='Gothic',Stone={95,105,119},Plaster={142,148,157},Wood={63,56,66},Roof={63,54,80},Metal={109,110,125},Glass={193,160,219},Height=6},
}
local important={GuildHall=true,Tavern=true,Temple=true,Castle=true,MagicSchool=true,Library=true,Forge=true,SmithGuild=true,Blacksmith=true,TrainingHall=true,ArcaneTower=true}
local tower={GuardTower=true,WatchTower=true,ArcaneTower=true}
function P.build(kind,city,index,lot)
 lot=lot or {};index=index or 1
 local theme=P.Themes[city] or P.Themes.Valoria
 local variant=lot.Variant or lot.Variation or index%4
 assert(type(variant)=='number' and variant>=0 and variant%1==0,'Variante arquitetônica inválida')
 variant%=4
 local w,d,h=26+(index%3)*2,28+(index%2)*2,16+(index%3)*2+theme.Height
 if kind=='SmallHouse' then w,d,h=24+variant,27+variant%2,15+variant%2+theme.Height end
 if kind=='LargeHouse' or kind=='GuildHall' or kind=='Tavern' then h+=5 end
 if kind=='Castle' then w,d,h=44,40,34+theme.Height end
 if kind=='ArcaneTower' then w,d,h=24,24,48+theme.Height end
 if kind=='Forge' then w,d,h=38,34,23+theme.Height end
 if kind=='GuardTower' or kind=='WatchTower' then w,d,h=25,26,30+theme.Height end
 local interior=if lot.Interior==nil then important[kind]==true else lot.Interior==true
 local rise=if tower[kind] then 13 elseif theme.Id=='Gothic' or theme.Id=='Arcane' then 11 else 7+variant%2*2
 return {Kind=kind,Theme=theme,Variant=variant,Width=w,Depth=d,Height=h,Rise=rise,
  DoorWidth=8,DoorHeight=10,Interior=interior,Tower=tower[kind]==true,
  District=lot.District or 'Civic',Roof=if tower[kind] then 'Spire' elseif variant==1 then 'CrossGable' elseif variant==3 then 'Dormer' else 'Gable',
  Windows=if theme.Id=='Gothic' then 'Lancet' elseif theme.Id=='Arcane' then 'Crystal' else 'Mullion'}
end
return P
