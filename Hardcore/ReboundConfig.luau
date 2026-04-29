local function SE_Rebound()
    if not spawner then warn("[Hardcore] Spawner missing for Rebound!") return end
    local s,err=xpcall(function()
        local e=spawner:Create({
            -- Removed UntouchedAudio so the engine takes full control of the model's sound!
            Entity = {Name="Rebound",Asset="111463924328072",HeightOffset=0,CanOpenDoors=false,Is2D=false,NavMeshHeightOffset=1.5},

            -- Injected your specific Asset ID for both Near and Far sounds
            Sounds = {
                FarSound = {SoundId = "rbxassetid://116456025793787", Volume = 7.5, PlaybackSpeed = 1, RollOffMinDistance = 10, RollOffMaxDistance = 75, Looped = true},
                NearSound = {SoundId = "rbxassetid://116456025793787", Volume = 5, PlaybackSpeed = 1, RollOffMinDistance = 5, RollOffMaxDistance = 20, Looped = true}
            },
            Lights = {Flicker={Enabled=true,Duration=3},Shatter=true,Repair=false}, Earthquake = {Enabled=true}, CameraShake = {Enabled=true,Range=100,Values={2, 50, 0.1, 1}},
            Movement = {Speed=70,Delay=3,Reversed=true},
            Rebounding = {Enabled=true,Type="Rebound",Min=3,Max=5,Delay=4}, Debug = {}
        })
        if not e then return end

        e:SetCallback("OnSpawned",function()
            pcall(function()
                local m=e.Model if m then ASK(m,40,{"You died to Rebound.","He attacks from the front every time you open a door.","Pay attention to the blue tint!"},nil,false)
                local c=Instance.new("ColorCorrectionEffect") c.Name="Warn" c.TintColor=Color3.fromRGB(65, 138, 255) c.Saturation=-0.7 c.Contrast=0.2 c.Parent=game:GetService("Lighting") game.Debris:AddItem(c,24)
                game:GetService("TweenService"):Create(c,TweenInfo.new(15),{TintColor = Color3.fromRGB(255, 255, 255),Saturation = 0, Contrast = 0}):Play()
                local mainCC = game.Lighting:FindFirstChild("MainColorCorrection") if mainCC then game:GetService("TweenService"):Create(mainCC, TweenInfo.new(5),{TintColor = Color3.fromRGB(255, 255, 255)}):Play() end

                -- FIRST ARRIVAL SOUND
                local s1 = Instance.new("Sound", workspace) s1.SoundId = "rbxassetid://9114221327" s1.Volume = 3 s1:Play() game.Debris:AddItem(s1, 10)

                -- DISTORTED SCREAM
                local s2 = Instance.new("Sound", workspace) s2.SoundId = "rbxassetid://9114397505" s2.Volume = 0.1
                local p1 = Instance.new("PitchShiftSoundEffect", s2) p1.Octave = 0.5
                local p2 = Instance.new("PitchShiftSoundEffect", s2) p2.Octave = 0.5
                local p3 = Instance.new("PitchShiftSoundEffect", s2) p3.Octave = 0.5
                local d1 = Instance.new("DistortionSoundEffect", s2) d1.Level = 1
                local d2 = Instance.new("DistortionSoundEffect", s2) d2.Level = 1
                s2:Play() game.Debris:AddItem(s2, 10)
                end
            end)
        end)

        e:SetCallback("OnRebounding", function(start)
            pcall(function()
                if start then
                    local mg = require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game)
                    if mg and mg.camShaker then mg.camShaker:ShakeOnce(2, 50, 0.1, 1) end

                    -- SECONDARY ARRIVAL SOUND FOR REBOUNDS
                    local s1 = Instance.new("Sound", workspace) s1.SoundId = "rbxassetid://9043335396" s1.Volume = 3 s1:Play() game.Debris:AddItem(s1, 10)

                    -- DISTORTED SCREAM (Repeats on every lap)
                    local s2 = Instance.new("Sound", workspace) s2.SoundId = "rbxassetid://9114397505" s2.Volume = 0.1
                    local p1 = Instance.new("PitchShiftSoundEffect", s2) p1.Octave = 0.5
                    local p2 = Instance.new("PitchShiftSoundEffect", s2) p2.Octave = 0.5
                    local p3 = Instance.new("PitchShiftSoundEffect", s2) p3.Octave = 0.5
                    local d1 = Instance.new("DistortionSoundEffect", s2) d1.Level = 1
                    local d2 = Instance.new("DistortionSoundEffect", s2) d2.Level = 1
                    s2:Play() game.Debris:AddItem(s2, 10)
                end
            end)
        end)

        e:SetCallback("OnDespawned",function() getgenv().ActiveCustomEntities=math.max(0,getgenv().ActiveCustomEntities-1) end)
        spawner:Run(e,false)
    end, function(er) return debug.traceback(er) end)
end
getgenv().SpawnEntity_Rebound=SE_Rebound