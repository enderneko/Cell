local _, Cell = ...
local L = Cell.L
---@type CellFuncs
local F = Cell.funcs
---@class CellIndicatorFuncs
local I = Cell.iFuncs

-------------------------------------------------
-- custom indicators
-------------------------------------------------
local enabledIndicators = {}
local customIndicators = {
    ["buff"] = {},
    ["debuff"] = {},
}

Cell.snippetVars.enabledIndicators = enabledIndicators
Cell.snippetVars.customIndicators = customIndicators

--! init enabledIndicators & customIndicators
function I.UpdateIndicatorTable(indicatorTable)
    local indicatorName = indicatorTable["indicatorName"]
    local auraType = indicatorTable["auraType"]

    -- keep custom indicators in table
    if indicatorTable["enabled"] then enabledIndicators[indicatorName] = true end

    -- NOTE: icons is different from other custom indicators, more like the Debuffs indicator
    if indicatorTable["type"] == "icons" then
        customIndicators[auraType][indicatorName] = {
            ["auras"] = F.ConvertSpellTable(indicatorTable["auras"], indicatorTable["trackByName"]), -- auras to match
            ["found"] = {},
            ["num"] = indicatorTable["num"],
        }
    elseif indicatorTable["type"] == "bars" or indicatorTable["type"] == "blocks" then
        customIndicators[auraType][indicatorName] = {
            ["auras"] = F.ConvertSpellTable_WithColor(indicatorTable["auras"], indicatorTable["trackByName"]), -- auras to match
            ["hasColor"] = true,
            ["found"] = {},
            ["num"] = indicatorTable["num"],
        }
    elseif indicatorTable["type"] == "border" then
        customIndicators[auraType][indicatorName] = {
            ["auras"] = F.ConvertSpellTable_WithColor(indicatorTable["auras"], indicatorTable["trackByName"]), -- auras to match
            ["hasColor"] = true,
            ["top"] = {},
            ["topOrder"] = {},
        }
    else
        customIndicators[auraType][indicatorName] = {
            ["auras"] = F.ConvertSpellTable(indicatorTable["auras"], indicatorTable["trackByName"]), -- auras to match
            ["top"] = {}, -- top aura details
            ["topOrder"] = {}, -- top aura order
        }
    end

    customIndicators[auraType][indicatorName]["name"] = indicatorTable["name"]
    customIndicators[auraType][indicatorName]["type"] = indicatorTable["type"]
    customIndicators[auraType][indicatorName]["castBy"] = indicatorTable["castBy"]

    if auraType == "buff" then
        customIndicators[auraType][indicatorName]["_auras"] = F.Copy(indicatorTable["auras"]) --* save ids
        customIndicators[auraType][indicatorName]["trackByName"] = indicatorTable["trackByName"]
    end
end

function I.CreateIndicator(parent, indicatorTable)
    local indicatorName = indicatorTable["indicatorName"]
    local indicator
    if indicatorTable["type"] == "icon" then
        indicator = I.CreateAura_BarIcon(nil, parent.widgets.indicatorFrame)
    elseif indicatorTable["type"] == "text" then
        indicator = I.CreateAura_Text(nil, parent.widgets.indicatorFrame)
    elseif indicatorTable["type"] == "bar" then
        indicator = I.CreateAura_Bar(nil, parent.widgets.indicatorFrame)
    elseif indicatorTable["type"] == "bars" then
        indicator = I.CreateAura_Bars(nil, parent.widgets.indicatorFrame, 10)
    elseif indicatorTable["type"] == "rect" then
        indicator = I.CreateAura_Rect(nil, parent.widgets.indicatorFrame)
    elseif indicatorTable["type"] == "icons" then
        indicator = I.CreateAura_Icons(nil, parent.widgets.indicatorFrame, 10)
    elseif indicatorTable["type"] == "color" then
        indicator = I.CreateAura_Color(nil, parent)
    elseif indicatorTable["type"] == "texture" then
        indicator = I.CreateAura_Texture(nil, parent.widgets.indicatorFrame)
    elseif indicatorTable["type"] == "glow" then
        indicator = I.CreateAura_Glow(nil, parent.widgets.highLevelFrame)
    elseif indicatorTable["type"] == "overlay" then
        indicator = I.CreateAura_Overlay(nil, parent)
    elseif indicatorTable["type"] == "block" then
        indicator = I.CreateAura_Block(nil, parent.widgets.indicatorFrame)
    elseif indicatorTable["type"] == "blocks" then
        indicator = I.CreateAura_Blocks(nil, parent.widgets.indicatorFrame, 10)
    elseif indicatorTable["type"] == "border" then
        indicator = I.CreateAura_Border(nil, parent.widgets.highLevelFrame)
    end
    parent.indicators[indicatorName] = indicator

    return indicator
end

function I.RemoveIndicator(parent, indicatorName, auraType)
    local indicator = parent.indicators[indicatorName]
    indicator:ClearAllPoints()
    indicator:Hide()
    indicator:SetParent(nil)
    parent.indicators[indicatorName] = nil
    enabledIndicators[indicatorName] = nil
    customIndicators[auraType][indicatorName] = nil
end

-- used for switching to a new layout
function I.RemoveAllCustomIndicators(parent)
    -- if parent ~= CellIndicatorsPreviewButton then
    --     wipe(enabledIndicators)
    --     wipe(customIndicators["buff"])
    --     wipe(customIndicators["debuff"])
    -- end

    for indicatorName, indicator in pairs(parent.indicators) do
        if string.find(indicatorName, "^indicator") then
            indicator:ClearAllPoints()
            indicator:Hide()
            indicator:SetParent(nil)
            parent.indicators[indicatorName] = nil
        end
    end
end

function I.ResetCustomIndicatorTables()
    -- clear
    wipe(enabledIndicators)
    wipe(customIndicators["buff"])
    wipe(customIndicators["debuff"])

    -- update customs
    for i = Cell.defaults.builtIns + 1, #Cell.vars.currentLayoutTable.indicators do
        I.UpdateIndicatorTable(Cell.vars.currentLayoutTable.indicators[i])
    end
end

local function UpdateCustomIndicators(layout, indicatorName, setting, value, value2)
    if layout and layout ~= Cell.vars.currentLayout then return end

    if not indicatorName or not string.find(indicatorName, "^indicator") then return end

    if setting == "enabled" then
        if value then
            enabledIndicators[indicatorName] = true
        else
            enabledIndicators[indicatorName] = nil
        end
    elseif setting == "auras" then
        customIndicators[value][indicatorName]["_auras"] = F.Copy(value2) --* save ids
        if customIndicators[value][indicatorName]["hasColor"] then
            customIndicators[value][indicatorName]["auras"] = F.ConvertSpellTable_WithColor(value2, customIndicators[value][indicatorName]["trackByName"])
        else
            customIndicators[value][indicatorName]["auras"] = F.ConvertSpellTable(value2, customIndicators[value][indicatorName]["trackByName"])
        end
    elseif setting == "checkbutton" then
        if customIndicators["buff"][indicatorName] then
            customIndicators["buff"][indicatorName][value] = value2
            if value == "trackByName" then
                if customIndicators["buff"][indicatorName]["hasColor"] then
                    customIndicators["buff"][indicatorName]["auras"] = F.ConvertSpellTable_WithColor(customIndicators["buff"][indicatorName]["_auras"], value2)
                else
                    customIndicators["buff"][indicatorName]["auras"] = F.ConvertSpellTable(customIndicators["buff"][indicatorName]["_auras"], value2)
                end
            end
        elseif customIndicators["debuff"][indicatorName] then
            customIndicators["debuff"][indicatorName][value] = value2
        end
    else -- num, castBy
        if customIndicators["buff"][indicatorName] then
            customIndicators["buff"][indicatorName][setting] = value
        elseif customIndicators["debuff"][indicatorName] then
            customIndicators["debuff"][indicatorName][setting] = value
        end
    end
end
Cell.RegisterCallback("UpdateIndicators", "UpdateCustomIndicators", UpdateCustomIndicators)

-------------------------------------------------
-- reset
-------------------------------------------------
function I.ResetCustomIndicators(unitButton, auraType)
    local unit = unitButton.states.displayedUnit

    for indicatorName, indicatorTable in pairs(customIndicators[auraType]) do
        if enabledIndicators[indicatorName] and unitButton.indicators[indicatorName] then
            unitButton.indicators[indicatorName]:Hide(true)
            if indicatorTable["num"] then
                if not indicatorTable["found"][unit] then
                    indicatorTable["found"][unit] = {}
                else
                    wipe(indicatorTable["found"][unit])
                end
            else
                indicatorTable["topOrder"][unit] = 999
                if not indicatorTable["top"][unit] then
                    indicatorTable["top"][unit] = {}
                else
                    wipe(indicatorTable["top"][unit])
                end
            end
        end
    end
end

-------------------------------------------------
-- update
-------------------------------------------------
local function Update(indicator, indicatorTable, unit, spell, start, duration, debuffType, icon, count, refreshing)
    if indicatorTable["num"] then
        if indicatorTable["hasColor"] then
            tinsert(indicatorTable["found"][unit], {indicatorTable["auras"][spell][1], start, duration, debuffType, icon, count, refreshing, indicatorTable["auras"][spell][2]})
        else
            tinsert(indicatorTable["found"][unit], {indicatorTable["auras"][spell], start, duration, debuffType, icon, count, refreshing})
        end
    else
        if indicatorTable["hasColor"] then
            if indicatorTable["auras"][spell][1] < indicatorTable["topOrder"][unit] then
                indicatorTable["topOrder"][unit] = indicatorTable["auras"][spell][1]
                indicatorTable["top"][unit]["start"] = start
                indicatorTable["top"][unit]["duration"] = duration
                indicatorTable["top"][unit]["debuffType"] = debuffType
                indicatorTable["top"][unit]["texture"] = icon
                indicatorTable["top"][unit]["count"] = count
                indicatorTable["top"][unit]["refreshing"] = refreshing
                indicatorTable["top"][unit]["color"] = indicatorTable["auras"][spell][2]
            end
        else
            if indicatorTable["auras"][spell] < indicatorTable["topOrder"][unit] then
                indicatorTable["topOrder"][unit] = indicatorTable["auras"][spell]
                indicatorTable["top"][unit]["start"] = start
                indicatorTable["top"][unit]["duration"] = duration
                indicatorTable["top"][unit]["debuffType"] = debuffType
                indicatorTable["top"][unit]["texture"] = icon
                indicatorTable["top"][unit]["count"] = count
                indicatorTable["top"][unit]["refreshing"] = refreshing
            end
        end
    end
end

function I.UpdateCustomIndicators(unitButton, auraType, spellId, spellName, start, duration, debuffType, icon, count, refreshing, castByMe)
    local unit = unitButton.states.displayedUnit

    for indicatorName, indicatorTable in pairs(customIndicators[auraType]) do
        if indicatorName and enabledIndicators[indicatorName] and unitButton.indicators[indicatorName] then
            local spell  --* trackByName
            if indicatorTable["trackByName"] then
                spell = spellName
            else
                spell = spellId
            end

            if indicatorTable["auras"][spell] or (indicatorTable["auras"][0] and duration ~= 0) then -- is in indicator spell list
                -- check caster
                if (indicatorTable["castBy"] == "me" and castByMe) or (indicatorTable["castBy"] == "others" and not castByMe) or (indicatorTable["castBy"] == "anyone") then
                    if auraType == "buff" then
                        Update(unitButton.indicators[indicatorName], indicatorTable, unit, spell, start, duration, debuffType, icon, count, refreshing)
                    else -- debuff
                        Update(unitButton.indicators[indicatorName], indicatorTable, unit, spell, start, duration, debuffType, icon, count, refreshing)
                    end
                end
            end
        end
    end
end

-------------------------------------------------
-- show
-------------------------------------------------
local sort = table.sort
local function comparator(a, b)
    return a[1] < b[1]
end

function I.ShowCustomIndicators(unitButton, auraType)
    if not unitButton._indicatorsReady then return end

    local unit = unitButton.states.displayedUnit
    for indicatorName, indicatorTable in pairs(customIndicators[auraType]) do
        local indicator = unitButton.indicators[indicatorName]
        if indicator and enabledIndicators[indicatorName] then
            if indicatorTable["num"] then
                local t = indicatorTable["found"][unit]
                if t[1] then
                    sort(t, comparator)
                    for i = 1, indicatorTable["num"] do
                        if not t[i] then break end
                        -- 1:order, 2:start, 3:duration, 4:debuffType, 5:icon, 6:count, 7:refreshing, 8:color
                        indicator[i]:SetCooldown(t[i][2], t[i][3], t[i][4], t[i][5], t[i][6], t[i][7], t[i][8])
                    end
                    indicator:Show()
                    indicator:UpdateSize()
                end
            else
                if indicatorTable["top"][unit] and indicatorTable["top"][unit]["start"] then
                    indicator:SetCooldown(
                        indicatorTable["top"][unit]["start"],
                        indicatorTable["top"][unit]["duration"],
                        indicatorTable["top"][unit]["debuffType"],
                        indicatorTable["top"][unit]["texture"],
                        indicatorTable["top"][unit]["count"],
                        indicatorTable["top"][unit]["refreshing"],
                        indicatorTable["top"][unit]["color"]
                    )
                end
            end
        end
    end
end

--[=[
function I.ResetCustomIndicators(unit, auraType)
    for indicatorName, indicatorTable in pairs(customIndicators[auraType]) do
        if indicatorTable["isIcons"] then
            indicatorTable["found"][unit] = 1
        else
            indicatorTable["topOrder"][unit] = 999
            if not indicatorTable["top"][unit] then
                indicatorTable["top"][unit] = {}
            else
                wipe(indicatorTable["top"][unit])
            end
        end
    end
end

function I.CheckCustomIndicators(unit, unitButton, auraType, spellId, name, start, duration, debuffType, texture, count, refreshing, castByMe)
    for indicatorName, indicatorTable in pairs(customIndicators[auraType]) do
        if enabledIndicators[indicatorName] and unitButton.indicators[indicatorName] then
            if indicatorTable["trackByName"] then spellId = name end --* wrath
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
                            unitButton.indicators[indicatorName]:UpdateSize(indicatorTable["found"][unit])
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

function I.ShowCustomIndicators(unit, unitButton, auraType)
    for indicatorName, indicatorTable in pairs(customIndicators[auraType]) do
        if enabledIndicators[indicatorName] and unitButton.indicators[indicatorName] then
            if indicatorTable["isIcons"] then
                for i = indicatorTable["found"][unit], 10 do
                    unitButton.indicators[indicatorName][i]:Hide()
                end
                if indicatorTable["found"][unit] == 1 then
                    unitButton.indicators[indicatorName]:Hide()
                end
            else
                if indicatorTable["top"][unit]["start"] then
                    unitButton.indicators[indicatorName]:SetCooldown(
                        indicatorTable["top"][unit]["start"],
                        indicatorTable["top"][unit]["duration"],
                        indicatorTable["top"][unit]["debuffType"],
                        indicatorTable["top"][unit]["texture"],
                        indicatorTable["top"][unit]["count"],
                        indicatorTable["top"][unit]["refreshing"])
                else
                    unitButton.indicators[indicatorName]:Hide()
                end
            end
        end
    end
end
]=]