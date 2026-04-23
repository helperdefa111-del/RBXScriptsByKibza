-- ============================================================
-- COMBINED: Vehicle Fly GUI + Vehicle Teleporter GUI
-- ============================================================

-- ========================
-- SERVICES
-- ========================
local PlayerService = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = PlayerService.LocalPlayer
if not player then
    player = PlayerService.PlayerAdded:Wait()
end
player:WaitForChild("PlayerGui")

-- ========================
-- MAIN GUI INSTANCES
-- ========================
local ScreenGui       = Instance.new("ScreenGui")
local MainFrame       = Instance.new("Frame")
local TitleBar        = Instance.new("Frame")
local TitleLabel      = Instance.new("TextLabel")
local MinimizeButton  = Instance.new("TextButton")
local CloseButton     = Instance.new("TextButton")

-- Tab Buttons
local TabBar          = Instance.new("Frame")
local FlyTabButton    = Instance.new("TextButton")
local TPTabButton     = Instance.new("TextButton")

-- Tab Frames
local FlyFrame        = Instance.new("Frame")
local TPFrame         = Instance.new("Frame")

-- ========================
-- FLY TAB INSTANCES
-- ========================
local SpeedTextBox    = Instance.new("TextBox")
local DecreaseButton  = Instance.new("TextButton")
local IncreaseButton  = Instance.new("TextButton")
local FlyButton       = Instance.new("TextButton")
local FwFButton       = Instance.new("TextButton")
local ControllerButton= Instance.new("TextButton")

-- Controller GUI
local ControllerGui   = Instance.new("ScreenGui")
local ControllerFrame = Instance.new("Frame")
local ForwardButton   = Instance.new("TextButton")
local BackwardButton  = Instance.new("TextButton")
local LeftButton      = Instance.new("TextButton")
local RightButton     = Instance.new("TextButton")
local AntiLockButton  = Instance.new("TextButton")
local PitchButton     = Instance.new("TextButton")

-- Left Side GUI
local LeftSideGui         = Instance.new("ScreenGui")
local LeftSideFrame       = Instance.new("Frame")
local UpButton            = Instance.new("TextButton")
local DownButton          = Instance.new("TextButton")
local RotateLeftButton    = Instance.new("TextButton")
local RotateRightButton   = Instance.new("TextButton")

-- ========================
-- TP TAB INSTANCES
-- ========================
local XTextBox        = Instance.new("TextBox")
local YTextBox        = Instance.new("TextBox")
local ZTextBox        = Instance.new("TextBox")
local TeleportButton  = Instance.new("TextButton")
local GetPosButton    = Instance.new("TextButton")

-- ========================
-- FLY STATE VARIABLES
-- ========================
local velocityHandlerName     = "VehicleFlyVelocity32"
local gyroHandlerName         = "VehicleFlyGyro64"
local VelocityHandler         = nil
local GyroHandler             = nil
local isAntiLockOn            = false
local FlyEnabled              = false
local seatConnection          = nil
local unseatConnection        = nil
local flightWithoutFlyEnabled = false
local isPitchOn               = false
local activeConnections       = {}
local controllerEnabled       = false
local movementDirection       = {}
local keyUpHeld               = false
local keyDownHeld             = false
local forwardVelocity         = 100
local leftVelocity            = 100
local rightVelocity           = 100
local upVelocity              = 50
local downVelocity            = 50
local rotationSpeed           = 5
local isGuiMinimized          = false
local originalMainFrameSize   = nil
local originalButtonPositions = {}

-- ============================================================
-- HELPER: Style a button uniformly
-- ============================================================
local function styleButton(btn, color, text)
    btn.BackgroundColor3 = color or Color3.fromRGB(80, 80, 80)
    btn.Font = Enum.Font.GothamBold
    btn.Text = text or ""
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
end

-- ============================================================
-- GUI INITIALIZATION
-- ============================================================
local function initializeGUI()
    -- ---- Main ScreenGui ----
    ScreenGui.Parent         = player.PlayerGui
    ScreenGui.ResetOnSpawn   = false
    ScreenGui.Name           = "VehicleCombinedGui"

    -- ---- Main Frame ----
    MainFrame.Parent          = ScreenGui
    MainFrame.BackgroundColor3= Color3.fromRGB(35, 35, 35)
    MainFrame.Position        = UDim2.new(0.3, 0, 0.35, 0)
    MainFrame.Size            = UDim2.new(0, 230, 0, 310)
    MainFrame.Active          = true
    MainFrame.Draggable       = true
    MainFrame.ClipsDescendants= true

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = MainFrame

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color     = Color3.fromRGB(0, 0, 0)
    mainStroke.Thickness = 2
    mainStroke.Parent    = MainFrame

    -- ---- Title Bar ----
    TitleBar.Parent           = MainFrame
    TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TitleBar.Size             = UDim2.new(1, 0, 0, 36)
    TitleBar.Position         = UDim2.new(0, 0, 0, 0)

    TitleLabel.Parent             = TitleBar
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Size               = UDim2.new(1, -80, 1, 0)
    TitleLabel.Position           = UDim2.new(0, 10, 0, 0)
    TitleLabel.Font               = Enum.Font.GothamBold
    TitleLabel.Text               = "🚗 Vehicle Tools"
    TitleLabel.TextColor3         = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextScaled         = true
    TitleLabel.TextXAlignment     = Enum.TextXAlignment.Left

    MinimizeButton.Parent           = TitleBar
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    MinimizeButton.Position         = UDim2.new(1, -56, 0.5, -10)
    MinimizeButton.Size             = UDim2.new(0, 22, 0, 20)
    MinimizeButton.Font             = Enum.Font.GothamBold
    MinimizeButton.Text             = "⇧"
    MinimizeButton.TextColor3       = Color3.fromRGB(255, 255, 255)
    MinimizeButton.TextScaled       = true
    local mCorner = Instance.new("UICorner"); mCorner.CornerRadius = UDim.new(0,4); mCorner.Parent = MinimizeButton

    CloseButton.Parent           = TitleBar
    CloseButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    CloseButton.Position         = UDim2.new(1, -30, 0.5, -10)
    CloseButton.Size             = UDim2.new(0, 22, 0, 20)
    CloseButton.Font             = Enum.Font.GothamBold
    CloseButton.Text             = "✕"
    CloseButton.TextColor3       = Color3.fromRGB(255, 255, 255)
    CloseButton.TextScaled       = true
    local cCorner = Instance.new("UICorner"); cCorner.CornerRadius = UDim.new(0,4); cCorner.Parent = CloseButton

    -- ---- Tab Bar ----
    TabBar.Parent           = MainFrame
    TabBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    TabBar.Size             = UDim2.new(1, 0, 0, 30)
    TabBar.Position         = UDim2.new(0, 0, 0, 36)

    FlyTabButton.Parent           = TabBar
    FlyTabButton.BackgroundColor3 = Color3.fromRGB(0, 130, 200)
    FlyTabButton.Position         = UDim2.new(0, 0, 0, 0)
    FlyTabButton.Size             = UDim2.new(0.5, 0, 1, 0)
    FlyTabButton.Font             = Enum.Font.GothamBold
    FlyTabButton.Text             = "✈ Fly"
    FlyTabButton.TextColor3       = Color3.fromRGB(255, 255, 255)
    FlyTabButton.TextScaled       = true

    TPTabButton.Parent            = TabBar
    TPTabButton.BackgroundColor3  = Color3.fromRGB(60, 60, 60)
    TPTabButton.Position          = UDim2.new(0.5, 0, 0, 0)
    TPTabButton.Size              = UDim2.new(0.5, 0, 1, 0)
    TPTabButton.Font              = Enum.Font.GothamBold
    TPTabButton.Text              = "📍 Teleport"
    TPTabButton.TextColor3        = Color3.fromRGB(200, 200, 200)
    TPTabButton.TextScaled        = true

    -- ---- Fly Tab Frame ----
    FlyFrame.Parent           = MainFrame
    FlyFrame.BackgroundTransparency = 1
    FlyFrame.Position         = UDim2.new(0, 0, 0, 66)
    FlyFrame.Size             = UDim2.new(1, 0, 1, -66)
    FlyFrame.Visible          = true

    -- Speed row
    DecreaseButton.Parent   = FlyFrame
    DecreaseButton.Size     = UDim2.new(0.2, 0, 0, 28)
    DecreaseButton.Position = UDim2.new(0.05, 0, 0.04, 0)
    styleButton(DecreaseButton, Color3.fromRGB(80, 80, 80), "-")
    originalButtonPositions[DecreaseButton] = DecreaseButton.Position

    SpeedTextBox.Parent           = FlyFrame
    SpeedTextBox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    SpeedTextBox.Position         = UDim2.new(0.3, 0, 0.04, 0)
    SpeedTextBox.Size             = UDim2.new(0.4, 0, 0, 28)
    SpeedTextBox.Font             = Enum.Font.Gotham
    SpeedTextBox.Text             = "1"
    SpeedTextBox.PlaceholderText  = "Speed"
    SpeedTextBox.TextColor3       = Color3.fromRGB(255, 255, 255)
    SpeedTextBox.TextScaled       = true
    local sCorner = Instance.new("UICorner"); sCorner.CornerRadius = UDim.new(0,6); sCorner.Parent = SpeedTextBox
    originalButtonPositions[SpeedTextBox] = SpeedTextBox.Position

    IncreaseButton.Parent   = FlyFrame
    IncreaseButton.Size     = UDim2.new(0.2, 0, 0, 28)
    IncreaseButton.Position = UDim2.new(0.75, 0, 0.04, 0)
    styleButton(IncreaseButton, Color3.fromRGB(80, 80, 80), "+")
    originalButtonPositions[IncreaseButton] = IncreaseButton.Position

    FlyButton.Parent   = FlyFrame
    FlyButton.Size     = UDim2.new(0.43, 0, 0, 32)
    FlyButton.Position = UDim2.new(0.05, 0, 0.25, 0)
    styleButton(FlyButton, Color3.fromRGB(0, 150, 0), "Fly")
    originalButtonPositions[FlyButton] = FlyButton.Position

    FwFButton.Parent   = FlyFrame
    FwFButton.Size     = UDim2.new(0.43, 0, 0, 32)
    FwFButton.Position = UDim2.new(0.52, 0, 0.25, 0)
    styleButton(FwFButton, Color3.fromRGB(80, 80, 80), "FwF")
    originalButtonPositions[FwFButton] = FwFButton.Position

    ControllerButton.Parent   = FlyFrame
    ControllerButton.Size     = UDim2.new(0.9, 0, 0, 30)
    ControllerButton.Position = UDim2.new(0.05, 0, 0.5, 0)
    styleButton(ControllerButton, Color3.fromRGB(70, 70, 70), "Controller")
    originalButtonPositions[ControllerButton] = ControllerButton.Position

    -- ---- TP Tab Frame ----
    TPFrame.Parent          = MainFrame
    TPFrame.BackgroundTransparency = 1
    TPFrame.Position        = UDim2.new(0, 0, 0, 66)
    TPFrame.Size            = UDim2.new(1, 0, 1, -66)
    TPFrame.Visible         = false

    local function makeInput(placeholder, yPos)
        local tb = Instance.new("TextBox")
        tb.Parent           = TPFrame
        tb.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        tb.Position         = UDim2.new(0.08, 0, yPos, 0)
        tb.Size             = UDim2.new(0.84, 0, 0, 30)
        tb.Font             = Enum.Font.Gotham
        tb.PlaceholderText  = placeholder
        tb.Text             = ""
        tb.TextColor3       = Color3.fromRGB(255, 255, 255)
        tb.TextScaled       = true
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = tb
        return tb
    end

    XTextBox = makeInput("X Coordinate", 0.04)
    YTextBox = makeInput("Y Coordinate", 0.22)
    ZTextBox = makeInput("Z Coordinate", 0.40)

    GetPosButton.Parent   = TPFrame
    GetPosButton.Size     = UDim2.new(0.84, 0, 0, 30)
    GetPosButton.Position = UDim2.new(0.08, 0, 0.58, 0)
    styleButton(GetPosButton, Color3.fromRGB(90, 90, 90), "Get My Pos")

    TeleportButton.Parent   = TPFrame
    TeleportButton.Size     = UDim2.new(0.84, 0, 0, 38)
    TeleportButton.Position = UDim2.new(0.08, 0, 0.74, 0)
    styleButton(TeleportButton, Color3.fromRGB(0, 150, 0), "TELEPORT VEHICLE")

    -- ========================
    -- Controller GUI (right pad)
    -- ========================
    ControllerGui.Parent       = player.PlayerGui
    ControllerGui.ResetOnSpawn = false
    ControllerGui.Enabled      = false
    ControllerGui.Name         = "VehicleFlyControllerGui"

    ControllerFrame.Parent          = ControllerGui
    ControllerFrame.BackgroundColor3= Color3.fromRGB(60, 60, 60)
    ControllerFrame.Position        = UDim2.new(0.78, -75, 0.5, -75)
    ControllerFrame.Size            = UDim2.new(0, 150, 0, 150)
    ControllerFrame.Active          = false

    local ccorner = Instance.new("UICorner")
    ccorner.CornerRadius = UDim.new(0.5, 0)
    ccorner.Parent = ControllerFrame

    local function ctrlBtn(parent, text, pos, size)
        local b = Instance.new("TextButton")
        b.Parent           = parent
        b.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        b.Size             = size or UDim2.new(0, 50, 0, 50)
        b.Position         = pos
        b.Font             = Enum.Font.GothamBold
        b.Text             = text
        b.TextColor3       = Color3.fromRGB(255, 255, 255)
        b.TextScaled       = true
        originalButtonPositions[b] = pos
        return b
    end

    ForwardButton  = ctrlBtn(ControllerFrame, "▲", UDim2.new(0.5,-25,0,10))
    BackwardButton = ctrlBtn(ControllerFrame, "▼", UDim2.new(0.5,-25,0,85))
    LeftButton     = ctrlBtn(ControllerFrame, "<",  UDim2.new(0,0,0.5,-25))
    RightButton    = ctrlBtn(ControllerFrame, ">",  UDim2.new(1,-50,0.5,-25))
    AntiLockButton = ctrlBtn(ControllerFrame, "A-L",UDim2.new(0.5,-25,0,60), UDim2.new(0,50,0,30))
    PitchButton    = ctrlBtn(ControllerFrame, "Pitch: Off", UDim2.new(0.16,-25,0,20), UDim2.new(0,50,0,30))

    -- ========================
    -- Left Side GUI (up/down/rotate)
    -- ========================
    LeftSideGui.Parent       = player.PlayerGui
    LeftSideGui.ResetOnSpawn = false
    LeftSideGui.Enabled      = false
    LeftSideGui.Name         = "VehicleFlyLeftSideGui"

    LeftSideFrame.Parent          = LeftSideGui
    LeftSideFrame.BackgroundColor3= Color3.fromRGB(60, 60, 60)
    LeftSideFrame.Position        = UDim2.new(0.1, 20, 0.5, -75)
    LeftSideFrame.Size            = UDim2.new(0, 150, 0, 150)
    LeftSideFrame.Active          = false

    local lsCorner = Instance.new("UICorner")
    lsCorner.CornerRadius = UDim.new(0.5, 0)
    lsCorner.Parent = LeftSideFrame

    UpButton          = ctrlBtn(LeftSideFrame, "↑",   UDim2.new(0.5,-25,0,10))
    DownButton        = ctrlBtn(LeftSideFrame, "↓",   UDim2.new(0.5,-25,0,90))
    RotateLeftButton  = ctrlBtn(LeftSideFrame, "⟩>",  UDim2.new(0.86,-25,0,50))
    RotateRightButton = ctrlBtn(LeftSideFrame, "<⟨",  UDim2.new(0.14,-25,0,50))

    originalMainFrameSize = MainFrame.Size
end

-- ============================================================
-- TAB SWITCHING
-- ============================================================
local function showTab(tabName)
    if tabName == "fly" then
        FlyFrame.Visible        = true
        TPFrame.Visible         = false
        FlyTabButton.BackgroundColor3 = Color3.fromRGB(0, 130, 200)
        FlyTabButton.TextColor3       = Color3.fromRGB(255, 255, 255)
        TPTabButton.BackgroundColor3  = Color3.fromRGB(60, 60, 60)
        TPTabButton.TextColor3        = Color3.fromRGB(180, 180, 180)
    else
        FlyFrame.Visible        = false
        TPFrame.Visible         = true
        TPTabButton.BackgroundColor3  = Color3.fromRGB(0, 130, 200)
        TPTabButton.TextColor3        = Color3.fromRGB(255, 255, 255)
        FlyTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        FlyTabButton.TextColor3       = Color3.fromRGB(180, 180, 180)
    end
end

-- ============================================================
-- FLIGHT CORE
-- ============================================================
local function cleanupConnections()
    for _, connection in pairs(activeConnections) do
        if connection and connection.Disconnect then
            connection:Disconnect()
        end
    end
    activeConnections = {}
end

local function setupFlyInstances(character)
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local rootPart = character.HumanoidRootPart

    local existingVelocity = rootPart:FindFirstChild(velocityHandlerName)
    local existingGyro     = rootPart:FindFirstChild(gyroHandlerName)
    if existingVelocity then existingVelocity:Destroy() end
    if existingGyro     then existingGyro:Destroy()     end

    VelocityHandler = Instance.new("BodyVelocity")
    VelocityHandler.Name     = velocityHandlerName
    VelocityHandler.Parent   = rootPart
    VelocityHandler.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    VelocityHandler.Velocity = Vector3.new()

    GyroHandler = Instance.new("BodyGyro")
    GyroHandler.Name      = gyroHandlerName
    GyroHandler.Parent    = rootPart
    GyroHandler.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    GyroHandler.P         = 1000
    GyroHandler.D         = 50
    GyroHandler.CFrame    = rootPart.CFrame
end

local function EnableFlight()
    local character = player.Character
    if character then setupFlyInstances(character) end
end

local function DisableFlight()
    if VelocityHandler then VelocityHandler:Destroy(); VelocityHandler = nil end
    if GyroHandler     then GyroHandler:Destroy();     GyroHandler = nil     end
end

player.CharacterAdded:Connect(function()
    ControllerGui.Enabled = false
    LeftSideGui.Enabled   = false
end)
player.CharacterRemoving:Connect(function()
    ControllerGui.Enabled = false
    LeftSideGui.Enabled   = false
end)

-- ============================================================
-- INPUT HANDLER
-- ============================================================
local function handleInput()
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end

    if FlyEnabled and (humanoid.SeatPart or flightWithoutFlyEnabled) then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart or not VelocityHandler then return end

        local gyro  = rootPart:FindFirstChild(gyroHandlerName)
        local speed = tonumber(SpeedTextBox.Text) or 1
        local velocity = Vector3.new()

        local function getMovementCFrame()
            if isPitchOn and gyro then
                return gyro.CFrame
            elseif gyro then
                local lv = gyro.CFrame.LookVector
                return CFrame.new(gyro.Parent.Position, gyro.Parent.Position + Vector3.new(lv.X, 0, lv.Z))
            end
            return rootPart.CFrame
        end

        local movementCFrame = getMovementCFrame()

        for _, direction in ipairs(movementDirection) do
            if direction == "forward" then
                velocity += movementCFrame.LookVector * forwardVelocity
            elseif direction == "backward" then
                velocity += -movementCFrame.LookVector * forwardVelocity
            elseif direction == "left" then
                velocity += movementCFrame.RightVector * -leftVelocity
            elseif direction == "right" then
                velocity += movementCFrame.RightVector * rightVelocity
            elseif direction == "up" then
                velocity += Vector3.new(0, upVelocity, 0)
            elseif direction == "down" then
                velocity += Vector3.new(0, -downVelocity, 0)
            elseif direction == "rotateLeft" and gyro then
                gyro.CFrame = gyro.CFrame * CFrame.Angles(0, math.rad(-rotationSpeed), 0)
            elseif direction == "rotateRight" and gyro then
                gyro.CFrame = gyro.CFrame * CFrame.Angles(0, math.rad(rotationSpeed), 0)
            end
        end

        if keyUpHeld   then velocity += Vector3.new(0,  upVelocity,   0) end
        if keyDownHeld then velocity += Vector3.new(0, -downVelocity, 0) end

        local thumbstickDirection = Vector2.new(0, 0)
        pcall(function()
            local controlModule = require(player.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
            thumbstickDirection = controlModule:GetMoveVector()
        end)

        local hasInput = #movementDirection > 0 or keyUpHeld or keyDownHeld or thumbstickDirection.Magnitude > 0

        if hasInput then
            local combinedVelocity = velocity + (
                movementCFrame.RightVector * thumbstickDirection.X * forwardVelocity * 2 +
                movementCFrame.LookVector  * -thumbstickDirection.Z * forwardVelocity * 2
            )

            if isAntiLockOn and humanoid.SeatPart then
                local sf = humanoid.SeatPart.CFrame.LookVector
                local sr = humanoid.SeatPart.CFrame.RightVector
                local su = humanoid.SeatPart.CFrame.UpVector
                local sv = Vector3.new()

                for _, direction in ipairs(movementDirection) do
                    if direction == "forward"  then sv += sf * forwardVelocity
                    elseif direction == "backward" then sv += -sf * forwardVelocity
                    elseif direction == "left"     then sv += -sr * leftVelocity
                    elseif direction == "right"    then sv += sr * rightVelocity
                    elseif direction == "up"       then sv += su * upVelocity
                    elseif direction == "down"     then sv += -su * downVelocity
                    end
                end
                if keyUpHeld   then sv += su *  upVelocity   end
                if keyDownHeld then sv += su * -downVelocity  end
                VelocityHandler.Velocity = sv * speed
            else
                VelocityHandler.Velocity = combinedVelocity * speed
            end
        else
            VelocityHandler.Velocity = Vector3.new()
        end

        if not isAntiLockOn then
            local camera = workspace.CurrentCamera
            if isPitchOn and gyro then
                gyro.CFrame = camera.CFrame
            elseif gyro then
                local flatLook = camera.CFrame.LookVector * Vector3.new(1, 0, 1)
                gyro.CFrame = CFrame.new(gyro.Parent.Position, gyro.Parent.Position + flatLook)
            end
        end
    else
        if VelocityHandler then VelocityHandler.Velocity = Vector3.new() end
    end
end

-- ============================================================
-- KEYBOARD BINDINGS
-- ============================================================
local function setupKeyboardBindings()
    table.insert(activeConnections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.E then keyUpHeld   = true  end
        if input.KeyCode == Enum.KeyCode.Q then keyDownHeld = true  end
    end))
    table.insert(activeConnections, UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.E then keyUpHeld   = false end
        if input.KeyCode == Enum.KeyCode.Q then keyDownHeld = false end
    end))
end

-- ============================================================
-- TELEPORT FUNCTIONS
-- ============================================================
local function teleportVehicle()
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local seat = humanoid.SeatPart
    if not seat then
        warn("You must be sitting in a vehicle!")
        return
    end

    local vehicle = seat.Parent
    while vehicle and not vehicle:IsA("Model") and vehicle ~= workspace do
        vehicle = vehicle.Parent
    end
    if not vehicle then return end

    local x = tonumber(XTextBox.Text) or 0
    local y = tonumber(YTextBox.Text) or 0
    local z = tonumber(ZTextBox.Text) or 0

    vehicle:PivotTo(CFrame.new(x, y, z))
end

local function getCurrentPosition()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local pos = character.HumanoidRootPart.Position
        XTextBox.Text = tostring(math.floor(pos.X))
        YTextBox.Text = tostring(math.floor(pos.Y))
        ZTextBox.Text = tostring(math.floor(pos.Z))
    end
end

-- ============================================================
-- BUTTON POSITION BACKUP (prevents Roblox reset bug)
-- ============================================================
local function backupButtonPositions()
    for button, originalPosition in pairs(originalButtonPositions) do
        if button and button.Parent and button.Position == UDim2.new(0,0,0,0) then
            button.Position = originalPosition
        end
    end
end

-- ============================================================
-- BUTTON CONNECTIONS
-- ============================================================
local function setupButtonConnections()
    -- Speed +/-
    table.insert(activeConnections, IncreaseButton.MouseButton1Click:Connect(function()
        SpeedTextBox.Text = tostring((tonumber(SpeedTextBox.Text) or 1) + 1)
    end))
    table.insert(activeConnections, DecreaseButton.MouseButton1Click:Connect(function()
        SpeedTextBox.Text = tostring(math.max(1, (tonumber(SpeedTextBox.Text) or 1) - 1))
    end))

    -- Direction buttons
    local function addDirectionButton(button, dirName)
        table.insert(activeConnections, button.MouseButton1Down:Connect(function()
            table.insert(movementDirection, dirName)
        end))
        table.insert(activeConnections, button.MouseButton1Up:Connect(function()
            for i = #movementDirection, 1, -1 do
                if movementDirection[i] == dirName then table.remove(movementDirection, i) end
            end
        end))
    end

    addDirectionButton(ForwardButton,     "forward")
    addDirectionButton(BackwardButton,    "backward")
    addDirectionButton(LeftButton,        "left")
    addDirectionButton(RightButton,       "right")
    addDirectionButton(UpButton,          "up")
    addDirectionButton(DownButton,        "down")
    addDirectionButton(RotateLeftButton,  "rotateLeft")
    addDirectionButton(RotateRightButton, "rotateRight")

    -- Anti-lock
    table.insert(activeConnections, AntiLockButton.MouseButton1Click:Connect(function()
        isAntiLockOn = not isAntiLockOn
        AntiLockButton.Text = isAntiLockOn and "A-L On" or "A-L"
        if isAntiLockOn and isPitchOn then
            isPitchOn = false
            PitchButton.Text = "Pitch: Off"
        end
    end))

    -- Pitch
    table.insert(activeConnections, PitchButton.MouseButton1Click:Connect(function()
        if not isAntiLockOn then
            isPitchOn = not isPitchOn
            PitchButton.Text = isPitchOn and "Pitch: On" or "Pitch: Off"
        else
            PitchButton.Text = "Pitch: Off"
            isPitchOn = false
        end
    end))
end

-- ============================================================
-- CLEANUP
-- ============================================================
local function cleanup()
    DisableFlight()
    cleanupConnections()
    movementDirection       = {}
    keyUpHeld               = false
    keyDownHeld             = false
    controllerEnabled       = false
    if seatConnection   then seatConnection:Disconnect()   end
    if unseatConnection then unseatConnection:Disconnect() end
    seatConnection          = nil
    unseatConnection        = nil
    FlyEnabled              = false
    flightWithoutFlyEnabled = false
    originalButtonPositions = {}

    if ScreenGui      then ScreenGui:Destroy()      end
    if ControllerGui  then ControllerGui:Destroy()  end
    if LeftSideGui    then LeftSideGui:Destroy()    end
end

-- ============================================================
-- INITIALIZE
-- ============================================================
local function initialize()
    initializeGUI()
    setupButtonConnections()
    setupKeyboardBindings()

    table.insert(activeConnections, RunService.RenderStepped:Connect(handleInput))
    table.insert(activeConnections, RunService.Heartbeat:Connect(backupButtonPositions))

    -- Tab switching
    FlyTabButton.MouseButton1Click:Connect(function() showTab("fly") end)
    TPTabButton.MouseButton1Click:Connect(function()  showTab("tp")  end)

    -- Close / Minimize
    CloseButton.MouseButton1Click:Connect(cleanup)

    MinimizeButton.MouseButton1Click:Connect(function()
        isGuiMinimized = not isGuiMinimized
        if isGuiMinimized then
            MinimizeButton.Text = "⇩"
            MainFrame:TweenSizeAndPosition(
                UDim2.new(0, 230, 0, 36),
                UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset,
                           MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset),
                Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.25, true
            )
            TabBar.Visible   = false
            FlyFrame.Visible = false
            TPFrame.Visible  = false
        else
            MinimizeButton.Text = "⇧"
            MainFrame:TweenSizeAndPosition(
                originalMainFrameSize,
                UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset,
                           MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset),
                Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.25, true
            )
            TabBar.Visible   = true
            showTab("fly")
        end
    end)

    -- Fly button
    FlyButton.MouseButton1Click:Connect(function()
        FlyEnabled = not FlyEnabled
        local character = player.Character
        local humanoid  = character and character:FindFirstChild("Humanoid")

        if FlyEnabled then
            FlyButton.Text = "UnFly"
            FlyButton.BackgroundColor3 = Color3.fromRGB(200, 50, 0)
            if flightWithoutFlyEnabled then
                EnableFlight()
            elseif humanoid then
                if seatConnection   then seatConnection:Disconnect()   end
                if unseatConnection then unseatConnection:Disconnect() end
                if humanoid.SeatPart then
                    EnableFlight()
                else
                    seatConnection = humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
                        if humanoid.SeatPart then EnableFlight() end
                    end)
                end
                unseatConnection = humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
                    if not humanoid.SeatPart then DisableFlight() end
                end)
            end
        else
            FlyButton.Text = "Fly"
            FlyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            DisableFlight()
            if seatConnection   then seatConnection:Disconnect()   end
            if unseatConnection then unseatConnection:Disconnect() end
            seatConnection   = nil
            unseatConnection = nil
        end
    end)

    -- FwF button
    FwFButton.MouseButton1Click:Connect(function()
        flightWithoutFlyEnabled = not flightWithoutFlyEnabled
        FwFButton.Text = flightWithoutFlyEnabled and "FwF On" or "FwF"
        FwFButton.BackgroundColor3 = flightWithoutFlyEnabled and Color3.fromRGB(0, 130, 200) or Color3.fromRGB(80, 80, 80)
        if FlyEnabled and not flightWithoutFlyEnabled then
            local character = player.Character
            local humanoid  = character and character:FindFirstChild("Humanoid")
            if humanoid and not humanoid.SeatPart then DisableFlight() end
        end
    end)

    -- Controller button
    ControllerButton.MouseButton1Click:Connect(function()
        controllerEnabled = not controllerEnabled
        ControllerGui.Enabled = controllerEnabled
        LeftSideGui.Enabled   = controllerEnabled
        ControllerButton.BackgroundColor3 = controllerEnabled and Color3.fromRGB(0, 130, 200) or Color3.fromRGB(70, 70, 70)
    end)

    -- Teleport buttons
    TeleportButton.MouseButton1Click:Connect(teleportVehicle)
    GetPosButton.MouseButton1Click:Connect(getCurrentPosition)

    -- Start on Fly tab
    showTab("fly")
end

initialize()
