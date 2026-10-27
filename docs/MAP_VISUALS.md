# Inspeção ambiental do continente

O projeto de mapa monta apenas `src/map-preview/MapPreview.server.luau` e `MapPreview.client.luau` como bootstraps. Eles não inicializam combate, inventário, dados, NPCs ou outras funções do RPG.

`MapEnvironment.apply('Day')` configura iluminação, Atmosphere, Bloom, ColorCorrection, SunRays e céu nativo. Presets: Dawn, Day, Sunset, Night, Rain, Fog e Storm. Rain/Storm ajustam a atmosfera para inspeção; não simulam chuva física, raios, áudio, eventos ou efeitos de gameplay. Não existem IDs de assets externos inventados.

No Play do Studio, o pequeno painel alterna qualidade e ambiente. O servidor só aceita mudanças ambientais no Studio, com uma allowlist e limite de frequência. Fora do Studio o botão ambiental fica oculto. O mapa não é regenerado na entrada de jogadores.

Baixo/Médio/Alto limitam luzes próximas, emissores e sombras. Automático observa o tempo dos frames e usa histerese antes de baixar/subir o perfil. Somente detalhes não colidíveis marcados com DetailTier/DetailDistance podem ficar invisíveis localmente à distância; estruturas e regiões não são removidas. Isso não é benchmark nem promessa de FPS. Os emissores existentes são limitados; não foram acrescentadas partículas pesadas.

O preview impede carregamento do personagem se TerrainPending estiver ativo, evitando uma falsa experiência jogável sem o Terrain. Pare Play e execute o comando de preparação indicado no guia antes de caminhar.

Verificações executadas: compilação Luau e teste puro de histerese, modo manual, limites e preservação de geometria colidível. Os sete presets também foram executados em host simulado com propriedades conferidas pelo API dump: os cinco efeitos são reutilizados e nomes inválidos são recusados. Isso não executa renderização. Roblox Studio, aparência, toque, navegação, streaming e FPS em dispositivos reais ainda exigem validação do proprietário.
