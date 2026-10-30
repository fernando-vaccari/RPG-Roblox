# Próxima tarefa — revisão monumental de 30/10/2026

Continue em `codex/eldravyn-monumental-20261029`, sem recomeçar o projeto. Leia [docs/MONUMENTAL_MAP.md](docs/MONUMENTAL_MAP.md) e [PROGRESSO_MAPA.md](PROGRESSO_MAPA.md). O usuário autorizou exceder 4.000 studs: a revisão implementada tem 6.144 × 6.144, 1.054 lotes, 1.440 árvores LOW, placas frontais, 28 portões e muralhas de 80–104 studs.

Código e artefato: `delivery-map/monumental/Eldravyn-Monumental.rbxlx`, 92.702 BaseParts; geradores incluídos, Terrain nativo pendente. Execute PrepareStudio uma vez no editor, salve/reabra e teste os portões/escadas/placas/ruas/florestas. Registre aparência, FPS/memória e Output no Windows 11; esse teste real não ocorreu aqui. As quatro imagens são prévias geométricas offline do Blender, não capturas do Studio.

Verificações concluídas: suíte geral, integração de mapa após correções finais, Sources/XML/SHA e renderização offline. Corrigidos conflito de estrada/torre em Eldoria, placa atrás da varanda e madeira coplanar. O mapa anterior permanece byte a byte igual. Use os comandos de reprodução do guia; **não execute package_map.py para sobrescrever task-01**.

O alerta Defender anterior continua indeterminado. Não alegar liberação de antivírus, não desativar a proteção e não produzir variantes para escapar da detecção. Havendo novo bloqueio, encaminhar amostra/hash à Microsoft. Não publicar o jogo ou ativar produtos.

---

# Histórico — continente anterior

**Prioridade atual:** nova detecção do Defender também no ZIP do mapa. Leia docs/MAP_DEFENDER_ALERT.md. Não produzir outro arquivo/formato ou alterar código apenas para mudar a detecção; preservar amostra/hash e encaminhar à Microsoft. Sem veredicto, não recomendar uso do artefato. Nenhum antivírus foi executado no Linux.

A solicitação específica Tarefa 01 substituiu o escopo de desenvolvimento amplo durante esta sessão. Leia PROGRESSO_MAPA.md e COMO_ABRIR_MAPA.md. Trabalhe em `codex/eldravyn-map-20261027`, não amplie gameplay.

O Place `delivery-map/task-01/Eldravyn-Continent.rbxlx` contém 20.001 peças de cenário, com `TerrainPending=true`. A próxima ação real é completar o Terrain no Studio, salvar/reabrir, caminhar e capturar dia/noite nas cinco cidades e três florestas, verificando ruas/portas/cavernas/portais. Sem isso a Tarefa 01 não está finalizada. Studio, FPS e Defender não foram executados aqui.

Preserve IDs/dados/versões anteriores. O alerta Defender continua indeterminado; não desative ou contorne a proteção. Entrega do mapa separada e sem instaladores no ZIP. Para validar novas mudanças: `python3 scripts/check.py`, `python3 scripts/bake_continent.py --self-test`, `python3 scripts/bake_continent.py`, `python3 scripts/package_map.py`. Copie apenas o novo artefato da etapa, confirme commit/push remoto. O jogo não foi publicado no Roblox.

# Histórico anterior — Eldravyn 0.6.1

0. Prioridade atual: investigar com a Microsoft qualquer novo alerta `Trojan:Script/Ulthar.A!ml`. Consulte docs/SECURITY_REVIEW_0.6.1.md e delivery-minimal/0.6.1. O ZIP completo anterior permanece preservado; o mínimo contém os mesmos dois Places, sem auxiliares, e não tem liberação de antivírus. Nunca desativar/contornar o Defender. A causa não foi determinada.
1. Leia PROGRESSO.md, COMO_JOGAR_NO_STUDIO.md, TESTES_STUDIO.md e docs/ELDRAVYN.md. Não recomece o projeto. Dois Places, ProjectId `ProjectMedievalRPG`, DataStore `MedievalRPG_v1`, raças e IDs legados foram preservados.
2. Prioridade seguinte: confirmar a correção real de ReadVoxels no Studio pelo procedimento docs/READVOXELS_FIX.md (leitura, geração dos dois Places, proteção sólido/água). O código antigo falhou com o mock contendo Size: Vector3; a correção numérica passa em 42 fluxos simulados, mas isso não valida o engine. Depois executar a matriz curta no Roblox Studio, a partir dos dois `.rbxlx` e do comando `PrepareStudio()`. Salvar cada cenário após geração; o build Rojo contém código e não Terrain pré-gravado. A nuvem Linux não executou o Studio.
3. Começar por spawn/criação, portas/caminhos, tutorial/parry e duas dungeons solo; depois dois/quatro clientes e mobile. Registrar Output e passos para reproduzir antes de alterar os sistemas já cobertos.
4. Prévia usa atributo `StudioSessionPreview=true`, reconhecido exclusivamente no Studio: não salva nem sorteia raça temporária. `PrepareStudio({Persistent=true})` habilita o teste real com APIs em Experience dedicada. Publicado continua exigindo DataStore e IDs oficiais de ambos os Places.
5. Expedições: 10/20 andares estáticos gerados no editor, encontros ativados por andar, uma tentativa por servidor reservado, espera de até 90 s pelo grupo. Melhor andar/recompensa confirmados no portal; nova tentativa começa no andar 1. Sete salas legadas permanecem. Não trocar tickets persistentes por confiança em TeleportData.
6. Não ativar produtos, inventar IDs ou combinações de fusão. Pacote iniciante ~300/troca de classe ~100 são propostas desativadas; 150/79/149 existentes também continuam IDs 0. Sons próprios aguardam upload autorizado; poses procedurais não equivalem a animação profissional homologada.
7. Se continuar apenas na nuvem, priorizar novos erros reproduzíveis de API, concorrência e fluxo, sem alegar validação visual/financeira. Benchmarks de 11.888 Parts/135 NPCs/300 árvores são contagem simulada, não promessa de FPS.
8. Depois de mudanças reais: `python3 scripts/check.py`, revisar logs, atualizar PROGRESSO/TEST_RESULTS, `python3 scripts/package.py`; copiar pacote e hashes para delivery. A entrega GitHub nesta branch já foi autorizada; não alterar main ou publicar no Roblox sem instrução específica.

Não usar links /workspace ou sandbox para download: falharam para este usuário. A entrega funcional anterior foi via URL raw do GitHub da branch `codex/rpg-quality-delivery-20261024`.
