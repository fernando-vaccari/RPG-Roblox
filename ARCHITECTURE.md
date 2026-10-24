# Arquitetura atual

Fase 1 preservada: WorldConfig, TerrainMath, TerrainGenerator, WorldGenerator, ValidationGenerator e Rojo permanecem a base. O pedido integral está em docs/REQUIREMENTS.pt-BR.txt.

## Editor

`WorldGenerator.GenerateNewWorld` valida configuração/plano, cria lock próprio, recusa Parts/voxels ocupados, escreve Terrain em chunks e passa por `ContentGenerator`: rotas/pontes, cidades/buildings, florestas, NPCs/baús/spawns e entrada da dungeon. DecorationGenerator adiciona detalhes por orçamento. ValidationGenerator confere estrutura e amostras de solo no engine. Nenhum bootstrap de runtime chama esse gerador.

`TerrainMath` e `WorldPlan` são puros e usados tanto nos testes CLI quanto no editor. O plano reserva lotes por círculos conservadores, preserva corredores e usa seed determinística. O Terrain é singleton do Workspace, com escrita estritamente delimitada; demais instâncias vivem em GeneratedWorld.

`DungeonInteriorGenerator` constrói outro mapa sem Terrain, no Place separado; o teste Studio explicitamente opcional coloca uma cópia isolada em X6000 no mesmo Place de teste. Não é uma simulação de sucesso de TeleportService.

`RegenerationService` cria estágio, valida identidade/assinatura e arquiva objetos substituídos em ServerStorage.MedievalBackups. Não substitui voxels. Mudança de geografia exige novo Place. Falhas de geração não apagam o Terrain parcial; backup do Place anterior é a recuperação recomendada.

## Runtime autoritativo

`Main.server` cria Action/Effects, inicializa GameService e relógio de Lighting. GameService liga Prompts/RemoteEvents às operações. AntiExploitService controla argumentos, frequência, vida, distância e contexto expirável. O cliente nunca envia preço, saldo, valor de recompensa ou dano aceito como autoridade.

Progression é a regra pura de economia, missões, classe e saques. InventoryService constrói ferramentas e aplica inventário/armadura. CombatService verifica arma equipada, cooldown, alcance, direção e raycast, e escolhe um inimigo. EnemyService usa um scheduler central com cap de atores, proximidade e pathfinding escalonado. A morte autoritativa distribui recompensas aos contribuidores próximos.

DataService usa UpdateAsync, envelope de perfil e lock por GUID com TTL/renovação. Falha de load deixa o perfil indisponível; não grava defaults. Save falho congela o perfil. Configuração padrão volátil não acessa DataStore.

DungeonService usa a máquina pura Party: máximo quatro, confirmação, presença/elegibilidade e liderança. Faz save/release antes do TeleportAsync para servidor reservado; falhas disparam recuperação do perfil e comunicação. TeleportData contém somente IDs/metadados; economia é recarregada pelo DataStore da Experience. A sessão volátil não permite teleporte real para evitar perda de dados.

## Cliente

UIController constrói HUD, diálogos, lojas, inventário, quests, grupos e controles de toque. WorldController mantém minimapa, nomes de regiões, apresentação de combate, barra do boss, poses e cor local de Nocthar. Atualizações visuais respeitam distância; streaming limita instâncias carregadas. Cor local aplica-se à vista do jogador naquela região, não a uma Atmosphere global localizada fictícia.

## Testes e limites

Testes puros executam o mesmo código de regras/plano. O bundler de integração executa módulos reais de geração/UI/DataService com um host simulado que consulta nomes de propriedades/enums de um API dump público. Mock não implementa física, renderização, rede, garantias de datastore ou navegação do Roblox. Ele não autoriza afirmar que o jogo está homologado.

Os dois projetos Rojo empacotam 27 módulos e dois bootstraps. O arquivo de dungeon usa o mesmo runtime e detecta seu mapa por GeneratedDungeon. Compilar rbxlx não materializa Terrain; a geração persiste quando executada no editor e o Place é salvo.

## Identidade persistente e produtos (versão atual)

IdentityConfig/IdentityRules acrescentam regras puras de raça, desafios, classe avançada, calendário UTC, fragmentos e créditos. DataService prepara os campos novos na migração e só libera o perfil depois de gravar a primeira raça com o lock da sessão. Save compara a raça original com a versão durável e recusa alteração. Modo volátil deixa raça pendente.

IdentityService recebe eventos de fontes já autoritativas (posição, prompts, kills) e aplica operações críticas por Data.changeIdentity: snapshot, congelamento curto, validação de posse, UpdateAsync e nova leitura do resultado. Falhas não liberam um perfil como se estivessem confirmadas. Morte durante uma operação fica pendente e é aplicada após o commit; falha de plataforma prolongada ainda exige testes reais de recuperação.

PurchaseService é o único ProcessReceipt. Data.receipt confirma crédito e chave de idempotência no MESMO registro do jogador; não há uma operação separada de ledger que possa ser confirmada sem o crédito. Replay conhecido retorna sem substituir alterações posteriores do perfil. O ledger não é transmitido ao cliente. Produtos seguem com IDs zero.

CombatRules admite herança de habilidades e modificadores raciais de soma zero. CombatService mantém cooldowns/recursos ao trocar classe, limita invocações e executa dreno/raciais no servidor. A UI apresenta somente estado e intenções; nunca transmite ticket racial, preço, dano, progresso concluído ou quantidade de fragmentos.

Catálogo de fusão vazio é uma decisão de produto: esta versão não executa sorteio nem consome moedas/fragmentos/tentativas e não inventa resultados. Qualquer resolvedor futuro precisa de definição do criador e implementação/testes próprios.

## Qualidade 0.5.0 — arquitetura atual

São agora 37 módulos e dois bootstraps em cada Place. ActionMath centraliza orçamento temporal/padrões de área; ProjectileService mantém tiros num scheduler Heartbeat com raycast varrido, sem Parts físicos no servidor. O cliente renderiza projéteis/explosões/avisos sem autoridade sobre dano. CombatService reutiliza a mesma aplicação validada de dano para melee/projétil/campo. Limites e cancelamento por personagem/classe não são opcionais visuais.

InteriorPlan separa disposição de móveis da construção. EnvironmentRules fornece clima determinístico e orçamento local de apresentação. BenefitPreview e TesterService oferecem apenas relatórios de produtos já aprovados: Studio, opt-in e sem persistência; não introduzem comandos de concessão ao perfil.

DataService recusa saves de snapshots congelados e libera somente o lock ao sair nesse estado; envelopes/locks inválidos e lease expirado são tratados conservadoramente. DungeonService usa o mesmo save/release e distingue recuperação confirmada de simples tentativa de load. Ver docs/IMPROVEMENTS.md para evidência e limites.
