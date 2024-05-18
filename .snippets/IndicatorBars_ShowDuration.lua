-------------------------------------------------
-- 2024-05-18 02:08:29 GMT+8
-------------------------------------------------
-- nil means to use stack text settings
local ANCHOR = nil -- "CENTER", "TOP", "TOPLEFT", ...
local X = nil -- number
local Y = nil -- number
local COLOR = nil -- table: {r, g, b}, e.g. {1, 0.5, 0.5}

-------------------------------------------------
-- CreateAura_Bar
-------------------------------------------------
local I = Cell.iFuncs

local function Bar_SetFont(frame, font, size, outline, shadow, anchor, xOffset, yOffset, color)
    I.SetFont(frame.stack, frame, font, size, outline, shadow, anchor, xOffset, yOffset, color)
    I.SetFont(frame.duration, frame, font, size, outline, shadow, ANCHOR or anchor, X or xOffset, Y or yOffset, COLOR or color)
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

        local fmt
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

            -- duration
            if remain > 60 then
                fmt, remain = "%dm", remain/60
            else
                fmt = "%d"
            end

            bar.duration:SetFormattedText(fmt, remain)
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
    bar.duration = bar:CreateFontString(nil, "OVERLAY")

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
        
    return bar
end