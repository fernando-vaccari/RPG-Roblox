-- Every floor has a distinct ticket and contract. No destination is invented.
local C={Order={'MalgorthDepths','FallenSanctum'},Dungeons={
 MalgorthDepths={Name='Abismo de Malgorth',Floors=10,Rank='F',PlaceId=0,EntryEnabled=false,InteriorReady=false,RewardPreview='Recompensas serão validadas pela futura integração da dungeon.'},
 FallenSanctum={Name='Santuário do Reino Caído',Floors=20,Rank='E',PlaceId=0,EntryEnabled=false,InteriorReady=false,RewardPreview='Recompensas serão validadas pela futura integração da dungeon.'}},Tickets={}}
for _,id in C.Order do
 local d=C.Dungeons[id]
 for floor=1,d.Floors do
  local key=id..':'..floor
  local rank=if floor>15 then 'B' elseif floor>10 then 'C' elseif floor>5 then 'D' else d.Rank
  C.Tickets[key]={Dungeon=id,Floor=floor,Name=d.Name..' • andar '..floor,Price=40+floor*15,Rank=rank,Quest='Ticket:'..key}
 end
end
return C
