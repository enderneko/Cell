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
    F:Debug("SHOW_GLOW:", glowFrame:GetName())
    
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
local srEnabled, srExists, srKnown, srFreeCD, srReplyCD, srType, srTimeout
local srSpells = {
    -- [spellId] = {buffId, keywords, glowOptions}
}
local srUnits = {
    -- [unit] = {spellId, buffId, glowFrame}
}
local requestedSpells = {
    -- [spellId] = unit
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
        local unit = button.state.unit
        if (not srExists or not F:FindAuraById(unit, "BUFF", srSpells[spellId][1])) and UnitIsVisible(unit) then
            -- check if has previous request
            if srUnits[unit] then
                -- remove previous request
                requestedSpells[srUnits[unit][1]] = nil
            end
            
            --! save {spellId, buffId, button} for hiding
            srUnits[unit] = {spellId, srSpells[spellId][1], button.widget.srGlowFrame} 
            requestedSpells[spellId] = unit
            
            ShowGlow(button.widget.srGlowFrame, srSpells[spellId][3][1], srSpells[spellId][3][2], srTimeout, function()
                srUnits[unit] = nil
                requestedSpells[spellId] = nil
            end)
        end
    end
end

--! glow on addon message
Comm:RegisterComm("CELL_REQ_S", function(prefix, message, channel, sender)
    if srEnabled and srType ~= "whisper" then
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

--! glow on whisper
function SR:CHAT_MSG_WHISPER(text, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName, languageID, lineID, guid, bnSenderID, isMobile, isSubtitle, hideSenderInLetterbox, supressRaidIcons)
    -- NOTE: cd reply
    if strmatch(text, "c.+|H.+|h%[.+%]|h|r.+%d+:%d+") then return end

    for spellId, t in pairs(srSpells) do
        if strfind(strlower(text), strlower(t[2])) then
            if CheckSRConditions(spellId, playerName) then
                ShowSRGlow(spellId, F:GetUnitButtonByGUID(guid))
                break
            end
        end
    end
end

--! hide glow when aura changes
function SR:UNIT_AURA(unit, isFullUpdate, updatedAuras)
    local srUnit = srUnits[unit] -- {spellId, buffId, button}
    if not srUnit then return end
    F:Debug("HIDE_GLOW [UNIT_AURA]:", unit, srUnit[1])

    if type(updatedAuras) == "table" then
        for _, aura in pairs(updatedAuras) do
            if srUnit[2] == aura.spellId then
                HideGlow(srUnit[3])
                srUnits[unit] = nil
                requestedSpells[srUnit[1]] = nil
                break
            end
        end
    end
end

--! hide glow when player spell cd
function SR:UNIT_SPELLCAST_SUCCEEDED(unit, _, spellId)
    if unit == "player" and requestedSpells[spellId] then
        local requester = requestedSpells[spellId]
        F:Debug("HIDE_GLOW [UNIT_SPELLCAST_SUCCEEDED]:", requester, spellId)
        
        if srUnits[requester] then
            HideGlow(srUnits[requester][3])
        end
        srUnits[requester] = nil
        requestedSpells[spellId] = nil
    end
end

SR:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)

-- CELL_SR_SPELLS = srSpells
-- CELL_SR_UNITS = srUnits
local function SR_UpdateGlows(which)
    F:Debug("|cffBBFFFFUpdateGlows:|r", which)

    if not which or which == "spellRequest" then
        -- NOTE: hide all
        for _, t in pairs(srUnits) do
            HideGlow(t[3])
        end
        wipe(srUnits)
        wipe(srSpells)
        wipe(requestedSpells)

        srEnabled = CellDB["glows"]["spellRequest"][1]
        
        if srEnabled then
            srExists = CellDB["glows"]["spellRequest"][2]
            srKnown = CellDB["glows"]["spellRequest"][3]
            srFreeCD = CellDB["glows"]["spellRequest"][4]
            srReplyCD = CellDB["glows"]["spellRequest"][5]
            srType = CellDB["glows"]["spellRequest"][6]
            srTimeout = CellDB["glows"]["spellRequest"][7]
            for _, t in pairs(CellDB["glows"]["spellRequest"][8]) do
                srSpells[t[1]] = {t[2], t[3], t[4]} -- [spellId] = {buffId, keywords, glowOptions}
            end

            if srType == "whisper" then
                SR:RegisterEvent("CHAT_MSG_WHISPER")
            else
                SR:UnregisterEvent("CHAT_MSG_WHISPER")
            end

            SR:RegisterEvent("UNIT_AURA")
            SR:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
        else
            SR:UnregisterAllEvents()
        end
        -- texplore(requestedSpells)
    end
end
Cell:RegisterCallback("UpdateGlows", "SR_UpdateGlows", SR_UpdateGlows)

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
                ShowGlow(button.widget.drGlowFrame, CellDB["glows"]["dispelRequest"][6][1], CellDB["glows"]["dispelRequest"][6][2], drTimeout, function()
                    drUnits[unit] = nil
                end)
            end
        else
            drUnits[unit] = nil
        end
    end
end)

local function DR_UpdateGlows(which)
    if not which or which == "dispelRequest" then
        HideAllDRGlows()
        
        drEnabled = CellDB["glows"]["dispelRequest"][1]

        if drEnabled then
            drDispellable = CellDB["glows"]["dispelRequest"][2]
            drType = CellDB["glows"]["dispelRequest"][3]
            drTimeout = CellDB["glows"]["dispelRequest"][4]
            drDebuffs = F:ConvertTable(CellDB["glows"]["dispelRequest"][5])

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
Cell:RegisterCallback("UpdateGlows", "DR_UpdateGlows", DR_UpdateGlows)