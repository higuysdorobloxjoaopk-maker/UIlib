-- lib
local Library = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

function Library:CreateWindow(titleText)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LuayLib_" .. math.random(100,999)
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

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
    
    -- Draggable Logic
    local dragging, dragStart, startPos
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = mainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,-90,1,0); title.Position = UDim2.new(0,55,0,0); title.BackgroundTransparency = 1
    title.Text = titleText; title.TextColor3 = Color3.fromRGB(50,50,60); title.Font = Enum.Font.GothamBold; title.TextSize = 12
    title.TextXAlignment = Enum.TextXAlignment.Left; title.Parent = topBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0,24,0,24); closeBtn.Position = UDim2.new(1,-26,0.5,-12); closeBtn.BackgroundColor3 = Color3.fromRGB(220,60,60)
    closeBtn.Text = "✕"; closeBtn.TextColor3 = Color3.fromRGB(255,255,255); closeBtn.Parent = topBar; Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)
    closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1,0,1,-30); scroll.Position = UDim2.new(0,0,0,30); scroll.CanvasSize = UDim2.new(0,0,0,300)
    scroll.ScrollBarThickness = 0; scroll.BackgroundTransparency = 1; scroll.Parent = mainFrame
    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0,8); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local Elements = {}

    function Elements:CreateButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,-24,0,32); btn.BackgroundColor3 = Color3.fromRGB(255,255,255); btn.BackgroundTransparency = 0.4
        btn.Text = text; btn.Font = Enum.Font.GothamBold; btn.TextSize = 13; btn.Parent = scroll
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
        btn.MouseButton1Click:Connect(callback)
    end

    function Elements:CreateToggle(text, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1,-24,0,30); frame.BackgroundTransparency = 1; frame.Parent = scroll
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0,80,1,0); lbl.BackgroundTransparency = 1; lbl.Text = text
        lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 12; lbl.TextColor3 = Color3.fromRGB(60,60,70); lbl.Parent = frame
        
        local tgl = Instance.new("Frame")
        tgl.Size = UDim2.new(0,40,0,20); tgl.Position = UDim2.new(1,-40,0.5,-10); tgl.BackgroundColor3 = Color3.fromRGB(180,180,180); tgl.Parent = frame
        Instance.new("UICorner", tgl).CornerRadius = UDim.new(1,0)
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0,16,0,16); knob.Position = UDim2.new(0,2,0.5,-8); knob.BackgroundColor3 = Color3.fromRGB(255,255,255); knob.Parent = tgl
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.Parent = tgl
        
        local state = false
        btn.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(tgl, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(0,200,100) or Color3.fromRGB(180,180,180)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)}):Play()
            callback(state)
        end)
    end

    function Elements:CreateSlider(text, min, max, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1,-24,0,45); container.BackgroundTransparency = 1; container.Parent = scroll
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1,0,0,20); lbl.BackgroundTransparency = 1; lbl.Text = text..": "..min; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 11; lbl.Parent = container
        local sBg = Instance.new("Frame")
        sBg.Size = UDim2.new(1,0,0,6); sBg.Position = UDim2.new(0,0,0,25); sBg.BackgroundColor3 = Color3.fromRGB(200,200,210); sBg.Parent = container
        Instance.new("UICorner", sBg)
        local sKnob = Instance.new("Frame")
        sKnob.Size = UDim2.new(0,14,0,14); sKnob.Position = UDim2.new(0,0,0.5,-7); sKnob.BackgroundColor3 = Color3.fromRGB(110,110,255); sKnob.Parent = sBg
        Instance.new("UICorner", sKnob).CornerRadius = UDim.new(1,0)

        local sliding = false
        local function update(input)
            local pos = math.clamp((input.Position.X - sBg.AbsolutePosition.X) / sBg.AbsoluteSize.X, 0, 1)
            sKnob.Position = UDim2.new(pos, -7, 0.5, -7)
            local val = math.floor(min + (max - min) * pos)
            lbl.Text = text..": "..val
            callback(val)
        end
        sBg.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true; update(input) end end)
        UserInputService.InputChanged:Connect(function(input) if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end end)
        UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end)
    end

    function Elements:CreateTextbox(placeholder, callback)
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1,-24,0,30); box.BackgroundColor3 = Color3.fromRGB(255,255,255); box.BackgroundTransparency = 0.5
        box.PlaceholderText = placeholder; box.Text = ""; box.Font = Enum.Font.Gotham; box.TextSize = 12; box.Parent = scroll
        Instance.new("UICorner", box).CornerRadius = UDim.new(0,8)
        box.FocusLost:Connect(function(enter) if enter then callback(box.Text) end end)
    end

    return Elements
end

return Library
