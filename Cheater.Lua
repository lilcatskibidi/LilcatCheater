-- ============================================================
-- LILCAT ULTIMATE UTILITY - All-in-One
-- Place in StarterPlayerScripts
-- ============================================================

-- ============================================================
-- CONFIGURATION
-- ============================================================
local CONFIG = {
    -- Admin Usernames
    AdminUsernames = {
        "PhoMaoC0D3v6",
    },
    
    -- Features
    EnableAdminCommands = true,
    EnableAutoTeleport = true,
    EnableAntiAFK = true,
    AntiAFKInterval = 45,
    DefaultFlySpeed = 50,
    MaxFlySpeed = 999999,
    
    -- Highlight Settings
    HighlightDistance = 600,
    EnemyColor = Color3.fromRGB(255, 60, 60),
    TeammateColor = Color3.fromRGB(0, 170, 255),
    AllyColor = Color3.fromRGB(0, 255, 0),
    
    -- Lock Target Settings
    LockMaxDistance = 700,
    LockViewAngle = 35,
    LockCameraOffset = 1.5,
    
    -- Keybinds
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
        ToggleTeleport = "P",
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
local Teams = game:GetService("Teams")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================

local function waitForCharacter()
    if not player.Character then
        player.CharacterAdded:Wait()
    end
    return player.Character:WaitForChild("HumanoidRootPart")
end

local function getKeyCode(keyName)
    if type(keyName) == "EnumItem" then return keyName end
    local keyMap = {
        F = Enum.KeyCode.F, E = Enum.KeyCode.E, T = Enum.KeyCode.T,
        R = Enum.KeyCode.R, Q = Enum.KeyCode.Q, B = Enum.KeyCode.B,
        N = Enum.KeyCode.N, M = Enum.KeyCode.M, Z = Enum.KeyCode.Z,
        X = Enum.KeyCode.X, C = Enum.KeyCode.C, V = Enum.KeyCode.V,
        G = Enum.KeyCode.G, H = Enum.KeyCode.H, P = Enum.KeyCode.P,
        L = Enum.KeyCode.L,
        LeftShift = Enum.KeyCode.LeftShift, RightShift = Enum.KeyCode.RightShift,
        LeftControl = Enum.KeyCode.LeftControl, RightControl = Enum.KeyCode.RightControl,
        LeftAlt = Enum.KeyCode.LeftAlt, RightAlt = Enum.KeyCode.RightAlt,
        Space = Enum.KeyCode.Space,
    }
    return keyMap[keyName] or Enum.KeyCode[keyName] or Enum.KeyCode.F
end

local function getKeyName(keyCode)
    for name, code in pairs(CONFIG.Keybinds) do
        if getKeyCode(code) == keyCode then return name end
    end
    return tostring(keyCode):gsub("Enum.KeyCode.", "")
end

local function isAdmin(username)
    for _, adminName in ipairs(CONFIG.AdminUsernames) do
        if adminName == username then return true end
    end
    return false
end

local function popup(text)
    task.spawn(function()
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Lilcat Utility",
                Text = text,
                Duration = 2
            })
        end)
    end)
end

-- ============================================================
-- GUI SYSTEM
-- ============================================================

local oldgui = CoreGui:FindFirstChild("LilcatUtility")
if oldgui then oldgui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "LilcatUtility"
gui.Parent = CoreGui
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

-- Colors
local colors = {
    bg = Color3.fromRGB(18, 18, 22),
    bg2 = Color3.fromRGB(28, 28, 35),
    bg3 = Color3.fromRGB(38, 38, 48),
    bg4 = Color3.fromRGB(48, 48, 58),
    accent = Color3.fromRGB(100, 180, 255),
    accent2 = Color3.fromRGB(80, 220, 160),
    error = Color3.fromRGB(255, 80, 80),
    success = Color3.fromRGB(80, 255, 150),
    warn = Color3.fromRGB(255, 200, 50),
    text = Color3.fromRGB(220, 220, 230),
    textDim = Color3.fromRGB(150, 150, 170),
    admin = Color3.fromRGB(255, 200, 50),
    enemy = CONFIG.EnemyColor,
    teammate = CONFIG.TeammateColor,
    ally = CONFIG.AllyColor,
}

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
                frame.Size = UDim2.new(0, 450, 0, 45)
                frame.Position = UDim2.new(0.5, -225, 0, 60)
                frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
                frame.BackgroundTransparency = 0.15
                frame.BorderSizePixel = 0
                frame.Parent = gui
                
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 10)
                corner.Parent = frame
                
                local stroke = Instance.new("UIStroke")
                stroke.Color = notif.color
                stroke.Thickness = 2
                stroke.Transparency = 0.5
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
                
                frame.Position = UDim2.new(0.5, -225, 0, -60)
                local tweenIn = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0.5, -225, 0, 60)
                })
                tweenIn:Play()
                tweenIn.Completed:Wait()
                
                task.wait(notif.duration)
                
                local tweenOut = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Position = UDim2.new(0.5, -225, 0, -60)
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
-- MAIN MENU - Professional Design
-- ============================================================

local menuVisible = true
local currentTab = "Main"
local menuTabs = {"Main", "Combat", "Movement", "Visuals", "Admin", "Settings"}

local menu = Instance.new("Frame")
menu.Size = UDim2.new(0, 350, 0, 500)
menu.Position = UDim2.new(0, 20, 0.08, 0)
menu.BackgroundColor3 = colors.bg
menu.BackgroundTransparency = 0.05
menu.BorderSizePixel = 0
menu.ClipsDescendants = true
menu.Parent = gui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 14)
menuCorner.Parent = menu

local menuStroke = Instance.new("UIStroke")
menuStroke.Color = colors.accent
menuStroke.Thickness = 1
menuStroke.Transparency = 0.5
menuStroke.Parent = menu

menu.Active = true
menu.Draggable = true

-- Glow
local glow = Instance.new("Frame")
glow.Size = UDim2.new(1, 30, 1, 30)
glow.Position = UDim2.new(0, -15, 0, -15)
glow.BackgroundColor3 = colors.accent
glow.BackgroundTransparency = 0.95
glow.BorderSizePixel = 0
glow.ZIndex = 0
glow.Parent = menu

local glowCorner = Instance.new("UICorner")
glowCorner.CornerRadius = UDim.new(0, 24)
glowCorner.Parent = glow

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = colors.bg2
titleBar.BackgroundTransparency = 0.3
titleBar.BorderSizePixel = 0
titleBar.Parent = menu

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 14)
titleCorner.Parent = titleBar

local titleIcon = Instance.new("TextLabel")
titleIcon.Size = UDim2.new(0, 35, 1, 0)
titleIcon.Position = UDim2.new(0, 10, 0, 0)
titleIcon.BackgroundTransparency = 1
titleIcon.Text = "⚡"
titleIcon.TextColor3 = colors.accent
titleIcon.Font = Enum.Font.GothamBold
titleIcon.TextSize = 24
titleIcon.TextXAlignment = Enum.TextXAlignment.Center
titleIcon.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -80, 1, 0)
titleLabel.Position = UDim2.new(0, 50, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "LILCAT UTILITY"
titleLabel.TextColor3 = colors.text
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -42, 0, 7)
closeBtn.BackgroundColor3 = colors.bg3
closeBtn.BackgroundTransparency = 0.5
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
tabBar.Size = UDim2.new(1, 0, 0, 40)
tabBar.Position = UDim2.new(0, 0, 0, 50)
tabBar.BackgroundColor3 = colors.bg2
tabBar.BackgroundTransparency = 0.2
tabBar.BorderSizePixel = 0
tabBar.Parent = menu

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 2)
tabLayout.Parent = tabBar

local tabButtons = {}

local function createTabButton(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 55, 1, -6)
    btn.Position = UDim2.new(0, 3, 0, 3)
    btn.BackgroundColor3 = colors.bg3
    btn.BackgroundTransparency = 0.5
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
            tb.BackgroundColor3 = colors.bg3
            tb.BackgroundTransparency = 0.5
            tb.TextColor3 = colors.textDim
        end
        btn.BackgroundColor3 = colors.accent
        btn.BackgroundTransparency = 0.3
        btn.TextColor3 = colors.text
        updateTabContent()
    end)
    
    tabButtons[name] = btn
    return btn
end

for _, tabName in ipairs(menuTabs) do
    createTabButton(tabName)
end

-- Tab Content Container
local tabContent = Instance.new("Frame")
tabContent.Size = UDim2.new(1, -20, 1, -100)
tabContent.Position = UDim2.new(0, 10, 0, 95)
tabContent.BackgroundTransparency = 1
tabContent.ClipsDescendants = true
tabContent.Parent = menu

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 4)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Parent = tabContent

-- Scrollable content
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

local function createButton(text, parent, callback, icon, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = color or colors.bg2
    btn.BackgroundTransparency = 0.3
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = colors.bg3
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = btn
    
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
        if callback then callback(btn) end
    end)
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
    end)
    
    return btn
end

local function createToggle(text, parent, callback, icon)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 38)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, -5, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = (icon or "") .. " " .. text
    label.TextColor3 = colors.text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(0, 50, 0, 28)
    toggle.Position = UDim2.new(1, -55, 0.5, -14)
    toggle.BackgroundColor3 = colors.bg3
    toggle.BorderSizePixel = 0
    toggle.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 22, 0, 22)
    indicator.Position = UDim2.new(0, 3, 0.5, -11)
    indicator.BackgroundColor3 = colors.textDim
    indicator.BorderSizePixel = 0
    indicator.Parent = toggle
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(1, 0)
    indicatorCorner.Parent = indicator
    
    local state = false
    
    local function updateToggle()
        if state then
            toggle.BackgroundColor3 = colors.accent
            indicator.Position = UDim2.new(1, -25, 0.5, -11)
            indicator.BackgroundColor3 = colors.text
        else
            toggle.BackgroundColor3 = colors.bg3
            indicator.Position = UDim2.new(0, 3, 0.5, -11)
            indicator.BackgroundColor3 = colors.textDim
        end
    end
    
    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.Parent = toggle
    
    clickBtn.MouseButton1Click:Connect(function()
        state = not state
        updateToggle()
        if callback then callback(state) end
    end)
    
    updateToggle()
    return frame, function() return state end
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
-- TAB CONTENT
-- ============================================================

local function updateTabContent()
    for _, child in ipairs(contentScroll:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    if currentTab == "Main" then
        createButton("📊 Status Dashboard", contentScroll)
        
        local statusFrame = Instance.new("Frame")
        statusFrame.Size = UDim2.new(1, 0, 0, 80)
        statusFrame.BackgroundColor3 = colors.bg2
        statusFrame.BackgroundTransparency = 0.3
        statusFrame.Parent = contentScroll
        
        local statusCorner = Instance.new("UICorner")
        statusCorner.CornerRadius = UDim.new(0, 8)
        statusCorner.Parent = statusFrame
        
        local labels = {
            "⚡ Fly: " .. (features.fly and "ON" or "OFF"),
            "👁️ ESP: " .. (features.esp and "ON" or "OFF"),
            "🛡️ Anti-AFK: " .. (features.antiAfk and "ON" or "OFF"),
            "🎯 Lock: " .. (features.lock and "ON" or "OFF"),
        }
        
        for i, text in ipairs(labels) do
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0.5, -5, 0.5, -5)
            lbl.Position = UDim2.new((i-1)%2 * 0.5 + 0.02, 0, math.floor((i-1)/2) * 0.5 + 0.02, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextColor3 = colors.text
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 13
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = statusFrame
        end
        
        createButton("📋 Quick Help", contentScroll, function()
            sendNotification("📋 Press F-Fly | E-ESP | L-Lock | H-Highlight | G-Fling", colors.accent)
        end, "📋")
        
    elseif currentTab == "Combat" then
        createToggle("🎯 Lock Target", contentScroll, function(state)
            features.lock = state
            if state then
                sendNotification("🎯 Lock Target Enabled - Press L", colors.accent2)
            else
                if lockTarget then unlockTarget() end
                sendNotification("🎯 Lock Target Disabled", colors.error)
            end
        end, "🎯")
        
        createToggle("💥 Fling Mode", contentScroll, function(state)
            features.fling = state
            if state then
                sendNotification("💥 Fling Mode Enabled - Press G", colors.accent2)
            else
                stopFling()
                sendNotification("💥 Fling Mode Disabled", colors.error)
            end
        end, "💥")
        
        createToggle("👁️ ESP Players", contentScroll, function(state)
            features.esp = state
            if state then
                refreshESP()
                sendNotification("👁️ ESP Enabled", colors.accent2)
            else
                clearESP()
                sendNotification("👁️ ESP Disabled", colors.error)
            end
        end, "👁️")
        
        createToggle("🟩 Team Highlight", contentScroll, function(state)
            features.highlight = state
            if state then
                sendNotification("🟩 Highlight Enabled", colors.accent2)
            else
                clearHighlights()
                sendNotification("🟩 Highlight Disabled", colors.error)
            end
        end, "🟩")
        
    elseif currentTab == "Movement" then
        createToggle("✈️ Fly Mode", contentScroll, function(state)
            toggleFly(state)
        end, "✈️")
        
        createToggle("💤 AFK Platform", contentScroll, function(state)
            toggleAFKPlatform(state)
        end, "💤")
        
        createToggle("🛡️ Anti-AFK", contentScroll, function(state)
            toggleAntiAFK(state)
        end, "🛡️")
        
        -- Speed control
        local speedFrame = Instance.new("Frame")
        speedFrame.Size = UDim2.new(1, 0, 0, 70)
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
        speedInput.Size = UDim2.new(0.6, 0, 0, 30)
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
        
        local applySpeed = Instance.new("TextButton")
        applySpeed.Size = UDim2.new(0.3, -10, 0, 30)
        applySpeed.Position = UDim2.new(0.7, 0, 0, 28)
        applySpeed.BackgroundColor3 = colors.accent
        applySpeed.BackgroundTransparency = 0.3
        applySpeed.Text = "Apply"
        applySpeed.TextColor3 = colors.text
        applySpeed.Font = Enum.Font.GothamSemibold
        applySpeed.TextSize = 14
        applySpeed.BorderSizePixel = 0
        applySpeed.Parent = speedFrame
        
        local applyCorner = Instance.new("UICorner")
        applyCorner.CornerRadius = UDim.new(0, 6)
        applyCorner.Parent = applySpeed
        
        applySpeed.MouseButton1Click:Connect(function()
            local val = tonumber(speedInput.Text)
            if val and val > 0 then
                flySpeed = val
                speedLabel.Text = "✈️ Fly Speed: " .. flySpeed
                sendNotification("✈️ Speed set to: " .. flySpeed, colors.accent2)
            else
                sendNotification("❌ Enter a valid number!", colors.error)
            end
        end)
        
        local presets = {"10", "50", "100", "500", "1000", "99999"}
        local presetRow = Instance.new("Frame")
        presetRow.Size = UDim2.new(1, 0, 0, 28)
        presetRow.BackgroundTransparency = 1
        presetRow.Parent = contentScroll
        
        local presetLayout = Instance.new("UIListLayout")
        presetLayout.FillDirection = Enum.FillDirection.Horizontal
        presetLayout.Padding = UDim.new(0, 4)
        presetLayout.Parent = presetRow
        
        for _, val in ipairs(presets) do
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(0.15, 0, 1, 0)
            pBtn.BackgroundColor3 = colors.bg3
            pBtn.BackgroundTransparency = 0.3
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
            if state then
                refreshESP()
                sendNotification("👁️ ESP Enabled", colors.accent2)
            else
                clearESP()
                sendNotification("👁️ ESP Disabled", colors.error)
            end
        end, "👁️")
        
        createToggle("🟩 Team Highlight", contentScroll, function(state)
            features.highlight = state
            if state then
                sendNotification("🟩 Highlight Enabled", colors.accent2)
            else
                clearHighlights()
                sendNotification("🟩 Highlight Disabled", colors.error)
            end
        end, "🟩")
        
        createToggle("🎯 Lock Target", contentScroll, function(state)
            features.lock = state
            if state then
                sendNotification("🎯 Lock Target Enabled", colors.accent2)
            else
                if lockTarget then unlockTarget() end
                sendNotification("🎯 Lock Target Disabled", colors.error)
            end
        end, "🎯")
        
    elseif currentTab == "Admin" then
        createButton("👮 Check Admins", contentScroll, function()
            local admins = {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if isAdmin(plr.Name) then
                    table.insert(admins, plr.Name)
                end
            end
            if #admins > 0 then
                sendNotification("👮 Admins: " .. table.concat(admins, ", "), colors.admin)
            else
                sendNotification("👮 No admins online", colors.textDim)
            end
        end, "👮")
        
        createToggle("📨 Admin Commands", contentScroll, function(state)
            CONFIG.EnableAdminCommands = state
            sendNotification("Admin commands " .. (state and "enabled" or "disabled"), state and colors.success or colors.error)
        end, "📨")
        
        createToggle("🚀 Auto Teleport", contentScroll, function(state)
            CONFIG.EnableAutoTeleport = state
            sendNotification("Auto-teleport " .. (state and "enabled" or "disabled"), state and colors.success or colors.error)
        end, "🚀")
        
    elseif currentTab == "Settings" then
        createButton("⚙️ Keybinds", contentScroll, function()
            local msg = "🔑 Keybinds:\n"
            for name, key in pairs(CONFIG.Keybinds) do
                msg = msg .. name .. ": " .. key .. "\n"
            end
            sendNotification(msg, colors.accent, 5)
        end, "⚙️")
        
        createToggle("🛡️ Anti-AFK", contentScroll, function(state)
            CONFIG.EnableAntiAFK = state
            toggleAntiAFK(state)
        end, "🛡️")
        
        -- Teleport points
        createButton("📍 Teleport Points", contentScroll, function()
            showTeleportPanel()
        end, "📍")
    end
end

-- ============================================================
-- FLY SYSTEM
-- ============================================================

local function toggleFly(state)
    features.fly = state
    if state then
        sendNotification("✈️ Fly enabled! Speed: " .. flySpeed, colors.accent2)
        local hrp = waitForCharacter()
        if flyConnection then flyConnection:Disconnect() end
        
        flyConnection = RunService.Heartbeat:Connect(function()
            if not features.fly then
                if flyConnection then
                    flyConnection:Disconnect()
                    flyConnection = nil
                end
                return
            end
            
            local char = player.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local camCF = workspace.CurrentCamera.CFrame
            local direction = (camCF.LookVector * flyInput.Forward) + 
                             (camCF.RightVector * flyInput.Right) + 
                             (Vector3.new(0, 1, 0) * flyInput.Up)
            
            if direction.Magnitude > 0 then
                direction = direction.Unit
                local targetVel = direction * flySpeed
                flyVelocity = flyVelocity:Lerp(targetVel, 0.5)
                hrp.AssemblyLinearVelocity = flyVelocity
            else
                flyVelocity = flyVelocity:Lerp(Vector3.new(), 0.2)
                if flyVelocity.Magnitude < 0.1 then flyVelocity = Vector3.new() end
                hrp.AssemblyLinearVelocity = flyVelocity
            end
        end)
    else
        sendNotification("✈️ Fly disabled", colors.error)
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
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
    billboard.Size = UDim2.new(0, 200, 0, 40)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.MaxDistance = 300    billboard.Parent = head
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.3
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
    label.TextSize = 14
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
local allyTeams = {}

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
                    elseif plr.Team and allyTeams[plr.Team] then
                        color = CONFIG.AllyColor
                    end
                    
                    local hl = highlights[pchar]
                    if not hl or not hl.Parent then
                        hl = Instance.new("Highlight")
                        hl.FillTransparency = 0.6
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
local lockMode = "Raycast"
local targetMode = "FFA"
local targetPartChoice = "Head"
local lockCameraOffset = CONFIG.LockCameraOffset

local function getVisibleTargetPart(target)
    if not target or not target.Character then return end
    local char = target.Character
    if targetPartChoice == "Head" then
        return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    elseif targetPartChoice == "UpperTorso" then
        return char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
    elseif targetPartChoice == "HumanoidRootPart" then
        return char:FindFirstChild("HumanoidRootPart")
    end
end

local function isValidTarget(plr)
    if plr == player then return false end
    local char = plr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    if targetMode == "Team" and player.Team and plr.Team == player.Team then return false end
    return true
end

local function getTargetByRaycast()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local best, distBest = nil, CONFIG.LockMaxDistance
    for _, plr in ipairs(Players:GetPlayers()) do
        if isValidTarget(plr) then
            local visiblePart = getVisibleTargetPart(plr)
            if visiblePart then
                local dir = visiblePart.Position - hrp.Position
                local dist = dir.Magnitude
                local angle = math.deg(math.acos(hrp.CFrame.LookVector:Dot(dir.Unit)))
                if dist <= CONFIG.LockMaxDistance and angle <= CONFIG.LockViewAngle and dist < distBest then
                    best, distBest = plr, dist
                end
            end
        end
    end
    return best
end

local function getTargetByMouse()
    local mousePos = UserInputService:GetMouseLocation()
    local best, closest = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if isValidTarget(plr) then
            local part = getVisibleTargetPart(plr)
            if part then
                local screenPos, vis = camera:WorldToViewportPoint(part.Position)
                if vis then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < closest and dist < 150 then
                        closest, best = dist, plr
                    end
                end
            end
        end
    end
    return best
end

local function getTargetAuto()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local nearest, closest = nil, CONFIG.LockMaxDistance
    for _, plr in ipairs(Players:GetPlayers()) do
        if isValidTarget(plr) then
            local part = getVisibleTargetPart(plr)
            if part then
                local dist = (part.Position - hrp.Position).Magnitude
                if dist < closest then
                    closest, nearest = dist, plr
                end
            end
        end
    end
    return nearest
end

local function applyLockHighlight(char)
    if lockHighlight then lockHighlight:Destroy() end
    local hl = Instance.new("Highlight")
    hl.FillColor = Color3.fromRGB(255, 0, 0)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency, hl.OutlineTransparency = 0.4, 0
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
    local target
    if lockMode == "Mouse" then
        target = getTargetByMouse()
    elseif lockMode == "Auto" then
        target = getTargetAuto()
    else
        target = getTargetByRaycast()
    end
    if target then 
        setNewTarget(target)
        sendNotification("🎯 Locked onto " .. target.Name, colors.accent2)
    else
        sendNotification("❌ No target found", colors.error)
    end
end

-- ============================================================
-- FLING SYSTEM
-- ============================================================

local flingActive = false
local flingConnection = nil
local flingTargets = {}
local oldPos = nil
local fpdh = workspace.FallenPartsDestroyHeight

local function stopFling()
    flingActive = false
    if flingConnection then
        flingConnection:Disconnect()
        flingConnection = nil
    end
    workspace.FallenPartsDestroyHeight = fpdh
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
        
        -- Fling all nearby players
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then
                local pchar = plr.Character
                if pchar then
                    local targetHRP = pchar:FindFirstChild("HumanoidRootPart")
                    if targetHRP then
                        local dist = (targetHRP.Position - hrp.Position).Magnitude
                        if dist < 100 then
                            -- Apply fling force
                            targetHRP.AssemblyLinearVelocity = Vector3.new(
                                math.random(-500, 500),
                                math.random(300, 1000),
                                math.random(-500, 500)
                            )
                            targetHRP.AssemblyAngularVelocity = Vector3.new(
                                math.random(-100, 100),
                                math.random(-100, 100),
                                math.random(-100, 100)
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
        if camera then
            local current = camera.CFrame
            camera.CFrame = current + Vector3.new(
                math.sin(tick() * 0.5) * 0.0005,
                math.cos(tick() * 0.7) * 0.0005,
                0
            )
        end
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
        sendNotification("🛡️ Anti-AFK Enabled", colors.success)
    else
        if antiAfkConnection then
            antiAfkConnection:Disconnect()
            antiAfkConnection = nil
        end
        sendNotification("🛡️ Anti-AFK Disabled", colors.error)
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
        sendNotification("💤 AFK Platform activated!", colors.accent2)
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
        sendNotification("💤 AFK Platform disabled", colors.error)
        if afkPlatformConnection then
            afkPlatformConnection:Disconnect()
            afkPlatformConnection = nil
        end
        local groundY = workspace.FallenPartsDestroyHeight + 5
        hrp.CFrame = CFrame.new(hrp.Position.X, groundY, hrp.Position.Z)
    end
end

-- ============================================================
-- TELEPORT SYSTEM
-- ============================================================

local savedPoints = {}

local function showTeleportPanel()
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 280, 0, 350)
    panel.Position = UDim2.new(0.5, -140, 0.5, -175)
    panel.BackgroundColor3 = colors.bg
    panel.BackgroundTransparency = 0.08
    panel.BorderSizePixel = 0
    panel.ClipsDescendants = true
    panel.Parent = gui
    panel.Active = true
    panel.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = panel
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = colors.accent2
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = panel
    
    local title = Instance.new("Frame")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = colors.bg2
    title.BackgroundTransparency = 0.3
    title.BorderSizePixel = 0
    title.Parent = panel
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = title
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "📍 Teleport Points"
    titleLabel.TextColor3 = colors.accent2
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = title
    
    local closeP = Instance.new("TextButton")
    closeP.Size = UDim2.new(0, 30, 0, 30)
    closeP.Position = UDim2.new(1, -38, 0, 3)
    closeP.BackgroundColor3 = colors.bg3
    closeP.BackgroundTransparency = 0.5
    closeP.Text = "✕"
    closeP.TextColor3 = colors.error
    closeP.Font = Enum.Font.GothamBold
    closeP.TextSize = 16
    closeP.BorderSizePixel = 0
    closeP.Parent = title
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeP
    
    closeP.MouseButton1Click:Connect(function()
        panel:Destroy()
    end)
    
    -- Input for new point
    local nameBox = Instance.new("TextBox")
    nameBox.Size = UDim2.new(1, -20, 0, 30)
    nameBox.Position = UDim2.new(0, 10, 0, 45)
    nameBox.BackgroundColor3 = colors.bg3
    nameBox.BackgroundTransparency = 0.3
    nameBox.PlaceholderText = "Point name..."
    nameBox.TextColor3 = colors.text
    nameBox.Font = Enum.Font.Gotham
    nameBox.TextSize = 14
    nameBox.ClearTextOnFocus = false
    nameBox.Parent = panel
    
    local nameCorner = Instance.new("UICorner")
    nameCorner.CornerRadius = UDim.new(0, 6)
    nameCorner.Parent = nameBox
    
    local setBtn = Instance.new("TextButton")
    setBtn.Size = UDim2.new(1, -20, 0, 30)
    setBtn.Position = UDim2.new(0, 10, 0, 80)
    setBtn.BackgroundColor3 = colors.accent
    setBtn.BackgroundTransparency = 0.3
    setBtn.Text = "Save Current Position"
    setBtn.TextColor3 = colors.text
    setBtn.Font = Enum.Font.GothamSemibold
    setBtn.TextSize = 14
    setBtn.BorderSizePixel = 0
    setBtn.Parent = panel
    
    local setCorner = Instance.new("UICorner")
    setCorner.CornerRadius = UDim.new(0, 6)
    setCorner.Parent = setBtn
    
    setBtn.MouseButton1Click:Connect(function()
        local hrp = waitForCharacter()
        if not hrp then return end
        local name = nameBox.Text ~= "" and nameBox.Text or "Point " .. (#savedPoints + 1)
        local pos = hrp.Position
        table.insert(savedPoints, {name = name, pos = pos})
        nameBox.Text = ""
        sendNotification("✅ Saved point: " .. name, colors.success)
        refreshPointList()
    end)
    
    -- Points list
    local pointScroll = Instance.new("ScrollingFrame")
    pointScroll.Size = UDim2.new(1, -20, 1, -130)
    pointScroll.Position = UDim2.new(0, 10, 0, 120)
    pointScroll.BackgroundColor3 = colors.bg2
    pointScroll.BackgroundTransparency = 0.3
    pointScroll.ScrollBarThickness = 4
    pointScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    pointScroll.Parent = panel
    
    local pointCorner = Instance.new("UICorner")
    pointCorner.CornerRadius = UDim.new(0, 6)
    pointCorner.Parent = pointScroll
    
    local pointLayout = Instance.new("UIListLayout")
    pointLayout.Padding = UDim.new(0, 4)
    pointLayout.Parent = pointScroll
    
    local function refreshPointList()
        for _, child in ipairs(pointScroll:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        for _, data in ipairs(savedPoints) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.BackgroundColor3 = colors.bg3
            btn.BackgroundTransparency = 0.3
            btn.Text = "📌 " .. data.name
            btn.TextColor3 = colors.text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = pointScroll
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = btn
            
            btn.MouseButton1Click:Connect(function()
                local hrp = waitForCharacter()
                if hrp then
                    hrp.CFrame = CFrame.new(data.pos)
                    sendNotification("📍 Teleported to: " .. data.name, colors.accent2)
                end
            end)
        end
        
        pointScroll.CanvasSize = UDim2.new(0, 0, 0, pointLayout.AbsoluteContentSize.Y + 10)
    end
    
    refreshPointList()
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
        local phrases = {"come to me", "come here", "tp to me", "teleport to me", "come", "get over here"}
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
        elseif cmd == "help" or cmd == "?" then
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
    
    -- Check keybinds
    if key == currentKeybinds.ToggleFly then
        toggleFly(not features.fly)
    elseif key == currentKeybinds.ToggleESP then
        features.esp = not features.esp
        if features.esp then refreshESP() else clearESP() end
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
        if highlightActive then
            sendNotification("🟩 Highlight Enabled", colors.accent2)
        else
            clearHighlights()
            sendNotification("🟩 Highlight Disabled", colors.error)
        end
        updateTabContent()
    elseif key == currentKeybinds.ToggleFling then
        if flingActive then
            stopFling()
        else
            startFling()
        end
    elseif key == currentKeybinds.ToggleTeleport then
        showTeleportPanel()
    end
    
    -- Fly movement keys
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

-- Lock target camera
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

-- Highlight update
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

sendNotification("⚡ Lilcat Ultimate Utility loaded!", colors.accent, 3)
print("=== LILCAT ULTIMATE UTILITY ===")
print("Press RightShift - Toggle Menu")
print("Press F - Toggle Fly")
print("Press E - Toggle ESP")
print("Press L - Lock Target")
print("Press H - Highlight")
print("Press G - Fling")
print("Press T - Teleport to Admin")
print("================================")
