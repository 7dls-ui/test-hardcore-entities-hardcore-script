print(os.date("%B")) print("Loading Hardcore Mode with True Sound FX Engine...")
local tween,ReplicatedStorage,Players,Workspace,RS,UIS,PathfindingService=game:GetService("TweenService"),game:GetService("ReplicatedStorage"),game:GetService("Players"),game:GetService("Workspace"),game:GetService("RunService"),game:GetService("UserInputService"),game:GetService("PathfindingService")
if ReplicatedStorage:FindFirstChild("Extacuted") then warn("You have Already Loaded") return false end
local Test=Instance.new("Part") Test.Name="Extacuted" Test.Parent=ReplicatedStorage
pcall(function() if not ReplicatedStorage:FindFirstChild("RemotesFolder") then local fR=Instance.new("Folder") fR.Name="RemotesFolder" fR.Parent=ReplicatedStorage local fH=Instance.new("RemoteEvent") fH.Name="DeathHint" fH.Parent=fR end end)
getgenv().ActiveCustomEntities=0 getgenv().CustomGodMode=false
RS.RenderStepped:Connect(function() if getgenv().ActiveCustomEntities>0 then local s=Workspace.CurrentCamera:FindFirstChild("Screech") if s then s:Destroy() end end end)

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
    if not s_sprint then warn("[Hardcore Mode] Sprint/UI Setup Error:\n" .. tostring(err_sprint)) end
end)

getgenv().death=false local function BDT(c) c:WaitForChild("Humanoid").Died:Connect(function() getgenv().death=true end) end if Players.LocalPlayer.Character then BDT(Players.LocalPlayer.Character) end Players.LocalPlayer.CharacterAdded:Connect(BDT)

local function IPS(c,eM)
    if c:GetAttribute("Hiding")==true then return true end
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

local function ASK(eM,kR,dH,aC,rM)
    local cn cn=RS.Heartbeat:Connect(function()
        if getgenv().death or not eM.Parent then if cn then cn:Disconnect() end return end
        local c=Players.LocalPlayer.Character if c and c:FindFirstChild("Head") and c:FindFirstChild("Humanoid") then
            local h=c.Humanoid if h.Health>0 then
                local rt=eM:IsA("Model") and (eM.PrimaryPart or eM:FindFirstChildWhichIsA("BasePart",true)) or eM
                if (c.Head.Position-rt.Position).Magnitude<=kR and (not rM or h.MoveDirection.Magnitude>0) and not getgenv().CustomGodMode then
                    if not IPS(c,eM) then
                        getgenv().death=true if cn then cn:Disconnect() end if aC then pcall(aC) end
                        pcall(function() local f,sv,gi,to,gg,nx=nil,debug.setupvalue or setupvalue,debug.getinfo or getinfo,typeof,getgc,next for _,v in nx,gg(false) do if to(v)=="function" then local i=gi(v) if i.currentline==54 and i.nups==2 and i.is_vararg==0 then f=v break end end end sv(f,1,dH);sv(f,2,"Blue") firesignal(ReplicatedStorage.Bricks.DeathHint.OnClientEvent,dH,"Blue") end)
                        h.Health=0
                    end
                end
            end
        end
    end)
end

task.spawn(function()
    local s_ui, err_ui = xpcall(function()
        local function _loadKavo()
            local ok, lib = pcall(function()
                if isfile and readfile and isfile("Hardcore/KavoUI_MacNight.luau") then
                    return loadstring(readfile("Hardcore/KavoUI_MacNight.luau"))()
                end
                return loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
            end)
            if ok and lib then
                return lib
            end
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
        end

        local L=_loadKavo()
        local W=L.CreateLib("Hardcore Spawner","MacNight")
        local function cW(f) if typeof(f)=="function" then coroutine.wrap(f)() else warn("[Hardcore Mode] Function not found. Wait until you open Door 1.") end end

        local HT=W:NewTab("Hardcore Entities")
        local HS=HT:NewSection("Manual Presets")
        HS:NewButton("Spawn Depth","Spawns Depth instantly",function() cW(getgenv().SpawnEntity_Depth) end)
        HS:NewButton("Spawn Blitz","Spawns Blitz instantly",function() cW(getgenv().SpawnEntity_Blitz) end)
        HS:NewButton("Spawn Ripper","Spawns Ripper instantly",function() cW(getgenv().SpawnEntity_Ripper) end)
        HS:NewButton("Spawn A-200","Spawns A-200 instantly",function() cW(getgenv().SpawnEntity_A200) end)
        HS:NewButton("Spawn Trollface","Spawns Trollface instantly",function() cW(getgenv().SpawnEntity_Trollface) end)
        HS:NewButton("Spawn A-60","Spawns A-60 instantly",function() cW(getgenv().SpawnEntity_A60) end)
        HS:NewButton("Spawn Silence","Spawns Silence instantly",function() cW(getgenv().SpawnEntity_Silence) end)
        HS:NewButton("Spawn Cease","Spawns Cease instantly",function() cW(getgenv().SpawnEntity_Cease) end)
        HS:NewButton("Revive","Revives you to test more",function() pcall(function() getgenv().death=false game.ReplicatedStorage.Bricks.Revive:FireServer() end) end)
        HS:NewToggle("God-Mode (Custom Entities)","Grants immunity.",function(s) getgenv().CustomGodMode=s end)

        local NET=W:NewTab("Normal Entities")
        local NES=NET:NewSection("Manual Presets")
        NES:NewButton("Spawn Ambush", "Spawns Ambush instantly", function() cW(getgenv().SpawnEntity_Ambush) end)

        local SHT=W:NewTab("SUPER HARD MODE entities")
        local SHS=SHT:NewSection("Super Hard Presets")
        SHS:NewButton("Spawn scary red face","Spawns scary red face instantly",function() cW(getgenv().SpawnEntity_ScaryRedFace1) end)
        SHS:NewButton("Spawn Scary Red Face","Spawns Scary Red Face instantly",function() cW(getgenv().SpawnEntity_ScaryRedFace2) end)
        SHS:NewButton("Spawn Nacho Varga","Spawns Nacho Varga instantly",function() cW(getgenv().SpawnEntity_NachoVarga) end)
        SHS:NewButton("Spawn DEPTH","Spawns DEPTH instantly",function() cW(getgenv().SpawnEntity_DEPTH_SHM) end)
        SHS:NewButton("Spawn Bald Kreek","Spawns Bald Kreek instantly",function() cW(getgenv().SpawnEntity_BaldKreek) end)
        SHS:NewButton("Spawn rahh!!!","Spawns rahh!!! instantly",function() cW(getgenv()["SpawnEntity_rahh!!!"]) end)
        SHS:NewButton("Spawn FREE ROBLOXIAN OUTFIT","Spawns FREE ROBLOXIAN OUTFIT instantly",function() cW(getgenv()["SpawnEntity_FREE ROBLOXIAN OUTFIT"]) end)

        local ST=W:NewTab("Settings") local SS=ST:NewSection("UI Settings") SS:NewKeybind("Toggle UI Key","Press [",Enum.KeyCode.LeftBracket,function() L:ToggleUI() end)
    end, function(e) return debug.traceback(e) end)
    if not s_ui then warn("[Hardcore Mode] Hardcore Spawner UI Error:\n" .. tostring(err_ui)) end
end)

local spawner=nil task.spawn(function()
    local mU=Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainUI",999999) if not mU then return end
    local s_eng, err_eng = xpcall(function()
        spawner=(function()
            (function() local M={} M.LoadCustomAsset=function(u) if getcustomasset then if u:lower():sub(1,4)=="http" then local f=`temp_{tick()}.txt` local _,r=pcall(function() writefile(f,game:HttpGet(u)) return getcustomasset(f,true) end) if isfile(f) then delfile(f) end return r elseif isfile(u) then return getcustomasset(u,true) end end if u:find("rbxassetid") or tonumber(u) then return "rbxassetid://"..u:match("%d+") end return nil end M.LoadCustomInstance=function(u) local s,r=pcall(function() return game:GetObjects(M.LoadCustomAsset(u))[1] end) return s and r or nil end for n,f in next,M do if typeof(f)=="function" then getgenv()[n]=f end end end)()
            local Rm,CR=ReplicatedStorage:WaitForChild("RemotesFolder"),workspace:WaitForChild("CurrentRooms")

            local mE,mG,mQ
            local s1,e1=pcall(function() mE=require((ReplicatedStorage:FindFirstChild("ClientModules") or ReplicatedStorage:FindFirstChild("ModulesClient")):WaitForChild("Module_Events",3)) end)
            if not s1 then warn("[Hardcore Mode] Warning: Module_Events failed to load. " .. tostring(e1)) end
            local s2,e2=pcall(function() mG=require(Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game) end)
            if not s2 then warn("[Hardcore Mode] Warning: Main_Game failed to load. " .. tostring(e2)) end
            local s3,e3=pcall(function() mQ=require(Rm.RequestAsset:InvokeServer("Earthquake")) end)
            if not s3 then warn("[Hardcore Mode] Warning: Earthquake failed to load. " .. tostring(e3)) end

            local Mods={Module_Events=mE,Main_Game=mG,Earthquake=mQ} local CT={BASE_ENTITY_SPEED=65,ATTR={ENTITY={Running=false,Paused=false,Despawning=false,LastEnteredRoom=-1}}} local M={ActiveEntities={}}
            local function cT(t) local n={} for k,v in next,t do n[k]=typeof(v)=="table" and cT(v) or v end return n end
            local function GCR(l) return l and CR:GetChildren()[#CR:GetChildren()] or CR:FindFirstChild(Players.LocalPlayer:GetAttribute("CurrentRoom")) end

            local function GetSortedRooms()
                local r = CR:GetChildren() local validRooms = {}
                for _, v in ipairs(r) do if tonumber(v.Name) then table.insert(validRooms, v) end end
                table.sort(validRooms, function(a, b) return tonumber(a.Name) < tonumber(b.Name) end)
                return validRooms
            end

            local function GRAP(v) local w={} for _,r in next,CR:GetChildren() do local p=r:FindFirstChild(r.Name) if p then w[#w+1]=p end end if #w>0 then local p=RaycastParams.new() p.FilterType,p.FilterDescendantsInstances,p.CollisionGroup=Enum.RaycastFilterType.Include,w,"BaseCheck" local res=workspace:Raycast(v,Vector3.new(0,-100,0),p) if res then for _,r in next,CR:GetChildren() do if res.Instance.Parent==r then return r end end end end return nil end
            local function FRL(rm) local re=rm:FindFirstChild("RoomEntrance") if not re then return end if Mods.Module_Events then Mods.Module_Events.toggle(rm,true,{}) end local rd=Random.new(tick()) for _,v in next,rm:GetDescendants() do if v:IsA("Model") and (v.Name=="LightStand" or v.Name=="Chandelier") and v:GetAttribute("Shattered") then task.delay((re.Position-v.PrimaryPart.Position).Magnitude/150+rd:NextInteger(-10,10)/50,function() local r2=rd:NextInteger(5,20)/100 local nn=v:FindFirstChild("Neon",true) for _,d in next,v:GetDescendants() do if d:IsA("Light") then tween:Create(d,TweenInfo.new(r2),{Brightness=d:GetAttribute("OGBrightness")}):Play() elseif d:IsA("Sound") then tween:Create(d,TweenInfo.new(r2),{Volume=d:GetAttribute("OGVolume")}):Play() end end if nn then nn.Transparency=0.9 nn.Material=Enum.Material.Neon tween:Create(nn,TweenInfo.new(r2),{Transparency=0.2}):Play() end v:SetAttribute("Shattered",nil) end) end end end

            local function PreCalculatePath(startPos, endPos)
                local disabledDoors = {}
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():match("door") or obj.Name:lower():match("gate") or obj.Name:lower():match("hidden")) then
                        if obj.CanCollide then
                            obj.CanCollide = false
                            table.insert(disabledDoors, obj)
                        end
                    end
                end
                local path = PathfindingService:CreatePath({AgentRadius = 2,AgentHeight = 5,AgentCanJump = false,WaypointSpacing = 3})
                local success = pcall(function() path:ComputeAsync(startPos, endPos) end)
                for _, obj in ipairs(disabledDoors) do obj.CanCollide = true end
                local wps = {}
                if success and path.Status == Enum.PathStatus.Success then
                    for _, wp in ipairs(path:GetWaypoints()) do table.insert(wps, CFrame.new(wp.Position)) end
                else
                    table.insert(wps, CFrame.new(startPos)) table.insert(wps, CFrame.new(endPos))
                end
                return wps
            end

            local function GPA_PreCalc(cf)
                local rooms = GetSortedRooms()
                if #rooms == 0 then return {} end
                local masterWaypoints = {}
                local latestRoomVal = ReplicatedStorage.GameData.LatestRoom.Value
                local endIdx = 1
                for i, r in ipairs(rooms) do endIdx = i if tonumber(r.Name) == latestRoomVal then break end end

                if cf.Movement.Reversed then
                    for i = endIdx, 1, -1 do
                        local rm = rooms[i]
                        local rx = rm:FindFirstChild("RoomExit") or rm:FindFirstChild("RoomEntrance")
                        local re = rm:FindFirstChild("RoomEntrance") or rm:FindFirstChild("RoomExit")
                        if rx and re then local wps = PreCalculatePath(rx.Position, re.Position) for _, w in ipairs(wps) do table.insert(masterWaypoints, w) end end
                    end
                else
                    for i = 1, endIdx do
                        local rm = rooms[i]
                        local re = rm:FindFirstChild("RoomEntrance") or rm:FindFirstChild("RoomExit")
                        local rx = rm:FindFirstChild("RoomExit") or rm:FindFirstChild("RoomEntrance")
                        if re and rx then local wps = PreCalculatePath(re.Position, rx.Position) for _, w in ipairs(wps) do table.insert(masterWaypoints, w) end end
                    end
                end
                return masterWaypoints
            end

            local function EMT_PreCalc(m, waypoints, sp, ho, nho)
                local rW = false
                for idx, wpCFrame in ipairs(waypoints) do
                    local targetPos = wpCFrame.Position + Vector3.new(0, 4.5 + (ho or 0), 0)
                    local nodeReached = false
                    local cn
                    cn = RS.Stepped:Connect(function(_, step)
                        if m.Parent == nil then cn:Disconnect() rW=true return end
                        if not m:GetAttribute("Paused") then
                            local cp = m:GetPivot().Position
                            local diff = targetPos - cp
                            local dist = diff.Magnitude
                            if dist > 1.5 then
                                local moveDir = diff.Unit
                                local actualSpeed = step * sp

                                local nextPos = cp + (moveDir * actualSpeed)
                                local flatLook = Vector3.new(moveDir.X, 0, moveDir.Z)
                                if flatLook.Magnitude > 0.001 then m:PivotTo(CFrame.new(nextPos, nextPos + flatLook)) else m:PivotTo(CFrame.new(nextPos)) end
                            else cn:Disconnect() nodeReached = true end
                        end
                    end)
                    repeat RS.Stepped:Wait() until nodeReached or rW
                    if rW then break end
                end
            end

            M.Create=function(s,cf)
                local nc=cT(cf) nc.Movement.Speed=CT.BASE_ENTITY_SPEED/100*cf.Movement.Speed local i
                if nc.Entity.Is2D then
                    i=Instance.new("Model") i.Name=nc.Entity.Name or "2DEntity" local r=Instance.new("Part",i) r.Name="Main" r.Size=Vector3.new(2,5,2) r.Transparency=1 r.CanCollide=false r.Anchored=true i.PrimaryPart=r local b=Instance.new("BillboardGui",r) b.Name="Sprite" b.Size=UDim2.new(8,0,8,0) b.AlwaysOnTop=true b.LightInfluence=0 b.MaxDistance=3000 b.Adornee=r local img=Instance.new("ImageLabel",b) img.Size=UDim2.new(1,0,1,0) img.BackgroundTransparency=1 img.ScaleType=Enum.ScaleType.Fit local ast=tostring(nc.Entity.Asset) if tonumber(ast) then ast="rbxassetid://"..ast end img.Image=ast
                else
                    if typeof(nc.Entity.Asset) == "Instance" then
                        i = nc.Entity.Asset:Clone()
                    else
                        local suc, res = pcall(function() return LoadCustomInstance(nc.Entity.Asset) end)
                        i = suc and res or nil
                    end
                end

                local rt = (i and i:IsA("Model") and i.PrimaryPart) or (i and i:FindFirstChildWhichIsA("BasePart",true)) or (i and i:IsA("BasePart") and i)
                if not rt then
                    warn("[Hardcore Mode] CRITICAL ERROR: Asset ID " .. tostring(nc.Entity.Asset) .. " failed to load or resolve a PrimaryPart.")
                    return nil
                end

                if not i:IsA("Model") then
                    local wrp = Instance.new("Model")
                    i.Parent = wrp
                    i = wrp
                end

                if not i then return end

                for _,v in next,i:GetDescendants() do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                        v.Anchored = true
                    end
                end

                rt.Anchored=true i.PrimaryPart=rt i.Name=nc.Entity.Name or i.Name for a,v in next,CT.ATTR.ENTITY do i:SetAttribute(a,v) end local c=Instance.new("Configuration",i) c.Name="RoomsEntered" return {Model=i,Config=nc,Debug=cf.Debug or {},SetCallback=function(ss,k,cb) ss.Debug[k]=cb end,RunCallback=function(ss,k,...) if typeof(ss.Debug[k])=="function" then pcall(ss.Debug[k],...) end end,IsAlive=function(ss) return ss.Model and ss.Model.Parent end,Run=function(ss,cE) M:Run(ss,cE) end,Despawn=function(ss) if ss:IsAlive() then ss.Model:Destroy() local id=table.find(M.ActiveEntities,ss) if id then table.remove(M.ActiveEntities,id) end task.spawn(ss.RunCallback,ss,"OnDespawned") end end}
            end

            M.Run=function(s,e,c)
                if c then s:Run(cT(e),false) return end if e.Model:GetAttribute("Running") then return end
                local m,cf=e.Model,e.Config m:SetAttribute("Running",true) s.ActiveEntities[#s.ActiveEntities+1]=e

                local r=GetSortedRooms() local sp=cf.Movement.Reversed and r[#r]:FindFirstChild("RoomExit") or r[1]:FindFirstChild("RoomEntrance")
                local rt = m:FindFirstChild("Main") or (m:IsA("Model") and m.PrimaryPart) or m:FindFirstChildWhichIsA("BasePart", true) or (m:IsA("BasePart") and m)

                local globalSounds = {}
                local despawnConfigs = {}
                local soundsToStart = {}
                local AUDIO_DEBUG = (getgenv and getgenv().HardcoreAudioDebug) == true
                local function _audioLog(msg)
                    if AUDIO_DEBUG then warn("[Hardcore Audio] " .. tostring(msg)) end
                end

                local function _clamp(n, mn, mx)
                    if type(n) ~= "number" then return n end
                    if n < mn then return mn end
                    if n > mx then return mx end
                    return n
                end

                local function _coerceAssetId(id)
                    if id == nil then return nil end
                    if typeof(id) == "number" then return "rbxassetid://" .. tostring(id) end
                    id = tostring(id)
                    if tonumber(id) then return "rbxassetid://" .. id end
                    return id
                end

                local function _applyEffects(sound, effects)
                    if typeof(effects) ~= "table" then return end
                    for fxName, fxCfg in pairs(effects) do
                        if typeof(fxCfg) == "table" then
                            local className = fxCfg.ClassName
                            if typeof(className) == "string" and className ~= "" then
                                local ok, fx = pcall(function() return Instance.new(className) end)
                                if ok and fx then
                                    fx.Name = tostring(fxName)
                                    fx.Parent = sound
                                    for k, v in pairs(fxCfg) do
                                        if k ~= "ClassName" then
                                            local val = v
                                            if type(v) == "number" then
                                                -- Clamp common SoundEffect ranges to avoid runtime errors on bad configs.
                                                if className == "ReverbSoundEffect" then
                                                    if k == "DecayTime" then val = _clamp(v, 0.1, 20)
                                                    elseif k == "Density" or k == "Diffusion" then val = _clamp(v, 0, 1)
                                                    elseif k == "DryLevel" or k == "WetLevel" then val = _clamp(v, -80, 10) end
                                                elseif className == "DistortionSoundEffect" and k == "Level" then
                                                    val = _clamp(v, 0, 1)
                                                elseif className == "PitchShiftSoundEffect" and k == "Octave" then
                                                    val = _clamp(v, 0.5, 2)
                                                end
                                            end
                                            local okSet, setErr = pcall(function() fx[k] = val end)
                                            if not okSet then
                                                _audioLog("Failed to set " .. className .. "." .. tostring(k) .. " = " .. tostring(val) .. " (" .. tostring(setErr) .. ")")
                                            end
                                        end
                                    end
                                    local okEn, enErr = pcall(function() fx.Enabled = true end)
                                    if not okEn then
                                        _audioLog("Failed to enable " .. className .. " (" .. tostring(enErr) .. ")")
                                    end
                                else
                                    _audioLog("Failed to create SoundEffect " .. tostring(className))
                                end
                            end
                        end
                    end
                end

                -- ============================================= --
                -- SMART SOUND FX ENGINE
                -- ============================================= --
                if cf.Sounds then
                    -- Nuke native model sounds entirely so they never accidentally play
                    for _,o in ipairs(m:GetDescendants()) do if o:IsA("Sound") then o:Destroy() end end

                    if rt then
                        for sN, sD in pairs(cf.Sounds) do
                            local isDespawn = sD.PlayOnDespawn or sN:lower():find("despawn") or sN:lower():find("end")

                            if isDespawn then
                                table.insert(despawnConfigs, {Name = sN, Config = sD})
                            else
                                local snd = Instance.new("Sound")
                                snd.Name = sN
                                snd.SoundId = _coerceAssetId(sD.SoundId)
                                snd.PlaybackSpeed = sD.PlaybackSpeed or 1
                                snd.RollOffMinDistance = sD.RollOffMinDistance or 10
                                snd.RollOffMaxDistance = sD.RollOffMaxDistance or 1500
                                snd.RollOffMode = Enum.RollOffMode.InverseTapered
                                snd.Looped = sD.Looped
                                if snd.Looped == nil then snd.Looped = true end

                                snd.Volume = 0

                                -- 1. PARENT THE SOUND FIRST
                                if sD.Global then
                                    snd.Parent = game:GetService("SoundService")
                                    -- Only keep looped global sounds for fade-out on despawn.
                                    if snd.Looped then table.insert(globalSounds, snd) end
                                else
                                    snd.Parent = rt
                                end

                                -- 2. START AFTER MODEL IS IN WORKSPACE (ensures SoundEffects apply consistently)
                                table.insert(soundsToStart, {Sound = snd, Config = sD})
                            end
                        end
                    end
                else
                    for _,o in ipairs(m:GetDescendants()) do
                        if o:IsA("Sound") then
                            local n = o.Name:lower()
                            if n:find("start") or n:find("end") or n:find("arrival") or n:find("despawn") or n:find("scream") then
                                o.Playing = false o.Volume = 0 o:Stop()
                            else
                                if n == "farsound" then o.RollOffMinDistance = 10; o.RollOffMaxDistance = 1500; o.RollOffMode = Enum.RollOffMode.InverseTapered
                                elseif n == "nearsound" then o.RollOffMinDistance = 5; o.RollOffMaxDistance = 75; o.RollOffMode = Enum.RollOffMode.InverseTapered end
                                local tv=o.Volume; o.Volume=0
                                table.insert(soundsToStart, {Sound = o, TargetVolume = tv})
                            end
                        end
                    end
                end

                -- Drop entity into map AFTER sounds are fully built and FX are applied
                m:PivotTo(sp.CFrame+Vector3.new(0,cf.Entity.HeightOffset,0))
                m.Parent=workspace

                -- Start queued sounds now that the model is in Workspace.
                for _, entry in ipairs(soundsToStart) do
                    local snd = entry.Sound
                    if snd and snd.Parent then
                        if entry.Config and entry.Config.Effects then
                            -- Ensure a clean slate and attach effects only when the Sound is already in the DataModel.
                            for _, ch in ipairs(snd:GetChildren()) do
                                if ch:IsA("SoundEffect") then ch:Destroy() end
                            end
                            _applyEffects(snd, entry.Config.Effects)
                            if AUDIO_DEBUG then
                                local c = 0
                                for _, ch in ipairs(snd:GetChildren()) do if ch:IsA("SoundEffect") then c += 1 end end
                                _audioLog("Attached " .. tostring(c) .. " effect(s) to sound '" .. tostring(snd.Name) .. "'")
                            end
                        end
                        pcall(function()
                            if not snd.IsPlaying then snd:Play() end
                        end)
                        if entry.Config then
                            if not snd.Looped then snd.Ended:Connect(function() pcall(function() snd:Destroy() end) end) end
                            tween:Create(snd, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Volume = entry.Config.Volume or 1}):Play()
                        else
                            tween:Create(snd, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Volume = entry.TargetVolume or 1}):Play()
                        end
                    end
                end

                task.spawn(e.RunCallback,e,"OnSpawned")
                local cR=GCR(false)
                if cR then if cf.Lights.Flicker.Enabled and Mods.Module_Events then Mods.Module_Events.flicker(cR,cf.Lights.Flicker.Duration) end if cf.Earthquake.Enabled and Mods.Earthquake then task.defer(Mods.Earthquake,Mods.Main_Game,cR) end end
                task.wait(cf.Movement.Delay)
                task.spawn(e.RunCallback,e,"OnStartMoving")

                task.spawn(function() while e:IsAlive() and task.wait() do if m:GetAttribute("Paused") then continue end local o,co=m:GetPivot().Position,Players.LocalPlayer.Character.PrimaryPart.Position local rm=GRAP(o) if rm then local id=tonumber(rm.Name) if id and id>=0 and id~=m:GetAttribute("LastEnteredRoom") then m:SetAttribute("LastEnteredRoom",id) local re=m:FindFirstChild("RoomsEntered") if re then local ft=re:GetAttribute(rm.Name)==nil task.spawn(e.RunCallback,e,"OnEnterRoom",rm,ft) if ft then re:SetAttribute(rm.Name,true) end
                    local lR = ReplicatedStorage.GameData.LatestRoom.Value if cf.Lights.Shatter and Mods.Module_Events and id<=lR then Mods.Module_Events.shatter(rm) elseif cf.Lights.Repair and id<=lR then FRL(rm) end
                end end end local cs=cf.CameraShake if cs.Enabled and Mods.Main_Game.camShaker then local mg=(co-o).Magnitude if mg<=cs.Range then Mods.Main_Game.camShaker:ShakeOnce(cs.Values[1]/cs.Range*(cs.Range-mg),cs.Values[2]/cs.Range*(cs.Range-mg),cs.Values[3],cs.Values[4]) end end end end)

                task.spawn(function()
                    local rtType=cf.Rebounding.Type:upper()

                    if rtType=="AMBUSH" or rtType=="LEGACY AMBUSH" then
                        local pathfindNodes = GPA_PreCalc(cf)
                        EMT_PreCalc(m, pathfindNodes, cf.Movement.Speed, cf.Entity.HeightOffset, cf.Entity.NavMeshHeightOffset)

                        if cf.Rebounding.Enabled then
                            local reboundsCount = math.random(cf.Rebounding.Min, cf.Rebounding.Max)
                            for i = 1, reboundsCount do
                                task.wait(cf.Rebounding.Delay)
                                m:SetAttribute("Damage", true)
                                task.spawn(e.RunCallback, e, "OnRebounding", true)

                                local backwardNodes = {}
                                for j = #pathfindNodes, 1, -1 do
                                    table.insert(backwardNodes, pathfindNodes[j])
                                end
                                EMT_PreCalc(m, backwardNodes, cf.Movement.Speed, cf.Entity.HeightOffset, cf.Entity.NavMeshHeightOffset)

                                task.spawn(e.RunCallback, e, "OnRebounding", false)
                                task.wait(cf.Rebounding.Delay)
                                m:SetAttribute("Damage", true)
                                task.spawn(e.RunCallback, e, "OnRebounding", true)

                                pathfindNodes = GPA_PreCalc(cf)
                                EMT_PreCalc(m, pathfindNodes, cf.Movement.Speed, cf.Entity.HeightOffset, cf.Entity.NavMeshHeightOffset)

                                task.spawn(e.RunCallback, e, "OnRebounding", false)
                                if i < reboundsCount then
                                    task.wait(cf.Rebounding.Delay)
                                end
                            end
                        end

                    elseif rtType=="BLITZ" then
                        local pathfindNodes = GPA_PreCalc(cf)
                        local pRoomStr = tostring(Players.LocalPlayer:GetAttribute("CurrentRoom") or 0)

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
                                for i = #roomNodes, randIdx, -1 do
                                    table.insert(backWp, roomNodes[i])
                                end
                                EMT_PreCalc(m, backWp, cf.Movement.Speed, cf.Entity.HeightOffset, cf.Entity.NavMeshHeightOffset)

                                task.wait(cf.Rebounding.Delay)
                                m:SetAttribute("Damage", true)
                                task.spawn(e.RunCallback, e, "OnRebounding", false)

                                local fwdWp = {}
                                for i = randIdx, #roomNodes do
                                    table.insert(fwdWp, roomNodes[i])
                                end
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
                            elseif foundCurrentAgain and checkRoom and checkRoom.Name ~= pRoomStr then
                                table.insert(updatedToEnd, wp)
                            end
                        end

                        if #updatedToEnd > 0 then
                            EMT_PreCalc(m, updatedToEnd, cf.Movement.Speed, cf.Entity.HeightOffset, cf.Entity.NavMeshHeightOffset)
                        elseif #nodesToEnd > 0 then
                            EMT_PreCalc(m, nodesToEnd, cf.Movement.Speed, cf.Entity.HeightOffset, cf.Entity.NavMeshHeightOffset)
                        end
                    end

                    if not m:GetAttribute("Despawning") then
                        m:SetAttribute("Despawning",true)
                        task.spawn(e.RunCallback,e,"OnDespawning")

                        -- Execute Despawn Sounds Dynamically
                        for _, dC in ipairs(despawnConfigs) do
                            local sD = dC.Config
                            local snd = Instance.new("Sound")
                            snd.Name = dC.Name
                            snd.SoundId = _coerceAssetId(sD.SoundId)
                            snd.Volume = sD.Volume or 1
                            snd.PlaybackSpeed = sD.PlaybackSpeed or 1
                            snd.RollOffMinDistance = sD.RollOffMinDistance or 10
                            snd.RollOffMaxDistance = sD.RollOffMaxDistance or 1500
                            snd.RollOffMode = Enum.RollOffMode.InverseTapered
                            snd.Looped = sD.Looped or false

                            -- 1. Parent FIRST
                            if sD.Global then
                                snd.Parent = game:GetService("SoundService")
                            else
                                local soundPart = Instance.new("Part")
                                soundPart.Transparency = 1; soundPart.CanCollide = false; soundPart.Anchored = true
                                soundPart.Position = m:GetPivot().Position; soundPart.Parent = workspace
                                snd.Parent = soundPart
                                game.Debris:AddItem(soundPart, 10)
                            end

                            -- 2. Attach Effects AFTER
                            _applyEffects(snd, sD.Effects)

                            -- 3. Play
                            pcall(function() snd:Play() end)
                            if not snd.Looped then snd.Ended:Connect(function() pcall(function() snd:Destroy() end) end) end
                        end

                        for _,v in next,m:GetDescendants() do if v:IsA("BasePart") then v.CanCollide=false end end

                        -- Fade out sounds
                        for _,o in ipairs(m:GetDescendants()) do if o:IsA("Sound") then tween:Create(o,TweenInfo.new(2.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{Volume=0}):Play() end end
                        for _,o in ipairs(globalSounds) do
                            if o and o.Parent then
                                tween:Create(o,TweenInfo.new(2.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{Volume=0}):Play()
                                task.delay(2.5, function() pcall(function() o:Destroy() end) end)
                            end
                        end

                        local cP=m:GetPivot() local dD=(cP.LookVector-Vector3.new(0,0.3,0)).Unit
                        local c c=RS.Stepped:Connect(function(_,stp) if m.Parent then m:PivotTo(m:GetPivot()+(dD*(cf.Movement.Speed*stp))) else c:Disconnect() end end)
                        task.wait(2.5) if c then c:Disconnect() end e:Despawn()
                    end
                end)
            end
            getgenv().VynixuEntitySpawnerV2=M return M
        end)()
    end, function(e) return debug.traceback(e) end)
    if not s_eng then warn("[Hardcore Mode] Engine Initialization Error:\n" .. tostring(err_eng)) end
end)

local function SE_Ambush()
    if not spawner then warn("[Hardcore] Spawner missing for Ambush!") return end
    local s, err = xpcall(function()
        local e = spawner:Create({
            Entity = { Name = "Ambush", Asset = "77471049714310", HeightOffset = 0, CanOpenDoors = false, Is2D = false, NavMeshHeightOffset = 1.5 },
            Sounds = {
                FarSound = { SoundId = "rbxassetid://80435851839067", Volume = 10, PlaybackSpeed = 1, RollOffMinDistance = 10, RollOffMaxDistance = 500, Looped = true },
                NearSound = { SoundId = "rbxassetid://80435851839067", Volume = 10, PlaybackSpeed = 1.10, RollOffMinDistance = 5, RollOffMaxDistance = 75, Looped = true },
                ArrivalSound = { SoundId = "rbxassetid://134020218579308", Volume = 3, PlaybackSpeed = 1, Looped = false, Global = true }
            },
            Lights = { Flicker = { Enabled = true, Duration = 1 }, Shatter = true, Repair = false },
            Earthquake = { Enabled = false },
            CameraShake = { Enabled = true, Range = 100, Values = {3, 60, 0.1, 1} },
            Movement = { Speed = 120, Delay = 5, Reversed = false },
            Rebounding = { Enabled = true, Type = "Legacy Ambush", Min = 2, Max = 5, Delay = 0.5 },
            Debug = {}
        })
        if not e then return end
        e:SetCallback("OnSpawned", function() ASK(e.Model, 40, {"You died to Ambush.", "It comes back!", "Hide when the lights flicker!"}, nil, false) end)
        e:SetCallback("OnDespawned", function() getgenv().ActiveCustomEntities = math.max(0, getgenv().ActiveCustomEntities - 1) end)
        spawner:Run(e, false)
    end, function(er) return debug.traceback(er) end)
    if not s then warn("[Hardcore Mode] Error in Ambush:\n" .. tostring(err)) end
end
getgenv().SpawnEntity_Ambush=SE_Ambush

local function SE_A60()
    if not spawner then warn("[Hardcore] Spawner missing for A-60!") return end
    local s, err = xpcall(function()
        local e = spawner:Create({
            Entity = {
                Name = "A-60",
                Asset = "rbxassetid://137170200467801",
                HeightOffset = 1,
                CanOpenDoors = false,
                Is2D = false,
                NavMeshHeightOffset = 1.5
            },
            Sounds = {
                FarSound = { SoundId = "rbxassetid://109949210483674", Volume = 1.5, PlaybackSpeed = 1, RollOffMinDistance = 10, RollOffMaxDistance = 1500, Looped = true },
                NearSound = { SoundId = "rbxassetid://109949210483674", Volume = 1.5, PlaybackSpeed = 1, RollOffMinDistance = 5, RollOffMaxDistance = 300, Looped = true }
            },
            Lights = {Flicker = {Enabled = true, Duration = 1}, Shatter = true, Repair = false},
            Earthquake = {Enabled = false},
            CameraShake = {Enabled = true, Range = 150, Values = {6, 60, 0.1, 1}},
            Movement = {Speed = 200, Delay = 4, Reversed = false},
            Rebounding = {Enabled = true, Type = "Legacy Ambush", Min = 5, Max = 20, Delay = 2},
            Debug = {}
        })
        if not e then return end
        e:SetCallback("OnSpawned", function() ASK(e.Model, 40, {"You died to A-60.", "It is incredibly fast!", "Hide when the lights flicker!"}, nil, false) end)
        e:SetCallback("OnDespawned", function() getgenv().ActiveCustomEntities = math.max(0, getgenv().ActiveCustomEntities - 1) end)
        spawner:Run(e, false)
    end, function(er) return debug.traceback(er) end)
    if not s then warn("[Hardcore Mode] Error in A-60:\n" .. tostring(err)) end
end
getgenv().SpawnEntity_A60 = SE_A60

local function SE_A200() if not spawner then warn("[Hardcore] Spawner missing for A-200!") return end local s,err=xpcall(function() local e=spawner:Create({Entity={Name="A-200",Asset="rbxassetid://12984237084",HeightOffset=1.5,CanOpenDoors=false,NavMeshHeightOffset=1.5},Lights={Flicker={Enabled=true,Duration=1.5},Shatter=true},Earthquake={Enabled=false},CameraShake={Enabled=true,Range=100,Values={1.5,20,0.1,1}},Movement={Speed=40,Delay=7,Reversed=true},Rebounding={Enabled=true,Type="Blitz",Min=0,Max=2,Delay=0.5}}) if not e then return end e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,40,{"You died to A-200.","Spawns ahead and travels backwards.","Hide quickly!"},nil,false) end end) end) e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) spawner:Run(e,false) end, function(er) return debug.traceback(er) end) if not s then warn("[Hardcore Mode] Error in A-200:\n"..tostring(err)) end end getgenv().SpawnEntity_A200=SE_A200
local function SE_FreeRobloxianOutfit() if not spawner then warn("[Hardcore] Spawner missing for FREE ROBLOXIAN!") return end local s,err=xpcall(function() local e=spawner:Create({Entity={Name="FREE ROBLOXIAN OUTFIT",Asset="rbxassetid://103662059684022",HeightOffset=0,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=1.5},Sounds={FarSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.2,RollOffMinDistance=10,RollOffMaxDistance=1000,Looped=true},NearSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.75,RollOffMinDistance=5,RollOffMaxDistance=75,Looped=true}},Lights={Flicker={Enabled=true,Duration=1},Shatter=true,Repair=false},Earthquake={Enabled=false},CameraShake={Enabled=true,Range=100,Values={1,40,0.1,1}},Movement={Speed=80,Delay=1.5,Reversed=false},Rebounding={Enabled=false,Type="Ambush",Min=1,Max=1,Delay=2},Debug={}}) if not e then return end e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,40,{"You died to FREE ROBLOXIAN OUTFIT.","Hide when the lights flicker!"},nil,false) end end) end) e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) spawner:Run(e,false) end, function(er) return debug.traceback(er) end) if not s then warn("[Hardcore Mode] Error in FREE ROBLOXIAN:\n"..tostring(err)) end end getgenv()["SpawnEntity_FREE ROBLOXIAN OUTFIT"]=SE_FreeRobloxianOutfit
local function SE_rahh() if not spawner then warn("[Hardcore] Spawner missing for rahh!!!") return end local s,err=xpcall(function() local e=spawner:Create({Entity={Name="rahh!!!",Asset="rbxassetid://123875017551067",HeightOffset=0,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=1.5},Sounds={FarSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.2,RollOffMinDistance=10,RollOffMaxDistance=1000,Looped=true},NearSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.75,RollOffMinDistance=5,RollOffMaxDistance=75,Looped=true}},Lights={Flicker={Enabled=true,Duration=1},Shatter=true,Repair=false},Earthquake={Enabled=false},CameraShake={Enabled=true,Range=100,Values={1,40,0.1,1}},Movement={Speed=80,Delay=1.5,Reversed=false},Rebounding={Enabled=false,Type="Ambush",Min=1,Max=1,Delay=2},Debug={}}) if not e then return end e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,40,{"You died to rahh!!!.","Hide when the lights flicker!"},nil,false) end end) end) e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) spawner:Run(e,false) end, function(er) return debug.traceback(er) end) if not s then warn("[Hardcore Mode] Error in rahh!!!:\n"..tostring(err)) end end getgenv()["SpawnEntity_rahh!!!"]=SE_rahh
local function SE_BaldKreek() if not spawner then warn("[Hardcore] Spawner missing for Bald Kreek!") return end local s,err=xpcall(function() local e=spawner:Create({Entity={Name="Bald Kreek",Asset="rbxassetid://93078046721158",HeightOffset=0,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=1.5},Sounds={FarSound={SoundId="rbxassetid://1845307009",Volume=1.5,PlaybackSpeed=0.2,RollOffMinDistance=10,RollOffMaxDistance=1000,Looped=true},NearSound={SoundId="rbxassetid://1845307009",Volume=1.5,PlaybackSpeed=0.4,RollOffMinDistance=5,RollOffMaxDistance=75,Looped=true}},Lights={Flicker={Enabled=true,Duration=1},Shatter=true,Repair=false},Earthquake={Enabled=false},CameraShake={Enabled=true,Range=100,Values={1,40,0.1,1}},Movement={Speed=80,Delay=1.5,Reversed=false},Rebounding={Enabled=false,Type="Ambush",Min=1,Max=1,Delay=2},Debug={}}) if not e then return end e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,40,{"You died to Bald Kreek.","Hide when the lights flicker!"},nil,false) end end) end) e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) spawner:Run(e,false) end, function(er) return debug.traceback(er) end) if not s then warn("[Hardcore Mode] Error in Bald Kreek:\n"..tostring(err)) end end getgenv().SpawnEntity_BaldKreek=SE_BaldKreek
local function SE_NachoVarga() if not spawner then warn("[Hardcore] Spawner missing for Nacho Varga!") return end local s,err=xpcall(function() local e=spawner:Create({Entity={Name="Nacho Varga",Asset="rbxassetid://122425276040196",HeightOffset=0,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=1.5},Sounds={FarSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.2,RollOffMinDistance=10,RollOffMaxDistance=1000,Looped=true},NearSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.75,RollOffMinDistance=5,RollOffMaxDistance=75,Looped=true}},Lights={Flicker={Enabled=true,Duration=1},Shatter=true,Repair=false},Earthquake={Enabled=false},CameraShake={Enabled=true,Range=100,Values={1,40,0.1,1}},Movement={Speed=80,Delay=1.5,Reversed=false},Rebounding={Enabled=false,Type="Ambush",Min=1,Max=1,Delay=2},Debug={}}) if not e then return end e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,40,{"You died to Nacho Varga.","Hide when the lights flicker!"},nil,false) end end) end) e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) spawner:Run(e,false) end, function(er) return debug.traceback(er) end) if not s then warn("[Hardcore Mode] Error in Nacho Varga:\n"..tostring(err)) end end getgenv().SpawnEntity_NachoVarga=SE_NachoVarga
local function SE_ScaryRedFace1() if not spawner then warn("[Hardcore] Spawner missing for scary red face!") return end local s,err=xpcall(function() local e=spawner:Create({Entity={Name="scary red face",Asset="rbxassetid://12987999444",HeightOffset=0,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=1.5},Sounds={FarSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.2,RollOffMinDistance=10,RollOffMaxDistance=1000,Looped=true},NearSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.75,RollOffMinDistance=5,RollOffMaxDistance=75,Looped=true}},Lights={Flicker={Enabled=true,Duration=1.5},Shatter=true,Repair=false},Earthquake={Enabled=false},CameraShake={Enabled=true,Range=100,Values={1,30,0.1,1}},Movement={Speed=80,Delay=1.5,Reversed=false},Rebounding={Enabled=false,Type="Ambush",Min=1,Max=1,Delay=2},Debug={}}) if not e then return end e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,40,{"You died to the scary red face.","It approaches at a moderate speed.","Hide when the lights flicker!"},nil,false) end end) end) e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) spawner:Run(e,false) end, function(er) return debug.traceback(er) end) if not s then warn("[Hardcore Mode] Error in scary red face:\n"..tostring(err)) end end getgenv().SpawnEntity_ScaryRedFace1=SE_ScaryRedFace1
local function SE_ScaryRedFace2() if not spawner then warn("[Hardcore] Spawner missing for Scary Red Face!") return end local s,err=xpcall(function() local e=spawner:Create({Entity={Name="Scary Red Face",Asset="rbxassetid://83896895946876",HeightOffset=0,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=1.5},Sounds={FarSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.2,RollOffMinDistance=10,RollOffMaxDistance=1000,Looped=true},NearSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.75,RollOffMinDistance=5,RollOffMaxDistance=75,Looped=true}},Lights={Flicker={Enabled=true,Duration=1.5},Shatter=true,Repair=false},Earthquake={Enabled=false},CameraShake={Enabled=true,Range=100,Values={1,30,0.1,1}},Movement={Speed=80,Delay=1.5,Reversed=false},Rebounding={Enabled=false,Type="Ambush",Min=1,Max=1,Delay=2},Debug={}}) if not e then return end e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,40,{"You died to the Scary Red Face.","It approaches at a moderate speed.","Hide when the lights flicker!"},nil,false) end end) end) e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) spawner:Run(e,false) end, function(er) return debug.traceback(er) end) if not s then warn("[Hardcore Mode] Error in Scary Red Face:\n"..tostring(err)) end end getgenv().SpawnEntity_ScaryRedFace2=SE_ScaryRedFace2
local function SE_DEPTH_SHM() if not spawner then warn("[Hardcore] Spawner missing for DEPTH_SHM!") return end local s,err=xpcall(function() local e=spawner:Create({Entity={Name="DEPTH",Asset="rbxassetid://84780317335866",HeightOffset=0,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=1.5},Sounds={FarSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.75,RollOffMinDistance=10,RollOffMaxDistance=1000,Looped=true},NearSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=1,RollOffMinDistance=5,RollOffMaxDistance=75,Looped=true}},Lights={Flicker={Enabled=true,Duration=1},Shatter=true,Repair=false},Earthquake={Enabled=false},CameraShake={Enabled=true,Range=100,Values={1,40,0.1,1}},Movement={Speed=80,Delay=1.5,Reversed=false},Rebounding={Enabled=false,Type="Ambush",Min=1,Max=1,Delay=2},Debug={}}) if not e then return end e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,40,{"You died to DEPTH.","Hide when the lights flicker!"},nil,false) end end) end) e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) spawner:Run(e,false) end, function(er) return debug.traceback(er) end) if not s then warn("[Hardcore Mode] Error in DEPTH_SHM:\n"..tostring(err)) end end getgenv().SpawnEntity_DEPTH_SHM=SE_DEPTH_SHM

local function SE_Trollface() if not spawner then warn("[Hardcore] Spawner missing for Trollface!") return end local s,err=xpcall(function() local e=spawner:Create({Entity={Name="Trollface",Asset="rbxassetid://17687252419",HeightOffset=1,NavMeshHeightOffset=1.5},Sounds={FarSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.2,RollOffMinDistance=10,RollOffMaxDistance=1500,Looped=true},NearSound={SoundId="rbxassetid://87112595752706",Volume=1.5,PlaybackSpeed=0.75,RollOffMinDistance=5,RollOffMaxDistance=300,Looped=true}},Lights={Flicker={Enabled=false,Duration=1},Shatter=true},Earthquake={Enabled=false},CameraShake={Enabled=true,Range=100,Values={2,25,0.1,1}},Movement={Speed=200,Delay=5,Reversed=false},Rebounding={Enabled=false,Type="Ambush",Min=1,Max=1,Delay=2}}) if not e then return end e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,40,{"Problem?","You just got trolled.","He is incredibly fast."},nil,false) end end) end) e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) spawner:Run(e,false) end, function(er) return debug.traceback(er) end) if not s then warn("[Hardcore Mode] Error in Trollface:\n"..tostring(err)) end end getgenv().SpawnEntity_Trollface=SE_Trollface

local function SE_Ripper()
    if not spawner then warn("[Hardcore] Spawner missing for Ripper!") return end
    local s,err=xpcall(function()
        local e=spawner:Create({
            Entity={
                Name="Ripper",
                Asset="116944518972350",
                HeightOffset=3,
                CanOpenDoors=false,
                Is2D=false,
                NavMeshHeightOffset=1.5
            },
            Sounds={
                FarSound={
                    SoundId="rbxassetid://9125713501",
                    Volume=1.5, PlaybackSpeed=1, RollOffMinDistance=10, RollOffMaxDistance=750, Looped=true,
                    Effects={
                        PitchShift={ClassName="PitchShiftSoundEffect", Octave=0.875}
                    }
                },
                NearSound={
                    SoundId="rbxassetid://6963538865",
                    Volume=0.5, PlaybackSpeed=1, RollOffMinDistance=5, RollOffMaxDistance=150, Looped=true,
                    Effects={
                        Distortion={ClassName="DistortionSoundEffect", Level=0.99},
                        Reverb={ClassName="ReverbSoundEffect", DecayTime=20, Density=1, Diffusion=1, DryLevel=0, WetLevel=1}
                    }
                },
                ArrivalSound={
                    SoundId="rbxassetid://9125713501",
                    Volume=3, PlaybackSpeed=1, Looped=false, Global=true,
                    Effects={
                        PitchShift={ClassName="PitchShiftSoundEffect", Octave=0.875}
                    }
                },
                DespawnSound={
                    SoundId="rbxassetid://1837829565",
                    Volume=3, PlaybackSpeed=1, Looped=false, PlayOnDespawn=true, Global=false,
                    Effects={
                        Reverb={ClassName="ReverbSoundEffect", DecayTime=1, Density=1, Diffusion=1, DryLevel=1, WetLevel=1}
                    }
                }
            },
            Lights={Flicker={Enabled=true,Duration=3},Shatter=true},
            Earthquake={Enabled=true},
            CameraShake={Enabled=true,Range=100,Values={2,50,0.1,1}},
            Movement={Speed=85,Delay=4,Reversed=false},
            Rebounding={Enabled=true,Type="Blitz",Min=0,Max=1,Delay=2},
            Debug={}
        })
        if not e then return end

        e:SetCallback("OnSpawned",function()
            pcall(function()
                local m=e.Model
                if m then
                    ASK(m,40,{"You died to Ripper.","He tears through the rooms.","Hide when lights flicker for a long time."},nil,false)
                end
            end)
        end)

        e:SetCallback("OnDespawned",function()
            getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1)
        end)

        spawner:Run(e,false)
    end, function(er) return debug.traceback(er) end)

    if not s then warn("[Hardcore Mode] Error in Ripper:\n"..tostring(err)) end
end
getgenv().SpawnEntity_Ripper=SE_Ripper

local function SE_Blitz() if not spawner then warn("[Hardcore] Spawner missing for Blitz!") return end local s,err=xpcall(function() local e=spawner:Create({Entity={Name="Blitz",Asset="https://github.com/RegularVynixu/Utilities/raw/main/Doors/Entity%20Spawner/Assets/Entities/BackdoorRush.rbxm",HeightOffset=0,CanOpenDoors=false,NavMeshHeightOffset=1.5},Lights={Flicker={Enabled=true,Duration=1},Shatter=true},Earthquake={Enabled=true},CameraShake={Enabled=true,Range=100,Values={1.5,20,0.1,1}},Movement={Speed=70,Delay=0,Reversed=false},Rebounding={Enabled=true,Type="Blitz",Min=1,Max=math.random(1,2),Delay=math.random(10,30)/10}}) if not e then return end e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,40,{"Oh... Hello.","I didn't expect to see you here.","She said we should call that one Blitz.","Haha... of course you will."},nil,false) end end) end) e:SetCallback("OnRebounding",function(s) pcall(function() local m=e.Model:FindFirstChild("Main") if not m then return end local a,as=m:FindFirstChild("Attachment"),m:FindFirstChild("AttachmentSwitch") local f,p,w,b=m:FindFirstChild("Footsteps"),m:FindFirstChild("PlaySound"),m:FindFirstChild("Switch"),m:FindFirstChild("SwitchBack") if a and as then for _,c in next,a:GetChildren() do c.Enabled=(not s) end for _,c in next,as:GetChildren() do c.Enabled=s end end if s then if f then f.PlaybackSpeed=0.35 end if p then p.PlaybackSpeed=0.25 end if w then w:Play() end else if f then f.PlaybackSpeed=0.25 end if p then p.PlaybackSpeed=0.16 end if b then b:Play() end end end) end) e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) spawner:Run(e,false) end, function(er) return debug.traceback(er) end) if not s then warn("[Hardcore Mode] Error in Blitz:\n"..tostring(err)) end end getgenv().SpawnEntity_Blitz=SE_Blitz
local function SE_Depth() if not spawner then warn("[Hardcore] Spawner missing for Depth!") return end local s,err=xpcall(function() local e=spawner:Create({Entity={Name="Depth",Asset="rbxassetid://11535848347",HeightOffset=0,CanOpenDoors=false,NavMeshHeightOffset=1.5},Sounds={FarSound={SoundId="rbxassetid://138776356539253",Volume=1.5,PlaybackSpeed=1,RollOffMinDistance=15,RollOffMaxDistance=1000,Looped=true},NearSound={SoundId="rbxassetid://109949210483674",Volume=3,PlaybackSpeed=1,RollOffMinDistance=5,RollOffMaxDistance=75,Looped=true}},Lights={Flicker={Enabled=true,Duration=1},Shatter=true},Earthquake={Enabled=true},CameraShake={Enabled=true,Range=100,Values={2,50,0.1,1}},Movement={Speed=180,Delay=5,Reversed=false},Rebounding={Enabled=true,Type="Ambush",Min=10,Max=10,Delay=0.5}}) if not e then return end e:SetCallback("OnSpawned",function() pcall(function() local m=e.Model if m then ASK(m,60,{"Depth is incredibly fast.","Hide the moment you hear him.","Be careful, he can come back."},nil,false) end end) end) e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end) spawner:Run(e,false) end, function(er) return debug.traceback(er) end) if not s then warn("[Hardcore Mode] Error in Depth:\n"..tostring(err)) end end getgenv().SpawnEntity_Depth=SE_Depth
local function SE_Silence() if not spawner then warn("[Hardcore] Spawner missing for Silence!") return end local s,err=xpcall(function() local S=loadstring(game:HttpGet('https://raw.githubusercontent.com/MuhXd/DoorSuff/main/OtherSuff/DoorEntitySpawn%2BSource'))() local e=S.createEntity({CustomName="Silence",Model="rbxassetid://11535812658",Speed=20,DelayTime=2,HeightOffset=0,CanKill=false,BreakLights=true,FlickerLights={false,1},Cycles={Min=1,Max=1,WaitTime=2},CamShake={true,{1.5,20,0.1,1},10}}) e.Debug.OnEntitySpawned=function() pcall(function() local m=Workspace:FindFirstChild("Silence") if m then ASK(m,45,{"You died to Silence","hide!","..","....","becareful, ok?"},nil,false) end end) end e.Debug.OnEntityDespawned=function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) pcall(function() local m=Workspace:FindFirstChild("Silence") if m then m:Destroy() end end) end S.runEntity(e) end, function(er) return debug.traceback(er) end) if not s then warn("[Hardcore Mode] Error in Silence:\n"..tostring(err)) end end getgenv().SpawnEntity_Silence=SE_Silence
local function SE_Cease() if not spawner then warn("[Hardcore] Spawner missing for Cease!") return end local s,err=xpcall(function() local S=loadstring(game:HttpGet('https://raw.githubusercontent.com/MuhXd/DoorSuff/main/OtherSuff/DoorEntitySpawn%2BSource'))() local e=S.createEntity({CustomName="Cease",Model="rbxassetid://12262854624",Speed=60,DelayTime=2,HeightOffset=0,CanKill=false,BreakLights=true,FlickerLights={true,1},Cycles={Min=1,Max=1,WaitTime=2},CamShake={false,{1.5,20,0.1,1},100}}) e.Debug.OnEntitySpawned=function() pcall(function() local c=Instance.new("ColorCorrectionEffect",game.Lighting) c.Name,c.TintColor,c.Contrast="CeaseColor",Color3.fromRGB(92,103,255),1 game.Debris:AddItem(c,85) tween:Create(c,TweenInfo.new(2.5),{Contrast=0}):Play() tween:Create(c,TweenInfo.new(80),{TintColor=Color3.fromRGB(255,255,255)}):Play() local m=Workspace:FindFirstChild("Cease") if m then ASK(m,80,{"You died to Cease..","He appears when the room turns blue","You just have to stand there and don't move until it disappears.","And if you move, he will kill you."},nil,true) end end) end e.Debug.OnEntityDespawned=function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) pcall(function() local ceaseModel=Workspace:FindFirstChild("Cease") if ceaseModel then ceaseModel:Destroy() end end) end S.runEntity(e) end, function(er) return debug.traceback(er) end) if not s then warn("[Hardcore Mode] Error in Cease:\n"..tostring(err)) end end getgenv().SpawnEntity_Cease=SE_Cease

local SpC={{Entity=SE_Blitz,Chance=26},{Entity=SE_Cease,Chance=26},{Entity=SE_Ripper,Chance=26},{Entity=SE_A60,Chance=10},{Entity=SE_Silence,Chance=8},{Entity=SE_Depth,Chance=4}}
local ETR,LSE=0,nil ReplicatedStorage.GameData.LatestRoom.Changed:Connect(function() ETR=0 end)
local function CSE() return not getgenv().death and ReplicatedStorage.GameData.LatestRoom.Value>=5 and ETR<3 end
local function GWS() local c repeat local r,cm=math.random(1,100),0 for _,s in ipairs(SpC) do cm=cm+s.Chance if r<=cm then c=s.Entity break end end until c~=LSE return c end
coroutine.wrap(function() while not getgenv().death do task.wait(300) if CSE() then local s=GWS() LSE=s getgenv().ActiveCustomEntities=getgenv().ActiveCustomEntities+1 ETR=ETR+1 coroutine.wrap(s)() end end end)()
ReplicatedStorage.GameData.LatestRoom.Changed:Connect(function() if not getgenv().death and ReplicatedStorage.GameData.LatestRoom.Value==10 then local s=GWS() LSE=s getgenv().ActiveCustomEntities=getgenv().ActiveCustomEntities+1 ETR=ETR+1 coroutine.wrap(s)() return end end)
