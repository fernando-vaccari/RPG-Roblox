# Análise anterior à implementação — 31/10/2026

Base: commit `0f21f59`, versão NPC Stage 2. Inspecionados Installer, NPCConfig, PlacementConfig, R15Factory, NPCService, AmbientService, DialogueService, cliente, empacotadores, testes e o XML entregue. Os caminhos reais estão em `INSPECTION.json`: 66 modelos existentes em Workspace/EldravynNPCs, identidade por EldravynNPCId/NPCRole/City, Humanoid+Animator, 15 motores R15 e Head/NPCInteraction. Não foram encontrados meshes/texturas de personagem próprios nem IDs de animações publicados. A imagem enviada orienta camadas de armadura, cabelo, rosto e acessórios; não será copiada como personagem.

## Dependências e compatibilidade

- O bootstrap atual NPCService é o único dono da inicialização, do perfil e dos prompts. Continua ativo; não será criado segundo bootstrap servidor ou DataStore.
- DialogueService.Sessions contém a interação real autorizada. A atenção V2 consulta essa tabela, sem mudar remotes, permissões, compras ou menus.
- AmbientService é o ponto de extensão para comportamento. Seu código V1 continua como fallback; V2 usa um controlador único com atualização limitada e cancelamento.
- O cliente atual escreve Neck.Transform. É necessário um desvio opt-in para entregar os motores ao controlador V2 e evitar dois escritores; UI e marcador permanecem intactos.
- NPCService atualmente reposiciona personagens no início usando PlacementConfig. Na V2 será usado um adaptador que mantém o CFrame atual e somente relata problemas de piso. PlacementConfig não será alterado.
- Atualizador opera apenas no editor e em instalação existente. Não chama Installer.Install, Terrain ou geradores. Verifica versões, identidade, rig e scripts conhecidos antes de mudar algo. Customizações incompatíveis interrompem a atualização para revisão, em vez de serem sobrescritas.

## Estratégia de preservação

Não substituir modelos de NPC, Humanoid, Animator, motores, prompts ou atributos de identidade. Manter a geometria corporal e as juntas do rig; modificar apenas propriedades visuais e acrescentar roupas/cabelos/rosto nativos. Adornos V1 serão guardados, com propriedades visuais e os poucos módulos adaptados, em backup separado. Todas as operações terão registros reversíveis e versão visual independente da instalação V1. Repetir Apply não duplica; Rollback repõe os objetos originais.

## Limitações e riscos reais

Sem Roblox Studio nesta máquina: rig, animação, física, interfaces, rede e FPS reais exigem teste manual. Recursos nativos não reproduzem o nível de texturas/meshes da referência: serão formas originais detalhadas, materiais e cores, sem alegar assets profissionais publicados. Tracks oficiais ficam com IDs vazios e fallback procedural funcional. Atenção/movimentos visuais são locais; deslocamento físico limitado é do servidor. Consultas de piso/obstáculos e interrupção de percurso precisam de teste no engine. O alerta Defender anterior continua indeterminado; não há verificação de antivírus nem promessa de ausência de alerta.

Plano: (1) aparências e rigs preservados; (2) controladores de animação, atenção, desempenho e comportamento; (3) migração/rollback idempotentes; (4) testes, comparação dos arquivos protegidos e prévia da geometria real; (5) pacote de atualização e documentação. Economia, missões, classes, salvamento e GeneratedWorld estão fora das alterações.
