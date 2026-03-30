local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local mouse = lp:GetMouse()

-- GUI
local gui = Instance.new("ScreenGui", lp.PlayerGui)
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 350, 0, 200)
frame.Position = UDim2.new(0.5, -175, 0.3, -100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

-- TextBox для назви об'єкта
local textbox = Instance.new("TextBox", frame)
textbox.Size = UDim2.new(0.9, 0, 0, 35)
textbox.Position = UDim2.new(0.05, 0, 0, 10)
textbox.PlaceholderText = "Введи назву об'єкта"
textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
textbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
textbox.TextScaled = true

-- Кнопка ESP + TP
local button = Instance.new("TextButton", frame)
button.Size = UDim2.new(0.9, 0, 0, 35)
button.Position = UDim2.new(0.05, 0, 0, 55)
button.Text = "ESP + TP"
button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextScaled = true

-- Label для показу шляху
local label = Instance.new("TextLabel", frame)
label.Size = UDim2.new(0.9, 0, 0, 80)
label.Position = UDim2.new(0.05, 0, 0, 100)
label.BackgroundTransparency = 0.3
label.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextWrapped = true
label.TextScaled = true
label.Font = Enum.Font.SourceSansSemibold
label.Text = "Explorer Path..."

local highlight

-- Функція для отримання шляху в Explorer
local function GetExplorerPath(inst)
    if not inst then return nil end
    local path = {}
    local current = inst
    while current do
        table.insert(path, 1, current.Name)
        if current.Parent == nil or current.Parent == game then
            break
        end
        current = current.Parent
    end
    return table.concat(path, " > ")
end

-- Функція пошуку об'єкта по назві
local function FindObjectByName(name)
    if not name or name == "" then return nil end
    return workspace:FindFirstChild(name, true)
end

-- ESP + Teleport кнопка
button.MouseButton1Click:Connect(function()
    local name = textbox.Text
    local target = FindObjectByName(name)
    if not target then
        warn("Об'єкт не знайдено")
        return
    end

    -- Highlight ESP
    if highlight then
        highlight:Destroy()
    end
    highlight = Instance.new("Highlight")
    highlight.Parent = target
    highlight.FillColor = Color3.fromRGB(255, 50, 50)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)

    -- Телепорт +5 studs
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local pos = (target:IsA("BasePart") and target.Position) or (target:GetPivot().Position)
        hrp.CFrame = CFrame.new(pos + Vector3.new(0,5,0))
    end

    -- Показати шлях у Explorer
    label.Text = "Explorer Path:\n" .. GetExplorerPath(target)
end)

-- Клік-детектор: тепер тільки показує шлях, НЕ вставляє назву в TextBox
mouse.Button1Down:Connect(function()
    local hit = mouse.Target
    if not hit then return end
    -- textbox.Text = hit.Name  -- прибрано
    label.Text = "Explorer Path:\n" .. GetExplorerPath(hit)
end)
