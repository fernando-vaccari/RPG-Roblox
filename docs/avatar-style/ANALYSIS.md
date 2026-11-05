# Avatar Roblox — análise e decisão artística

Base preservada: `9a6564c`, atualização V2. Novo pedido de 04/11/2026: substituir a aparência de peças primitivas por personagens no estilo de avatar Roblox, com temas por função/região, incluindo inimigos.

O V2 mantém rigs R15 corretos, mas suas roupas, cabelo e olhos feitos de Part/WedgePart não alcançam a aparência da referência. A imagem enviada é uma referência 2D; não contém malha, rig, UV ou licença de um asset de catálogo. Não foi fornecido `.rbxm`, `.fbx` ou ID verificável. O catálogo/avatar API oficial respondeu HTTP 403 neste ambiente. Não serão inventados IDs nem copiados personagens de catálogo.

Solução: criar malhas originais com proporções de avatar Roblox, cabeça clássica com rosto plano, roupas em camadas, cabelo em volumes contínuos e armaduras com relevo. Produzir FBX com atlas/PBR e nomes de peças estáveis para o Importador 3D do Studio. A importação/publicação na conta proprietária é necessária para obter os IDs reais de mesh/textura; o pacote de integração só aplica visuais quando as malhas importadas estão presentes e verificadas. Sem fallback que repita o visual rejeitado.

Preservação: manter NPCs, Humanoid, Animator, motores, prompts, identidades e posições. Reutilizar os controladores V2. Migração visual reversível tanto sobre Stage 2 quanto sobre V2. Não modificar o mapa, o terreno, a economia, as missões ou os dados. Inimigos reutilizam catálogo/IA existentes mediante adaptador visual opcional; instalar a biblioteca não cria spawns ou inicia combate na etapa NPC.

Limitações: não há Roblox Studio nem publicação de assets nesta máquina. Renderizações offline conferem a geometria produzida, não o resultado no Studio. Verificar importação FBX, texturas, pivôs, animações, física e FPS manualmente. Nenhuma execução de Defender ocorreu. As entregas anteriores permanecem intactas.
