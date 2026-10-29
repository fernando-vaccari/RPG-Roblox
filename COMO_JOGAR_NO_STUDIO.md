# Como jogar Eldravyn: Rise of Shadows no Roblox Studio — Windows 11

O pacote usa Rojo e inclui **dois Places `.rbxlx` com os scripts nos serviços corretos**. O mundo não está previamente gravado: o Studio deve executar o gerador uma vez. Depois de salvar essa cópia, basta abri-la e clicar Play nas próximas sessões. Não é necessário instalar Rojo/Python para esse caminho.

**Correção 0.6.1:** se você encontrou `attempt to iterate over a Vector3 value` em TerrainGenerator, baixe o ZIP novo, extraia em outra pasta e abra o novo `.rbxlx` depois de fechar o Place antigo. Preserve seu mapa salvo. [Diagnóstico e teste de proteção do Terrain](docs/READVOXELS_FIX.md) explicam a causa e os passos de reteste. O script opcional `scripts/TestReadVoxels.command.luau` testa a leitura real sem alterar terreno; não foi executado no Studio pela nuvem.

## 1. Abrir e preparar o continente

1. Baixe o ZIP pelo GitHub, clique com o botão direito → **Extrair Tudo**. Abra o arquivo extraído `RPG-Roblox/build/ProjectMedievalRPG.rbxlx` pelo Roblox Studio (**File → Open from File**).
2. Salve como uma cópia nova, por exemplo `Eldravyn-Continente.rbxlx`. Mantenha seu mapa anterior em outro arquivo.
3. Fora do Play/Run, habilite **Command Bar** e **Output** nas ferramentas/janelas do Studio. Cole na Command Bar:

   ```lua
   require(game.ServerStorage.MedievalWorldgen.WorldGenerator).PrepareStudio()
   ```

4. Aguarde o Output terminar com **`[Eldravyn] Cenário preparado`**. O terreno usa 1.024 chunks; o tempo no seu notebook ainda não foi medido. Não entre em Play durante a geração.
5. **Salve novamente**, agora com Terrain, cidades, NPCs e demais instâncias. Clique **Play**.
6. A tela de personagem oferece Guerreiro, Espadachim e Mago; Arqueiro aparece como alternativa. A arma inicial é gratuita, equipada automaticamente e concedida uma vez por perfil.
7. Siga o painel Tutorial. A guilda está **ao sul de Valoria, X 0 / Z 1480**. Converse com Maelis para registrar Rank F. Treine ataques/aparos no parceiro próximo da sede, aceite missões e explore.

`PrepareStudio()` recusa mapas ocupados ou de outra geografia. Se aparecer esse aviso, abra o `.rbxlx` novo do pacote e gere numa cópia vazia; não apague o mapa anterior. Em falha depois de começar a escrever Terrain, reabra a cópia anterior à geração. O projeto preserva o diagnóstico e bloqueia repetição por cima do terreno parcial.

## 2. Entender a prévia local

A preparação padrão marca `Workspace.StudioSessionPreview=true`. **Só no Studio**, isso permite jogar sem API/DataStore. A HUD informa que a sessão não será salva. Ao parar Play, esse progresso é descartado.

A raça fica **pendente**, pois o projeto não sorteia uma raça temporária que mudaria a cada entrada. O sorteio permanente e as transações de evolução racial precisam do modo persistente. Combate, classe inicial, missões, lojas, inventário e encontros locais podem ser testados na prévia.

Fora do Studio, esse atributo é ignorado: `EnableDataStore=true` continua valendo. Não publique esperando que a prévia substitua a configuração de persistência.

## 3. Testar as dungeons

No continente, registre-se na guilda e procure um guardião:

| Entrada | Local | Requisito |
| --- | --- | --- |
| Abismo de Malgorth | X 0 / Z -1700, norte de Arkheim | Rank registrado, nível 1 |
| Santuário do Reino Caído | X -900 / Z -1680, norte de Véspera | Rank registrado, nível 20 |

Escolha solo ou crie um grupo. Os outros jogadores entram com o código do líder; todos confirmam próximos ao mesmo guardião e o líder inicia. O teste no Studio cria **uma cópia isolada da dungeon em X=6000**, uma vez por sessão, sem regenerar o continente. Isso não testa TeleportService real.

Cada andar deve ser limpo. Reúna os sobreviventes junto ao portal **Avançar** e interaja: o servidor confirma o progresso e leva o grupo ao próximo andar. Baús do andar exigem a limpeza. O melhor andar e a primeira conclusão são preservados no modo persistente; a recompensa de avanço não se repete. Novas tentativas começam no andar 1. Morte elimina o jogador da tentativa; derrota do grupo encerra o percurso. Use o portal de retorno para sair.

As sete salas anteriores continuam acessíveis pela opção **Explorar as sete salas legadas**.

Para abrir o segundo Place diretamente:

1. Abra `build/ProjectMedievalRPG_Dungeon.rbxlx`, salve uma cópia `Eldravyn-Dungeons.rbxlx`.
2. Fora de Play, execute o mesmo `PrepareStudio()` e salve novamente.
3. Clique Play. A prévia da dungeon fornece cajado, couraça e cinco poções apenas para a sessão. Converse com a recepção para iniciar a expedição disponível ao seu nível. O retorno local leva à recepção quando não há continente nessa sessão.

## 4. Solo e multiplayer local

Use as opções de teste do Studio para iniciar um **servidor com dois clientes**; depois teste quatro. Entre pelo mesmo guardião, confirme o grupo em todos os clientes e inicie. Os IDs negativos usados por jogadores de teste do Studio são aceitos pelo sistema local.

No modo local há uma expedição ativa por servidor de teste. Em produção cada grupo recebe um servidor reservado do segundo Place. Teste primeiro dois clientes em LOW no notebook; a nuvem não mediu consumo de quatro clientes do Studio.

## 5. Testar persistência e raça permanente

Esta etapa exige uma Experience de teste sua e acesso às APIs Roblox. Ela não foi realizada no ambiente Linux.

1. Quando decidir publicar para teste, use uma **Experience dedicada**. Não use dados de uma experiência de produção para os primeiros testes.
2. Habilite o acesso do Studio aos serviços de API nas configurações da Experience de teste.
3. Fora de Play, no mapa já preparado, execute:

   ```lua
   require(game.ServerStorage.MedievalWorldgen.WorldGenerator).PrepareStudio({Persistent=true})
   ```

4. Salve, entre em Play, crie o personagem, obtenha Gold/itens, pare e entre novamente. Confira raça, classe, missões e inventário. **A raça deve ser a mesma**.
5. Se o perfil ficar indisponível, confira o Output. O sistema não libera um perfil vazio para fingir que salvou. Para voltar à prévia sem salvamento, pare Play e execute `PrepareStudio()` novamente.

## 6. Configurar os dois Places para teleporte real

Somente quando você decidir publicar para testes:

1. Crie o continente e a dungeon como **dois Places da mesma Experience**, gerados e salvos antes da publicação.
2. Preencha os IDs verdadeiros em `ReplicatedStorage.MedievalRPG.Config.WorldConfig`, nos dois Places: `DungeonPlaceId` para a dungeon e `ReturnPlaceId` para o continente. Ambos continuam 0 no pacote.
3. Mantenha `EnableDataStore=true`. Atualize/publice os scripts nos dois Places sem perder o cenário salvo.
4. Teste pelo **aplicativo Roblox**. O Studio não valida teleporte real. O servidor grava reservas de grupo; a dungeon espera até 90 segundos pelos membros e só começa após reuni-los. Itens, moeda e recompensas nunca são aceitos do TeleportData.

Nenhum produto Robux precisa ser configurado para jogar. IDs de produtos permanecem 0 e compras estão desativadas. Áudio próprio requer upload dos WAV e IDs reais em `WorldConfig.Audio`.

## 7. Atualizar o código com Rojo

O build é reproduzível; instruções de instalação estão no README. No PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy RemoteSigned -File .\scripts\install-tools.ps1
powershell -NoProfile -ExecutionPolicy RemoteSigned -File .\scripts\check.ps1
.\.tools\bin\rojo.exe plugin install
.\.tools\bin\rojo.exe serve default.project.json
```

Conecte o plugin Rojo à porta **34872**. Para a dungeon, sirva `dungeon.project.json`. Evite abrir um build vazio sobre uma cópia de cenário sem salvá-la. O Rojo compila/sincroniza os scripts; não recupera automaticamente o Terrain editado no Studio.

Os dois `.rbxlx` foram construídos e sua estrutura é verificada por `scripts/verify_project.py`. `build/BUILD_MANIFEST.json` registra os hashes e a limitação de cenário não pré-gravado. Use [TESTES_STUDIO.md](TESTES_STUDIO.md) para homologar o resultado real.
