-- libv2
local Library = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

function Library:CreateWindow(titleText, iconId)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RagdollSystemLib"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local lastMinimizedPos = UDim2.new(1, -70, 1, -70)

    local function createGlassFrame(name, size, pos, parent, color1, color2)
        local frame = Instance.new("Frame")
        frame.Name = name; frame.Size = size; frame.Position = pos
        frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        frame.BackgroundTransparency = 0.3; frame.BorderSizePixel = 0; frame.Parent = parent
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12); corner.Parent = frame
        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, color1 or Color3.fromRGB(255,255,255)), ColorSequenceKeypoint.new(1, color2 or Color3.fromRGB(220,220,240))}
        gradient.Rotation = 45; gradient.Parent = frame
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(200,200,220); stroke.Thickness = 1; stroke.Transparency = 0.5; stroke.Parent = frame
        return frame
    end

    local mainFrame = createGlassFrame("MainFrame", UDim2.new(0,160,0,180), UDim2.new(1,-180,1,-210), screenGui)
    mainFrame.Active = true

    local topBar = createGlassFrame("TopBar", UDim2.new(1,0,0,30), UDim2.new(0,0,0,0), mainFrame, Color3.fromRGB(245,245,255), Color3.fromRGB(210,210,230))
    topBar.BackgroundTransparency = 0.2

    -- Dots Decorativos
    local colors = {Color3.fromRGB(255,90,90),Color3.fromRGB(255,210,60),Color3.fromRGB(70,255,120)}
    for i=1,3 do
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0,8,0,8); dot.Position = UDim2.new(0,10+(i-1)*15,0.5,-4)
        dot.BackgroundColor3 = colors[i]; dot.BorderSizePixel = 0
        Instance.new("UICorner", dot).CornerRadius = UDim.new(0.5,0)
        dot.Parent = topBar
    end

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1,-90,1,0); titleLabel.Position = UDim2.new(0,55,0,0); titleLabel.BackgroundTransparency = 1
    titleLabel.Text = titleText; titleLabel.TextColor3 = Color3.fromRGB(50,50,60); titleLabel.Font = Enum.Font.GothamBold; titleLabel.TextSize = 12
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left; titleLabel.Parent = topBar

    local function makeDraggable(obj, target, isIcon)
        local dragging, dragStart, startPos = false, nil, nil
        obj.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = input.Position; startPos = target.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        if isIcon then lastMinimizedPos = target.Position end
                    end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    makeDraggable(topBar, mainFrame, false)

    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0,24,0,24); minimizeBtn.Position = UDim2.new(1,-54,0.5,-12); minimizeBtn.BackgroundColor3 = Color3.fromRGB(70,70,90)
    minimizeBtn.BackgroundTransparency = 0.3; minimizeBtn.Text = "−"; minimizeBtn.TextColor3 = Color3.fromRGB(255,255,255); minimizeBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0,6); minimizeBtn.Parent = topBar

    minimizeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        local minIcon = Instance.new("ImageButton")
        minIcon.Size = UDim2.new(0,55,0,55); minIcon.Position = lastMinimizedPos; minIcon.BackgroundTransparency = 1
        minIcon.Image = iconId or "rbxassetid://6031068433"; minIcon.Parent = screenGui
        makeDraggable(minIcon, minIcon, true)
        minIcon.MouseButton1Click:Connect(function() lastMinimizedPos = minIcon.Position; minIcon:Destroy(); mainFrame.Visible = true end)
    end)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0,24,0,24); closeBtn.Position = UDim2.new(1,-26,0.5,-12); closeBtn.BackgroundColor3 = Color3.fromRGB(220,60,60)
    closeBtn.Text = "✕"; closeBtn.TextColor3 = Color3.fromRGB(255,255,255); closeBtn.Font = Enum.Font.GothamBold; closeBtn.Parent = topBar
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)
    closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1,0,1,-30); scroll.Position = UDim2.new(0,0,0,30); scroll.CanvasSize = UDim2.new(0,0,0,300)
    scroll.ScrollBarThickness = 4; scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0; scroll.Parent = mainFrame
    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0,5); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local API = {}

    function API:CreateToggle(text, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1,-24,0,30); frame.BackgroundTransparency = 1; frame.Parent = scroll
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0,80,1,0); lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(60,60,70)
        lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = frame
        
        local tFrame = Instance.new("Frame")
        tFrame.Size = UDim2.new(0,44,0,22); tFrame.Position = UDim2.new(1,-44,0.5,-11); tFrame.BackgroundColor3 = Color3.fromRGB(180,180,180)
        Instance.new("UICorner", tFrame).CornerRadius = UDim.new(0.5,0); tFrame.Parent = frame
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0,18,0,18); knob.Position = UDim2.new(0,2,0.5,-9); knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
        Instance.new("UICorner", knob).CornerRadius = UDim.new(0.5,0); knob.Parent = tFrame
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.Parent = tFrame
        
        local state = false
        btn.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(tFrame, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(0,200,100) or Color3.fromRGB(180,180,180)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)}):Play()
            callback(state)
        end)
    end

    function API:CreateButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,-24,0,32); btn.BackgroundColor3 = Color3.fromRGB(255,255,255); btn.BackgroundTransparency = 0.4
        btn.Text = text; btn.TextColor3 = Color3.fromRGB(60,60,70); btn.Font = Enum.Font.GothamBold; btn.TextSize = 13
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8); btn.Parent = scroll
        btn.MouseButton1Click:Connect(callback)
    end

    function API:CreateSlider(text, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1,-24,0,45); frame.BackgroundTransparency = 1; frame.Parent = scroll
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1,0,0,20); lbl.BackgroundTransparency = 1; lbl.Text = text..": "..default; lbl.TextColor3 = Color3.fromRGB(80,80,90); lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 11; lbl.Parent = frame
        local sBg = Instance.new("Frame")
        sBg.Size = UDim2.new(1,0,0,6); sBg.Position = UDim2.new(0,0,0,25); sBg.BackgroundColor3 = Color3.fromRGB(200,200,210); sBg.Parent = frame
        Instance.new("UICorner", sBg).CornerRadius = UDim.new(1,0)
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0,16,0,16); knob.Position = UDim2.new((default/max),-8,0.5,-8); knob.BackgroundColor3 = Color3.fromRGB(110,110,255); knob.Parent = sBg
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
        
        local sliding = false
        local function update(input)
            local rel = math.clamp((input.Position.X - sBg.AbsolutePosition.X) / sBg.AbsoluteSize.X, 0, 1)
            knob.Position = UDim2.new(rel, -8, 0.5, -8)
            local val = math.floor(min + (max-min)*rel)
            lbl.Text = text..": "..val
            callback(val)
        end
        sBg.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true; update(input) end end)
        UserInputService.InputChanged:Connect(function(input) if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end end)
        UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end)
    end

    function API:CreateTextbox(placeholder, callback)
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1,-24,0,30); box.BackgroundColor3 = Color3.fromRGB(255,255,255); box.BackgroundTransparency = 0.5
        box.PlaceholderText = placeholder; box.Text = ""; box.Font = Enum.Font.Gotham; box.TextSize = 12; box.TextColor3 = Color3.fromRGB(50,50,60); box.Parent = scroll
        Instance.new("UICorner", box).CornerRadius = UDim.new(0,8)
        box.FocusLost:Connect(function(enter) if enter then callback(box.Text) end end)
    end

    return API
end

return Library

print("site: luay.gt.tc")
