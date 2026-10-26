# Eldravyn: Rise of Shadows — estado de 26/10/2026

## Resultado atual

Versão 0.6.0 implementada sobre o commit `915588c`, com dois Places Rojo e o histórico preservados. Nome público atualizado; ProjectId `ProjectMedievalRPG`, DataStore `MedievalRPG_v1`, equipamentos, missões e identidade legados permanecem compatíveis.

**Builds e verificações da nuvem passaram. Roblox Studio não foi executado.** O pacote fornece um processo completo de preparação: abrir o `.rbxlx`, executar `PrepareStudio()` no editor, salvar a cópia e clicar Play. Os builds não contêm Terrain/cenário pré-gravado; não confundir build de scripts com cena executada.

## Etapas concluídas em código

1. **Auditoria/fundação:** revisados os módulos e alterações; migração aditiva de tutorial, armadura, ranks e expedições. Recibos, locks e falhas conservadoras anteriores mantidos.
2. **Combate/personagem:** parry frontal de 0,24 s, bloqueio sem renovar janela ao segurar, postura/quebra/recuperação, crítico 8% ×1,35, windup de ataques comuns, resolução temporal separada da IA, tutorial ligado a ações reais, escolha inicial única, armas por classe e armadura equipada explicitamente. 48 habilidades e cinco raciais preservadas.
3. **Mundo/NPCs:** cinco cidades/130 lotes, terceira floresta de Véspera, guilda fora de Valoria, caminhos/praças/marcos, Lago das Memórias/cascata e falas regionais dos moradores. Conteúdo legado preservado; alterações de geografia exigem gerar numa cópia nova.
4. **RPG:** 15 missões principais, 20 secundárias, 10 de aventura; ranks F–S por XP e missões; capacidade/stack de inventário; duas fronteiras com evento de defesa e recompensa idempotente.
5. **Dungeons:** sete salas legadas mais Abismo 10 andares/Santuário 20 andares, seis ambientes, encontros variados e chefes; portais/baús condicionados; solo/grupo até quatro; derrota; melhor andar/primeira conclusão; tickets persistentes e reunião dos jogadores antes de iniciar. Novas tentativas começam no andar 1, sem duplicar recompensa de avanço.
6. **Cliente/integração:** nome Eldravyn, menus de personagem/tutorial/expedição, hotbar/mira touch, HUD de postura, notificações, carregamento/morte, poses e avisos de combate. Ajustes de áreas móveis e remoção de hotbar nativa duplicada. Leitura correta de compras/horário do payload.
7. **Preparação/entrega:** `PrepareStudio()` reconhece o papel do Place, gera/valida uma vez e ativa prévia local sem APIs; preserva mapas existentes. Guias Windows/Studio, checklist, catálogos, dois `.rbxlx`, manifesto e ZIP.

## Erros reproduzidos e corrigidos

- Campo de raio ausente no planejamento usado pelas defesas urbanas.
- Variável de membro ocultava o identificador da dungeon e impedia iniciar grupos.
- Travessa frontal colidível passava pela porta de edifícios.
- Flag de Malgorth derrotado podia bloquear o chefe numa segunda expedição.
- IDs negativos dos clientes do Studio eram recusados pela regra de grupo.
- Fragmentos não reconheciam inimigos de andares aninhados na dungeon.
- UI procurava horário/compras fora de State; notificação e controles móveis disputavam áreas.
- Recuperação de transferência recarregava também perfis intactos; agora só recupera os liberados/congelados.
- Armas incompatíveis e armadura pela mera posse foram substituídas por validação/equipamento explícito com migração da posse antiga.

## Testes executados

- `python3 scripts/check.py`: **63 arquivos Luau compilados**, análise das regras/configurações, **52 cenários CLI** (51 casos nomeados + planejamento/topologia/perfis) e **36 fluxos de integração simulada**.
- Serviços reais sob host simulado: duas dungeons completas em dupla; replay de Malgorth; quatro clientes locais com IDs negativos; bloqueio de quinto/intruso; tickets e reunião de grupo; morte/derrota; resposta perdida após commit de andar e recompensa única; defesa da cidade; criação/equipamentos/lojas; parry e tutorial; prévia exclusiva de Studio; invariantes anteriores de raça/recibos/dados/projéteis.
- Geração/estrutura em mock: **11.888 Parts, 135 NPCs, 130 lotes, 300 árvores LOW, 15 baús florestais e 30 andares adicionais**. Contagem não é benchmark nem avaliação estética.
- Dois builds com **48 ModuleScripts + um Script de servidor + um LocalScript**, sem referências ausentes/ciclos. Verificados os serviços de destino e marcador World/Dungeon. `build/BUILD_MANIFEST.json` registra hashes e `studio_tested=false`, `scenes_baked=false`.
- ZIP usa teste de integridade CRC, nomes únicos, exclusão de caches/segredos e SHA-256. Conferir hashes entregues em delivery.

## Parcialmente concluído / depende de plataforma

- Qualidade visual: arquitetura/decoração/iluminação/FX implementados, mas beleza, enquadramento, rigs, animações, travessia e colisões não foram inspecionados no engine. Poses são procedurais, não animações profissionais homologadas.
- Persistência, teleporte e recibos: lógica e regressões simuladas cobertas; serviços Roblox reais não homologados. IDs de Place/produtos permanecem 0.
- Raça na prévia fica pendente para evitar reroll temporário. Modo persistente exige APIs e salva a raça uma única vez.
- Áudio original aguardando upload/IDs autorizados; não há reprodução fictícia. Fusões e ofertas indefinidas continuam desativadas sem consumos.
- Desempenho: LOW/streaming/caps implementados; FPS/RAM e tempo de geração no 5700U/12 GB e mobile ainda não medidos.

## Bugs conhecidos e limites

Nenhuma falha restante foi reproduzida nas suítes executadas. Isso não garante ausência de erros no Roblox. A geração é exclusiva do editor; geografia antiga não é sobrescrita. Prévia não salva; dungeon local usa o mesmo servidor de teste e só admite uma expedição ativa. Servidores publicados usam reserva separada. Fusão, áudio publicado e compras oficiais permanecem pendentes por definição/configuração.

## Próxima tarefa exata

Executar [TESTES_STUDIO.md](TESTES_STUDIO.md), começando por abrir/preparar/salvar o continente e testar personagem, tutorial/parry, portas e dungeons solo. Depois dois/quatro clientes, mobile e serviços reais em Experience de teste. Corrigir erros reproduzidos com Output e passos exatos; não reiniciar o projeto. Detalhes de continuidade em NEXT_STEPS.md.

Nada foi publicado no Roblox e nenhuma compra foi ativada. A entrega usa a branch GitHub já autorizada; `main` permanece preservada.
