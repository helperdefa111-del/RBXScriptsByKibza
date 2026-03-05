-- Очищення
for _, oldGui in pairs(game:GetService("CoreGui"):GetChildren()) do
    if oldGui.Name == "AbyssaliteUltimate" or oldGui.Name == "AbyssaliteLogs" then oldGui:Destroy() end
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VIM = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- === ГОЛОВНІ НАЛАШТУВАННЯ ШВИДКОСТІ ===
local PICKAXE_NAME = "Obsidian Pickaxe" 
local BAG_NAME = "Item Bag"
local SELL_SPEED = 0.3    -- Швидкість викидання руди (було 0.4)
local AIM_SPEED = 0.3     -- Час наведення на шматок (було 0.5)
local COLLECT_DELAY = 0.3 -- Пауза після кліку по шматку (було 0.5)
local TP_STEPS = 20       -- Кількість кроків телепорту (було 10)
local TP_DELAY = 0.1      -- Затримка телепорту (20 * 0.1 = 2 сек)

local isRunning = false
local STAGE_1 = Vector3.new(-7141, -693, -2924)
local STAGE_2 = Vector3.new(-7123, -711, -2545)
local SELL_POS = Vector3.new(1528, 30, -548)

-- === GUI LOGS ===
local LogGui = Instance.new("ScreenGui", CoreGui)
LogGui.Name = "AbyssaliteLogs"
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
ScreenGui.Name = "AbyssaliteUltimate"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 100)
Main.Position = UDim2.new(0.5, -100, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Main.Draggable = true
Main.Active = true

local ToggleBtn = Instance.new("TextButton", Main)
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 60)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleBtn.Text = "START FARM"
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

local function spamTP(targetPos)
    addLog("Телепорт (Turbo)...")
    for i = 1, TP_STEPS do -- Тепер 20 разів
        if not isRunning then return false end
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(targetPos)
        end
        task.wait(TP_DELAY) -- Кожні 0.1 сек
    end
    return true
end

local function equip(name)
    local char = player.Character
    local bp = player:FindFirstChild("Backpack")
    if char and bp then
        local tool = char:FindFirstChild(name) or bp:FindFirstChild(name)
        if tool then 
            char.Humanoid:EquipTool(tool)
            return true
        end
    end
    return false
end

-- === ЦИКЛ ===
local function farm()
    while isRunning do
        addLog("Цикл запущено")
        equip(PICKAXE_NAME)
        
        if not spamTP(STAGE_1) then break end
        task.wait(1.5)
        if not spamTP(STAGE_2) then break end
        
        local ore = Workspace.WorldSpawn.Ores:FindFirstChild("Abyssalite")
        if ore and (ore:GetPivot().Position - STAGE_2).Magnitude <= 85 then
            addLog("Добування...")
            spamTP(ore:GetPivot().Position + Vector3.new(0, 4, 0))
            
            local hittable = ore:FindFirstChild("Hittable")
            if hittable then
                while isRunning and #hittable:GetChildren() > 0 do
                    local part = hittable:GetChildren()[1]
                    workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, part.Position)
                    fastClick()
                    task.wait(1.1) 
                end
            end
            
            -- ЗБІР
            addLog("Збір шматків...")
            task.wait(0.8) 
            equip(BAG_NAME)
            task.wait(0.5) 
            
            for i = 1, 5 do
                if not isRunning then break end
                local target = nil
                local dist = math.huge
                local grab = Workspace:FindFirstChild("Grab")
                
                if grab then
                    for _, obj in pairs(grab:GetChildren()) do
                        if obj.Name == "MaterialPart" then
                            local d = (player.Character.HumanoidRootPart.Position - obj:GetPivot().Position).Magnitude
                            if d < dist then dist = d target = obj end
                        end
                    end
                end
                
                if target then
                    workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target:GetPivot().Position)
                    task.wait(AIM_SPEED) -- 0.3 сек
                    fastClick()
                    addLog("Зібрано #"..i)
                    task.wait(COLLECT_DELAY) -- 0.3 сек
                else
                    fastClick()
                    task.wait(0.3)
                end
            end
            
            -- ПРОДАЖ
            addLog("На продаж...")
            if not spamTP(STAGE_1) then break end
            task.wait(0.5)
            if not spamTP(SELL_POS) then break end
            
            for i = 1, 6 do
                if not isRunning then break end
                fastClick()
                task.wait(SELL_SPEED) -- 0.3 сек
            end
        else
            addLog("Очікування руди", true)
            task.wait(4)
        end
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        ToggleBtn.Text = "STOP"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        task.spawn(farm)
    else
        ToggleBtn.Text = "START"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    end
end)
