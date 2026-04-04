-- Очищення попередніх інтерфейсів
for _, oldGui in pairs(game:GetService("CoreGui"):GetChildren()) do
    if oldGui.Name == "EasterEventMiner" or oldGui.Name == "EasterLogs" then oldGui:Destroy() end
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
local targetOreName = "Chocolate" -- Назва руди зі скріншоту
local positions = {
    Vector3.new(844.8, 30.1, -712.80),
    Vector3.new(-1061.3, -52.1, 1257.2),
    Vector3.new(408.8, 181.0, 3239.0),
    Vector3.new(-6117.1, -199.7, -1807.7),
    Vector3.new(1622.6, -259.3, -247.6)
}

local TP_STEPS = 15        
local TP_DELAY = 0.07       

-- === GUI LOGS ===
local LogGui = Instance.new("ScreenGui", CoreGui)
LogGui.Name = "EasterLogs"
local LogFrame = Instance.new("ScrollingFrame", LogGui)
LogFrame.Size = UDim2.new(0, 260, 0, 150)
LogFrame.Position = UDim2.new(0, 10, 0.6, 0)
LogFrame.BackgroundColor3 = Color3.new(0, 0, 0)
LogFrame.BackgroundTransparency = 0.5
LogFrame.CanvasSize = UDim2.new(0, 0, 10, 0)
Instance.new("UIListLayout", LogFrame).SortOrder = Enum.SortOrder.LayoutOrder

local function addLog(text, isError)
    local l = Instance.new("TextLabel", LogFrame)
    l.Size = UDim2.new(1, 0, 0, 20)
    l.Text = " " .. text
    l.TextColor3 = isError and Color3.new(1, 0.4, 0.4) or Color3.new(0.6, 1, 0.6)
    l.BackgroundTransparency = 1
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextScaled = true
    LogFrame.CanvasPosition = Vector2.new(0, 99999)
end

-- === MAIN GUI ===
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "EasterEventMiner"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 220, 0, 300) -- Збільшив висоту для кнопок TP
Main.Position = UDim2.new(0.5, -110, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Main.Active = true
Main.Draggable = true

local ToggleBtn = Instance.new("TextButton", Main)
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 45)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.05, 0)
ToggleBtn.Text = "START EASTER FARM"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 150)
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.TextScaled = true

-- Створення кнопок телепорту
for i, pos in ipairs(positions) do
    local tpBtn = Instance.new("TextButton", Main)
    tpBtn.Size = UDim2.new(0.9, 0, 0, 30)
    tpBtn.Position = UDim2.new(0.05, 0, 0.25 + (i-1)*0.13, 0)
    tpBtn.Text = "Teleport to POS " .. i
    tpBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    tpBtn.TextColor3 = Color3.new(1, 1, 1)
    tpBtn.TextScaled = true
    
    tpBtn.MouseButton1Click:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
            addLog("Ручний ТП до точки " .. i)
        end
    end)
end

-- === ФУНКЦІЇ ===
local function silentHit(targetPart)
    if not targetPart or not isRunning then return end
    
    -- Сила 87-100% для швидкого фарму
    local safeAlpha = (87 + math.random(0, 13)) / 100
    local randomResponse = 0.2 + (math.random() * 0.2)

    chargeEvent:FireServer({
        ["HitPosition"] = targetPart.Position,
        ["Target"] = targetPart
    })
    
    task.wait(0.03)
    
    attackEvent:FireServer({
        ["Alpha"] = safeAlpha,
        ["ResponseTime"] = randomResponse
    })
end

local function smoothTP(targetPos)
    for i = 1, TP_STEPS do 
        if not isRunning then return false end
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            -- Використовуємо Lerp для плавності
            char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame:Lerp(CFrame.new(targetPos), i/TP_STEPS)
        end
        task.wait(TP_DELAY) 
    end
    return true
end

local function findEventOre()
    local oresFolder = Workspace:FindFirstChild("WorldSpawn") and Workspace.WorldSpawn:FindFirstChild("Ores")
    if oresFolder then
        -- Шукаємо саме Chocolate або будь-яку іншу руду, якщо Chocolate не знайдено
        return oresFolder:FindFirstChild(targetOreName)
    end
    return nil
end

-- === ГОЛОВНИЙ ЦИКЛ ===
local function startMining()
    while isRunning do
        for i, pos in ipairs(positions) do
            if not isRunning then break end
            
            addLog("Переліт до POS_" .. i)
            if not smoothTP(pos) then break end
            
            addLog("Очікування завантаження (5с)...")
            task.wait(5)
            
            local ore = findEventOre()
            if ore then
                addLog("Знайшов " .. targetOreName .. "!")
                local hitbox = ore:FindFirstChild("Hitbox") or ore:FindFirstChildWhichIsA("BasePart", true)
                local tpTarget = (hitbox and hitbox.Position or ore:GetPivot().Position) + Vector3.new(0, 6, 0)
                
                smoothTP(tpTarget)
                task.wait(0.5)
                
                local hittable = ore:FindFirstChild("Hittable")
                if hittable then
                    -- Б'ємо поки руда існує
                    while isRunning and ore.Parent do
                        local parts = hittable:GetChildren()
                        local targetPart = nil
                        for _, p in pairs(parts) do
                            if p:IsA("BasePart") then targetPart = p break end
                        end
                        
                        if targetPart then
                            silentHit(targetPart)
                            task.wait(0.5) -- Швидкість ударів
                        else
                            break
                        end
                    end
                    addLog("Зібрано!")
                    task.wait(1)
                end
            else
                addLog("Руди на точці " .. i .. " немає", true)
            end
        end
        task.wait(1)
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        ToggleBtn.Text = "STOP FARM"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        task.spawn(startMining)
    else
        ToggleBtn.Text = "START EASTER FARM"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 150)
    end
end)
