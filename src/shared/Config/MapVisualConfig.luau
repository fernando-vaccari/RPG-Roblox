-- Visual budgets only. Never used by damage, collision or gameplay rules.
return table.freeze({
    Modes={'AUTO','LOW','MEDIUM','HIGH'},
    Labels={AUTO='Automático',LOW='Baixo',MEDIUM='Médio',HIGH='Alto'},
    Presets={'Dawn','Day','Sunset','Night','Rain','Fog','Storm'},
    PresetLabels={Dawn='Amanhecer',Day='Dia',Sunset='Entardecer',Night='Noite',Rain='Chuva',Fog='Neblina',Storm='Tempestade'},
    Profiles={
        LOW={Lights=12,LightDistance=90,Shadows=false,Particles=0,ParticleDistance=60,DetailScale=0.65,Bloom=0.025},
        MEDIUM={Lights=28,LightDistance=150,Shadows=true,Particles=10,ParticleDistance=100,DetailScale=1,Bloom=0.075},
        HIGH={Lights=48,LightDistance=220,Shadows=true,Particles=20,ParticleDistance=160,DetailScale=1.35,Bloom=0.12},
    },
    UpdateSeconds=0.8,
})
