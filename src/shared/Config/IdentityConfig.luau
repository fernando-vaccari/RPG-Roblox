-- Probabilidades em pontos inteiros: limites auditáveis, sem peso vindo do cliente.
return {
 Version=1,RetrySeconds=86400,RacialDuration=1800,RacialLevel=15,EvolutionFragments=5,
 RaceOrder={'Humano','Elfo','ElfoNegro','Demonio','Anjo'},
 Races={
  Humano={Name='Humano',Weight=70,Identity='Versatilidade e perseverança',Color={194,153,109},Shape='Crest',Health=5,Mana=-5,Stamina=0,Skill='Resolve',Evolution='Guardião do Pacto',Steps={{Event='Visit:Arkheim',Count=1},{Event='Bandit',Count=5},{Event='Ruins',Count=1}}},
  Elfo={Name='Elfo',Weight=12,Identity='Memória e proteção da floresta',Color={90,174,111},Shape='Ears',Health=-10,Mana=10,Stamina=0,Skill='SylvanBreath',Evolution='Sentinela Ancestral',Steps={{Event='Visit:Sylvarin',Count=1},{Event='Wolf',Count=5},{Event='Herb',Count=1}}},
  ElfoNegro={Name='Elfo Negro',Weight=8,Identity='Equilíbrio entre segredo e conhecimento',Color={122,102,173},Shape='DarkEars',Health=0,Mana=8,Stamina=-8,Skill='ShadowFocus',Evolution='Oráculo do Crepúsculo',Secret='Twilight',Steps={{Event='Visit:Nocthar',Count=1},{Event='Skeleton',Count=3},{Event='Mage',Count=1}}},
  Demonio={Name='Demônio',Weight=6,Identity='Domínio da própria chama; força com disciplina',Color={174,76,79},Shape='Horns',Health=0,Mana=-10,Stamina=10,Skill='EmberWill',Evolution='Juramentado das Cinzas',Steps={{Event='Ruins',Count=1},{Event='Demon',Count=4},{Event='Knight',Count=1}}},
  Anjo={Name='Anjo',Weight=4,Identity='Proteção sem superioridade absoluta',Color={224,210,135},Shape='Halo',Health=-5,Mana=5,Stamina=0,Skill='DawnGrace',Evolution='Arauto da Aurora',Secret='Dawn',Steps={{Event='Talk:Valoria:Healer',Count=1},{Event='Visit:Eldoria',Count=1},{Event='Shadow',Count=2}}},
 },
 PrimaryClasses={'Guerreiro','Espadachim','Mago'},LegacyClasses={'Arqueiro'},
 Advanced={
  Tanque={Base='Guerreiro',Level=20,Steps={{Event='Talk:Arkheim:Guard',Count=1},{Event='Skeleton',Count=5},{Event='Visit:Durakh',Count=1}}},
  ['Valquíria']={Base='Guerreiro',Level=25,Steps={{Event='Visit:Eldoria',Count=1},{Event='SylvarinBoss',Count=1},{Event='Knight',Count=1}}},
  Samurai={Base='Espadachim',Level=20,Steps={{Event='Visit:Arkheim',Count=1},{Event='Bandit',Count=8},{Event='Knight',Count=1}}},
  Assassino={Base='Espadachim',Level=25,Secret='Assassin',Steps={{Event='Visit:Nocthar',Count=1},{Event='NoctharBoss',Count=1},{Event='Ruins',Count=1}}},
  Invocador={Base='Mago',Level=20,Steps={{Event='Mage',Count=1},{Event='Herb',Count=2},{Event='SylvarinBoss',Count=1}}},
  Necromante={Base='Mago',Level=25,Secret='Necromancy',Steps={{Event='Skeleton',Count=6},{Event='Shadow',Count=2},{Event='Knight',Count=1}}},
 },
 Secrets={
  Necromancy={Name='Juramento dos Ossos',Region='Nocthar',Hint='Investigue o altar das ruínas sombrias.'},
  Assassin={Name='Passos sem Testemunhas',Region='Nocthar',Hint='O altar guarda mais de um segredo.'},
  Twilight={Name='Memória do Crepúsculo',Region='Nocthar',Hint='A história dos elfos negros repousa nas ruínas.'},
  Dawn={Name='Vigília da Aurora',Region='Sylvarin',Hint='Procure o altar entre as árvores antigas.'},
 },
 Fusion={WeeklyFree=3,FreeTier='Basic',GoldPrice=1500,GoldPack=1,
  Pools={Basic={'Guerreiro','Espadachim','Mago','Arqueiro'},Premium={'Tanque','Valquíria','Samurai','Assassino','Invocador','Necromante'}},Recipes={}}, -- Resultados aguardam definição do criador.
 Products={RacialRetry={Id=0,Robux=150,Grant='Retry',Amount=1},BasicPack={Id=0,Robux=79,Grant='Basic',Amount=3},PremiumPack={Id=0,Robux=149,Grant='Premium',Amount=3}},
 DungeonFragments={Knight=1,Malgorth=3},
}
