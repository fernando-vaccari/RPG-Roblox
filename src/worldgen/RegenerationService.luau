-- Substituições de instâncias próprias, com arquivo recuperável no ServerStorage.
-- Terrain nunca é removido/substituído por este serviço.
local G=require(script.Parent.Geometry)
local Plan=require(script.Parent.WorldPlan)
local Terrain=require(script.Parent.TerrainMath)
local Content=require(script.Parent.ContentGenerator)
local Decor=require(script.Parent.DecorationGenerator)
local Catalog=require(game.ReplicatedStorage.MedievalRPG.Config.ContentConfig)
local Config=require(game.ReplicatedStorage.MedievalRPG.Config.WorldConfig)
local R={Busy=false}
local function root()
    assert(not game:GetService('RunService'):IsRunning(),'Regeneração apenas no editor')
    local w=workspace:FindFirstChild('GeneratedWorld')
    assert(w and w:GetAttribute('ProjectId')==Config.ProjectId and w:GetAttribute('Status')=='Complete','Mundo próprio completo ausente')
    assert(not R.Busy,'Regeneração já em andamento')
    assert(w:GetAttribute('Seed')==Config.Seed,'Mudança de seed exige um Place novo: Terrain atual será preservado')
    assert(w:GetAttribute('ConfigSignature')==Terrain.signature(Config),'Geografia mudou; use um Place novo para preservar o Terrain existente')
    return w
end
local function stage()
    local m=G.model(game.ServerStorage,'MedievalStage_'..game:GetService('HttpService'):GenerateGUID(false))
    for _,name in {'Cities','Forests','NPCs','EnemySpawns','TreasureChests','InteractiveObjects','CinematicMarkers','Decorations'} do local f=Instance.new('Folder');f.Name=name;f.Parent=m end
    return m
end
local function archive()
    local folder=game.ServerStorage:FindFirstChild('MedievalBackups')
    if not folder then folder=Instance.new('Folder');folder.Name='MedievalBackups';folder.Parent=game.ServerStorage end
    local a=G.model(folder,'Backup_'..game:GetService('HttpService'):GenerateGUID(false))
    a:SetAttribute('CreatedAt',os.time());return a
end
local function run(build,commit)
    local w=root();R.Busy=true;local s=stage();local backup
    local ok,result=xpcall(function()
        build(s);backup=archive();commit(w,s,backup)
        s:Destroy();print('Regeneração concluída. Objetos anteriores preservados em '..backup.Name);return backup.Name
    end,debug.traceback)
    R.Busy=false
    if not ok then
        -- O estágio/backup é mantido se o commit falhar; nunca descarta objetos movidos.
        if not backup then s:Destroy() end
        error(result,0)
    end
    return result
end
local function moveChildren(from,to)
    for _,child in from:GetChildren() do child.Parent=to end
end
function R.city(id)
    assert(type(id)=='string' and Catalog.CityBuildings[id],'Cidade inválida')
    local plan=Plan.build(Config,Terrain,Catalog);local subset={Cities={}}
    for _,c in plan.Cities do if c.Id==id then table.insert(subset.Cities,c) end end
    return run(function(s) Content.cities(s,Config,subset,function()end) end,function(w,s,a)
        local old=w.Cities:FindFirstChild(id)
        assert(old and old:GetAttribute('GeneratedBy')==Config.ProjectId,'Cidade não reconhecida')
        old.Parent=a
        for _,npc in w.NPCs:GetChildren() do if npc:GetAttribute('City')==id then npc.Parent=a end end
        for _,name in {'InteractiveObjects','CinematicMarkers'} do
            for _,p in w[name]:GetChildren() do if string.sub(p.Name,1,#id+1)==id..'_' then p.Parent=a end end
        end
        for _,name in {'Cities','NPCs','InteractiveObjects','CinematicMarkers'} do moveChildren(s[name],w[name]) end
    end)
end
function R.forest(id)
    assert(id=='Sylvarin' or id=='Nocthar','Floresta inválida')
    local plan=Plan.build(Config,Terrain,Catalog);local subset={Trees={},Landmarks={},EnemySpawns={},Chests={}}
    for _,t in plan.Trees do if t.Forest==id then table.insert(subset.Trees,t) end end
    for _,key in {'Landmarks','EnemySpawns','Chests'} do
        for _,item in plan[key] do if string.sub(item.Id,1,#id)==id then table.insert(subset[key],item) end end
    end
    local c=table.clone(Config);c.Forests={}
    for _,f in Config.Forests do if f.Id==id then table.insert(c.Forests,f) end end
    return run(function(s) Content.forests(s,c,subset,function()end) end,function(w,s,a)
        local old=w.Forests:FindFirstChild(id);assert(old and old:GetAttribute('GeneratedBy')==Config.ProjectId,'Floresta não reconhecida');old.Parent=a
        for _,npc in w.NPCs:GetChildren() do if npc:GetAttribute('City')==id then npc.Parent=a end end
        for _,name in {'EnemySpawns','TreasureChests','CinematicMarkers'} do
            for _,item in w[name]:GetChildren() do if string.sub(item.Name,1,#id)==id then item.Parent=a end end
        end
        for _,name in {'Forests','NPCs','EnemySpawns','TreasureChests','CinematicMarkers'} do moveChildren(s[name],w[name]) end
    end)
end
function R.decorations()
    return run(function(s) Decor.generate(s.Decorations,Config,Plan.build(Config,Terrain,Catalog),Terrain) end,function(w,s,a)
        w.Decorations.Parent=a;s.Decorations.Parent=w
    end)
end
function R.markers()
    return run(function(s)
        local f=Instance.new('Folder');f.Name='NPCSpawns';f.Parent=s
        for _,npc in workspace.GeneratedWorld.NPCs:GetChildren() do
            if npc.PrimaryPart and npc:GetAttribute('NpcId') then
                G.marker(f,npc:GetAttribute('NpcId'),npc.PrimaryPart.Position,{Role=npc:GetAttribute('Role'),City=npc:GetAttribute('City')})
            end
        end
    end,function(w,s,a) w.NPCSpawns.Parent=a;s.NPCSpawns.Parent=w end)
end
return R
