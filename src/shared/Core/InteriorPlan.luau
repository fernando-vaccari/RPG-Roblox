local Plan={}
function Plan.build(kind,width,depth,height)
 local out={}
 local function item(name,size,pos,material,collide)
  table.insert(out,{Name=name,Size=size,Position=pos,Material=material,Collide=collide~=false})
 end
 item('Rug',{6,0.12,8},{0,1.6,3},'Fabric',false)
 item('Table',{6,0.6,5},{-width*0.28,4,depth*0.2},'WoodPlanks')
 for _,x in {-2,2}do item('TableLeg',{0.5,2.5,0.5},{-width*0.28+x,2.6,depth*0.2},'Wood')end
 item('Bench',{5,1,2},{-width*0.28,2.4,depth*0.2-4},'WoodPlanks')
 if kind=='Tavern' or string.find(kind,'House') then
  item('BedFrame',{6,1.2,8},{width*0.28,2.2,depth*0.2},'Wood')
  item('Blanket',{5.5,0.5,7},{width*0.28,3.1,depth*0.2},'Fabric',false)
 elseif kind=='Castle' or kind=='Temple' then
  item('Dais',{10,1,6},{0,2,depth*0.33},'Cobblestone')
  item('Throne',{4,6,1},{0,5,depth*0.36},'Wood')
 else item('SupplyShelf',{6,6,2},{width*0.28,4,depth*0.3},'WoodPlanks')end
 for _,z in {-depth*0.25,depth*0.25}do item('CeilingBeam',{width,0.8,0.8},{0,height-1,z},'Wood',false)end
 item('LanternFrame',{1.2,1.8,1.2},{-width/2+2,7,-depth*0.15},'Metal',false)
 item('LanternGlow',{0.8,1.2,0.8},{-width/2+2,7,-depth*0.15},'Neon',false)
 return out
end
return Plan
