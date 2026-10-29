local Validation={}
function Validation.validate(ws,c)
    local checks={}
    local function check(name,passed)
        local status=if passed then 'PASSOU' else 'FALHOU'
        table.insert(checks,{Name=name,Status=status});print('['..status..'] '..name)
    end
    local root=ws:FindFirstChild('GeneratedWorld')
    check('Pasta e identidade',root~=nil and root:GetAttribute('ProjectId')==c.ProjectId)
    if not root then return checks end
    local marker=root:FindFirstChild('TerrainMarkers');check('Reservas de regiões',marker~=nil and #marker:GetChildren()==#c.Cities+#c.Forests+1)
    local spawns=root:FindFirstChild('Spawns');local spawn=spawns and spawns:FindFirstChild('ValoriaSpawn')
    check('Spawn inicial',spawn~=nil and spawn:IsA('SpawnLocation') and spawn.Anchored and spawn.Enabled)
    local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={ws.Terrain}
    for _,city in c.Cities do
        local hit=ws:Raycast(Vector3.new(city.X,c.MaxY,city.Z),Vector3.new(0,c.MinY-c.MaxY,0),params)
        check('Solo em '..city.Id,hit~=nil and math.abs(hit.Position.Y-city.Height)<=4)
        local model=root.Cities:FindFirstChild(city.Id)
        local buildings=0
        if model then
            for _,m in model:GetChildren() do if m:GetAttribute('Template') then buildings+=1 end end
        end
        check('Edifícios em '..city.Id,buildings>=13)
    end
    check('Cidades configuradas',#root.Cities:GetChildren()==#c.Cities)
    check('Florestas configuradas',#root.Forests:GetChildren()==#c.Forests)
    check('Estradas',#root.Roads:GetChildren()==#c.Roads)
    check('Pontes sobre o rio',#root.Bridges:GetChildren()>0)
    local interactive=0
    for _,m in root.NPCs:GetChildren() do
        if m:FindFirstChildOfClass('Humanoid') and m:FindFirstChild('HumanoidRootPart') and m.HumanoidRootPart:FindFirstChildOfClass('ProximityPrompt') then interactive+=1 end
    end
    check('NPCs com rig e interação',interactive>=40)
    check('Spawns de inimigos',#root.EnemySpawns:GetChildren()>=12)
    check('Baús configurados',#root.TreasureChests:GetChildren()==#c.Forests*5)
    check('Guardião da dungeon',root.NPCs:FindFirstChild('DungeonGuardian')~=nil)
    check('Marcadores cinematográficos',#root.CinematicMarkers:GetChildren()>=7)
    table.insert(checks,{Name='Gameplay real, DataStore e teleporte',Status='NÃO TESTADO',Reason='Execute matriz de testes no Studio e cliente Roblox.'})
    return checks
end
return Validation
