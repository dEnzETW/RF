-- rEm.lua - whitelist case-insensitive compatibility loader
-- IMPORTANT:
-- 1. Rename the existing full script to rEm-original.lua in the same GitHub repository.
-- 2. Upload this file as rEm.lua.
-- 3. This loader downloads rEm-original.lua, fixes only the whitelist comparison,
--    then runs the original script with its existing features intact.

local sourceUrl = "https://raw.githubusercontent.com/dEnzETW/RF/refs/heads/main/rEm-original.lua"

local ok, source = pcall(function()
    return game:HttpGet(sourceUrl)
end)

if not ok or type(source) ~= "string" or #source == 0 then
    warn("rEm: gagal mengunduh rEm-original.lua. Periksa nama file dan branch GitHub.")
    return
end

local oldCheck = "if not table.find(WhitelistedUsers, LocalPlayer.Name) then"
local newCheck = [[if not (function()
    for _, username in ipairs(WhitelistedUsers) do
        if string.lower(username) == string.lower(LocalPlayer.Name) then
            return true
        end
    end
    return false
end)() then]]

if not string.find(source, oldCheck, 1, true) then
    warn("rEm: baris pengecekan whitelist tidak ditemukan. Pastikan rEm-original.lua adalah script asli.")
    return
end

source = string.gsub(source, oldCheck, function()
    return newCheck
end, 1)

local compileOk, chunkOrError = pcall(function()
    return loadstring(source)
end)

if not compileOk or type(chunkOrError) ~= "function" then
    warn("rEm: gagal memproses script: " .. tostring(chunkOrError))
    return
end

local runOk, runError = pcall(chunkOrError)
if not runOk then
    warn("rEm: script error: " .. tostring(runError))
end
