# Auditoria e escopo da continuação

A base já possuía continente/dungeon, planejamento de lotes, rigs, diálogos, economia, seis quests, perfil opcional e grupos. Foi preservada. Combate tinha somente ataque primário e pulso, sem recursos ou níveis. Não havia 35 missões nem catálogo de habilidades.

Nesta continuação: adicionados AbilityConfig e CombatRules; CombatService existente ampliado, GameService/EnemyService/UI integrados. Progression existente ganhou requisitos, venda, desbloqueios e marcador persistente da escolha gratuita. Regressões verificadas: desequipar/vender não libera outra arma gratuita; classe não some ao salvar desequipado; rejeição por recurso/cooldown não debita duas vezes.

Limites ainda reais: som não toca sem assets Roblox próprios publicados; não foram inventados IDs. Efeitos/poses são procedurais simples. Habilidades são efeitos autoritativos imediatos com linha de visão (não projéteis físicos em voo). Bosses usam o mesmo rig-base com variações e duas fases de alcance/frequência, sem animações profissionais ou telegraph avançado. Física, combate multiplayer e balanceamento não foram validados no engine.

A próxima prioridade continua sendo melhorar/verificar o código automaticamente; o usuário adiou os testes manuais. Não solicitar abertura do Studio como pré-condição para continuar programação.
