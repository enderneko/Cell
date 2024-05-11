-- color indicator icons
-- 自定义指示器图标颜色
local iconColor = {
    -- [spellId] = {r, g, b},
    [367364] = {1, 0.5, 0.5}, -- Reversion - 逆转
    [376788] = {1, 0.4, 0.4}, -- Dream Breath - 梦境吐息
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
            if iconColor[spellId] then
                indicator[indicatorTable["found"][unit]].icon:SetVertexColor(iconColor[spellId][1], iconColor[spellId][2], iconColor[spellId][3])
            else
                indicator[indicatorTable["found"][unit]].icon:SetVertexColor(1, 1, 1)
            end
            indicator:Show()
        end
    else
        if indicatorTable["auras"][spellId] < indicatorTable["topOrder"][unit] then
            indicatorTable["topOrder"][unit] = indicatorTable["auras"][spellId]
            indicatorTable["top"][unit]["spellId"] = spellId
            indicatorTable["top"][unit]["start"] = start
            indicatorTable["top"][unit]["duration"] = duration
            indicatorTable["top"][unit]["debuffType"] = debuffType
            indicatorTable["top"][unit]["texture"] = icon
            indicatorTable["top"][unit]["count"] = count
            indicatorTable["top"][unit]["refreshing"] = refreshing
        end
    end
end

function Cell.iFuncs:UpdateCustomIndicators(unitButton, auraInfo, refreshing)
    local unit = unitButton.states.displayedUnit

    local auraType = auraInfo.isHelpful and "buff" or "debuff"
    local icon = auraInfo.icon
    local debuffType = auraInfo.isHarmful and (auraInfo.dispelName or "")
    local count = auraInfo.applications
    local duration = auraInfo.duration
    local start = (auraInfo.expirationTime or 0) - auraInfo.duration
    local spellId = auraInfo.spellId
    local castByMe = auraInfo.sourceUnit == "player" or auraInfo.sourceUnit == "pet"



    for indicatorName, indicatorTable in pairs(customIndicators[auraType]) do
        if enabledIndicators[indicatorName] and unitButton.indicators[indicatorName] then
            if indicatorTable["auras"][spellId] or indicatorTable["auras"][0] then -- is in indicator spell list
                if auraType == "buff" then
                    -- check caster
                    if (indicatorTable["castBy"] == "me" and castByMe) or (indicatorTable["castBy"] == "others" and not castByMe) or (indicatorTable["castBy"] == "anyone") then
                        Update(unitButton.indicators[indicatorName], indicatorTable, unit, spellId, start, duration, debuffType, icon, count, refreshing)
                    end
                else -- debuff
                    Update(unitButton.indicators[indicatorName], indicatorTable, unit, spellId, start, duration, debuffType, icon, count, refreshing)
                end
            end
        end
    end
end

function Cell.iFuncs:ShowCustomIndicators(unitButton, auraType)
    local unit = unitButton.states.displayedUnit
    for indicatorName, indicatorTable in pairs(customIndicators[auraType]) do
        if enabledIndicators[indicatorName] and unitButton.indicators[indicatorName] then
            if not indicatorTable["isIcons"] then
                if indicatorTable["top"][unit]["start"] then
                    unitButton.indicators[indicatorName]:SetCooldown(
                        indicatorTable["top"][unit]["start"], 
                        indicatorTable["top"][unit]["duration"], 
                        indicatorTable["top"][unit]["debuffType"], 
                        indicatorTable["top"][unit]["texture"], 
                        indicatorTable["top"][unit]["count"], 
                        indicatorTable["top"][unit]["refreshing"])
                    local spellId = indicatorTable["top"][unit]["spellId"]
                    if iconColor[spellId] then
                        unitButton.indicators[indicatorName].icon:SetVertexColor(iconColor[spellId][1], iconColor[spellId][2], iconColor[spellId][3])
                    else
                        unitButton.indicators[indicatorName].icon:SetVertexColor(1, 1, 1)
                    end
                end
            end
        end
    end
end