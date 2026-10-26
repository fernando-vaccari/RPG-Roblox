local Players=game:GetService('Players')
local Shared=game.ReplicatedStorage.MedievalRPG
local Config=require(Shared.Config.AdventureConfig)
local Rules=require(Shared.Core.AdventureRules)
local Identity=require(Shared.Config.IdentityConfig)
local Dungeon=require(Shared.Config.DungeonConfig)
local A={}
function A.bind(ui)
 function ui.character()
  ui.clear();ui.Panel.Visible=true;ui.Role=nil;ui.View='Character';ui.Title.Text='Seu personagem'
  local state=ui.State;local race=state and state.Identity and Identity.Races[state.Identity.Race]
  ui.Dialogue.Text=Config.Title..'\n'..(race and ('Linhagem permanente: '..race.Name..' • '..race.Identity) or 'Linhagem aguardando gravação segura.')
  if not state then ui.info('Aguardando o perfil salvo.');return end
  if state.StarterChosen then
   ui.info('Classe atual: '..state.Class..'. O mesmo personagem e a raça original são carregados ao reconectar.')
   ui.button('Árvore de classes e evolução racial',ui.identity)
  else
   ui.info('A primeira arma é gratuita. Escolha o estilo que deseja aprender; o servidor registra uma única escolha.')
   for _,v in {{'Guerreiro','Longsword','Resistência, defesa e golpes amplos.'},{'Espadachim','Katana','Combos rápidos e precisão.'},{'Mago','Staff','Projéteis, controle e cura.'},{'Arqueiro','Bow','Alternativa preservada: ataques à distância.'}} do
    ui.info(v[3]);ui.button(v[1],'CreateCharacter',v[2])
   end
  end
  ui.button('Tutorial e história',ui.tutorial)
 end
 function ui.tutorial()
  ui.clear();ui.Panel.Visible=true;ui.Role=nil;ui.View='Tutorial';ui.Title.Text='O primeiro juramento'
  ui.Dialogue.Text='Os sinos de Valoria ainda anunciam manhãs tranquilas. Maelis pede ajuda para manter as estradas abertas enquanto a corrupção desperta no norte.'
  local state=ui.State
  for _,step in Config.Tutorial do
   local done=state and state.Adventure and state.Adventure.Tutorial[step.Id]
   ui.info((if done then '✓ ' else '○ ')..step.Name..'\n'..step.Text)
  end
  ui.info('Guilda: ao sul de Valoria, X 0 / Z 1480. O parceiro de treino não concede saque e anuncia cada ataque.')
  ui.button('Personagem',ui.character);ui.button('Atlas',ui.map)
 end
 function ui.expeditions()
  ui.clear();ui.Panel.Visible=true;ui.Role=nil;ui.View='Expeditions';ui.Title.Text='Expedições'
  ui.Dialogue.Text='Solo ou até quatro aventureiros. Reúna sobreviventes no portal após limpar cada andar. Morte elimina você desta tentativa.'
  for _,id in Dungeon.Order do
   local d=Dungeon.Dungeons[id];local best=ui.State and ui.State.Expedition and ui.State.Expedition.Best[id] or 0
   ui.info(d.Name..' • '..d.Floors..' andares • nível '..d.MinLevel..'\nMelhor andar confirmado: '..best..'. Recompensa de avanço é concedida uma vez por andar.')
  end
  ui.info('As tentativas recomeçam no andar 1. Melhor andar, primeira conclusão e baús individuais ficam salvos. O progresso é confirmado ao usar o portal.')
  ui.button('Atlas das entradas',ui.map)
 end
 local gui=ui.Hud.Parent
 local guide=Instance.new('TextButton');guide.Name='TutorialTracker';guide.Size=UDim2.new(0.56,0,0,48);guide.Position=UDim2.fromOffset(10,134)
 guide.TextSize=14;guide.TextWrapped=true;guide.Font=Enum.Font.Garamond;guide.TextColor3=Color3.fromRGB(235,204,142);guide.BackgroundColor3=Color3.fromRGB(31,34,39);guide.BackgroundTransparency=0.2;guide.Parent=gui
 guide.Activated:Connect(ui.tutorial);ui.Guide=guide
 local function screen(name,title)
  local frame=Instance.new('Frame');frame.Name=name;frame.Size=UDim2.fromScale(1,1);frame.BackgroundColor3=Color3.fromRGB(20,24,33);frame.BackgroundTransparency=0.12;frame.ZIndex=20;frame.Visible=false;frame.Parent=gui
  local text=Instance.new('TextLabel');text.Size=UDim2.fromScale(0.8,0.3);text.Position=UDim2.fromScale(0.1,0.3);text.BackgroundTransparency=1;text.TextColor3=Color3.fromRGB(236,209,152);text.TextWrapped=true;text.TextSize=24;text.Font=Enum.Font.Garamond;text.ZIndex=21;text.Text=title;text.Parent=frame
  return frame,text
 end
 local loading,loadingText=screen('ProfileLoading',Config.Title..'\nCarregando seu personagem...')
 local death,deathText=screen('DeathScreen','O juramento permanece.\nAguardando o renascimento...')
 loading.Visible=ui.State==nil
 function ui.refreshAdventure()
  local state=ui.State;loading.Visible=state==nil or Players.LocalPlayer:GetAttribute('ProfileStatus')=='Unavailable'
  if loading.Visible and Players.LocalPlayer:GetAttribute('ProfileStatus')=='Unavailable' then loadingText.Text='Perfil indisponível. Seu progresso foi preservado. Reconecte para tentar novamente.' end
  local p=Players.LocalPlayer;local hum=p.Character and p.Character:FindFirstChildOfClass('Humanoid')
  death.Visible=state~=nil and hum~=nil and hum.Health<=0
  deathText.Text='Você caiu. Seu personagem renascerá em instantes.\n'..(if p:GetAttribute('InDungeon') then 'Esta tentativa terminou para você. Andares confirmados e itens salvos permanecem.' else 'Retorne à hospedaria e prepare sua próxima jornada.')
  if p:GetAttribute('DungeonName') then
   guide.Visible=true;guide.Text=p:GetAttribute('DungeonName')..' • '..tostring(p:GetAttribute('DungeonFloor'))..'/'..tostring(p:GetAttribute('DungeonFloors'))..'\nGuardiões restantes: '..tostring(p:GetAttribute('DungeonRemaining'))..' • '..tostring(p:GetAttribute('DungeonState'))
  elseif state then
   local step,index=Rules.current(state,Config)
   guide.Visible=step~=nil;guide.Text=if step then 'Tutorial '..index..'/'..#Config.Tutorial..' • '..step.Name..'\nToque para ver o objetivo.' else ''
  end
 end
 return ui
end
return A
