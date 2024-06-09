local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local B = Cell.bFuncs
local I = Cell.iFuncs
local U = Cell.uFuncs
local P = Cell.pixelPerfectFuncs
local A = Cell.animations
local LGI = LibStub:GetLibrary("LibGroupInfo")

CELL_FADE_OUT_HEALTH_PERCENT = nil

local UnitGUID = UnitGUID
-- local UnitHealth = LibCLHealth.UnitHealth
local UnitName = UnitName
local GetUnitName = GetUnitName
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitGetIncomingHeals = UnitGetIncomingHeals
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local UnitIsUnit = UnitIsUnit
local UnitIsPlayer = UnitIsPlayer
local UnitIsConnected = UnitIsConnected
local UnitIsAFK = UnitIsAFK
local UnitIsFeignDeath = UnitIsFeignDeath
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsGhost = UnitIsGhost
local UnitPowerType = UnitPowerType
local UnitPowerMax = UnitPowerMax
-- local UnitInRange = UnitInRange
-- local UnitIsVisible = UnitIsVisible
local SetRaidTargetIconTexture = SetRaidTargetIconTexture
local GetTime = GetTime
local GetRaidTargetIndex = GetRaidTargetIndex
local GetReadyCheckStatus = GetReadyCheckStatus
local UnitHasVehicleUI = UnitHasVehicleUI
-- local UnitInVehicle = UnitInVehicle
-- local UnitUsingVehicle = UnitUsingVehicle
local UnitIsCharmed = UnitIsCharmed
local UnitIsPlayer = UnitIsPlayer
local UnitInPartyIsAI = UnitInPartyIsAI
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitThreatSituation = UnitThreatSituation
local GetThreatStatusColor = GetThreatStatusColor
local UnitExists = UnitExists
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitIsGroupAssistant = UnitIsGroupAssistant
local InCombatLockdown = InCombatLockdown
local UnitPhaseReason = UnitPhaseReason
-- local UnitBuff = UnitBuff
-- local UnitDebuff = UnitDebuff
local GetAuraDataByAuraInstanceID = C_UnitAuras.GetAuraDataByAuraInstanceID
local IsInRaid = IsInRaid
local UnitDetailedThreatSituation = UnitDetailedThreatSituation
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local GetAuraSlots = C_UnitAuras.GetAuraSlots

--! for AI followers, UnitClassBase is buggy
local UnitClassBase = function(unit)
    return select(2, UnitClass(unit))
end

local barAnimationType, highlightEnabled, predictionEnabled
local shieldEnabled, overshieldEnabled, overshieldReverseFillEnabled
local absorbEnabled, absorbInvertColor

-------------------------------------------------
-- unit button func declarations
-------------------------------------------------
local UnitButton_UpdateAll
local UnitButton_UpdateAuras, UnitButton_UpdateRole, UnitButton_UpdateLeader, UnitButton_UpdateStatusText
local UnitButton_UpdateHealthColor, UnitButton_UpdateNameTextColor, UnitButton_UpdateHealthTextColor, UnitButton_UpdatePowerTextColor
local UnitButton_UpdatePowerMax, UnitButton_UpdatePower, UnitButton_UpdatePowerType
local UnitButton_UpdateShieldAbsorbs

-------------------------------------------------
-- unit button init indicators
-------------------------------------------------
local enabledIndicators, indicatorNums = {}, {}
local indicatorBooleans, indicatorColors = {}, {}

local function UpdateIndicatorParentVisibility(b, indicatorName, enabled)
    if not (indicatorName == "debuffs" or
            indicatorName == "privateAuras" or
            indicatorName == "defensiveCooldowns" or
            indicatorName == "externalCooldowns" or
            indicatorName == "allCooldowns" or
            indicatorName == "dispels" or
            indicatorName == "crowdControls" or
            indicatorName == "missingBuffs") then
        return
    end

    if enabled then
        b.indicators[indicatorName]:Show()
    else
        b.indicators[indicatorName]:Hide()
    end
end

local function ResetIndicators()
    wipe(enabledIndicators)
    wipe(indicatorNums)

    for _, t in pairs(Cell.vars.currentLayoutTable["indicators"]) do
        -- update enabled
        if t["enabled"] then
            enabledIndicators[t["indicatorName"]] = true
        end
        -- update num
        if t["num"] then
            indicatorNums[t["indicatorName"]] = t["num"]
        end
        -- update statusIcon
        if t["indicatorName"] == "statusIcon" then
            I.EnableStatusIcon(t["enabled"])
        end
        -- update aoehealing
        if t["indicatorName"] == "aoeHealing" then
            I.EnableAoEHealing(t["enabled"])
        end
        -- update targetCounter
        if t["indicatorName"] == "targetCounter" then
            I.UpdateTargetCounterFilters(t["filters"], true)
            I.EnableTargetCounter(t["enabled"])
        end
        -- update targetedSpells
        if t["indicatorName"] == "targetedSpells" then
            I.EnableTargetedSpells(t["enabled"])
            I.ShowAllTargetedSpells(t["showAllSpells"])
        end
        -- update consumables
        if t["indicatorName"] == "consumables" then
            I.EnableConsumables(t["enabled"])
        end
        -- update healthThresholds
        if t["indicatorName"] == "healthThresholds" then
            I.UpdateHealthThresholds()
        end
        -- update missingBuffs
        if t["indicatorName"] == "missingBuffs" then
            I.UpdateMissingBuffsNum(t["num"], true)
            I.UpdateMissingBuffsFilters(t["filters"], true)
            I.EnableMissingBuffs(t["enabled"])
        end
        -- update extra
        if t["indicatorName"] == "nameText" or t["indicatorName"] == "healthText" or t["indicatorName"] == "powerText" then
            indicatorColors[t["indicatorName"]] = t["color"]
        end
        if t["dispellableByMe"] ~= nil then
            indicatorBooleans[t["indicatorName"]] = t["dispellableByMe"]
        end
        if t["hideIfEmptyOrFull"] ~= nil then
            indicatorBooleans[t["indicatorName"]] = t["hideIfEmptyOrFull"]
        end
        if t["onlyShowTopGlow"] ~= nil then
            indicatorBooleans[t["indicatorName"]] = t["onlyShowTopGlow"]
        end
        if t["hideInCombat"] ~= nil then
            indicatorBooleans[t["indicatorName"]] = t["hideInCombat"]
        end
        if t["onlyShowOvershields"] ~= nil then
            indicatorBooleans[t["indicatorName"]] = t["onlyShowOvershields"]
        end
    end
end

local function HandleIndicators(b)
    b._indicatorReady = nil

    -- NOTE: Remove old
    I.RemoveAllCustomIndicators(b)

    for _, t in pairs(Cell.vars.currentLayoutTable["indicators"]) do
        local indicator = b.indicators[t["indicatorName"]] or I.CreateIndicator(b, t)
        -- update position
        if t["position"] then
            P:ClearPoints(indicator)
            P:Point(indicator, t["position"][1], b, t["position"][2], t["position"][3], t["position"][4])
        end
        -- update anchor
        if t["anchor"] then
            indicator:SetAnchor(t["anchor"])
        end
        -- update frameLevel
        if t["frameLevel"] then
            indicator:SetFrameLevel(indicator:GetParent():GetFrameLevel()+t["frameLevel"])
        end
        -- update size
        if t["size"] then
            -- NOTE: debuffs: ["size"] = {{normalSize}, {bigSize}}
            if t["indicatorName"] == "debuffs" then
                indicator:SetSize(t["size"][1], t["size"][2])
            else
                P:Size(indicator, t["size"][1], t["size"][2])
            end
        end
        -- update thickness
        if t["thickness"] then
            indicator:SetThickness(t["thickness"])
        end
        -- update border
        if t["border"] then
            indicator:SetBorder(t["border"])
        end
        -- update height
        if t["height"] then
            P:Height(indicator, t["height"])
        end
        -- update height
        if t["textWidth"] then
            indicator:UpdateTextWidth(t["textWidth"])
        end
        -- update alpha
        if t["alpha"] then
            indicator:SetAlpha(t["alpha"])
        end
        -- update numPerLine
        if t["numPerLine"] then
            indicator:SetNumPerLine(t["numPerLine"])
        end
        -- update spacing
        if t["spacing"] then
            indicator:SetSpacing(t["spacing"])
        end
        -- update orientation
        if t["orientation"] then
            indicator:SetOrientation(t["orientation"])
        end
        -- update font
        if t["font"] then
            indicator:SetFont(unpack(t["font"]))
        end
        -- update format
        if t["format"] then
            indicator:SetFormat(t["format"])
            if t["indicatorName"] == "healthText" then
                B:UpdateHealthText(b)
            elseif t["indicatorName"] == "powerText" then
                B:UpdatePowerText(b)
            end
        end
        -- update color
        if t["color"] and t["indicatorName"] ~= "nameText" and t["indicatorName"] ~="healthText" and t["indicatorName"] ~="powerText" then
            indicator:SetColor(unpack(t["color"]))
        end
        -- update colors
        if t["colors"] then
            indicator:SetColors(t["colors"])
        end
        -- update texture
        if t["texture"] then
            indicator:SetTexture(t["texture"])
        end
        -- update dispel highlight
        if t["highlightType"] then
            indicator:UpdateHighlight(t["highlightType"])
        end
        -- update dispel icons
        if type(t["showDispelTypeIcons"]) == "boolean" then
            indicator:ShowIcons(t["showDispelTypeIcons"])
        end
        -- update duration
        if type(t["showDuration"]) == "boolean" or type(t["showDuration"]) == "number" then
            indicator:ShowDuration(t["showDuration"])
        end
        -- update animation
        if type(t["showAnimation"]) == "boolean" then
            indicator:ShowAnimation(t["showAnimation"])
        end
        -- update stack
        if type(t["showStack"]) == "boolean" then
            indicator:ShowStack(t["showStack"])
        end
        -- update duration
        if t["duration"] then
            indicator:SetDuration(t["duration"])
        end
        -- update circled nums
        if type(t["circledStackNums"]) == "boolean" then
            indicator:SetCircledStackNums(t["circledStackNums"])
        end
        -- update groupNumber
        if type(t["showGroupNumber"]) == "boolean" then
            indicator:ShowGroupNumber(t["showGroupNumber"])
        end
        -- update vehicleNamePosition
        if t["vehicleNamePosition"] then
            indicator:UpdateVehicleNamePosition(t["vehicleNamePosition"])
        end
        -- update timer
        if type(t["showTimer"]) == "boolean" then
            indicator:SetShowTimer(t["showTimer"])
        end
        -- update background
        if type(t["showBackground"]) == "boolean" then
            indicator:ShowBackground(t["showBackground"])
        end
        -- update role texture
        if t["roleTexture"] then
            indicator:SetRoleTexture(t["roleTexture"])
            indicator:HideDamager(t["hideDamager"])
            UnitButton_UpdateRole(b)
        end
        -- tooltip
        if type(t["showTooltip"]) == "boolean" then
            indicator:ShowTooltip(t["showTooltip"])
        end
        -- blacklist shortcut
        if type(t["enableBlacklistShortcut"]) == "boolean" then
            indicator:EnableBlacklistShortcut(t["enableBlacklistShortcut"])
        end
        -- speed
        if t["speed"] then
            indicator:SetSpeed(t["speed"])
        end
        -- privateAuraOptions
        if t["privateAuraOptions"] then
            indicator:UpdateOptions(t["privateAuraOptions"])
        end
        -- update fadeOut
        if type(t["fadeOut"]) == "boolean" then
            indicator:SetFadeOut(t["fadeOut"])
        end
        -- update glow
        if t["glowOptions"] then
            indicator:UpdateGlowOptions(t["glowOptions"])
        end
        -- update smooth
        if type(t["smooth"]) == "boolean" then
            indicator:EnableSmooth(t["smooth"])
        end

        -- init
        -- update name visibility
        if t["indicatorName"] == "nameText" then
            if t["enabled"] then
                indicator:Show()
            else
                indicator:Hide()
            end
        elseif t["indicatorName"] == "playerRaidIcon" then
            B:UpdatePlayerRaidIcon(b, t["enabled"])
        elseif t["indicatorName"] == "targetRaidIcon" then
            B:UpdateTargetRaidIcon(b, t["enabled"])
        else
            UpdateIndicatorParentVisibility(b, t["indicatorName"], t["enabled"])
        end

        -- update pixel perfect for built-in widgets
        -- if t["type"] == "built-in" then
        --     if indicator.UpdatePixelPerfect then
        --         indicator:UpdatePixelPerfect()
        --     end
        -- end
    end

    --! update pixel perfect for widgets
    B:UpdatePixelPerfect(b, true)

    b._indicatorReady = true
end

-------------------------------------------------
-- indicator update queue
-------------------------------------------------
local updater = CreateFrame("Frame")
updater:Hide()
local queue = {}

updater:SetScript("OnUpdate", function()
    local b = queue[1]
    if b then
        if not b._status then
            -- print("processing", GetTime(), b:GetName())
            b._status = "processing"
            HandleIndicators(b)
            UnitButton_UpdateAll(b)
            b._status = "finished"
        elseif b._status == "finished" then
            CellLoadingBar.current = (CellLoadingBar.current or 0) + 1
            CellLoadingBar:SetValue(CellLoadingBar.current)
            tremove(queue, 1)
            b._status = nil
        end
    else
        CellLoadingBar:Hide()
        CellLoadingBar.current = 0
        updater:Hide()
    end
end)

hooksecurefunc(updater, "Show", function()
    CellLoadingBar.total = #queue
    CellLoadingBar:SetMinMaxValues(0, CellLoadingBar.total)
    CellLoadingBar:SetValue(CellLoadingBar.current or 0)
    CellLoadingBar:Show()
end)

local function AddToQueue(b)
    b._indicatorReady = nil
    tinsert(queue, b)
end

-------------------------------------------------
-- UpdateIndicators
-------------------------------------------------
local indicatorsInitialized
local previousLayout = {}

local function UpdateIndicators(layout, indicatorName, setting, value, value2)
    F:Debug("|cffff7777UpdateIndicators:|r ", layout, indicatorName, setting, value, value2)

    local INDEX = Cell.vars.groupType == "solo" and "solo" or Cell.vars.layoutGroupType

    if layout then
        -- Cell:Fire("UpdateIndicators", layout): indicators copy/import
        -- Cell:Fire("UpdateIndicators", xxx, ...): indicator updated
        for k, v in pairs(previousLayout) do
            if v == layout then
                previousLayout[k] = nil -- update required
                F:Debug("UPDATE REQUIRED:", k)
            end
        end

        --! indicator changed, but not current layout
        if layout ~= Cell.vars.currentLayout then
            F:Debug("NO UPDATE: not active layout")
            return
        end

    elseif not indicatorName then -- Cell:Fire("UpdateIndicators")
        --! layout/groupType switched, check if update is required
        if previousLayout[INDEX] == Cell.vars.currentLayout then
            F:Debug("NO UPDATE: only reset custom indicator tables")
            I.ResetCustomIndicatorTables()
            ResetIndicators()
            --! update shared buttons: npcs, spotlights
            -- F:IterateSharedUnitButtons(HandleIndicators)
            F:IterateSharedUnitButtons(AddToQueue)
            updater:Show()
            return
        end
    end

    previousLayout[INDEX] = Cell.vars.currentLayout

    if not indicatorName then -- init
        I.ResetCustomIndicatorTables()
        ResetIndicators()

        if not indicatorsInitialized then
            -- update indicators
            F:IterateAllUnitButtons(HandleIndicators) -- -- NOTE: indicatorsInitialized = false, update ALL GROUP TYPE; indicatorsInitialized = true, just update CURRENT GROUP TYPE
            -- update all when indicators update finished
            F:IterateAllUnitButtons(UnitButton_UpdateAll, true)
        else
            F:IterateAllUnitButtons(AddToQueue, true)
            updater:Show()
        end
        indicatorsInitialized = true

    else
        -- changed in IndicatorsTab
        if setting == "enabled" then
            enabledIndicators[indicatorName] = value

            if indicatorName == "aoeHealing" then
                I.EnableAoEHealing(value)
            elseif indicatorName == "targetCounter" then
                I.EnableTargetCounter(value)
            elseif indicatorName == "targetedSpells" then
                I.EnableTargetedSpells(value)
            elseif indicatorName == "consumables" then
                I.EnableConsumables(value)
            elseif indicatorName == "roleIcon" then
                F:IterateAllUnitButtons(function(b)
                    UnitButton_UpdateRole(b)
                end, true)
            elseif indicatorName == "leaderIcon" then
                F:IterateAllUnitButtons(function(b)
                    UnitButton_UpdateLeader(b)
                end, true)
            elseif indicatorName == "playerRaidIcon" then
                F:IterateAllUnitButtons(function(b)
                    B:UpdatePlayerRaidIcon(b, value)
                end, true)
            elseif indicatorName == "targetRaidIcon" then
                F:IterateAllUnitButtons(function(b)
                    B:UpdateTargetRaidIcon(b, value)
                end, true)
            elseif indicatorName == "nameText" then
                F:IterateAllUnitButtons(function(b)
                    if value then
                        b.indicators[indicatorName]:Show()
                    else
                        b.indicators[indicatorName]:Hide()
                    end
                end, true)
            elseif indicatorName == "statusText" then
                F:IterateAllUnitButtons(function(b)
                    B:UpdateStatusText(b)
                end, true)
            elseif indicatorName == "healthText" then
                F:IterateAllUnitButtons(function(b)
                    B:UpdateHealthText(b)
                end, true)
            elseif indicatorName == "powerText" then
                F:IterateAllUnitButtons(function(b)
                    B:UpdatePowerText(b)
                end, true)
            elseif indicatorName == "shieldBar" then
                F:IterateAllUnitButtons(function(b)
                    B:UpdateShield(b)
                end, true)
            elseif indicatorName == "healthThresholds" then
                if value then
                    I.UpdateHealthThresholds()
                end
                F:IterateAllUnitButtons(function(b)
                    B.UpdateHealth(b)
                end, true)
            elseif indicatorName == "missingBuffs" then
                I.EnableMissingBuffs(value)
                F:IterateAllUnitButtons(function(b)
                    UpdateIndicatorParentVisibility(b, indicatorName, value)
                end, true)
            else
                -- refresh
                F:IterateAllUnitButtons(function(b)
                    UpdateIndicatorParentVisibility(b, indicatorName, value)
                    if not value then
                        b.indicators[indicatorName]:Hide() -- hide indicators which is shown right now
                    end
                    UnitButton_UpdateAuras(b)
                end, true)
            end
        elseif setting == "position" then
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                P:ClearPoints(indicator)
                P:Point(indicator, value[1], b, value[2], value[3], value[4])
                -- update arrangement
                if indicator.indicatorType == "icons" then
                    indicator:SetOrientation(indicator.orientation)
                end
            end, true)
        elseif setting == "anchor" then
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:SetAnchor(value)
            end, true)
        elseif setting == "frameLevel" then
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:SetFrameLevel(indicator:GetParent():GetFrameLevel()+value)
            end, true)
        elseif setting == "size" then
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                if indicatorName == "debuffs" then
                    indicator:SetSize(value[1], value[2])
                    -- update debuffs' normal/big icon sizes
                    UnitButton_UpdateAuras(b)
                else
                    P:Size(indicator, value[1], value[2])
                end
            end, true)
        elseif setting == "size-border" then
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                P:Size(indicator, value[1], value[2])
                indicator:SetBorder(value[3])
            end, true)
        elseif setting == "thickness" then
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:SetThickness(value)
            end, true)
        elseif setting == "height" then
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                P:Height(indicator, value)
            end, true)
        elseif setting == "textWidth" then
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:UpdateTextWidth(value)
            end, true)
        elseif setting == "alpha" then
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:SetAlpha(value)
            end, true)
        elseif setting == "spacing" then
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:SetSpacing(value)
            end, true)
        elseif setting == "orientation" then
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:SetOrientation(value)
            end, true)
        elseif setting == "font" then
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:SetFont(unpack(value))
            end, true)
        elseif setting == "format" then
            if indicatorName == "healthText" then
                F:IterateAllUnitButtons(function(b)
                    local indicator = b.indicators[indicatorName]
                    indicator:SetFormat(value)
                    B:UpdateHealthText(b)
                end, true)
            elseif indicatorName == "powerText" then
                F:IterateAllUnitButtons(function(b)
                    local indicator = b.indicators[indicatorName]
                    indicator:SetFormat(value)
                    B:UpdatePowerText(b)
                end, true)
            end
        elseif setting == "color" then
            if indicatorName == "nameText" then
                indicatorColors[indicatorName] = value
                F:IterateAllUnitButtons(function(b)
                    UnitButton_UpdateNameTextColor(b)
                end, true)
            elseif indicatorName == "healthText" then
                indicatorColors[indicatorName] = value
                F:IterateAllUnitButtons(function(b)
                    UnitButton_UpdateHealthTextColor(b)
                end, true)
            elseif indicatorName == "powerText" then
                indicatorColors[indicatorName] = value
                F:IterateAllUnitButtons(function(b)
                    UnitButton_UpdatePowerTextColor(b)
                end, true)
            else
                F:IterateAllUnitButtons(function(b)
                    local indicator = b.indicators[indicatorName]
                    indicator:SetColor(unpack(value))
                end, true)
            end
        elseif setting == "colors" then
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:SetColors(value) -- update color on next SetCooldown
                UnitButton_UpdateAuras(b) -- call SetCooldown now
            end, true)
        elseif setting == "vehicleNamePosition" then
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:UpdateVehicleNamePosition(value)
            end, true)
        elseif setting == "statusColors" then
            F:IterateAllUnitButtons(function(b)
                UnitButton_UpdateStatusText(b)
            end, true)
        elseif setting == "num" then
            indicatorNums[indicatorName] = value
            if indicatorName == "missingBuffs" then
                I.UpdateMissingBuffsNum(value)
            else
                -- refresh
                F:IterateAllUnitButtons(function(b)
                    UnitButton_UpdateAuras(b)
                end, true)
            end
        elseif setting == "numPerLine" then
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:SetNumPerLine(value)
            end, true)
        elseif setting == "roleTexture" then
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:SetRoleTexture(value)
                UnitButton_UpdateRole(b)
            end, true)
        elseif setting == "texture" then
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:SetTexture(value)
            end, true)
        elseif setting == "duration" then
            F:IterateAllUnitButtons(function(b)
                UnitButton_UpdateAuras(b)
            end, true)
        elseif setting == "highlightType" then
            F:IterateAllUnitButtons(function(b)
                b.indicators[indicatorName]:UpdateHighlight(value)
                UnitButton_UpdateAuras(b)
            end, true)
        elseif setting == "thresholds" then
            I.UpdateHealthThresholds()
            F:IterateAllUnitButtons(function(b)
                B.UpdateHealth(b)
            end, true)
        elseif setting == "showDuration" then
            F:IterateAllUnitButtons(function(b)
                b.indicators[indicatorName]:ShowDuration(value)
                UnitButton_UpdateAuras(b)
            end, true)
        elseif setting == "privateAuraOptions" then
            F:IterateAllUnitButtons(function(b)
                b.indicators[indicatorName]:UpdateOptions(value)
            end, true)
        elseif setting == "missingBuffsFilters" then
            I.UpdateMissingBuffsFilters()
        elseif setting == "targetCounterFilters" then
            I.UpdateTargetCounterFilters()
        elseif setting == "glowOptions" then
            F:IterateAllUnitButtons(function(b)
                b.indicators[indicatorName]:UpdateGlowOptions(value)
                UnitButton_UpdateAuras(b)
            end, true)
        elseif setting == "checkbutton" then
            if value == "showGroupNumber" then
                F:IterateAllUnitButtons(function(b)
                    b.indicators[indicatorName]:ShowGroupNumber(value2)
                end, true)
            elseif value == "showTimer" then
                F:IterateAllUnitButtons(function(b)
                    b.indicators[indicatorName]:SetShowTimer(value2)
                    UnitButton_UpdateStatusText(b)
                end, true)
            elseif value == "showBackground" then
                F:IterateAllUnitButtons(function(b)
                    b.indicators[indicatorName]:ShowBackground(value2)
                end, true)
            elseif value == "hideIfEmptyOrFull" then
                indicatorBooleans[indicatorName] = value2
                if indicatorName == "healthText" then
                    F:IterateAllUnitButtons(function(b)
                        B:UpdateHealthText(b)
                    end, true)
                elseif indicatorName == "powerText" then
                    F:IterateAllUnitButtons(function(b)
                        B:UpdatePowerText(b)
                    end, true)
                end
            elseif value == "hideInCombat" then
                indicatorBooleans[indicatorName] = value2
                F:IterateAllUnitButtons(function(b)
                    UnitButton_UpdateLeader(b)
                end, true)
            elseif value == "onlyShowOvershields" then
                indicatorBooleans[indicatorName] = value2
                F:IterateAllUnitButtons(function(b)
                    UnitButton_UpdateShieldAbsorbs(b)
                end, true)
            elseif value == "showDispelTypeIcons" then
                F:IterateAllUnitButtons(function(b)
                    b.indicators[indicatorName]:ShowIcons(value2)
                    UnitButton_UpdateAuras(b)
                end, true)
            elseif value == "showStack" then
                F:IterateAllUnitButtons(function(b)
                    b.indicators[indicatorName]:ShowStack(value2)
                    UnitButton_UpdateAuras(b)
                end, true)
            elseif value == "showAnimation" then
                F:IterateAllUnitButtons(function(b)
                    b.indicators[indicatorName]:ShowAnimation(value2)
                    UnitButton_UpdateAuras(b)
                end, true)
            elseif value == "trackByName" then
                F:IterateAllUnitButtons(function(b)
                    UnitButton_UpdateAuras(b)
                end, true)
            elseif value == "showTooltip" then
                F:IterateAllUnitButtons(function(b)
                    b.indicators[indicatorName]:ShowTooltip(value2)
                end, true)
            elseif value == "enableBlacklistShortcut" then
                F:IterateAllUnitButtons(function(b)
                    b.indicators[indicatorName]:EnableBlacklistShortcut(value2)
                end, true)
            elseif value == "circledStackNums" then
                F:IterateAllUnitButtons(function(b)
                    b.indicators[indicatorName]:SetCircledStackNums(value2)
                    UnitButton_UpdateAuras(b)
                end, true)
            elseif value == "hideDamager" then
                F:IterateAllUnitButtons(function(b)
                    b.indicators[indicatorName]:HideDamager(value2)
                    UnitButton_UpdateRole(b)
                end, true)
            elseif value == "fadeOut" then
                F:IterateAllUnitButtons(function(b)
                    b.indicators[indicatorName]:SetFadeOut(value2)
                    UnitButton_UpdateAuras(b)
                end, true)
            elseif value == "smooth" then
                F:IterateAllUnitButtons(function(b)
                    b.indicators[indicatorName]:EnableSmooth(value2)
                end, true)
            elseif value == "showAllSpells" then
                I.ShowAllTargetedSpells(value2)
            else
                indicatorBooleans[indicatorName] = value2
            end
        elseif setting == "create" then
            F:IterateAllUnitButtons(function(b)
                local indicator = I.CreateIndicator(b, value)
                -- update position
                if value["position"] then
                    P:ClearPoints(indicator)
                    P:Point(indicator, value["position"][1], b, value["position"][2], value["position"][3], value["position"][4])
                end
                -- update anchor
                if value["anchor"] then
                    indicator:SetAnchor(value["anchor"])
                end
                -- update size
                if value["size"] then
                    P:Size(indicator, value["size"][1], value["size"][2])
                end
                -- update size
                if value["frameLevel"] then
                    indicator:SetFrameLevel(indicator:GetParent():GetFrameLevel()+value["frameLevel"])
                end
                -- update numPerLine
                if value["numPerLine"] then
                    indicator:SetNumPerLine(value["numPerLine"])
                end
                -- update spacing
                if value["spacing"] then
                    indicator:SetSpacing(value["spacing"])
                end
                -- update orientation
                if value["orientation"] then
                    indicator:SetOrientation(value["orientation"])
                end
                -- update font
                if value["font"] then
                    indicator:SetFont(unpack(value["font"]))
                end
                -- update color
                if value["color"] then
                    indicator:SetColor(unpack(value["color"]))
                end
                -- update colors
                if value["colors"] then
                    indicator:SetColors(value["colors"])
                end
                -- update texture
                if value["texture"] then
                    indicator:SetTexture(value["texture"])
                end
                -- update showDuration
                if type(value["showDuration"]) ~= "nil" then
                    indicator:ShowDuration(value["showDuration"])
                end
                -- update showAnimation
                if type(value["showAnimation"]) == "boolean" then
                    indicator:ShowAnimation(value["showAnimation"])
                end
                -- update showStack
                if value["showStack"] then
                    indicator:ShowStack(value["showStack"])
                end
                -- update duration
                if value["duration"] then
                    indicator:SetDuration(value["duration"])
                end
                -- update circled nums
                if type(value["circledStackNums"]) == "boolean" then
                    indicator:SetCircledStackNums(value["circledStackNums"])
                end
                -- update fadeOut
                if type(value["fadeOut"]) == "boolean" then
                    indicator:SetFadeOut(value["fadeOut"])
                end
                -- update glow
                if value["glowOptions"] then
                    indicator:UpdateGlowOptions(value["glowOptions"])
                end
                -- FirstRun: Healers
                if value["auras"] and #value["auras"] ~= 0 then
                    UnitButton_UpdateAuras(b)
                end
            end, true)
        elseif setting == "remove" then
            F:IterateAllUnitButtons(function(b)
                I.RemoveIndicator(b, indicatorName, value)
            end, true)
        elseif setting == "auras" then
            -- indicator auras changed, hide them all, then recheck whether to show
            F:IterateAllUnitButtons(function(b)
                b.indicators[indicatorName]:Hide()
                UnitButton_UpdateAuras(b)
            end, true)
        elseif setting == "debuffBlacklist" or setting == "dispelBlacklist" or setting == "defensives" or setting == "externals" or setting == "crowdControls" or setting == "bigDebuffs" or setting == "debuffTypeColor" or setting == "castBy" then
            F:IterateAllUnitButtons(function(b)
                UnitButton_UpdateAuras(b)
            end, true)
        elseif setting == "speed" then
            -- only Consumables indicator has this option for now
            F:IterateAllUnitButtons(function(b)
                b.indicators[indicatorName]:SetSpeed(value)
            end, true)
        end
    end
end
Cell:RegisterCallback("UpdateIndicators", "UnitButton_UpdateIndicators", UpdateIndicators)

-------------------------------------------------
-- unit button
-------------------------------------------------
--[[
unitButton = {
    state = {
        class, color, inRange, isAssistant, isLeader, name, role,
        unit, displayedUnit, health, healthMax, healthPercent, powerType
    },
    widget = {
        background, mouseoverHighlight, targetHighlight, readyCheckHighlight,
        healthBar, healthBarBackground, absorbsBar, shieldBar, incomingHeal, damageFlashTex, overShieldGlow,
        powerBar, powerBarBackground,
        statusTextFrame, statusText, timerText
        overlayFrame, nameText
        aggroBlink, leaderIcon, statusIcon, readyCheckIcon, roleIcon,
    },
    func = {
        ShowFlash, HideFlash,
        ShowTimer, HideTimer, UpdateTimer,
    },
    indicators = {},
    updateRequired,
    __updateElapsed,
}
]]

-------------------------------------------------
-- ForEachAura
-------------------------------------------------
local function ForEachAuraHelper(button, func, continuationToken, ...)
    -- continuationToken is the first return value of GetAuraSlots()
    local n = select('#', ...)
    local index = 1
    for i = 1, n do
        local slot = select(i, ...)
        local auraInfo = C_UnitAuras.GetAuraDataBySlot(button.states.displayedUnit, slot)
        local done = func(button, auraInfo, index)
        if done then
            -- if func returns true then no further slots are needed, so don't return continuationToken
            return nil
        end
        index = index + 1
    end
    return continuationToken
end

-- local function ForEachAura(button, filter, func)
--     local continuationToken
--     repeat
--         -- continuationToken is the first return value of UnitAuraSltos
--         continuationToken = ForEachAuraHelper(button, func, GetAuraSlots(button.states.displayedUnit, filter, nil, continuationToken))
--     until continuationToken == nil
-- end

local function ForEachAura(button, filter, func)
    ForEachAuraHelper(button, func, GetAuraSlots(button.states.displayedUnit, filter))
end

-------------------------------------------------
-- debuffs
-------------------------------------------------
-- cleuAuras
-- local cleuUnits = {}

-- NOTE: Weakened Soul has been removed in Dragonflight
-- won't show if not a priest, otherwise show mine only
-- local function FilterWeakenedSoul(spellId, caster)
--     if spellId ~= 6788 then return true end

--     if not Cell.vars.playerClassID == 5 then return end
--     return caster == "player"
-- end

local function ResetDebuffVars(self)
    self._debuffs.resurrectionFound = false
    self._debuffs.raidDebuffsFound = false
    self._debuffs.crowdControlsFound = 0
    self._debuffs.allFound = 0

    self.states.BGOrb = nil -- TODO: move to _debuffs
end

local function HandleDebuffs(self, auraInfo, index)
    local auraInstanceID = auraInfo.auraInstanceID
    local name = auraInfo.name
    local icon = auraInfo.icon
    local count = auraInfo.applications
    local debuffType = auraInfo.dispelName or ""
    local expirationTime = auraInfo.expirationTime or 0
    local start = expirationTime - auraInfo.duration
    local duration = auraInfo.duration
    local source = auraInfo.sourceUnit
    local spellId = auraInfo.spellId
    -- local attribute = auraInfo.points[1] -- UnitAura:arg16

    local refreshing = false

    self._debuffs_indices[auraInstanceID] = index

    -- check Bleed
    debuffType = I.CheckDebuffType(debuffType, spellId)

    if duration then
        if Cell.vars.iconAnimation == "duration" then
            local timeIncreased = self._debuffs_cache[auraInstanceID] and (expirationTime - self._debuffs_cache[auraInstanceID] >= 0.5) or false
            local countIncreased = self._debuffs_count_cache[auraInstanceID] and (count > self._debuffs_count_cache[auraInstanceID]) or false
            refreshing = timeIncreased or countIncreased
        elseif Cell.vars.iconAnimation == "stack" then
            refreshing = self._debuffs_count_cache[auraInstanceID] and (count > self._debuffs_count_cache[auraInstanceID]) or false
        else
            refreshing = false
        end

        self._debuffs_cache[auraInstanceID] = expirationTime
        self._debuffs_count_cache[auraInstanceID] = count

        if enabledIndicators["debuffs"] and not Cell.vars.debuffBlacklist[spellId] then
            -- all debuffs / only dispellableByMe
            if not indicatorBooleans["debuffs"] or I.CanDispel(debuffType) then
                -- debuffs, may contain topDebuff and cc
                if self._debuffs.allFound <= indicatorNums["debuffs"]+indicatorNums["raidDebuffs"]+indicatorNums["crowdControls"] then
                    self._debuffs.allFound = self._debuffs.allFound + 1
                    if Cell.vars.bigDebuffs[spellId] then
                        self._debuffs_big[auraInstanceID] = refreshing
                    else
                        self._debuffs_normal[auraInstanceID] = refreshing
                    end
                end
            end
        end

        -- user created indicators
        I.UpdateCustomIndicators(self, auraInfo, refreshing)

        -- prepare raidDebuffs
        local order = I.GetDebuffOrder(name, spellId, count)
        if enabledIndicators["raidDebuffs"] and order then
            self._debuffs.raidDebuffsFound = true
            tinsert(self._debuffs_raid, auraInstanceID)
            self._debuffs_raid_refreshing[auraInstanceID] = refreshing
            self._debuffs_raid_orders[auraInstanceID] = order

            if not indicatorBooleans["raidDebuffs"] then -- glow all
                local glowType, glowOptions = I.GetDebuffGlow(name, spellId, count)
                if glowType and glowType ~= "None" then
                    self._debuffs_glow_current[glowType] = glowOptions
                    self._debuffs_glow_cache[glowType] = true
                end
            end
        end

        if enabledIndicators["dispels"] and debuffType and debuffType ~= "" then
            -- all dispels / only dispellableByMe
            if not indicatorBooleans["dispels"] or I.CanDispel(debuffType) then
                if Cell.vars.dispelBlacklist[spellId] then
                    -- no highlight
                    self._debuffs_dispel[debuffType] = false
                else
                    self._debuffs_dispel[debuffType] = true
                end
            end
        end

        -- crowdControls
        if enabledIndicators["crowdControls"] and I.IsCrowdControls(name, spellId) and self._debuffs.crowdControlsFound < indicatorNums["crowdControls"] then
            self._debuffs.crowdControlsFound = self._debuffs.crowdControlsFound + 1
            self._debuffs_cc[auraInstanceID] = true
            self.indicators.crowdControls[self._debuffs.crowdControlsFound]:SetCooldown(start, duration, debuffType, icon, count, refreshing)
        end

        -- resurrections: 图腾复生/复生
        if spellId == 255234 or spellId == 225080 then
            -- NOTE: this rez lasts longer than the debuff
            self._debuffs.resurrectionFound = true
            self.states.hasRezDebuff = true
        end

        -- BG orbs
        if spellId == 121164 then
            self.states.BGOrb = "blue"
        elseif spellId == 121175 then
            self.states.BGOrb = "purple"
        elseif spellId == 121176 then
            self.states.BGOrb = "green"
        elseif spellId == 121177 then
            self.states.BGOrb = "orange"
        end
    end
end

local function UnitButton_UpdateDebuffs(self)
    local unit = self.states.displayedUnit

    ResetDebuffVars(self)

    -- user created indicators
    I.ResetCustomIndicators(self, "debuff")

    ForEachAura(self, "HARMFUL", HandleDebuffs)

    if not self._debuffs.resurrectionFound then
        self.states.hasRezDebuff = nil
    end

    local startIndex = 1

    -- update raid debuffs
    -- if self._debuffs.raidDebuffsFound or cleuUnits[unit] then
    if self._debuffs.raidDebuffsFound then
        self.indicators.raidDebuffs:Show()

        -- cleuAuras
        -- local offset = 0
        -- if cleuUnits[unit] then
        --     offset = 1
        --     startIndex = startIndex + 1
        -- end

        -- sort indices
        -- NOTE: self._debuffs_raid_orders = { [auraInstanceID] = debuffOrder } used for sorting
        table.sort(self._debuffs_raid, function(a, b)
            return self._debuffs_raid_orders[a] < self._debuffs_raid_orders[b]
        end)

        -- show
        local topGlowType, topGlowOptions
        -- for i = 1+offset, indicatorNums["raidDebuffs"] do
        for i = 1, indicatorNums["raidDebuffs"] do
            if self._debuffs_raid[i] then -- self._debuffs_raid[i] -> auraInstanceID
                local auraInfo = GetAuraDataByAuraInstanceID(unit, self._debuffs_raid[i])
                if auraInfo then
                    self.indicators.raidDebuffs[i]:SetCooldown((auraInfo.expirationTime or 0) - auraInfo.duration, auraInfo.duration, auraInfo.dispelName or "", auraInfo.icon, auraInfo.applications, self._debuffs_raid_refreshing[self._debuffs_raid[i]])
                    self.indicators.raidDebuffs[i].index = self._debuffs_indices[self._debuffs_raid[i]] -- NOTE: for tooltip
                    startIndex = startIndex + 1
                    -- store debuffs auraInstanceIDs shown by raidDebuffs indicator
                    self._debuffs_raid_shown[self._debuffs_raid[i]] = true

                    if i == 1 then -- top
                        topGlowType, topGlowOptions = I.GetDebuffGlow(auraInfo.name, auraInfo.spellId, auraInfo.applications)
                    end
                end
            end
        end

        -- if cleuUnits[unit] then
        --     self.indicators.raidDebuffs[1]:SetCooldown(cleuUnits[unit][1], cleuUnits[unit][2], "cleu", cleuUnits[unit][3], 1)
        --     topGlowType, topGlowOptions = unpack(CellDB["cleuGlow"])
        -- end

        -- update raidDebuffs
        self.indicators.raidDebuffs:UpdateSize(startIndex - 1)
        for i = startIndex, 3 do
            self.indicators.raidDebuffs[i].index = nil
        end

        -- update glow
        if not indicatorBooleans["raidDebuffs"] then
            if topGlowType and topGlowType ~= "None" then
                -- to make sure top glow has highest priority
                self._debuffs_glow_current[topGlowType] = topGlowOptions
            end
            for t, o in pairs(self._debuffs_glow_current) do
                self.indicators.raidDebuffs:ShowGlow(t, o, true)
            end
            for t, _ in pairs(self._debuffs_glow_cache) do
                if not self._debuffs_glow_current[t] then
                    self.indicators.raidDebuffs:HideGlow(t)
                    self._debuffs_glow_cache[t] = nil
                end
            end
            wipe(self._debuffs_glow_current)
        else
            self.indicators.raidDebuffs:ShowGlow(topGlowType, topGlowOptions)
        end
    else
        self.indicators.raidDebuffs:Hide()
    end

    -- update debuffs
    startIndex = 1
    if enabledIndicators["debuffs"] then
        -- bigDebuffs first
        for auraInstanceID, refreshing in pairs(self._debuffs_big) do
            local auraInfo = GetAuraDataByAuraInstanceID(unit, auraInstanceID)
            if auraInfo and not (self._debuffs_raid_shown[auraInstanceID] or self._debuffs_cc[auraInstanceID]) and startIndex <= indicatorNums["debuffs"] then
                -- start, duration, debuffType, texture, count
                self.indicators.debuffs[startIndex]:SetCooldown((auraInfo.expirationTime or 0) - auraInfo.duration, auraInfo.duration, auraInfo.dispelName or "", auraInfo.icon, auraInfo.applications, refreshing, true)
                self.indicators.debuffs[startIndex].index = self._debuffs_indices[auraInstanceID] -- NOTE: for tooltip
                self.indicators.debuffs[startIndex].spellId = auraInfo.spellId -- NOTE: for blacklist
                startIndex = startIndex + 1
            end
        end
        -- then normal debuffs
        for auraInstanceID, refreshing in pairs(self._debuffs_normal) do
            local auraInfo = GetAuraDataByAuraInstanceID(unit, auraInstanceID)
            if auraInfo and not (self._debuffs_raid_shown[auraInstanceID] or self._debuffs_cc[auraInstanceID]) and startIndex <= indicatorNums["debuffs"] then
                -- start, duration, debuffType, texture, count
                self.indicators.debuffs[startIndex]:SetCooldown((auraInfo.expirationTime or 0) - auraInfo.duration, auraInfo.duration, auraInfo.dispelName or "", auraInfo.icon, auraInfo.applications, refreshing)
                self.indicators.debuffs[startIndex].index = self._debuffs_indices[auraInstanceID] -- NOTE: for tooltip
                self.indicators.debuffs[startIndex].spellId = auraInfo.spellId -- NOTE: for blacklist
                startIndex = startIndex + 1
            end
        end
    end

    -- update debuffs
    self.indicators.debuffs:UpdateSize(startIndex - 1)
    for i = startIndex, 10 do
        self.indicators.debuffs[i].index = nil
        self.indicators.debuffs[i].spellId = nil
    end

    -- update dispels
    self.indicators.dispels:SetDispels(self._debuffs_dispel)

    -- update crowdControls
    self.indicators.crowdControls:UpdateSize(self._debuffs.crowdControlsFound)

    -- user created indicators
    I.ShowCustomIndicators(self, "debuff")

    wipe(self._debuffs_indices)
    wipe(self._debuffs_normal)
    wipe(self._debuffs_big)
    wipe(self._debuffs_dispel)
    wipe(self._debuffs_cc)
    wipe(self._debuffs_raid)
    wipe(self._debuffs_raid_refreshing)
    wipe(self._debuffs_raid_orders)
    wipe(self._debuffs_raid_shown)
end

-------------------------------------------------
-- buffs
-------------------------------------------------
local function ResetBuffVars(self)
    self._buffs.defensiveFound = 0
    self._buffs.externalFound = 0
    self._buffs.allFound = 0
    self._buffs.tankActiveMitigationFound = false
    self._buffs.drinkingFound = false

    self.states.BGFlag = nil -- TODO: move to _buffs
end

local function HandleBuff(self, auraInfo)
    local unit = self.states.displayedUnit

    local auraInstanceID = auraInfo.auraInstanceID
    local name = auraInfo.name
    local icon = auraInfo.icon
    local count = auraInfo.applications
    -- local debuffType = auraInfo.isHarmful and auraInfo.dispelName
    local expirationTime = auraInfo.expirationTime or 0
    local start = expirationTime - auraInfo.duration
    local duration = auraInfo.duration
    local source = auraInfo.sourceUnit
    local spellId = auraInfo.spellId
    -- local attribute = auraInfo.points[1] -- UnitAura:arg16

    local refreshing = false

    if duration then
        if Cell.vars.iconAnimation == "duration" then
            local timeIncreased = self._buffs_cache[auraInstanceID] and (expirationTime - self._buffs_cache[auraInstanceID] >= 0.5) or false
            local countIncreased = self._buffs_count_cache[auraInstanceID] and (count > self._buffs_count_cache[auraInstanceID]) or false
            refreshing = timeIncreased or countIncreased
        elseif Cell.vars.iconAnimation == "stack" then
            refreshing = self._buffs_count_cache[auraInstanceID] and (count > self._buffs_count_cache[auraInstanceID]) or false
        else
            refreshing = false
        end

        self._buffs_cache[auraInstanceID] = expirationTime
        self._buffs_count_cache[auraInstanceID] = count

        -- defensiveCooldowns
        if enabledIndicators["defensiveCooldowns"] and I.IsDefensiveCooldown(name, spellId) and self._buffs.defensiveFound < indicatorNums["defensiveCooldowns"] then
            self._buffs.defensiveFound = self._buffs.defensiveFound + 1
            -- start, duration, debuffType, texture, count, refreshing
            self.indicators.defensiveCooldowns[self._buffs.defensiveFound]:SetCooldown(start, duration, nil, icon, count, refreshing)
        end

        -- externalCooldowns
        if enabledIndicators["externalCooldowns"] and I.IsExternalCooldown(name, spellId, source, unit) and self._buffs.externalFound < indicatorNums["externalCooldowns"] then
            self._buffs.externalFound = self._buffs.externalFound + 1
            -- start, duration, debuffType, texture, count, refreshing
            self.indicators.externalCooldowns[self._buffs.externalFound]:SetCooldown(start, duration, nil, icon, count, refreshing)
        end

        -- allCooldowns
        if enabledIndicators["allCooldowns"] and (I.IsExternalCooldown(name, spellId, source, unit) or I.IsDefensiveCooldown(name, spellId)) and self._buffs.allFound < indicatorNums["allCooldowns"] then
            self._buffs.allFound = self._buffs.allFound + 1
            -- start, duration, debuffType, texture, count, refreshing
            self.indicators.allCooldowns[self._buffs.allFound]:SetCooldown(start, duration, nil, icon, count, refreshing)
        end

        -- tankActiveMitigation
        if enabledIndicators["tankActiveMitigation"] and I.IsTankActiveMitigation(name) then
            self.indicators.tankActiveMitigation:SetCooldown(start, duration)
            self._buffs.tankActiveMitigationFound = true
        end

        -- drinking
        if enabledIndicators["statusText"] and I.IsDrinking(name) then
            if not self.indicators.statusText:GetStatus() then
                self.indicators.statusText:SetStatus("DRINKING")
                self.indicators.statusText:Show()
            end
            self._buffs.drinkingFound = true
        end

        -- user created indicators
        I.UpdateCustomIndicators(self, auraInfo, refreshing)

        -- check BG flags for statusIcon
        if spellId == 156621 then
            self.states.BGFlag = "alliance"
        elseif spellId == 156618 then
            self.states.BGFlag = "horde"
        end
    end
end

local function UnitButton_UpdateBuffs(self)
    local unit = self.states.displayedUnit

    -- user created indicators
    I.ResetCustomIndicators(self, "buff")

    ResetBuffVars(self)

    ForEachAura(self, "HELPFUL", HandleBuff)

    -- check Mirror Image
    if self._mirror_image and I.IsDefensiveCooldown(55342) then -- exists and enabled
        if self._buffs.defensiveFound < indicatorNums["defensiveCooldowns"] then
            self._buffs.defensiveFound = self._buffs.defensiveFound + 1
            self.indicators.defensiveCooldowns[self._buffs.defensiveFound]:SetCooldown(self._mirror_image, 40, nil, 135994, 0)
        end
        if self._buffs.allFound < indicatorNums["allCooldowns"] then
            self._buffs.allFound = self._buffs.allFound + 1
            self.indicators.allCooldowns[self._buffs.allFound]:SetCooldown(self._mirror_image, 40, nil, 135994, 0)
        end
    end

    -- check Mass Barrier (self)
    if self._mass_barrier and I.IsExternalCooldown(414660) then -- exists and enabled
        if self._buffs.externalFound < indicatorNums["externalCooldowns"] then
            self._buffs.externalFound = self._buffs.externalFound + 1
            self.indicators.externalCooldowns[self._buffs.externalFound]:SetCooldown(self._mass_barrier, 60, nil, self._mass_barrier_icon, 0)
        end
        if self._buffs.allFound < indicatorNums["allCooldowns"] then
            self._buffs.allFound = self._buffs.allFound + 1
            self.indicators.allCooldowns[self._buffs.allFound]:SetCooldown(self._mass_barrier, 60, nil, self._mass_barrier_icon, 0)
        end
    end

    -- update defensiveCooldowns
    self.indicators.defensiveCooldowns:UpdateSize(self._buffs.defensiveFound)

    -- update externalCooldowns
    self.indicators.externalCooldowns:UpdateSize(self._buffs.externalFound)

    -- update allCooldowns
    self.indicators.allCooldowns:UpdateSize(self._buffs.allFound)

    -- hide tankActiveMitigation
    if not self._buffs.tankActiveMitigationFound then
        self.indicators.tankActiveMitigation:Hide()
    end

    -- hide drinking
    if not self._buffs.drinkingFound and self.indicators.statusText:GetStatus() == "DRINKING" then
        -- self.indicators.statusText:Hide()
        self.indicators.statusText:SetStatus()
    end

    -- user created indicators
    I.ShowCustomIndicators(self, "buff")
end

-------------------------------------------------
-- aura tables
-------------------------------------------------
local function InitAuraTables(self)
    -- vars
    self._buffs = {}
    self._debuffs = {}

    -- for icon animation only
    self._buffs_cache = {}
    self._buffs_count_cache = {}
    self._debuffs_cache = {}
    self._debuffs_count_cache = {}

    -- debuffs
    self._debuffs_indices = {} -- [auraInstanceID] = index, for tooltips
    self._debuffs_normal = {} -- [auraInstanceID] = refreshing
    self._debuffs_big = {} -- [auraInstanceID] = refreshing
    self._debuffs_dispel = {} -- [debuffType] = true/false
    self._debuffs_cc = {} -- [auraInstanceID] = refreshing
    self._debuffs_raid = {} -- {id1, id2, ...}
    self._debuffs_raid_refreshing = {} -- [auraInstanceID] = refreshing
    self._debuffs_raid_orders = {} -- [auraInstanceID] = order
    self._debuffs_raid_shown = {} -- [auraInstanceID] = true, currently shown by raidDebuffs indicator
    self._debuffs_glow_current = {}
    self._debuffs_glow_cache = {}
end

local function ResetAuraTables(self)
    wipe(self._buffs_cache)
    wipe(self._buffs_count_cache)
    wipe(self._debuffs_cache)
    wipe(self._debuffs_count_cache)

    -- debuffs
    wipe(self._debuffs_indices)
    wipe(self._debuffs_normal)
    wipe(self._debuffs_big)
    wipe(self._debuffs_dispel)
    wipe(self._debuffs_cc)
    wipe(self._debuffs_raid)
    wipe(self._debuffs_raid_refreshing)
    wipe(self._debuffs_raid_orders)
    wipe(self._debuffs_raid_shown)

    -- raid debuffs glow
    wipe(self._debuffs_glow_current)
    wipe(self._debuffs_glow_cache)
    if self.indicators.raidDebuffs then
        self.indicators.raidDebuffs:HideGlow()
    end

    self._mirror_image = nil
    self._mass_barrier = nil
    self._mass_barrier_icon = nil
end

-------------------------------------------------
-- check auras using CLEU
-------------------------------------------------
local cleu = CreateFrame("Frame")
cleu:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

local function UpdateMirrorImage(b, event)
    if event == "SPELL_AURA_APPLIED" then
        b._mirror_image = GetTime()
    elseif event == "SPELL_AURA_REMOVED" then
        b._mirror_image = nil
    end
    UnitButton_UpdateBuffs(b)
end

local SelfBarriers = {
    [11426] = true, -- 寒冰护体 (self)
    [235313] = true, -- 烈焰护体 (self)
    [235450] = true, -- 棱光护体 (self)
}

local function UpdateMassBarrier(b, event)
    if event == "SPELL_CAST_SUCCESS" then
        b._mass_barrier = GetTime()
        local info = LGI:GetCachedInfo(b.states.guid)
        if info then
            if info.specId == 62 then -- Arcane
                b._mass_barrier_icon = 135991
            elseif info.specId == 63 then -- Fire
                b._mass_barrier_icon = 132221
            elseif info.specId == 64 then -- Frost
                b._mass_barrier_icon = 135988
            else
                b._mass_barrier_icon = 1723997
            end
        end
    elseif event == "SPELL_AURA_REMOVED" then
        b._mass_barrier = nil
        b._mass_barrier_icon = nil
    end
    UnitButton_UpdateBuffs(b)
end

cleu:SetScript("OnEvent", function()
    local _, subEvent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName = CombatLogGetCurrentEventInfo()

    -- mirror image
    if spellId == 55342 and F:IsFriend(sourceFlags) then
        F:HandleUnitButton("guid", sourceGUID, UpdateMirrorImage, subEvent)
    end

    -- mass barrier (self), SPELL_CAST_SUCCESS
    if spellId == 414660 and F:IsFriend(sourceFlags) then
        F:HandleUnitButton("guid", sourceGUID, UpdateMassBarrier, "SPELL_CAST_SUCCESS")
    end
    if (subEvent == "SPELL_AURA_REMOVED" or subEvent == "SPELL_AURA_REFRESH") and SelfBarriers[spellId] and F:IsFriend(sourceFlags) then
        F:HandleUnitButton("guid", sourceGUID, UpdateMassBarrier, "SPELL_AURA_REMOVED")
    end

    -- CLEU auras
    -- if I.CheckCleuAura(spellId) and F:IsFriend(destFlags) then
    --     local b1, b2 = F:GetUnitButtonByGUID(sourceGUID)
    --     if subEvent == "SPELL_AURA_APPLIED" then
    --         if b1 and b1.states.unit then
    --             cleuUnits[b1.states.unit] = {GetTime(), unpack(I.CheckCleuAura(spellId))}
    --             UnitButton_UpdateDebuffs(b1)
    --         end
    --         if b2 and b2.states.unit then
    --             cleuUnits[b2.states.unit] = {GetTime(), unpack(I.CheckCleuAura(spellId))}
    --             UnitButton_UpdateDebuffs(b2)
    --         end
    --     elseif subEvent == "SPELL_AURA_REMOVED" then
    --         if b1 and b1.states.unit then
    --             cleuUnits[b1.states.unit] = nil
    --             UnitButton_UpdateDebuffs(b1)
    --         end
    --         if b2 and b2.states.unit then
    --             cleuUnits[b2.states.unit] = nil
    --             UnitButton_UpdateDebuffs(b2)
    --         end
    --     end
    -- end
end)

-------------------------------------------------
-- functions
-------------------------------------------------
UnitButton_UpdateAuras = function(self, updateInfo)
    if not self._indicatorReady then return end

    local unit = self.states.displayedUnit
    if not unit then return end

    local buffsChanged, debuffsChanged

    if not updateInfo or updateInfo.isFullUpdate then
        wipe(self._buffs_cache)
        wipe(self._buffs_count_cache)
        wipe(self._debuffs_cache)
        wipe(self._debuffs_count_cache)
        buffsChanged = true
        debuffsChanged = true
    else
        if updateInfo.addedAuras then
            for _, aura in pairs(updateInfo.addedAuras) do
                if aura.isHelpful then buffsChanged = true end
                if aura.isHarmful then debuffsChanged = true end
            end
        end

        if updateInfo.updatedAuraInstanceIDs then
            for _, auraInstanceID in pairs(updateInfo.updatedAuraInstanceIDs) do
                if self._buffs_cache[auraInstanceID] then buffsChanged = true end
                if self._debuffs_cache[auraInstanceID] then debuffsChanged = true end
            end
        end

        if updateInfo.removedAuraInstanceIDs then
            for _, auraInstanceID in pairs(updateInfo.removedAuraInstanceIDs) do
                if self._buffs_cache[auraInstanceID] then
                    self._buffs_cache[auraInstanceID] = nil
                    self._buffs_count_cache[auraInstanceID] = nil
                    buffsChanged = true
                end
                if self._debuffs_cache[auraInstanceID] then
                    self._debuffs_cache[auraInstanceID] = nil
                    self._debuffs_count_cache[auraInstanceID] = nil
                    debuffsChanged = true
                end
            end
        end

        if Cell.loaded then
            if CellDB["general"]["alwaysUpdateBuffs"] then buffsChanged = true end
            if CellDB["general"]["alwaysUpdateDebuffs"] then debuffsChanged = true end
        end
    end

    if buffsChanged then UnitButton_UpdateBuffs(self) end
    if debuffsChanged then UnitButton_UpdateDebuffs(self) end
    I.UpdateStatusIcon(self)
end

local function UpdateUnitHealthState(self, diff)
    local unit = self.states.displayedUnit

    local health = UnitHealth(unit) + (diff or 0)
    local healthMax = UnitHealthMax(unit)
    health = min(health, healthMax) --! diff

    self.states.health = health
    self.states.healthMax = healthMax
    self.states.totalAbsorbs = UnitGetTotalAbsorbs(unit)

    if healthMax == 0 then
        self.states.healthPercent = 0
    else
        self.states.healthPercent = health / healthMax
    end

    self.states.wasDead = self.states.isDead
    self.states.isDead = health == 0
    if self.states.wasDead ~= self.states.isDead then
        UnitButton_UpdateStatusText(self)
        I.UpdateStatusIcon_Resurrection(self)
        if not self.states.isDead then
            self.states.hasSoulstone = nil
            I.UpdateStatusIcon(self)
        end
    end

    self.states.wasDeadOrGhost = self.states.isDeadOrGhost
    self.states.isDeadOrGhost = UnitIsDeadOrGhost(unit)
    if self.states.wasDeadOrGhost ~= self.states.isDeadOrGhost then
        I.UpdateStatusIcon_Resurrection(self)
        UnitButton_UpdateHealthColor(self)
    end

    if enabledIndicators["healthText"] and healthMax ~= 0 then
        if indicatorBooleans["healthText"] then
            if health == healthMax or self.states.isDeadOrGhost or self.states.isDead then
                self.indicators.healthText:Hide()
            else
                self.indicators.healthText:SetValue(health, healthMax, self.states.totalAbsorbs)
                self.indicators.healthText:Show()
            end
        else
            self.indicators.healthText:SetValue(health, healthMax, self.states.totalAbsorbs)
            self.indicators.healthText:Show()
        end
    else
        self.indicators.healthText:Hide()
    end
end

-------------------------------------------------
-- power filter funcs
-------------------------------------------------
local function GetRole(b)
    if b.states.role and b.states.role ~= "NONE" then
        return b.states.role
    end

    local info = LGI:GetCachedInfo(b.states.guid)
    if not info then return end
    return info.role
end

local function ShouldShowPowerBar(b)
    if not (b:IsVisible() or b.isPreview) then return end
    if not b.powerSize or b.powerSize == 0 then return end

    if not b.states.guid then
        return true
    end

    local class, role
    if b.states.inVehicle then
        class = "VEHICLE"
    elseif F:IsPlayer(b.states.guid) then
        class = b.states.class
        role = GetRole(b)
    elseif F:IsPet(b.states.guid) then
        class = "PET"
    elseif F:IsNPC(b.states.guid) then
        if UnitInPartyIsAI(b.states.unit) then
            class = b.states.class
            role = GetRole(b)
        else
            class = "NPC"
        end
    elseif F:IsVehicle(b.states.guid) then
        class = "VEHICLE"
    end

    if class and Cell.vars.currentLayoutTable then
        if type(Cell.vars.currentLayoutTable["powerFilters"][class]) == "boolean" then
            return Cell.vars.currentLayoutTable["powerFilters"][class]
        else
            if role then
                return Cell.vars.currentLayoutTable["powerFilters"][class][role]
            else
                return true -- show power if role not found
            end
        end
    end

    return true
end

local function ShowPowerBar(b)
    if b:IsVisible() and not b.isPreview then
        b:RegisterEvent("UNIT_POWER_FREQUENT")
        b:RegisterEvent("UNIT_MAXPOWER")
        b:RegisterEvent("UNIT_DISPLAYPOWER")
    end
    b.widgets.powerBar:Show()
    b.widgets.powerBarLoss:Show()
    b.widgets.gapTexture:Show()

    P:ClearPoints(b.widgets.healthBar)
    P:ClearPoints(b.widgets.powerBar)
    if b.orientation == "horizontal" or b.orientation == "vertical_health" then
        P:Point(b.widgets.healthBar, "TOPLEFT", b, "TOPLEFT", CELL_BORDER_SIZE, -CELL_BORDER_SIZE)
        P:Point(b.widgets.healthBar, "BOTTOMRIGHT", b, "BOTTOMRIGHT", -CELL_BORDER_SIZE, b.powerSize + CELL_BORDER_SIZE * 2)
        P:Point(b.widgets.powerBar, "TOPLEFT", b.widgets.healthBar, "BOTTOMLEFT", 0, -CELL_BORDER_SIZE)
        P:Point(b.widgets.powerBar, "BOTTOMRIGHT", b, "BOTTOMRIGHT", -CELL_BORDER_SIZE, CELL_BORDER_SIZE)
    else
        P:Point(b.widgets.healthBar, "TOPLEFT", b, "TOPLEFT", CELL_BORDER_SIZE, -CELL_BORDER_SIZE)
        P:Point(b.widgets.healthBar, "BOTTOMRIGHT", b, "BOTTOMRIGHT", -(b.powerSize + CELL_BORDER_SIZE * 2), CELL_BORDER_SIZE)
        P:Point(b.widgets.powerBar, "TOPLEFT", b.widgets.healthBar, "TOPRIGHT", CELL_BORDER_SIZE, 0)
        P:Point(b.widgets.powerBar, "BOTTOMRIGHT", b, "BOTTOMRIGHT", -CELL_BORDER_SIZE, CELL_BORDER_SIZE)
    end

    if b:IsVisible() then
        -- update now
        UnitButton_UpdatePowerMax(b)
        UnitButton_UpdatePower(b)
        UnitButton_UpdatePowerType(b)
    end
end

local function HidePowerBar(b)
    b:UnregisterEvent("UNIT_POWER_FREQUENT")
    b:UnregisterEvent("UNIT_MAXPOWER")
    b:UnregisterEvent("UNIT_DISPLAYPOWER")
    b.widgets.powerBar:Hide()
    b.widgets.powerBarLoss:Hide()
    b.widgets.gapTexture:Hide()

    P:ClearPoints(b.widgets.healthBar)
    P:Point(b.widgets.healthBar, "TOPLEFT", b, "TOPLEFT", CELL_BORDER_SIZE, -CELL_BORDER_SIZE)
    P:Point(b.widgets.healthBar, "BOTTOMRIGHT", b, "BOTTOMRIGHT", -CELL_BORDER_SIZE, CELL_BORDER_SIZE)
end

-------------------------------------------------
-- unit button functions
-------------------------------------------------
local function UnitButton_UpdateTarget(self)
    local unit = self.states.displayedUnit
    if not unit then return end

    if UnitIsUnit(unit, "target") then
        if highlightEnabled then self.widgets.targetHighlight:Show() end
    else
        self.widgets.targetHighlight:Hide()
    end
end


local function CheckVehicleRoot(self, petUnit)
    if not petUnit then return end

    local playerUnit = F:GetPlayerUnit(petUnit)

    local isRoot
    for i = 1, UnitVehicleSeatCount(playerUnit) do
        local controlType, occupantName, serverName, ejectable, canSwitchSeats = UnitVehicleSeatInfo(playerUnit, i)
        if UnitName(playerUnit) == occupantName then
            isRoot = controlType == "Root"
            break
        end
    end

    self.indicators.roleIcon:SetRole(isRoot and "VEHICLE-ROOT" or "VEHICLE")
end

UnitButton_UpdateRole = function(self)
    local unit = self.states.unit
    if not unit then return end

    local role = UnitGroupRolesAssigned(unit)
    self.states.role = role

    local roleIcon = self.indicators.roleIcon
    if enabledIndicators["roleIcon"] then

        roleIcon:SetRole(role)

        --! check vehicle root
        if self.states.guid and strfind(self.states.guid, "^Vehicle") then
            CheckVehicleRoot(self, unit)
        end
    else
        roleIcon:Hide()
    end
end

UnitButton_UpdateLeader = function(self, event)
    local unit = self.states.unit
    if not unit then return end

    local leaderIcon = self.indicators.leaderIcon

    if enabledIndicators["leaderIcon"] then
        if indicatorBooleans["leaderIcon"] and (InCombatLockdown() or event == "PLAYER_REGEN_DISABLED") then
            leaderIcon:Hide()
            return
        end

        local isLeader = UnitIsGroupLeader(unit)
        self.states.isLeader = isLeader
        local isAssistant = UnitIsGroupAssistant(unit) and IsInRaid()
        self.states.isAssistant = isAssistant

        leaderIcon:SetIcon(isLeader, isAssistant)
    else
        leaderIcon:Hide()
    end
end

local function UnitButton_UpdatePlayerRaidIcon(self)
    local unit = self.states.displayedUnit
    if not unit then return end

    local playerRaidIcon = self.indicators.playerRaidIcon

    local index = GetRaidTargetIndex(unit)

    if enabledIndicators["playerRaidIcon"] then
        if index then
            SetRaidTargetIconTexture(playerRaidIcon.tex, index)
            playerRaidIcon:Show()
        else
            playerRaidIcon:Hide()
        end
    else
        playerRaidIcon:Hide()
    end
end

local function UnitButton_UpdateTargetRaidIcon(self)
    local unit = self.states.displayedUnit
    if not unit then return end

    local targetRaidIcon = self.indicators.targetRaidIcon

    local index = GetRaidTargetIndex(unit.."target")

    if enabledIndicators["targetRaidIcon"] then
        if index then
            SetRaidTargetIconTexture(targetRaidIcon.tex, index)
            targetRaidIcon:Show()
        else
            targetRaidIcon:Hide()
        end
    else
        targetRaidIcon:Hide()
    end
end

local function UnitButton_UpdateReadyCheck(self)
    local unit = self.states.unit
    if not unit then return end

    local status = GetReadyCheckStatus(unit)
    self.states.readyCheckStatus = status

    if status then
        -- self.widgets.readyCheckHighlight:SetVertexColor(unpack(READYCHECK_STATUS[status].c))
        -- self.widgets.readyCheckHighlight:Show()
        self.indicators.readyCheckIcon:SetStatus(status)
    else
        -- self.widgets.readyCheckHighlight:Hide()
        self.indicators.readyCheckIcon:Hide()
    end
end

local function UnitButton_FinishReadyCheck(self)
    if self.states.readyCheckStatus == "waiting" then
        -- self.widgets.readyCheckHighlight:SetVertexColor(unpack(READYCHECK_STATUS.notready.c))
        self.indicators.readyCheckIcon:SetStatus("notready")
    end
    C_Timer.After(6, function()
        -- self.widgets.readyCheckHighlight:Hide()
        self.indicators.readyCheckIcon:Hide()
    end)
end

local function UnitButton_UpdatePowerText(self)
    if enabledIndicators["powerText"] and self.states.powerMax and self.states.power then
        if indicatorBooleans["powerText"] then
            if self.states.power == self.states.powerMax or self.states.power == 0 then
                self.indicators.powerText:Hide()
            else
                self.indicators.powerText:SetValue(self.states.power, self.states.powerMax)
                self.indicators.powerText:Show()
            end
        else
            self.indicators.powerText:SetValue(self.states.power, self.states.powerMax)
            self.indicators.powerText:Show()
        end
    else
        self.indicators.powerText:Hide()
    end
end

UnitButton_UpdatePowerTextColor = function(self)
    local unit = self.states.displayedUnit
    if not unit then return end

    if enabledIndicators["powerText"] then
        if indicatorColors["powerText"][1] == "power_color" then
            self.indicators.powerText:SetColor(F:GetPowerColor(unit))
        elseif indicatorColors["powerText"][1] == "class_color" then
            self.indicators.powerText:SetColor(F:GetUnitClassColor(unit))
        else
            self.indicators.powerText:SetColor(unpack(indicatorColors["powerText"][2]))
        end
    end
end

UnitButton_UpdatePowerMax = function(self)
    local unit = self.states.displayedUnit
    if not unit then return end

    self.states.powerMax = UnitPowerMax(unit)
    if self.states.powerMax < 0 then self.states.powerMax = 0 end

    if barAnimationType == "Smooth" then
        self.widgets.powerBar:SetMinMaxSmoothedValue(0, self.states.powerMax)
    else
        self.widgets.powerBar:SetMinMaxValues(0, self.states.powerMax)
    end

    UnitButton_UpdatePowerText(self)
end

UnitButton_UpdatePower = function(self)
    local unit = self.states.displayedUnit
    if not unit then return end

    self.states.power = UnitPower(unit)

    self.widgets.powerBar:SetBarValue(self.states.power)

    UnitButton_UpdatePowerText(self)
end

UnitButton_UpdatePowerType = function(self)
    local unit = self.states.displayedUnit
    if not unit then return end

    local r, g, b, lossR, lossG, lossB
    local a = Cell.loaded and CellDB["appearance"]["lossAlpha"] or 1

    if not UnitIsConnected(unit) then
        r, g, b = 0.4, 0.4, 0.4
        lossR, lossG, lossB = 0.4, 0.4, 0.4
    else
        r, g, b, lossR, lossG, lossB, self.states.powerType = F:GetPowerBarColor(unit, self.states.class)
    end

    self.widgets.powerBar:SetStatusBarColor(r, g, b)
    self.widgets.powerBarLoss:SetVertexColor(lossR, lossG, lossB)

    UnitButton_UpdatePowerTextColor(self)
end

local function UnitButton_UpdateHealthMax(self)
    local unit = self.states.displayedUnit
    if not unit then return end

    UpdateUnitHealthState(self)

    if barAnimationType == "Smooth" then
        self.widgets.healthBar:SetMinMaxSmoothedValue(0, self.states.healthMax)
    else
        self.widgets.healthBar:SetMinMaxValues(0, self.states.healthMax)
    end

    if Cell.vars.useGradientColor then
        UnitButton_UpdateHealthColor(self)
    end
end

local function UnitButton_UpdateHealth(self, diff)
    local unit = self.states.displayedUnit
    if not unit then return end

    UpdateUnitHealthState(self, diff)
    local healthPercent = self.states.healthPercent

    if barAnimationType == "Flash" then
        self.widgets.healthBar:SetValue(self.states.health)
        local diff = healthPercent - (self.states.healthPercentOld or healthPercent)
        if diff >= 0 then
            B:HideFlash(self)
        elseif diff <= -0.05 and diff >= -1 then --! player (just joined) UnitHealthMax(unit) may be 1 ====> diff == -maxHealth
            B:ShowFlash(self, abs(diff))
        end
    else
        self.widgets.healthBar:SetBarValue(self.states.health)
    end

    if Cell.vars.useGradientColor then
        UnitButton_UpdateHealthColor(self)
    end

    self.states.healthPercentOld = healthPercent

    if enabledIndicators["healthThresholds"] then
        self.indicators.healthThresholds:CheckThreshold(healthPercent)
    else
        self.indicators.healthThresholds:Hide()
    end

    if CELL_FADE_OUT_HEALTH_PERCENT then
        if self.states.inRange and healthPercent < CELL_FADE_OUT_HEALTH_PERCENT then
            A:FrameFadeIn(self, 0.25, self:GetAlpha(), 1)
        else
            A:FrameFadeOut(self, 0.25, self:GetAlpha(), CellDB["appearance"]["outOfRangeAlpha"])
        end
    end
end

local function UnitButton_UpdateHealPrediction(self)
    if not predictionEnabled then
        self.widgets.incomingHeal:Hide()
        return
    end

    local unit = self.states.displayedUnit
    if not unit then return end

    local value = UnitGetIncomingHeals(unit) or 0
    if value == 0 then
        self.widgets.incomingHeal:Hide()
        return
    end

    UpdateUnitHealthState(self)

    self.widgets.incomingHeal:SetValue(value / self.states.healthMax, self.states.healthPercent)
end

UnitButton_UpdateShieldAbsorbs = function(self)
    local unit = self.states.displayedUnit
    if not unit then return end

    UpdateUnitHealthState(self)

    if self.states.totalAbsorbs > 0 then
        local shieldPercent = self.states.totalAbsorbs / self.states.healthMax

        if enabledIndicators["shieldBar"] then
            if indicatorBooleans["shieldBar"] then
                -- onlyShowOvershields
                local overshieldPercent = (self.states.totalAbsorbs + self.states.health - self.states.healthMax) / self.states.healthMax
                if overshieldPercent > 0 then
                    self.indicators.shieldBar:Show()
                    self.indicators.shieldBar:SetValue(overshieldPercent)
                else
                    self.indicators.shieldBar:Hide()
                end
            else
                self.indicators.shieldBar:Show()
                self.indicators.shieldBar:SetValue(shieldPercent)
            end
        else
            self.indicators.shieldBar:Hide()
        end

        self.widgets.shieldBar:SetValue(shieldPercent, self.states.healthPercent)
    else
        self.indicators.shieldBar:Hide()
        self.widgets.shieldBar:Hide()
        self.widgets.overShieldGlow:Hide()
        self.widgets.shieldBarR:Hide()
        self.widgets.overShieldGlowR:Hide()
    end
end

local function UnitButton_UpdateHealAbsorbs(self)
    if not absorbEnabled then
        self.widgets.absorbsBar:Hide()
        self.widgets.overAbsorbGlow:Hide()
        return
    end

    local unit = self.states.displayedUnit
    if not unit then return end

    local value = UnitGetTotalHealAbsorbs(unit)
    if value > 0 then
        UpdateUnitHealthState(self)

        local absorbsPercent = value / self.states.healthMax
        self.widgets.absorbsBar:SetValue(absorbsPercent, self.states.healthPercent)
    else
        self.widgets.absorbsBar:Hide()
        self.widgets.overAbsorbGlow:Hide()
    end
end

local function UnitButton_UpdateThreat(self)
    local unit = self.states.displayedUnit
    if not unit or not UnitExists(unit) then return end

    local status = UnitThreatSituation(unit)
    if status and status >= 2 then
        if enabledIndicators["aggroBlink"] then
            self.indicators.aggroBlink:ShowAggro(GetThreatStatusColor(status))
        end
        if enabledIndicators["aggroBorder"] then
            self.indicators.aggroBorder:ShowAggro(GetThreatStatusColor(status))
        end
    else
        self.indicators.aggroBlink:Hide()
        self.indicators.aggroBorder:Hide()
    end
end

local function UnitButton_UpdateThreatBar(self)
    if not enabledIndicators["aggroBar"] then
        self.indicators.aggroBar:Hide()
        return
    end

    local unit = self.states.displayedUnit
    if not unit or not UnitExists(unit) then return end

    -- isTanking, status, scaledPercentage, rawPercentage, threatValue = UnitDetailedThreatSituation(unit, mobUnit)
    local _, status, scaledPercentage, rawPercentage = UnitDetailedThreatSituation(unit, "target")
    if status then
        self.indicators.aggroBar:Show()
        self.indicators.aggroBar:SetSmoothedValue(scaledPercentage)
        self.indicators.aggroBar:SetStatusBarColor(GetThreatStatusColor(status))
    else
        self.indicators.aggroBar:Hide()
    end
end

-- UNIT_IN_RANGE_UPDATE: unit, inRange
local function UnitButton_UpdateInRange(self, ir)
    local unit = self.states.displayedUnit
    if not unit then return end

    local inRange = F:IsInRange(unit)

    self.states.inRange = inRange
    if Cell.loaded then
        if self.states.inRange ~= self.states.wasInRange then
            if inRange then
                if CELL_FADE_OUT_HEALTH_PERCENT then
                    if not self.states.healthPercent or self.states.healthPercent < CELL_FADE_OUT_HEALTH_PERCENT then
                        A:FrameFadeIn(self, 0.25, self:GetAlpha(), 1)
                    else
                        A:FrameFadeOut(self, 0.25, self:GetAlpha(), CellDB["appearance"]["outOfRangeAlpha"])
                    end
                else
                    A:FrameFadeIn(self, 0.25, self:GetAlpha(), 1)
                end
            else
                A:FrameFadeOut(self, 0.25, self:GetAlpha(), CellDB["appearance"]["outOfRangeAlpha"])
            end
        end
        self.states.wasInRange = inRange
        -- self:SetAlpha(inRange and 1 or CellDB["appearance"]["outOfRangeAlpha"])
    end
end

local function UnitButton_UpdateVehicleStatus(self)
    local unit = self.states.unit
    if not unit then return end

    if UnitHasVehicleUI(unit) then -- or UnitInVehicle(unit) or UnitUsingVehicle(unit) then
        self.states.inVehicle = true
        if unit == "player" then
            self.states.displayedUnit = "vehicle"
        else
            -- local prefix, id, suffix = strmatch(unit, "([^%d]+)([%d]*)(.*)")
            local prefix, id = strmatch(unit, "([^%d]+)([%d]+)")
            self.states.displayedUnit = prefix.."pet"..id
        end
        self.indicators.nameText:UpdateVehicleName()
    else
        self.states.inVehicle = nil
        self.states.displayedUnit = self.states.unit
        self.indicators.nameText.vehicle:SetText("")
    end

    if Cell.loaded then
        if ShouldShowPowerBar(self) then
            ShowPowerBar(self)
        else
            HidePowerBar(self)
        end
    end
end

UnitButton_UpdateStatusText = function(self)
    local statusText = self.indicators.statusText
    if not enabledIndicators["statusText"] then
        -- statusText:Hide()
        statusText:SetStatus()
        return
    end

    local unit = self.states.unit
    if not unit then return end

    self.states.guid = UnitGUID(unit) -- update!
    if not self.states.guid then return end

    if not UnitIsConnected(unit) and UnitIsPlayer(unit) then
        statusText:Show()
        statusText:SetStatus("OFFLINE")
        statusText:ShowTimer()
    elseif UnitIsAFK(unit) then
        statusText:Show()
        statusText:SetStatus("AFK")
        statusText:ShowTimer()
    elseif UnitIsFeignDeath(unit) then
        statusText:Show()
        statusText:SetStatus("FEIGN")
        statusText:HideTimer(true)
    elseif UnitIsDeadOrGhost(unit) then
        statusText:Show()
        statusText:HideTimer(true)
        if UnitIsGhost(unit) then
            statusText:SetStatus("GHOST")
        else
            statusText:SetStatus("DEAD")
        end
    elseif C_IncomingSummon.HasIncomingSummon(unit) then
        statusText:Show()
        statusText:HideTimer()
        local status = C_IncomingSummon.IncomingSummonStatus(unit)
        if status == Enum.SummonStatus.Pending then
            statusText:SetStatus("PENDING")
        elseif status == Enum.SummonStatus.Accepted then
            statusText:SetStatus("ACCEPTED")
            C_Timer.After(6, function() UnitButton_UpdateStatusText(self) end)
        elseif status == Enum.SummonStatus.Declined then
            statusText:SetStatus("DECLINED")
            C_Timer.After(6, function() UnitButton_UpdateStatusText(self) end)
        end
    elseif statusText:GetStatus() == "DRINKING" then
        -- update colors
        statusText:Show()
        statusText:SetStatus("DRINKING")
    else
        -- statusText:Hide()
        statusText:HideTimer(true)
        statusText:SetStatus()
    end
end

local function UnitButton_UpdateName(self)
    local unit = self.states.unit
    if not unit then return end

    self.states.name = UnitName(unit)
    self.states.fullName = F:UnitFullName(unit)
    self.states.class = UnitClassBase(unit)
    self.states.guid = UnitGUID(unit)
    self.states.isPlayer = UnitIsPlayer(unit)

    self.indicators.nameText:UpdateName()
end

UnitButton_UpdateNameTextColor = function(self)
    local unit = self.states.unit
    if not unit then return end

    if enabledIndicators["nameText"] then
        if indicatorColors["nameText"][1] == "class_color" or not UnitIsConnected(unit)
        or ((UnitIsPlayer(unit) or UnitInPartyIsAI(unit)) and UnitIsCharmed(unit)) then
            self.indicators.nameText:SetColor(F:GetUnitClassColor(unit))
        else
            self.indicators.nameText:SetColor(unpack(indicatorColors["nameText"][2]))
        end
    end
end

UnitButton_UpdateHealthTextColor = function(self)
    local unit = self.states.unit
    if not unit then return end

    if enabledIndicators["healthText"] then
        if indicatorColors["healthText"][1] == "class_color" then
            self.indicators.healthText:SetColor(F:GetUnitClassColor(unit))
        else
            self.indicators.healthText:SetColor(unpack(indicatorColors["healthText"][2]))
        end
    end
end

UnitButton_UpdateHealthColor = function(self)
    local unit = self.states.unit
    if not unit then return end

    self.states.class = UnitClassBase(unit) --! update class

    local barR, barG, barB
    local lossR, lossG, lossB
    local barA, lossA = 1, 1

    if Cell.loaded then
        barA =  CellDB["appearance"]["barAlpha"]
        lossA =  CellDB["appearance"]["lossAlpha"]
    end

    if UnitIsPlayer(unit) or UnitInPartyIsAI(unit) then -- player
        if not UnitIsConnected(unit) then
            barR, barG, barB = 0.4, 0.4, 0.4
            lossR, lossG, lossB = 0.4, 0.4, 0.4
        elseif UnitIsCharmed(unit) then
            barR, barG, barB, barA = 0.5, 0, 1, 1
            lossR, lossG, lossB, lossA = barR*0.2, barG*0.2, barB*0.2, 1
        elseif self.states.inVehicle then
            barR, barG, barB, lossR, lossG, lossB = F:GetHealthBarColor(self.states.healthPercent, self.states.isDeadOrGhost or self.states.isDead, 0, 1, 0.2)
        else
            barR, barG, barB, lossR, lossG, lossB = F:GetHealthBarColor(self.states.healthPercent, self.states.isDeadOrGhost or self.states.isDead, F:GetClassColor(self.states.class))
        end
    elseif F:IsPet(self.states.guid) then -- pet
        barR, barG, barB, lossR, lossG, lossB = F:GetHealthBarColor(self.states.healthPercent, self.states.isDeadOrGhost or self.states.isDead, 0.5, 0.5, 1)
    else -- npc
        barR, barG, barB, lossR, lossG, lossB = F:GetHealthBarColor(self.states.healthPercent, self.states.isDeadOrGhost or self.states.isDead, 0, 1, 0.2)
    end

    -- local r, g, b = RAID_CLASS_COLORS["DEATHKNIGHT"]:GetRGB()
    self.widgets.healthBar:SetStatusBarColor(barR, barG, barB, barA)
    self.widgets.healthBarLoss:SetVertexColor(lossR, lossG, lossB, lossA)

    if Cell.loaded and CellDB["appearance"]["healPrediction"][2] then
        self.widgets.incomingHeal:SetVertexColor(CellDB["appearance"]["healPrediction"][3][1], CellDB["appearance"]["healPrediction"][3][2], CellDB["appearance"]["healPrediction"][3][3], CellDB["appearance"]["healPrediction"][3][4])
    else
        self.widgets.incomingHeal:SetVertexColor(barR, barG, barB, 0.4)
    end
end

-------------------------------------------------
-- cleu health updater
-------------------------------------------------
local cleuHealthUpdater = CreateFrame("Frame", "CellCleuHealthUpdater")
cleuHealthUpdater:SetScript("OnEvent", function()
    local _, subEvent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22 = CombatLogGetCurrentEventInfo()

    if not F:IsFriend(destFlags) then return end

    local diff
    if subEvent == "SPELL_HEAL" or subEvent == "SPELL_PERIODIC_HEAL" then
        -- spellId, spellName, spellSchool, amount, overhealing, absorbed, critical
        diff = arg15
    elseif subEvent == "SPELL_DAMAGE" or subEvent == "SPELL_PERIODIC_DAMAGE" then
        -- spellId, spellName, spellSchool, amount, overhealing, absorbed, critical
        diff = -arg15
    elseif subEvent == "SWING_DAMAGE" then
        -- amount
        diff = -arg12
    elseif subEvent == "RANGE_DAMAGE" then
        -- spellId, spellName, spellSchool, amount
        diff = -arg15
    elseif subEvent == "ENVIRONMENTAL_DAMAGE" then
        -- environmentalType, amount
        diff = -arg13
    end

    if diff and diff ~= 0 then
        F:HandleUnitButton("guid", destGUID, UnitButton_UpdateHealth, diff)
    end
end)

local function UpdateCLEU()
    if CellDB["general"]["useCleuHealthUpdater"] then
        cleuHealthUpdater:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    else
        cleuHealthUpdater:UnregisterAllEvents()
    end
end
Cell:RegisterCallback("UpdateCLEU", "UnitButton_UpdateCLEU", UpdateCLEU)

-------------------------------------------------
-- translit names
-------------------------------------------------
Cell:RegisterCallback("TranslitNames", "UnitButton_TranslitNames", function()
    F:IterateAllUnitButtons(function(b)
        UnitButton_UpdateName(b)
    end, true)
end)

-------------------------------------------------
-- update all
-------------------------------------------------
UnitButton_UpdateAll = function(self)
    if not self:IsVisible() then return end

    -- print(GetTime(), "UpdateAll", self:GetName())

    UnitButton_UpdateVehicleStatus(self)
    UnitButton_UpdateName(self)
    UnitButton_UpdateNameTextColor(self)
    UnitButton_UpdateHealthTextColor(self)
    UnitButton_UpdateHealthMax(self)
    UnitButton_UpdateHealth(self)
    UnitButton_UpdateHealPrediction(self)
    UnitButton_UpdateStatusText(self)
    UnitButton_UpdateHealthColor(self)
    UnitButton_UpdateTarget(self)
    UnitButton_UpdatePlayerRaidIcon(self)
    UnitButton_UpdateTargetRaidIcon(self)
    UnitButton_UpdateShieldAbsorbs(self)
    UnitButton_UpdateHealAbsorbs(self)
    UnitButton_UpdateInRange(self)
    UnitButton_UpdateRole(self)
    UnitButton_UpdateLeader(self)
    UnitButton_UpdateReadyCheck(self)
    UnitButton_UpdateThreat(self)
    UnitButton_UpdateThreatBar(self)
    -- UnitButton_UpdateStatusIcon(self)
    I.UpdateStatusIcon_Resurrection(self)

    if Cell.loaded and self._powerBarUpdateRequired then
        self._powerBarUpdateRequired = nil
        if ShouldShowPowerBar(self) then
            ShowPowerBar(self)
        else
            HidePowerBar(self)
        end
    else
        UnitButton_UpdatePowerType(self)
        UnitButton_UpdatePowerMax(self)
        UnitButton_UpdatePower(self)
    end

    UnitButton_UpdateAuras(self)
end

-------------------------------------------------
-- unit button events
-------------------------------------------------
local function UnitButton_RegisterEvents(self)
    -- self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")

    self:RegisterEvent("UNIT_HEALTH")
    self:RegisterEvent("UNIT_MAXHEALTH")

    self:RegisterEvent("UNIT_POWER_FREQUENT")
    self:RegisterEvent("UNIT_MAXPOWER")
    self:RegisterEvent("UNIT_DISPLAYPOWER")

    self:RegisterEvent("UNIT_AURA")

    self:RegisterEvent("UNIT_HEAL_PREDICTION")
    self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
    self:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")

    self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
    self:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
    self:RegisterEvent("UNIT_ENTERED_VEHICLE")
    self:RegisterEvent("UNIT_EXITED_VEHICLE")

    self:RegisterEvent("INCOMING_SUMMON_CHANGED")
    self:RegisterEvent("UNIT_FLAGS") -- afk
    self:RegisterEvent("UNIT_FACTION") -- mind control

    self:RegisterEvent("UNIT_CONNECTION") -- offline
    self:RegisterEvent("PLAYER_FLAGS_CHANGED") -- afk
    self:RegisterEvent("UNIT_NAME_UPDATE") -- unknown target
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA") --? update status text

    -- self:RegisterEvent("PARTY_LEADER_CHANGED") -- GROUP_ROSTER_UPDATE
    -- self:RegisterEvent("PLAYER_ROLES_ASSIGNED") -- GROUP_ROSTER_UPDATE
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")

    self:RegisterEvent("PLAYER_TARGET_CHANGED")

    if Cell.loaded then
        if enabledIndicators["playerRaidIcon"] then
            self:RegisterEvent("RAID_TARGET_UPDATE")
        end
    else
        self:RegisterEvent("RAID_TARGET_UPDATE")
    end
    if Cell.loaded then
        if enabledIndicators["targetRaidIcon"] then
            self:RegisterEvent("UNIT_TARGET")
        end
    else
        self:RegisterEvent("UNIT_TARGET")
    end

    self:RegisterEvent("READY_CHECK")
    self:RegisterEvent("READY_CHECK_FINISHED")
    self:RegisterEvent("READY_CHECK_CONFIRM")

    -- self:RegisterEvent("UNIT_PHASE") -- warmode, traditional sources of phasing such as progress through quest chains
    -- self:RegisterEvent("PARTY_MEMBER_DISABLE")
    -- self:RegisterEvent("PARTY_MEMBER_ENABLE")
    -- self:RegisterEvent("INCOMING_RESURRECT_CHANGED")

    -- self:RegisterEvent("VOICE_CHAT_CHANNEL_ACTIVATED")
    -- self:RegisterEvent("VOICE_CHAT_CHANNEL_DEACTIVATED")

    -- self:RegisterEvent("UNIT_PET")
    self:RegisterEvent("UNIT_PORTRAIT_UPDATE") -- pet summoned far away

    --! OnShow时立即执行，但UpdateIndicators可能并未执行完毕，导致在ResetCustomIndicators过程中指示器发生变化，进而报错
    local success, result = pcall(UnitButton_UpdateAll, self)
    if not success then
        F:Debug("UnitButton_UpdateAll |cffff0000FAILED:|r", self:GetName(), result)
    end
    -- if not pcall(UnitButton_UpdateAll, self) then
    --     C_Timer.After(1, function()
    --         UnitButton_UpdateAuras(self)
    --     end)
    -- end
end

local function UnitButton_UnregisterEvents(self)
    self:UnregisterAllEvents()
end

local function UnitButton_OnEvent(self, event, unit, arg)
    if unit and (self.states.displayedUnit == unit or self.states.unit == unit) then
        if  event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE" or event == "UNIT_CONNECTION" then
            self._updateRequired = 1
            self._powerBarUpdateRequired = 1

        elseif event == "UNIT_NAME_UPDATE" then
            UnitButton_UpdateName(self)
            UnitButton_UpdateNameTextColor(self)
            UnitButton_UpdateHealthColor(self)
            UnitButton_UpdateHealthTextColor(self)
            UnitButton_UpdatePowerTextColor(self)

        elseif event == "UNIT_MAXHEALTH" then
            UnitButton_UpdateHealthMax(self)
            UnitButton_UpdateHealth(self)
            UnitButton_UpdateHealPrediction(self)
            UnitButton_UpdateShieldAbsorbs(self)
            UnitButton_UpdateHealAbsorbs(self)

        elseif event == "UNIT_HEALTH" then
            UnitButton_UpdateHealth(self)
            UnitButton_UpdateHealPrediction(self)
            UnitButton_UpdateShieldAbsorbs(self)
            UnitButton_UpdateHealAbsorbs(self)
            -- UnitButton_UpdateStatusText(self)

        elseif event == "UNIT_HEAL_PREDICTION" then
            UnitButton_UpdateHealPrediction(self)

        elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
            UnitButton_UpdateShieldAbsorbs(self)

        elseif event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
            UnitButton_UpdateHealAbsorbs(self)

        elseif event == "UNIT_MAXPOWER" then
            UnitButton_UpdatePowerMax(self)
            UnitButton_UpdatePower(self)

        elseif event == "UNIT_POWER_FREQUENT" then
            UnitButton_UpdatePower(self)

        elseif event == "UNIT_DISPLAYPOWER" then
            UnitButton_UpdatePowerMax(self)
            UnitButton_UpdatePower(self)
            UnitButton_UpdatePowerType(self)

        elseif event == "UNIT_AURA" then
            UnitButton_UpdateAuras(self, arg)

        -- elseif event == "UNIT_IN_RANGE_UPDATE" then
        --     UnitButton_UpdateInRange(self, arg)

        elseif event == "UNIT_TARGET" then
            UnitButton_UpdateTargetRaidIcon(self)

        elseif event == "PLAYER_FLAGS_CHANGED" or event == "UNIT_FLAGS" or event == "INCOMING_SUMMON_CHANGED" then
            -- if CELL_SUMMON_ICONS_ENABLED then UnitButton_UpdateStatusIcon(self) end
            UnitButton_UpdateStatusText(self)

        elseif event == "UNIT_FACTION" then -- mind control
            UnitButton_UpdateNameTextColor(self)
            UnitButton_UpdateHealthColor(self)

        elseif event == "UNIT_THREAT_SITUATION_UPDATE" then
            UnitButton_UpdateThreat(self)

        -- elseif event == "INCOMING_RESURRECT_CHANGED" or event == "UNIT_PHASE" or event == "PARTY_MEMBER_DISABLE" or event == "PARTY_MEMBER_ENABLE" then
            -- UnitButton_UpdateStatusIcon(self)

        elseif event == "READY_CHECK_CONFIRM" then
            UnitButton_UpdateReadyCheck(self)

        elseif event == "UNIT_PORTRAIT_UPDATE" then -- pet summoned far away
            if self.states.healthMax == 0 then
                self._updateRequired = 1
                self._powerBarUpdateRequired = 1
            end
        end

    else
        if event == "GROUP_ROSTER_UPDATE" then
            self._updateRequired = 1
            self._powerBarUpdateRequired = 1

        elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
            UnitButton_UpdateLeader(self, event)

        elseif event == "PLAYER_TARGET_CHANGED" then
            UnitButton_UpdateTarget(self)
            UnitButton_UpdateThreatBar(self)
            if self:GetAttribute("updateOnTargetChanged") then
                UnitButton_UpdateAll(self)
            end

        elseif event == "UNIT_THREAT_LIST_UPDATE" then
            UnitButton_UpdateThreatBar(self)

        elseif event == "RAID_TARGET_UPDATE" then
            UnitButton_UpdatePlayerRaidIcon(self)
            UnitButton_UpdateTargetRaidIcon(self)

        elseif event == "READY_CHECK" then
            UnitButton_UpdateReadyCheck(self)

        elseif event == "READY_CHECK_FINISHED" then
            UnitButton_FinishReadyCheck(self)

        elseif event == "ZONE_CHANGED_NEW_AREA" then
            -- F:Debug("|cffbbbbbb=== ZONE_CHANGED_NEW_AREA ===")
            -- self._updateRequired = 1
            UnitButton_UpdateStatusText(self)

        -- elseif event == "VOICE_CHAT_CHANNEL_ACTIVATED" or event == "VOICE_CHAT_CHANNEL_DEACTIVATED" then
        -- 	VOICE_CHAT_CHANNEL_MEMBER_SPEAKING_STATE_CHANGED
        end
    end
end

local timer
local function EnterLeaveInstance()
    if timer then timer:Cancel() timer=nil end
    timer = C_Timer.NewTimer(1, function()
        F:Debug("|cffff1111*** EnterLeaveInstance:|r UnitButton_UpdateAll")
        F:IterateAllUnitButtons(UnitButton_UpdateAll, true)
        timer = nil
    end)
end
Cell:RegisterCallback("EnterInstance", "UnitButton_EnterInstance", EnterLeaveInstance)
Cell:RegisterCallback("LeaveInstance", "UnitButton_LeaveInstance", EnterLeaveInstance)

local function UnitButton_OnAttributeChanged(self, name, value)
    if name == "unit" then
        if not value or value ~= self.states.unit then
            -- NOTE: when unitId for this button changes
            if self.__unitGuid then -- self.__unitGuid is deleted when hide
                -- print("deleteUnitGuid:", self:GetName(), self.states.unit, self.__unitGuid)
                if not self.isSpotlight then Cell.vars.guids[self.__unitGuid] = nil end
                self.__unitGuid = nil
            end
            if self.__unitName then
                if not self.isSpotlight then Cell.vars.names[self.__unitName] = nil end
                self.__unitName = nil
            end
            wipe(self.states)
        end

        -- private auras
        if self.states.unit ~= value then
            -- print("unitChanged:", self:GetName(), value)
            self.indicators.privateAuras:UpdatePrivateAuraAnchor(value)
        end

        if type(value) == "string" then
            self.states.unit = value
            self.states.displayedUnit = value
            if string.find(value, "^raid%d+$") then Cell.unitButtons.raid.units[value] = self end

            -- range
            -- if value ~= "focus" and not strfind(value, "target$") then
            --     self:RegisterUnitEvent("UNIT_IN_RANGE_UPDATE", value)
            -- end

            -- for omnicd
            if string.match(value, "raid%d") then
                local i = string.match(value, "%d")
                _G["CellRaidFrameMember"..i] = self
                self.unit = value
            end

            ResetAuraTables(self)
        -- else
        --     self:UnregisterEvent("UNIT_IN_RANGE_UPDATE")
        end
    end
end

-------------------------------------------------
-- unit button show/hide/enter/leave
-------------------------------------------------
Cell.vars.guids = {} -- guid to unitid
Cell.vars.names = {} -- name to unitid

local function UnitButton_OnShow(self)
    -- print(GetTime(), "OnShow", self:GetName())
    self._updateRequired = nil -- prevent UnitButton_UpdateAll twice. when convert party <-> raid, GROUP_ROSTER_UPDATE fired.
    self._powerBarUpdateRequired = 1
    UnitButton_RegisterEvents(self)

    --[[
    if self.states.unit then
        -- NOTE: update Cell.vars.guids
        local guid = UnitGUID(self.states.unit)
        if guid then
            Cell.vars.guids[guid] = self.states.unit
        end
        --! NOTE: can't get valid name immediately after an unseen player joining into group
        self.__timer = C_Timer.NewTicker(0.5, function()
            local name = GetUnitName(self.states.unit, true)
            if name and name ~= _G.UNKNOWN then
                Cell.vars.names[name] = self.states.unit
                self.__timer:Cancel()
                self.__timer = nil
            end
        end)
        -- print("show", self.states.unit, guid, name)
    end
    ]]
end

local function UnitButton_OnHide(self)
    -- print(GetTime(), "OnHide", self:GetName())
    UnitButton_UnregisterEvents(self)

    ResetAuraTables(self)

    -- NOTE: update Cell.vars.guids
    -- print("hide", self.states.unit, self.__unitGuid, self.__unitName)
    if self.__unitGuid then
        if not self.isSpotlight then Cell.vars.guids[self.__unitGuid] = nil end
        self.__unitGuid = nil
    end
    if self.__unitName then
        if not self.isSpotlight then Cell.vars.names[self.__unitName] = nil end
        self.__unitName = nil
    end
    self.__displayedGuid = nil
    F:RemoveElementsExceptKeys(self.states, "unit", "displayedUnit")
end

local function UnitButton_OnEnter(self)
    if not IsEncounterInProgress() then UnitButton_UpdateStatusText(self) end

    if highlightEnabled then self.widgets.mouseoverHighlight:Show() end

    local unit = self.states.displayedUnit
    if not unit then return end

    F:ShowTooltips(self, "unit", unit)
end

local function UnitButton_OnLeave(self)
    self.widgets.mouseoverHighlight:Hide()
    GameTooltip:Hide()
end

local UNKNOWN = _G.UNKNOWN
local UNKNOWNOBJECT = _G.UNKNOWNOBJECT
local function UnitButton_OnTick(self)
    -- print(GetTime(), "OnTick", self._updateRequired, self:GetAttribute("refreshOnUpdate"), self:GetName())
    local e = (self.__tickCount or 0) + 1
    if e >= 2 then -- every 0.5 second
        e = 0

        if self.states.unit and self.states.displayedUnit then
            local displayedGuid = UnitGUID(self.states.displayedUnit)
            if displayedGuid ~= self.__displayedGuid then
                -- NOTE: displayed unit entity changed
                F:RemoveElementsExceptKeys(self.states, "unit", "displayedUnit")
                self.__displayedGuid = displayedGuid
                self._updateRequired = 1
                self._powerBarUpdateRequired = 1
            end

            local guid = UnitGUID(self.states.unit)
            if guid and guid ~= self.__unitGuid then
                -- print("guidChanged:", self:GetName(), self.states.unit, guid)
                -- NOTE: unit entity changed
                -- update Cell.vars.guids
                self.__unitGuid = guid
                if not self.isSpotlight then Cell.vars.guids[guid] = self.states.unit end

                -- NOTE: only save players' names
                if UnitIsPlayer(self.states.unit) then
                    -- update Cell.vars.names
                    local name = GetUnitName(self.states.unit, true)
                    if (name and self.__nameRetries and self.__nameRetries >= 4) or (name and name ~= UNKNOWN and name ~= UNKNOWNOBJECT) then
                        self.__unitName = name
                        if not self.isSpotlight then Cell.vars.names[name] = self.states.unit end
                        self.__nameRetries = nil
                    else
                        -- NOTE: update on next tick
                        -- 国服可以起名为“未知目标”，干！就只多重试4次好了
                        self.__nameRetries = (self.__nameRetries or 0) + 1
                        self.__unitGuid = nil
                    end
                end
            end
        end
    end

    self.__tickCount = e

    -- !TODO: use UNIT_DISTANCE_CHECK_UPDATE and UNIT_IN_RANGE_UPDATE events in 10.1.5
    -- if self.states.displayedUnit == "target" or self.states.displayedUnit == "focus" then
        UnitButton_UpdateInRange(self)
    -- end

    if self._updateRequired and self._indicatorReady then
        self._updateRequired = nil
        UnitButton_UpdateAll(self)
    end

    --! for Xtarget
    if self:GetAttribute("refreshOnUpdate") then
        UnitButton_UpdateAll(self)
    end
end

local function UnitButton_OnUpdate(self, elapsed)
    local e = (self.__updateElapsed or 0) + elapsed
    if e > 0.25 then
        UnitButton_OnTick(self)
        e = 0
    end
    self.__updateElapsed = e
end

-------------------------------------------------
-- button functions
-------------------------------------------------
function B:SetPowerSize(button, size)
    -- print(GetTime(), "SetPowerSize", button:GetName(), button:IsShown(), button:IsVisible())
    button.powerSize = size

    if size == 0 then
        HidePowerBar(button)
    else
        if ShouldShowPowerBar(button) then
            ShowPowerBar(button)
        else
            HidePowerBar(button)
        end
    end
end

function B:UpdateShields(button)
    predictionEnabled = CellDB["appearance"]["healPrediction"][1]
    shieldEnabled = CellDB["appearance"]["shield"][1]
    overshieldEnabled = CellDB["appearance"]["overshield"][1]
    overshieldReverseFillEnabled = shieldEnabled and CellDB["appearance"]["overshieldReverseFill"]
    absorbEnabled = CellDB["appearance"]["healAbsorb"][1]
    absorbInvertColor = CellDB["appearance"]["healAbsorbInvertColor"]

    button.widgets.shieldBar:SetVertexColor(unpack(CellDB["appearance"]["shield"][2]))
    button.widgets.shieldBarR:SetVertexColor(unpack(CellDB["appearance"]["shield"][2]))
    button.widgets.overShieldGlow:SetVertexColor(unpack(CellDB["appearance"]["overshield"][2]))
    button.widgets.overShieldGlowR:SetVertexColor(unpack(CellDB["appearance"]["overshield"][2]))
    if not absorbInvertColor then
        button.widgets.overAbsorbGlow:SetVertexColor(unpack(CellDB["appearance"]["healAbsorb"][2]))
        button.widgets.absorbsBar:SetVertexColor(unpack(CellDB["appearance"]["healAbsorb"][2]))
    end

    UnitButton_UpdateHealPrediction(button)
    UnitButton_UpdateHealAbsorbs(button)
    UnitButton_UpdateShieldAbsorbs(button)
end

function B:SetTexture(button, tex)
    button.widgets.healthBar:SetStatusBarTexture(tex)
    button.widgets.healthBar:GetStatusBarTexture():SetDrawLayer("ARTWORK", -6)
    button.widgets.healthBarLoss:SetTexture(tex)
    button.widgets.powerBar:SetStatusBarTexture(tex)
    button.widgets.powerBar:GetStatusBarTexture():SetDrawLayer("ARTWORK", -6)
    button.widgets.powerBarLoss:SetTexture(tex)
    button.widgets.incomingHeal:SetTexture(tex)
    button.widgets.damageFlashTex:SetTexture(tex)
end

function B:UpdateColor(button)
    UnitButton_UpdateHealthColor(button)
    UnitButton_UpdatePowerType(button)
    button:SetBackdropColor(0, 0, 0, CellDB["appearance"]["bgAlpha"])
end

local function IncomingHeal_SetValue_Horizontal(self, incomingPercent, healthPercent)
    local barWidth = self:GetParent():GetWidth()
    local incomingHealWidth = incomingPercent * barWidth
    local lostHealthWidth = barWidth * (1 - healthPercent)

    -- print(incomingPercent, barWidth, incomingHealWidth, lostHealthWidth)
    -- FIXME: if incomingPercent is a very tiny number, like 0.005
    -- P:Scale(incomingHealWidth) ==> 0
    --! if width is set to 0, then the ACTUAL width may be 256!!!

    if lostHealthWidth == 0 then
        self:Hide()
    else
        if lostHealthWidth > incomingHealWidth then
            self:SetWidth(incomingHealWidth)
        else
            self:SetWidth(lostHealthWidth)
        end
        self:Show()
    end
end

local function ShieldBar_SetValue_Horizontal(self, shieldPercent, healthPercent)
    local barWidth = self:GetParent():GetWidth()
    if shieldPercent + healthPercent > 1 then -- overshield
        local p = 1 - healthPercent
        if p ~= 0 then
            if shieldEnabled then
                self:SetWidth(p * barWidth)
                self:Show()
            else
                self:Hide()
            end
        else
            self:Hide()
        end

        if overshieldReverseFillEnabled then
            p = shieldPercent + healthPercent - 1
            if p > healthPercent then p = healthPercent end
            self.shieldBarR:SetWidth(p * barWidth)
            self.shieldBarR:Show()
            if overshieldEnabled then
                self.overShieldGlowR:Show()
            else
                self.overShieldGlowR:Hide()
            end
            self.overShieldGlow:Hide()
        else
            if overshieldEnabled then
                self.overShieldGlow:Show()
            else
                self.overShieldGlow:Hide()
            end
            self.shieldBarR:Hide()
            self.overShieldGlowR:Hide()
        end
    else
        if shieldEnabled then
            self:SetWidth(shieldPercent * barWidth)
            self:Show()
        else
            self:Hide()
        end
        self.shieldBarR:Hide()
        self.overShieldGlow:Hide()
        self.overShieldGlowR:Hide()
    end
end

local function AbsorbsBar_SetValue_Horizontal(self, absorbsPercent, healthPercent)
    if absorbInvertColor then
        local r, g, b = F:InvertColor(self:GetParent():GetStatusBarColor())
        self:SetVertexColor(r, g, b)
        self.overAbsorbGlow:SetVertexColor(r, g, b)
    end

    local barWidth = self:GetParent():GetWidth()
    if absorbsPercent > healthPercent then
        self:SetWidth(healthPercent * barWidth)
        self.overAbsorbGlow:Show()
    else
        self:SetWidth(absorbsPercent * barWidth)
        self.overAbsorbGlow:Hide()
    end
    self:Show()
end

local function DamageFlashTex_SetValue_Horizontal(self, lostPercent)
    local barWidth = self:GetParent():GetWidth()
    self:SetWidth(barWidth * lostPercent)
end

local function IncomingHeal_SetValue_Vertical(self, incomingPercent, healthPercent)
    local barHeight = self:GetParent():GetHeight()
    local incomingHealHeight = incomingPercent * barHeight
    local lostHealthHeight = barHeight * (1 - healthPercent)

    if lostHealthHeight == 0 then
        self:Hide()
    else
        if lostHealthHeight > incomingHealHeight then
            self:SetHeight(incomingHealHeight)
        else
            self:SetHeight(lostHealthHeight)
        end
        self:Show()
    end
end

local function ShieldBar_SetValue_Vertical(self, shieldPercent, healthPercent)
    local barHeight = self:GetParent():GetHeight()
    if shieldPercent + healthPercent > 1 then -- overshield
        local p = 1 - healthPercent
        if p ~= 0 then
            if shieldEnabled then
                self:SetHeight(p * barHeight)
                self:Show()
            else
                self:Hide()
            end
        else
            self:Hide()
        end

        if overshieldReverseFillEnabled then
            p = shieldPercent + healthPercent - 1
            if p > healthPercent then p = healthPercent end
            self.shieldBarR:SetHeight(p * barHeight)
            self.shieldBarR:Show()
            if overshieldEnabled then
                self.overShieldGlowR:Show()
            else
                self.overShieldGlowR:Hide()
            end
            self.overShieldGlow:Hide()
        else
            if overshieldEnabled then
                self.overShieldGlow:Show()
            else
                self.overShieldGlow:Hide()
            end
            self.shieldBarR:Hide()
            self.overShieldGlowR:Hide()
        end
    else
        if shieldEnabled then
            self:SetHeight(shieldPercent * barHeight)
            self:Show()
        else
            self:Hide()
        end
        self.shieldBarR:Hide()
        self.overShieldGlow:Hide()
        self.overShieldGlowR:Hide()
    end
end

local function AbsorbsBar_SetValue_Vertical(self, absorbsPercent, healthPercent)
    if absorbInvertColor then
        local r, g, b = F:InvertColor(self:GetParent():GetStatusBarColor())
        self:SetVertexColor(r, g, b)
        self.overAbsorbGlow:SetVertexColor(r, g, b)
    end
    local barHeight = self:GetParent():GetHeight()
    if absorbsPercent > healthPercent then
        self:SetHeight(healthPercent * barHeight)
        self.overAbsorbGlow:Show()
    else
        self:SetHeight(absorbsPercent * barHeight)
        self.overAbsorbGlow:Hide()
    end
    self:Show()
end

local function DamageFlashTex_SetValue_Vertical(self, lostPercent)
    local barHeight = self:GetParent():GetHeight()
    self:SetHeight(barHeight * lostPercent)
end

function B:SetOrientation(button, orientation, rotateTexture)
    local healthBar = button.widgets.healthBar
    local healthBarLoss = button.widgets.healthBarLoss
    local powerBar = button.widgets.powerBar
    local powerBarLoss = button.widgets.powerBarLoss
    local incomingHeal = button.widgets.incomingHeal
    local damageFlashTex = button.widgets.damageFlashTex
    local gapTexture = button.widgets.gapTexture
    local shieldBar = button.widgets.shieldBar
    local shieldBarR = button.widgets.shieldBarR
    local overShieldGlow = button.widgets.overShieldGlow
    local overShieldGlowR = button.widgets.overShieldGlowR
    local overAbsorbGlow = button.widgets.overAbsorbGlow
    local absorbsBar = button.widgets.absorbsBar

    gapTexture:SetColorTexture(unpack(CELL_BORDER_COLOR))

    button.orientation = orientation
    if orientation == "vertical_health" then
        healthBar:SetOrientation("vertical")
        powerBar:SetOrientation("horizontal")
    else
        healthBar:SetOrientation(orientation)
        powerBar:SetOrientation(orientation)
    end
    healthBar:SetRotatesTexture(rotateTexture)
    powerBar:SetRotatesTexture(rotateTexture)

    button.indicators.healthThresholds:SetOrientation(orientation)

    if rotateTexture then
        F:RotateTexture(healthBarLoss, 90)
        F:RotateTexture(powerBarLoss, 90)
        F:RotateTexture(incomingHeal, 90)
        F:RotateTexture(damageFlashTex, 90)
        -- F:RotateTexture(shieldBar, 90)
        -- F:RotateTexture(absorbsBar, 90)
    else
        F:RotateTexture(healthBarLoss, 0)
        F:RotateTexture(powerBarLoss, 0)
        F:RotateTexture(incomingHeal, 0)
        F:RotateTexture(damageFlashTex, 0)
        -- F:RotateTexture(overShieldGlow, 0)
        -- F:RotateTexture(shieldBar, 0)
        -- F:RotateTexture(absorbsBar, 0)
    end

    if orientation == "horizontal" then
        -- update healthBarLoss
        P:ClearPoints(healthBarLoss)
        P:Point(healthBarLoss, "TOPRIGHT", healthBar)
        P:Point(healthBarLoss, "BOTTOMLEFT", healthBar:GetStatusBarTexture(), "BOTTOMRIGHT")

        -- update powerBarLoss
        P:ClearPoints(powerBarLoss)
        P:Point(powerBarLoss, "TOPRIGHT", powerBar)
        P:Point(powerBarLoss, "BOTTOMLEFT", powerBar:GetStatusBarTexture(), "BOTTOMRIGHT")

        -- update gapTexture
        P:ClearPoints(gapTexture)
        P:Point(gapTexture, "BOTTOMLEFT", powerBar, "TOPLEFT")
        P:Point(gapTexture, "BOTTOMRIGHT", powerBar, "TOPRIGHT")
        P:Height(gapTexture, CELL_BORDER_SIZE)

        -- update incomingHeal
        incomingHeal.SetValue = IncomingHeal_SetValue_Horizontal
        P:ClearPoints(incomingHeal)
        P:Point(incomingHeal, "TOPLEFT", healthBar:GetStatusBarTexture(), "TOPRIGHT")
        P:Point(incomingHeal, "BOTTOMLEFT", healthBar:GetStatusBarTexture(), "BOTTOMRIGHT")

        -- update shieldBar
        shieldBar.SetValue = ShieldBar_SetValue_Horizontal
        P:ClearPoints(shieldBar)
        P:Point(shieldBar, "TOPLEFT", healthBar:GetStatusBarTexture(), "TOPRIGHT")
        P:Point(shieldBar, "BOTTOMLEFT", healthBar:GetStatusBarTexture(), "BOTTOMRIGHT")

        -- update shieldBarR
        P:ClearPoints(shieldBarR)
        P:Point(shieldBarR, "TOPRIGHT", healthBar:GetStatusBarTexture())
        P:Point(shieldBarR, "BOTTOMRIGHT", healthBar:GetStatusBarTexture())

        -- update absorbsBar
        absorbsBar.SetValue = AbsorbsBar_SetValue_Horizontal
        P:ClearPoints(absorbsBar)
        P:Point(absorbsBar, "TOPRIGHT", healthBar:GetStatusBarTexture())
        P:Point(absorbsBar, "BOTTOMRIGHT", healthBar:GetStatusBarTexture())

        -- update overShieldGlow
        P:ClearPoints(overShieldGlow)
        P:Point(overShieldGlow, "TOPRIGHT")
        P:Point(overShieldGlow, "BOTTOMRIGHT")
        P:Width(overShieldGlow, 4)
        F:RotateTexture(overShieldGlow, 0)

        -- update overShieldGlowR
        P:ClearPoints(overShieldGlowR)
        P:Point(overShieldGlowR, "TOPLEFT", shieldBarR, "TOPLEFT", -4, 0)
        P:Point(overShieldGlowR, "BOTTOMLEFT", shieldBarR, "BOTTOMLEFT", -4, 0)
        P:Width(overShieldGlowR, 8)
        F:RotateTexture(overShieldGlowR, 0)

        -- update overAbsorbGlow
        P:ClearPoints(overAbsorbGlow)
        P:Point(overAbsorbGlow, "TOPLEFT")
        P:Point(overAbsorbGlow, "BOTTOMLEFT")
        P:Width(overAbsorbGlow, 4)
        F:RotateTexture(overAbsorbGlow, 0)

        -- update damageFlashTex
        damageFlashTex.SetValue = DamageFlashTex_SetValue_Horizontal
        P:ClearPoints(damageFlashTex)
        P:Point(damageFlashTex, "TOPLEFT", healthBar:GetStatusBarTexture(), "TOPRIGHT")
        P:Point(damageFlashTex, "BOTTOMLEFT", healthBar:GetStatusBarTexture(), "BOTTOMRIGHT")

    else -- vertical / vertical_health
        P:ClearPoints(healthBarLoss)
        P:Point(healthBarLoss, "TOPRIGHT", healthBar)
        P:Point(healthBarLoss, "BOTTOMLEFT", healthBar:GetStatusBarTexture(), "TOPLEFT")

        if orientation == "vertical" then
            -- update powerBarLoss
            P:ClearPoints(powerBarLoss)
            P:Point(powerBarLoss, "TOPRIGHT", powerBar)
            P:Point(powerBarLoss, "BOTTOMLEFT", powerBar:GetStatusBarTexture(), "TOPLEFT")

            -- update gapTexture
            P:ClearPoints(gapTexture)
            P:Point(gapTexture, "TOPRIGHT", powerBar, "TOPLEFT")
            P:Point(gapTexture, "BOTTOMRIGHT", powerBar, "BOTTOMLEFT")
            P:Width(gapTexture, CELL_BORDER_SIZE)
        else -- vertical_health
            -- update powerBarLoss
            P:ClearPoints(powerBarLoss)
            P:Point(powerBarLoss, "TOPRIGHT", powerBar)
            P:Point(powerBarLoss, "BOTTOMLEFT", powerBar:GetStatusBarTexture(), "BOTTOMRIGHT")

            -- update gapTexture
            P:ClearPoints(gapTexture)
            P:Point(gapTexture, "BOTTOMLEFT", powerBar, "TOPLEFT")
            P:Point(gapTexture, "BOTTOMRIGHT", powerBar, "TOPRIGHT")
            P:Height(gapTexture, CELL_BORDER_SIZE)
        end

        -- update incomingHeal
        incomingHeal.SetValue = IncomingHeal_SetValue_Vertical
        P:ClearPoints(incomingHeal)
        P:Point(incomingHeal, "BOTTOMLEFT", healthBar:GetStatusBarTexture(), "TOPLEFT")
        P:Point(incomingHeal, "BOTTOMRIGHT", healthBar:GetStatusBarTexture(), "TOPRIGHT")

        -- update shieldBar
        shieldBar.SetValue = ShieldBar_SetValue_Vertical
        P:ClearPoints(shieldBar)
        P:Point(shieldBar, "BOTTOMLEFT", healthBar:GetStatusBarTexture(), "TOPLEFT")
        P:Point(shieldBar, "BOTTOMRIGHT", healthBar:GetStatusBarTexture(), "TOPRIGHT")

        -- update shieldBarR
        P:ClearPoints(shieldBarR)
        P:Point(shieldBarR, "TOPLEFT", healthBar:GetStatusBarTexture())
        P:Point(shieldBarR, "TOPRIGHT", healthBar:GetStatusBarTexture())

        -- update absorbsBar
        absorbsBar.SetValue = AbsorbsBar_SetValue_Vertical
        P:ClearPoints(absorbsBar)
        P:Point(absorbsBar, "TOPLEFT", healthBar:GetStatusBarTexture())
        P:Point(absorbsBar, "TOPRIGHT", healthBar:GetStatusBarTexture())

        -- update overShieldGlow
        P:ClearPoints(overShieldGlow)
        P:Point(overShieldGlow, "TOPLEFT")
        P:Point(overShieldGlow, "TOPRIGHT")
        P:Height(overShieldGlow, 4)
        F:RotateTexture(overShieldGlow, 90)

        -- update overShieldGlowR TODO: fix vertical height
        P:ClearPoints(overShieldGlowR)
        P:Point(overShieldGlowR, "TOPRIGHT", shieldBarR, "TOPRIGHT", 0, -4)
        P:Point(overShieldGlowR, "BOTTOMLEFT", shieldBarR, "BOTTOMLEFT", 0, -4)
        P:Height(overShieldGlowR, 8)
        F:RotateTexture(overShieldGlowR, 90)

        -- update overAbsorbGlow
        P:ClearPoints(overAbsorbGlow)
        P:Point(overAbsorbGlow, "BOTTOMLEFT")
        P:Point(overAbsorbGlow, "BOTTOMRIGHT")
        P:Height(overAbsorbGlow, 4)
        F:RotateTexture(overAbsorbGlow, 90)

        -- update damageFlashTex
        damageFlashTex.SetValue = DamageFlashTex_SetValue_Vertical
        P:ClearPoints(damageFlashTex)
        P:Point(damageFlashTex, "BOTTOMLEFT", healthBar:GetStatusBarTexture(), "TOPLEFT")
        P:Point(damageFlashTex, "BOTTOMRIGHT", healthBar:GetStatusBarTexture(), "TOPRIGHT")
    end

    -- update consumables
    I.UpdateConsumablesOrientation(button, orientation)
end

function B:UpdateHighlightColor(button)
    button.widgets.targetHighlight:SetBackdropBorderColor(unpack(CellDB["appearance"]["targetColor"]))
    button.widgets.mouseoverHighlight:SetBackdropBorderColor(unpack(CellDB["appearance"]["mouseoverColor"]))
end

function B:UpdateHighlightSize(button)
    local targetHighlight = button.widgets.targetHighlight
    local mouseoverHighlight = button.widgets.mouseoverHighlight

    local size = CellDB["appearance"]["highlightSize"]

    if size ~= 0 then
        highlightEnabled = true

        P:ClearPoints(targetHighlight)
        P:ClearPoints(mouseoverHighlight)

        -- update point
        if size < 0 then
            size = abs(size)
            P:Point(targetHighlight, "TOPLEFT", button, "TOPLEFT")
            P:Point(targetHighlight, "BOTTOMRIGHT", button, "BOTTOMRIGHT")
            P:Point(mouseoverHighlight, "TOPLEFT", button, "TOPLEFT")
            P:Point(mouseoverHighlight, "BOTTOMRIGHT", button, "BOTTOMRIGHT")
        else
            P:Point(targetHighlight, "TOPLEFT", button, "TOPLEFT", -size, size)
            P:Point(targetHighlight, "BOTTOMRIGHT", button, "BOTTOMRIGHT", size, -size)
            P:Point(mouseoverHighlight, "TOPLEFT", button, "TOPLEFT", -size, size)
            P:Point(mouseoverHighlight, "BOTTOMRIGHT", button, "BOTTOMRIGHT", size, -size)
        end

        -- update thickness
        targetHighlight:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = P:Scale(size)})
        mouseoverHighlight:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = P:Scale(size)})

        -- update color
        targetHighlight:SetBackdropBorderColor(unpack(CellDB["appearance"]["targetColor"]))
        mouseoverHighlight:SetBackdropBorderColor(unpack(CellDB["appearance"]["mouseoverColor"]))

        UnitButton_UpdateTarget(button) -- 0->!0 show highlight again
    else
        highlightEnabled = false
        targetHighlight:Hide()
        mouseoverHighlight:Hide()
    end
end

-- raidIcons
function B:UpdatePlayerRaidIcon(button, enabled)
    if not button:IsShown() then return end
    UnitButton_UpdatePlayerRaidIcon(button)
    if enabled then
        button:RegisterEvent("RAID_TARGET_UPDATE")
    else
        button:UnregisterEvent("RAID_TARGET_UPDATE")
    end
end

function B:UpdateTargetRaidIcon(button, enabled)
    if not button:IsShown() then return end
    UnitButton_UpdateTargetRaidIcon(button)
    if enabled then
        button:RegisterEvent("UNIT_TARGET")
    else
        button:UnregisterEvent("UNIT_TARGET")
    end
end

-- healthText
function B:UpdateHealthText(button)
    if button.states.displayedUnit then
        UpdateUnitHealthState(button)
    end
end

-- powerText
function B:UpdatePowerText(button)
    if button.states.displayedUnit then
        UnitButton_UpdatePowerText(button)
        UnitButton_UpdatePowerTextColor(button)
    end
end

-- statusText
function B:UpdateStatusText(button)
    UnitButton_UpdateStatusText(button)
end

-- shields
function B:UpdateShield(button)
    UnitButton_UpdateShieldAbsorbs(button)
end

-- animation
function B:UpdateAnimation(button)
    barAnimationType = CellDB["appearance"]["barAnimation"]

    if barAnimationType == "Smooth" then
        button.widgets.healthBar.SetBarValue = button.widgets.healthBar.SetSmoothedValue
        button.widgets.powerBar.SetBarValue = button.widgets.powerBar.SetSmoothedValue
    else
        button.widgets.healthBar:ResetSmoothedValue()
        button.widgets.healthBar.SetBarValue = button.widgets.healthBar.SetValue
        button.widgets.powerBar:ResetSmoothedValue()
        button.widgets.powerBar.SetBarValue = button.widgets.powerBar.SetValue
    end

    if barAnimationType ~= "Flash" then
        button.widgets.damageFlashAG:Finish()
    end
end

-- damageFlash
function B:ShowFlash(button, lostPercent)
    button.widgets.damageFlashTex:SetValue(lostPercent)
    button.widgets.damageFlashAG:Play()
end

function B:HideFlash(button)
    button.widgets.damageFlashAG:Finish()
end

-- pixel perfect
function B:UpdatePixelPerfect(button, updateIndicators)
    button:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = P:Scale(CELL_BORDER_SIZE)})
    button:SetBackdropColor(0, 0, 0, CellDB["appearance"]["bgAlpha"])
    button:SetBackdropBorderColor(unpack(CELL_BORDER_COLOR))
    if not InCombatLockdown() then P:Resize(button) end

    P:Repoint(button.widgets.healthBar)
    P:Repoint(button.widgets.healthBarLoss)
    P:Repoint(button.widgets.powerBar)
    P:Repoint(button.widgets.powerBarLoss)
    P:Repoint(button.widgets.gapTexture)
    P:Resize(button.widgets.gapTexture)

    P:Repoint(button.widgets.incomingHeal)
    P:Repoint(button.widgets.shieldBar)
    P:Repoint(button.widgets.absorbsBar)
    P:Repoint(button.widgets.damageFlashTex)

    P:Resize(button.widgets.overShieldGlow)
    P:Repoint(button.widgets.overShieldGlow)
    P:Resize(button.widgets.overAbsorbGlow)
    P:Repoint(button.widgets.overAbsorbGlow)

    B:UpdateHighlightSize(button)

    if updateIndicators then
        -- indicators
        for _, i in pairs(button.indicators) do
            if i.UpdatePixelPerfect then
                i:UpdatePixelPerfect()
            end
        end
    else
        button.indicators.nameText:UpdatePixelPerfect()
        button.indicators.statusText:UpdatePixelPerfect()
    end

    button.widgets.srIcon:UpdatePixelPerfect()
end

B.UpdateAll = UnitButton_UpdateAll
B.UpdateHealth = UnitButton_UpdateHealth
B.UpdateHealthMax = UnitButton_UpdateHealthMax
B.UpdateAuras = UnitButton_UpdateAuras
B.UpdateName = UnitButton_UpdateName

-------------------------------------------------
-- unit button init
-------------------------------------------------
-- local startTimeCache, statusCache = {}, {}
local startTimeCache = {}

-- Layer(statusTextFrame) -- frameLevel:27 ----------
-- ARTWORK
--	statusText, timerText
-------------------------------------------------
-- Layer(overlayFrame) -- frameLevel:7 ----------
-- OVERLAY
--	-7 readyCheckIcon, statusIcon
-- ARTWORK
--	top nameText, statusText, timerText
--	-7 playerRaidIcon, roleIcon, leaderIcon
-------------------------------------------------

-- Layer(healthBar) -- frameLevel:5 -----------------
-- ARTWORK
--	-5 overShieldGlow
--	-6 incomingHeal, damageFlash, absorbsBar
--	-7 shieldBar
-------------------------------------------------

-- Layer(button) -- frameLevel:3 -----------------
-- OVERLAY
-- ARTWORK
--	-6 healthBar, powerBar
--	-7 healthBarBackground, powerBarBackground
-- BORDER
--	0 background(button)
-- BACKGROUND
--	0 readyCheckHighlight
--	-1 mouseoverHighlight
--	-2 targetHighlight
-------------------------------------------------
-- BACKGROUND BORDER ARTWORK OVERLAY HIGHLIGHT

-- NOTE: prevent a nil method error
local DumbFunc = function() end

function CellUnitButton_OnLoad(button)
    local name = button:GetName()

    button.widgets = {}
    button.states = {}
    button.indicators = {}

    InitAuraTables(button)

    -- ping system
    Mixin(button, PingableType_UnitFrameMixin)
    button:SetAttribute("ping-receiver", true)

    function button:GetTargetPingGUID()
        return button.__unitGuid
    end

    -- background
    -- local background = button:CreateTexture(name.."Background", "BORDER")
    -- button.widgets.background = background
    -- background:SetAllPoints(button)
    -- background:SetTexture("Interface\\BUTTONS\\WHITE8X8.BLP")
    -- background:SetVertexColor(0, 0, 0, 1)

    -- backdrop
    button:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = P:Scale(CELL_BORDER_SIZE)})
    button:SetBackdropColor(0, 0, 0, 1)
    button:SetBackdropBorderColor(unpack(CELL_BORDER_COLOR))

    -- healthbar
    local healthBar = CreateFrame("StatusBar", name.."HealthBar", button)
    button.widgets.healthBar = healthBar
    -- P:Point(healthBar, "TOPLEFT", button, "TOPLEFT", 1, -1)
    -- P:Point(healthBar, "BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 4)
    healthBar:SetStatusBarTexture(Cell.vars.texture)
    healthBar:GetStatusBarTexture():SetDrawLayer("ARTWORK", -6)
    healthBar:SetFrameLevel(button:GetFrameLevel()+5)
    healthBar.SetBarValue = healthBar.SetValue

    -- healthBar:SetScript("OnValueChanged", function(self, value)
    --     if value == 0 then
    --         healthBar:SetValue(0.1)
    --     end
    -- end)

    -- hp loss
    local healthBarLoss = button:CreateTexture(name.."HealthBarLoss", "ARTWORK", nil , -7)
    button.widgets.healthBarLoss = healthBarLoss
    -- P:Point(healthBarLoss, "TOPRIGHT", healthBar)
    -- P:Point(healthBarLoss, "BOTTOMLEFT", healthBar:GetStatusBarTexture(), "BOTTOMRIGHT")
    healthBarLoss:SetTexture(Cell.vars.texture)

    -- powerbar
    local powerBar = CreateFrame("StatusBar", name.."PowerBar", button)
    button.widgets.powerBar = powerBar
    -- P:Point(powerBar, "TOPLEFT", healthBar, "BOTTOMLEFT", 0, -1)
    -- P:Point(powerBar, "BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
    powerBar:SetStatusBarTexture(Cell.vars.texture)
    powerBar:GetStatusBarTexture():SetDrawLayer("ARTWORK", -6)
    powerBar:SetFrameLevel(button:GetFrameLevel()+6)
    powerBar.SetBarValue = powerBar.SetValue

    local gapTexture = button:CreateTexture(nil, "BORDER")
    button.widgets.gapTexture = gapTexture
    -- P:Point(gapTexture, "BOTTOMLEFT", powerBar, "TOPLEFT")
    -- P:Point(gapTexture, "BOTTOMRIGHT", powerBar, "TOPRIGHT")
    -- P:Height(gapTexture, 1)
    gapTexture:SetColorTexture(unpack(CELL_BORDER_COLOR))

    -- power loss
    local powerBarLoss = button:CreateTexture(name.."PowerBarLoss", "ARTWORK", nil , -7)
    button.widgets.powerBarLoss = powerBarLoss
    -- P:Point(powerBarLoss, "TOPRIGHT", powerBar)
    -- P:Point(powerBarLoss, "BOTTOMLEFT", powerBar:GetStatusBarTexture(), "BOTTOMRIGHT")
    powerBarLoss:SetTexture(Cell.vars.texture)

    -- incoming heal
    local incomingHeal = healthBar:CreateTexture(name.."IncomingHealBar", "ARTWORK", nil, -6)
    button.widgets.incomingHeal = incomingHeal
    incomingHeal:SetTexture(Cell.vars.texture)
    incomingHeal:Hide()
    incomingHeal.SetValue = DumbFunc

    -- shield bar
    local shieldBar = healthBar:CreateTexture(name.."ShieldBar", "ARTWORK", nil, -7)
    button.widgets.shieldBar = shieldBar
    shieldBar:SetTexture("Interface\\AddOns\\Cell\\Media\\shield", "REPEAT", "REPEAT")
    shieldBar:SetHorizTile(true)
    shieldBar:SetVertTile(true)
    shieldBar:Hide()
    shieldBar.SetValue = DumbFunc

    local shieldBarR = healthBar:CreateTexture(name.."ShieldBarR", "OVERLAY", nil, 1)
    button.widgets.shieldBarR = shieldBarR
    shieldBarR:SetTexture("Interface\\AddOns\\Cell\\Media\\shield", "REPEAT", "REPEAT")
    shieldBarR:SetHorizTile(true)
    shieldBarR:SetVertTile(true)
    shieldBarR:Hide()
    shieldBar.shieldBarR = shieldBarR

    -- over-shield glow
    local overShieldGlow = healthBar:CreateTexture(name.."OverShieldGlow", "OVERLAY")
    button.widgets.overShieldGlow = overShieldGlow
    overShieldGlow:SetTexture("Interface\\AddOns\\Cell\\Media\\overshield")
    -- overShieldGlow:SetBlendMode("ADD")
    overShieldGlow:Hide()
    shieldBar.overShieldGlow = overShieldGlow

    -- over-shield glow reversed
    local overShieldGlowR = healthBar:CreateTexture(name.."OverShieldGlowR", "OVERLAY", nil, 2)
    button.widgets.overShieldGlowR = overShieldGlowR
    overShieldGlowR:SetTexture("Interface\\AddOns\\Cell\\Media\\overshield_reversed")
    -- overShieldGlowR:SetBlendMode("ADD")
    overShieldGlowR:Hide()
    shieldBar.overShieldGlowR = overShieldGlowR

    -- over-absorb glow
    local overAbsorbGlow = healthBar:CreateTexture(name.."OverAbsorbGlow", "OVERLAY", nil, 7)
    button.widgets.overAbsorbGlow = overAbsorbGlow
    overAbsorbGlow:SetTexture("Interface\\AddOns\\Cell\\Media\\overabsorb")
    -- overAbsorbGlow:SetBlendMode("ADD")
    overAbsorbGlow:Hide()

    -- absorbs bar
    local absorbsBar = healthBar:CreateTexture(name.."AbsorbsBar", "OVERLAY", nil, 5)
    button.widgets.absorbsBar = absorbsBar
    absorbsBar:SetTexture("Interface\\AddOns\\Cell\\Media\\shield.tga", "REPEAT", "REPEAT")
    absorbsBar:SetHorizTile(true)
    absorbsBar:SetVertTile(true)
    absorbsBar:SetVertexColor(1, 0.1, 0.1, 1)
    -- absorbsBar:SetBlendMode("ADD")
    absorbsBar:Hide()
    absorbsBar.SetValue = DumbFunc
    absorbsBar.overAbsorbGlow = overAbsorbGlow

    -- bar animation
    -- flash
    local damageFlashTex = healthBar:CreateTexture(name.."DamageFlash", "ARTWORK", nil, -6)
    button.widgets.damageFlashTex = damageFlashTex
    damageFlashTex:SetTexture("Interface\\BUTTONS\\WHITE8X8")
    damageFlashTex:SetVertexColor(1, 1, 1, 0.7)
    -- P:Point(damageFlashTex, "TOPLEFT", healthBar:GetStatusBarTexture(), "TOPRIGHT")
    -- P:Point(damageFlashTex, "BOTTOMLEFT", healthBar:GetStatusBarTexture(), "BOTTOMRIGHT")
    damageFlashTex:Hide()
    damageFlashTex.SetValue = DumbFunc

    -- damage flash animation group
    local damageFlashAG = damageFlashTex:CreateAnimationGroup()
    button.widgets.damageFlashAG = damageFlashAG

    local alpha = damageFlashAG:CreateAnimation("Alpha")
    alpha:SetFromAlpha(0.7)
    alpha:SetToAlpha(0)
    alpha:SetDuration(0.2)

    damageFlashAG:SetScript("OnPlay", function(self)
        damageFlashTex:Show()
    end)

    damageFlashAG:SetScript("OnFinished", function(self)
        damageFlashTex:Hide()
    end)

    -- smooth
    Mixin(healthBar, SmoothStatusBarMixin)
    Mixin(powerBar, SmoothStatusBarMixin)

    -- target highlight
    local targetHighlight = CreateFrame("Frame", name.."TargetHighlight", button, "BackdropTemplate")
    button.widgets.targetHighlight = targetHighlight
    targetHighlight:SetIgnoreParentAlpha(true)
    targetHighlight:SetFrameLevel(button:GetFrameLevel()+6)
    -- targetHighlight:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = P:Scale(1)})
    -- P:Point(targetHighlight, "TOPLEFT", button, "TOPLEFT", -1, 1)
    -- P:Point(targetHighlight, "BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, -1)
    targetHighlight:Hide()

    -- mouseover highlight
    local mouseoverHighlight = CreateFrame("Frame", name.."MouseoverHighlight", button, "BackdropTemplate")
    button.widgets.mouseoverHighlight = mouseoverHighlight
    mouseoverHighlight:SetIgnoreParentAlpha(true)
    mouseoverHighlight:SetFrameLevel(button:GetFrameLevel()+7)
    -- mouseoverHighlight:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = P:Scale(1)})
    -- P:Point(mouseoverHighlight, "TOPLEFT", button, "TOPLEFT", -1, 1)
    -- P:Point(mouseoverHighlight, "BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, -1)
    mouseoverHighlight:Hide()

    -- readyCheck highlight
    -- local readyCheckHighlight = button:CreateTexture(name.."ReadyCheckHighlight", "BACKGROUND")
    -- button.widgets.readyCheckHighlight = readyCheckHighlight
    -- readyCheckHighlight:SetPoint("TOPLEFT", -1, 1)
    -- readyCheckHighlight:SetPoint("BOTTOMRIGHT", 1, -1)
    -- readyCheckHighlight:SetTexture("Interface\\Buttons\\WHITE8x8")
    -- readyCheckHighlight:Hide()

    --* tsGlowFrame (Targeted Spells)
    local tsGlowFrame = CreateFrame("Frame", name.."TSGlowFrame", button)
    button.widgets.tsGlowFrame = tsGlowFrame
    tsGlowFrame:SetAllPoints(button)

    --* srGlowFrame (Spell Request)
    local srGlowFrame = CreateFrame("Frame", name.."SRGlowFrame", button)
    button.widgets.srGlowFrame = srGlowFrame
    srGlowFrame:SetFrameLevel(button:GetFrameLevel()+240)
    srGlowFrame:SetAllPoints(button)

    --* drGlowFrame (Dispel Request)
    local drGlowFrame = CreateFrame("Frame", name.."DRGlowFrame", button)
    button.widgets.drGlowFrame = drGlowFrame
    drGlowFrame:SetFrameLevel(button:GetFrameLevel()+240)
    drGlowFrame:SetAllPoints(button)

    --* overlayFrame
    local overlayFrame = CreateFrame("Frame", name.."OverlayFrame", button)
    button.widgets.overlayFrame = overlayFrame
    overlayFrame:SetFrameLevel(button:GetFrameLevel()+120)
    overlayFrame:SetAllPoints(button)

    -- aggro bar
    local aggroBar = Cell:CreateStatusBar(name.."AggroBar", overlayFrame, 20, 4, 100, true)
    button.indicators.aggroBar = aggroBar
    -- aggroBar:SetPoint("BOTTOMLEFT", overlayFrame, "TOPLEFT", 1, 0)
    aggroBar:Hide()

    -- indicators
    I.CreateNameText(button)
    I.CreateStatusText(button)
    I.CreateHealthText(button)
    I.CreatePowerText(button)
    I.CreateStatusIcon(button)
    I.CreateRoleIcon(button)
    I.CreateLeaderIcon(button)
    I.CreateReadyCheckIcon(button)
    I.CreateAggroBlink(button)
    I.CreateAggroBorder(button)
    I.CreatePlayerRaidIcon(button)
    I.CreateTargetRaidIcon(button)
    I.CreateShieldBar(button)
    I.CreateAoEHealing(button)
    I.CreateDefensiveCooldowns(button)
    I.CreateExternalCooldowns(button)
    I.CreateAllCooldowns(button)
    I.CreateTankActiveMitigation(button)
    I.CreateDebuffs(button)
    I.CreateDispels(button)
    I.CreateRaidDebuffs(button)
    I.CreatePrivateAuras(button)
    I.CreateTargetedSpells(button)
    I.CreateTargetCounter(button)
    I.CreateCrowdControls(button)
    I.CreateConsumables(button)
    I.CreateHealthThresholds(button)
    I.CreateMissingBuffs(button)
    U:CreateSpellRequestIcon(button)
    U:CreateDispelRequestText(button)

    -- events
    button:SetScript("OnAttributeChanged", UnitButton_OnAttributeChanged) -- init
    button:HookScript("OnShow", UnitButton_OnShow)
    button:HookScript("OnHide", UnitButton_OnHide) -- use _onhide for click-castings
    button:HookScript("OnEnter", UnitButton_OnEnter) -- SecureHandlerEnterLeaveTemplate
    button:HookScript("OnLeave", UnitButton_OnLeave) -- SecureHandlerEnterLeaveTemplate
    button:SetScript("OnUpdate", UnitButton_OnUpdate)
    button:SetScript("OnEvent", UnitButton_OnEvent)
    button:RegisterForClicks("AnyDown")
end