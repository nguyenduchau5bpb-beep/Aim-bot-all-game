-- [[ MRGHOST HUB VIP - FLUENT UI & FIXED FOV EDITION ]]
local success, err = pcall(function()

    -- Load Fluent Library
    local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

    -- Services
    local CoreGui = game:GetService("CoreGui")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local HttpService = game:GetService("HttpService")

    local LocalPlayer = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera

    -- Key Config System
    local CORRECT_KEY = "TTTT"
    local KEY_LINK = "https://discord.gg/KDTDZjYSR"
    local BACKUP_LINK = "https://fnote.net/notes/jv9G9J"
    local CACHE_FILE = "MrGhostVIP_KeyCache.json"
    local EXPIRE_TIME = 86400

    -- Variable Configs
    local walkSpeedValue = 50
    local speedEnabled = false
    local jumpPowerValue = 120
    local jumpEnabled = false
    local infJumpEnabled = false
    local noclipEnabled = false

    local AimbotEnabled = false
    local AimPart = "Head"
    local Sensitivity = 0.2

    local ShowFOV = true
    local FOVRadius = 120

    local ESPEnabled = false
    local TracersEnabled = false

    -- Universal ScreenGui Container
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MrGhostHub_FluentVIP"
    local guiParent = (gethui and gethui()) or CoreGui or (LocalPlayer and LocalPlayer:WaitForChild("PlayerGui"))
    ScreenGui.Parent = guiParent
    ScreenGui.ResetOnSpawn = false

    -- Key Cache Functions
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

    -- =========================================================
    -- ⭕ PERFECT FOV CIRCLE (UI FRAME - GUARANTEED VISIBLE 100%)
    -- =========================================================
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
    FOVStroke.Transparency = 0.2
    FOVStroke.Parent = FOVFrame

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

    -- Target Aimbot (Kẻ địch)
    local function getClosestEnemy()
        local closestPlayer = nil
        local shortestDistance = FOVRadius
        local centerPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local isEnemy = true
                if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
                    isEnemy = false
                end

                if isEnemy then
                    local targetPart = player.Character:FindFirstChild(AimPart) or player.Character:FindFirstChild("HumanoidRootPart")
                    local hum = player.Character:FindFirstChildOfClass("Humanoid")

                    if hum and hum.Health > 0 and targetPart then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen then
                            local distance = (Vector2.new(screenPos.X, screenPos.Y) - centerPos).Magnitude
                            if distance < shortestDistance then
                                shortestDistance = distance
                                closestPlayer = targetPart
                            end
                        end
                    end
                end
            end
        end
        return closestPlayer
    end

    -- =========================================================
    -- MAIN HUB LOADER
    -- =========================================================
    local function loadMainHub()
        local Window = Fluent:CreateWindow({
            Title = "MrGhost Hub VIP 👻",
            SubTitle = "by MrGhost | Key: TTTT 💖",
            TabWidth = 140,
            Size = UDim2.fromOffset(530, 360),
            Theme = "Darker",
            MinimizeKey = Enum.KeyCode.LeftControl
        })

        local Tabs = {
            Main = Window:AddTab({ Title = "⚡ Nhân Vật", Icon = "user" }),
            Combat = Window:AddTab({ Title = "🎯 Aimbot & FOV", Icon = "target" }),
            Visuals = Window:AddTab({ Title = "👁️ ESP Nhìn Xuyên", Icon = "eye" })
        }

        -- TAB 1: NHÂN VẬT
        Tabs.Main:AddToggle("SpeedToggle", {
            Title = "⚡ Bật Chạy Nhanh (WalkSpeed)",
            Default = false,
            Callback = function(Value) speedEnabled = Value end
        })

        Tabs.Main:AddSlider("SpeedSlider", {
            Title = "🏃 Tốc Độ Di Chuyển",
            Default = 50,
            Min = 16,
            Max = 300,
            Rounding = 0,
            Callback = function(Value) walkSpeedValue = Value end
        })

        Tabs.Main:AddToggle("JumpToggle", {
            Title = "🦘 Bật Nhảy Cao (JumpPower)",
            Default = false,
            Callback = function(Value) jumpEnabled = Value end
        })

        Tabs.Main:AddSlider("JumpSlider", {
            Title = "💥 Sức Nhảy",
            Default = 120,
            Min = 50,
            Max = 500,
            Rounding = 0,
            Callback = function(Value) jumpPowerValue = Value end
        })

        Tabs.Main:AddToggle("InfJumpToggle", {
            Title = "🌌 Infinite Jump (Nhảy Trên Không)",
            Default = false,
            Callback = function(Value) infJumpEnabled = Value end
        })

        Tabs.Main:AddToggle("NoclipToggle", {
            Title = "👻 Noclip (Đi Xuyên Tường)",
            Default = false,
            Callback = function(Value) noclipEnabled = Value end
        })

        -- TAB 2: AIMBOT & FOV
        Tabs.Combat:AddToggle("AimToggle", {
            Title = "🎯 Aim Lock (Tự Khóa Địch)",
            Default = false,
            Callback = function(Value) AimbotEnabled = Value end
        })

        Tabs.Combat:AddDropdown("AimPartDropdown", {
            Title = "🎯 Vị Trí Ngắm",
            Values = {"Head", "HumanoidRootPart", "LeftFoot"},
            Default = "Head",
            Callback = function(Value) AimPart = Value end
        })

        Tabs.Combat:AddToggle("FOVToggle", {
            Title = "⭕ Hiện Vòng Tròn FOV",
            Default = true,
            Callback = function(Value)
                ShowFOV = Value
                FOVFrame.Visible = Value
            end
        })

        Tabs.Combat:AddSlider("FOVSlider", {
            Title = "📏 Kích Thước Vòng FOV",
            Default = 120,
            Min = 30,
            Max = 500,
            Rounding = 0,
            Callback = function(Value)
                FOVRadius = Value
                FOVFrame.Size = UDim2.new(0, FOVRadius * 2, 0, FOVRadius * 2)
            end
        })

        -- TAB 3: ESP
        Tabs.Visuals:AddToggle("ESPToggle", {
            Title = "📦 ESP Box & Tên Player",
            Default = false,
            Callback = function(Value) ESPEnabled = Value end
        })

        Tabs.Visuals:AddToggle("TracerToggle", {
            Title = "⚡ Đường Kẻ Tracer Player",
            Default = false,
            Callback = function(Value) TracersEnabled = Value end
        })

        -- NÚT NỔI THU GỌN (TOGGLE BUTTON) CỰC ĐẸP & MƯỢT
        local ToggleMenuBtn = Instance.new("ImageButton")
        ToggleMenuBtn.Name = "MrGhostToggleButton"
        ToggleMenuBtn.Size = UDim2.new(0, 48, 0, 48)
        ToggleMenuBtn.Position = UDim2.new(0.03, 0, 0.25, 0)
        ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(15, 17, 26)
        ToggleMenuBtn.Image = "rbxassetid://10747373176" -- Icon 👻 VIP Modern
        ToggleMenuBtn.ImageColor3 = Color3.fromRGB(0, 240, 255)
        ToggleMenuBtn.Parent = ScreenGui

        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(1, 0)
        ToggleCorner.Parent = ToggleMenuBtn

        local ToggleStroke = Instance.new("UIStroke")
        ToggleStroke.Thickness = 2.5
        ToggleStroke.Color = Color3.fromRGB(255, 0, 110)
        ToggleStroke.Parent = ToggleMenuBtn

        -- Smooth Drag cho Nút Phụ
        local dragging, dragInput, dragStart, startPos
        ToggleMenuBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = ToggleMenuBtn.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        ToggleMenuBtn.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                ToggleMenuBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)

        ToggleMenuBtn.MouseButton1Click:Connect(function()
            Window:Minimize()
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

        -- MAIN RENDER LOOP
        RunService.RenderStepped:Connect(function()
            -- WalkSpeed & JumpPower
            if LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    if speedEnabled then hum.WalkSpeed = walkSpeedValue end
                    if jumpEnabled then hum.UseJumpPower = true; hum.JumpPower = jumpPowerValue end
                end
            end

            -- Aimbot
            if AimbotEnabled then
                local target = getClosestEnemy()
                if target then
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), Sensitivity)
                end
            end

            -- ESP Rendring
            for player, drawings in pairs(ESP_Storage) do
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") and char.Humanoid.Health > 0 then
                    local hrp = char.HumanoidRootPart
                    local head = char:FindFirstChild("Head") or hrp
                    local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

                    local isTeammate = player.Team and LocalPlayer.Team and (player.Team == LocalPlayer.Team)
                    local espColor = isTeammate and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(255, 50, 50)

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
                            local teamTag = isTeammate and " [ĐỒNG MINH]" or " [ĐỊCH]"
                            drawings.Name.Text = player.Name .. teamTag .. " [" .. dist .. "m]"
                            drawings.Name.Position = Vector2.new(pos.X, pos.Y - height / 2 - 15)
                            drawings.Name.Visible = true
                        else
                            drawings.Box.Visible = false; drawings.Name.Visible = false
                        end

                        if TracersEnabled then
                            drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y)
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

        Fluent:Notify({
            Title = "MrGhost Hub VIP",
            Content = "Đã tải giao diện Fluent VIP & Fix FOV thành công!",
            Duration = 4
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
        KeyFrame.Size = UDim2.new(0, 300, 0, 220)
        KeyFrame.Position = UDim2.new(0.5, -150, 0.4, -110)
        KeyFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 26)
        KeyFrame.Parent = ScreenGui

        local KeyCorner = Instance.new("UICorner")
        KeyCorner.CornerRadius = UDim.new(0, 16)
        KeyCorner.Parent = KeyFrame

        local KeyStroke = Instance.new("UIStroke")
        KeyStroke.Thickness = 2
        KeyStroke.Color = Color3.fromRGB(0, 240, 255)
        KeyStroke.Parent = KeyFrame

        local KeyTitle = Instance.new("TextLabel")
        KeyTitle.Size = UDim2.new(1, 0, 0, 40)
        KeyTitle.BackgroundTransparency = 1
        KeyTitle.Text = "🔑 KEY SYSTEM VIP 💖"
        KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        KeyTitle.TextSize = 14
        KeyTitle.Font = Enum.Font.GothamBold
        KeyTitle.Parent = KeyFrame

        local KeyTextBox = Instance.new("TextBox")
        KeyTextBox.Size = UDim2.new(1, -30, 0, 36)
        KeyTextBox.Position = UDim2.new(0, 15, 0, 44)
        KeyTextBox.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
        KeyTextBox.PlaceholderText = "Nhập Key VIP..."
        KeyTextBox.Text = ""
        KeyTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        KeyTextBox.TextSize = 12
        KeyTextBox.Font = Enum.Font.Gotham
        KeyTextBox.Parent = KeyFrame

        local BoxCorner = Instance.new("UICorner")
        BoxCorner.CornerRadius = UDim.new(0, 8)
        BoxCorner.Parent = KeyTextBox

        local CheckBtn = Instance.new("TextButton")
        CheckBtn.Size = UDim2.new(0.46, -4, 0, 34)
        CheckBtn.Position = UDim2.new(0, 15, 0, 90)
        CheckBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 110)
        CheckBtn.Text = "Check Key"
        CheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        CheckBtn.TextSize = 12
        CheckBtn.Font = Enum.Font.GothamBold
        CheckBtn.Parent = KeyFrame

        local BtnCorner1 = Instance.new("UICorner")
        BtnCorner1.CornerRadius = UDim.new(0, 8)
        BtnCorner1.Parent = CheckBtn

        local GetKeyBtn = Instance.new("TextButton")
        GetKeyBtn.Size = UDim2.new(0.46, -4, 0, 34)
        GetKeyBtn.Position = UDim2.new(0.54, 0, 0, 90)
        GetKeyBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        GetKeyBtn.Text = "Discord Key"
        GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        GetKeyBtn.TextSize = 12
        GetKeyBtn.Font = Enum.Font.GothamBold
        GetKeyBtn.Parent = KeyFrame

        local BtnCorner2 = Instance.new("UICorner")
        BtnCorner2.CornerRadius = UDim.new(0, 8)
        BtnCorner2.Parent = GetKeyBtn

        local BackupBtn = Instance.new("TextButton")
        BackupBtn.Size = UDim2.new(1, -30, 0, 32)
        BackupBtn.Position = UDim2.new(0, 15, 0, 132)
        BackupBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
        BackupBtn.Text = "🔗 Copy Link Lấy Key"
        BackupBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        BackupBtn.TextSize = 11
        BackupBtn.Font = Enum.Font.GothamBold
        BackupBtn.Parent = KeyFrame

        local BtnCorner3 = Instance.new("UICorner")
        BtnCorner3.CornerRadius = UDim.new(0, 8)
        BtnCorner3.Parent = BackupBtn

        local StatusText = Instance.new("TextLabel")
        StatusText.Size = UDim2.new(1, -30, 0, 20)
        StatusText.Position = UDim2.new(0, 15, 0, 172)
        StatusText.BackgroundTransparency = 1
        StatusText.Text = "Nhập key 'TTTT' để bắt đầu"
        StatusText.TextColor3 = Color3.fromRGB(160, 170, 190)
        StatusText.TextSize = 11
        StatusText.Font = Enum.Font.Gotham
        StatusText.Parent = KeyFrame

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
 
