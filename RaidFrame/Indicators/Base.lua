local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local I = Cell.iFuncs

local DebuffTypeColor = DebuffTypeColor
-------------------------------------------------
-- CreateAura_BorderIcon
-------------------------------------------------
function I:CreateAura_BorderIcon(name, parent, borderSize)
    local frame = CreateFrame("Frame", name, parent, "BackdropTemplate")
    frame:Hide()
    frame:SetSize(11, 11)
    frame:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
    frame:SetBackdropColor(0, 0, 0, .75)
    
    local border = frame:CreateTexture(name.."Border", "BORDER")
    frame.border = border
    border:SetAllPoints(frame)
    border:Hide()

    local cooldown = CreateFrame("Cooldown", name.."Cooldown", frame)
    frame.cooldown = cooldown
    cooldown:SetAllPoints(frame)
    cooldown:SetSwipeTexture("Interface\\Buttons\\WHITE8x8")
    cooldown:SetSwipeColor(1, 1, 1)
    cooldown.noCooldownCount = true -- disable omnicc

    local iconFrame = CreateFrame("Frame", name.."IconFrame", frame)
    iconFrame:SetPoint("TOPLEFT", borderSize, -borderSize)
    iconFrame:SetPoint("BOTTOMRIGHT", -borderSize, borderSize)
    iconFrame:SetFrameLevel(cooldown:GetFrameLevel()+1)

    local icon = iconFrame:CreateTexture(name.."Icon", "ARTWORK")
    frame.icon = icon
    icon:SetTexCoord(.12, .88, .12, .88)
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

    function frame:SetBorder(thickness)
        iconFrame:ClearAllPoints()
        iconFrame:SetPoint("TOPLEFT", thickness, -thickness)
        iconFrame:SetPoint("BOTTOMRIGHT", -thickness, thickness)
    end

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
            border:SetColorTexture(r, g, b)
            cooldown:Hide()
            frame.duration:Hide()
            frame:SetScript("OnUpdate", nil)
        else
            border:Hide()
            cooldown:Show()
            cooldown:SetSwipeColor(r, g, b)
            cooldown:SetCooldown(start, duration)
            frame.duration:Show()
            frame:SetScript("OnUpdate", function()
                local remain = duration-(GetTime()-start)
                -- if remain <= 5 then
                --     frame.duration:SetText(string.format("%.1f", remain))
                if remain <= 60 then
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

-------------------------------------------------
-- CreateAura_BarIcon
-------------------------------------------------
-- local LSSB = LibStub:GetLibrary("LibSmoothStatusBar-1.0")
function I:CreateAura_BarIcon(name, parent)
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

    local duration = cooldown:CreateFontString(nil, "OVERLAY", "CELL_FONT_STATUS")
    frame.duration = duration
    duration:SetJustifyH("RIGHT")
    duration:SetPoint("BOTTOMRIGHT", 2, 0)
    duration:Hide()

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
            stack:SetFont(font, size)
            stack:SetShadowOffset(1, -1)
            stack:SetShadowColor(0, 0, 0, 1)
            duration:SetFont(font, size)
            duration:SetShadowOffset(1, -1)
            duration:SetShadowColor(0, 0, 0, 1)
        else
            if flags == "Outline" then
                flags = "OUTLINE"
            else
                flags = "OUTLINE, MONOCHROME"
            end
            stack:SetFont(font, size, flags)
            stack:SetShadowOffset(0, 0)
            stack:SetShadowColor(0, 0, 0, 0)
            duration:SetFont(font, size, flags)
            duration:SetShadowOffset(0, 0)
            duration:SetShadowColor(0, 0, 0, 0)
        end
        stack:ClearAllPoints()
        stack:SetPoint("TOPRIGHT", horizontalOffset, 0)
        duration:ClearAllPoints()
        duration:SetPoint("BOTTOMRIGHT", horizontalOffset, 0)
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
            frame:SetScript("OnUpdate", nil)
        else
            -- init bar values
            cooldown:SetMinMaxValues(0, duration)
            cooldown:SetValue(GetTime()-start)
            cooldown:Show()
            if frame.showDuration then
                frame:SetScript("OnUpdate", function()
                    local remain = duration-(GetTime()-start)
                    if remain <= 30 then
                        frame.duration:SetText(string.format("%d", remain))
                    else
                        frame.duration:SetText("")
                    end
                end)
            end
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

    function frame:ShowDuration(show)
        frame.showDuration = show
        if show then
            duration:Show()
        else
            duration:Hide()
        end
    end

    return frame
end

-------------------------------------------------
-- CreateAura_Text
-------------------------------------------------
function I:CreateAura_Text(name, parent)
    local frame = CreateFrame("Frame", name, parent)
    frame:SetSize(11, 11)
    frame:Hide()
    frame.indicatorType = "text"

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

        local point = frame:GetPoint(1)
        text:ClearAllPoints()
        if string.find(point, "LEFT") then
            text:SetPoint("LEFT", horizontalOffset, 0)
        elseif string.find(point, "RIGHT") then
            text:SetPoint("RIGHT", horizontalOffset, 0)
        else
            text:SetPoint("CENTER", horizontalOffset, 0)
        end
        frame:SetSize(size+3, size+3)
    end

    frame.OriginalSetPoint = frame.SetPoint
    function frame:SetPoint(point, relativeTo, relativePoint, x, y)
        local horizontalOffset = select(4, text:GetPoint(1))
        text:ClearAllPoints()
        if string.find(point, "LEFT") then
            text:SetPoint("LEFT", horizontalOffset, 0)
        elseif string.find(point, "RIGHT") then
            text:SetPoint("RIGHT", horizontalOffset, 0)
        else
            text:SetPoint("CENTER", horizontalOffset, 0)
        end
        frame:OriginalSetPoint(point, relativeTo, relativePoint, x, y)
    end

    function frame:SetCooldown(start, duration, debuffType, texture, count)
        count = (count == 0 or count == 1) and "" or (count.." ")
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
                    text:SetText(count..math.ceil(remain/60).."m")
                else
                    text:SetText(count..string.format("%d", remain))
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
function I:CreateAura_Rect(name, parent)
    local frame = CreateFrame("Frame", name, parent, "BackdropTemplate")
    frame:SetSize(11, 4)
    frame:Hide()
    frame.indicatorType = "rect"
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
function I:CreateAura_Bar(name, parent)
    local bar = Cell:CreateStatusBar(parent, 18, 4, 100)
    bar:Hide()
    bar.indicatorType = "bar"

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
function I:CreateAura_Icons(name, parent)
    local icons = CreateFrame("Frame", name, parent)
    icons:SetSize(11, 11)
    icons:Hide()
    icons.indicatorType = "icons"

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
        local frame = I:CreateAura_BarIcon(name, icons)
        icons[i] = frame

        if i == 1 then
            frame:SetPoint("TOPLEFT")
        else
            frame:SetPoint("RIGHT", icons[i-1], "LEFT")
        end
    end

    function icons:ShowDuration(show)
        for i = 1, 5 do
            icons[i]:ShowDuration(show)
        end
    end

    return icons
end