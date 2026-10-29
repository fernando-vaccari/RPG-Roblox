-- Alternativa procedural R6 válida, sem downloads ou animações de terceiros.
local Rig={}
function Rig.create(parent,name,position,color,hostile,kind)
    local model=Instance.new('Model'); model.Name=name
    local function limb(id,size,offset,paint,collide)
        local p=Instance.new('Part'); p.Name=id; p.Size=size; p.Position=position+offset
        p.Color=paint; p.Material=Enum.Material.SmoothPlastic; p.CanCollide=collide==true; p.CanTouch=false
        p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth; p.Parent=model; return p
    end
    local skin=Color3.fromRGB(214,171,133)
    local root=limb('HumanoidRootPart',Vector3.new(2,2,1),Vector3.new(0,3,0),color,false); root.Transparency=1
    local torso=limb('Torso',Vector3.new(2,2,1),Vector3.new(0,3,0),color,hostile)
    local head=limb('Head',Vector3.new(2,1,1),Vector3.new(0,4.5,0),skin,false)
    local headMesh=Instance.new('SpecialMesh');headMesh.MeshType=Enum.MeshType.Head;headMesh.Scale=Vector3.new(1.15,1.15,1.15);headMesh.Parent=head
    local leftArm=limb('Left Arm',Vector3.new(1,2,1),Vector3.new(-1.5,3,0),color,false)
    local rightArm=limb('Right Arm',Vector3.new(1,2,1),Vector3.new(1.5,3,0),color,false)
    local leftLeg=limb('Left Leg',Vector3.new(1,2,1),Vector3.new(-0.5,1,0),Color3.fromRGB(60,56,51),false)
    local rightLeg=limb('Right Leg',Vector3.new(1,2,1),Vector3.new(0.5,1,0),Color3.fromRGB(60,56,51),false)
    local function joint(id,a,b,c0,c1)
        local motor=Instance.new('Motor6D'); motor.Name=id; motor.Part0=a; motor.Part1=b; motor.C0=c0; motor.C1=c1; motor.Parent=a
    end
    joint('RootJoint',root,torso,CFrame.identity,CFrame.identity)
    joint('Neck',torso,head,CFrame.new(0,1,0),CFrame.new(0,-0.5,0))
    joint('Left Shoulder',torso,leftArm,CFrame.new(-1,0.5,0),CFrame.new(0.5,0.5,0))
    joint('Right Shoulder',torso,rightArm,CFrame.new(1,0.5,0),CFrame.new(-0.5,0.5,0))
    joint('Left Hip',torso,leftLeg,CFrame.new(-0.5,-1,0),CFrame.new(0,1,0))
    joint('Right Hip',torso,rightLeg,CFrame.new(0.5,-1,0),CFrame.new(0,1,0))
    local function adorn(id,size,offset,paint,base)
        base=base or head
        local p=limb(id,size,base.Position-position+offset,paint,false); p.Massless=true
        local weld=Instance.new('WeldConstraint'); weld.Part0=base; weld.Part1=p; weld.Parent=p
        return p
    end
    for _,x in {-0.4,0.4} do adorn('Eye',Vector3.new(0.15,0.18,0.1),Vector3.new(x,0.1,-0.54),Color3.fromRGB(22,26,31)) end
    if kind=='Mage' or kind=='ShopMagic' then
        adorn('WizardHat',Vector3.new(2.4,1.4,2),Vector3.new(0,1,0),color)
        adorn('Robe',Vector3.new(2.2,2.4,1.3),Vector3.new(0,-0.6,0),color,torso)
    elseif kind=='Guard' or hostile then
        adorn('Helmet',Vector3.new(2.1,0.5,1.2),Vector3.new(0,0.5,0),Color3.fromRGB(106,115,128))
        adorn('Breastplate',Vector3.new(2.1,1.7,0.3),Vector3.new(0,0,-0.65),color,torso)
    else
        adorn('Apron',Vector3.new(1.5,1.8,0.2),Vector3.new(0,-0.2,-0.6),Color3.fromRGB(72,49,36),torso)
        adorn('Belt',Vector3.new(2.1,0.25,1.1),Vector3.new(0,-0.6,0),Color3.fromRGB(68,47,29),torso)
    end
    if kind=='Wolf' or kind=='DarkWolf' then
        adorn('Muzzle',Vector3.new(1.2,0.6,1),Vector3.new(0,-0.1,-0.8),color)
        for _,x in {-0.7,0.7} do adorn('Ear',Vector3.new(0.5,0.9,0.5),Vector3.new(x,0.9,0),color) end
    elseif kind=='Malgorth' or kind=='SylvarinBoss' or kind=='NoctharBoss' then
        for _,x in {-0.8,0.8} do adorn('Horn',Vector3.new(0.4,1.8,0.4),Vector3.new(x,1.1,0),Color3.fromRGB(38,24,31)) end
    elseif kind=='Slime' then
        local slime=adorn('SlimeBody',Vector3.new(4,3,4),Vector3.new(0,-0.5,0),color,torso)
        slime.Shape=Enum.PartType.Ball; slime.Transparency=0.2
    end
    local humanoid=Instance.new('Humanoid'); humanoid.DisplayName=name; humanoid.MaxHealth=100; humanoid.Health=100
    humanoid.HipHeight=0; humanoid.BreakJointsOnDeath=false; humanoid.RigType=Enum.HumanoidRigType.R6; humanoid.Parent=model
    root.Anchored=not hostile; model.PrimaryPart=root; model.Parent=parent
    if hostile then root:SetNetworkOwner(nil) end
    model:SetAttribute('ProceduralRig',true)
    return model,humanoid,root
end
return Rig
