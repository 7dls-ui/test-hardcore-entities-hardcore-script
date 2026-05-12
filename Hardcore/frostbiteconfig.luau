local function SE_Frostbite()
    -- Ensure the static spawner is loaded
    if not getgenv().SpawnStaticEntity then return end

    -- =====================================
    -- || ENTITY CONFIGURATION            ||
    -- =====================================
    local PREPARE_ASSET = "https://github.com/7dls-ui/test-hardcore-entities-hardcore-script/raw/refs/heads/main/Hardcore/FrostbitePrepare2.rbxm"
    local ATTACK_ASSET = "https://github.com/7dls-ui/test-hardcore-entities-hardcore-script/raw/refs/heads/main/Hardcore/FrostbiteAttack.rbxm"
    local DESPAWN_ASSET = "https://github.com/7dls-ui/test-hardcore-entities-hardcore-script/raw/refs/heads/main/Hardcore/FrostbiteDespawning.rbxm"
    
    local PREPARE_DELAY = 5 -- How many seconds before it starts attacking
    local DESPAWN_DELAY = 5 -- How many seconds the despawn model/audio lasts before deletion

    getgenv().SpawnStaticEntity({
        Name = "Frostbite",
        
        -- STAGE 1: We use the PREPARE model as the base asset
        Asset = PREPARE_ASSET, 
        HeightOffset = 1.5,
        
        -- Spawns randomly in the current room as requested
        SpawnLocation = "RandomRoom", 
        
        -- This flawlessly handles your "lasts until the door opens" request!
        -- The engine will automatically call OnDespawning when the room changes.
        DespawnOnNextRoom = true,
        
        -- Custom config flag to respect your native audio
        UntouchedAudio = true, 

        OnSpawned = function(model, despawnFunc)
            getgenv().ActiveCustomEntities = getgenv().ActiveCustomEntities + 1
            
            -- =====================================
            -- || STAGE 1: PREPARING              ||
            -- =====================================
            print("Stage 1: Preparing...")
            -- (Your Prepare Model is currently visible and playing its native sounds)
            
            -- Wait for the preparation phase to end
            task.delay(PREPARE_DELAY, function()
                -- If the player opened the door before it even finished preparing, cancel the attack
                if not model.Parent or model:GetAttribute("Despawning") then return end
                
                -- =====================================
                -- || STAGE 2: ATTACKING              ||
                -- =====================================
                print("Stage 2: Attacking...")
                
                -- Load the Attacking Model
                local attackModel = getgenv().LoadCustomInstance(ATTACK_ASSET)
                if attackModel then
                    attackModel:PivotTo(model:GetPivot())
                    attackModel.Parent = model
                    
                    -- Hide the Prepare model so only the Attack model shows
                    for _, v in ipairs(model:GetDescendants()) do
                        if v:IsA("BasePart") and not v:IsDescendantOf(attackModel) and v ~= model.PrimaryPart then
                            v.Transparency = 1
                        end
                    end
                end
                
                -- The 5 Damage Per Second Loop!
                task.spawn(function()
                    -- This loop runs forever until the entity is despawned (door opened)
                    while model.Parent and not model:GetAttribute("Despawning") do
                        task.wait(1) -- Wait 1 second between damage ticks
                        
                        -- Double-check it hasn't despawned during the wait
                        if not model.Parent or model:GetAttribute("Despawning") then break end
                        
                        -- Deal 5 Damage
                        local char = game.Players.LocalPlayer.Character
                        if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                            if not getgenv().CustomGodMode then
                                char.Humanoid:TakeDamage(5)
                                
                                -- Optional: If the DPS kills them, give a custom death hint
                                if char.Humanoid.Health <= 0 then
                                    pcall(function() 
                                        firesignal(game.ReplicatedStorage.Bricks.DeathHint.OnClientEvent, 
                                        {"You died to the 3-Stage Entity.", "You must open the next door quickly to banish it!"}, 
                                        "Blue") 
                                    end)
                                end
                            end
                        end
                    end
                end)
            end)
        end,
        
        OnDespawning = function(model)
            getgenv().ActiveCustomEntities = math.max(0, getgenv().ActiveCustomEntities - 1)
            
            -- Set a flag to instantly stop the 5 DPS attack loop
            model:SetAttribute("Despawning", true)
            
            -- =====================================
            -- || STAGE 3: DESPAWNING             ||
            -- =====================================
            print("Stage 3: Despawning...")
            
            -- Load the Despawning Model
            local despawnModel = getgenv().LoadCustomInstance(DESPAWN_ASSET)
            if despawnModel then
                despawnModel:PivotTo(model:GetPivot())
                despawnModel.Parent = model
                
                -- Destroy the Attacking/Prepare visual models so ONLY the Despawn model shows
                for _, v in ipairs(model:GetChildren()) do
                    if v:IsA("Model") and v ~= despawnModel then
                        v:Destroy()
                    end
                end
            end
            
            -- Because UntouchedAudio = true, your Despawn model's audio will play perfectly 
            -- without the engine trying to tween its volume down to 0.
        end, 
        
        -- Maps directly to your requested Despawn Delay variable
        DespawnDelay = DESPAWN_DELAY 
    })
end 

-- Expose it to the global environment for your UI
getgenv().SpawnEntity_3StageEntity = SE_3StageEntity
