# Eldravyn: Rise of Shadows — testes pessoais no Roblox Studio

**Todos os itens abaixo estão pendentes de execução real.** Compilação, regras e integração simulada não marcam esta lista automaticamente. Registre versão, dispositivo, resultados e erros completos do Output.

**Primeiro, validar a correção 0.6.1:** execute o [procedimento ReadVoxels](docs/READVOXELS_FIX.md#como-testar-novamente-no-roblox-studio): script de leitura real, geração dos dois Places e recusa de Terrain sólido/água em cópias descartáveis. O erro reportado foi reproduzido em mock e corrigido em código; ainda não houve reteste no engine.

1. **Preparação e entrada:** abra cada `.rbxlx`, execute `PrepareStudio()`, salve, reabra a cópia e clique Play. Confira spawn, HUD e ausência de nova geração de continente na entrada de outro jogador.
2. **Personagem:** escolha uma classe; confira arma nas mãos e habilidades iniciais. A segunda escolha gratuita deve ser recusada. Prévia deve mostrar ausência de salvamento/raça pendente; modo persistente deve preservar a raça original.
3. **Combate:** teste combo, pesado, mana/stamina, cooldown, crítico, armadura e poção. Acerte com projéteis; paredes devem bloquear. Trocar arma/classe ou morrer deve encerrar projéteis e invocações apropriadas.
4. **Parry e esquiva:** no parceiro de treino, veja o aviso, apare de frente com F, segure para bloquear e teste pela retaguarda. Repetir bloqueio rapidamente não deve renovar a janela. Verifique quebra e recuperação de postura. Afaste-se durante um golpe anunciado e confira que ele erra.
5. **Tutorial/NPCs:** conclua movimento, arma, acerto, esquiva, parry, habilidade, inventário, registro e Primeiros Passos. Teste ferreiro, mago, hospedaria, cura e mercador. Comprar de longe/sem conversa, vender arma equipada ou gastar saldo insuficiente deve falhar.
6. **Cinco cidades:** explore Valoria, Arkheim, Eldoria, Durakh e Asterion. Atravesse portões, ruas, pontes e entradas das casas. Confira guilda fora de Valoria, caminhos livres, interiores, lojas e iluminação. Registre portas bloqueadas, terreno atravessando pisos e quedas indevidas.
7. **Três florestas:** visite Sylvarin, Nocthar e Véspera; teste caminhos, cavernas, baús, altares, ervas, chefes e o Lago das Memórias. Investigue segredos de classes/raças.
8. **Missões/guilda:** aceite, avance e entregue missões; tente entregar novamente. Verifique promoção por XP/missões, restrição por rank e evento de defesa das fronteiras. Recompensa não pode duplicar ao repetir o prompt.
9. **Dungeons solo:** complete os 10 e os 20 andares, incluindo chefes/baús. Não deve avançar com guardiões vivos ou por um portal de outro andar. Teste morte, timeout, retorno, repetição da tentativa e preservação dos andares confirmados. Explore também as sete salas legadas.
10. **Grupo:** teste dois e quatro clientes, líder, entrada por código, confirmações, distância ao guardião/portal, saída, morte de um membro e derrota total. Outros jogadores não devem causar dano/saquear a expedição do grupo. Teste os IDs negativos dos clientes locais.
11. **Dados reais:** numa Experience de teste, habilite persistência e reconecte. Confira raça, classe, Gold, itens, missões, rank, melhores andares, fragmentos e desbloqueios. Teste sessão concorrente e falhas de API sem apagar o perfil. Teleporte real e espera pelos membros exigem o aplicativo Roblox e IDs oficiais.
12. **Mobile/desempenho:** emule celular pequeno e tablet, depois teste aparelho real. Confira hotbar, mira central, prompts, segurar bloqueio, movimento/jump, rolagem e textos. Meça FPS, RAM e tempo de geração em LOW no Ryzen 7 5700U/12 GB. Inspecione combate com quatro jogadores e transições de streaming.

Compras continuam desativadas. Testes financeiros, upload/áudio, animações/estética e balanceamento final exigem configuração e revisão específicas; não habilite produtos apenas para completar esta lista.

Modelo de registro: `item | versão/commit | aparelho | passou/falhou | passos para reproduzir | trecho do Output`.
