-- === Services ===
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui", 10)

-- === CLEANUP (ВИДАЛЕННЯ СТАРИХ КОПІЙ) ===
-- Шукаємо і видаляємо старе GUI, якщо воно вже є
local oldGui = playerGui:FindFirstChild("UltimateGrabber_V7_MOD")
if oldGui then
    oldGui:Destroy()
end

-- Шукаємо і видаляємо старий візуалізатор радіусу
if Workspace:FindFirstChild("RadiusVisualizer") then
    Workspace.RadiusVisualizer:Destroy()
end

-- === REST OF THE SCRIPT ===
local events = ReplicatedStorage:WaitForChild("Events", 5)
local grabHandler = events and events:WaitForChild("GrabHandler", 5)
local grabFolder = Workspace:WaitForChild("Grab", 5)

if not grabHandler or not grabFolder then
    warn("Критична помилка: Не знайдено GrabHandler!")
    return
end

-- === RADIUS VISUALIZER SETUP ===
local selectionPart = Instance.new("Part")
selectionPart.Name = "RadiusVisualizer"
selectionPart.Shape = Enum.PartType.Cylinder
selectionPart.Anchored = true
selectionPart.CanCollide = false
selectionPart.CastShadow = false
selectionPart.CanQuery = false
selectionPart.Transparency = 0.5
selectionPart.Color = Color3.fromRGB(0, 0, 0)
selectionPart.Material = Enum.Material.ForceField
selectionPart.Size = Vector3.new(1, 100, 100)
selectionPart.Orientation = Vector3.new(0, 0, 90)
selectionPart.Parent = Workspace

local visualUpdate = RunService.RenderStepped:Connect(function()
    local char = localPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        selectionPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.Angles(0, 0, math.rad(90))
    end
end)

-- === GUI SETUP ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UltimateGrabber_V7_MOD" -- Унікальна назва для очистки
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 480)
frame.Position = UDim2.new(0.5, -175, 0.5, -240)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true 
frame.Parent = screenGui

local function createTextBox(placeholder, pos, size)
    local tb = Instance.new("TextBox")
    tb.Size = size or UDim2.new(1, -20, 0, 30)
    tb.Position = pos
    tb.PlaceholderText = placeholder
    tb.PlaceholderColor3 = Color3.fromRGB(80, 80, 80)
    tb.Text = ""
    tb.TextScaled = true
    tb.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
    tb.TextColor3 = Color3.fromRGB(0, 0, 0)
    tb.Parent = frame
    return tb
end

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "Ultimate Grabber V7.2 MOD"
title.TextScaled = true
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Parent = frame

-- Елементи керування
local bringAllToggle = Instance.new("TextButton")
bringAllToggle.Size = UDim2.new(1, -20, 0, 30)
bringAllToggle.Position = UDim2.new(0, 10, 0, 40)
bringAllToggle.Text = "BRING ALL: OFF"
bringAllToggle.TextScaled = true
bringAllToggle.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
bringAllToggle.TextColor3 = Color3.new(1, 1, 1)
bringAllToggle.Parent = frame

local isBringAll = false
bringAllToggle.MouseButton1Click:Connect(function()
    isBringAll = not isBringAll
    bringAllToggle.Text = isBringAll and "BRING ALL: ON" or "BRING ALL: OFF"
    bringAllToggle.BackgroundColor3 = isBringAll and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
end)

local mainObjectNameBox = createTextBox("Назва (напр. MaterialPart)", UDim2.new(0, 10, 0, 75))
mainObjectNameBox.Text = "MaterialPart"

local filterFrame = Instance.new("Frame")
filterFrame.Size = UDim2.new(1, -20, 0, 70)
filterFrame.Position = UDim2.new(0, 10, 0, 110)
filterFrame.BackgroundTransparency = 1
filterFrame.Parent = frame

local materialStringBox = createTextBox("Material (Stone/Uranium)", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 30))
materialStringBox.Parent = filterFrame

local filterToggle = Instance.new("TextButton")
filterToggle.Size = UDim2.new(1, 0, 0, 30)
filterToggle.Position = UDim2.new(0, 0, 0, 35)
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

local radiusBox = createTextBox("Радіус дії", UDim2.new(0, 10, 0, 185))
radiusBox.Text = "50"

local limitBox = createTextBox("Ліміт штук (0 = безлім)", UDim2.new(0, 10, 0, 220))
limitBox.Text = "0"

radiusBox:GetPropertyChangedSignal("Text"):Connect(function()
    local r = tonumber(radiusBox.Text)
    if r then
        selectionPart.Size = Vector3.new(1, r * 2, r * 2)
        selectionPart.Transparency = 0.5
    else
        selectionPart.Transparency = 1
    end
end)

local coords = {}
local coordNames = {"X", "Y", "Z"}
for i, name in ipairs(coordNames) do
    local tb = createTextBox(name, UDim2.new(0, 10 + (i-1)*110, 0, 255), UDim2.new(0, 100, 0, 30))
    coords[name] = tb
end

local getPosButton = Instance.new("TextButton")
getPosButton.Size = UDim2.new(1, -20, 0, 30)
getPosButton.Position = UDim2.new(0, 10, 0, 290)
getPosButton.Text = "Get My Pos"
getPosButton.TextScaled = true
getPosButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
getPosButton.TextColor3 = Color3.new(1, 1, 1)
getPosButton.Parent = frame

local mainButton = Instance.new("TextButton")
mainButton.Size = UDim2.new(1, -20, 0, 45)
mainButton.Position = UDim2.new(0, 10, 0, 330)
mainButton.Text = "START BRINGING"
mainButton.TextScaled = true
mainButton.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
mainButton.TextColor3 = Color3.new(1, 1, 1)
mainButton.Parent = frame

local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.new(1, -20, 0, 45)
stopButton.Position = UDim2.new(0, 10, 0, 380)
stopButton.Text = "STOP PROCESS"
stopButton.TextScaled = true
stopButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
stopButton.TextColor3 = Color3.new(1, 1, 1)
stopButton.Visible = false
stopButton.Parent = frame

-- === LOGIC ===
local isStopping = false

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

stopButton.MouseButton1Click:Connect(function()
    isStopping = true
    stopButton.Text = "STOPPING..."
end)

local function bringObject(targetName, x, y, z, radius, limit)
    local targetPos = Vector3.new(x, y, z)
    local char = localPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    isStopping = false
    stopButton.Visible = true
    stopButton.Text = "STOP PROCESS"
    
    local count = 0
    local objects = grabFolder:GetChildren()

    for _, obj in pairs(objects) do
        if isStopping then break end
        if limit > 0 and count >= limit then break end

        local myPos = char.HumanoidRootPart.Position

        if isBringAll or (obj.Name == targetName) then
            if not isBringAll and targetName == "MaterialPart" and isFilterActive then
                local config = obj:FindFirstChild("Configuration")
                local data = config and config:FindFirstChild("Data")
                local matString = data and data:FindFirstChild("MaterialString")
                if not (matString and matString.Value:lower() == materialStringBox.Text:lower()) then
                    continue 
                end
            end
            
            local innerPart = obj:FindFirstChild("Part") or obj:FindFirstChildWhichIsA("BasePart")
            if not innerPart then continue end
            if (myPos - innerPart.Position).Magnitude > radius then continue end

            local owner = obj:FindFirstChild("Owner")
            if owner and owner.Value ~= nil and owner.Value ~= localPlayer then continue end

            count = count + 1
            
            if obj:IsA("Model") and not obj.PrimaryPart then
                obj.PrimaryPart = innerPart
            end

            char.HumanoidRootPart.CFrame = CFrame.new(innerPart.Position + Vector3.new(0, 3, 0))
            task.wait(0.12)
            grabHandler:InvokeServer(innerPart, "Grab", innerPart.Position)
            task.wait(0.08)
            
            if obj:IsA("Model") then
                obj:SetPrimaryPartCFrame(CFrame.new(targetPos))
            else
                obj.CFrame = CFrame.new(targetPos)
            end
            task.wait(0.05)
        end
    end
    
    stopButton.Visible = false
    isStopping = false
end

mainButton.MouseButton1Click:Connect(function()
    local r = tonumber(radiusBox.Text) or 50
    local l = tonumber(limitBox.Text) or 0
    local x, y, z = tonumber(coords["X"].Text), tonumber(coords["Y"].Text), tonumber(coords["Z"].Text)
    
    if x and y and z then
        bringObject(mainObjectNameBox.Text, x, y, z, r, l)
    end
end)

-- Важливо: при видаленні GUI через Destroy() також зупинити цикл візуалізації
screenGui.Destroying:Connect(function()
    if visualUpdate then visualUpdate:Disconnect() end
    if selectionPart then selectionPart:Destroy() end
end)
