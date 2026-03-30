-- Очищення попередніх інтерфейсів
for _, oldGui in pairs(game:GetService("CoreGui"):GetChildren()) do
    if oldGui.Name == "VoltshardMiner" or oldGui.Name == "VoltshardLogs" then oldGui:Destroy() end
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- РЕМОУТИ
local toolsEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Tools")
local chargeEvent = toolsEvents:WaitForChild("Charge")
local attackEvent = toolsEvents:WaitForChild("Attack")

-- === НАЛАШТУВАННЯ ===
local isRunning = false
local POS_1 = Vector3.new(-6609, -593, 832) 
local POS_2 = Vector3.new(-7459, -638, 1372) 

local TP_STEPS = 20        
local TP_DELAY = 0.1       

-- === GUI LOGS ===
local LogGui = Instance.new("ScreenGui", CoreGui)
LogGui.Name = "VoltshardLogs"
local LogFrame = Instance.new("ScrollingFrame", LogGui)
LogFrame.Size = UDim2.new(0, 260, 0, 120)
LogFrame.Position = UDim2.new(0, 10, 0.7, 0)
LogFrame.BackgroundColor3 = Color3.new(0, 0, 0)
LogFrame.BackgroundTransparency = 0.5
LogFrame.CanvasSize = UDim2.new(0, 0, 10, 0)
Instance.new("UIListLayout", LogFrame).SortOrder = Enum.SortOrder.LayoutOrder

local function addLog(text, isError)
    local l = Instance.new("TextLabel", LogFrame)
    l.Size = UDim2.new(1, 0, 0, 20)
    l.Text = " " .. text
    l.TextColor3 = isError and Color3.new(1, 0.4, 0.4) or Color3.new(0.4, 1, 1)
    l.BackgroundTransparency = 1
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextScaled = true
    LogFrame.CanvasPosition = Vector2.new(0, 99999)
end

-- === MAIN GUI ===
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "VoltshardMiner"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 100)
Main.Position = UDim2.new(0.5, -100, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 40, 50)
Main.Active = true
Main.Draggable = true

local ToggleBtn = Instance.new("TextButton", Main)
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 60)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleBtn.Text = "START VOLTSHARD"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 80, 150)
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.TextScaled = true

-- === ФУНКЦІЯ БЕЗПЕЧНОГО УДАРУ (58-63%) ===
local function silentHit(targetPart)
    if not targetPart or not isRunning then return end
    
    -- Генерируємо силу удару від 0.58 до 0.63
    local safeAlpha = (58 + math.random(0, 5)) / 100
    local randomResponse = 0.4 + (math.random() * 0.3)

    chargeEvent:FireServer({
        ["HitPosition"] = targetPart.Position,
        ["Target"] = targetPart
    })
    
    task.wait(0.05)
    
    attackEvent:FireServer({
        ["Alpha"] = safeAlpha,
        ["ResponseTime"] = randomResponse
    })
end

local function smoothTP(targetPos)
    addLog("Телепорт...")
    for i = 1, TP_STEPS do 
        if not isRunning then return false end
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(targetPos)
        end
        task.wait(TP_DELAY) 
    end
    return true
end

-- === ГОЛОВНИЙ ЦИКЛ ===
local function startMining()
    while isRunning do
        if not smoothTP(POS_1) then break end
        addLog("Точка 1: Очікування")
        task.wait(4)
        
        if not smoothTP(POS_2) then break end
        addLog("Точка 2: Пошук руди")
        task.wait(2)
        
        local oresFolder = Workspace:FindFirstChild("WorldSpawn") and Workspace.WorldSpawn:FindFirstChild("Ores")
        local ore = oresFolder and oresFolder:FindFirstChild("Voltshard")
        
        if ore then
            addLog("Voltshard! Б'ю обережно...")
            local hitbox = ore:FindFirstChild("Hitbox") or ore:FindFirstChildWhichIsA("BasePart", true)
            local targetTP = (hitbox and hitbox.Position or ore:GetPivot().Position) + Vector3.new(0, 5, 0)
            
            if not smoothTP(targetTP) then break end
            task.wait(0.5)
            
            local hittable = ore:FindFirstChild("Hittable")
            if hittable then
                while isRunning and ore.Parent == oresFolder do
                    local parts = hittable:GetChildren()
                    local targetPart = nil
                    
                    for _, p in pairs(parts) do
                        if p:IsA("BasePart") then
                            targetPart = p
                            break
                        end
                    end
                    
                    if targetPart then
                        silentHit(targetPart)
                        task.wait(0.7) -- Трохи збільшив затримку для стабільності
                    else
                        break
                    end
                end
                addLog("Voltshard зібрано!")
            end
        else
            addLog("Пусто, чекаю респавн...", true)
            task.wait(2)
        end
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        ToggleBtn.Text = "STOP VOLTSHARD"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        task.spawn(startMining)
    else
        ToggleBtn.Text = "START VOLTSHARD"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 80, 150)
    end
end)
