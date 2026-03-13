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

local casts = {}
local castsOnUnit, sortedCastsOnUnit = {}, {}
local recheck = {}
local maxIcons, showAllSpells
local displayMode = "Both" -- "Icons", "Border", "Both"
local useSecretPath = false -- set true when UnitIsUnit returns secrets
local eventFrame = CreateFrame("Frame")

-- Secret-safe UnitIsUnit — returns false when result is secret
local function SafeUnitIsUnit(a, b)
    local ok, result = pcall(UnitIsUnit, a, b)
    if not ok then return false end
    if issecretvalue(result) then return false end
    return result
end

-- Try to resolve target unit ID (non-secret path)
local function GetTargetUnitID_Safe(target, sourceUnit)
    local resolved

    if SafeUnitIsUnit(target, "player") then return "player", false end
    if SafeUnitIsUnit(target, "pet") then return "pet", false end

    for unit in F.IterateGroupMembers() do
        if SafeUnitIsUnit(target, unit) then return unit, false end
    end

    for unit in F.IterateGroupPets() do
        if SafeUnitIsUnit(target, unit) then return unit, false end
    end

    -- Check if UnitIsUnit is returning secrets (not just nil/no target)
    if Cell.isMidnight and UnitExists(target) then
        local ok, result = pcall(UnitIsUnit, target, "player")
        if ok and issecretvalue(result) then
            return nil, true -- target exists but results are secret
        end
    end

    return nil, false
end

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
    -- Reset glow frame alpha in case SetShown was used
    if ts.tsGlowFrame then
        ts.tsGlowFrame:SetAlpha(1)
        ts.tsGlowFrame:Show()
    end
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

    -- Show glow in Border and Both modes only
    if displayMode ~= "Icons" then
        ts:ShowGlow(unpack(Cell.vars.targetedSpellsGlow))
    else
        ts:HideGlow()
    end
end

-------------------------------------------------
-- Midnight secret-value display path
-- Uses SetShown() with secret booleans from UnitIsUnit
-- so the C-level API handles visibility without Lua boolean tests
-------------------------------------------------
local allActiveCasts = {}

local function GetAllActiveCasts()
    wipe(allActiveCasts)
    local now = GetTime()
    for sourceKey, castInfo in pairs(casts) do
        if castInfo["endTime"] > now then
            tinsert(allActiveCasts, castInfo)
        else
            casts[sourceKey] = nil
        end
    end
    return allActiveCasts
end

local function ShowCastsSecret(b, activeCasts, numCasts)
    local ts = b.indicators.targetedSpells
    local unit = b.states.displayedUnit or b.states.unit
    if not unit then return end

    -- Icons: set up each icon slot, let SetShown control per-cast visibility
    if displayMode ~= "Border" then
        local num = min(maxIcons, numCasts)
        for i = 1, num do
            local cast = activeCasts[i]
            ts[i].cooldown:SetReverse(not cast.isChanneling)
            -- Set cooldown data (always — SetShown will hide if not targeted)
            ts[i].duration:Hide()
            if cast.count and cast.count ~= 1 then
                ts[i].stack:Show()
                ts[i].stack:SetText(cast.count)
            else
                ts[i].stack:Hide()
            end
            ts[i].border:Show()
            ts[i].cooldown:Show()
            ts[i].cooldown:SetSwipeColor(unpack(Cell.vars.targetedSpellsGlow[2]))
            ts[i].cooldown:SetCooldown(cast.startTime, cast.endTime - cast.startTime)
            ts[i].icon:SetTexture(cast.icon)
            -- C-level SetShown with secret boolean — only shows on the correct target's frame
            ts[i]:SetShown(UnitIsUnit(cast.sourceUnit .. "target", unit))
        end
        -- Hide unused slots
        for i = numCasts + 1, #ts do
            ts[i]:Hide()
        end
        ts:UpdateSize(num)
    end

    -- Glow: start the glow effect, use SetShown on tsGlowFrame with the first cast's result
    if displayMode ~= "Icons" and numCasts > 0 then
        ts:ShowGlow(unpack(Cell.vars.targetedSpellsGlow))
        -- Use the first/most important cast to control glow visibility via C-level API
        ts.tsGlowFrame:SetShown(UnitIsUnit(activeCasts[1].sourceUnit .. "target", unit))
    else
        ts:HideGlow()
    end
end

local function UpdateAllButtonsCasts()
    local activeCasts = GetAllActiveCasts()
    local numCasts = #activeCasts

    if numCasts == 0 then
        F.IterateAllUnitButtons(HideCasts, true)
        return
    end

    F.IterateAllUnitButtons(function(b)
        ShowCastsSecret(b, activeCasts, numCasts)
    end, true)
end

-------------------------------------------------
-- update casts for unit (non-secret path)
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
            if useSecretPath then
                UpdateAllButtonsCasts()
            else
                UpdateCastsOnUnit(previousTarget)
            end
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
        casts[sourceKey]["sourceUnit"] = sourceUnit
    else
        casts[sourceKey] = {
            ["startTime"] = startTime,
            ["endTime"] = endTime,
            ["spellId"] = spellId,
            ["nonSecretSpellId"] = nonSecretSpellId,
            ["icon"] = texture,
            ["isChanneling"] = isChanneling,
            ["inList"] = inList,
            ["sourceUnit"] = sourceUnit,
            ["recheck"] = 0,
        }
    end

    -- Resolve target
    local targetUnit, isSecret = GetTargetUnitID_Safe(sourceUnit.."target", sourceUnit)

    if isSecret then
        -- UnitIsUnit returns secrets — use broadcast path with SetShown
        useSecretPath = true
        casts[sourceKey]["targetUnit"] = nil
        casts[sourceKey]["nonNameplate"] = not strfind(sourceUnit, "^nameplate")
        UpdateAllButtonsCasts()
    else
        -- Normal path — resolved target
        casts[sourceKey]["targetUnit"] = targetUnit
        casts[sourceKey]["nonNameplate"] = not strfind(sourceUnit, "^nameplate")
        UpdateCastsOnUnit(targetUnit)
    end

    if not isRecheck then
        if not recheck[sourceKey] or not (strfind(sourceUnit, "target$") or strfind(sourceUnit, "^nameplate")) then
            recheck[sourceKey] = sourceUnit
        end
        eventFrame:Show()
    end

    if not useSecretPath and previousTarget and previousTarget ~= targetUnit then
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
                    if useSecretPath then
                        -- On secret path, just recheck cast and broadcast
                        CheckUnitCast(unit, true)
                    else
                        local recheckRequired
                        if not casts[sourceKey]["targetUnit"] then
                            recheckRequired = UnitExists(unit.."target")
                        else
                            recheckRequired = not SafeUnitIsUnit(unit.."target", casts[sourceKey]["targetUnit"])
                        end
                        if recheckRequired then
                            CheckUnitCast(unit, true)
                        end
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
    if event == "ENCOUNTER_END" or event == "PLAYER_REGEN_ENABLED" then
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
            if useSecretPath then
                UpdateAllButtonsCasts()
            else
                UpdateCastsOnUnit(previousTarget)
            end
        end

    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        local sourceKey = sourceUnit
        if casts[sourceKey] and not casts[sourceKey]["nonNameplate"] then
            local previousTarget = casts[sourceKey]["targetUnit"]
            casts[sourceKey] = nil
            if useSecretPath then
                UpdateAllButtonsCasts()
            else
                UpdateCastsOnUnit(previousTarget)
            end
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
    -- Show/hide icon previews based on display mode
    if displayMode == "Border" then
        -- Border only: hide icons, show glow
        for i = 1, #frame do
            frame[i]:Hide()
        end
        frame:UpdateSize(0)
    else
        -- Icons or Both: show preview icons (OnShow hooks handle icon/cooldown)
        local num = min(maxIcons or 1, #frame)
        for i = 1, num do
            frame[i]:Show()
        end
        frame:UpdateSize(num)
    end

    -- Show glow in Border and Both modes; hide in Icons mode
    if displayMode == "Icons" then
        frame:HideGlow()
    else
        frame:ShowGlow(unpack(Cell.vars.targetedSpellsGlow))
    end
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
    useSecretPath = false
    F.IterateAllUnitButtons(HideCasts, true)
end

function I.EnableTargetedSpells(enabled)
    if enabled then
        F.IterateAllUnitButtons(function(b)
            b.indicators.targetedSpells:Show()
        end, true)

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
        eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

        Cell.RegisterCallback("EnterInstance", "TargetedSpells_EnterInstance", EnterLeaveInstance)
        Cell.RegisterCallback("LeaveInstance", "TargetedSpells_LeaveInstance", EnterLeaveInstance)
    else
        Reset()
        useSecretPath = false
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
