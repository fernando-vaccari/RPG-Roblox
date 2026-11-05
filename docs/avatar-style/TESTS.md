# Testes da revisão Avatar

Os resultados abaixo foram executados neste ambiente Linux. Não são validação de Roblox Studio ou de assets publicados.

## Resultados executados

| Verificação | Alcance e resultado |
| --- | --- |
| Compilação/análise | 140 arquivos Luau compilados; módulos puros analisados. O ajuste final de propriedades físicas do factory de inimigos foi recompilado. Helpers Python com sintaxe validada. |
| Regressão | Suíte anterior de regras, integração simulada, mapa, NPC Stage 2 e V2 aprovada. Ambos os Places clássicos construídos em `build/`, 55 módulos cada, sem dependências/ciclos ausentes. Entregas antigas não sobrescritas. |
| ImportFrame puro | Quatro cenários: coordenadas/unidades/rotação, marcadores inválidos e espelhamento, formato de URI publicada e cobertura dos catálogos. |
| Migração simulada | Dez cenários repetidos sobre Stage 2 e sobre V2: aplicação sem assets, rejeição de script/URI temporária, 80 modelos/normalização, falha injetada/reversão, 66 instâncias preservadas, reaplicação/instalação parcial, 14 inimigos, EnemyService real com factory, limite/limpeza de cliente e rollback. |
| Proteção | Mesmos NPCs/Humanoid/motores/prompts/IDs/posições. Zero writes de voxel no host e construção sentinela intacta. Sources personalizados após instalação impedem rollback automático. |
| EnemyService | Serviço real carregado no host, criado inimigo por seu fluxo de spawn usando o factory opcional; vida/dano/velocidade conferidos contra o catálogo existente; NaN rejeitado e dano válido aplicado. Não é física/combate Roblox real. |
| Rigs inimigos | 14 modelos criados com meshes sintéticos somente nos mocks; R15+Animator, ausência de prompts/ID de NPC de serviço, query de dano e tags. Nenhum novo spawn ou loot definido. |
| Cliente | Dez inimigos selecionados no máximo; 180 passos simulados, remoção por tag e desconexão de callbacks; sem uma segunda IA ou varredura periódica do mapa inteiro. |
| FBX real | Os quatro FBX foram reimportados no Blender 4.3.2: 1.162 meshes nomeados (marcadores à parte), 596.334 triângulos somados em todos os 80 modelos, UVs e atlas presentes. Erro máximo de bounds menor que `0,000007` stud. |
| Pacote | XML e referências, Sources correspondentes ao repositório, dois LocalScripts desabilitados; leitura/regravação Rojo preserva Sources/classes. Sem IDs de mesh fictícios ou meshes vazios apresentados como personagens prontos. |
| Preservação de arquivos | 49 Sources protegidos idênticos à V2; exceção documentada é somente o hook em EnemyService. SHA-256 do Place Stage 2 inteiro e do pacote V2 anterior preservados. |
| Revisão visual | 14 renders de meshes/UV/texturas reais; conferidos formato de avatar, rosto UV sem painel elevado, cabelo, heráldica, personagens e criaturas. Renders offline não validam o resultado no Studio. |
| Download GitHub | Onze arquivos publicados no commit `a162d29f040428cdc237c08b151918a18682bbf0` baixados por HTTP 200 e comparados byte a byte/SHA-256 com os arquivos locais. |

Os IDs positivos dentro dos testes são **sintéticos de um host falso**, nunca baixados, publicados ou incluídos na entrega. Eles não comprovam existência ou permissão de qualquer asset. O integrador entregue exige os MeshParts e imagens realmente importados no Studio do usuário.

Evidências: [suite geral](evidence/full-check.log), [integração Avatar](evidence/avatar-integration.log), [FBX](evidence/fbx-roundtrip.json), [XML/pacote](evidence/package.log), [download GitHub](evidence/github-downloads.json), [manifesto/hash dos arquivos](../../delivery-npcs/avatar-style/MANIFEST.json).

## Reproduzir

Com as ferramentas já configuradas em `.tools/bin`, Blender e Pillow:

```bash
python3 scripts/build_avatar_assets.py
python3 scripts/verify_avatar_assets.py
python3 scripts/check.py
python3 scripts/build_avatar_package.py
python3 scripts/compose_avatar_previews.py
```

`build_avatar_assets.py` regenera apenas as novas malhas, atlas, dados de integração e renders. Não chama geradores do continente. Não execute o builder Stage 2 ou o builder V2 antigo para empacotar esta revisão. O builder V2 anterior preserva hashes da sua própria etapa; a revisão Avatar tem escopo/verificador próprio para a alteração opcional de EnemyService.

## Validação manual pendente — Studio Windows 11

Use uma cópia salva do Place e siga [README.md](README.md).

1. Importe os quatro FBX na conta/grupo dono da Experience, preservando nomes, peças separadas e marcadores. Confira que o importador trouxe cores/UVs e publicou meshes/texturas. Observe limites/cotas e mensagens de moderação/permissão.
2. Registre cada grupo: devem ser 24, 20, 20 e 16 modelos. Confira escala, frente/eixos e alinhamento no preview; não force instalação com erro. `Report()` deve mostrar 80 prontos e nenhum ausente.
3. Confira PBR no Studio. Se metal/rugosidade não forem reconhecidos, publique os três PNG e use `SetPBR` antes de aplicar. Ajuste o lighting da cópia e compare com as malhas; iluminação Blender é diferente.
4. Aplique em Stage 2 e, separadamente, em uma cópia V2. Confira as mesmas 66 instâncias, IDs/atributos, CFrames das raízes, Humanoid, Animator, motores e prompts. O mapa/terreno devem permanecer intactos.
5. Inspecione guarda, guilda, ferreiro, mago, comerciante, estalajadeiro e NPCs de outras cidades/entradas. Confira mãos, rosto, cabeça, cabelo, UVs, ausência de z-fighting, encaixe dos adereços e silhuetas.
6. Teste idle, atenção, cumprimento, diálogo, patrulha e trabalho. Observe armaduras/capas/livros/cajados em movimento; há geometria rígida ligada às juntas, sem simulação de tecido. Verifique interseções e a pausa durante conversa.
7. Teste as funções existentes de diálogo, banco, loja, ferreiro, missões, classe, cura/estalagem e tickets. Nenhuma regra/preço foi alterado; os testes Stage 2 continuam aplicáveis.
8. Crie previews dos inimigos em Edit e confira todos os 14, especialmente lobos/cervo quadrúpedes, slime, esqueletos, demônios e chefes. Apague a pasta de demonstração antes do jogo final.
9. Em cópia onde o combate existente já esteja ativo, teste os spawns existentes. Confira movimento por Humanoid, caminho/colisão, escala de chefe, raycasts nos meshes, vida, dano, parry, kill, loot e avanço de andares. A instalação Avatar não ativa combate na etapa NPC.
10. Use dois clientes, streaming, morte/respawn, distâncias de ativação e Device Emulator. Confira a remoção de conexões/atores e teste depois em celular físico.
11. Meça FPS/memória/MicroProfiler com a mesma qualidade/câmera antes e depois no Ryzen 7 5700U/12 GB. Não deixe os grandes grupos FBX originais de importação no Workspace. Os limites de animação não são prova de desempenho do mapa inteiro.
12. Salve/reabra antes e depois de aplicar. Teste `Rollback()`: Stage 2 deve voltar a Stage 2, V2 deve voltar à sua aparência V2, com objetos/posições originais. Depois reaplique na cópia.

Não foram executados: Roblox Studio/Player, Import 3D Roblox, publicação/moderação/permissão de assets, animações/física/render Roblox, multiplayer real, compras/persistência/teleporte reais, FPS/MicroProfiler, celular físico ou Defender. Uma URI com formato válido não é verificação de permissão; a validação real é indispensável.
