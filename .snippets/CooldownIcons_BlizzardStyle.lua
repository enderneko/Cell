-- blizzard style cooldown animation
-- 暴雪样式图标
local COLOR_BORDER_BY_DISPEL_TYPE = true
local DRAW_EDGE = true

-------------------------------------------------
-- override customs
-------------------------------------------------
local F = Cell.funcs
local I = Cell.iFuncs
local P = Cell.pixelPerfectFuncs

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
            frame.cooldown:SetCooldown(start, duration)
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
            frame:SetScript("OnUpdate", function()
                local remain = duration-(GetTime()-start)
                if remain < 0 then remain = 0 end

                if remain > threshold then
                    frame.duration:SetText("")
                    return
                end

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
    if COLOR_BORDER_BY_DISPEL_TYPE and debuffType then
        r, g, b = I:GetDebuffTypeColor(debuffType)
    else
        r, g, b = 0, 0, 0
    end

    frame:SetBackdropColor(r, g, b, 1)
    frame.icon:SetTexture(texture)
    frame.stack:SetText((count == 0 or count == 1) and "" or count)
    frame:Show()

    if refreshing then
        frame.ag:Play()
    end
end

function I:CreateAura_BarIcon(name, parent)
    local frame = CreateFrame("Frame", name, parent, "BackdropTemplate")
    frame:Hide()
    -- frame:SetSize(11, 11)
    frame:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
    frame:SetBackdropColor(0, 0, 0, 1)

    local icon = frame:CreateTexture(name.."Icon", "ARTWORK")
    frame.icon = icon
    icon:SetTexCoord(0.12, 0.88, 0.12, 0.88)
    P:Point(icon, "TOPLEFT", frame, "TOPLEFT", 1, -1)
    P:Point(icon, "BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
    -- icon:SetDrawLayer("ARTWORK", 1)

    local cooldown = CreateFrame("Cooldown", name.."Cooldown", frame, "CooldownFrameTemplate")
    frame.cooldown = cooldown
    cooldown:SetAllPoints(frame)
    cooldown:SetReverse(true)
    cooldown.noCooldownCount = true -- disable omnicc
    cooldown:SetHideCountdownNumbers(true)
    cooldown:SetDrawEdge(DRAW_EDGE)

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

    function frame:ShowStack(show)
        if show then
            stack:Show()
        else
            stack:Hide()
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

    function frame:ShowAnimation(show)
        frame.showAnimation = show
        if show then
            cooldown:Show()
        else
            cooldown:Hide()
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

-------------------------------------------------
-- override built-ins
-------------------------------------------------
local function CreateCooldown(f)
    local cooldown = CreateFrame("Cooldown", f:GetName().."Cooldown", f, "CooldownFrameTemplate")
    f.cooldown = cooldown
    cooldown:SetAllPoints(f)
    cooldown:SetReverse(true)
    cooldown.noCooldownCount = true -- disable omnicc
    cooldown:SetHideCountdownNumbers(true)
    cooldown:SetDrawEdge(DRAW_EDGE)
    f.SetCooldown = BarIcon_SetCooldown
end

F:IterateAllUnitButtons(function(b)
    -- debuffs
    for i = 1, 10 do
        CreateCooldown(b.indicators.debuffs[i])
        hooksecurefunc(b.indicators.debuffs[i], "SetCooldown", function(self, start, duration, debuffType, texture, count, refreshing, isBigDebuff)
            if isBigDebuff then
                P:Size(self, b.indicators.debuffs.bigSize[1], b.indicators.debuffs.bigSize[2])
            else
                P:Size(self, b.indicators.debuffs.normalSize[1], b.indicators.debuffs.normalSize[2])
            end
        end)
    end

    for i = 1, 5 do
        -- defensives
        CreateCooldown(b.indicators.defensiveCooldowns[i])
        -- externals
        CreateCooldown(b.indicators.externalCooldowns[i])
        -- all
        CreateCooldown(b.indicators.allCooldowns[i])
    end

end)