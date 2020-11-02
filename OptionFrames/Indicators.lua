local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local LCG = LibStub("LibCustomGlow-1.0")

local indicatorsTab = Cell:CreateFrame("CellOptionsFrame_IndicatorsTab", Cell.frames.optionsFrame, nil, nil, true)
Cell.frames.indicatorsTab = indicatorsTab
indicatorsTab:SetAllPoints(Cell.frames.optionsFrame)

local selected, currentLayout, currentLayoutTable

-------------------------------------------------
-- preview
-------------------------------------------------
local previewText = Cell:CreateSeparator(L["Preview"], indicatorsTab, 255)
previewText:SetPoint("TOPLEFT", 137, -5)
previewText:SetJustifyH("LEFT")

local previewButton = CreateFrame("Button", "IndicatorPreviewButton", indicatorsTab, "CellUnitButtonTemplate")
-- previewButton:SetPoint("TOPLEFT", indicatorsTab, 137, -32)
previewButton:SetPoint("CENTER", indicatorsTab, "TOPLEFT", 265, -70)
previewButton:UnregisterAllEvents()
previewButton:SetScript("OnEnter", nil)
previewButton:SetScript("OnLeave", nil)
previewButton:SetScript("OnShow", nil)
previewButton:SetScript("OnHide", nil)
previewButton:SetScript("OnUpdate", nil)
previewButton:Show()

local function UpdatePreviewButton()
    if not previewButton.loaded then
        previewButton.loaded = true
        
        previewButton.widget.healthBar:SetStatusBarColor(F:GetClassColor(Cell.vars.playerClass))
        local r, g, b = F:GetPowerColor("player")
        previewButton.widget.powerBar:SetStatusBarColor(r, g, b)
        
        local name = UnitName("player")
        previewButton.widget.nameText:SetText(name)

        previewButton:SetScript("OnSizeChanged", function(self)
            F:UpdateTextWidth(self.widget.nameText, name)
        end)

        previewButton.widget.roleIcon:SetTexture("Interface\\AddOns\\Cell\\Media\\UI-LFG-ICON-PORTRAITROLES.blp")
		previewButton.widget.roleIcon:SetTexCoord(GetTexCoordsForRoleSmallCircle("DAMAGER"))
		previewButton.widget.roleIcon:Show()
    end

    previewButton:SetSize(unpack(Cell.vars.currentLayoutTable["size"]))
    previewButton.func.SetPowerHeight(Cell.vars.currentLayoutTable["powerHeight"])
    previewButton.widget.healthBar:SetStatusBarTexture(Cell.vars.texture)
    previewButton.widget.powerBar:SetStatusBarTexture(Cell.vars.texture)
    previewButton:GetScript("OnSizeChanged")(previewButton)
end

-- init preview button indicator animation
local function InitIndicator(indicatorName)
    local indicator = previewButton.indicators[indicatorName]
    if indicator.init then return end

    if indicatorName == "aggroBar" then
        indicator:SetStatusBarColor(1, 0, 0)
        indicator.value = 0
        indicator:SetScript("OnUpdate", function(self, elapsed)
            if self.value >= 100 then
                self.value = 0
            else
                self.value = self.value + 1
            end
            self:SetValue(self.value)
        end)

    elseif indicatorName == "tankActiveMitigation" then
        indicator.value = 0
        indicator:SetMinMaxValues(0, 100)
        indicator:SetScript("OnUpdate", function(self, elapsed)
            if self.value >= 100 then
                self.value = 0
            else
                self.value = self.value + 1
            end
            self:SetValue(self.value)
        end)

    elseif indicatorName == "debuffs" then
        local types = {"", "Curse", "Disease", "Magic", "Poison"}
        local icons = {132155, 136139, 136128, 136071, 136182}
        local stacks = {7, 10, 0, 0, 2}
        for i = 1, 5 do
            indicator[i]:SetScript("OnShow", function()
                indicator[i]:SetCooldown(GetTime(), 7, types[i], icons[i], stacks[i])
                indicator[i].cooldown.value = 0
                indicator[i].cooldown:SetScript("OnUpdate", function(self, elapsed)
                    if self.value >= 7 then
                        self.value = 0
                    else
                        self.value = self.value + elapsed
                    end
                    self:SetValue(self.value)
                end)
            end)
            -- indicator[i]:SetScript("OnHide", function()
            --     indicator[i].cooldown:Hide()
            --     indicator[i].cooldown:SetScript("OnValueChanged", nil)
            -- end)
        end
        
    elseif indicatorName == "dispels" then
        local types = {["Curse"]=true, ["Disease"]=true, ["Magic"]=true, ["Poison"]=true}
        indicator:SetDispels(types)

    elseif indicatorName == "centralDebuff" then
        indicator:SetScript("OnShow", function()
            indicator:SetCooldown(GetTime(), 10, "Magic", "Interface\\Icons\\INV_Misc_QuestionMark", 7)
            indicator.cooldown:SetScript("OnCooldownDone", function()
                indicator:SetCooldown(GetTime(), 10, "Magic", "Interface\\Icons\\INV_Misc_QuestionMark", 7)
            end)
        end)
        indicator:SetScript("OnHide", function()
            indicator.cooldown:Hide()
            indicator.cooldown:SetScript("OnCooldownDone", nil)
        end)
        
    elseif indicatorName == "externalCooldowns" then
        local icons = {135936, 572025, 135966, 627485, 237542}
        for i = 1, 5 do
            indicator[i]:SetScript("OnShow", function()
                indicator[i]:SetCooldown(GetTime(), 7, nil, icons[i], 0)
                indicator[i].cooldown.value = 0
                indicator[i].cooldown:SetScript("OnUpdate", function(self, elapsed)
                    if self.value >= 7 then
                        self.value = 0
                    else
                        self.value = self.value + elapsed
                    end
                    self:SetValue(self.value)
                end)
            end)
        end
    elseif indicatorName == "defensiveCooldowns" then
        local icons = {135919, 136120, 538565, 132362, 132199}
        for i = 1, 5 do
            indicator[i]:SetScript("OnShow", function()
                indicator[i]:SetCooldown(GetTime(), 7, nil, icons[i], 0)
                indicator[i].cooldown.value = 0
                indicator[i].cooldown:SetScript("OnUpdate", function(self, elapsed)
                    if self.value >= 7 then
                        self.value = 0
                    else
                        self.value = self.value + elapsed
                    end
                    self:SetValue(self.value)
                end)
            end)
        end
    elseif string.find(indicatorName, "indicator") then
        indicator.preview = CreateFrame("Frame", nil, indicator)
        indicator:SetScript("OnShow", function()
            indicator:SetCooldown(GetTime(), 7, nil, 134400, 0)
            indicator.preview.elapsedTime = 0
            indicator.preview:HookScript("OnUpdate", function(self, elapsed)
                if self.elapsedTime >= 7 then
                    self.elapsedTime = 0
                    indicator:SetCooldown(GetTime(), 7, nil, 134400, 0)
                else
                    self.elapsedTime = self.elapsedTime + elapsed
                end
            end)
        end)
    end
    indicator.init = true
end

local function UpdateIndicators(indicatorName, setting, value)
	if not indicatorName then -- init
        for _, t in pairs(Cell.vars.currentLayoutTable["indicators"]) do
            local indicator = previewButton.indicators[t["indicatorName"]] or F:CreateIndicator(previewButton, t)
            if t["enabled"] then
                InitIndicator(t["indicatorName"])
                indicator:Show()
            end
            -- update position
            if t["position"] then
                indicator:ClearAllPoints()
                indicator:SetPoint(t["position"][1], previewButton, t["position"][2], t["position"][3], t["position"][4])
            end
            -- update size
            if t["size"] then
                indicator:SetSize(unpack(t["size"]))
            end
            -- update height
            if t["height"] then
                indicator:SetHeight(t["height"])
            end
            -- update debuffs num
            if t["num"] then
                for i, frame in ipairs(indicator) do
                    if i <= t["num"] then
                        frame:Show()
                    else
                        frame:Hide()
                    end
                end
            end
            -- update font
            if t["font"] then
                indicator:SetFont(unpack(t["font"]))
            end
            -- update color
            if t["color"] then
                indicator:SetColor(unpack(t["color"]))
            end
            -- update aoehealing
            if t["indicatorName"] == "aoeHealing" then
                F:EnableAoEHealing(t["enabled"])
            end
		end
	else
        local indicator = previewButton.indicators[indicatorName]
		-- changed in IndicatorsTab
		if setting == "enabled" then
            if value then
                indicator:Show()
                InitIndicator(indicatorName)
            else
                indicator:Hide()
            end
            -- update aoehealing
            if indicatorName == "aoeHealing" then
                F:EnableAoEHealing(value)
            end
		elseif setting == "position" then
			indicator:ClearAllPoints()
			indicator:SetPoint(value[1], previewButton, value[2], value[3], value[4])
		elseif setting == "size" then
            indicator:SetSize(unpack(value))
		elseif setting == "height" then
            indicator:SetHeight(value)
        elseif setting == "num" then
            for i, frame in ipairs(indicator) do
                if i <= value then
                    frame:Show()
                else
                    frame:Hide()
                end
            end
        elseif setting == "font" then
            indicator:SetFont(unpack(value))
        elseif setting == "color" then
            indicator:SetColor(unpack(value))
        elseif setting == "create" then
            indicator = F:CreateIndicator(previewButton, value)
            -- update position
            indicator:ClearAllPoints()
            indicator:SetPoint(value["position"][1], previewButton, value["position"][2], value["position"][3], value["position"][4])
            -- update size
            if value["size"] then
                indicator:SetSize(unpack(value["size"]))
            end
            -- update font
            if value["font"] then
                indicator:SetFont(unpack(value["font"]))
            end
            -- update color
            if value["color"] then
                indicator:SetColor(unpack(value["color"]))
            end
            InitIndicator(indicatorName)
            indicator:Show()
        elseif setting == "remove" then
            F:RemoveIndicator(previewButton, indicatorName, value)
        end
	end
end
Cell:RegisterCallback("UpdateIndicators", "PreviewButton_UpdateIndicators", UpdateIndicators)

-------------------------------------------------
-- current layout
-------------------------------------------------
local currentLayoutText = indicatorsTab:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET_TITLE")
currentLayoutText:SetJustifyH("LEFT")
currentLayoutText:SetPoint("LEFT", previewText, "RIGHT", 5, 0)

local function UpdateCurrentLayoutText()
    currentLayoutText:SetText("|cFF777777"..L["Current Layout"]..": "..currentLayout)
end

-------------------------------------------------
-- indicator list
-------------------------------------------------
local listText = Cell:CreateSeparator(L["Indicators"], indicatorsTab, 122)
listText:SetPoint("TOPLEFT", 5, -5)
listText:SetJustifyH("LEFT")

local listFrame = Cell:CreateFrame("IndicatorsTab_ListFrame", indicatorsTab)
listFrame:SetPoint("TOPLEFT", 5, -29)
listFrame:SetPoint("BOTTOMRIGHT", indicatorsTab, "BOTTOMLEFT", 127, 29)
listFrame:Show()

Cell:CreateScrollFrame(listFrame)
listFrame.scrollFrame:SetScrollStep(19)

local listButtons = {}
local LoadIndicatorList

-------------------------------------------------
-- indicator create/delete
-------------------------------------------------
-- mask
Cell:CreateMask(indicatorsTab, nil, {1, -1, -1, 1})
indicatorsTab.mask:Hide()

local typeItems = {
    {
        ["text"] = L["Icon"],
        ["value"] = "icon",
    },
    {
        ["text"] = L["Rectangle"],
        ["value"] = "rectangle",
    },
    {
        ["text"] = L["Bar"],
        ["value"] = "bar",
    },
    {
        ["text"] = L["Text"],
        ["value"] = "text",
    },
}

local auraTypeItems = {
    {
        ["text"] = L["Buff"],
        ["value"] = "buff",
    },
    {
        ["text"] = L["Debuff"],
        ["value"] = "debuff",
    },
}

local createBtn = Cell:CreateButton(indicatorsTab, L["Create"], "blue-hover", {62, 20})
createBtn:SetPoint("BOTTOMLEFT", 5, 5)
createBtn:SetScript("OnClick", function()
    local popup = Cell:CreateConfirmPopup(indicatorsTab, 200, L["Create new indicator"], function(self)
        local name = strtrim(self.editBox:GetText())
        local indicatorName
        local indicatorType, indicatorAuraType = self.dropdown1:GetSelected(), self.dropdown2:GetSelected()
        
        local last = #currentLayoutTable["indicators"]
        if currentLayoutTable["indicators"][last]["type"] == "built-in" then
            indicatorName = "indicator"..(last+1)
        else
            indicatorName = "indicator"..(tonumber(strmatch(currentLayoutTable["indicators"][last]["indicatorName"], "%d+"))+1)
        end

        if indicatorType == "icon" then
            tinsert(currentLayoutTable["indicators"], {
                ["name"] = name,
                ["indicatorName"] = indicatorName,
                ["type"] = indicatorType,
                ["enabled"] = true,
                ["position"] = {"TOPRIGHT", "TOPRIGHT", 0, 3},
                ["size"] = {13, 13},
                ["font"] = {"Cell ".._G.DEFAULT, 12, "Outline", 2},
                ["auraType"] = indicatorAuraType,
                ["auras"] = {},
            })
        elseif indicatorType == "text" then
            tinsert(currentLayoutTable["indicators"], {
                ["name"] = name,
                ["indicatorName"] = indicatorName,
                ["type"] = indicatorType,
                ["enabled"] = true,
                ["position"] = {"TOPRIGHT", "TOPRIGHT", 0, 3},
                ["font"] = {"Cell ".._G.DEFAULT, 12, "Outline", 1},
                ["colors"] = {{0,1,0}, {.5,1,1,0}, {5,1,0,0}},
                ["auraType"] = indicatorAuraType,
                ["auras"] = {},
            })
        end
        if indicatorAuraType == "buff" then
            currentLayoutTable["indicators"][last+1]["castByMe"] = true
        end
        Cell:Fire("UpdateIndicators", indicatorName, "create", currentLayoutTable["indicators"][last+1])
        LoadIndicatorList()
        listButtons[last+1]:Click()

    end, true, true, 2)
    popup:SetPoint("TOPLEFT", 100, -100)
    popup.dropdown1:SetItems(typeItems)
    popup.dropdown1:SetSelectedItem(1)
    -- popup.dropdown1:SetEnabled(false)
    popup.dropdown2:SetItems(auraTypeItems)
    popup.dropdown2:SetSelectedItem(1)
end)

local deleteBtn = Cell:CreateButton(indicatorsTab, L["Delete"], "red-hover", {61, 20})
deleteBtn:SetPoint("LEFT", createBtn, "RIGHT", -1, 0)
deleteBtn:SetEnabled(false)
deleteBtn:SetScript("OnClick", function()
    local name = currentLayoutTable["indicators"][selected]["name"]
    local indicatorName = currentLayoutTable["indicators"][selected]["indicatorName"]
    local auraType = currentLayoutTable["indicators"][selected]["auraType"]

    local popup = Cell:CreateConfirmPopup(indicatorsTab, 200, L["Delete indicator"].." "..name.."?", function(self)
        Cell:Fire("UpdateIndicators", indicatorName, "remove", auraType)
        tremove(currentLayoutTable["indicators"], selected)
        LoadIndicatorList()
        listButtons[1]:Click()
    end, true)
    popup:SetPoint("TOPLEFT", 100, -120)
end)

-------------------------------------------------
-- indicator settings
-------------------------------------------------
local settingsText = Cell:CreateSeparator(L["Indicator Settings"], indicatorsTab, 255)
settingsText:SetPoint("TOPLEFT", 137, -129)
settingsText:SetJustifyH("LEFT")

-------------------------------------------------
-- settings frame
-------------------------------------------------
local settingsFrame = Cell:CreateFrame("IndicatorsTab_SettingsFrame", indicatorsTab, 10, 10, true)
settingsFrame:SetPoint("TOPLEFT", settingsText, "BOTTOMLEFT", 0, -10)
settingsFrame:SetPoint("BOTTOMRIGHT", indicatorsTab, -5, 5)
settingsFrame:Show()

Cell:CreateScrollFrame(settingsFrame)
settingsFrame.scrollFrame:SetScrollStep(35)

local indicatorSettings = {
    ["aggroBar"] = {"enabled", "position", "size"},
    ["aoeHealing"] = {"enabled", "height", "color"},
    ["externalCooldowns"] = {"enabled", "position", "size", "num"},
    ["defensiveCooldowns"] = {"enabled", "position", "size", "num"},
    ["tankActiveMitigation"] = {"enabled", "position", "size"},
    ["dispels"] = {"enabled", "position", "size-square", "checkbutton"},
    ["debuffs"] = {"enabled", "blacklist", "position", "size-square", "num", "font"},
    ["centralDebuff"] = {"enabled", "position", "size-square", "font"},
}

local function ShowIndicatorSettings(id)
    if selected == id then return end

    settingsFrame.scrollFrame:ResetScroll()
    settingsFrame.scrollFrame:ResetHeight()

    local indicatorName = currentLayoutTable["indicators"][id]["indicatorName"]
    local indicatorType = currentLayoutTable["indicators"][id]["type"]

    local settingsTable
    if indicatorType == "built-in" then
        settingsTable = indicatorSettings[indicatorName]
    else
        if indicatorType == "icon" then
            settingsTable = {"enabled", "auras", "position", "size-square", "font"}
        elseif indicatorType == "text" then
            settingsTable = {"enabled", "auras", "position", "font", "colors"}
        end
        if currentLayoutTable["indicators"][id]["auraType"] == "buff" then
            tinsert(settingsTable, 3, "checkbutton") -- castByMe
        end 
    end

    local widgets = Cell:CreateIndicatorSettings(settingsFrame.scrollFrame.content, settingsTable)
    
    local last
    local height = 0
    for i, w in pairs(widgets) do
        if last then
            w:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -7)
        else
            w:SetPoint("TOPLEFT")
        end
        w:SetPoint("RIGHT")
        last = w

        height = height + w:GetHeight()

        -- "enabled", "position", "size", "num", "font"
        local currentSetting = settingsTable[i]
        if currentSetting == "size-square" then currentSetting = "size" end
        
        -- echo
        if currentSetting == "checkbutton" then
            if indicatorName == "dispels" then
                w:SetDBValue("dispellableByMe", currentLayoutTable["indicators"][id]["dispellableByMe"])
            else -- custom indicators
                w:SetDBValue("castByMe", currentLayoutTable["indicators"][id]["castByMe"])
            end
        elseif currentSetting == "auras" then
            w:SetDBValue(L[F:UpperFirst(currentLayoutTable["indicators"][id]["auraType"]).." List"].." |cFF777777("..L["spell name"]..")", currentLayoutTable["indicators"][id]["auras"])
        elseif currentSetting == "blacklist" then
            w:SetDBValue(L["Debuff Filter (blacklist)"], CellDB["debuffBlacklist"])
        else
            w:SetDBValue(currentLayoutTable["indicators"][id][currentSetting])
        end

        -- update func
        w:SetFunc(function(value, value2)
            -- texplore(value)
            if currentSetting == "checkbutton" then
                Cell.vars.currentLayoutTable["indicators"][id][value] = value2
                Cell:Fire("UpdateIndicators", indicatorName, currentSetting, value2)
            elseif currentSetting == "auras" then
                Cell.vars.currentLayoutTable["indicators"][id][currentSetting] = value
                Cell:Fire("UpdateIndicators", indicatorName, currentSetting, currentLayoutTable["indicators"][id]["auraType"], value)
            elseif currentSetting == "blacklist" then
                CellDB["debuffBlacklist"] = value
                Cell.vars.debuffBlacklist = F:ConvertTable(CellDB["debuffBlacklist"])
                Cell:Fire("UpdateIndicators", "", "blacklist")
            else
                Cell.vars.currentLayoutTable["indicators"][id][currentSetting] = value
                Cell:Fire("UpdateIndicators", indicatorName, currentSetting, value)
            end
            -- show enabled/disabled status
            if currentSetting == "enabled" then
                if value then
                    listButtons[id]:SetTextColor(1, 1, 1, 1)
                else
                    listButtons[id]:SetTextColor(.466, .466, .466, 1)
                end
            end
        end)
    end

    settingsFrame.scrollFrame:SetContentHeight(height + (#widgets-1)*7)

    if string.find(indicatorName, "indicator") then
        deleteBtn:SetEnabled(true)
    else
        deleteBtn:SetEnabled(false)
    end
    selected = id
end

LoadIndicatorList = function()
    F:Debug("|cffff7777LoadIndicatorList:|r "..currentLayout)
    listFrame.scrollFrame:Reset()
    wipe(listButtons)

    local last
    for i, t in pairs(currentLayoutTable["indicators"]) do
        local b
        if t["type"] == "built-in" then
            b = Cell:CreateButton(listFrame.scrollFrame.content, L[t["name"]], "transparent-class", {20, 20})
        else
            b = Cell:CreateButton(listFrame.scrollFrame.content, t["name"].." |cffababab("..L[t["type"]]..")", "transparent-class", {20, 20})
        end
        tinsert(listButtons, b)
        b.id = i
            
        -- show enabled/disabled status
        if t["enabled"] then
            b:SetTextColor(1, 1, 1, 1)
        else
            b:SetTextColor(.466, .466, .466, 1)
        end

        b.ShowTooltip = function()
            if b:GetFontString():IsTruncated() then
                CellTooltip:SetOwner(b, "ANCHOR_NONE")
                CellTooltip:SetPoint("RIGHT", b, "LEFT")
                CellTooltip:AddLine(b:GetText())
                CellTooltip:Show()
            end
        end

        b.HideTooltip = function()
            CellTooltip:Hide()
        end

        b:SetPoint("RIGHT")
        if last then
            b:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, 1)
        else
            b:SetPoint("TOPLEFT")
        end
        last = b
    end
    listFrame.scrollFrame:SetContentHeight(20, #listButtons, -1)

    Cell:CreateButtonGroup(listButtons, ShowIndicatorSettings, function(id)
        local w = previewButton.indicators[currentLayoutTable["indicators"][id]["indicatorName"]]
        LCG.PixelGlow_Start(w:IsObjectType("StatusBar") and w.border or w)
    end, function(id)
        local w = previewButton.indicators[currentLayoutTable["indicators"][id]["indicatorName"]]
        LCG.PixelGlow_Stop(w:IsObjectType("StatusBar") and w.border or w)
    end)
end

-------------------------------------------------
-- functions
-------------------------------------------------
local function ShowTab(tab)
    if tab == "indicators" then
        indicatorsTab:Show()
        UpdatePreviewButton()
        
        if currentLayout == Cell.vars.currentLayout then return end
        currentLayout = Cell.vars.currentLayout
        currentLayoutTable = Cell.vars.currentLayoutTable

        UpdateCurrentLayoutText()
        LoadIndicatorList()
        listButtons[1]:Click()
        -- texplore(previewButton)
    else
        indicatorsTab:Hide()
    end
end
Cell:RegisterCallback("ShowOptionsTab", "IndicatorsTab_ShowTab", ShowTab)