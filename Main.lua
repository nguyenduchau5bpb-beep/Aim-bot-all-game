-- [[ MRGHOST HUB VIP - UNIVERSAL FOR ALL ROBLOX GAMES ]]
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
    local EXPIRE_TIME = 86400

    -- Config Features
    local walkSpeedValue = 50
    local speedEnabled = false
    local jumpPowerValue = 120
    local jumpEnabled = false
    local infJumpEnabled = false
    local noclipEnabled = false

    local AimbotEnabled = false
    local AimPart = "Head"
    local Sensitivity = 0.25

    local ShowFOV = true
    local FOVRadius = 120

    local ESPEnabled = false
    local TracersEnabled = false
    local TeamCheckEnabled = false -- Mặc định tắt để All Game đều ngắm được ngay!

    -- Universal GUI Container
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MrGhostHub_UniversalAllGames"
    local guiParent = (gethui and gethui()) or CoreGui or (LocalPlayer and LocalPlayer:WaitForChild("PlayerGui"))
    ScreenGui.Parent = guiParent
    ScreenGui.ResetOnSpawn = false

    -- Fast RGB
    local function getRGBColor(speed)
        speed = speed or 3
        return Color3.fromHSV((tick() % speed) / speed, 0.8, 1)
    end

    -- ⭕ PERFECT FOV CIRCLE (UI FRAME)
    local FOVFrame = Instance.new("Frame")
    FOVFrame.Name = "FOVCircleFrame"
    FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    FOVFrame.Size = UDim2.new(0, FOVRadius * 2, 0, FOVRadius * 2)
    FOVFrame.BackgroundTransparency = 1
    FOVFrame.Visible = ShowFOV
    FOVFrame.Parent = ScreenGui

    local FOVCorner = Instance.new("UICorner")
    FOVCorner.CornerRadius = UDim.new(1, 0)
    FOVCorner.Parent = FOVFrame

    local FOVStroke = Instance.new("UIStroke")
    FOVStroke.Thickness = 2
    FOVStroke.Color = Color3.fromRGB(0, 240, 255)
    FOVStroke.Transparency = 0.1
    FOVStroke.Parent = FOVFrame

    -- Key Cache System
    local function isKeySavedValid()
        if readfile and isfile and isfile(CACHE_FILE) then
            local successRead, data = pcall(function() return HttpService:JSONDecode(readfile(CACHE_FILE)) end)
            if successRead and data and data.key == CORRECT_KEY and data.time then
                if (os.time() - data.time) < EXPIRE_TIME then return true end
            end
        end
        return false
    end

    local function saveKeyCache(key)
        if writefile then
            pcall(function() writefile(CACHE_FILE, HttpService:JSONEncode({ key = key, time = os.time() })) end)
        end
    end

    -- Draggable Optimization
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

    -- 👥 HÀM KIỂM TRA TEAM UNIVERSAL (CHO TẤT CẢ GAME)
    local function isTeammate(player)
        if not TeamCheckEnabled then return false end
        if player == LocalPlayer then return true end

        -- 1. Standard Roblox Team
        if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
            return true
        end
        if player.TeamColor and LocalPlayer.TeamColor and player.TeamColor == LocalPlayer.TeamColor then
            return true
        end

        -- 2. Leaderstats & Custom Attributes
        local pTeam = player:FindFirstChild("Team") or player:GetAttribute("Team") or (player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Team"))
        local myTeam = LocalPlayer:FindFirstChild("Team") or LocalPlayer:GetAttribute("Team") or (LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Team"))

        if pTeam and myTeam then
            local pVal = (type(pTeam) == "userdata" and pTeam.Value) or pTeam
            local myVal = (type(myTeam) == "userdata" and myTeam.Value) or myTeam
            if pVal == myVal then return true end
        end

        return false
    end

    -- 🎯 AIMBOT UNIVERSAL
    local function getClosestEnemy()
        local closestTarget = nil
        local shortestDistance = FOVRadius
        local centerPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if not isTeammate(player) then
                    local targetPart = player.Character:FindFirstChild(AimPart) or player.Character:FindFirstChild("HumanoidRootPart")
                    local hum = player.Character:FindFirstChildOfClass("Humanoid")

                    if hum and hum.Health > 0 and targetPart then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen then
                            local distance = (Vector2.new(screenPos.X, screenPos.Y) - centerPos).Magnitude
                            if distance < shortestDistance then
                                shortestDistance = distance
                                closestTarget = targetPart
                            end
                        end
                    end
                end
            end
        end
        return closestTarget
    end

    -- ESP Storage
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
        drawings.Name.Size = 12
        drawings.Name.Center = true
        drawings.Name.Outline = true
        drawings.Name.Color = Color3.fromRGB(255, 255, 255)
        drawings.Tracer.Thickness = 1.2
        ESP_Storage[player] = drawings
    end

    local function removeESP(player)
        if ESP_Storage[player] then
            pcall(function()
                ESP_Storage[player].Box:Remove()
                ESP_Storage[player].Name:Remove()
                ESP_Storage[player].Tracer:Remove()
            end)
            ESP_Storage[player] = nil
        end
    end

    for _, player in pairs(Players:GetPlayers()) do createESP(player) end
    Players.PlayerAdded:Connect(createESP)
    Players.PlayerRemoving:Connect(removeESP)

    -- MAIN HUB UI
    local function loadMainHub()
        local MainFrame = Instance.new("Frame")
        MainFrame.Name = "MainFrame"
        MainFrame.Size = UDim2.new(0, 330, 0, 420)
        MainFrame.Position = UDim2.new(0.5, -165, 0.3, -210)
        MainFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 26)
        MainFrame.BackgroundTransparency = 0.15
        MainFrame.BorderSizePixel = 0
        MainFrame.Parent = ScreenGui

        local MainCorner = Instance.new("UICorner")
        MainCorner.CornerRadius = UDim.new(0, 16)
        MainCorner.Parent = MainFrame

        local UIStroke = Instance.new("UIStroke")
        UIStroke.Thickness = 2
        UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        UIStroke.Parent = MainFrame

        -- Title Bar
        local TitleBar = Instance.new("Frame")
        TitleBar.Size = UDim2.new(1, 0, 0, 46)
        TitleBar.BackgroundColor3 = Color3.fromRGB(22, 25, 38)
        TitleBar.BackgroundTransparency = 0.2
        TitleBar.Parent = MainFrame

        local TitleBarCorner = Instance.new("UICorner")
        TitleBarCorner.CornerRadius = UDim.new(0, 16)
        TitleBarCorner.Parent = TitleBar

        local LogoIcon = Instance.new("TextLabel")
        LogoIcon.Size = UDim2.new(0, 30, 0, 30)
        LogoIcon.Position = UDim2.new(0, 10, 0.5, -15)
        LogoIcon.BackgroundColor3 = Color3.fromRGB(255, 0, 110)
        LogoIcon.Text = "👻"
        LogoIcon.TextSize = 15
        LogoIcon.Parent = TitleBar

        local LogoCorner = Instance.new("UICorner")
        LogoCorner.CornerRadius = UDim.new(0, 8)
        LogoCorner.Parent = LogoIcon

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(0, 160, 1, 0)
        Title.Position = UDim2.new(0, 48, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Text = "MrGhost Hub VIP"
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextSize = 15
        Title.Font = Enum.Font.GothamBold
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = TitleBar

        local HeartLabel = Instance.new("TextLabel")
        HeartLabel.Size = UDim2.new(0, 80, 1, 0)
        HeartLabel.Position = UDim2.new(1, -88, 0, 0)
        HeartLabel.BackgroundTransparency = 1
        HeartLabel.Text = "💖 TTTT"
        HeartLabel.TextColor3 = Color3.fromRGB(255, 120, 190)
        HeartLabel.TextSize = 12
        HeartLabel.Font = Enum.Font.GothamBold
        HeartLabel.Parent = TitleBar

        -- Scrolling Container
        local Scroll = Instance.new("ScrollingFrame")
        Scroll.Size = UDim2.new(1, -16, 1, -54)
        Scroll.Position = UDim2.new(0, 8, 0, 50)
        Scroll.BackgroundTransparency = 1
        Scroll.BorderSizePixel = 0
        Scroll.ScrollBarThickness = 3
        Scroll.CanvasSize = UDim2.new(0, 0, 0, 710)
        Scroll.Parent = MainFrame

        local UIList = Instance.new("UIListLayout")
        UIList.Parent = Scroll
        UIList.SortOrder = Enum.SortOrder.LayoutOrder
        UIList.Padding = UDim.new(0, 6)

        -- Helper Toggles
        local function createToggleCard(titleText, defaultState, layoutOrder, callback)
            local Card = Instance.new("Frame")
            Card.Size = UDim2.new(1, -4, 0, 40)
            Card.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
            Card.BackgroundTransparency = 0.2
            Card.LayoutOrder = layoutOrder
            Card.Parent = Scroll

            local CardCorner = Instance.new("UICorner")
            CardCorner.CornerRadius = UDim.new(0, 8)
            CardCorner.Parent = Card

            local CardLabel = Instance.new("TextLabel")
            CardLabel.Size = UDim2.new(0.7, 0, 1, 0)
            CardLabel.Position = UDim2.new(0, 12, 0, 0)
            CardLabel.BackgroundTransparency = 1
            CardLabel.Text = titleText
            CardLabel.TextColor3 = Color3.fromRGB(230, 235, 245)
            CardLabel.TextSize = 12
            CardLabel.Font = Enum.Font.GothamMedium
            CardLabel.TextXAlignment = Enum.TextXAlignment.Left
            CardLabel.Parent = Card

            local SwitchBg = Instance.new("TextButton")
            SwitchBg.Size = UDim2.new(0, 44, 0, 22)
            SwitchBg.Position = UDim2.new(1, -50, 0.5, -11)
            SwitchBg.BackgroundColor3 = defaultState and Color3.fromRGB(255, 0, 110) or Color3.fromRGB(45, 52, 75)
            SwitchBg.Text = ""
            SwitchBg.AutoButtonColor = false
            SwitchBg.Parent = Card

            local SwitchCorner = Instance.new("UICorner")
            SwitchCorner.CornerRadius = UDim.new(1, 0)
            SwitchCorner.Parent = SwitchBg

            local SwitchDot = Instance.new("Frame")
            SwitchDot.Size = UDim2.new(0, 16, 0, 16)
            SwitchDot.Position = defaultState and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            SwitchDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SwitchDot.Parent = SwitchBg

            local SwitchDotCorner = Instance.new("UICorner")
            SwitchDotCorner.CornerRadius = UDim.new(1, 0)
            SwitchDotCorner.Parent = SwitchDot

            local enabled = defaultState
            SwitchBg.MouseButton1Click:Connect(function()
                enabled = not enabled
                if enabled then
                    TweenService:Create(SwitchBg, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 0, 110)}):Play()
                    TweenService:Create(SwitchDot, TweenInfo.new(0.15), {Position = UDim2.new(1, -19, 0.5, -8)}):Play()
                else
                    TweenService:Create(SwitchBg, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(45, 52, 75)}):Play()
                    TweenService:Create(SwitchDot, TweenInfo.new(0.15), {Position = UDim2.new(0, 3, 0.5, -8)}):Play()
                end
                callback(enabled)
            end)
            return Card
        end

        local function createInputCard(titleText, placeholderText, defaultVal, layoutOrder, callback)
            local Card = Instance.new("Frame")
            Card.Size = UDim2.new(1, -4, 0, 56)
            Card.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
            Card.BackgroundTransparency = 0.2
            Card.LayoutOrder = layoutOrder
            Card.Parent = Scroll

            local CardCorner = Instance.new("UICorner")
            CardCorner.CornerRadius = UDim.new(0, 8)
            CardCorner.Parent = Card

            local InputLabel = Instance.new("TextLabel")
            InputLabel.Size = UDim2.new(1, -20, 0, 18)
            InputLabel.Position = UDim2.new(0, 10, 0, 4)
            InputLabel.BackgroundTransparency = 1
            InputLabel.Text = titleText
            InputLabel.TextColor3 = Color3.fromRGB(0, 230, 255)
            InputLabel.TextSize = 11
            InputLabel.Font = Enum.Font.GothamMedium
            InputLabel.TextXAlignment = Enum.TextXAlignment.Left
            InputLabel.Parent = Card

            local TextBox = Instance.new("TextBox")
            TextBox.Size = UDim2.new(1, -20, 0, 24)
            TextBox.Position = UDim2.new(0, 10, 0, 24)
            TextBox.BackgroundColor3 = Color3.fromRGB(16, 18, 28)
            TextBox.Text = tostring(defaultVal)
            TextBox.PlaceholderText = placeholderText
            TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextBox.TextSize = 12
            TextBox.Font = Enum.Font.Gotham
            TextBox.ClearTextOnFocus = false
            TextBox.Parent = Card

            local BoxCorner = Instance.new("UICorner")
            BoxCorner.CornerRadius = UDim.new(0, 6)
            BoxCorner.Parent = TextBox

            TextBox.FocusLost:Connect(function()
                local num = tonumber(TextBox.Text)
                if num then callback(num) else TextBox.Text = tostring(defaultVal) end
            end)
            return Card
        end

        -- DÀN TÍNH NĂNG
        createToggleCard("⚡ Chạy Nhanh (WalkSpeed)", false, 1, function(st) speedEnabled = st end)
        createInputCard("🏃 Tốc Độ Di Chuyển", "Nhập Speed...", 50, 2, function(val) walkSpeedValue = val end)

        createToggleCard("🦘 Nhảy Cao (JumpPower)", false, 3, function(st) jumpEnabled = st end)
        createInputCard("💥 Sức Nhảy", "Nhập JumpPower...", 120, 4, function(val) jumpPowerValue = val end)

        createToggleCard("🌌 Infinite Jump (Nhảy Trên Không)", false, 5, function(st) infJumpEnabled = st end)
        createToggleCard("👻 Noclip (Đi Xuyên Tường)", false, 6, function(st) noclipEnabled = st end)

        createToggleCard("🎯 Aim Lock (Tự Khóa Địch)", false, 7, function(st) AimbotEnabled = st end)

        createToggleCard("👥 Bật Chia Team (Đồng Minh/Địch)", false, 8, function(st) TeamCheckEnabled = st end)

        local PartBtn = Instance.new("TextButton")
        PartBtn.Size = UDim2.new(1, -4, 0, 36)
        PartBtn.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
        PartBtn.BackgroundTransparency = 0.2
        PartBtn.Text = "🎯 Vị Trí Ngắm: HEAD (Đầu)"
        PartBtn.TextColor3 = Color3.fromRGB(0, 230, 255)
        PartBtn.TextSize = 12
        PartBtn.Font = Enum.Font.GothamMedium
        PartBtn.LayoutOrder = 9
        PartBtn.Parent = Scroll

        local PartCorner = Instance.new("UICorner")
        PartCorner.CornerRadius = UDim.new(0, 8)
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

        createToggleCard("⭕ Hiện Vòng Tròn FOV", true, 10, function(st) 
            ShowFOV = st 
            FOVFrame.Visible = st
        end)

        -- Slider FOV
        local SliderCard = Instance.new("Frame")
        SliderCard.Size = UDim2.new(1, -4, 0, 48)
        SliderCard.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
        SliderCard.BackgroundTransparency = 0.2
        SliderCard.LayoutOrder = 11
        SliderCard.Parent = Scroll

        local SliderCorner = Instance.new("UICorner")
        SliderCorner.CornerRadius = UDim.new(0, 8)
        SliderCorner.Parent = SliderCard

        local SliderLabel = Instance.new("TextLabel")
        SliderLabel.Size = UDim2.new(1, -20, 0, 16)
        SliderLabel.Position = UDim2.new(0, 10, 0, 4)
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.Text = "📏 Kích Thước FOV: " .. FOVRadius
        SliderLabel.TextColor3 = Color3.fromRGB(230, 235, 245)
        SliderLabel.TextSize = 11
        SliderLabel.Font = Enum.Font.GothamMedium
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        SliderLabel.Parent = SliderCard

        local SliderTrack = Instance.new("Frame")
        SliderTrack.Size = UDim2.new(1, -20, 0, 6)
        SliderTrack.Position = UDim2.new(0, 10, 0, 26)
        SliderTrack.BackgroundColor3 = Color3.fromRGB(16, 18, 28)
        SliderTrack.Parent = SliderCard

        local SliderTrackCorner = Instance.new("UICorner")
        SliderTrackCorner.CornerRadius = UDim.new(1, 0)
        SliderTrackCorner.Parent = SliderTrack

        local SliderFill = Instance.new("Frame")
        SliderFill.Size = UDim2.new((FOVRadius - 30) / 470, 0, 1, 0)
        SliderFill.BackgroundColor3 = Color3.fromRGB(0, 230, 255)
        SliderFill.Parent = SliderTrack

        local SliderFillCorner = Instance.new("UICorner")
        SliderFillCorner.CornerRadius = UDim.new(1, 0)
        SliderFillCorner.Parent = SliderFill

        local isSliding = false
        local function updateSlider(input)
            local posX = math.clamp(input.Position.X - SliderTrack.AbsolutePosition.X, 0, SliderTrack.AbsoluteSize.X)
            local percentage = posX / SliderTrack.AbsoluteSize.X
            FOVRadius = math.floor(30 + (percentage * 470))
            SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
            SliderLabel.Text = "📏 Kích Thước FOV: " .. FOVRadius
            FOVFrame.Size = UDim2.new(0, FOVRadius * 2, 0, FOVRadius * 2)
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
        createToggleCard("⚡ Đường Kẻ Tracer Player", false, 13, function(st) TracersEnabled = st end)

        -- NÚT THU GỌN HUB TRÒN
        local ToggleMenuBtn = Instance.new("TextButton")
        ToggleMenuBtn.Size = UDim2.new(0, 46, 0, 46)
        ToggleMenuBtn.Position = UDim2.new(0.04, 0, 0.2, 0)
        ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(15, 17, 26)
        ToggleMenuBtn.Text = "👻"
        ToggleMenuBtn.TextSize = 18
        ToggleMenuBtn.Parent = ScreenGui

        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(1, 0)
        ToggleCorner.Parent = ToggleMenuBtn

        local ToggleStroke = Instance.new("UIStroke")
        ToggleStroke.Thickness = 2
        ToggleStroke.Parent = ToggleMenuBtn

        makeDraggable(MainFrame)
        makeDraggable(ToggleMenuBtn)

        local menuVisible = true
        ToggleMenuBtn.MouseButton1Click:Connect(function()
            menuVisible = not menuVisible
            MainFrame.Visible = menuVisible
        end)

        -- INF JUMP
        UserInputService.JumpRequest:Connect(function()
            if infJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            end
        end)

        -- NOCLIP
        RunService.Stepped:Connect(function()
            if noclipEnabled and LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)

        -- RENDER LOOP
        RunService.RenderStepped:Connect(function()
            local rainbowColor = getRGBColor(3)
            UIStroke.Color = rainbowColor
            ToggleStroke.Color = rainbowColor

            -- WalkSpeed & JumpPower
            if LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    if speedEnabled then hum.WalkSpeed = walkSpeedValue end
                    if jumpEnabled then hum.UseJumpPower = true; hum.JumpPower = jumpPowerValue end
                end
            end

            -- AIMBOT LOCK
            if AimbotEnabled then
                local target = getClosestEnemy()
                if target then
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), Sensitivity)
                end
            end

            -- ESP & TRACER RENDERING
            for player, drawings in pairs(ESP_Storage) do
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") and char.Humanoid.Health > 0 then
                    local hrp = char.HumanoidRootPart
                    local head = char:FindFirstChild("Head") or hrp
                    local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

                    local teammate = isTeammate(player)
                    local espColor = teammate and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 50, 50)

                    if onScreen then
                        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                        local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                        local height = math.abs(headPos.Y - legPos.Y)
                        local width = height / 1.6

                        if ESPEnabled then
                            drawings.Box.Size = Vector2.new(width, height)
                            drawings.Box.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
                            drawings.Box.Color = espColor
                            drawings.Box.Visible = true

                            local dist = math.floor((LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude) or 0)
                            local teamTag = teammate and " [ĐỒNG MINH]" or " [MỤC TIÊU]"
                            drawings.Name.Text = player.Name .. teamTag .. " [" .. dist .. "m]"
                            drawings.Name.Position = Vector2.new(pos.X, pos.Y - height / 2 - 15)
                            drawings.Name.Visible = true
                        else
                            drawings.Box.Visible = false; drawings.Name.Visible = false
                        end

                        if TracersEnabled then
                            drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X * 0.5, 0)
                            drawings.Tracer.To = Vector2.new(pos.X, pos.Y)
                            drawings.Tracer.Color = espColor
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
            Text = "Đã kích hoạt Universal All Games!",
            Duration = 3
        })
    end

    -- KEY SYSTEM UI
    if isKeySavedValid() then
        loadMainHub()
    else
        local KeyFrame = Instance.new("Frame")
        KeyFrame.Name = "KeyFrame"
        KeyFrame.Size = UDim2.new(0, 290, 0, 210)
        KeyFrame.Position = UDim2.new(0.5, -145, 0.4, -105)
        KeyFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 26)
        KeyFrame.Parent = ScreenGui

        local KeyCorner = Instance.new("UICorner")
        KeyCorner.CornerRadius = UDim.new(0, 14)
        KeyCorner.Parent = KeyFrame

        local KeyStroke = Instance.new("UIStroke")
        KeyStroke.Thickness = 2
        KeyStroke.Parent = KeyFrame

        RunService.RenderStepped:Connect(function() KeyStroke.Color = getRGBColor(3) end)

        local KeyTitle = Instance.new("TextLabel")
        KeyTitle.Size = UDim2.new(1, 0, 0, 35)
        KeyTitle.BackgroundTransparency = 1
        KeyTitle.Text = "🔑 KEY SYSTEM VIP 💖"
        KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        KeyTitle.TextSize = 14
        KeyTitle.Font = Enum.Font.GothamBold
        KeyTitle.Parent = KeyFrame

        local KeyTextBox = Instance.new("TextBox")
        KeyTextBox.Size = UDim2.new(1, -28, 0, 32)
        KeyTextBox.Position = UDim2.new(0, 14, 0, 38)
        KeyTextBox.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
        KeyTextBox.PlaceholderText = "Nhập Key VIP..."
        KeyTextBox.Text = ""
        KeyTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        KeyTextBox.TextSize = 12
        KeyTextBox.Font = Enum.Font.Gotham
        KeyTextBox.Parent = KeyFrame

        local BoxCorner = Instance.new("UICorner")
        BoxCorner.CornerRadius = UDim.new(0, 6)
        BoxCorner.Parent = KeyTextBox

        local CheckBtn = Instance.new("TextButton")
        CheckBtn.Size = UDim2.new(0.46, -4, 0, 32)
        CheckBtn.Position = UDim2.new(0, 14, 0, 80)
        CheckBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 110)
        CheckBtn.Text = "Check Key"
        CheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        CheckBtn.TextSize = 12
        CheckBtn.Font = Enum.Font.GothamBold
        CheckBtn.Parent = KeyFrame

        local BtnCorner1 = Instance.new("UICorner")
        BtnCorner1.CornerRadius = UDim.new(0, 6)
        BtnCorner1.Parent = CheckBtn

        local GetKeyBtn = Instance.new("TextButton")
        GetKeyBtn.Size = UDim2.new(0.46, -4, 0, 32)
        GetKeyBtn.Position = UDim2.new(0.54, 0, 0, 80)
        GetKeyBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        GetKeyBtn.Text = "Discord Key"
        GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        GetKeyBtn.TextSize = 12
        GetKeyBtn.Font = Enum.Font.GothamBold
        GetKeyBtn.Parent = KeyFrame

        local BackupBtn = Instance.new("TextButton")
        BackupBtn.Size = UDim2.new(1, -28, 0, 30)
        BackupBtn.Position = UDim2.new(0, 14, 0, 120)
        BackupBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
        BackupBtn.Text = "🔗 Copy Link Lấy Key"
        BackupBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        BackupBtn.TextSize = 11
        BackupBtn.Font = Enum.Font.GothamBold
        BackupBtn.Parent = KeyFrame

        local BtnCorner3 = Instance.new("UICorner")
        BtnCorner3.CornerRadius = UDim.new(0, 6)
        BtnCorner3.Parent = BackupBtn

        local StatusText = Instance.new("TextLabel")
        StatusText.Size = UDim2.new(1, -28, 0, 20)
        StatusText.Position = UDim2.new(0, 14, 0, 156)
        StatusText.BackgroundTransparency = 1
        StatusText.Text = "Nhập key 'TTTT' để bắt đầu"
        StatusText.TextColor3 = Color3.fromRGB(160, 170, 190)
        StatusText.TextSize = 11
        StatusText.Font = Enum.Font.Gotham
        StatusText.Parent = KeyFrame

        makeDraggable(KeyFrame)

        GetKeyBtn.MouseButton1Click:Connect(function()
            if setclipboard then setclipboard(KEY_LINK); StatusText.Text = "✅ Đã copy link Discord!" end
        end)

        BackupBtn.MouseButton1Click:Connect(function()
            if setclipboard then setclipboard(BACKUP_LINK); StatusText.Text = "✅ Đã copy link Fnote!" end
        end)

        CheckBtn.MouseButton1Click:Connect(function()
            if KeyTextBox.Text == CORRECT_KEY then
                StatusText.Text = "🎉 Đang tải Hub..."
                saveKeyCache(KeyTextBox.Text)
                task.wait(0.3)
                KeyFrame:Destroy()
                loadMainHub()
            else
                StatusText.Text = "❌ Key sai rồi anh ơi!"
            end
        end)
    end
end)
 
