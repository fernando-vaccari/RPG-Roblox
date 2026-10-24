# Continuação exata após qualidade 0.5.0

1. Ler docs/IMPROVEMENTS.md, PROGRESS, TEST_RESULTS e os catálogos. Preservar todos os IDs, dois Places e DataStore MedievalRPG_v1; não recomeçar o projeto.
2. Base atual passou em compilação/regras/mock. Continuar por preocupações concretas: recuperação prolongada de storage, concorrência realista de save/teleporte/recibos, cenários multi-alvo/lag/streaming e polimento das habilidades que compartilham arquétipos. Não repetir suítes sem mudança ou motivo.
3. Os projéteis selecionados são lineares e varrem colisões no servidor; Campo de Chamas pulsa. Não voltar a chamá-los todos de acerto instantâneo. Cancelamento por morte/classe e limites são parte da segurança, não devem ser removidos para aumentar espetáculo.
4. Cenário novo é gerado pelo mesmo comando de editor; o mapa antigo não foi alterado. Interiores/torres superiores, passagens e estética ainda exigem inspeção física futura. Nunca limpar Terrain para contornar preflight.
5. VIP/pacotes iniciais aguardam benefícios/preços; fusões aguardam combinações/resultados/resolvedor. Não inventar decisões. Produtos existentes continuam IDs 0. Tester faz relatórios e só funciona com opt-in em Studio sem persistência; nunca ativar concessões/admin em produção.
6. Áudios originais aguardam upload autorizado. Nenhum ID deve ser inventado. Preferências visuais são locais, não mudam regras ou densidade do mundo.
7. Quando o usuário decidir testar manualmente, usar docs/STUDIO_TEST_MATRIX.md incluindo os casos de qualidade/projétil/saída congelada. Não exigir Studio como condição para continuar programação agora.
8. Depois de código: python3 scripts/check.py; depois python3 scripts/package.py. Catálogos são gerados pelo check. Registrar resultados/limitações e atualizar docs/IMPROVEMENTS.md.

Não publicar, enviar ao GitHub ou ativar compras sem autorização. Não criar worktrees salvo solicitação explícita. Esta tarefa não declara o jogo 100% funcional/homologado.
