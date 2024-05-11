-- WRATH ONLY, BUFFS ONLY

-- show buffs from anyone 无视来源
local ignoreSource = {
    -- ["spellName"] = true,
    -- [spellId] = true,
}

-- filter out buffs from others 仅显示我的
local filterOutOthers = {
    -- ["spellName"] = true,
    -- [spellId] = true,
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
                    local show
                    if ignoreSource[spellId] or ignoreSource[spellName] then
                        show = true
                    elseif filterOutOthers[spellId] or filterOutOthers[spellName] then
                        show = castByMe
                    else
                        show = (indicatorTable["castBy"] == "me" and castByMe) or (indicatorTable["castBy"] == "anyone")
                    end
                    if show then
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