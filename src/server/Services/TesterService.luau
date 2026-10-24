local Run=game:GetService('RunService')
local Shared=game.ReplicatedStorage.MedievalRPG
local Settings=require(Shared.Config.WorldConfig)
local Config=require(Shared.Config.IdentityConfig)
local Preview=require(Shared.Core.BenefitPreview)
local Data=require(script.Parent.DataService)
local T={}
function T.allowed()return Run:IsStudio() and Settings.EnableStudioTester==true and not Data.Persistent end
function T.preview(player,key)
 if not T.allowed()then return nil,'Tester permitido somente no Studio, opt-in e sem persistência.' end
 local profile=Data.get(player);if not profile then return nil,'Perfil indisponível.' end
 return Preview.report(profile,Config,key)
end
return T
