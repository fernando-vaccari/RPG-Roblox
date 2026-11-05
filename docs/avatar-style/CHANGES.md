# Arquivos e preservação — Avatar Style

Base: `9a6564c`, V2 publicada. Branch `codex/eldravyn-avatar-style-20261104`. A mudança atende à nova referência de avatar Roblox e acrescenta visuais aos inimigos existentes.

## Malhas e arte

- `scripts/avatar_geometry.py`: modelagem original em studs, volumes arredondados, cortes de roupa, cabelo, heráldica, armaduras, armas/adereços e criaturas. Os objetos são reunidos por peça do rig.
- `scripts/build_avatar_assets.py`: atlas 1024² original, UVs, PBR, FBX com textura embutida e renderização no Blender. O catálogo NPC/inimigo é lido do projeto existente, não redefinido.
- `assets/avatars/source/`: quatro FBX com 66 personagens e 14 tipos de inimigo; `CATALOG.json` registra nomes, funções, cidades e juntas.
- `assets/avatars/textures/`: atlas de cor, metal e rugosidade.
- `scripts/verify_avatar_assets.py`: reimporta cada FBX no Blender e compara nomes, bounds, UVs e atlas.
- `scripts/compose_avatar_previews.py`: pranchas rotuladas dos renders reais, sem substituir geometria por ilustração conceitual.

## Integração modular

- `src/avatar/shared/AvatarCatalog.luau`: contrato gerado entre exportador/importador, nomes de meshes, origem e rigs; não contém preços/recompensas ou IDs publicados.
- `shared/ImportFrame.luau`: valida unidades/eixos, coordenadas finitas e formato das URIs; rejeita espelhamento, escala desigual e marcadores inválidos.
- `install/RegisterImported.luau`: clone sanitizado das importações do Studio e configuração PBR, sem downloads ou execução de scripts importados.
- `install/AvatarAppearance.luau`: conecta meshes aos corpos R15 existentes e preserva instâncias, pose e escala.
- `install/CoreVisualFactory.luau`: adapta o factory de aparência ao instalador V2 existente; os controladores V2 e suas fontes são reutilizados.
- `install/Upgrade.luau`: aplicação/reversão Stage 2 ou V2, backup, detecção de instalação parcial e proteção de Sources personalizados.
- `server/EnemyFactory.luau`: rig R15 oculto, meshes e juntas quadrúpedes quando necessário; devolve o mesmo contrato `(Model, Humanoid, Root)` ao serviço existente.
- `client/EnemyAnimationClient.luau` e `Bootstrap.client.luau`: único scheduler cosmético com até dez inimigos, cache, tags e limpeza. Não envia intenção de combate nem inicia IA.
- `install/EnemyServiceBaseline.luau`: cópia exata do Source anterior, usada para validar e guardar a adaptação.
- `avatar-style.project.json` e `scripts/build_avatar_package.py`: integrador passivo, hashes e verificação XML/Rojo. As malhas publicadas são obtidas das importações reais do dono do jogo.

## Uma alteração no gameplay existente

Em `src/server/Services/EnemyService.luau`, a chamada de criação do rig escolhe `EldravynEnemyAvatarLibrary.Factory` se a biblioteca registrada estiver pronta; caso contrário mantém o factory anterior. O restante do arquivo é preservado. Nenhum valor de vida/dano/XP/loot, alvo, missão, callback, spawn ou lógica de IA é alterado.

O instalador compara esse módulo com o Source baseline conhecido ou com o adaptado antes de trocá-lo. Uma customização desconhecida aborta a operação antes de mudar os NPCs. O objeto original fica no backup.

## Demais alterações de desenvolvimento

`scripts/npc_host.py` ganhou montagem opcional Avatar para testes, `scripts/check.py` incluiu os testes novos e `scripts/verify_project.py` exclui o pacote opt-in dos módulos esperados no build clássico e reconhece a dependência opcional do factory. Não há ampliação automática do build clássico com dados de assets ainda não publicados.

`tests/AvatarMock.luau`, `AvatarImport.spec.luau`, `avatar-fixture.luau`, `avatar.integration.luau` e `scripts/test_avatar.py` cobrem contratos/segurança de importação e migração. Os IDs sintéticos dos mocks não entram no integrador ou nos FBX.

49 dos 50 arquivos protegidos da inspeção V2 permanecem idênticos; a única exceção autorizada é o hook visual em EnemyService. O Place Stage 2 inteiro e o pacote V2 anterior continuam com os mesmos SHA-256. GeneratedWorld, Terrain, construções, PlacementConfig, diálogos, lojas, persistência, raças/classes e missões não foram reescritos. Entregas anteriores não foram sobrescritas.
