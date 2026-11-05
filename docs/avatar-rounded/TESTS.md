# Verificações — rounded-1

Escopo: arredondar as malhas existentes e distinguir esta revisão no registro/aplicação. Base: `ceea116`. As funções de gameplay não foram modificadas nesta etapa.

## Verificações executadas

- Cinco testes de geometria sobre os vértices exportados: cabeça circular/cilíndrica, seção oval do braço, profundidade curva do peitoral, preservação do catálogo/rig e validade de índices/UVs/orçamento. Não dependem apenas do sombreado da imagem.
- A biblioteca conserva os 80 modelos, os mesmos IDs/funções/origens/juntas e 1.162 meshes. Os JSON de catálogo anterior e arredondado são idênticos. O contrato Luau acrescenta somente `ArtRevision = rounded-1`.
- Os quatro FBX foram reimportados no Blender 4.3.2: nomes, UVs, atlas e bounds conferidos. Total de 930.326 triângulos; erro máximo de bounds menor que 0,000007 stud.
- 140 arquivos Luau compilados; módulos puros analisados. Suíte de regressão aprovada, 11 cenários de importação/migração em cada base (Stage 2/V2) e os dois builds clássicos aprovados. Consulte os logs abaixo para os resultados.
- O registrador rejeita FBX de outra revisão antes de criar templates. O atualizador recusa retornar `Already` quando a revisão aplicada for diferente; exige rollback pelo pacote correspondente.
- XML/referências/Sources e leitura/regravação Rojo do pacote passivo. Dois LocalScripts chegam desabilitados, sem ativação automática de scripts importados.
- Hashes dos arquivos da entrega Avatar anterior, incluindo os quatro FBX/PNG/integrador, conferidos pelo builder. Place Stage 2, pacote V2, mapa e fontes protegidas também preservados.
- Comparação visual anterior/arredondado com iluminação/câmera iguais. Corrigida a franja que penetrava na nova testa cilíndrica e deixava pontas isoladas; peitoral/relevos ajustados para acompanhar a curvatura.

Evidências: [geometria](evidence/geometry.log), [suíte](evidence/full-check.log), [FBX](evidence/fbx-roundtrip.json), [pacote](evidence/package.log), [manifesto](../../delivery-npcs/avatar-rounded/MANIFEST.json).

## Arquivos alterados

`scripts/avatar_geometry.py`: perfis elípticos, fillets curvos, peito convexo, ombreiras, luvas, botas, cabelo e coordenadas de relevo. Mesmos pontos de rig e materiais.

`scripts/build_avatar_assets.py`, `verify_avatar_assets.py`, `compose_avatar_previews.py`, `build_avatar_package.py`: geram/verificam a nova pasta `assets/avatars-rounded`, o projeto/pacote `avatar-rounded` e as prévias separadas. Os arquivos antigos permanecem intactos. A opção `--export-only` refaz somente exportações; `--preview-only` renderiza para revisão sem substituir FBX.

`src/avatar/shared/AvatarCatalog.luau`, `install/RegisterImported.luau` e `install/Upgrade.luau`: identificação da revisão e proteção contra mistura/sobrescrita de outra instalação. Testes atualizados para os marcadores e a reaplicação; teste Python novo em `scripts/test_avatar_geometry.py`. Nenhum módulo de combate/dados ou código do mapa alterado nesta etapa.

## Reproduzir

```bash
python3 scripts/build_avatar_assets.py --keys NPC_Arkheim_Ambient_Guard NPC_Valoria_GuildMaster NPC_Valoria_Blacksmith NPC_Valoria_Magic NPC_Eldoria_General NPC_Durakh_Inn ENEMY_Demon ENEMY_Knight ENEMY_Skeleton ENEMY_Wolf ENEMY_Malgorth ENEMY_SylvarinBoss ENEMY_Slime ENEMY_NoctharBoss
python3 scripts/test_avatar_geometry.py
python3 scripts/verify_avatar_assets.py
python3 scripts/check.py
python3 scripts/build_avatar_package.py
python3 scripts/compose_avatar_previews.py
```

Requer ferramentas `.tools/bin`, Blender e Pillow. Os builders atuais usam as pastas arredondadas. Para reproduzir exatamente a versão anterior, use o commit dela; não redirecione o builder atual para sobrescrever a entrega antiga.

## Pendente no Roblox Studio

Importe os novos FBX e texturas na conta proprietária e registre os cinco marcadores; verifique se a seleção do Model mantém a hierarquia/nome das peças. Teste rejeição do FBX anterior e a proteção de revisão aplicada diferente em cópias de teste.

Confira no engine cabeça, mãos, cintura, ombros e peitoral, principalmente durante cumprimento, leitura, trabalho e caminhada. Observe interseções de armadura/capa/cabelo, materiais e UVs. Salve/reabra e teste rollback/reaplicação em Stage 2 e V2. Repita as verificações de diálogos e serviços, dois jogadores, streaming, inimigos e desempenho do [roteiro anterior](../avatar-style/TESTS.md).

Roblox Studio/Player, permissões/publicação de assets, física/rede reais, FPS/MicroProfiler, celular físico e Defender não foram executados. As prévias Blender e testes simulados não aprovam esses itens.
