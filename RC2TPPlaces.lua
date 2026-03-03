-- === SERVICES ===
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer

-- === DEVICE CHECK ===
local isMobile = UserInputService.TouchEnabled

-- === GUI ROOT ===
local gui = Instance.new("ScreenGui")
gui.Name = "TeleportGUI"
gui.ResetOnSpawn = false
gui.Parent = lp:WaitForChild("PlayerGui")

-- === TOP TABS FRAME ===
local tabsFrame = Instance.new("Frame")
tabsFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
tabsFrame.Position = UDim2.new(0.5,0,0.05,0)
tabsFrame.AnchorPoint = Vector2.new(0.5,0)
tabsFrame.Parent = gui

if isMobile then
	tabsFrame.Size = UDim2.new(0,130,0,130)
else
	tabsFrame.Size = UDim2.new(0,900,0,130)
end

-- draggable
local dragTabs = Instance.new("UIDragDetector")
dragTabs.Parent = tabsFrame

-- === VARIABLES ===
local maxTabs = 10
local panels = {}
local storedCoords = {}

-- === TELEPORT FUNCTION ===
local function tp(x,y,z)
	local char = lp.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		char.HumanoidRootPart.CFrame = CFrame.new(x,y,z)
	end
end

-- === PANEL CREATOR ===
local function createPanel(number)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0,305,0,220)
	frame.Position = UDim2.new(0.5,-150,0.22,0)
	frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
	frame.Visible = false
	frame.Parent = gui

	local dragPanel = Instance.new("UIDragDetector")
	dragPanel.Parent = frame

	local function makeBox(y,placeholder)
		local box = Instance.new("TextBox")
		box.Size = UDim2.new(0,260,0,40)
		box.Position = UDim2.new(0,20,0,y)
		box.BackgroundColor3 = Color3.fromRGB(60,60,60)
		box.TextColor3 = Color3.fromRGB(255,255,255)
		box.PlaceholderText = placeholder
		box.Text = ""
		box.Font = Enum.Font.SourceSansBold
		box.TextSize = 24
		box.ClearTextOnFocus = false
		box.Parent = frame
		return box
	end

	local xBox = makeBox(15,"X")
	local yBox = makeBox(65,"Y")
	local zBox = makeBox(115,"Z")

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0,260,0,40)
	btn.Position = UDim2.new(0,20,0,165)
	btn.BackgroundColor3 = Color3.fromRGB(100,100,100)
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.Text = "SUBMIT"
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 24
	btn.Parent = frame

	btn.MouseButton1Click:Connect(function()
		local X = tonumber(xBox.Text)
		local Y = tonumber(yBox.Text)
		local Z = tonumber(zBox.Text)
		if X and Y and Z then
			storedCoords[number] = {X=X,Y=Y,Z=Z}
			tp(X,Y,Z)
		end
	end)

	return {frame=frame,x=xBox,y=yBox,z=zBox}
end

-- === CREATE TABS ===
local tabContainer
if isMobile then
	tabContainer = Instance.new("ScrollingFrame")
	tabContainer.Size = UDim2.new(1,0,1,0)
	tabContainer.CanvasSize = UDim2.new(0,0,0,0)
	tabContainer.ScrollBarThickness = 6
	tabContainer.BackgroundTransparency = 1
	tabContainer.Parent = tabsFrame
else
	tabContainer = tabsFrame
end

local buttonsPerRow = isMobile and 3 or 1
local buttonSize = isMobile and UDim2.new(0,40,0,40) or UDim2.new(0,55,0,50)
local padding = isMobile and 5 or 0

for i=1,maxTabs do
	local tab = Instance.new("TextButton")
	tab.Size = buttonSize
	tab.BackgroundColor3 = Color3.fromRGB(70,70,70)
	tab.TextColor3 = Color3.fromRGB(255,255,255)
	tab.Text = tostring(i)
	tab.Font = Enum.Font.SourceSansBold
	tab.TextSize = 22
	tab.Parent = tabContainer

	if isMobile then
		local row = math.floor((i-1)/buttonsPerRow)
		local col = (i-1)%buttonsPerRow
		tab.Position = UDim2.new(0, col*(buttonSize.X.Offset+padding),0,row*(buttonSize.Y.Offset+padding))
		tabContainer.CanvasSize = UDim2.new(0,0,0,(row+1)*(buttonSize.Y.Offset+padding))
	else
		tab.Position = UDim2.new(0,(i-1)*60,0,10)
	end

	panels[i] = createPanel(i)

	tab.MouseButton1Click:Connect(function()
		local panel = panels[i]
		panel.frame.Visible = not panel.frame.Visible
		if storedCoords[i] and panel.frame.Visible then
			panel.x.Text = storedCoords[i].X
			panel.y.Text = storedCoords[i].Y
			panel.z.Text = storedCoords[i].Z
		end
	end)
end

-- === QUICK TP BUTTONS ===
local quickTps = {
	{emoji="🏕️",pos=Vector3.new(337,154,2766)},
	{emoji="🏜️",pos=Vector3.new(986,-200,473)},
	{emoji="🌳",pos=Vector3.new(-177,-480,1567)},
	{emoji="⛓️",pos=Vector3.new(-1884,-647,2272)},
	{emoji="💎",pos=Vector3.new(-6601,-470,1000)},
	{emoji="⬇️",pos=Vector3.new(-7800,0,-3274)},
	{emoji="🌋",pos=Vector3.new(-7303,-585,-2857)},
	{emoji="🖼️",pos=Vector3.new(1528,45,-548)},
	{emoji="🌸",pos=Vector3.new(-5620,35,4499)},
	{emoji="🗻",pos=Vector3.new(-7235,774,-3281)},
	{emoji="🏪",pos=Vector3.new(1250,31,-700)},
	{emoji="🏞️",pos=Vector3.new(1221,4,2072)},
	{emoji="🌑",pos=Vector3.new(362,-96,3299)},
	{emoji="🟪",pos=Vector3.new(-7122,-711,-2541)},
	{emoji="💵",pos=Vector3.new(920,30,-710)},
	{emoji="🔁",rejoin=true},
}

local quickFrame = Instance.new("ScrollingFrame")
if isMobile then
	quickFrame.Size = UDim2.new(1,0,0,buttonSize.Y.Offset*math.ceil(#quickTps/buttonsPerRow)+padding*math.ceil(#quickTps/buttonsPerRow))
else
	quickFrame.Size = UDim2.new(0,900,0,60)
end
quickFrame.Position = UDim2.new(0,0,0,isMobile and 0 or 70)
quickFrame.ScrollBarThickness = 6
quickFrame.BackgroundTransparency = 1
quickFrame.Parent = tabsFrame

for i,data in ipairs(quickTps) do
	local btn = Instance.new("TextButton")
	btn.Size = buttonSize
	btn.BackgroundColor3 = Color3.fromRGB(90,90,90)
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.Text = data.emoji
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 26
	btn.Parent = quickFrame

	if isMobile then
		local row = math.floor((i-1)/buttonsPerRow)
		local col = (i-1)%buttonsPerRow
		btn.Position = UDim2.new(0, col*(buttonSize.X.Offset+padding),0,row*(buttonSize.Y.Offset+padding))
		quickFrame.CanvasSize = UDim2.new(0,0,0,(row+1)*(buttonSize.Y.Offset+padding))
	else
		btn.Position = UDim2.new(0,(i-1)*60,0,5)
	end

	btn.MouseButton1Click:Connect(function()
		if data.rejoin then
			TeleportService:Teleport(game.PlaceId, lp)
		else
			tp(data.pos.X,data.pos.Y,data.pos.Z)
		end
	end)
end

-- === NAMED TP BUTTONS ===
local namedTps = {
	-- приклад: {emoji="⚡",target="LightningPad"}
}

local function findTargetByName(name)
	for _,inst in ipairs(workspace:GetDescendants()) do
		if inst.Name==name then
			return inst
		end
	end
end

local namedFrame = Instance.new("ScrollingFrame")
if isMobile then
	namedFrame.Size = UDim2.new(1,0,0,buttonSize.Y.Offset*math.ceil(#namedTps/buttonsPerRow)+padding*math.ceil(#namedTps/buttonsPerRow))
else
	namedFrame.Size = UDim2.new(0,900,0,60)
end
namedFrame.Position = UDim2.new(0,0,0,isMobile and buttonSize.Y.Offset*math.ceil(#quickTps/buttonsPerRow)+padding*math.ceil(#quickTps/buttonsPerRow) or 130)
namedFrame.ScrollBarThickness = 6
namedFrame.BackgroundTransparency = 1
namedFrame.Parent = tabsFrame

for i,data in ipairs(namedTps) do
	local btn = Instance.new("TextButton")
	btn.Size = buttonSize
	btn.BackgroundColor3 = Color3.fromRGB(110,110,110)
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.Text = data.emoji
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 26
	btn.Parent = namedFrame

	if isMobile then
		local row = math.floor((i-1)/buttonsPerRow)
		local col = (i-1)%buttonsPerRow
		btn.Position = UDim2.new(0, col*(buttonSize.X.Offset+padding),0,row*(buttonSize.Y.Offset+padding))
		namedFrame.CanvasSize = UDim2.new(0,0,0,(row+1)*(buttonSize.Y.Offset+padding))
	else
		btn.Position = UDim2.new(0,(i-1)*60,0,5)
	end

	btn.MouseButton1Click:Connect(function()
		local inst = findTargetByName(data.target)
		if not inst then return end
		local pos
		if inst:IsA("BasePart") then
			pos = inst.Position
		elseif inst:IsA("Model") then
			if inst.PrimaryPart then
				pos = inst.PrimaryPart.Position
			else
				pos = inst:GetPivot().Position
			end
		end
		if pos then
			tp(pos.X,pos.Y,pos.Z)
		end
	end)
end
