local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local I = Cell.iFuncs
local LCG = LibStub("LibCustomGlow-1.0")

local indicatorsTab = Cell:CreateFrame("CellOptionsFrame_IndicatorsTab", Cell.frames.optionsFrame, nil, nil, true)
Cell.frames.indicatorsTab = indicatorsTab
indicatorsTab:SetAllPoints(Cell.frames.optionsFrame)

local selected, currentLayout, currentLayoutTable
local LoadIndicatorList
local listButtons = {}

-------------------------------------------------
-- preview
-------------------------------------------------
local previewButton = CreateFrame("Button", "IndicatorsPreviewButton", indicatorsTab, "CellUnitButtonTemplate")
previewButton:SetPoint("TOPLEFT", indicatorsTab, "TOPRIGHT", 10, -25)
previewButton:UnregisterAllEvents()
previewButton:SetScript("OnEnter", nil)
previewButton:SetScript("OnLeave", nil)
previewButton:SetScript("OnShow", nil)
previewButton:SetScript("OnHide", nil)
previewButton:SetScript("OnUpdate", nil)
previewButton:Show()

local previewButtonBG = Cell:CreateFrame("IndicatorsPreviewButtonBG", indicatorsTab)
previewButtonBG:SetPoint("TOPLEFT", previewButton, -5, 25)
previewButtonBG:SetPoint("BOTTOMRIGHT", previewButton, 5, -5)
previewButtonBG:SetFrameStrata("BACKGROUND")
Cell:StylizeFrame(previewButtonBG, {.1, .1, .1, .9}, {0, 0, 0, 0})
previewButtonBG:Show()

local previewText = previewButtonBG:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET_TITLE")
previewText:SetPoint("TOP", 0, -3)
previewText:SetText(Cell:GetPlayerClassColorString()..L["Preview"])

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

    previewButton:SetSize(unpack(currentLayoutTable["size"]))
    previewButton.func.SetPowerHeight(currentLayoutTable["powerHeight"])
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
        if indicator.indicatorType == "icons" then
            local stacks = {1, 2, 3, 4, 5}
            for i = 1, 5 do
                indicator[i]:SetScript("OnShow", function()
                    indicator[i]:SetCooldown(GetTime(), 7, nil, 134400, stacks[i])
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
        else
            indicator.preview = indicator.preview or CreateFrame("Frame", nil, indicator)
            indicator:SetScript("OnShow", function()
                indicator:SetCooldown(GetTime(), 7, nil, 134400, 0)
                indicator.preview.elapsedTime = 0
                indicator.preview:SetScript("OnUpdate", function(self, elapsed)
                    if self.elapsedTime >= 7 then
                        self.elapsedTime = 0
                        indicator:SetCooldown(GetTime(), 7, nil, 134400, 0)
                    else
                        self.elapsedTime = self.elapsedTime + elapsed
                    end
                end)
            end)
        end
    end
    indicator.init = true
end

local function UpdateIndicators(layout, indicatorName, setting, value)
    if not indicatorsTab:IsShown() then return end

    if not indicatorName then -- init
        I:RemoveAllCustomIndicators(previewButton)
        for _, t in pairs(currentLayoutTable["indicators"]) do
            local indicator = previewButton.indicators[t["indicatorName"]] or I:CreateIndicator(previewButton, t)
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
            -- update num
            if t["num"] then
                for i, frame in ipairs(indicator) do
                    if i <= t["num"] then
                        frame:Show()
                    else
                        frame:Hide()
                    end
                end
            end
            -- update orientation
            if t["orientation"] then
                indicator:SetOrientation(t["orientation"])
            end
            -- update font
            if t["font"] then
                indicator:SetFont(unpack(t["font"]))
            end
            -- update color
            if t["color"] then
                indicator:SetColor(unpack(t["color"]))
            end
            -- update colors
            if t["colors"] then
                indicator:SetColors(t["colors"])
            end
            -- update aoehealing
            if t["indicatorName"] == "aoeHealing" then
                I:EnableAoEHealing(t["enabled"])
            end
		end
	else
        local indicator = previewButton.indicators[indicatorName]
		-- changed in IndicatorsTab
		if setting == "enabled" then
            if value then
                InitIndicator(indicatorName)
                indicator:Show()
            else
                indicator:Hide()
            end
            -- update aoehealing
            if indicatorName == "aoeHealing" then
                I:EnableAoEHealing(value)
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
        elseif setting == "orientation" then
            indicator:SetOrientation(value)
        elseif setting == "font" then
            indicator:SetFont(unpack(value))
        elseif setting == "color" then
            indicator:SetColor(unpack(value))
        elseif setting == "colors" then
            indicator:SetColors(value)
        elseif setting == "create" then
            indicator = I:CreateIndicator(previewButton, value)
            -- update position
            indicator:ClearAllPoints()
            indicator:SetPoint(value["position"][1], previewButton, value["position"][2], value["position"][3], value["position"][4])
            -- update size
            if value["size"] then
                indicator:SetSize(unpack(value["size"]))
            end
            -- update num
            if value["num"] then
                for i, frame in ipairs(indicator) do
                    if i <= value["num"] then
                        frame:Show()
                    else
                        frame:Hide()
                    end
                end
            end
            -- update orientation
            if value["orientation"] then
                indicator:SetOrientation(value["orientation"])
            end
            -- update font
            if value["font"] then
                indicator:SetFont(unpack(value["font"]))
            end
            -- update color
            if value["color"] then
                indicator:SetColor(unpack(value["color"]))
            end
            -- update colors
            if value["colors"] then
                indicator:SetColors(value["colors"])
            end
            InitIndicator(indicatorName)
            indicator:Show()
        elseif setting == "remove" then
            I:RemoveIndicator(previewButton, indicatorName, value)
        end
	end
end
Cell:RegisterCallback("UpdateIndicators", "PreviewButton_UpdateIndicators", UpdateIndicators)

-------------------------------------------------
-- layout
-------------------------------------------------
local layoutText = Cell:CreateSeparator(L["Layout"], indicatorsTab, 122)
layoutText:SetPoint("TOPLEFT", 5, -5)
layoutText:SetJustifyH("LEFT")

local layoutDropdown = Cell:CreateDropdown(indicatorsTab, 122)
layoutDropdown:SetPoint("TOPLEFT", layoutText, "BOTTOMLEFT", 0, -10)

local function LoadLayoutDropdown()
    local indices = {}
    for name, _ in pairs(CellDB["layouts"]) do
        if name ~= "default" then
            tinsert(indices, name)
        end
    end
    table.sort(indices)
    tinsert(indices, 1, "default") -- make default first

    local items = {}
    for _, value in pairs(indices) do
        table.insert(items, {
            ["text"] = value == "default" and _G.DEFAULT or value,
            ["onClick"] = function()
                currentLayout = value
                currentLayoutTable = CellDB["layouts"][value]

                UpdateIndicators()
                UpdatePreviewButton()
                LoadIndicatorList()
                listButtons[1]:Click()
            end,
        })
    end
    layoutDropdown:SetItems(items)
end

-------------------------------------------------
-- indicator list
-------------------------------------------------
local listText = Cell:CreateSeparator(L["Indicators"], indicatorsTab, 122)
listText:SetPoint("TOPLEFT", 5, -62)
listText:SetJustifyH("LEFT")

local listFrame = Cell:CreateFrame("IndicatorsTab_ListFrame", indicatorsTab)
listFrame:SetPoint("TOPLEFT", 5, -86)
listFrame:SetPoint("BOTTOMRIGHT", indicatorsTab, "BOTTOMLEFT", 127, 29)
listFrame:Show()

Cell:CreateScrollFrame(listFrame)
listFrame.scrollFrame:SetScrollStep(19)

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
        ["text"] = L["Bar"],
        ["value"] = "bar",
    },
    {
        ["text"] = L["Rect"],
        ["value"] = "rect",
    },
    {
        ["text"] = L["Text"],
        ["value"] = "text",
    },
    {
        ["text"] = L["Icons"],
        ["value"] = "icons",
    },
    {
        ["text"] = "|cff777777"..L["Bars"], -- TODO:
        ["value"] = "bars",
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
        if indicatorType == "bars" then return end -- TODO:
        
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
                ["font"] = {"Cell ".._G.DEFAULT, 11, "Outline", 2},
                ["showDuration"] = false,
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
                ["font"] = {"Cell ".._G.DEFAULT, 12, "Outline", 0},
                ["colors"] = {{0,1,0}, {1,1,0,.5}, {1,0,0,5}},
                ["auraType"] = indicatorAuraType,
                ["auras"] = {},
            })
        elseif indicatorType == "bar" then
            tinsert(currentLayoutTable["indicators"], {
                ["name"] = name,
                ["indicatorName"] = indicatorName,
                ["type"] = indicatorType,
                ["enabled"] = true,
                ["position"] = {"TOPRIGHT", "TOPRIGHT", -1, 2},
                ["size"] = {18, 4},
                ["colors"] = {{0,1,0}, {1,1,0,.5}, {1,0,0,5}},
                ["auraType"] = indicatorAuraType,
                ["auras"] = {},
            })
        elseif indicatorType == "rect" then
            tinsert(currentLayoutTable["indicators"], {
                ["name"] = name,
                ["indicatorName"] = indicatorName,
                ["type"] = indicatorType,
                ["enabled"] = true,
                ["position"] = {"TOPRIGHT", "TOPRIGHT", 0, 2},
                ["size"] = {11, 4},
                ["colors"] = {{0,1,0}, {1,1,0,.5}, {1,0,0,5}},
                ["auraType"] = indicatorAuraType,
                ["auras"] = {},
            })
        elseif indicatorType == "icons" then
            tinsert(currentLayoutTable["indicators"], {
                ["name"] = name,
                ["indicatorName"] = indicatorName,
                ["type"] = indicatorType,
                ["enabled"] = true,
                ["position"] = {"TOPRIGHT", "TOPRIGHT", 0, 3},
                ["size"] = {13, 13},
                ["num"] = 3,
                ["orientation"] = "right-to-left",
                ["font"] = {"Cell ".._G.DEFAULT, 11, "Outline", 2},
                ["showDuration"] = false,
                ["auraType"] = indicatorAuraType,
                ["auras"] = {},
            })
        end
        if indicatorAuraType == "buff" then
            currentLayoutTable["indicators"][last+1]["castByMe"] = true
        end
        Cell:Fire("UpdateIndicators", currentLayout, indicatorName, "create", currentLayoutTable["indicators"][last+1])
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
        Cell:Fire("UpdateIndicators", currentLayout, indicatorName, "remove", auraType)
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
settingsText:SetPoint("TOPLEFT", 137, -5)
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
    ["dispels"] = {"enabled", "position", "size-square", "checkbutton:dispellableByMe", "checkbutton2:enableHighlight"},
    ["debuffs"] = {"enabled", "blacklist", "position", "size-square", "num", "font"},
    ["centralDebuff"] = {"|cffb7b7b7"..L["You can config debuffs in %s"]:format(Cell:GetPlayerClassColorString()..L["Raid Debuffs"].."|r"), "enabled", "position", "size-square", "font"},
}

local function ShowIndicatorSettings(id)
    -- if selected == id then return end

    settingsFrame.scrollFrame:ResetScroll()
    settingsFrame.scrollFrame:ResetHeight()

    local indicatorName = currentLayoutTable["indicators"][id]["indicatorName"]
    local indicatorType = currentLayoutTable["indicators"][id]["type"]
    -- texplore(currentLayoutTable["indicators"][id])

    local settingsTable
    if indicatorType == "built-in" then
        settingsTable = indicatorSettings[indicatorName]
    else
        if indicatorType == "icon" then
            settingsTable = {"enabled", "auras", "position", "size-square", "font", "checkbutton2:showDuration"}
        elseif indicatorType == "text" then
            settingsTable = {"enabled", "auras", "position", "font", "colors"}
        elseif indicatorType == "bar" or indicatorType == "rect" then
            settingsTable = {"enabled", "auras", "position", "size", "colors"}
        elseif indicatorType == "icons" then
            settingsTable = {"enabled", "auras", "position", "size-square", "num", "orientation", "font", "checkbutton2:showDuration"}
        end
        -- castByMe
        if currentLayoutTable["indicators"][id]["auraType"] == "buff" then
            tinsert(settingsTable, 3, "checkbutton:castByMe")
        end
        -- tips
        if indicatorType == "icons" then
            tinsert(settingsTable, 1, "|cffb7b7b7"..L["The spells list of a icons indicator is unordered (no priority)."].." "..L["Indicator settings are part of Layout settings which are account-wide."])
        else
            tinsert(settingsTable, 1, "|cffb7b7b7"..L["The priority of spells decreases from top to bottom."].." "..L["Indicator settings are part of Layout settings which are account-wide."])
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
        if string.find(currentSetting, "checkbutton") then
            local setting = select(2,string.split(":", currentSetting))
            w:SetDBValue(setting, currentLayoutTable["indicators"][id][setting])
        elseif currentSetting == "auras" then
            w:SetDBValue(L[F:UpperFirst(currentLayoutTable["indicators"][id]["auraType"]).." List"].." |cFF777777("..L["spell name"]..")", currentLayoutTable["indicators"][id]["auras"])
        elseif currentSetting == "blacklist" then
            w:SetDBValue(L["Debuff Filter (blacklist)"], CellDB["debuffBlacklist"])
        else
            w:SetDBValue(currentLayoutTable["indicators"][id][currentSetting])
        end

        -- update func
        w:SetFunc(function(value)
            -- texplore(value)
            if string.find(currentSetting, "checkbutton") then
                local setting = select(2,string.split(":", currentSetting))
                currentLayoutTable["indicators"][id][setting] = value
                Cell:Fire("UpdateIndicators", currentLayout, indicatorName, "checkbutton", setting, value) -- indicatorName, setting, value, value2
            elseif currentSetting == "auras" then
                currentLayoutTable["indicators"][id][currentSetting] = value
                Cell:Fire("UpdateIndicators", currentLayout, indicatorName, currentSetting, currentLayoutTable["indicators"][id]["auraType"], value)
            elseif currentSetting == "blacklist" then
                CellDB["debuffBlacklist"] = value
                Cell.vars.debuffBlacklist = F:ConvertTable(CellDB["debuffBlacklist"])
                Cell:Fire("UpdateIndicators", currentLayout, "", "blacklist")
            else
                currentLayoutTable["indicators"][id][currentSetting] = value
                Cell:Fire("UpdateIndicators", currentLayout, indicatorName, currentSetting, value)
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
            -- b = Cell:CreateButton(listFrame.scrollFrame.content, t["name"], "transparent-class", {20, 20})
            b = Cell:CreateButton(listFrame.scrollFrame.content, t["name"].." |cff7f7f7f("..L[t["auraType"]]..")", "transparent-class", {20, 20})
            b.typeIcon = b:CreateTexture(nil, "ARTWORK")
            b.typeIcon:SetPoint("RIGHT", -2, 0)
            b.typeIcon:SetSize(16, 16)
            b.typeIcon:SetTexture("Interface\\AddOns\\Cell\\Media\\indicators\\indicator-"..t["type"])
            -- b.typeIcon:SetVertexColor(unpack(Cell:GetPlayerClassColorTable()))
            b.typeIcon:SetAlpha(.5)

            b:GetFontString():ClearAllPoints()
            b:GetFontString():SetPoint("LEFT", 5, 0)
            b:GetFontString():SetPoint("RIGHT", b.typeIcon, "LEFT", -2, 0)
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
        w:SetAlpha(1)
    end, function(id)
        local w = previewButton.indicators[currentLayoutTable["indicators"][id]["indicatorName"]]
        LCG.PixelGlow_Stop(w:IsObjectType("StatusBar") and w.border or w)
        w:SetAlpha(.57)
    end)
end

-------------------------------------------------
-- functions
-------------------------------------------------
local function ShowTab(tab)
    if tab == "indicators" then
        indicatorsTab:Show()
        LoadLayoutDropdown()
        
        if currentLayout == Cell.vars.currentLayout then return end
        currentLayout = Cell.vars.currentLayout
        currentLayoutTable = Cell.vars.currentLayoutTable
        UpdateIndicators()
        UpdatePreviewButton()
        
        layoutDropdown:SetSelected(currentLayout == "default" and _G.DEFAULT or currentLayout)
        LoadIndicatorList()
        listButtons[1]:Click()
        -- texplore(previewButton)
    else
        indicatorsTab:Hide()
    end
end
Cell:RegisterCallback("ShowOptionsTab", "IndicatorsTab_ShowTab", ShowTab)

local function UpdateLayout()
    if previewButton.loaded and currentLayout == Cell.vars.currentLayout then
        UpdatePreviewButton()
    end
end
Cell:RegisterCallback("UpdateLayout", "IndicatorsTab_UpdateLayout", UpdateLayout)