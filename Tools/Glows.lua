local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

local LCG = LibStub("LibCustomGlow-1.0")
local Comm = LibStub:GetLibrary("AceComm-3.0")

local function HideGlow(glowFrame)
    LCG.ButtonGlow_Stop(glowFrame)
    LCG.PixelGlow_Stop(glowFrame)
    LCG.AutoCastGlow_Stop(glowFrame)
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
        HideGlow(glowFrame)
        glowFrame.timer = nil
    end)
end

-------------------------------------------------
-- power infusion request
-------------------------------------------------
local PIR_SPELL_ID = 10060
local pirEnabled, pirPriest, pirFreeCD, pirType, pirTimeout, pirKeyword
local requestUnits = {}
local PIR = CreateFrame("Frame")

local function CheckPIConditions()
    return (not pirPriest) or ((pirFreeCD and IsSpellKnown(PIR_SPELL_ID) and GetSpellCooldown(PIR_SPELL_ID) == 0) or (not pirFreeCD))
end

local function ShowPIGlow(button)
    if button then
        if not F:FindAuraById(button.state.unit, "BUFF", PIR_SPELL_ID) then
            requestUnits[button.state.unit] = button -- save for hiding
            ShowGlow(button.widget.pirGlowFrame, CellDB["tools"]["PIRequest"][7][1], CellDB["tools"]["PIRequest"][7][2], pirTimeout)
        end
    end
end

-- glow on addon message
Comm:RegisterComm("CELL_REQ_PI", function(prefix, message, channel, sender)
    if pirEnabled then
        if pirType == "all" or (pirType == "me" and message == GetUnitName("player")) then
            if (pirFreeCD and GetSpellCooldown(PIR_SPELL_ID) == 0) or not pirFreeCD then
                ShowPIGlow(F:GetUnitButtonByName(sender))
            end
        end
    end
end)

-- glow on whisper
function PIR:CHAT_MSG_WHISPER(text, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName, languageID, lineID, guid, bnSenderID, isMobile, isSubtitle, hideSenderInLetterbox, supressRaidIcons)
    if strfind(strlower(text), strlower(pirKeyword)) then
        if (pirFreeCD and GetSpellCooldown(PIR_SPELL_ID) == 0) or not pirFreeCD then
            ShowPIGlow(F:GetUnitButtonByGUID(guid))
        end
    end
end

-- hide glow when PI changes
function PIR:UNIT_AURA(unit, isFullUpdate, updatedAuras)
    if type(updatedAuras) == "table" then
        for _, aura in pairs(updatedAuras) do
            if aura.spellId == PIR_SPELL_ID and requestUnits[unit] then
                HideGlow(requestUnits[unit].widget.pirGlowFrame)
                requestUnits[unit] = nil
            end
        end
    end
end

PIR:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)

local function PI_UpdateTools(which)
    if not which or which == "pirequest" then
        wipe(requestUnits)
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
Cell:RegisterCallback("UpdateTools", "PI_UpdateTools", PI_UpdateTools)

-------------------------------------------------
-- dispel request
-------------------------------------------------