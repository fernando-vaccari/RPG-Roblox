# NPC Overhaul V2 — retomada de 31/10/2026

Base preservada: `0f21f59`, NPC Stage 2, 66 personagens R15. Branch: `codex/eldravyn-npc-overhaul-v2-20261031`. Pedido integral e análise prévia em `docs/npc-v2/`.

- Análise real concluída: inspeção XML, identidades/posições e hashes dos sistemas protegidos registrados em `INSPECTION.json`.
- Camada visual implementada e revisada em prévias offline: 25 profissões, paletas por cidade, cabelo/rosto, roupas, armaduras e utensílios nativos; 5.467 adornos em 66 NPCs, máximo 100 por personagem. Sem asset externo obrigatório.
- Controles implementados: poses procedurais, atenção limitada, cache de tracks opcionais, orçamento visual, um scheduler servidor de patrulhas, prioridade das sessões existentes de diálogo. Somente três hooks opt-in nos scripts V1.
- Atualizador implementado: validação prévia, atualização das mesmas instâncias, backup lógico, rollback e reaplicação. Não chama geradores ou instalador de mapa.
- Testes executados: 126 compilações Luau; suíte anterior aprovada; construção de 66 visuais, 10 cenários de migração e 12 de controle no host simulado. Integração com bootstrap/dialogue/prompts V1, múltiplos interlocutores e limites com 120 NPCs simulados. Logs em `docs/npc-v2/evidence/`.
- Preservação conferida: 50 fontes protegidas e Place Stage 2 inteiro idênticos; hash separado de GeneratedWorld; baselines iguais aos scripts originais do XML. XML/Rojo da entrega anterior e do pacote V2 verificados.
- Entrega construída: `delivery-npcs/visual-v2/Eldravyn-NPC-Overhaul-V2.rbxmx`, 17 módulos e um template LocalScript desabilitado. Manifesto/SHA e guia completo de instalação/rollback/assets/testes em `docs/npc-v2/`.
- Revisão visual: cabelo/roupas/corpo corrigidos após conferir geometria real no Blender; oito renders agrupados em duas pranchas. Não são capturas do Studio.
- Publicação concluída: código e pacote no commit `fa9bcccbec1fab5fcd68a441484a35407ca0766f`, na branch indicada. Download do pacote, manifesto e guia conferido por HTTP 200 e comparação byte a byte; evidência em `docs/npc-v2/evidence/github-downloads.json`. Verificação retomada em 04/11/2026 sem alterações no código ou no pacote.
- Próxima etapa: validação manual da cópia no Studio Windows 11 conforme `docs/npc-v2/TESTS.md`. A implementação, os testes disponíveis, a documentação e o pacote de atualização foram entregues.

Roblox Studio, Defender, FPS e rede reais não executados. A validação final no engine permanece necessária; renders offline não equivalem a capturas do Studio. Não recriar o mapa, não executar `build_npc_stage2.py` e não substituir a entrega Stage 2.
