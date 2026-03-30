-- Очищення попередніх інтерфейсів
for _, oldGui in pairs(game:GetService("CoreGui"):GetChildren()) do
    if oldGui.Name == "CloudniteMiner" or oldGui.Name == "CloudniteLogs" then oldGui:Destroy() end
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- РЕМОУТИ З ТВОГО SPY
local toolsEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Tools")
local chargeEvent = toolsEvents:WaitForChild("Charge")
local attackEvent = toolsEvents:WaitForChild("Attack")

-- === НАЛАШТУВАННЯ ===
local isRunning = false
local POS_1 = Vector3.new(-7241, 761, -3245) 
local POS_2 = Vector3.new(-7211, 758, -2909) 

-- Параметри ТП
local TP_STEPS = 20        
local TP_DELAY = 0.1       

-- === GUI LOGS ===
local LogGui = Instance.new("ScreenGui", CoreGui)
LogGui.Name = "CloudniteLogs"
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
    l.TextColor3 = isError and Color3.new(1, 0.2, 0.2) or Color3.new(1, 1, 1)
    l.BackgroundTransparency = 1
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextScaled = true
    LogFrame.CanvasPosition = Vector2.new(0, 99999)
end

-- === MAIN GUI ===
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "CloudniteMiner"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 100)
Main.Position = UDim2.new(0.5, -100, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Main.Active = true
Main.Draggable = true

local ToggleBtn = Instance.new("TextButton", Main)
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 60)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleBtn.Text = "START CLOUDNITE"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.TextScaled = true

-- === НОВА ФУНКЦІЯ УДАРУ (SILENT) ===
local function silentHit(targetPart)
    if not targetPart or not isRunning then return end
    
    -- Рандомізація як ми тестували
    local randomAlpha = 0.94 + (math.random() * 0.04)
    local randomResponse = 0.4 + (math.random() * 0.3)

    chargeEvent:FireServer({
        ["HitPosition"] = targetPart.Position,
        ["Target"] = targetPart
    })
    
    task.wait(0.05) -- Маленька затримка між замахом і ударом
    
    attackEvent:FireServer({
        ["Alpha"] = randomAlpha,
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
        -- 1. Перша точка
        if not smoothTP(POS_1) then break end
        addLog("Точка 1: Очікування 5с")
        task.wait(5)
        
        -- 2. Друга точка
        if not smoothTP(POS_2) then break end
        addLog("Точка 2: Очікування 3с")
        task.wait(3)
        
        -- 3. Пошук руди
        local oresFolder = Workspace:FindFirstChild("WorldSpawn") and Workspace.WorldSpawn:FindFirstChild("Ores")
        local ore = oresFolder and oresFolder:FindFirstChild("Cloudnite")
        
        if ore then
            addLog("Cloudnite знайдено! Починаю фарм")
            local hitbox = ore:FindFirstChild("Hitbox") or ore:FindFirstChildWhichIsA("BasePart", true)
            local targetTP = (hitbox and hitbox.Position or ore:GetPivot().Position) + Vector3.new(0, 5, 0)
            
            if not smoothTP(targetTP) then break end
            task.wait(0.5)
            
            local hittable = ore:FindFirstChild("Hittable")
            if hittable then
                -- Цикл видобутку, поки руда існує
                while isRunning and ore.Parent == oresFolder do
                    local parts = hittable:GetChildren()
                    local targetPart = nil
                    
                    -- Шукаємо активну частину руди
                    for _, p in pairs(parts) do
                        if p:IsA("BasePart") then
                            targetPart = p
                            break
                        end
                    end
                    
                    if targetPart then
                        silentHit(targetPart)
                        task.wait(0.6) -- Швидкість ударів
                    else
                        break -- Всі частини зламані
                    end
                end
                addLog("Руду добуто!")
            end
        else
            addLog("Cloudnite не знайдено, повтор...", true)
            task.wait(2)
        end
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        ToggleBtn.Text = "STOP CLOUDNITE"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        task.spawn(startMining)
    else
        ToggleBtn.Text = "START CLOUDNITE"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    end
end)
