local a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p = game.Players.LocalPlayer, game:GetService('Players'), game:GetService('RunService'), game:GetService('TweenService'), game:GetService('ReplicatedStorage'), false, false, false, nil, nil, {}, false, 'Coin', false, false, nil

getgenv().OldPos = nil
getgenv().FPDH = workspace.FallenPartsDestroyHeight

local function setupCharacterCollision(q)
    local function disableCollide(r)
        if f and r:IsA('BasePart') then
            r.CanCollide = false
        end
    end

    for r, s in ipairs(q:GetChildren())do
        disableCollide(s)
    end

    local r, s = q.ChildAdded:Connect(disableCollide), c.Stepped:Connect(function(
    )
        if f and q:IsDescendantOf(workspace) then
            for r, s in ipairs(q:GetChildren())do
                if s:IsA('BasePart') and s.CanCollide then
                    s.CanCollide = false
                end
            end
        end
    end)

    q.Destroying:Connect(function()
        r:Disconnect()
        s:Disconnect()
    end)
end
local function trackPlayer(q)
    if q == a then
        return
    end

    q.CharacterAdded:Connect(setupCharacterCollision)

    if q.Character then
        setupCharacterCollision(q.Character)
    end
end

for q, r in ipairs(b:GetPlayers())do
    trackPlayer(r)
end

b.PlayerAdded:Connect(trackPlayer)

local q, r, s = game:GetService('UserInputService'), pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/tontov/ScriptLibrary/refs/heads/main/Main'))()
end)

if not r or not s then
    warn('Failed to load UI library')

    return
end
if s.ShowLoading then
    local t = s:ShowLoading()

    while not t() do
        task.wait()
    end
end

local t, u = s:CreateWindow({
    Title = '???',
    Theme = 'Dark',
    Size = UDim2.fromOffset(570, 370),
    Transparency = 0.2,
    Blurring = true,
    MinimizeKeybind = Enum.KeyCode.LeftAlt,
}), {
    Light = {
        Primary = Color3.fromRGB(232, 232, 232),
        Secondary = Color3.fromRGB(255, 255, 255),
        Component = Color3.fromRGB(245, 245, 245),
        Interactables = Color3.fromRGB(235, 235, 235),
        Tab = Color3.fromRGB(50, 50, 50),
        Title = Color3.fromRGB(0, 0, 0),
        Description = Color3.fromRGB(100, 100, 100),
        Shadow = Color3.fromRGB(255, 255, 255),
        Outline = Color3.fromRGB(210, 210, 210),
        Icon = Color3.fromRGB(100, 100, 100),
    },
    Dark = {
        Primary = Color3.fromRGB(30, 30, 30),
        Secondary = Color3.fromRGB(35, 35, 35),
        Component = Color3.fromRGB(40, 40, 40),
        Interactables = Color3.fromRGB(45, 45, 45),
        Tab = Color3.fromRGB(200, 200, 200),
        Title = Color3.fromRGB(240, 240, 240),
        Description = Color3.fromRGB(200, 200, 200),
        Shadow = Color3.fromRGB(0, 0, 0),
        Outline = Color3.fromRGB(40, 40, 40),
        Icon = Color3.fromRGB(220, 220, 220),
    },
    Void = {
        Primary = Color3.fromRGB(15, 15, 15),
        Secondary = Color3.fromRGB(20, 20, 20),
        Component = Color3.fromRGB(25, 25, 25),
        Interactables = Color3.fromRGB(30, 30, 30),
        Tab = Color3.fromRGB(200, 200, 200),
        Title = Color3.fromRGB(240, 240, 240),
        Description = Color3.fromRGB(200, 200, 200),
        Shadow = Color3.fromRGB(0, 0, 0),
        Outline = Color3.fromRGB(40, 40, 40),
        Icon = Color3.fromRGB(220, 220, 220),
    },
}

t:SetTheme(u.Dark)

local v = t:AddTab({
    Title = 'Main',
    Icon = 'rbxassetid://11963373994',
})

t:AddSection({
    Name = 'Murder Functions',
    Tab = v,
})

local w = false

t:AddToggle({
    Title = 'Auto Kill All',
    Description = 'Automatically kill all players when you are murderer',
    Default = false,
    Tab = v,
    Callback = function(x)
        w = x
    end,
})
t:AddButton({
    Title = 'Kill All',
    Description = 'Kill All Innocents',
    Tab = v,
    Callback = function()
        if not a then
            return
        end

        local x = a.Character

        if not x or not x.Parent then
            return
        end

        local y = x:FindFirstChild('Knife')

        if not y then
            y = a.Backpack:FindFirstChild('Knife')

            if y then
                y.Parent = x
            else
                t:Notify({
                    Title = 'No Knife',
                    Description = 'You need to be the murderer!',
                    Duration = 3,
                })

                return
            end
        end

        for z, A in pairs(game.Players:GetPlayers())do
            if A ~= a and A.Character and A.Character:FindFirstChild('Head') then
                pcall(function()
                    y.Events.KnifeStabbed:FireServer()
                    y.Events.HandleTouched:FireServer(A.Character.Head)
                end)
                task.wait(0.05)
            end
        end

        t:Notify({
            Title = 'Kill All',
            Description = 'Attempted to kill all players',
            Duration = 2,
        })
    end,
})
task.spawn(function()
    while true do
        task.wait(0.5)

        if w and not autoKillWhenFull and a and a.Character then
            local x = a.Character:FindFirstChild('Knife') or a.Backpack:FindFirstChild('Knife')

            if x then
                if x.Parent == a.Backpack then
                    x.Parent = a.Character
                end

                for y, z in pairs(game.Players:GetPlayers())do
                    if z ~= a and z.Character and z.Character:FindFirstChild('Head') then
                        pcall(function()
                            x.Events.KnifeStabbed:FireServer()
                            x.Events.HandleTouched:FireServer(z.Character.Head)
                        end)
                        task.wait(0.05)
                    end
                end
            end
        end
    end
end)

local function getPlayerRole()
    local x = game:GetService('ReplicatedStorage')
    local y = x:FindFirstChild('GetPlayerData', true)

    if not y then
        return nil
    end

    local z, A = pcall(function()
        return y:InvokeServer()
    end)

    if not z or not A then
        return nil
    end

    local B = A[a.Name]

    if B and B.Role then
        return B.Role
    end

    return nil
end
local function isMurderer()
    return getPlayerRole() == 'Murderer'
end

t:AddSection({
    Name = 'Sheriff Functions',
    Tab = v,
})

local x, y, z, A, B, C, D, E = false, false, nil, false, nil, nil, 1.25, false

local function getPing()
    local F = game:GetService('Stats')
    local G = F.Network.ServerStatsItem['Data Ping']:GetValue()

    return G
end
local function findMurderer()
    local F = game:GetService('ReplicatedStorage')
    local G = F:FindFirstChild('GetPlayerData', true)

    if not G then
        return nil
    end

    local H, I = pcall(function()
        return G:InvokeServer()
    end)

    if not H then
        return nil
    end
    if not I then
        return nil
    end

    for J, K in ipairs(b:GetPlayers())do
        if K ~= b.LocalPlayer and K:GetAttribute('Alive') == true then
            local L = I[K.Name]

            if L and L.Role then
                if L.Role == 'Murderer' then
                    return K
                end
            end
        end
    end

    return nil
end
local function shootMurderer()
    local F = nil

    if a.Character and a.Character:FindFirstChild('Gun') then
        F = a.Character.Gun
    elseif a.Backpack and a.Backpack:FindFirstChild('Gun') then
        F = a.Backpack.Gun
        F.Parent = a.Character
    end
    if not F then
        return false
    end

    local G = findMurderer()

    if not G then
        return false
    end

    local H = G.Character

    if not H or not H:FindFirstChild('HumanoidRootPart') then
        return false
    end

    local I, J, K = H.HumanoidRootPart, H:FindFirstChild('Torso') or H:FindFirstChild('UpperTorso'), H:FindFirstChild('Humanoid')

    if not J or not K then
        return false
    end
    if not a.Character or not a.Character:FindFirstChild('HumanoidRootPart') then
        return false
    end

    local L, M = a.Character.HumanoidRootPart, getPing()
    local N, O = (M / 1000) * D, I.Velocity
    local P, Q = O.Magnitude, nil

    if P < 1 then
        Q = J.Position
    else
        Q = J.Position + (O * N)
    end

    local R

    if E then
        R = CFrame.new(J.Position, Q)
    else
        R = CFrame.new(L.Position, Q)
    end

    local S, T = CFrame.new(Q), F:FindFirstChild('ShootEvent') or F:FindFirstChild('Shoot')

    if T then
        T:FireServer(R, S)

        return true
    end

    return false
end
local function createShootButton()
    if z then
        return
    end

    local F = Instance.new('ScreenGui')

    F.Name = 'ShootButtonGui'
    F.ResetOnSpawn = false
    F.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    F.Parent = game:GetService('CoreGui')

    local G = Instance.new('ImageButton')

    G.Name = 'ShootButton'
    G.Size = UDim2.new(0, 80, 0, 80)
    G.Position = UDim2.new(0.5, -40, 0.5, -40)
    G.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    G.BackgroundTransparency = 0.3
    G.BorderSizePixel = 0
    G.Parent = F

    local H = Instance.new('UICorner')

    H.CornerRadius = UDim.new(1, 0)
    H.Parent = G

    local I = Instance.new('TextLabel')

    I.Size = UDim2.new(1, 0, 1, 0)
    I.BackgroundTransparency = 1
    I.Text = '\u{1f52b}'
    I.TextSize = 32
    I.TextColor3 = Color3.fromRGB(255, 255, 255)
    I.Font = Enum.Font.GothamBold
    I.Parent = G

    G.InputBegan:Connect(function(J)
        if J.UserInputType == Enum.UserInputType.MouseButton1 or J.UserInputType == Enum.UserInputType.Touch then
            A = true
            B = J.Position
            C = G.Position

            J.Changed:Connect(function()
                if J.UserInputState == Enum.UserInputState.End then
                    A = false
                end
            end)
        end
    end)
    G.InputChanged:Connect(function(J)
        if J.UserInputType == Enum.UserInputType.MouseMovement or J.UserInputType == Enum.UserInputType.Touch then
            if A then
                local K = J.Position - B

                G.Position = UDim2.new(C.X.Scale, C.X.Offset + K.X, C.Y.Scale, C.Y.Offset + K.Y)
            end
        end
    end)
    G.MouseButton1Click:Connect(function()
        if not A then
            shootMurderer()
        end
    end)

    z = F
end
local function removeShootButton()
    if z then
        z:Destroy()

        z = nil
    end
end

t:AddToggle({
    Title = 'Auto Shoot Murderer',
    Description = 'Automatically shoot the murderer',
    Default = false,
    Tab = v,
    Callback = function(F)
        y = F
    end,
})
task.spawn(function()
    while true do
        task.wait(0.1)

        if y then
            shootMurderer()
        end
    end
end)
t:AddToggle({
    Title = 'Auto Shoot Button',
    Description = 'Creates a draggable button to shoot the murderer',
    Default = false,
    Tab = v,
    Callback = function(F)
        x = F

        if F then
            createShootButton()
        else
            removeShootButton()
        end
    end,
})
t:AddToggle({
    Title = 'Magic Bullet',
    Description = 'First argument will be set to murderer position',
    Default = false,
    Tab = v,
    Callback = function(F)
        E = F
    end,
})
t:AddSection({
    Name = 'Innocent Functions',
    Tab = v,
})
t:AddToggle({
    Title = 'Auto Grab Gun',
    Description = 'Automatically grabbing gun if sheriff died',
    Default = false,
    Tab = v,
    Callback = function(F)
        g = F
    end,
})
t:AddSection({
    Name = 'Auto Farm',
    Tab = v,
})

local function returncoincontainer()
    for F, G in pairs(workspace:GetChildren())do
        if G:FindFirstChild('CoinContainer') and G:IsA('Model') then
            return G:FindFirstChild('CoinContainer')
        end
    end

    return nil
end
local function FindNearestCoin(F)
    if not F then
        return nil, math.huge
    end

    local G, H = nil, math.huge

    for I, J in pairs(F:GetChildren())do
        if J:GetAttribute('CoinID') == 'Coin' and J:FindFirstChild('TouchInterest') and J.Transparency == 1 then
            if a.Character and a.Character:FindFirstChild('HumanoidRootPart') then
                local K = (a.Character.HumanoidRootPart.Position - J.Position).Magnitude

                if K < H then
                    G = J
                    H = K
                end
            end
        end
    end

    return G, H
end

t:AddToggle({
    Title = 'Farm Coins',
    Description = 'Automatically farm coins with noclip',
    Default = false,
    Tab = v,
    Callback = function(F)
        h = F

        if not F then
            l = false
        end
    end,
})

local F = t:AddTab({
    Title = 'Visuals',
    Icon = 'rbxassetid://11963373994',
})

t:AddSection({
    Name = 'Chams',
    Tab = F,
})
t:AddToggle({
    Title = 'Chams Murderer',
    Description = 'Enable Chams for Murderer',
    Default = false,
    Tab = F,
    Callback = function(G)
        ESP_SETTINGS.Murderer = G
    end,
})
t:AddToggle({
    Title = 'Chams Sheriff',
    Description = 'Enable Chams for Sheriff',
    Default = false,
    Tab = F,
    Callback = function(G)
        ESP_SETTINGS.Sheriff = G
    end,
})
t:AddToggle({
    Title = 'Chams Innocent',
    Description = 'Enable Chams for Innocent',
    Default = false,
    Tab = F,
    Callback = function(G)
        ESP_SETTINGS.Innocent = G
    end,
})
t:AddToggle({
    Title = 'Chams Hero',
    Description = 'Enable Chams for Hero',
    Default = false,
    Tab = F,
    Callback = function(G)
        ESP_SETTINGS.Hero = G
    end,
})
t:AddSection({
    Name = 'ESP',
    Tab = F,
})
t:AddToggle({
    Title = 'ESP Murderer',
    Description = 'Show Murderer name above head',
    Default = false,
    Tab = F,
    Callback = function(G)
        NAME_ESP_SETTINGS.Murderer = G
    end,
})
t:AddToggle({
    Title = 'ESP Sheriff',
    Description = 'Show Sheriff name above head',
    Default = false,
    Tab = F,
    Callback = function(G)
        NAME_ESP_SETTINGS.Sheriff = G
    end,
})
t:AddToggle({
    Title = 'ESP Innocent',
    Description = 'Show Innocent name above head',
    Default = false,
    Tab = F,
    Callback = function(G)
        NAME_ESP_SETTINGS.Innocent = G
    end,
})
t:AddToggle({
    Title = 'ESP Hero',
    Description = 'Show Hero name above head',
    Default = false,
    Tab = F,
    Callback = function(G)
        NAME_ESP_SETTINGS.Hero = G
    end,
})
t:AddSection({
    Name = 'ESP Customization',
    Tab = F,
})
t:AddToggle({
    Title = '2D Box',
    Description = 'Show 2D box around player',
    Default = false,
    Tab = F,
    Callback = function(G)
        ESP_CUSTOMIZATION.Box2D = G
    end,
})
t:AddToggle({
    Title = 'Display Name',
    Description = 'Show display name instead of username',
    Default = false,
    Tab = F,
    Callback = function(G)
        ESP_CUSTOMIZATION.DisplayName = G

        if G then
            ESP_CUSTOMIZATION.NormalName = false
        end
    end,
})
t:AddToggle({
    Title = 'Normal Name',
    Description = 'Show normal username',
    Default = true,
    Tab = F,
    Callback = function(G)
        ESP_CUSTOMIZATION.NormalName = G

        if G then
            ESP_CUSTOMIZATION.DisplayName = false
        end
    end,
})
t:AddToggle({
    Title = 'Avatar Display',
    Description = 'Show player avatar above name',
    Default = false,
    Tab = F,
    Callback = function(G)
        ESP_CUSTOMIZATION.AvatarDisplay = G
    end,
})

local G = t:AddTab({
    Title = 'Misc',
    Icon = 'rbxassetid://11963373994',
})

t:AddToggle({
    Title = 'Anti-Fling',
    Description = 'Anti-Fling',
    Tab = G,
    Callback = function(H)
        f = H
    end,
})
t:AddSection({
    Name = 'Character Modifiers',
    Tab = G,
})

local H, I, J, K = false, false, 16, 50

local function applyWalkSpeed()
    if H and a.Character then
        local L = a.Character:FindFirstChildOfClass('Humanoid')

        if L then
            L.WalkSpeed = J
        end
    end
end
local function applyJumpPower()
    if I and a.Character then
        local L = a.Character:FindFirstChildOfClass('Humanoid')

        if L then
            L.JumpPower = K
        end
    end
end

task.spawn(function()
    while true do
        c.Heartbeat:Wait()

        if H then
            applyWalkSpeed()
        end
        if I then
            applyJumpPower()
        end
    end
end)
a.CharacterAdded:Connect(function(L)
    L:WaitForChild('Humanoid')
    task.wait(0.1)

    if H then
        applyWalkSpeed()
    end
    if I then
        applyJumpPower()
    end
end)
t:AddToggle({
    Title = 'Custom WalkSpeed',
    Description = 'Enable custom walk speed',
    Default = false,
    Tab = G,
    Callback = function(L)
        H = L

        if L then
            applyWalkSpeed()
        else
            if a.Character then
                local M = a.Character:FindFirstChildOfClass('Humanoid')

                if M then
                    M.WalkSpeed = 16
                end
            end
        end
    end,
})
t:AddSlider({
    Title = 'WalkSpeed Value',
    Description = 'Set custom walk speed value',
    Tab = G,
    Default = 16,
    MinValue = 16,
    MaxValue = 200,
    AllowDecimals = false,
    Callback = function(L)
        J = L

        if H then
            applyWalkSpeed()
        end
    end,
})
t:AddToggle({
    Title = 'Custom JumpPower',
    Description = 'Enable custom jump power',
    Default = false,
    Tab = G,
    Callback = function(L)
        I = L

        if L then
            applyJumpPower()
        else
            if a.Character then
                local M = a.Character:FindFirstChildOfClass('Humanoid')

                if M then
                    M.JumpPower = 50
                end
            end
        end
    end,
})
t:AddSlider({
    Title = 'JumpPower Value',
    Description = 'Set custom jump power value',
    Tab = G,
    Default = 50,
    MinValue = 50,
    MaxValue = 200,
    AllowDecimals = false,
    Callback = function(L)
        K = L

        if I then
            applyJumpPower()
        end
    end,
})

local L, M = false, 70

local function applyFOV()
    if L then
        local N = workspace.CurrentCamera

        if N then
            N.FieldOfView = M
        end
    end
end

task.spawn(function()
    while true do
        c.Heartbeat:Wait()

        if L then
            applyFOV()
        end
    end
end)
t:AddToggle({
    Title = 'Custom FOV',
    Description = 'Enable custom field of view',
    Default = false,
    Tab = G,
    Callback = function(N)
        L = N

        if N then
            applyFOV()
        else
            local O = workspace.CurrentCamera

            if O then
                O.FieldOfView = 70
            end
        end
    end,
})
t:AddSlider({
    Title = 'FOV Value',
    Description = 'Set custom field of view value',
    Tab = G,
    Default = 70,
    MinValue = 70,
    MaxValue = 120,
    AllowDecimals = false,
    Callback = function(N)
        M = N

        if L then
            applyFOV()
        end
    end,
})

local N = false

local function applyForceFieldMaterial()
    if not N then
        return
    end
    if not a.Character then
        return
    end

    for O, P in pairs(a.Character:GetDescendants())do
        if P:IsA('BasePart') or P:IsA('MeshPart') then
            P.Material = Enum.Material.ForceField
        end
    end
end

task.spawn(function()
    while true do
        c.Heartbeat:Wait()

        if N then
            applyForceFieldMaterial()
        end
    end
end)
a.CharacterAdded:Connect(function(O)
    O:WaitForChild('Humanoid')
    task.wait(0.1)

    if N then
        applyForceFieldMaterial()
    end
end)
t:AddToggle({
    Title = 'Force Field Body Parts',
    Description = 'Set all body parts material to ForceField',
    Default = false,
    Tab = G,
    Callback = function(O)
        N = O

        if O then
            applyForceFieldMaterial()
            t:Notify({
                Title = 'ForceField Enabled',
                Description = 'Body parts material set to ForceField',
                Duration = 2,
            })
        else
            if a.Character then
                for P, Q in pairs(a.Character:GetDescendants())do
                    if Q:IsA('BasePart') or Q:IsA('MeshPart') then
                        Q.Material = Enum.Material.Plastic
                    end
                end
            end

            t:Notify({
                Title = 'ForceField Disabled',
                Description = 'Body parts material restored',
                Duration = 2,
            })
        end
    end,
})

local O, P = t:AddTab({
    Title = 'Spawner',
    Icon = 'rbxassetid://11963373994',
}), {
    {
        original = 'Harvester',
        custom = 'Harvester',
    },
    {
        original = 'Gingerscope',
        custom = 'Gingerscope',
    },
    {
        original = 'Snowcannon',
        custom = 'Snowcannon',
    },
    {
        original = 'Bauble',
        custom = 'Bauble',
    },
    {
        original = 'BaubleChroma',
        custom = 'BaubleChroma',
    },
    {
        original = 'Icepiercer',
        custom = 'Icepiercer',
    },
    {
        original = 'TreeGun2023',
        custom = 'Evergun',
    },
    {
        original = 'TreeKnife2023',
        custom = 'Evergreen',
    },
    {
        original = 'TreeGun2023Chroma',
        custom = 'Chroma Evergun',
    },
    {
        original = 'TreeKnife2023Chroma',
        custom = 'Chroma Evergreen',
    },
    {
        original = 'Bloom',
        custom = 'Bloom',
    },
    {
        original = 'Flora',
        custom = 'Flora',
    },
    {
        original = 'TravelerAxe',
        custom = 'Traveler Axe',
    },
    {
        original = 'TravelerGun',
        custom = 'Traveler Gun',
    },
    {
        original = 'TravelerAxeChroma',
        custom = 'Chroma Traveler Axe',
    },
    {
        original = 'TravelerGunChroma',
        custom = 'Chroma Traveler Gun',
    },
    {
        original = 'Celestial',
        custom = 'Celestial',
    },
    {
        original = 'Constellation',
        custom = 'Constellation',
    },
    {
        original = 'ConstellationChroma',
        custom = 'Chroma Constellation',
    },
    {
        original = 'Candy',
        custom = 'Candy',
    },
    {
        original = 'Sugar',
        custom = 'Sugar',
    },
    {
        original = 'Darksword',
        custom = 'Darksword',
    },
    {
        original = 'Darkshot',
        custom = 'Darkshot',
    },
    {
        original = 'VampireAxe',
        custom = 'Vampire Axe',
    },
    {
        original = 'VampireGun',
        custom = 'Vampire Gun',
    },
    {
        original = 'SwirlyAxe',
        custom = 'Swirly Axe',
    },
    {
        original = 'SwirlyGun',
        custom = 'Swirly Gun',
    },
    {
        original = 'Flowerwood',
        custom = 'Flowerwood',
    },
    {
        original = 'FlowerwoodGun',
        custom = 'Flowerwood Gun',
    },
    {
        original = 'VampireGunChroma',
        custom = 'Chroma Vampire Gun',
    },
    {
        original = 'WatergunChroma',
        custom = 'Chroma Watergun',
    },
    {
        original = 'Turkey2023',
        custom = 'Turkey',
    },
    {
        original = 'Sakura_K',
        custom = 'Sakura',
    },
    {
        original = 'Blossom_G',
        custom = 'Blossom',
    },
    {
        original = 'Makeshift',
        custom = 'Makeshift',
    },
    {
        original = 'Sorry',
        custom = 'Corrupt',
    },
    {
        original = 'HeartWand',
        custom = 'HeartWand',
    },
}

local function spawnItem(Q)
    local R = pcall(function()
        local R = require(game:GetService('ReplicatedStorage').Modules.ProfileData)
        local S, T = R.Weapons, Q

        for U, V in ipairs(P)do
            if V.custom == Q then
                T = V.original

                break
            end
        end

        if not S.Owned[T] then
            S.Owned[T] = 1
        else
            S.Owned[T] += 1
        end

        R.Weapons = S

        local U = game:GetService('ReplicatedStorage'):FindFirstChild('Remotes')

        if U then
            local V = U:FindFirstChild('Inventory')

            if V then
                local W = V:FindFirstChild('ChangeInventoryItem')

                if W then
                    W:FireServer(T, 'Add')
                end

                local X = V:FindFirstChild('InventoryDataChanged')

                if X then
                    X:Fire()
                end
            end
        end
    end)

    return R
end

t:AddSection({
    Name = 'Item Spawner',
    Tab = O,
})

local Q = {}

for R, S in ipairs(P)do
    Q[S.custom] = S.custom
end

local R = nil

t:AddDropdown({
    Title = 'Select Item',
    Description = 'Choose an item to spawn',
    Tab = O,
    Options = Q,
    Callback = function(S)
        R = S
    end,
})
t:AddButton({
    Title = 'Spawn Selected Item',
    Description = 'Spawn the selected item to your inventory',
    Tab = O,
    Callback = function()
        if not R then
            t:Notify({
                Title = 'No Item Selected',
                Description = 'Please select an item first!',
                Duration = 3,
            })

            return
        end

        local S = spawnItem(R)

        if S then
            t:Notify({
                Title = 'Item Spawned',
                Description = R .. ' has been added to your inventory!',
                Duration = 3,
            })
        else
            t:Notify({
                Title = 'Spawn Failed',
                Description = 'Failed to spawn ' .. R,
                Duration = 3,
            })
        end
    end,
})
t:AddSection({
    Name = 'Quick Spawn',
    Tab = O,
})
t:AddButton({
    Title = 'Spawn Harvester',
    Description = 'Quickly spawn Harvester',
    Tab = O,
    Callback = function()
        if spawnItem('Harvester') then
            t:Notify({
                Title = 'Item Spawned',
                Description = 'Harvester has been added!',
                Duration = 2,
            })
        end
    end,
})
t:AddButton({
    Title = 'Spawn Corrupt',
    Description = 'Quickly spawn Corrupt',
    Tab = O,
    Callback = function()
        if spawnItem('Corrupt') then
            t:Notify({
                Title = 'Item Spawned',
                Description = 'Corrupt has been added!',
                Duration = 2,
            })
        end
    end,
})
t:AddButton({
    Title = 'Spawn Chroma Evergun',
    Description = 'Quickly spawn Chroma Evergun',
    Tab = O,
    Callback = function()
        if spawnItem('Chroma Evergun') then
            t:Notify({
                Title = 'Item Spawned',
                Description = 'Chroma Evergun has been added!',
                Duration = 2,
            })
        end
    end,
})
t:AddButton({
    Title = 'Spawn Chroma Evergreen',
    Description = 'Quickly spawn Chroma Evergreen',
    Tab = O,
    Callback = function()
        if spawnItem('Chroma Evergreen') then
            t:Notify({
                Title = 'Item Spawned',
                Description = 'Chroma Evergreen has been added!',
                Duration = 2,
            })
        end
    end,
})

local S = t:AddTab({
    Title = 'Settings',
    Icon = 'rbxassetid://11293977610',
})

t:AddKeybind({
    Title = 'Minimize Keybind',
    Description = 'Set the keybind for Minimizing',
    Tab = S,
    Callback = function(T)
        t:SetSetting('Keybind', T)
    end,
})
t:AddDropdown({
    Title = 'Set Theme',
    Description = 'Set the theme of the library!',
    Tab = S,
    Options = {
        ['Light Mode'] = 'Light',
        ['Dark Mode'] = 'Dark',
        ['Extra Dark'] = 'Void',
    },
    Callback = function(T)
        t:SetTheme(u[T])
    end,
})
t:AddToggle({
    Title = 'UI Blur',
    Description = 'If enabled, must have your Roblox graphics set to 8+ for it to work',
    Default = true,
    Tab = S,
    Callback = function(T)
        t:SetSetting('Blur', T)
    end,
})
t:AddSlider({
    Title = 'UI Transparency',
    Description = 'Set the transparency of the UI',
    Tab = S,
    AllowDecimals = true,
    MaxValue = 1,
    Callback = function(T)
        t:SetSetting('Transparency', T)
    end,
})
t:Notify({
    Title = 'Hello World!',
    Description = 'Press Left Alt to Minimize and Open the tab!',
    Duration = 10,
})

local T, U = game:GetService('Players'), game:GetService('ReplicatedStorage')
local V = U:FindFirstChild('GetPlayerData', true)

ESP_SETTINGS = {
    Murderer = false,
    Sheriff = false,
    Innocent = false,
    Hero = false,
}
NAME_ESP_SETTINGS = {
    Murderer = false,
    Sheriff = false,
    Innocent = false,
    Hero = false,
}
ESP_CUSTOMIZATION = {
    Box2D = false,
    DisplayName = false,
    NormalName = true,
    AvatarDisplay = false,
}

local W = {
    Murderer = Color3.fromRGB(255, 0, 0),
    Sheriff = Color3.fromRGB(0, 0, 255),
    Hero = Color3.fromRGB(255, 255, 0),
    Innocent = Color3.fromRGB(0, 255, 0),
}

local function CreateESP(X, Y)
    if not X.Character then
        return
    end

    local Z = X.Character:FindFirstChild('RoleESP')

    if not Z then
        Z = Instance.new('Highlight')
        Z.Name = 'RoleESP'
        Z.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        Z.FillTransparency = 0.5
        Z.OutlineTransparency = 0
        Z.Parent = X.Character
    end

    Z.FillColor = Y
    Z.OutlineColor = Y
end
local function RemoveESP(X)
    if X.Character then
        local Y = X.Character:FindFirstChild('RoleESP')

        if Y then
            Y:Destroy()
        end
    end
end
local function Create2DBox(X, Y)
    if not X.Character then
        return
    end

    local Z = X.Character:FindFirstChild('HumanoidRootPart')

    if not Z then
        return
    end

    local _ = Z:FindFirstChild('Box2D')

    if ESP_CUSTOMIZATION.Box2D then
        if not _ then
            _ = Instance.new('BillboardGui')
            _.Name = 'Box2D'
            _.AlwaysOnTop = true
            _.Size = UDim2.new(4, 0, 5, 0)
            _.StudsOffset = Vector3.new(0, 0, 0)
            _.Parent = Z

            local aa = Instance.new('Frame')

            aa.Name = 'BoxFrame'
            aa.BackgroundTransparency = 1
            aa.Size = UDim2.new(1, 0, 1, 0)
            aa.BorderSizePixel = 2
            aa.Parent = _

            local ab = Instance.new('UIStroke')

            ab.Name = 'Stroke'
            ab.Thickness = 2
            ab.Parent = aa
        end

        local aa = _:FindFirstChild('BoxFrame')

        if aa then
            local ab = aa:FindFirstChild('Stroke')

            if ab then
                ab.Color = Y
            end
        end
    else
        if _ then
            _:Destroy()
        end
    end
end
local function CreateNameESP(aa, ab)
    if not aa.Character then
        return
    end

    local X, Y = aa.Character:FindFirstChild('Head'), aa.Character:FindFirstChild('HumanoidRootPart')

    if not X or not Y then
        return
    end

    local Z = X:FindFirstChild('NameESP')

    if not Z then
        Z = Instance.new('BillboardGui')
        Z.Name = 'NameESP'
        Z.AlwaysOnTop = true
        Z.Size = UDim2.new(0, 200, 0, 80)
        Z.StudsOffset = Vector3.new(0, 2, 0)
        Z.Parent = X

        local _ = Instance.new('Frame')

        _.Name = 'AvatarFrame'
        _.BackgroundColor3 = Color3.new(1, 1, 1)
        _.Size = UDim2.new(0, 40, 0, 40)
        _.Position = UDim2.new(0.5, -20, 0, 0)
        _.BorderSizePixel = 2
        _.Parent = Z

        local ac = Instance.new('UICorner')

        ac.CornerRadius = UDim.new(1, 0)
        ac.Parent = _

        local ad = Instance.new('ImageLabel')

        ad.Name = 'Avatar'
        ad.BackgroundTransparency = 1
        ad.Size = UDim2.new(1, 0, 1, 0)
        ad.Image = T:GetUserThumbnailAsync(aa.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        ad.Parent = _

        local ae = Instance.new('UICorner')

        ae.CornerRadius = UDim.new(1, 0)
        ae.Parent = ad

        local af = Instance.new('TextLabel')

        af.Name = 'NameLabel'
        af.BackgroundTransparency = 1
        af.Size = UDim2.new(1, 0, 0, 20)
        af.Position = UDim2.new(0, 0, 1, -20)
        af.Font = Enum.Font.GothamBold
        af.TextSize = 14
        af.TextStrokeTransparency = 0
        af.TextStrokeColor3 = Color3.new(0, 0, 0)
        af.Parent = Z
    end

    local ac, ad = Z:FindFirstChild('AvatarFrame'), Z:FindFirstChild('NameLabel')

    if ad then
        if ESP_CUSTOMIZATION.DisplayName then
            ad.Text = aa.DisplayName
        elseif ESP_CUSTOMIZATION.NormalName then
            ad.Text = aa.Name
        else
            ad.Text = ''
        end

        ad.TextColor3 = ab
    end
    if ac then
        ac.Visible = ESP_CUSTOMIZATION.AvatarDisplay
        ac.BorderColor3 = ab
    end

    Create2DBox(aa, ab)
end
local function RemoveNameESP(aa)
    if aa.Character then
        local ab = aa.Character:FindFirstChild('Head')

        if ab then
            local ac = ab:FindFirstChild('NameESP')

            if ac then
                ac:Destroy()
            end
        end

        local ac = aa.Character:FindFirstChild('HumanoidRootPart')

        if ac then
            local ad = ac:FindFirstChild('Box2D')

            if ad then
                ad:Destroy()
            end
        end
    end
end
local function UpdateESP()
    local aa, ab = pcall(function()
        return V:InvokeServer()
    end)

    if not aa then
        return
    end

    for ac, ad in ipairs(T:GetPlayers())do
        if ad ~= T.LocalPlayer and ad:GetAttribute('Alive') == true then
            local ae, af = 'Innocent', ab[ad.Name]

            if af and af.Role then
                ae = af.Role
            end

            local X = W[ae] or W.Innocent

            if ESP_SETTINGS[ae] == true then
                CreateESP(ad, X)
            else
                RemoveESP(ad)
            end
            if NAME_ESP_SETTINGS[ae] == true then
                CreateNameESP(ad, X)
            else
                RemoveNameESP(ad)
            end
        else
            RemoveESP(ad)
            RemoveNameESP(ad)
        end
    end
end
local function findmap()
    for aa, ab in (game.Workspace:GetChildren())do
        if ab:GetAttribute('MapID') then
            return ab
        end
    end
end

t:AddButton({
    Title = 'Map TP',
    Description = 'Teleports you in map',
    Tab = G,
    Callback = function()
        if not a then
            return
        end

        local aa = a.Character

        if not aa or not aa.Parent then
            return
        end

        for ab, ac in (findmap().Spawns:GetChildren())do
            aa.HumanoidRootPart.CFrame = ac.CFrame

            return
        end
    end,
})
t:AddButton({
    Title = 'Lobby TP',
    Description = 'Teleports you in Lobby',
    Tab = G,
    Callback = function()
        if not a then
            return
        end

        local aa = a.Character

        if not aa or not aa.Parent then
            return
        end

        for ab, ac in (workspace.Lobby.Spawns:GetChildren())do
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = ac.CFrame

            return
        end
    end,
})
t:AddButton({
    Title = 'Murder TP',
    Description = 'Teleports you to Murder',
    Tab = G,
    Callback = function()
        if not a then
            return
        end

        local aa = a.Character

        if not aa or not aa.Parent then
            return
        end

        local ab, ac = pcall(function()
            return V:InvokeServer()
        end)

        if ab and ac then
            for ad, ae in pairs(b:GetPlayers())do
                if ae ~= a and ae:GetAttribute('Alive') == true then
                    local af = ac[ae.Name]

                    if af and af.Role == 'Murderer' and ae.Character then
                        aa.HumanoidRootPart.CFrame = ae.Character.HumanoidRootPart.CFrame

                        return
                    end
                end
            end
        end
    end,
})
t:AddButton({
    Title = 'Sheriff TP',
    Description = 'Teleports you to Sheriff',
    Tab = G,
    Callback = function()
        if not a then
            return
        end

        local aa = a.Character

        if not aa or not aa.Parent then
            return
        end

        local ab, ac = pcall(function()
            return V:InvokeServer()
        end)

        if ab and ac then
            for ad, ae in pairs(b:GetPlayers())do
                if ae ~= a and ae:GetAttribute('Alive') == true then
                    local af = ac[ae.Name]

                    if af and af.Role == 'Sheriff' and ae.Character then
                        aa.HumanoidRootPart.CFrame = ae.Character.HumanoidRootPart.CFrame

                        return
                    end
                end
            end
        end
    end,
})
t:AddSection({
    Name = 'Dance Emotes',
    Tab = G,
})

local aa, ab, ac, ad = false, '127118661424463', nil, {
    ['Dance 1'] = '127118661424463',
    ['Dance 2'] = '82682811348660',
    ['Dance 3'] = '10714340543',
    ['Dance 4'] = '15609995579',
}

local function playDance()
    if not a.Character then
        return
    end
    if not ab then
        return
    end

    local ae = a.Character:FindFirstChildOfClass('Humanoid')

    if not ae then
        return
    end

    local af = ae:FindFirstChildOfClass('Animator')

    if not af then
        af = Instance.new('Animator')
        af.Parent = ae
    end
    if ac then
        pcall(function()
            ac:Stop()
        end)
        task.wait(0.1)
        pcall(function()
            ac:Destroy()
        end)

        ac = nil
    end

    task.wait(0.1)

    local X = Instance.new('Animation')

    X.AnimationId = 'rbxassetid://' .. tostring(ab)

    pcall(function()
        ac = af:LoadAnimation(X)
        ac.Looped = true
        ac.Priority = Enum.AnimationPriority.Action

        ac:Play(0.1, 1, 1)
    end)
    X:Destroy()
end
local function stopDance()
    if ac then
        pcall(function()
            ac:Stop()
            ac:Destroy()
        end)

        ac = nil
    end
end

a.CharacterAdded:Connect(function(ae)
    ae:WaitForChild('Humanoid')
    task.wait(0.5)

    if aa then
        playDance()
    end
end)
t:AddDropdown({
    Title = 'Select Dance',
    Description = 'Choose a dance emote',
    Tab = G,
    Options = ad,
    Callback = function(ae)
        if ae then
            ab = ae

            if aa then
                stopDance()
                task.wait(0.2)
                playDance()
                t:Notify({
                    Title = 'Dance Changed',
                    Description = 'Dance ID: ' .. tostring(ab),
                    Duration = 2,
                })
            end
        end
    end,
})
t:AddToggle({
    Title = 'Auto Dance',
    Description = 'Automatically play selected dance',
    Default = false,
    Tab = G,
    Callback = function(ae)
        aa = ae

        if ae then
            playDance()
            t:Notify({
                Title = 'Dance Started',
                Description = 'Now dancing!',
                Duration = 2,
            })
        else
            stopDance()
            t:Notify({
                Title = 'Dance Stopped',
                Description = 'Dance disabled',
                Duration = 2,
            })
        end
    end,
})
t:AddSection({
    Name = 'Fling Players',
    Tab = G,
})

local function SkidFling(ae)
    local af = a.Character
    local X = af and af:FindFirstChildOfClass('Humanoid')
    local Y, Z = X and X.RootPart, ae.Character

    if not Z then
        return
    end

    local _, ag, ah, ai, aj

    if Z:FindFirstChildOfClass('Humanoid') then
        _ = Z:FindFirstChildOfClass('Humanoid')
    end
    if _ and _.RootPart then
        ag = _.RootPart
    end
    if Z:FindFirstChild('Head') then
        ah = Z.Head
    end

    for ak, al in pairs(Z:FindFirstChildWhichIsA('Accessory') and Z:GetChildren() or {})do
        if al:IsA('Accessory') and al:FindFirstChild('Handle') then
            ai = al
            aj = al.Handle

            break
        end
    end

    if not aj then
        for ak, al in pairs(Z:GetChildren())do
            if al:IsA('Accessory') and al:FindFirstChild('Handle') then
                ai = al
                aj = al.Handle

                break
            end
        end
    end
    if af and X and Y then
        if Y.Velocity.Magnitude < 50 then
            getgenv().OldPos = Y.CFrame
        end
        if _ and _.Sit then
            return
        end
        if ah then
            workspace.CurrentCamera.CameraSubject = ah
        elseif aj then
            workspace.CurrentCamera.CameraSubject = aj
        elseif _ and ag then
            workspace.CurrentCamera.CameraSubject = _
        end
        if not Z:FindFirstChildWhichIsA('BasePart') then
            return
        end

        local ak = function(ak, al, am)
            Y.CFrame = CFrame.new(ak.Position) * al * am

            af:SetPrimaryPartCFrame(CFrame.new(ak.Position) * al * am)

            Y.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            Y.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end
        local al = function(al)
            local am, an, ao = 2, tick(), 0

            repeat
                if Y and _ then
                    if al.Velocity.Magnitude < 50 then
                        ao = ao + 100

                        ak(al, CFrame.new(0, 1.5, 0) + _.MoveDirection * al.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(ao), 0, 0))
                        task.wait()
                        ak(al, CFrame.new(0, -1.5, 0) + _.MoveDirection * al.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(ao), 0, 0))
                        task.wait()
                        ak(al, CFrame.new(0, 1.5, 0) + _.MoveDirection * al.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(ao), 0, 0))
                        task.wait()
                        ak(al, CFrame.new(0, -1.5, 0) + _.MoveDirection * al.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(ao), 0, 0))
                        task.wait()
                        ak(al, CFrame.new(0, 1.5, 0) + _.MoveDirection, CFrame.Angles(math.rad(ao), 0, 0))
                        task.wait()
                        ak(al, CFrame.new(0, -1.5, 0) + _.MoveDirection, CFrame.Angles(math.rad(ao), 0, 0))
                        task.wait()
                    else
                        ak(al, CFrame.new(0, 1.5, _.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        ak(al, CFrame.new(0, -1.5, -_.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()
                        ak(al, CFrame.new(0, 1.5, _.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        ak(al, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        ak(al, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                        ak(al, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        ak(al, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                end
            until an + am < tick() or not o
        end

        workspace.FallenPartsDestroyHeight = 0 / 0

        local am = Instance.new('BodyVelocity')

        am.Parent = Y
        am.Velocity = Vector3.new(0, 0, 0)
        am.MaxForce = Vector3.new(9e9, 9e9, 9e9)

        X:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

        if ag then
            al(ag)
        elseif ah then
            al(ah)
        elseif aj then
            al(aj)
        end

        am:Destroy()
        X:SetStateEnabled(Enum.HumanoidStateType.Seated, true)

        workspace.CurrentCamera.CameraSubject = X

        if getgenv().OldPos then
            repeat
                Y.CFrame = getgenv().OldPos * CFrame.new(0, 0.5, 0)

                af:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, 0.5, 0))
                X:ChangeState('GettingUp')

                for an, ao in pairs(af:GetChildren())do
                    if ao:IsA('BasePart') then
                        ao.Velocity, ao.RotVelocity = Vector3.new(), Vector3.new()
                    end
                end

                task.wait()
            until (Y.Position - getgenv().OldPos.p).Magnitude < 25

            workspace.FallenPartsDestroyHeight = getgenv().FPDH
        end
    end
end
local function FindPlayerByPartialName(ae)
    if not ae or ae == '' then
        return nil
    end

    local af = string.lower(ae)

    for ag, ah in pairs(b:GetPlayers())do
        if ah ~= a and string.lower(ah.Name) == af then
            return ah
        end
    end
    for ag, ah in pairs(b:GetPlayers())do
        if ah ~= a and string.sub(string.lower(ah.Name), 1, #af) == af then
            return ah
        end
    end
    for ag, ah in pairs(b:GetPlayers())do
        if ah ~= a and string.find(string.lower(ah.Name), af, 1, true) then
            return ah
        end
    end

    return nil
end

t:AddInput({
    Title = 'Player Search',
    Description = 'Enter player name or part of it',
    Tab = G,
    Callback = function(ae)
        local af = FindPlayerByPartialName(ae)

        if af then
            p = af

            t:Notify({
                Title = 'Player Found',
                Description = 'Selected: ' .. af.Name,
                Duration = 2,
            })
        else
            p = nil

            if ae ~= '' then
                t:Notify({
                    Title = 'Not Found',
                    Description = 'No player found matching: ' .. ae,
                    Duration = 2,
                })
            end
        end
    end,
})
t:AddButton({
    Title = 'Fling Murderer',
    Description = 'Automatically fling the murderer',
    Tab = G,
    Callback = function()
        if o then
            return
        end

        local ae, af, ag = nil, pcall(function()
            return V:InvokeServer()
        end)

        if af and ag then
            for ah, ai in pairs(b:GetPlayers())do
                if ai ~= a and ai:GetAttribute('Alive') == true then
                    local aj = ag[ai.Name]

                    if aj and aj.Role == 'Murderer' then
                        ae = ai

                        break
                    end
                end
            end
        end
        if ae then
            o = true

            t:Notify({
                Title = 'Fling Started',
                Description = 'Flinging murderer: ' .. ae.Name,
                Duration = 3,
            })
            task.spawn(function()
                SkidFling(ae)

                o = false
            end)
        end
    end,
})
t:AddButton({
    Title = 'Fling Sheriff',
    Description = 'Automatically fling the sheriff',
    Tab = G,
    Callback = function()
        if o then
            return
        end

        local ae, af, ag = nil, pcall(function()
            return V:InvokeServer()
        end)

        if af and ag then
            for ah, ai in pairs(b:GetPlayers())do
                if ai ~= a and ai:GetAttribute('Alive') == true then
                    local aj = ag[ai.Name]

                    if aj and aj.Role == 'Sheriff' then
                        ae = ai

                        break
                    end
                end
            end
        end
        if ae then
            o = true

            t:Notify({
                Title = 'Fling Started',
                Description = 'Flinging sheriff: ' .. ae.Name,
                Duration = 3,
            })
            task.spawn(function()
                SkidFling(ae)

                o = false
            end)
        end
    end,
})
t:AddButton({
    Title = 'Fling Selected Player',
    Description = 'Fling the player selected in dropdown',
    Tab = G,
    Callback = function()
        if o then
            return
        end
        if not p or not p.Parent then
            t:Notify({
                Title = 'Error',
                Description = 'Please select a valid player first!',
                Duration = 3,
            })

            return
        end

        o = true

        t:Notify({
            Title = 'Fling Started',
            Description = 'Flinging: ' .. p.Name,
            Duration = 3,
        })
        task.spawn(function()
            SkidFling(p)

            o = false
        end)
    end,
})
t:AddButton({
    Title = 'Stop Fling',
    Description = 'Stop current fling operation',
    Tab = G,
    Callback = function()
        if o then
            o = false

            t:Notify({
                Title = 'Fling Stopped',
                Description = 'Fling operation has been stopped',
                Duration = 3,
            })
        else
            t:Notify({
                Title = 'Info',
                Description = 'No active fling operation',
                Duration = 2,
            })
        end
    end,
})

local function getgun()
    pcall(function()
        if not g then
            return
        end
        if not a:GetAttribute('Alive') then
            return
        end
        if isMurderer() then
            return
        end

        local ae, af = findmap(), nil

        if not ae then
            return
        end

        af = a.Character.HumanoidRootPart.CFrame

        if ae:FindFirstChild('GunDrop') then
            ae:FindFirstChild('GunDrop').CFrame = a.Character.HumanoidRootPart.CFrame
        end
    end)
end
local function enableNoclip()
    if i then
        return
    end

    i = c.Stepped:Connect(function()
        if h and a.Character then
            for ae, af in pairs(a.Character:GetDescendants())do
                if af:IsA('BasePart') then
                    af.CanCollide = false
                end
            end
        end
    end)
end
local function startFarming()
    if not a.Character or not a.Character:FindFirstChild('HumanoidRootPart') then
        return
    end
    if a:GetAttribute('Alive') ~= true then
        return
    end

    local ae, af = a.Character.HumanoidRootPart, a.Character:FindFirstChild('Humanoid')

    k = {}

    for ag, ah in pairs(a.Character:GetDescendants())do
        if ah:IsA('BasePart') then
            k[ah] = {
                CanCollide = ah.CanCollide,
                Massless = ah.Massless,
            }
        end
    end

    ae.CFrame = ae.CFrame - Vector3.new(0, 2.5, 0)
    ae.CFrame = ae.CFrame * CFrame.Angles(math.rad(90), 0, 0)

    if af then
        af.PlatformStand = true

        af:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        af:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    end

    l = true
end
local function stopFarming()
    l = false

    if j then
        j:Cancel()

        j = nil
    end
    if i then
        i:Disconnect()

        i = nil
    end
    if a.Character then
        for ae, af in pairs(k)do
            if ae and ae.Parent then
                ae.CanCollide = af.CanCollide
                ae.Massless = af.Massless
            end
        end

        local ae = a.Character:FindFirstChild('HumanoidRootPart')

        if ae then
            ae.Velocity = Vector3.new(0, 0, 0)
            ae.RotVelocity = Vector3.new(0, 0, 0)
            ae.CFrame = ae.CFrame * CFrame.Angles(math.rad(-90), 0, 0)
            ae.CFrame = ae.CFrame + Vector3.new(0, 2.5, 0)
        end

        local af = a.Character:FindFirstChild('Humanoid')

        if af then
            af.PlatformStand = false

            af:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            af:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        end
    end

    k = {}
end

local ae = U.Remotes.Gameplay.CoinCollected

ae.OnClientEvent:Connect(function(af, ag, ah)
    if af == m then
        if tonumber(ag) == tonumber(ah) then
            n = true

            if l then
                stopFarming()
            end
        else
            n = false
        end
    end
end)

local af, ag = U.Remotes.Gameplay.RoundStart, U.Remotes.Gameplay.RoundEndFade

af.OnClientEvent:Connect(function()
    n = false
end)
ag.OnClientEvent:Connect(function()
    n = false

    if l then
        stopFarming()
    end
end)
task.spawn(function()
    while true do
        c.Heartbeat:Wait()

        if l and a.Character and a.Character:FindFirstChild('HumanoidRootPart') and a:GetAttribute('Alive') == true then
            local ah, ai = a.Character.HumanoidRootPart, returncoincontainer()

            if ai then
                for aj, ak in pairs(ai:GetChildren())do
                    if ak:GetAttribute('CoinID') == 'Coin' and ak:FindFirstChild('TouchInterest') and ak.Transparency == 1 then
                        local al = (ah.Position - ak.Position).Magnitude

                        if al <= 5 then
                            firetouchinterest(ah, ak, 0)
                            firetouchinterest(ah, ak, 1)
                        end
                    end
                end
            end
        end
    end
end)
task.spawn(function()
    while true do
        c.Heartbeat:Wait()

        if h and not n and a:GetAttribute('Alive') == true and a.Character and a.Character:FindFirstChild('HumanoidRootPart') then
            local ah = returncoincontainer()

            if ah then
                local ai, aj = FindNearestCoin(ah)

                if ai and ai.Transparency == 1 and not n then
                    if not l then
                        startFarming()
                    end

                    local ak, al = a.Character.HumanoidRootPart, a.Character:FindFirstChild('Humanoid')

                    ak.Velocity = Vector3.new(0, 0, 0)
                    ak.RotVelocity = Vector3.new(0, 0, 0)

                    local am = ai.Position - Vector3.new(0, 2.5, 0)
                    local an = CFrame.new(am) * CFrame.Angles(math.rad(90), 0, 0)

                    enableNoclip()

                    local ao = TweenInfo.new(aj / 23, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

                    j = d:Create(ak, ao, {CFrame = an})

                    j:Play()

                    local X

                    X = c.Heartbeat:Connect(function()
                        if h and a:GetAttribute('Alive') == true and ak then
                            ak.Velocity = Vector3.new(0, 0, 0)
                            ak.RotVelocity = Vector3.new(0, 0, 0)

                            if al then
                                al.PlatformStand = true
                            end
                        else
                            if X then
                                X:Disconnect()
                            end
                        end
                    end)

                    while ai and ai:FindFirstChild('TouchInterest') and ai.Transparency == 1 and not n and h and a:GetAttribute('Alive') == true do
                        c.Heartbeat:Wait()
                    end

                    if X then
                        X:Disconnect()
                    end
                    if j then
                        j:Cancel()
                    end
                    if ak then
                        ak.Velocity = Vector3.new(0, 0, 0)
                        ak.RotVelocity = Vector3.new(0, 0, 0)
                    end
                else
                    if l then
                        stopFarming()
                    end
                end
            else
                if l then
                    stopFarming()
                end
            end
        else
            if l then
                stopFarming()
            end
        end
    end
end)
task.spawn(function()
    while true do
        c.Heartbeat:Wait()
        UpdateESP()
        getgun()
    end
end)
T.PlayerAdded:Connect(function(ah)
    ah.CharacterAdded:Connect(function()
        UpdateESP()
    end)
end)
q.InputBegan:Connect(function(ah)
    if ah == Keybind then
    end
end)
