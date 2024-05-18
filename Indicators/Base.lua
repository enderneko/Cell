local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local I = Cell.iFuncs
local P = Cell.pixelPerfectFuncs

local LCG = LibStub("LibCustomGlow-1.0")

CELL_BORDER_SIZE = 1
CELL_BORDER_COLOR = {0, 0, 0, 1}

-------------------------------------------------
-- SetFont
-------------------------------------------------
function I.SetFont(fs, anchorTo, font, size, outline, shadow, anchor, xOffset, yOffset, color)
    font = F:GetFont(font)

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
    
    P:ClearPoints(fs)
    P:Point(fs, anchor, anchorTo, anchor, xOffset, yOffset)

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
-- CreateAura_BorderIcon
-------------------------------------------------
local function BorderIcon_SetFont(frame, font1, font2)
    I.SetFont(frame.stack, frame.textFrame, unpack(font1))
    I.SetFont(frame.duration, frame.textFrame, unpack(font2))
end

local function BorderIcon_SetCooldown(frame, start, duration, debuffType, texture, count, refreshing)
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
    else
        frame.border:Hide()
        frame.cooldown:Show()
        frame.cooldown:SetSwipeColor(r, g, b)
        frame.cooldown:_SetCooldown(start, duration)

        local threshold
        if not frame.showDuration then
            frame.duration:Hide()
        else
            if frame.showDuration == true then
                threshold = duration
            elseif frame.showDuration >= 1 then
                threshold = frame.showDuration
            else -- < 1
                threshold = frame.showDuration * duration
            end
            frame.duration:Show()
        end

        if frame.showDuration then
            local fmt
            frame.elapsed = 0.1 -- update immediately
            frame:SetScript("OnUpdate", function(self, elapsed)
                local remain = duration-(GetTime()-start)
                if remain < 0 then remain = 0 end

                if remain > threshold then
                    frame.duration:SetText("")
                    return
                end

                self.elapsed = self.elapsed + elapsed
                if self.elapsed >= 0.1 then
                    self.elapsed = 0
                    -- color
                    if Cell.vars.iconDurationColors then
                        if remain < Cell.vars.iconDurationColors[3][4] then
                            frame.duration:SetTextColor(Cell.vars.iconDurationColors[3][1], Cell.vars.iconDurationColors[3][2], Cell.vars.iconDurationColors[3][3])
                        elseif remain < (Cell.vars.iconDurationColors[2][4] * duration) then
                            frame.duration:SetTextColor(Cell.vars.iconDurationColors[2][1], Cell.vars.iconDurationColors[2][2], Cell.vars.iconDurationColors[2][3])
                        else
                            frame.duration:SetTextColor(Cell.vars.iconDurationColors[1][1], Cell.vars.iconDurationColors[1][2], Cell.vars.iconDurationColors[1][3])
                        end
                    else
                        frame.duration:SetTextColor(frame.duration.r, frame.duration.g, frame.duration.b)
                    end
                end

                -- format
                if remain > 60 then
                    fmt, remain = "%dm", remain/60
                else
                    if Cell.vars.iconDurationRoundUp then
                        fmt, remain = "%d", ceil(remain)
                    else
                        if remain < Cell.vars.iconDurationDecimal then
                            fmt = "%.1f"
                        else
                            fmt = "%d"
                        end
                    end
                end
                frame.duration:SetFormattedText(fmt, remain)
            end)
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
    P:ClearPoints(frame.iconFrame)
    P:Point(frame.iconFrame, "TOPLEFT", frame, "TOPLEFT", thickness, -thickness)
    P:Point(frame.iconFrame, "BOTTOMRIGHT", frame, "BOTTOMRIGHT", -thickness, thickness)
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
    P:Resize(frame)
    P:Repoint(frame)
    P:Repoint(frame.iconFrame)
    P:Repoint(frame.stack)
    P:Repoint(frame.duration)
end

function I.CreateAura_BorderIcon(name, parent, borderSize)
    local frame = CreateFrame("Frame", name, parent, "BackdropTemplate")
    frame:Hide()
    -- frame:SetSize(11, 11)
    frame:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
    frame:SetBackdropColor(0, 0, 0, 0.85)
    
    local border = frame:CreateTexture(name.."Border", "BORDER")
    frame.border = border
    border:SetAllPoints(frame)
    border:Hide()

    local cooldown = CreateFrame("Cooldown", name.."Cooldown", frame)
    frame.cooldown = cooldown
    cooldown:SetAllPoints(frame)
    cooldown:SetSwipeTexture("Interface\\Buttons\\WHITE8x8")
    cooldown:SetSwipeColor(1, 1, 1)
    cooldown:SetHideCountdownNumbers(true)
    -- disable omnicc
    cooldown.noCooldownCount = true
    -- prevent some addons from adding cooldown text
    cooldown._SetCooldown = cooldown.SetCooldown
    cooldown.SetCooldown = nil

    local iconFrame = CreateFrame("Frame", name.."IconFrame", frame)
    frame.iconFrame = iconFrame
    P:Point(iconFrame, "TOPLEFT", frame, "TOPLEFT", borderSize, -borderSize)
    P:Point(iconFrame, "BOTTOMRIGHT", frame, "BOTTOMRIGHT", -borderSize, borderSize)
    iconFrame:SetFrameLevel(cooldown:GetFrameLevel()+1)

    local icon = iconFrame:CreateTexture(name.."Icon", "ARTWORK")
    frame.icon = icon
    icon:SetTexCoord(0.12, 0.88, 0.12, 0.88)
    icon:SetAllPoints(iconFrame)

    local textFrame = CreateFrame("Frame", nil, iconFrame)
    frame.textFrame = textFrame
    textFrame:SetAllPoints(frame)

    local stack = textFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_STATUS")
    frame.stack = stack
    stack:SetJustifyH("RIGHT")
    P:Point(stack, "TOPRIGHT", textFrame, "TOPRIGHT", 2, 1)

    local duration = textFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_STATUS")
    frame.duration = duration
    duration:SetJustifyH("RIGHT")
    P:Point(duration, "BOTTOMRIGHT", textFrame, "BOTTOMRIGHT", 2, -1)

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

    frame.SetFont = BorderIcon_SetFont
    frame.SetBorder = BorderIcon_SetBorder
    frame.SetCooldown = BorderIcon_SetCooldown
    frame.ShowDuration = BorderIcon_ShowDuration
    frame.UpdatePixelPerfect = BorderIcon_UpdatePixelPerfect

    return frame
end

-------------------------------------------------
-- CreateAura_BarIcon
-------------------------------------------------
local function BarIcon_SetFont(frame, font1, font2)
    I.SetFont(frame.stack, frame.textFrame, unpack(font1))
    I.SetFont(frame.duration, frame.textFrame, unpack(font2))
end

local function BarIcon_SetCooldown(frame, start, duration, debuffType, texture, count, refreshing)
    if duration == 0 then
        frame.cooldown:Hide()
        frame.duration:Hide()
        frame:SetScript("OnUpdate", nil)
    else
        if frame.showAnimation then
            -- init bar values
            frame.cooldown.elapsed = 0.1 -- update immediately
            frame.cooldown:SetMinMaxValues(0, duration)
            frame.cooldown:SetValue(GetTime()-start)
            frame.cooldown:Show()
        else
            frame.cooldown:Hide()
        end

        local threshold
        if not frame.showDuration then
            frame.duration:Hide()
        else
            if frame.showDuration == true then
                threshold = duration
            elseif frame.showDuration >= 1 then
                threshold = frame.showDuration
            else -- < 1
                threshold = frame.showDuration * duration
            end
            frame.duration:Show()
        end

        if frame.showDuration then
            local fmt
            frame.elapsed = 0.1 -- update immediately
            frame:SetScript("OnUpdate", function(self, elapsed)
                local remain = duration-(GetTime()-start)
                if remain < 0 then remain = 0 end

                if remain > threshold then
                    frame.duration:SetText("")
                    return
                end

                self.elapsed = self.elapsed + elapsed
                if self.elapsed >= 0.1 then
                    self.elapsed = 0
                    -- color
                    if Cell.vars.iconDurationColors then
                        if remain < Cell.vars.iconDurationColors[3][4] then
                            frame.duration:SetTextColor(Cell.vars.iconDurationColors[3][1], Cell.vars.iconDurationColors[3][2], Cell.vars.iconDurationColors[3][3])
                        elseif remain < (Cell.vars.iconDurationColors[2][4] * duration) then
                            frame.duration:SetTextColor(Cell.vars.iconDurationColors[2][1], Cell.vars.iconDurationColors[2][2], Cell.vars.iconDurationColors[2][3])
                        else
                            frame.duration:SetTextColor(Cell.vars.iconDurationColors[1][1], Cell.vars.iconDurationColors[1][2], Cell.vars.iconDurationColors[1][3])
                        end
                    else
                        frame.duration:SetTextColor(frame.duration.r, frame.duration.g, frame.duration.b)
                    end
                end

                -- format
                if remain > 60 then
                    fmt, remain = "%dm", remain/60
                else
                    if Cell.vars.iconDurationRoundUp then
                        fmt, remain = "%d", ceil(remain)
                    else
                        if remain < Cell.vars.iconDurationDecimal then
                            fmt = "%.1f"
                        else
                            fmt = "%d"
                        end
                    end
                end
                frame.duration:SetFormattedText(fmt, remain)
            end)
        end
    end

    local r, g, b
    if debuffType then
        r, g, b = I.GetDebuffTypeColor(debuffType)
        frame.spark:SetColorTexture(r, g, b, 1)
    else
        r, g, b = 0, 0, 0
        frame.spark:SetColorTexture(0.5, 0.5, 0.5, 1)
    end

    frame:SetBackdropColor(r, g, b, 1)
    frame.icon:SetTexture(texture)
    frame.maskIcon:SetTexture(texture)
    frame.stack:SetText((count == 0 or count == 1) and "" or count)
    frame:Show()

    if refreshing then
        frame.ag:Play()
    end
end

local function BarIcon_ShowDuration(frame, show)
    frame.showDuration = show
    if show then
        frame.duration:Show()
    else
        frame.duration:Hide()
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

local function BarIcon_ShowStack(frame, show)
    if show then
        frame.stack:Show()
    else
        frame.stack:Hide()
    end
end

local function BarIcon_UpdatePixelPerfect(frame)
    P:Resize(frame)
    P:Repoint(frame)
    P:Repoint(frame.icon)
    P:Repoint(frame.cooldown)
    P:Resize(frame.spark)
    P:Repoint(frame.stack)
    P:Repoint(frame.duration)
end

function I.CreateAura_BarIcon(name, parent)
    local frame = CreateFrame("Frame", name, parent, "BackdropTemplate")
    frame:Hide()
    -- frame:SetSize(11, 11)
    frame:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
    frame:SetBackdropColor(0, 0, 0, 1)

    local icon = frame:CreateTexture(name.."Icon", "ARTWORK")
    frame.icon = icon
    icon:SetTexCoord(0.12, 0.88, 0.12, 0.88)
    P:Point(icon, "TOPLEFT", frame, "TOPLEFT", CELL_BORDER_SIZE, -CELL_BORDER_SIZE)
    P:Point(icon, "BOTTOMRIGHT", frame, "BOTTOMRIGHT", -CELL_BORDER_SIZE, CELL_BORDER_SIZE)
    -- icon:SetDrawLayer("ARTWORK", 1)

    local cooldown = CreateFrame("StatusBar", name.."CooldownBar", frame)
    frame.cooldown = cooldown
    cooldown:SetPoint("TOPLEFT", icon)
    cooldown:SetPoint("BOTTOMRIGHT", icon)
    cooldown:SetOrientation("VERTICAL")
    cooldown:SetReverseFill(true)
    -- cooldown:SetFillStyle("REVERSE")
    cooldown:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    cooldown:GetStatusBarTexture():SetAlpha(0)

    cooldown.elapsed = 0.1 -- update immediately
    cooldown:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        if self.elapsed >= 0.1 then
            cooldown:SetValue(cooldown:GetValue() + self.elapsed)
            self.elapsed = 0
        end
    end)

    -- for LCG.ButtonGlow_Start
    function cooldown:GetCooldownDuration()
        return 0
    end

    local spark = cooldown:CreateTexture(nil, "OVERLAY")
    frame.spark = spark
    P:Height(spark, CELL_BORDER_SIZE)
    spark:SetBlendMode("ADD")
    spark:SetPoint("TOPLEFT", cooldown:GetStatusBarTexture(), "BOTTOMLEFT")
    spark:SetPoint("TOPRIGHT", cooldown:GetStatusBarTexture(), "BOTTOMRIGHT")
    
    local mask = frame:CreateMaskTexture()
    mask:SetTexture("Interface\\Buttons\\WHITE8x8", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetPoint("TOPLEFT")
    mask:SetPoint("BOTTOMRIGHT", cooldown:GetStatusBarTexture())

    local maskIcon = cooldown:CreateTexture(name.."MaskIcon", "ARTWORK")
    frame.maskIcon = maskIcon
    maskIcon:SetTexCoord(0.12, 0.88, 0.12, 0.88)
    maskIcon:SetDesaturated(true)
    maskIcon:SetAllPoints(icon)
    -- maskIcon:SetDrawLayer("ARTWORK", 0)
    maskIcon:SetVertexColor(0.5, 0.5, 0.5, 1)
    maskIcon:AddMaskTexture(mask)

    frame:SetScript("OnSizeChanged", function(self, width, height)
        -- keep aspect ratio
        icon:SetTexCoord(unpack(F:GetTexCoord(width, height)))
        maskIcon:SetTexCoord(unpack(F:GetTexCoord(width, height)))
    end)

    local textFrame = CreateFrame("Frame", nil, frame)
    frame.textFrame = textFrame
    textFrame:SetAllPoints(frame)
    textFrame:SetFrameLevel(cooldown:GetFrameLevel()+1)

    local stack = textFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_STATUS")
    frame.stack = stack
    stack:SetJustifyH("RIGHT")
    P:Point(stack, "TOPRIGHT", textFrame, "TOPRIGHT", 2, 0)

    local duration = textFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_STATUS")
    frame.duration = duration
    duration:SetJustifyH("RIGHT")
    P:Point(duration, "BOTTOMRIGHT", textFrame, "BOTTOMRIGHT", 2, 0)
    duration:Hide()

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

    frame.SetFont = BarIcon_SetFont
    frame.SetCooldown = BarIcon_SetCooldown
    frame.ShowDuration = BarIcon_ShowDuration
    frame.ShowAnimation = BarIcon_ShowAnimation
    frame.ShowStack = BarIcon_ShowStack
    frame.UpdatePixelPerfect = BarIcon_UpdatePixelPerfect

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
-- CreateAura_Text
-------------------------------------------------
local function Text_SetFont(frame, font, size, outline, shadow)
    font = F:GetFont(font)

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

    local point = frame:GetPoint(1)
    frame.text:ClearAllPoints()
    if string.find(point, "LEFT") then
        frame.text:SetPoint("LEFT")
    elseif string.find(point, "RIGHT") then
        frame.text:SetPoint("RIGHT")
    else
        frame.text:SetPoint("CENTER")
    end
    frame:SetSize(size+3, size+3)
end

local function Text_OnUpdateColor(frame, duration, remain)
    if frame.colors[3][1] and remain <= frame.colors[3][2] then
        if frame.state ~= 3 then
            frame.state = 3
            frame.text:SetTextColor(frame.colors[3][3][1], frame.colors[3][3][2], frame.colors[3][3][3], frame.colors[3][3][4])
        end
    elseif frame.colors[2][1] and remain <= duration * frame.colors[2][2] then
        if frame.state ~= 2 then
            frame.state = 2
            frame.text:SetTextColor(frame.colors[2][3][1], frame.colors[2][3][2], frame.colors[2][3][3], frame.colors[2][3][4])
        end
    elseif frame.state ~= 1 then
        frame.state = 1
        frame.text:SetTextColor(frame.colors[1][1], frame.colors[1][2], frame.colors[1][3], frame.colors[1][4])
    end
end

local circled = {"①","②","③","④","⑤","⑥","⑦","⑧","⑨","⑩","⑪","⑫","⑬","⑭","⑮","⑯","⑰","⑱","⑲","⑳","㉑","㉒","㉓","㉔","㉕","㉖","㉗","㉘","㉙","㉚","㉛","㉜","㉝","㉞","㉟","㊱","㊲","㊳","㊴","㊵","㊶","㊷","㊸","㊹","㊺","㊻","㊼","㊽","㊾","㊿"}
local function Text_SetCooldown(frame, start, duration, debuffType, texture, count)
    if duration == 0 then
        count = count == 0 and 1 or count
        count = frame.circledStackNums and circled[count] or count
        frame.text:SetText(count)
        frame:SetScript("OnUpdate", nil)
    else
        local fmt
        if frame.durationTbl[1] then
            if count == 0 then
                fmt, count = "%s", ""
            elseif frame.circledStackNums then
                fmt, count = "%s ", circled[count] .. " "
            else
                fmt = "%d "
            end

            frame.elapsed = 0.1 -- update immediately
            frame:SetScript("OnUpdate", function(self, elapsed)
                local remain = duration-(GetTime()-start)
                if remain < 0 then remain = 0 end

                self.elapsed = self.elapsed + elapsed
                if self.elapsed >= 0.1 then
                    self.elapsed = 0
                    -- color
                    Text_OnUpdateColor(frame, duration, remain)
                end

                -- format
                local fmt2
                if remain > 60 then
                    fmt2, remain = fmt .. "%dm", remain/60
                else
                    if frame.durationTbl[2] then
                        fmt2, remain = fmt .. "%d", ceil(remain)
                    else
                        if remain < frame.durationTbl[3] then
                            fmt2 = fmt .. "%.1f"
                        else
                            fmt2 = fmt .. "%d"
                        end
                    end
                end
                frame.text:SetFormattedText(fmt2, count, remain)
            end)
        else
            count = count == 0 and 1 or count
            if frame.circledStackNums then
                fmt = circled[count]
                count = nil
            else
                fmt = "%d"
            end
            
            -- update count
            frame.text:SetFormattedText(fmt, count)

            frame.elapsed = 0.1 -- update immediately
            frame:SetScript("OnUpdate", function(self, elapsed)
                self.elapsed = self.elapsed + elapsed
                if self.elapsed >= 0.1 then
                    self.elapsed = 0
                    
                    local remain = duration-(GetTime()-start)
                    -- update color
                    Text_OnUpdateColor(frame, duration, remain)
                end
            end)
        end
    end

    frame:Show()
end

function I.CreateAura_Text(name, parent)
    local frame = CreateFrame("Frame", name, parent)
    frame:SetSize(11, 11)
    frame:Hide()
    frame.indicatorType = "text"

    local text = frame:CreateFontString(nil, "OVERLAY", "CELL_FONT_STATUS")
    frame.text = text
    -- stack:SetJustifyH("RIGHT")
    text:SetPoint("CENTER", 1, 0)

    frame.SetFont = Text_SetFont

    frame._SetPoint = frame.SetPoint
    function frame:SetPoint(point, relativeTo, relativePoint, x, y)
        text:ClearAllPoints()
        if string.find(point, "LEFT") then
            text:SetPoint("LEFT")
        elseif string.find(point, "RIGHT") then
            text:SetPoint("RIGHT")
        else
            text:SetPoint("CENTER")
        end
        frame:_SetPoint(point, relativeTo, relativePoint, x, y)
    end

    frame.SetCooldown = Text_SetCooldown

    function frame:SetDuration(durationTbl)
        frame.durationTbl = durationTbl
    end

    function frame:SetCircledStackNums(circled)
        frame.circledStackNums = circled
    end

    function frame:SetColors(colors)
        frame.state = nil
        frame.colors = colors
    end
        
    return frame
end

-------------------------------------------------
-- CreateAura_Rect
-------------------------------------------------
local function Rect_SetFont(frame, font, size, outline, shadow, anchor, xOffset, yOffset, color)
    I.SetFont(frame.stack, frame, font, size, outline, shadow, anchor, xOffset, yOffset, color)
end

local function Rect_OnUpdateColor(frame, duration, remain)
    if frame.colors[3][1] and remain <= frame.colors[3][2] then
        if frame.state ~= 3 then
            frame.state = 3
            frame.tex:SetColorTexture(frame.colors[3][3][1], frame.colors[3][3][2], frame.colors[3][3][3], frame.colors[3][3][4])
        end
    elseif frame.colors[2][1] and remain <= duration * frame.colors[2][2] then
        if frame.state ~= 2 then
            frame.state = 2
            frame.tex:SetColorTexture(frame.colors[2][3][1], frame.colors[2][3][2], frame.colors[2][3][3], frame.colors[2][3][4])
        end
    elseif frame.state ~= 1 then
        frame.state = 1
        frame.tex:SetColorTexture(frame.colors[1][1], frame.colors[1][2], frame.colors[1][3], frame.colors[1][4])
    end
end

local function Rect_SetCooldown(frame, start, duration, debuffType, texture, count)
    if duration == 0 then
        frame.tex:SetColorTexture(unpack(frame.colors[1]))
        frame:SetScript("OnUpdate", nil)
    else
        frame.elapsed = 0.1 -- update immediately
        frame:SetScript("OnUpdate", function(self, elapsed)
            self.elapsed = self.elapsed + elapsed
            if self.elapsed >= 0.1 then
                self.elapsed = 0

                local remain = duration-(GetTime()-start)
                -- update color
                Rect_OnUpdateColor(frame, duration, remain)
            end
        end)
    end

    frame.stack:SetText((count == 0 or count == 1) and "" or count)
    frame:Show()
end

function I.CreateAura_Rect(name, parent)
    local frame = CreateFrame("Frame", name, parent, "BackdropTemplate")
    -- frame:SetSize(11, 4)
    frame:Hide()
    frame.indicatorType = "rect"
    frame:SetBackdrop({edgeFile="Interface\\Buttons\\WHITE8x8", edgeSize=P:Scale(1)})
    frame:SetBackdropBorderColor(0, 0, 0, 1)

    local tex = frame:CreateTexture(nil, "BORDER", nil, -7)
    frame.tex = tex
    tex:SetAllPoints()

    frame.stack = frame:CreateFontString(nil, "OVERLAY")

    frame.SetFont = Rect_SetFont
    frame.SetCooldown = Rect_SetCooldown

    function frame:SetColors(colors)
        frame.state = nil
        frame.colors = colors
        frame:SetBackdropBorderColor(colors[4][1], colors[4][2], colors[4][3], colors[4][4])
    end

    function frame:ShowStack(show)
        if show then
            frame.stack:Show()
        else
            frame.stack:Hide()
        end
    end

    function frame:UpdatePixelPerfect()
        P:Resize(frame)
        P:Reborder(frame)
        P:Repoint(frame)
    end
        
    return frame
end

-------------------------------------------------
-- CreateAura_Bar
-------------------------------------------------
local function Bar_SetFont(frame, font, size, outline, shadow, anchor, xOffset, yOffset, color)
    I.SetFont(frame.stack, frame, font, size, outline, shadow, anchor, xOffset, yOffset, color)
end

local function Bar_SetCooldown(bar, start, duration, debuffType, texture, count)
    if duration == 0 then
        bar:SetScript("OnUpdate", nil)
        bar:SetMinMaxValues(0, 1)
        bar:SetValue(1)
    else
        bar:SetMinMaxValues(0, duration)
        bar.elapsed = 0.1 -- update immediately
        bar:SetScript("OnUpdate", function(self, elapsed)
            local remain = duration-(GetTime()-start)
            if remain < 0 then remain = 0 end
            bar:SetValue(remain)

            self.elapsed = self.elapsed + elapsed
            if self.elapsed >= 0.1 then
                self.elapsed = 0
                -- update color
                if bar.colors[3][1] and remain <= bar.colors[3][2] then
                    if bar.state ~= 3 then
                        bar.state = 3
                        bar:SetStatusBarColor(bar.colors[3][3][1], bar.colors[3][3][2], bar.colors[3][3][3], bar.colors[3][3][4])
                    end
                elseif bar.colors[2][1] and remain <= duration * bar.colors[2][2] then
                    if bar.state ~= 2 then
                        bar.state = 2
                        bar:SetStatusBarColor(bar.colors[2][3][1], bar.colors[2][3][2], bar.colors[2][3][3], bar.colors[2][3][4])
                    end
                elseif bar.state ~= 1 then
                    bar.state = 1
                    bar:SetStatusBarColor(bar.colors[1][1], bar.colors[1][2], bar.colors[1][3], bar.colors[1][4])
                end
            end
        end)
    end

    bar.stack:SetText((count == 0 or count == 1) and "" or count)
    bar:Show()
end

function I.CreateAura_Bar(name, parent)
    local bar = Cell:CreateStatusBar(name, parent, 18, 4, 100)
    bar:Hide()
    bar.indicatorType = "bar"

    bar.stack = bar:CreateFontString(nil, "OVERLAY")

    bar.SetFont = Bar_SetFont
    bar.SetCooldown = Bar_SetCooldown

    function bar:SetColors(colors)
        bar:SetBackdropBorderColor(colors[4][1], colors[4][2], colors[4][3], colors[4][4])
        bar:SetBackdropColor(colors[5][1], colors[5][2], colors[5][3], colors[5][4])
        bar.state = nil
        bar.colors = colors
    end

    function bar:ShowStack(show)
        if show then
            bar.stack:Show()
        else
            bar.stack:Hide()
        end
    end
        
    return bar
end

-------------------------------------------------
-- CreateAura_Color
-------------------------------------------------
local function Color_SetCooldown(color, start, duration, debuffType)
    if color.type == "change-over-time" then
        if duration == 0 then
            color.solidTex:SetVertexColor(unpack(color.colors[4]))
            color:SetScript("OnUpdate", nil)
        else
            color.elapsed = 0.1 -- update immediately
            color:SetScript("OnUpdate", function(self, elapsed)
                self.elapsed = self.elapsed + elapsed
                if self.elapsed >= 0.1 then
                    self.elapsed = 0

                    local remain = duration-(GetTime()-start)
                    -- update color
                    if remain <= color.colors[6][1] then
                        if color.state ~= 3 then
                            color.state = 3
                            color.solidTex:SetVertexColor(color.colors[6][2][1], color.colors[6][2][2], color.colors[6][2][3], color.colors[6][2][4])
                        end
                    elseif remain <= duration * color.colors[5][1] then
                        if color.state ~= 2 then
                            color.state = 2
                            color.solidTex:SetVertexColor(color.colors[5][2][1], color.colors[5][2][2], color.colors[5][2][3], color.colors[5][2][4])
                        end
                    elseif color.state ~= 1 then
                        color.state = 1
                        color.solidTex:SetVertexColor(color.colors[4][1], color.colors[4][2], color.colors[4][3], color.colors[4][4])
                    end
                end
            end)
        end
    elseif color.type == "class-color" then
        color.solidTex:SetVertexColor(F:GetClassColor(color.parent.states.class))
    elseif color.type == "debuff-type" and debuffType then
        color.solidTex:SetVertexColor(CellDB["debuffTypeColor"][debuffType]["r"], CellDB["debuffTypeColor"][debuffType]["g"], CellDB["debuffTypeColor"][debuffType]["b"], 1)
    end
    color:Show()
end

local function Color_SetFrameLevel(color, frameLevel)
    color:_SetFrameLevel(frameLevel + 10)
end

local function Color_SetAnchor(color, anchorTo)
    color:ClearAllPoints()
    if anchorTo == "healthbar-current" then
        -- current hp texture
        color:SetAllPoints(color.parent.widgets.healthBar:GetStatusBarTexture())
        -- color:SetFrameLevel(parent:GetFrameLevel()+5)
    elseif anchorTo == "healthbar-entire" then
        -- entire hp bar
        color:SetAllPoints(color.parent.widgets.healthBar)
        -- color:SetFrameLevel(parent:GetFrameLevel()+5)
    else -- unitbutton
        P:Point(color, "TOPLEFT", color.parent.widgets.overlayFrame, "TOPLEFT", 1, -1)
        P:Point(color, "BOTTOMRIGHT", color.parent.widgets.overlayFrame, "BOTTOMRIGHT", -1, 1)
        -- color:SetFrameLevel(parent:GetFrameLevel()+6)
    end
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

    local solidTex = color:CreateTexture(nil, "OVERLAY", nil, -5)
    color.solidTex = solidTex
    solidTex:SetTexture(Cell.vars.texture)
    solidTex:SetAllPoints(color)
    solidTex:Hide()

    solidTex:SetScript("OnShow", function()
        -- update texture
        solidTex:SetTexture(Cell.vars.texture)
    end)
   
    local gradientTex = color:CreateTexture(nil, "OVERLAY", nil, -5)
    color.gradientTex = gradientTex
    gradientTex:SetTexture("Interface\\Buttons\\WHITE8x8")
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
function I.CreateAura_Texture(name, parent)
    local texture = CreateFrame("Frame", name, parent)
    texture:Hide()
    texture.indicatorType = "texture"
    
    local tex = texture:CreateTexture(name, "OVERLAY")
    tex:SetAllPoints(texture)

    function texture:SetCooldown(start, duration)
        if texture.fadeOut then
            texture.elapsed = 0.1 -- update immediately
            texture:SetScript("OnUpdate", function(self, elapsed)
                self.elapsed = self.elapsed + elapsed
                if self.elapsed >= 0.1 then
                    self.elapsed = 0

                    local remain = duration - (GetTime() - start)
                    if remain <= 0 then
                        tex:SetAlpha(0.2)
                    elseif remain >= duration then
                        tex:SetAlpha(1)
                    else
                        tex:SetAlpha(remain / duration * 0.8 + 0.2)
                    end
                end
            end)
        else
            texture:SetScript("OnUpdate", nil)
            tex:SetAlpha(texture.colorAlpha)
        end
        texture:Show()
    end

    function texture:SetFadeOut(fadeOut)
        texture.fadeOut = fadeOut
    end
    
    function texture:SetTexture(texTbl) -- texture, rotation, color
        if strfind(strlower(texTbl[1]), "^interface") then
            tex:SetTexture(texTbl[1])
        else
            tex:SetAtlas(texTbl[1])
        end
        tex:SetRotation(texTbl[2] * math.pi / 180)
        tex:SetVertexColor(unpack(texTbl[3]))
        texture.colorAlpha = texTbl[3][4]
    end

    return texture
end

-------------------------------------------------
-- CreateAura_Icons
-------------------------------------------------
local function Icons_UpdateFrameSize(icons, iconsShown)
    local lines = ceil(iconsShown / icons.numPerLine)
    
    if icons.isHorizontal then
        if lines > 1 then
            icons:_SetSize(icons.width*icons.numPerLine, icons.height*lines)
        else
            icons:_SetSize(icons.width*iconsShown, icons.height)
        end
    else
        if lines > 1 then
            icons:_SetSize(icons.width*lines, icons.height*icons.numPerLine)
        else
            icons:_SetSize(icons.width, icons.height*iconsShown)
        end
    end
end

local function Icons_UpdateSize(icons, iconsShown)
    if not (icons.width and icons.height and icons.orientation) then return end -- not init
    
    if iconsShown then -- call from I.CheckCustomIndicators or preview
        for i = iconsShown + 1, icons.maxNum do
            icons[i]:Hide()
        end
        if iconsShown ~= 0 then
            Icons_UpdateFrameSize(icons, iconsShown)
        end
    else
        for i = 1, icons.maxNum do
            if icons[i]:IsShown() then
                Icons_UpdateFrameSize(icons, i)
            end
        end
    end
end

local function Icons_SetNumPerLine(icons, numPerLine)
    icons.numPerLine = min(numPerLine, icons.maxNum)
    

    if icons.orientation then
        icons:SetOrientation(icons.orientation)
    end

    icons:UpdateSize()
end

local function Icons_SetOrientation(icons, orientation)
    icons.orientation = orientation

    local anchor = icons:GetPoint()
    assert(anchor, "[indicator] SetPoint must be called before SetOrientation")

    icons.isHorizontal = not strfind(orientation, "top")

    local point1, point2, newLinePoint2
    if orientation == "left-to-right" then
        if strfind(anchor, "^BOTTOM") then
            point1 = "BOTTOMLEFT"
            point2 = "BOTTOMRIGHT"
            newLinePoint2 = "TOPLEFT"
        else
            point1 = "TOPLEFT"
            point2 = "TOPRIGHT"
            newLinePoint2 = "BOTTOMLEFT"
        end
        
    elseif orientation == "right-to-left" then
        if strfind(anchor, "^BOTTOM") then
            point1 = "BOTTOMRIGHT"
            point2 = "BOTTOMLEFT"
            newLinePoint2 = "TOPRIGHT"
        else
            point1 = "TOPRIGHT"
            point2 = "TOPLEFT"
            newLinePoint2 = "BOTTOMRIGHT"
        end

    elseif orientation == "top-to-bottom" then
        if strfind(anchor, "RIGHT$") then
            point1 = "TOPRIGHT"
            point2 = "BOTTOMRIGHT"
            newLinePoint2 = "TOPLEFT"
        else
            point1 = "TOPLEFT"
            point2 = "BOTTOMLEFT"
            newLinePoint2 = "TOPRIGHT"
        end
        
    elseif orientation == "bottom-to-top" then
        if strfind(anchor, "RIGHT$") then
            point1 = "BOTTOMRIGHT"
            point2 = "TOPRIGHT"
            newLinePoint2 = "BOTTOMLEFT"
        else
            point1 = "BOTTOMLEFT"
            point2 = "TOPLEFT"
            newLinePoint2 = "BOTTOMRIGHT"
        end
    end
    
    for i = 1, icons.maxNum do
        P:ClearPoints(icons[i])
        if i == 1 then
            P:Point(icons[i], point1)
        elseif i % icons.numPerLine == 1 then
            P:Point(icons[i], point1, icons[i-icons.numPerLine], newLinePoint2)
        else
            P:Point(icons[i], point1, icons[i-1], point2)
        end
    end

    icons:UpdateSize()
end

local function Icons_SetSize(icons, width, height)
    icons.width = width
    icons.height = height

    for i = 1, icons.maxNum do
        icons[i]:SetSize(width, height)
    end

    icons:UpdateSize()
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
    P:Repoint(icons)
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
    
    icons._SetSize = icons.SetSize
    icons.SetSize = Icons_SetSize
    icons._Hide = icons.Hide
    icons.Hide = Icons_Hide
    icons.SetFont = Icons_SetFont
    icons.UpdateSize = Icons_UpdateSize
    icons.SetOrientation = Icons_SetOrientation
    icons.SetNumPerLine = Icons_SetNumPerLine
    icons.ShowDuration = Icons_ShowDuration
    icons.ShowStack = Icons_ShowStack
    icons.ShowAnimation = Icons_ShowAnimation
    icons.UpdatePixelPerfect = Icons_UpdatePixelPerfect

    for i = 1, num do
        local name = name.."Icons"..i
        local frame = I.CreateAura_BarIcon(name, icons)
        icons[i] = frame
    end

    return icons
end

-------------------------------------------------
-- CreateAura_Glow
-------------------------------------------------
local function Glow_SetCooldown(glow, start, duration)
    if glow.fadeOut then
        glow.elapsed = 0.1 -- update immediately
        glow:SetScript("OnUpdate", function(self, elapsed)
            self.elapsed = self.elapsed + elapsed
            if self.elapsed >= 0.1 then
                self.elapsed = 0

                local remain = duration-(GetTime()-start)
                if remain <= 0 then
                    glow:SetAlpha(0.2)
                elseif remain >= duration then
                    glow:SetAlpha(1)
                else
                    glow:SetAlpha(remain / duration * 0.8 + 0.2)
                end
            end
        end)
    else
        glow:SetScript("OnUpdate", nil)
        glow:SetAlpha(1)
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

    glow:SetScript("OnHide", function()
        LCG.ButtonGlow_Stop(glow)
        LCG.PixelGlow_Stop(glow)
        LCG.AutoCastGlow_Stop(glow)
        LCG.ProcGlow_Stop(glow)
    end)

    return glow
end

-------------------------------------------------
-- CreateAura_Bars
-------------------------------------------------
local function Bars_SetCooldown(bar, start, duration, color)
    if duration == 0 then
        bar:SetScript("OnUpdate", nil)
        bar:SetMinMaxValues(0, 1)
        bar:SetValue(1)
    else
        bar:SetMinMaxValues(0, duration)
        bar:SetScript("OnUpdate", function(self, elapsed)
            local remain = duration-(GetTime()-start)
            if remain < 0 then remain = 0 end
            bar:SetValue(remain)
        end)
    end

    bar:SetStatusBarColor(color[1], color[2], color[3], 1)
    bar:Show()
end

function I.CreateAura_Bars(name, parent, num)
    local bars = CreateFrame("Frame", name, parent)
    bars:Hide()
    bars.indicatorType = "bars"

    bars._SetSize = bars.SetSize

    function bars:UpdateSize(barsShown)
        if not (bars.width and bars.height) then return end -- not init
        if barsShown then -- call from I.CheckCustomIndicators or preview
            for i = barsShown + 1, num do
                bars[i]:Hide()
            end
            if barsShown ~= 0 then
                bars:_SetSize(bars.width, bars.height*barsShown-P:Scale(1)*(barsShown-1))
            end
        else
            for i = 1, num do
                if bars[i]:IsShown() then
                    bars:_SetSize(bars.width, bars.height*i-P:Scale(1)*(i-1))
                else
                    break
                end
            end
        end
    end

    function bars:SetSize(width, height)
        bars.width = width
        bars.height = height

        for i = 1, num do
            bars[i]:SetSize(width, height)
        end

        bars:UpdateSize()
    end

    function bars:SetOrientation(orientation)
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
        
        for i = 1, num do
            P:ClearPoints(bars[i])
            if i == 1 then
                P:Point(bars[i], point1)
            else
                P:Point(bars[i], point1, bars[i-1], point2, 0, offset)
            end
        end

        bars:UpdateSize()
    end

    for i = 1, num do
        local name = name.."Bar"..i
        local bar = I.CreateAura_Bar(name, bars)
        bars[i] = bar

        bar.stack:Hide()
        bar.SetCooldown = Bars_SetCooldown
    end

    bars._Hide = bars.Hide
    function bars:Hide(hideAll)
        bars:_Hide()
        if hideAll then
            for i = 1, num do
                bars[i]:Hide()
            end
        end
    end

    function bars:UpdatePixelPerfect()
        -- P:Resize(bars)
        P:Repoint(bars)
        for i = 1, num do
            bars[i]:UpdatePixelPerfect()
        end
    end

    return bars
end

-------------------------------------------------
-- CreateAura_Overlay
-------------------------------------------------
local function Overlay_SetCooldown(overlay, start, duration, debuffType, texture, count)
    if duration == 0 then
        overlay:SetScript("OnUpdate", nil)
        overlay:_SetMinMaxValues(0, 1)
        overlay:_SetValue(1)
        overlay:SetStatusBarColor(unpack(overlay.colors[1]))
    else
        overlay:_SetMinMaxValues(0, duration)
        overlay.elapsed = 0.1 -- update immediately
        overlay:SetScript("OnUpdate", function(self, elapsed)
            local remain = duration-(GetTime()-start)
            if remain < 0 then remain = 0 end
            overlay:_SetValue(remain)

            self.elapsed = self.elapsed + elapsed
            if self.elapsed >= 0.1 then
                self.elapsed = 0
                -- update color
                if overlay.colors[3][1] and remain <= overlay.colors[3][2] then
                    if overlay.state ~= 3 then
                        overlay.state = 3
                        overlay:SetStatusBarColor(overlay.colors[3][3][1], overlay.colors[3][3][2], overlay.colors[3][3][3], overlay.colors[3][3][4])
                    end
                elseif overlay.colors[2][1] and remain <= duration * overlay.colors[2][2] then
                    if overlay.state ~= 2 then
                        overlay.state = 2
                        overlay:SetStatusBarColor(overlay.colors[2][3][1], overlay.colors[2][3][2], overlay.colors[2][3][3], overlay.colors[2][3][4])
                    end
                elseif overlay.state ~= 1 then
                    overlay.state = 1
                    overlay:SetStatusBarColor(overlay.colors[1][1], overlay.colors[1][2], overlay.colors[1][3], overlay.colors[1][4])
                end
            end
        end)
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

local function Overlay_SetFrameLevel(overlay, frameLevel)
    overlay:_SetFrameLevel(frameLevel + 10)
end

function I.CreateAura_Overlay(name, parent)
    local overlay = CreateFrame("StatusBar", name, parent.widgets.healthBar)
    overlay:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
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
