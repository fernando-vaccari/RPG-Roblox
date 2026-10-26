# Linhagens, evolução, classes e fusões

> Estado atual: Eldravyn 0.6.0. Consulte [PROGRESSO.md](../PROGRESSO.md) e [COMO_JOGAR_NO_STUDIO.md](../COMO_JOGAR_NO_STUDIO.md). As seções anteriores são histórico quando divergirem da versão atual.


Esta versão estende o mesmo projeto, nos dois Places, sem reset de equipamento, XP, missões ou habilidades antigas. Uma conta tem um personagem persistente atualmente; respawn não cria outro personagem. Seleção de múltiplos personagens não foi adicionada.

## Sorteio e persistência

O servidor usa ticket inteiro de 1 a 100: Humano 1–70; Elfo 71–82; Elfo Negro 83–90; Demônio 91–96; Anjo 97–100. A configuração é validada para somar exatamente 100. Ticket/probabilidades não são recebidos por RemoteEvent. Em retry de UpdateAsync, o mesmo candidato é reutilizado.

O sorteio é gravado no mesmo UpdateAsync que adquire a sessão, antes de liberar o perfil para gameplay. Reconexão lê a raça já gravada. A raça original está em `Identity.Race`; evolução fica em outro campo e nunca a substitui. Save recusa alteração da raça original. Uma raça corrompida na gravação bloqueia o load, sem sorteio silencioso de substituição.

**Mudança necessária:** `WorldConfig.EnableDataStore` agora vem **true**. Identidade permanente depende de gravação confirmada. Em modo volátil explicitamente escolhido (`false`), os sistemas básicos de teste continuam, mas a raça fica pendente, sem sorteio, compras ou progresso racial. Isso evita prometer permanência enquanto se sorteia outra raça a cada teste. Se as APIs estiverem indisponíveis, o perfil persistente fica bloqueado, sem sobrescrever defaults. Nenhum teste real de DataStore foi realizado nesta tarefa.

## Aparência, traços e habilidades

Aparência procedural acrescenta apenas a pasta própria `MedievalRaceAppearance` ao avatar: brasão humano, orelhas élficas, orelhas escuras, chifres ou halo. Não troca roupas/acessórios do jogador. Evolução acrescenta um sigilo.

Cada raça troca recursos com soma zero em Vida/Mana/Stamina e mantém o mesmo multiplicador de dano da classe. R usa uma habilidade própria: recuperação de stamina, cura, foco de mana, proteção breve ou regeneração. Custo: 8 mana; recarga 20 s, ou 18 s após evolução. A raridade não fornece um multiplicador de poder. Balanceamento e aparência ainda precisam de validação no engine.

## Evolução racial

Requisitos padrão configuráveis: Rank F, nível 15 e descoberta quando secreta. A missão tem 30 minutos. Eventos só contam após iniciar. Morrer ou expirar o prazo falha a tentativa. O relógio usa `os.time()` do servidor, persiste entre Places e reconexões, e a falha não é reiniciada ao consultar o menu.

Após falhar: nova tentativa grátis a partir de `ReadyAt` (falha + 86400 segundos). Enquanto aguarda, um crédito de retry pode antecipar somente essa tentativa, sem sortear outra raça. Crédito não é consumido quando o prazo grátis já passou.

Concluir exige todos os objetivos e cinco fragmentos. Fragmentos são um custo complementar; possuir mil fragmentos não conclui nenhum objetivo e não compra uma raça. Evolução só é concedida uma vez. Missões de Elfo Negro/Anjo precisam de descobertas nas ruínas de Nocthar/Sylvarin.

## Classes

As três principais são Guerreiro, Espadachim e Mago. A primeira missão e a escolha de equipamento continuam definindo a classe básica. Arqueiro permanece disponível como alternativa.

- Guerreiro → Tanque / Valquíria.
- Espadachim → Samurai / Assassino.
- Mago → Invocador / Necromante.

Classes avançadas exigem a classe-base desbloqueada, nível 20/25 e seu desafio. Assassino/Necromante precisam de descoberta nas ruínas de Nocthar antes de iniciar. Não existe RemoteEvent que simplesmente declare descoberta/conclusão: o servidor confere prompts, posição e mortes.

Cada classe avançada tem atributos, quatro técnicas, arma-base e efeitos próprios. As técnicas antigas da classe-base continuam acessíveis pelo menu. Invocador cria um espírito temporário que segue o dono e ataca um inimigo com linha de visão (12 s, um por jogador e teto global de 16). Necromante usa dreno de vida; não é apenas um efeito visual. Trocar classe preserva mana/stamina atuais, limitando-as ao novo máximo; não é um reabastecimento gratuito. Trocar ou sair remove invocações.

Aprender habilidades mantém as regras do mestre de armas/arcanista. Não foi adicionado um método de comprar/desbloquear arbitrariamente outras classes básicas: preserva-se a classe inicial conquistada e suas duas ramificações. O catálogo permite ampliar isso depois sem remover o Arqueiro.

## Fragmentos

O Cavaleiro Corrompido concede 1 e Malgorth 3 por derrota válida no mapa `GeneratedDungeon`. Apenas contribuidores próximos e com perfil carregado recebem o recurso. Matar um inimigo de mesmo nome fora da dungeon não concede fragmentos. O valor fica em `Identity.Fragments`, aparece no menu e é salvo junto do perfil.

## Fusões: estrutura preparada, resultados pendentes

As pools declaradas separam classes básicas (incluindo Arqueiro) das seis avançadas: créditos Basic usam a primeira e Premium a segunda quando o resolvedor futuro for implementado. As três gratuitas são da pool Basic.

Três tentativas gratuitas semanais, com reset na segunda-feira às 00:00 UTC; créditos básicos e premium são separados e não expiram no reset semanal. Gold/fragmentos não são tocados pelo reset.

O catálogo `IdentityConfig.Fusion.Recipes` está vazio. Solicitar fusão não rola resultado nem debita tentativa ou fragmento. A compra de créditos com Gold e as janelas pagas de pacotes permanecem bloqueadas nessa situação, para não vender uso indefinido.

Planejado: uma básica por 1500 Gold (configurável); pacote de três básicas por 79 Robux; três premium por 149. Combinações de classes/habilidades, pesos, custos de fragmentos, falhas e resultados **aguardam definição do criador**. O resolvedor não foi inventado; adicionar entradas ao catálogo não implementa automaticamente uma fusão. Uma próxima implementação deve validar base/avançada, saldo e recibos e então consumir uma única fonte de tentativas de maneira atômica.

## Compras oficiais

`IdentityConfig.Products` mantém todos os IDs em **0**, portanto nenhuma compra está ativa. Valores planejados: retry 150; básicas 79; premium 149 Robux. Configurar um produto real da mesma Experience, com preço correspondente, será uma etapa administrativa futura.

`PurchaseService` é o único proprietário de `MarketplaceService.ProcessReceipt`. Usa GetProductInfoAsync para verificar preço/estado antes da janela oficial PromptProductPurchase. Nenhum evento de cliente ou fechamento de janela concede recompensa. Recibo desconhecido, jogador ausente, sessão ocupada ou falha de gravação retorna NotProcessedYet.

Crédito e `PurchaseId` são gravados juntos no MESMO perfil via UpdateAsync, com lock. PurchaseGranted só retorna após confirmação persistente. Recibo repetido consulta o ledger e não duplica créditos nem reverte progresso posterior. O ledger não é enviado ao cliente nem podado automaticamente; novas janelas são pausadas a partir de 1024 registros para permitir manutenção segura. Não use um segundo ProcessReceipt sem integrar os handlers.

Não publicar compras antes de configurar/testar os produtos reais em Experience de teste. Não foi realizada nenhuma cobrança nesta tarefa.

## Menu e controles

L no computador, ou **Linhagem** no celular, abre raça, características, evolução, objetivos, classes/requisitos, fragmentos e tentativas. R ativa a habilidade racial; também há botão no menu. Selecionar uma classe não concede suas armas automaticamente. Z/X/C/V passam a usar os slots da classe atual. Catálogo completo: CATALOGS.md.

## Limites de validação

Testes CLI e host simulado não provam persistência, entrega financeira ou aparência real. Ainda devem ser testados no Roblox: primeira entrada/reconexão entre Places, desligamento durante save, morte durante transação, recibos reais e retries da plataforma, interface móvel e invocações multiplayer. O usuário adiou essa etapa; não é solicitada agora.

## Compatibilidade em Eldravyn 0.6.0

A escolha inicial no menu Personagem já define a classe e fornece/equipa a arma; Primeiros Passos continua sendo missão de guilda com o mesmo ID/recompensa. A prévia Studio não salva nem sorteia raça. No modo persistente, o sorteio original permanece durável e único. Cavaleiro/Malgorth/Regente concedem 1/3/5 fragmentos nas dungeons, incluindo seus andares. O catálogo de fusões continua inativo; as 48 técnicas e cinco raciais permanecem.
