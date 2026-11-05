-- Item ownership reuses the existing profile.Inventory; no Tools or equip actions.
return {Items={
 Longsword={Name='Espada longa',Price=120,Sell=48,Kind='Weapon',Rarity='Comum',MinRank='F'},
 Katana={Name='Katana',Price=140,Sell=56,Kind='Weapon',Rarity='Comum',MinRank='F'},
 Staff={Name='Cajado',Price=120,Sell=48,Kind='Weapon',Rarity='Comum',MinRank='F'},
 Bow={Name='Arco',Price=140,Sell=56,Kind='Weapon',Rarity='Comum',MinRank='F'},
 Armor={Name='Couraça',Price=150,Sell=60,Kind='Armor',Rarity='Incomum',MinRank='F'},
 Potion={Name='Poção selada',Price=20,Sell=8,Kind='Consumable',Rarity='Comum',MinRank='F',Note='Armazenada; nenhum efeito de consumo nesta etapa.'},
 Ore={Name='Minério de Durakh',Price=12,Sell=4,Kind='Material',Rarity='Comum',MinRank='F'},
 TravelRelic={Name='Relíquia da Caravana',Price=250,Sell=80,Kind='Material',Rarity='Rara',MinRank='E',Note='Objeto de coleção; sem efeitos.'}},
 Shops={Weapons={'Longsword','Katana','Staff','Bow'},Armor={'Armor'},General={'Potion','Ore'},TravelShop={'TravelRelic','Bow','Ore'}},
 Upgrade={Max=5,GoldPerLevel=30,OrePerLevel=2}}
