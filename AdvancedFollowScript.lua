--[[
    Advanced Player Follower GUI
    Features: Player selection, CFrame offsets, rotation, noclip, smooth following
    Author: Expert Roblox Luau Developer
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- State variables
local isFollowing = false
local targetPlayer = nil
local followConnection = nil
local noclipConnection = nil

-- Offset values
local offsetX = 0
local offsetY = 0
local offsetZ = 0
local rotX = 0
local rotY = 0
local rotZ = 0

-- GUI Creation
local function createGUI()
    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdvancedFollowerGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 480)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -240)
    mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    -- Add corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -20, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Advanced Player Follower"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Player Selection Label
    local playerLabel = Instance.new("TextLabel")
    playerLabel.Name = "PlayerLabel"
    playerLabel.Size = UDim2.new(1, -20, 0, 25)
    playerLabel.Position = UDim2.new(0, 10, 0, 50)
    playerLabel.BackgroundTransparency = 1
    playerLabel.Text = "Select Target Player:"
    playerLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    playerLabel.TextSize = 14
    playerLabel.Font = Enum.Font.Gotham
    playerLabel.TextXAlignment = Enum.TextXAlignment.Left
    playerLabel.Parent = mainFrame
    
    -- Player Dropdown
    local playerDropdown = Instance.new("TextButton")
    playerDropdown.Name = "PlayerDropdown"
    playerDropdown.Size = UDim2.new(1, -20, 0, 35)
    playerDropdown.Position = UDim2.new(0, 10, 0, 75)
    playerDropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    playerDropdown.Text = "Select Player..."
    playerDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    playerDropdown.TextSize = 14
    playerDropdown.Font = Enum.Font.Gotham
    playerDropdown.Parent = mainFrame
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 6)
    dropdownCorner.Parent = playerDropdown
    
    -- Dropdown List Container
    local dropdownList = Instance.new("ScrollingFrame")
    dropdownList.Name = "DropdownList"
    dropdownList.Size = UDim2.new(1, -20, 0, 150)
    dropdownList.Position = UDim2.new(0, 10, 0, 112)
    dropdownList.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    dropdownList.BorderSizePixel = 0
    dropdownList.Visible = false
    dropdownList.ScrollBarThickness = 6
    dropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
    dropdownList.ZIndex = 10
    dropdownList.Parent = mainFrame
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 6)
    listCorner.Parent = dropdownList
    
    local listStroke = Instance.new("UIStroke")
    listStroke.Color = Color3.fromRGB(100, 100, 120)
    listStroke.Thickness = 2
    listStroke.Parent = dropdownList
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.Name
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = dropdownList
    
    -- Helper function to create input field
    local function createInputField(name, labelText, yPos)
        local label = Instance.new("TextLabel")
        label.Name = name .. "Label"
        label.Size = UDim2.new(0.3, -5, 0, 30)
        label.Position = UDim2.new(0, 10, 0, yPos)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.TextColor3 = Color3.fromRGB(220, 220, 220)
        label.TextSize = 13
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = mainFrame
        
        local input = Instance.new("TextBox")
        input.Name = name
        input.Size = UDim2.new(0.7, -15, 0, 30)
        input.Position = UDim2.new(0.3, 0, 0, yPos)
        input.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        input.Text = "0"
        input.TextColor3 = Color3.fromRGB(255, 255, 255)
        input.TextSize = 13
        input.Font = Enum.Font.Gotham
        input.PlaceholderText = "0"
        input.ClearTextOnFocus = false
        input.Parent = mainFrame
        
        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 6)
        inputCorner.Parent = input
        
        return input
    end
    
    -- Position Offsets Section
    local positionHeader = Instance.new("TextLabel")
    positionHeader.Name = "PositionHeader"
    positionHeader.Size = UDim2.new(1, -20, 0, 25)
    positionHeader.Position = UDim2.new(0, 10, 0, 120)
    positionHeader.BackgroundTransparency = 1
    positionHeader.Text = "Position Offsets:"
    positionHeader.TextColor3 = Color3.fromRGB(100, 180, 255)
    positionHeader.TextSize = 15
    positionHeader.Font = Enum.Font.GothamBold
    positionHeader.TextXAlignment = Enum.TextXAlignment.Left
    positionHeader.Parent = mainFrame
    
    local offsetXInput = createInputField("OffsetX", "X Offset:", 150)
    local offsetYInput = createInputField("OffsetY", "Y Offset:", 185)
    local offsetZInput = createInputField("OffsetZ", "Z Offset:", 220)
    
    -- Rotation Offsets Section
    local rotationHeader = Instance.new("TextLabel")
    rotationHeader.Name = "RotationHeader"
    rotationHeader.Size = UDim2.new(1, -20, 0, 25)
    rotationHeader.Position = UDim2.new(0, 10, 0, 255)
    rotationHeader.BackgroundTransparency = 1
    rotationHeader.Text = "Rotation Offsets (Degrees):"
    rotationHeader.TextColor3 = Color3.fromRGB(255, 180, 100)
    rotationHeader.TextSize = 15
    rotationHeader.Font = Enum.Font.GothamBold
    rotationHeader.TextXAlignment = Enum.TextXAlignment.Left
    rotationHeader.Parent = mainFrame
    
    local rotXInput = createInputField("RotX", "X Rotation:", 285)
    local rotYInput = createInputField("RotY", "Y Rotation:", 320)
    local rotZInput = createInputField("RotZ", "Z Rotation:", 355)
    
    -- Follow Toggle Button
    local followButton = Instance.new("TextButton")
    followButton.Name = "FollowButton"
    followButton.Size = UDim2.new(1, -20, 0, 40)
    followButton.Position = UDim2.new(0, 10, 1, -50)
    followButton.BackgroundColor3 = Color3.fromRGB(60, 180, 75)
    followButton.Text = "Start Following"
    followButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    followButton.TextSize = 15
    followButton.Font = Enum.Font.GothamBold
    followButton.Parent = mainFrame
    
    local followCorner = Instance.new("UICorner")
    followCorner.CornerRadius = UDim.new(0, 6)
    followCorner.Parent = followButton
    
    -- Reset Button
    local resetButton = Instance.new("TextButton")
    resetButton.Name = "ResetButton"
    resetButton.Size = UDim2.new(0.48, 0, 0, 35)
    resetButton.Position = UDim2.new(0, 10, 0, 395)
    resetButton.BackgroundColor3 = Color3.fromRGB(255, 140, 60)
    resetButton.Text = "Reset Values"
    resetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    resetButton.TextSize = 13
    resetButton.Font = Enum.Font.GothamBold
    resetButton.Parent = mainFrame
    
    local resetCorner = Instance.new("UICorner")
    resetCorner.CornerRadius = UDim.new(0, 6)
    resetCorner.Parent = resetButton
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0.48, 0, 0, 35)
    closeButton.Position = UDim2.new(0.52, 0, 0, 395)
    closeButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    closeButton.Text = "Close GUI"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 13
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton
    
    screenGui.Parent = PlayerGui
    
    return screenGui, {
        mainFrame = mainFrame,
        playerDropdown = playerDropdown,
        dropdownList = dropdownList,
        listLayout = listLayout,
        offsetXInput = offsetXInput,
        offsetYInput = offsetYInput,
        offsetZInput = offsetZInput,
        rotXInput = rotXInput,
        rotYInput = rotYInput,
        rotZInput = rotZInput,
        followButton = followButton,
        resetButton = resetButton,
        closeButton = closeButton
    }
end

-- Noclip function
local function enableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
    end
    
    noclipConnection = RunService.Stepped:Connect(function()
        local character = LocalPlayer.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

-- Disable noclip
local function disableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    -- Re-enable collisions
    local character = LocalPlayer.Character
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                if part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- Follow function
local function startFollowing()
    if followConnection then
        followConnection:Disconnect()
    end
    
    followConnection = RunService.RenderStepped:Connect(function()
        -- Safety checks
        if not targetPlayer or not targetPlayer.Parent then
            isFollowing = false
            return
        end
        
        local targetChar = targetPlayer.Character
        local localChar = LocalPlayer.Character
        
        if not targetChar or not localChar then
            return
        end
        
        local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
        local localHRP = localChar:FindFirstChild("HumanoidRootPart")
        
        if not targetHRP or not localHRP then
            return
        end
        
        -- Apply CFrame with offsets and rotation
        local offsetCFrame = CFrame.new(offsetX, offsetY, offsetZ)
        local rotationCFrame = CFrame.Angles(math.rad(rotX), math.rad(rotY), math.rad(rotZ))
        
        localHRP.CFrame = targetHRP.CFrame * offsetCFrame * rotationCFrame
    end)
end

-- Stop following
local function stopFollowing()
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
    disableNoclip()
end

-- Update player list
local function updatePlayerList(elements)
    -- Clear existing list
    for _, child in pairs(elements.dropdownList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Add players to list
    local players = Players:GetPlayers()
    local ySize = 0
    
    for _, player in ipairs(players) do
        if player ~= LocalPlayer then
            local playerButton = Instance.new("TextButton")
            playerButton.Name = player.Name
            playerButton.Size = UDim2.new(1, -10, 0, 30)
            playerButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            playerButton.Text = player.Name
            playerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            playerButton.TextSize = 13
            playerButton.Font = Enum.Font.Gotham
            playerButton.ZIndex = 11
            playerButton.Parent = elements.dropdownList
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 4)
            btnCorner.Parent = playerButton
            
            -- Button click event
            playerButton.MouseButton1Click:Connect(function()
                targetPlayer = player
                elements.playerDropdown.Text = player.Name
                elements.dropdownList.Visible = false
            end)
            
            ySize = ySize + 32
        end
    end
    
    elements.dropdownList.CanvasSize = UDim2.new(0, 0, 0, ySize)
end

-- Main execution
local function main()
    local gui, elements = createGUI()
    
    -- Update player list initially
    updatePlayerList(elements)
    
    -- Player dropdown toggle
    elements.playerDropdown.MouseButton1Click:Connect(function()
        elements.dropdownList.Visible = not elements.dropdownList.Visible
        updatePlayerList(elements)
    end)
    
    -- Input field handlers
    elements.offsetXInput.FocusLost:Connect(function()
        offsetX = tonumber(elements.offsetXInput.Text) or 0
        elements.offsetXInput.Text = tostring(offsetX)
    end)
    
    elements.offsetYInput.FocusLost:Connect(function()
        offsetY = tonumber(elements.offsetYInput.Text) or 0
        elements.offsetYInput.Text = tostring(offsetY)
    end)
    
    elements.offsetZInput.FocusLost:Connect(function()
        offsetZ = tonumber(elements.offsetZInput.Text) or 0
        elements.offsetZInput.Text = tostring(offsetZ)
    end)
    
    elements.rotXInput.FocusLost:Connect(function()
        rotX = tonumber(elements.rotXInput.Text) or 0
        elements.rotXInput.Text = tostring(rotX)
    end)
    
    elements.rotYInput.FocusLost:Connect(function()
        rotY = tonumber(elements.rotYInput.Text) or 0
        elements.rotYInput.Text = tostring(rotY)
    end)
    
    elements.rotZInput.FocusLost:Connect(function()
        rotZ = tonumber(elements.rotZInput.Text) or 0
        elements.rotZInput.Text = tostring(rotZ)
    end)
    
    -- Follow button
    elements.followButton.MouseButton1Click:Connect(function()
        if not targetPlayer then
            elements.followButton.Text = "Select a player first!"
            wait(1.5)
            elements.followButton.Text = "Start Following"
            return
        end
        
        isFollowing = not isFollowing
        
        if isFollowing then
            elements.followButton.Text = "Stop Following"
            elements.followButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
            enableNoclip()
            startFollowing()
        else
            elements.followButton.Text = "Start Following"
            elements.followButton.BackgroundColor3 = Color3.fromRGB(60, 180, 75)
            stopFollowing()
        end
    end)
    
    -- Reset button
    elements.resetButton.MouseButton1Click:Connect(function()
        offsetX, offsetY, offsetZ = 0, 0, 0
        rotX, rotY, rotZ = 0, 0, 0
        
        elements.offsetXInput.Text = "0"
        elements.offsetYInput.Text = "0"
        elements.offsetZInput.Text = "0"
        elements.rotXInput.Text = "0"
        elements.rotYInput.Text = "0"
        elements.rotZInput.Text = "0"
    end)
    
    -- Close button
    elements.closeButton.MouseButton1Click:Connect(function()
        stopFollowing()
        gui:Destroy()
    end)
    
    -- Handle target player leaving
    Players.PlayerRemoving:Connect(function(player)
        if player == targetPlayer then
            targetPlayer = nil
            elements.playerDropdown.Text = "Select Player..."
            if isFollowing then
                elements.followButton.Text = "Start Following"
                elements.followButton.BackgroundColor3 = Color3.fromRGB(60, 180, 75)
                isFollowing = false
                stopFollowing()
            end
        end
        updatePlayerList(elements)
    end)
    
    -- Handle new players joining
    Players.PlayerAdded:Connect(function()
        wait(0.5) -- Small delay to ensure player is fully loaded
        updatePlayerList(elements)
    end)
    
    -- Cleanup on character respawn
    LocalPlayer.CharacterAdded:Connect(function()
        if isFollowing then
            wait(1) -- Wait for character to fully load
            enableNoclip()
            startFollowing()
        end
    end)
end

-- Execute
main()

print("Advanced Player Follower GUI loaded successfully!")
