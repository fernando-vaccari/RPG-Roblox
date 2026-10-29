# Arquitetura do continente — reconstrução 01

`ArchitecturalPlan` define a gramática pura de dimensões, materiais, variantes e interiores; `BuildingGenerator` constrói geometria nativa. O contrato antigo `build(parent,lot,city,index)` e IDs de lotes permanecem. Nenhum NPC, prompt de loja ou sistema de gameplay é criado pelos novos módulos.

| Cidade | Identidade construída | Marco cívico |
| --- | --- | --- |
| Valoria | Reboco claro, madeira aparente, telha terracota, janelas com venezianas | Torre das Horas da Aurora, relógio geométrico, campanário |
| Eldoria | Madeira/verde, mãos-francesas como ramos, floreiras e fachadas integradas à vegetação | Árvore do Primeiro Pacto, raízes, copas e passarela com degraus |
| Durakh | Pedra/ardósia, contrafortes, metal/cobre, volumes de forja | Galeria dos Mestres da Pedra, ponte elevada, escada e chaminé |
| Asterion | Pedra clara, azul, cristais, janelas com pedras-chave | Obelisco das Constelações e runas geométricas |
| Arkheim | Pedra escura, telhados altos, lancetas, contrafortes e pináculos | Campanário do Juramento Partido, sino caído e torre gótica |

As construções possuem fundações, vãos reais de entrada, paredes divididas, caixilhos/rebaixos/montantes, telhados inclinados com empenas WedgePart, vigas e cumeeiras. Variantes controladas acrescentam águas-furtadas, mezaninos de fachada, balcões, janelas com venezianas e volumes verticais. Torres/castelos possuem torreões, ameias, pináculos e bandeiras. As variações usam os dados do lote, não aleatoriedade por entrada do jogador.

Somente edifícios relevantes recebem mobiliário de interior por padrão. `lot.Interior` permite reservar explicitamente interiores; casas comuns mantêm a envolvente sem duplicar mobiliário em todos os lotes. Portas têm abertura nominal de oito studs; a aproximação central conserva ao menos sete studs livres dos balcões/postes. Detalhes pequenos usam `CanCollide=false`, `CanQuery=false`, `CanTouch=false`, `CastShadow=false`. Lanternas arquitetônicas são emissivas, sem uma PointLight por janela.

`CityLandmarkGenerator.build(parent,city,config)` é chamado pela composição da praça. Marca `LandmarkId`, `LandmarkName` e `ArchitecturalTheme` para integração futura. Não altera Terrain, Lighting ou gameplay.

Verificações executadas: compilação Luau dos três módulos; análise sem diagnósticos do plano puro; quatro testes de gramática; dois fluxos no host simulado com os geradores reais (130 edifícios e cinco marcos), conferindo portas, dimensões positivas, construção ancorada, interiores seletivos e ausência de prompts/Humanoids/Scripts. Os mesmos testes não verificam renderização, passagem física, sensação de escala ou FPS. A inspeção no Roblox Studio permanece pendente, especialmente empenas, silhuetas, colisões dos terraços, iluminação noturna e enquadramentos das cinco praças.
