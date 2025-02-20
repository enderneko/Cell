local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local I = Cell.iFuncs
local LCG = LibStub("LibCustomGlow-1.0")

local UnitIsVisible = UnitIsVisible
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitIsUnit = UnitIsUnit
local UnitIsEnemy = UnitIsEnemy
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo

local casts = {}
local castsOnUnit, sortedCastsOnUnit = {}, {}
local recheck = {}
local maxIcons, showAllSpells
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
    b.indicators.targetedSpells:UpdateSize(0)
    b.indicators.targetedSpells:HideGlow()
end

local function ShowCasts(b, showGlow, sortedCasts, num)
    num = min(maxIcons, num)
    for i = 1, num do
        local cast = sortedCasts[i]
        b.indicators.targetedSpells[i].cooldown:SetReverse(not cast.isChanneling)
        b.indicators.targetedSpells[i]:SetCooldown(cast.startTime, cast.endTime-cast.startTime, cast.icon, cast.count)
    end
    b.indicators.targetedSpells:UpdateSize(num)

    if showGlow then
        b.indicators.targetedSpells:ShowGlow(unpack(Cell.vars.targetedSpellsGlow))
    else
        b.indicators.targetedSpells:HideGlow()
    end
end

-------------------------------------------------
-- update casts for guid
-------------------------------------------------
local function GetCastsOnUnit(guid)
    if castsOnUnit[guid] then
        wipe(castsOnUnit[guid])
        wipe(sortedCastsOnUnit[guid])
    else
        castsOnUnit[guid] = {}
        sortedCastsOnUnit[guid] = {}
    end

    local inListFound
    for sourceGUID, castInfo in pairs(casts) do
        if guid == castInfo["targetGUID"] then
            if castInfo["endTime"] > GetTime() then -- not expired
                local spellId = castInfo["spellId"]
                if not castsOnUnit[guid][spellId] then
                    castsOnUnit[guid][spellId] = {["count"] = 0}
                end
                if not castsOnUnit[guid][spellId]["endTime"] or castsOnUnit[guid][spellId]["endTime"] > castInfo["endTime"] then --! shorter duration
                    castsOnUnit[guid][spellId]["startTime"] = castInfo["startTime"]
                    castsOnUnit[guid][spellId]["endTime"] = castInfo["endTime"]
                    castsOnUnit[guid][spellId]["icon"] = castInfo["icon"]
                end
                castsOnUnit[guid][spellId]["count"] = castsOnUnit[guid][spellId]["count"] + 1

                if Cell.vars.targetedSpellsList[spellId] then
                    castsOnUnit[guid][spellId]["inList"] = true
                    inListFound = true
                end
            else
                casts[sourceGUID] = nil
            end
        end
    end

    return castsOnUnit[guid], inListFound
end

local function Comparator(a, b)
    if a.inList ~= b.inList then
        return a.inList
    end
    return a.startTime < b.startTime
end

local function UpdateCastsOnUnit(guid)
    if not guid then return end

    -- local startTime, endTime, spellId, icon, isChanneling
    local t, showGlow = GetCastsOnUnit(guid)

    for spellId, castInfo in pairs(t) do
        tinsert(sortedCastsOnUnit[guid], castInfo)

        -- if not endTime then --! init
        --     startTime, endTime, spellId, icon, isChanneling = castInfo["startTime"], castInfo["endTime"], castInfo["spellId"], castInfo["icon"], castInfo["isChanneling"]
        -- else
        --     spellId = castInfo["spellId"]
        --     if Cell.vars.targetedSpellsList[spellId] then --! [IN LIST]
        --         if not inListFound or endTime > castInfo["endTime"] then --! NOT FOUND BEFORE or SHORTER DURATION
        --             startTime, endTime, icon, isChanneling = castInfo["startTime"], castInfo["endTime"], castInfo["icon"], castInfo["isChanneling"]
        --         end
        --     elseif not inListFound and endTime > castInfo["endTime"] then --! [NOT IN LIST] NOT FOUND BEFORE and SHORTER DURATION
        --         startTime, endTime, icon, isChanneling = castInfo["startTime"], castInfo["endTime"], castInfo["icon"], castInfo["isChanneling"]
        --     end
        -- end

        -- if Cell.vars.targetedSpellsList[spellId] then
        --     inListFound = true
        -- end
    end

    local n = #sortedCastsOnUnit[guid]

    if n == 0 then
        F.HandleUnitButton("guid", guid, HideCasts)
    else
        table.sort(sortedCastsOnUnit[guid], Comparator)
        F.HandleUnitButton("guid", guid, ShowCasts, showGlow, sortedCastsOnUnit[guid], n)
    end
end

-------------------------------------------------
-- check if sourceUnit is casting
-------------------------------------------------
local function CheckUnitCast(sourceUnit, isRecheck)
    if not UnitIsEnemy("player", sourceUnit) then return end

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
        if casts[sourceGUID] then
            casts[sourceGUID]["startTime"] = startTimeMS/1000
            casts[sourceGUID]["endTime"] = endTimeMS/1000
            casts[sourceGUID]["spellId"] = spellId
            casts[sourceGUID]["icon"] = texture
        else
            casts[sourceGUID] = {
                ["startTime"] = startTimeMS/1000,
                ["endTime"] = endTimeMS/1000,
                ["spellId"] = spellId,
                ["icon"] = texture,
                ["isChanneling"] = isChanneling,
                -- ["targetGUID"] = targetGUID,
                -- ["sourceUnit"] = sourceUnit,
                -- ["targetUnit"] = targetUnit,
                ["recheck"] = 0,
            }
        end

        local targetUnit = sourceUnit.."target"
        targetUnit = F.GetTargetUnitID(targetUnit) -- units in group (players/pets), no npcs
        if targetUnit then targetGUID = UnitGUID(targetUnit) end

        -- update spell target
        casts[sourceGUID]["targetUnit"] = targetUnit
        casts[sourceGUID]["targetGUID"] = targetGUID
        casts[sourceGUID]["nonNameplate"] = not strfind(sourceUnit, "^nameplate")

        UpdateCastsOnUnit(targetGUID)

        if not isRecheck then
            if not recheck[sourceGUID] or not (strfind(sourceUnit, "target$") or strfind(sourceUnit, "^nameplate")) then
                recheck[sourceGUID] = sourceUnit
            end
            eventFrame:Show()
        end
    end

    if previousTarget and previousTarget ~= targetGUID then
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

        for guid, unit in pairs(recheck) do
            if casts[guid] then
                casts[guid]["recheck"] = casts[guid]["recheck"] + 1
                if casts[guid]["recheck"] >= 6 then
                    recheck[guid] = nil
                else
                    empty = false
                    local recheckRequired = (not casts[guid]["targetUnit"] and UnitExists(unit.."target")) or (casts[guid]["targetUnit"] and not UnitIsUnit(unit.."target", casts[guid]["targetUnit"]))
                    if recheckRequired then
                        -- print(unit, casts[guid]["recheck"], recheckRequired)
                        CheckUnitCast(unit, true)
                    end
                end
            else
                recheck[guid] = nil
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
        local sourceGUID = UnitGUID(sourceUnit)
        if casts[sourceGUID] then
            previousTarget = casts[sourceGUID]["targetGUID"]
            casts[sourceGUID] = nil
            UpdateCastsOnUnit(previousTarget)
        end

    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        local sourceGUID = UnitGUID(sourceUnit)
        if casts[sourceGUID] and not casts[sourceGUID]["nonNameplate"] then
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