--[[
   rEm V2.2 - CYAN NEON (THE ABSOLUTE FINAL + EXECUTOR BYPASS)
    - FIX FATAL: Fallback UI container buat executor yang ngeblokir CoreGui
    - FIX YIELD: Dihapus WaitForChild yang bikin script nge-hang/ga jalan
    - FIX STABILITY: Ganti RenderStepped ke Heartbeat biar support semua executor
    - Fix: ESP nyangkut pas di-OFF sekarang langsung bersih
    - Added: Auto Sell berdasarkan UI Bar Detection (Size.X.Scale >= 1)
    - Added: Whitelist System (Hanya player tertentu yang bisa pakai)
    - Update: DYNAMIC ATTACK TP (Anti-fling/bug pas lagi sambil makan)
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- WHITELIST SYSTEM
-- ==========================================
local WhitelistedUsers = {
    "mount2702blanc",
    "L0rdDarkShad0w",
    "chibhothax",
    "ibrak4dabra"
}

if not table.find(WhitelistedUsers, LocalPlayer.Name) then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "rEm V2.2",
        Text = "Access Denied: Username tidak di-whitelist!",
        Duration = 5
    })
    return
end

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "rEm V2.2",
    Text = "Welcome to rEm, " .. LocalPlayer.Name .. "!",
    Duration = 3
})

-- ==========================================
-- BYPASS COREGUI PERMISSION (ANTI-CRASH)
-- ==========================================
local PlayerGui
local success = pcall(function() 
    PlayerGui = game:GetService("CoreGui") 
    local test = PlayerGui.Name 
end)

if not success or not PlayerGui then
    PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
end

-- ==========================================
-- HANS BIG PLATFORM (ANTI-LICIN EDITION)
-- ==========================================
if not workspace:FindFirstChild("HansBigPlatform") then
    local p = Instance.new("Part")
    p.Name = "HansBigPlatform"
    p.Size = Vector3.new(3000, 10, 3000)
    p.Anchored = true
    p.CanCollide = true
    p.Position = Vector3.new(0, -6, 0)
    p.Material = Enum.Material.Fabric 
    p.CustomPhysicalProperties = PhysicalProperties.new(100, 2, 0, 100, 100) 
    p.Parent = workspace
end

-- Bersihkan UI lama
local oldUIs = {"HAZE_HUB", "CustomGUI", "HazeAutoSell", "HazeEmotes", "HazeUtility", "HAZE_V2", "HAZE_V2_1", "HAZE_V2_2"}
for _, uiName in pairs(oldUIs) do
    pcall(function()
        if PlayerGui:FindFirstChild(uiName) then PlayerGui[uiName]:Destroy() end
    end)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "rEm_V2_2"
pcall(function()
    ScreenGui.Parent = (gethui and gethui()) or PlayerGui
end)
ScreenGui.ResetOnSpawn = false

-- 1. ANIMASI INTRO
local function playIntro()
    local IntroText = Instance.new("TextLabel")
    IntroText.Parent = ScreenGui
    IntroText.BackgroundTransparency = 1
    IntroText.Position = UDim2.new(0.5, 0, 0.5, 0)
    IntroText.Font = Enum.Font.GothamBold
    IntroText.Text = "rEm V2.2"
    IntroText.TextColor3 = Color3.fromRGB(0, 255, 255) 
    IntroText.TextSize = 0
    IntroText.AnchorPoint = Vector2.new(0.5, 0.5)
    
    TweenService:Create(IntroText, TweenInfo.new(0.8, Enum.EasingStyle.Back), {TextSize = 60}):Play()
    task.wait(1.2)
    TweenService:Create(IntroText, TweenInfo.new(0.8), {TextTransparency = 1}):Play()
    task.delay(0.8, function() IntroText:Destroy() end)
end
playIntro()

-- 2. MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Position = UDim2.new(0.5, -85, 0.3, 0)
MainFrame.Size = UDim2.new(0, 170, 0, 280) 
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(0, 255, 255) 
Stroke.Thickness = 1.5

-- 3. SCROLLING AREA
local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1, -10, 1, -40)
Scroll.Position = UDim2.new(0, 5, 0, 35)
Scroll.BackgroundTransparency = 1
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y 
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0) 
Scroll.ScrollBarThickness = 2
Scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255) 

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 5)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- 4. LOGO "H" TOGGLE
local MenuBtn = Instance.new("TextButton", ScreenGui)
MenuBtn.Size = UDim2.new(0, 42, 0, 42) 
MenuBtn.Position = UDim2.new(0, 20, 0.5, -20)
MenuBtn.Text = "H"
MenuBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MenuBtn.TextColor3 = Color3.fromRGB(0, 255, 255) 
MenuBtn.Font = Enum.Font.GothamBold
MenuBtn.TextSize = 24 
MenuBtn.Draggable = true 
Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(1, 0)

local BtnStroke = Instance.new("UIStroke", MenuBtn)
BtnStroke.Color = Color3.fromRGB(0, 255, 255) 
BtnStroke.Thickness = 2 
BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border 

MenuBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible 
end)

-- 5. COMPONENT GENERATORS
local function createToggle(name, default, callback)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(0.95, 0, 0, 28)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 10
    btn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    
    local enabled = default
    local function update()
        btn.Text = name .. ": " .. (enabled and "ON" or "OFF")
        btn.BackgroundColor3 = enabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
        callback(enabled)
    end
    btn.MouseButton1Click:Connect(function() enabled = not enabled update() end)
    update()
end

local function createInput(placeholder, callback)
    local box = Instance.new("TextBox", Scroll)
    box.Size = UDim2.new(0.95, 0, 0, 28)
    box.PlaceholderText = placeholder
    box.Text = ""
    box.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    box.TextColor3 = Color3.new(1, 1, 1)
    box.Font = Enum.Font.Gotham
    box.TextSize = 10
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)
    box.FocusLost:Connect(function() callback(box.Text) end)
end

-- ==========================================
-- FEATURE LOGIC: PURE FARM, SPEED, ANTI-VOID
-- ==========================================

getgenv().AntiVoid = false
task.spawn(function()
    while task.wait(0.05) do
        if getgenv().AntiVoid then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root and root.Position.Y < -50 then
                root.Velocity = Vector3.new(0, 0, 0)
                root.CFrame = CFrame.new(0, 50, 0)
            end
        end
    end
end)
createToggle("Anti-Void", false, function(v) getgenv().AntiVoid = v end)

getgenv().AutoFarm = false
getgenv().SpeedEnabled = false
getgenv().SpeedValue = 100

local setCubesEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("SetCubes")

RunService.Heartbeat:Connect(function(delta)
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if getgenv().AutoFarm then
        pcall(function()
            if setCubesEvent then setCubesEvent:FireServer() end
            if char:FindFirstChild("Events") then
                if char.Events:FindFirstChild("Grab") then char.Events.Grab:FireServer(false, false, false) end
                if char.Events:FindFirstChild("Eat") then char.Events.Eat:FireServer() end
            end
        end)
    end
    
    if getgenv().SpeedEnabled and hum and root then
        root.Anchored = false
        if hum.MoveDirection.Magnitude > 0 then
            local pos = root.Position + (hum.MoveDirection * getgenv().SpeedValue * delta)
            root.CFrame = CFrame.new(pos, pos + root.CFrame.LookVector)
        end
    end
end)

createToggle("Auto Eat", false, function(v) getgenv().AutoFarm = v end)
createInput("Speed Value", function(t) getgenv().SpeedValue = tonumber(t) or 100 end)
createToggle("Run Speed", false, function(v) getgenv().SpeedEnabled = v end)

-- ==========================================
-- AUTO SELL (UI BAR DETECTION)
-- ==========================================
getgenv().AutoSellBar = false
local cachedBar = nil
local isSelling = false

local function findBar()
    if cachedBar and cachedBar.Parent then return cachedBar end
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, v in pairs(playerGui:GetDescendants()) do
            if v:IsA("Frame") and (v.Name:lower():find("bar") or v.Name:lower():find("meter")) then
                cachedBar = v
                return v
            end
        end
    end
    return nil
end

local function getSell()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("Events") and c.Events:FindFirstChild("Sell")
end

RunService.Heartbeat:Connect(function()
    if not getgenv().AutoSellBar or isSelling then return end
    local b = findBar()
    if b and b.Size.X.Scale >= 1 then
        local s = getSell()
        if s then
            isSelling = true
            pcall(function() s:FireServer() end)
            task.delay(0.5, function() isSelling = false end)
        end
    end
end)

createToggle("Auto Sell (Bar)", false, function(v) getgenv().AutoSellBar = v end)

-- ==========================================
-- UPDATED: DYNAMIC ATTACK TP
-- ==========================================
getgenv().AttackTP = false
getgenv().TargetPlayer = ""
local attackTpConnection = nil

createInput("Target Name (Attack TP)", function(t) getgenv().TargetPlayer = t end)

local function getRandomPosition()
    return Vector3.new(math.random(-100, 100), math.random(10, 50), math.random(-100, 100))
end

local function getTargetPlayer(query)
    if query == "" then return nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if string.find(string.lower(p.Name), string.lower(query)) or string.find(string.lower(p.DisplayName), string.lower(query)) then
                return p
            end
        end
    end
    return nil
end

createToggle("Attack TP Loop", false, function(v) 
    getgenv().AttackTP = v 
    if not v and attackTpConnection then
        attackTpConnection:Disconnect()
        attackTpConnection = nil
    end
end)

task.spawn(function()
    while true do
        if getgenv().AttackTP then
            local targetPlayer = getTargetPlayer(getgenv().TargetPlayer)
            local char = LocalPlayer.Character
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and char and char:FindFirstChild("HumanoidRootPart") then
                
                char:SetPrimaryPartCFrame(CFrame.new(getRandomPosition()))
                task.wait(1.5)
                
                if char:FindFirstChild("Events") and char.Events:FindFirstChild("Grab") then   
                    char.Events.Grab:FireServer()   
                end   
                task.wait(2)
                
                attackTpConnection = RunService.Heartbeat:Connect(function()
                    if getgenv().AttackTP and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and char and char:FindFirstChild("HumanoidRootPart") then   
                        local mySize = char:GetExtentsSize().Z
                        local targetSize = targetPlayer.Character:GetExtentsSize().Z
                        local safeDistance = (mySize / 2) + (targetSize / 2) + 2
                        
                        char:SetPrimaryPartCFrame(targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, safeDistance))   
                    end   
                end)
                
                if char:FindFirstChild("Events") and char.Events:FindFirstChild("Throw") then
                    char.Events.Throw:FireServer()
                end
                task.wait(1.5)
                
                if attackTpConnection then
                    attackTpConnection:Disconnect()
                    attackTpConnection = nil
                end
            end
            task.wait(1) 
        else
            task.wait(0.5)
        end
    end
end)

-- ==========================================
-- INTEGRATED: GRAVITY LOCK & GOD ANTI-RAGDOLL
-- ==========================================

createToggle("Gravity Lock", false, function(v)
    _G.GravityLock = v
    if _G.GravityLock then
        if not _G.GravLockLoop then
            _G.GravLockLoop = RunService.Heartbeat:Connect(function()
                workspace.Gravity = 196.2
            end)
        end
    else
        if _G.GravLockLoop then
            _G.GravLockLoop:Disconnect()
            _G.GravLockLoop = nil
        end
    end
end)

createToggle("God Anti-Ragdoll", false, function(v)
    _G.GodModeRagdoll = v
    local player = game.Players.LocalPlayer
    local RS = game:GetService("ReplicatedStorage")
    
    if _G.GodModeRagdoll then
        if not _G.GodLoop then
            _G.GodLoop = RunService.Heartbeat:Connect(function()
                local currentChar = player.Character
                if currentChar then
                    pcall(function()
                        if RS:FindFirstChild("Events") and RS.Events:FindFirstChild("unRagdoll") then
                            RS.Events.unRagdoll:FireServer(currentChar)
                        end
                    end)

                    local currentHrp = currentChar:FindFirstChild("HumanoidRootPart")
                    if currentHrp and not currentHrp:FindFirstChild("HazeIronPosture") then
                        local gyro = Instance.new("BodyGyro")
                        gyro.Name = "HazeIronPosture"
                        gyro.MaxTorque = Vector3.new(math.huge, 0, math.huge) 
                        gyro.P = 1000000 
                        gyro.Parent = currentHrp
                    end

                    local ragdollScript = currentChar:FindFirstChild("RagdollListener")
                    if ragdollScript then
                        ragdollScript.Disabled = true
                        ragdollScript:Destroy()
                    end
                    
                    if currentHrp then
                        currentHrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    end
                    
                    local hum = currentChar:FindFirstChild("Humanoid")
                    if hum then
                        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                        hum.PlatformStand = false
                        hum.Sit = false
                        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                    end
                end
            end)
        end
    else
        if _G.GodLoop then
            _G.GodLoop:Disconnect()
            _G.GodLoop = nil
        end
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and hrp:FindFirstChild("HazeIronPosture") then
                hrp.HazeIronPosture:Destroy()
            end
            pcall(function()
                if RS:FindFirstChild("Events") and RS.Events:FindFirstChild("unRagdoll") then
                    RS.Events.unRagdoll:FireServer(char)
                end
            end)
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                hum.PlatformStand = false
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
    end
end)

-- ==========================================
-- ADVANCED ESP
-- ==========================================
local espEnabled = false
local espObjects = {}

local function cariDataBruteForce(targetPlayer, namaData)
    local namaVariasi = {namaData, string.gsub(namaData, " ", ""), string.gsub(namaData, " ", "_")}
    
    local function cekObjek(obj)
        for _, variasi in ipairs(namaVariasi) do
            if string.lower(obj.Name) == string.lower(variasi) and (obj:IsA("IntValue") or obj:IsA("NumberValue")) then 
                return obj.Value 
            end
        end
        return nil
    end

    for _, obj in ipairs(targetPlayer:GetDescendants()) do
        local val = cekObjek(obj)
        if val then return val end
    end
    
    for _, variasi in ipairs(namaVariasi) do
        local pAttr = targetPlayer:GetAttribute(variasi)
        if pAttr then return pAttr end
        if targetPlayer.Character then
            local cAttr = targetPlayer.Character:GetAttribute(variasi)
            if cAttr then return cAttr end
        end
    end
    
    local pGui = targetPlayer:FindFirstChild("PlayerGui")
    if pGui then
        for _, obj in ipairs(pGui:GetDescendants()) do
            local val = cekObjek(obj)
            if val then return val end
        end
    end

    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if string.find(string.lower(obj.Name), string.lower(targetPlayer.Name)) then
            for _, child in ipairs(obj:GetDescendants()) do
                local val = cekObjek(child)
                if val then return val end
            end
        end
    end
    return "?" 
end

local function createESP(targetPlayer)
    if targetPlayer == LocalPlayer then return end
    local hl = Instance.new("Highlight")
    hl.Name = "HazeESP"
    hl.FillColor = Color3.fromRGB(0, 255, 255) 
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop 
    
    local bgui = Instance.new("BillboardGui")
    bgui.Name = "HazeESPText"
    bgui.AlwaysOnTop = true
    bgui.Size = UDim2.new(0, 180, 0, 100) 
    bgui.StudsOffset = Vector3.new(0, 4, 0)
    
    local text = Instance.new("TextLabel", bgui)
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextStrokeTransparency = 0 
    text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    text.Font = Enum.Font.GothamBold
    text.TextSize = 12
    text.TextYAlignment = Enum.TextYAlignment.Bottom 
    
    table.insert(espObjects, {player = targetPlayer, highlight = hl, billboard = bgui, textLabel = text})
end

task.spawn(function()
    while task.wait(1) do 
        if espEnabled then
            for _, obj in ipairs(espObjects) do
                local tPlayer = obj.player
                local char = tPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    if obj.highlight.Parent ~= char then obj.highlight.Parent = char end
                    if obj.billboard.Parent ~= char:FindFirstChild("HumanoidRootPart") then obj.billboard.Parent = char:FindFirstChild("HumanoidRootPart") end
                    
                    local sizeVal = cariDataBruteForce(tPlayer, "Size")
                    local maxVal = cariDataBruteForce(tPlayer, "MaxSize")
                    if maxVal == "?" then maxVal = cariDataBruteForce(tPlayer, "Max Size") end
                    if maxVal == "?" then maxVal = cariDataBruteForce(tPlayer, "Max") end
                    if maxVal == "?" then maxVal = cariDataBruteForce(tPlayer, "Capacity") end
                    
                    local eatSpeedVal = cariDataBruteForce(tPlayer, "eat speed")
                    if eatSpeedVal == "?" then eatSpeedVal = cariDataBruteForce(tPlayer, "eat level") end
                    
                    local multiVal = cariDataBruteForce(tPlayer, "size multiplier")
                    if multiVal == "?" then multiVal = cariDataBruteForce(tPlayer, "multiplier") end
                    if multiVal == "?" then multiVal = cariDataBruteForce(tPlayer, "multi") end
                    
                    local walkSpeedVal = 16
                    local hum = char:FindFirstChild("Humanoid")
                    if hum then walkSpeedVal = math.floor(hum.WalkSpeed) end
                    
                    obj.textLabel.Text = string.format("[%s]\nSize: %s / %s\nMulti: %s | Eat: %s\nWalkSpeed: %s", tPlayer.Name, tostring(sizeVal), tostring(maxVal), tostring(multiVal), tostring(eatSpeedVal), tostring(walkSpeedVal))
                else
                    obj.highlight.Parent = nil
                    obj.billboard.Parent = nil
                end
            end
        end
    end
end)

for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(function(player)
    for i, obj in ipairs(espObjects) do
        if obj.player == player then
            obj.highlight:Destroy()
            obj.billboard:Destroy()
            table.remove(espObjects, i)
            break
        end
    end
end)

createToggle("Player ESP", false, function(v) 
    espEnabled = v 
    if not espEnabled then
        for _, obj in ipairs(espObjects) do
            obj.highlight.Parent = nil
            obj.billboard.Parent = nil
        end
    end
end)
