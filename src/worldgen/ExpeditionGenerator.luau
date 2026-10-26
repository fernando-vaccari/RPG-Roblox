local Shared=game.ReplicatedStorage.MedievalRPG
local Config=require(Shared.Config.DungeonConfig)
local Rules=require(Shared.Core.DungeonRules)
local G=require(script.Parent.Geometry)
local Content=require(script.Parent.ContentGenerator)
local Generator={}
function Generator.preflight(origin)
 for _,id in Config.Order do
  local d=Config.Dungeons[id]
  local low=origin+Vector3.new(d.X-85,-6,d.Z-85)
  local high=origin+Vector3.new(d.X+85,(d.Floors-1)*96+45,d.Z+85)
  local params=OverlapParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={workspace.Terrain}
  assert(#workspace:GetPartBoundsInBox(CFrame.new((low+high)/2),high-low,params)==0,'Área da expedição ocupada; preserve o mapa e use outro Place')
  -- Small per-floor reads avoid an enormous empty vertical voxel allocation.
  for n=1,d.Floors do
   local p=origin+Vector3.new(d.X,(n-1)*96,d.Z)
   local _,fill=workspace.Terrain:ReadVoxels(Region3.new(p-Vector3.new(85,6,85),p+Vector3.new(85,45,85)):ExpandToGrid(4),4)
   for _,plane in fill do for _,row in plane do for _,v in row do assert(v==0,'Terrain existente na área da expedição') end end end
  end
 end
end
function Generator.build(map,origin)
 local expeditions=G.model(map,'Expeditions')
 for _,id in Config.Order do
  local d=Config.Dungeons[id];local tower=G.model(expeditions,id)
  tower:SetAttribute('DungeonId',id);tower:SetAttribute('FloorCount',d.Floors)
  local tint=Color3.fromRGB(table.unpack(d.Tint))
  for n=1,d.Floors do
   local plan=Rules.floor(Config,id,n);local pos=origin+Vector3.new(plan.X,plan.Y,plan.Z)
   local floor=G.model(tower,'Floor'..n)
   floor:SetAttribute('DungeonId',id);floor:SetAttribute('FloorIndex',n);floor:SetAttribute('Layout',plan.Layout)
   floor:SetAttribute('FloorName',plan.Name);floor:SetAttribute('SpawnPosition',pos+Vector3.new(0,6,-56))
   floor:SetAttribute('Center',pos);floor:SetAttribute('Active',false)
   for _,name in {'EnemySpawns','TreasureChests'} do local f=Instance.new('Folder');f.Name=name;f.Parent=floor end
   local function part(name,size,x,y,z,color,material)
    return G.part(floor,name,size,CFrame.new(pos+Vector3.new(x,y,z)),color or G.Palette.Stone,material or Enum.Material.Slate)
   end
   if plan.Layout=='Bridge' then
    for _,z in {-53,53} do part('Landing',Vector3.new(140,3,40),0,0,z) end
    part('Crossing',Vector3.new(22,3,70),0,0,0)
    for _,x in {-12,12} do part('BridgeRail',Vector3.new(2,4,70),x,3,0) end
   else part('Floor',Vector3.new(140,3,150),0,0,0) end
   for _,x in {-71,71} do part('Wall',Vector3.new(3,34,150),x,17,0) end
   for _,z in {-76,76} do part('Wall',Vector3.new(140,34,3),0,17,z) end
   part('Vault',Vector3.new(144,2,154),0,36,0,Color3.fromRGB(43,42,57))
   for _,x in {-58,58} do
    for _,z in {-48,0,48} do
     part('ColumnBase',Vector3.new(8,3,8),x,3,z)
     part('Column',Vector3.new(4,30,4),x,18,z)
     local banner=G.detail(floor,'Banner',Vector3.new(6,12,0.3),CFrame.new(pos+Vector3.new(x,24,z-3)),tint,Enum.Material.Fabric);banner:SetAttribute('Flutter',true)
    end
    G.torch(floor,CFrame.new(pos+Vector3.new(x,8,0)),true)
   end
   -- Six different traversal silhouettes; a central corridor remains at least 16 studs wide.
   for _,side in {-1,1} do
    if plan.Layout=='Crypt' then
     for row=-1,1 do part('Sarcophagus',Vector3.new(14,4,9),side*39,3,row*24);part('CarvedLid',Vector3.new(15,1,10),side*39,5.5,row*24,tint) end
    elseif plan.Layout=='Library' then
     for row=-1,1 do
      part('Bookshelf',Vector3.new(24,18,3),side*39,10,row*25,G.Palette.Wood,Enum.Material.WoodPlanks)
      for y=5,17,4 do part('Books',Vector3.new(22,2,2),side*39,y,row*25-2,tint,Enum.Material.Fabric) end
     end
    elseif plan.Layout=='Garden' then
     part('Planter',Vector3.new(24,3,50),side*40,2,0)
     for row=-1,1 do Content.tree(floor,{X=pos.X+side*40,H=pos.Y+3,Z=pos.Z+row*18,Scale=0.65,Variant=(n+row)%3,Forest='Vespera'}) end
    elseif plan.Layout=='Forge' then
     part('Furnace',Vector3.new(20,14,22),side*42,8,10,G.Palette.Stone,Enum.Material.Brick)
     G.detail(floor,'Embers',Vector3.new(15,5,0.5),CFrame.new(pos+Vector3.new(side*42,6,-1.5)),Color3.fromRGB(249,124,61),Enum.Material.Neon)
     for row=-1,1 do part('Anvil',Vector3.new(8,3,5),side*32,4,row*28,Color3.fromRGB(71,75,82),Enum.Material.Metal) end
    elseif plan.Layout=='Arena' then
     part('ThroneDais',Vector3.new(18,2,18),side*46,2,38)
     G.crystal(floor,CFrame.new(pos+Vector3.new(side*46,8,38)),tint,1.5)
    end
   end
   for i,kind in plan.Enemies do
    local x=if plan.Layout=='Bridge' or plan.Boss then 0 else (if i%2==0 then -18 else 18)
    local z=if plan.Layout=='Bridge' then 40+(i-1)*7 else -8+(i-1)*14
    local marker=Content.enemyMarker(floor.EnemySpawns,id..'_'..n..'_'..i,pos+Vector3.new(x,2,z),kind)
    marker:SetAttribute('Enabled',false);marker:SetAttribute('Once',true);marker:SetAttribute('Difficulty',plan.Scale)
   end
   local nextPortal=part('NextFloor',Vector3.new(9,12,2),0,7,64,tint,Enum.Material.Neon)
   nextPortal.CanCollide=false;nextPortal:SetAttribute('ExpeditionNext',true);G.prompt(nextPortal,'Avançar',n..'/'..d.Floors..' • elimine os guardiões')
   local leave=part('RetreatPortal',Vector3.new(6,9,2),-29,6,-62,Color3.fromRGB(101,158,180),Enum.Material.Neon)
   leave.CanCollide=false;leave:SetAttribute('ReturnPortal',true);G.prompt(leave,'Retornar','Abandonar expedição')
   local chest=Content.chest(floor.TreasureChests,id..'_Floor_'..n,pos+Vector3.new(28,2,60),if plan.Boss then 'Epic' else 'Uncommon')
   chest:SetAttribute('FloorLocked',true)
   G.sign(floor,string.format('%02d • %s',n,plan.Name),CFrame.new(pos+Vector3.new(0,27,73)),45)
   task.wait()
  end
 end
 return expeditions
end
return Generator
