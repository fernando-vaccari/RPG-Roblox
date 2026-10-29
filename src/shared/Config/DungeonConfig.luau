-- Static floors are built once in the editor. Runtime only enables encounters/portals.
return {
 Order={'MalgorthDepths','FallenSanctum'},MaxPlayers=4,TicketSeconds=600,RunSeconds=3600,
 Dungeons={
  MalgorthDepths={Name='Abismo de Malgorth',Floors=10,MinLevel=1,X=480,Z=300,Tint={125,55,75},FinalBoss='Malgorth',
   Titles={'Porta do Juramento','Arquivo dos Exilados','Jardim da Cinza','Forja dos Grilhões','Vigília do Cavaleiro','Ponte dos Lamentos','Catacumbas do Selo','Biblioteca Proibida','Átrio da Ruptura','Coroa de Malgorth'}},
  FallenSanctum={Name='Santuário do Reino Caído',Floors=20,MinLevel=20,X=900,Z=300,Tint={76,103,161},FinalBoss='FallenRegent',
   Titles={'Escadaria da Aurora','Cripta dos Nomes','Estufa do Eclipse','Oficina dos Autômatos','Tribunal de Pedra','Travessia das Estrelas','Ossuário Real','Arquivo da Tempestade','Raízes do Palácio','Cavaleiro da Vigília','Ponte da Lua Morta','Sepulcro das Coroas','Biblioteca do Vazio','Jardim da Última Chuva','Arauto do Eclipse','Passagem dos Desterrados','Cripta do Primeiro Rei','Memória do Reino','Trono Vazio','Regente do Reino Caído'}},
 },
 Layouts={'Crypt','Library','Garden','Forge','Arena','Bridge'},
}
