# CODEX — ELDRAVYN RPG
## ETAPA 2: IMPLEMENTAÇÃO COMPLETA DOS NPCs E SUAS FUNCIONALIDADES

Você é um desenvolvedor sênior especializado em Roblox Studio, Luau, arquitetura cliente-servidor e jogos RPG medievais de mundo aberto.

Sua tarefa é implementar **todos os NPCs e suas funcionalidades próprias** no projeto Eldravyn, sem modificar desnecessariamente o mapa existente.

**IMPORTANTE: Esta etapa é exclusivamente para NPCs. Não implemente o sistema geral de combate, magia, inventário, árvores de habilidades, fusões de raças ou sistemas independentes que serão desenvolvidos posteriormente.**

### 1. ANÁLISE OBRIGATÓRIA DO MAPA

Arquivo principal: `Eldravyn-Monumental(1).rbxlx`

O mapa possui aproximadamente 383 MB e contém estruturas como:

- `GeneratedWorld`
- `ValoriaSpawn`
- `NPCSpawns`
- `GuildCamp`
- `GuildRoad`
- `DungeonEntrance`
- `Plaza`
- `DungeonConfig`
- `DungeonRules`

Antes de implementar:

1. Inspecione a hierarquia real do mapa.
2. Identifique cidades, casas, lojas, mercados, guildas, estradas, entradas de dungeons e construções aproveitáveis.
3. Localize pontos seguros para posicionar NPCs.
4. Utilize os edifícios já construídos sempre que possível.
5. Não coloque NPCs dentro de paredes, abaixo do terreno ou bloqueando portas.
6. Não altere o terreno nem reconstrua o continente.
7. Preserve scripts e sistemas existentes.
8. Evite criar NPCs duplicados quando o projeto já possuir equivalentes.
9. Se um edifício não tiver nome identificável, use sua posição, aparência e contexto para decidir sua função.
10. Se não existir um edifício adequado, posicione o NPC em uma área segura e registre a necessidade de construção futura.

Não presuma que todos os edifícios possuem interiores acessíveis. Verifique antes.

### 2. NPCs A IMPLEMENTAR

**NPC 01 — Mestre da Guilda**

Localização: sede da guilda ou estrutura apropriada próxima de `GuildCamp`.

Funções:
- Registrar jogadores como aventureiros.
- Atribuir rank inicial F.
- Mostrar rank atual.
- Exibir requisitos de promoção.
- Realizar promoção quando os requisitos forem cumpridos.
- Mostrar histórico básico de progressão.
- Permitir consultar benefícios dos ranks.
- Salvar rank e progresso do jogador.

Ranks configuráveis: F, E, D, C, B, A, S.

Criar estrutura preparada para futuras expansões.

**NPC 02 — Quadro de Missões / Recepcionista da Guilda**

Funções:
- Exibir missões disponíveis.
- Filtrar missões por rank.
- Aceitar missões.
- Abandonar missões.
- Consultar progresso.
- Entregar missões concluídas.
- Distribuir recompensas.
- Evitar recompensas duplicadas.
- Salvar missões aceitas e concluídas.

Criar missões iniciais de exploração, visita a locais, conversa com NPCs e descoberta de regiões.

Missões que exigirem derrotar inimigos devem ficar cadastradas, mas só poderão progredir quando o futuro sistema de combate emitir eventos válidos.

**NPC 03 — Administrador de Dungeons**

Localização: próximo à entrada da dungeon.

Funções:
- Mostrar dungeons disponíveis.
- Mostrar número de andares.
- Informar requisitos de rank.
- Informar recompensas previstas.
- Verificar tickets.
- Permitir entrada somente quando os requisitos forem atendidos.
- Mostrar missões de obtenção de tickets.
- Vender tickets utilizando moeda do jogo.

Regras fundamentais:

Cada nível de dungeon possui seu próprio ticket e sua própria missão para conseguir esse ticket.

O jogador pode obter tickets de duas maneiras:
1. Completando missões fornecidas pelo NPC da dungeon.
2. Comprando tickets diretamente com moeda do jogo.

Não criar outros métodos de obtenção nesta etapa.

Preparar as duas dungeons iniciais:
- Dungeon 1: 10 andares.
- Dungeon 2: 20 andares.

O sistema deve validar tickets no servidor, impedir duplicação e registrar consumo.

Não implementar inimigos, chefes ou combate das dungeons.

Se o interior da dungeon ainda não estiver funcional, deixar a entrada preparada, mas não permitir teleporte para um destino inexistente.

**NPC 04 — Ferreiro**

Funções:
- Mostrar equipamentos disponíveis para evolução.
- Exibir materiais e moedas necessários.
- Permitir melhorar armas e armaduras.
- Mostrar nível atual de aprimoramento.
- Confirmar custos antes da operação.
- Aplicar aprimoramentos válidos.
- Salvar evolução dos equipamentos.
- Impedir exploração e duplicação de recursos.

Implementar somente a estrutura de equipamentos necessária ao funcionamento do ferreiro.

Não implementar combate, dano real ou sistema geral de inventário.

**NPC 05 — Comerciante de Armas**

Funções:
- Exibir catálogo de armas.
- Mostrar preço e informações básicas.
- Comprar armas.
- Vender armas permitidas.
- Consultar saldo.
- Confirmar transações.

As armas compradas devem ser registradas em uma estrutura persistente de propriedade de itens, preparada para integração posterior ao inventário.

Não criar habilidades nem ataques.

**NPC 06 — Comerciante de Armaduras**

Funções:
- Comprar armaduras.
- Vender armaduras.
- Mostrar raridade.
- Mostrar requisitos.
- Registrar propriedade e melhorias.

Não implementar sistema geral de defesa ou cálculo de dano.

**NPC 07 — Comerciante Geral**

Funções:
- Vender itens básicos.
- Comprar itens permitidos.
- Vender consumíveis futuros.
- Exibir catálogo organizado.
- Mostrar preços.
- Registrar compras.

Consumíveis sem sistema correspondente devem ficar armazenados, sem efeitos artificiais.

**NPC 08 — Mestre de Classes**

Classes iniciais:
- Guerreiro
- Espadachim
- Mago

Evoluções planejadas:
- Guerreiro → Tanque ou Valquíria.
- Espadachim → Samurai ou Assassino.
- Mago → Invocador ou Necromante.

Funções:
- Explicar cada classe.
- Permitir escolher classe inicial.
- Consultar classe atual.
- Mostrar evoluções possíveis.
- Validar requisitos para evolução.
- Realizar evolução quando os requisitos estiverem implementados e cumpridos.
- Salvar escolhas.
- Permitir troca de classe mediante um produto Roblox configurável de 100 Robux, após validação da compra.

Não implementar habilidades, ataques, magias ou árvores de habilidades.

Não presumir que uma compra foi realizada apenas porque o jogador clicou no botão. Utilizar confirmação oficial do Roblox.

**NPC 09 — Mestre de Magia**

Funções:
- Explicar escolas de magia.
- Exibir catálogo de magias futuras.
- Mostrar requisitos de desbloqueio.
- Registrar desbloqueios autorizados.
- Informar quais magias estarão disponíveis em atualizações futuras.

Não implementar conjuração, efeitos, projéteis ou dano mágico.

**NPC 10 — Mestre de Evolução de Habilidades**

Funções:
- Mostrar informações de progressão.
- Consultar requisitos futuros.
- Explicar evoluções de habilidades.
- Preparar interface para desbloqueios posteriores.

Não implementar árvore de habilidades.

**NPC 11 — Especialista em Raças**

Funções:
- Informar a raça atual do jogador, caso já exista.
- Explicar características das raças.
- Mostrar possíveis evoluções futuras.
- Exibir informações sobre fusões de raças.

Não implementar sorteio inicial, alteração ou fusão de raças nesta etapa.

**NPC 12 — Especialista em Fusões**

Funções:
- Explicar fusão de habilidades e raças.
- Exibir requisitos futuros.
- Mostrar opções planejadas.
- Informar indisponibilidade enquanto os sistemas correspondentes não estiverem implementados.

Não realizar fusões nesta etapa.

**NPC 13 — Estalajadeiro**

Funções:
- Oferecer hospedagem.
- Cobrar moedas.
- Registrar local de descanso.
- Permitir definir ponto de retorno, respeitando as regras do jogo.
- Exibir diálogo de ambientação.

Não criar sistema de fome ou sobrevivência.

**NPC 14 — Curandeiro**

Funções:
- Oferecer serviços de cura.
- Mostrar preço.
- Preparar integração com sistema de vida.

Caso não exista sistema de vida compatível, deixar o serviço indisponível com mensagem apropriada.

Não criar um sistema de combate apenas para viabilizar a cura.

**NPC 15 — Banqueiro**

Funções:
- Consultar saldo de moedas.
- Depositar moedas.
- Sacar moedas.
- Salvar saldo bancário.
- Validar todas as operações no servidor.
- Impedir saldos negativos e duplicações.

**NPC 16 — Vendedor de Tickets**

Pode ser integrado ao Administrador de Dungeons quando fizer sentido.

Funções:
- Vender tickets específicos.
- Mostrar preços.
- Informar requisitos.
- Registrar compras.
- Evitar tickets duplicados indevidamente.

Não criar NPC duplicado se o Administrador de Dungeons já oferecer todas essas funções.

**NPC 17 — Guia da Cidade**

Funções:
- Explicar regiões da cidade.
- Indicar guilda, lojas, ferreiro e dungeons.
- Orientar novos jogadores.
- Fornecer informações sobre exploração.
- Criar marcações temporárias de destinos existentes, quando possível.

**NPC 18 — NPC de Tutorial**

Funções:
- Recepcionar jogadores novos.
- Explicar movimentação.
- Orientar visita à guilda.
- Ensinar interação com NPCs.
- Explicar moedas, ranks e missões.
- Encaminhar o jogador ao primeiro objetivo.
- Salvar progresso do tutorial.
- Permitir pular ou revisar tutorial.

Não ensinar combate com sistemas ainda inexistentes.

**NPC 19 — Mercador Viajante**

Funções:
- Oferecer catálogo diferenciado.
- Apresentar itens raros configuráveis.
- Alterar catálogo por configuração.
- Comprar e vender itens permitidos.

Não implementar eventos aleatórios complexos nesta etapa.

**NPC 20 — NPCs Ambientais**

Criar NPCs para dar vida às cidades:
- Guardas.
- Moradores.
- Viajantes.
- Artesãos.
- Funcionários de lojas.
- Aventureiros.
- Camponeses.

Funções:
- Diálogos variados.
- Informações sobre a região.
- Animações básicas.
- Movimentação simples e limitada quando segura.
- Interações de ambientação.

Não criar combate para guardas.

### 3. SISTEMA UNIVERSAL DE DIÁLOGOS

Criar um sistema único de interação com NPCs.

Requisitos:
- `ProximityPrompt`.
- Interface medieval responsiva.
- Compatibilidade com PC e celular.
- Nome e função do NPC.
- Texto de diálogo.
- Botões de respostas.
- Opção de voltar.
- Opção de encerrar.
- Diálogos ramificados.
- Respostas condicionais.
- Mensagens de erro.
- Confirmação de compras.
- Interface adaptável a diferentes resoluções.

Usar um sistema reutilizável em vez de criar scripts de interface independentes para cada NPC.

### 4. PERSISTÊNCIA E SEGURANÇA

Criar apenas os serviços de dados indispensáveis aos NPCs:

- Moedas.
- Saldo bancário.
- Rank.
- Classe escolhida.
- Progresso de missões.
- Tickets.
- Propriedade básica de itens.
- Aprimoramentos de equipamentos.
- Progresso de tutorial.
- Local de retorno.

Utilizar `DataStoreService` com tratamento de erros, salvamento seguro e prevenção de sobrescrita indevida entre sessões.

Toda compra, recompensa e alteração importante deve ser validada pelo servidor.

Não confiar em valores enviados pelo cliente.

Implementar proteções contra:
- Duplicação de moedas.
- Recompensas repetidas.
- Compras sem saldo.
- Tickets falsificados.
- Chamadas remotas abusivas.
- Promoções indevidas.
- Evoluções sem requisitos.
- Operações simultâneas inconsistentes.

### 5. ARQUITETURA

Organizar o projeto em módulos reutilizáveis, preferencialmente seguindo esta estrutura lógica:

`ReplicatedStorage/EldravynNPC/`
- NPCConfig
- DialogueConfig
- ShopConfig
- QuestConfig
- DungeonTicketConfig
- RemoteEvents

`ServerScriptService/EldravynNPC/`
- NPCService
- NPCDataService
- DialogueService
- QuestService
- GuildService
- ShopService
- TicketService
- BlacksmithService
- ClassService
- BankService

`StarterPlayer/StarterPlayerScripts/`
- NPCInteractionClient
- NPCDialogueClient
- NPCShopClient

`Workspace/`
- NPCs organizados por cidade ou região.

Adapte os nomes e caminhos caso já exista uma arquitetura equivalente no projeto.

Não sobrescrever módulos existentes sem inspecioná-los.

### 6. APARÊNCIA DOS NPCs

Os NPCs devem combinar com o mundo medieval de fantasia e estética inspirada em RPGs de anime.

Exemplos:
- Mestre da Guilda: roupas nobres de aventureiro.
- Ferreiro: avental, luvas e ferramentas.
- Mago: túnica e cajado decorativo.
- Comerciante: roupas de mercador.
- Guarda: armadura medieval.
- Estalajadeiro: roupas de taverna.
- Mestre de Classes: aparência de veterano experiente.

Utilizar personagens Roblox compatíveis com R15 e recursos permitidos.

Priorizar desempenho, reaproveitamento e estabilidade.

Não depender de assets pagos ou IDs não verificados.

### 7. POSICIONAMENTO NO MAPA

Utilizar as estruturas reais identificadas no arquivo.

Prioridades:
1. NPCs principais próximos da cidade inicial e do spawn.
2. Mestre da Guilda na guilda.
3. Ferreiro próximo à forja ou oficina existente.
4. Comerciantes em lojas ou mercados.
5. Estalajadeiro em construção apropriada.
6. Administrador de Dungeons próximo à entrada correspondente.
7. Mestre de Classes em local apropriado.
8. NPCs ambientais distribuídos sem prejudicar o desempenho.

Não colocar todos os NPCs na praça central.

Não inventar nomes ou posições de edifícios sem verificar o mapa.

### 8. LIMITAÇÕES DESTA ETAPA

NÃO IMPLEMENTAR:
- Sistema geral de combate.
- Ataques.
- Parry.
- Esquivas.
- Magias funcionais.
- IA de inimigos.
- Bosses.
- Sistema geral de inventário.
- Árvore de habilidades.
- Sistema completo de raças.
- Fusões de raças.
- Fusões de habilidades.
- Sistema completo de equipamentos.
- Dungeons jogáveis.
- Novo continente.
- Reconstrução de cidades.

EXCEÇÃO: implementar somente os componentes mínimos indispensáveis para que as funcionalidades próprias dos NPCs funcionem.

Não criar sistemas paralelos desnecessários.

### 9. TESTES OBRIGATÓRIOS

Verificar:
1. Todos os NPCs são criados corretamente.
2. Todos possuem interação.
3. Interfaces abrem e fecham.
4. Diálogos funcionam.
5. Lojas validam compras.
6. Moedas não podem ser duplicadas.
7. Missões são registradas.
8. Tickets são comprados corretamente.
9. Tickets de diferentes dungeons não se confundem.
10. Ranks são salvos.
11. Classes são salvas.
12. Aprimoramentos são persistentes.
13. O mapa permanece intacto.
14. O sistema funciona com múltiplos jogadores.
15. Nenhum script depende de sistemas ainda inexistentes para iniciar.
16. Serviços futuros aparecem como indisponíveis quando apropriado.

### 10. ENTREGA

Quero uma implementação real, não apenas documentação ou pseudocódigo.

Se estiver trabalhando diretamente no arquivo `.rbxlx`, gere uma versão funcional modificada e preservando o original.

Se estiver trabalhando em repositório, crie scripts Luau e um instalador ou processo de integração reproduzível no Roblox Studio.

Não afirmar que os NPCs estão instalados no mapa quando apenas os scripts foram gerados.

Ao terminar, informe:
- NPCs implementados.
- Funcionalidades realmente operacionais.
- Funcionalidades preparadas para integração futura.
- Localização de cada NPC.
- Arquivos criados ou alterados.
- Testes executados e resultados.
- Passos necessários para abrir e testar no Roblox Studio.

### REGRA FINAL — ECONOMIA DE CRÉDITOS E EXECUÇÃO EFICIENTE

Execute somente esta etapa.

Primeiro analise a estrutura necessária, depois implemente os sistemas compartilhados e finalmente os NPCs.

Evite explicações longas durante a execução.

Não reescreva o mapa.

Não crie sistemas fora do escopo.

Não interrompa o trabalho para solicitar aprovação a cada NPC, salvo se existir um bloqueio real.

Priorize entregar o máximo de NPCs funcionais, seguros e integrados ao mapa com o mínimo de alterações e de consumo desnecessário de créditos.

**OBJETIVO FINAL: deixar o continente Eldravyn povoado por NPCs medievais funcionais, com guilda, lojas, missões, tickets de dungeon, classes, ferreiro, banco, tutorial e diálogos prontos, mantendo combate, magia e demais sistemas complexos para as próximas etapas.**