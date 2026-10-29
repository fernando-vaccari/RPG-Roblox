# Abrir o continente — Tarefa 01

**Uso não recomendado por enquanto:** o ZIP deste mapa também foi bloqueado pelo Defender como `Trojan:Script/Ulthar.A!ml`. Não execute o arquivo bloqueado. Aguarde a investigação descrita em [docs/MAP_DEFENDER_ALERT.md](docs/MAP_DEFENDER_ALERT.md); os passos abaixo são referência de preparação para depois da análise de segurança.

A entrega é exclusiva do cenário. O Place contém cidades, florestas, estradas, pontes, entradas externas, iluminação e pontos de integração já serializados. O **Terrain nativo ainda precisa ser materializado no Studio**; o avatar de inspeção aguarda essa etapa. Não há combate, NPC funcional, missões, economia ou interiores de dungeon novos neste Place.

1. Mantenha o Defender ativo. O alerta anterior continua sem veredicto; esta entrega não tem homologação de antivírus. Se houver bloqueio, não libere o arquivo: submeta à Microsoft conforme docs/SECURITY_REVIEW_0.6.1.md.
2. Extraia a entrega e abra `Eldravyn-Continent.rbxlx` no Roblox Studio. Salve uma cópia com outro nome; mantenha seu mapa anterior separado.
3. **Fora de Play/Run**, abra Output e Command Bar. Execute:

   ```lua
   require(game.ServerStorage.MedievalWorldgen.WorldGenerator).PrepareStudio()
   ```

4. Aguarde o preflight e a escrita dos 1.024 chunks. A geometria existente não é regenerada. Nenhum Terrain/objeto externo é apagado para forçar a geração. Se houver erro antes da escrita, leia o Output; se houver escrita parcial, reabra a cópia anterior à geração.
5. Após `[Eldravyn] Continente preparado`, **salve novamente**, feche/reabra a cópia e clique Play. O avatar padrão começa na praça de Valoria; use os controles nativos do Roblox para caminhar.
6. No painel de inspeção, alterne Baixo/Médio/Alto/Automático e os sete presets de ambiente. Os presets Chuva/Tempestade são preparação atmosférica; não há simulação de eventos climáticos ou de gameplay.

Para gerar do código usando ferramentas já instaladas: `python3 scripts/bake_continent.py`. Para sincronizar: `.tools/bin/rojo serve map.project.json` (Windows: `.tools/bin/rojo.exe`). Não use default.project.json para a inspeção isolada: esse é o projeto legado do RPG.

O comando de preparação no Studio é indispensável: o build offline não contém os voxels de Terrain. Não foi possível abrir o Studio neste ambiente. Execute o checklist em PROGRESSO_MAPA.md; arquitetura, relevo, navegação, renderização e FPS reais continuam pendentes.
