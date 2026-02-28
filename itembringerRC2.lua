-- === Services ===
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local grabHandler = ReplicatedStorage:WaitForChild("Events"):WaitForChild("GrabHandler")
local grabFolder = Workspace:WaitForChild("Grab")

-- === GUI ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BringToSellGUI"
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- Вікно (трохи збільшив висоту для нового поля)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 220)
frame.Position = UDim2.new(0.5, -175, 0.5, -110)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Bring To SellZone (Radius Mode)"
title.TextScaled = true
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Parent = frame

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, -20, 0, 30)
textBox.Position = UDim2.new(0, 10, 0, 40)
textBox.PlaceholderText = "Назва руди (напр. Oak_Log або Iron)..."
textBox.Text = ""
textBox.TextScaled = true
textBox.Parent = frame

-- Поле для Радіусу
local radiusBox = Instance.new("TextBox")
radiusBox.Size = UDim2.new(1, -20, 0, 30)
radiusBox.Position = UDim2.new(0, 10, 0, 75)
radiusBox.PlaceholderText = "Радіус дії (напр. 20)"
radiusBox.Text = "20" -- Значення за замовчуванням
radiusBox.TextScaled = true
radiusBox.Parent = frame

-- Поля координат
local coords = {}
local coordNames = {"X", "Y", "Z"}
for i, name in ipairs(coordNames) do
    local tb = Instance.new("TextBox")
    tb.Size = UDim2.new(0, 100, 0, 30)
    tb.Position = UDim2.new(0, 10 + (i-1)*110, 0, 115)
    tb.PlaceholderText = name
    tb.Text = ""
    tb.TextScaled = true
    tb.Parent = frame
    coords[name] = tb
end

local button = Instance.new("TextButton")
button.Size = UDim2.new(1, -20, 0, 40)
button.Position = UDim2.new(0, 10, 0, 160)
button.Text = "Bring Object"
button.TextScaled = true
button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Parent = frame

-- === Drag Logic (спрощена) ===
local dragging, dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- === Bring Function with Radius Filter ===
local function bringObject(name, x, y, z, radius)
    local targetPos = Vector3.new(x, y, z)
    local character = localPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local myPos = character.HumanoidRootPart.Position

    for _, obj in pairs(grabFolder:GetChildren()) do
        -- Перевірка назви
        if obj:IsA("Model") and obj.Name == name then
            local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            
            if primary then
                -- ПЕРЕВІРКА ДИСТАНЦІЇ
                local distance = (myPos - primary.Position).Magnitude
                
                if distance <= radius then
                    -- Перевірка власника (Owner)
                    local owner = obj:FindFirstChild("Owner")
                    if owner and (owner.Value == localPlayer or owner.Value == nil) then
                        
                        -- 1. ТП до об'єкта для активації Grab
                        character:SetPrimaryPartCFrame(CFrame.new(primary.Position + Vector3.new(0, 3, 0)))
                        task.wait(0.1)
                        
                        -- 2. Grab
                        grabHandler:InvokeServer(primary, "Grab", primary.Position)
                        task.wait(0.1)
                        
                        -- 3. Телепорт об'єкта в ціль
                        obj:SetPrimaryPartCFrame(CFrame.new(targetPos))
                        task.wait(0.1)
                    end
                end
            end
        end
    end
end

-- Подія кнопки
button.MouseButton1Click:Connect(function()
    local objectName = textBox.Text
    local r = tonumber(radiusBox.Text) or 20
    local x = tonumber(coords["X"].Text)
    local y = tonumber(coords["Y"].Text)
    local z = tonumber(coords["Z"].Text)

    if objectName ~= "" and x and y and z then
        bringObject(objectName, x, y, z, r)
    else
        warn("Заповніть назву, координати та радіус!")
    end
end)
