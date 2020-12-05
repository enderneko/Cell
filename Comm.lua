local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

local Compresser = LibStub:GetLibrary("LibCompress")
local Encoder = Compresser:GetAddonEncodeTable()
local Serializer = LibStub:GetLibrary("LibSerialize")
local Comm = LibStub:GetLibrary("AceComm-3.0")

local function Serialize(data)
    local serialized = Serializer:Serialize(data)
    local compressed = Compresser:CompressHuffman(serialized)
    return Encoder:Encode(compressed)
end

local function Deserialize(encoded)
    local decoded = Encoder:Decode(encoded)
    local decompressed, errorMsg = Compresser:Decompress(decoded)
    if not decompressed then
        F:Debug("Error decompressing: " .. errorMsg)
        return nil
    end
    local success, data = Serializer:Deserialize(decompressed)
    if not success then
        F:Debug("Error deserializing: " .. data)
        return nil
    end
    return data
end

local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)

local sendChannel
local function UpdateSendChannel()
    local isLFG
    if IsInInstance() then
        isLFG = select(10, GetInstanceInfo())
    end

    if isLFG then
        sendChannel = "INSTANCE_CHAT"
    elseif IsInRaid() then
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
    local version = tonumber(string.match(message, "%d+"))
    local myVersion = tonumber(string.match(Cell.version, "%d+"))
    if (not CellDB["lastVersionCheck"] or time()-CellDB["lastVersionCheck"]>=27000) and version and myVersion and myVersion < version then
        CellDB["lastVersionCheck"] = time()
        F:Print(L["New version found (%s). Please visit %s to get the latest version."]:format(message, "|cFF00CCFFhttps://www.curseforge.com/wow/addons/cell|r"))
    end
end)

-----------------------------------------
-- Notify Marks
-----------------------------------------
Comm:RegisterComm("CELL_MARKS", function(prefix, message, channel, sender)
    if sender == UnitName("player") then return end
    local data = Deserialize(message)
    if Cell.vars.hasPartyMarkPermission and CellDB["raidTools"]["showMarks"] and (CellDB["raidTools"]["marks"] == "target" or CellDB["raidTools"]["marks"] == "both") and data then
        sender = F:GetClassColorStr(select(2, UnitClass(sender)))..sender.."|r"

        if data[1] then -- lock
            F:Print(L["%s lock %s on %s."]:format(sender, F:GetMarkEscapeSequence(data[2]), data[3]))
        else
            F:Print(L["%s unlock %s from %s."]:format(sender, F:GetMarkEscapeSequence(data[2]), data[3]))
        end
    end
end)

function F:NotifyMarkLock(mark, name, class)
    name = F:GetClassColorStr(class)..name.."|r"
    F:Print(L["%s lock %s on %s."]:format(L["You"], F:GetMarkEscapeSequence(mark), name))
    
    UpdateSendChannel()
    Comm:SendCommMessage("CELL_MARKS", Serialize({true, mark, name}), sendChannel, nil, "BULK")
end

function F:NotifyMarkUnlock(mark, name, class)
    name = F:GetClassColorStr(class)..name.."|r"
    F:Print(L["%s unlock %s from %s."]:format(L["You"], F:GetMarkEscapeSequence(mark), name))

    UpdateSendChannel()
    Comm:SendCommMessage("CELL_MARKS", Serialize({false, mark, name}), sendChannel, nil, "BULK")
end