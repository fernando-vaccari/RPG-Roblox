# Materialização do cenário fora do Studio

`python3 scripts/bake_continent.py` constrói a hierarquia de cenário usando os geradores reais de mapa em um host Luau **simulado**. Serializa Models, Parts/WedgeParts, SpawnLocation, placas, luzes, transformações, cores e atributos em `.rbxmx`. O Rojo lê esse arquivo e normaliza os nomes e tipos nativos antes de incorporá-lo ao Place `build/Eldravyn-Continent.rbxlx`.

O arquivo entregue contém instâncias reais serializadas do continente; não é somente uma coleção de scripts de geração. Os scripts de RPG existentes continuam no repositório, mas os únicos bootstraps do Place de inspeção são os de apresentação do mapa. Não são criados NPCs, inimigos, recompensas ou interiores de dungeon.

**Limite material:** o Terrain nativo não está gravado nesse arquivo. Não há um codec de voxels SmoothGrid documentado/suportado na cadeia Python/Rojo utilizada. O exportador não inventa um blob de Terrain e não substitui montanhas por uma base plana. Os atributos `SceneOnly=true`, `TerrainPending=true` e `Status=AwaitingTerrain` preservam explicitamente esse estado. Portanto o mapa ainda não está finalizado nem homologado visualmente.

No Roblox Studio, fora de Play, abra o Place, salve uma cópia e execute:

```lua
require(game.ServerStorage.MedievalWorldgen.WorldGenerator).PrepareStudio()
```

O comando completa somente o Terrain, preservando a geometria pré-construída, após verificar que não sobrescreverá voxels/objetos externos. Salve novamente. Uma falha com escrita parcial exige reabrir a cópia anterior; o gerador não limpa o terreno automaticamente.

Verificações possíveis na nuvem: compilação do exportador Luau; teste de enquadramento binário de atributos/UTF-8/vetores; parsing e canonicalização `.rbxmx` pelo Rojo; tipos e nomes de propriedades pelo API dump; atributos críticos preservados no round-trip; IDs/referências únicos; ausência de Humanoid/ProximityPrompt no cenário; manifesto com hash e flags `native_terrain_baked=false`, `studio_executed=false`, `visual_quality_validated=false`. `--self-test` verifica os formatos, sem executar o engine.

`AttributesSerialize` usa metadados nativos documentados pelo formato [rbxattr](https://github.com/RobloxAPI/rbxattr/blob/06116439a68931d9d591d11ffff77ff982c9947d/spec.md) e pelo [rbx-dom](https://github.com/rojo-rbx/rbx-dom/tree/master/rbx_types/src/attributes). Não é código comprimido ou carregamento externo. Isso não constitui uma liberação de antivírus; o alerta anterior permanece sem veredicto do fabricante.

O manifesto `build/CONTINENT_MANIFEST.json` registra a contagem e o SHA-256 da geração atual. A inspeção de arquitetura, terreno, colisões, cores e desempenho precisa ser executada no Studio e nos dispositivos reais. Contagens de Parts não comprovam FPS ou qualidade artística.
