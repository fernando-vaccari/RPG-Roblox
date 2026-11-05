# CODEX — ELDRAVYN NPC OVERHAUL V2
## Modernização visual, animações e inteligência ambiental dos NPCs

Você é um desenvolvedor sênior especializado em Roblox Studio, Luau, personagens R15, rigging, animações, sistemas modulares e otimização de jogos RPG.

Sua missão é desenvolver uma atualização completa dos NPCs do jogo **ELDRAVYN**, um RPG medieval de mundo aberto inspirado em Sword Art Online, The Elder Scrolls e RPGs de fantasia.

**IMPORTANTE: ESTE TRABALHO É UMA ATUALIZAÇÃO DO SISTEMA EXISTENTE, NÃO A CRIAÇÃO DE UM JOGO NOVO.**

## 1. Analisar o projeto existente

Antes de modificar qualquer arquivo:

1. Analise a estrutura completa do projeto.
2. Localize `EldravynNPCPackage`, `EldravynNPCs`, `MedievalRPG`, `GeneratedWorld` e todos os módulos relacionados.
3. Examine `Installer`, `NPCConfig`, `PlacementConfig`, `R15Factory`, os módulos de cliente e servidor e os scripts de interação.
4. Identifique como os NPCs são criados, posicionados, identificados e conectados às funções existentes.
5. Preserve a compatibilidade com a instalação anterior.
6. Documente dependências, limitações e riscos antes de implementar alterações.

Não assuma que os nomes dos arquivos ou a estrutura são idênticos em todas as versões. Inspecione os arquivos reais.

## 2. Restrições absolutas

É proibido:

- Recriar, substituir ou apagar o mapa.
- Alterar o terreno.
- Modificar cidades, casas, florestas, dungeons ou construções.
- Apagar NPCs existentes ou suas informações.
- Alterar a economia, os preços, as missões ou a progressão.
- Reescrever sistemas de inventário, combate, classes ou salvamento.
- Criar sistemas duplicados de DataStore.
- Substituir scripts funcionais desnecessariamente.
- Usar assets pagos como dependência obrigatória.
- Inserir scripts de terceiros não auditados.
- Criar uma segunda lógica de servidor conflitante.

O mapa `GeneratedWorld` deve permanecer intacto.

Os NPCs existentes devem manter seus atributos `NPCRole`, `City`, identificadores e vínculos com os sistemas de diálogo e interação.

## 3. Direção artística: anime + realismo medieval

Crie NPCs com identidade visual própria.

O estilo deve combinar:

- Proporções humanas estilizadas de anime.
- Rostos expressivos e agradáveis.
- Cabelos com formas detalhadas.
- Armaduras com aparência de metal trabalhado.
- Roupas medievais com camadas e variações.
- Botas, luvas, cintos, bolsas e acessórios.
- Paleta de cores coerente com cada cidade e profissão.
- Silhuetas distintas entre personagens.

Evite NPCs que pareçam bonecos básicos de Roblox.

Não copie personagens protegidos de animes ou jogos. Crie designs originais com inspiração estética no gênero.

### Qualidade dos modelos

Use rigs R15 compatíveis com Humanoid, Animator e acessórios apropriados.

Priorize:

- Roupas com aparência de tecido e couro.
- Peitorais, ombreiras e proteções metálicas.
- Acessórios posicionados corretamente.
- Cabeças e cabelos com proporções coerentes.
- Movimentos sem interseções excessivas entre acessórios e corpo.

Se houver meshes, texturas e animações próprias disponíveis, integre-as corretamente.

Se não houver, implemente a melhor versão possível com recursos nativos do Roblox, peças, MeshParts disponíveis no projeto e materiais.

**Não afirme ter criado meshes profissionais, texturas pintadas ou animações publicadas quando esses recursos não existirem.**

## 4. Identidade visual por profissão

### Guardas

- Armaduras de aço e couro.
- Espadas embainhadas.
- Escudos ou lanças conforme a função.
- Capacetes variados.
- Capas discretas.
- Postura disciplinada.

### Mestres de guilda

- Roupas elegantes e detalhadas.
- Capas e emblemas da guilda.
- Aparência experiente e imponente.
- Gestos de liderança.
- Postura confiante.

### Ferreiros

- Aventais de couro.
- Luvas de trabalho.
- Martelos e ferramentas.
- Roupas com aparência de uso.
- Animações de trabalho na forja.

### Magos

- Mantos detalhados.
- Cajados e acessórios mágicos.
- Runas discretas.
- Efeitos mágicos leves e otimizados.
- Animações de leitura, estudo e conjuração.

### Comerciantes

- Roupas de viajantes e mercadores.
- Bolsas, cintos e pequenos acessórios.
- Expressões amigáveis.
- Gestos de negociação.

### Estalajadeiros

- Roupas medievais civis.
- Aventais ou coletes.
- Animações de atendimento.
- Comportamentos relacionados à estalagem.

### NPCs especiais

Identifique os demais papéis já existentes em `NPCConfig` e crie aparências específicas sem remover nenhuma função.

## 5. Sistema de animações R15

Desenvolva uma arquitetura modular para animações.

### Animações básicas

- Idle natural.
- Respiração sutil.
- Olhar para os lados.
- Pequenas mudanças de postura.
- Caminhada.
- Corrida, quando aplicável.
- Cumprimento.
- Conversa.
- Reação à aproximação do jogador.

### Animações profissionais

Ferreiros:
- Martelar.
- Examinar armas.
- Organizar ferramentas.

Magos:
- Ler livros.
- Erguer cajado.
- Conjurar efeitos discretos.

Guardas:
- Patrulhar.
- Observar o ambiente.
- Assumir postura de alerta.

Comerciantes:
- Organizar mercadorias.
- Cumprimentar clientes.
- Gestos de negociação.

Mestres de guilda:
- Examinar documentos.
- Gestos de orientação.
- Postura de autoridade.

### Requisitos técnicos

1. Utilize `Animator` e `AnimationTrack` corretamente.
2. Organize animações por prioridade.
3. Evite reproduzir animações incompatíveis simultaneamente.
4. Faça transições suaves.
5. Não recrie AnimationTracks a cada frame.
6. Implemente gerenciamento e limpeza de conexões.
7. Respeite o estado do Humanoid.
8. Evite conflitos com o Animate padrão.
9. Não utilize IDs de animações inventados.
10. Caso sejam necessários assets publicados, documente os IDs pendentes e forneça alternativas funcionais.

Quando possível, utilize movimentos procedurais leves com `Motor6D`, respeitando o rig R15.

## 6. Comportamento ambiental

Os NPCs não devem permanecer completamente imóveis.

Crie comportamentos naturais, previsíveis e leves.

### Guardas

- Patrulhar pequenos percursos seguros.
- Parar para observar.
- Retornar à posição original.
- Interromper a patrulha durante interações.
- Não atravessar paredes ou construções.

### Comerciantes

- Permanecer próximos de suas lojas.
- Realizar gestos de trabalho.
- Olhar para jogadores próximos.
- Retornar ao comportamento anterior após o diálogo.

### Ferreiros

- Trabalhar periodicamente.
- Interromper a animação para atender jogadores.
- Retomar o trabalho após a interação.

### Magos

- Estudar.
- Manipular objetos mágicos.
- Produzir efeitos visuais discretos.
- Interagir naturalmente com jogadores.

### Mestres de guilda

- Permanecer em seus postos.
- Observar documentos ou mapas.
- Cumprimentar jogadores próximos.

Os comportamentos não podem modificar a função original do NPC.

## 7. Sistema de atenção ao jogador

Implemente um sistema de atenção contextual.

Quando um jogador se aproximar:

- O NPC pode virar suavemente a cabeça.
- O NPC pode orientar parcialmente o torso.
- O NPC pode executar um cumprimento curto.
- O NPC deve retornar naturalmente à postura anterior.

Limite a distância de percepção e o ângulo de rotação.

Não faça o NPC girar constantemente para jogadores distantes.

Priorize a interação ativa quando houver múltiplos jogadores.

## 8. Preservação das interações

Todos os NPCs devem continuar executando suas funções anteriores.

Preserve:

- Diálogos.
- Missões.
- Lojas.
- Serviços de guilda.
- Serviços de ferreiro.
- Serviços mágicos.
- Progressão relacionada a NPCs.
- Identificadores e atributos.
- Eventos remotos.
- Permissões e validações de servidor.
- Dados persistentes existentes.

Não substitua interfaces funcionais sem necessidade.

Se houver incompatibilidade entre um modelo novo e um script antigo, implemente um adaptador de compatibilidade.

## 9. Otimização

O jogo deve funcionar em computadores intermediários e dispositivos móveis.

Implemente:

- Atualizações de comportamento com frequência limitada.
- Distâncias de ativação.
- Redução de animações secundárias em NPCs distantes.
- Efeitos visuais com custo controlado.
- Limites de partículas.
- Cache de referências.
- Limpeza de conexões.
- Controle de tarefas assíncronas.
- Reutilização de recursos quando apropriado.

Evite loops `while true` pesados por NPC.

Não use PathfindingService continuamente sem necessidade.

Mantenha a lógica visual preferencialmente no cliente quando isso não comprometer a sincronização e a segurança.

## 10. Compatibilidade com o mapa

Os NPCs já foram instalados no mapa.

Portanto:

1. Preserve seus posicionamentos.
2. Preserve `PlacementConfig`.
3. Não mova NPCs para cidades diferentes.
4. Não altere o `GeneratedWorld`.
5. Não recrie a instalação completa.
6. Atualize modelos e comportamentos existentes por identificação.
7. Evite duplicar NPCs.
8. Não altere a estrutura das construções.

Se um NPC estiver mal posicionado, registre o problema em vez de modificar automaticamente o mapa.

## 11. Arquitetura sugerida

Adapte a estrutura real do projeto, preferencialmente com módulos equivalentes a:

- `NPCAppearanceConfig`
- `NPCVisualFactory`
- `NPCAnimationController`
- `NPCBehaviorController`
- `NPCAttentionController`
- `NPCPerformanceManager`
- `NPCVisualUpgrade`

Separe dados de aparência, criação visual, animações, comportamento e atualização.

Evite concentrar todo o código em um único script.

## 12. Sistema de atualização V2

Crie um atualizador compatível com a instalação atual.

O atualizador deverá:

1. Verificar se `EldravynNPCs` existe.
2. Verificar a versão instalada.
3. Identificar NPCs pelos atributos existentes.
4. Preservar seus identificadores e funções.
5. Atualizar somente a camada visual e comportamental.
6. Evitar duplicações.
7. Registrar os NPCs atualizados.
8. Detectar dependências ausentes.
9. Permitir testes em uma cópia do projeto.
10. Fornecer instruções para reverter a atualização.

Faça backup lógico das configurações afetadas antes de substituí-las.

Use uma estratégia de migração idempotente, com validações antes de aplicar mudanças.

Não habilite automaticamente scripts potencialmente conflitantes.

## 13. Testes obrigatórios

Implemente e execute, quando o ambiente permitir, testes para verificar:

- Existência dos NPCs.
- Compatibilidade R15.
- Preservação de atributos.
- Preservação dos diálogos.
- Preservação dos serviços.
- Ausência de NPCs duplicados.
- Ausência de alterações no terreno.
- Ausência de alterações nas construções.
- Funcionamento das animações.
- Interrupção correta de comportamentos.
- Ausência de conflitos entre controladores.
- Funcionamento com múltiplos jogadores.
- Desempenho com muitos NPCs.
- Compatibilidade com a versão anterior.

Se os testes dependerem do Roblox Studio e não puderem ser executados no ambiente atual, forneça um roteiro reproduzível de validação manual. Não declare testes como aprovados sem executá-los.

## 14. Entrega

Entregue:

1. Código Luau completo dos módulos novos ou modificados.
2. Modelos e configurações visuais compatíveis com R15.
3. Controladores de animação e comportamento.
4. Atualizador V2.
5. Instruções exatas de instalação.
6. Instruções para rollback.
7. Relatório dos arquivos modificados.
8. Relatório dos testes realizados.
9. Lista de assets externos necessários, se houver.
10. Lista de limitações visuais reais.

Se possível, gere um pacote `.rbxmx` válido para importação no Roblox Studio, sem depender de uma instalação do zero.

Não entregue apenas pseudocódigo.

Não substitua recursos ausentes por afirmações de que foram implementados.

## 15. Critérios finais de aceitação

A atualização estará concluída quando:

- Os NPCs existentes tiverem aparências medievais individualizadas.
- Os personagens utilizarem rigs R15 funcionais.
- As animações básicas estiverem funcionando.
- Os comportamentos ambientais estiverem integrados.
- As interações anteriores continuarem funcionando.
- Nenhum NPC tiver sido duplicado.
- O mapa original estiver preservado.
- O desempenho estiver dentro de limites razoáveis.
- O atualizador puder ser executado novamente com segurança.

**PRIORIDADE MÁXIMA: QUALIDADE VISUAL + PRESERVAÇÃO TOTAL DOS SISTEMAS EXISTENTES.**

Comece analisando os arquivos reais do repositório e apresente um plano curto. Em seguida, implemente as alterações necessárias, execute os testes disponíveis e entregue o pacote de atualização com instruções claras.

Não desenvolva combate, inventário, árvore de habilidades, novas dungeons ou novos sistemas de progressão nesta tarefa.