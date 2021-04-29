local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local I = Cell.iFuncs
local LCG = LibStub("LibCustomGlow-1.0")

-------------------------------------------------
-- targeted spells
-------------------------------------------------
local casts, expiredCasts, spells, glow = {}, {}, {}
-- spells[32011] = true
local castsOnUnit = {}

local function UpdateTargetedSpells(setting, value, value2)
    F:Debug("UpdateTargetedSpells: ", setting, value, value2)
    if setting == "spells" then
        spells = F:ConvertTable(value)
    elseif setting == "glow" then
        glow = value
    else
        spells = F:ConvertTable(value)
        glow = value2
    end
end
Cell:RegisterCallback("UpdateTargetedSpells", "UpdateTargetedSpells", UpdateTargetedSpells)

local function GetCastsOnUnit(guid)
    wipe(castsOnUnit)
    for sourceGUID, castInfo in pairs(casts) do
        if guid == castInfo["targetGUID"] then
            if castInfo["endTime"] > GetTime() then -- not expired
                tinsert(castsOnUnit, castInfo)
            else
                tinsert(expiredCasts, sourceGUID)
            end
        end
    end

    for _, source in pairs(expiredCasts) do
        casts[source] = nil
    end
    wipe(expiredCasts)

    return castsOnUnit
end

local function UpdateCastsOnUnit(guid)
    local b = F:GetUnitButtonByGUID(guid)
    if not b then return end

    local allCasts = 0
    local startTime, endTime, spellId, icon
    for _, castInfo in pairs(GetCastsOnUnit(guid)) do
        allCasts = allCasts + 1
        if not endTime then
            startTime, endTime, spellId, icon = castInfo["startTime"], castInfo["endTime"], castInfo["spellId"], castInfo["icon"]
        elseif endTime > castInfo["endTime"] then -- always show spell with min endTime
            startTime, endTime, spellId, icon = castInfo["startTime"], castInfo["endTime"], castInfo["spellId"], castInfo["icon"]
        end
    end

    if allCasts == 0 then
        b.indicators.targetedSpells:Hide()
    else
        b.indicators.targetedSpells:SetCooldown(startTime, endTime-startTime, icon, allCasts)
        b.indicators.targetedSpells:ShowGlow(unpack(glow))
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(_, event, sourceUnit)
    if event == "ENCOUNTER_END" then
        wipe(casts)
        wipe(expiredCasts)
        F:IterateAllUnitButtons(function(b)
            b.indicators.targetedSpells:Hide()
        end)
        return
    end

    if sourceUnit and UnitIsEnemy(sourceUnit, "player") then
        local sourceGUID = UnitGUID(sourceUnit)
        local cast = casts[sourceGUID]

        if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_DELAYED"  or event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" or event == "UNIT_TARGET" or event == "NAME_PLATE_UNIT_ADDED" then
            -- name, text, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible, spellId
            local name, _, texture, startTimeMS, endTimeMS, _, _, notInterruptible, spellId = UnitCastingInfo(sourceUnit)
            if not name then
                -- name, text, texture, startTimeMS, endTimeMS, isTradeSkill, notInterruptible, spellId
                name, _, texture, startTimeMS, endTimeMS, _, notInterruptible, spellId = UnitChannelInfo(sourceUnit)
            end

            local previousTarget
            if cast then previousTarget = cast["targetGUID"] end

            if spellId and spells[spellId] then
                local targetUnit = sourceUnit.."target"
                if UnitExists(targetUnit) then
                    for member in F:IterateGroupMembers() do
                        if UnitIsUnit(targetUnit, member) then
                            local targetGUID = UnitGUID(member)
                            casts[sourceGUID] = {
                                ["startTime"] = startTimeMS/1000,
                                ["endTime"] = endTimeMS/1000,
                                ["spellId"] = spellId,
                                ["icon"] = texture,
                                ["targetGUID"] = targetGUID,
                            }
                            UpdateCastsOnUnit(targetGUID)
                            break
                        end
                    end
                end
            end
            if previousTarget then UpdateCastsOnUnit(previousTarget) end

        elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_FAILED_QUIET" or event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "NAME_PLATE_UNIT_REMOVED" then
            if cast then
                casts[sourceGUID] = nil
                UpdateCastsOnUnit(cast["targetGUID"])
            end
        end
    end
end)

function I:CreateTargetedSpells(parent)
    local frame = I:CreateAura_BorderIcon(parent:GetName().."TargetedSpells", parent.widget.overlayFrame, 2)
    parent.indicators.targetedSpells = frame
    frame:Hide()

    -- frame.spellId
    -- frame.spellCount

    function frame:SetCooldown(start, duration, icon, count)
        frame.duration:Hide()

        if count ~= 1 then
            frame.stack:Show()
            frame.stack:SetText(count)
        else
            frame.stack:Hide()
        end

        frame.border:Show()
        frame.cooldown:Show()
        frame.cooldown:SetSwipeColor(unpack(glow[2]))
        frame.cooldown:SetCooldown(start, duration)
        frame.icon:SetTexture(icon)
        frame:Show()
    end

    function frame:SetFont(font, size, flags, horizontalOffset)
        if not string.find(font, ".ttf") then font = F:GetFont(font) end

        if flags == "Shadow" then
            frame.stack:SetFont(font, size)
            frame.stack:SetShadowOffset(1, -1)
            frame.stack:SetShadowColor(0, 0, 0, 1)
        else
            if flags == "Outline" then
                flags = "OUTLINE"
            elseif flags == "None" then
                flags = ""
            else
                flags = "OUTLINE, MONOCHROME"
            end
            frame.stack:SetFont(font, size, flags)
            frame.stack:SetShadowOffset(0, 0)
            frame.stack:SetShadowColor(0, 0, 0, 0)
        end
        frame.stack:ClearAllPoints()
        frame.stack:SetPoint("TOPRIGHT", horizontalOffset, 1)
    end

    function frame:ShowGlow(glowType, color, arg1, arg2, arg3, arg4)
        if glowType == "Normal" then
            LCG.PixelGlow_Stop(parent.widget.overlayFrame)
            LCG.AutoCastGlow_Stop(parent.widget.overlayFrame)
            LCG.ButtonGlow_Start(parent.widget.overlayFrame, color)
        elseif glowType == "Pixel" then
            LCG.ButtonGlow_Stop(parent.widget.overlayFrame)
            LCG.AutoCastGlow_Stop(parent.widget.overlayFrame)
            -- color, N, frequency, length, thickness
            LCG.PixelGlow_Start(parent.widget.overlayFrame, color, arg1, arg2, arg3, arg4)
        elseif glowType == "Shine" then
            LCG.ButtonGlow_Stop(parent.widget.overlayFrame)
            LCG.PixelGlow_Stop(parent.widget.overlayFrame)
            -- color, N, frequency, scale
            LCG.AutoCastGlow_Start(parent.widget.overlayFrame, color, arg1, arg2, arg3)
        else
            LCG.ButtonGlow_Stop(parent.widget.overlayFrame)
            LCG.PixelGlow_Stop(parent.widget.overlayFrame)
            LCG.AutoCastGlow_Stop(parent.widget.overlayFrame)
        end
    end

    -- function frame:HideGlow(glowType)
    --     if glowType == "Normal" then
    --         LCG.ButtonGlow_Stop(parent.widget.overlayFrame)
    --     elseif glowType == "Pixel" then
    --         LCG.PixelGlow_Stop(parent.widget.overlayFrame)
    --     elseif glowType == "Shine" then
    --         LCG.AutoCastGlow_Stop(parent.widget.overlayFrame)
    --     end
    -- end

    frame:SetScript("OnHide", function()
        LCG.ButtonGlow_Stop(parent.widget.overlayFrame)
        LCG.PixelGlow_Stop(parent.widget.overlayFrame)
        LCG.AutoCastGlow_Stop(parent.widget.overlayFrame)
    end)

    function frame:ShowGlowPreview()
        frame:ShowGlow(unpack(glow))
    end

    function frame:HideGlowPreview()
        LCG.ButtonGlow_Stop(parent.widget.overlayFrame)
        LCG.PixelGlow_Stop(parent.widget.overlayFrame)
        LCG.AutoCastGlow_Stop(parent.widget.overlayFrame)
    end
end

function I:EnableTargetedSpells(enabled)
    if enabled then
        -- UNIT_SPELLCAST_DELAYED UNIT_SPELLCAST_FAILED UNIT_SPELLCAST_FAILED_QUIET UNIT_SPELLCAST_INTERRUPTED UNIT_SPELLCAST_START UNIT_SPELLCAST_STOP
        -- UNIT_SPELLCAST_CHANNEL_START UNIT_SPELLCAST_CHANNEL_STOP UNIT_SPELLCAST_CHANNEL_UPDATE
        -- UNIT_TARGET ENCOUNTER_END

        eventFrame:RegisterEvent("UNIT_SPELLCAST_START")
        eventFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
        eventFrame:RegisterEvent("UNIT_SPELLCAST_DELAYED")
        eventFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
        eventFrame:RegisterEvent("UNIT_SPELLCAST_FAILED_QUIET")
        eventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
        eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
        eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
        eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")

        eventFrame:RegisterEvent("UNIT_TARGET")
        eventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        eventFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
        
        eventFrame:RegisterEvent("ENCOUNTER_END")
    else
        eventFrame:UnregisterAllEvents()
        F:IterateAllUnitButtons(function(b)
            b.indicators.targetedSpells:Hide()
        end)
    end
end