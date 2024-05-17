-------------------------------------------------
-- remove icons border
-------------------------------------------------
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs
local I = Cell.iFuncs

local function BarIcon_SetFont(frame, font1, font2)
    I:SetFont(frame.stack, frame.textFrame, unpack(font1))
    I:SetFont(frame.duration, frame.textFrame, unpack(font2))
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

    frame.icon:SetTexture(texture)
    frame.maskIcon:SetTexture(texture)
    frame.stack:SetText((count == 0 or count == 1) and "" or count)
    frame:Show()

    if refreshing then
        frame.ag:Play()
    end
end

function I:CreateAura_BarIcon(name, parent)
    local frame = CreateFrame("Frame", name, parent)
    frame:Hide()

    local icon = frame:CreateTexture(name.."Icon", "ARTWORK")
    frame.icon = icon
    icon:SetTexCoord(0.12, 0.88, 0.12, 0.88)
    icon:SetAllPoints(frame)

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

    frame.SetFont = BarIcon_SetFont

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

    frame.SetCooldown = BarIcon_SetCooldown

    -- frame:SetScript("OnEnter", function()
        -- local f = frame
        -- repeat
        --     f = f:GetParent()
        -- until f:IsObjectType("button")
        -- f:GetScript("OnEnter")(f)
    -- end)
    
    function frame:ShowDuration(show)
        frame.showDuration = show
        if show then
            duration:Show()
        else
            duration:Hide()
        end
    end

    function frame:ShowAnimation(show)
        frame.showAnimation = show
        if show then
            cooldown:Show()
        else
            cooldown:Hide()
        end
    end

    function frame:ShowStack(show)
        if show then
            stack:Show()
        else
            stack:Hide()
        end
    end

    function frame:UpdatePixelPerfect()
        P:Resize(frame)
        P:Repoint(frame)
        P:Repoint(icon)
        P:Repoint(cooldown)
        P:Repoint(stack)
        P:Repoint(duration)
    end

    return frame
end