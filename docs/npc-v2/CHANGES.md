# Alterações e limites da migração

Base: commit `0f21f59`, branch anterior `codex/eldravyn-npcs-20261030`. Inspeção anterior às alterações: [ANALYSIS.md](ANALYSIS.md), [INSPECTION.json](INSPECTION.json). Pedido: [REQUEST.pt-BR.md](REQUEST.pt-BR.md).

## Código novo

| Arquivo em `src/npc-v2/` | Responsabilidade |
| --- | --- |
| `shared/NPCAppearanceConfig.luau` | Paletas e 25 profissões; variações determinísticas por ID |
| `shared/NPCVisualConfig.luau` | Orçamentos, atenção, comportamento e clips opcionais |
| `shared/NPCMotion.luau` | Vocabulário de poses procedurais |
| `shared/NPCVisualPolicy.luau` | Ângulos, distância, seleção limitada e formato de IDs |
| `install/NPCRigAdapter.luau` | Inspeção das peças, 15 juntas e dependências R15 |
| `install/NPCVisualFactory.luau` | Aparência nativa construída fora da cena antes do commit |
| `install/NPCVisualUpgrade.luau` | Preflight, backup, aplicação idempotente e rollback |
| `server/NPCPositionAdapter.luau` | Mantém o CFrame instalado; apenas consulta piso e registra problemas |
| `server/NPCBehaviorController.luau` | Um scheduler, sessões existentes, patrulhas e cancelamento |
| `client/NPCAttentionController.luau` | Percepção contextual, interlocutor, cumprimento e suavização |
| `client/NPCAnimationController.luau` | Poses/Animator, cache, transições e exclusão de controladores conflitantes |
| `client/NPCPerformanceManager.luau` | Frequências, distâncias, efeitos, streaming e limpeza |
| `baseline/*.luau` | Cópias inativas e exatas dos três Sources V1 usados no preflight |

## Três adaptações localizadas em código existente

| Arquivo | Mudança |
| --- | --- |
| `src/npc/server/NPCService.luau` | Quando V2 está instalado, consulta o adaptador e preserva o CFrame atual em vez de reposicionar pelo mapa. Demais serviços/prompts permanecem. |
| `src/npc/server/AmbientService.luau` | Delega ao controlador V2 antes de iniciar o loop V1; impede dois schedulers de patrulha. |
| `src/npc/client/NPCInteractionClient.client.luau` | Depois de manter a UI e o marcador existentes, transfere os motores ao manager V2 e deixa de executar o idle antigo. |

Essas adaptações só entram em uso com `Workspace.EldravynNPCVisualVersion = 2`. O preflight aceita somente os Sources baseline conhecidos ou os adaptados desta revisão. O atualizador guarda os objetos originais antes da troca, preserva o estado Disabled e não cria segundo bootstrap servidor. O único LocalScript no pacote de importação chega desabilitado.

## Fora das alterações

Os **50 arquivos protegidos** de regras, catálogos, serviços, persistência, diálogo, UI, Installer, R15Factory e Placement são conferidos por SHA-256. O Place Stage 2 inteiro também continua com o hash `c2e74768a2df09e1e710c4cffdaae3036c81a52ff905f2a91f16fb2c37d99ad6`. O subtree de GeneratedWorld foi comparado separadamente. O hash deste subtree usa a serialização `ElementTree.tostring(..., encoding='us-ascii')`; não deve ser confundido com SHA-256 do arquivo completo ou outra codificação XML.

Não há mudanças nos geradores de mundo, PlacementConfig, NPCConfig, menus, preços, missões, classes, habilidades, equipamentos, DataStore, remotes ou validações de compras. Não há nova rolagem racial, recompensas ou novas funções de combate. Os dois Places existentes e as entregas anteriores permanecem intactos; builds de teste ficam em `build/`.

## Ferramentas e evidências

- `npc-visual-v2.project.json` e `scripts/build_npc_v2.py`: pacote isolado, hashes, Sources correspondentes e leitura/regravação XML com Rojo.
- `scripts/test_npc_v2.py`, `tests/NPCV2Mock.luau` e `tests/npc-v2-*.luau`: migração, rollback, poses e controles simulados. `scripts/npc_host.py` ganhou montagem V2 opcional e extensão de mocks.
- `scripts/export_npc_v2_preview.luau` e `scripts/render_npc_v2_preview.py`: prévias de geometria/pose real, fora do Studio.
- `scripts/check.py`: inclui o V2 na suíte. `scripts/verify_project.py`: exclui também `npc-v2` dos módulos esperados nos Places clássicos, pois o pacote V2 é separado e opt-in.
- `delivery-npcs/visual-v2/`: nova entrega; `PACKAGE_SOURCES.json`: classes e hashes dos Sources empacotados; `docs/npc-v2/evidence/`: resultados realmente executados.
- README, NEXT_STEPS e PROGRESSO_NPC_V2: orientação atualizada, sem apagar o histórico.
