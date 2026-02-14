-- EQUIP YOUR PICKAXE 2ND SLOT
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VIM = game:GetService("VirtualInputManager")

local localPlayer = Players.LocalPlayer
local events = ReplicatedStorage:WaitForChild("Events")
local grabFunc = events:WaitForChild("Grab")
local ungrabEvent = events:WaitForChild("Ungrab")

-- ПАПКИ ЗГІДНО ТВОЄЇ СТРУКТУРИ
local worldSpawn = Workspace:WaitForChild("WorldSpawn")
local grabableFolder = Workspace:WaitForChild("Grabable")

-- === GUI ===
local screenGui = Instance.new("ScreenGui", localPlayer.PlayerGui)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 120)
frame.Position = UDim2.new(0.5, -125, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(20, 25, 20)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0.5, 0)
toggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
toggleBtn.Text = "FARM: OFF"
toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 30)
status.Position = UDim2.new(0, 0, 0.7, 0)
status.Text = "Status: Idle"
status.TextColor3 = Color3.new(1, 1, 1)
status.BackgroundTransparency = 1
status.Parent = frame

-- === НАЛАШТУВАННЯ ===
local farmActive = false
local farmPos = Vector3.new(8.8, -80, 4570)
local basePos = Vector3.new(-727, 4, -762)

-- Функція майнінгу (1-ша особа)
local function minePart(targetPart)
    if not targetPart or not targetPart.Parent then return end
    local camera = Workspace.CurrentCamera
    camera.CFrame = CFrame.new(camera.CFrame.Position, targetPart.Position)
    task.wait(0.02)
    local center = camera.ViewportSize / 2
    VIM:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 1)
    task.wait(0.04)
    VIM:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 1)
end

-- Функція телепорту руди (ТІЛЬКИ З GRABABLE)
local function bringOreToBase()
    status.Text = "Status: Bringing Loot..."
    task.wait(1.5)
    for _, item in pairs(grabableFolder:GetChildren()) do
        if item.Name == "MaterialPart" then
            local owner = item:FindFirstChild("Owner")
            -- Перевірка власника з твого фото
            if owner and (owner.Value == localPlayer or tostring(owner.Value) == localPlayer.Name) then
                local p = item:FindFirstChild("Part")
                if p then
                    grabFunc:InvokeServer(p)
                    task.wait(0.1)
                    p.CFrame = CFrame.new(basePos + Vector3.new(0, 5, 0))
                    task.wait(0.1)
                    ungrabEvent:FireServer()
                end
            end
        end
    end
end

-- ГОЛОВНИЙ ЦИКЛ
task.spawn(function()
    while true do
        if farmActive then
            local char = localPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            if hrp then
                -- 1. ТП В ЗОНУ
                hrp.CFrame = CFrame.new(farmPos)
                status.Text = "Status: Loading Zone..."
                task.wait(5)

                local targetFound = false
                -- 2. ШУКАЄМО В WORLDSPAWN (Як ти вказав)
                for _, obj in pairs(worldSpawn:GetChildren()) do
                    if not farmActive then break end
                    
                    local rs = obj:FindFirstChild("RockString")
                    if rs and rs.Value == "Uranium" then
                        targetFound = true
                        status.Text = "Status: Mining Uranium..."
                        
                        -- ТП до каменю
                        hrp.CFrame = obj:GetPivot() * CFrame.new(0, 1.5, 0)
                        task.wait(0.5)

                        -- Інструмент 4
                        local tool = localPlayer.Backpack:FindFirstChild("4") or char:FindFirstChild("4")
                        if tool then tool.Parent = char end
                        task.wait(0.3)

                        -- РОЗБИТТЯ (Stage3.Part)
                        local stage3 = obj:FindFirstChild("Rock") and obj.Rock:FindFirstChild("Stage3")
                        if stage3 then
                            while stage3:FindFirstChild("Part") and farmActive do
                                for _, p in pairs(stage3:GetChildren()) do
                                    if p.Name == "Part" then
                                        minePart(p)
                                    end
                                end
                                task.wait(0.1)
                            end
                        end
                        
                        -- 3. ЗБІР ДРОПУ З GRABABLE
                        bringOreToBase()
                    end
                end
                
                if not targetFound then
                    status.Text = "Status: No Uranium in WorldSpawn"
                    task.wait(3)
                end
            end
        end
        task.wait(0.5)
    end
end)

toggleBtn.MouseButton1Click:Connect(function()
    farmActive = not farmActive
    toggleBtn.Text = farmActive and "FARM: ON" or "FARM: OFF"
    toggleBtn.BackgroundColor3 = farmActive and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(150, 0, 0)
end)
