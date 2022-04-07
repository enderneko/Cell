local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local I = Cell.iFuncs

local LCG = LibStub("LibCustomGlow-1.0")
local Comm = LibStub:GetLibrary("AceComm-3.0")

local function HideGlow(glowFrame)
    LCG.ButtonGlow_Stop(glowFrame)
    LCG.PixelGlow_Stop(glowFrame)
    LCG.AutoCastGlow_Stop(glowFrame)
    
    if glowFrame.timer then
        glowFrame.timer:Cancel()
    end
end

local function ShowGlow(glowFrame, glowType, glowOptions, timeout)
    F:Debug("GLOW:", glowFrame:GetName())
    
    if glowType == "normal" then
        LCG.PixelGlow_Stop(glowFrame)
        LCG.AutoCastGlow_Stop(glowFrame)
        LCG.ButtonGlow_Start(glowFrame, glowOptions[1])
    elseif glowType == "pixel" then
        LCG.ButtonGlow_Stop(glowFrame)
        LCG.AutoCastGlow_Stop(glowFrame)
        -- color, N, frequency, length, thickness, x, y
        LCG.PixelGlow_Start(glowFrame, glowOptions[1], glowOptions[4], glowOptions[5], glowOptions[6], glowOptions[7], glowOptions[2], glowOptions[3])
    elseif glowType == "shine" then
        LCG.ButtonGlow_Stop(glowFrame)
        LCG.PixelGlow_Stop(glowFrame)
        -- color, N, frequency, scale, x, y
        LCG.AutoCastGlow_Start(glowFrame, glowOptions[1], glowOptions[4], glowOptions[5], glowOptions[6], glowOptions[2], glowOptions[3])
    end

    if glowFrame.timer then
        glowFrame.timer:Cancel()
    end
    glowFrame.timer = C_Timer.NewTimer(timeout, function()
        glowFrame.timer = nil
        HideGlow(glowFrame)
    end)
end

-------------------------------------------------
-- power infusion request
-------------------------------------------------
local PIR_SPELL_ID = 10060
local pirEnabled, pirPriest, pirFreeCD, pirType, pirTimeout, pirKeyword
local pirUnits = {}
local PIR = CreateFrame("Frame")

local function CheckPIConditions()
    return (not pirPriest) or ((pirFreeCD and IsSpellKnown(PIR_SPELL_ID) and GetSpellCooldown(PIR_SPELL_ID) == 0) or (not pirFreeCD))
end

local function ShowPIGlow(button)
    if button then
        if not F:FindAuraById(button.state.unit, "BUFF", PIR_SPELL_ID) and UnitIsVisible(button.state.unit) then
            pirUnits[button.state.unit] = button -- save for hiding
            ShowGlow(button.widget.pirGlowFrame, CellDB["tools"]["PIRequest"][7][1], CellDB["tools"]["PIRequest"][7][2], pirTimeout)
        end
    end
end

-- glow on addon message
Comm:RegisterComm("CELL_REQ_PI", function(prefix, message, channel, sender)
    if pirEnabled then
        if pirType == "all" or (pirType == "me" and message == GetUnitName("player")) then
            if CheckPIConditions() then
                ShowPIGlow(F:GetUnitButtonByName(sender))
            end
        end
    end
end)

-- glow on whisper
function PIR:CHAT_MSG_WHISPER(text, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName, languageID, lineID, guid, bnSenderID, isMobile, isSubtitle, hideSenderInLetterbox, supressRaidIcons)
    if strfind(strlower(text), strlower(pirKeyword)) then
        if CheckPIConditions() then
            ShowPIGlow(F:GetUnitButtonByGUID(guid))
        end
    end
end

-- hide glow when PI changes
function PIR:UNIT_AURA(unit, isFullUpdate, updatedAuras)
    if type(updatedAuras) == "table" then
        for _, aura in pairs(updatedAuras) do
            if aura.spellId == PIR_SPELL_ID and pirUnits[unit] then
                HideGlow(pirUnits[unit].widget.pirGlowFrame)
                pirUnits[unit] = nil
            end
        end
    end
end

PIR:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)

local function PIR_UpdateTools(which)
    if not which or which == "pirequest" then
        -- NOTE: hide all
        for _, button in pairs(pirUnits) do
            HideGlow(button.widget.pirGlowFrame)
        end
        wipe(pirUnits)

        local enabled

        if CellDB["tools"]["PIRequest"][1] then
            if CellDB["tools"]["PIRequest"][2] then
                if Cell.vars.playerClass == "PRIEST" then
                    enabled = true
                end
            else -- all classes
                enabled = true
            end
        end

        pirEnabled = enabled
        
        if enabled then
            pirPriest = CellDB["tools"]["PIRequest"][2]
            pirFreeCD = CellDB["tools"]["PIRequest"][3]
            pirType = CellDB["tools"]["PIRequest"][4]
            pirTimeout = CellDB["tools"]["PIRequest"][5]
            -- pirGlowType = CellDB["tools"]["PIRequest"][7][1]
            -- pirGlowOptions = CellDB["tools"]["PIRequest"][7][2]

            if pirType == "whisper" then
                PIR:RegisterEvent("CHAT_MSG_WHISPER")
                pirKeyword = CellDB["tools"]["PIRequest"][6]
            else
                PIR:UnregisterEvent("CHAT_MSG_WHISPER")
            end

            PIR:RegisterEvent("UNIT_AURA")
        else
            PIR:UnregisterAllEvents()
        end
    end
end
Cell:RegisterCallback("UpdateTools", "PIR_UpdateTools", PIR_UpdateTools)

-------------------------------------------------
-- dispel request
-------------------------------------------------
local drEnabled, drDispellable, drType, drTimeout, drDebuffs
local drUnits = {}
local DR = CreateFrame("Frame")

-- hide all
local function HideAllDRGlows()
    -- NOTE: hide all
    for unit in pairs(drUnits) do
        local button = F:GetUnitButtonByUnit(unit)
        if button then
            HideGlow(button.widget.drGlowFrame)
        end
    end
    wipe(drUnits)
end

-- hide glow if removed
DR:SetScript("OnEvent", function(self, event)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local timestamp, subEvent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID = CombatLogGetCurrentEventInfo()
        if subEvent == "SPELL_AURA_REMOVED" then
            local unit = Cell.vars.guids[destGUID]
            if unit and drUnits[unit] and drUnits[unit][spellID] then
                -- NOTE: one of debuffs removed, hide glow
                drUnits[unit] = nil
                local button = F:GetUnitButtonByGUID(destGUID)
                if button then
                    HideGlow(button.widget.drGlowFrame)
                end
            end
        end
    else
        
    end
end)

-- glow on addon message
Comm:RegisterComm("CELL_REQ_D", function(prefix, message, channel, sender)
    if drEnabled then
        local unit = Cell.vars.names[sender]
        if not unit or not UnitIsVisible(unit) then return end

        if drType == "all" then
            -- NOTE: get all dispellable debuffs on unit
            drUnits[unit] = F:FindAuraByDebuffTypes(unit, "all")
        else -- specific debuff
            -- NOTE: get specific dispellable debuffs on unit
            drUnits[unit] = F:FindDebuffByIds(unit, drDebuffs)
        end
       
        -- NOTE: filter dispellable by me
        if drDispellable then
            for spellId, debuffType in pairs(drUnits[unit]) do
                if not I:CanDispel(debuffType) then
                    drUnits[unit][spellId] = nil
                end
            end
        end

        if F:Getn(drUnits[unit]) ~= 0 then -- found
            local button = F:GetUnitButtonByName(sender)
            if button then
                ShowGlow(button.widget.drGlowFrame, CellDB["tools"]["DRequest"][6][1], CellDB["tools"]["DRequest"][6][2], drTimeout)
            end
        else
            drUnits[unit] = nil
        end
    end
end)

local function DR_UpdateTools(which)
    if not which or which == "drequest" then
        HideAllDRGlows()
        
        drEnabled = CellDB["tools"]["DRequest"][1]

        if drEnabled then
            drDispellable = CellDB["tools"]["DRequest"][2]
            drType = CellDB["tools"]["DRequest"][3]
            drTimeout = CellDB["tools"]["DRequest"][4]
            drDebuffs = F:ConvertTable(CellDB["tools"]["DRequest"][5])

            DR:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
            DR:RegisterEvent("ENCOUNTER_START")
            DR:RegisterEvent("ENCOUNTER_END")
        else
            DR:UnregisterAllEvents()
        end
        -- texplore(drUnits)
        -- texplore(drDebuffs)
    end
end
Cell:RegisterCallback("UpdateTools", "DR_UpdateTools", DR_UpdateTools)