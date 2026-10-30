-- Native geometry construction in the limited host; not a Studio/FPS test.
do
    local scenery=require(game.ServerStorage.MedievalWorldgen.ScenicGenerator)
    local geometry=require(game.ServerStorage.MedievalWorldgen.Geometry)
    local folder=Instance.new('Folder');folder.Name='MonumentalForestRegression';folder.Parent=workspace
    -- A sloped beam's long axis must meet both requested endpoints. This catches
    -- yaw-only mock lookAt baking roots and branches horizontally in midair.
    local a,b=Vector3.new(-12,4,18),Vector3.new(21,42,-9)
    local beam=geometry.beam(folder,a,b,2,Color3.fromRGB(90,80,60),Enum.Material.Wood)
    local front=beam.CFrame:PointToWorldSpace(Vector3.new(0,0,-beam.Size.Z/2))
    local back=beam.CFrame:PointToWorldSpace(Vector3.new(0,0,beam.Size.Z/2))
    assert((front-b).Magnitude<0.00001 and (back-a).Magnitude<0.00001,'Sloped beam endpoints changed during authoring')
    beam:Destroy()
    local checked=0
    for _,forest in {'Sylvarin','Nocthar','Vespera'} do
        for variant=0,4 do
            for _,scale in {1,1.4,2.1} do
                local tree=scenery.monumentalTree(folder,{X=200,H=40,Z=-100,Scale=scale,Variant=variant,Forest=forest})
                local count,canopies=0,0
                assert(tree:GetAttribute('MonumentalTree') and tree:GetAttribute('ForestId')==forest)
                for _,part in tree:GetDescendants() do
                    assert(not part:IsA('Script') and not part:IsA('LocalScript') and not part:IsA('ModuleScript'))
                    assert(not part:IsA('PointLight') and not part:IsA('ParticleEmitter'))
                    if part:IsA('BasePart') then
                        count+=1
                        assert(part.Anchored and part.Size.X>0 and part.Size.Y>0 and part.Size.Z>0)
                        if part.Name=='Canopy' then
                            canopies+=1
                            assert(part.CanCollide==false and part.CanQuery==false and part.CastShadow==false)
                            assert(part:GetAttribute('DetailTier')==nil,'Core canopy must survive LOW quality')
                            assert(part.Position.Y-part.Size.Y/2>40+24*scale,'Canopy blocks the walking layer')
                            assert(part.Position.Y+part.Size.Y/2<=40+tree:GetAttribute('TreeHeight'))
                        end
                    end
                end
                assert(count>=12 and count<=18,'Tree native part budget exceeded')
                assert(canopies==6,'Forest silhouette lost its crown layers')
                checked+=1;tree:Destroy()
            end
        end
    end
    print('PASSOU MOCK: '..checked..' árvores monumentais preservam copas essenciais, passagem sob galhos e orçamento de 12–18 Parts; feixes inclinados alcançam os dois extremos.')
    for _,forest in {'Sylvarin','Nocthar','Vespera'} do
        local region=Instance.new('Folder');region.Name=forest;region.Parent=folder
        scenery.forest(region,{X=200,H=40,Z=-100,Id=forest},{MonumentalMap=true,ScenicReservations={}},
            {height=function()return 40 end},{})
        local heart=region:FindFirstChild('HeartGrove')
        assert(heart and heart:GetAttribute('MonumentalSanctuary') and heart:GetAttribute('OpenClearingRadius')==28)
        assert(type(heart:GetAttribute('DisplayName'))=='string')
        assert(region:FindFirstChild('HiddenCave'),'Cave and approach must survive scenery replacement')
        for _,node in region:GetDescendants() do
            assert(not node:IsA('ProximityPrompt') and not node:IsA('Humanoid'),'Forest scenery activated gameplay')
        end
    end
    folder:Destroy()
    print('PASSOU MOCK: três santuários florestais distintos preservam clareira, caverna e integração sem criar gameplay.')
end
