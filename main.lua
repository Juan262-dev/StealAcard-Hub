-- Caxias Hub v1.0 | client-side utility panel
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local old=pg:FindFirstChild("CaxiasHub")
if old then old:Destroy() end
local gui=Instance.new("ScreenGui")
gui.Name="CaxiasHub";gui.ResetOnSpawn=false
gui.Parent=pg
local function new(class,parent,props)
 local o=Instance.new(class)
 for k,v in pairs(props) do o[k]=v end
 o.Parent=parent
 return o
end
local main=new("Frame",gui,{Size=UDim2.fromOffset(285,315),Position=UDim2.new(.5,-142,.25,0),BackgroundColor3=Color3.fromRGB(20,26,38),Active=true})
new("UICorner",main,{CornerRadius=UDim.new(0,12)})
local header=new("TextLabel",main,{Size=UDim2.new(1,-50,0,45),Position=UDim2.fromOffset(10,0),BackgroundTransparency=1,Text="CAXIAS HUB v1.0",TextColor3=Color3.new(1,1,1),TextSize=16,Font=Enum.Font.GothamBold})
local min=new("TextButton",main,{Size=UDim2.fromOffset(35,32),Position=UDim2.new(1,-40,0,6),Text="-",TextSize=22,TextColor3=Color3.new(1,1,1),BackgroundColor3=Color3.fromRGB(45,55,75)})
local content=new("Frame",main,{Size=UDim2.new(1,-20,1,-55),Position=UDim2.fromOffset(10,50),BackgroundTransparency=1})
new("UIListLayout",content,{Padding=UDim.new(0,8)})
local options={players=true,timer=true,coords=false,zoom=false}
local function toggle(label,key)
 local b=new("TextButton",content,{Size=UDim2.new(1,0,0,38),TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamMedium,TextSize=13})
 new("UICorner",b,{CornerRadius=UDim.new(0,8)})
 local function refresh()
  b.Text=label.."  "..(options[key] and "ON" or "OFF")
  b.BackgroundColor3=options[key] and Color3.fromRGB(32,105,78) or Color3.fromRGB(43,53,72)
 end
 b.MouseButton1Click:Connect(function() options[key]=not options[key];refresh() end)
 refresh()
end
toggle("Jogadores","players")
toggle("Tempo de sessao","timer")
toggle("Coordenadas","coords")
toggle("Zoom da camera","zoom")
local info=new("TextLabel",content,{Size=UDim2.new(1,0,0,60),BackgroundTransparency=1,TextColor3=Color3.fromRGB(210,220,235),TextSize=12,TextWrapped=true,Text="Carregando..."})
local startTime=os.clock()
local camera=workspace.CurrentCamera
local originalFov=camera and camera.FieldOfView or 70
local minimized=false
min.MouseButton1Click:Connect(function()
 minimized=not minimized
 content.Visible=not minimized
 main.Size=UDim2.fromOffset(285,minimized and 45 or 315)
 min.Text=minimized and "+" or "-"
end)
local dragging=false
local dragInput,dragStart,startPos
header.InputBegan:Connect(function(input)
 if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
  dragging=true;dragInput=input;dragStart=input.Position;startPos=main.Position
 end
end)
header.InputChanged:Connect(function(input)
 if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseMovement then dragInput=input end
end)
UIS.InputChanged:Connect(function(input)
 if dragging and input==dragInput then
  local delta=input.Position-dragStart
  main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
 end
end)
UIS.InputEnded:Connect(function(input)
 if input==dragInput or (dragging and input.UserInputType==Enum.UserInputType.MouseButton1) then dragging=false end
end)
local elapsed=0
local conn
conn=RunService.Heartbeat:Connect(function(dt)
 if not gui.Parent then
  if workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView=originalFov end
  conn:Disconnect();return
 end
 elapsed=elapsed+dt
 if elapsed<.5 then return end
 elapsed=0
 local lines={}
 if options.players then table.insert(lines,"Jogadores: "..#Players:GetPlayers()) end
 if options.timer then
  local seconds=math.floor(os.clock()-startTime)
  table.insert(lines,string.format("Sessao: %02d:%02d",math.floor(seconds/60),seconds%60))
 end
 if options.coords then
  local char=player.Character
  local root=char and char:FindFirstChild("HumanoidRootPart")
  if root then
   local p=root.Position
   table.insert(lines,string.format("XYZ: %.0f, %.0f, %.0f",p.X,p.Y,p.Z))
  end
 end
 local cam=workspace.CurrentCamera
 if cam then cam.FieldOfView=options.zoom and 50 or originalFov end
 info.Text=#lines>0 and table.concat(lines," | ") or "Ative uma funcao"
end)
