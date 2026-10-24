# RPG-Roblox

RPG medieval procedural original para Roblox Studio, com **continente de 4000 × 4000 studs**, quatro cidades, duas florestas e dungeon separada. A fase 1 foi estendida, sem recomeçar o projeto.

**Estado desta entrega:** código das fases 2–11 integrado; testes CLI e integração simulada executados. **Execução, física, aparência e desempenho no Studio ainda precisam de validação.** DataStore e teleporte reais também não foram testados na nuvem Linux. Não é uma versão já homologada/publicada.

## Caminho mais rápido no Windows 11 — sem instalar ferramentas

1. Extraia o pacote `RPG-Roblox-Windows11.zip` em uma pasta sua. Instale e abra o Roblox Studio pelo site oficial da Roblox, entrando em sua conta.
2. Dentro do pacote, abra `build/ProjectMedievalRPG.rbxlx` usando File → Open from File no Studio. **Use esse arquivo novo; não importe por cima do seu mapa antigo.**
3. Em modo de edição (fora do Play/Run), confira no Explorer os módulos em `ServerStorage.MedievalWorldgen` e as configurações em `ReplicatedStorage.MedievalRPG.Config`.
4. Salve uma cópia de segurança em File → Save to File As antes de gerar. O `.rbxlx` fornecido contém scripts e configurações; o Terrain e o cenário são criados no editor pelo comando abaixo, não estão previamente gravados no arquivo.
5. Abra os painéis Command Bar e Output no Studio. Execute primeiro:

   ```lua
   require(game.ServerStorage.MedievalWorldgen.WorldGenerator).PreviewGeneration()
   ```

6. Gere **o continente completo com um único comando**:

   ```lua
   require(game.ServerStorage.MedievalWorldgen.WorldGenerator).GenerateNewWorld()
   ```

7. Aguarde o Output concluir `[09/09]`. A geração verifica a área, escreve o terreno por chunks e cria estradas, pontes, cidades, florestas, NPCs, baús e entrada da dungeon. Não edite o Terrain nem remova a pasta durante a geração. Tempo total no seu notebook ainda não foi medido.
8. Salve o Place **depois de gerar**. Os objetos e voxels ficam persistentes no Place salvo. O servidor **não gera o continente ao entrar um jogador**.
9. Use Play. Seu personagem começa em Valoria sem rank/classe/equipamento. Consulte a seção seguinte para testar o início do jogo.

**Para cancelar:** marque o atributo `CancelRequested` de `Workspace.GeneratedWorld`. A interrupção ocorre entre etapas. Se a escrita já começou, o terreno parcial é preservado; reabra o backup anterior à geração. Não apague Terrain nem somente a pasta para tentar novamente.

## Testar NPCs, guilda, lojas e missões

1. Aproxime-se de um NPC e pressione **E**, ou toque no prompt no celular. A janela mostra o serviço e os botões disponíveis. O servidor confere proximidade e expiração do contexto; se a conversa expirar, reabra-a.
2. Na **Guilda dos Aventureiros**, escolha “Registrar como aventureiro Rank F”. A missão **Primeiros Passos** passa a acompanhar três bandidos derrotados.
3. No **Campo de Treino**, escolha uma arma gratuita: Katana, Espada longa, Cajado ou Arco. A escolha gratuita só acontece uma vez; outras armas são compradas por 500 Gold.
4. Equipe a ferramenta na barra de ferramentas do Roblox e clique/toque para atacar. Cajado e arco usam a posição apontada; o servidor escolhe um alvo válido por alcance, direção e linha de visão. Não há dano entre jogadores.
5. Com cajado equipado, **Q** ou o botão “Pulso” usa a segunda técnica gratuita. Há cooldown validado no servidor.
6. Em Nocthar, derrote três bandidos. Volte à guilda e entregue **Primeiros Passos** para receber Gold, XP e a classe correspondente à arma equipada. O combate é uma base inicial, não um sistema final balanceado.
7. Ferreiros, arcanistas, armeiros e alquimistas vendem itens com Gold. Preços não vêm do cliente. Couraça aumenta vida máxima; poção cura 50 pontos e é consumida pelo servidor.
8. Use **I / Inventário** para equipar armas compradas e **J / Missões** para acompanhar objetivos. No celular, use os botões inferiores.
9. Aceite missões secundárias na guilda ou com exploradores: lobos, erva rara, ruínas, entrega em Durakh e conversa com mestre arcano. A aceitação da entrega representa receber os suprimentos; não há um modelo carregável separado.
10. Hospedeiros registram a cidade de retorno ao morrer. Sacerdotes curam gratuitamente. Baús têm saque individual por ID; fechar/reabrir não duplica o prêmio. Na persistência atual, o mesmo baú é coletado uma vez por perfil, sem reset diário.

Os rigs são **R6 procedurais articulados**, com rostos e acessórios próprios, uma alternativa sem downloads externos. Possuem movimento/pose procedural simples; não são personagens R15 ou animações profissionais. Suas silhuetas e colisões precisam ser inspecionadas no Studio.

## Dungeon: testar sozinho ou com até quatro jogadores

### Teste local partindo do continente

1. Registre Rank F e equipe uma arma.
2. Siga a estrada de Arkheim para o norte, até o Guardião do Abismo de Malgorth.
3. Use E. Escolha “Entrar sozinho”, ou “Criar grupo”. Para entrar no grupo de outra pessoa, digite o código numérico do líder, exibido na interface.
4. Todos devem estar vivos, próximos do guardião e registrados. Grupos têm até quatro pessoas. Cada membro confirma; o líder inicia. Ao mudar membros, as confirmações são zeradas. Use “Atualizar estado do grupo” ou reabra a conversa para atualizar a lista.
5. No Studio, com `StudioDungeonTest = true`, o servidor cria um mapa de teste isolado em X=6000 **neste mesmo Place de teste** e move os personagens. A interface avisa que **nenhum teleporte real foi validado**. Esse modo não é a arquitetura de publicação.
6. Explore sete salas, corredores/pontes, uma sala secreta, runa de dano, minichefe e Malgorth. O baú final exige a derrota do chefe. Use o portal para retornar à vila no teste local.
7. Para simular cooperação, use a opção de teste do Studio para iniciar servidor com 2–4 jogadores. O mapa local é compartilhado pelos grupos nessa sessão de teste; um servidor reservado separado só existe no teleporte publicado.

### Abrir e gerar o Place separado da dungeon

1. Abra **outro arquivo**: `build/ProjectMedievalRPG_Dungeon.rbxlx`.
2. Salve uma cópia e, fora do Play, execute:

   ```lua
   require(game.ServerStorage.MedievalWorldgen.WorldGenerator).GenerateDungeon()
   ```

3. Salve o Place depois da geração. O interior usa piso/arquitetura próprios, sem escrever Terrain do continente.
4. Em Play no Studio, com DataStore desativado, o modo de teste fornece um kit volátil de cajado, couraça e cinco poções. Ele não simula progressão real ou grava esses itens. O portal de retorno precisa de um continente na sessão; no Place isolado, use Stop para sair do teste.

### Configurar teleporte real — IDs não foram inventados

1. Publique o continente como uma Experience de teste privada pelo Studio/Creator Dashboard.
2. Crie **um segundo Place na mesma Experience** e publique nele o arquivo da dungeon **após gerar seu interior**. Não crie uma Experience independente para a dungeon.
3. Copie os IDs reais dos dois Places pelo Creator Dashboard. Em `src/shared/Config/WorldConfig.luau`, configure:

   ```lua
   DungeonPlaceId = 0, -- substituir pelo ID real da dungeon
   ReturnPlaceId = 0,  -- substituir pelo ID real do continente
   EnableDataStore = true,
   ```

   Os zeros significam “não configurado”. Faça novo build/sync e publique a atualização nos dois Places sem perder o mapa salvo. Se estiver usando apenas o arquivo pronto, pode editar o ModuleScript WorldConfig diretamente no Studio; mantenha o código-fonte no Git atualizado também.

4. Valide primeiro o salvamento com uma conta de teste. DataStore usa autenticação do próprio Roblox; não há chave para colar neste projeto. Em Studio, a opção de acesso a serviços de API só deve ser ativada em uma Experience de teste dedicada, pois pode acessar dados reais dessa Experience.
5. Abra a Experience publicada pelo **aplicativo Roblox**, registre Rank F e teste o guardião. O Studio não confirma teleporte real. O servidor salva os perfis, usa `TeleportAsync` com servidor reservado e envia somente metadados do grupo — nunca saldo/recompensas como autoridade de TeleportData.
6. Teste solo, grupo completo, cancelamento/saída de membro, desconexão, erro de teleporte e retorno. As permissões e restrições da plataforma ainda se aplicam. Falhas de teleporte/salvamento são tratadas e exibidas; não são consideradas sucesso.

## Persistência e segurança

`EnableDataStore = false` é o padrão: os testes têm perfil volátil e a HUD informa isso. Ao sair, esse progresso se perde. Quando habilitado, `DataService` usa UpdateAsync, lock de sessão com renovação e salva periodicamente/ao sair. Erro de load **não grava um perfil padrão por cima dos dados**. Falha de save congela as operações do perfil até recarregar/reconectar.

Compras, escolhas, missões, saques, dano e entrada de grupo são decididos pelo servidor. Há contexto de conversa, validação de argumentos, proximidade, linha de visão e rate limiting. Isso não é uma promessa de anti-cheat infalível; controle de movimento e auditoria de produção ainda podem ser fortalecidos. Não há cobrança Robux nesta versão.

## Desenvolvimento no Windows 11 com VS Code e Rojo

O pacote já permite abrir o Studio sem ferramentas. Para editar/sincronizar:

1. Instale VS Code e Git para Windows pelos sites oficiais. Abra a pasta extraída no VS Code. Se usar `git clone`, lembre que os arquivos desta tarefa **ainda não foram enviados automaticamente ao GitHub**.
2. No PowerShell, dentro da pasta do projeto:

   ```powershell
   powershell -NoProfile -ExecutionPolicy RemoteSigned -File .\scripts\install-tools.ps1
   powershell -NoProfile -ExecutionPolicy RemoteSigned -File .\scripts\check.ps1
   .\.tools\bin\rojo.exe plugin install
   ```

   Instala versões fixadas Rojo 7.7.1 / Luau 0.744 em `.tools/bin`, com TLS e SHA-256 verificado. Não exige Python/npm/Rust. O comando de plugin instala/substitui o plugin Rojo; reinicie o Studio depois. PowerShell/Studio não foram executados neste Linux.

3. Inicie a sincronização do continente:

   ```powershell
   .\.tools\bin\rojo.exe serve default.project.json
   ```

4. No plugin Rojo do Studio, conecte ao servidor do **seu Windows**, porta 34872. Revise o primeiro sync. Para sincronizar a dungeon, pare esse processo com Ctrl+C e use `dungeon.project.json`, conectando ao Place correspondente.
5. O `.rbxlx` já aberto contém os scripts, portanto não precisa de Rojo apenas para gerar. Não substitua um Place com terreno salvo por um novo build vazio: guarde uma cópia do mapa e use sync para atualizar código.
6. Salve o Place gerado. Rojo não exporta os voxels de volta para o Git. O `.rbxl/.rbxlx` gerado no Studio precisa ser guardado separadamente.

## Alterar cidades e regenerar partes

Configurações: `src/shared/Config/WorldConfig.luau`. Catálogo de prédios/serviços, economia e missões: `src/shared/Config/ContentConfig.luau`.

Após gerar, a geometria do Terrain fica vinculada a uma assinatura das coordenadas/seed/relevo. Alterar geografia exige **um Place novo** para não tocar voxels editados. Mudanças na biblioteca de prédios podem usar regeneração seletiva, sempre fora do Play:

```lua
local g = require(game.ServerStorage.MedievalWorldgen.WorldGenerator)
g.RegenerateCity("Valoria")
-- ou: g.RegenerateForest("Sylvarin")
-- ou: g.RegenerateDecorations()
-- ou: g.RegenerateNPCMarkers()
```

Os objetos substituídos são **movidos para `ServerStorage.MedievalBackups`**, preservando conteúdo antigo e eventuais edições internas. Em falha de commit, estágio/backup são mantidos para inspeção. A recuperação de um backup é manual pelo Explorer, fora do Play, após salvar cópia. Essas rotinas não modificam Terrain.

`RegenerateGeneratedWorld()` permanece bloqueado deliberadamente: não há substituição global automática segura de voxels editados. Gere um Place novo em vez disso. O gerador também recusa Parts/Terrain ocupados na área antes da primeira escrita e não usa `Workspace:ClearAllChildren()` ou `Terrain:Clear()`.

## Desempenho — Ryzen 7 5700U / 12 GB

Perfil inicial **LOW**: 200 árvores nas duas florestas, aproximadamente 5,3 mil Parts estáticas/rigs, no máximo 16 inimigos ativos, ativação por proximidade e streaming. MEDIUM/HIGH aumentam árvores/decoração e limites de inimigos; não são recomendações para o notebook sem medir FPS.

IA centralizada a 4 Hz; pathfinding no máximo a cada 2 s por ator; NPCs decorativos não têm loops de servidor próprios. UI/animações locais atualizam por lotes e distância. Terrain usa chunks de 128 studs, com tabelas temporárias limitadas ao chunk. O preflight e a escrita ainda percorrem 56 milhões de voxels: **não há benchmark real de RAM/FPS/tempo do Studio disponível**. Leia [docs/STUDIO_TEST_MATRIX.md](docs/STUDIO_TEST_MATRIX.md) antes de chamar a versão de pronta.

## Testes na nuvem

```bash
cd /workspace/RPG-Roblox
python3 scripts/install_tools.py
python3 scripts/check.py
```

`check.py` compila todos os Luau, analisa módulos puros, executa as três suítes CLI, roda integração simulada com os módulos reais e um API dump público, compila os dois Places e verifica referências/ciclos. Logs da integração: `build/integration.log`.

O mock valida construção e regras sem simular física, renderização, rede, pathfinding real ou garantias de DataStore. Não substitui Studio. No Windows, `scripts/check.ps1` executa compilações, testes puros e builds; a integração Python é opcional e exige Python 3 (`py scripts/integration.py`).

Servidor Rojo opcional: `.tools/bin/rojo serve default.project.json`. Com ele rodando, `python3 scripts/smoke_rojo.py` verifica a entrega dos sources pela API. Nenhum segredo é necessário para as verificações da nuvem.

## Organização e continuidade

- `src/worldgen`: terreno, planejamento, construções, conteúdo, dungeon, decoração e regeneração seletiva do editor.
- `src/server/Services`: dados, segurança, inventário, combate, IA, grupos e integração de gameplay.
- `src/client/Controllers`: diálogos/HUD/inventário/diário/grupos e apresentação do mundo.
- `src/shared`: configurações, progressão, máquina de grupos e rigs próprios.
- `docs/REQUIREMENTS.pt-BR.txt`: pedido original integral.
- `PROGRESS.md`, `PROJECT_PLAN.md`, `NEXT_STEPS.md`, `ARCHITECTURE.md`, `MAP_LAYOUT.md`, `TODO.md`, `CHANGELOG.md`, `TEST_RESULTS.md`: estado real para a próxima sessão.

Não há publicação automática, envio ao GitHub, integração Instagram ou controle OBS. Os pontos cinematográficos estão preparados para integração futura.

## Expansão de combate, classes e campanha

O pedido mais recente adia testes manuais: não é necessário abrir o Studio agora para continuar o código. Geradores e comandos anteriores permanecem disponíveis quando decidir testar.

- Progressão derivada do XP acumulado até nível 100; vida, mana, stamina, dano, defesa e velocidade dependem da classe/nível. Dados existentes são migrados por saneamento sem reset de XP/inventário.
- Combos de quatro ataques; pesado; bloqueio frontal com custo; esquiva com curta janela de invulnerabilidade; corrida; regeneração de recursos; interrupção ao receber dano. O servidor decide custos, cooldowns, alcance e efeitos.
- Z/X/C/V ativam quatro habilidades da classe. Mago tem doze magias ao todo, disponíveis também pelo menu K; habilidades além do nível 1 exigem aprender com mestre de armas/arcanista. O menu aceita uso apenas se o servidor autorizar.
- F segura bloqueio; Ctrl esquerdo esquiva; Shift esquerdo corre; mouse direito ataca pesado; mouse esquerdo mantém ataque básico. K abre classes/habilidades. Existem botões de toque para essas ações.
- O catálogo agora contém **15 missões principais e 20 secundárias**, com pré-requisitos na campanha. Visitas são verificadas pela posição no servidor, conversas por prompts e combate por morte autoritativa. Missões não aceitas ainda não acumulam objetivos.
- Venda pelo mercador, desequipar, materiais de inimigos e pacote de suprimentos de missão foram integrados. A escolha gratuita inicial é persistente, mesmo após vender/desequipar.
- Dois chefes florestais adicionais e Malgorth possuem fases por limiar de vida, ataque próximo e ataque em área, variando intervalo/alcance na segunda fase. Ainda precisam de balanceamento e inspeção física.

Listas completas: [habilidades, NPCs e missões](docs/CATALOGS.md). Auditoria: [docs/AUDIT_EXPANSION.md](docs/AUDIT_EXPANSION.md).

Animações usam poses procedurais curtas, não IDs inventados. Efeitos de impacto e números de dano são locais e limitados a 20 eventos/s por cliente. As magias usam resolução imediata de alvos por linha de visão; não são projéteis físicos em voo. Arquivos de som próprios estão em `assets/audio`; para reprodução no Roblox, será necessário publicar esses WAV e preencher **IDs reais próprios** em `WorldConfig.Audio`. Por padrão o áudio permanece silencioso; nenhum upload foi feito nesta tarefa.

## Raças, evoluções e classes avançadas — versão atual

Abra **Linhagem** no celular ou pressione **L**. O menu reúne raça original, traços, missão racial, árvore de classes, fragmentos e créditos de fusão. **R** usa a habilidade racial; há um botão equivalente no menu.

- Sorteio único no servidor: Humano 70%, Elfo 12%, Elfo Negro 8%, Demônio 6%, Anjo 4%. A raça é gravada antes de liberar o perfil, e reconectar não sorteia outra.
- Evolução racial exige nível 15, missão própria, descobertas quando secretas e cinco fragmentos. Morte ou fim do prazo da tentativa causa espera de 24 horas. Compra opcional de retry custa 150 Robux planejados, mas **está desativada com ProductId=0**; a repetição gratuita funciona sem produto após o prazo.
- Guerreiro → Tanque/Valquíria; Espadachim → Samurai/Assassino; Mago → Invocador/Necromante. Arqueiro permanece. As ramificações exigem nível, desafios e exploração; Necromante precisa descobrir as ruínas de Nocthar.
- As 24 habilidades anteriores permanecem; há 24 técnicas avançadas adicionais e cinco habilidades raciais. Invocações são temporárias e limitadas; dreno aplica dano e cura reais no servidor.
- Fragmentos são concedidos no mapa da dungeon: Cavaleiro 1, Malgorth 3. Não compram uma raça nem substituem a missão racial.
- Fusões têm estrutura de três gratuitas semanais e créditos básicos/premium. **O catálogo de combinações está vazio**; não há resultados inventados ou consumo de moedas/tentativas. Pacotes de 79/149 Robux e aquisição com Gold permanecem bloqueados enquanto não houver catálogo/resolvedor definido.

**Persistência mudou nesta versão:** `EnableDataStore=true` é agora o padrão para cumprir a identidade permanente. Se não houver acesso a DataStore, o perfil não será liberado como se estivesse salvo. O modo volátil explícito (`false`) continua útil para testar a base, porém deixa a raça pendente e não faz sorteio descartável. As seções anteriores sobre modo de sessão descrevem essa opção de teste, não mais o padrão.

Manual completo de regras, migração, missões e recibos: [docs/RACES_CLASSES.md](docs/RACES_CLASSES.md). Catálogos são gerados das configurações por `python3 scripts/export_catalogs.py`, também executado pelo check.py. Nenhum ID de produto foi inventado, nenhuma cobrança ativada e nenhum teste real de Roblox foi declarado nesta entrega.

## Rodada de qualidade 0.5.0

Relatório antes/depois e limites: **[docs/IMPROVEMENTS.md](docs/IMPROVEMENTS.md)**.

- **M / Menu** abre navegação central; há atlas esquemático com cidades, florestas, dungeon e rotas. **Configurações** muda efeitos LOW/MEDIUM/HIGH, som e movimento reduzido localmente. Essas preferências não alteram dano, recompensas ou a densidade já gerada do mapa.
- Magias e arco selecionados agora têm projéteis visíveis com tempo de viagem e colisão autoritativa no servidor. Nem todas as técnicas são projéteis: cortes, curas e áreas mantêm sua forma apropriada.
- Chefes avisam áreas perigosas antes de causar dano. Campo de Chamas tem pulsos posteriores ao cast e expira. Recargas aparecem nos botões de habilidades.
- Geração ganhou interiores mobiliados, cavernas, margens de rio e salas de dungeon refinadas. Use os mesmos comandos já documentados; não gere por cima de outro mapa. Regeneração seletiva continua mantendo backups. Materiais do Terrain alterados requerem novo Place, sem limpar o mapa antigo.
- VIP/pacotes sem definição aparecem apenas como informação. Para testar **prévias** dos benefícios já aprovados sem gastar Robux, configure `EnableStudioTester=true` e `EnableDataStore=false` numa sessão Studio de teste. O servidor bloqueia o painel em produção e não modifica saldo/raça/recibos ao gerar o relatório. O padrão continua desativado.
- A geração real/visual, os trajetos de combate e o desempenho ainda não foram testados no Roblox. Não é necessário realizar testes manuais agora para usar o código como base da próxima execução.

O pacote contém os dois Places compilados com código; os mapas continuam sendo materializados e salvos pelo gerador no editor. As limitações registradas anteriormente continuam válidas quando não substituídas pelo relatório atual.
