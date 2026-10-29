local Config=require('../src/shared/Config/MapVisualConfig')
local Rules=require('../src/shared/Core/MapVisualRules')
local state=Rules.new(false)
assert(state.Level==3 and state.Mode=='AUTO')
for _=1,600 do Rules.step(state,1/20) end
assert(state.Level==1,'Sustained slow frames should lower AUTO to LOW')
for _=1,4000 do Rules.step(state,1/90) end
assert(state.Level==3,'Sustained fast frames should recover slowly')
assert(Rules.select(state,'LOW'))
for _=1,4000 do Rules.step(state,1/90) end
assert(state.Level==1,'Manual mode must not change adaptively')
assert(not Rules.select(state,'EXPLOIT'))
assert(Rules.step(state,0)=='LOW' and Rules.step(state,0/0)=='LOW')
assert(Rules.distanceVisible(1000,180,Config.Profiles.LOW,true),'Collision geometry is never hidden')
assert(not Rules.distanceVisible(1000,180,Config.Profiles.HIGH,false),'Far fine detail can be hidden locally')
for _,profile in Config.Profiles do
    assert(profile.Lights<=48 and profile.Particles<=20 and profile.DetailScale>0)
end
print('PASSOU: perfis visuais/AUTO têm histerese, respeitam modo manual e preservam geometria colidível; FPS reais não medidos.')
