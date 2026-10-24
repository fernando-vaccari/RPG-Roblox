-- Regras puras e autoritativas. Apenas o servidor chama estas mutações.
local P = {}
function P.new()
    return {Gold=100,XP=0,Rank="",Class="",Equipment="",StarterChosen=false,Unlocks={},Inventory={},Quests={},Claims={},Spawn="Valoria",Revision=0}
end
local function integer(n,lo,hi)
    return type(n)=="number" and n==n and n%1==0 and n>=lo and n<=hi
end
function P.sanitize(raw, catalog)
    local out = P.new()
    if type(raw)~="table" then return out end
    for _,k in {"Gold","XP","Revision"} do
        if integer(raw[k],0,1000000000) then out[k]=raw[k] end
    end
    if raw.Rank=="F" then out.Rank="F" end
    if type(raw.Inventory)=="table" then
        for id,item in catalog.Items do
            local value=raw.Inventory[id]
            if integer(value,1,if item.Kind=="Consumable" or item.Kind=="Material" then 99 else 1) then out.Inventory[id]=value end
        end
    end
    if catalog.Items[raw.Equipment] and out.Inventory[raw.Equipment] then out.Equipment=raw.Equipment end
    out.StarterChosen=raw.StarterChosen==true
    for id in out.Inventory do if catalog.Items[id].Kind=="Weapon" then out.StarterChosen=true end end
    if type(raw.Quests)=="table" then
        for id,q in catalog.Quests do
            local v=raw.Quests[id]
            if type(v)=="table" then out.Quests[id]={Count=if integer(v.Count,0,q.Required) then v.Count else 0,Claimed=v.Claimed==true} end
        end
    end
    if out.Quests.FirstSteps and out.Quests.FirstSteps.Claimed then
        -- Classe persistida só pode corresponder a um equipamento de classe conhecido.
        for _,item in catalog.Items do if item.Class==raw.Class then out.Class=raw.Class end end
    end
    if type(raw.Unlocks)=="table" then
        for id,value in raw.Unlocks do if type(id)=="string" and #id<50 and value==true then out.Unlocks[id]=true end end
    end
    if type(raw.Claims)=="table" then
        local n=0
        for id,v in raw.Claims do
            if type(id)=="string" and #id<=100 and v==true and n<512 then out.Claims[id]=true; n+=1 end
        end
    end
    for _,id in {"Valoria","Arkheim","Eldoria","Durakh"} do if raw.Spawn==id then out.Spawn=id end end
    return out
end
function P.register(s)
    if s.Rank~="" then return false,"Você já está registrado." end
    s.Rank="F"; s.Quests.FirstSteps={Count=0,Claimed=false}
    return true,"Registro concluído: Rank F."
end
function P.buy(s,catalog,id,role)
    local item=catalog.Items[id]
    local allowed=false
    for _,candidate in catalog.Shops[role] or {} do if candidate==id then allowed=true end end
    if not item or not allowed then return false,"Item indisponível nesta loja." end
    if item.Kind~="Consumable" and item.Kind~="Material" and (s.Inventory[id] or 0)>0 then return false,"Você já possui este item." end
    if (s.Inventory[id] or 0)>=99 then return false,"Inventário cheio." end
    if s.Gold<item.Price then return false,"Gold insuficiente." end
    s.Gold-=item.Price; s.Inventory[id]=(s.Inventory[id] or 0)+1
    return true,"Compra concluída."
end
function P.choose(s,catalog,id)
    local item=catalog.Items[id]
    if not item or item.Kind~="Weapon" then return false,"Equipamento inválido." end
    if s.StarterChosen or s.Equipment~="" then return false,"O equipamento gratuito já foi escolhido." end
    s.StarterChosen=true;s.Inventory[id]=1; s.Equipment=id
    return true,"Equipamento recebido. Use a ferramenta para atacar."
end
function P.accept(s,catalog,id)
    if s.Rank=="" or not catalog.Quests[id] or s.Quests[id] then return false,"Missão indisponível." end
    local q=catalog.Quests[id]
    for _,pre in q.Prerequisites or {} do if not s.Quests[pre] or not s.Quests[pre].Claimed then return false,"Conclua a missão anterior." end end
    if q.Target=="Supplies" then s.Inventory.SupplyParcel=1 end
    s.Quests[id]={Count=0,Claimed=false}; return true,"Missão aceita."
end
function P.event(s,catalog,target,amount)
    if not integer(amount,1,10) then return end
    local changed=false
    for id,state in s.Quests do
        local q=catalog.Quests[id]
        if q and not state.Claimed and q.Target==target then local before=state.Count;state.Count=math.min(q.Required,state.Count+amount);changed=changed or state.Count~=before end
    end
    return changed
end
function P.claimQuest(s,catalog,id)
    local q, state=catalog.Quests[id],s.Quests[id]
    if not q or not state or state.Claimed or state.Count<q.Required then return false,"Objetivos pendentes ou recompensa já recebida." end
    if id=="FirstSteps" and (s.Rank~="F" or not catalog.Items[s.Equipment]) then return false,"Registre-se e escolha equipamento." end
    if q.Target=="Supplies" then s.Inventory.SupplyParcel=nil end
    state.Claimed=true; s.Gold=math.min(1000000000,s.Gold+q.Gold); s.XP=math.min(1000000000,s.XP+q.XP)
    if id=="FirstSteps" then s.Class=catalog.Items[s.Equipment].Class end
    return true,"Missão concluída!"
end
function P.chest(s,catalog,id,rarity)
    local reward=catalog.ChestRewards[rarity]
    if not reward or s.Claims[id] then return false,"Baú já coletado ou inválido." end
    local n=0; for _ in s.Claims do n+=1 end
    if n>=512 then return false,"Limite de registros de baú atingido." end
    s.Claims[id]=true; s.Gold=math.min(1000000000,s.Gold+reward)
    return true,"Baú: +"..reward.." Gold."
end
function P.sell(s,catalog,id)
    local item=catalog.Items[id]
    if not item or item.Kind=='Quest' or not item.Price or (s.Inventory[id] or 0)<1 or s.Equipment==id then return false,'Item indisponível para venda; desequipe antes.' end
    s.Inventory[id]-=1;if s.Inventory[id]==0 then s.Inventory[id]=nil end;s.Gold=math.min(1000000000,s.Gold+math.floor(item.Price*0.4));return true,'Venda concluída.'
end
return P
