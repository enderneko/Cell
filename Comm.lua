local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

-- local Compresser = LibStub:GetLibrary("LibCompress")
-- local Encoder = Compresser:GetAddonEncodeTable()
-- local Serializer = LibStub:GetLibrary("AceSerializer-3.0")
local Comm = LibStub:GetLibrary("AceComm-3.0")

-- from WeakAuras
-- local function TableToString(inTable)
--     local serialized = Serializer:Serialize(inTable)
--     local compressed = Compresser:CompressHuffman(serialized)
--     return Encoder:Encode(compressed)
-- end

-- local function StringToTable(inString)
--     local decoded = Encoder:Decode(inString)
--     local decompressed, errorMsg = Compresser:Decompress(decoded)
--     if not(decompressed) then
--         GRA:Debug("Error decompressing: " .. errorMsg)
--         return nil
--     end
--     local success, deserialized = Serializer:Deserialize(decompressed)
--     if not(success) then
--         GRA:Debug("Error deserializing: " .. deserialized)
--         return nil
--     end
--     return deserialized
-- end

local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)

local sendChannel
local function UpdateSendChannel()
    if IsInRaid() then
        sendChannel = "RAID"
    else
        sendChannel = "PARTY"
    end
end

-----------------------------------------
-- Check Version
-----------------------------------------
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
function eventFrame:GROUP_ROSTER_UPDATE()
    if IsInGroup() then
        eventFrame:UnregisterEvent("GROUP_ROSTER_UPDATE")
        UpdateSendChannel()
        Comm:SendCommMessage("CELL_VERSION", Cell.version, sendChannel, nil, "BULK")
    end
end

eventFrame:RegisterEvent("PLAYER_LOGIN")
function eventFrame:PLAYER_LOGIN()
    if IsInGuild() then
        Comm:SendCommMessage("CELL_VERSION", Cell.version, "GUILD", nil, "BULK")
    end
end

Comm:RegisterComm("CELL_VERSION", function(prefix, message, channel, sender)
    if sender == UnitName("player") then return end
    if (not CellDB["lastVersionCheck"] or time()-CellDB["lastVersionCheck"]>=86400) and Cell.version < message then
        CellDB["lastVersionCheck"] = time()
        F:Print(L["New version found (%s). Please visit %s to get the latest version."]:format(message, "|cFF00CCFFhttps://www.curseforge.com/wow/addons/cell|r"))
    end
end)