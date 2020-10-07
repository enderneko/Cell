-----------------------------------------
-- LibWidgets
-- by KevinSK
-----------------------------------------
local addonName, addon = ...
local L = addon.L
local F = addon.funcs
-- local LPP = LibStub:GetLibrary("LibPixelPerfect")
local LSSB = LibStub:GetLibrary("LibSmoothStatusBar-1.0")

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

function addon:ColorFontStringByPlayerClass(fs)
	fs:SetTextColor(classColor.t[1], classColor.t[2], classColor.t[3])
end

-----------------------------------------
-- Font
-----------------------------------------
local font_title_name = strupper(addonName).."_FONT_WIDGET_TITLE"
local font_title_disable_name = strupper(addonName).."_FONT_WIDGET_TITLE_DISABLE"
local font_name = strupper(addonName).."_FONT_WIDGET"
local font_disable_name = strupper(addonName).."_FONT_WIDGET_DISABLE"
local font_special_name = strupper(addonName).."_FONT_SPECIAL"

local font_title = CreateFont(font_title_name)
font_title:SetFont(GameFontNormal:GetFont(), 14)
font_title:SetTextColor(1, 1, 1, 1)
font_title:SetShadowColor(0, 0, 0)
font_title:SetShadowOffset(1, -1)
font_title:SetJustifyH("CENTER")

local font_title_disable = CreateFont(font_title_disable_name)
font_title_disable:SetFont(GameFontNormal:GetFont(), 14)
font_title_disable:SetTextColor(.4, .4, .4, 1)
font_title_disable:SetShadowColor(0, 0, 0)
font_title_disable:SetShadowOffset(1, -1)
font_title_disable:SetJustifyH("CENTER")

local font = CreateFont(font_name)
font:SetFont(GameFontNormal:GetFont(), 13)
font:SetTextColor(1, 1, 1, 1)
font:SetShadowColor(0, 0, 0)
font:SetShadowOffset(1, -1)
font:SetJustifyH("CENTER")

local font_disable = CreateFont(font_disable_name)
font_disable:SetFont(GameFontNormal:GetFont(), 13)
font_disable:SetTextColor(.4, .4, .4, 1)
font_disable:SetShadowColor(0, 0, 0)
font_disable:SetShadowOffset(1, -1)
font_disable:SetJustifyH("CENTER")

local font_special = CreateFont(font_special_name)
font_special:SetFont("Interface\\AddOns\\Cell\\Media\\font.ttf", 12)
font_special:SetTextColor(1, 1, 1, 1)
font_special:SetShadowColor(0, 0, 0)
font_special:SetShadowOffset(1, -1)
font_special:SetJustifyH("CENTER")
font_special:SetJustifyV("MIDDLE")

-- local font_large = CreateFont(font_large_name)
-- font_large:SetFont(GameFontNormal:GetFont(), 14)
-- font_large:SetTextColor(1, 1, 1, 1)
-- font_large:SetShadowColor(0, 0, 0)
-- font_large:SetShadowOffset(1, -1)
-- font_large:SetJustifyH("CENTER")

-- local font_large_disable = CreateFont(font_large_disable_name)
-- font_large_disable:SetFont(GameFontNormal:GetFont(), 14)
-- font_large_disable:SetTextColor(.4, .4, .4, 1)
-- font_large_disable:SetShadowColor(0, 0, 0)
-- font_large_disable:SetShadowOffset(1, -1)
-- font_large_disable:SetJustifyH("CENTER")

-----------------------------------------
-- seperator
-----------------------------------------
function addon:CreateSeparator(text, parent, width, color)
	if not color then color = {t={classColor.t[1], classColor.t[2], classColor.t[3], .5}, s=classColor.s} end
	if not width then width = parent:GetWidth()-10 end

	local fs = parent:CreateFontString(nil, "OVERLAY", font_title_name)
	fs:SetJustifyH("LEFT")
	fs:SetTextColor(color.t[1], color.t[2], color.t[3])
	fs:SetText(text)


	local line = parent:CreateTexture()
	line:SetSize(width, 1)
	line:SetColorTexture(unpack(color.t))
	line:SetPoint("TOPLEFT", fs, "BOTTOMLEFT", 0, -2)
	local shadow = parent:CreateTexture()
	shadow:SetSize(width, 1)
	shadow:SetColorTexture(0, 0, 0, 1)
	shadow:SetPoint("TOPLEFT", line, 1, -1)

	return fs
end

-----------------------------------------
-- Frame
-----------------------------------------
function addon:StylizeFrame(frame, color, borderColor)
	if not color then color = {.1, .1, .1, .9} end
	if not borderColor then borderColor = {0, 0, 0, 1} end

	frame:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
    frame:SetBackdropColor(unpack(color))
	frame:SetBackdropBorderColor(unpack(borderColor))
end

function addon:CreateFrame(name, parent, width, height, isTransparent)
	local f = CreateFrame("Frame", name, parent)
	f:Hide()
	if not isTransparent then addon:StylizeFrame(f) end
	f:EnableMouse(true)
	if width and height then f:SetSize(width, height) end
	return f
end

local function SetTooltip(widget, anchor, x, y, ...)
	local tooltips = {...}

	if #tooltips ~= 0 then
		widget:HookScript("OnEnter", function()
			CellTooltip:SetOwner(widget, anchor or "ANCHOR_TOP", x or 0, y or 0)
            CellTooltip:AddLine(tooltips[1])
            for i = 2, #tooltips do
                CellTooltip:AddLine("|cffffffff" .. tooltips[i])
            end
            CellTooltip:Show()
		end)
		widget:HookScript("OnLeave", function()
			CellTooltip:Hide()
		end)
	end
end

-----------------------------------------
-- Button
-----------------------------------------
function addon:CreateButton(parent, text, buttonColor, size, noBorder, noBackground, fontNormal, fontDisable, template, ...)
	local b = CreateFrame("Button", nil, parent, template)
	if parent then b:SetFrameLevel(parent:GetFrameLevel()+1) end
	b:SetText(text)
	b:SetSize(unpack(size))

	local color, hoverColor
	if buttonColor == "red" then
		color = {.6, .1, .1, .6}
		hoverColor = {.6, .1, .1, 1}
	elseif buttonColor == "red-hover" then
		color = {.1, .1, .1, 1}
		hoverColor = {.6, .1, .1, 1}
	elseif buttonColor == "green" then
		color = {.1, .6, .1, .6}
		hoverColor = {.1, .6, .1, 1}
	elseif buttonColor == "green-hover" then
		color = {.1, .1, .1, 1}
		hoverColor = {.1, .6, .1, 1}
	elseif buttonColor == "cyan" then
		color = {0, .9, .9, .6}
		hoverColor = {0, .9, .9, 1}
	elseif buttonColor == "blue" then
		color = {0, .5, .8, .6}
		hoverColor = {0, .5, .8, 1}
	elseif buttonColor == "blue-hover" then
		color = {.1, .1, .1, 1}
		hoverColor = {0, .5, .8, 1}
	elseif buttonColor == "yellow" then
		color = {.7, .7, 0, .6}
		hoverColor = {.7, .7, 0, 1}
	elseif buttonColor == "yellow-hover" then
		color = {.1, .1, .1, 1}
		hoverColor = {.7, .7, 0, 1}
	elseif buttonColor == "class" then
		color = {classColor.t[1], classColor.t[2], classColor.t[3], .3}
		hoverColor = {classColor.t[1], classColor.t[2], classColor.t[3], .6}
	elseif buttonColor == "class-hover" then
		color = {.1, .1, .1, 1}
		hoverColor = {classColor.t[1], classColor.t[2], classColor.t[3], .6}
	elseif buttonColor == "chartreuse" then
		color = {.5, 1, 0, .6}
		hoverColor = {.5, 1, 0, .8}
	elseif buttonColor == "magenta" then
		color = {.6, .1, .6, .6}
		hoverColor = {.6, .1, .6, 1}
	elseif buttonColor == "transparent" then -- drop down item
		color = {0, 0, 0, 0}
		hoverColor = {.5, 1, 0, .7}
	elseif buttonColor == "transparent-white" then -- drop down item
		color = {0, 0, 0, 0}
		hoverColor = {.4, .4, .4, .7}
	elseif buttonColor == "transparent-light" then -- drop down item
		color = {0, 0, 0, 0}
		hoverColor = {.5, 1, 0, .5}
	elseif buttonColor == "transparent-class" then -- drop down item
		color = {0, 0, 0, 0}
		hoverColor = {classColor.t[1], classColor.t[2], classColor.t[3], .6}
	elseif buttonColor == "none" then
		color = {0, 0, 0, 0}
	else
		color = {.1, .1, .1, .7}
		hoverColor = {.5, 1, 0, .6}
	end

	-- keep color & hoverColor
	b.color = color
	b.hoverColor = hoverColor

	local s = b:GetFontString()
	if s then
		s:SetWordWrap(false)
		-- s:SetWidth(size[1])
		s:SetPoint("LEFT")
		s:SetPoint("RIGHT")

		function b:SetTextColor(...)
			s:SetTextColor(...)
		end
	end
	
	if noBorder then
		b:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
	else
		b:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left=1,top=1,right=1,bottom=1}})
	end
	
	if buttonColor and string.find(buttonColor, "transparent") then -- drop down item
		-- b:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
		if s then
			s:SetJustifyH("LEFT")
			s:SetPoint("LEFT", 5, 0)
			s:SetPoint("RIGHT", -5, 0)
		end
		b:SetBackdropBorderColor(1, 1, 1, 0)
		b:SetPushedTextOffset(0, 0)
	else
		if not noBackground then
			local bg = parent:CreateTexture(nil, "BACKGROUND")
			b.bg = bg
			bg:SetAllPoints(b)
			bg:SetColorTexture(.1, .1, .1, 1)
		end

    	b:SetBackdropBorderColor(0, 0, 0, 1)
		b:SetPushedTextOffset(0, -1)
	end


	b:SetBackdropColor(unpack(color)) 
	b:SetDisabledFontObject(fontDisable or font_disable)
    b:SetNormalFontObject(fontNormal or font)
	b:SetHighlightFontObject(fontNormal or font)
	
	if buttonColor ~= "none" then
		b:SetScript("OnEnter", function(self) self:SetBackdropColor(unpack(self.hoverColor)) end)
		b:SetScript("OnLeave", function(self) self:SetBackdropColor(unpack(self.color)) end)
	end

	-- click sound
	b:SetScript("PostClick", function() PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON) end)

	SetTooltip(b, "ANCHOR_TOPLEFT", 0, 3, ...)

	return b
end

-----------------------------------------
-- Button Group
-----------------------------------------
function addon:CreateButtonGroup(buttons, onClick, func1, func2)
	local function HighlightButton(id)
		for _, b in ipairs(buttons) do
			if id == b.id then
				b:SetBackdropColor(unpack(b.hoverColor))
				b:SetScript("OnEnter", function()
					if b.ShowTooltip then b.ShowTooltip(b) end
				end)
				b:SetScript("OnLeave", function()
					if b.HideTooltip then b.HideTooltip() end
				end)
				if func1 then func1(b.id) end
			else
				b:SetBackdropColor(unpack(b.color))
				b:SetScript("OnEnter", function() 
					if b.ShowTooltip then b.ShowTooltip(b) end
					b:SetBackdropColor(unpack(b.hoverColor))
				end)
				b:SetScript("OnLeave", function() 
					if b.HideTooltip then b.HideTooltip() end
					b:SetBackdropColor(unpack(b.color))
				end)
				if func2 then func2(b.id) end
			end
		end
	end
	
	for _, b in ipairs(buttons) do
		b:SetScript("OnClick", function()
			HighlightButton(b.id)
			onClick(b.id)
		end)
	end
	
	buttons.HighlightButton = HighlightButton

	return buttons
end

-----------------------------------------
-- check button
-----------------------------------------
function addon:CreateCheckButton(parent, label, onClick, ...)
	-- InterfaceOptionsCheckButtonTemplate --> FrameXML\InterfaceOptionsPanels.xml line 19
	-- OptionsBaseCheckButtonTemplate -->  FrameXML\OptionsPanelTemplates.xml line 10
	
	local cb = CreateFrame("CheckButton", nil, parent)
	cb.onClick = onClick
	cb:SetScript("OnClick", function(self)
		PlaySound(self:GetChecked() and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		if cb.onClick then cb.onClick(self:GetChecked() and true or false, self) end
	end)
	
	cb.label = cb:CreateFontString(nil, "ARTWORK", font_name)
	cb.label:SetText(label)
	cb.label:SetPoint("LEFT", cb, "RIGHT", 5, 0)
	-- cb.label:SetTextColor(classColor.t[1], classColor.t[2], classColor.t[3])
	
	cb:SetSize(14, 14)
	cb:SetHitRectInsets(0, -cb.label:GetStringWidth(), 0, 0)

	cb:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
	cb:SetBackdropColor(.1, .1, .1, .9)
	cb:SetBackdropBorderColor(0, 0, 0, 1)

	local checkedTexture = cb:CreateTexture(nil, "ARTWORK")
	checkedTexture:SetColorTexture(classColor.t[1], classColor.t[2], classColor.t[3], .7)
	checkedTexture:SetPoint("CENTER")
	checkedTexture:SetSize(12, 12)
	
	cb:SetCheckedTexture(checkedTexture)
	-- cb:SetHighlightTexture([[Interface\AddOns\Cell\Media\CheckBox\CheckBox-Highlight-16x16]], "ADD")
	-- cb:SetDisabledCheckedTexture([[Interface\AddOns\Cell\Media\CheckBox\CheckBox-DisabledChecked-16x16]])

	cb:SetScript("OnEnable", function()
		cb.label:SetTextColor(1, 1, 1)
		checkedTexture:SetColorTexture(classColor.t[1], classColor.t[2], classColor.t[3], .7)
	end)

	cb:SetScript("OnDisable", function()
		cb.label:SetTextColor(.4, .4, .4)
		checkedTexture:SetColorTexture(.4, .4, .4)
	end)
	
	SetTooltip(cb, "ANCHOR_TOPLEFT", 0, 1, ...)

	return cb
end

-----------------------------------------
-- editbox
-----------------------------------------
function addon:CreateEditBox(parent, width, height, isTransparent, isMultiLine, isNumeric, font)
	local eb = CreateFrame("EditBox", nil, parent)
	if not isTransparent then addon:StylizeFrame(eb, {.1, .1, .1, .9}) end
	eb:SetFontObject(font or font_name)
	eb:SetMultiLine(isMultiLine)
	eb:SetMaxLetters(0)
	eb:SetJustifyH("LEFT")
	eb:SetJustifyV("CENTER")
	eb:SetWidth(width or 0)
	eb:SetHeight(height or 0)
	eb:SetTextInsets(5, 5, 0, 0)
	eb:SetAutoFocus(false)
	eb:SetNumeric(isNumeric)
	eb:SetScript("OnEscapePressed", function() eb:ClearFocus() end)
	eb:SetScript("OnEnterPressed", function() eb:ClearFocus() end)
	eb:SetScript("OnEditFocusGained", function() eb:HighlightText() end)
	eb:SetScript("OnEditFocusLost", function() eb:HighlightText(0, 0) end)
	eb:SetScript("OnDisable", function() eb:SetTextColor(.7, .7, .7, 1) end)
	eb:SetScript("OnEnable", function() eb:SetTextColor(1, 1, 1, 1) end)

	return eb
end

-----------------------------------------
-- slider 2020-08-25 02:49:16
-----------------------------------------
-- Interface\FrameXML\OptionsPanelTemplates.xml, line 76, OptionsSliderTemplate
function addon:CreateSlider(name, parent, low, high, width, step, onValueChangedFn, afterValueChangedFn)
    local slider = CreateFrame("Slider", nil, parent)
    slider:SetMinMaxValues(low, high)
	slider:SetValue(low)
    slider:SetValueStep(step)
	slider:SetObeyStepOnDrag(true)
	slider:SetOrientation("HORIZONTAL")
	slider:SetSize(width, 10)

	addon:StylizeFrame(slider)
	
	local nameText = slider:CreateFontString(nil, "OVERLAY", font_name)
	nameText:SetText(name)
	nameText:SetPoint("BOTTOM", slider, "TOP", 0, 2)

	local currentText = slider:CreateFontString(nil, "OVERLAY", font_name)
	currentText:SetText(slider:GetValue())
	currentText:SetPoint("TOP", slider, "BOTTOM")

	local lowText = slider:CreateFontString(nil, "OVERLAY", font_name)
	lowText:SetText(colors.grey.s..low)
	lowText:SetPoint("TOPLEFT", slider, "BOTTOMLEFT")

	local hightText = slider:CreateFontString(nil, "OVERLAY", font_name)
	hightText:SetText(colors.grey.s..high)
	hightText:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT")

	local tex = slider:CreateTexture(nil, "ARTWORK")
	tex:SetColorTexture(classColor.t[1], classColor.t[2], classColor.t[3], .7)
	tex:SetSize(8, 8)
	slider:SetThumbTexture(tex)
	slider:SetScript("OnEnter", function()
		tex:SetColorTexture(classColor.t[1], classColor.t[2], classColor.t[3], 1)
	end)
	slider:SetScript("OnLeave", function()
		tex:SetColorTexture(classColor.t[1], classColor.t[2], classColor.t[3], .7)
	end)

	slider.onValueChangedFn = onValueChangedFn
	slider.afterValueChangedFn = afterValueChangedFn
	
    -- if tooltip then slider.tooltipText = tooltip end

	local oldValue
	slider:SetScript("OnValueChanged", function(self, value, userChanged)
		if oldValue == value then return end
		oldValue = value

		if math.floor(value) < value then -- decimal
			value = tonumber(string.format("%.1f", value))
		end

		currentText:SetText(value)
        if userChanged and slider.onValueChangedFn then slider.onValueChangedFn(value) end
	end)

	local valueBeforeClick
	slider:HookScript("OnEnter", function(self, button, isMouseOver)
		valueBeforeClick = slider:GetValue()
	end)

	slider:SetScript("OnMouseUp", function(self, button, isMouseOver)
		-- oldValue here == newValue, OnMouseUp called after OnValueChanged
		if valueBeforeClick ~= oldValue and slider.afterValueChangedFn then
			valueBeforeClick = oldValue
			slider.afterValueChangedFn(slider:GetValue())
		end
	end)

	slider:EnableMouseWheel(true)
	slider:SetScript("OnMouseWheel", function(self, delta)
		if not IsShiftKeyDown() then return end

		-- NOTE: OnValueChanged may not be called: value == low
		oldValue = oldValue and oldValue or low

		local value
		if delta == 1 then -- scroll up
			value = oldValue + step
			value = value > high and high or value
		elseif delta == -1 then -- scroll down
			value = oldValue - step
			value = value < low and low or value
		end
		
		if value ~= oldValue then
			slider:SetValue(value)
			if slider.onValueChangedFn then slider.onValueChangedFn(value) end
			if slider.afterValueChangedFn then slider.afterValueChangedFn(value) end
		end
	end)
	
	return slider
end

-----------------------------------------
-- status bar
-----------------------------------------
function addon:CreateStatusBar(parent, width, height, maxValue, smooth, func, showText, texture, color)
	local bar = CreateFrame("StatusBar", nil, parent)

	if not color then color = {classColor.t[1], classColor.t[2], classColor.t[3], 1} end
	if not texture then
		local tex = bar:CreateTexture(nil, "ARTWORK")
		tex:SetColorTexture(1, 1, 1, 1)

		bar:SetStatusBarTexture(tex)
		bar:SetStatusBarColor(unpack(color))
	else
		bar:SetStatusBarTexture(texture)
		bar:SetStatusBarColor(unpack(color))
	end
	
	-- bar:GetStatusBarTexture():SetHorizTile(false)
	bar:SetWidth(width)
	bar:SetHeight(height)
	bar:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = -1})
	bar:SetBackdropColor(.07, .07, .07, .9)
	bar:SetBackdropBorderColor(0, 0, 0, 1)

	if showText then
		bar.text = bar:CreateFontString(nil, "OVERLAY", font_name)
		bar.text:SetJustifyH("CENTER")
		bar.text:SetJustifyV("MIDDLE")
		bar.text:SetPoint("CENTER")
		bar.text:SetText("0%")
	end

	bar:SetMinMaxValues(0, maxValue)
	bar:SetValue(0)
	if smooth then LSSB:SmoothBar(bar) end -- smooth progress bar

	function bar:SetMaxValue(m)
		maxValue = m
		bar:SetMinMaxValues(0, m)
	end
	
	function bar:Reset()
		LSSB:ResetBar(bar) -- disable smooth
		bar:SetValue(0)
		LSSB:SmoothBar(bar) -- re-enable smooth
	end

	bar:SetScript("OnValueChanged", function(self, value)
		if showText then
			bar.text:SetText(format("%d%%", value / maxValue * 100))
		end
		
		if func then func() end
	end)

	bar:SetScript("OnHide", function()
		if smooth then
			bar:Reset()
		end
	end)

	return bar
end

function addon:CreateStatusBarButton(parent, text, size, maxValue, template)
	local b = Cell:CreateButton(parent, text, "class-hover", size, false, true, nil, nil, template)
	b:SetFrameLevel(parent:GetFrameLevel()+2)
	b:SetBackdropColor(0, 0, 0, 0)
	b:SetScript("OnEnter", function()
		b:SetBackdropBorderColor(unpack(classColor.t))
	end)
	b:SetScript("OnLeave", function()
		b:SetBackdropBorderColor(0, 0, 0, 1)
	end)

	
	local bar = CreateFrame("StatusBar", nil, parent)
	bar:SetParent(b)
	b.bar = bar
	bar:SetPoint("TOPLEFT", b)
	bar:SetPoint("BOTTOMRIGHT", b)
	bar:SetStatusBarTexture("Interface\\AddOns\\Cell\\Media\\statusbar.tga")
	bar:SetStatusBarColor(classColor.t[1], classColor.t[2], classColor.t[3], .5)
	bar:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
	bar:SetBackdropColor(.1, .1, .1, 1)
	bar:SetBackdropBorderColor(0, 0, 0, 0)
	bar:SetSize(unpack(size))
	bar:SetMinMaxValues(0, maxValue)
	bar:SetValue(0)
	bar:SetFrameLevel(parent:GetFrameLevel()+1)
	
	function b:Start()
		bar:SetValue(select(2, bar:GetMinMaxValues()))
		bar:SetScript("OnUpdate", function(self, elapsed)
			bar:SetValue(bar:GetValue()-elapsed)
			if bar:GetValue() <= 0 then
				b:Stop()
			end
		end)
	end

	function b:Stop()
		bar:SetValue(0)
		bar:SetScript("OnUpdate", nil)
	end

	function b:SetMaxValue(value)
		bar:SetMinMaxValues(0, value)
		bar:SetValue(value)
	end
	
	return b
end

-----------------------------------------
-- mask
-----------------------------------------
function addon:CreateMask(parent, text, points) -- points = {topleftX, topleftY, bottomrightX, bottomrightY}
	if not parent.mask then -- not init
		parent.mask = CreateFrame("Frame", nil, parent)
		addon:StylizeFrame(parent.mask, {.15, .15, .15, .7}, {0, 0, 0, 0})
		parent.mask:SetFrameStrata("HIGH")
		parent.mask:SetFrameLevel(100)
		parent.mask:EnableMouse(true) -- can't click-through

		parent.mask.text = parent.mask:CreateFontString(nil, "OVERLAY", font_title_name)
		parent.mask.text:SetTextColor(1, .2, .2)
		parent.mask.text:SetPoint("LEFT", 5, 0)
		parent.mask.text:SetPoint("RIGHT", -5, 0)

		-- parent.mask:SetScript("OnUpdate", function()
		-- 	if not parent:IsVisible() then
		-- 		parent.mask:Hide()
		-- 	end
		-- end)
	end

	if not text then text = "" end
	parent.mask.text:SetText(text)

	parent.mask:ClearAllPoints() -- prepare for SetPoint()
	if points then
		local tlX, tlY, brX, brY = unpack(points)
		parent.mask:SetPoint("TOPLEFT", tlX, tlY)
		parent.mask:SetPoint("BOTTOMRIGHT", brX, brY)
	else
		parent.mask:SetAllPoints(parent) -- anchor points are set to those of its "parent"
	end
	parent.mask:Show()
end

-----------------------------------------
-- create popup (delete/edit/... confirm) with mask
-----------------------------------------
function addon:CreateConfirmPopup(parent, width, text, onAccept, mask, hasEditBox, dropdowns)
	if not parent.confirmPopup then -- not init
		parent.confirmPopup = CreateFrame("Frame", nil, parent)
		parent.confirmPopup:SetSize(width, 100)
		addon:StylizeFrame(parent.confirmPopup, {.1, .1, .1, .95}, {classColor.t[1], classColor.t[2], classColor.t[3], .7})
		parent.confirmPopup:SetFrameStrata("DIALOG")
		parent.confirmPopup:SetFrameLevel(2)
		parent.confirmPopup:Hide()
		
		parent.confirmPopup:SetScript("OnHide", function()
			parent.confirmPopup:Hide()
			-- hide mask
			if mask and parent.mask then parent.mask:Hide() end
		end)

		parent.confirmPopup:SetScript("OnShow", function ()
			C_Timer.After(.2, function()
				parent.confirmPopup:SetScript("OnUpdate", nil)
			end)
		end)
		
		parent.confirmPopup.text = parent.confirmPopup:CreateFontString(nil, "OVERLAY", font_title_name)
		parent.confirmPopup.text:SetWordWrap(true)
		parent.confirmPopup.text:SetSpacing(3)
		parent.confirmPopup.text:SetJustifyH("CENTER")
		parent.confirmPopup.text:SetPoint("TOPLEFT", 5, -8)
		parent.confirmPopup.text:SetPoint("TOPRIGHT", -5, -8)

		-- yes
		parent.confirmPopup.button1 = addon:CreateButton(parent.confirmPopup, L["Yes"], "green", {35, 15})
		-- button1:SetPoint("BOTTOMRIGHT", -45, 0)
		parent.confirmPopup.button1:SetPoint("BOTTOMRIGHT", -34, 0)
		parent.confirmPopup.button1:SetBackdropBorderColor(classColor.t[1], classColor.t[2], classColor.t[3], .7)
		-- no
		parent.confirmPopup.button2 = addon:CreateButton(parent.confirmPopup, L["No"], "red", {35, 15})
		parent.confirmPopup.button2:SetPoint("LEFT", parent.confirmPopup.button1, "RIGHT", -1, 0)
		parent.confirmPopup.button2:SetBackdropBorderColor(classColor.t[1], classColor.t[2], classColor.t[3], .7)
	end

	if hasEditBox then
		if not parent.confirmPopup.editBox then
			parent.confirmPopup.editBox = addon:CreateEditBox(parent.confirmPopup, width-40, 20)
			parent.confirmPopup.editBox:SetPoint("TOP", parent.confirmPopup.text, "BOTTOM", 0, -5)
			parent.confirmPopup.editBox:SetAutoFocus(true)
			parent.confirmPopup.editBox:SetScript("OnHide", function()
				parent.confirmPopup.editBox:SetText("")
			end)
		end
		parent.confirmPopup.editBox:Show()
		-- disable yes if editBox empty
		parent.confirmPopup.editBox:SetScript("OnTextChanged", function()
			if not parent.confirmPopup.editBox:GetText() or strtrim(parent.confirmPopup.editBox:GetText()) == "" then
				parent.confirmPopup.button1:SetEnabled(false)
			else
				parent.confirmPopup.button1:SetEnabled(true)
			end
		end)
	elseif parent.confirmPopup.editBox then
		parent.confirmPopup.editBox:Hide()
		parent.confirmPopup.editBox:SetScript("OnTextChanged", nil)
		parent.confirmPopup.button1:SetEnabled(true)
	end

	if dropdowns then
		if not parent.confirmPopup.dropdown1 then
			parent.confirmPopup.dropdown1 = addon:CreateDropdown(parent.confirmPopup, width-40)
			parent.confirmPopup.dropdown1:SetPoint("LEFT", 20, 0)
			if hasEditBox then
				parent.confirmPopup.dropdown1:SetPoint("TOP", parent.confirmPopup.editBox, "BOTTOM", 0, -5)
			else
				parent.confirmPopup.dropdown1:SetPoint("TOP", parent.confirmPopup.text, "BOTTOM", 0, -5)
			end
		end
		if not parent.confirmPopup.dropdown2 then
			parent.confirmPopup.dropdown2 = addon:CreateDropdown(parent.confirmPopup, (width-40)/2-3)
			parent.confirmPopup.dropdown2:SetPoint("LEFT", parent.confirmPopup.dropdown1, "RIGHT", 5, 0)
		end

		if dropdowns == 1 then
			parent.confirmPopup.dropdown1:Show()
			parent.confirmPopup.dropdown2:Hide()
		elseif dropdowns == 2 then
			parent.confirmPopup.dropdown1:Show()
			parent.confirmPopup.dropdown2:Show()
			parent.confirmPopup.dropdown1:SetWidth((width-40)/2-2)
		end
	elseif parent.confirmPopup.dropdown1 then
		parent.confirmPopup.dropdown1:Hide()
		parent.confirmPopup.dropdown2:Hide()
	end

	if mask then -- show mask?
		if not parent.mask then
			addon:CreateMask(parent)
		else
			parent.mask:Show()
		end
	end

	parent.confirmPopup.button1:SetScript("OnClick", function()
		if onAccept then onAccept(parent.confirmPopup) end
		-- hide mask
		if mask and parent.mask then parent.mask:Hide() end
		parent.confirmPopup:Hide()
	end)

	parent.confirmPopup.button2:SetScript("OnClick", function()
		-- hide mask
		if mask and parent.mask then parent.mask:Hide() end
		parent.confirmPopup:Hide()
	end)
	
	parent.confirmPopup:SetWidth(width)
	parent.confirmPopup.text:SetText(text)

	-- update height
	parent.confirmPopup:SetScript("OnUpdate", function(self, elapsed)
		local newHeight = parent.confirmPopup.text:GetStringHeight() + 30
		if hasEditBox then newHeight = newHeight + 30 end
		if dropdowns then newHeight = newHeight + 30 end
		parent.confirmPopup:SetHeight(newHeight)
	end)

	parent.confirmPopup:SetScript("OnShow", function()
		C_Timer.After(2, function()
			parent.confirmPopup:SetScript("OnUpdate", nil)
		end)
	end)

	parent.confirmPopup:ClearAllPoints() -- prepare for SetPoint()
	parent.confirmPopup:Show()

	return parent.confirmPopup
end

-----------------------------------------
-- popup edit box
-----------------------------------------
function addon:CreatePopupEditBox(parent, width, func, multiLine)
	if not addon.popupEditBox then
		local eb = CreateFrame("EditBox", addonName.."PopupEditBox")
		addon.popupEditBox = eb
		eb:Hide()
		eb:SetWidth(width)
		eb:SetAutoFocus(true)
		eb:SetFontObject(font)
		eb:SetJustifyH("LEFT")
		eb:SetMultiLine(true)
		eb:SetMaxLetters(255)
		eb:SetTextInsets(5, 5, 3, 4)
		eb:SetPoint("TOPLEFT")
		eb:SetPoint("TOPRIGHT")
		addon:StylizeFrame(eb, {.1, .1, .1, 1}, {classColor.t[1], classColor.t[2], classColor.t[3], 1})
		
		eb:SetScript("OnHide", function()
			eb:Hide() -- hide self when parent hides
		end)

		eb:SetScript("OnEscapePressed", function()
			eb:SetText("")
			eb:Hide()
		end)

		function eb:ShowEditBox(text)
			eb:SetText(text)
			eb:Show()
		end

		local tipsText = eb:CreateFontString(nil, "OVERLAY", font_name)
		tipsText:SetPoint("TOPLEFT", eb, "BOTTOMLEFT", 2, -1)
		tipsText:SetJustifyH("LEFT")
		-- tipsText:SetText("|cff777777"..L["Shift+Enter: add a new line\nEnter: apply\nESC: discard"])

		function eb:SetTips(text)
			tipsText:SetText(text)
		end

		local tipsBackground = CreateFrame("Frame", nil, eb)
		tipsBackground:SetPoint("TOPLEFT", eb, "BOTTOMLEFT")
		tipsBackground:SetPoint("TOPRIGHT", eb, "BOTTOMRIGHT")
		tipsBackground:SetPoint("BOTTOM", tipsText, 0, -2)
		-- tipsBackground:SetHeight(41)
		tipsBackground:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
		tipsBackground:SetBackdropColor(.1, .1, .1, .9)
		tipsBackground:SetFrameStrata("HIGH")
	end
	
	addon.popupEditBox:SetScript("OnEnterPressed", function(self)
		if multiLine and IsShiftKeyDown() then -- new line
			self:Insert("\n")
		else
			func(self:GetText())
			self:Hide()
			self:SetText("")
		end
	end)

	-- set parent(for hiding) & size
	addon.popupEditBox:ClearAllPoints()
	addon.popupEditBox:SetParent(parent)
	addon.popupEditBox:SetWidth(width)
	addon.popupEditBox:SetFrameStrata("DIALOG")

	return addon.popupEditBox
end

-----------------------------------------
-- cascaded menu
-----------------------------------------
local menu = addon:CreateFrame(addonName.."CascadedMenu", UIParent, 100, 20)
addon.menu = menu
tinsert(UISpecialFrames, menu:GetName())
menu:SetBackdropColor(.12, .12, .12, 1)
menu:SetBackdropBorderColor(classColor.t[1], classColor.t[2], classColor.t[3], 1)
menu:SetFrameStrata("TOOLTIP")
menu.items = {}

-- items: menu items table
-- itemTable: table to store item buttons --> menu/submenu
-- itemParent: menu/submenu
-- level: menu level, 0, 1, 2, 3, ...
local function CreateItemButtons(items, itemTable, itemParent, level)
	itemParent:SetScript("OnHide", function(self) self:Hide() end)

	for i, item in pairs(items) do
		local b
		if itemTable[i] and itemTable[i]:GetObjectType() == "Button" then
			b = itemTable[i]
			b:SetText(item.text)
			if level == 0 then b:Show() end -- show valid top menu buttons
		else
			b = addon:CreateButton(itemParent, item.text, "transparent-class", {98 ,18}, true)
			tinsert(itemTable, b)
			if i == 1 then
				b:SetPoint("TOPLEFT", 1, -1)
				b:SetPoint("RIGHT", -1, 0)
			else
				b:SetPoint("TOPLEFT", itemTable[i-1], "BOTTOMLEFT")
				b:SetPoint("RIGHT", itemTable[i-1])
			end
		end

		if item.textColor then
			b:GetFontString():SetTextColor(unpack(item.textColor))
		end

		if item.icon then
			if not b.icon then
				b.icon = b:CreateTexture(nil, "ARTWORK")
				b.icon:SetPoint("LEFT", b, 5, 0)
				b.icon:SetSize(14, 14)
				b.icon:SetTexCoord(.08, .92, .08, .92)
			end
			b.icon:SetTexture(item.icon)
			b.icon:Show()
			b:GetFontString():SetPoint("LEFT", b.icon, "RIGHT", 5, 0)
		else
			if b.icon then b.icon:Hide() end
			b:GetFontString():SetPoint("LEFT", 5, 0)
		end

		if level > 0 then
			b:Hide()
			b:SetScript("OnHide", function(self) self:Hide() end)
		end
		
		if item.children then
			-- create sub menu level+1
			if not menu[level+1] then
				-- menu[level+1] parent == menu[level]
				menu[level+1] = addon:CreateFrame(addonName.."CascadedSubMenu"..level, level == 0 and menu or menu[level], 100, 20)
				menu[level+1]:SetBackdropColor(.12, .12, .12, 1)
				menu[level+1]:SetBackdropBorderColor(classColor.t[1], classColor.t[2], classColor.t[3], 1)
				-- menu[level+1]:SetScript("OnHide", function(self) self:Hide() end)
			end

			if not b.childrenSymbol then
				b.childrenSymbol = b:CreateFontString(nil, "OVERLAY", font_name)
				b.childrenSymbol:SetText("|cFF777777>")
				b.childrenSymbol:SetPoint("RIGHT", -5, 0)
			end
			b.childrenSymbol:Show()

			CreateItemButtons(item.children, b, menu[level+1], level+1) -- itemTable == b, insert children to its table
			
			b:SetScript("OnEnter", function()
				b:SetBackdropColor(unpack(b.hoverColor))

				menu[level+1]:Hide()

				menu[level+1]:ClearAllPoints()
				menu[level+1]:SetPoint("TOPLEFT", b, "TOPRIGHT", 2, 1)
				menu[level+1]:Show()

				for _, b in ipairs(b) do
					b:Show()
				end
			end)

			-- clear parent menuItem's onClick
			b:SetScript("OnClick", function()
				PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
			end)
		else
			if b.childrenSymbol then b.childrenSymbol:Hide() end

			b:SetScript("OnEnter", function()
				b:SetBackdropColor(unpack(b.hoverColor))

				if menu[level+1] then menu[level+1]:Hide() end
			end)

			b:SetScript("OnClick", function()
				PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
				menu:Hide()
				if item.onClick then item.onClick(item.text) end
			end)
		end
	end

	-- update menu/submenu height
	itemParent:SetHeight(2 + #items*18)
end

function menu:SetItems(items)
	-- clear topmenu
	for _, b in pairs({menu:GetChildren()}) do
		if b:GetObjectType() == "Button" then
			b:Hide()
		end
	end
	-- create buttons -- items, itemTable, itemParent, level
	CreateItemButtons(items, menu.items, menu, 0)
end

function menu:SetWidths(...)
	local widths = {...}
	menu:SetWidth(widths[1])
	if #widths == 1 then
		for _, m in ipairs(menu) do
			m:SetWidth(widths[1])
		end
	else
		for i, m in ipairs(menu) do
			if widths[i+1] then m:SetWidth(widths[i+1]) end
		end
	end
end

function menu:ShowMenu()
	for i, m in ipairs(menu) do
		m:Hide()
	end
	menu:Show()
end

function menu:SetMenuParent(parent)
	menu:SetParent(parent)
	menu:SetFrameStrata("TOOLTIP")
end

-----------------------------------------------------------------------------------
-- create scroll frame (with scrollbar & content frame) 2017-07-17 08:40:41
-----------------------------------------------------------------------------------
function addon:CreateScrollFrame(parent, top, bottom, color, border)
	-- create scrollFrame & scrollbar seperately (instead of UIPanelScrollFrameTemplate), in order to custom it
	local scrollFrame = CreateFrame("ScrollFrame", parent:GetName() and parent:GetName().."ScrollFrame" or nil, parent)
	parent.scrollFrame = scrollFrame
	top = top or 0
	bottom = bottom or 0
	scrollFrame:SetPoint("TOPLEFT", 0, top) 
	scrollFrame:SetPoint("BOTTOMRIGHT", 0, bottom)

	if color then
		addon:StylizeFrame(scrollFrame, color, border)
	end

	function scrollFrame:Resize(newTop, newBottom)
		top = newTop
		bottom = newBottom
		scrollFrame:SetPoint("TOPLEFT", 0, top) 
		scrollFrame:SetPoint("BOTTOMRIGHT", 0, bottom)
	end
	
	-- content
	local content = CreateFrame("Frame", nil, scrollFrame)
	content:SetSize(scrollFrame:GetWidth(), 10)
	scrollFrame:SetScrollChild(content)
	scrollFrame.content = content
	-- content:SetFrameLevel(2)
	
	-- scrollbar
	local scrollbar = CreateFrame("Frame", nil, scrollFrame)
	scrollbar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 2, 0)
	scrollbar:SetPoint("BOTTOMRIGHT", scrollFrame, 7, 0)
	scrollbar:Hide()
	addon:StylizeFrame(scrollbar, {.1, .1, .1, .8})
	scrollFrame.scrollbar = scrollbar
	
	-- scrollbar thumb
	local scrollThumb = CreateFrame("Frame", nil, scrollbar)
	scrollThumb:SetWidth(5) -- scrollbar's width is 5
	scrollThumb:SetHeight(scrollbar:GetHeight())
	scrollThumb:SetPoint("TOP")
	addon:StylizeFrame(scrollThumb, {classColor.t[1], classColor.t[2], classColor.t[3], .8})
	scrollThumb:EnableMouse(true)
	scrollThumb:SetMovable(true)
	scrollThumb:SetHitRectInsets(-5, -5, 0, 0) -- Frame:SetHitRectInsets(left, right, top, bottom)
	
	-- reset content height manually ==> content:GetBoundsRect() make it right @OnUpdate
	function scrollFrame:ResetHeight()
		content:SetHeight(10)
	end
	
	-- reset to top, useful when used with DropDownMenu (variable content height)
	function scrollFrame:ResetScroll()
		scrollFrame:SetVerticalScroll(0)
	end
	
	-- local scrollRange -- ACCURATE scroll range, for SetVerticalScroll(), instead of scrollFrame:GetVerticalScrollRange()
	function scrollFrame:VerticalScroll(step)
		local scroll = scrollFrame:GetVerticalScroll() + step
		-- if CANNOT SCROLL then scroll = -25/25, scrollFrame:GetVerticalScrollRange() = 0
		-- then scrollFrame:SetVerticalScroll(0) and scrollFrame:SetVerticalScroll(scrollFrame:GetVerticalScrollRange()) ARE THE SAME
		if scroll <= 0 then
			scrollFrame:SetVerticalScroll(0)
		elseif  scroll >= scrollFrame:GetVerticalScrollRange() then
			scrollFrame:SetVerticalScroll(scrollFrame:GetVerticalScrollRange())
		else
			scrollFrame:SetVerticalScroll(scroll)
		end
	end

	-- NOTE: this func should not be called before Show, or GetVerticalScrollRange will be incorrect.
	function scrollFrame:ScrollToBottom()
		scrollFrame:SetVerticalScroll(scrollFrame:GetVerticalScrollRange())
	end

	function scrollFrame:SetContentHeight(height, num, spacing)
		if num and spacing then
			content:SetHeight(num*height+(num-1)*spacing)
		else
			content:SetHeight(height)
		end
	end

	--[[ BUG: not reliable
	-- to remove/hide widgets "widget:SetParent(nil)" MUST be called!!!
	scrollFrame:SetScript("OnUpdate", function()
		-- set content height, check if it CAN SCROLL
		local x, y, w, h = content:GetBoundsRect()
		-- NOTE: if content is not IN SCREEN -> x,y<0 -> h==-y!
		if x > 0 and y > 0 then
			content:SetHeight(h)
		end
	end)
	]]
	
	-- stores all widgets on content frame
	-- local autoWidthWidgets = {}

	function scrollFrame:ClearContent()
		for _, c in pairs({content:GetChildren()}) do
			c:SetParent(nil)  -- or it will show (OnUpdate)
			c:ClearAllPoints()
			c:Hide()
		end
		-- wipe(autoWidthWidgets)
		scrollFrame:ResetHeight()
	end

	function scrollFrame:Reset()
		scrollFrame:ResetScroll()
		scrollFrame:ClearContent()
	end
	
	-- function scrollFrame:SetWidgetAutoWidth(widget)
	-- 	table.insert(autoWidthWidgets, widget)
	-- end
	
	-- on width changed, make the same change to widgets
	scrollFrame:SetScript("OnSizeChanged", function()
		-- change widgets width (marked as auto width)
		-- for i = 1, #autoWidthWidgets do
		-- 	autoWidthWidgets[i]:SetWidth(scrollFrame:GetWidth())
		-- end
		
		-- update content width
		content:SetWidth(scrollFrame:GetWidth())
	end)

	-- check if it can scroll
	content:SetScript("OnSizeChanged", function()
		-- set ACCURATE scroll range
		-- scrollRange = content:GetHeight() - scrollFrame:GetHeight()

		-- set thumb height (%)
		local p = scrollFrame:GetHeight() / content:GetHeight()
		p = tonumber(string.format("%.3f", p))
		if p < 1 then -- can scroll
			scrollThumb:SetHeight(scrollbar:GetHeight()*p)
			-- space for scrollbar
			scrollFrame:SetPoint("BOTTOMRIGHT", parent, -7, bottom)
			scrollbar:Show()
		else
			scrollFrame:SetPoint("BOTTOMRIGHT", parent, 0, bottom)
			scrollbar:Hide()
			if scrollFrame:GetVerticalScroll() > 0 then scrollFrame:SetVerticalScroll(0) end
		end
	end)

	-- DO NOT USE OnScrollRangeChanged to check whether it can scroll.
	-- "invisible" widgets should be hidden, then the scroll range is NOT accurate!
	-- scrollFrame:SetScript("OnScrollRangeChanged", function(self, xOffset, yOffset) end)
	
	-- dragging and scrolling
	scrollThumb:SetScript("OnMouseDown", function(self, button)
		if button ~= 'LeftButton' then return end
		local offsetY = select(5, scrollThumb:GetPoint(1))
		local mouseY = select(2, GetCursorPosition())
		local currentScroll = scrollFrame:GetVerticalScroll()
		self:SetScript("OnUpdate", function(self)
			--------------------- y offset before dragging + mouse offset
			local newOffsetY = offsetY + (select(2, GetCursorPosition()) - mouseY)
			
			-- even scrollThumb:SetPoint is already done in OnVerticalScroll, but it's useful in some cases.
			if newOffsetY >= 0 then -- @top
				scrollThumb:SetPoint("TOP")
				newOffsetY = 0
			elseif (-newOffsetY) + scrollThumb:GetHeight() >= scrollbar:GetHeight() then -- @bottom
				scrollThumb:SetPoint("TOP", 0, -(scrollbar:GetHeight() - scrollThumb:GetHeight()))
				newOffsetY = -(scrollbar:GetHeight() - scrollThumb:GetHeight())
			else
				scrollThumb:SetPoint("TOP", 0, newOffsetY)
			end
			local vs = (-newOffsetY / (scrollbar:GetHeight()-scrollThumb:GetHeight())) * scrollFrame:GetVerticalScrollRange()
			scrollFrame:SetVerticalScroll(vs)
		end)
	end)

	scrollThumb:SetScript("OnMouseUp", function(self)
		self:SetScript("OnUpdate", nil)
	end)
	
	scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
		if scrollFrame:GetVerticalScrollRange() ~= 0 then
			local scrollP = scrollFrame:GetVerticalScroll()/scrollFrame:GetVerticalScrollRange()
			local yoffset = -((scrollbar:GetHeight()-scrollThumb:GetHeight())*scrollP)
			scrollThumb:SetPoint("TOP", 0, yoffset)
		end
	end)
	
	local step = 25
	function scrollFrame:SetScrollStep(s)
		step = s
	end
	
	-- enable mouse wheel scroll
	scrollFrame:EnableMouseWheel(true)
	scrollFrame:SetScript("OnMouseWheel", function(self, delta)
		if delta == 1 then -- scroll up
			scrollFrame:VerticalScroll(-step)
		elseif delta == -1 then -- scroll down
			scrollFrame:VerticalScroll(step)
		end
	end)
	
	return scrollFrame
end

------------------------------------------------
-- dropdown menu 2020-09-07
------------------------------------------------
local list = CreateFrame("Frame", addonName.."DropdownList")
addon:StylizeFrame(list, {.1, .1, .1, 1})
list:Hide()
list:SetScript("OnShow", function()
	list:SetScale(list.menu:GetEffectiveScale())
	list:SetFrameStrata(list.menu:GetFrameStrata())
	list:SetFrameLevel(77) -- top of its strata
end)
list:SetScript("OnHide", function() list:Hide() end)

-- close dropdown
function addon:RegisterForCloseDropdown(button)
	button:HookScript("OnClick", function()
		list:Hide()
	end)
end

-- store created buttons
list.items = {}
addon:CreateScrollFrame(list)
list.scrollFrame:SetScrollStep(18)

-- highlight
local hightlightTexture = CreateFrame("Frame", nil, list)
hightlightTexture:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
hightlightTexture:SetBackdropBorderColor(unpack(classColor.t))
hightlightTexture:Hide()

local function SetHighlightItem(i)
	if not i then
		hightlightTexture:ClearAllPoints()
		hightlightTexture:Hide()
	else
		hightlightTexture:SetParent(list.items[i]) -- buttons show/hide automatically when scroll, so let hightlightTexture to be the same
		hightlightTexture:ClearAllPoints()
		hightlightTexture:SetAllPoints(list.items[i])
		hightlightTexture:Show()
	end
end

function addon:CreateDropdown(parent, width, dropdownType)
	local menu = CreateFrame("Frame", nil, parent)
	menu:SetSize(width, 20)
	menu:EnableMouse(true)
	-- menu:SetFrameLevel(5)
	addon:StylizeFrame(menu)
	
	-- button: open/close menu list
	menu.button = addon:CreateButton(menu, "", "transparent-class", {18 ,20})
	addon:StylizeFrame(menu.button)
	menu.button:SetPoint("RIGHT")
	menu.button:SetFrameLevel(menu:GetFrameLevel()+1)
	menu.button:SetNormalTexture([[Interface\AddOns\Cell\Media\dropdown]])
	menu.button:SetPushedTexture([[Interface\AddOns\Cell\Media\dropdown-pushed]])
	menu.button:SetDisabledTexture([[Interface\AddOns\Cell\Media\dropdown-disabled]])

	-- selected item
	menu.text = menu:CreateFontString(nil, "OVERLAY", font_name)
	menu.text:SetJustifyV("MIDDLE")
	menu.text:SetJustifyH("LEFT")
	menu.text:SetWordWrap(false)
	menu.text:SetPoint("TOPLEFT", 5, -1)
	menu.text:SetPoint("BOTTOMRIGHT", -18, 1)

	if dropdownType == "texture" then
		menu.texture = menu:CreateTexture(nil, "ARTWORK")
		menu.texture:SetPoint("TOPLEFT", 1, -1)
		menu.texture:SetPoint("BOTTOMRIGHT", -18, 1)
		menu.texture:SetVertexColor(1, 1, 1, .7)
	end
	
	-- keep all menu item buttons
	menu.items = {}

	-- index in items
	-- menu.selected
	
	function menu:SetSelected(text, value)
		for i, item in pairs(menu.items) do
			if item.text == text then
				-- store index for list
				menu.selected = i
				menu.text:SetText(text)
				if dropdownType == "texture" then
					menu.texture:SetTexture(value)
				elseif dropdownType == "font" then
					menu.text:SetFont(value, 13)
				end
				break
			end
		end
	end

	function menu:GetSelected()
		if menu.selected then
			return menu.items[menu.selected].value or menu.items[menu.selected].text
		end
		return nil
	end

	function menu:SetSelectedItem(itemNum)
		local item = menu.items[itemNum]
		menu.text:SetText(item.text)
		menu.selected = itemNum
	end

	-- items = {
	-- 	{
	-- 		["text"] = (string),
	-- 		["texture"] = (string),
	-- 		["font"] = (string),
	-- 		["onClick"] = (function)
	-- 	},
	-- }
	function menu:SetItems(items)
		menu.items = items
	end

	function menu:AddItem(item)
		tinsert(menu.items, item)
		menu.reloadRequired = true
	end

	function menu:RemoveCurrentItem()
		tremove(menu.items, menu.selected)
		menu.reloadRequired = true
	end

	function menu:SetCurrentItem(item)
		menu.items[menu.selected] = item
		-- usually, update current item means to change its name (text) and func
		menu.text:SetText(item["text"])
		menu.reloadRequired = true
	end

	local function LoadItems()
		-- hide highlight
		SetHighlightItem()
		-- hide all list items
		list.scrollFrame:Reset()

		-- load current dropdown
		for i, item in pairs(menu.items) do
			local b
			if not list.items[i] then
				-- init
				b = addon:CreateButton(list.scrollFrame.content, item.text, "transparent-class", {18 ,18}, true) --! width is not important
				table.insert(list.items, b)

				-- texture
				b.texture = b:CreateTexture(nil, "ARTWORK")
				b.texture:SetPoint("TOPLEFT", 1, -1)
				b.texture:SetPoint("BOTTOMRIGHT", -1, 1)
				b.texture:SetVertexColor(1, 1, 1, .7)
				b.texture:Hide()
			else
				b = list.items[i]
				b:SetText(item.text)
			end

			-- texture
			if item.texture then
				b.texture:SetTexture(item.texture)
				b.texture:Show()
			else
				b.texture:Hide()
			end

			-- font
			local f, s = font:GetFont()
			if item.font then
				b:GetFontString():SetFont(item.font, s)
			else
				b:GetFontString():SetFont(f, s)
			end

			-- highlight
			if menu.selected == i then
				SetHighlightItem(i)
			end

			b:SetScript("OnClick", function()
				PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
				if dropdownType == "texture" then
					menu:SetSelected(item.text, item.texture)
				elseif dropdownType == "font" then
					menu:SetSelected(item.text, item.font)
				else
					menu:SetSelected(item.text)
				end
				list:Hide()
				if item.onClick then item.onClick(item.text) end
			end)

			-- update point
			b:SetParent(list.scrollFrame.content)
			b:Show()
			b:SetPoint("LEFT", 1, 0)
			b:SetPoint("RIGHT", -1, 0)
			if i == 1 then
				b:SetPoint("TOP", 0, -1)
			else
				b:SetPoint("TOP", list.items[i-1], "BOTTOM", 0, 0)
			end
		end

		-- update list size
		list.menu = menu -- menu's OnHide -> list:Hide
		list:ClearAllPoints()
		list:SetPoint("TOP", menu, "BOTTOM", 0, -2)
		
		if #menu.items == 0 then
			list:SetSize(menu:GetWidth(), 5)
		elseif #menu.items <= 10 then
			list:SetSize(menu:GetWidth(), 2 + #menu.items*18)
		else
			list:SetSize(menu:GetWidth(), 182)
			-- update list scrollFrame
			list.scrollFrame:SetContentHeight(2 + #menu.items*18)
		end
	end

	function menu:SetEnabled(f)
		menu.button:SetEnabled(f)
		if f then
			menu.text:SetTextColor(1, 1, 1)
		else
			menu.text:SetTextColor(.4, .4, .4)
		end
	end

	menu:SetScript("OnHide", function()
		if list.menu == menu then
			list:Hide()
		end
	end)
	
	-- scripts
	menu.button:HookScript("OnClick", function()
		if list.menu ~= menu then -- list shown by other dropdown
			LoadItems()
			list:Show()

		elseif list:IsShown() then -- list showing by this, hide it
			list:Hide()

		else
			if menu.reloadRequired then
				LoadItems()
				menu.reloadRequired = false
			else
				-- update highlight
				if menu.selected then
					SetHighlightItem(menu.selected)
				end
			end
			list:Show()
		end
	end)
	
	return menu
end

-----------------------------------------
-- binding button
-----------------------------------------
local function CreateGrid(parent, text, width)
	local grid = CreateFrame("Button", nil, parent)
	grid:SetFrameLevel(6)
	grid:SetSize(width, 20)
	grid:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
	grid:SetBackdropColor(0, 0, 0, 0) 
	grid:SetBackdropBorderColor(0, 0, 0, 1)

	-- to avoid SetText("") -> GetFontString() == nil
	grid.text = grid:CreateFontString(nil, "OVERLAY", font_name)
	grid.text:SetWordWrap(false)
	grid.text:SetJustifyH("LEFT")
	grid.text:SetPoint("LEFT", 5, 0)
	grid.text:SetPoint("RIGHT", -5, 0)
	grid.text:SetText(text)

	function grid:SetText(s)
		grid.text:SetText(s)
	end

	function grid:GetText()
		return grid.text:GetText()
	end

	function grid:IsTruncated()
		return grid.text:IsTruncated()
	end

	grid:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	grid:SetScript("OnEnter", function() 
		grid:SetBackdropColor(classColor.t[1], classColor.t[2], classColor.t[3], .15)
		parent:Highlight()
	end)

	grid:SetScript("OnLeave", function()
		grid:SetBackdropColor(0, 0, 0, 0)
		parent:Unhighlight()
	end)

	return grid
end

function addon:CreateBindingButton(parent, modifier, bindKey, bindType, bindAction)
	local b = CreateFrame("Button", nil, parent)
	b:SetFrameLevel(5)
	b:SetSize(100, 20)
	b:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
	b:SetBackdropColor(.12, .12, .12, 1) 
    b:SetBackdropBorderColor(0, 0, 0, 1)

	function b:Highlight()
		b:SetBackdropColor(classColor.t[1], classColor.t[2], classColor.t[3], .1)
	end

	function b:Unhighlight()
		b:SetBackdropColor(.12, .12, .12, 1)
	end

	local keyGrid = CreateGrid(b, modifier..bindKey, 127)
	b.keyGrid = keyGrid
	keyGrid:SetPoint("LEFT")

	local typeGrid = CreateGrid(b, bindType, 65)
	b.typeGrid = typeGrid
	typeGrid:SetPoint("LEFT", keyGrid, "RIGHT", -1, 0)

	local actionGrid = CreateGrid(b, bindAction, 100)
	b.actionGrid = actionGrid
	actionGrid:SetPoint("LEFT", typeGrid, "RIGHT", -1, 0)
	actionGrid:SetPoint("RIGHT")

	actionGrid:HookScript("OnEnter", function()
		if actionGrid:IsTruncated() then
			CellTooltip:SetOwner(actionGrid, "ANCHOR_TOPLEFT", 0, 1)
			CellTooltip:AddLine(L["Action"])
			CellTooltip:AddLine("|cffffffff" .. actionGrid:GetText())
			CellTooltip:Show()
		end
	end)
	actionGrid:HookScript("OnLeave", function()
		CellTooltip:Hide()
	end)

	function b:SetBorderColor(...)
		keyGrid:SetBackdropBorderColor(...)
		typeGrid:SetBackdropBorderColor(...)
		actionGrid:SetBackdropBorderColor(...)
	end

	function b:SetChanged(isChanged)
		if isChanged then
			b:SetBorderColor(classColor.t[1], classColor.t[2], classColor.t[3], 1)
		else
			b:SetBorderColor(0, 0, 0, 1)
		end
	end

	return b
end

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
		widget.cb:SetPoint("LEFT", 5, 0)

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
local function CreateSetting_Position(parent)
	local widget

	if not settingWidgets["position"] then
		widget = addon:CreateFrame("CellIndicatorSettings_Position", parent, 240, 95)
		settingWidgets["position"] = widget

		widget.anchor = addon:CreateDropdown(widget, 100)
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

		widget.relativeTo = addon:CreateDropdown(widget, 100)
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

		widget.x = addon:CreateSlider(L["X Offset"], widget, -50, 50, 100, 1)
		widget.x:SetPoint("TOPLEFT", widget.anchor, "BOTTOMLEFT", 0, -25)
		widget.x.afterValueChangedFn = function(value)
			widget.func({widget.anchor:GetSelected(), widget.relativeTo:GetSelected(), value, widget.y:GetValue()})
		end
		
		widget.y = addon:CreateSlider(L["Y Offset"], widget, -50, 50, 100, 1)
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

	widget:Show()
	return widget
end

local function CreateSetting_Size(parent)
	local widget

	if not settingWidgets["size"] then
		widget = addon:CreateFrame("CellIndicatorSettings_Size", parent, 240, 50)
		settingWidgets["size"] = widget

		widget.width = addon:CreateSlider(L["Width"], widget, 10, 50, 100, 1)
		widget.width:SetPoint("TOPLEFT", widget, 5, -20)
		widget.width.afterValueChangedFn = function(value)
			widget.func({value, widget.height:GetValue()})
		end
		
		widget.height = addon:CreateSlider(L["Height"], widget, 1, 50, 100, 1)
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

local function CreateSetting_SizeSquare(parent)
	local widget

	if not settingWidgets["size-square"] then
		widget = addon:CreateFrame("CellIndicatorSettings_SizeSquare", parent, 240, 50)
		settingWidgets["size-square"] = widget

		widget.size = addon:CreateSlider(L["Size"], widget, 10, 50, 100, 1)
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

local function CreateSetting_Height(parent)
	local widget

	if not settingWidgets["height"] then
		widget = addon:CreateFrame("CellIndicatorSettings_Height", parent, 240, 50)
		settingWidgets["height"] = widget

		widget.height = addon:CreateSlider(L["Height"], widget, 10, 50, 100, 1)
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

local function CreateSetting_Num(parent)
	local widget

	if not settingWidgets["num"] then
		widget = addon:CreateFrame("CellIndicatorSettings_Num", parent, 240, 50)
		settingWidgets["num"] = widget

		widget.num = addon:CreateSlider(L["Max Icons"], widget, 1, 5, 100, 1)
		widget.num:SetPoint("TOPLEFT", 5, -20)
		widget.num.afterValueChangedFn = function(value)
			widget.func(value)
		end

		-- associate db
		function widget:SetFunc(func)
			widget.func = func
		end
		
		-- show db value
		function widget:SetDBValue(num)
			widget.num:SetValue(num)
		end
	else
		widget = settingWidgets["num"]
	end

	widget:Show()
	return widget
end

local function CreateSetting_Font(parent)
	local widget

	if not settingWidgets["font"] then
		widget = addon:CreateFrame("CellIndicatorSettings_Font", parent, 240, 95)
		settingWidgets["font"] = widget

		widget.font = addon:CreateDropdown(widget, 100)
		widget.font:SetPoint("TOPLEFT", 5, -20)
		local items, fonts, defaultFontName, defaultFont = F:GetFontItems()
		for _, item in pairs(items) do
			item["onClick"] = function()
				widget.func({widget.font:GetSelected(), widget.fontSize:GetValue(), widget.outline:GetSelected(), widget.xOffset:GetValue()})
			end
		end
		widget.font:SetItems(items)

		widget.fontText = widget:CreateFontString(nil, "OVERLAY", font_name)
		widget.fontText:SetText(L["Font"])
		widget.fontText:SetPoint("BOTTOMLEFT", widget.font, "TOPLEFT", 0, 1)

		widget.outline = addon:CreateDropdown(widget, 100)
		widget.outline:SetPoint("LEFT", widget.font, "RIGHT", 25, 0)
		widget.outline:SetItems({
			{
				["text"] = L["Shadow"],
				["value"] = "Shadow",
				["onClick"] = function()
					widget.func({widget.font:GetSelected(), widget.fontSize:GetValue(), widget.outline:GetSelected(), widget.xOffset:GetValue()})
				end,
			},
			{
				["text"] = L["Outline"],
				["value"] = "Outline",
				["onClick"] = function()
					widget.func({widget.font:GetSelected(), widget.fontSize:GetValue(), widget.outline:GetSelected(), widget.xOffset:GetValue()})
				end,
			},
			{
				["text"] = L["Monochrome Outline"],
				["value"] = "Monochrome Outline",
				["onClick"] = function()
					widget.func({widget.font:GetSelected(), widget.fontSize:GetValue(), widget.outline:GetSelected(), widget.xOffset:GetValue()})
				end,
			},
		})

		widget.outlineText = widget:CreateFontString(nil, "OVERLAY", font_name)
		widget.outlineText:SetText(L["Font Outline"])
		widget.outlineText:SetPoint("BOTTOMLEFT", widget.outline, "TOPLEFT", 0, 1)

		widget.fontSize = addon:CreateSlider(L["Font Size"], widget, 7, 17, 100, 1)
		widget.fontSize:SetPoint("TOPLEFT", widget.font, "BOTTOMLEFT", 0, -25)
		widget.fontSize.afterValueChangedFn = function(value)
			widget.func({widget.font:GetSelected(), value, widget.outline:GetSelected(), widget.xOffset:GetValue()})
		end

		widget.xOffset = addon:CreateSlider(L["X Offset"], widget, -10, 10, 100, 1)
		widget.xOffset:SetPoint("TOPLEFT", widget.outline, "BOTTOMLEFT", 0, -25)
		widget.xOffset.afterValueChangedFn = function(value)
			widget.func({widget.font:GetSelected(), widget.fontSize:GetValue(), widget.outline:GetSelected(), value})
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
		end
	else
		widget = settingWidgets["font"]
	end

	widget:Show()
	return widget
end

local function CreateSetting_Color(parent)
	local widget

	if not settingWidgets["color"] then
		widget = addon:CreateFrame("CellIndicatorSettings_Color", parent, 240, 30)
		settingWidgets["color"] = widget

		local function ColorCallback(restore)
			local newR, newG, newB
			if restore then
				newR, newG, newB = unpack(restore)
			else
				newR, newG, newB = ColorPickerFrame:GetColorRGB()
			end
			
			widget.color[1], widget.color[2], widget.color[3] = newR, newG, newB
			widget.b:SetBackdropColor(newR, newG, newB)
			widget.func({newR, newG, newB})
		end

		local function ShowColorPicker()
			ColorPickerFrame.hasOpacity = false
			ColorPickerFrame.previousValues = {unpack(widget.color)}
			ColorPickerFrame.func, ColorPickerFrame.cancelFunc = ColorCallback, ColorCallback
			ColorPickerFrame:SetColorRGB(unpack(widget.color))
			ColorPickerFrame:Hide()
			ColorPickerFrame:Show()
		end

		widget.b = CreateFrame("Button", nil, widget)
		widget.b:SetPoint("LEFT", 5, 0)
		widget.b:SetSize(14, 14)
		widget.b:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
		widget.b:SetBackdropBorderColor(0, 0, 0, 1)
		widget.b:SetScript("OnEnter", function()
			widget.b:SetBackdropBorderColor(classColor.t[1], classColor.t[2], classColor.t[3], .7)
		end)
		widget.b:SetScript("OnLeave", function()
			widget.b:SetBackdropBorderColor(0, 0, 0, 1)
		end)
		widget.b:SetScript("OnClick", function()
			ShowColorPicker()
		end)

		widget.label = widget:CreateFontString(nil, "OVERLAY", font_name)
		widget.label:SetPoint("LEFT", widget.b, "RIGHT", 5, 0)
		widget.label:SetText(L["Color"])

		-- associate db
		function widget:SetFunc(func)
			widget.func = func
		end

		-- show db value
		function widget:SetDBValue(t)
			widget.b:SetBackdropColor(unpack(t))
			widget.color = t
		end
	else
		widget = settingWidgets["color"]
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
		widget.cb:SetPoint("LEFT", 5, 0)

		-- associate db
		function widget:SetFunc(func)
			widget.cb.onClick = function(checked)
				func(widget.settingName, checked)
			end
		end

		-- show db value
		function widget:SetDBValue(settingName, checked)
			widget.cb:SetChecked(checked)
			widget.settingName = settingName
			widget.cb.label:SetText(L[settingName])
		end
	else
		widget = settingWidgets["checkbutton"]
	end

	widget:Show()
	return widget
end

local function CreateSetting_Auras(parent)
	local widget

	if not settingWidgets["editbox"] then
		widget = addon:CreateFrame("CellIndicatorSettings_EditBox", parent, 240, 128)
		settingWidgets["editbox"] = widget

		widget.frame = addon:CreateFrame(nil, widget, 225, 80, true)
		widget.frame:SetPoint("TOPLEFT", 5, -20)
		widget.frame:Show()

		widget.text = widget:CreateFontString(nil, "OVERLAY", font_name)
		widget.text:SetPoint("BOTTOMLEFT", widget.frame, "TOPLEFT", 0, 1)

		addon:CreateScrollFrame(widget.frame)
		addon:StylizeFrame(widget.frame.scrollFrame, {.15, .15, .15, .9})
		
		widget.eb = addon:CreateEditBox(widget.frame.scrollFrame.content, 10, 20, true, true)
		widget.eb:SetPoint("TOPLEFT")
		widget.eb:SetPoint("RIGHT")
		widget.eb:SetTextInsets(2, 2, 1, 1)
		widget.eb:SetScript("OnEditFocusGained", nil)
		widget.eb:SetScript("OnEditFocusLost", nil)

		widget.eb:SetScript("OnEnterPressed", function(self) self:Insert("\n") end)

		-- https://wow.gamepedia.com/UIHANDLER_OnCursorChanged
		widget.eb:SetScript("OnCursorChanged", function(self, x, y, arg, lineHeight)
			widget.frame.scrollFrame:SetScrollStep(lineHeight)

			local vs = widget.frame.scrollFrame:GetVerticalScroll()
			local h  = widget.frame.scrollFrame:GetHeight()

			local cursorHeight = lineHeight - y

			if vs + y > 0 then -- cursor above current view
				widget.frame.scrollFrame:SetVerticalScroll(-y)
			elseif cursorHeight > h + vs then
				widget.frame.scrollFrame:SetVerticalScroll(-y-h+lineHeight+arg)
			end

			if widget.frame.scrollFrame:GetVerticalScroll() > widget.frame.scrollFrame:GetVerticalScrollRange() then widget.frame.scrollFrame:ScrollToBottom() end
		end)

		widget.eb:SetScript("OnTextChanged", function(self, userChanged)
			widget.frame.scrollFrame:SetContentHeight(self:GetHeight())
			if userChanged then
				widget.b:SetEnabled(true)
			end
		end)

		widget.frame.scrollFrame:SetScript("OnMouseDown", function()
			widget.eb:SetFocus(true)
		end)

		widget.b = addon:CreateButton(widget, L["Save"], "class-hover", {60, 20})
		widget.b:SetPoint("TOPLEFT", widget.frame, "BOTTOMLEFT", 0, -3)
		widget.b:SetEnabled(false)
		widget.b:SetScript("OnClick", function()
			widget.b:SetEnabled(false)
			widget.eb:ClearFocus()
			widget.func(F:StringToTable(widget.eb:GetText(), "\n"))
		end)

		-- associate db
		function widget:SetFunc(func)
			widget.func = func
		end

		-- show db value
		function widget:SetDBValue(title, t)
			widget.text:SetText(title)
			widget.eb:SetText(F:TableToString(t, "\n"))
			-- widget.title = title
		end
	else
		widget = settingWidgets["editbox"]
	end

	-- widget.eb:SetText("1\n2\n3\n4\n5\n6\n7\n8\n9\n10")
	widget.eb:SetCursorPosition(0)
	-- widget.frame.scrollFrame:ResetHeight()
	widget.b:SetEnabled(false)
	widget.frame.scrollFrame:ResetScroll()
	widget:Show()
	return widget
end

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
			tinsert(widgetsTable, CreateSetting_Position(parent))
		elseif setting == "size" then
			tinsert(widgetsTable, CreateSetting_Size(parent))
		elseif setting == "size-square" then
			tinsert(widgetsTable, CreateSetting_SizeSquare(parent))
		elseif setting == "height" then
			tinsert(widgetsTable, CreateSetting_Height(parent))
		elseif setting == "num" then
			tinsert(widgetsTable, CreateSetting_Num(parent))
		elseif setting == "font" then
			tinsert(widgetsTable, CreateSetting_Font(parent))
		elseif setting == "color" then
			tinsert(widgetsTable, CreateSetting_Color(parent))
		elseif setting == "checkbutton" then
			tinsert(widgetsTable, CreateSetting_CheckButton(parent))
		elseif setting == "auras" or setting == "blacklist" then
			tinsert(widgetsTable, CreateSetting_Auras(parent))
		end
	end
	
	return widgetsTable
end