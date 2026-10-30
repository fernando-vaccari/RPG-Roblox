-- CLI-only documentation export; game configuration remains the source of truth.
local catalog=require('../src/shared/Config/ContentConfig')
local abilities=require('../src/shared/Config/AbilityConfig')
local identity=require('../src/shared/Config/IdentityConfig')
local world=require('../src/shared/Config/WorldConfig')
local dungeon=require('../src/shared/Config/DungeonConfig')
local function keys(map)local out={};for key in map do table.insert(out,key)end;table.sort(out);return out end
print('# Catálogos atuais\n\nGerados das configurações do projeto. Implementação não equivale a homologação Roblox.\n')
print('## Eldravyn: Rise of Shadows — mundo\n\nOs totais abaixo contam os edifícios originais do catálogo. A revisão monumental acrescenta residências planejadas; consulte [o relatório do mapa](MONUMENTAL_MAP.md) para os totais materializados.\n\nRegião | Tipo | X | Z | Edifícios originais\n--- | --- | --- | --- | ---')
for _,r in world.Cities do print(r.Name..' | Cidade | '..r.X..' | '..r.Z..' | '..#catalog.CityBuildings[r.Id]) end
for _,r in world.Forests do print(r.Name..' | Floresta | '..r.X..' | '..r.Z..' | —') end
print('\n## Expedições\n\nDungeon | Andar | Ambiente | Encontro\n--- | --- | --- | ---')
local dungeonRules=require('../src/shared/Core/DungeonRules')
for _,id in dungeon.Order do for floor=1,dungeon.Dungeons[id].Floors do local f=dungeonRules.floor(dungeon,id,floor);print(dungeon.Dungeons[id].Name..' | '..floor..' — '..f.Name..' | '..f.Layout..' | '..table.concat(f.Enemies,', ')) end end
print('\n## Ranks da guilda\n\nRank | XP acumulada | Missões concluídas\n--- | --- | ---')
for _,rank in catalog.Ranks do local r=catalog.RankRequirements[rank];print(rank..' | '..r.XP..' | '..r.Quests) end
print('## Raças\n\nID | Nome | Probabilidade | Evolução | Habilidade\n--- | --- | --- | --- | ---')
for _,id in identity.RaceOrder do
 local r=identity.Races[id]
 print(id..' | '..r.Name..' | '..r.Weight..'% | '..r.Evolution..' | '..abilities.RacialSkills[id].Name)
end
print('\n## Árvore de classes\n\nPrincipal | Evolução | Nível | Descoberta secreta\n--- | --- | --- | ---')
for _,id in keys(identity.Advanced) do local c=identity.Advanced[id];print(c.Base..' | '..id..' | '..c.Level..' | '..(c.Secret or 'não'))end
print('\nArqueiro e suas quatro habilidades são preservados. As 24 habilidades iniciais continuam, acrescidas de 24 técnicas avançadas e cinco ações raciais.\n')
print('## Habilidades\n\nID | Nome | Classe | Nível | Mana | Stamina | Cooldown | Estilo | Entrega\n--- | --- | --- | --- | --- | --- | --- | --- | ---')
for _,id in keys(abilities.Skills) do local s=abilities.Skills[id];print(id..' | '..s.Name..' | '..s.Class..' | '..s.Level..' | '..s.Mana..' | '..s.Stamina..' | '..s.Cooldown..' s | '..(s.Style or s.Effect)..' | '..(s.ProjectileSpeed and 'Projétil '..s.ProjectileSpeed..' studs/s' or s.Effect))end
print('\n## Missões\n\nID | Nome | Categoria | Evento | Quantidade | Pré-requisitos\n--- | --- | --- | --- | --- | ---')
for _,id in keys(catalog.Quests) do local q=catalog.Quests[id];print(id..' | '..q.Name..' | '..q.Category..' | '..q.Target..' | '..q.Required..' | '..table.concat(q.Prerequisites or {},', '))end
print('\n## Desafios raciais\n\nRaça | Eventos obrigatórios\n--- | ---')
for _,id in identity.RaceOrder do local steps={};for _,s in identity.Races[id].Steps do table.insert(steps,s.Event..' ×'..s.Count)end;print(id..' | '..table.concat(steps,'; '))end
print('\n## Desafios de classes\n\nClasse | Eventos obrigatórios\n--- | ---')
for _,id in keys(identity.Advanced) do local steps={};for _,s in identity.Advanced[id].Steps do table.insert(steps,s.Event..' ×'..s.Count)end;print(id..' | '..table.concat(steps,'; '))end
print('\n## NPCs — papéis\n')
for _,role in keys(catalog.Dialogue) do local d=catalog.Dialogue[role];print('- '..role..': '..d.Name..'. '..d.Text)end
print('\n## Produtos planejados — sem IDs reais\n\nProduto | Valor planejado | ID configurado\n--- | --- | ---')
for _,id in keys(identity.Products) do local p=identity.Products[id];print(id..' | '..p.Robux..' Robux | '..p.Id)end
print('\nFusões: catálogo de combinações/resultados vazio, sem consumos. Três gratuitas por semana UTC; créditos básicos/premium persistentes; aquisição com Gold planejada a '..identity.Fusion.GoldPrice..', bloqueada até implementação do catálogo/resolvedor.')
