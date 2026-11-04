# Verificações da atualização NPC V2

Execução em Linux na sessão iniciada em **31/10/2026, horário de Brasília**. **Roblox Studio não foi executado.** Os testes de controle usam um host simulado e não comprovam animação, colisão, rede, DataStore, antivírus ou FPS reais.

## Executado

| Verificação | Resultado e alcance |
| --- | --- |
| Compilação Luau | 126 arquivos compilados, incluindo fontes, baselines, testes e exportadores; análise Luau dos módulos puros. Os três arquivos dos últimos ajustes visuais foram recompilados e os testes V2 repetidos |
| Regressão anterior | 63 verificações puras em 9 arquivos de especificação; 46 cenários de integração simulada, 7 de mapa e 23 de NPCs/instalador V1 |
| Aparência V2 | Construção das 66 aparências com API/Enums conferidos pelo dump Roblox; 5.467 adornos, máximo 100 por NPC; peças sem colisão/toque/query; nenhum ParticleEmitter ou script anexado aos personagens |
| Migração V2 | 10 cenários: scripts personalizados, Animate ativo/IDs duplicados, dependência V1 ausente, falha injetada no meio da aplicação, 66 instâncias preservadas, reaplicação idempotente, dependência V2 ausente, serviços originais, rollback e reaplicação após rollback |
| Controle V2 | 12 cenários: poses por 30 s simulados, atenção/FOV, fallback, Humanoid/Animate, tracks/cache/prioridade/transição, asset com falha, piso, diálogo com dois jogadores, patrulha/obstáculos, retomada profissional, limite/limpeza, 120 atores e integração com bootstrap/prompts existentes |
| Pose/atenção | 15 estados com ângulos finitos e movimento distinto; limitação de cabeça/torso, retorno ao repouso e intervalo de cumprimento; atenção adicional não acumula em tracks que omitem essas juntas |
| Preservação | SHA-256 dos 50 arquivos protegidos e do Place Stage 2 inteiro idênticos à inspeção; GeneratedWorld idêntico; zero writes de voxel no host V2; objeto de construção sentinela mantido |
| XML V2 | 17 ModuleScripts + 1 LocalScript desabilitado, Sources correspondentes ao repositório; referências XML e leitura/regravação por Rojo verificadas; baselines idênticos aos Sources do Place original |
| XML anterior | Hashes preservados e leitura/regravação Rojo de 66 R15, 990 motores, prompts e referências |
| Builds anteriores | Continente e dungeon clássicos compilados em `build/`, 55 módulos cada, sem ciclos/dependências ausentes; entregas antigas não sobrescritas |
| Python/diff | Compilação sintática dos helpers modificados e `git diff --check` |
| Revisão visual | Duas pranchas com oito renders da geometria e poses efetivamente produzidas, Blender offline; revisão de cabelo, continuidade das roupas, acessórios e silhuetas |
| Download do GitHub | Pacote, manifesto e guia do commit `fa9bcccbec1fab5fcd68a441484a35407ca0766f` baixados por HTTP 200 e comparados byte a byte com os arquivos locais; verificação repetida na retomada de 04/11/2026 |

Os 120 atores são um teste de limites de seleção, cache e liberação de recursos no host Luau. **Não é um benchmark de FPS.** Tracks sintéticos só existem nos testes com Animator falso; nenhum ID de teste entra na entrega. O teste com dois interlocutores manipula jogadores/sessões simulados e testa também o prompt/DialogueService original; **não é um servidor multiplayer Roblox real**.

O log da suíte geral registra 5.449 adornos. Os últimos ajustes adicionaram a lâmina inacabada decorativa aos ferreiros/artesãos e alternância de organização para comerciantes: a recompilação e a execução V2 posteriores registram o total final de **5.467**, sem alterar o máximo de 100. O pacote e as prévias foram reconstruídos após esses ajustes.

Evidências: [suite geral](evidence/full-check.log), [V2 isolado](evidence/v2-tests.log), [recompilação final](evidence/final-compile.log), [pacote](evidence/package.log), [preservação XML](evidence/preservation.log), [download GitHub](evidence/github-downloads.json), [manifesto](../../delivery-npcs/visual-v2/MANIFEST.json) e [hashes dos Sources](PACKAGE_SOURCES.json).

## Problemas encontrados e corrigidos durante a implementação

- Atenção adicional de cabeça/torso poderia se acumular em AnimationTracks sem canais para essas juntas. Agora o offset anterior é removido antes do Animator avaliar o próximo frame e os dois offsets em cache são reaplicados inclusive entre atualizações limitadas de pose, evitando oscilação; teste cobre 300 atualizações e frames intermediários.
- Cancelamento de patrulha precisava considerar a ordem dos listeners do prompt. A sessão existente é prioritária; quando ainda não foi aberta, usa a validação de proximidade original para pausar somente a ação visual.
- A contagem de efeitos por frame poderia deixar atores de frames alternados ativos ao mesmo tempo. A seleção passa a ser estável entre scans, com no máximo três atores.
- Dependência V2 removida após instalação não podia parecer uma reaplicação válida. Preflight verifica as bibliotecas antes de retornar `Already`.
- Rollback precisava preservar atributos visuais preexistentes e recusar remoção de Sources V2 personalizados. Foram adicionados snapshots e validação anterior à reversão.
- A primeira revisão visual mostrou franja com faces retangulares e membros arredondados com continuidade ruim. Mechas foram orientadas para apresentar o perfil triangular, e roupas passaram a usar volumes contínuos presos ao rig original.
- A inspeção original do subtree XML usava `us-ascii`; comparar com `utf-8` produzia hashes diferentes do mesmo conteúdo. O verificador usa explicitamente a codificação registrada, além de comparar o hash do arquivo inteiro.
- O Blender disponível não tem denoiser OpenImageDenoise e usa outro nome para a entrada de emissão. O helper foi ajustado e os renders finais foram concluídos; isso não representa uma correção no engine Roblox.

## Reproduzir no ambiente de desenvolvimento

Ferramentas já configuradas em `.tools/bin`; não são necessárias para importar o `.rbxmx` no Studio.

```bash
python3 scripts/check.py
python3 scripts/build_npc_v2.py
python3 scripts/verify_npc_stage2.py
python3 scripts/render_npc_v2_preview.py
```

O último comando depende de Blender e Pillow. Artefatos intermediários ficam em `build/`; o único builder da entrega V2 é `build_npc_v2.py`. Não use o builder Stage 2 para refazer o mapa ou substituir o Place anterior.

## Validação manual pendente — Roblox Studio Windows 11

Execute em uma **cópia** do Place existente, seguindo [README.md](README.md). Registre versão do Studio, arquivo/hash, dispositivo, qualidade gráfica e Output. Marque os casos abaixo somente depois de executá-los.

| Caso | Procedimento e resultado a conferir |
| --- | --- |
| Preflight | Execute `Report()` em Edit. Confira 66 IDs na base conhecida e dependências presentes. Um erro interrompe a aplicação, sem reiniciar a instalação. |
| Upgrade | Execute `Apply()`. Compare antes/depois IDs, `NPCRole`, `City`, PrimaryPart.CFrame, Humanoid, Animator, 15 motores e prompt. GeneratedWorld e Terrain devem permanecer inalterados. |
| Reaplicação | Execute `Apply()` de novo. Deve retornar `Already`, sem novos NPCs, módulos repetidos ou mais de um bootstrap. |
| Salvar/reabrir | Salve o `.rbxlx` da cópia e reabra no Studio. Verifique visuais, referências dos backups e `Report()` antes de iniciar Play. |
| Aparência | Visite mestre de guilda, guarda, ferreiro, mago, comerciante e estalajadeiro; revise rostos, cabelos, capas, ferramentas, proporções, sombras e interseções em todos os estados. As pranchas offline não substituem esta inspeção. |
| Animação | Observe respiração/idle, cumprimento, conversa, forja/inspeção/organização, estudo/gesto arcano, documentos/atendimento e caminhada dos guardas. O rig deve continuar unido e sem saltos de escala. |
| Atenção | Aproxime-se pela frente, pelos lados e pelas costas; afaste-se além de 22 studs. Cabeça/torso devem ficar limitados e voltar ao repouso. Não deve cumprimentar repetidamente a cada frame. |
| Patrulha | Observe saída/retorno de 2,5 studs, pausas e ausência de atravessamento de paredes. Na cópia, coloque temporariamente um obstáculo no trajeto: deve cancelar. Remova o objeto de teste antes de salvar. Piso ausente/desnível deve gerar aviso e manter a origem. |
| Conversa | Interaja durante deslocamento/trabalho. O NPC deve parar, olhar para o interlocutor e retomar após fechar/expirar a sessão. Não deve caminhar enquanto conversa. |
| Duas pessoas | Use Start Server com dois clientes. Teste jogadores nos dois lados e ambos abrindo o mesmo NPC. O interlocutor escolhido deve permanecer estável, e fechar uma conversa não deve ignorar a outra. |
| Funções anteriores | Faça registro, consulta de missões/classes, compra/venda, depósito/saque, serviço do ferreiro, cura/estalagem e consulta de tickets. Confira valores iguais à base, confirmação pelo servidor, sem nova recompensa ou DataStore. Use os testes Stage 2 para limites detalhados. |
| Segurança existente | Tente interação distante e repetição de token/opção vencidos na Experience de teste. As validações anteriores continuam responsáveis por rejeitar. Não publique produtos nem ative compras para testar a aparência. |
| Streaming | Afaste-se das cidades e retorne; faça respawn. Não deve acumular controladores, referências a NPCs removidos ou tracks duplicados. |
| Mobile | Use Device Emulator em retrato/paisagem; confira menus anteriores, prompts touch e gestos. Depois teste em dispositivo físico; emulação não mede desempenho de celular. |
| Desempenho | Compare V1/V2 nas mesmas posições, câmera e qualidade no Ryzen 7 5700U com 12 GB e em celular. Registre FPS, memória e MicroProfiler por alguns minutos, incluindo cidade cheia e dois clientes. Ajuste os orçamentos com base nessas medições. |
| Track opcional | Somente com um asset real autorizado: configure um ID em `NPCVisualConfig`, reinicie Play e verifique permissão, rig, prioridades, fade e fallback de erro. IDs vazios devem continuar funcionando proceduralmente. |
| Rollback | Pare Play e execute `Rollback()`. Confira corpos/adornos/scripts originais, IDs e posições. Salve/reabra e teste interações V1. Reaplique V2 na cópia para confirmar o ciclo completo. |

Não foram executados: Studio/Roblox Player, física real, multiplayer real, persistência/teleporte/recibos reais, animações publicadas, dispositivo móvel físico, MicroProfiler/FPS ou antivírus/sandbox Windows. Os alertas históricos do Defender permanecem sem causa determinada; nenhum teste acima libera o arquivo no antivírus.
