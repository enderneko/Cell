--------------------------------------------------------------------
-- 2024-05-18 02:09:07 GMT+8
-- remove dispel type border color (only Debuffs indicator)
--------------------------------------------------------------------
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

local function BarIcon_SetCooldown(frame, start, duration, debuffType, texture, count, refreshing, isBigDebuff)
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

    frame.spark:SetColorTexture(0.5, 0.5, 0.5, 1)
    frame:SetBackdropColor(0, 0, 0, 1)
    frame.icon:SetTexture(texture)
    frame.maskIcon:SetTexture(texture)
    frame.stack:SetText((count == 0 or count == 1) and "" or count)
    frame:Show()

    if refreshing then
        frame.ag:Play()
    end

    if strfind(frame:GetName(), "Debuff%d+$") then
        if isBigDebuff then
            local debuffs = frame:GetParent()
            if isBigDebuff then
                P:Size(frame, debuffs.bigSize[1], debuffs.bigSize[2])
            else
                P:Size(frame, debuffs.normalSize[1], debuffs.normalSize[2])
            end
        end
    end
end

F:IterateAllUnitButtons(function(b)
    local debuffs = b.indicators.debuffs
    for i = 1, 10 do
        debuffs[i].SetCooldown = BarIcon_SetCooldown
    end
end)