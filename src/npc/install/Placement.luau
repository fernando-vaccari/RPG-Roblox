-- Read-only map queries. Never writes Terrain, moves buildings or guesses interiors.
local P={}
function P.resolve(world,path)
 local node=world;for segment in path:gmatch('[^/]+')do node=node and node:FindFirstChild(segment)end;return node
end
function P.safe(position,ignore,expectedY)
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances=ignore;params.IgnoreWater=false;params.RespectCanCollide=true
 local hit=workspace:Raycast(position+Vector3.new(0,12,0),Vector3.new(0,-40,0),params)
 if not hit or hit.Material==Enum.Material.Water or (hit.Normal and hit.Normal.Y<0.85) or math.abs(hit.Position.Y-expectedY)>6 then return nil end
 local feet=hit.Position+Vector3.new(0,0.12,0)
 local box=OverlapParams.new();box.FilterType=Enum.RaycastFilterType.Exclude;local ignored=table.clone(ignore);table.insert(ignored,workspace.Terrain);box.FilterDescendantsInstances=ignored;box.RespectCanCollide=true
 for _,part in workspace:GetPartBoundsInBox(CFrame.new(feet+Vector3.new(0,3.7,0)),Vector3.new(4.8,7,4.8),box)do
  if part.CanCollide then return nil end
 end
 return feet
end
function P.frame(world,entry,npcs,strict)
 local anchor=P.resolve(world,entry.Anchor)
 if not anchor or not anchor:IsA('BasePart') then return nil,'Âncora ausente: '..entry.Anchor end
 local offset=Vector3.new(table.unpack(entry.Offset));local position=anchor.CFrame:PointToWorldSpace(offset)
 if strict then
  local safe=P.safe(position,{npcs},position.Y);if not safe then return nil,'Piso/obstáculo incompatível: '..entry.Id end;position=safe
 end
 local look=anchor.CFrame.LookVector
 return CFrame.lookAt(position,position+Vector3.new(look.X,0,look.Z))
end
return P
