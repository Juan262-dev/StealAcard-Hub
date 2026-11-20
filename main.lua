-- Steal a Card Mobile Hub v3.0 - experimental client tools
-- No Auto Steal or Auto Farm; object detection is heuristic.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local me=Players.LocalPlayer
local pg=me:WaitForChild("PlayerGui")
local old=pg:FindFirstChild("SACMobileHubV3")
if old then old:Destroy() end
local gui=Instance.new("ScreenGui")
gui.Name="SACMobileHubV3"
gui.ResetOnSpawn=false
gui.Parent=pg
local frame=Instance.new("Frame",gui)
frame.Size=UDim2.fromOffset(285,320)
frame.Position=UDim2.new(0,15,.24,0)
frame.BackgroundColor3=Color3.fromRGB(24,27,38)
frame.Active=true
Instance.new("UICorner",frame).CornerRadius=UDim.new(0,12)
local function make(kind,parent,props)
 local x=Instance.new(kind)
 for k,v in pairs(props) do x[k]=v end
 x.Parent=parent
 return x
end
make("TextLabel",frame,{Text="STEAL A CARD | MOBILE HUB",Size=UDim2.new(1,-50,0,44),Position=UDim2.fromOffset(10,0),BackgroundTransparency=1,TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=13})
local mini=make("TextButton",frame,{Text="-",Size=UDim2.fromOffset(35,35),Position=UDim2.new(1,-40,0,5),BackgroundColor3=Color3.fromRGB(55,60,78),TextColor3=Color3.new(1,1,1),TextSize=20})
local content=make("Frame",frame,{Size=UDim2.new(1,-20,1,-52),Position=UDim2.fromOffset(10,47),BackgroundTransparency=1})
make("UIListLayout",content,{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder})
local enabled={players=false,cards=false,speed=false,radar=false}
local function toggle(name,key)
 local b=make("TextButton",content,{Text=name.." OFF",Size=UDim2.new(1,0,0,37),BackgroundColor3=Color3.fromRGB(53,58,76),TextColor3=Color3.new(1,1,1),TextSize=13,Font=Enum.Font.GothamMedium})
 Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
 b.MouseButton1Click:Connect(function()
  enabled[key]=not enabled[key]
  b.Text=name..(enabled[key] and " ON" or " OFF")
  b.BackgroundColor3=enabled[key] and Color3.fromRGB(34,112,89) or Color3.fromRGB(53,58,76)
 end)
end
toggle("ESP Jogadores","players")
toggle("ESP Cartas (experimental)","cards")
toggle("Speed local","speed")
toggle("Radar de cartas","radar")
local speed=24
local speedRow=make("Frame",content,{Size=UDim2.new(1,0,0,35),BackgroundTransparency=1})
local minus=make("TextButton",speedRow,{Text="-",Size=UDim2.fromOffset(43,35),TextSize=20})
local plus=make("TextButton",speedRow,{Text="+",Position=UDim2.new(1,-43,0,0),Size=UDim2.fromOffset(43,35),TextSize=20})
local speedText=make("TextLabel",speedRow,{Text="Speed: 24",Position=UDim2.fromOffset(48,0),Size=UDim2.new(1,-96,1,0),BackgroundTransparency=1,TextColor3=Color3.new(1,1,1),TextSize=14})
minus.MouseButton1Click:Connect(function() speed=math.max(16,speed-4);speedText.Text="Speed: "..speed end)
plus.MouseButton1Click:Connect(function() speed=math.min(40,speed+4);speedText.Text="Speed: "..speed end)
local status=make("TextLabel",content,{Text="Radar desativado",Size=UDim2.new(1,0,0,30),BackgroundTransparency=1,TextColor3=Color3.fromRGB(190,200,220),TextSize=11,TextWrapped=true})
local minimized=false
mini.MouseButton1Click:Connect(function()
 minimized=not minimized
 content.Visible=not minimized
 frame.Size=UDim2.fromOffset(285,minimized and 45 or 320)
 mini.Text=minimized and "+" or "-"
end)
local drag=false
local start,original
frame.InputBegan:Connect(function(input)
 if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
  if input.Position.Y<frame.AbsolutePosition.Y+43 and input.Position.X<frame.AbsolutePosition.X+240 then
   drag=true;start=input.Position;original=frame.Position
  end
 end
end)
UIS.InputChanged:Connect(function(input)
 if drag and (input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseMovement) then
  local d=input.Position-start
  frame.Position=UDim2.new(original.X.Scale,original.X.Offset+d.X,original.Y.Scale,original.Y.Offset+d.Y)
 end
end)
UIS.InputEnded:Connect(function(input)
 if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
end)
local marks={}
local function mark(key,obj,color)
 if marks[key] and marks[key].Parent then return end
 local h=Instance.new("Highlight")
 h.Name="SAC_ClientHighlight";h.Adornee=obj;h.FillColor=color;h.OutlineColor=color
 h.FillTransparency=.75;h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop;h.Parent=gui
 marks[key]=h
end
local function isCard(x)
 if not (x:IsA("Model") or x:IsA("BasePart")) then return false end
 if x:GetAttribute("IsCard")==true then return true end
 local n=x.Name:lower()
 return n:find("card",1,true) or n:find("carta",1,true) or n:find("deck",1,true) or n:find("baralho",1,true)
end
local previousSpeed
local elapsed=0
local conn
conn=RunService.Heartbeat:Connect(function(dt)
 if not gui.Parent then
  conn:Disconnect()
  for _,h in pairs(marks) do h:Destroy() end
  return
 end
 elapsed=elapsed+dt
 if elapsed<.75 then return end
 elapsed=0
 local keep={}
 if enabled.players then
  for _,p in ipairs(Players:GetPlayers()) do
   if p~=me and p.Character then
    local key="player_"..p.UserId
    keep[key]=true;mark(key,p.Character,Color3.fromRGB(255,90,90))
   end
  end
 end
 local count=0
 local distance=math.huge
 if enabled.cards or enabled.radar then
  local root=me.Character and me.Character:FindFirstChild("HumanoidRootPart")
  for _,obj in ipairs(workspace:GetDescendants()) do
   if isCard(obj) then
    count=count+1
    if enabled.cards then
     local key="card_"..tostring(obj)
     keep[key]=true;mark(key,obj,Color3.fromRGB(255,210,65))
    end
    local part=obj:IsA("BasePart") and obj or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart",true)
    if root and part then distance=math.min(distance,(root.Position-part.Position).Magnitude) end
   end
  end
 end
 for k,h in pairs(marks) do
  if not keep[k] then h:Destroy();marks[k]=nil end
 end
 local hum=me.Character and me.Character:FindFirstChildOfClass("Humanoid")
 if hum then
  if enabled.speed then
   if previousSpeed==nil then previousSpeed=hum.WalkSpeed end
   hum.WalkSpeed=speed
  elseif previousSpeed~=nil then
   hum.WalkSpeed=previousSpeed;previousSpeed=nil
  end
 end
 status.Text=enabled.radar and ("Possiveis cartas: "..count.." | Mais proxima: "..(distance<math.huge and math.floor(distance).." studs" or "nenhuma")) or "Radar desativado"
end)
