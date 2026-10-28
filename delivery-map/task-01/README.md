# Continente — Tarefa 01

[Baixar Eldravyn-Continent-Task01.zip](https://github.com/fernando-vaccari/RPG-Roblox/raw/refs/heads/codex/eldravyn-map-20261027/delivery-map/task-01/Eldravyn-Continent-Task01.zip)

O ZIP contém somente `Eldravyn-Continent.rbxlx`. [Arquivo individual](https://github.com/fernando-vaccari/RPG-Roblox/raw/refs/heads/codex/eldravyn-map-20261027/delivery-map/task-01/Eldravyn-Continent.rbxlx). Inclui geometria já serializada: cinco cidades, três florestas, duas entradas externas, estradas/pontes, construções, vegetação, pontos de integração e iluminação. Os dois bootstraps são exclusivamente de apresentação do mapa.

**Ainda não é o mapa final:** Terrain nativo, inspeção artística/física e desempenho precisam do Studio. O manifesto registra essas limitações. O avatar não inicia enquanto o Terrain estiver pendente. A tarefa não adiciona gameplay.

1. Abra o Place no Studio e salve uma cópia nova.
2. Fora de Play, execute na Command Bar:

   ```lua
   require(game.ServerStorage.MedievalWorldgen.WorldGenerator).PrepareStudio()
   ```

3. Aguarde o preflight e os 1.024 chunks, salve novamente, reabra e clique Play. A geometria não é regenerada; Terrain/objetos externos são protegidos. Se houver escrita parcial, reabra a cópia anterior.
4. Siga [COMO_ABRIR_MAPA.md](../../COMO_ABRIR_MAPA.md) e o checklist em [PROGRESSO_MAPA.md](../../PROGRESSO_MAPA.md).

[SHA-256](SHA256SUMS.txt) e [manifesto](CONTINENT_MANIFEST.json) ficam fora do ZIP. Conferir hashes prova integridade, não segurança. O alerta anterior do Defender permanece indeterminado. Mantenha a proteção ativa; se houver bloqueio, não libere o arquivo e [submeta à Microsoft](https://www.microsoft.com/en-us/wdsi/filesubmission).

Somente ferramentas gratuitas já existentes e recursos nativos. Nenhum asset pago, publicação no Roblox ou configuração de produto foi realizado. Fontes e instruções de build estão nesta branch; versões anteriores preservadas no histórico.
