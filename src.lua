local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")

local Lib = {}

local function corner(obj,r)
local c = Instance.new("UICorner")
c.CornerRadius = UDim.new(0,r or 6)
c.Parent = obj
end

function Lib:CreateWindow(title)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Name = "UILib"
ScreenGui.Parent = guiParent

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,270,0,340)
Main.Position = UDim2.new(1,-290,1,-360)
Main.BackgroundColor3 = Color3.fromRGB(28,28,32)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui
corner(Main,10)

local Top = Instance.new("Frame")
Top.Size = UDim2.new(1,0,0,34)
Top.BackgroundColor3 = Color3.fromRGB(40,40,46)
Top.Parent = Main
corner(Top,10)

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1,-70,1,0)
Title.Position = UDim2.new(0,10,0,0)
Title.Font = Enum.Font.GothamBold
Title.Text = title
Title.TextSize = 14
Title.TextColor3 = Color3.new(1,1,1)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Top

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0,26,0,26)
Close.Position = UDim2.new(1,-30,0.5,-13)
Close.Text = "X"
Close.Font = Enum.Font.GothamBold
Close.TextSize = 12
Close.BackgroundColor3 = Color3.fromRGB(200,60,60)
Close.TextColor3 = Color3.new(1,1,1)
Close.Parent = Top
corner(Close)

Close.MouseButton1Click:Connect(function()
ScreenGui:Destroy()
end)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1,-10,1,-44)
Scroll.Position = UDim2.new(0,5,0,38)
Scroll.CanvasSize = UDim2.new(0,0,0,0)
Scroll.ScrollBarThickness = 4
Scroll.BackgroundTransparency = 1
Scroll.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0,6)
Layout.Parent = Scroll

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
Scroll.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y+10)
end)

local Window = {}

function Window:Button(text,callback)

local B = Instance.new("TextButton")
B.Size = UDim2.new(1,0,0,32)
B.BackgroundColor3 = Color3.fromRGB(45,45,52)
B.TextColor3 = Color3.new(1,1,1)
B.Font = Enum.Font.Gotham
B.TextSize = 13
B.Text = text
B.Parent = Scroll
corner(B)

B.MouseButton1Click:Connect(function()
if callback then
callback()
end
end)

end

function Window:Toggle(text,default,callback)

local state = default

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(1,0,0,32)
Frame.BackgroundColor3 = Color3.fromRGB(45,45,52)
Frame.Parent = Scroll
corner(Frame)

local Label = Instance.new("TextLabel")
Label.BackgroundTransparency = 1
Label.Size = UDim2.new(1,-50,1,0)
Label.Position = UDim2.new(0,8,0,0)
Label.Text = text
Label.Font = Enum.Font.Gotham
Label.TextSize = 13
Label.TextColor3 = Color3.new(1,1,1)
Label.TextXAlignment = Enum.TextXAlignment.Left
Label.Parent = Frame

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(0,36,0,20)
Toggle.Position = UDim2.new(1,-42,0.5,-10)
Toggle.Text = ""
Toggle.BackgroundColor3 = state and Color3.fromRGB(0,170,120) or Color3.fromRGB(80,80,90)
Toggle.Parent = Frame
corner(Toggle,10)

Toggle.MouseButton1Click:Connect(function()
state = not state
Toggle.BackgroundColor3 = state and Color3.fromRGB(0,170,120) or Color3.fromRGB(80,80,90)
if callback then callback(state) end
end)

end

function Window:Textbox(text,callback)

local Box = Instance.new("TextBox")
Box.Size = UDim2.new(1,0,0,32)
Box.BackgroundColor3 = Color3.fromRGB(45,45,52)
Box.TextColor3 = Color3.new(1,1,1)
Box.PlaceholderText = text
Box.Font = Enum.Font.Gotham
Box.TextSize = 13
Box.Parent = Scroll
corner(Box)

Box.FocusLost:Connect(function()
if callback then
callback(Box.Text)
end
end)

end

function Window:Dropdown(text,list,callback)

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(1,0,0,32)
Frame.BackgroundColor3 = Color3.fromRGB(45,45,52)
Frame.Parent = Scroll
corner(Frame)

local Btn = Instance.new("TextButton")
Btn.Size = UDim2.new(1,0,1,0)
Btn.Text = text
Btn.TextColor3 = Color3.new(1,1,1)
Btn.BackgroundTransparency = 1
Btn.Font = Enum.Font.Gotham
Btn.TextSize = 13
Btn.Parent = Frame

local Drop = Instance.new("Frame")
Drop.Visible = false
Drop.Size = UDim2.new(1,0,0,#list*26)
Drop.Position = UDim2.new(0,0,1,2)
Drop.BackgroundColor3 = Color3.fromRGB(35,35,40)
Drop.Parent = Frame
corner(Drop)

local Layout = Instance.new("UIListLayout")
Layout.Parent = Drop

for _,v in pairs(list) do

local Opt = Instance.new("TextButton")
Opt.Size = UDim2.new(1,0,0,26)
Opt.Text = v
Opt.BackgroundTransparency = 1
Opt.TextColor3 = Color3.new(1,1,1)
Opt.Font = Enum.Font.Gotham
Opt.TextSize = 12
Opt.Parent = Drop

Opt.MouseButton1Click:Connect(function()
Btn.Text = text.." : "..v
Drop.Visible = false
if callback then callback(v) end
end)

end

Btn.MouseButton1Click:Connect(function()
Drop.Visible = not Drop.Visible
end)

end

function Window:PlayerList(callback)

local names = {}

for _,p in pairs(Players:GetPlayers()) do
table.insert(names,p.Name)
end

return Window:Dropdown("Players",names,callback)

end

function Window:ImageBanner(imageId)

local Img = Instance.new("ImageLabel")
Img.Size = UDim2.new(1,0,0,120)
Img.BackgroundTransparency = 1
Img.Image = "rbxassetid://"..imageId
Img.Parent = Scroll
corner(Img)

end

function Window:Discord(invite)

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(1,0,0,60)
Frame.BackgroundColor3 = Color3.fromRGB(88,101,242)
Frame.Parent = Scroll
corner(Frame,8)

local Label = Instance.new("TextLabel")
Label.Size = UDim2.new(1,0,0.6,0)
Label.BackgroundTransparency = 1
Label.Text = "Discord Server"
Label.TextColor3 = Color3.new(1,1,1)
Label.Font = Enum.Font.GothamBold
Label.TextSize = 14
Label.Parent = Frame

local Join = Instance.new("TextButton")
Join.Size = UDim2.new(0.5,0,0.35,0)
Join.Position = UDim2.new(0.25,0,0.6,0)
Join.Text = "Copy Invite"
Join.BackgroundColor3 = Color3.fromRGB(60,70,200)
Join.TextColor3 = Color3.new(1,1,1)
Join.Font = Enum.Font.Gotham
Join.TextSize = 12
Join.Parent = Frame
corner(Join)

Join.MouseButton1Click:Connect(function()
setclipboard(invite)
end)

end

return Window

end

return Lib
