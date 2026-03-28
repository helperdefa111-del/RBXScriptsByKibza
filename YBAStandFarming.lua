local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

-- Видалення старого GUI
if player.PlayerGui:FindFirstChild("KibzaStandRoller") then
    player.PlayerGui.KibzaStandRoller:Destroy()
end

-- Створення GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KibzaStandRoller"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false 

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Size = UDim2.new(0, 200, 0, 220)
MainFrame.Position = UDim2.new(0.8, 0, 0.4, 0)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local UIList = Instance.new("UIListLayout", MainFrame)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.Padding = UDim.new(0, 8)
UIList.VerticalAlignment = Enum.VerticalAlignment.Center

local InfoLabel = Instance.new("TextLabel", MainFrame)
InfoLabel.Size = UDim2.new(0.9, 0, 0.15, 0)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Наведи на 'Yes' і тисни P"
InfoLabel.TextColor3 = Color3.new(1, 1, 1)
InfoLabel.TextSize = 10
InfoLabel.Font = Enum.Font.Gotham

-- Змінні координат
local savedX, savedY = 0, 0

-- Збереження позиції на клавішу P
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.P then
        local mousePos = UserInputService:GetMouseLocation()
        savedX, savedY = mousePos.X, mousePos.Y
        InfoLabel.Text = "ЗБЕРЕЖЕНО: " .. math.floor(savedX) .. ", " .. math.floor(savedY)
        InfoLabel.TextColor3 = Color3.new(0.2, 1, 0.2)
        task.wait(1)
        InfoLabel.TextColor3 = Color3.new(1, 1, 1)
    end
end)

-- Функція подвійного кліку
local function clickAtSavedPos()
    if savedX == 0 then return end
    
    local waitTime = 1.2 -- Затримка, яку можна регулювати
    
    -- Перший клік
    task.wait(waitTime)
    VirtualInputManager:SendMouseButtonEvent(savedX, savedY, 0, true, game, 1)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(savedX, savedY, 0, false, game, 1)
    print("Перший клік виконано")
    
    -- ДРУГИЙ КЛІК (з таким же очікуванням)
    task.wait(waitTime)
    VirtualInputManager:SendMouseButtonEvent(savedX, savedY, 0, true, game, 1)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(savedX, savedY, 0, false, game, 1)
    print("Другий клік виконано")
end

-- Використання предметів
local function useItem(itemName)
    local char = player.Character
    local backpack = player:FindFirstChild("Backpack")
    local tool = backpack and backpack:FindFirstChild(itemName)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if tool and hum then
        hum:EquipTool(tool)
        task.wait(0.5)
        tool:Activate()
        clickAtSavedPos()
    else
        warn("Предмет " .. itemName .. " не знайдено!")
    end
end

-- Кнопки
local function createBtn(text, color, func)
    local b = Instance.new("TextButton", MainFrame)
    b.Text = text
    b.Size = UDim2.new(0.9, 0, 0.2, 0)
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(func)
end

createBtn("EAT ROKAKAKA", Color3.fromRGB(180, 50, 50), function() useItem("Rokakaka") end)
createBtn("USE ARROW", Color3.fromRGB(180, 160, 40), function() useItem("Mysterious Arrow") end)
createBtn("WORTHINESS", Color3.fromRGB(180, 80, 180), function()
    local char = player.Character
    local remote = char and char:FindFirstChild("RemoteFunction")
    if remote then
        local skills = {"Vitality I", "Vitality II", "Vitality III", "Worthiness"}
        for _, s in pairs(skills) do
            remote:InvokeServer("LearnSkill", {["SkillTreeType"] = "Character", ["Skill"] = s})
            task.wait(0.3)
        end
    end
end)
