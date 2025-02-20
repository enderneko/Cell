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
    F.Debug("|cffa2d2ffSHOW_GLOW:|r", glowFrame:GetName())

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
    F.Debug("|cffa2d2ffSHOW_ICON:|r", icon:GetName())

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
    F.Debug("|cffa2d2ffSHOW_TEXT:|r", text:GetName())

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
    -- [spellId] = {type, buffId, keywords, glowOptions} / {type, buffId, keywords, icon, iconColor}
}
local srUnits = {
    -- [unit] = buffId
}

local SR = CreateFrame("Frame")
local COOLDOWN_TIME = _G.ITEM_COOLDOWN_TIME

local GetSpellCooldown = C_Spell.GetSpellCooldown or GetSpellCooldown
local GetCooldown
if C_Spell.GetSpellCooldown then
    GetCooldown = function(spellId)
        local info = GetSpellCooldown(spellId)
        if info then
            return info.startTime, info.duration
        end
    end
else
    GetCooldown = function(spellId)
        return GetSpellCooldown(spellId)
    end
end

local GetSpellLink = C_Spell.GetSpellLink or GetSpellLink

local function CheckSRConditions(spellId, unit, sender)
    F.Debug("|cffcdb4dbCheckSRConditions:|r", spellId, unit, sender)

    if not srSpells[spellId] then return end

    -- can't find unit
    if not unit or not UnitIsVisible(unit) then return end

    -- already has this buff
    if srExists and F.FindAuraById(unit, "BUFF", srSpells[spellId][2]) then return end

    if srKnown then
        if IsSpellKnown(spellId) then
            -- if srDeadMsg and UnitIsDeadOrGhost("player") then
            --     SendChatMessage(srDeadMsg, "WHISPER", nil, sender)
            -- end

            local start, duration = GetCooldown(spellId)
            local cdLeft = start + duration - GetTime()

            if srFreeCD then -- NOTE: require free cd
                if start == 0 or duration == 0 then
                    return true
                else
                    local _, gcd = GetCooldown(61304) --! check gcd
                    if duration == gcd then -- spell ready
                        return true
                    else
                        if srReplyCD then -- reply cooldown
                            SendChatMessage(GetSpellLink(spellId).." "..format(COOLDOWN_TIME, F.SecondsToTime(cdLeft)), "WHISPER", nil, sender)
                        end
                        return false
                    end
                end
            else -- NOTE: no require free cd
                if srReplyCD then -- reply cd if cd
                    if start > 0 and duration > 0 then
                        local _, gcd = GetCooldown(61304) --! check gcd
                        if duration ~= gcd then
                            SendChatMessage(GetSpellLink(spellId).." "..format(COOLDOWN_TIME, F.SecondsToTime(cdLeft)), "WHISPER", nil, sender)
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

local function ShowSpellRequest(button, spellId)
    if button then
        local unit = button.states.unit

        --! save requesterUnit and buffId
        srUnits[unit] = srSpells[spellId][2]

        if srSpells[spellId][1] == "icon" then
            ShowIcon(button.widgets.srIcon, srSpells[spellId][4], srSpells[spellId][5], srTimeout, function()
                srUnits[unit] = nil
            end)
        else
            ShowGlow(button.widgets.srGlowFrame, srSpells[spellId][4][1], srSpells[spellId][4][2], srTimeout, function()
                srUnits[unit] = nil
            end)
        end
    end
end

local function HideSpellRequest(button)
    HideGlow(button.widgets.srGlowFrame)
    HideIcon(button.widgets.srIcon)
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
                F.HandleUnitButton("name", sender, ShowSpellRequest, spellId)
                -- notify WA
                F.Notify("SPELL_REQ_RECEIVED", Cell.vars.names[sender], srSpells[spellId][2], srTimeout)
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
                F.HandleUnitButton("guid", guid, ShowSpellRequest, spellId)
                -- notify WA
                F.Notify("SPELL_REQ_RECEIVED", Cell.vars.guids[guid], t[2], srTimeout)
            end
            break
        end
    end
end

--! hide on applied
function SR:COMBAT_LOG_EVENT_UNFILTERED(_, event, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, buffId)
    if event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH" then
        local unit = Cell.vars.guids[destGUID]
        if unit and srUnits[unit] == buffId then
            -- hide
            F.HandleUnitButton("unit", unit, HideSpellRequest)
            -- notify APPLIED
            F.Notify("SPELL_REQ_APPLIED", unit, buffId, 0, Cell.vars.guids[sourceGUID])
            F.Debug("|cffdda15eSR_HIDE [|cffbc6c25CLEU:"..event.."|r]:|r", unit, buffId, Cell.vars.guids[sourceGUID])
            -- cast msg (if castByMe)
            if sourceGUID == Cell.vars.playerGUID and srCastMsg then
                SendChatMessage(srCastMsg, "WHISPER", nil, GetUnitName(unit, true))
            end
            -- clear
            srUnits[unit] = nil
        end
    end
end

SR:SetScript("OnEvent", function(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        self:COMBAT_LOG_EVENT_UNFILTERED(CombatLogGetCurrentEventInfo())
    else
        self[event](self, ...)
    end
end)

local function SR_UpdateRequests(which)
    F.Debug("|cffBBFFFFUpdateRequests:|r", which)

    if not which or which == "spellRequest" then
        -- NOTE: hide all
        for unit in pairs(srUnits) do
            F.HandleUnitButton("unit", unit, HideSpellRequest)
        end
        wipe(srUnits)
        -- texplore(srUnits)

        srEnabled = CellDB["spellRequest"]["enabled"]

        if srEnabled then
            srExists = CellDB["spellRequest"]["checkIfExists"]
            srKnown = CellDB["spellRequest"]["knownSpellsOnly"]
            srFreeCD = CellDB["spellRequest"]["freeCooldownOnly"]
            srResponseType = CellDB["spellRequest"]["responseType"]
            srReplyCD = CellDB["spellRequest"]["replyCooldown"] and srResponseType ~= "all"
            srTimeout = CellDB["spellRequest"]["timeout"]
            srCastMsg = CellDB["spellRequest"]["replyAfterCast"]

            if srResponseType == "whisper" then
                SR:RegisterEvent("CHAT_MSG_WHISPER")
            else
                SR:UnregisterEvent("CHAT_MSG_WHISPER")
            end

            SR:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        else
            SR:UnregisterAllEvents()
        end
    end

    if not which or which == "spellRequest_icon" then
        F.IterateAllUnitButtons(function(b)
            local setting = CellDB["spellRequest"]["sharedIconOptions"]
            b.widgets.srIcon:SetAnimationType(setting[1])
            P.Size(b.widgets.srIcon, setting[2], setting[2])
            P.ClearPoints(b.widgets.srIcon)
            P.Point(b.widgets.srIcon, setting[3], b.widgets.srGlowFrame, setting[4], setting[5], setting[6])
        end)
    end

    if not which or which == "spellRequest_spells" then
        wipe(srSpells)
        if srEnabled then
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
Cell.RegisterCallback("UpdateRequests", "SR_UpdateRequests", SR_UpdateRequests)

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
        F.HandleUnitButton("guid", destGUID, function(b)
            HideGlow(b.widgets.drGlowFrame)
            HideText(b.widgets.drText)
        end)
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
                F.HandleUnitButton("guid", destGUID, function(b)
                    HideGlow(b.widgets.drGlowFrame)
                    HideText(b.widgets.drText)
                end)
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
            drUnits[unit] = F.FindAuraByDebuffTypes(unit, "all")
        else -- specific debuff
            -- NOTE: get specific dispellable debuffs on unit
            drUnits[unit] = F.FindDebuffByIds(unit, drDebuffs)
        end

        -- NOTE: filter dispellable by me
        if drDispellable then
            for spellId, debuffType in pairs(drUnits[unit]) do
                if not I.CanDispel(debuffType) then
                    drUnits[unit][spellId] = nil
                end
            end
        end

        if F.Getn(drUnits[unit]) ~= 0 then -- found
            F.HandleUnitButton("name", sender, function(b)
                if drDisplayType == "text" then
                    ShowText(b.widgets.drText, drTimeout, function()
                        drUnits[unit] = nil
                    end)
                else
                    ShowGlow(b.widgets.drGlowFrame, CellDB["dispelRequest"]["glowOptions"][1], CellDB["dispelRequest"]["glowOptions"][2], drTimeout, function()
                        drUnits[unit] = nil
                    end)
                end
            end)
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
            drDebuffs = F.ConvertTable(CellDB["dispelRequest"]["debuffs"])
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
        F.IterateAllUnitButtons(function(b)
            local setting = CellDB["dispelRequest"]["textOptions"]
            b.widgets.drText:SetType(setting[1])
            b.widgets.drText:SetColor(setting[2])
            P.Size(b.widgets.drText, setting[3] * 2, setting[3])
            P.ClearPoints(b.widgets.drText)
            P.Point(b.widgets.drText, setting[4], b.widgets.srGlowFrame, setting[5], setting[6], setting[7])
        end)
    end
end
Cell.RegisterCallback("UpdateRequests", "DR_UpdateRequests", DR_UpdateRequests)