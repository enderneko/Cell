-------------------------------------------------
-- override
-------------------------------------------------
local I = Cell.iFuncs
local P = Cell.pixelPerfectFuncs

local function Bar_SetFont(frame, font, size, flags, anchor, xOffset, yOffset, color)
    I.SetFont(frame.stack, frame, font, size, flags, anchor, xOffset, yOffset, color)
end

local function Bar_SetCooldown(bar, start, duration, debuffType, texture, count)
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

    bar.stack:SetText((count == 0 or count == 1) and "" or count)
    bar:Show()
end

function I.CreateAura_Bar(name, parent)
    local bar = CreateFrame("StatusBar", name, parent, "BackdropTemplate")
    bar:SetStatusBarTexture(Cell.vars.whiteTexture)
    P.Size(bar, 18, 4)
    bar:SetBackdrop({bgFile=Cell.vars.whiteTexture})
    bar:SetBackdropColor(0.07, 0.07, 0.07, 0.7)
    bar:Hide()
    bar.indicatorType = "bar"

    bar.stack = bar:CreateFontString(nil, "OVERLAY")

    bar.SetFont = Bar_SetFont
    bar.SetCooldown = Bar_SetCooldown

    function bar:SetColors(colors)
        bar.colors = colors
    end

    function bar:ShowStack(show)
        if show then
            bar.stack:Show()
        else
            bar.stack:Hide()
        end
    end

    function bar:UpdatePixelPerfect()
        P.Resize(bar)
        P.Repoint(bar)
    end

    return bar
end