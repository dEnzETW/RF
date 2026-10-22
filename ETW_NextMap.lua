
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

-- Proses otomatis
task.spawn(function()
    while task.wait(0.25) do
        if enabled then
            local current, maximum = getSizeData()

            if current and maximum and maximum > 0 then
                if current >= maximum then
                    wasAtMax = true

                elseif wasAtMax
                    and previousSize
                    and current < previousSize
                    and os.clock() - lastMapSkip >= cooldown then

                    task.wait(0.75)

                    -- Batalkan proses jika sudah OFF
                    if not enabled then
                        wasAtMax = false
                        previousSize = nil
                    else
                        local target = findMapSkipButton()

                        if target and activateButton(target) then
                            lastMapSkip = os.clock()
                            print(
                                "[ETW Auto Next Map] Aktivasi tombol dicoba."
                            )
                        elseif not target then
                            warn(
                                "[ETW Auto Next Map] Tombol map tidak ditemukan."
                            )
                        else
                            warn(
                                "[ETW Auto Next Map] Tombol tidak dapat diaktifkan."
                            )
                        end

                        wasAtMax = false
                    end
                end

                previousSize = current
            else
                previousSize = nil
                wasAtMax = false
            end
        end
    end
end)

print("[ETW Auto Next Map] Loaded.")
