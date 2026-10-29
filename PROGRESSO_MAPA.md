# Continente — progresso da Tarefa 01

**28/10/2026 — cópia passiva separada:** gerada `delivery-map/passive-scene/Eldravyn-Continent-SceneryOnly.rbxlx` a pedido do usuário. Apenas Workspace e Lighting, 20.001 peças preservadas; zero código de projeto/blobs de metadados. Cópia exclusivamente visual, sem Terrain/PrepareStudio/gameplay. Comparação estrutural independente passou; fonte e original preservados. Antivírus não executado: base oficial ClamAV bloqueada pela rede (CONNECT 403). Não há veredicto do Defender ou promessa de ausência de alerta. Consulte docs/PASSIVE_SCENE_REVIEW.md.

**28/10/2026 — uso da entrega não recomendado:** o usuário confirmou `Trojan:Script/Ulthar.A!ml` também no ZIP do continente, que contém apenas um `.rbxlx`. O registro `webfile` não aponta membro interno. A investigação estática não determinou a causa nem confirmou falso positivo. Arquivos/hashes preservados e links de uso retirados do README da entrega. Detalhes em [docs/MAP_DEFENDER_ALERT.md](docs/MAP_DEFENDER_ALERT.md). Não houve mudança de geometria/código ou novo empacotamento nesta investigação.

Atualização: 27/10/2026. Branch: `codex/eldravyn-map-20261027`. Base preservada: `17b4f8e` (0.6.1 + investigação Defender). Último commit de código desta etapa: `3f7e4fa`; o commit de documentação/artefato da entrega aparece a seguir no log Git.

## Estado

Reconstrução do cenário integrada, testada na nuvem e materializada no arquivo `delivery-map/task-01/Eldravyn-Continent.rbxlx`. Esta tarefa substituiu o escopo amplo anterior: **somente continente**, sem novos sistemas de gameplay. Mapa antigo rejeitado substituído nos geradores/novo artefato; versões anteriores e dados do RPG preservados. Rojo/Luau são o fluxo de origem. Não existe Studio neste Linux.

O cenário é materializado offline como instâncias nativas XML, e não entregue apenas como um gerador. **Terrain nativo, inspeção visual e medições reais continuam pendentes. Portanto o mapa final ainda não está concluído segundo os critérios do pedido.** O comando PrepareStudio completa o Terrain numa cópia nova e deve ser seguido de salvamento.

## Regiões e arquitetura implementadas em código

- Valoria: capital com praça, marco do relógio, arquitetura de madeira/reboco, castelo e guilda externa conectada.
- Eldoria: cidade florestal com madeira, jardins, árvores monumentais e marco orgânico.
- Durakh: cidade das montanhas, pedra, forjas e marco defensivo.
- Asterion: cidade arcana, academia/torres e cristais.
- Arkheim: cidade gótica, silhuetas de torres e fortaleza sombria.
- Sylvarin/Bosque Esmeralda, Nocthar/Ancestrais e Véspera/Sombria: quatro agrupamentos por região, clareiras, cinco variantes de árvore, raízes, rochas e cavernas.
- Dez rotas curvas contínuas, pontes, três cadeias montanhosas, vales, três lagos, cascata, vila, acampamento, fortaleza abandonada, santuário e mirante.
- Dois exteriores monumentais de dungeon. Slots de integração identificados; sem interiores novos, guardiões, teleporte ou recompensas.
- Arquitetura modular com fachadas/janelas, telhados/gables/dormers, materiais por cidade, oito studs de abertura de portas e interiores seletivos nos edifícios relevantes.

## Escala e orçamento

Continente: **4.000 × 4.000 studs**, mantendo deslocamentos contínuos e IDs anteriores. O tamanho foi mantido para concentrar esforço em composição/densidade e compatibilidade, não por alegação de benchmark. Grades de Terrain de 4 studs; 1.024 chunks e cerca de 56 milhões de voxels. Build LOW prevê 160 árvores por floresta; não reduz o continente nem remove regiões.

Streaming: mínimo 64/alvo 256 studs. Perfis visuais limitam luzes, sombras, partículas e detalhes não colidíveis; Automático usa tempo de frame observado. Silhuetas, edifícios, colisões e regiões permanecem. Metas 30 FPS mobile/60 FPS PC são objetivos não medidos. Notebook 5700U/12 GB não foi testado.

## Verificação e continuidade

- `python3 scripts/check.py` passou: **79 arquivos Luau compilados**, análise das regras/configurações, todas as suítes CLI, **42 fluxos simulados legados e oito novos fluxos de arquitetura/mapa**. Dois builds legados passaram no verificador de dependências/serviços (55 módulos e dois bootstraps por Place).
- Nove testes puros de terreno; planejamento de 130 lotes sem sobreposição, portas/ruas com folga, topologia das dez rotas, inclinação máxima testada e densidade dos três perfis; quatro casos de gramática arquitetônica; histerese do modo Automático. A classificação de casos integrados não equivale a testar no engine.
- Materialização final: **21.323 instâncias de cenário, incluindo 20.001 BaseParts**, 130 lotes e 480 árvores LOW. Há 100 módulos de tabuleiro de ponte, não 100 pontes independentes. O arquivo tem 38 ModuleScripts e somente os dois bootstraps de apresentação do mapa.
- `python3 scripts/bake_continent.py --self-test`: atributos nativos/UTF-8/vetores, aliases de propriedades e referências preservados num round-trip pelo Rojo. `python3 scripts/bake_continent.py` materializou e verificou a hierarquia final.
- Verificação independente do arquivo final: 21.323 nós, 20.001 transformações e tamanhos iguais aos dados gerados, referências válidas; nenhum Humanoid/ProximityPrompt; nenhum bootstrap de gameplay.
- Corrigidos: relevo atravessando cavernas/antepátios dos portais; trechos de estrada suspensos; descontinuidade na margem de lago; retorno duplo distância/t confundido com distância; caminhos de portas atravessando outras quadras. As verificações são geométricas/puras e simuladas, sem afirmar colisões reais homologadas.
- `python3 scripts/package_map.py`: ZIP com somente um `.rbxlx`, CRC e SHA-256 conferidos. Manifesto registra `native_terrain_baked=false`, `studio_executed=false`, `visual_quality_validated=false`. Hashes em delivery-map/task-01/SHA256SUMS.txt.
- O Place contém a geometria real serializada; **os 56 milhões de voxels ainda não foram escritos em Terrain real**. Metas de FPS, caminhada física, renderização, streaming e aparência não foram verificadas no Studio.

Próxima tarefa exata: no Roblox Studio, seguir COMO_ABRIR_MAPA.md para materializar o Terrain, salvar/reabrir e executar o checklist abaixo, começando por portas/ruas, cavernas e antepátios. Registrar Output e capturas com coordenadas; corrigir apenas problemas reproduzidos, sem recomeçar o cenário. A branch de entrega é codex/eldravyn-map-20261027; conferir o commit remoto contra o log local.

## Checklist real pendente

1. Preparar Terrain, salvar/reabrir e confirmar spawn; segunda preparação não deve recriar geometria.
2. Percorrer as dez rotas e pontes a pé; verificar declives, muralhas, ruas e entradas de edifícios importantes.
3. Fotografar praça/skyline de cada cidade em Dia e Noite. Avaliar proporção, variedade, telhados, vazios, cores, sombras e leitura das fachadas.
4. Inspecionar as três florestas, clareiras e cavernas; procurar troncos/rochas flutuantes, obstáculos e repetição visual excessiva.
5. Inspecionar os dois portais externos, lagos/cascata, vilarejo, acampamento, fortaleza, mirante e santuário. Não deve haver NPC, inimigo, prompt ou recompensa funcional.
6. Testar os sete presets e os quatro perfis em celular emulado/aparelho e PC. Medir FPS, memória, tempo de preparação e streaming; registrar versão/dispositivo/Output/capturas.
7. Registrar ajustes artísticos por coordenada e captura. Sem esta revisão, o mapa não é final nem visualmente homologado.

O alerta Defender anterior permanece indeterminado. Nenhum antivírus foi desativado; nenhum arquivo foi declarado seguro. Compras/publicação do jogo não fazem parte desta tarefa.

## Arquivos desta etapa

Configuração WorldConfig; TerrainMath/WorldPlan; ArchitecturalPlan/BuildingGenerator/CityLandmarkGenerator; ContentGenerator/ScenicGenerator/LandmarkGenerator/DecorationGenerator; MapSceneGenerator e extensão Map de WorldGenerator; MapEnvironment/MapVisualConfig/MapVisualRules; src/map-preview; map.project.json; scripts de materialização/empacotamento e testes de mapa/arquitetura/terreno/planejamento. Nenhum arquivo de src/server ou src/client do RPG foi alterado. Detalhes técnicos por área estão em docs/MAP_LAYOUT_REBUILD.md, ARCHITECTURE_MAP.md, LANDSCAPE_MAP.md, MAP_VISUALS.md e SCENE_BAKE_LIMITS.md.
