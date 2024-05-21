local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local B = Cell.bFuncs
local I = Cell.iFuncs
local P = Cell.pixelPerfectFuncs
local LCG = LibStub("LibCustomGlow-1.0")

CELL_RECTANGULAR_CUSTOM_INDICATOR_ICONS = false

local indicatorsTab = Cell:CreateFrame("CellOptionsFrame_IndicatorsTab", Cell.frames.optionsFrame, nil, nil, true)
Cell.frames.indicatorsTab = indicatorsTab
indicatorsTab:SetAllPoints(Cell.frames.optionsFrame)

local selected, currentLayout, currentLayoutTable
local LoadIndicatorList
local listButtons = {}
local ListHighlightFn

-------------------------------------------------
-- preview
-------------------------------------------------
local previewButton, previewButtonBG, previewAlphaSlider, previewScaleSlider

local function CreatePreviewButton()
    previewButton = CreateFrame("Button", "CellIndicatorsPreviewButton", indicatorsTab, "CellPreviewButtonTemplate")
    -- previewButton.type = "main" -- layout setup
    -- previewButton:SetPoint("TOPLEFT", indicatorsTab, "TOPRIGHT", 10, -55)
    previewButton:UnregisterAllEvents()
    previewButton:SetScript("OnEnter", nil)
    previewButton:SetScript("OnLeave", nil)
    previewButton:SetScript("OnShow", nil)
    previewButton:SetScript("OnHide", nil)
    previewButton:SetScript("OnUpdate", nil)
    previewButton:Show()

    previewButton.states.class = Cell.vars.playerClass

    previewButton.widgets.healthBar:SetMinMaxValues(0, 1)
    previewButton.widgets.healthBar:SetValue(1)
    previewButton.widgets.powerBar:SetMinMaxValues(0, 1)
    previewButton.widgets.powerBar:SetValue(1)

    previewButtonBG = Cell:CreateFrame("CellIndicatorsPreviewButtonBG", indicatorsTab)
    -- previewButtonBG:SetPoint("TOPLEFT", indicatorsTab, "TOPRIGHT", 5, -1)
    -- previewButtonBG:SetPoint("BOTTOMRIGHT", previewButton, 5, -5)
    previewButtonBG:SetPoint("BOTTOM", previewButton, 0, -5)
    previewButtonBG:SetFrameStrata("BACKGROUND")
    Cell:StylizeFrame(previewButtonBG, {0.1, 0.1, 0.1, 0.77}, {0, 0, 0, 0})
    previewButtonBG:Show()

    function previewButton:UpdatePoint()
        previewButton:ClearAllPoints()
        previewButtonBG:ClearAllPoints()
        previewButtonBG:SetPoint("TOPLEFT", indicatorsTab, "TOPRIGHT", 5, -1)

        local x = 10
        local y = Round(-70 / CellDB["indicatorPreviewScale"])

        if (previewButton.width * CellDB["indicatorPreviewScale"]) <= 105 then
            x = Round((115-previewButton.width)/2)+5
            previewButtonBG:SetPoint("BOTTOM", previewButton, 0, -5)
            P:Width(previewButtonBG, 115)
        else
            previewButtonBG:SetPoint("BOTTOMRIGHT", previewButton, 5, -5)
        end

        x = Round(x / CellDB["indicatorPreviewScale"])
        previewButton:SetPoint("TOPLEFT", indicatorsTab, "TOPRIGHT", x, y)
    end

    local previewText = previewButtonBG:CreateFontString(nil, "OVERLAY", "CELL_FONT_CLASS_TITLE")
    previewText:SetPoint("TOP", 0, -3)
    previewText:SetText(L["Preview"])

    -- preview alpha
    previewAlphaSlider = Cell:CreateSlider(L["Alpha"], previewButtonBG, 0, 1, 50, 0.1, nil, function(value)
        CellDB["indicatorPreviewAlpha"] = value
        listButtons[selected]:Click()
    end)
    previewAlphaSlider:SetPoint("TOPLEFT", 5, -35)
    previewAlphaSlider.currentEditBox:Hide()
    previewAlphaSlider.lowText:Hide()
    previewAlphaSlider.highText:Hide()

    -- preview scale
    previewScaleSlider = Cell:CreateSlider(L["Scale"], previewButtonBG, 1, 5, 50, 1, nil, function(value)
        CellDB["indicatorPreviewScale"] = value
        previewButton:SetScale(value)
        previewButton:UpdatePoint()
    end)
    previewScaleSlider:SetPoint("TOPLEFT", previewAlphaSlider, "TOPRIGHT", 5, 0)
    previewScaleSlider.currentEditBox:Hide()
    previewScaleSlider.lowText:Hide()
    previewScaleSlider.highText:Hide()

    -- local alphaText = settingsPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_CLASS")
    -- alphaText:SetPoint("BOTTOM", settingsPane.line, "TOP", 0, P:Scale(2))
    -- alphaText:SetPoint("RIGHT", previewAlphaSlider, "LEFT", -5, 0)
    -- alphaText:SetText(L["Alpha"])

    Cell:Fire("CreatePreview", previewButton)
end

local function UpdatePreviewButton()
    P:Size(previewButton, currentLayoutTable["main"]["size"][1], currentLayoutTable["main"]["size"][2])
    B:SetOrientation(previewButton, currentLayoutTable["barOrientation"][1], currentLayoutTable["barOrientation"][2])
    B:SetPowerSize(previewButton, currentLayoutTable["main"]["powerSize"])

    previewButton:UpdatePoint()

    previewButton.widgets.healthBar:SetStatusBarTexture(Cell.vars.texture)
    previewButton.widgets.powerBar:SetStatusBarTexture(Cell.vars.texture)

    -- health color
    local r, g, b = F:GetHealthBarColor(1, false, F:GetClassColor(Cell.vars.playerClass))
    previewButton.widgets.healthBar:SetStatusBarColor(r, g, b, CellDB["appearance"]["barAlpha"])

    -- power color
    r, g, b = F:GetPowerBarColor("player", Cell.vars.playerClass)
    previewButton.widgets.powerBar:SetStatusBarColor(r, g, b)

    -- alpha
    previewButton:SetBackdropColor(0, 0, 0, CellDB["appearance"]["bgAlpha"])

    Cell:Fire("UpdatePreview", previewButton)
end

-- indicator preview onupdate
local function SetOnUpdate(indicator, type, icon, stack)
    indicator.preview = indicator.preview or CreateFrame("Frame", nil, indicator)
    indicator.preview:SetScript("OnUpdate", function(self, elapsed)
        self.elapsedTime = (self.elapsedTime or 0) + elapsed
        if self.elapsedTime >= 13 then
            self.elapsedTime = 0
            indicator:SetCooldown(GetTime(), 13, type, icon, stack)
        end
    end)
    indicator:SetScript("OnShow", function()
        indicator.preview.elapsedTime = 0
        indicator:SetCooldown(GetTime(), 13, type, icon, stack)
    end)
end

-- init preview button indicator animation
local function InitIndicator(indicatorName)
    local indicator = previewButton.indicators[indicatorName]
    if indicator.init then return end

    if indicatorName == "nameText" then
        previewButton.states.name = UnitName("player")
        previewButton.states.isPlayer = true
        indicator.isPreview = true
        indicator:UpdateName()
        indicator:UpdateVehicleName()
        -- texture type cannot glow by LCG
        indicator.preview = indicator.preview or CreateFrame("Frame", nil, previewButton)
        indicator.preview:SetAllPoints(indicator)

    elseif indicatorName == "statusText" then
        local count = 2
        local maxCount = Cell.isRetail and 9 or 6
        local ticker
        indicator:SetScript("OnShow", function()
            if indicator.showTimer then
                indicator.timer:Show()
            else
                indicator.timer:Hide()
            end

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

                if count < maxCount then
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
        indicator.tex:SetTexture("Interface\\AddOns\\Cell\\Media\\UI-LFG-ICON-PORTRAITROLES.blp")
        indicator.tex:SetTexCoord(GetTexCoordsForRoleSmallCircle("DAMAGER"))
        -- texture type cannot glow by LCG
        indicator.preview = indicator.preview or CreateFrame("Frame", nil, previewButton)
        indicator.preview:SetAllPoints(indicator)
        indicator.roles = {"TANK", "HEALER", "DAMAGER"}
        indicator.role = 1
        indicator.elapsed = 0
        indicator.preview:SetScript("OnUpdate", function(self, elapsed)
            indicator.elapsed = indicator.elapsed + elapsed
            if indicator.elapsed >= 1.5 then
                indicator.elapsed = 0
                indicator.role = (indicator.role + 1 > 3) and 1 or indicator.role + 1
                indicator:SetRole(indicator.roles[indicator.role])
            end
        end)

    elseif indicatorName == "partyAssignmentIcon" then
        -- texture type cannot glow by LCG
        indicator.preview = indicator.preview or CreateFrame("Frame", nil, previewButton)
        indicator.preview:SetAllPoints(indicator)
        indicator.roles = {"Interface\\GroupFrame\\UI-Group-MainTankIcon", "Interface\\GroupFrame\\UI-Group-MainAssistIcon"}
        indicator.role = 1
        indicator.elapsed = 0
        indicator.preview:SetScript("OnUpdate", function(self, elapsed)
            indicator.elapsed = indicator.elapsed + elapsed
            if indicator.elapsed >= 1.5 then
                indicator.elapsed = 0
                indicator.role = (indicator.role + 1 > 2) and 1 or indicator.role + 1
                indicator:SetTexture(indicator.roles[indicator.role])
            end
        end)

    elseif indicatorName == "leaderIcon" then
        indicator:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
        -- texture type cannot glow by LCG
        indicator.preview = indicator.preview or CreateFrame("Frame", nil, previewButton)
        indicator.preview:SetAllPoints(indicator)

    elseif indicatorName == "readyCheckIcon" then
        local status = {"ready", "notready", "waiting"}
        indicator:SetScript("OnShow", function()
            indicator.elapsed = 0
            indicator.current = 1
            indicator:SetStatus("ready")
        end)
        indicator:SetScript("OnUpdate", function(self, elapsed)
            indicator.elapsed = (indicator.elapsed or 0) + elapsed
            if indicator.elapsed >= 2 then
                indicator.elapsed = 0
                indicator.current = indicator.current + 1
                if indicator.current > 3 then indicator.current = 1 end
                indicator:SetStatus(status[indicator.current])
            end
        end)

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
        indicator:SetValue(0.5)

    elseif indicatorName == "powerWordShield" then
        indicator:SetScript("OnShow", function()
            indicator.elapsed = 0
            indicator:UpdateShield(200, 200)
            indicator:SetShieldCooldown(GetTime(), 30)
            indicator:SetWeakenedSoulCooldown(GetTime(), 15)
        end)

        indicator:SetScript("OnUpdate", function(self, elapsed)
            indicator.elapsed = (indicator.elapsed or 0) + elapsed
            indicator:UpdateShield(200-indicator.elapsed*10)
            if indicator.elapsed >= 20 then
                indicator.elapsed = 0
                indicator:SetShieldCooldown(GetTime(), 30)
                indicator:SetWeakenedSoulCooldown(GetTime(), 15)
            end
        end)

    elseif indicatorName == "tankActiveMitigation" then
        indicator.value = 0
        indicator:SetMinMaxValues(0, 100)
        indicator:SetValue(0)
        indicator:SetScript("OnUpdate", function(self, elapsed)
            self.value = self.value + 1
            if self.value >= 100 then
                self.value = 0
            end
            self:SetValue(self.value)
        end)
        function indicator:SetColor(cType, cTable)
            if cType == "class_color" then
                indicator.tex:SetColorTexture(F:GetClassColor(Cell.vars.playerClass))
            else
                indicator.tex:SetColorTexture(cTable[1], cTable[2], cTable[3])
            end
        end

    elseif indicatorName == "debuffs" then
        local types = {"", "Curse", "Disease", "Magic", "Poison", "", "Curse", "Disease", "Magic", "Poison"}
        local icons = {132155, 136139, 136128, 240443, 136182, 132155, 136139, 136128, 240443, 136182}
        for i = 1, 10 do
            SetOnUpdate(indicator[i], types[i], icons[i], i)
        end

    elseif indicatorName == "dispels" then
        indicator.isDispels = true

        local debuffTypes = {
            {["Curse"]=true},
            {["Disease"]=true},
            {["Magic"]=true},
            {["Poison"]=true},
            {["Bleed"]=true},
        }

        -- override
        indicator.SetDispels = function(self, dispelTypes)
            local r, g, b = 0, 0, 0
            local found

            self.highlight:Hide()

            local i = 1
            for dispelType, showHighlight in pairs(dispelTypes) do
                -- highlight
                if not found and self.highlightType ~= "none" and dispelType and showHighlight then
                    found = true
                    local r, g, b = I.GetDebuffTypeColor(dispelType)
                    if self.highlightType == "entire" then
                        self.highlight:SetVertexColor(r, g, b, 0.5)
                    elseif self.highlightType == "current" then
                        self.highlight:SetVertexColor(r, g, b, 1)
                    elseif self.highlightType == "gradient" or self.highlightType == "gradient-half" then
                        self.highlight:SetGradient("VERTICAL", CreateColor(r, g, b, 1), CreateColor(r, g, b, 0))
                    end
                    if indicator.isVisible then self.highlight:Show() end
                end
                -- icons
                if self.showIcons then
                    self[i]:SetDispel(dispelType)
                    i = i + 1
                end
            end

            self:UpdateSize(i)

            -- hide unused
            for j = i, 5 do
                self[j]:Hide()
            end
        end

        indicator.UpdateHighlight = function(self, highlightType)
            indicator.highlightType = highlightType

            if highlightType == "none" then
                indicator.highlight:Hide()
            elseif highlightType == "gradient" then
                indicator.highlight:ClearAllPoints()
                indicator.highlight:SetAllPoints(previewButton.widgets.healthBar)
                indicator.highlight:SetTexture("Interface\\Buttons\\WHITE8x8")
            elseif highlightType == "gradient-half" then
                indicator.highlight:ClearAllPoints()
                indicator.highlight:SetPoint("BOTTOMLEFT", previewButton.widgets.healthBar)
                indicator.highlight:SetPoint("TOPRIGHT", previewButton.widgets.healthBar, "RIGHT")
                indicator.highlight:SetTexture("Interface\\Buttons\\WHITE8x8")
            elseif highlightType == "entire" then
                indicator.highlight:ClearAllPoints()
                indicator.highlight:SetAllPoints(previewButton.widgets.healthBar)
                indicator.highlight:SetTexture("Interface\\Buttons\\WHITE8x8")
            elseif highlightType == "current" then
                indicator.highlight:ClearAllPoints()
                indicator.highlight:SetAllPoints(previewButton.widgets.healthBar:GetStatusBarTexture())
                indicator.highlight:SetTexture(Cell.vars.texture)
            end

            -- preview
            indicator.elapsed = 1
            indicator.current = 1
            indicator:SetScript("OnUpdate", function(self, elapsed)
                indicator.elapsed = indicator.elapsed + elapsed
                if indicator.elapsed >= 1 then
                    indicator.elapsed = 0
                    indicator:SetDispels(debuffTypes[indicator.current])
                    indicator.current = indicator.current + 1
                    if indicator.current == 6 then indicator.current = 1 end
                end
            end)
        end

    elseif indicatorName == "raidDebuffs" then
        indicator.isRaidDebuffs = true
        local types = {"", "Curse", "Magic"}
        for i = 1, 3 do
            indicator[i]:HookScript("OnShow", function()
                indicator[i]:SetCooldown(GetTime(), 13, types[i], "Interface\\Icons\\INV_Misc_QuestionMark", 7)
                indicator[i].cooldown:SetScript("OnCooldownDone", function()
                    indicator[i]:SetCooldown(GetTime(), 13, types[i], "Interface\\Icons\\INV_Misc_QuestionMark", 7)
                end)
            end)
            indicator[i]:HookScript("OnHide", function()
                indicator[i].cooldown:Hide()
                indicator[i].cooldown:SetScript("OnCooldownDone", nil)
            end)
        end

    elseif indicatorName == "privateAuras" then
        indicator.isPrivateAuras = true

        indicator.mask = indicator:CreateMaskTexture()
        indicator.mask:SetTexture("interface/framegeneral/uiframeiconmask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        indicator.mask:SetAllPoints(indicator)

        indicator.icon = indicator:CreateTexture(nil, "ARTWORK")
        indicator.icon:SetAllPoints(indicator)
        indicator.icon:SetTexture(237555)
        indicator.icon:AddMaskTexture(indicator.mask)

        indicator.border = indicator:CreateTexture(nil, "BORDER")
        indicator.border:SetPoint("TOPLEFT", indicator.icon, -1, 0)
        indicator.border:SetPoint("BOTTOMRIGHT", indicator.icon, 1, 0)
        indicator.border:SetTexture([[Interface\Buttons\UI-Debuff-Overlays]])
        indicator.border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
        indicator.border:SetVertexColor(0.8, 0, 0)

        indicator.cooldown = CreateFrame("Cooldown", nil, indicator, "CooldownFrameTemplate")
        indicator.cooldown:SetAllPoints(indicator)
        indicator.cooldown:SetReverse(true)
        indicator.cooldown:SetDrawEdge(false)
        indicator.cooldown:SetDrawBling(false)

        local timer
        indicator:HookScript("OnShow", function()
            if timer then timer:Cancel() end
            indicator.cooldown:SetCooldown(GetTime(), 15)
            timer = C_Timer.NewTicker(15, function()
                indicator.cooldown:SetCooldown(GetTime(), 15)
            end)
        end)
        indicator:HookScript("OnHide", function()
            if timer then timer:Cancel() end
        end)

    elseif indicatorName == "targetedSpells" then
        indicator.isTargetedSpells = true
        indicator:SetScript("OnShow", function()
            indicator:SetCooldown(GetTime(), 3, "Interface\\Icons\\ability_warlock_chaosbolt", 7)
            indicator.cooldown:SetScript("OnCooldownDone", function()
                indicator:SetCooldown(GetTime(), 3, "Interface\\Icons\\ability_warlock_chaosbolt", 7)
            end)
        end)
        indicator:SetScript("OnHide", function()
            indicator.cooldown:Hide()
            indicator.cooldown:SetScript("OnCooldownDone", nil)
        end)

    elseif indicatorName == "targetCounter" then
        indicator:SetCount(3)

    elseif indicatorName == "crowdControls" then
        indicator.isCrowdControls = true
        local spells = {
            {"Magic", "Interface\\Icons\\spell_nature_polymorph"},
            {"Magic", "Interface\\Icons\\spell_shadow_psychicscream"},
            {"", "Interface\\Icons\\spell_nature_earthbind"},
        }
        for i = 1, 3 do
            indicator[i]:HookScript("OnShow", function()
                indicator[i]:SetCooldown(GetTime(), 13, spells[i][1], spells[i][2], 7)
                indicator[i].cooldown:SetScript("OnCooldownDone", function()
                    indicator[i]:SetCooldown(GetTime(), 13, spells[i][1], spells[i][2], 7)
                end)
            end)
            indicator[i]:HookScript("OnHide", function()
                indicator[i].cooldown:Hide()
                indicator[i].cooldown:SetScript("OnCooldownDone", nil)
            end)
        end

    elseif indicatorName == "externalCooldowns" then
        local icons = {135936, 135964, 135966, 237510, 237542}
        for i = 1, 5 do
            SetOnUpdate(indicator[i], nil, icons[i], 0)
        end
    elseif indicatorName == "defensiveCooldowns" then
        local icons = {135919, 136120, 135841, 132362, 132199}
        for i = 1, 5 do
            SetOnUpdate(indicator[i], nil, icons[i], 0)
        end
    elseif indicatorName == "allCooldowns" then
        local icons = {135936, 136120, 135966, 132362, 237542}
        for i = 1, 5 do
            SetOnUpdate(indicator[i], nil, icons[i], 0)
        end
    elseif indicatorName == "missingBuffs" then
        local buffs = I.GetDefaultMissingBuffs()
        for i = 1, 5 do
            indicator[i]:SetCooldown(0, 0, nil, buffs[i]["icon"], 0)
        end
    elseif string.find(indicatorName, "indicator") then
        if indicator.indicatorType == "icons" then
            for i = 1, 10 do
                SetOnUpdate(indicator[i], nil, 134400, i)
            end
        elseif indicator.indicatorType == "text" then
            indicator.isCustomText = true -- mark for custom glow
            SetOnUpdate(indicator, nil, 134400, 5)
            --! overwrite
            indicator:SetScript("OnShow", function()
                indicator:SetCooldown(GetTime(), 13, nil, 134400, 5)
                indicator.preview.elapsedTime = 0
                C_Timer.After(0.2, function()
                    indicator:SetWidth(indicator.text:GetStringWidth() + 6)
                end)
            end)
        elseif indicator.indicatorType == "color" then
            -- texture type cannot glow by LCG
            indicator.preview = indicator.preview or CreateFrame("Frame", nil, previewButton)
            indicator.preview:SetAllPoints(indicator)
            SetOnUpdate(indicator)
        elseif indicator.indicatorType == "texture" then
            function indicator:SetFadeOut(fadeOut)
                indicator.fadeOut = fadeOut
                indicator.preview.elapsedTime = 13 -- update now!
            end
            SetOnUpdate(indicator, nil, 134400, 0)
        elseif indicator.indicatorType == "glow" then
            function indicator:SetFadeOut(fadeOut)
                indicator.fadeOut = fadeOut
                indicator.preview.elapsedTime = 13 -- update now!
            end
            hooksecurefunc(indicator, "UpdateGlowOptions", function()
                indicator.preview.elapsedTime = 13 -- update now!
            end)
            SetOnUpdate(indicator, nil, 134400, 0)
        else
            SetOnUpdate(indicator, nil, 134400, 5)
        end
    end
    indicator.init = true
end

local function UpdateIndicators(layout, indicatorName, setting, value, value2)
    if not indicatorsTab:IsShown() then return end

    if not indicatorName then -- init
        if not layout then --! call from UpdateIndicators() not from Cell:Fire("UpdateIndicators", ...)
            I.RemoveAllCustomIndicators(previewButton)
            for _, t in pairs(currentLayoutTable["indicators"]) do
                local indicator = previewButton.indicators[t["indicatorName"]] or I.CreateIndicator(previewButton, t, true)
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
                    indicator:SetFrameLevel(indicator:GetParent():GetFrameLevel()+t["frameLevel"])
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
                    if t["indicatorName"] == "healthThresholds" then
                        indicator:UpdateThresholdsPreview()
                    end
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
                    if indicator.UpdateSize then indicator:UpdateSize(t["num"]) end
                end
                -- update format
                if t["format"] then
                    indicator:SetFormat(t["format"])
                    if t["indicatorName"] == "healthText" then
                        indicator:SetValue(21377, 65535, 16384)
                    elseif t["indicatorName"] == "powerText" then
                        indicator:SetValue(2048, 4096)
                    end
                end
                -- update numPerLine
                if t["numPerLine"] then
                    indicator:SetNumPerLine(t["numPerLine"])
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
                    if t["indicatorName"] == "nameText" or t["indicatorName"] == "healthText" or t["indicatorName"] == "powerText" then
                        indicator:UpdatePreviewColor(t["color"])
                    else
                        indicator:SetColor(unpack(t["color"]))
                    end
                end
                -- update colors
                if t["colors"] then
                    indicator:SetColors(t["colors"])
                end
                -- update groupNumber
                if type(t["showGroupNumber"]) == "boolean" then
                    indicator:ShowGroupNumber(t["showGroupNumber"])
                end
                -- update vehicleNamePosition
                if t["vehicleNamePosition"] then
                    indicator:UpdateVehicleNamePosition(t["vehicleNamePosition"])
                end
                -- update timer
                if type(t["showTimer"]) == "boolean" then
                    indicator:SetShowTimer(t["showTimer"])
                end
                -- update background
                if type(t["showBackground"]) == "boolean" then
                    indicator:ShowBackground(t["showBackground"])
                end
                -- update role texture
                if t["roleTexture"] then
                    indicator:SetRoleTexture(t["roleTexture"])
                    indicator:SetRole(indicator.roles[indicator.role])
                end
                -- update texture
                if t["texture"] then
                    indicator:SetTexture(t["texture"])
                end
                -- update duration
                if type(t["showDuration"]) == "boolean" or type(t["showDuration"]) == "number" then
                    indicator:ShowDuration(t["showDuration"])
                end
                -- update animation
                if type(t["showAnimation"]) == "boolean" then
                    indicator:ShowAnimation(t["showAnimation"])
                end
                -- update stack
                if type(t["showStack"]) == "boolean" then
                    indicator:ShowStack(t["showStack"])
                end
                -- update duration
                if t["duration"] then
                    indicator:SetDuration(t["duration"])
                end
                -- speed
                if t["speed"] then
                    indicator:SetSpeed(t["speed"])
                end
                 -- update circled nums
                 if type(t["circledStackNums"]) == "boolean" then
                    indicator:SetCircledStackNums(t["circledStackNums"])
                end
                -- update dispel highlight
                if t["highlightType"] then
                    indicator:UpdateHighlight(t["highlightType"])
                end
                -- update dispel icons
                if type(t["showDispelTypeIcons"]) == "boolean" then
                    indicator:ShowIcons(t["showDispelTypeIcons"])
                    indicator.init = false
                    InitIndicator(t["indicatorName"])
                end
                -- privateAuraOptions
                if t["privateAuraOptions"] then
                    indicator.cooldown:SetDrawSwipe(t["privateAuraOptions"][1])
                    indicator.cooldown:SetHideCountdownNumbers(not (t["privateAuraOptions"][1] and t["privateAuraOptions"][2]))
                end
                -- update glow
                if t["glowOptions"] then
                    indicator:UpdateGlowOptions(t["glowOptions"])
                end
                -- update fadeOut
                if type(t["fadeOut"]) == "boolean" then
                    indicator:SetFadeOut(t["fadeOut"])
                end
                -- update shape
                if t["shape"] then
                    indicator:SetShape(t["shape"])
                end
                -- update smooth
                if type(t["smooth"]) == "boolean" then
                    indicator:EnableSmooth(t["smooth"])
                end

                -- after init
                if t["enabled"] then
                    indicator.enabled = true
                    indicator:Show()
                    if indicator.preview then indicator.preview:Show() end
                else
                    indicator.enabled = false
                    indicator:Hide()
                    if indicator.preview then indicator.preview:Hide() end
                end
            end
            -- pixel perfect
            B:UpdatePixelPerfect(previewButton, true)
        end
    else
        local indicator = previewButton.indicators[indicatorName]
        -- changed in IndicatorsTab
        if setting == "enabled" then
            if value then
                indicator.enabled = true
                indicator:Show()
                if indicator.preview then indicator.preview:Show() end
                if indicator.isTargetedSpells then indicator:ShowGlowPreview() end
                if indicator.isDispels then
                    indicator.elapsed = 1
                    indicator.current = 1
                    indicator.isVisible = true
                end
            else
                indicator.enabled = false
                indicator:Hide()
                if indicator.preview then indicator.preview:Hide() end
                if indicator.isTargetedSpells then indicator:HideGlowPreview() end
            end
        elseif setting == "position" then
            P:ClearPoints(indicator)
            P:Point(indicator, value[1], previewButton, value[2], value[3], value[4])
            -- update arrangement
            if indicator.indicatorType == "icons" then
                indicator:SetOrientation(indicator.orientation)
            end
        elseif setting == "anchor" then
            indicator:SetAnchor(value)
        elseif setting == "frameLevel" then
            indicator:SetFrameLevel(indicator:GetParent():GetFrameLevel()+value)
        elseif setting == "size" then
            if indicatorName == "debuffs" then
                indicator:SetSize(value[1], value[2])
            else
                P:Size(indicator, value[1], value[2])
            end
            ListHighlightFn(selected) -- NOTE: update glow
        elseif setting == "size-border" then
            P:Size(indicator, value[1], value[2])
            indicator:SetBorder(value[3])
        elseif setting == "thickness" then
            indicator:SetThickness(value)
            if indicatorName == "healthThresholds" then
                indicator:UpdateThresholdsPreview()
            end
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
                if indicator.UpdateSize then indicator:UpdateSize(value) end
            end
        elseif setting == "numPerLine" then
            indicator:SetNumPerLine(value)
        elseif setting == "format" then
            indicator:SetFormat(value)
            if indicatorName == "healthText" then
                indicator:SetValue(21377, 65535, 16384)
            elseif indicatorName == "powerText" then
                indicator:SetValue(2048, 4096)
            end
        elseif setting == "orientation" then
            indicator:SetOrientation(value)
        elseif setting == "font" then
            indicator:SetFont(unpack(value))
            if indicator.isCustomText and indicator.enabled then
                indicator:Hide()
                indicator:Show()
            end
        elseif setting == "color" then
            if indicatorName == "nameText" or indicatorName == "healthText" or indicatorName == "powerText" then
                indicator:UpdatePreviewColor(value)
            else
                indicator:SetColor(unpack(value))
            end
        elseif setting == "colors" then
            indicator:SetColors(value)
            indicator.preview.elapsedTime = 13 -- update now!
        elseif setting == "vehicleNamePosition" then
            indicator:UpdateVehicleNamePosition(value)
        elseif setting == "statusColors" then
            if indicator.enabled then
                indicator:Hide()
                indicator:Show()
            end
        elseif setting == "roleTexture" then
            indicator:SetRoleTexture(value)
            indicator:SetRole(indicator.roles[indicator.role])
        elseif setting == "texture" then
            indicator:SetTexture(value)
        elseif setting == "duration" then
            -- indicator:SetDuration(value)
            if indicator.enabled then
                indicator:Hide()
                indicator:Show()
            end
        elseif setting == "highlightType" then
            indicator:UpdateHighlight(value)
            indicator.init = false
            InitIndicator(indicatorName)
        elseif setting == "thresholds" then
            indicator:UpdateThresholdsPreview()
        elseif setting == "showDuration" then
            indicator:ShowDuration(value)
            if indicator.enabled then
                -- update through OnShow
                indicator:Hide()
                indicator:Show()
            end
        elseif setting == "privateAuraOptions" then
            indicator.cooldown:SetDrawSwipe(value[1])
            indicator.cooldown:SetHideCountdownNumbers(not (value[1] and value[2]))
        elseif setting == "speed" then
            indicator:SetSpeed(value)
        elseif setting == "shape" then
            indicator:SetShape(value)
        elseif setting == "glowOptions" then
            indicator:UpdateGlowOptions(value)
            indicator:SetCooldown(GetTime(), 13)
        elseif setting == "checkbutton" then
            if value == "showGroupNumber" then
                indicator:ShowGroupNumber(value2)
            elseif value == "showTimer" then
                indicator:SetShowTimer(value2)
                indicator:Hide()
                indicator:Show()
            elseif value == "showBackground" then
                indicator:ShowBackground(value2)
            elseif value == "showAnimation" then
                indicator:ShowAnimation(value2)
                if indicator.enabled then
                    -- update through OnShow
                    indicator:Hide()
                    indicator:Show()
                end
            elseif value == "showStack" then
                indicator:ShowStack(value2)
            elseif value == "circledStackNums" then
                indicator:SetCircledStackNums(value2)
                if indicator.enabled then
                    -- update through OnShow
                    indicator:Hide()
                    indicator:Show()
                end
            elseif value == "showDispelTypeIcons" then
                indicator:ShowIcons(value2)
                indicator.init = false
                InitIndicator(indicatorName)
            elseif value == "fadeOut" then
                indicator:SetFadeOut(value2)
                -- indicator:SetCooldown(GetTime(), 13)
            elseif value == "smooth" then
                indicator:EnableSmooth(value2)
            end
        elseif setting == "create" then
            indicator = I.CreateIndicator(previewButton, value, true)
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
                indicator:SetFrameLevel(indicator:GetParent():GetFrameLevel()+value["frameLevel"])
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
                if indicator.UpdateSize then indicator:UpdateSize(value["num"]) end
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
            if type(value["showDuration"]) ~= "nil" then
                indicator:ShowDuration(value["showDuration"])
            end
            -- update animation
            if type(value["showAnimation"]) == "boolean" then
                indicator:ShowAnimation(value["showAnimation"])
            end
            -- update stack
            if type(value["showStack"]) == "boolean" then
                indicator:ShowStack(value["showStack"])
            end
            -- update duration
            if value["duration"] then
                indicator:SetDuration(value["duration"])
            end
            -- update circled nums
            if type(value["circledStackNums"]) == "boolean" then
                indicator:SetCircledStackNums(value["circledStackNums"])
            end
            -- update fadeOut
            if type(value["fadeOut"]) == "boolean" then
                indicator:SetFadeOut(value["fadeOut"])
            end
            -- update glow
            if value["glowOptions"] then
                indicator:UpdateGlowOptions(value["glowOptions"])
            end
            InitIndicator(indicatorName)
            indicator:Show()
            indicator.enabled = true
        elseif setting == "remove" then
            if indicator.preview then
                indicator.preview:SetParent(nil)
                indicator.preview:Hide()
                indicator.preview = nil
            end
            I.RemoveIndicator(previewButton, indicatorName, value)
        end
    end
end
Cell:RegisterCallback("UpdateIndicators", "PreviewButton_UpdateIndicators", UpdateIndicators)

-------------------------------------------------
-- layout
-------------------------------------------------
local layoutDropdown, LoadLayoutDropdown, LoadSyncDropdown

local function CreateLayoutPane()
    local layoutPane = Cell:CreateTitledPane(indicatorsTab, L["Layout"], 136, 50)
    layoutPane:SetPoint("TOPLEFT", indicatorsTab, "TOPLEFT", 5, -5)

    layoutDropdown = Cell:CreateDropdown(layoutPane, 136)
    layoutDropdown:SetPoint("TOPLEFT", 0, -25)
end


LoadLayoutDropdown = function()
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

                LoadSyncDropdown()
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
-- indicator sync
-------------------------------------------------
local syncDropdown, syncStatus
local masters, slaves = {}, {}

local function ColorName(layout)
    if layout == currentLayout then
        if layout == "default" then
            return "|cffff0066".._G.DEFAULT.."|r"
        else
            return "|cffff0066"..layout.."|r"
        end
    end

    if layout == "default" then
        return _G.DEFAULT
    end

    return layout
end

local function UpdateSyncedLayouts()
    --! CLEAR SYNC
    for slave, master in pairs(slaves) do
        if CellDB["layouts"][slave] then -- not deleted
            CellDB["layouts"][slave]["indicators"] = F:Copy(CellDB["layouts"][slave]["indicators"])
        end
    end

    wipe(masters)
    wipe(slaves)

    for layout, t in pairs(CellDB["layouts"]) do
        local master = t["syncWith"]
        if master then
            if CellDB["layouts"][master] then -- master exists
                if not masters[master] then masters[master] = {} end
                masters[master][layout] = true
                slaves[layout] = master
            else -- master missing
                t["syncWith"] = nil
            end
        end
    end

    --! SYNC NOW
    for slave, master in pairs(slaves) do
        CellDB["layouts"][slave]["indicators"] = CellDB["layouts"][master]["indicators"]
    end

    -- update syncStatus
    if F:Getn(masters) == 0 then
        syncStatus:Hide()
    else
        local text = ""
        -- check synced
        for master, t in pairs(masters) do
            text = text..ColorName(master).."\n"
            for slave in pairs(t) do
                text = text.."  - "..ColorName(slave).."\n"
            end
        end
        -- text = text.."\n"
        -- check non-synced
        for layout in pairs(CellDB["layouts"]) do
            if not masters[layout] and not slaves[layout] then
                text = text..ColorName(layout).."\n"
            end
        end

        syncStatus:SetText(text)
        syncStatus:Show()
    end
end

function F:GetNotifiedLayoutName(layout)
    -- if currentlyEnabled is a slave
    local masterOfCurrentlyEnabled = slaves[Cell.vars.currentLayout]
    if masterOfCurrentlyEnabled then
        -- if layout is currentlyEnabled's master or they share a same master
        if layout == masterOfCurrentlyEnabled or slaves[layout] == masterOfCurrentlyEnabled then
            return Cell.vars.currentLayout
        end
    end

    -- if currentlyEnabled is a master
    local slaves = masters[Cell.vars.currentLayout]
    if slaves then
        -- if layout is a slave of currentlyEnabled
        if slaves[layout] then
            return Cell.vars.currentLayout
        end
    end

    return layout
end

LoadSyncDropdown = function()
    UpdateSyncedLayouts()

    if masters[currentLayout] then
        -- NOTE: a master layout can not sync with others
        syncDropdown:SetItems({
            {
                ["text"] = L["None"],
                ["value"] = "none",
            }
        })
        syncDropdown:SetSelectedValue("none")
        syncDropdown:SetEnabled(false)
    else
        -- check
        local indices = {}
        for layout, _ in pairs(CellDB["layouts"]) do
            -- NOTE: not current, not default, not slave
            if layout ~= currentLayout and layout ~= "default" and not slaves[layout] then
                tinsert(indices, layout)
            end
        end
        table.sort(indices)

        -- NOTE: if current is not default, and default is not a slave
        if currentLayout ~= "default" and not slaves["default"] then
            tinsert(indices, 1, "default")
        end

        -- make items
        local items = {}
        for _, layout in ipairs(indices) do
            tinsert(items, {
                ["text"] = layout == "default" and _G.DEFAULT or layout,
                ["value"] = layout,
                ["onClick"] = function()
                    local popup = Cell:CreateConfirmPopup(indicatorsTab, 200, L["All indicators of %s will be replaced with those in %s"]:format("|cffff0066"..(currentLayout == "default" and _G.DEFAULT or currentLayout).."|r", "|cffff0066"..(layout == "default" and _G.DEFAULT or layout).."|r"), function(self)
                        currentLayoutTable["syncWith"] = layout
                        -- currentLayoutTable = CellDB["layouts"][currentLayout]
                        UpdateSyncedLayouts()
                        --! notify unitbuttons to update current indicators
                        Cell:Fire("UpdateIndicators", currentLayout)
                        --! update indicators preview
                        UpdateIndicators()
                        LoadIndicatorList()
                        listButtons[1]:Click()
                    end, function()
                        syncDropdown:SetSelectedValue("none")
                    end, true)
                    popup:SetPoint("TOPLEFT", 117, -117)
                end
            })
        end

        -- add "none"
        tinsert(items, 1, {
            ["text"] = L["None"],
            ["value"] = "none",
            ["onClick"] = function()
                currentLayoutTable["syncWith"] = nil
                -- currentLayoutTable = CellDB["layouts"][currentLayout]
                UpdateSyncedLayouts()
                --! notify unitbuttons to update current indicators
                Cell:Fire("UpdateIndicators", currentLayout)
                --! update indicators preview
                UpdateIndicators()
                LoadIndicatorList()
                listButtons[1]:Click()
            end
        })

        syncDropdown:SetItems(items)
        syncDropdown:SetSelectedValue(currentLayoutTable["syncWith"] or "none")
        syncDropdown:SetEnabled(true)
    end
end

local function CreateSyncPane()
    local syncPane = Cell:CreateTitledPane(indicatorsTab, L["Sync With"], 136, 50)
    syncPane:SetPoint("TOPLEFT", 5, -60)

    -- tip
    syncTip = Cell:CreateButton(syncPane, nil, "accent-hover", {17, 17}, nil, nil, nil, nil, nil, L["Indicator Sync"], L["syncTips"])
    syncTip:SetPoint("TOPRIGHT")
    syncTip.tex = syncTip:CreateTexture(nil, "ARTWORK")
    syncTip.tex:SetAllPoints(syncTip)
    syncTip.tex:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\info2.tga")

    -- sync
    syncDropdown = Cell:CreateDropdown(syncPane, 136)
    syncDropdown:SetPoint("TOPLEFT", 0, -25)

    -- sync status
    syncStatus = CreateFrame("Frame", "CellIndicatorsSyncStatus", indicatorsTab, "BackdropTemplate")
    Cell:StylizeFrame(syncStatus, nil, Cell:GetAccentColorTable())
    syncStatus:SetSize(150, 30)
    syncStatus:SetPoint("TOPRIGHT", syncPane, "TOPLEFT", -10, 3)

    syncStatus.title = syncStatus:CreateFontString(nil, "OVERLAY", "CELL_FONT_CLASS_TITLE")
    syncStatus.title:SetText(L["Sync Status"])
    syncStatus.title:SetPoint("BOTTOMLEFT", syncStatus, "TOPLEFT", 5, -18)

    syncStatus.text = syncStatus:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    syncStatus.text:SetPoint("TOPLEFT", syncStatus.title, "BOTTOMLEFT", 5, -5)
    syncStatus.text:SetJustifyH("LEFT")
    syncStatus.text:SetSpacing(3)

    function syncStatus:SetText(text)
        syncStatus.text:SetText(text)

        syncStatus:SetScript("OnUpdate", function()
            syncStatus:SetWidth(math.max(syncStatus.title:GetStringWidth(), syncStatus.text:GetStringWidth()) + 10)
            syncStatus:SetHeight(syncStatus.title:GetStringHeight() + syncStatus.text:GetStringHeight() + 15)
            syncStatus:SetScript("OnUpdate", nil)
        end)
    end
end

-------------------------------------------------
-- indicator list
-------------------------------------------------
local listFrame, renameBtn, deleteBtn

local typeItems = {
    {
        ["text"] = L["Icons"],
        ["value"] = "icons",
    },
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
        ["text"] = L["Color"],
        ["value"] = "color",
    },
    {
        ["text"] = L["Texture"],
        ["value"] = "texture",
    },
    {
        ["text"] = L["Glow"],
        ["value"] = "glow",
    },
    {
        ["text"] = L["Overlay"],
        ["value"] = "overlay",
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

local function CreateListPane()
    local listPane = Cell:CreateTitledPane(indicatorsTab, L["Indicators"], 136, 392)
    listPane:SetPoint("TOPLEFT", 5, -115)

    listFrame = Cell:CreateFrame("IndicatorsTab_ListFrame", listPane)
    listFrame:SetPoint("TOPLEFT", 0, -25)
    listFrame:SetPoint("BOTTOMRIGHT", 0, 43)
    listFrame:Show()

    Cell:CreateScrollFrame(listFrame)
    listFrame.scrollFrame:SetScrollStep(19)

    -- buttons
    local createBtn = Cell:CreateButton(listPane, nil, "green-hover", {46, 20}, nil, nil, nil, nil, nil, L["Create"])
    createBtn:SetPoint("TOPLEFT", listFrame, "BOTTOMLEFT", 0, -4)
    createBtn:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\create", {16, 16}, {"CENTER", 0, 0})
    createBtn:SetScript("OnClick", function()
        local popup = Cell:CreateConfirmPopup(indicatorsTab, 200, L["Create new indicator"], function(self)
            local name = strtrim(self.editBox:GetText())
            local indicatorName
            local indicatorType, indicatorAuraType = self.dropdown1:GetSelected(), self.dropdown2:GetSelected()

            local last = #currentLayoutTable["indicators"]
            if currentLayoutTable["indicators"][last]["type"] == "built-in" then
                indicatorName = "indicator1"
            else
                indicatorName = "indicator"..(tonumber(strmatch(currentLayoutTable["indicators"][last]["indicatorName"], "%d+"))+1)
            end

            tinsert(currentLayoutTable["indicators"], I.GetDefaultCustomIndicatorTable(name, indicatorName, indicatorType, indicatorAuraType))

            Cell:Fire("UpdateIndicators", F:GetNotifiedLayoutName(currentLayout), indicatorName, "create", currentLayoutTable["indicators"][last+1])
            LoadIndicatorList()
            listButtons[last+1]:Click()
            -- check scroll
            if last+1 > 15 then
                listFrame.scrollFrame:ScrollToBottom()
            end

        end, nil, true, true, 2)
        popup:SetPoint("TOPLEFT", 117, -187)
        popup.dropdown1:SetItems(typeItems)
        popup.dropdown1:SetSelectedItem(1)
        -- popup.dropdown1:SetEnabled(false)
        popup.dropdown2:SetItems(auraTypeItems)
        popup.dropdown2:SetSelectedItem(1)
    end)
    Cell:RegisterForCloseDropdown(createBtn)

    renameBtn = Cell:CreateButton(listPane, nil, "blue-hover", {46, 20}, nil, nil, nil, nil, nil, L["Rename"])
    renameBtn:SetPoint("TOPLEFT", createBtn, "TOPRIGHT", P:Scale(-1), 0)
    renameBtn:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\rename", {16, 16}, {"CENTER", 0, 0})
    renameBtn:SetEnabled(false)
    renameBtn:SetScript("OnClick", function()
        local name = currentLayoutTable["indicators"][selected]["name"]
        local popup = Cell:CreateConfirmPopup(indicatorsTab, 200, L["Rename indicator"].."\n"..name, function(self)
            local newName = strtrim(self.editBox:GetText())
            currentLayoutTable["indicators"][selected]["name"] = newName
            listButtons[selected]:SetText(newName)
        end, nil, true, true)
        popup:SetPoint("TOPLEFT", 117, -187)
    end)
    Cell:RegisterForCloseDropdown(renameBtn)

    deleteBtn = Cell:CreateButton(listPane, nil, "red-hover", {46, 20}, nil, nil, nil, nil, nil, L["Delete"])
    deleteBtn:SetPoint("TOPLEFT", renameBtn, "TOPRIGHT", P:Scale(-1), 0)
    deleteBtn:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\trash", {16, 16}, {"CENTER", 0, 0})
    deleteBtn:SetEnabled(false)
    deleteBtn:SetScript("OnClick", function()
        local name = currentLayoutTable["indicators"][selected]["name"]
        local indicatorName = currentLayoutTable["indicators"][selected]["indicatorName"]
        local auraType = currentLayoutTable["indicators"][selected]["auraType"]

        local popup = Cell:CreateConfirmPopup(indicatorsTab, 200, L["Delete indicator"].."?\n"..name, function(self)
            Cell:Fire("UpdateIndicators", F:GetNotifiedLayoutName(currentLayout), indicatorName, "remove", auraType)
            tremove(currentLayoutTable["indicators"], selected)
            LoadIndicatorList()
            listButtons[1]:Click()
        end, nil, true)
        popup:SetPoint("TOPLEFT", 117, -187)
    end)
    Cell:RegisterForCloseDropdown(deleteBtn)

    local importBtn = Cell:CreateButton(listPane, nil, "accent-hover", {46, 20}, nil, nil, nil, nil, nil, L["Import"], L["Custom indicators will not be overwritten, even with same name"])
    importBtn:SetPoint("TOPLEFT", createBtn, "BOTTOMLEFT", 0, P:Scale(1))
    importBtn:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\import", {16, 16}, {"TOPLEFT", 14, -2})
    importBtn:SetScript("OnClick", function()
        F:ShowIndicatorsImportFrame(currentLayout)
    end)
    Cell:RegisterForCloseDropdown(importBtn)

    local exportBtn = Cell:CreateButton(listPane, nil, "accent-hover", {46, 20}, nil, nil, nil, nil, nil, L["Export"])
    exportBtn:SetPoint("TOPLEFT", importBtn, "TOPRIGHT", P:Scale(-1), 0)
    exportBtn:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\export", {16, 16}, {"TOPLEFT", 14, -2})
    exportBtn:SetScript("OnClick", function()
        F:ShowIndicatorsExportFrame(currentLayout)
    end)
    Cell:RegisterForCloseDropdown(exportBtn)

    local copyBtn = Cell:CreateButton(listPane, nil, "accent-hover", {46, 20}, nil, nil, nil, nil, nil, L["Copy"], L["Copy indicators from one layout to another"], L["Custom indicators will not be overwritten, even with same name"])
    copyBtn:SetPoint("TOPLEFT", exportBtn, "TOPRIGHT", P:Scale(-1), 0)
    copyBtn:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\copy", {16, 16}, {"TOPLEFT", 14, -2})
    copyBtn:SetScript("OnClick", function()
        F:ShowIndicatorsCopyFrame()
    end)
    Cell:RegisterForCloseDropdown(copyBtn)
end

-------------------------------------------------
-- indicator settings
-------------------------------------------------
local settingsFrame

local function CreateSettingsPane()
    local settingsPane = Cell:CreateTitledPane(indicatorsTab, L["Indicator Settings"], 274, 502)
    settingsPane:SetPoint("TOPLEFT", 153, P:Scale(-5))

    -- settings frame
    settingsFrame = Cell:CreateFrame("IndicatorsTab_SettingsFrame", settingsPane, 10, 10, true)
    settingsFrame:SetPoint("TOPLEFT", 0, P:Scale(-25))
    settingsFrame:SetPoint("BOTTOMRIGHT")
    settingsFrame:Show()

    Cell:CreateScrollFrame(settingsFrame)
    settingsFrame.scrollFrame:SetScrollStep(50)
end

local indicatorSettings
local DEBUFFS_TOOLTIP1 = L["This will make these icons not click-through-able"].."|"..L["Tooltips need to be enabled in General tab"]
local DEBUFFS_TOOLTIP2 = L["This will make these icons not click-through-able"]
if Cell.isRetail then
    indicatorSettings = {
        ["nameText"] = {"enabled", "color-class", "textWidth", "checkbutton:showGroupNumber", "vehicleNamePosition", "namePosition", "frameLevel", "font-noOffset"},
        ["statusText"] = {"enabled", "checkbutton:showTimer", "checkbutton2:showBackground", "statusColors", "statusPosition", "frameLevel", "font-noOffset"},
        ["healthText"] = {"enabled", "color-class", "healthFormat", "checkbutton:hideIfEmptyOrFull", "position", "frameLevel", "font-noOffset"},
        ["powerText"] = {"enabled", "color-power", "powerFormat", "checkbutton:hideIfEmptyOrFull", "position", "frameLevel", "font-noOffset"},
        ["statusIcon"] = {
            -- "|A:dungeonskull:18:18|a "..
            "|TInterface\\LFGFrame\\LFG-Eye:18:18:0:0:512:256:72:120:72:120|t "..
            "|TInterface\\RaidFrame\\Raid-Icon-Rez:18:18|t "..
            "|TInterface\\TargetingFrame\\UI-PhasingIcon:18:18:0:0:31:31:3:28:3:28|t "..
            "|A:nameplates-icon-flag-horde:18:18|a "..
            "|A:nameplates-icon-flag-alliance:18:18|a "..
            "|A:nameplates-icon-orb-blue:18:18|a "..
            "|A:nameplates-icon-orb-green:18:18|a "..
            "|A:nameplates-icon-orb-orange:18:18|a "..
            "|A:nameplates-icon-orb-purple:18:18|a ", "enabled", "size-square", "position", "frameLevel"},
        ["roleIcon"] = {"enabled", "checkbutton:hideDamager", "size-square", "roleTexture", "position", "frameLevel"},
        ["leaderIcon"] = {"enabled", "checkbutton:hideInCombat", "size-square", "position"},
        ["readyCheckIcon"] = {"size-square", "frameLevel"},
        ["playerRaidIcon"] = {"enabled", "size-square", "alpha", "position", "frameLevel"},
        ["targetRaidIcon"] = {"enabled", "size-square", "alpha", "position", "frameLevel"},
        ["aggroBlink"] = {"enabled", "size", "position", "frameLevel"},
        ["aggroBorder"] = {"enabled", "thickness", "frameLevel"},
        ["aggroBar"] = {"enabled", "size-bar", "position", "frameLevel"},
        ["shieldBar"] = {"enabled", "checkbutton:onlyShowOvershields", "color-alpha", "height", "shieldBarPosition", "frameLevel"},
        ["aoeHealing"] = {"enabled", "color", "height"},
        ["externalCooldowns"] = {L["Even if disabled, the settings below affect \"Externals + Defensives\" indicator"], "enabled", "builtInExternals", "customExternals", "durationVisibility", "checkbutton:showAnimation", "size", "num:5", "orientation", "position", "frameLevel", "font1:stackFont", "font2:durationFont"},
        ["defensiveCooldowns"] = {L["Even if disabled, the settings below affect \"Externals + Defensives\" indicator"], "enabled", "builtInDefensives", "customDefensives", "durationVisibility", "checkbutton:showAnimation", "size", "num:5", "orientation", "position", "frameLevel", "font1:stackFont", "font2:durationFont"},
        ["allCooldowns"] = {"enabled", "durationVisibility", "checkbutton:showAnimation", "size", "num:5", "orientation", "position", "frameLevel", "font1:stackFont", "font2:durationFont"},
        ["tankActiveMitigation"] = {"|cffb7b7b7"..I.GetTankActiveMitigationString(), "enabled", "color-class", "size-bar", "position", "frameLevel"},
        ["dispels"] = {"enabled", "checkbutton:dispellableByMe", "highlightType", "dispelBlacklist", "checkbutton2:showDispelTypeIcons", "orientation", "size-square", "position", "frameLevel"},
        ["debuffs"] = {"enabled", "checkbutton:dispellableByMe", "debuffBlacklist", "bigDebuffs", "durationVisibility", "checkbutton2:showAnimation", "checkbutton3:showTooltip:"..DEBUFFS_TOOLTIP1, "checkbutton4:enableBlacklistShortcut:"..DEBUFFS_TOOLTIP2, "size-normal-big", "num:10", "orientation", "position", "frameLevel", "font1:stackFont", "font2:durationFont"},
        ["raidDebuffs"] = {"|cffb7b7b7"..L["You can config debuffs in %s"]:format(Cell:GetAccentColorString()..L["Raid Debuffs"].."|r"), "enabled", "checkbutton:onlyShowTopGlow", "durationVisibility", "checkbutton2:showTooltip:"..DEBUFFS_TOOLTIP1, "size-border", "num:3", "orientation", "position", "frameLevel", "font1:stackFont", "font2:durationFont"},
        ["privateAuras"] = {"|cffb7b7b7"..L["Due to restrictions of the private aura system, this indicator can only use Blizzard style."], "enabled", "privateAuraOptions", "size-square", "position", "frameLevel"},
        ["targetedSpells"] = {"enabled", "checkbutton:showAllSpells:"..L["Glow is only available to the spells in the list below"], "targetedSpellsList", "targetedSpellsGlow", "size-border", "position", "frameLevel", "font"},
        ["targetCounter"] = {"|cffff2727"..L["HIGH CPU USAGE"].."!|r |cffb7b7b7"..L["Check all visible enemy nameplates."], "enabled", "targetCounterFilters", "color", "position", "frameLevel", "font-noOffset"},
        ["crowdControls"] = {"enabled", "builtInCrowdControls", "customCrowdControls", "size-border", "num:3", "orientation", "position", "frameLevel", "font1:stackFont", "font2:durationFont"},
        ["consumables"] = {"enabled", "consumablesPreview", "consumablesList"},
        ["healthThresholds"] = {"enabled", "thresholds", "thickness"},
        ["missingBuffs"] = {I.GetMissingBuffsString().."|cffb7b7b7"..(L["%s in Utilities must be enabled to make this indicator work."]:format(Cell:GetAccentColorString()..L["Buff Tracker"].."|r")), "enabled", "missingBuffsFilters", "size-square", "num:5", "orientation", "position", "frameLevel"},
    }
elseif Cell.isCata then
    indicatorSettings = {
        ["nameText"] = {"enabled", "color-class", "textWidth", "checkbutton:showGroupNumber", "vehicleNamePosition", "namePosition", "frameLevel", "font-noOffset"},
        ["statusText"] = {"enabled", "checkbutton:showTimer", "checkbutton2:showBackground", "statusColors", "statusPosition", "frameLevel", "font-noOffset"},
        ["healthText"] = {"enabled", "color-class", "healthFormat", "checkbutton:hideIfEmptyOrFull", "position", "frameLevel", "font-noOffset"},
        ["powerText"] = {"enabled", "color-power", "powerFormat", "checkbutton:hideIfEmptyOrFull", "position", "frameLevel", "font-noOffset"},
        ["statusIcon"] = {
            -- "|A:dungeonskull:18:18|a "..
            "|TInterface\\LFGFrame\\LFG-Eye:18:18:0:0:512:256:72:120:72:120|t "..
            "|TInterface\\RaidFrame\\Raid-Icon-Rez:18:18|t "..
            "|TInterface\\TargetingFrame\\UI-PhasingIcon:18:18:0:0:31:31:3:28:3:28|t "..
            "|A:horde_icon_and_flag-dynamicIcon:18:18|a "..
            "|A:alliance_icon_and_flag-dynamicIcon:18:18|a ", "enabled", "size-square", "position", "frameLevel"},
        ["roleIcon"] = {"enabled", "checkbutton:hideDamager", "size-square", "roleTexture", "position", "frameLevel"},
        ["leaderIcon"] = {"enabled", "checkbutton:hideInCombat", "size-square", "position"},
        ["readyCheckIcon"] = {"size-square", "frameLevel"},
        ["playerRaidIcon"] = {"enabled", "size-square", "alpha", "position", "frameLevel"},
        ["targetRaidIcon"] = {"enabled", "size-square", "alpha", "position", "frameLevel"},
        ["aggroBlink"] = {"enabled", "size", "position", "frameLevel"},
        ["aggroBorder"] = {"enabled", "thickness", "frameLevel"},
        ["aggroBar"] = {"enabled", "size-bar", "position", "frameLevel"},
        ["shieldBar"] = {"enabled", "checkbutton:onlyShowOvershields", "color-alpha", "height", "shieldBarPosition", "frameLevel"},
        ["powerWordShield"] = {L["To show shield value, |cffff2727Glyph of Power Word: Shield|r is required"], "enabled", "checkbutton:shieldByMe", "shape", "size-square", "position", "frameLevel"},
        ["aoeHealing"] = {"enabled", "color", "height"},
        ["externalCooldowns"] = {L["Even if disabled, the settings below affect \"Externals + Defensives\" indicator"], "enabled", "builtInExternals", "customExternals", "durationVisibility", "checkbutton:showAnimation", "size", "num:5", "orientation", "position", "frameLevel", "font1:stackFont", "font2:durationFont"},
        ["defensiveCooldowns"] = {L["Even if disabled, the settings below affect \"Externals + Defensives\" indicator"], "enabled", "builtInDefensives", "customDefensives", "durationVisibility", "checkbutton:showAnimation", "size", "num:5", "orientation", "position", "frameLevel", "font1:stackFont", "font2:durationFont"},
        ["allCooldowns"] = {"enabled", "durationVisibility", "checkbutton:showAnimation", "size", "num:5", "orientation", "position", "frameLevel", "font1:stackFont", "font2:durationFont"},
        ["dispels"] = {"enabled", "checkbutton:dispellableByMe", "highlightType", "dispelBlacklist", "checkbutton2:showDispelTypeIcons", "orientation", "size-square", "position", "frameLevel"},
        ["debuffs"] = {"enabled", "checkbutton:dispellableByMe", "debuffBlacklist", "bigDebuffs", "durationVisibility", "checkbutton2:showAnimation", "checkbutton3:showTooltip:"..DEBUFFS_TOOLTIP1, "checkbutton4:enableBlacklistShortcut:"..DEBUFFS_TOOLTIP2, "size-normal-big", "num:10", "orientation", "position", "frameLevel", "font1:stackFont", "font2:durationFont"},
        ["raidDebuffs"] = {"|cffb7b7b7"..L["You can config debuffs in %s"]:format(Cell:GetAccentColorString()..L["Raid Debuffs"].."|r"), "enabled", "checkbutton:onlyShowTopGlow", "durationVisibility", "checkbutton2:showTooltip:"..DEBUFFS_TOOLTIP1, "size-border", "num:3", "orientation", "position", "frameLevel", "font1:stackFont", "font2:durationFont"},
        ["targetedSpells"] = {"enabled", "checkbutton:showAllSpells:"..L["Glow is only available to the spells in the list below"], "targetedSpellsList", "targetedSpellsGlow", "size-border", "position", "frameLevel", "font"},
        ["targetCounter"] = {"|cffff2727"..L["HIGH CPU USAGE"].."!|r |cffb7b7b7"..L["Check all visible enemy nameplates."], "enabled", "targetCounterFilters", "color", "position", "frameLevel", "font-noOffset"},
        ["consumables"] = {"enabled", "consumablesPreview", "consumablesList"},
        ["healthThresholds"] = {"enabled", "thresholds", "thickness"},
        ["missingBuffs"] = {"|cffb7b7b7"..(L["%s in Utilities must be enabled to make this indicator work."]:format(Cell:GetAccentColorString()..L["Buff Tracker"].."|r")).." "..(L["If you are a paladin or warrior, and the unit has no buffs from you, a %s icon will be displayed."]:format("|T254882:14:14:0:0:14:14:1:13:1:13|t")), "enabled", "missingBuffsFilters", "size-square", "num:5", "orientation", "position", "frameLevel"},
    }
elseif Cell.isVanilla then
    indicatorSettings = {
        ["nameText"] = {"enabled", "color-class", "textWidth", "checkbutton:showGroupNumber", "vehicleNamePosition", "namePosition", "frameLevel", "font-noOffset"},
        ["statusText"] = {"enabled", "checkbutton:showTimer", "checkbutton2:showBackground", "statusColors", "statusPosition", "frameLevel", "font-noOffset"},
        ["healthText"] = {"enabled", "color-class", "healthFormat", "checkbutton:hideIfEmptyOrFull", "position", "frameLevel", "font-noOffset"},
        ["powerText"] = {"enabled", "color-power", "powerFormat", "checkbutton:hideIfEmptyOrFull", "position", "frameLevel", "font-noOffset"},
        ["statusIcon"] = {
            -- "|A:dungeonskull:18:18|a "..
            "|TInterface\\LFGFrame\\LFG-Eye:18:18:0:0:512:256:72:120:72:120|t "..
            "|TInterface\\RaidFrame\\Raid-Icon-Rez:18:18|t "..
            "|TInterface\\TargetingFrame\\UI-PhasingIcon:18:18:0:0:31:31:3:28:3:28|t "..
            "|A:horde_icon_and_flag-dynamicIcon:18:18|a "..
            "|A:alliance_icon_and_flag-dynamicIcon:18:18|a ", "enabled", "size-square", "position", "frameLevel"},
        ["partyAssignmentIcon"] = {"enabled", "size-square", "position"},
        ["leaderIcon"] = {"enabled", "checkbutton:hideInCombat", "size-square", "position"},
        ["readyCheckIcon"] = {"size-square", "frameLevel"},
        ["playerRaidIcon"] = {"enabled", "size-square", "alpha", "position", "frameLevel"},
        ["targetRaidIcon"] = {"enabled", "size-square", "alpha", "position", "frameLevel"},
        ["aggroBlink"] = {"enabled", "size", "position", "frameLevel"},
        ["aggroBorder"] = {"enabled", "thickness", "frameLevel"},
        ["aggroBar"] = {"enabled", "size-bar", "position", "frameLevel"},
        ["aoeHealing"] = {"enabled", "color", "height"},
        ["externalCooldowns"] = {L["Even if disabled, the settings below affect \"Externals + Defensives\" indicator"], "enabled", "builtInExternals", "customExternals", "durationVisibility", "checkbutton:showAnimation", "size", "num:5", "orientation", "position", "frameLevel", "font1:stackFont", "font2:durationFont"},
        ["defensiveCooldowns"] = {L["Even if disabled, the settings below affect \"Externals + Defensives\" indicator"], "enabled", "builtInDefensives", "customDefensives", "durationVisibility", "checkbutton:showAnimation", "size", "num:5", "orientation", "position", "frameLevel", "font1:stackFont", "font2:durationFont"},
        ["allCooldowns"] = {"enabled", "durationVisibility", "checkbutton:showAnimation", "size", "num:5", "orientation", "position", "frameLevel", "font1:stackFont", "font2:durationFont"},
        ["dispels"] = {"enabled", "checkbutton:dispellableByMe", "highlightType", "dispelBlacklist", "checkbutton2:showDispelTypeIcons", "orientation", "size-square", "position", "frameLevel"},
        ["debuffs"] = {"enabled", "checkbutton:dispellableByMe", "debuffBlacklist", "bigDebuffs", "durationVisibility", "checkbutton2:showAnimation", "checkbutton3:showTooltip:"..DEBUFFS_TOOLTIP1, "checkbutton4:enableBlacklistShortcut:"..DEBUFFS_TOOLTIP2, "size-normal-big", "num:10", "orientation", "position", "frameLevel", "font1:stackFont", "font2:durationFont"},
        ["raidDebuffs"] = {"|cffb7b7b7"..L["You can config debuffs in %s"]:format(Cell:GetAccentColorString()..L["Raid Debuffs"].."|r"), "enabled", "checkbutton:onlyShowTopGlow", "durationVisibility", "checkbutton2:showTooltip:"..DEBUFFS_TOOLTIP1, "size-border", "num:3", "orientation", "position", "frameLevel", "font1:stackFont", "font2:durationFont"},
        ["targetedSpells"] = {"enabled", "checkbutton:showAllSpells:"..L["Glow is only available to the spells in the list below"], "targetedSpellsList", "targetedSpellsGlow", "size-border", "position", "frameLevel", "font"},
        ["targetCounter"] = {"|cffff2727"..L["HIGH CPU USAGE"].."!|r |cffb7b7b7"..L["Check all visible enemy nameplates."], "enabled", "targetCounterFilters", "color", "position", "frameLevel", "font-noOffset"},
        ["consumables"] = {"enabled", "consumablesPreview", "consumablesList"},
        ["healthThresholds"] = {"enabled", "thresholds", "thickness"},
        ["missingBuffs"] = {"|cffb7b7b7"..(L["%s in Utilities must be enabled to make this indicator work."]:format(Cell:GetAccentColorString()..L["Buff Tracker"].."|r")).." "..(L["If you are a paladin or warrior, and the unit has no buffs from you, a %s icon will be displayed."]:format("|T254882:14:14:0:0:14:14:1:13:1:13|t")), "enabled", "missingBuffsFilters", "size-square", "num:5", "orientation", "position", "frameLevel"},
    }
end

local function ShowIndicatorSettings(id)
    -- if selected == id then return end

    settingsFrame.scrollFrame:ResetScroll()
    settingsFrame.scrollFrame:ResetHeight()

    local notifiedLayout = F:GetNotifiedLayoutName(currentLayout)
    local indicatorTable = currentLayoutTable["indicators"][id]
    local indicatorName = indicatorTable["indicatorName"]
    local indicatorType = indicatorTable["type"]
    -- texplore(indicatorTable)

    local settingsTable
    if indicatorType == "built-in" then
        settingsTable = indicatorSettings[indicatorName]
        -- if indicatorName == "tankActiveMitigation" then
        --     tinsert(settingsTable, 1, "|cffb7b7b7"..L["Tank Active Mitigation refers to a single, specific ability that a Tank must use as a counter to specific Boss abilities. These Boss abilities are designated as Mitigation Checks."])
        -- end
    else
        if indicatorType == "icon" then
            settingsTable = {"enabled", "auras", "checkbutton3:showStack", "durationVisibility", "checkbutton4:showAnimation", CELL_RECTANGULAR_CUSTOM_INDICATOR_ICONS and "size" or "size-square", "position", "frameLevel", "font1:stackFont", "font2:durationFont"}
        elseif indicatorType == "text" then
            settingsTable = {"enabled", "auras", "duration", "checkbutton3:circledStackNums:"..L["Require font support"], "colors", "position", "frameLevel", "font-noOffset"}
        elseif indicatorType == "bar" then
            settingsTable = {"enabled", "auras", "colors", "checkbutton3:showStack", "barOrientation", "size-bar", "position", "frameLevel", "font"}
        elseif indicatorType == "rect" then
            settingsTable = {"enabled", "auras", "colors", "checkbutton3:showStack", "size", "position", "frameLevel", "font"}
        elseif indicatorType == "icons" then
            settingsTable = {"enabled", "auras", "checkbutton3:showStack", "durationVisibility", "checkbutton4:showAnimation", CELL_RECTANGULAR_CUSTOM_INDICATOR_ICONS and "size" or "size-square", "num:10", "numPerLine:10", "orientation", "position", "frameLevel", "font1:stackFont", "font2:durationFont"}
        elseif indicatorType == "color" then
            settingsTable = {"enabled", "auras", "customColors", "anchor", "frameLevel"}
        elseif indicatorType == "texture" then
            settingsTable = {"enabled", "checkbutton3:fadeOut", "auras", "texture", "size", "position", "frameLevel"}
        elseif indicatorType == "glow" then
            settingsTable = {"enabled", "checkbutton3:fadeOut", "auras", "glowOptions", "frameLevel"}
        elseif indicatorType == "overlay" then
            settingsTable = {"enabled", "auras", "overlayColors", "checkbutton3:smooth", "barOrientation", "frameLevel"}
        end

        if indicatorTable["auraType"] == "buff" then
            tinsert(settingsTable, 2, "castBy")
            tinsert(settingsTable, 3, "checkbutton2:trackByName")
            -- tinsert(settingsTable, 4, "showOn")
        end

        -- tips
        if indicatorType == "icons" or indicatorType == "glow" then
            tinsert(settingsTable, 1, "|cffb7b7b7"..L["The spells list of a icons indicator is unordered (no priority)."].." "..L["Indicator settings are part of Layout settings which are account-wide."])
        else
            tinsert(settingsTable, 1, "|cffb7b7b7"..L["The priority of spells decreases from top to bottom."].." "..L["Indicator settings are part of Layout settings which are account-wide."])
        end
    end

    local widgets = Cell:CreateIndicatorSettings(settingsFrame.scrollFrame.content, settingsTable)

    local last
    for i, w in pairs(widgets) do
        if last then
            w:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, P:Scale(-10))
        else
            w:SetPoint("TOPLEFT")
        end
        w:SetPoint("RIGHT")
        last = w

        local currentSetting = settingsTable[i]

        --! convert currentSetting to ACTUAL TABLE INDEX
        if currentSetting == "color-alpha" or currentSetting == "color-class" or currentSetting == "color-power" then currentSetting = "color" end
        if currentSetting == "customColors" or currentSetting == "overlayColors" then currentSetting = "colors" end
        if currentSetting == "size-square" or currentSetting == "size-bar" or currentSetting == "size-normal-big" then currentSetting = "size" end
        if currentSetting == "namePosition" or currentSetting == "statusPosition" or currentSetting == "position-noHCenter" or currentSetting == "shieldBarPosition" then currentSetting = "position" end
        if currentSetting == "barOrientation" then currentSetting = "orientation" end
        if currentSetting == "durationVisibility" then currentSetting = "showDuration" end
        if currentSetting == "healthFormat" or currentSetting == "powerFormat" then currentSetting = "format" end

        -- enabled
        if currentSetting == "enabled" then
            w:SetDBValue(indicatorTable[currentSetting])
            w:SetFunc(function(value)
                indicatorTable[currentSetting] = value
                Cell:Fire("UpdateIndicators", notifiedLayout, indicatorName, currentSetting, value)
                -- show enabled/disabled status
                if value then
                    listButtons[id]:SetTextColor(1, 1, 1, 1)
                else
                    listButtons[id]:SetTextColor(0.466, 0.466, 0.466, 1)
                end
                if listButtons[id].typeIcon then
                    listButtons[id].typeIcon:SetAlpha(value and 0.55 or 0.15)
                end
            end)

        -- checkbutton
        elseif string.find(currentSetting, "^checkbutton") then
            local _, setting, tooltip = string.split(":", currentSetting)
            w:SetDBValue(setting, indicatorTable[setting], tooltip)
            w:SetFunc(function(value)
                indicatorTable[setting] = value
                Cell:Fire("UpdateIndicators", notifiedLayout, indicatorName, "checkbutton", setting, value) -- indicatorName, setting, value, value2
            end)

        -- font
        elseif currentSetting == "font" or currentSetting == "font-noOffset" then
            w:SetDBValue(indicatorTable["font"])
            w:SetFunc(function()
                -- NOTE: values already changed in widget
                Cell:Fire("UpdateIndicators", notifiedLayout, indicatorName, "font", indicatorTable["font"])
            end)

        -- font1, font2
        elseif string.find(currentSetting, "^font%d") then
            local index, setting = strmatch(currentSetting, "^font(%d):(.+)")
            index = tonumber(index)
            w:SetDBValue(indicatorTable["font"][index], setting)
            w:SetFunc(function()
                -- NOTE: values already changed in widget
                Cell:Fire("UpdateIndicators", notifiedLayout, indicatorName, "font", indicatorTable["font"])
            end)

        -- auras
        elseif currentSetting == "auras" then
            w:SetDBValue(L[F:UpperFirst(indicatorTable["auraType"]).." List"], indicatorTable["auras"], indicatorType == "glow", indicatorType == "icons")
            w:SetFunc(function(value)
                -- NOTE: already changed in widget
                Cell:Fire("UpdateIndicators", notifiedLayout, indicatorName, "auras", indicatorTable["auraType"], value)
            end)

        -- debuffBlacklist
        elseif currentSetting == "debuffBlacklist" then
            w:SetDBValue(L["Debuff Filter (blacklist)"], CellDB["debuffBlacklist"], true)
            w:SetFunc(function(value)
                CellDB["debuffBlacklist"] = value
                Cell.vars.debuffBlacklist = F:ConvertTable(CellDB["debuffBlacklist"])
                Cell:Fire("UpdateIndicators", notifiedLayout, "", "debuffBlacklist")
            end)

        -- dispelBlacklist
        elseif currentSetting == "dispelBlacklist" then
            w:SetDBValue(L["Highlight Filter (blacklist)"], CellDB["dispelBlacklist"], true)
            w:SetFunc(function(value)
                CellDB["dispelBlacklist"] = value
                Cell.vars.dispelBlacklist = F:ConvertTable(CellDB["dispelBlacklist"])
                Cell:Fire("UpdateIndicators", notifiedLayout, "", "dispelBlacklist")
            end)

        -- builtInDefensives
        elseif currentSetting == "builtInDefensives" then
            w:SetDBValue(I.GetDefensives(), CellDB["defensives"]["disabled"])
            w:SetFunc(function()
                I.UpdateDefensives(CellDB["defensives"])
                Cell:Fire("UpdateIndicators", notifiedLayout, "", "defensives")
            end)

        -- customDefensives
        elseif currentSetting == "customDefensives" then
            w:SetDBValue(_G.CUSTOM, CellDB["defensives"]["custom"], true)
            w:SetFunc(function(value)
                CellDB["defensives"]["custom"] = value
                I.UpdateDefensives(CellDB["defensives"])
                Cell:Fire("UpdateIndicators", notifiedLayout, "", "defensives")
            end)

        -- builtInExternals
        elseif currentSetting == "builtInExternals" then
            w:SetDBValue(I.GetExternals(), CellDB["externals"]["disabled"])
            w:SetFunc(function()
                I.UpdateExternals(CellDB["externals"])
                Cell:Fire("UpdateIndicators", notifiedLayout, "", "externals")
            end)

        -- customExternals
        elseif currentSetting == "customExternals" then
            w:SetDBValue(_G.CUSTOM, CellDB["externals"]["custom"], true)
            w:SetFunc(function(value)
                CellDB["externals"]["custom"] = value
                I.UpdateExternals(CellDB["externals"])
                Cell:Fire("UpdateIndicators", notifiedLayout, "", "externals")
            end)

        -- builtInCrowdControls
        elseif currentSetting == "builtInCrowdControls" then
            w:SetDBValue(I.GetCrowdControls(), CellDB["crowdControls"]["disabled"])
            w:SetFunc(function()
                I.UpdateCrowdControls(CellDB["crowdControls"])
                Cell:Fire("UpdateIndicators", notifiedLayout, "", "crowdControls")
            end)

        -- customCrowdControls
        elseif currentSetting == "customCrowdControls" then
            w:SetDBValue(_G.CUSTOM, CellDB["crowdControls"]["custom"], true)
            w:SetFunc(function(value)
                CellDB["crowdControls"]["custom"] = value
                I.UpdateCrowdControls(CellDB["crowdControls"])
                Cell:Fire("UpdateIndicators", notifiedLayout, "", "crowdControls")
            end)

        -- cleuAuras
        -- elseif currentSetting == "cleuAuras" then
        --     w:SetDBValue(CellDB["cleuAuras"])
        --     w:SetFunc(function(value)
        --         CellDB["cleuAuras"] = value
        --         I.UpdateCleuAuras(value)
        --     end)

        -- bigDebuffs
        elseif currentSetting == "bigDebuffs" then
            w:SetDBValue(L["Big Debuffs"], CellDB["bigDebuffs"], true)
            w:SetFunc(function(value)
                CellDB["bigDebuffs"] = value
                Cell.vars.bigDebuffs = F:ConvertTable(CellDB["bigDebuffs"])
                Cell:Fire("UpdateIndicators", notifiedLayout, "", "bigDebuffs")
            end)

        -- consumablesPreview
        elseif currentSetting == "consumablesPreview" then
            w:SetDBValue(indicatorTable["speed"])
            w:SetFunc(function(value)
                indicatorTable["speed"] = value
                Cell:Fire("UpdateIndicators", notifiedLayout, indicatorName, "speed", value)
            end)

        -- consumablesList
        elseif currentSetting == "consumablesList" then
            w:SetDBValue(CellDB["consumables"])
            w:SetFunc(function(value)
                CellDB["consumables"] = value
                Cell.vars.consumables = I.ConvertConsumables(value)
            end)

        -- targetedSpellsList
        elseif currentSetting == "targetedSpellsList" then
            w:SetDBValue(L["Spell List"], CellDB["targetedSpellsList"], true)
            w:SetFunc(function(value)
                CellDB["targetedSpellsList"] = value
                Cell.vars.targetedSpellsList = F:ConvertTable(CellDB["targetedSpellsList"])
            end)

        -- targetedSpellsGlow
        elseif currentSetting == "targetedSpellsGlow" then
            w:SetDBValue(CellDB["targetedSpellsGlow"])
            w:SetFunc(function(value)
                CellDB["targetedSpellsGlow"] = value
                Cell.vars.targetedSpellsGlow = CellDB["targetedSpellsGlow"]
                CellIndicatorsPreviewButton.indicators.targetedSpells:ShowGlowPreview()
            end)

        -- glowOptions
        elseif currentSetting == "glowOptions" then
            w:SetDBValue(indicatorTable["glowOptions"], true)
            w:SetFunc(function(value)
                Cell:Fire("UpdateIndicators", notifiedLayout, indicatorName, currentSetting, value)
            end)

        -- size-border
        elseif currentSetting == "size-border" then
            w:SetDBValue(indicatorTable["size"], indicatorTable["border"])
            w:SetFunc(function(value)
                indicatorTable["size"][1] = value[1]
                indicatorTable["size"][2] = value[2]
                indicatorTable["border"] = value[3]
                Cell:Fire("UpdateIndicators", notifiedLayout, indicatorName, currentSetting, value)
            end)

        -- colors
        elseif currentSetting == "colors" then
            w:SetDBValue(indicatorTable["colors"], indicatorTable["auraType"])
            w:SetFunc(function(value)
                -- NOTE: already changed in widget
                Cell:Fire("UpdateIndicators", notifiedLayout, indicatorName, "colors", value)
            end)

        -- statusColors
        elseif currentSetting == "statusColors" then
            w:SetDBValue(indicatorTable["colors"])
            w:SetFunc(function()
                Cell:Fire("UpdateIndicators", notifiedLayout, indicatorName, "statusColors")
            end)

        -- num:X
        elseif string.find(currentSetting, "^num:") then
            w:SetDBValue(indicatorTable["num"], tonumber(select(2,string.split(":", currentSetting))))
            w:SetFunc(function(value)
                indicatorTable["num"] = value
                Cell:Fire("UpdateIndicators", notifiedLayout, indicatorName, "num", value)
            end)

        -- numPerLine:X
        elseif string.find(currentSetting, "^numPerLine:") then
            w:SetDBValue(indicatorTable["numPerLine"], tonumber(select(2,string.split(":", currentSetting))))
            w:SetFunc(function(value)
                indicatorTable["numPerLine"] = value
                Cell:Fire("UpdateIndicators", notifiedLayout, indicatorName, "numPerLine", value)
            end)

        -- missingBuffsFilters
        elseif currentSetting == "missingBuffsFilters" then
            w:SetDBValue(indicatorTable["filters"])
            w:SetFunc(function()
                -- NOTE: already changed in widget
                Cell:Fire("UpdateIndicators", notifiedLayout, indicatorName, "missingBuffsFilters")
            end)

        -- targetCounterFilters
        elseif currentSetting == "targetCounterFilters" then
            w:SetDBValue(indicatorTable["filters"])
            w:SetFunc(function()
                -- NOTE: already changed in widget
                Cell:Fire("UpdateIndicators", notifiedLayout, indicatorName, "targetCounterFilters")
            end)

        -- common
        else
            w:SetDBValue(indicatorTable[currentSetting])
            w:SetFunc(function(value)
                indicatorTable[currentSetting] = value
                Cell:Fire("UpdateIndicators", notifiedLayout, indicatorName, currentSetting, value)
            end)
        end
    end

    Cell:UpdateIndicatorSettingsHeight()

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
    F:Debug("|cffff7777LoadIndicatorList:|r", currentLayout)
    listFrame.scrollFrame:Reset()
    wipe(listButtons)

    local last
    for i, t in pairs(currentLayoutTable["indicators"]) do
        local b
        if t["type"] == "built-in" then
            b = Cell:CreateButton(listFrame.scrollFrame.content, L[t["name"]], "transparent-accent", {20, 20})
        else
            b = Cell:CreateButton(listFrame.scrollFrame.content, t["name"], "transparent-accent", {20, 20})
            -- b = Cell:CreateButton(listFrame.scrollFrame.content, t["name"].." |cff7f7f7f("..L[t["auraType"]]..")", "transparent-accent", {20, 20})
            b.typeIcon = b:CreateTexture(nil, "ARTWORK")
            b.typeIcon:SetPoint("RIGHT", -2, 0)
            P:Size(b.typeIcon, 16, 16)
            b.typeIcon:SetTexture("Interface\\AddOns\\Cell\\Media\\Indicators\\indicator-"..t["type"])
            -- b.typeIcon:SetAlpha(0.5)
            if t["auraType"] == "buff" then
                b.typeIcon:SetVertexColor(0.75, 1, 0.75)
            else -- debuff
                b.typeIcon:SetVertexColor(1, 0.75, 0.75)
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
            b:SetTextColor(0.466, 0.466, 0.466, 1)
        end
        if b.typeIcon then
            b.typeIcon:SetAlpha(t["enabled"] and 0.55 or 0.15)
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
            b:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, P:Scale(1))
        else
            b:SetPoint("TOPLEFT")
        end
        last = b
    end
    listFrame.scrollFrame:SetContentHeight(P:Scale(20), #listButtons, -P:Scale(1))

    ListHighlightFn = Cell:CreateButtonGroup(listButtons, ShowIndicatorSettings, function(id)
        local i = previewButton.indicators[currentLayoutTable["indicators"][id]["indicatorName"]]
        if i.indicatorType == "glow" then
            i:Show()
            return
        end

        if i:IsObjectType("Texture") or i:IsObjectType("FontString") then
            LCG.PixelGlow_Start(i.preview)
            i:SetAlpha(i.alpha or 1)
        else
            if i.isRaidDebuffs or i.isPrivateAuras or i.isCrowdControls then
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
                if i.isDispels and i.enabled then
                    i.isVisible = true
                    i.highlight:Show()
                end
            end
        end
    end, function(id)
        local i = previewButton.indicators[currentLayoutTable["indicators"][id]["indicatorName"]]
        if i.indicatorType == "glow" then
            i:Hide()
            return
        end

        if i:IsObjectType("Texture") or i:IsObjectType("FontString") then
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
            if i.isDispels then
                i.isVisible = false
                i.highlight:Hide()
            end
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
            CreatePreviewButton()
            CreateLayoutPane()
            CreateSyncPane()
            CreateListPane()
            CreateSettingsPane()
            -- texplore(masters)
            previewAlphaSlider:SetValue(CellDB["indicatorPreviewAlpha"])
            previewScaleSlider:SetValue(CellDB["indicatorPreviewScale"])
            previewButton:SetScale(CellDB["indicatorPreviewScale"])
        end

        LoadLayoutDropdown()
        indicatorsTab:Show()

        local noUpdateIndicators = currentLayout == Cell.vars.currentLayout
        currentLayout = Cell.vars.currentLayout
        currentLayoutTable = Cell.vars.currentLayoutTable
        LoadSyncDropdown()
        if noUpdateIndicators then return end

        UpdatePreviewButton()
        UpdateIndicators()

        layoutDropdown:SetSelected(currentLayout == "default" and _G.DEFAULT or currentLayout)
        LoadIndicatorList()
        listButtons[1]:Click()
        -- texplore(previewButton)
    else
        indicatorsTab:Hide()
    end
end
Cell:RegisterCallback("ShowOptionsTab", "IndicatorsTab_ShowTab", ShowTab)

function F:ReloadIndicatorList()
    if not init then return end
    if indicatorsTab:IsShown() then
        LoadIndicatorList()
        listFrame.scrollFrame:ScrollToBottom()
        listButtons[#listButtons]:Click()
    else
        indicatorsTab:SetScript("OnShow", function()
            indicatorsTab:SetScript("OnShow", nil)
            UpdateIndicators()
            LoadIndicatorList()
            listButtons[1]:Click()
        end)
    end
end

function F:ReloadIndicatorOptions(index)
    if not init then return end
    if selected == index then
        listButtons[index]:Click()
    end
end


local function UpdateLayout()
    if previewButton and currentLayout == Cell.vars.currentLayout then
        UpdatePreviewButton()
    end
end
Cell:RegisterCallback("UpdateLayout", "IndicatorsTab_UpdateLayout", UpdateLayout)

local function UpdateAppearance()
    if previewButton and currentLayout == Cell.vars.currentLayout then
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