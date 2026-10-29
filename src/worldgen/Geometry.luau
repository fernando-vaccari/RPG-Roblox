local G={}
G.Palette={Stone=Color3.fromRGB(112,119,124),Wood=Color3.fromRGB(86,53,35),Plaster=Color3.fromRGB(221,202,160),Roof=Color3.fromRGB(133,58,47),Gold=Color3.fromRGB(224,177,74)}
function G.model(parent,name)
    local m=Instance.new('Model'); m.Name=name; m.Parent=parent
    m:SetAttribute('GeneratedBy','ProjectMedievalRPG'); return m
end
function G.part(parent,name,size,cf,color,material,shape)
    local p=Instance.new('Part'); p.Name=name; p.Size=size; p.CFrame=cf
    p.Anchored=true; p.Color=color or G.Palette.Stone; p.Material=material or Enum.Material.Slate
    p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
    if shape then p.Shape=shape end
    p.CanTouch=false; p.Parent=parent; return p
end
function G.detail(parent,name,size,cf,color,material,shape)
    local p=G.part(parent,name,size,cf,color,material,shape)
    p.CanCollide=false; p.CanQuery=false; return p
end
function G.sign(parent,text,cf,width)
    local p=G.detail(parent,'Sign',Vector3.new(width or 12,3,0.4),cf,G.Palette.Wood,Enum.Material.Wood)
    local ui=Instance.new('SurfaceGui'); ui.Face=Enum.NormalId.Front; ui.CanvasSize=Vector2.new(500,130); ui.Parent=p
    local label=Instance.new('TextLabel'); label.Size=UDim2.fromScale(1,1); label.BackgroundTransparency=1
    label.Text=text; label.TextColor3=G.Palette.Gold; label.TextScaled=true; label.Font=Enum.Font.Garamond; label.Parent=ui
    return p
end
function G.prompt(part,action,object)
    local p=Instance.new('ProximityPrompt'); p.ActionText=action; p.ObjectText=object
    p.KeyboardKeyCode=Enum.KeyCode.E; p.MaxActivationDistance=12; p.RequiresLineOfSight=true; p.HoldDuration=0.2; p.Parent=part; return p
end
function G.marker(parent,id,pos,attrs)
    local p=G.detail(parent,id,Vector3.new(2,2,2),CFrame.new(pos),G.Palette.Gold)
    p.Transparency=1
    for key,value in attrs or {} do p:SetAttribute(key,value) end
    return p
end
function G.crystal(parent,cf,color,scale)
    return G.detail(parent,'Crystal',Vector3.new(2,6,2)*(scale or 1),cf*CFrame.Angles(0,0,0.3),color,Enum.Material.Neon)
end
function G.torch(parent,cf,light)
    G.detail(parent,'TorchWood',Vector3.new(0.6,3,0.6),cf,G.Palette.Wood,Enum.Material.Wood)
    local flame=G.detail(parent,'Flame',Vector3.new(1,1.8,1),cf*CFrame.new(0,2,0),Color3.fromRGB(255,155,58),Enum.Material.Neon,Enum.PartType.Ball)
    if light then local l=Instance.new('PointLight'); l.Range=18; l.Brightness=1; l.Color=flame.Color; l.Shadows=false; l.Parent=flame end
end
function G.beam(parent,a,b,width,color,material)
    local delta=b-a
    return G.part(parent,'Beam',Vector3.new(width,width,delta.Magnitude),CFrame.lookAt((a+b)/2,b),color,material)
end
return G
