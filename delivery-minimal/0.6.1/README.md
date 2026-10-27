# Eldravyn 0.6.1 — somente os dois Places

**Alerta em investigação:** o pacote completo anterior foi bloqueado como `Trojan:Script/Ulthar.A!ml`. A revisão não determinou a causa e esta entrega **não tem liberação do Microsoft Defender**. Leia o [relatório de análise](../../docs/SECURITY_REVIEW_0.6.1.md).

[Baixar Eldravyn-0.6.1-Places.zip](https://github.com/fernando-vaccari/RPG-Roblox/raw/refs/heads/codex/rpg-quality-delivery-20261024/delivery-minimal/0.6.1/Eldravyn-0.6.1-Places.zip)

O ZIP contém exatamente `ProjectMedievalRPG.rbxlx` e `ProjectMedievalRPG_Dungeon.rbxlx`, sem instaladores/auxiliares. Os mesmos arquivos estão nesta pasta para download individual. **São idênticos aos Places do pacote anterior**: reduzir o conteúdo não garante que a detecção desapareça.

Os [hashes SHA-256](SHA256SUMS.txt) e o relatório ficam fora do ZIP. Confira-os mantendo o Defender ativo; hashes verificam identidade, não segurança. Se houver bloqueio, não libere o arquivo nem desative a proteção; [submeta à Microsoft](https://www.microsoft.com/en-us/wdsi/filesubmission) para análise.

O cenário ainda precisa ser gerado uma vez no editor. Se o arquivo estiver disponível para uso sem bloqueio, abra uma cópia nova do continente, fora de Play, e execute na Command Bar:

```lua
require(game.ServerStorage.MedievalWorldgen.WorldGenerator).PrepareStudio()
```

Aguarde a conclusão, salve outra cópia e clique Play. Repita no Place de dungeon. Não há necessidade de instalar Rojo, Python ou PowerShell para essa preparação. A prévia padrão não salva progresso; confira [COMO_JOGAR_NO_STUDIO.md](../../COMO_JOGAR_NO_STUDIO.md). Studio e antivírus não foram executados no ambiente Linux.

A entrega anterior permanece em `delivery/` para histórico. O código do jogo não foi alterado nesta investigação.
