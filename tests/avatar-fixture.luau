-- Reuse the already-created Stage 2 fixture. No real assets, uploads or engine.
local avatar=game.ServerStorage.AvatarPackage
if START_WITH_V2 then require(pkg.NPCVisualUpgrade).Apply()end
pkg.Name='CoreV2';pkg.Parent=avatar
local wrapper=avatar.CoreVisualFactory:Clone();wrapper.Name='NPCVisualFactory'
pkg.Authoring.NPCVisualFactory:Destroy();wrapper.Parent=pkg.Authoring
avatar.EnemyRuntime.EnemyFactory.Name='Factory'
local bootstrap=Instance.new('LocalScript');bootstrap.Name='Bootstrap';bootstrap.Disabled=true;bootstrap.Source=AVATAR_BOOTSTRAP_SOURCE;bootstrap.Parent=avatar.Client
local actualEnemy=game.ServerScriptService.MedievalServer.Services.EnemyService
actualEnemy.Source=avatar.EnemyServiceBaseline.Source
local Catalog=require(avatar.Shared.AvatarCatalog)
local Register=require(avatar.RegisterImported)
local Art=require(avatar.Upgrade)
local function near(a,b)assert(math.abs(a-b)<.00001,tostring(a)..' ~= '..tostring(b))end
local function importedGroup(group)
 local f=Instance.new('Model');f.Name='Imported_'..group;f.Parent=workspace
 local revision=Instance.new('Part');revision.Name='ELDRAVYN_ART_'..Catalog.ArtRevision:gsub('%W','_');revision.Parent=f
 local rotation=CFrame.new(123,71,-32)*CFrame.Angles(0,.7,0);local scale=100
 for key,v in {O={0,.5,0},X={1,.5,0},Y={0,1.5,0},Z={0,.5,1}}do
  local marker=Instance.new('MeshPart');marker.Name='ELDRAVYN_CAL_'..key;marker.CFrame=rotation*CFrame.new(Vector3.new(table.unpack(v))*scale);marker.Parent=f
 end
 for key,def in Catalog.Models do if def.Group==group then
  for i,bone in def.Bones do
   local center=Catalog.R15[bone]or Catalog.Quadruped[bone]or{0,.95,0}
   local p=Instance.new('MeshPart');p.Name=key..'__'..bone;p.Size=Vector3.new(.8,1,.6)*scale;p.Color=Color3.new(1,1,1);p.Material=Enum.Material.SmoothPlastic
   p.CFrame=rotation*CFrame.new((Vector3.new(table.unpack(def.Origin))+Vector3.new(table.unpack(center)))*scale)
   p.MeshId='rbxassetid://99000001';p.TextureID='rbxassetid://99000002';p.Parent=f
  end
 end end
 return f
end
