-- Paste into the executor while in game.
-- Use the returned saver, not Xeno's global saveinstance.
local url = "https://raw.githubusercontent.com/tailolicon/UniversalSynSaveInstance/005e15dd68dab24b99df9439007cacc4a23a8e89/saveinstance.lua"
local loader, loadError = loadstring(game:HttpGet(url), "saveinstance")
assert(loader, loadError)
local cleanSave = loader()
assert(type(cleanSave) == "function", "The downloaded saver did not return a function")
assert(type(writefile) == "function", "writefile is unavailable")

local filePath = "place_dump.rbxlx"
local wroteFile = false
local function validateAndWrite(data)
    assert(type(data) == "string", "No serialized data returned")
    assert(data:find('<roblox version="4">', 1, true), "Expected XML output")
    assert(data:find("<Item ", 1, true), "No instances were saved")
    assert(data:match("</roblox>%s*$"), "Incomplete XML output")

    local lower = string.lower(data)
    for _, marker in ipairs({
        "universalsynsaveinstance",
        "join to copy games",
        "discord.gg/wx4thpasmw",
    }) do
        assert(not lower:find(marker, 1, true), "Export rejected: remaining marker " .. marker)
    end
    for name in lower:gmatch('<string name="name">(.-)</string>') do
        assert(name ~= "readme", "Export rejected: README instance")
        assert(not (name:find("loadstring", 1, true) and name:find("saveinstance", 1, true)),
            "Export rejected: saveinstance loader module")
    end

    -- Do not overwrite an existing dump until validation has passed.
    writefile(filePath, data)
    wroteFile = true
end

local ok, saveError = cleanSave({
    FilePath = filePath,
    mode = "optimized",
    noscripts = false,
    scriptcache = true,
    decomptype = "new",
    SaveBytecode = true,
    NilInstances = true,
    timeout = 60,
    ShowStatus = true,
    ReadMe = false,
    Callback = validateAndWrite,
})
assert(ok == true, tostring(saveError or "Save failed"))
assert(wroteFile, "The saver did not produce a validated file")
print("dump done -> executor workspace/" .. filePath .. " (known exporter markers checked)")

