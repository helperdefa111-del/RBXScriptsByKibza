local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local events = ReplicatedStorage:WaitForChild("Events")
local grabFunc = events:WaitForChild("Grab")
local ungrabEvent = events:WaitForChild("Ungrab")
local grabableFolder = Workspace:WaitForChild("Grabable")

-- === GUI ===
local screenGui = Instance.new("ScreenGui", localPlayer.PlayerGui)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 320)
frame.Position = UDim2.new(0.5, -150, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 2
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "RC1 Private Teleporter"
title.TextColor3 = Color3.new(1, 0.8, 0)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.Parent = frame

-- Поле для фільтра назви (MatInd або просто назва об'єкта)
local nameBox = Instance.new("TextBox")
nameBox.Size = UDim2.new(0.9, 0, 0, 30)
nameBox.Position = UDim2.new(0.05, 0, 0.15, 0)
nameBox.PlaceholderText = "Назва (напр. Cobble / Iron / All)"
nameBox.Text = ""
nameBox.Parent = frame

-- Поля координат
local coords = {}
local names = {"X", "Y", "Z"}
for i, n in ipairs(names) do
    local tb = Instance.new("TextBox")
    tb.Size = UDim2.new(0, 85, 0, 30)
    tb.Position = UDim2.new(0.05 + (i-1)*0.31, 0, 0.28, 0)
    tb.PlaceholderText = n
    tb.Text = ""
    tb.Parent = frame
    coords[n] = tb
end

local getPosBtn = Instance.new("TextButton")
getPosBtn.Size = UDim2.new(0.9, 0, 0, 30)
getPosBtn.Position = UDim2.new(0.05, 0, 0.42, 0)
getPosBtn.Text = "Взяти мої координати"
getPosBtn.Parent = frame

local tpMeBtn = Instance.new("TextButton")
tpMeBtn.Size = UDim2.new(0.9, 0, 0, 30)
tpMeBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
tpMeBtn.Text = "Телепорт мене сюди"
tpMeBtn.BackgroundColor3 = Color3.fromRGB(70, 30, 100)
tpMeBtn.TextColor3 = Color3.new(1,1,1)
tpMeBtn.Parent = frame

local bringBtn = Instance.new("TextButton")
bringBtn.Size = UDim2.new(0.9, 0, 0, 60)
bringBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
bringBtn.Text = "ТЕЛЕПОРТУВАТИ МОЄ"
bringBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
bringBtn.Font = Enum.Font.SourceSansBold
bringBtn.TextSize = 20
bringBtn.TextColor3 = Color3.new(1, 1, 1)
bringBtn.Parent = frame

-- === ЛОГІКА ===

getPosBtn.MouseButton1Click:Connect(function()
    local p = localPlayer.Character.HumanoidRootPart.Position
    coords.X.Text = tostring(math.floor(p.X))
    coords.Y.Text = tostring(math.floor(p.Y))
    coords.Z.Text = tostring(math.floor(p.Z))
end)

tpMeBtn.MouseButton1Click:Connect(function()
    local x, y, z = tonumber(coords.X.Text), tonumber(coords.Y.Text), tonumber(coords.Z.Text)
    if x and y and z then
        localPlayer.Character:SetPrimaryPartCFrame(CFrame.new(x, y + 3, z))
    end
end)

bringBtn.MouseButton1Click:Connect(function()
    local x, y, z = tonumber(coords.X.Text), tonumber(coords.Y.Text), tonumber(coords.Z.Text)
    local filter = nameBox.Text:lower()
    
    if not (x and y and z) then return end
    local targetVec = Vector3.new(x, y, z)

    for _, obj in pairs(grabableFolder:GetChildren()) do
        -- 1. Перевіряємо, чи це MaterialPart або об'єкт, який ми вписали в поле
        if obj.Name == "MaterialPart" or obj.Name:lower():find(filter) then
            
            -- 2. Перевірка власника (щоб не красти в магазині/інших)
            local ownerObj = obj:FindFirstChild("Owner")
            -- Якщо Owner є, перевіряємо чи це ми. Якщо Owner немає (blueprint), пропускаємо або додаємо логіку
            if ownerObj and ownerObj:IsA("ObjectValue") and (ownerObj.Value == localPlayer or tostring(ownerObj.Value) == localPlayer.Name) then
                
                -- 3. Перевірка типу матеріалу (MatInd)
                local canBring = false
                if filter == "" or filter == "all" then
                    canBring = true
                else
                    local config = obj:FindFirstChild("Configuration")
                    local matInd = config and config:FindFirstChild("Data") and config.Data:FindFirstChild("MatInd")
                    if matInd and matInd.Value:lower():find(filter) then
                        canBring = true
                    elseif obj.Name:lower():find(filter) then
                        canBring = true
                    end
                end

                -- 4. Виконання телепортації
                if canBring then
                    -- В RC1 руда — це Part всередині Model, або сама Model
                    local mainPart = obj:IsA("BasePart") and obj or obj:FindFirstChild("Part") or obj.PrimaryPart
                    
                    if mainPart then
                        grabFunc:InvokeServer(mainPart)
                        task.wait(0.07)
                        -- Телепортуємо
                        if obj:IsA("Model") then
                            obj:SetPrimaryPartCFrame(CFrame.new(targetVec + Vector3.new(0, 5, 0)))
                        else
                            obj.CFrame = CFrame.new(targetVec + Vector3.new(0, 5, 0))
                        end
                        task.wait(0.07)
                        ungrabEvent:FireServer()
                    end
                end
            end
        end
    end
end)
