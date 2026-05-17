--// Custom "macOS / mspaint" Style UI Library
--// Rebuilt with native Roblox Frames, Exponential Center-Zooming, and macOS Pill Toggles.
--// Drop-in replacement for Kavo.

local Kavo = {}

local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Players = game:GetService("Players")

-- Smooth, snappy animation preset
local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

local function tween(obj, props, overrideTime)
    local ti = overrideTime and TweenInfo.new(overrideTime, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out) or tweenInfo
    local tw = TS:Create(obj, ti, props)
    tw:Play()
    return tw
end

-- Dragging logic adapted for AnchorPoint 0.5, 0.5
local function MakeDraggable(topbar, main)
    local dragging, dragInput, mousePos, framePos
    
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = main.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            main.Position = UDim2.new(
                framePos.X.Scale, framePos.X.Offset + delta.X, 
                framePos.Y.Scale, framePos.Y.Offset + delta.Y
            )
        end
    end)
end

local activeGuiName = ""
local LibOpen = true

function Kavo:ToggleUI()
    local gui = game.CoreGui:FindFirstChild(activeGuiName)
    if gui then
        local main = gui:FindFirstChild("Main")
        local scale = main and main:FindFirstChildOfClass("UIScale")
        
        LibOpen = not LibOpen
        
        if LibOpen then
            gui.Enabled = true
            if main and scale then
                tween(main, {GroupTransparency = 0})
                tween(scale, {Scale = 1})
            end
        else
            if main and scale then
                tween(main, {GroupTransparency = 1})
                local t = tween(scale, {Scale = 0.85})
                t.Completed:Connect(function()
                    if not LibOpen then gui.Enabled = false end
                end)
            else
                gui.Enabled = false
            end
        end
    end
end

function Kavo.CreateLib(kavName, themeName)
    kavName = kavName or "UI Library"
    activeGuiName = kavName
    table.insert(Kavo, kavName)
    
    -- Cleanup old GUI
    for _,v in pairs(game.CoreGui:GetChildren()) do
        if v:IsA("ScreenGui") and v.Name == kavName then v:Destroy() end
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = kavName
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    -- Native Mouse Unlocker
    RS.RenderStepped:Connect(function()
        if ScreenGui.Enabled and LibOpen then
            UIS.MouseIconEnabled = true
            UIS.MouseBehavior = Enum.MouseBehavior.Default
        end
    end)

    -- macOS CanvasGroup Base
    local Main = Instance.new("CanvasGroup")
    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(0, 600, 0, 400)
    Main.BackgroundColor3 = Color3.fromRGB(28, 28, 30) -- Deep macOS Dark
    Main.BorderSizePixel = 0
    Main.GroupTransparency = 1 -- Start hidden for anim
    
    local uiScale = Instance.new("UIScale", Main)
    uiScale.Scale = 0.85
    
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    
    local mainStroke = Instance.new("UIStroke", Main)
    mainStroke.Color = Color3.fromRGB(60, 60, 65)
    mainStroke.Thickness = 1
    mainStroke.Transparency = 0.5

    -- Sidebar (Left)
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 160, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
    Sidebar.BorderSizePixel = 0
    
    local SidebarStroke = Instance.new("UIStroke", Sidebar)
    SidebarStroke.Color = Color3.fromRGB(0, 0, 0)
    SidebarStroke.Thickness = 1
    SidebarStroke.Transparency = 0.8
    
    -- Top drag area above Sidebar
    local DragBar = Instance.new("Frame", Main)
    DragBar.Size = UDim2.new(1, 0, 0, 40)
    DragBar.BackgroundTransparency = 1
    MakeDraggable(DragBar, Main)

    -- Title
    local TitleLabel = Instance.new("TextLabel", Sidebar)
    TitleLabel.Size = UDim2.new(1, -20, 0, 50)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = kavName
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Tabs Container
    local TabContainer = Instance.new("ScrollingFrame", Sidebar)
    TabContainer.Size = UDim2.new(1, -10, 1, -60)
    TabContainer.Position = UDim2.new(0, 5, 0, 50)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    
    local TabListLayout = Instance.new("UIListLayout", TabContainer)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 4)

    -- Pages Container (Right)
    local PagesFolder = Instance.new("Folder", Main)
    
    -- Initial Entry Animation
    tween(Main, {GroupTransparency = 0})
    tween(uiScale, {Scale = 1})

    local Tabs = {}
    local firstTab = true

    function Tabs:NewTab(tabName)
        local tabBtn = Instance.new("TextButton", TabContainer)
        tabBtn.Size = UDim2.new(1, 0, 0, 30)
        tabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        tabBtn.BackgroundTransparency = 1
        tabBtn.Text = "   " .. tabName
        tabBtn.Font = Enum.Font.GothamMedium
        tabBtn.TextColor3 = Color3.fromRGB(160, 160, 165)
        tabBtn.TextSize = 13
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        tabBtn.AutoButtonColor = false
        
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)

        local Page = Instance.new("ScrollingFrame", Main)
        Page.Size = UDim2.new(1, -170, 1, -20)
        Page.Position = UDim2.new(0, 165, 0, 10)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 85)
        Page.Visible = false
        
        local PageLayout = Instance.new("UIListLayout", Page)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 8)
        
        local PagePadding = Instance.new("UIPadding", Page)
        PagePadding.PaddingRight = UDim.new(0, 10)

        if firstTab then
            Page.Visible = true
            tabBtn.BackgroundTransparency = 0.5
            tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            firstTab = false
        end

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end)

        tabBtn.MouseButton1Click:Connect(function()
            for _, child in pairs(PagesFolder:GetChildren()) do
                if child:IsA("ScrollingFrame") then child.Visible = false end
            end
            for _, child in pairs(Main:GetChildren()) do
                if child:IsA("ScrollingFrame") and child ~= TabContainer then child.Visible = false end
            end
            for _, btn in pairs(TabContainer:GetChildren()) do
                if btn:IsA("TextButton") then
                    tween(btn, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(160, 160, 165)})
                end
            end
            Page.Visible = true
            tween(tabBtn, {BackgroundTransparency = 0.5, TextColor3 = Color3.fromRGB(255, 255, 255)})
        end)

        local Sections = {}
        function Sections:NewSection(secName)
            local SectionFrame = Instance.new("Frame", Page)
            SectionFrame.Size = UDim2.new(1, 0, 0, 0) -- Auto sizes later
            SectionFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 38)
            SectionFrame.ClipsDescendants = true
            Instance.new("UICorner", SectionFrame).CornerRadius = UDim.new(0, 8)
            
            local SecStroke = Instance.new("UIStroke", SectionFrame)
            SecStroke.Color = Color3.fromRGB(60, 60, 65)
            SecStroke.Thickness = 1
            
            local SecTitle = Instance.new("TextLabel", SectionFrame)
            SecTitle.Size = UDim2.new(1, -20, 0, 30)
            SecTitle.Position = UDim2.new(0, 10, 0, 0)
            SecTitle.BackgroundTransparency = 1
            SecTitle.Font = Enum.Font.GothamBold
            SecTitle.Text = secName
            SecTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            SecTitle.TextSize = 12
            SecTitle.TextXAlignment = Enum.TextXAlignment.Left

            local SecContent = Instance.new("Frame", SectionFrame)
            SecContent.Size = UDim2.new(1, 0, 1, -30)
            SecContent.Position = UDim2.new(0, 0, 0, 30)
            SecContent.BackgroundTransparency = 1
            
            local SecLayout = Instance.new("UIListLayout", SecContent)
            SecLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SecLayout.Padding = UDim.new(0, 2)
            
            local SecPadding = Instance.new("UIPadding", SecContent)
            SecPadding.PaddingBottom = UDim.new(0, 8)

            local function UpdateSectionSize()
                tween(SectionFrame, {Size = UDim2.new(1, 0, 0, SecLayout.AbsoluteContentSize.Y + 38)})
            end
            SecLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSectionSize)

            local Elements = {}

            -- BUTTON
            function Elements:NewButton(bName, tip, callback, iconAsset)
                bName = bName or "Button"
                callback = callback or function() end

                local Btn = Instance.new("TextButton", SecContent)
                Btn.Size = UDim2.new(1, -16, 0, 34)
                Btn.Position = UDim2.new(0, 8, 0, 0)
                Btn.BackgroundColor3 = Color3.fromRGB(44, 44, 46)
                Btn.AutoButtonColor = false
                Btn.Text = ""
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

                local Icon = Instance.new("ImageLabel", Btn)
                Icon.Size = UDim2.new(0, 20, 0, 20)
                Icon.Position = UDim2.new(0, 8, 0.5, -10)
                Icon.BackgroundTransparency = 1
                Icon.Image = iconAsset or ""
                if Icon.Image == "" then Icon.Visible = false end

                local Lbl = Instance.new("TextLabel", Btn)
                Lbl.Size = UDim2.new(1, -45, 1, 0)
                Lbl.Position = UDim2.new(0, Icon.Visible and 36 or 10, 0, 0)
                Lbl.BackgroundTransparency = 1
                Lbl.Font = Enum.Font.GothamMedium
                Lbl.Text = bName
                Lbl.TextColor3 = Color3.fromRGB(220, 220, 225)
                Lbl.TextSize = 13
                Lbl.TextXAlignment = Enum.TextXAlignment.Left

                Btn.MouseEnter:Connect(function() tween(Btn, {BackgroundColor3 = Color3.fromRGB(55, 55, 58)}) end)
                Btn.MouseLeave:Connect(function() tween(Btn, {BackgroundColor3 = Color3.fromRGB(44, 44, 46)}) end)
                Btn.MouseButton1Down:Connect(function() tween(Btn, {BackgroundColor3 = Color3.fromRGB(65, 65, 68)}, 0.1) end)
                
                Btn.MouseButton1Click:Connect(function()
                    tween(Btn, {BackgroundColor3 = Color3.fromRGB(55, 55, 58)})
                    callback()
                end)
                
                UpdateSectionSize()
                local funcs = {}
                function funcs:UpdateButton(newT) Lbl.Text = newT end
                return funcs
            end

            -- TOGGLE (macOS Pill Style)
            function Elements:NewToggle(tName, tip, callback)
                local toggled = false
                callback = callback or function() end

                local TogBtn = Instance.new("TextButton", SecContent)
                TogBtn.Size = UDim2.new(1, -16, 0, 34)
                TogBtn.Position = UDim2.new(0, 8, 0, 0)
                TogBtn.BackgroundColor3 = Color3.fromRGB(36, 36, 38)
                TogBtn.AutoButtonColor = false
                TogBtn.Text = ""
                Instance.new("UICorner", TogBtn).CornerRadius = UDim.new(0, 6)

                local Lbl = Instance.new("TextLabel", TogBtn)
                Lbl.Size = UDim2.new(1, -60, 1, 0)
                Lbl.Position = UDim2.new(0, 10, 0, 0)
                Lbl.BackgroundTransparency = 1
                Lbl.Font = Enum.Font.GothamMedium
                Lbl.Text = tName
                Lbl.TextColor3 = Color3.fromRGB(220, 220, 225)
                Lbl.TextSize = 13
                Lbl.TextXAlignment = Enum.TextXAlignment.Left

                local Pill = Instance.new("Frame", TogBtn)
                Pill.Size = UDim2.new(0, 36, 0, 20)
                Pill.Position = UDim2.new(1, -44, 0.5, -10)
                Pill.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
                Instance.new("UICorner", Pill).CornerRadius = UDim.new(1, 0)
                
                local Knob = Instance.new("Frame", Pill)
                Knob.Size = UDim2.new(0, 16, 0, 16)
                Knob.Position = UDim2.new(0, 2, 0.5, -8)
                Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
                
                local KnobStroke = Instance.new("UIStroke", Knob)
                KnobStroke.Color = Color3.fromRGB(0,0,0)
                KnobStroke.Transparency = 0.8
                KnobStroke.Thickness = 1

                TogBtn.MouseEnter:Connect(function() tween(TogBtn, {BackgroundColor3 = Color3.fromRGB(44, 44, 46)}) end)
                TogBtn.MouseLeave:Connect(function() tween(TogBtn, {BackgroundColor3 = Color3.fromRGB(36, 36, 38)}) end)

                TogBtn.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    if toggled then
                        tween(Pill, {BackgroundColor3 = Color3.fromRGB(200, 200, 205)}) -- White/Silver Active
                        tween(Knob, {Position = UDim2.new(1, -18, 0.5, -8)})
                    else
                        tween(Pill, {BackgroundColor3 = Color3.fromRGB(60, 60, 65)}) -- Dark track
                        tween(Knob, {Position = UDim2.new(0, 2, 0.5, -8)})
                    end
                    pcall(callback, toggled)
                end)
                
                UpdateSectionSize()
            end

            -- TEXTBOX
            function Elements:NewTextBox(tName, tip, callback)
                callback = callback or function() end
                
                local BoxFrame = Instance.new("Frame", SecContent)
                BoxFrame.Size = UDim2.new(1, -16, 0, 34)
                BoxFrame.Position = UDim2.new(0, 8, 0, 0)
                BoxFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 38)
                Instance.new("UICorner", BoxFrame).CornerRadius = UDim.new(0, 6)

                local Lbl = Instance.new("TextLabel", BoxFrame)
                Lbl.Size = UDim2.new(0.5, 0, 1, 0)
                Lbl.Position = UDim2.new(0, 10, 0, 0)
                Lbl.BackgroundTransparency = 1
                Lbl.Font = Enum.Font.GothamMedium
                Lbl.Text = tName
                Lbl.TextColor3 = Color3.fromRGB(220, 220, 225)
                Lbl.TextSize = 13
                Lbl.TextXAlignment = Enum.TextXAlignment.Left

                local Input = Instance.new("TextBox", BoxFrame)
                Input.Size = UDim2.new(0.45, -10, 0, 24)
                Input.Position = UDim2.new(0.55, 0, 0.5, -12)
                Input.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
                Input.Font = Enum.Font.Gotham
                Input.PlaceholderText = "Input..."
                Input.Text = ""
                Input.TextColor3 = Color3.fromRGB(255, 255, 255)
                Input.TextSize = 12
                Instance.new("UICorner", Input).CornerRadius = UDim.new(0, 4)
                
                local InpStroke = Instance.new("UIStroke", Input)
                InpStroke.Color = Color3.fromRGB(60, 60, 65)
                InpStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

                Input.FocusLost:Connect(function(entered)
                    if entered then callback(Input.Text) end
                end)
                
                UpdateSectionSize()
            end

            -- SLIDER
            function Elements:NewSlider(sName, tip, maxVal, minVal, callback)
                maxVal = maxVal or 100
                minVal = minVal or 0
                callback = callback or function() end

                local SlideFrame = Instance.new("Frame", SecContent)
                SlideFrame.Size = UDim2.new(1, -16, 0, 44)
                SlideFrame.Position = UDim2.new(0, 8, 0, 0)
                SlideFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 38)
                Instance.new("UICorner", SlideFrame).CornerRadius = UDim.new(0, 6)

                local Lbl = Instance.new("TextLabel", SlideFrame)
                Lbl.Size = UDim2.new(1, -50, 0, 20)
                Lbl.Position = UDim2.new(0, 10, 0, 4)
                Lbl.BackgroundTransparency = 1
                Lbl.Font = Enum.Font.GothamMedium
                Lbl.Text = sName
                Lbl.TextColor3 = Color3.fromRGB(220, 220, 225)
                Lbl.TextSize = 13
                Lbl.TextXAlignment = Enum.TextXAlignment.Left

                local ValLbl = Instance.new("TextLabel", SlideFrame)
                ValLbl.Size = UDim2.new(0, 40, 0, 20)
                ValLbl.Position = UDim2.new(1, -50, 0, 4)
                ValLbl.BackgroundTransparency = 1
                ValLbl.Font = Enum.Font.Gotham
                ValLbl.Text = tostring(minVal)
                ValLbl.TextColor3 = Color3.fromRGB(160, 160, 165)
                ValLbl.TextSize = 12
                ValLbl.TextXAlignment = Enum.TextXAlignment.Right

                local Track = Instance.new("Frame", SlideFrame)
                Track.Size = UDim2.new(1, -20, 0, 4)
                Track.Position = UDim2.new(0, 10, 0, 30)
                Track.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
                Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

                local Fill = Instance.new("Frame", Track)
                Fill.Size = UDim2.new(0, 0, 1, 0)
                Fill.BackgroundColor3 = Color3.fromRGB(200, 200, 205)
                Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

                local function UpdateSlide(input)
                    local pos = math.clamp(input.Position.X - Track.AbsolutePosition.X, 0, Track.AbsoluteSize.X)
                    local percent = pos / Track.AbsoluteSize.X
                    local value = math.floor(minVal + ((maxVal - minVal) * percent))
                    
                    tween(Fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
                    ValLbl.Text = tostring(value)
                    callback(value)
                end

                local dragging = false
                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        UpdateSlide(input)
                    end
                end)
                UIS.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
                UIS.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlide(input)
                    end
                end)
                
                UpdateSectionSize()
            end
            
            function Elements:NewKeybind(kName, tip, defaultKey, callback)
                local currentKey = defaultKey.Name or "Unknown"
                callback = callback or function() end
                
                local KeyFrame = Instance.new("TextButton", SecContent)
                KeyFrame.Size = UDim2.new(1, -16, 0, 34)
                KeyFrame.Position = UDim2.new(0, 8, 0, 0)
                KeyFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 38)
                KeyFrame.AutoButtonColor = false
                KeyFrame.Text = ""
                Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 6)

                local Lbl = Instance.new("TextLabel", KeyFrame)
                Lbl.Size = UDim2.new(0.5, 0, 1, 0)
                Lbl.Position = UDim2.new(0, 10, 0, 0)
                Lbl.BackgroundTransparency = 1
                Lbl.Font = Enum.Font.GothamMedium
                Lbl.Text = kName
                Lbl.TextColor3 = Color3.fromRGB(220, 220, 225)
                Lbl.TextSize = 13
                Lbl.TextXAlignment = Enum.TextXAlignment.Left

                local BindBox = Instance.new("TextLabel", KeyFrame)
                BindBox.Size = UDim2.new(0.3, 0, 0, 24)
                BindBox.Position = UDim2.new(0.7, -10, 0.5, -12)
                BindBox.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
                BindBox.Font = Enum.Font.GothamSemibold
                BindBox.Text = currentKey
                BindBox.TextColor3 = Color3.fromRGB(200, 200, 205)
                BindBox.TextSize = 12
                Instance.new("UICorner", BindBox).CornerRadius = UDim.new(0, 4)
                
                local InpStroke = Instance.new("UIStroke", BindBox)
                InpStroke.Color = Color3.fromRGB(60, 60, 65)

                local binding = false
                KeyFrame.MouseButton1Click:Connect(function()
                    binding = true
                    BindBox.Text = "..."
                end)
                
                UIS.InputBegan:Connect(function(inputObj, proc)
                    if binding then
                        if inputObj.UserInputType == Enum.UserInputType.Keyboard then
                            currentKey = inputObj.KeyCode.Name
                            BindBox.Text = currentKey
                            binding = false
                        end
                    elseif not proc and inputObj.UserInputType == Enum.UserInputType.Keyboard then
                        if inputObj.KeyCode.Name == currentKey then callback() end
                    end
                end)
                
                UpdateSectionSize()
            end

            return Elements
        end
        return Sections
    end
    return Tabs
end

return Kavo
