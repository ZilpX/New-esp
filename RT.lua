-- ZilpX Menu - ESP, Hitbox, Aim, FOV, Tracer, Drag menu
local TEAM_COLORS = {
    Color3.fromRGB(255, 75, 75),
    Color3.fromRGB(75, 150, 255),
    Color3.fromRGB(100, 255, 120),
    Color3.fromRGB(255, 210, 70),
    Color3.fromRGB(200, 120, 255),
}
local SHOW_DISTANCE = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local State = {
    espEnabled = false,
    tracerEnabled = false,
    hitboxEnabled = false,
    hitboxHeadEnabled = false,
    aimEnabled = false,
    fov = 120,
    hitboxSize = 6,
    hitboxHeadSize = 10,
    menuOpened = false,
    menuPos = "left",
    espDistance = 120,
}

local keyRequired = "VietNam01"
local keyUnlocked = false
local menuActivated = false

local HasDrawing = pcall(function()
    return Drawing and typeof(Drawing.new) == "function"
end)

local ESPMap = {}
local TeamIndexMap = {}

local function safeDisconnect(conn)
    if conn then pcall(function() conn:Disconnect() end) end
end

local function formatNum(n)
    n = math.floor(n or 0)
    if n >= 1000 then
        return string.format("%.1fk", n/1000)
    end
    return tostring(n)
end

local function getTeamKey(p)
    if p.Team ~= nil then
        return "T:" .. (p.Team.Name or "Unknown")
    elseif p.TeamColor ~= nil then
        return "C:" .. tostring(p.TeamColor)
    else
        return "N:" .. p.Name
    end
end

local function getTeamColor(p)
    local key = getTeamKey(p)
    if not TeamIndexMap[key] then
        local count = 0
        for _ in pairs(TeamIndexMap) do count += 1 end
        local idx = (count % 5) + 1
        TeamIndexMap[key] = idx
    end
    return TEAM_COLORS[TeamIndexMap[key]] or TEAM_COLORS[1]
end

local function worldToScreen(v3)
    local v, onScreen = Camera:WorldToViewportPoint(v3)
    return Vector2.new(v.X, v.Y), onScreen, v.Z
end

--------------------------
-- UI (Circle menu + bảng)
--------------------------
local menuCircleBtn
local menuFrame

local menuPositions = {
    left = UDim2.new(0, 20, 0.5, -25),
    right = UDim2.new(1, -70, 0.5, -25),
    top = UDim2.new(0.5, -25, 0, 20),
    bottom = UDim2.new(0.5, -25, 1, -70),
}
local posList = {"left","right","top","bottom"}
local posIndex = 1

local function setMenuPosition(pos)
    menuCircleBtn.Position = menuPositions[pos]
end

local function createUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ZilpX_Menu"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = false
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    menuCircleBtn = Instance.new("TextButton")
    menuCircleBtn.Size = UDim2.fromOffset(50, 50)
    menuCircleBtn.Position = menuPositions[State.menuPos]
    menuCircleBtn.BackgroundColor3 = Color3.fromRGB(80, 120, 220)
    menuCircleBtn.Text = "≡"
    menuCircleBtn.TextSize = 32
    menuCircleBtn.TextColor3 = Color3.new(1,1,1)
    menuCircleBtn.Font = Enum.Font.GothamBlack
    menuCircleBtn.Parent = gui
    menuCircleBtn.ZIndex = 10
    local circleCorner = Instance.new("UICorner", menuCircleBtn)
    circleCorner.CornerRadius = UDim.new(1, 0)

    menuFrame = Instance.new("Frame")
    menuFrame.Size = UDim2.fromOffset(220, 530)
    menuFrame.Position = UDim2.new(0.5, -110, 0.5, -265)
    menuFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    menuFrame.BorderSizePixel = 0
    menuFrame.Visible = false
    menuFrame.Active = true
    menuFrame.Parent = gui
    Instance.new("UICorner", menuFrame).CornerRadius = UDim.new(0, 10)

    -- DRAGGABLE LOGIC (kéo di chuyển menuFrame)
    local dragging, dragInput, dragStart, frameStart
    menuFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = menuFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    menuFrame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            menuFrame.Position = UDim2.new(
                frameStart.X.Scale, frameStart.X.Offset + delta.X,
                frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            menuFrame.Position = UDim2.new(
                frameStart.X.Scale, frameStart.X.Offset + delta.X,
                frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
            )
        end
    end)

    menuCircleBtn.MouseButton1Click:Connect(function()
        State.menuOpened = not State.menuOpened
        menuFrame.Visible = State.menuOpened
        menuCircleBtn.BackgroundColor3 = State.menuOpened and Color3.fromRGB(35,120,70) or Color3.fromRGB(80,120,220)
    end)

    local keyLabel = Instance.new("TextLabel")
    keyLabel.Size = UDim2.new(1, -20, 0, 30)
    keyLabel.Position = UDim2.fromOffset(10, 35)
    keyLabel.Text = "Nhập Key để mở menu:"
    keyLabel.BackgroundTransparency = 1
    keyLabel.Font = Enum.Font.Gotham
    keyLabel.TextSize = 15
    keyLabel.TextColor3 = Color3.new(1,1,1)
    keyLabel.Name = "KeyLabel"
    keyLabel.Parent = menuFrame

    local keyBox = Instance.new("TextBox")
    keyBox.Size = UDim2.new(1, -20, 0, 24)
    keyBox.Position = UDim2.fromOffset(10, 65)
    keyBox.Text = ""
    keyBox.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    keyBox.TextColor3 = Color3.new(1,1,1)
    keyBox.Font = Enum.Font.Gotham
    keyBox.TextSize = 14
    keyBox.Name = "KeyBox"
    keyBox.Parent = menuFrame
    Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 8)

    local moveKeyBtn = Instance.new("TextButton")
    moveKeyBtn.Size = UDim2.new(1, -20, 0, 28)
    moveKeyBtn.Position = UDim2.fromOffset(10, 93)
    moveKeyBtn.BackgroundColor3 = Color3.fromRGB(45,45,60)
    moveKeyBtn.TextColor3 = Color3.new(1,1,1)
    moveKeyBtn.Font = Enum.Font.Gotham
    moveKeyBtn.TextSize = 14
    moveKeyBtn.Text = "Đổi vị trí menu: Trái"
    moveKeyBtn.Parent = menuFrame
    Instance.new("UICorner", moveKeyBtn).CornerRadius = UDim.new(0,8)
    moveKeyBtn.Visible = true

    moveKeyBtn.MouseButton1Click:Connect(function()
        posIndex = posIndex % #posList + 1
        State.menuPos = posList[posIndex]
        moveKeyBtn.Text = "Đổi vị trí menu: " .. ({
            left="Trái",right="Phải",top="Trên",bottom="Dưới"
        })[State.menuPos]
        setMenuPosition(State.menuPos)
    end)

    local enterBtn = Instance.new("TextButton")
    enterBtn.Size = UDim2.new(1, -20, 0, 28)
    enterBtn.Position = UDim2.fromOffset(10, 128)
    enterBtn.BackgroundColor3 = Color3.fromRGB(35, 120, 70)
    enterBtn.TextColor3 = Color3.new(1,1,1)
    enterBtn.Font = Enum.Font.GothamBold
    enterBtn.TextSize = 15
    enterBtn.Text = "Vào menu"
    enterBtn.Visible = false
    enterBtn.Parent = menuFrame
    Instance.new("UICorner", enterBtn).CornerRadius = UDim.new(0, 8)

    -- Ẩn tất cả phần tính năng khi chưa vào menu
    local featureObjs = {}

    local function setFeaturesVisible(visible)
        for _,obj in ipairs(featureObjs) do
            obj.Visible = visible
        end
    end

    local function makeFeature(obj)
        table.insert(featureObjs, obj)
        obj.Visible = false
    end

    keyBox.FocusLost:Connect(function()
        if keyBox.Text == keyRequired then
            keyUnlocked = true
            keyBox.BackgroundColor3 = Color3.fromRGB(35, 120, 70)
            keyLabel.Text = "Đúng key! Bấm Vào menu."
            enterBtn.Visible = true
        else
            keyUnlocked = false
            keyBox.BackgroundColor3 = Color3.fromRGB(90,35,35)
            keyLabel.Text = "Sai key! Nhập lại."
            enterBtn.Visible = false
            menuActivated = false
            setFeaturesVisible(false)
        end
    end)

    enterBtn.MouseButton1Click:Connect(function()
        menuActivated = true
        setFeaturesVisible(true)
        enterBtn.Visible = false
        keyBox.Visible = false
        keyLabel.Visible = false
        moveKeyBtn.Visible = false
    end)

    -- Các tính năng, toggle, numberbox, v.v.
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -100, 0, 28)
    title.Position = UDim2.fromOffset(10, 170)
    title.BackgroundTransparency = 1
    title.Text = "ZilpX Menu"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 19
    title.TextColor3 = Color3.new(1,1,1)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = menuFrame
    makeFeature(title)

    local function makeToggle(y, label, getFn, setFn)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 30)
        btn.Position = UDim2.fromOffset(10, y)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        btn.BorderSizePixel = 0
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 16
        btn.AutoButtonColor = true
        btn.Parent = menuFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        makeFeature(btn)
        local function refresh()
            local on = getFn()
            btn.Text = (on and "ON  | " or "OFF | ") .. label
            btn.BackgroundColor3 = on and Color3.fromRGB(35, 120, 70) or Color3.fromRGB(90, 35, 35)
        end
        btn.MouseButton1Click:Connect(function()
            setFn(not getFn())
            refresh()
        end)
        refresh()
        return btn
    end

    makeToggle(210, "ESP", function() return State.espEnabled end, function(v) State.espEnabled = v end)
    makeToggle(245, "Tracer", function() return State.tracerEnabled end, function(v) State.tracerEnabled = v end)
    makeToggle(280,"Hitbox Thân", function() return State.hitboxEnabled end, function(v) State.hitboxEnabled = v end)
    makeToggle(315,"Hitbox Đầu", function() return State.hitboxHeadEnabled end, function(v) State.hitboxHeadEnabled = v end)
    makeToggle(350,"Aim", function() return State.aimEnabled end, function(v) State.aimEnabled = v end)

    local function makeNumberBox(y, label, getFn, setFn, min, max)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0, 110, 0, 30)
        lbl.Position = UDim2.fromOffset(10, y)
        lbl.Text = label
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 16
        lbl.TextColor3 = Color3.new(1,1,1)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = menuFrame
        makeFeature(lbl)
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(0, 60, 0, 30)
        box.Position = UDim2.fromOffset(120, y)
        box.Text = tostring(getFn())
        box.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        box.TextColor3 = Color3.new(1,1,1)
        box.Font = Enum.Font.Gotham
        box.TextSize = 16
        box.ClearTextOnFocus = false
        box.Parent = menuFrame
        makeFeature(box)
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)
        box.FocusLost:Connect(function()
            local n = tonumber(box.Text)
            if n and n >= min and n <= max then
                setFn(n)
            end
            box.Text = tostring(getFn())
        end)
    end

    makeNumberBox(385, "Aim FOV", function() return State.fov end, function(v) State.fov = v end, 10, 180)
    makeNumberBox(420, "Hitbox Thân", function() return State.hitboxSize end, function(v) State.hitboxSize = v end, 5, 20)
    makeNumberBox(455, "Hitbox Đầu", function() return State.hitboxHeadSize end, function(v) State.hitboxHeadSize = v end, 5, 20)
    makeNumberBox(490, "ESP Distance", function() return State.espDistance end, function(v) State.espDistance = v end, 20, 500)

    local note = Instance.new("TextLabel")
    note.Size = UDim2.new(1, -10, 0, 18)
    note.Position = UDim2.fromOffset(10, 525)
    note.BackgroundTransparency = 1
    note.Text = HasDrawing and "Drawing API: YES (tracers enabled)" or "Drawing API: NO (tracers disabled)"
    note.Font = Enum.Font.Gotham
    note.TextSize = 12
    note.TextColor3 = Color3.fromRGB(200,200,200)
    note.TextXAlignment = Enum.TextXAlignment.Left
    note.Parent = menuFrame
    makeFeature(note)
end

--------------------------
-- FOV Circle
--------------------------
local fovCircle
local function updateFOVCircle()
    if not HasDrawing then return end
    if State.aimEnabled and keyUnlocked and menuActivated then
        if not fovCircle then
            fovCircle = Drawing.new("Circle")
            fovCircle.Thickness = 2
            fovCircle.Transparency = 1
            fovCircle.Color = Color3.new(1,1,1)
            fovCircle.Filled = false
            fovCircle.ZIndex = 99
        end
        local center = Camera.ViewportSize/2
        fovCircle.Position = Vector2.new(center.X, center.Y)
        fovCircle.Visible = true
        fovCircle.Radius = State.fov
    else
        if fovCircle then
            fovCircle.Visible = false
        end
    end
end

--------------------------
-- ESP/Tracer/Highlight/Hitbox/Aimbot
--------------------------
local function makeBillboard(character, player)
    local head = character:FindFirstChild("Head")
    if not head then return end
    local bb = Instance.new("BillboardGui")
    bb.Name = "ESP_Nameplate"
    bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0, 200, 0, 40)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.Adornee = head
    bb.Parent = character
    local tl = Instance.new("TextLabel")
    tl.Name = "Label"
    tl.BackgroundTransparency = 1
    tl.Size = UDim2.new(1, 0, 1, 0)
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 14
    tl.TextColor3 = getTeamColor(player)
    tl.TextStrokeTransparency = 0.5
    tl.TextYAlignment = Enum.TextYAlignment.Center
    tl.Parent = bb
    return bb, tl
end

local function makeHighlight(character, player)
    local h = Instance.new("Highlight")
    h.Name = "ESP_Highlight"
    h.FillTransparency = 1
    h.OutlineTransparency = 0
    h.OutlineColor = getTeamColor(player)
    h.Adornee = character
    h.Parent = character
    return h
end

local function makeBoxAdornment(character, player)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESP_Box"
    box.Adornee = hrp
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Transparency = 0.7
    box.Color3 = getTeamColor(player)
    box.Size = hrp.Size
    box.Parent = hrp
    return box
end

local function makeTracer(character, player)
    if not HasDrawing then return nil end
    local line = Drawing.new("Line")
    line.Thickness = 1.5
    line.Transparency = 1
    line.Visible = false
    line.Color = getTeamColor(player)
    return line
end

local function updateNameplateText(tl, player, humanoid, character)
    if not tl or not tl.Parent then return end
    local hp = (humanoid and humanoid.Health) or 0
    local maxHp = (humanoid and humanoid.MaxHealth) or 100
    local percent = (maxHp > 0) and math.clamp(hp / maxHp * 100, 0, 999) or 0
    local dist = ""
    if SHOW_DISTANCE then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local d = (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            dist = string.format(" | %dm", math.floor(d + 0.5))
        end
    end
    tl.Text = string.format("%s | HP: %s/%s (%.0f%%%s)", player.Name, formatNum(hp), formatNum(maxHp), percent, dist)
end

local function applyHitbox(character, enable, store, player)
    if not player then return end
    if player.Team == LocalPlayer.Team then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if enable and keyUnlocked and menuActivated then
        if store then
            store.hrpSize = hrp.Size
            store.hrpCollide = hrp.CanCollide
            store.hrpMassless = hrp.Massless
        end
        pcall(function()
            hrp.Size = Vector3.new(State.hitboxSize, State.hitboxSize, State.hitboxSize)
            hrp.Massless = true
            hrp.CanCollide = false
        end)
    else
        if store and store.hrpSize then
            pcall(function()
                hrp.Size = store.hrpSize
                hrp.CanCollide = store.hrpCollide
                hrp.Massless = store.hrpMassless
            end)
        end
    end
end

local function applyHitboxHead(character, enable, store, player)
    if not player then return end
    if player.Team == LocalPlayer.Team then return end
    local head = character:FindFirstChild("Head")
    if not head then return end
    if enable and keyUnlocked and menuActivated then
        if store then
            store.headSize = head.Size
            store.headMassless = head.Massless
            store.headCollide = head.CanCollide
        end
        pcall(function()
            head.Size = Vector3.new(State.hitboxHeadSize, State.hitboxHeadSize, State.hitboxHeadSize)
            head.Massless = true
            head.CanCollide = false
        end)
    else
        if store and store.headSize then
            pcall(function()
                head.Size = store.headSize
                head.Massless = store.headMassless
                head.CanCollide = store.headCollide
            end)
        end
    end
end

local function createESPForPlayer(p)
    if p == LocalPlayer then return end
    local container = { conns = {}, originals = {} }
    ESPMap[p] = container
    local function onCharacter(char)
        container.character = char
        local humanoid = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 10)
        local bb, label = makeBillboard(char, p)
        container.gui = bb
        container.label = label
        container.highlight = makeHighlight(char, p)
        container.box = makeBoxAdornment(char, p)
        container.tracer = makeTracer(char, p)
        if humanoid then
            table.insert(container.conns, humanoid.HealthChanged:Connect(function()
                updateNameplateText(label, p, humanoid, char)
            end))
            updateNameplateText(label, p, humanoid, char)
        end
        local visible = State.espEnabled
        if container.gui then container.gui.Enabled = visible end
        if container.highlight then container.highlight.Enabled = visible end
        if container.box then container.box.Visible = visible end
        if container.tracer then container.tracer.Visible = (visible and State.tracerEnabled) end
        applyHitbox(char, State.hitboxEnabled, container.originals, p)
        applyHitboxHead(char, State.hitboxHeadEnabled, container.originals, p)
    end
    if p.Character then
        onCharacter(p.Character)
    end
    table.insert(container.conns, p.CharacterAdded:Connect(function(c)
        if container.tracer then pcall(function() container.tracer.Visible=false; container.tracer:Remove() end) end
        container.tracer = nil
        onCharacter(c)
    end))
end

local function removeESPForPlayer(p)
    local container = ESPMap[p]
    if not container then return end
    if container.character then
        applyHitbox(container.character, false, container.originals, p)
        applyHitboxHead(container.character, false, container.originals, p)
    end
    for _,c in ipairs(container.conns) do safeDisconnect(c) end
    if container.gui then pcall(function() container.gui:Destroy() end) end
    if container.highlight then pcall(function() container.highlight:Destroy() end) end
    if container.box then pcall(function() container.box:Destroy() end) end
    if container.tracer then pcall(function() container.tracer.Visible=false; container.tracer:Remove() end) end
    ESPMap[p] = nil
end

local function applyEspVisibility()
    for p,container in pairs(ESPMap) do
        local show = State.espEnabled and keyUnlocked and menuActivated
        if show and container.character and container.character:FindFirstChild("HumanoidRootPart")
            and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        then
            local dist = (container.character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            show = dist <= State.espDistance
        else
            show = false
        end
        if container.gui then container.gui.Enabled = show end
        if container.highlight then container.highlight.Enabled = show end
        if container.box then container.box.Visible = show end
        if container.tracer then container.tracer.Visible = (show and State.tracerEnabled) end
    end
end

local function applyHitboxAll()
    for p,container in pairs(ESPMap) do
        if container.character then
            applyHitbox(container.character, State.hitboxEnabled, container.originals, p)
        end
    end
end

local function applyHitboxHeadAll()
    for p,container in pairs(ESPMap) do
        if container.character then
            applyHitboxHead(container.character, State.hitboxHeadEnabled, container.originals, p)
        end
    end
end

local function getClosestEnemyToPlayer()
    local closest = nil
    local closestDist = math.huge
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
    for p,container in pairs(ESPMap) do
        local char = container.character
        if char and char.Parent and char:FindFirstChild("Head") and char ~= LocalPlayer.Character then
            local head = char.Head
            if p and (p.Team ~= LocalPlayer.Team or not p.Team) then
                local dist = (head.Position-myPos).Magnitude
                if dist < closestDist and dist <= State.fov then
                    closest = head
                    closestDist = dist
                end
            end
        end
    end
    return closest
end

local aimingConn
task.spawn(function()
    local lastAim = false
    while true do
        if State.aimEnabled ~= lastAim then
            if State.aimEnabled and keyUnlocked and menuActivated then
                if not aimingConn then
                    aimingConn = RunService.RenderStepped:Connect(function()
                        local target = getClosestEnemyToPlayer()
                        if target then
                            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
                        end
                    end)
                end
            else
                if aimingConn then
                    aimingConn:Disconnect()
                    aimingConn = nil
                end
            end
            lastAim = State.aimEnabled
        end
        task.wait(0.15)
    end
end)

RunService.RenderStepped:Connect(function()
    if not State.espEnabled or not State.tracerEnabled or not HasDrawing or not keyUnlocked or not menuActivated then
        for _,ct in pairs(ESPMap) do
            if ct.tracer then ct.tracer.Visible = false end
        end
        return
    end
    local screenBottom = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y - 2)
    for _,ct in pairs(ESPMap) do
        local char = ct.character
        local tracer = ct.tracer
        if tracer and char and char.Parent then
            local head = char:FindFirstChild("Head")
            if head then
                local pos2D, onScreen = worldToScreen(head.Position)
                if onScreen then
                    tracer.From = screenBottom
                    tracer.To = pos2D
                    tracer.Visible = true
                else
                    tracer.Visible = false
                end
            else
                tracer.Visible = false
            end
        end
    end
end)

task.spawn(function()
    local lastAim, lastFov = false, State.fov
    while true do
        if (State.aimEnabled ~= lastAim) or (State.fov ~= lastFov) then
            updateFOVCircle()
            lastAim = State.aimEnabled
            lastFov = State.fov
        end
        task.wait(0.1)
    end
end)

for _,p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        createESPForPlayer(p)
    end
end

Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then
        createESPForPlayer(p)
    end
end)

Players.PlayerRemoving:Connect(function(p)
    removeESPForPlayer(p)
end)

createUI()

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "ZilpX Menu",
        Text = "Nhập key VietNam01 để mở menu!",
        Duration = 8
    })
end)

task.spawn(function()
    local last = {esp=false, tracer=false, hit=false, head=false, fov=State.fov, hsize=State.hitboxSize, hhead=State.hitboxHeadSize, menuPos=State.menuPos, espDist=State.espDistance}
    while true do
        if State.espEnabled ~= last.esp or State.tracerEnabled ~= last.tracer or State.espDistance ~= last.espDist then
            applyEspVisibility()
            last.esp = State.espEnabled
            last.tracer = State.tracerEnabled
            last.espDist = State.espDistance
        end
        if State.hitboxEnabled ~= last.hit or State.hitboxSize ~= last.hsize then
            applyHitboxAll()
            last.hit = State.hitboxEnabled
            last.hsize = State.hitboxSize
        end
        if State.hitboxHeadEnabled ~= last.head or State.hitboxHeadSize ~= last.hhead then
            applyHitboxHeadAll()
            last.head = State.hitboxHeadEnabled
            last.hhead = State.hitboxHeadSize
        end
        if State.menuPos ~= last.menuPos then
            setMenuPosition(State.menuPos)
            last.menuPos = State.menuPos
        end
        last.fov = State.fov
        task.wait(0.25)
    end
end)
