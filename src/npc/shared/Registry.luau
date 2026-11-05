local C=table.clone(require(script.Parent.NPCConfig))
local shop=require(script.Parent.ShopConfig)
C.Items=shop.Items;C.Shops=shop.Shops;C.Upgrade=shop.Upgrade
C.Dungeon=require(script.Parent.DungeonTicketConfig)
C.Quests=table.clone(require(script.Parent.QuestConfig))
local regions={'Valoria','Eldoria','Durakh','Arkheim','Asterion','Sylvarin','Nocthar','Vespera'}
for key,t in C.Dungeon.Tickets do
 C.Quests[t.Quest]={Name='Autorização: '..t.Name,Rank=t.Rank,Gold=0,XP=12,Ticket=key,Cooldown=86400,
  Objectives={{Event='Visit:'..regions[(t.Floor-1)%#regions+1],Need=1},{Event='Talk:Guide',Need=1}},
  Description='Visite a região indicada e converse com uma guia. Uma autorização específica por conclusão.'}
end
C.Dialogue=require(script.Parent.DialogueConfig)
return C
