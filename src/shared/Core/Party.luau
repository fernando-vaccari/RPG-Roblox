-- Sem engine: máquina de estados para confirmação de grupos.
local Party = {}
function Party.new(leader)
    return {Leader=leader,Members={leader},Confirmed={},State="Forming"}
end
function Party.join(p,id)
    if p.State~="Forming" or #p.Members>=4 then return false end
    for _,v in p.Members do if v==id then return false end end
    table.insert(p.Members,id); table.clear(p.Confirmed); return true
end
function Party.confirm(p,id)
    if p.State~="Forming" then return false end
    for _,v in p.Members do if v==id then p.Confirmed[id]=true; return true end end
    return false
end
function Party.ready(p,present)
    if p.State~="Forming" or #p.Members<1 or #p.Members>4 then return false end
    for _,id in p.Members do if not p.Confirmed[id] or not present(id) then return false end end
    return true
end
function Party.remove(p,id)
    if p.State~="Forming" then return false end
    for i,v in p.Members do
        if v==id then
            table.remove(p.Members,i); table.clear(p.Confirmed)
            if p.Leader==id then p.Leader=p.Members[1] end
            return true
        end
    end
    return false
end
return Party
