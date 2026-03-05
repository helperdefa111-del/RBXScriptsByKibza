-- === Services ===
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local grabHandler = ReplicatedStorage:WaitForChild("Events"):WaitForChild("GrabHandler")
local grabFolder = Workspace:WaitForChild("Grab")

-- === GUI SETUP ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MaterialGrabber_V6"
screenGui.ResetOnSpawn = false
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 380)
frame.Position = UDim2.new(0.5, -175, 0.5, -190)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true 
frame.Parent = screenGui

local function createTextBox(placeholder, pos, size)
    local tb = Instance.new("TextBox")
    tb.Size = size or UDim2.new(1, -20, 0, 35)
    tb.Position = pos
    tb.PlaceholderText = placeholder
    tb.PlaceholderColor3 = Color3.fromRGB(0, 0, 0)
    tb.Text = ""
    tb.TextScaled = true
    tb.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
    tb.TextColor3 = Color3.fromRGB(0, 0, 0)
    tb.Parent = frame
    return tb
end

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "Universal Grabber V6"
title.TextScaled = true
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Parent = frame

-- Головне поле назви об'єкта
local mainObjectNameBox = createTextBox("Назва об'єкта в Grab", UDim2.new(0, 10, 0, 45))
mainObjectNameBox.Text = "MaterialPart"

-- Блок фільтрації (ховається/показується)
local filterFrame = Instance.new("Frame")
filterFrame.Size = UDim2.new(1, -20, 0, 80)
filterFrame.Position = UDim2.new(0, 10, 0, 85)
filterFrame.BackgroundTransparency = 1
filterFrame.Visible = true -- Буде залежати від тексту в mainObjectNameBox
filterFrame.Parent = frame

local materialStringBox = createTextBox("MaterialString Value (Stone)", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 35))
materialStringBox.Parent = filterFrame

local filterToggle = Instance.new("TextButton")
filterToggle.Size = UDim2.new(1, 0, 0, 35)
filterToggle.Position = UDim2.new(0, 0, 0, 40)
filterToggle.Text = "FILTER: OFF"
filterToggle.TextScaled = true
filterToggle.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
filterToggle.TextColor3 = Color3.new(1, 1, 1)
filterToggle.Parent = filterFrame

local isFilterActive = false
filterToggle.MouseButton1Click:Connect(function()
    isFilterActive = not isFilterActive
    filterToggle.Text = isFilterActive and "FILTER: ON" or "FILTER: OFF"
    filterToggle.BackgroundColor3 = isFilterActive and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
end)

-- Радіус та Координати
local radiusBox = createTextBox("Радіус дії", UDim2.new(0, 10, 0, 170))
radiusBox.Text = "100"

local coords = {}
local coordNames = {"X", "Y", "Z"}
for i, name in ipairs(coordNames) do
    local tb = createTextBox(name, UDim2.new(0, 10 + (i-1)*110, 0, 210), UDim2.new(0, 100, 0, 35))
    coords[name] = tb
end

local getPosButton = Instance.new("TextButton")
getPosButton.Size = UDim2.new(1, -20, 0, 35)
getPosButton.Position = UDim2.new(0, 10, 0, 250)
getPosButton.Text = "Get My Pos"
getPosButton.TextScaled = true
getPosButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
getPosButton.TextColor3 = Color3.new(1, 1, 1)
getPosButton.Parent = frame

local mainButton = Instance.new("TextButton")
mainButton.Size = UDim2.new(1, -20, 0, 50)
mainButton.Position = UDim2.new(0, 10, 0, 295)
mainButton.Text = "START BRINGING"
mainButton.TextScaled = true
mainButton.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
mainButton.TextColor3 = Color3.new(1, 1, 1)
mainButton.Parent = frame

-- === ЛОГІКА ===

-- Функція показу фільтра тільки для MaterialPart
mainObjectNameBox:GetPropertyChangedSignal("Text"):Connect(function()
    filterFrame.Visible = (mainObjectNameBox.Text == "MaterialPart")
end)

getPosButton.MouseButton1Click:Connect(function()
    local char = localPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local p = char.HumanoidRootPart.Position
        coords["X"].Text = tostring(math.floor(p.X))
        coords["Y"].Text = tostring(math.floor(p.Y))
        coords["Z"].Text = tostring(math.floor(p.Z))
    end
end)

local function bringObject(targetName, x, y, z, radius)
    local targetPos = Vector3.new(x, y, z)
    local char = localPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local myPos = char.HumanoidRootPart.Position

    for _, obj in pairs(grabFolder:GetChildren()) do
        if obj.Name == targetName then
            
            -- Якщо назва "MaterialPart" і фільтр увімкнено, перевіряємо MaterialString
            if targetName == "MaterialPart" and isFilterActive then
                local config = obj:FindFirstChild("Configuration")
                local data = config and config:FindFirstChild("Data")
                local matString = data and data:FindFirstChild("MaterialString")
                
                if not (matString and matString:IsA("StringValue") and matString.Value:lower() == materialStringBox.Text:lower()) then
                    continue -- Пропускаємо, якщо значення не збігається
                end
            end
            
            -- Основна деталь для ТП
            local innerPart = obj:FindFirstChild("Part") or obj:FindFirstChildWhichIsA("BasePart")
            if not innerPart then continue end

            -- Перевірка радіусу
            if (myPos - innerPart.Position).Magnitude > radius then continue end

            -- Власник
            local owner = obj:FindFirstChild("Owner")
            if owner and owner.Value ~= nil and owner.Value ~= localPlayer then continue end

            -- Процес ТП
            if obj:IsA("Model") and not obj.PrimaryPart then
                obj.PrimaryPart = innerPart
            end

            char.HumanoidRootPart.CFrame = CFrame.new(innerPart.Position + Vector3.new(0, 3, 0))
            task.wait(0.15)
            grabHandler:InvokeServer(innerPart, "Grab", innerPart.Position)
            task.wait(0.1)
            
            if obj:IsA("Model") then
                obj:SetPrimaryPartCFrame(CFrame.new(targetPos))
            else
                obj.CFrame = CFrame.new(targetPos)
            end
            task.wait(0.05)
        end
    end
end

mainButton.MouseButton1Click:Connect(function()
    local objName = mainObjectNameBox.Text
    local r = tonumber(radiusBox.Text) or 100
    local x, y, z = tonumber(coords["X"].Text), tonumber(coords["Y"].Text), tonumber(coords["Z"].Text)
    
    if objName ~= "" and x and y and z then
        bringObject(objName, x, y, z, r)
    end
end)
