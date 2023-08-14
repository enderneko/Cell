-- /script SetAllowDangerousScripts(true)
local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local I = Cell.iFuncs
local P = Cell.pixelPerfectFuncs

local LCG = LibStub("LibCustomGlow-1.0")
local Comm = LibStub:GetLibrary("AceComm-3.0")

-------------------------------------------------
-- glow
-------------------------------------------------
local function HideGlow(glowFrame)
    LCG.ButtonGlow_Stop(glowFrame)
    LCG.PixelGlow_Stop(glowFrame)
    LCG.AutoCastGlow_Stop(glowFrame)
    LCG.ProcGlow_Stop(glowFrame)
    
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
        LCG.ProcGlow_Stop(glowFrame)
        LCG.ButtonGlow_Start(glowFrame, glowOptions[1])
    elseif glowType == "pixel" then
        LCG.ButtonGlow_Stop(glowFrame)
        LCG.AutoCastGlow_Stop(glowFrame)
        LCG.ProcGlow_Stop(glowFrame)
        -- color, N, frequency, length, thickness, x, y
        LCG.PixelGlow_Start(glowFrame, glowOptions[1], glowOptions[4], glowOptions[5], glowOptions[6], glowOptions[7], glowOptions[2], glowOptions[3])
    elseif glowType == "shine" then
        LCG.ButtonGlow_Stop(glowFrame)
        LCG.PixelGlow_Stop(glowFrame)
        LCG.ProcGlow_Stop(glowFrame)
        -- color, N, frequency, scale, x, y
        LCG.AutoCastGlow_Start(glowFrame, glowOptions[1], glowOptions[4], glowOptions[5], glowOptions[6], glowOptions[2], glowOptions[3])
    elseif glowType == "proc" then
        LCG.ButtonGlow_Stop(glowFrame)
        LCG.PixelGlow_Stop(glowFrame)
        LCG.AutoCastGlow_Stop(glowFrame)
        -- color, duration
        LCG.ProcGlow_Start(glowFrame, {color=glowOptions[1], xOffset=glowOptions[2], yOffset=glowOptions[3], duration=glowOptions[4], startAnim=false})
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
-- icon
-------------------------------------------------
local function HideIcon(icon)
    icon:Hide()

    if icon.timer then
        icon.timer:Cancel()
        icon.timer = nil
    end
end

local function ShowIcon(icon, tex, iconColor, timeout, callback)
    F:Debug("SHOW_ICON:", icon:GetName())
    
    icon:Display(tex, iconColor)

    if icon.timer then
        icon.timer:Cancel()
    end
    icon.timer = C_Timer.NewTimer(timeout, function()
        icon.timer = nil
        HideIcon(icon)
        if callback then
            callback()
        end
    end)
end

-------------------------------------------------
-- text
-------------------------------------------------
local function HideText(text)
    text:Hide()

    if text.timer then
        text.timer:Cancel()
        text.timer = nil
    end
end

local function ShowText(text, timeout, callback)
    F:Debug("SHOW_TEXT:", text:GetName())
    
    text:Display()

    if text.timer then
        text.timer:Cancel()
    end
    text.timer = C_Timer.NewTimer(timeout, function()
        text.timer = nil
        HideText(text)
        if callback then
            callback()
        end
    end)
end

-------------------------------------------------
-- spell request
-------------------------------------------------
local srEnabled, srExists, srKnown, srFreeCD, srReplyCD, srResponseType, srTimeout, srCastMsg
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

local COOLDOWN_TIME = _G.ITEM_COOLDOWN_TIME
local function CheckSRConditions(spellId, unit, sender)
    F:Debug("CheckSRConditions:", spellId, unit, sender)

    if not srSpells[spellId] then return end

    -- can't find unit
    if not unit or not UnitIsVisible(unit) then return end

    -- already has this buff
    if srExists and F:FindAuraById(unit, "BUFF", srSpells[spellId][2]) then return end

    if srKnown then
        if IsSpellKnown(spellId) then
            -- if srDeadMsg and UnitIsDeadOrGhost("player") then
            --     SendChatMessage(srDeadMsg, "WHISPER", nil, sender)
            -- end

            local start, duration, enabled, modRate = GetSpellCooldown(spellId)
            local cdLeft = start + duration - GetTime()

            if srFreeCD then -- NOTE: require free cd
                if start == 0 or duration == 0 then
                    return true
                else
                    local _, gcd = GetSpellCooldown(61304) --! check gcd
                    if duration == gcd then -- spell ready
                        return true
                    else
                        if srReplyCD then -- reply cooldown
                            SendChatMessage(GetSpellLink(spellId).." "..format(COOLDOWN_TIME, F:SecondsToTime(cdLeft)), "WHISPER", nil, sender)
                        end
                        return false
                    end
                end
            else -- NOTE: no require free cd
                if srReplyCD then -- reply cd if cd
                    if start > 0 and duration > 0 then
                        local _, gcd = GetSpellCooldown(61304) --! check gcd
                        if duration ~= gcd then
                            SendChatMessage(GetSpellLink(spellId).." "..format(COOLDOWN_TIME, F:SecondsToTime(cdLeft)), "WHISPER", nil, sender)
                        end
                    end
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

local function ShowSpellRequest(spellId, button)
    if button then
        local unit = button.state.unit

        -- check if has previous request
        if srUnits[unit] then
            -- remove previous request
            requestedSpells[srUnits[unit][1]] = nil
        end
        
        --! save {spellId, buffId, button} for hiding
        srUnits[unit] = {spellId, srSpells[spellId][2], button} 
        requestedSpells[spellId] = unit
        
        if srSpells[spellId][1] == "icon" then
            ShowIcon(button.widget.srIcon, srSpells[spellId][4], srSpells[spellId][5], srTimeout, function()
                srUnits[unit] = nil
                requestedSpells[spellId] = nil
            end)
        else
            ShowGlow(button.widget.srGlowFrame, srSpells[spellId][4][1], srSpells[spellId][4][2], srTimeout, function()
                srUnits[unit] = nil
                requestedSpells[spellId] = nil
            end)
        end

        -- notify
        F:Notify("SPELL_REQ_RECEIVED", unit, spellId, srSpells[spellId][2], srTimeout)
    end
end

--! glow on addon message
Comm:RegisterComm("CELL_REQ_S", function(prefix, message, channel, sender)
    if srEnabled and srResponseType ~= "whisper" then
        local spellId, target = strsplit(":", message)
        spellId = tonumber(spellId)

        if spellId and CheckSRConditions(spellId, Cell.vars.names[sender], sender) then
            local me = GetUnitName("player")
            -- NOTE: to all provider / to me
            if (srResponseType == "all" and (not target or target == me)) or (srResponseType == "me" and target == me) then
                ShowSpellRequest(spellId, F:GetUnitButtonByName(sender))
            end
        end
    end
end)

--! glow on whisper
local COOLDOWN_TIME_TEXT = string.gsub(ITEM_COOLDOWN_TIME, "%%s", "")
-- NOTE: playerName always contains SERVER name!
function SR:CHAT_MSG_WHISPER(text, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName, languageID, lineID, guid, bnSenderID, isMobile, isSubtitle, hideSenderInLetterbox, supressRaidIcons)
    -- NOTE: filter cd reply
    if strfind(text, "^|c.+|H.+|h%[.+%]|h|r "..COOLDOWN_TIME_TEXT..".+") then return end

    for spellId, t in pairs(srSpells) do
        if strfind(strlower(text), strlower(t[3])) then
            if CheckSRConditions(spellId, Cell.vars.guids[guid], playerName) then
                ShowSpellRequest(spellId, F:GetUnitButtonByGUID(guid))
            end
            break
        end
    end
end

--! hide glow when aura changes
if Cell.isRetail then
    function SR:UNIT_AURA(unit, updatedAuras)
        local srUnit = srUnits[unit] -- {spellId, buffId, button}
        if not srUnit then return end
        
        if updatedAuras and updatedAuras.addedAuras then
            for _, aura in pairs(updatedAuras.addedAuras) do
                if srUnit[2] == aura.spellId then
                    F:Debug("SR_HIDE [UNIT_AURA]:", unit, srUnit[1])
                    HideGlow(srUnit[3].widget.srGlowFrame)
                    HideIcon(srUnit[3].widget.srIcon)
                    -- notify
                    F:Notify("SPELL_REQ_APPLIED", unit, srUnit[1], srUnit[2])
                    -- clear
                    srUnits[unit] = nil
                    requestedSpells[srUnit[1]] = nil
                    break
                end
            end
        end
    end
else
    function SR:UNIT_AURA(unit)
        local srUnit = srUnits[unit] -- {spellId, buffId, button}
        if not srUnit then return end
        
        if F:FindAuraById(unit, "BUFF", srUnit[2]) then
            F:Debug("SR_HIDE [UNIT_AURA]:", unit, srUnit[1])
            HideGlow(srUnit[3].widget.srGlowFrame)
            HideIcon(srUnit[3].widget.srIcon)
            -- notify
            F:Notify("SPELL_REQ_APPLIED", unit, srUnit[1], srUnit[2])
            -- clear
            srUnits[unit] = nil
            requestedSpells[srUnit[1]] = nil
        end
    end
end

--! hide glow when player spell cd
function SR:UNIT_SPELLCAST_SUCCEEDED(unit, _, spellId)
    if unit == "player" and requestedSpells[spellId] then
        if not F:FindAuraById(unit, "BUFF", spellId) then return end

        local requester = requestedSpells[spellId]
        F:Debug("SR_HIDE [UNIT_SPELLCAST_SUCCEEDED]:", requester, spellId)
        if srCastMsg then
            SendChatMessage(srCastMsg, "WHISPER", nil, GetUnitName(requester, true))
        end
        
        if srUnits[requester] then
            HideGlow(srUnits[requester][3].widget.srGlowFrame)
            HideIcon(srUnits[requester][3].widget.srIcon)
        end

        -- notify
        F:Notify("SPELL_REQ_CAST", requester, srUnits[requester][1], srUnits[requester][2])
        -- clear
        srUnits[requester] = nil
        requestedSpells[spellId] = nil
    end
end

SR:SetScript("OnEvent", function(self, event, ...)
    self[event](self, ...)
end)

-- CELL_SR_SPELLS = srSpells
-- CELL_SR_UNITS = srUnits
local function SR_UpdateRequests(which)
    F:Debug("|cffBBFFFFUpdateRequests:|r", which)

    if not which or which == "spellRequest" then
        -- NOTE: hide all
        for _, t in pairs(srUnits) do
            HideGlow(t[3].widget.srGlowFrame)
            HideIcon(t[3].widget.srIcon)
        end
        wipe(srUnits)
        wipe(requestedSpells)

        srEnabled = CellDB["spellRequest"]["enabled"]
        
        if srEnabled then
            srExists = CellDB["spellRequest"]["checkIfExists"]
            srKnown = CellDB["spellRequest"]["knownSpellsOnly"]
            srFreeCD = CellDB["spellRequest"]["freeCooldownOnly"]
            srResponseType = CellDB["spellRequest"]["responseType"]
            srReplyCD = CellDB["spellRequest"]["replyCooldown"] and srResponseType ~= "all"
            srTimeout = CellDB["spellRequest"]["timeout"]
            
            if srResponseType ~= "all" then
                srCastMsg = CellDB["spellRequest"]["replyAfterCast"]
            else
                srCastMsg = nil
            end
            
            if srResponseType == "whisper" then
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

    if not which or which == "spellRequest_icon" then
        F:IterateAllUnitButtons(function(b)
            local setting = CellDB["spellRequest"]["sharedIconOptions"]
            b.widget.srIcon:SetAnimationType(setting[1])
            P:Size(b.widget.srIcon, setting[2], setting[2])
            P:ClearPoints(b.widget.srIcon)
            P:Point(b.widget.srIcon, setting[3], b.widget.srGlowFrame, setting[4], setting[5], setting[6])
        end)
    end

    if not which or which == "spellRequest_spells" then
        if srEnabled then
            wipe(srSpells)

            for _, t in pairs(CellDB["spellRequest"]["spells"]) do
                if t["type"] == "icon" then
                    srSpells[t["spellId"]] = {t["type"], t["buffId"], t["keywords"], t["icon"], t["iconColor"]} -- [spellId] = {buffId, keywords, icon, iconColor}
                else
                    srSpells[t["spellId"]] = {t["type"], t["buffId"], t["keywords"], t["glowOptions"]} -- [spellId] = {buffId, keywords, glowOptions}
                end
            end
        end
    end
end
Cell:RegisterCallback("UpdateRequests", "SR_UpdateRequests", SR_UpdateRequests)

-------------------------------------------------
-- dispel request
-------------------------------------------------
local drEnabled, drDispellable, drResponseType, drTimeout, drDebuffs, drDisplayType
local drUnits = {}
local DR = CreateFrame("Frame")

-- hide all
local function HideAllDRGlows()
    -- NOTE: hide all
    for unit in pairs(drUnits) do
        local button = F:GetUnitButtonByUnit(unit)
        if button then
            HideGlow(button.widget.drGlowFrame)
            HideText(button.widget.drText)
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
                    HideText(button.widget.drText)
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

        if drResponseType == "all" then
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
                if drDisplayType == "text" then
                    ShowText(button.widget.drText, drTimeout, function()
                        drUnits[unit] = nil
                    end)
                else
                    ShowGlow(button.widget.drGlowFrame, CellDB["dispelRequest"]["glowOptions"][1], CellDB["dispelRequest"]["glowOptions"][2], drTimeout, function()
                        drUnits[unit] = nil
                    end)
                end
            end
        else
            drUnits[unit] = nil
        end
    end
end)

local function DR_UpdateRequests(which)
    if not which or which == "dispelRequest" then
        HideAllDRGlows()
        
        drEnabled = CellDB["dispelRequest"]["enabled"]

        if drEnabled then
            drDispellable = CellDB["dispelRequest"]["dispellableByMe"]
            drResponseType = CellDB["dispelRequest"]["responseType"]
            drTimeout = CellDB["dispelRequest"]["timeout"]
            drDebuffs = F:ConvertTable(CellDB["dispelRequest"]["debuffs"])
            drDisplayType = CellDB["dispelRequest"]["type"]

            DR:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
            DR:RegisterEvent("ENCOUNTER_START")
            DR:RegisterEvent("ENCOUNTER_END")
        else
            DR:UnregisterAllEvents()
        end
        -- texplore(drUnits)
        -- texplore(drDebuffs)

    end
    
    if not which or which == "dispelRequest_text" then
        F:IterateAllUnitButtons(function(b)
            local setting = CellDB["dispelRequest"]["textOptions"]
            b.widget.drText:SetType(setting[1])
            b.widget.drText:SetColor(setting[2])
            P:Size(b.widget.drText, setting[3] * 2, setting[3])
            P:ClearPoints(b.widget.drText)
            P:Point(b.widget.drText, setting[4], b.widget.srGlowFrame, setting[5], setting[6], setting[7])
        end)
    end
end
Cell:RegisterCallback("UpdateRequests", "DR_UpdateRequests", DR_UpdateRequests)