# Avatares arredondados — rounded-1

Pedido: personagens mais arredondados no estilo de avatar Roblox. Base `ceea116`, branch `codex/eldravyn-rounded-avatars-20261104`.

- Código de geometria ajustado: cabeça cilíndrica, tronco/membros elípticos, mãos/botas e ombreiras curvas, peitoral convexo e relevos projetados. Franja ajustada à testa arredondada. Livros, armas, escudos e temas preservados.
- Mesmos 66 NPCs e 14 tipos de inimigo, mesmos IDs, funções, origens e juntas. 15 meshes por NPC; 1.162 na biblioteca completa. 930.326 triângulos nos 80 modelos fonte.
- Nova entrega em `assets/avatars-rounded` e `delivery-npcs/avatar-rounded`; não sobrescrever a anterior. Atlas/PBR anteriores reutilizados. Projeto `avatar-rounded.project.json`, nome `EldravynRoundedAvatarUpgrade`.
- Revisão marcada no catálogo, backup, Workspace e FBX. Registros rejeitam FBX antigos e reaplicação sobre revisão diferente. Usuários com Avatar anterior aplicado devem fazer rollback pelo pacote anterior e importar os novos FBX.
- Verificações aprovadas: cinco testes geométricos, FBX roundtrip, 140 compilações Luau e suíte de regressão; 11 cenários de importação/migração em cada base (Stage 2/V2). XML/Rojo/Sources e preservação dos arquivos anteriores conferidos. Logs em `docs/avatar-rounded/evidence/`. Studio/FPS/Defender continuam indisponíveis.
- Prévia/comparação da geometria real no Blender em `docs/avatar-rounded/previews`; não são capturas do Studio. Guia e roteiro atualizados.

Continuidade: finalizar registro dos resultados/publicação GitHub, depois validação manual no Studio do dono: importação/publicação dos quatro FBX, registro dos cinco marcadores, Apply, materiais, poses, interação, rollback e FPS. Não regenerar o mapa ou modificar regras do jogo. Não inventar IDs para substituir essa etapa.
