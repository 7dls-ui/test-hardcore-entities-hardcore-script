local function SE_Template()
    if not spawner then return end
    local s, err = xpcall(function()
        local e = spawner:Create({
            Entity = {
                Name = "Matcher", 
                Asset = "rbxassetid://https://github.com/7dls-ui/test-hardcore-entities-hardcore-script/raw/refs/heads/main/Hardcore/MatcherMoving.rbxm", -- Paste your ID or .rbxm GitHub URL here
                HeightOffset = 0, 
                CanOpenDoors = false, 
                Is2D = false, 
                NavMeshHeightOffset = 1.5, 
                UntouchedAudio = true -- Your audio stays completely un-tampered with!
            },
            Sounds = {
                -- Because UntouchedAudio is true, it relies on the sounds inside your model.
                -- However, you can still add a Global Arrival sound here if you want!
            },
            Lights = {
                Flicker = {Enabled = true, Duration = 5}, 
                Shatter = true, 
                Repair = false
            }, 
            Earthquake = {Enabled = false}, 
            CameraShake = {Enabled = true, Range = 100, Values = {2, 30, 0.1, 1}},
            Movement = {
                Speed = 100, -- Adjust how fast it moves
                Delay = 5, -- Seconds before it starts moving after spawning
                Reversed = false -- Set to true to make it come from the front (like A-200)
            },
            Rebounding = {
                Enabled = true, -- Set to true to make it act like Ambush/Blitz
                Type = "Legacy Ambush", 
                Min = 0, 
                Max = 1, 
                Delay = 0
            }, 
            Debug = {}
        })
        if not e then return end

        e:SetCallback("OnSpawned", function()
            pcall(function()
                local m = e.Model 
                if m then 
                    -- ASK(model, kill_radius, death_hints_table, extra_callback, requires_movement, ignores_hiding)
                    ASK(m, 40, {"You died to the Template.", "Change this text to whatever you want!", "Good luck."}, nil, false, false) 
                end
            end)
        end)

        e:SetCallback("OnDespawned", function()
            getgenv().ActiveCustomEntities = math.max(0, getgenv().ActiveCustomEntities - 1)
        end)
        
        spawner:Run(e, false)
    end, function(er) return debug.traceback(er) end)
end
getgenv().SpawnEntity_Template = SE_Template
