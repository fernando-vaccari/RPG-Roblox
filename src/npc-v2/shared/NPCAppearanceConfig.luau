-- Original designs made from native Roblox geometry. No uploaded asset dependency.
local C={Version=2,MaxVisualParts=150,DetailDistance=42}
C.Cities={
 Valoria={Cloth={29,49,69},Accent={194,158,87},Metal={132,143,154}},
 Arkheim={Cloth={94,43,44},Accent={179,135,84},Metal={95,106,116}},
 Eldoria={Cloth={39,88,78},Accent={175,192,160},Metal={149,167,164}},
 Durakh={Cloth={105,74,46},Accent={184,125,72},Metal={111,119,124}},
 Asterion={Cloth={70,58,105},Accent={191,183,215},Metal={153,158,181}},
 MalgorthDepths={Cloth={65,39,48},Accent={171,115,77},Metal={104,112,127}},
 FallenSanctum={Cloth={55,67,87},Accent={173,183,194},Metal={136,151,168}},
}
C.Roles={
 GuildMaster={Style='Commander',Hair='Swept',Cape=true,Armor=true,Book=true,Sword=true,Work='Documents',HairColor={224,215,192}},
 Reception={Style='Scribe',Hair='Braided',Book=true,Work='Documents'},
 Guard={Style='Guard',Hair='Short',Cape=true,Armor=true,Sword=true,Shield=true,Helmet=true,Work='Observe',Patrol=true},
 Classes={Style='Veteran',Hair='Swept',Armor=true,Sword=true,Cape=true,Work='Inspect'},
 Skills={Style='Duelist',Hair='Short',Sword=true,Work='Inspect'},
 Blacksmith={Style='Smith',Hair='Short',Apron=true,Hammer=true,Work='Forge',HairColor={56,45,39}},
 Armor={Style='Armorer',Hair='Braided',Armor=true,Apron=true,Work='Organize'},
 Weapons={Style='Quartermaster',Hair='Swept',Sword=true,Work='Organize'},
 General={Style='Merchant',Hair='Swept',Work='Trade'},
 TravelShop={Style='Nomad',Hair='Braided',Cape=true,Backpack=true,Work='Trade'},
 Magic={Style='Mage',Hair='Long',Cape=true,Robe=true,Staff=true,Book=true,Work='Study'},
 Races={Style='Lorekeeper',Hair='Long',Robe=true,Cape=true,Book=true,Work='Study'},
 Fusions={Style='Artificer',Hair='Swept',Robe=true,Staff=true,Monocle=true,Work='Study'},
 Inn={Style='Host',Hair='Braided',Apron=true,Cup=true,Work='Serve'},
 Healer={Style='Healer',Hair='Long',Robe=true,Work='Study'},
 Bank={Style='Clerk',Hair='Short',Book=true,Monocle=true,Work='Documents'},
 Guide={Style='Scout',Hair='Swept',Cape=true,Work='Orient'},
 Tutorial={Style='Page',Hair='Swept',Work='Orient'},
 Dungeon={Style='Warden',Hair='Long',Armor=true,Cape=true,Work='Inspect'},
 Resident={Style='Citizen',Hair='Swept',Work='Observe',Patrol=true},
 Traveler={Style='Traveler',Hair='Long',Backpack=true,Work='Observe',Patrol=true},
 Artisan={Style='Artisan',Hair='Short',Apron=true,Hammer=true,Work='Forge'},
 Employee={Style='Assistant',Hair='Braided',Apron=true,Work='Organize'},
 Adventurer={Style='Ranger',Hair='Swept',Cape=true,Sword=true,Work='Observe',Patrol=true},
 Farmer={Style='Farmer',Hair='Short',Apron=true,Hat=true,Work='Observe',Patrol=true},
}
local skins={{230,191,160},{198,147,111},{156,107,81},{239,209,184},{174,126,101}}
local hairs={{65,43,32},{132,92,55},{197,170,118},{42,39,47},{176,182,190},{119,54,41}}
local eyes={{67,113,112},{121,91,54},{92,101,137},{108,135,89}}
function C.hash(id)
 local n=17;for i=1,#id do n=(n*31+string.byte(id,i))%104729 end;return n
end
function C.forNPC(id,role,city)
 assert(type(id)=='string' and C.Roles[role] and C.Cities[city],'Visual V2: identidade/papel/cidade desconhecidos')
 local n=C.hash(id);local out=table.clone(C.Roles[role]);local palette=C.Cities[city]
 out.Id=id;out.Role=role;out.City=city;out.Variant=n%3+1
 out.Skin=skins[n%#skins+1];out.HairColor=out.HairColor or hairs[n%#hairs+1];out.Eyes=eyes[n%#eyes+1]
 out.Cloth=palette.Cloth;out.Accent=palette.Accent;out.Metal=palette.Metal
 out.Leather={72+n%12,49+n%8,36+n%6};out.Linen={207,197,170};out.MaxParts=C.MaxVisualParts
 if role=='Healer' then out.Cloth={202,206,185}end
 return out
end
return C
