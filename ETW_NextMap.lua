
-- Eat the World: Auto Next Map
-- Panel ON/OFF terpisah dari rEm.lua.
-- Auto Eat dan Auto Sell di rEm.lua tidak diubah.

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local enabled = true
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
button.Draggable = true
button.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = button

local function toggleAutoNextMap()
    enabled = not enabled

    button.Text = enabled
        and "Auto Next Map: ON"
        or "Auto Next Map: OFF"

    button.BackgroundColor3 = enabled
        and Color3.fromRGB(35, 150, 85)
        or Color3.fromRGB(160, 55, 55)

    print("[ETW Auto Next Map] " ..
        (enabled and "ON" or "OFF"))
end

button.Activated:Connect(toggleAutoNextMap)

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

-- Mencoba mengaktifkan tombol yang ditemukan
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

-- Proses otomatis: deteksi berulang setiap kali ukuran turun
local previousCurrent = nil
local previousMaximum = nil
local lastTrigger = 0
local busy = false

task.spawn(function()
    while task.wait(0.25) do
        if enabled and not busy then
            local current, maximum = getSizeData()

            if current and maximum and maximum > 0 then
                local wasFull = previousCurrent
                    and previousMaximum
                    and previousCurrent >= previousMaximum

                local droppedAfterFull = wasFull
                    and current < previousCurrent

                if droppedAfterFull
                    and os.clock() - lastTrigger >= cooldown then

                    busy = true
                    lastTrigger = os.clock()

                    task.wait(0.75)

                    if enabled then
                        local target = findMapSkipButton()

                        if target then
                            if activateButton(target) then
                                print(
                                    "[ETW Auto Next Map] Percobaan pindah map dikirim."
                                )
                            else
                                warn(
                                    "[ETW Auto Next Map] Tombol ditemukan tetapi gagal diaktifkan."
                                )
                            end
                        else
                            warn(
                                "[ETW Auto Next Map] Tombol map tidak ditemukan."
                            )
                        end
                    end

                    busy = false
                end

                previousCurrent = current
                previousMaximum = maximum
            else
                previousCurrent = nil
                previousMaximum = nil
            end
        elseif not enabled then
            previousCurrent = nil
            previousMaximum = nil
        end
    end
end)

print(
    "[ETW Auto Next Map] Loaded. Gunakan panel untuk ON/OFF."
)
