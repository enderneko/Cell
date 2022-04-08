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
        glowFrame.timer = nil
    end
end

local function ShowGlow(glowFrame, glowType, glowOptions, timeout, callback)
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
        if callback then
            callback()
        end
    end)
end

-------------------------------------------------
-- spell request
-------------------------------------------------
local srEnabled, srKnown, srFreeCD, srReplyCD, srType, srTimeout
local srSpells = {
    -- [spellId] = {keywords, glowOptions}
}
local srUnits = {
    -- [unit] = {spellId, button}
}
local SR = CreateFrame("Frame")

local ITEM_COOLDOWN_TIME = _G.ITEM_COOLDOWN_TIME
local function CheckSRConditions(spellId, sender)
    if not srSpells[spellId] then
        return
    end

    if srKnown then
        if IsSpellKnown(spellId) then
            local start, duration, enabled, modRate = GetSpellCooldown(spellId)
            local cdLeft = start + duration - GetTime()

            if srFreeCD then -- NOTE: require free cd
                if start == 0 or duration == 0 then
                    return true
                else
                    if srReplyCD then -- reply cooldown
                        SendChatMessage(GetSpellLink(spellId).." "..format(ITEM_COOLDOWN_TIME, F:SecondsToTime(cdLeft)), "WHISPER", nil, sender)
                    end
                    return false
                end
            else -- NOTE: no require free cd
                if srReplyCD and start > 0 and duration > 0 then -- reply cd if cd
                    SendChatMessage(GetSpellLink(spellId).." "..format(ITEM_COOLDOWN_TIME, F:SecondsToTime(cdLeft)), "WHISPER", nil, sender)
                end
                return true
            end
        else
            return false
        end
    else
        return true
    end
end

local function ShowSRGlow(spellId, button)
    if button then
        if not F:FindAuraById(button.state.unit, "BUFF", spellId) and UnitIsVisible(button.state.unit) then
            srUnits[button.state.unit] = {spellId, button} -- save for hiding
            ShowGlow(button.widget.srGlowFrame, srSpells[spellId][2][1], srSpells[spellId][2][2], srTimeout, function()
                srUnits[button.state.unit] = nil
            end)
        end
    end
end

-- glow on addon message
Comm:RegisterComm("CELL_REQ_S", function(prefix, message, channel, sender)
    if srEnabled then
        local spellId, target = strsplit(":", message)
        spellId = tonumber(spellId)

        if spellId and CheckSRConditions(spellId, sender) then
            -- NOTE: to all provider / to me
            if (srType == "all" and not target) or (srType == "me" and target == GetUnitName("player")) then
                ShowSRGlow(spellId, F:GetUnitButtonByName(sender))
            end   
        end
    end
end)

-- glow on whisper
function SR:CHAT_MSG_WHISPER(text, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName, languageID, lineID, guid, bnSenderID, isMobile, isSubtitle, hideSenderInLetterbox, supressRaidIcons)
    -- NOTE: cd reply
    if strmatch(text, "c.+|H.+|h%[.+%]|h|r.+%d+:%d+") then return end

    for spellId, t in pairs(srSpells) do
        if strfind(strlower(text), strlower(t[1])) then
            if CheckSRConditions(spellId, playerName) then
                ShowSRGlow(spellId, F:GetUnitButtonByGUID(guid))
                break
            end
        end
    end
end

-- hide glow when aura changes
function SR:UNIT_AURA(unit, isFullUpdate, updatedAuras)
    local srUnit = srUnits[unit]
    if not srUnit then return end

    if type(updatedAuras) == "table" then
        for _, aura in pairs(updatedAuras) do
            if srUnit[1] == aura.spellId then
                HideGlow(srUnit[2].widget.srGlowFrame)
                srUnits[unit] = nil
            end
        end
    end
end

SR:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)

local function SR_UpdateTools(which)
    if not which or which == "spellRequest" then
        -- NOTE: hide all
        for _, t in pairs(srUnits) do
            HideGlow(t[2].widget.srGlowFrame)
        end
        wipe(srUnits)
        wipe(srSpells)

        srEnabled = CellDB["tools"]["spellRequest"][1]
        
        if srEnabled then
            srKnown = CellDB["tools"]["spellRequest"][2]
            srFreeCD = CellDB["tools"]["spellRequest"][3]
            srReplyCD = CellDB["tools"]["spellRequest"][4]
            srType = CellDB["tools"]["spellRequest"][5]
            srTimeout = CellDB["tools"]["spellRequest"][6]
            for _, t in pairs(CellDB["tools"]["spellRequest"][7]) do
                srSpells[t[1]] = {t[2], t[3]}
            end

            if srType == "whisper" then
                SR:RegisterEvent("CHAT_MSG_WHISPER")
            else
                SR:UnregisterEvent("CHAT_MSG_WHISPER")
            end

            SR:RegisterEvent("UNIT_AURA")
        else
            SR:UnregisterAllEvents()
        end
        -- texplore(srUnits)
    end
end
Cell:RegisterCallback("UpdateTools", "SR_UpdateTools", SR_UpdateTools)

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
        HideAllDRGlows()
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
                ShowGlow(button.widget.drGlowFrame, CellDB["tools"]["dispelRequest"][6][1], CellDB["tools"]["dispelRequest"][6][2], drTimeout, function()
                    drUnits[unit] = nil
                end)
            end
        else
            drUnits[unit] = nil
        end
    end
end)

local function DR_UpdateTools(which)
    if not which or which == "dispelRequest" then
        HideAllDRGlows()
        
        drEnabled = CellDB["tools"]["dispelRequest"][1]

        if drEnabled then
            drDispellable = CellDB["tools"]["dispelRequest"][2]
            drType = CellDB["tools"]["dispelRequest"][3]
            drTimeout = CellDB["tools"]["dispelRequest"][4]
            drDebuffs = F:ConvertTable(CellDB["tools"]["dispelRequest"][5])

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