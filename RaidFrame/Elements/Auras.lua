local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local LCG = LibStub("LibCustomGlow-1.0")

local DebuffTypeColor = DebuffTypeColor
-------------------------------------------------
-- CreateAura_BorderIcon
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

    function frame:SetCooldown(start, duration, debuffType, texture, count, refreshing, glowType, glowColor)
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
        
        if glowType == "Normal" then
            LCG.PixelGlow_Stop(parent)
            LCG.AutoCastGlow_Stop(parent)
            LCG.ButtonGlow_Start(parent, glowColor)
        elseif glowType == "Pixel" then
            LCG.ButtonGlow_Stop(parent)
            LCG.AutoCastGlow_Stop(parent)
            LCG.PixelGlow_Start(parent, glowColor)
        elseif glowType == "Shine" then
            LCG.ButtonGlow_Stop(parent)
            LCG.PixelGlow_Stop(parent)
            LCG.AutoCastGlow_Start(parent, glowColor, 7, 0.5)
        end
    end

    frame:SetScript("OnHide", function()
        LCG.ButtonGlow_Stop(parent)
        LCG.PixelGlow_Stop(parent)
        LCG.AutoCastGlow_Stop(parent)
    end)

    return frame
end

-------------------------------------------------
-- CreateAura_BarIcon
-------------------------------------------------
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
-- CreateAura_Text
-------------------------------------------------
local function CreateAura_Text(name, parent)
    local frame = CreateFrame("Frame", name, parent)
    frame:Hide()
    frame:SetSize(11, 11)

    local text = frame:CreateFontString(nil, "OVERLAY", "CELL_FONT_STATUS")
    frame.text = text
    -- stack:SetJustifyH("RIGHT")
    text:SetPoint("CENTER", 1, 0)

    function frame:SetFont(font, size, flags, horizontalOffset)
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
        text:ClearAllPoints()
        text:SetPoint("CENTER", horizontalOffset, 0)
        frame:SetSize(size+3, size+3)
    end

    function frame:SetCooldown(start, duration, debuffType, texture, count)
        count = (count == 0 or count == 1) and "" or (" "..count)
        if duration == 0 then
            text:SetText(count)
            frame:SetScript("OnUpdate", nil)
        else
            frame:SetScript("OnUpdate", function()
                local remain = duration-(GetTime()-start)
                -- update color
                if remain <= frame.colors[3][4] then
                    text:SetTextColor(frame.colors[3][1], frame.colors[3][2], frame.colors[3][3])
                elseif remain <= duration * frame.colors[2][4] then
                    text:SetTextColor(frame.colors[2][1], frame.colors[2][2], frame.colors[2][3])
                else
                    text:SetTextColor(unpack(frame.colors[1]))
                end
                -- update text
                if remain > 60 then
                    text:SetText(math.ceil(remain/60).."m"..count)
                else
                    text:SetText(string.format("%d", remain)..count)
                end
            end)
        end

        frame:Show()
    end

    function frame:SetColors(colors)
        frame.colors = colors
    end
        
    return frame
end

-------------------------------------------------
-- CreateAura_Rect
-------------------------------------------------
local function CreateAura_Rect(name, parent)
    local frame = CreateFrame("Frame", name, parent, "BackdropTemplate")
    frame:Hide()
    frame:SetSize(11, 4)
    frame:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
    frame:SetBackdropColor(0, 0, 0, 1)

    local tex = frame:CreateTexture(nil, "ARTWORK")
    tex:SetPoint("TOPLEFT", 1, -1)
    tex:SetPoint("BOTTOMRIGHT", -1, 1)

    function frame:SetCooldown(start, duration, debuffType, texture, count)
        if duration == 0 then
            tex:SetColorTexture(unpack(frame.colors[1]))
            frame:SetScript("OnUpdate", nil)
        else
            frame:SetScript("OnUpdate", function()
                local remain = duration-(GetTime()-start)
                -- update color
                if remain <= frame.colors[3][4] then
                    tex:SetColorTexture(frame.colors[3][1], frame.colors[3][2], frame.colors[3][3])
                elseif remain <= duration * frame.colors[2][4] then
                    tex:SetColorTexture(frame.colors[2][1], frame.colors[2][2], frame.colors[2][3])
                else
                    tex:SetColorTexture(unpack(frame.colors[1]))
                end
            end)
        end

        frame:Show()
    end

    function frame:SetColors(colors)
        frame.colors = colors
    end
        
    return frame
end

-------------------------------------------------
-- CreateAura_Bar
-------------------------------------------------
local function CreateAura_Bar(name, parent)
    local bar = Cell:CreateStatusBar(parent, 18, 4, 100)
    bar:Hide()

    function bar:SetCooldown(start, duration, debuffType, texture, count)
        if duration == 0 then
            bar:SetScript("OnUpdate", nil)
            bar:SetMinMaxValues(0, 1)
            bar:SetValue(1)
            bar:SetStatusBarColor(unpack(bar.colors[1]))
        else
            bar:SetMinMaxValues(0, duration)
            bar:SetValue(GetTime()-start)
            bar:SetScript("OnUpdate", function()
                local remain = duration-(GetTime()-start)
                bar:SetValue(remain)
                -- update color
                if remain <= bar.colors[3][4] then
                    bar:SetStatusBarColor(bar.colors[3][1], bar.colors[3][2], bar.colors[3][3])
                elseif remain <= duration * bar.colors[2][4] then
                    bar:SetStatusBarColor(bar.colors[2][1], bar.colors[2][2], bar.colors[2][3])
                else
                    bar:SetStatusBarColor(unpack(bar.colors[1]))
                end
            end)
        end

        bar:Show()
    end

    function bar:SetColors(colors)
        bar.colors = colors
    end
        
    return bar
end

-------------------------------------------------
-- CreateAura_Icons
-------------------------------------------------
local function CreateAura_Icons(name, parent)
    local icons = CreateFrame("Frame", name, parent)
    icons:SetSize(11, 11)
    icons:Hide()

    icons.OriginalSetSize = icons.SetSize

    function icons:SetSize(width, height)
        icons:OriginalSetSize(width, height)
        for i = 1, 5 do
            icons[i]:SetSize(width, height)
        end
    end

    function icons:SetFont(font, ...)
        font = F:GetFont(font)
        for i = 1, 5 do
            icons[i]:SetFont(font, ...)
        end
    end

    function icons:SetOrientation(orientation)
        local point1, point2
        if orientation == "left-to-right" then
            point1 = "LEFT"
            point2 = "RIGHT"
        elseif orientation == "right-to-left" then
            point1 = "RIGHT"
            point2 = "LEFT"
        elseif orientation == "top-to-bottom" then
            point1 = "TOP"
            point2 = "BOTTOM"
        elseif orientation == "bottom-to-top" then
            point1 = "BOTTOM"
            point2 = "TOP"
        end
        
        for i = 2, 5 do
            icons[i]:ClearAllPoints()
            icons[i]:SetPoint(point1, icons[i-1], point2)
        end
    end

    for i = 1, 5 do
        local name = name.."Icons"..i
        local frame = CreateAura_BarIcon(name, icons)
        icons[i] = frame

        if i == 1 then
            frame:SetPoint("TOPLEFT")
        else
            frame:SetPoint("RIGHT", icons[i-1], "LEFT")
        end
    end
    
    return icons
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

    bar:SetScript("OnShow", function()
        tex:SetColorTexture(F:GetClassColor(parent.state.class))
    end)

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
            dispels[i]:Hide()
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

function F:GetDebuffOrder(spellId)
    if currentAreaDebuffs[spellId] then
        return currentAreaDebuffs[spellId]["order"], currentAreaDebuffs[spellId]["glowType"], currentAreaDebuffs[spellId]["glowColor"]
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
    elseif indicatorTable["type"] == "text" then
        indicator = CreateAura_Text(indicatorName, parent.widget.overlayFrame)
    elseif indicatorTable["type"] == "bar" then
        indicator = CreateAura_Bar(indicatorName, parent.widget.overlayFrame)
    elseif indicatorTable["type"] == "rect" then
        indicator = CreateAura_Rect(indicatorName, parent.widget.overlayFrame)
    elseif indicatorTable["type"] == "icons" then
        indicator = CreateAura_Icons(indicatorName, parent.widget.overlayFrame)
    end
    parent.indicators[indicatorName] = indicator
    
    -- keep custom indicators in table
    if indicatorTable["enabled"] then enabledIndicators[indicatorName] = true end

    local auraType = indicatorTable["auraType"]

    -- NOTE: icons is different from other custom indicators, more like the Debuffs indicator
    if indicatorTable["type"] == "icons" then
        customIndicators[auraType][indicatorName] = {
            ["auras"] = F:ConvertTable(indicatorTable["auras"]), -- auras to match
            ["isIcons"] = true,
            ["found"] = {},
            ["num"] = indicatorTable["num"],
            -- ["castByMe"]
        }
    else
        customIndicators[auraType][indicatorName] = {
            ["auras"] = F:ConvertTable(indicatorTable["auras"]), -- auras to match
            ["top"] = {}, -- top aura details
            ["topOrder"] = {}, -- top aura order
            -- ["castByMe"]
        }
    end

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

-- used for switching to a new layout
function F:RemoveAllCustomIndicators(parent)
    for indicatorName, indicator in pairs(parent.indicators) do
        if string.find(indicatorName, "indicator") then
            indicator:ClearAllPoints()
            indicator:Hide()
            indicator:SetParent(nil)
            parent.indicators[indicatorName] = nil
        end
    end

    wipe(enabledIndicators)
    wipe(customIndicators["buff"])
    wipe(customIndicators["debuff"])
end

local function UpdateCustomIndicators(indicatorName, setting, value, value2)
    if not indicatorName or not string.find(indicatorName, "indicator") then return end

    if setting == "enabled" then
        if value then
            enabledIndicators[indicatorName] = true
        else
            enabledIndicators[indicatorName] = nil
        end
    elseif setting == "auras" then
        customIndicators[value][indicatorName]["auras"] = F:ConvertTable(value2)
    elseif setting == "checkbutton" then
        customIndicators["buff"][indicatorName][value] = value2
    elseif setting == "num" then
        if customIndicators["buff"][indicatorName] then
            customIndicators["buff"][indicatorName]["num"] = value
        elseif customIndicators["debuff"][indicatorName] then
            customIndicators["debuff"][indicatorName]["num"] = value
        end
    end
end
Cell:RegisterCallback("UpdateIndicators", "UpdateCustomIndicators", UpdateCustomIndicators)

function F:ResetCustomIndicators(unit, auraType)
    for indicatorName, indicatorTable in pairs(customIndicators[auraType]) do
        if indicatorTable["isIcons"] then
            indicatorTable["found"][unit] = 1
        else
            indicatorTable["topOrder"][unit] = 999
            if not indicatorTable["top"][unit] then
                indicatorTable["top"][unit] = {}
            else
                wipe(indicatorTable["top"][unit])
            end
        end
    end
end

function F:CheckCustomIndicators(unit, unitButton, auraType, auraName, start, duration, debuffType, texture, count, refreshing, castByMe)
    for indicatorName, indicatorTable in pairs(customIndicators[auraType]) do
        if enabledIndicators[indicatorName] then
            if indicatorTable["auras"][auraName] then -- is in indicator spell list
                if auraType == "buff" then
                    -- check castByMe
                    if indicatorTable["castByMe"] == castByMe then
                        if indicatorTable["isIcons"] then
                            if indicatorTable["auras"][auraName] and indicatorTable["found"][unit] <= indicatorTable["num"] then
                                unitButton.indicators[indicatorName][indicatorTable["found"][unit]]:SetCooldown(start, duration, debuffType, texture, count, refreshing)
                                indicatorTable["found"][unit] = indicatorTable["found"][unit] + 1
                                unitButton.indicators[indicatorName]:Show()
                            end
                        else
                            if indicatorTable["auras"][auraName] < indicatorTable["topOrder"][unit] then
                                indicatorTable["topOrder"][unit] = indicatorTable["auras"][auraName]
                                indicatorTable["top"][unit]["start"] = start
                                indicatorTable["top"][unit]["duration"] = duration
                                indicatorTable["top"][unit]["debuffType"] = debuffType
                                indicatorTable["top"][unit]["texture"] = texture
                                indicatorTable["top"][unit]["count"] = count
                                indicatorTable["top"][unit]["refreshing"] = refreshing
                            end
                        end
                    end
                else -- debuff
                    if indicatorTable["isIcons"] then
                        if indicatorTable["auras"][auraName] and indicatorTable["found"][unit] <= indicatorTable["num"] then
                            unitButton.indicators[indicatorName][indicatorTable["found"][unit]]:SetCooldown(start, duration, debuffType, texture, count, refreshing)
                            indicatorTable["found"][unit] = indicatorTable["found"][unit] + 1
                            unitButton.indicators[indicatorName]:Show()
                        end
                    else
                        if  indicatorTable["auras"][auraName] < indicatorTable["topOrder"][unit] then
                            indicatorTable["topOrder"][unit] = indicatorTable["auras"][auraName]
                            indicatorTable["top"][unit]["start"] = start
                            indicatorTable["top"][unit]["duration"] = duration
                            indicatorTable["top"][unit]["debuffType"] = debuffType
                            indicatorTable["top"][unit]["texture"] = texture
                            indicatorTable["top"][unit]["count"] = count
                            indicatorTable["top"][unit]["refreshing"] = refreshing
                        end
                    end
                end
            end
        end
    end
end

function F:ShowCustomIndicators(unit, unitButton, auraType)
    for indicatorName, indicatorTable in pairs(customIndicators[auraType]) do
        if enabledIndicators[indicatorName] then
            if indicatorTable["isIcons"] then
                for i = indicatorTable["found"][unit], 5 do
                    unitButton.indicators[indicatorName][i]:Hide()
                end
                if indicatorTable["found"][unit] == 1 then
                    unitButton.indicators[indicatorName]:Hide()
                end
            else
                if indicatorTable["top"][unit]["start"] then
                    unitButton.indicators[indicatorName]:SetCooldown(
                        indicatorTable["top"][unit]["start"], 
                        indicatorTable["top"][unit]["duration"], 
                        indicatorTable["top"][unit]["debuffType"], 
                        indicatorTable["top"][unit]["texture"], 
                        indicatorTable["top"][unit]["count"], 
                        indicatorTable["top"][unit]["refreshing"])
                else
                    unitButton.indicators[indicatorName]:Hide()
                end
            end
        end
    end
end