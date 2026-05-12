print(os.date("%B")) 
print("Loading Hardcore Mode with True Sound FX Engine and Dynamic Lighting...")

local tween = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local PathfindingService = game:GetService("PathfindingService")

if ReplicatedStorage:FindFirstChild("Extacuted") then warn("You have Already Loaded") return false end
local Test = Instance.new("Part") 
Test.Name = "Extacuted" 
Test.Parent = ReplicatedStorage

pcall(function() 
    if not ReplicatedStorage:FindFirstChild("RemotesFolder") then 
        local fR = Instance.new("Folder") fR.Name = "RemotesFolder" fR.Parent = ReplicatedStorage 
        local fH = Instance.new("RemoteEvent") fH.Name = "DeathHint" fH.Parent = fR 
    end 
end)

local VynixuModule = {}
getgenv().LoadCustomInstance = function(url)
    if url:find("rbxassetid") or tonumber(url) then
        local s, r = pcall(function() return game:GetObjects("rbxassetid://"..url:match("%d+"))[1] end)
        return s and r or nil
    elseif getcustomasset and url:lower():sub(1,4) == "http" then
        local f = "TempEntity_"..tostring(math.random(100000,999999))..".rbxm"
        local s, r = pcall(function()
            writefile(f, game:HttpGet(url))
            local asset = getcustomasset(f)
            return game:GetObjects(asset)[1]
        end)
        task.delay(3, function() pcall(function() if isfile(f) then delfile(f) end end) end)
        return s and r or nil
    end
    return nil
end

getgenv().ActiveCustomEntities = 0 
getgenv().CustomGodMode = false
getgenv().ReboundSpawnCount = 0 

task.spawn(function()
    task.wait(3) 
    pcall(function()
        local PG = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        local caption = PG:WaitForChild("MainUI"):WaitForChild("MainFrame"):WaitForChild("Caption")
        local TS = game:GetService("TweenService")
        local function displayHardcoreMessage(msg)
            caption.Text = msg caption.TextTransparency = 0 caption.Visible = true task.wait(1)
            TS:Create(caption, TweenInfo.new(1), {TextTransparency = 1}):Play() task.wait(1) 
        end
        displayHardcoreMessage("Hardcore Mode initiated.")
        displayHardcoreMessage("Created by sabnoober12")
        displayHardcoreMessage("Have Fun! (You Won't)")
    end)
end)

task.spawn(function()
    local LIT_ID, SHAT_ID, FLICK_ID = "rbxassetid://100619195335220", "rbxassetid://118261729120886", "rbxassetid://4288784832"
    local currentRooms = game:GetService("Workspace"):WaitForChild("CurrentRooms")
    local function createTemplate(assetId)
        local s, m = pcall(function() return game:GetObjects(assetId) end)
        if not s or not m or not m[1] then return nil end
        for _, d in ipairs(m[1]:GetDescendants()) do
            if d:IsA("Light") then d:Destroy() end
            if d:IsA("BasePart") then d.CanCollide = false end
        end
        return m[1]
    end
    local LitTemplate, ShatteredTemplate = createTemplate(LIT_ID), createTemplate(SHAT_ID)
    if not LitTemplate or not ShatteredTemplate then return end

    local function cloneCustomModel(t, vS, r)
        local c = t:Clone() c.Name = "CustomLightModel" c.Parent = r
        if vS:IsA("Model") then c:PivotTo(vS:GetPivot()) end return c
    end

    local function processLightstand(obj, room)
        if obj.Name == "LightStand" and obj:IsA("Model") then
            if obj:GetAttribute("SwapperProcessed") then return end
            obj:SetAttribute("SwapperProcessed", true)
            task.spawn(function()
                task.wait(0.5) if not obj or not obj.Parent then return end 
                for _, d in ipairs(obj:GetDescendants()) do
                    if d:IsA("BasePart") then d.Transparency = 1 d.CanCollide = false
                    elseif d:IsA("Decal") or d:IsA("Texture") then d.Transparency = 1 end
                end
                local isShat = obj:GetAttribute("Shattered")
                local lS = obj:FindFirstChildWhichIsA("Light", true)
                if not lS or not lS.Enabled or lS.Brightness <= 0 then isShat = true end
                local activeModel = cloneCustomModel(isShat and ShatteredTemplate or LitTemplate, obj, room)
                local vS = obj:FindFirstChildWhichIsA("Sound", true)
                local bV = vS and vS.Volume or 0.5
                local cFlicker = Instance.new("Sound")
                cFlicker.SoundId, cFlicker.Volume, cFlicker.RollOffMaxDistance, cFlicker.RollOffMinDistance = FLICK_ID, 1, 60, 10
                cFlicker.Parent = obj:FindFirstChildWhichIsA("BasePart", true) or obj
                local isFlickering = false
                if lS and not isShat then
                    local baseB = lS.Brightness
                    lS:GetPropertyChangedSignal("Brightness"):Connect(function()
                        if lS.Brightness < (baseB * 0.5) and not obj:GetAttribute("Shattered") and not isFlickering then
                            isFlickering = true if vS then vS.Volume = 0 end cFlicker:Play()
                            task.spawn(function()
                                cFlicker.Ended:Wait()
                                if not obj:GetAttribute("Shattered") and vS then vS.Volume = bV end
                                isFlickering = false
                            end)
                        end
                    end)
                end
                obj:GetAttributeChangedSignal("Shattered"):Connect(function()
                    if obj:GetAttribute("Shattered") then
                        if activeModel then activeModel:Destroy() end
                        activeModel = cloneCustomModel(ShatteredTemplate, obj, room)
                        if vS then vS.Volume = 0 end
                    end
                end)
            end)
        end
    end

    local function setupRoom(room)
        for _, obj in ipairs(room:GetDescendants()) do processLightstand(obj, room) end
        room.DescendantAdded:Connect(function(obj) processLightstand(obj, room) end)
    end
    currentRooms.ChildAdded:Connect(setupRoom)
    for _, room in ipairs(currentRooms:GetChildren()) do setupRoom(room) end
end)

local function IsSafeRoom(roomNum)
    if not roomNum then return false end local rStr = tostring(roomNum)
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
    end return false
end

local function TintRoomLights(room, color, tDur)
    if not room then return end
    for _, v in ipairs(room:GetDescendants()) do
        if v:IsA("Light") then
            if not v:GetAttribute("OGColor") then v:SetAttribute("OGColor", v.Color) end
            tween:Create(v, TweenInfo.new(tDur or 1), {Color = color}):Play()
        end
    end
end

local function UntintRoomLights(room, tDur)
    if not room then return end
    for _, v in ipairs(room:GetDescendants()) do
        if v:IsA("Light") and v:GetAttribute("OGColor") then
            tween:Create(v, TweenInfo.new(tDur or 2), {Color = v:GetAttribute("OGColor")}):Play()
        end
    end
end

task.spawn(function()
    pcall(function()
        local CAS, player = game:GetService("ContextActionService"), game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        local SB = Instance.new("ScreenGui") SB.Name = "StaminaBar" SB.Parent = player:WaitForChild("PlayerGui")
        local Bo = Instance.new("Frame") Bo.Name = "Border" Bo.Parent = SB Bo.AnchorPoint = Vector2.new(1, 1) Bo.BackgroundColor3 = Color3.fromRGB(0, 0, 0) Bo.BackgroundTransparency = 0.5 Bo.Position = UDim2.new(0.98, 0, 0.95, 0) Bo.Size = UDim2.new(0.15, 0, 0.015, 0) Bo.BorderSizePixel = 2
        local Ba = Instance.new("Frame") Ba.Name = "Bar" Ba.Parent = Bo Ba.BackgroundColor3 = Color3.fromRGB(50, 200, 50) Ba.Size = UDim2.new(1, 0, 1, 0) Ba.BorderSizePixel = 0 Bo.Visible = false 
        local sP, maxSp, drainRate, rechargeRate, isHoldingSprintKey, isExhausted, sprintSpeed, wasSprinting = 100, 100, 25, 16.66, false, false, 20, false
        local cam = workspace.CurrentCamera
        
        local function updateUI()
            if sP >= maxSp and not isHoldingSprintKey then Bo.Visible = false else
                Bo.Visible = true Ba.Size = UDim2.new(math.clamp(sP / maxSp, 0, 1), 0, 1, 0)
                Ba.BackgroundColor3 = isExhausted and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 200, 50) 
            end
        end

        CAS:BindAction("Sprint", function(_, state) isHoldingSprintKey = (state == Enum.UserInputState.Begin) end, true, Enum.KeyCode.Q)
        CAS:SetTitle("Sprint", "Q") CAS:SetPosition("Sprint", UDim2.new(5, 0, 0, 0))
        
        RS.RenderStepped:Connect(function(dt)
            local isMoving = humanoid.MoveDirection.Magnitude > 0
            local canSprint = isHoldingSprintKey and isMoving and not isExhausted and not character:GetAttribute("Hiding") and humanoid.WalkSpeed > 6
            if canSprint then
                wasSprinting = true sP = math.max(0, sP - (drainRate * dt)) humanoid.WalkSpeed = sprintSpeed
                cam.FieldOfView = cam.FieldOfView + (75 - cam.FieldOfView) * 10 * dt
                if sP == 0 then
                    isExhausted, isHoldingSprintKey = true, false 
                    local PG = player:FindFirstChild("PlayerGui")
                    if PG and PG:FindFirstChild("MainUI") then
                        local cap = PG.MainUI.MainFrame.Caption cap.Text, cap.TextTransparency, cap.Visible = "You're exhausted.", 0, true
                        tween:Create(cap, TweenInfo.new(1), {TextTransparency = 1}):Play()
                    end
                end
            else
                if wasSprinting then humanoid.WalkSpeed = 15 wasSprinting = false end
                sP = math.min(maxSp, sP + (rechargeRate * dt)) if sP >= maxSp then isExhausted = false end
                if cam.FieldOfView > 70.1 then cam.FieldOfView = cam.FieldOfView + (70 - cam.FieldOfView) * 10 * dt end
            end
            updateUI()
            if canSprint then humanoid.CameraOffset = humanoid.CameraOffset:lerp(Vector3.new(math.abs(math.sin(tick() * 12)) * 0.05, math.abs(math.sin(tick() * 12)) * 0.35, 0), 0.75)
            else humanoid.CameraOffset = humanoid.CameraOffset * 0.5 end
        end)
        humanoid.Died:Connect(function() SB:Destroy() end)
    end)
end)

getgenv().death = false 
Players.LocalPlayer.CharacterAdded:Connect(function(c) c:WaitForChild("Humanoid").Died:Connect(function() getgenv().death = true getgenv().ReboundSpawnCount = 0 end) end)

local function IPS(c, eM, iH)
    if not iH and c:GetAttribute("Hiding") == true then return true end
    local target = c:FindFirstChild("LeftLowerLeg") or c:FindFirstChild("RightLowerLeg") or c:FindFirstChild("Left Leg") or c:FindFirstChild("Right Leg") or c:FindFirstChild("LowerTorso") or c:FindFirstChild("Torso")
    local rt = eM:IsA("Model") and (eM.PrimaryPart or eM:FindFirstChildWhichIsA("BasePart", true)) or eM
    if not target or not rt then return false end
    local cp, ep = target.Position, rt.Position 
    local vec = ep - cp 
    local dist = vec.Magnitude
    if dist < 2 then return false end 
    local dir = vec.Unit * (dist - 2) 
    local il = {c, eM, Workspace.CurrentCamera}
    for _, p in ipairs(Players:GetPlayers()) do if p.Character then table.insert(il, p.Character) end end
    local rp = RaycastParams.new() rp.FilterType, rp.IgnoreWater = Enum.RaycastFilterType.Exclude, true
    for i = 1, 7 do
        rp.FilterDescendantsInstances = il 
        local res = Workspace:Spherecast(cp, 0.25, dir, rp)
        if not res then return false end 
        local inst = res.Instance 
        local n, pn = string.lower(inst.Name), inst.Parent and string.lower(inst.Parent.Name) or ""
        if n:find("door") or pn:find("door") or n:find("glass") or pn:find("glass") or inst.Transparency >= 0.99 then table.insert(il, inst) 
        elseif inst.Transparency > 0 and inst.CanCollide then table.insert(il, inst) else return true end
    end return false
end

local function ASK(eM, kR, dH, aC, rM, iH)
    local cn 
    cn = RS.Heartbeat:Connect(function()
        if getgenv().death or not eM.Parent then if cn then cn:Disconnect() end return end
        local c = Players.LocalPlayer.Character 
        local target = c and (c:FindFirstChild("LeftLowerLeg") or c:FindFirstChild("RightLowerLeg") or c:FindFirstChild("Left Leg") or c:FindFirstChild("Right Leg") or c:FindFirstChild("LowerTorso") or c:FindFirstChild("Torso"))
        if c and target and c:FindFirstChild("Humanoid") then
            local h = c.Humanoid 
            if h.Health > 0 then
                local rt = eM:IsA("Model") and (eM.PrimaryPart or eM:FindFirstChildWhichIsA("BasePart", true)) or eM
                if (target.Position - rt.Position).Magnitude <= kR and (not rM or h.MoveDirection.Magnitude > 0) and not getgenv().CustomGodMode then
                    if not IPS(c, eM, iH) then
                        getgenv().death = true if cn then cn:Disconnect() end if aC then pcall(aC) end
                        pcall(function() 
                            local f,sv,gi,to,gg,nx = nil, debug.setupvalue or setupvalue, debug.getinfo or getinfo, typeof, getgc, next 
                            for _,v in nx, gg(false) do if typeof(v) == "function" then local i = gi(v) if i.currentline == 54 and i.nups == 2 and i.is_vararg == 0 then f = v break end end end 
                            sv(f, 1, dH) sv(f, 2, "Blue") firesignal(ReplicatedStorage.Bricks.DeathHint.OnClientEvent, dH, "Blue") 
                        end) h.Health = 0
                    end
                end
            end
        end
    end)
end

getgenv().SpawnStaticEntity = function(config)
    local model = getgenv().LoadCustomInstance(config.Asset)
    if not model then warn("[Hardcore] Failed to load static entity") return end
    if not model:IsA("Model") then local wrp = Instance.new("Model") model.Parent = wrp model = wrp end
    local rt = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
    if not rt then return end model.PrimaryPart = rt
    
    for _, v in ipairs(model:GetDescendants()) do 
        if v:IsA("BasePart") then 
            if v.Name == "Main" or v.Name == "Part" or v == model.PrimaryPart then
                v.CanCollide = true
            else
                v.CanCollide = false 
            end
            v.Anchored = true 
        end 
    end

    local lRV = game.ReplicatedStorage.GameData.LatestRoom.Value
    local currentRoom = workspace.CurrentRooms:FindFirstChild(tostring(lRV))
    local targetCFrame = CFrame.new()

    if config.SpawnLocation == "FrontOfPlayer" then
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            local rayOrigin = root.Position
            local lookVector = root.CFrame.LookVector
            local flatLook = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
            local rayDir = flatLook * (config.FrontOffset or 30)
            local targetPos = rayOrigin + rayDir
            
            local rp = RaycastParams.new()
            rp.FilterDescendantsInstances = {currentRoom}
            rp.FilterType = Enum.RaycastFilterType.Include
            local floorCast = workspace:Raycast(targetPos + Vector3.new(0, 10, 0), Vector3.new(0, -50, 0), rp)
            
            if floorCast then
                local lookAtPos = Vector3.new(root.Position.X, floorCast.Position.Y + (config.HeightOffset or 0), root.Position.Z)
                targetCFrame = CFrame.new(floorCast.Position + Vector3.new(0, config.HeightOffset or 0, 0), lookAtPos)
            else
                local lookAtPos = Vector3.new(root.Position.X, targetPos.Y + (config.HeightOffset or 0), root.Position.Z)
                targetCFrame = CFrame.new(targetPos + Vector3.new(0, config.HeightOffset or 0, 0), lookAtPos)
            end
        end
    elseif currentRoom then
        local entPos = currentRoom:FindFirstChild("RoomEntrance")
        local extPos = currentRoom:FindFirstChild("RoomExit")
        if config.SpawnLocation == "Entrance" and entPos then
            targetCFrame = entPos.CFrame + Vector3.new(0, config.HeightOffset or 0, 0)
        elseif config.SpawnLocation == "Exit" and extPos then
            targetCFrame = extPos.CFrame + Vector3.new(0, config.HeightOffset or 0, 0)
        elseif config.SpawnLocation == "RandomRoom" and entPos and extPos then
            local midPos = entPos.Position:Lerp(extPos.Position, math.random(15, 85) / 100)
            local rp = RaycastParams.new()
            rp.FilterType = Enum.RaycastFilterType.Include
            rp.FilterDescendantsInstances = {currentRoom}
            local resCast = workspace:Raycast(midPos + Vector3.new(0, 10, 0), Vector3.new(0, -50, 0), rp)
            if resCast then targetCFrame = CFrame.new(resCast.Position + Vector3.new(0, config.HeightOffset or 0, 0)) else targetCFrame = CFrame.new(midPos + Vector3.new(0, config.HeightOffset or 0, 0)) end
        end
    end

    model:PivotTo(targetCFrame)
    model.Parent = workspace

    local isAlive = true
    local function Despawn()
        if not isAlive then return end
        isAlive = false
        if config.OnDespawning then pcall(config.OnDespawning, model) end
        task.delay(config.DespawnDelay or 0, function() if model then model:Destroy() end end)
    end
    if config.OnSpawned then task.spawn(config.OnSpawned, model, Despawn) end
    if config.DespawnOnNextRoom then
        local conn
        conn = game.ReplicatedStorage.GameData.LatestRoom.Changed:Connect(function(newRoom)
            if newRoom > lRV then if conn then conn:Disconnect() end Despawn() end
        end)
    end
end

task.spawn(function()
    local s_ui, err_ui = xpcall(function()
        local L=loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))() 
        local W=L.CreateLib("Hardcore Spawner","Midnight") 
        local function cW(f) if typeof(f)=="function" then coroutine.wrap(f)() else warn("[Hardcore Mode] Function not found.") end end
        
        local HT=W:NewTab("Hardcore Entities") 
        local HS=HT:NewSection("Manual Presets") 
        HS:NewButton("Spawn Depth","Spawns Depth",function() cW(getgenv().SpawnEntity_Depth) end)
        HS:NewButton("Spawn Blitz","Spawns Blitz",function() cW(getgenv().SpawnEntity_Blitz) end)
        HS:NewButton("Spawn Ripper","Spawns Ripper",function() cW(getgenv().SpawnEntity_Ripper) end)
        HS:NewButton("Spawn Rebound","Spawns Rebound",function() cW(getgenv().SpawnEntity_Rebound) end)
        HS:NewButton("Spawn Frostbite","Spawns Frostbite",function() cW(getgenv().SpawnEntity_Frostbite) end)
        HS:NewButton("Spawn Shocker","Spawns Shocker",function() cW(getgenv().SpawnEntity_Shocker) end)
        HS:NewButton("Spawn Deer God","Spawns Deer God",function() cW(getgenv().SpawnEntity_DeerGod) end)
        HS:NewButton("Spawn A-200","Spawns A-200",function() cW(getgenv().SpawnEntity_A200) end)
        HS:NewButton("Spawn Trollface","Spawns Trollface",function() cW(getgenv().SpawnEntity_Trollface) end)
        HS:NewButton("Spawn A-60","Spawns A-60",function() cW(getgenv().SpawnEntity_A60) end)
        HS:NewButton("Spawn Silence","Spawns Silence",function() cW(getgenv().SpawnEntity_Silence) end)
        HS:NewButton("Spawn Cease","Spawns Cease",function() cW(getgenv().SpawnEntity_Cease) end)
        HS:NewButton("Spawn Matcher","Spawns Matcher",function() cW(getgenv().SpawnEntity_Matcher) end)
        HS:NewButton("Revive","Revives you",function() pcall(function() getgenv().death=false game.ReplicatedStorage.Bricks.Revive:FireServer() end) end)
        HS:NewToggle("God-Mode","Grants immunity.",function(s) getgenv().CustomGodMode=s end)

        local NET=W:NewTab("Normal Entities") 
        local NES=NET:NewSection("Manual Presets")
        NES:NewButton("Spawn Ambush", "Spawns Ambush", function() cW(getgenv().SpawnEntity_Ambush) end)

        local SHT=W:NewTab("SUPER HARD MODE") 
        local SHS=SHT:NewSection("Super Hard Presets")
        SHS:NewButton("Spawn scary red face","Spawns scary red face",function() cW(getgenv().SpawnEntity_ScaryRedFace1) end)
        SHS:NewButton("Spawn Scary Red Face","Spawns Scary Red Face",function() cW(getgenv().SpawnEntity_ScaryRedFace2) end)
        SHS:NewButton("Spawn Nacho Varga","Spawns Nacho Varga",function() cW(getgenv().SpawnEntity_NachoVarga) end)
        SHS:NewButton("Spawn DEPTH","Spawns DEPTH",function() cW(getgenv().SpawnEntity_DEPTH_SHM) end)
        SHS:NewButton("Spawn Bald Kreek","Spawns Bald Kreek",function() cW(getgenv().SpawnEntity_BaldKreek) end)
        SHS:NewButton("Spawn rahh!!!","Spawns rahh!!!",function() cW(getgenv()["SpawnEntity_rahh!!!"]) end)
        SHS:NewButton("Spawn FREE ROBLOXIAN","Spawns FREE ROBLOXIAN",function() cW(getgenv()["SpawnEntity_FREE ROBLOXIAN OUTFIT"]) end)

        local ST=W:NewTab("Settings") 
        local SS=ST:NewSection("UI Settings") 
        SS:NewKeybind("Toggle UI Key","Press [",Enum.KeyCode.LeftBracket,function() L:ToggleUI() end)
        
        RS.RenderStepped:Connect(function() 
            local gh=(getgenv and getgenv().gethui) or nil 
            local cg=gh and gh() or game:GetService("CoreGui") 
            local kU=cg:FindFirstChild("Hardcore Spawner") or Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Hardcore Spawner") 
            if kU and kU:FindFirstChild("Main") and kU.Main.Visible then 
                UIS.MouseIconEnabled,UIS.MouseBehavior=true,Enum.MouseBehavior.Default 
            end 
        end)
    end, function(e) return debug.traceback(e) end)
end)

local spawner=nil 
task.spawn(function()
    local mU=Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainUI",999999) 
    if not mU then return end
    
    local s_eng, err_eng = xpcall(function()
        spawner=(function()
            local Rm,CR=ReplicatedStorage:WaitForChild("RemotesFolder"),workspace:WaitForChild("CurrentRooms")
            local mE,mG,mQ 
            
            pcall(function() mE=require((ReplicatedStorage:FindFirstChild("ClientModules") or ReplicatedStorage:FindFirstChild("ModulesClient")):WaitForChild("Module_Events",3)) end)
            pcall(function() mG=require(Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game) end)
            pcall(function() mQ=require(Rm.RequestAsset:InvokeServer("Earthquake")) end)
            
            local Mods={Module_Events=mE,Main_Game=mG,Earthquake=mQ} 
            local CT={BASE_ENTITY_SPEED=65,ATTR={ENTITY={Running=false,Paused=false,Despawning=false,LastEnteredRoom=-1}}} 
            local M={ActiveEntities={}}
            
            local function cT(t) 
                local n={} 
                for k,v in pairs(t) do 
                    n[k]=typeof(v)=="table" and cT(v) or v 
                end 
                return n 
            end
            
            local function GCR(l) 
                return l and CR:GetChildren()[#CR:GetChildren()] or CR:FindFirstChild(Players.LocalPlayer:GetAttribute("CurrentRoom")) 
            end
            
            local function GetSortedRooms() 
                local r,vR=CR:GetChildren(),{} 
                for _,v in ipairs(r) do 
                    if tonumber(v.Name) then table.insert(vR,v) end 
                end 
                table.sort(vR,function(a,b) return tonumber(a.Name)<tonumber(b.Name) end) 
                return vR 
            end
            
            local function GRAP(v) 
                local rp = RaycastParams.new()
                rp.FilterType = Enum.RaycastFilterType.Include
                rp.FilterDescendantsInstances = CR:GetChildren()
                local res = workspace:Raycast(v, Vector3.new(0, -100, 0), rp)
                if res then
                    local obj = res.Instance
                    while obj and obj.Parent and obj.Parent ~= CR do obj = obj.Parent end
                    if obj and obj.Parent == CR then return obj end
                end
                return nil
            end
            
            local function FRL(rm) 
                local re=rm:FindFirstChild("RoomEntrance") 
                if not re then return end 
                if Mods.Module_Events then pcall(function() Mods.Module_Events.toggle(rm,true,{}) end) end 
                local rd=Random.new(tick()) 
                for _,v in ipairs(rm:GetDescendants()) do 
                    if v:IsA("Model") and (v.Name=="LightStand" or v.Name=="Chandelier") and v:GetAttribute("Shattered") then 
                        task.delay((re.Position-v.PrimaryPart.Position).Magnitude/150+rd:NextInteger(-10,10)/50,function() 
                            local r2=rd:NextInteger(5,20)/100 
                            local nn=v:FindFirstChild("CustomNeon",true) or v:FindFirstChild("Neon",true) 
                            for _,d in ipairs(v:GetDescendants()) do 
                                if d:IsA("Light") then tween:Create(d,TweenInfo.new(r2),{Brightness=d:GetAttribute("OGBrightness")}):Play() 
                                elseif d:IsA("Sound") then tween:Create(d,TweenInfo.new(r2),{Volume=d:GetAttribute("OGVolume")}):Play() end 
                            end 
                            if nn then 
                                nn.Transparency=0.9 nn.Material=Enum.Material.Neon 
                                tween:Create(nn,TweenInfo.new(r2),{Transparency=0.2}):Play() 
                            end 
                            v:SetAttribute("Shattered",nil) 
                        end) 
                    end 
                end 
            end
            
            local function PreCalculatePath(sp, ep)
                local dD={} 
                for _,o in pairs(workspace:GetDescendants()) do 
                    if o:IsA("BasePart") and (o.Name:lower():match("door") or o.Name:lower():match("gate") or o.Name:lower():match("hidden")) then 
                        if o.CanCollide then o.CanCollide=false table.insert(dD,o) end 
                    end 
                end
                local p=PathfindingService:CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=false,WaypointSpacing=3}) 
                local s=pcall(function() p:ComputeAsync(sp,ep) end)
                for _,o in ipairs(dD) do o.CanCollide=true end 
                local wps={} 
                if s and p.Status==Enum.PathStatus.Success then 
                    for _,wp in ipairs(p:GetWaypoints()) do table.insert(wps,CFrame.new(wp.Position)) end 
                else table.insert(wps,CFrame.new(sp)) table.insert(wps,CFrame.new(ep)) end 
                return wps
            end

            local function GPA_PreCalc(cf)
                local rms=GetSortedRooms() 
                if #rms==0 then return {} end 
                local mW,lRV,eI={},ReplicatedStorage.GameData.LatestRoom.Value,1
                for i,r in ipairs(rms) do eI=i if tonumber(r.Name)==lRV then break end end
                if cf.Movement.Reversed then 
                    for i=eI,1,-1 do 
                        local rx,re=rms[i]:FindFirstChild("RoomExit") or rms[i]:FindFirstChild("RoomEntrance"),rms[i]:FindFirstChild("RoomEntrance") or rms[i]:FindFirstChild("RoomExit") 
                        if rx and re then for _,w in ipairs(PreCalculatePath(rx.Position,re.Position)) do table.insert(mW,w) end end 
                    end 
                else 
                    for i=1,eI do 
                        local re,rx=rms[i]:FindFirstChild("RoomEntrance") or rms[i]:FindFirstChild("RoomExit"),rms[i]:FindFirstChild("RoomExit") or rms[i]:FindFirstChild("RoomEntrance") 
                        if re and rx then for _,w in ipairs(PreCalculatePath(re.Position,rx.Position)) do table.insert(mW,w) end end 
                    end 
                end 
                return mW
            end

            local function EMT_PreCalc(m, wps, sp, ho, nho)
                local rW=false 
                for _,wC in ipairs(wps) do 
                    local tP = wC.Position + Vector3.new(0, 4.5 + (ho or 0) + (nho or 0), 0) 
                    local nR, cn = false, nil
                    cn = RS.Stepped:Connect(function(_,step) 
                        if not m.Parent then cn:Disconnect() rW=true return end 
                        if not m:GetAttribute("Paused") then 
                            local cP = m:GetPivot().Position
                            local vec = tP - cP
                            local dist = vec.Magnitude
                            local moveAmount = step * sp
                            if dist > moveAmount then 
                                local nP = cP + (vec.Unit * moveAmount) 
                                local fL = Vector3.new(vec.Unit.X, 0, vec.Unit.Z) 
                                m:PivotTo(fL.Magnitude > 0.001 and CFrame.new(nP, nP + fL) or CFrame.new(nP)) 
                            else 
                                local fL = Vector3.new(vec.Unit.X, 0, vec.Unit.Z)
                                m:PivotTo(fL.Magnitude > 0.001 and CFrame.new(tP, tP + fL) or CFrame.new(tP)) 
                                cn:Disconnect() nR=true 
                            end 
                        end 
                    end)
                    repeat RS.Stepped:Wait() until nR or rW 
                    if rW then break end 
                end
            end

            M.Create=function(s,cf) 
                local nc=cT(cf) 
                nc.Movement.Speed=CT.BASE_ENTITY_SPEED/100*cf.Movement.Speed 
                local i
                if nc.Entity.Is2D then 
                    i=Instance.new("Model") i.Name=nc.Entity.Name or "2DEntity" 
                    local r=Instance.new("Part",i) r.Name="Main" r.Size=Vector3.new(2,5,2) r.Transparency=1 r.CanCollide=false r.Anchored=true i.PrimaryPart=r 
                    local b=Instance.new("BillboardGui",r) b.Name="Sprite" b.Size=UDim2.new(8,0,8,0) b.AlwaysOnTop=true b.LightInfluence=0 b.MaxDistance=3000 b.Adornee=r 
                    local img=Instance.new("ImageLabel",b) img.Size=UDim2.new(1,0,1,0) img.BackgroundTransparency=1 img.ScaleType=Enum.ScaleType.Fit 
                    local ast=tostring(nc.Entity.Asset) 
                    if tonumber(ast) then ast="rbxassetid://"..ast end img.Image=ast
                else 
                    i = getgenv().LoadCustomInstance(nc.Entity.Asset)
                end
                
                local rt=(i and i:IsA("Model") and i.PrimaryPart) or (i and i:FindFirstChildWhichIsA("BasePart",true)) or (i and i:IsA("BasePart") and i)
                if not rt then return nil end 
                if not i:IsA("Model") then local wrp=Instance.new("Model") i.Parent=wrp i=wrp end
                
                for _,v in ipairs(i:GetDescendants()) do 
                    if v:IsA("BasePart") then v.CanCollide=false v.Anchored=true end 
                end 
                rt.Anchored=true i.PrimaryPart=rt i.Name=nc.Entity.Name or i.Name 
                for a,v in pairs(CT.ATTR.ENTITY) do i:SetAttribute(a,v) end 
                local c=Instance.new("Configuration",i) c.Name="RoomsEntered" 
                
                return {
                    Model=i,
                    Config=nc,
                    Debug=cf.Debug or {},
                    SetCallback=function(ss,k,cb) ss.Debug[k]=cb end,
                    RunCallback=function(ss,k,...) if typeof(ss.Debug[k])=="function" then pcall(ss.Debug[k],...) end end,
                    IsAlive=function(ss) return ss.Model and not ss.Model:GetAttribute("FullyDespawned") end,
                    Run=function(ss,cE) M:Run(ss,cE) end,
                    Despawn=function(ss) 
                        if ss:IsAlive() then 
                            ss.Model:SetAttribute("FullyDespawned", true) 
                            ss.Model:Destroy() 
                            local id=table.find(M.ActiveEntities,ss) 
                            if id then table.remove(M.ActiveEntities,id) end 
                            task.spawn(ss.RunCallback,ss,"OnDespawned") 
                        end 
                    end
                } 
            end
            
            M.Run=function(s,e,c) 
                if c then s:Run(cT(e),false) return end 
                if e.Model:GetAttribute("Running") then return end 
                
                local m,cf=e.Model,e.Config 
                m:SetAttribute("Running",true) 
                s.ActiveEntities[#s.ActiveEntities+1]=e 
                
                local r=GetSortedRooms() 
                local sp=cf.Movement.Reversed and r[#r]:FindFirstChild("RoomExit") or r[1]:FindFirstChild("RoomEntrance") 
                local rt = m:FindFirstChild("Main") or (m:IsA("Model") and m.PrimaryPart) or m:FindFirstChildWhichIsA("BasePart", true) or (m:IsA("BasePart") and m)
                
                local globalSounds, despawnConfigs = {}, {}
                
                if cf.Sounds and next(cf.Sounds) ~= nil then
                    for _,o in ipairs(m:GetDescendants()) do if o:IsA("Sound") then o:Destroy() end end
                    if rt then
                        for sN, sD in pairs(cf.Sounds) do
                            local isDespawn = sD.PlayOnDespawn or sN:lower():find("despawn") or sN:lower():find("end")
                            if isDespawn then 
                                table.insert(despawnConfigs, {Name = sN, Config = sD})
                            else
                                local snd = Instance.new("Sound") 
                                snd.Name = sN 
                                snd.SoundId = sD.SoundId 
                                snd.PlaybackSpeed = sD.PlaybackSpeed or 1 
                                snd.RollOffMinDistance = sD.RollOffMinDistance or 10 
                                snd.RollOffMaxDistance = sD.RollOffMaxDistance or 1500 
                                snd.RollOffMode = Enum.RollOffMode.InverseTapered 
                                snd.Looped = sD.Looped 
                                if snd.Looped == nil then snd.Looped = true end 
                                snd.Volume = 0
                                
                                if sD.Global then 
                                    snd.Parent = workspace table.insert(globalSounds, snd) 
                                else 
                                    snd.Parent = rt 
                                end
                                
                                if sD.Effects then 
                                    for fN, fP in pairs(sD.Effects) do 
                                        local scc, fx = pcall(function() return Instance.new(fP.ClassName) end) 
                                        if scc and fx then 
                                            fx.Name = fN 
                                            for k, v in pairs(fP) do if k ~= "ClassName" then pcall(function() fx[k] = v end) end end 
                                            fx.Enabled = true fx.Parent = snd 
                                        end 
                                    end 
                                end
                                snd:Play() 
                                if not snd.Looped then snd.Ended:Connect(function() snd:Destroy() end) end 
                                tween:Create(snd, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Volume = sD.Volume or 1}):Play()
                            end
                        end
                    end
                else
                    if cf.Entity.UntouchedAudio then
                        for _,o in ipairs(m:GetDescendants()) do 
                            if o:IsA("Sound") and o.Playing then 
                                local tv = o.Volume o.Volume = 0 
                                tween:Create(o,TweenInfo.new(2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Volume=tv}):Play() 
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
                                        if n == "farsound" then o.RollOffMinDistance = 10; o.RollOffMaxDistance = 1500; o.RollOffMode = Enum.RollOffMode.InverseTapered 
                                        elseif n == "nearsound" then o.RollOffMinDistance = 5; o.RollOffMaxDistance = 75; o.RollOffMode = Enum.RollOffMode.InverseTapered 
                                        else o.RollOffMinDistance = 10; o.RollOffMaxDistance = 1000; o.RollOffMode = Enum.RollOffMode.InverseTapered end
                                    end
                                    local tv = o.Volume if tv <= 0.01 then tv = 1.5 end o.Volume = 0 
                                    if not o.IsPlaying then o:Play() end 
                                    tween:Create(o,TweenInfo.new(2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Volume=tv}):Play() 
                                end
                            end 
                        end
                    end
                end

                if cf.Movement.Speed > 0 then m:PivotTo(sp.CFrame+Vector3.new(0,cf.Entity.HeightOffset,0)) end
                m.Parent=workspace 
                task.spawn(e.RunCallback,e,"OnSpawned") 
                
                local cR=GCR(false) 
                if cR then 
                    if cf.Lights.Flicker.Enabled and Mods.Module_Events then pcall(function() Mods.Module_Events.flicker(cR,cf.Lights.Flicker.Duration) end) end 
                    if cf.Earthquake and cf.Earthquake.Enabled and Mods.Earthquake then task.defer(Mods.Earthquake,Mods.Main_Game,cR) end 
                end 
                
                task.wait(cf.Movement.Delay) 
                task.spawn(e.RunCallback,e,"OnStartMoving")

                local cshake = cf.CameraShake
                if cshake and cshake.Enabled then
                    task.spawn(function()
                        while e:IsAlive() and task.wait() do
                            if not m.Parent then continue end
                            local rtp = m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart", true)
                            if rtp and Players.LocalPlayer.Character and Players.LocalPlayer.Character.PrimaryPart and Mods.Main_Game and Mods.Main_Game.camShaker then
                                local origin = rtp.Position
                                local charOrigin = Players.LocalPlayer.Character.PrimaryPart.Position
                                local mag = (charOrigin - origin).Magnitude
                                if mag <= cshake.Range then
                                    local cloned = {}
                                    for i, v in ipairs(cshake.Values) do cloned[i] = v end
                                    cloned[1] = cshake.Values[1] / cshake.Range * (cshake.Range - mag)
                                    cloned[2] = cshake.Values[2] / cshake.Range * (cshake.Range - mag)
                                    Mods.Main_Game.camShaker:ShakeOnce(table.unpack(cloned))
                                end
                            end
                        end
                    end)
                end

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
                                        local ft=re:GetAttribute(rm.Name)==nil 
                                        task.spawn(e.RunCallback,e,"OnEnterRoom",rm,ft) 
                                        if ft then re:SetAttribute(rm.Name,true) end 
                                        local lR = ReplicatedStorage.GameData.LatestRoom.Value 
                                        if cf.Lights.Shatter and Mods.Module_Events and id<=lR then pcall(function() Mods.Module_Events.shatter(rm) end)
                                        elseif cf.Lights.Repair and id<=lR then pcall(function() FRL(rm) end) end 
                                    end 
                                end 
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
                            local pathfindNodes = GPA_PreCalc(cf) 
                            EMT_PreCalc(m, pathfindNodes, cf.Movement.Speed, cf.Entity.HeightOffset, cf.Entity.NavMeshHeightOffset)
                            if cf.Rebounding.Enabled then 
                                local reboundsCount = math.random(cf.Rebounding.Min, cf.Rebounding.Max) 
                                for i = 1, reboundsCount do 
                                    task.wait(cf.Rebounding.Delay) m:SetAttribute("Damage", true) 
                                    task.spawn(e.RunCallback, e, "OnRebounding", true) 
                                    local backwardNodes = {} 
                                    for j = #pathfindNodes, 1, -1 do table.insert(backwardNodes, pathfindNodes[j]) end 
                                    EMT_PreCalc(m, backwardNodes, cf.Movement.Speed, cf.Entity.HeightOffset, cf.Entity.NavMeshHeightOffset) 
                                    task.spawn(e.RunCallback, e, "OnRebounding", false) task.wait(cf.Rebounding.Delay) 
                                    m:SetAttribute("Damage", true) task.spawn(e.RunCallback, e, "OnRebounding", true) 
                                    pathfindNodes = GPA_PreCalc(cf) 
                                    EMT_PreCalc(m, pathfindNodes, cf.Movement.Speed, cf.Entity.HeightOffset, cf.Entity.NavMeshHeightOffset) 
                                    task.spawn(e.RunCallback, e, "OnRebounding", false) 
                                    if i < reboundsCount then task.wait(cf.Rebounding.Delay) end 
                                end 
                            end
                        
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
                                    table.insert(nodesToCurrent, wp) table.insert(roomNodes, wp) passedCurrent = true 
                                elseif not passedCurrent then table.insert(nodesToCurrent, wp) else table.insert(nodesToEnd, wp) end 
                            end
                            if #roomNodes <= 1 and #pathfindNodes > 1 then
                                roomNodes = {}
                                for i = math.max(1, #pathfindNodes - 15), #pathfindNodes do table.insert(roomNodes, pathfindNodes[i]) end
                            end

                            EMT_PreCalc(m, nodesToCurrent, cf.Movement.Speed, cf.Entity.HeightOffset, cf.Entity.NavMeshHeightOffset)
                            if cf.Rebounding.Enabled and #roomNodes > 1 then 
                                local rc = math.random(cf.Rebounding.Min, cf.Rebounding.Max) 
                                local randIdx = 1 
                                if not cf.Movement.Reversed then randIdx = math.random(1, math.max(1, #roomNodes - 1)) else randIdx = math.random(math.min(2, #roomNodes), #roomNodes) end 
                                for _ = 1, rc do 
                                    m:SetAttribute("Damage", true) task.spawn(e.RunCallback, e, "OnRebounding", true) 
                                    local backWp = {} 
                                    for i = #roomNodes, randIdx, -1 do table.insert(backWp, roomNodes[i]) end 
                                    EMT_PreCalc(m, backWp, cf.Movement.Speed, cf.Entity.HeightOffset, cf.Entity.NavMeshHeightOffset) 
                                    task.wait(cf.Rebounding.Delay) m:SetAttribute("Damage", true) task.spawn(e.RunCallback, e, "OnRebounding", false) 
                                    local fwdWp = {} 
                                    for i = randIdx, #roomNodes do table.insert(fwdWp, roomNodes[i]) end 
                                    EMT_PreCalc(m, fwdWp, cf.Movement.Speed, cf.Entity.HeightOffset, cf.Entity.NavMeshHeightOffset) 
                                end 
                            end
                            
                            local fullPathAgain = GPA_PreCalc(cf) 
                            local updatedToEnd, foundCurrentAgain = {}, false 
                            for _, wp in ipairs(fullPathAgain) do 
                                local checkRoom = GRAP(wp.Position) 
                                if checkRoom and checkRoom.Name == pRoomStr then foundCurrentAgain = true 
                                elseif foundCurrentAgain and (not checkRoom or checkRoom.Name ~= pRoomStr) then table.insert(updatedToEnd, wp) end 
                            end
                            if #updatedToEnd > 0 then EMT_PreCalc(m, updatedToEnd, cf.Movement.Speed, cf.Entity.HeightOffset, cf.Entity.NavMeshHeightOffset) 
                            elseif #nodesToEnd > 0 then EMT_PreCalc(m, nodesToEnd, cf.Movement.Speed, cf.Entity.HeightOffset, cf.Entity.NavMeshHeightOffset) 
                            else
                                local fbk = {}
                                for i = math.min(#pathfindNodes, #nodesToCurrent + 1), #pathfindNodes do table.insert(fbk, pathfindNodes[i]) end
                                if #fbk > 0 then EMT_PreCalc(m, fbk, cf.Movement.Speed, cf.Entity.HeightOffset, cf.Entity.NavMeshHeightOffset) end
                            end
                            
                        elseif rtType=="REBOUND" then
                            local pathfindNodes = GPA_PreCalc(cf)
                            EMT_PreCalc(m, pathfindNodes, cf.Movement.Speed, cf.Entity.HeightOffset, cf.Entity.NavMeshHeightOffset)
                            if cf.Rebounding.Enabled then
                                local targetLaps, currentLap = math.random(cf.Rebounding.Min, cf.Rebounding.Max), 1
                                m:SetAttribute("Paused", true)
                                local cP = m:GetPivot() local dD = cP.LookVector.Unit local cv 
                                cv = RS.Stepped:Connect(function(_,stp) if m.Parent then m:PivotTo(m:GetPivot()+(dD*(cf.Movement.Speed*stp))) else cv:Disconnect() end end)
                                task.wait(1.5) if cv then cv:Disconnect() end m.Parent = nil 
                                
                                while currentLap < targetLaps do
                                    local startRoom = game.ReplicatedStorage.GameData.LatestRoom.Value
                                    repeat task.wait(0.1) until game.ReplicatedStorage.GameData.LatestRoom.Value > startRoom or getgenv().death
                                    if getgenv().death or IsSafeRoom(game.ReplicatedStorage.GameData.LatestRoom.Value) then break end
                                    
                                    currentLap = currentLap + 1
                                    local nRms = GetSortedRooms()
                                    local nSp = cf.Movement.Reversed and nRms[#nRms]:FindFirstChild("RoomExit") or nRms[1]:FindFirstChild("RoomEntrance") 
                                    if nSp then
                                        m:PivotTo(nSp.CFrame + Vector3.new(0,cf.Entity.HeightOffset,0))
                                        m.Parent = workspace m:SetAttribute("Paused", true) 
                                        task.spawn(e.RunCallback, e, "OnRebounding", true)
                                        if delayVal > 0 then task.wait(delayVal) end 
                                        
                                        m:SetAttribute("Paused", false)
                                        local newPath = GPA_PreCalc(cf)
                                        EMT_PreCalc(m, newPath, cf.Movement.Speed, cf.Entity.HeightOffset, cf.Entity.NavMeshHeightOffset)
                                        
                                        m:SetAttribute("Paused", true)
                                        local nCP, nDD, nCV = m:GetPivot(), m:GetPivot().LookVector.Unit, nil 
                                        nCV = RS.Stepped:Connect(function(_,stp) if m.Parent then m:PivotTo(m:GetPivot()+(nDD*(cf.Movement.Speed*stp))) else nCV:Disconnect() end end)
                                        task.wait(1.5) if nCV then nCV:Disconnect() end m.Parent = nil
                                    end
                                end
                            else
                                m:SetAttribute("Paused", true)
                                local cP, dD, cv = m:GetPivot(), m:GetPivot().LookVector.Unit, nil 
                                cv = RS.Stepped:Connect(function(_,stp) if m.Parent then m:PivotTo(m:GetPivot()+(dD*(cf.Movement.Speed*stp))) else cv:Disconnect() end end)
                                task.wait(1.5) if cv then cv:Disconnect() end m.Parent = nil 
                            end

                        elseif rtType=="CHASE" then
                            local lastHandledRoom = ReplicatedStorage.GameData.LatestRoom.Value
                            local targetLaps = math.random(cf.Rebounding.Min, cf.Rebounding.Max)
                            for i = 1, targetLaps do
                                local currentPath = GPA_PreCalc(cf)
                                EMT_PreCalc(m, currentPath, cf.Movement.Speed, cf.Entity.HeightOffset, cf.Entity.NavMeshHeightOffset)
                                if ReplicatedStorage.GameData.LatestRoom.Value <= lastHandledRoom then
                                    m:SetAttribute("Paused", true)
                                    local waited = 0
                                    while waited < 15 do
                                        if ReplicatedStorage.GameData.LatestRoom.Value > lastHandledRoom or getgenv().death then break end
                                        task.wait(0.1) waited = waited + 0.1
                                    end
                                    m:SetAttribute("Paused", false)
                                end
                                if ReplicatedStorage.GameData.LatestRoom.Value > lastHandledRoom and not getgenv().death then lastHandledRoom = ReplicatedStorage.GameData.LatestRoom.Value else break end
                            end
                        end
                        
                        if cf.Entity.RipperDelay and rtType ~= "REBOUND" then
                            local rDelay = 0
                            if type(cf.Entity.RipperDelay) == "number" then rDelay = cf.Entity.RipperDelay
                            elseif type(cf.Entity.RipperDelay) == "table" then rDelay = math.random((cf.Entity.RipperDelay.Min or 0) * 10, (cf.Entity.RipperDelay.Max or 0) * 10) / 10 end
                            if rDelay > 0 then task.wait(rDelay) end
                        end
                        
                        if not m:GetAttribute("Despawning") then
                            m:SetAttribute("Despawning",true) task.spawn(e.RunCallback,e,"OnDespawning")
                            for _, dC in ipairs(despawnConfigs) do 
                                local sD = dC.Config local snd = Instance.new("Sound") snd.Name = dC.Name snd.SoundId = sD.SoundId snd.Volume = sD.Volume or 1 snd.PlaybackSpeed = sD.PlaybackSpeed or 1 snd.RollOffMinDistance = sD.RollOffMinDistance or 10 snd.RollOffMaxDistance = sD.RollOffMaxDistance or 1500 snd.RollOffMode = Enum.RollOffMode.InverseTapered snd.Looped = sD.Looped or false
                                if sD.Global then snd.Parent = workspace else 
                                    local soundPart = Instance.new("Part") soundPart.Transparency = 1 soundPart.CanCollide = false soundPart.Anchored = true soundPart.Position = m:GetPivot().Position soundPart.Parent = workspace snd.Parent = soundPart game.Debris:AddItem(soundPart, 10) 
                                end
                                if sD.Effects then 
                                    for fN, fP in pairs(sD.Effects) do 
                                        local success, fx = pcall(function() return Instance.new(fP.ClassName) end) 
                                        if success and fx then fx.Name = fN for k, v in pairs(fP) do if k ~= "ClassName" then pcall(function() fx[k] = v end) end end fx.Enabled = true fx.Parent = snd end 
                                    end 
                                end 
                                snd:Play() if not snd.Looped then snd.Ended:Connect(function() snd:Destroy() end) end
                            end
                            
                            for _,v in ipairs(m:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=false end end
                            for _,o in ipairs(m:GetDescendants()) do if o:IsA("Sound") then tween:Create(o,TweenInfo.new(2.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{Volume=0}):Play() end end
                            for _,o in ipairs(globalSounds) do tween:Create(o,TweenInfo.new(2.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{Volume=0}):Play() task.delay(2.5, function() o:Destroy() end) end
                            
                            if rtType ~= "REBOUND" and rtType ~= "CHASE" then
                                local cP, dD, c = m:GetPivot(), (m:GetPivot().LookVector-Vector3.new(0,0.3,0)).Unit, nil 
                                c=RS.Stepped:Connect(function(_,stp) if m.Parent then m:PivotTo(m:GetPivot()+(dD*(cf.Movement.Speed*stp))) else c:Disconnect() end end)
                                task.wait(2.5) if c then c:Disconnect() end 
                            else task.wait(2.5) end
                            e:Despawn()
                        end
                    end)
                end
            end
            getgenv().VynixuEntitySpawnerV2=M 
            return M
        end)()
    end, function(e) return debug.traceback(e) end)
end)

local function SE_Ambush() 
    if not spawner then return end 
    local s,err=xpcall(function() 
        local e=spawner:Create({
            Entity={Name="Ambush",Asset="77471049714310",HeightOffset=0,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=0},
            Sounds={
                FarSound={SoundId="rbxassetid://80435851839067",Volume=10,PlaybackSpeed=1,RollOffMinDistance=10,RollOffMaxDistance=500,Looped=true},
                NearSound={SoundId="rbxassetid://80435851839067",Volume=10,PlaybackSpeed=1.10,RollOffMinDistance=5,RollOffMaxDistance=75,Looped=true},
                ArrivalSound={SoundId="rbxassetid://134020218579308",Volume=3,PlaybackSpeed=1,Looped=false,Global=true}
            },
            Lights={Flicker={Enabled=true,Duration=1},Shatter=true,Repair=false}, Earthquake={Enabled=false}, CameraShake={Enabled=true,Range=100,Values={3, 15, 0.1, 1}},
            Movement={Speed=120,Delay=5,Reversed=false}, Rebounding={Enabled=true,Type="Legacy Ambush",Min=2,Max=5,Delay=0.5}, Debug={}
        }) 
        if not e then return end 
        e:SetCallback("OnSpawned",function() ASK(e.Model,40,{"You died to Ambush.","It comes back!","Hide when the lights flicker!"},nil,false) end) 
        e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) 
        spawner:Run(e,false) 
    end,function(er) return debug.traceback(er) end) 
end 
getgenv().SpawnEntity_Ambush=SE_Ambush

local function SE_A60() 
    if not spawner then return end 
    local s,err=xpcall(function() 
        local e=spawner:Create({
            Entity={Name="A-60",Asset="https://github.com/7dls-ui/test-hardcore-entities-hardcore-script/raw/refs/heads/main/Hardcore/A60Moving.rbxm",HeightOffset=1,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=0,UntouchedAudio=true},
            Sounds={}, Lights={Flicker={Enabled=true,Duration=1},Shatter=true,Repair=false}, Earthquake={Enabled=false}, CameraShake={Enabled=true,Range=100,Values={5, 75, 0.1, 1}},
            Movement={Speed=200,Delay=4,Reversed=false}, Rebounding={Enabled=true,Type="Legacy Ambush",Min=2,Max=4,Delay=2}, Debug={}
        }) 
        if not e then return end 
        e:SetCallback("OnSpawned",function() ASK(e.Model,120,{"You died to A-60.","It is incredibly fast!","Hide when the lights flicker!"},nil,false) end) 
        e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) 
        spawner:Run(e,false) 
    end,function(er) return debug.traceback(er) end) 
end 
getgenv().SpawnEntity_A60=SE_A60

local function SE_A200() 
    if not spawner then return end 
    local s,err=xpcall(function() 
        local e=spawner:Create({
            Entity={Name="A-200",Asset="https://github.com/7dls-ui/test-hardcore-entities-hardcore-script/raw/refs/heads/main/Hardcore/A200Moving4.rbxm",HeightOffset=1.5,CanOpenDoors=false,NavMeshHeightOffset=0,UntouchedAudio=true},
            Lights={Flicker={Enabled=true,Duration=1.5},Shatter=true}, Earthquake={Enabled=false}, CameraShake={Enabled=true,Range=100,Values={1, 35, 0.1, 1}},
            Movement={Speed=40,Delay=7,Reversed=true}, Rebounding={Enabled=true,Type="Blitz",Min=0,Max=2,Delay=0.5}
        }) 
        if not e then return end 
        e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,40,{"You died to A-200.","Spawns ahead and travels backwards.","Hide quickly!"},nil,false) end end) end) 
        e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) 
        spawner:Run(e,false) 
    end, function(er) return debug.traceback(er) end) 
end 
getgenv().SpawnEntity_A200=SE_A200

local function SE_FreeRobloxianOutfit() 
    if not spawner then return end 
    local s,err=xpcall(function() 
        local e=spawner:Create({
            Entity={Name="FREE ROBLOXIAN OUTFIT",Asset="rbxassetid://103662059684022",HeightOffset=0,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=0},
            Sounds={FarSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.2,RollOffMinDistance=10,RollOffMaxDistance=1000,Looped=true},NearSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.75,RollOffMinDistance=5,RollOffMaxDistance=75,Looped=true}},
            Lights={Flicker={Enabled=true,Duration=1},Shatter=true,Repair=false}, Earthquake={Enabled=false}, CameraShake={Enabled=true,Range=100,Values={2, 15, 0.1, 1}},
            Movement={Speed=80,Delay=1.5,Reversed=false}, Rebounding={Enabled=false,Type="Ambush",Min=1,Max=1,Delay=2}, Debug={}
        }) 
        if not e then return end 
        e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,40,{"You died to FREE ROBLOXIAN OUTFIT.","Hide when the lights flicker!"},nil,false) end end) end) 
        e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) 
        spawner:Run(e,false) 
    end, function(er) return debug.traceback(er) end) 
end 
getgenv()["SpawnEntity_FREE ROBLOXIAN OUTFIT"]=SE_FreeRobloxianOutfit

local function SE_rahh() 
    if not spawner then return end 
    local s,err=xpcall(function() 
        local e=spawner:Create({
            Entity={Name="rahh!!!",Asset="rbxassetid://123875017551067",HeightOffset=0,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=0},
            Sounds={FarSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.2,RollOffMinDistance=10,RollOffMaxDistance=1000,Looped=true},NearSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.75,RollOffMinDistance=5,RollOffMaxDistance=75,Looped=true}},
            Lights={Flicker={Enabled=true,Duration=1},Shatter=true,Repair=false}, Earthquake={Enabled=false}, CameraShake={Enabled=true,Range=100,Values={2, 15, 0.1, 1}},
            Movement={Speed=80,Delay=1.5,Reversed=false}, Rebounding={Enabled=false,Type="Ambush",Min=1,Max=1,Delay=2}, Debug={}
        }) 
        if not e then return end 
        e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,40,{"You died to rahh!!!.","Hide when the lights flicker!"},nil,false) end end) end) 
        e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) 
        spawner:Run(e,false) 
    end, function(er) return debug.traceback(er) end) 
end 
getgenv()["SpawnEntity_rahh!!!"]=SE_rahh

local function SE_BaldKreek() 
    if not spawner then return end 
    local s,err=xpcall(function() 
        local e=spawner:Create({
            Entity={Name="Bald Kreek",Asset="rbxassetid://93078046721158",HeightOffset=0,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=0},
            Sounds={FarSound={SoundId="rbxassetid://1845307009",Volume=1.5,PlaybackSpeed=0.2,RollOffMinDistance=10,RollOffMaxDistance=1000,Looped=true},NearSound={SoundId="rbxassetid://1845307009",Volume=1.5,PlaybackSpeed=0.4,RollOffMinDistance=5,RollOffMaxDistance=75,Looped=true}},
            Lights={Flicker={Enabled=true,Duration=1},Shatter=true,Repair=false}, Earthquake={Enabled=false}, CameraShake={Enabled=true,Range=100,Values={2, 15, 0.1, 1}},
            Movement={Speed=80,Delay=1.5,Reversed=false}, Rebounding={Enabled=false,Type="Ambush",Min=1,Max=1,Delay=2}, Debug={}
        }) 
        if not e then return end 
        e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,40,{"You died to Bald Kreek.","Hide when the lights flicker!"},nil,false) end end) end) 
        e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) 
        spawner:Run(e,false) 
    end, function(er) return debug.traceback(er) end) 
end 
getgenv().SpawnEntity_BaldKreek=SE_BaldKreek

local function SE_NachoVarga() 
    if not spawner then return end 
    local s,err=xpcall(function() 
        local e=spawner:Create({
            Entity={Name="Nacho Varga",Asset="rbxassetid://122425276040196",HeightOffset=0,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=0},
            Sounds={FarSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.2,RollOffMinDistance=10,RollOffMaxDistance=1000,Looped=true},NearSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.75,RollOffMinDistance=5,RollOffMaxDistance=75,Looped=true}},
            Lights={Flicker={Enabled=true,Duration=1},Shatter=true,Repair=false}, Earthquake={Enabled=false}, CameraShake={Enabled=true,Range=100,Values={2, 15, 0.1, 1}},
            Movement={Speed=80,Delay=1.5,Reversed=false}, Rebounding={Enabled=false,Type="Ambush",Min=1,Max=1,Delay=2}, Debug={}
        }) 
        if not e then return end 
        e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,40,{"You died to Nacho Varga.","Hide when the lights flicker!"},nil,false) end end) end) 
        e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) 
        spawner:Run(e,false) 
    end, function(er) return debug.traceback(er) end) 
end 
getgenv().SpawnEntity_NachoVarga=SE_NachoVarga

local function SE_ScaryRedFace1() 
    if not spawner then return end 
    local s,err=xpcall(function() 
        local e=spawner:Create({
            Entity={Name="scary red face",Asset="rbxassetid://12987999444",HeightOffset=0,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=0},
            Sounds={FarSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.2,RollOffMinDistance=10,RollOffMaxDistance=1000,Looped=true},NearSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.75,RollOffMinDistance=5,RollOffMaxDistance=75,Looped=true}},
            Lights={Flicker={Enabled=true,Duration=1.5},Shatter=true,Repair=false}, Earthquake={Enabled=false}, CameraShake={Enabled=true,Range=100,Values={2, 15, 0.1, 1}},
            Movement={Speed=80,Delay=1.5,Reversed=false}, Rebounding={Enabled=false,Type="Ambush",Min=1,Max=1,Delay=2}, Debug={}
        }) 
        if not e then return end 
        e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,40,{"You died to the scary red face.","It approaches at a moderate speed.","Hide when the lights flicker!"},nil,false) end end) end) 
        e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) 
        spawner:Run(e,false) 
    end, function(er) return debug.traceback(er) end) 
end 
getgenv().SpawnEntity_ScaryRedFace1=SE_ScaryRedFace1

local function SE_ScaryRedFace2() 
    if not spawner then return end 
    local s,err=xpcall(function() 
        local e=spawner:Create({
            Entity={Name="Scary Red Face",Asset="rbxassetid://83896895946876",HeightOffset=0,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=0},
            Sounds={FarSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.2,RollOffMinDistance=10,RollOffMaxDistance=1000,Looped=true},NearSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.75,RollOffMinDistance=5,RollOffMaxDistance=75,Looped=true}},
            Lights={Flicker={Enabled=true,Duration=1.5},Shatter=true,Repair=false}, Earthquake={Enabled=false}, CameraShake={Enabled=true,Range=100,Values={2, 15, 0.1, 1}},
            Movement={Speed=80,Delay=1.5,Reversed=false}, Rebounding={Enabled=false,Type="Ambush",Min=1,Max=1,Delay=2}, Debug={}
        }) 
        if not e then return end 
        e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,40,{"You died to the Scary Red Face.","It approaches at a moderate speed.","Hide when the lights flicker!"},nil,false) end end) end) 
        e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) 
        spawner:Run(e,false) 
    end, function(er) return debug.traceback(er) end) 
end 
getgenv().SpawnEntity_ScaryRedFace2=SE_ScaryRedFace2

local function SE_DEPTH_SHM() 
    if not spawner then return end 
    local s,err=xpcall(function() 
        local e=spawner:Create({
            Entity={Name="DEPTH",Asset="rbxassetid://84780317335866",HeightOffset=0,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=0},
            Sounds={FarSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.75,RollOffMinDistance=10,RollOffMaxDistance=1000,Looped=true},NearSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=1,RollOffMinDistance=5,RollOffMaxDistance=75,Looped=true}},
            Lights={Flicker={Enabled=true,Duration=1},Shatter=true,Repair=false}, Earthquake={Enabled=false}, CameraShake={Enabled=true,Range=120,Values={3, 50, 0.1, 1}},
            Movement={Speed=80,Delay=1.5,Reversed=false}, Rebounding={Enabled=false,Type="Ambush",Min=1,Max=1,Delay=2}, Debug={}
        }) 
        if not e then return end 
        e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,40,{"You died to DEPTH.","Hide when the lights flicker!"},nil,false) end end) end) 
        e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) 
        spawner:Run(e,false) 
    end, function(er) return debug.traceback(er) end) 
end 
getgenv().SpawnEntity_DEPTH_SHM=SE_DEPTH_SHM

local function SE_Trollface() 
    if not spawner then return end 
    local s,err=xpcall(function() 
        local e=spawner:Create({
            Entity={Name="Trollface",Asset="rbxassetid://17687252419",HeightOffset=1,NavMeshHeightOffset=0},
            Sounds={FarSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.2,RollOffMinDistance=10,RollOffMaxDistance=1500,Looped=true},NearSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.75,RollOffMinDistance=5,RollOffMaxDistance=300,Looped=true}},
            Lights={Flicker={Enabled=false,Duration=1},Shatter=true}, Earthquake={Enabled=false}, CameraShake={Enabled=true,Range=100,Values={2, 15, 0.1, 1}},
            Movement={Speed=200,Delay=5,Reversed=false}, Rebounding={Enabled=false,Type="Ambush",Min=1,Max=1,Delay=2}
        }) 
        if not e then return end 
        e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,40,{"Problem?","You just got trolled.","He is incredibly fast."},nil,false) end end) end) 
        e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) 
        spawner:Run(e,false) 
    end, function(er) return debug.traceback(er) end) 
end 
getgenv().SpawnEntity_Trollface=SE_Trollface

local function SE_DeerGod()
    if not spawner then warn("[Hardcore] Spawner missing for Deer God!") return end
    local s, err = xpcall(function()
        local e = spawner:Create({
            Entity = {Name = "Deer God", Asset = "https://github.com/7dls-ui/test-hardcore-entities-hardcore-script/raw/refs/heads/main/Hardcore/DeerGodMoving2.rbxm", HeightOffset = 0, CanOpenDoors = false, Is2D = false, NavMeshHeightOffset = 0, UntouchedAudio = true, RipperDelay = 1},
            Sounds = {}, Lights = {Flicker = {Enabled = true, Duration = 5}, Shatter = true, Repair = false}, Earthquake = {Enabled = false}, CameraShake = {Enabled = true, Range = 150, Values = {4, 20, 0.1, 1}},
            Movement = {Speed = 25, Delay = 6, Reversed = false}, Rebounding = {Enabled = false, Type = "Ambush", Min = 1, Max = 1, Delay = 2}, Debug = {}
        })
        if not e then return end
        e:SetCallback("OnSpawned", function() pcall(function() local m = e.Model if m then ASK(m, 150, {"You died to the Deer God.", "It ignores hiding spots.", "Break line of sight to survive!"}, nil, false, true) end end) end)
        e:SetCallback("OnDespawned", function() getgenv().ActiveCustomEntities = math.max(0, getgenv().ActiveCustomEntities - 1) end)
        spawner:Run(e, false)
    end, function(er) return debug.traceback(er) end)
end
getgenv().SpawnEntity_DeerGod = SE_DeerGod

local function SE_Rebound_Core(isStalker)
    if not spawner then return end
    local s,err=xpcall(function()
        local e=spawner:Create({
            Entity = {Name="Rebound",Asset="rbxassetid://12254145022",HeightOffset=0,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=0,UntouchedAudio=true},
            Sounds = {}, Lights = {Flicker={Enabled=false}, Shatter=false, Repair=false}, Earthquake = {Enabled=false}, CameraShake={Enabled=true,Range=100,Values={6,20,0.1,1}},
            Movement = {Speed=70, Delay=isStalker and 2 or 7, Reversed=true}, Rebounding = {Enabled=false, Type="Ambush", Min=1, Max=1, Delay=2}, Debug = {}
        })
        if not e then return end
        e:SetCallback("OnSpawned",function()
            pcall(function()
                local function GitAud(soundgit,filename) pcall(function() if not isfile(filename..".mp3") then writefile(filename..".mp3", game:HttpGet(soundgit)) end end) return (getcustomasset or getsynasset)(filename..".mp3") end
                if not isStalker then
                    task.spawn(function()
                        local tintColor, lastRoom = Color3.fromRGB(65, 138, 255), nil
                        while e:IsAlive() do
                            local pRoom = Players.LocalPlayer:GetAttribute("CurrentRoom") or ReplicatedStorage.GameData.LatestRoom.Value
                            if pRoom ~= lastRoom then
                                if lastRoom then UntintRoomLights(workspace.CurrentRooms:FindFirstChild(tostring(lastRoom)), 1.5) end
                                TintRoomLights(workspace.CurrentRooms:FindFirstChild(tostring(pRoom)), tintColor, 1) lastRoom = pRoom
                            end
                            task.wait(0.1)
                        end
                        if lastRoom then UntintRoomLights(workspace.CurrentRooms:FindFirstChild(tostring(lastRoom)), 2) end
                    end)
                    task.spawn(function() pcall(function() local Main_Game = require(Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game) if Main_Game and Main_Game.camShaker then Main_Game.camShaker:ShakeOnce(10, 3, 0.1, 6, 2, 0.5) end end) end)
                    local warnSnd = Instance.new("Sound") warnSnd.SoundId = GitAud("https://github.com/Isth4t/ReboundMain/raw/main/ReboundWarning.mp3", "ReboundWarning") warnSnd.Parent = workspace warnSnd.Volume = 3 warnSnd:Play() game.Debris:AddItem(warnSnd, 10)
                end
                local m = e.Model if m then ASK(m, 40, {"You died to who you call Rebound...", "He makes his presence known and keeps coming back...", "Hide when this happens!"}, function() pcall(function() loadstring(game:HttpGet('https://pastefy.app/RtjDtwEJ/raw'))() end) end, false, false) end
                task.delay(isStalker and 0.5 or 4, function() if m and m.Parent then local root = m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart") local ReboudMov = Instance.new("Sound") ReboudMov.SoundId = GitAud("https://github.com/Kotyara19k-Doorsspawner/Random-files/raw/main/Y2meta.app%20-%20DOORS%20HARDCORE_REBOUND%20MOVING%20START%20(320%20kbps).mp3", "ReboundMoving") ReboudMov.Parent = root or workspace ReboudMov.Volume = 2 ReboudMov.RollOffMaxDistance = 1500 ReboudMov.Looped = true ReboudMov:Play() m:SetAttribute("MovingSound", ReboudMov.Name) end end)
            end)
        end)
        e:SetCallback("OnStartMoving", function() task.spawn(function() if not isStalker then game.ReplicatedStorage.GameData.LatestRoom.Changed:Wait() pcall(function() loadstring(game:HttpGet("https://pastefy.app/Ou6ZqFoX/raw"))() end) end end) end)
        e:SetCallback("OnDespawning", function() pcall(function() local m = e.Model if m then local sndName = m:GetAttribute("MovingSound") if sndName then local root = m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart") if root and root:FindFirstChild(sndName) then game:GetService("TweenService"):Create(root[sndName], TweenInfo.new(2.5), {Volume = 0}):Play() end end end end) end)
        e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) spawner:Run(e,false)
    end, function(er) return debug.traceback(er) end)
end

local function SE_Rebound()
    if getgenv().ReboundControllerActive then return end
    getgenv().ReboundControllerActive, getgenv().ReboundAttacks = true, 1 coroutine.wrap(SE_Rebound_Core)(false)
    task.spawn(function()
        local lastRoom = ReplicatedStorage.GameData.LatestRoom.Value
        while getgenv().ReboundAttacks < 4 and not getgenv().death do
            ReplicatedStorage.GameData.LatestRoom.Changed:Wait()
            local curRoom = ReplicatedStorage.GameData.LatestRoom.Value
            if curRoom > lastRoom and not IsSafeRoom(curRoom) then
                lastRoom = curRoom task.wait(math.random(3, 8)) 
                if not getgenv().death then getgenv().ReboundAttacks = getgenv().ReboundAttacks + 1 coroutine.wrap(SE_Rebound_Core)(true) end
            end
        end
        getgenv().ReboundControllerActive, getgenv().ReboundAttacks = false, 0
    end)
end
getgenv().SpawnEntity_Rebound = SE_Rebound

local function SE_Ripper()
    if not spawner then warn("[Hardcore] Spawner missing for Ripper!") return end
    local s,err=xpcall(function()
        local e=spawner:Create({
            Entity = {Name="Ripper",Asset="https://github.com/7dls-ui/test-hardcore-entities-hardcore-script/raw/refs/heads/main/Hardcore/RipperMoving2.rbxm",HeightOffset=0,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=0,UntouchedAudio=true,RipperDelay={Min=1,Max=3}},
            Sounds = {}, Lights = {Flicker={Enabled=true,Duration=3},Shatter=true,Repair=false}, Earthquake = {Enabled=false}, CameraShake={Enabled=true,Range=120,Values={3,50,0.1,1}}, Movement = {Speed=135,Delay=4,Reversed=false}, Rebounding = {Enabled=false,Type="Blitz",Min=0,Max=1,Delay=2}, Debug = {}
        })
        if not e then return end
        e:SetCallback("OnSpawned",function() 
            pcall(function() local m=e.Model if m then ASK(m,90,{"You died to Ripper.","He tears through the rooms.","Hide when lights flicker for a long time."},nil,false) end 
                task.spawn(function() pcall(function() local MG=require(Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game) if MG and MG.camShaker then MG.camShaker:ShakeOnce(10,3,0.1,6,2,0.5) end end) end)
                task.spawn(function() local tc,lR=Color3.fromRGB(200,0,0),nil while e:IsAlive() do local pR=Players.LocalPlayer:GetAttribute("CurrentRoom") or ReplicatedStorage.GameData.LatestRoom.Value if pR~=lR then if lR then UntintRoomLights(workspace.CurrentRooms:FindFirstChild(tostring(lR)),1.5) end TintRoomLights(workspace.CurrentRooms:FindFirstChild(tostring(pR)),tc,1) lR=pR end task.wait(0.1) end if lR then UntintRoomLights(workspace.CurrentRooms:FindFirstChild(tostring(lR)),2) end end)
            end) 
        end)
        e:SetCallback("OnDespawning",function() pcall(function() task.spawn(function() pcall(function() local MG=require(Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game) if MG and MG.camShaker then MG.camShaker:ShakeOnce(20,15,0.7,0.6,10,7) end end) end) local m=e.Model if m then local sP=Instance.new("Part") sP.Transparency,sP.CanCollide,sP.Anchored,sP.Position,sP.Parent=1,false,true,m:GetPivot().Position,workspace local dS=Instance.new("Sound") dS.Name,dS.SoundId,dS.Volume,dS.PlaybackSpeed,dS.Parent="RipperDespawn","rbxassetid://1837829565",3,1,sP dS:Play() game.Debris:AddItem(sP,10) end end) end)
        e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) spawner:Run(e,false)
    end, function(er) return debug.traceback(er) end)
end
getgenv().SpawnEntity_Ripper=SE_Ripper

local function SE_Matcher()
    if not spawner then return end
    local s, err = xpcall(function()
        local e = spawner:Create({
            Entity = {Name = "Matcher", Asset = "https://github.com/7dls-ui/test-hardcore-entities-hardcore-script/raw/refs/heads/main/Hardcore/MatcherMoving.rbxm", HeightOffset = 0, CanOpenDoors = false, Is2D = false, NavMeshHeightOffset = 0, UntouchedAudio = true },
            Sounds = {}, Lights = {Flicker = {Enabled = true, Duration = 5}, Shatter = false, Repair = false}, Earthquake = {Enabled = false}, CameraShake={Enabled=true,Range=100,Values={2,35,0.1,1}},
            Movement = {Speed = 100, Delay = 5, Reversed = false}, Rebounding = {Enabled = true, Type = "Legacy Ambush", Min = 0, Max = 1, Delay = 0}, Debug = {}
        })
        if not e then return end
        e:SetCallback("OnSpawned", function() pcall(function() local m = e.Model if m then ASK(m, 85, {"You died to Matcher.", "Pay close attention to the lights.", "Good luck."}, nil, false, false) end end) end)
        e:SetCallback("OnDespawned", function() getgenv().ActiveCustomEntities = math.max(0, getgenv().ActiveCustomEntities - 1) end) spawner:Run(e, false)
    end, function(er) return debug.traceback(er) end)
end
getgenv().SpawnEntity_Matcher = SE_Matcher

local function SE_Blitz()
    if not spawner then return end
    local s,err=xpcall(function()
        local e=spawner:Create({
            Entity={Name="Blitz",Asset="https://github.com/RegularVynixu/Utilities/raw/main/Doors/Entity%20Spawner/Assets/Entities/BackdoorRush.rbxm",HeightOffset=0,CanOpenDoors=false,NavMeshHeightOffset=0,UntouchedAudio=true},
            Lights={Flicker={Enabled=true,Duration=1},Shatter=true}, Earthquake={Enabled=false}, CameraShake={Enabled=true,Range=100,Values={3,25,0.1,1}},
            Movement={Speed=70,Delay=0,Reversed=false}, Rebounding={Enabled=true,Type="Blitz",Min=1,Max=math.random(1,2),Delay=math.random(10,30)/10}
        })
        if not e then return end
        e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,75,{"Oh... Hello.","I didn't expect to see you here.","She said we should call that one Blitz.","Haha... of course you will."},nil,false) end end) end)
        e:SetCallback("OnRebounding",function(s) pcall(function() local m=e.Model:FindFirstChild("Main") if not m then return end local a,as,f,p,w,b=m:FindFirstChild("Attachment"),m:FindFirstChild("AttachmentSwitch"),m:FindFirstChild("Footsteps"),m:FindFirstChild("PlaySound"),m:FindFirstChild("Switch"),m:FindFirstChild("SwitchBack") if a and as then for _,c in ipairs(a:GetChildren()) do c.Enabled=(not s) end for _,c in ipairs(as:GetChildren()) do c.Enabled=s end end if s then if f then f.PlaybackSpeed=0.35 end if p then p.PlaybackSpeed=0.25 end if w then w:Play() end else if f then f.PlaybackSpeed=0.25 end if p then p.PlaybackSpeed=0.16 end if b then b:Play() end end end) end)
        e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) spawner:Run(e,false)
    end, function(er) return debug.traceback(er) end)
end
getgenv().SpawnEntity_Blitz=SE_Blitz

local function SE_Depth() 
    if not spawner then return end 
    local s,err=xpcall(function() 
        local e=spawner:Create({
            Entity={Name="Depth",Asset="https://github.com/7dls-ui/test-hardcore-entities-hardcore-script/raw/refs/heads/main/Hardcore/DepthMoving.rbxm",HeightOffset=0,CanOpenDoors=false,NavMeshHeightOffset=0,UntouchedAudio=true},
            Sounds={}, Lights={Flicker={Enabled=true,Duration=1},Shatter=true}, Earthquake={Enabled=false}, CameraShake={Enabled=true,Range=120,Values={3,50,0.1,1}},
            Movement={Speed=180,Delay=5,Reversed=false}, Rebounding={Enabled=true,Type="Ambush",Min=2,Max=2,Delay=0.5}
        }) 
        if not e then return end 
        e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,150,{"Depth is incredibly fast.","Hide the moment you hear him.","Be careful, he can come back."},nil,false) end end) end) 
        e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) spawner:Run(e,false) 
    end, function(er) return debug.traceback(er) end) 
end 
getgenv().SpawnEntity_Depth=SE_Depth

local function SE_Silence()
    if not spawner then return end
    local s, err = xpcall(function()
        local e = spawner:Create({
            Entity = {Name="Silence",Asset="https://github.com/7dls-ui/test-hardcore-entities-hardcore-script/raw/refs/heads/main/Hardcore/SilenceMoving2.rbxm",HeightOffset=0,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=0,UntouchedAudio=true, RipperDelay = 1},
            Sounds = {}, Lights = {Flicker={Enabled=false,Duration=1},Shatter=true,Repair=false}, Earthquake = {Enabled=false}, CameraShake={Enabled=false,Range=0,Values={0,0,0,0}},
            Movement = {Speed=35,Delay=0,Reversed=false}, Rebounding = {Enabled=false,Type="Ambush",Min=1,Max=1,Delay=0}
        })
        if not e then return end
        e:SetCallback("OnSpawned", function() pcall(function() local m=e.Model if m then ASK(m,45,{"You died to Silence","hide!","..","....","becareful, ok?"},nil,false) end end) end)
        e:SetCallback("OnDespawned", function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) spawner:Run(e, false)
    end, function(er) return debug.traceback(er) end)
end
getgenv().SpawnEntity_Silence=SE_Silence

local function SE_Cease()
    if not spawner then return end
    local s, err = xpcall(function()
        local e = spawner:Create({
            Entity = {Name="Cease",Asset="https://github.com/7dls-ui/test-hardcore-entities-hardcore-script/raw/refs/heads/main/Hardcore/CeaseMoving2.rbxm",HeightOffset=0,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=0,UntouchedAudio=true},
            Sounds = {}, Lights = {Flicker={Enabled=true,Duration=1},Shatter=false,Repair=false}, Earthquake = {Enabled=false}, CameraShake={Enabled=true,Range=100,Values={1,35,0.1,1}},
            Movement = {Speed=60,Delay=2,Reversed=false}, Rebounding = {Enabled=false,Type="Ambush",Min=1,Max=1,Delay=2}
        })
        if not e then return end
        e:SetCallback("OnSpawned", function() 
            pcall(function() local m=e.Model if m then ASK(m,80,{"You died to Cease..","He appears when the room turns blue","You just have to stand there and don't move until it disappears.","And if you move, he will kill you."},nil,true) end task.spawn(function() local tc, lR = Color3.fromRGB(92, 103, 255), nil while e:IsAlive() do local pR=Players.LocalPlayer:GetAttribute("CurrentRoom") or ReplicatedStorage.GameData.LatestRoom.Value if pR~=lR then if lR then UntintRoomLights(workspace.CurrentRooms:FindFirstChild(tostring(lR)), 1.5) end TintRoomLights(workspace.CurrentRooms:FindFirstChild(tostring(pR)), tc, 1) lR=pR end task.wait(0.1) end if lR then UntintRoomLights(workspace.CurrentRooms:FindFirstChild(tostring(lR)), 2) end end) end) 
        end)
        e:SetCallback("OnDespawned", function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) spawner:Run(e, false)
    end, function(er) return debug.traceback(er) end)
end
getgenv().SpawnEntity_Cease=SE_Cease

local function SE_Frostbite()
    if not spawner then return end
    coroutine.wrap(function()
        local e=spawner:Create({Entity={Name="Frostbite",Asset="97585092787249",HeightOffset=3,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=0,UntouchedAudio=true},Sounds={},Lights={Flicker={Enabled=true,Duration=5},Shatter=false,Repair=false},Earthquake={Enabled=false},CameraShake={Enabled=false},Movement={Speed=0,Delay=999,Reversed=false},Rebounding={Enabled=false,Type="Ambush",Min=0,Max=0,Delay=0},Debug={}}) if not e then return end
        e:SetCallback("OnSpawned",function() pcall(function() local m,lRV=e.Model,game.ReplicatedStorage.GameData.LatestRoom.Value if not m then return end local root=m:FindFirstChild("Part") or m:FindFirstChild("Main") or m.PrimaryPart if root then local cR=workspace.CurrentRooms:FindFirstChild(tostring(lRV)) if cR and cR:FindFirstChild("RoomEntrance") and cR:FindFirstChild("RoomExit") then local mP=cR.RoomEntrance.Position:Lerp(cR.RoomExit.Position,math.random(30,70)/100) local rp=RaycastParams.new() rp.FilterType,rp.FilterDescendantsInstances=Enum.RaycastFilterType.Include,{cR} local res=workspace:Raycast(mP+Vector3.new(0,10,0),Vector3.new(0,-50,0),rp) m:PivotTo(CFrame.new((res and res.Position or mP)+Vector3.new(0,3,0))) end local c=Instance.new("ColorCorrectionEffect") c.Name,c.TintColor,c.Contrast,c.Parent="FrostbiteTint",Color3.fromRGB(150,180,255),0.5,game:GetService("Lighting") local ts,MG=game:GetService("TweenService"),require(Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game) if MG and MG.camShaker then MG.camShaker:ShakeOnce(5,4,2,5) end local sFX=root:FindFirstChild("Static Effect") if sFX then sFX.Volume=1.5 sFX:Play() task.delay(4.5,function() local eS=root:FindFirstChild("Sound") if eS then eS:Play() end ts:Create(sFX,TweenInfo.new(1,Enum.EasingStyle.Linear),{Volume=0}):Play() task.delay(1,function() sFX:Stop() end) end) end task.delay(5.5,function() if not e:IsAlive() then return end if MG and MG.camShaker then MG.camShaker:ShakeOnce(13,13,8,5) end local aF,amb=root:FindFirstChild("AmbienceFar"),root:FindFirstChild("Ambience") if aF then aF:Stop() end if amb then amb.Volume=2 amb:Play() end local att=root:FindFirstChild("Attachment") if att then for _,p in ipairs(att:GetChildren()) do if p:IsA("ParticleEmitter") then p.Enabled=true end end end if root:FindFirstChild("Part") and root.Part:FindFirstChild("ParticleEmitter") then root.Part.ParticleEmitter.Enabled=true end ts:Create(c,TweenInfo.new(2,Enum.EasingStyle.Sine),{TintColor=Color3.fromRGB(80,90,200),Contrast=0.8}):Play() end) task.spawn(function() task.wait(6.5) while e:IsAlive() do task.wait(1) local char=game.Players.LocalPlayer.Character if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health>0 then local hL=false local cT=char:FindFirstChildOfClass("Tool") if cT and (cT.Name:lower():find("lighter") or cT.Name:lower():find("flashlight")) then hL=true end if not hL and not getgenv().CustomGodMode then char.Humanoid:TakeDamage(5) if char.Humanoid.Health<=0 then local f,sv,gi,to,gg,nx=nil,debug.setupvalue or setupvalue,debug.getinfo or getinfo,typeof,getgc,next for _,v in nx,gg(false) do if typeof(v)=="function" then local i=gi(v) if i.currentline==54 and i.nups==2 and i.is_vararg==0 then f=v break end end end sv(f,1,{"You froze to death.","Frostbite requires you to move fast.","Hold a lighter to stay warm!"}) sv(f,2,"Blue") firesignal(ReplicatedStorage.Bricks.DeathHint.OnClientEvent,{"You froze to death.","Frostbite requires you to move fast.","Hold a lighter to stay warm!"},"Blue") local GS=game.ReplicatedStorage:FindFirstChild("GameStats") if GS and GS:FindFirstChild("Player_"..game.Players.LocalPlayer.Name) then GS["Player_"..game.Players.LocalPlayer.Name].Total.DeathCause.Value="Frostbite" end end end end end end) local dC dC=game.ReplicatedStorage.GameData.LatestRoom.Changed:Connect(function(nR) if nR>lRV then if dC then dC:Disconnect() end e:Despawn() end end) end end) end)
        e:SetCallback("OnDespawning",function() pcall(function() local c=game:GetService("Lighting"):FindFirstChild("FrostbiteTint") if c then local tw=game:GetService("TweenService"):Create(c,TweenInfo.new(2,Enum.EasingStyle.Sine),{Contrast=0,TintColor=Color3.fromRGB(255,255,255)}) tw:Play() tw.Completed:Connect(function() c:Destroy() end) end local m=e.Model if m then local root=m:FindFirstChild("Part") or m:FindFirstChild("Main") or m.PrimaryPart if root then local att=root:FindFirstChild("Attachment") if att then for _,p in ipairs(att:GetChildren()) do if p:IsA("ParticleEmitter") then p.Enabled=false end end end if root:FindFirstChild("Part") and root.Part:FindFirstChild("ParticleEmitter") then root.Part.ParticleEmitter.Enabled=false end end for _,obj in ipairs(m:GetDescendants()) do if obj:IsA("Sound") then game:GetService("TweenService"):Create(obj,TweenInfo.new(2),{Volume=0}):Play() end end end end) end)
        e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) spawner:Run(e,false)
    end)()
end 
getgenv().SpawnEntity_Frostbite=SE_Frostbite

local function SE_Shocker()
    getgenv().SpawnStaticEntity({
        Name="Shocker",
        Asset="https://github.com/7dls-ui/test-hardcore-entities-hardcore-script/raw/refs/heads/main/Hardcore/ShockerStanding.rbxm",
        HeightOffset=2.5,
        SpawnLocation="FrontOfPlayer",
        FrontOffset=math.random(5,10),
        DespawnOnNextRoom=true,
        OnSpawned=function(m,dF)
            getgenv().ActiveCustomEntities = getgenv().ActiveCustomEntities + 1
            local s = Instance.new("Sound")
            s.SoundId = "rbxassetid://9059632426"
            s.Parent = m.PrimaryPart
            s.Volume = 2
            s.Looped = true
            s.RollOffMaxDistance = 100
            s:Play()
            
            local iA, sT, hA = true, 0, false
            local function iL(tP) 
                local cam = workspace.CurrentCamera 
                local v = tP.Position - cam.CFrame.Position 
                local d = cam.CFrame.LookVector:Dot(v.Unit) 
                if d > 0.7 then 
                    local rp = RaycastParams.new() 
                    rp.FilterDescendantsInstances = {game.Players.LocalPlayer.Character, m}
                    rp.FilterType = Enum.RaycastFilterType.Exclude 
                    if not workspace:Raycast(cam.CFrame.Position, v, rp) then return true end 
                end 
                return false 
            end
            
            local cn 
            cn = game:GetService("RunService").RenderStepped:Connect(function(dt)
                if not m.Parent or not iA or hA then if cn then cn:Disconnect() end return end
                if iL(m.PrimaryPart) then 
                    sT = sT + dt 
                    if sT >= 2.0 then 
                        hA = true 
                        local c = game.Players.LocalPlayer.Character 
                        if c and c:FindFirstChild("HumanoidRootPart") then 
                            local targetPos = c.HumanoidRootPart.Position + Vector3.new(0, 2.5, 0)
                            local tween = game:GetService("TweenService"):Create(m.PrimaryPart, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(targetPos)})
                            tween:Play()
                            tween.Completed:Wait()
                            if c:FindFirstChild("Humanoid") then c.Humanoid:TakeDamage(40) end
                        end 
                        dF() 
                    end 
                else 
                    dF() 
                end
            end)
        end,
        OnDespawning=function(m)
            getgenv().ActiveCustomEntities = math.max(0, getgenv().ActiveCustomEntities - 1)
            local sCF = m:GetPivot()
            local eCF = m:GetPivot() * CFrame.new(0, -16, 0)
            task.spawn(function() 
                local el, dur, c = 0, 0.75, nil 
                c = game:GetService("RunService").Heartbeat:Connect(function(dt) 
                    el = el + dt 
                    local a = math.min(el / dur, 1) 
                    if m.Parent then m:PivotTo(sCF:Lerp(eCF, a)) end 
                    if a >= 1 then c:Disconnect() end 
                end) 
            end)
            for _, o in ipairs(m:GetDescendants()) do 
                if o:IsA("Sound") then game:GetService("TweenService"):Create(o, TweenInfo.new(0.75), {Volume = 0}):Play() 
                elseif o:IsA("BasePart") then game:GetService("TweenService"):Create(o, TweenInfo.new(0.75), {Transparency = 1}):Play() end 
            end
        end, 
        DespawnDelay=0.75
    })
end 
getgenv().SpawnEntity_Shocker=SE_Shocker

local SpC={
    {Entity=SE_Cease,Chance=15}, {Entity=SE_Ripper,Chance=15}, {Entity=SE_Depth,Chance=15}, {Entity=SE_Silence,Chance=7.5},
    {Entity=SE_Rebound,Chance=12}, {Entity=SE_DeerGod,Chance=8}, {Entity=SE_A200,Chance=2}, {Entity=SE_Matcher,Chance=5},
    {Entity=SE_A60,Chance=1}
}
local ECR,LRGS,NRI,TE,NTI,LSE,PDRC,PES=0,10,math.random(7,10),0,math.random(90,180),nil,20,0

local function CanSpawnEntity() 
    if getgenv().death then return false end 
    local lR=ReplicatedStorage.GameData.LatestRoom.Value 
    local pR=Players.LocalPlayer:GetAttribute("CurrentRoom") or lR 
    if lR<2 or lR>=99 or ECR>=1 or IsSafeRoom(lR) or IsSafeRoom(pR) then return false end 
    local rI=workspace.CurrentRooms:FindFirstChild(tostring(lR)) 
    if rI then 
        if rI:GetAttribute("IsDark")==true or rI:GetAttribute("RequiresLight")==true then return false end 
        local wC=0 
        for _,v in ipairs(rI:GetDescendants()) do 
            if v:IsA("Model") and (v.Name=="Wardrobe" or v.Name=="Toolshed") then wC=wC+1 end 
        end 
        if wC<1 and math.random(1,100)>10 then return false end 
    end return true 
end

local function TriggerEntitySpawn(r,iTS) 
    if not CanSpawnEntity() then return false end 
    ECR = ECR + 1 
    local tW = 0 
    for _,v in ipairs(SpC) do tW = tW + v.Chance end 
    local s 
    repeat 
        local rnd, cm = math.random() * tW, 0 
        for _,v in ipairs(SpC) do 
            cm = cm + v.Chance 
            if rnd <= cm then s = v.Entity break end 
        end 
    until s ~= LSE 
    LSE = s 
    getgenv().ActiveCustomEntities = getgenv().ActiveCustomEntities + 1 
    if iTS then TE, NTI = 0, math.random(90, 180) end 
    coroutine.wrap(s)() 
    return true 
end

ReplicatedStorage.GameData.LatestRoom.Changed:Connect(function(nR)
    if getgenv().death then return end 
    ECR = 0
    if PES > 0 and CanSpawnEntity() then 
        task.spawn(function() 
            task.wait(2) 
            if not getgenv().death and CanSpawnEntity() then TriggerEntitySpawn("Pending",false) PES=0 end 
        end) 
    end
    if TE >= NTI and CanSpawnEntity() then TriggerEntitySpawn("Timer",true) end
    if not CanSpawnEntity() then return end
    if nR > 2 and math.random(1,100) <= 5 then getgenv().ActiveCustomEntities=getgenv().ActiveCustomEntities+1 coroutine.wrap(SE_Frostbite)() end
    if nR < 2 then return 
    elseif nR >= 2 and nR < 10 then 
        if math.random(1,100) <= 10 then if not TriggerEntitySpawn("Pre10",false) then PES=math.min(1,PES+1) end end 
    elseif nR == 10 then 
        if not TriggerEntitySpawn("Door10",false) then PES=math.min(1,PES+1) end LRGS,NRI=nR,math.random(7,10) 
    elseif nR > 10 then 
        if nR >= LRGS + NRI then 
            if not TriggerEntitySpawn("Interval",false) then PES=math.min(1,PES+1) end LRGS,NRI=nR,math.random(7,10) 
        else 
            if math.random(1,100) <= PDRC then if not TriggerEntitySpawn("Random",false) then PES=math.min(1,PES+1) end end 
        end 
    end
end)

task.spawn(function() 
    while not getgenv().death do 
        task.wait(1) 
        local lR=ReplicatedStorage.GameData.LatestRoom.Value 
        if lR>=99 then continue end 
        if lR>=5 then 
            TE=TE+1 
            if TE>=NTI then 
                if not TriggerEntitySpawn("Timer",true) then PES=math.min(1,PES+1) TE=TE-5 end 
            end 
        end 
    end 
end)

task.spawn(function()
    while not getgenv().death do
        task.wait(math.random(60, 180))
        if getgenv().death then break end
        local lR = ReplicatedStorage.GameData.LatestRoom.Value
        local pR = Players.LocalPlayer:GetAttribute("CurrentRoom") or lR
        if lR >= 2 and lR < 99 and not IsSafeRoom(lR) and not IsSafeRoom(pR) then
            coroutine.wrap(SE_Shocker)()
        end
    end
end)
