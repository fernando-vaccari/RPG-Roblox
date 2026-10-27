# Correção 0.6.1 — ReadVoxels — 27/10/2026

## Causa do erro real

O usuário encontrou no Roblox Studio: `TerrainGenerator:15: attempt to iterate over a Vector3 value`, durante `PrepareStudio → GenerateNewWorld → assertEmpty`.

`Terrain:ReadVoxels(region, 4)` retorna **duas tabelas**, materiais e ocupações. Cada uma contém índices numéricos `[x][y][z]` **e o metadado `Size`, um Vector3 com as dimensões da matriz**. O laço genérico `for _, plane in occupancy do` visitava também `occupancy.Size`; o laço seguinte tentava iterar esse Vector3.

Referência consultada em 27/10/2026: [API oficial Terrain:ReadVoxels](https://create.roblox.com/docs/reference/engine/classes/Terrain#ReadVoxels), [fonte da documentação oficial](https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Terrain.yaml). A documentação descreve as duas matrizes com `Size`, resolução 4 e região alinhada à grade. Não houve execução do Studio nesta investigação.

## Alteração

`TerrainGenerator.assertRegionEmpty` centraliza a verificação somente de leitura:

```lua
local _, occupancy = terrain:ReadVoxels(region, 4)
local size = occupancy.Size -- Vector3, não uma camada da matriz
for x = 1, size.X do
    for y = 1, size.Y do
        for z = 1, size.Z do
            assert(occupancy[x][y][z] == 0, "Terrain existente")
        end
    end
end
```

A implementação também recusa dimensões ausentes, não positivas ou não inteiras. Células ausentes/inesperadas impedem a geração. Qualquer ocupação diferente de zero, inclusive água parcial, continua bloqueando a escrita.

O mesmo padrão incorreto foi encontrado e substituído em **DungeonInteriorGenerator** e **ExpeditionGenerator**. A busca em `src` confirmou que agora existe uma única chamada a `ReadVoxels`, no verificador compartilhado. `WriteVoxels` continua escrevendo apenas matrizes criadas pelo gerador, após o preflight completo. As verificações de Parts, locks, cancelamento e terreno parcialmente escrito foram mantidas. Não houve alteração da geografia, configuração dos saves, gameplay ou do mapa do usuário; nenhuma limpeza global de Terrain foi introduzida.

## Verificações realmente executadas na nuvem

1. **Regressão negativa:** atualizamos o mock para incluir `Size: Vector3` nas duas tabelas e proibir iteração de Vector3. Antes de corrigir o código de produção, `python3 scripts/integration.py` falhou com a mesma mensagem `attempt to iterate over a Vector3 value`, em `assertEmpty`. O mock anterior omitia esse metadado e por isso não detectava o problema. Logs locais em `build/readvoxels-before-fix.log`.
2. **Após a correção:** `python3 scripts/check.py` terminou com código 0: **65 arquivos Luau compilados**, análise das regras/configurações puras, **52 cenários CLI** (51 casos nomeados + cenário integrado de planejamento com duas mensagens), **42 fluxos de integração simulada**, dois builds Rojo e verificação XML/dependências/serviços. Logs locais em `build/check.log` e `build/integration.log`.
3. **Novas regressões:** região vazia 2×3×4 com `Size` em ambas as tabelas; 48 combinações de sólido/água parcial em cada coordenada; respostas malformadas; água somente no último chunk antes de qualquer escrita; água no último andar e na dungeon legada antes de criar cenário; adição de expedições recusada sem alterar dungeon existente. Os demais fluxos de jogo continuam passando no host simulado.
4. **Builds:** `ProjectMedievalRPG.rbxlx` e `ProjectMedievalRPG_Dungeon.rbxlx`, cada um com os 48 ModuleScripts, Script e LocalScript nos serviços esperados. O ZIP é submetido a CRC/nomes únicos e hashes SHA-256; manifesto e checksums acompanham a entrega.

O mock usa matrizes compactas nas verificações de orquestração e uma matriz 2×3×4 no teste direcionado. Não simula 56 milhões de voxels, física nem o agendamento do engine. O script opcional abaixo foi **compilado, mas não executado aqui**. Compilação, mock e inspeção XML não confirmam que a geração real terminou no Studio.

## Como testar novamente no Roblox Studio

1. Baixe o ZIP **0.6.1**, extraia em uma pasta nova e feche o Place antigo, para não testar módulos antigos já carregados. Preserve seus mapas salvos. Abra `build/ProjectMedievalRPG.rbxlx` do novo pacote e salve como outra cópia.
2. Opcionalmente, fora de Play, cole o conteúdo de [scripts/TestReadVoxels.command.luau](../scripts/TestReadVoxels.command.luau) na Command Bar. Ele consulta **o Terrain real** em uma região 2×3×4, confere os dois `Size` e testa o verificador. Não escreve nem remove voxels, mesmo se houver Terrain nessa região. Deve imprimir `[Eldravyn] PASSOU ReadVoxels real...`.
3. Fora de Play, execute:

   ```lua
   require(game.ServerStorage.MedievalWorldgen.WorldGenerator).PrepareStudio()
   ```

4. Confira os 1.024 chunks do preflight, depois as nove etapas até `[Eldravyn] Cenário preparado`. O erro de iteração de Vector3 não deve reaparecer. Aguarde terminar, salve, feche/reabra a cópia e clique Play.
5. Abra também o novo `build/ProjectMedievalRPG_Dungeon.rbxlx`, salve outra cópia, execute `PrepareStudio()`, salve e teste a recepção e expedições. Isso verifica os outros dois caminhos corrigidos.
6. **Proteção do mapa:** em cópias descartáveis separadas dos builds novos, antes de gerar, crie um pequeno volume de Terrain sólido em X=0/Y=20/Z=0 pelo Terrain Editor. Execute `PrepareStudio()`: deve recusar com `Terrain existente`, preservar esse volume e não gerar cenário. Repita em outra cópia com água. Não faça esse teste em cima de seu mapa pronto; não apague Terrain ou pastas para forçar a geração.
7. Registre commit/versão, versão do Studio e o Output completo. Caso a execução anterior tenha escrito Terrain parcial, reabra a cópia anterior à geração; não tente regenerar sobre ela.

**Status de homologação:** correção implementada, regressão reproduzida em mock e builds verificados; confirmação no Roblox Studio ainda pendente. A próxima tarefa é executar os passos 2–6 no Windows 11 e, em seguida, [TESTES_STUDIO.md](../TESTES_STUDIO.md).
