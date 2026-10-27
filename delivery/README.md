# Eldravyn: Rise of Shadows — download para Windows 11

**Histórico: alerta do Defender em investigação.** Este ZIP 0.6.1 foi reportado como `Trojan:Script/Ulthar.A!ml` e permanece preservado sem alterações para rastreabilidade. Não foi confirmado falso positivo. Consulte o [relatório](../docs/SECURITY_REVIEW_0.6.1.md) e a [entrega mínima separada](../delivery-minimal/0.6.1/README.md), também sem homologação de antivírus. Não desative a proteção ou libere um arquivo bloqueado.

[Baixar RPG-Roblox-Windows11.zip](https://github.com/fernando-vaccari/RPG-Roblox/raw/refs/heads/codex/rpg-quality-delivery-20261024/delivery/RPG-Roblox-Windows11.zip)

Se o download direto não iniciar, abra RPG-Roblox-Windows11.zip nesta pasta e use **Download raw file** no GitHub. Entre na sua conta se o repositório exigir autenticação.

Entrega **0.6.1**, com correção de `ReadVoxels` no continente/dungeon/expedições. [Diagnóstico e reteste](../docs/READVOXELS_FIX.md). O ZIP contém código, catálogos, documentação e os dois Places `.rbxlx` compilados. **O cenário precisa ser gerado uma vez no editor e salvo antes de Play.** Siga [COMO_JOGAR_NO_STUDIO.md](../COMO_JOGAR_NO_STUDIO.md):

1. Extraia o ZIP e abra `RPG-Roblox/build/ProjectMedievalRPG.rbxlx` no Studio.
2. Fora de Play, execute na Command Bar:

   ```lua
   require(game.ServerStorage.MedievalWorldgen.WorldGenerator).PrepareStudio()
   ```

3. Aguarde a conclusão, salve como uma cópia nova e clique Play.

A preparação padrão permite uma prévia sem APIs e sem salvamento. Testes reais no Roblox permanecem pendentes em [TESTES_STUDIO.md](../TESTES_STUDIO.md). Compras seguem desativadas; o jogo não foi publicado na Roblox. Confira o estado atual em [PROGRESSO.md](../PROGRESSO.md).

Checksum em SHA256SUMS.txt.
