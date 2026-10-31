# Etapa 2 — NPCs de Eldravyn

Implementação exclusiva dos NPCs e seus serviços. Combate, conjuração, inventário geral, árvores de habilidades, fusões e dungeons jogáveis não são iniciados. Os módulos anteriores continuam no repositório.

A cópia `Eldravyn-Monumental(1).rbxlx` de aproximadamente 383 MB **não foi anexada**. Foi inspecionado o arquivo do repositório `delivery-map/monumental/Eldravyn-Monumental.rbxlx`, de 71.115.751 bytes: cinco cidades, três florestas, duas entradas de dungeon, 1.054 lotes, 92.702 BaseParts, 40 Sources, nenhum Humanoid ou ProximityPrompt. Essa base ainda tem `TerrainPending=true`; não contém o Terrain materializado no Studio. [Inspeção](MAP_INSPECTION.json) e [posições dos 66 NPCs](LOCATIONS.md).

## Usar sua cópia já preparada no Windows 11

1. Abra sua cópia no Roblox Studio e salve uma **nova cópia**, mantendo o original.
2. Pare Play. Baixe [Eldravyn-NPCs-Stage2.rbxmx](../../delivery-npcs/stage-02/Eldravyn-NPCs-Stage2.rbxmx).
3. No Explorer, clique com o botão direito em `ServerStorage` → **Insert from File… / Inserir do arquivo…** e selecione o `.rbxmx`. Se o Studio o inserir em Workspace, mova o Model `EldravynNPCPackage` para ServerStorage. Os scripts do pacote estão desativados.
4. Na **Command Bar**, execute:

```lua
require(game.ServerStorage.EldravynNPCPackage.Installer).Install()
```

5. Confira o Output e salve a nova cópia. Se a instalação abortar por âncora/piso incompatível, o mapa fica preservado. Ajuste **somente** as âncoras/offsets em `EldravynNPCPackage.Shared.PlacementConfig` às construções reais da sua cópia; não regenere o continente para corrigir um ponto de NPC.
6. Pressione Play, aproxime-se dos NPCs e use **E** ou toque no ProximityPrompt. O tutorial Theo fica ao lado de `ValoriaSpawn`. Maelis e Iria atendem no exterior da guilda.

O instalador não escreve Terrain, não move edifícios e não assume interiores acessíveis. Ele verifica todas as posições antes de ativar scripts. Uma segunda execução reconhece a instalação existente e não duplica personagens. NPCs equivalentes identificados por `NPCRole`/`Role` e `City`/`CityId` são preservados e listados como ignorados; seus diálogos precisam de adaptação específica. Personagens sem identificação interrompem a instalação para evitar duplicações. Destinos ocupados e runtime antigo `MedievalServer` ativo também interrompem a instalação, evitando dois escritores de perfil. Esses bloqueios não removem conteúdo existente.

## Abrir o Place aditivo disponibilizado

[Eldravyn-Monumental-NPCs.rbxlx](../../delivery-npcs/stage-02/Eldravyn-Monumental-NPCs.rbxlx) contém **66 personagens materializados**, os módulos instalados e os geradores originais. Sua base é a versão do repositório de 71 MB, não a cópia local de 383 MB. `GeneratedWorld` e os 40 Sources antigos foram preservados. Nenhum novo continente foi gerado nesta etapa.

Como essa base já tinha Terrain pendente, somente **nesse arquivo entregue, ainda não preparado**, conclua a preparação antiga uma vez no editor:

```lua
require(game.ServerStorage.MedievalWorldgen.WorldGenerator).PrepareStudio()
```

Depois salve, reabra e use Play. O runtime NPC não chama esse gerador, nem regenera o mapa ao entrar um jogador. **Não execute esse comando na sua cópia já preparada para instalar NPCs:** nela use apenas o instalador acima. As proteções de Terrain anteriores permanecem intactas.

## Serviços implementados

| Categoria solicitada | Implementação desta etapa |
|---|---|
| Mestre da Guilda | Registro F, consulta, histórico e promoção manual F→E→D→C→B→A→S, com XP/contratos configuráveis |
| Recepcionista | Filtro por rank, aceitar, abandonar, progresso, entrega atômica, contratos de conversa, cidades, florestas e descoberta secreta |
| Administrador / vendedor de tickets | Dois administradores, 10 e 20 andares; **30 tickets e 30 contratos específicos**; compra por moedas ou recompensa de missão; consulta de quantidade/requisitos |
| Ferreiro | Propriedade mínima de armas/armadura, nível +0 a +5, custo crescente em moedas/minério, confirmação, persistência; sem dano/defesa |
| Armas / armaduras / geral / viajante | Catálogos, preço, raridade, requisitos, propriedade persistente e venda permitida; poções armazenadas sem efeitos; peça equipada/aprimorada não pode ser vendida |
| Mestre de Classes | Guerreiro, Espadachim e Mago; Arqueiro antigo preservado; seis evoluções por rank/contrato; crédito de troca via recibo oficial, produto de 100 Robux desativado |
| Mestre de Magia | Escolas e requisitos, registro de estudo Luz-guia após contrato/rank; Chama futura desativada; nenhuma conjuração |
| Mentor de Habilidades | Informações de progressão e requisitos futuros sem valores fictícios; nenhum desbloqueio/cobrança |
| Especialista em Raças | Consulta da raça/evolução já existente, características e evoluções possíveis; nenhum sorteio ou alteração |
| Especialista em Fusões | Explicação, requisitos/combinações aguardando definição, indisponibilidade explícita; nenhum recurso cobrado |
| Estalajadeiro | Hospedagem por 15 moedas, descanso e retorno validado junto à estalagem; sem fome/sobrevivência |
| Curandeiro | Cura por 10 moedas apenas com Humanoid vivo e ferido; verificação antes do débito, conciliação da operação pendente |
| Banqueiro | Saldo, depósitos e saques no mesmo perfil/transação, valores inteiros e limites |
| Guia | Serviços e regiões realmente encontrados; marcador temporário de 45 segundos |
| Tutorial | Movimento PC/celular, interação, moedas/ranks/missões, visita à guilda/recepção/guia, progresso salvo, pular/revisar |
| Ambientais | 35 guardas, moradores, viajantes, artesãos, funcionários, aventureiros e camponeses; linhas próprias; poses locais; pequenos passeios apenas se piso/caminho livres |

São 29 serviços nas cidades, 35 ambientais e dois administradores. As 20 categorias do pedido usam 25 papéis de configuração; vendedor de tickets e administrador compartilham o mesmo NPC. Personagens usam peças nativas, 15 juntas Motor6D R15 e roupas/acessórios decorativos próprios. Nenhum ID de asset pago/não verificado ou animação externa foi adicionado.

Serviços ficam distribuídos pelas fachadas dos edifícios reais. O banqueiro atende no mercado existente; não foi inventada uma agência bancária. Quando não há o template preferido, o catálogo de posições registra `FutureBuilding=true` e usa outro edifício identificado. NPCs não têm colisão e não ocupam o eixo das portas. As posições são novamente verificadas no Play; qualquer falha desativa a interação correspondente e aparece no Output.

## Persistência, testes com APIs e compras

O padrão de prévia Studio usa `Workspace.StudioSessionPreview=true`: progresso temporário e compras Robux indisponíveis. Isso permite testar os serviços sem habilitar APIs. O menu informa quando os dados são voláteis.

Para testar persistência real, publique **uma cópia privada de teste**, habilite **Game Settings → Security → Enable Studio Access to API Services**, coloque `Workspace.StudioSessionPreview=false` fora do Play e mantenha `MedievalRPG.Config.WorldConfig.EnableDataStore=true`. Entre, realize operações, pare e entre novamente. O DataStore `MedievalRPG_v1` pertence à Experience: uma Experience separada evita tocar os dados de produção. Falha ou lock de sessão impede compras/alterações, sem gravar defaults por cima de dados existentes.

A extensão `NPC` usa o mesmo perfil/economia, sem um segundo DataStore de moedas. Salva banco, contratos, tickets, melhorias, tutorial, retorno, estudos, histórico e créditos. Rank, classe e propriedade mínima reutilizam os campos antigos. `UpdateAsync` mantém a posse da sessão; resultado incerto congela operações até recarga. A confirmação do cliente contém apenas token descartável/índice; preço, recompensa, NPC, proximidade, rank e recursos são conferidos no servidor. Tokens são invalidados antes de operações que podem aguardar.

Para uma futura troca de classe paga, crie o Developer Product **na Experience correta**, configure o preço oficial de **100 Robux** e substitua apenas `ClassChangeProduct.Id=0` em `ReplicatedStorage.EldravynNPC.NPCConfig` pelo ID real. O preço é conferido via MarketplaceService antes de abrir a janela oficial. Somente `ProcessReceipt` concede crédito e registra o recibo na mesma transação. Clique, fechamento da janela e sinal do cliente nunca concedem crédito. **Nenhum produto foi criado ou ativado nesta entrega.**

## Limites e integrações futuras

- **Dungeon:** `PlaceId=0`, `EntryEnabled=false`, `InteriorReady=false` nas duas definições. Não há teleporte/consumo na entrega. `NPCActionService.DungeonAdapter` deve futuramente fornecer `ValidateDestination(definition,floor)` e `Enter(player,definition,floor,admissionId)` com autorização entre servidores. `Rules.admit` registra consumo pendente; falha antes do envio permite devolução única; `Rules.confirmArrival` encerra a admissão depois de validação no destino. O adaptador real deve autenticar o jogador/servidor, conferir o perfil e reconciliar desconexões/TeleportInitFailed; **não basta ligar os flags nem confiar em TeleportData do cliente**. Essa integração não está implementada/ativada nesta etapa.
- **Missão de combate:** `QuestService.CombatEnabled=false`; o contrato existe, mas não progride. Futuro código confiável do servidor pode chamar `combatEvent(player,"Combat:Bandit",eventId)`; eventos repetidos são rejeitados. Não há remote de progresso de combate.
- **Equipamentos/consumíveis:** registros de propriedade e melhoria; não equipam Tools, executam ataques, alteram defesa ou usam poções. Venda de item aprimorado fica bloqueada para não perder sua melhoria.
- **Identidade:** raça existente é preservada, jogador novo permanece sem sorteio nesta etapa. Classes são registros, não habilidades ativas. Fusões e árvores permanecem indisponíveis.
- **Compatibilidade com Places antigos:** DataService foi atualizado no repositório para preservar a extensão NPC, e os dois builds legados passam nos testes. Antes de conectar um Place publicado antigo ao mesmo perfil, atualize seu DataService/ContentConfig a partir desta revisão. Os artefatos antigos de entrega foram mantidos intactos, não atualizados silenciosamente.
- **Desempenho:** uma rotina de exploração a cada 2 s, animação local de até 12 personagens próximos, patrulha de até quatro ambientais a cada 10 s com deslocamento de 2,5 studs; NPCs distantes não recebem animação local contínua. FPS/RAM reais ainda precisam ser medidos no equipamento informado.

## Arquivos e reprodução

- `src/npc/shared/`: NPCConfig, DialogueConfig, ShopConfig, QuestConfig, DungeonTicketConfig, PlacementConfig, Registry e regras puras Rules.
- `src/npc/server/`: NPCService, NPCDataService, NPCActionService, DialogueService, QuestService, AmbientService e bootstrap. Guilda/loja/banco/classes/ferreiro reutilizam as operações puras de Rules e o mesmo despachante; não existem escritores de economia paralelos.
- `src/npc/client/`: interface única NPCDialogueClient e NPCInteractionClient (diálogo, confirmações de loja, marcador e poses).
- `src/npc/install/`: Installer, Placement e R15Factory; `npc-package.project.json` produz pacote passivo.
- Alterações antigas: `DataService` preserva extensão e evita sorteio no modo NPC; `PurchaseService` admite produto oficial extensível; `ContentConfig` reconhece a relíquia de propriedade. Mock/verificador/check foram ampliados.
- `scripts/npc_placements.py` inspeciona XML e verifica caixas; `scripts/build_npc_stage2.py` adiciona NPCs ao arquivo existente e compara estrutura/Sources/hashes. Não chama geração de continente.

Com as ferramentas já instaladas no repositório:

```text
python3 scripts/check.py
python3 scripts/test_npc_stage2.py
python3 scripts/build_npc_stage2.py
python3 scripts/verify_npc_stage2.py
```

O primeiro comando inclui o segundo. O terceiro grava somente `delivery-npcs/stage-02/` e os catálogos de posições; conserva a entrega monumental original. Não execute os empacotadores antigos para sobrescrever versões anteriores.

[Resultados reais dos testes e checklist Studio](TESTS.md). [Progresso e continuidade](../../PROGRESSO_NPCS.md). [Hashes e manifesto](../../delivery-npcs/stage-02/MANIFEST.json).

Não houve execução de Roblox Studio, Windows Defender ou serviços reais Roblox nesta máquina Linux. O alerta anterior do Defender continua com causa indeterminada; esta entrega é uma implementação de NPCs, não uma tentativa de escapar da detecção. Havendo bloqueio, mantenha o antivírus ativo e encaminhe amostra/hash à [Microsoft](https://www.microsoft.com/en-us/wdsi/filesubmission).
