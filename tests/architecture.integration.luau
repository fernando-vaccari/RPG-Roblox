-- Appended by the integration bundler. Real generators under a simulated host.
do
 local Buildings=require(game.ServerStorage.MedievalWorldgen.BuildingGenerator)
 local Civic=require(game.ServerStorage.MedievalWorldgen.CityLandmarkGenerator)
 local Plan=require(game.ServerStorage.MedievalWorldgen.ArchitecturalPlan)
 local Catalog=require(game.ReplicatedStorage.MedievalRPG.Config.ContentConfig)
 local folder=Instance.new('Folder');folder.Name='ArchitectureRegression';folder.Parent=workspace
 local total=0
 for city,kinds in Catalog.CityBuildings do for index,kind in kinds do
  local lot={Id=city..'_'..index,Kind=kind,X=0,H=40,Z=0,Yaw=index*0.31}
  local spec=Plan.build(kind,city,index,lot)
  local model,pos,role=Buildings.build(folder,lot,city,index)
  assert(model:GetAttribute('ArchitecturalTheme')==Plan.Themes[city].Id)
  assert(model:GetAttribute('Template')==kind and typeof(pos)=='Vector3' and type(role)=='string')
  assert((model:FindFirstChild('Interior')~=nil)==spec.Interior)
  local frame=CFrame.new(lot.X,lot.H,lot.Z)*CFrame.Angles(0,lot.Yaw,0)
  for _,part in model:GetDescendants()do
   assert(not part:IsA('ProximityPrompt') and not part:IsA('Humanoid') and not part:IsA('Script'))
   if part:IsA('BasePart')then
    assert(part.Anchored and part.Size.X>0 and part.Size.Y>0 and part.Size.Z>0)
    local p=frame:PointToObjectSpace(part.Position)
    if part.CanCollide~=false and math.abs(p.Z+spec.Depth/2)<0.8 and p.Y-part.Size.Y/2<8 and p.Y+part.Size.Y/2>2 then
     assert(math.abs(p.X)-part.Size.X/2>=3.5,lot.Id..' doorway blocked by '..part.Name)
    end
   end
  end
  total+=1;model:Destroy()
 end end
 folder:Destroy()
 print('PASSOU MOCK: '..total..' edifícios de cinco temas preservam portas, módulos, interiores seletivos e não criam gameplay.')
 folder=Instance.new('Folder');folder.Name='CivicRegression';folder.Parent=workspace
 local seen={}
 for city in Plan.Themes do
  local model=Civic.build(folder,{Id=city,X=0,Z=0,H=40},{})
  local name=model:GetAttribute('LandmarkName');assert(type(name)=='string' and not seen[name]);seen[name]=true
  assert(model:GetAttribute('LandmarkId')==city..'_Civic')
  for _,part in model:GetDescendants()do
   assert(not part:IsA('ProximityPrompt') and not part:IsA('Humanoid') and not part:IsA('Script'))
   if part:IsA('BasePart')then
    assert(part.Anchored and part.Size.X>0 and part.Size.Y>0 and part.Size.Z>0)
    assert(math.abs(part.Position.X)<65 and math.abs(part.Position.Z)<55,'Civic center exceeds reserved footprint')
   end
  end
 end
 folder:Destroy()
 print('PASSOU MOCK: cinco marcos cívicos únicos ficam na reserva central e não possuem prompts ou lógica de gameplay.')
end
