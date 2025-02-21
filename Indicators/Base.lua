local _, Cell = ...
local L = Cell.L
---@type CellFuncs
local F = Cell.funcs
---@class CellIndicatorFuncs
local I = Cell.iFuncs
---@type PixelPerfectFuncs
local P = Cell.pixelPerfectFuncs

local LCG = LibStub("LibCustomGlow-1.0")

CELL_BORDER_SIZE = 1
CELL_BORDER_COLOR = {0, 0, 0, 1}
CELL_COOLDOWN_STYLE = "VERTICAL"

-------------------------------------------------
-- SetFont
-------------------------------------------------
function I.JustifyText(text, point)
    if strfind(point, "LEFT$") then
        text:SetJustifyH("LEFT")
    elseif strfind(point, "RIGHT$") then
        text:SetJustifyH("RIGHT")
    else
        text:SetJustifyH("CENTER")
    end

    if strfind(point, "^TOP") then
        text:SetJustifyV("TOP")
    elseif strfind(point, "^BOTTOM") then
        text:SetJustifyV("BOTTOM")
    else
        text:SetJustifyV("MIDDLE")
    end
end

function I.SetFont(fs, anchorTo, font, size, outline, shadow, anchor, xOffset, yOffset, color)
    font = F.GetFont(font)

    local flags
    if outline == "None" then
        flags = ""
    elseif outline == "Outline" then
        flags = "OUTLINE"
    else
        flags = "OUTLINE,MONOCHROME"
    end

    fs:SetFont(font, size, flags)

    if shadow then
        fs:SetShadowOffset(1, -1)
        fs:SetShadowColor(0, 0, 0, 1)
    else
        fs:SetShadowOffset(0, 0)
        fs:SetShadowColor(0, 0, 0, 0)
    end

    P.ClearPoints(fs)
    P.Point(fs, anchor, anchorTo, anchor, xOffset, yOffset)
    I.JustifyText(fs, anchor)

    if color then
        fs.r = color[1]
        fs.g = color[2]
        fs.b = color[3]
        fs:SetTextColor(fs.r, fs.g, fs.b)
    else
        fs.r, fs.g, fs.b = 1, 1, 1
    end
end

-------------------------------------------------
-- Shared
-------------------------------------------------
local function Shared_SetFont(frame, font1, font2)
    I.SetFont(frame.stack, frame, unpack(font1))
    I.SetFont(frame.duration, frame, unpack(font2))
end

local function Shared_ShowStack(frame, show)
    frame.stack:SetShown(show)
end

local function Shared_ShowDuration(frame, show)
    frame.showDuration = show
    frame.duration:SetShown(show)
end

-------------------------------------------------
-- VerticalCooldown
-------------------------------------------------
local function ReCalcTexCoord(self, width, height)
    local texCoord = F.GetTexCoord(width, height)
    self.icon:SetTexCoord(unpack(texCoord))
    if self.cooldown.icon then
        self.cooldown.icon:SetTexCoord(unpack(texCoord))
    end
end

local function VerticalCooldown_OnUpdate(self, elapsed)
    self.elapsed = self.elapsed + elapsed
    if self.elapsed >= 0.1 then
        self:SetValue(self:GetValue() + self.elapsed)
        self.elapsed = 0
    end
end

-- for LCG.ButtonGlow_Start
local function VerticalCooldown_GetCooldownDuration()
    return 0
end

local function VerticalCooldown_ShowCooldown(self, start, duration, _, icon, debuffType)
    if debuffType then
        self.spark:SetColorTexture(I.GetDebuffTypeColor(debuffType))
    else
        self.spark:SetColorTexture(0.5, 0.5, 0.5)
    end

    if self.icon then
        self.icon:SetTexture(icon)
    end

    self.elapsed = 0.1 -- update immediately
    self:SetMinMaxValues(0, duration)
    self:SetValue(GetTime() - start)
    self:Show()
end

local function Shared_CreateCooldown_Vertical(frame)
    local cooldown = CreateFrame("StatusBar", nil, frame)
    frame.cooldown = cooldown
    cooldown:Hide()

    cooldown.GetCooldownDuration = VerticalCooldown_GetCooldownDuration
    cooldown.ShowCooldown = VerticalCooldown_ShowCooldown
    cooldown:SetScript("OnUpdate", VerticalCooldown_OnUpdate)

    P.Point(cooldown, "TOPLEFT", frame.icon)
    P.Point(cooldown, "BOTTOMRIGHT", frame.icon, "BOTTOMRIGHT", 0, CELL_BORDER_SIZE)
    cooldown:SetOrientation("VERTICAL")
    cooldown:SetReverseFill(true)
    cooldown:SetStatusBarTexture(Cell.vars.whiteTexture)

    local texture = cooldown:GetStatusBarTexture()
    texture:SetAlpha(0)

    local spark = cooldown:CreateTexture(nil, "BORDER")
    cooldown.spark = spark
    P.Height(spark, 1)
    spark:SetBlendMode("ADD")
    spark:SetPoint("TOPLEFT", texture, "BOTTOMLEFT")
    spark:SetPoint("TOPRIGHT", texture, "BOTTOMRIGHT")

    local mask = cooldown:CreateMaskTexture()
    mask:SetTexture(Cell.vars.whiteTexture, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetPoint("TOPLEFT")
    mask:SetPoint("BOTTOMRIGHT", texture)

    local icon = cooldown:CreateTexture(nil, "ARTWORK")
    cooldown.icon = icon
    -- icon:SetTexCoord(0.12, 0.88, 0.12, 0.88)
    icon:SetDesaturated(true)
    icon:SetAllPoints(frame.icon)
    icon:SetVertexColor(0.5, 0.5, 0.5, 1)
    icon:AddMaskTexture(mask)
end

local function Shared_CreateCooldown_Vertical_NoIcon(frame)
    local cooldown = CreateFrame("StatusBar", nil, frame)
    frame.cooldown = cooldown
    cooldown:Hide()

    cooldown.GetCooldownDuration = VerticalCooldown_GetCooldownDuration
    cooldown.ShowCooldown = VerticalCooldown_ShowCooldown
    cooldown:SetScript("OnUpdate", VerticalCooldown_OnUpdate)

    P.Point(cooldown, "TOPLEFT", frame, CELL_BORDER_SIZE, -CELL_BORDER_SIZE)
    P.Point(cooldown, "BOTTOMRIGHT", frame, -CELL_BORDER_SIZE, CELL_BORDER_SIZE + CELL_BORDER_SIZE)
    cooldown:SetOrientation("VERTICAL")
    cooldown:SetReverseFill(true)
    cooldown:SetStatusBarTexture(Cell.vars.whiteTexture)

    local texture = cooldown:GetStatusBarTexture()
    texture:SetVertexColor(0, 0, 0, 0.8)

    local spark = cooldown:CreateTexture(nil, "BORDER")
    cooldown.spark = spark
    P.Height(spark, 1)
    spark:SetBlendMode("ADD")
    spark:SetPoint("TOPLEFT", texture, "BOTTOMLEFT")
    spark:SetPoint("TOPRIGHT", texture, "BOTTOMRIGHT")
end

-------------------------------------------------
-- ClockCooldown
-------------------------------------------------
local function Shared_CreateCooldown_Clock(frame)
    local cooldown = CreateFrame("Cooldown", nil, frame)
    frame.cooldown = cooldown
    cooldown:Hide()

    P.Point(cooldown, "TOPLEFT", frame, CELL_BORDER_SIZE, -CELL_BORDER_SIZE)
    P.Point(cooldown, "BOTTOMRIGHT", frame, -CELL_BORDER_SIZE, CELL_BORDER_SIZE)
    cooldown:SetReverse(true)
    cooldown:SetDrawEdge(false)
    cooldown:SetSwipeTexture(Cell.vars.whiteTexture)
    cooldown:SetSwipeColor(0, 0, 0, 0.77)
    -- cooldown:SetEdgeTexture([[Interface\Cooldown\UI-HUD-ActionBar-SecondaryCooldown]])

    -- cooldown text
    cooldown:SetHideCountdownNumbers(true)
    -- disable omnicc
    cooldown.noCooldownCount = true
    -- prevent some dirty addons from adding cooldown text
    cooldown.ShowCooldown = cooldown.SetCooldown
    cooldown.SetCooldown = nil
end

-------------------------------------------------
-- SetCooldownStyle
-------------------------------------------------
local function Shared_SetCooldownStyle(frame, style, noIcon)
    if frame.style == style then return end

    if frame.cooldown then
        frame.cooldown:SetParent(nil)
        frame.cooldown:Hide()
    end

    frame.style = style

    if style == "CLOCK" then
        Shared_CreateCooldown_Clock(frame)
    else
        if noIcon then
            Shared_CreateCooldown_Vertical_NoIcon(frame)
        else
            Shared_CreateCooldown_Vertical(frame)
        end
    end
end

-------------------------------------------------
-- Icon_OnUpdate
-------------------------------------------------
local function Icon_OnUpdate(frame, elapsed)
    frame._remain = frame._duration - (GetTime() - frame._start)
    if frame._remain < 0 then frame._remain = 0 end

    if frame._remain > frame._threshold then
        frame.duration:SetText("")
        return
    end

    frame._elapsed = frame._elapsed + elapsed
    if frame._elapsed >= 0.1 then
        frame._elapsed = 0
        -- color
        if Cell.vars.iconDurationColors then
            if frame._remain < Cell.vars.iconDurationColors[3][4] then
                frame.duration:SetTextColor(Cell.vars.iconDurationColors[3][1], Cell.vars.iconDurationColors[3][2], Cell.vars.iconDurationColors[3][3])
            elseif frame._remain < (Cell.vars.iconDurationColors[2][4] * frame._duration) then
                frame.duration:SetTextColor(Cell.vars.iconDurationColors[2][1], Cell.vars.iconDurationColors[2][2], Cell.vars.iconDurationColors[2][3])
            else
                frame.duration:SetTextColor(Cell.vars.iconDurationColors[1][1], Cell.vars.iconDurationColors[1][2], Cell.vars.iconDurationColors[1][3])
            end
        else
            frame.duration:SetTextColor(frame.duration.r, frame.duration.g, frame.duration.b)
        end
    end

    -- format
    if frame._remain > 60 then
        frame.duration:SetFormattedText("%dm", frame._remain / 60)
    else
        if Cell.vars.iconDurationRoundUp then
            frame.duration:SetFormattedText("%d", ceil(frame._remain))
        else
            if frame._remain < Cell.vars.iconDurationDecimal then
                frame.duration:SetFormattedText("%.1f", frame._remain)
            else
                frame.duration:SetFormattedText("%d", frame._remain)
            end
        end
    end
end

local function Icon_OnUpdate_ElapsedTime(frame, elapsed)
    frame._remain = frame._duration - (GetTime() - frame._start)
    if frame._remain < 0 then frame._remain = 0 end

    if frame._remain > frame._threshold then
        frame.duration:SetText("")
        return
    end

    frame._elapsed = frame._elapsed + elapsed
    if frame._elapsed >= 0.1 then
        frame._elapsed = 0
        -- color
        if Cell.vars.iconDurationColors then
            if frame._remain < Cell.vars.iconDurationColors[3][4] then
                frame.duration:SetTextColor(Cell.vars.iconDurationColors[3][1], Cell.vars.iconDurationColors[3][2], Cell.vars.iconDurationColors[3][3])
            elseif frame._remain < (Cell.vars.iconDurationColors[2][4] * frame._duration) then
                frame.duration:SetTextColor(Cell.vars.iconDurationColors[2][1], Cell.vars.iconDurationColors[2][2], Cell.vars.iconDurationColors[2][3])
            else
                frame.duration:SetTextColor(Cell.vars.iconDurationColors[1][1], Cell.vars.iconDurationColors[1][2], Cell.vars.iconDurationColors[1][3])
            end
        else
            frame.duration:SetTextColor(frame.duration.r, frame.duration.g, frame.duration.b)
        end
    end

    -- format
    frame._elapsedTime = GetTime() - frame._start
    if frame._elapsedTime > frame._duration then frame._elapsedTime = frame._duration end

    if frame._elapsedTime > 60 then
        frame.duration:SetFormattedText("%dm", frame._elapsedTime / 60)
    else
        frame.duration:SetFormattedText("%d", frame._elapsedTime)
    end
end

-------------------------------------------------
-- CreateAura_BorderIcon
-------------------------------------------------
local function BorderIcon_SetCooldown(frame, start, duration, debuffType, texture, count, refreshing, useElapsedTime)
    local r, g, b
    if debuffType then
        r, g, b = I.GetDebuffTypeColor(debuffType)
    else
        r, g, b = 0, 0, 0
    end

    if duration == 0 then
        frame.border:Show()
        frame.border:SetColorTexture(r, g, b)
        frame.cooldown:Hide()
        frame.duration:Hide()
        frame:SetScript("OnUpdate", nil)
        frame._start = nil
        frame._duration = nil
        frame._remain = nil
        frame._elapsed = nil
        frame._threshold = nil
        frame._elapsedTime = nil
    else
        frame.border:Hide()
        frame.cooldown:Show()
        frame.cooldown:SetSwipeColor(r, g, b)
        frame.cooldown:_SetCooldown(start, duration)

        if not frame.showDuration then
            frame.duration:Hide()
        else
            if frame.showDuration == true then
                frame._threshold = duration
            elseif frame.showDuration >= 1 then
                frame._threshold = frame.showDuration
            else -- < 1
                frame._threshold = frame.showDuration * duration
            end
            frame.duration:Show()
        end

        if frame.showDuration then
            frame._start = start
            frame._duration = duration
            frame._elapsed = 0.1 -- update immediately
            frame:SetScript("OnUpdate", useElapsedTime and Icon_OnUpdate_ElapsedTime or Icon_OnUpdate)
        end
    end

    frame.icon:SetTexture(texture)
    frame.stack:SetText((count == 0 or count == 1) and "" or count)
    frame:Show()

    if refreshing then
        frame.ag:Play()
    end
end

local function BorderIcon_SetBorder(frame, thickness)
    P.ClearPoints(frame.iconFrame)
    P.Point(frame.iconFrame, "TOPLEFT", frame, "TOPLEFT", thickness, -thickness)
    P.Point(frame.iconFrame, "BOTTOMRIGHT", frame, "BOTTOMRIGHT", -thickness, thickness)
end

local function BorderIcon_ShowDuration(frame, show)
    frame.showDuration = show
    if show then
        frame.duration:Show()
    else
        frame.duration:Hide()
    end
end

local function BorderIcon_UpdatePixelPerfect(frame)
    P.Resize(frame)
    P.Repoint(frame)
    P.Repoint(frame.iconFrame)
    P.Repoint(frame.stack)
    P.Repoint(frame.duration)
end

function I.CreateAura_BorderIcon(name, parent, borderSize)
    local frame = CreateFrame("Frame", name, parent, "BackdropTemplate")
    frame:Hide()
    -- frame:SetSize(11, 11)
    frame:SetBackdrop({bgFile = Cell.vars.whiteTexture})
    frame:SetBackdropColor(0, 0, 0, 0.85)

    local border = frame:CreateTexture(name.."Border", "BORDER")
    frame.border = border
    border:SetAllPoints(frame)
    border:Hide()

    local cooldown = CreateFrame("Cooldown", name.."Cooldown", frame)
    frame.cooldown = cooldown
    cooldown:SetAllPoints(frame)
    cooldown:SetSwipeTexture(Cell.vars.whiteTexture)
    cooldown:SetSwipeColor(1, 1, 1)
    cooldown:SetHideCountdownNumbers(true)
    -- disable omnicc
    cooldown.noCooldownCount = true
    -- prevent some addons from adding cooldown text
    cooldown._SetCooldown = cooldown.SetCooldown
    cooldown.SetCooldown = nil

    local iconFrame = CreateFrame("Frame", name.."IconFrame", frame)
    frame.iconFrame = iconFrame
    P.Point(iconFrame, "TOPLEFT", frame, "TOPLEFT", borderSize, -borderSize)
    P.Point(iconFrame, "BOTTOMRIGHT", frame, "BOTTOMRIGHT", -borderSize, borderSize)
    iconFrame:SetFrameLevel(cooldown:GetFrameLevel()+1)

    local icon = iconFrame:CreateTexture(name.."Icon", "ARTWORK")
    frame.icon = icon
    icon:SetTexCoord(0.12, 0.88, 0.12, 0.88)
    icon:SetAllPoints(iconFrame)

    frame.stack = iconFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_STATUS")
    frame.duration = iconFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_STATUS")

    local ag = frame:CreateAnimationGroup()
    frame.ag = ag
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

    frame.SetFont = Shared_SetFont
    frame.SetBorder = BorderIcon_SetBorder
    frame.SetCooldown = BorderIcon_SetCooldown
    frame.ShowDuration = BorderIcon_ShowDuration
    frame.UpdatePixelPerfect = BorderIcon_UpdatePixelPerfect

    return frame
end

-------------------------------------------------
-- CreateAura_BarIcon
-------------------------------------------------
local function BarIcon_SetCooldown(frame, start, duration, debuffType, texture, count, refreshing)
    if duration == 0 then
        frame.cooldown:Hide()
        frame.duration:Hide()
        frame.stack:SetParent(frame)
        frame:SetScript("OnUpdate", nil)
        frame._start = nil
        frame._duration = nil
        frame._threshold = nil
        frame._remain = nil
        frame._elapsed = nil
    else
        if frame.showAnimation then
            frame.cooldown:ShowCooldown(start, duration, nil, texture, debuffType)
            frame.duration:SetParent(frame.cooldown)
            frame.stack:SetParent(frame.cooldown)
        else
            frame.cooldown:Hide()
            frame.duration:SetParent(frame)
            frame.stack:SetParent(frame)
        end

        if not frame.showDuration then
            frame.duration:Hide()
        else
            if frame.showDuration == true then
                frame._threshold = duration
            elseif frame.showDuration >= 1 then
                frame._threshold = frame.showDuration
            else -- < 1
                frame._threshold = frame.showDuration * duration
            end
            frame.duration:Show()
        end

        if frame.showDuration then
            frame._start = start
            frame._duration = duration
            frame._elapsed = 0.1 -- update immediately
            frame:SetScript("OnUpdate", Icon_OnUpdate)
        end
    end

    if debuffType then
        frame:SetBackdropColor(I.GetDebuffTypeColor(debuffType))
    else
        frame:SetBackdropColor(0, 0, 0)
    end

    frame.icon:SetTexture(texture)
    frame.stack:SetText((count == 0 or count == 1) and "" or count)
    frame:Show()

    if refreshing then
        frame.ag:Play()
    end
end

local function BarIcon_ShowAnimation(frame, show)
    frame.showAnimation = show
    if show then
        frame.cooldown:Show()
    else
        frame.cooldown:Hide()
    end
end

local function BarIcon_UpdatePixelPerfect(frame)
    P.Resize(frame)
    P.Repoint(frame)
    P.Repoint(frame.icon)
    P.Repoint(frame.stack)
    P.Repoint(frame.duration)
    P.Repoint(frame.cooldown)
    if frame.cooldown.spark then
        P.Resize(frame.cooldown.spark)
    end
end

function I.CreateAura_BarIcon(name, parent)
    local frame = CreateFrame("Frame", name, parent, "BackdropTemplate")
    frame:Hide()
    -- frame:SetSize(11, 11)
    frame:SetBackdrop({bgFile = Cell.vars.whiteTexture})
    frame:SetBackdropColor(0, 0, 0, 1)

    local icon = frame:CreateTexture(name.."Icon", "ARTWORK")
    frame.icon = icon
    -- icon:SetTexCoord(0.12, 0.88, 0.12, 0.88)
    P.Point(icon, "TOPLEFT", frame, "TOPLEFT", CELL_BORDER_SIZE, -CELL_BORDER_SIZE)
    P.Point(icon, "BOTTOMRIGHT", frame, "BOTTOMRIGHT", -CELL_BORDER_SIZE, CELL_BORDER_SIZE)
    -- icon:SetDrawLayer("ARTWORK", 1)

    frame.stack = frame:CreateFontString(nil, "OVERLAY", "CELL_FONT_STATUS")
    frame.duration = frame:CreateFontString(nil, "OVERLAY", "CELL_FONT_STATUS")

    local ag = frame:CreateAnimationGroup()
    frame.ag = ag
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

    frame.SetFont = Shared_SetFont
    frame.SetCooldown = BarIcon_SetCooldown
    frame.ShowDuration = Shared_ShowDuration
    frame.ShowStack = Shared_ShowStack
    frame.ShowAnimation = BarIcon_ShowAnimation
    frame.UpdatePixelPerfect = BarIcon_UpdatePixelPerfect

    Shared_SetCooldownStyle(frame, CELL_COOLDOWN_STYLE)

    frame:SetScript("OnSizeChanged", ReCalcTexCoord)

    -- frame:SetScript("OnEnter", function()
        -- local f = frame
        -- repeat
        --     f = f:GetParent()
        -- until f:IsObjectType("button")
        -- f:GetScript("OnEnter")(f)
    -- end)

    return frame
end

-------------------------------------------------
-- CreateAura_Icons
-------------------------------------------------
local function Icons_UpdateSize(icons, numAuras)
    if not (icons.width and icons.orientation) then return end -- not init

    if numAuras then -- call from I.CheckCustomIndicators or preview
        for i = numAuras + 1, icons.maxNum do
            icons[i]:Hide()
        end
    else
        numAuras = 0
        for i = 1, icons.maxNum do
            if icons[i]:IsShown() then
                numAuras = i
            else
                break
            end
        end
    end

    -- set size
    local lines = ceil(numAuras / icons.numPerLine)
    numAuras = min(numAuras, icons.numPerLine)

    if icons.isHorizontal then
        P.SetGridSize(icons, icons.width, icons.height, icons.spacingX, icons.spacingY, numAuras, lines)
    else
        P.SetGridSize(icons, icons.width, icons.height, icons.spacingX, icons.spacingY, lines, numAuras)
    end
end

local function Icons_SetNumPerLine(icons, numPerLine)
    icons.numPerLine = min(numPerLine, icons.maxNum)


    if icons.orientation then
        icons:SetOrientation(icons.orientation)
    -- else
    --     icons:UpdateSize()
    end
end

local function Icons_SetOrientation(icons, orientation)
    icons.orientation = orientation

    local anchor = icons:GetPoint()
    assert(anchor, "[indicator] SetPoint must be called before SetOrientation")

    icons.isHorizontal = not strfind(orientation, "top")

    local point1, point2, x, y
    local newLinePoint2, newLineX, newLineY

    if orientation == "left-to-right" then
        if strfind(anchor, "^BOTTOM") then
            point1 = "BOTTOMLEFT"
            point2 = "BOTTOMRIGHT"
            newLinePoint2 = "TOPLEFT"
            y = 0
            newLineY = icons.spacingY
        else
            point1 = "TOPLEFT"
            point2 = "TOPRIGHT"
            newLinePoint2 = "BOTTOMLEFT"
            y = 0
            newLineY = -icons.spacingY
        end
        x = icons.spacingX
        newLineX = 0

    elseif orientation == "right-to-left" then
        if strfind(anchor, "^BOTTOM") then
            point1 = "BOTTOMRIGHT"
            point2 = "BOTTOMLEFT"
            newLinePoint2 = "TOPRIGHT"
            y = 0
            newLineY = icons.spacingY
        else
            point1 = "TOPRIGHT"
            point2 = "TOPLEFT"
            newLinePoint2 = "BOTTOMRIGHT"
            y = 0
            newLineY = -icons.spacingY
        end
        x = -icons.spacingX
        newLineX = 0

    elseif orientation == "top-to-bottom" then
        if strfind(anchor, "RIGHT$") then
            point1 = "TOPRIGHT"
            point2 = "BOTTOMRIGHT"
            newLinePoint2 = "TOPLEFT"
            x = 0
            newLineX = -icons.spacingX
        else
            point1 = "TOPLEFT"
            point2 = "BOTTOMLEFT"
            newLinePoint2 = "TOPRIGHT"
            x = 0
            newLineX = icons.spacingX
        end
        y = -icons.spacingY
        newLineY = 0

    elseif orientation == "bottom-to-top" then
        if strfind(anchor, "RIGHT$") then
            point1 = "BOTTOMRIGHT"
            point2 = "TOPRIGHT"
            newLinePoint2 = "BOTTOMLEFT"
            x = 0
            newLineX = -icons.spacingX
        else
            point1 = "BOTTOMLEFT"
            point2 = "TOPLEFT"
            newLinePoint2 = "BOTTOMRIGHT"
            x = 0
            newLineX = icons.spacingX
        end
        y = icons.spacingY
        newLineY = 0
    end

    for i = 1, icons.maxNum do
        P.ClearPoints(icons[i])
        if i == 1 then
            P.Point(icons[i], point1)
        elseif i % icons.numPerLine == 1 then
            P.Point(icons[i], point1, icons[i-icons.numPerLine], newLinePoint2, newLineX, newLineY)
        else
            P.Point(icons[i], point1, icons[i-1], point2, x, y)
        end
    end

    icons:UpdateSize()
end

local function Icons_SetSize(icons, width, height)
    icons.width = width
    icons.height = height

    for i = 1, icons.maxNum do
        icons[i]:SetSize(width, height)
        --! width & height P.Scaled
        icons[i].width = nil
        icons[i].height = nil
    end

    icons:UpdateSize()
end

local function Icons_SetSpacing(icons, spacing)
    icons.spacingX = spacing[1]
    icons.spacingY = spacing[2]

    if icons.orientation then
        icons:SetOrientation(icons.orientation)
    end
end

local function Icons_Hide(icons, hideAll)
    icons:_Hide()
    if hideAll then
        for i = 1, icons.maxNum do
            icons[i]:Hide()
        end
    end
end

local function Icons_SetFont(icons, ...)
    for i = 1, icons.maxNum do
        icons[i]:SetFont(...)
    end
end

local function Icons_ShowDuration(icons, show)
    for i = 1, icons.maxNum do
        icons[i]:ShowDuration(show)
    end
end

local function Icons_ShowStack(icons, show)
    for i = 1, icons.maxNum do
        icons[i]:ShowStack(show)
    end
end

local function Icons_ShowAnimation(icons, show)
    for i = 1, icons.maxNum do
        icons[i]:ShowAnimation(show)
    end
end

local function Icons_UpdatePixelPerfect(icons)
    P.Repoint(icons)
    P.Resize(icons)
    for i = 1, icons.maxNum do
        icons[i]:UpdatePixelPerfect()
    end
end

function I.CreateAura_Icons(name, parent, num)
    local icons = CreateFrame("Frame", name, parent)
    icons:Hide()

    icons.indicatorType = "icons"
    icons.maxNum = num
    icons.numPerLine = num
    icons.spacingX = 0
    icons.spacingY = 0

    icons._SetSize = icons.SetSize
    icons.SetSize = Icons_SetSize
    icons._Hide = icons.Hide
    icons.Hide = Icons_Hide
    icons.SetFont = Icons_SetFont
    icons.UpdateSize = Icons_UpdateSize
    icons.SetOrientation = Icons_SetOrientation
    icons.SetSpacing = Icons_SetSpacing
    icons.SetNumPerLine = Icons_SetNumPerLine
    icons.ShowDuration = Icons_ShowDuration
    icons.ShowStack = Icons_ShowStack
    icons.ShowAnimation = Icons_ShowAnimation
    icons.UpdatePixelPerfect = Icons_UpdatePixelPerfect

    for i = 1, num do
        local name = name.."Icon"..i
        local frame = I.CreateAura_BarIcon(name, icons)
        icons[i] = frame
    end

    return icons
end

-------------------------------------------------
-- CreateAura_Text
-------------------------------------------------
local function Text_SetFont(frame, font, size, outline, shadow)
    font = F.GetFont(font)

    local flags
    if outline == "None" then
        flags = ""
    elseif outline == "Outline" then
        flags = "OUTLINE"
    else
        flags = "OUTLINE,MONOCHROME"
    end

    frame.text:SetFont(font, size, flags)

    if shadow then
        frame.text:SetShadowOffset(1, -1)
        frame.text:SetShadowColor(0, 0, 0, 1)
    else
        frame.text:SetShadowOffset(0, 0)
        frame.text:SetShadowColor(0, 0, 0, 0)
    end

    frame:SetSize(size, size)
end

local function Text_SetPoint(frame, point, relativeTo, relativePoint, x, y)
    frame.text:ClearAllPoints()
    frame.text:SetPoint(point)
    frame:_SetPoint(point, relativeTo, relativePoint, x, y)
    I.JustifyText(frame.text, point)
end

local function Text_SetDuration(frame, durationTbl)
    frame.durationTbl = durationTbl
end

local function Text_SetStack(frame, stack)
    frame.showStack = stack[1]
    frame.circledStackNums = stack[2]
end

local function Text_SetColors(frame, colors)
    frame.state = nil
    frame.colors = colors
end

local function Text_OnUpdateColor(frame)
    if frame.colors[3][1] and frame._remain <= frame.colors[3][2] then
        if frame.state ~= 3 then
            frame.state = 3
            frame.text:SetTextColor(frame.colors[3][3][1], frame.colors[3][3][2], frame.colors[3][3][3], frame.colors[3][3][4])
        end
    elseif frame.colors[2][1] and frame._remain <= frame._duration * frame.colors[2][2] then
        if frame.state ~= 2 then
            frame.state = 2
            frame.text:SetTextColor(frame.colors[2][3][1], frame.colors[2][3][2], frame.colors[2][3][3], frame.colors[2][3][4])
        end
    elseif frame.state ~= 1 then
        frame.state = 1
        frame.text:SetTextColor(frame.colors[1][1], frame.colors[1][2], frame.colors[1][3], frame.colors[1][4])
    end
end

local function Text_OnUpdateDuration(frame, elapsed)
    frame._remain = frame._duration - (GetTime() - frame._start)
    if frame._remain < 0 then frame._remain = 0 end

    frame._elapsed = frame._elapsed + elapsed
    if frame._elapsed >= 0.1 then
        frame._elapsed = 0
        -- color
        Text_OnUpdateColor(frame)
    end

    -- format
    if frame._remain > 60 then
        frame.text:SetFormattedText(frame._count.."%dm", frame._remain/60)
    else
        if frame.durationTbl[2] then
            frame.text:SetFormattedText(frame._count.."%d", ceil(frame._remain))
        else
            if frame._remain < frame.durationTbl[3] then
                frame.text:SetFormattedText(frame._count.."%.1f", frame._remain)
            else
                frame.text:SetFormattedText(frame._count.."%d", frame._remain)
            end
        end
    end
end

local function Text_OnUpdate(frame, elapsed)
    frame._elapsed = frame._elapsed + elapsed
    if frame._elapsed >= 0.1 then
        frame._elapsed = 0

        frame._remain = frame._duration - (GetTime() - frame._start)
        -- update color
        Text_OnUpdateColor(frame)
    end
end

local circled = {"①","②","③","④","⑤","⑥","⑦","⑧","⑨","⑩","⑪","⑫","⑬","⑭","⑮","⑯","⑰","⑱","⑲","⑳","㉑","㉒","㉓","㉔","㉕","㉖","㉗","㉘","㉙","㉚","㉛","㉜","㉝","㉞","㉟","㊱","㊲","㊳","㊴","㊵","㊶","㊷","㊸","㊹","㊺","㊻","㊼","㊽","㊾","㊿"}
local function Text_SetCooldown(frame, start, duration, debuffType, texture, count)
    if duration == 0 then
        -- always show stack
        count = count == 0 and 1 or count
        count = frame.circledStackNums and circled[count] or count
        frame.text:SetText(count)
        frame.text:SetTextColor(frame.colors[1][1], frame.colors[1][2], frame.colors[1][3], frame.colors[1][4])
        frame:SetScript("OnUpdate", nil)
        frame._count = nil
        frame._start = nil
        frame._duration = nil
        frame._remain = nil
        frame._elapsed = nil
    else
        frame._start = start
        frame._duration = duration

        if frame.durationTbl[1] then
            if frame.showStack and count ~= 0 then
                if frame.circledStackNums then
                    frame._count = circled[count].." "
                else
                    frame._count = count.." "
                end
            else
                frame._count = ""
            end

            frame._elapsed = 0.1 -- update immediately
            frame:SetScript("OnUpdate", Text_OnUpdateDuration)
        else
            -- always show stack
            count = count == 0 and 1 or count
            if frame.circledStackNums then
                frame.text:SetText(circled[count])
            else
                frame.text:SetText(count)
            end

            frame._elapsed = 0.1 -- update immediately
            frame:SetScript("OnUpdate", Text_OnUpdate)
        end
    end

    frame:Show()
end

function I.CreateAura_Text(name, parent)
    local frame = CreateFrame("Frame", name, parent)
    frame:Hide()
    frame.indicatorType = "text"

    local text = frame:CreateFontString(nil, "OVERLAY", "CELL_FONT_STATUS")
    frame.text = text
    text:SetPoint("CENTER", 1, 0)

    frame.SetFont = Text_SetFont
    frame._SetPoint = frame.SetPoint
    frame.SetPoint = Text_SetPoint
    frame.SetCooldown = Text_SetCooldown
    frame.SetDuration = Text_SetDuration
    frame.SetStack = Text_SetStack
    frame.SetColors = Text_SetColors

    return frame
end

-------------------------------------------------
-- CreateAura_Rect
-------------------------------------------------
local function Rect_SetFont(frame, font1, font2)
    I.SetFont(frame.stack, frame, unpack(font1))
    I.SetFont(frame.duration, frame, unpack(font2))
end

local function Rect_OnUpdateColor(frame)
    if frame.colors[3][1] and frame._remain <= frame.colors[3][2] then
        if frame.state ~= 3 then
            frame.state = 3
            frame.tex:SetColorTexture(frame.colors[3][3][1], frame.colors[3][3][2], frame.colors[3][3][3], frame.colors[3][3][4])
        end
    elseif frame.colors[2][1] and frame._remain <= frame._duration * frame.colors[2][2] then
        if frame.state ~= 2 then
            frame.state = 2
            frame.tex:SetColorTexture(frame.colors[2][3][1], frame.colors[2][3][2], frame.colors[2][3][3], frame.colors[2][3][4])
        end
    elseif frame.state ~= 1 then
        frame.state = 1
        frame.tex:SetColorTexture(frame.colors[1][1], frame.colors[1][2], frame.colors[1][3], frame.colors[1][4])
    end
end

local function Rect_OnUpdate(frame, elapsed)
    frame._remain = frame._duration - (GetTime() - frame._start)
    if frame._remain < 0 then frame._remain = 0 end

    frame._elapsed = frame._elapsed + elapsed
    if frame._elapsed >= 0.1 then
        frame._elapsed = 0
        -- update color
        Rect_OnUpdateColor(frame)
    end

    if frame._remain > frame._threshold then
        frame.duration:SetText("")
        return
    end

    -- format
    if frame._remain > 60 then
        frame.duration:SetFormattedText("%dm", frame._remain / 60)
    else
        if Cell.vars.iconDurationRoundUp then
            frame.duration:SetFormattedText("%d", ceil(frame._remain))
        else
            if frame._remain < Cell.vars.iconDurationDecimal then
                frame.duration:SetFormattedText("%.1f", frame._remain)
            else
                frame.duration:SetFormattedText("%d", frame._remain)
            end
        end
    end
end

local function Rect_SetCooldown(frame, start, duration, debuffType, texture, count)
    if duration == 0 then
        frame.tex:SetColorTexture(unpack(frame.colors[1]))
        frame:SetScript("OnUpdate", nil)
        frame.duration:Hide()
        frame._start = nil
        frame._duration = nil
        frame._remain = nil
        frame._elapsed = nil
        frame._threshold = nil
    else
        if not frame.showDuration then
            frame._threshold = -1
            frame.duration:Hide()
        else
            if frame.showDuration == true then
                frame._threshold = duration
            elseif frame.showDuration >= 1 then
                frame._threshold = frame.showDuration
            else -- < 1
                frame._threshold = frame.showDuration * duration
            end
            frame.duration:Show()
        end

        frame._start = start
        frame._duration = duration
        frame._elapsed = 0.1 -- update immediately
        frame:SetScript("OnUpdate", Rect_OnUpdate)
    end

    frame.stack:SetText((count == 0 or count == 1) and "" or count)
    frame:Show()
end

local function Rect_SetColors(frame, colors)
    frame.state = nil
    frame.colors = colors
    frame:SetBackdropBorderColor(colors[4][1], colors[4][2], colors[4][3], colors[4][4])
end

local function Rect_UpdatePixelPerfect(frame)
    P.Resize(frame)
    P.Reborder(frame)
    P.Repoint(frame)
end

function I.CreateAura_Rect(name, parent)
    local frame = CreateFrame("Frame", name, parent, "BackdropTemplate")
    frame:Hide()
    frame.indicatorType = "rect"
    frame:SetBackdrop({edgeFile=Cell.vars.whiteTexture, edgeSize=P.Scale(1)})
    frame:SetBackdropBorderColor(0, 0, 0, 1)

    local tex = frame:CreateTexture(nil, "BORDER", nil, -7)
    frame.tex = tex
    tex:SetAllPoints()

    frame.stack = frame:CreateFontString(nil, "OVERLAY", "CELL_FONT_STATUS")
    frame.duration = frame:CreateFontString(nil, "OVERLAY", "CELL_FONT_STATUS")

    frame.SetFont = Rect_SetFont
    frame.SetCooldown = Rect_SetCooldown
    frame.SetColors = Rect_SetColors
    frame.ShowStack = Shared_ShowStack
    frame.ShowDuration = Shared_ShowDuration
    frame.UpdatePixelPerfect = Rect_UpdatePixelPerfect

    return frame
end

-------------------------------------------------
-- CreateAura_Bar
-------------------------------------------------
local function Bar_SetFont(bar, font1, font2)
    I.SetFont(bar.stack, bar, unpack(font1))
    I.SetFont(bar.duration, bar, unpack(font2))
end

local function Bar_OnUpdate(bar, elapsed)
    bar._remain = bar._duration - (GetTime() - bar._start)
    if bar._remain < 0 then bar._remain = 0 end
    bar:SetValue(bar._remain)

    bar._elapsed = bar._elapsed + elapsed
    if bar._elapsed >= 0.1 then
        bar._elapsed = 0
        -- update color
        if bar.colors[3][1] and bar._remain <= bar.colors[3][2] then
            if bar.state ~= 3 then
                bar.state = 3
                bar:SetStatusBarColor(bar.colors[3][3][1], bar.colors[3][3][2], bar.colors[3][3][3], bar.colors[3][3][4])
            end
        elseif bar.colors[2][1] and bar._remain <= bar._duration * bar.colors[2][2] then
            if bar.state ~= 2 then
                bar.state = 2
                bar:SetStatusBarColor(bar.colors[2][3][1], bar.colors[2][3][2], bar.colors[2][3][3], bar.colors[2][3][4])
            end
        elseif bar.state ~= 1 then
            bar.state = 1
            bar:SetStatusBarColor(bar.colors[1][1], bar.colors[1][2], bar.colors[1][3], bar.colors[1][4])
        end
    end

    if bar._remain > bar._threshold then
        bar.duration:SetText("")
        return
    end

    -- format
    if bar._remain > 60 then
        bar.duration:SetFormattedText("%dm", bar._remain / 60)
    else
        if Cell.vars.iconDurationRoundUp then
            bar.duration:SetFormattedText("%d", ceil(bar._remain))
        else
            if bar._remain < Cell.vars.iconDurationDecimal then
                bar.duration:SetFormattedText("%.1f", bar._remain)
            else
                bar.duration:SetFormattedText("%d", bar._remain)
            end
        end
    end
end

local function Bar_SetCooldown(bar, start, duration, debuffType, texture, count)
    if duration == 0 then
        bar:SetScript("OnUpdate", nil)
        bar.duration:Hide()
        bar:SetMinMaxValues(0, 1)
        bar:SetValue(1)
        bar._start = nil
        bar._duration = nil
        bar._threshold = nil
        bar._remain = nil
        bar._elapsed = nil
    else
        if not bar.showDuration then
            bar._threshold = -1
            bar.duration:Hide()
        else
            if bar.showDuration == true then
                bar._threshold = duration
            elseif bar.showDuration >= 1 then
                bar._threshold = bar.showDuration
            else -- < 1
                bar._threshold = bar.showDuration * duration
            end
            bar.duration:Show()
        end

        bar:SetMinMaxValues(0, duration)
        bar._start = start
        bar._duration = duration
        bar._elapsed = 0.1 -- update immediately
        bar:SetScript("OnUpdate", Bar_OnUpdate)
    end

    bar.stack:SetText((count == 0 or count == 1) and "" or count)
    bar:Show()
end

local function Bar_SetColors(bar, colors)
    bar:SetBackdropBorderColor(colors[4][1], colors[4][2], colors[4][3], colors[4][4])
    bar:SetBackdropColor(colors[5][1], colors[5][2], colors[5][3], colors[5][4])
    bar.state = nil
    bar.colors = colors
end

function I.CreateAura_Bar(name, parent)
    local bar = Cell.CreateStatusBar(name, parent, 18, 4, 100)
    bar:Hide()
    bar.indicatorType = "bar"

    bar.stack = bar:CreateFontString(nil, "OVERLAY", "CELL_FONT_STATUS")
    bar.duration = bar:CreateFontString(nil, "OVERLAY", "CELL_FONT_STATUS")

    bar.SetFont = Bar_SetFont
    bar.SetCooldown = Bar_SetCooldown
    bar.ShowStack = Shared_ShowStack
    bar.ShowDuration = Shared_ShowDuration
    bar.SetColors = Bar_SetColors

    return bar
end

-------------------------------------------------
-- CreateAura_Bars
-------------------------------------------------
local function Bars_OnUpdate(bar, elapsed)
    bar._remain = bar._duration - (GetTime() - bar._start)
    if bar._remain < 0 then bar._remain = 0 end
    bar:SetValue(bar._remain)

    if bar._remain > bar._threshold then
        bar.duration:SetText("")
        return
    end

    -- format
    if bar._remain > 60 then
        bar.duration:SetFormattedText("%dm", bar._remain / 60)
    else
        if Cell.vars.iconDurationRoundUp then
            bar.duration:SetFormattedText("%d", ceil(bar._remain))
        else
            if bar._remain < Cell.vars.iconDurationDecimal then
                bar.duration:SetFormattedText("%.1f", bar._remain)
            else
                bar.duration:SetFormattedText("%d", bar._remain)
            end
        end
    end
end

local function Bars_SetCooldown(bar, start, duration, debuffType, texture, count, refreshing, color)
    if duration == 0 then
        bar:SetScript("OnUpdate", nil)
        bar:SetMinMaxValues(0, 1)
        bar:SetValue(1)
        bar.duration:Hide()
        bar._start = nil
        bar._duration = nil
        bar._remain = nil
        bar._threshold = nil
    else
        if not bar.showDuration then
            bar._threshold = -1
            bar.duration:Hide()
        else
            if bar.showDuration == true then
                bar._threshold = duration
            elseif bar.showDuration >= 1 then
                bar._threshold = bar.showDuration
            else -- < 1
                bar._threshold = bar.showDuration * duration
            end
            bar.duration:Show()
        end

        if bar.parent.maxValue then
            bar:SetMinMaxValues(0, bar.parent.allowSmaller and min(bar.parent.maxValue, duration) or bar.parent.maxValue)
        else
            bar:SetMinMaxValues(0, duration)
        end
        bar._start = start
        bar._duration = duration
        bar:SetScript("OnUpdate", Bars_OnUpdate)
    end

    bar:SetStatusBarColor(color[1], color[2], color[3], color[4])
    bar:SetBackdropColor(color[1] * 0.2, color[2] * 0.2, color[3] * 0.2, color[4])
    bar.stack:SetText((count == 0 or count == 1) and "" or count)
    bar:Show()
end

local function Bars_SetMaxValue(bars, maxValue)
    if maxValue[1] == 0 then
        bars.maxValue = nil
        bars.allowSmaller = nil
    else
        bars.maxValue = maxValue[1]
        bars.allowSmaller = maxValue[2]
    end
end

function I.CreateAura_Bars(name, parent, num)
    local bars = CreateFrame("Frame", name, parent)
    bars:Hide()

    bars.indicatorType = "bars"
    bars.maxNum = num
    bars.numPerLine = num

    bars._SetSize = bars.SetSize
    bars.SetSize = Icons_SetSize
    bars._Hide = bars.Hide
    bars.Hide = Icons_Hide
    bars.SetFont = Icons_SetFont
    bars.UpdateSize = Icons_UpdateSize
    bars.SetOrientation = Icons_SetOrientation
    bars.SetSpacing = Icons_SetSpacing
    bars.SetNumPerLine = Icons_SetNumPerLine
    bars.ShowDuration = Icons_ShowDuration
    bars.ShowStack = Icons_ShowStack
    bars.SetMaxValue = Bars_SetMaxValue
    bars.UpdatePixelPerfect = Icons_UpdatePixelPerfect

    for i = 1, num do
        local name = name.."Icons"..i
        local frame = I.CreateAura_Bar(name, bars)
        bars[i] = frame
        frame.parent = bars
        frame.SetCooldown = Bars_SetCooldown
        frame:SetBackdropBorderColor(0, 0, 0, 1)
    end

    return bars
end

-------------------------------------------------
-- CreateAura_Color
-------------------------------------------------
local function Color_OnUpdate(color, elapsed)
    color._elapsed = color._elapsed + elapsed
    if color._elapsed >= 0.1 then
        color._elapsed = 0

        color._remain = color._duration - (GetTime() - color._start)
        -- update color
        if color._remain <= color.colors[6][1] then
            if color.state ~= 3 then
                color.state = 3
                color.solidTex:SetVertexColor(color.colors[6][2][1], color.colors[6][2][2], color.colors[6][2][3], color.colors[6][2][4])
            end
        elseif color._remain <= color._duration * color.colors[5][1] then
            if color.state ~= 2 then
                color.state = 2
                color.solidTex:SetVertexColor(color.colors[5][2][1], color.colors[5][2][2], color.colors[5][2][3], color.colors[5][2][4])
            end
        elseif color.state ~= 1 then
            color.state = 1
            color.solidTex:SetVertexColor(color.colors[4][1], color.colors[4][2], color.colors[4][3], color.colors[4][4])
        end
    end
end

local function Color_SetCooldown(color, start, duration, debuffType)
    if color.type == "change-over-time" then
        if duration == 0 then
            color.solidTex:SetVertexColor(unpack(color.colors[4]))
            color:SetScript("OnUpdate", nil)
            color._start = nil
            color._duration = nil
            color._remain = nil
            color._elapsed = nil
        else
            color._start = start
            color._duration = duration
            color._elapsed = 0.1 -- update immediately
            color:SetScript("OnUpdate", Color_OnUpdate)
        end
    elseif color.type == "class-color" then
        color.solidTex:SetVertexColor(F.GetClassColor(color.parent.states.class))
    elseif color.type == "debuff-type" and debuffType then
        color.solidTex:SetVertexColor(CellDB["debuffTypeColor"][debuffType]["r"], CellDB["debuffTypeColor"][debuffType]["g"], CellDB["debuffTypeColor"][debuffType]["b"], 1)
    end
    color:Show()
end

-- +6 ~ +55
local function Color_SetFrameLevel(color, frameLevel)
    color:_SetFrameLevel(frameLevel + 5)
end

local function Color_SetAnchor(color, anchorTo)
    color:ClearAllPoints()
    if anchorTo == "healthbar-current" then
        -- current hp texture
        color:SetAllPoints(color.parent.widgets.healthBar:GetStatusBarTexture())
    elseif anchorTo == "healthbar-loss" then
        -- lost texture
        color:SetAllPoints(color.parent.widgets.healthBarLoss)
    elseif anchorTo == "healthbar-entire" then
        -- entire hp bar
        color:SetAllPoints(color.parent.widgets.healthBar)
    else -- unitbutton
        P.Point(color, "TOPLEFT", color.parent, "TOPLEFT", CELL_BORDER_SIZE, -CELL_BORDER_SIZE)
        P.Point(color, "BOTTOMRIGHT", color.parent, "BOTTOMRIGHT", -CELL_BORDER_SIZE, CELL_BORDER_SIZE)
    end

    -- color:SetFrameLevel(color:GetParent():GetFrameLevel() + color.configs.frameLevel)
end

local function Color_SetColors(self, colors)
    self.state = nil
    self.type = colors[1]
    self.colors = colors

    if colors[1] == "solid" then
        self:SetScript("OnUpdate", nil)
        self.solidTex:SetVertexColor(colors[2][1], colors[2][2], colors[2][3], colors[2][4])
        self.solidTex:Show()
        self.gradientTex:Hide()
    elseif colors[1] == "gradient-vertical" then
        self:SetScript("OnUpdate", nil)
        self.gradientTex:SetGradient("VERTICAL", CreateColor(colors[2][1], colors[2][2], colors[2][3], colors[2][4]), CreateColor(colors[3][1], colors[3][2], colors[3][3], colors[3][4]))
        self.gradientTex:Show()
        self.solidTex:Hide()
    elseif colors[1] == "gradient-horizontal" then
        self:SetScript("OnUpdate", nil)
        self.gradientTex:SetGradient("HORIZONTAL", CreateColor(colors[2][1], colors[2][2], colors[2][3], colors[2][4]), CreateColor(colors[3][1], colors[3][2], colors[3][3], colors[3][4]))
        self.gradientTex:Show()
        self.solidTex:Hide()
    elseif colors[1] == "debuff-type" then
        self:SetScript("OnUpdate", nil)
        self.solidTex:SetVertexColor(colors[2][1], colors[2][2], colors[2][3], colors[2][4])
        self.solidTex:Show()
        self.gradientTex:Hide()
    elseif colors[1] == "change-over-time" then
        self.solidTex:SetVertexColor(colors[4][1], colors[4][2], colors[4][3], colors[4][4])
        self.solidTex:Show()
        self.gradientTex:Hide()
    elseif colors[1] == "class-color" then
        self:SetScript("OnUpdate", nil)
        self.solidTex:Show()
        self.gradientTex:Hide()
    end
end

function I.CreateAura_Color(name, parent)
    local color = CreateFrame("Frame", name, parent)
    color:Hide()
    color.indicatorType = "color"
    color.parent = parent

    local solidTex = color:CreateTexture(nil, "ARTWORK")
    color.solidTex = solidTex
    solidTex:SetTexture(Cell.vars.texture)
    solidTex:SetAllPoints(color)
    solidTex:Hide()

    solidTex:SetScript("OnShow", function()
        -- update texture
        solidTex:SetTexture(Cell.vars.texture)
    end)

    local gradientTex = color:CreateTexture(nil, "ARTWORK")
    color.gradientTex = gradientTex
    gradientTex:SetTexture(Cell.vars.whiteTexture)
    gradientTex:SetAllPoints(color)
    gradientTex:Hide()

    color.SetCooldown = Color_SetCooldown
    color._SetFrameLevel = color.SetFrameLevel
    color.SetFrameLevel = Color_SetFrameLevel
    color.SetAnchor = Color_SetAnchor
    color.SetColors = Color_SetColors

    return color
end

-------------------------------------------------
-- CreateAura_Texture
-------------------------------------------------
local function Texture_OnUpdate(texture, elapsed)
    texture._elapsed = texture._elapsed + elapsed
    if texture._elapsed >= 0.1 then
        texture._elapsed = 0

        texture._remain = texture._duration - (GetTime() - texture._start)
        if texture._remain < 0 then texture._remain = 0 end
        texture.tex:SetAlpha(texture._remain / texture._duration * 0.9 + 0.1)
    end
end

local function Texture_SetCooldown(texture, start, duration)
    if duration ~= 0 and texture.fadeOut then
        texture._start = start
        texture._duration = duration
        texture._elapsed = 0.1 -- update immediately
        texture:SetScript("OnUpdate", Texture_OnUpdate)
    else
        texture:SetScript("OnUpdate", nil)
        texture.tex:SetAlpha(texture.colorAlpha)
        texture._start = nil
        texture._duration = nil
        texture._remain = nil
        texture._elapsed = nil
    end
    texture:Show()
end

local function Texture_SetFadeOut(texture, fadeOut)
    texture.fadeOut = fadeOut
end

local function Texture_SetTexture(texture, texTbl) -- texture, rotation, color
    if strfind(strlower(texTbl[1]), "^interface") then
        texture.tex:SetTexture(texTbl[1])
    else
        texture.tex:SetAtlas(texTbl[1])
    end
    texture.tex:SetRotation(texTbl[2] * math.pi / 180)
    texture.tex:SetVertexColor(unpack(texTbl[3]))
    texture.colorAlpha = texTbl[3][4]
end

function I.CreateAura_Texture(name, parent)
    local texture = CreateFrame("Frame", name, parent)
    texture:Hide()
    texture.indicatorType = "texture"

    local tex = texture:CreateTexture(name, "OVERLAY")
    texture.tex = tex
    tex:SetAllPoints(texture)

    texture.SetCooldown = Texture_SetCooldown
    texture.SetFadeOut = Texture_SetFadeOut
    texture.SetTexture = Texture_SetTexture

    return texture
end

-------------------------------------------------
-- CreateAura_Glow
-------------------------------------------------
local function Glow_OnUpdate(glow, elapsed)
    glow._elapsed = glow._elapsed + elapsed
    if glow._elapsed >= 0.1 then
        glow._elapsed = 0

        glow._remain = glow._duration - (GetTime() - glow._start)
        if glow._remain < 0 then glow._remain = 0 end
        glow:SetAlpha(glow._remain / glow._duration * 0.9 + 0.1)
    end
end

local function Glow_SetCooldown(glow, start, duration)
    if glow.fadeOut and duration ~= 0 then
        glow._start = start
        glow._duration = duration
        glow._elapsed = 0.1 -- update immediately
        glow:SetScript("OnUpdate", Glow_OnUpdate)
    else
        glow:SetScript("OnUpdate", nil)
        glow:SetAlpha(1)
        glow._start = nil
        glow._duration = nil
        glow._remain = nil
        glow._elapsed = nil
    end

    glow:Show()

    local glowOptions = glow.glowOptions
    local glowType = glowOptions[1]

    if glowType == "Normal" then
        LCG.PixelGlow_Stop(glow)
        LCG.AutoCastGlow_Stop(glow)
        LCG.ProcGlow_Stop(glow)
        LCG.ButtonGlow_Start(glow, glowOptions[2])
    elseif glowType == "Pixel" then
        LCG.ButtonGlow_Stop(glow)
        LCG.AutoCastGlow_Stop(glow)
        LCG.ProcGlow_Stop(glow)
        -- color, N, frequency, length, thickness
        LCG.PixelGlow_Start(glow, glowOptions[2], glowOptions[3], glowOptions[4], glowOptions[5], glowOptions[6])
    elseif glowType == "Shine" then
        LCG.ButtonGlow_Stop(glow)
        LCG.PixelGlow_Stop(glow)
        LCG.ProcGlow_Stop(glow)
        -- color, N, frequency, scale
        LCG.AutoCastGlow_Start(glow, glowOptions[2], glowOptions[3], glowOptions[4], glowOptions[5])
    elseif glowType == "Proc" then
        LCG.ButtonGlow_Stop(glow)
        LCG.PixelGlow_Stop(glow)
        LCG.AutoCastGlow_Stop(glow)
        -- color, duration
        LCG.ProcGlow_Start(glow, {color=glowOptions[2], duration=glowOptions[3], startAnim=false})
    else
        LCG.ButtonGlow_Stop(glow)
        LCG.PixelGlow_Stop(glow)
        LCG.AutoCastGlow_Stop(glow)
        LCG.ProcGlow_Stop(glow)
        glow:Hide()
    end
end

function I.CreateAura_Glow(name, parent)
    local glow = CreateFrame("Frame", name, parent)
    glow:SetAllPoints(parent)
    glow:Hide()
    glow.indicatorType = "glow"

    glow.SetCooldown = Glow_SetCooldown

    function glow:SetFadeOut(fadeOut)
        glow.fadeOut = fadeOut
    end

    function glow:UpdateGlowOptions(options)
        glow.glowOptions = options
    end

    -- glow:SetScript("OnHide", function()
    --     LCG.ButtonGlow_Stop(glow)
    --     LCG.PixelGlow_Stop(glow)
    --     LCG.AutoCastGlow_Stop(glow)
    --     LCG.ProcGlow_Stop(glow)
    -- end)

    return glow
end

-------------------------------------------------
-- CreateAura_QuickAssistBars
-------------------------------------------------
local function QuickAssistBars_OnUpdate(bar, elapsed)
    bar._remain = bar._duration - (GetTime() - bar._start)
    if bar._remain < 0 then bar._remain = 0 end
    bar:SetValue(bar._remain)
end

local function QuickAssistBars_SetCooldown(bar, start, duration, color)
    if duration == 0 then
        bar:SetScript("OnUpdate", nil)
        bar:SetMinMaxValues(0, 1)
        bar:SetValue(1)
        bar._start = nil
        bar._duration = nil
        bar._remain = nil
    else
        bar._start = start
        bar._duration = duration
        bar:SetMinMaxValues(0, duration)
        bar:SetScript("OnUpdate", QuickAssistBars_OnUpdate)
    end

    bar:SetStatusBarColor(color[1], color[2], color[3], 1)
    bar:Show()
end

local function QuickAssistBars_UpdateSize(bars, barsShown)
    if not (bars.width and bars.height) then return end -- not init
    if barsShown then -- call from I.CheckCustomIndicators or preview
        for i = barsShown + 1, bars.num do
            bars[i]:Hide()
        end
        if barsShown ~= 0 then
            bars:_SetSize(bars.width, bars.height*barsShown-P.Scale(1)*(barsShown-1))
        end
    else
        for i = 1, bars.num do
            if bars[i]:IsShown() then
                bars:_SetSize(bars.width, bars.height*i-P.Scale(1)*(i-1))
            else
                break
            end
        end
    end
end

local function QuickAssistBars_SetSize(bars, width, height)
    bars.width = width
    bars.height = height

    for i = 1, bars.num do
        bars[i]:SetSize(width, height)
    end

    bars:UpdateSize()
end

local function QuickAssistBars_SetOrientation(bars, orientation)
    local point1, point2, offset
    if orientation == "top-to-bottom" then
        point1 = "TOPLEFT"
        point2 = "BOTTOMLEFT"
        offset = 1
    elseif orientation == "bottom-to-top" then
        point1 = "BOTTOMLEFT"
        point2 = "TOPLEFT"
        offset = -1
    end

    for i = 1, bars.num do
        P.ClearPoints(bars[i])
        if i == 1 then
            P.Point(bars[i], point1)
        else
            P.Point(bars[i], point1, bars[i-1], point2, 0, offset)
        end
    end

    bars:UpdateSize()
end

local function QuickAssistBars_Hide(bars, hideAll)
    bars:_Hide()
    if hideAll then
        for i = 1, bars.num do
            bars[i]:Hide()
        end
    end
end

local function QuickAssistBars_UpdatePixelPerfect(bars)
    -- P.Resize(bars)
    P.Repoint(bars)
    for i = 1, bars.num do
        bars[i]:UpdatePixelPerfect()
    end
end

function I.CreateAura_QuickAssistBars(name, parent, num)
    local bars = CreateFrame("Frame", name, parent)
    bars:Hide()
    bars.indicatorType = "bars"
    bars.num = num

    bars._SetSize = bars.SetSize
    bars.SetSize = QuickAssistBars_SetSize
    bars.UpdateSize = QuickAssistBars_UpdateSize
    bars.SetOrientation = QuickAssistBars_SetOrientation
    bars._Hide = bars.Hide
    bars.Hide = QuickAssistBars_Hide
    bars.UpdatePixelPerfect = QuickAssistBars_UpdatePixelPerfect

    for i = 1, num do
        local name = name.."Bar"..i
        local bar = I.CreateAura_Bar(name, bars)
        bars[i] = bar

        bar.stack:Hide()
        bar.duration:Hide()
        bar.SetCooldown = QuickAssistBars_SetCooldown
    end

    return bars
end

-------------------------------------------------
-- CreateAura_Overlay
-------------------------------------------------
local function Overlay_OnUpdate(overlay, elapsed)
    overlay._remain = overlay._duration - (GetTime() - overlay._start)
    if overlay._remain < 0 then overlay._remain = 0 end
    overlay:_SetValue(overlay._remain)

    overlay._elapsed = overlay._elapsed + elapsed
    if overlay._elapsed >= 0.1 then
        overlay._elapsed = 0
        -- update color
        if overlay.colors[3][1] and overlay._remain <= overlay.colors[3][2] then
            if overlay.state ~= 3 then
                overlay.state = 3
                overlay:SetStatusBarColor(overlay.colors[3][3][1], overlay.colors[3][3][2], overlay.colors[3][3][3], overlay.colors[3][3][4])
            end
        elseif overlay.colors[2][1] and overlay._remain <= overlay._duration * overlay.colors[2][2] then
            if overlay.state ~= 2 then
                overlay.state = 2
                overlay:SetStatusBarColor(overlay.colors[2][3][1], overlay.colors[2][3][2], overlay.colors[2][3][3], overlay.colors[2][3][4])
            end
        elseif overlay.state ~= 1 then
            overlay.state = 1
            overlay:SetStatusBarColor(overlay.colors[1][1], overlay.colors[1][2], overlay.colors[1][3], overlay.colors[1][4])
        end
    end
end

local function Overlay_SetCooldown(overlay, start, duration, debuffType, texture, count)
    if duration == 0 then
        overlay:SetScript("OnUpdate", nil)
        overlay:_SetMinMaxValues(0, 1)
        overlay:_SetValue(1)
        overlay:SetStatusBarColor(unpack(overlay.colors[1]))
        overlay._start = nil
        overlay._duration = nil
        overlay._remain = nil
        overlay._elapsed = nil
    else
        overlay:_SetMinMaxValues(0, duration)
        overlay._start = start
        overlay._duration = duration
        overlay._elapsed = 0.1 -- update immediately
        overlay:SetScript("OnUpdate", Overlay_OnUpdate)
    end

    overlay:Show()
end

local function Overlay_EnableSmooth(overlay, smooth)
    if smooth then
        overlay._SetMinMaxValues = overlay.SetMinMaxSmoothedValue
        overlay._SetValue = overlay.SetSmoothedValue
    else
        overlay._SetMinMaxValues = overlay.SetMinMaxValues
        overlay._SetValue = overlay.SetValue
    end
end

local function Overlay_SetColors(overlay, colors)
    overlay.state = nil
    overlay.colors = colors
end

-- +56 ~ +110
local function Overlay_SetFrameLevel(overlay, frameLevel)
    overlay:_SetFrameLevel(frameLevel + 55)
end

function I.CreateAura_Overlay(name, parent)
    local overlay = CreateFrame("StatusBar", name, parent.widgets.healthBar)
    overlay:SetStatusBarTexture(Cell.vars.whiteTexture)
    overlay:Hide()
    overlay.indicatorType = "overlay"

    Mixin(overlay, SmoothStatusBarMixin)
    overlay:SetAllPoints()
    -- overlay:SetBackdropColor(0, 0, 0, 0)

    overlay.SetCooldown = Overlay_SetCooldown
    overlay._SetMinMaxValues = overlay.SetMinMaxValues
    overlay._SetValue = overlay.SetValue
    overlay._SetFrameLevel = overlay.SetFrameLevel
    overlay.SetFrameLevel = Overlay_SetFrameLevel
    overlay.EnableSmooth = Overlay_EnableSmooth
    overlay.SetColors = Overlay_SetColors

    return overlay
end

-------------------------------------------------
-- CreateAura_Block
-------------------------------------------------
local function Block_OnUpdate_Duration(frame, elapsed)
    frame._remain = frame._duration - (GetTime() - frame._start)
    if frame._remain < 0 then frame._remain = 0 end

    frame._elapsed = frame._elapsed + elapsed
    if frame._elapsed >= 0.1 then
        frame._elapsed = 0
        -- update color
        if frame.colors[4][1] and frame._remain <= frame.colors[4][2] then
            if frame.state ~= 3 then
                frame.state = 3
                frame:SetBackdropColor(frame.colors[4][3][1], frame.colors[4][3][2], frame.colors[4][3][3], frame.colors[4][3][4])
            end
        elseif frame.colors[3][1] and frame._remain <= frame._duration * frame.colors[3][2] then
            if frame.state ~= 2 then
                frame.state = 2
                frame:SetBackdropColor(frame.colors[3][3][1], frame.colors[3][3][2], frame.colors[3][3][3], frame.colors[3][3][4])
            end
        elseif frame.state ~= 1 then
            frame.state = 1
            frame:SetBackdropColor(frame.colors[2][1], frame.colors[2][2], frame.colors[2][3], frame.colors[2][4])
        end
    end

    if frame._remain > frame._threshold then
        frame.duration:SetText("")
        return
    end

    -- format
    if frame._remain > 60 then
        frame.duration:SetFormattedText("%dm", frame._remain / 60)
    else
        if Cell.vars.iconDurationRoundUp then
            frame.duration:SetFormattedText("%d", ceil(frame._remain))
        else
            if frame._remain < Cell.vars.iconDurationDecimal then
                frame.duration:SetFormattedText("%.1f", frame._remain)
            else
                frame.duration:SetFormattedText("%d", frame._remain)
            end
        end
    end
end

local function Block_SetCooldown_Duration(frame, start, duration, debuffType, texture, count, refreshing)
    -- local r, g, b
    -- if debuffType then
    --     r, g, b = I.GetDebuffTypeColor(debuffType)
    -- else
    --     r, g, b = 0, 0, 0
    -- end

    if duration == 0 then
        frame.cooldown:Hide()
        frame.duration:Hide()
        frame:SetScript("OnUpdate", nil)
        frame._start = nil
        frame._duration = nil
        frame._remain = nil
        frame._elapsed = nil
        frame._threshold = nil
    else
        -- frame.cooldown:SetSwipeColor(r, g, b)
        frame.cooldown:ShowCooldown(start, duration)

        if not frame.showDuration then
            frame._threshold = -1
            frame.duration:Hide()
        else
            if frame.showDuration == true then
                frame._threshold = duration
            elseif frame.showDuration >= 1 then
                frame._threshold = frame.showDuration
            else -- < 1
                frame._threshold = frame.showDuration * duration
            end
            frame.duration:Show()
        end

        frame._start = start
        frame._duration = duration
        frame._elapsed = 0.1 -- update immediately
        frame:SetScript("OnUpdate", Block_OnUpdate_Duration)
    end

    frame.stack:SetText((count == 0 or count == 1) and "" or count)
    frame:Show()

    if refreshing then
        frame.ag:Play()
    end
end

local function Block_OnUpdate_Stack(frame, elapsed)
    frame._remain = frame._duration - (GetTime() - frame._start)
    if frame._remain < 0 then frame._remain = 0 end

    if frame._remain > frame._threshold then
        frame.duration:SetText("")
        return
    end

    -- format
    if frame._remain > 60 then
        frame.duration:SetFormattedText("%dm", frame._remain / 60)
    else
        if Cell.vars.iconDurationRoundUp then
            frame.duration:SetFormattedText("%d", ceil(frame._remain))
        else
            if frame._remain < Cell.vars.iconDurationDecimal then
                frame.duration:SetFormattedText("%.1f", frame._remain)
            else
                frame.duration:SetFormattedText("%d", frame._remain)
            end
        end
    end
end

local function Block_SetCooldown_Stack(frame, start, duration, debuffType, texture, count, refreshing)
    if duration == 0 then
        frame.cooldown:Hide()
        frame.duration:Hide()
        frame:SetScript("OnUpdate", nil)
        frame._start = nil
        frame._duration = nil
        frame._remain = nil
        frame._threshold = nil
    else
        -- frame.cooldown:SetSwipeColor(r, g, b)
        frame.cooldown:ShowCooldown(start, duration)

        if not frame.showDuration then
            frame._threshold = -1
            frame.duration:Hide()
        else
            if frame.showDuration == true then
                frame._threshold = duration
            elseif frame.showDuration >= 1 then
                frame._threshold = frame.showDuration
            else -- < 1
                frame._threshold = frame.showDuration * duration
            end
            frame.duration:Show()
        end

        frame._start = start
        frame._duration = duration
        frame:SetScript("OnUpdate", Block_OnUpdate_Stack)
    end

    -- update color
    if frame.colors[4][1] and count >= frame.colors[4][2] then
        frame:SetBackdropColor(frame.colors[4][3][1], frame.colors[4][3][2], frame.colors[4][3][3], frame.colors[4][3][4])
    elseif frame.colors[3][1] and count >= frame.colors[3][2] then
        frame:SetBackdropColor(frame.colors[3][3][1], frame.colors[3][3][2], frame.colors[3][3][3], frame.colors[3][3][4])
    else
        frame:SetBackdropColor(frame.colors[2][1], frame.colors[2][2], frame.colors[2][3], frame.colors[2][4])
    end

    frame.stack:SetText((count == 0 or count == 1) and "" or count)
    frame:Show()

    if refreshing then
        frame.ag:Play()
    end
end

local function Block_SetColors(frame, colors)
    if colors[1] == "duration" then
        frame.SetCooldown = Block_SetCooldown_Duration
    else
        frame.SetCooldown = Block_SetCooldown_Stack
    end
    frame:SetBackdropBorderColor(colors[5][1], colors[5][2], colors[5][3], colors[5][4])
    frame.state = nil
    frame.colors = colors
end

local function Block_UpdatePixelPerfect(frame)
    P.Resize(frame)
    P.Repoint(frame)
    P.Repoint(frame.stack)
    P.Repoint(frame.duration)
    P.Repoint(frame.cooldown)
    if frame.cooldown.spark then
        P.Resize(frame.cooldown.spark)
    end
end

function I.CreateAura_Block(name, parent)
    local frame = CreateFrame("Frame", name, parent, "BackdropTemplate")
    frame:Hide()
    frame.indicatorType = "block"

    frame:SetBackdrop({bgFile = Cell.vars.whiteTexture, edgeFile = Cell.vars.whiteTexture, edgeSize = P.Scale(CELL_BORDER_SIZE)})

    Shared_SetCooldownStyle(frame, CELL_COOLDOWN_STYLE, true)

    frame.stack = frame.cooldown:CreateFontString(nil, "OVERLAY", "CELL_FONT_STATUS")
    frame.duration = frame.cooldown:CreateFontString(nil, "OVERLAY", "CELL_FONT_STATUS")

    frame.SetFont = Shared_SetFont
    frame.SetColors = Block_SetColors
    frame.ShowStack = Shared_ShowStack
    frame.ShowDuration = Shared_ShowDuration
    frame.SetCooldown = Block_SetCooldown_Duration
    frame.UpdatePixelPerfect = Block_UpdatePixelPerfect

    local ag = frame:CreateAnimationGroup()
    frame.ag = ag
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

    return frame
end

-------------------------------------------------
-- CreateAura_Blocks
-------------------------------------------------
local function Blocks_OnUpdate(frame, elapsed)
    frame._remain = frame._duration - (GetTime() - frame._start)
    if frame._remain < 0 then frame._remain = 0 end

    if frame._remain > frame._threshold then
        frame.duration:SetText("")
        return
    end

    -- format
    if frame._remain > 60 then
        frame.duration:SetFormattedText("%dm", frame._remain / 60)
    else
        if Cell.vars.iconDurationRoundUp then
            frame.duration:SetFormattedText("%d", ceil(frame._remain))
        else
            if frame._remain < Cell.vars.iconDurationDecimal then
                frame.duration:SetFormattedText("%.1f", frame._remain)
            else
                frame.duration:SetFormattedText("%d", frame._remain)
            end
        end
    end
end

local function Blocks_SetCooldown(frame, start, duration, debuffType, texture, count, refreshing, color)
    if duration == 0 then
        frame.cooldown:Hide()
        frame.duration:Hide()
        frame:SetScript("OnUpdate", nil)
        frame._start = nil
        frame._duration = nil
        frame._remain = nil
        frame._threshold = nil
    else
        frame.cooldown:ShowCooldown(start, duration)

        if not frame.showDuration then
            frame._threshold = -1
            frame.duration:Hide()
        else
            if frame.showDuration == true then
                frame._threshold = duration
            elseif frame.showDuration >= 1 then
                frame._threshold = frame.showDuration
            else -- < 1
                frame._threshold = frame.showDuration * duration
            end
            frame.duration:Show()
        end

        frame._start = start
        frame._duration = duration
        frame:SetScript("OnUpdate", Blocks_OnUpdate)
    end

    frame:SetBackdropColor(color[1], color[2], color[3], color[4])
    frame.stack:SetText((count == 0 or count == 1) and "" or count)
    frame:Show()

    if refreshing then
        frame.ag:Play()
    end
end

function I.CreateAura_Blocks(name, parent, num)
    local blocks = CreateFrame("Frame", name, parent)
    blocks:Hide()

    blocks.indicatorType = "blocks"
    blocks.maxNum = num
    blocks.numPerLine = num

    blocks._SetSize = blocks.SetSize
    blocks.SetSize = Icons_SetSize
    blocks._Hide = blocks.Hide
    blocks.Hide = Icons_Hide
    blocks.SetFont = Icons_SetFont
    blocks.UpdateSize = Icons_UpdateSize
    blocks.SetOrientation = Icons_SetOrientation
    blocks.SetSpacing = Icons_SetSpacing
    blocks.SetNumPerLine = Icons_SetNumPerLine
    blocks.ShowDuration = Icons_ShowDuration
    blocks.ShowStack = Icons_ShowStack
    blocks.UpdatePixelPerfect = Icons_UpdatePixelPerfect

    for i = 1, num do
        local name = name.."Icons"..i
        local frame = I.CreateAura_Block(name, blocks)
        blocks[i] = frame
        frame.SetCooldown = Blocks_SetCooldown
        frame:SetBackdropBorderColor(0, 0, 0, 1)
    end

    return blocks
end

-------------------------------------------------
-- CreateAura_Border
-------------------------------------------------
local function Border_OnUpdate(border, elapsed)
    border._elapsed = border._elapsed + elapsed
    if border._elapsed >= 0.1 then
        border._elapsed = 0

        border._remain = border._duration - (GetTime() - border._start)
        if border._remain < 0 then border._remain = 0 end
        border:SetAlpha(border._remain / border._duration * 0.9 + 0.1)
    end
end

local function Border_SetFadeOut(border, fadeOut)
    border.fadeOut = fadeOut
end

local function Border_SetCooldown(border, start, duration, _, _, _, _, color)
    if border.fadeOut then
        border._start = start
        border._duration = duration
        border._elapsed = 0.1 -- update immediately
        border:SetScript("OnUpdate", Border_OnUpdate)
    else
        border:SetScript("OnUpdate", nil)
        border._start = nil
        border._duration = nil
        border._remain = nil
        border._elapsed = nil
        border:SetAlpha(1)
    end
    border.tex:SetVertexColor(color[1], color[2], color[3], color[4])
    border:Show()
end

local function Border_UpdatePixelPerfect(border)
    P.Repoint(border)
    P.Repoint(border.mask)
    P.Repoint(border.mask2)
end

local function Border_SetThickness(border, thickness)
    P.ClearPoints(border.mask)
    P.Point(border.mask, "TOPLEFT", thickness, -thickness)
    P.Point(border.mask, "BOTTOMRIGHT", -thickness, thickness)
    P.ClearPoints(border.mask2)
    P.Point(border.mask2, "TOPLEFT", thickness+CELL_BORDER_SIZE, -thickness-CELL_BORDER_SIZE)
    P.Point(border.mask2, "BOTTOMRIGHT", -thickness-CELL_BORDER_SIZE, thickness+CELL_BORDER_SIZE)
end

function I.CreateAura_Border(name, parent)
    local border = CreateFrame("Frame", name, parent)
    border:Hide()
    border.indicatorType = "border"

    P.Point(border, "TOPLEFT", CELL_BORDER_SIZE, -CELL_BORDER_SIZE)
    P.Point(border, "BOTTOMRIGHT", -CELL_BORDER_SIZE, CELL_BORDER_SIZE)

    local mask = border:CreateMaskTexture()
    border.mask = mask
    mask:SetTexture(Cell.vars.emptyTexture, "CLAMPTOWHITE","CLAMPTOWHITE")

    local tex = border:CreateTexture(nil, "ARTWORK")
    border.tex = tex
    tex:SetAllPoints()
    tex:SetTexture(Cell.vars.whiteTexture)
    tex:AddMaskTexture(mask)

    local mask2 = border:CreateMaskTexture()
    border.mask2 = mask2
    mask2:SetTexture(Cell.vars.emptyTexture, "CLAMPTOWHITE","CLAMPTOWHITE")

    local tex2 = border:CreateTexture(nil, "ARTWORK", nil, -1)
    tex2:SetAllPoints()
    tex2:SetColorTexture(0, 0, 0)
    tex2:AddMaskTexture(mask2)

    border.SetCooldown = Border_SetCooldown
    border.SetFadeOut = Border_SetFadeOut
    border.SetThickness = Border_SetThickness
    border.UpdatePixelPerfect = Border_UpdatePixelPerfect

    return border
end