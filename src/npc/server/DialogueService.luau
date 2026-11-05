-- Client sends only a single-use token and an index into server-owned options.
local Players=game:GetService('Players')
local Http=game:GetService('HttpService')
local Shared=game.ReplicatedStorage.EldravynNPC
local C=require(Shared.Registry)
local Data=require(script.Parent.NPCDataService)
local Actions=require(script.Parent.NPCActionService)
local D={Sessions={},Limits={}}
function D.near(player,npc)
 local character=player.Character;local root=character and character:FindFirstChild('HumanoidRootPart')
 local hum=character and character:FindFirstChildOfClass('Humanoid');local head=npc and npc:FindFirstChild('Head')
 if not root or not hum or hum.Health<=0 or not head or not npc:IsDescendantOf(workspace) then return false end
 if (root.Position-head.Position).Magnitude>C.PromptDistance+2 then return false end
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude
 params.FilterDescendantsInstances={character,workspace:FindFirstChild('EldravynNPCs') or npc};params.IgnoreWater=true
 local hit=workspace:Raycast(root.Position,head.Position-root.Position,params)
 return hit==nil or hit.Instance:IsDescendantOf(npc)
end
function D.send(player,session,page,notice)
 local menu=Actions.menu(player,session.NPC,page)
 session.Page=page;session.Options=menu.Options;session.Token=Http:GenerateGUID(false);session.Expires=os.clock()+C.SessionSeconds;session.NPC:SetAttribute('NPCSpeakingUntil',session.Expires)
 local role=C.Roles[session.NPC:GetAttribute('NPCRole')]
 local choices={};for _,v in menu.Options do table.insert(choices,{Label=v.Label,Enabled=v.Enabled})end
 D.View:FireClient(player,{Token=session.Token,Name=role.Name,Title=role.Title,Text=menu.Text,Notice=notice,Options=choices})
end
function D.close(player)
 D.Sessions[player]=nil;if D.View then D.View:FireClient(player,{Close=true})end
end
function D.open(player,npc)
 local now=os.clock();if now<(D.Limits[player] or 0) then return false end;D.Limits[player]=now+0.3
 local previous=D.Sessions[player];if previous and previous.Busy then return false end
 if Actions.NPCs[npc:GetAttribute('EldravynNPCId')]~=npc or not D.near(player,npc) then return false end
 if not Data.get(player) then
  D.View:FireClient(player,{Close=true,Notice='Perfil indisponível. Aguarde ou reconecte; nenhuma compra foi realizada.'});return false
 end
 local s={NPC=npc,Busy=true};D.Sessions[player]=s
 local ok,err=pcall(function()Data.event(player,'Talk:'..npc:GetAttribute('NPCRole'),'Interaction');D.send(player,s,'Root')end)
 s.Busy=false;if not ok then warn('[NPC] Interação falhou: '..tostring(err));D.close(player)end
 return ok
end
function D.handle(player,payload)
 local now=os.clock();if now<(D.Limits[player] or 0) then return false end;D.Limits[player]=now+0.2
 local s=D.Sessions[player]
 if not s or s.Busy or type(payload)~='table' or type(payload.Token)~='string' or #payload.Token>80 or payload.Token~=s.Token then return false end
 if not require(Shared.Rules).integer(payload.Choice,1,#s.Options) then return false end
 if now>s.Expires or not D.near(player,s.NPC) then D.close(player);return false end
 local option=s.Options[payload.Choice];if not option.Enabled then return false end
 -- Invalidate before any yielding persistence or marketplace calls.
 s.Busy=true;s.Token=nil
 local ok,err=pcall(function()
  local command=option.Command
  if command=='Close' then D.close(player)
  elseif command=='Page' then s.Pending=nil;D.send(player,s,option.Value)
  elseif command=='Mark' then
   local target=Actions.Locations[option.Value]
   if target then D.View:FireClient(player,{Marker={Name=target.Name,Position=target.Position,Seconds=45}})end
   D.send(player,s,s.Page,'Destino marcado por 45 segundos.')
  elseif command=='Confirm' then
   local pending=s.Pending;s.Pending=nil;local state=Data.get(player)
   if not pending or not state or state.Revision~=s.Revision then D.send(player,s,'Root','Os dados mudaram. Consulte os custos e confirme novamente.');return end
   local accepted,message=Actions.execute(player,s.NPC,pending)
   D.send(player,s,'Root',message or (if accepted then 'Operação concluída.' else 'Operação indisponível.'))
  else
   local state=Data.get(player);if not state then D.close(player);return end
   s.Pending=option;s.Revision=state.Revision;s.Options={{Label='Confirmar',Command='Confirm',Enabled=true},{Label='Cancelar / voltar',Command='Page',Value=s.Page,Enabled=true},{Label='Encerrar',Command='Close',Enabled=true}}
   s.Token=Http:GenerateGUID(false);s.Expires=now+C.SessionSeconds
   D.View:FireClient(player,{Token=s.Token,Name=C.Roles[s.NPC:GetAttribute('NPCRole')].Name,Title='Confirmação',Text=option.Label..'\nConfirme esta operação. Custos e requisitos serão verificados novamente pelo servidor.',Options={{Label='Confirmar',Enabled=true},{Label='Cancelar / voltar',Enabled=true},{Label='Encerrar',Enabled=true}}})
  end
 end)
 s.Busy=false
 if not ok then warn('[NPC] Operação interrompida: '..tostring(err));D.close(player)end
 return ok
end
function D.start(view,action)
 D.View=view;action.OnServerEvent:Connect(D.handle)
 Players.PlayerRemoving:Connect(function(p)D.Sessions[p]=nil;D.Limits[p]=nil end)
end
return D
