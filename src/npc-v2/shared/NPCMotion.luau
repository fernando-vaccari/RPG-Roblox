-- Authored procedural pose vocabulary. Radians, no assets, Instances or gameplay state.
local M={}
function M.pose(state,t,phase,reduced)
 local p={};local rad=math.rad
 local function joint(name,x,y,z)p[name]={rad(x or 0),rad(y or 0),rad(z or 0)}end
 local breath=math.sin(t*1.6+phase)
 joint('Waist',.6*breath,0,.45*math.sin(t*.65+phase));joint('Neck',.6*breath,2.5*math.sin(t*.38+phase),0)
 joint('LeftShoulder',1.5*breath,0,-3);joint('RightShoulder',-1.5*breath,0,3)
 joint('LeftElbow',5,0,0);joint('RightElbow',5,0,0)
 if reduced and state~='Walk' and state~='Run' then return p end
 local pulse=math.sin(t*2.6+phase)
 if state=='Walk' or state=='Run' then
  local run=state=='Run';local step=math.sin(t*(if run then 9 else 5.5)+phase);local swing=if run then 36 else 22
  joint('LeftHip',swing*step,0,0);joint('RightHip',-swing*step,0,0)
  joint('LeftKnee',-math.max(0,-step)*(if run then 46 else 28),0,0);joint('RightKnee',-math.max(0,step)*(if run then 46 else 28),0,0)
  joint('LeftAnkle',-8*step,0,0);joint('RightAnkle',8*step,0,0)
  joint('LeftShoulder',-swing*step,0,-4);joint('RightShoulder',swing*step,0,4);joint('Waist',if run then -8 else -2,1.2*step,0)
 elseif state=='Greet' then
  joint('RightShoulder',28,0,84);joint('RightElbow',65,0,0);joint('RightWrist',0,0,14*math.sin(t*10));joint('Neck',-3,0,-4)
 elseif state=='Talk' or state=='Trade' or state=='Orient' then
  joint('RightShoulder',22+5*pulse,0,12);joint('RightElbow',39+9*pulse,0,0);joint('RightWrist',0,12*math.sin(t*1.4),-8)
  joint('LeftElbow',15+7*math.sin(t*1.8+phase),0,0);joint('Neck',2*math.sin(t*2.1),0,0)
 elseif state=='Forge' then
  local lift=(math.sin(t*3+phase)+1)/2
  joint('Waist',-8,0,-3);joint('RightShoulder',35+35*lift,0,8);joint('RightElbow',12+53*lift,0,0)
  joint('RightWrist',12-16*lift,0,0);joint('LeftShoulder',27,0,-5);joint('LeftElbow',24,0,0);joint('Neck',-18,0,0)
 elseif state=='Study' or state=='Documents' then
  joint('LeftShoulder',34,0,-9);joint('LeftElbow',65,0,0);joint('LeftWrist',0,0,-8)
  joint('RightShoulder',23,0,5);joint('RightElbow',45+5*pulse,0,0);joint('RightWrist',0,9*pulse,0);joint('Neck',-16,2*pulse,0)
 elseif state=='Arcane' then
  joint('RightShoulder',38,0,24);joint('RightElbow',28-5*pulse,0,0);joint('LeftShoulder',18,0,-23);joint('LeftElbow',55,0,0)
  joint('LeftWrist',0,18*pulse,0);joint('Neck',-7,0,0)
 elseif state=='Inspect' then
  joint('LeftShoulder',30,0,-6);joint('LeftElbow',43,0,0);joint('RightShoulder',28,0,10);joint('RightElbow',48,0,0);joint('Neck',-13,8*pulse,0)
 elseif state=='Organize' then
  joint('Waist',-5,5*pulse,0);joint('RightShoulder',36+8*pulse,0,9);joint('RightElbow',21+10*pulse,0,0);joint('LeftShoulder',18,0,-5);joint('LeftElbow',35,0,0)
 elseif state=='Serve' then
  joint('RightShoulder',45+5*pulse,0,5);joint('RightElbow',20,0,0);joint('LeftShoulder',10,0,-8);joint('LeftElbow',25,0,0);joint('Neck',-2,3*pulse,0)
 elseif state=='Observe' then joint('Neck',0,10*math.sin(t*.35+phase),0);joint('Waist',0,3*math.sin(t*.35+phase),0)
 end
 return p
end
function M.work(base,t,phase,cycle)
 cycle=cycle or 18;local slot=math.floor((t+phase)%cycle/(cycle/3))
 if base=='Forge' then return ({'Forge','Inspect','Organize'})[slot+1]end
 if base=='Study' then return ({'Study','Study','Arcane'})[slot+1]end
 if base=='Trade' then return ({'Trade','Organize','Trade'})[slot+1]end
 return base
end
return M
