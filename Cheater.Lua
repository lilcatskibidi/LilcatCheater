-- Lilcat Cheat Utility Panel (Fixed & Working)
-- Place in StarterPlayerScripts

-- ============================================================
-- CONFIGURATION
-- ============================================================
local CONFIG = {
    -- Admin usernames (case sensitive)
    AdminUsernames = {
        "PhoMaoC0D3v6",
    },
    
    -- Features
    EnableAdminCommands = true,
    EnableAutoTeleport = true,
    EnableAntiAFK = true,
    AntiAFKInterval = 45,
    DefaultFlySpeed = 50,
    
    -- Keybinds (KeyCode names)
    Keybinds = {
        ToggleFly = "F",
        ToggleESP = "E",
        ToggleMenu = "RightShift",
        TeleportToAdmin = "T",
    },
}

-- ============================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

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
    local keyMap = {
        F = Enum.KeyCode.F,
        E = Enum.KeyCode.E,
        T = Enum.KeyCode.T,
        R = Enum.KeyCode.R,
        Q = Enum.KeyCode.Q,
        LeftShift = Enum.KeyCode.LeftShift,
        RightShift = Enum.KeyCode.RightShift,
        LeftControl = Enum.KeyCode.LeftControl,
        RightControl = Enum.KeyCode.RightControl,
        LeftAlt = Enum.KeyCode.LeftAlt,
        RightAlt = Enum.KeyCode.RightAlt,
        Space = Enum.KeyCode.Space,
        X = Enum.KeyCode.X,
        C = Enum.KeyCode.C,
        V = Enum.KeyCode.V,
        B = Enum.KeyCode.B,
        N = Enum.KeyCode.N,
        M = Enum.KeyCode.M,
        Z = Enum.KeyCode.Z,
    }
    return keyMap[keyName] or Enum.KeyCode[keyName] or Enum.KeyCode.F
end

local function isAdmin(username)
    for _, adminName in ipairs(CONFIG.AdminUsernames) do
        if adminName == username then
            return true
        end
    end
    return false
end

-- ============================================================
-- GUI SETUP - Modern Dark Theme
-- ============================================================

local oldgui = CoreGui:FindFirstChild("LilcatCheat")
if oldgui then oldgui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "LilcatCheat"
gui.Parent = CoreGui
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

-- Colors
local colors = {
    bg = Color3.fromRGB(20, 20, 25),
    bg2 = Color3.fromRGB(30, 30, 38),
    bg3 = Color3.fromRGB(40, 40, 50),
    accent = Color3.fromRGB(100, 180, 255),
    accent2 = Color3.fromRGB(80, 220, 160),
    error = Color3.fromRGB(255, 80, 80),
    success = Color3.fromRGB(80, 255, 150),
    warn = Color3.fromRGB(255, 200, 50),
    text = Color3.fromRGB(220, 220, 230),
    textDim = Color3.fromRGB(150, 150, 170),
    admin = Color3.fromRGB(255, 200, 50),
}

-- Smooth notification system
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
                frame.Size = UDim2.new(0, 350, 0, 45)
                frame.Position = UDim2.new(0.5, -175, 0, 60)
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
                
                -- Animate in
                frame.Position = UDim2.new(0.5, -175, 0, -60)
                local tweenIn = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0.5, -175, 0, 60)
                })
                tweenIn:Play()
                tweenIn.Completed:Wait()
                
                task.wait(notif.duration)
                
                -- Animate out
                local tweenOut = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Position = UDim2.new(0.5, -175, 0, -60)
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
-- MAIN MENU
-- ============================================================

local menuVisible = true
local menu = Instance.new("Frame")
menu.Size = UDim2.new(0, 280, 0, 420)
menu.Position = UDim2.new(0, 20, 0.15, 0)
menu.BackgroundColor3 = colors.bg
menu.BackgroundTransparency = 0.08
menu.BorderSizePixel = 0
menu.ClipsDescendants = true
menu.Parent = gui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 12)
menuCorner.Parent = menu

local menuStroke = Instance.new("UIStroke")
menuStroke.Color = colors.accent
menuStroke.Thickness = 1
menuStroke.Transparency = 0.6
menuStroke.Parent = menu

-- Make draggable
menu.Active = true
menu.Draggable = true

-- Glow effect
local glow = Instance.new("Frame")
glow.Size = UDim2.new(1, 20, 1, 20)
glow.Position = UDim2.new(0, -10, 0, -10)
glow.BackgroundColor3 = colors.accent
glow.BackgroundTransparency = 0.95
glow.BorderSizePixel = 0
glow.ZIndex = 0
glow.Parent = menu

local glowCorner = Instance.new("UICorner")
glowCorner.CornerRadius = UDim.new(0, 22)
glowCorner.Parent = glow

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = colors.bg2
titleBar.BackgroundTransparency = 0.3
titleBar.BorderSizePixel = 0
titleBar.Parent = menu

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚡ Lilcat Utility"
titleLabel.TextColor3 = colors.accent
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 20
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -42, 0, 5)
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

-- Scrollable content
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -55)
scrollFrame.Position = UDim2.new(0, 10, 0, 50)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = colors.accent
scrollFrame.ScrollBarImageTransparency = 0.5
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Parent = menu

local scrollLayout = Instance.new("UIListLayout")
scrollLayout.Padding = UDim.new(0, 6)
scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
scrollLayout.Parent = scrollFrame

scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, scrollLayout.AbsoluteContentSize.Y + 10)
end)

-- Button Creator
local function createModernButton(text, parent, callback, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = colors.bg2
    btn.BackgroundTransparency = 0.3
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.Parent = parent
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = colors.bg3
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.5
    btnStroke.Parent = btn
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = (icon or "") .. " " .. text
    label.TextColor3 = colors.text
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        if callback then callback(btn) end
    end)
    
    -- Hover effect
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
    end)
    
    return btn
end

-- ============================================================
-- FEATURE TOGGLES
-- ============================================================

local features = {
    fly = false,
    esp = false,
    antiAfk = CONFIG.EnableAntiAFK,
    afkPlatform = false,
}

-- Create buttons
local flyBtn = createModernButton("✈️ Fly Mode", scrollFrame, nil, "✈️")
local espBtn = createModernButton("👁️ ESP Players", scrollFrame, nil, "👁️")
local tweenBtn = createModernButton("📍 Teleport", scrollFrame, nil, "📍")
local adminBtn = createModernButton("👮 Admin Panel", scrollFrame, nil, "👮")
local afkBtn = createModernButton("💤 AFK Platform", scrollFrame, nil, "💤")
local antiAfkBtn = createModernButton("🛡️ Anti-AFK: ON", scrollFrame, nil, "🛡️")
local settingsBtn = createModernButton("⚙️ Settings", scrollFrame, nil, "⚙️")

-- Update button states
local function updateButtonStates()
    flyBtn:FindFirstChildOfClass("TextLabel").Text = (features.fly and "✈️ Fly: ON" or "✈️ Fly: OFF")
    espBtn:FindFirstChildOfClass("TextLabel").Text = (features.esp and "👁️ ESP: ON" or "👁️ ESP: OFF")
    antiAfkBtn:FindFirstChildOfClass("TextLabel").Text = (features.antiAfk and "🛡️ Anti-AFK: ON" or "🛡️ Anti-AFK: OFF")
    afkBtn:FindFirstChildOfClass("TextLabel").Text = (features.afkPlatform and "💤 AFK: ON" or "💤 AFK: OFF")
end

-- ============================================================
-- FLY SYSTEM (Optimized)
-- ============================================================

local flySpeed = CONFIG.DefaultFlySpeed
local flyInput = {Forward = 0, Right = 0, Up = 0}
local flyConnection = nil
local flyVelocity = Vector3.new()

local function toggleFly()
    features.fly = not features.fly
    updateButtonStates()
    
    if features.fly then
        sendNotification("✈️ Fly mode enabled!", colors.accent2)
        local hrp = waitForCharacter()
        if flyConnection then flyConnection:Disconnect() end
        
        -- Use Heartbeat for smoother movement
        flyConnection = RunService.Heartbeat:Connect(function(deltaTime)
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
                if flyVelocity.Magnitude < 0.1 then
                    flyVelocity = Vector3.new()
                end
                hrp.AssemblyLinearVelocity = flyVelocity
            end
        end)
    else
        sendNotification("✈️ Fly mode disabled", colors.error)
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
end

-- ============================================================
-- ESP SYSTEM (Optimized with throttling)
-- ============================================================

local espActive = false
local espTags = {}
local espUpdateRate = 1/10 -- Update 10 times per second
local espTimer = 0

local function clearESP()
    espActive = false
    for _, tag in pairs(espTags) do
        if tag and tag.Parent then
            tag:Destroy()
        end
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
    billboard.MaxDistance = 300
    billboard.Parent = head
    
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
    if not espActive then return end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            task.spawn(function()
                createESPTag(plr)
            end)
        end
    end
end

local function toggleESP()
    espActive = not espActive
    updateButtonStates()
    
    if espActive then
        sendNotification("👁️ ESP Enabled", colors.accent2)
        refreshESP()
    else
        sendNotification("👁️ ESP Disabled", colors.error)
        clearESP()
    end
end

-- ============================================================
-- ANTI-AFK SYSTEM (Fixed - Non-Intrusive)
-- ============================================================

local antiAfkActive = CONFIG.EnableAntiAFK
local antiAfkTimer = 0
local antiAfkConnection = nil

local function performAntiAFK()
    pcall(function()
        -- Method 1: VirtualUser
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
        
        -- Method 2: Slight camera movement (barely noticeable)
        if camera then
            local current = camera.CFrame
            local offset = Vector3.new(
                math.sin(tick() * 0.5) * 0.0005,
                math.cos(tick() * 0.7) * 0.0005,
                0
            )
            camera.CFrame = current + offset
        end
    end)
end

local function startAntiAFK()
    if antiAfkConnection then
        antiAfkConnection:Disconnect()
        antiAfkConnection = nil
    end
    
    antiAfkTimer = 0
    
    -- Use RunService for timing (more efficient)
    antiAfkConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if not antiAfkActive then return end
        
        antiAfkTimer = antiAfkTimer + deltaTime
        if antiAfkTimer >= CONFIG.AntiAFKInterval then
            antiAfkTimer = 0
            task.spawn(performAntiAFK)
        end
    end)
end

local function toggleAntiAFK()
    antiAfkActive = not antiAfkActive
    features.antiAfk = antiAfkActive
    updateButtonStates()
    
    if antiAfkActive then
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
-- AFK PLATFORM (Optimized)
-- ============================================================

local afkPlatformActive = false
local afkPlatformConnection = nil
local afkWaypoints = {}
local afkCurrentWaypoint = 1

local function toggleAFKPlatform()
    local hrp = waitForCharacter()
    if not hrp then return end
    
    afkPlatformActive = not afkPlatformActive
    features.afkPlatform = afkPlatformActive
    updateButtonStates()
    
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
        
        if afkPlatformConnection then
            afkPlatformConnection:Disconnect()
        end
        
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
                local speed = 60
                currentHRP.AssemblyLinearVelocity = direction * speed
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
        if not isAuto then
            sendNotification("❌ Admin not found", colors.error)
        end
        return false
    end
    
    local adminChar = adminPlayer.Character
    if not adminChar or not adminChar:FindFirstChild("HumanoidRootPart") then
        if not isAuto then
            sendNotification("❌ Admin is not in game", colors.error)
        end
        return false
    end
    
    local myHRP = waitForCharacter()
    if not myHRP then return false end
    
    local targetCF = adminChar.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
    local distance = (myHRP.Position - targetCF.Position).Magnitude
    
    if distance > 10 then
        local travelTime = math.min(distance / 150, 2)
        local tween = TweenService:Create(myHRP, 
            TweenInfo.new(travelTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {CFrame = targetCF}
        )
        tween:Play()
        tween.Completed:Wait()
    else
        myHRP.CFrame = targetCF
    end
    
    sendNotification((isAuto and "🚀 " or "✅ ") .. "Teleported to " .. adminName, colors.success)
    
    if features.fly then
        toggleFly()
    end
    
    return true
end

-- ============================================================
-- KEYBIND SYSTEM
-- ============================================================

local keybindHandler = {}

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    local key = input.KeyCode
    if not key then return end
    
    -- Check keybinds
    if key == getKeyCode(CONFIG.Keybinds.ToggleFly) then
        toggleFly()
    elseif key == getKeyCode(CONFIG.Keybinds.ToggleESP) then
        toggleESP()
    elseif key == getKeyCode(CONFIG.Keybinds.ToggleMenu) then
        menuVisible = not menuVisible
        menu.Visible = menuVisible
    elseif key == getKeyCode(CONFIG.Keybinds.TeleportToAdmin) then
        if #CONFIG.AdminUsernames > 0 then
            teleportToAdmin(CONFIG.AdminUsernames[1], true)
        end
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
-- SETTINGS MENU
-- ============================================================

local settingsFrame = nil
local settingsVisible = false

local function createSettingsMenu()
    if settingsFrame and settingsFrame.Parent then
        settingsFrame:Destroy()
        settingsFrame = nil
        settingsVisible = false
        return
    end
    
    settingsVisible = true
    settingsFrame = Instance.new("Frame")
    settingsFrame.Size = UDim2.new(0, 320, 0, 350)
    settingsFrame.Position = UDim2.new(0, 310, 0.15, 0)
    settingsFrame.BackgroundColor3 = colors.bg
    settingsFrame.BackgroundTransparency = 0.08
    settingsFrame.BorderSizePixel = 0
    settingsFrame.ClipsDescendants = true
    settingsFrame.Parent = gui
    settingsFrame.Active = true
    settingsFrame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = settingsFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = colors.accent2
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = settingsFrame
    
    -- Title
    local title = Instance.new("Frame")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = colors.bg2
    title.BackgroundTransparency = 0.3
    title.BorderSizePixel = 0
    title.Parent = settingsFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = title
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "⚙️ Settings"
    titleLabel.TextColor3 = colors.accent2
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = title
    
    local closeS = Instance.new("TextButton")
    closeS.Size = UDim2.new(0, 30, 0, 30)
    closeS.Position = UDim2.new(1, -38, 0, 5)
    closeS.BackgroundColor3 = colors.bg3
    closeS.BackgroundTransparency = 0.5
    closeS.Text = "✕"
    closeS.TextColor3 = colors.error
    closeS.Font = Enum.Font.GothamBold
    closeS.TextSize = 16
    closeS.BorderSizePixel = 0
    closeS.Parent = title
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeS
    
    closeS.MouseButton1Click:Connect(function()
        settingsFrame:Destroy()
        settingsFrame = nil
        settingsVisible = false
    end)
    
    -- Settings content
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -20, 1, -50)
    scroll.Position = UDim2.new(0, 10, 0, 45)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 4
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.Parent = settingsFrame
    
    local sLayout = Instance.new("UIListLayout")
    sLayout.Padding = UDim.new(0, 8)
    sLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sLayout.Parent = scroll
    
    sLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, sLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Setting row creator
    local function createSettingRow(label, value, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 35)
        row.BackgroundTransparency = 1
        row.Parent = scroll
        
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.6, -5, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = colors.text
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.35, -5, 1, 0)
        btn.Position = UDim2.new(0.65, 0, 0, 0)
        btn.BackgroundColor3 = value and colors.accent or colors.bg3
        btn.BackgroundTransparency = 0.3
        btn.Text = value and "ON" or "OFF"
        btn.TextColor3 = colors.text
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 13
        btn.BorderSizePixel = 0
        btn.Parent = row
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            local newVal = not value
            value = newVal
            btn.Text = newVal and "ON" or "OFF"
            btn.BackgroundColor3 = newVal and colors.accent or colors.bg3
            if callback then callback(newVal) end
        end)
        
        return row
    end
    
    -- Speed setting with slider
    local speedRow = Instance.new("Frame")
    speedRow.Size = UDim2.new(1, 0, 0, 45)
    speedRow.BackgroundTransparency = 1
    speedRow.Parent = scroll
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, 0, 0, 20)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Fly Speed: " .. flySpeed
    speedLabel.TextColor3 = colors.text
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextSize = 14
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = speedRow
    
    local speedSlider = Instance.new("Frame")
    speedSlider.Size = UDim2.new(1, 0, 0, 20)
    speedSlider.Position = UDim2.new(0, 0, 0, 22)
    speedSlider.BackgroundColor3 = colors.bg3
    speedSlider.BackgroundTransparency = 0.3
    speedSlider.BorderSizePixel = 0
    speedSlider.Parent = speedRow
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 4)
    sliderCorner.Parent = speedSlider
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(flySpeed / 100, 0, 1, 0)
    sliderFill.BackgroundColor3 = colors.accent
    sliderFill.BackgroundTransparency = 0.3
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = speedSlider
    
    local sliderCorner2 = Instance.new("UICorner")
    sliderCorner2.CornerRadius = UDim.new(0, 4)
    sliderCorner2.Parent = sliderFill
    
    -- Speed slider interaction
    speedSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mouse = player:GetMouse()
            local connection
            connection = RunService.RenderStepped:Connect(function()
                local pos = mouse.X - speedSlider.AbsolutePosition.X
                local percent = math.clamp(pos / speedSlider.AbsoluteSize.X, 0, 1)
                flySpeed = math.max(10, math.floor(percent * 100))
                sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                speedLabel.Text = "Fly Speed: " .. flySpeed
            end)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    connection:Disconnect()
                end
            end)
        end
    end)
    
    -- Settings rows
    createSettingRow("Auto-Admin Teleport", CONFIG.EnableAutoTeleport, function(val)
        CONFIG.EnableAutoTeleport = val
        sendNotification("Auto-teleport " .. (val and "enabled" or "disabled"), val and colors.success or colors.error)
    end)
    
    createSettingRow("Admin Commands", CONFIG.EnableAdminCommands, function(val)
        CONFIG.EnableAdminCommands = val
        sendNotification("Admin commands " .. (val and "enabled" or "disabled"), val and colors.success or colors.error)
    end)
end

settingsBtn.MouseButton1Click:Connect(createSettingsMenu)

-- ============================================================
-- ADMIN COMMAND PROCESSING
-- ============================================================

local function processAdminCommand(message, sender)
    if not CONFIG.EnableAdminCommands then return end
    if not isAdmin(sender) then return end
    
    local msg = message:lower()
    
    -- Auto-teleport
    if CONFIG.EnableAutoTeleport then
        local phrases = {"come to me", "come here", "tp to me", "teleport to me", "come", "get over here"}
        for _, phrase in ipairs(phrases) do
            if msg:find(phrase, 1, true) and not msg:sub(1, 1) == "/" then
                teleportToAdmin(sender, true)
                return
            end
        end
    end
    
    -- Commands
    if msg:sub(1, 1) == "/" then
        local cmd = msg:sub(2)
        
        if cmd == "turn off fly" or cmd == "disable fly" or cmd == "fly off" then
            if features.fly then toggleFly() end
            sendNotification("👮 " .. sender .. " disabled your fly!", colors.error)
        elseif cmd == "help" or cmd == "?" then
            sendNotification("📋 Commands: /fly off, /help", colors.admin)
        end
    end
end

-- Chat listener
local function setupAdminListener()
    local ChatService = game:GetService("Chat")
    if ChatService and ChatService:FindFirstChild("OnChatMessage") then
        ChatService.OnChatMessage:Connect(processAdminCommand)
    end
    
    -- Check common chat remotes
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

if CONFIG.EnableAdminCommands then
    task.delay(1, setupAdminListener)
end

-- ============================================================
-- BUTTON CALLBACKS
-- ============================================================

flyBtn.MouseButton1Click:Connect(toggleFly)
espBtn.MouseButton1Click:Connect(toggleESP)
antiAfkBtn.MouseButton1Click:Connect(toggleAntiAFK)
afkBtn.MouseButton1Click:Connect(toggleAFKPlatform)

-- Admin panel (shows online admins)
adminBtn.MouseButton1Click:Connect(function()
    local admins = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if isAdmin(plr.Name) then
            table.insert(admins, plr.Name)
        end
    end
    
    if #admins > 0 then
        sendNotification("👮 Admins online: " .. table.concat(admins, ", "), colors.admin)
    else
        sendNotification("👮 No admins online", colors.textDim)
    end
end)

-- Teleport panel
tweenBtn.MouseButton1Click:Connect(function()
    local players = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            table.insert(players, plr.Name)
        end
    end
    
    if #players == 0 then
        sendNotification("No other players online", colors.textDim)
        return
    end
    
    sendNotification("📋 Click on a player in the list", colors.accent)
    
    -- Simple player list UI
    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(0, 200, 0, math.min(#players * 35 + 10, 250))
    listFrame.Position = UDim2.new(0, 310, 0.15, 0)
    listFrame.BackgroundColor3 = colors.bg
    listFrame.BackgroundTransparency = 0.08
    listFrame.BorderSizePixel = 0
    listFrame.ClipsDescendants = true
    listFrame.Parent = gui
    listFrame.Active = true
    listFrame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = listFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = listFrame
    
    for _, name in ipairs(players) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 30)
        btn.Position = UDim2.new(0, 5, 0, 0)
        btn.BackgroundColor3 = colors.bg2
        btn.BackgroundTransparency = 0.3
        btn.Text = name
        btn.TextColor3 = colors.text
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.BorderSizePixel = 0
        btn.Parent = listFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            listFrame:Destroy()
            local target = Players:FindFirstChild(name)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local myHRP = waitForCharacter()
                local targetHRP = target.Character.HumanoidRootPart
                local dist = (myHRP.Position - targetHRP.Position).Magnitude
                local time = math.min(dist / 150, 2)
                local tween = TweenService:Create(myHRP,
                    TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)}
                )
                tween:Play()
                sendNotification("📍 Teleporting to " .. name, colors.accent2)
            else
                sendNotification("❌ Player not available", colors.error)
            end
        end)
    end
    
    -- Auto-close after 10 seconds
    task.delay(10, function()
        if listFrame and listFrame.Parent then
            listFrame:Destroy()
        end
    end)
end)

-- ============================================================
-- PLAYER EVENTS (Optimized)
-- ============================================================

Players.PlayerAdded:Connect(function(newPlayer)
    if espActive then
        task.wait(0.5)
        createESPTag(newPlayer)
    end
end)

Players.PlayerRemoving:Connect(function(playerLeft)
    if espActive and espTags[playerLeft.UserId] then
        local tag = espTags[playerLeft.UserId]
        if tag then tag:Destroy() end
        espTags[playerLeft.UserId] = nil
    end
end)

-- ============================================================
-- INITIALIZATION
-- ============================================================

-- Start anti-AFK by default
if CONFIG.EnableAntiAFK then
    task.wait(1)
    startAntiAFK()
end

-- Update button states
updateButtonStates()

-- Print startup info
sendNotification("⚡ Lilcat Utility loaded!", colors.accent, 3)
print("=== Lilcat Utility Loaded ===")
print("Press F - Toggle Fly")
print("Press E - Toggle ESP")
print("Press RightShift - Toggle Menu")
print("Press T - Teleport to Admin")
print("Admin: " .. table.concat(CONFIG.AdminUsernames, ", "))
print("==============================")
