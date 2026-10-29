# Melhorias — versão 0.5.0

> Estado atual: Eldravyn 0.6.0. Consulte [PROGRESSO.md](../PROGRESSO.md) e [COMO_JOGAR_NO_STUDIO.md](../COMO_JOGAR_NO_STUDIO.md). As seções anteriores são histórico quando divergirem da versão atual.


Esta rodada amplia o projeto existente; não o recria. Preservados os dois projetos Rojo, a área de 4000 × 4000, coordenadas, quatro cidades, duas florestas, dungeon, IDs de quests/itens, probabilidades raciais e produtos desativados. **Não é uma declaração de homologação ou de revisão visual concluída no Roblox.**

## Correções e refinamentos

| Área | Antes | Depois | Evidência disponível |
| --- | --- | --- | --- |
| Salvamento incerto | Perfil congelado ainda podia ser salvo ao sair | Save recusa congelado; saída libera só o próprio lock e mantém o registro durável | Mock de recibo com commit/resposta perdida, saída e reentrega |
| Corrupção/carregamento | Envelope não tabela podia virar defaults | Dados/locks malformados bloqueiam load e são preservados; loads concorrentes são recusados | Cenário de envelope corrompido e testes existentes de load |
| Posse de sessão | Validade era conferida principalmente ao salvar | Lease expirado bloqueia acesso; token continua conferido no UpdateAsync | Mock de lease expirado e saída sem gravar snapshot |
| Teleporte | Recuperação anunciava sucesso sem conferir load | Mensagem distingue recuperação confirmada/indisponível; save/release congela internamente de modo coerente | Build/inspeção; teleporte real não testado |
| Inventário/lojas | Venda deixava quantidade 0, que Lua considera verdadeira | Remove entrada vazia, recompra funciona, equip/combate exigem quantidade positiva | Regressão CLI vender → recomprar e suites anteriores |
| Magias e arco | Ranged resolvido como hit instantâneo | Ataque básico de cajado/arco, bola de fogo/explosão, projétil de gelo e técnicas de arqueiro usam tempo de viagem e raycast varrido no servidor | Mock de viagem, parede, acerto único, cancelamento e limite |
| Efeitos de habilidades | Um feixe semelhante em vários efeitos | Estilos de fogo/gelo/raio/flecha/sombra/aço, projéteis locais, explosões expansivas, dano e recarga em botões | Handlers reais executados no mock; aparência não renderizada |
| Campo de Chamas | Dano/status inicial sem campo posterior | Campo de cinco segundos pulsa no servidor, expira e é removido em troca de classe/morte; máximo oito campos | Mock de dano posterior e expiração |
| Combate/efeitos | Aviso de cooldown aparecia como toast por ataque | Recargas registradas nos botões; poses variam com combo/pesado; modo de movimento reduzido | Construção/UI e handlers mock; fluidez real pendente |
| Chefes | Área de dano instantânea, sem aviso para esquivar | Windup com área vermelha, origem fixada, fases e padrões alternados de explosão/anel com centro seguro; interrupção cancela windup | Mock verifica zero dano antes do prazo, fase 2 e interrupção |
| Boss solo/grupo | Mesmo HP e scale podia enterrar pernas | HP ajusta uma vez no spawn por 1–4 próximos (1,00–2,05×), recompensa não multiplica; posição corrige o scale | Código/build; balanceamento/contagem real pendentes |
| IA/cleanup | Caminhos antigos podiam persistir para alvo distante; erro de reward podia bloquear cleanup | Invalida path quando alvo mudou muito; IDLE/PATROL explícitos; dano credita vida efetivamente removida e cleanup independe de erro no callback | Código/build e regressões de combate; pathfinding real pendente |
| Casas/serviços | Muitos interiores vazios | Mesas, bancos, camas/prateleiras, tapetes, lanternas e vigas; faixa central de entrada livre; NPCs olham para a praça | Planejamento puro e construção mock |
| Florestas/cavernas | Árvores menos variadas e clareiras simples | Silhuetas variadas, arbustos econômicos e cavernas com escadas/entrada/rochas/cristais | Construção mock; aparência/colisão real pendentes |
| Baús secretos | Baú raro ficava em posição genérica | Mesmo ID de baú transferido para cada caverna; não adiciona loot duplicado | Contagens de dez baús e regras de saque mantidas |
| Rio | Margens secas pouco diferenciadas; amostragem pura não descrevia toda água | Materiais de areia/lama nas colunas reservadas; amostragem pura concorda com adaptador para leito/água/ar | Comparação de matrizes no mock |
| Dungeon | Vãos laterais não intencionais e salas muito semelhantes | Laterais fechadas salvo passagem secreta; ponte sobre abismo interno, pilares, altar, trono e corrimãos da sala secreta | Gerador executado no mock; física não testada |
| Menus | Navegação fragmentada e rótulos com callbacks vazios | Menu central, atlas de rotas/regiões, configurações, ofertas e Tester; rótulos informativos viram texto não clicável | Construção dos menus e mapa no mock |
| Interface móvel | Textos longos podiam ser cortados | Linhas/botões de lista autoajustam altura; painel centralizado com limite de tamanho | Propriedades/API verificadas; dispositivos reais pendentes |
| Campanha | Objetivos técnicos/repetitivos pouco explicados | Textos de objetivos específicos e recompensas visíveis; pré-requisitos informados antes da tentativa; IDs e 35 quests preservados | Testes de referências/objetivos/pré-requisitos e build |
| Ambiente/qualidade | Poucas preferências locais | Clima determinístico com névoa/chuva visual, ajuste de bloom, LOW/MEDIUM/HIGH de efeitos e redução de movimento | Regras de clima/budget CLI; ambiente real pendente |
| VFX/desempenho | Eventos distantes podiam consumir budget/tocar som local | Distância conferida antes de áudio/budget; efeitos limitados por qualidade, chuva desligada no LOW | Código e handlers; FPS não medido |
| VIP/pacotes | Sem área explicativa/teste seguro | Tela informativa, sem inventar benefícios; prévias apenas dos três produtos aprovados | Preview CLI/mock sem mutação |
| Admin Tester | Sem infraestrutura específica | Opt-in, somente Studio sem persistência, relatório antes/depois, sem concessão a perfil real | Mock de bloqueio de produção/ausência de mutação |

Habilidades iniciais de nível 1 já eram utilizáveis gratuitamente; o aprendizado redundante agora é recusado sem débito, e o menu mostra disponibilidade em vez de uma compra desnecessária. Materiais/itens de missão no inventário deixaram de mostrar a mensagem incorreta de armadura.

## Sistemas concluídos nesta rodada, dentro do escopo definido

- Correções identificadas de save incerto, inventário zerado e acesso por lease.
- Pipeline servidor/cliente de projéteis, colisões e apresentação; limites globais/de jogador e cancelamento.
- Windup autoritativo de chefes e campo de dano persistente com expiração.
- Interiores procedurais, cavernas e ajustes estruturais da dungeon.
- Navegação de menus/atlas/configurações e preview seguro dos benefícios já aprovados.
- Novos cenários de regressão e atualização dos dois builds/pacote.

“Concluído nesta rodada” significa implementado e verificado nos testes indicados, não equivalência a jogo homologado. Nenhum sistema avançado anterior foi removido para substituí-lo por um placeholder.

## Testes executados

`python3 scripts/check.py` passou: 50 Luau compilados, análise dos módulos puros, **40 cenários CLI** e **21 fluxos mock**, verificação de referências/ciclos e builds dos dois Places com **37 módulos**. Logs completos em `build/check.log` e `build/integration.log`. Código de testes e casos estão no pacote.

O mock executa módulos reais contra objetos simulados com nomes de propriedades/enums conferidos pelo API dump. Ele não implementa física, renderização, garantias de rede/durabilidade/entrega financeira ou navegação do Roblox. Não transformar esses resultados em “FPS aprovado”, “visual aprovado” ou “compras homologadas”.

## Orçamentos e preservação

No mock LOW atual: **6138 Parts e 63 NPCs**, contra 5307 Parts no início desta rodada (aproximadamente +16% para interiores/cavernas/detalhes). Memória e FPS reais não foram medidos. Mantidos streaming e limite LOW de 16 inimigos; projéteis têm teto 64 global/4 por jogador, campos oito e invocações 16 globais/um por dono. Chuva tem zero Parts no LOW e máximo 24 no HIGH.

Nenhum Terrain foi apagado ou mapa antigo substituído. Alterações de cenário valem para geração nova/regeneração seletiva com backup. Para mudar o Terrain/materiais no mapa já salvo, use um Place novo: não há regeneração global de voxels editados.

## Limitações e decisões pendentes reais

- Sem execução manual no Studio/cliente Roblox, sem benchmark Ryzen 5700U/12 GB e sem inspeção visual em dispositivos reais.
- Assets sonoros próprios continuam aguardando upload autorizado e IDs reais. Não existem animações R15 profissionais; poses são procedurais.
- Parte das técnicas ainda compartilha arquétipos visuais/mecânicos; projéteis são trajetórias lineares sem balística gravitacional. Polimento/balanceamento individual de todas as habilidades permanece iterativo.
- Patrulha/pathfinding e passagens dos interiores precisam ser percorridos no engine. Pavimentos superiores/torres não ganharam acessibilidade completa nesta rodada.
- O clima usa pós-processamento/chuva local, não uma simulação meteorológica volumétrica. O atlas é esquemático; não reproduz altura do terreno nem o mapa interno da dungeon.
- VIP e pacotes iniciais aguardam benefícios/preços aprovados. Nada foi inventado para preencher o menu.
- Fusões continuam sem catálogo/resolvedor aprovado e não consomem recursos; compras continuam desativadas com IDs zero.
- DataStore, teleporte, desligamento concorrente e recibos reais exigem homologação posterior. A recuperação sob indisponibilidade prolongada ainda deve ser exercitada no ambiente real.
- Não houve Git push, publicação do jogo ou ativação de produtos.
