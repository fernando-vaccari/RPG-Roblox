# Resultados atuais — continuação fases 2–11

> Estado atual: Eldravyn 0.6.0. Consulte [PROGRESSO.md](PROGRESSO.md) e [COMO_JOGAR_NO_STUDIO.md](COMO_JOGAR_NO_STUDIO.md). As seções anteriores são histórico quando divergirem da versão atual.


## PASSOU na nuvem Linux

- `python3 scripts/check.py`: **37 arquivos Luau compilados**, análise estática dos módulos puros sem diagnósticos e duas compilações Rojo.
- `tests/terrain.spec.luau`: **7 casos**; configurações, cobertura exata de 4000 × 4000, 10201 amostras de relevo/continuidade, plataformas, determinismo, materiais/ocupação e proteção de reservas.
- `tests/gameplay.spec.luau`: **7 casos**; fluxo inicial de rank/arma/missão/classe, preços/saldo, compra duplicada, saque individual, objetivos/recompensas únicas, saneamento de dados e grupo até quatro/confirmados/presença.
- `tests/planning.spec.luau`: **1 cenário integrado**; 60 lotes sem sobreposição, seis rotas contínuas, 42 segmentos de ponte, grafo alcançando quatro cidades, árvores determinísticas, perfis LOW/MEDIUM/HIGH, spawns/baús.
- `scripts/verify_project.py`: dois rbxlx com **27 módulos**, referências existentes, grafo sem ciclos e dois bootstraps sem chamada de geração massiva.
- `git diff --check`: sem problemas de whitespace na verificação final.

## PASSOU em host SIMULADO — não é engine Roblox

`python3 scripts/integration.py`, também chamado por check.py, executa os módulos reais com API/objetos simulados. Log completo: `build/integration.log`.

1. TerrainGenerator real constrói matrizes de ocupação/material de um chunk 32 × 32. WriteVoxels é um método simulado, não serviço do Roblox.
2. WorldGenerator real executa construção de continente: **5305 Parts, 63 NPCs**, contagens estruturais e recusas de Parts/Terrain ocupados/segunda geração. A escrita dos 1024 chunks é substituída por contador neste teste; raycasts também são simulados.
3. Regenerações seletivas mantêm contagens e arquivam objetos anteriores, sem escrita de Terrain.
4. DungeonInteriorGenerator cria salas/corredores, inimigos, baús e portal. Isso não verifica física, jogabilidade ou teleporte.
5. UIControllers constroem todos os diálogos, lojas/grupos, inventário/diário, HUD/minimapa com propriedades conhecidas; sem renderização ou medidas de usabilidade reais.
6. Falha parcial de escrita mantém o lock/diagnóstico e recusa reexecução.
7. DataService real usa UpdateAsync simulado: salva, bloqueia sessão duplicada, congela em falha, não sobrescreve defaults após load falho e recupera o próprio lock.

O host consulta propriedades/classes/enums do API dump público Roblox Client Tracker. Não implementa física, agendamento/rede reais, pathfinding ou garantias de durabilidade do DataStore. Não chamar esses testes de homologação Roblox.

## Falhas encontradas e corrigidas

- Enum.Material.Tile inexistente: substituído por Slate.
- Raio conservador de lotes ampliado para considerar balcões/varandas e acesso externo.
- Recuperação de perfil após erro de teleporte reaproveita token para não bloquear contra o próprio lock.
- Dungeon ganhou preflight de Terrain, além de Parts; não será construída dentro de solo existente.
- Parser de inspeção do build corrigido para o Source serializado como string pela versão atual do Rojo; verificação passou após correção.
- No histórico da fase 1, API de releases GitHub estava bloqueada e o protocolo Rojo foi inicialmente lido como JSON. Downloads oficiais por github.com e protocolo MessagePack resolveram esses diagnósticos sem desabilitar TLS/checksums.

## NÃO TESTADO no ambiente disponível

- Studio e PowerShell no Windows 11, plugin e abertura dos rbxlx no engine.
- Geração real dos 56 milhões de voxels, superfícies/colisões, passagem por portas/pontes, rigs e animação no engine.
- Gameplay real, pathfinding, morte/respawn, interação por teclado/toque e sessões de 2–4 jogadores.
- DataStore real, encerramento concorrente em produção, TeleportAsync/retorno e permissões da Experience.
- Aparência, FPS/RAM/tempo no Ryzen 5700U/12 GB e celulares.
- Publicação do jogo/ambiente, envio ao GitHub e restauração em nova tarefa.

Matriz e procedimentos reais: docs/STUDIO_TEST_MATRIX.md. O código está integrado, mas a homologação final permanece pendente.

## Histórico preservado

A fase 1 tinha sete testes puros e build/API Rojo verificados. Seus módulos e testes foram reaproveitados e continuam no projeto; a entrega atual amplia o mesmo checkout.

## Entrega e configuração

- Smoke da API Rojo reiniciado nesta sessão: passou após iniciar o servidor (a primeira consulta encontrou a porta sem processo, não uma falha do projeto).
- Sources dos módulos nos dois arquivos rbxlx comparados com os arquivos atuais: correspondem exatamente na verificação de entrega.
- Pacote ZIP testado para integridade e ausência de duplicatas/caches Git; SHA-256 dos três artefatos em build/SHA256SUMS.txt.
- install_script e start_skill atualizados no rascunho do ambiente para os testes/builds/pacote atuais. Gravação confirmada; publicação/restore em nova tarefa não foram executados.

## Expansão de combate/campanha — rodada atual

- Compilação/análise e testes da base executados novamente após as mudanças.
- Seis cenários puros adicionais em expansion.spec: nível 1–100/atributos; combo/reset/recovery; custos e cooldowns atômicos; desbloqueio por classe/nível; 15 principais/20 secundárias com fontes de eventos e pré-requisitos acíclicos; venda/escolha gratuita/classe persistida após desequipar.
- Integração simulada dos geradores/UI/DataService permanece separada de engine. Contagem de spawns passou de 12 para 14 com os chefes florestais.
- Combate físico, latência real, aprendizado/efeitos no servidor Roblox, áudio publicado e balanceamento de bosses continuam NÃO TESTADOS. O teste puro de custos não deve ser chamado de teste completo do CombatService em rede.

Resultado final da expansão: **37 Luau compilados, 27 módulos por Place e 21 cenários CLI** (7 terreno + 7 gameplay + 6 expansão + 1 planejamento integrado), além dos sete fluxos mock preservados. Builds dos dois Places concluídos. Catálogos gerados diretamente das configurações. O ZIP inclui três WAV sintéticos próprios, cuja reprodução depende de upload autorizado futuro. Não foram executados testes manuais nesta tarefa.

## Raças e classes — rodada atual (substitui contagens antigas acima)

- Doze cenários CLI novos em identity.spec.luau. Prova exata dos 100 tickets, limites e rejeição de NaN; atribuição uma vez; migração/raça inválida; orçamento de recursos sem bônus de dano por raridade; 86400 s exatos; prazo persistente; retry idempotente; fragmentos não substituem objetivo; seis desafios/classes persistentes; descoberta racial; semanas UTC e créditos; catálogo vazio sem débito; preservação das 24 habilidades/Arqueiro.
- Host simulado executa DataService/PurchaseService reais: callback UpdateAsync repetido, reconexão, save que tenta alterar raça, produto/preço inválido, falha depois de commit com resposta perdida e reentrega do mesmo recibo. Gravação de créditos+recibo permanece única, e replay não reverte Gold obtido/gasto depois.
- Host simulado constrói menu/aparência de todas as raças e executa CombatService real para invocação/cleanup, dreno, cura racial e cooldown; trocar classe não reabastece recursos.
- Cenário de morte durante transação de início racial confirma falha persistida e preservação de recibos.
- Falha inicial dessa ampliação do host: mock não tinha GetPlayers, necessário pelo caminho real de cura. Método de teste adicionado e cenário passou; isso não constitui teste do serviço real Roblox.
- `GetProductInfoAsync`, ProcessReceipt e PromptProductPurchase conferidos no API dump. IDs de fixtures ficam apenas em memória no teste; configuração entregue permanece com zeros.
- Nenhum Roblox Studio, compra real, DataStore real, teleporte real ou benchmark foi executado. Confiabilidade financeira/latência/desligamento real ainda depende da matriz de homologação.

Fechamento atual: **43 arquivos Luau compilados, 33 cenários CLI e 13 fluxos mock passaram**. Os dois Places têm **31 módulos**, sem ciclos ou referências ausentes na inspeção dos builds. Catálogos foram regenerados diretamente das configurações; as 24 habilidades originais permanecem, com 24 técnicas avançadas adicionais e cinco ações raciais. Os números históricos acima se referem às versões anteriores.

## Rodada de qualidade 0.5.0 — contagens atuais

**Passou:** 50 arquivos Luau compilados, 40 cenários CLI, 21 fluxos em host simulado, dois builds com 37 módulos e verificação de referências/ciclos. Novos casos cobrem limites de viagem, aviso de bosses, plano de interiores, preview de benefícios, clima/budget, venda/recompra, recibo com commit incerto seguido de saída, corrupção/lease, projéteis/parede/cancelamento, windup/fases, Tester bloqueado em produção, Campo de Chamas, matrizes do rio, handlers VFX e atlas.

Os cenários estão em tests/quality.spec.luau e na extensão de tests/editor.integration.luau. Foi corrigida a venda que deixava quantidade 0 e a possibilidade de gravar snapshot antigo após congelamento. A estrutura do mapa foi gerada no mock, com 6138 Parts e 63 NPCs. Isso não valida sua aparência ou custo real de renderização.

**Não testado:** renderização/física/navegação real, fluidez de combate/móvel, FPS/RAM no notebook, áudio com assets publicados, DataStore/teleporte/recibos reais. O relatório docs/IMPROVEMENTS.md separa cada implementação da evidência disponível e lista pendências. Nenhuma compra ou publicação foi executada.

## Eldravyn 0.6.0 — 26/10/2026

`python3 scripts/check.py` passou: 63 Luau compilados, análise pura, 52 cenários CLI (51 nomeados + planejamento composto), 36 fluxos mock. Ambos os Places foram construídos com 48 módulos + 2 bootstraps; serviços, papel World/Dungeon e grafo de referências verificados.

Regressões novas: janela/frente/spam de parry, postura/crítico, tutorial sem recompensa inventada, armadura/capacidade/ranks, 30 andares, recompensa única, grupo/tickets persistentes, espera de chegada, dupla até o final de ambas as expedições, replay de chefe, derrota, commit com resposta perdida, quatro clientes negativos/limite e reunião no portal, defesa de cidade e fluxo real de personagem/loja/equipamento. Preparação de editor não reescreve mapa pronto, prévia não acessa DataStore nem substitui persistência publicada.

Contagem mock: 11.888 Parts, 135 NPCs, 130 lotes, 300 árvores e 15 baús florestais; 30 pisos adicionais na dungeon. Teste geométrico detecta travessas nas entradas centrais. UI calcula áreas sem sobreposição de tutorial/toast/hotbar em 667×375, 844×390 e 390×844. Isso não testa pixels, toque ou física.

Manifesto: build/BUILD_MANIFEST.json com `scenes_baked=false` e `studio_tested=false`. Nenhum Roblox Studio/cliente, publicação, compra, DataStore/teleporte real ou benchmark foi executado. Checklist real em TESTES_STUDIO.md.
