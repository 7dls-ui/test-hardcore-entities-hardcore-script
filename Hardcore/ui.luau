--// macOS Optimized Kavo UI Library Rewrite (V2 - Bug Fixes & Graphite Theme)
--// Rebuilt with Quint/Out animations, SF Pro (Gotham) typography, and Apple window controls.

local Kavo = {}

local tween = game:GetService("TweenService")
local tweeninfo = TweenInfo.new
local input = game:GetService("UserInputService")
local run = game:GetService("RunService")

local Utility = {}
local Objects = {}

function Kavo:DraggingEnabled(frame, parent)
    parent = parent or frame
    
    local dragging = false
    local dragInput, mousePos, framePos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = parent.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    input.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            parent.Position  = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

function Utility:TweenObject(obj, properties, duration, ...)
    tween:Create(obj, tweeninfo(duration or 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), properties):Play()
end

-- Changed to a sleek "Graphite" macOS style without the bright blue.
local themes = {
    SchemeColor = Color3.fromRGB(150, 150, 150), -- Graphite Accent
    Background = Color3.fromRGB(30, 30, 32), -- macOS Dark Main
    Header = Color3.fromRGB(45, 45, 48), -- macOS Dark Sidebar/Titlebar
    TextColor = Color3.fromRGB(240, 240, 240),
    ElementColor = Color3.fromRGB(55, 55, 58) -- Button Backgrounds
}

local themeStyles = {
    DarkTheme = {
        SchemeColor = Color3.fromRGB(150, 150, 150),
        Background = Color3.fromRGB(30, 30, 32),
        Header = Color3.fromRGB(45, 45, 48),
        TextColor = Color3.fromRGB(240, 240, 240),
        ElementColor = Color3.fromRGB(55, 55, 58)
    },
    LightTheme = {
        SchemeColor = Color3.fromRGB(120, 120, 120),
        Background = Color3.fromRGB(245, 245, 245),
        Header = Color3.fromRGB(225, 225, 225),
        TextColor = Color3.fromRGB(0, 0, 0),
        ElementColor = Color3.fromRGB(255, 255, 255)
    },
    Midnight = {
        SchemeColor = Color3.fromRGB(150, 150, 150),
        Background = Color3.fromRGB(25, 25, 27),
        Header = Color3.fromRGB(40, 40, 42),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(50, 50, 53)
    }
}
local oldTheme = ""

local SettingsT = {}
local Name = "KavoConfig.JSON"

pcall(function()
    if not pcall(function() readfile(Name) end) then
        writefile(Name, game:service'HttpService':JSONEncode(SettingsT))
    end
    Settings = game:service'HttpService':JSONEncode(readfile(Name))
end)

local LibName = tostring(math.random(1, 100))..tostring(math.random(1,50))..tostring(math.random(1, 100))

function Kavo:ToggleUI()
    if game.CoreGui:FindFirstChild(LibName) then
        local gui = game.CoreGui[LibName]
        gui.Enabled = not gui.Enabled
    end
end

function Kavo.CreateLib(kavName, themeList)
    if not themeList then themeList = themes end
    if type(themeList) == "string" then
        themeList = themeStyles[themeList] or themes
    else
        if themeList.SchemeColor == nil then themeList.SchemeColor = Color3.fromRGB(150, 150, 150) end
        if themeList.Background == nil then themeList.Background = Color3.fromRGB(30, 30, 32) end
        if themeList.Header == nil then themeList.Header = Color3.fromRGB(45, 45, 48) end
        if themeList.TextColor == nil then themeList.TextColor = Color3.fromRGB(255,255,255) end
        if themeList.ElementColor == nil then themeList.ElementColor = Color3.fromRGB(55, 55, 58) end
    end

    local selectedTab 
    kavName = kavName or "Library"
    table.insert(Kavo, kavName)
    
    for i,v in pairs(game.CoreGui:GetChildren()) do
        if v:IsA("ScreenGui") and v.Name == kavName then
            v:Destroy()
        end
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    local Main = Instance.new("Frame")
    local MainCorner = Instance.new("UICorner")
    local MainHeader = Instance.new("Frame")
    local headerCover = Instance.new("UICorner")
    local coverup = Instance.new("Frame")
    local title = Instance.new("TextLabel")
    
    local TrafficLights = Instance.new("Frame")
    local closeBtn = Instance.new("TextButton")
    local minBtn = Instance.new("TextButton")
    local maxBtn = Instance.new("TextButton")
    
    local MainSide = Instance.new("Frame")
    local sideCorner = Instance.new("UICorner")
    local coverup_2 = Instance.new("Frame")
    local tabFrames = Instance.new("Frame")
    local tabListing = Instance.new("UIListLayout")
    local pages = Instance.new("Frame")
    local Pages = Instance.new("Folder")
    local infoContainer = Instance.new("Frame")
    local blurFrame = Instance.new("Frame")

    Kavo:DraggingEnabled(MainHeader, Main)

    blurFrame.Name = "blurFrame"
    blurFrame.Parent = pages
    blurFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    blurFrame.BackgroundTransparency = 1
    blurFrame.BorderSizePixel = 0
    blurFrame.Position = UDim2.new(-0.022, 0, -0.037, 0)
    blurFrame.Size = UDim2.new(0, 376, 0, 289)
    blurFrame.ZIndex = 999

    ScreenGui.Parent = game.CoreGui
    ScreenGui.Name = LibName
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = themeList.Background
    Main.ClipsDescendants = true
    Main.Position = UDim2.new(0.336, 0, 0.275, 0)
    Main.Size = UDim2.new(0, 525, 0, 318)

    MainCorner.CornerRadius = UDim.new(0, 12) -- Smoother macOS Window Corners
    MainCorner.Name = "MainCorner"
    MainCorner.Parent = Main
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Parent = Main
    mainStroke.Color = Color3.fromRGB(0, 0, 0)
    mainStroke.Transparency = 0.5
    mainStroke.Thickness = 1

    MainHeader.Name = "MainHeader"
    MainHeader.Parent = Main
    MainHeader.BackgroundColor3 = themeList.Header
    Objects[MainHeader] = "BackgroundColor3"
    MainHeader.Size = UDim2.new(0, 525, 0, 38)
    headerCover.CornerRadius = UDim.new(0, 12)
    headerCover.Name = "headerCover"
    headerCover.Parent = MainHeader

    coverup.Name = "coverup"
    coverup.Parent = MainHeader
    coverup.BackgroundColor3 = themeList.Header
    Objects[coverup] = "BackgroundColor3"
    coverup.BorderSizePixel = 0
    coverup.Position = UDim2.new(0, 0, 0.758, 0)
    coverup.Size = UDim2.new(0, 525, 0, 10)

    title.Name = "title"
    title.Parent = MainHeader
    title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1.000
    title.BorderSizePixel = 0
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Size = UDim2.new(1, 0, 1, 0)
    title.Font = Enum.Font.GothamSemibold
    title.RichText = true
    title.Text = kavName
    title.TextColor3 = Color3.fromRGB(200, 200, 200)
    title.TextSize = 13.000
    title.TextXAlignment = Enum.TextXAlignment.Center
    
    -- macOS Traffic Lights
    TrafficLights.Name = "TrafficLights"
    TrafficLights.Parent = MainHeader
    TrafficLights.BackgroundTransparency = 1
    TrafficLights.Position = UDim2.new(0, 14, 0.5, -6)
    TrafficLights.Size = UDim2.new(0, 52, 0, 12)
    
    closeBtn.Name = "close"
    closeBtn.Parent = TrafficLights
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 95, 86)
    closeBtn.Size = UDim2.new(0, 12, 0, 12)
    closeBtn.Font = Enum.Font.Gotham
    closeBtn.Text = ""
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
    
    minBtn.Name = "minimize"
    minBtn.Parent = TrafficLights
    minBtn.BackgroundColor3 = Color3.fromRGB(255, 189, 46)
    minBtn.Position = UDim2.new(0, 20, 0, 0)
    minBtn.Size = UDim2.new(0, 12, 0, 12)
    minBtn.Font = Enum.Font.Gotham
    minBtn.Text = ""
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(1, 0)
    
    maxBtn.Name = "maximize"
    maxBtn.Parent = TrafficLights
    maxBtn.BackgroundColor3 = Color3.fromRGB(39, 201, 63)
    maxBtn.Position = UDim2.new(0, 40, 0, 0)
    maxBtn.Size = UDim2.new(0, 12, 0, 12)
    maxBtn.Font = Enum.Font.Gotham
    maxBtn.Text = ""
    Instance.new("UICorner", maxBtn).CornerRadius = UDim.new(1, 0)

    local minimized = false
    
    -- BUG FIX: Does NOT destroy the GUI, hides it so the toggle hotkey works
    closeBtn.MouseButton1Click:Connect(function()
        game.TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0, Main.AbsolutePosition.X + (Main.AbsoluteSize.X / 2), 0, Main.AbsolutePosition.Y + (Main.AbsoluteSize.Y / 2))
        }):Play()
        task.wait(0.3)
        ScreenGui.Enabled = false
        -- Reset size invisibly so it's normal when re-opened
        Main.Size = UDim2.new(0, 525, 0, minimized and 38 or 318)
    end)
    
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            game.TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 525, 0, 38)
            }):Play()
        else
            game.TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 525, 0, 318)
            }):Play()
        end
    end)

    MainSide.Name = "MainSide"
    MainSide.Parent = Main
    MainSide.BackgroundColor3 = themeList.Header
    Objects[MainSide] = "Header"
    MainSide.Position = UDim2.new(0, 0, 0, 38)
    MainSide.Size = UDim2.new(0, 149, 0, 280)

    sideCorner.CornerRadius = UDim.new(0, 12)
    sideCorner.Name = "sideCorner"
    sideCorner.Parent = MainSide

    coverup_2.Name = "coverup"
    coverup_2.Parent = MainSide
    coverup_2.BackgroundColor3 = themeList.Header
    Objects[coverup_2] = "Header"
    coverup_2.BorderSizePixel = 0
    coverup_2.Position = UDim2.new(0.95, 0, 0, 0)
    coverup_2.Size = UDim2.new(0, 7, 0, 280)
    coverup_2.ZIndex = 0

    tabFrames.Name = "tabFrames"
    tabFrames.Parent = MainSide
    tabFrames.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    tabFrames.BackgroundTransparency = 1.000
    tabFrames.Position = UDim2.new(0.044, 0, 0.02, 0)
    tabFrames.Size = UDim2.new(0, 135, 0, 270)

    tabListing.Name = "tabListing"
    tabListing.Parent = tabFrames
    tabListing.SortOrder = Enum.SortOrder.LayoutOrder
    tabListing.Padding = UDim.new(0, 2)

    pages.Name = "pages"
    pages.Parent = Main
    pages.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    pages.BackgroundTransparency = 1.000
    pages.BorderSizePixel = 0
    pages.Position = UDim2.new(0.299, 0, 0.135, 0)
    pages.Size = UDim2.new(0, 360, 0, 269)

    Pages.Name = "Pages"
    Pages.Parent = pages

    infoContainer.Name = "infoContainer"
    infoContainer.Parent = Main
    infoContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    infoContainer.BackgroundTransparency = 1.000
    infoContainer.BorderColor3 = Color3.fromRGB(27, 42, 53)
    infoContainer.ClipsDescendants = true
    infoContainer.Position = UDim2.new(0.299, 0, 0.874, 0)
    infoContainer.Size = UDim2.new(0, 368, 0, 33)

    coroutine.wrap(function()
        while task.wait(0.5) do
            Main.BackgroundColor3 = themeList.Background
            MainHeader.BackgroundColor3 = themeList.Header
            MainSide.BackgroundColor3 = themeList.Header
            coverup_2.BackgroundColor3 = themeList.Header
            coverup.BackgroundColor3 = themeList.Header
        end
    end)()

    function Kavo:ChangeColor(prope,color)
        if prope == "Background" then themeList.Background = color
        elseif prope == "SchemeColor" then themeList.SchemeColor = color
        elseif prope == "Header" then themeList.Header = color
        elseif prope == "TextColor" then themeList.TextColor = color
        elseif prope == "ElementColor" then themeList.ElementColor = color end
    end
    
    local Tabs = {}
    local first = true

    function Tabs:NewTab(tabName)
        tabName = tabName or "Tab"
        local tabButton = Instance.new("TextButton")
        local UICorner = Instance.new("UICorner")
        local page = Instance.new("ScrollingFrame")
        local pageListing = Instance.new("UIListLayout")

        local function UpdateSize()
            local cS = pageListing.AbsoluteContentSize
            game.TweenService:Create(page, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                CanvasSize = UDim2.new(0,cS.X,0,cS.Y)
            }):Play()
        end

        page.Name = "Page"
        page.Parent = Pages
        page.Active = true
        page.BackgroundColor3 = themeList.Background
        page.BorderSizePixel = 0
        page.Position = UDim2.new(0, 0, -0.003, 0)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.ScrollBarThickness = 4
        page.Visible = false
        page.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)

        pageListing.Name = "pageListing"
        pageListing.Parent = page
        pageListing.SortOrder = Enum.SortOrder.LayoutOrder
        pageListing.Padding = UDim.new(0, 6) -- Slightly more breathing room

        tabButton.Name = tabName.."TabButton"
        tabButton.Parent = tabFrames
        tabButton.BackgroundColor3 = themeList.SchemeColor
        Objects[tabButton] = "SchemeColor"
        tabButton.Size = UDim2.new(0, 130, 0, 26)
        tabButton.AutoButtonColor = false
        tabButton.Font = Enum.Font.Gotham
        tabButton.Text = "  " .. tabName
        tabButton.TextXAlignment = Enum.TextXAlignment.Left
        tabButton.TextColor3 = themeList.TextColor
        Objects[tabButton] = "TextColor3"
        tabButton.TextSize = 13.000
        tabButton.BackgroundTransparency = 1

        if first then
            first = false
            page.Visible = true
            tabButton.BackgroundTransparency = 0
            tabButton.Font = Enum.Font.GothamSemibold
            UpdateSize()
        else
            page.Visible = false
            tabButton.BackgroundTransparency = 1
            tabButton.Font = Enum.Font.Gotham
        end

        UICorner.CornerRadius = UDim.new(0, 6)
        UICorner.Parent = tabButton
        table.insert(Tabs, tabName)

        UpdateSize()
        page.ChildAdded:Connect(UpdateSize)
        page.ChildRemoved:Connect(UpdateSize)

        tabButton.MouseButton1Click:Connect(function()
            UpdateSize()
            for i,v in next, Pages:GetChildren() do v.Visible = false end
            page.Visible = true
            for i,v in next, tabFrames:GetChildren() do
                if v:IsA("TextButton") then
                    Utility:TweenObject(v, {BackgroundTransparency = 1}, 0.3)
                    v.Font = Enum.Font.Gotham
                end
            end
            Utility:TweenObject(tabButton, {BackgroundTransparency = 0}, 0.3)
            tabButton.Font = Enum.Font.GothamSemibold
        end)
        
        local Sections = {}
        local focusing = false
        local viewDe = false

        function Sections:NewSection(secName, hidden)
            secName = secName or "Section"
            local sectionFunctions = {}
            local modules = {}
            hidden = hidden or false
            local sectionFrame = Instance.new("Frame")
            local sectionlistoknvm = Instance.new("UIListLayout")
            local sectionHead = Instance.new("Frame")
            local sHeadCorner = Instance.new("UICorner")
            local sectionName = Instance.new("TextLabel")
            local sectionInners = Instance.new("Frame")
            local sectionElListing = Instance.new("UIListLayout")
            
            if hidden then sectionHead.Visible = false else sectionHead.Visible = true end

            sectionFrame.Name = "sectionFrame"
            sectionFrame.Parent = page
            sectionFrame.BackgroundColor3 = themeList.Background
            sectionFrame.BorderSizePixel = 0
            
            sectionlistoknvm.Name = "sectionlistoknvm"
            sectionlistoknvm.Parent = sectionFrame
            sectionlistoknvm.SortOrder = Enum.SortOrder.LayoutOrder
            sectionlistoknvm.Padding = UDim.new(0, 5)

            for i,v in pairs(sectionInners:GetChildren()) do
                v.Changed:Connect(function(pro)
                    if pro == "Size" then
                        UpdateSize()
                        updateSectionFrame()
                    end
                end)
            end
            
            sectionHead.Name = "sectionHead"
            sectionHead.Parent = sectionFrame
            sectionHead.BackgroundTransparency = 1
            sectionHead.Size = UDim2.new(0, 345, 0, 25)

            sectionName.Name = "sectionName"
            sectionName.Parent = sectionHead
            sectionName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            sectionName.BackgroundTransparency = 1.000
            sectionName.Position = UDim2.new(0.01, 0, 0.2, 0)
            sectionName.Size = UDim2.new(0.98, 0, 1, 0)
            sectionName.Font = Enum.Font.GothamSemibold
            sectionName.Text = secName
            sectionName.RichText = true
            sectionName.TextColor3 = Color3.fromRGB(150, 150, 150)
            sectionName.TextSize = 12.000
            sectionName.TextXAlignment = Enum.TextXAlignment.Left
               
            sectionInners.Name = "sectionInners"
            sectionInners.Parent = sectionFrame
            sectionInners.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            sectionInners.BackgroundTransparency = 1.000
            sectionInners.Position = UDim2.new(0, 0, 0.19, 0)

            sectionElListing.Name = "sectionElListing"
            sectionElListing.Parent = sectionInners
            sectionElListing.SortOrder = Enum.SortOrder.LayoutOrder
            sectionElListing.Padding = UDim.new(0, 4)

            local function updateSectionFrame()
                local innerSc = sectionElListing.AbsoluteContentSize
                sectionInners.Size = UDim2.new(1, 0, 0, innerSc.Y)
                local frameSc = sectionlistoknvm.AbsoluteContentSize
                sectionFrame.Size = UDim2.new(0, 345, 0, frameSc.Y)
            end
            updateSectionFrame()
            UpdateSize()
            
            local Elements = {}
            function Elements:NewButton(bname,tipINf, callback)
                local ButtonFunction = {}
                tipINf = tipINf or "Tip: Clicking this nothing will happen!"
                bname = bname or "Click Me!"
                callback = callback or function() end

                local buttonElement = Instance.new("TextButton")
                local UICorner = Instance.new("UICorner")
                local btnInfo = Instance.new("TextLabel")
                local touch = Instance.new("ImageLabel")

                table.insert(modules, bname)

                buttonElement.Name = bname
                buttonElement.Parent = sectionInners
                buttonElement.BackgroundColor3 = themeList.ElementColor
                buttonElement.ClipsDescendants = true
                buttonElement.Size = UDim2.new(0, 345, 0, 32)
                buttonElement.AutoButtonColor = false
                buttonElement.Font = Enum.Font.Gotham
                buttonElement.Text = ""
                Objects[buttonElement] = "BackgroundColor3"

                UICorner.CornerRadius = UDim.new(0, 6)
                UICorner.Parent = buttonElement
                
                local btnStroke = Instance.new("UIStroke", buttonElement)
                btnStroke.Color = Color3.fromRGB(0,0,0)
                btnStroke.Transparency = 0.8
                btnStroke.Thickness = 1

                touch.Name = "touch"
                touch.Parent = buttonElement
                touch.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                touch.BackgroundTransparency = 1.000
                touch.Position = UDim2.new(0.02, 0, 0.15, 0)
                touch.Size = UDim2.new(0, 20, 0, 20)
                touch.Image = "rbxassetid://3926305904"
                touch.ImageColor3 = themeList.SchemeColor
                Objects[touch] = "SchemeColor"
                touch.ImageRectOffset = Vector2.new(84, 204)
                touch.ImageRectSize = Vector2.new(36, 36)

                btnInfo.Name = "btnInfo"
                btnInfo.Parent = buttonElement
                btnInfo.BackgroundTransparency = 1.000
                btnInfo.Position = UDim2.new(0.096, 0, 0.27, 0)
                btnInfo.Size = UDim2.new(0, 314, 0, 14)
                btnInfo.Font = Enum.Font.Gotham
                btnInfo.Text = bname
                btnInfo.TextColor3 = themeList.TextColor
                Objects[btnInfo] = "TextColor3"
                btnInfo.TextSize = 13.000
                btnInfo.TextXAlignment = Enum.TextXAlignment.Left

                updateSectionFrame()
                UpdateSize()

                local btn = buttonElement

                btn.MouseButton1Click:Connect(function()
                    if not focusing then
                        callback()
                        -- Swift macOS button pulse
                        Utility:TweenObject(btn, {BackgroundColor3 = Color3.fromRGB(themeList.SchemeColor.r * 255, themeList.SchemeColor.g * 255, themeList.SchemeColor.b * 255)}, 0.1)
                        Utility:TweenObject(btnInfo, {TextColor3 = Color3.fromRGB(30, 30, 32)}, 0.1)
                        task.wait(0.1)
                        Utility:TweenObject(btn, {BackgroundColor3 = themeList.ElementColor}, 0.3)
                        Utility:TweenObject(btnInfo, {TextColor3 = themeList.TextColor}, 0.3)
                    end
                end)
                
                local hovering = false
                btn.MouseEnter:Connect(function()
                    if not focusing then
                        Utility:TweenObject(btn, {BackgroundColor3 = Color3.fromRGB(themeList.ElementColor.r * 255 + 10, themeList.ElementColor.g * 255 + 10, themeList.ElementColor.b * 255 + 10)}, 0.3)
                        hovering = true
                    end
                end)
                btn.MouseLeave:Connect(function()
                    if not focusing then 
                        Utility:TweenObject(btn, {BackgroundColor3 = themeList.ElementColor}, 0.3)
                        hovering = false
                    end
                end)
                
                function ButtonFunction:UpdateButton(newTitle)
                    btnInfo.Text = newTitle
                end
                return ButtonFunction
            end

            function Elements:NewTextBox(tname, tTip, callback)
                tname = tname or "Textbox"
                callback = callback or function() end
                local textboxElement = Instance.new("TextButton")
                local UICorner = Instance.new("UICorner")
                local write = Instance.new("ImageLabel")
                local TextBox = Instance.new("TextBox")
                local UICorner_2 = Instance.new("UICorner")
                local togName = Instance.new("TextLabel")

                textboxElement.Name = "textboxElement"
                textboxElement.Parent = sectionInners
                textboxElement.BackgroundColor3 = themeList.ElementColor
                textboxElement.ClipsDescendants = true
                textboxElement.Size = UDim2.new(0, 345, 0, 32)
                textboxElement.AutoButtonColor = false
                textboxElement.Text = ""
                
                local btnStroke = Instance.new("UIStroke", textboxElement)
                btnStroke.Color = Color3.fromRGB(0,0,0)
                btnStroke.Transparency = 0.8
                btnStroke.Thickness = 1

                UICorner.CornerRadius = UDim.new(0, 6)
                UICorner.Parent = textboxElement

                write.Name = "write"
                write.Parent = textboxElement
                write.BackgroundTransparency = 1.000
                write.Position = UDim2.new(0.02, 0, 0.15, 0)
                write.Size = UDim2.new(0, 20, 0, 20)
                write.Image = "rbxassetid://3926305904"
                write.ImageColor3 = themeList.SchemeColor
                write.ImageRectOffset = Vector2.new(324, 604)
                write.ImageRectSize = Vector2.new(36, 36)

                TextBox.Parent = textboxElement
                TextBox.BackgroundColor3 = Color3.fromRGB(themeList.ElementColor.r * 255 - 10, themeList.ElementColor.g * 255 - 10, themeList.ElementColor.b * 255 - 10)
                TextBox.BorderSizePixel = 0
                TextBox.ClipsDescendants = true
                TextBox.Position = UDim2.new(0.488, 0, 0.2, 0)
                TextBox.Size = UDim2.new(0, 150, 0, 20)
                TextBox.Font = Enum.Font.Gotham
                TextBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
                TextBox.PlaceholderText = "Type here..."
                TextBox.Text = ""
                TextBox.TextColor3 = themeList.TextColor
                TextBox.TextSize = 12.000
                
                local boxStroke = Instance.new("UIStroke", TextBox)
                boxStroke.Color = Color3.fromRGB(0,0,0)
                boxStroke.Transparency = 0.8
                boxStroke.Thickness = 1

                UICorner_2.CornerRadius = UDim.new(0, 4)
                UICorner_2.Parent = TextBox

                togName.Name = "togName"
                togName.Parent = textboxElement
                togName.BackgroundTransparency = 1.000
                togName.Position = UDim2.new(0.096, 0, 0.27, 0)
                togName.Size = UDim2.new(0, 138, 0, 14)
                togName.Font = Enum.Font.Gotham
                togName.Text = tname
                togName.TextColor3 = themeList.TextColor
                togName.TextSize = 13.000
                togName.TextXAlignment = Enum.TextXAlignment.Left

                updateSectionFrame()
                UpdateSize()
            
                local btn = textboxElement

                local hovering = false
                btn.MouseEnter:Connect(function()
                    if not focusing then
                        Utility:TweenObject(btn, {BackgroundColor3 = Color3.fromRGB(themeList.ElementColor.r * 255 + 10, themeList.ElementColor.g * 255 + 10, themeList.ElementColor.b * 255 + 10)}, 0.3)
                        hovering = true
                    end 
                end)

                btn.MouseLeave:Connect(function()
                    if not focusing then
                        Utility:TweenObject(btn, {BackgroundColor3 = themeList.ElementColor}, 0.3)
                        hovering = false
                    end
                end)

                -- BUG FIX: Removed TextBox.Text = "" so user inputs stay visible
                TextBox.FocusLost:Connect(function(EnterPressed)
                    if EnterPressed then
                        callback(TextBox.Text)
                    end
                end)
            end 

            function Elements:NewToggle(tname, nTip, callback)
                local TogFunction = {}
                tname = tname or "Toggle"
                callback = callback or function() end
                local toggled = false
                table.insert(SettingsT, tname)

                local toggleElement = Instance.new("TextButton")
                local UICorner = Instance.new("UICorner")
                local toggleDisabled = Instance.new("ImageLabel")
                local toggleEnabled = Instance.new("ImageLabel")
                local togName = Instance.new("TextLabel")

                toggleElement.Name = "toggleElement"
                toggleElement.Parent = sectionInners
                toggleElement.BackgroundColor3 = themeList.ElementColor
                toggleElement.ClipsDescendants = true
                toggleElement.Size = UDim2.new(0, 345, 0, 32)
                toggleElement.AutoButtonColor = false
                toggleElement.Text = ""

                UICorner.CornerRadius = UDim.new(0, 6)
                UICorner.Parent = toggleElement
                
                local btnStroke = Instance.new("UIStroke", toggleElement)
                btnStroke.Color = Color3.fromRGB(0,0,0)
                btnStroke.Transparency = 0.8
                btnStroke.Thickness = 1

                toggleDisabled.Name = "toggleDisabled"
                toggleDisabled.Parent = toggleElement
                toggleDisabled.BackgroundTransparency = 1.000
                toggleDisabled.Position = UDim2.new(0.02, 0, 0.15, 0)
                toggleDisabled.Size = UDim2.new(0, 20, 0, 20)
                toggleDisabled.Image = "rbxassetid://3926309567"
                toggleDisabled.ImageColor3 = Color3.fromRGB(120, 120, 120)
                toggleDisabled.ImageRectOffset = Vector2.new(628, 420)
                toggleDisabled.ImageRectSize = Vector2.new(48, 48)

                toggleEnabled.Name = "toggleEnabled"
                toggleEnabled.Parent = toggleElement
                toggleEnabled.BackgroundTransparency = 1.000
                toggleEnabled.Position = UDim2.new(0.02, 0, 0.15, 0)
                toggleEnabled.Size = UDim2.new(0, 20, 0, 20)
                toggleEnabled.Image = "rbxassetid://3926309567"
                toggleEnabled.ImageColor3 = themeList.SchemeColor
                toggleEnabled.ImageRectOffset = Vector2.new(784, 420)
                toggleEnabled.ImageRectSize = Vector2.new(48, 48)
                toggleEnabled.ImageTransparency = 1.000

                togName.Name = "togName"
                togName.Parent = toggleElement
                togName.BackgroundTransparency = 1.000
                togName.Position = UDim2.new(0.096, 0, 0.27, 0)
                togName.Size = UDim2.new(0, 288, 0, 14)
                togName.Font = Enum.Font.Gotham
                togName.Text = tname
                togName.TextColor3 = themeList.TextColor
                togName.TextSize = 13.000
                togName.TextXAlignment = Enum.TextXAlignment.Left

                local btn = toggleElement
                local img = toggleEnabled

                updateSectionFrame()
                UpdateSize()

                btn.MouseButton1Click:Connect(function()
                    if not focusing then
                        toggled = not toggled
                        if toggled then
                            Utility:TweenObject(img, {ImageTransparency = 0}, 0.3)
                        else
                            Utility:TweenObject(img, {ImageTransparency = 1}, 0.3)
                        end
                        pcall(callback, toggled)
                    end
                end)
                
                local hovering = false
                btn.MouseEnter:Connect(function()
                    if not focusing then
                        Utility:TweenObject(btn, {BackgroundColor3 = Color3.fromRGB(themeList.ElementColor.r * 255 + 10, themeList.ElementColor.g * 255 + 10, themeList.ElementColor.b * 255 + 10)}, 0.3)
                        hovering = true
                    end 
                end)
                btn.MouseLeave:Connect(function()
                    if not focusing then
                        Utility:TweenObject(btn, {BackgroundColor3 = themeList.ElementColor}, 0.3)
                        hovering = false
                    end
                end)

                function TogFunction:UpdateToggle(newText, isTogOn)
                    isTogOn = isTogOn or toggled
                    if newText ~= nil then togName.Text = newText end
                    if isTogOn then
                        toggled = true
                        Utility:TweenObject(img, {ImageTransparency = 0}, 0.3)
                        pcall(callback, toggled)
                    else
                        toggled = false
                        Utility:TweenObject(img, {ImageTransparency = 1}, 0.3)
                        pcall(callback, toggled)
                    end
                end
                return TogFunction
            end

            function Elements:NewSlider(slidInf, slidTip, maxvalue, minvalue, callback)
                slidInf = slidInf or "Slider"
                maxvalue = maxvalue or 500
                minvalue = minvalue or 16
                callback = callback or function() end

                local sliderElement = Instance.new("TextButton")
                local UICorner = Instance.new("UICorner")
                local togName = Instance.new("TextLabel")
                local sliderBtn = Instance.new("TextButton")
                local UICorner_2 = Instance.new("UICorner")
                local UIListLayout = Instance.new("UIListLayout")
                local sliderDrag = Instance.new("Frame")
                local UICorner_3 = Instance.new("UICorner")
                local write = Instance.new("ImageLabel")
                local val = Instance.new("TextLabel")

                sliderElement.Name = "sliderElement"
                sliderElement.Parent = sectionInners
                sliderElement.BackgroundColor3 = themeList.ElementColor
                sliderElement.ClipsDescendants = true
                sliderElement.Size = UDim2.new(0, 345, 0, 32)
                sliderElement.AutoButtonColor = false
                sliderElement.Text = ""
                
                local btnStroke = Instance.new("UIStroke", sliderElement)
                btnStroke.Color = Color3.fromRGB(0,0,0)
                btnStroke.Transparency = 0.8
                btnStroke.Thickness = 1

                UICorner.CornerRadius = UDim.new(0, 6)
                UICorner.Parent = sliderElement

                togName.Name = "togName"
                togName.Parent = sliderElement
                togName.BackgroundTransparency = 1.000
                togName.Position = UDim2.new(0.096, 0, 0.27, 0)
                togName.Size = UDim2.new(0, 138, 0, 14)
                togName.Font = Enum.Font.Gotham
                togName.Text = slidInf
                togName.TextColor3 = themeList.TextColor
                togName.TextSize = 13.000
                togName.TextXAlignment = Enum.TextXAlignment.Left

                sliderBtn.Name = "sliderBtn"
                sliderBtn.Parent = sliderElement
                sliderBtn.BackgroundColor3 = Color3.fromRGB(themeList.ElementColor.r * 255 + 15, themeList.ElementColor.g * 255 + 15, themeList.ElementColor.b * 255  + 15)
                sliderBtn.BorderSizePixel = 0
                sliderBtn.Position = UDim2.new(0.488, 0, 0.45, 0)
                sliderBtn.Size = UDim2.new(0, 149, 0, 4)
                sliderBtn.AutoButtonColor = false
                sliderBtn.Text = ""
                
                local btnStroke2 = Instance.new("UIStroke", sliderBtn)
                btnStroke2.Color = Color3.fromRGB(0,0,0)
                btnStroke2.Transparency = 0.8
                btnStroke2.Thickness = 1

                UICorner_2.CornerRadius = UDim.new(1,0)
                UICorner_2.Parent = sliderBtn

                UIListLayout.Parent = sliderBtn
                UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

                sliderDrag.Name = "sliderDrag"
                sliderDrag.Parent = sliderBtn
                sliderDrag.BackgroundColor3 = themeList.SchemeColor
                sliderDrag.BorderSizePixel = 0
                sliderDrag.Size = UDim2.new(0, 0, 1, 0)

                UICorner_3.CornerRadius = UDim.new(1,0)
                UICorner_3.Parent = sliderDrag

                write.Name = "write"
                write.Parent = sliderElement
                write.BackgroundTransparency = 1.000
                write.Position = UDim2.new(0.02, 0, 0.15, 0)
                write.Size = UDim2.new(0, 20, 0, 20)
                write.Image = "rbxassetid://3926307971"
                write.ImageColor3 = themeList.SchemeColor
                write.ImageRectOffset = Vector2.new(404, 164)
                write.ImageRectSize = Vector2.new(36, 36)

                val.Name = "val"
                val.Parent = sliderElement
                val.BackgroundTransparency = 1.000
                val.Position = UDim2.new(0.35, 0, 0.27, 0)
                val.Size = UDim2.new(0, 41, 0, 14)
                val.Font = Enum.Font.Gotham
                val.Text = minvalue
                val.TextColor3 = themeList.TextColor
                val.TextSize = 12.000
                val.TextTransparency = 1.000
                val.TextXAlignment = Enum.TextXAlignment.Right

                updateSectionFrame()
                UpdateSize()

                local mouse = game.Players.LocalPlayer:GetMouse()
                local uis = game:GetService("UserInputService")
                local btn = sliderElement
                
                local hovering = false
                btn.MouseEnter:Connect(function()
                    if not focusing then
                        Utility:TweenObject(btn, {BackgroundColor3 = Color3.fromRGB(themeList.ElementColor.r * 255 + 10, themeList.ElementColor.g * 255 + 10, themeList.ElementColor.b * 255 + 10)}, 0.3)
                        hovering = true
                    end 
                end)
                btn.MouseLeave:Connect(function()
                    if not focusing then
                        Utility:TweenObject(btn, {BackgroundColor3 = themeList.ElementColor}, 0.3)
                        hovering = false
                    end
                end)        

                local Value
                local moveconnection
                local releaseconnection
                
                sliderBtn.MouseButton1Down:Connect(function()
                    if not focusing then
                        Utility:TweenObject(val, {TextTransparency = 0}, 0.3)
                        Value = math.floor((((tonumber(maxvalue) - tonumber(minvalue)) / 149) * sliderDrag.AbsoluteSize.X) + tonumber(minvalue)) or 0
                        pcall(function() callback(Value) end)
                        sliderDrag:TweenSize(UDim2.new(0, math.clamp(mouse.X - sliderDrag.AbsolutePosition.X, 0, 149), 1, 0), "InOut", "Quint", 0.3, true)
                        
                        moveconnection = mouse.Move:Connect(function()
                            val.Text = Value
                            Value = math.floor((((tonumber(maxvalue) - tonumber(minvalue)) / 149) * sliderDrag.AbsoluteSize.X) + tonumber(minvalue))
                            pcall(function() callback(Value) end)
                            sliderDrag:TweenSize(UDim2.new(0, math.clamp(mouse.X - sliderDrag.AbsolutePosition.X, 0, 149), 1, 0), "InOut", "Quint", 0.3, true)
                        end)
                        
                        releaseconnection = uis.InputEnded:Connect(function(Mouse)
                            if Mouse.UserInputType == Enum.UserInputType.MouseButton1 then
                                Value = math.floor((((tonumber(maxvalue) - tonumber(minvalue)) / 149) * sliderDrag.AbsoluteSize.X) + tonumber(minvalue))
                                pcall(function() callback(Value) end)
                                val.Text = Value
                                Utility:TweenObject(val, {TextTransparency = 1}, 0.3)
                                sliderDrag:TweenSize(UDim2.new(0, math.clamp(mouse.X - sliderDrag.AbsolutePosition.X, 0, 149), 1, 0), "InOut", "Quint", 0.3, true)
                                moveconnection:Disconnect()
                                releaseconnection:Disconnect()
                            end
                        end)
                    end
                end)
            end

            function Elements:NewDropdown(dropname, dropinf, list, callback)
                local DropFunction = {}
                dropname = dropname or "Dropdown"
                list = list or {}
                callback = callback or function() end   

                local opened = false
                local DropYSize = 32

                local dropFrame = Instance.new("Frame")
                local dropOpen = Instance.new("TextButton")
                local listImg = Instance.new("ImageLabel")
                local itemTextbox = Instance.new("TextLabel")
                local UICorner = Instance.new("UICorner")
                local UIListLayout = Instance.new("UIListLayout")

                local ms = game.Players.LocalPlayer:GetMouse()
                
                dropFrame.Name = "dropFrame"
                dropFrame.Parent = sectionInners
                dropFrame.BackgroundColor3 = themeList.Background
                dropFrame.BorderSizePixel = 0
                dropFrame.Size = UDim2.new(0, 345, 0, 32)
                dropFrame.ClipsDescendants = true
                
                local btn = dropOpen
                dropOpen.Name = "dropOpen"
                dropOpen.Parent = dropFrame
                dropOpen.BackgroundColor3 = themeList.ElementColor
                dropOpen.Size = UDim2.new(0, 345, 0, 32)
                dropOpen.AutoButtonColor = false
                dropOpen.Text = ""
                dropOpen.ClipsDescendants = true
                
                local btnStroke = Instance.new("UIStroke", dropOpen)
                btnStroke.Color = Color3.fromRGB(0,0,0)
                btnStroke.Transparency = 0.8
                btnStroke.Thickness = 1

                dropOpen.MouseButton1Click:Connect(function()
                    if not focusing then
                        if opened then
                            opened = false
                            dropFrame:TweenSize(UDim2.new(0, 345, 0, 32), "InOut", "Quint", 0.3, true)
                            task.wait(0.1)
                            updateSectionFrame()
                            UpdateSize()
                        else
                            opened = true
                            dropFrame:TweenSize(UDim2.new(0, 345, 0, UIListLayout.AbsoluteContentSize.Y), "InOut", "Quint", 0.3, true)
                            task.wait(0.1)
                            updateSectionFrame()
                            UpdateSize()
                        end
                    end
                end)

                listImg.Name = "listImg"
                listImg.Parent = dropOpen
                listImg.BackgroundTransparency = 1.000
                listImg.Position = UDim2.new(0.02, 0, 0.15, 0)
                listImg.Size = UDim2.new(0, 20, 0, 20)
                listImg.Image = "rbxassetid://3926305904"
                listImg.ImageColor3 = themeList.SchemeColor
                listImg.ImageRectOffset = Vector2.new(644, 364)
                listImg.ImageRectSize = Vector2.new(36, 36)

                itemTextbox.Name = "itemTextbox"
                itemTextbox.Parent = dropOpen
                itemTextbox.BackgroundTransparency = 1.000
                itemTextbox.Position = UDim2.new(0.097, 0, 0.27, 0)
                itemTextbox.Size = UDim2.new(0, 138, 0, 14)
                itemTextbox.Font = Enum.Font.Gotham
                itemTextbox.Text = dropname
                itemTextbox.TextColor3 = themeList.TextColor
                itemTextbox.TextSize = 13.000
                itemTextbox.TextXAlignment = Enum.TextXAlignment.Left

                UICorner.CornerRadius = UDim.new(0, 6)
                UICorner.Parent = dropOpen

                UIListLayout.Parent = dropFrame
                UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                UIListLayout.Padding = UDim.new(0, 2)

                updateSectionFrame() 
                UpdateSize()

                local hovering = false
                btn.MouseEnter:Connect(function()
                    if not focusing then
                        Utility:TweenObject(btn, {BackgroundColor3 = Color3.fromRGB(themeList.ElementColor.r * 255 + 10, themeList.ElementColor.g * 255 + 10, themeList.ElementColor.b * 255 + 10)}, 0.3)
                        hovering = true
                    end 
                end)
                btn.MouseLeave:Connect(function()
                    if not focusing then
                        Utility:TweenObject(btn, {BackgroundColor3 = themeList.ElementColor}, 0.3)
                        hovering = false
                    end
                end)        

                for i,v in next, list do
                    local optionSelect = Instance.new("TextButton")
                    local UICorner_2 = Instance.new("UICorner")

                    DropYSize = DropYSize + 32
                    optionSelect.Name = "optionSelect"
                    optionSelect.Parent = dropFrame
                    optionSelect.BackgroundColor3 = themeList.ElementColor
                    optionSelect.Position = UDim2.new(0, 0, 0, 0)
                    optionSelect.Size = UDim2.new(0, 345, 0, 32)
                    optionSelect.AutoButtonColor = false
                    optionSelect.Font = Enum.Font.Gotham
                    optionSelect.Text = "  "..v
                    optionSelect.TextColor3 = Color3.fromRGB(180, 180, 180)
                    optionSelect.TextSize = 13.000
                    optionSelect.TextXAlignment = Enum.TextXAlignment.Left
                    
                    local optStroke = Instance.new("UIStroke", optionSelect)
                    optStroke.Color = Color3.fromRGB(0,0,0)
                    optStroke.Transparency = 0.8
                    optStroke.Thickness = 1

                    optionSelect.MouseButton1Click:Connect(function()
                        if not focusing then
                            opened = false
                            callback(v)
                            itemTextbox.Text = v
                            dropFrame:TweenSize(UDim2.new(0, 345, 0, 32), 'InOut', 'Quint', 0.3, true)
                            task.wait(0.1)
                            updateSectionFrame()
                            UpdateSize()
                        end
                    end)
    
                    UICorner_2.CornerRadius = UDim.new(0, 6)
                    UICorner_2.Parent = optionSelect

                    local oHover = false
                    optionSelect.MouseEnter:Connect(function()
                        if not focusing then
                            Utility:TweenObject(optionSelect, {BackgroundColor3 = Color3.fromRGB(themeList.ElementColor.r * 255 + 10, themeList.ElementColor.g * 255 + 10, themeList.ElementColor.b * 255 + 10), TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.3)
                            oHover = true
                        end 
                    end)
                    optionSelect.MouseLeave:Connect(function()
                        if not focusing then
                            Utility:TweenObject(optionSelect, {BackgroundColor3 = themeList.ElementColor, TextColor3 = Color3.fromRGB(180, 180, 180)}, 0.3)
                            oHover = false
                        end
                    end)   
                end

                function DropFunction:Refresh(newList)
                    newList = newList or {}
                    for i,v in next, dropFrame:GetChildren() do
                        if v.Name == "optionSelect" then
                            v:Destroy()
                        end
                    end
                    for i,v in next, newList do
                        local optionSelect = Instance.new("TextButton")
                        local UICorner_2 = Instance.new("UICorner")
    
                        DropYSize = DropYSize + 32
                        optionSelect.Name = "optionSelect"
                        optionSelect.Parent = dropFrame
                        optionSelect.BackgroundColor3 = themeList.ElementColor
                        optionSelect.Size = UDim2.new(0, 345, 0, 32)
                        optionSelect.AutoButtonColor = false
                        optionSelect.Font = Enum.Font.Gotham
                        optionSelect.Text = "  "..v
                        optionSelect.TextColor3 = Color3.fromRGB(180, 180, 180)
                        optionSelect.TextSize = 13.000
                        optionSelect.TextXAlignment = Enum.TextXAlignment.Left
                        
                        local optStroke = Instance.new("UIStroke", optionSelect)
                        optStroke.Color = Color3.fromRGB(0,0,0)
                        optStroke.Transparency = 0.8
                        optStroke.Thickness = 1
                        
                        UICorner_2.CornerRadius = UDim.new(0, 6)
                        UICorner_2.Parent = optionSelect
                        
                        optionSelect.MouseButton1Click:Connect(function()
                            if not focusing then
                                opened = false
                                callback(v)
                                itemTextbox.Text = v
                                dropFrame:TweenSize(UDim2.new(0, 345, 0, 32), 'InOut', 'Quint', 0.3, true)
                                task.wait(0.1)
                                updateSectionFrame()
                                UpdateSize()       
                            end
                        end)
                        updateSectionFrame()
                        UpdateSize()
                        
                        local oHover = false
                        optionSelect.MouseEnter:Connect(function()
                            if not focusing then
                                Utility:TweenObject(optionSelect, {BackgroundColor3 = Color3.fromRGB(themeList.ElementColor.r * 255 + 10, themeList.ElementColor.g * 255 + 10, themeList.ElementColor.b * 255 + 10), TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.3)
                                oHover = true
                            end 
                        end)
                        optionSelect.MouseLeave:Connect(function()
                            if not focusing then
                                Utility:TweenObject(optionSelect, {BackgroundColor3 = themeList.ElementColor, TextColor3 = Color3.fromRGB(180, 180, 180)}, 0.3)
                                oHover = false
                            end
                        end)   
                    end
                    if opened then 
                        dropFrame:TweenSize(UDim2.new(0, 345, 0, UIListLayout.AbsoluteContentSize.Y), "InOut", "Quint", 0.3, true)
                        task.wait(0.1)
                        updateSectionFrame()
                        UpdateSize()
                    else
                        dropFrame:TweenSize(UDim2.new(0, 345, 0, 32), "InOut", "Quint", 0.3, true)
                        task.wait(0.1)
                        updateSectionFrame()
                        UpdateSize()
                    end
                end
                return DropFunction
            end
            
            function Elements:NewKeybind(keytext, keyinf, first, callback)
                keytext = keytext or "KeybindText"
                callback = callback or function() end
                local oldKey = first.Name
                local keybindElement = Instance.new("TextButton")
                local UICorner = Instance.new("UICorner")
                local togName = Instance.new("TextLabel")
                local touch = Instance.new("ImageLabel")
                local togName_2 = Instance.new("TextLabel")

                local ms = game.Players.LocalPlayer:GetMouse()
                local uis = game:GetService("UserInputService")

                keybindElement.Name = "keybindElement"
                keybindElement.Parent = sectionInners
                keybindElement.BackgroundColor3 = themeList.ElementColor
                keybindElement.ClipsDescendants = true
                keybindElement.Size = UDim2.new(0, 345, 0, 32)
                keybindElement.AutoButtonColor = false
                keybindElement.Text = ""
                
                local btnStroke = Instance.new("UIStroke", keybindElement)
                btnStroke.Color = Color3.fromRGB(0,0,0)
                btnStroke.Transparency = 0.8
                btnStroke.Thickness = 1

                keybindElement.MouseButton1Click:connect(function(e) 
                    if not focusing then
                        togName_2.Text = ". . ."
                        local a, b = game:GetService('UserInputService').InputBegan:wait();
                        if a.KeyCode.Name ~= "Unknown" then
                            togName_2.Text = a.KeyCode.Name
                            oldKey = a.KeyCode.Name;
                        end
                    end
                end)
        
                game:GetService("UserInputService").InputBegan:connect(function(current, ok) 
                    if not ok then 
                        if current.KeyCode.Name == oldKey then 
                            callback()
                        end
                    end
                end)

                UICorner.CornerRadius = UDim.new(0, 6)
                UICorner.Parent = keybindElement

                touch.Name = "touch"
                touch.Parent = keybindElement
                touch.BackgroundTransparency = 1.000
                touch.Position = UDim2.new(0.02, 0, 0.15, 0)
                touch.Size = UDim2.new(0, 20, 0, 20)
                touch.Image = "rbxassetid://3926305904"
                touch.ImageColor3 = themeList.SchemeColor
                touch.ImageRectOffset = Vector2.new(364, 284)
                touch.ImageRectSize = Vector2.new(36, 36)

                togName.Name = "togName"
                togName.Parent = keybindElement
                togName.BackgroundTransparency = 1.000
                togName.Position = UDim2.new(0.096, 0, 0.27, 0)
                togName.Size = UDim2.new(0, 222, 0, 14)
                togName.Font = Enum.Font.Gotham
                togName.Text = keytext
                togName.TextColor3 = themeList.TextColor
                togName.TextSize = 13.000
                togName.TextXAlignment = Enum.TextXAlignment.Left
                
                togName_2.Name = "togName"
                togName_2.Parent = keybindElement
                togName_2.BackgroundTransparency = 1.000
                togName_2.Position = UDim2.new(0.727, 0, 0.27, 0)
                togName_2.Size = UDim2.new(0, 70, 0, 14)
                togName_2.Font = Enum.Font.GothamSemibold
                togName_2.Text = oldKey
                togName_2.TextColor3 = themeList.SchemeColor
                togName_2.TextSize = 13.000
                togName_2.TextXAlignment = Enum.TextXAlignment.Right   

                updateSectionFrame()
                UpdateSize()
                local oHover = false
                keybindElement.MouseEnter:Connect(function()
                    if not focusing then
                        Utility:TweenObject(keybindElement, {BackgroundColor3 = Color3.fromRGB(themeList.ElementColor.r * 255 + 10, themeList.ElementColor.g * 255 + 10, themeList.ElementColor.b * 255 + 10)}, 0.3)
                        oHover = true
                    end 
                end)
                keybindElement.MouseLeave:Connect(function()
                    if not focusing then
                        Utility:TweenObject(keybindElement, {BackgroundColor3 = themeList.ElementColor}, 0.3)
                        oHover = false
                    end
                end)        
            end

            function Elements:NewColorPicker(colText, colInf, defcolor, callback)
                colText = colText or "ColorPicker"
                callback = callback or function() end
                defcolor = defcolor or Color3.fromRGB(1,1,1)
                local h, s, v = Color3.toHSV(defcolor)
                local ms = game.Players.LocalPlayer:GetMouse()
                local colorOpened = false
                local colorElement = Instance.new("TextButton")
                local UICorner = Instance.new("UICorner")
                local colorHeader = Instance.new("Frame")
                local UICorner_2 = Instance.new("UICorner")
                local touch = Instance.new("ImageLabel")
                local togName = Instance.new("TextLabel")
                local colorCurrent = Instance.new("Frame")
                local UICorner_3 = Instance.new("UICorner")
                local UIListLayout = Instance.new("UIListLayout")
                local colorInners = Instance.new("Frame")
                local UICorner_4 = Instance.new("UICorner")
                local rgb = Instance.new("ImageButton")
                local UICorner_5 = Instance.new("UICorner")
                local rbgcircle = Instance.new("ImageLabel")
                local darkness = Instance.new("ImageButton")
                local UICorner_6 = Instance.new("UICorner")
                local darkcircle = Instance.new("ImageLabel")
                local toggleDisabled = Instance.new("ImageLabel")
                local toggleEnabled = Instance.new("ImageLabel")
                local onrainbow = Instance.new("TextButton")
                local togName_2 = Instance.new("TextLabel")

                local btn = colorHeader

                colorElement.Name = "colorElement"
                colorElement.Parent = sectionInners
                colorElement.BackgroundColor3 = themeList.ElementColor
                colorElement.BackgroundTransparency = 1.000
                colorElement.ClipsDescendants = true
                colorElement.Size = UDim2.new(0, 345, 0, 32)
                colorElement.AutoButtonColor = false
                colorElement.Text = ""
                colorElement.MouseButton1Click:Connect(function()
                    if not focusing then
                        if colorOpened then
                            colorOpened = false
                            colorElement:TweenSize(UDim2.new(0, 345, 0, 32), "InOut", "Quint", 0.3, true)
                            task.wait(0.1)
                            updateSectionFrame()
                            UpdateSize()
                        else
                            colorOpened = true
                            colorElement:TweenSize(UDim2.new(0, 345, 0, 141), "InOut", "Quint", 0.3, true)
                            task.wait(0.1)
                            updateSectionFrame()
                            UpdateSize()
                        end
                    end
                end)
                UICorner.CornerRadius = UDim.new(0, 6)
                UICorner.Parent = colorElement

                colorHeader.Name = "colorHeader"
                colorHeader.Parent = colorElement
                colorHeader.BackgroundColor3 = themeList.ElementColor
                colorHeader.Size = UDim2.new(0, 345, 0, 32)
                colorHeader.ClipsDescendants = true
                
                local headerStroke = Instance.new("UIStroke", colorHeader)
                headerStroke.Color = Color3.fromRGB(0,0,0)
                headerStroke.Transparency = 0.8
                headerStroke.Thickness = 1

                UICorner_2.CornerRadius = UDim.new(0, 6)
                UICorner_2.Parent = colorHeader
                
                touch.Name = "touch"
                touch.Parent = colorHeader
                touch.BackgroundTransparency = 1.000
                touch.Position = UDim2.new(0.02, 0, 0.15, 0)
                touch.Size = UDim2.new(0, 20, 0, 20)
                touch.Image = "rbxassetid://3926305904"
                touch.ImageColor3 = themeList.SchemeColor
                touch.ImageRectOffset = Vector2.new(44, 964)
                touch.ImageRectSize = Vector2.new(36, 36)

                togName.Name = "togName"
                togName.Parent = colorHeader
                togName.BackgroundTransparency = 1.000
                togName.Position = UDim2.new(0.096, 0, 0.27, 0)
                togName.Size = UDim2.new(0, 288, 0, 14)
                togName.Font = Enum.Font.Gotham
                togName.Text = colText
                togName.TextColor3 = themeList.TextColor
                togName.TextSize = 13.000
                togName.TextXAlignment = Enum.TextXAlignment.Left

                colorCurrent.Name = "colorCurrent"
                colorCurrent.Parent = colorHeader
                colorCurrent.BackgroundColor3 = defcolor
                colorCurrent.Position = UDim2.new(0.79, 0, 0.2, 0)
                colorCurrent.Size = UDim2.new(0, 42, 0, 18)

                UICorner_3.CornerRadius = UDim.new(0, 4)
                UICorner_3.Parent = colorCurrent

                UIListLayout.Parent = colorElement
                UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                UIListLayout.Padding = UDim.new(0, 3)

                colorInners.Name = "colorInners"
                colorInners.Parent = colorElement
                colorInners.BackgroundColor3 = themeList.ElementColor
                colorInners.Size = UDim2.new(0, 345, 0, 105)

                UICorner_4.CornerRadius = UDim.new(0, 6)
                UICorner_4.Parent = colorInners

                rgb.Name = "rgb"
                rgb.Parent = colorInners
                rgb.BackgroundTransparency = 1.000
                rgb.Position = UDim2.new(0.02, 0, 0.05, 0)
                rgb.Size = UDim2.new(0, 211, 0, 93)
                rgb.Image = "http://www.roblox.com/asset/?id=6523286724"

                UICorner_5.CornerRadius = UDim.new(0, 4)
                UICorner_5.Parent = rgb

                rbgcircle.Name = "rbgcircle"
                rbgcircle.Parent = rgb
                rbgcircle.BackgroundTransparency = 1.000
                rbgcircle.Size = UDim2.new(0, 14, 0, 14)
                rbgcircle.Image = "rbxassetid://3926309567"
                rbgcircle.ImageColor3 = Color3.fromRGB(0, 0, 0)
                rbgcircle.ImageRectOffset = Vector2.new(628, 420)
                rbgcircle.ImageRectSize = Vector2.new(48, 48)

                darkness.Name = "darkness"
                darkness.Parent = colorInners
                darkness.BackgroundTransparency = 1.000
                darkness.Position = UDim2.new(0.65, 0, 0.05, 0)
                darkness.Size = UDim2.new(0, 18, 0, 93)
                darkness.Image = "http://www.roblox.com/asset/?id=6523291212"

                UICorner_6.CornerRadius = UDim.new(0, 4)
                UICorner_6.Parent = darkness

                darkcircle.Name = "darkcircle"
                darkcircle.Parent = darkness
                darkcircle.AnchorPoint = Vector2.new(0.5, 0)
                darkcircle.BackgroundTransparency = 1.000
                darkcircle.Size = UDim2.new(0, 14, 0, 14)
                darkcircle.Image = "rbxassetid://3926309567"
                darkcircle.ImageColor3 = Color3.fromRGB(0, 0, 0)
                darkcircle.ImageRectOffset = Vector2.new(628, 420)
                darkcircle.ImageRectSize = Vector2.new(48, 48)

                toggleDisabled.Name = "toggleDisabled"
                toggleDisabled.Parent = colorInners
                toggleDisabled.BackgroundTransparency = 1.000
                toggleDisabled.Position = UDim2.new(0.73, 0, 0.06, 0)
                toggleDisabled.Size = UDim2.new(0, 20, 0, 20)
                toggleDisabled.Image = "rbxassetid://3926309567"
                toggleDisabled.ImageColor3 = Color3.fromRGB(120, 120, 120)
                toggleDisabled.ImageRectOffset = Vector2.new(628, 420)
                toggleDisabled.ImageRectSize = Vector2.new(48, 48)

                toggleEnabled.Name = "toggleEnabled"
                toggleEnabled.Parent = colorInners
                toggleEnabled.BackgroundTransparency = 1.000
                toggleEnabled.Position = UDim2.new(0.73, 0, 0.06, 0)
                toggleEnabled.Size = UDim2.new(0, 20, 0, 20)
                toggleEnabled.Image = "rbxassetid://3926309567"
                toggleEnabled.ImageColor3 = themeList.SchemeColor
                toggleEnabled.ImageRectOffset = Vector2.new(784, 420)
                toggleEnabled.ImageRectSize = Vector2.new(48, 48)
                toggleEnabled.ImageTransparency = 1.000

                onrainbow.Name = "onrainbow"
                onrainbow.Parent = toggleEnabled
                onrainbow.BackgroundTransparency = 1.000
                onrainbow.Size = UDim2.new(1, 0, 1, 0)
                onrainbow.Text = ""

                togName_2.Name = "togName"
                togName_2.Parent = colorInners
                togName_2.BackgroundTransparency = 1.000
                togName_2.Position = UDim2.new(0.8, 0, 0.1, 0)
                togName_2.Size = UDim2.new(0, 278, 0, 14)
                togName_2.Font = Enum.Font.Gotham
                togName_2.Text = "Rainbow"
                togName_2.TextColor3 = themeList.TextColor
                togName_2.TextSize = 13.000
                togName_2.TextXAlignment = Enum.TextXAlignment.Left

                local hovering = false
                colorElement.MouseEnter:Connect(function()
                    if not focusing then
                        Utility:TweenObject(colorHeader, {BackgroundColor3 = Color3.fromRGB(themeList.ElementColor.r * 255 + 10, themeList.ElementColor.g * 255 + 10, themeList.ElementColor.b * 255 + 10)}, 0.3)
                        hovering = true
                    end 
                end)
                colorElement.MouseLeave:Connect(function()
                    if not focusing then
                        Utility:TweenObject(colorHeader, {BackgroundColor3 = themeList.ElementColor}, 0.3)
                        hovering = false
                    end
                end)        

                updateSectionFrame()
                UpdateSize()
                local plr = game.Players.LocalPlayer
                local mouse = plr:GetMouse()
                local uis = game:GetService('UserInputService')
                local rs = game:GetService("RunService")
                local colorpicker = false
                local darknesss = false
                local dark = false
                local rgb = rgb    
                local dark = darkness    
                local cursor = rbgcircle
                local cursor2 = darkcircle
                local color = {1,1,1}
                local rainbow = false
                local rainbowconnection
                local counter = 0
                
                local function zigzag(X) return math.acos(math.cos(X*math.pi))/math.pi end
                counter = 0
                local function mouseLocation() return plr:GetMouse() end
                
                local function cp()
                    if colorpicker then
                        local ml = mouseLocation()
                        local x,y = ml.X - rgb.AbsolutePosition.X,ml.Y - rgb.AbsolutePosition.Y
                        local maxX,maxY = rgb.AbsoluteSize.X,rgb.AbsoluteSize.Y
                        if x<0 then x=0 end
                        if x>maxX then x=maxX end
                        if y<0 then y=0 end
                        if y>maxY then y=maxY end
                        x = x/maxX
                        y = y/maxY
                        local cx = cursor.AbsoluteSize.X/2
                        local cy = cursor.AbsoluteSize.Y/2
                        cursor.Position = UDim2.new(x,-cx,y,-cy)
                        color = {1-x,1-y,color[3]}
                        local realcolor = Color3.fromHSV(color[1],color[2],color[3])
                        colorCurrent.BackgroundColor3 = realcolor
                        callback(realcolor)
                    end
                    if darknesss then
                        local ml = mouseLocation()
                        local y = ml.Y - dark.AbsolutePosition.Y
                        local maxY = dark.AbsoluteSize.Y
                        if y<0 then y=0 end
                        if y>maxY then y=maxY end
                        y = y/maxY
                        local cy = cursor2.AbsoluteSize.Y/2
                        cursor2.Position = UDim2.new(0.5,0,y,-cy)
                        cursor2.ImageColor3 = Color3.fromHSV(0,0,y)
                        color = {color[1],color[2],1-y}
                        local realcolor = Color3.fromHSV(color[1],color[2],color[3])
                        colorCurrent.BackgroundColor3 = realcolor
                        callback(realcolor)
                    end
                end

                local function setcolor(tbl)
                    local cx = cursor.AbsoluteSize.X/2
                    local cy = cursor.AbsoluteSize.Y/2
                    color = {tbl[1],tbl[2],tbl[3]}
                    cursor.Position = UDim2.new(color[1],-cx,color[2]-1,-cy)
                    cursor2.Position = UDim2.new(0.5,0,color[3]-1,-cy)
                    local realcolor = Color3.fromHSV(color[1],color[2],color[3])
                    colorCurrent.BackgroundColor3 = realcolor
                end
                local function setrgbcolor(tbl)
                    local cx = cursor.AbsoluteSize.X/2
                    local cy = cursor.AbsoluteSize.Y/2
                    color = {tbl[1],tbl[2],color[3]}
                    cursor.Position = UDim2.new(color[1],-cx,color[2]-1,-cy)
                    local realcolor = Color3.fromHSV(color[1],color[2],color[3])
                    colorCurrent.BackgroundColor3 = realcolor
                    callback(realcolor)
                end
                local function togglerainbow()
                    if rainbow then
                        Utility:TweenObject(toggleEnabled, {ImageTransparency = 1}, 0.3)
                        rainbow = false
                        rainbowconnection:Disconnect()
                    else
                        Utility:TweenObject(toggleEnabled, {ImageTransparency = 0}, 0.3)
                        rainbow = true
                        rainbowconnection = rs.RenderStepped:Connect(function()
                            setrgbcolor({zigzag(counter),1,1})
                            counter = counter + 0.01
                        end)
                    end
                end

                onrainbow.MouseButton1Click:Connect(togglerainbow)
                mouse.Move:connect(cp)
                rgb.MouseButton1Down:connect(function()colorpicker=true end)
                dark.MouseButton1Down:connect(function()darknesss=true end)
                uis.InputEnded:Connect(function(input)
                    if input.UserInputType.Name == 'MouseButton1' then
                        if darknesss then darknesss = false end
                        if colorpicker then colorpicker = false end
                    end
                end)
                setcolor({h,s,v})
            end
            
            function Elements:NewLabel(title)
                local labelFunctions = {}
                local label = Instance.new("TextLabel")
                local UICorner = Instance.new("UICorner")
                label.Name = "label"
                label.Parent = sectionInners
                label.BackgroundColor3 = themeList.SchemeColor
                label.BackgroundTransparency = 0.8
                label.BorderSizePixel = 0
                label.ClipsDescendants = true
                label.Size = UDim2.new(0, 345, 0, 32)
                label.Font = Enum.Font.GothamSemibold
                label.Text = "  "..title
                label.RichText = true
                label.TextColor3 = themeList.SchemeColor
                label.TextSize = 13.000
                label.TextXAlignment = Enum.TextXAlignment.Left
                
                local labelStroke = Instance.new("UIStroke", label)
                labelStroke.Color = themeList.SchemeColor
                labelStroke.Transparency = 0.5
                labelStroke.Thickness = 1
                
                UICorner.CornerRadius = UDim.new(0, 6)
                UICorner.Parent = label

                updateSectionFrame()
                UpdateSize()
                function labelFunctions:UpdateLabel(newText)
                    if label.Text ~= "  "..newText then
                        label.Text = "  "..newText
                    end
                end 
                return labelFunctions
            end 
            return Elements
        end
        return Sections
    end  
    return Tabs
end
return Kavo
