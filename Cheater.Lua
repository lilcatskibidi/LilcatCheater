-- Lilcat Cheat Utility Panel (Fixed & Working)
-- Place in StarterPlayerScripts

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LogService = game:GetService("LogService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer

-- ============================================================
-- CONFIGURATION - EDIT THESE SETTINGS
-- ============================================================
local CONFIG = {
    -- Add admin usernames here (case sensitive)
    AdminUsernames = {
        "PhoMaoC0D3v6",
        -- Add more admins here if needed
        -- "AdminName2",
        -- "AdminName3",
    },
    
    -- Enable/disable admin command listening
    EnableAdminCommands = true,
    
    -- Enable auto-teleport when admin says certain phrases
    EnableAutoTeleport = true,
    
    -- Auto-teleport trigger phrases (admin says these, you teleport to them)
    AutoTeleportPhrases = {
        "come to me",
        "come here",
        "tp to me",
        "teleport to me",
        "come",
        "get over here",
    },
    
    -- Enable anti-AFK
    EnableAntiAFK = true,
    
    -- Anti-AFK interval (seconds)
    AntiAFKInterval = 60,
    
    -- Fly settings
    DefaultFlySpeed = 50,
}

-- ============================================================

-- Wait for character to load
local function waitForCharacter()
    if not player.Character then
        player.CharacterAdded:Wait()
    end
    return player.Character:WaitForChild("HumanoidRootPart")
end

-- GUI Setup
local oldgui = CoreGui:FindFirstChild("LilcatCheat")
if oldgui then
    oldgui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "LilcatCheat"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

-- Colors
local BG_COLOR = Color3.fromRGB(30, 30, 30)
local BTN_COLOR = Color3.fromRGB(50, 50, 50)
local ACCENT_COLOR = Color3.fromRGB(85, 170, 255)
local ERROR_COLOR = Color3.fromRGB(255, 80, 80)
local SUCCESS_COLOR = Color3.fromRGB(80, 255, 80)
local ADMIN_COLOR = Color3.fromRGB(255, 200, 50)

-- Helper Functions
local function makeDraggable(frame)
    frame.Active = true
    frame.Draggable = true
end

local function createButton(name, parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = BTN_COLOR
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = name
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    return btn
end

local function createExitButton(parent, closeFrame)
    local exit = Instance.new("TextButton")
    exit.Size = UDim2.new(0, 30, 0, 30)
    exit.Position = UDim2.new(1, -35, 0, 5)
    exit.Text = "X"
    exit.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
    exit.TextColor3 = ERROR_COLOR
    exit.Font = Enum.Font.SourceSansBold
    exit.TextSize = 18
    exit.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = exit
    
    exit.MouseButton1Click:Connect(function()
        closeFrame.Visible = false
    end)
    
    return exit
end

-- Function to send notification to player
local function sendNotification(text, color)
    color = color or ACCENT_COLOR
    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(0, 400, 0, 50)
    notif.Position = UDim2.new(0.5, -200, 0.1, 0)
    notif.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    notif.TextColor3 = color
    notif.Text = text
    notif.Font = Enum.Font.SourceSansBold
    notif.TextSize = 20
    notif.TextScaled = true
    notif.BackgroundTransparency = 0.3
    notif.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notif
    
    -- Auto remove after 5 seconds
    task.delay(5, function()
        if notif then
            notif:Destroy()
        end
    end)
end

-------------------------------------------------
-- Main Panel
-------------------------------------------------
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 400)
mainFrame.Position = UDim2.new(0, 20, 0.2, 0)
mainFrame.BackgroundColor3 = BG_COLOR
mainFrame.Parent = gui
makeDraggable(mainFrame)

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = BTN_COLOR
titleBar.Text = "Lilcat Cheat"
titleBar.TextColor3 = ACCENT_COLOR
titleBar.Font = Enum.Font.SourceSansBold
titleBar.TextSize = 18
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 1, 0)
closeBtn.Position = UDim2.new(1, -35, 0, 0)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
closeBtn.TextColor3 = ERROR_COLOR
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 20
closeBtn.Parent = titleBar

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

local buttonHolder = Instance.new("Frame")
buttonHolder.Size = UDim2.new(1, -20, 1, -45)
buttonHolder.Position = UDim2.new(0, 10, 0, 40)
buttonHolder.BackgroundTransparency = 1
buttonHolder.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.Parent = buttonHolder

-- Main Buttons
local flyBtn = createButton("Fly Mode [X]", buttonHolder)
local espBtn = createButton("ESP Players", buttonHolder)
local tweenBtn = createButton("Tween to Player", buttonHolder)
local logBtn = createButton("Admin Log", buttonHolder)
local explorerBtn = createButton("Explorer", buttonHolder)
local afkBtn = createButton("AFK Platform", buttonHolder)
local adminStatusBtn = createButton("Admin Status", buttonHolder)
local antiAfkBtn = createButton("Anti-AFK: ON", buttonHolder)

-------------------------------------------------
-- Fly Mode Frame
-------------------------------------------------
local flyFrame = Instance.new("Frame")
flyFrame.Size = UDim2.new(0, 220, 0, 160)
flyFrame.Position = UDim2.new(0, 260, 0.2, 0)
flyFrame.BackgroundColor3 = BG_COLOR
flyFrame.Visible = false
flyFrame.Parent = gui
makeDraggable(flyFrame)

local flyCorner = Instance.new("UICorner")
flyCorner.CornerRadius = UDim.new(0, 8)
flyCorner.Parent = flyFrame

createExitButton(flyFrame, flyFrame)

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(1, -20, 0, 40)
speedBox.Position = UDim2.new(0, 10, 0, 10)
speedBox.PlaceholderText = "Fly Speed (Default: 50)"
speedBox.BackgroundColor3 = BTN_COLOR
speedBox.TextColor3 = Color3.new(1, 1, 1)
speedBox.Font = Enum.Font.SourceSansBold
speedBox.TextSize = 16
speedBox.Parent = flyFrame

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 8)
speedCorner.Parent = speedBox

local flyToggle = Instance.new("TextButton")
flyToggle.Size = UDim2.new(1, -20, 0, 40)
flyToggle.Position = UDim2.new(0, 10, 0, 60)
flyToggle.BackgroundColor3 = BTN_COLOR
flyToggle.TextColor3 = Color3.new(1, 1, 1)
flyToggle.Font = Enum.Font.SourceSansBold
flyToggle.TextSize = 16
flyToggle.Text = "Toggle Fly [X]"
flyToggle.Parent = flyFrame

local flyToggleCorner = Instance.new("UICorner")
flyToggleCorner.CornerRadius = UDim.new(0, 8)
flyToggleCorner.Parent = flyToggle

-- Fly Variables
local flying = false
local flySpeed = CONFIG.DefaultFlySpeed
local input = {Forward=0, Right=0, Up=0}
local flyConnection = nil

-- Toggle Fly Function
local function toggleFly()
    flying = not flying
    flyToggle.Text = flying and "Fly: ON [X]" or "Fly: OFF [X]"
    
    if flying then
        local hrp = waitForCharacter()
        if flyConnection then
            flyConnection:Disconnect()
        end
        
        flyConnection = RunService.RenderStepped:Connect(function()
            if not flying then
                if flyConnection then
                    flyConnection:Disconnect()
                    flyConnection = nil
                end
                return
            end
            
            if not (player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then
                return
            end
            
            local currentHRP = player.Character.HumanoidRootPart
            local camCF = workspace.CurrentCamera.CFrame
            local dir = (camCF.LookVector * input.Forward) + (camCF.RightVector * input.Right) + (Vector3.new(0, 1, 0) * input.Up)
            
            if dir.Magnitude > 0 then
                dir = dir.Unit
            end
            
            currentHRP.AssemblyLinearVelocity = dir * flySpeed
        end)
    else
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end
end

-- Force turn off fly (for admin commands)
local function forceFlyOff()
    if flying then
        flying = false
        flyToggle.Text = "Fly: OFF [X]"
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
        sendNotification("✈️ Fly mode disabled by admin!", ERROR_COLOR)
    end
end

-- Button Toggle
flyToggle.MouseButton1Click:Connect(toggleFly)

-- Keyboard F Key Toggle
UserInputService.InputBegan:Connect(function(inputObject, gameProcessed)
    if gameProcessed then return end
    
    -- Press F to toggle fly
    if inputObject.KeyCode == Enum.KeyCode.X then
        toggleFly()
    end
    
    -- Fly Movement Keys
    local keyCode = inputObject.KeyCode
    if keyCode == Enum.KeyCode.W then
        input.Forward = 1
    elseif keyCode == Enum.KeyCode.S then
        input.Forward = -1
    elseif keyCode == Enum.KeyCode.A then
        input.Right = -1
    elseif keyCode == Enum.KeyCode.D then
        input.Right = 1
    elseif keyCode == Enum.KeyCode.Space then
        input.Up = 1
    elseif keyCode == Enum.KeyCode.LeftShift then
        input.Up = -1
    end
end)

UserInputService.InputEnded:Connect(function(inputObject, gameProcessed)
    if gameProcessed then return end
    
    local keyCode = inputObject.KeyCode
    if keyCode == Enum.KeyCode.W or keyCode == Enum.KeyCode.S then
        input.Forward = 0
    elseif keyCode == Enum.KeyCode.A or keyCode == Enum.KeyCode.D then
        input.Right = 0
    elseif keyCode == Enum.KeyCode.Space or keyCode == Enum.KeyCode.LeftShift then
        input.Up = 0
    end
end)

speedBox.FocusLost:Connect(function()
    local val = tonumber(speedBox.Text)
    if val and val > 0 then
        flySpeed = val
    end
end)

flyBtn.MouseButton1Click:Connect(function()
    flyFrame.Visible = not flyFrame.Visible
end)

-------------------------------------------------
-- ESP System
-------------------------------------------------
local espActive = false
local espConnections = {}

local function clearESP()
    espActive = false
    
    -- Disconnect all connections
    for _, conn in pairs(espConnections) do
        if conn then
            conn:Disconnect()
        end
    end
    table.clear(espConnections)

    -- Remove all ESP tags
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character and plr.Character:FindFirstChild("Head") then
            local tag = plr.Character.Head:FindFirstChild("ESPTag")
            if tag then
                tag:Destroy()
            end
        end
    end
end

local function createESP(targetPlayer)
    if targetPlayer == player then return end
    if not targetPlayer.Character then return end
    
    local head = targetPlayer.Character:FindFirstChild("Head")
    if not head then return end

    -- Remove old tag if exists
    local oldTag = head:FindFirstChild("ESPTag")
    if oldTag then
        oldTag:Destroy()
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESPTag"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = head

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = targetPlayer.Name
    label.TextColor3 = ACCENT_COLOR
    label.TextStrokeTransparency = 0.2
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 16
    label.Parent = billboard

    -- Update loop
    local updateConnection = RunService.RenderStepped:Connect(function()
        if not espActive or not billboard.Parent then
            if espConnections[targetPlayer.UserId] then
                espConnections[targetPlayer.UserId]:Disconnect()
                espConnections[targetPlayer.UserId] = nil
            end
            return
        end

        if not (player.Character and targetPlayer.Character) then
            return
        end

        local myHRP = player.Character:FindFirstChild("HumanoidRootPart")
        local theirHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")

        if myHRP and theirHRP and humanoid then
            local dist = math.floor((myHRP.Position - theirHRP.Position).Magnitude)
            local hp = math.floor(humanoid.Health)
            local maxHp = math.floor(humanoid.MaxHealth)
            label.Text = string.format("%s [%d studs] | HP: %d/%d", targetPlayer.Name, dist, hp, maxHp)
        end
    end)

    espConnections[targetPlayer.UserId] = updateConnection
end

espBtn.MouseButton1Click:Connect(function()
    if espActive then
        clearESP()
    else
        espActive = true
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then
                spawn(function()
                    createESP(plr)
                end)
            end
        end
    end
end)

-- Handle new players
Players.PlayerAdded:Connect(function(newPlayer)
    newPlayer.CharacterAdded:Connect(function()
        if espActive then
            task.wait(1)
            createESP(newPlayer)
        end
    end)
end)

-------------------------------------------------
-- Tween to Player Frame
-------------------------------------------------
local tweenFrame = Instance.new("Frame")
tweenFrame.Size = UDim2.new(0, 220, 0, 300)
tweenFrame.Position = UDim2.new(0, 480, 0.2, 0)
tweenFrame.BackgroundColor3 = BG_COLOR
tweenFrame.Visible = false
tweenFrame.Parent = gui
makeDraggable(tweenFrame)

local tweenCorner = Instance.new("UICorner")
tweenCorner.CornerRadius = UDim.new(0, 8)
tweenCorner.Parent = tweenFrame

createExitButton(tweenFrame, tweenFrame)

local tweenScroll = Instance.new("ScrollingFrame")
tweenScroll.Size = UDim2.new(1, -10, 1, -10)
tweenScroll.Position = UDim2.new(0, 5, 0, 5)
tweenScroll.BackgroundTransparency = 1
tweenScroll.ScrollBarThickness = 6
tweenScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
tweenScroll.Parent = tweenFrame

local tweenLayout = Instance.new("UIListLayout")
tweenLayout.Padding = UDim.new(0, 5)
tweenLayout.SortOrder = Enum.SortOrder.LayoutOrder
tweenLayout.Parent = tweenScroll

tweenLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    tweenScroll.CanvasSize = UDim2.new(0, 0, 0, tweenLayout.AbsoluteContentSize.Y + 10)
end)

local function refreshTweenList()
    for _, child in ipairs(tweenScroll:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= player then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -5, 0, 40)
            btn.BackgroundColor3 = BTN_COLOR
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.SourceSansBold
            btn.TextSize = 18
            btn.Text = targetPlayer.Name
            btn.Parent = tweenScroll

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = btn

            btn.MouseButton1Click:Connect(function()
                if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local myHRP = waitForCharacter()
                    local targetHRP = targetPlayer.Character.HumanoidRootPart
                    
                    local distance = (myHRP.Position - targetHRP.Position).Magnitude
                    local travelTime = math.max(distance / 100, 0.2)

                    local tween = TweenService:Create(
                        myHRP,
                        TweenInfo.new(travelTime, Enum.EasingStyle.Linear),
                        {CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)}
                    )
                    tween:Play()
                end
            end)
        end
    end
end

tweenBtn.MouseButton1Click:Connect(function()
    tweenFrame.Visible = not tweenFrame.Visible
    if tweenFrame.Visible then
        refreshTweenList()
    end
end)

Players.PlayerAdded:Connect(function()
    if tweenFrame.Visible then
        refreshTweenList()
    end
end)

Players.PlayerRemoving:Connect(function()
    if tweenFrame.Visible then
        refreshTweenList()
    end
end)

-------------------------------------------------
-- Admin Log Frame
-------------------------------------------------
local logFrame = Instance.new("Frame")
logFrame.Size = UDim2.new(0, 400, 0, 400)
logFrame.Position = UDim2.new(0, 700, 0.2, 0)
logFrame.BackgroundColor3 = BG_COLOR
logFrame.Visible = false
logFrame.Parent = gui
makeDraggable(logFrame)

local logCorner = Instance.new("UICorner")
logCorner.CornerRadius = UDim.new(0, 8)
logCorner.Parent = logFrame

createExitButton(logFrame, logFrame)

local filterBar = Instance.new("Frame")
filterBar.Size = UDim2.new(1, -10, 0, 35)
filterBar.Position = UDim2.new(0, 5, 0, 5)
filterBar.BackgroundTransparency = 1
filterBar.Parent = logFrame

local filterLayout = Instance.new("UIListLayout")
filterLayout.FillDirection = Enum.FillDirection.Horizontal
filterLayout.Padding = UDim.new(0, 5)
filterLayout.Parent = filterBar

local function createFilterBtn(name, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 1, 0)
    btn.BackgroundColor3 = BTN_COLOR
    btn.TextColor3 = color or Color3.new(1, 1, 1)
    btn.Text = name
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = filterBar
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    return btn
end

local infoBtn = createFilterBtn("Info", Color3.fromRGB(200, 200, 200))
local warnBtn = createFilterBtn("Warning", Color3.fromRGB(255, 200, 0))
local errorBtn = createFilterBtn("Error", ERROR_COLOR)
local clearBtn = createFilterBtn("Clear", Color3.fromRGB(255, 255, 255))

local logScroll = Instance.new("ScrollingFrame")
logScroll.Size = UDim2.new(1, -10, 1, -50)
logScroll.Position = UDim2.new(0, 5, 0, 45)
logScroll.BackgroundTransparency = 1
logScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
logScroll.ScrollBarThickness = 6
logScroll.Parent = logFrame

local logListLayout = Instance.new("UIListLayout")
logListLayout.Padding = UDim.new(0, 2)
logListLayout.SortOrder = Enum.SortOrder.LayoutOrder
logListLayout.Parent = logScroll

local allLogs = {}

local function refreshLogs(filterType)
    for _, child in ipairs(logScroll:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    for _, log in ipairs(allLogs) do
        if not filterType or log.Type == filterType then
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -10, 0, 0)
            lbl.AutomaticSize = Enum.AutomaticSize.Y
            lbl.BackgroundTransparency = 1
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextYAlignment = Enum.TextYAlignment.Top
            lbl.TextWrapped = true
            lbl.Font = Enum.Font.Code
            lbl.TextSize = 14
            lbl.Parent = logScroll
            
            if log.Type == Enum.MessageType.MessageError then
                lbl.TextColor3 = ERROR_COLOR
            elseif log.Type == Enum.MessageType.MessageWarning then
                lbl.TextColor3 = Color3.fromRGB(255, 200, 0)
            else
                lbl.TextColor3 = Color3.new(1, 1, 1)
            end
            
            lbl.Text = log.Text
        end
    end

    logScroll.CanvasSize = UDim2.new(0, 0, 0, logListLayout.AbsoluteContentSize.Y + 10)
end

LogService.MessageOut:Connect(function(message, messageType)
    table.insert(allLogs, {Text = message, Type = messageType})
    if #allLogs > 100 then
        table.remove(allLogs, 1)
    end
    refreshLogs()
end)

infoBtn.MouseButton1Click:Connect(function()
    refreshLogs(Enum.MessageType.MessageOutput)
end)

warnBtn.MouseButton1Click:Connect(function()
    refreshLogs(Enum.MessageType.MessageWarning)
end)

errorBtn.MouseButton1Click:Connect(function()
    refreshLogs(Enum.MessageType.MessageError)
end)

clearBtn.MouseButton1Click:Connect(function()
    allLogs = {}
    refreshLogs()
end)

logBtn.MouseButton1Click:Connect(function()
    logFrame.Visible = not logFrame.Visible
end)

-------------------------------------------------
-- Explorer Frame
-------------------------------------------------
local explorerFrame = Instance.new("Frame")
explorerFrame.Size = UDim2.new(0, 400, 0, 400)
explorerFrame.Position = UDim2.new(0, 1100, 0.2, 0)
explorerFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
explorerFrame.Visible = false
explorerFrame.Parent = gui
makeDraggable(explorerFrame)

local explorerCorner = Instance.new("UICorner")
explorerCorner.CornerRadius = UDim.new(0, 8)
explorerCorner.Parent = explorerFrame

createExitButton(explorerFrame, explorerFrame)

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -120, 0, 30)
searchBox.Position = UDim2.new(0, 5, 0, 5)
searchBox.PlaceholderText = "Search..."
searchBox.Text = ""
searchBox.ClearTextOnFocus = false
searchBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.Font = Enum.Font.Code
searchBox.TextSize = 14
searchBox.Parent = explorerFrame

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 6)
searchCorner.Parent = searchBox

local modeLabel = Instance.new("TextButton")
modeLabel.Size = UDim2.new(0, 100, 0, 30)
modeLabel.Position = UDim2.new(1, -105, 0, 5)
modeLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
modeLabel.Text = "Mode: Name"
modeLabel.TextColor3 = Color3.new(1, 1, 1)
modeLabel.Font = Enum.Font.Code
modeLabel.TextSize = 14
modeLabel.Parent = explorerFrame

local modeCorner = Instance.new("UICorner")
modeCorner.CornerRadius = UDim.new(0, 6)
modeCorner.Parent = modeLabel

local searchMode = "Name"
modeLabel.MouseButton1Click:Connect(function()
    if searchMode == "Name" then
        searchMode = "Type"
        modeLabel.Text = "Mode: Type"
    else
        searchMode = "Name"
        modeLabel.Text = "Mode: Name"
    end
end)

local explorerScroll = Instance.new("ScrollingFrame")
explorerScroll.Size = UDim2.new(1, -10, 1, -60)
explorerScroll.Position = UDim2.new(0, 5, 0, 40)
explorerScroll.BackgroundTransparency = 1
explorerScroll.ScrollBarThickness = 6
explorerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
explorerScroll.Parent = explorerFrame

local explorerLayout = Instance.new("UIListLayout")
explorerLayout.Padding = UDim.new(0, 2)
explorerLayout.SortOrder = Enum.SortOrder.LayoutOrder
explorerLayout.Parent = explorerScroll

local removeBtn = Instance.new("TextButton")
removeBtn.Size = UDim2.new(0, 80, 0, 25)
removeBtn.Position = UDim2.new(1, -85, 1, -30)
removeBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
removeBtn.Text = "Remove"
removeBtn.TextColor3 = Color3.new(1, 1, 1)
removeBtn.Font = Enum.Font.SourceSansBold
removeBtn.TextSize = 14
removeBtn.Parent = explorerFrame

local removeCorner = Instance.new("UICorner")
removeCorner.CornerRadius = UDim.new(0, 6)
removeCorner.Parent = removeBtn

-------------------------------------------------
-- Create Node Function
-------------------------------------------------
local selectedInstance = nil
local highlightedLabel = nil

local function createNode(parentUI, instance, depth)
    local container = Instance.new("Frame")
    container.Name = "Node_" .. instance.Name
    container.Size = UDim2.new(1, -5, 0, 20)
    container.BackgroundTransparency = 1
    container.Parent = parentUI

    local plusBtn = Instance.new("TextButton")
    plusBtn.Size = UDim2.new(0, 20, 0, 20)
    plusBtn.Position = UDim2.new(0, depth * 20, 0, 0)
    plusBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    plusBtn.Text = "+"
    plusBtn.TextColor3 = Color3.new(1, 1, 1)
    plusBtn.Font = Enum.Font.Code
    plusBtn.TextSize = 14
    plusBtn.Parent = container

    local label = Instance.new("TextButton")
    label.Size = UDim2.new(1, -30 - depth * 20, 0, 20)
    label.Position = UDim2.new(0, 25 + depth * 20, 0, 0)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Code
    label.TextSize = 14
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Text = instance.Name .. " (" .. instance.ClassName .. ")"
    label.Parent = container

    label.MouseButton1Click:Connect(function()
        if highlightedLabel then
            highlightedLabel.BackgroundTransparency = 1
        end
        selectedInstance = instance
        highlightedLabel = label
        label.BackgroundTransparency = 0.5
        label.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
    end)

    local expanded = false
    local childrenFrames = {}

    plusBtn.MouseButton1Click:Connect(function()
        if expanded then
            for _, frame in ipairs(childrenFrames) do
                frame:Destroy()
            end
            childrenFrames = {}
            plusBtn.Text = "+"
            expanded = false
        else
            for _, child in ipairs(instance:GetChildren()) do
                table.insert(childrenFrames, createNode(parentUI, child, depth + 1))
            end
            plusBtn.Text = "-"
            expanded = true
        end
        explorerScroll.CanvasSize = UDim2.new(0, 0, 0, explorerLayout.AbsoluteContentSize.Y + 10)
    end)

    return container
end

-------------------------------------------------
-- Refresh Tree Function
-------------------------------------------------
local function refreshExplorerTree()
    for _, child in ipairs(explorerScroll:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local roots = {
        workspace,
        game.Players,
        game.ReplicatedStorage,
        game:GetService("CoreGui")
    }

    for _, root in ipairs(roots) do
        createNode(explorerScroll, root, 0)
    end

    explorerScroll.CanvasSize = UDim2.new(0, 0, 0, explorerLayout.AbsoluteContentSize.Y + 10)
end

explorerBtn.MouseButton1Click:Connect(function()
    explorerFrame.Visible = not explorerFrame.Visible
    if explorerFrame.Visible then
        refreshExplorerTree()
    end
end)

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local searchText = searchBox.Text:lower()
    for _, child in ipairs(explorerScroll:GetChildren()) do
        if child:IsA("Frame") then
            local label = child:FindFirstChildOfClass("TextButton")
            if label then
                local checkText = (searchMode == "Name")
                    and label.Text:lower()
                    or label.Text:match("%((.-)%)"):lower()
                child.Visible = (searchText == "" or checkText:find(searchText, 1, true) ~= nil)
            end
        end
    end
end)

removeBtn.MouseButton1Click:Connect(function()
    if selectedInstance then
        selectedInstance:Destroy()
        refreshExplorerTree()
        selectedInstance = nil
        highlightedLabel = nil
    end
end)

-------------------------------------------------
-- AFK Sky Float Toggle
-------------------------------------------------
local isAfk = false
local afkCoroutine

afkBtn.MouseButton1Click:Connect(function()
    local hrp = waitForCharacter()
    if not hrp then return end

    if not isAfk then
        isAfk = true

        local startPos = hrp.Position + Vector3.new(0, 5000, 0)
        hrp.CFrame = CFrame.new(startPos)

        local radius = 100
        local height = 5000
        local speed = 20

        local points = {
            Vector3.new(radius, height, 0),
            Vector3.new(0, height, radius),
            Vector3.new(-radius, height, 0),
            Vector3.new(0, height, -radius),
        }

        afkCoroutine = coroutine.create(function()
            local i = 1
            while isAfk and hrp.Parent do
                local targetPos = startPos + points[i]
                local targetCFrame = CFrame.new(targetPos)

                local distance = (hrp.Position - targetPos).Magnitude
                local travelTime = distance / speed

                local tween = TweenService:Create(
                    hrp,
                    TweenInfo.new(travelTime, Enum.EasingStyle.Linear),
                    {CFrame = targetCFrame}
                )
                tween:Play()
                tween.Completed:Wait()

                i = i + 1
                if i > #points then
                    i = 1
                end
            end
        end)
        coroutine.resume(afkCoroutine)

    else
        isAfk = false
        local groundY = workspace.FallenPartsDestroyHeight + 5
        hrp.CFrame = CFrame.new(hrp.Position.X, groundY, hrp.Position.Z)
    end
end)

-------------------------------------------------
-- ANTI-AFK SYSTEM
-------------------------------------------------
local antiAfkActive = CONFIG.EnableAntiAFK
local antiAfkConnection = nil

local function startAntiAFK()
    if antiAfkConnection then
        antiAfkConnection:Disconnect()
        antiAfkConnection = nil
    end
    
    antiAfkConnection = RunService.Stepped:Connect(function()
        if not antiAfkActive then return end
        
        -- Simulate user activity to prevent AFK kick
        -- Bounce the camera slightly
        local camera = workspace.CurrentCamera
        if camera then
            local cf = camera.CFrame
            local offset = Vector3.new(
                math.sin(tick() * 0.1) * 0.001,
                math.cos(tick() * 0.13) * 0.001,
                0
            )
            camera.CFrame = cf + offset
        end
        
        -- Click on a random part of the screen to simulate activity
        -- Using VirtualUser for more reliable anti-AFK
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end)
    
    -- Also use the Built-in anti-AFK method
    local bh = Instance.new("BindableFunction")
    bh.Name = "AntiAFK"
    bh.Parent = gui
    bh.OnInvoke = function()
        if antiAfkActive then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end)
        end
        return true
    end
    
    -- Spam the function every few seconds
    task.spawn(function()
        while antiAfkActive do
            task.wait(CONFIG.AntiAFKInterval)
            pcall(function()
                bh:Invoke()
            end)
        end
    end)
end

-- Toggle Anti-AFK
local function toggleAntiAFK()
    antiAfkActive = not antiAfkActive
    antiAfkBtn.Text = antiAfkActive and "Anti-AFK: ON" or "Anti-AFK: OFF"
    if antiAfkActive then
        startAntiAFK()
        sendNotification("🛡️ Anti-AFK Enabled!", SUCCESS_COLOR)
    else
        if antiAfkConnection then
            antiAfkConnection:Disconnect()
            antiAfkConnection = nil
        end
        sendNotification("🛡️ Anti-AFK Disabled!", ERROR_COLOR)
    end
end

antiAfkBtn.MouseButton1Click:Connect(toggleAntiAFK)

-- Start anti-AFK by default
if CONFIG.EnableAntiAFK then
    task.wait(2)
    startAntiAFK()
end

-------------------------------------------------
-- ADMIN COMMAND SYSTEM
-------------------------------------------------

-- Function to check if a username is an admin
local function isAdmin(username)
    for _, adminName in ipairs(CONFIG.AdminUsernames) do
        if adminName == username then
            return true
        end
    end
    return false
end

-- Function to teleport to admin (with animation)
local function teleportToAdmin(adminName, isAuto)
    local adminPlayer = nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name == adminName then
            adminPlayer = plr
            break
        end
    end
    
    if not adminPlayer then
        if not isAuto then
            sendNotification("❌ Admin " .. adminName .. " not found in server!", ERROR_COLOR)
        end
        return false
    end
    
    if not adminPlayer.Character or not adminPlayer.Character:FindFirstChild("HumanoidRootPart") then
        if not isAuto then
            sendNotification("❌ Admin " .. adminName .. " is not in game!", ERROR_COLOR)
        end
        return false
    end
    
    local myHRP = waitForCharacter()
    local adminHRP = adminPlayer.Character.HumanoidRootPart
    
    -- Smooth teleport using Tween
    local distance = (myHRP.Position - adminHRP.Position).Magnitude
    local travelTime = math.min(math.max(distance / 200, 0.2), 2) -- Max 2 seconds
    
    local tween = TweenService:Create(
        myHRP,
        TweenInfo.new(travelTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {CFrame = adminHRP.CFrame + Vector3.new(0, 3, 0)}
    )
    tween:Play()
    
    local msg = isAuto and "🚀 Auto-teleported to admin: " or "✅ Teleported to admin: "
    sendNotification(msg .. adminName, SUCCESS_COLOR)
    
    -- If flying, disable it to prevent weirdness
    if flying then
        forceFlyOff()
    end
    
    return true
end

-- Function to check if message contains auto-teleport phrases
local function checkAutoTeleport(message, sender)
    if not CONFIG.EnableAutoTeleport then return false end
    if not isAdmin(sender) then return false end
    
    local messageLower = message:lower()
    for _, phrase in ipairs(CONFIG.AutoTeleportPhrases) do
        if messageLower:find(phrase, 1, true) then
            -- Don't auto-teleport if it's a command (starts with prefix)
            if not string.sub(message, 1, 1) == CONFIG.CommandPrefix then
                teleportToAdmin(sender, true)
                return true
            end
        end
    end
    return false
end

-- Admin command processing
local function processAdminCommand(message, sender)
    if not CONFIG.EnableAdminCommands then return end
    if not isAdmin(sender) then return end
    
    -- Check auto-teleport first (if enabled)
    if CONFIG.EnableAutoTeleport then
        if checkAutoTeleport(message, sender) then
            return
        end
    end
    
    -- Check if message starts with command prefix
    if not string.sub(message, 1, 1) == CONFIG.CommandPrefix then
        return
    end
    
    -- Remove prefix and trim
    local command = string.sub(message, 2)
    command = command:gsub("^%s+", ""):gsub("%s+$", "")
    
    -- Convert to lowercase for matching
    local commandLower = command:lower()
    
    -- Command: turn off fly
    if commandLower == "turn off fly" or commandLower == "disable fly" or commandLower == "fly off" or commandLower == "off fly" then
        forceFlyOff()
        sendNotification("👮 Admin " .. sender .. " disabled your fly!", ERROR_COLOR)
        return
    end
    
    -- Command: teleport to me (manual command)
    if commandLower == "teleport to me" or commandLower == "tp to me" or commandLower == "come to me" or commandLower == "come here" then
        teleportToAdmin(sender, false)
        return
    end
    
    -- Command: help
    if commandLower == "help" or commandLower == "?" then
        local helpMsg = [[
📋 Available Admin Commands:
/turn off fly - Disable fly mode
/teleport to me - Teleport to admin
/help - Show this message

💡 Auto-teleport triggers:
"come to me", "come here", "tp to me"
]]
        sendNotification(helpMsg, ADMIN_COLOR)
        return
    end
end

-- Function to check chat messages for admin commands
local function setupAdminCommandListener()
    local ChatService = game:GetService("Chat")
    
    if ChatService and ChatService:FindFirstChild("OnChatMessage") then
        ChatService.OnChatMessage:Connect(function(message, sender)
            processAdminCommand(message, sender)
        end)
    end
    
    local chatRemotes = {
        "Chat",
        "SendMessage",
        "ChatMessage",
        "SendChat",
        "PlayerChat",
        "SayMessage",
    }
    
    for _, remoteName in ipairs(chatRemotes) do
        local remote = ReplicatedStorage:FindFirstChild(remoteName)
        if remote and remote:IsA("RemoteEvent") then
            remote.OnClientEvent:Connect(function(sender, message, ...)
                if type(sender) == "string" and type(message) == "string" then
                    processAdminCommand(message, sender)
                end
            end)
        end
    end
    
    local locations = {
        ReplicatedStorage,
        game:GetService("ReplicatedFirst"),
    }
    
    for _, location in ipairs(locations) do
        for _, child in ipairs(location:GetChildren()) do
            if child:IsA("RemoteEvent") and child.Name:lower():find("chat") then
                child.OnClientEvent:Connect(function(sender, message, ...)
                    if type(sender) == "string" and type(message) == "string" then
                        processAdminCommand(message, sender)
                    end
                end)
            end
        end
    end
end

-- Start admin command listener if enabled
if CONFIG.EnableAdminCommands then
    task.delay(1, setupAdminCommandListener)
end

-- Admin Status Button
local adminStatusFrame = nil

adminStatusBtn.MouseButton1Click:Connect(function()
    if adminStatusFrame and adminStatusFrame.Parent then
        adminStatusFrame:Destroy()
        adminStatusFrame = nil
        return
    end
    
    adminStatusFrame = Instance.new("Frame")
    adminStatusFrame.Size = UDim2.new(0, 250, 0, 200)
    adminStatusFrame.Position = UDim2.new(0, 1320, 0.2, 0)
    adminStatusFrame.BackgroundColor3 = BG_COLOR
    adminStatusFrame.Parent = gui
    makeDraggable(adminStatusFrame)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = adminStatusFrame
    
    createExitButton(adminStatusFrame, adminStatusFrame)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = BTN_COLOR
    title.Text = "👮 Admin Status"
    title.TextColor3 = ADMIN_COLOR
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 18
    title.Parent = adminStatusFrame
    
    local titleCorner2 = Instance.new("UICorner")
    titleCorner2.CornerRadius = UDim.new(0, 8)
    titleCorner2.Parent = title
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -45)
    scroll.Position = UDim2.new(0, 5, 0, 40)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 6
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.Parent = adminStatusFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = scroll
    
    local hasAdmins = false
    for _, plr in ipairs(Players:GetPlayers()) do
        if isAdmin(plr.Name) then
            hasAdmins = true
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 30)
            label.BackgroundTransparency = 1
            label.Text = plr.Name
            label.TextColor3 = ADMIN_COLOR
            label.Font = Enum.Font.SourceSansBold
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = scroll
            
            local status = Instance.new("TextLabel")
            status.Size = UDim2.new(0, 60, 1, 0)
            status.Position = UDim2.new(1, -65, 0, 0)
            status.BackgroundTransparency = 1
            status.Text = "🟢 Online"
            status.TextColor3 = SUCCESS_COLOR
            status.Font = Enum.Font.SourceSans
            status.TextSize = 14
            status.TextXAlignment = Enum.TextXAlignment.Right
            status.Parent = label
        end
    end
    
    if not hasAdmins then
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 30)
        label.BackgroundTransparency = 1
        label.Text = "No admins online"
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.Font = Enum.Font.SourceSans
        label.TextSize = 16
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.Parent = scroll
    end
    
    task.wait(0.1)
    scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end)

-------------------------------------------------
-- Print startup message
-------------------------------------------------
print("Lilcat Cheat Utility loaded successfully!")
print("Press F to toggle Fly")
print("Admin commands enabled for: " .. table.concat(CONFIG.AdminUsernames, ", "))
print("Auto-teleport enabled! Admins saying 'come to me' will teleport you.")
print("Anti-AFK is " .. (CONFIG.EnableAntiAFK and "ENABLED" or "DISABLED"))
