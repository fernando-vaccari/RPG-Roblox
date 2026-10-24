local Players=game:GetService('Players')
local RunService=game:GetService('RunService')
local Teleport=game:GetService('TeleportService')
local Shared=game.ReplicatedStorage.MedievalRPG
local Config=require(Shared.Config.WorldConfig)
local Parties=require(Shared.Core.Party)
local Data=require(script.Parent.DataService)
local Security=require(script.Parent.AntiExploitService)
local D={Groups={},Membership={},Notice=nil,OnDungeonReady=nil}
local function tell(p,message) if D.Notice then D.Notice(p,message) end end
local function eligible(p)
    local s=Data.get(p)
    local context=Security.context(p)
    return s and s.Rank=='F' and Security.alive(p) and context and context.Role=='Dungeon'
end
function D.status(player)
    local group=D.Membership[player.UserId]
    local list={}
    if group then
        for _,id in group.Members do
            local p=Players:GetPlayerByUserId(id)
            table.insert(list,{Id=id,Name=if p then p.DisplayName else tostring(id),Confirmed=group.Confirmed[id]==true})
        end
    end
    return {Leader=group and group.Leader,Members=list,State=group and group.State or 'Solo',Code=group and group.Leader}
end
function D.leave(player,force)
    local group=D.Membership[player.UserId]
    if not group then return end
    if force then group.State='Forming' end
    if group.State~='Forming' then return end
    local oldLeader=group.Leader
    Parties.remove(group,player.UserId);D.Membership[player.UserId]=nil
    D.Groups[oldLeader]=nil
    if #group.Members>0 then D.Groups[group.Leader]=group end
end
local function recover(list)
    for _,p in list do
        if p.Parent==Players then task.spawn(function() local slot=Data.Sessions[p];local ok=Data.load(p,slot and slot.Token);tell(p,if ok then 'Teleporte interrompido; perfil recarregado. Reabra o guardião.' else 'Perfil ainda indisponível; nenhuma recuperação foi confirmada.') end) end
    end
end
function D.transfer(group)
    local list={}
    if not Parties.ready(group,function(id)
        local p=Players:GetPlayerByUserId(id)
        if p and eligible(p) then table.insert(list,p);return true end
        return false
    end) then return false,'Todos devem estar vivos, registrados, próximos e confirmados.' end
    if RunService:IsStudio() then
        if not Config.StudioDungeonTest then return false,'Modo de teste local desativado.' end
        local map=workspace:FindFirstChild('GeneratedDungeon')
        if not map then
            local ok,result=pcall(function()
                return require(game.ServerStorage.MedievalWorldgen.DungeonInteriorGenerator).GenerateDungeon({Origin=Vector3.new(6000,30,0),StudioTest=true})
            end)
            if not ok then warn(result);return false,'Falha ao criar mapa isolado de teste; consulte Output.' end
            map=result
            if D.OnDungeonReady then D.OnDungeonReady(map) end
        end
        group.State='LocalTest'
        for i,p in list do
            p:SetAttribute('InDungeon',true)
            p.Character:PivotTo(CFrame.new(map:GetAttribute('SpawnPosition')+Vector3.new((i-1)*4,0,0)))
            tell(p,'TESTE LOCAL: movimentação no mesmo Place. Nenhum teleporte real foi testado.')
        end
        return true,'Grupo entrou no teste local.'
    end
    if Config.DungeonPlaceId<=0 or Config.ReturnPlaceId<=0 then return false,'Configure DungeonPlaceId e ReturnPlaceId com IDs reais da mesma Experience.' end
    if not Data.Persistent then return false,'Habilite e valide DataStore antes de usar teleporte publicado.' end
    group.State='Teleporting'
    for _,p in list do
        local slot=Data.Sessions[p]
        local saved=Data.save(p,true)
        if not saved then group.State='Forming';recover(list);return false,'Não foi possível salvar todos os perfis; teleporte cancelado.' end
    end
    local options=Instance.new('TeleportOptions');options.ShouldReserveServer=true
    options:SetTeleportData({Party=group.Members,OriginPlaceId=game.PlaceId}) -- Sem itens, Gold ou recompensas no TeleportData.
    local ok,err=pcall(function() Teleport:TeleportAsync(Config.DungeonPlaceId,list,options) end)
    if not ok then warn(err);group.State='Forming';recover(list);return false,'Teleporte falhou. Perfis serão recarregados.' end
    return true,'Teleporte solicitado; aguarde a resposta da plataforma.'
end
function D.action(player,action,code)
    if not eligible(player) then return false,'Registre Rank F e converse com o guardião novamente.' end
    local group=D.Membership[player.UserId]
    if action=='Leave' then D.leave(player);return true,'Grupo atualizado.' end
    if action=='Create' then
        if group then return false,'Saia do grupo atual primeiro.' end
        group=Parties.new(player.UserId);D.Groups[player.UserId]=group;D.Membership[player.UserId]=group
        return true,'Grupo criado. Código: '..player.UserId
    elseif action=='Join' then
        if group or type(code)~='number' or code%1~=0 then return false,'Código inválido ou você já está em grupo.' end
        local target=D.Groups[code]
        local leader=target and Players:GetPlayerByUserId(target.Leader)
        if not target or not leader or not eligible(leader) then return false,'Grupo indisponível.' end
        if not Parties.join(target,player.UserId) then return false,'Grupo cheio ou iniciado.' end
        D.Membership[player.UserId]=target;return true,'Você entrou no grupo; todos devem confirmar novamente.'
    elseif action=='Confirm' and group then
        Parties.confirm(group,player.UserId);return true,'Presença confirmada. O líder pode iniciar.'
    elseif action=='Start' and group then
        if group.Leader~=player.UserId then return false,'Somente o líder pode iniciar.' end
        return D.transfer(group)
    elseif action=='Solo' then
        if group then return false,'Saia do grupo antes de entrar sozinho.' end
        group=Parties.new(player.UserId);Parties.confirm(group,player.UserId)
        local ok,message=D.transfer(group)
        if ok then D.Membership[player.UserId]=group;D.Groups[player.UserId]=group end
        return ok,message
    end
    return false,'Ação de grupo inválida.'
end
function D.returnPlayer(player)
    if RunService:IsStudio() then
        local map=workspace:FindFirstChild('GeneratedWorld')
        local spawn=map and map:FindFirstChild('Spawns') and map.Spawns:FindFirstChild('ValoriaSpawn')
        if not spawn or not player.Character then return false,'Place de continente ausente neste teste. Use Stop para sair.' end
        player.Character:PivotTo(spawn.CFrame+Vector3.new(0,5,0));player:SetAttribute('InDungeon',false)
        local group=D.Membership[player.UserId]
        if group then group.State='Forming';D.leave(player) end
        return true,'Retorno local concluído; sem TeleportService.'
    end
    if Config.ReturnPlaceId<=0 then return false,'Configure ReturnPlaceId no Place da dungeon.' end
    local slot=Data.Sessions[player]
    if not slot then return false,'Perfil indisponível.' end
    if not Data.save(player,true) then recover({player});return false,'Falha de salvamento; retorno cancelado.' end
    local ok,err=pcall(function() Teleport:TeleportAsync(Config.ReturnPlaceId,{player}) end)
    if not ok then warn(err);recover({player});return false,'Falha de teleporte; perfil será recarregado.' end
    return true,'Retorno solicitado.'
end
function D.start()
    Teleport.TeleportInitFailed:Connect(function(player)
        local slot=Data.Sessions[player]
        if slot and slot.Released then recover({player}) end
        local group=D.Membership[player.UserId]
        if group then group.State='Forming';table.clear(group.Confirmed) end
    end)
end
return D
