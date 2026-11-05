-- Reuse the unchanged V2 installer/rollback with the imported avatar factory.
local Factory={}
function Factory.build(rig,style)return require(script.Parent.Parent.Parent.AvatarAppearance).build(rig,style)end
return Factory
