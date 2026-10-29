# Continente — composição e relevo reconstruídos

Continente contínuo de **4.000 × 4.000 studs**, Terrain a 4 studs por voxel, 1.024 chunks de 128 studs no máximo; volume vertical permanece -32..192 (56 milhões de voxels). Essa escolha preserva escala e limita o volume do editor. **Não é medição de FPS, RAM ou tempo no Studio.**

IDs e centros regionais legados permanecem estáveis. `SchemaVersion=4` e `LayoutRevision=AuthoredContinent-01` distinguem a composição nova: assinaturas antigas são recusadas para impedir sobreposição de terreno existente. Nenhum clear global foi introduzido.

- **Valoria:** capital/Crown, centro (0,1000), raio360. O antigo lote GuardTower mantém seu ID/Kind e recebe `VisualKind=Castle` para a cena; guilda externa continua em (0,1480).
- **Eldoria:** natureza/Forest, (1150,-150), raio360.
- **Durakh:** montanhas/Mountain, (-1150,-150), raio360.
- **Asterion:** Arcane, (1150,1200), raio360.
- **Arkheim:** Gothic, (0,-850), raio380.

As 130 parcelas deixam a espiral e passam a quadras autorais de 84 studs, com distrito, orientação de fachada, variação e indicação de interior. Praça central livre, avenidas cardeais de24 studs e vias de6 studs entre quadras (+/-126 e +/-210) conectam portas sem atravessar outras construções. Os caminhos têm folga de pelo menos meia largura de3 studs além do círculo conservador de cada lote. Todos os IDs de parcela e conteúdos legados são preservados; nenhuma regra de gameplay foi editada.

Dez rotas usam controles curvos de Catmull-Rom, segmentos de até14 studs e alturas amostradas do Terrain final fora das pontes. Avenidas com eixos iguais não arqueiam sobre as quadras. Pontes mantêm tabuleiro elevado, com extensão nas margens. O teste atual conta100 módulos de tabuleiro — **não100 pontes independentes**. Um índice espacial de128 studs reutiliza os caminhos nas consultas de relevo; as curvas não são reconstruídas por voxel.

O relevo integra três dorsais (Forjas, Coroa Setentrional e Agulhas Celestes), dois vales, rio sinuoso, Lago das Memórias e dois lagos adicionais (Espelho Alpino e Lago do Sul). A margem principal foi ampliada para128 studs e a alpina para96 após detectar transição excessiva entre a montanha e o leito. O teste anterior de continuidade em10.201 amostras foi mantido, sem relaxar sua tolerância.

As três florestas usam quatro bosquetes compostos em torno de clareiras e cinco variantes de árvores. Nocthar tem exemplares ancestrais maiores; Véspera privilegia troncos retorcidos. LOW tenta160 árvores/floresta (480), MEDIUM240 (720), HIGH360 (1.080); testes verificam densidade e todos mantêm as três regiões. Árvores evitam estradas, água, cidades e reservas cênicas.

Reservas planas explícitas protegem as duas entradas monumentais, as três cavernas e cinco pontos de interesse. Foram acrescentadas após uma revisão geométrica identificar terreno atravessando cavernas. Elas e os controles de rota entram na assinatura da geografia.

**Verificações executadas:** nove testes puros de Terrain, planejamento/topologia/perfis e teste adicional de quadras/caminhos/bosquetes; `luau-analyze` desses módulos sem diagnósticos. Cobrem limites de volume, assinaturas, material/água, pads, continuidade, lotes sem sobreposição, rampas inferiores a15%, portas sem cruzar outro lote, determinação e cinco espécies/doze bosquetes. Não executamos Roblox Studio, física, inspeção artística, colisões reais ou benchmarks. Construção de objetos/contagem e geração de cenas não homologam qualidade visual.
