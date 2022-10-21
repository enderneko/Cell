-- remove dispel type border color (excluding RaidDebuffs)
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

local function BarIcon_SetCooldown(frame, start, duration, debuffType, texture, count, refreshing, isBigDebuff)
    if duration == 0 then
        frame.cooldown:Hide()
        frame.duration:Hide()
        frame:SetScript("OnUpdate", nil)
    else
        if frame.showDuration then
            frame.cooldown:Hide()
            frame.duration:Show()
            frame:SetScript("OnUpdate", function()
                local remain = duration-(GetTime()-start)
                if remain < 0 then remain = 0 end

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
                    frame.duration:SetTextColor(1, 1, 1)
                end

                -- format
                if remain > 60 then
                    remain = string.format("%dm", remain/60)
                else
                    if Cell.vars.iconDurationRoundUp then
                        remain = math.ceil(remain)
                    else
                        if remain < Cell.vars.iconDurationDecimal then
                            remain = string.format("%.1f", remain)
                        else
                            remain = string.format("%d", remain)
                        end
                    end
                end

                frame.duration:SetText(remain)
            end)
        else
            -- init bar values
            frame.cooldown:SetMinMaxValues(0, duration)
            frame.cooldown:SetValue(GetTime()-start)
            frame.cooldown:Show()
            frame.duration:Hide()
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