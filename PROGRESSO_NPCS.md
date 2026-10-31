# Etapa 2 — NPCs (31/10/2026)

Branch: `codex/eldravyn-npcs-20261030`. Escopo: somente NPCs e componentes mínimos de seus serviços. Pedido integral em `docs/npc-stage2/REQUEST.pt-BR.md`.

## Etapas registradas

1. Inspeção concluída: arquivo disponível `delivery-map/monumental/Eldravyn-Monumental.rbxlx` (71.115.751 bytes), 92.702 BaseParts e 40 Sources. A cópia local `Eldravyn-Monumental(1).rbxlx` de ~383 MB NÃO foi anexada. A base disponível não possui Humanoids/ProximityPrompts nem Terrain materializado. Todos os interiores foram tratados como opcionais; posicionamento exterior documentado em `LOCATIONS.json`.
2. Serviços compartilhados escritos: extensão do perfil existente `MedievalRPG_v1`, sessão exclusiva, operações atômicas, proteção contra chamadas simultâneas, confirmação de custos, menus condicionais e recibos oficiais. Nenhum sorteio racial ou runtime geral de combate é iniciado na etapa NPC.
3. 66 personagens R15 com 25 papéis de configuração: as 20 categorias solicitadas (tickets unidos ao administrador), serviços centrais em Valoria, guias/lojas/estalagens nas outras cidades, 35 ambientes e dois administradores de dungeon. Lojas, banco, missões, guilda, classes, estudo arcano, ferreiro, cura e hospedagem implementados.
4. Posições derivadas do XML: 66 âncoras exteriores confrontadas com 34.798 peças colidíveis. Na instalação e em Play são consultados piso e obstáculos reais; pontos incompatíveis abortam instalação ou desativam interação. Nenhuma operação de Terrain existe no instalador.
5. Testes finais: 19 cenários NPC + quatro cenários de instalação/inicialização passaram no host simulado. Suíte antiga e builds dos dois Places também passaram. Compilação de 105 Luau, análise estática, nove specs puros, 46 fluxos MOCK anteriores, sete MAPA, dois builds legados e pacote NPC. Resultados e checklist em `docs/npc-stage2/TESTS.md`.
6. Entrega aditiva criada em `delivery-npcs/stage-02/`: `.rbxlx` com NPCs materializados e instalador `.rbxmx` passivo para aplicar à cópia salva do usuário. Verificação de GeneratedWorld idêntico, 40 Sources originais preservados e zero Terrain escrito. Rebuild final e hashes em `delivery-npcs/stage-02/MANIFEST.json`. Round-trip de 66 R15/990 motores pelo Rojo aprovado; nenhuma validação de Studio implícita. A próxima etapa é o checklist manual; não ampliar escopo para combate.

7. Entrega enviada ao GitHub. Downloads HTTPS do commit `fb9d206d4c977d4039858f6dbee64891fca8f1aa` conferidos: HTTP 200, tamanhos e SHA-256 idênticos aos arquivos locais. Evidência em `docs/npc-stage2/evidence/github-downloads.json`. O `.rbxlx` tem 74.126.115 bytes e o instalador 120.087 bytes.

## Limitações reais

Roblox Studio, Windows/Defender, DataStore/Marketplace reais, físicas R15, telas móveis e FPS não estão disponíveis neste ambiente. Tests mock/compilação/XML não substituem testes de Studio. Nenhuma promessa de ausência de alerta antivírus. Dungeon sem interior integrado não permite entrada nem consumo de ticket. Produtos reais permanecem ID 0. Prévia Studio padrão é temporária, sem persistência.
