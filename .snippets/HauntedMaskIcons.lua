-- 鬼灵面具：减CD     356968 50  50  50  50  50  0    0  0
local cdr_icon = 648208

-- 鬼灵面具：减伤20%  356968  0   0   0   0   0  0  -20  0
local dr_icon = 2967110

local I = Cell.iFuncs
local enabledIndicators = Cell.snippetVars.enabledIndicators
local customIndicators = Cell.snippetVars.customIndicators

function I:CheckCustomIndicators(unit, unitButton, auraType, spellId, start, duration, debuffType, texture, count, refreshing, castByMe, arg16)
    if spellId == 356968 then
        if arg16 == 50 then
            texture = cdr_icon
        else
            texture = dr_icon
        end
    end

    for indicatorName, indicatorTable in pairs(customIndicators[auraType]) do
        if enabledIndicators[indicatorName] and unitButton.indicators[indicatorName] then
            if indicatorTable["auras"][spellId] or indicatorTable["auras"][0] then -- is in indicator spell list
                if auraType == "buff" then
                    -- check castByMe
                    if indicatorTable["castByMe"] == castByMe then
                        if indicatorTable["isIcons"] then
                            if indicatorTable["found"][unit] <= indicatorTable["num"] then
                                unitButton.indicators[indicatorName]:UpdateSize(indicatorTable["found"][unit])
                                unitButton.indicators[indicatorName][indicatorTable["found"][unit]]:SetCooldown(start, duration, debuffType, texture, count, refreshing)
                                indicatorTable["found"][unit] = indicatorTable["found"][unit] + 1
                                unitButton.indicators[indicatorName]:Show()
                            end
                        else
                            if indicatorTable["auras"][spellId] < indicatorTable["topOrder"][unit] then
                                indicatorTable["topOrder"][unit] = indicatorTable["auras"][spellId]
                                indicatorTable["top"][unit]["start"] = start
                                indicatorTable["top"][unit]["duration"] = duration
                                indicatorTable["top"][unit]["debuffType"] = debuffType
                                indicatorTable["top"][unit]["texture"] = texture
                                indicatorTable["top"][unit]["count"] = count
                                indicatorTable["top"][unit]["refreshing"] = refreshing
                            end
                        end
                    end
                else -- debuff
                    if indicatorTable["isIcons"] then
                        if indicatorTable["found"][unit] <= indicatorTable["num"] then
                            unitButton.indicators[indicatorName][indicatorTable["found"][unit]]:SetCooldown(start, duration, debuffType, texture, count, refreshing)
                            indicatorTable["found"][unit] = indicatorTable["found"][unit] + 1
                            unitButton.indicators[indicatorName]:Show()
                        end
                    else
                        if  indicatorTable["auras"][spellId] < indicatorTable["topOrder"][unit] then
                            indicatorTable["topOrder"][unit] = indicatorTable["auras"][spellId]
                            indicatorTable["top"][unit]["start"] = start
                            indicatorTable["top"][unit]["duration"] = duration
                            indicatorTable["top"][unit]["debuffType"] = debuffType
                            indicatorTable["top"][unit]["texture"] = texture
                            indicatorTable["top"][unit]["count"] = count
                            indicatorTable["top"][unit]["refreshing"] = refreshing
                        end
                    end
                end
            end
        end
    end
end