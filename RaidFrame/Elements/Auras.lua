local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

local DebuffTypeColor = DebuffTypeColor
-------------------------------------------------
-- icon builder
-------------------------------------------------
local function CreateAura_BorderIcon(name, parent, borderSize)
    local frame = CreateFrame("Frame", name, parent)
    frame:Hide()
    frame:SetSize(11, 11)
    frame:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
    frame:SetBackdropColor(0, 0, 0, .7)
    
    local border = CreateFrame("Frame", name.."Border", frame)
    frame.border = border
    border:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
    border:SetAllPoints(frame)
    border:Hide()

    local cooldown = CreateFrame("Cooldown", name.."Cooldown", frame)
    frame.cooldown = cooldown
    cooldown:SetAllPoints(frame)
    cooldown:SetSwipeTexture("")
    cooldown:SetSwipeColor(1, 1, 1)
    cooldown.noCooldownCount = true -- disable omnicc

    local iconFrame = CreateFrame("Frame", name.."IconFrame", frame)
    iconFrame:SetPoint("TOPLEFT", borderSize, -borderSize)
    iconFrame:SetPoint("BOTTOMRIGHT", -borderSize, borderSize)

    local icon = iconFrame:CreateTexture(name.."Icon", "ARTWORK")
    frame.icon = icon
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    icon:SetAllPoints(iconFrame)

    function frame:SetCooldown(start, duration, debuffType, texture)
        local r, g, b = DebuffTypeColor[debuffType].r, DebuffTypeColor[debuffType].g, DebuffTypeColor[debuffType].b
        if duration == 0 then
            border:Show()
            border:SetBackdropColor(r, g, b)
        else
            border:Hide()
            cooldown:SetSwipeTexture("")
            cooldown:SetSwipeColor(r, g, b)
            cooldown:SetCooldown(start, duration)
        end
        icon:SetTexture(texture)
    end

    return frame
end

-- local LSSB = LibStub:GetLibrary("LibSmoothStatusBar-1.0")
local function CreateAura_BarIcon(name, parent)
    local frame = CreateFrame("Frame", name, parent)
    frame:Hide()
    frame:SetSize(11, 11)
    frame:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
    frame:SetBackdropColor(0, 0, 0, 1)

    local icon = frame:CreateTexture(name.."Icon", "ARTWORK")
    frame.icon = icon
    icon:SetTexCoord(.12, .88, .12, .88)
    icon:SetPoint("TOPLEFT", 1, -1)
    icon:SetPoint("BOTTOMRIGHT", -1, 1)
    -- icon:SetDrawLayer("ARTWORK", 1)

    local cooldown = CreateFrame("StatusBar", name.."CooldownBar", frame)
    frame.cooldown = cooldown
    cooldown:SetPoint("TOPLEFT", 1, -1)
    cooldown:SetPoint("BOTTOMRIGHT", -1, 1)
    cooldown:SetOrientation("VERTICAL")
    cooldown:SetReverseFill(true)
    -- cooldown:SetFillStyle("REVERSE")
    cooldown:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    cooldown:GetStatusBarTexture():SetAlpha(0)

    local elapsedTime = 0
    cooldown:SetScript("OnUpdate", function(self, elapsed)
        -- cooldown:SetValue(GetTime()-cooldown.start)
        if elapsedTime >= 0.1 then
            cooldown:SetValue(cooldown:GetValue() + elapsedTime)
            elapsedTime = 0
        end
        elapsedTime = elapsedTime + elapsed
    end)

    local spark = cooldown:CreateTexture(nil, "OVERLAY")
    spark:SetHeight(1)
    spark:SetBlendMode("ADD")
    spark:SetPoint("TOPLEFT", cooldown:GetStatusBarTexture(), "BOTTOMLEFT")
    spark:SetPoint("TOPRIGHT", cooldown:GetStatusBarTexture(), "BOTTOMRIGHT")
    
    local mask = frame:CreateMaskTexture()
    mask:SetTexture("Interface\\Buttons\\WHITE8x8", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetPoint("TOPLEFT")
    mask:SetPoint("BOTTOMRIGHT", cooldown:GetStatusBarTexture())

    local maskIcon = cooldown:CreateTexture(name.."MaskIcon", "ARTWORK")
    maskIcon:SetTexCoord(.12, .88, .12, .88)
    maskIcon:SetDesaturated(true)
    maskIcon:SetAllPoints(icon)
    -- maskIcon:SetDrawLayer("ARTWORK", 0)
    maskIcon:SetVertexColor(.4, .4, .4, 1)
    maskIcon:AddMaskTexture(mask)

    frame:SetScript("OnSizeChanged", function(self, width, height)
        -- keep aspect ratio
        icon:SetTexCoord(unpack(F:GetTexCoord(width, height)))
        maskIcon:SetTexCoord(unpack(F:GetTexCoord(width, height)))
    end)

    local stack = cooldown:CreateFontString(nil, "OVERLAY", "CELL_FONT_STATUS")
    frame.stack = stack
    stack:SetJustifyH("RIGHT")
    -- stack:SetJustifyV("TOP")
    stack:SetPoint("TOPRIGHT", frame, 1, 0)
    -- stack:SetPoint("CENTER", 1, 0)

    function frame:SetFont(font, size, flags, horizontalOffset)
        if flags == "Shadow" then
            frame.stack:SetFont(font, size)
            frame.stack:SetShadowColor(0, 0, 0, 1)
        else
            if flags == "Outline" then
                flags = "OUTLINE"
            else
                flags = "OUTLINE, MONOCHROME"
            end
            frame.stack:SetFont(font, size, flags)
            frame.stack:SetShadowColor(0, 0, 0, 0)
        end
        frame.stack:ClearAllPoints()
        frame.stack:SetPoint("TOPRIGHT", frame, horizontalOffset, 0)
    end

    local ag = frame:CreateAnimationGroup()
    local t1 = ag:CreateAnimation("Translation")
    t1:SetOffset(0, 5)
    t1:SetDuration(0.1)
    t1:SetOrder(1)
    t1:SetSmoothing("OUT")
    local t2 = ag:CreateAnimation("Translation")
    t2:SetOffset(0, -5)
    t2:SetDuration(0.1)
    t2:SetOrder(2)
    t2:SetSmoothing("IN")

    function frame:SetCooldown(start, duration, debuffType, texture, count, refreshing)
        if duration == 0 then
            cooldown:Hide()
        else
            -- init bar values
            cooldown:SetMinMaxValues(0, duration)
            cooldown:SetValue(GetTime()-start)
            cooldown:Show()
        end

        local r, g, b
        if debuffType then
            r, g, b = DebuffTypeColor[debuffType].r, DebuffTypeColor[debuffType].g, DebuffTypeColor[debuffType].b
            spark:SetColorTexture(r, g, b, 1)
        else
            r, g, b = 0, 0, 0
            spark:SetColorTexture(.5, .5, .5, 1)
        end

        frame:SetBackdropColor(r, g, b, 1)
        icon:SetTexture(texture)
        maskIcon:SetTexture(texture)
        stack:SetText((count == 0 or count == 1) and "" or count)
        frame:Show()

        if refreshing then
            ag:Play()
        end
    end

    return frame
end

-------------------------------------------------
-- CreateAoEHealing
-------------------------------------------------
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function()
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName = CombatLogGetCurrentEventInfo()
    if (subevent == "SPELL_HEAL" or subevent == "SPELL_PERIODIC_HEAL") and F:IsAoEHealing(spellName) and sourceGUID == Cell.vars.playerGUID then
        if Cell.vars.groupType and Cell.vars.guid[destGUID] then
            Cell.unitButtons[Cell.vars.groupType][Cell.vars.guid[destGUID]].indicators.aoeHealing:ShowUp()
        end
    end
end)

function F:CreateAoEHealing(parent)
    local aoeHealing = CreateFrame("Frame", nil, parent)
	parent.indicators.aoeHealing = aoeHealing
	aoeHealing:SetPoint("TOPLEFT", parent.widget.healthBar)
    aoeHealing:SetPoint("TOPRIGHT", parent.widget.healthBar)
    aoeHealing:SetFrameLevel(5)
    -- aoeHealing:SetHeight(15)
	aoeHealing:Hide()

	aoeHealing.tex = aoeHealing:CreateTexture(nil, "ARTWORK")
    aoeHealing.tex:SetAllPoints(aoeHealing)
	aoeHealing.tex:SetTexture("Interface\\Buttons\\WHITE8x8")
    
    local ag = aoeHealing:CreateAnimationGroup()
    local a1 = ag:CreateAnimation("Alpha")
    a1:SetFromAlpha(0)
    a1:SetToAlpha(1)
    a1:SetDuration(0.5)
    a1:SetOrder(1)
    a1:SetSmoothing("OUT")
    local a2 = ag:CreateAnimation("Alpha")
    a2:SetFromAlpha(1)
    a2:SetToAlpha(0)
    a2:SetDuration(0.5)
    a2:SetOrder(2)
    a2:SetSmoothing("IN")

    ag:SetScript("OnPlay", function()
        aoeHealing:Show()
    end)
    ag:SetScript("OnFinished", function()
        aoeHealing:Hide()
    end)

	function aoeHealing:SetColor(r, g, b)
		aoeHealing.tex:SetGradientAlpha("VERTICAL", r, g, b, 0, r, g, b, .77)
    end

    function aoeHealing:ShowUp()
        -- if ag:IsPlaying() then
        --     ag:Restart()
        -- else
            ag:Play()
        -- end
    end
end

function F:EnableAoEHealing(enabled)
    if enabled then
        eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    else
        eventFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end
end

-------------------------------------------------
-- CreateDefensiveCooldowns
-------------------------------------------------
function F:CreateDefensiveCooldowns(parent)
    local defensiveCooldowns = CreateFrame("Frame", parent:GetName().."ExternalCooldownParent", parent.widget.overlayFrame)
    parent.indicators.defensiveCooldowns = defensiveCooldowns
    defensiveCooldowns:SetSize(20, 10)
    defensiveCooldowns:SetFrameLevel(11)
    defensiveCooldowns:Hide()

    defensiveCooldowns.OriginalSetSize = defensiveCooldowns.SetSize

    function defensiveCooldowns:SetSize(width, height)
        defensiveCooldowns:OriginalSetSize(width, height)
        for i = 1, 5 do
            defensiveCooldowns[i]:SetSize(width, height)
        end
    end

    function defensiveCooldowns:SetFont(font, ...)
        font = F:GetFont(font)
        for i = 1, 5 do
            defensiveCooldowns[i]:SetFont(font, ...)
        end
    end

    for i = 1, 5 do
        local name = parent:GetName().."DefensiveCooldown"..i
        local frame = CreateAura_BarIcon(name, defensiveCooldowns)
        tinsert(defensiveCooldowns, frame)

        if i == 1 then
            frame:SetPoint("TOPLEFT")
        else
            frame:SetPoint("LEFT", defensiveCooldowns[i-1], "RIGHT", -1, 0)
        end
	end
end

-------------------------------------------------
-- CreateExternalCooldowns
-------------------------------------------------
function F:CreateExternalCooldowns(parent)
    local externalCooldowns = CreateFrame("Frame", parent:GetName().."ExternalCooldownParent", parent.widget.overlayFrame)
    parent.indicators.externalCooldowns = externalCooldowns
    externalCooldowns:SetSize(20, 10)
    externalCooldowns:SetFrameLevel(11)
    externalCooldowns:Hide()

    externalCooldowns.OriginalSetSize = externalCooldowns.SetSize

    function externalCooldowns:SetSize(width, height)
        externalCooldowns:OriginalSetSize(width, height)
        for i = 1, 5 do
            externalCooldowns[i]:SetSize(width, height)
        end
    end

    function externalCooldowns:SetFont(font, ...)
        font = F:GetFont(font)
        for i = 1, 5 do
            externalCooldowns[i]:SetFont(font, ...)
        end
    end

    for i = 1, 5 do
        local name = parent:GetName().."ExternalCooldown"..i
        local frame = CreateAura_BarIcon(name, externalCooldowns)
        tinsert(externalCooldowns, frame)

        if i == 1 then
            frame:SetPoint("TOPLEFT")
        else
            frame:SetPoint("RIGHT", externalCooldowns[i-1], "LEFT", 1, 0)
        end
	end
end

-------------------------------------------------
-- CreateTankActiveMitigation
-------------------------------------------------
function F:CreateTankActiveMitigation(parent)
    local bar = Cell:CreateStatusBar(parent.widget.overlayFrame, 18, 4, 100)
    parent.indicators.tankActiveMitigation = bar
    bar:Hide()
    
    bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    bar:GetStatusBarTexture():SetAlpha(0)
    bar:SetReverseFill(true)

    local tex = bar:CreateTexture(nil, "ARTWORK")
    tex:SetColorTexture(.7, .7, .7)
    tex:SetPoint("TOPLEFT")
    tex:SetPoint("BOTTOMRIGHT", bar:GetStatusBarTexture(), "BOTTOMLEFT")

    local elapsedTime = 0
    bar:SetScript("OnUpdate", function(self, elapsed)
        if elapsedTime >= 0.1 then
            bar:SetValue(bar:GetValue() + elapsedTime)
            elapsedTime = 0
        end
        elapsedTime = elapsedTime + elapsed
    end)

    function bar:SetCooldown(start, duration)
        bar:SetMinMaxValues(0, duration)
        bar:SetValue(GetTime()-start)
        bar:Show()
    end
end

-------------------------------------------------
-- CreateDebuffs
-------------------------------------------------
function F:CreateDebuffs(parent)
    local debuffs = CreateFrame("Frame", parent:GetName().."DebuffParent", parent.widget.overlayFrame)
    parent.indicators.debuffs = debuffs
    debuffs:SetSize(11, 11)
    debuffs:Hide()

    debuffs.OriginalSetSize = debuffs.SetSize

    function debuffs:SetSize(width, height)
        debuffs:OriginalSetSize(width, height)
        for i = 1, 5 do
            debuffs[i]:SetSize(width, height)
        end
    end

    function debuffs:SetFont(font, ...)
        font = F:GetFont(font)
        for i = 1, 5 do
            debuffs[i]:SetFont(font, ...)
        end
    end

    for i = 1, 5 do
        local name = parent:GetName().."Debuff"..i
        local frame = CreateAura_BarIcon(name, debuffs)
        tinsert(debuffs, frame)

        if i == 1 then
            frame:SetPoint("TOPLEFT")
        else
            frame:SetPoint("LEFT", debuffs[i-1], "RIGHT")
        end
	end
end

-------------------------------------------------
-- CreateDispels
-------------------------------------------------
function F:CreateDispels(parent)
    local dispels = CreateFrame("Frame", parent:GetName().."DispelParent", parent.widget.overlayFrame)
    parent.indicators.dispels = dispels
    dispels:SetFrameLevel(77)
    dispels:Hide()

    dispels.OriginalSetSize = dispels.SetSize

    function dispels:SetSize(width, height)
        dispels:OriginalSetSize(width, height)
        for i = 1, 4 do
            dispels[i]:SetSize(width, height)
        end
    end

    function dispels:SetDispels(dispelTypes)
        local i = 1
        for dispelType, _ in pairs(dispelTypes) do
            dispels[i]:SetDispel(dispelType)
            i = i + 1
        end
        -- hide unused
        for j = i, 4 do
            dispels[i]:Hide()
        end
    end

    for i = 1, 4 do
        local icon = dispels:CreateTexture(parent:GetName().."Dispel"..i, "ARTWORK")
        tinsert(dispels, icon)
        icon:Hide()

        if i == 1 then
            icon:SetPoint("TOPLEFT")
        else
            icon:SetPoint("RIGHT", dispels[i-1], "LEFT", 7, 0)
        end

        icon:SetTexCoord(.15, .85, .15, .85)
        icon:SetDrawLayer("ARTWORK", i)

        function icon:SetDispel(dispelType)
            icon:SetTexture("Interface\\RaidFrame\\Raid-Icon-Debuff"..dispelType)
            icon:Show()
        end
    end
end

-------------------------------------------------
-- CreateCentralDebuff
-------------------------------------------------
function F:CreateCentralDebuff(parent)
    local frame = CreateAura_BorderIcon(parent:GetName().."CentralDebuff", parent.widget.overlayFrame, 2)
    parent.indicators.centralDebuff = frame
    frame:SetFrameLevel(77)
end

-------------------------------------------------
-- custom indicators
-------------------------------------------------
local enabledIndicators = {}
local customIndicators = {
    ["buff"] = {},
    ["debuff"] = {},
}

function F:CreateIndicator(parent, indicatorTable)
    local indicator
    if indicatorTable["type"] == "icon" then
        indicator = CreateAura_BarIcon(indicatorTable["indicatorName"], parent.widget.overlayFrame)
    end
    parent.indicators[indicatorTable["indicatorName"]] = indicator
    
    -- keep custom indicators in table
    if indicatorTable["enabled"] then enabledIndicators[indicatorTable["indicatorName"]] = true end

    local auraType = indicatorTable["auraType"]
    customIndicators[auraType][indicatorTable["indicatorName"]] = {
        ["found"] = {}, -- found cache
        ["auras"] = F:ConvertTable(indicatorTable["auras"]), -- auras to match
    }

    return indicator
end

function F:RemoveIndicator(parent, indicatorName, auraType)
    local indicator = parent.indicators[indicatorName]
    indicator:ClearAllPoints()
    indicator:Hide()
    indicator:SetParent(nil)
    parent.indicators[indicatorName] = nil
    enabledIndicators[indicatorName] = nil
    customIndicators[auraType][indicatorName] = nil
end

local function UpdateCustomIndicators(indicatorName, setting, value)
    if not indicatorName or not string.find(indicatorName, "indicator") then return end

    if setting == "enabled" then
        if value then
            enabledIndicators[indicatorName] = true
        else
            enabledIndicators[indicatorName] = nil
        end
    elseif setting == "auras" then
        customIndicators[value[1]][indicatorName]["auras"] = F:ConvertTable(value[2])
    end
end
Cell:RegisterCallback("UpdateIndicators", "UpdateCustomIndicators", UpdateCustomIndicators)

function F:ShowCustomIndicators(unitButton, auraType, auraName, start, duration, debuffType, texture, count, refreshing)
    for indicatorName, indicatorTable in pairs(customIndicators[auraType]) do
        if enabledIndicators[indicatorName] then
            if indicatorTable["auras"][auraName] then
                unitButton.indicators[indicatorName]:SetCooldown(start, duration, debuffType, texture, count, refreshing)
                -- update cache
                customIndicators[auraType][indicatorName]["found"][auraName] = true
            end
        end
    end
end

function F:HideCustomIndicators(unitButton, auraType, auraName)
    for indicatorName, indicatorTable in pairs(customIndicators[auraType]) do
        if enabledIndicators[indicatorName] then
            if indicatorTable["auras"][auraName] then
                -- update cache
                customIndicators[auraType][indicatorName]["found"][auraName] = nil
                if F:Getn(customIndicators[auraType][indicatorName]["found"]) == 0 then
                    unitButton.indicators[indicatorName]:Hide()
                end
            end
        else
            wipe(customIndicators[auraType][indicatorName]["found"])
            unitButton.indicators[indicatorName]:Hide()
        end
    end
end