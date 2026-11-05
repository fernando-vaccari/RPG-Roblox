# Continente monumental — revisão de 30/10/2026

Pedido: substituir a composição pequena rejeitada por cidades extensas com muralhas monumentais, bairros medievais densos, casas detalhadas e placas nas fachadas, com identidade de fantasia/anime isekai. A referência fornecida orienta a composição de anéis e a relação entre muralha, telhados e grandes marcos cívicos. O usuário autorizou ultrapassar 4.000 × 4.000 studs.

## Implementação

- Continente ampliado para 6.144 × 6.144 studs. As construções mantêm portas e interiores na escala do avatar; a ampliação aumenta as áreas urbanas e florestais.
- Valoria tem dois anéis de muralhas, bairros concêntricos e uma catedral elevada. As outras quatro cidades mantêm paletas, marcos e estilos próprios.
- Lotes originais e identificadores preservados; as novas residências não criam centenas de NPCs adicionais no runtime legado.
- Florestas com troncos, raízes, copas em camadas, clareiras, ruínas e santuários próprios. Copas essenciais permanecem visíveis em LOW.
- Placas de fachada identificam residências e serviços. Novas casas usam um orçamento menor de peças que os edifícios importantes com interiores.
- Artefato novo em `delivery-map/monumental/`; a entrega anterior em `delivery-map/task-01/` permanece preservada. Não será criado ZIP nesta revisão.

## Limites de validação

O ambiente executa Luau, Rojo, verificações XML e renderização geométrica offline no Blender. Não executa Roblox Studio ou Microsoft Defender. As imagens offline usam a geometria exportada e amostras do relevo calculado: não são capturas do Studio e não comprovam FPS, física, streaming ou aparência final no engine.

O `.rbxlx` terá construções e geradores. O Terrain nativo precisa ser escrito uma vez no editor pelo comando `require(game.ServerStorage.MedievalWorldgen.WorldGenerator).PrepareStudio()` e então salvo. O volume expandido contém 2.304 chunks e 132.120.576 posições de voxel; a geração será mais demorada que a versão anterior. O gerador continua verificando ocupação antes da escrita e bloqueando repetição sobre Terrain parcial.

O alerta anterior `Trojan:Script/Ulthar.A!ml` continua sem causa determinada. Esta é uma alteração artística e funcional, não uma tentativa de mudar embalagem para escapar da detecção. Nenhuma liberação de antivírus é alegada.

## Resultado materializado

| Região | Diâmetro aproximado | Conteúdo LOW |
| --- | --- | --- |
| Valoria | 1.680 studs | 334 lotes, muralha externa de 104 studs e interna de 66 studs |
| Arkheim | 1.320 studs | 180 lotes, muralha de 96 studs, catedral gótica |
| Eldoria | 1.260 studs | 180 lotes, muralha de 80 studs, grande árvore cívica |
| Durakh | 1.260 studs | 180 lotes, muralha de 92 studs, bastião das forjas |
| Asterion | 1.260 studs | 180 lotes, muralha de 88 studs, observatório arcano |
| Sylvarin | 1.560 studs | 480 árvores planejadas, santuário e caverna |
| Nocthar | 1.620 studs | 480 árvores planejadas, árvore ancestral, ruínas e caverna |
| Véspera | 1.500 studs | 480 árvores planejadas, monólitos e caverna |

O total de 1.054 lotes inclui os 130 lotes originais; há ainda três casas no vilarejo e os marcos cívicos. As 1.440 árvores planejadas não contam as árvores especiais de santuários/jardins. A geometria materializada contém **92.702 BaseParts e 97.846 instâncias de cenário**, além dos serviços/scripts. As árvores comuns chegam aproximadamente a 72–125 studs; árvores especiais de santuário são maiores. Há dez rotas, 133 segmentos de tabuleiro de ponte (não 133 pontes independentes) e 28 portões.

Os novos lotes têm variação de altura, reboco, madeira, telhados inclinados fechados, chaminés, janelas, floreiras ou águas-furtadas. Placas em português identificam serviços e residências numeradas. As residências extras são exteriores com entrada livre e ambiente simples; os interiores mobiliados continuam seletivos nos prédios importantes.

## Verificações executadas

- `python3 scripts/check.py`: 81 arquivos Luau compilados, análise das regras/configurações, suítes CLI, 46 fluxos MOCK e sete verificações MAPA reportadas; ambos os Places legados construídos com 55 módulos e dois bootstraps cada, sem ciclos ou dependências ausentes.
- Nove testes de relevo na extensão ampliada; planejamento determinístico, lotes e entradas sem sobreposição nas reservas testadas, inclinação rodoviária abaixo de 0,15, conectividade, densidade nos três perfis e fundações alinhadas com o relevo.
- Testes geométricos com caixas orientadas nas portas, ruas e **largura das estradas** ao atravessar muralhas. Detectaram e corrigiram uma torre invadindo a ArcaneRoad em Eldoria: entradas próximas agora são unidas em um portão mais largo.
- 45 combinações de árvores e três santuários construídos no host simulado. Verificados orçamento de peças, alturas das copas, manutenção em LOW e extremos dos galhos inclinados.
- Revisão de imagens da geometria exportada detectou a placa da taverna atrás da varanda e madeira coplanar com o reboco. Ambas corrigidas; `python3 scripts/integration.py --map` repetido após o último ajuste, incluindo regressão para a madeira sobressair da parede e placas ficarem à frente da sacada.
- `python3 scripts/bake_continent.py --self-test`: tipos XML, atributos, UTF-8 e referências passaram por leitura/escrita do Rojo. Build final verificado por `scripts/package_monumental_map.py`: 40 Sources iguais aos arquivos do projeto, referências válidas, contagens correspondentes, SHA-256 e tamanho conferidos.
- Python dos scripts de build/entrega/prévia compilado e `git diff --check` executado.
- Quatro imagens offline da geometria: capital, floresta, continente e fachada. O relatório das imagens identifica fonte, câmeras, omissões e aproximações. **Não são capturas do Roblox Studio.**

Nada disso mede FPS, memória do cliente, física real, salvamento real do Terrain ou detecção de antivírus. Streaming 64/256 e limites visuais permanecem; o perfil LOW conserva todo o continente e as silhuetas. O notebook Ryzen 7 5700U/12 GB ainda precisa de teste real. Nenhum sistema de monetização foi ativado e nenhum Place foi publicado.

## Reproduzir a entrega

```bash
python3 scripts/check.py
python3 scripts/bake_continent.py --self-test
python3 scripts/bake_continent.py --compact-xml --output build/Eldravyn-Monumental.rbxlx
python3 scripts/package_monumental_map.py
python3 scripts/render_continent_preview.py --output-dir build/previews-delivery --width 1600
```

O XML conserva as tags, quebras de linha e Sources em texto. Apenas a indentação repetida foi retirada para manter o mapa abaixo do limite de arquivo do GitHub; não há codificação de scripts, ofuscação ou ZIP. A alteração não constitui liberação do Defender.

## Abrir e gerar no Windows 11

1. Baixe **Eldravyn-Monumental.rbxlx** em `delivery-map/monumental/`. Se o navegador exibir XML, use **botão direito → Salvar link como…**, mantendo a extensão `.rbxlx`.
2. Abra como um novo arquivo no Roblox Studio, preservando seus Places antigos. Se o Defender bloquear, não crie exclusões nem libere o arquivo; encaminhe o arquivo/hash ao [portal oficial da Microsoft](https://www.microsoft.com/en-us/wdsi/filesubmission).
3. Fora do Play, abra Command Bar e Output e execute:

   ```lua
   require(game.ServerStorage.MedievalWorldgen.WorldGenerator).PrepareStudio()
   ```

4. Aguarde a conclusão dos 2.304 chunks, sem executar novamente durante o processo. Salve como uma nova cópia. O código verifica terreno/objetos externos e preserva o cenário se detectar ocupação ou falha parcial.
5. Clique Play para explorar. Comece em LOW; teste os portões, a escada da muralha, as fachadas e as trilhas. Verifique as placas da taverna, guilda, lojas e residências. Registre FPS, memória, Output e capturas de cada cidade e floresta.
6. Salve e reabra. Uma segunda chamada de PrepareStudio deve validar o mapa existente sem recriar os objetos. Em caso de geração parcial, preserve a cópia para diagnóstico e reabra a cópia anterior à preparação.

Esta entrega é a revisão visual do **mapa**, com geradores; os sistemas de RPG continuam no repositório e nos projetos legados. Nenhuma alegação de homologação no Studio ou ausência de vírus foi feita.
