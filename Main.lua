-- [[ MRGHOST HUB VIP - ALL IN ONE ULTIMATE EDITION ]]
local success, err = pcall(function()

    -- Services
    local CoreGui = game:GetService("CoreGui")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local HttpService = game:GetService("HttpService")
    local Workspace = game:GetService("Workspace")

    local LocalPlayer = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera

    -- Config Key System
    local CORRECT_KEY = "TTTT"
    local KEY_LINK = "https://discord.gg/KDTDZjYSR"
    local BACKUP_LINK = "https://fnote.net/notes/jv9G9J"
    local CACHE_FILE = "MrGhostVIP_KeyCache.json"
    local EXPIRE_TIME = 86400 -- 24 Tiếng

    -- Config Features
    local walkSpeedValue = 50
    local speedEnabled = false
    local jumpPowerValue = 120
    local jumpEnabled = false
    local infJumpEnabled = false
    local noclipEnabled = false

    local AimbotEnabled = false
    local AimPart = "Head" -- "Head", "HumanoidRootPart", "LeftFoot"
    local Sensitivity = 0.2
    local TeamCheckEnabled = true -- Nút Chia Đội

    local ShowFOV = true
    local FOVRadius = 120

    local ESPEnabled = false
    local TracersEnabled = false

    -- Container ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MrGhostHub_UltraVIP_AllInOne"
    ScreenGui.Parent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false

    -- Helper RGB
    local function getRGBColor(speed)
        speed = speed or 3
        local hue = (tick() % speed) / speed
        return Color3.fromHSV(hue, 0.85, 1)
    end

    -- FOV Drawing Circle
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1.5
    FOVCircle.Color = Color3.fromRGB(0, 240, 255)
    FOVCircle.Filled = false
    FOVCircle.Transparency = 0.8
    FOVCircle.NumSides = 64
    FOVCircle.Visible = ShowFOV
    FOVCircle.Radius = FOVRadius

    -- Helper Draggable
    local function makeDraggable(gui)
        local dragging, dragInput, dragStart, startPos
        gui.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = gui.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        gui.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    -- =========================================================
    -- KIỂM TRA CACHE KEY
    -- =========================================================
    local function isKeySavedValid()
        if readfile and isfile and isfile(CACHE_FILE) then
            local successRead, data = pcall(function()
                return HttpService:JSONDecode(readfile(CACHE_FILE))
            end)
            if successRead and data and data.key == CORRECT_KEY and data.time then
                if (os.time() - data.time) < EXPIRE_TIME then
                    return true
                end
            end
        end
        return false
    end

    local function saveKeyCache(key)
        if writefile then
            pcall(function()
                local data = { key = key, time = os.time() }
                writefile(CACHE_FILE, HttpService:JSONEncode(data))
            end)
        end
    end

    -- Helper get Closest Player for Aimbot
    local function getClosestPlayer()
        local closestPlayer = nil
        local shortestDistance = FOVRadius
        local mousePos = UserInputService:GetMouseLocation()

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(AimPart) and player.Character:FindFirstChildOfClass("Humanoid") then
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                local isSameTeam = TeamCheckEnabled and player.Team and LocalPlayer.Team and (player.Team == LocalPlayer.Team)

                if hum.Health > 0 and not isSameTeam then
                    local targetPart = player.Character[AimPart]
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)

                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestPlayer = targetPart
                        end
                    end
                end
            end
        end
        return closestPlayer
    end

    -- =========================================================
    -- ESP & TRACERS STORAGE
    -- =========================================================
    local ESP_Storage = {}

    local function createESP(player)
        if player == LocalPlayer then return end
        local drawings = {
            Box = Drawing.new("Square"),
            Name = Drawing.new("Text"),
            Tracer = Drawing.new("Line")
        }

        drawings.Box.Thickness = 1.5
        drawings.Box.Filled = false
        drawings.Box.Color = Color3.fromRGB(255, 0, 120)

        drawings.Name.Size = 13
        drawings.Name.Center = true
        drawings.Name.Outline = true
        drawings.Name.Color = Color3.fromRGB(255, 255, 255)

        drawings.Tracer.Thickness = 1.5
        drawings.Tracer.Color = Color3.fromRGB(0, 240, 255)

        ESP_Storage[player] = drawings
    end

    local function removeESP(player)
        if ESP_Storage[player] then
            for _, drawing in pairs(ESP_Storage[player]) do
                drawing:Remove()
            end
            ESP_Storage[player] = nil
        end
    end

    for _, player in pairs(Players:GetPlayers()) do createESP(player) end
    Players.PlayerAdded:Connect(createESP)
    Players.PlayerRemoving:Connect(removeESP)

    -- =========================================================
    -- MAIN HUB UI (CYBERPUNK STYLE)
    -- =========================================================
    local function loadMainHub()
        local MainFrame = Instance.new("Frame")
        MainFrame.Name = "MainFrame"
        MainFrame.Size = UDim2.new(0, 360, 0, 420)
        MainFrame.Position = UDim2.new(0.5, -180, 0.3, -210)
        MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
        MainFrame.BackgroundTransparency = 0.15
        MainFrame.BorderSizePixel = 0
        MainFrame.Parent = ScreenGui

        local MainCorner = Instance.new("UICorner")
        MainCorner.CornerRadius = UDim.new(0, 20)
        MainCorner.Parent = MainFrame

        local UIStroke = Instance.new("UIStroke")
        UIStroke.Thickness = 2.5
        UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        UIStroke.Parent = MainFrame

        -- TITLE HEADER VIP
        local TitleBar = Instance.new("Frame")
        TitleBar.Name = "TitleBar"
        TitleBar.Size = UDim2.new(1, 0, 0, 52)
        TitleBar.BackgroundColor3 = Color3.fromRGB(18, 14, 28)
        TitleBar.BackgroundTransparency = 0.2
        TitleBar.Parent = MainFrame

        local TitleBarCorner = Instance.new("UICorner")
        TitleBarCorner.CornerRadius = UDim.new(0, 20)
        TitleBarCorner.Parent = TitleBar

        local VipBadge = Instance.new("TextLabel")
        VipBadge.Size = UDim2.new(0, 40, 0, 22)
        VipBadge.Position = UDim2.new(0, 12, 0.5, -11)
        VipBadge.BackgroundColor3 = Color3.fromRGB(255, 0, 120)
        VipBadge.Text = "VIP"
        VipBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
        VipBadge.TextSize = 12
        VipBadge.Font = Enum.Font.FredokaOne
        VipBadge.Parent = TitleBar

        local BadgeCorner = Instance.new("UICorner")
        BadgeCorner.CornerRadius = UDim.new(0, 6)
        BadgeCorner.Parent = VipBadge

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(0, 180, 1, 0)
        Title.Position = UDim2.new(0, 58, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Text = "MRGHOST HUB VIP"
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextSize = 16
        Title.Font = Enum.Font.FredokaOne
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = TitleBar

        local TitleGradient = Instance.new("UIGradient")
        TitleGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 180)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 240, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 220, 0))
        }
        TitleGradient.Parent = Title

        local HeartLabel = Instance.new("TextLabel")
        HeartLabel.Size = UDim2.new(0, 80, 1, 0)
        HeartLabel.Position = UDim2.new(0, 240, 0, 0)
        HeartLabel.BackgroundTransparency = 1
        HeartLabel.Text = "💖 TTTT"
        HeartLabel.TextColor3 = Color3.fromRGB(255, 100, 180)
        HeartLabel.TextSize = 13
        HeartLabel.Font = Enum.Font.FredokaOne
        HeartLabel.TextXAlignment = Enum.TextXAlignment.Left
        HeartLabel.Parent = TitleBar

        task.spawn(function()
            while task.wait() do
                if HeartLabel.Parent then
                    TweenService:Create(HeartLabel, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextSize = 16}):Play()
                    task.wait(0.6)
                    TweenService:Create(HeartLabel, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextSize = 13}):Play()
                    task.wait(0.6)
                else break end
            end
        end)

        -- SCROLLING FRAME
        local Scroll = Instance.new("ScrollingFrame")
        Scroll.Size = UDim2.new(1, -20, 1, -65)
        Scroll.Position = UDim2.new(0, 10, 0, 58)
        Scroll.BackgroundTransparency = 1
        Scroll.BorderSizePixel = 0
        Scroll.ScrollBarThickness = 4
        Scroll.CanvasSize = UDim2.new(0, 0, 0, 780)
        Scroll.Parent = MainFrame

        local UIList = Instance.new("UIListLayout")
        UIList.Parent = Scroll
        UIList.SortOrder = Enum.SortOrder.LayoutOrder
        UIList.Padding = UDim.new(0, 8)

        -- Helper Toggle Card
        local function createToggleCard(titleText, defaultState, layoutOrder, callback)
            local Card = Instance.new("Frame")
            Card.Size = UDim2.new(1, -6, 0, 45)
            Card.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
            Card.BackgroundTransparency = 0.25
            Card.LayoutOrder = layoutOrder
            Card.Parent = Scroll

            local CardCorner = Instance.new("UICorner")
            CardCorner.CornerRadius = UDim.new(0, 12)
            CardCorner.Parent = Card

            local CardLabel = Instance.new("TextLabel")
            CardLabel.Size = UDim2.new(0.7, 0, 1, 0)
            CardLabel.Position = UDim2.new(0, 12, 0, 0)
            CardLabel.BackgroundTransparency = 1
            CardLabel.Text = titleText
            CardLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            CardLabel.TextSize = 13
            CardLabel.Font = Enum.Font.FredokaOne
            CardLabel.TextXAlignment = Enum.TextXAlignment.Left
            CardLabel.Parent = Card

            local SwitchBg = Instance.new("TextButton")
            SwitchBg.Size = UDim2.new(0, 50, 0, 24)
            SwitchBg.Position = UDim2.new(1, -60, 0.5, -12)
            SwitchBg.BackgroundColor3 = defaultState and Color3.fromRGB(255, 0, 120) or Color3.fromRGB(40, 32, 55)
            SwitchBg.Text = ""
            SwitchBg.AutoButtonColor = false
            SwitchBg.Parent = Card

            local SwitchCorner = Instance.new("UICorner")
            SwitchCorner.CornerRadius = UDim.new(1, 0)
            SwitchCorner.Parent = SwitchBg

            local SwitchDot = Instance.new("Frame")
            SwitchDot.Size = UDim2.new(0, 18, 0, 18)
            SwitchDot.Position = defaultState and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
            SwitchDot.BackgroundColor3 = defaultState and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 140, 180)
            SwitchDot.Parent = SwitchBg

            local SwitchDotCorner = Instance.new("UICorner")
            SwitchDotCorner.CornerRadius = UDim.new(1, 0)
            SwitchDotCorner.Parent = SwitchDot

            local enabled = defaultState
            SwitchBg.MouseButton1Click:Connect(function()
                enabled = not enabled
                if enabled then
                    TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 0, 120)}):Play()
                    TweenService:Create(SwitchDot, TweenInfo.new(0.2), {Position = UDim2.new(1, -21, 0.5, -9), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                else
                    TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 32, 55)}):Play()
                    TweenService:Create(SwitchDot, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -9), BackgroundColor3 = Color3.fromRGB(160, 140, 180)}):Play()
                end
                callback(enabled)
            end)
            return Card
        end

        -- Helper Input Card
        local function createInputCard(titleText, placeholderText, defaultVal, layoutOrder, callback)
            local Card = Instance.new("Frame")
            Card.Size = UDim2.new(1, -6, 0, 65)
            Card.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
            Card.BackgroundTransparency = 0.25
            Card.LayoutOrder = layoutOrder
            Card.Parent = Scroll

            local CardCorner = Instance.new("UICorner")
            CardCorner.CornerRadius = UDim.new(0, 12)
            CardCorner.Parent = Card

            local InputLabel = Instance.new("TextLabel")
            InputLabel.Size = UDim2.new(1, -24, 0, 20)
            InputLabel.Position = UDim2.new(0, 12, 0, 6)
            InputLabel.BackgroundTransparency = 1
            InputLabel.Text = titleText
            InputLabel.TextColor3 = Color3.fromRGB(0, 240, 255)
            InputLabel.TextSize = 12
            InputLabel.Font = Enum.Font.FredokaOne
            InputLabel.TextXAlignment = Enum.TextXAlignment.Left
            InputLabel.Parent = Card

            local TextBox = Instance.new("TextBox")
            TextBox.Size = UDim2.new(1, -24, 0, 28)
            TextBox.Position = UDim2.new(0, 12, 0, 28)
            TextBox.BackgroundColor3 = Color3.fromRGB(30, 24, 42)
            TextBox.Text = tostring(defaultVal)
            TextBox.PlaceholderText = placeholderText
            TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextBox.TextSize = 13
            TextBox.Font = Enum.Font.SourceSansBold
            TextBox.ClearTextOnFocus = false
            TextBox.Parent = Card

            local BoxCorner = Instance.new("UICorner")
            BoxCorner.CornerRadius = UDim.new(0, 8)
            BoxCorner.Parent = TextBox

            TextBox.FocusLost:Connect(function()
                local num = tonumber(TextBox.Text)
                if num then callback(num) else TextBox.Text = tostring(defaultVal) end
            end)
            return Card
        end

        -- SECTION 1: HACK DI CHUYỂN
        createToggleCard("⚡ Chạy Nhanh (WalkSpeed)", false, 1, function(st) speedEnabled = st end)
        createInputCard("🏃 Tốc Độ Di Chuyển", "Nhập Speed...", 50, 2, function(val) walkSpeedValue = val end)

        createToggleCard("🦘 Nhảy Cao (JumpPower)", false, 3, function(st) jumpEnabled = st end)
        createInputCard("💥 Sức Nhảy", "Nhập JumpPower...", 120, 4, function(val) jumpPowerValue = val end)

        createToggleCard("🌌 Infinite Jump (Nhảy Trên Không)", false, 5, function(st) infJumpEnabled = st end)
        createToggleCard("👻 Noclip (Đi Xuyên Tường)", false, 6, function(st) noclipEnabled = st end)

        -- SECTION 2: AIMBOT & AIM LOCK
        createToggleCard("🎯 Aim Lock (Khóa Tâm)", false, 7, function(st) AimbotEnabled = st end)

        -- 🛡️ NÚT CHIA ĐỘI (TEAM CHECK)
        createToggleCard("🛡️ Bật Chia Đội (Game Co Team)", true, 8, function(st) TeamCheckEnabled = st end)

        -- SELECTOR VÙNG NGẮM (HEAD/THÂN/CHÂN)
        local PartBtn = Instance.new("TextButton")
        PartBtn.Size = UDim2.new(1, -6, 0, 42)
        PartBtn.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
        PartBtn.BackgroundTransparency = 0.25
        PartBtn.Text = "🎯 Vị Trí Ngắm: HEAD (Đầu)"
        PartBtn.TextColor3 = Color3.fromRGB(0, 240, 255)
        PartBtn.TextSize = 13
        PartBtn.Font = Enum.Font.FredokaOne
        PartBtn.LayoutOrder = 9
        PartBtn.Parent = Scroll

        local PartCorner = Instance.new("UICorner")
        PartCorner.CornerRadius = UDim.new(0, 12)
        PartCorner.Parent = PartBtn

        local partsList = {
            {name = "HEAD (Đầu)", part = "Head"},
            {name = "THÂN (Root)", part = "HumanoidRootPart"},
            {name = "CHÂN (Foot)", part = "LeftFoot"}
        }
        local partIdx = 1

        PartBtn.MouseButton1Click:Connect(function()
            partIdx = partIdx % #partsList + 1
            AimPart = partsList[partIdx].part
            PartBtn.Text = "🎯 Vị Trí Ngắm: " .. partsList[partIdx].name
        end)

        -- SECTION 3: FOV & ESP
        createToggleCard("⭕ Hiện Vòng Tròn FOV", true, 10, function(st)
            ShowFOV = st
            FOVCircle.Visible = st
        end)

        -- FOV SLIDER CARD
        local SliderCard = Instance.new("Frame")
        SliderCard.Size = UDim2.new(1, -6, 0, 55)
        SliderCard.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
        SliderCard.BackgroundTransparency = 0.25
        SliderCard.LayoutOrder = 11
        SliderCard.Parent = Scroll

        local SliderCorner = Instance.new("UICorner")
        SliderCorner.CornerRadius = UDim.new(0, 12)
        SliderCorner.Parent = SliderCard

        local SliderLabel = Instance.new("TextLabel")
        SliderLabel.Size = UDim2.new(1, -20, 0, 20)
        SliderLabel.Position = UDim2.new(0, 10, 0, 4)
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.Text = "📏 Kích Thước FOV: " .. FOVRadius
        SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        SliderLabel.TextSize = 12
        SliderLabel.Font = Enum.Font.FredokaOne
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        SliderLabel.Parent = SliderCard

        local SliderTrack = Instance.new("Frame")
        SliderTrack.Size = UDim2.new(1, -20, 0, 10)
        SliderTrack.Position = UDim2.new(0, 10, 0, 32)
        SliderTrack.BackgroundColor3 = Color3.fromRGB(40, 32, 55)
        SliderTrack.Parent = SliderCard

        local TrackCorner = Instance.new("UICorner")
        TrackCorner.CornerRadius = UDim.new(1, 0)
        TrackCorner.Parent = SliderTrack

        local SliderFill = Instance.new("Frame")
        SliderFill.Size = UDim2.new((FOVRadius - 30) / 470, 0, 1, 0)
        SliderFill.BackgroundColor3 = Color3.fromRGB(0, 240, 255)
        SliderFill.Parent = SliderTrack

        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(1, 0)
        FillCorner.Parent = SliderFill

        local isSliding = false
        local function updateSlider(input)
            local posX = math.clamp(input.Position.X - SliderTrack.AbsolutePosition.X, 0, SliderTrack.AbsoluteSize.X)
            local percentage = posX / SliderTrack.AbsoluteSize.X
            FOVRadius = math.floor(30 + (percentage * 470))
            FOVCircle.Radius = FOVRadius
            SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
            SliderLabel.Text = "📏 Kích Thước FOV: " .. FOVRadius
        end

        SliderTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isSliding = true
                updateSlider(input)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateSlider(input)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isSliding = false
            end
        end)

        createToggleCard("📦 ESP Box & Tên Player", false, 12, function(st) ESPEnabled = st end)
        createToggleCard("⚡ Đường Kẻ Tracer Địch", false, 13, function(st) TracersEnabled = st end)

        -- NÚT THU GỌN HUB TRÒN
        local ToggleMenuBtn = Instance.new("TextButton")
        ToggleMenuBtn.Size = UDim2.new(0, 52, 0, 52)
        ToggleMenuBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
        ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(15, 12, 24)
        ToggleMenuBtn.Text = "HUB"
        ToggleMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleMenuBtn.TextSize = 14
        ToggleMenuBtn.Font = Enum.Font.FredokaOne
        ToggleMenuBtn.AutoButtonColor = false
        ToggleMenuBtn.Parent = ScreenGui

        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(1, 0)
        ToggleCorner.Parent = ToggleMenuBtn

        local ToggleStroke = Instance.new("UIStroke")
        ToggleStroke.Thickness = 2.5
        ToggleStroke.Parent = ToggleMenuBtn

        makeDraggable(MainFrame)
        makeDraggable(ToggleMenuBtn)

        local menuVisible = true
        ToggleMenuBtn.MouseButton1Click:Connect(function()
            menuVisible = not menuVisible
            MainFrame.Visible = menuVisible
        end)

        -- INF JUMP LISTENER
        UserInputService.JumpRequest:Connect(function()
            if infJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            end
        end)

        -- RENDER LOOP MAIN
        RunService.RenderStepped:Connect(function()
            local rainbowColor = getRGBColor(3)
            UIStroke.Color = rainbowColor
            ToggleStroke.Color = rainbowColor
            TitleGradient.Rotation = (tick() * 90) % 360

            -- Handle Speed / Jump / Noclip
            if LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    if speedEnabled then hum.WalkSpeed = walkSpeedValue end
                    if jumpEnabled then hum.UseJumpPower = true; hum.JumpPower = jumpPowerValue end
                end

                if noclipEnabled then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end

            -- Handle FOV Center
            FOVCircle.Position = UserInputService:GetMouseLocation()

            -- Handle Aimbot Lock
            if AimbotEnabled then
                local target = getClosestPlayer()
                if target then
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), Sensitivity)
                end
            end

            -- Handle ESP & Tracers
            for player, drawings in pairs(ESP_Storage) do
                local char = player.Character
                local isSameTeam = TeamCheckEnabled and player.Team and LocalPlayer.Team and (player.Team == LocalPlayer.Team)

                if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") and char.Humanoid.Health > 0 and not isSameTeam then
                    local hrp = char.HumanoidRootPart
                    local head = char:FindFirstChild("Head") or hrp
                    local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

                    if onScreen then
                        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                        local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                        local height = math.abs(headPos.Y - legPos.Y)
                        local width = height / 1.6

                        if ESPEnabled then
                            drawings.Box.Size = Vector2.new(width, height)
                            drawings.Box.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
                            drawings.Box.Visible = true

                            local dist = math.floor((LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude) or 0)
                            drawings.Name.Text = player.Name .. " [" .. dist .. "m]"
                            drawings.Name.Position = Vector2.new(pos.X, pos.Y - height / 2 - 16)
                            drawings.Name.Visible = true
                        else
                            drawings.Box.Visible = false
                            drawings.Name.Visible = false
                        end

                        if TracersEnabled then
                            -- 👉 CẬP NHẬT: KÉO TỪ GIỮA TẬN CÙNG TRÊN ĐỈNH MÀN HÌNH (Y = 0) DÙNG ĐÂM XUỐNG ĐỊCH
                            drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, 0)
                            drawings.Tracer.To = Vector2.new(pos.X, pos.Y)
                            drawings.Tracer.Visible = true
                        else
                            drawings.Tracer.Visible = false
                        end
                    else
                        drawings.Box.Visible = false; drawings.Name.Visible = false; drawings.Tracer.Visible = false
                    end
                else
                    drawings.Box.Visible = false; drawings.Name.Visible = false; drawings.Tracer.Visible = false
                end
            end
        end)

        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "★ MRGHOST HUB VIP ★",
            Text = "Đã kích hoạt thành công All-In-One Hub!",
            Duration = 3
        })
    end

    -- =========================================================
    -- KEY SYSTEM UI
    -- =========================================================
    if isKeySavedValid() then
        loadMainHub()
    else
        local KeyFrame = Instance.new("Frame")
        KeyFrame.Name = "KeyFrame"
        KeyFrame.Size = UDim2.new(0, 320, 0, 245)
        KeyFrame.Position = UDim2.new(0.5, -160, 0.4, -122)
        KeyFrame.BackgroundColor3 = Color3.fromRGB(12, 10, 18)
        KeyFrame.Parent = ScreenGui

        local KeyCorner = Instance.new("UICorner")
        KeyCorner.CornerRadius = UDim.new(0, 16)
        KeyCorner.Parent = KeyFrame

        local KeyStroke = Instance.new("UIStroke")
        KeyStroke.Thickness = 2
        KeyStroke.Parent = KeyFrame

        RunService.RenderStepped:Connect(function()
            KeyStroke.Color = getRGBColor(3)
        end)

        local KeyTitle = Instance.new("TextLabel")
        KeyTitle.Size = UDim2.new(1, 0, 0, 35)
        KeyTitle.BackgroundTransparency = 1
        KeyTitle.Text = "🔑 MRGHOST KEY SYSTEM 💖"
        KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        KeyTitle.TextSize = 15
        KeyTitle.Font = Enum.Font.FredokaOne
        KeyTitle.Parent = KeyFrame

        task.spawn(function()
            while task.wait() do
                if KeyTitle.Parent then
                    TweenService:Create(KeyTitle, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextSize = 17}):Play()
                    task.wait(0.5)
                    TweenService:Create(KeyTitle, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextSize = 15}):Play()
                    task.wait(0.5)
                else break end
            end
        end)

        local KeyTextBox = Instance.new("TextBox")
        KeyTextBox.Size = UDim2.new(1, -32, 0, 34)
        KeyTextBox.Position = UDim2.new(0, 16, 0, 38)
        KeyTextBox.BackgroundColor3 = Color3.fromRGB(24, 20, 35)
        KeyTextBox.PlaceholderText = "Nhập Key VIP tại đây..."
        KeyTextBox.Text = ""
        KeyTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        KeyTextBox.TextSize = 13
        KeyTextBox.Font = Enum.Font.SourceSansBold
        KeyTextBox.Parent = KeyFrame

        local BoxCorner = Instance.new("UICorner")
        BoxCorner.CornerRadius = UDim.new(0, 8)
        BoxCorner.Parent = KeyTextBox

        local KeyNoteText = Instance.new("TextLabel")
        KeyNoteText.Size = UDim2.new(1, -32, 0, 18)
        KeyNoteText.Position = UDim2.new(0, 16, 0, 76)
        KeyNoteText.BackgroundTransparency = 1
        KeyNoteText.Text = "✨ Key vĩnh viễn (Get 1 lần duy nhất) ✨"
        KeyNoteText.TextColor3 = Color3.fromRGB(0, 240, 255)
        KeyNoteText.TextSize = 11
        KeyNoteText.Font = Enum.Font.SourceSansBold
        KeyNoteText.Parent = KeyFrame

        local CheckBtn = Instance.new("TextButton")
        CheckBtn.Size = UDim2.new(0.45, -4, 0, 34)
        CheckBtn.Position = UDim2.new(0, 16, 0, 98)
        CheckBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 120)
        CheckBtn.Text = "Check Key"
        CheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        CheckBtn.TextSize = 13
        CheckBtn.Font = Enum.Font.FredokaOne
        CheckBtn.Parent = KeyFrame

        local BtnCorner1 = Instance.new("UICorner")
        BtnCorner1.CornerRadius = UDim.new(0, 8)
        BtnCorner1.Parent = CheckBtn

        local GetKeyBtn = Instance.new("TextButton")
        GetKeyBtn.Size = UDim2.new(0.45, -4, 0, 34)
        GetKeyBtn.Position = UDim2.new(0.555, 0, 0, 98)
        GetKeyBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        GetKeyBtn.Text = "Discord Key"
        GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        GetKeyBtn.TextSize = 12
        GetKeyBtn.Font = Enum.Font.FredokaOne
        GetKeyBtn.Parent = GetKeyBtn

        local BtnCorner2 = Instance.new("UICorner")
        BtnCorner2.CornerRadius = UDim.new(0, 8)
        BtnCorner2.Parent = GetKeyBtn

        local BackupBtn = Instance.new("TextButton")
        BackupBtn.Size = UDim2.new(1, -32, 0, 32)
        BackupBtn.Position = UDim2.new(0, 16, 0, 140)
        BackupBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
        BackupBtn.Text = "🔗 Nếu ko có Discord dùng cái này"
        BackupBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        BackupBtn.TextSize = 12
        BackupBtn.Font = Enum.Font.FredokaOne
        BackupBtn.Parent = KeyFrame

        local BtnCorner3 = Instance.new("UICorner")
        BtnCorner3.CornerRadius = UDim.new(0, 8)
        BtnCorner3.Parent = BackupBtn

        local StatusText = Instance.new("TextLabel")
        StatusText.Size = UDim2.new(1, -32, 0, 22)
        StatusText.Position = UDim2.new(0, 16, 0, 182)
        StatusText.BackgroundTransparency = 1
        StatusText.Text = "Chọn hình thức lấy key để tiếp tục"
        StatusText.TextColor3 = Color3.fromRGB(180, 180, 180)
        StatusText.TextSize = 12
        StatusText.Font = Enum.Font.SourceSans
        StatusText.Parent = KeyFrame

        makeDraggable(KeyFrame)

        GetKeyBtn.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard(KEY_LINK)
                StatusText.Text = "✅ Đã copy link Discord!"
                StatusText.TextColor3 = Color3.fromRGB(0, 255, 120)
            end
        end)

        BackupBtn.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard(BACKUP_LINK)
                StatusText.Text = "✅ Đã copy link Fnote!"
                StatusText.TextColor3 = Color3.fromRGB(255, 200, 0)
            end
        end)

        CheckBtn.MouseButton1Click:Connect(function()
            if KeyTextBox.Text == CORRECT_KEY then
                StatusText.Text = "🎉 Key đúng! Đang tải Hub..."
                StatusText.TextColor3 = Color3.fromRGB(0, 255, 120)
                saveKeyCache(KeyTextBox.Text)
                task.wait(1)
                KeyFrame:Destroy()
                loadMainHub()
            else
                StatusText.Text = "❌ Key không chính xác!"
                StatusText.TextColor3 = Color3.fromRGB(255, 50, 50)
            end
        end)
    end
end)
