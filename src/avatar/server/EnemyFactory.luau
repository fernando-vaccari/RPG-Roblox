-- Visual factory only: EnemyService retains all AI, health, damage and rewards.
local F={}
local Catalog=require(script.Parent.AvatarCatalog)
local Proxy=require(script.Parent.ProxyRig)
local function frame(v)return CFrame.new(table.unpack(v))end
function F.create(parent,name,position,_color,hostile,kind)
 assert(hostile,'Biblioteca de inimigos não cria NPCs de serviço')
 local key=Catalog.Enemies[kind];local def=key and Catalog.Models[key]
 local template=def and script.Parent.Templates:FindFirstChild(key);assert(template,'Modelo de inimigo não registrado: '..tostring(kind))
 local model=Proxy.create(parent,{Id=name,Role='Guard',City='Enemy',Ambient=false},{Name=name,Title='Inimigo'},CFrame.new(position))
 local root=model.PrimaryPart;local hum=model:FindFirstChildOfClass('Humanoid');local bodies={HumanoidRootPart=root}
 local ok,err=pcall(function()
  for bone in Catalog.R15 do bodies[bone]=assert(model:FindFirstChild(bone),'Proxy R15 incompleto')end
  for _,child in model:GetChildren()do if child:IsA('BasePart') then
   if not bodies[child.Name] then child:Destroy()else child.Transparency=1;child.CanCollide=child.Name=='UpperTorso';child.CanQuery=child.CanCollide end
  end end
  local prompt=model:FindFirstChild('NPCInteraction',true);if prompt then prompt:Destroy()end
  for _,keyName in {'EldravynNPCId','NPCRole','City','AmbientNPC','NPCVersion'}do model:SetAttribute(keyName,nil)end
  local visuals=Instance.new('Folder');visuals.Name='AvatarEnemyVisuals';visuals.Parent=model
  local feet=root.CFrame*CFrame.new(0,-3,0)
  for _,bone in def.Bones do
   local source=assert(template:FindFirstChild(bone));local target=bodies[bone]
   if not target then
    local p=Instance.new('Part');p.Name='AvatarAnchor_'..bone;p.Size=Vector3.new(.1,.1,.1);p.Transparency=1;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Massless=true
    local point=Catalog.Quadruped[bone]or{0,.95,0};p.CFrame=feet*frame(point);p.Parent=model;target=p
    local pivot=if bone:find('Front')or bone:find('Hind')then{point[1],1.48,point[3]}elseif bone=='BeastHead'then{0,1.80,-.7}elseif bone=='BeastTail'then{0,1.65,1.0}else point
    local motor=Instance.new('Motor6D');motor.Name='Avatar_'..bone;motor.Part0=root;motor.Part1=p
    local worldPivot=feet*frame(pivot);motor.C0=root.CFrame:ToObjectSpace(worldPivot);motor.C1=p.CFrame:ToObjectSpace(worldPivot);motor.Parent=root
   end
   local mesh=source:Clone();mesh.Name='Avatar_'..bone;mesh.CFrame=feet*source.CFrame;mesh.Anchored=false;mesh.Massless=true;mesh.CanCollide=false;mesh.CanTouch=false;mesh.CanQuery=true;mesh.Parent=visuals
   if def.Kind=='Blob'then mesh.Transparency=.12 end
   local weld=Instance.new('WeldConstraint');weld.Part0=target;weld.Part1=mesh;weld.Parent=mesh
  end
  hum.AutoRotate=true;root.Anchored=false;root.Massless=false
  model:SetAttribute('AvatarEnemyKind',kind);model:SetAttribute('AvatarRigKind',def.Kind);model:SetAttribute('EnemyKind',kind);model:SetAttribute('AvatarArtVersion',3)
  game:GetService('CollectionService'):AddTag(model,'EldravynAvatarEnemy')
  if game:GetService('RunService'):IsRunning()then root:SetNetworkOwner(nil)end
 end)
 if not ok then model:Destroy();error(err)end
 return model,hum,root
end
return F
