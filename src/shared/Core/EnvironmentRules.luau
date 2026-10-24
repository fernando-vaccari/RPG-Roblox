local E={Profiles={LOW={FX=12,Rain=0,Bloom=0.04},MEDIUM={FX=20,Rain=12,Bloom=0.1},HIGH={FX=28,Rain=24,Bloom=0.15}}}
function E.weather(serverSeconds)
 local cycle=math.floor(serverSeconds/300)%4
 return if cycle==1 then 'Mist' elseif cycle==2 then 'Rain' else 'Clear'
end
return E
