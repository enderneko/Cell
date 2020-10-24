local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

local DebuffTypeColor = DebuffTypeColor
-------------------------------------------------
-- icon builder
-------------------------------------------------
local function CreateAura_BorderIcon(name, parent, borderSize)
    local frame = CreateFrame("Frame", name, parent, "BackdropTemplate")
    frame:Hide()
    frame:SetSize(11, 11)
    frame:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
    frame:SetBackdropColor(0, 0, 0, .7)
    
    local border = CreateFrame("Frame", name.."Border", frame, "BackdropTemplate")
    frame.border = border
    border:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
    border:SetAllPoints(frame)
    border:Hide()

    local cooldown = CreateFrame("Cooldown", name.."Cooldown", frame)
    frame.cooldown = cooldown
    cooldown:SetAllPoints(frame)
    cooldown:SetSwipeTexture("Interface\\Buttons\\WHITE8x8")
    cooldown:SetSwipeColor(1, 1, 1)
    cooldown.noCooldownCount = true -- disable omnicc

    local iconFrame = CreateFrame("Frame", name.."IconFrame", cooldown)
    iconFrame:SetPoint("TOPLEFT", borderSize, -borderSize)
    iconFrame:SetPoint("BOTTOMRIGHT", -borderSize, borderSize)

    local icon = iconFrame:CreateTexture(name.."Icon", "ARTWORK")
    frame.icon = icon
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    icon:SetAllPoints(iconFrame)

    local textFrame = CreateFrame("Frame", nil, iconFrame)
    textFrame:SetAllPoints(frame)

    local stack = textFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_STATUS")
    frame.stack = stack
    stack:SetJustifyH("RIGHT")
    stack:SetPoint("TOPRIGHT", 2, 1)

    local duration = textFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_STATUS")
    frame.duration = duration
    duration:SetJustifyH("RIGHT")
    duration:SetPoint("BOTTOMRIGHT", 2, -1)

    function frame:SetFont(font, size, flags, horizontalOffset)
        if not string.find(font, ".ttf") then font = F:GetFont(font) end

        if flags == "Shadow" then
            frame.stack:SetFont(font, size)
            frame.stack:SetShadowOffset(1, -1)
            frame.stack:SetShadowColor(0, 0, 0, 1)
            frame.duration:SetFont(font, size)
            frame.duration:SetShadowOffset(1, -1)
            frame.duration:SetShadowColor(0, 0, 0, 1)
        else
            if flags == "Outline" then
                flags = "OUTLINE"
            else
                flags = "OUTLINE, MONOCHROME"
            end
            frame.stack:SetFont(font, size, flags)
            frame.stack:SetShadowOffset(0, 0)
            frame.stack:SetShadowColor(0, 0, 0, 0)
            frame.duration:SetFont(font, size, flags)
            frame.duration:SetShadowOffset(0, 0)
            frame.duration:SetShadowColor(0, 0, 0, 0)
        end
        frame.stack:ClearAllPoints()
        frame.stack:SetPoint("TOPRIGHT", horizontalOffset, 1)
        frame.duration:ClearAllPoints()
        frame.duration:SetPoint("BOTTOMRIGHT", horizontalOffset, -1)
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
        local r, g, b
        if debuffType then
            r, g, b = DebuffTypeColor[debuffType].r, DebuffTypeColor[debuffType].g, DebuffTypeColor[debuffType].b
        else
            r, g, b = 0, 0, 0
        end

        if duration == 0 then
            border:Show()
            border:SetBackdropColor(r, g, b)
            frame:SetScript("OnUpdate", nil)
        else
            border:Hide()
            cooldown:SetSwipeColor(r, g, b)
            cooldown:SetCooldown(start, duration)
            frame:SetScript("OnUpdate", function()
                local remain = duration-(GetTime()-start)
                -- if remain <= 5 then
                --     frame.duration:SetText(string.format("%.1f", remain))
                if remain <= 30 then
                    frame.duration:SetText(string.format("%d", remain))
                else
                    frame.duration:SetText("")
                end
            end)
        end

        icon:SetTexture(texture)
        stack:SetText((count == 0 or count == 1) and "" or count)
        frame:Show()

        if refreshing then
            ag:Play()
        end
    end

    return frame
end

-- local LSSB = LibStub:GetLibrary("LibSmoothStatusBar-1.0")
local function CreateAura_BarIcon(name, parent)
    local frame = CreateFrame("Frame", name, parent, "BackdropTemplate")
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

    local stackFrame = CreateFrame("Frame", nil, frame)
    stackFrame:SetAllPoints(frame)

    local stack = stackFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_STATUS")
    frame.stack = stack
    stack:SetJustifyH("RIGHT")
    -- stack:SetJustifyV("TOP")
    stack:SetPoint("TOPRIGHT", 2, 0)
    -- stack:SetPoint("CENTER", 1, 0)

    function frame:SetFont(font, size, flags, horizontalOffset)
        if not string.find(font, ".ttf") then font = F:GetFont(font) end

        if flags == "Shadow" then
            frame.stack:SetFont(font, size)
            frame.stack:SetShadowOffset(1, -1)
            frame.stack:SetShadowColor(0, 0, 0, 1)
        else
            if flags == "Outline" then
                flags = "OUTLINE"
            else
                flags = "OUTLINE, MONOCHROME"
            end
            frame.stack:SetFont(font, size, flags)
            frame.stack:SetShadowOffset(0, 0)
            frame.stack:SetShadowColor(0, 0, 0, 0)
        end
        frame.stack:ClearAllPoints()
        frame.stack:SetPoint("TOPRIGHT", horizontalOffset, 0)
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
-- CreateAoEHealing -- not support for npc
-------------------------------------------------
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function()
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName = CombatLogGetCurrentEventInfo()
    if (subevent == "SPELL_HEAL" or subevent == "SPELL_PERIODIC_HEAL") and sourceGUID == Cell.vars.playerGUID and destGUID and F:IsAoEHealing(spellName) then
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
local currentAreaDebuffs = {}
local eventFrame2 = CreateFrame("Frame")
eventFrame2:RegisterEvent("PLAYER_ENTERING_WORLD")

local function UpdateDebuffsForCurrentZone()
    local iName = F:GetInstanceName()
    if iName ~= "" then
        currentAreaDebuffs = F:GetDebuffList(iName)
    end
end
Cell:RegisterCallback("RaidDebuffsChanged", "UpdateDebuffsForCurrentZone", UpdateDebuffsForCurrentZone)
eventFrame2:SetScript("OnEvent", UpdateDebuffsForCurrentZone)

function F:GetDebuffOrder(spellId)
    if currentAreaDebuffs[spellId] then
        return currentAreaDebuffs[spellId]["order"]
    else
        return 0
    end
end

function F:CreateCentralDebuff(parent)
    local frame = CreateAura_BorderIcon(parent:GetName().."CentralDebuff", parent.widget.overlayFrame, 1)
    parent.indicators.centralDebuff = frame
    frame:SetFrameLevel(77)
    frame:Hide()
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
    local indicatorName, indicator = indicatorTable["indicatorName"]
    if indicatorTable["type"] == "icon" then
        indicator = CreateAura_BarIcon(indicatorName, parent.widget.overlayFrame)
    end
    parent.indicators[indicatorName] = indicator
    
    -- keep custom indicators in table
    if indicatorTable["enabled"] then enabledIndicators[indicatorName] = true end

    local auraType = indicatorTable["auraType"]
    customIndicators[auraType][indicatorName] = {
        ["found"] = {}, -- found cache
        ["auras"] = F:ConvertTable(indicatorTable["auras"]), -- auras to match
    }
    if auraType == "buff" then
        customIndicators[auraType][indicatorName]["castByMe"] = indicatorTable["castByMe"]
    end

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

local function UpdateCustomIndicators(indicatorName, setting, value, aurasTable)
    if not indicatorName or not string.find(indicatorName, "indicator") then return end

    if setting == "enabled" then
        if value then
            enabledIndicators[indicatorName] = true
        else
            enabledIndicators[indicatorName] = nil
        end
    elseif setting == "auras" then
        customIndicators[value][indicatorName]["auras"] = F:ConvertTable(aurasTable)
    elseif setting == "checkbutton" then
        customIndicators["buff"][indicatorName]["castByMe"] = value
    end
end
Cell:RegisterCallback("UpdateIndicators", "UpdateCustomIndicators", UpdateCustomIndicators)

function F:ShowCustomIndicators(unitButton, auraType, auraName, start, duration, debuffType, texture, count, refreshing, castByMe)
    for indicatorName, indicatorTable in pairs(customIndicators[auraType]) do
        if enabledIndicators[indicatorName] then
            if auraType == "buff" then
                -- check castByMe
                if customIndicators["buff"][indicatorName]["castByMe"] == castByMe and indicatorTable["auras"][auraName] then
                    unitButton.indicators[indicatorName]:SetCooldown(start, duration, debuffType, texture, count, refreshing)
                    -- update cache
                    customIndicators[auraType][indicatorName]["found"][auraName] = true
                end
            else
                unitButton.indicators[indicatorName]:SetCooldown(start, duration, debuffType, texture, count, refreshing)
                -- update cache
                customIndicators[auraType][indicatorName]["found"][auraName] = true
            end
        end
    end
end

function F:HideCustomIndicators(unitButton, auraType, auraName, castByMe)
    for indicatorName, indicatorTable in pairs(customIndicators[auraType]) do
        if enabledIndicators[indicatorName] then
            if indicatorTable["auras"][auraName] then
                if auraType == "buff" then
                    if customIndicators["buff"][indicatorName]["castByMe"] == castByMe then
                        -- update cache
                        customIndicators[auraType][indicatorName]["found"][auraName] = nil
                        if F:Getn(customIndicators[auraType][indicatorName]["found"]) == 0 then
                            unitButton.indicators[indicatorName]:Hide()
                        end
                    end
                else
                    -- update cache
                    customIndicators[auraType][indicatorName]["found"][auraName] = nil
                    if F:Getn(customIndicators[auraType][indicatorName]["found"]) == 0 then
                        unitButton.indicators[indicatorName]:Hide()
                    end
                end
            end
        else
            wipe(customIndicators[auraType][indicatorName]["found"])
            unitButton.indicators[indicatorName]:Hide()
        end
    end
end