-- Preserve the installed position. This adapter never calls PivotTo or changes CFrame.
local Adapter={}
function Adapter.frame(npc,world,entry,folder,placement)
 if npc:GetAttribute('NPCVisualVersion')~=2 then return entry and placement.frame(world,entry,folder,true)end
 local root=npc:FindFirstChild('HumanoidRootPart');if not root then return nil end
 local frame=root.CFrame*CFrame.new(0,-3,0)
 local floor=placement.safe(frame.Position,{folder},frame.Position.Y)
 local valid=floor~=nil and math.abs(floor.Y-frame.Position.Y)<=.8
 npc:SetAttribute('NPCV2PatrolFloorValid',valid)
 if not valid then warn('[NPC V2] Piso incompatível em '..npc.Name..'; posição preservada e patrulha bloqueada. Revise a cópia manualmente.')end
 return frame
end
return Adapter
