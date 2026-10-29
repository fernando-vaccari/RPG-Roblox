# Matriz de homologação no Roblox Studio / cliente publicado

> Estado atual: Eldravyn 0.6.0. Consulte [PROGRESSO.md](../PROGRESSO.md) e [COMO_JOGAR_NO_STUDIO.md](../COMO_JOGAR_NO_STUDIO.md). As seções anteriores são histórico quando divergirem da versão atual.


**Todos os casos desta matriz: NÃO TESTADOS no engine nesta entrega.** Não marcar como PASSOU a partir do mock. Registrar versão do Studio, dispositivo, perfil, número de jogadores e resultado real em TEST_RESULTS.md.

| Caso | Procedimento | Resultado esperado |
| --- | --- | --- |
| Instalação Windows | Executar instalador/check.ps1 e plugin | Hashes corretos, três suítes e dois builds concluídos |
| Build aberto | Abrir os dois rbxlx no Studio | Sem erros de deserialize, módulos e dois bootstraps presentes |
| Geração única | Preview e GenerateNewWorld em Place vazio salvo | 4 cidades/2 florestas, rio/pontes, entrada, spawn; Status Complete |
| Proteção Parts | Em Place descartável novo, pôr Part na área antes da geração | Recusa antes de qualquer Terrain escrito, Part permanece |
| Proteção Terrain | Mesmo teste com um pequeno voxel/água | Recusa, voxel preservado |
| Segundo comando | Repetir GenerateNewWorld após concluir | Recusa; mapa idêntico |
| Cancelamento | Marcar CancelRequested enquanto gera, em cópia descartável | Falha parcial diagnosticada; reabrir backup sem apagar mapa antigo |
| Terreno | Percorrer todas as estradas a pé | Sem degraus/abismos não intencionais, margens e pontes transitáveis |
| Prédios | Verificar 60 lotes, portas, balcões e NPCs | Sem sobreposição/bloqueios, terreno sob os edifícios |
| NPCs | E em cada papel/cidade | Nome, diálogo, opções e distância corretos; rigs sem peças caindo |
| Guilda | Registrar duas vezes | Primeira Rank F, segunda não duplica nada |
| Equipamento | Escolher cada arma em perfis de teste separados | Primeira escolha única; ferramenta equipa e ataca |
| Combate | Atacar Bandit com quatro armas, atrás de parede e fora de alcance | Dano só em alvo válido; duas técnicas do cajado |
| Economia | Comprar sem Gold, repetido, distante, item errado | Servidor recusa; saldo/inventário permanecem coerentes |
| Poção/armadura | Comprar/usar repetidamente | Consumo/cooldown corretos; couraça 140 HP máximos |
| Missão principal | Guilda → treino → 3 bandidos → guilda | Gold/XP/classe uma vez; sem entrega antecipada |
| Missões secundárias | Lobos/erva/ruína/Durakh/mago | Objetivos certos; só recompensa uma vez |
| Baú | Dois jogadores abrem o mesmo, depois repetem | Cada um recebe uma vez; não duplica |
| Respawn | Definir cidade em hospedaria e morrer | Retorno à cidade escolhida |
| IA | Entrar/sair do raio, esconder atrás de parede, afastar inimigo | Pathfinding físico, retorno ao território e desativação distante |
| Grupo | 1, 2, 3, 4, tentativa de 5 jogadores | Máximo quatro; líder/confirmados coerentes |
| Presença | Membro afasta, morre, sai ou contexto expira | Entrada recusada; nenhum membro faltante é transferido |
| Teste local | Solo/grupo no guardião do Studio | Mensagem explícita de teste local; mapa X6000, sem teleporte real |
| Dungeon separada | Gerar em segundo arquivo e Play | Salas ligadas, sem pisos/corredores abertos acidentalmente |
| Chefe | Enfrentar Malgorth e tentar baú antes/depois | Vida/dano/derrota/recompensa e trava corretos |
| Retorno local | Portal no teste do continente | Retorna a Valoria; standalone informa usar Stop |
| DataStore load | Experience de teste com APIs habilitadas | Perfil carrega e guarda itens/quest/rank/spawn |
| DataStore falha | Induzir falha controlada em Experience de teste | Operações congeladas; defaults não sobrescrevem dados |
| Concorrência | Reconexão/troca de servidor durante save | Lock evita duas sessões; progresso consistente |
| Teleporte real | Aplicativo Roblox, mesma Experience, IDs reais | Grupo chega ao mesmo servidor reservado; perfis recarregados |
| Falha teleporte | Testar destino indisponível/recusa controlada | Erro informado, perfis recuperados, grupo pode tentar novamente |
| Retorno real | Portal com ReturnPlaceId válido | Retorna ao continente e conserva dados |
| Regeneração | RegenerateCity/Forest/Decorations/NPCMarkers fora do Play | Contagens corretas, backup antigo em ServerStorage, Terrain preservado |
| Geografia alterada | Mudar seed/coordenadas e tentar regeneração seletiva | Recusa, pede outro Place |
| Desempenho | Percorrer cidades/florestas/4 jogadores na dungeon | Medir FPS/tempo/RAM no Ryzen 5700U; ajustar LOW se necessário |
| Streaming/mobile | Testar dispositivo real e entrada/saída de regiões | Sem quedas pelo chão, UI legível, prompts e ataque por toque funcionam |

Itens conhecidos fora da entrega: regeneração global de voxels, editor gráfico de grupos privados/convites, animações R15 profissionais, áudio com assets próprios, balanceamento final, evolução além de Rank F e troca de classe paga. Nenhum desses itens deve ser descrito como validado.

## Identidade — próxima homologação real (NÃO TESTADA)

- Migrar cópia de perfil legado, conferir XP/Gold/itens/35 quests e habilidade antiga preservados; novo sorteio ocorre só se ainda não há raça.
- Primeira entrada com API disponível, resposta perdida após commit e reconexão nos dois Places: mesma raça, sem janela volátil silenciosa.
- Modo volátil explícito: raça pendente; nenhuma compra/atribuição permanente simulada.
- Cada raça e avatar R6/R15: aparência aditiva, R, custos/cooldown e remoção apenas da pasta própria.
- Missão racial: segredo/nível, iniciar, morte, timeout offline, exatos 86400 s, falha de save e morte enquanto transação está em andamento.
- Evolução exige missão + fragmentos; reconexão mantém raça original/evolução separadas.
- Desbloquear seis ramificações, trocar classe sem refil de recursos, herdar habilidades básicas, invocador/drain e arqueiro intacto.
- Fragmentos por contribuidores próximos no interior da dungeon; mesmos inimigos fora dela não dão fragmentos.
- Fusão com catálogo vazio: sem custo e sem resultado; reset semanal mantém créditos comprados.
- Somente depois de configurar produtos reais: metadata/preço, ProcessReceipt duplicado/atrasado, perfil offline, desconexão, indisponibilidade de DataStore e entrega após recarga. Nenhuma homologação financeira foi realizada pelo mock.

## Qualidade 0.5.0 — casos reais ainda NÃO TESTADOS

- Repetir commit com resposta perdida, desconectar e conferir que a saída não grava snapshot sem recibo/crédito.
- Testar envelopes/locks inválidos em cópias de dados e sessão com lease perdido, preservando registros.
- Percorrer interiores, escadas/cavernas, portas, ponte interna e sala secreta; conferir mobiliário sem bloqueios e altura de NPCs/bosses.
- Disparar magias/flechas contra alvo móvel e paredes finas, com latência/streaming; verificar acerto único, alcance, expiração e cancelamento ao morrer/trocar classe.
- Entrar/sair do Campo de Chamas depois do cast e depois de expirar; nenhum dano infinito ou através de paredes.
- Chefes com 1–4 jogadores: HP fixado no spawn, aviso antes do dano, blast/anel com centro seguro, fase e interrupção coerentes.
- Testar menus/atlas/texto autoajustável em celular, gamepad/PC e diferentes resoluções; recarga no botão e movimento reduzido.
- Medir LOW no Ryzen 5700U/12 GB; conferir que efeitos distantes não tocam som nem gastam budget local e que LOW não cria chuva.
- Tester em produção deve sempre negar; preview em Studio opt-in não concede nenhum benefício ao perfil real.
