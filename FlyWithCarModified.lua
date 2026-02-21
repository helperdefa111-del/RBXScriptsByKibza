-- Instances (GUI elements)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local InnerFrame = Instance.new("Frame")
local SpeedTextBox = Instance.new("TextBox")
local DecreaseButton = Instance.new("TextButton")
local IncreaseButton = Instance.new("TextButton")
local FlyButton = Instance.new("TextButton")
local FwFButton = Instance.new("TextButton")
local DestroyButton = Instance.new("TextButton")
local ControllerButton = Instance.new("TextButton")
local UIGradient = Instance.new("UIGradient")
local UICorner = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")

-- Controller GUI Instances
local ControllerGui = Instance.new("ScreenGui")
local ControllerFrame = Instance.new("Frame")
local ForwardButton = Instance.new("TextButton")
local BackwardButton = Instance.new("TextButton")
local LeftButton = Instance.new("TextButton")
local RightButton = Instance.new("TextButton")
local AntiLockButton = Instance.new("TextButton")
local PitchButton = Instance.new("TextButton")

-- Left Side Movement GUI
local LeftSideGui = Instance.new("ScreenGui")
local LeftSideFrame = Instance.new("Frame")
local UpButton = Instance.new("TextButton")
local DownButton = Instance.new("TextButton")
local RotateLeftButton = Instance.new("TextButton")
local RotateRightButton = Instance.new("TextButton")

-- Minimize Button
local MinimizeButton = Instance.new("TextButton")

-- Services
local PlayerService = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Global Variables
local velocityHandlerName = "VehicleFlyVelocity32"
local gyroHandlerName = "VehicleFlyGyro64"
local VelocityHandler = nil
local GyroHandler = nil
local isAntiLockOn = false
local FlyEnabled = false
local seatConnection = nil
local unseatConnection = nil
local flightWithoutFlyEnabled = false
local isPitchOn = false

-- Track Active Connections
local activeConnections = {}
local controllerEnabled = false
local movementDirection = {}

-- Keyboard state for E/Q
local keyUpHeld = false
local keyDownHeld = false

-- Movement Speeds
local forwardVelocity = 100
local leftVelocity = 100
local rightVelocity = 100
local upVelocity = 50
local downVelocity = 50
local rotationSpeed = 5

-- GUI Minimized State
local isGuiMinimized = false
local originalMainFramePosition = nil

-- Store original positions for buttons to monitor
local originalButtonPositions = {}

-- Wait for player to load
local player = PlayerService.LocalPlayer
if not player then
    player = PlayerService.PlayerAdded:Wait()
end

player:WaitForChild("PlayerGui")

-- ============================================================
-- GUI INITIALIZATION
-- ============================================================
local function initializeGUI()
    ScreenGui.Parent = player.PlayerGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Name = "VehicleFlyGui"

    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    MainFrame.Position = UDim2.new(0.3, 0, 0.5, -100)
    MainFrame.Size = UDim2.new(0, 200, 0, 230)
    MainFrame.Active = true
    MainFrame.Draggable = true

    UIStroke.Parent = MainFrame
    UIStroke.Color = Color3.fromRGB(0, 0, 0)
    UIStroke.Thickness = 2

    Title.Parent = MainFrame
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, 0, 0.2, 0)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "Vehicle Fly GUI"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextScaled = true

    InnerFrame.Parent = MainFrame
    InnerFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    InnerFrame.Size = UDim2.new(1, 0, 0.75, 0)
    InnerFrame.Position = UDim2.new(0, 0, 0.2, 0)

    SpeedTextBox.Parent = InnerFrame
    SpeedTextBox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    SpeedTextBox.Position = UDim2.new(0.5, -25, 0.1, 0)
    SpeedTextBox.Size = UDim2.new(0, 50, 0, 30)
    SpeedTextBox.Font = Enum.Font.Gotham
    SpeedTextBox.Text = "1"
    SpeedTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedTextBox.TextScaled = true
    SpeedTextBox.PlaceholderText = "Speed"
    originalButtonPositions[SpeedTextBox] = SpeedTextBox.Position

    DecreaseButton.Parent = InnerFrame
    DecreaseButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    DecreaseButton.Size = UDim2.new(0.2, 0, 0, 25)
    DecreaseButton.Position = UDim2.new(0.1, 0, 0.1, 0)
    DecreaseButton.Font = Enum.Font.Gotham
    DecreaseButton.Text = "-"
    DecreaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DecreaseButton.TextScaled = true
    originalButtonPositions[DecreaseButton] = DecreaseButton.Position

    IncreaseButton.Parent = InnerFrame
    IncreaseButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    IncreaseButton.Size = UDim2.new(0.2, 0, 0, 25)
    IncreaseButton.Position = UDim2.new(0.7, 0, 0.1, 0)
    IncreaseButton.Font = Enum.Font.Gotham
    IncreaseButton.Text = "+"
    IncreaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    IncreaseButton.TextScaled = true
    originalButtonPositions[IncreaseButton] = IncreaseButton.Position

    FlyButton.Parent = InnerFrame
    FlyButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    FlyButton.Size = UDim2.new(0.4, 0, 0, 25)
    FlyButton.Position = UDim2.new(0.1, 0, 0.33, 0)
    FlyButton.Font = Enum.Font.GothamBold
    FlyButton.Text = "Fly"
    FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    FlyButton.TextScaled = true
    originalButtonPositions[FlyButton] = FlyButton.Position

    FwFButton.Parent = InnerFrame
    FwFButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    FwFButton.Size = UDim2.new(0.4, 0, 0, 25)
    FwFButton.Position = UDim2.new(0.5, 0, 0.33, 0)
    FwFButton.Font = Enum.Font.GothamBold
    FwFButton.Text = "FwF"
    FwFButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    FwFButton.TextScaled = true
    originalButtonPositions[FwFButton] = FwFButton.Position

    DestroyButton.Parent = InnerFrame
    DestroyButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    DestroyButton.Size = UDim2.new(0.8, 0, 0, 25)
    DestroyButton.Position = UDim2.new(0.1, 0, 0.53, 0)
    DestroyButton.Font = Enum.Font.GothamBold
    DestroyButton.Text = "Destroy"
    DestroyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DestroyButton.TextScaled = true
    originalButtonPositions[DestroyButton] = DestroyButton.Position

    ControllerButton.Parent = InnerFrame
    ControllerButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    ControllerButton.Size = UDim2.new(0.8, 0, 0, 25)
    ControllerButton.Position = UDim2.new(0.1, 0, 0.73, 0)
    ControllerButton.Font = Enum.Font.GothamBold
    ControllerButton.Text = "Controller"
    ControllerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ControllerButton.TextScaled = true
    originalButtonPositions[ControllerButton] = ControllerButton.Position

    UICorner.CornerRadius = UDim.new(0.1, 0)
    UICorner.Parent = MainFrame

    UIGradient.Parent = MainFrame
    UIGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(75, 75, 75))
    }

    -- Controller GUI
    ControllerGui.Parent = player.PlayerGui
    ControllerGui.ResetOnSpawn = false
    ControllerGui.Enabled = false
    ControllerGui.Name = "VehicleFlyControllerGui"

    ControllerFrame.Parent = ControllerGui
    ControllerFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    ControllerFrame.Position = UDim2.new(0.78, -75, 0.5, -75)
    ControllerFrame.Size = UDim2.new(0, 150, 0, 150)
    ControllerFrame.Active = false
    ControllerFrame.Draggable = false

    local ControllerCorner = Instance.new("UICorner")
    ControllerCorner.CornerRadius = UDim.new(0.5, 0)
    ControllerCorner.Parent = ControllerFrame

    ForwardButton.Parent = ControllerFrame
    ForwardButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    ForwardButton.Size = UDim2.new(0, 50, 0, 50)
    ForwardButton.Position = UDim2.new(0.5, -25, 0, 10)
    ForwardButton.Font = Enum.Font.GothamBold
    ForwardButton.Text = "▲"
    ForwardButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ForwardButton.TextScaled = true
    originalButtonPositions[ForwardButton] = ForwardButton.Position

    BackwardButton.Parent = ControllerFrame
    BackwardButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    BackwardButton.Size = UDim2.new(0, 50, 0, 50)
    BackwardButton.Position = UDim2.new(0.5, -25, 0, 85)
    BackwardButton.Font = Enum.Font.GothamBold
    BackwardButton.Text = "▼"
    BackwardButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    BackwardButton.TextScaled = true
    originalButtonPositions[BackwardButton] = BackwardButton.Position

    LeftButton.Parent = ControllerFrame
    LeftButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    LeftButton.Size = UDim2.new(0, 50, 0, 50)
    LeftButton.Position = UDim2.new(0, 0, 0.5, -25)
    LeftButton.Font = Enum.Font.GothamBold
    LeftButton.Text = "<"
    LeftButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    LeftButton.TextScaled = true
    originalButtonPositions[LeftButton] = LeftButton.Position

    RightButton.Parent = ControllerFrame
    RightButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    RightButton.Size = UDim2.new(0, 50, 0, 50)
    RightButton.Position = UDim2.new(1, -50, 0.5, -25)
    RightButton.Font = Enum.Font.GothamBold
    RightButton.Text = ">"
    RightButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    RightButton.TextScaled = true
    originalButtonPositions[RightButton] = RightButton.Position

    AntiLockButton.Parent = ControllerFrame
    AntiLockButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    AntiLockButton.Size = UDim2.new(0, 50, 0, 30)
    AntiLockButton.Position = UDim2.new(0.5, -25, 0, 60)
    AntiLockButton.Font = Enum.Font.GothamBold
    AntiLockButton.Text = "A-L"
    AntiLockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    AntiLockButton.TextScaled = true
    originalButtonPositions[AntiLockButton] = AntiLockButton.Position

    PitchButton.Parent = ControllerFrame
    PitchButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    PitchButton.Size = UDim2.new(0, 50, 0, 30)
    PitchButton.Position = UDim2.new(0.16, -25, 0, 20)
    PitchButton.Font = Enum.Font.GothamBold
    PitchButton.Text = "Pitch: Off"
    PitchButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    PitchButton.TextScaled = true
    originalButtonPositions[PitchButton] = PitchButton.Position

    -- Left Side GUI
    LeftSideGui.Parent = player.PlayerGui
    LeftSideGui.ResetOnSpawn = false
    LeftSideGui.Enabled = false
    LeftSideGui.Name = "VehicleFlyLeftSideGui"

    LeftSideFrame.Parent = LeftSideGui
    LeftSideFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    LeftSideFrame.Position = UDim2.new(0.1, 20, 0.5, -75)
    LeftSideFrame.Size = UDim2.new(0, 150, 0, 150)
    LeftSideFrame.Active = false
    LeftSideFrame.Draggable = false

    local LeftSideCorner = Instance.new("UICorner")
    LeftSideCorner.CornerRadius = UDim.new(0.5, 0)
    LeftSideCorner.Parent = LeftSideFrame

    UpButton.Parent = LeftSideFrame
    UpButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    UpButton.Size = UDim2.new(0, 50, 0, 50)
    UpButton.Position = UDim2.new(0.5, -25, 0, 10)
    UpButton.Font = Enum.Font.GothamBold
    UpButton.Text = "↑"
    UpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    UpButton.TextScaled = true
    originalButtonPositions[UpButton] = UpButton.Position

    DownButton.Parent = LeftSideFrame
    DownButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    DownButton.Size = UDim2.new(0, 50, 0, 50)
    DownButton.Position = UDim2.new(0.5, -25, 0, 90)
    DownButton.Font = Enum.Font.GothamBold
    DownButton.Text = "↓"
    DownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DownButton.TextScaled = true
    originalButtonPositions[DownButton] = DownButton.Position

    RotateLeftButton.Parent = LeftSideFrame
    RotateLeftButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    RotateLeftButton.Size = UDim2.new(0, 50, 0, 50)
    RotateLeftButton.Position = UDim2.new(0.86, -25, 0, 50)
    RotateLeftButton.Font = Enum.Font.GothamBold
    RotateLeftButton.Text = "⟩>"
    RotateLeftButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    RotateLeftButton.TextScaled = true
    originalButtonPositions[RotateLeftButton] = RotateLeftButton.Position

    RotateRightButton.Parent = LeftSideFrame
    RotateRightButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    RotateRightButton.Size = UDim2.new(0, 50, 0, 50)
    RotateRightButton.Position = UDim2.new(0.14, -25, 0, 50)
    RotateRightButton.Font = Enum.Font.GothamBold
    RotateRightButton.Text = "<⟨"
    RotateRightButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    RotateRightButton.TextScaled = true
    originalButtonPositions[RotateRightButton] = RotateRightButton.Position

    -- Minimize Button
    MinimizeButton.Parent = MainFrame
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
    MinimizeButton.Position = UDim2.new(-0.15, 0, 0, 0)
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.Text = "⇧"
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.TextScaled = true
    MinimizeButton.ZIndex = 2
    originalButtonPositions[MinimizeButton] = MinimizeButton.Position

    originalMainFramePosition = MainFrame.Position
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
    local existingGyro = rootPart:FindFirstChild(gyroHandlerName)
    if existingVelocity then existingVelocity:Destroy() end
    if existingGyro then existingGyro:Destroy() end

    VelocityHandler = Instance.new("BodyVelocity")
    VelocityHandler.Name = velocityHandlerName
    VelocityHandler.Parent = rootPart
    VelocityHandler.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    VelocityHandler.Velocity = Vector3.new()

    GyroHandler = Instance.new("BodyGyro")
    GyroHandler.Name = gyroHandlerName
    GyroHandler.Parent = rootPart
    GyroHandler.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    GyroHandler.P = 1000
    GyroHandler.D = 50
    GyroHandler.CFrame = rootPart.CFrame
end

local function EnableFlight()
    local character = player.Character
    if character then
        setupFlyInstances(character)
    end
end

local function DisableFlight()
    if VelocityHandler then
        VelocityHandler:Destroy()
        VelocityHandler = nil
    end
    if GyroHandler then
        GyroHandler:Destroy()
        GyroHandler = nil
    end
end

local function resetControllerOnSpawn()
    ControllerGui.Enabled = false
    LeftSideGui.Enabled = false
end

player.CharacterAdded:Connect(resetControllerOnSpawn)
player.CharacterRemoving:Connect(resetControllerOnSpawn)

-- ============================================================
-- INPUT HANDLER (RenderStepped)
-- ============================================================
local function handleInput()
    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end

    if FlyEnabled and (humanoid.SeatPart or flightWithoutFlyEnabled) then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart or not VelocityHandler then return end

        local gyro = rootPart:FindFirstChild(gyroHandlerName)
        local speed = tonumber(SpeedTextBox.Text) or 1
        local velocity = Vector3.new()

        local function getMovementCFrame()
            if isPitchOn and gyro then
                return gyro.CFrame
            elseif gyro then
                local lookVector = gyro.CFrame.LookVector
                return CFrame.new(gyro.Parent.Position, gyro.Parent.Position + Vector3.new(lookVector.X, 0, lookVector.Z))
            end
            return rootPart.CFrame
        end

        local movementCFrame = getMovementCFrame()

        -- Button-based movement
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

        -- E / Q keyboard up/down
        if keyUpHeld then
            velocity += Vector3.new(0, upVelocity, 0)
        end
        if keyDownHeld then
            velocity += Vector3.new(0, -downVelocity, 0)
        end

        -- Thumbstick input
        local thumbstickDirection = Vector2.new(0, 0)
        pcall(function()
            local controlModule = require(player.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
            thumbstickDirection = controlModule:GetMoveVector()
        end)

        local hasInput = #movementDirection > 0 or keyUpHeld or keyDownHeld or thumbstickDirection.Magnitude > 0

        if hasInput then
            local combinedVelocity = velocity + (
                movementCFrame.RightVector * thumbstickDirection.X * forwardVelocity * 2 +
                movementCFrame.LookVector * -thumbstickDirection.Z * forwardVelocity * 2
            )

            if isAntiLockOn and humanoid.SeatPart then
                local seatForward = humanoid.SeatPart.CFrame.LookVector
                local seatRight = humanoid.SeatPart.CFrame.RightVector
                local seatUp = humanoid.SeatPart.CFrame.UpVector
                local seatVelocity = Vector3.new()

                for _, direction in ipairs(movementDirection) do
                    if direction == "forward" then
                        seatVelocity += seatForward * forwardVelocity
                    elseif direction == "backward" then
                        seatVelocity += -seatForward * forwardVelocity
                    elseif direction == "left" then
                        seatVelocity += -seatRight * leftVelocity
                    elseif direction == "right" then
                        seatVelocity += seatRight * rightVelocity
                    elseif direction == "up" then
                        seatVelocity += seatUp * upVelocity
                    elseif direction == "down" then
                        seatVelocity += -seatUp * downVelocity
                    end
                end

                -- E/Q also respect anti-lock mode
                if keyUpHeld then
                    seatVelocity += seatUp * upVelocity
                end
                if keyDownHeld then
                    seatVelocity += -seatUp * downVelocity
                end

                VelocityHandler.Velocity = seatVelocity * speed
            else
                VelocityHandler.Velocity = combinedVelocity * speed
            end
        else
            VelocityHandler.Velocity = Vector3.new()
        end

        -- Update gyro to match camera
        if not isAntiLockOn then
            local camera = workspace.CurrentCamera
            if isPitchOn and gyro then
                gyro.CFrame = camera.CFrame
            elseif gyro then
                local flatLookVector = camera.CFrame.LookVector * Vector3.new(1, 0, 1)
                gyro.CFrame = CFrame.new(gyro.Parent.Position, gyro.Parent.Position + flatLookVector)
            end
        end
    else
        if VelocityHandler then
            VelocityHandler.Velocity = Vector3.new()
        end
    end
end

-- ============================================================
-- KEYBOARD BINDINGS (E = Up, Q = Down)
-- ============================================================
local function setupKeyboardBindings()
    table.insert(activeConnections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.E then
            keyUpHeld = true
        elseif input.KeyCode == Enum.KeyCode.Q then
            keyDownHeld = true
        end
    end))

    table.insert(activeConnections, UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.E then
            keyUpHeld = false
        elseif input.KeyCode == Enum.KeyCode.Q then
            keyDownHeld = false
        end
    end))
end

-- ============================================================
-- BUTTON CONNECTIONS
-- ============================================================
local function backupButtonPositions()
    for button, originalPosition in pairs(originalButtonPositions) do
        if button and button.Parent and button.Position == UDim2.new(0, 0, 0, 0) then
            button.Position = originalPosition
        end
    end
end

local function setupButtonConnections()
    table.insert(activeConnections, IncreaseButton.MouseButton1Click:Connect(function()
        local currentSpeed = tonumber(SpeedTextBox.Text) or 1
        SpeedTextBox.Text = tostring(currentSpeed + 1)
    end))

    table.insert(activeConnections, DecreaseButton.MouseButton1Click:Connect(function()
        local currentSpeed = tonumber(SpeedTextBox.Text) or 1
        SpeedTextBox.Text = tostring(math.max(1, currentSpeed - 1))
    end))

    -- Direction buttons helper
    local function addDirectionButton(button, dirName)
        table.insert(activeConnections, button.MouseButton1Down:Connect(function()
            table.insert(movementDirection, dirName)
        end))
        table.insert(activeConnections, button.MouseButton1Up:Connect(function()
            for i = #movementDirection, 1, -1 do
                if movementDirection[i] == dirName then
                    table.remove(movementDirection, i)
                end
            end
        end))
    end

    addDirectionButton(ForwardButton, "forward")
    addDirectionButton(BackwardButton, "backward")
    addDirectionButton(LeftButton, "left")
    addDirectionButton(RightButton, "right")
    addDirectionButton(UpButton, "up")
    addDirectionButton(DownButton, "down")
    addDirectionButton(RotateLeftButton, "rotateLeft")
    addDirectionButton(RotateRightButton, "rotateRight")

    table.insert(activeConnections, AntiLockButton.MouseButton1Click:Connect(function()
        isAntiLockOn = not isAntiLockOn
        if isAntiLockOn then
            AntiLockButton.Text = "A-L On"
            if isPitchOn then
                PitchButton.Text = "Pitch: Off"
                isPitchOn = false
            end
        else
            AntiLockButton.Text = "A-L"
        end
    end))

    table.insert(activeConnections, PitchButton.MouseButton1Click:Connect(function()
        if isAntiLockOn then
            PitchButton.Text = "Pitch: Off"
            isPitchOn = false
        else
            isPitchOn = not isPitchOn
            PitchButton.Text = isPitchOn and "Pitch: On" or "Pitch: Off"
        end
    end))
end

-- ============================================================
-- EVENT LISTENER SETUP
-- ============================================================
local function setupEventListeners()
    setupButtonConnections()
    setupKeyboardBindings()
    table.insert(activeConnections, RunService.RenderStepped:Connect(handleInput))
    table.insert(activeConnections, RunService.Heartbeat:Connect(backupButtonPositions))
end

-- ============================================================
-- CLEANUP
-- ============================================================
local function cleanup()
    DisableFlight()
    cleanupConnections()
    movementDirection = {}
    keyUpHeld = false
    keyDownHeld = false
    controllerEnabled = false

    if seatConnection then seatConnection:Disconnect() end
    if unseatConnection then unseatConnection:Disconnect() end
    seatConnection = nil
    unseatConnection = nil
    FlyEnabled = false
    flightWithoutFlyEnabled = false
    FwFButton.Text = "FwF"

    if ScreenGui then ScreenGui:Destroy() end
    if ControllerGui then ControllerGui:Destroy() end
    if LeftSideGui then LeftSideGui:Destroy() end

    originalButtonPositions = {}
end

-- ============================================================
-- INITIALIZE
-- ============================================================
local function initialize()
    initializeGUI()
    setupEventListeners()

    DestroyButton.MouseButton1Click:Connect(cleanup)

    -- Fly Button
    FlyButton.MouseButton1Click:Connect(function()
        FlyEnabled = not FlyEnabled
        local character = player.Character
        local humanoid = character and character:FindFirstChild("Humanoid")

        if FlyEnabled then
            FlyButton.Text = "UnFly"
            if flightWithoutFlyEnabled then
                EnableFlight()
            elseif humanoid then
                if seatConnection then seatConnection:Disconnect() end
                if unseatConnection then unseatConnection:Disconnect() end

                if humanoid.SeatPart then
                    EnableFlight()
                else
                    seatConnection = humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
                        if humanoid.SeatPart then
                            EnableFlight()
                        end
                    end)
                end

                unseatConnection = humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
                    if not humanoid.SeatPart then
                        DisableFlight()
                    end
                end)
            end
        else
            FlyButton.Text = "Fly"
            DisableFlight()
            if seatConnection then seatConnection:Disconnect() end
            if unseatConnection then unseatConnection:Disconnect() end
            seatConnection = nil
            unseatConnection = nil
        end
    end)

    -- FwF Button
    FwFButton.MouseButton1Click:Connect(function()
        flightWithoutFlyEnabled = not flightWithoutFlyEnabled
        FwFButton.Text = flightWithoutFlyEnabled and "FwF On" or "FwF"

        if FlyEnabled and not flightWithoutFlyEnabled then
            local character = player.Character
            local humanoid = character and character:FindFirstChild("Humanoid")
            if humanoid and not humanoid.SeatPart then
                DisableFlight()
            end
        end
    end)

    -- Controller Button
    ControllerButton.MouseButton1Click:Connect(function()
        controllerEnabled = not controllerEnabled
        ControllerGui.Enabled = controllerEnabled
        LeftSideGui.Enabled = controllerEnabled
    end)

    -- Minimize Button
    MinimizeButton.MouseButton1Click:Connect(function()
        isGuiMinimized = not isGuiMinimized

        if isGuiMinimized then
            MinimizeButton.Text = "⇩"
            originalMainFramePosition = MainFrame.Position

            MainFrame:TweenSizeAndPosition(
                UDim2.new(0, 200, 0, 50),
                UDim2.new(
                    MainFrame.Position.X.Scale, MainFrame.Position.X.Offset,
                    MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset + (MainFrame.Size.Y.Offset - 50) / 2
                ),
                Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true
            )

            Title.Visible = true
            Title.Size = UDim2.new(1, 0, 1, 0)
            Title.Position = UDim2.new(0, 0, 0, 0)
            InnerFrame.Visible = false
        else
            MinimizeButton.Text = "⇧"

            MainFrame:TweenSizeAndPosition(
                UDim2.new(0, 200, 0, 230),
                originalMainFramePosition,
                Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true
            )

            Title.Visible = true
            Title.Size = UDim2.new(1, 0, 0.2, 0)
            Title.Position = UDim2.new(0, 0, 0, 0)
            InnerFrame.Visible = true
        end
    end)
end

-- Start
initialize()
