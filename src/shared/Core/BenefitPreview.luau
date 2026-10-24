-- Approved grants only. Preview is a report and never mutates any wallet/receipt/race.
local Preview={}
function Preview.report(profile,config,key)
 local product=config.Products[key]
 if not product then return nil,'Benefícios deste produto ainda não definidos.' end
 local id=profile.Identity
 if not id then return nil,'Perfil indisponível.' end
 local before=if product.Grant=='Retry' then id.RetryCredits else id.Fusion[product.Grant]
 if type(before)~='number' then return nil,'Tipo de benefício desconhecido.' end
 return {Product=key,PlannedPrice=product.Robux,Grant=product.Grant,Before=before,After=math.min(1000000,before+product.Amount),Preview=true}
end
return Preview
