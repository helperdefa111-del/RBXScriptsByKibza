-- KILASIK's Multi-Target Fling Exploit, Modified by helperdefa111 & Gemini
-- Оновлено: Додано перевірку радіусу пошуку цілей

-- Deleting old GUI if exists
if game:GetService("CoreGui"):FindFirstChild("KilasikFlingGUI") then
    game:GetService("CoreGui"):FindFirstChild("KilasikFlingGUI"):Destroy()
end

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KilasikFlingGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 560) -- Збільшено висоту для нових елементів
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -280)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -30, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "KILASIK'S MULTI-FLING"
Title.TextColor3 = Color3.fromRGB(255, 80, 80)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = TitleBar

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 18
CloseButton.Parent = TitleBar

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Position = UDim2.new(0, 10, 0, 40)
StatusLabel.Size = UDim2.new(1, -20, 0, 25)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Select targets to fling"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 16
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

-- Player Selection Frame
local SelectionFrame = Instance.new("Frame")
SelectionFrame.Position = UDim2.new(0, 10, 0, 70)
SelectionFrame.Size = UDim2.new(1, -20, 0, 140)
SelectionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SelectionFrame.BorderSizePixel = 0
SelectionFrame.Parent = MainFrame

local PlayerScrollFrame = Instance.new("ScrollingFrame")
PlayerScrollFrame.Position = UDim2.new(0, 5, 0, 5)
PlayerScrollFrame.Size = UDim2.new(1, -10, 1, -10)
PlayerScrollFrame.BackgroundTransparency = 1
PlayerScrollFrame.BorderSizePixel = 0
PlayerScrollFrame.ScrollBarThickness = 6
PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerScrollFrame.Parent = SelectionFrame

-- Object Target Section
local ObjectLabel = Instance.new("TextLabel")
ObjectLabel.Position = UDim2.new(0, 10, 0, 215)
ObjectLabel.Size = UDim2.new(1, -20, 0, 25)
ObjectLabel.BackgroundTransparency = 1
ObjectLabel.Text = "Object Target (Explorer Path):"
ObjectLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ObjectLabel.Font = Enum.Font.SourceSansBold
ObjectLabel.TextSize = 14
ObjectLabel.TextXAlignment = Enum.TextXAlignment.Left
ObjectLabel.Parent = MainFrame

local ObjectPathBox = Instance.new("TextBox")
ObjectPathBox.Position = UDim2.new(0, 10, 0, 240)
ObjectPathBox.Size = UDim2.new(1, -20, 0, 30)
ObjectPathBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ObjectPathBox.Text = "workspace.PartName"
ObjectPathBox.TextColor3 = Color3.fromRGB(255, 255, 255)
ObjectPathBox.Font = Enum.Font.SourceSans
ObjectPathBox.TextSize = 14
ObjectPathBox.ClearTextOnFocus = false
ObjectPathBox.Parent = MainFrame

-- Radius Section
local RadiusLabel = Instance.new("TextLabel")
RadiusLabel.Position = UDim2.new(0, 10, 0, 280)
RadiusLabel.Size = UDim2.new(1, -20, 0, 25)
RadiusLabel.BackgroundTransparency = 1
RadiusLabel.Text = "Search Radius (Studs):"
RadiusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
RadiusLabel.Font = Enum.Font.SourceSansBold
RadiusLabel.TextSize = 14
RadiusLabel.TextXAlignment = Enum.TextXAlignment.Left
RadiusLabel.Parent = MainFrame

local RadiusBox = Instance.new("TextBox")
RadiusBox.Position = UDim2.new(0, 10, 0, 305)
RadiusBox.Size = UDim2.new(0, 130, 0, 30)
RadiusBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
RadiusBox.Text = "100"
RadiusBox.TextColor3 = Color3.fromRGB(255, 255, 255)
RadiusBox.Font = Enum.Font.SourceSans
RadiusBox.TextSize = 14
RadiusBox.ClearTextOnFocus = false
RadiusBox.Parent = MainFrame

local RadiusToggle = Instance.new("TextButton")
RadiusToggle.Position = UDim2.new(0, 150, 0, 305)
RadiusToggle.Size = UDim2.new(0, 140, 0, 30)
RadiusToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
RadiusToggle.Text = "USE RADIUS: OFF"
RadiusToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
RadiusToggle.Font = Enum.Font.SourceSansBold
RadiusToggle.TextSize = 12
RadiusToggle.Parent = MainFrame

-- Target Mode Toggle
local ObjectToggle = Instance.new("TextButton")
ObjectToggle.Position = UDim2.new(0, 10, 0, 345)
ObjectToggle.Size = UDim2.new(1, -20, 0, 30)
ObjectToggle.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
ObjectToggle.Text = "TARGET MODE: PLAYERS"
ObjectToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ObjectToggle.Font = Enum.Font.SourceSansBold
ObjectToggle.TextSize = 14
ObjectToggle.Parent = MainFrame

-- Start/Stop Buttons
local StartButton = Instance.new("TextButton")
StartButton.Position = UDim2.new(0, 10, 0, 390)
StartButton.Size = UDim2.new(0.5, -15, 0, 40)
StartButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
StartButton.Text = "START FLING"
StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StartButton.Font = Enum.Font.SourceSansBold
StartButton.TextSize = 18
StartButton.Parent = MainFrame

local StopButton = Instance.new("TextButton")
StopButton.Position = UDim2.new(0.5, 5, 0, 390)
StopButton.Size = UDim2.new(0.5, -15, 0, 40)
StopButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
StopButton.Text = "STOP FLING"
StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StopButton.Font = Enum.Font.SourceSansBold
StopButton.TextSize = 18
StopButton.Parent = MainFrame

-- Select Buttons
local SelectAllButton = Instance.new("TextButton")
SelectAllButton.Position = UDim2.new(0, 10, 0, 440)
SelectAllButton.Size = UDim2.new(0.5, -15, 0, 30)
SelectAllButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SelectAllButton.Text = "SELECT ALL"
SelectAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SelectAllButton.Parent = MainFrame

local DeselectAllButton = Instance.new("TextButton")
DeselectAllButton.Position = UDim2.new(0.5, 5, 0, 440)
DeselectAllButton.Size = UDim2.new(0.5, -15, 0, 30)
DeselectAllButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
DeselectAllButton.Text = "DESELECT ALL"
DeselectAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DeselectAllButton.Parent = MainFrame

-- Variables
local SelectedTargets = {}
local PlayerCheckboxes = {}
local FlingActive = false
local TargetObjectsMode = false
local UseRadius = false
getgenv().OldPos = nil
getgenv().FPDH = workspace.FallenPartsDestroyHeight

-- Toggles Logic
ObjectToggle.MouseButton1Click:Connect(function()
    TargetObjectsMode = not TargetObjectsMode
    ObjectToggle.BackgroundColor3 = TargetObjectsMode and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(60, 0, 0)
    ObjectToggle.Text = TargetObjectsMode and "TARGET MODE: OBJECT PATH" or "TARGET MODE: PLAYERS"
    UpdateStatus()
end)

RadiusToggle.MouseButton1Click:Connect(function()
    UseRadius = not UseRadius
    RadiusToggle.BackgroundColor3 = UseRadius and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
    RadiusToggle.Text = UseRadius and "USE RADIUS: ON" or "USE RADIUS: OFF"
end)

-- Find Object
local function GetObjectFromPath(path)
    local success, result = pcall(function()
        local segments = path:split(".")
        local current = game
        for _, name in ipairs(segments) do
            current = current:FindFirstChild(name)
        end
        return current
    end)
    return success and result or nil
end

-- Distance Check
local function IsInRadius(targetPart)
    if not UseRadius then return true end
    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not targetPart then return false end
    
    local radius = tonumber(RadiusBox.Text) or 100
    return (root.Position - targetPart.Position).Magnitude <= radius
end

-- Refresh Player List
local function RefreshPlayerList()
    for _, child in pairs(PlayerScrollFrame:GetChildren()) do child:Destroy() end
    PlayerCheckboxes = {}
    local PlayerList = Players:GetPlayers()
    table.sort(PlayerList, function(a, b) return a.Name:lower() < b.Name:lower() end)
    
    local yPosition = 5
    for _, player in ipairs(PlayerList) do
        if player ~= Player then
            local PlayerEntry = Instance.new("Frame")
            PlayerEntry.Size = UDim2.new(1, -10, 0, 30)
            PlayerEntry.Position = UDim2.new(0, 5, 0, yPosition)
            PlayerEntry.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            PlayerEntry.BorderSizePixel = 0
            PlayerEntry.Parent = PlayerScrollFrame
            
            local Checkbox = Instance.new("TextButton")
            Checkbox.Size = UDim2.new(0, 24, 0, 24)
            Checkbox.Position = UDim2.new(0, 3, 0.5, -12)
            Checkbox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            Checkbox.Text = ""
            Checkbox.Parent = PlayerEntry
            
            local Checkmark = Instance.new("TextLabel")
            Checkmark.Size = UDim2.new(1, 0, 1, 0)
            Checkmark.BackgroundTransparency = 1
            Checkmark.Text = "✓"
            Checkmark.TextColor3 = Color3.fromRGB(0, 255, 0)
            Checkmark.Visible = SelectedTargets[player.Name] ~= nil
            Checkmark.Parent = Checkbox
            
            local NameLabel = Instance.new("TextLabel")
            NameLabel.Size = UDim2.new(1, -35, 1, 0)
            NameLabel.Position = UDim2.new(0, 30, 0, 0)
            NameLabel.BackgroundTransparency = 1
            NameLabel.Text = player.Name
            NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            NameLabel.TextXAlignment = Enum.TextXAlignment.Left
            NameLabel.Parent = PlayerEntry
            
            local ClickArea = Instance.new("TextButton")
            ClickArea.Size = UDim2.new(1, 0, 1, 0)
            ClickArea.BackgroundTransparency = 1
            ClickArea.Text = ""
            ClickArea.ZIndex = 2
            ClickArea.Parent = PlayerEntry
            
            ClickArea.MouseButton1Click:Connect(function()
                if SelectedTargets[player.Name] then
                    SelectedTargets[player.Name] = nil
                    Checkmark.Visible = false
                else
                    SelectedTargets[player.Name] = player
                    Checkmark.Visible = true
                end
                UpdateStatus()
            end)
            
            PlayerCheckboxes[player.Name] = {Entry = PlayerEntry, Checkmark = Checkmark}
            yPosition = yPosition + 35
        end
    end
    PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPosition + 5)
end

local function CountSelectedTargets()
    local count = 0
    for _ in pairs(SelectedTargets) do count = count + 1 end
    return count
end

local function UpdateStatus()
    if TargetObjectsMode then
        StatusLabel.Text = "Mode: Target Object"
        StatusLabel.TextColor3 = Color3.fromRGB(80, 150, 255)
    else
        local count = CountSelectedTargets()
        StatusLabel.Text = FlingActive and "Flinging " .. count .. " target(s)" or count .. " target(s) selected"
        StatusLabel.TextColor3 = FlingActive and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(255, 255, 255)
    end
end

local function Message(Title, Text, Time)
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = Title, Text = Text, Duration = Time or 5})
end

-- Fling Logic
local function SkidFling(Target)
    local Character = Player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    
    local TargetPart = nil
    local TargetHumanoid = nil

    if Target:IsA("Player") then
        if Target.Character then
            TargetPart = Target.Character:FindFirstChild("HumanoidRootPart") or Target.Character:FindFirstChild("Head")
            TargetHumanoid = Target.Character:FindFirstChildOfClass("Humanoid")
        end
    elseif Target:IsA("BasePart") then
        TargetPart = Target
    elseif Target:IsA("Model") then
        TargetPart = Target.PrimaryPart or Target:FindFirstChildWhichIsA("BasePart")
    end

    if not TargetPart or not IsInRadius(TargetPart) then return end
    if not Character or not RootPart or not Humanoid then return end

    if RootPart.Velocity.Magnitude < 50 then getgenv().OldPos = RootPart.CFrame end

    workspace.CurrentCamera.CameraSubject = TargetPart
    workspace.FallenPartsDestroyHeight = 0/0

    local FPos = function(BasePart, Pos, Ang)
        RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
        Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
        RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
        RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
    end

    local SFBasePart = function(BasePart)
        local TimeToWait = 2
        local Time = tick()
        local Angle = 0
        repeat
            if RootPart then
                Angle = Angle + 100
                local moveDir = (TargetHumanoid and TargetHumanoid.MoveDirection) or Vector3.new(0,0,0)
                FPos(BasePart, CFrame.new(0, 1.5, 0) + moveDir * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                task.wait()
                FPos(BasePart, CFrame.new(0, -1.5, 0) + moveDir * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                task.wait()
            end
        until Time + TimeToWait < tick() or not FlingActive
    end

    local BV = Instance.new("BodyVelocity")
    BV.Parent = RootPart
    BV.Velocity = Vector3.new(0, 0, 0)
    BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

    SFBasePart(TargetPart)

    BV:Destroy()
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    workspace.CurrentCamera.CameraSubject = Humanoid

    if getgenv().OldPos then
        repeat
            RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
            Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
            task.wait()
        until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
        workspace.FallenPartsDestroyHeight = getgenv().FPDH
    end
end

-- Start/Stop
local function StartFling()
    if FlingActive then return end
    FlingActive = true
    UpdateStatus()
    
    spawn(function()
        while FlingActive do
            if TargetObjectsMode then
                local obj = GetObjectFromPath(ObjectPathBox.Text)
                if obj then SkidFling(obj) else StopFling() Message("Error", "Invalid Path", 2) end
            else
                for name, player in pairs(SelectedTargets) do
                    if player and player.Parent and FlingActive then SkidFling(player) wait(0.1) end
                end
            end
            wait(0.5)
        end
    end)
end

function StopFling()
    FlingActive = false
    UpdateStatus()
end

StartButton.MouseButton1Click:Connect(StartFling)
StopButton.MouseButton1Click:Connect(StopFling)
SelectAllButton.MouseButton1Click:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player then
            SelectedTargets[player.Name] = player
            if PlayerCheckboxes[player.Name] then PlayerCheckboxes[player.Name].Checkmark.Visible = true end
        end
    end
    UpdateStatus()
end)
DeselectAllButton.MouseButton1Click:Connect(function()
    SelectedTargets = {}
    for _, data in pairs(PlayerCheckboxes) do data.Checkmark.Visible = false end
    UpdateStatus()
end)
CloseButton.MouseButton1Click:Connect(function() StopFling() ScreenGui:Destroy() end)

Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(function(player) SelectedTargets[player.Name] = nil RefreshPlayerList() UpdateStatus() end)

RefreshPlayerList()
UpdateStatus()
Message("Loaded", "Fling GUI with Radius Support Loaded!", 3)
