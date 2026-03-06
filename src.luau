local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Library = {}
Library.__index = Library

local function create(class,props)
    local obj = Instance.new(class)
    for i,v in pairs(props) do
        obj[i]=v
    end
    return obj
end

function Library:CreateWindow(cfg)
    local player = Players.LocalPlayer
    local gui = create("ScreenGui",{Parent=player:WaitForChild("PlayerGui"),ResetOnSpawn=false,Name="UILibrary"})
    
    local main = create("Frame",{Parent=gui,Size=UDim2.new(0,520,0,420),Position=UDim2.new(0.5,-260,0.5,-210),BackgroundColor3=Color3.fromRGB(20,20,20),BorderSizePixel=0})
    
    local top = create("Frame",{Parent=main,Size=UDim2.new(1,0,0,40),BackgroundColor3=Color3.fromRGB(15,15,15),BorderSizePixel=0})
    
    local title = create("TextLabel",{Parent=top,Text=cfg.Title or "Window",Font=Enum.Font.GothamBold,TextSize=16,TextColor3=Color3.new(1,1,1),BackgroundTransparency=1,Position=UDim2.new(0,10,0,0),Size=UDim2.new(1,-60,1,0),TextXAlignment=Enum.TextXAlignment.Left})
    
    local minimize = create("TextButton",{Parent=top,Text="-",Font=Enum.Font.GothamBold,TextSize=18,TextColor3=Color3.new(1,1,1),BackgroundTransparency=1,Size=UDim2.new(0,40,1,0),Position=UDim2.new(1,-40,0,0)})
    
    local tabButtons = create("Frame",{Parent=main,Size=UDim2.new(0,140,1,-40),Position=UDim2.new(0,0,0,40),BackgroundColor3=Color3.fromRGB(18,18,18),BorderSizePixel=0})
    
    local tabList = create("UIListLayout",{Parent=tabButtons,SortOrder=Enum.SortOrder.LayoutOrder})
    
    local pages = create("Frame",{Parent=main,Size=UDim2.new(1,-140,1,-40),Position=UDim2.new(0,140,0,40),BackgroundTransparency=1})
    
    local window = {}
    
    local minimized=false
    minimize.MouseButton1Click:Connect(function()
        minimized=not minimized
        TweenService:Create(main,TweenInfo.new(0.25),{Size=minimized and UDim2.new(0,520,0,40) or UDim2.new(0,520,0,420)}):Play()
    end)
    
    do
        local dragging=false
        local dragInput,dragStart,startPos
        
        top.InputBegan:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
                dragging=true
                dragStart=input.Position
                startPos=main.Position
                input.Changed:Connect(function()
                    if input.UserInputState==Enum.UserInputState.End then
                        dragging=false
                    end
                end)
            end
        end)
        
        top.InputChanged:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
                dragInput=input
            end
        end)
        
        UIS.InputChanged:Connect(function(input)
            if input==dragInput and dragging then
                local delta=input.Position-dragStart
                main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
            end
        end)
    end
    
    function window:CreateTab(name)
        local button=create("TextButton",{Parent=tabButtons,Size=UDim2.new(1,0,0,36),BackgroundTransparency=1,Text=name,Font=Enum.Font.Gotham,TextSize=14,TextColor3=Color3.fromRGB(200,200,200)})
        
        local page=create("ScrollingFrame",{Parent=pages,Size=UDim2.new(1,0,1,0),CanvasSize=UDim2.new(0,0,0,0),ScrollBarThickness=4,Visible=false,BackgroundTransparency=1})
        
        local layout=create("UIListLayout",{Parent=page,Padding=UDim.new(0,6)})
        
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize=UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+10)
        end)
        
        button.MouseButton1Click:Connect(function()
            for _,v in pairs(pages:GetChildren()) do
                if v:IsA("ScrollingFrame") then
                    v.Visible=false
                end
            end
            page.Visible=true
        end)
        
        local tab={}
        
        function tab:CreateSection(name)
            local secFrame=create("Frame",{Parent=page,Size=UDim2.new(1,-10,0,30),BackgroundColor3=Color3.fromRGB(25,25,25),BorderSizePixel=0})
            
            local secLayout=create("UIListLayout",{Parent=secFrame,Padding=UDim.new(0,4)})
            
            local title=create("TextLabel",{Parent=secFrame,Text=name,Font=Enum.Font.GothamBold,TextSize=14,TextColor3=Color3.new(1,1,1),BackgroundTransparency=1,Size=UDim2.new(1,0,0,24)})
            
            local section={}
            
            function section:CreateButton(cfg)
                local b=create("TextButton",{Parent=secFrame,Size=UDim2.new(1,-10,0,28),Text=cfg.Name,Font=Enum.Font.Gotham,TextSize=14,BackgroundColor3=Color3.fromRGB(35,35,35),TextColor3=Color3.new(1,1,1),BorderSizePixel=0})
                b.MouseButton1Click:Connect(function()
                    if cfg.Callback then
                        cfg.Callback()
                    end
                end)
            end
            
            function section:CreateToggle(cfg)
                local t=create("TextButton",{Parent=secFrame,Size=UDim2.new(1,-10,0,28),Text=cfg.Name,Font=Enum.Font.Gotham,TextSize=14,BackgroundColor3=Color3.fromRGB(35,35,35),TextColor3=Color3.new(1,1,1),BorderSizePixel=0})
                local state=cfg.Default or false
                t.MouseButton1Click:Connect(function()
                    state=not state
                    if cfg.Callback then
                        cfg.Callback(state)
                    end
                end)
            end
            
            function section:CreateSlider(cfg)
                local frame=create("Frame",{Parent=secFrame,Size=UDim2.new(1,-10,0,36),BackgroundColor3=Color3.fromRGB(35,35,35),BorderSizePixel=0})
                
                local bar=create("Frame",{Parent=frame,Size=UDim2.new(1,-20,0,4),Position=UDim2.new(0,10,0.5,0),BackgroundColor3=Color3.fromRGB(60,60,60),BorderSizePixel=0})
                
                local fill=create("Frame",{Parent=bar,Size=UDim2.new(0,0,1,0),BackgroundColor3=Color3.fromRGB(120,120,255),BorderSizePixel=0})
                
                local dragging=false
                frame.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                        dragging=true
                    end
                end)
                
                UIS.InputEnded:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                        dragging=false
                    end
                end)
                
                UIS.InputChanged:Connect(function(i)
                    if dragging then
                        local pos=(i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X
                        pos=math.clamp(pos,0,1)
                        fill.Size=UDim2.new(pos,0,1,0)
                        local val=math.floor((cfg.Min+(cfg.Max-cfg.Min)*pos))
                        if cfg.Callback then
                            cfg.Callback(val)
                        end
                    end
                end)
            end
            
            function section:CreateTextbox(cfg)
                local box=create("TextBox",{Parent=secFrame,Size=UDim2.new(1,-10,0,28),BackgroundColor3=Color3.fromRGB(35,35,35),TextColor3=Color3.new(1,1,1),Font=Enum.Font.Gotham,TextSize=14,Text="",PlaceholderText=cfg.Placeholder or "",BorderSizePixel=0})
                box.FocusLost:Connect(function()
                    if cfg.Callback then
                        cfg.Callback(box.Text)
                    end
                end)
            end
            
            return section
        end
        
        return tab
    end
    
    return window
end

return Library
