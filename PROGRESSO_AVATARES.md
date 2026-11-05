# Avatar Style — sessão iniciada em 04/11/2026

Branch: `codex/eldravyn-avatar-style-20261104`. Base `9a6564c`. Pedido vigente: personagens no estilo padrão Roblox, referência de cavaleiro com armadura; temas por NPC/local e modelos de inimigos. A referência é imagem, não arquivo de malha.

- Análise e limites anteriores à implementação em `docs/avatar-style/ANALYSIS.md`.
- Produzidos 66 NPCs temáticos e 14 tipos de inimigo a partir dos catálogos existentes. Malhas/UVs/atlas/PBR originais; cabeças clássicas, rosto na textura, cabelo contínuo e armaduras em relevo. Sem IDs inventados ou uso de modelos pagos.
- Quatro FBX em `assets/avatars/source`, três PNG em `assets/avatars/textures`. Catálogo JSON/Luau gerado pelo mesmo autor. Peças nomeadas por ID e junta para vincular aos rigs existentes.
- Integrador em `delivery-npcs/avatar-style`; registro normaliza os quatro marcadores por arquivo, rejeita scripts/URIs temporárias, mantém os mesmos NPCs e aplica meshes somente após importação real. Suporta Stage 2 e V2 com rollback lógico e preservação das instâncias.
- Inimigos usam o contrato do factory do EnemyService existente. Um hook opt-in de criação visual, sem modificar catálogo/IA/dano/loot/spawns. Não inicia combate na etapa NPC. Cliente compartilhado limitado a dez inimigos e guiado por tags.
- Testes: suíte geral aprovada, 140 compilações Luau, quatro cenários puros de importação, dez cenários Avatar em cada base, runtime/EnemyService em host simulado. FBX reimportados no Blender: 1.162 meshes, 596.334 triângulos totais na biblioteca de 80 modelos, UV/atlas e bounds conferidos. XML/Rojo e hashes preservados.
- Revisadas prévias de geometria real em `docs/avatar-style/previews`. Não são capturas do Studio. Guia, limites, registro PBR, rollback e roteiro de testes documentados.
- 49 arquivos protegidos idênticos; exceção autorizada é EnemyService. Place Stage 2 e pacote V2 anterior mantêm os hashes. GeneratedWorld/Terrain não foram escritos. Economia, missões, dados e funções de NPC não foram reescritos.

**Pendente fora deste ambiente:** importar/publicar os quatro FBX e texturas pelo Importador 3D do Studio na conta do dono, registrar os quatro grupos e executar Apply na cópia. Nenhum asset foi publicado aqui. Verificar engine, física, permissões, materiais, poses, multiplayer e FPS no Windows 11/celular. Sem Studio ou Defender executados, sem garantia de ausência de alerta.

Continuidade: leia `docs/avatar-style/README.md` e `TESTS.md`. Não regenerar o continente nem sobrescrever entregas anteriores. Reproduzir com `build_avatar_assets.py`, `verify_avatar_assets.py`, `check.py`, `build_avatar_package.py`. Assets reais importados são necessários; não substituir a ausência deles por bonecos genéricos ou IDs fictícios.
