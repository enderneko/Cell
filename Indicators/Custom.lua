local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local I = Cell.iFuncs

-------------------------------------------------
-- custom indicators
-------------------------------------------------
local currentLayout
local enabledIndicators = {}
local customIndicators = {
    ["buff"] = {},
    ["debuff"] = {},
}

Cell.snippetVars.enabledIndicators = enabledIndicators
Cell.snippetVars.customIndicators = customIndicators

--! init enabledIndicators & customIndicators
local function UpdateTablesForIndicator(indicatorTable)
    local indicatorName = indicatorTable["indicatorName"]
    local auraType = indicatorTable["auraType"]

    -- keep custom indicators in table
    if indicatorTable["enabled"] then enabledIndicators[indicatorName] = true end

    -- NOTE: icons is different from other custom indicators, more like the Debuffs indicator
    if indicatorTable["type"] == "icons" then
        customIndicators[auraType][indicatorName] = {
            ["auras"] = F:ConvertSpellTable(indicatorTable["auras"], indicatorTable["trackByName"]), -- auras to match
            ["found"] = {},
            ["num"] = indicatorTable["num"],
        }
    elseif indicatorTable["type"] == "blocks" then
        customIndicators[auraType][indicatorName] = {
            ["auras"] = F:ConvertSpellTable_WithColor(indicatorTable["auras"], indicatorTable["trackByName"]), -- auras to match
            ["hasColor"] = true,
            ["found"] = {},
            ["num"] = indicatorTable["num"],
        }
    elseif indicatorTable["type"] == "border" then
        customIndicators[auraType][indicatorName] = {
            ["auras"] = F:ConvertSpellTable_WithColor(indicatorTable["auras"], indicatorTable["trackByName"]), -- auras to match
            ["hasColor"] = true,
            ["top"] = {},
            ["topOrder"] = {},
        }
    else
        customIndicators[auraType][indicatorName] = {
            ["auras"] = F:ConvertSpellTable(indicatorTable["auras"], indicatorTable["trackByName"]), -- auras to match
            ["top"] = {}, -- top aura details
            ["topOrder"] = {}, -- top aura order
        }
    end

    customIndicators[auraType][indicatorName]["name"] = indicatorTable["name"]

    if auraType == "buff" then
        customIndicators[auraType][indicatorName]["castBy"] = indicatorTable["castBy"]
        customIndicators[auraType][indicatorName]["_auras"] = F:Copy(indicatorTable["auras"]) --* save ids
        customIndicators[auraType][indicatorName]["trackByName"] = indicatorTable["trackByName"]
    end
end

function I.CreateIndicator(parent, indicatorTable, noTableUpdate)
    local indicatorName = indicatorTable["indicatorName"]
    local indicator
    if indicatorTable["type"] == "icon" then
        indicator = I.CreateAura_BarIcon(parent:GetName()..indicatorName, parent.widgets.indicatorFrame)
    elseif indicatorTable["type"] == "text" then
        indicator = I.CreateAura_Text(parent:GetName()..indicatorName, parent.widgets.indicatorFrame)
    elseif indicatorTable["type"] == "bar" then
        indicator = I.CreateAura_Bar(parent:GetName()..indicatorName, parent.widgets.indicatorFrame)
    elseif indicatorTable["type"] == "rect" then
        indicator = I.CreateAura_Rect(parent:GetName()..indicatorName, parent.widgets.indicatorFrame)
    elseif indicatorTable["type"] == "icons" then
        indicator = I.CreateAura_Icons(parent:GetName()..indicatorName, parent.widgets.indicatorFrame, 10)
    elseif indicatorTable["type"] == "color" then
        indicator = I.CreateAura_Color(parent:GetName()..indicatorName, parent)
    elseif indicatorTable["type"] == "texture" then
        indicator = I.CreateAura_Texture(parent:GetName()..indicatorName, parent.widgets.indicatorFrame)
    elseif indicatorTable["type"] == "glow" then
        indicator = I.CreateAura_Glow(parent:GetName()..indicatorName, parent.widgets.highLevelFrame)
    elseif indicatorTable["type"] == "overlay" then
        indicator = I.CreateAura_Overlay(parent:GetName()..indicatorName, parent)
    elseif indicatorTable["type"] == "block" then
        indicator = I.CreateAura_Block(parent:GetName()..indicatorName, parent.widgets.indicatorFrame)
    elseif indicatorTable["type"] == "blocks" then
        indicator = I.CreateAura_Blocks(parent:GetName()..indicatorName, parent.widgets.indicatorFrame, 10)
    elseif indicatorTable["type"] == "border" then
        indicator = I.CreateAura_Border(parent:GetName()..indicatorName, parent.widgets.highLevelFrame)
    end
    parent.indicators[indicatorName] = indicator

    if not noTableUpdate then
        UpdateTablesForIndicator(indicatorTable)
    end

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
        UpdateTablesForIndicator(Cell.vars.currentLayoutTable.indicators[i])
    end

    -- update currentLayout
    currentLayout = Cell.vars.currentLayout
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
        customIndicators[value][indicatorName]["_auras"] = F:Copy(value2) --* save ids
        if customIndicators[value][indicatorName]["hasColor"] then
            customIndicators[value][indicatorName]["auras"] = F:ConvertSpellTable_WithColor(value2, customIndicators[value][indicatorName]["trackByName"])
        else
            customIndicators[value][indicatorName]["auras"] = F:ConvertSpellTable(value2, customIndicators[value][indicatorName]["trackByName"])
        end
    elseif setting == "checkbutton" then
        if customIndicators["buff"][indicatorName] then
            customIndicators["buff"][indicatorName][value] = value2
            if value == "trackByName" then
                if customIndicators["buff"][indicatorName]["hasColor"] then
                    customIndicators["buff"][indicatorName]["auras"] = F:ConvertSpellTable_WithColor(customIndicators["buff"][indicatorName]["_auras"], value2)
                else
                    customIndicators["buff"][indicatorName]["auras"] = F:ConvertSpellTable(customIndicators["buff"][indicatorName]["_auras"], value2)
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
Cell:RegisterCallback("UpdateIndicators", "UpdateCustomIndicators", UpdateCustomIndicators)

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

function I.UpdateCustomIndicators(unitButton, auraInfo)
    local unit = unitButton.states.displayedUnit

    local auraType = auraInfo.isHelpful and "buff" or "debuff"
    local icon = auraInfo.icon
    local debuffType = auraInfo.isHarmful and (auraInfo.dispelName or "") or nil
    local count = auraInfo.applications
    local duration = auraInfo.duration
    local start = (auraInfo.expirationTime or 0) - auraInfo.duration
    local castByMe = auraInfo.sourceUnit == "player" or auraInfo.sourceUnit == "pet"

    -- check Bleed
    if auraInfo.isHarmful then
        debuffType = I.CheckDebuffType(debuffType, auraInfo.spellId)
    end

    for indicatorName, indicatorTable in pairs(customIndicators[auraType]) do
        if indicatorName and enabledIndicators[indicatorName] and unitButton.indicators[indicatorName] then
            local spell  --* trackByName
            if indicatorTable["trackByName"] then
                spell = auraInfo.name
            else
                spell = auraInfo.spellId
            end

            if indicatorTable["auras"][spell] or (indicatorTable["auras"][0] and duration ~= 0) then -- is in indicator spell list
                if auraType == "buff" then
                    -- check caster
                    if (indicatorTable["castBy"] == "me" and castByMe) or (indicatorTable["castBy"] == "others" and not castByMe) or (indicatorTable["castBy"] == "anyone") then
                        Update(unitButton.indicators[indicatorName], indicatorTable, unit, spell, start, duration, debuffType, icon, count, auraInfo.refreshing)
                    end
                else -- debuff
                    Update(unitButton.indicators[indicatorName], indicatorTable, unit, spell, start, duration, debuffType, icon, count, auraInfo.refreshing)
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
    if a[1] and b[1] then
        return a[1] < b[1]
    else
        return a[2] <= b[2]
    end
end

function I.ShowCustomIndicators(unitButton, auraType)
    if Cell.vars.currentLayout ~= currentLayout then return end

    local unit = unitButton.states.displayedUnit
    for indicatorName, indicatorTable in pairs(customIndicators[auraType]) do
        local indicator = unitButton.indicators[indicatorName]
        if indicator and enabledIndicators[indicatorName] then
            if indicatorTable["num"] then
                local t = indicatorTable["found"][unit]
                sort(t, comparator)
                for i = 1, indicatorTable["num"] do
                    if not t[i] then break end
                    -- 1:order, 2:start, 3:duration, 4:debuffType, 5:icon, 6:count, 7:refreshing, 8:color
                    indicator[i]:SetCooldown(t[i][2], t[i][3], t[i][4], t[i][5], t[i][6], t[i][7], t[i][8])
                    indicator:Show()
                end
                indicator:UpdateSize()
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