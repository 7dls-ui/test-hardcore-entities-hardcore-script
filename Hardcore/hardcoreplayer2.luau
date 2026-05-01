print(os.date("%B")) print("Loading Hardcore Mode with True Sound FX Engine and Dynamic Lighting...")
local tween,ReplicatedStorage,Players,Workspace,RS,UIS,PathfindingService=game:GetService("TweenService"),game:GetService("ReplicatedStorage"),game:GetService("Players"),game:GetService("Workspace"),game:GetService("RunService"),game:GetService("UserInputService"),game:GetService("PathfindingService")
if ReplicatedStorage:FindFirstChild("Extacuted") then warn("You have Already Loaded") return false end
local Test=Instance.new("Part") Test.Name="Extacuted" Test.Parent=ReplicatedStorage
pcall(function() if not ReplicatedStorage:FindFirstChild("RemotesFolder") then local fR=Instance.new("Folder") fR.Name="RemotesFolder" fR.Parent=ReplicatedStorage local fH=Instance.new("RemoteEvent") fH.Name="DeathHint" fH.Parent=fR end end)
getgenv().ActiveCustomEntities=0 getgenv().CustomGodMode=false
RS.RenderStepped:Connect(function() if getgenv().ActiveCustomEntities>0 then local s=Workspace.CurrentCamera:FindFirstChild("Screech") if s then s:Destroy() end end end)

-- ==========================================
-- || HARDCORE INTRO SEQUENCE              ||
-- ==========================================
task.spawn(function()
    task.wait(3) -- Wait 3 seconds after execution
    
    pcall(function()
        local PG = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        local caption = PG:WaitForChild("MainUI"):WaitForChild("MainFrame"):WaitForChild("Caption")
        local TS = game:GetService("TweenService")
        
        local function displayHardcoreMessage(msg)
            caption.Text = msg
            caption.TextTransparency = 0
            caption.Visible = true
            
            task.wait(1) -- Stay solid for 1 second
            local fadeOut = TS:Create(caption, TweenInfo.new(1), {TextTransparency = 1})
            fadeOut:Play()
            task.wait(1) -- Wait 1 second for the fade out to finish (Total 2 seconds)
        end
        
        displayHardcoreMessage("Hardcore Mode initiated.")
        displayHardcoreMessage("Created by sabnoober12")
        displayHardcoreMessage("Have Fun! (You Won't)")
    end)
end)

-- ==========================================
-- || HARDCORE VISUALS & LIGHTING OVERRIDE ||
-- ==========================================

task.spawn(function()
    local RunService = game:GetService("RunService")
    local CurrentRooms = workspace:WaitForChild("CurrentRooms")
    
    -- 1. PRE-LOAD THE MODELS & AUDIO ONCE
    local customLightId = "rbxassetid://12258314281" 
    local customShatteredId = "rbxassetid://112708908978754" 
    
    -- PUT YOUR CUSTOM FLICKERING AUDIO ID HERE:
    local customFlickerAudioId = "rbxassetid://4288784832" 
    
    local customLightTemplate = nil
    local customShatteredTemplate = nil
    
    pcall(function()
        -- Load Intact Model
        local s1, r1 = pcall(function() return game:GetObjects(customLightId)[1] end)
        if s1 and r1 then
            customLightTemplate = r1
            for _, d in ipairs(customLightTemplate:GetDescendants()) do
                if d:IsA("Light") then d:Destroy() end
                if d:IsA("BasePart") then d.Anchored = true; d.CanCollide = false end
            end
        else
            warn("[Hardcore Engine] Failed to load Intact Light: " .. tostring(r1))
        end
        
        -- Load Shattered Model
        local s2, r2 = pcall(function() return game:GetObjects(customShatteredId)[1] end)
        if s2 and r2 then
            customShatteredTemplate = r2
            for _, d in ipairs(customShatteredTemplate:GetDescendants()) do
                if d:IsA("Light") then d:Destroy() end
                if d:IsA("BasePart") then d.Anchored = true; d.CanCollide = false end
            end
        else
            warn("[Hardcore Engine] Failed to load Shattered Light! Check if ID is public: " .. tostring(r2))
        end
    end)

    local rotationOffset = CFrame.Angles(0, 0, 0)
    local TrackedLights = {}

    -- Helper to cache all visible parts to avoid ghosting
    local function GetVisualParts(model)
        local cache = {}
        for _, child in ipairs(model:GetDescendants()) do
            if child:IsA("BasePart") or child:IsA("Decal") or child:IsA("Texture") or child:IsA("SurfaceAppearance") then
                cache[child] = child.Transparency
            end
        end
        return cache
    end

    -- 2. THE DYNAMIC ROOM CORRUPTOR
    local function CorruptRoom(room)
        task.wait(0.5) -- Give the room extra time to fully load before tracking
        
        for _, obj in ipairs(room:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "LightStand" then
                local oldFixture = obj:FindFirstChild("LightFixture")
                
                if oldFixture and customLightTemplate then
                    
                    -- Find ALL lights in this DOORS fixture
                    local allLights = {}
                    for _, l in ipairs(oldFixture:GetDescendants()) do
                        if l:IsA("PointLight") or l:IsA("SpotLight") or l:IsA("SurfaceLight") then
                            table.insert(allLights, l)
                        end
                    end

                    local originalParts = GetVisualParts(oldFixture)
                    
                    -- Clone custom intact model and overlay it
                    local newLightShell = customLightTemplate:Clone()
                    newLightShell:PivotTo(oldFixture:GetPivot() * rotationOffset)
                    newLightShell.Parent = obj
                    
                    local customParts = GetVisualParts(newLightShell)

                    -- Add to our continuous monitor list
                    table.insert(TrackedLights, {
                        OriginalModel = obj,
                        OriginalFixture = oldFixture,
                        OriginalParts = originalParts,
                        CustomShell = newLightShell,
                        CustomParts = customParts,
                        AllLights = allLights,
                        CurrentState = "Unknown",
                        FlickerSound = nil -- Tracking the audio object
                    })
                end
            end
        end
    end

    -- Sweep the rooms that are already loaded when script executes
    for _, room in ipairs(CurrentRooms:GetChildren()) do
        CorruptRoom(room)
    end
    
    -- Hook into the event for new rooms
    CurrentRooms.ChildAdded:Connect(CorruptRoom)

    -- 3. THE HEARTBEAT MONITOR (100% Bulletproof State Detection)
    RunService.Heartbeat:Connect(function()
        for i = #TrackedLights, 1, -1 do
            local data = TrackedLights[i]
            
            -- Cleanup if the room was despawned behind the player
            if not data.OriginalModel or not data.OriginalModel.Parent then
                if data.FlickerSound then data.FlickerSound:Destroy() end
                table.remove(TrackedLights, i)
                continue
            end

            -- CHECK 1: SHATTER DETECTION
            -- DOORS actively assigns this attribute when an entity breaks the light
            local isShattered = data.OriginalModel:GetAttribute("Shattered") == true
            
            if isShattered then
                -- Kill the flicker sound immediately
                if data.FlickerSound then 
                    data.FlickerSound:Destroy() 
                    data.FlickerSound = nil
                end

                -- Hide original DOORS parts permanently
                for part, _ in pairs(data.OriginalParts) do
                    if part and part.Parent then part.Transparency = 1 end
                end
                
                -- Destroy the intact custom shell
                if data.CustomShell and data.CustomShell.Parent then
                    data.CustomShell:Destroy()
                end
                
                -- Spawn the CUSTOM SHATTERED shell exactly where the old one was
                if customShatteredTemplate and data.OriginalFixture then
                    local brokenShell = customShatteredTemplate:Clone()
                    brokenShell:PivotTo(data.OriginalFixture:GetPivot() * rotationOffset)
                    brokenShell.Parent = data.OriginalModel
                end
                
                -- Remove from tracking list because it's officially dead
                table.remove(TrackedLights, i)
                continue
            end

            -- CHECK 2: FLICKER DETECTION
            -- Loop through ALL lights in the fixture. If EVERY single one is off/dim, it's flickering.
            local isFlickering = true
            local hasLights = false
            
            for _, light in ipairs(data.AllLights) do
                if light and light.Parent then
                    hasLights = true
                    if light.Enabled and light.Brightness > 0.1 then
                        isFlickering = false -- Found an active, bright light!
                        break
                    end
                end
            end
            
            if not hasLights then isFlickering = true end
            
            local targetState = isFlickering and "Flicker" or "Normal"
            
            -- Execute Visibility Swap & Audio if the state changed
            if data.CurrentState ~= targetState then
                data.CurrentState = targetState
                
                if targetState == "Normal" then
                    -- Kill audio if returning to normal
                    if data.FlickerSound then 
                        data.FlickerSound:Destroy() 
                        data.FlickerSound = nil
                    end

                    -- NORMAL: Hide original DOORS light, Show Custom Shell
                    for part, _ in pairs(data.OriginalParts) do
                        if part and part.Parent then part.Transparency = 1 end
                    end
                    for part, origTrans in pairs(data.CustomParts) do
                        if part and part.Parent then part.Transparency = origTrans end
                    end
                elseif targetState == "Flicker" then
                    -- FLICKERING: Show original DOORS light, Hide Custom Shell
                    for part, origTrans in pairs(data.OriginalParts) do
                        if part and part.Parent then part.Transparency = origTrans end
                    end
                    for part, _ in pairs(data.CustomParts) do
                        if part and part.Parent then part.Transparency = 1 end
                    end

                    -- Play custom flicker audio natively on the light
                    if not data.FlickerSound and customFlickerAudioId ~= "rbxassetid://YOUR_AUDIO_ID_HERE" then
                        local snd = Instance.new("Sound")
                        snd.Name = "CustomFlickerSFX"
                        snd.SoundId = customFlickerAudioId
                        snd.Volume = 1.5 
                        snd.Looped = true
                        snd.RollOffMaxDistance = 75 -- How far away you can hear it
                        snd.RollOffMinDistance = 10
                        snd.RollOffMode = Enum.RollOffMode.InverseTapered
                        snd.Parent = data.OriginalFixture -- Attach it to the fixture so it's 3D!
                        snd:Play()
                        data.FlickerSound = snd
                    end
                end
            end
        end
    end)
end)

-- UNIVERSAL SAFE ROOM CHECK (Moved to top so all entities can see it)
local function IsSafeRoom(roomNum)
    if not roomNum then return false end
    local rStr = tostring(roomNum)
    
    if rStr == "49" or rStr == "50" or rStr == "51" or rStr == "100" then return true end
    
    local rm = Workspace.CurrentRooms:FindFirstChild(rStr)
    if rm then
        local n = string.lower(rm.Name)
        if n:find("seek") or n:find("chase") or n:find("library") or n:find("figure") then return true end
        
        for _, child in ipairs(rm:GetChildren()) do
            local cn = string.lower(child.Name)
            if cn:find("seek") or cn:find("chase") or cn:find("library") or cn:find("figure") then return true end
        end
        
        if rm:GetAttribute("IsSeekChase") or rm:GetAttribute("RawName") == "SeekChase" then return true end
    end
    return false
end

task.spawn(function()
    local s_sprint, err_sprint = xpcall(function()
        local runService,character=game:GetService("RunService"),game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait() local humanoid=character:WaitForChild("Humanoid")
        local SB=Instance.new("ScreenGui") SB.Name="StaminaBar" SB.Parent=game.Players.LocalPlayer:WaitForChild("PlayerGui") SB.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
        local Bo=Instance.new("Frame") Bo.Name="Border" Bo.Parent=SB Bo.AnchorPoint=Vector2.new(0,1) Bo.BackgroundColor3,Bo.BorderColor3=Color3.fromRGB(0,0,0),Color3.fromRGB(0,0,0) Bo.BackgroundTransparency=0.7 Bo.BorderSizePixel=4 Bo.Position,Bo.Size=UDim2.new(0.83,0,0.95,0),UDim2.new(0.15,0,0.0263,0)
        Instance.new("UICorner",Bo).CornerRadius=UDim.new(0.25,0)
        local Ba=Instance.new("Frame") Ba.Name="Bar" Ba.Parent=Bo Ba.AnchorPoint=Vector2.new(0,1) Ba.BackgroundColor3=Color3.fromRGB(213,185,158) Ba.BorderSizePixel=0 Ba.Position,Ba.Size=UDim2.new(0,0,1,0),UDim2.new(1,0,1,0)
        Instance.new("UICorner",Ba).CornerRadius=UDim.new(0.25,0)
        local UP=Instance.new("UIPadding",Bo) UP.PaddingBottom,UP.PaddingLeft,UP.PaddingRight,UP.PaddingTop=UDim.new(0,4),UDim.new(0,4),UDim.new(0,4),UDim.new(0,4)
        local Si=Instance.new("Frame") Si.Name="SideBar" Si.Parent=SB Si.AnchorPoint=Vector2.new(0,1) Si.BackgroundColor3,Si.BorderColor3=Color3.fromRGB(0,0,0),Color3.fromRGB(0,0,0) Si.BackgroundTransparency=0.7 Si.BorderSizePixel=4 Si.Position,Si.Size=UDim2.new(0.985,0,1,0),UDim2.new(0.014,0,0.174,0)
        Instance.new("UICorner",Si).CornerRadius=UDim.new(0.25,0)
        local UP2=Instance.new("UIPadding",Si) UP2.PaddingBottom,UP2.PaddingLeft,UP2.PaddingRight,UP2.PaddingTop=UDim.new(0,4),UDim.new(0,4),UDim.new(0,4),UDim.new(0,4)
        local B2=Instance.new("Frame") B2.Name="Bar" B2.Parent=Si B2.AnchorPoint=Vector2.new(0,1) B2.BackgroundColor3=Color3.fromRGB(213,185,158) B2.BorderSizePixel=0 B2.Position,B2.Size=UDim2.new(0,0,1,0),UDim2.new(1,0,1,0)
        Instance.new("UICorner",B2).CornerRadius=UDim.new(0.25,0)
        local Started,OO=false,0 local sO=Instance.new('LocalScript',SB) local B=Instance.new('NumberValue',sO.Parent) B.Name="Dissapear"
        sO.Parent.Dissapear.Changed:Connect(function(V) for _,v in pairs(sO:GetChildren()) do v:Destroy() end local A=Instance.new("Part",sO) A.Name="Keep"..tick()..game.JobId..game.Players.LocalPlayer.Name Bo.Visible,Si.Visible=true,false task.wait(1) if sO:FindFirstChild(A.Name) then OO=0 repeat task.wait(1) OO=OO+1 until V>OO or not sO:FindFirstChild(A.Name) if sO:FindFirstChild(A.Name) then Bo.Visible=true end end end)
        local TS,cam=game:GetService("TweenService"),workspace.CurrentCamera local TI_In,TI_Out=TweenInfo.new(0.4,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),TweenInfo.new(1.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
        local BF,SF=TS:Create(cam,TI_In,{FieldOfView=100}),TS:Create(cam,TI_Out,{FieldOfView=70})
        local sP,sT,rT,spr,DEF=100,100/(7*60),100/(20*60),false,15 local W2=DEF
        local function sprint(_,IS) if IS==Enum.UserInputState.Begin then if spr==false then DEF=humanoid.WalkSpeed end sO.Parent.Dissapear.Value=9e99 W2=DEF+10 humanoid.WalkSpeed=W2 spr=true while sP>0 and spr do if Started~=true then sO.Parent.Dissapear.Value=9e99 BF:Play() Started=true end Ba.Size,B2.Size=UDim2.new(sP/100,0,1,0),UDim2.new(1,0,sP/100,0) Ba.Visible,B2.Visible=true,true sP=sP-sT task.wait() if sP<=0 then Ba.Visible=false W2=DEF humanoid.WalkSpeed=W2 SF:Play() Started=false local PG=game.Players.LocalPlayer.PlayerGui local TC=TS:Create(PG.MainUI.MainFrame.Caption,TweenInfo.new(1),{TextTransparency=1}) PG.MainUI.MainFrame.Caption.Text="You're exhausted." PG.MainUI.MainFrame.Caption.TextTransparency=0 PG.MainUI.MainFrame.Caption.Visible=true task.wait(1) TC:Play() sO.Parent.Dissapear.Value=10 sP=0 end end elseif IS==Enum.UserInputState.End then Ba.Visible=true W2=DEF humanoid.WalkSpeed=W2 spr=false while sP<=100 and spr==false do sP=math.min(100,sP+rT) Ba.Size,B2.Size=UDim2.new(sP/100,0,1,0),UDim2.new(1,0,sP/100,0) if Started~=false then Started=false SF:Play() sO.Parent.Dissapear.Value=10 end task.wait() end end end
        character.Changed:Connect(function() if humanoid.WalkSpeed~=W2 and humanoid.WalkSpeed~=10 then DEF=humanoid.WalkSpeed if spr then W2=DEF+10 humanoid.WalkSpeed=W2 end end end)
        runService.RenderStepped:Connect(function() local ct=tick() if Started and humanoid.MoveDirection.Magnitude>0 then humanoid.CameraOffset=humanoid.CameraOffset:lerp(Vector3.new(math.abs(math.sin(ct*10))*.05,math.abs(math.sin(ct*10))*.35,0),.75) elseif Started then humanoid.CameraOffset=humanoid.CameraOffset*0 end end)
        local CAS=game:GetService("ContextActionService") CAS:BindAction("Sprint",sprint,true,Enum.KeyCode.LeftShift,Enum.KeyCode.RightShift) CAS:SetPosition("Sprint",UDim2.new(5,0,0,0)) CAS:SetTitle("Sprint","Shift") humanoid.Died:Connect(function() SB:Destroy() end)
    end, function(e) return debug.traceback(e) end)
end)

getgenv().death=false local function BDT(c) c:WaitForChild("Humanoid").Died:Connect(function() getgenv().death=true end) end if Players.LocalPlayer.Character then BDT(Players.LocalPlayer.Character) end Players.LocalPlayer.CharacterAdded:Connect(BDT)

local function IPS(c,eM, iH)
    if not iH and c:GetAttribute("Hiding")==true then return true end
    local hd=c:FindFirstChild("Head") local rt=eM:IsA("Model") and (eM.PrimaryPart or eM:FindFirstChildWhichIsA("BasePart",true)) or eM
    if not hd or not rt then return false end
    local cp,ep=hd.Position,rt.Position local vec=ep-cp local dist=vec.Magnitude
    if dist<2 then return false end 
    local dir=vec.Unit*(dist-2) 
    local il={c,eM,Workspace.CurrentCamera}
    for _,p in ipairs(Players:GetPlayers()) do if p.Character then table.insert(il,p.Character) end end
    local rp=RaycastParams.new() rp.FilterType,rp.IgnoreWater=Enum.RaycastFilterType.Exclude,true
    for i=1,7 do
        rp.FilterDescendantsInstances=il local res=Workspace:Raycast(cp,dir,rp)
        if not res then return false end 
        local inst=res.Instance local n,pn=string.lower(inst.Name),inst.Parent and string.lower(inst.Parent.Name) or ""
        if n:find("door") or pn:find("door") or inst.Transparency>=0.8 or not inst.CanCollide or n:find("glass") or pn:find("glass") then table.insert(il,inst) else return true end
    end
    return false
end

local function ASK(eM,kR,dH,aC,rM,iH)
    local cn cn=RS.Heartbeat:Connect(function()
        if getgenv().death or not eM.Parent then if cn then cn:Disconnect() end return end
        local c=Players.LocalPlayer.Character if c and c:FindFirstChild("Head") and c:FindFirstChild("Humanoid") then
            local h=c.Humanoid if h.Health>0 then
                local rt=eM:IsA("Model") and (eM.PrimaryPart or eM:FindFirstChildWhichIsA("BasePart",true)) or eM
                if (c.Head.Position-rt.Position).Magnitude<=kR and (not rM or h.MoveDirection.Magnitude>0) and not getgenv().CustomGodMode then
                    if not IPS(c,eM,iH) then
                        getgenv().death=true if cn then cn:Disconnect() end if aC then pcall(aC) end
                        pcall(function() local f,sv,gi,to,gg,nx=nil,debug.setupvalue or setupvalue,debug.getinfo or getinfo,typeof,getgc,next for _,v in nx,gg(false) do if typeof(v)=="function" then local i=gi(v) if i.currentline==54 and i.nups==2 and i.is_vararg==0 then f=v break end end end sv(f,1,dH);sv(f,2,"Blue") firesignal(ReplicatedStorage.Bricks.DeathHint.OnClientEvent,dH,"Blue") end)
                        h.Health=0
                    end
                end
            end
        end
    end)
end

task.spawn(function()
    local s_ui, err_ui = xpcall(function()
        local L=loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))() local W=L.CreateLib("Hardcore Spawner","Midnight") 
        local function cW(f) if typeof(f)=="function" then coroutine.wrap(f)() else warn("[Hardcore Mode] Function not found.") end end
        
        local HT=W:NewTab("Hardcore Entities") local HS=HT:NewSection("Manual Presets") 
        HS:NewButton("Spawn Depth","Spawns Depth",function() cW(getgenv().SpawnEntity_Depth) end)
        HS:NewButton("Spawn Blitz","Spawns Blitz",function() cW(getgenv().SpawnEntity_Blitz) end)
        HS:NewButton("Spawn Ripper","Spawns Ripper",function() cW(getgenv().SpawnEntity_Ripper) end)
        HS:NewButton("Spawn Rebound","Spawns Rebound",function() cW(getgenv().SpawnEntity_Rebound) end)
        HS:NewButton("Spawn Frostbite","Spawns Frostbite",function() cW(getgenv().SpawnEntity_Frostbite) end)
        HS:NewButton("Spawn Deer God","Spawns Deer God",function() cW(getgenv().SpawnEntity_DeerGod) end)
        HS:NewButton("Spawn A-200","Spawns A-200",function() cW(getgenv().SpawnEntity_A200) end)
        HS:NewButton("Spawn Trollface","Spawns Trollface",function() cW(getgenv().SpawnEntity_Trollface) end)
        HS:NewButton("Spawn A-60","Spawns A-60",function() cW(getgenv().SpawnEntity_A60) end)
        HS:NewButton("Spawn Silence","Spawns Silence",function() cW(getgenv().SpawnEntity_Silence) end)
        HS:NewButton("Spawn Cease","Spawns Cease",function() cW(getgenv().SpawnEntity_Cease) end)
        HS:NewButton("Revive","Revives you",function() pcall(function() getgenv().death=false game.ReplicatedStorage.Bricks.Revive:FireServer() end) end)
        HS:NewToggle("God-Mode","Grants immunity.",function(s) getgenv().CustomGodMode=s end)

        local NET=W:NewTab("Normal Entities") local NES=NET:NewSection("Manual Presets")
        NES:NewButton("Spawn Ambush", "Spawns Ambush", function() cW(getgenv().SpawnEntity_Ambush) end)

        local SHT=W:NewTab("SUPER HARD MODE") local SHS=SHT:NewSection("Super Hard Presets")
        SHS:NewButton("Spawn scary red face","Spawns scary red face",function() cW(getgenv().SpawnEntity_ScaryRedFace1) end)
        SHS:NewButton("Spawn Scary Red Face","Spawns Scary Red Face",function() cW(getgenv().SpawnEntity_ScaryRedFace2) end)
        SHS:NewButton("Spawn Nacho Varga","Spawns Nacho Varga",function() cW(getgenv().SpawnEntity_NachoVarga) end)
        SHS:NewButton("Spawn DEPTH","Spawns DEPTH",function() cW(getgenv().SpawnEntity_DEPTH_SHM) end)
        SHS:NewButton("Spawn Bald Kreek","Spawns Bald Kreek",function() cW(getgenv().SpawnEntity_BaldKreek) end)
        SHS:NewButton("Spawn rahh!!!","Spawns rahh!!!",function() cW(getgenv()["SpawnEntity_rahh!!!"]) end)
        SHS:NewButton("Spawn FREE ROBLOXIAN","Spawns FREE ROBLOXIAN",function() cW(getgenv()["SpawnEntity_FREE ROBLOXIAN OUTFIT"]) end)

        local ST=W:NewTab("Settings") local SS=ST:NewSection("UI Settings") SS:NewKeybind("Toggle UI Key","Press [",Enum.KeyCode.LeftBracket,function() L:ToggleUI() end)
        RS.RenderStepped:Connect(function() local gh=(getgenv and getgenv().gethui) or nil local cg=gh and gh() or game:GetService("CoreGui") local kU=cg:FindFirstChild("Hardcore Spawner") or Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Hardcore Spawner") if kU and kU:FindFirstChild("Main") and kU.Main.Visible then UIS.MouseIconEnabled,UIS.MouseBehavior=true,Enum.MouseBehavior.Default end end)
    end, function(e) return debug.traceback(e) end)
end)

local spawner=nil task.spawn(function()
    local mU=Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainUI",999999) if not mU then return end
    local s_eng, err_eng = xpcall(function()
        spawner=(function()
            (function() local M={} M.LoadCustomAsset=function(u) if getcustomasset then if u:lower():sub(1,4)=="http" then local f=`temp_{tick()}.txt` local _,r=pcall(function() writefile(f,game:HttpGet(u)) return getcustomasset(f,true) end) if isfile(f) then delfile(f) end return r elseif isfile(u) then return getcustomasset(u,true) end end if u:find("rbxassetid") or tonumber(u) then return "rbxassetid://"..u:match("%d+") end return nil end M.LoadCustomInstance=function(u) local s,r=pcall(function() return game:GetObjects(M.LoadCustomAsset(u))[1] end) return s and r or nil end for n,f in next,M do if typeof(f)=="function" then getgenv()[n]=f end end end)()
            local Rm,CR=ReplicatedStorage:WaitForChild("RemotesFolder"),workspace:WaitForChild("CurrentRooms")
            local mE,mG,mQ 
            pcall(function() mE=require((ReplicatedStorage:FindFirstChild("ClientModules") or ReplicatedStorage:FindFirstChild("ModulesClient")):WaitForChild("Module_Events",3)) end)
            pcall(function() mG=require(Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game) end)
            pcall(function() mQ=require(Rm.RequestAsset:InvokeServer("Earthquake")) end)
            
            local Mods={Module_Events=mE,Main_Game=mG,Earthquake=mQ} local CT={BASE_ENTITY_SPEED=65,ATTR={ENTITY={Running=false,Paused=false,Despawning=false,LastEnteredRoom=-1}}} local M={ActiveEntities={}}
            local function cT(t) local n={} for k,v in next,t do n[k]=typeof(v)=="table" and cT(v) or v end return n end
            local function GCR(l) return l and CR:GetChildren()[#CR:GetChildren()] or CR:FindFirstChild(Players.LocalPlayer:GetAttribute("CurrentRoom")) end
            
            local function GetSortedRooms() local r,vR=CR:GetChildren(),{} for _,v in ipairs(r) do if tonumber(v.Name) then table.insert(vR,v) end end table.sort(vR,function(a,b) return tonumber(a.Name)<tonumber(b.Name) end) return vR end
            
            -- UPGRADED BULLETPROOF GRAP FUNCTION
            local function GRAP(v) 
                local rp = RaycastParams.new()
                rp.FilterType = Enum.RaycastFilterType.Include
                rp.FilterDescendantsInstances = CR:GetChildren()
                local res = workspace:Raycast(v, Vector3.new(0, -100, 0), rp)
                if res then
                    local obj = res.Instance
                    while obj and obj.Parent and obj.Parent ~= CR do
                        obj = obj.Parent
                    end
                    if obj and obj.Parent == CR then return obj end
                end
                return nil
            end
            
            local function FRL(rm) local re=rm:FindFirstChild("RoomEntrance") if not re then return end if Mods.Module_Events then pcall(function() Mods.Module_Events.toggle(rm,true,{}) end) end local rd=Random.new(tick()) for _,v in next,rm:GetDescendants() do if v:IsA("Model") and (v.Name=="LightStand" or v.Name=="Chandelier") and v:GetAttribute("Shattered") then task.delay((re.Position-v.PrimaryPart.Position).Magnitude/150+rd:NextInteger(-10,10)/50,function() local r2=rd:NextInteger(5,20)/100 local nn=v:FindFirstChild("Neon",true) for _,d in next,v:GetDescendants() do if d:IsA("Light") then tween:Create(d,TweenInfo.new(r2),{Brightness=d:GetAttribute("OGBrightness")}):Play() elseif d:IsA("Sound") then tween:Create(d,TweenInfo.new(r2),{Volume=d:GetAttribute("OGVolume")}):Play() end end if nn then nn.Transparency=0.9 nn.Material=Enum.Material.Neon tween:Create(nn,TweenInfo.new(r2),{Transparency=0.2}):Play() end v:SetAttribute("Shattered",nil) end) end end end
            
            local function PreCalculatePath(sp, ep)
                local dD={} for _,o in pairs(workspace:GetDescendants()) do if o:IsA("BasePart") and (o.Name:lower():match("door") or o.Name:lower():match("gate") or o.Name:lower():match("hidden")) then if o.CanCollide then o.CanCollide=false table.insert(dD,o) end end end
                local p=PathfindingService:CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=false,WaypointSpacing=3}) local s=pcall(function() p:ComputeAsync(sp,ep) end)
                for _,o in ipairs(dD) do o.CanCollide=true end local wps={} if s and p.Status==Enum.PathStatus.Success then for _,wp in ipairs(p:GetWaypoints()) do table.insert(wps,CFrame.new(wp.Position)) end else table.insert(wps,CFrame.new(sp)) table.insert(wps,CFrame.new(ep)) end return wps
            end

            local function GPA_PreCalc(cf)
                local rms=GetSortedRooms() if #rms==0 then return {} end local mW,lRV,eI={},ReplicatedStorage.GameData.LatestRoom.Value,1
                for i,r in ipairs(rms) do eI=i if tonumber(r.Name)==lRV then break end end
                if cf.Movement.Reversed then for i=eI,1,-1 do local rx,re=rms[i]:FindFirstChild("RoomExit") or rms[i]:FindFirstChild("RoomEntrance"),rms[i]:FindFirstChild("RoomEntrance") or rms[i]:FindFirstChild("RoomExit") if rx and re then for _,w in ipairs(PreCalculatePath(rx.Position,re.Position)) do table.insert(mW,w) end end end else for i=1,eI do local re,rx=rms[i]:FindFirstChild("RoomEntrance") or rms[i]:FindFirstChild("RoomExit"),rms[i]:FindFirstChild("RoomExit") or rms[i]:FindFirstChild("RoomEntrance") if re and rx then for _,w in ipairs(PreCalculatePath(re.Position,rx.Position)) do table.insert(mW,w) end end end end return mW
            end

            local function EMT_PreCalc(m, wps, sp, ho, nho)
                local rW=false for _,wC in ipairs(wps) do local tP=wC.Position+Vector3.new(0,4.5+(ho or 0),0) local nR,cn=false,nil
                    cn=RS.Stepped:Connect(function(_,step) if not m.Parent then cn:Disconnect() rW=true return end if not m:GetAttribute("Paused") then local cP,diff=m:GetPivot().Position,tP-m:GetPivot().Position
                            if diff.Magnitude>1.5 then local nP=cP+(diff.Unit*(step*sp)) local fL=Vector3.new(diff.Unit.X,0,diff.Unit.Z) m:PivotTo(fL.Magnitude>0.001 and CFrame.new(nP,nP+fL) or CFrame.new(nP)) else cn:Disconnect() nR=true end end end)
                    repeat RS.Stepped:Wait() until nR or rW if rW then break end end
            end

            M.Create=function(s,cf) 
                local nc=cT(cf) nc.Movement.Speed=CT.BASE_ENTITY_SPEED/100*cf.Movement.Speed local i
                if nc.Entity.Is2D then i=Instance.new("Model") i.Name=nc.Entity.Name or "2DEntity" local r=Instance.new("Part",i) r.Name="Main" r.Size=Vector3.new(2,5,2) r.Transparency=1 r.CanCollide=false r.Anchored=true i.PrimaryPart=r local b=Instance.new("BillboardGui",r) b.Name="Sprite" b.Size=UDim2.new(8,0,8,0) b.AlwaysOnTop=true b.LightInfluence=0 b.MaxDistance=3000 b.Adornee=r local img=Instance.new("ImageLabel",b) img.Size=UDim2.new(1,0,1,0) img.BackgroundTransparency=1 img.ScaleType=Enum.ScaleType.Fit local ast=tostring(nc.Entity.Asset) if tonumber(ast) then ast="rbxassetid://"..ast end img.Image=ast
                else local suc,res=pcall(function() return LoadCustomInstance(nc.Entity.Asset) end) i=suc and res or nil end
                local rt=(i and i:IsA("Model") and i.PrimaryPart) or (i and i:FindFirstChildWhichIsA("BasePart",true)) or (i and i:IsA("BasePart") and i)
                if not rt then return nil end if not i:IsA("Model") then local wrp=Instance.new("Model") i.Parent=wrp i=wrp end
                for _,v in next,i:GetDescendants() do if v:IsA("BasePart") then v.CanCollide=false v.Anchored=true end end 
                rt.Anchored=true i.PrimaryPart=rt i.Name=nc.Entity.Name or i.Name for a,v in next,CT.ATTR.ENTITY do i:SetAttribute(a,v) end local c=Instance.new("Configuration",i) c.Name="RoomsEntered" 
                
                return {Model=i,Config=nc,Debug=cf.Debug or {},SetCallback=function(ss,k,cb) ss.Debug[k]=cb end,RunCallback=function(ss,k,...) if typeof(ss.Debug[k])=="function" then pcall(ss.Debug[k],...) end end,IsAlive=function(ss) return ss.Model and not ss.Model:GetAttribute("FullyDespawned") end,Run=function(ss,cE) M:Run(ss,cE) end,Despawn=function(ss) if ss:IsAlive() then ss.Model:SetAttribute("FullyDespawned", true) ss.Model:Destroy() local id=table.find(M.ActiveEntities,ss) if id then table.remove(M.ActiveEntities,id) end task.spawn(ss.RunCallback,ss,"OnDespawned") end end} 
            end
            
            M.Run=function(s,e,c) 
                if c then s:Run(cT(e),false) return end if e.Model:GetAttribute("Running") then return end 
                local m,cf=e.Model,e.Config m:SetAttribute("Running",true) s.ActiveEntities[#s.ActiveEntities+1]=e 
                local r=GetSortedRooms() local sp=cf.Movement.Reversed and r[#r]:FindFirstChild("RoomExit") or r[1]:FindFirstChild("RoomEntrance") 
                local rt = m:FindFirstChild("Main") or (m:IsA("Model") and m.PrimaryPart) or m:FindFirstChildWhichIsA("BasePart", true) or (m:IsA("BasePart") and m)
                local globalSounds, despawnConfigs = {}, {}
                
                if cf.Sounds and next(cf.Sounds) ~= nil then
                    for _,o in ipairs(m:GetDescendants()) do if o:IsA("Sound") then o:Destroy() end end
                    if rt then
                        for sN, sD in pairs(cf.Sounds) do
                            local isDespawn = sD.PlayOnDespawn or sN:lower():find("despawn") or sN:lower():find("end")
                            if isDespawn then table.insert(despawnConfigs, {Name = sN, Config = sD})
                            else
                                local snd = Instance.new("Sound") snd.Name = sN snd.SoundId = sD.SoundId snd.PlaybackSpeed = sD.PlaybackSpeed or 1 snd.RollOffMinDistance = sD.RollOffMinDistance or 10 snd.RollOffMaxDistance = sD.RollOffMaxDistance or 1500 snd.RollOffMode = Enum.RollOffMode.InverseTapered snd.Looped = sD.Looped if snd.Looped == nil then snd.Looped = true end snd.Volume = 0
                                if sD.Global then snd.Parent = workspace table.insert(globalSounds, snd) else snd.Parent = rt end
                                if sD.Effects then for fN, fP in pairs(sD.Effects) do local scc, fx = pcall(function() return Instance.new(fP.ClassName) end) if scc and fx then fx.Name = fN for k, v in pairs(fP) do if k ~= "ClassName" then pcall(function() fx[k] = v end) end end fx.Enabled = true fx.Parent = snd end end end
                                snd:Play() if not snd.Looped then snd.Ended:Connect(function() snd:Destroy() end) end tween:Create(snd, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Volume = sD.Volume or 1}):Play()
                            end
                        end
                    end
                else
                    if cf.Entity.UntouchedAudio then
                        for _,o in ipairs(m:GetDescendants()) do 
                            if o:IsA("Sound") and o.Playing then 
                                local tv = o.Volume o.Volume = 0 tween:Create(o,TweenInfo.new(2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Volume=tv}):Play() 
                            end 
                        end
                    else
                        for _,o in ipairs(m:GetDescendants()) do 
                            if o:IsA("Sound") then 
                                if not o.Parent:IsA("BasePart") and rt then o.Parent = rt end
                                local n = o.Name:lower()
                                if n:find("start") or n:find("end") or n:find("arrival") or n:find("despawn") or n:find("scream") or n:find("switch") then
                                    o.Playing = false o.Volume = 0 o:Stop()
                                else
                                    if o.RollOffMode ~= Enum.RollOffMode.InverseTapered then
                                        if n == "farsound" then o.RollOffMinDistance = 10; o.RollOffMaxDistance = 1500; o.RollOffMode = Enum.RollOffMode.InverseTapered elseif n == "nearsound" then o.RollOffMinDistance = 5; o.RollOffMaxDistance = 75; o.RollOffMode = Enum.RollOffMode.InverseTapered else o.RollOffMinDistance = 10; o.RollOffMaxDistance = 1000; o.RollOffMode = Enum.RollOffMode.InverseTapered end
                                    end
                                    local tv = o.Volume if tv <= 0.01 then tv = 1.5 end o.Volume = 0 if not o.IsPlaying then o:Play() end tween:Create(o,TweenInfo.new(2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Volume=tv}):Play() 
                                end
                            end 
                        end
                    end
                end

                if cf.Movement.Speed > 0 then m:PivotTo(sp.CFrame+Vector3.new(0,cf.Entity.HeightOffset,0)) end
                m.Parent=workspace 
                task.spawn(e.RunCallback,e,"OnSpawned") 
                local cR=GCR(false) if cR then if cf.Lights.Flicker.Enabled and Mods.Module_Events then pcall(function() Mods.Module_Events.flicker(cR,cf.Lights.Flicker.Duration) end) end if cf.Earthquake.Enabled and Mods.Earthquake then task.defer(Mods.Earthquake,Mods.Main_Game,cR) end end 
                task.wait(cf.Movement.Delay) task.spawn(e.RunCallback,e,"OnStartMoving")

                if cf.Movement.Speed > 0 then
                    task.spawn(function() 
                        while e:IsAlive() and task.wait() do 
                            if not m.Parent or m:GetAttribute("Paused") then continue end 
                            local o,co=m:GetPivot().Position,Players.LocalPlayer.Character.PrimaryPart.Position 
                            local rm=GRAP(o) 
                            if rm then 
                                local id=tonumber(rm.Name) 
                                if id and id>=0 and id~=m:GetAttribute("LastEnteredRoom") then 
                                    m:SetAttribute("LastEnteredRoom",id) 
                                    local re=m:FindFirstChild("RoomsEntered") 
                                    if re then 
                                        local ft=re:GetAttribute(rm.Name)==nil task.spawn(e.RunCallback,e,"OnEnterRoom",rm,ft) 
                                        if ft then re:SetAttribute(rm.Name,true) end 
                                        local lR = ReplicatedStorage.GameData.LatestRoom.Value 
                                        if cf.Lights.Shatter and Mods.Module_Events and id<=lR then 
                                            pcall(function() Mods.Module_Events.shatter(rm) end)
                                        elseif cf.Lights.Repair and id<=lR then 
                                            pcall(function() FRL(rm) end)
                                        end 
                                    end 
                                end 
                            end 
                            local cs=cf.CameraShake 
                            if cs.Enabled and Mods.Main_Game.camShaker then 
                                local mg=(co-o).Magnitude if mg<=cs.Range then Mods.Main_Game.camShaker:ShakeOnce(cs.Values[1]/cs.Range*(cs.Range-mg),cs.Values[2]/cs.Range*(cs.Range-mg),cs.Values[3],cs.Values[4]) end 
                            end 
                        end 
                    end)
                    
                    task.spawn(function()
                        local rtType=cf.Rebounding.Type:upper()
                        
                        local delayVal = 0
                        if cf.Entity.ReboundDelay then
                            if type(cf.Entity.ReboundDelay) == "number" then delayVal = cf.Entity.ReboundDelay
                            elseif type(cf.Entity.ReboundDelay) == "table" then delayVal = math.random((cf.Entity.ReboundDelay.Min or 0)*10, (cf.Entity.ReboundDelay.Max or 0)*10)/10 end
                        end

                        if rtType=="AMBUSH" or rtType=="LEGACY AMBUSH" then
                            local pathfindNodes = GPA_PreCalc(cf) EMT_PreCalc(m, pathfindNodes, cf.Movement.Speed, cf.Entity.HeightOffset, cf.Entity.NavMeshHeightOffset)
                            if cf.Rebounding.Enabled then local reboundsCount = math.random(cf.Rebounding.Min, cf.Rebounding.Max) for i = 1, reboundsCount do task.wait(cf.Rebounding.Delay) m:SetAttribute("Damage", true) task.spawn(e.RunCallback, e, "OnRebounding", true) local backwardNodes = {} for j = #pathfindNodes, 1, -1 do table.insert(backwardNodes, pathfindNodes[j]) end EMT_PreCalc(m, backwardNodes, cf.Movement.Speed, cf.Entity.HeightOffset, cf.Entity.NavMeshHeightOffset) task.spawn(e.RunCallback, e, "OnRebounding", false) task.wait(cf.Rebounding.Delay) m:SetAttribute("Damage", true) task.spawn(e.RunCallback, e, "OnRebounding", true) pathfindNodes = GPA_PreCalc(cf) EMT_PreCalc(m, pathfindNodes, cf.Movement.Speed, cf.Entity.HeightOffset, cf.Entity.NavMeshHeightOffset) task.spawn(e.RunCallback, e, "OnRebounding", false) if i < reboundsCount then task.wait(cf.Rebounding.Delay) end end end
                        
                        elseif rtType=="BLITZ" then
                            local pathfindNodes = GPA_PreCalc(cf) 
                            local pRoomVal = Players.LocalPlayer:GetAttribute("CurrentRoom")
                            if not pRoomVal or pRoomVal < 1 then pRoomVal = ReplicatedStorage.GameData.LatestRoom.Value end
                            local pRoomStr = tostring(pRoomVal)
                            
                            local nodesToCurrent, nodesToEnd, roomNodes = {}, {}, {} 
                            local passedCurrent = false
                            for _, wp in ipairs(pathfindNodes) do 
                                local checkRoom = GRAP(wp.Position) 
                                if checkRoom and checkRoom.Name == pRoomStr then 
                                    table.insert(nodesToCurrent, wp) 
                                    table.insert(roomNodes, wp) 
                                    passedCurrent = true 
                                elseif not passedCurrent then 
                                    table.insert(nodesToCurrent, wp) 
                                else 
                                    table.insert(nodesToEnd, wp) 
                                end 
                            end
                            
                            if #roomNodes <= 1 and #pathfindNodes > 1 then
                                roomNodes = {}
                                for i = math.max(1, #pathfindNodes - 15), #pathfindNodes do
                                    table.insert(roomNodes, pathfindNodes[i])
                                end
                            end

                            EMT_PreCalc(m, nodesToCurrent, cf.Movement.Speed, cf.Entity.HeightOffset, cf.Entity.NavMeshHeightOffset)
                            
                            if cf.Rebounding.Enabled and #roomNodes > 1 then 
                                local rc = math.random(cf.Rebounding.Min, cf.Rebounding.Max) 
                                local randIdx = 1 
                                if not cf.Movement.Reversed then 
                                    randIdx = math.random(1, math.max(1, #roomNodes - 1)) 
                                else 
                                    randIdx = math.random(math.min(2, #roomNodes), #roomNodes) 
                                end 
                                for _ = 1, rc do 
                                    m:SetAttribute("Damage", true) 
                                    task.spawn(e.RunCallback, e, "OnRebounding", true) 
                                    local backWp = {} 
                                    for i = #roomNodes, randIdx, -1 do table.insert(backWp, roomNodes[i]) end 
                                    EMT_PreCalc(m, backWp, cf.Movement.Speed, cf.Entity.HeightOffset, cf.Entity.NavMeshHeightOffset) 
                                    task.wait(cf.Rebounding.Delay) 
                                    m:SetAttribute("Damage", true) 
                                    task.spawn(e.RunCallback, e, "OnRebounding", false) 
                                    local fwdWp = {} 
                                    for i = randIdx, #roomNodes do table.insert(fwdWp, roomNodes[i]) end 
                                    EMT_PreCalc(m, fwdWp, cf.Movement.Speed, cf.Entity.HeightOffset, cf.Entity.NavMeshHeightOffset) 
                                end 
                            end
                            
                            local fullPathAgain = GPA_PreCalc(cf) 
                            local updatedToEnd = {} 
                            local foundCurrentAgain = false 
                            for _, wp in ipairs(fullPathAgain) do 
                                local checkRoom = GRAP(wp.Position) 
                                if checkRoom and checkRoom.Name == pRoomStr then 
                                    foundCurrentAgain = true 
                                elseif foundCurrentAgain and (not checkRoom or checkRoom.Name ~= pRoomStr) then 
                                    table.insert(updatedToEnd, wp) 
                                end 
                            end
                            
                            if #updatedToEnd > 0 then EMT_PreCalc(m, updatedToEnd, cf.Movement.Speed, cf.Entity.HeightOffset, cf.Entity.NavMeshHeightOffset) 
                            elseif #nodesToEnd > 0 then EMT_PreCalc(m, nodesToEnd, cf.Movement.Speed, cf.Entity.HeightOffset, cf.Entity.NavMeshHeightOffset) 
                            else
                                local fbk = {}
                                for i = math.min(#pathfindNodes, #nodesToCurrent + 1), #pathfindNodes do
                                    table.insert(fbk, pathfindNodes[i])
                                end
                                if #fbk > 0 then EMT_PreCalc(m, fbk, cf.Movement.Speed, cf.Entity.HeightOffset, cf.Entity.NavMeshHeightOffset) end
                            end
                            
                        elseif rtType=="REBOUND" then
                            local pathfindNodes = GPA_PreCalc(cf)
                            EMT_PreCalc(m, pathfindNodes, cf.Movement.Speed, cf.Entity.HeightOffset, cf.Entity.NavMeshHeightOffset)
                            
                            if cf.Rebounding.Enabled then
                                local targetLaps = math.random(cf.Rebounding.Min, cf.Rebounding.Max)
                                local currentLap = 1
                                
                                m:SetAttribute("Paused", true)
                                local cP=m:GetPivot() local dD=cP.LookVector.Unit 
                                local cv cv=RS.Stepped:Connect(function(_,stp) if m.Parent then m:PivotTo(m:GetPivot()+(dD*(cf.Movement.Speed*stp))) else cv:Disconnect() end end)
                                task.wait(1.5) if cv then cv:Disconnect() end
                                m.Parent = nil 
                                
                                while currentLap < targetLaps do
                                    local startRoom = game.ReplicatedStorage.GameData.LatestRoom.Value
                                    repeat task.wait(0.1) until game.ReplicatedStorage.GameData.LatestRoom.Value > startRoom or getgenv().death
                                    if getgenv().death then break end
                                    
                                    if IsSafeRoom(game.ReplicatedStorage.GameData.LatestRoom.Value) then break end
                                    
                                    currentLap = currentLap + 1
                                    
                                    if delayVal > 0 then 
                                        task.wait(delayVal) 
                                    else 
                                        task.wait(cf.Rebounding.Delay) 
                                    end 
                                    
                                    local nRms = GetSortedRooms()
                                    local nSp = nRms[#nRms]:FindFirstChild("RoomExit") 
                                    if nSp then
                                        m:PivotTo(nSp.CFrame + Vector3.new(0,cf.Entity.HeightOffset,0))
                                        m.Parent = workspace
                                        m:SetAttribute("Paused", false)
                                        
                                        task.spawn(e.RunCallback, e, "OnRebounding", true)
                                        
                                        local newPath = GPA_PreCalc(cf)
                                        EMT_PreCalc(m, newPath, cf.Movement.Speed, cf.Entity.HeightOffset, cf.Entity.NavMeshHeightOffset)
                                        
                                        m:SetAttribute("Paused", true)
                                        local nCP=m:GetPivot() local nDD=nCP.LookVector.Unit 
                                        local nCV nCV=RS.Stepped:Connect(function(_,stp) if m.Parent then m:PivotTo(m:GetPivot()+(nDD*(cf.Movement.Speed*stp))) else nCV:Disconnect() end end)
                                        task.wait(1.5) if nCV then nCV:Disconnect() end
                                        m.Parent = nil
                                    end
                                end
                            else
                                m:SetAttribute("Paused", true)
                                local cP=m:GetPivot() local dD=cP.LookVector.Unit 
                                local cv cv=RS.Stepped:Connect(function(_,stp) if m.Parent then m:PivotTo(m:GetPivot()+(dD*(cf.Movement.Speed*stp))) else cv:Disconnect() end end)
                                task.wait(1.5) if cv then cv:Disconnect() end
                                m.Parent = nil 
                            end
                        end
                        
                        if cf.Entity.RipperDelay and rtType ~= "REBOUND" then
                            local rDelay = 0
                            if type(cf.Entity.RipperDelay) == "number" then
                                rDelay = cf.Entity.RipperDelay
                            elseif type(cf.Entity.RipperDelay) == "table" then
                                rDelay = math.random((cf.Entity.RipperDelay.Min or 0) * 10, (cf.Entity.RipperDelay.Max or 0) * 10) / 10
                            end
                            if rDelay > 0 then
                                task.wait(rDelay)
                            end
                        end
                        
                        if not m:GetAttribute("Despawning") then
                            m:SetAttribute("Despawning",true) task.spawn(e.RunCallback,e,"OnDespawning")
                            for _, dC in ipairs(despawnConfigs) do local sD = dC.Config local snd = Instance.new("Sound") snd.Name = dC.Name snd.SoundId = sD.SoundId snd.Volume = sD.Volume or 1 snd.PlaybackSpeed = sD.PlaybackSpeed or 1 snd.RollOffMinDistance = sD.RollOffMinDistance or 10 snd.RollOffMaxDistance = sD.RollOffMaxDistance or 1500 snd.RollOffMode = Enum.RollOffMode.InverseTapered snd.Looped = sD.Looped or false
                                if sD.Global then snd.Parent = workspace else local soundPart = Instance.new("Part") soundPart.Transparency = 1; soundPart.CanCollide = false; soundPart.Anchored = true soundPart.Position = m:GetPivot().Position; soundPart.Parent = workspace snd.Parent = soundPart game.Debris:AddItem(soundPart, 10) end
                                if sD.Effects then for fN, fP in pairs(sD.Effects) do local success, fx = pcall(function() return Instance.new(fP.ClassName) end) if success and fx then fx.Name = fN for k, v in pairs(fP) do if k ~= "ClassName" then pcall(function() fx[k] = v end) end end fx.Enabled = true fx.Parent = snd end end end snd:Play() if not snd.Looped then snd.Ended:Connect(function() snd:Destroy() end) end
                            end
                            for _,v in next,m:GetDescendants() do if v:IsA("BasePart") then v.CanCollide=false end end
                            for _,o in ipairs(m:GetDescendants()) do if o:IsA("Sound") then tween:Create(o,TweenInfo.new(2.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{Volume=0}):Play() end end
                            for _,o in ipairs(globalSounds) do tween:Create(o,TweenInfo.new(2.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{Volume=0}):Play() task.delay(2.5, function() o:Destroy() end) end
                            
                            if rtType ~= "REBOUND" then
                                local cP=m:GetPivot() local dD=(cP.LookVector-Vector3.new(0,0.3,0)).Unit local c c=RS.Stepped:Connect(function(_,stp) if m.Parent then m:PivotTo(m:GetPivot()+(dD*(cf.Movement.Speed*stp))) else c:Disconnect() end end)
                                task.wait(2.5) if c then c:Disconnect() end 
                            end
                            e:Despawn()
                        end
                    end)
                end
            end
            getgenv().VynixuEntitySpawnerV2=M return M
        end)()
    end, function(e) return debug.traceback(e) end)
end)

local function SE_Ambush() if not spawner then return end local s,err=xpcall(function() local e=spawner:Create({Entity={Name="Ambush",Asset="77471049714310",HeightOffset=0,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=1.5},Sounds={FarSound={SoundId="rbxassetid://80435851839067",Volume=10,PlaybackSpeed=1,RollOffMinDistance=10,RollOffMaxDistance=500,Looped=true},NearSound={SoundId="rbxassetid://80435851839067",Volume=10,PlaybackSpeed=1.10,RollOffMinDistance=5,RollOffMaxDistance=75,Looped=true},ArrivalSound={SoundId="rbxassetid://134020218579308",Volume=3,PlaybackSpeed=1,Looped=false,Global=true}},Lights={Flicker={Enabled=true,Duration=1},Shatter=true,Repair=false},Earthquake={Enabled=false},CameraShake={Enabled=true,Range=100,Values={3,60,0.1,1}},Movement={Speed=120,Delay=5,Reversed=false},Rebounding={Enabled=true,Type="Legacy Ambush",Min=2,Max=5,Delay=0.5},Debug={}}) if not e then return end e:SetCallback("OnSpawned",function() ASK(e.Model,40,{"You died to Ambush.","It comes back!","Hide when the lights flicker!"},nil,false) end) e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) spawner:Run(e,false) end,function(er) return debug.traceback(er) end) end getgenv().SpawnEntity_Ambush=SE_Ambush

local function SE_A60() if not spawner then return end local s,err=xpcall(function() local e=spawner:Create({Entity={Name="A-60",Asset="https://github.com/7dls-ui/test-hardcore-entities-hardcore-script/raw/refs/heads/main/Hardcore/A60Moving.rbxm",HeightOffset=1,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=1.5,UntouchedAudio=true},Sounds={},Lights={Flicker={Enabled=true,Duration=1},Shatter=true,Repair=false},Earthquake={Enabled=false},CameraShake={Enabled=true,Range=150,Values={6,60,0.1,1}},Movement={Speed=200,Delay=4,Reversed=false},Rebounding={Enabled=true,Type="Legacy Ambush",Min=2,Max=4,Delay=2},Debug={}}) if not e then return end e:SetCallback("OnSpawned",function() ASK(e.Model,120,{"You died to A-60.","It is incredibly fast!","Hide when the lights flicker!"},nil,false) end) e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) spawner:Run(e,false) end,function(er) return debug.traceback(er) end) end getgenv().SpawnEntity_A60=SE_A60

local function SE_A200() if not spawner then return end local s,err=xpcall(function() local e=spawner:Create({Entity={Name="A-200",Asset="https://github.com/7dls-ui/test-hardcore-entities-hardcore-script/raw/refs/heads/main/Hardcore/A200Moving3.rbxm",HeightOffset=1.5,CanOpenDoors=false,NavMeshHeightOffset=1.5,UntouchedAudio=true},Lights={Flicker={Enabled=true,Duration=1.5},Shatter=true},Earthquake={Enabled=false},CameraShake={Enabled=true,Range=100,Values={1.5,20,0.1,1}},Movement={Speed=40,Delay=7,Reversed=true},Rebounding={Enabled=true,Type="Blitz",Min=0,Max=2,Delay=0.5}}) if not e then return end e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,40,{"You died to A-200.","Spawns ahead and travels backwards.","Hide quickly!"},nil,false) end end) end) e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) spawner:Run(e,false) end, function(er) return debug.traceback(er) end) end getgenv().SpawnEntity_A200=SE_A200

local function SE_FreeRobloxianOutfit() if not spawner then return end local s,err=xpcall(function() local e=spawner:Create({Entity={Name="FREE ROBLOXIAN OUTFIT",Asset="rbxassetid://103662059684022",HeightOffset=0,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=1.5},Sounds={FarSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.2,RollOffMinDistance=10,RollOffMaxDistance=1000,Looped=true},NearSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.75,RollOffMinDistance=5,RollOffMaxDistance=75,Looped=true}},Lights={Flicker={Enabled=true,Duration=1},Shatter=true,Repair=false},Earthquake={Enabled=false},CameraShake={Enabled=true,Range=100,Values={1,40,0.1,1}},Movement={Speed=80,Delay=1.5,Reversed=false},Rebounding={Enabled=false,Type="Ambush",Min=1,Max=1,Delay=2},Debug={}}) if not e then return end e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,40,{"You died to FREE ROBLOXIAN OUTFIT.","Hide when the lights flicker!"},nil,false) end end) end) e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) spawner:Run(e,false) end, function(er) return debug.traceback(er) end) end getgenv()["SpawnEntity_FREE ROBLOXIAN OUTFIT"]=SE_FreeRobloxianOutfit

local function SE_rahh() if not spawner then return end local s,err=xpcall(function() local e=spawner:Create({Entity={Name="rahh!!!",Asset="rbxassetid://123875017551067",HeightOffset=0,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=1.5},Sounds={FarSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.2,RollOffMinDistance=10,RollOffMaxDistance=1000,Looped=true},NearSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.75,RollOffMinDistance=5,RollOffMaxDistance=75,Looped=true}},Lights={Flicker={Enabled=true,Duration=1},Shatter=true,Repair=false},Earthquake={Enabled=false},CameraShake={Enabled=true,Range=100,Values={1,40,0.1,1}},Movement={Speed=80,Delay=1.5,Reversed=false},Rebounding={Enabled=false,Type="Ambush",Min=1,Max=1,Delay=2},Debug={}}) if not e then return end e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,40,{"You died to rahh!!!.","Hide when the lights flicker!"},nil,false) end end) end) e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) spawner:Run(e,false) end, function(er) return debug.traceback(er) end) end getgenv()["SpawnEntity_rahh!!!"]=SE_rahh

local function SE_BaldKreek() if not spawner then return end local s,err=xpcall(function() local e=spawner:Create({Entity={Name="Bald Kreek",Asset="rbxassetid://93078046721158",HeightOffset=0,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=1.5},Sounds={FarSound={SoundId="rbxassetid://1845307009",Volume=1.5,PlaybackSpeed=0.2,RollOffMinDistance=10,RollOffMaxDistance=1000,Looped=true},NearSound={SoundId="rbxassetid://1845307009",Volume=1.5,PlaybackSpeed=0.4,RollOffMinDistance=5,RollOffMaxDistance=75,Looped=true}},Lights={Flicker={Enabled=true,Duration=1},Shatter=true,Repair=false},Earthquake={Enabled=false},CameraShake={Enabled=true,Range=100,Values={1,40,0.1,1}},Movement={Speed=80,Delay=1.5,Reversed=false},Rebounding={Enabled=false,Type="Ambush",Min=1,Max=1,Delay=2},Debug={}}) if not e then return end e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,40,{"You died to Bald Kreek.","Hide when the lights flicker!"},nil,false) end end) end) e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) spawner:Run(e,false) end, function(er) return debug.traceback(er) end) end getgenv().SpawnEntity_BaldKreek=SE_BaldKreek

local function SE_NachoVarga() if not spawner then return end local s,err=xpcall(function() local e=spawner:Create({Entity={Name="Nacho Varga",Asset="rbxassetid://122425276040196",HeightOffset=0,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=1.5},Sounds={FarSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.2,RollOffMinDistance=10,RollOffMaxDistance=1000,Looped=true},NearSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.75,RollOffMinDistance=5,RollOffMaxDistance=75,Looped=true}},Lights={Flicker={Enabled=true,Duration=1},Shatter=true,Repair=false},Earthquake={Enabled=false},CameraShake={Enabled=true,Range=100,Values={1,40,0.1,1}},Movement={Speed=80,Delay=1.5,Reversed=false},Rebounding={Enabled=false,Type="Ambush",Min=1,Max=1,Delay=2},Debug={}}) if not e then return end e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,40,{"You died to Nacho Varga.","Hide when the lights flicker!"},nil,false) end end) end) e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) spawner:Run(e,false) end, function(er) return debug.traceback(er) end) end getgenv().SpawnEntity_NachoVarga=SE_NachoVarga

local function SE_ScaryRedFace1() if not spawner then return end local s,err=xpcall(function() local e=spawner:Create({Entity={Name="scary red face",Asset="rbxassetid://12987999444",HeightOffset=0,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=1.5},Sounds={FarSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.2,RollOffMinDistance=10,RollOffMaxDistance=1000,Looped=true},NearSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.75,RollOffMinDistance=5,RollOffMaxDistance=75,Looped=true}},Lights={Flicker={Enabled=true,Duration=1.5},Shatter=true,Repair=false},Earthquake={Enabled=false},CameraShake={Enabled=true,Range=100,Values={1,30,0.1,1}},Movement={Speed=80,Delay=1.5,Reversed=false},Rebounding={Enabled=false,Type="Ambush",Min=1,Max=1,Delay=2},Debug={}}) if not e then return end e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,40,{"You died to the scary red face.","It approaches at a moderate speed.","Hide when the lights flicker!"},nil,false) end end) end) e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) spawner:Run(e,false) end, function(er) return debug.traceback(er) end) end getgenv().SpawnEntity_ScaryRedFace1=SE_ScaryRedFace1

local function SE_ScaryRedFace2() if not spawner then return end local s,err=xpcall(function() local e=spawner:Create({Entity={Name="Scary Red Face",Asset="rbxassetid://83896895946876",HeightOffset=0,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=1.5},Sounds={FarSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.2,RollOffMinDistance=10,RollOffMaxDistance=1000,Looped=true},NearSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.75,RollOffMinDistance=5,RollOffMaxDistance=75,Looped=true}},Lights={Flicker={Enabled=true,Duration=1.5},Shatter=true,Repair=false},Earthquake={Enabled=false},CameraShake={Enabled=true,Range=100,Values={1,30,0.1,1}},Movement={Speed=80,Delay=1.5,Reversed=false},Rebounding={Enabled=false,Type="Ambush",Min=1,Max=1,Delay=2},Debug={}}) if not e then return end e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,40,{"You died to the Scary Red Face.","It approaches at a moderate speed.","Hide when the lights flicker!"},nil,false) end end) end) e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) spawner:Run(e,false) end, function(er) return debug.traceback(er) end) end getgenv().SpawnEntity_ScaryRedFace2=SE_ScaryRedFace2

local function SE_DEPTH_SHM() if not spawner then return end local s,err=xpcall(function() local e=spawner:Create({Entity={Name="DEPTH",Asset="rbxassetid://84780317335866",HeightOffset=0,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=1.5},Sounds={FarSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.75,RollOffMinDistance=10,RollOffMaxDistance=1000,Looped=true},NearSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=1,RollOffMinDistance=5,RollOffMaxDistance=75,Looped=true}},Lights={Flicker={Enabled=true,Duration=1},Shatter=true,Repair=false},Earthquake={Enabled=false},CameraShake={Enabled=true,Range=100,Values={1,40,0.1,1}},Movement={Speed=80,Delay=1.5,Reversed=false},Rebounding={Enabled=false,Type="Ambush",Min=1,Max=1,Delay=2},Debug={}}) if not e then return end e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,40,{"You died to DEPTH.","Hide when the lights flicker!"},nil,false) end end) end) e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) spawner:Run(e,false) end, function(er) return debug.traceback(er) end) end getgenv().SpawnEntity_DEPTH_SHM=SE_DEPTH_SHM

local function SE_Trollface() if not spawner then return end local s,err=xpcall(function() local e=spawner:Create({Entity={Name="Trollface",Asset="rbxassetid://17687252419",HeightOffset=1,NavMeshHeightOffset=1.5},Sounds={FarSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.2,RollOffMinDistance=10,RollOffMaxDistance=1500,Looped=true},NearSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.75,RollOffMinDistance=5,RollOffMaxDistance=300,Looped=true}},Lights={Flicker={Enabled=false,Duration=1},Shatter=true},Earthquake={Enabled=false},CameraShake={Enabled=true,Range=100,Values={2,25,0.1,1}},Movement={Speed=200,Delay=5,Reversed=false},Rebounding={Enabled=false,Type="Ambush",Min=1,Max=1,Delay=2}}) if not e then return end e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,40,{"Problem?","You just got trolled.","He is incredibly fast."},nil,false) end end) end) e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) spawner:Run(e,false) end, function(er) return debug.traceback(er) end) end getgenv().SpawnEntity_Trollface=SE_Trollface

local function SE_DeerGod()
    if not spawner then warn("[Hardcore] Spawner missing for Deer God!") return end
    local s, err = xpcall(function()
        local e = spawner:Create({
            Entity = {Name = "Deer God", Asset = "https://github.com/7dls-ui/test-hardcore-entities-hardcore-script/raw/refs/heads/main/Hardcore/DeerGodMoving2.rbxm", HeightOffset = 0, CanOpenDoors = false, Is2D = false, NavMeshHeightOffset = 1.5, UntouchedAudio = true},
            Sounds = {},
            Lights = {Flicker = {Enabled = true, Duration = 5}, Shatter = true, Repair = false}, 
            Earthquake = {Enabled = false}, 
            CameraShake = {Enabled = true, Range = 100, Values = {2, 30, 0.1, 1}},
            Movement = {Speed = 25, Delay = 6, Reversed = false},
            Rebounding = {Enabled = false, Type = "Ambush", Min = 1, Max = 1, Delay = 2}, 
            Debug = {}
        })
        if not e then return end

        e:SetCallback("OnSpawned", function()
            pcall(function()
                local m = e.Model 
                if m then 
                    ASK(m, 150, {"You died to the Deer God.", "It ignores hiding spots.", "Break line of sight to survive!"}, nil, false, true) 
                end
            end)
        end)

        e:SetCallback("OnDespawned", function()
            getgenv().ActiveCustomEntities = math.max(0, getgenv().ActiveCustomEntities - 1)
        end)
        spawner:Run(e, false)
    end, function(er) return debug.traceback(er) end)
end
getgenv().SpawnEntity_DeerGod = SE_DeerGod

local activeReboundSounds = {Arrival = nil, Scream = nil}
local function SE_Rebound()
    if not spawner then warn("[Hardcore] Spawner missing for Rebound!") return end
    local s,err=xpcall(function()
        local e=spawner:Create({
            Entity = {Name="Rebound",Asset="111463924328072",HeightOffset=0,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=1.5,ReboundDelay=4},
            Sounds = {
                FarSound = {SoundId = "rbxassetid://116456025793787", Volume = 7.5, PlaybackSpeed = 1, RollOffMinDistance = 10, RollOffMaxDistance = 75, Looped = true},
                NearSound = {SoundId = "rbxassetid://116456025793787", Volume = 5, PlaybackSpeed = 1, RollOffMinDistance = 5, RollOffMaxDistance = 20, Looped = true}
            },
            Lights = {Flicker={Enabled=true,Duration=3},Shatter=true,Repair=false}, Earthquake = {Enabled=true}, CameraShake = {Enabled=true,Range=100,Values={2, 50, 0.1, 1}},
            Movement = {Speed=70,Delay=3,Reversed=true},
            Rebounding = {Enabled=true,Type="Rebound",Min=3,Max=5,Delay=1}, Debug = {}
        })
        if not e then return end

        e:SetCallback("OnSpawned",function()
            pcall(function()
                local m=e.Model if m then ASK(m,75,{"You died to Rebound.","He attacks from the front every time you open a door.","Pay attention to the blue tint!"},nil,false) end
                local c=Instance.new("ColorCorrectionEffect") c.Name="Warn" c.TintColor=Color3.fromRGB(65, 138, 255) c.Saturation=-0.7 c.Contrast=0.2 c.Parent=game:GetService("Lighting") game.Debris:AddItem(c,24)
                game:GetService("TweenService"):Create(c,TweenInfo.new(15),{TintColor = Color3.fromRGB(255, 255, 255),Saturation = 0, Contrast = 0}):Play()
                local mainCC = game.Lighting:FindFirstChild("MainColorCorrection") if mainCC then game:GetService("TweenService"):Create(mainCC, TweenInfo.new(5),{TintColor = Color3.fromRGB(255, 255, 255)}):Play() end

                activeReboundSounds.Arrival = Instance.new("Sound", workspace) 
                activeReboundSounds.Arrival.SoundId = "rbxassetid://9114221327" 
                activeReboundSounds.Arrival.Volume = 3 
                activeReboundSounds.Arrival:Play() 

                activeReboundSounds.Scream = Instance.new("Sound", workspace) 
                activeReboundSounds.Scream.SoundId = "rbxassetid://9114397505" 
                activeReboundSounds.Scream.Volume = 0.1
                local p1 = Instance.new("PitchShiftSoundEffect", activeReboundSounds.Scream) p1.Octave = 0.5
                local p2 = Instance.new("PitchShiftSoundEffect", activeReboundSounds.Scream) p2.Octave = 0.5
                local p3 = Instance.new("PitchShiftSoundEffect", activeReboundSounds.Scream) p3.Octave = 0.5
                local d1 = Instance.new("DistortionSoundEffect", activeReboundSounds.Scream) d1.Level = 1
                local d2 = Instance.new("DistortionSoundEffect", activeReboundSounds.Scream) d2.Level = 1
                activeReboundSounds.Scream:Play() 
            end)
        end)

        e:SetCallback("OnRebounding", function(start)
            pcall(function()
                if start then
                    local m = e.Model
                    if m then ASK(m, 75, {"You died to Rebound.","He attacks from the front every time you open a door.","Pay attention to the blue tint!"}, nil, false) end
                    
                    local mg = require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game)
                    if mg and mg.camShaker then mg.camShaker:ShakeOnce(2, 50, 0.1, 1) end

                    if activeReboundSounds.Arrival then activeReboundSounds.Arrival:Stop() activeReboundSounds.Arrival:Destroy() activeReboundSounds.Arrival = nil end
                    if activeReboundSounds.Scream then activeReboundSounds.Scream:Stop() activeReboundSounds.Scream:Destroy() activeReboundSounds.Scream = nil end

                    activeReboundSounds.Arrival = Instance.new("Sound", workspace) 
                    activeReboundSounds.Arrival.SoundId = "rbxassetid://9043335396" 
                    activeReboundSounds.Arrival.Volume = 3 
                    activeReboundSounds.Arrival.PlaybackSpeed = 0.8 
                    activeReboundSounds.Arrival:Play() 

                    activeReboundSounds.Scream = Instance.new("Sound", workspace) 
                    activeReboundSounds.Scream.SoundId = "rbxassetid://9114397505" 
                    activeReboundSounds.Scream.Volume = 0.1
                    local p1 = Instance.new("PitchShiftSoundEffect", activeReboundSounds.Scream) p1.Octave = 0.5
                    local p2 = Instance.new("PitchShiftSoundEffect", activeReboundSounds.Scream) p2.Octave = 0.5
                    local p3 = Instance.new("PitchShiftSoundEffect", activeReboundSounds.Scream) p3.Octave = 0.5
                    local d1 = Instance.new("DistortionSoundEffect", activeReboundSounds.Scream) d1.Level = 1
                    local d2 = Instance.new("DistortionSoundEffect", activeReboundSounds.Scream) d2.Level = 1
                    activeReboundSounds.Scream:Play() 

                    if m then
                        for _, snd in ipairs(m:GetDescendants()) do
                            if snd:IsA("Sound") then
                                local n = snd.Name:lower()
                                if n == "nearsound" or n == "farsound" then
                                    local targetVol = snd:GetAttribute("OrigVol") or 1.5
                                    snd.Volume = 0
                                    if not snd.IsPlaying then snd:Play() end
                                    game:GetService("TweenService"):Create(snd, TweenInfo.new(1), {Volume = targetVol}):Play()
                                end
                            end
                        end
                    end
                end
            end)
        end)

        e:SetCallback("OnDespawning", function()
            if activeReboundSounds.Arrival then activeReboundSounds.Arrival:Stop() activeReboundSounds.Arrival:Destroy() activeReboundSounds.Arrival = nil end
            if activeReboundSounds.Scream then activeReboundSounds.Scream:Stop() activeReboundSounds.Scream:Destroy() activeReboundSounds.Scream = nil end
        end)

        e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end)
        spawner:Run(e,false)
    end, function(er) return debug.traceback(er) end)
end
getgenv().SpawnEntity_Rebound=SE_Rebound

local function SE_Ripper()
    if not spawner then warn("[Hardcore] Spawner missing for Ripper!") return end
    local s,err=xpcall(function()
        local e=spawner:Create({
            Entity = {Name="Ripper",Asset="https://github.com/7dls-ui/test-hardcore-entities-hardcore-script/raw/refs/heads/main/Hardcore/RipperMoving2.rbxm",HeightOffset=3,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=1.5,UntouchedAudio=true,RipperDelay={Min=1,Max=3}},
            Sounds = {}, Lights = {Flicker={Enabled=true,Duration=3},Shatter=true,Repair=false}, Earthquake = {Enabled=true}, CameraShake = {Enabled=true,Range=100,Values={2,50,0.1,1}},
            Movement = {Speed=85,Delay=4,Reversed=false}, Rebounding = {Enabled=false,Type="Blitz",Min=0,Max=1,Delay=2}, Debug = {}
        })
        if not e then return end
        
        e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,90,{"You died to Ripper.","He tears through the rooms.","Hide when lights flicker for a long time."},nil,false) local c=Instance.new("ColorCorrectionEffect") c.Name="RipperColor" c.TintColor=Color3.fromRGB(150,0,0) c.Contrast=1 c.Parent=game:GetService("Lighting") local ts=game:GetService("TweenService") ts:Create(c,TweenInfo.new(2.5),{Contrast=0}):Play() ts:Create(c,TweenInfo.new(80),{TintColor=Color3.fromRGB(255,255,255)}):Play() game.Debris:AddItem(c,85) end end) end)
        
        e:SetCallback("OnDespawning", function()
            pcall(function()
                local m = e.Model
                if m then
                    local soundPart = Instance.new("Part")
                    soundPart.Transparency = 1
                    soundPart.CanCollide = false
                    soundPart.Anchored = true
                    soundPart.Position = m:GetPivot().Position
                    soundPart.Parent = workspace
                    
                    local dSnd = Instance.new("Sound")
                    dSnd.Name = "RipperDespawn"
                    dSnd.SoundId = "rbxassetid://1837829565"
                    dSnd.Volume = 3
                    dSnd.PlaybackSpeed = 1
                    dSnd.Parent = soundPart
                    
                    dSnd:Play()
                    game.Debris:AddItem(soundPart, 10)
                end
            end)
        end)
        
        e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end)
        spawner:Run(e,false)
    end, function(er) return debug.traceback(er) end)
end
getgenv().SpawnEntity_Ripper=SE_Ripper

local function SE_Frostbite()
    if not spawner then return end
    local s, err = xpcall(function()
        local e = spawner:Create({
            Entity = {Name = "Frostbite", Asset = "97585092787249", HeightOffset = 3, CanOpenDoors = false, Is2D = false, NavMeshHeightOffset = 1.5, UntouchedAudio = true},
            Sounds = {}, Lights = {Flicker = {Enabled = true, Duration = 5}, Shatter = false, Repair = false}, Earthquake = {Enabled = false},
            CameraShake = {Enabled = false, Range = 100, Values = {1.5, 20, 0.1, 1}}, Movement = {Speed = 0, Delay = 999, Reversed = false},
            Rebounding = {Enabled = false, Type = "Ambush", Min = 0, Max = 0, Delay = 0}, Debug = {}
        })
        if not e then return end

        e:SetCallback("OnSpawned", function()
            pcall(function()
                local m = e.Model if not m then return end
                local root = m:FindFirstChild("Part") or m:FindFirstChild("Main") or m.PrimaryPart
                if root then
                    local lRV = game.ReplicatedStorage.GameData.LatestRoom.Value
                    local currentRoom = workspace.CurrentRooms:FindFirstChild(tostring(lRV))
                    if currentRoom and currentRoom:FindFirstChild("RoomExit") then m:PivotTo(currentRoom.RoomExit.CFrame + Vector3.new(0, 3, 0)) end

                    local c = Instance.new("ColorCorrectionEffect") c.Name = "FrostbiteTint" c.TintColor = Color3.fromRGB(150, 180, 255) c.Contrast = 0.5 c.Parent = game:GetService("Lighting")
                    local ts = game:GetService("TweenService")
                    
                    local mg = require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game)
                    if mg and mg.camShaker then mg.camShaker:ShakeOnce(5, 4, 2, 5) end
                    
                    local staticFX = root:FindFirstChild("Static Effect")
                    if staticFX then staticFX.Volume = 1.5 staticFX:Play() end
                    task.wait(4.5)
                    
                    local emergeSound = root:FindFirstChild("Sound") if emergeSound then emergeSound:Play() end
                    if staticFX then ts:Create(staticFX, TweenInfo.new(1, Enum.EasingStyle.Linear), {Volume = 0}):Play() end
                    task.wait(1) if staticFX then staticFX:Stop() end
                    
                    local ambFar = root:FindFirstChild("AmbienceFar") if ambFar then ambFar:Stop() end
                    local amb = root:FindFirstChild("Ambience") if amb then amb.Volume = 2 amb:Play() end
                    if mg and mg.camShaker then mg.camShaker:ShakeOnce(13, 13, 8, 5) end
                    
                    local att = root:FindFirstChild("Attachment")
                    if att then for _, p in pairs(att:GetChildren()) do if p:IsA("ParticleEmitter") then p.Enabled = true end end end
                    if root:FindFirstChild("Part") and root.Part:FindFirstChild("ParticleEmitter") then root.Part.ParticleEmitter.Enabled = true end
                    
                    ts:Create(c, TweenInfo.new(2, Enum.EasingStyle.Sine), {TintColor = Color3.fromRGB(80, 90, 200), Contrast = 0.8}):Play()

                    task.spawn(function()
                        while e:IsAlive() do
                            task.wait(1)
                            local char = game.Players.LocalPlayer.Character
                            if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                                local hasLighter = false
                                local currentTool = char:FindFirstChildOfClass("Tool")
                                if currentTool and (currentTool.Name:lower():find("lighter") or currentTool.Name:lower():find("flashlight")) then hasLighter = true end
                                
                                if not hasLighter and not getgenv().CustomGodMode then
                                    char.Humanoid:TakeDamage(5)
                                    if char.Humanoid.Health <= 0 then
                                        local f,sv,gi,to,gg,nx=nil,debug.setupvalue or setupvalue,debug.getinfo or getinfo,typeof,getgc,next for _,v in nx,gg(false) do if typeof(v)=="function" then local i=gi(v) if i.currentline==54 and i.nups==2 and i.is_vararg==0 then f=v break end end end sv(f,1,{"You froze to death.","Frostbite requires you to move fast.","Hold a lighter to stay warm!"});sv(f,2,"Blue") firesignal(ReplicatedStorage.Bricks.DeathHint.OnClientEvent,{"You froze to death.","Frostbite requires you to move fast.","Hold a lighter to stay warm!"},"Blue")
                                        local GameStats = game.ReplicatedStorage:FindFirstChild("GameStats")
                                        if GameStats and GameStats:FindFirstChild("Player_"..game.Players.LocalPlayer.Name) then GameStats["Player_"..game.Players.LocalPlayer.Name].Total.DeathCause.Value = "Frostbite" end
                                    end
                                end
                            end
                        end
                    end)

                    local despawnConnection
                    despawnConnection = game.ReplicatedStorage.GameData.LatestRoom.Changed:Connect(function(newRoom)
                        if newRoom > lRV then if despawnConnection then despawnConnection:Disconnect() end e:Despawn() end
                    end)
                    task.delay(30, function() if e:IsAlive() then if despawnConnection then despawnConnection:Disconnect() end e:Despawn() end end)
                end
            end)
        end)

        e:SetCallback("OnDespawning", function() pcall(function() local c = game:GetService("Lighting"):FindFirstChild("FrostbiteTint") if c then local ts = game:GetService("TweenService") local tw = ts:Create(c, TweenInfo.new(2, Enum.EasingStyle.Sine), {Contrast = 0, TintColor = Color3.fromRGB(255, 255, 255)}) tw:Play() tw.Completed:Connect(function() c:Destroy() end) end local m = e.Model if m then for _, obj in ipairs(m:GetDescendants()) do if obj:IsA("Sound") then game:GetService("TweenService"):Create(obj, TweenInfo.new(2), {Volume = 0}):Play() end end end end) end)
        e:SetCallback("OnDespawned", function() getgenv().ActiveCustomEntities = math.max(0, getgenv().ActiveCustomEntities - 1) end)
        spawner:Run(e, false)
    end, function(er) return debug.traceback(er) end)
end
getgenv().SpawnEntity_Frostbite=SE_Frostbite

local function SE_Depth() if not spawner then return end local s,err=xpcall(function() local e=spawner:Create({Entity={Name="Depth",Asset="https://github.com/7dls-ui/test-hardcore-entities-hardcore-script/raw/refs/heads/main/Hardcore/DepthMoving.rbxm",HeightOffset=0,CanOpenDoors=false,NavMeshHeightOffset=1.5,UntouchedAudio=true},Sounds={},Lights={Flicker={Enabled=true,Duration=1},Shatter=true},Earthquake={Enabled=true},CameraShake={Enabled=true,Range=100,Values={2,50,0.1,1}},Movement={Speed=180,Delay=5,Reversed=false},Rebounding={Enabled=true,Type="Ambush",Min=2,Max=2,Delay=0.5}}) if not e then return end e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,150,{"Depth is incredibly fast.","Hide the moment you hear him.","Be careful, he can come back."},nil,false) end end) end) e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) spawner:Run(e,false) end, function(er) return debug.traceback(er) end) end getgenv().SpawnEntity_Depth=SE_Depth

local function SE_Silence()
    if not spawner then return end
    local s, err = xpcall(function()
        local e = spawner:Create({
            Entity = {Name="Silence",Asset="https://github.com/7dls-ui/test-hardcore-entities-hardcore-script/raw/refs/heads/main/Hardcore/SilenceMoving2.rbxm",HeightOffset=0,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=1.5,UntouchedAudio=true},
            Sounds = {}, Lights = {Flicker={Enabled=false,Duration=1},Shatter=true,Repair=false}, Earthquake = {Enabled=false},
            CameraShake = {Enabled=true,Range=10,Values={1.5,20,0.1,1}}, Movement = {Speed=20,Delay=2,Reversed=false}, Rebounding = {Enabled=false,Type="Ambush",Min=1,Max=1,Delay=2}
        })
        if not e then return end
        e:SetCallback("OnSpawned", function() pcall(function() local m=e.Model if m then ASK(m,45,{"You died to Silence","hide!","..","....","becareful, ok?"},nil,false) end end) end)
        e:SetCallback("OnDespawned", function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end)
        spawner:Run(e, false)
    end, function(er) return debug.traceback(er) end)
end
getgenv().SpawnEntity_Silence=SE_Silence

local function SE_Cease()
    if not spawner then return end
    local s, err = xpcall(function()
        local e = spawner:Create({
            Entity = {Name="Cease",Asset="https://github.com/7dls-ui/test-hardcore-entities-hardcore-script/raw/refs/heads/main/Hardcore/CeaseMoving2.rbxm",HeightOffset=0,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=1.5,UntouchedAudio=true},
            Sounds = {}, Lights = {Flicker={Enabled=true,Duration=1},Shatter=true,Repair=false}, Earthquake = {Enabled=false},
            CameraShake = {Enabled=false,Range=100,Values={1.5,20,0.1,1}}, Movement = {Speed=60,Delay=2,Reversed=false}, Rebounding = {Enabled=false,Type="Ambush",Min=1,Max=1,Delay=2}
        })
        if not e then return end
        e:SetCallback("OnSpawned", function() pcall(function() local m=e.Model if m then ASK(m,80,{"You died to Cease..","He appears when the room turns blue","You just have to stand there and don't move until it disappears.","And if you move, he will kill you."},nil,true) local c=Instance.new("ColorCorrectionEffect") c.Name="CeaseColor" c.TintColor=Color3.fromRGB(92,103,255) c.Contrast=1 c.Parent=game:GetService("Lighting") local ts=game:GetService("TweenService") ts:Create(c,TweenInfo.new(2.5),{Contrast=0}):Play() ts:Create(c,TweenInfo.new(80),{TintColor=Color3.fromRGB(255,255,255)}):Play() game.Debris:AddItem(c,85) end end) end)
        e:SetCallback("OnDespawned", function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end)
        spawner:Run(e, false)
    end, function(er) return debug.traceback(er) end)
end
getgenv().SpawnEntity_Cease=SE_Cease

local function SE_Blitz()
    if not spawner then return end
    local s,err=xpcall(function()
        local e=spawner:Create({
            Entity={Name="Blitz",Asset="https://github.com/RegularVynixu/Utilities/raw/main/Doors/Entity%20Spawner/Assets/Entities/BackdoorRush.rbxm",HeightOffset=0,CanOpenDoors=false,NavMeshHeightOffset=1.5,UntouchedAudio=true},
            Lights={Flicker={Enabled=true,Duration=1},Shatter=true},
            Earthquake={Enabled=true},
            CameraShake={Enabled=true,Range=100,Values={1.5,20,0.1,1}},
            Movement={Speed=70,Delay=0,Reversed=false},
            Rebounding={Enabled=true,Type="Blitz",Min=1,Max=math.random(1,2),Delay=math.random(10,30)/10}
        })
        if not e then return end
        e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,75,{"Oh... Hello.","I didn't expect to see you here.","She said we should call that one Blitz.","Haha... of course you will."},nil,false) end end) end)
        e:SetCallback("OnRebounding",function(s) pcall(function() local m=e.Model:FindFirstChild("Main") if not m then return end local a,as=m:FindFirstChild("Attachment"),m:FindFirstChild("AttachmentSwitch") local f,p,w,b=m:FindFirstChild("Footsteps"),m:FindFirstChild("PlaySound"),m:FindFirstChild("Switch"),m:FindFirstChild("SwitchBack") if a and as then for _,c in next,a:GetChildren() do c.Enabled=(not s) end for _,c in next,as:GetChildren() do c.Enabled=s end end if s then if f then f.PlaybackSpeed=0.35 end if p then p.PlaybackSpeed=0.25 end if w then w:Play() end else if f then f.PlaybackSpeed=0.25 end if p then p.PlaybackSpeed=0.16 end if b then b:Play() end end end) end)
        e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end)
        spawner:Run(e,false)
    end, function(er) return debug.traceback(er) end)
end
getgenv().SpawnEntity_Blitz=SE_Blitz


-- =========================================================
-- || HARDCORE MODE: SYNC LISTENER ENGINE (CLIENT)        ||
-- =========================================================

-- !!! PLAYER 2 MUST PUT PLAYER 1'S EXACT ROBLOX USERNAME HERE !!!
local TargetHostName = "HostUsernameHere" 

print("[Hardcore Engine] Client Mode Active. Listening for Host: " .. TargetHostName)

local function HandleSyncSignal(msg)
    if string.match(msg, "%[HC_SYNC%]::SPAWN::(.+)") then
        local eID = string.split(msg, "::")[3]
        
        getgenv().ActiveCustomEntities = getgenv().ActiveCustomEntities + 1
        
        if eID == "Blitz" then coroutine.wrap(SE_Blitz)()
        elseif eID == "Cease" then coroutine.wrap(SE_Cease)()
        elseif eID == "Ripper" then coroutine.wrap(SE_Ripper)()
        elseif eID == "Depth" then coroutine.wrap(SE_Depth)()
        elseif eID == "Silence" then coroutine.wrap(SE_Silence)()
        elseif eID == "Rebound" then coroutine.wrap(SE_Rebound)()
        elseif eID == "DeerGod" then coroutine.wrap(SE_DeerGod)()
        elseif eID == "A200" then coroutine.wrap(SE_A200)()
        elseif eID == "A60" then coroutine.wrap(SE_A60)()
        elseif eID == "Frostbite" then coroutine.wrap(SE_Frostbite)()
        end
    end
end

-- Hook into players already in the game
for _, player in ipairs(game.Players:GetPlayers()) do
    player.Chatted:Connect(function(msg)
        if player.Name == TargetHostName then HandleSyncSignal(msg) end
    end)
end

-- Hook into players joining late
game.Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(msg)
        if player.Name == TargetHostName then HandleSyncSignal(msg) end
    end)
end)
