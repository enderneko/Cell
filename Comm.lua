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
    if (not CellDB["lastVersionCheck"] or time()-CellDB["lastVersionCheck"]>=25200) and version and myVersion and myVersion < version then
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

-----------------------------------------
-- Priority Check
-----------------------------------------
local myPriority
local highestPriority = 99
Cell.hasHighestPriority = false

local function UpdatePriority()
    myPriority = 99
    if UnitIsGroupLeader("player") then
        myPriority = 0
    else
        if IsInRaid() then
            for i = 1, GetNumGroupMembers() do
                if UnitIsUnit("player", "raid"..i) then
                    myPriority = i
                    break
                end
            end
        elseif IsInGroup() then -- party
            local players = {}
            local pName, pRealm = UnitFullName("player")
            pRealm = pRealm or GetRealmName()
            pName = pName.."-"..pRealm
            tinsert(players, pName)
            
            for i = 1, GetNumGroupMembers()-1 do
                local name, realm = UnitFullName("party"..i)
                tinsert(players, name.."-"..(realm or pRealm))
            end
            table.sort(players)
            
            for i, p in pairs(players) do
                if p == pName then
                    myPriority = i
                    break
                end
            end
        end
    end

end

local t_check, t_send, t_update
function F:CheckPriority()
    UpdatePriority()
    -- NOTE: needs time to calc myPriority
    C_Timer.After(1, function()
        UpdateSendChannel()
        Comm:SendCommMessage("CELL_CPRIO", "chk", sendChannel, nil, "BULK")
    end)
    -- if t_check then t_check:Cancel() end
    -- t_check = C_Timer.NewTimer(2, function()
    --     UpdateSendChannel()
    --     Comm:SendCommMessage("CELL_CPRIO", "chk", sendChannel, nil, "BULK")
    -- end)
end

Comm:RegisterComm("CELL_CPRIO", function(prefix, message, channel, sender)
    if not myPriority then return end -- receive CELL_CPRIO just after GOURP_JOINED 
    highestPriority = 99
    
    -- NOTE: wait for check requests
    if t_send then t_send:Cancel() end
    t_send = C_Timer.NewTimer(2, function()
        UpdateSendChannel()
        Comm:SendCommMessage("CELL_PRIO", tostring(myPriority), sendChannel, nil, "BULK")
    end)
end)

Comm:RegisterComm("CELL_PRIO", function(prefix, message, channel, sender)
    if not myPriority then return end -- receive CELL_PRIO just after GOURP_JOINED

    local p = tonumber(message)
    if p then
        highestPriority = highestPriority < p and highestPriority or p

        if t_update then t_update:Cancel() end
        t_update = C_Timer.NewTimer(2, function()
            Cell.hasHighestPriority = myPriority <= highestPriority
            Cell:Fire("UpdatePriority", Cell.hasHighestPriority)
            F:Debug("|cff00ff00UpdatePriority:|r", Cell.hasHighestPriority)
        end)
    end
end)