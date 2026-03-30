local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ObjectPathInput = Instance.new("TextBox")
local XInput = Instance.new("TextBox")
local YInput = Instance.new("TextBox")
local ZInput = Instance.new("TextBox")
local RInput = Instance.new("TextBox") -- Поле для оберту
local TeleportBtn = Instance.new("TextButton")
local GetPosBtn = Instance.new("TextButton")
local SelectBtn = Instance.new("TextButton")
local Title = Instance.new("TextLabel")
local UICorner = Instance.new("UICorner")

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

-- Налаштування GUI
ScreenGui.Parent = game.CoreGui
MainFrame.Name = "KibzaVisualMover_V3"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
MainFrame.Size = UDim2.new(0, 250, 0, 330)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = UICorner:Clone()
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "Kibza Visual Mover"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

-- Поле ШЛЯХУ
ObjectPathInput.Parent = MainFrame
ObjectPathInput.PlaceholderText = "Workspace.Path.To.Object"
ObjectPathInput.Text = "Workspace."
ObjectPathInput.ClearTextOnFocus = false
ObjectPathInput.Position = UDim2.new(0.1, 0, 0.15, 0)
ObjectPathInput.Size = UDim2.new(0.8, 0, 0, 30)
ObjectPathInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ObjectPathInput.TextColor3 = Color3.new(1, 1, 1)

-- Кнопка вибору кліком
SelectBtn.Parent = MainFrame
SelectBtn.Text = "SELECT BY CLICK"
SelectBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SelectBtn.Position = UDim2.new(0.1, 0, 0.27, 0)
SelectBtn.Size = UDim2.new(0.8, 0, 0, 25)
SelectBtn.TextColor3 = Color3.new(1, 1, 1)

-- Поля координат та ОБЕРТУ
local function createInput(box, pos, size, txt)
    box.Parent = MainFrame
    box.PlaceholderText = txt
    box.ClearTextOnFocus = false
    box.Position = pos
    box.Size = size
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.TextColor3 = Color3.new(1, 1, 1)
end

createInput(XInput, UDim2.new(0.1, 0, 0.38, 0), UDim2.new(0.25, 0, 0, 30), "X")
createInput(YInput, UDim2.new(0.37, 0, 0.38, 0), UDim2.new(0.25, 0, 0, 30), "Y")
createInput(ZInput, UDim2.new(0.65, 0, 0.38, 0), UDim2.new(0.25, 0, 0, 30), "Z")
createInput(RInput, UDim2.new(0.1, 0, 0.50, 0), UDim2.new(0.8, 0, 0, 30), "ROTATION (0-360)")

-- Кнопка GET MY POS
GetPosBtn.Parent = MainFrame
GetPosBtn.Text = "GET MY POS"
GetPosBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 140)
GetPosBtn.Position = UDim2.new(0.1, 0, 0.63, 0)
GetPosBtn.Size = UDim2.new(0.8, 0, 0, 30)
GetPosBtn.TextColor3 = Color3.new(1, 1, 1)

-- Кнопка MOVE
TeleportBtn.Parent = MainFrame
TeleportBtn.Text = "MOVE OBJECT"
TeleportBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
TeleportBtn.Position = UDim2.new(0.1, 0, 0.77, 0)
TeleportBtn.Size = UDim2.new(0.8, 0, 0, 45)
TeleportBtn.TextColor3 = Color3.new(1, 1, 1)
TeleportBtn.Font = Enum.Font.SourceSansBold

--- ЛОГІКА ---

-- Закриття/Відкриття на F4
game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.F4 then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Отримання шляху
local function getFullPath(obj)
    local names = {}
    local current = obj
    while current and current ~= game do
        table.insert(names, 1, current.Name)
        current = current.Parent
    end
    return table.concat(names, ".")
end

-- Вибір кліком
SelectBtn.MouseButton1Click:Connect(function()
    SelectBtn.Text = "CLICK ON OBJECT..."
    local conn
    conn = mouse.Button1Down:Connect(function()
        if mouse.Target then
            local target = mouse.Target
            local actual = target:FindFirstAncestorOfClass("Model") or target
            ObjectPathInput.Text = getFullPath(actual)
            SelectBtn.Text = "SELECTED!"
            task.wait(0.5)
            SelectBtn.Text = "SELECT BY CLICK"
            conn:Disconnect()
        end
    end)
end)

-- Позиція гравця
GetPosBtn.MouseButton1Click:Connect(function()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        XInput.Text = tostring(math.floor(root.Position.X))
        YInput.Text = tostring(math.floor(root.Position.Y))
        ZInput.Text = tostring(math.floor(root.Position.Z))
        RInput.Text = tostring(math.floor(root.Orientation.Y)) -- Також копіюємо твій поворот
    end
end)

-- ТЕЛЕПОРТ + ОБЕРТ
TeleportBtn.MouseButton1Click:Connect(function()
    local segments = ObjectPathInput.Text:split(".")
    local target = game
    for _, name in ipairs(segments) do
        if name == "game" then continue end
        target = target:FindFirstChild(name)
        if not target then break end
    end

    local x, y, z = tonumber(XInput.Text), tonumber(YInput.Text), tonumber(ZInput.Text)
    local rotY = tonumber(RInput.Text) or 0

    if target and x and y and z then
        -- Створюємо новий CFrame з координатами та обертом (переводимо градуси в радіани)
        local newCFrame = CFrame.new(x, y, z) * CFrame.Angles(0, math.rad(rotY), 0)
        
        if target:IsA("BasePart") then
            target.CFrame = newCFrame
        elseif target:IsA("Model") then
            if target.PrimaryPart then
                target:SetPrimaryPartCFrame(newCFrame)
            else
                target:MoveTo(Vector3.new(x, y, z)) -- Якщо немає PrimaryPart, просто переносимо
            end
        end
    else
        warn("Помилка даних!")
    end
end)
