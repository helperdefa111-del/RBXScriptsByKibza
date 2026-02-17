-- === Services ===
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- === Variables ===
local autoAimEnabled = false
local autoAimEnemiesEnabled = false
local holdRightClick = false
local aimDistance = 800
local noclipEnabled = false
local followEnabled = false
local espEnabled = false
local savedPosition = nil
local selectedPlayer = nil 
local guiKey = Enum.KeyCode.RightControl
local imageID = "rbxassetid://118991382621971"
local targetFOV = 120

-- Wallhop & ESP Management
local wallhopESP = false
local autoWallhopEnabled = false
local flickStrength = 40
local RADIUS = 25
local HIGHLIGHT_COLOR = Color3.fromRGB(0, 255, 255)
local bindKey1 = Enum.KeyCode.V
local bindKey2 = Enum.KeyCode.G
local secondBindEnabled = false
local isBinding1 = false
local isBinding2 = false
local activeHighlights = {}
local activeESP = {} -- Таблиця для збереження об'єктів ESP

-- === UI Setup ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KibzaMulti_V4_Final"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 100

-- Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Size = UDim2.new(0, 60, 0, 60)
toggleBtn.Position = UDim2.new(0, 20, 0.5, -30)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
toggleBtn.Text = "KIBZA"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 12
toggleBtn.Draggable = true
toggleBtn.Active = true
toggleBtn.ZIndex = 100
toggleBtn.Parent = ScreenGui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 16)

-- Main Frame
local MainFrame = Instance.new("ImageLabel")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 420)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.Image = imageID
MainFrame.ScaleType = Enum.ScaleType.Crop
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 100
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame)

local Overlay = Instance.new("Frame")
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Overlay.BackgroundTransparency = 0.7
Overlay.ZIndex = 100
Overlay.Parent = MainFrame
Instance.new("UICorner", Overlay)

toggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- === TAB SYSTEM ===
local TabButtonsFrame = Instance.new("Frame")
TabButtonsFrame.Size = UDim2.new(1, 0, 0, 40)
TabButtonsFrame.BackgroundTransparency = 1
TabButtonsFrame.ZIndex = 101
TabButtonsFrame.Parent = MainFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -60)
ContentFrame.Position = UDim2.new(0, 10, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ZIndex = 101
ContentFrame.Parent = MainFrame

local function switchTab(targetFrame, activeBtn)
    for _, child in pairs(ContentFrame:GetChildren()) do
        if child:IsA("ScrollingFrame") then child.Visible = false end
    end
    for _, btn in pairs(TabButtonsFrame:GetChildren()) do
        if btn:IsA("TextButton") then
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            btn.BackgroundTransparency = 0.3
        end
    end
    targetFrame.Visible = true
    activeBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    activeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    activeBtn.BackgroundTransparency = 0
end

local function createTabButton(text, positionX, widthScale)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = UDim2.new(widthScale, -4, 0, 35)
    btn.Position = UDim2.new(positionX, 2, 0, 2)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.ZIndex = 102
    btn.Parent = TabButtonsFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local function createContentScroll()
    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.ScrollBarThickness = 4
    sf.Visible = false
    sf.ZIndex = 102
    sf.Parent = ContentFrame
    local layout = Instance.new("UIListLayout", sf)
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    return sf
end

local Tab1 = createContentScroll()
local Tab2 = createContentScroll()
local Tab3 = createContentScroll()
local Tab4 = createContentScroll()
local Tab5 = createContentScroll()

local Btn1 = createTabButton("Interactions", 0, 0.2)
local Btn2 = createTabButton("Local Player", 0.2, 0.2)
local Btn3 = createTabButton("In Game", 0.4, 0.2)
local Btn4 = createTabButton("Other", 0.6, 0.2)
local Btn5 = createTabButton("Troll", 0.8, 0.2)

Btn1.MouseButton1Click:Connect(function() switchTab(Tab1, Btn1) end)
Btn2.MouseButton1Click:Connect(function() switchTab(Tab2, Btn2) end)
Btn3.MouseButton1Click:Connect(function() switchTab(Tab3, Btn3) end)
Btn4.MouseButton1Click:Connect(function() switchTab(Tab4, Btn4) end)
Btn5.MouseButton1Click:Connect(function() switchTab(Tab5, Btn5) end)
switchTab(Tab1, Btn1)

-- === HELPER FUNCTIONS ===
local function createBtn(text, parent, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 35)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.BackgroundTransparency = 0.2
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 18
    btn.Font = Enum.Font.Gotham
    btn.ZIndex = 103
    btn.Parent = parent
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function() callback(btn) end)
    return btn
end

local function createToggle(text, parent, default, callback)
    local btn = createBtn(text .. ": OFF", parent, function() end)
    local toggled = default
    local function updateUI()
        btn.Text = text .. ": " .. (toggled and "ON" or "OFF")
        btn.BackgroundColor3 = toggled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(50, 50, 50)
    end
    btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        updateUI()
        callback(toggled)
    end)
    if default then updateUI() end
    return btn
end

local function createInputRow(labelTxt, parent, defaultVal, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 35)
    frame.BackgroundTransparency = 1
    frame.ZIndex = 103
    frame.Parent = parent
    local lbl = Instance.new("TextLabel")
    lbl.Text = labelTxt
    lbl.Size = UDim2.new(0.4, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.Font = Enum.Font.Gotham
    lbl.ZIndex = 104
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    local box = Instance.new("TextBox")
    box.Text = defaultVal
    box.Size = UDim2.new(0.55, 0, 1, 0)
    box.Position = UDim2.new(0.45, 0, 0, 0)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.TextScaled = true
    box.BackgroundTransparency = 0.3
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.Gotham
    box.ZIndex = 104
    box.Parent = frame
    Instance.new("UICorner", box)
    box:GetPropertyChangedSignal("Text"):Connect(function() callback(box.Text) end)
end

----------------------------------------------------------------------
-- TAB 1: PLAYER INTERACTIONS (Logic)
----------------------------------------------------------------------
local selPlayerLabel = Instance.new("TextLabel")
selPlayerLabel.Text = "Target: None"
selPlayerLabel.Size = UDim2.new(0.95, 0, 0, 30)
selPlayerLabel.BackgroundColor3 = Color3.fromRGB(40,40,40)
selPlayerLabel.BackgroundTransparency = 0.3
selPlayerLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
selPlayerLabel.ZIndex = 103
selPlayerLabel.Parent = Tab1
Instance.new("UICorner", selPlayerLabel)

local dropdownFrame = Instance.new("ScrollingFrame")
dropdownFrame.Size = UDim2.new(0.95, 0, 0, 150)
dropdownFrame.Visible = false
dropdownFrame.BackgroundTransparency = 0.5
dropdownFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
dropdownFrame.ZIndex = 110
dropdownFrame.Parent = Tab1
Instance.new("UIListLayout", dropdownFrame)

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, 0, 0, 30)
searchBox.PlaceholderText = "Search Player..."
searchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.ZIndex = 111
searchBox.Parent = dropdownFrame

local function updatePlayerList()
    for _, v in pairs(dropdownFrame:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    local searchText = searchBox.Text:lower()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and (searchText == "" or p.Name:lower():find(searchText) or p.DisplayName:lower():find(searchText)) then
            local pBtn = Instance.new("TextButton")
            pBtn.Text = p.DisplayName .. " (@" .. p.Name .. ")"
            pBtn.Size = UDim2.new(1, 0, 0, 30)
            pBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
            pBtn.TextColor3 = Color3.fromRGB(255,255,255)
            pBtn.ZIndex = 112
            pBtn.Parent = dropdownFrame
            pBtn.MouseButton1Click:Connect(function()
                selectedPlayer = p
                selPlayerLabel.Text = "Target: " .. p.Name
                dropdownFrame.Visible = false
            end)
        end
    end
end
searchBox:GetPropertyChangedSignal("Text"):Connect(updatePlayerList)

createBtn("Select Player ▼", Tab1, function()
    dropdownFrame.Visible = not dropdownFrame.Visible
    if dropdownFrame.Visible then updatePlayerList() end
end)

createBtn("TP to Target", Tab1, function()
    if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame
    end
end)

createToggle("Follow Target", Tab1, false, function(state) followEnabled = state end)

----------------------------------------------------------------------
-- TAB 2: LOCAL PLAYER (Logic)
----------------------------------------------------------------------
----------------------------------------------------------------------
-- TAB 2: LOCAL PLAYER (Enhanced with XYZ Teleport)
----------------------------------------------------------------------
local xyzLabel = Instance.new("TextLabel")
xyzLabel.Size = UDim2.new(0.95, 0, 0, 30)
xyzLabel.Text = "XYZ: 0, 0, 0"
xyzLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
xyzLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
xyzLabel.BackgroundTransparency = 0.5
xyzLabel.TextSize = 25
xyzLabel.ZIndex = 103
xyzLabel.Font = Enum.Font.Code
xyzLabel.Parent = Tab2

createInputRow("WalkSpeed:", Tab2, "16", function(val)
    if LocalPlayer.Character then LocalPlayer.Character.Humanoid.WalkSpeed = tonumber(val) or 16 end
end)
createInputRow("JumpPower:", Tab2, "50", function(val)
    if LocalPlayer.Character then LocalPlayer.Character.Humanoid.JumpPower = tonumber(val) or 50 end
end)
createInputRow("Field of View:", Tab2, "70", function(val) targetFOV = tonumber(val) or 70 end)

--- Секція ручного Телепорту ---
local coordFrame = Instance.new("Frame")
coordFrame.Size = UDim2.new(0.95, 0, 0, 35)
coordFrame.BackgroundTransparency = 1
coordFrame.ZIndex = 103
coordFrame.Parent = Tab2

local layout = Instance.new("UIListLayout", coordFrame)
layout.FillDirection = Enum.FillDirection.Horizontal
layout.Padding = UDim.new(0, 5)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function createCoordBox(placeholder)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.32, 0, 1, 0)
    box.PlaceholderText = placeholder
    box.Text = ""
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.BackgroundTransparency = 0.3
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.Code
    box.TextScaled = true
    box.ZIndex = 104
    box.Parent = coordFrame
    Instance.new("UICorner", box)
    return box
end

local inputX = createCoordBox("X")
local inputY = createCoordBox("Y")
local inputZ = createCoordBox("Z")

-- Кнопка для отримання поточних координат (для зручності)
createBtn("Get Current Position", Tab2, function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local pos = LocalPlayer.Character.HumanoidRootPart.Position
        inputX.Text = string.format("%.1f", pos.X)
        inputY.Text = string.format("%.1f", pos.Y)
        inputZ.Text = string.format("%.1f", pos.Z)
    end
end)

-- Кнопка самого телепорту
createBtn("Teleport to XYZ", Tab2, function(btn)
    local x = tonumber(inputX.Text)
    local y = tonumber(inputY.Text)
    local z = tonumber(inputZ.Text)
    
    if x and y and z then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
            btn.Text = "Success!"
            task.wait(1)
            btn.Text = "Teleport to XYZ"
        end
    else
        btn.Text = "Invalid Coordinates!"
        task.wait(1)
        btn.Text = "Teleport to XYZ"
    end
end)

----------------------------------------------------------------------
-- TAB 3: IN GAME (Advanced ESP, Tracers & Object Eraser)
----------------------------------------------------------------------
local TweenService = game:GetService("TweenService")
local Mouse = LocalPlayer:GetMouse()

-- Змінні для видалення об'єктів
local deleteEnabled = false
local deletedObjects = {} 
local restoreKey = Enum.KeyCode.X 
local isBindingRestore = false

local tracersEnabled = false
local activeTracers = {}

-- Функція для відновлення останнього об'єкта
local function restoreLastObject()
    if #deletedObjects > 0 then
        local data = table.remove(deletedObjects, #deletedObjects)
        local restored = Instance.new("Part")
        restored.Name = data.Name
        restored.Size = data.Size
        restored.CFrame = data.CFrame
        restored.Color = data.Color
        restored.Material = data.Material
        restored.Transparency = data.Transparency
        restored.CanCollide = data.CanCollide
        restored.Anchored = data.Anchored
        restored.Parent = data.Parent
    end
end

-- Логіка кліку для видалення
Mouse.Button1Down:Connect(function()
    if deleteEnabled and Mouse.Target then
        local obj = Mouse.Target
        if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) then
            table.insert(deletedObjects, {
                Name = obj.Name,
                Size = obj.Size,
                CFrame = obj.CFrame,
                Color = obj.Color,
                Material = obj.Material,
                Transparency = obj.Transparency,
                CanCollide = obj.CanCollide,
                Anchored = obj.Anchored,
                Parent = obj.Parent
            })
            obj:Destroy()
        end
    end
end)

local function removeESP(character)
    if character:FindFirstChild("ESP_Highlight") then character.ESP_Highlight:Destroy() end
    if character:FindFirstChild("ESP_Billboard") then character.ESP_Billboard:Destroy() end
end

local function applyESP(player)
    if player == LocalPlayer then return end
    local function setup(character)
        removeESP(character)
        if not espEnabled then return end
        local hrp = character:WaitForChild("HumanoidRootPart", 10)
        local head = character:WaitForChild("Head", 10)
        local hum = character:WaitForChild("Humanoid", 10)
        if not hrp or not head or not hum then return end

        local hl = Instance.new("Highlight")
        hl.Name = "ESP_Highlight"; hl.Adornee = character; hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.FillColor = (player.Team == LocalPlayer.Team) and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
        hl.Parent = character

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_Billboard"; billboard.Adornee = head; billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0); billboard.AlwaysOnTop = true; billboard.Parent = character

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1, 1, 1); label.TextStrokeTransparency = 0
        label.Font = Enum.Font.GothamBold; label.TextSize = 14; label.Parent = billboard

        local connection
        connection = RunService.Heartbeat:Connect(function()
            if not character.Parent or not head.Parent or not espEnabled then
                removeESP(character); connection:Disconnect(); return
            end
            local myPos = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) and LocalPlayer.Character.HumanoidRootPart.Position or Camera.CFrame.Position
            local dist = math.floor((myPos - head.Position).Magnitude)
            label.Text = string.format("%s\nHP: %d | %d studs", player.DisplayName or player.Name, math.floor(hum.Health), dist)
        end)
    end
    player.CharacterAdded:Connect(setup)
    if player.Character then task.spawn(setup, player.Character) end
end

createToggle("Auto Aim", Tab3, false, function(s) autoAimEnabled = s end)
createToggle("Enemies Only", Tab3, false, function(s) autoAimEnemiesEnabled = s end)
createToggle("Noclip", Tab3, false, function(s) noclipEnabled = s end)

-- --- СЕКЦІЯ DELETE OBJECTS З АНІМАЦІЄЮ ---
local restoreBtn
createToggle("Delete Objects", Tab3, false, function(state)
    deleteEnabled = state
    if state then
        restoreBtn.Visible = true
        TweenService:Create(restoreBtn, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(0.95, 0, 0, 35)}):Play()
    else
        local t = TweenService:Create(restoreBtn, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0.95, 0, 0, 0)})
        t:Play(); t.Completed:Connect(function() if not deleteEnabled then restoreBtn.Visible = false end end)
    end
end)

restoreBtn = createBtn("↳ Restore Bind: " .. restoreKey.Name, Tab3, function(b) isBindingRestore = true; b.Text = "..." end)
restoreBtn.Visible = false; restoreBtn.ClipsDescendants = true; restoreBtn.Size = UDim2.new(0.95, 0, 0, 0)
-- ---------------------------------------

local tracerBtn
createToggle("Advanced ESP", Tab3, false, function(state)
    espEnabled = state
    if state then
        tracerBtn.Visible = true
        TweenService:Create(tracerBtn, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(0.95, 0, 0, 35)}):Play()
    else
        local t = TweenService:Create(tracerBtn, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0.95, 0, 0, 0)})
        t:Play(); t.Completed:Connect(function() if not espEnabled then tracerBtn.Visible = false end end)
    end
    for _, p in pairs(Players:GetPlayers()) do if p.Character then if state then applyESP(p) else removeESP(p.Character) end end end
end)

tracerBtn = createToggle("↳ Tracers", Tab3, false, function(state) tracersEnabled = state end)
tracerBtn.Visible = false; tracerBtn.ClipsDescendants = true; tracerBtn.Size = UDim2.new(0.95, 0, 0, 0)

createBtn("Save Position", Tab3, function(btn)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        savedPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
        btn.Text = "Saved!"; task.wait(1); btn.Text = "Save Position"
    end
end)
createBtn("Teleport Saved", Tab3, function() if savedPosition and LocalPlayer.Character then LocalPlayer.Character.HumanoidRootPart.CFrame = savedPosition end end)

Players.PlayerAdded:Connect(applyESP)

----------------------------------------------------------------------
-- TAB 4: OTHER (Wallhop & Standard Tools)
----------------------------------------------------------------------
local function animateGroup(canvasList, show)
    for _, item in pairs(canvasList) do
        if show then
            item.Visible = true
            TweenService:Create(item, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(0.95, 0, 0, 35)}):Play()
        else
            local t = TweenService:Create(item, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0.95, 0, 0, 0)})
            t:Play()
            t.Completed:Connect(function() if item.Size.Y.Offset <= 1 then item.Visible = false end end)
        end
    end
end

local wallhopGroup = {}
createToggle("Wallhop Features", Tab4, false, function(state) animateGroup(wallhopGroup, state) end)
local w1 = createToggle("↳ Wallhop ESP", Tab4, false, function(state)
    wallhopESP = state
    if not state then for part, highlight in pairs(activeHighlights) do if highlight then highlight:Destroy() end activeHighlights[part] = nil end end
end)
local w2 = createToggle("↳ Auto-Flick", Tab4, false, function(state) autoWallhopEnabled = state end)
local w3 = createBtn("↳ 1st Bind: " .. (bindKey1 and bindKey1.Name or "None"), Tab4, function(b) isBinding1 = true; b.Text = "..." end)
local w4 = createToggle("↳ 2nd Bind ON", Tab4, false, function(state) secondBindEnabled = state end)
local w5 = createBtn("↳ 2nd Bind: " .. (bindKey2 and bindKey2.Name or "None"), Tab4, function(b) isBinding2 = true; b.Text = "..." end)
wallhopGroup = {w1, w2, w3, w4, w5}
for _, v in pairs(wallhopGroup) do v.Visible = false; v.ClipsDescendants = true; v.Size = UDim2.new(0.95, 0, 0, 0) end

local toolsGroup = {}
createToggle("Other Tools", Tab4, false, function(state) animateGroup(toolsGroup, state) end)
local t1 = createBtn("Fly GUI V3", Tab4, function() loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))() end)
local t2 = createBtn("Fly With Car GUI", Tab4, function() loadstring(game:HttpGet("https://raw.githubusercontent.com/helperdefa111-del/RBXScriptsByKibza/refs/heads/main/FlyWithCarModified.lua"))() end)
local t3 = createBtn("Dex Explorer", Tab4, function() loadstring(game:HttpGet("https://raw.githubusercontent.com/BigBoyTimme/New.Loadstring.Scripts/refs/heads/main/Dex.Explorer"))() end)
local t4 = createBtn("Piano player", Tab4, function() loadstring(game:HttpGet("https://hellohellohell0.com/talentless-raw/TALENTLESS.lua", true))()
toolsGroup = {t1, t2, t3, t4}
for _, v in pairs(toolsGroup) do v.Visible = false; v.ClipsDescendants = true; v.Size = UDim2.new(0.95, 0, 0, 0) end

----------------------------------------------------------------------
-- TAB 5: TROLL (Fling, Play Off & Advanced Follow)
----------------------------------------------------------------------
local function createLabel(text, parent)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.95, 0, 0, 25)
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.Parent = parent
    return lbl
end

createLabel("--- Troll Scripts ---", Tab5)

createBtn("Fling GUI", Tab5, function() 
    loadstring(game:HttpGet("https://raw.githubusercontent.com/helperdefa111-del/RBXScriptsByKibza/refs/heads/main/FlingModified.lua"))() 
end)

createBtn("Play off (Gone)", Tab5, function() 
    loadstring(game:HttpGet("https://pastefy.app/wa3v2Vgm/raw"))()
    loadstring(game:HttpGet("https://pastefy.app/YZoglOyJ/raw"))()
end)

createLabel("--- Advanced Follow ---", Tab5)

createBtn("Advance Follow GUI", Tab5, function()
    -- Встав сюди своє RAW посилання з GitHub
    loadstring(game:HttpGet("https://raw.githubusercontent.com/helperdefa111-del/RBXScriptsByKibza/refs/heads/main/AdvancedFollowScript.lua"))()
end)

----------------------------------------------------------------------
-- CORE ENGINE
----------------------------------------------------------------------
local function doFlick()
    local originalCFrame = Camera.CFrame
    Camera.CFrame = originalCFrame * CFrame.Angles(0, math.rad(flickStrength), 0)
    RunService.Heartbeat:Wait()
    Camera.CFrame = originalCFrame
end

local function getClosestPlayer()
    local target, shortestDist = nil, aimDistance
    local mouseLoc = UserInputService:GetMouseLocation()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            if autoAimEnemiesEnabled and p.Team == LocalPlayer.Team then continue end
            local pos, onScreen = Camera:WorldToScreenPoint(p.Character.Head.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - mouseLoc).Magnitude
                if dist < shortestDist then shortestDist = dist; target = p end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    Camera.FieldOfView = targetFOV
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local p = LocalPlayer.Character.HumanoidRootPart.Position
        xyzLabel.Text = string.format("XYZ: %.1f, %.1f, %.1f", p.X, p.Y, p.Z)
        
        if followEnabled and selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame
        end

        if wallhopESP then
            local parts = workspace:GetPartBoundsInRadius(p, RADIUS)
            for _, part in pairs(parts) do
                if part:IsA("BasePart") and part.CanCollide and not activeHighlights[part] then
                    local sb = Instance.new("SelectionBox")
                    sb.Adornee = part; sb.Color3 = HIGHLIGHT_COLOR; sb.LineThickness = 0.05
                    sb.Transparency = 0.4; sb.Parent = part; activeHighlights[part] = sb
                end
            end
        end
    end

    if tracersEnabled and espEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                local line = activeTracers[player.Name]
                if not line then line = Drawing.new("Line"); line.Thickness = 2; line.Transparency = 0.8; activeTracers[player.Name] = line end
                if onScreen then
                    line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    line.To = Vector2.new(vector.X, vector.Y)
                    line.Color = (player.Team == LocalPlayer.Team) and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                    line.Visible = true
                else line.Visible = false end
            else if activeTracers[player.Name] then activeTracers[player.Name].Visible = false end end
        end
    else for _, line in pairs(activeTracers) do line.Visible = false end end

    if holdRightClick and (autoAimEnabled or autoAimEnemiesEnabled) then
        local target = getClosestPlayer()
        if target and target.Character:FindFirstChild("Head") then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position) end
    end
end)

RunService.Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then holdRightClick = true end
    if input.KeyCode == guiKey then MainFrame.Visible = not MainFrame.Visible end
    
    if isBindingRestore then
        restoreKey = input.KeyCode; restoreBtn.Text = "↳ Restore Bind: " .. restoreKey.Name; isBindingRestore = false
    elseif input.KeyCode == restoreKey then
        restoreLastObject()
    end

    if isBinding1 then
        bindKey1 = input.KeyCode; w3.Text = "↳ 1st Bind: " .. (bindKey1.Name); isBinding1 = false
    elseif isBinding2 then
        bindKey2 = input.KeyCode; w5.Text = "↳ 2nd Bind: " .. (bindKey2.Name); isBinding2 = false
    elseif autoWallhopEnabled then
        if input.KeyCode == (bindKey1 or Enum.KeyCode.Unknown) or (secondBindEnabled and input.KeyCode == (bindKey2 or Enum.KeyCode.Unknown)) then doFlick() end
    end
end)

UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton2 then holdRightClick = false end end)
