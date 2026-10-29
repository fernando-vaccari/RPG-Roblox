# Plano e critérios atuais

> Estado atual: Eldravyn 0.6.0. Consulte [PROGRESSO.md](PROGRESSO.md) e [COMO_JOGAR_NO_STUDIO.md](COMO_JOGAR_NO_STUDIO.md). As seções anteriores são histórico quando divergirem da versão atual.


Pedido integral: docs/REQUIREMENTS.pt-BR.txt. A continuação implementou código das fases 2–11 nesta tarefa, reutilizando a fase 1. **Implementado não significa homologado no Roblox.**

| Fase | Código entregue | Evidência e pendência |
| --- | --- | --- |
| 1 | Rojo/configuração/terreno preservados | Testes matemáticos continuam passando |
| 2 | Máscaras de rotas, rio, pontes, relevo | Topologia/plano CLI; travessia no Studio pendente |
| 3 | 60 lotes e construções medievais/4 cidades | Geração de instâncias em mock; visual/colisão pendentes |
| 4 | Duas florestas, árvores/ruínas/decoração | Densidade determinística CLI/mock; aparência pendente |
| 5 | Entrada + dungeon separada com salas/arena/portal | Estrutura mock; física do interior pendente |
| 6 | 63 NPCs, rigs R6, prompts, diálogos | Construção mock; rig e interação engine pendentes |
| 7 | Lojas/economia/inventário/Rank F | Regras CLI e interface mock; integração engine pendente |
| 8 | Missões/inimigos/combate/baús | Regras/saques CLI; IA/física/combate engine pendentes |
| 9 | Grupo até quatro, solo, confirmação, teleporte configurável | Máquina CLI; teleporte e cooperação reais pendentes |
| 10 | Streaming/LOW/caps/schedulers/regeneração seletiva/testes | Orçamentos/contagens; FPS/RAM e load real pendentes |
| 11 | Documentação, dois rbxlx e pacote Windows | Builds/referências verificados; homologação final pendente |

Não afirmar que todos os critérios finais do jogo foram atingidos. A matriz de testes real está em docs/STUDIO_TEST_MATRIX.md. Substituição global de Terrain, conteúdo profissional de animação e balanceamento final continuam fora da versão inicial.

## Identidade — extensão implementada

Cinco raças com atribuição durável única, evolução por missão, seis ramificações de classes, fragmentos, calendário de tentativas e gateway oficial de produtos estão integrados e cobertos por regras CLI/host simulado. Catálogo/resolvedor de fusões aguarda definição do criador e permanece sem consumo. Ver docs/RACES_CLASSES.md e TEST_RESULTS.md; homologação real não foi executada.

## Qualidade 0.5.0

Aplicadas correções e melhorias transversais, sem reconstrução. Pipeline servidor/cliente de projéteis, windup, mapa/interiores/dungeon, navegação, qualidade local e segurança de dados são descritos em docs/IMPROVEMENTS.md. Contagens atuais: 50 Luau, 40 cenários CLI, 21 fluxos mock, dois Places com 37 módulos. Permanecem homologação real e decisões não aprovadas; não declarar conclusão integral do jogo.
