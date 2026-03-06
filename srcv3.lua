local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local lib = {}

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function createGlassFrame(name,size,pos,parent,c1,c2)

local frame = Instance.new("Frame")
frame.Name = name
frame.Size = size
frame.Position = pos
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BackgroundTransparency = 0.3
frame.BorderSizePixel = 0
frame.Parent = parent

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,12)
corner.Parent = frame

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
ColorSequenceKeypoint.new(0,c1 or Color3.fromRGB(255,255,255)),
ColorSequenceKeypoint.new(1,c2 or Color3.fromRGB(220,220,240))
}
gradient.Rotation = 45
gradient.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(200,200,220)
stroke.Thickness = 1
stroke.Transparency = 0.5
stroke.Parent = frame

return frame

end

local function draggable(obj,target)

local dragging=false
local dragStart,startPos

obj.InputBegan:Connect(function(input)

if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then

dragging=true
dragStart=input.Position
startPos=target.Position

input.Changed:Connect(function()

if input.UserInputState==Enum.UserInputState.End then
dragging=false
end

end)

end

end)

UserInputService.InputChanged:Connect(function(input)

if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then

local delta=input.Position-dragStart

target.Position=UDim2.new(
startPos.X.Scale,
startPos.X.Offset+delta.X,
startPos.Y.Scale,
startPos.Y.Offset+delta.Y
)

end

end)

end

function lib.new(title)

local gui = Instance.new("ScreenGui")
gui.Name = "GlassUILibrary"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = createGlassFrame(
"Main",
UDim2.new(0,160,0,260),
UDim2.new(1,-180,1,-280),
gui
)

main.Active = true

local top = createGlassFrame(
"TopBar",
UDim2.new(1,0,0,30),
UDim2.new(0,0,0,0),
main,
Color3.fromRGB(245,245,255),
Color3.fromRGB(210,210,230)
)

top.BackgroundTransparency = 0.2

local colors={
Color3.fromRGB(255,90,90),
Color3.fromRGB(255,210,60),
Color3.fromRGB(70,255,120)
}

for i=1,3 do

local dot=Instance.new("Frame")
dot.Size=UDim2.new(0,8,0,8)
dot.Position=UDim2.new(0,10+(i-1)*15,0.5,-4)
dot.BackgroundColor3=colors[i]
dot.BorderSizePixel=0
dot.Parent=top

local c=Instance.new("UICorner")
c.CornerRadius=UDim.new(1,0)
c.Parent=dot

end

local titleLabel=Instance.new("TextLabel")
titleLabel.Size=UDim2.new(1,-80,1,0)
titleLabel.Position=UDim2.new(0,55,0,0)
titleLabel.BackgroundTransparency=1
titleLabel.Text=title or "UI"
titleLabel.Font=Enum.Font.GothamBold
titleLabel.TextSize=12
titleLabel.TextColor3=Color3.fromRGB(50,50,60)
titleLabel.TextXAlignment=Enum.TextXAlignment.Left
titleLabel.Parent=top

draggable(top,main)

local scroll=Instance.new("ScrollingFrame")
scroll.Size=UDim2.new(1,0,1,-30)
scroll.Position=UDim2.new(0,0,0,30)
scroll.BackgroundTransparency=1
scroll.ScrollBarThickness=4
scroll.CanvasSize=UDim2.new(0,0,0,0)
scroll.Parent=main

local layout=Instance.new("UIListLayout")
layout.Padding=UDim.new(0,6)
layout.Parent=scroll

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
scroll.CanvasSize=UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+10)
end)

local api={}

function api.Button(text,callback)

local btn=createGlassFrame(
"Button",
UDim2.new(1,-12,0,30),
UDim2.new(0,6,0,0),
scroll
)

local t=Instance.new("TextButton")
t.Size=UDim2.new(1,0,1,0)
t.BackgroundTransparency=1
t.Text=text
t.Font=Enum.Font.GothamBold
t.TextSize=13
t.TextColor3=Color3.fromRGB(60,60,70)
t.Parent=btn

t.MouseButton1Click:Connect(function()
if callback then callback() end
end)

end

function api.TextBox(text,callback)

local box=createGlassFrame(
"Textbox",
UDim2.new(1,-12,0,32),
UDim2.new(0,6,0,0),
scroll
)

local input=Instance.new("TextBox")
input.Size=UDim2.new(1,-10,1,0)
input.Position=UDim2.new(0,5,0,0)
input.BackgroundTransparency=1
input.PlaceholderText=text
input.Font=Enum.Font.Gotham
input.TextSize=13
input.TextColor3=Color3.fromRGB(50,50,60)
input.Parent=box

input.FocusLost:Connect(function()

if callback then
callback(input.Text)
end

end)

end

function api.DropdownPlayers(callback)

local frame=createGlassFrame(
"Dropdown",
UDim2.new(1,-12,0,30),
UDim2.new(0,6,0,0),
scroll
)

local btn=Instance.new("TextButton")
btn.Size=UDim2.new(1,0,1,0)
btn.BackgroundTransparency=1
btn.Text="Players"
btn.Font=Enum.Font.GothamBold
btn.TextSize=13
btn.TextColor3=Color3.fromRGB(60,60,70)
btn.Parent=frame

btn.MouseButton1Click:Connect(function()

for _,p in pairs(Players:GetPlayers()) do

if callback then
callback(p)
end

end

end)

end

function api.ColorPicker(callback)

local picker=createGlassFrame(
"Color",
UDim2.new(1,-12,0,40),
UDim2.new(0,6,0,0),
scroll
)

local wheel=Instance.new("ImageButton")
wheel.Size=UDim2.new(0,32,0,32)
wheel.Position=UDim2.new(0,4,0.5,-16)
wheel.Image="rbxassetid://6020299385"
wheel.BackgroundTransparency=1
wheel.Parent=picker

wheel.MouseButton1Down:Connect(function()

local color=Color3.fromHSV(
math.random(),
1,
1
)

if callback then
callback(color)
end

end)

end

function api.DiscordBanner(imageId,link)

local banner=createGlassFrame(
"Discord",
UDim2.new(1,-12,0,60),
UDim2.new(0,6,0,0),
scroll
)

local img=Instance.new("ImageLabel")
img.Size=UDim2.new(1,0,1,0)
img.BackgroundTransparency=1
img.Image=imageId
img.Parent=banner

local btn=Instance.new("TextButton")
btn.Size=UDim2.new(1,0,1,0)
btn.BackgroundTransparency=1
btn.Text=""
btn.Parent=banner

btn.MouseButton1Click:Connect(function()

setclipboard(link)

end)

end

return api

end

return lib
