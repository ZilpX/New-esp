-- ZilpX Menu Di Chuyển Được - ESP, Hitbox, Aim, FOV & Toggle Button
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Configs
local ESP_Enabled = true
local Hitbox_Enabled = true
local Aim_Enabled = true
local FOV_Radius = 120
local HitboxBody = 10
local HitboxHead = 7

-- UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "ZilpXMenuUI"

-- Nút mở/tắt menu (hình tròn cố định)
local OpenButton = Instance.new("ImageButton", ScreenGui)
OpenButton.Size = UDim2.new(0,45,0,45)
OpenButton.Position = UDim2.new(0,15,0,200)
OpenButton.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
OpenButton.Image = "" -- Không dùng icon, chỉ màu nền
OpenButton.AutoButtonColor = true
OpenButton.BackgroundTransparency = 0
OpenButton.BorderSizePixel = 0
OpenButton.Name = "ZilpXOpenButton"

local UICorner = Instance.new("UICorner", OpenButton)
UICorner.CornerRadius = UDim.new(1,0)

local OpenText = Instance.new("TextLabel", OpenButton)
OpenText.Size = UDim2.new(1,0,1,0)
OpenText.BackgroundTransparency = 1
OpenText.Text = "≡"
OpenText.TextColor3 = Color3.new(1,1,1)
OpenText.Font = Enum.Font.GothamBold
OpenText.TextScaled = true

-- Menu chính
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 280, 0, 210)
MainFrame.Position = UDim2.new(0,70,0,170)
MainFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
MainFrame.Active = true
MainFrame.Visible = false

local CornerFrame = Instance.new("UICorner", MainFrame)
CornerFrame.CornerRadius = UDim.new(0,16)

-- DRAG MENU (Kéo thả)
local dragging = false
local dragInput, dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

function AddLabel(txt,pos)
    local l = Instance.new("TextLabel", MainFrame)
    l.Size = UDim2.new(0,260,0,25)
    l.Position = UDim2.new(0,10,0,pos)
    l.Text = txt
    l.TextColor3 = Color3.new(1,1,1)
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextSize = 18
    return l
end

AddLabel("ZilpX Menu", 5)
local ESPToggle = Instance.new("TextButton", MainFrame)
ESPToggle.Size = UDim2.new(0,120,0,25)
ESPToggle.Position = UDim2.new(0,10,0,35)
ESPToggle.Text = "ESP: ON"
ESPToggle.BackgroundColor3 = Color3.fromRGB(50,200,50)
ESPToggle.TextColor3 = Color3.new(1,1,1)
ESPToggle.Font = Enum.Font.GothamBold
ESPToggle.TextSize = 16

local HitboxToggle = Instance.new("TextButton", MainFrame)
HitboxToggle.Size = UDim2.new(0,120,0,25)
HitboxToggle.Position = UDim2.new(0,10,0,65)
HitboxToggle.Text = "Hitbox: ON"
HitboxToggle.BackgroundColor3 = Color3.fromRGB(200,80,80)
HitboxToggle.TextColor3 = Color3.new(1,1,1)
HitboxToggle.Font = Enum.Font.GothamBold
HitboxToggle.TextSize = 16

local AimToggle = Instance.new("TextButton", MainFrame)
AimToggle.Size = UDim2.new(0,120,0,25)
AimToggle.Position = UDim2.new(0,10,0,95)
AimToggle.Text = "AIM: ON"
AimToggle.BackgroundColor3 = Color3.fromRGB(80,80,200)
AimToggle.TextColor3 = Color3.new(1,1,1)
AimToggle.Font = Enum.Font.GothamBold
AimToggle.TextSize = 16

local FOVBox = Instance.new("TextBox", MainFrame)
FOVBox.Size = UDim2.new(0,120,0,25)
FOVBox.Position = UDim2.new(0,10,0,125)
FOVBox.Text = "FOV: "..FOV_Radius
FOVBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
FOVBox.TextColor3 = Color3.new(1,1,1)
FOVBox.Font = Enum.Font.GothamBold
FOVBox.TextSize = 15

local BodyBox = Instance.new("TextBox", MainFrame)
BodyBox.Size = UDim2.new(0,120,0,25)
BodyBox.Position = UDim2.new(0,10,0,155)
BodyBox.Text = "Body: "..HitboxBody
BodyBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
BodyBox.TextColor3 = Color3.new(1,1,1)
BodyBox.Font = Enum.Font.GothamBold
BodyBox.TextSize = 15

local HeadBox = Instance.new("TextBox", MainFrame)
HeadBox.Size = UDim2.new(0,120,0,25)
HeadBox.Position = UDim2.new(0,10,0,185)
HeadBox.Text = "Head: "..HitboxHead
HeadBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
HeadBox.TextColor3 = Color3.new(1,1,1)
HeadBox.Font = Enum.Font.GothamBold
HeadBox.TextSize = 15

-- Toggle
ESPToggle.MouseButton1Click:Connect(function()
    ESP_Enabled = not ESP_Enabled
    ESPToggle.Text = "ESP: "..(ESP_Enabled and "ON" or "OFF")
end)
HitboxToggle.MouseButton1Click:Connect(function()
    Hitbox_Enabled = not Hitbox_Enabled
    HitboxToggle.Text = "Hitbox: "..(Hitbox_Enabled and "ON" or "OFF")
end)
AimToggle.MouseButton1Click:Connect(function()
    Aim_Enabled = not Aim_Enabled
    AimToggle.Text = "AIM: "..(Aim_Enabled and "ON" or "OFF")
end)
FOVBox.FocusLost:Connect(function()
    local v = tonumber(FOVBox.Text:match("%d+"))
    if v and v >= 50 and v <= 300 then
        FOV_Radius = v
        FOVBox.Text = "FOV: "..FOV_Radius
    else
        FOVBox.Text = "FOV: "..FOV_Radius
    end
end)
BodyBox.FocusLost:Connect(function()
    local v = tonumber(BodyBox.Text:match("%d+"))
    if v and v >= 5 and v <= 30 then
        HitboxBody = v
        BodyBox.Text = "Body: "..HitboxBody
    else
        BodyBox.Text = "Body: "..HitboxBody
    end
end)
HeadBox.FocusLost:Connect(function()
    local v = tonumber(HeadBox.Text:match("%d+"))
    if v and v >= 3 and v <= 15 then
        HitboxHead = v
        HeadBox.Text = "Head: "..HitboxHead
    else
        HeadBox.Text = "Head: "..HitboxHead
    end
end)

-- Mở/tắt menu
OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- FOV Circle
local Drawing = Drawing or nil
local FOVCircle
if Drawing then
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Color = Color3.new(1,1,1)
    FOVCircle.Thickness = 2
    FOVCircle.Filled = false
    FOVCircle.NumSides = 90
    FOVCircle.Visible = false
end

-- ESP
local ESPTable = {}
function UpdateESP()
    for _,v in pairs(ESPTable) do
        if v then v:Remove() end
    end
    ESPTable = {}
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local Billboard = Instance.new("BillboardGui", head)
            Billboard.Size = UDim2.new(0,120,0,24)
            Billboard.Adornee = head
            Billboard.AlwaysOnTop = true
            local NameLabel = Instance.new("TextLabel", Billboard)
            NameLabel.Size = UDim2.new(1,0,1,0)
            NameLabel.BackgroundTransparency = 1
            local hp = p.Character:FindFirstChildOfClass("Humanoid") and math.floor(p.Character:FindFirstChildOfClass("Humanoid").Health) or "??"
            local dist = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") and (head.Position - LocalPlayer.Character.Head.Position).Magnitude) or 0
            NameLabel.Text = p.Name.." | HP: "..hp.." | "..math.floor(dist).."m"
            NameLabel.TextColor3 = Color3.new(1,1,1)
            NameLabel.Font = Enum.Font.GothamBold
            NameLabel.TextScaled = true
            table.insert(ESPTable, Billboard)
        end
    end
end

-- Hitbox
function EditHitbox(player)
    local chr = player.Character
    if chr then
        if chr:FindFirstChild("HumanoidRootPart") then
            chr.HumanoidRootPart.Size = Vector3.new(HitboxBody,HitboxBody,HitboxBody)
            chr.HumanoidRootPart.Transparency = 0.6
            chr.HumanoidRootPart.BrickColor = BrickColor.new("Really red")
            chr.HumanoidRootPart.Material = Enum.Material.Neon
            chr.HumanoidRootPart.CanCollide = false
        end
        if chr:FindFirstChild("Head") then
            chr.Head.Size = Vector3.new(HitboxHead,HitboxHead,HitboxHead)
            chr.Head.Transparency = 0.6
            chr.Head.BrickColor = BrickColor.new("Bright blue")
            chr.Head.Material = Enum.Material.Neon
            chr.Head.CanCollide = false
        end
    end
end

-- Aim
function GetClosestEnemy()
    local closest, distCheck = nil, math.huge
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Head") then return nil end
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local head = plr.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local mousePos = UserInputService:GetMouseLocation()
                local fovDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if fovDist <= FOV_Radius and fovDist < distCheck then
                    closest = head
                    distCheck = fovDist
                end
            end
        end
    end
    return closest
end

-- Main loop
RunService.RenderStepped:Connect(function()
    -- FOV Circle
    if Drawing and FOVCircle then
        FOVCircle.Visible = Aim_Enabled
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = FOV_Radius
    end

    -- ESP
    if ESP_Enabled then
        pcall(UpdateESP)
    else
        for _,v in pairs(ESPTable) do
            if v then v:Remove() end
        end
        ESPTable = {}
    end

    -- Hitbox
    if Hitbox_Enabled then
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                pcall(function() EditHitbox(plr) end)
            end
        end
    end

    -- AIM
    if Aim_Enabled then
        local target = GetClosestEnemy()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)

-- Auto update ESP, Hitbox
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        wait(1)
        if ESP_Enabled then pcall(UpdateESP) end
        if Hitbox_Enabled then pcall(function() EditHitbox(p) end) end
    end)
end)

print("ZilpX Menu ESP/Hitbox/Aim Loaded!")
