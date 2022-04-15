local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local I = Cell.iFuncs
local P = Cell.pixelPerfectFuncs
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
local previewButton = CreateFrame("Button", "CellIndicatorsPreviewButton", indicatorsTab, "CellUnitButtonTemplate")
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
    P:Size(previewButton, currentLayoutTable["size"][1], currentLayoutTable["size"][2])
    previewButton.func.SetOrientation(unpack(currentLayoutTable["barOrientation"]))
    previewButton.func.SetPowerSize(currentLayoutTable["powerSize"])
    previewButton:GetScript("OnSizeChanged")(previewButton)
    
    previewButton.widget.healthBar:SetStatusBarTexture(Cell.vars.texture)
    previewButton.widget.powerBar:SetStatusBarTexture(Cell.vars.texture)

    -- health color
    local r, g, b = F:GetHealthColor(1, F:GetClassColor(Cell.vars.playerClass))
    previewButton.widget.healthBar:SetStatusBarColor(r, g, b, CellDB["appearance"]["barAlpha"])
    
    -- power color
    r, g, b = F:GetPowerColor("player", Cell.vars.playerClass)
    previewButton.widget.powerBar:SetStatusBarColor(r, g, b)

    -- alpha
    previewButton:SetBackdropColor(0, 0, 0, CellDB["appearance"]["bgAlpha"])

    previewButton.loaded = true
end

-- init preview button indicator animation
local function InitIndicator(indicatorName)
    local indicator = previewButton.indicators[indicatorName]
    if indicator.init then return end

    if indicatorName == "nameText" then
        previewButton.state.name = UnitName("player")
        indicator.isPreview = true
        indicator:UpdateName()
        indicator:UpdateVehicleName()
        -- texture type cannot glow by LCG
        indicator.preview = indicator.preview or CreateFrame("Frame", nil, previewButton)
        indicator.preview:SetAllPoints(indicator)

    elseif indicatorName == "statusText" then
        local count = 2
        local ticker
        indicator:SetScript("OnShow", function()
            indicator:SetStatus("AFK")
            indicator.timer:SetText("13m")

            ticker = C_Timer.NewTicker(1, function()
                if count == 1 then
                    indicator:SetStatus("AFK")
                    indicator.timer:SetText("13m")
                elseif count == 2 then
                    indicator:SetStatus("OFFLINE")
                    indicator.timer:SetText("13m")
                elseif count == 3 then
                    indicator:SetStatus("DEAD")
                    indicator.timer:SetText()
                elseif count == 4 then
                    indicator:SetStatus("GHOST")
                    indicator.timer:SetText()
                elseif count == 5 then
                    indicator:SetStatus("FEIGN")
                    indicator.timer:SetText()
                elseif count == 6 then
                    indicator:SetStatus("DRINKING")
                    indicator.timer:SetText()
                elseif count == 7 then
                    indicator:SetStatus("PENDING")
                    indicator.timer:SetText()
                elseif count == 8 then
                    indicator:SetStatus("ACCEPTED")
                    indicator.timer:SetText()
                elseif count == 9 then
                    indicator:SetStatus("DECLINED")
                    indicator.timer:SetText()
                end

                if count < 9 then
                    count = count + 1
                else
                    count = 1
                end
            end)
        end)

        indicator:SetScript("OnHide", function()
            if ticker then
                ticker:Cancel()
                ticker = nil
                count = 2
            end
        end)

    elseif indicatorName == "statusIcon" then
        indicator:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")

    elseif indicatorName == "roleIcon" then
        indicator:SetTexture("Interface\\AddOns\\Cell\\Media\\UI-LFG-ICON-PORTRAITROLES.blp")
        indicator:SetTexCoord(GetTexCoordsForRoleSmallCircle("DAMAGER"))
        -- texture type cannot glow by LCG
        indicator.preview = indicator.preview or CreateFrame("Frame", nil, previewButton)
        indicator.preview:SetAllPoints(indicator)
        indicator.roles = {"TANK", "HEALER", "DAMAGER"}
        indicator.role = 1
        indicator.elapsed = 0
        indicator.preview:SetScript("OnUpdate", function(self, elapsed)
            indicator.elapsed = indicator.elapsed + elapsed
            if indicator.elapsed >= 2 then
                indicator.elapsed = 0
                indicator.role = (indicator.role + 1 > 3) and 1 or indicator.role + 1
                indicator:SetRole(indicator.roles[indicator.role])
            end
        end)
        
    elseif indicatorName == "leaderIcon" then
        indicator:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
        -- texture type cannot glow by LCG
        indicator.preview = indicator.preview or CreateFrame("Frame", nil, previewButton)
        indicator.preview:SetAllPoints(indicator)
        
    elseif indicatorName == "readyCheckIcon" then
        indicator:SetTexture(READY_CHECK_READY_TEXTURE)

    elseif indicatorName == "aggroBlink" then
        indicator.isAggroBlink = true

    elseif indicatorName == "aggroBorder" then
        indicator.isAggroBorder = true

    elseif indicatorName == "playerRaidIcon" then
        SetRaidTargetIconTexture(indicator.tex, 6)

    elseif indicatorName == "targetRaidIcon" then
        SetRaidTargetIconTexture(indicator.tex, 8)

    elseif indicatorName == "aggroBar" then
        indicator:SetStatusBarColor(1, 0, 0)
        indicator.value = 0
        indicator:SetScript("OnUpdate", function(self, elapsed)
            self.value = self.value + 1
            if self.value >= 100 then
                self.value = 0
            end
            self:SetValue(self.value)
        end)

    elseif indicatorName == "shieldBar" then
        indicator:SetValue(.5)

    elseif indicatorName == "tankActiveMitigation" then
        indicator.value = 0
        indicator:SetMinMaxValues(0, 100)
        indicator:SetScript("OnUpdate", function(self, elapsed)
            self.value = self.value + 1
            if self.value >= 100 then
                self.value = 0
            end
            self:SetValue(self.value)
        end)

    elseif indicatorName == "debuffs" then
        local types = {"", "Curse", "Disease", "Magic", "Poison", "", "Curse", "Disease", "Magic", "Poison"}
        local icons = {132155, 136139, 136128, 240443, 136182, 132155, 136139, 136128, 240443, 136182}
        for i = 1, 10 do
            indicator[i]:SetScript("OnShow", function()
                indicator[i]:SetCooldown(GetTime(), 8, types[i], icons[i], i)
                indicator[i].cooldown:SetScript("OnUpdate", nil)
                indicator[i]:SetScript("OnUpdate", function(self, elapsed)
                    self.value = (self.value or 0) + elapsed
                    if self.value >= 8 then
                        self.value = 0
                    end
                    self.duration:SetText(string.format("%d", 8-self.value))
                    self.cooldown:SetValue(self.value)
                end)
            end)
        end
        
    elseif indicatorName == "dispels" then
        local types = {["Curse"]=true, ["Disease"]=true, ["Magic"]=true, ["Poison"]=true}
        indicator:SetDispels(types)

    elseif indicatorName == "raidDebuffs" then
        indicator.isRaidDebuffs = true
        for i = 1, 3 do
            indicator[i]:HookScript("OnShow", function()
                indicator[i]:SetCooldown(GetTime(), 10, "", "Interface\\Icons\\INV_Misc_QuestionMark", 7)
                indicator[i].cooldown:SetScript("OnCooldownDone", function()
                    indicator[i]:SetCooldown(GetTime(), 10, "", "Interface\\Icons\\INV_Misc_QuestionMark", 7)
                end)
            end)
            indicator[i]:HookScript("OnHide", function()
                indicator[i].cooldown:Hide()
                indicator[i].cooldown:SetScript("OnCooldownDone", nil)
            end)
        end

    elseif indicatorName == "targetedSpells" then
        indicator.isTargetedSpells = true
        indicator:SetScript("OnShow", function()
            indicator:SetCooldown(GetTime(), 3, "Interface\\Icons\\spell_nature_polymorph", 7)
            indicator.cooldown:SetScript("OnCooldownDone", function()
                indicator:SetCooldown(GetTime(), 3, "Interface\\Icons\\spell_nature_polymorph", 7)
            end)
        end)
        indicator:SetScript("OnHide", function()
            indicator.cooldown:Hide()
            indicator.cooldown:SetScript("OnCooldownDone", nil)
        end)

    elseif indicatorName == "targetCounter" then
        indicator:SetCount(3)

    elseif indicatorName == "externalCooldowns" then
        local icons = {135936, 572025, 135966, 627485, 237542}
        for i = 1, 5 do
            indicator[i]:SetScript("OnShow", function()
                indicator[i]:SetCooldown(GetTime(), 8, nil, icons[i], 0)
                indicator[i].cooldown:SetScript("OnUpdate", nil)
                indicator[i]:SetScript("OnUpdate", function(self, elapsed)
                    self.value = (self.value or 0) + elapsed
                    if self.value >= 8 then
                        self.value = 0
                    end
                    self.duration:SetText(string.format("%d", 8-self.value))
                    self.cooldown:SetValue(self.value)
                end)
            end)
        end
    elseif indicatorName == "defensiveCooldowns" then
        local icons = {135919, 136120, 538565, 132362, 132199}
        for i = 1, 5 do
            indicator[i]:SetScript("OnShow", function()
                indicator[i]:SetCooldown(GetTime(), 8, nil, icons[i], 0)
                indicator[i].cooldown:SetScript("OnUpdate", nil)
                indicator[i]:SetScript("OnUpdate", function(self, elapsed)
                    self.value = (self.value or 0) + elapsed
                    if self.value >= 8 then
                        self.value = 0
                    end
                    self.duration:SetText(string.format("%d", 8-self.value))
                    self.cooldown:SetValue(self.value)
                end)
            end)
        end
    elseif string.find(indicatorName, "indicator") then
        if indicator.indicatorType == "icons" then
            for i = 1, 10 do
                indicator[i]:SetScript("OnShow", function()
                    indicator[i]:SetCooldown(GetTime(), 8, nil, 134400, i)
                    indicator[i].cooldown:SetScript("OnUpdate", nil)
                    indicator[i]:SetScript("OnUpdate", function(self, elapsed)
                        self.value = (self.value or 0) + elapsed
                        if self.value >= 8 then
                            self.value = 0
                        end
                        self.duration:SetText(string.format("%d", 8-self.value))
                        self.cooldown:SetValue(self.value)
                    end)
                end)
            end
        elseif indicator.indicatorType == "text" then
            indicator.isCustomText = true -- mark for custom glow
            indicator.preview = indicator.preview or CreateFrame("Frame", nil, indicator)
            indicator:SetScript("OnShow", function()
                indicator:SetCooldown(GetTime(), 12, nil, 134400, 5)
                indicator.preview.elapsedTime = 0
                indicator.preview:SetScript("OnUpdate", function(self, elapsed)
                    self.elapsedTime = self.elapsedTime + elapsed
                    if self.elapsedTime >= 12 then
                        self.elapsedTime = 0
                        indicator:SetCooldown(GetTime(), 12, nil, 134400, 5)
                    end
                end)
                C_Timer.After(.2, function()
                    indicator:SetWidth(indicator.text:GetStringWidth() + 6)
                end)
            end)
        elseif indicator.indicatorType == "color" then
            -- texture type cannot glow by LCG
            indicator.preview = indicator.preview or CreateFrame("Frame", nil, previewButton)
            indicator.preview:SetAllPoints(indicator)
            indicator:SetCooldown(nil, nil, "Curse")
        elseif indicator.indicatorType == "texture" then
            -- texture type cannot glow by LCG
            indicator:SetCooldown()
        else
            indicator.preview = indicator.preview or CreateFrame("Frame", nil, indicator)
            indicator:SetScript("OnShow", function()
                indicator:SetCooldown(GetTime(), 12, nil, 134400, 0)
                indicator.preview.elapsedTime = 0
                indicator.preview:SetScript("OnUpdate", function(self, elapsed)
                    self.elapsedTime = self.elapsedTime + elapsed
                    if self.elapsedTime >= 12 then
                        self.elapsedTime = 0
                        indicator:SetCooldown(GetTime(), 12, nil, 134400, 0)
                    end
                end)
            end)
        end
    end
    indicator.init = true
end

local function UpdateIndicators(layout, indicatorName, setting, value, value2)
    if not indicatorsTab:IsShown() then return end

    if not indicatorName then -- init
        if not layout then -- call from UpdateIndicators() not from Cell:Fire("UpdateIndicators", ...)
            I:RemoveAllCustomIndicators(previewButton)
            for _, t in pairs(currentLayoutTable["indicators"]) do
                local indicator = previewButton.indicators[t["indicatorName"]] or I:CreateIndicator(previewButton, t)
                InitIndicator(t["indicatorName"])
                -- update position
                if t["position"] then
                    P:ClearPoints(indicator)
                    P:Point(indicator, t["position"][1], previewButton, t["position"][2], t["position"][3], t["position"][4])
                end
                -- update anchor
                if t["anchor"] then
                    indicator:SetAnchor(t["anchor"])
                end
                -- update frameLevel
                if t["frameLevel"] then
                    indicator:SetFrameLevel(previewButton.widget.overlayFrame:GetFrameLevel()+t["frameLevel"])
                end
                -- update size
                if t["size"] then
                    -- NOTE: debuffs: ["size"] = {{normalSize}, {bigSize}}
                    if t["indicatorName"] == "debuffs" then
                        indicator:SetSize(t["size"][1], t["size"][2])
                    else
                        P:Size(indicator, t["size"][1], t["size"][2])
                    end
                end
                -- update thickness
                if t["thickness"] then
                    indicator:SetThickness(t["thickness"])
                end
                -- update textWidth
                if t["textWidth"] then
                    indicator:UpdateTextWidth(t["textWidth"])
                end
                -- update border
                if t["border"] then
                    indicator:SetBorder(t["border"])
                end
                -- update height
                if t["height"] then
                    P:Height(indicator, t["height"])
                end
                -- update alpha
                if t["alpha"] then
                    indicator:SetAlpha(t["alpha"])
                    indicator.alpha = t["alpha"]
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
                -- update format
                if t["format"] then -- healthText
                    indicator:SetFormat(t["format"])
                    indicator:SetHealth(21377, 65535)
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
                -- update nameColor
                if t["nameColor"] then
                    indicator:UpdatePreviewColor(t["nameColor"])
                end
                -- update vehicleNamePosition
                if t["vehicleNamePosition"] then
                    indicator:UpdateVehicleNamePosition(t["vehicleNamePosition"])
                end
                -- update custom texture
                if t["customTextures"] then
                    indicator:SetCustomTexture(t["customTextures"])
                    indicator:SetRole(indicator.roles[indicator.role])
                end
                -- update texture
                if t["texture"] then
                    indicator:SetTexture(t["texture"])
                end
                -- update duration
                if type(t["showDuration"]) == "boolean" then
                    indicator:ShowDuration(t["showDuration"])
                end
                 -- update circled nums
                 if type(t["circledStackNums"]) == "boolean" then
                    indicator:SetCircledStackNums(t["circledStackNums"])
                end
                -- after init
                if t["enabled"] then
                    indicator:Show()
                    if indicator.preview then indicator.preview:Show() end
                else
                    indicator:Hide()
                    if indicator.preview then indicator.preview:Hide() end
                end
            end
            -- pixel perfect
            previewButton.func.UpdatePixelPerfect(true)
        end
    else
        local indicator = previewButton.indicators[indicatorName]
        -- changed in IndicatorsTab
        if setting == "enabled" then
            if value then
                indicator:Show()
                if indicator.preview then indicator.preview:Show() end
                if indicator.isTargetedSpells then indicator:ShowGlowPreview() end
            else
                indicator:Hide()
                if indicator.preview then indicator.preview:Hide() end
                if indicator.isTargetedSpells then indicator:HideGlowPreview() end
            end
        elseif setting == "position" then
            P:ClearPoints(indicator)
            P:Point(indicator, value[1], previewButton, value[2], value[3], value[4])
        elseif setting == "anchor" then
            indicator:SetAnchor(value)
        elseif setting == "frameLevel" then
            indicator:SetFrameLevel(previewButton.widget.overlayFrame:GetFrameLevel()+value)
        elseif setting == "size" then
            if indicatorName == "debuffs" then
                indicator:SetSize(value[1], value[2])
            else
                P:Size(indicator, value[1], value[2])
            end
        elseif setting == "size-border" then
            P:Size(indicator, value[1], value[2])
            indicator:SetBorder(value[3])
        elseif setting == "thickness" then
            indicator:SetThickness(value)
        elseif setting == "height" then
            P:Height(indicator, value)
        elseif setting == "textWidth" then
            indicator:UpdateTextWidth(value)
        elseif setting == "alpha" then
            indicator:SetAlpha(value)
            indicator.alpha = value
        elseif setting == "num" then
            for i, frame in ipairs(indicator) do
                if i <= value then
                    frame:Show()
                else
                    frame:Hide()
                end
            end
        elseif setting == "format" then
            indicator:SetFormat(value)
            indicator:SetHealth(21377, 65535)
        elseif setting == "orientation" then
            indicator:SetOrientation(value)
        elseif setting == "font" then
            indicator:SetFont(unpack(value))
            if indicator.isCustomText then
                indicator:Hide()
                indicator:Show()
            end
        elseif setting == "color" then
            indicator:SetColor(unpack(value))
        elseif setting == "colors" then
            indicator:SetColors(value)
        elseif setting == "nameColor" then
            indicator:UpdatePreviewColor(value)
        elseif setting == "vehicleNamePosition" then
            indicator:UpdateVehicleNamePosition(value)
        elseif setting == "statusColors" then
            indicator:Hide()
            indicator:Show()
        elseif setting == "customTextures" then
            indicator:SetCustomTexture(value)
            indicator:SetRole(indicator.roles[indicator.role])
        elseif setting == "texture" then
            indicator:SetTexture(value)
        elseif setting == "checkbutton" then
            if value == "showDuration" then
                indicator:ShowDuration(value2)
                -- update through OnShow
                indicator:Hide()
                indicator:Show()
            elseif value == "circledStackNums" then
                indicator:SetCircledStackNums(value2)
                -- update through OnShow
                indicator:Hide()
                indicator:Show()
            end
        elseif setting == "create" then
            indicator = I:CreateIndicator(previewButton, value)
            -- update position
            if value["position"] then
                P:ClearPoints(indicator)
                P:Point(indicator, value["position"][1], previewButton, value["position"][2], value["position"][3], value["position"][4])
            end
            -- update anchor
            if value["anchor"] then
                indicator:SetAnchor(value["anchor"])
            end
            -- update size
            if value["size"] then
                P:Size(indicator, value["size"][1], value["size"][2])
            end
            -- update frame level
            if value["frameLevel"] then
                indicator:SetFrameLevel(previewButton.widget.overlayFrame:GetFrameLevel()+value["frameLevel"])
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
            -- update colors
            if value["texture"] then
                indicator:SetTexture(value["texture"])
            end
            -- update duration
            if type(value["showDuration"]) == "boolean" then
                indicator:ShowDuration(value["showDuration"])
            end
            -- update circled nums
            if type(value["circledStackNums"]) == "boolean" then
                indicator:SetCircledStackNums(value["circledStackNums"])
            end
            InitIndicator(indicatorName)
            indicator:Show()
        elseif setting == "remove" then
            I:RemoveIndicator(previewButton, indicatorName, value)
        end
    end
end
Cell:RegisterCallback("UpdateIndicators", "PreviewButton_UpdateIndicators", UpdateIndicators)

local function UpdateTargetedSpellsPreview()
    if currentLayoutTable and selected and currentLayoutTable["indicators"][selected]["indicatorName"] == "targetedSpells" then
        previewButton.indicators.targetedSpells:ShowGlowPreview()
    end
end
Cell:RegisterCallback("UpdateTargetedSpells", "UpdateTargetedSpellsPreview", UpdateTargetedSpellsPreview)

-------------------------------------------------
-- layout
-------------------------------------------------
local layoutDropdown
local function CreateLayoutPane()
    local layoutPane = Cell:CreateTitledPane(indicatorsTab, L["Layout"], 136, 50)
    layoutPane:SetPoint("TOPLEFT", indicatorsTab, "TOPLEFT", 5, -5)

    layoutDropdown = Cell:CreateDropdown(layoutPane, 136)
    layoutDropdown:SetPoint("TOPLEFT", 0, -25)
end


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
local listFrame, renameBtn, deleteBtn

local typeItems = {
    {
        ["text"] = L["Icon"],
        ["value"] = "icon",
    },
    {
        ["text"] = L["Icons"],
        ["value"] = "icons",
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
        ["text"] = L["Color"],
        ["value"] = "color",
    },
    {
        ["text"] = L["Texture"],
        ["value"] = "texture",
    },
    -- TODO:
    -- {
    --     ["text"] = "|cff777777"..L["Bars"],
    --     ["value"] = "bars",
    -- },
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

local function CreateListPane()
    local listPane = Cell:CreateTitledPane(indicatorsTab, L["Indicators"], 136, 412)
    listPane:SetPoint("TOPLEFT", 5, -62)

    listFrame = Cell:CreateFrame("IndicatorsTab_ListFrame", listPane)
    listFrame:SetPoint("TOPLEFT", 0, -25)
    listFrame:SetPoint("BOTTOMRIGHT", 0, 44)
    listFrame:Show()
    
    Cell:CreateScrollFrame(listFrame)
    listFrame.scrollFrame:SetScrollStep(19)

    -- buttons
    local createBtn = Cell:CreateButton(listPane, nil, "green-hover", {46, 20}, nil, nil, nil, nil, nil, L["Create"])
    createBtn:SetPoint("TOPLEFT", listFrame, "BOTTOMLEFT", 0, -5)
    createBtn:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\create.blp", {16, 16}, {"TOPLEFT", 14, 0})
    createBtn:SetScript("OnClick", function()
        local popup = Cell:CreateConfirmPopup(indicatorsTab, 200, L["Create new indicator"], function(self)
            local name = strtrim(self.editBox:GetText())
            local indicatorName
            local indicatorType, indicatorAuraType = self.dropdown1:GetSelected(), self.dropdown2:GetSelected()
            -- TODO: if indicatorType == "bars" then return end
            
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
                    ["frameLevel"] = 5,
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
                    ["frameLevel"] = 5,
                    ["font"] = {"Cell ".._G.DEFAULT, 12, "Outline", 0},
                    ["colors"] = {{0,1,0}, {1,1,0,.5}, {1,0,0,3}},
                    ["auraType"] = indicatorAuraType,
                    ["auras"] = {},
                    ["showDuration"] = true,
                    ["circledStackNums"] = false,
                })
            elseif indicatorType == "bar" then
                tinsert(currentLayoutTable["indicators"], {
                    ["name"] = name,
                    ["indicatorName"] = indicatorName,
                    ["type"] = indicatorType,
                    ["enabled"] = true,
                    ["position"] = {"TOPRIGHT", "TOPRIGHT", -1, 2},
                    ["frameLevel"] = 5,
                    ["size"] = {18, 4},
                    ["colors"] = {{0,1,0}, {1,1,0,.5}, {1,0,0,3}},
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
                    ["frameLevel"] = 5,
                    ["size"] = {11, 4},
                    ["colors"] = {{0,1,0}, {1,1,0,.5}, {1,0,0,3}},
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
                    ["frameLevel"] = 5,
                    ["size"] = {13, 13},
                    ["num"] = 3,
                    ["orientation"] = "right-to-left",
                    ["font"] = {"Cell ".._G.DEFAULT, 11, "Outline", 2},
                    ["showDuration"] = false,
                    ["auraType"] = indicatorAuraType,
                    ["auras"] = {},
                })
            elseif indicatorType == "color" then
                tinsert(currentLayoutTable["indicators"], {
                    ["name"] = name,
                    ["indicatorName"] = indicatorName,
                    ["type"] = indicatorType,
                    ["enabled"] = true,
                    ["anchor"] = "healthbar-current",
                    ["colors"] = {"gradient-vertical", {1, 0, 0.4, 1}, {0, 0, 0, 1}},
                    ["auraType"] = indicatorAuraType,
                    ["auras"] = {},
                })
            elseif indicatorType == "texture" then
                tinsert(currentLayoutTable["indicators"], {
                    ["name"] = name,
                    ["indicatorName"] = indicatorName,
                    ["type"] = indicatorType,
                    ["enabled"] = true,
                    ["position"] = {"TOP", "TOP", 0, 0},
                    ["size"] = {16, 16},
                    ["frameLevel"] = 10,
                    ["texture"] = {"Interface\\AddOns\\Cell\\Media\\Shapes\\circle_filled.tga", 0, {1, 1, 1, 1}},
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
            -- check scroll
            if last+1 > 15 then
                listFrame.scrollFrame:ScrollToBottom()
            end

        end, nil, true, true, 2)
        popup:SetPoint("TOPLEFT", 117, -100)
        popup.dropdown1:SetItems(typeItems)
        popup.dropdown1:SetSelectedItem(1)
        -- popup.dropdown1:SetEnabled(false)
        popup.dropdown2:SetItems(auraTypeItems)
        popup.dropdown2:SetSelectedItem(1)
    end)

    renameBtn = Cell:CreateButton(listPane, nil, "blue-hover", {46, 20}, nil, nil, nil, nil, nil, L["Rename"])
    renameBtn:SetPoint("TOPLEFT", createBtn, "TOPRIGHT", P:Scale(-1), 0)
    renameBtn:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\rename.blp", {16, 16}, {"TOPLEFT", 14, -2})
    renameBtn:SetEnabled(false)
    renameBtn:SetScript("OnClick", function()
        local name = currentLayoutTable["indicators"][selected]["name"]
        local popup = Cell:CreateConfirmPopup(indicatorsTab, 200, L["Rename indicator"].."\n"..name, function(self)
            local newName = strtrim(self.editBox:GetText())
            currentLayoutTable["indicators"][selected]["name"] = newName
            listButtons[selected]:SetText(newName)
        end, nil, true, true)
        popup:SetPoint("TOPLEFT", 117, -200)
    end)

    deleteBtn = Cell:CreateButton(listPane, nil, "red-hover", {46, 20}, nil, nil, nil, nil, nil, L["Delete"])
    deleteBtn:SetPoint("TOPLEFT", renameBtn, "TOPRIGHT", P:Scale(-1), 0)
    deleteBtn:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\trash.blp", {16, 16}, {"TOPLEFT", 14, -2})
    deleteBtn:SetEnabled(false)
    deleteBtn:SetScript("OnClick", function()
        local name = currentLayoutTable["indicators"][selected]["name"]
        local indicatorName = currentLayoutTable["indicators"][selected]["indicatorName"]
        local auraType = currentLayoutTable["indicators"][selected]["auraType"]

        local popup = Cell:CreateConfirmPopup(indicatorsTab, 200, L["Delete indicator"].."?\n"..name, function(self)
            Cell:Fire("UpdateIndicators", currentLayout, indicatorName, "remove", auraType)
            tremove(currentLayoutTable["indicators"], selected)
            LoadIndicatorList()
            listButtons[1]:Click()
        end, nil, true)
        popup:SetPoint("TOPLEFT", 117, -200)
    end)

    local importBtn = Cell:CreateButton(listPane, nil, "class-hover", {46, 20}, nil, nil, nil, nil, nil, L["Import"])
    importBtn:SetPoint("TOPLEFT", createBtn, "BOTTOMLEFT", 0, P:Scale(1))
    importBtn:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\import.blp", {16, 16}, {"TOPLEFT", 14, -2})
    importBtn:SetScript("OnClick", function()
        F:ShowIndicatorsImportFrame(currentLayout)
    end)

    local exportBtn = Cell:CreateButton(listPane, nil, "class-hover", {46, 20}, nil, nil, nil, nil, nil, L["Export"])
    exportBtn:SetPoint("TOPLEFT", importBtn, "TOPRIGHT", P:Scale(-1), 0)
    exportBtn:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\export.blp", {16, 16}, {"TOPLEFT", 14, -2})
    exportBtn:SetScript("OnClick", function()
        F:ShowIndicatorsExportFrame(currentLayout)
    end)

    local copyBtn = Cell:CreateButton(listPane, nil, "class-hover", {46, 20}, nil, nil, nil, nil, nil, L["Copy"], L["Copy indicators from one layout to another"])
    copyBtn:SetPoint("TOPLEFT", exportBtn, "TOPRIGHT", P:Scale(-1), 0)
    copyBtn:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\copy.blp", {16, 16}, {"TOPLEFT", 14, -2})
    copyBtn:SetScript("OnClick", function()
        F:ShowIndicatorsCopyFrame()
    end)
end

-------------------------------------------------
-- indicator settings
-------------------------------------------------
local othersAlpha, settingsFrame

local function CreateSettingsPane()
    local settingsPane = Cell:CreateTitledPane(indicatorsTab, L["Indicator Settings"], 274, 469)
    settingsPane:SetPoint("TOPLEFT", 153, -5)

    othersAlpha = Cell:CreateSlider("", settingsPane, 0, 1, 50, .1, nil, function(value)
        CellDB["indicatorPreviewAlpha"] = value
        listButtons[selected]:Click()
    end)
    othersAlpha:SetPoint("TOPRIGHT", 0, -4)
    othersAlpha.currentEditBox:Hide()
    othersAlpha.lowText:Hide()
    othersAlpha.highText:Hide()
    
    local alphaText = settingsPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_CLASS")
    alphaText:SetPoint("BOTTOM", settingsPane.line, "TOP", 0, P:Scale(2))
    alphaText:SetPoint("RIGHT", othersAlpha, "LEFT", -5, 0)
    alphaText:SetText(L["Alpha"])

    -- settings frame
    settingsFrame = Cell:CreateFrame("IndicatorsTab_SettingsFrame", settingsPane, 10, 10, true)
    settingsFrame:SetPoint("TOPLEFT", 0, -25)
    settingsFrame:SetPoint("BOTTOMRIGHT")
    settingsFrame:Show()
    
    Cell:CreateScrollFrame(settingsFrame)
    settingsFrame.scrollFrame:SetScrollStep(35)
end

local indicatorSettings = {
    ["nameText"] = {"enabled", "nameColor", "textWidth", "vehicleNamePosition", "namePosition", "font-noOffset"},
    ["statusText"] = {"enabled", "statusColors", "statusPosition", "frameLevel", "font-noOffset"},
    ["healthText"] = {"enabled", "format", "checkbutton:hideFull", "color", "position", "frameLevel", "font-noOffset"},
    ["statusIcon"] = {"|TInterface\\RaidFrame\\Raid-Icon-Rez:18:18|t "..
        "|TInterface\\TargetingFrame\\UI-PhasingIcon:18:18|t "..
        "|A:nameplates-icon-flag-horde:18:18|a "..
        "|A:nameplates-icon-flag-alliance:18:18|a "..
        "|A:nameplates-icon-orb-blue:18:18|a "..
        "|A:nameplates-icon-orb-green:18:18|a "..
        "|A:nameplates-icon-orb-orange:18:18|a "..
        "|A:nameplates-icon-orb-purple:18:18|a ", "enabled", "position", "frameLevel", "size-square"},
    ["roleIcon"] = {"enabled", "position", "size-square", "customTextures"},
    ["leaderIcon"] = {"|cffb7b7b7"..L["Leader Icons will hide while in combat"], "enabled", "position", "size-square"},
    ["readyCheckIcon"] = {"frameLevel", "size-square"},
    ["playerRaidIcon"] = {"enabled", "position", "frameLevel", "size-square", "alpha"},
    ["targetRaidIcon"] = {"enabled", "position", "frameLevel", "size-square", "alpha"},
    ["aggroBlink"] = {"enabled", "position", "frameLevel", "size"},
    ["aggroBorder"] = {"enabled", "frameLevel", "thickness"},
    ["aggroBar"] = {"enabled", "position", "frameLevel", "size-bar"},
    ["shieldBar"] = {"|cffb7b7b7"..L["With this indicator enabled, shield / overshield textures are disabled"], "enabled", "color-alpha", "position", "frameLevel", "height"},
    ["aoeHealing"] = {"enabled", "color", "height"},
    ["externalCooldowns"] = {"enabled", "checkbutton2:showDuration:"..L["Show duration text instead of icon animation"], "num:5", "orientation", "position", "frameLevel", "size", "font"},
    ["defensiveCooldowns"] = {"enabled", "checkbutton2:showDuration:"..L["Show duration text instead of icon animation"], "num:5", "orientation", "position", "frameLevel", "size", "font"},
    ["tankActiveMitigation"] = {"|cffb7b7b7"..I:GetTankActiveMitigationString(), "enabled", "position", "frameLevel", "size"},
    ["dispels"] = {"enabled", "checkbutton:dispellableByMe", "checkbutton2:enableHighlight", "position", "frameLevel", "size-square"},
    ["debuffs"] = {"enabled", "checkbutton:dispellableByMe", "blacklist", "bigDebuffs", "checkbutton2:showDuration:"..L["Show duration text instead of icon animation"], "num:10", "orientation", "position", "frameLevel", "size-normal-big", "font"},
    ["raidDebuffs"] = {"|cffb7b7b7"..L["You can config debuffs in %s"]:format(Cell:GetPlayerClassColorString()..L["Raid Debuffs"].."|r"), "enabled", "checkbutton:onlyShowTopGlow", "num:3", "orientation", "position", "frameLevel", "size-border", "font"},
    ["targetedSpells"] = {"enabled", "spells", "glow", "position", "frameLevel", "size-border", "font"},
    ["targetCounter"] = {"|cffff2727"..L["HIGH CPU USAGE"].."!|r |cffb7b7b7"..L["Check all visible enemy nameplates. Battleground/Arena only."], "enabled", "color", "position", "frameLevel", "font"},
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
        -- if indicatorName == "tankActiveMitigation" then
        --     tinsert(settingsTable, 1, "|cffb7b7b7"..L["Tank Active Mitigation refers to a single, specific ability that a Tank must use as a counter to specific Boss abilities. These Boss abilities are designated as Mitigation Checks."])
        -- end
    else
        if indicatorType == "icon" then
            settingsTable = {"enabled", "auras", "checkbutton2:showDuration:"..L["Show duration text instead of icon animation"], "position", "frameLevel", "size-square", "font"}
        elseif indicatorType == "text" then
            settingsTable = {"enabled", "auras", "checkbutton2:showDuration", "checkbutton3:circledStackNums:"..L["Require font support"], "colors", "position", "frameLevel", "font"}
        elseif indicatorType == "bar" then
            settingsTable = {"enabled", "auras", "colors", "position", "frameLevel", "size-bar"}
        elseif indicatorType == "rect" then
            settingsTable = {"enabled", "auras", "colors", "position", "frameLevel", "size"}
        elseif indicatorType == "icons" then
            settingsTable = {"enabled", "auras", "checkbutton2:showDuration:"..L["Show duration text instead of icon animation"], "num:10", "orientation", "position", "frameLevel", "size-square", "font"}
        elseif indicatorType == "color" then
            settingsTable = {"enabled", "auras", "customColors", "anchor"}
        elseif indicatorType == "texture" then
            settingsTable = {"enabled", "auras", "texture", "position", "frameLevel", "size"}
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
            w:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, P:Scale(-7))
        else
            w:SetPoint("TOPLEFT")
        end
        w:SetPoint("RIGHT")
        last = w

        -- NOTE: convert currentSetting to ACTUAL TABLE INDEX
        local currentSetting = settingsTable[i]
        if currentSetting == "color-alpha" then currentSetting = "color" end
        if currentSetting == "statusColors" then currentSetting = "colors" end
        if currentSetting == "size-square" or currentSetting == "size-bar" or currentSetting == "size-normal-big" then currentSetting = "size" end
        if currentSetting == "font-noOffset" then currentSetting = "font" end
        if currentSetting == "namePosition" or currentSetting == "statusPosition" then currentSetting = "position" end
        
        -- echo
        if string.find(currentSetting, "checkbutton") then
            local _, setting, tooltip = string.split(":", currentSetting)
            w:SetDBValue(setting, currentLayoutTable["indicators"][id][setting], tooltip)
        elseif currentSetting == "auras" then
            -- TODO: indicatorType == "bars"
            w:SetDBValue(L[F:UpperFirst(currentLayoutTable["indicators"][id]["auraType"]).." List"], currentLayoutTable["indicators"][id]["auras"], indicatorType == "icons", indicatorType == "icons")
        elseif currentSetting == "blacklist" then
            w:SetDBValue(L["Debuff Filter (blacklist)"], CellDB["debuffBlacklist"], true)
        elseif currentSetting == "bigDebuffs" then
            w:SetDBValue(L["Big Debuffs"], currentLayoutTable["indicators"][id]["bigDebuffs"], true)
        elseif currentSetting == "spells" then
            w:SetDBValue(L["Spell List"], currentLayoutTable["indicators"][id]["spells"], true)
        elseif currentSetting == "size-border" then
            w:SetDBValue(currentLayoutTable["indicators"][id]["size"], currentLayoutTable["indicators"][id]["border"])
        elseif currentSetting == "customColors" then
            w:SetDBValue(currentLayoutTable["indicators"][id]["auraType"], currentLayoutTable["indicators"][id]["colors"])
        elseif string.find(currentSetting, "num") then
            w:SetDBValue(currentLayoutTable["indicators"][id]["num"], tonumber(select(2,string.split(":", currentSetting))))
            currentSetting = "num"
        else
            w:SetDBValue(currentLayoutTable["indicators"][id][currentSetting])
        end

        height = height + w:GetHeight()

        -- update func
        w:SetFunc(function(value, customSetting)
            if value == nil and customSetting then --* NOTE: just Fire("UpdateIndicators") with customSetting
                F:Debug("|cff77ff77SetFunc(Custom):|r ", currentLayout, indicatorName, customSetting)
                Cell:Fire("UpdateIndicators", currentLayout, indicatorName, customSetting)
            else
                if string.find(currentSetting, "checkbutton") then
                    local setting = select(2,string.split(":", currentSetting))
                    currentLayoutTable["indicators"][id][setting] = value
                    Cell:Fire("UpdateIndicators", currentLayout, indicatorName, "checkbutton", setting, value) -- indicatorName, setting, value, value2
                elseif currentSetting == "auras" then
                    -- currentLayoutTable["indicators"][id][currentSetting] = value -- NOTE: already changed in widget
                    Cell:Fire("UpdateIndicators", currentLayout, indicatorName, currentSetting, currentLayoutTable["indicators"][id]["auraType"], value)
                elseif currentSetting == "blacklist" then
                    CellDB["debuffBlacklist"] = value
                    Cell.vars.debuffBlacklist = F:ConvertTable(CellDB["debuffBlacklist"])
                    Cell:Fire("UpdateIndicators", currentLayout, "", "blacklist")
                elseif currentSetting == "spells" then
                    -- currentLayoutTable["indicators"][id][currentSetting] = value -- NOTE: already changed in widget
                    Cell:Fire("UpdateTargetedSpells", "spells", value)
                elseif currentSetting == "glow" then
                    -- NOTE: already changed in widget
                    Cell:Fire("UpdateTargetedSpells", "glow", value)
                elseif currentSetting == "size-border" then
                    currentLayoutTable["indicators"][id]["size"][1] = value[1]
                    currentLayoutTable["indicators"][id]["size"][2] = value[2]
                    currentLayoutTable["indicators"][id]["border"] = value[3]
                    Cell:Fire("UpdateIndicators", currentLayout, indicatorName, currentSetting, value)
                elseif currentSetting == "customColors" then
                    currentLayoutTable["indicators"][id]["colors"] = value
                    Cell:Fire("UpdateIndicators", currentLayout, indicatorName, "colors", value)
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
            end
        end)
    end

    settingsFrame.scrollFrame:SetContentHeight(height + (#widgets-1)*7)

    if string.find(indicatorName, "indicator") then
        renameBtn:SetEnabled(true)
        deleteBtn:SetEnabled(true)
    else
        renameBtn:SetEnabled(false)
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
            b = Cell:CreateButton(listFrame.scrollFrame.content, t["name"], "transparent-class", {20, 20})
            -- b = Cell:CreateButton(listFrame.scrollFrame.content, t["name"].." |cff7f7f7f("..L[t["auraType"]]..")", "transparent-class", {20, 20})
            b.typeIcon = b:CreateTexture(nil, "ARTWORK")
            b.typeIcon:SetPoint("RIGHT", -2, 0)
            b.typeIcon:SetSize(16, 16)
            b.typeIcon:SetTexture("Interface\\AddOns\\Cell\\Media\\Indicators\\indicator-"..t["type"])
            -- b.typeIcon:SetAlpha(0.5)
            if t["auraType"] == "buff" then
                b.typeIcon:SetVertexColor(0.9, 1, 0.9, 0.5)
            else -- debuff
                b.typeIcon:SetVertexColor(1, 0.9, 0.9, 0.5)
            end

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
        local i = previewButton.indicators[currentLayoutTable["indicators"][id]["indicatorName"]]
        if i:IsObjectType("StatusBar") then
            LCG.PixelGlow_Start(i.border)
            i:SetAlpha(1)
        elseif i:IsObjectType("Texture") or i:IsObjectType("FontString") then
            LCG.PixelGlow_Start(i.preview)
            i:SetAlpha(i.alpha or 1)
        else
            if i.isRaidDebuffs then
                LCG.PixelGlow_Start(i, nil, nil, nil, nil, nil, 2, 2)
            elseif i.isTargetedSpells then
                LCG.PixelGlow_Start(i, nil, nil, nil, nil, nil, 2, 2)
                if currentLayoutTable["indicators"][id]["enabled"] then i:ShowGlowPreview() end
            elseif i.isAggroBorder then
                LCG.PixelGlow_Start(i, nil, nil, nil, nil, nil, 2, 2)
            else
                LCG.PixelGlow_Start(i)
            end

            if i.isAggroBlink then
                i.blink.alpha:SetFromAlpha(1)
            else
                i:SetAlpha(i.alpha or 1)
            end
        end
    end, function(id)
        local i = previewButton.indicators[currentLayoutTable["indicators"][id]["indicatorName"]]
        if i:IsObjectType("StatusBar") then
            LCG.PixelGlow_Stop(i.border)
        elseif i:IsObjectType("Texture") or i:IsObjectType("FontString") then
            LCG.PixelGlow_Stop(i.preview)
        else
            LCG.PixelGlow_Stop(i)
            if i.isTargetedSpells then
                i:HideGlowPreview()
            end
        end

        if i.isAggroBlink then
            i.blink.alpha:SetFromAlpha(CellDB["indicatorPreviewAlpha"])
        else
            i:SetAlpha(CellDB["indicatorPreviewAlpha"])
        end
    end)
end

-------------------------------------------------
-- functions
-------------------------------------------------
local init
local function ShowTab(tab)
    if tab == "indicators" then
        if not init then
            init = true
            CreateLayoutPane()
            CreateListPane()     
            CreateSettingsPane()  
        end

        indicatorsTab:Show()
        LoadLayoutDropdown()
        
        if currentLayout == Cell.vars.currentLayout then return end
        currentLayout = Cell.vars.currentLayout
        currentLayoutTable = Cell.vars.currentLayoutTable
        UpdatePreviewButton()
        UpdateIndicators()
        
        layoutDropdown:SetSelected(currentLayout == "default" and _G.DEFAULT or currentLayout)
        LoadIndicatorList()
        listButtons[1]:Click()
        othersAlpha:SetValue(CellDB["indicatorPreviewAlpha"])
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

local function UpdateAppearance()
    if previewButton.loaded and currentLayout == Cell.vars.currentLayout then
        UpdatePreviewButton()
    end
end
Cell:RegisterCallback("UpdateAppearance", "IndicatorsTab_UpdateAppearance", UpdateAppearance)

local function IndicatorsChanged(layout)
    -- reload after indicator copy
    if currentLayout == layout then
        F:Debug("Reload Indicator List:", layout)
        -- update indicators for preview button
        UpdateIndicators()
        -- reload list
        LoadIndicatorList()
        listButtons[1]:Click()
    end
end
Cell:RegisterCallback("IndicatorsChanged", "IndicatorsTab_IndicatorsChanged", IndicatorsChanged)