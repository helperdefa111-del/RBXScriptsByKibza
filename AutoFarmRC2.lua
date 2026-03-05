-- Видаляємо стару копію
for _, oldGui in pairs(game:GetService("CoreGui"):GetChildren()) do
    if oldGui.Name == "AbyssaliteUltimate" then oldGui:Destroy() end
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VIM = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- === НАЛАШТУВАННЯ НАЗВ ТУЛІВ ===
local PICKAXE_NAME = "Obsidian Pickaxe" -- Заміни на точну назву твоєї кірки
local BAG_NAME = "Item Bag"         -- Заміни на точну назву свого мішка
-- ===============================

local isRunning = false
local STAGE_1 = Vector3.new(-7141, -693, -2924)
local STAGE_2 = Vector3.new(-7123, -711, -2545)
local SELL_POS = Vector3.new(1528, 30, -548)

-- === GUI ===
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
    task.wait(0.05)
    VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
end

local function spamTP(targetPos)
    for i = 1, 10 do
        if not isRunning then return false end
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(targetPos)
        end
        task.wait(0.2)
    end
    return true
end

-- Покращена функція екіпірування за назвою
local function equipToolByName(name)
    local char = player.Character
    local bp = player:FindFirstChild("Backpack")
    if char and bp then
        -- Якщо вже в руках — нічого не робимо
        if char:FindFirstChild(name) then return end
        
        local tool = bp:FindFirstChild(name)
        if tool then
            char.Humanoid:EquipTool(tool)
        else
            warn("Тул '" .. name .. "' не знайдено в Backpack!")
        end
    end
end

-- === ЦИКЛ ===
local function farm()
    while isRunning do
        print("DEBUG: Нове коло")
        
        -- 1. Беремо кірку та летимо
        equipToolByName(PICKAXE_NAME)
        if not spamTP(STAGE_1) then break end
        task.wait(2)
        if not spamTP(STAGE_2) then break end
        
        -- 2. Видобуток
        local ore = Workspace.WorldSpawn.Ores:FindFirstChild("Abyssalite")
        if ore and (ore:GetPivot().Position - STAGE_2).Magnitude <= 65 then
            if not spamTP(ore:GetPivot().Position + Vector3.new(0, 4, 0)) then break end
            
            local hittable = ore:FindFirstChild("Hittable")
            if hittable then
                while isRunning and #hittable:GetChildren() > 0 do
                    local part = hittable:GetChildren()[1]
                    workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, part.Position)
                    
                    -- Клікаємо раз на 1.1 секунди для 100% удару
                    fastClick()
                    task.wait(1.1) 
                end
            end
            
            -- 3. Збір у мішок
            task.wait(1)
            equipToolByName(BAG_NAME)
            for i = 1, 6 do
                if not isRunning then break end
                local closest = nil
                local dist = math.huge
                for _, item in pairs(Workspace.Grab:GetChildren()) do
                    if item.Name == "MaterialPart" then
                        local d = (player.Character.HumanoidRootPart.Position - item.Position).Magnitude
                        if d < dist then dist = d closest = item end
                    end
                end
                if closest then
                    workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, closest.Position)
                    task.wait(2) -- Чекаємо наведення
                    fastClick()
                    task.wait(1)
                end
            end
            
            -- 4. Продаж
            if not spamTP(STAGE_1) then break end
            task.wait(0.5)
            if not spamTP(SELL_POS) then break end
            
            for i = 1, 6 do
                if not isRunning then break end
                fastClick()
                task.wait(1.1)
            end
        else
            print("DEBUG: Руду не знайдено, очікування...")
            task.wait(5)
        end
        task.wait(1)
    end
end

-- === КЕРУВАННЯ ===
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
