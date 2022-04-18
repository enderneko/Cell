local addonName, addon = ...
local L = addon.L
local F = addon.funcs
local P = addon.pixelPerfectFuncs

-----------------------------------------
-- Color
-----------------------------------------
local colors = {
    grey = {s="|cFFB2B2B2", t={.7, .7, .7}},
    yellow = {s="|cFFFFD100", t= {1, .82, 0}},
    orange = {s="|cFFFFC0CB", t= {1, .65, 0}},
    firebrick = {s="|cFFFF3030", t={1, .19, .19}},
    skyblue = {s="|cFF00CCFF", t={0, .8, 1}},
    chartreuse = {s="|cFF80FF00", t={.5, 1, 0}},
}

local class = select(2, UnitClass("player"))
local classColor = {s="|cCCB2B2B2", t={.7, .7, .7}}
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
        widget = addon:CreateFrame("CellIndicatorSettings_Enabled", parent, 240, 30)
        settingWidgets["enabled"] = widget

        widget.cb = addon:CreateCheckButton(widget, L["Enabled"])
        widget.cb:SetPoint("TOPLEFT", 5, -8)

        -- associate db
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

local points = {"BOTTOM", "BOTTOMLEFT", "BOTTOMRIGHT", "CENTER", "LEFT", "RIGHT", "TOP", "TOPLEFT", "TOPRIGHT"}
local function CreateSetting_Position(parent, relativeToText)
    local widget

    if not settingWidgets["position"] then
        widget = addon:CreateFrame("CellIndicatorSettings_Position", parent, 240, 95)
        settingWidgets["position"] = widget

        widget.anchor = addon:CreateDropdown(widget, 110)
        widget.anchor:SetPoint("TOPLEFT", 5, -20)
        local items = {}
        for _, point in pairs(points) do
            tinsert(items, {
                ["text"] = L[point],
                ["value"] = point,
                ["onClick"] = function()
                    widget.func({point, widget.relativeTo:GetSelected(), widget.x:GetValue(), widget.y:GetValue()})
                end,
            })
        end
        widget.anchor:SetItems(items)

        widget.anchorText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.anchorText:SetText(L["Anchor Point"])
        widget.anchorText:SetPoint("BOTTOMLEFT", widget.anchor, "TOPLEFT", 0, 1)

        widget.relativeTo = addon:CreateDropdown(widget, 110)
        widget.relativeTo:SetPoint("LEFT", widget.anchor, "RIGHT", 25, 0)
        items = {}
        for _, point in pairs(points) do
            tinsert(items, {
                ["text"] = L[point],
                ["value"] = point,
                ["onClick"] = function()
                    widget.func({widget.anchor:GetSelected(), point, widget.x:GetValue(), widget.y:GetValue()})
                end,
            })
        end
        widget.relativeTo:SetItems(items)

        widget.relativeToText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.relativeToText:SetText(L["To UnitButton's"])
        widget.relativeToText:SetPoint("BOTTOMLEFT", widget.relativeTo, "TOPLEFT", 0, 1)
        
        widget.x = addon:CreateSlider(L["X Offset"], widget, -100, 100, 110, 1)
        widget.x:SetPoint("TOPLEFT", widget.anchor, "BOTTOMLEFT", 0, -25)
        widget.x.afterValueChangedFn = function(value)
            widget.func({widget.anchor:GetSelected(), widget.relativeTo:GetSelected(), value, widget.y:GetValue()})
        end
        
        widget.y = addon:CreateSlider(L["Y Offset"], widget, -100, 100, 110, 1)
        widget.y:SetPoint("TOPLEFT", widget.relativeTo, "BOTTOMLEFT", 0, -25)
        widget.y.afterValueChangedFn = function(value)
            widget.func({widget.anchor:GetSelected(), widget.relativeTo:GetSelected(), widget.x:GetValue(), value})
        end
        
        -- associate db
        function widget:SetFunc(func)
            widget.func = func
        end
        
        -- show db value
        function widget:SetDBValue(positionTable)
            widget.anchor:SetSelected(L[positionTable[1]])
            widget.relativeTo:SetSelected(L[positionTable[2]])
            widget.x:SetValue(positionTable[3])
            widget.y:SetValue(positionTable[4])
        end
    else
        widget = settingWidgets["position"]
    end
    
    widget.relativeToText:SetText(relativeToText)
    widget:Show()
    return widget
end

local function CreateSetting_Anchor(parent)
    local widget

    if not settingWidgets["anchor"] then
        widget = addon:CreateFrame("CellIndicatorSettings_Anchor", parent, 240, 50)
        settingWidgets["anchor"] = widget

        widget.anchor = addon:CreateDropdown(widget, 170)
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

        -- associate db
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
        widget = addon:CreateFrame("CellIndicatorSettings_FrameLevel", parent, 240, 50)
        settingWidgets["frameLevel"] = widget

        widget.frameLevel = addon:CreateSlider(L["Frame Level"], widget, 1, 100, 110, 1)
        widget.frameLevel:SetPoint("TOPLEFT", widget, 5, -20)
        widget.frameLevel.afterValueChangedFn = function(value)
            widget.func(value)
        end
        
        -- associate db
        function widget:SetFunc(func)
            widget.func = func
        end
        
        -- show db value
        function widget:SetDBValue(frameLevel)
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
        widget = addon:CreateFrame("CellIndicatorSettings_Size", parent, 240, 50)
        settingWidgets["size"] = widget

        widget.width = addon:CreateSlider(L["Width"], widget, 1, 64, 110, 1)
        widget.width:SetPoint("TOPLEFT", widget, 5, -20)
        widget.width.afterValueChangedFn = function(value)
            widget.func({value, widget.height:GetValue()})
        end
        
        widget.height = addon:CreateSlider(L["Height"], widget, 1, 64, 110, 1)
        widget.height:SetPoint("LEFT", widget.width, "RIGHT", 25, 0)
        widget.height.afterValueChangedFn = function(value)
            widget.func({widget.width:GetValue(), value})
        end

        -- associate db
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

local function CreateSetting_SizeBar(parent)
    local widget

    if not settingWidgets["size-bar"] then
        widget = addon:CreateFrame("CellIndicatorSettings_Size", parent, 240, 50)
        settingWidgets["size-bar"] = widget

        widget.width = addon:CreateSlider(L["Width"], widget, 10, 300, 110, 1)
        widget.width:SetPoint("TOPLEFT", widget, 5, -20)
        widget.width.afterValueChangedFn = function(value)
            widget.func({value, widget.height:GetValue()})
        end
        
        widget.height = addon:CreateSlider(L["Height"], widget, 1, 50, 110, 1)
        widget.height:SetPoint("LEFT", widget.width, "RIGHT", 25, 0)
        widget.height.afterValueChangedFn = function(value)
            widget.func({widget.width:GetValue(), value})
        end

        -- associate db
        function widget:SetFunc(func)
            widget.func = func
        end
        
        -- show db value
        function widget:SetDBValue(sizeTable)
            widget.width:SetValue(sizeTable[1])
            widget.height:SetValue(sizeTable[2])
        end
    else
        widget = settingWidgets["size-bar"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_SizeSquare(parent)
    local widget

    if not settingWidgets["size-square"] then
        widget = addon:CreateFrame("CellIndicatorSettings_SizeSquare", parent, 240, 50)
        settingWidgets["size-square"] = widget

        widget.size = addon:CreateSlider(L["Size"], widget, 1, 64, 110, 1)
        widget.size:SetPoint("TOPLEFT", widget, 5, -20)
        widget.size.afterValueChangedFn = function(value)
            widget.func({value, value})
        end
        
        -- associate db
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

local function CreateSetting_Thickness(parent)
    local widget

    if not settingWidgets["thickness"] then
        widget = addon:CreateFrame("CellIndicatorSettings_Thickness", parent, 240, 50)
        settingWidgets["thickness"] = widget

        widget.size = addon:CreateSlider(L["Size"], widget, 2, 12, 110, 1)
        widget.size:SetPoint("TOPLEFT", widget, 5, -20)
        widget.size.afterValueChangedFn = function(value)
            widget.func(value)
        end
        
        -- associate db
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
        widget = addon:CreateFrame("CellIndicatorSettings_SizeNormalBig", parent, 240, 50)
        settingWidgets["size-normal-big"] = widget

        widget.sizeNormal = addon:CreateSlider(L["Size"], widget, 1, 64, 110, 1)
        widget.sizeNormal:SetPoint("TOPLEFT", widget, 5, -20)
        widget.sizeNormal.afterValueChangedFn = function(value)
            widget.func({{value, value}, {widget.sizeBig:GetValue(), widget.sizeBig:GetValue()}})
        end

        widget.sizeBig = addon:CreateSlider(L["Size (Big)"], widget, 1, 64, 110, 1)
        widget.sizeBig:SetPoint("LEFT", widget.sizeNormal, "RIGHT", 25, 0)
        widget.sizeBig.afterValueChangedFn = function(value)
            widget.func({{widget.sizeNormal:GetValue(), widget.sizeNormal:GetValue()}, {value, value}})
        end
        
        -- associate db
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
        widget = addon:CreateFrame("CellIndicatorSettings_SizeAndBorder", parent, 240, 50)
        settingWidgets["size-border"] = widget

        widget.size = addon:CreateSlider(L["Size"], widget, 1, 64, 110, 1)
        widget.size:SetPoint("TOPLEFT", widget, 5, -20)
        widget.size.afterValueChangedFn = function(value)
            widget.func({value, value, widget.border:GetValue()})
        end

        widget.border = addon:CreateSlider(L["Border"], widget, 1, 10, 110, 1)
        widget.border:SetPoint("LEFT", widget.size, "RIGHT", 25, 0)
        widget.border.afterValueChangedFn = function(value)
            widget.func({widget.size:GetValue(), widget.size:GetValue(), value})
        end
        
        -- associate db
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
        widget = addon:CreateFrame("CellIndicatorSettings_Height", parent, 240, 50)
        settingWidgets["height"] = widget

        widget.height = addon:CreateSlider(L["Height"], widget, 1, 70, 110, 1)
        widget.height:SetPoint("TOPLEFT", widget, 5, -20)
        widget.height.afterValueChangedFn = function(value)
            widget.func(value)
        end
        
        -- associate db
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
        widget = addon:CreateFrame("CellIndicatorSettings_TextWidth", parent, 240, 50)
        settingWidgets["textWidth"] = widget

        widget.textWidth = addon:CreateDropdown(widget, 110)
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
                    widget.length:SetText(5)
                    widget.length:Show()
                    widget.percent:Hide()
                    widget.lengthValue = 5
                    
                    if F:IsAsian() then
                        widget.length2:SetText(5)
                        widget.length2:Show()
                        widget.func({"length", 5, 5})
                        widget.lengthValue2 = 5
                    else
                        widget.func({"length", 5})
                    end
                end,
            },
        })

        widget.percent = addon:CreateDropdown(widget, 75)
        widget.percent:SetPoint("TOPLEFT", widget.textWidth, "TOPRIGHT", 25, 0)
        addon:SetTooltips(widget.percent.button, "ANCHOR_TOP", 0, 3, L["Name Width / UnitButton Width"])
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

        widget.length = addon:CreateEditBox(widget, 34, 20, false, false, true)
        widget.length:SetPoint("TOPLEFT", widget.textWidth, "TOPRIGHT", 25, 0)

        widget.length.confirmBtn = addon:CreateButton(widget.length, "OK", "class", {27, 20})
        widget.length.confirmBtn:SetPoint("TOPLEFT", widget.length, "TOPRIGHT", -1, 0)
        widget.length.confirmBtn:Hide()
        widget.length.confirmBtn:SetScript("OnHide", function()
            widget.length.confirmBtn:Hide()
        end)
        widget.length.confirmBtn:SetScript("OnClick", function()
            local length = tonumber(widget.length:GetText())
            widget.length:SetText(length)
            widget.length.confirmBtn:Hide()
            widget.lengthValue = length
            
            if F:IsAsian() then
                widget.func({"length", length, tonumber(widget.length2:GetText()) or widget.lengthValue2})
            else
                widget.func({"length", length})
            end
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

        -- for Chinese/Korean clients, additional english name length
        widget.length2 = addon:CreateEditBox(widget, 33, 20, false, false, true)
        widget.length2:SetPoint("TOPLEFT", widget.length, "TOPRIGHT", 25, 0)

        if F:IsAsian() then
            widget.nonEnText = widget.length:CreateFontString(nil, "OVERLAY", font_name)
            widget.nonEnText:SetText(L["NON-EN"])
            widget.nonEnText:SetPoint("BOTTOMLEFT", widget.length, "TOPLEFT", 0, 1)
            widget.enText = widget.length2:CreateFontString(nil, "OVERLAY", font_name)
            widget.enText:SetText(L["EN"])
            widget.enText:SetPoint("BOTTOMLEFT", widget.length2, "TOPLEFT", 0, 1)

            widget.length2.confirmBtn = addon:CreateButton(widget.length2, "OK", "class", {27, 20})
            widget.length2.confirmBtn:SetPoint("TOPLEFT", widget.length2, "TOPRIGHT", -1, 0)
            widget.length2.confirmBtn:Hide()
            widget.length2.confirmBtn:SetScript("OnHide", function()
                widget.length2.confirmBtn:Hide()
            end)
            widget.length2.confirmBtn:SetScript("OnClick", function()
                local length = tonumber(widget.length2:GetText())
                widget.length2:SetText(length)
                widget.length2.confirmBtn:Hide()
                widget.func({"length", tonumber(widget.length:GetText()) or widget.lengthValue, length})
                widget.lengthValue2 = length
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
        end

        widget.widthText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.widthText:SetText(L["Text Width"])
        widget.widthText:SetPoint("BOTTOMLEFT", widget.textWidth, "TOPLEFT", 0, 1)

        -- associate db
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
                widget.percent:Hide()

                if F:IsAsian() then
                    widget.lengthValue2 = width[3] or width[2]
                    widget.length2:SetText(width[3] or width[2])
                    widget.length2:Show()
                else
                    widget.length2:Hide()
                end
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
        widget = addon:CreateFrame("CellIndicatorSettings_Alpha", parent, 240, 50)
        settingWidgets["alpha"] = widget

        widget.alpha = addon:CreateSlider(L["Alpha"], widget, 0, 1, 110, .01)
        widget.alpha:SetPoint("TOPLEFT", widget, 5, -20)
        widget.alpha.afterValueChangedFn = function(value)
            widget.func(value)
        end
        
        -- associate db
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
        widget = addon:CreateFrame("CellIndicatorSettings_Num", parent, 240, 50)
        settingWidgets["num"] = widget

        widget.num = addon:CreateSlider(L["Max Icons"], widget, 1, 5, 110, 1)
        widget.num:SetPoint("TOPLEFT", 5, -20)
        widget.num.afterValueChangedFn = function(value)
            widget.func(value)
        end

        -- associate db
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

local function CreateSetting_Format(parent)
    local widget

    if not settingWidgets["format"] then
        widget = addon:CreateFrame("CellIndicatorSettings_Format", parent, 240, 50)
        settingWidgets["format"] = widget

        widget.format = addon:CreateDropdown(widget, 110)
        widget.format:SetPoint("TOPLEFT", 5, -20)
        widget.format:SetItems({
            {
                ["text"] = "32%",
                ["value"] = "percentage",
                ["onClick"] = function()
                    widget.func("percentage")
                end,
            },
            {
                ["text"] = "-67%",
                ["value"] = "percentage-deficit",
                ["onClick"] = function()
                    widget.func("percentage-deficit")
                end,
            },
            {
                ["text"] = "21377",
                ["value"] = "number",
                ["onClick"] = function()
                    widget.func("number")
                end,
            },
            {
                ["text"] = F:FormatNumber(21377),
                ["value"] = "number-short",
                ["onClick"] = function()
                    widget.func("number-short")
                end,
            },
            {
                ["text"] = "-44158",
                ["value"] = "number-deficit",
                ["onClick"] = function()
                    widget.func("number-deficit")
                end,
            },
            {
                ["text"] = F:FormatNumber(-44158),
                ["value"] = "number-deficit-short",
                ["onClick"] = function()
                    widget.func("number-deficit-short")
                end,
            },
        })

        widget.formatText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.formatText:SetText(L["Format"])
        widget.formatText:SetPoint("BOTTOMLEFT", widget.format, "TOPLEFT", 0, 1)

        -- associate db
        function widget:SetFunc(func)
            widget.func = func
        end
        
        -- show db value
        function widget:SetDBValue(format)
            widget.format:SetSelectedValue(format)
        end
    else
        widget = settingWidgets["format"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_Orientation(parent)
    local widget

    if not settingWidgets["orientation"] then
        widget = addon:CreateFrame("CellIndicatorSettings_Orientation", parent, 240, 50)
        settingWidgets["orientation"] = widget

        widget.orientation = addon:CreateDropdown(widget, 110)
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

        -- associate db
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

local function CreateSetting_VehicleNamePosition(parent)
    local widget

    if not settingWidgets["vehicleNamePosition"] then
        widget = addon:CreateFrame("CellIndicatorSettings_VehicleNamePosition", parent, 240, 50)
        settingWidgets["vehicleNamePosition"] = widget

        widget.position = addon:CreateDropdown(widget, 110)
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

        widget.yOffset = addon:CreateSlider(L["Y Offset"], widget, -50, 50, 110, 1)
        widget.yOffset:SetPoint("TOPLEFT", widget.position, "TOPRIGHT", 25, 0)
        widget.yOffset.afterValueChangedFn = function(value)
            widget.func({widget.position:GetSelected(), value})
        end

        -- associate db
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
        widget = addon:CreateFrame("CellIndicatorSettings_StatusPosition", parent, 240, 50)
        settingWidgets["statusPosition"] = widget

        widget.position = addon:CreateDropdown(widget, 110)
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
        })

        widget.positionText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.positionText:SetText(L["Status Text Position"])
        widget.positionText:SetPoint("BOTTOMLEFT", widget.position, "TOPLEFT", 0, 1)

        widget.yOffset = addon:CreateSlider(L["Y Offset"], widget, -50, 50, 110, 1)
        widget.yOffset:SetPoint("TOPLEFT", widget.position, "TOPRIGHT", 25, 0)
        widget.yOffset.afterValueChangedFn = function(value)
            widget.func({widget.position:GetSelected(), value})
        end

        -- associate db
        function widget:SetFunc(func)
            widget.func = func
        end
        
        -- show db value
        function widget:SetDBValue(pTable)
            widget.position:SetSelected(L[pTable[1]])
            widget.yOffset:SetValue(pTable[2])
        end
    else
        widget = settingWidgets["statusPosition"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_Font(parent)
    local widget

    if not settingWidgets["font"] then
        widget = addon:CreateFrame("CellIndicatorSettings_Font", parent, 240, 145)
        settingWidgets["font"] = widget

        widget.font = addon:CreateDropdown(widget, 110)
        widget.font:SetPoint("TOPLEFT", 5, -20)
        local items, fonts, defaultFontName, defaultFont = F:GetFontItems()
        for _, item in pairs(items) do
            item["onClick"] = function()
                widget.func({widget.font:GetSelected(), widget.fontSize:GetValue(), widget.outline:GetSelected(), widget.xOffset:GetValue(), widget.yOffset:GetValue()})
            end
        end
        widget.font:SetItems(items)

        widget.fontText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.fontText:SetText(L["Font"])
        widget.fontText:SetPoint("BOTTOMLEFT", widget.font, "TOPLEFT", 0, 1)

        widget.outline = addon:CreateDropdown(widget, 110)
        widget.outline:SetPoint("TOPLEFT", widget.font, "TOPRIGHT", 25, 0)
        widget.outline:SetItems({
            {
                ["text"] = L["None"],
                ["value"] = "None",
                ["onClick"] = function()
                    widget.func({widget.font:GetSelected(), widget.fontSize:GetValue(), widget.outline:GetSelected(), widget.xOffset:GetValue(), widget.yOffset:GetValue()})
                end,
            },
            {
                ["text"] = L["Shadow"],
                ["value"] = "Shadow",
                ["onClick"] = function()
                    widget.func({widget.font:GetSelected(), widget.fontSize:GetValue(), widget.outline:GetSelected(), widget.xOffset:GetValue(), widget.yOffset:GetValue()})
                end,
            },
            {
                ["text"] = L["Outline"],
                ["value"] = "Outline",
                ["onClick"] = function()
                    widget.func({widget.font:GetSelected(), widget.fontSize:GetValue(), widget.outline:GetSelected(), widget.xOffset:GetValue(), widget.yOffset:GetValue()})
                end,
            },
            {
                ["text"] = L["Monochrome Outline"],
                ["value"] = "Monochrome Outline",
                ["onClick"] = function()
                    widget.func({widget.font:GetSelected(), widget.fontSize:GetValue(), widget.outline:GetSelected(), widget.xOffset:GetValue(), widget.yOffset:GetValue()})
                end,
            },
        })

        widget.outlineText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.outlineText:SetText(L["Font Outline"])
        widget.outlineText:SetPoint("BOTTOMLEFT", widget.outline, "TOPLEFT", 0, 1)

        widget.fontSize = addon:CreateSlider(L["Font Size"], widget, 5, 30, 110, 1)
        widget.fontSize:SetPoint("TOPLEFT", widget.font, "BOTTOMLEFT", 0, -25)
        widget.fontSize.afterValueChangedFn = function(value)
            widget.func({widget.font:GetSelected(), value, widget.outline:GetSelected(), widget.xOffset:GetValue(), widget.yOffset:GetValue()})
        end

        widget.xOffset = addon:CreateSlider(L["X Offset"], widget, -10, 10, 110, 1)
        widget.xOffset:SetPoint("TOPLEFT", widget.fontSize, "BOTTOMLEFT", 0, -40)
        widget.xOffset.afterValueChangedFn = function(value)
            widget.func({widget.font:GetSelected(), widget.fontSize:GetValue(), widget.outline:GetSelected(), value, widget.yOffset:GetValue()})
        end
        
        widget.yOffset = addon:CreateSlider(L["Y Offset"], widget, -10, 10, 110, 1)
        widget.yOffset:SetPoint("TOPLEFT", widget.xOffset, "TOPRIGHT", 25, 0)
        widget.yOffset.afterValueChangedFn = function(value)
            widget.func({widget.font:GetSelected(), widget.fontSize:GetValue(), widget.outline:GetSelected(), widget.xOffset:GetValue(), value})
        end

        -- associate db
        function widget:SetFunc(func)
            widget.func = func
        end
        
        -- show db value
        function widget:SetDBValue(fontTable)
            widget.font:SetSelected(fontTable[1])
            widget.fontSize:SetValue(fontTable[2])
            widget.outline:SetSelected(L[fontTable[3]])
            widget.xOffset:SetValue(fontTable[4])
            widget.yOffset:SetValue(fontTable[5])
        end
    else
        widget = settingWidgets["font"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_FontNoOffset(parent)
    local widget

    if not settingWidgets["font-noOffset"] then
        widget = addon:CreateFrame("CellIndicatorSettings_FontNoOffset", parent, 240, 95)
        settingWidgets["font-noOffset"] = widget

        widget.font = addon:CreateDropdown(widget, 110)
        widget.font:SetPoint("TOPLEFT", 5, -20)
        local items, fonts, defaultFontName, defaultFont = F:GetFontItems()
        for _, item in pairs(items) do
            item["onClick"] = function()
                widget.func({widget.font:GetSelected(), widget.fontSize:GetValue(), widget.outline:GetSelected()})
            end
        end
        widget.font:SetItems(items)

        widget.fontText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.fontText:SetText(L["Font"])
        widget.fontText:SetPoint("BOTTOMLEFT", widget.font, "TOPLEFT", 0, 1)

        widget.outline = addon:CreateDropdown(widget, 110)
        widget.outline:SetPoint("LEFT", widget.font, "RIGHT", 25, 0)
        widget.outline:SetItems({
            {
                ["text"] = L["None"],
                ["value"] = "None",
                ["onClick"] = function()
                    widget.func({widget.font:GetSelected(), widget.fontSize:GetValue(), widget.outline:GetSelected()})
                end,
            },
            {
                ["text"] = L["Shadow"],
                ["value"] = "Shadow",
                ["onClick"] = function()
                    widget.func({widget.font:GetSelected(), widget.fontSize:GetValue(), widget.outline:GetSelected()})
                end,
            },
            {
                ["text"] = L["Outline"],
                ["value"] = "Outline",
                ["onClick"] = function()
                    widget.func({widget.font:GetSelected(), widget.fontSize:GetValue(), widget.outline:GetSelected()})
                end,
            },
            {
                ["text"] = L["Monochrome Outline"],
                ["value"] = "Monochrome Outline",
                ["onClick"] = function()
                    widget.func({widget.font:GetSelected(), widget.fontSize:GetValue(), widget.outline:GetSelected()})
                end,
            },
        })

        widget.outlineText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.outlineText:SetText(L["Font Outline"])
        widget.outlineText:SetPoint("BOTTOMLEFT", widget.outline, "TOPLEFT", 0, 1)

        widget.fontSize = addon:CreateSlider(L["Font Size"], widget, 5, 30, 110, 1)
        widget.fontSize:SetPoint("TOPLEFT", widget.font, "BOTTOMLEFT", 0, -25)
        widget.fontSize.afterValueChangedFn = function(value)
            widget.func({widget.font:GetSelected(), value, widget.outline:GetSelected()})
        end

        -- associate db
        function widget:SetFunc(func)
            widget.func = func
        end
        
        -- show db value
        function widget:SetDBValue(fontTable)
            widget.font:SetSelected(fontTable[1])
            widget.fontSize:SetValue(fontTable[2])
            widget.outline:SetSelected(L[fontTable[3]])
        end
    else
        widget = settingWidgets["font-noOffset"]
    end

    widget:Show()
    return widget
end

-- TODO: seems unnecessary now
-- local function CreateSetting_StackFont(parent)
--     local widget

--     if not settingWidgets["stackFont"] then
--         widget = addon:CreateFrame("CellIndicatorSettings_StackFont", parent, 240, 140)
--         settingWidgets["stackFont"] = widget

--         widget.Update = function()
--             widget.func({
--                 widget.font:GetSelected(),
--                 widget.fontSize:GetValue(),
--                 widget.outline:GetSelected(),
--                 widget.alignment:GetSelected(),
--                 widget.xOffset:GetValue(),
--                 widget.yOffset:GetValue()
--             })
--         end

--         -- font
--         widget.font = addon:CreateDropdown(widget, 110)
--         widget.font:SetPoint("TOPLEFT", 5, -20)
--         local items, fonts, defaultFontName, defaultFont = F:GetFontItems()
--         for _, item in pairs(items) do
--             item["onClick"] = widget.Update
--         end
--         widget.font:SetItems(items)

--         widget.fontText = widget:CreateFontString(nil, "OVERLAY", font_name)
--         widget.fontText:SetText(L["Font"])
--         widget.fontText:SetPoint("BOTTOMLEFT", widget.font, "TOPLEFT", 0, 1)

--         -- outline
--         widget.outline = addon:CreateDropdown(widget, 110)
--         widget.outline:SetPoint("TOPLEFT", widget.font, "TOPRIGHT", 25, 0)
--         widget.outline:SetItems({
--             {
--                 ["text"] = L["None"],
--                 ["value"] = "None",
--                 ["onClick"] = widget.Update
--             },
--             {
--                 ["text"] = L["Shadow"],
--                 ["value"] = "Shadow",
--                 ["onClick"] = widget.Update
--             },
--             {
--                 ["text"] = L["Outline"],
--                 ["value"] = "Outline",
--                 ["onClick"] = widget.Update
--             },
--             {
--                 ["text"] = L["Monochrome Outline"],
--                 ["value"] = "Monochrome Outline",
--                 ["onClick"] = widget.Update
--             },
--         })

--         widget.outlineText = widget:CreateFontString(nil, "OVERLAY", font_name)
--         widget.outlineText:SetText(L["Font Outline"])
--         widget.outlineText:SetPoint("BOTTOMLEFT", widget.outline, "TOPLEFT", 0, 1)

--         -- alignment
--         widget.alignment = addon:CreateDropdown(widget, 110)
--         widget.alignment:SetPoint("TOPLEFT", widget.font, "BOTTOMLEFT", 0, -25)
--         widget.alignment:SetItems({
--             {
--                 ["text"] = "Left",
--                 ["value"] = "LEFT",
--                 ["onClick"] = widget.Update
--             },
--             {
--                 ["text"] = "Right",
--                 ["value"] = "RIGHT",
--                 ["onClick"] = widget.Update
--             },
--             {
--                 ["text"] = "Center",
--                 ["value"] = "CENTER",
--                 ["onClick"] = widget.Update
--             },
--         })
        
--         widget.alignmentText = widget:CreateFontString(nil, "OVERLAY", font_name)
--         widget.alignmentText:SetText(L["Alignment"])
--         widget.alignmentText:SetPoint("BOTTOMLEFT", widget.alignment, "TOPLEFT", 0, 1)

--         -- size
--         widget.fontSize = addon:CreateSlider(L["Font Size"], widget, 5, 30, 110, 1)
--         widget.fontSize:SetPoint("TOPLEFT", widget.alignment, "TOPRIGHT", 25, 0)
--         widget.fontSize.afterValueChangedFn = widget.Update

--         -- x
--         widget.xOffset = addon:CreateSlider(L["X Offset"], widget, -50, 50, 110, 1)
--         widget.xOffset:SetPoint("TOPLEFT", widget.alignment, "BOTTOMLEFT", 0, -25)
--         widget.xOffset.afterValueChangedFn = widget.Update

--         -- y
--         widget.yOffset = addon:CreateSlider(L["Y Offset"], widget, -50, 50, 110, 1)
--         widget.yOffset:SetPoint("TOPLEFT", widget.xOffset, "TOPRIGHT", 25, 0)
--         widget.yOffset.afterValueChangedFn = widget.Update

--         -- associate db
--         function widget:SetFunc(func)
--             widget.func = func
--         end
        
--         -- show db value
--         function widget:SetDBValue(fontTable)
--             widget.font:SetSelected(fontTable[1])
--             widget.fontSize:SetValue(fontTable[2])
--             widget.outline:SetSelectedValue(fontTable[3])
--             widget.alignment:SetSelectedValue(fontTable[4])
--             widget.xOffset:SetValue(fontTable[5])
--             widget.yOffset:SetValue(fontTable[6])
--         end
--     else
--         widget = settingWidgets["stackFont"]
--     end

--     widget:Show()
--     return widget
-- end

-- local function CreateSetting_DurationFont(parent)
--     local widget

--     if not settingWidgets["font"] then
--         widget = addon:CreateFrame("CellIndicatorSettings_Font", parent, 240, 95)
--         settingWidgets["font"] = widget

--         widget.font = addon:CreateDropdown(widget, 110)
--         widget.font:SetPoint("TOPLEFT", 5, -20)
--         local items, fonts, defaultFontName, defaultFont = F:GetFontItems()
--         for _, item in pairs(items) do
--             item["onClick"] = function()
--                 widget.func({widget.font:GetSelected(), widget.fontSize:GetValue(), widget.outline:GetSelected(), widget.xOffset:GetValue()})
--             end
--         end
--         widget.font:SetItems(items)

--         widget.fontText = widget:CreateFontString(nil, "OVERLAY", font_name)
--         widget.fontText:SetText(L["Font"])
--         widget.fontText:SetPoint("BOTTOMLEFT", widget.font, "TOPLEFT", 0, 1)

--         widget.outline = addon:CreateDropdown(widget, 110)
--         widget.outline:SetPoint("LEFT", widget.font, "RIGHT", 25, 0)
--         widget.outline:SetItems({
--             {
--                 ["text"] = L["None"],
--                 ["value"] = "None",
--                 ["onClick"] = function()
--                     widget.func({widget.font:GetSelected(), widget.fontSize:GetValue(), widget.outline:GetSelected(), widget.xOffset:GetValue()})
--                 end,
--             },
--             {
--                 ["text"] = L["Shadow"],
--                 ["value"] = "Shadow",
--                 ["onClick"] = function()
--                     widget.func({widget.font:GetSelected(), widget.fontSize:GetValue(), widget.outline:GetSelected(), widget.xOffset:GetValue()})
--                 end,
--             },
--             {
--                 ["text"] = L["Outline"],
--                 ["value"] = "Outline",
--                 ["onClick"] = function()
--                     widget.func({widget.font:GetSelected(), widget.fontSize:GetValue(), widget.outline:GetSelected(), widget.xOffset:GetValue()})
--                 end,
--             },
--             {
--                 ["text"] = L["Monochrome Outline"],
--                 ["value"] = "Monochrome Outline",
--                 ["onClick"] = function()
--                     widget.func({widget.font:GetSelected(), widget.fontSize:GetValue(), widget.outline:GetSelected(), widget.xOffset:GetValue()})
--                 end,
--             },
--         })

--         widget.outlineText = widget:CreateFontString(nil, "OVERLAY", font_name)
--         widget.outlineText:SetText(L["Font Outline"])
--         widget.outlineText:SetPoint("BOTTOMLEFT", widget.outline, "TOPLEFT", 0, 1)

--         widget.fontSize = addon:CreateSlider(L["Font Size"], widget, 5, 30, 110, 1)
--         widget.fontSize:SetPoint("TOPLEFT", widget.font, "BOTTOMLEFT", 0, -25)
--         widget.fontSize.afterValueChangedFn = function(value)
--             widget.func({widget.font:GetSelected(), value, widget.outline:GetSelected(), widget.xOffset:GetValue()})
--         end

--         widget.xOffset = addon:CreateSlider(L["X Offset"], widget, -50, 50, 110, 1)
--         widget.xOffset:SetPoint("TOPLEFT", widget.outline, "BOTTOMLEFT", 0, -25)
--         widget.xOffset.afterValueChangedFn = function(value)
--             widget.func({widget.font:GetSelected(), widget.fontSize:GetValue(), widget.outline:GetSelected(), value})
--         end

--         -- associate db
--         function widget:SetFunc(func)
--             widget.func = func
--         end
        
--         -- show db value
--         function widget:SetDBValue(fontTable)
--             widget.font:SetSelected(fontTable[1])
--             widget.fontSize:SetValue(fontTable[2])
--             widget.outline:SetSelected(L[fontTable[3]])
--             widget.xOffset:SetValue(fontTable[4])
--         end
--     else
--         widget = settingWidgets["font"]
--     end

--     widget:Show()
--     return widget
-- end

local function CreateSetting_Color(parent)
    local widget

    if not settingWidgets["color"] then
        widget = addon:CreateFrame("CellIndicatorSettings_Color", parent, 240, 30)
        settingWidgets["color"] = widget

        local colorPicker = addon:CreateColorPicker(widget, L["Color"], false, function(r, g, b, a)
            widget.colorTable[1] = r
            widget.colorTable[2] = g 
            widget.colorTable[3] = b
            widget.func(widget.colorTable)
        end)
        colorPicker:SetPoint("TOPLEFT", 5, -8)

        -- associate db
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
        widget = addon:CreateFrame("CellIndicatorSettings_ColorAlpha", parent, 240, 30)
        settingWidgets["color-alpha"] = widget

        local colorPicker = addon:CreateColorPicker(widget, L["Color"], true, function(r, g, b, a)
            widget.colorTable[1] = r
            widget.colorTable[2] = g 
            widget.colorTable[3] = b
            widget.colorTable[4] = a
            widget.func(widget.colorTable)
        end)
        colorPicker:SetPoint("TOPLEFT", 5, -8)

        -- associate db
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
        widget = addon:CreateFrame("CellIndicatorSettings_Colors", parent, 240, 72)
        settingWidgets["colors"] = widget

        local normalColor = addon:CreateColorPicker(widget, L["Normal"], false, function(r, g, b)
            widget.colorsTable[1][1] = r
            widget.colorsTable[1][2] = g 
            widget.colorsTable[1][3] = b
            -- widget.func(widget.colorsTable)
        end)
        normalColor:SetPoint("TOPLEFT", 5, -8)
        
        local percentColor = addon:CreateColorPicker(widget, L["Remaining Time <"], false, function(r, g, b)
            widget.colorsTable[2][1] = r
            widget.colorsTable[2][2] = g 
            widget.colorsTable[2][3] = b
            -- widget.func(widget.colorsTable)
        end)
        percentColor:SetPoint("TOPLEFT", normalColor, "BOTTOMLEFT", 0, -8)
        
        local secColor = addon:CreateColorPicker(widget, L["Remaining Time <"], false, function(r, g, b)
            widget.colorsTable[3][1] = r
            widget.colorsTable[3][2] = g 
            widget.colorsTable[3][3] = b
            -- widget.func(widget.colorsTable)
        end)
        secColor:SetPoint("TOPLEFT", percentColor, "BOTTOMLEFT", 0, -8)

        local percentDropdown = addon:CreateDropdown(widget, 60)
        percentDropdown:SetPoint("LEFT", percentColor.label, "RIGHT", 5, 0)
        percentDropdown:SetItems({
            {
                ["text"] = "75%",
                ["onClick"] = function()
                    widget.colorsTable[2][4] = .75
                end,
            },
            {
                ["text"] = "50%",
                ["onClick"] = function()
                    widget.colorsTable[2][4] = .5
                end,
            },
            {
                ["text"] = "25%",
                ["onClick"] = function()
                    widget.colorsTable[2][4] = .25
                end,
            },
            {
                ["text"] = _G.NONE,
                ["onClick"] = function()
                    widget.colorsTable[2][4] = 0
                end,
            },
        })
        
        -- local secDropdown = addon:CreateDropdown(widget, 55)
        -- secDropdown:SetPoint("LEFT", secColor.label, "RIGHT", 5, 0)
        -- secDropdown:SetItems({
        -- 	{
        -- 		["text"] = "10 "..L["sec"],
        -- 		["onClick"] = function()
        -- 			widget.colorsTable[3][4] = 10
        -- 		end,
        -- 	},
        -- 	{
        -- 		["text"] = "7 "..L["sec"],
        -- 		["onClick"] = function()
        -- 			widget.colorsTable[3][4] = 7
        -- 		end,
        -- 	},
        -- 	{
        -- 		["text"] = "5 "..L["sec"],
        -- 		["onClick"] = function()
        -- 			widget.colorsTable[3][4] = 5
        -- 		end,
        -- 	},
        -- 	{
        -- 		["text"] = "3 "..L["sec"],
        -- 		["onClick"] = function()
        -- 			widget.colorsTable[3][4] = 3
        -- 		end,
        -- 	},
        -- 	{
        -- 		["text"] = _G.NONE,
        -- 		["onClick"] = function()
        -- 			widget.colorsTable[3][4] = 0
        -- 		end,
        -- 	},
        -- })

        local secEditBox = addon:CreateEditBox(widget, 43, 20, false, false, true)
        secEditBox:SetPoint("LEFT", secColor.label, "RIGHT", 5, 0)
        secEditBox:SetMaxLetters(4)
 
        secEditBox.confirmBtn = addon:CreateButton(widget, "OK", "class", {27, 20})
        secEditBox.confirmBtn:SetPoint("LEFT", secEditBox, "RIGHT", -1, 0)
        secEditBox.confirmBtn:Hide()
        secEditBox.confirmBtn:SetScript("OnHide", function()
            secEditBox.confirmBtn:Hide()
        end)
        secEditBox.confirmBtn:SetScript("OnClick", function()
            local newSec = tonumber(secEditBox:GetText())
            widget.colorsTable[3][4] = newSec
            secEditBox:SetText(newSec)
            secEditBox.confirmBtn:Hide()
        end)

        secEditBox:SetScript("OnTextChanged", function(self, userChanged)
            if userChanged then
                local newSec = tonumber(self:GetText())
                if newSec and newSec ~= widget.colorsTable[3][4] then
                    secEditBox.confirmBtn:Show()
                else
                    secEditBox.confirmBtn:Hide()
                end
            end
        end)

        local secText = widget:CreateFontString(nil, "OVERLAY", font_name)
        secText:SetPoint("LEFT", secEditBox, "RIGHT", 5, 0)
        secText:SetText(L["sec"])

        -- associate db
        function widget:SetFunc(func)
            -- widget.func = func
        end
        
        -- show db value
        function widget:SetDBValue(colorsTable)
            widget.colorsTable = colorsTable

            normalColor:SetColor(colorsTable[1])
            percentColor:SetColor({colorsTable[2][1],colorsTable[2][2],colorsTable[2][3]})
            secColor:SetColor({colorsTable[3][1],colorsTable[3][2],colorsTable[3][3]})

            percentDropdown:SetSelected(colorsTable[2][4]~=0 and ((colorsTable[2][4]*100).."%") or _G.NONE)
            -- secDropdown:SetSelected(colorsTable[3][4]~=0 and (colorsTable[3][4].." "..L["sec"]) or _G.NONE)
            secEditBox:SetText(colorsTable[3][4])
        end
    else
        widget = settingWidgets["colors"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_CustomColors(parent)
    local widget

    if not settingWidgets["customColors"] then
        widget = addon:CreateFrame("CellIndicatorSettings_CustomColors", parent, 240, 50)
        settingWidgets["customColors"] = widget

        -- dropdown
        widget.color = addon:CreateDropdown(widget, 170)
        widget.color:SetPoint("TOPLEFT", 5, -20)
        
        widget.buffItems = {
            {
                ["text"] = L["Solid"],
                ["value"] = "solid",
                ["onClick"] = function()
                    -- widget.colorPicker1:Show()
                    widget.colorPicker2:Hide()
                    widget.func({"solid", widget.colorTable1, widget.colorTable2})
                end
            },
            {
                ["text"] = L["Vertical Gradient"],
                ["value"] = "gradient-vertical",
                ["onClick"] = function()
                    -- widget.colorPicker1:Show()
                    widget.colorPicker2:Show()
                    widget.func({"gradient-vertical", widget.colorTable1, widget.colorTable2})
                end
            },
            {
                ["text"] = L["Horizontal Gradient"],
                ["value"] = "gradient-horizontal",
                ["onClick"] = function()
                    -- widget.colorPicker1:Show()
                    widget.colorPicker2:Show()
                    widget.func({"gradient-horizontal", widget.colorTable1, widget.colorTable2})
                end
            },
        }
        
        widget.debuffItems = {
            {
                ["text"] = L["Solid"],
                ["value"] = "solid",
                ["onClick"] = function()
                    -- widget.colorPicker1:Show()
                    widget.colorPicker2:Hide()
                    widget.func({"solid", widget.colorTable1, widget.colorTable2})
                end
            },
            {
                ["text"] = L["Vertical Gradient"],
                ["value"] = "gradient-vertical",
                ["onClick"] = function()
                    -- widget.colorPicker1:Show()
                    widget.colorPicker2:Show()
                    widget.func({"gradient-vertical", widget.colorTable1, widget.colorTable2})
                end
            },
            {
                ["text"] = L["Horizontal Gradient"],
                ["value"] = "gradient-horizontal",
                ["onClick"] = function()
                    -- widget.colorPicker1:Show()
                    widget.colorPicker2:Show()
                    widget.func({"gradient-horizontal", widget.colorTable1, widget.colorTable2})
                end
            },
            {
                ["text"] = L["Debuff Type"],
                ["value"] = "debuff-type",
                ["onClick"] = function()
                    -- widget.colorPicker1:Show()
                    widget.colorPicker2:Hide()
                    widget.func({"debuff-type", widget.colorTable1, widget.colorTable2})
                end
            },
        }

        widget.colorText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.colorText:SetText(L["Color"])
        widget.colorText:SetPoint("BOTTOMLEFT", widget.color, "TOPLEFT", 0, 1)

        widget.colorPicker1 = addon:CreateColorPicker(widget, "", true, function(r, g, b, a)
            widget.colorTable1[1] = r
            widget.colorTable1[2] = g 
            widget.colorTable1[3] = b
            widget.colorTable1[4] = a
            widget.func({widget.color:GetSelected(), widget.colorTable1, widget.colorTable2})
        end)
        widget.colorPicker1:SetPoint("LEFT", widget.color, "RIGHT", 5, 0)

        widget.colorPicker2 = addon:CreateColorPicker(widget, "", true, function(r, g, b, a)
            widget.colorTable2[1] = r
            widget.colorTable2[2] = g 
            widget.colorTable2[3] = b
            widget.colorTable2[4] = a
            widget.func({widget.color:GetSelected(), widget.colorTable1, widget.colorTable2})
        end)
        widget.colorPicker2:SetPoint("LEFT", widget.colorPicker1, "RIGHT", 5, 0)

        -- associate db
        function widget:SetFunc(func)
            widget.func = func
        end
        
        -- show db value
        function widget:SetDBValue(auraType, colorTable)
            if auraType == "buff" then
                widget.color:SetItems(widget.buffItems)
            else -- debuff
                widget.color:SetItems(widget.debuffItems)
            end
            widget.color:SetSelectedValue(colorTable[1])

            if colorTable[1] == "solid" then
                -- widget.colorPicker1:Show()
                widget.colorPicker2:Hide()
            elseif colorTable[1] == "debuff-type" then
                -- widget.colorPicker1:Show()
                widget.colorPicker2:Hide()
            else -- gradient
                -- widget.colorPicker1:Show()
                widget.colorPicker2:Show()
            end
            
            widget.colorTable1 = colorTable[2]
            widget.colorPicker1:SetColor(widget.colorTable1)
            
            widget.colorTable2 = colorTable[3]
            widget.colorPicker2:SetColor(widget.colorTable2)
        end
    else
        widget = settingWidgets["customColors"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_NameColor(parent)
    local widget

    if not settingWidgets["nameColor"] then
        widget = addon:CreateFrame("CellIndicatorSettings_NameColor", parent, 240, 50)
        settingWidgets["nameColor"] = widget

        widget.nameColorDropdown = addon:CreateDropdown(widget, 120)
        widget.nameColorDropdown:SetPoint("TOPLEFT", 5, -20)
        widget.nameColorDropdown:SetItems({
            {
                ["text"] = L["Class Color"],
                ["value"] = "Class Color",
                ["onClick"] = function()
                    widget.func({"Class Color", widget.nameColorPicker:GetColor()})
                end,
            },
            {
                ["text"] = L["Custom Color"],
                ["value"] = "Custom Color",
                ["onClick"] = function()
                    widget.func({"Custom Color", widget.nameColorPicker:GetColor()})
                end,
            },
        })

        local nameColorText = widget:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
        nameColorText:SetPoint("BOTTOMLEFT", widget.nameColorDropdown, "TOPLEFT", 0, 1)
        nameColorText:SetText(L["Name Color"])

        widget.nameColorPicker = addon:CreateColorPicker(widget, "", false, function(r, g, b)
            widget.func({widget.nameColorDropdown:GetSelected(), {r, g, b}})
        end)
        widget.nameColorPicker:SetPoint("LEFT", widget.nameColorDropdown, "RIGHT", 5, 0)

        -- associate db
        function widget:SetFunc(func)
            widget.func = func
        end
        
        -- show db value
        function widget:SetDBValue(cTable)
            widget.nameColorDropdown:SetSelected(L[cTable[1]])
            widget.nameColorPicker:SetColor(cTable[2])
        end
    else
        widget = settingWidgets["nameColor"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_StatusColors(parent)
    local widget

    if not settingWidgets["statusColors"] then
        widget = addon:CreateFrame("CellIndicatorSettings_StatusColors", parent, 240, 100)
        settingWidgets["statusColors"] = widget

        local afkColor = addon:CreateColorPicker(widget, L["AFK"], false, function(r, g, b)
            widget.colorsTable["AFK"][1] = r
            widget.colorsTable["AFK"][2] = g 
            widget.colorsTable["AFK"][3] = b
            widget.func(nil, "statusColors")
        end)
        afkColor:SetPoint("TOPLEFT", 5, -7)
        
        local offlineColor = addon:CreateColorPicker(widget, L["OFFLINE"], false, function(r, g, b)
            widget.colorsTable["OFFLINE"][1] = r
            widget.colorsTable["OFFLINE"][2] = g 
            widget.colorsTable["OFFLINE"][3] = b
            widget.func(nil, "statusColors")
        end)
        offlineColor:SetPoint("TOPLEFT", afkColor, "TOPRIGHT", 70, 0)
        
        local deadColor = addon:CreateColorPicker(widget, L["DEAD"], false, function(r, g, b)
            widget.colorsTable["DEAD"][1] = r
            widget.colorsTable["DEAD"][2] = g 
            widget.colorsTable["DEAD"][3] = b
            widget.func(nil, "statusColors")
        end)
        deadColor:SetPoint("TOPLEFT", offlineColor, "TOPRIGHT", 70, 0)

        local ghostColor = addon:CreateColorPicker(widget, L["GHOST"], false, function(r, g, b)
            widget.colorsTable["GHOST"][1] = r
            widget.colorsTable["GHOST"][2] = g 
            widget.colorsTable["GHOST"][3] = b
            widget.func(nil, "statusColors")
        end)
        ghostColor:SetPoint("TOPLEFT", afkColor, "BOTTOMLEFT", 0, -8)

        local feignColor = addon:CreateColorPicker(widget, L["FEIGN"], false, function(r, g, b)
            widget.colorsTable["FEIGN"][1] = r
            widget.colorsTable["FEIGN"][2] = g 
            widget.colorsTable["FEIGN"][3] = b
            widget.func(nil, "statusColors")
        end)
        feignColor:SetPoint("TOPLEFT", ghostColor, "TOPRIGHT", 70, 0)

        local drinkingColor = addon:CreateColorPicker(widget, L["DRINKING"], false, function(r, g, b)
            widget.colorsTable["DRINKING"][1] = r
            widget.colorsTable["DRINKING"][2] = g 
            widget.colorsTable["DRINKING"][3] = b
            widget.func(nil, "statusColors")
        end)
        drinkingColor:SetPoint("TOPLEFT", feignColor, "TOPRIGHT", 70, 0)

        local pendingColor = addon:CreateColorPicker(widget, L["PENDING"], false, function(r, g, b)
            widget.colorsTable["PENDING"][1] = r
            widget.colorsTable["PENDING"][2] = g 
            widget.colorsTable["PENDING"][3] = b
            widget.func(nil, "statusColors")
        end)
        pendingColor:SetPoint("TOPLEFT", ghostColor, "BOTTOMLEFT", 0, -8)

        local acceptedColor = addon:CreateColorPicker(widget, L["ACCEPTED"], false, function(r, g, b)
            widget.colorsTable["ACCEPTED"][1] = r
            widget.colorsTable["ACCEPTED"][2] = g 
            widget.colorsTable["ACCEPTED"][3] = b
            widget.func(nil, "statusColors")
        end)
        acceptedColor:SetPoint("TOPLEFT", pendingColor, "TOPRIGHT", 70, 0)

        local declinedColor = addon:CreateColorPicker(widget, L["DECLINED"], false, function(r, g, b)
            widget.colorsTable["DECLINED"][1] = r
            widget.colorsTable["DECLINED"][2] = g 
            widget.colorsTable["DECLINED"][3] = b
            widget.func(nil, "statusColors")
        end)
        declinedColor:SetPoint("TOPLEFT", acceptedColor, "TOPRIGHT", 70, 0)

        local resetBtn = addon:CreateButton(widget, L["Reset All"], "class", {70, 20})
        resetBtn:SetPoint("TOPLEFT", pendingColor, "BOTTOMLEFT", 0, -8)
        resetBtn:SetScript("OnClick", function()
            widget.colorsTable["AFK"] = {1, 0.19, 0.19}
            widget.colorsTable["OFFLINE"] = {1, 0.19, 0.19}
            widget.colorsTable["DEAD"] = {1, 0.19, 0.19}
            widget.colorsTable["GHOST"] = {1, 0.19, 0.19}
            widget.colorsTable["FEIGN"] = {1, 1, 0.12}
            widget.colorsTable["DRINKING"] = {0.12, 0.75, 1}
            widget.colorsTable["PENDING"] = {1, 1, 0.12}
            widget.colorsTable["ACCEPTED"] = {0.12, 1, 0.12}
            widget.colorsTable["DECLINED"] = {1, 0.19, 0.19}

            afkColor:SetColor(widget.colorsTable["AFK"])
            offlineColor:SetColor(widget.colorsTable["OFFLINE"])
            deadColor:SetColor(widget.colorsTable["DEAD"])
            ghostColor:SetColor(widget.colorsTable["GHOST"])
            feignColor:SetColor(widget.colorsTable["FEIGN"])
            drinkingColor:SetColor(widget.colorsTable["DRINKING"])
            pendingColor:SetColor(widget.colorsTable["PENDING"])
            acceptedColor:SetColor(widget.colorsTable["ACCEPTED"])
            declinedColor:SetColor(widget.colorsTable["DECLINED"])

            widget.func(nil, "statusColors")
        end)
        
        -- associate db
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
        widget = addon:CreateFrame("CellIndicatorSettings_CheckButton", parent, 240, 30)
        settingWidgets["checkbutton"] = widget

        widget.cb = addon:CreateCheckButton(widget, "checkbutton")
        widget.cb:SetPoint("TOPLEFT", 5, -8)

        -- associate db
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
                addon:SetTooltips(widget.cb, "ANCHOR_TOPLEFT", 0, 2, L[settingName], string.split("|", tooltip))
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
        widget = addon:CreateFrame("CellIndicatorSettings_CheckButton2", parent, 240, 30)
        settingWidgets["checkbutton2"] = widget

        widget.cb = addon:CreateCheckButton(widget, "checkbutton2")
        widget.cb:SetPoint("TOPLEFT", 5, -8)

        -- associate db
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
                addon:SetTooltips(widget.cb, "ANCHOR_TOPLEFT", 0, 2, L[settingName], string.split("|", tooltip))
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
        widget = addon:CreateFrame("CellIndicatorSettings_CheckButton3", parent, 240, 30)
        settingWidgets["checkbutton3"] = widget

        widget.cb = addon:CreateCheckButton(widget, "checkbutton3")
        widget.cb:SetPoint("TOPLEFT", 5, -8)

        -- associate db
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
                addon:SetTooltips(widget.cb, "ANCHOR_TOPLEFT", 0, 2, L[settingName], string.split("|", tooltip))
            end
        end
    else
        widget = settingWidgets["checkbutton3"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_Duration(parent)
    local widget

    if not settingWidgets["duration"] then
        widget = addon:CreateFrame("CellIndicatorSettings_Duration", parent, 240, 97)
        settingWidgets["duration"] = widget

        -- duration
        widget.durationCB = addon:CreateCheckButton(widget, L["showDuration"], function(checked, self)
            widget.durationTbl[1] = checked
            widget.func(widget.durationTbl)
        end)
        widget.durationCB:SetPoint("TOPLEFT", 5, -8)

        -- duration round up
        widget.durationRoundUpCB = addon:CreateCheckButton(widget, L["Round Up Duration Text"], function(checked, self)
            CellDropdownList:Hide()
            widget.durationTbl[2] = checked
            addon:SetEnabled(not checked, widget.durationDecimalText1, widget.durationDecimalText2, widget.durationDecimalDropdown)
            widget.func(widget.durationTbl)
        end)
        widget.durationRoundUpCB:SetPoint("TOPLEFT", widget.durationCB, "BOTTOMLEFT", 0, -8)

        -- duration decimal
        widget.durationDecimalText1 = widget:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
        widget.durationDecimalText1:SetPoint("TOPLEFT", widget.durationRoundUpCB, "BOTTOMLEFT", 1, -10)
        widget.durationDecimalText1:SetText(L["Display One Decimal Place When"])

        widget.durationDecimalText2 = widget:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
        widget.durationDecimalText2:SetPoint("TOPLEFT", widget.durationDecimalText1, "BOTTOMLEFT", 0, -5)
        widget.durationDecimalText2:SetText(L["Remaining Time <"])

        widget.durationDecimalDropdown = addon:CreateDropdown(widget, 60)
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

        -- associate db
        function widget:SetFunc(func)
            -- NOTE: to notify indicator update
            widget.func = func
        end
        
        -- show db value
        function widget:SetDBValue(durationTbl)
            widget.durationTbl = durationTbl
            widget.durationCB:SetChecked(durationTbl[1])
            widget.durationRoundUpCB:SetChecked(durationTbl[2])
            addon:SetEnabled(not durationTbl[2], widget.durationDecimalText1, widget.durationDecimalText2, widget.durationDecimalDropdown)
            widget.durationDecimalDropdown:SetSelectedValue(durationTbl[3])
        end
    else
        widget = settingWidgets["duration"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_CustomTextures(parent)
    local widget

    if not settingWidgets["customTextures"] then
        widget = addon:CreateFrame("CellIndicatorSettings_CustomTextures", parent, 240, 165)
        settingWidgets["customTextures"] = widget

        widget.cb = addon:CreateCheckButton(widget, L["Use Custom Textures"], function(checked)
            widget.func({widget.cb:GetChecked(), widget.eb1:GetText(), widget.eb2:GetText(), widget.eb3:GetText()})
            widget.eb1:SetEnabled(checked)
            widget.eb2:SetEnabled(checked)
            widget.eb3:SetEnabled(checked)
        end)
        widget.cb:SetPoint("TOPLEFT", 5, -8)

        widget.eb1 = addon:CreateEditBox(widget, 260, 20)
        widget.eb1:SetPoint("TOPLEFT", widget.cb, "BOTTOMLEFT", 0, -25)
        widget.eb1:SetScript("OnEnterPressed", function(self)
            self:ClearFocus()
            widget.func({widget.cb:GetChecked(), self:GetText(), widget.eb2:GetText(), widget.eb3:GetText()})
            widget.texture1:SetTexture(self:GetText())
        end)

        local text1 = widget:CreateFontString(nil, "OVERLAY", font_name)
        text1:SetPoint("BOTTOMLEFT", widget.eb1, "TOPLEFT", 0, 1)
        text1:SetText(_G["TANK"])

        widget.texture1 = widget:CreateTexture(nil, "ARTWORK")
        widget.texture1:SetPoint("BOTTOMLEFT", text1, "BOTTOMRIGHT", 3, 0)
        widget.texture1:SetSize(16, 16)
        
        widget.eb2 = addon:CreateEditBox(widget, 260, 20)
        widget.eb2:SetPoint("TOPLEFT", widget.eb1, "BOTTOMLEFT", 0, -25)
        widget.eb2:SetScript("OnEnterPressed", function(self)
            self:ClearFocus()
            widget.func({widget.cb:GetChecked(), widget.eb1:GetText(), self:GetText(), widget.eb3:GetText()})
            widget.texture2:SetTexture(self:GetText())
        end)
        
        local text2 = widget:CreateFontString(nil, "OVERLAY", font_name)
        text2:SetPoint("BOTTOMLEFT", widget.eb2, "TOPLEFT", 0, 1)
        text2:SetText(_G["HEALER"])

        widget.texture2 = widget:CreateTexture(nil, "ARTWORK")
        widget.texture2:SetPoint("BOTTOMLEFT", text2, "BOTTOMRIGHT", 3, 0)
        widget.texture2:SetSize(16, 16)

        widget.eb3 = addon:CreateEditBox(widget, 260, 20)
        widget.eb3:SetPoint("TOPLEFT", widget.eb2, "BOTTOMLEFT", 0, -25)
        widget.eb3:SetScript("OnEnterPressed", function(self)
            self:ClearFocus()
            widget.func({widget.cb:GetChecked(), widget.eb1:GetText(), widget.eb2:GetText(), self:GetText()})
            widget.texture3:SetTexture(self:GetText())
        end)

        local text3 = widget:CreateFontString(nil, "OVERLAY", font_name)
        text3:SetPoint("BOTTOMLEFT", widget.eb3, "TOPLEFT", 0, 1)
        text3:SetText(_G["DAMAGER"])

        widget.texture3 = widget:CreateTexture(nil, "ARTWORK")
        widget.texture3:SetPoint("BOTTOMLEFT", text3, "BOTTOMRIGHT", 3, 0)
        widget.texture3:SetSize(16, 16)

        -- associate db
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(t)
            widget.cb:SetChecked(t[1])
            widget.eb1:SetEnabled(t[1])
            widget.eb2:SetEnabled(t[1])
            widget.eb3:SetEnabled(t[1])
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
        widget = settingWidgets["customTextures"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_Glow(parent)
    local widget

    if not settingWidgets["glow"] then
        widget = addon:CreateFrame("CellIndicatorSettings_Glow", parent, 240, 145)
        settingWidgets["glow"] = widget

        widget.glowType = addon:CreateDropdown(widget, 110)
        widget.glowType:SetPoint("TOPLEFT", 5, -20)
        widget.glowType:SetItems({
            {
                ["text"] = L["None"],
                ["value"] = "None",
                ["onClick"] = function()
                    widget:SetHeight(50)
                    widget.glowColor:SetColor({0.95,0.95,0.32,1})
                    widget.glowLines:Hide()
                    widget.glowParticles:Hide()
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
                    widget.glowColor:SetColor({0.95,0.95,0.32,1})
                    widget.glowLines:Hide()
                    widget.glowParticles:Hide()
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
                    widget.glowColor:SetColor({0.95,0.95,0.32,1})
                    widget.glowLines:Show()
                    widget.glowLines:SetValue(9)
                    widget.glowFrequency:Show()
                    widget.glowFrequency:SetValue(.25)
                    widget.glowLength:Show()
                    widget.glowLength:SetValue(8)
                    widget.glowThickness:Show()
                    widget.glowThickness:SetValue(2)
                    widget.glowParticles:Hide()
                    widget.glowScale:Hide()
                    widget.glow[1] = "Pixel"
                    widget.glow[2] = {0.95,0.95,0.32,1}
                    widget.glow[3] = 9
                    widget.glow[4] = .25
                    widget.glow[5] = 8
                    widget.glow[6] = 2
                    widget.func(widget.glow)
                end,
            },
            {
                ["text"] = L["Shine"],
                ["value"] = "Shine",
                ["onClick"] = function()
                    widget:SetHeight(145)
                    widget.glowColor:SetColor({0.95,0.95,0.32,1})
                    widget.glowParticles:Show()
                    widget.glowParticles:SetValue(9)
                    widget.glowFrequency:Show()
                    widget.glowFrequency:SetValue(.5)
                    widget.glowScale:Show()
                    widget.glowScale:SetValue(100)
                    widget.glowLines:Hide()
                    widget.glowLength:Hide()
                    widget.glowThickness:Hide()
                    widget.glow[1] = "Shine"
                    widget.glow[2] = {0.95,0.95,0.32,1}
                    widget.glow[3] = 9
                    widget.glow[4] = .5
                    widget.glow[5] = 1
                    widget.glow[6] = nil
                    widget.func(widget.glow)
                end,
            },
        })

        widget.glowTypeText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.glowTypeText:SetText(L["Glow Type"])
        widget.glowTypeText:SetPoint("BOTTOMLEFT", widget.glowType, "TOPLEFT", 0, 1)

        widget.glowColor = addon:CreateColorPicker(widget, L["Glow Color"], false, function(r, g, b)
            widget.glow[2] = {r, g, b, 1}
            widget.func(widget.glow)
        end)
        widget.glowColor:SetPoint("LEFT", widget.glowType, "RIGHT", 25, 0)

        -- glowNumber
        widget.glowLines = addon:CreateSlider(L["Lines"], widget, 1, 30, 110, 1, function(value)
            widget.glow[3] = value
            widget.func(widget.glow)
        end)
        widget.glowLines:SetPoint("TOPLEFT", widget.glowType, "BOTTOMLEFT", 0, -25)

        widget.glowParticles = addon:CreateSlider(L["Particles"], widget, 1, 30, 110, 1, function(value)
            widget.glow[3] = value
            widget.func(widget.glow)
        end)
        widget.glowParticles:SetPoint("TOPLEFT", widget.glowType, "BOTTOMLEFT", 0, -25)

        -- glowFrequency
        widget.glowFrequency = addon:CreateSlider(L["Frequency"], widget, -2, 2, 110, .05, function(value)
            widget.glow[4] = value
            widget.func(widget.glow)
        end)
        widget.glowFrequency:SetPoint("TOPLEFT", widget.glowLines, "TOPRIGHT", 25, 0)

        -- glowLength
        widget.glowLength = addon:CreateSlider(L["Length"], widget, 1, 20, 110, 1, function(value)
            widget.glow[5] = value
            widget.func(widget.glow)
        end)
        widget.glowLength:SetPoint("TOPLEFT", widget.glowLines, "BOTTOMLEFT", 0, -40)

        -- glowThickness
        widget.glowThickness = addon:CreateSlider(L["Thickness"], widget, 1, 20, 110, 1, function(value)
            widget.glow[6] = value
            widget.func(widget.glow)
        end)
        widget.glowThickness:SetPoint("TOPLEFT", widget.glowLength, "TOPRIGHT", 25, 0)

        -- glowScale
        widget.glowScale = addon:CreateSlider(L["Scale"], widget, 50, 500, 110, 1, function(value)
            widget.glow[5] = value
            widget.func(widget.glow)
        end, nil, true)
        widget.glowScale:SetPoint("TOPLEFT", widget.glowLines, "BOTTOMLEFT", 0, -40)

        -- associate db
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(t)
            -- {"Pixel", {0.95,0.95,0.32,1}, 9, .25, 8, 2},
            widget.glow = t
            widget.glowType:SetSelectedValue(t[1])
            widget.glowColor:SetColor(t[2])

            if t[1] == "None" or t[1] == "Normal" then
                widget.glowLines:Hide()
                widget.glowParticles:Hide()
                widget.glowFrequency:Hide()
                widget.glowLength:Hide()
                widget.glowThickness:Hide()
                widget.glowScale:Hide()
                widget:SetHeight(50)
            else
                widget:SetHeight(145)
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
                    widget.glowScale:Hide()

                elseif t[1] == "Shine" then
                    widget.glowParticles:Show()
                    widget.glowParticles:SetValue(t[3])
                    widget.glowFrequency:Show()
                    widget.glowFrequency:SetValue(t[4])
                    widget.glowScale:Show()
                    widget.glowScale:SetValue(t[5]*100)
                    widget.glowLines:Hide()
                    widget.glowLength:Hide()
                    widget.glowThickness:Hide()
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
        widget = addon:CreateFrame("CellIndicatorSettings_Texture", parent, 240, 100)
        settingWidgets["texture"] = widget

        widget.pathBox = addon:CreateFrame(nil, widget, 216, 20)
        addon:StylizeFrame(widget.pathBox, {0.115, 0.115, 0.115, 1}, {0, 0, 0, 1})
        widget.pathBox:SetPoint("TOPLEFT", 5, -20)
        widget.pathBox:Show()

        widget.path = widget.pathBox:CreateFontString(nil, "OVERLAY", font_name)
        widget.path:SetPoint("LEFT", 5, 0)
        widget.path:SetPoint("RIGHT", -5, 0)
        widget.path:SetWordWrap(false)

        widget.button = addon:CreateButton(widget, "...", "class", {30, 20})
        widget.button:SetPoint("TOPLEFT", widget.pathBox, "TOPRIGHT", P:Scale(-1), 0)
        widget.button:SetScript("OnClick", function()
            F:ShowTextureSelector(widget.selected, function(path)
                widget.selected = path
                F:FitWidth(widget.path, path, "right")
                widget.func({path, widget.rotation:GetValue(), widget.colorPicker:GetColor()})
            end)
        end)

        widget.pathText = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.pathText:SetText(L["Texture"])
        widget.pathText:SetPoint("BOTTOMLEFT", widget.pathBox, "TOPLEFT", 0, 1)

        widget.rotation = addon:CreateSlider(L["Rotation"], widget, -180, 180, 110, 1)
        widget.rotation:SetPoint("TOPLEFT", widget.pathBox, "BOTTOMLEFT", 0, -25)
        widget.rotation.afterValueChangedFn = function(value)
            widget.func({widget.selected, value, widget.colorPicker:GetColor()})
        end

        widget.colorPicker = addon:CreateColorPicker(widget, L["Color"], true, function(r, g, b, a)
            widget.func({widget.selected, widget.rotation:GetValue(), widget.colorPicker:GetColor()})
        end)
        widget.colorPicker:SetPoint("TOPLEFT", widget.rotation, "TOPRIGHT", 25, 0)

        -- associate db
        function widget:SetFunc(func)
            widget.func = func
        end

        -- show db value
        function widget:SetDBValue(t)
            widget.selected = t[1]
            F:FitWidth(widget.path, t[1], "right")
            widget.rotation:SetValue(t[2])
            widget.colorPicker:SetColor(t[3])
        end
    else
        widget = settingWidgets["texture"]
    end

    widget:Show()
    return widget
end

local auraButtons1 = {}
local auraButtons2 = {}
local GetSpellInfo = GetSpellInfo
local function CreateAuraButtons(parent, auraButtons, auraTable, noUpDownButtons, isZeroValid, updateHeightFunc)
    local n = #auraTable

    -- tooltip
    if not parent.popupEditBox then
        local popup = addon:CreatePopupEditBox(parent, 20)
        popup:SetNumeric(true)

        popup:SetScript("OnTextChanged", function()
            local spellId = tonumber(popup:GetText())
            if not spellId then
                CellTooltip:Hide()
                return
            end

            local name = GetSpellInfo(spellId)
            if not name then
                CellTooltip:Hide()
                return
            end
            
            CellTooltip:SetOwner(popup, "ANCHOR_NONE")
            CellTooltip:SetPoint("TOPLEFT", popup, "BOTTOMLEFT", 0, -1)
            CellTooltip:SetHyperlink("spell:"..spellId)
            CellTooltip:Show()
        end)
        
        popup:HookScript("OnHide", function()
            CellTooltip:Hide()
        end)
    end

    -- new
    if not auraButtons[0] then
        auraButtons[0] = addon:CreateButton(parent, "", "transparent-class", {20, 20})
        auraButtons[0]:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\new", {16, 16}, {"RIGHT", -1, 0})
        auraButtons[0]:SetPoint("BOTTOMLEFT")
        auraButtons[0]:SetPoint("RIGHT")
    end
    
    auraButtons[0]:SetScript("OnClick", function(self)
        local popup = addon:CreatePopupEditBox(parent, self:GetWidth(), function(text)
            local spellId = tonumber(text)
            local spellName = GetSpellInfo(spellId)
            if (spellId and spellName) or (spellId == 0 and isZeroValid) then
                -- update db
                tinsert(auraTable, spellId)
                parent.func(auraTable)
                CreateAuraButtons(parent, auraButtons, auraTable, noUpDownButtons, isZeroValid, updateHeightFunc)
                updateHeightFunc(19)
            else
                F:Print(L["Invalid spell id."])
            end
        end)
        popup:SetPoint("TOPLEFT", self)
        popup:ShowEditBox("")
        if isZeroValid then
            parent.popupEditBox:SetTips("|cff777777"..L["Enter spell id"]..", 0 = ".. L["all"])
        else
            parent.popupEditBox:SetTips("|cff777777"..L["Enter spell id"])
        end
    end)


    for i, spell in ipairs(auraTable) do
        -- creation
        if not auraButtons[i] then
            auraButtons[i] = addon:CreateButton(parent, "", "transparent-class", {20, 20})

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
            auraButtons[i].del = addon:CreateButton(auraButtons[i], "", "none", {18, 20}, true, true)
            auraButtons[i].del:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\delete", {16, 16}, {"CENTER", 0, 0})
            auraButtons[i].del:SetPoint("RIGHT")
            auraButtons[i].del.tex:SetVertexColor(.6, .6, .6, 1)
            auraButtons[i].del:SetScript("OnEnter", function()
                auraButtons[i]:GetScript("OnEnter")(auraButtons[i])
                auraButtons[i].del.tex:SetVertexColor(1, 1, 1, 1)
            end)
            auraButtons[i].del:SetScript("OnLeave",  function()
                auraButtons[i]:GetScript("OnLeave")(auraButtons[i])
                auraButtons[i].del.tex:SetVertexColor(.6, .6, .6, 1)
            end)
            
            -- edit
            auraButtons[i].edit = addon:CreateButton(auraButtons[i], "", "none", {18, 20}, true, true)
            auraButtons[i].edit:SetPoint("RIGHT", auraButtons[i].del, "LEFT", 1, 0)
            auraButtons[i].edit:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\info", {16, 16}, {"CENTER", 0, 0})
            auraButtons[i].edit.tex:SetVertexColor(.6, .6, .6, 1)
            auraButtons[i].edit:SetScript("OnEnter", function()
                auraButtons[i]:GetScript("OnEnter")(auraButtons[i])
                auraButtons[i].edit.tex:SetVertexColor(1, 1, 1, 1)
            end)
            auraButtons[i].edit:SetScript("OnLeave",  function()
                auraButtons[i]:GetScript("OnLeave")(auraButtons[i])
                auraButtons[i].edit.tex:SetVertexColor(.6, .6, .6, 1)
            end)

            -- down
            auraButtons[i].down = addon:CreateButton(auraButtons[i], "", "none", {18, 20}, true, true)
            auraButtons[i].down:SetPoint("RIGHT", auraButtons[i].edit, "LEFT", 1, 0)
            auraButtons[i].down:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\down", {16, 16}, {"CENTER", 0, 0})
            auraButtons[i].down.tex:SetVertexColor(.6, .6, .6, 1)
            auraButtons[i].down:SetScript("OnEnter", function()
                auraButtons[i]:GetScript("OnEnter")(auraButtons[i])
                auraButtons[i].down.tex:SetVertexColor(1, 1, 1, 1)
            end)
            auraButtons[i].down:SetScript("OnLeave",  function()
                auraButtons[i]:GetScript("OnLeave")(auraButtons[i])
                auraButtons[i].down.tex:SetVertexColor(.6, .6, .6, 1)
            end)
            
            -- up
            auraButtons[i].up = addon:CreateButton(auraButtons[i], "", "none", {18, 20}, true, true)
            auraButtons[i].up:SetPoint("RIGHT", auraButtons[i].down, "LEFT", 1, 0)
            auraButtons[i].up:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\up", {16, 16}, {"CENTER", 0, 0})
            auraButtons[i].up.tex:SetVertexColor(.6, .6, .6, 1)
            auraButtons[i].up:SetScript("OnEnter", function()
                auraButtons[i]:GetScript("OnEnter")(auraButtons[i])
                auraButtons[i].up.tex:SetVertexColor(1, 1, 1, 1)
            end)
            auraButtons[i].up:SetScript("OnLeave",  function()
                auraButtons[i]:GetScript("OnLeave")(auraButtons[i])
                auraButtons[i].up.tex:SetVertexColor(.6, .6, .6, 1)
            end)
        end
        
        -- TODO: for old versions, remove these in the future
        if type(spell) == "string" then
            auraButtons[i].spellIdText:SetText("")
            auraButtons[i].spellId = nil
            auraButtons[i].spellNameText:SetText("|cffff0000"..spell)
            auraButtons[i].spellIconBg:Hide()
            auraButtons[i].spellIcon:Hide()
        elseif spell == 0 then
            auraButtons[i].spellIdText:SetText("0")
            auraButtons[i].spellId = nil
            auraButtons[i].spellNameText:SetText("|cff22ff22"..L["all"])
            auraButtons[i].spellIconBg:Hide()
            auraButtons[i].spellIcon:Hide()
        else
            local name, _, icon = GetSpellInfo(spell)
            auraButtons[i].spellIdText:SetText(spell)
            auraButtons[i].spellId = spell
            auraButtons[i].spellNameText:SetText(name or L["Invalid"])
            if icon then
                auraButtons[i].spellIcon:SetTexture(icon)
                auraButtons[i].spellIconBg:Show()
                auraButtons[i].spellIcon:Show()
            else
                auraButtons[i].spellIconBg:Hide()
                auraButtons[i].spellIcon:Hide()
            end
            -- spell tooltip
            auraButtons[i]:HookScript("OnEnter", function(self)
                if not parent.popupEditBox:IsShown() then
                    local name = GetSpellInfo(self.spellId)
                    if not name then
                        CellTooltip:Hide()
                        return
                    end
                    
                    CellTooltip:SetOwner(auraButtons[i], "ANCHOR_NONE")
                    CellTooltip:SetPoint("TOPRIGHT", auraButtons[i], "TOPLEFT", -1, 0)
                    CellTooltip:SetHyperlink("spell:"..self.spellId)
                    CellTooltip:Show()
                end
            end)
            auraButtons[i]:HookScript("OnLeave", function()
                if not parent.popupEditBox:IsShown() then
                    CellTooltip:Hide()
                end
            end)
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
            auraButtons[i]:SetPoint("TOPLEFT", auraButtons[i-1], "BOTTOMLEFT", 0, 1)
            -- update buttons
            if noUpDownButtons then
                auraButtons[i].up:Hide()
                auraButtons[i].down:Hide()
            else
                auraButtons[i].up:Show()
                auraButtons[i].down:Hide()
            end
        else
            auraButtons[i]:SetPoint("TOPLEFT", auraButtons[i-1], "BOTTOMLEFT", 0, 1)
            -- update buttons
            if noUpDownButtons then
                auraButtons[i].down:Hide()
                auraButtons[i].up:Hide()
            else
                auraButtons[i].down:Show()
                auraButtons[i].up:Show()
            end
        end
        auraButtons[i]:SetPoint("RIGHT")
        auraButtons[i]:Show()

        -- functions
        auraButtons[i].edit:SetScript("OnClick", function()
            local popup = addon:CreatePopupEditBox(parent, auraButtons[i]:GetWidth(), function(text)
                local spellId = tonumber(text)
                if spellId == 0 then
                    if isZeroValid then
                        auraButtons[i].spellIdText:SetText("0")
                        auraButtons[i].spellId = nil
                        auraButtons[i].spellNameText:SetText("|cff22ff22"..L["all"])
                        auraButtons[i].spellIconBg:Hide()
                        auraButtons[i].spellIcon:Hide()
                    else
                        F:Print(L["Invalid spell id."])
                    end
                else
                    local spellName, _, spellIcon = GetSpellInfo(spellId)
                    if spellId and spellName then
                        -- update text
                        auraButtons[i].spellIdText:SetText(spellId)
                        auraButtons[i].spellId = spellId
                        auraButtons[i].spellNameText:SetText(spellName)
                        -- update db
                        auraTable[i] = spellId
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
                        F:Print(L["Invalid spell id."])
                    end
                end

            end)
            popup:SetPoint("TOPLEFT", auraButtons[i])
            popup:ShowEditBox(auraButtons[i].spellId or "")
            parent.popupEditBox:SetTips("|cff777777"..L["Enter spell id"])
        end)

        auraButtons[i].del:SetScript("OnClick", function()
            tremove(auraTable, i)
            parent.func(auraTable)
            CreateAuraButtons(parent, auraButtons, auraTable, noUpDownButtons, isZeroValid, updateHeightFunc)
            updateHeightFunc(-19)
        end)

        auraButtons[i].up:SetScript("OnClick", function()
            local temp = auraTable[i-1]
            auraTable[i-1] = auraTable[i]
            auraTable[i] = temp
            parent.func(auraTable)
            CreateAuraButtons(parent, auraButtons, auraTable, noUpDownButtons, isZeroValid, updateHeightFunc)
        end)

        auraButtons[i].down:SetScript("OnClick", function()
            local temp = auraTable[i+1]
            auraTable[i+1] = auraTable[i]
            auraTable[i] = temp
            parent.func(auraTable)
            CreateAuraButtons(parent, auraButtons, auraTable, noUpDownButtons, isZeroValid, updateHeightFunc)
        end)
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

local function CreateSetting_Auras(parent)
    local widget

    if not settingWidgets["auras"] then
        widget = addon:CreateFrame("CellIndicatorSettings_Auras", parent, 240, 128)
        settingWidgets["auras"] = widget

        widget.frame = addon:CreateFrame(nil, widget, 20, 20)
        widget.frame:SetPoint("TOPLEFT", 5, -20)
        widget.frame:SetPoint("RIGHT", -5, 0)
        widget.frame:Show()
        addon:StylizeFrame(widget.frame, {.15, .15, .15, 1})

        widget.text = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.text:SetPoint("BOTTOMLEFT", widget.frame, "TOPLEFT", 0, 1)

        -- associate db
        function widget:SetFunc(func)
            widget.frame.func = func
        end

        -- show db value
        function widget:SetDBValue(title, t, noUpDownButtons, isZeroValid)
            widget.text:SetText(title)
            CreateAuraButtons(widget.frame, auraButtons1, t, noUpDownButtons, isZeroValid, function(diff)
                widget.frame:SetHeight((#t+1)*19+1)
                widget:SetHeight((#t+1)*19+1 + 20 + 5)
                if diff then parent:SetHeight(parent:GetHeight()+diff) end
            end)
            widget.frame:SetHeight((#t+1)*19+1)
            widget:SetHeight((#t+1)*19+1 + 20 + 5)
        end
    else
        widget = settingWidgets["auras"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_Auras2(parent)
    local widget

    if not settingWidgets["auras2"] then
        widget = addon:CreateFrame("CellIndicatorSettings_Auras2", parent, 240, 128)
        settingWidgets["auras2"] = widget

        widget.frame = addon:CreateFrame(nil, widget, 20, 20)
        widget.frame:SetPoint("TOPLEFT", 5, -20)
        widget.frame:SetPoint("RIGHT", -5, 0)
        widget.frame:Show()
        addon:StylizeFrame(widget.frame, {.15, .15, .15, 1})

        widget.text = widget:CreateFontString(nil, "OVERLAY", font_name)
        widget.text:SetPoint("BOTTOMLEFT", widget.frame, "TOPLEFT", 0, 1)

        -- associate db
        function widget:SetFunc(func)
            widget.frame.func = func
        end

        -- show db value
        function widget:SetDBValue(title, t, noUpDownButtons)
            widget.text:SetText(title)
            CreateAuraButtons(widget.frame, auraButtons2, t, noUpDownButtons, nil, function(diff)
                widget.frame:SetHeight((#t+1)*19+1)
                widget:SetHeight((#t+1)*19+1 + 20 + 5)
                if diff then parent:SetHeight(parent:GetHeight()+diff) end
            end)
            widget.frame:SetHeight((#t+1)*19+1)
            widget:SetHeight((#t+1)*19+1 + 20 + 5)
        end
    else
        widget = settingWidgets["auras2"]
    end

    widget:Show()
    return widget
end

local function CreateSetting_Tips(parent, text)
    local widget

    if not settingWidgets["tips"] then
        widget = addon:CreateFrame("CellIndicatorSettings_Tips", parent, 240, 30)
        settingWidgets["tips"] = widget

        -- widget.text = widget:CreateFontString(nil, "OVERLAY", font_name)
        -- widget.text:SetPoint("LEFT", 5, 0)
        -- widget.text:SetPoint("RIGHT", -5, 0)
        -- widget.text:SetJustifyH("LEFT")
        widget.text = addon:CreateScrollTextFrame(widget, "", 0.02, nil, nil, true)
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

-----------------------------------------
-- create
-----------------------------------------
function addon:CreateIndicatorSettings(parent, settingsTable)
    local widgetsTable = {}

    -- hide all
    for _, w in pairs(settingWidgets) do
        w:Hide()
        w:ClearAllPoints()
    end

    -- return and show
    for _, setting in pairs(settingsTable) do
        if setting == "enabled" then
            tinsert(widgetsTable, CreateSetting_Enabled(parent))
        elseif setting == "position" then
            tinsert(widgetsTable, CreateSetting_Position(parent, L["To UnitButton's"]))
        elseif setting == "namePosition" then
            tinsert(widgetsTable, CreateSetting_Position(parent, L["To HealthBar's"]))
        elseif setting == "anchor" then
            tinsert(widgetsTable, CreateSetting_Anchor(parent))
        elseif setting == "frameLevel" then
            tinsert(widgetsTable, CreateSetting_FrameLevel(parent))
        elseif setting == "size" then
            tinsert(widgetsTable, CreateSetting_Size(parent))
        elseif setting == "size-normal-big" then
            tinsert(widgetsTable, CreateSetting_SizeNormalBig(parent))
        elseif setting == "size-square" then
            tinsert(widgetsTable, CreateSetting_SizeSquare(parent))
        elseif setting == "size-bar" then
            tinsert(widgetsTable, CreateSetting_SizeBar(parent))
        elseif setting == "size-border" then
            tinsert(widgetsTable, CreateSetting_SizeAndBorder(parent))
        elseif setting == "thickness" then
            tinsert(widgetsTable, CreateSetting_Thickness(parent))
        elseif setting == "height" then
            tinsert(widgetsTable, CreateSetting_Height(parent))
        elseif setting == "textWidth" then
            tinsert(widgetsTable, CreateSetting_TextWidth(parent))
        elseif setting == "vehicleNamePosition" then
            tinsert(widgetsTable, CreateSetting_VehicleNamePosition(parent))
        elseif setting == "statusPosition" then
            tinsert(widgetsTable, CreateSetting_StatusPosition(parent))
        elseif setting == "alpha" then
            tinsert(widgetsTable, CreateSetting_Alpha(parent))
        elseif string.find(setting, "num") then
            tinsert(widgetsTable, CreateSetting_Num(parent))
        elseif setting == "format" then
            tinsert(widgetsTable, CreateSetting_Format(parent))
        elseif setting == "orientation" then
            tinsert(widgetsTable, CreateSetting_Orientation(parent))
        elseif setting == "font" then
            tinsert(widgetsTable, CreateSetting_Font(parent))
        elseif setting == "font-noOffset" then
            tinsert(widgetsTable, CreateSetting_FontNoOffset(parent))
        -- elseif setting == "durationFont" then
        --     tinsert(widgetsTable, CreateSetting_DurationFont(parent))
        -- elseif setting == "stackFont" then
        --     tinsert(widgetsTable, CreateSetting_StackFont(parent))
        elseif setting == "color" then
            tinsert(widgetsTable, CreateSetting_Color(parent))
        elseif setting == "color-alpha" then
            tinsert(widgetsTable, CreateSetting_ColorAlpha(parent))
        elseif setting == "colors" then
            tinsert(widgetsTable, CreateSetting_Colors(parent))
        elseif setting == "customColors" then
            tinsert(widgetsTable, CreateSetting_CustomColors(parent))
        elseif setting == "nameColor" then
            tinsert(widgetsTable, CreateSetting_NameColor(parent))
        elseif setting == "statusColors" then
            tinsert(widgetsTable, CreateSetting_StatusColors(parent))
        elseif string.find(setting, "checkbutton3") then
            tinsert(widgetsTable, CreateSetting_CheckButton3(parent))
        elseif string.find(setting, "checkbutton2") then
            tinsert(widgetsTable, CreateSetting_CheckButton2(parent))
        elseif string.find(setting, "checkbutton") then
            tinsert(widgetsTable, CreateSetting_CheckButton(parent))
        elseif setting == "duration" then
            tinsert(widgetsTable, CreateSetting_Duration(parent))
        elseif setting == "customTextures" then
            tinsert(widgetsTable, CreateSetting_CustomTextures(parent))
        elseif setting == "glow" then
            tinsert(widgetsTable, CreateSetting_Glow(parent))
        elseif setting == "texture" then
            tinsert(widgetsTable, CreateSetting_Texture(parent))
        elseif setting == "auras" or setting == "blacklist" or setting == "spells" then
            tinsert(widgetsTable, CreateSetting_Auras(parent))
        elseif setting == "auras2" or setting == "bigDebuffs" then
            tinsert(widgetsTable, CreateSetting_Auras2(parent))
        else -- tips
            tinsert(widgetsTable, CreateSetting_Tips(parent, setting))
        end
    end
    
    return widgetsTable
end