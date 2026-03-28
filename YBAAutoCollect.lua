local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- 1. Видалення старого GUI
local oldGui = player:WaitForChild("PlayerGui"):FindFirstChild("KibzaRokaUltra")
if oldGui then oldGui:Destroy() end

-- Створення GUI
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ToggleButton = Instance.new("TextButton")
local AllToggle = Instance.new("TextButton") -- Новий перемикач
local ItemInput = Instance.new("TextBox")
local SpeedLabel = Instance.new("TextLabel")
local SliderBackground = Instance.new("Frame")
local SliderFill = Instance.new("Frame")

ScreenGui.Name = "KibzaRokaUltra"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Головна панель
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 200, 0, 200) -- Трохи збільшив висоту
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Функція для створення кнопок (щоб код був чистішим)
local function createButton(name, text, pos, color)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Parent = MainFrame
    btn.BackgroundColor3 = color
    btn.Position = pos
    btn.Size = UDim2.new(0.8, 0, 0.18, 0)
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    local corn = Instance.new("UICorner")
    corn.CornerRadius = UDim.new(0, 6)
    corn.Parent = btn
    return btn
end

-- Кнопки та Поля
ToggleButton = createButton("ToggleFarm", "FARM: OFF", UDim2.new(0.1, 0, 0.08, 0), Color3.fromRGB(180, 50, 50))
AllToggle = createButton("AllToggle", "COLLECT ALL: OFF", UDim2.new(0.1, 0, 0.28, 0), Color3.fromRGB(80, 80, 80))

ItemInput.Name = "ItemInput"
ItemInput.Parent = MainFrame
ItemInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ItemInput.Position = UDim2.new(0.1, 0, 0.48, 0)
ItemInput.Size = UDim2.new(0.8, 0, 0.15, 0)
ItemInput.Font = Enum.Font.Gotham
ItemInput.PlaceholderText = "Назва предмета..."
ItemInput.Text = "Rokakaka"
ItemInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ItemInput.TextSize = 11
local InpCorn = Instance.new("UICorner")
InpCorn.Parent = ItemInput

SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Parent = MainFrame
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Position = UDim2.new(0.1, 0, 0.65, 0)
SpeedLabel.Size = UDim2.new(0.8, 0, 0.1, 0)
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLabel.TextSize = 11

SliderBackground.Name = "SliderBackground"
SliderBackground.Parent = MainFrame
SliderBackground.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SliderBackground.Position = UDim2.new(0.1, 0, 0.8, 0)
SliderBackground.Size = UDim2.new(0.8, 0, 0.05, 0)

SliderFill.Name = "SliderFill"
SliderFill.Parent = SliderBackground
SliderFill.BackgroundColor3 = Color3.fromRGB(100, 160, 255)
SliderFill.Size = UDim2.new(0.3, 0, 1, 0)

-- Логічні змінні
local isFarming = false
local collectAll = false
local currentSpeed = 35
local targetItem = "Rokakaka"

-- Обробка слайдера
local function updateSlider(input)
    local size = math.clamp((input.Position.X - SliderBackground.AbsolutePosition.X) / SliderBackground.AbsoluteSize.X, 0, 1)
    SliderFill.Size = UDim2.new(size, 0, 1, 0)
    currentSpeed = math.floor(size * 150)
    SpeedLabel.Text = "Speed: " .. tostring(currentSpeed)
end

SliderBackground.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local con
        con = UserInputService.InputChanged:Connect(function(change)
            if change.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(change) end
        end)
        UserInputService.InputEnded:Connect(function(ended)
            if ended.UserInputType == Enum.UserInputType.MouseButton1 then con:Disconnect() end
        end)
    end
end)

-- Перемикачі
ToggleButton.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    ToggleButton.Text = isFarming and "FARM: ON" or "FARM: OFF"
    ToggleButton.BackgroundColor3 = isFarming and Color3.fromRGB(50, 160, 50) or Color3.fromRGB(160, 50, 50)
end)

AllToggle.MouseButton1Click:Connect(function()
    collectAll = not collectAll
    AllToggle.Text = collectAll and "COLLECT ALL: ON" or "COLLECT ALL: OFF"
    AllToggle.BackgroundColor3 = collectAll and Color3.fromRGB(50, 120, 180) or Color3.fromRGB(80, 80, 80)
    ItemInput.Visible = not collectAll -- Ховаємо поле вводу, якщо збираємо все
end)

ItemInput.FocusLost:Connect(function() targetItem = ItemInput.Text end)

-- Основний Цикл
task.spawn(function()
    local folder = workspace:WaitForChild("Item_Spawns"):WaitForChild("Items")
    
    while true do
        if isFarming then
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            
            for _, item in pairs(folder:GetChildren()) do
                if not isFarming then break end
                
                local prompt = item:FindFirstChild("ProximityPrompt")
                
                -- Умова збору: або (Все підряд) або (Тільки вказаний текст)
                if prompt and (collectAll or prompt.ObjectText == targetItem) then
                    local targetPart = item:FindFirstChild("MeshPart") or item:FindFirstChild("Handle") or item.PrimaryPart
                    
                    if root and targetPart then
                        local dist = (root.Position - targetPart.Position).Magnitude
                        local duration = dist / math.max(currentSpeed, 1)
                        
                        local tween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPart.Position + Vector3.new(0, 3, 0))})
                        tween:Play()
                        tween.Completed:Wait()
                        
                        task.wait(0.2)
                        fireproximityprompt(prompt)
                        task.wait(0.5)
                    end
                end
            end
        end
        task.wait(1)
    end
end)

SpeedLabel.Text = "Speed: " .. tostring(currentSpeed)
