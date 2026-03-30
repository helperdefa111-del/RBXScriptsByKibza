local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ObjectPathInput = Instance.new("TextBox")
local XInput = Instance.new("TextBox")
local YInput = Instance.new("TextBox")
local ZInput = Instance.new("TextBox")
local TeleportBtn = Instance.new("TextButton")
local GetPosBtn = Instance.new("TextButton")
local SelectBtn = Instance.new("TextButton")
local Title = Instance.new("TextLabel")

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

-- Налаштування GUI
ScreenGui.Parent = game.CoreGui
MainFrame.Name = "VisualEditorV2"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -130)
MainFrame.Size = UDim2.new(0, 250, 0, 280)
MainFrame.Active = true
MainFrame.Draggable = true

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "Kibza Visual Mover"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

-- Поле для шляху
ObjectPathInput.Parent = MainFrame
ObjectPathInput.PlaceholderText = "Шлях до об'єкта..."
ObjectPathInput.Position = UDim2.new(0.1, 0, 0.15, 0)
ObjectPathInput.Size = UDim2.new(0.8, 0, 0, 30)

-- Кнопка вибору кліком
SelectBtn.Parent = MainFrame
SelectBtn.Text = "SELECT BY CLICK"
SelectBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
SelectBtn.Position = UDim2.new(0.1, 0, 0.28, 0)
SelectBtn.Size = UDim2.new(0.8, 0, 0, 25)
SelectBtn.TextColor3 = Color3.new(1, 1, 1)
SelectBtn.TextSize = 12

-- Поля для координат
local function setupCoord(box, pos, txt)
    box.Parent = MainFrame
    box.PlaceholderText = txt
    box.Position = pos
    box.Size = UDim2.new(0.25, 0, 0, 30)
end
setupCoord(XInput, UDim2.new(0.1, 0, 0.4, 0), "X")
setupCoord(YInput, UDim2.new(0.37, 0, 0.4, 0), "Y")
setupCoord(ZInput, UDim2.new(0.65, 0, 0.4, 0), "Z")

-- Кнопка отримати свої координати
GetPosBtn.Parent = MainFrame
GetPosBtn.Text = "GET MY POS"
GetPosBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 150)
GetPosBtn.Position = UDim2.new(0.1, 0, 0.55, 0)
GetPosBtn.Size = UDim2.new(0.8, 0, 0, 30)
GetPosBtn.TextColor3 = Color3.new(1, 1, 1)

-- Кнопка ТЕЛЕПОРТ
TeleportBtn.Parent = MainFrame
TeleportBtn.Text = "MOVE OBJECT"
TeleportBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 0)
TeleportBtn.Position = UDim2.new(0.1, 0, 0.75, 0)
TeleportBtn.Size = UDim2.new(0.8, 0, 0, 45)
TeleportBtn.TextColor3 = Color3.new(1, 1, 1)
TeleportBtn.Font = Enum.Font.SourceSansBold

--- ЛОГІКА ---

-- Функція для отримання шляху
local function getFullPath(obj)
    local path = obj.Name
    local current = obj.Parent
    while current and current ~= game do
        path = current.Name .. "." .. path
        current = current.Parent
    end
    return path
end

-- Вибір об'єкта мишкою
SelectBtn.MouseButton1Click:Connect(function()
    SelectBtn.Text = "CLICK ON OBJECT..."
    local connection
    connection = mouse.Button1Down:Connect(function()
        if mouse.Target then
            ObjectPathInput.Text = getFullPath(mouse.Target)
            SelectBtn.Text = "SELECTED!"
            task.wait(1)
            SelectBtn.Text = "SELECT BY CLICK"
            connection:Disconnect()
        end
    end)
end)

-- Отримати позицію гравця
GetPosBtn.MouseButton1Click:Connect(function()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local pos = root.Position
        XInput.Text = tostring(math.floor(pos.X))
        YInput.Text = tostring(math.floor(pos.Y))
        ZInput.Text = tostring(math.floor(pos.Z))
    end
end)

-- Телепортація об'єкта за вказаним шляхом
TeleportBtn.MouseButton1Click:Connect(function()
    local pathSegments = ObjectPathInput.Text:split(".")
    local target = game
    
    for _, name in ipairs(pathSegments) do
        if name == "game" then continue end
        target = target:FindFirstChild(name)
        if not target then break end
    end
    
    local x, y, z = tonumber(XInput.Text), tonumber(YInput.Text), tonumber(ZInput.Text)
    
    if target and x and y and z then
        if target:IsA("BasePart") then
            target.CFrame = CFrame.new(x, y, z)
        elseif target:IsA("Model") then
            target:MoveTo(Vector3.new(x, y, z))
        end
    else
        warn("Помилка: перевір шлях або координати!")
    end
end)
