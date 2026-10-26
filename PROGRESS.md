# Progresso

> Estado atual: Eldravyn 0.6.0. Consulte [PROGRESSO.md](PROGRESSO.md) e [COMO_JOGAR_NO_STUDIO.md](COMO_JOGAR_NO_STUDIO.md). As seções anteriores são histórico quando divergirem da versão atual.


## Fase 1 — código implementado, aguardando execução no Studio

- Repositório inicial continha somente `README.md`; nenhum mapa existente foi removido.
- Rojo 7.7.1: módulos do editor em ServerStorage, configuração em ReplicatedStorage e StreamingEnabled no Place.
- Ferramentas locais verificadas por SHA-256, com instaladores separados para Linux e Windows 11 x64.
- Configuração central, quatro reservas urbanas e duas reservas florestais, seed, perfis/orçamentos para fases futuras.
- Terreno por voxels: ruído determinístico, relevo moderado, montanhas no oeste/norte e plataformas urbanas com transição suave.
- Geração somente no editor, preview, verificação de ocupação antes da escrita, chunks, cancelamento e diagnóstico de falha parcial.
- Organização GeneratedWorld, sete marcadores de reserva e SpawnLocation inicial.
- Validação no engine disponível por comando, ainda não executada; sete testes puros passaram na nuvem.
- Build do Place, sourcemap e API de sincronização Rojo verificados no Linux.
- Tutorial Windows 11 e continuidade preservada.

## Limites explícitos

Nenhuma cidade/vegetação foi construída. Reservas não equivalem a regiões prontas. Regeneração é bloqueada até haver recuperação segura. Nenhum sistema de runtime foi criado; nenhuma geração é disparada ao entrar no jogo. O Terrain completo ainda NÃO foi executado/inspecionado no Studio.

## Continuação — fases 2 a 4

- Adicionados rio meandrante com água/leito/bancos e máscaras de altura para estradas ao núcleo existente.
- Planejador puro verificou 60 lotes sem sobreposição, seis rotas, 42 segmentos de ponte e 200 árvores no perfil LOW.
- Implementados geometria reutilizável, construções com telhados inclinados, paredes/entrada aberta, janelas, madeira, detalhes específicos de castelo, forja, torre, biblioteca, moinho e demais serviços.
- Geradores de cidades, muralhas com vãos nas rotas, florestas, ruínas, baús, marcadores e NPCs procedurais R6.
- Os módulos de conteúdo ainda serão conectados ao orquestrador e validados no build. Aparência e acessibilidade no Studio permanecem NÃO TESTADAS.

## Fases 5 e 6 — código implementado

- Dungeon separada com sete salas conectadas, corredores/pontes, sala secreta, armadilha, arena, inimigos/minichefe/chefe, baú condicionado e portal.
- Continente ganhou portão monumental/guardião, marcadores cinematográficos e NPCs de cada serviço.
- Rig procedural R6 articulado é a alternativa própria disponível (não é asset R15 profissional). Consultado API dump público para verificar RigType, Terrain e métodos de teleporte utilizados.
- Orquestrador da fase 1 preservado e estendido: um comando passa pelas etapas de conteúdo após o Terrain. Geração continua exclusiva do editor.

## Fases 7 a 9 — sistemas escritos, validação em andamento

- Regras puras de Gold/inventário/compras, equipamento inicial, classe pós-missão, Rank F, seis missões e saques por jogador.
- DataStore opcional com UpdateAsync, lock de sessão, congelamento em falha e recusa de defaults quando load falha; modo volátil explícito por padrão.
- Runtime autoritativo conecta prompts, contexto/distância/expiração, rate limiting, ferramentas, combate, inimigos/Pathfinding, recompensas e armadilhas.
- Máquina de grupos até quatro com confirmação reiniciada quando membros mudam, validação de presença e opções solo/cooperativa.
- TeleportAsync configurável e salvamento prévio; teste Studio gera mapa isolado em X=6000 e informa que não testa teleporte real.
- Ainda faltam UI, integração/testes finais e validação no engine. Não considerar essas funcionalidades validadas no Roblox neste ponto.

## Fase 10 — integração/otimização em andamento

- HUD, diálogos com botões, inventário, diário, interface de grupo, minimapa, regiões e barra do chefe implementados no cliente.
- Atualização de IA central a 4 Hz, pathfinding com intervalo mínimo de 2 s por ator, ativação por proximidade e teto LOW de 16 inimigos. StreamingEnabled permanece ativado.
- Partículas não são necessárias; luzes limitadas por cidade/sala. Geometria estática e detalhes sem colisão/toque onde apropriado.
- Sete testes adicionais da progressão/economia/saque/grupos passaram; compilação de todos os módulos passou.
- Diagnóstico de API encontrou `Enum.Material.Tile` inexistente: substituído por Slate. Nenhuma API ou ID fictício foi mantido.

## Fechamento da continuação — fases 10 e 11

- 25 módulos Luau e dois bootstraps de runtime integrados aos dois projetos Rojo.
- Continente no mock atual: 5305 Parts, 63 NPCs, quatro cidades, 60 lotes, duas florestas, seis rotas e dez baús. 200 árvores no LOW.
- Regras CLI, grafo de conectividade, três perfis, compilação/análise pura, sete fluxos mock de geração/UI/dados e builds passaram.
- Regeneração de cidade/floresta/decoração/marcadores implementada com estágio e backups, sem tocar Terrain. Assinatura de geografia impede colocar construções novas em relevo incompatível.
- Dois arquivos rbxlx preparados para abrir no Windows. Eles contêm o código; o continente e o interior precisam ser gerados no editor e salvos.
- README substitui as limitações antigas de scaffolding por passos atuais de geração, NPCs, guilda, combate, grupos, dungeon, persistência e Windows. Matriz de homologação real em docs/STUDIO_TEST_MATRIX.md.
- Nenhuma publicação, Git push, cobrança ou acesso a DataStore/TeleportService real foi executado.

## Limites atuais (substituem o estado histórico da fase 1 acima)

O código das fases 2–11 existe e foi integrado, mas o jogo NÃO está homologado no Studio. Aparência, física, IA/pathfinding, desempenho no notebook, multiplayer, DataStore e teleporte reais continuam NÃO TESTADOS. Rigs são R6 procedurais; áudio e animações profissionais não foram adicionados. A substituição global de Terrain continua bloqueada, com regenerações seletivas disponíveis. Não chamar esses itens de prontos sem executar a matriz.

Artefatos finais: build/ProjectMedievalRPG.rbxlx, build/ProjectMedievalRPG_Dungeon.rbxlx e build/RPG-Roblox-Windows11.zip. Instruções de instalação/inicialização do ambiente salvas em rascunho, com estado de homologação pendente explícito. Conferir TEST_RESULTS e README antes de publicar/testar.

## Expansão solicitada — combate e campanha, sem testes manuais agora

- Base existente preservada. Auditoria em docs/AUDIT_EXPANSION.md.
- AbilityConfig/CombatRules acrescentam progressão 1–100 e atributos; 24 habilidades no catálogo, incluindo quatro slots por classe e 12 magias de fogo/gelo/raio/cura.
- CombatService ampliado com combos de quatro, pesado, bloqueio frontal, esquiva, corrida, mana/stamina/cooldowns, interrupção, buffs, cura/regeneração, slow/stun/burn e ataques múltiplos. Autoridade permanece no servidor, sem PvP ativo.
- IA existente integrada à defesa/status; chefes florestais adicionais e Malgorth com duas fases e ataques em área com linha de visão.
- Campanha total de 15 principais + 20 secundárias; visitas/conversas/kill/interações têm fontes reais no servidor e pré-requisitos.
- Venda, desequipar, materiais e pacote de missão integrados. Persistência preserva desbloqueios e escolha gratuita. Corrigido reset indevido de classe ao salvar desequipado e possibilidade de reobter arma grátis após vender.
- HUD de recursos/XP/nível, menu de habilidades, controles desktop/toque, números de dano e poses procedurais simples. WAV próprios gerados, mas reprodução exige upload de assets reais, ainda não feito.
- Suíte expansion.spec adicionada. Fonte, builds e ZIP devem ser usados da versão mais recente. O usuário adiou testes Studio: NÃO tratá-los como pré-requisito para continuar desenvolvimento.

## Raças e classes — continuação atual

- IdentityConfig e IdentityRules novos, sobre o perfil e o combate existentes. Cinco probabilidades inteiras somam 100; atribuição única é gravada no UpdateAsync de aquisição da sessão. Imutabilidade da raça é conferida também no save.
- Persistência padrão ativada; modo volátil deixa raça pendente, sem reroll a cada entrada. Migração preserva XP/Gold/inventário/missões e aceita classes avançadas com prova dos desafios salvos.
- Missões raciais próprias, algumas secretas, falha por morte/timeout, ReadyAt persistente de 86400 s, evolução mediante objetivos + cinco fragmentos. Morte durante transação fica pendente e é aplicada após a gravação.
- Seis classes avançadas, quatro técnicas próprias cada, slots/atributos/arma-base, herança das técnicas antigas. Arqueiro e as 24 habilidades anteriores preservados. Invocador tem aliado temporário real; Necromante tem dreno.
- Aparência aditiva própria por raça, sem remover avatar/acessórios. Habilidades raciais funcionais e compensações de recursos sem multiplicador de dano por raridade.
- Fragmentos de dungeon integrados aos contribuidores de Knight/Malgorth; missões raciais obrigatórias não são substituídas por fragmentos.
- Fusões preparadas com três gratuitas por semana UTC e créditos separados; catálogo vazio bloqueia tentativa e compra com Gold/Robux. Nenhuma combinação foi criada sem definição do autor.
- PurchaseService usa um único ProcessReceipt por servidor, ProductInfo/Prompt oficiais e concessão+ledger na mesma transação do perfil. IDs todos 0. Recibo confirmado só após persistência; retry não duplica nem reverte progresso posterior.
- Menu L/Linhagem para desktop/toque; R para ação racial. Seleção inicial destaca as três classes principais.
- Testes puros e integração mock ampliados para probabilidades, persistência, receitas simuladas, classes, cooldown racial, morte em transação e combate. Homologação Roblox/financeira real permanece pendente.

## Qualidade geral 0.5.0 — estado atual

- Auditoria identificou e corrigiu save de snapshot congelado na saída, envelope/lock malformado, lease expirado, arma com quantidade zero e falsa confirmação de recuperação após teleporte.
- Pipeline de projétil real no servidor/visual local, tempo de viagem, colisão varrida, limites/cancelamento; explosões e campo persistente; windup de chefes e escalonamento de HP por 1–4 participantes.
- Interiores com plano puro de acessibilidade da entrada, NPCs orientados, árvores/cavernas, dez baús com mesmos IDs, bordas de rio e dungeon com vãos fechados e salas refinadas.
- Menu central/atlas/configurações/ofertas/Tester, textos autoajustáveis, rótulos sem callback vazio, recarga nos botões e descrição de objetivos. VIP/pacotes/fusões indefinidos seguem bloqueados.
- Clima local/qualidade de efeitos e movimento reduzido; LOW mantém chuva sem Parts e 16 inimigos. Contagem mock de mundo: 6138 Parts/63 NPCs; não há benchmark real.
- Check completo passou com 50 Luau, 40 cenários CLI e 21 fluxos mock. Dois builds com 37 módulos. Relatório detalhado e limitações: docs/IMPROVEMENTS.md.
- Não publicar nem ativar compras; testes manuais seguem adiados. Não declarar melhoria estética/fluidez/desempenho reais validados a partir de compilação/mock.

## Eldravyn 0.6.0 — estado atual

Continuação concluída em código/testes cloud sobre esta base. Cinco cidades, três florestas, 10/20 andares, parry/postura, tutorial, ranks, defesa, equipamentos, interface e preparação Studio integrados. O estado completo e a próxima tarefa exata estão em PROGRESSO.md. Verificação: 63 Luau, 52 CLI, 36 fluxos mock, 48 módulos por Place. Studio e serviços reais pendentes.
