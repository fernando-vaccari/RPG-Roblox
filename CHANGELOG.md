# Changelog

## Entrega mínima 0.6.1 — alerta de segurança em investigação

- Recebido alerta `Trojan:Script/Ulthar.A!ml` no ZIP completo; causa não identificada e sem confirmação de falso positivo.
- Inventário estático/estrutural dos 106 membros, origens/hashes conferidos e relatório de limitações; antivírus/Studio não executados.
- Entrega separada em delivery-minimal/0.6.1: ZIP de somente dois Places, arquivos individuais, hashes e relatório fora do ZIP.
- Places reconstruídos idênticos aos anteriores; nenhum código de jogo removido/alterado. Pacote anterior preservado.

## 0.6.1 — proteção de Terrain / ReadVoxels — 27/10/2026

- Corrigida iteração do metadado `Size: Vector3` retornado junto das matrizes de ReadVoxels.
- Verificador numérico X/Y/Z compartilhado pelo continente, dungeon legada e expedições; mantém recusa de sólido/água parcial antes de escrever ou criar cenário.
- Mock agora inclui Size nas duas tabelas e reproduz o erro antigo; seis fluxos adicionais cobrem bordas, respostas malformadas, último chunk/andar e preservação de dungeon existente.
- Script opcional somente de leitura para teste real no Studio; guia de reteste e relatório de causa. Script compilado, não executado no engine.
- Check completo: 65 Luau, 52 cenários CLI, 42 fluxos simulados e dois Places reconstruídos/verificados. Homologação real continua pendente.

## 0.6.0 — Eldravyn: Rise of Shadows — 26/10/2026

- Nome público atualizado; IDs internos, saves e conteúdos legados preservados.
- Parry frontal, postura/quebra, crítico moderado e windup de ataques comuns; resolução de golpe separada da IA.
- Cinco cidades de 26 edifícios, terceira floresta, guilda externa, lago/cascata, marcos e falas regionais.
- Duas expedições de 10/20 andares, seis ambientes, recompensas/baús condicionados, derrota, tickets persistentes e espera de grupo.
- Tutorial por ações, personagem/classe inicial, armadura explícita, compatibilidade de armas, ranks e 10 missões de aventura/defesa.
- Interface responsiva, hotbar com mira touch, menus de expedição, carga/morte e feedback de combate.
- Correções: payload de UI; travessa nas portas; parâmetro de grupo ocultando dungeon; flags de chefe bloqueando replay; IDs negativos do Studio; fragmentos de pisos aninhados; recuperação de transferência sem recarregar perfis intactos.
- PrepareStudio prepara e valida no editor, com prévia local sem APIs; dois builds, manifesto de estrutura, guia Windows e checklist real.
- Studio, visuais, física, multiplayer/serviços reais e benchmarks continuam pendentes.

# Histórico

## 0.1.0 — Fase 1

Adicionados projeto Rojo, configuração, núcleo matemático, gerador de Terrain para editor, reservas de regiões, spawn, proteção contra área ocupada, relatórios, instaladores Linux/Windows, testes e documentação. README original preservado na primeira linha e expandido. Sem publicação, commits ou envio ao GitHub nesta sessão.

## 0.2.0 — Continuação fases 2–11

Fase 1 estendida com rio/rotas/pontes, 60 lotes medievais/4 cidades, florestas, NPCs R6, conteúdo/interações, economia/missões/combate/IA, dungeon separada, grupos, DataStore opcional e UI. Adicionadas regenerações seletivas com arquivo de objetos anteriores, testes puros/mock, verificação de builds/referências, documentação Windows e pacote distribuível. Sem publicação/Git push. Homologação Studio e serviços reais permanece pendente.

## 0.3.0 — Recursos, habilidades e campanha

Combate existente ampliado, AbilityConfig/CombatRules, progressão 1–100, 24 habilidades (12 magias), 35 missões, bosses florestais e fases, venda/desequipar/materiais, marcadores persistentes de escolha gratuita, HUD e controles desktop/toque. Catálogos/controles/auditoria e WAV próprios incluídos. Testes manuais adiados pelo usuário; sem promessa de homologação Roblox.

## 0.4.0 — Linhagens e ramificações

Sorteio racial persistente, evoluções por desafios com cooldown/retry, seis classes avançadas e habilidades, aparência própria, fragmentos, menu de linhagem, estrutura de fusão sem resultados inventados e processamento oficial de recibos idempotente. Migração sem reset; persistência padrão agora true para evitar reroll volátil. Produtos permanecem desativados. Novos testes CLI/mock e catálogos reproduzíveis.

## 0.5.0 — Correção, refinamento e qualidade

Preservação de dados em saída congelada, leases e envelopes; inventário com quantidade zero corrigido. Projéteis varridos, windup de chefes, campo persistente, limites e cancelamento. Interiores/cavernas/materiais/dungeon refinados, menus/atlas/clima/qualidade e Tester de prévias sem concessões. 40 cenários CLI/21 mock passaram. Relatório em docs/IMPROVEMENTS.md; sem publicação ou compras reais.
