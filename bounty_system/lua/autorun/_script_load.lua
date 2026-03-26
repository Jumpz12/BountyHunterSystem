--[[

    Do NOT touch.
    This is needed to load all files.

]]

-- TABLE SET UP

Jumpz = Jumpz or {}
Jumpz.Script = Jumpz.Script or {}
Jumpz.Script.Name = "Bounty System"
Jumpz.Script.Author = "Jumpz"
Jumpz.Script.Build = "v2.1"
Jumpz.Script.Released = "05/11/2025"
Jumpz.Script.Website = "https://github.com/Jumpz12"

-- INFORMATION

local luaroot = "bountyhunter"
local loadlabel = "Bounty Hunter"

local ScriptStartupHeader = {
    '\n\n',
    [[__________________________________________________ ]],
    '\n',
}

local ScriptStartupInfo = {
    [[Title      ....    ]] .. Jumpz.Script.Name .. [[ ]],
    [[Build      ....    ]] .. Jumpz.Script.Build .. [[ ]],
    [[Released   ....    ]] .. Jumpz.Script.Released .. [[ ]],
    [[Author     ....    ]] .. Jumpz.Script.Author .. [[ ]],
    [[Website    ....    ]] .. Jumpz.Script.Website .. [[ ]],
}

local ScriptStartupFooter = {
    [[__________________________________________________ ]],
}

for k, i in ipairs( ScriptStartupHeader ) do
    MsgC( Color( 255, 255, 0 ), i .. '\n' )
end

for k, i in ipairs( ScriptStartupInfo ) do
    MsgC( Color( 255, 255, 255 ), i .. '\n\n' )
end

for k, i in ipairs( ScriptStartupFooter ) do
    MsgC( Color( 255, 255, 0 ), i .. '\n\n' )
end

-- SERVER-SIDE

if SERVER then

    local fol = luaroot .. "/"
    local files, folders = file.Find(fol .. "*", "LUA")

    for k, v in pairs(files) do
        include(fol .. v)
    end

    for _, folder in SortedPairs(folders, true) do
        if folder == "." or folder == ".." then continue end

            for _, File in SortedPairs(file.Find(fol .. folder .. "/sh_*.lua", "LUA"), true) do
                MsgC(Color(255, 255, 0), "[" .. Jumpz.Script.Name .. "] SHARED file: " .. File .. "\n")
                AddCSLuaFile(fol .. folder .. "/" .. File)
                include(fol .. folder .. "/" .. File)
            end
        end

        for _, folder in SortedPairs(folders, true) do
            if folder == "." or folder == ".." then continue end

                for _, File in SortedPairs(file.Find(fol .. folder .. "/sv_*.lua", "LUA"), true) do
                    MsgC(Color(255, 255, 0), "[" .. Jumpz.Script.Name .. "] SERVER file: " .. File .. "\n")
                    include(fol .. folder .. "/" .. File)
                end
            end

            for _, folder in SortedPairs(folders, true) do
                if folder == "." or folder == ".." then continue end

                    for _, File in SortedPairs(file.Find(fol .. folder .. "/cl_*.lua", "LUA"), true) do
                        MsgC(Color(255, 255, 0), "[" .. Jumpz.Script.Name .. "] CLIENT file: " .. File .. "\n")
                        AddCSLuaFile(fol .. folder .. "/" .. File)
                    end
                end

                for _, folder in SortedPairs(folders, true) do
                    if folder == "." or folder == ".." then continue end

                        for _, File in SortedPairs(file.Find(fol .. folder .. "/vgui_*.lua", "LUA"), true) do
                            MsgC(Color(255, 255, 0), "[" .. Jumpz.Script.Name .. "] CLIENT file: " .. File .. "\n")
                            AddCSLuaFile(fol .. folder .. "/" .. File)
                        end
                    end

                    MsgC(Color( 0, 255, 0 ), "\n[ " .. loadlabel .. " Loaded ]\n\n")
                    MsgC(Color( 255, 255, 0), "__________________________________________________ \n\n")

                end

                -- CLIENT-SIDE

                if CLIENT then

                    local root = luaroot .. "/"
                    local _, folders = file.Find(root .. "*", "LUA")

                    for _, folder in SortedPairs(folders, true) do
                        if folder == "." or folder == ".." then continue end

                            for _, File in SortedPairs(file.Find(root .. folder .. "/sh_*.lua", "LUA"), true) do
                                MsgC(Color(255, 255, 0), "[" .. Jumpz.Script.Name .. "] SHARED file: " .. File .. "\n")
                                include(root .. folder .. "/" .. File)
                            end
                        end

                        for _, folder in SortedPairs(folders, true) do
                            for _, File in SortedPairs(file.Find(root .. folder .. "/cl_*.lua", "LUA"), true) do
                                MsgC(Color(255, 255, 0), "[" .. Jumpz.Script.Name .. "] CLIENT file: " .. File .. "\n")
                                include(root .. folder .. "/" .. File)
                            end
                        end

                        for _, folder in SortedPairs(folders, true) do
                            for _, File in SortedPairs(file.Find(root .. folder .. "/vgui_*.lua", "LUA"), true) do
                                MsgC(Color(255, 0, 0), "[" .. Jumpz.Script.Name .. "] VGUI file: " .. File .. "\n")
                                include(root .. folder .. "/" .. File)
                            end
                        end

                        MsgC(Color( 0, 255, 0 ), "\n[ " .. loadlabel .. " Loaded ]\n\n")
                        MsgC(Color( 255, 255, 0), "__________________________________________________ \n\n")

                    end