local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function showAreaIntro(customText, displayDuration)
    displayDuration = displayDuration or 4.5 
    
    -- The DOORS off-white theme color
    local themeColor = Color3.fromRGB(245, 235, 214) 

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DoorsAreaIntro"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    -- ==========================================
    -- 🎧 CUSTOM AUDIO ROUTING SETUP
    -- ==========================================
    local effectGroup = Instance.new("SoundGroup")
    effectGroup.Name = "EnterAudioGroup"
    effectGroup.Parent = SoundService

    local equalizer = Instance.new("EqualizerSoundEffect")
    equalizer.Name = "EqualizerSoundEffect"
    equalizer.Enabled = true
    equalizer.HighGain = -44
    equalizer.LowGain = 1
    equalizer.MidGain = 10
    equalizer.Priority = 0
    equalizer.Parent = effectGroup 

    local reverb = Instance.new("ReverbSoundEffect")
    reverb.Name = "ReverbSoundEffect"
    reverb.Enabled = true
    reverb.DecayTime = 20
    reverb.Density = 1
    reverb.Diffusion = 1
    reverb.DryLevel = -6
    reverb.WetLevel = 0
    reverb.Priority = 0
    reverb.Parent = effectGroup

    local audioEnter = Instance.new("Sound")
    audioEnter.Name = "Audio_Enter"
    audioEnter.SoundId = "rbxassetid://126711047271197"
    audioEnter.PlaybackSpeed = 0.8
    audioEnter.SoundGroup = effectGroup 
    audioEnter.Parent = SoundService
    
    -- Audio Cleanup
    audioEnter.Ended:Connect(function()
        audioEnter:Destroy()
        effectGroup:Destroy() 
    end)
    -- ==========================================

    -- UI Container
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 700, 0, 160) 
    container.Position = UDim2.new(0.5, 0, 0.17, 0) 
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.BackgroundTransparency = 1
    container.Parent = screenGui

    -- Text Label
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 0.8, 0)
    textLabel.Position = UDim2.new(0, 0, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.FontFace = Font.new("rbxasset://fonts/families/Oswald.json", Enum.FontWeight.Regular)
    textLabel.Text = customText
    textLabel.TextColor3 = themeColor
    textLabel.TextScaled = true
    textLabel.TextTransparency = 1 
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.TextStrokeTransparency = 1 
    textLabel.Parent = container

    local sizeConstraint = Instance.new("UITextSizeConstraint")
    sizeConstraint.MaxTextSize = 120 
    sizeConstraint.Parent = textLabel

    -- The Growing Underline
    local underline = Instance.new("Frame")
    underline.Size = UDim2.new(0, 0, 0, 4) 
    underline.Position = UDim2.new(0.5, 0, 0.9, 0)
    underline.AnchorPoint = Vector2.new(0.5, 0)
    underline.BackgroundColor3 = themeColor
    underline.BorderSizePixel = 0
    underline.BackgroundTransparency = 1 
    underline.Parent = container

    -- Setup Animations
    local fadeTweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

    local textFadeIn = TweenService:Create(textLabel, fadeTweenInfo, {TextTransparency = 0, TextStrokeTransparency = 0.5})
    local lineFadeIn = TweenService:Create(underline, fadeTweenInfo, {BackgroundTransparency = 0})
    local lineSizeIn = TweenService:Create(underline, fadeTweenInfo, {Size = UDim2.new(0.6, 0, 0, 4)}) 

    local textFadeOut = TweenService:Create(textLabel, fadeTweenInfo, {TextTransparency = 1, TextStrokeTransparency = 1})
    local lineFadeOut = TweenService:Create(underline, fadeTweenInfo, {BackgroundTransparency = 1})
    local lineSizeOut = TweenService:Create(underline, fadeTweenInfo, {Size = UDim2.new(0, 0, 0, 4)}) 

    -- Pre-load the sound so the animations sync perfectly
    if not audioEnter.IsLoaded then
        audioEnter.Loaded:Wait()
    end
    
    -- The critical engine wait you added
    task.wait()

    -- 🎬 Execute the Sequence!
    audioEnter:Play() 
    textFadeIn:Play()
    lineFadeIn:Play()
    lineSizeIn:Play() 

    -- Wait for the duration
    task.wait(displayDuration)

    -- Melt away
    textFadeOut:Play()
    lineFadeOut:Play()
    lineSizeOut:Play() 

    textFadeOut.Completed:Wait()
    screenGui:Destroy()
end

-- Trigger it with your requested text!
showAreaIntro("The Dark Depths")
