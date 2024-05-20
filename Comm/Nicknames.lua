local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

local Comm = LibStub:GetLibrary("AceComm-3.0")

-----------------------------------------
-- shared
-----------------------------------------
local sendChannel
local function UpdateSendChannel()
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        sendChannel = "INSTANCE_CHAT"
    elseif IsInRaid() then
        sendChannel = "RAID"
    else
        sendChannel = "PARTY"
    end
end

-----------------------------------------
-- nickname
-----------------------------------------
Cell.vars.nicknames = {}
Cell.vars.nicknameCustoms = {}

function F:GetNickname(shortname, fullname)
    local name
    if Cell.vars.nicknameCustomEnabled then
        name = Cell.vars.nicknameCustoms[fullname] or
               Cell.vars.nicknameCustoms[shortname] or
               Cell.vars.nicknames[fullname] or
               Cell.vars.nicknames[shortname] or
               shortname
    else
        name = Cell.vars.nicknames[fullname] or
               Cell.vars.nicknames[shortname] or
               shortname
    end
    return name or _G.UNKNOWNOBJECT
end

local nic_check, nic_send

local function Update(b)
    b.indicators.nameText:UpdateName()
end

local function UpdateName(who)
    F:Debug("|cFF69A000UpdateName:|r|cFF696969", who, Cell.vars.nicknames[who], Cell.vars.nicknameCustoms[who])
    -- update name
    local handled = F:HandleUnitButton("name", who, Update)
    if not handled then
        if strfind(who, "-") then
            who = F:ToShortName(who)
        else
            who = who.."-"..GetNormalizedRealmName()
        end
        F:HandleUnitButton("name", who, Update)
    end
    -- update quickAssist
    local unit = Cell.vars.names[who]
    if unit and Cell.unitButtons.quickAssist.units[unit] then
        Cell.unitButtons.quickAssist.units[unit].nameText:UpdateName()
    end
end

local function CheckNicknames()
    if IsInGroup() then
        if CellDB["nicknames"]["sync"] then
            if nic_check then nic_check:Cancel() end
            nic_check = C_Timer.NewTimer(random(3), function()
                UpdateSendChannel()
                Comm:SendCommMessage("CELL_CNIC", "chk", sendChannel, nil, "ALERT")
            end)
        end
    end
end

local function CheckSelf()
    Cell.vars.nicknames[Cell.vars.playerNameShort] = Cell.vars.playerNickname
    UpdateName(Cell.vars.playerNameShort)

    -- update preview buttons
    if CellLayoutsPreviewButton then
        CellLayoutsPreviewButton.indicators.nameText:UpdateName()
    end
    if CellIndicatorsPreviewButton then
        CellIndicatorsPreviewButton.indicators.nameText:UpdateName()
    end
    if CellRaidDebuffsPreviewButton then
        CellRaidDebuffsPreviewButton.indicators.nameText:UpdateName()
    end
    if CellGlowsPreviewButton then
        CellGlowsPreviewButton.indicators.nameText:UpdateName()
    end
end

-- events -----------------------------
local nickname = CreateFrame("Frame")
nickname:SetScript("OnEvent", function(self, event, ...)
    self[event](self, ...)
end)

nickname:RegisterEvent("PLAYER_ENTERING_WORLD")

function nickname:PLAYER_ENTERING_WORLD()
    nickname:UnregisterEvent("PLAYER_ENTERING_WORLD")
    Cell:Fire("UpdateNicknames")
end

function nickname:GROUP_ROSTER_UPDATE()
    CheckNicknames()
end
---------------------------------------

local function UpdateNicknames(which, value1, value2)
    F:Debug("|cFF80FF00UpdateNicknames:|r", which, value1, value2)
    -- init
    if not which then
        Cell.vars.playerNickname = CellDB["nicknames"]["mine"] ~= "" and CellDB["nicknames"]["mine"] or nil
        Cell.vars.nicknameCustomEnabled = CellDB["nicknames"]["custom"]
        CheckSelf()

        if CellDB["nicknames"]["sync"] then
            CheckNicknames()
            nickname:RegisterEvent("GROUP_ROSTER_UPDATE")
        end

        -- customs
        for _, v in ipairs(CellDB["nicknames"]["list"]) do
            local playerName, nickname = strsplit(":", v, 2)
            if playerName and nickname then
                Cell.vars.nicknameCustoms[playerName] = nickname
                if CellDB["nicknames"]["custom"] then
                    UpdateName(playerName)
                end
            end
        end
    end

    -- enable/disable sync
    if which == "sync" then
        if CellDB["nicknames"]["sync"] then
            CheckNicknames()
            nickname:RegisterEvent("GROUP_ROSTER_UPDATE")
        else
            -- clear all except mine
            F:RemoveElementsExceptKeys(Cell.vars.nicknames, Cell.vars.playerNameShort)
            nickname:UnregisterEvent("GROUP_ROSTER_UPDATE")

            if nic_check then nic_check:Cancel() end
            -- disabled, notify others
            UpdateSendChannel()
            Comm:SendCommMessage("CELL_NIC", "CELL_NONE", sendChannel)

            -- update all
            F:IterateAllUnitButtons(function(b)
                b.indicators.nameText:UpdateName()
            end, true)
        end
    end

    -- player changed nickname
    if which == "mine" then
        Cell.vars.playerNickname = CellDB["nicknames"]["mine"] ~= "" and CellDB["nicknames"]["mine"] or nil

        -- update self
        CheckSelf()

        -- notify others
        if IsInGroup() and CellDB["nicknames"]["sync"] then
            UpdateSendChannel()
            Comm:SendCommMessage("CELL_NIC", Cell.vars.playerNickname or "CELL_NONE", sendChannel)
        end
    end

    -- customs
    if which == "custom" then
        Cell.vars.nicknameCustomEnabled = CellDB["nicknames"]["custom"]
        -- update now
        for playerName in pairs(Cell.vars.nicknameCustoms) do
            UpdateName(playerName)
        end
    end

    -- list
    if which == "list-add" then
        Cell.vars.nicknameCustoms[value1] = value2
        UpdateName(value1)
    end
    if which == "list-delete" then
        Cell.vars.nicknameCustoms[value1] = nil
        UpdateName(value1)
    end
end
Cell:RegisterCallback("UpdateNicknames", "UpdateNicknames", UpdateNicknames)

-- check nickname received
Comm:RegisterComm("CELL_CNIC", function(prefix, message, channel, sender)
    -- others send chk before you, no need to send chk again
    if nic_check then nic_check:Cancel() end

    if nic_send then nic_send:Cancel() end
    nic_send = C_Timer.NewTimer(3, function()
        UpdateSendChannel()
        if CellDB["nicknames"]["sync"] then
            Comm:SendCommMessage("CELL_NIC", Cell.vars.playerNickname or "CELL_NONE", sendChannel)
        else
            Comm:SendCommMessage("CELL_NIC", "CELL_NONE", sendChannel)
        end
    end)
end)

-- nickname received
Comm:RegisterComm("CELL_NIC", function(prefix, message, channel, sender)
    if sender == Cell.vars.playerNameShort then return end

    if CellDB["nicknames"]["sync"] then
        if message == "CELL_NONE" then
            Cell.vars.nicknames[sender] = nil
        else
            Cell.vars.nicknames[sender] = message
        end
        UpdateName(sender)
    end
end)

-----------------------------------------
-- NickTag
-----------------------------------------
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
    f:UnregisterAllEvents()

    if not CELL_NICKTAG_ENABLED then return end

    local nickTag = LibStub:GetLibrary("NickTag-1.0", true)
    if nickTag then
        Cell.NickTag = nickTag

        local function UpdateAll()
            -- update all
            F:IterateAllUnitButtons(function(b)
                b.indicators.nameText:UpdateName()
            end, true)
        end

        local timer
        nickTag:RegisterCallback("NickTag_Update", function()
            if timer then
                timer:Cancel()
                timer = nil
            end
            timer = C_Timer.NewTimer(3, UpdateAll)
        end)
    end
end)
