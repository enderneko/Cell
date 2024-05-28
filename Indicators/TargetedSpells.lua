local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local I = Cell.iFuncs
local LCG = LibStub("LibCustomGlow-1.0")

local UnitIsVisible = UnitIsVisible
local UnitGUID = UnitGUID
local UnitIsUnit = UnitIsUnit
local UnitIsEnemy = UnitIsEnemy
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo

-------------------------------------------------
-- show / hide
-------------------------------------------------
local function HideCasts(b)
    b.indicators.targetedSpells:Hide()
end

local function ShowCasts(b, inListFound, start, duration, icon, isChanneling, num)
    b.indicators.targetedSpells.cooldown:SetReverse(not isChanneling)
    b.indicators.targetedSpells:SetCooldown(start, duration, icon, num)
    -- glow if not 0
    if inListFound then
        b.indicators.targetedSpells:ShowGlow(unpack(Cell.vars.targetedSpellsGlow))
    else
        b.indicators.targetedSpells:ShowGlow()
    end
end

-------------------------------------------------
-- update casts for guid
-------------------------------------------------
local casts, castsOnUnit = {}, {}
local showAllSpells

local function GetCastsOnUnit(guid)
    if castsOnUnit[guid] then
        wipe(castsOnUnit[guid])
    else
        castsOnUnit[guid] = {}
    end

    for sourceGUID, castInfo in pairs(casts) do
        if guid == castInfo["targetGUID"] then
            if castInfo["endTime"] > GetTime() then -- not expired
                tinsert(castsOnUnit[guid], castInfo)
            else
                casts[sourceGUID] = nil
            end
        end
    end

    return castsOnUnit[guid]
end

local function UpdateCastsOnUnit(guid)
    local allCasts = 0
    local startTime, endTime, spellId, icon, isChanneling
    local inListFound

    for _, castInfo in pairs(GetCastsOnUnit(guid)) do
        allCasts = allCasts + 1

        if not endTime then --! init
            startTime, endTime, spellId, icon, isChanneling = castInfo["startTime"], castInfo["endTime"], castInfo["spellId"], castInfo["icon"], castInfo["isChanneling"]
        else
            spellId = castInfo["spellId"]
            if Cell.vars.targetedSpellsList[spellId] then --! [IN LIST]
                if not inListFound or endTime > castInfo["endTime"] then --! NOT FOUND BEFORE or SHORTER DURATION
                    startTime, endTime, icon, isChanneling = castInfo["startTime"], castInfo["endTime"], castInfo["icon"], castInfo["isChanneling"]
                end
            elseif not inListFound and endTime > castInfo["endTime"] then --! [NOT IN LIST] NOT FOUND BEFORE and SHORTER DURATION
                startTime, endTime, icon, isChanneling = castInfo["startTime"], castInfo["endTime"], castInfo["icon"], castInfo["isChanneling"]
            end
        end

        if Cell.vars.targetedSpellsList[spellId] then
            inListFound = true
        end
    end

    if allCasts == 0 then
        F:HandleUnitButton("guid", guid, HideCasts)
    else
        F:HandleUnitButton("guid", guid, ShowCasts, inListFound, startTime, endTime-startTime, icon, isChanneling, allCasts)
    end
end

-------------------------------------------------
-- check if sourceUnit is casting
-------------------------------------------------
local function CheckUnitCast(sourceUnit)
    if not UnitIsEnemy(sourceUnit, "player") then return end

    local sourceGUID = UnitGUID(sourceUnit)
    local targetGUID
    local previousTarget, isChanneling

    if casts[sourceGUID] then
        previousTarget = casts[sourceGUID]["targetGUID"]
        if casts[sourceGUID]["endTime"] <= GetTime() then
            --! expired
            casts[sourceGUID] = nil
            UpdateCastsOnUnit(previousTarget)
            previousTarget = nil
        end
    end

    -- name, text, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible, spellId
    local name, _, texture, startTimeMS, endTimeMS, _, _, notInterruptible, spellId = UnitCastingInfo(sourceUnit)
    if not name then
        -- name, text, texture, startTimeMS, endTimeMS, isTradeSkill, notInterruptible, spellId
        name, _, texture, startTimeMS, endTimeMS, _, notInterruptible, spellId = UnitChannelInfo(sourceUnit)
        isChanneling = true
    end

    -- print(sourceUnit, name, spellId)

    if spellId and (Cell.vars.targetedSpellsList[spellId] or showAllSpells) then
        local targetUnit = sourceUnit.."target"
        targetUnit = F:GetTargetUnitID(targetUnit) -- units in group (players/pets), no npcs
        if targetUnit then
            targetGUID = UnitGUID(targetUnit)
            casts[sourceGUID] = {
                ["startTime"] = startTimeMS/1000,
                ["endTime"] = endTimeMS/1000,
                ["spellId"] = spellId,
                ["icon"] = texture,
                ["targetGUID"] = targetGUID,
                ["isChanneling"] = isChanneling,
                -- ["sourceUnit"] = sourceUnit,
                -- ["targetUnit"] = targetUnit,
            }
            UpdateCastsOnUnit(targetGUID)
        end
    end

    if previousTarget and previousTarget ~= targetGUID then
        UpdateCastsOnUnit(previousTarget)
    end
end

-------------------------------------------------
-- events
-------------------------------------------------
local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(_, event, sourceUnit)
    if event == "ENCOUNTER_END" then
        wipe(casts)
        wipe(castsOnUnit)
        F:IterateAllUnitButtons(function(b)
            b.indicators.targetedSpells:Hide()
        end, true)
        return
    end

    if sourceUnit == "softenemy" then return end

    if event == "PLAYER_TARGET_CHANGED" then
        CheckUnitCast("target")

    elseif event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_DELAYED"  or event == "UNIT_SPELLCAST_CHANNEL_START" or event == "NAME_PLATE_UNIT_ADDED" then
        CheckUnitCast(sourceUnit)

    elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_FAILED_QUIET" or event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "NAME_PLATE_UNIT_REMOVED" then
        local sourceGUID = UnitGUID(sourceUnit)
        if casts[sourceGUID] then
            previousTarget = casts[sourceGUID]["targetGUID"]
            casts[sourceGUID] = nil
            UpdateCastsOnUnit(previousTarget)
        end
    end
end)

-------------------------------------------------
-- create
-------------------------------------------------
local function SetCooldown(frame, start, duration, icon, count)
    frame.duration:Hide()

    if count ~= 1 then
        frame.stack:Show()
        frame.stack:SetText(count)
    else
        frame.stack:Hide()
    end

    frame.border:Show()
    frame.cooldown:Show()
    frame.cooldown:SetSwipeColor(unpack(Cell.vars.targetedSpellsGlow[2]))
    frame.cooldown:SetCooldown(start, duration)
    frame.icon:SetTexture(icon)
    frame:Show()
end

local function SetFont(frame, font, size, outline, shadow, anchor, xOffset, yOffset, color)
    I.SetFont(frame.stack, frame, font, size, outline, shadow, anchor, xOffset, yOffset, color)
end

local function ShowGlowPreview(frame)
    frame:ShowGlow(unpack(Cell.vars.targetedSpellsGlow))
end

local function HideGlowPreview(frame)
    LCG.ButtonGlow_Stop(frame.tsGlowFrame)
    LCG.PixelGlow_Stop(frame.tsGlowFrame)
    LCG.AutoCastGlow_Stop(frame.tsGlowFrame)
    LCG.ProcGlow_Stop(frame.tsGlowFrame)
end

local function ShowGlow(frame, glowType, color, arg1, arg2, arg3, arg4)
    if glowType == "Normal" then
        LCG.PixelGlow_Stop(frame.tsGlowFrame)
        LCG.AutoCastGlow_Stop(frame.tsGlowFrame)
        LCG.ProcGlow_Stop(frame.tsGlowFrame)
        LCG.ButtonGlow_Start(frame.tsGlowFrame, color)
    elseif glowType == "Pixel" then
        LCG.ButtonGlow_Stop(frame.tsGlowFrame)
        LCG.AutoCastGlow_Stop(frame.tsGlowFrame)
        LCG.ProcGlow_Stop(frame.tsGlowFrame)
        -- color, N, frequency, length, thickness
        LCG.PixelGlow_Start(frame.tsGlowFrame, color, arg1, arg2, arg3, arg4)
    elseif glowType == "Shine" then
        LCG.ButtonGlow_Stop(frame.tsGlowFrame)
        LCG.PixelGlow_Stop(frame.tsGlowFrame)
        LCG.ProcGlow_Stop(frame.tsGlowFrame)
        -- color, N, frequency, scale
        LCG.AutoCastGlow_Start(frame.tsGlowFrame, color, arg1, arg2, arg3)
    elseif glowType == "Proc" then
        LCG.ButtonGlow_Stop(frame.tsGlowFrame)
        LCG.PixelGlow_Stop(frame.tsGlowFrame)
        LCG.AutoCastGlow_Stop(frame.tsGlowFrame)
        -- color, duration
        LCG.ProcGlow_Start(frame.tsGlowFrame, {color=color, duration=arg1, startAnim=false})
    else
        LCG.ButtonGlow_Stop(frame.tsGlowFrame)
        LCG.PixelGlow_Stop(frame.tsGlowFrame)
        LCG.AutoCastGlow_Stop(frame.tsGlowFrame)
        LCG.ProcGlow_Stop(frame.tsGlowFrame)
    end
end

function I.CreateTargetedSpells(parent)
    local frame = I.CreateAura_BorderIcon(parent:GetName().."TargetedSpells", parent.widgets.overlayFrame, 2)
    parent.indicators.targetedSpells = frame
    frame:Hide()

    frame.tsGlowFrame = parent.widgets.tsGlowFrame
    frame.ShowGlow = ShowGlow
    frame.SetCooldown = SetCooldown
    frame.SetFont = SetFont
    frame.ShowGlowPreview = ShowGlowPreview
    frame.HideGlowPreview = HideGlowPreview

    frame.cooldown:SetScript("OnCooldownDone", function()
        frame:Hide()
    end)

    frame:SetScript("OnHide", function()
        LCG.ButtonGlow_Stop(parent.widgets.tsGlowFrame)
        LCG.PixelGlow_Stop(parent.widgets.tsGlowFrame)
        LCG.AutoCastGlow_Stop(parent.widgets.tsGlowFrame)
        LCG.ProcGlow_Stop(parent.widgets.tsGlowFrame)
    end)
end

-------------------------------------------------
-- functions
-------------------------------------------------
-- NOTE: in case there's a casting spell, hide!
local function EnterLeaveInstance()
    F:IterateAllUnitButtons(function(b)
        b.indicators.targetedSpells:Hide()
    end)
end

function I.EnableTargetedSpells(enabled)
    if enabled then
        -- UNIT_SPELLCAST_DELAYED UNIT_SPELLCAST_FAILED UNIT_SPELLCAST_FAILED_QUIET UNIT_SPELLCAST_INTERRUPTED UNIT_SPELLCAST_START UNIT_SPELLCAST_STOP
        -- UNIT_SPELLCAST_CHANNEL_START UNIT_SPELLCAST_CHANNEL_STOP
        -- PLAYER_TARGET_CHANGED ENCOUNTER_END

        eventFrame:RegisterEvent("UNIT_SPELLCAST_START")
        eventFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
        eventFrame:RegisterEvent("UNIT_SPELLCAST_DELAYED")
        eventFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
        eventFrame:RegisterEvent("UNIT_SPELLCAST_FAILED_QUIET")
        eventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
        eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
        eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
        -- eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")

        eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
        eventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        eventFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

        eventFrame:RegisterEvent("ENCOUNTER_END")

        Cell:RegisterCallback("EnterInstance", "TargetedSpells_EnterInstance", EnterLeaveInstance)
        Cell:RegisterCallback("LeaveInstance", "TargetedSpells_LeaveInstance", EnterLeaveInstance)
    else
        eventFrame:UnregisterAllEvents()

        Cell:UnregisterCallback("EnterInstance", "TargetedSpells_EnterInstance")
        Cell:UnregisterCallback("LeaveInstance", "TargetedSpells_LeaveInstance")

        F:IterateAllUnitButtons(function(b)
            b.indicators.targetedSpells:Hide()
        end)
    end
end

function I.ShowAllTargetedSpells(showAll)
    showAllSpells = showAll
end