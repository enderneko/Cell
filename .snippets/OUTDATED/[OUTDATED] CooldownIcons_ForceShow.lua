-- force show icon cooldown animation
-- 强制显示图标冷却动画
local function ShowCooldownAnimation(frame, start, duration)
    if frame.cooldown:GetObjectType() == "StatusBar" then
        frame.cooldown:SetMinMaxValues(0, duration)
        frame.cooldown:SetValue(GetTime()-start)
    else
        frame.cooldown:SetCooldown(start, duration)
    end
        frame.cooldown:Show()
end

-- hook built-in
Cell.funcs.IterateAllUnitButtons(function(b)
    for name, indicator in pairs(b.indicators) do
        if name ~= "raidDebuffs" and indicator[1] then
            for i, icon in ipairs(indicator) do
                if icon.cooldown then
                    hooksecurefunc(icon, "SetCooldown", ShowCooldownAnimation)
                end
            end
        elseif name ~= "targetedSpells" and indicator.cooldown then
            -- no such indicator currently
            hooksecurefunc(indicator, "SetCooldown", ShowCooldownAnimation)
        end
    end
end)

-- hook user created
hooksecurefunc(Cell.iFuncs, "CreateIndicator", function(self, parent, indicatorTable)
    if parent ~= CellIndicatorsPreviewButton then
        if indicatorTable["auraType"] == "buff" then
            local indicator = parent.indicators[indicatorTable["indicatorName"]]
            if indicatorTable["type"] == "icon" then
                hooksecurefunc(indicator, "SetCooldown", ShowCooldownAnimation)
            elseif indicatorTable["type"] == "icons" then
                for _, icon in ipairs(indicator) do
                    hooksecurefunc(icon, "SetCooldown", ShowCooldownAnimation)
                end
            end
        end
    end
end)