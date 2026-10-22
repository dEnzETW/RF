
-- Eat the World: Auto Next Map (standalone addon)
-- Tidak mengubah rEm.lua atau fitur Auto Eat / Auto Sell.
-- Mendeteksi ukuran maksimum, lalu mencari tombol pindah map setelah ukuran turun.

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local enabled = true
local wasAtMax = false
local previousSize = nil
local lastMapSkip = 0
local cooldown = 3

local function getSizeData()
    local character = player.Character
    local sizeObj = character and character:FindFirstChild("Size")
    local current = sizeObj
        and (sizeObj:IsA("NumberValue") or sizeObj:IsA("IntValue"))
        and sizeObj.Value or nil

    local upgrades = player:FindFirstChild("Upgrades")
        or player:FindFirstChild("upgrades")
        or player:FindFirstChild("Upgrade")

    local maxObj = upgrades and (
        upgrades:FindFirstChild("MaxSize")
        or upgrades:FindFirstChild("Capacity")
    )

    local maximum = maxObj
        and (maxObj:IsA("NumberValue") or maxObj:IsA("IntValue"))
        and maxObj.Value or nil

    return current, maximum
end

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
            if obj:IsA("GuiButton") and obj.Visible then
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

local function activateButton(button)
    if typeof(firesignal) == "function" then
        local ok = pcall(function()
            firesignal(button.Activated)
        end)

        if ok then
            return true
        end
    end

    if typeof(getconnections) == "function" then
        local ok = pcall(function()
            for _, connection in ipairs(getconnections(button.Activated)) do
                if connection.Function then
                    connection:Fire()
                    return
                end
            end
        end)

        if ok then
            return true
        end
    end

    return false
end

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

                    -- Ukuran turun setelah maksimum; mungkin baru saja menjual.
                    task.wait(0.75)

                    local button = findMapSkipButton()

                    if button then
                        if activateButton(button) then
                            lastMapSkip = os.clock()
                            print("[ETW Auto Next Map] Map button activated.")
                        else
                            warn("[ETW Auto Next Map] Tombol ditemukan, tetapi tidak dapat diaktifkan.")
                        end
                    else
                        warn("[ETW Auto Next Map] Tombol pindah map tidak ditemukan.")
                    end

                    wasAtMax = false
                end

                previousSize = current
            end
        end
    end
end)

print("[ETW Auto Next Map] Loaded separately. Auto Eat / Auto Sell in rEm.lua are untouched.")
