# Layout planejado

Continente contínuo de 4000 × 4000 studs, centro (0,0); norte = Z negativo. Nesta fase, toda a área X/Z tem solo; mar, rios e lagos serão fase 2. Nenhuma ilha separa as cidades.

| Região | X | Z | Reserva (raio) | Solo no centro |
| --- | ---: | ---: | ---: | ---: |
| Valoria | 0 | 1000 | 240 | 44 |
| Arkheim | 0 | -850 | 320 | 48 |
| Eldoria | 1150 | -150 | 240 | 48 |
| Durakh | -1150 | -150 | 240 | 52 |
| Sylvarin | 1100 | -1100 | 400 | Procedural |
| Nocthar | -1000 | 1000 | 400 | Procedural |
| Malgorth (entrada) | 0 | -1700 | 60 (marcador) | Procedural |

Só centros das cidades têm plataformas planas. Áreas florestais e dungeon possuem marcadores, sem geometria construída. Estradas planejadas: Valoria–Arkheim, Valoria–Eldoria, Valoria–Durakh, Arkheim–Malgorth e ramais florestais. O planejamento de estradas ainda não altera a altura.

Limites verticais de escrita: -32 a 192. Chunk 128 × 128 studs, último chunk ajustado à borda. Voxels de 4 studs. Escrita total de 56 milhões de voxels em 1024 chunks; memória temporária limitada ao chunk corrente. Pré-leitura de ocupação também percorre esse volume. Custo de execução no Studio pendente de medição.

## Atualização da continuação

As reservas agora recebem construções/florestas. Seis estradas do WorldConfig têm altura interpolada e máscaras no terreno. O rio cruza o continente próximo de Z=300, com meandro de 70 studs; as rotas que cruzam seus bancos recebem decks/guarda-corpos de ponte. Água/leito são voxels, sem oceanos dividindo cidades.

60 lotes são planejados em anéis com afastamento conservador de estradas e de outros lotes. LOW produz 100 árvores em cada floresta. Cada bosque tem clareira/ruína/objetivos, inimigos e cinco baús.

Entrada de Malgorth ao norte. Interior publicado fica em outro Place (7 salas ligadas ao longo de Z=0..660). Apenas o teste Studio usa origem X=6000 no mesmo Place, com aviso explícito; o gerador principal não incorpora uma ilha/dungeon no continente.
