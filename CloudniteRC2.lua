-- Очищення попередніх інтерфейсів
for _, oldGui in pairs(game:GetService("CoreGui"):GetChildren()) do
    if oldGui.Name == "CloudniteMiner" or oldGui.Name == "CloudniteLogs" then oldGui:Destroy() end
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VIM = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- === НАЛАШТУВАННЯ ШВИДКОСТІ ===
local isRunning = false
local POS_1 = Vector3.new(-7241, 761, -3245) -- Точка 1
local POS_2 = Vector3.new(-7211, 758, -2909) -- Точка 2

-- Нові налаштування: 20 разів за 2 секунди
local TP_STEPS = 20       
local TP_DELAY = 0.1      

-- === GUI LOGS ===
local LogGui = Instance.new("ScreenGui", CoreGui)
LogGui.Name = "CloudniteLogs"
local LogFrame = Instance.new("ScrollingFrame", LogGui)
LogFrame.Size = UDim2.new(0, 260, 0, 100)
LogFrame.Position = UDim2.new(0, 10, 0.8, 0)
LogFrame.BackgroundColor3 = Color3.new(0, 0, 0)
LogFrame.BackgroundTransparency = 0.5
LogFrame.CanvasSize = UDim2.new(0, 0, 5, 0)
Instance.new("UIListLayout", LogFrame).SortOrder = Enum.SortOrder.LayoutOrder

local function addLog(text, isError)
    local l = Instance.new("TextLabel", LogFrame)
    l.Size = UDim2.new(1, 0, 0, 20)
    l.Text = " " .. text
    l.TextColor3 = isError and Color3.new(1, 0.2, 0.2) or Color3.new(1, 1, 1)
    l.BackgroundTransparency = 1
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextScaled = true
    LogFrame.CanvasPosition = Vector2.new(0, 9999)
end

-- === MAIN GUI ===
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "CloudniteMiner"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 100)
Main.Position = UDim2.new(0.5, -100, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Main.Draggable = true
Main.Active = true

local ToggleBtn = Instance.new("TextButton", Main)
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 60)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleBtn.Text = "START MINER"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.TextScaled = true

-- === ФУНКЦІЇ ===
local function fastClick()
    local pos = Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)
    VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
    task.wait(0.01)
    VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
end

local function smoothTP(targetPos)
    addLog("Телепорт (2с)...")
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
        addLog("Очікування 5с...")
        task.wait(5)
        
        -- 2. Друга точка
        if not smoothTP(POS_2) then break end
        addLog("Очікування 3с...")
        task.wait(3)
        
        -- 3. Пошук руди Cloudnite
        local oresFolder = Workspace:FindFirstChild("WorldSpawn") and Workspace.WorldSpawn:FindFirstChild("Ores")
        local ore = oresFolder and oresFolder:FindFirstChild("Cloudnite")
        
        if ore then
            addLog("Лечу до Cloudnite")
            local targetPos = ore:FindFirstChild("Hitbox") and ore.Hitbox.Position or ore:GetPivot().Position
            if not smoothTP(targetPos + Vector3.new(0, 5, 0)) then break end
            task.wait(1)
            
            local hittable = ore:FindFirstChild("Hittable")
            if hittable then
                local parts = hittable:GetChildren()
                for _, part in pairs(parts) do
                    if not isRunning then break end
                    if part:IsA("BasePart") then
                        workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, part.Position)
                        task.wait(0.2)
                        while isRunning and part.Parent == hittable do
                            fastClick()
                            task.wait(1.1)
                        end
                    end
                end
            end
        else
            addLog("Cloudnite не знайдено", true)
            task.wait(2)
        end
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        ToggleBtn.Text = "STOP MINER"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        task.spawn(startMining)
    else
        ToggleBtn.Text = "START MINER"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    end
end)
