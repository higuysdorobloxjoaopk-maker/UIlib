local Library = {}

function Library:CreateWindow(titleText)
    local Players = game:GetService("Players")
    local UIS = game:GetService("UserInputService")
    local TS = game:GetService("TweenService")
    
    local sg = Instance.new("ScreenGui", Players.LocalPlayer:WaitForChild("PlayerGui"))
    sg.Name = "GlassLib_" .. math.random(100,999)
    sg.ResetOnSpawn = false

    -- Centralizar e Arrastar
    local main = Instance.new("Frame", sg)
    main.Name = "Main"
    main.Size = UDim2.new(0, 300, 0, 400)
    main.Position = UDim2.new(0.5, -150, 0.5, -200)
    main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    main.BackgroundTransparency = 0.2
    
    local corner = Instance.new("UICorner", main)
    corner.CornerRadius = UDim.new(0, 12)
    
    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(255,255,255)
    stroke.Transparency = 0.6
    
    local gradient = Instance.new("UIGradient", main)
    gradient.Color = ColorSequence.new(Color3.fromRGB(240,240,255), Color3.fromRGB(200,200,220))
    gradient.Rotation = 45

    -- Topbar
    local top = Instance.new("Frame", main)
    top.Size = UDim2.new(1, 0, 0, 35)
    top.BackgroundTransparency = 1
    
    local title = Instance.new("TextLabel", top)
    title.Size = UDim2.new(1, -40, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.Text = titleText or "GLASS LIB"
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = Color3.fromRGB(40,40,50)
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1

    -- Scrolling Frame (Onde os itens ficam)
    local container = Instance.new("ScrollingFrame", main)
    container.Size = UDim2.new(1, -10, 1, -45)
    container.Position = UDim2.new(0, 5, 0, 40)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ScrollBarThickness = 2
    container.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local layout = Instance.new("UIListLayout", container)
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Auto-ajuste do Canvas
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)

    -- Draggable Logic
    local dragging, dragInput, dragStart, startPos
    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = main.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    local Elements = {}

    -- Label
    function Elements:AddLabel(text)
        local lab = Instance.new("TextLabel", container)
        lab.Size = UDim2.new(0, 270, 0, 25)
        lab.BackgroundTransparency = 1
        lab.Text = text
        lab.Font = Enum.Font.GothamMedium
        lab.TextColor3 = Color3.fromRGB(80,80,90)
        lab.TextSize = 12
    end

    -- Button
    function Elements:AddButton(text, callback)
        local btn = Instance.new("TextButton", container)
        btn.Size = UDim2.new(0, 270, 0, 35)
        btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
        btn.BackgroundTransparency = 0.5
        btn.Text = text
        btn.Font = Enum.Font.GothamBold
        btn.TextColor3 = Color3.fromRGB(60,60,70)
        btn.TextSize = 13
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        btn.MouseButton1Click:Connect(callback)
    end

    -- Toggle
    function Elements:AddToggle(text, callback)
        local state = false
        local tFrame = Instance.new("Frame", container)
        tFrame.Size = UDim2.new(0, 270, 0, 35)
        tFrame.BackgroundTransparency = 1

        local lab = Instance.new("TextLabel", tFrame)
        lab.Size = UDim2.new(1, -60, 1, 0)
        lab.Position = UDim2.new(0, 10, 0, 0)
        lab.Text = text
        lab.Font = Enum.Font.GothamSemibold
        lab.TextColor3 = Color3.fromRGB(60,60,70)
        lab.BackgroundTransparency = 1
        lab.TextXAlignment = "Left"

        local bg = Instance.new("Frame", tFrame)
        bg.Size = UDim2.new(0, 40, 0, 20)
        bg.Position = UDim2.new(1, -50, 0.5, -10)
        bg.BackgroundColor3 = Color3.fromRGB(180,180,180)
        Instance.new("UICorner", bg).CornerRadius = UDim.new(1,0)

        local knob = Instance.new("Frame", bg)
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = UDim2.new(0, 2, 0.5, -8)
        knob.BackgroundColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

        local btn = Instance.new("TextButton", tFrame)
        btn.Size = UDim2.new(1,0,1,0)
        btn.BackgroundTransparency = 1
        btn.Text = ""

        btn.MouseButton1Click:Connect(function()
            state = not state
            TS:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(0,200,100) or Color3.fromRGB(180,180,180)}):Play()
            TS:Create(knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
            callback(state)
        end)
    end

    -- TextBox
    function Elements:AddTextBox(text, placeholder, callback)
        local box = Instance.new("TextBox", container)
        box.Size = UDim2.new(0, 270, 0, 35)
        box.BackgroundColor3 = Color3.fromRGB(255,255,255)
        box.BackgroundTransparency = 0.6
        box.PlaceholderText = placeholder
        box.Text = ""
        box.Font = Enum.Font.Gotham
        box.TextColor3 = Color3.new(0,0,0)
        Instance.new("UICorner", box)
        box.FocusLost:Connect(function() callback(box.Text) end)
    end
    
    -- Color Picker (Simplificado)
    function Elements:AddColorPicker(text, callback)
        local cpFrame = Instance.new("Frame", container)
        cpFrame.Size = UDim2.new(0, 270, 0, 35)
        cpFrame.BackgroundTransparency = 1
        
        local lab = Instance.new("TextLabel", cpFrame)
        lab.Size = UDim2.new(0, 100, 1, 0)
        lab.Position = UDim2.new(0, 10, 0, 0)
        lab.Text = text
        lab.BackgroundTransparency = 1
        lab.TextXAlignment = "Left"
        
        local picker = Instance.new("ImageButton", cpFrame)
        picker.Size = UDim2.new(0, 100, 0, 20)
        picker.Position = UDim2.new(1, -110, 0.5, -10)
        picker.Image = "rbxassetid://6980520070" -- Gradiente cromático
        
        picker.MouseButton1Click:Connect(function()
            callback(Color3.fromHSV(math.random(), 1, 1)) -- Exemplo: Cor aleatória ao clicar
        end)
    end

    -- Discord Banner
    function Elements:AddDiscord(link)
        local banner = Instance.new("TextButton", container)
        banner.Size = UDim2.new(0, 270, 0, 50)
        banner.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
        banner.Text = "JOIN OUR DISCORD\n" .. link
        banner.TextColor3 = Color3.new(1,1,1)
        banner.Font = Enum.Font.GothamBold
        Instance.new("UICorner", banner)
        banner.MouseButton1Click:Connect(function()
            if setclipboard then setclipboard(link) end
            print("Link copiado!")
        end)
    end

    -- Player List Dropdown
    function Elements:AddPlayerList(callback)
        local drop = Instance.new("TextButton", container)
        drop.Size = UDim2.new(0, 270, 0, 35)
        drop.BackgroundColor3 = Color3.fromRGB(255,255,255)
        drop.BackgroundTransparency = 0.7
        drop.Text = "Select Player..."
        Instance.new("UICorner", drop)
        
        drop.MouseButton1Click:Connect(function()
            -- Aqui você poderia criar um menu flutuante com a lista
            local pList = Players:GetPlayers()
            local randomP = pList[math.random(1, #pList)]
            drop.Text = "Player: " .. randomP.Name
            callback(randomP)
        end)
    end

    return Elements
end

return Library
