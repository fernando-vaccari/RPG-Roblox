# Continente — progresso da Tarefa 01

Atualização: 27/10/2026. Branch: `codex/eldravyn-map-20261027`. Base preservada: `17b4f8e` (0.6.1 + investigação Defender). Consulte o log Git para o último commit desta entrega.

## Estado

Reconstrução do cenário em implementação e testes. Esta tarefa substituiu o escopo amplo anterior: **somente continente**, sem novos sistemas de gameplay. Mapa antigo rejeitado substituído nos geradores/novo artefato; versões anteriores e dados do RPG preservados. Rojo/Luau são o fluxo de origem. Não existe Studio neste Linux.

O cenário é materializado offline como instâncias nativas XML, e não entregue apenas como um gerador. **Terrain nativo, inspeção visual e medições reais continuam pendentes. Portanto o mapa final ainda não está concluído segundo os critérios do pedido.** O comando PrepareStudio completa o Terrain numa cópia nova e deve ser seguido de salvamento.

## Regiões e arquitetura implementadas em código

- Valoria: capital com praça, marco do relógio, arquitetura de madeira/reboco, castelo e guilda externa conectada.
- Eldoria: cidade florestal com madeira, jardins, árvores monumentais e marco orgânico.
- Durakh: cidade das montanhas, pedra, forjas e marco defensivo.
- Asterion: cidade arcana, academia/torres e cristais.
- Arkheim: cidade gótica, silhuetas de torres e fortaleza sombria.
- Sylvarin/Bosque Esmeralda, Nocthar/Ancestrais e Véspera/Sombria: quatro agrupamentos por região, clareiras, cinco variantes de árvore, raízes, rochas e cavernas.
- Dez rotas curvas contínuas, pontes, três cadeias montanhosas, vales, três lagos, cascata, vila, acampamento, fortaleza abandonada, santuário e mirante.
- Dois exteriores monumentais de dungeon. Slots de integração identificados; sem interiores novos, guardiões, teleporte ou recompensas.
- Arquitetura modular com fachadas/janelas, telhados/gables/dormers, materiais por cidade, oito studs de abertura de portas e interiores seletivos nos edifícios relevantes.

## Escala e orçamento

Continente: **4.000 × 4.000 studs**, mantendo deslocamentos contínuos e IDs anteriores. O tamanho foi mantido para concentrar esforço em composição/densidade e compatibilidade, não por alegação de benchmark. Grades de Terrain de 4 studs; 1.024 chunks e cerca de 56 milhões de voxels. Build LOW prevê 160 árvores por floresta; não reduz o continente nem remove regiões.

Streaming: mínimo 64/alvo 256 studs. Perfis visuais limitam luzes, sombras, partículas e detalhes não colidíveis; Automático usa tempo de frame observado. Silhuetas, edifícios, colisões e regiões permanecem. Metas 30 FPS mobile/60 FPS PC são objetivos não medidos. Notebook 5700U/12 GB não foi testado.

## Verificação e continuidade

Resultados finais e números serão registrados ao terminar a integração. A revisão estrutural já localizou e encaminhou correções de cavernas/portais atravessados pelo relevo e estradas suspensas. Não substituir essas verificações por suposições de beleza.

Próxima tarefa exata: executar os testes de integração da branch, reconstruir o Place, registrar hashes/manifesto e confirmar push. No Studio, seguir COMO_ABRIR_MAPA.md e o checklist abaixo.

## Checklist real pendente

1. Preparar Terrain, salvar/reabrir e confirmar spawn; segunda preparação não deve recriar geometria.
2. Percorrer as dez rotas e pontes a pé; verificar declives, muralhas, ruas e entradas de edifícios importantes.
3. Fotografar praça/skyline de cada cidade em Dia e Noite. Avaliar proporção, variedade, telhados, vazios, cores, sombras e leitura das fachadas.
4. Inspecionar as três florestas, clareiras e cavernas; procurar troncos/rochas flutuantes, obstáculos e repetição visual excessiva.
5. Inspecionar os dois portais externos, lagos/cascata, vilarejo, acampamento, fortaleza, mirante e santuário. Não deve haver NPC, inimigo, prompt ou recompensa funcional.
6. Testar os sete presets e os quatro perfis em celular emulado/aparelho e PC. Medir FPS, memória, tempo de preparação e streaming; registrar versão/dispositivo/Output/capturas.
7. Registrar ajustes artísticos por coordenada e captura. Sem esta revisão, o mapa não é final nem visualmente homologado.

O alerta Defender anterior permanece indeterminado. Nenhum antivírus foi desativado; nenhum arquivo foi declarado seguro. Compras/publicação do jogo não fazem parte desta tarefa.
