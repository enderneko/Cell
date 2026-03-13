local _, Cell = ...
local L = Cell.L
---@type CellFuncs
local F = Cell.funcs
---@class CellIndicatorFuncs
local I = Cell.iFuncs
local LCG = LibStub("LibCustomGlow-1.0")

local UnitIsVisible = UnitIsVisible
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitIsUnit = UnitIsUnit
local UnitIsEnemy = UnitIsEnemy
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local issecretvalue = issecretvalue or function() return false end
local C_Spell = C_Spell
local PlayerIsSpellTarget = PlayerIsSpellTarget

local casts = {}
local castsOnUnit, sortedCastsOnUnit = {}, {}
local recheck = {}
local maxIcons, showAllSpells
local displayMode = "Both" -- "Icons", "Border", "Both"
local eventFrame = CreateFrame("Frame")

local function Reset()
    wipe(recheck)
    wipe(casts)
    wipe(castsOnUnit)
    wipe(sortedCastsOnUnit)
end

-------------------------------------------------
-- show / hide
-------------------------------------------------
local function HideCasts(b)
    local ts = b.indicators.targetedSpells
    if displayMode ~= "Border" then
        ts:UpdateSize(0)
    end
    ts:HideGlow()
end

local function ShowCasts(b, showGlow, sortedCasts, num)
    local ts = b.indicators.targetedSpells

    -- Show icons in Icons and Both modes
    if displayMode ~= "Border" then
        num = min(maxIcons, num)
        for i = 1, num do
            local cast = sortedCasts[i]
            ts[i].cooldown:SetReverse(not cast.isChanneling)
            ts[i]:SetCooldown(cast.startTime, cast.endTime-cast.startTime, cast.icon, cast.count)
        end
        ts:UpdateSize(num)
    end

    -- Show glow in Border and Both modes (Icons mode: only on listed spells)
    if displayMode == "Icons" then
        if showGlow then
            ts:ShowGlow(unpack(Cell.vars.targetedSpellsGlow))
        else
            ts:HideGlow()
        end
    else
        -- Border or Both: always show glow when any cast is targeting this unit
        ts:ShowGlow(unpack(Cell.vars.targetedSpellsGlow))
    end
end

-------------------------------------------------
-- update casts for unit
-------------------------------------------------
local function GetCastsOnUnit(targetUnit)
    if castsOnUnit[targetUnit] then
        wipe(castsOnUnit[targetUnit])
        wipe(sortedCastsOnUnit[targetUnit])
    else
        castsOnUnit[targetUnit] = {}
        sortedCastsOnUnit[targetUnit] = {}
    end

    local inListFound
    local castIndex = 0
    for sourceKey, castInfo in pairs(casts) do
        if targetUnit == castInfo["targetUnit"] then
            if castInfo["endTime"] > GetTime() then -- not expired
                -- On Midnight, spellId may be secret — can't use as table key.
                -- Use a numeric index instead to group casts.
                castIndex = castIndex + 1
                local key = castInfo["nonSecretSpellId"] or castIndex
                if not castsOnUnit[targetUnit][key] then
                    castsOnUnit[targetUnit][key] = {["count"] = 0}
                end
                if not castsOnUnit[targetUnit][key]["endTime"] or castsOnUnit[targetUnit][key]["endTime"] > castInfo["endTime"] then --! shorter duration
                    castsOnUnit[targetUnit][key]["startTime"] = castInfo["startTime"]
                    castsOnUnit[targetUnit][key]["endTime"] = castInfo["endTime"]
                    castsOnUnit[targetUnit][key]["icon"] = castInfo["icon"]
                    castsOnUnit[targetUnit][key]["isChanneling"] = castInfo["isChanneling"]
                end
                castsOnUnit[targetUnit][key]["count"] = castsOnUnit[targetUnit][key]["count"] + 1

                if castInfo["inList"] then
                    castsOnUnit[targetUnit][key]["inList"] = true
                    inListFound = true
                end
            else
                casts[sourceKey] = nil
            end
        end
    end

    return castsOnUnit[targetUnit], inListFound
end

local function Comparator(a, b)
    if a.inList ~= b.inList then
        return a.inList
    end
    return a.startTime < b.startTime
end

local function UpdateCastsOnUnit(targetUnit)
    if not targetUnit then return end

    local t, showGlow = GetCastsOnUnit(targetUnit)

    for key, castInfo in pairs(t) do
        tinsert(sortedCastsOnUnit[targetUnit], castInfo)
    end

    local n = #sortedCastsOnUnit[targetUnit]

    if n == 0 then
        F.HandleUnitButton("unit", targetUnit, HideCasts)
    else
        table.sort(sortedCastsOnUnit[targetUnit], Comparator)
        F.HandleUnitButton("unit", targetUnit, ShowCasts, showGlow, sortedCastsOnUnit[targetUnit], n)
    end
end

-------------------------------------------------
-- check if sourceUnit is casting
-------------------------------------------------
local function CheckUnitCast(sourceUnit, isRecheck)
    if not UnitIsEnemy("player", sourceUnit) then return end

    -- Use sourceUnit as tracking key (e.g., "nameplate1", "target").
    -- UnitGUID can be secret on Midnight — sourceUnit strings are always safe.
    local sourceKey = sourceUnit
    local previousTarget, isChanneling

    if casts[sourceKey] then
        previousTarget = casts[sourceKey]["targetUnit"]
        if casts[sourceKey]["endTime"] <= GetTime() then
            --! expired
            casts[sourceKey] = nil
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

    if not spellId then return end

    -- Determine if spellId is secret
    local spellIdIsSecret = issecretvalue(spellId)
    local nonSecretSpellId -- used for grouping and list lookup when available

    if not spellIdIsSecret then
        nonSecretSpellId = spellId
    end

    -- Get icon: C_Spell.GetSpellTexture accepts secret spellId (C-level API)
    if Cell.isMidnight and C_Spell and C_Spell.GetSpellTexture then
        local ok, tex = pcall(C_Spell.GetSpellTexture, spellId)
        if ok and tex then
            texture = tex
        end
    end

    -- Determine if this spell should be tracked
    local inList = false
    local shouldTrack = false

    if nonSecretSpellId then
        -- Non-secret: use normal list lookup
        if Cell.vars.targetedSpellsList[nonSecretSpellId] then
            inList = true
            shouldTrack = true
        elseif showAllSpells then
            shouldTrack = true
        end
    else
        -- Secret spellId: can't look up in list.
        -- Use C_Spell.IsSpellImportant as a proxy for "dangerous/boss spell"
        if C_Spell and C_Spell.IsSpellImportant then
            local ok, important = pcall(C_Spell.IsSpellImportant, spellId)
            if ok and not issecretvalue(important) and important then
                inList = true
                shouldTrack = true
            elseif ok and issecretvalue(important) then
                -- Secret boolean — treat as important (safe assumption for enemy casts)
                inList = true
                shouldTrack = true
            end
        end
        -- In showAllSpells mode, show all enemy casts even if secret
        if showAllSpells then
            shouldTrack = true
        end
    end

    -- In Border or Both mode, track all enemy casts targeting group members
    -- (glow always shows regardless of spell list)
    if not shouldTrack and displayMode ~= "Icons" then
        shouldTrack = true
    end

    if not shouldTrack then return end

    -- Time values may be secret on Midnight — use pcall to safely convert
    local startTime, endTime
    if not issecretvalue(startTimeMS) and not issecretvalue(endTimeMS) then
        startTime = startTimeMS / 1000
        endTime = endTimeMS / 1000
    else
        -- Fallback: use current time + reasonable estimate
        startTime = GetTime()
        endTime = GetTime() + 3
    end

    if casts[sourceKey] then
        casts[sourceKey]["startTime"] = startTime
        casts[sourceKey]["endTime"] = endTime
        casts[sourceKey]["spellId"] = spellId
        casts[sourceKey]["nonSecretSpellId"] = nonSecretSpellId
        casts[sourceKey]["icon"] = texture
        casts[sourceKey]["inList"] = inList
    else
        casts[sourceKey] = {
            ["startTime"] = startTime,
            ["endTime"] = endTime,
            ["spellId"] = spellId,
            ["nonSecretSpellId"] = nonSecretSpellId,
            ["icon"] = texture,
            ["isChanneling"] = isChanneling,
            ["inList"] = inList,
            ["recheck"] = 0,
        }
    end

    -- Find which group member is the target using UnitIsUnit (secret-safe)
    local targetUnit = sourceUnit.."target"
    targetUnit = F.GetTargetUnitID(targetUnit) -- resolves to group unit via UnitIsUnit

    -- update spell target
    casts[sourceKey]["targetUnit"] = targetUnit
    casts[sourceKey]["nonNameplate"] = not strfind(sourceUnit, "^nameplate")

    UpdateCastsOnUnit(targetUnit)

    if not isRecheck then
        if not recheck[sourceKey] or not (strfind(sourceUnit, "target$") or strfind(sourceUnit, "^nameplate")) then
            recheck[sourceKey] = sourceUnit
        end
        eventFrame:Show()
    end

    if previousTarget and previousTarget ~= targetUnit then
        UpdateCastsOnUnit(previousTarget)
    end
end

-------------------------------------------------
-- recheck
-------------------------------------------------
eventFrame:Hide()
eventFrame:SetScript("OnUpdate", function(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed >= 0.1 then
        self.elapsed = 0

        local empty = true

        for sourceKey, unit in pairs(recheck) do
            if casts[sourceKey] then
                casts[sourceKey]["recheck"] = casts[sourceKey]["recheck"] + 1
                if casts[sourceKey]["recheck"] >= 6 then
                    recheck[sourceKey] = nil
                else
                    empty = false
                    local recheckRequired = (not casts[sourceKey]["targetUnit"] and UnitExists(unit.."target")) or (casts[sourceKey]["targetUnit"] and not UnitIsUnit(unit.."target", casts[sourceKey]["targetUnit"]))
                    if recheckRequired then
                        CheckUnitCast(unit, true)
                    end
                end
            else
                recheck[sourceKey] = nil
            end
        end

        if empty then
            eventFrame:Hide()
        end
    end
end)

-------------------------------------------------
-- events
-------------------------------------------------
eventFrame:SetScript("OnEvent", function(_, event, sourceUnit)
    if event == "ENCOUNTER_END" then
        Reset()
        F.IterateAllUnitButtons(HideCasts, true)
        return
    end

    if sourceUnit and strfind(sourceUnit, "^soft") then return end

    if event == "PLAYER_TARGET_CHANGED" then
        CheckUnitCast("target")

    elseif event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_DELAYED" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" or event == "NAME_PLATE_UNIT_ADDED" then
        CheckUnitCast(sourceUnit)

    elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        -- Use sourceUnit as key (secret-safe, unlike UnitGUID)
        local sourceKey = sourceUnit
        if casts[sourceKey] then
            local previousTarget = casts[sourceKey]["targetUnit"]
            casts[sourceKey] = nil
            UpdateCastsOnUnit(previousTarget)
        end

    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        local sourceKey = sourceUnit
        if casts[sourceKey] and not casts[sourceKey]["nonNameplate"] then
            local previousTarget = casts[sourceKey]["targetUnit"]
            casts[sourceKey] = nil
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

local function SetFont(frame, ...)
    for i = 1, #frame do
        I.SetFont(frame[i].stack, frame[i], ...)
    end
end

local function ShowGlowPreview(frame)
    frame:ShowGlow(unpack(Cell.vars.targetedSpellsGlow))
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

local function HideGlow(frame)
    LCG.ButtonGlow_Stop(frame.tsGlowFrame)
    LCG.PixelGlow_Stop(frame.tsGlowFrame)
    LCG.AutoCastGlow_Stop(frame.tsGlowFrame)
    LCG.ProcGlow_Stop(frame.tsGlowFrame)
end

function I.CreateTargetedSpells(parent)
    local targetedSpells = CreateFrame("Frame", parent:GetName().."TargetedSpellsParent", parent.widgets.indicatorFrame)
    parent.indicators.targetedSpells = targetedSpells
    targetedSpells:Hide()

    targetedSpells.tsGlowFrame = parent.widgets.tsGlowFrame
    targetedSpells._SetSize = targetedSpells.SetSize
    targetedSpells.SetSize = I.Cooldowns_SetSize
    targetedSpells.SetBorder = I.Cooldowns_SetBorder
    targetedSpells.UpdateSize = I.Cooldowns_UpdateSize_WithSpacing
    targetedSpells.SetOrientation = I.Cooldowns_SetOrientation_WithSpacing
    targetedSpells.ShowGlow = ShowGlow
    targetedSpells.HideGlow = HideGlow
    targetedSpells.SetFont = SetFont
    targetedSpells.ShowGlowPreview = ShowGlowPreview
    targetedSpells.HideGlowPreview = HideGlow

    for i = 1, 3 do
        local frame = I.CreateAura_BorderIcon(parent:GetName().."TargetedSpells"..i, targetedSpells, 2)
        tinsert(targetedSpells, frame)
        frame.SetCooldown = SetCooldown
        -- frame:SetScript("OnShow", targetedSpells.UpdateSize)
        -- frame:SetScript("OnHide", targetedSpells.UpdateSize)
        frame.cooldown:SetScript("OnCooldownDone", function()
            frame:Hide()
        end)
    end
end

-------------------------------------------------
-- functions
-------------------------------------------------
-- NOTE: in case there's a casting spell, hide!
local function EnterLeaveInstance()
    Reset()
    F.IterateAllUnitButtons(HideCasts, true)
end

function I.EnableTargetedSpells(enabled)
    if enabled then
        F.IterateAllUnitButtons(function(b)
            b.indicators.targetedSpells:Show()
        end, true)

        -- UNIT_SPELLCAST_DELAYED UNIT_SPELLCAST_FAILED UNIT_SPELLCAST_INTERRUPTED UNIT_SPELLCAST_START UNIT_SPELLCAST_STOP
        -- UNIT_SPELLCAST_CHANNEL_START UNIT_SPELLCAST_CHANNEL_STOP
        -- PLAYER_TARGET_CHANGED ENCOUNTER_END

        eventFrame:RegisterEvent("UNIT_SPELLCAST_START")
        eventFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
        eventFrame:RegisterEvent("UNIT_SPELLCAST_DELAYED")
        eventFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
        eventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
        eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
        eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
        eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")

        eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
        eventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        eventFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

        eventFrame:RegisterEvent("ENCOUNTER_END")

        Cell.RegisterCallback("EnterInstance", "TargetedSpells_EnterInstance", EnterLeaveInstance)
        Cell.RegisterCallback("LeaveInstance", "TargetedSpells_LeaveInstance", EnterLeaveInstance)
    else
        Reset()
        eventFrame:Hide()
        eventFrame:UnregisterAllEvents()

        Cell.UnregisterCallback("EnterInstance", "TargetedSpells_EnterInstance")
        Cell.UnregisterCallback("LeaveInstance", "TargetedSpells_LeaveInstance")

        F.IterateAllUnitButtons(function(b)
            HideCasts(b)
            b.indicators.targetedSpells:Hide()
        end, true)
    end
end

function I.ShowAllTargetedSpells(showAll)
    showAllSpells = showAll
end

function I.UpdateTargetedSpellsNum(num)
    maxIcons = num
end

function I.UpdateTargetedSpellsDisplayMode(mode)
    displayMode = mode or "Both"
end
