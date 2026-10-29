local Rules={}
local levels={'LOW','MEDIUM','HIGH'}
function Rules.new(touch)
    return {Mode='AUTO',Level=if touch then 2 else 3,EMA=1/60,Slow=0,Fast=0}
end
function Rules.select(state,mode)
    if mode~='AUTO' and not table.find(levels,mode) then return false end
    state.Mode=mode;state.Slow=0;state.Fast=0
    if mode~='AUTO' then state.Level=table.find(levels,mode) end
    return true
end
function Rules.step(state,dt)
    if type(dt)~='number' or dt~=dt or dt<=0 then return levels[state.Level] end
    -- Long pauses do not immediately punish a profile; real frame pacing does.
    dt=math.min(dt,0.25)
    state.EMA+=(dt-state.EMA)*0.05
    if state.Mode=='AUTO' then
        state.Slow=if state.EMA>1/28 then state.Slow+dt else 0
        state.Fast=if state.EMA<1/50 then state.Fast+dt else 0
        if state.Slow>=3 and state.Level>1 then
            state.Level-=1;state.Slow=0;state.Fast=0
        elseif state.Fast>=12 and state.Level<3 then
            state.Level+=1;state.Slow=0;state.Fast=0
        end
    end
    return levels[state.Level]
end
function Rules.distanceVisible(distance,baseDistance,profile,collidable)
    -- Fine decorative objects only. Never hide a collidable building/region.
    return collidable or distance<=baseDistance*profile.DetailScale
end
return Rules
