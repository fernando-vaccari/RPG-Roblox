# Eldravyn — mapa atual

Continente contínuo de 4.000 × 4.000 studs. Norte é Z negativo. O gerador verifica ocupação antes de escrever e nunca limpa Terrain global.

| Região | X | Z | Raio | Altura central |
| --- | ---: | ---: | ---: | ---: |
| Valoria | 0 | 1000 | 330 | 44 |
| Arkheim | 0 | -850 | 380 | 48 |
| Eldoria | 1150 | -150 | 340 | 48 |
| Durakh | -1150 | -150 | 330 | 52 |
| Asterion | 1150 | 1200 | 360 | 64 |
| Sylvarin | 1100 | -1100 | 400 | Procedural |
| Nocthar | -1000 | 1000 | 400 | Procedural |
| Véspera | -1080 | -1170 | 390 | Procedural |
| Guilda/treino | 0 | 1480 | Área externa | 44 |
| Abismo (entrada) | 0 | -1700 | Portão | Procedural |
| Santuário (entrada) | -900 | -1680 | Portão | Procedural |
| Lago das Memórias | 1550 | 600 | 80 + margem 64 | Água 32 |

Cada cidade tem 26 edifícios; a guilda de Valoria conserva o ID do lote e fica fora da muralha. Dez rotas ligam cidades, florestas, guilda e entradas. O rio meandrante próximo de Z=300 recebe leito/água por voxels e 42 segmentos de ponte nas rotas. O lago também usa voxels; a cascata usa geometria própria.

LOW: 300 árvores/15 baús, clareiras/cavernas/altares e chefes nas três florestas. Postos de defesa ficam nas fronteiras norte de Valoria/Arkheim. Reservas/rotas mudaram: não regenerar por cima de um Terrain antigo; use um Place novo ou preserve a versão anterior.

O segundo Place mantém sete salas legadas ao longo de Z=0..660. Expedições adicionais têm 10/20 andares, centros locais X=480/900, Z=300, separação vertical de 96 studs; cada piso mede 140 × 150. Portais autoritativos fazem a passagem após confirmar progresso. Em teste no continente, todo o interior recebe origem X=6000, fora do mapa, uma vez por sessão.

Terrain: Y -32..192, voxels 4, chunks 128, 1.024 chunks/56 milhões de voxels. Pré-leitura e escrita têm custo real ainda não medido. Navegação, física e composição visual precisam de inspeção no Studio.
