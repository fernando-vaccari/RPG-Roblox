-- Único ProcessReceipt da Experience. Ambos os Places usam o mesmo perfil/ledger.
local Market=game:GetService('MarketplaceService')
local Players=game:GetService('Players')
local Shared=game.ReplicatedStorage.MedievalRPG
local Config=require(Shared.Config.IdentityConfig)
local Rules=require(Shared.Core.IdentityRules)
local Data=require(script.Parent.DataService)
local Purchase={OnGrant=nil,OnPending=nil}
function Purchase.available(key)
 local p=Config.Products[key]
 return p~=nil and p.Id>0 and Data.Persistent and (key=='RacialRetry' or next(Config.Fusion.Recipes)~=nil)
end
function Purchase.prompt(player,key)
 local profile=Data.get(player);local p=Config.Products[key]
 if not profile or not Purchase.available(key) then return false,'Compra desativada: produto real e catálogo devem estar configurados.' end
 if key=='RacialRetry' then
  Rules.refresh(profile,Config,os.time())
  if profile.Identity.Racial.Status~='Failed' or os.time()>=profile.Identity.Racial.ReadyAt or profile.Identity.RetryCredits>0 then return false,'Nova tentativa paga não é necessária.' end
 end
 local receiptCount=0;for _ in profile.Identity.Receipts do receiptCount+=1 end
 if receiptCount>=1024 then return false,'Novas compras pausadas; o histórico precisa de manutenção segura.' end
 local ok,info=pcall(function() return Market:GetProductInfoAsync(p.Id,Enum.InfoType.Product) end)
 if not ok or not info.IsForSale or info.PriceInRobux~=p.Robux then return false,'Produto/preço oficial não corresponde à configuração. Nenhuma compra aberta.' end
 local prompted=pcall(function() Market:PromptProductPurchase(player,p.Id) end)
 return prompted,if prompted then 'Confirme somente na janela oficial Roblox.' else 'Não foi possível abrir a compra.'
end
function Purchase.process(receipt)
 local pending=Enum.ProductPurchaseDecision.NotProcessedYet
 if type(receipt)~='table' or type(receipt.PurchaseId)~='string' or #receipt.PurchaseId<1 or #receipt.PurchaseId>200 then return pending end
 local known=false
 for _,p in Config.Products do if p.Id>0 and p.Id==receipt.ProductId then known=true end end
 if not known then return pending end
 local player=Players:GetPlayerByUserId(receipt.PlayerId)
 if not player then return pending end
 if not Data.receipt(player,receipt.PurchaseId,receipt.ProductId) then
    if Purchase.OnPending then Purchase.OnPending(player) end
    return pending
 end
 if Purchase.OnGrant then Purchase.OnGrant(player) end
 return Enum.ProductPurchaseDecision.PurchaseGranted
end
function Purchase.start()
 Rules.validate(Config)
 Market.ProcessReceipt=Purchase.process
end
return Purchase
