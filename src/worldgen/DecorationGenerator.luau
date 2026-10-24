local G=require(script.Parent.Geometry)
local D={}
function D.generate(parent,c,plan,terrain)
    local budget=c.QualityProfiles[c.Quality].DecorationBudget
    local count=0
    for _,road in plan.Roads do
        for i,s in road.Segments do
            if i%7~=0 or s.Bridge then continue end
            local a,b=Vector3.new(s.A.X,0,s.A.Z),Vector3.new(s.B.X,0,s.B.Z)
            local mid=(a+b)/2;local side=Vector3.new(-(b-a).Z,0,(b-a).X).Unit
            for _,sign in {-1,1} do
                if count>=budget then return count end
                local pos=mid+side*sign*28
                local free=true
                for _,city in plan.Cities do
                    for _,lot in city.Lots do
                        if (Vector2.new(lot.X,lot.Z)-Vector2.new(pos.X,pos.Z)).Magnitude<lot.Radius+8 then free=false end
                    end
                end
                if free and terrain.riverDistance(c,pos.X,pos.Z)>65 then
                    local ground=terrain.height(c,pos.X,pos.Z)
                    G.detail(parent,'RoadsideRock',Vector3.new(4,2,3),CFrame.new(pos.X,ground+0.6,pos.Z),Color3.fromRGB(116,124,111),Enum.Material.Rock,Enum.PartType.Ball)
                    count+=1
                end
            end
        end
    end
    return count
end
return D
