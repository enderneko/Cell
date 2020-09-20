local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

local unitDebuffs = {}
function F:UnitDebuffs(unit, filterMode, filterList)
    local debuffs, currentDebuffs = {}, {}
    if not unitDebuffs[unit] then unitDebuffs[unit] = {} end

    for i = 1, 40 do
        -- name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod, ...
        local name, icon, count, debuffType, duration, expirationTime = UnitDebuff(unit, i)
		if not name then
			break
        end
        
        local isValid
        if filterMode == "BLACKLIST" then
            if filterList[name] then
                isValid = false
            else
                isValid = true
            end
        else -- WHITELIST
            if filterList[name] then
                isValid = true
            else
                isValid = false
            end
        end

		if isValid and duration and duration <= 600 then
            if unitDebuffs[unit][name] and expirationTime > unitDebuffs[unit][name] then
                -- start, duration, debuffType, texture, count, refreshing
                debuffs[i] = {expirationTime - duration, duration, debuffType or "", icon, count, true}
            else
                -- start, duration, debuffType, texture, count
                debuffs[i] = {expirationTime - duration, duration, debuffType or "", icon, count}
            end
            unitDebuffs[unit][name] = expirationTime
            currentDebuffs[name] = i
		end
    end
    
    local t = GetTime()
    for name, expirationTime in pairs(unitDebuffs[unit]) do
        -- lost or expired
        if not currentDebuffs[name] or t > expirationTime then
            unitDebuffs[unit][name] = nil
        end
    end

    return debuffs
end

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
    maskIcon:SetVertexColor(.5, .5, .5, 1)
    maskIcon:AddMaskTexture(mask)

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
        local r, g, b
        if debuffType then
            r, g, b = DebuffTypeColor[debuffType].r, DebuffTypeColor[debuffType].g, DebuffTypeColor[debuffType].b
        else
            r, g, b = 0, 0, 0
        end

        if duration == 0 then
            cooldown:Hide()
        else
            -- init bar values
            cooldown:SetMinMaxValues(0, duration)
            cooldown:SetValue(GetTime()-start)
            cooldown:Show()
        end
        
        frame:SetBackdropColor(r, g, b, 1)
        spark:SetColorTexture(r, g, b, 1)
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

end

-------------------------------------------------
-- CreateCentralDebuff
-------------------------------------------------
function F:CreateCentralDebuff(parent)
    local name = parent:GetName().."Debuff"..i
    local frame = CreateFrame("Frame", name, debuffs)
    tinsert(debuffs, frame)
    -- frame:Hide()
    frame:SetSize(11, 11)
    frame:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
    frame:SetBackdropColor(0, 0, 0, .7)
    
    if i == 1 then
        frame:SetPoint("TOPLEFT")
    else
        frame:SetPoint("LEFT", debuffs[i-1], "RIGHT", 1, 0)
    end
    
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
    
    local iconFrame = CreateFrame("Frame", name.."IconFrame", frame)
    iconFrame:SetPoint("TOPLEFT", 1, -1)
    iconFrame:SetPoint("BOTTOMRIGHT", -1, 1)

    local icon = iconFrame:CreateTexture(name.."Icon", "OVERLAY")
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
end

-------------------------------------------------
-- other indicators (aura)
-------------------------------------------------
function F:CreateIndicator(parent, name)

end