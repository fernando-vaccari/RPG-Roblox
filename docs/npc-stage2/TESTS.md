# Verificações da etapa NPC — 31/10/2026

**Roblox Studio não foi executado.** Estes resultados são de Luau CLI, host simulado, reflexão da API e inspeção de XML. Não validam física/R15 em execução real, renderização, streaming em rede, interfaces em aparelhos reais, FPS no Ryzen 7 5700U, DataStore/Marketplace/teleporte reais nem Windows Defender.

## Execuções concluídas

| Verificação | Resultado e limite |
|---|---|
| Compilação de Luau | 105 arquivos de `src`, `tests` e scripts compilados |
| Análise estática | Núcleos/configurações puros anteriores e sete módulos puros NPC; sem diagnósticos na rodada final |
| Suíte pura anterior | Nove arquivos `.spec.luau`, 63 verificações reportadas; preserva gameplay, identidade, terreno, planejamento, arquitetura e qualidade existentes |
| Integração anterior | 46 fluxos MOCK e sete verificações MAPA aprovadas; dois builds Rojo legados com 55 módulos por Place e dependências conferidas |
| NPCs | 19 cenários MOCK de regras, dados, diálogos, recibos, loja, tickets, classes, cura e interface; detalhes abaixo |
| Instalador/inicialização | Quatro cenários MOCK: bloqueio por obstáculo, idempotência/equivalentes, início sem dependências futuras e destinos ocupados |
| XML e empacotamento | 66 Humanoids R15, 66 ProximityPrompts, referências únicas/válidas, Sources novos iguais ao repositório, scripts do instalador desativados; round-trip Rojo/rbx-dom de 66 R15 e 990 motores aprovado |
| Preservação do mapa | SHA do arquivo original permaneceu idêntico; subtree `GeneratedWorld` idêntica e os 40 Sources originais preservados; nenhuma operação de escrita de Terrain |
| Posições | 66 candidatos exteriores confrontados com caixas de 34.798 Parts colidíveis do XML; sem colisões nesse modelo; alturas comparadas à função de terreno existente sem desvios acima de três studs. Não equivale a teste de caminhar no Studio |
| Download GitHub | Ambos os arquivos baixados integralmente por HTTPS do commit `fb9d206d4c977d4039858f6dbee64891fca8f1aa`: HTTP 200 e bytes/SHA-256 iguais ao manifesto; evidência em `evidence/github-downloads.json` |
| Segurança desta adição | Revisão das operações/receipts, nenhum ID real inventado, assets remotos ou código baixado para os NPCs. Não é resultado de antivírus |

Comandos: `python3 scripts/check.py`, `python3 scripts/test_npc_stage2.py` e `python3 scripts/build_npc_stage2.py` e `python3 scripts/verify_npc_stage2.py`. O check geral já executa o teste NPC. Logs finais copiados para `docs/npc-stage2/evidence/`; hashes/manifesto estão na pasta de entrega. Rodadas específicas NPC foram repetidas após ajustes de persistência de evolução, textos de objetivos e colocação.

A base analisada não contém um Item Terrain serializado: por isso `terrain_subtree_sha256` é `null` no manifesto. Não alegamos comparar voxels inexistentes com os voxels da cópia local de 383 MB, que não foi enviada. A confirmação de preservação na cópia do usuário deve ser feita após aplicar o instalador a uma nova cópia salva.

## Cobertura dos 19 cenários NPC

1. Todos os 66 R15 com 15 motores, aparência nativa, prompt único, modo de streaming Atomic e peças não colidíveis/não consultáveis.
2. Perfil sem sorteio racial; registro F; rank não promove sozinho ao ganhar XP.
3. Banco conserva soma de saldos; rejeita negativos, zero, NaN, infinito, fração e valores acima do limite.
4. Loja rejeita papel incorreto, falta de moedas e compra repetida de equipamento; venda e propriedade registradas; armadura comprada não é equipada.
5. Ferreiro exige propriedade, moedas/minério; melhoria persiste; peça melhorada não é vendida.
6. Missão aceita/abandonada, contadores de conversa, entrega única e promoção manual.
7. Trinta tickets e trinta contratos distintos; dungeons não compartilham ticket; entrada desativada não consome; contrato repetível respeita 24 horas.
8. Adaptador futuro simulado: uma admissão pendente, destino/andar incorretos rejeitados, devolução única e confirmação de chegada impedindo devolução posterior. IDs fictícios existem **apenas no teste**, nunca no pacote.
9. Classe básica/evolução, requisitos, registro de magia e serviços futuros; cumprir requisitos sem escolher evolução não concede classe avançada.
10. Recarga de banco/rank/classe/tickets/melhoria/tutorial/retorno, sem nova raça.
11. Produto padrão ID 0 indisponível; preço oficial divergente rejeitado; recibo repetido concede uma vez; resposta perdida após commit resulta em retry sem crédito duplo.
12. Dois jogadores independentes; outro servidor com mesmo usuário bloqueado; callback UpdateAsync repetido e operação concorrente não duplicam saldo.
13. Resposta perdida após depósito congela perfil; recarga recupera o saldo efetivamente gravado.
14. Falha de armazenamento preserva os dados, sem gravação de defaults.
15. Missão de combate só aceita adaptador confiável habilitado no teste, com ID de evento não repetido.
16. Diálogo verifica token, distância e linha de visão; exige confirmação; rejeita replay; ignora preço/comando/recompensa forjados pelo cliente.
17. Cura exige Humanoid ferido/vivo; debita uma vez, cura e fecha pendência; personagem saudável não paga.
18. Interface compartilhada abre/fecha, transmite token/índice e tem botões de pelo menos 44 px. Layout visual e toque reais continuam pendentes.
19. Menus de todos os papéis e ramificações imediatas abrem no host sem iniciar combate, sorteio ou geração de Terrain.

O host oferece DataStore, Marketplace, raycast, scheduler e instâncias **simulados**. Testes de dois jogadores comprovam isolamento de estado no código; não simulam latência/distribuição real do Roblox. As tarefas agendadas de exploração, patrulha e poses precisam de observação no Studio. O mock de raycast não comprova colisão real do mapa; a verificação de caixas do XML é uma checagem independente e o runtime consulta o engine novamente.

## Checklist obrigatório no Roblox Studio

Use o guia de instalação e uma cópia privada de teste. Para DataStore real, siga a seção de persistência; prévia volátil não pode comprovar reconexão. Registre versão do Studio, tamanho do arquivo, Output e resultados sem marcar itens como aprovados antes de executar.

| Item solicitado | Reteste real a realizar |
|---|---|
| 1. Criação | Conferir `Workspace/EldravynNPCs`, sete pastas de cidade/entrada, 66 personagens na base entregue e nenhuma cabeça/junta caída |
| 2. Interação | Caminhar até cada ponto de `LOCATIONS.md`; confirmar pés no piso, porta livre e prompt por E/toque |
| 3. Interface | Abrir/voltar/fechar, Escape, rolagem e orientação retrato/paisagem no emulador; repetir com toque real |
| 4. Diálogos | Conferir nomes/funções, Lore, condições e mensagens sem erros no Output |
| 5. Lojas | Confirmar/cancelar compra; saldo insuficiente; registrar item; vender item permitido; rejeitar peça equipada/aprimorada |
| 6. Moedas | Dois clientes, depósitos/saques, clicar repetidamente e desconectar durante compra; total nunca aumenta indevidamente |
| 7. Missões | Registrar F, aceitar Primeiras inscrições; falar com Seren/Liora; entregar; segunda entrega bloqueada; abandono e exploração salvos |
| 8. Tickets | Comprar andar específico; moedas e quantidade coerentes; obter outro ticket via contrato |
| 9. Separação | Malgorth:1 não vale para FallenSanctum:1; botão de entrada indisponível e nenhum ticket consumido |
| 10. Ranks | Cumprir XP/contratos, pedir promoção a Maelis, reconectar e conferir histórico/rank |
| 11. Classes | Escolher classe, reconectar; completar requisito e evoluir no mestre; troca paga permanece indisponível com ID 0 |
| 12. Melhorias | Comprar arma e minério após contratos; conferir custo, melhorar e reconectar; nível continua registrado |
| 13. Mapa | Comparar a cópia anterior e posterior no Explorer; Terrain/edifícios/ruas não alterados; repetir instalador sem duplicação |
| 14. Multiplayer | **Test → Server & Clients**, dois clientes: menus/recursos independentes e nenhum acesso remoto fora da distância |
| 15. Inicialização | Iniciar apenas bootstrap NPC + inspeção original; não ativar MedievalServer/combate em paralelo; reiniciar servidor sem geração de mapa |
| 16. Futuros | Raça não sorteada, fusão/habilidades indisponíveis, magia não conjura, ticket não teleporta, consumível não aplica efeito |

Teste adicional de cura: na cópia de teste, reduza `Humanoid.Health` pelo servidor sem criar combate; peça cura, confira preço e nova vida. Teste de hospedagem: pague uma estalagem, use Reset/reentre e confirme retorno ao lado do NPC somente com piso livre. Observe patrulhas curtas sem atravessar paredes e até 12 poses locais próximas; meça FPS/RAM no hardware informado.

Não há resultado de teste real de compra de 100 Robux nesta entrega. Para essa validação futura, configure produto oficial real e siga o procedimento de teste de Marketplace do Roblox; clicar no botão não comprova concessão. Nenhuma compra é necessária para validar os demais serviços.
