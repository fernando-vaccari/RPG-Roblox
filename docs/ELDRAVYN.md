# Auditoria e implementação — Eldravyn: Rise of Shadows

## Auditoria antes das alterações

Revisados os módulos de `src`, configurações dos dois Places, scripts de build/empacotamento, regras/testes e documentação de progresso. O projeto usa Rojo 7.7.1; `src/shared` vai para ReplicatedStorage, serviços para ServerScriptService e geradores exclusivos do editor para ServerStorage. Um build `.rbxlx` contém os scripts; a geração e gravação do cenário acontecem no editor.

| Área | Estado encontrado | Trabalho necessário |
| --- | --- | --- |
| Fundação/dados | Implementada com lock, falha conservadora e recibos | Migração aditiva para tutorial, guilda e expedições |
| Combate | Combo/pesado/esquiva/bloqueio/habilidades/projéteis | Parry, postura, crítico moderado, aviso de ataque comum |
| Personagem | Cinco raças permanentes, quatro bases/seis avançadas | Apresentação inicial, compatibilidade de armas, armadura explícita |
| Mundo | Quatro cidades/duas florestas, 60 lotes | Cinco cidades maiores, terceira floresta, guilda externa e pontos de interesse |
| Dungeon | Sete salas legadas + cooperação até quatro | Duas expedições com 10/20 andares, controle de progressão e derrota |
| RPG | 15 principais/20 secundárias, Gold/itens/baús | Ranks promovíveis, missões locais e defesa de cidade |
| Cliente | Menus/HUD/mapa/controles básicos | Tutorial, morte/carregamento, postura, habilidade touch/aim |
| Qualidade | Testes CLI/mock e dois builds | Regressões adicionais e matriz manual atualizada |

Falhas concretas: `UI.update` buscava Purchases/ServerTime fora de State; ataque comum inimigo sem windup; qualquer arma podia executar ataque básico em qualquer classe; couraça era ativada pela simples posse; ranks superiores eram apenas catálogo. Não substituir os sistemas maduros de persistência e identidade.

## Decisões de compatibilidade

- Nome público novo; ProjectId, DataStore e IDs legados permanecem estáveis.
- Raça sorteada uma vez, com probabilidades 70/12/8/6/4. A interface apresenta a linhagem; não oferece reroll disfarçado de criação de personagem.
- Dois Places: continente e dungeon. As duas expedições compartilham o segundo Place; a dungeon legada continua disponível.
- Mudança de geografia exige gerar em Place vazio/cópia nova. O mapa salvo pelo usuário não é sobrescrito.
- Produtos sem IDs e fusões sem resultados definidos continuam bloqueados. Áudio próprio depende de upload autorizado; nenhum ID inventado.
- Testes cloud não substituem Studio, multiplayer real, DataStore/teleporte da plataforma ou benchmark do notebook.

## Implementação e evidência finais

As lacunas da auditoria foram implementadas em 0.6.0; PROGRESSO.md contém o estado por etapa e os erros corrigidos. DefenseRules/AdventureRules/DungeonRules mantêm decisões testáveis no servidor. ExpeditionService controla encontros/participantes/tickets e recompensa cada andar confirmado uma vez; SiegeService liquida a defesa com marcador persistente. DungeonInteriorGenerator mantém o interior legado e adiciona 30 andares; não gera o continente no runtime.

A preparação de editor usa o StringValue ServerStorage.MedievalPlaceKind do respectivo projeto Rojo. `PrepareStudio()` ativa uma prévia de sessão reconhecida somente no Studio; `Persistent=true` exige armazenamento real. O build XML verifica serviços/papel/dependências, mas não executa o engine. A entrega não deve ser anunciada como arquivo com mapa já gravado ou jogo homologado.

Verificação atual: 63 Luau, 52 cenários CLI, 36 fluxos mock e dois builds de 48 módulos/2 bootstraps. O mock verifica áreas calculadas de UI em três resoluções, sem afirmar renderização responsiva validada. O teste de quatro jogadores usa IDs negativos como nos clientes locais do Studio.
