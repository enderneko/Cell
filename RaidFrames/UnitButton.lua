local _, Cell = ...
local L = Cell.L
---@type CellFuncs
local F = Cell.funcs
---@class CellUnitButtonFuncs
local B = Cell.bFuncs
---@type CellIndicatorFuncs
local I = Cell.iFuncs
---@type CellUtilityFuncs
local U = Cell.uFuncs
---@type PixelPerfectFuncs
local P = Cell.pixelPerfectFuncs
---@type CellAnimations
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
-- 12.0+ APIs for secret value support
local issecretvalue = issecretvalue or function() return false end
local AbbreviateNumbers = AbbreviateNumbers
local UnitHealthPercent = UnitHealthPercent
local CreateUnitHealPredictionCalculator = CreateUnitHealPredictionCalculator
local UnitGetDetailedHealPrediction = UnitGetDetailedHealPrediction
local UnitIsFriend = UnitIsFriend
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
local GetSpecialization = GetSpecialization
local GetSpecializationRole = GetSpecializationRole
local UnitHasVehicleUI = UnitHasVehicleUI
-- local UnitInVehicle = UnitInVehicle
-- local UnitUsingVehicle = UnitUsingVehicle
local UnitIsCharmed = UnitIsCharmed
-- UnitIsPlayer already declared above
local UnitInPartyIsAI = UnitInPartyIsAI
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitThreatSituation = UnitThreatSituation
local GetThreatStatusColor = GetThreatStatusColor
local UnitExists = UnitExists
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitIsGroupAssistant = UnitIsGroupAssistant
local InCombatLockdown = InCombatLockdown
local UnitAffectingCombat = UnitAffectingCombat
local UnitPhaseReason = UnitPhaseReason
-- local UnitBuff = UnitBuff
-- local UnitDebuff = UnitDebuff
local IsInRaid = IsInRaid
local UnitDetailedThreatSituation = UnitDetailedThreatSituation
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo -- nil in 12.0+
local _GetAuraDataByAuraInstanceID = C_UnitAuras.GetAuraDataByAuraInstanceID
local GetAuraSlots = C_UnitAuras.GetAuraSlots
local _GetAuraDataBySlot = C_UnitAuras.GetAuraDataBySlot
local _GetAuraDispelTypeColor = C_UnitAuras.GetAuraDispelTypeColor
local _IsAuraFilteredOut = C_UnitAuras.IsAuraFilteredOutByInstanceID
local _GetAuraDuration = C_UnitAuras.GetAuraDuration -- 12.0+: NOT restricted, returns LuaDurationObject
-- wrapped versions applied after SanitizeAura is defined (see below)
local GetAuraDataByAuraInstanceID, GetAuraDataBySlot
local IsDelveInProgress = C_PartyInfo.IsDelveInProgress
local UnitGetDetailedHealPrediction = UnitGetDetailedHealPrediction  -- nil pre-12.0
local CreateUnitHealPredictionCalculator = CreateUnitHealPredictionCalculator  -- nil pre-12.0

--! for AI followers, UnitClassBase is buggy
local UnitClassBase = function(unit)
    return select(2, UnitClass(unit))
end

local barAnimationType, highlightEnabled, predictionEnabled
local shieldEnabled, overshieldEnabled, overshieldReverseFillEnabled
local absorbEnabled, absorbInvertColor

-- Midnight: Curve for CELL_FADE_OUT_HEALTH_PERCENT feature
-- Maps health percent â†' alpha so we can evaluate secret health% without comparisons
local fadeOutHealthCurve
local fadeOutHealthCurve_threshold -- track last threshold to know when to rebuild
local fadeOutHealthCurve_alpha -- track last outOfRangeAlpha to know when to rebuild

-- Builds/rebuilds the fade-out health curve when threshold or alpha changes.
-- health% < threshold â†' alpha 1.0 (fully visible, needs healing)
-- health% >= threshold â†' outOfRangeAlpha (faded out, healthy enough)
local function RebuildFadeOutHealthCurve()
    if not Cell.isMidnight or not C_CurveUtil then return end
    local threshold = CELL_FADE_OUT_HEALTH_PERCENT
    local alpha = CellDB and CellDB["appearance"] and CellDB["appearance"]["outOfRangeAlpha"] or 0.4
    if not threshold then
        fadeOutHealthCurve = nil
        fadeOutHealthCurve_threshold = nil
        fadeOutHealthCurve_alpha = nil
        return
    end
    if fadeOutHealthCurve and fadeOutHealthCurve_threshold == threshold and fadeOutHealthCurve_alpha == alpha then
        return -- no change needed
    end
    fadeOutHealthCurve = C_CurveUtil.CreateCurve()
    -- Below threshold: fully visible (unit needs healing)
    fadeOutHealthCurve:AddPoint(0.0, 1.0)
    fadeOutHealthCurve:AddPoint(threshold - 0.001, 1.0)
    -- At/above threshold: faded out (unit is healthy enough)
    fadeOutHealthCurve:AddPoint(threshold, alpha)
    fadeOutHealthCurve:AddPoint(1.0, alpha)
    fadeOutHealthCurve_threshold = threshold
    fadeOutHealthCurve_alpha = alpha
end

local CheckCLEURequired

-------------------------------------------------
-- 12.0+ secret value sanitizer for aura data
-------------------------------------------------
local function _notSecret(v)
    -- issecretvalue() is the only safe operation on secret values;
    -- must check it BEFORE any comparison (even ~= nil) to avoid
    -- producing a secret boolean that crashes on and/or
    if issecretvalue(v) then return false end
    return v ~= nil
end

local function SanitizeAura(aura)
    if not aura then return nil end

    -- auraInstanceID is the cache key — if secret, drop the aura
    if not _notSecret(aura.auraInstanceID) then return nil end

    -- Fast path: if name is not secret, no fields are secret.
    -- Probe once to skip all sanitization outside combat.
    if not issecretvalue(aura.name) then
        aura._hasSecrets = false
        aura._dispelNameIsSecret = false
        return aura
    end

    -- Slow path: fields are secret (12.0+ in combat).
    -- Sanitize in-place — no table copy. GetAuraDataBySlot/ByAuraInstanceID
    -- return fresh tables per call, so in-place mutation is safe.
    aura._hasSecrets = true

    -- dispelName: nil = non-dispellable, secret = dispellable but type unknown
    -- (== nil is safe on secrets; only arithmetic/boolean test/concat crash)
    aura._dispelNameIsSecret = aura.dispelName ~= nil

    -- keep raw values for C-level CooldownFrame:SetCooldown
    aura._rawDuration       = aura.duration
    aura._rawExpirationTime = aura.expirationTime

    -- replace secret fields with safe defaults in-place
    aura.icon       = aura.icon  -- raw; SetTexture() is C-level
    aura._rawSpellId = aura.spellId -- keep secret spellId for C_Spell lookup
    aura.name       = nil
    aura.sourceUnit = nil
    aura.dispelName = nil
    aura.spellId    = nil
    aura.applications   = 0
    aura.expirationTime = 0
    aura.duration       = 0
    aura.timeMod        = 1
    aura.isHelpful              = false
    aura.isHarmful              = false
    aura.isBossAura             = false
    aura.isRaid                 = false
    aura.isStealable            = false
    aura.isFromPlayerOrPlayerPet = false
    aura.canApplyAura           = false
    aura.nameplateShowAll       = false
    aura.nameplateShowPersonal  = false
    aura.canActivePlayerDispel  = false
    aura.points = nil

    return aura
end

-- wrap aura data retrieval to sanitize secret values
GetAuraDataByAuraInstanceID = function(unit, id)
    return SanitizeAura(_GetAuraDataByAuraInstanceID(unit, id))
end
GetAuraDataBySlot = function(unit, slot)
    return SanitizeAura(_GetAuraDataBySlot(unit, slot))
end

-------------------------------------------------
-- 12.0+ dispel display via bracket curves
-------------------------------------------------
-- WoW step curves CLAMP below the first point (never return nil).
-- So we can't use nil/non-nil for type detection. Instead:
--
-- 1. Use issecretvalue(aura.dispelName) to detect dispellable vs non-dispellable
--    (non-dispellable = nil, dispellable = SECRET in combat)
-- 2. Use "bracket curves" with 3 points to isolate each type:
--    e.g. Magic: {0:transparent, 1:visible, 2:transparent}
--    The step curve returns visible only for index 1, transparent for all others.
-- 3. Pass raw (secret) colors to C-level SetVertexColor for rendering.
--
-- Dispel type indices: None=0, Magic=1, Curse=2, Disease=3, Poison=4, Enrage=9, Bleed=11

local _dispelCurvesReady = false

-- Highlight curve: maps each type -> its correct display color
local _dispelHighlightCurve

-- Bracket curves: isolate each type (visible alpha for match, 0 alpha for non-match)
local _bracketCurves = {} -- [typeName] = curve

-- Type definitions for curve building (order matches Built-in.lua dispelOrder)
local _dispelTypes = {
    {name = "Magic",   idx = 1,  nextIdx = 2,  r = 0.20, g = 0.60, b = 1.00},
    {name = "Curse",   idx = 2,  nextIdx = 3,  r = 0.60, g = 0.00, b = 1.00},
    {name = "Disease", idx = 3,  nextIdx = 4,  r = 0.60, g = 0.40, b = 0.00},
    {name = "Poison",  idx = 4,  nextIdx = 5,  r = 0.00, g = 0.60, b = 0.00},
    {name = "Bleed",   idx = 11, nextIdx = nil, r = 1.00, g = 0.20, b = 0.60},
}

do
    local ok = pcall(function()
        if not C_CurveUtil or not C_CurveUtil.CreateColorCurve then return end
        if not _GetAuraDispelTypeColor then return end
        local stepType = Enum and Enum.LuaCurveType and Enum.LuaCurveType.Step
        if not stepType then return end

        local transparent = CreateColor(0, 0, 0, 0)

        -- highlight curve: all types -> correct colors, non-dispellable -> transparent
        _dispelHighlightCurve = C_CurveUtil.CreateColorCurve()
        _dispelHighlightCurve:SetType(stepType)
        _dispelHighlightCurve:AddPoint(0, transparent)  -- None
        for _, t in ipairs(_dispelTypes) do
            _dispelHighlightCurve:AddPoint(t.idx, CreateColor(t.r, t.g, t.b, 1))
        end
        _dispelHighlightCurve:AddPoint(9, transparent)  -- Enrage

        -- bracket curves: isolate each type
        -- e.g. Magic: {0:transparent, 1:typeColor, 2:transparent}
        for _, t in ipairs(_dispelTypes) do
            local curve = C_CurveUtil.CreateColorCurve()
            curve:SetType(stepType)
            curve:AddPoint(0, transparent) -- below target: invisible
            curve:AddPoint(t.idx, CreateColor(t.r, t.g, t.b, 1)) -- target: visible
            if t.nextIdx then
                curve:AddPoint(t.nextIdx, transparent) -- above target: invisible
            end
            _bracketCurves[t.name] = curve
        end

        _dispelCurvesReady = true
    end)
    if not ok then
        _dispelHighlightCurve = nil
        wipe(_bracketCurves)
        _dispelCurvesReady = false
    end
end

-- Get a ColorMixin from a curve for a specific aura (returns nil on failure)
local function _getCurveColor(unit, auraInstanceID, curve)
    if not curve then return nil end
    local ok, color = pcall(_GetAuraDispelTypeColor, unit, auraInstanceID, curve)
    if not ok then return nil end
    if issecretvalue(color) then return nil end
    return color
end

-- Gradient texture path: 1x4 white texture with baked-in vertical alpha gradient
-- (opaque at bottom, transparent at top). Used with SetVertexColor for secret
-- dispel display — the alpha gradient comes from the texture file, and the color
-- is applied via C-level SetVertexColor which handles secret values.
local GRADIENT_TEXTURE = "Interface\\AddOns\\Cell\\Media\\gradient"

-- Lazily create a single gradient overlay texture for secret dispel display.
local function _ensureGradientOverlay(dispels)
    if dispels._secretGradientOverlay then return dispels._secretGradientOverlay end

    local hlParent = dispels.highlight:GetParent()
    local tex = hlParent:CreateTexture(nil, "ARTWORK", nil, 0)
    tex:SetTexture(GRADIENT_TEXTURE)
    tex:SetBlendMode("BLEND")
    tex:Hide()

    dispels._secretGradientOverlay = tex
    return tex
end

-------------------------------------------------
-- debug: dispel trace & diagnostics
-------------------------------------------------
local _dispelTraceEnabled = false
function F.ToggleDispelTrace()
    _dispelTraceEnabled = not _dispelTraceEnabled
    print("|cff00ff00[Cell]|r Dispel trace:", _dispelTraceEnabled and "ON" or "OFF")
end
function F.PrintDispelDiag()
    print("|cff00ff00[Cell Dispel Diag]|r")
    print("  GetAuraDispelTypeColor:", _GetAuraDispelTypeColor and "exists" or "MISSING")
    print("  IsAuraFilteredOut:", _IsAuraFilteredOut and "exists" or "MISSING")
    print("  bracketCurves:", _dispelCurvesReady and "initialized" or "NOT READY")
    print("  highlightCurve:", _dispelHighlightCurve and "yes" or "NO")
    print("  issecretvalue:", rawget(_G, "issecretvalue") and "native" or "fallback")
    print("  InCombatLockdown:", InCombatLockdown() and "YES" or "NO")
end

-- Test bracket curves against all debuffs on a unit (run in combat to test secret handling)
function F.TestBracketCurves(unit)
    unit = unit or "player"
    print("|cff00ff00[Cell Bracket Test]|r unit=" .. unit .. " combat=" .. tostring(InCombatLockdown()))
    print("  _dispelCurvesReady:", _dispelCurvesReady)

    local slots = {GetAuraSlots(unit, "HARMFUL")}
    if #slots < 2 then
        print("  No debuffs found on", unit)
        return
    end
    for i = 2, #slots do
        local rawAura = _GetAuraDataBySlot(unit, slots[i])
        if rawAura then
            local id = rawAura.auraInstanceID
            local idOk = not issecretvalue(id)

            local nameStr = "?"
            if not issecretvalue(rawAura.name) and rawAura.name then nameStr = rawAura.name end
            local dispelStr = "?"
            if not issecretvalue(rawAura.dispelName) then
                dispelStr = rawAura.dispelName and rawAura.dispelName or "nil"
            else
                dispelStr = "SECRET"
            end

            if idOk then
                -- test highlight curve
                local hlColor = _getCurveColor(unit, id, _dispelHighlightCurve)
                local hlInfo = "nil"
                if hlColor then
                    local ok, r, g, b, a = pcall(hlColor.GetRGBA, hlColor)
                    if ok then
                        local rS = issecretvalue(r) and "S" or string.format("%.2f", r)
                        local aS = issecretvalue(a) and "S" or string.format("%.2f", a)
                        hlInfo = "r=" .. rS .. " a=" .. aS
                    else
                        hlInfo = "GetRGBA failed"
                    end
                end

                -- test bracket curves
                local bracketResults = {}
                for _, t in ipairs(_dispelTypes) do
                    local color = _getCurveColor(unit, id, _bracketCurves[t.name])
                    if color then
                        local ok, _, _, _, a = pcall(color.GetRGBA, color)
                        local aStr = (ok and (issecretvalue(a) and "S" or string.format("%.1f", a))) or "ERR"
                        bracketResults[#bracketResults+1] = t.name .. "=" .. aStr
                    else
                        bracketResults[#bracketResults+1] = t.name .. "=nil"
                    end
                end

                print(string.format("  id=%s name=%s rawDispel=%s hl=[%s] [%s]",
                    tostring(id), nameStr, dispelStr,
                    hlInfo, table.concat(bracketResults, ", ")))
            else
                print(string.format("  id=SECRET name=%s rawDispel=%s", nameStr, dispelStr))
            end
        end
    end
end
-- F.PrintKnownDispels defined after _knownDispelTypes (see HandleDebuff section)

-------------------------------------------------
-- unit button func declarations
-------------------------------------------------
local UnitButton_UpdateAll
local UnitButton_UpdateAuras, UnitButton_UpdateRole, UnitButton_UpdateLeader, UnitButton_UpdateStatusText
local UnitButton_UpdateHealthColor, UnitButton_UpdateNameTextColor, UnitButton_UpdateHealthTextColor
local UnitButton_UpdatePowerMax, UnitButton_UpdatePower, UnitButton_UpdatePowerType, UnitButton_UpdatePowerText, UnitButton_UpdatePowerTextColor
local UnitButton_UpdateShieldAbsorbs
local CheckPowerEventRegistration, ShouldShowPowerText, ShouldShowPowerBar

-------------------------------------------------
-- unit button init indicators
-------------------------------------------------
local enabledIndicators = {}
local indicatorNums, indicatorBooleans, indicatorColors, indicatorCustoms = {}, {}, {}, {}

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

    for _, t in next, Cell.vars.currentLayoutTable["indicators"] do
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

        -- update aoehealing
        elseif t["indicatorName"] == "aoeHealing" then
            I.EnableAoEHealing(t["enabled"])

        -- update targetCounter
        elseif t["indicatorName"] == "targetCounter" then
            I.UpdateTargetCounterFilters(t["filters"], true)
            I.EnableTargetCounter(t["enabled"])

        -- update targetedSpells
        elseif t["indicatorName"] == "targetedSpells" then
            I.UpdateTargetedSpellsNum(t["num"])
            I.ShowAllTargetedSpells(t["showAllSpells"])
            I.EnableTargetedSpells(t["enabled"])

        -- update actions
        elseif t["indicatorName"] == "actions" then
            I.EnableActions(t["enabled"])

        -- update missingBuffs
        elseif t["indicatorName"] == "missingBuffs" then
            I.EnableMissingBuffs(t["enabled"])

        -- update healthThresholds
        elseif t["indicatorName"] == "healthThresholds" then
            I.UpdateHealthThresholds()
        end

        -- update extra
        if t["indicatorName"] == "nameText" or t["indicatorName"] == "powerText" then
            indicatorColors[t["indicatorName"]] = t["color"]
        end
        if t["indicatorName"] == "powerText" then
            indicatorCustoms[t["indicatorName"]] = t["filters"]
        end
        if t["indicatorName"] == "dispels" then
            indicatorBooleans["dispels"] = t["filters"]
        end
        if t["dispellableByMe"] ~= nil then
            indicatorBooleans[t["indicatorName"]] = t["dispellableByMe"]
        end
        if t["onlyShowTopGlow"] ~= nil then
            indicatorBooleans[t["indicatorName"]] = t["onlyShowTopGlow"]
        end
        if t["hideInCombat"] ~= nil then
            indicatorBooleans[t["indicatorName"]] = t["hideInCombat"]
        end
        if t["onlyEnableNotInCombat"] ~= nil then
            indicatorBooleans[t["indicatorName"]] = t["onlyEnableNotInCombat"]
        end
        if t["onlyShowOvershields"] ~= nil then
            indicatorBooleans[t["indicatorName"]] = t["onlyShowOvershields"]
        end
    end
end

local function HandleIndicators(b)
    b._indicatorsReady = nil

    if b._waitingForIndicatorCreation then
        b._waitingForIndicatorCreation = nil
        I.CreateDefensiveCooldowns(b)
        I.CreateExternalCooldowns(b)
        I.CreateAllCooldowns(b)
        I.CreateDebuffs(b)
    end

    -- NOTE: Remove old
    I.RemoveAllCustomIndicators(b)

    for _, t in next, b._config do
        local indicator = b.indicators[t["indicatorName"]] or I.CreateIndicator(b, t)
        indicator.configs = t

        -- update position
        if t["position"] then
            if t["indicatorName"] == "statusText" then
                indicator:SetPosition(t["position"][1], t["position"][2], t["position"][3])
            else
                P.ClearPoints(indicator)
                local relativeTo = t["position"][2] == "healthBar" and b.widgets.healthBar or b
                P.Point(indicator, t["position"][1], relativeTo, t["position"][3], t["position"][4], t["position"][5])
            end
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
                P.Size(indicator, t["size"][1], t["size"][2])
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
            P.Height(indicator, t["height"])
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
                B.UpdateHealthText(b)
            elseif t["indicatorName"] == "powerText" then
                B.UpdatePowerText(b)
            end
        end
        -- update color
        if t["color"] and t["indicatorName"] ~= "nameText" and t["indicatorName"] ~="powerText" then
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
        -- update icon style
        if t["iconStyle"] then
            indicator:SetIconStyle(t["iconStyle"])
        end
        -- update animation
        if type(t["showAnimation"]) == "boolean" then
            indicator:ShowAnimation(t["showAnimation"])
        end
        -- update duration
        if type(t["showDuration"]) == "boolean" or type(t["showDuration"]) == "number" then
            indicator:ShowDuration(t["showDuration"])
        end
        -- update stack
        if type(t["showStack"]) == "boolean" then
            indicator:ShowStack(t["showStack"])
        end
        -- update duration
        if t["duration"] then
            indicator:SetDuration(t["duration"])
        end
        -- update stack
        if t["stack"] then
            indicator:SetStack(t["stack"])
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
            indicator:SetupGlow(t["glowOptions"])
        end
        -- update smooth
        if type(t["smooth"]) == "boolean" then
            indicator:EnableSmooth(t["smooth"])
        end
        -- max value
        if t["maxValue"] then
            indicator:SetMaxValue(t["maxValue"])
        end
        -- update hideIfEmptyOrFull
        if type(t["hideIfEmptyOrFull"]) == "boolean" then
            indicator:SetHideIfEmptyOrFull(t["hideIfEmptyOrFull"])
        end

        -- init
        -- update name visibility
        if t["indicatorName"] == "nameText" or t["indicatorName"] == "healthText" then
            if t["enabled"] then
                indicator:Show()
            else
                indicator:Hide()
            end
        elseif t["indicatorName"] == "playerRaidIcon" then
            B.UpdatePlayerRaidIcon(b, t["enabled"])
        elseif t["indicatorName"] == "targetRaidIcon" then
            B.UpdateTargetRaidIcon(b, t["enabled"])
        elseif t["indicatorName"] == "readyCheckIcon" then
            B.UpdateReadyCheckIcon(b, t["enabled"])
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
    B.UpdatePixelPerfect(b, true)

    b._indicatorsReady = true
end

-------------------------------------------------
-- indicator update queue
-------------------------------------------------
local updater = CreateFrame("Frame")
updater:Hide()
local queue = {}

local WAITING_FOR_INIT = "WAITING_FOR_INIT"
local WAITING_FOR_UPDATE = "WAITING_FOR_UPDATE"

local function Process(b)
    if b then
        -- print("Process", GetTime(), b:GetName(), b._status)
        if b._status == WAITING_FOR_INIT then
            -- print("processing_init", GetTime(), b:GetName())
            b._status = "processing"
            HandleIndicators(b)
            UnitButton_UpdateAuras(b)
        elseif b._status == WAITING_FOR_UPDATE then
            -- print("processing_update", GetTime(), b:GetName())
            b._indicatorsReady = true
            b._status = "processing"
            UnitButton_UpdateAuras(b)
        end

        CellLoadingBar.current = (CellLoadingBar.current or 0) + 1
        CellLoadingBar:SetValue(CellLoadingBar.current)
        b._status = nil
        b._config = nil
        queue[b] = nil
    else
        CellLoadingBar:Hide()
        CellLoadingBar.current = 0
        updater:Hide()
    end
end

updater:SetScript("OnUpdate", function()
    Process(next(queue))
    Process(next(queue))
end)

hooksecurefunc(updater, "Show", function()
    CellLoadingBar.total = F.Getn(queue)
    CellLoadingBar.current = 0
    CellLoadingBar:SetMinMaxValues(0, CellLoadingBar.total)
    CellLoadingBar:SetValue(0)
    CellLoadingBar:Show()
end)

local function FlushQueue()
    updater:Hide()
    wipe(queue)
end

local function AddToInitQueue(b)
    b._indicatorsReady = nil
    b._status = WAITING_FOR_INIT
    b._config = Cell.vars.currentLayoutTable["indicators"]
    queue[b] = true
end

local function AddToUpdateQueue(b)
    if queue[b] then return end
    b._indicatorsReady = nil
    b._status = WAITING_FOR_UPDATE
    queue[b] = true
end

-------------------------------------------------
-- UpdateIndicators
-------------------------------------------------
local activeLayouts = {
    solo = nil,
    party = nil,
    raid = nil,
}

local function UpdateIndicators(layout, indicatorName, setting, value, value2)
    F.Debug("|cffff7777UpdateIndicators:|r ", layout, indicatorName, setting, value, value2)

    -- FlushQueue()

    local currentLayout = Cell.vars.currentLayout
    local INDEX = Cell.vars.groupType

    if layout then
        -- Cell.Fire("UpdateIndicators", layout): indicators copy/import
        -- Cell.Fire("UpdateIndicators", xxx, ...): indicator updated
        for groupType, groupLayout in next, activeLayouts do
            if groupLayout == layout then
                activeLayouts[groupType] = nil -- update required
                F.Debug("  -> UPDATE REQUIRED:", groupType)
            end
        end

        --! indicator changed, but not current layout
        if layout ~= currentLayout then
            F.Debug("  -> NO UPDATE: not active layout")
            return
        end

    else -- Cell.Fire("UpdateIndicators")
        --! layout/groupType switched, check if update is required
        if activeLayouts[INDEX] == currentLayout then
            I.ResetCustomIndicatorTables()
            ResetIndicators()
            F.Debug("  -> NO FULL UPDATE: only reset custom indicator tables")
            F.IterateAllUnitButtons(AddToUpdateQueue, true, nil, true)
            F.IterateSharedUnitButtons(AddToInitQueue)
            updater:Show()
            return
        end
    end

    if Cell.vars.isHidden then
        F.Debug("  -> NO UPDATE: Cell is hidden")
        I.ResetCustomIndicatorTables()
        ResetIndicators()
        return
    end

    activeLayouts[INDEX] = currentLayout

    if not indicatorName then -- init
        F.Debug("  -> FULL UPDATE", INDEX, currentLayout)
        I.ResetCustomIndicatorTables()
        ResetIndicators()
        F.IterateAllUnitButtons(AddToInitQueue, true)
        updater:Show()

    else
        -- changed in IndicatorsTab
        if setting == "enabled" then
            enabledIndicators[indicatorName] = value

            if indicatorName == "combatIcon" then
                F.IterateAllUnitButtons(function(b)
                    if not value then
                        b.indicators[indicatorName]:Hide()
                    end
                end, true)
            elseif indicatorName == "aoeHealing" then
                I.EnableAoEHealing(value)
            elseif indicatorName == "targetCounter" then
                I.EnableTargetCounter(value)
            elseif indicatorName == "targetedSpells" then
                I.EnableTargetedSpells(value)
            elseif indicatorName == "actions" then
                I.EnableActions(value)
            elseif indicatorName == "roleIcon" then
                F.IterateAllUnitButtons(function(b)
                    UnitButton_UpdateRole(b)
                end, true)
            elseif indicatorName == "leaderIcon" then
                F.IterateAllUnitButtons(function(b)
                    UnitButton_UpdateLeader(b)
                end, true)
            elseif indicatorName == "playerRaidIcon" then
                F.IterateAllUnitButtons(function(b)
                    B.UpdatePlayerRaidIcon(b, value)
                end, true)
            elseif indicatorName == "targetRaidIcon" then
                F.IterateAllUnitButtons(function(b)
                    B.UpdateTargetRaidIcon(b, value)
                end, true)
            elseif indicatorName == "readyCheckIcon" then
                F.IterateAllUnitButtons(function(b)
                    B.UpdateReadyCheckIcon(b, value)
                end, true)
            elseif indicatorName == "nameText" then
                F.IterateAllUnitButtons(function(b)
                    if value then
                        b.indicators[indicatorName]:Show()
                    else
                        b.indicators[indicatorName]:Hide()
                    end
                end, true)
            elseif indicatorName == "statusText" then
                F.IterateAllUnitButtons(function(b)
                    B.UpdateStatusText(b)
                end, true)
            elseif indicatorName == "healthText" then
                F.IterateAllUnitButtons(function(b)
                    if value then
                        b.indicators[indicatorName]:Show()
                        B.UpdateHealthText(b)
                    else
                        b.indicators[indicatorName]:Hide()
                    end
                end, true)
            elseif indicatorName == "powerText" then
                F.IterateAllUnitButtons(function(b)
                    b._shouldShowPowerText = ShouldShowPowerText(b)
                    CheckPowerEventRegistration(b)
                    if b._shouldShowPowerText then
                        B.UpdatePowerText(b)
                    else
                        b.indicators[indicatorName]:Hide()
                    end
                end, true)
            elseif indicatorName == "shieldBar" then
                F.IterateAllUnitButtons(function(b)
                    B.UpdateShield(b)
                end, true)
            elseif indicatorName == "healthThresholds" then
                if value then
                    I.UpdateHealthThresholds()
                end
                F.IterateAllUnitButtons(function(b)
                    B.UpdateHealth(b)
                end, true)
            elseif indicatorName == "missingBuffs" then
                I.EnableMissingBuffs(value)
                F.IterateAllUnitButtons(function(b)
                    UpdateIndicatorParentVisibility(b, indicatorName, value)
                end, true)
            else
                -- refresh
                F.IterateAllUnitButtons(function(b)
                    UpdateIndicatorParentVisibility(b, indicatorName, value)
                    if not value then
                        b.indicators[indicatorName]:Hide() -- hide indicators which is shown right now
                    end
                    UnitButton_UpdateAuras(b)
                end, true)
            end
        elseif setting == "position" then
            F.IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                if indicatorName == "statusText" then
                    indicator:SetPosition(value[1], value[2], value[3])
                else
                    P.ClearPoints(indicator)
                    local relativeTo = value[2] == "healthBar" and b.widgets.healthBar or b
                    P.Point(indicator, value[1], relativeTo, value[3], value[4], value[5])
                end
                -- update arrangement
                if indicator.indicatorType == "icons" then
                    indicator:SetOrientation(indicator.orientation)
                end
            end, true)
        elseif setting == "anchor" then
            F.IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:SetAnchor(value)
            end, true)
        elseif setting == "frameLevel" then
            F.IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:SetFrameLevel(indicator:GetParent():GetFrameLevel()+value)
            end, true)
        elseif setting == "size" then
            F.IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                if indicatorName == "debuffs" then
                    indicator:SetSize(value[1], value[2])
                    -- update debuffs' normal/big icon sizes
                    UnitButton_UpdateAuras(b)
                else
                    P.Size(indicator, value[1], value[2])
                end
            end, true)
        elseif setting == "size-border" then
            F.IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                P.Size(indicator, value[1], value[2])
                indicator:SetBorder(value[3])
            end, true)
        elseif setting == "thickness" then
            F.IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:SetThickness(value)
            end, true)
        elseif setting == "height" then
            F.IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                P.Height(indicator, value)
            end, true)
        elseif setting == "textWidth" then
            F.IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:UpdateTextWidth(value)
            end, true)
        elseif setting == "alpha" then
            F.IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:SetAlpha(value)
            end, true)
        elseif setting == "spacing" then
            F.IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:SetSpacing(value)
            end, true)
        elseif setting == "orientation" then
            F.IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:SetOrientation(value)
            end, true)
        elseif setting == "font" then
            F.IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:SetFont(unpack(value))
            end, true)
        elseif setting == "format" then
            if indicatorName == "healthText" then
                F.IterateAllUnitButtons(function(b)
                    local indicator = b.indicators[indicatorName]
                    indicator:SetFormat(value)
                    B.UpdateHealthText(b)
                end, true)
            elseif indicatorName == "powerText" then
                F.IterateAllUnitButtons(function(b)
                    local indicator = b.indicators[indicatorName]
                    indicator:SetFormat(value)
                    B.UpdatePowerText(b)
                end, true)
            end
        elseif setting == "color" then
            if indicatorName == "nameText" then
                indicatorColors[indicatorName] = value
                F.IterateAllUnitButtons(function(b)
                    UnitButton_UpdateNameTextColor(b)
                end, true)
            elseif indicatorName == "powerText" then
                indicatorColors[indicatorName] = value
                F.IterateAllUnitButtons(function(b)
                    UnitButton_UpdatePowerTextColor(b)
                end, true)
            else
                F.IterateAllUnitButtons(function(b)
                    local indicator = b.indicators[indicatorName]
                    indicator:SetColor(unpack(value))
                end, true)
            end
        elseif setting == "colors" then
            F.IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:SetColors(value) -- update color on next SetCooldown
                UnitButton_UpdateAuras(b) -- call SetCooldown now
            end, true)
        elseif setting == "vehicleNamePosition" then
            F.IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:UpdateVehicleNamePosition(value)
            end, true)
        elseif setting == "statusColors" then
            F.IterateAllUnitButtons(function(b)
                UnitButton_UpdateStatusText(b)
            end, true)
        elseif setting == "num" then
            indicatorNums[indicatorName] = value
            if indicatorName == "targetedSpells" then
                I.UpdateTargetedSpellsNum(value)
            else
                -- refresh
                F.IterateAllUnitButtons(function(b)
                    UnitButton_UpdateAuras(b)
                end, true)
            end
        elseif setting == "numPerLine" then
            F.IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:SetNumPerLine(value)
            end, true)
        elseif setting == "roleTexture" then
            F.IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:SetRoleTexture(value)
                UnitButton_UpdateRole(b)
            end, true)
        elseif setting == "texture" then
            F.IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:SetTexture(value)
            end, true)
        elseif setting == "duration" or setting == "dispelFilters" then
            F.IterateAllUnitButtons(function(b)
                UnitButton_UpdateAuras(b)
            end, true)
        elseif setting == "stack" then
            F.IterateAllUnitButtons(function(b)
                b.indicators[indicatorName]:SetStack(value)
                UnitButton_UpdateAuras(b)
            end, true)
        elseif setting == "highlightType" then
            F.IterateAllUnitButtons(function(b)
                b.indicators[indicatorName]:UpdateHighlight(value)
                UnitButton_UpdateAuras(b)
            end, true)
        elseif setting == "thresholds" then
            I.UpdateHealthThresholds()
            F.IterateAllUnitButtons(function(b)
                B.UpdateHealth(b)
            end, true)
        elseif setting == "showDuration" then
            F.IterateAllUnitButtons(function(b)
                b.indicators[indicatorName]:ShowDuration(value)
                UnitButton_UpdateAuras(b)
            end, true)
        elseif setting == "privateAuraOptions" then
            F.IterateAllUnitButtons(function(b)
                b.indicators[indicatorName]:UpdateOptions(value)
            end, true)
        elseif setting == "powerTextFilters" then
            F.IterateAllUnitButtons(function(b)
                b._shouldShowPowerText = ShouldShowPowerText(b)
                CheckPowerEventRegistration(b)
                if b._shouldShowPowerText then
                    B.UpdatePowerText(b)
                else
                    b.indicators[indicatorName]:Hide()
                end
            end, true)
        elseif setting == "targetCounterFilters" then
            I.UpdateTargetCounterFilters()
        elseif setting == "maxValue" then
            F.IterateAllUnitButtons(function(b)
                b.indicators[indicatorName]:SetMaxValue(value)
                UnitButton_UpdateAuras(b)
            end, true)
        elseif setting == "glowOptions" then
            F.IterateAllUnitButtons(function(b)
                b.indicators[indicatorName]:SetupGlow(value)
                UnitButton_UpdateAuras(b)
            end, true)
        elseif setting == "iconStyle" then
            F.IterateAllUnitButtons(function(b)
                b.indicators[indicatorName]:SetIconStyle(value)
                UnitButton_UpdateAuras(b)
            end, true)
        elseif setting == "checkbutton" then
            if value == "showGroupNumber" then
                F.IterateAllUnitButtons(function(b)
                    b.indicators[indicatorName]:ShowGroupNumber(value2)
                end, true)
            elseif value == "showTimer" then
                F.IterateAllUnitButtons(function(b)
                    b.indicators[indicatorName]:SetShowTimer(value2)
                    UnitButton_UpdateStatusText(b)
                end, true)
            elseif value == "showBackground" then
                F.IterateAllUnitButtons(function(b)
                    b.indicators[indicatorName]:ShowBackground(value2)
                end, true)
            elseif value == "hideIfEmptyOrFull" then
                if indicatorName == "powerText" then
                    F.IterateAllUnitButtons(function(b)
                        b.indicators[indicatorName]:SetHideIfEmptyOrFull(value2)
                        B.UpdatePowerText(b)
                    end, true)
                end
            elseif value == "hideInCombat" then
                indicatorBooleans[indicatorName] = value2
                F.IterateAllUnitButtons(function(b)
                    UnitButton_UpdateLeader(b)
                end, true)
            elseif value == "onlyEnableNotInCombat" then
                indicatorBooleans[indicatorName] = value2
                F.IterateAllUnitButtons(function(b)
                    b.indicators[indicatorName]:Hide()
                end, true)
            elseif value == "onlyShowOvershields" then
                indicatorBooleans[indicatorName] = value2
                F.IterateAllUnitButtons(function(b)
                    UnitButton_UpdateShieldAbsorbs(b)
                end, true)
            elseif value == "showStack" then
                F.IterateAllUnitButtons(function(b)
                    b.indicators[indicatorName]:ShowStack(value2)
                    UnitButton_UpdateAuras(b)
                end, true)
            elseif value == "showAnimation" then
                F.IterateAllUnitButtons(function(b)
                    b.indicators[indicatorName]:ShowAnimation(value2)
                    UnitButton_UpdateAuras(b)
                end, true)
            elseif value == "trackByName" then
                F.IterateAllUnitButtons(function(b)
                    UnitButton_UpdateAuras(b)
                end, true)
            elseif value == "dispellableByMe" then
                indicatorBooleans[indicatorName] = value2
                F.IterateAllUnitButtons(function(b)
                    UnitButton_UpdateAuras(b)
                end, true)
            elseif value == "showTooltip" then
                F.IterateAllUnitButtons(function(b)
                    b.indicators[indicatorName]:ShowTooltip(value2)
                end, true)
            elseif value == "enableBlacklistShortcut" then
                F.IterateAllUnitButtons(function(b)
                    b.indicators[indicatorName]:EnableBlacklistShortcut(value2)
                end, true)
            elseif value == "hideDamager" then
                F.IterateAllUnitButtons(function(b)
                    b.indicators[indicatorName]:HideDamager(value2)
                    UnitButton_UpdateRole(b)
                end, true)
            elseif value == "fadeOut" then
                F.IterateAllUnitButtons(function(b)
                    b.indicators[indicatorName]:SetFadeOut(value2)
                    UnitButton_UpdateAuras(b)
                end, true)
            elseif value == "smooth" then
                F.IterateAllUnitButtons(function(b)
                    b.indicators[indicatorName]:EnableSmooth(value2)
                end, true)
            elseif value == "showAllSpells" then
                I.ShowAllTargetedSpells(value2)
            else
                indicatorBooleans[indicatorName] = value2
            end
        elseif setting == "create" then
            I.UpdateIndicatorTable(value)
            F.IterateAllUnitButtons(function(b)
                local indicator = I.CreateIndicator(b, value)
                indicator.configs = value

                -- update position
                if value["position"] then
                    P.ClearPoints(indicator)
                    local relativeTo = value["position"][2] == "healthBar" and b.widgets.healthBar or b
                    P.Point(indicator, value["position"][1], relativeTo, value["position"][3], value["position"][4], value["position"][5])
                end
                -- update anchor
                if value["anchor"] then
                    indicator:SetAnchor(value["anchor"])
                end
                -- update size
                if value["size"] then
                    P.Size(indicator, value["size"][1], value["size"][2])
                end
                -- update thickness
                if value["thickness"] then
                    indicator:SetThickness(value["thickness"])
                end
                -- update frameLevel
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
                -- update showAnimation
                if type(value["showAnimation"]) == "boolean" then
                    indicator:ShowAnimation(value["showAnimation"])
                end
                -- update showDuration
                if type(value["showDuration"]) ~= "nil" then
                    indicator:ShowDuration(value["showDuration"])
                end
                -- update showStack
                if type(value["showStack"]) ~= "nil" then
                    indicator:ShowStack(value["showStack"])
                end
                -- update duration
                if value["duration"] then
                    indicator:SetDuration(value["duration"])
                end
                -- update stack
                if value["stack"] then
                    indicator:SetStack(value["stack"])
                end
                -- update fadeOut
                if type(value["fadeOut"]) == "boolean" then
                    indicator:SetFadeOut(value["fadeOut"])
                end
                -- update glow
                if value["glowOptions"] then
                    indicator:SetupGlow(value["glowOptions"])
                end
                -- FirstRun: Healers
                if value["auras"] and #value["auras"] ~= 0 then
                    UnitButton_UpdateAuras(b)
                end
            end, true)
        elseif setting == "remove" then
            F.IterateAllUnitButtons(function(b)
                I.RemoveIndicator(b, indicatorName, value)
            end, true)
        elseif setting == "auras" then
            -- indicator auras changed, hide them all, then recheck whether to show
            F.IterateAllUnitButtons(function(b)
                b.indicators[indicatorName]:Hide()
                UnitButton_UpdateAuras(b)
            end, true)
        elseif setting == "debuffBlacklist" or setting == "dispelBlacklist" or setting == "defensives" or setting == "externals" or setting == "crowdControls" or setting == "bigDebuffs" or setting == "debuffTypeColor" or setting == "castBy" then
            F.IterateAllUnitButtons(function(b)
                UnitButton_UpdateAuras(b)
            end, true)
        elseif setting == "speed" then
            -- only Actions indicator has this option for now
            F.IterateAllUnitButtons(function(b)
                b.indicators[indicatorName]:SetSpeed(value)
            end, true)
        end
    end
end
Cell.RegisterCallback("UpdateIndicators", "UnitButton_UpdateIndicators", UpdateIndicators)

-------------------------------------------------
-- ForEachAura
-------------------------------------------------
local function ForEachAuraHelper(button, func, continuationToken, ...)
    -- continuationToken is the first return value of GetAuraSlots()
    local n = select('#', ...)
    for i = 1, n do
        local slot = select(i, ...)
        local auraInfo = GetAuraDataBySlot(button.states.displayedUnit, slot)
        if auraInfo then
            -- auraInfo.index = i
            func(button, auraInfo)
        end
        -- local done = func(button, auraInfo)
        -- if done then
        --     -- if func returns true then no further slots are needed, so don't return continuationToken
        --     return nil
        -- end
    end
end

local function ForEachAura(button, filter, func)
    ForEachAuraHelper(button, func, GetAuraSlots(button.states.displayedUnit, filter))
end

-------------------------------------------------
-- ForEachAuraCache
-------------------------------------------------
local function ForEachAuraCache(button, filter, func)
    if filter == "HARMFUL" then
        for auraInstanceID, aura in next, button._debuffs_cache do
            func(button, aura)
        end
    elseif filter == "HELPFUL" then
        for auraInstanceID, aura in next, button._buffs_cache do
            func(button, aura)
        end
    end
end

-------------------------------------------------
-- UpdateAuraRefreshState
-------------------------------------------------
local function UpdateAuraRefreshState(auraInfo)
    if Cell.vars.iconAnimation == "duration" then
        local timeIncreased, countIncreased
        if Cell.isMidnight and (
            not F.IsValueNonSecret(auraInfo.expirationTime)
            or not F.IsValueNonSecret(auraInfo.oldExpirationTime)
            or not F.IsValueNonSecret(auraInfo.applications)
            or not F.IsValueNonSecret(auraInfo.oldApplications)
        ) then
            -- One or more fields are secret: can't do arithmetic/comparison (Midnight 12.0.0+)
            timeIncreased = false
            countIncreased = false
        else
            timeIncreased = auraInfo.oldExpirationTime and ((auraInfo.expirationTime or 0) - auraInfo.oldExpirationTime >= 0.5) or false
            countIncreased = auraInfo.oldApplications and (auraInfo.applications > auraInfo.oldApplications) or false
        end
        auraInfo.refreshing = timeIncreased or countIncreased
    elseif Cell.vars.iconAnimation == "stack" then
        if Cell.isMidnight and (
            not F.IsValueNonSecret(auraInfo.applications)
            or not F.IsValueNonSecret(auraInfo.oldApplications)
        ) then
            -- Secret applications: can't compare (Midnight 12.0.0+)
            auraInfo.refreshing = false
        else
            auraInfo.refreshing = auraInfo.oldApplications and (auraInfo.applications > auraInfo.oldApplications) or false
        end
    else
        auraInfo.refreshing = false
    end

    auraInfo.oldExpirationTime = nil
    auraInfo.oldApplications = nil
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
    self._debuffs.crowdControlsFound = 0
    self._secretDispelAuraID = nil
    self._secretDispelUnit = nil

    self.states.BGOrb = nil -- TODO: move to _debuffs
end

-- 12.0+: fields to preserve from old cache when current read returns nil (secret)
local _secretMergeFields = {"name", "icon", "sourceUnit", "spellId", "dispelName", "_rawSpellId"}

local function _mergeSecretAura(auraInfo, oldCache)
    if not oldCache then return end
    local old = oldCache[auraInfo.auraInstanceID]
    if not old then return end
    for _, field in ipairs(_secretMergeFields) do
        if auraInfo[field] == nil and old[field] ~= nil then
            auraInfo[field] = old[field]
        end
    end
    -- clear secret flag if dispelName was successfully restored from cache
    if auraInfo.dispelName and auraInfo._dispelNameIsSecret then
        auraInfo._dispelNameIsSecret = false
    end
    -- preserve duration/expirationTime if both defaulted to 0 but old had real values
    if auraInfo.duration == 0 and old.duration and old.duration > 0 then
        auraInfo.duration = old.duration
    end
    if auraInfo.expirationTime == 0 and old.expirationTime and old.expirationTime > 0 then
        auraInfo.expirationTime = old.expirationTime
    end
    -- preserve boolean fields that defaulted to false but old had true
    if not auraInfo.isHelpful and old.isHelpful then
        auraInfo.isHelpful = old.isHelpful
    end
    if not auraInfo.isHarmful and old.isHarmful then
        auraInfo.isHarmful = old.isHarmful
    end
    if not auraInfo.isFromPlayerOrPlayerPet and old.isFromPlayerOrPlayerPet then
        auraInfo.isFromPlayerOrPlayerPet = old.isFromPlayerOrPlayerPet
    end
end

-- upvalue set by UnitButton_UpdateDebuffs/UpdateBuffs during combat full updates
local _oldDebuffsCache, _oldBuffsCache

-- persistent spellId → dispelName cache; survives across auraInstanceID changes
local _knownDispelTypes = {}
function F.PrintKnownDispels()
    local n = 0
    print("|cff00ff00[Cell Known Dispel Types]|r")
    for spellId, dispelType in pairs(_knownDispelTypes) do
        print(string.format("  %d = %s", spellId, dispelType))
        n = n + 1
    end
    print("  Total:", n, "entries")
end

-- 12.0+: activate vertical StatusBar cooldown animation for secret durations.
-- SetMinMaxValues/SetValue are C-level and accept secrets.
-- GetValue() returns tainted after SetMinMaxValues with secret max, so we
-- use a custom OnUpdate that tracks elapsed with non-secret arithmetic only.
-- Duration text is not supported for secret auras (SetFormattedText produces
-- invisible output with secret values).
local function _ActivateSecretCooldown(frame, auraInfo, unit)
    local cd = frame.cooldown

    if cd and cd._SetCooldown then
        -- BorderIcon: Blizzard CooldownFrame with clock swipe.
        -- Use GetAuraDuration (NOT restricted) to get a LuaDurationObject,
        -- then read start/total via C-level methods — no Lua arithmetic on secrets.
        local ok = false
        if _GetAuraDuration and unit and auraInfo.auraInstanceID then
            ok = pcall(function()
                local dur = _GetAuraDuration(unit, auraInfo.auraInstanceID)
                if dur and not dur:IsZero() then
                    cd:_SetCooldown(dur:GetStartTime(), dur:GetTotalDuration())
                end
            end)
        end
        if ok then
            if frame.border then frame.border:Hide() end
            cd:Show()
        end
        -- if GetAuraDuration fails, border stays visible (static colored display)
    elseif cd and cd.SetMinMaxValues then
        -- BarIcon: StatusBar with vertical fill animation.
        -- Use GetAuraDuration to get non-tainted start/duration values.
        -- Do NOT pass secret values to SetMinMaxValues — it permanently
        -- taints the StatusBar, causing GetValue() to return tainted values
        -- that crash VerticalCooldown_OnUpdate.
        local ok = false
        if _GetAuraDuration and unit and auraInfo.auraInstanceID then
            ok = pcall(function()
                local dur = _GetAuraDuration(unit, auraInfo.auraInstanceID)
                if dur and not dur:IsZero() then
                    cd:SetMinMaxValues(0, dur:GetTotalDuration())
                    cd:SetValue(dur:GetElapsedDuration())
                end
            end)
        end
        if ok then
            if cd.icon and auraInfo.icon then
                pcall(cd.icon.SetTexture, cd.icon, auraInfo.icon)
            end
            if cd.spark then
                cd.spark:SetColorTexture(0.5, 0.5, 0.5)
            end
            -- Save original OnUpdate so we can restore it on deactivation
            if not cd._origOnUpdate then
                cd._origOnUpdate = cd:GetScript("OnUpdate")
            end
            cd._secretUnit = unit
            cd._secretAuraID = auraInfo.auraInstanceID
            cd:SetScript("OnUpdate", function(self, elapsed)
                self._secretElapsed = (self._secretElapsed or 0) + elapsed
                if self._secretElapsed >= 0.1 then
                    self._secretElapsed = 0
                    pcall(function()
                        local dur = _GetAuraDuration(self._secretUnit, self._secretAuraID)
                        if dur and not dur:IsZero() then
                            self:SetMinMaxValues(0, dur:GetTotalDuration())
                            self:SetValue(dur:GetElapsedDuration())
                        end
                    end)
                end
            end)
            cd:Show()
        end
    end

    -- Hide duration text — secret values can't be rendered visibly
    if frame.duration then frame.duration:Hide() end

    frame._secretClockActive = true
end

local function _DeactivateSecretCooldown(frame)
    frame._secretClockActive = nil
    -- Restore border for BorderIcon (CooldownFrame path)
    if frame.border then
        frame.border:Show()
    end
    -- Restore original OnUpdate for vertical cooldown bars (StatusBar path)
    if frame.cooldown then
        if frame.cooldown._origOnUpdate then
            frame.cooldown:SetScript("OnUpdate", frame.cooldown._origOnUpdate)
            frame.cooldown._origOnUpdate = nil
        end
        frame.cooldown._secretStartTime = nil
        frame.cooldown._secretElapsed = nil
        frame.cooldown._secretUnit = nil
        frame.cooldown._secretAuraID = nil
        -- Reset StatusBar to untainted state if it was used for vertical cooldown
        if frame.cooldown.SetMinMaxValues and not frame.cooldown._SetCooldown then
            frame.cooldown:SetMinMaxValues(0, 1)
            frame.cooldown:SetValue(0)
            frame.cooldown:Hide()
        end
    end
end

-- Post-process a set of indicator frames to fix secret-duration cooldowns
local function _FixSecretCooldowns(indicators, count, cache, unit)
    for i = 1, count do
        local frame = indicators[i]
        if frame then
            local aid = frame.auraInstanceID
            local auraInfo = aid and cache[aid]
            if auraInfo and auraInfo.duration == 0 and issecretvalue(auraInfo._rawDuration) then
                _ActivateSecretCooldown(frame, auraInfo, unit)
            elseif frame._secretClockActive then
                _DeactivateSecretCooldown(frame)
            end
        end
    end
end

local function HandleDebuff(self, auraInfo)
    local auraInstanceID = auraInfo.auraInstanceID

    -- 12.0+: merge with previously-known good data when fields are secret
    if _oldDebuffsCache then
        _mergeSecretAura(auraInfo, _oldDebuffsCache)
    end

    local name = auraInfo.name
    -- auraInfo.icon may be a secret fileID on Midnight 12.0.0+
    -- SetTexture() accepts secret numbers, so this works as-is
    local icon = auraInfo.icon
    local count = auraInfo.applications
    local debuffType = auraInfo.dispelName or ""
    local spellId = auraInfo.spellId

    -- 12.0+: try to resolve spellId/name from raw secret via C_Spell (C-level API)
    if not spellId and auraInfo._rawSpellId and C_Spell and C_Spell.GetSpellName then
        local ok, resolvedName = pcall(C_Spell.GetSpellName, auraInfo._rawSpellId)
        if ok and resolvedName and not issecretvalue(resolvedName) then
            auraInfo.name = resolvedName
            name = resolvedName
            -- C_Spell.GetSpellInfo returns a table with spellID field
            local ok2, info = pcall(C_Spell.GetSpellInfo, auraInfo._rawSpellId)
            if ok2 and info and info.spellID and not issecretvalue(info.spellID) then
                auraInfo.spellId = info.spellID
                spellId = info.spellID
            end
        end
    end

    -- 12.0+: resolve secret dispelName via multiple fallbacks
    if debuffType == "" and InCombatLockdown() then
        -- fallback 1: persistent spellId → dispelName cache
        if spellId and _knownDispelTypes[spellId] then
            debuffType = _knownDispelTypes[spellId]
            auraInfo.dispelName = debuffType
        end
        -- fallback 2: if dispelName was secret (not just nil), this IS dispellable
        -- but we can't read the type name. Store auraInstanceID for curve-based
        -- display later (highlight + icons via bracket curves).
        if debuffType == "" and auraInfo._dispelNameIsSecret and self.states.displayedUnit then
            self._secretDispelAuraID = auraInstanceID
            self._secretDispelUnit = self.states.displayedUnit
        end
    end

    -- learn dispelName for this spellId whenever both are readable
    if spellId and debuffType ~= "" then
        _knownDispelTypes[spellId] = debuffType
    end

    local expirationTime = auraInfo.expirationTime or 0
    local duration = auraInfo.duration
    -- Midnight 12.0.0+: expirationTime and duration may be secret even when spellId is not.
    -- Guard per-field: non-secret temporal fields get proper duration/cooldown display.
    local start
    if F.IsValueNonSecret(expirationTime) and F.IsValueNonSecret(duration) then
        start = expirationTime - duration
    else
        start = 0
        duration = 0
    end
    local source = auraInfo.sourceUnit
    -- local attribute = auraInfo.points[1] -- UnitAura:arg16

    auraInfo.refreshing = false

    if _dispelTraceEnabled and auraInfo.isHarmful then
        print(string.format("|cff00ff00[Dispel]|r id=%s name=%s dispel=%s spellId=%s secret=%s stored=%s",
            tostring(auraInstanceID), tostring(name),
            tostring(debuffType), tostring(spellId),
            tostring(auraInfo._dispelNameIsSecret),
            tostring(self._secretDispelAuraID)))
    end

    -- check Bleed
    -- On Midnight in restricted context, spellId may be secret; I.CheckDebuffType guards internally
    debuffType = I.CheckDebuffType(debuffType, spellId)

    if duration then
        UpdateAuraRefreshState(auraInfo)
        self._debuffs_cache[auraInstanceID] = auraInfo

        local isBig = false
        local isBlacklisted = false
        local isDispelBlacklisted = false
        -- spellId is nil for sanitized secrets, but may be restored by _mergeSecretAura
        if spellId then
            isBig = Cell.vars.bigDebuffs[spellId] or false
            isBlacklisted = Cell.vars.debuffBlacklist[spellId] or false
            isDispelBlacklisted = Cell.vars.dispelBlacklist[spellId] or false
        end

        if enabledIndicators["debuffs"] and not isBlacklisted then
            -- all debuffs / only dispellableByMe
            local canDispel = not indicatorBooleans["debuffs"] or I.CanDispel(debuffType)
            -- 12.0+: when dispelName is secret, use server-side filter to check
            -- if this player can dispel it (works without knowing the type name)
            if not canDispel and auraInfo._dispelNameIsSecret
                and _IsAuraFilteredOut and self.states.displayedUnit then
                canDispel = not _IsAuraFilteredOut(self.states.displayedUnit,
                    auraInstanceID, "HARMFUL|RAID_PLAYER_DISPELLABLE")
            end
            if canDispel then
                if isBig then
                    self._debuffs_big[auraInstanceID] = true
                else
                    self._debuffs_normal[auraInstanceID] = true
                end
            end
        end

        -- user created indicators
        I.UpdateCustomIndicators(self, auraInfo)

        -- prepare raidDebuffs
        local order = I.GetDebuffOrder(name, spellId, count)
        -- 12.0+: when spellId/name are secret, fall back to server RAID flag
        -- IsAuraFilteredOutByInstanceID accepts secret auraInstanceID and
        -- returns non-secret bool (not SecretWhenUnitAuraRestricted)
        if not order and auraInfo._hasSecrets and enabledIndicators["raidDebuffs"]
            and _IsAuraFilteredOut and self.states.displayedUnit then
            local isRaid = not _IsAuraFilteredOut(self.states.displayedUnit,
                auraInstanceID, "HARMFUL|RAID")
            if isRaid then
                order = 100 -- default order for server-flagged raid debuffs
            end
        end
        if enabledIndicators["raidDebuffs"] and order then
            auraInfo.raidDebuffOrder = order
            tinsert(self._debuffs_raid, auraInstanceID)

            if not indicatorBooleans["raidDebuffs"] then -- glow all
                local glowType, glowOptions = I.GetDebuffGlow(name, spellId, count)
                if glowType and glowType ~= "None" then
                    auraInfo.raidDebuffGlowType = glowType
                    auraInfo.raidDebuffGlowOptions = glowOptions
                    self._debuffs_glow_current[glowType] = glowOptions
                end
            end
        end

        if enabledIndicators["dispels"] and debuffType and debuffType ~= "" then
            -- all dispels / only dispellableByMe
            if not indicatorBooleans ["dispels"]["dispellableByMe"] or I.CanDispel(debuffType) then
                if indicatorBooleans["dispels"][debuffType] then
                    if isDispelBlacklisted then
                        -- no highlight
                        self._debuffs_dispel[debuffType] = false
                    else
                        self._debuffs_dispel[debuffType] = true
                    end
                end
            end
        end

        -- crowdControls
        if enabledIndicators["crowdControls"] and I.IsCrowdControls(name, spellId) and self._debuffs.crowdControlsFound < indicatorNums["crowdControls"] then
            self._debuffs.crowdControlsFound = self._debuffs.crowdControlsFound + 1
            self.indicators.crowdControls[self._debuffs.crowdControlsFound]:SetCooldown(start, duration, debuffType, icon, count, auraInfo.refreshing)
            -- remove from debuffs
            self._debuffs_big[auraInstanceID] = nil
            self._debuffs_normal[auraInstanceID] = nil
        end

        -- Per-aura check: only compare spellId if non-secret
        if spellId then
            -- resurrections: å›¾è…¾å¤ç"Ÿ/å¤ç"Ÿ
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
end

local RAID_DEBUFFS_GLOW_TYPES = {"Normal", "Pixel", "Shine", "Proc"}

local function UnitButton_UpdateDebuffs(self, isFullUpdate)
    local unit = self.states.displayedUnit

    ResetDebuffVars(self)
    I.ResetCustomIndicators(self, "debuff")

    if isFullUpdate then
        -- 12.0+: always save old cache so HandleDebuff can merge previously-known
        -- field values when current read returns secrets. InCombatLockdown() is
        -- unreliable during combat transitions — secrets can exist before it returns true.
        _oldDebuffsCache = self._debuffs_cache
        self._debuffs_cache = {}
        ForEachAura(self, "HARMFUL", HandleDebuff)
        _oldDebuffsCache = nil
    else
        ForEachAuraCache(self, "HARMFUL", HandleDebuff)
    end

    if not self._debuffs.resurrectionFound then
        self.states.hasRezDebuff = nil
    end

    local startIndex = 1

    -- update raid debuffs
    -- if self._debuffs.raidDebuffsFound or cleuUnits[unit] then
    if self._debuffs_raid[1] then
        self.indicators.raidDebuffs:Show()

        -- cleuAuras
        -- local offset = 0
        -- if cleuUnits[unit] then
        --     offset = 1
        --     startIndex = startIndex + 1
        -- end

        -- sort indices
        sort(self._debuffs_raid, function(a, b)
            local ca, cb = self._debuffs_cache[a], self._debuffs_cache[b]
            if not ca or not cb then return ca ~= nil end
            return ca["raidDebuffOrder"] < cb["raidDebuffOrder"]
        end)

        -- show
        local topAuraInstanceID
        -- for i = 1+offset, indicatorNums["raidDebuffs"] do
        for i = 1, indicatorNums["raidDebuffs"] do
            local auraInstanceID = self._debuffs_raid[i]
            if auraInstanceID then
                local auraInfo = self._debuffs_cache[auraInstanceID]
                if auraInfo then
                    local rdStart, rdDur
                    if F.IsValueNonSecret(auraInfo.expirationTime) and F.IsValueNonSecret(auraInfo.duration) then
                        rdStart = (auraInfo.expirationTime or 0) - auraInfo.duration
                        rdDur = auraInfo.duration
                    else
                        rdStart = 0
                        rdDur = 0
                    end
                    self.indicators.raidDebuffs[i]:SetCooldown(
                        rdStart,
                        rdDur,
                        (auraInfo.dispelName and (not issecretvalue or not issecretvalue(auraInfo.dispelName))) and auraInfo.dispelName or "",
                        auraInfo.icon,
                        auraInfo.applications,
                        auraInfo.refreshing,
                        I.IsDebuffUseElapsedTime(auraInfo.name, auraInfo.spellId)
                    )
                    self.indicators.raidDebuffs[i].auraInstanceID = auraInstanceID -- NOTE: for tooltip
                    startIndex = startIndex + 1
                    -- remove from debuffs
                    self._debuffs_big[auraInstanceID] = nil
                    self._debuffs_normal[auraInstanceID] = nil

                    if i == 1 then -- top
                        topAuraInstanceID = auraInstanceID
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
            self.indicators.raidDebuffs[i].auraInstanceID = nil
        end

        -- 12.0+: fix secret durations and dispel-type coloring for raid debuffs
        for i = 1, startIndex - 1 do
            local frame = self.indicators.raidDebuffs[i]
            if frame then
                local aid = frame.auraInstanceID
                local auraInfo = aid and self._debuffs_cache[aid]
                if auraInfo then
                    -- fix border + spark color for secret dispel types via bracket curves
                    if auraInfo._dispelNameIsSecret and _dispelCurvesReady and self.states.displayedUnit then
                        local hlColor = _getCurveColor(self.states.displayedUnit, aid, _dispelHighlightCurve)
                        if hlColor then
                            local ok, r, g, b, a = pcall(hlColor.GetRGBA, hlColor)
                            if ok then
                                -- transparent = non-dispellable (Physical); use red
                                if not issecretvalue(a) and a < 0.1 then
                                    r, g, b = 1, 0, 0
                                end
                                if frame.border then
                                    pcall(frame.border.SetColorTexture, frame.border, r, g, b)
                                end
                                if frame.cooldown then
                                    if frame.cooldown.spark then
                                        pcall(frame.cooldown.spark.SetColorTexture, frame.cooldown.spark, r, g, b)
                                    end
                                    if frame.cooldown.SetSwipeColor then
                                        pcall(frame.cooldown.SetSwipeColor, frame.cooldown, r, g, b)
                                    end
                                end
                            end
                        end
                    elseif auraInfo._hasSecrets and not auraInfo._dispelNameIsSecret then
                        -- non-dispellable secret debuff (Physical): red
                        if frame.border then
                            frame.border:SetColorTexture(1, 0, 0)
                        end
                        if frame.cooldown then
                            if frame.cooldown.spark then
                                frame.cooldown.spark:SetColorTexture(1, 0, 0)
                            end
                            if frame.cooldown.SetSwipeColor then
                                frame.cooldown:SetSwipeColor(1, 0, 0)
                            end
                        end
                    end
                    -- fix cooldown animation for secret durations
                    if auraInfo.duration == 0 and issecretvalue(auraInfo._rawDuration) then
                        _ActivateSecretCooldown(frame, auraInfo, self.states.displayedUnit)
                    elseif frame._secretClockActive then
                        _DeactivateSecretCooldown(frame)
                    end
                end
            end
        end

        -- update glow
        if not indicatorBooleans["raidDebuffs"] then
            -- to make sure top glow has highest priority
            local topAura = topAuraInstanceID and self._debuffs_cache[topAuraInstanceID]
            local topGlowType = topAura and topAura["raidDebuffGlowType"]
            local topGlowOptions = topAura and topAura["raidDebuffGlowOptions"]
            if topGlowType and topGlowType ~= "None" then
                self._debuffs_glow_current[topGlowType] = topGlowOptions
            end
            for t, o in next, self._debuffs_glow_current do
                self.indicators.raidDebuffs:ShowGlow(t, o, true)
            end
            for _, t in next, RAID_DEBUFFS_GLOW_TYPES do
                if not self._debuffs_glow_current[t] then
                    self.indicators.raidDebuffs:HideGlow(t)
                end
            end
            wipe(self._debuffs_glow_current)
        else
            local topAura = topAuraInstanceID and self._debuffs_cache[topAuraInstanceID]
            if topAura then
                self.indicators.raidDebuffs:ShowGlow(
                    I.GetDebuffGlow(
                        topAura["name"],
                        topAura["spellId"],
                        topAura["applications"]
                    )
                )
            end
        end
    else
        self.indicators.raidDebuffs:Hide()
    end

    -- update debuffs
    startIndex = 1
    if enabledIndicators["debuffs"] then
        -- bigDebuffs first
        for auraInstanceID in next, self._debuffs_big do
            local auraInfo = self._debuffs_cache[auraInstanceID]
            if auraInfo and startIndex <= indicatorNums["debuffs"] then
                -- start, duration, debuffType, texture, count
                local bStart, bDur
                if F.IsValueNonSecret(auraInfo.expirationTime) and F.IsValueNonSecret(auraInfo.duration) then
                    bStart = (auraInfo.expirationTime or 0) - auraInfo.duration
                    bDur = auraInfo.duration
                else
                    bStart = 0
                    bDur = 0
                end
                self.indicators.debuffs[startIndex]:SetCooldown(bStart, bDur, (auraInfo.dispelName and (not issecretvalue or not issecretvalue(auraInfo.dispelName))) and auraInfo.dispelName or "", auraInfo.icon, auraInfo.applications, auraInfo.refreshing, true)
                self.indicators.debuffs[startIndex].auraInstanceID = auraInstanceID -- NOTE: for tooltip
                self.indicators.debuffs[startIndex].spellId = auraInfo.spellId -- NOTE: for blacklist
                startIndex = startIndex + 1
            elseif startIndex > indicatorNums["debuffs"] then
                break
            end
        end
        -- then normal debuffs
        for auraInstanceID in next, self._debuffs_normal do
            local auraInfo = self._debuffs_cache[auraInstanceID]
            if auraInfo and startIndex <= indicatorNums["debuffs"] then
                -- start, duration, debuffType, texture, count
                local nStart, nDur
                if F.IsValueNonSecret(auraInfo.expirationTime) and F.IsValueNonSecret(auraInfo.duration) then
                    nStart = (auraInfo.expirationTime or 0) - auraInfo.duration
                    nDur = auraInfo.duration
                else
                    nStart = 0
                    nDur = 0
                end
                self.indicators.debuffs[startIndex]:SetCooldown(nStart, nDur, (auraInfo.dispelName and (not issecretvalue or not issecretvalue(auraInfo.dispelName))) and auraInfo.dispelName or "", auraInfo.icon, auraInfo.applications, auraInfo.refreshing)
                self.indicators.debuffs[startIndex].auraInstanceID = auraInstanceID -- NOTE: for tooltip
                self.indicators.debuffs[startIndex].spellId = auraInfo.spellId -- NOTE: for blacklist
                startIndex = startIndex + 1
            elseif startIndex > indicatorNums["debuffs"] then
                break
            end
        end
    end

    -- update debuffs
    self.indicators.debuffs:UpdateSize(startIndex - 1)
    for i = startIndex, 10 do
        self.indicators.debuffs[i].auraInstanceID = nil
        self.indicators.debuffs[i].spellId = nil
    end

    -- 12.0+: fix debuff icons for secret values (backdrop color + cooldown animation)
    for i = 1, startIndex - 1 do
        local frame = self.indicators.debuffs[i]
        if frame and frame.auraInstanceID then
            local auraInfo = self._debuffs_cache[frame.auraInstanceID]
            if auraInfo then
                -- fix backdrop color for secret debuffs (dispel type via bracket curves)
                if auraInfo._dispelNameIsSecret and _dispelCurvesReady and self.states.displayedUnit then
                    local hlColor = _getCurveColor(self.states.displayedUnit, frame.auraInstanceID, _dispelHighlightCurve)
                    if hlColor then
                        local ok, r, g, b, a = pcall(hlColor.GetRGBA, hlColor)
                        if ok then
                            -- transparent = non-dispellable (Physical); use red
                            if not issecretvalue(a) and a < 0.1 then
                                r, g, b = 1, 0, 0
                            end
                            pcall(frame.SetBackdropColor, frame, r, g, b)
                        end
                    end
                elseif auraInfo._hasSecrets and not auraInfo._dispelNameIsSecret then
                    -- non-dispellable secret debuff (Physical): red backdrop
                    pcall(frame.SetBackdropColor, frame, 1, 0, 0)
                end
                -- fix cooldown animation for secret durations
                if auraInfo.duration == 0 and issecretvalue(auraInfo._rawDuration) then
                    _ActivateSecretCooldown(frame, auraInfo, self.states.displayedUnit)
                elseif frame._secretClockActive then
                    _DeactivateSecretCooldown(frame)
                end
            end
        end
    end

    -- update dispels
    if F.UnitInGroup(unit) or UnitIsFriend("player", unit) then
        -- 12.0+: restore icon positions and alpha if they were stacked by secret dispel mode
        if self.indicators.dispels._secretIconsStacked then
            self.indicators.dispels:SetOrientation(self.indicators.dispels._orientation)
            self.indicators.dispels._secretIconsStacked = nil
            for i = 1, 5 do
                self.indicators.dispels[i]:SetAlpha(1)
                self.indicators.dispels[i]:SetVertexColor(1, 1, 1, 1)
            end
        end
        -- 12.0+: hide gradient overlay from secret dispel mode
        if self.indicators.dispels._secretGradientShown then
            self.indicators.dispels._secretGradientShown = nil
            if self.indicators.dispels._secretGradientOverlay then
                self.indicators.dispels._secretGradientOverlay:Hide()
            end
        end
        self.indicators.dispels:SetDispels(self._debuffs_dispel)

        -- 12.0+: if SetDispels found nothing but we detected a secret dispellable debuff,
        -- use color curves to render the dispel indicator directly via SetVertexColor.
        -- C-level SetVertexColor handles secret values from the curves.
        if self._secretDispelAuraID and _dispelCurvesReady
            and not self.indicators.dispels.highlight:IsShown()
            and enabledIndicators["dispels"] then

            local dispels = self.indicators.dispels
            local sUnit = self._secretDispelUnit
            local sAuraID = self._secretDispelAuraID

            -- get type color from highlight curve (secret but usable via C-level functions)
            local hlColor = _getCurveColor(sUnit, sAuraID, _dispelHighlightCurve)
            if hlColor then
                local colorOk, cr, cg, cb, ca = pcall(hlColor.GetRGBA, hlColor)
                if colorOk then
                    -- highlight: match the user's highlight type setting
                    local ht = dispels.highlightType
                    if ht and ht ~= "none" then
                        if ht == "entire" then
                            dispels.highlight:SetTexture(Cell.vars.whiteTexture)
                            pcall(dispels.highlight.SetVertexColor, dispels.highlight, cr, cg, cb, 0.5)
                            dispels.highlight:Show()
                        elseif ht == "current" or ht == "current+" then
                            dispels.highlight:SetTexture(Cell.vars.texture)
                            pcall(dispels.highlight.SetVertexColor, dispels.highlight, cr, cg, cb, 1)
                            dispels.highlight:Show()
                        elseif ht == "gradient" or ht == "gradient-half" then
                            -- SetGradient crashes with secret colors. Instead, use a
                            -- gradient texture (baked-in alpha gradient) + SetVertexColor
                            -- (C-level, handles secrets) for immediate correct coloring.
                            local overlay = _ensureGradientOverlay(dispels)
                            overlay:ClearAllPoints()
                            overlay:SetAllPoints(dispels.highlight)
                            pcall(overlay.SetVertexColor, overlay, cr, cg, cb, 1)
                            overlay:Show()
                            dispels._secretGradientShown = true
                        end
                    end

                    -- icons: stack all 5 type icons at position 1, using bracket curve
                    -- alpha to control visibility (matching type=opaque, others=transparent).
                    -- SetDispel sets texture/color per user's style (blizzard or rhombus).
                    -- SetAlpha with secret bracket curve alpha controls which icon renders.
                    if dispels.showIcons then
                        for i, t in ipairs(_dispelTypes) do
                            local icon = dispels[i]
                            if icon then
                                -- set texture/color via user's chosen style
                                if icon.SetDispel then
                                    icon:SetDispel(t.name)
                                end
                                -- bracket curve: alpha=1 for matching type, 0 for others
                                -- SetAlpha is C-level and handles secret values
                                local bColor = _getCurveColor(sUnit, sAuraID, _bracketCurves[t.name])
                                if bColor then
                                    local bOk, _, _, _, ba = pcall(bColor.GetRGBA, bColor)
                                    if bOk then
                                        pcall(icon.SetAlpha, icon, ba)
                                    end
                                end
                                -- stack at icon 1's position
                                if i > 1 then
                                    icon:ClearAllPoints()
                                    icon:SetAllPoints(dispels[1])
                                end
                                icon:Show()
                            end
                        end
                        dispels:UpdateSize(1)
                        dispels._secretIconsStacked = true
                    end
                end
            end
        end
    end

    -- update crowdControls
    self.indicators.crowdControls:UpdateSize(self._debuffs.crowdControlsFound)

    -- user created indicators
    I.ShowCustomIndicators(self, "debuff")

    wipe(self._debuffs_normal)
    wipe(self._debuffs_big)
    wipe(self._debuffs_dispel)
    wipe(self._debuffs_raid)
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

    -- 12.0+: merge with previously-known good data when fields are secret
    if _oldBuffsCache then
        _mergeSecretAura(auraInfo, _oldBuffsCache)
    end

    local name = auraInfo.name
    -- auraInfo.icon may be a secret fileID on Midnight 12.0.0+
    -- SetTexture() accepts secret numbers, so this works as-is
    local icon = auraInfo.icon
    local count = auraInfo.applications
    -- local debuffType = auraInfo.isHarmful and auraInfo.dispelName
    local expirationTime = auraInfo.expirationTime or 0
    local duration = auraInfo.duration
    -- Midnight 12.0.0+: expirationTime and duration may be secret even when spellId is not.
    -- Guard per-field: non-secret temporal fields get proper duration/cooldown display.
    local start
    if F.IsValueNonSecret(expirationTime) and F.IsValueNonSecret(duration) then
        start = expirationTime - duration
    else
        start = 0
        duration = 0
    end
    local source = auraInfo.sourceUnit
    local spellId = auraInfo.spellId

    -- 12.0+: try to resolve spellId/name from raw secret via C_Spell (C-level API)
    if not spellId and auraInfo._rawSpellId and C_Spell and C_Spell.GetSpellName then
        local ok, resolvedName = pcall(C_Spell.GetSpellName, auraInfo._rawSpellId)
        if ok and resolvedName and not issecretvalue(resolvedName) then
            auraInfo.name = resolvedName
            name = resolvedName
            local ok2, info = pcall(C_Spell.GetSpellInfo, auraInfo._rawSpellId)
            if ok2 and info and info.spellID and not issecretvalue(info.spellID) then
                auraInfo.spellId = info.spellID
                spellId = info.spellID
            end
        end
    end
    -- local attribute = auraInfo.points[1] -- UnitAura:arg16

    auraInfo.refreshing = false

    if duration then
        UpdateAuraRefreshState(auraInfo)
        self._buffs_cache[auraInstanceID] = auraInfo

        -- defensiveCooldowns / externalCooldowns / allCooldowns
        -- Use spell name/id when readable; fall back to IsAuraFilteredOutByInstanceID
        -- with BIG_DEFENSIVE / EXTERNAL_DEFENSIVE filters when fields are secret (12.0+).
        local isDefensive = I.IsDefensiveCooldown(name, spellId)
        local isExternal = I.IsExternalCooldown(name, spellId, source, unit)

        if not isDefensive and not isExternal and auraInfo._hasSecrets and _IsAuraFilteredOut then
            -- check external first: spells like Pain Suppression / Ironbark match
            -- both BIG_DEFENSIVE and EXTERNAL_DEFENSIVE; Cell treats them as external
            isExternal = not _IsAuraFilteredOut(unit, auraInstanceID, "HELPFUL|EXTERNAL_DEFENSIVE")
            if not isExternal then
                isDefensive = not _IsAuraFilteredOut(unit, auraInstanceID, "HELPFUL|BIG_DEFENSIVE")
            end
        end

        if enabledIndicators["defensiveCooldowns"] and isDefensive and self._buffs.defensiveFound < indicatorNums["defensiveCooldowns"] then
            self._buffs.defensiveFound = self._buffs.defensiveFound + 1
            local frame = self.indicators.defensiveCooldowns[self._buffs.defensiveFound]
            frame:SetCooldown(start, duration, nil, icon, count, auraInfo.refreshing)
            frame.auraInstanceID = auraInstanceID
        end

        if enabledIndicators["externalCooldowns"] and isExternal and self._buffs.externalFound < indicatorNums["externalCooldowns"] then
            self._buffs.externalFound = self._buffs.externalFound + 1
            local frame = self.indicators.externalCooldowns[self._buffs.externalFound]
            frame:SetCooldown(start, duration, nil, icon, count, auraInfo.refreshing)
            frame.auraInstanceID = auraInstanceID
        end

        if enabledIndicators["allCooldowns"] and (isDefensive or isExternal) and self._buffs.allFound < indicatorNums["allCooldowns"] then
            self._buffs.allFound = self._buffs.allFound + 1
            local frame = self.indicators.allCooldowns[self._buffs.allFound]
            frame:SetCooldown(start, duration, nil, icon, count, auraInfo.refreshing)
            frame.auraInstanceID = auraInstanceID
        end

        -- tankActiveMitigation
        if enabledIndicators["tankActiveMitigation"] and I.IsTankActiveMitigation(spellId) then
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
        I.UpdateCustomIndicators(self, auraInfo)

        -- Per-aura check: spellId may be restored by merge or C_Spell resolution
        if spellId then
            -- check BG flags for statusIcon
            if spellId == 156621 then
                self.states.BGFlag = "alliance"
            elseif spellId == 156618 then
                self.states.BGFlag = "horde"
            end
        end
    end
end

local function UnitButton_UpdateBuffs(self, isFullUpdate)
    local unit = self.states.displayedUnit

    ResetBuffVars(self)
    I.ResetCustomIndicators(self, "buff")

    if isFullUpdate then
        -- 12.0+: always save old cache for secret field merging (see _mergeSecretAura)
        _oldBuffsCache = self._buffs_cache
        self._buffs_cache = {}
        ForEachAura(self, "HELPFUL", HandleBuff)
        _oldBuffsCache = nil
    else
        ForEachAuraCache(self, "HELPFUL", HandleBuff)
    end

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

    -- 12.0+: activate C-level cooldown animation for secret-duration buff indicators
    _FixSecretCooldowns(self.indicators.defensiveCooldowns, self._buffs.defensiveFound, self._buffs_cache, self.states.displayedUnit)
    _FixSecretCooldowns(self.indicators.externalCooldowns, self._buffs.externalFound, self._buffs_cache, self.states.displayedUnit)
    _FixSecretCooldowns(self.indicators.allCooldowns, self._buffs.allFound, self._buffs_cache, self.states.displayedUnit)

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
    self._debuffs_cache = {}
    self._missing_auras = {}

    -- debuffs
    self._debuffs_normal = {} -- [auraInstanceID] = refreshing
    self._debuffs_big = {} -- [auraInstanceID] = refreshing
    self._debuffs_dispel = {} -- [debuffType] = true/false
    self._debuffs_raid = {} -- {id1, id2, ...}
    self._debuffs_glow_current = {}
end

local function ResetAuraTables(self)
    wipe(self._buffs_cache)
    wipe(self._debuffs_cache)
    wipe(self._missing_auras)

    -- debuffs
    wipe(self._debuffs_normal)
    wipe(self._debuffs_big)
    wipe(self._debuffs_dispel)
    wipe(self._debuffs_raid)

    -- raid debuffs glow
    wipe(self._debuffs_glow_current)
    if self.indicators.raidDebuffs then
        self.indicators.raidDebuffs:HideGlow()
    end

    self._mirror_image = nil
    self._mass_barrier = nil
    self._mass_barrier_icon = nil
end

-------------------------------------------------
-- check auras using CLEU
-- NOTE: COMBAT_LOG_EVENT_UNFILTERED is unavailable on Midnight (12.0.0+).
-- CheckCLEURequired guards registration; CLEU handler is wrapped with Cell.isMidnight check.
-------------------------------------------------
local cleu = CreateFrame("Frame")

function CheckCLEURequired()
    -- CLEU (CombatLogGetCurrentEventInfo) removed in 12.0+
    if not CombatLogGetCurrentEventInfo then return end

    if (Cell.vars.currentLayoutTable.indicators[Cell.defaults.indicatorIndices.externalCooldowns].enabled
        or Cell.vars.currentLayoutTable.indicators[Cell.defaults.indicatorIndices.defensiveCooldowns].enabled
        or Cell.vars.currentLayoutTable.indicators[Cell.defaults.indicatorIndices.allCooldowns].enabled)
        and (I.IsDefensiveCooldown(55342) or I.IsExternalCooldown(414660)) then
        cleu:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    else
        cleu:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end
end

local function UpdateMirrorImage(b, event)
    if event == "SPELL_AURA_APPLIED" then
        b._mirror_image = GetTime()
    elseif event == "SPELL_AURA_REMOVED" then
        b._mirror_image = nil
    end
    if b._indicatorsReady then
        UnitButton_UpdateBuffs(b, false) -- should be no full update needed, indicator update is done
    end
end

local SelfBarriers = {
    [11426] = true, -- å¯'å†°æŠ¤ä½" (self)
    [235313] = true, -- çƒˆç„°æŠ¤ä½" (self)
    [235450] = true, -- æ£±å…‰æŠ¤ä½" (self)
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
    if b._indicatorsReady then
        UnitButton_UpdateBuffs(b, false) -- should be no full update needed, indicator update is done
    end
end

-- CLEU-based indicator tracking (mirror image, mass barrier).
-- Unavailable on Midnight (12.0.0+); guarded by Cell.isMidnight.
if not Cell.isMidnight then
    cleu:SetScript("OnEvent", function()
        local _, subEvent, _, sourceGUID, _, sourceFlags, _, _, _, destFlags, _, spellId = CombatLogGetCurrentEventInfo()

        -- mirror image
        if spellId == 55342 and F.IsFriend(sourceFlags) then
            F.HandleUnitButton("guid", sourceGUID, UpdateMirrorImage, subEvent)
        end

        -- mass barrier (self), SPELL_CAST_SUCCESS
        if spellId == 414660 and F.IsFriend(sourceFlags) then
            F.HandleUnitButton("guid", sourceGUID, UpdateMassBarrier, "SPELL_CAST_SUCCESS")
        end
        if (subEvent == "SPELL_AURA_REMOVED" or subEvent == "SPELL_AURA_REFRESH") and SelfBarriers[spellId] and F.IsFriend(sourceFlags) then
            F.HandleUnitButton("guid", sourceGUID, UpdateMassBarrier, "SPELL_AURA_REMOVED")
        end
    end)
end

-------------------------------------------------
-- functions
-------------------------------------------------
UnitButton_UpdateAuras = function(self, updateInfo)
    if not self._indicatorsReady then return end

    local unit = self.states.displayedUnit
    if not unit then return end

    local isFullUpdate = not updateInfo or updateInfo.isFullUpdate

    if isFullUpdate then
        -- full update
        UnitButton_UpdateBuffs(self, true)
        UnitButton_UpdateDebuffs(self, true)
    else
        -- Midnight 12.0.0+: some aura fields may still be secret. Per-aura checks in
        -- HandleBuff/HandleDebuff handle this. We no longer force full update for ALL
        -- Midnight aura events â€" only fall back to full update if we encounter secret
        -- isHelpful/isHarmful fields in addedAuras that prevent classification.
        local buffsChanged, debuffsChanged
        wipe(self._missing_auras)

        if updateInfo.addedAuras then
            for _, rawAura in next, updateInfo.addedAuras do
                local aura = SanitizeAura(rawAura)
                if aura then
                    -- 12.0+: record when the aura was first seen (for C-level cooldown
                    -- when duration is secret and we can't compute start time)
                    aura._addedTime = GetTime()
                    local isHelpful, isHarmful = aura.isHelpful, aura.isHarmful
                    -- 12.0+: isHelpful/isHarmful may be secret (defaulted to false);
                    -- use IsAuraFilteredOutByInstanceID as fallback
                    if not isHelpful and not isHarmful and _IsAuraFilteredOut then
                        isHarmful = not _IsAuraFilteredOut(unit, aura.auraInstanceID, "HARMFUL")
                        isHelpful = not isHarmful and not _IsAuraFilteredOut(unit, aura.auraInstanceID, "HELPFUL")
                    end
                    if isHelpful then
                        buffsChanged = true
                        self._buffs_cache[aura.auraInstanceID] = aura
                    end
                    if isHarmful then
                        debuffsChanged = true
                        self._debuffs_cache[aura.auraInstanceID] = aura
                    end
                end
            end
        end

        if updateInfo.updatedAuraInstanceIDs then
            local aura
            -- auraInstanceID is NOT secret and is safe to use as table key
            for _, auraInstanceID in next, updateInfo.updatedAuraInstanceIDs do
                if self._buffs_cache[auraInstanceID] then
                    buffsChanged = true
                    aura = GetAuraDataByAuraInstanceID(unit, auraInstanceID)
                    if aura then
                        if F.IsAuraNonSecret(aura) then
                            -- Sanitize cached values: they may be secret even if new aura's spellId is not
                            local cachedExp = self._buffs_cache[auraInstanceID].expirationTime
                            local cachedApp = self._buffs_cache[auraInstanceID].applications
                            aura.oldExpirationTime = (cachedExp and F.IsValueNonSecret(cachedExp)) and cachedExp or 0
                            aura.oldApplications = (cachedApp and F.IsValueNonSecret(cachedApp)) and cachedApp or nil
                        end
                        self._buffs_cache[auraInstanceID] = aura
                    end
                elseif self._debuffs_cache[auraInstanceID] then
                    debuffsChanged = true
                    aura = GetAuraDataByAuraInstanceID(unit, auraInstanceID)
                    if aura then
                        if F.IsAuraNonSecret(aura) then
                            -- Sanitize cached values: they may be secret even if new aura's spellId is not
                            local cachedExp = self._debuffs_cache[auraInstanceID].expirationTime
                            local cachedApp = self._debuffs_cache[auraInstanceID].applications
                            aura.oldExpirationTime = (cachedExp and F.IsValueNonSecret(cachedExp)) and cachedExp or 0
                            aura.oldApplications = (cachedApp and F.IsValueNonSecret(cachedApp)) and cachedApp or nil
                        end
                        self._debuffs_cache[auraInstanceID] = aura
                    end
                else
                    aura = GetAuraDataByAuraInstanceID(unit, auraInstanceID)
                    if aura then
                        self._missing_auras[auraInstanceID] = aura
                    end
                end
            end
        end

        if updateInfo.removedAuraInstanceIDs then
            for _, auraInstanceID in next, updateInfo.removedAuraInstanceIDs do
                if self._buffs_cache[auraInstanceID] then
                    self._buffs_cache[auraInstanceID] = nil
                    buffsChanged = true
                elseif self._debuffs_cache[auraInstanceID] then
                    self._debuffs_cache[auraInstanceID] = nil
                    debuffsChanged = true
                else
                    self._missing_auras[auraInstanceID] = nil
                end
            end
        end

        if next(self._missing_auras) then
            for _, aura in next, self._missing_auras do
                if aura then
                    local isHelpful, isHarmful = aura.isHelpful, aura.isHarmful
                    if not isHelpful and not isHarmful and _IsAuraFilteredOut then
                        isHarmful = not _IsAuraFilteredOut(unit, aura.auraInstanceID, "HARMFUL")
                        isHelpful = not isHarmful and not _IsAuraFilteredOut(unit, aura.auraInstanceID, "HELPFUL")
                    end
                    if isHelpful then
                        buffsChanged = true
                        self._buffs_cache[aura.auraInstanceID] = aura
                    elseif isHarmful then
                        debuffsChanged = true
                        self._debuffs_cache[aura.auraInstanceID] = aura
                    end
                end
                -- Secret missing auras are silently dropped â€" they'll be
                -- picked up on the next full update if needed
            end
        end

        if buffsChanged then UnitButton_UpdateBuffs(self) end
        if debuffsChanged then UnitButton_UpdateDebuffs(self) end
    end

    I.UpdateStatusIcon(self)
end

-- Updates the health prediction calculator for a button (Midnight 12.0.0+)
local function UnitButton_UpdateCalculator(self)
    local unit = self.states.displayedUnit
    if not unit then return end
    local calc = self.widgets.healthCalculator
    if not calc then return end
    -- pcall: UnitGetDetailedHealPrediction may fail for AI followers or unavailable units
    pcall(UnitGetDetailedHealPrediction, unit, "player", calc)
end

local function UnitButton_UpdateHealthStates(self, diff)
    local unit = self.states.displayedUnit

    if Cell.isMidnight and self.widgets.healthCalculator then
        -- MIDNIGHT PATH: use calculator â€" no arithmetic on secrets
        UnitButton_UpdateCalculator(self)
        -- Store healthPercent for color logic.
        -- GetCurrentHealthPercent() returns a secret value inside PvP instances —
        -- Lua comparisons on secrets throw errors. Use it only when non-secret.
        local hpPct = self.widgets.healthCalculator:GetCurrentHealthPercent()
        if F.IsValueNonSecret(hpPct) then
            self.states.healthPercent = hpPct
        else
            -- Secret: default to 0 so F.GetHealthBarColor won't trigger fullColor (which checks == 1).
            -- class_color / class_color_dark modes don't use percent, so they still work.
            self.states.healthPercent = 0
        end
        -- Death detection uses non-secret boolean
        self.states.wasDead = self.states.isDead
        self.states.isDead = UnitIsDeadOrGhost(unit) or false
        -- Fallback: use UnitIsDeadOrGhost which is always non-secret
        self.states.wasDeadOrGhost = self.states.isDeadOrGhost
        self.states.isDeadOrGhost = UnitIsDeadOrGhost(unit) or false

        -- Health text: use calculator secret values
        if enabledIndicators["healthText"] then
            local calc = self.widgets.healthCalculator
            local health = calc:GetCurrentHealth()
            local maxHealth = calc:GetMaximumHealth()
            local totalAbsorbs = calc:GetTotalDamageAbsorbs()
            local healAbsorbs = calc:GetTotalHealAbsorbs()
            -- SetValue accepts secret values; pass unit for UnitHealthPercent
            self.indicators.healthText:SetValue(health, maxHealth, totalAbsorbs, healAbsorbs, unit)
            self.indicators.healthText:Show()
        else
            self.indicators.healthText:Hide()
        end

        -- Fire death-state change callbacks
        if self.states.wasDead ~= self.states.isDead then
            UnitButton_UpdateStatusText(self)
            I.UpdateStatusIcon_Resurrection(self)
            if not self.states.isDead then
                self.states.hasSoulstone = nil
                I.UpdateStatusIcon(self)
            end
        end
        if self.states.wasDeadOrGhost ~= self.states.isDeadOrGhost then
            I.UpdateStatusIcon_Resurrection(self)
            UnitButton_UpdateHealthColor(self)
        end
    else
        -- CLASSIC/PRE-MIDNIGHT PATH: original logic preserved
        local health = UnitHealth(unit) + (diff or 0)
        local healthMax = UnitHealthMax(unit)
        health = min(health, healthMax) --! diff

        self.states.health = health
        self.states.healthMax = healthMax
        self.states.totalAbsorbs = UnitGetTotalAbsorbs(unit)
        self.states.healAbsorbs = UnitGetTotalHealAbsorbs(unit)

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

        if enabledIndicators["healthText"] then -- and not self.states.isDeadOrGhost then
            self.indicators.healthText:SetValue(health, healthMax, self.states.totalAbsorbs, self.states.healAbsorbs, unit)
            self.indicators.healthText:Show()
        else
            self.indicators.healthText:Hide()
        end
    end
end

local function UnitButton_UpdatePowerStates(self)
    local unit = self.states.displayedUnit
    if not unit then return end

    -- 12.0+: UnitPower may return secret values; store raw for SetValue
    self.states.power = UnitPower(unit)
    self.states.powerMax = UnitPowerMax(unit)
    -- Midnight 12.0.0+: UnitPowerMax may be secret — only clamp when non-secret
    if F.IsValueNonSecret(self.states.powerMax) then
        if self.states.powerMax <= 0 then self.states.powerMax = 1 end
    end
end

-------------------------------------------------
-- power filter funcs
-------------------------------------------------
local function GetRole(b)
    if b.states.role and b.states.role ~= "NONE" then
        return b.states.role
    end

    -- For the player's own unit, get role from current spec directly
    -- (UnitGroupRolesAssigned returns "NONE" when solo or in non-LFG groups)
    if GetSpecialization and GetSpecializationRole
        and b.states.unit and UnitIsUnit(b.states.unit, "player") then
        local spec = GetSpecialization()
        if spec then
            local specRole = GetSpecializationRole(spec)
            if specRole and specRole ~= "NONE" then
                return specRole
            end
        end
    end

    -- Fresh UnitGroupRolesAssigned check (role may have been assigned after init)
    if b.states.unit then
        local freshRole = UnitGroupRolesAssigned(b.states.unit)
        if freshRole and freshRole ~= "NONE" then
            b.states.role = freshRole
            return freshRole
        end
    end

    local info = LGI:GetCachedInfo(b.states.guid)
    if not info then return end
    return info.role
end

-- Evaluate a role filter table when the specific role is unknown.
-- Returns false if ALL roles in the table are disabled, true otherwise.
local function EvaluateFilterWithoutRole(filterTable)
    if type(filterTable) == "boolean" then
        return filterTable
    end
    -- If any role is enabled, show (safe default when role unknown)
    for _, enabled in pairs(filterTable) do
        if enabled then
            return true
        end
    end
    -- All roles disabled for this class → hide
    return false
end

-- Determine class and role for a unit button (used by power filter functions)
local function GetClassAndRole(b)
    local class, role
    local guid = b.states.guid
    -- 12.0+: guid may be secret for NPC units — can't use string.find on secrets
    if guid and issecretvalue and issecretvalue(guid) then
        -- Fallback: use UnitInPartyIsAI to detect AI followers without needing guid
        if b.states.unit and UnitInPartyIsAI(b.states.unit) then
            class = b.states.class
            role = GetRole(b)
        end
        return class, role
    end
    if b.states.inVehicle then
        class = "VEHICLE"
    elseif F.IsPlayer(guid) then
        class = b.states.class
        role = GetRole(b)
    elseif F.IsPet(guid) then
        class = "PET"
    elseif F.IsNPC(guid) then
        if UnitInPartyIsAI(b.states.unit) then
            class = b.states.class
            role = GetRole(b)
        else
            class = "NPC"
        end
    elseif F.IsVehicle(guid) then
        class = "VEHICLE"
    end
    return class, role
end

ShouldShowPowerText = function(b)
    if not enabledIndicators["powerText"] then return end
    if not (b:IsVisible() or b.isPreview) then return end

    if not b.states.guid then
        return true
    end

    local class, role = GetClassAndRole(b)

    if class then
        local filter = indicatorCustoms["powerText"] and indicatorCustoms["powerText"][class]
        if filter == nil then
            return true
        elseif type(filter) == "boolean" then
            return filter
        else
            if role then
                return filter[role]
            else
                return EvaluateFilterWithoutRole(filter)
            end
        end
    end

    return true
end

ShouldShowPowerBar = function(b)
    if not (b:IsVisible() or b.isPreview) then return end
    if not b.powerSize or b.powerSize == 0 then return end

    if not b.states.guid then
        return true
    end

    local class, role = GetClassAndRole(b)

    if class and Cell.vars.currentLayoutTable then
        local filter = Cell.vars.currentLayoutTable["powerFilters"] and Cell.vars.currentLayoutTable["powerFilters"][class]
        if filter == nil then
            return true
        elseif type(filter) == "boolean" then
            return filter
        else
            if role then
                return filter[role]
            else
                return EvaluateFilterWithoutRole(filter)
            end
        end
    end

    return true
end

CheckPowerEventRegistration = function(b)
    if b:IsVisible() and not b.isPreview and (b._shouldShowPowerText or b._shouldShowPowerBar) then
        b:RegisterEvent("UNIT_POWER_FREQUENT")
        b:RegisterEvent("UNIT_MAXPOWER")
        b:RegisterEvent("UNIT_DISPLAYPOWER")
        return true
    else
        b:UnregisterEvent("UNIT_POWER_FREQUENT")
        b:UnregisterEvent("UNIT_MAXPOWER")
        b:UnregisterEvent("UNIT_DISPLAYPOWER")
        return false
    end
end

local function ShowPowerBar(b)
    b.widgets.powerBar:Show()
    b.widgets.powerBarLoss:Show()
    b.widgets.gapTexture:SetShown(CELL_BORDER_SIZE ~= 0)

    P.ClearPoints(b.widgets.healthBar)
    P.ClearPoints(b.widgets.powerBar)
    if b.orientation == "horizontal" or b.orientation == "vertical_health" then
        P.Point(b.widgets.healthBar, "TOPLEFT", b, "TOPLEFT", CELL_BORDER_SIZE, -CELL_BORDER_SIZE)
        P.Point(b.widgets.healthBar, "BOTTOMRIGHT", b, "BOTTOMRIGHT", -CELL_BORDER_SIZE, b.powerSize + CELL_BORDER_SIZE * 2)
        P.Point(b.widgets.powerBar, "TOPLEFT", b.widgets.healthBar, "BOTTOMLEFT", 0, -CELL_BORDER_SIZE)
        P.Point(b.widgets.powerBar, "BOTTOMRIGHT", b, "BOTTOMRIGHT", -CELL_BORDER_SIZE, CELL_BORDER_SIZE)
    else
        P.Point(b.widgets.healthBar, "TOPLEFT", b, "TOPLEFT", CELL_BORDER_SIZE, -CELL_BORDER_SIZE)
        P.Point(b.widgets.healthBar, "BOTTOMRIGHT", b, "BOTTOMRIGHT", -(b.powerSize + CELL_BORDER_SIZE * 2), CELL_BORDER_SIZE)
        P.Point(b.widgets.powerBar, "TOPLEFT", b.widgets.healthBar, "TOPRIGHT", CELL_BORDER_SIZE, 0)
        P.Point(b.widgets.powerBar, "BOTTOMRIGHT", b, "BOTTOMRIGHT", -CELL_BORDER_SIZE, CELL_BORDER_SIZE)
    end

    if b:IsVisible() then
        -- update now
        CheckPowerEventRegistration(b)
        UnitButton_UpdatePowerStates(b)
        UnitButton_UpdatePowerType(b)
        UnitButton_UpdatePowerMax(b)
        UnitButton_UpdatePower(b)
    end
end

local function HidePowerBar(b)
    CheckPowerEventRegistration(b)
    b.widgets.powerBar:Hide()
    b.widgets.powerBarLoss:Hide()
    b.widgets.gapTexture:Hide()

    P.ClearPoints(b.widgets.healthBar)
    P.Point(b.widgets.healthBar, "TOPLEFT", b, "TOPLEFT", CELL_BORDER_SIZE, -CELL_BORDER_SIZE)
    P.Point(b.widgets.healthBar, "BOTTOMRIGHT", b, "BOTTOMRIGHT", -CELL_BORDER_SIZE, CELL_BORDER_SIZE)
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

    local playerUnit = F.GetPlayerUnit(petUnit)

    local isRoot
    for i = 1, UnitVehicleSeatCount(playerUnit) do
        local controlType, occupantName, serverName, ejectable, canSwitchSeats = UnitVehicleSeatInfo(playerUnit, i)
        local pName = UnitName(playerUnit)
        -- On Midnight 12.0.0+, UnitName() may return a secret string in instances
        -- Comparing a secret string with == will error, so guard before comparing
        if not (Cell.isMidnight and F.IsSecretValue and F.IsSecretValue(pName)) and pName == occupantName then
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
        -- Midnight 12.0.0+: guid may be secret for NPC/boss units
        if self.states.guid and not (issecretvalue and issecretvalue(self.states.guid)) and strfind(self.states.guid, "^Vehicle") and not UnitInPartyIsAI(unit) then
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

    if enabledIndicators["readyCheckIcon"] and status then
        -- self.widgets.readyCheckHighlight:SetVertexColor(unpack(READYCHECK_STATUS[status].c))
        -- self.widgets.readyCheckHighlight:Show()
        self.indicators.readyCheckIcon:SetStatus(status)
    else
        -- self.widgets.readyCheckHighlight:Hide()
        self.indicators.readyCheckIcon:Hide()
    end
end

local function UnitButton_FinishReadyCheck(self)
    if not enabledIndicators["readyCheckIcon"] then return end

    if self.states.readyCheckStatus == "waiting" then
        -- self.widgets.readyCheckHighlight:SetVertexColor(unpack(READYCHECK_STATUS.notready.c))
        self.indicators.readyCheckIcon:SetStatus("notready")
    end
    C_Timer.After(6, function()
        -- self.widgets.readyCheckHighlight:Hide()
        self.indicators.readyCheckIcon:Hide()
    end)
end

UnitButton_UpdatePowerText = function(self)
    if not self._shouldShowPowerText then return end

    local power = self.states.power
    local powerMax = self.states.powerMax
    -- 12.0+: power may be secret; check nil via rawequal (safe on secrets)
    -- before boolean test which would crash on secret values
    if rawequal(power, nil) or self.states.isDeadOrGhost then
        self.indicators.powerText:Hide()
        return
    end

    if not issecretvalue(power) and (rawequal(powerMax, nil) or not issecretvalue(powerMax)) then
        self.indicators.powerText:SetValue(power, powerMax)
    else
        -- Pass secret values to C-level SetFormattedText directly.
        -- hideIfEmptyOrFull: use UnitPowerPercent (C-level, returns non-secret %)
        -- to detect full/empty since direct comparison on secrets crashes Lua.
        local unit = self.states.displayedUnit
        if self.indicators.powerText.hideIfEmptyOrFull and unit and UnitPowerPercent then
            local ok, pctVal = pcall(UnitPowerPercent, unit, nil, true,
                CurveConstants and CurveConstants.ScaleTo100 or nil)
            if ok and not issecretvalue(pctVal) and (pctVal == 0 or pctVal == 100) then
                self.indicators.powerText:Hide()
                return
            end
        end
        pcall(function()
            local fmt = self.indicators.powerText._format
            if fmt == "percentage" then
                -- UnitPowerPercent returns 0-1 by default; use ScaleTo100 curve for 0-100
                local pct
                if unit and UnitPowerPercent then
                    if CurveConstants and CurveConstants.ScaleTo100 then
                        local ok, val = pcall(UnitPowerPercent, unit, nil, true, CurveConstants.ScaleTo100)
                        pct = ok and val or nil
                    else
                        local ok, val = pcall(UnitPowerPercent, unit)
                        pct = ok and val or nil
                    end
                end
                if pct then
                    self.indicators.powerText.text:SetFormattedText("%d%%", pct)
                else
                    self.indicators.powerText.text:SetFormattedText("%d", power)
                end
            elseif fmt == "number-short" and AbbreviateNumbers then
                self.indicators.powerText.text:SetFormattedText("%s", AbbreviateNumbers(power))
            else
                -- "number" or "number-short" without AbbreviateNumbers: raw number
                self.indicators.powerText.text:SetFormattedText("%d", power)
            end
        end)
        -- GetStringWidth returns secret when text is tainted; skip SetWidth
        self.indicators.powerText:Show()
    end
end

UnitButton_UpdatePowerTextColor = function(self)
    if not self._shouldShowPowerText then return end

    local unit = self.states.displayedUnit
    if not unit then return end

    if indicatorColors["powerText"][1] == "power_color" then
        self.indicators.powerText:SetColor(F.GetPowerColor(unit))
    elseif indicatorColors["powerText"][1] == "class_color" then
        self.indicators.powerText:SetColor(F.GetUnitClassColor(unit))
    else
        self.indicators.powerText:SetColor(unpack(indicatorColors["powerText"][2]))
    end
end

UnitButton_UpdatePowerMax = function(self)
    if not self._shouldShowPowerBar then return end
    if self.states.powerMax == nil then return end

    -- powerMax may be secret on Midnight 12.0.0+ for some units.
    -- SetMinMaxSmoothedValue is a Lua mixin that does arithmetic (Clamp) â€" fails on secrets.
    -- SetMinMaxValues is native C API that accepts secrets. Use it as fallback on Midnight.
    if barAnimationType == "Smooth" and F.IsValueNonSecret(self.states.powerMax) then
        self.widgets.powerBar:SetMinMaxSmoothedValue(0, self.states.powerMax)
    else
        self.widgets.powerBar:SetMinMaxValues(0, self.states.powerMax)
    end
end

UnitButton_UpdatePower = function(self)
    if not self._shouldShowPowerBar then return end
    if self.states.power == nil then return end

    -- self.states.power may be a secret value on Midnight 12.0.0+
    -- SetBarValue maps to SetSmoothedValue in Smooth mode, which does Lua Clamp and fails on secrets.
    -- Use native SetValue on Midnight when power is secret.
    if Cell.isMidnight and not F.IsValueNonSecret(self.states.power) then
        self.widgets.powerBar:SetValue(self.states.power)
    else
        self.widgets.powerBar:SetBarValue(self.states.power)
    end
end

UnitButton_UpdatePowerType = function(self)
    if not self._shouldShowPowerBar then return end

    local unit = self.states.displayedUnit
    if not unit then return end

    local r, g, b, lossR, lossG, lossB
    local a = Cell.loaded and CellDB["appearance"]["lossAlpha"] or 1

    if not UnitIsConnected(unit) then
        r, g, b = 0.4, 0.4, 0.4
        lossR, lossG, lossB = 0.4, 0.4, 0.4
    else
        r, g, b, lossR, lossG, lossB, self.states.powerType = F.GetPowerBarColor(unit, self.states.class)
    end

    self.widgets.powerBar:SetStatusBarColor(r, g, b)
    self.widgets.powerBarLoss:SetVertexColor(lossR, lossG, lossB)
end

local function UnitButton_UpdateHealthMax(self)
    local unit = self.states.displayedUnit
    if not unit then return end

    UnitButton_UpdateHealthStates(self)

    if Cell.isMidnight and self.widgets.healthCalculator then
        -- MIDNIGHT PATH: pass secret maxHealth directly
        -- SetMinMaxSmoothedValue is a Lua mixin that does arithmetic (Clamp) â€" fails on secrets.
        -- Always use native SetMinMaxValues on Midnight since maxHealth may be secret.
        local maxHealth = self.widgets.healthCalculator:GetMaximumHealth()
        self.widgets.healthBar:SetMinMaxValues(0, maxHealth)
        -- Also update overlay bar ranges
        if self.widgets.incomingHeal then
            self.widgets.incomingHeal:SetMinMaxValues(0, maxHealth)
        end
        if self.widgets.shieldBar then
            self.widgets.shieldBar:SetMinMaxValues(0, maxHealth)
        end
        if self.widgets.shieldBarR then
            self.widgets.shieldBarR:SetMinMaxValues(0, maxHealth)
        end
        if self.widgets.absorbsBar then
            self.widgets.absorbsBar:SetMinMaxValues(0, maxHealth)
        end
    else
        -- CLASSIC/PRE-MIDNIGHT PATH: original logic
        if barAnimationType == "Smooth" then
            self.widgets.healthBar:SetMinMaxSmoothedValue(0, self.states.healthMax)
        else
            self.widgets.healthBar:SetMinMaxValues(0, self.states.healthMax)
        end
    end

    if Cell.vars.useThresholdColor or Cell.vars.useFullColor then
        UnitButton_UpdateHealthColor(self)
    end
end

local function UnitButton_UpdateHealth(self, diff, skipStateUpdates)
    local unit = self.states.displayedUnit
    if not unit then return end

    if not skipStateUpdates then
        UnitButton_UpdateHealthStates(self, diff)
    end

    if Cell.isMidnight and self.widgets.healthCalculator then
        -- MIDNIGHT PATH: pass secret values directly to status bar
        local calc = self.widgets.healthCalculator
        local health = calc:GetCurrentHealth()
        -- Always use native SetValue on Midnight — SetSmoothedValue (SetBarValue in Smooth mode)
        -- is a Lua mixin that does Clamp() arithmetic, which fails on secret values.
        self.widgets.healthBar:SetValue(health)
        if barAnimationType == "Flash" then
            -- Flash: we can't compute exact diff without arithmetic on secrets, so skip precise flash
            B.HideFlash(self)
        end

        if Cell.vars.useThresholdColor or Cell.vars.useFullColor then
            UnitButton_UpdateHealthColor(self)
        end

        -- Health thresholds: use EvaluateCurrentHealthPercent with a curve
        if enabledIndicators["healthThresholds"] and self.widgets.healthCalculator then
            self.indicators.healthThresholds:CheckThresholdMidnight(self.widgets.healthCalculator)
        else
            self.indicators.healthThresholds:Hide()
        end

        -- CELL_FADE_OUT_HEALTH_PERCENT: use EvaluateMissingHealthPercent with a Curve to fade
        -- frames that are above the health threshold (healthy enough to fade out)
        if CELL_FADE_OUT_HEALTH_PERCENT and self.widgets.healthCalculator then
            RebuildFadeOutHealthCurve()
            if fadeOutHealthCurve and self.states.inRange then
                -- EvaluateCurrentHealthPercent feeds secret health% into the curve
                -- Curve output: 1.0 if below threshold (needs healing), outOfRangeAlpha if above
                local targetAlpha = self.widgets.healthCalculator:EvaluateCurrentHealthPercent(fadeOutHealthCurve)
                -- targetAlpha is a secret value â€" SetAlpha accepts secrets on Midnight
                self:SetAlpha(targetAlpha)
            end
        end
    else
        -- CLASSIC/PRE-MIDNIGHT PATH: original logic
        local healthPercent = self.states.healthPercent

        if barAnimationType == "Flash" then
            self.widgets.healthBar:SetValue(self.states.health)
            local diff = healthPercent - (self.states.healthPercentOld or healthPercent)
            if diff >= 0 or self.states.healthMax == 0 then
                B.HideFlash(self)
            elseif diff <= -0.05 and diff >= -1 then --! player (just joined) UnitHealthMax(unit) may be 1 ====> diff == -maxHealth
                B.ShowFlash(self, abs(diff))
            end
        else
            self.widgets.healthBar:SetBarValue(self.states.health)
        end

        if Cell.vars.useThresholdColor or Cell.vars.useFullColor then
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
                A.FrameFadeIn(self, 0.25, self:GetAlpha(), 1)
            else
                A.FrameFadeOut(self, 0.25, self:GetAlpha(), CellDB["appearance"]["outOfRangeAlpha"])
            end
        end
    end
end

local function UnitButton_UpdateHealPrediction(self, skipStateUpdates)
    if Cell.isMidnight and self.widgets.healPredictionCalculator then
        -- MIDNIGHT PATH: use a DEDICATED calculator for heal prediction.
        -- This keeps clamp/overflow settings isolated from the shared
        -- healthCalculator used by health, absorb, and heal-absorb reads.
        -- Bar is anchored to health fill edge (set in SetOrientation).
        -- SetMinMaxValues(0, maxHealth) + SetValue(incomingHeals) lets the
        -- C++ widget compute the proportional fill natively with secrets.
        if not predictionEnabled then
            self.widgets.incomingHeal:Hide()
            return
        end
        local unit = self.states.displayedUnit
        if not unit then return end
        local calc = self.widgets.healPredictionCalculator
        -- Configure clamp: 0 = MissingHealth (no overheal past frame edge)
        calc:SetIncomingHealClampMode(0)
        calc:SetIncomingHealOverflowPercent(1.0)
        -- Populate calculator with fresh data
        UnitGetDetailedHealPrediction(unit, "player", calc)
        local maxHealth = calc:GetMaximumHealth()
        local incomingHeals = calc:GetIncomingHeals()
        local bar = self.widgets.incomingHeal
        -- Set explicit size: bar fills from health edge across remaining bar space
        if self.orientation == "horizontal" then
            bar:SetWidth(self.widgets.healthBar:GetWidth())
        else
            bar:SetHeight(self.widgets.healthBar:GetHeight())
        end
        bar:SetMinMaxValues(0, maxHealth)
        bar:SetValue(incomingHeals)
        bar:Show()
        return
    end
    -- CLASSIC/PRE-MIDNIGHT PATH: original logic
    if not predictionEnabled then
        self.widgets.incomingHeal:Hide()
        return
    end

    local unit = self.states.displayedUnit
    if not unit then return end

    if not skipStateUpdates then
        UnitButton_UpdateHealthStates(self)
    end

    local incomingHeal = self.widgets.incomingHeal
    -- Set size to match health bar for correct proportions
    if self.orientation == "horizontal" then
        incomingHeal:SetWidth(self.widgets.healthBar:GetWidth())
    else
        incomingHeal:SetHeight(self.widgets.healthBar:GetHeight())
    end

    -- Use 12.0 calculator API if available (handles secret values via C)
    local calc = self._healPredCalc
    if calc and UnitGetDetailedHealPrediction then
        pcall(function() UnitGetDetailedHealPrediction(unit, nil, calc) end)
        local allHeal
        if calc.GetIncomingHeals then
            allHeal = select(1, calc:GetIncomingHeals())
        end
        pcall(function()
            incomingHeal:SetMinMaxValues(0, self.states.healthMax)
            incomingHeal:SetValue(allHeal or 0)
        end)
    else
        -- Fallback for pre-12.0
        local value = UnitGetIncomingHeals(unit) or 0
        pcall(function()
            incomingHeal:SetMinMaxValues(0, self.states.healthMax)
            incomingHeal:SetValue(value)
        end)
    end
    incomingHeal:Show()
end

UnitButton_UpdateShieldAbsorbs = function(self, skipStateUpdates)
    if Cell.isMidnight and self.widgets.healthCalculator then
        -- MIDNIGHT PATH: use calculator secret values
        if not shieldEnabled then
            self.widgets.shieldBar:Hide()
            self.widgets.shieldBarR:Hide()
            self.widgets.overShieldGlow:Hide()
            self.widgets.overShieldGlowR:Hide()
            self.indicators.shieldBar:Hide()
            return
        end
        local unit = self.states.displayedUnit
        if not unit then return end
        -- Refresh calculator so we have current data (critical for standalone UNIT_ABSORB_AMOUNT_CHANGED events)
        UnitButton_UpdateCalculator(self)
        local absorbs = self.widgets.healthCalculator:GetTotalDamageAbsorbs()
        local healthMax = self.widgets.healthCalculator:GetMaximumHealth()
        -- Update the widget shield bar (needs min/max for correct proportioning)
        self.widgets.shieldBar:SetMinMaxValues(0, healthMax)
        self.widgets.shieldBar:SetValue(absorbs)
        self.widgets.shieldBar:Show()

        -- Overshield glow and reverse-fill bar
        -- NOTE: absorbs is a secret value on Midnight â€" we can't compare it to health to detect overshield.
        -- Show the glow whenever shields are present and overshieldEnabled is on.
        -- TODO: Use a Curve to map (absorbs + health - maxHealth) to glow visibility for precise overshield detection.
        if overshieldReverseFillEnabled then
            self.widgets.shieldBarR:SetMinMaxValues(0, healthMax)
            self.widgets.shieldBarR:SetValue(absorbs)
            self.widgets.shieldBarR:Show()
            if overshieldEnabled then
                self.widgets.overShieldGlowR:Show()
            else
                self.widgets.overShieldGlowR:Hide()
            end
            self.widgets.overShieldGlow:Hide()
        else
            if overshieldEnabled then
                self.widgets.overShieldGlow:Show()
            else
                self.widgets.overShieldGlow:Hide()
            end
            self.widgets.shieldBarR:Hide()
            self.widgets.overShieldGlowR:Hide()
        end

        -- Update shield indicator (user-configurable indicator on top of health bar)
        if enabledIndicators["shieldBar"] then
            local indBar = self.indicators.shieldBar
            if indicatorBooleans["shieldBar"] then
                -- onlyShowOvershields: can't compute overshield from secrets, hide indicator
                -- TODO: Use a Curve to detect overshield (absorbs + health > maxHealth)
                indBar:Hide()
            else
                -- SetAbsorbs anchors to health bar and uses StatusBar fill for proportioning
                indBar:Show()
                indBar:SetAbsorbs(absorbs, healthMax)
            end
        else
            self.indicators.shieldBar:Hide()
        end
        return
    end

    -- CLASSIC/PRE-MIDNIGHT PATH: original logic
    local unit = self.states.displayedUnit
    if not unit then return end

    if not skipStateUpdates then
        UnitButton_UpdateHealthStates(self)
    end

    local shieldBar = self.widgets.shieldBar
    local _ta = self.states.totalAbsorbs
    local totalAbsorbs = rawequal(_ta, nil) and 0 or _ta
    local healthMax = self.states.healthMax
    local health = self.states.health

    -- Check if values are secret (12.0+ combat)
    local isSecret = issecretvalue(totalAbsorbs) or issecretvalue(healthMax) or issecretvalue(health)

    if isSecret then
        -- Secret path: use StatusBar min/max approach (C-level handles secrets)
        -- Set size to match health bar for correct proportions
        if self.orientation == "horizontal" then
            shieldBar:SetWidth(self.widgets.healthBar:GetWidth())
        else
            shieldBar:SetHeight(self.widgets.healthBar:GetHeight())
        end

        -- Use 12.0 calculator API if available
        local calc = self._healPredCalc
        local absorbAmt, isClamped
        if calc and UnitGetDetailedHealPrediction then
            pcall(function() UnitGetDetailedHealPrediction(unit, nil, calc) end)
            if calc.GetDamageAbsorbs then
                absorbAmt, isClamped = calc:GetDamageAbsorbs()
            end
        end
        local displayAbsorbs = rawequal(absorbAmt, nil) and totalAbsorbs or absorbAmt

        if shieldEnabled then
            pcall(function()
                shieldBar:SetMinMaxValues(0, healthMax)
                shieldBar:SetValue(displayAbsorbs)
            end)
            shieldBar:Show()
        else
            shieldBar:Hide()
        end

        -- Overshield glow: use SetAlphaFromBoolean for secret bool support
        if overshieldEnabled and isClamped ~= nil then
            local glow = self.widgets.overShieldGlow
            if glow.SetAlphaFromBoolean then
                glow:Show()
                glow:SetAlphaFromBoolean(isClamped, 1, 0)
            else
                local okOver, isOver = pcall(function() return isClamped == true end)
                if okOver and isOver then glow:Show() else glow:Hide() end
            end
        else
            self.widgets.overShieldGlow:Hide()
        end
        self.widgets.shieldBarR:Hide()
        self.widgets.overShieldGlowR:Hide()

        -- Indicator: StatusBar-based, C-level handles secret values
        if enabledIndicators["shieldBar"] then
            -- Size the indicator to match health bar
            local indBar = self.indicators.shieldBar
            if self.orientation == "horizontal" then
                indBar:SetWidth(self.widgets.healthBar:GetWidth())
            else
                indBar:SetHeight(self.widgets.healthBar:GetHeight())
            end
            pcall(indBar.SetAbsorbs, indBar, displayAbsorbs, healthMax)
            indBar:Show()
        else
            self.indicators.shieldBar:Hide()
        end
    else
        -- Normal path: Lua arithmetic is safe (non-secret values)
        if totalAbsorbs > 0 then
            local shieldPercent = totalAbsorbs / healthMax

            -- Indicator (percentage-based overlay)
            if enabledIndicators["shieldBar"] then
                if indicatorBooleans["shieldBar"] then
                    -- onlyShowOvershields
                    local overshieldPercent = (totalAbsorbs + health - healthMax) / healthMax
                    if overshieldPercent > 0 then
                        self.indicators.shieldBar:Show()
                        self.indicators.shieldBar:SetPercent(overshieldPercent)
                    else
                        self.indicators.shieldBar:Hide()
                    end
                else
                    self.indicators.shieldBar:Show()
                    self.indicators.shieldBar:SetPercent(shieldPercent)
                end
            else
                self.indicators.shieldBar:Hide()
            end

            -- Widget shield bar (StatusBar)
            if shieldEnabled then
                -- Set size to match health bar
                if self.orientation == "horizontal" then
                    shieldBar:SetWidth(self.widgets.healthBar:GetWidth())
                else
                    shieldBar:SetHeight(self.widgets.healthBar:GetHeight())
                end
                shieldBar:SetMinMaxValues(0, healthMax)
                shieldBar:SetValue(totalAbsorbs)
                shieldBar:Show()
            else
                shieldBar:Hide()
            end

            -- Overshield glow
            local healthPercent = self.states.healthPercent
            if shieldPercent + healthPercent > 1 then
                if overshieldReverseFillEnabled then
                    local p = shieldPercent + healthPercent - 1
                    if p > healthPercent then p = healthPercent end
                    local barSize = (self.orientation == "horizontal")
                        and self.widgets.healthBar:GetWidth()
                        or self.widgets.healthBar:GetHeight()
                    local shieldBarR = self.widgets.shieldBarR
                    if self.orientation == "horizontal" then
                        shieldBarR:SetWidth(p * barSize)
                    else
                        shieldBarR:SetHeight(p * barSize)
                    end
                    shieldBarR:Show()
                    if overshieldEnabled then
                        self.widgets.overShieldGlowR:Show()
                    else
                        self.widgets.overShieldGlowR:Hide()
                    end
                    self.widgets.overShieldGlow:Hide()
                else
                    if overshieldEnabled then
                        self.widgets.overShieldGlow:Show()
                    else
                        self.widgets.overShieldGlow:Hide()
                    end
                    self.widgets.shieldBarR:Hide()
                    self.widgets.overShieldGlowR:Hide()
                end
            else
                self.widgets.overShieldGlow:Hide()
                self.widgets.shieldBarR:Hide()
                self.widgets.overShieldGlowR:Hide()
            end
        else
            self.indicators.shieldBar:Hide()
            shieldBar:Hide()
            self.widgets.overShieldGlow:Hide()
            self.widgets.shieldBarR:Hide()
            self.widgets.overShieldGlowR:Hide()
        end
    end
end

local function UnitButton_UpdateHealAbsorbs(self, skipStateUpdates)
    if Cell.isMidnight and self.widgets.healthCalculator then
        -- MIDNIGHT PATH: use calculator secret values
        if not absorbEnabled then
            self.widgets.absorbsBar:Hide()
            self.widgets.overAbsorbGlow:Hide()
            return
        end
        local unit = self.states.displayedUnit
        if not unit then return end
        -- Refresh calculator so we have current data (critical for standalone UNIT_HEAL_ABSORB_AMOUNT_CHANGED events)
        UnitButton_UpdateCalculator(self)
        local healAbsorbs = self.widgets.healthCalculator:GetHealAbsorbs()
        self.widgets.absorbsBar:SetValue(healAbsorbs)
        self.widgets.absorbsBar:Show()
        return
    end

    -- CLASSIC/PRE-MIDNIGHT PATH: original logic
    if not absorbEnabled then
        self.widgets.absorbsBar:Hide()
        self.widgets.overAbsorbGlow:Hide()
        return
    end

    local unit = self.states.displayedUnit
    if not unit then return end

    if not skipStateUpdates then
        UnitButton_UpdateHealthStates(self)
    end

    local absorbsBar = self.widgets.absorbsBar
    if absorbInvertColor then
        local r, g, b = F.InvertColor(self.widgets.healthBar:GetStatusBarColor())
        absorbsBar:SetStatusBarColor(r, g, b)
        absorbsBar.overAbsorbGlow:SetVertexColor(r, g, b)
    end

    -- Use calculator API for heal absorbs
    local calc = self._healPredCalc
    local healAbsorbAmt, isClamped
    if calc and UnitGetDetailedHealPrediction then
        pcall(function() UnitGetDetailedHealPrediction(unit, nil, calc) end)
        if calc.GetHealAbsorbs then
            healAbsorbAmt, isClamped = calc:GetHealAbsorbs()
        end
    end

    -- Use rawequal for nil check: `or` crashes on secret values (boolean test)
    local _healAbs = rawequal(healAbsorbAmt, nil) and self.states.healAbsorbs or healAbsorbAmt
    local displayAbsorbs = rawequal(_healAbs, nil) and 0 or _healAbs
    pcall(function()
        absorbsBar:SetMinMaxValues(0, self.states.health)
        absorbsBar:SetValue(displayAbsorbs)
    end)
    absorbsBar:Show()

    -- Over-absorb glow using SetAlphaFromBoolean for secret bool support
    local glow = self.widgets.overAbsorbGlow
    if isClamped ~= nil then
        if SetAlphaFromBoolean then
            glow:Show()
            SetAlphaFromBoolean(glow, isClamped, 1, 0)
        else
            local okOver, isOver = pcall(function() return isClamped == true end)
            if okOver and isOver then glow:Show() else glow:Hide() end
        end
    else
        -- Fallback: try comparison with pcall
        local okGlow, showGlow = pcall(function()
            return displayAbsorbs and displayAbsorbs > self.states.health
        end)
        if okGlow and showGlow then
            glow:Show()
        else
            glow:Hide()
        end
    end
end

local function UnitButton_UpdateThreat(self)
    local unit = self.states.displayedUnit
    if not unit or not UnitExists(unit) then return end

    local status = UnitThreatSituation(unit)
    if status and status >= 1 then
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

local function UnitButton_UpdateCombatIcon(self)
    if not enabledIndicators["combatIcon"] then return end

    local unit = self.states.displayedUnit
    if not unit then return end

    if not (indicatorBooleans["combatIcon"] and InCombatLockdown()) and UnitAffectingCombat(unit) then
        self.indicators.combatIcon:Show()
    else
        self.indicators.combatIcon:Hide()
    end
end

-- UNIT_IN_RANGE_UPDATE: unit, inRange
local IsInRange = F.IsInRange
local function UnitButton_UpdateInRange(self, ir)
    local unit = self.states.displayedUnit
    if not unit then return end

    local inRange = IsInRange(unit)
    -- Nil-safety: if IsInRange errors (e.g. secret value issue), default to true
    -- so frames don't grey out incorrectly
    if inRange == nil then inRange = true end

    self.states.inRange = inRange
    if Cell.loaded then
        if self.states.inRange ~= self.states.wasInRange then
            if inRange then
                if CELL_FADE_OUT_HEALTH_PERCENT then
                    if Cell.isMidnight and self.widgets and self.widgets.healthCalculator then
                        -- Midnight: use Curve-based fade (secret-safe)
                        RebuildFadeOutHealthCurve()
                        if fadeOutHealthCurve then
                            local targetAlpha = self.widgets.healthCalculator:EvaluateCurrentHealthPercent(fadeOutHealthCurve)
                            self:SetAlpha(targetAlpha)
                        else
                            A.FrameFadeIn(self, 0.25, self:GetAlpha(), 1)
                        end
                    elseif not self.states.healthPercent or self.states.healthPercent < CELL_FADE_OUT_HEALTH_PERCENT then
                        A.FrameFadeIn(self, 0.25, self:GetAlpha(), 1)
                    else
                        A.FrameFadeOut(self, 0.25, self:GetAlpha(), CellDB["appearance"]["outOfRangeAlpha"])
                    end
                else
                    A.FrameFadeIn(self, 0.25, self:GetAlpha(), 1)
                end
            else
                A.FrameFadeOut(self, 0.25, self:GetAlpha(), CellDB["appearance"]["outOfRangeAlpha"])
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
            local prefix, id = strmatch(unit, "([^%d]+)([%d]*)")
            self.states.displayedUnit = prefix .. "pet" .. (id or "")
        end
        self.indicators.nameText:UpdateVehicleName()
    else
        self.states.inVehicle = nil
        self.states.displayedUnit = self.states.unit
        self.indicators.nameText.vehicle:SetText("")
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
    -- Midnight 12.0.0+: UnitIsAFK may return a secret boolean â€" skip on Midnight
    elseif not Cell.isMidnight and UnitIsAFK(unit) then
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
        else
            if status == Enum.SummonStatus.Accepted then
                statusText:SetStatus("ACCEPTED")
            elseif status == Enum.SummonStatus.Declined then
                statusText:SetStatus("DECLINED")
            end
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

    -- unit name may be a secret string in instances on Midnight 12.0.0+
    -- FontString:SetText() accepts secrets, so display works without change
    -- However, any NAME COMPARISONS (name == something) will error if name is secret
    self.states.name = UnitName(unit)
    self.states.fullName = F.UnitFullName(unit)
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
        or ((UnitIsPlayer(unit) or UnitInPartyIsAI(unit)) and UnitIsCharmed(unit)) or self.states.inVehicle then
            self.indicators.nameText:SetColor(F.GetUnitClassColor(unit))
        else
            self.indicators.nameText:SetColor(unpack(indicatorColors["nameText"][2]))
        end
    end
end

UnitButton_UpdateHealthTextColor = function(self)
    local unit = self.states.unit
    if not unit then return end

    if enabledIndicators["healthText"] then
        self.indicators.healthText:SetColor(F.GetUnitClassColor(unit))
    end
end

UnitButton_UpdateHealthColor = function(self)
    local unit = self.states.unit
    if not unit then return end

    -- NOTE: Health bar coloring uses non-secret data (class, settings, UnitIsPlayer, etc.)
    -- so the classic color logic below works on both Midnight and pre-Midnight.
    -- TODO: implement proper ColorCurve coloring for threshold/gradient modes once
    -- SetStatusBarColor secret color API is verified on PTR.

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
            barR, barG, barB, lossR, lossG, lossB = F.GetHealthBarColor(self.states.healthPercent, self.states.isDeadOrGhost or self.states.isDead, 0, 1, 0.2)
        else
            barR, barG, barB, lossR, lossG, lossB = F.GetHealthBarColor(self.states.healthPercent, self.states.isDeadOrGhost or self.states.isDead, F.GetClassColor(self.states.class))
        end
    elseif F.IsPet(self.states.guid, self.states.unit) then -- pet
        barR, barG, barB, lossR, lossG, lossB = F.GetHealthBarColor(self.states.healthPercent, self.states.isDeadOrGhost or self.states.isDead, 0.5, 0.5, 1)
    else -- npc
        barR, barG, barB, lossR, lossG, lossB = F.GetHealthBarColor(self.states.healthPercent, self.states.isDeadOrGhost or self.states.isDead, 0, 1, 0.2)
    end

    self.widgets.healthBar:SetStatusBarColor(barR, barG, barB, barA)
    self.widgets.healthBarLoss:SetVertexColor(lossR, lossG, lossB, lossA)

    if Cell.isMidnight then
        -- StatusBar on Midnight: use SetStatusBarColor
        if Cell.loaded and CellDB["appearance"]["healPrediction"][2] then
            self.widgets.incomingHeal:SetStatusBarColor(CellDB["appearance"]["healPrediction"][3][1], CellDB["appearance"]["healPrediction"][3][2], CellDB["appearance"]["healPrediction"][3][3], CellDB["appearance"]["healPrediction"][3][4])
        else
            self.widgets.incomingHeal:SetStatusBarColor(barR, barG, barB, 0.4)
        end
    else
        -- Texture on pre-Midnight: use SetVertexColor
        if Cell.loaded and CellDB["appearance"]["healPrediction"][2] then
            self.widgets.incomingHeal:SetVertexColor(CellDB["appearance"]["healPrediction"][3][1], CellDB["appearance"]["healPrediction"][3][2], CellDB["appearance"]["healPrediction"][3][3], CellDB["appearance"]["healPrediction"][3][4])
        else
            self.widgets.incomingHeal:SetVertexColor(barR, barG, barB, 0.4)
        end
    end
end

-- Configures the health color curve for a button (Midnight 12.0.0+)
-- Called when color settings change (e.g., class color, custom color toggled)
function B.UpdateHealthColorCurve(button)
    if not (Cell.isMidnight and button.widgets.healthColorCurve) then return end
    local curve = button.widgets.healthColorCurve
    curve:ClearPoints()
    -- Default green gradient; overridden by class color / custom color settings
    -- TODO: read from CellDB["appearance"] color settings and build proper curve
    curve:AddPoint(0.0, {r=1,   g=0,   b=0,   a=1}) -- red at 0%
    curve:AddPoint(0.5, {r=1,   g=1,   b=0,   a=1}) -- yellow at 50%
    curve:AddPoint(1.0, {r=0,   g=0.9, b=0,   a=1}) -- green at 100%
end

-------------------------------------------------
-- translit names
-------------------------------------------------
Cell.RegisterCallback("TranslitNames", "UnitButton_TranslitNames", function()
    F.IterateAllUnitButtons(function(b)
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
    UnitButton_UpdateHealth(self, nil, true)
    UnitButton_UpdateHealPrediction(self, true)
    UnitButton_UpdateStatusText(self)
    UnitButton_UpdateHealthColor(self)
    UnitButton_UpdateTarget(self)
    UnitButton_UpdatePlayerRaidIcon(self)
    UnitButton_UpdateTargetRaidIcon(self)
    UnitButton_UpdateShieldAbsorbs(self, true)
    UnitButton_UpdateHealAbsorbs(self, true)
    UnitButton_UpdateInRange(self)
    UnitButton_UpdateRole(self)
    UnitButton_UpdateLeader(self)
    UnitButton_UpdateReadyCheck(self)
    UnitButton_UpdateThreat(self)
    UnitButton_UpdateThreatBar(self)
    -- UnitButton_UpdateStatusIcon(self)
    I.UpdateStatusIcon_Resurrection(self)

    UnitButton_UpdatePowerStates(self)
    if Cell.loaded then
        if self._powerUpdateRequired then
            self._powerUpdateRequired = nil

            self._shouldShowPowerText = ShouldShowPowerText(self)
            self._shouldShowPowerBar = ShouldShowPowerBar(self)
            CheckPowerEventRegistration(self)

            if self._shouldShowPowerText then
                UnitButton_UpdatePowerTextColor(self)
                UnitButton_UpdatePowerText(self)
            else
                self.indicators.powerText:Hide()
            end

            if self._shouldShowPowerBar then
                ShowPowerBar(self)
            else
                HidePowerBar(self)
            end

        end
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
        if enabledIndicators["targetRaidIcon"] then
            self:RegisterEvent("UNIT_TARGET")
        end
        if enabledIndicators["readyCheckIcon"] then
            self:RegisterEvent("READY_CHECK")
            self:RegisterEvent("READY_CHECK_FINISHED")
            self:RegisterEvent("READY_CHECK_CONFIRM")
        end
    else
        self:RegisterEvent("RAID_TARGET_UPDATE")
        self:RegisterEvent("UNIT_TARGET")
        self:RegisterEvent("READY_CHECK")
        self:RegisterEvent("READY_CHECK_FINISHED")
        self:RegisterEvent("READY_CHECK_CONFIRM")
    end

    -- self:RegisterEvent("UNIT_PHASE") -- warmode, traditional sources of phasing such as progress through quest chains
    -- self:RegisterEvent("PARTY_MEMBER_DISABLE")
    -- self:RegisterEvent("PARTY_MEMBER_ENABLE")
    -- self:RegisterEvent("INCOMING_RESURRECT_CHANGED")

    -- self:RegisterEvent("VOICE_CHAT_CHANNEL_ACTIVATED")
    -- self:RegisterEvent("VOICE_CHAT_CHANNEL_DEACTIVATED")

    -- self:RegisterEvent("UNIT_PET")
    self:RegisterEvent("UNIT_PORTRAIT_UPDATE") -- pet summoned far away

    --! OnShowæ—¶ç«‹å³æ‰§è¡Œï¼Œä½†UpdateIndicatorså¯èƒ½å¹¶æœªæ‰§è¡Œå®Œæ¯•ï¼Œå¯¼è‡´åœ¨ResetCustomIndicatorsè¿‡ç¨‹ä¸­æŒ‡ç¤ºå™¨å'ç"Ÿå˜åŒ–ï¼Œè¿›è€ŒæŠ¥é"™
    local success, result = pcall(UnitButton_UpdateAll, self)
    if not success then
        F.Debug("UnitButton_UpdateAll |cffff0000FAILED:|r", self:GetName(), result)
    end
end

local function UnitButton_UnregisterEvents(self)
    self:UnregisterAllEvents()
end

local function UnitButton_OnEvent(self, event, unit, arg)
    if unit and (self.states.displayedUnit == unit or self.states.unit == unit) then
        if  event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE" or event == "UNIT_CONNECTION" then
            self._updateRequired = 1
            self._powerUpdateRequired = 1

        elseif event == "UNIT_NAME_UPDATE" then
            UnitButton_UpdateName(self)
            UnitButton_UpdateNameTextColor(self)
            UnitButton_UpdateHealthColor(self)
            UnitButton_UpdateHealthTextColor(self)
            UnitButton_UpdatePowerTextColor(self)

        elseif event == "UNIT_MAXHEALTH" then
            UnitButton_UpdateHealthMax(self)
            UnitButton_UpdateHealth(self, nil, true)
            UnitButton_UpdateHealPrediction(self, true)
            UnitButton_UpdateShieldAbsorbs(self, true)
            UnitButton_UpdateHealAbsorbs(self, true)

        elseif event == "UNIT_HEALTH" then
            UnitButton_UpdateHealth(self)
            UnitButton_UpdateHealPrediction(self, true)
            UnitButton_UpdateShieldAbsorbs(self, true)
            UnitButton_UpdateHealAbsorbs(self, true)
            -- UnitButton_UpdateStatusText(self)

        elseif event == "UNIT_HEAL_PREDICTION" then
            UnitButton_UpdateHealPrediction(self)

        elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
            UnitButton_UpdateShieldAbsorbs(self)
            -- Refresh health text so shield component updates immediately
            if enabledIndicators["healthText"] then
                UnitButton_UpdateHealthStates(self)
            end

        elseif event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
            UnitButton_UpdateHealAbsorbs(self)
            -- Refresh health text so healAbsorb component updates immediately
            if enabledIndicators["healthText"] then
                UnitButton_UpdateHealthStates(self)
            end

        elseif event == "UNIT_MAXPOWER" then
            UnitButton_UpdatePowerStates(self)
            UnitButton_UpdatePowerMax(self)
            UnitButton_UpdatePower(self)
            UnitButton_UpdatePowerText(self)

        elseif event == "UNIT_POWER_FREQUENT" then
            UnitButton_UpdatePowerStates(self)
            UnitButton_UpdatePower(self)
            UnitButton_UpdatePowerText(self)

        elseif event == "UNIT_DISPLAYPOWER" then
            UnitButton_UpdatePowerStates(self)
            UnitButton_UpdatePowerMax(self)
            UnitButton_UpdatePower(self)
            UnitButton_UpdatePowerType(self)
            UnitButton_UpdatePowerTextColor(self)
            UnitButton_UpdatePowerText(self)

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
                self._powerUpdateRequired = 1
            end
        end

    else
        if event == "GROUP_ROSTER_UPDATE" then
            -- FIXME:
            -- if IsDelveInProgress() then
            --     self.__tickCount = 2
            --     self.__updateElapsed = 0.25
            -- else
                self._updateRequired = 1
                self._powerUpdateRequired = 1
            -- end

        elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
            UnitButton_UpdateLeader(self, event)
            if event == "PLAYER_REGEN_ENABLED" then
                -- 12.0+: secret values may linger briefly after combat ends.
                -- Immediate refresh + delayed retry to catch stale secrets.
                UnitButton_UpdateHealth(self)
                UnitButton_UpdateShieldAbsorbs(self)
                UnitButton_UpdateHealAbsorbs(self)
                UnitButton_UpdatePowerStates(self)
                UnitButton_UpdatePowerText(self)
                UnitButton_UpdateAuras(self)
                -- Delayed retry: values at full health/power won't get events
                local btn = self
                C_Timer.After(0.5, function()
                    if btn.states.displayedUnit then
                        UnitButton_UpdateHealth(btn)
                        UnitButton_UpdateShieldAbsorbs(btn)
                        UnitButton_UpdateHealAbsorbs(btn)
                        UnitButton_UpdatePowerStates(btn)
                        UnitButton_UpdatePowerText(btn)
                        UnitButton_UpdateAuras(btn)
                    end
                end)
            end

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
            -- F.Debug("|cffbbbbbb=== ZONE_CHANGED_NEW_AREA ===")
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
        F.Debug("|cffff1111*** EnterLeaveInstance:|r UnitButton_UpdateAll")
        F.IterateAllUnitButtons(UnitButton_UpdateAll, true)
        timer = nil
    end)
end
Cell.RegisterCallback("EnterInstance", "UnitButton_EnterInstance", EnterLeaveInstance)
Cell.RegisterCallback("LeaveInstance", "UnitButton_LeaveInstance", EnterLeaveInstance)

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
            -- Reset calculator predicted values to prevent stale data from previous unit
            if self.widgets and self.widgets.healthCalculator then
                self.widgets.healthCalculator:ResetPredictedValues()
            end
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

            -- ResetAuraTables(self)
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
    self._powerUpdateRequired = 1
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
    self._updateRequired = nil
    F.RemoveElementsExceptKeys(self.states, "unit", "displayedUnit")
    -- Reset calculator predicted values so hidden button doesn't hold stale data
    if self.widgets and self.widgets.healthCalculator then
        self.widgets.healthCalculator:ResetPredictedValues()
    end
end

local function UnitButton_OnEnter(self)
    if not IsEncounterInProgress() then UnitButton_UpdateStatusText(self) end

    if highlightEnabled then self.widgets.mouseoverHighlight:Show() end

    local unit = self.states.displayedUnit
    if not unit then return end

    F.ShowTooltips(self, "unit", unit)
end

local function UnitButton_OnLeave(self)
    self.widgets.mouseoverHighlight:Hide()
    GameTooltip:Hide()
end

local UNKNOWN, UNKNOWNOBJECT = _G.UNKNOWN, _G.UNKNOWNOBJECT
local function UnitButton_OnTick(self)
    -- print(GetTime(), "OnTick", self._updateRequired, self:GetAttribute("refreshOnUpdate"), self:GetName())
    local e = (self.__tickCount or 0) + 1
    if e >= 2 then -- every 0.5 second
        e = 0

        if self.states.unit and self.states.displayedUnit then
            local displayedGuid = UnitGUID(self.states.displayedUnit)
            if displayedGuid ~= self.__displayedGuid then
                -- NOTE: displayed unit entity changed
                F.RemoveElementsExceptKeys(self.states, "unit", "displayedUnit")
                self.__displayedGuid = displayedGuid
                if displayedGuid then --? clearing unit may come before hiding
                    self._updateRequired = 1
                    self._powerUpdateRequired = 1
                end
            end

            local guid = UnitGUID(self.states.unit)
            if guid and guid ~= self.__unitGuid then
                -- print("guidChanged:", self:GetName(), self.states.unit, guid)
                -- NOTE: unit entity changed
                -- update Cell.vars.guids
                self.__unitGuid = guid
                -- On Midnight 12.0.0+, GUIDs for non-player units in instances are secret
                -- Can't use a secret as a table key â€" only store non-secret GUIDs
                if not self.isSpotlight then
                    if not (Cell.isMidnight and F.IsSecretValue and F.IsSecretValue(guid)) then
                        Cell.vars.guids[guid] = self.states.unit
                    end
                end

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
                        -- å›½æœå¯ä»¥èµ·åä¸ºâ€œæœªçŸ¥ç›®æ ‡â€ï¼Œå¹²ï¼å°±åªå¤šé‡è¯•4æ¬¡å¥½äº†
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

    if self._updateRequired and self._indicatorsReady then
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
        e = 0
        UnitButton_OnTick(self)
        UnitButton_UpdateCombatIcon(self)
    end
    self.__updateElapsed = e
end

-------------------------------------------------
-- button functions
-------------------------------------------------
function B.SetPowerSize(button, size)
    -- print(GetTime(), "SetPowerSize", button:GetName(), button:IsShown(), button:IsVisible())
    button.powerSize = size

    if size == 0 then
        HidePowerBar(button)
        button._shouldShowPowerBar = false
    else
        button._shouldShowPowerBar = ShouldShowPowerBar(button)
        if button._shouldShowPowerBar then
            ShowPowerBar(button)
        else
            HidePowerBar(button)
        end
    end
    CheckPowerEventRegistration(button)
end

function B.UpdateShields(button)
    predictionEnabled = CellDB["appearance"]["healPrediction"][1]
    shieldEnabled = CellDB["appearance"]["shield"][1]
    overshieldEnabled = CellDB["appearance"]["overshield"][1]
    overshieldReverseFillEnabled = shieldEnabled and CellDB["appearance"]["overshieldReverseFill"]
    absorbEnabled = CellDB["appearance"]["healAbsorb"][1]
    absorbInvertColor = CellDB["appearance"]["healAbsorbInvertColor"]

    if Cell.isMidnight then
        -- StatusBars on Midnight: use SetStatusBarColor
        button.widgets.shieldBar:SetStatusBarColor(unpack(CellDB["appearance"]["shield"][2]))
        button.widgets.shieldBarR:SetStatusBarColor(unpack(CellDB["appearance"]["shield"][2]))
    else
        -- Textures on pre-Midnight: use SetVertexColor
        button.widgets.shieldBar:SetVertexColor(unpack(CellDB["appearance"]["shield"][2]))
        button.widgets.shieldBarR:SetVertexColor(unpack(CellDB["appearance"]["shield"][2]))
    end
    -- overShieldGlow textures are always textures
    button.widgets.overShieldGlow:SetVertexColor(unpack(CellDB["appearance"]["overshield"][2]))
    button.widgets.overShieldGlowR:SetVertexColor(unpack(CellDB["appearance"]["overshield"][2]))
    if not absorbInvertColor then
        button.widgets.overAbsorbGlow:SetVertexColor(unpack(CellDB["appearance"]["healAbsorb"][2]))
        if Cell.isMidnight then
            button.widgets.absorbsBar:SetStatusBarColor(unpack(CellDB["appearance"]["healAbsorb"][2]))
        else
            button.widgets.absorbsBar:SetVertexColor(unpack(CellDB["appearance"]["healAbsorb"][2]))
        end
    end

    UnitButton_UpdateHealPrediction(button)
    UnitButton_UpdateHealAbsorbs(button)
    UnitButton_UpdateShieldAbsorbs(button)
end

function B.SetTexture(button, tex)
    button.widgets.healthBar:SetStatusBarTexture(tex)
    button.widgets.healthBar:GetStatusBarTexture():SetDrawLayer("ARTWORK", -7) --! VERY IMPORTANT
    button.widgets.healthBarLoss:SetTexture(tex)
    button.widgets.powerBar:SetStatusBarTexture(tex)
    button.widgets.powerBar:GetStatusBarTexture():SetDrawLayer("ARTWORK", -7) --! VERY IMPORTANT
    button.widgets.powerBarLoss:SetTexture(tex)
    if Cell.isMidnight then
        button.widgets.incomingHeal:SetStatusBarTexture(tex)
    else
        button.widgets.incomingHeal:SetTexture(tex)
    end
    button.widgets.damageFlashTex:SetTexture(tex)
end

function B.UpdateColor(button)
    UnitButton_UpdateHealthColor(button)
    UnitButton_UpdatePowerType(button)
    UnitButton_UpdatePowerTextColor(button)
    button:SetBackdropColor(0, 0, 0, CellDB["appearance"]["bgAlpha"])
end

local function IncomingHeal_SetValue_Horizontal(self, incomingPercent, healthPercent)
    local barWidth = self:GetParent():GetWidth()
    local incomingHealWidth = incomingPercent * barWidth
    local lostHealthWidth = barWidth * (1 - healthPercent)

    -- print(incomingPercent, barWidth, incomingHealWidth, lostHealthWidth)
    -- FIXME: if incomingPercent is a very tiny number, like 0.005
    -- P.Scale(incomingHealWidth) ==> 0
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
        local r, g, b = F.InvertColor(self.healthBar:GetStatusBarColor())
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
        local r, g, b = F.InvertColor(self.healthBar:GetStatusBarColor())
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

function B.SetOrientation(button, orientation, rotateTexture)
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

    -- StatusBar orientation for shield/absorb/heal bars (12.0 secret value support)
    local barOrientation = (orientation == "vertical_health") and "vertical" or orientation
    incomingHeal:SetOrientation(barOrientation)
    incomingHeal:SetRotatesTexture(rotateTexture)
    shieldBar:SetOrientation(barOrientation)
    shieldBar:SetRotatesTexture(rotateTexture)
    absorbsBar:SetOrientation(barOrientation)
    absorbsBar:SetRotatesTexture(rotateTexture)

    button.indicators.healthThresholds:SetOrientation(orientation)

    if rotateTexture then
        F.RotateTexture(healthBarLoss, 90)
        F.RotateTexture(powerBarLoss, 90)
        if not Cell.isMidnight then F.RotateTexture(incomingHeal, 90) end
        F.RotateTexture(damageFlashTex, 90)
    else
        F.RotateTexture(healthBarLoss, 0)
        F.RotateTexture(powerBarLoss, 0)
        if not Cell.isMidnight then F.RotateTexture(incomingHeal, 0) end
        F.RotateTexture(damageFlashTex, 0)
    end

    if orientation == "horizontal" then
        -- update healthBarLoss
        P.ClearPoints(healthBarLoss)
        P.Point(healthBarLoss, "TOPRIGHT", healthBar)
        P.Point(healthBarLoss, "BOTTOMLEFT", healthBar:GetStatusBarTexture(), "BOTTOMRIGHT")

        -- update powerBarLoss
        P.ClearPoints(powerBarLoss)
        P.Point(powerBarLoss, "TOPRIGHT", powerBar)
        P.Point(powerBarLoss, "BOTTOMLEFT", powerBar:GetStatusBarTexture(), "BOTTOMRIGHT")

        -- update gapTexture
        P.ClearPoints(gapTexture)
        P.Point(gapTexture, "BOTTOMLEFT", powerBar, "TOPLEFT")
        P.Point(gapTexture, "BOTTOMRIGHT", powerBar, "TOPRIGHT")
        P.Height(gapTexture, CELL_BORDER_SIZE)

        if Cell.isMidnight then
            -- Midnight: anchor incomingHeal to health fill edge so it starts where health ends
            P.ClearPoints(incomingHeal)
            P.Point(incomingHeal, "TOPLEFT", healthBar:GetStatusBarTexture(), "TOPRIGHT")
            P.Point(incomingHeal, "BOTTOMLEFT", healthBar:GetStatusBarTexture(), "BOTTOMRIGHT")
            incomingHeal:SetOrientation("horizontal")
            shieldBar:SetOrientation("horizontal")
            shieldBarR:SetOrientation("horizontal")
            absorbsBar:SetOrientation("horizontal")
        else
            -- Pre-Midnight: Textures with manual positioning
            -- update incomingHeal
            incomingHeal.SetValue = IncomingHeal_SetValue_Horizontal
            P.ClearPoints(incomingHeal)
            P.Point(incomingHeal, "TOPLEFT", healthBar:GetStatusBarTexture(), "TOPRIGHT")
            P.Point(incomingHeal, "BOTTOMLEFT", healthBar:GetStatusBarTexture(), "BOTTOMRIGHT")

            -- update shieldBar
            shieldBar.SetValue = ShieldBar_SetValue_Horizontal
            P.ClearPoints(shieldBar)
            P.Point(shieldBar, "TOPLEFT", healthBar:GetStatusBarTexture(), "TOPRIGHT")
            P.Point(shieldBar, "BOTTOMLEFT", healthBar:GetStatusBarTexture(), "BOTTOMRIGHT")

            -- update shieldBarR
            P.ClearPoints(shieldBarR)
            P.Point(shieldBarR, "TOPRIGHT", healthBar:GetStatusBarTexture())
            P.Point(shieldBarR, "BOTTOMRIGHT", healthBar:GetStatusBarTexture())

            -- update absorbsBar
            absorbsBar.SetValue = AbsorbsBar_SetValue_Horizontal
            P.ClearPoints(absorbsBar)
            P.Point(absorbsBar, "TOPRIGHT", healthBar:GetStatusBarTexture())
            P.Point(absorbsBar, "BOTTOMRIGHT", healthBar:GetStatusBarTexture())
        end

        -- update overShieldGlow
        P.ClearPoints(overShieldGlow)
        P.Point(overShieldGlow, "TOPRIGHT")
        P.Point(overShieldGlow, "BOTTOMRIGHT")
        P.Width(overShieldGlow, 4)
        F.RotateTexture(overShieldGlow, 0)

        -- update overShieldGlowR
        P.ClearPoints(overShieldGlowR)
        P.Point(overShieldGlowR, "TOP", shieldBarR, "TOPLEFT", 0, 0)
        P.Point(overShieldGlowR, "BOTTOM", shieldBarR, "BOTTOMLEFT", 0, 0)
        P.Width(overShieldGlowR, 8)
        F.RotateTexture(overShieldGlowR, 0)

        -- update overAbsorbGlow
        P.ClearPoints(overAbsorbGlow)
        P.Point(overAbsorbGlow, "TOPLEFT")
        P.Point(overAbsorbGlow, "BOTTOMLEFT")
        P.Width(overAbsorbGlow, 4)
        F.RotateTexture(overAbsorbGlow, 0)

        -- update damageFlashTex
        damageFlashTex.SetValue = DamageFlashTex_SetValue_Horizontal
        P.ClearPoints(damageFlashTex)
        P.Point(damageFlashTex, "TOPLEFT", healthBar:GetStatusBarTexture(), "TOPRIGHT")
        P.Point(damageFlashTex, "BOTTOMLEFT", healthBar:GetStatusBarTexture(), "BOTTOMRIGHT")

    else -- vertical / vertical_health
        P.ClearPoints(healthBarLoss)
        P.Point(healthBarLoss, "TOPRIGHT", healthBar)
        P.Point(healthBarLoss, "BOTTOMLEFT", healthBar:GetStatusBarTexture(), "TOPLEFT")

        if orientation == "vertical" then
            -- update powerBarLoss
            P.ClearPoints(powerBarLoss)
            P.Point(powerBarLoss, "TOPRIGHT", powerBar)
            P.Point(powerBarLoss, "BOTTOMLEFT", powerBar:GetStatusBarTexture(), "TOPLEFT")

            -- update gapTexture
            P.ClearPoints(gapTexture)
            P.Point(gapTexture, "TOPRIGHT", powerBar, "TOPLEFT")
            P.Point(gapTexture, "BOTTOMRIGHT", powerBar, "BOTTOMLEFT")
            P.Width(gapTexture, CELL_BORDER_SIZE)
        else -- vertical_health
            -- update powerBarLoss
            P.ClearPoints(powerBarLoss)
            P.Point(powerBarLoss, "TOPRIGHT", powerBar)
            P.Point(powerBarLoss, "BOTTOMLEFT", powerBar:GetStatusBarTexture(), "BOTTOMRIGHT")

            -- update gapTexture
            P.ClearPoints(gapTexture)
            P.Point(gapTexture, "BOTTOMLEFT", powerBar, "TOPLEFT")
            P.Point(gapTexture, "BOTTOMRIGHT", powerBar, "TOPRIGHT")
            P.Height(gapTexture, CELL_BORDER_SIZE)
        end

        if Cell.isMidnight then
            -- Midnight: anchor incomingHeal to health fill edge so it starts where health ends
            P.ClearPoints(incomingHeal)
            P.Point(incomingHeal, "BOTTOMLEFT", healthBar:GetStatusBarTexture(), "TOPLEFT")
            P.Point(incomingHeal, "BOTTOMRIGHT", healthBar:GetStatusBarTexture(), "TOPRIGHT")
            incomingHeal:SetOrientation("vertical")
            shieldBar:SetOrientation("vertical")
            shieldBarR:SetOrientation("vertical")
            absorbsBar:SetOrientation("vertical")
        else
            -- Pre-Midnight: Textures with manual positioning
            -- update incomingHeal
            incomingHeal.SetValue = IncomingHeal_SetValue_Vertical
            P.ClearPoints(incomingHeal)
            P.Point(incomingHeal, "BOTTOMLEFT", healthBar:GetStatusBarTexture(), "TOPLEFT")
            P.Point(incomingHeal, "BOTTOMRIGHT", healthBar:GetStatusBarTexture(), "TOPRIGHT")

            -- update shieldBar
            shieldBar.SetValue = ShieldBar_SetValue_Vertical
            P.ClearPoints(shieldBar)
            P.Point(shieldBar, "BOTTOMLEFT", healthBar:GetStatusBarTexture(), "TOPLEFT")
            P.Point(shieldBar, "BOTTOMRIGHT", healthBar:GetStatusBarTexture(), "TOPRIGHT")

            -- update shieldBarR
            P.ClearPoints(shieldBarR)
            P.Point(shieldBarR, "TOPLEFT", healthBar:GetStatusBarTexture())
            P.Point(shieldBarR, "TOPRIGHT", healthBar:GetStatusBarTexture())

            -- update absorbsBar
            absorbsBar.SetValue = AbsorbsBar_SetValue_Vertical
            P.ClearPoints(absorbsBar)
            P.Point(absorbsBar, "TOPLEFT", healthBar:GetStatusBarTexture())
            P.Point(absorbsBar, "TOPRIGHT", healthBar:GetStatusBarTexture())
        end

        -- update overShieldGlow
        P.ClearPoints(overShieldGlow)
        P.Point(overShieldGlow, "TOPLEFT")
        P.Point(overShieldGlow, "TOPRIGHT")
        P.Height(overShieldGlow, 4)
        F.RotateTexture(overShieldGlow, 90)

        -- update overShieldGlowR
        P.ClearPoints(overShieldGlowR)
        P.Point(overShieldGlowR, "LEFT", shieldBarR, "BOTTOMLEFT", 0, 0)
        P.Point(overShieldGlowR, "RIGHT", shieldBarR, "BOTTOMRIGHT", 0, 0)
        P.Height(overShieldGlowR, 8)
        F.RotateTexture(overShieldGlowR, 90)

        -- update overAbsorbGlow
        P.ClearPoints(overAbsorbGlow)
        P.Point(overAbsorbGlow, "BOTTOMLEFT")
        P.Point(overAbsorbGlow, "BOTTOMRIGHT")
        P.Height(overAbsorbGlow, 4)
        F.RotateTexture(overAbsorbGlow, 90)

        -- update damageFlashTex
        damageFlashTex.SetValue = DamageFlashTex_SetValue_Vertical
        P.ClearPoints(damageFlashTex)
        P.Point(damageFlashTex, "BOTTOMLEFT", healthBar:GetStatusBarTexture(), "TOPLEFT")
        P.Point(damageFlashTex, "BOTTOMRIGHT", healthBar:GetStatusBarTexture(), "TOPRIGHT")
    end

    -- update actions
    I.UpdateActionsOrientation(button, orientation)
end

function B.UpdateHighlightColor(button)
    button.widgets.targetHighlight:SetBackdropBorderColor(unpack(CellDB["appearance"]["targetColor"]))
    button.widgets.mouseoverHighlight:SetBackdropBorderColor(unpack(CellDB["appearance"]["mouseoverColor"]))
end

function B.UpdateHighlightSize(button)
    local targetHighlight = button.widgets.targetHighlight
    local mouseoverHighlight = button.widgets.mouseoverHighlight

    local size = CellDB["appearance"]["highlightSize"]

    if size ~= 0 then
        highlightEnabled = true

        P.ClearPoints(targetHighlight)
        P.ClearPoints(mouseoverHighlight)

        -- update point
        if size < 0 then
            size = abs(size)
            P.Point(targetHighlight, "TOPLEFT", button, "TOPLEFT")
            P.Point(targetHighlight, "BOTTOMRIGHT", button, "BOTTOMRIGHT")
            P.Point(mouseoverHighlight, "TOPLEFT", button, "TOPLEFT")
            P.Point(mouseoverHighlight, "BOTTOMRIGHT", button, "BOTTOMRIGHT")
        else
            P.Point(targetHighlight, "TOPLEFT", button, "TOPLEFT", -size, size)
            P.Point(targetHighlight, "BOTTOMRIGHT", button, "BOTTOMRIGHT", size, -size)
            P.Point(mouseoverHighlight, "TOPLEFT", button, "TOPLEFT", -size, size)
            P.Point(mouseoverHighlight, "BOTTOMRIGHT", button, "BOTTOMRIGHT", size, -size)
        end

        -- update thickness
        targetHighlight:SetBackdrop({edgeFile = Cell.vars.whiteTexture, edgeSize = P.Scale(size)})
        mouseoverHighlight:SetBackdrop({edgeFile = Cell.vars.whiteTexture, edgeSize = P.Scale(size)})

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
function B.UpdatePlayerRaidIcon(button, enabled)
    if not button:IsShown() then return end
    UnitButton_UpdatePlayerRaidIcon(button)
    if enabled then
        button:RegisterEvent("RAID_TARGET_UPDATE")
    else
        button:UnregisterEvent("RAID_TARGET_UPDATE")
    end
end

function B.UpdateTargetRaidIcon(button, enabled)
    if not button:IsShown() then return end
    UnitButton_UpdateTargetRaidIcon(button)
    if enabled then
        button:RegisterEvent("UNIT_TARGET")
    else
        button:UnregisterEvent("UNIT_TARGET")
    end
end

-- readyCheckIcon
function B.UpdateReadyCheckIcon(button, enabled)
    if not button:IsShown() then return end
    UnitButton_UpdateReadyCheck(button)
    if enabled then
        button:RegisterEvent("READY_CHECK")
        button:RegisterEvent("READY_CHECK_FINISHED")
        button:RegisterEvent("READY_CHECK_CONFIRM")
    else
        button:UnregisterEvent("READY_CHECK")
        button:UnregisterEvent("READY_CHECK_FINISHED")
        button:UnregisterEvent("READY_CHECK_CONFIRM")
    end
end

-- healthText
function B.UpdateHealthText(button)
    if button.states.displayedUnit then
        UnitButton_UpdateHealthStates(button)
    end
end

-- powerText
function B.UpdatePowerText(button)
    if button.states.displayedUnit then
        UnitButton_UpdatePowerStates(button)
        UnitButton_UpdatePowerText(button)
        UnitButton_UpdatePowerTextColor(button)
    end
end

-- statusText
function B.UpdateStatusText(button)
    UnitButton_UpdateStatusText(button)
end

-- shields
function B.UpdateShield(button)
    UnitButton_UpdateShieldAbsorbs(button)
end

-- animation
function B.UpdateAnimation(button)
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
function B.ShowFlash(button, lostPercent)
    button.widgets.damageFlashTex:SetValue(lostPercent)
    button.widgets.damageFlashAG:Play()
end

function B.HideFlash(button)
    button.widgets.damageFlashAG:Finish()
end

-- backdrop
function B.UpdateBackdrop(button)
    if CELL_BORDER_SIZE == 0 then
        button:SetBackdrop({bgFile = Cell.vars.whiteTexture})
        button:SetBackdropColor(0, 0, 0, CellDB["appearance"]["bgAlpha"])
    else
        button:SetBackdrop({bgFile = Cell.vars.whiteTexture, edgeFile = Cell.vars.whiteTexture, edgeSize = P.Scale(CELL_BORDER_SIZE)})
        button:SetBackdropColor(0, 0, 0, CellDB["appearance"]["bgAlpha"])
        button:SetBackdropBorderColor(unpack(CELL_BORDER_COLOR))
    end
end

-- pixel perfect
function B.UpdatePixelPerfect(button, updateIndicators)
    if not InCombatLockdown() then P.Resize(button) end
    P.Reborder(button)

    P.Repoint(button.widgets.healthBar)
    P.Repoint(button.widgets.healthBarLoss)
    P.Repoint(button.widgets.powerBar)
    P.Repoint(button.widgets.powerBarLoss)
    P.Repoint(button.widgets.gapTexture)
    P.Resize(button.widgets.gapTexture)

    P.Repoint(button.widgets.incomingHeal)
    P.Repoint(button.widgets.shieldBar)
    P.Repoint(button.widgets.absorbsBar)
    P.Repoint(button.widgets.damageFlashTex)

    P.Resize(button.widgets.overShieldGlow)
    P.Repoint(button.widgets.overShieldGlow)
    P.Resize(button.widgets.overAbsorbGlow)
    P.Repoint(button.widgets.overAbsorbGlow)

    B.UpdateHighlightSize(button)
    B.UpdateBackdrop(button)

    if updateIndicators then
        -- indicators
        for _, i in next, button.indicators do
            if i.UpdatePixelPerfect then
                i:UpdatePixelPerfect()
            end
        end
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

-- Layers ---------------------------------------
-- OVERLAY
-- ARTWORK
--  -2 overAbsorbGlow (texture)
--  absorbsBar (StatusBar, frame level midLevel+2)
--  -4 overShieldGlow, overShieldGlowR (texture)
--  shieldBar (StatusBar, frame level midLevel+1), shieldBarR (texture)
--  incomingHeal (StatusBar, frame level healthBar+1)
--	-6 damageFlashTex
--	-7 healthBar, healthBarLoss
-- BORDER
--  0 gapTexture
-- BACKGROUND
-------------------------------------------------

-- NOTE: prevent a nil method error
local DumbFunc = function() end

function CellUnitButton_OnLoad(button)
    local name = button:GetName()

    button.widgets = {}
    button.states = {}
    button.indicators = {}

    -- Health prediction calculator (Patch 12.0.0+)
    if Cell.isMidnight and CreateUnitHealPredictionCalculator then
        button.widgets.healthCalculator = CreateUnitHealPredictionCalculator()
        -- Separate calculator for heal prediction so clamp settings don't
        -- corrupt the shared healthCalculator used by health/absorb reads.
        button.widgets.healPredictionCalculator = CreateUnitHealPredictionCalculator()
    end
    -- Color curve for health bar coloring (Patch 12.0.0+)
    if Cell.isMidnight and C_CurveUtil then
        button.widgets.healthColorCurve = C_CurveUtil.CreateColorCurve()
    end

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
    -- background:SetTexture(Cell.vars.whiteTexture)
    -- background:SetVertexColor(0, 0, 0, 1)

    -- NOTE: SecureUnitButton has no OnActionButtonPressAndHoldRelease
    -- button:SetAttribute("pressAndHoldAction", true)
    -- button:SetAttribute("typerelease", "macro")

    -- backdrop
    -- button:SetBackdrop({bgFile = Cell.vars.whiteTexture, edgeFile = Cell.vars.whiteTexture, edgeSize = P.Scale(CELL_BORDER_SIZE)})
    -- button:SetBackdropColor(0, 0, 0, 1)
    -- button:SetBackdropBorderColor(unpack(CELL_BORDER_COLOR))

    -- healthbar
    local healthBar = CreateFrame("StatusBar", name.."HealthBar", button)
    button.widgets.healthBar = healthBar
    -- P.Point(healthBar, "TOPLEFT", button, "TOPLEFT", 1, -1)
    -- P.Point(healthBar, "BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 4)
    healthBar:SetStatusBarTexture(Cell.vars.texture)
    healthBar:GetStatusBarTexture():SetDrawLayer("ARTWORK", -7)
    healthBar:SetFrameLevel(button:GetFrameLevel()+1)
    healthBar.SetBarValue = healthBar.SetValue

    -- healthBar:SetScript("OnValueChanged", function(self, value)
    --     if value == 0 then
    --         healthBar:SetValue(0.1)
    --     end
    -- end)

    -- hp loss
    local healthBarLoss = button:CreateTexture(name.."HealthBarLoss", "ARTWORK", nil , -7)
    button.widgets.healthBarLoss = healthBarLoss
    -- P.Point(healthBarLoss, "TOPRIGHT", healthBar)
    -- P.Point(healthBarLoss, "BOTTOMLEFT", healthBar:GetStatusBarTexture(), "BOTTOMRIGHT")
    healthBarLoss:SetTexture(Cell.vars.texture)

    -- powerbar
    local powerBar = CreateFrame("StatusBar", name.."PowerBar", button)
    button.widgets.powerBar = powerBar
    -- P.Point(powerBar, "TOPLEFT", healthBar, "BOTTOMLEFT", 0, -1)
    -- P.Point(powerBar, "BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
    powerBar:SetStatusBarTexture(Cell.vars.texture)
    powerBar:GetStatusBarTexture():SetDrawLayer("ARTWORK", -7)
    powerBar:SetFrameLevel(button:GetFrameLevel()+2)
    powerBar.SetBarValue = powerBar.SetValue

    local gapTexture = button:CreateTexture(nil, "BORDER")
    button.widgets.gapTexture = gapTexture
    -- P.Point(gapTexture, "BOTTOMLEFT", powerBar, "TOPLEFT")
    -- P.Point(gapTexture, "BOTTOMRIGHT", powerBar, "TOPRIGHT")
    -- P.Height(gapTexture, 1)
    gapTexture:SetColorTexture(unpack(CELL_BORDER_COLOR))

    -- power loss
    local powerBarLoss = button:CreateTexture(name.."PowerBarLoss", "ARTWORK", nil , -7)
    button.widgets.powerBarLoss = powerBarLoss
    -- P.Point(powerBarLoss, "TOPRIGHT", powerBar)
    -- P.Point(powerBarLoss, "BOTTOMLEFT", powerBar:GetStatusBarTexture(), "BOTTOMRIGHT")
    powerBarLoss:SetTexture(Cell.vars.texture)

    -- incoming heal
    local incomingHeal
    if Cell.isMidnight then
        -- Midnight: StatusBar so native SetMinMaxValues/SetValue work with secret values
        -- Health values are always secret in instances, so we must use calculator-based StatusBar
        incomingHeal = CreateFrame("StatusBar", name.."IncomingHealBar", healthBar)
        incomingHeal:SetStatusBarTexture(Cell.vars.texture)
        incomingHeal:GetStatusBarTexture():SetDrawLayer("ARTWORK", -6)
        incomingHeal:SetFrameLevel(healthBar:GetFrameLevel()+1)
        -- Positioned by SetOrientation (anchored to health fill edge, not SetAllPoints)
        -- Compatibility shims: map Texture methods to StatusBar equivalents
        incomingHeal.SetVertexColor = incomingHeal.SetStatusBarColor
        incomingHeal.SetTexture = incomingHeal.SetStatusBarTexture
    else
        -- Pre-Midnight: Texture with manual width/height positioning
        incomingHeal = healthBar:CreateTexture(name.."IncomingHealBar", "ARTWORK", nil, -3)
        incomingHeal:SetTexture(Cell.vars.texture)
        incomingHeal.SetValue = DumbFunc
    end
    button.widgets.incomingHeal = incomingHeal
    incomingHeal:Hide()

    --* indicatorFrame
    local indicatorFrame = CreateFrame("Frame", name.."IndicatorFrame", button)
    button.widgets.indicatorFrame = indicatorFrame
    indicatorFrame:SetFrameLevel(button:GetFrameLevel()+220)
    indicatorFrame:SetAllPoints(button)

    --* tsGlowFrame (Targeted Spells)
    local tsGlowFrame = CreateFrame("Frame", name.."TSGlowFrame", button)
    button.widgets.tsGlowFrame = tsGlowFrame
    tsGlowFrame:SetFrameLevel(button:GetFrameLevel()+200)
    tsGlowFrame:SetAllPoints(button)

    --* srGlowFrame (Spell Request)
    local srGlowFrame = CreateFrame("Frame", name.."SRGlowFrame", button)
    button.widgets.srGlowFrame = srGlowFrame
    srGlowFrame:SetFrameLevel(button:GetFrameLevel()+200)
    srGlowFrame:SetAllPoints(button)

    --* drGlowFrame (Dispel Request)
    local drGlowFrame = CreateFrame("Frame", name.."DRGlowFrame", button)
    button.widgets.drGlowFrame = drGlowFrame
    drGlowFrame:SetFrameLevel(button:GetFrameLevel()+200)
    drGlowFrame:SetAllPoints(button)

    --* highLevelFrame
    local highLevelFrame = CreateFrame("Frame", name.."HighLevelFrame", button)
    button.widgets.highLevelFrame = highLevelFrame
    highLevelFrame:SetFrameLevel(button:GetFrameLevel()+140)
    highLevelFrame:SetAllPoints(button)

    --* midLevelFrame
    local midLevelFrame = CreateFrame("Frame", name.."MidLevelFrame", button)
    button.widgets.midLevelFrame = midLevelFrame
    midLevelFrame:SetFrameLevel(button:GetFrameLevel()+120)
    midLevelFrame:SetAllPoints(healthBar)

    -- shield bar
    local shieldBar
    if Cell.isMidnight then
        -- Midnight: StatusBar so native SetMinMaxValues/SetValue work with secret values
        shieldBar = CreateFrame("StatusBar", name.."ShieldBar", midLevelFrame)
        shieldBar:SetStatusBarTexture("Interface\\AddOns\\Cell\\Media\\shield")
        shieldBar:GetStatusBarTexture():SetDrawLayer("ARTWORK", -5)
        shieldBar:SetFrameLevel(midLevelFrame:GetFrameLevel()+1)
        shieldBar:SetAllPoints(healthBar)
        -- Compatibility shims: map Texture methods to StatusBar equivalents
        shieldBar.SetVertexColor = shieldBar.SetStatusBarColor
        shieldBar.SetTexture = shieldBar.SetStatusBarTexture
    else
        -- Pre-Midnight: Texture with manual width/height positioning
        shieldBar = midLevelFrame:CreateTexture(name.."ShieldBar", "ARTWORK", nil, -5)
        shieldBar:SetTexture("Interface\\AddOns\\Cell\\Media\\shield", "REPEAT", "REPEAT")
        shieldBar:SetHorizTile(true)
        shieldBar:SetVertTile(true)
        shieldBar.SetValue = DumbFunc
    end
    button.widgets.shieldBar = shieldBar
    shieldBar:Hide()

    local shieldBarR
    if Cell.isMidnight then
        -- Midnight: StatusBar for reverse-fill shield display with secret values
        shieldBarR = CreateFrame("StatusBar", name.."ShieldBarR", midLevelFrame)
        shieldBarR:SetStatusBarTexture("Interface\\AddOns\\Cell\\Media\\shield")
        shieldBarR:GetStatusBarTexture():SetDrawLayer("ARTWORK", -5)
        shieldBarR:SetFrameLevel(midLevelFrame:GetFrameLevel()+1)
        shieldBarR:SetAllPoints(healthBar)
        shieldBarR:SetReverseFill(true)
        -- Compatibility shims: map Texture methods to StatusBar equivalents
        shieldBarR.SetVertexColor = shieldBarR.SetStatusBarColor
        shieldBarR.SetTexture = shieldBarR.SetStatusBarTexture
    else
        -- Pre-Midnight: Texture with manual width/height positioning
        shieldBarR = midLevelFrame:CreateTexture(name.."ShieldBarR", "ARTWORK", nil, -5)
        shieldBarR:SetTexture("Interface\\AddOns\\Cell\\Media\\shield", "REPEAT", "REPEAT")
        shieldBarR:SetHorizTile(true)
        shieldBarR:SetVertTile(true)
    end
    button.widgets.shieldBarR = shieldBarR
    shieldBarR:Hide()
    shieldBar.shieldBarR = shieldBarR

    -- over-shield glow
    local overShieldGlow = midLevelFrame:CreateTexture(name.."OverShieldGlow", "ARTWORK", nil, -4)
    button.widgets.overShieldGlow = overShieldGlow
    overShieldGlow:SetTexture("Interface\\AddOns\\Cell\\Media\\overshield")
    -- overShieldGlow:SetBlendMode("ADD")
    overShieldGlow:Hide()
    shieldBar.overShieldGlow = overShieldGlow

    -- over-shield glow reversed
    local overShieldGlowR = midLevelFrame:CreateTexture(name.."OverShieldGlowR", "ARTWORK", nil, -4)
    button.widgets.overShieldGlowR = overShieldGlowR
    overShieldGlowR:SetTexture("Interface\\AddOns\\Cell\\Media\\overshield_reversed")
    -- overShieldGlowR:SetBlendMode("ADD")
    overShieldGlowR:Hide()
    shieldBar.overShieldGlowR = overShieldGlowR

    -- over-absorb glow
    local overAbsorbGlow = midLevelFrame:CreateTexture(name.."OverAbsorbGlow", "ARTWORK", nil, -2)
    button.widgets.overAbsorbGlow = overAbsorbGlow
    overAbsorbGlow:SetTexture("Interface\\AddOns\\Cell\\Media\\overabsorb")
    -- overAbsorbGlow:SetBlendMode("ADD")
    overAbsorbGlow:Hide()

    -- absorbs bar
    local absorbsBar
    if Cell.isMidnight then
        -- Midnight: StatusBar so native SetMinMaxValues/SetValue work with secret values
        absorbsBar = CreateFrame("StatusBar", name.."AbsorbsBar", midLevelFrame)
        absorbsBar:SetStatusBarTexture("Interface\\AddOns\\Cell\\Media\\shield.tga")
        absorbsBar:GetStatusBarTexture():SetDrawLayer("ARTWORK", 1)
        absorbsBar:SetStatusBarColor(1, 0.1, 0.1, 1)
        absorbsBar:SetFrameLevel(midLevelFrame:GetFrameLevel()+2)
        absorbsBar:SetAllPoints(healthBar)
        absorbsBar:SetReverseFill(true)
        -- Compatibility shims: map Texture methods to StatusBar equivalents
        absorbsBar.SetVertexColor = absorbsBar.SetStatusBarColor
        absorbsBar.SetTexture = absorbsBar.SetStatusBarTexture
    else
        -- Pre-Midnight: Texture with manual width/height positioning
        absorbsBar = midLevelFrame:CreateTexture(name.."AbsorbsBar", "ARTWORK", nil, 1)
        absorbsBar:SetTexture("Interface\\AddOns\\Cell\\Media\\shield.tga", "REPEAT", "REPEAT")
        absorbsBar:SetHorizTile(true)
        absorbsBar:SetVertTile(true)
        absorbsBar:SetVertexColor(1, 0.1, 0.1, 1)
        absorbsBar.SetValue = DumbFunc
    end
    button.widgets.absorbsBar = absorbsBar
    absorbsBar.healthBar = healthBar
    -- absorbsBar:SetBlendMode("ADD")
    absorbsBar:Hide()
    absorbsBar.overAbsorbGlow = overAbsorbGlow

    -- Midnight: Overlay StatusBars need initial min/max for SetValue to work before UpdateHealthMax fires
    if Cell.isMidnight then
        if button.widgets.incomingHeal then
            button.widgets.incomingHeal:SetMinMaxValues(0, 1)
        end
        if button.widgets.shieldBar then
            button.widgets.shieldBar:SetMinMaxValues(0, 1)
        end
        if button.widgets.shieldBarR then
            button.widgets.shieldBarR:SetMinMaxValues(0, 1)
        end
        if button.widgets.absorbsBar then
            button.widgets.absorbsBar:SetMinMaxValues(0, 1)
        end
    end

    -- bar animation
    -- flash
    local damageFlashTex = healthBar:CreateTexture(name.."DamageFlash", "ARTWORK", nil, -6)
    button.widgets.damageFlashTex = damageFlashTex
    damageFlashTex:SetTexture(Cell.vars.whiteTexture)
    damageFlashTex:SetVertexColor(1, 1, 1, 0.7)
    -- P.Point(damageFlashTex, "TOPLEFT", healthBar:GetStatusBarTexture(), "TOPRIGHT")
    -- P.Point(damageFlashTex, "BOTTOMLEFT", healthBar:GetStatusBarTexture(), "BOTTOMRIGHT")
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
    targetHighlight:SetFrameLevel(button:GetFrameLevel()+3)
    -- targetHighlight:SetBackdrop({edgeFile = Cell.vars.whiteTexture, edgeSize = P.Scale(1)})
    -- P.Point(targetHighlight, "TOPLEFT", button, "TOPLEFT", -1, 1)
    -- P.Point(targetHighlight, "BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, -1)
    targetHighlight:Hide()

    -- mouseover highlight
    local mouseoverHighlight = CreateFrame("Frame", name.."MouseoverHighlight", button, "BackdropTemplate")
    button.widgets.mouseoverHighlight = mouseoverHighlight
    mouseoverHighlight:SetIgnoreParentAlpha(true)
    mouseoverHighlight:SetFrameLevel(button:GetFrameLevel()+4)
    -- mouseoverHighlight:SetBackdrop({edgeFile = Cell.vars.whiteTexture, edgeSize = P.Scale(1)})
    -- P.Point(mouseoverHighlight, "TOPLEFT", button, "TOPLEFT", -1, 1)
    -- P.Point(mouseoverHighlight, "BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, -1)
    mouseoverHighlight:Hide()

    -- readyCheck highlight
    -- local readyCheckHighlight = button:CreateTexture(name.."ReadyCheckHighlight", "BACKGROUND")
    -- button.widgets.readyCheckHighlight = readyCheckHighlight
    -- readyCheckHighlight:SetPoint("TOPLEFT", -1, 1)
    -- readyCheckHighlight:SetPoint("BOTTOMRIGHT", 1, -1)
    -- readyCheckHighlight:SetTexture(Cell.vars.whiteTexture)
    -- readyCheckHighlight:Hide()

    -- aggro bar
    local aggroBar = Cell.CreateStatusBar(name.."AggroBar", indicatorFrame, 20, 4, 100, true)
    button.indicators.aggroBar = aggroBar
    aggroBar:Hide()

    -- indicators
    I.CreateNameText(button)
    I.CreateStatusText(button)
    I.CreateHealthText(button)
    I.CreatePowerText(button)
    I.CreateStatusIcon(button)
    I.CreateRoleIcon(button)
    I.CreateLeaderIcon(button)
    I.CreateCombatIcon(button)
    I.CreateReadyCheckIcon(button)
    I.CreateAggroBlink(button)
    I.CreateAggroBorder(button)
    I.CreatePlayerRaidIcon(button)
    I.CreateTargetRaidIcon(button)
    I.CreateShieldBar(button)
    I.CreateAoEHealing(button)
    I.CreateTankActiveMitigation(button)
    -- I.CreateDefensiveCooldowns(button)
    -- I.CreateExternalCooldowns(button)
    -- I.CreateAllCooldowns(button)
    -- I.CreateDebuffs(button)
    I.CreateDispels(button)
    I.CreateRaidDebuffs(button)
    I.CreatePrivateAuras(button)
    I.CreateTargetedSpells(button)
    I.CreateTargetCounter(button)
    I.CreateCrowdControls(button)
    I.CreateActions(button)
    I.CreateMissingBuffs(button)
    I.CreateHealthThresholds(button)
    U.CreateSpellRequestIcon(button)
    U.CreateDispelRequestText(button)

    button._waitingForIndicatorCreation = true

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
