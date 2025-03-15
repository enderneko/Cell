local addonName, Cell = ...
local L = Cell.L
---@type CellFuncs
local F = Cell.funcs
---@type CellIndicatorFuncs
local I = Cell.iFuncs
---@type PixelPerfectFuncs
local P = Cell.pixelPerfectFuncs
local LCG = LibStub("LibCustomGlow-1.0")

-----------------------------------------
-- Color
-----------------------------------------
local colors = {
    grey = {s="|cFFA7A7A7", t={0.7, 0.7, 0.7}},
    yellow = {s="|cFFFFD100", t= {1, 0.82, 0}},
    orange = {s="|cFFFFC0CB", t= {1, 0.65, 0}},
    firebrick = {s="|cFFFF3030", t={1, 0.19, 0.19}},
    skyblue = {s="|cFF00CCFF", t={0, 0.8, 1}},
    chartreuse = {s="|cFF80FF00", t={0.5, 1, 0}},
}

local class = select(2, UnitClass("player"))
local classColor = {s="|cCCB2B2B2", t={0.7, 0.7, 0.7}}
if class then
    classColor.t[1], classColor.t[2], classColor.t[3], classColor.s = GetClassColor(class)
    classColor.s = "|c"..classColor.s
end

-----------------------------------------
-- Font
-----------------------------------------
local font_title_name = strupper(addonName).."_FONT_WIDGET_TITLE"
local font_title_disable_name = strupper(addonName).."_FONT_WIDGET_TITLE_DISABLE"
local font_name = strupper(addonName).."_FONT_WIDGET"
local font_disable_name = strupper(addonName).."_FONT_WIDGET_DISABLE"
local font_special_name = strupper(addonName).."_FONT_SPECIAL"
local font_class_title_name = strupper(addonName).."_FONT_CLASS_TITLE"
local font_class_name = strupper(addonName).."_FONT_CLASS"

-----------------------------------------
-- indicator settings widgets
-----------------------------------------
local settingWidgets = {} -- store all created widgets

local function CreateSetting_Enabled(parent)
    local widget

    if not settingWidgets["enabled"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_Enabled", parent, 240, 30)
        settingWidgets["enabled"] = widget

        widget.cb = Cell.CreateCheckButton(widget, L["Enabled"])
        widget.cb:SetPoint("TOPLEFT", 5, -8)

        -- callback
        function widget:SetFunc(func)
            widget.cb.onClick = func
        end

        -- show db value
        function widget:SetDBValue(checked)
            widget.cb:SetChecked(checked)
        end
    else
        widget = settingWidgets["enabled"]
    end

    widget:Show()
    return widget
end

local anchorPoints = {"BOTTOM", "BOTTOMLEFT", "BOTTOMRIGHT", "CENTER", "LEFT", "RIGHT", "TOP", "TOPLEFT", "TOPRIGHT"}
local function CreateSetting_Position(parent)
    local widget

    if not settingWidgets["position"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_Position", parent, 240, 141)
        settingWidgets["position"] = widget

        local function GetResult()
            return {widget.anchor:GetSelected(), widget.relativeTo:GetSelected(), widget.relativePoint:GetSelected(), widget.x:GetValue(), widget.y:GetValue()}
        end

        -- anchor
        widget.anchor = Cell.CreateDropdown(widget, 110)
        widget.anchor:SetPoint("TOPLEFT", 5, -20)
        local items = {}
        for _, point in pairs(anchorPoints) do
            tinsert(items, {
                ["text"] = L[point],
                ["value"] = point,
                ["onClick"] = function()
                    widget.func(GetResult())
                end,
            })
        end
        widget.anchor:SetItems(items)

        widget.anchorText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.anchorText:SetText(L["Anchor Point"])
        widget.anchorText:SetPoint("BOTTOMLEFT", widget.anchor, "TOPLEFT", 0, 1)

        -- relative point
        widget.relativePoint = Cell.CreateDropdown(widget, 110)
        widget.relativePoint:SetPoint("TOPLEFT", widget.anchor, "TOPRIGHT", 25, 0)
        items = {}
        for _, point in pairs(anchorPoints) do
            tinsert(items, {
                ["text"] = L[point],
                ["value"] = point,
                ["onClick"] = function()
                    widget.func(GetResult())
                end,
            })
        end
        widget.relativePoint:SetItems(items)

        widget.relativePointText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.relativePointText:SetText(L["Relative Point"])
        widget.relativePointText:SetPoint("BOTTOMLEFT", widget.relativePoint, "TOPLEFT", 0, 1)

        -- relative to
        widget.relativeTo = Cell.CreateDropdown(widget, 110)
        widget.relativeTo:SetPoint("TOPLEFT", widget.anchor, "BOTTOMLEFT", 0, -25)
        widget.relativeTo:SetItems({
            {
                ["text"] = L["Unit Button"],
                ["value"] = "button",
                ["onClick"] = function()
                    widget.func(GetResult())
                end,
            },
            {
                ["text"] = L["Health Bar"],
                ["value"] = "healthBar",
                ["onClick"] = function()
                    widget.func(GetResult())
                end,
            }
        })

        widget.relativeToText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.relativeToText:SetText(L["Relative To"])
        widget.relativeToText:SetPoint("BOTTOMLEFT", widget.relativeTo, "TOPLEFT", 0, 1)

        -- x
        widget.x = Cell.CreateSlider(L["X Offset"], widget, -150, 150, 110, 1)
        widget.x:SetPoint("TOPLEFT", widget.relativeTo, "BOTTOMLEFT", 0, -25)
        widget.x.afterValueChangedFn = function(value)
            widget.func(GetResult())
        end

        -- y
        widget.y = Cell.CreateSlider(L["Y Offset"], widget, -150, 150, 110, 1)
        widget.y:SetPoint("TOPLEFT", widget.x, "TOPRIGHT", 25, 0)
        widget.y.afterValueChangedFn = function(value)
            widget.func(GetResult())
        end

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(positionTable)
            widget.anchor:SetSelectedValue(positionTable[1])
            widget.relativePoint:SetSelectedValue(positionTable[3])
            widget.relativeTo:SetSelectedValue(positionTable[2])
            widget.x:SetValue(positionTable[4])
            widget.y:SetValue(positionTable[5])
        end
    else
        widget = settingWidgets["position"]
    end

    widget:Show()
    return widget
end

local anchorPoints_noHCenter = {"BOTTOMLEFT", "BOTTOMRIGHT", "LEFT", "RIGHT", "TOPLEFT", "TOPRIGHT"}
local function CreateSetting_PositionNoHCenter(parent)
    local widget

    if not settingWidgets["position_noHCenter"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_PositionNoHCenter", parent, 240, 95)
        settingWidgets["position_noHCenter"] = widget

        local function GetResult()
            return {widget.anchor:GetSelected(), widget.relativeTo:GetSelected(), widget.relativePoint:GetSelected(), widget.x:GetValue(), widget.y:GetValue()}
        end

        -- anchor
        widget.anchor = Cell.CreateDropdown(widget, 110)
        widget.anchor:SetPoint("TOPLEFT", 5, -20)
        local items = {}
        for _, point in pairs(anchorPoints_noHCenter) do
            tinsert(items, {
                ["text"] = L[point],
                ["value"] = point,
                ["onClick"] = function()
                    widget.func(GetResult())
                end,
            })
        end
        widget.anchor:SetItems(items)

        widget.anchorText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.anchorText:SetText(L["Anchor Point"])
        widget.anchorText:SetPoint("BOTTOMLEFT", widget.anchor, "TOPLEFT", 0, 1)

        -- relative point
        widget.relativePoint = Cell.CreateDropdown(widget, 110)
        widget.relativePoint:SetPoint("TOPLEFT", widget.anchor, "TOPRIGHT", 25, 0)
        items = {}
        for _, point in pairs(anchorPoints_noHCenter) do
            tinsert(items, {
                ["text"] = L[point],
                ["value"] = point,
                ["onClick"] = function()
                    widget.func(GetResult())
                end,
            })
        end
        widget.relativePoint:SetItems(items)

        widget.relativePointText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.relativePointText:SetText(L["Relative Point"])
        widget.relativePointText:SetPoint("BOTTOMLEFT", widget.relativePoint, "TOPLEFT", 0, 1)

        -- relative to
        widget.relativeTo = Cell.CreateDropdown(widget, 110)
        widget.relativeTo:SetPoint("TOPLEFT", widget.anchor, "BOTTOMLEFT", 0, -25)
        widget.relativeTo:SetItems({
            {
                ["text"] = L["Unit Button"],
                ["value"] = "button",
                ["onClick"] = function()
                    widget.func(GetResult())
                end,
            },
            {
                ["text"] = L["Health Bar"],
                ["value"] = "healthBar",
                ["onClick"] = function()
                    widget.func(GetResult())
                end,
            }
        })

        widget.relativeToText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.relativeToText:SetText(L["Relative To"])
        widget.relativeToText:SetPoint("BOTTOMLEFT", widget.relativeTo, "TOPLEFT", 0, 1)

        -- x
        widget.x = Cell.CreateSlider(L["X Offset"], widget, -150, 150, 110, 1)
        widget.x:SetPoint("TOPLEFT", widget.relativeTo, "BOTTOMLEFT", 0, -25)
        widget.x.afterValueChangedFn = function(value)
            widget.func(GetResult())
        end

        -- y
        widget.y = Cell.CreateSlider(L["Y Offset"], widget, -150, 150, 110, 1)
        widget.y:SetPoint("TOPLEFT", widget.x, "TOPRIGHT", 25, 0)
        widget.y.afterValueChangedFn = function(value)
            widget.func(GetResult())
        end

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(positionTable)
            widget.anchor:SetSelectedValue(positionTable[1])
            widget.relativePoint:SetSelectedValue(positionTable[3])
            widget.relativeTo:SetSelectedValue(positionTable[2])
            widget.x:SetValue(positionTable[4])
            widget.y:SetValue(positionTable[5])
        end
    else
        widget = settingWidgets["position_noHCenter"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_ShieldBarPosition(parent)
    local widget

    if not settingWidgets["shieldBarPosition"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_PositionNoHCenter", parent, 240, 95)
        settingWidgets["shieldBarPosition"] = widget

        widget.anchor = Cell.CreateDropdown(widget, 110)
        widget.anchor:SetPoint("TOPLEFT", 5, -20)
        local items = {}
        for _, point in pairs(anchorPoints_noHCenter) do
            tinsert(items, {
                ["text"] = L[point],
                ["value"] = point,
                ["onClick"] = function()
                    widget.func({point, nil, widget.relativePoint:GetSelected(), widget.x:GetValue(), widget.y:GetValue()})
                    Cell.SetEnabled(true, widget.relativePointText, widget.relativePoint, widget.x, widget.y)
                end,
            })
        end
        tinsert(items, 1, {
            ["text"] = L["Health Bar"],
            ["value"] = "HEALTH_BAR",
            ["onClick"] = function()
                widget.func({"HEALTH_BAR", nil, widget.relativePoint:GetSelected(), widget.x:GetValue(), widget.y:GetValue()})
                Cell.SetEnabled(false, widget.relativePointText, widget.relativePoint, widget.x, widget.y)
            end,
        })
        widget.anchor:SetItems(items)

        widget.anchorText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.anchorText:SetText(L["Anchor Point"])
        widget.anchorText:SetPoint("BOTTOMLEFT", widget.anchor, "TOPLEFT", 0, 1)

        widget.relativePoint = Cell.CreateDropdown(widget, 110)
        widget.relativePoint:SetPoint("LEFT", widget.anchor, "RIGHT", 25, 0)
        items = {}
        for _, point in pairs(anchorPoints_noHCenter) do
            tinsert(items, {
                ["text"] = L[point],
                ["value"] = point,
                ["onClick"] = function()
                    widget.func({widget.anchor:GetSelected(), nil, point, widget.x:GetValue(), widget.y:GetValue()})
                end,
            })
        end
        widget.relativePoint:SetItems(items)

        widget.relativePointText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.relativePointText:SetText(L["To UnitButton's"])
        widget.relativePointText:SetPoint("BOTTOMLEFT", widget.relativePoint, "TOPLEFT", 0, 1)

        widget.x = Cell.CreateSlider(L["X Offset"], widget, -150, 150, 110, 1)
        widget.x:SetPoint("TOPLEFT", widget.anchor, "BOTTOMLEFT", 0, -25)
        widget.x.afterValueChangedFn = function(value)
            widget.func({widget.anchor:GetSelected(), nil, widget.relativePoint:GetSelected(), value, widget.y:GetValue()})
        end

        widget.y = Cell.CreateSlider(L["Y Offset"], widget, -150, 150, 110, 1)
        widget.y:SetPoint("TOPLEFT", widget.relativePoint, "BOTTOMLEFT", 0, -25)
        widget.y.afterValueChangedFn = function(value)
            widget.func({widget.anchor:GetSelected(), nil, widget.relativePoint:GetSelected(), widget.x:GetValue(), value})
        end

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(positionTable)
            widget.anchor:SetSelectedValue(positionTable[1])
            widget.relativePoint:SetSelectedValue(positionTable[3])
            widget.x:SetValue(positionTable[4])
            widget.y:SetValue(positionTable[5])

            Cell.SetEnabled(positionTable[1] ~= "HEALTH_BAR", widget.relativePointText, widget.relativePoint, widget.x, widget.y)
        end
    else
        widget = settingWidgets["shieldBarPosition"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_Anchor(parent)
    local widget

    if not settingWidgets["anchor"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_Anchor", parent, 240, 50)
        settingWidgets["anchor"] = widget

        widget.anchor = Cell.CreateDropdown(widget, 170)
        widget.anchor:SetPoint("TOPLEFT", 5, -20)

        widget.anchor:SetItems({
            {
                ["text"] = L["Health Bar"].." ("..L["Current"]..")",
                ["value"] = "healthbar-current",
                ["onClick"] = function()
                    widget.func("healthbar-current")
                end
            },
            {
                ["text"] = L["Health Bar"].." ("..L["Loss"]..")",
                ["value"] = "healthbar-loss",
                ["onClick"] = function()
                    widget.func("healthbar-loss")
                end
            },
            {
                ["text"] = L["Health Bar"].." ("..L["Entire"]..")",
                ["value"] = "healthbar-entire",
                ["onClick"] = function()
                    widget.func("healthbar-entire")
                end
            },
            {
                ["text"] = L["Unit Button"],
                ["value"] = "unitButton",
                ["onClick"] = function()
                    widget.func("unitButton")
                end
            },
        })

        widget.anchorText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.anchorText:SetText(L["Anchor To"])
        widget.anchorText:SetPoint("BOTTOMLEFT", widget.anchor, "TOPLEFT", 0, 1)

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(anchor)
            widget.anchor:SetSelectedValue(anchor)
        end
    else
        widget = settingWidgets["anchor"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_FrameLevel(parent)
    local widget

    if not settingWidgets["frameLevel"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_FrameLevel", parent, 240, 50)
        settingWidgets["frameLevel"] = widget

        widget.frameLevel = Cell.CreateSlider(L["Frame Level"], widget, 1, 100, 110, 1)
        widget.frameLevel:SetPoint("TOPLEFT", widget, 5, -20)
        widget.frameLevel.afterValueChangedFn = function(value)
            widget.func(value)
        end

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(frameLevel, maxFrameLevel)
            widget.frameLevel:UpdateMinMaxValues(1, maxFrameLevel)
            widget.frameLevel:SetValue(frameLevel)
        end
    else
        widget = settingWidgets["frameLevel"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_Size(parent)
    local widget

    if not settingWidgets["size"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_Size", parent, 240, 50)
        settingWidgets["size"] = widget

        widget.width = Cell.CreateSlider(L["Width"], widget, 3, 500, 110, 1)
        widget.width:SetPoint("TOPLEFT", widget, 5, -20)
        widget.width.afterValueChangedFn = function(value)
            widget.func({value, widget.height:GetValue()})
        end

        widget.height = Cell.CreateSlider(L["Height"], widget, 3, 500, 110, 1)
        widget.height:SetPoint("LEFT", widget.width, "RIGHT", 25, 0)
        widget.height.afterValueChangedFn = function(value)
            widget.func({widget.width:GetValue(), value})
        end

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(sizeTable)
            widget.width:SetValue(sizeTable[1])
            widget.height:SetValue(sizeTable[2])
        end
    else
        widget = settingWidgets["size"]
    end

    widget:Show()
    return widget
end

-- local function CreateSetting_SizeBar(parent)
--     local widget

--     if not settingWidgets["size-bar"] then
--         widget = Cell.CreateFrame("CellIndicatorSettings_SizeBar", parent, 240, 50)
--         settingWidgets["size-bar"] = widget

--         widget.width = Cell.CreateSlider(L["Width"], widget, 3, 500, 110, 1)
--         widget.width:SetPoint("TOPLEFT", widget, 5, -20)
--         widget.width.afterValueChangedFn = function(value)
--             widget.func({value, widget.height:GetValue()})
--         end

--         widget.height = Cell.CreateSlider(L["Height"], widget, 3, 500, 110, 1)
--         widget.height:SetPoint("LEFT", widget.width, "RIGHT", 25, 0)
--         widget.height.afterValueChangedFn = function(value)
--             widget.func({widget.width:GetValue(), value})
--         end

--         -- callback
--         function widget:SetFunc(func)
--             widget.func = func
--         end

--         -- show db value
--         function widget:SetDBValue(sizeTable)
--             widget.width:SetValue(sizeTable[1])
--             widget.height:SetValue(sizeTable[2])
--         end
--     else
--         widget = settingWidgets["size-bar"]
--     end

--     widget:Show()
--     return widget
-- end

local function CreateSetting_SizeSquare(parent)
    local widget

    if not settingWidgets["size-square"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_SizeSquare", parent, 240, 50)
        settingWidgets["size-square"] = widget

        widget.size = Cell.CreateSlider(L["Size"], widget, 1, 200, 110, 1)
        widget.size:SetPoint("TOPLEFT", widget, 5, -20)
        widget.size.afterValueChangedFn = function(value)
            widget.func({value, value})
        end

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(sizeTable)
            widget.size:SetValue(sizeTable[1])
        end
    else
        widget = settingWidgets["size-square"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_Spacing(parent)
    local widget

    if not settingWidgets["spacing"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_Spacing", parent, 240, 50)
        settingWidgets["spacing"] = widget

        widget.x = Cell.CreateSlider(L["Spacing"].." X", widget, -1, 50, 110, 1)
        widget.x:SetPoint("TOPLEFT", widget, 5, -20)
        widget.x.afterValueChangedFn = function(value)
            widget.spacing[1] = value
            widget.func(widget.spacing)
        end

        widget.y = Cell.CreateSlider(L["Spacing"].." Y", widget, -1, 50, 110, 1)
        widget.y:SetPoint("LEFT", widget.x, "RIGHT", 25, 0)
        widget.y.afterValueChangedFn = function(value)
            widget.spacing[2] = value
            widget.func(widget.spacing)
        end

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(spacing)
            widget.spacing = spacing
            widget.x:SetValue(spacing[1])
            widget.y:SetValue(spacing[2])
        end
    else
        widget = settingWidgets["spacing"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_Thickness(parent)
    local widget

    if not settingWidgets["thickness"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_Thickness", parent, 240, 50)
        settingWidgets["thickness"] = widget

        widget.size = Cell.CreateSlider(L["Size"], widget, 1, 15, 110, 1)
        widget.size:SetPoint("TOPLEFT", widget, 5, -20)
        widget.size.afterValueChangedFn = function(value)
            widget.func(value)
        end

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(n)
            widget.size:SetValue(n)
        end
    else
        widget = settingWidgets["thickness"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_SizeNormalBig(parent)
    local widget

    if not settingWidgets["size-normal-big"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_SizeNormalBig", parent, 240, 50)
        settingWidgets["size-normal-big"] = widget

        widget.sizeNormal = Cell.CreateSlider(L["Size"], widget, 1, 200, 110, 1)
        widget.sizeNormal:SetPoint("TOPLEFT", widget, 5, -20)
        widget.sizeNormal.afterValueChangedFn = function(value)
            widget.func({{value, value}, {widget.sizeBig:GetValue(), widget.sizeBig:GetValue()}})
        end

        widget.sizeBig = Cell.CreateSlider(L["Size (Big)"], widget, 1, 200, 110, 1)
        widget.sizeBig:SetPoint("LEFT", widget.sizeNormal, "RIGHT", 25, 0)
        widget.sizeBig.afterValueChangedFn = function(value)
            widget.func({{widget.sizeNormal:GetValue(), widget.sizeNormal:GetValue()}, {value, value}})
        end

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(sizeTable)
            widget.sizeNormal:SetValue(sizeTable[1][1])
            widget.sizeBig:SetValue(sizeTable[2][1])
        end
    else
        widget = settingWidgets["size-normal-big"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_SizeAndBorder(parent)
    local widget

    if not settingWidgets["size-border"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_SizeAndBorder", parent, 240, 50)
        settingWidgets["size-border"] = widget

        widget.size = Cell.CreateSlider(L["Size"], widget, 1, 200, 110, 1)
        widget.size:SetPoint("TOPLEFT", widget, 5, -20)
        widget.size.afterValueChangedFn = function(value)
            widget.func({value, value, widget.border:GetValue()})
        end

        widget.border = Cell.CreateSlider(L["Border"], widget, 1, 10, 110, 1)
        widget.border:SetPoint("LEFT", widget.size, "RIGHT", 25, 0)
        widget.border.afterValueChangedFn = function(value)
            widget.func({widget.size:GetValue(), widget.size:GetValue(), value})
        end

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(sizeTable, border)
            widget.size:SetValue(sizeTable[1])
            widget.border:SetValue(border or 1) -- before r33 there's no border value
        end
    else
        widget = settingWidgets["size-border"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_Height(parent)
    local widget

    if not settingWidgets["height"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_Height", parent, 240, 50)
        settingWidgets["height"] = widget

        widget.height = Cell.CreateSlider(L["Height"], widget, 1, 300, 110, 1)
        widget.height:SetPoint("TOPLEFT", widget, 5, -20)
        widget.height.afterValueChangedFn = function(value)
            widget.func(value)
        end

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(height)
            widget.height:SetValue(height)
        end
    else
        widget = settingWidgets["height"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_TextWidth(parent)
    local widget

    if not settingWidgets["textWidth"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_TextWidth", parent, 240, 50)
        settingWidgets["textWidth"] = widget

        widget.textWidth = Cell.CreateDropdown(widget, 110)
        widget.textWidth:SetPoint("TOPLEFT", 5, -20)
        widget.textWidth:SetItems({
            {
                ["text"] = L["Unlimited"],
                ["onClick"] = function()
                    widget.func("unlimited")
                    widget.percent:Hide()
                    widget.length:Hide()
                    widget.length2:Hide()
                    widget.lengthValue = nil
                    widget.lengthValue2 = nil
                end,
            },
            {
                ["text"] = L["Percentage"],
                ["onClick"] = function()
                    widget.func({"percentage", 0.75})
                    widget.percent:SetSelectedValue(0.75)
                    widget.percent:Show()
                    widget.length:Hide()
                    widget.length2:Hide()
                    widget.lengthValue = nil
                    widget.lengthValue2 = nil
                end,
            },
            {
                ["text"] = L["Length"],
                ["onClick"] = function()
                    widget.func({"length", 5, 3})
                    widget.percent:Hide()
                    widget.length:SetText(5)
                    widget.length:Show()
                    widget.length2:SetText(3)
                    widget.length2:Show()
                    widget.lengthValue = 5
                    widget.lengthValue2 = 3
                end,
            },
        })

        widget.percent = Cell.CreateDropdown(widget, 75)
        widget.percent:SetPoint("TOPLEFT", widget.textWidth, "TOPRIGHT", 25, 0)
        Cell.SetTooltips(widget.percent.button, "ANCHOR_TOP", 0, 3, L["Name Width / UnitButton Width"])
        widget.percent:SetItems({
            {
                ["text"] = "100%",
                ["value"] = 1,
                ["onClick"] = function()
                    widget.func({"percentage", 1})
                end,
            },
            {
                ["text"] = "75%",
                ["value"] = 0.75,
                ["onClick"] = function()
                    widget.func({"percentage", 0.75})
                end,
            },
            {
                ["text"] = "50%",
                ["value"] = 0.5,
                ["onClick"] = function()
                    widget.func({"percentage", 0.5})
                end,
            },
            {
                ["text"] = "25%",
                ["value"] = 0.25,
                ["onClick"] = function()
                    widget.func({"percentage", 0.25})
                end,
            },
        })

        widget.length = Cell.CreateEditBox(widget, 34, 20, false, false, true)
        widget.length:SetPoint("TOPLEFT", widget.textWidth, "TOPRIGHT", 25, 0)

        widget.enText = widget.length:CreateFontString(nil, "OVERLAY", font_name)
        widget.enText:SetText(L["En"])
        widget.enText:SetPoint("BOTTOMLEFT", widget.length, "TOPLEFT", 0, 1)

        widget.length.confirmBtn = Cell.CreateButton(widget.length, "OK", "accent", {27, 20})
        widget.length.confirmBtn:SetPoint("TOPLEFT", widget.length, "TOPRIGHT", -1, 0)
        widget.length.confirmBtn:Hide()
        widget.length.confirmBtn:SetScript("OnHide", function()
            widget.length.confirmBtn:Hide()
        end)
        widget.length.confirmBtn:SetScript("OnClick", function()
            local length = tonumber(widget.length:GetText())
            widget.length:SetText(length)
            widget.length:ClearFocus()
            widget.length.confirmBtn:Hide()
            widget.lengthValue = length

            widget.func({"length", length, tonumber(widget.length2:GetText()) or widget.lengthValue2})
        end)

        widget.length:SetScript("OnTextChanged", function(self, userChanged)
            if userChanged then
                local length = tonumber(self:GetText())
                if length and length ~= widget.lengthValue and length ~= 0 then
                    widget.length.confirmBtn:Show()
                else
                    widget.length.confirmBtn:Hide()
                end
            end
        end)

        widget.length2 = Cell.CreateEditBox(widget, 33, 20, false, false, true)
        widget.length2:SetPoint("TOPLEFT", widget.length, "TOPRIGHT", 25, 0)

        widget.nonEnText = widget.length2:CreateFontString(nil, "OVERLAY", font_name)
        widget.nonEnText:SetText(L["Non-En"])
        widget.nonEnText:SetPoint("BOTTOMLEFT", widget.length2, "TOPLEFT", 0, 1)

        widget.length2.confirmBtn = Cell.CreateButton(widget.length2, "OK", "accent", {27, 20})
        widget.length2.confirmBtn:SetPoint("TOPLEFT", widget.length2, "TOPRIGHT", -1, 0)
        widget.length2.confirmBtn:Hide()
        widget.length2.confirmBtn:SetScript("OnHide", function()
            widget.length2.confirmBtn:Hide()
        end)
        widget.length2.confirmBtn:SetScript("OnClick", function()
            local length = tonumber(widget.length2:GetText())
            widget.length2:SetText(length)
            widget.length2:ClearFocus()
            widget.length2.confirmBtn:Hide()
            widget.lengthValue2 = length

            widget.func({"length", tonumber(widget.length:GetText()) or widget.lengthValue, length})
        end)

        widget.length2:SetScript("OnTextChanged", function(self, userChanged)
            if userChanged then
                local length = tonumber(self:GetText())
                if length and length ~= widget.lengthValue2 and length ~= 0 then
                    widget.length2.confirmBtn:Show()
                else
                    widget.length2.confirmBtn:Hide()
                end
            end
        end)

        widget.widthText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.widthText:SetText(L["Text Width"])
        widget.widthText:SetPoint("BOTTOMLEFT", widget.textWidth, "TOPLEFT", 0, 1)

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(width)
            if width == "unlimited" then
                widget.textWidth:SetSelectedItem(1)
                widget.percent:Hide()
                widget.length:Hide()
                widget.length2:Hide()
            elseif width[1] == "percentage" then
                widget.textWidth:SetSelectedItem(2)
                widget.percent:SetSelectedValue(width[2])
                widget.percent:Show()
                widget.length:Hide()
                widget.length2:Hide()
            elseif width[1] == "length" then
                widget.textWidth:SetSelectedItem(3)
                widget.length:SetText(width[2])
                widget.lengthValue = width[2]
                widget.length:Show()
                widget.length2:SetText(width[3])
                widget.lengthValue2 = width[3]
                widget.length2:Show()
                widget.percent:Hide()
            end
        end
    else
        widget = settingWidgets["textWidth"]
    end

    widget:Show()
    return widget
end



local function CreateSetting_Alpha(parent)
    local widget

    if not settingWidgets["alpha"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_Alpha", parent, 240, 50)
        settingWidgets["alpha"] = widget

        widget.alpha = Cell.CreateSlider(L["Alpha"], widget, 0, 1, 110, 0.01)
        widget.alpha:SetPoint("TOPLEFT", widget, 5, -20)
        widget.alpha.afterValueChangedFn = function(value)
            widget.func(value)
        end

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(alpha)
            widget.alpha:SetValue(alpha)
        end
    else
        widget = settingWidgets["alpha"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_Num(parent)
    local widget

    if not settingWidgets["num"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_Num", parent, 240, 50)
        settingWidgets["num"] = widget

        widget.num = Cell.CreateSlider(L["Max Displayed"], widget, 1, 5, 110, 1)
        widget.num:SetPoint("TOPLEFT", 5, -20)
        widget.num.afterValueChangedFn = function(value)
            widget.func(value)
        end

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(num, maxN)
            widget.num:UpdateMinMaxValues(1, maxN)
            widget.num:SetValue(num)
        end
    else
        widget = settingWidgets["num"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_NumPerLine(parent)
    local widget

    if not settingWidgets["numPerLine"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_NumPerLine", parent, 240, 50)
        settingWidgets["numPerLine"] = widget

        widget.num = Cell.CreateSlider(L["Displayed Per Line"], widget, 1, 5, 110, 1)
        widget.num:SetPoint("TOPLEFT", 5, -20)
        widget.num.afterValueChangedFn = function(value)
            widget.func(value)
        end

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(num, maxN)
            widget.num:UpdateMinMaxValues(2, maxN)
            widget.num:SetValue(num)
        end
    else
        widget = settingWidgets["numPerLine"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_HealthFormat(parent)
    local widget

    if not settingWidgets["healthFormat"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_HealthFormat", parent, 240, 380)
        settingWidgets["healthFormat"] = widget

        local health, healthMax = 213777, 300000
        local shield = 65535
        local healAbsorb = 88127

        local function UpdateWidgets()
            local health1Enabled = widget.format.health1.format ~= "none"
            widget.health1HideIfEmptyOrFullCB:SetEnabled(health1Enabled)
            widget.health1ColorDropdown:SetEnabled(health1Enabled)
            widget.health1ColorPicker:SetEnabled(health1Enabled)

            local health2Enabled = widget.format.health2.format ~= "none"
            widget.health2DelimiterEB:SetEnabled(health2Enabled)
            widget.health2DelimiterEB.confirmBtn:Hide()
            widget.health2HideIfEmptyOrFullCB:SetEnabled(health2Enabled)
            widget.health2ColorDropdown:SetEnabled(health2Enabled)
            widget.health2ColorPicker:SetEnabled(health2Enabled)
            if health2Enabled then
                widget.health2DelimiterText:SetTextColor(1, 1, 1)
            else
                widget.health2DelimiterText:SetTextColor(0.4, 0.4, 0.4)
            end

            local shieldEnabled = widget.format.shields.format ~= "none"
            widget.shieldDelimiterEB:SetEnabled(shieldEnabled)
            widget.shieldDelimiterEB.confirmBtn:Hide()
            widget.shieldColorDropdown:SetEnabled(shieldEnabled)
            widget.shieldColorPicker:SetEnabled(shieldEnabled)
            if shieldEnabled then
                widget.shieldDelimiterText:SetTextColor(1, 1, 1)
            else
                widget.shieldDelimiterText:SetTextColor(0.4, 0.4, 0.4)
            end

            local healAbsorbEnabled = widget.format.healAbsorbs.format ~= "none"
            widget.healAbsorbDelimiterEB:SetEnabled(healAbsorbEnabled)
            widget.healAbsorbDelimiterEB.confirmBtn:Hide()
            widget.healAbsorbColorDropdown:SetEnabled(healAbsorbEnabled)
            widget.healAbsorbColorPicker:SetEnabled(healAbsorbEnabled)
            if healAbsorbEnabled then
                widget.healAbsorbDelimiterText:SetTextColor(1, 1, 1)
            else
                widget.healAbsorbDelimiterText:SetTextColor(0.4, 0.4, 0.4)
            end
        end

        local function GetItems(which, list)
            local items = {}
            for _, v in pairs(list) do
                tinsert(items, {
                    ["text"] = v[1],
                    ["value"] = v[2],
                    ["onClick"] = function()
                        widget.format[which].format = v[2]
                        UpdateWidgets()
                        widget.func()
                    end,
                })
            end
            return items
        end

        local effective = " |cff7b7b7b" .. L["Effective"] .. "|r"
        local healthList = {
            {L["None"], "none"},
            {(health + shield - healAbsorb) .. effective, "effective"},
            {F.FormatNumber(health + shield - healAbsorb) .. effective, "effective_short"},
            {F.Round((health + shield - healAbsorb) / healthMax * 100) .. "%" .. effective, "effective_percent"},
            {F.Round((health + shield - healAbsorb) / healthMax * 100) .. effective, "effective_percent_no_sign"},
            {health, "health"},
            {F.FormatNumber(health), "health_short"},
            {F.Round(health / healthMax * 100) .. "%", "health_percent"},
            {F.Round(health / healthMax * 100), "health_percent_no_sign"},
            {health - healthMax, "deficit"},
            {F.FormatNumber(health - healthMax), "deficit_short"},
            {F.Round((health - healthMax) / healthMax * 100) .. "%", "deficit_percent"},
            {F.Round((health - healthMax) / healthMax * 100), "deficit_percent_no_sign"},
        }

        -- health1 ------------------------------
        widget.health1FormatDropdown = Cell.CreateDropdown(widget, 127)
        widget.health1FormatDropdown:SetPoint("TOPLEFT", 5, -20)
        widget.health1FormatDropdown:SetItems(GetItems("health1", healthList))

        local health1Text = widget:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
        health1Text:SetPoint("BOTTOMLEFT", widget.health1FormatDropdown, "TOPLEFT", 0, 1)
        health1Text:SetText(L["Health"] .. " 1")

        widget.health1HideIfEmptyOrFullCB = Cell.CreateCheckButton(widget, L["hideIfEmptyOrFull"], function(checked)
            widget.format.health1.hideIfEmptyOrFull = checked
            widget.func()
        end)
        widget.health1HideIfEmptyOrFullCB:SetPoint("TOPLEFT", widget.health1FormatDropdown, "BOTTOMLEFT", 0, -10)

        widget.health1ColorDropdown = Cell.CreateDropdown(widget, 127)
        widget.health1ColorDropdown:SetPoint("TOPLEFT", widget.health1HideIfEmptyOrFullCB, "BOTTOMLEFT", 0, -10)
        widget.health1ColorDropdown:SetItems({
            {
                ["text"] = L["Class Color"],
                ["value"] = "class_color",
                ["onClick"] = function()
                    widget.format.health1.color[1] = "class_color"
                    widget.func()
                    widget.health1ColorPicker:Hide()
                end,
            },
            {
                ["text"] = L["Custom Color"],
                ["value"] = "custom_color",
                ["onClick"] = function()
                    widget.format.health1.color[1] = "custom_color"
                    widget.func()
                    widget.health1ColorPicker:Show()
                end,
            },
        })

        widget.health1ColorPicker = Cell.CreateColorPicker(widget, "", false, function(r, g, b)
            widget.format.health1.color[2][1] = r
            widget.format.health1.color[2][2] = g
            widget.format.health1.color[2][3] = b
            widget.func()
        end)
        widget.health1ColorPicker:SetPoint("LEFT", widget.health1ColorDropdown, "RIGHT", 5, 0)

        -- health2 ------------------------------
        widget.health2FormatDropdown = Cell.CreateDropdown(widget, 127)
        widget.health2FormatDropdown:SetPoint("TOPLEFT", widget.health1ColorDropdown, "BOTTOMLEFT", 0, -35)
        widget.health2FormatDropdown:SetItems(GetItems("health2", healthList))

        local health2Text = widget:CreateFontString(nil, "OVERLAY", font_name)
        health2Text:SetPoint("BOTTOMLEFT", widget.health2FormatDropdown, "TOPLEFT", 0, 1)
        health2Text:SetText(L["Health"] .. " 2")

        widget.health2DelimiterEB = Cell.CreateEditBox(widget, 50, 20)
        widget.health2DelimiterEB:SetPoint("TOPLEFT", widget.health2FormatDropdown, "TOPRIGHT", 25, 0)
        widget.health2DelimiterEB:SetMaxLetters(5)
        widget.health2DelimiterEB:AddConfirmButton(function()
            widget.format.health2.delimiter = widget.health2DelimiterEB:GetText()
            widget.func()
        end)

        widget.health2DelimiterText = widget:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
        widget.health2DelimiterText:SetPoint("BOTTOMLEFT", widget.health2DelimiterEB, "TOPLEFT", 0, 1)
        widget.health2DelimiterText:SetText(L["Delimiter"])

        widget.health2HideIfEmptyOrFullCB = Cell.CreateCheckButton(widget, L["hideIfEmptyOrFull"], function(checked)
            widget.format.health2.hideIfEmptyOrFull = checked
            widget.func()
        end)
        widget.health2HideIfEmptyOrFullCB:SetPoint("TOPLEFT", widget.health2FormatDropdown, "BOTTOMLEFT", 0, -10)

        widget.health2ColorDropdown = Cell.CreateDropdown(widget, 127)
        widget.health2ColorDropdown:SetPoint("TOPLEFT", widget.health2HideIfEmptyOrFullCB, "BOTTOMLEFT", 0, -10)
        widget.health2ColorDropdown:SetItems({
            {
            ["text"] = L["Class Color"],
            ["value"] = "class_color",
            ["onClick"] = function()
                widget.format.health2.color[1] = "class_color"
                widget.func()
                widget.health2ColorPicker:Hide()
            end,
            },
            {
            ["text"] = L["Custom Color"],
            ["value"] = "custom_color",
            ["onClick"] = function()
                widget.format.health2.color[1] = "custom_color"
                widget.func()
                widget.health2ColorPicker:Show()
            end,
            },
        })

        widget.health2ColorPicker = Cell.CreateColorPicker(widget, "", false, function(r, g, b)
            widget.format.health2.color[2][1] = r
            widget.format.health2.color[2][2] = g
            widget.format.health2.color[2][3] = b
            widget.func()
        end)
        widget.health2ColorPicker:SetPoint("LEFT", widget.health2ColorDropdown, "RIGHT", 5, 0)

        -- shield -------------------------------
        local shieldList = {
            {L["None"], "none"},
            {shield, "shields"},
            {F.FormatNumber(shield), "shields_short"},
            {F.Round(shield / healthMax * 100) .. "%", "shields_percent"},
            {F.Round(shield / healthMax * 100), "shields_percent_no_sign"},
        }

        widget.shieldFormatDropdown = Cell.CreateDropdown(widget, 127)
        widget.shieldFormatDropdown:SetPoint("TOPLEFT", widget.health2ColorDropdown, "BOTTOMLEFT", 0, -35)
        widget.shieldFormatDropdown:SetItems(GetItems("shields", shieldList))

        local shieldText = widget:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
        shieldText:SetPoint("BOTTOMLEFT", widget.shieldFormatDropdown, "TOPLEFT", 0, 1)
        shieldText:SetText(L["Shields"])

        -- delimiter
        widget.shieldDelimiterEB = Cell.CreateEditBox(widget, 50, 20)
        widget.shieldDelimiterEB:SetPoint("TOPLEFT", widget.shieldFormatDropdown, "TOPRIGHT", 25, 0)
        widget.shieldDelimiterEB:SetMaxLetters(5)
        widget.shieldDelimiterEB:AddConfirmButton(function()
            widget.format.shields.delimiter = widget.shieldDelimiterEB:GetText()
            widget.func()
        end)

        widget.shieldDelimiterText = widget:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
        widget.shieldDelimiterText:SetPoint("BOTTOMLEFT", widget.shieldDelimiterEB, "TOPLEFT", 0, 1)
        widget.shieldDelimiterText:SetText(L["Delimiter"])

        -- color
        widget.shieldColorDropdown = Cell.CreateDropdown(widget, 127)
        widget.shieldColorDropdown:SetPoint("TOPLEFT", widget.shieldFormatDropdown, "BOTTOMLEFT", 0, -10)
        widget.shieldColorDropdown:SetItems({
            {
                ["text"] = L["Class Color"],
                ["value"] = "class_color",
                ["onClick"] = function()
                    widget.format.shields.color[1] = "class_color"
                    widget.func()
                    widget.shieldColorPicker:Hide()
                end,
            },
            {
                ["text"] = L["Custom Color"],
                ["value"] = "custom_color",
                ["onClick"] = function()
                    widget.format.shields.color[1] = "custom_color"
                    widget.func()
                    widget.shieldColorPicker:Show()
                end,
            },
        })

        widget.shieldColorPicker = Cell.CreateColorPicker(widget, "", false, function(r, g, b)
            widget.format.shields.color[2][1] = r
            widget.format.shields.color[2][2] = g
            widget.format.shields.color[2][3] = b
            widget.func()
        end)
        widget.shieldColorPicker:SetPoint("LEFT", widget.shieldColorDropdown, "RIGHT", 5, 0)

        -- heal absorb --------------------------
        local healAbsorbList = {
            {L["None"], "none"},
            {healAbsorb, "healabsorbs"},
            {F.FormatNumber(healAbsorb), "healabsorbs_short"},
            {F.Round(healAbsorb / healthMax * 100) .. "%", "healabsorbs_percent"},
            {F.Round(healAbsorb / healthMax * 100), "healabsorbs_percent_no_sign"},
        }

        widget.healAbsorbFormatDropdown = Cell.CreateDropdown(widget, 127)
        widget.healAbsorbFormatDropdown:SetPoint("TOPLEFT", widget.shieldColorDropdown, "BOTTOMLEFT", 0, -35)
        widget.healAbsorbFormatDropdown:SetItems(GetItems("healAbsorbs", healAbsorbList))

        local healAbsorbText = widget:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
        healAbsorbText:SetPoint("BOTTOMLEFT", widget.healAbsorbFormatDropdown, "TOPLEFT", 0, 1)
        healAbsorbText:SetText(L["Heal Absorbs"])

        -- delimiter
        widget.healAbsorbDelimiterEB = Cell.CreateEditBox(widget, 50, 20)
        widget.healAbsorbDelimiterEB:SetPoint("TOPLEFT", widget.healAbsorbFormatDropdown, "TOPRIGHT", 25, 0)
        widget.healAbsorbDelimiterEB:SetMaxLetters(5)
        widget.healAbsorbDelimiterEB:AddConfirmButton(function()
            widget.format.healAbsorbs.delimiter = widget.healAbsorbDelimiterEB:GetText()
            widget.func()
        end)

        widget.healAbsorbDelimiterText = widget:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
        widget.healAbsorbDelimiterText:SetPoint("BOTTOMLEFT", widget.healAbsorbDelimiterEB, "TOPLEFT", 0, 1)
        widget.healAbsorbDelimiterText:SetText(L["Delimiter"])

        -- color
        widget.healAbsorbColorDropdown = Cell.CreateDropdown(widget, 127)
        widget.healAbsorbColorDropdown:SetPoint("TOPLEFT", widget.healAbsorbFormatDropdown, "BOTTOMLEFT", 0, -10)
        widget.healAbsorbColorDropdown:SetItems({
            {
                ["text"] = L["Class Color"],
                ["value"] = "class_color",
                ["onClick"] = function()
                    widget.format.healAbsorbs.color[1] = "class_color"
                    widget.func()
                    widget.healAbsorbColorPicker:Hide()
                end,
            },
            {
                ["text"] = L["Custom Color"],
                ["value"] = "custom_color",
                ["onClick"] = function()
                    widget.format.healAbsorbs.color[1] = "custom_color"
                    widget.func()
                    widget.healAbsorbColorPicker:Show()
                end,
            }
        })

        widget.healAbsorbColorPicker = Cell.CreateColorPicker(widget, "", false, function(r, g, b)
            widget.format.healAbsorbs.color[2][1] = r
            widget.format.healAbsorbs.color[2][2] = g
            widget.format.healAbsorbs.color[2][3] = b
            widget.func()
        end)
        widget.healAbsorbColorPicker:SetPoint("LEFT", widget.healAbsorbColorDropdown, "RIGHT", 5, 0)

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(format)
            widget.format = format
            UpdateWidgets()

            -- health1
            widget.health1FormatDropdown:SetSelectedValue(format.health1.format)
            widget.health1HideIfEmptyOrFullCB:SetChecked(format.health1.hideIfEmptyOrFull)
            widget.health1ColorDropdown:SetSelectedValue(format.health1.color[1])
            widget.health1ColorPicker:SetColor(unpack(format.health1.color[2]))

            -- health2
            widget.health2FormatDropdown:SetSelectedValue(format.health2.format)
            widget.health2DelimiterEB:SetText(format.health2.delimiter)
            widget.health2HideIfEmptyOrFullCB:SetChecked(format.health2.hideIfEmptyOrFull)
            widget.health2ColorDropdown:SetSelectedValue(format.health2.color[1])
            widget.health2ColorPicker:SetColor(unpack(format.health2.color[2]))

            -- shields
            widget.shieldFormatDropdown:SetSelectedValue(format.shields.format)
            widget.shieldDelimiterEB:SetText(format.shields.delimiter)
            widget.shieldColorDropdown:SetSelectedValue(format.shields.color[1])
            widget.shieldColorPicker:SetColor(unpack(format.shields.color[2]))

            -- heal absorbs
            widget.healAbsorbFormatDropdown:SetSelectedValue(format.healAbsorbs.format)
            widget.healAbsorbDelimiterEB:SetText(format.healAbsorbs.delimiter)
            widget.healAbsorbColorDropdown:SetSelectedValue(format.healAbsorbs.color[1])
            widget.healAbsorbColorPicker:SetColor(unpack(format.healAbsorbs.color[2]))
        end
    else
        widget = settingWidgets["healthFormat"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_PowerFormat(parent)
    local widget

    if not settingWidgets["powerFormat"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_PowerFormat", parent, 240, 50)
        settingWidgets["powerFormat"] = widget

        widget.format = Cell.CreateDropdown(widget, 127)
        widget.format:SetPoint("TOPLEFT", 5, -20)
        widget.format:SetItems({
            {
                ["text"] = "50%",
                ["value"] = "percentage",
                ["onClick"] = function()
                    widget.func("percentage")
                end,
            },
            {
                ["text"] = "25000",
                ["value"] = "number",
                ["onClick"] = function()
                    widget.func("number")
                end,
            },
            {
                ["text"] = F.FormatNumber(25000),
                ["value"] = "number-short",
                ["onClick"] = function()
                    widget.func("number-short")
                end,
            },
        })

        widget.formatText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.formatText:SetText(L["Format"])
        widget.formatText:SetPoint("BOTTOMLEFT", widget.format, "TOPLEFT", 0, 1)

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(format)
            widget.format:SetSelectedValue(format)
        end
    else
        widget = settingWidgets["powerFormat"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_DurationVisibility(parent)
    local widget

    if not settingWidgets["durationVisibility"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_DurationVisibility", parent, 240, 50)
        settingWidgets["durationVisibility"] = widget

        widget.durationVisibility = Cell.CreateDropdown(widget, 245)
        widget.durationVisibility:SetPoint("TOPLEFT", 5, -20)
        widget.durationVisibility:SetItems({
            {
                ["text"] = L["Never"],
                ["value"] = false,
                ["onClick"] = function()
                    widget.func(false)
                end,
            },
            {
                ["text"] = L["Always"],
                ["value"] = true,
                ["onClick"] = function()
                    widget.func(true)
                end,
            },
            {
                ["text"] = "< 75%",
                ["value"] = 0.75,
                ["onClick"] = function()
                    widget.func(0.75)
                end,
            },
            {
                ["text"] = "< 50%",
                ["value"] = 0.5,
                ["onClick"] = function()
                    widget.func(0.5)
                end,
            },
            {
                ["text"] = "< 30%",
                ["value"] = 0.3,
                ["onClick"] = function()
                    widget.func(0.3)
                end,
            },
            {
                ["text"] = "< 25%",
                ["value"] = 0.25,
                ["onClick"] = function()
                    widget.func(0.25)
                end,
            },
            {
                ["text"] = "< 15 "..L["sec"],
                ["value"] = 15,
                ["onClick"] = function()
                    widget.func(15)
                end,
            },
            {
                ["text"] = "< 10 "..L["sec"],
                ["value"] = 10,
                ["onClick"] = function()
                    widget.func(10)
                end,
            },
            {
                ["text"] = "< 5 "..L["sec"],
                ["value"] = 5,
                ["onClick"] = function()
                    widget.func(5)
                end,
            },
        })

        widget.durationVisibilityText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.durationVisibilityText:SetText(L["showDuration"])
        widget.durationVisibilityText:SetPoint("BOTTOMLEFT", widget.durationVisibility, "TOPLEFT", 0, 1)

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(durationVisibility)
            widget.durationVisibility:SetSelectedValue(durationVisibility)
        end
    else
        widget = settingWidgets["durationVisibility"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_Orientation(parent)
    local widget

    if not settingWidgets["orientation"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_Orientation", parent, 240, 50)
        settingWidgets["orientation"] = widget

        widget.orientation = Cell.CreateDropdown(widget, 245)
        widget.orientation:SetPoint("TOPLEFT", 5, -20)
        widget.orientation:SetItems({
            {
                ["text"] = L["left-to-right"],
                ["onClick"] = function()
                    widget.func("left-to-right")
                end,
            },
            {
                ["text"] = L["right-to-left"],
                ["onClick"] = function()
                    widget.func("right-to-left")
                end,
            },
            {
                ["text"] = L["top-to-bottom"],
                ["onClick"] = function()
                    widget.func("top-to-bottom")
                end,
            },
            {
                ["text"] = L["bottom-to-top"],
                ["onClick"] = function()
                    widget.func("bottom-to-top")
                end,
            },
        })

        widget.orientationText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.orientationText:SetText(L["Orientation"])
        widget.orientationText:SetPoint("BOTTOMLEFT", widget.orientation, "TOPLEFT", 0, 1)

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(orientation)
            widget.orientation:SetSelected(L[orientation])
        end
    else
        widget = settingWidgets["orientation"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_BarOrientation(parent)
    local widget

    if not settingWidgets["barOrientation"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_BarOrientation", parent, 240, 50)
        settingWidgets["barOrientation"] = widget

        widget.orientation = Cell.CreateDropdown(widget, 153)
        widget.orientation:SetPoint("TOPLEFT", 5, -20)
        widget.orientation:SetItems({
            {
                ["text"] = L["Horizontal"],
                ["value"] = "horizontal",
                ["onClick"] = function()
                    widget.func("horizontal")
                end,
            },
            {
                ["text"] = L["Vertical"],
                ["value"] = "vertical",
                ["onClick"] = function()
                    widget.func("vertical")
                end,
            },
        })

        widget.orientationText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.orientationText:SetText(L["Orientation"])
        widget.orientationText:SetPoint("BOTTOMLEFT", widget.orientation, "TOPLEFT", 0, 1)

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(orientation)
            widget.orientation:SetSelectedValue(orientation)
        end
    else
        widget = settingWidgets["barOrientation"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_VehicleNamePosition(parent)
    local widget

    if not settingWidgets["vehicleNamePosition"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_VehicleNamePosition", parent, 240, 50)
        settingWidgets["vehicleNamePosition"] = widget

        widget.position = Cell.CreateDropdown(widget, 110)
        widget.position:SetPoint("TOPLEFT", 5, -20)
        widget.position:SetItems({
            {
                ["text"] = L["TOP"],
                ["value"] = "TOP",
                ["onClick"] = function()
                    widget.func({"TOP", widget.yOffset:GetValue()})
                end,
            },
            {
                ["text"] = L["BOTTOM"],
                ["value"] = "BOTTOM",
                ["onClick"] = function()
                    widget.func({"BOTTOM", widget.yOffset:GetValue()})
                end,
            },
            {
                ["text"] = L["Hide"],
                ["value"] = "Hide",
                ["onClick"] = function()
                    widget.func({"Hide", widget.yOffset:GetValue()})
                end,
            },
        })

        widget.positionText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.positionText:SetText(L["Vehicle Name Position"])
        widget.positionText:SetPoint("BOTTOMLEFT", widget.position, "TOPLEFT", 0, 1)

        widget.yOffset = Cell.CreateSlider(L["Y Offset"], widget, -50, 50, 110, 1)
        widget.yOffset:SetPoint("TOPLEFT", widget.position, "TOPRIGHT", 25, 0)
        widget.yOffset.afterValueChangedFn = function(value)
            widget.func({widget.position:GetSelected(), value})
        end

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(pTable)
            widget.position:SetSelected(L[pTable[1]])
            widget.yOffset:SetValue(pTable[2])
        end
    else
        widget = settingWidgets["vehicleNamePosition"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_StatusPosition(parent)
    local widget

    if not settingWidgets["statusPosition"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_StatusPosition", parent, 240, 95)
        settingWidgets["statusPosition"] = widget

        widget.position = Cell.CreateDropdown(widget, 110)
        widget.position:SetPoint("TOPLEFT", 5, -20)
        widget.position:SetItems({
            {
                ["text"] = L["TOP"],
                ["value"] = "TOP",
                ["onClick"] = function()
                    widget.func({"TOP", widget.yOffset:GetValue(), widget.justify:GetSelected()})
                end,
            },
            {
                ["text"] = L["BOTTOM"],
                ["value"] = "BOTTOM",
                ["onClick"] = function()
                    widget.func({"BOTTOM", widget.yOffset:GetValue(), widget.justify:GetSelected()})
                end,
            },
        })

        widget.positionText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.positionText:SetText(L["Status Text Position"])
        widget.positionText:SetPoint("BOTTOMLEFT", widget.position, "TOPLEFT", 0, 1)

        widget.justify = Cell.CreateDropdown(widget, 110)
        widget.justify:SetPoint("TOPLEFT", widget.position, "TOPRIGHT", 25, 0)
        widget.justify:SetItems({
            {
                ["text"] = "<<< >>>",
                ["value"] = "justify",
                ["onClick"] = function()
                    widget.func({widget.position:GetSelected(), widget.yOffset:GetValue(), "justify"})
                end,
            },
            {
                ["text"] = "<<<",
                ["value"] = "left",
                ["onClick"] = function()
                    widget.func({widget.position:GetSelected(), widget.yOffset:GetValue(), "left"})
                end,
            },
            {
                ["text"] = ">>>",
                ["value"] = "right",
                ["onClick"] = function()
                    widget.func({widget.position:GetSelected(), widget.yOffset:GetValue(), "right"})
                end,
            },
        })

        widget.yOffset = Cell.CreateSlider(L["Y Offset"], widget, -150, 150, 110, 1)
        widget.yOffset:SetPoint("TOPLEFT", widget.position, "BOTTOMLEFT", 0, -25)
        widget.yOffset.afterValueChangedFn = function(value)
            widget.func({widget.position:GetSelected(), value, widget.justify:GetSelected()})
        end

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(pTable)
            widget.position:SetSelectedValue(pTable[1])
            widget.yOffset:SetValue(pTable[2])
            widget.justify:SetSelectedValue(pTable[3])
        end
    else
        widget = settingWidgets["statusPosition"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_FontNoOffset(parent)
    local widget

    if not settingWidgets["font-noOffset"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_FontNoOffset", parent, 240, 95)
        settingWidgets["font-noOffset"] = widget

        widget.Update = function()
            widget.fontTable[1] = widget.font:GetSelected() or "Cell ".._G.DEFAULT
            widget.fontTable[2] = widget.fontSize:GetValue()
            widget.fontTable[3] =  widget.outline:GetSelected()
            widget.fontTable[4] =  widget.shadow:GetChecked()
            widget.func()
        end

        widget.font = Cell.CreateDropdown(widget, 110, "font")
        widget.font:SetPoint("TOPLEFT", 5, -20)
        local items, fonts, defaultFontName, defaultFont = F.GetFontItems()
        for _, item in pairs(items) do
            item["onClick"] = widget.Update
        end
        widget.font:SetItems(items)

        widget.fontText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.fontText:SetText(L["Font"])
        widget.fontText:SetPoint("BOTTOMLEFT", widget.font, "TOPLEFT", 0, 1)

        widget.outline = Cell.CreateDropdown(widget, 110)
        widget.outline:SetPoint("LEFT", widget.font, "RIGHT", 25, 0)
        widget.outline:SetItems({
            {
                ["text"] = L["None"],
                ["value"] = "None",
                ["onClick"] = widget.Update,
            },
            {
                ["text"] = L["Outline"],
                ["value"] = "Outline",
                ["onClick"] = widget.Update,
            },
            {
                ["text"] = L["Monochrome"],
                ["value"] = "Monochrome",
                ["onClick"] = widget.Update,
            },
        })

        widget.outlineText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.outlineText:SetText(L["Outline"])
        widget.outlineText:SetPoint("BOTTOMLEFT", widget.outline, "TOPLEFT", 0, 1)

        widget.fontSize = Cell.CreateSlider(L["Size"], widget, 5, 50, 110, 1)
        widget.fontSize:SetPoint("TOPLEFT", widget.font, "BOTTOMLEFT", 0, -25)
        widget.fontSize.afterValueChangedFn = widget.Update

        widget.shadow = Cell.CreateCheckButton(widget, L["Shadow"], widget.Update)
        widget.shadow:SetPoint("TOPLEFT", widget.fontSize, "TOPRIGHT", 25, -3)

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(fontTable)
            widget.fontTable = fontTable
            widget.font:SetSelected(fontTable[1], fonts[fontTable[1]])
            widget.fontSize:SetValue(fontTable[2])
            widget.outline:SetSelected(L[fontTable[3]])
            widget.shadow:SetChecked(fontTable[4])
        end
    else
        widget = settingWidgets["font-noOffset"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_Font(parent, index)
    local widget

    if not settingWidgets[index] then
        widget = Cell.CreateFrame("CellIndicatorSettings_"..F.UpperFirst(index), parent, 240, 145)
        settingWidgets[index] = widget

        widget.Update = function()
            widget.fontTable[1] = widget.font:GetSelected() or "Cell ".._G.DEFAULT
            widget.fontTable[2] = widget.fontSize:GetValue()
            widget.fontTable[3] =  widget.outline:GetSelected()
            widget.fontTable[4] = widget.shadow:GetChecked()
            widget.fontTable[5] = widget.anchor:GetSelected()
            widget.fontTable[6] = widget.xOffset:GetValue()
            widget.fontTable[7] = widget.yOffset:GetValue()
            widget.func()
        end

        -- title
        widget.title = widget:CreateFontString(nil, "OVERLAY", font_class_name)
        widget.title:SetPoint("TOPLEFT", 5, -5)

        -- font
        widget.font = Cell.CreateDropdown(widget, 110, "font")
        -- widget.font:SetPoint("TOPLEFT", 5, -40)
        local items, fonts, defaultFontName, defaultFont = F.GetFontItems()
        for _, item in pairs(items) do
            item["onClick"] = widget.Update
        end
        widget.font:SetItems(items)

        widget.fontText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.fontText:SetText(L["Font"])
        widget.fontText:SetPoint("BOTTOMLEFT", widget.font, "TOPLEFT", 0, 1)

        -- outline
        widget.outline = Cell.CreateDropdown(widget, 110)
        widget.outline:SetPoint("TOPLEFT", widget.font, "TOPRIGHT", 25, 0)
        widget.outline:SetItems({
            {
                ["text"] = L["None"],
                ["value"] = "None",
                ["onClick"] = widget.Update
            },
            {
                ["text"] = L["Outline"],
                ["value"] = "Outline",
                ["onClick"] = widget.Update
            },
            {
                ["text"] = L["Monochrome"],
                ["value"] = "Monochrome",
                ["onClick"] = widget.Update
            },
        })

        widget.outlineText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.outlineText:SetText(L["Outline"])
        widget.outlineText:SetPoint("BOTTOMLEFT", widget.outline, "TOPLEFT", 0, 1)

        -- size
        widget.fontSize = Cell.CreateSlider(L["Size"], widget, 5, 50, 110, 1)
        widget.fontSize:SetPoint("TOPLEFT", widget.font, "BOTTOMLEFT", 0, -25)
        widget.fontSize.afterValueChangedFn = widget.Update

        -- shadow
        widget.shadow = Cell.CreateCheckButton(widget, L["Shadow"], widget.Update)
        widget.shadow:SetPoint("TOPLEFT", widget.fontSize, "TOPRIGHT", 25, -3)

        -- anchor
        widget.anchor = Cell.CreateDropdown(widget, 110)
        widget.anchor:SetPoint("TOPLEFT", widget.fontSize, "BOTTOMLEFT", 0, -45)
        local items = {}
        for _, point in pairs(anchorPoints) do
            tinsert(items, {
                ["text"] = L[point],
                ["value"] = point,
                ["onClick"] = widget.Update,
            })
        end
        widget.anchor:SetItems(items)

        widget.anchorText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.anchorText:SetText(L["Anchor Point"])
        widget.anchorText:SetPoint("BOTTOMLEFT", widget.anchor, "TOPLEFT", 0, 1)

        -- x
        widget.xOffset = Cell.CreateSlider(L["X Offset"], widget, -50, 50, 110, 1)
        widget.xOffset:SetPoint("TOPLEFT", widget.anchor, "TOPRIGHT", 25, 0)
        widget.xOffset.afterValueChangedFn = widget.Update

        -- y
        widget.yOffset = Cell.CreateSlider(L["Y Offset"], widget, -50, 50, 110, 1)
        widget.yOffset:SetPoint("TOPLEFT", widget.xOffset, "BOTTOMLEFT", 0, -40)
        widget.yOffset.afterValueChangedFn = widget.Update

        -- color
        widget.color = Cell.CreateColorPicker(widget, L["Color"], false, function(r, g, b)
            widget.fontTable[8][1] = r
            widget.fontTable[8][2] = g
            widget.fontTable[8][3] = b
            widget.func()
        end)
        widget.color:SetPoint("TOPLEFT", widget.anchor, "BOTTOMLEFT", 0, -30)

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(fontTable, title)
            widget.fontTable = fontTable
            widget.font:SetSelected(fontTable[1], fonts[fontTable[1]])
            widget.fontSize:SetValue(fontTable[2])
            widget.outline:SetSelectedValue(fontTable[3])
            widget.shadow:SetChecked(fontTable[4])
            widget.anchor:SetSelectedValue(fontTable[5])
            widget.xOffset:SetValue(fontTable[6])
            widget.yOffset:SetValue(fontTable[7])

            local height = 200

            -- title
            if title then
                widget.title:SetText(L[title])
                widget.font:SetPoint("TOPLEFT", 5, -40)
                height = height + 20
            else
                widget.font:SetPoint("TOPLEFT", 5, -20)
            end

            -- color
            if fontTable[8] then
                widget.color:Show()
                widget.color:SetColor(fontTable[8])
            else
                widget.color:Hide()
            end

            P.Height(widget, height)

            if title == "durationFont" then
                Cell.SetTooltips(widget.color, "ANCHOR_TOPLEFT", 0, 3, L["Color"], L["This setting will be ignored, if the %1$s option in %2$s tab is enabled"]:format(Cell.GetAccentColorString().."\""..L["Color Duration Text"].."\"|r", L["Appearance"]))
            else
                Cell.ClearTooltips(widget.color)
            end
        end
    else
        widget = settingWidgets[index]
    end

    widget:Show()
    return widget
end

local function CreateSetting_Color(parent)
    local widget

    if not settingWidgets["color"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_Color", parent, 240, 30)
        settingWidgets["color"] = widget

        local colorPicker = Cell.CreateColorPicker(widget, L["Color"], false, function(r, g, b, a)
            widget.colorTable[1] = r
            widget.colorTable[2] = g
            widget.colorTable[3] = b
            widget.func(widget.colorTable)
        end)
        colorPicker:SetPoint("TOPLEFT", 5, -8)

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(colorTable)
            widget.colorTable = colorTable
            colorPicker:SetColor(colorTable)
        end
    else
        widget = settingWidgets["color"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_ColorAlpha(parent)
    local widget

    if not settingWidgets["color-alpha"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_ColorAlpha", parent, 240, 30)
        settingWidgets["color-alpha"] = widget

        local colorPicker = Cell.CreateColorPicker(widget, L["Color"], true, function(r, g, b, a)
            widget.colorTable[1] = r
            widget.colorTable[2] = g
            widget.colorTable[3] = b
            widget.colorTable[4] = a
            widget.func(widget.colorTable)
        end)
        colorPicker:SetPoint("TOPLEFT", 5, -8)

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(colorTable)
            widget.colorTable = colorTable
            colorPicker:SetColor(colorTable)
        end
    else
        widget = settingWidgets["color-alpha"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_Colors(parent)
    local widget

    if not settingWidgets["colors"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_Colors", parent, 240, 96)
        settingWidgets["colors"] = widget

        local normalColor = Cell.CreateColorPicker(widget, L["Normal"], true, function(r, g, b, a)
            widget.colorsTable[1][1] = r
            widget.colorsTable[1][2] = g
            widget.colorsTable[1][3] = b
            widget.colorsTable[1][4] = a
            widget.func(widget.colorsTable)
        end)
        normalColor:SetPoint("TOPLEFT", 5, -8)

        local percentColor, percentDropdown

        local percentCB = Cell.CreateCheckButton(widget, "", function(checked)
            widget.colorsTable[2][1] = checked
            Cell.SetEnabled(checked, percentColor, percentDropdown)
        end)
        percentCB:SetPoint("TOPLEFT", normalColor, "BOTTOMLEFT", 0, -8)

        percentColor = Cell.CreateColorPicker(widget, L["Remaining Time"].." <", true, function(r, g, b, a)
            widget.colorsTable[2][3][1] = r
            widget.colorsTable[2][3][2] = g
            widget.colorsTable[2][3][3] = b
            widget.colorsTable[2][3][4] = a
            widget.func(widget.colorsTable)
        end)
        percentColor:SetPoint("TOPLEFT", percentCB, "TOPRIGHT", 2, 0)

        local secColor, secEditBox, secText

        local secCB = Cell.CreateCheckButton(widget, "", function(checked)
            widget.colorsTable[3][1] = checked
            Cell.SetEnabled(checked, secColor, secEditBox, secText)
        end)
        secCB:SetPoint("TOPLEFT", percentCB, "BOTTOMLEFT", 0, -8)

        secColor = Cell.CreateColorPicker(widget, L["Remaining Time"].." <", true, function(r, g, b, a)
            widget.colorsTable[3][3][1] = r
            widget.colorsTable[3][3][2] = g
            widget.colorsTable[3][3][3] = b
            widget.colorsTable[3][3][4] = a
            widget.func(widget.colorsTable)
        end)
        secColor:SetPoint("TOPLEFT", secCB, "TOPRIGHT", 2, 0)

        local borderColor = Cell.CreateColorPicker(widget, L["Border Color"], true, function(r, g, b, a)
            widget.colorsTable[4][1] = r
            widget.colorsTable[4][2] = g
            widget.colorsTable[4][3] = b
            widget.colorsTable[4][4] = a
            widget.func(widget.colorsTable)
        end)
        borderColor:SetPoint("TOPLEFT", secCB, "BOTTOMLEFT", 0, -8)

        local bgColor = Cell.CreateColorPicker(widget, L["Background Color"], true, function(r, g, b, a)
            widget.colorsTable[5][1] = r
            widget.colorsTable[5][2] = g
            widget.colorsTable[5][3] = b
            widget.colorsTable[5][4] = a
            widget.func(widget.colorsTable)
        end)
        bgColor:SetPoint("TOPLEFT", borderColor, "BOTTOMLEFT", 0, -8)


        percentDropdown = Cell.CreateDropdown(widget, 60)
        percentDropdown:SetPoint("LEFT", percentColor.label, "RIGHT", 5, 0)
        percentDropdown:SetItems({
            {
                ["text"] = "75%",
                ["value"] = 0.75,
                ["onClick"] = function()
                    widget.colorsTable[2][2] = 0.75
                    widget.func(widget.colorsTable)
                end,
            },
            {
                ["text"] = "50%",
                ["value"] = 0.5,
                ["onClick"] = function()
                    widget.colorsTable[2][2] = 0.5
                    widget.func(widget.colorsTable)
                end,
            },
            {
                ["text"] = "30%",
                ["value"] = 0.3,
                ["onClick"] = function()
                    widget.colorsTable[2][2] = 0.3
                    widget.func(widget.colorsTable)
                end,
            },
            {
                ["text"] = "25%",
                ["value"] = 0.25,
                ["onClick"] = function()
                    widget.colorsTable[2][2] = 0.25
                    widget.func(widget.colorsTable)
                end,
            },
        })

        secEditBox = Cell.CreateEditBox(widget, 43, 20, false, false, true)
        secEditBox:SetPoint("LEFT", secColor.label, "RIGHT", 5, 0)
        secEditBox:SetMaxLetters(4)

        secEditBox.confirmBtn = Cell.CreateButton(widget, "OK", "accent", {27, 20})
        secEditBox.confirmBtn:SetPoint("LEFT", secEditBox, "RIGHT", -1, 0)
        secEditBox.confirmBtn:Hide()
        secEditBox.confirmBtn:SetScript("OnHide", function()
            secEditBox.confirmBtn:Hide()
        end)
        secEditBox.confirmBtn:SetScript("OnClick", function()
            local newSec = tonumber(secEditBox:GetText())
            widget.colorsTable[3][2] = newSec
            secEditBox:SetText(newSec)
            secEditBox:ClearFocus()
            secEditBox.confirmBtn:Hide()
            widget.func(widget.colorsTable)
        end)

        secEditBox:SetScript("OnTextChanged", function(self, userChanged)
            if userChanged then
                local newSec = tonumber(self:GetText())
                if newSec and newSec ~= widget.colorsTable[3][2] then
                    secEditBox.confirmBtn:Show()
                else
                    secEditBox.confirmBtn:Hide()
                end
            end
        end)

        secText = widget:CreateFontString(nil, "OVERLAY", font_name)
        secText:SetPoint("LEFT", secEditBox, "RIGHT", 5, 0)
        secText:SetText(L["sec"])

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(colorsTable)
            widget.colorsTable = colorsTable

            percentCB:SetChecked(colorsTable[2][1])
            Cell.SetEnabled(colorsTable[2][1], percentColor, percentDropdown)
            secCB:SetChecked(colorsTable[3][1])
            Cell.SetEnabled(colorsTable[3][1], secColor, secEditBox, secText)

            normalColor:SetColor(colorsTable[1])
            percentColor:SetColor(colorsTable[2][3])
            secColor:SetColor(colorsTable[3][3])

            if colorsTable[4] and colorsTable[5] then
                P.Height(widget, 118)
                borderColor:SetColor(colorsTable[4])
                borderColor:Show()
                bgColor:SetColor(colorsTable[5])
                bgColor:Show()
            elseif colorsTable[4] then
                P.Height(widget, 96)
                borderColor:SetColor(colorsTable[4])
                borderColor:Show()
                bgColor:Hide()
            else
                P.Height(widget, 75)
                borderColor:Hide()
                bgColor:Hide()
            end

            percentDropdown:SetSelectedValue(colorsTable[2][2])
            secEditBox:SetText(colorsTable[3][2])
        end
    else
        widget = settingWidgets["colors"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_BlockColors(parent)
    local widget

    if not settingWidgets["blockColors"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_BlockColors", parent, 240, 136)
        settingWidgets["blockColors"] = widget

        -- colorBy
        local colorBy = Cell.CreateDropdown(widget, 260)
        colorBy:SetPoint("TOPLEFT", 5, -20)

        colorByText = widget:CreateFontString(nil, "OVERLAY", font_name)
        colorByText:SetText(L["Color By"])
        colorByText:SetPoint("BOTTOMLEFT", colorBy, "TOPLEFT", 0, 1)

        local normalColor = Cell.CreateColorPicker(widget, L["Normal"], true, function(r, g, b, a)
            widget.colorsTable[2][1] = r
            widget.colorsTable[2][2] = g
            widget.colorsTable[2][3] = b
            widget.colorsTable[2][4] = a
            widget.func(widget.colorsTable)
        end)
        normalColor:SetPoint("TOPLEFT", colorBy, "BOTTOMLEFT", 0, -8)

        -- duration pane --------------------------------------------------------------------------
        local durationPane = CreateFrame("Frame", nil, widget)
        P.Size(durationPane, 260, 36)
        durationPane:SetPoint("TOPLEFT", normalColor, "BOTTOMLEFT", 0, -8)

        local percentColor, percentDropdown

        local percentCB = Cell.CreateCheckButton(durationPane, "", function(checked)
            widget.colorsTable[3][1] = checked
            Cell.SetEnabled(checked, percentColor, percentDropdown)
        end)
        percentCB:SetPoint("TOPLEFT")

        percentColor = Cell.CreateColorPicker(durationPane, L["Remaining Time"].." <", true, function(r, g, b, a)
            widget.colorsTable[3][3][1] = r
            widget.colorsTable[3][3][2] = g
            widget.colorsTable[3][3][3] = b
            widget.colorsTable[3][3][4] = a
            widget.func(widget.colorsTable)
        end)
        percentColor:SetPoint("TOPLEFT", percentCB, "TOPRIGHT", 2, 0)

        local secColor, secEditBox, secText

        local secCB = Cell.CreateCheckButton(durationPane, "", function(checked)
            widget.colorsTable[4][1] = checked
            Cell.SetEnabled(checked, secColor, secEditBox, secText)
        end)
        secCB:SetPoint("TOPLEFT", percentCB, "BOTTOMLEFT", 0, -8)

        secColor = Cell.CreateColorPicker(durationPane, L["Remaining Time"].." <", true, function(r, g, b, a)
            widget.colorsTable[4][3][1] = r
            widget.colorsTable[4][3][2] = g
            widget.colorsTable[4][3][3] = b
            widget.colorsTable[4][3][4] = a
            widget.func(widget.colorsTable)
        end)
        secColor:SetPoint("TOPLEFT", secCB, "TOPRIGHT", 2, 0)

        percentDropdown = Cell.CreateDropdown(durationPane, 60)
        percentDropdown:SetPoint("LEFT", percentColor.label, "RIGHT", 5, 0)
        percentDropdown:SetItems({
            {
                ["text"] = "75%",
                ["value"] = 0.75,
                ["onClick"] = function()
                    widget.colorsTable[3][2] = 0.75
                    widget.func(widget.colorsTable)
                end,
            },
            {
                ["text"] = "50%",
                ["value"] = 0.5,
                ["onClick"] = function()
                    widget.colorsTable[3][2] = 0.5
                    widget.func(widget.colorsTable)
                end,
            },
            {
                ["text"] = "30%",
                ["value"] = 0.3,
                ["onClick"] = function()
                    widget.colorsTable[3][2] = 0.3
                    widget.func(widget.colorsTable)
                end,
            },
            {
                ["text"] = "25%",
                ["value"] = 0.25,
                ["onClick"] = function()
                    widget.colorsTable[3][2] = 0.25
                    widget.func(widget.colorsTable)
                end,
            },
        })

        secEditBox = Cell.CreateEditBox(durationPane, 43, 20, false, false, true)
        secEditBox:SetPoint("LEFT", secColor.label, "RIGHT", 5, 0)
        secEditBox:SetMaxLetters(4)

        secEditBox.confirmBtn = Cell.CreateButton(durationPane, "OK", "accent", {27, 20})
        secEditBox.confirmBtn:SetPoint("LEFT", secEditBox, "RIGHT", -1, 0)
        secEditBox.confirmBtn:Hide()
        secEditBox.confirmBtn:SetScript("OnHide", function()
            secEditBox.confirmBtn:Hide()
        end)
        secEditBox.confirmBtn:SetScript("OnClick", function()
            local newSec = tonumber(secEditBox:GetText())
            widget.colorsTable[4][2] = newSec
            secEditBox:SetText(newSec)
            secEditBox:ClearFocus()
            secEditBox.confirmBtn:Hide()
            widget.func(widget.colorsTable)
        end)

        secEditBox:SetScript("OnTextChanged", function(self, userChanged)
            if userChanged then
                local newSec = tonumber(self:GetText())
                if newSec and newSec ~= widget.colorsTable[3][2] then
                    secEditBox.confirmBtn:Show()
                else
                    secEditBox.confirmBtn:Hide()
                end
            end
        end)

        secText = durationPane:CreateFontString(nil, "OVERLAY", font_name)
        secText:SetPoint("LEFT", secEditBox, "RIGHT", 5, 0)
        secText:SetText(L["sec"])

        -- stack pane -----------------------------------------------------------------------------
        local stackPane = CreateFrame("Frame", nil, widget)
        P.Size(stackPane, 260, 36)
        stackPane:SetPoint("TOPLEFT", normalColor, "BOTTOMLEFT", 0, -8)

        local stackColor1, stackEB1

        local stackCB1 = Cell.CreateCheckButton(stackPane, "", function(checked)
            widget.colorsTable[3][1] = checked
            Cell.SetEnabled(checked, stackColor1, stackEB1)
            widget.func(widget.colorsTable)
        end)
        stackCB1:SetPoint("TOPLEFT")

        stackColor1 = Cell.CreateColorPicker(stackPane, L["Stack"].." >=", true, function(r, g, b, a)
            widget.colorsTable[3][3][1] = r
            widget.colorsTable[3][3][2] = g
            widget.colorsTable[3][3][3] = b
            widget.colorsTable[3][3][4] = a
            widget.func(widget.colorsTable)
        end)
        stackColor1:SetPoint("TOPLEFT", stackCB1, "TOPRIGHT", 2, 0)

        local stackColor2, stackEB2

        local stackCB2 = Cell.CreateCheckButton(stackPane, "", function(checked)
            widget.colorsTable[4][1] = checked
            Cell.SetEnabled(checked, stackColor2, stackEB2)
            widget.func(widget.colorsTable)
        end)
        stackCB2:SetPoint("TOPLEFT", stackCB1, "BOTTOMLEFT", 0, -8)

        stackColor2 = Cell.CreateColorPicker(stackPane, L["Stack"].." >=", true, function(r, g, b, a)
            widget.colorsTable[4][3][1] = r
            widget.colorsTable[4][3][2] = g
            widget.colorsTable[4][3][3] = b
            widget.colorsTable[4][3][4] = a
            widget.func(widget.colorsTable)
        end)
        stackColor2:SetPoint("TOPLEFT", stackCB2, "TOPRIGHT", 2, 0)

        -- eb
        stackEB1 = Cell.CreateEditBox(stackPane, 43, 20, false, false, true)
        stackEB1:SetPoint("LEFT", stackColor1.label, "RIGHT", 5, 0)
        stackEB1:SetMaxLetters(3)

        stackEB1.confirmBtn = Cell.CreateButton(stackPane, "OK", "accent", {27, 20})
        stackEB1.confirmBtn:SetPoint("LEFT", stackEB1, "RIGHT", -1, 0)
        stackEB1.confirmBtn:Hide()
        stackEB1.confirmBtn:SetScript("OnHide", function()
            stackEB1.confirmBtn:Hide()
        end)
        stackEB1.confirmBtn:SetScript("OnClick", function()
            local newStack = tonumber(stackEB1:GetText())
            widget.colorsTable[3][2] = newStack
            stackEB1:SetText(newStack)
            stackEB1:ClearFocus()
            stackEB1.confirmBtn:Hide()
            widget.func(widget.colorsTable)
        end)

        stackEB1:SetScript("OnTextChanged", function(self, userChanged)
            if userChanged then
                local newStack = tonumber(self:GetText())
                if newStack and newStack ~= widget.colorsTable[3][2] then
                    stackEB1.confirmBtn:Show()
                else
                    stackEB1.confirmBtn:Hide()
                end
            end
        end)

        stackEB2 = Cell.CreateEditBox(stackPane, 43, 20, false, false, true)
        stackEB2:SetPoint("LEFT", stackColor2.label, "RIGHT", 5, 0)
        stackEB2:SetMaxLetters(3)

        stackEB2.confirmBtn = Cell.CreateButton(stackPane, "OK", "accent", {27, 20})
        stackEB2.confirmBtn:SetPoint("LEFT", stackEB2, "RIGHT", -1, 0)
        stackEB2.confirmBtn:Hide()
        stackEB2.confirmBtn:SetScript("OnHide", function()
            stackEB2.confirmBtn:Hide()
        end)
        stackEB2.confirmBtn:SetScript("OnClick", function()
            local newStack = tonumber(stackEB2:GetText())
            widget.colorsTable[4][2] = newStack
            stackEB2:SetText(newStack)
            stackEB2:ClearFocus()
            stackEB2.confirmBtn:Hide()
            widget.func(widget.colorsTable)
        end)

        stackEB2:SetScript("OnTextChanged", function(self, userChanged)
            if userChanged then
                local newStack = tonumber(self:GetText())
                if newStack and newStack ~= widget.colorsTable[4][2] then
                    stackEB2.confirmBtn:Show()
                else
                    stackEB2.confirmBtn:Hide()
                end
            end
        end)

        -- control
        colorBy:SetItems({
            {
                ["text"] = L["Duration"],
                ["value"] = "duration",
                ["onClick"] = function()
                    if widget.colorsTable[1] == "duration" then return end
                    durationPane:Show()
                    stackPane:Hide()
                    widget.colorsTable[1] = "duration"
                    widget.colorsTable[3][1] = false
                    widget.colorsTable[4][1] = false
                    widget.colorsTable[3][2] = 0.5
                    widget.colorsTable[4][2] = 3
                    widget.func(widget.colorsTable)
                    widget:SetDBValue(widget.colorsTable)
                end,
            },
            {
                ["text"] = L["Stack"],
                ["value"] = "stack",
                ["onClick"] = function()
                    if widget.colorsTable[1] == "stack" then return end
                    durationPane:Hide()
                    stackPane:Show()
                    widget.colorsTable[1] = "stack"
                    widget.colorsTable[3][1] = false
                    widget.colorsTable[4][1] = false
                    widget.colorsTable[3][2] = 2
                    widget.colorsTable[4][2] = 3
                    widget.func(widget.colorsTable)
                    widget:SetDBValue(widget.colorsTable)
                end,
            },
        })

        -- border color
        local borderColor = Cell.CreateColorPicker(widget, L["Border Color"], true, function(r, g, b, a)
            widget.colorsTable[5][1] = r
            widget.colorsTable[5][2] = g
            widget.colorsTable[5][3] = b
            widget.colorsTable[5][4] = a
            widget.func(widget.colorsTable)
        end)
        borderColor:SetPoint("TOPLEFT", stackPane, "BOTTOMLEFT", 0, -8)

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(colorsTable)
            widget.colorsTable = colorsTable

            colorBy:SetSelectedValue(colorsTable[1])
            if colorsTable[1] == "duration" then
                durationPane:Show()
                stackPane:Hide()
            else
                durationPane:Hide()
                stackPane:Show()
            end

            normalColor:SetColor(colorsTable[2])
            borderColor:SetColor(colorsTable[5])

            Cell.SetEnabled(colorsTable[3][1], percentColor, percentDropdown, stackColor1, stackEB1)
            Cell.SetEnabled(colorsTable[4][1], secColor, secEditBox, secText, stackColor2, stackEB2)

            percentCB:SetChecked(colorsTable[3][1])
            percentColor:SetColor(colorsTable[3][3])
            percentDropdown:SetSelectedValue(colorsTable[3][2])
            secCB:SetChecked(colorsTable[4][1])
            secColor:SetColor(colorsTable[4][3])
            secEditBox:SetText(colorsTable[4][2])

            stackCB1:SetChecked(colorsTable[3][1])
            stackColor1:SetColor(colorsTable[3][3])
            stackEB1:SetText(colorsTable[3][2])
            stackCB2:SetChecked(colorsTable[4][1])
            stackColor2:SetColor(colorsTable[4][3])
            stackEB2:SetText(colorsTable[4][2])
        end
    else
        widget = settingWidgets["blockColors"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_OverlayColors(parent)
    local widget

    if not settingWidgets["overlayColors"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_ColorsWithBG", parent, 240, 74)
        settingWidgets["overlayColors"] = widget

        local normalColor = Cell.CreateColorPicker(widget, L["Normal"], true, function(r, g, b, a)
            widget.colorsTable[1][1] = r
            widget.colorsTable[1][2] = g
            widget.colorsTable[1][3] = b
            widget.colorsTable[1][4] = a
            widget.func(widget.colorsTable)
        end)
        normalColor:SetPoint("TOPLEFT", 5, -8)

        local percentColor, percentDropdown

        local percentCB = Cell.CreateCheckButton(widget, "", function(checked)
            widget.colorsTable[2][1] = checked
            Cell.SetEnabled(checked, percentColor, percentDropdown)
            widget.func(widget.colorsTable)
        end)
        percentCB:SetPoint("TOPLEFT", normalColor, "BOTTOMLEFT", 0, -8)

        percentColor = Cell.CreateColorPicker(widget, L["Remaining Time"].." <", true, function(r, g, b, a)
            widget.colorsTable[2][3][1] = r
            widget.colorsTable[2][3][2] = g
            widget.colorsTable[2][3][3] = b
            widget.colorsTable[2][3][4] = a
            widget.func(widget.colorsTable)
        end)
        percentColor:SetPoint("TOPLEFT", percentCB, "TOPRIGHT", 2, 0)

        local secColor, secEditBox, secText

        local secCB = Cell.CreateCheckButton(widget, "", function(checked)
            widget.colorsTable[3][1] = checked
            Cell.SetEnabled(checked, secColor, secEditBox, secText)
            widget.func(widget.colorsTable)
        end)
        secCB:SetPoint("TOPLEFT", percentCB, "BOTTOMLEFT", 0, -8)

        secColor = Cell.CreateColorPicker(widget, L["Remaining Time"].." <", true, function(r, g, b, a)
            widget.colorsTable[3][3][1] = r
            widget.colorsTable[3][3][2] = g
            widget.colorsTable[3][3][3] = b
            widget.colorsTable[3][3][4] = a
            widget.func(widget.colorsTable)
        end)
        secColor:SetPoint("TOPLEFT", secCB, "TOPRIGHT", 2, 0)

        percentDropdown = Cell.CreateDropdown(widget, 60)
        percentDropdown:SetPoint("LEFT", percentColor.label, "RIGHT", 5, 0)
        percentDropdown:SetItems({
            {
                ["text"] = "75%",
                ["value"] = 0.75,
                ["onClick"] = function()
                    widget.colorsTable[2][2] = 0.75
                    widget.func(widget.colorsTable)
                end,
            },
            {
                ["text"] = "50%",
                ["value"] = 0.5,
                ["onClick"] = function()
                    widget.colorsTable[2][2] = 0.5
                    widget.func(widget.colorsTable)
                end,
            },
            {
                ["text"] = "30%",
                ["value"] = 0.3,
                ["onClick"] = function()
                    widget.colorsTable[2][2] = 0.3
                    widget.func(widget.colorsTable)
                end,
            },
            {
                ["text"] = "25%",
                ["value"] = 0.25,
                ["onClick"] = function()
                    widget.colorsTable[2][2] = 0.25
                    widget.func(widget.colorsTable)
                end,
            },
        })

        secEditBox = Cell.CreateEditBox(widget, 43, 20, false, false, true)
        secEditBox:SetPoint("LEFT", secColor.label, "RIGHT", 5, 0)
        secEditBox:SetMaxLetters(4)

        secEditBox.confirmBtn = Cell.CreateButton(widget, "OK", "accent", {27, 20})
        secEditBox.confirmBtn:SetPoint("LEFT", secEditBox, "RIGHT", -1, 0)
        secEditBox.confirmBtn:Hide()
        secEditBox.confirmBtn:SetScript("OnHide", function()
            secEditBox.confirmBtn:Hide()
        end)
        secEditBox.confirmBtn:SetScript("OnClick", function()
            local newSec = tonumber(secEditBox:GetText())
            widget.colorsTable[3][2] = newSec
            secEditBox:SetText(newSec)
            secEditBox:ClearFocus()
            secEditBox.confirmBtn:Hide()
            widget.func(widget.colorsTable)
        end)

        secEditBox:SetScript("OnTextChanged", function(self, userChanged)
            if userChanged then
                local newSec = tonumber(self:GetText())
                if newSec and newSec ~= widget.colorsTable[3][2] then
                    secEditBox.confirmBtn:Show()
                else
                    secEditBox.confirmBtn:Hide()
                end
            end
        end)

        secText = widget:CreateFontString(nil, "OVERLAY", font_name)
        secText:SetPoint("LEFT", secEditBox, "RIGHT", 5, 0)
        secText:SetText(L["sec"])

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(colorsTable)
            widget.colorsTable = colorsTable

            percentCB:SetChecked(colorsTable[2][1])
            Cell.SetEnabled(colorsTable[2][1], percentColor, percentDropdown)
            secCB:SetChecked(colorsTable[3][1])
            Cell.SetEnabled(colorsTable[3][1], secColor, secEditBox, secText)

            normalColor:SetColor(colorsTable[1])
            percentColor:SetColor(colorsTable[2][3])
            secColor:SetColor(colorsTable[3][3])

            percentDropdown:SetSelectedValue(colorsTable[2][2])
            secEditBox:SetText(colorsTable[3][2])
        end
    else
        widget = settingWidgets["overlayColors"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_CustomColors(parent)
    local widget

    if not settingWidgets["customColors"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_CustomColors", parent, 240, 50)
        settingWidgets["customColors"] = widget

        -- dropdown
        widget.color = Cell.CreateDropdown(widget, 170)
        widget.color:SetPoint("TOPLEFT", 5, -20)

        widget.buffItems = {
            {
                ["text"] = L["Solid"],
                ["value"] = "solid",
                ["onClick"] = function()
                    P.Height(widget, 50)
                    widget.colorPicker1:Show()
                    widget.colorPicker2:Hide()
                    widget.cotFrame:Hide()
                    widget.colorsTable[1] = "solid"
                    widget.func(widget.colorsTable)
                end
            },
            {
                ["text"] = L["Vertical Gradient"],
                ["value"] = "gradient-vertical",
                ["onClick"] = function()
                    P.Height(widget, 50)
                    widget.colorPicker1:Show()
                    widget.colorPicker2:Show()
                    widget.cotFrame:Hide()
                    widget.colorsTable[1] = "gradient-vertical"
                    widget.func(widget.colorsTable)
                end
            },
            {
                ["text"] = L["Horizontal Gradient"],
                ["value"] = "gradient-horizontal",
                ["onClick"] = function()
                    P.Height(widget, 50)
                    widget.colorPicker1:Show()
                    widget.colorPicker2:Show()
                    widget.cotFrame:Hide()
                    widget.colorsTable[1] = "gradient-horizontal"
                    widget.func(widget.colorsTable)
                end
            },
            {
                ["text"] = L["Change Over Time"],
                ["value"] = "change-over-time",
                ["onClick"] = function()
                    P.Height(widget, 117)
                    widget.colorPicker1:Hide()
                    widget.colorPicker2:Hide()
                    widget.cotFrame:Show()
                    widget.colorsTable[1] = "change-over-time"
                    widget.func(widget.colorsTable)
                end
            },
            {
                ["text"] = L["Class Color"],
                ["value"] = "class-color",
                ["onClick"] = function()
                    P.Height(widget, 50)
                    widget.colorPicker1:Hide()
                    widget.colorPicker2:Hide()
                    widget.cotFrame:Hide()
                    widget.colorsTable[1] = "class-color"
                    widget.func(widget.colorsTable)
                end
            },
        }

        widget.debuffItems = {
            {
                ["text"] = L["Solid"],
                ["value"] = "solid",
                ["onClick"] = function()
                    P.Height(widget, 50)
                    widget.colorPicker1:Show()
                    widget.colorPicker2:Hide()
                    widget.cotFrame:Hide()
                    widget.colorsTable[1] = "solid"
                    widget.func(widget.colorsTable)
                end
            },
            {
                ["text"] = L["Vertical Gradient"],
                ["value"] = "gradient-vertical",
                ["onClick"] = function()
                    P.Height(widget, 50)
                    widget.colorPicker1:Show()
                    widget.colorPicker2:Show()
                    widget.cotFrame:Hide()
                    widget.colorsTable[1] = "gradient-vertical"
                    widget.func(widget.colorsTable)
                end
            },
            {
                ["text"] = L["Horizontal Gradient"],
                ["value"] = "gradient-horizontal",
                ["onClick"] = function()
                    P.Height(widget, 50)
                    widget.colorPicker1:Show()
                    widget.colorPicker2:Show()
                    widget.cotFrame:Hide()
                    widget.colorsTable[1] = "gradient-horizontal"
                    widget.func(widget.colorsTable)
                end
            },
            {
                ["text"] = L["Debuff Type"],
                ["value"] = "debuff-type",
                ["onClick"] = function()
                    P.Height(widget, 50)
                    widget.colorPicker1:Hide()
                    widget.colorPicker2:Hide()
                    widget.cotFrame:Hide()
                    widget.colorsTable[1] = "debuff-type"
                    widget.func(widget.colorsTable)
                end
            },
            {
                ["text"] = L["Change Over Time"],
                ["value"] = "change-over-time",
                ["onClick"] = function()
                    P.Height(widget, 117)
                    widget.colorPicker1:Hide()
                    widget.colorPicker2:Hide()
                    widget.cotFrame:Show()
                    widget.colorsTable[1] = "change-over-time"
                    widget.func(widget.colorsTable)
                end
            },
            {
                ["text"] = L["Class Color"],
                ["value"] = "class-color",
                ["onClick"] = function()
                    P.Height(widget, 50)
                    widget.colorPicker1:Hide()
                    widget.colorPicker2:Hide()
                    widget.cotFrame:Hide()
                    widget.colorsTable[1] = "class-color"
                    widget.func(widget.colorsTable)
                end
            },
        }

        widget.colorText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.colorText:SetText(L["Color"])
        widget.colorText:SetPoint("BOTTOMLEFT", widget.color, "TOPLEFT", 0, 1)

        widget.colorPicker1 = Cell.CreateColorPicker(widget, "", true, function(r, g, b, a)
            widget.colorsTable[2][1] = r
            widget.colorsTable[2][2] = g
            widget.colorsTable[2][3] = b
            widget.colorsTable[2][4] = a
            widget.func(widget.colorsTable)
        end)
        widget.colorPicker1:SetPoint("LEFT", widget.color, "RIGHT", 5, 0)

        widget.colorPicker2 = Cell.CreateColorPicker(widget, "", true, function(r, g, b, a)
            widget.colorsTable[3][1] = r
            widget.colorsTable[3][2] = g
            widget.colorsTable[3][3] = b
            widget.colorsTable[3][4] = a
            widget.func(widget.colorsTable)
        end)
        widget.colorPicker2:SetPoint("LEFT", widget.colorPicker1, "RIGHT", 5, 0)

        widget.cotFrame = CreateFrame("Frame", nil, widget)
        widget.cotFrame:SetSize(170, 50)
        widget.cotFrame:SetPoint("TOPLEFT", widget.color, "BOTTOMLEFT", 0, -8)

        local normalColor = Cell.CreateColorPicker(widget.cotFrame, L["Normal"], true, function(r, g, b, a)
            widget.colorsTable[4][1] = r
            widget.colorsTable[4][2] = g
            widget.colorsTable[4][3] = b
            widget.colorsTable[4][4] = a
            widget.func(widget.colorsTable)
        end)
        normalColor:SetPoint("TOPLEFT")

        local percentColor = Cell.CreateColorPicker(widget.cotFrame, L["Remaining Time"].." <", true, function(r, g, b, a)
            widget.colorsTable[5][2][1] = r
            widget.colorsTable[5][2][2] = g
            widget.colorsTable[5][2][3] = b
            widget.colorsTable[5][2][4] = a
            widget.func(widget.colorsTable)
        end)
        percentColor:SetPoint("TOPLEFT", normalColor, "BOTTOMLEFT", 0, -8)

        local secColor = Cell.CreateColorPicker(widget.cotFrame, L["Remaining Time"].." <", true, function(r, g, b, a)
            widget.colorsTable[6][2][1] = r
            widget.colorsTable[6][2][2] = g
            widget.colorsTable[6][2][3] = b
            widget.colorsTable[6][2][4] = a
            widget.func(widget.colorsTable)
        end)
        secColor:SetPoint("TOPLEFT", percentColor, "BOTTOMLEFT", 0, -8)

        local percentDropdown = Cell.CreateDropdown(widget.cotFrame, 60)
        percentDropdown:SetPoint("LEFT", percentColor.label, "RIGHT", 5, 0)
        percentDropdown:SetItems({
            {
                ["text"] = "75%",
                ["value"] = 0.75,
                ["onClick"] = function()
                    widget.colorsTable[5][1] = 0.75
                    widget.func(widget.colorsTable)
                end,
            },
            {
                ["text"] = "50%",
                ["value"] = 0.5,
                ["onClick"] = function()
                    widget.colorsTable[5][1] = 0.5
                    widget.func(widget.colorsTable)
                end,
            },
            {
                ["text"] = "30%",
                ["value"] = 0.3,
                ["onClick"] = function()
                    widget.colorsTable[5][1] = 0.3
                    widget.func(widget.colorsTable)
                end,
            },
            {
                ["text"] = "25%",
                ["value"] = 0.25,
                ["onClick"] = function()
                    widget.colorsTable[5][1] = 0.25
                    widget.func(widget.colorsTable)
                end,
            },
            {
                ["text"] = _G.NONE,
                ["value"] = 0,
                ["onClick"] = function()
                    widget.colorsTable[5][1] = 0
                    widget.func(widget.colorsTable)
                end,
            },
        })

        local secEditBox = Cell.CreateEditBox(widget.cotFrame, 43, 20, false, false, true)
        secEditBox:SetPoint("LEFT", secColor.label, "RIGHT", 5, 0)
        secEditBox:SetMaxLetters(4)

        secEditBox.confirmBtn = Cell.CreateButton(widget.cotFrame, "OK", "accent", {27, 20})
        secEditBox.confirmBtn:SetPoint("LEFT", secEditBox, "RIGHT", -1, 0)
        secEditBox.confirmBtn:Hide()
        secEditBox.confirmBtn:SetScript("OnHide", function()
            secEditBox.confirmBtn:Hide()
        end)
        secEditBox.confirmBtn:SetScript("OnClick", function()
            local newSec = tonumber(secEditBox:GetText())
            widget.colorsTable[6][1] = newSec
            secEditBox:SetText(newSec)
            secEditBox:ClearFocus()
            secEditBox.confirmBtn:Hide()
            widget.func(widget.colorsTable)
        end)

        secEditBox:SetScript("OnTextChanged", function(self, userChanged)
            if userChanged then
                local newSec = tonumber(self:GetText())
                if newSec and newSec ~= widget.colorsTable[6][1] then
                    secEditBox.confirmBtn:Show()
                else
                    secEditBox.confirmBtn:Hide()
                end
            end
        end)

        local secText = widget.cotFrame:CreateFontString(nil, "OVERLAY", font_name)
        secText:SetPoint("LEFT", secEditBox, "RIGHT", 5, 0)
        secText:SetText(L["sec"])

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(colorsTable, auraType)
            widget.colorsTable = colorsTable

            if auraType == "buff" then
                widget.color:SetItems(widget.buffItems)
            else -- debuff
                widget.color:SetItems(widget.debuffItems)
            end
            widget.color:SetSelectedValue(colorsTable[1])

            if colorsTable[1] == "solid" then
                P.Height(widget, 50)
                widget.colorPicker1:Show()
                widget.colorPicker2:Hide()
                widget.cotFrame:Hide()
            elseif colorsTable[1] == "debuff-type" then
                P.Height(widget, 50)
                widget.colorPicker1:Hide()
                widget.colorPicker2:Hide()
                widget.cotFrame:Hide()
            elseif colorsTable[1] == "change-over-time" then
                P.Height(widget, 117)
                widget.colorPicker1:Hide()
                widget.colorPicker2:Hide()
                widget.cotFrame:Show()
            elseif colorsTable[1] == "class-color" then
                P.Height(widget, 50)
                widget.colorPicker1:Hide()
                widget.colorPicker2:Hide()
                widget.cotFrame:Hide()
            else -- gradient
                P.Height(widget, 50)
                widget.colorPicker1:Show()
                widget.colorPicker2:Show()
                widget.cotFrame:Hide()
            end

            widget.colorPicker1:SetColor(colorsTable[2])
            widget.colorPicker2:SetColor(colorsTable[3])

            normalColor:SetColor(colorsTable[4])
            percentColor:SetColor(colorsTable[5][2])
            secColor:SetColor(colorsTable[6][2])

            percentDropdown:SetSelectedValue(colorsTable[5][1])
            secEditBox:SetText(colorsTable[6][1])
        end
    else
        widget = settingWidgets["customColors"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_ClassColor(parent)
    local widget

    if not settingWidgets["classColor"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_ClassColor", parent, 240, 50)
        settingWidgets["classColor"] = widget

        widget.colorDropdown = Cell.CreateDropdown(widget, 127)
        widget.colorDropdown:SetPoint("TOPLEFT", 5, -20)
        widget.colorDropdown:SetItems({
            {
                ["text"] = L["Class Color"],
                ["value"] = "class_color",
                ["onClick"] = function()
                    widget.func({"class_color", widget.colorPicker:GetColor()})
                    widget.colorPicker:Hide()
                end,
            },
            {
                ["text"] = L["Custom Color"],
                ["value"] = "custom_color",
                ["onClick"] = function()
                    widget.func({"custom_color", widget.colorPicker:GetColor()})
                    widget.colorPicker:Show()
                end,
            },
        })

        local text = widget:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
        text:SetPoint("BOTTOMLEFT", widget.colorDropdown, "TOPLEFT", 0, 1)
        text:SetText(L["Color"])

        widget.colorPicker = Cell.CreateColorPicker(widget, "", false, function(r, g, b)
            widget.func({widget.colorDropdown:GetSelected(), {r, g, b}})
        end)
        widget.colorPicker:SetPoint("LEFT", widget.colorDropdown, "RIGHT", 5, 0)

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(cTable)
            widget.colorDropdown:SetSelectedValue(cTable[1])
            widget.colorPicker:SetColor(cTable[2])
            if cTable[1] == "custom_color" then
                widget.colorPicker:Show()
            else
                widget.colorPicker:Hide()
            end
        end
    else
        widget = settingWidgets["classColor"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_PowerColor(parent)
    local widget

    if not settingWidgets["powerColor"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_PowerColor", parent, 240, 50)
        settingWidgets["powerColor"] = widget

        widget.colorDropdown = Cell.CreateDropdown(widget, 127)
        widget.colorDropdown:SetPoint("TOPLEFT", 5, -20)
        widget.colorDropdown:SetItems({
            {
                ["text"] = L["Power Color"],
                ["value"] = "power_color",
                ["onClick"] = function()
                    widget.func({"power_color", widget.colorPicker:GetColor()})
                    widget.colorPicker:Hide()
                end,
            },
            {
                ["text"] = L["Class Color"],
                ["value"] = "class_color",
                ["onClick"] = function()
                    widget.func({"class_color", widget.colorPicker:GetColor()})
                    widget.colorPicker:Hide()
                end,
            },
            {
                ["text"] = L["Custom Color"],
                ["value"] = "custom_color",
                ["onClick"] = function()
                    widget.func({"custom_color", widget.colorPicker:GetColor()})
                    widget.colorPicker:Show()
                end,
            },
        })

        local text = widget:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
        text:SetPoint("BOTTOMLEFT", widget.colorDropdown, "TOPLEFT", 0, 1)
        text:SetText(L["Color"])

        widget.colorPicker = Cell.CreateColorPicker(widget, "", false, function(r, g, b)
            widget.func({widget.colorDropdown:GetSelected(), {r, g, b}})
        end)
        widget.colorPicker:SetPoint("LEFT", widget.colorDropdown, "RIGHT", 5, 0)

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(cTable)
            widget.colorDropdown:SetSelectedValue(cTable[1])
            widget.colorPicker:SetColor(cTable[2])
            if cTable[1] == "custom_color" then
                widget.colorPicker:Show()
            else
                widget.colorPicker:Hide()
            end
        end
    else
        widget = settingWidgets["powerColor"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_StatusColors(parent)
    local widget

    if not settingWidgets["statusColors"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_StatusColors", parent, 240, 100)
        settingWidgets["statusColors"] = widget

        local afkColor = Cell.CreateColorPicker(widget, L["AFK"], true, function(r, g, b, a)
            widget.colorsTable["AFK"][1] = r
            widget.colorsTable["AFK"][2] = g
            widget.colorsTable["AFK"][3] = b
            widget.colorsTable["AFK"][4] = a
            widget.func()
        end)
        afkColor:SetPoint("TOPLEFT", 5, -7)

        local offlineColor = Cell.CreateColorPicker(widget, L["OFFLINE"], true, function(r, g, b, a)
            widget.colorsTable["OFFLINE"][1] = r
            widget.colorsTable["OFFLINE"][2] = g
            widget.colorsTable["OFFLINE"][3] = b
            widget.colorsTable["OFFLINE"][4] = a
            widget.func()
        end)
        offlineColor:SetPoint("TOPLEFT", afkColor, "TOPRIGHT", 70, 0)

        local deadColor = Cell.CreateColorPicker(widget, L["DEAD"], true, function(r, g, b, a)
            widget.colorsTable["DEAD"][1] = r
            widget.colorsTable["DEAD"][2] = g
            widget.colorsTable["DEAD"][3] = b
            widget.colorsTable["DEAD"][4] = a
            widget.func()
        end)
        deadColor:SetPoint("TOPLEFT", offlineColor, "TOPRIGHT", 70, 0)

        local ghostColor = Cell.CreateColorPicker(widget, L["GHOST"], true, function(r, g, b, a)
            widget.colorsTable["GHOST"][1] = r
            widget.colorsTable["GHOST"][2] = g
            widget.colorsTable["GHOST"][3] = b
            widget.colorsTable["GHOST"][4] = a
            widget.func()
        end)
        ghostColor:SetPoint("TOPLEFT", afkColor, "BOTTOMLEFT", 0, -8)

        local feignColor = Cell.CreateColorPicker(widget, L["FEIGN"], true, function(r, g, b, a)
            widget.colorsTable["FEIGN"][1] = r
            widget.colorsTable["FEIGN"][2] = g
            widget.colorsTable["FEIGN"][3] = b
            widget.colorsTable["FEIGN"][4] = a
            widget.func()
        end)
        feignColor:SetPoint("TOPLEFT", ghostColor, "TOPRIGHT", 70, 0)

        local drinkingColor = Cell.CreateColorPicker(widget, L["DRINKING"], true, function(r, g, b, a)
            widget.colorsTable["DRINKING"][1] = r
            widget.colorsTable["DRINKING"][2] = g
            widget.colorsTable["DRINKING"][3] = b
            widget.colorsTable["DRINKING"][4] = a
            widget.func()
        end)
        drinkingColor:SetPoint("TOPLEFT", feignColor, "TOPRIGHT", 70, 0)

        local pendingColor = Cell.CreateColorPicker(widget, L["PENDING"], true, function(r, g, b, a)
            widget.colorsTable["PENDING"][1] = r
            widget.colorsTable["PENDING"][2] = g
            widget.colorsTable["PENDING"][3] = b
            widget.colorsTable["PENDING"][4] = a
            widget.func()
        end)
        pendingColor:SetPoint("TOPLEFT", ghostColor, "BOTTOMLEFT", 0, -8)
        pendingColor:SetEnabled(Cell.isRetail)

        local acceptedColor = Cell.CreateColorPicker(widget, L["ACCEPTED"], true, function(r, g, b, a)
            widget.colorsTable["ACCEPTED"][1] = r
            widget.colorsTable["ACCEPTED"][2] = g
            widget.colorsTable["ACCEPTED"][3] = b
            widget.colorsTable["ACCEPTED"][4] = a
            widget.func()
        end)
        acceptedColor:SetPoint("TOPLEFT", pendingColor, "TOPRIGHT", 70, 0)
        acceptedColor:SetEnabled(Cell.isRetail)

        local declinedColor = Cell.CreateColorPicker(widget, L["DECLINED"], true, function(r, g, b, a)
            widget.colorsTable["DECLINED"][1] = r
            widget.colorsTable["DECLINED"][2] = g
            widget.colorsTable["DECLINED"][3] = b
            widget.colorsTable["DECLINED"][4] = a
            widget.func()
        end)
        declinedColor:SetPoint("TOPLEFT", acceptedColor, "TOPRIGHT", 70, 0)
        declinedColor:SetEnabled(Cell.isRetail)

        local resetBtn = Cell.CreateButton(widget, L["Reset All"], "accent", {70, 20})
        resetBtn:SetPoint("TOPLEFT", pendingColor, "BOTTOMLEFT", 0, -8)
        resetBtn:SetScript("OnClick", function()
            widget.colorsTable["AFK"] = {1, 0.19, 0.19, 1}
            widget.colorsTable["OFFLINE"] = {1, 0.19, 0.19, 1}
            widget.colorsTable["DEAD"] = {1, 0.19, 0.19, 1}
            widget.colorsTable["GHOST"] = {1, 0.19, 0.19, 1}
            widget.colorsTable["FEIGN"] = {1, 1, 0.12, 1}
            widget.colorsTable["DRINKING"] = {0.12, 0.75, 1, 1}
            widget.colorsTable["PENDING"] = {1, 1, 0.12, 1}
            widget.colorsTable["ACCEPTED"] = {0.12, 1, 0.12, 1}
            widget.colorsTable["DECLINED"] = {1, 0.19, 0.19, 1}

            afkColor:SetColor(widget.colorsTable["AFK"])
            offlineColor:SetColor(widget.colorsTable["OFFLINE"])
            deadColor:SetColor(widget.colorsTable["DEAD"])
            ghostColor:SetColor(widget.colorsTable["GHOST"])
            feignColor:SetColor(widget.colorsTable["FEIGN"])
            drinkingColor:SetColor(widget.colorsTable["DRINKING"])
            pendingColor:SetColor(widget.colorsTable["PENDING"])
            acceptedColor:SetColor(widget.colorsTable["ACCEPTED"])
            declinedColor:SetColor(widget.colorsTable["DECLINED"])

            widget.func()
        end)

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(colorsTable)
            widget.colorsTable = colorsTable

            afkColor:SetColor(colorsTable["AFK"])
            offlineColor:SetColor(colorsTable["OFFLINE"])
            deadColor:SetColor(colorsTable["DEAD"])
            ghostColor:SetColor(colorsTable["GHOST"])
            feignColor:SetColor(colorsTable["FEIGN"])
            drinkingColor:SetColor(colorsTable["DRINKING"])
            pendingColor:SetColor(colorsTable["PENDING"])
            acceptedColor:SetColor(colorsTable["ACCEPTED"])
            declinedColor:SetColor(colorsTable["DECLINED"])
        end
    else
        widget = settingWidgets["statusColors"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_CheckButton(parent)
    local widget

    if not settingWidgets["checkbutton"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_CheckButton", parent, 240, 30)
        settingWidgets["checkbutton"] = widget

        widget.cb = Cell.CreateCheckButton(widget, "checkbutton")
        widget.cb:SetPoint("TOPLEFT", 5, -8)

        -- callback
        function widget:SetFunc(func)
            widget.cb.onClick = function(checked)
                func(checked)
            end
        end

        -- show db value
        function widget:SetDBValue(settingName, checked, tooltip)
            widget.cb:SetChecked(checked)
            widget.cb:SetText(L[settingName])
            if tooltip then
                Cell.SetTooltips(widget.cb, "ANCHOR_TOPLEFT", 0, 2, L[settingName], string.split("|", tooltip))
            else
                Cell.ClearTooltips(widget.cb)
            end
        end
    else
        widget = settingWidgets["checkbutton"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_CheckButton2(parent)
    local widget

    if not settingWidgets["checkbutton2"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_CheckButton2", parent, 240, 30)
        settingWidgets["checkbutton2"] = widget

        widget.cb = Cell.CreateCheckButton(widget, "checkbutton2")
        widget.cb:SetPoint("TOPLEFT", 5, -8)

        -- callback
        function widget:SetFunc(func)
            widget.cb.onClick = function(checked)
                func(checked)
            end
        end

        -- show db value
        function widget:SetDBValue(settingName, checked, tooltip)
            widget.cb:SetChecked(checked)
            widget.cb:SetText(L[settingName])
            if tooltip then
                Cell.SetTooltips(widget.cb, "ANCHOR_TOPLEFT", 0, 2, L[settingName], string.split("|", tooltip))
            else
                Cell.ClearTooltips(widget.cb)
            end
        end
    else
        widget = settingWidgets["checkbutton2"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_CheckButton3(parent)
    local widget

    if not settingWidgets["checkbutton3"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_CheckButton3", parent, 240, 30)
        settingWidgets["checkbutton3"] = widget

        widget.cb = Cell.CreateCheckButton(widget, "checkbutton3")
        widget.cb:SetPoint("TOPLEFT", 5, -8)

        -- callback
        function widget:SetFunc(func)
            widget.cb.onClick = function(checked)
                func(checked)
            end
        end

        -- show db value
        function widget:SetDBValue(settingName, checked, tooltip)
            widget.cb:SetChecked(checked)
            widget.cb:SetText(L[settingName])
            if tooltip then
                Cell.SetTooltips(widget.cb, "ANCHOR_TOPLEFT", 0, 2, L[settingName], string.split("|", tooltip))
            else
                Cell.ClearTooltips(widget.cb)
            end
        end
    else
        widget = settingWidgets["checkbutton3"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_CheckButton4(parent)
    local widget

    if not settingWidgets["checkbutton4"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_CheckButton4", parent, 240, 30)
        settingWidgets["checkbutton4"] = widget

        widget.cb = Cell.CreateCheckButton(widget, "checkbutton4")
        widget.cb:SetPoint("TOPLEFT", 5, -8)

        -- callback
        function widget:SetFunc(func)
            widget.cb.onClick = function(checked)
                func(checked)
            end
        end

        -- show db value
        function widget:SetDBValue(settingName, checked, tooltip)
            widget.cb:SetChecked(checked)
            widget.cb:SetText(L[settingName])
            if tooltip then
                Cell.SetTooltips(widget.cb, "ANCHOR_TOPLEFT", 0, 2, L[settingName], string.split("|", tooltip))
            else
                Cell.ClearTooltips(widget.cb)
            end
        end
    else
        widget = settingWidgets["checkbutton4"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_Duration(parent)
    local widget

    if not settingWidgets["duration"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_Duration", parent, 240, 97)
        settingWidgets["duration"] = widget

        -- duration
        widget.durationCB = Cell.CreateCheckButton(widget, L["showDuration"], function(checked, self)
            widget.durationTbl[1] = checked
            widget.func(widget.durationTbl)
        end)
        widget.durationCB:SetPoint("TOPLEFT", 5, -8)

        -- duration round up
        widget.durationRoundUpCB = Cell.CreateCheckButton(widget, L["Round Up Duration Text"], function(checked, self)
            CellDropdownList:Hide()
            widget.durationTbl[2] = checked
            Cell.SetEnabled(not checked, widget.durationDecimalText1, widget.durationDecimalText2, widget.durationDecimalDropdown)
            widget.func(widget.durationTbl)
        end)
        widget.durationRoundUpCB:SetPoint("TOPLEFT", widget.durationCB, "BOTTOMLEFT", 0, -8)

        -- duration decimal
        widget.durationDecimalText1 = widget:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
        widget.durationDecimalText1:SetPoint("TOPLEFT", widget.durationRoundUpCB, "BOTTOMLEFT", 1, -10)
        widget.durationDecimalText1:SetText(L["Display One Decimal Place When"])

        widget.durationDecimalText2 = widget:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
        widget.durationDecimalText2:SetPoint("TOPLEFT", widget.durationDecimalText1, "BOTTOMLEFT", 0, -5)
        widget.durationDecimalText2:SetText(L["Remaining Time"].." <")

        widget.durationDecimalDropdown = Cell.CreateDropdown(widget, 60)
        widget.durationDecimalDropdown:SetPoint("LEFT", widget.durationDecimalText2, "RIGHT", 5, 0)

        local items = {}
        for i = 5, 0, -1 do
            tinsert(items, {
                ["text"] = i == 0 and _G.NONE or i,
                ["value"] = i,
                ["onClick"] = function()
                    widget.durationTbl[3] = i
                    widget.func(widget.durationTbl)
                end
            })
        end
        widget.durationDecimalDropdown:SetItems(items)

        -- callback
        function widget:SetFunc(func)
            -- NOTE: to notify indicator update
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(durationTbl)
            widget.durationTbl = durationTbl
            widget.durationCB:SetChecked(durationTbl[1])
            widget.durationRoundUpCB:SetChecked(durationTbl[2])
            Cell.SetEnabled(not durationTbl[2], widget.durationDecimalText1, widget.durationDecimalText2, widget.durationDecimalDropdown)
            widget.durationDecimalDropdown:SetSelectedValue(durationTbl[3])
        end
    else
        widget = settingWidgets["duration"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_Stack(parent)
    local widget

    if not settingWidgets["stack"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_Stack", parent, 240, 52)
        settingWidgets["stack"] = widget

        -- show stack
        widget.stackCB = Cell.CreateCheckButton(widget, L["showStack"], function(checked, self)
            widget.stackTbl[1] = checked
            widget.func(widget.stackTbl)
            -- widget.circledStackCB:SetEnabled(checked)
        end)
        widget.stackCB:SetPoint("TOPLEFT", 5, -8)

        -- circled stack nums
        widget.circledStackCB = Cell.CreateCheckButton(widget, L["circledStackNums"], function(checked, self)
            CellDropdownList:Hide()
            widget.stackTbl[2] = checked
            Cell.SetEnabled(not checked, widget.durationDecimalText1, widget.durationDecimalText2, widget.durationDecimalDropdown)
            widget.func(widget.stackTbl)
        end, L["circledStackNums"], L["Require font support"])
        widget.circledStackCB:SetPoint("TOPLEFT", widget.stackCB, "BOTTOMLEFT", 0, -8)

        -- callback
        function widget:SetFunc(func)
            -- NOTE: to notify indicator update
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(stackTbl)
            widget.stackTbl = stackTbl
            widget.stackCB:SetChecked(stackTbl[1])
            widget.circledStackCB:SetChecked(stackTbl[2])
            -- widget.circledStackCB:SetEnabled(stackTbl[1])
        end
    else
        widget = settingWidgets["stack"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_RoleTexture(parent)
    local widget

    if not settingWidgets["roleTexture"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_RoleTexture", parent, 240, 180)
        settingWidgets["roleTexture"] = widget

        widget.texture = Cell.CreateDropdown(widget, 260)
        widget.texture:SetPoint("TOPLEFT", 5, -20)

        local blizzard = F.UpperFirst(SLASH_TEXTTOSPEECH_BLIZZARD)
        local indices = {"default", "default2", "blizzard", "blizzard2", "blizzard3", "blizzard4", "ffxiv", "miirgui", "mattui", "custom"}
        local ICON_PATH = " |TInterface\\AddOns\\Cell\\Media\\Roles\\Preview_%s:0:4|t"
        local options = {
            ["default"] = _G.DEFAULT..format(ICON_PATH, "Default"),
            ["default2"] = _G.DEFAULT.." 2"..format(ICON_PATH, "Default2"),
            ["blizzard"] = blizzard..format(ICON_PATH, "Blizzard"),
            ["blizzard2"] = blizzard.." 2"..format(ICON_PATH, "Blizzard2"),
            ["blizzard3"] = blizzard.." 3"..format(ICON_PATH, "Blizzard3"),
            ["blizzard4"] = blizzard.." 4"..format(ICON_PATH, "Blizzard4"),
            ["ffxiv"] = "FFXIV"..format(ICON_PATH, "FFXIV"),
            ["miirgui"] = "MiirGui"..format(ICON_PATH, "MiirGui"),
            ["mattui"] = "MattUI"..format(ICON_PATH, "MattUI"),
            ["custom"] = _G.CUSTOM,
        }

        local items = {}
        for _, v in ipairs(indices) do
            tinsert(items, {
                ["text"] = options[v],
                ["value"] = v,
                ["onClick"] = function()
                    widget.func({v, widget.eb1:GetText(), widget.eb2:GetText(), widget.eb3:GetText()})
                    Cell.SetEnabled(v == "custom",
                        widget.text1, widget.text2, widget.text3,
                        widget.texture1, widget.texture2, widget.texture3,
                        widget.eb1, widget.eb2, widget.eb3
                    )
                end
            })
        end
        widget.texture:SetItems(items)

        widget.textureText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.textureText:SetText(L["Texture"])
        widget.textureText:SetPoint("BOTTOMLEFT", widget.texture, "TOPLEFT", 0, 1)

        widget.eb1 = Cell.CreateEditBox(widget, 260, 20)
        widget.eb1:SetPoint("TOPLEFT", widget.texture, "BOTTOMLEFT", 0, -25)
        widget.eb1:SetScript("OnEnterPressed", function(self)
            self:ClearFocus()
            widget.func({widget.texture:GetSelected(), self:GetText(), widget.eb2:GetText(), widget.eb3:GetText()})
            widget.texture1:SetTexture(self:GetText())
        end)

        widget.text1 = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.text1:SetPoint("BOTTOMLEFT", widget.eb1, "TOPLEFT", 0, 1)
        widget.text1:SetText(_G["TANK"])

        widget.texture1 = widget:CreateTexture(nil, "ARTWORK")
        widget.texture1:SetPoint("BOTTOMLEFT", widget.text1, "BOTTOMRIGHT", 3, 0)
        widget.texture1:SetSize(16, 16)

        widget.eb2 = Cell.CreateEditBox(widget, 260, 20)
        widget.eb2:SetPoint("TOPLEFT", widget.eb1, "BOTTOMLEFT", 0, -25)
        widget.eb2:SetScript("OnEnterPressed", function(self)
            self:ClearFocus()
            widget.func({widget.texture:GetSelected(), widget.eb1:GetText(), self:GetText(), widget.eb3:GetText()})
            widget.texture2:SetTexture(self:GetText())
        end)

        widget.text2 = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.text2:SetPoint("BOTTOMLEFT", widget.eb2, "TOPLEFT", 0, 1)
        widget.text2:SetText(_G["HEALER"])

        widget.texture2 = widget:CreateTexture(nil, "ARTWORK")
        widget.texture2:SetPoint("BOTTOMLEFT", widget.text2, "BOTTOMRIGHT", 3, 0)
        widget.texture2:SetSize(16, 16)

        widget.eb3 = Cell.CreateEditBox(widget, 260, 20)
        widget.eb3:SetPoint("TOPLEFT", widget.eb2, "BOTTOMLEFT", 0, -25)
        widget.eb3:SetScript("OnEnterPressed", function(self)
            self:ClearFocus()
            widget.func({widget.texture:GetSelected(), widget.eb1:GetText(), widget.eb2:GetText(), self:GetText()})
            widget.texture3:SetTexture(self:GetText())
        end)

        widget.text3 = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.text3:SetPoint("BOTTOMLEFT", widget.eb3, "TOPLEFT", 0, 1)
        widget.text3:SetText(_G["DAMAGER"])

        widget.texture3 = widget:CreateTexture(nil, "ARTWORK")
        widget.texture3:SetPoint("BOTTOMLEFT", widget.text3, "BOTTOMRIGHT", 3, 0)
        widget.texture3:SetSize(16, 16)

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(t)
            widget.texture:SetSelectedValue(t[1])
            Cell.SetEnabled(t[1] == "custom",
                widget.text1, widget.text2, widget.text3,
                widget.texture1, widget.texture2, widget.texture3,
                widget.eb1, widget.eb2, widget.eb3
            )

            widget.eb1:SetText(t[2])
            widget.eb2:SetText(t[3])
            widget.eb3:SetText(t[4])
            widget.eb1:SetCursorPosition(0)
            widget.eb2:SetCursorPosition(0)
            widget.eb3:SetCursorPosition(0)
            widget.texture1:SetTexture(t[2])
            widget.texture2:SetTexture(t[3])
            widget.texture3:SetTexture(t[4])
        end
    else
        widget = settingWidgets["roleTexture"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_Glow(parent)
    local widget

    if not settingWidgets["glow"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_Glow", parent, 240, 145)
        settingWidgets["glow"] = widget

        widget.glowType = Cell.CreateDropdown(widget, 110)
        widget.glowType:SetPoint("TOPLEFT", 5, -20)
        widget.glowType:SetItems({
            {
                ["text"] = L["None"],
                ["value"] = "None",
                ["onClick"] = function()
                    widget:SetHeight(50)
                    Cell.UpdateIndicatorSettingsHeight()
                    widget.glowColor:SetColor({0.95,0.95,0.32,1})
                    widget.glowColor:Hide()
                    widget.glowLines:Hide()
                    widget.glowParticles:Hide()
                    widget.glowDuration:Hide()
                    widget.glowFrequency:Hide()
                    widget.glowLength:Hide()
                    widget.glowThickness:Hide()
                    widget.glowScale:Hide()
                    widget.glow[1] = "None"
                    widget.glow[2] = {0.95,0.95,0.32,1}
                    widget.glow[3] = nil
                    widget.glow[4] = nil
                    widget.glow[5] = nil
                    widget.glow[6] = nil
                    widget.func(widget.glow)
                end,
            },
            {
                ["text"] = L["Normal"],
                ["value"] = "Normal",
                ["onClick"] = function()
                    widget:SetHeight(50)
                    Cell.UpdateIndicatorSettingsHeight()
                    widget.glowColor:SetColor({0.95,0.95,0.32,1})
                    widget.glowColor:Show()
                    widget.glowLines:Hide()
                    widget.glowParticles:Hide()
                    widget.glowDuration:Hide()
                    widget.glowFrequency:Hide()
                    widget.glowLength:Hide()
                    widget.glowThickness:Hide()
                    widget.glowScale:Hide()
                    widget.glow[1] = "Normal"
                    widget.glow[2] = {0.95,0.95,0.32,1}
                    widget.glow[3] = nil
                    widget.glow[4] = nil
                    widget.glow[5] = nil
                    widget.glow[6] = nil
                    widget.func(widget.glow)
                end,
            },
            {
                ["text"] = L["Pixel"],
                ["value"] = "Pixel",
                ["onClick"] = function()
                    widget:SetHeight(145)
                    Cell.UpdateIndicatorSettingsHeight()
                    widget.glowColor:SetColor({0.95,0.95,0.32,1})
                    widget.glowColor:Show()
                    widget.glowLines:Show()
                    widget.glowLines:SetValue(9)
                    widget.glowFrequency:Show()
                    widget.glowFrequency:SetValue(0.25)
                    widget.glowLength:Show()
                    widget.glowLength:SetValue(8)
                    widget.glowThickness:Show()
                    widget.glowThickness:SetValue(2)
                    widget.glowParticles:Hide()
                    widget.glowDuration:Hide()
                    widget.glowScale:Hide()
                    widget.glow[1] = "Pixel"
                    widget.glow[2] = {0.95,0.95,0.32,1}
                    widget.glow[3] = widget.useSmallerSize and 4 or 9
                    widget.glow[4] = 0.25
                    widget.glow[5] = widget.useSmallerSize and 4 or 8
                    widget.glow[6] = widget.useSmallerSize and 1 or 2
                    widget.func(widget.glow)
                end,
            },
            {
                ["text"] = L["Shine"],
                ["value"] = "Shine",
                ["onClick"] = function()
                    widget:SetHeight(145)
                    Cell.UpdateIndicatorSettingsHeight()
                    widget.glowColor:SetColor({0.95,0.95,0.32,1})
                    widget.glowColor:Show()
                    widget.glowParticles:Show()
                    widget.glowParticles:SetValue(9)
                    widget.glowFrequency:Show()
                    widget.glowFrequency:SetValue(0.5)
                    widget.glowScale:Show()
                    widget.glowScale:SetValue(100)
                    widget.glowLines:Hide()
                    widget.glowDuration:Hide()
                    widget.glowLength:Hide()
                    widget.glowThickness:Hide()
                    widget.glow[1] = "Shine"
                    widget.glow[2] = {0.95,0.95,0.32,1}
                    widget.glow[3] = widget.useSmallerSize and 4 or 9
                    widget.glow[4] = 0.5
                    widget.glow[5] = widget.useSmallerSize and 0.7 or 1
                    widget.glow[6] = nil
                    widget.func(widget.glow)
                end,
            },
            {
                ["text"] = L["Proc"],
                ["value"] = "Proc",
                ["onClick"] = function()
                    widget:SetHeight(95)
                    Cell.UpdateIndicatorSettingsHeight()
                    widget.glowColor:SetColor({0.95,0.95,0.32,1})
                    widget.glowColor:Show()
                    widget.glowDuration:Show()
                    widget.glowDuration:SetValue(1)
                    widget.glowParticles:Hide()
                    widget.glowFrequency:Hide()
                    widget.glowScale:Hide()
                    widget.glowLines:Hide()
                    widget.glowLength:Hide()
                    widget.glowThickness:Hide()
                    widget.glow[1] = "Proc"
                    widget.glow[2] = {0.95,0.95,0.32,1}
                    widget.glow[3] = 1
                    widget.glow[4] = nil
                    widget.glow[5] = nil
                    widget.glow[6] = nil
                    widget.func(widget.glow)
                end,
            },
        })

        widget.glowTypeText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.glowTypeText:SetText(L["Glow Type"])
        widget.glowTypeText:SetPoint("BOTTOMLEFT", widget.glowType, "TOPLEFT", 0, 1)

        widget.glowColor = Cell.CreateColorPicker(widget, L["Glow Color"], false, function(r, g, b)
            widget.glow[2] = {r, g, b, 1}
            widget.func(widget.glow)
        end)
        widget.glowColor:SetPoint("LEFT", widget.glowType, "RIGHT", 25, 0)

        -- glowNumber
        widget.glowLines = Cell.CreateSlider(L["Lines"], widget, 1, 30, 110, 1, function(value)
            widget.glow[3] = value
            widget.func(widget.glow)
        end)
        widget.glowLines:SetPoint("TOPLEFT", widget.glowType, "BOTTOMLEFT", 0, -25)

        widget.glowParticles = Cell.CreateSlider(L["Particles"], widget, 1, 30, 110, 1, function(value)
            widget.glow[3] = value
            widget.func(widget.glow)
        end)
        widget.glowParticles:SetPoint("TOPLEFT", widget.glowType, "BOTTOMLEFT", 0, -25)

        -- glowDuration
        widget.glowDuration = Cell.CreateSlider(L["Duration"], widget, 0.1, 3, 110, 0.1, function(value)
            widget.glow[3] = value
            widget.func(widget.glow)
        end)
        widget.glowDuration:SetPoint("TOPLEFT", widget.glowType, "BOTTOMLEFT", 0, -25)

        -- glowFrequency
        widget.glowFrequency = Cell.CreateSlider(L["Frequency"], widget, -2, 2, 110, 0.01, function(value)
            widget.glow[4] = value
            widget.func(widget.glow)
        end)
        widget.glowFrequency:SetPoint("TOPLEFT", widget.glowLines, "TOPRIGHT", 25, 0)

        -- glowLength
        widget.glowLength = Cell.CreateSlider(L["Length"], widget, 1, 50, 110, 1, function(value)
            widget.glow[5] = value
            widget.func(widget.glow)
        end)
        widget.glowLength:SetPoint("TOPLEFT", widget.glowLines, "BOTTOMLEFT", 0, -40)

        -- glowThickness
        widget.glowThickness = Cell.CreateSlider(L["Thickness"], widget, 1, 20, 110, 1, function(value)
            widget.glow[6] = value
            widget.func(widget.glow)
        end)
        widget.glowThickness:SetPoint("TOPLEFT", widget.glowLength, "TOPRIGHT", 25, 0)

        -- glowScale
        widget.glowScale = Cell.CreateSlider(L["Scale"], widget, 50, 500, 110, 1, function(value)
            widget.glow[5] = value/100
            widget.func(widget.glow)
        end, nil, true)
        widget.glowScale:SetPoint("TOPLEFT", widget.glowLines, "BOTTOMLEFT", 0, -40)

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(t, hideNone)
            widget.useSmallerSize = not hideNone -- TODO: may require addtional arg
            widget.glowType.items[1].disabled = hideNone
            widget.glowType.items[5].disabled = not Cell.isRetail

            -- {"Pixel", {0.95,0.95,0.32,1}, 9, 0.25, 8, 2},
            widget.glow = t
            widget.glowType:SetSelectedValue(t[1])
            widget.glowColor:SetColor(t[2])

            if t[1] == "None" or t[1] == "Normal" then
                if t[1] == "None" then
                    widget.glowColor:Hide()
                end
                widget.glowLines:Hide()
                widget.glowParticles:Hide()
                widget.glowDuration:Hide()
                widget.glowFrequency:Hide()
                widget.glowLength:Hide()
                widget.glowThickness:Hide()
                widget.glowScale:Hide()
                widget:SetHeight(50)
            else
                widget.glowColor:Show()
                if t[1] == "Pixel" then
                    widget.glowLines:Show()
                    widget.glowLines:SetValue(t[3])
                    widget.glowFrequency:Show()
                    widget.glowFrequency:SetValue(t[4])
                    widget.glowLength:Show()
                    widget.glowLength:SetValue(t[5])
                    widget.glowThickness:Show()
                    widget.glowThickness:SetValue(t[6])

                    widget.glowParticles:Hide()
                    widget.glowDuration:Hide()
                    widget.glowScale:Hide()
                    widget:SetHeight(145)

                elseif t[1] == "Shine" then
                    widget.glowParticles:Show()
                    widget.glowParticles:SetValue(t[3])
                    widget.glowFrequency:Show()
                    widget.glowFrequency:SetValue(t[4])
                    widget.glowScale:Show()
                    widget.glowScale:SetValue(t[5]*100)

                    widget.glowLines:Hide()
                    widget.glowDuration:Hide()
                    widget.glowLength:Hide()
                    widget.glowThickness:Hide()
                    widget:SetHeight(145)

                elseif t[1] == "Proc" then
                    widget.glowDuration:Show()
                    widget.glowDuration:SetValue(t[3])

                    widget.glowLines:Hide()
                    widget.glowParticles:Hide()
                    widget.glowFrequency:Hide()
                    widget.glowLength:Hide()
                    widget.glowScale:Hide()
                    widget.glowThickness:Hide()
                    widget:SetHeight(95)
                end
            end
        end
    else
        widget = settingWidgets["glow"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_Texture(parent)
    local widget

    if not settingWidgets["texture"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_Texture", parent, 240, 100)
        settingWidgets["texture"] = widget

        widget.pathBox = Cell.CreateFrame(nil, widget, 216, 20)
        Cell.StylizeFrame(widget.pathBox, {0.115, 0.115, 0.115, 1}, {0, 0, 0, 1})
        widget.pathBox:SetPoint("TOPLEFT", 5, -20)
        widget.pathBox:Show()

        widget.path = widget.pathBox:CreateFontString(nil, "OVERLAY", font_name)
        widget.path:SetPoint("LEFT", 5, 0)
        widget.path:SetPoint("RIGHT", -5, 0)
        widget.path:SetJustifyH("LEFT")
        widget.path:SetWordWrap(false)

        widget.button = Cell.CreateButton(widget, "...", "accent", {30, 20})
        widget.button:SetPoint("TOPLEFT", widget.pathBox, "TOPRIGHT", P.Scale(-1), 0)
        widget.button:SetScript("OnClick", function()
            F.ShowTextureSelector(widget.selected, function(path)
                widget.selected = path
                F.FitWidth(widget.path, path, "right")
                widget.func({path, widget.rotation:GetValue(), widget.colorPicker:GetColor()})
            end)
        end)

        widget.pathText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.pathText:SetText(L["Texture"])
        widget.pathText:SetPoint("BOTTOMLEFT", widget.pathBox, "TOPLEFT", 0, 1)

        widget.rotation = Cell.CreateSlider(L["Rotation"], widget, -180, 180, 110, 1)
        widget.rotation:SetPoint("TOPLEFT", widget.pathBox, "BOTTOMLEFT", 0, -25)
        widget.rotation.afterValueChangedFn = function(value)
            widget.func({widget.selected, value, widget.colorPicker:GetColor()})
        end

        widget.colorPicker = Cell.CreateColorPicker(widget, L["Color"], true, function(r, g, b, a)
            widget.func({widget.selected, widget.rotation:GetValue(), {r, g, b, a}})
        end)
        widget.colorPicker:SetPoint("TOPLEFT", widget.rotation, "TOPRIGHT", 25, 0)

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(t)
            widget.selected = t[1]
            F.FitWidth(widget.path, t[1], "right")
            widget.rotation:SetValue(t[2])
            widget.colorPicker:SetColor(t[3])
        end
    else
        widget = settingWidgets["texture"]
    end

    widget:Show()
    return widget
end

local function CreateAuraButtons(parent, auraButtons, auraTable, noUpDownButtons, isZeroValid, hasColorPicker, updateHeightFunc)
    local n = #auraTable

    -- tooltip
    if not parent.popupEditBox then
        local popup = Cell.CreatePopupEditBox(parent)
        popup:SetNumeric(true)

        popup:SetScript("OnTextChanged", function()
            local spellId = tonumber(popup:GetText())
            if not spellId then
                CellSpellTooltip:Hide()
                return
            end

            local name, tex = F.GetSpellInfo(spellId)
            if not name then
                CellSpellTooltip:Hide()
                return
            end

            CellSpellTooltip:SetOwner(popup, "ANCHOR_NONE")
            CellSpellTooltip:SetPoint("TOPLEFT", popup, "BOTTOMLEFT", 0, -1)
            CellSpellTooltip:SetSpellByID(spellId, tex)
            CellSpellTooltip:Show()
        end)

        popup:HookScript("OnHide", function()
            CellSpellTooltip:Hide()
        end)
    end

    -- new
    if not auraButtons[0] then
        auraButtons[0] = Cell.CreateButton(parent, "", "transparent-accent", {20, 20})
        auraButtons[0]:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\new", {16, 16}, {"RIGHT", -1, 0})
        auraButtons[0]:SetPoint("BOTTOMLEFT")
        auraButtons[0]:SetPoint("RIGHT")
    end

    auraButtons[0]:SetScript("OnClick", function(self)
        local popup = Cell.CreatePopupEditBox(parent, function(text)
            local spellId = tonumber(text)
            local spellName = F.GetSpellInfo(spellId)
            if (spellId and spellName) or (spellId == 0 and isZeroValid) then
                -- update db
                if hasColorPicker then
                    tinsert(auraTable, {spellId, {1, 0.26667, 0.4, 1}})
                else
                    tinsert(auraTable, spellId)
                end
                parent.func(auraTable)
                CreateAuraButtons(parent, auraButtons, auraTable, noUpDownButtons, isZeroValid, hasColorPicker, updateHeightFunc)
                updateHeightFunc(#auraTable, 19)
            else
                F.Print(L["Invalid spell id."])
            end
        end)
        popup:SetPoint("TOPLEFT", self)
        popup:SetPoint("BOTTOMRIGHT", self)
        popup:ShowEditBox("")
        if isZeroValid then
            parent.popupEditBox:SetTips("|cffababab"..L["Input spell id"]..", 0 = "..L["all"])
        else
            parent.popupEditBox:SetTips("|cffababab"..L["Input spell id"])
        end
    end)


    for i, spell in ipairs(auraTable) do
        -- creation
        if not auraButtons[i] then
            auraButtons[i] = Cell.CreateButton(parent, "", "transparent-accent", {20, 20})

            -- spellIcon
            auraButtons[i].spellIconBg = auraButtons[i]:CreateTexture(nil, "BORDER")
            auraButtons[i].spellIconBg:SetSize(16, 16)
            auraButtons[i].spellIconBg:SetPoint("TOPLEFT", 2, -2)
            auraButtons[i].spellIconBg:SetColorTexture(0, 0, 0, 1)
            auraButtons[i].spellIconBg:Hide()

            auraButtons[i].spellIcon = auraButtons[i]:CreateTexture(nil, "OVERLAY")
            auraButtons[i].spellIcon:SetPoint("TOPLEFT", auraButtons[i].spellIconBg, 1, -1)
            auraButtons[i].spellIcon:SetPoint("BOTTOMRIGHT", auraButtons[i].spellIconBg, -1, 1)
            auraButtons[i].spellIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            auraButtons[i].spellIcon:Hide()

            -- spellId text
            auraButtons[i].spellIdText = auraButtons[i]:CreateFontString(nil, "OVERLAY", font_name)
            auraButtons[i].spellIdText:SetPoint("LEFT", auraButtons[i].spellIconBg, "RIGHT", 5, 0)
            auraButtons[i].spellIdText:SetPoint("RIGHT", auraButtons[i], "LEFT", 80, 0)
            auraButtons[i].spellIdText:SetWordWrap(false)
            auraButtons[i].spellIdText:SetJustifyH("LEFT")

            -- spellName text
            auraButtons[i].spellNameText = auraButtons[i]:CreateFontString(nil, "OVERLAY", font_name)
            auraButtons[i].spellNameText:SetPoint("LEFT", auraButtons[i].spellIdText, "RIGHT", 5, 0)
            auraButtons[i].spellNameText:SetPoint("RIGHT", -70, 0)
            auraButtons[i].spellNameText:SetWordWrap(false)
            auraButtons[i].spellNameText:SetJustifyH("LEFT")

            -- del
            auraButtons[i].del = Cell.CreateButton(auraButtons[i], "", "none", {18, 20}, true, true)
            auraButtons[i].del:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\delete", {16, 16}, {"CENTER", 0, 0})
            auraButtons[i].del:SetPoint("RIGHT")
            auraButtons[i].del.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
            auraButtons[i].del:SetScript("OnEnter", function()
                auraButtons[i]:GetScript("OnEnter")(auraButtons[i])
                auraButtons[i].del.tex:SetVertexColor(1, 1, 1, 1)
            end)
            auraButtons[i].del:SetScript("OnLeave",  function()
                auraButtons[i]:GetScript("OnLeave")(auraButtons[i])
                auraButtons[i].del.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
            end)

            -- edit
            -- auraButtons[i].edit = Cell.CreateButton(auraButtons[i], "", "none", {18, 20}, true, true)
            -- auraButtons[i].edit:SetPoint("RIGHT", auraButtons[i].del, "LEFT", 1, 0)
            -- auraButtons[i].edit:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\info", {16, 16}, {"CENTER", 0, 0})
            -- auraButtons[i].edit.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
            -- auraButtons[i].edit:SetScript("OnEnter", function()
            --     auraButtons[i]:GetScript("OnEnter")(auraButtons[i])
            --     auraButtons[i].edit.tex:SetVertexColor(1, 1, 1, 1)
            -- end)
            -- auraButtons[i].edit:SetScript("OnLeave",  function()
            --     auraButtons[i]:GetScript("OnLeave")(auraButtons[i])
            --     auraButtons[i].edit.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
            -- end)

            -- down
            auraButtons[i].down = Cell.CreateButton(auraButtons[i], "", "none", {18, 20}, true, true)
            auraButtons[i].down:SetPoint("RIGHT", auraButtons[i].del, "LEFT", 1, 0)
            auraButtons[i].down:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\down", {16, 16}, {"CENTER", 0, 0})
            auraButtons[i].down.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
            auraButtons[i].down:SetScript("OnEnter", function()
                auraButtons[i]:GetScript("OnEnter")(auraButtons[i])
                auraButtons[i].down.tex:SetVertexColor(1, 1, 1, 1)
            end)
            auraButtons[i].down:SetScript("OnLeave",  function()
                auraButtons[i]:GetScript("OnLeave")(auraButtons[i])
                auraButtons[i].down.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
            end)

            -- up
            auraButtons[i].up = Cell.CreateButton(auraButtons[i], "", "none", {18, 20}, true, true)
            auraButtons[i].up:SetPoint("RIGHT", auraButtons[i].down, "LEFT", 1, 0)
            auraButtons[i].up:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\up", {16, 16}, {"CENTER", 0, 0})
            auraButtons[i].up.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
            auraButtons[i].up:SetScript("OnEnter", function()
                auraButtons[i]:GetScript("OnEnter")(auraButtons[i])
                auraButtons[i].up.tex:SetVertexColor(1, 1, 1, 1)
            end)
            auraButtons[i].up:SetScript("OnLeave",  function()
                auraButtons[i]:GetScript("OnLeave")(auraButtons[i])
                auraButtons[i].up.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
            end)

            -- color
            auraButtons[i].colorPicker = Cell.CreateColorPicker(auraButtons[i], "", true)
            auraButtons[i].colorPicker:SetPoint("RIGHT", auraButtons[i].up, "LEFT", -1, 0)
            auraButtons[i].colorPicker:SetPoint("TOP", 0, -3)
            auraButtons[i].colorPicker:HookScript("OnEnter", function()
                auraButtons[i]:GetScript("OnEnter")(auraButtons[i])
            end)
            auraButtons[i].colorPicker:HookScript("OnLeave", function()
                auraButtons[i]:GetScript("OnLeave")(auraButtons[i])
            end)

            -- spell tooltip
            auraButtons[i]:HookScript("OnEnter", function(self)
                if parent.popupEditBox:IsShown() then return end

                local name = F.GetSpellInfo(self.spellId)
                if not name then
                    CellSpellTooltip:Hide()
                    return
                end

                CellSpellTooltip:SetOwner(auraButtons[i], "ANCHOR_NONE")
                CellSpellTooltip:SetPoint("TOPRIGHT", auraButtons[i], "TOPLEFT", -1, 0)
                CellSpellTooltip:SetSpellByID(self.spellId, self.spellTex)
                CellSpellTooltip:Show()
            end)
            auraButtons[i]:HookScript("OnLeave", function()
                if not parent.popupEditBox:IsShown() then
                    CellSpellTooltip:Hide()
                end
            end)
        end

        local color
        if hasColorPicker then
            color = spell[2]
            spell = spell[1]
        end

        if spell == 0 then
            auraButtons[i].spellIdText:SetText(spell)
            auraButtons[i].spellId = nil
            auraButtons[i].spellNameText:SetText("|cff22ff22"..L["all"])
            auraButtons[i].spellIconBg:Hide()
            auraButtons[i].spellIcon:Hide()
        else
            local name, icon = F.GetSpellInfo(spell)
            auraButtons[i].spellIdText:SetText(spell)
            auraButtons[i].spellId = spell
            auraButtons[i].spellTex = icon
            auraButtons[i].spellNameText:SetText(name or "|cffff2222"..L["Invalid"])
            if icon then
                auraButtons[i].spellIcon:SetTexture(icon)
                auraButtons[i].spellIconBg:Show()
                auraButtons[i].spellIcon:Show()
            else
                auraButtons[i].spellIconBg:Hide()
                auraButtons[i].spellIcon:Hide()
            end
        end

        -- points
        auraButtons[i]:ClearAllPoints()
        if i == 1 then -- first
            auraButtons[i]:SetPoint("TOPLEFT")
            -- update buttons
            if noUpDownButtons then
                auraButtons[i].up:Hide()
                auraButtons[i].down:Hide()
            else
                auraButtons[i].up:Hide()
                auraButtons[i].down:Show()
            end
        elseif i == n then -- last
            auraButtons[i]:SetPoint("TOPLEFT", auraButtons[i-1], "BOTTOMLEFT", 0, P.Scale(1))
            -- update buttons
            if noUpDownButtons then
                auraButtons[i].up:Hide()
                auraButtons[i].down:Hide()
            else
                auraButtons[i].up:Show()
                auraButtons[i].down:Hide()
            end
        else
            auraButtons[i]:SetPoint("TOPLEFT", auraButtons[i-1], "BOTTOMLEFT", 0, P.Scale(1))
            -- update buttons
            if noUpDownButtons then
                auraButtons[i].down:Hide()
                auraButtons[i].up:Hide()
            else
                auraButtons[i].down:Show()
                auraButtons[i].up:Show()
            end
        end

        -- update spellNameText width
        if noUpDownButtons then
            auraButtons[i].spellNameText:SetPoint("RIGHT", auraButtons[i].del, "LEFT", -5, 0)
        elseif hasColorPicker then
            auraButtons[i].spellNameText:SetPoint("RIGHT", auraButtons[i].colorPicker, "LEFT", -5, 0)
        else
            auraButtons[i].spellNameText:SetPoint("RIGHT", auraButtons[i].up, "LEFT", -5, 0)
        end

        auraButtons[i]:SetPoint("RIGHT")
        auraButtons[i]:Show()

        -- functions
        auraButtons[i]:SetScript("OnClick", function()
            local popup = Cell.CreatePopupEditBox(parent, function(text)
                local spellId = tonumber(text)
                if spellId == 0 then
                    if isZeroValid then
                        auraButtons[i].spellIdText:SetText("0")
                        auraButtons[i].spellId = nil
                        auraButtons[i].spellNameText:SetText("|cff22ff22"..L["all"])
                        auraButtons[i].spellIconBg:Hide()
                        auraButtons[i].spellIcon:Hide()
                    else
                        F.Print(L["Invalid spell id."])
                    end
                else
                    local spellName, spellIcon = F.GetSpellInfo(spellId)
                    if spellId and spellName then
                        -- update text
                        auraButtons[i].spellIdText:SetText(spellId)
                        auraButtons[i].spellId = spellId
                        auraButtons[i].spellTex = spellIcon
                        auraButtons[i].spellNameText:SetText(spellName)
                        -- update db
                        if hasColorPicker then
                            auraTable[i][1] = spellId
                        else
                            auraTable[i] = spellId
                        end
                        parent.func(auraTable)
                        if spellIcon then
                            auraButtons[i].spellIcon:SetTexture(spellIcon)
                            auraButtons[i].spellIconBg:Show()
                            auraButtons[i].spellIcon:Show()
                        else
                            auraButtons[i].spellIconBg:Hide()
                            auraButtons[i].spellIcon:Hide()
                        end
                    else
                        F.Print(L["Invalid spell id."])
                    end
                end

            end)
            popup:SetPoint("TOPLEFT", auraButtons[i])
            popup:SetPoint("BOTTOMRIGHT", auraButtons[i])
            popup:ShowEditBox(auraButtons[i].spellId or "")
            parent.popupEditBox:SetTips("|cffababab"..L["Input spell id"])
        end)

        auraButtons[i].del:SetScript("OnClick", function()
            tremove(auraTable, i)
            parent.func(auraTable)
            CreateAuraButtons(parent, auraButtons, auraTable, noUpDownButtons, isZeroValid, hasColorPicker, updateHeightFunc)
            updateHeightFunc(#auraTable, -19)
        end)

        auraButtons[i].up:SetScript("OnClick", function()
            local temp = auraTable[i-1]
            auraTable[i-1] = auraTable[i]
            auraTable[i] = temp
            parent.func(auraTable)
            CreateAuraButtons(parent, auraButtons, auraTable, noUpDownButtons, isZeroValid, hasColorPicker, updateHeightFunc)
        end)

        auraButtons[i].down:SetScript("OnClick", function()
            local temp = auraTable[i+1]
            auraTable[i+1] = auraTable[i]
            auraTable[i] = temp
            parent.func(auraTable)
            CreateAuraButtons(parent, auraButtons, auraTable, noUpDownButtons, isZeroValid, hasColorPicker, updateHeightFunc)
        end)

        if hasColorPicker then
            auraButtons[i].colorPicker:Show()
            auraButtons[i].colorPicker:SetColor(color)
            auraButtons[i].colorPicker.onConfirm = function(r, g, b, a)
                auraTable[i][2][1] = r
                auraTable[i][2][2] = g
                auraTable[i][2][3] = b
                auraTable[i][2][4] = a
                parent.func(auraTable)
            end
        else
            auraButtons[i].colorPicker:Hide()
        end
    end

    -- check up down
    if n == 1 then
        auraButtons[1].up:Hide()
        auraButtons[1].down:Hide()
    end

    for i = n+1, #auraButtons do
        auraButtons[i]:Hide()
        auraButtons[i]:ClearAllPoints()
    end
end

local function GetExportString(t)
    local s = ""
    local n = 0
    for i, id in ipairs(t) do
        local color = ""
        if type(id) == "table" then
            color = " {"
            for j, c in pairs(id[2]) do
                color = color .. F.Round(c, 3)
                if j ~= 4 then
                    color = color .. ","
                end
            end
            color = color .. "}"
            id = id[1]
        end
        local name = F.GetSpellInfo(id)
        if name then
            s = s .. (i == 1 and "" or "\n") .. id .. ", -- " .. name .. color
            n = n + 1
        end
    end
    return s, n
end

local auraButtons = {}
local auraImportExportFrame

local function ConvertAuraData(text)
    if not text or text == "" then return end

    local data = {}

    if auraImportExportFrame.parent.hasColorPicker then
        for i, line in pairs({strsplit("\n", text)}) do
            line = strtrim(line)
            if line ~= "" then
                local id = strmatch(line, "^(%d+).*$")
                id = tonumber(id)
                if id then
                    local color = strmatch(line, "^%d+, %-%- .+ %{(.+)%}$")
                    if color then
                        color = F.StringToTable(color, ",", true)
                    else
                        color = {1, 0.26667, 0.4, 1}
                    end
                    tinsert(data, {id, color})
                end
            end
        end
    else
        for i, line in pairs({strsplit("\n", text)}) do
            line = strtrim(line)
            local id = strmatch(line, "^(%d+),.+$")
            id = tonumber(id)
            if id then
                tinsert(data, id)
            end
        end
    end

    return data
end

local function CreateSetting_Auras(parent, index)
    local widget

    if not auraImportExportFrame then
        auraImportExportFrame = Cell.CreateFrame(nil, parent, 1, 200)
        auraImportExportFrame:SetBackdropBorderColor(Cell.GetAccentColorRGB())
        auraImportExportFrame:EnableMouse(true)
        auraImportExportFrame:Hide()

        function auraImportExportFrame:ShowUp()
            auraImportExportFrame:SetParent(auraImportExportFrame.parent)
            auraImportExportFrame:SetPoint("TOPLEFT")
            auraImportExportFrame:SetPoint("TOPRIGHT")
            auraImportExportFrame:SetToplevel(true)
            auraImportExportFrame:Show()
        end

        auraImportExportFrame:SetScript("OnHide", function()
            auraImportExportFrame:Hide()
        end)

        auraImportExportFrame.textArea = Cell.CreateScrollEditBox(auraImportExportFrame, function(eb, userChanged)
            if userChanged then
                if auraImportExportFrame.isImport then
                    local data = ConvertAuraData(eb:GetText())
                    if data and #data ~= 0 then
                        auraImportExportFrame.data = data
                        auraImportExportFrame.info:SetText(Cell.GetAccentColorString()..L["Spells"]..":|r "..#data)
                        auraImportExportFrame.importBtn:SetEnabled(true)
                    else
                        auraImportExportFrame.info:SetText(Cell.GetAccentColorString()..L["Spells"]..":|r 0")
                        auraImportExportFrame.importBtn:SetEnabled(false)
                    end
                else
                    eb:SetText(auraImportExportFrame.exported)
                    eb:SetCursorPosition(0)
                    eb:HighlightText()
                end
            end
        end)
        Cell.StylizeFrame(auraImportExportFrame.textArea.scrollFrame, {0, 0, 0, 0}, Cell.GetAccentColorTable())
        auraImportExportFrame.textArea:SetPoint("TOPLEFT", 5, -22)
        auraImportExportFrame.textArea:SetPoint("BOTTOMRIGHT", -5, 5)
        auraImportExportFrame.textArea.eb:SetAutoFocus(true)

        auraImportExportFrame.textArea.eb:SetScript("OnEditFocusGained", function() auraImportExportFrame.textArea.eb:HighlightText() end)
        auraImportExportFrame.textArea.eb:SetScript("OnMouseUp", function()
            if not auraImportExportFrame.isImport then
                auraImportExportFrame.textArea.eb:HighlightText()
            end
        end)

        auraImportExportFrame.info = auraImportExportFrame:CreateFontString(nil, "OVERLAY", font_name)
        auraImportExportFrame.info:SetPoint("BOTTOMLEFT", auraImportExportFrame.textArea, "TOPLEFT", 0, 3)

        auraImportExportFrame.closeBtn = Cell.CreateButton(auraImportExportFrame, "×", "red", {18, 18}, false, false, "CELL_FONT_SPECIAL", "CELL_FONT_SPECIAL")
        auraImportExportFrame.closeBtn:SetPoint("BOTTOMRIGHT", auraImportExportFrame.textArea, "TOPRIGHT", 0, 1)
        auraImportExportFrame.closeBtn:SetScript("OnClick", function() auraImportExportFrame:Hide() end)

        auraImportExportFrame.importBtn = Cell.CreateButton(auraImportExportFrame, L["Import"], "green", {57, 18})
        auraImportExportFrame.importBtn:SetPoint("TOPRIGHT", auraImportExportFrame.closeBtn, "TOPLEFT", P.Scale(1), 0)
        auraImportExportFrame.importBtn:SetScript("OnClick", function()
            -- replace old
            wipe(auraImportExportFrame.parent.t)
            for _, data in pairs(auraImportExportFrame.data) do
                tinsert(auraImportExportFrame.parent.t, data)
            end
            -- update list
            auraImportExportFrame.parent:SetDBValue(auraImportExportFrame.parent.title,
                auraImportExportFrame.parent.t,
                auraImportExportFrame.parent.noUpDownButtons,
                auraImportExportFrame.parent.isZeroValid,
                auraImportExportFrame.parent.hasColorPicker
            )
            auraImportExportFrame:Hide()
            -- update height
            Cell.UpdateIndicatorSettingsHeight()
            -- event
            auraImportExportFrame.parent.frame.func(auraImportExportFrame.parent.t)
        end)
    end

    if not settingWidgets["auras"..index] then
        widget = Cell.CreateFrame("CellIndicatorSettings_Auras"..index, parent, 240, 128)
        settingWidgets["auras"..index] = widget

        widget.frame = Cell.CreateFrame(nil, widget, 20, 20)
        widget.frame:SetPoint("TOPLEFT", 5, -22)
        widget.frame:SetPoint("RIGHT", -5, 0)
        widget.frame:Show()
        Cell.StylizeFrame(widget.frame, {0.15, 0.15, 0.15, 1})

        widget.text = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.text:SetPoint("BOTTOMLEFT", widget.frame, "TOPLEFT", 0, 3)

        widget.export = Cell.CreateButton(widget, nil, "accent-hover", {21, 17}, nil, nil, nil, nil, nil, L["Export"])
        widget.export:SetPoint("BOTTOMRIGHT", widget.frame, "TOPRIGHT", 0, 1)
        widget.export:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\export", {15, 15}, {"CENTER", 0, 0})
        widget.export:SetScript("OnClick", function()
            auraImportExportFrame.isImport = false
            auraImportExportFrame.parent = widget
            local n
            auraImportExportFrame.exported, n = GetExportString(widget.t)
            auraImportExportFrame.info:SetText(Cell.GetAccentColorString()..L["Spells"]..":|r "..n)
            auraImportExportFrame.textArea:SetText(auraImportExportFrame.exported)
            auraImportExportFrame.importBtn:Hide()
            auraImportExportFrame:ShowUp()
            -- hide editbox
            if widget.frame.popupEditBox then
                widget.frame.popupEditBox:Hide()
            end
        end)

        widget.import = Cell.CreateButton(widget, nil, "accent-hover", {21, 17}, nil, nil, nil, nil, nil, L["Import"])
        widget.import:SetPoint("BOTTOMRIGHT", widget.export, "BOTTOMLEFT", -1, 0)
        widget.import:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\import", {15, 15}, {"CENTER", 0, 0})
        widget.import:SetScript("OnClick", function()
            auraImportExportFrame.isImport = true
            auraImportExportFrame.parent = widget
            auraImportExportFrame.textArea:SetText("")
            auraImportExportFrame.info:SetText(Cell.GetAccentColorString()..L["Spells"]..":|r 0")
            auraImportExportFrame.importBtn:Show()
            auraImportExportFrame.importBtn:SetEnabled(false)
            auraImportExportFrame:ShowUp()
            -- hide editbox
            if widget.frame.popupEditBox then
                widget.frame.popupEditBox:Hide()
            end
        end)

        widget.clear = Cell.CreateButton(widget, nil, "accent-hover", {21, 17}, nil, nil, nil, nil, nil, L["Clear"], "|cffffb5c5Ctrl+"..L["Left-Click"])
        widget.clear:SetPoint("BOTTOMRIGHT", widget.import, "BOTTOMLEFT", -1, 0)
        widget.clear:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\trash", {15, 15}, {"CENTER", 0, 0})
        widget.clear:SetScript("OnClick", function(self, button)
            if button == "LeftButton" and IsControlKeyDown() then
                wipe(widget.t)
                -- update list
                widget:SetDBValue(widget.title, widget.t, widget.noUpDownButtons, widget.isZeroValid, widget.hasColorPicker)
                -- update height
                Cell.UpdateIndicatorSettingsHeight()
                -- event
                widget.frame.func(widget.t)
                -- hide editbox
                if widget.frame.popupEditBox then
                    widget.frame.popupEditBox:Hide()
                end
            end
        end)

        -- callback
        function widget:SetFunc(func)
            widget.frame.func = func
        end

        -- show db value
        function widget:SetDBValue(title, t, noUpDownButtons, isZeroValid, hasColorPicker)
            widget.title = title
            widget.t = t
            widget.noUpDownButtons = noUpDownButtons
            widget.isZeroValid = isZeroValid
            widget.hasColorPicker = hasColorPicker

            widget.text:SetText(title)

            if not auraButtons[index] then auraButtons[index] = {} end

<<<<<<< HEAD
            CreateAuraButtons(widget.frame, auraButtons[index], t, noUpDownButtons, isZeroValid, hasColorPicker, function(diff)
                local height = (#t + 1) * P.Scale(19) + P.Scale(1)
=======
            CreateAuraButtons(widget.frame, auraButtons[index], t, noUpDownButtons, isZeroValid, hasColorPicker, function(n, diff)
                local height = (n + 1) * P.Scale(20) - n * P.Scale(1)
>>>>>>> 4d63b4f4242382c8194c9b54493bac32fc2cf8fb
                widget.frame:SetHeight(height)
                widget:SetHeight(height + P.Scale(22) + P.Scale(7))
                if diff then parent:SetHeight(parent:GetHeight() + P.Scale(diff)) end
            end)

<<<<<<< HEAD
            local height = (#t + 1) * P.Scale(19) + P.Scale(1)
=======
            local height = (#t + 1) * P.Scale(20) - #t * P.Scale(1)
>>>>>>> 4d63b4f4242382c8194c9b54493bac32fc2cf8fb
            widget.frame:SetHeight(height)
            widget:SetHeight(height + P.Scale(22) + P.Scale(7))
        end
    else
        widget = settingWidgets["auras"..index]
    end

    widget:Show()
    return widget
end

--[=[
local cleuAuraButtons = {}
local function CreateCleuAuraButtons(parent, auraTable, updateHeightFunc)
    local n = #auraTable

    -- tooltip
    if not parent.inputs then
        local inputs = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        Cell.StylizeFrame(inputs, {0.115, 0.115, 0.115, 1})
        inputs:SetFrameStrata("DIALOG")
        inputs:Hide()
        inputs:SetScript("OnHide", function()
            inputs:Hide()
            inputs.spellEB.isValid = false
            inputs.durationEB.isValid = false
            inputs.spellEB:SetText("")
            inputs.durationEB:SetText("")
            inputs.okBtn:SetEnabled(false)
            CellSpellTooltip:Hide()
        end)

        local function Validate()
            inputs.okBtn:SetEnabled(inputs.spellEB.isValid and inputs.durationEB.isValid)
        end

        local spellEB = Cell.CreateEditBox(inputs, 20, 20, false, false, true)
        spellEB:SetAutoFocus(true)
        spellEB.tip = spellEB:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
        spellEB.tip:SetTextColor(0.4, 0.4, 0.4, 1)
        spellEB.tip:SetText("ID")
        spellEB.tip:SetPoint("RIGHT", -5, 0)
        spellEB:SetScript("OnTextChanged", function()
            spellEB.isValid = false
            local spellId = tonumber(spellEB:GetText())
            if not spellId then
                CellSpellTooltip:Hide()
                Validate()
                return
            end

            local name = F.GetSpellInfo(spellId)
            if not name then
                CellSpellTooltip:Hide()
                Validate()
                return
            end

            CellSpellTooltip:SetOwner(spellEB, "ANCHOR_NONE")
            CellSpellTooltip:SetPoint("TOPLEFT", spellEB, "BOTTOMLEFT", 0, -1)
            CellSpellTooltip:SetSpellByID(spellId)
            CellSpellTooltip:Show()
            spellEB.isValid = true
            Validate()
        end)
        spellEB:HookScript("OnHide", function()
            CellSpellTooltip:Hide()
        end)
        spellEB:SetScript("OnEscapePressed", function()
            inputs:Hide()
        end)

        local durationEB = Cell.CreateEditBox(inputs, 20, 20, false, false, true)
        durationEB:SetAutoFocus(true)
        durationEB:SetMaxLetters(2)
        durationEB.tip = durationEB:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
        durationEB.tip:SetTextColor(0.4, 0.4, 0.4, 1)
        durationEB.tip:SetText(_G.AUCTION_DURATION)
        durationEB.tip:SetPoint("RIGHT", -5, 0)
        durationEB:SetScript("OnTextChanged", function()
            durationEB.isValid = false
            local duration = tonumber(durationEB:GetText())
            if not duration or duration == 0 then
                Validate()
                return
            end
            durationEB.isValid = true
            Validate()
        end)
        durationEB:SetScript("OnEscapePressed", function()
            inputs:Hide()
        end)

        spellEB:SetScript("OnTabPressed", function()
            durationEB:SetFocus(true)
        end)
        durationEB:SetScript("OnTabPressed", function()
            spellEB:SetFocus(true)
        end)

        local okBtn = Cell.CreateButton(inputs, "OK", "green", {40, 20})
        okBtn:SetEnabled(false)

        spellEB:SetPoint("TOPLEFT")
        spellEB:SetPoint("BOTTOMRIGHT", inputs, "BOTTOMLEFT", 120, 0)
        okBtn:SetPoint("BOTTOMRIGHT")
        okBtn:SetPoint("TOPLEFT", inputs, "TOPRIGHT", -30, 0)
        durationEB:SetPoint("TOPLEFT", spellEB, "TOPRIGHT", -1, 0)
        durationEB:SetPoint("BOTTOMRIGHT", okBtn, "BOTTOMLEFT", 1, 0)

        parent.inputs = inputs
        inputs.spellEB = spellEB
        inputs.durationEB = durationEB
        inputs.okBtn = okBtn
    end

    -- new
    if not cleuAuraButtons[0] then
        cleuAuraButtons[0] = Cell.CreateButton(parent, "", "transparent-accent", {20, 20})
        cleuAuraButtons[0]:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\new", {16, 16}, {"RIGHT", -1, 0})
        cleuAuraButtons[0]:SetPoint("BOTTOMLEFT")
        cleuAuraButtons[0]:SetPoint("RIGHT")
    end

    cleuAuraButtons[0]:SetScript("OnClick", function(self)
        parent.inputs:SetPoint("TOPLEFT", self)
        parent.inputs:SetPoint("BOTTOMRIGHT", self)
        parent.inputs:Show()
        parent.inputs.spellEB:SetText("")
        parent.inputs.durationEB:SetText("")
        parent.inputs.okBtn:SetEnabled(false)
        parent.inputs.okBtn:SetScript("OnClick", function()
            local spellId = tonumber(parent.inputs.spellEB:GetText())
            local duration = tonumber(parent.inputs.durationEB:GetText())
            -- update db
            tinsert(auraTable, {spellId, duration})
            parent.func(auraTable)
            CreateCleuAuraButtons(parent, auraTable, updateHeightFunc)
            updateHeightFunc(19)
            parent.inputs:Hide()
        end)
    end)

    for i, t in ipairs(auraTable) do
        -- creation
        if not cleuAuraButtons[i] then
            cleuAuraButtons[i] = Cell.CreateButton(parent, "", "transparent-accent", {20, 20})

            -- spellIcon
            cleuAuraButtons[i].spellIconBg = cleuAuraButtons[i]:CreateTexture(nil, "BORDER")
            cleuAuraButtons[i].spellIconBg:SetSize(16, 16)
            cleuAuraButtons[i].spellIconBg:SetPoint("TOPLEFT", 2, -2)
            cleuAuraButtons[i].spellIconBg:SetColorTexture(0, 0, 0, 1)
            cleuAuraButtons[i].spellIconBg:Hide()

            cleuAuraButtons[i].spellIcon = cleuAuraButtons[i]:CreateTexture(nil, "OVERLAY")
            cleuAuraButtons[i].spellIcon:SetPoint("TOPLEFT", cleuAuraButtons[i].spellIconBg, 1, -1)
            cleuAuraButtons[i].spellIcon:SetPoint("BOTTOMRIGHT", cleuAuraButtons[i].spellIconBg, -1, 1)
            cleuAuraButtons[i].spellIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            cleuAuraButtons[i].spellIcon:Hide()

            -- spellId text
            cleuAuraButtons[i].spellIdText = cleuAuraButtons[i]:CreateFontString(nil, "OVERLAY", font_name)
            cleuAuraButtons[i].spellIdText:SetPoint("LEFT", cleuAuraButtons[i].spellIconBg, "RIGHT", 5, 0)
            cleuAuraButtons[i].spellIdText:SetPoint("RIGHT", cleuAuraButtons[i], "LEFT", 80, 0)
            cleuAuraButtons[i].spellIdText:SetWordWrap(false)
            cleuAuraButtons[i].spellIdText:SetJustifyH("LEFT")

            -- spellName text
            cleuAuraButtons[i].spellNameText = cleuAuraButtons[i]:CreateFontString(nil, "OVERLAY", font_name)
            cleuAuraButtons[i].spellNameText:SetPoint("LEFT", cleuAuraButtons[i].spellIdText, "RIGHT", 5, 0)
            cleuAuraButtons[i].spellNameText:SetPoint("RIGHT", -70, 0)
            cleuAuraButtons[i].spellNameText:SetWordWrap(false)
            cleuAuraButtons[i].spellNameText:SetJustifyH("LEFT")

            -- duration text
            cleuAuraButtons[i].durationText = cleuAuraButtons[i]:CreateFontString(nil, "OVERLAY", font_name)
            cleuAuraButtons[i].durationText:SetPoint("LEFT", cleuAuraButtons[i].spellNameText, "RIGHT", 5, 0)
            cleuAuraButtons[i].durationText:SetPoint("RIGHT", -40, 0)
            cleuAuraButtons[i].durationText:SetWordWrap(false)
            cleuAuraButtons[i].durationText:SetJustifyH("LEFT")

            -- del
            cleuAuraButtons[i].del = Cell.CreateButton(cleuAuraButtons[i], "", "none", {18, 20}, true, true)
            cleuAuraButtons[i].del:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\delete", {16, 16}, {"CENTER", 0, 0})
            cleuAuraButtons[i].del:SetPoint("RIGHT")
            cleuAuraButtons[i].del.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
            cleuAuraButtons[i].del:SetScript("OnEnter", function()
                cleuAuraButtons[i]:GetScript("OnEnter")(cleuAuraButtons[i])
                cleuAuraButtons[i].del.tex:SetVertexColor(1, 1, 1, 1)
            end)
            cleuAuraButtons[i].del:SetScript("OnLeave",  function()
                cleuAuraButtons[i]:GetScript("OnLeave")(cleuAuraButtons[i])
                cleuAuraButtons[i].del.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
            end)

            -- edit
            cleuAuraButtons[i].edit = Cell.CreateButton(cleuAuraButtons[i], "", "none", {18, 20}, true, true)
            cleuAuraButtons[i].edit:SetPoint("RIGHT", cleuAuraButtons[i].del, "LEFT", 1, 0)
            cleuAuraButtons[i].edit:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\info", {16, 16}, {"CENTER", 0, 0})
            cleuAuraButtons[i].edit.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
            cleuAuraButtons[i].edit:SetScript("OnEnter", function()
                cleuAuraButtons[i]:GetScript("OnEnter")(cleuAuraButtons[i])
                cleuAuraButtons[i].edit.tex:SetVertexColor(1, 1, 1, 1)
            end)
            cleuAuraButtons[i].edit:SetScript("OnLeave",  function()
                cleuAuraButtons[i]:GetScript("OnLeave")(cleuAuraButtons[i])
                cleuAuraButtons[i].edit.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
            end)

            -- spell tooltip
            cleuAuraButtons[i]:HookScript("OnEnter", function(self)
                if parent.inputs:IsShown() then return end

                local name = F.GetSpellInfo(self.spellId)
                if not name then
                    CellSpellTooltip:Hide()
                    return
                end

                CellSpellTooltip:SetOwner(cleuAuraButtons[i], "ANCHOR_NONE")
                CellSpellTooltip:SetPoint("TOPRIGHT", cleuAuraButtons[i], "TOPLEFT", -1, 0)
                CellSpellTooltip:SetSpellByID(self.spellId)
                CellSpellTooltip:Show()
            end)
            cleuAuraButtons[i]:HookScript("OnLeave", function()
                if parent.inputs:IsShown() then return end
                CellSpellTooltip:Hide()
            end)
        end

        local name, icon = F.GetSpellInfo(t[1])
        cleuAuraButtons[i].spellIdText:SetText(t[1])
        cleuAuraButtons[i].spellNameText:SetText(name or L["Invalid"])
        cleuAuraButtons[i].durationText:SetText(t[2])
        if icon then
            cleuAuraButtons[i].spellIcon:SetTexture(icon)
            cleuAuraButtons[i].spellIconBg:Show()
            cleuAuraButtons[i].spellIcon:Show()
        else
            cleuAuraButtons[i].spellIconBg:Hide()
            cleuAuraButtons[i].spellIcon:Hide()
        end
        cleuAuraButtons[i].spellId = t[1]
        cleuAuraButtons[i].duration = t[2]

        -- points
        cleuAuraButtons[i]:ClearAllPoints()
        if i == 1 then -- first
            cleuAuraButtons[i]:SetPoint("TOPLEFT")
        else
            cleuAuraButtons[i]:SetPoint("TOPLEFT", cleuAuraButtons[i-1], "BOTTOMLEFT", 0, 1)
        end
        cleuAuraButtons[i]:SetPoint("RIGHT")
        cleuAuraButtons[i]:Show()

        -- functions
        cleuAuraButtons[i].edit:SetScript("OnClick", function()
            parent.inputs:SetPoint("TOPLEFT", cleuAuraButtons[i])
            parent.inputs:SetPoint("BOTTOMRIGHT", cleuAuraButtons[i])
            parent.inputs:Show()
            parent.inputs.spellEB:SetText(cleuAuraButtons[i].spellId)
            parent.inputs.durationEB:SetText(cleuAuraButtons[i].duration)
            parent.inputs.okBtn:SetEnabled(false)
            parent.inputs.okBtn:SetScript("OnClick", function()
                local spellId = tonumber(parent.inputs.spellEB:GetText())
                local duration = tonumber(parent.inputs.durationEB:GetText())
                local spellName, spellIcon = F.GetSpellInfo(spellId)
                -- update text
                cleuAuraButtons[i].spellIdText:SetText(spellId)
                cleuAuraButtons[i].spellNameText:SetText(spellName)
                cleuAuraButtons[i].durationText:SetText(duration)
                cleuAuraButtons[i].spellId = spellId
                cleuAuraButtons[i].duration = duration
                -- update db
                auraTable[i] = {spellId, duration}
                parent.func(auraTable)
                if spellIcon then
                    cleuAuraButtons[i].spellIcon:SetTexture(spellIcon)
                    cleuAuraButtons[i].spellIconBg:Show()
                    cleuAuraButtons[i].spellIcon:Show()
                else
                    cleuAuraButtons[i].spellIconBg:Hide()
                    cleuAuraButtons[i].spellIcon:Hide()
                end
                parent.inputs:Hide()
            end)
        end)

        cleuAuraButtons[i].del:SetScript("OnClick", function()
            tremove(auraTable, i)
            parent.func(auraTable)
            CreateCleuAuraButtons(parent, auraTable, updateHeightFunc)
            updateHeightFunc(-19)
        end)
    end

    for i = n+1, #cleuAuraButtons do
        cleuAuraButtons[i]:Hide()
        cleuAuraButtons[i]:ClearAllPoints()
    end
end

local function CreateSetting_CleuAuras(parent)
    local widget

    if not settingWidgets["cleuAuras"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_CleuAuras", parent, 240, 128)
        settingWidgets["cleuAuras"] = widget

        widget.frame = Cell.CreateFrame(nil, widget, 20, 20)
        widget.frame:SetPoint("TOPLEFT", 5, -20)
        widget.frame:SetPoint("RIGHT", -5, 0)
        widget.frame:Show()
        Cell.StylizeFrame(widget.frame, {0.15, 0.15, 0.15, 1})

        widget.text = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.text:SetPoint("BOTTOMLEFT", widget.frame, "TOPLEFT", 0, 1)

        -- callback
        function widget:SetFunc(func)
            widget.frame.func = func
        end

        -- show db value
        function widget:SetDBValue(t)
            widget.text:SetText(L["cleuAurasTips"])
            CreateCleuAuraButtons(widget.frame, t, function(diff)
                widget.frame:SetHeight((#t+1)*19+1)
                widget:SetHeight((#t+1)*19+1 + 20 + 5)
                if diff then parent:SetHeight(parent:GetHeight()+diff) end
            end)
            widget.frame:SetHeight((#t+1)*19+1)
            widget:SetHeight((#t+1)*19+1 + 20 + 5)
        end
    else
        widget = settingWidgets["cleuAuras"]
    end

    widget:Show()
    return widget
end
]=]

-------------------------------------------------
-- CreateSetting_BuiltIns
-------------------------------------------------
local classOrder = {"DEATHKNIGHT", "DEMONHUNTER", "DRUID", "EVOKER", "HUNTER", "MAGE", "MONK", "PALADIN", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR", "UNCATEGORIZED"}
local classFrames = {}
local spellButtons = {}
local buttonIndex = 1
local builtInUpdater

local function UpdateSpellButton(btn, class, isDisabled)
    if isDisabled then
        btn:SetBackdropColor(0.6, 0.6, 0.6, 0.85)
        btn.icon:SetDesaturated(true)
        btn:SetAlpha(0.5)
    else
        if class == "UNCATEGORIZED" then
            btn:SetBackdropColor(0.75, 0.75, 0.75, 0.85)
        else
            local r, g, b = F.GetClassColor(class)
            btn:SetBackdropColor(r, g, b, 0.85)
        end
        btn.icon:SetDesaturated(false)
        btn:SetAlpha(1)
    end
end

local function CreateSpellButtons(parent, class, spells, disableds)
    local n = 1
    for spellId in pairs(spells) do
        if not spellButtons[buttonIndex] then
            spellButtons[buttonIndex] = CreateFrame("Button", "CellIndicatorSettings_BuiltIns_SpellButton"..buttonIndex, parent:GetParent(), "BackdropTemplate")
            spellButtons[buttonIndex]:SetBackdrop({bgFile = Cell.vars.whiteTexture})
            P.Size(spellButtons[buttonIndex], 20, 20)

            spellButtons[buttonIndex].icon = spellButtons[buttonIndex]:CreateTexture(nil, "ARTWORK")
            spellButtons[buttonIndex].icon:SetTexCoord(0.12, 0.88, 0.12, 0.88)
            P.Point(spellButtons[buttonIndex].icon, "TOPLEFT", 2, -2)
            P.Point(spellButtons[buttonIndex].icon, "BOTTOMRIGHT", -2, 2)
        end

        spellButtons[buttonIndex]:SetParent(parent)
        spellButtons[buttonIndex]:Show()

        -- tooltips
        spellButtons[buttonIndex]:SetScript("OnEnter", function(self)
            CellSpellTooltip:SetOwner(self, "ANCHOR_NONE")
            CellSpellTooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, P.Scale(3))
            CellSpellTooltip:SetSpellByID(spellId)
            CellSpellTooltip:Show()
        end)
        spellButtons[buttonIndex]:SetScript("OnLeave", function()
            CellSpellTooltip:Hide()
        end)

        -- click
        spellButtons[buttonIndex]:SetScript("OnClick", function(self)
            if disableds[spellId] then
                disableds[spellId] = nil
            else
                disableds[spellId] = true
            end
            UpdateSpellButton(self, class, disableds[spellId])
            builtInUpdater()
        end)

        if spellId == 45438 then
            -- 深寒凝冰 覆盖了 寒冰屏障
            spellButtons[buttonIndex].icon:SetTexture(135841)
        else
            local icon = select(2, F.GetSpellInfo(spellId))
            spellButtons[buttonIndex].icon:SetTexture(icon)
        end

        UpdateSpellButton(spellButtons[buttonIndex], class, disableds[spellId])

        spellButtons[buttonIndex]:ClearAllPoints()
        if n == 1 then
            spellButtons[buttonIndex]:SetPoint("TOPLEFT", 5, -20)
        elseif (n - 1) % 10 == 0 then
            spellButtons[buttonIndex]:SetPoint("TOPLEFT", spellButtons[buttonIndex-10], "BOTTOMLEFT", 0, -5)
        else
            spellButtons[buttonIndex]:SetPoint("TOPLEFT", spellButtons[buttonIndex-1], "TOPRIGHT", 5, 0)
        end

        n = n + 1
        buttonIndex = buttonIndex + 1
    end

    local row = ceil((n - 1) / 10)
    return row * 20 + (row - 1) * 5
end

local function CreateClassFrames(parent, builtIns, disableds)
    local height = 0
    local last

    for _, class in pairs(classOrder) do
        if not classFrames[class] then
            classFrames[class] = Cell.CreateFrame("CellIndicatorSettings_BuiltIns_"..class, parent, nil, nil, true)
            classFrames[class].text = classFrames[class]:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
            classFrames[class].text:SetPoint("TOPLEFT", 5, -5)
        end

        local f = classFrames[class]

        if builtIns[class] then
            -- set position
            f:Show()
            f:ClearAllPoints()
            if last then
                f:SetPoint("TOPLEFT", last, "BOTTOMLEFT")
            else
                f:SetPoint("TOPLEFT")
            end
            f:SetPoint("RIGHT")
            last = f

            -- update text
            if class == "UNCATEGORIZED" then
                f.text:SetText("|cffbababa"..L["Uncategorized"])
            else
                f.text:SetText(F.GetClassColorStr(class)..F.GetLocalizedClassName(class))
            end

            -- create buttons
            local buttonHeight = CreateSpellButtons(f, class, builtIns[class], disableds)

            -- update height
            f:SetHeight(buttonHeight + 20 + 5)
            height = height + buttonHeight + 20 + 5
        else
            f:Hide()
        end
    end

    -- hide unused spell buttons
    for i = buttonIndex, #spellButtons do
        spellButtons[i]:Hide()
    end

    return height
end

local function CreateSetting_BuiltIns(parent)
    local widget

    if not settingWidgets["builtIns"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_BuiltIns", parent, 240, 128)
        settingWidgets["builtIns"] = widget

        widget.frame = Cell.CreateFrame(nil, widget, 20, 20)
        widget.frame:SetPoint("TOPLEFT", 5, -20)
        widget.frame:SetPoint("RIGHT", -5, 0)
        widget.frame:Show()
        Cell.StylizeFrame(widget.frame, {0.15, 0.15, 0.15, 1})

        widget.text = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.text:SetPoint("BOTTOMLEFT", widget.frame, "TOPLEFT", 0, 1)
        widget.text:SetText(L["Built-in Spells"])


        -- callback
        function widget:SetFunc(func)
            builtInUpdater = func
        end

        -- show db value
        function widget:SetDBValue(builtIns, disableds)
            buttonIndex = 1
            local height = CreateClassFrames(widget.frame, builtIns, disableds)
            widget.frame:SetHeight(height)
            widget:SetHeight(height + 25)
        end
    else
        widget = settingWidgets["builtIns"]
    end

    widget:Show()
    return widget
end

local function CreateActionPreview(parent, style)
    local f = CreateFrame("Frame", "CellIndicatorSettings_ActionsPreview_Type"..style, parent, "BackdropTemplate")
    f:SetBackdrop({bgFile = Cell.vars.whiteTexture, edgeFile = Cell.vars.whiteTexture, edgeSize = P.Scale(1)})
    f:SetBackdropColor(0.2, 0.2, 0.2, 1)
    f:SetBackdropBorderColor(0, 0, 0, 1)

    local text = f:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    text:SetPoint("CENTER")
    text:SetText("Type "..style)

    I.CreateActions(f, true)

    function f:UpdateTicker(speed)
        f:SetScript("OnShow", function()
            f.actions:Display(style, {1, 1, 1})
            f.ticker = C_Timer.NewTicker(2/speed, function()
                f.actions:Display(style, {1, 1, 1})
            end)
        end)

        f:SetScript("OnHide", function()
            if f.ticker then
                f.ticker:Cancel()
                f.ticker = nil
            end
        end)
    end

    return f
end

local function CreateSetting_ActionsPreview(parent)
    local widget

    if not settingWidgets["actionsPreview"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_ActionsPreview", parent, 240, 220)
        settingWidgets["actionsPreview"] = widget

        local typeA = CreateActionPreview(widget, "A")
        typeA:SetSize(70, 50)
        typeA:SetPoint("TOPLEFT", 5, -5)

        local typeB = CreateActionPreview(widget, "B")
        typeB:SetSize(70, 50)
        typeB:SetPoint("TOPLEFT", typeA, "TOPRIGHT", 5, 0)

        local typeD = CreateActionPreview(widget, "D")
        typeD:SetSize(70, 50)
        typeD:SetPoint("TOPLEFT", typeB, "TOPRIGHT", 5, 0)

        local typeC1 = CreateActionPreview(widget, "C1")
        typeC1:SetSize(70, 50)
        typeC1:SetPoint("TOPLEFT", typeA, "BOTTOMLEFT", 0, -5)

        local typeC2 = CreateActionPreview(widget, "C2")
        typeC2:SetSize(70, 50)
        typeC2:SetPoint("TOPLEFT", typeC1, "TOPRIGHT", 5, 0)

        local typeC3 = CreateActionPreview(widget, "C3")
        typeC3:SetSize(70, 50)
        typeC3:SetPoint("TOPLEFT", typeC2, "TOPRIGHT", 5, 0)

        local typeE = CreateActionPreview(widget, "E")
        typeE:SetSize(70, 50)
        typeE:SetPoint("TOPLEFT", typeC1, "BOTTOMLEFT", 0, -5)

        local typeF = CreateActionPreview(widget, "F")
        typeF:SetSize(70, 50)
        typeF:SetPoint("TOPLEFT", typeE, "TOPRIGHT", 5, 0)

        local typeG = CreateActionPreview(widget, "G")
        typeG:SetSize(70, 50)
        typeG:SetPoint("TOPLEFT", typeF, "TOPRIGHT", 5, 0)

        local previews = {
            A = typeA,
            B = typeB,
            C1 = typeC1,
            C2 = typeC2,
            C3 = typeC3,
            D = typeD,
            E = typeE,
            F = typeF,
            G = typeG,
        }

        local speedSlider = Cell.CreateSlider(_G.SPEED, widget, 0.5, 1.5, 145, 0.01)
        speedSlider:SetPoint("TOPLEFT", typeE, "BOTTOMLEFT", 0, -25)
        speedSlider.afterValueChangedFn = function(value)
            widget.func(value)

            for _, f in pairs(previews) do
                f:UpdateTicker(value)
                f.actions:SetSpeed(value)
                f:Hide()
                f:Show()
            end
        end

        function widget:SetDBValue(speed)
            speedSlider:SetValue(speed)

            for _, f in pairs(previews) do
                f:UpdateTicker(speed)
                f.actions:SetSpeed(speed)
                f:Hide()
                f:Show()
            end
        end

        function widget:SetFunc(func)
            widget.func = func
        end
    else
        widget = settingWidgets["actionsPreview"]
    end

    widget:Show()
    return widget
end

local actionButtons = {}
local function CreateActionButtons(parent, spellTable, updateHeightFunc)
    local n = #spellTable

    -- tooltip
    if not parent.popupEditBox then
        local popup = Cell.CreatePopupEditBox(parent)
        popup:SetNumeric(true)

        popup:SetScript("OnTextChanged", function()
            local spellId = tonumber(popup:GetText())
            if not spellId then
                CellSpellTooltip:Hide()
                return
            end

            local name = F.GetSpellInfo(spellId)
            if not name then
                CellSpellTooltip:Hide()
                return
            end

            CellSpellTooltip:SetOwner(popup, "ANCHOR_NONE")
            CellSpellTooltip:SetPoint("TOPLEFT", popup, "BOTTOMLEFT", 0, -1)
            CellSpellTooltip:SetSpellByID(spellId)
            CellSpellTooltip:Show()
        end)

        popup:HookScript("OnHide", function()
            CellSpellTooltip:Hide()
        end)
    end

    -- new
    if not actionButtons[0] then
        actionButtons[0] = Cell.CreateButton(parent, "", "transparent-accent", {20, 20})
        actionButtons[0]:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\new", {16, 16}, {"RIGHT", -1, 0})
        actionButtons[0]:SetPoint("BOTTOMLEFT")
        actionButtons[0]:SetPoint("RIGHT")
    end

    actionButtons[0]:SetScript("OnClick", function(self)
        local popup = Cell.CreatePopupEditBox(parent, function(text)
            local spellId = tonumber(text)
            local spellName = F.GetSpellInfo(spellId)
            if spellId and spellName then
                -- update db
                tinsert(spellTable, {
                    spellId,
                    {"A", {1, 1, 1}}
                })
                parent.func(spellTable)
                CreateActionButtons(parent, spellTable, updateHeightFunc)
                updateHeightFunc(19)
            else
                F.Print(L["Invalid spell id."])
            end
        end)
        popup:SetPoint("TOPLEFT", self)
        popup:SetPoint("BOTTOMRIGHT", self)
        popup:ShowEditBox("")
        parent.popupEditBox:SetTips("|cffababab"..L["Input spell id"])
    end)


    for i, spell in ipairs(spellTable) do
        -- creation
        if not actionButtons[i] then
            actionButtons[i] = Cell.CreateButton(parent, "", "transparent-accent", {20, 20})

            -- spellIcon
            actionButtons[i].spellIconBg = actionButtons[i]:CreateTexture(nil, "BORDER")
            actionButtons[i].spellIconBg:SetSize(16, 16)
            actionButtons[i].spellIconBg:SetPoint("TOPLEFT", 2, -2)
            actionButtons[i].spellIconBg:SetColorTexture(0, 0, 0, 1)
            actionButtons[i].spellIconBg:Hide()

            actionButtons[i].spellIcon = actionButtons[i]:CreateTexture(nil, "OVERLAY")
            actionButtons[i].spellIcon:SetPoint("TOPLEFT", actionButtons[i].spellIconBg, 1, -1)
            actionButtons[i].spellIcon:SetPoint("BOTTOMRIGHT", actionButtons[i].spellIconBg, -1, 1)
            actionButtons[i].spellIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            actionButtons[i].spellIcon:Hide()

            -- spellId text
            actionButtons[i].spellIdText = actionButtons[i]:CreateFontString(nil, "OVERLAY", font_name)
            actionButtons[i].spellIdText:SetPoint("LEFT", actionButtons[i].spellIconBg, "RIGHT", 5, 0)
            actionButtons[i].spellIdText:SetPoint("RIGHT", actionButtons[i], "LEFT", 80, 0)
            actionButtons[i].spellIdText:SetWordWrap(false)
            actionButtons[i].spellIdText:SetJustifyH("LEFT")

            -- spellName text
            actionButtons[i].spellNameText = actionButtons[i]:CreateFontString(nil, "OVERLAY", font_name)
            actionButtons[i].spellNameText:SetPoint("LEFT", actionButtons[i].spellIdText, "RIGHT", 5, 0)
            actionButtons[i].spellNameText:SetPoint("RIGHT", -90, 0)
            actionButtons[i].spellNameText:SetWordWrap(false)
            actionButtons[i].spellNameText:SetJustifyH("LEFT")

            -- style dropdown
            actionButtons[i].styleDropdown = Cell.CreateDropdown(actionButtons[i], 30, nil, true)
            P.Height(actionButtons[i].styleDropdown, 16)
            actionButtons[i].styleDropdown:SetPoint("TOPLEFT", actionButtons[i], 180, -2)
            actionButtons[i].styleDropdown.button:HookScript("OnEnter", function()
                actionButtons[i]:GetScript("OnEnter")(actionButtons[i])
            end)
            actionButtons[i].styleDropdown.button:HookScript("OnLeave", function()
                actionButtons[i]:GetScript("OnLeave")(actionButtons[i])
            end)

            local items = {}
            for _, style in pairs({"A", "B", "C1", "C2", "C3", "D", "E", "F", "G"}) do
                tinsert(items, {
                    ["text"] = style,
                    ["onClick"] = function()
                        CellIndicatorsPreviewButton.indicators.actions:Display(style, actionButtons[i].animationColor)
                        actionButtons[i].animationType = style
                        -- update db
                        spellTable[i][2][1] = style
                        parent.func(spellTable)
                    end,
                })
            end
            actionButtons[i].styleDropdown:SetItems(items)

            -- color
            actionButtons[i].colorPicker = Cell.CreateColorPicker(actionButtons[i], "", false, nil, function(r, g, b, a)
                spellTable[i][2][2][1] = r
                spellTable[i][2][2][2] = g
                spellTable[i][2][2][3] = b
                parent.func(spellTable)
                actionButtons[i].animationColor = {r, g, b}
                CellIndicatorsPreviewButton.indicators.actions:Display(actionButtons[i].animationType, actionButtons[i].animationColor)
            end)
            actionButtons[i].colorPicker:SetPoint("TOPLEFT", actionButtons[i].styleDropdown, "TOPRIGHT", 2, -1)
            actionButtons[i].colorPicker:HookScript("OnEnter", function()
                actionButtons[i]:GetScript("OnEnter")(actionButtons[i])
            end)
            actionButtons[i].colorPicker:HookScript("OnLeave", function()
                actionButtons[i]:GetScript("OnLeave")(actionButtons[i])
            end)

            -- del
            actionButtons[i].del = Cell.CreateButton(actionButtons[i], "", "none", {18, 20}, true, true)
            actionButtons[i].del:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\delete", {16, 16}, {"CENTER", 0, 0})
            actionButtons[i].del:SetPoint("RIGHT")
            actionButtons[i].del.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
            actionButtons[i].del:SetScript("OnEnter", function()
                actionButtons[i]:GetScript("OnEnter")(actionButtons[i])
                actionButtons[i].del.tex:SetVertexColor(1, 1, 1, 1)
            end)
            actionButtons[i].del:SetScript("OnLeave",  function()
                actionButtons[i]:GetScript("OnLeave")(actionButtons[i])
                actionButtons[i].del.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
            end)

            -- edit
            actionButtons[i].edit = Cell.CreateButton(actionButtons[i], "", "none", {18, 20}, true, true)
            actionButtons[i].edit:SetPoint("RIGHT", actionButtons[i].del, "LEFT", 1, 0)
            actionButtons[i].edit:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\info", {16, 16}, {"CENTER", 0, 0})
            actionButtons[i].edit.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
            actionButtons[i].edit:SetScript("OnEnter", function()
                actionButtons[i]:GetScript("OnEnter")(actionButtons[i])
                actionButtons[i].edit.tex:SetVertexColor(1, 1, 1, 1)
            end)
            actionButtons[i].edit:SetScript("OnLeave",  function()
                actionButtons[i]:GetScript("OnLeave")(actionButtons[i])
                actionButtons[i].edit.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
            end)

            -- preview
            actionButtons[i]:SetScript("OnClick", function(self, button)
                CellIndicatorsPreviewButton.indicators.actions:Display(actionButtons[i].animationType, actionButtons[i].animationColor)
            end)

            -- spell tooltip
            actionButtons[i]:HookScript("OnEnter", function(self)
                if not parent.popupEditBox:IsShown() then
                    local name = F.GetSpellInfo(self.spellId)
                    if not name then
                        CellSpellTooltip:Hide()
                        return
                    end

                    CellSpellTooltip:SetOwner(actionButtons[i], "ANCHOR_NONE")
                    CellSpellTooltip:SetPoint("TOPRIGHT", actionButtons[i], "TOPLEFT", -1, 0)
                    CellSpellTooltip:SetSpellByID(self.spellId)
                    CellSpellTooltip:Show()
                end
            end)
            actionButtons[i]:HookScript("OnLeave", function()
                if not parent.popupEditBox:IsShown() then
                    CellSpellTooltip:Hide()
                end
            end)
        end

        -- fill data
        local name, icon = F.GetSpellInfo(spell[1])
        actionButtons[i].spellIdText:SetText(spell[1])
        actionButtons[i].spellId = spell[1]
        actionButtons[i].spellNameText:SetText(name or L["Invalid"])
        if icon then
            actionButtons[i].spellIcon:SetTexture(icon)
            actionButtons[i].spellIconBg:Show()
            actionButtons[i].spellIcon:Show()
        else
            actionButtons[i].spellIconBg:Hide()
            actionButtons[i].spellIcon:Hide()
        end

        actionButtons[i].animationType = spell[2][1]
        actionButtons[i].styleDropdown:SetSelected(spell[2][1])
        actionButtons[i].animationColor = spell[2][2]
        actionButtons[i].colorPicker:SetColor(spell[2][2])

        -- points
        actionButtons[i]:ClearAllPoints()
        if i == 1 then -- first
            actionButtons[i]:SetPoint("TOPLEFT")
        else
            actionButtons[i]:SetPoint("TOPLEFT", actionButtons[i-1], "BOTTOMLEFT", 0, 1)
        end
        actionButtons[i]:SetPoint("RIGHT")
        actionButtons[i]:Show()

        -- functions
        actionButtons[i].edit:SetScript("OnClick", function()
            local popup = Cell.CreatePopupEditBox(parent, function(text)
                local spellId = tonumber(text)
                local spellName, spellIcon = F.GetSpellInfo(spellId)
                if spellId and spellName then
                    -- update text
                    actionButtons[i].spellIdText:SetText(spellId)
                    actionButtons[i].spellId = spellId
                    actionButtons[i].spellNameText:SetText(spellName)
                    -- update db
                    spellTable[i][1] = spellId
                    parent.func(spellTable)
                    if spellIcon then
                        actionButtons[i].spellIcon:SetTexture(spellIcon)
                        actionButtons[i].spellIconBg:Show()
                        actionButtons[i].spellIcon:Show()
                    else
                        actionButtons[i].spellIconBg:Hide()
                        actionButtons[i].spellIcon:Hide()
                    end
                else
                    F.Print(L["Invalid spell id."])
                end
            end)
            popup:SetPoint("TOPLEFT", actionButtons[i])
            popup:SetPoint("BOTTOMRIGHT", actionButtons[i])
            popup:ShowEditBox(actionButtons[i].spellId or "")
            parent.popupEditBox:SetTips("|cffababab"..L["Input spell id"])
        end)

        actionButtons[i].del:SetScript("OnClick", function()
            tremove(spellTable, i)
            parent.func(spellTable)
            CreateActionButtons(parent, spellTable, updateHeightFunc)
            updateHeightFunc(-19)
        end)
    end

    for i = n+1, #actionButtons do
        actionButtons[i]:Hide()
        actionButtons[i]:ClearAllPoints()
    end
end

local function CreateSetting_ActionsList(parent)
    local widget

    if not settingWidgets["actionsList"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_ActionsList", parent, 240, 128)
        settingWidgets["actionsList"] = widget

        widget.text = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.text:SetPoint("TOPLEFT", 7, -7)
        widget.text:SetText(L["Click to preview"])

        widget.debug = Cell.CreateButton(widget, L["Debug Mode"], "accent", {100, 17})
        widget.debug:SetPoint("TOPRIGHT", -5, -5)
        widget.debug.enabled = false
        widget.debug:SetScript("OnClick", function(self)
            if self.enabled then
                self.enabled = false
                LCG.PixelGlow_Stop(widget.debug)
            else
                self.enabled = true
                LCG.PixelGlow_Start(widget.debug, {0,1,0,1}, 9, 0.25, 8, 1)
            end
            Cell.vars.actionsDebugModeEnabled = self.enabled
        end)

        widget.frame = Cell.CreateFrame(nil, widget, 20, 20)
        widget.frame:SetPoint("TOPLEFT", 5, -27)
        widget.frame:SetPoint("RIGHT", -5, 0)
        widget.frame:Show()
        Cell.StylizeFrame(widget.frame, {0.15, 0.15, 0.15, 1})

        -- callback
        function widget:SetFunc(func)
            widget.frame.func = func
        end

        -- show db value
        function widget:SetDBValue(t)
            CreateActionButtons(widget.frame, t, function(diff)
                widget.frame:SetHeight((#t+1)*19+1)
                widget:SetHeight((#t+1)*19+1 + 27 + 5)
                if diff then parent:SetHeight(parent:GetHeight()+diff) end
            end)
            widget.frame:SetHeight((#t+1)*19+1)
            widget:SetHeight((#t+1)*19+1 + 27 + 5)
        end
    else
        widget = settingWidgets["actionsList"]
    end

    widget:Show()
    return widget
end

local thresholdButtons = {}
local function CreateThresholdButtons(parent, thresholdTable, updateHeightFunc)
    local n = #thresholdTable

    -- new
    if not thresholdButtons[0] then
        thresholdButtons[0] = Cell.CreateButton(parent, "", "transparent-accent", {20, 20})
        thresholdButtons[0]:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\new", {16, 16}, {"RIGHT", -1, 0})
        thresholdButtons[0]:SetPoint("BOTTOMLEFT")
        thresholdButtons[0]:SetPoint("RIGHT")
    end

    thresholdButtons[0]:SetScript("OnClick", function(self)
        tinsert(thresholdTable, {0.99, {1, 0, 0, 1}})
        parent.func(thresholdTable)
        CreateThresholdButtons(parent, thresholdTable, updateHeightFunc)
        updateHeightFunc(19)
    end)


    for i, t in ipairs(thresholdTable) do
        -- creation
        if not thresholdButtons[i] then
            thresholdButtons[i] = Cell.CreateButton(parent, "", "transparent-accent", {20, 20})

            -- threshold
            thresholdButtons[i].eb = Cell.CreateEditBox(thresholdButtons[i], 35, 16, false, false, true)
            thresholdButtons[i].eb:SetPoint("TOPLEFT", 2, -2)
            thresholdButtons[i].eb:SetMaxLetters(2)
            thresholdButtons[i].eb:HookScript("OnEnter", function()
                thresholdButtons[i]:GetScript("OnEnter")(thresholdButtons[i])
            end)
            thresholdButtons[i].eb:HookScript("OnLeave", function()
                thresholdButtons[i]:GetScript("OnLeave")(thresholdButtons[i])
            end)

            thresholdButtons[i].confirmBtn = Cell.CreateButton(thresholdButtons[i], "OK", "accent", {27, 16})
            thresholdButtons[i].confirmBtn:SetPoint("TOPLEFT", thresholdButtons[i].eb, "TOPRIGHT", P.Scale(-1), 0)
            thresholdButtons[i].confirmBtn:Hide()
            thresholdButtons[i].confirmBtn:SetScript("OnHide", function()
                thresholdButtons[i].confirmBtn:Hide()
            end)
            thresholdButtons[i].confirmBtn:HookScript("OnEnter", function()
                thresholdButtons[i]:GetScript("OnEnter")(thresholdButtons[i])
            end)
            thresholdButtons[i].confirmBtn:HookScript("OnLeave", function()
                thresholdButtons[i]:GetScript("OnLeave")(thresholdButtons[i])
            end)
            thresholdButtons[i].confirmBtn:SetScript("OnClick", function()
                local newThreshold = tonumber(thresholdButtons[i].eb:GetText())
                thresholdTable[i][1] = newThreshold / 100
                parent.func(thresholdTable)
                thresholdButtons[i].eb:ClearFocus()
                thresholdButtons[i].confirmBtn:Hide()
                CreateThresholdButtons(parent, thresholdTable, updateHeightFunc)
            end)

            thresholdButtons[i].eb:SetScript("OnTextChanged", function(self, userChanged)
                if userChanged then
                    local newThreshold = tonumber(self:GetText())
                    if newThreshold and newThreshold ~= thresholdTable[i][1] * 100 then
                        thresholdButtons[i].confirmBtn:Show()
                    else
                        thresholdButtons[i].confirmBtn:Hide()
                    end
                end
            end)

            -- percentSign
            thresholdButtons[i].percentSign = thresholdButtons[i]:CreateFontString(nil, "OVERLAY", font_name)
            thresholdButtons[i].percentSign:SetPoint("LEFT", thresholdButtons[i].eb, "RIGHT", 2, 0)
            thresholdButtons[i].percentSign:SetText("%")

            -- color
            thresholdButtons[i].colorPicker = Cell.CreateColorPicker(thresholdButtons[i], "", true, nil, function(r, g, b, a)
                thresholdTable[i][2][1] = r
                thresholdTable[i][2][2] = g
                thresholdTable[i][2][3] = b
                thresholdTable[i][2][4] = a
                parent.func(thresholdTable)
            end)
            thresholdButtons[i].colorPicker:SetPoint("TOPLEFT", thresholdButtons[i].eb, "TOPRIGHT", P.Scale(30), P.Scale(-1))
            thresholdButtons[i].colorPicker:HookScript("OnEnter", function()
                thresholdButtons[i]:GetScript("OnEnter")(thresholdButtons[i])
            end)
            thresholdButtons[i].colorPicker:HookScript("OnLeave", function()
                thresholdButtons[i]:GetScript("OnLeave")(thresholdButtons[i])
            end)

            -- del
            thresholdButtons[i].del = Cell.CreateButton(thresholdButtons[i], "", "none", {18, 20}, true, true)
            thresholdButtons[i].del:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\delete", {16, 16}, {"CENTER", 0, 0})
            thresholdButtons[i].del:SetPoint("RIGHT")
            thresholdButtons[i].del.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
            thresholdButtons[i].del:SetScript("OnEnter", function()
                thresholdButtons[i]:GetScript("OnEnter")(thresholdButtons[i])
                thresholdButtons[i].del.tex:SetVertexColor(1, 1, 1, 1)
            end)
            thresholdButtons[i].del:SetScript("OnLeave",  function()
                thresholdButtons[i]:GetScript("OnLeave")(thresholdButtons[i])
                thresholdButtons[i].del.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
            end)
        end

        -- fill data
        thresholdButtons[i].eb:SetText(t[1]*100)
        thresholdButtons[i].colorPicker:SetColor(t[2])

        -- points
        thresholdButtons[i]:ClearAllPoints()
        if i == 1 then -- first
            thresholdButtons[i]:SetPoint("TOPLEFT")
        else
            thresholdButtons[i]:SetPoint("TOPLEFT", thresholdButtons[i-1], "BOTTOMLEFT", 0, P.Scale(1))
        end
        thresholdButtons[i]:SetPoint("RIGHT")
        thresholdButtons[i]:Show()

        -- functions
        thresholdButtons[i].del:SetScript("OnClick", function()
            tremove(thresholdTable, i)
            parent.func(thresholdTable)
            CreateThresholdButtons(parent, thresholdTable, updateHeightFunc)
            updateHeightFunc(-19)
        end)
    end

    for i = n+1, #thresholdButtons do
        thresholdButtons[i]:Hide()
        thresholdButtons[i]:ClearAllPoints()
    end
end

local function CreateSetting_Thresholds(parent)
    local widget

    if not settingWidgets["thresholds"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_Thresholds", parent, 240, 128)
        settingWidgets["thresholds"] = widget

        widget.text = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.text:SetPoint("TOPLEFT", 7, -7)
        widget.text:SetText(L["Only one threshold is displayed at a time"])

        widget.frame = Cell.CreateFrame(nil, widget, 100, 20)
        widget.frame:SetPoint("TOPLEFT", 5, -27)
        -- widget.frame:SetPoint("RIGHT", -5, 0)
        widget.frame:Show()
        Cell.StylizeFrame(widget.frame, {0.15, 0.15, 0.15, 1})

        -- callback
        function widget:SetFunc(func)
            widget.frame.func = func
        end

        -- show db value
        function widget:SetDBValue(t)
            CreateThresholdButtons(widget.frame, t, function(diff)
                widget.frame:SetHeight((#t+1)*19+1)
                widget:SetHeight((#t+1)*19+1 + 27 + 5)
                if diff then parent:SetHeight(parent:GetHeight()+diff) end
            end)
            widget.frame:SetHeight((#t+1)*19+1)
            widget:SetHeight((#t+1)*19+1 + 27 + 5)
        end
    else
        widget = settingWidgets["thresholds"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_HighlightType(parent)
    local widget

    if not settingWidgets["highlightType"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_HighlightType", parent, 240, 50)
        -- widget = Cell.CreateFrame("CellIndicatorSettings_HighlightType", parent, 240, 117)
        settingWidgets["highlightType"] = widget

        widget.highlightType = Cell.CreateDropdown(widget, 245)
        widget.highlightType:SetPoint("TOPLEFT", 5, -20)
        widget.highlightType:SetItems({
            {
                ["text"] = L["None"],
                ["value"] = "none",
                ["onClick"] = function()
                    widget.func("none")
                end,
            },
            {
                ["text"] = L["Gradient"].." - "..L["Health Bar"].." ("..L["Entire"]..")",
                ["value"] = "gradient",
                ["onClick"] = function()
                    widget.func("gradient")
                end,
            },
            {
                ["text"] = L["Gradient"].." - "..L["Health Bar"].." ("..L["Half"]..")",
                ["value"] = "gradient-half",
                ["onClick"] = function()
                    widget.func("gradient-half")
                end,
            },
            {
                ["text"] = L["Solid"].." - "..L["Health Bar"].." ("..L["Entire"]..")",
                ["value"] = "entire",
                ["onClick"] = function()
                    widget.func("entire")
                end,
            },
            {
                ["text"] = L["Solid"].." - "..L["Health Bar"].." ("..L["Current"]..")",
                ["value"] = "current",
                ["onClick"] = function()
                    widget.func("current")
                end,
            },
            {
                ["text"] = L["Solid"].." - "..L["Health Bar"].." ("..L["Current"].."+)",
                ["value"] = "current+",
                ["onClick"] = function()
                    widget.func("current+")
                end,
            },
        })

        widget.highlightTypeText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.highlightTypeText:SetText(L["Highlight Type"])
        widget.highlightTypeText:SetPoint("BOTTOMLEFT", widget.highlightType, "TOPLEFT", 0, 1)

        --[[
        -- curse
        widget.curseCP = Cell.CreateColorPicker(widget, "|TInterface\\AddOns\\Cell\\Media\\Debuffs\\Curse:0|t "..L["Curse"], false, nil, function(r, g, b)
            I.SetDebuffTypeColor("Curse", r, g, b)
            widget.func(widget.highlightType:GetSelected())
        end)
        widget.curseCP:SetPoint("TOPLEFT", widget.highlightType, "BOTTOMLEFT", 0, -7)

        -- disease
        widget.diseaseCP = Cell.CreateColorPicker(widget, "|TInterface\\AddOns\\Cell\\Media\\Debuffs\\Disease:0|t "..L["Disease"], false, nil, function(r, g, b)
            I.SetDebuffTypeColor("Disease", r, g, b)
            widget.func(widget.highlightType:GetSelected())
        end)
        widget.diseaseCP:SetPoint("TOPLEFT", widget.curseCP, "TOPRIGHT", 110, 0)

        -- magic
        widget.magicCP = Cell.CreateColorPicker(widget, "|TInterface\\AddOns\\Cell\\Media\\Debuffs\\Magic:0|t "..L["Magic"], false, nil, function(r, g, b)
            I.SetDebuffTypeColor("Magic", r, g, b)
            widget.func(widget.highlightType:GetSelected())
        end)
        widget.magicCP:SetPoint("TOPLEFT", widget.curseCP, "BOTTOMLEFT", 0, -7)

        -- poison
        widget.poisonCP = Cell.CreateColorPicker(widget, "|TInterface\\AddOns\\Cell\\Media\\Debuffs\\Poison:0|t "..L["Poison"], false, nil, function(r, g, b)
            I.SetDebuffTypeColor("Poison", r, g, b)
            widget.func(widget.highlightType:GetSelected())
        end)
        widget.poisonCP:SetPoint("TOPLEFT", widget.magicCP, "TOPRIGHT", 110, 0)

        -- reset
        widget.resetBtn = Cell.CreateButton(widget, L["Reset All"], "accent-hover", {70, 20})
        widget.resetBtn:SetPoint("TOPLEFT", widget.magicCP, "BOTTOMLEFT", 0, -7)
        widget.resetBtn:SetScript("OnClick", function()
            I.ResetDebuffTypeColor()
            widget.curseCP:SetColor(I.GetDebuffTypeColor("Curse"))
            widget.diseaseCP:SetColor(I.GetDebuffTypeColor("Disease"))
            widget.magicCP:SetColor(I.GetDebuffTypeColor("Magic"))
            widget.poisonCP:SetColor(I.GetDebuffTypeColor("Poison"))
            widget.func(widget.highlightType:GetSelected())
        end)
        ]]

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(highlightType)
            widget.highlightType:SetSelectedValue(highlightType)
            -- widget.curseCP:SetColor(I.GetDebuffTypeColor("Curse"))
            -- widget.diseaseCP:SetColor(I.GetDebuffTypeColor("Disease"))
            -- widget.magicCP:SetColor(I.GetDebuffTypeColor("Magic"))
            -- widget.poisonCP:SetColor(I.GetDebuffTypeColor("Poison"))
        end
    else
        widget = settingWidgets["highlightType"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_PrivateAuraOptions(parent)
    local widget

    if not settingWidgets["privateAuraOptions"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_PrivateAuraOptions", parent, 240, 55)
        settingWidgets["privateAuraOptions"] = widget

        widget.cb1 = Cell.CreateCheckButton(widget, L["Show countdown swipe"])
        widget.cb1:SetPoint("TOPLEFT", 5, -8)
        widget.cb2 = Cell.CreateCheckButton(widget, L["Show countdown number"])
        widget.cb2:SetPoint("TOPLEFT", widget.cb1, "BOTTOMLEFT", 0, -7)

        -- callback
        function widget:SetFunc(func)
            widget.cb1.onClick = function(checked)
                widget.cb2:SetEnabled(checked)
                func({checked, widget.cb2:GetChecked()})
            end
            widget.cb2.onClick = function(checked)
                func({widget.cb1:GetChecked(), checked})
            end
        end

        -- show db value
        function widget:SetDBValue(t)
            widget.cb1:SetChecked(t[1])
            widget.cb2:SetChecked(t[2])
            widget.cb2:SetEnabled(t[1])
        end
    else
        widget = settingWidgets["privateAuraOptions"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_Tips(parent, text)
    local widget

    if not settingWidgets["tips"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_Tips", parent, 240, 30)
        settingWidgets["tips"] = widget

        -- widget.text = widget:CreateFontString(nil, "OVERLAY", font_name)
        -- widget.text:SetPoint("LEFT", 5, 0)
        -- widget.text:SetPoint("RIGHT", -5, 0)
        -- widget.text:SetJustifyH("LEFT")
        widget.text = Cell.CreateScrollTextFrame(widget, "", 0.02, nil, nil, true)
        widget.text:SetPoint("LEFT", 5, 0)
        widget.text:SetPoint("RIGHT", -5, 0)

        function widget:SetDBValue()
        end
        function widget:SetFunc()
        end
    else
        widget = settingWidgets["tips"]
    end

    widget.text:SetText(text)
    widget:Show()
    return widget
end

local function CreateSetting_Shape(parent)
    local widget

    if not settingWidgets["shape"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_Shape", parent, 240, 50)
        settingWidgets["shape"] = widget

        local shapes = {"circle", "square", "rhombus", "hexagon", "octagon"}

        widget.buttons = {}

        for i, s in pairs(shapes) do
            widget.buttons[s] = Cell.CreateButton(widget, nil, "accent-hover", {22, 22})
            widget.buttons[s]:SetTexture("Interface\\AddOns\\Cell\\Media\\Shapes\\"..shapes[i].."_filled", {18, 18}, {"CENTER", 0, 0})

            -- button group
            widget.buttons[s].id = s

            if i == 1 then
                widget.buttons[s]:SetPoint("TOPLEFT", 5, -20)
            else
                widget.buttons[s]:SetPoint("TOPLEFT", widget.buttons[shapes[i-1]], "TOPRIGHT", 5, 0)
            end
        end

        widget.highlight = Cell.CreateButtonGroup(widget.buttons, function(shape)
            widget.func(shape)
        end)

        -- widget.shape = Cell.CreateDropdown(widget, 153)
        -- widget.shape:SetPoint("TOPLEFT", 5, -20)
        -- widget.shape:SetItems({
        --     {
        --         ["text"] = "|TInterface\\AddOns\\Cell\\Media\\Shapes\\circle_filled:0|t",
        --         ["value"] = "circle",
        --         ["onClick"] = function()
        --             widget.func("circle")
        --         end,
        --     },
        --     {
        --         ["text"] = "|TInterface\\AddOns\\Cell\\Media\\Shapes\\square_filled:0|t",
        --         ["value"] = "square",
        --         ["onClick"] = function()
        --             widget.func("square")
        --         end,
        --     },
        --     {
        --         ["text"] = "|TInterface\\AddOns\\Cell\\Media\\Shapes\\rhombus_filled:0|t",
        --         ["value"] = "rhombus",
        --         ["onClick"] = function()
        --             widget.func("rhombus")
        --         end,
        --     },
        --     {
        --         ["text"] = "|TInterface\\AddOns\\Cell\\Media\\Shapes\\hexagon_filled:0|t",
        --         ["value"] = "hexagon",
        --         ["onClick"] = function()
        --             widget.func("hexagon")
        --         end,
        --     },
        --     {
        --         ["text"] = "|TInterface\\AddOns\\Cell\\Media\\Shapes\\octagon_filled:0|t",
        --         ["value"] = "octagon",
        --         ["onClick"] = function()
        --             widget.func("octagon")
        --         end,
        --     },
        --     {
        --         ["text"] = "|TInterface\\AddOns\\Cell\\Media\\Shapes\\star_filled:0|t",
        --         ["value"] = "star",
        --         ["onClick"] = function()
        --             widget.func("star")
        --         end,
        --     },
        -- })

        widget.shapeText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.shapeText:SetText(L["Shape"])
        widget.shapeText:SetPoint("BOTTOMLEFT", widget.buttons[shapes[1]], "TOPLEFT", 0, 2)

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(shape)
            -- widget.shape:SetSelectedValue(shape)
            widget.highlight(shape)
        end
    else
        widget = settingWidgets["shape"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_MissingBuffsFilters(parent)
    local widget

    if not settingWidgets["missingBuffsFilters"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_MissingBuffsFilters", parent, 240, 30)
        settingWidgets["missingBuffsFilters"] = widget

        widget.buffByMe = Cell.CreateCheckButton(widget, L["buffByMe"])
        widget.buffByMe:SetPoint("TOPLEFT", 5, -8)

        local buffs = I.GetMissingBuffsFilters()
        local indexToCB = {}

        for i, t in ipairs(buffs) do
            widget[i] = Cell.CreateCheckButton(widget, t[1])
            indexToCB[t[2]] = widget[i]

            if i == 1 then
                widget[i]:SetPoint("TOPLEFT", widget.buffByMe, "BOTTOMLEFT", 0, -16)
            else
                widget[i]:SetPoint("TOPLEFT", widget[i-1], "BOTTOMLEFT", 0, -8)
            end
        end

        P.Height(widget, (#buffs+1)*(14+8)+8+8)

        -- callback
        function widget:SetFunc(func)
            widget.buffByMe.onClick = function(checked)
                widget.filters.buffByMe = checked
                func()
            end

            for k, cb in pairs(indexToCB) do
                cb.onClick = function(checked)
                    widget.filters[k] = checked
                    func()
                end
            end
        end

        -- show db value
        function widget:SetDBValue(filters)
            widget.filters = filters
            widget.buffByMe:SetChecked(filters["buffByMe"])
            for k, cb in pairs(indexToCB) do
                cb:SetChecked(filters[k])
            end
        end
    else
        widget = settingWidgets["missingBuffsFilters"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_TargetCounterFilters(parent)
    local widget

    if not settingWidgets["targetCounterFilters"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_TargetCounterFilters", parent, 240, 74)
        settingWidgets["targetCounterFilters"] = widget

        widget.outdoor = Cell.CreateCheckButton(widget, L["Outdoor"])
        widget.outdoor:SetPoint("TOPLEFT", 5, -8)

        widget.pve = Cell.CreateCheckButton(widget, "PvE")
        widget.pve:SetPoint("TOPLEFT", widget.outdoor, "BOTTOMLEFT", 0, -8)

        widget.pvp = Cell.CreateCheckButton(widget, "PvP")
        widget.pvp:SetPoint("TOPLEFT", widget.pve, "BOTTOMLEFT", 0, -8)

        -- callback
        function widget:SetFunc(func)
            widget.outdoor.onClick = function(checked)
                widget.filters.outdoor = checked
                func()
            end
            widget.pve.onClick = function(checked)
                widget.filters.pve = checked
                func()
            end
            widget.pvp.onClick = function(checked)
                widget.filters.pvp = checked
                func()
            end
        end

        -- show db value
        function widget:SetDBValue(filters)
            widget.filters = filters
            widget.outdoor:SetChecked(filters["outdoor"])
            widget.pve:SetChecked(filters["pve"])
            widget.pvp:SetChecked(filters["pvp"])
        end
    else
        widget = settingWidgets["targetCounterFilters"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_DispelFilters(parent)
    local widget

    if not settingWidgets["dispelFilters"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_DispelFilters", parent, 240, 96)
        settingWidgets["dispelFilters"] = widget

        widget.dispellableByMe = Cell.CreateCheckButton(widget, L["dispellableByMe"])
        widget.dispellableByMe:SetPoint("TOPLEFT", 5, -8)

        widget.curse = Cell.CreateCheckButton(widget, "|TInterface\\AddOns\\Cell\\Media\\Debuffs\\Curse:0|t"..L["Curse"])
        widget.curse:SetPoint("TOPLEFT", widget.dispellableByMe, "BOTTOMLEFT", 0, -8)

        widget.disease = Cell.CreateCheckButton(widget, "|TInterface\\AddOns\\Cell\\Media\\Debuffs\\Disease:0|t"..L["Disease"])
        widget.disease:SetPoint("TOPLEFT", widget.curse, 135, 0)

        widget.magic = Cell.CreateCheckButton(widget, "|TInterface\\AddOns\\Cell\\Media\\Debuffs\\Magic:0|t"..L["Magic"])
        widget.magic:SetPoint("TOPLEFT", widget.curse, "BOTTOMLEFT", 0, -8)

        widget.poison = Cell.CreateCheckButton(widget, "|TInterface\\AddOns\\Cell\\Media\\Debuffs\\Poison:0|t"..L["Poison"])
        widget.poison:SetPoint("TOPLEFT", widget.magic, 135, 0)

        widget.bleed = Cell.CreateCheckButton(widget, "|TInterface\\AddOns\\Cell\\Media\\Debuffs\\Bleed:0|t"..L["Bleed"])
        widget.bleed:SetPoint("TOPLEFT", widget.magic, "BOTTOMLEFT", 0, -8)

        -- callback
        function widget:SetFunc(func)
            widget.dispellableByMe.onClick = function(checked)
                widget.filters.dispellableByMe = checked
                func()
            end
            widget.curse.onClick = function(checked)
                widget.filters.Curse = checked
                func()
            end
            widget.disease.onClick = function(checked)
                widget.filters.Disease = checked
                func()
            end
            widget.magic.onClick = function(checked)
                widget.filters.Magic = checked
                func()
            end
            widget.poison.onClick = function(checked)
                widget.filters.Poison = checked
                func()
            end
            widget.bleed.onClick = function(checked)
                widget.filters.Bleed = checked
                func()
            end
        end

        -- show db value
        function widget:SetDBValue(filters)
            widget.filters = filters
            widget.dispellableByMe:SetChecked(filters.dispellableByMe)
            widget.curse:SetChecked(filters.Curse)
            widget.disease:SetChecked(filters.Disease)
            widget.magic:SetChecked(filters.Magic)
            widget.poison:SetChecked(filters.Poison)
            widget.bleed:SetChecked(filters.Bleed)
        end
    else
        widget = settingWidgets["dispelFilters"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_CastBy(parent)
    local widget

    if not settingWidgets["castBy"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_CastBy", parent, 240, 50)
        settingWidgets["castBy"] = widget

        widget.castBy = Cell.CreateDropdown(widget, 245)
        widget.castBy:SetPoint("TOPLEFT", 5, -20)
        widget.castBy:SetItems({
            {
                ["text"] = L["Me"],
                ["value"] = "me",
                ["onClick"] = function()
                    widget.func("me")
                end,
            },
            {
                ["text"] = L["Others"],
                ["value"] = "others",
                ["onClick"] = function()
                    widget.func("others")
                end,
            },
            {
                ["text"] = L["Anyone"],
                ["value"] = "anyone",
                ["onClick"] = function()
                    widget.func("anyone")
                end,
            },
        })

        widget.castByText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.castByText:SetText(L["Cast By"])
        widget.castByText:SetPoint("BOTTOMLEFT", widget.castBy, "TOPLEFT", 0, 1)

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(castBy)
            widget.castBy:SetSelectedValue(castBy)
        end
    else
        widget = settingWidgets["castBy"]
    end

    widget:Show()
    return widget
end

-- local function CreateSetting_ShowOn(parent)
--     local widget

--     if not settingWidgets["showOn"] then
--         widget = Cell.CreateFrame("CellIndicatorSettings_ShowOn", parent, 240, 50)
--         settingWidgets["showOn"] = widget

--         widget.showOn = Cell.CreateDropdown(widget, 245)
--         widget.showOn:SetPoint("TOPLEFT", 5, -20)
--         widget.showOn:SetItems({
--             {
--                 ["text"] = L["All"],
--                 ["value"] = "all",
--                 ["onClick"] = function()
--                     widget.func("all")
--                 end,
--             },
--             {
--                 ["text"] = L["Main"],
--                 ["value"] = "main",
--                 ["onClick"] = function()
--                     widget.func("main")
--                 end,
--             },
--             {
--                 ["text"] = L["Spotlight"],
--                 ["value"] = "spotlight",
--                 ["onClick"] = function()
--                     widget.func("spotlight")
--                 end,
--             },
--             {
--                 ["text"] = L["Pet"],
--                 ["value"] = "pet",
--                 ["onClick"] = function()
--                     widget.func("pet")
--                 end,
--             },
--             {
--                 ["text"] = L["NPC"],
--                 ["value"] = "npc",
--                 ["onClick"] = function()
--                     widget.func("npc")
--                 end,
--             },
--         })

--         widget.showOnText = widget:CreateFontString(nil, "OVERLAY", font_name)
--         widget.showOnText:SetText(L["Show On"])
--         widget.showOnText:SetPoint("BOTTOMLEFT", widget.showOn, "TOPLEFT", 0, 1)

--         -- callback
--         function widget:SetFunc(func)
--             widget.func = func
--         end

--         -- show db value
--         function widget:SetDBValue(showOn)
--             widget.showOn:SetSelectedValue(showOn)
--         end
--     else
--         widget = settingWidgets["showOn"]
--     end

--     widget:Show()
--     return widget
-- end

local function CreateSetting_MaxValue(parent)
    local widget

    if not settingWidgets["maxValue"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_MaxValue", parent, 240, 80)
        settingWidgets["maxValue"] = widget

        widget.cb = Cell.CreateCheckButton(widget, L["Set Bar Max Value"], function(checked)
            Cell.SetEnabled(checked, widget.maxValue, widget.secText, widget.allowSmaller)
            widget.func({checked, tonumber(widget.maxValue:GetText()) or 0, widget.allowSmaller:GetChecked()})
        end)
        widget.cb:SetPoint("TOPLEFT", 5, -8)

        widget.maxValue = Cell.CreateEditBox(widget, 50, 20, nil, nil, true)
        widget.maxValue:SetPoint("TOPLEFT", widget.cb, "BOTTOMLEFT", 0, -8)
        widget.maxValue:SetMaxLetters(3)
        widget.maxValue:AddConfirmButton(function()
            local value = tonumber(widget.maxValue:GetText()) or 0
            widget.maxValue:SetText(value)
            widget.func({widget.cb:GetChecked(), value, widget.allowSmaller:GetChecked()})
        end, "number")

        widget.secText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.secText:SetPoint("LEFT", widget.maxValue, "RIGHT", 5, 0)
        widget.secText:SetText(L["sec"])

        widget.allowSmaller = Cell.CreateCheckButton(widget, L["Allow smaller value"], function(checked)
            widget.func({widget.cb:GetChecked(), tonumber(widget.maxValue:GetText()) or 0, checked})
        end)
        widget.allowSmaller:SetPoint("TOPLEFT", widget.maxValue, "BOTTOMLEFT", 0, -8)

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(maxValue)
            widget.cb:SetChecked(maxValue[1])
            widget.maxValue:SetText(maxValue[2])
            widget.allowSmaller:SetChecked(maxValue[3])
            Cell.SetEnabled(maxValue[1], widget.maxValue, widget.secText, widget.allowSmaller)
        end
    else
        widget = settingWidgets["maxValue"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_IconStyle(parent)
    local widget

    if not settingWidgets["iconStyle"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_IconStyle", parent, 240, 50)
        settingWidgets["iconStyle"] = widget

        widget.iconStyle = Cell.CreateDropdown(widget, 245)
        widget.iconStyle:SetPoint("TOPLEFT", 5, -20)

        -- dispels
        do
            local dispels = {
                {
                    ["text"] = L["None"],
                    ["value"] = "none",
                    ["onClick"] = function()
                        widget.func("none")
                    end,
                },
                {
                    -- ["text"] = "blizzard",
                    ["value"] = "blizzard",
                    ["onClick"] = function()
                        widget.func("blizzard")
                    end,
                },
                {
                    -- ["text"] = "rhombus",
                    ["value"] = "rhombus",
                    ["onClick"] = function()
                        widget.func("rhombus")
                    end,
                },
            }
            widget.dispels = dispels

            local types = {"Magic", "Curse", "Disease", "Poison", "Bleed"}

            -- blizzard
            local blizzard = ""
            local blizzard_icon = "|TInterface\\AddOns\\Cell\\Media\\Debuffs\\%s:0|t"

            -- rhombus
            local rhombus = ""
            local rhombus_icon = "|TInterface\\AddOns\\Cell\\Media\\Debuffs\\Rhombus:0:0:0:0:16:16:0:16:0:16:%s:%s:%s|t"

            for _, t in pairs(types) do
                blizzard = blizzard .. blizzard_icon:format(t) .. " "

                local r, g, b = F.ConvertRGB_256(I.GetDebuffTypeColor(t))
                rhombus = rhombus .. rhombus_icon:format(r, g, b) .. " "
            end

            dispels[2].text = blizzard
            dispels[3].text = rhombus
        end

        widget.iconStyleText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.iconStyleText:SetText(L["Icon Style"])
        widget.iconStyleText:SetPoint("BOTTOMLEFT", widget.iconStyle, "TOPLEFT", 0, 1)

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(iconStyle, indicatorName)
            widget.iconStyle:SetItems(widget[indicatorName])
            widget.iconStyle:SetSelectedValue(iconStyle)
        end
    else
        widget = settingWidgets["iconStyle"]
    end

    widget:Show()
    return widget
end

local CLASS_ROLES = {
    ["DEATHKNIGHT"] = {"TANK", "DAMAGER"},
    ["DEMONHUNTER"] = {"TANK", "DAMAGER"},
    ["DRUID"] = {"TANK", "HEALER", "DAMAGER"},
    ["EVOKER"] = {"HEALER", "DAMAGER"},
    ["HUNTER"] = {"DAMAGER"},
    ["MAGE"] = {"DAMAGER"},
    ["MONK"] = {"TANK", "HEALER", "DAMAGER"},
    ["PALADIN"] = {"TANK", "HEALER", "DAMAGER"},
    ["PRIEST"] = {"HEALER", "DAMAGER"},
    ["ROGUE"] = {"DAMAGER"},
    ["SHAMAN"] = {"HEALER", "DAMAGER"},
    ["WARLOCK"] = {"DAMAGER"},
    ["WARRIOR"] = {"TANK", "DAMAGER"},
    ["PET"] = {"DAMAGER"},
    ["VEHICLE"] = {"DAMAGER"},
    ["NPC"] = {"DAMAGER"},
}

local function RoleFilter_UpdateButton(b, enabled)
    b.tex:SetDesaturated(not enabled)
    if enabled then
        b:SetBackdropColor(unpack(b.hoverColor))
        b:SetScript("OnEnter", nil)
        b:SetScript("OnLeave", nil)
    else
        b:SetBackdropColor(unpack(b.color))
        b:SetScript("OnEnter", function()
            b:SetBackdropColor(unpack(b.hoverColor))
        end)
        b:SetScript("OnLeave", function()
            b:SetBackdropColor(unpack(b.color))
        end)
    end
end


local function CreateRoleFilter(parent, class, roles)
    local filter = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    Cell.StylizeFrame(filter)
    P.Size(filter, 170, 20)

    filter.text = filter:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    filter.text:SetPoint("LEFT", 5, 0)
    if class == "VEHICLE" or class == "PET" or class == "NPC" then
        filter.text:SetText("|cff00ff33"..L[class])
    else
        filter.text:SetText(F.GetClassColorStr(class)..F.GetLocalizedClassName(class))
    end

    filter.buttons = {}
    local last
    for i = #roles, 1, -1 do
        local b = Cell.CreateButton(filter, nil, "accent-hover", {20, 20})
        filter.buttons[roles[i]] = b
        b:SetTexture(F.GetDefaultRoleIcon(roles[i]), {16, 16}, {"CENTER", 0, 0})

        if last then
            b:SetPoint("BOTTOMRIGHT", last, "BOTTOMLEFT", P.Scale(1), 0)
        else
            b:SetPoint("BOTTOMRIGHT", filter)
        end
        last = b

        b:SetScript("OnClick", function()
            local settingsTable = parent.settingsTable
            local enabled
            if type(settingsTable[class]) == "boolean" then
                settingsTable[class] = not settingsTable[class]
                enabled = settingsTable[class]
            else
                settingsTable[class][roles[i]] = not settingsTable[class][roles[i]]
                enabled = settingsTable[class][roles[i]]
            end
            RoleFilter_UpdateButton(b, enabled)
            parent.func() -- fire
        end)
    end

    function filter:Load(t)
        if type(t) == "boolean" then
            RoleFilter_UpdateButton(filter.buttons["DAMAGER"], t)
        else
            for role, b in pairs(filter.buttons) do
                RoleFilter_UpdateButton(b, t[role])
            end
        end
    end

    return filter
end

local function CreateSetting_RoleFilters(parent)
    local widget

    if not settingWidgets["roleFilters"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_RoleFilters", parent, 240, 50)
        settingWidgets["roleFilters"] = widget

        -- filters
        widget.filters = {}

        local last
        for class in F.IterateClasses() do
            widget.filters[class] = CreateRoleFilter(widget, class, Cell.isVanilla and {"TANK", "HEALER", "DAMAGER"} or CLASS_ROLES[class])
            if last then
                widget.filters[class]:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -5)
            else
                widget.filters[class]:SetPoint("TOPLEFT", 5, -5)
            end
            last = widget.filters[class]
        end

        for _, class in pairs({"PET", "VEHICLE", "NPC"}) do
            widget.filters[class] = CreateRoleFilter(widget, class, CLASS_ROLES[class])
            widget.filters[class]:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -5)
            last = widget.filters[class]
        end

        local n = F.Getn(widget.filters)
        P.Height(widget, 10 + 20 * n + 5 * (n - 1))

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(settings)
            widget.settingsTable = settings
            for class, filter in pairs(widget.filters) do
                filter:Load(settings[class])
            end
        end
    else
        widget = settingWidgets["roleFilters"]
    end

    widget:Show()
    return widget
end

local function ClassFilter_UpdateButton(b, enabled)
    b.tex:SetDesaturated(not enabled)
    if enabled then
        b.fs:SetTextColor(unpack(b.classColor))
    else
        b.fs:SetTextColor(0.4, 0.4, 0.4)
    end
end

local function CreateClassFilter(parent, class)
    local filter = Cell.CreateButton(parent, class, "accent-hover", {120, 20})
    filter:SetTexture("classicon-"..strlower(class), {16, 16}, {"LEFT", 2, 0}, true, true)


    if class == "VEHICLE" or class == "PET" or class == "NPC" then
        filter.classColor = {0, 1, 0.2}
        filter:SetText(L[class])
    else
        filter.classColor = {F.GetClassColor(class)}
        filter:SetText(F.GetLocalizedClassName(class))
    end

    filter:SetScript("OnClick", function()
        local settingsTable = parent.settingsTable
        settingsTable[class] = not settingsTable[class]
        ClassFilter_UpdateButton(filter, settingsTable[class])
        parent.func() -- fire
    end)

    function filter:Load(enabled)
        ClassFilter_UpdateButton(filter, enabled)
    end

    return filter
end

local function CreateSetting_ClassFilters(parent)
    local widget

    if not settingWidgets["classFilters"] then
        widget = Cell.CreateFrame("CellIndicatorSettings_ClassFilters", parent, 240, 50)
        settingWidgets["classFilters"] = widget

        -- filters
        widget.filters = {}

        local classes = {}
        for class in F.IterateClasses() do
            tinsert(classes, class)
        end
        tinsert(classes, "PET")
        tinsert(classes, "VEHICLE")
        tinsert(classes, "NPC")

        local i, last, lastRow = 1
        for _, class in pairs(classes) do
            widget.filters[class] = CreateClassFilter(widget, class)
            if last then
                if i % 2 == 1 then
                    widget.filters[class]:SetPoint("TOPLEFT", lastRow, "BOTTOMLEFT", 0, -5)
                    lastRow = widget.filters[class]
                else
                    widget.filters[class]:SetPoint("TOPLEFT", last, "TOPRIGHT", 5, 0)
                end
            else
                widget.filters[class]:SetPoint("TOPLEFT", 5, -5)
                lastRow = widget.filters[class]
            end
            i = i + 1
            last = widget.filters[class]
        end

        local n = ceil(F.Getn(widget.filters) / 2)
        P.Height(widget, 10 + 20 * n + 5 * (n - 1))

        -- callback
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(settings)
            widget.settingsTable = settings
            for class, filter in pairs(widget.filters) do
                filter:Load(settings[class])
            end
        end
    else
        widget = settingWidgets["classFilters"]
    end

    widget:Show()
    return widget
end

-----------------------------------------
-- update parent height
-----------------------------------------
local settingsParent
function Cell.UpdateIndicatorSettingsHeight()
    local count, height = 0, 0
    for _, w in pairs(settingWidgets) do
        if w:IsShown() then
            count = count + 1
            height = height + w:GetHeight()
        end
    end
    settingsParent:SetHeight(height + (count-1)*P.Scale(10))
end

-----------------------------------------
-- create
-----------------------------------------
local builders = {
    ["enabled"] = CreateSetting_Enabled,
    ["vehicleNamePosition"] = CreateSetting_VehicleNamePosition,
    ["statusPosition"] = CreateSetting_StatusPosition,
    ["shieldBarPosition"] = CreateSetting_ShieldBarPosition,
    ["anchor"] = CreateSetting_Anchor,
    ["size"] = CreateSetting_Size,
    ["size-normal-big"] = CreateSetting_SizeNormalBig,
    ["size-square"] = CreateSetting_SizeSquare,
    -- ["size-bar"] = CreateSetting_SizeBar,
    ["size-border"] = CreateSetting_SizeAndBorder,
    ["spacing"] = CreateSetting_Spacing,
    ["thickness"] = CreateSetting_Thickness,
    ["height"] = CreateSetting_Height,
    ["textWidth"] = CreateSetting_TextWidth,
    ["alpha"] = CreateSetting_Alpha,
    ["healthFormat"] = CreateSetting_HealthFormat,
    ["powerFormat"] = CreateSetting_PowerFormat,
    ["durationVisibility"] = CreateSetting_DurationVisibility,
    ["orientation"] = CreateSetting_Orientation,
    ["barOrientation"] = CreateSetting_BarOrientation,
    ["font-noOffset"] = CreateSetting_FontNoOffset,
    ["color"] = CreateSetting_Color,
    ["color-alpha"] = CreateSetting_ColorAlpha,
    ["colors"] = CreateSetting_Colors,
    ["blockColors"] = CreateSetting_BlockColors,
    ["overlayColors"] = CreateSetting_OverlayColors,
    ["customColors"] = CreateSetting_CustomColors,
    ["color-class"] = CreateSetting_ClassColor,
    ["color-power"] = CreateSetting_PowerColor,
    ["statusColors"] = CreateSetting_StatusColors,
    ["duration"] = CreateSetting_Duration,
    ["stack"] = CreateSetting_Stack,
    ["roleTexture"] = CreateSetting_RoleTexture,
    ["glow"] = CreateSetting_Glow,
    ["glowOptions"] = CreateSetting_Glow,
    ["targetedSpellsGlow"] = CreateSetting_Glow,
    ["texture"] = CreateSetting_Texture,
    ["builtInAoEHealings"] = CreateSetting_BuiltIns,
    ["builtInDefensives"] = CreateSetting_BuiltIns,
    ["builtInExternals"] = CreateSetting_BuiltIns,
    ["builtInCrowdControls"] = CreateSetting_BuiltIns,
    ["actionsPreview"] = CreateSetting_ActionsPreview,
    ["actionsList"] = CreateSetting_ActionsList,
    ["highlightType"] = CreateSetting_HighlightType,
    ["thresholds"] = CreateSetting_Thresholds,
    ["privateAuraOptions"] = CreateSetting_PrivateAuraOptions,
    ["shape"] = CreateSetting_Shape,
    ["missingBuffsFilters"] = CreateSetting_MissingBuffsFilters,
    ["targetCounterFilters"] = CreateSetting_TargetCounterFilters,
    ["dispelFilters"] = CreateSetting_DispelFilters,
    ["castBy"] = CreateSetting_CastBy,
    -- ["showOn"] = CreateSetting_ShowOn,
    ["maxValue"] = CreateSetting_MaxValue,
    ["iconStyle"] = CreateSetting_IconStyle,
    ["powerTextFilters"] = CreateSetting_RoleFilters,
}

function Cell.CreateIndicatorSettings(parent, settingsTable)
    settingsParent = parent

    local widgetsTable = {}

    -- hide all
    for _, w in pairs(settingWidgets) do
        w:Hide()
        w:ClearAllPoints()
    end

    -- return and show
    for _, setting in pairs(settingsTable) do
        if builders[setting] then
            tinsert(widgetsTable, builders[setting](parent))
        elseif setting == "position" then
            tinsert(widgetsTable, CreateSetting_Position(parent))
        elseif setting == "position-noHCenter" then
            tinsert(widgetsTable, CreateSetting_PositionNoHCenter(parent))
        elseif strfind(setting, "^frameLevel") then
            tinsert(widgetsTable, CreateSetting_FrameLevel(parent))
        elseif string.find(setting, "^num:") then
            tinsert(widgetsTable, CreateSetting_Num(parent))
        elseif string.find(setting, "^numPerLine:") then
            tinsert(widgetsTable, CreateSetting_NumPerLine(parent))
        elseif string.find(setting, "^font") then
            tinsert(widgetsTable, CreateSetting_Font(parent, string.match(setting, "^(font%d?):?.*$")))
        elseif string.find(setting, "^checkbutton4") then
            tinsert(widgetsTable, CreateSetting_CheckButton4(parent))
        elseif string.find(setting, "^checkbutton3") then
            tinsert(widgetsTable, CreateSetting_CheckButton3(parent))
        elseif string.find(setting, "^checkbutton2") then
            tinsert(widgetsTable, CreateSetting_CheckButton2(parent))
        elseif string.find(setting, "^checkbutton") then
            tinsert(widgetsTable, CreateSetting_CheckButton(parent))
        elseif setting == "auras" or setting == "debuffBlacklist" or setting == "dispelBlacklist" or setting == "targetedSpellsList"
        or setting == "customAoEHealings" or setting == "customDefensives" or setting == "customExternals" or setting == "customCrowdControls" then
            tinsert(widgetsTable, CreateSetting_Auras(parent, 1))
        elseif setting == "auras2" or setting == "bigDebuffs" then
            tinsert(widgetsTable, CreateSetting_Auras(parent, 2))
        -- elseif setting == "cleuAuras" then
        --     tinsert(widgetsTable, CreateSetting_CleuAuras(parent))
        else -- tips
            tinsert(widgetsTable, CreateSetting_Tips(parent, setting))
        end
    end

    return widgetsTable
end