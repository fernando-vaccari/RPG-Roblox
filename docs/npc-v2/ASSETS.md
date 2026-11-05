# Assets, autoria e limitações

Nenhum asset externo é obrigatório. O pacote contém somente Sources Luau e contêineres Roblox; não contém instaladores, Python, PowerShell, executáveis, downloads de malhas nem scripts de terceiros. Os geradores produzem peças nativas (`Part`, `WedgePart`, esferas e cilindros) com materiais nativos e `WeldConstraint` nas peças do rig existente. A imagem enviada foi usada como direção de roupas em camadas, armadura e cabelo claro, sem copiar personagem ou textura.

Não foram localizados meshes/texturas próprios de personagem nem animações publicadas no projeto inspecionado. **Não foram criados meshes profissionais, roupas em camadas de catálogo, face skinned, expressões por ossos ou texturas pintadas.** Os rostos têm olhos, sobrancelhas e sorriso geométricos fixos; a expressividade de movimento vem da pose e atenção, não de lip-sync. Capas e mechas seguem suas peças do corpo, sem simulação de tecido/cabelo.

As 15 entradas em `NPCVisualConfig.Animations` têm `Id = ''`. Todas usam poses procedurais funcionais no código. A arquitetura aceita IDs oficiais autorizados futuramente; ainda faltam gravação/publicação de clips R15 e revisão das permissões da Experience. Os IDs sintéticos usados com o Animator falso aparecem somente nos testes e não são exportados no pacote.

Para elevar a fidelidade até o nível de ilustrações ou personagens comerciais, a próxima etapa artística precisará de meshes originais, UVs/texturas, variações corporais com skinning e clips produzidos para o rig. Essa etapa não está implícita nos renders atuais. Os volumes nativos são uma solução estilizada e relativamente simples; detalhes próximos e interseções durante movimento precisam de revisão no Roblox Studio.

As prévias em `previews/` são reproduzíveis por `python3 scripts/render_npc_v2_preview.py`: o factory Luau gera as peças; a mesma hierarquia Motor6D e as mesmas poses calculam os transforms; Blender reconstrói essas formas e renderiza. Não há imagem conceitual gerada substituindo geometria ausente. Materiais, câmera e iluminação do Blender diferem dos do jogo. As imagens não validam desempenho, animação contínua ou física Roblox.

O efeito arcano é uma esfera pequena de Neon com variação local limitada de tamanho/transparência. Não usa ParticleEmitter, luz dinâmica ou habilidade de combate. Livro, martelo, escudo, espada embainhada e cajado são adereços visuais; não concedem equipamento ou dano.
