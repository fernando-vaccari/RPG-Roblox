-- One responsive interface shared by every role; prices/options arrive from server.
local UI={}
function UI.new(playerGui,action)
 local screen=Instance.new('ScreenGui');screen.Name='EldravynNPCDialogue';screen.ResetOnSpawn=false;screen.DisplayOrder=25;screen.Parent=playerGui
 local panel=Instance.new('Frame');panel.Name='Dialogue';panel.AnchorPoint=Vector2.new(0.5,0.5);panel.Position=UDim2.fromScale(0.5,0.5);panel.Size=UDim2.fromScale(0.92,0.84);panel.BackgroundColor3=Color3.fromRGB(31,27,24);panel.Visible=false;panel.Parent=screen
 local cap=Instance.new('UISizeConstraint');cap.MaxSize=Vector2.new(660,720);cap.Parent=panel
 local border=Instance.new('UIStroke');border.Color=Color3.fromRGB(177,146,83);border.Thickness=2;border.Parent=panel
 local corner=Instance.new('UICorner');corner.CornerRadius=UDim.new(0,10);corner.Parent=panel
 local title=Instance.new('TextLabel');title.Name='Title';title.Size=UDim2.new(1,-70,0,58);title.Position=UDim2.fromOffset(16,6);title.BackgroundTransparency=1;title.Font=Enum.Font.Garamond;title.TextColor3=Color3.fromRGB(241,216,165);title.TextSize=23;title.TextWrapped=true;title.TextXAlignment=Enum.TextXAlignment.Left;title.Parent=panel
 local close=Instance.new('TextButton');close.Name='Close';close.Text='×';close.TextSize=30;close.Size=UDim2.fromOffset(48,48);close.Position=UDim2.new(1,-56,0,8);close.BackgroundColor3=Color3.fromRGB(75,43,37);close.TextColor3=Color3.fromRGB(255,242,219);close.Parent=panel
 local scroll=Instance.new('ScrollingFrame');scroll.Name='Content';scroll.Position=UDim2.fromOffset(16,72);scroll.Size=UDim2.new(1,-32,1,-88);scroll.BackgroundTransparency=1;scroll.BorderSizePixel=0;scroll.ScrollBarThickness=6;scroll.CanvasSize=UDim2.fromOffset(0,0);scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;scroll.Parent=panel
 local layout=Instance.new('UIListLayout');layout.Padding=UDim.new(0,10);layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Parent=scroll
 local text=Instance.new('TextLabel');text.Name='Body';text.Size=UDim2.new(1,-10,0,0);text.AutomaticSize=Enum.AutomaticSize.Y;text.BackgroundTransparency=1;text.TextColor3=Color3.fromRGB(237,225,203);text.TextSize=18;text.Font=Enum.Font.SourceSans;text.TextWrapped=true;text.TextXAlignment=Enum.TextXAlignment.Left;text.TextYAlignment=Enum.TextYAlignment.Top;text.LayoutOrder=0;text.Parent=scroll
 local toast=Instance.new('TextLabel');toast.Name='Notice';toast.AnchorPoint=Vector2.new(0.5,0);toast.Position=UDim2.fromScale(0.5,0.03);toast.Size=UDim2.new(0.9,0,0,64);toast.BackgroundColor3=Color3.fromRGB(39,34,28);toast.TextColor3=Color3.fromRGB(255,226,166);toast.TextSize=18;toast.Font=Enum.Font.SourceSans;toast.TextWrapped=true;toast.Visible=false;toast.Parent=screen
 local self={Panel=panel,Screen=screen,Token=nil,Options={},Buttons={},Sending=false,NoticeSerial=0}
 function self:choose(index)
  if self.Sending or not self.Token or not self.Options[index] or not self.Options[index].Enabled then return end
  self.Sending=true;action:FireServer({Token=self.Token,Choice=index})
 end
 function self:hide()
  for i,v in self.Options do if v.Label=='Encerrar conversa' or v.Label=='Encerrar' then self:choose(i);break end end
  panel.Visible=false
 end
 close.Activated:Connect(function()self:hide()end)
 function self:receive(payload)
  if payload.Notice and not payload.Token then
   self.NoticeSerial+=1;local serial=self.NoticeSerial;toast.Text=payload.Notice;toast.Visible=true
   task.delay(6,function()if serial==self.NoticeSerial then toast.Visible=false end end)
  end
  if payload.Close then panel.Visible=false;self.Token=nil;return end
  if not payload.Token then return end
  self.Sending=false;self.Token=payload.Token;self.Options=payload.Options or {};panel.Visible=true
  title.Text=payload.Name..' • '..payload.Title;text.Text=(payload.Notice and payload.Notice..'\n\n' or '')..payload.Text
  for _,b in self.Buttons do b:Destroy()end;self.Buttons={};scroll.CanvasPosition=Vector2.new(0,0)
  for index,option in self.Options do
   local button=Instance.new('TextButton');button.Name='Option'..index;button.Size=UDim2.new(1,-10,0,52);button.AutomaticSize=Enum.AutomaticSize.Y
   button.Text=option.Label;button.TextWrapped=true;button.TextSize=18;button.Font=Enum.Font.SourceSansSemibold;button.LayoutOrder=index;button.AutoButtonColor=option.Enabled
   button.BackgroundColor3=if option.Enabled then Color3.fromRGB(83,63,38) else Color3.fromRGB(49,46,42)
   button.TextColor3=if option.Enabled then Color3.fromRGB(255,239,202) else Color3.fromRGB(164,158,145)
   local padding=Instance.new('UIPadding');padding.PaddingTop=UDim.new(0,12);padding.PaddingBottom=UDim.new(0,12);padding.PaddingLeft=UDim.new(0,10);padding.PaddingRight=UDim.new(0,10);padding.Parent=button
   button.Parent=scroll;button.Activated:Connect(function()self:choose(index)end);table.insert(self.Buttons,button)
  end
 end
 return self
end
return UI
