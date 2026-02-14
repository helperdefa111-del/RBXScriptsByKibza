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

-- Вікно
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 180)
frame.Position = UDim2.new(0.5, -175, 0.5, -90)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "Bring To SellZone"
title.TextScaled = true
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Parent = frame

-- Поле введення назви об'єкта
local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, -20, 0, 30)
textBox.Position = UDim2.new(0, 10, 0, 40)
textBox.PlaceholderText = "Enter object name..."
textBox.Text = ""
textBox.TextScaled = true
textBox.ClearTextOnFocus = false
textBox.Parent = frame

-- Поля введення координат X, Y, Z
local coords = {}
local coordNames = {"X", "Y", "Z"}
for i, name in ipairs(coordNames) do
	local tb = Instance.new("TextBox")
	tb.Size = UDim2.new(0, 100, 0, 30)
	tb.Position = UDim2.new(0, 10 + (i-1)*110, 0, 80)
	tb.PlaceholderText = name
	tb.Text = ""
	tb.TextScaled = true
	tb.ClearTextOnFocus = false
	tb.Parent = frame
	coords[name] = tb
end

-- Кнопка Bring
local button = Instance.new("TextButton")
button.Size = UDim2.new(1, -20, 0, 30)
button.Position = UDim2.new(0, 10, 0, 130)
button.Text = "Bring Object"
button.TextScaled = true
button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Parent = frame

-- === Drag Detector для вікна ===
local dragging = false
local dragInput
local dragStart
local startPos

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			0,
			math.clamp(startPos.X.Offset + delta.X, 0, workspace.CurrentCamera.ViewportSize.X - frame.AbsoluteSize.X),
			0,
			math.clamp(startPos.Y.Offset + delta.Y, 0, workspace.CurrentCamera.ViewportSize.Y - frame.AbsoluteSize.Y)
		)
	end
end)

-- === Bring Function ===
local function bringObject(name, x, y, z)
	local targetPos = Vector3.new(x, y, z)
	for _, obj in pairs(grabFolder:GetChildren()) do
		if obj:IsA("Model") and obj.Name == name then
			local owner = obj:FindFirstChild("Owner")
			if owner and owner.Value == localPlayer then
				local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
				if primary then
					-- Підходимо до об'єкта
					localPlayer.Character:SetPrimaryPartCFrame(CFrame.new(primary.Position + Vector3.new(0, -1, 0)))
					task.wait(0.1)
					-- Викликаємо GrabHandler
					grabHandler:InvokeServer(primary, "Grab", obj:GetPivot().Position)
					task.wait(0.1)
					-- Телепортуємо на введені координати
					obj:SetPrimaryPartCFrame(CFrame.new(targetPos))
					task.wait(0.1)
				end
			end
		end
	end
end

-- Подія кнопки
button.MouseButton1Click:Connect(function()
	local objectName = textBox.Text
	local x = tonumber(coords["X"].Text)
	local y = tonumber(coords["Y"].Text)
	local z = tonumber(coords["Z"].Text)

	if objectName ~= "" and x and y and z then
		bringObject(objectName, x, y, z)
	else
		warn("Enter object name and valid X, Y, Z coordinates!")
	end
end)
