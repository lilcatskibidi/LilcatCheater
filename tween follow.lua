local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 🔹 Constants
local GUI_NAME = "FollowPlayerGui"
local TWEEN_INFO = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
local STORAGE_KEY = "FollowPlayerGui_Position"

-- 🔹 Remove old GUI
local existing = CoreGui:FindFirstChild(GUI_NAME)
if existing then
	existing:Destroy()
end

-- === GUI CREATION ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = GUI_NAME
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 580)
mainFrame.Position = UDim2.new(0, 20, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIGradient", mainFrame).Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 50)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 30))
}

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 8)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 5, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Player Follow"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = titleBar

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.BackgroundTransparency = 1
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
closeButton.TextSize = 16
closeButton.Parent = titleBar
closeButton.MouseButton1Click:Connect(function()
	screenGui.Enabled = false
end)

-- Search bar
local searchBar = Instance.new("TextBox")
searchBar.Size = UDim2.new(1, -10, 0, 30)
searchBar.Position = UDim2.new(0, 5, 0, 35)
searchBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
searchBar.TextColor3 = Color3.new(1, 1, 1)
searchBar.PlaceholderText = "Search players..."
searchBar.Text = ""
searchBar.TextSize = 14
searchBar.Parent = mainFrame
Instance.new("UICorner", searchBar)

-- Offset config
local offsetLabel = Instance.new("TextLabel")
offsetLabel.Size = UDim2.new(0, 80, 0, 25)
offsetLabel.Position = UDim2.new(0, 5, 0, 70)
offsetLabel.BackgroundTransparency = 1
offsetLabel.Text = "Distance:"
offsetLabel.TextColor3 = Color3.new(1, 1, 1)
offsetLabel.TextSize = 13
offsetLabel.Parent = mainFrame

local offsetBox = Instance.new("TextBox")
offsetBox.Size = UDim2.new(0, 60, 0, 25)
offsetBox.Position = UDim2.new(0, 85, 0, 70)
offsetBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
offsetBox.TextColor3 = Color3.new(1, 1, 1)
offsetBox.Text = "3"
offsetBox.TextSize = 13
offsetBox.Parent = mainFrame
Instance.new("UICorner", offsetBox)

-- Orbit speed
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 80, 0, 25)
speedLabel.Position = UDim2.new(0, 155, 0, 70)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed:"
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.TextSize = 13
speedLabel.Parent = mainFrame

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0, 60, 0, 25)
speedBox.Position = UDim2.new(0, 235, 0, 70)
speedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedBox.TextColor3 = Color3.new(1, 1, 1)
speedBox.Text = "0.05"
speedBox.TextSize = 13
speedBox.Parent = mainFrame
Instance.new("UICorner", speedBox)

-- Orbit height
local heightLabel = Instance.new("TextLabel")
heightLabel.Size = UDim2.new(0, 80, 0, 25)
heightLabel.Position = UDim2.new(0, 5, 0, 100)
heightLabel.BackgroundTransparency = 1
heightLabel.Text = "Height:"
heightLabel.TextColor3 = Color3.new(1, 1, 1)
heightLabel.TextSize = 13
heightLabel.Parent = mainFrame

local heightBox = Instance.new("TextBox")
heightBox.Size = UDim2.new(0, 60, 0, 25)
heightBox.Position = UDim2.new(0, 85, 0, 100)
heightBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
heightBox.TextColor3 = Color3.new(1, 1, 1)
heightBox.Text = "0"
heightBox.TextSize = 13
heightBox.Parent = mainFrame
Instance.new("UICorner", heightBox)

-- Orbit radius X
local radiusXLabel = Instance.new("TextLabel")
radiusXLabel.Size = UDim2.new(0, 80, 0, 25)
radiusXLabel.Position = UDim2.new(0, 155, 0, 100)
radiusXLabel.BackgroundTransparency = 1
radiusXLabel.Text = "Radius X:"
radiusXLabel.TextColor3 = Color3.new(1, 1, 1)
radiusXLabel.TextSize = 13
radiusXLabel.Parent = mainFrame

local radiusXBox = Instance.new("TextBox")
radiusXBox.Size = UDim2.new(0, 60, 0, 25)
radiusXBox.Position = UDim2.new(0, 235, 0, 100)
radiusXBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
radiusXBox.TextColor3 = Color3.new(1, 1, 1)
radiusXBox.Text = "3"
radiusXBox.TextSize = 13
radiusXBox.Parent = mainFrame
Instance.new("UICorner", radiusXBox)

-- Orbit radius Z
local radiusZLabel = Instance.new("TextLabel")
radiusZLabel.Size = UDim2.new(0, 80, 0, 25)
radiusZLabel.Position = UDim2.new(0, 5, 0, 130)
radiusZLabel.BackgroundTransparency = 1
radiusZLabel.Text = "Radius Z:"
radiusZLabel.TextColor3 = Color3.new(1, 1, 1)
radiusZLabel.TextSize = 13
radiusZLabel.Parent = mainFrame

local radiusZBox = Instance.new("TextBox")
radiusZBox.Size = UDim2.new(0, 60, 0, 25)
radiusZBox.Position = UDim2.new(0, 85, 0, 130)
radiusZBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
radiusZBox.TextColor3 = Color3.new(1, 1, 1)
radiusZBox.Text = "3"
radiusZBox.TextSize = 13
radiusZBox.Parent = mainFrame
Instance.new("UICorner", radiusZBox)

-- Orbit toggle
local orbitToggle = Instance.new("TextButton")
orbitToggle.Size = UDim2.new(1, -10, 0, 30)
orbitToggle.Position = UDim2.new(0, 5, 0, 160)
orbitToggle.BackgroundColor3 = Color3.fromRGB(70, 70, 120)
orbitToggle.TextColor3 = Color3.new(1, 1, 1)
orbitToggle.Text = "Orbit: OFF"
orbitToggle.TextSize = 14
orbitToggle.Parent = mainFrame
Instance.new("UICorner", orbitToggle)

-- Scrolling list
local scrolling = Instance.new("ScrollingFrame")
scrolling.Size = UDim2.new(1, -10, 1, -310)
scrolling.Position = UDim2.new(0, 5, 0, 195)
scrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
scrolling.ScrollBarThickness = 6
scrolling.BackgroundTransparency = 1
scrolling.Parent = mainFrame

local uiList = Instance.new("UIListLayout")
uiList.Parent = scrolling
uiList.Padding = UDim.new(0, 5)

-- Buttons
local followButton = Instance.new("TextButton")
followButton.Size = UDim2.new(1, -10, 0, 40)
followButton.Position = UDim2.new(0, 5, 1, -235)
followButton.BackgroundColor3 = Color3.fromRGB(70, 100, 70)
followButton.TextColor3 = Color3.new(1, 1, 1)
followButton.Text = "Follow: OFF"
followButton.TextSize = 16
followButton.Font = Enum.Font.SourceSansBold
followButton.Parent = mainFrame
Instance.new("UICorner", followButton)

local spectateButton = Instance.new("TextButton")
spectateButton.Size = UDim2.new(1, -10, 0, 40)
spectateButton.Position = UDim2.new(0, 5, 1, -190)
spectateButton.BackgroundColor3 = Color3.fromRGB(90, 70, 120)
spectateButton.TextColor3 = Color3.new(1, 1, 1)
spectateButton.Text = "Spectator: OFF"
spectateButton.TextSize = 16
spectateButton.Font = Enum.Font.SourceSansBold
spectateButton.Parent = mainFrame
Instance.new("UICorner", spectateButton)

local lockButton = Instance.new("TextButton")
lockButton.Size = UDim2.new(1, -10, 0, 40)
lockButton.Position = UDim2.new(0, 5, 1, -145)
lockButton.BackgroundColor3 = Color3.fromRGB(120, 70, 70)
lockButton.TextColor3 = Color3.new(1, 1, 1)
lockButton.Text = "Lock: OFF"
lockButton.TextSize = 16
lockButton.Font = Enum.Font.SourceSansBold
lockButton.Parent = mainFrame
Instance.new("UICorner", lockButton)

local cancellToggle = Instance.new("TextButton")
cancellToggle.Size = UDim2.new(1, -10, 0, 40)
cancellToggle.Position = UDim2.new(0, 5, 1, -100)
cancellToggle.BackgroundColor3 = Color3.fromRGB(120, 100, 70)
cancellToggle.TextColor3 = Color3.new(1, 1, 1)
cancellToggle.Text = "Collision: OFF"
cancellToggle.TextSize = 16
cancellToggle.Font = Enum.Font.SourceSansBold
cancellToggle.Parent = mainFrame
Instance.new("UICorner", cancellToggle)

local aimbotToggle = Instance.new("TextButton")
aimbotToggle.Size = UDim2.new(1, -10, 0, 40)
aimbotToggle.Position = UDim2.new(0, 5, 1, -55)
aimbotToggle.BackgroundColor3 = Color3.fromRGB(70, 120, 120)
aimbotToggle.TextColor3 = Color3.new(1, 1, 1)
aimbotToggle.Text = "Aimbot: OFF"
aimbotToggle.TextSize = 16
aimbotToggle.Font = Enum.Font.SourceSansBold
aimbotToggle.Parent = mainFrame
Instance.new("UICorner", aimbotToggle)

-- === LOGIC ===
local following = false
local spectating = false
local locking = false
local orbitMode = false
local collisionMode = false
local aimbotMode = false
local targetPlayer = nil
local playerButtons = {}
local highlight = nil
local billGui = nil
local nameLabel = nil
local healthLabel = nil
local distLabel = nil
local respawnConn = nil
local orbitAngle = 0
local affectedParts = {}
local originalCancollide = {}
local isLocking = false

-- Load saved position
local success, savedPosition = pcall(function()
	return game:GetService("DataStoreService"):GetDataStore(STORAGE_KEY):GetAsync(LocalPlayer.UserId)
end)
if success and savedPosition then
	mainFrame.Position = UDim2.new(savedPosition.X.Scale, savedPosition.X.Offset, savedPosition.Y.Scale, savedPosition.Y.Offset)
end

-- Save position on drag
mainFrame:GetPropertyChangedSignal("Position"):Connect(function()
	local pos = mainFrame.Position
	local success = pcall(function()
		game:GetService("DataStoreService"):GetDataStore(STORAGE_KEY):SetAsync(LocalPlayer.UserId, {
			X = {Scale = pos.X.Scale, Offset = pos.X.Offset},
			Y = {Scale = pos.Y.Scale, Offset = pos.Y.Offset}
		})
	end)
end)

-- Button hover effects
local function applyHoverEffect(button)
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TWEEN_INFO, {BackgroundColor3 = button.BackgroundColor3:Lerp(Color3.fromRGB(255, 255, 255), 0.2)}):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TWEEN_INFO, {BackgroundColor3 = button.BackgroundColor3}):Play()
	end)
end

applyHoverEffect(followButton)
applyHoverEffect(spectateButton)
applyHoverEffect(lockButton)
applyHoverEffect(closeButton)
applyHoverEffect(orbitToggle)
applyHoverEffect(cancellToggle)
applyHoverEffect(aimbotToggle)

-- Highlight selection
local function highlightSelection(plr)
	for p, btn in pairs(playerButtons) do
		local color = p == plr and Color3.fromRGB(100, 140, 255) or Color3.fromRGB(60, 60, 60)
		TweenService:Create(btn, TWEEN_INFO, {BackgroundColor3 = color}):Play()
	end
end

-- Populate player buttons
local function refreshPlayers(filter)
	for _, child in ipairs(scrolling:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	playerButtons = {}

	local count = 0
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and (not filter or string.find(string.lower(plr.Name), string.lower(filter))) then
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, -10, 0, 30)
			btn.Text = plr.Name
			btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			btn.TextColor3 = Color3.new(1, 1, 1)
			btn.TextSize = 14
			btn.Font = Enum.Font.SourceSans
			btn.Parent = scrolling
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
			applyHoverEffect(btn)

			playerButtons[plr] = btn

			btn.MouseButton1Click:Connect(function()
				local oldTarget = targetPlayer
				targetPlayer = plr
				highlightSelection(plr)
				
				-- Re-enable lock if it was on
				if locking and oldTarget ~= targetPlayer then
					disableLock()
					enableLock()
				end
			end)

			count += 1
		end
	end

	scrolling.CanvasSize = UDim2.new(0, 0, 0, count * 35)
end

-- Search bar handler
searchBar:GetPropertyChangedSignal("Text"):Connect(function()
	refreshPlayers(searchBar.Text)
end)

Players.PlayerAdded:Connect(function() refreshPlayers(searchBar.Text) end)
Players.PlayerRemoving:Connect(function() refreshPlayers(searchBar.Text) end)
refreshPlayers()

-- Lock functions (ESP + Tracking)
local function enableLock()
	if not targetPlayer then return end
	disableLock()

	local char = targetPlayer.Character
	if not char then return end
	local head = char:FindFirstChild("Head")
	if not head then return end

	-- Highlight
	highlight = Instance.new("Highlight")
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
	highlight.Parent = char

	-- Billboard GUI
	billGui = Instance.new("BillboardGui")
	billGui.AlwaysOnTop = true
	billGui.LightInfluence = 0
	billGui.Size = UDim2.new(5, 0, 3, 0)
	billGui.StudsOffset = Vector3.new(0, 3, 0)
	billGui.Adornee = head
	billGui.Parent = screenGui

	nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Size = UDim2.new(1, 0, 0.33, 0)
	nameLabel.Text = targetPlayer.DisplayName or targetPlayer.Name
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.TextScaled = true
	nameLabel.TextStrokeTransparency = 0
	nameLabel.Parent = billGui

	healthLabel = Instance.new("TextLabel")
	healthLabel.BackgroundTransparency = 1
	healthLabel.Position = UDim2.new(0, 0, 0.33, 0)
	healthLabel.Size = UDim2.new(1, 0, 0.33, 0)
	healthLabel.Text = "Health: "
	healthLabel.TextColor3 = Color3.new(1, 1, 1)
	healthLabel.TextScaled = true
	healthLabel.TextStrokeTransparency = 0
	healthLabel.Parent = billGui

	distLabel = Instance.new("TextLabel")
	distLabel.BackgroundTransparency = 1
	distLabel.Position = UDim2.new(0, 0, 0.66, 0)
	distLabel.Size = UDim2.new(1, 0, 0.33, 0)
	distLabel.Text = "0 studs"
	distLabel.TextColor3 = Color3.new(1, 1, 1)
	distLabel.TextScaled = true
	distLabel.TextStrokeTransparency = 0
	distLabel.Parent = billGui

	respawnConn = targetPlayer.CharacterAdded:Connect(function(newChar)
		task.wait(0.1)
		local newHead = newChar:FindFirstChild("Head")
		if newHead and locking then
			billGui.Adornee = newHead
			highlight.Parent = newChar
		end
	end)
	
	isLocking = true
end

local function disableLock()
	isLocking = false
	if highlight then
		highlight:Destroy()
		highlight = nil
	end
	if billGui then
		billGui:Destroy()
		billGui = nil
		nameLabel = nil
		healthLabel = nil
		distLabel = nil
	end
	if respawnConn then
		respawnConn:Disconnect()
		respawnConn = nil
	end
end

-- Collision functions
local function enableCollision()
	if collisionMode then
		local parts = Workspace:GetDescendants()
		for _, part in ipairs(parts) do
			if part:IsA("BasePart") and part.CanCollide then
				table.insert(affectedParts, part)
				table.insert(originalCancollide, true)
				part.CanCollide = false
			end
		end
	end
end

local function disableCollision()
	for i, part in ipairs(affectedParts) do
		if part and part:IsA("BasePart") then
			part.CanCollide = originalCancollide[i] or true
		end
	end
	affectedParts = {}
	originalCancollide = {}
end

-- Aimbot function (look at target)
local function aimAtTarget()
	if not targetPlayer or not aimbotMode then return end
	
	local char = LocalPlayer.Character
	if not char then return end
	
	local targetChar = targetPlayer.Character
	if not targetChar then return end
	
	local head = char:FindFirstChild("Head")
	local targetHead = targetChar:FindFirstChild("Head")
	
	if head and targetHead then
		local lookAt = targetHead.Position
		local direction = (lookAt - head.Position).Unit
		
		-- Create CFrame looking at target
		local newCFrame = CFrame.new(head.Position, lookAt)
		
		-- Apply to character (rotate character to face target)
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(targetHead.Position.X, hrp.Position.Y, targetHead.Position.Z))
		end
		
		-- Aim camera at target
		Camera.CameraType = Enum.CameraType.Scriptable
		local camPos = head.Position + Vector3.new(0, 1, 0)
		Camera.CFrame = CFrame.new(camPos, targetHead.Position)
	end
end

-- Main update loop
RunService.RenderStepped:Connect(function()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")

	-- Follow logic
	if following and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local targetChar = targetPlayer.Character
		local targetHRP = targetChar.HumanoidRootPart
		local distance = tonumber(offsetBox.Text) or 3
		local height = tonumber(heightBox.Text) or 0
		
		if orbitMode then
			-- Orbit around target
			local speed = tonumber(speedBox.Text) or 0.05
			orbitAngle = orbitAngle + speed
			local radiusX = tonumber(radiusXBox.Text) or 3
			local radiusZ = tonumber(radiusZBox.Text) or 3
			
			local x = targetHRP.Position.X + math.cos(orbitAngle) * radiusX
			local z = targetHRP.Position.Z + math.sin(orbitAngle) * radiusZ
			local y = targetHRP.Position.Y + height
			
			local targetPos = Vector3.new(x, y, z)
			local lookAt = targetHRP.Position
			
			if hrp then
				hrp.CFrame = CFrame.new(targetPos, lookAt)
				if hum then
					Camera.CameraType = Enum.CameraType.Custom
					Camera.CameraSubject = hum
				end
			end
		else
			-- Normal follow - teleport behind target
			local targetPos = targetHRP.Position - targetHRP.CFrame.LookVector * distance
			targetPos = targetPos + Vector3.new(0, height, 0)
			local targetCFrame = CFrame.new(targetPos, targetHRP.Position)
			if hrp then
				hrp.CFrame = targetCFrame
				if hum then
					Camera.CameraType = Enum.CameraType.Custom
					Camera.CameraSubject = hum
				end
			end
		end
	end
	
	-- Spectator logic
	if spectating and targetPlayer and targetPlayer.Character then
		local targetChar = targetPlayer.Character
		local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
		if targetHum then
			Camera.CameraType = Enum.CameraType.Custom
			Camera.CameraSubject = targetHum
		end
	elseif not spectating and not following then
		if hum then
			Camera.CameraType = Enum.CameraType.Custom
			Camera.CameraSubject = hum
		end
	end

	-- Lock logic (update ESP info)
	if locking and targetPlayer and targetPlayer.Character and hrp then
		local targetChar = targetPlayer.Character
		local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
		local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
		if targetHRP then
			local dist = (hrp.Position - targetHRP.Position).Magnitude
			if distLabel then
				distLabel.Text = math.floor(dist) .. " studs"
			end
		end
		if targetHum and healthLabel then
			healthLabel.Text = "Health: " .. math.floor(targetHum.Health) .. "/" .. targetHum.MaxHealth
		end
	end
	
	-- Aimbot logic
	if aimbotMode and targetPlayer then
		aimAtTarget()
	end
end)

-- Follow button logic
followButton.MouseButton1Click:Connect(function()
	if spectating or not targetPlayer then return end
	following = not following
	followButton.Text = following and "Follow: ON" or "Follow: OFF"
	if following then
		spectating = false
		spectateButton.Text = "Spectator: OFF"
		orbitAngle = 0
		-- Reset camera
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			Camera.CameraType = Enum.CameraType.Custom
			Camera.CameraSubject = hum
		end
	end
end)

-- Spectator button logic
spectateButton.MouseButton1Click:Connect(function()
	if not targetPlayer then return end
	spectating = not spectating
	spectateButton.Text = spectating and "Spectator: ON" or "Spectator: OFF"
	if spectating then
		following = false
		followButton.Text = "Follow: OFF"
	end
end)

-- Lock button logic
lockButton.MouseButton1Click:Connect(function()
	if not targetPlayer then return end
	locking = not locking
	lockButton.Text = locking and "Lock: ON" or "Lock: OFF"
	if locking then
		enableLock()
	else
		disableLock()
	end
end)

-- Orbit toggle logic
orbitToggle.MouseButton1Click:Connect(function()
	if not following then
		following = true
		followButton.Text = "Follow: ON"
		spectating = false
		spectateButton.Text = "Spectator: OFF"
	end
	orbitMode = not orbitMode
	orbitToggle.Text = orbitMode and "Orbit: ON" or "Orbit: OFF"
	if orbitMode then
		orbitAngle = 0
	end
end)

-- Collision toggle logic
cancellToggle.MouseButton1Click:Connect(function()
	collisionMode = not collisionMode
	cancellToggle.Text = collisionMode and "Collision: ON" or "Collision: OFF"
	
	if collisionMode then
		enableCollision()
	else
		disableCollision()
	end
end)

-- Aimbot toggle logic
aimbotToggle.MouseButton1Click:Connect(function()
	if not targetPlayer then return end
	aimbotMode = not aimbotMode
	aimbotToggle.Text = aimbotMode and "Aimbot: ON" or "Aimbot: OFF"
end)

-- Reset states on respawn
LocalPlayer.CharacterAdded:Connect(function(char)
	following = false
	spectating = false
	aimbotMode = false
	followButton.Text = "Follow: OFF"
	spectateButton.Text = "Spectator: OFF"
	aimbotToggle.Text = "Aimbot: OFF"
	
	if collisionMode then
		disableCollision()
		collisionMode = false
		cancellToggle.Text = "Collision: OFF"
	end
	
	local hum = char:WaitForChild("Humanoid")
	Camera.CameraType = Enum.CameraType.Custom
	Camera.CameraSubject = hum
end)

-- Error handling for player leaving
Players.PlayerRemoving:Connect(function(plr)
	if plr == targetPlayer then
		following = false
		spectating = false
		locking = false
		orbitMode = false
		aimbotMode = false
		followButton.Text = "Follow: OFF"
		spectateButton.Text = "Spectator: OFF"
		lockButton.Text = "Lock: OFF"
		orbitToggle.Text = "Orbit: OFF"
		aimbotToggle.Text = "Aimbot: OFF"
		targetPlayer = nil
		highlightSelection(nil)
		disableLock()
		
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			Camera.CameraType = Enum.CameraType.Custom
			Camera.CameraSubject = hum
		end
	end
end)

-- Cleanup when GUI is disabled
screenGui:GetPropertyChangedSignal("Enabled"):Connect(function()
	if not screenGui.Enabled then
		if collisionMode then
			disableCollision()
			collisionMode = false
			cancellToggle.Text = "Collision: OFF"
		end
		if locking then
			disableLock()
			locking = false
			lockButton.Text = "Lock: OFF"
		end
		following = false
		spectating = false
		aimbotMode = false
		followButton.Text = "Follow: OFF"
		spectateButton.Text = "Spectator: OFF"
		aimbotToggle.Text = "Aimbot: OFF"
	end
end)

print("Follow GUI loaded successfully!")
