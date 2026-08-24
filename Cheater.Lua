-- ============================================================
-- LILCAT ULTIMATE UTILITY - COMPLETE FIXED VERSION
-- Place in StarterPlayerScripts
-- ============================================================

-- ============================================================
-- CONFIGURATION
-- ============================================================
local CONFIG = {
    AdminUsernames = {"PhoMaoC0D3v6"},
    EnableAdminCommands = true,
    EnableAutoTeleport = true,
    EnableAntiAFK = true,
    AntiAFKInterval = 45,
    DefaultFlySpeed = 50,
    HighlightDistance = 600,
    EnemyColor = Color3.fromRGB(255, 60, 60),
    TeammateColor = Color3.fromRGB(0, 170, 255),
    AllyColor = Color3.fromRGB(0, 255, 0),
    LockMaxDistance = 700,
    LockViewAngle = 35,
    Keybinds = {
        ToggleFly = "F",
        ToggleESP = "E",
        ToggleMenu = "RightShift",
        TeleportToAdmin = "T",
        ToggleAFK = "B",
        ToggleAntiAFK = "N",
        ToggleLock = "L",
        ToggleHighlight = "H",
        ToggleFling = "G",
    },
}

-- ============================================================
-- SERVICES
-- ============================================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ============================================================
-- COLORS
-- ============================================================
local colors = {
    bg = Color3.fromRGB(15, 15, 20),
    bg2 = Color3.fromRGB(25, 25, 32),
    bg3 = Color3.fromRGB(35, 35, 45),
    bg4 = Color3.fromRGB(45, 45, 55),
    accent = Color3.fromRGB(100, 180, 255),
    accent2 = Color3.fromRGB(80, 220, 160),
    error = Color3.fromRGB(255, 70, 70),
    success = Color3.fromRGB(70, 255, 140),
    warn = Color3.fromRGB(255, 200, 50),
    text = Color3.fromRGB(230, 230, 240),
    textDim = Color3.fromRGB(160, 160, 180),
    admin = Color3.fromRGB(255, 200, 50),
}

-- ============================================================
-- GUI SETUP
-- ============================================================
local oldgui = CoreGui:FindFirstChild("LilcatUtility")
if oldgui then oldgui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "LilcatUtility"
gui.Parent = CoreGui
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================
local function waitForCharacter()
    if not player.Character then player.CharacterAdded:Wait() end
    return player.Character:WaitForChild("HumanoidRootPart")
end

local function getKeyCode(keyName)
    local map = {
        F = Enum.KeyCode.F, E = Enum.KeyCode.E, T = Enum.KeyCode.T,
        G = Enum.KeyCode.G, H = Enum.KeyCode.H, L = Enum.KeyCode.L,
        B = Enum.KeyCode.B, N = Enum.KeyCode.N, P = Enum.KeyCode.P,
        RightShift = Enum.KeyCode.RightShift, LeftShift = Enum.KeyCode.LeftShift,
        Space = Enum.KeyCode.Space,
    }
    return map[keyName] or Enum.KeyCode[keyName] or Enum.KeyCode.F
end

local function isAdmin(name)
    for _, a in ipairs(CONFIG.AdminUsernames) do
        if a == name then return true end
    end
    return false
end

-- ============================================================
-- NOTIFICATION SYSTEM
-- ============================================================
local notificationQueue = {}
local notificationActive = false

local function sendNotification(text, color, duration)
    color = color or colors.accent
    duration = duration or 4
    
    table.insert(notificationQueue, {text = text, color = color, duration = duration})
    
    if not notificationActive then
        notificationActive = true
        task.spawn(function()
            while #notificationQueue > 0 do
                local notif = table.remove(notificationQueue, 1)
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(0, 420, 0, 45)
                frame.Position = UDim2.new(0.5, -210, 0, 60)
                frame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
                frame.BackgroundTransparency = 0.1
                frame.BorderSizePixel = 0
                frame.Parent = gui
                
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 10)
                corner.Parent = frame
                
                local stroke = Instance.new("UIStroke")
                stroke.Color = notif.color
                stroke.Thickness = 2
                stroke.Transparency = 0.4
                stroke.Parent = frame
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, -20, 1, 0)
                label.Position = UDim2.new(0, 10, 0, 0)
                label.BackgroundTransparency = 1
                label.Text = notif.text
                label.TextColor3 = colors.text
                label.Font = Enum.Font.GothamSemibold
                label.TextSize = 16
                label.TextWrapped = true
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = frame
                
                frame.Position = UDim2.new(0.5, -210, 0, -60)
                local tweenIn = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0.5, -210, 0, 60)
                })
                tweenIn:Play()
                tweenIn.Completed:Wait()
                
                task.wait(notif.duration)
                
                local tweenOut = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Position = UDim2.new(0.5, -210, 0, -60)
                })
                tweenOut:Play()
                tweenOut.Completed:Wait()
                frame:Destroy()
            end
            notificationActive = false
        end)
    end
end

-- ============================================================
-- FEATURES STATE
-- ============================================================
local features = {
    fly = false,
    esp = false,
    antiAfk = CONFIG.EnableAntiAFK,
    afkPlatform = false,
    lock = false,
    highlight = false,
    fling = false,
}

local flySpeed = CONFIG.DefaultFlySpeed
local flyInput = {Forward = 0, Right = 0, Up = 0}
local flyConnection = nil
local flyVelocity = Vector3.new()

-- ============================================================
-- MAIN MENU
-- ============================================================
local menuVisible = true
local menu = Instance.new("Frame")
menu.Size = UDim2.new(0, 340, 0, 480)
menu.Position = UDim2.new(0, 25, 0.08, 0)
menu.BackgroundColor3 = colors.bg
menu.BackgroundTransparency = 0.05
menu.BorderSizePixel = 0
menu.ClipsDescendants = true
menu.Parent = gui
menu.Active = true
menu.Draggable = true

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 14)
menuCorner.Parent = menu

local glowStroke = Instance.new("UIStroke")
glowStroke.Color = colors.accent
glowStroke.Thickness = 1.5
glowStroke.Transparency = 0.6
glowStroke.Parent = menu

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = colors.bg2
titleBar.BackgroundTransparency = 0.4
titleBar.BorderSizePixel = 0
titleBar.Parent = menu

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 14)
titleCorner.Parent = titleBar

local titleIcon = Instance.new("TextLabel")
titleIcon.Size = UDim2.new(0, 35, 1, 0)
titleIcon.Position = UDim2.new(0, 12, 0, 0)
titleIcon.BackgroundTransparency = 1
titleIcon.Text = "⚡"
titleIcon.TextColor3 = colors.accent
titleIcon.Font = Enum.Font.GothamBold
titleIcon.TextSize = 24
titleIcon.TextXAlignment = Enum.TextXAlignment.Center
titleIcon.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -80, 1, 0)
titleLabel.Position = UDim2.new(0, 52, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "LILCAT UTILITY"
titleLabel.TextColor3 = colors.text
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 34, 0, 34)
closeBtn.Position = UDim2.new(1, -40, 0, 8)
closeBtn.BackgroundColor3 = colors.bg3
closeBtn.BackgroundTransparency = 0.6
closeBtn.Text = "✕"
closeBtn.TextColor3 = colors.error
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    menu.Visible = menuVisible
end)

-- Tab Bar
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 38)
tabBar.Position = UDim2.new(0, 0, 0, 50)
tabBar.BackgroundColor3 = colors.bg2
tabBar.BackgroundTransparency = 0.3
tabBar.BorderSizePixel = 0
tabBar.Parent = menu

local currentTab = "Main"
local menuTabs = {"Main", "Combat", "Movement", "Visuals", "Admin"}
local tabButtons = {}

local function createTabButton(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 62, 0, 30)
    btn.Position = UDim2.new(0, 4 + (#tabButtons * 66), 0, 4)
    btn.BackgroundColor3 = colors.bg3
    btn.BackgroundTransparency = 0.7
    btn.Text = name
    btn.TextColor3 = colors.textDim
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.Parent = tabBar
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        currentTab = name
        for _, tb in pairs(tabButtons) do
            tb.BackgroundTransparency = 0.7
            tb.TextColor3 = colors.textDim
        end
        btn.BackgroundTransparency = 0.2
        btn.TextColor3 = colors.text
        updateTabContent()
    end)
    
    tabButtons[name] = btn
    return btn
end

for _, tabName in ipairs(menuTabs) do
    createTabButton(tabName)
end

-- Select first tab
task.wait(0.1)
if tabButtons["Main"] then
    tabButtons["Main"].BackgroundTransparency = 0.2
    tabButtons["Main"].TextColor3 = colors.text
end

-- Tab Content
local tabContent = Instance.new("Frame")
tabContent.Size = UDim2.new(1, -20, 1, -95)
tabContent.Position = UDim2.new(0, 10, 0, 93)
tabContent.BackgroundTransparency = 1
tabContent.ClipsDescendants = true
tabContent.Parent = menu

local contentScroll = Instance.new("ScrollingFrame")
contentScroll.Size = UDim2.new(1, 0, 1, 0)
contentScroll.BackgroundTransparency = 1
contentScroll.ScrollBarThickness = 4
contentScroll.ScrollBarImageColor3 = colors.accent
contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
contentScroll.Parent = tabContent

local scrollLayout = Instance.new("UIListLayout")
scrollLayout.Padding = UDim.new(0, 6)
scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
scrollLayout.Parent = contentScroll

scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    contentScroll.CanvasSize = UDim2.new(0, 0, 0, scrollLayout.AbsoluteContentSize.Y + 10)
end)

-- ============================================================
-- UI COMPONENTS
-- ============================================================

-- Regular Button (works)
local function createButton(text, parent, callback, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = colors.bg2
    btn.BackgroundTransparency = 0.3
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = (icon or "") .. " " .. text
    label.TextColor3 = colors.text
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    return btn
end

-- Toggle Button (works with state)
local function createToggle(text, parent, callback, icon, initialState)
    local state = initialState or false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 38)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, -5, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = (icon or "") .. " " .. text
    label.TextColor3 = colors.text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 50, 0, 28)
    toggleBg.Position = UDim2.new(1, -54, 0.5, -14)
    toggleBg.BackgroundColor3 = colors.bg3
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBg
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 22, 0, 22)
    indicator.Position = UDim2.new(0, 3, 0.5, -11)
    indicator.BackgroundColor3 = colors.textDim
    indicator.BorderSizePixel = 0
    indicator.Parent = toggleBg
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(1, 0)
    indicatorCorner.Parent = indicator
    
    local function updateToggle()
        if state then
            toggleBg.BackgroundColor3 = colors.accent
            indicator.Position = UDim2.new(1, -25, 0.5, -11)
            indicator.BackgroundColor3 = colors.text
        else
            toggleBg.BackgroundColor3 = colors.bg3
            indicator.Position = UDim2.new(0, 3, 0.5, -11)
            indicator.BackgroundColor3 = colors.textDim
        end
    end
    
    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.Parent = toggleBg
    
    clickBtn.MouseButton1Click:Connect(function()
        state = not state
        updateToggle()
        if callback then callback(state) end
    end)
    
    updateToggle()
    return frame
end

-- ============================================================
-- UPDATE TAB CONTENT
-- ============================================================
local function updateTabContent()
    -- Clear content
    for _, child in ipairs(contentScroll:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    if currentTab == "Main" then
        -- Status Dashboard
        local statusFrame = Instance.new("Frame")
        statusFrame.Size = UDim2.new(1, 0, 0, 90)
        statusFrame.BackgroundColor3 = colors.bg2
        statusFrame.BackgroundTransparency = 0.3
        statusFrame.Parent = contentScroll
        
        local statusCorner = Instance.new("UICorner")
        statusCorner.CornerRadius = UDim.new(0, 8)
        statusCorner.Parent = statusFrame
        
        local statuses = {
            {"⚡ Fly", features.fly},
            {"👁️ ESP", features.esp},
            {"🛡️ Anti-AFK", features.antiAfk},
            {"🎯 Lock", features.lock},
            {"💥 Fling", features.fling},
            {"🟩 Highlight", features.highlight},
        }
        
        for i, data in ipairs(statuses) do
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0.5, -5, 0.5, -5)
            lbl.Position = UDim2.new((i-1)%2 * 0.5 + 0.02, 0, math.floor((i-1)/2) * 0.33 + 0.02, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = data[1] .. ": " .. (data[2] and "✅ ON" or "❌ OFF")
            lbl.TextColor3 = data[2] and colors.success or colors.error
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 13
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = statusFrame
        end
        
        createButton("📋 Help & Info", contentScroll, function()
            sendNotification("📋 F=Fly | E=ESP | L=Lock | H=Highlight | G=Fling", colors.accent, 5)
        end, "📋")
        
    elseif currentTab == "Combat" then
        createToggle("🎯 Lock Target", contentScroll, function(state)
            features.lock = state
            sendNotification("🎯 Lock " .. (state and "Enabled" or "Disabled"), state and colors.success or colors.error)
            if not state and lockHighlight then unlockTarget() end
        end, "🎯", features.lock)
        
        createToggle("💥 Fling Mode", contentScroll, function(state)
            features.fling = state
            if state then startFling() else stopFling() end
            sendNotification("💥 Fling " .. (state and "Started" or "Stopped"), state and colors.success or colors.error)
        end, "💥", features.fling)
        
        createToggle("👁️ ESP Players", contentScroll, function(state)
            features.esp = state
            if state then refreshESP() else clearESP() end
            sendNotification("👁️ ESP " .. (state and "Enabled" or "Disabled"), state and colors.success or colors.error)
        end, "👁️", features.esp)
        
        createToggle("🟩 Highlight", contentScroll, function(state)
            features.highlight = state
            highlightActive = state
            sendNotification("🟩 Highlight " .. (state and "Enabled" or "Disabled"), state and colors.success or colors.error)
        end, "🟩", features.highlight)
        
    elseif currentTab == "Movement" then
        createToggle("✈️ Fly Mode", contentScroll, function(state)
            toggleFly(state)
        end, "✈️", features.fly)
        
        createToggle("💤 AFK Platform", contentScroll, function(state)
            toggleAFKPlatform(state)
        end, "💤", features.afkPlatform)
        
        createToggle("🛡️ Anti-AFK", contentScroll, function(state)
            toggleAntiAFK(state)
        end, "🛡️", features.antiAfk)
        
        -- Speed Control with TextBox
        local speedFrame = Instance.new("Frame")
        speedFrame.Size = UDim2.new(1, 0, 0, 80)
        speedFrame.BackgroundTransparency = 1
        speedFrame.Parent = contentScroll
        
        local speedLabel = Instance.new("TextLabel")
        speedLabel.Size = UDim2.new(1, 0, 0, 25)
        speedLabel.BackgroundTransparency = 1
        speedLabel.Text = "✈️ Fly Speed: " .. flySpeed
        speedLabel.TextColor3 = colors.text
        speedLabel.Font = Enum.Font.Gotham
        speedLabel.TextSize = 14
        speedLabel.TextXAlignment = Enum.TextXAlignment.Left
        speedLabel.Parent = speedFrame
        
        local speedInput = Instance.new("TextBox")
        speedInput.Size = UDim2.new(0.55, 0, 0, 32)
        speedInput.Position = UDim2.new(0, 0, 0, 28)
        speedInput.BackgroundColor3 = colors.bg3
        speedInput.BackgroundTransparency = 0.3
        speedInput.Text = tostring(flySpeed)
        speedInput.TextColor3 = colors.text
        speedInput.Font = Enum.Font.Gotham
        speedInput.TextSize = 16
        speedInput.ClearTextOnFocus = false
        speedInput.Parent = speedFrame
        
        local speedCorner = Instance.new("UICorner")
        speedCorner.CornerRadius = UDim.new(0, 6)
        speedCorner.Parent = speedInput
        
        local applyBtn = Instance.new("TextButton")
        applyBtn.Size = UDim2.new(0.35, -5, 0, 32)
        applyBtn.Position = UDim2.new(0.65, 0, 0, 28)
        applyBtn.BackgroundColor3 = colors.accent
        applyBtn.BackgroundTransparency = 0.4
        applyBtn.Text = "Apply Speed"
        applyBtn.TextColor3 = colors.text
        applyBtn.Font = Enum.Font.GothamSemibold
        applyBtn.TextSize = 13
        applyBtn.BorderSizePixel = 0
        applyBtn.Parent = speedFrame
        
        local applyCorner = Instance.new("UICorner")
        applyCorner.CornerRadius = UDim.new(0, 6)
        applyCorner.Parent = applyBtn
        
        applyBtn.MouseButton1Click:Connect(function()
            local val = tonumber(speedInput.Text)
            if val and val > 0 then
                flySpeed = val
                speedLabel.Text = "✈️ Fly Speed: " .. flySpeed
                sendNotification("✈️ Speed set to: " .. flySpeed, colors.accent2)
            else
                sendNotification("❌ Enter a valid number!", colors.error)
                speedInput.Text = tostring(flySpeed)
            end
        end)
        
        -- Speed presets
        local presetRow = Instance.new("Frame")
        presetRow.Size = UDim2.new(1, 0, 0, 28)
        presetRow.BackgroundTransparency = 1
        presetRow.Parent = contentScroll
        
        local presetLayout = Instance.new("UIListLayout")
        presetLayout.FillDirection = Enum.FillDirection.Horizontal
        presetLayout.Padding = UDim.new(0, 4)
        presetLayout.Parent = presetRow
        
        for _, val in ipairs({"10", "50", "100", "500", "1000", "9999"}) do
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(0.15, 0, 1, 0)
            pBtn.BackgroundColor3 = colors.bg3
            pBtn.BackgroundTransparency = 0.4
            pBtn.Text = val
            pBtn.TextColor3 = colors.text
            pBtn.Font = Enum.Font.Gotham
            pBtn.TextSize = 11
            pBtn.BorderSizePixel = 0
            pBtn.Parent = presetRow
            
            local pCorner = Instance.new("UICorner")
            pCorner.CornerRadius = UDim.new(0, 4)
            pCorner.Parent = pBtn
            
            pBtn.MouseButton1Click:Connect(function()
                flySpeed = tonumber(val)
                speedLabel.Text = "✈️ Fly Speed: " .. flySpeed
                speedInput.Text = tostring(flySpeed)
                sendNotification("✈️ Speed set to: " .. flySpeed, colors.accent2)
            end)
        end
        
    elseif currentTab == "Visuals" then
        createToggle("👁️ ESP Players", contentScroll, function(state)
            features.esp = state
            if state then refreshESP() else clearESP() end
            sendNotification("👁️ ESP " .. (state and "Enabled" or "Disabled"), state and colors.success or colors.error)
        end, "👁️", features.esp)
        
        createToggle("🟩 Highlight", contentScroll, function(state)
            features.highlight = state
            highlightActive = state
            sendNotification("🟩 Highlight " .. (state and "Enabled" or "Disabled"), state and colors.success or colors.error)
        end, "🟩", features.highlight)
        
        createToggle("🎯 Lock Target", contentScroll, function(state)
            features.lock = state
            sendNotification("🎯 Lock " .. (state and "Enabled" or "Disabled"), state and colors.success or colors.error)
            if not state and lockHighlight then unlockTarget() end
        end, "🎯", features.lock)
        
    elseif currentTab == "Admin" then
        createButton("👮 Check Admins", contentScroll, function()
            local admins = {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if isAdmin(plr.Name) then table.insert(admins, plr.Name) end
            end
            if #admins > 0 then
                sendNotification("👮 Admins online: " .. table.concat(admins, ", "), colors.admin)
            else
                sendNotification("👮 No admins online", colors.textDim)
            end
        end, "👮")
        
        createToggle("📨 Admin Commands", contentScroll, function(state)
            CONFIG.EnableAdminCommands = state
            sendNotification("Admin commands " .. (state and "enabled" or "disabled"), state and colors.success or colors.error)
        end, "📨", CONFIG.EnableAdminCommands)
        
        createToggle("🚀 Auto Teleport", contentScroll, function(state)
            CONFIG.EnableAutoTeleport = state
            sendNotification("Auto-teleport " .. (state and "enabled" or "disabled"), state and colors.success or colors.error)
        end, "🚀", CONFIG.EnableAutoTeleport)
    end
end

-- ============================================================
-- FLY SYSTEM
-- ============================================================
local function toggleFly(state)
    features.fly = state
    if state then
        sendNotification("✈️ Fly ON - Speed: " .. flySpeed, colors.accent2)
        local hrp = waitForCharacter()
        if flyConnection then flyConnection:Disconnect() end
        
        flyConnection = RunService.Heartbeat:Connect(function()
            if not features.fly then
                if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
                return
            end
            local char = player.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local camCF = workspace.CurrentCamera.CFrame
            local dir = (camCF.LookVector * flyInput.Forward) + 
                       (camCF.RightVector * flyInput.Right) + 
                       (Vector3.new(0, 1, 0) * flyInput.Up)
            
            if dir.Magnitude > 0 then
                dir = dir.Unit
                local targetVel = dir * flySpeed
                flyVelocity = flyVelocity:Lerp(targetVel, 0.4)
                hrp.AssemblyLinearVelocity = flyVelocity
            else
                flyVelocity = flyVelocity:Lerp(Vector3.new(), 0.15)
                hrp.AssemblyLinearVelocity = flyVelocity
            end
        end)
    else
        sendNotification("✈️ Fly OFF", colors.error)
        if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
        flyVelocity = Vector3.new()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new()
        end
    end
    updateTabContent()
end

-- ============================================================
-- ESP SYSTEM
-- ============================================================
local espActive = false
local espTags = {}

local function clearESP()
    espActive = false
    for _, tag in pairs(espTags) do
        if tag and tag.Parent then tag:Destroy() end
    end
    espTags = {}
end

local function createESPTag(targetPlayer)
    if targetPlayer == player then return end
    if espTags[targetPlayer.UserId] then
        espTags[targetPlayer.UserId]:Destroy()
        espTags[targetPlayer.UserId] = nil
    end
    
    local char = targetPlayer.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESPTag"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 180, 0, 35)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.MaxDistance = 300
    billboard.Parent = head
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.4
    bg.BorderSizePixel = 0
    bg.Parent = billboard
    
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 6)
    bgCorner.Parent = bg
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = targetPlayer.Name
    label.TextColor3 = colors.accent
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextStrokeTransparency = 0.3
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13
    label.TextScaled = true
    label.Parent = bg
    
    espTags[targetPlayer.UserId] = billboard
end

local function refreshESP()
    clearESP()
    if not features.esp then return end
    espActive = true
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            task.spawn(function() createESPTag(plr) end)
        end
    end
end

-- ============================================================
-- HIGHLIGHT SYSTEM
-- ============================================================
local highlights = {}
local highlightActive = false

local function clearHighlights()
    highlightActive = false
    for model, hl in pairs(highlights) do
        if hl and hl.Parent then hl:Destroy() end
    end
    highlights = {}
end

local function updateHighlights()
    if not highlightActive then return end
    
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local myTeam = player.Team
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local pchar = plr.Character
            local root = pchar and pchar:FindFirstChild("HumanoidRootPart")
            if root then
                local dist = (root.Position - hrp.Position).Magnitude
                if dist <= CONFIG.HighlightDistance then
                    local color = CONFIG.EnemyColor
                    if plr.Team == myTeam then
                        color = CONFIG.TeammateColor
                    end
                    
                    local hl = highlights[pchar]
                    if not hl or not hl.Parent then
                        hl = Instance.new("Highlight")
                        hl.FillTransparency = 0.5
                        hl.OutlineTransparency = 0
                        hl.Adornee = pchar
                        hl.Parent = pchar
                        highlights[pchar] = hl
                    end
                    hl.FillColor = color
                    hl.OutlineColor = color
                else
                    local hl = highlights[pchar]
                    if hl then
                        hl:Destroy()
                        highlights[pchar] = nil
                    end
                end
            end
        end
    end
end

-- ============================================================
-- LOCK TARGET SYSTEM
-- ============================================================
local lockedTarget = nil
local lockHighlight = nil
local lockActive = false
local lockCameraOffset = 1.5

local function getVisibleTargetPart(target)
    if not target or not target.Character then return end
    return target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
end

local function isValidTarget(plr)
    if plr == player then return false end
    local char = plr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    return true
end

local function getTargetByRaycast()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local best, distBest = nil, CONFIG.LockMaxDistance
    for _, plr in ipairs(Players:GetPlayers()) do
        if isValidTarget(plr) then
            local part = getVisibleTargetPart(plr)
            if part then
                local dir = part.Position - hrp.Position
                local dist = dir.Magnitude
                if dist <= CONFIG.LockMaxDistance and dist < distBest then
                    best, distBest = plr, dist
                end
            end
        end
    end
    return best
end

local function applyLockHighlight(char)
    if lockHighlight then lockHighlight:Destroy() end
    local hl = Instance.new("Highlight")
    hl.FillColor = Color3.fromRGB(255, 50, 50)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency, hl.OutlineTransparency = 0.3, 0
    hl.Adornee = char
    hl.Parent = char
    lockHighlight = hl
end

local function unlockTarget()
    if lockHighlight then lockHighlight:Destroy() end
    lockHighlight, lockedTarget, lockActive = nil, nil, false
    camera.CameraType = Enum.CameraType.Custom
end

local function setNewTarget(target)
    if not target then unlockTarget() return end
    lockedTarget, lockActive = target, true
    applyLockHighlight(target.Character)
    camera.CameraType = Enum.CameraType.Scriptable
end

local function toggleLock()
    if not features.lock then return end
    if lockActive then unlockTarget(); return end
    local target = getTargetByRaycast()
    if target then 
        setNewTarget(target)
        sendNotification("🎯 Locked: " .. target.Name, colors.accent2)
    else
        sendNotification("❌ No target found", colors.error)
    end
end

-- ============================================================
-- FLING SYSTEM
-- ============================================================
local flingActive = false
local flingConnection = nil

local function stopFling()
    flingActive = false
    if flingConnection then
        flingConnection:Disconnect()
        flingConnection = nil
    end
end

local function startFling()
    if flingActive then return end
    flingActive = true
    
    flingConnection = RunService.Heartbeat:Connect(function()
        if not flingActive then
            if flingConnection then
                flingConnection:Disconnect()
                flingConnection = nil
            end
            return
        end
        
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then
                local pchar = plr.Character
                if pchar then
                    local targetHRP = pchar:FindFirstChild("HumanoidRootPart")
                    if targetHRP then
                        local dist = (targetHRP.Position - hrp.Position).Magnitude
                        if dist < 80 then
                            targetHRP.AssemblyLinearVelocity = Vector3.new(
                                math.random(-400, 400),
                                math.random(200, 800),
                                math.random(-400, 400)
                            )
                            targetHRP.AssemblyAngularVelocity = Vector3.new(
                                math.random(-80, 80),
                                math.random(-80, 80),
                                math.random(-80, 80)
                            )
                        end
                    end
                end
            end
        end
    end)
    
    sendNotification("💥 Fling started!", colors.accent2)
end

-- ============================================================
-- ANTI-AFK SYSTEM
-- ============================================================
local antiAfkActive = CONFIG.EnableAntiAFK
local antiAfkTimer = 0
local antiAfkConnection = nil

local function performAntiAFK()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end

local function startAntiAFK()
    if antiAfkConnection then antiAfkConnection:Disconnect() end
    antiAfkTimer = 0
    
    antiAfkConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if not antiAfkActive then return end
        antiAfkTimer = antiAfkTimer + deltaTime
        if antiAfkTimer >= CONFIG.AntiAFKInterval then
            antiAfkTimer = 0
            task.spawn(performAntiAFK)
        end
    end)
end

local function toggleAntiAFK(state)
    antiAfkActive = state
    features.antiAfk = state
    if state then
        startAntiAFK()
        sendNotification("🛡️ Anti-AFK ON", colors.success)
    else
        if antiAfkConnection then antiAfkConnection:Disconnect(); antiAfkConnection = nil end
        sendNotification("🛡️ Anti-AFK OFF", colors.error)
    end
end

-- ============================================================
-- AFK PLATFORM
-- ============================================================
local afkPlatformActive = false
local afkPlatformConnection = nil
local afkWaypoints = {}
local afkCurrentWaypoint = 1

local function toggleAFKPlatform(state)
    local hrp = waitForCharacter()
    if not hrp then return end
    
    afkPlatformActive = state
    features.afkPlatform = state
    
    if afkPlatformActive then
        sendNotification("💤 AFK Platform ON", colors.accent2)
        local startPos = hrp.Position + Vector3.new(0, 3000, 0)
        hrp.CFrame = CFrame.new(startPos)
        
        local radius = 80
        local height = 3000
        afkWaypoints = {
            Vector3.new(radius, height, 0),
            Vector3.new(0, height, radius),
            Vector3.new(-radius, height, 0),
            Vector3.new(0, height, -radius),
        }
        afkCurrentWaypoint = 1
        
        if afkPlatformConnection then afkPlatformConnection:Disconnect() end
        
        afkPlatformConnection = RunService.Heartbeat:Connect(function()
            if not afkPlatformActive then
                if afkPlatformConnection then
                    afkPlatformConnection:Disconnect()
                    afkPlatformConnection = nil
                end
                return
            end
            
            local char = player.Character
            if not char then return end
            local currentHRP = char:FindFirstChild("HumanoidRootPart")
            if not currentHRP then return end
            
            local targetPos = startPos + afkWaypoints[afkCurrentWaypoint]
            local distance = (currentHRP.Position - targetPos).Magnitude
            
            if distance < 5 then
                afkCurrentWaypoint = afkCurrentWaypoint % #afkWaypoints + 1
            else
                local direction = (targetPos - currentHRP.Position).Unit
                currentHRP.AssemblyLinearVelocity = direction * 60
            end
        end)
    else
        sendNotification("💤 AFK Platform OFF", colors.error)
        if afkPlatformConnection then afkPlatformConnection:Disconnect(); afkPlatformConnection = nil end
        local groundY = workspace.FallenPartsDestroyHeight + 5
        hrp.CFrame = CFrame.new(hrp.Position.X, groundY, hrp.Position.Z)
    end
end

-- ============================================================
-- ADMIN SYSTEM
-- ============================================================
local function teleportToAdmin(adminName, isAuto)
    local adminPlayer = nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name == adminName then
            adminPlayer = plr
            break
        end
    end
    
    if not adminPlayer then
        if not isAuto then sendNotification("❌ Admin not found", colors.error) end
        return false
    end
    
    local adminChar = adminPlayer.Character
    if not adminChar or not adminChar:FindFirstChild("HumanoidRootPart") then
        if not isAuto then sendNotification("❌ Admin not in game", colors.error) end
        return false
    end
    
    local myHRP = waitForCharacter()
    if not myHRP then return false end
    
    local targetCF = adminChar.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
    myHRP.CFrame = targetCF
    
    sendNotification((isAuto and "🚀 " or "✅ ") .. "Teleported to " .. adminName, colors.success)
    return true
end

-- ============================================================
-- ADMIN COMMANDS
-- ============================================================
local function processAdminCommand(message, sender)
    if not CONFIG.EnableAdminCommands then return end
    if not isAdmin(sender) then return end
    
    local msg = message:lower()
    
    if CONFIG.EnableAutoTeleport then
        local phrases = {"come to me", "come here", "tp to me", "teleport to me", "come"}
        for _, phrase in ipairs(phrases) do
            if msg:find(phrase, 1, true) and not msg:sub(1, 1) == "/" then
                teleportToAdmin(sender, true)
                return
            end
        end
    end
    
    if msg:sub(1, 1) == "/" then
        local cmd = msg:sub(2)
        if cmd == "turn off fly" or cmd == "disable fly" or cmd == "fly off" then
            if features.fly then toggleFly(false) end
            sendNotification("👮 " .. sender .. " disabled your fly!", colors.error)
        elseif cmd == "help" then
            sendNotification("📋 Commands: /fly off, /help", colors.admin)
        end
    end
end

-- ============================================================
-- KEYBIND SYSTEM
-- ============================================================
local currentKeybinds = {}
for name, key in pairs(CONFIG.Keybinds) do
    currentKeybinds[name] = getKeyCode(key)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local key = input.KeyCode
    if not key then return end
    
    if key == currentKeybinds.ToggleFly then
        toggleFly(not features.fly)
    elseif key == currentKeybinds.ToggleESP then
        features.esp = not features.esp
        if features.esp then refreshESP() else clearESP() end
        sendNotification("👁️ ESP " .. (features.esp and "ON" or "OFF"), features.esp and colors.success or colors.error)
        updateTabContent()
    elseif key == currentKeybinds.ToggleMenu then
        menuVisible = not menuVisible
        menu.Visible = menuVisible
    elseif key == currentKeybinds.TeleportToAdmin then
        if #CONFIG.AdminUsernames > 0 then
            teleportToAdmin(CONFIG.AdminUsernames[1], true)
        end
    elseif key == currentKeybinds.ToggleAFK then
        toggleAFKPlatform(not afkPlatformActive)
    elseif key == currentKeybinds.ToggleAntiAFK then
        toggleAntiAFK(not antiAfkActive)
    elseif key == currentKeybinds.ToggleLock then
        toggleLock()
    elseif key == currentKeybinds.ToggleHighlight then
        highlightActive = not highlightActive
        features.highlight = highlightActive
        sendNotification("🟩 Highlight " .. (highlightActive and "ON" or "OFF"), highlightActive and colors.success or colors.error)
        updateTabContent()
    elseif key == currentKeybinds.ToggleFling then
        if flingActive then stopFling() else startFling() end
    end
    
    -- Fly movement
    if features.fly then
        if key == Enum.KeyCode.W then flyInput.Forward = 1
        elseif key == Enum.KeyCode.S then flyInput.Forward = -1
        elseif key == Enum.KeyCode.A then flyInput.Right = -1
        elseif key == Enum.KeyCode.D then flyInput.Right = 1
        elseif key == Enum.KeyCode.Space then flyInput.Up = 1
        elseif key == Enum.KeyCode.LeftShift then flyInput.Up = -1
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local key = input.KeyCode
    if not key then return end
    
    if features.fly then
        if key == Enum.KeyCode.W or key == Enum.KeyCode.S then flyInput.Forward = 0
        elseif key == Enum.KeyCode.A or key == Enum.KeyCode.D then flyInput.Right = 0
        elseif key == Enum.KeyCode.Space or key == Enum.KeyCode.LeftShift then flyInput.Up = 0
        end
    end
end)

-- ============================================================
-- CHAT LISTENER
-- ============================================================
local function setupAdminListener()
    local ChatService = game:GetService("Chat")
    if ChatService and ChatService:FindFirstChild("OnChatMessage") then
        ChatService.OnChatMessage:Connect(processAdminCommand)
    end
    
    for _, name in ipairs({"Chat", "SendMessage", "ChatMessage", "SendChat", "PlayerChat", "SayMessage"}) do
        local remote = ReplicatedStorage:FindFirstChild(name)
        if remote and remote:IsA("RemoteEvent") then
            remote.OnClientEvent:Connect(function(sender, message)
                if type(sender) == "string" and type(message) == "string" then
                    processAdminCommand(message, sender)
                end
            end)
        end
    end
end

-- ============================================================
-- PLAYER EVENTS
-- ============================================================
Players.PlayerAdded:Connect(function(newPlayer)
    if features.esp then
        task.wait(0.5)
        createESPTag(newPlayer)
    end
end)

Players.PlayerRemoving:Connect(function(playerLeft)
    if features.esp and espTags[playerLeft.UserId] then
        local tag = espTags[playerLeft.UserId]
        if tag then tag:Destroy() end
        espTags[playerLeft.UserId] = nil
    end
end)

-- ============================================================
-- RUN LOOP
-- ============================================================
RunService.RenderStepped:Connect(function()
    if not (lockActive and lockedTarget) then return end
    local targetChar = lockedTarget.Character
    local targetHRP = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not (targetHRP and hrp) then return end

    local visiblePart = getVisibleTargetPart(lockedTarget) or targetHRP
    local lookAt = CFrame.lookAt(hrp.Position, Vector3.new(visiblePart.Position.X, hrp.Position.Y, visiblePart.Position.Z))
    hrp.CFrame = hrp.CFrame:Lerp(lookAt, 0.35)

    local camPos = hrp.Position - hrp.CFrame.LookVector * 8 + Vector3.new(0, 3, 0)
    local targetPos = visiblePart.Position + Vector3.new(0, lockCameraOffset, 0)
    camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camPos, targetPos), 0.3)
end)

RunService.Heartbeat:Connect(function()
    if highlightActive then
        updateHighlights()
    end
end)

-- ============================================================
-- INITIALIZATION
-- ============================================================
if CONFIG.EnableAntiAFK then
    task.wait(1)
    startAntiAFK()
end

if CONFIG.EnableAdminCommands then
    task.delay(1, setupAdminListener)
end

updateTabContent()

sendNotification("⚡ Lilcat Ultimate Utility Loaded!", colors.accent, 3)

print("=== LILCAT ULTIMATE UTILITY ===")
print("Press RightShift - Toggle Menu")
print("Press F - Fly | E - ESP | L - Lock")
print("Press H - Highlight | G - Fling")
print("Press T - Teleport to Admin")
print("================================")
