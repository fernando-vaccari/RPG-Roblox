local Players=game:GetService('Players')
local Http=game:GetService('HttpService')
local DSS=game:GetService('DataStoreService')
local Shared=game.ReplicatedStorage.MedievalRPG
local Config=require(Shared.Config.WorldConfig)
local Catalog=require(Shared.Config.ContentConfig)
local Rules=require(Shared.Core.Progression)
local Identity=require(Shared.Core.IdentityRules)
local IdentityConfig=require(Shared.Config.IdentityConfig)
Identity.validate(IdentityConfig)
local function prepare(raw)
    assert(raw==nil or type(raw)=='table','Perfil inválido; defaults não serão gravados')
    local state=Rules.sanitize(raw,Catalog)
    Identity.restore(state,type(raw)=='table' and raw.Identity or nil,IdentityConfig)
    return state
end
local Data={Sessions={},Persistent=Config.EnableDataStore}
local store=if Data.Persistent then DSS:GetDataStore('MedievalRPG_v1') else nil
local function clone(t) return Http:JSONDecode(Http:JSONEncode(t)) end
function Data.load(player,reuseToken)
    local previous=Data.Sessions[player]
    if previous and (previous.Saving or previous.Loading) then return false,'Perfil ocupado; aguarde a operação atual.' end
    local slot={Loading=true,PendingDeath=previous and previous.PendingDeath,Token=reuseToken or Http:GenerateGUID(false),State=Rules.new(),Ready=false,Saving=false,Frozen=false}
    Data.Sessions[player]=slot
    if not store then slot.State=prepare(nil);slot.Ready=true;slot.Loading=false; return true,'Modo volátil: raça não sorteada. Persistência é obrigatória para identidade permanente.' end
    local candidate
    local ok,result
    for attempt=1,3 do
        ok,result=pcall(function()
            return store:UpdateAsync('Player_'..player.UserId,function(old)
                assert(old==nil or type(old)=='table' and type(old.Data)=='table','Envelope existente inválido; preservar para recuperação')
                old=old or {}
                assert(old.Session==nil or type(old.Session)=='table' and type(old.Session.Token)=='string' and type(old.Session.Expires)=='number' and old.Session.Expires==old.Session.Expires,'Lock inválido')
                local lock=old.Session
                if lock and lock.Token~=slot.Token and type(lock.Expires)=='number' and lock.Expires>os.time() then return nil end
                local profile=prepare(old.Data)
                if profile.Identity.Race=='' then
                    if not candidate then candidate=math.random(1,100) end
                    Identity.assign(profile,IdentityConfig,candidate)
                end
                Identity.refresh(profile,IdentityConfig,os.time())
                if slot.PendingDeath then Identity.fail(profile,IdentityConfig,slot.PendingDeath) end
                return {Data=profile,Session={Token=slot.Token,Expires=os.time()+180}}
            end)
        end)
        if ok and result and result.Session and result.Session.Token==slot.Token then break end
        if attempt<3 then task.wait(attempt) end
    end
    if not ok or not result or not result.Session or result.Session.Token~=slot.Token then
        slot.Loading=false;slot.Frozen=true
        warn('Perfil indisponível para '..player.UserId..'; nenhuma gravação de defaults será feita.')
        return false,'Dados indisponíveis ou sessão ativa em outro servidor. Entre novamente mais tarde.'
    end
    slot.State=prepare(result.Data);slot.Ready=true;slot.Loading=false;slot.PendingDeath=nil;slot.LeaseUntil=result.Session.Expires
    if player.Parent~=Players then Data.save(player,true);Data.Sessions[player]=nil end
    return true,'Progresso carregado.'
end
function Data.get(player)
    local slot=Data.Sessions[player]
    if slot and store and slot.Ready and slot.LeaseUntil and os.time()>=slot.LeaseUntil then slot.Frozen=true end
    return if slot and slot.Ready and not slot.Frozen and not slot.Released then slot.State else nil
end
function Data.save(player,release)
    local slot=Data.Sessions[player]
    if slot and slot.Released then return true end
    if not slot or not slot.Ready or slot.Saving or slot.Frozen then return false,'Perfil ocupado/indisponível' end
    if not store then return true end
    slot.Saving=true
    if release then slot.Frozen=true end
    slot.State.Identity.CurrentClass=slot.State.Class
    local snapshot=clone(slot.State)
    local ok,result=pcall(function()
        return store:UpdateAsync('Player_'..player.UserId,function(old)
            if type(old)~='table' or not old.Session or old.Session.Token~=slot.Token then return nil end
            if old.Data and old.Data.Identity and old.Data.Identity.Race~=snapshot.Identity.Race then return nil end
            return {Data=snapshot,Session=if release then nil else {Token=slot.Token,Expires=os.time()+180}}
        end)
    end)
    slot.Saving=false
    if not ok or not result then
        -- Congela em caso de erro ou perda de posse; evita recompensas em perfil sem lock.
        slot.Frozen=true;warn('Save falhou; perfil congelado para '..player.UserId)
        return false,'Falha de salvamento. Reconecte para proteger o progresso.'
    end
    if release then slot.Released=true else slot.LeaseUntil=result.Session.Expires;Data.flushDeath(player) end
    return true
end
-- Grant + durable receipt marker committed in the SAME owned profile transaction.
function Data.changeIdentity(player,mutation)
    local slot=Data.Sessions[player]
    if not store or not Data.get(player) or slot.Saving or slot.Released then return false,'Perfil ocupado ou sem persistência.' end
    local snapshot=clone(slot.State)
    snapshot.Identity.CurrentClass=snapshot.Class
    local accepted,message=mutation(snapshot)
    if not accepted then return false,message end
    snapshot.Identity.CurrentClass=snapshot.Class
    slot.Saving=true;slot.Frozen=true
    local ok,result=pcall(function()
        return store:UpdateAsync('Player_'..player.UserId,function(old)
            if not old or not old.Session or old.Session.Token~=slot.Token then return nil end
            if not old.Data or not old.Data.Identity or old.Data.Identity.Race~=snapshot.Identity.Race then return nil end
            return {Data=snapshot,Session={Token=slot.Token,Expires=os.time()+180}}
        end)
    end)
    slot.Saving=false
    if not ok or not result then return false,'Gravação incerta; perfil congelado até recarga. Nenhuma compra será confirmada.' end
    slot.State=prepare(result.Data);slot.Frozen=false;slot.LeaseUntil=result.Session.Expires
    Data.flushDeath(player)
    return true,message
end
function Data.receipt(player,receiptId,productId)
    local slot=Data.Sessions[player]
    if not store or not Data.get(player) or slot.Saving or slot.Released then return false end
    if slot.State.Identity.Receipts[receiptId] then return true end
    slot.Saving=true;slot.Frozen=true
    slot.State.Identity.CurrentClass=slot.State.Class
    local snapshot=clone(slot.State)
    local ok,result=pcall(function()
        return store:UpdateAsync('Player_'..player.UserId,function(old)
            if type(old)~='table' or not old.Session or old.Session.Token~=slot.Token then return nil end
            if not old.Data or not old.Data.Identity or old.Data.Identity.Race~=snapshot.Identity.Race then return nil end
            if old.Data.Identity.Receipts[receiptId] then return old end
            local nextState=clone(snapshot)
            if not Identity.grantReceipt(nextState,IdentityConfig,receiptId,productId) then return nil end
            return {Data=nextState,Session={Token=slot.Token,Expires=os.time()+180}}
        end)
    end)
    slot.Saving=false
    if not ok or not result then
        -- Keep frozen on uncertainty; Roblox must retry the receipt, never acknowledge a lost grant.
        warn('Recibo pendente; perfil requer recarga segura: '..player.UserId)
        return false
    end
    slot.State=prepare(result.Data);slot.Frozen=false;slot.LeaseUntil=result.Session.Expires
    Data.flushDeath(player)
    return slot.State.Identity.Receipts[receiptId]==true
end
function Data.noteDeath(player)
    local slot=Data.Sessions[player]
    if not slot or not slot.Ready then return end
    slot.PendingDeath=os.time()
    local changed=Identity.fail(slot.State,IdentityConfig,slot.PendingDeath)
    if not slot.Saving and not slot.Frozen then
        slot.PendingDeath=nil
        if changed then Data.save(player,false) end
    end
end
function Data.flushDeath(player)
    local slot=Data.Sessions[player]
    if not slot or not slot.PendingDeath then return end
    local at=slot.PendingDeath;slot.PendingDeath=nil
    local changed=Identity.fail(slot.State,IdentityConfig,at)
    if changed or slot.State.Identity.Racial.Status=='Failed' then Data.save(player,false) end
end
function Data.remove(player)
    local slot=Data.Sessions[player]
    if not slot then return end
    local limit=os.clock()+8
    while slot.Saving and os.clock()<limit do task.wait(0.1) end
    if slot.Frozen then
        -- Discard uncertain local snapshot; release ONLY our lock, preserving durable receipts/progress.
        if store and not slot.Saving then pcall(function()
            store:UpdateAsync('Player_'..player.UserId,function(old)
                if type(old)=='table' and old.Session and old.Session.Token==slot.Token then return {Data=old.Data} end
                return nil
            end)
        end) end
    else Data.save(player,true) end
    if Data.Sessions[player]==slot then Data.Sessions[player]=nil end
end
function Data.start()
    task.spawn(function()
        while task.wait(45) do
            for player,slot in Data.Sessions do
                if slot.Ready and not slot.Saving and not slot.Frozen then Data.save(player,false) end
            end
        end
    end)
    game:BindToClose(function()
        local pending=0
        for player in Data.Sessions do pending+=1;task.spawn(function() Data.remove(player);pending-=1 end) end
        local deadline=os.clock()+20
        while pending>0 and os.clock()<deadline do task.wait(0.1) end
    end)
end
return Data
