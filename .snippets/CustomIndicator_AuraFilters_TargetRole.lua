-- WRATH ONLY, BUFFS ONLY 仅怀旧服

-- filter by target role 按目标职责过滤
local filters = {
    -- ["spellName"] = {
    --     ["TANK"] = true,
    --     ["HEALER"] = true,
    --     ["DAMAGER"] = true,
    -- },
}

-------------------------------------------------
-- override
-------------------------------------------------
local enabledIndicators = Cell.snippetVars.enabledIndicators
local customIndicators = Cell.snippetVars.customIndicators

local function Update(indicator, indicatorTable, unit, spellId, start, duration, debuffType, icon, count, refreshing)
    if indicatorTable["isIcons"] then
        if indicatorTable["found"][unit] < indicatorTable["num"] then
            indicatorTable["found"][unit] = indicatorTable["found"][unit] + 1
            indicator:UpdateSize(indicatorTable["found"][unit])
            indicator[indicatorTable["found"][unit]]:SetCooldown(start, duration, debuffType, icon, count, refreshing)
            indicator:Show()
        end
    else
        if indicatorTable["auras"][spellId] < indicatorTable["topOrder"][unit] then
            indicatorTable["topOrder"][unit] = indicatorTable["auras"][spellId]
            indicatorTable["top"][unit]["start"] = start
            indicatorTable["top"][unit]["duration"] = duration
            indicatorTable["top"][unit]["debuffType"] = debuffType
            indicatorTable["top"][unit]["texture"] = icon
            indicatorTable["top"][unit]["count"] = count
            indicatorTable["top"][unit]["refreshing"] = refreshing
        end
    end
end

function Cell.iFuncs:UpdateCustomIndicators(unitButton, auraType, spellId, spellName, start, duration, debuffType, icon, count, refreshing, castByMe)
    local unit = unitButton.states.displayedUnit

    for indicatorName, indicatorTable in pairs(customIndicators[auraType]) do
        if indicatorName and enabledIndicators[indicatorName] and unitButton.indicators[indicatorName] then
            local spell  --* trackByName
            if indicatorTable["trackByName"] then
                spell = spellName
            else
                spell = spellId
            end
            
            if indicatorTable["auras"][spell] or indicatorTable["auras"][0] then -- is in indicator spell list
                if auraType == "buff" then
                    local show = true
                    if unitButton.states.role and unitButton.states.role ~= "NONE" and filters[spellName] then
                        show = filters[spellName][unitButton.states.role]
                    end
                    if show and (indicatorTable["castBy"] == "me" and castByMe) or (indicatorTable["castBy"] == "anyone") then
                        Update(unitButton.indicators[indicatorName], indicatorTable, unit, spell, start, duration, debuffType, icon, count, refreshing)
                    end
                else -- debuff
                    Update(unitButton.indicators[indicatorName], indicatorTable, unit, spell, start, duration, debuffType, icon, count, refreshing)
                end
            end
        end
    end
end

function Cell.iFuncs:ShowCustomIndicators(unitButton, auraType)
    local unit = unitButton.states.displayedUnit
    for indicatorName, indicatorTable in pairs(customIndicators[auraType]) do
        if indicatorName and enabledIndicators[indicatorName] and unitButton.indicators[indicatorName] then
            if not indicatorTable["isIcons"] then
                if indicatorTable["top"][unit]["start"] then
                    unitButton.indicators[indicatorName]:SetCooldown(
                        indicatorTable["top"][unit]["start"], 
                        indicatorTable["top"][unit]["duration"], 
                        indicatorTable["top"][unit]["debuffType"], 
                        indicatorTable["top"][unit]["texture"], 
                        indicatorTable["top"][unit]["count"], 
                        indicatorTable["top"][unit]["refreshing"])
                end
            end
        end
    end
end