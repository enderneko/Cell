local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local I = Cell.iFuncs

-------------------------------------------------
-- CreateDefensiveCooldowns
-------------------------------------------------
function I:CreateDefensiveCooldowns(parent)
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
        local frame = I:CreateAura_BarIcon(name, defensiveCooldowns)
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
function I:CreateExternalCooldowns(parent)
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
        local frame = I:CreateAura_BarIcon(name, externalCooldowns)
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
function I:CreateTankActiveMitigation(parent)
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
        tex:SetColorTexture(F:GetClassColor(parent.state.class))
        bar:SetMinMaxValues(0, duration)
        bar:SetValue(GetTime()-start)
        bar:Show()
    end
end

-------------------------------------------------
-- CreateDebuffs
-------------------------------------------------
function I:CreateDebuffs(parent)
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
        local frame = I:CreateAura_BarIcon(name, debuffs)
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
function I:CreateDispels(parent)
    local dispels = CreateFrame("Frame", parent:GetName().."DispelParent", parent.widget.overlayFrame)
    parent.indicators.dispels = dispels
    dispels:SetFrameLevel(77)
    dispels:Hide()

    dispels.highlight = parent.widget.healthBar:CreateTexture(parent:GetName().."DispelHighlight", "ARTWORK")
    dispels.highlight:SetAllPoints(parent.widget.healthBar)
    dispels.highlight:SetTexture("Interface\\Buttons\\WHITE8x8")
    dispels.highlight:Hide()

    dispels.OriginalSetSize = dispels.SetSize

    function dispels:SetSize(width, height)
        dispels:OriginalSetSize(width, height)
        for i = 1, 4 do
            dispels[i]:SetSize(width, height)
        end
    end

    function dispels:SetDispels(dispelTypes)
        local r, g, b, a = 0, 0, 0, 0

        local i = 1
        for dispelType, _ in pairs(dispelTypes) do
            dispels[i]:SetDispel(dispelType)
            i = i + 1
            if dispelType then
                r, g, b, a = DebuffTypeColor[dispelType].r, DebuffTypeColor[dispelType].g, DebuffTypeColor[dispelType].b, .5
            end
        end

        -- hide unused
        for j = i, 4 do
            dispels[j]:Hide()
        end

        -- highlight
        dispels.highlight:SetGradientAlpha("VERTICAL", r, g, b, a, r, g, b, 0)
    end

    function dispels:EnableHighlight(enabled)
        if enabled then
            dispels.highlight:Show()
        else
            dispels.highlight:Hide()
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

function I:GetDebuffOrder(spellId)
    if currentAreaDebuffs[spellId] then
        return currentAreaDebuffs[spellId]["order"], currentAreaDebuffs[spellId]["glowType"], currentAreaDebuffs[spellId]["glowColor"]
    else
        return 0
    end
end

function I:CreateCentralDebuff(parent)
    local frame = I:CreateAura_BorderIcon(parent:GetName().."CentralDebuff", parent.widget.overlayFrame, 1)
    parent.indicators.centralDebuff = frame
    frame:SetFrameLevel(77)
    frame:Hide()
end

-------------------------------------------------
-- player raid icon
-------------------------------------------------
function I:CreatePlayerRaidIcon(parent)
    -- local playerRaidIcon = parent.widget.overlayFrame:CreateTexture(parent:GetName().."PlayerRaidIcon", "ARTWORK", nil, -7)
    -- parent.indicators.playerRaidIcon = playerRaidIcon
    -- playerRaidIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    local playerRaidIcon = CreateFrame("Frame", parent:GetName().."PlayerRaidIcon", parent.widget.overlayFrame)
    parent.indicators.playerRaidIcon = playerRaidIcon
    playerRaidIcon.tex = playerRaidIcon:CreateTexture(nil, "ARTWORK")
    playerRaidIcon.tex:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    playerRaidIcon.tex:SetAllPoints(playerRaidIcon)
    playerRaidIcon:Hide()
end

-------------------------------------------------
-- target raid icon
-------------------------------------------------
function I:CreateTargetRaidIcon(parent)
    local targetRaidIcon = CreateFrame("Frame", parent:GetName().."TargetRaidIcon", parent.widget.overlayFrame)
    parent.indicators.targetRaidIcon = targetRaidIcon
    targetRaidIcon.tex = targetRaidIcon:CreateTexture(nil, "ARTWORK")
    targetRaidIcon.tex:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    targetRaidIcon.tex:SetAllPoints(targetRaidIcon)
    targetRaidIcon:Hide()
end

-------------------------------------------------
-- health text
-------------------------------------------------
function I:CreateHealthText(parent)
    local healthText = CreateFrame("Frame", parent:GetName().."HealthText", parent.widget.overlayFrame)
    parent.indicators.healthText = healthText
    healthText:Hide()

    local text = healthText:CreateFontString(nil, "OVERLAY", "CELL_FONT_STATUS")
    healthText.text = text

    function healthText:SetFont(font, size, flags, horizontalOffset)
        if not string.find(font, ".ttf") then font = F:GetFont(font) end

        if flags == "Shadow" then
            text:SetFont(font, size)
            text:SetShadowOffset(1, -1)
            text:SetShadowColor(0, 0, 0, 1)
        else
            if flags == "Outline" then
                flags = "OUTLINE"
            else
                flags = "OUTLINE, MONOCHROME"
            end
            text:SetFont(font, size, flags)
            text:SetShadowOffset(0, 0)
            text:SetShadowColor(0, 0, 0, 0)
        end

        local point = healthText:GetPoint(1)
        text:ClearAllPoints()
        if string.find(point, "LEFT") then
            text:SetPoint("LEFT", horizontalOffset, 0)
        elseif string.find(point, "RIGHT") then
            text:SetPoint("RIGHT", horizontalOffset, 0)
        else
            text:SetPoint("CENTER", horizontalOffset, 0)
        end
        healthText:SetSize(text:GetStringWidth()+3, size+3)
    end

    healthText.OriginalSetPoint = healthText.SetPoint
    function healthText:SetPoint(point, relativeTo, relativePoint, x, y)
        local horizontalOffset = select(4, text:GetPoint(1))
        text:ClearAllPoints()
        if string.find(point, "LEFT") then
            text:SetPoint("LEFT", horizontalOffset, 0)
        elseif string.find(point, "RIGHT") then
            text:SetPoint("RIGHT", horizontalOffset, 0)
        else
            text:SetPoint("CENTER", horizontalOffset, 0)
        end
        healthText:OriginalSetPoint(point, relativeTo, relativePoint, x, y)
    end

    function healthText:SetFormat(format)
        healthText.format = format
    end

    function healthText:SetColor(r, g, b)
        text:SetTextColor(r, g, b)
    end

    function healthText:SetHealth(current, max)
        if healthText.format == "percentage" then
            text:SetText(string.format("%d%%", current/max*100))
        elseif healthText.format == "percentage-deficit" then
            text:SetText(string.format("%d%%", (current-max)/max*100))
        elseif healthText.format == "number" then
            text:SetText(current)
        elseif healthText.format == "number-short" then
            text:SetText(F:FormatNumer(current))
        elseif healthText.format == "number-deficit" then
            text:SetText(current-max)
        elseif healthText.format == "number-deficit-short" then
            text:SetText(F:FormatNumer(current-max))
        end
        healthText:SetWidth(text:GetStringWidth()+3)
    end
end