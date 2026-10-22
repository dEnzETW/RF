
-- Eat the World: Auto Next Map
-- Panel ON/OFF terpisah dari rEm.lua.
-- Auto Eat dan Auto Sell di rEm.lua tidak diubah.

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local enabled = true
local wasAtMax = false
local previousSize = nil
local lastMapSkip = 0
local cooldown = 3

-- Hapus panel lama jika script dijalankan ulang
local oldGui = playerGui:FindFirstChild("ETWNextMapToggle")
if oldGui then
    oldGui:Destroy()
end

-- Membuat panel ON/OFF
local gui = Instance.new("ScreenGui")
gui.Name = "ETWNextMapToggle"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local button = Instance.new("TextButton")
button.Name = "ToggleButton"
button.Size = UDim2.new(0, 170, 0, 44)
button.Position = UDim2.new(0, 16, 0.55, 0)
button.BackgroundColor3 = Color3.fromRGB(35, 150, 85)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 15
button.Font = Enum.Font.GothamBold
button.Text = "Auto Next Map: ON"
button.Active = true
button.Selectable = true
button.Draggable = true
button.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = button

-- Geser panel secara manual dengan sentuhan atau mouse
local UserInputService = game:GetService("UserInputService")
local dragging = false
local dragInput
local dragStart
local startPosition

button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPosition = button.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

button.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input == dragInput
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart

        button.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)


-- Fungsi ON/OFF
local function toggleAutoNextMap()
    enabled = not enabled

    if enabled then
        button.Text = "Auto Next Map: ON"
        button.BackgroundColor3 = Color3.fromRGB(35, 150, 85)
        print("[ETW Auto Next Map] ON")
    else
        button.Text = "Auto Next Map: OFF"
        button.BackgroundColor3 = Color3.fromRGB(160, 55, 55)

        -- Reset deteksi saat OFF
        wasAtMax = false
        previousSize = nil

        print("[ETW Auto Next Map] OFF")
    end
end

-- Gunakan satu event klik agar tidak toggle dua kali
button.MouseButton1Click:Connect(toggleAutoNextMap)

-- Membaca ukuran karakter dan ukuran maksimum
local function getSizeData()
    local character = player.Character
    local sizeObj = character
        and character:FindFirstChild("Size")

    local current = sizeObj
        and (sizeObj:IsA("NumberValue")
        or sizeObj:IsA("IntValue"))
        and sizeObj.Value or nil

    local upgrades = player:FindFirstChild("Upgrades")
        or player:FindFirstChild("upgrades")
        or player:FindFirstChild("Upgrade")

    local maxObj = upgrades and (
        upgrades:FindFirstChild("MaxSize")
        or upgrades:FindFirstChild("Capacity")
    )

    local maximum = maxObj
        and (maxObj:IsA("NumberValue")
        or maxObj:IsA("IntValue"))
        and maxObj.Value or nil

    return current, maximum
end

-- Mencari tombol map berdasarkan nama atau teks
local function findMapSkipButton()
    local roots = { playerGui }

    pcall(function()
        if gethui then
            table.insert(roots, gethui())
        end
    end)

    pcall(function()
        table.insert(roots, game:GetService("CoreGui"))
    end)

    for _, root in ipairs(roots) do
        for _, obj in ipairs(root:GetDescendants()) do
            if obj:IsA("GuiButton")
                and obj.Visible
                and obj ~= button then

                local name = string.lower(obj.Name or "")
                local label = ""

                pcall(function()
                    label = string.lower(obj.Text or "")
                end)

                local combined = name .. " " .. label

                if combined:find("skip")
                    or combined:find("map")
                    or combined:find("next") then
                    return obj
                end
            end
        end
    end

    return nil
end

-- Mencoba mengaktifkan tombol map
local function activateButton(target)
    if typeof(firesignal) == "function" then
        local ok = pcall(function()
            firesignal(target.Activated)
        end)

        if ok then
            return true
        end
    end

    if typeof(getconnections) == "function" then
        local fired = false

        local ok = pcall(function()
            for _, connection in
                ipairs(getconnections(target.Activated)) do

                if connection.Function then
                    connection:Fire()
                    fired = true
                    break
                end
            end
        end)

        if ok and fired then
            return true
        end
    end

    return false
end


-- Proses otomatis: deteksi siklus ukuran berulang
local previousSize = nil
local previousMaximum = nil
local armed = false
local busy = false
local lastTrigger = 0

task.spawn(function()
    while task.wait(0.25) do
        if not enabled then
            armed = false
            previousSize = nil
            previousMaximum = nil
        elseif not busy then
            local current, maximum = getSizeData()

            if not current or not maximum or maximum <= 0 then
                previousSize = nil
                previousMaximum = nil
                armed = false
            else
                -- Reset deteksi jika maksimum berubah
                if previousMaximum ~= maximum then
                    armed = false
                    previousSize = nil
                end

                -- Siapkan pemicu ketika ukuran mencapai maksimum
                if current >= maximum then
                    armed = true
                end

                -- Picu satu kali ketika ukuran turun setelah penuh
                local droppedAfterFull =
                    armed
                    and previousSize ~= nil
                    and current < previousSize

                if droppedAfterFull
                    and os.clock() - lastTrigger >= cooldown then

                    busy = true
                    armed = false
                    lastTrigger = os.clock()

                    task.wait(0.75)

                    -- Jangan lanjut jika fitur dimatikan
                    if enabled then
                        local target = findMapSkipButton()

                        if target then
                            if activateButton(target) then
                                print(
                                    "[ETW Auto Next Map] Percobaan skip dikirim."
                                )
                            else
                                warn(
                                    "[ETW Auto Next Map] Tombol ditemukan, tetapi gagal diaktifkan."
                                )
                            end
                        else
                            warn(
                                "[ETW Auto Next Map] Tombol skip tidak ditemukan."
                            )
                        end
                    end

                    busy = false
                end

                previousSize = current
                previousMaximum = maximum
            end
        end
    end
end)


print("[ETW Auto Next Map] Loaded.")
