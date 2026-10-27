# Eldravyn: Rise of Shadows

Action RPG medieval/anime no projeto **RPG-Roblox**, preservando os dois Places, o DataStore `MedievalRPG_v1`, as raças, classes e conteúdos anteriores.

**Alerta de segurança em investigação:** o ZIP completo 0.6.1 foi bloqueado pelo Defender como `Trojan:Script/Ulthar.A!ml`. A causa não foi determinada; não há confirmação de falso positivo. [Relatório e limitações](docs/SECURITY_REVIEW_0.6.1.md), [entrega separada contendo somente os dois Places](delivery-minimal/0.6.1/README.md). Essa entrega não é uma liberação de antivírus.

**Atualização 0.6.1:** corrigida a iteração de `ReadVoxels().Size` no continente, dungeon e expedições. Consulte [diagnóstico e reteste no Studio](docs/READVOXELS_FIX.md). A confirmação no engine ainda está pendente.

**Abra primeiro [COMO_JOGAR_NO_STUDIO.md](COMO_JOGAR_NO_STUDIO.md).** O pacote contém os dois arquivos `.rbxlx` construídos pelo Rojo. O cenário deve ser materializado **uma vez no editor** e salvo antes de Play; ele não está pré-gravado nos builds. Este ambiente Linux não executa Roblox Studio.

## Abrir no Windows 11

1. Extraia o ZIP e abra `build/ProjectMedievalRPG.rbxlx` no Roblox Studio.
2. Fora do Play, abra **Command Bar** e **Output** e execute:

   ```lua
   require(game.ServerStorage.MedievalWorldgen.WorldGenerator).PrepareStudio()
   ```

3. Aguarde a conclusão e salve como **uma cópia nova** `.rbxl` ou `.rbxlx`.
4. Clique **Play**. Escolha a classe no menu Personagem e siga o tutorial.

A preparação ativa uma **prévia local sem salvamento**, para jogar sem configurar APIs. A raça fica pendente nesse modo, evitando sorteios descartáveis. Para testar o personagem permanente, siga a seção de persistência do guia. O atributo de prévia nunca desativa DataStore fora do Studio.

O mesmo comando prepara `build/ProjectMedievalRPG_Dungeon.rbxlx`: sete salas legadas e as duas novas expedições. Nenhum mapa ocupado é apagado; geografia antiga exige gerar numa cópia nova. Não repita a geração apagando apenas a pasta `GeneratedWorld`.

## Conteúdo implementado

- Continente de **4000 × 4000 studs**; Valoria, Arkheim, Eldoria, Durakh e Asterion, com **26 edifícios por cidade**. A sede da guilda de Valoria fica fora da muralha. Casas com estruturas de madeira, telhados, interiores, lojas e caminhos; castelos, mercados, praças e marcos regionais.
- Sylvarin, Nocthar e Véspera: árvores, cavernas, ruínas, recursos de missão, inimigos, chefes e 15 baús. Rio, pontes e Lago das Memórias com cascata.
- **Abismo de Malgorth: 10 andares**; **Santuário do Reino Caído: 20 andares**. Seis tipos de ambiente, chefes a cada cinco andares, portais condicionados, baús individuais, derrota e progresso persistido. Solo ou até quatro jogadores.
- Combos, pesado, parry frontal de 0,24 s, bloqueio, postura/quebra, esquiva, stamina, mana, crítico moderado, projéteis com colisão no servidor e ataques inimigos anunciados.
- Guerreiro, Espadachim e Mago destacados; Arqueiro preservado; seis classes avançadas por desafios. **48 habilidades + cinco ações raciais**, sem apagar as 24 anteriores.
- Cinco raças permanentes com probabilidades **70/12/8/6/4%**, evolução por missão, fragmentos e espera gratuita de 24 horas após falha racial.
- Inventário, compra/venda, equipamentos por classe, armadura explícita, poções, Gold, níveis 1–100, ranks F–S e **15 missões principais + 20 secundárias + 10 de aventura**. Defesa periódica das fronteiras de Valoria/Arkheim.
- Tutorial por ações verificadas, menus de personagem/linhagem/expedições, HUD, atlas, carregamento, morte, controles touch, hotbar de habilidades e configurações locais.

Os testes automatizados verificam código, regras e serviços em host simulado. **Aparência, física, fluidez, multiplayer, teleporte e persistência reais ainda precisam dos testes em [TESTES_STUDIO.md](TESTES_STUDIO.md).** Não há homologação comercial ou benchmark no Ryzen 7 5700U/12 GB.

## PC e celular

| Ação | PC |
| --- | --- |
| Interagir | E |
| Básico / pesado | Clique esquerdo / direito |
| Bloquear / aparar | F; pressione pouco antes do impacto para aparar |
| Esquivar / correr | Ctrl esquerdo / Shift esquerdo |
| Habilidades | Z, X, C, V |
| Racial / pulso do cajado | R / Q |
| Inventário / missões | I / J |
| Habilidades / linhagem / menu | K / L / M |

No celular, use prompts, botões de combate e hotbar; a mira usa o centro da câmera. **Bloquear funciona ao segurar o botão.** Layout, gestos e alcance da mira aguardam teste no emulador/aparelho.

## Persistência, produtos e áudio

`EnableDataStore=true` continua sendo o padrão de produção. A preparação de prévia é uma opção exclusiva do Studio. Falha de carga não grava defaults sobre dados existentes; falha incerta congela o perfil; recibos e recompensas críticas usam transação no mesmo registro. Racial retry 150 Robux e pacotes de fusão 79/149 têm **IDs 0**, portanto não abrem compras. Fusões sem combinações definidas continuam desativadas. Pacote iniciante/troca de classe são propostas, sem concessões ou preços oficiais ativos.

Sons próprios estão em `assets/audio`; precisam de upload autorizado e IDs válidos em `WorldConfig.Audio`. O projeto não usa IDs inventados. A versão entregue permanece sem esses sons até a configuração. Animações são poses procedurais, não um pacote de animações profissionais já homologado.

## Build e sincronização reproduzíveis

Linux/cloud:

```bash
python3 scripts/install_tools.py
python3 scripts/check.py
python3 scripts/package.py
```

Windows 11, PowerShell na pasta do projeto:

```powershell
powershell -NoProfile -ExecutionPolicy RemoteSigned -File .\scripts\install-tools.ps1
powershell -NoProfile -ExecutionPolicy RemoteSigned -File .\scripts\check.ps1
.\.tools\bin\rojo.exe plugin install
.\.tools\bin\rojo.exe serve default.project.json
```

Conecte o plugin Rojo à porta 34872. Para o segundo Place, use `dungeon.project.json`. Salve o cenário gerado pelo Studio; o build recompila o código, não captura Terrain de um Place aberto. Python é necessário apenas para a suíte mock, verificação XML/catálogos e empacotamento (`py scripts/check.py`).

O check compila/análise Luau, executa suítes CLI e integração simulada, gera ambos os Places e verifica módulos, dependências, serviços e papel de cada Place. `build/BUILD_MANIFEST.json` informa hashes e deixa explícito que cenário/Studio não foram executados pelo build.

## Desempenho e continuidade

LOW: 300 árvores, limite de 16 inimigos ativos por servidor, streaming com raio alvo de 256 studs, IA a 4 Hz e resolução de golpes anunciados separada a até ~33 Hz. Efeitos/chuva são limitados por qualidade e distância. A contagem geométrica simulada não comprova FPS/RAM reais; teste LOW primeiro.

[PROGRESSO.md](PROGRESSO.md) é o estado atual; [NEXT_STEPS.md](NEXT_STEPS.md) contém a continuidade exata. [docs/ELDRAVYN.md](docs/ELDRAVYN.md) descreve a auditoria, [docs/CATALOGS.md](docs/CATALOGS.md) lista conteúdo e [docs/RACES_CLASSES.md](docs/RACES_CLASSES.md) explica a identidade persistente. Históricos anteriores continuam no Git e em `PROGRESS.md`/`TEST_RESULTS.md`.

O projeto não publica a Experience nem ativa compras automaticamente.
