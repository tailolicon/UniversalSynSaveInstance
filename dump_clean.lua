-- Paste into the executor while in game.
-- Call the saver returned by the download; do not call Xeno's global saver.
local url = "https://raw.githubusercontent.com/tailolicon/UniversalSynSaveInstance/7ca8782c917318354265743cc7dc98cc8e8994d3/saveinstance.lua"
local loader, loadError = loadstring(game:HttpGet(url), "saveinstance")
assert(loader, loadError)
local save = loader()
assert(type(save) == "function", "The downloaded saver did not return a function")
assert(type(writefile) == "function", "writefile is unavailable")

local filePath = "place_dump.rbxlx"
local wroteFile = false
save({
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
    Callback = function(data)
        assert(type(data) == "string" and data:find("<Item ", 1, true), "No instances were saved")
        assert(data:find('<roblox version="4">', 1, true) and data:match("</roblox>%s*$"),
            "Incomplete XML output")
        local lower = string.lower(data)
        -- Split literals so the checker itself cannot be mistaken for a watermark.
        for _, marker in ipairs({
            "saved by universal" .. "synsaveinstance",
            "thank you for using universal" .. "synsaveinstance",
            "join to " .. "copy games",
            "discord.gg/" .. "wx4thpasmw",
        }) do
            assert(not lower:find(marker, 1, true),
                "Remaining exporter attribution: " .. marker .. "; old file was not overwritten")
        end
        for name in lower:gmatch('<string name="name">(.-)</string>') do
            assert(not (name:match("^loadstring:") and name:find("saveinstance", 1, true)),
                "Remaining exporter loader module; old file was not overwritten")
        end
        writefile(filePath, data)
        wroteFile = true
    end,
})
-- The original saver returns nil even on success; completion is tracked via Callback.
assert(wroteFile, "Save did not finish. Check the F9 console for the original error.")
print("dump done -> executor workspace/" .. filePath .. " (known exporter attribution checked)")
