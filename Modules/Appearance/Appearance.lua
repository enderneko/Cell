---@class Cell
local Cell = select(2, ...)
local L = Cell.L
local F = Cell.funcs
local B = Cell.bFuncs
local I = Cell.iFuncs
---@type AbstractFramework
local AF = _G.AbstractFramework

local LoadData, LoadButtonStyle, LoadDebuffTypeColor

local appearanceTab = CreateFrame("Frame", "CellOptionsFrame_AppearanceTab", CellOptionsFrame)
appearanceTab:SetAllPoints(CellOptionsFrame)
appearanceTab:Hide()

---------------------------------------------------------------------
-- cell
---------------------------------------------------------------------
local scaleSlider, strataDropdown, accentColorDropdown, accentColorPicker

local function GetRecommendedScale()
    local pScale = AF.GetPixelFactor()
    local mult
    if pScale >= 0.71 then -- 1080
        mult = 1
    elseif pScale >= 0.53 then -- 1440
        mult = 1.2
    else -- 2160
        mult = 1.7
    end
    return AF.Clamp(AF.Round(pScale / UIParent:GetScale() * mult, 2), 0.5, 2)
end

local function CreateCellPane()
    local cellPane = AF.CreateTitledPane(appearanceTab, "Cell", nil, 120)
    AF.SetPoint(cellPane, "TOPLEFT", appearanceTab, 7, -7)
    AF.SetPoint(cellPane, "TOPRIGHT", appearanceTab, -7, -7)

    -- global scale
    scaleSlider = AF.CreateSlider(cellPane, L["Scale"], 150, 0.5, 2, 0.01, nil, true)
    AF.SetPoint(scaleSlider, "TOPLEFT", cellPane, "TOPLEFT", 5, -40)
    scaleSlider:SetAfterValueChanged(function(value)
        CellDB["appearance"]["scale"] = value
        Cell.Fire("UpdateAppearance", "scale")
        Cell.Fire("UpdatePixelPerfect")

        local dialog = AF.GetDialog(appearanceTab, L["A UI reload is required.\nDo it now?"])
        AF.SetPoint(dialog, "TOP", appearanceTab, 0, -70)
        dialog:SetOnConfirm(ReloadUI)
    end)
    AF.RegisterForCloseDropdown(scaleSlider)

    -- recommended scale
    local recScaleBtn = AF.CreateButton(cellPane, nil, "accent_hover", 17, 17)
    AF.SetPoint(recScaleBtn, "BOTTOMRIGHT", scaleSlider, "TOPRIGHT", 0, 2)
    recScaleBtn:SetTexture(AF.GetIcon("resize", "Cell"), {15, 15}, {"CENTER", 0, 0})
    recScaleBtn:SetTooltip(L["Apply Recommended Scale"])
    recScaleBtn:SetScript("OnClick", function()
        local scale = GetRecommendedScale()
        scaleSlider:SetValue(scale)
        scaleSlider.afterValueChanged(scale)
    end)

    -- options ui font size
    -- optionsFontSizeOffset = AF.CreateSlider(cellPane, L["Options UI Font Size"], 150, -5, 5, 1, nil, true)
    -- AF.SetPoint(optionsFontSizeOffset, "TOPLEFT", 222, -40)

    -- optionsFontSizeOffset:SetAfterValueChanged(function(value)
    --     CellDB["appearance"]["optionsFontSizeOffset"] = value
    --     Cell.UpdateOptionsFont(value, CellDB["appearance"]["useGameFont"])
    --     Cell.UpdateAboutFont(value)
    -- end)

    -- raid frame strata
    strataDropdown = AF.CreateDropdown(cellPane, 150)
    AF.SetPoint(strataDropdown, "TOPLEFT", 229, -40)
    strataDropdown:SetLabel(L["Strata"])
    strataDropdown:SetItems({
        {
            ["text"] = "LOW",
            ["onClick"] = function()
                CellDB["appearance"]["strata"] = "LOW"
                Cell.Fire("UpdateAppearance", "strata")
            end,
        },
        {
            ["text"] = "MEDIUM",
            ["onClick"] = function()
                CellDB["appearance"]["strata"] = "MEDIUM"
                Cell.Fire("UpdateAppearance", "strata")
            end,
        },
        {
            ["text"] = "HIGH",
            ["onClick"] = function()
                CellDB["appearance"]["strata"] = "HIGH"
                Cell.Fire("UpdateAppearance", "strata")
            end,
        },
    })

    -- accent color
    accentColorDropdown = AF.CreateDropdown(cellPane, 150)
    AF.SetPoint(accentColorDropdown, "TOPLEFT", scaleSlider, 0, -50)
    accentColorDropdown:SetLabel(L["Options UI Accent Color"])
    accentColorDropdown:SetItems({
        {
            ["text"] = L["Class Color"],
            ["value"] = "class_color",
            ["onClick"] = function()
                if CellDB["appearance"]["accentColor"][1] ~= "class_color" then
                    local dialog = AF.GetDialog(appearanceTab, L["A UI reload is required.\nDo it now?"])
                    AF.SetPoint(dialog, "TOP", appearanceTab, 0, -77)
                    dialog:SetOnConfirm(ReloadUI)
                end
                CellDB["appearance"]["accentColor"][1] = "class_color"
                accentColorPicker:SetEnabled(false)
            end
        },
        {
            ["text"] = L["Custom Color"],
            ["value"] = "custom",
            ["onClick"] = function()
                if CellDB["appearance"]["accentColor"][1] ~= "custom" then
                    local dialog = AF.GetDialog(appearanceTab, L["A UI reload is required.\nDo it now?"])
                    AF.SetPoint(dialog, "TOP", appearanceTab, 0, -77)
                    dialog:SetOnConfirm(ReloadUI)
                end
                CellDB["appearance"]["accentColor"][1] = "custom"
                accentColorPicker:SetEnabled(true)
            end
        },
    })

    accentColorPicker = AF.CreateColorPicker(cellPane, nil, false, nil, function(r, g, b)
        if CellDB["appearance"]["accentColor"][2][1] ~= r or CellDB["appearance"]["accentColor"][2][2] ~= g or CellDB["appearance"]["accentColor"][2][3] ~= b then
            local dialog = AF.GetDialog(appearanceTab, L["A UI reload is required.\nDo it now?"])
            AF.SetPoint(dialog, "TOP", appearanceTab, 0, -77)
            dialog:SetOnConfirm(ReloadUI)
        end

        CellDB["appearance"]["accentColor"][2][1] = r
        CellDB["appearance"]["accentColor"][2][2] = g
        CellDB["appearance"]["accentColor"][2][3] = b
    end)
    AF.SetPoint(accentColorPicker, "LEFT", accentColorDropdown, "RIGHT", 5, 0)
    AF.RegisterForCloseDropdown(accentColorPicker)

    -- use game font
    -- useGameFontCB = AF.CreateCheckButton(cellPane, "Use Game Font", function(checked)
    --     CellDB["appearance"]["useGameFont"] = checked
    --     Cell.UpdateOptionsFont(CellDB["appearance"]["optionsFontSizeOffset"], checked)
    -- end)
    -- AF.SetPoint(useGameFontCB, "TOPLEFT", strataDropdown, 0, -32)
    -- if Cell.isAsian then
    --     useGameFontCB:Hide()
    -- end
end

---------------------------------------------------------------------
-- preview icons
---------------------------------------------------------------------
local previewIconsBG, borderIcon1, borderIcon2, barIcon1, barIcon2

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

-- local function SetOnUpdate_Refresh(indicator, type, icon, stack)
--     indicator.preview = indicator.preview or CreateFrame("Frame", nil, indicator)
--     indicator.preview:SetScript("OnUpdate", function(self, elapsed)
--         self.elapsedTime = (self.elapsedTime or 0) + elapsed
--         if self.elapsedTime >= 5 then
--             self.elapsedTime = 0
--             indicator:SetCooldown(GetTime(), 13, type, icon, stack, true)
--         end
--     end)
--     indicator:SetScript("OnShow", function()
--         indicator.preview.elapsedTime = 0
--         indicator:SetCooldown(GetTime(), 13, type, icon, stack)
--     end)
-- end

--[=[ update font
local function UpdatePreviewIcons(layout, indicatorName, setting, value, value2)
    if not indicatorName or indicatorName == "raidDebuffs" then
        borderIcon1:SetFont(unpack(Cell.vars.currentLayoutTable.indicators[Cell.defaults.indicatorIndices["raidDebuffs"]].font))
        borderIcon2:SetFont(unpack(Cell.vars.currentLayoutTable.indicators[Cell.defaults.indicatorIndices["raidDebuffs"]].font))
    end
    if not indicatorName or indicatorName == "debuffs" then
        barIcon1:SetFont(unpack(Cell.vars.currentLayoutTable.indicators[Cell.defaults.indicatorIndices["debuffs"]].font))
        barIcon2:SetFont(unpack(Cell.vars.currentLayoutTable.indicators[Cell.defaults.indicatorIndices["debuffs"]].font))
    end
end]=]

local previewIconsFont = {
    {"Cell", 11, "Outline", false, "TOPRIGHT", 2, 1},
    {"Cell", 11, "Outline", false, "BOTTOMRIGHT", 2, -1},
}

local function CreatePreviewIcons()
    previewIconsBG = CreateFrame("Frame", "CellAppearancePreviewIconsBG", appearanceTab)
    AF.SetSize(previewIconsBG, 95, 45)
    AF.SetPoint(previewIconsBG, "TOPLEFT", appearanceTab, "TOPRIGHT", 5, -160)
    AF.ApplyDefaultBackdrop_NoBorder(previewIconsBG)
    previewIconsBG:SetBackdropColor(AF.GetColorRGB("background", 0.75))
    previewIconsBG:Show()

    local previewText = previewIconsBG:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET_TITLE")
    AF.SetPoint(previewText, "TOP", 0, -3)
    previewText:SetText(AF.GetColorStr("Cell") .. L["Preview"] .. " 1")

    borderIcon1 = I.CreateAura_BorderIcon("CellAppearancePreviewIcon1", previewIconsBG, 2)
    borderIcon1:SetFont(unpack(previewIconsFont))
    AF.SetSize(borderIcon1, 22, 22)
    AF.SetPoint(borderIcon1, "BOTTOMLEFT")
    SetOnUpdate(borderIcon1, "Magic", 135819, 0)
    borderIcon1:Show()

    borderIcon2 = I.CreateAura_BorderIcon("CellAppearancePreviewIcon2", previewIconsBG, 2)
    borderIcon2:SetFont(unpack(previewIconsFont))
    AF.SetSize(borderIcon2, 22, 22)
    AF.SetPoint(borderIcon2, "BOTTOMLEFT", borderIcon1, "BOTTOMRIGHT", 1, 0)
    borderIcon2.preview = CreateFrame("Frame", nil, borderIcon2)
    borderIcon2.preview:SetScript("OnUpdate", function(self, elapsed)
        self.elapsedTime = (self.elapsedTime or 0) + elapsed
        if self.elapsedTime >= 6 then
            self.elapsedTime = 0
            self.stack = self.stack + 1
            borderIcon2:SetCooldown(GetTime(), 13, "", 135718, self.stack, Cell.vars.iconAnimation ~= "never")
        end
    end)
    borderIcon2:SetScript("OnShow", function()
        borderIcon2.preview.stack = 1
        borderIcon2.preview.elapsedTime = 0
        borderIcon2:SetCooldown(GetTime(), 13, "", 135718, 1)
    end)
    borderIcon2:Show()

    barIcon2 = I.CreateAura_BarIcon("CellAppearancePreviewIcon4", previewIconsBG)
    barIcon2:SetFont(unpack(previewIconsFont))
    AF.SetSize(barIcon2, 22, 22)
    AF.SetPoint(barIcon2, "BOTTOMRIGHT")
    barIcon2.preview = CreateFrame("Frame", nil, barIcon2)
    barIcon2.preview:SetScript("OnUpdate", function(self, elapsed)
        self.elapsedTime = (self.elapsedTime or 0) + elapsed
        if self.elapsedTime >= 6 then
            self.elapsedTime = 0
            barIcon2:SetCooldown(GetTime(), 13, nil, 136085, 0, Cell.vars.iconAnimation == "duration")
        end
    end)
    barIcon2:SetScript("OnShow", function()
        barIcon2.preview.elapsedTime = 0
        barIcon2:SetCooldown(GetTime(), 13, nil, 136085, 0)
    end)
    barIcon2:ShowAnimation(true)
    barIcon2:Show()

    barIcon1 = I.CreateAura_BarIcon("CellAppearancePreviewIcon3", previewIconsBG)
    barIcon1:SetFont(unpack(previewIconsFont))
    AF.SetSize(barIcon1, 22, 22)
    AF.SetPoint(barIcon1, "BOTTOMRIGHT", barIcon2, "BOTTOMLEFT", -1, 0)
    barIcon1:ShowDuration(true)
    barIcon1:ShowAnimation(true)
    SetOnUpdate(barIcon1, "", 132155, 5)
    barIcon1:Show()

    -- display debuff type colors
    -- curse_border = I.CreateAura_BorderIcon("CellAppearancePreviewIconCurse1", previewIconsBG, 2)
    -- AF.SetSize(curse_border, 22 ,22)
    -- AF.SetPoint(curse_border, "TOPLEFT", borderIcon1, "BOTTOMLEFT", 0, -1)
    -- curse_border:SetCooldown(0, 0, "Curse", 136139, 0)
    -- curse_border:Show()

    -- disease_border = I.CreateAura_BorderIcon("CellAppearancePreviewIconDisease1", previewIconsBG, 2)
    -- AF.SetSize(disease_border, 22 ,22)
    -- AF.SetPoint(disease_border, "TOPLEFT", curse_border, "TOPRIGHT", 1, 0)
    -- disease_border:SetCooldown(0, 0, "Disease", 136128, 0)
    -- disease_border:Show()

    -- magic_border = I.CreateAura_BorderIcon("CellAppearancePreviewIconMagic1", previewIconsBG, 2)
    -- AF.SetSize(magic_border, 22 ,22)
    -- AF.SetPoint(magic_border, "TOPLEFT", disease_border, "TOPRIGHT", 1, 0)
    -- magic_border:SetCooldown(0, 0, "Magic", 240443, 0)
    -- magic_border:Show()

    -- poison_border = I.CreateAura_BorderIcon("CellAppearancePreviewIconPoison1", previewIconsBG, 2)
    -- AF.SetSize(poison_border, 22 ,22)
    -- AF.SetPoint(poison_border, "TOPLEFT", magic_border, "TOPRIGHT", 1, 0)
    -- poison_border:SetCooldown(0, 0, "Poison", 136182, 0)
    -- poison_border:Show()

    -- UpdatePreviewIcons()
end

---------------------------------------------------------------------
-- preview button
---------------------------------------------------------------------
local previewButton, previewButton2

local function CreatePreviewButtons()
    previewButton = CreateFrame("Button", "CellAppearancePreviewButton", appearanceTab, "CellPreviewButtonTemplate")
    B.UpdateBackdrop(previewButton)
    -- previewButton.type = "main" -- layout setup
    AF.SetPoint(previewButton, "TOPLEFT", previewIconsBG, "BOTTOMLEFT", 0, -50)
    previewButton:UnregisterAllEvents()
    previewButton:SetScript("OnEnter", nil)
    previewButton:SetScript("OnLeave", nil)
    previewButton:SetScript("OnUpdate", nil)
    previewButton:Show()

    previewButton.previewHealthText = previewButton.widgets.indicatorFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    previewButton.previewHealthText:SetPoint("CENTER")

    previewButton.widgets.healthBar:SetMinMaxSmoothedValue(0, 100)
    previewButton.widgets.healthBar:SetMinMaxValues(0, 100)

    previewButton.widgets.powerBar:SetMinMaxValues(0, 1)
    previewButton.widgets.powerBar:SetValue(1)

    local previewButtonBG = CreateFrame("Frame", "CellAppearancePreviewButtonBG", appearanceTab)
    AF.SetPoint(previewButtonBG, "TOPLEFT", previewButton, 0, 20)
    AF.SetPoint(previewButtonBG, "BOTTOMRIGHT", previewButton, "TOPRIGHT")
    AF.ApplyDefaultBackdrop_NoBorder(previewButtonBG)
    previewButtonBG:SetBackdropColor(AF.GetColorRGB("background", 0.75))
    previewButtonBG:Show()

    local previewText = previewButtonBG:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET_TITLE")
    AF.SetPoint(previewText, "TOP", 0, -3)
    previewText:SetText(AF.GetColorStr("Cell") .. L["Preview"] .. " 2")

    previewButton2 = CreateFrame("Button", "CellAppearancePreviewButton2", appearanceTab, "CellPreviewButtonTemplate")
    B.UpdateBackdrop(previewButton2)
    -- previewButton2.type = "main" -- layout setup
    AF.SetPoint(previewButton2, "TOPLEFT", previewButton, "BOTTOMLEFT", 0, -50)
    previewButton2:UnregisterAllEvents()
    previewButton2:SetScript("OnEnter", nil)
    previewButton2:SetScript("OnLeave", nil)
    previewButton2:SetScript("OnUpdate", nil)
    previewButton2:SetScript("OnShow", nil)
    previewButton2:SetScript("OnHide", nil)
    previewButton2:Show()

    previewButton2.widgets.healthBar:SetMinMaxValues(0, 100)
    previewButton2.widgets.healthBar:SetValue(60)
    previewButton2.states.healthMax = 100
    previewButton2.states.healthPercent = 0.6

    local previewButtonBG2 = CreateFrame("Frame", "CellAppearancePreviewButtonBG2", appearanceTab)
    AF.SetPoint(previewButtonBG2, "TOPLEFT", previewButton2, 0, 20)
    AF.SetPoint(previewButtonBG2, "BOTTOMRIGHT", previewButton2, "TOPRIGHT")
    AF.ApplyDefaultBackdrop_NoBorder(previewButtonBG2)
    previewButtonBG2:SetBackdropColor(AF.GetColorRGB("background", 0.75))
    previewButtonBG2:Show()

    local previewText2 = previewButtonBG2:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET_TITLE")
    AF.SetPoint(previewText2, "TOP", 0, -3)
    previewText2:SetText(AF.GetColorStr("Cell") .. L["Preview"] .. " 3")

    -- animation
    local states = {-20, -30, -40, 50, -60, 0, 100, 0}
    local ticker
    previewButton:SetScript("OnShow", function()
        previewButton.perc = 1
        previewButton.widgets.healthBar:SetValue(100)
        -- previewButton.widgets.healthBar:SetSmoothedValue(100)
        previewButton.previewHealthText:SetText("100%")

        local health, healthPercent, healthPercentOld, currentState = 100, 1, 1, 1

        ticker = C_Timer.NewTicker(1, function()
            health = health + states[currentState]
            healthPercent = health / 100
            previewButton.perc = healthPercent

            if CellDB["appearance"]["barAnimation"] == "Flash" then
                previewButton.widgets.healthBar:SetValue(health)

                local diff = healthPercent - (healthPercentOld or healthPercent)
                if diff >= 0 then
                    B.HideFlash(previewButton)
                    -- previewButton.widgets.damageFlashTex:Hide()
                elseif diff <= -0.05 and diff >= -1 then
                    B.ShowFlash(previewButton, abs(diff))
                    -- print(abs(diff))
                end
            elseif CellDB["appearance"]["barAnimation"] == "Smooth" then
                previewButton.widgets.healthBar:SetSmoothedValue(health)
            else
                previewButton.widgets.healthBar:SetValue(health)
            end

            -- update text
            if health == 0 then
                previewButton.previewHealthText:SetText(L["DEAD"])
            else
                previewButton.previewHealthText:SetText(health .. "%")
            end

            -- update color
            local r, g, b, lossR, lossG, lossB = F.GetHealthBarColor(healthPercent, health == 0, F.GetClassColor(Cell.vars.playerClass))
            previewButton.widgets.healthBar:SetStatusBarColor(r, g, b, CellDB["appearance"]["barAlpha"])
            previewButton.widgets.healthBarLoss:SetVertexColor(lossR, lossG, lossB, CellDB["appearance"]["lossAlpha"])

            healthPercentOld = healthPercent
            currentState = currentState == 8 and 1 or (currentState + 1)
        end)
    end)

    previewButton:SetScript("OnHide", function()
        previewButton.perc = 100
        ticker:Cancel()
        ticker = nil
    end)

    Cell.Fire("CreatePreview", previewButton, previewButton2)
end

local function UpdatePreviewShields(r, g, b)
    if CellDB["appearance"]["healPrediction"][1] then
        previewButton2.widgets.incomingHeal:SetValue(0.2, 0.6)
        if CellDB["appearance"]["healPrediction"][2] then
            previewButton2.widgets.incomingHeal:SetVertexColor(CellDB["appearance"]["healPrediction"][3][1], CellDB["appearance"]["healPrediction"][3][2], CellDB["appearance"]["healPrediction"][3][3], CellDB["appearance"]["healPrediction"][3][4])
        else
            previewButton2.widgets.incomingHeal:SetVertexColor(r, g, b, 0.4)
        end
    else
        previewButton2.widgets.incomingHeal:Hide()
    end

    if Cell.isRetail then
        if CellDB["appearance"]["healAbsorb"][1] then
            previewButton2.widgets.absorbsBar:SetValue(0.8, 0.6)
            if CellDB["appearance"]["healAbsorbInvertColor"] then
                previewButton2.widgets.absorbsBar:SetVertexColor(F.InvertColor(previewButton2.widgets.healthBar:GetStatusBarColor()))
                previewButton2.widgets.overAbsorbGlow:SetVertexColor(F.InvertColor(previewButton2.widgets.healthBar:GetStatusBarColor()))
            else
                previewButton2.widgets.absorbsBar:SetVertexColor(unpack(CellDB["appearance"]["healAbsorb"][2]))
                previewButton2.widgets.overAbsorbGlow:SetVertexColor(unpack(CellDB["appearance"]["healAbsorb"][2]))
            end
        else
            previewButton2.widgets.absorbsBar:Hide()
            previewButton2.widgets.overAbsorbGlow:Hide()
        end
    end

    if Cell.isRetail or Cell.isWrath or Cell.isCata then
        if CellDB["appearance"]["shield"][1] then
            previewButton2.widgets.shieldBar:SetValue(0.6, 0.6)
            previewButton2.widgets.shieldBar:SetVertexColor(unpack(CellDB["appearance"]["shield"][2]))
        else
            previewButton2.widgets.shieldBar:Hide()
        end

        local reverseFilling = CellDB["appearance"]["shield"][1] and CellDB["appearance"]["overshieldReverseFill"]

        if CellDB["appearance"]["overshield"][1] and not reverseFilling then
            previewButton2.widgets.overShieldGlow:SetVertexColor(unpack(CellDB["appearance"]["overshield"][2]))
            previewButton2.widgets.overShieldGlow:Show()
        else
            previewButton2.widgets.overShieldGlow:Hide()
        end

        if reverseFilling then
            previewButton2.widgets.shieldBarR:SetVertexColor(unpack(CellDB["appearance"]["shield"][2]))
            previewButton2.widgets.shieldBarR:Show()

            if CellDB["appearance"]["overshield"][1] then
                previewButton2.widgets.overShieldGlowR:SetVertexColor(unpack(CellDB["appearance"]["overshield"][2]))
                previewButton2.widgets.overShieldGlowR:Show()
            else
                previewButton2.widgets.overShieldGlowR:Hide()
            end
        else
            previewButton2.widgets.shieldBarR:Hide()
            previewButton2.widgets.overShieldGlowR:Hide()
        end
    end
end

local function UpdatePreviewButton(which)
    if not which or which == "texture" or which == "reset" then
        previewButton.widgets.healthBar:SetStatusBarTexture(Cell.vars.texture)
        previewButton.widgets.healthBarLoss:SetTexture(Cell.vars.texture)
        previewButton.widgets.powerBar:SetStatusBarTexture(Cell.vars.texture)
        previewButton.widgets.powerBarLoss:SetTexture(Cell.vars.texture)
        previewButton.widgets.incomingHeal:SetTexture(Cell.vars.texture)
        previewButton.widgets.damageFlashTex:SetTexture(Cell.vars.texture)

        previewButton2.widgets.healthBar:SetStatusBarTexture(Cell.vars.texture)
        previewButton2.widgets.healthBar:GetStatusBarTexture():SetDrawLayer("ARTWORK", -7) --! VERY IMPORTANT
        previewButton2.widgets.healthBarLoss:SetTexture(Cell.vars.texture)
        previewButton2.widgets.powerBar:SetStatusBarTexture(Cell.vars.texture)
        previewButton2.widgets.powerBar:GetStatusBarTexture():SetDrawLayer("ARTWORK", -7) --! VERY IMPORTANT
        previewButton2.widgets.powerBarLoss:SetTexture(Cell.vars.texture)
        previewButton2.widgets.incomingHeal:SetTexture(Cell.vars.texture)
        previewButton2.widgets.damageFlashTex:SetTexture(Cell.vars.texture)
    end

    if not which or which == "layout" then
        -- barOrientation
        B.SetOrientation(previewButton, Cell.vars.currentLayoutTable["barOrientation"][1], Cell.vars.currentLayoutTable["barOrientation"][2])
        B.SetOrientation(previewButton2, Cell.vars.currentLayoutTable["barOrientation"][1], Cell.vars.currentLayoutTable["barOrientation"][2])

        -- size
        AF.SetSize(previewButton, Cell.vars.currentLayoutTable["main"]["size"][1], Cell.vars.currentLayoutTable["main"]["size"][2])
        B.SetPowerSize(previewButton, Cell.vars.currentLayoutTable["main"]["powerSize"])
        AF.SetSize(previewButton2, Cell.vars.currentLayoutTable["main"]["size"][1], Cell.vars.currentLayoutTable["main"]["size"][2])
        B.SetPowerSize(previewButton2, Cell.vars.currentLayoutTable["main"]["powerSize"])
    end

    if not which or which == "color" or which == "alpha" or which == "shields" or which == "reset" then
        -- power color
        local r, g, b = F.GetPowerBarColor("player", Cell.vars.playerClass)
        previewButton.widgets.powerBar:SetStatusBarColor(r, g, b)
        previewButton2.widgets.powerBar:SetStatusBarColor(r, g, b)

        -- health color
        local lossR, lossG, lossB
        r, g, b, lossR, lossG, lossB = F.GetHealthBarColor(previewButton.perc or 1, previewButton.perc == 0, F.GetClassColor(Cell.vars.playerClass))
        previewButton.widgets.healthBar:SetStatusBarColor(r, g, b, CellDB["appearance"]["barAlpha"])
        previewButton.widgets.healthBarLoss:SetVertexColor(lossR, lossG, lossB, CellDB["appearance"]["lossAlpha"])

        r, g, b, lossR, lossG, lossB = F.GetHealthBarColor(0.6, false, F.GetClassColor(Cell.vars.playerClass))
        previewButton2.widgets.healthBar:SetStatusBarColor(r, g, b, CellDB["appearance"]["barAlpha"])
        previewButton2.widgets.healthBarLoss:SetVertexColor(lossR, lossG, lossB, CellDB["appearance"]["lossAlpha"])

        -- bg alpha
        previewButton:SetBackdropColor(0, 0, 0, CellDB["appearance"]["bgAlpha"])
        previewButton2:SetBackdropColor(0, 0, 0, CellDB["appearance"]["bgAlpha"])

        -- shields
        UpdatePreviewShields(r, g, b)
    end

    previewButton.loaded = true

    Cell.Fire("UpdatePreview", previewButton, previewButton2)
end

---------------------------------------------------------------------
-- unit button style
---------------------------------------------------------------------
local textureDropdown, barColorDropdown, barColorPicker, fullColorCB, fullColorPicker, lossColorDropdown, lossColorPicker, deathColorCB, deathColorPicker, powerColorDropdown, powerColorPicker, barAnimationDropdown, targetColorPicker, mouseoverColorPicker, highlightSize
local gradientCB, thresholdCP1, thresholdCP2, thresholdCP3, thresholdDropdown1, thresholdDropdown2
local gradientLossCB, thresholdLossCP1, thresholdLossCP2, thresholdLossCP3, thresholdLossDropdown1, thresholdLossDropdown2
local barAlpha, lossAlpha, bgAlpha, oorAlpha, predCB, absorbCB, invertColorCB, shieldCB, oversCB, reverseCB
local predCustomCB, predColorPicker, absorbColorPicker, shieldColorPicker, oversColorPicker
local iconOptionsBtn, iconOptionsFrame, iconAnimationDropdown, durationRoundUpCB, durationDecimalText1, durationDecimalText2, durationDecimalDropdown, durationColorCB, durationNormalCP, durationPercentCP, durationSecondCP, durationPercentDD, durationSecondEB, durationSecondText

local LSM = LibStub("LibSharedMedia-3.0", true)
local function CheckTextures()
    local items = {}
    local textures, textureNames
    local defaultTexture, defaultTextureName = "Interface\\AddOns\\Cell\\Media\\statusbar.tga", "Cell"

    -- if LSM then
    textures, textureNames = F.Copy(LSM:HashTable("statusbar")), F.Copy(LSM:List("statusbar"))

    -- make default texture first
    F.TRemove(textureNames, defaultTextureName)
    tinsert(textureNames, 1, defaultTextureName)

    for _, name in pairs(textureNames) do
        tinsert(items, {
            ["text"] = name,
            ["texture"] = textures[name],
            ["onClick"] = function()
                CellDB["appearance"]["texture"] = name
                F.GetBarTexture() -- update Cell.vars.texture NOW
                Cell.Fire("UpdateAppearance", "texture")
            end,
        })
    end
    -- else
    --     textureNames = {defaultTextureName}
    --     textures = {[defaultTextureName] = defaultTexture}

    --     tinsert(items, {
    --         ["text"] = defaultTextureName,
    --         ["texture"] = defaultTexture,
    --         ["onClick"] = function()
    --             CellDB["appearance"]["texture"] = defaultTextureName
    --             F.GetBarTexture() -- update Cell.vars.texture NOW
    --             Cell.Fire("UpdateAppearance", "texture")
    --         end,
    --     })
    -- end
    textureDropdown:SetItems(items)

    -- validation
    if textures[CellDB["appearance"]["texture"]] then
        textureDropdown:SetSelected(CellDB["appearance"]["texture"], textures[CellDB["appearance"]["texture"]])
    else
        textureDropdown:SetSelected(defaultTextureName, defaultTexture)
    end
end

local function CreateIconOptionsFrame()
    iconOptionsFrame = AF.CreateBorderedFrame(appearanceTab, "CellOptionsFrame_IconOptions", 235, 235, "background", "Cell")
    AF.SetPoint(iconOptionsFrame, "TOP", iconOptionsBtn, "BOTTOM", 0, -5)
    AF.SetPoint(iconOptionsFrame, "RIGHT", -5, 0)
    iconOptionsFrame:SetFrameLevel(appearanceTab:GetFrameLevel() + 50)
    iconOptionsFrame:Hide()

    iconOptionsFrame:SetScript("OnShow", function()
        AF.ShowMask(appearanceTab, nil, 1, -1, -1, 1)
        iconOptionsBtn:SetFrameLevel(appearanceTab:GetFrameLevel() + 50)
    end)
    iconOptionsFrame:SetScript("OnHide", function()
        iconOptionsFrame:Hide()
        AF.HideMask(appearanceTab)
        iconOptionsBtn:SetFrameLevel(appearanceTab:GetFrameLevel() + 1)
    end)

    -- icon animation
    iconAnimationDropdown = AF.CreateDropdown(iconOptionsFrame, 180)
    AF.SetPoint(iconAnimationDropdown, "TOPLEFT", iconOptionsFrame, 10, -25)
    iconAnimationDropdown:SetLabel(L["Play Icon Animation When"])
    iconAnimationDropdown:SetItems({
        {
            ["text"] = L["+ Stack & Duration"],
            ["value"] = "duration",
            ["onClick"] = function()
                CellDB["appearance"]["auraIconOptions"]["animation"] = "duration"
                Cell.Fire("UpdateAppearance", "icon")
            end,
        },
        {
            ["text"] = L["+ Stack"],
            ["value"] = "stack",
            ["onClick"] = function()
                CellDB["appearance"]["auraIconOptions"]["animation"] = "stack"
                Cell.Fire("UpdateAppearance", "icon")
            end,
        },
        {
            ["text"] = L["Never"],
            ["value"] = "never",
            ["onClick"] = function()
                CellDB["appearance"]["auraIconOptions"]["animation"] = "never"
                Cell.Fire("UpdateAppearance", "icon")
            end,
        },
    })

    -- duration round up
    durationRoundUpCB = AF.CreateCheckButton(iconOptionsFrame, L["Round Up Duration Text"], function(checked, self)
        CellDropdownList:Hide()

        CellDB["appearance"]["auraIconOptions"]["durationRoundUp"] = checked
        AF.SetEnabled(not checked, durationDecimalText1, durationDecimalText2, durationDecimalDropdown)

        Cell.Fire("UpdateAppearance", "icon")
    end)
    AF.SetPoint(durationRoundUpCB, "TOPLEFT", iconAnimationDropdown, "BOTTOMLEFT", 0, -22)

    -- duration decimal
    durationDecimalText1 = iconOptionsFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    AF.SetPoint(durationDecimalText1, "TOPLEFT", durationRoundUpCB, "BOTTOMLEFT", 0, -10)
    durationDecimalText1:SetText(L["Display One Decimal Place When"])

    durationDecimalText2 = iconOptionsFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    AF.SetPoint(durationDecimalText2, "TOPLEFT", durationDecimalText1, "BOTTOMLEFT", 0, -5)
    durationDecimalText2:SetText(L["Remaining Time"] .. " <")

    durationDecimalDropdown = AF.CreateDropdown(iconOptionsFrame, 65)
    AF.SetPoint(durationDecimalDropdown, "LEFT", durationDecimalText2, "RIGHT", 5, 0)

    local items = {}
    for i = 5, 0, -1 do
        tinsert(items, {
            ["text"] = i == 0 and _G.NONE or i,
            ["value"] = i,
            ["onClick"] = function()
                CellDB["appearance"]["auraIconOptions"]["durationDecimal"] = i
                Cell.Fire("UpdateAppearance", "icon")
            end
        })
    end
    durationDecimalDropdown:SetItems(items)

    -- duration text color
    durationColorCB = AF.CreateCheckButton(iconOptionsFrame, L["Color Duration Text"], function(checked, self)
        CellDropdownList:Hide()

        -- restore sec
        durationSecondEB:SetText(CellDB["appearance"]["auraIconOptions"]["durationColors"][3][4])

        CellDB["appearance"]["auraIconOptions"]["durationColorEnabled"] = checked
        AF.SetEnabled(checked, durationNormalCP, durationPercentCP, durationPercentDD, durationSecondCP, durationSecondEB, durationSecondText)

        Cell.Fire("UpdateAppearance", "icon")
    end)
    AF.SetPoint(durationColorCB, "TOPLEFT", durationRoundUpCB, "BOTTOMLEFT", 0, -63)

    durationNormalCP = AF.CreateColorPicker(iconOptionsFrame, L["Normal"], false, function(r, g, b)
        CellDB["appearance"]["auraIconOptions"]["durationColors"][1][1] = r
        CellDB["appearance"]["auraIconOptions"]["durationColors"][1][2] = g
        CellDB["appearance"]["auraIconOptions"]["durationColors"][1][3] = b
        Cell.Fire("UpdateAppearance", "icon")
    end)
    AF.SetPoint(durationNormalCP, "TOPLEFT", durationColorCB, "BOTTOMLEFT", 0, -8)

    durationPercentCP = AF.CreateColorPicker(iconOptionsFrame, L["Remaining Time"] .. " <", false, function(r, g, b)
        CellDB["appearance"]["auraIconOptions"]["durationColors"][2][1] = r
        CellDB["appearance"]["auraIconOptions"]["durationColors"][2][2] = g
        CellDB["appearance"]["auraIconOptions"]["durationColors"][2][3] = b
        Cell.Fire("UpdateAppearance", "icon")
    end)
    AF.SetPoint(durationPercentCP, "TOPLEFT", durationNormalCP, "BOTTOMLEFT", 0, -8)

    durationSecondCP = AF.CreateColorPicker(iconOptionsFrame, L["Remaining Time"] .. " <", false, function(r, g, b)
        CellDB["appearance"]["auraIconOptions"]["durationColors"][3][1] = r
        CellDB["appearance"]["auraIconOptions"]["durationColors"][3][2] = g
        CellDB["appearance"]["auraIconOptions"]["durationColors"][3][3] = b
        Cell.Fire("UpdateAppearance", "icon")
    end)
    AF.SetPoint(durationSecondCP, "TOPLEFT", durationPercentCP, "BOTTOMLEFT", 0, -8)

    durationPercentDD = AF.CreateDropdown(iconOptionsFrame, 65)
    AF.SetPoint(durationPercentDD, "LEFT", durationPercentCP.label, "RIGHT", 5, 0)
    durationPercentDD:SetItems({
        {
            ["text"] = "75%",
            ["value"] = 0.75,
            ["onClick"] = function()
                CellDB["appearance"]["auraIconOptions"]["durationColors"][2][4] = 0.75
                Cell.Fire("UpdateAppearance", "icon")
            end,
        },
        {
            ["text"] = "50%",
            ["value"] = 0.5,
            ["onClick"] = function()
                CellDB["appearance"]["auraIconOptions"]["durationColors"][2][4] = 0.5
                Cell.Fire("UpdateAppearance", "icon")
            end,
        },
        {
            ["text"] = "30%",
            ["value"] = 0.3,
            ["onClick"] = function()
                CellDB["appearance"]["auraIconOptions"]["durationColors"][2][4] = 0.3
                Cell.Fire("UpdateAppearance", "icon")
            end,
        },
        {
            ["text"] = "25%",
            ["value"] = 0.25,
            ["onClick"] = function()
                CellDB["appearance"]["auraIconOptions"]["durationColors"][2][4] = 0.25
                Cell.Fire("UpdateAppearance", "icon")
            end,
        },
        {
            ["text"] = _G.NONE,
            ["value"] = 0,
            ["onClick"] = function()
                CellDB["appearance"]["auraIconOptions"]["durationColors"][2][4] = 0
                Cell.Fire("UpdateAppearance", "icon")
            end,
        },
    })

    durationSecondEB = AF.CreateEditBox(iconOptionsFrame, nil, 43, 20, "number")
    AF.SetPoint(durationSecondEB, "LEFT", durationSecondCP.label, "RIGHT", 5, 0)
    durationSecondEB:SetMaxLetters(4)
    durationSecondEB:SetConfirmButton(function(value)
        CellDB["appearance"]["auraIconOptions"]["durationColors"][3][4] = value
        Cell.Fire("UpdateAppearance", "icon")
    end, nil, "RIGHT_OUTSIDE")

    durationSecondText = iconOptionsFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    AF.SetPoint(durationSecondText, "LEFT", durationSecondEB, "RIGHT", 5, 0)
    durationSecondText:SetText(L["sec"])
end

local function UpdateCheckButtons()
    predCustomCB:SetEnabled(CellDB["appearance"]["healPrediction"][1])
    predColorPicker:SetEnabled(CellDB["appearance"]["healPrediction"][1] and CellDB["appearance"]["healPrediction"][2])
    shieldColorPicker:SetEnabled(CellDB["appearance"]["shield"][1])
    reverseCB:SetEnabled(CellDB["appearance"]["shield"][1])
    absorbColorPicker:SetEnabled(CellDB["appearance"]["healAbsorb"][1])
    invertColorCB:SetEnabled(CellDB["appearance"]["healAbsorb"][1])
    oversColorPicker:SetEnabled(CellDB["appearance"]["overshield"][1])

    if CellDB["appearance"]["healAbsorbInvertColor"] then
        absorbCB:SetText(L["Heal Absorb"])
        absorbColorPicker:Hide()
    else
        absorbCB:SetText("")
        absorbColorPicker:Show()
    end
end

local function UpdateColorPickers()
    -- full color
    if CellDB["appearance"]["barColor"][1] == "custom" then
        AF.ClearPoints(fullColorCB)
        AF.SetPoint(fullColorCB, "TOPLEFT", barColorPicker, "TOPRIGHT", 2, 0)
        barColorPicker:Show()
    else
        AF.ClearPoints(fullColorCB)
        AF.SetPoint(fullColorCB, "LEFT", barColorDropdown, "RIGHT", 5, 0)
        barColorPicker:Hide()
    end

    -- death color
    if CellDB["appearance"]["lossColor"][1] == "custom" then
        AF.ClearPoints(deathColorCB)
        AF.SetPoint(deathColorCB, "TOPLEFT", lossColorPicker, "TOPRIGHT", 2, 0)
        lossColorPicker:Show()
    else
        AF.ClearPoints(deathColorCB)
        AF.SetPoint(deathColorCB, "LEFT", lossColorDropdown, "RIGHT", 5, 0)
        lossColorPicker:Hide()
    end

    -- color threshold
    if CellDB["appearance"]["barColor"][1]:find("^threshold") then
        gradientCB:Show()
        thresholdCP1:Show()
        thresholdCP2:Show()
        thresholdCP3:Show()
        thresholdCP3:SetEnabled(CellDB["appearance"]["barColor"][1] == "threshold1")
        thresholdDropdown1:Show()
        thresholdDropdown2:Show()
        AF.ClearPoints(lossColorDropdown)
        AF.SetPoint(lossColorDropdown, "TOPLEFT", gradientCB, "BOTTOMLEFT", 0, -30)
    else
        gradientCB:Hide()
        thresholdCP1:Hide()
        thresholdCP2:Hide()
        thresholdCP3:Hide()
        thresholdDropdown1:Hide()
        thresholdDropdown2:Hide()
        AF.ClearPoints(lossColorDropdown)
        AF.SetPoint(lossColorDropdown, "TOPLEFT", barColorDropdown, "BOTTOMLEFT", 0, -30)
    end

    if CellDB["appearance"]["lossColor"][1]:find("^threshold") then
        gradientLossCB:Show()
        thresholdLossCP1:Show()
        thresholdLossCP2:Show()
        thresholdLossCP3:Show()
        thresholdLossCP1:SetEnabled(CellDB["appearance"]["lossColor"][1] == "threshold1")
        thresholdLossDropdown1:Show()
        thresholdLossDropdown2:Show()
        AF.ClearPoints(powerColorDropdown)
        AF.SetPoint(powerColorDropdown, "TOPLEFT", gradientLossCB, "BOTTOMLEFT", 0, -30)
    else
        gradientLossCB:Hide()
        thresholdLossCP1:Hide()
        thresholdLossCP2:Hide()
        thresholdLossCP3:Hide()
        thresholdLossDropdown1:Hide()
        thresholdLossDropdown2:Hide()
        AF.ClearPoints(powerColorDropdown)
        AF.SetPoint(powerColorDropdown, "TOPLEFT", lossColorDropdown, "BOTTOMLEFT", 0, -30)
    end

    -- power color
    if CellDB["appearance"]["powerColor"][1] == "custom" then
        powerColorPicker:Show()
    else
        powerColorPicker:Hide()
    end
end

local function CreateUnitButtonStylePane()
    local unitButtonPane = AF.CreateTitledPane(appearanceTab, L["Unit Button Style"], nil, 430)
    AF.SetPoint(unitButtonPane, "TOPLEFT", appearanceTab, 7, -145)
    AF.SetPoint(unitButtonPane, "TOPRIGHT", appearanceTab, -7, -145)

    -- texture
    textureDropdown = AF.CreateDropdown(unitButtonPane, 170, nil, nil, "texture")
    AF.SetPoint(textureDropdown, "TOPLEFT", unitButtonPane, "TOPLEFT", 5, -40)
    textureDropdown:SetLabel(L["Texture"])

    -- bar color
    barColorDropdown = AF.CreateDropdown(unitButtonPane, 150)
    AF.SetPoint(barColorDropdown, "TOPLEFT", textureDropdown, "BOTTOMLEFT", 0, -30)
    barColorDropdown:SetLabel(L["Health Bar Color"])
    barColorDropdown:SetItems({
        {
            ["text"] = L["Class Color"],
            ["value"] = "class_color",
            ["onClick"] = function()
                CellDB["appearance"]["barColor"][1] = "class_color"
                UpdateColorPickers()
                Cell.Fire("UpdateAppearance", "color")
            end,
        },
        {
            ["text"] = L["Class Color (dark)"],
            ["value"] = "class_color_dark",
            ["onClick"] = function()
                CellDB["appearance"]["barColor"][1] = "class_color_dark"
                UpdateColorPickers()
                Cell.Fire("UpdateAppearance", "color")
            end,
        },
        {
            ["text"] = L["Color Thresholds"] .. " A",
            ["value"] = "threshold1",
            ["onClick"] = function()
                CellDB["appearance"]["barColor"][1] = "threshold1"
                UpdateColorPickers()
                Cell.Fire("UpdateAppearance", "color")
            end,
        },
        {
            ["text"] = L["Color Thresholds"] .. " B",
            ["value"] = "threshold2",
            ["onClick"] = function()
                CellDB["appearance"]["barColor"][1] = "threshold2"
                UpdateColorPickers()
                Cell.Fire("UpdateAppearance", "color")
            end,
        },
        {
            ["text"] = L["Color Thresholds"] .. " C",
            ["value"] = "threshold3",
            ["onClick"] = function()
                CellDB["appearance"]["barColor"][1] = "threshold3"
                UpdateColorPickers()
                Cell.Fire("UpdateAppearance", "color")
            end,
        },
        {
            ["text"] = L["Custom Color"],
            ["value"] = "custom",
            ["onClick"] = function()
                CellDB["appearance"]["barColor"][1] = "custom"
                UpdateColorPickers()
                Cell.Fire("UpdateAppearance", "color")
            end,
        },
    })
    barColorDropdown:SetTooltip(L["Color Thresholds"] .. " |cffff2727" .. L["HIGH CPU USAGE"], "|cff7777770% -> 100%",
        "|cffffb5c5" .. L["Color Thresholds"] .. " A:", "|cffffffff" .. L["Color"] .. "1 |cff777777->|r " .. L["Color"] .. "2 |cff777777->|r " .. L["Color"] .. "3",
        "|cffffb5c5" .. L["Color Thresholds"] .. " B:", "|cffffffff" .. L["Color"] .. "1 |cff777777->|r " .. L["Color"] .. "2 |cff777777->|r " .. L["Class Color"],
        "|cffffb5c5" .. L["Color Thresholds"] .. " C:", "|cffffffff" .. L["Color"] .. "1 |cff777777->|r " .. L["Color"] .. "2 |cff777777->|r " .. L["Class Color (dark)"])

    barColorPicker = AF.CreateColorPicker(unitButtonPane, nil, false, function(r, g, b)
        CellDB["appearance"]["barColor"][2][1] = r
        CellDB["appearance"]["barColor"][2][2] = g
        CellDB["appearance"]["barColor"][2][3] = b
        if CellDB["appearance"]["barColor"][1] == "custom" then
            Cell.Fire("UpdateAppearance", "color")
        end
    end)
    AF.SetPoint(barColorPicker, "LEFT", barColorDropdown, "RIGHT", 5, 0)

    -- full hp color
    fullColorCB = AF.CreateCheckButton(unitButtonPane, nil, function(checked, self)
        CellDB["appearance"]["fullColor"][1] = checked
        fullColorPicker:SetEnabled(checked)
        Cell.Fire("UpdateAppearance", "fullColor")
    end)
    fullColorCB:SetTooltip(L["Enable Full Health Color"])
    -- AF.SetPoint(fullColorCB, "TOPLEFT", barColorPicker, "TOPRIGHT", 2, 0)

    fullColorPicker = AF.CreateColorPicker(unitButtonPane, nil, false, function(r, g, b)
        CellDB["appearance"]["fullColor"][2][1] = r
        CellDB["appearance"]["fullColor"][2][2] = g
        CellDB["appearance"]["fullColor"][2][3] = b
        if CellDB["appearance"]["fullColor"][1] then
            Cell.Fire("UpdateAppearance", "fullColor")
        end
    end)
    AF.SetPoint(fullColorPicker, "TOPLEFT", fullColorCB, "TOPRIGHT", 2, 0)

    -- use gradient color
    gradientCB = AF.CreateCheckButton(unitButtonPane, nil, function(checked, self)
        CellDB["appearance"]["colorThresholds"][6] = checked
        Cell.Fire("UpdateAppearance", "color")
    end)
    gradientCB:SetTooltip(L["Enable Color Gradient"])
    AF.SetPoint(gradientCB, "TOPLEFT", barColorDropdown, "BOTTOMLEFT", 0, -5)

    -- color thresholds
    thresholdCP1 = AF.CreateColorPicker(unitButtonPane, nil, false, function(r, g, b)
        CellDB["appearance"]["colorThresholds"][1][1] = r
        CellDB["appearance"]["colorThresholds"][1][2] = g
        CellDB["appearance"]["colorThresholds"][1][3] = b
        Cell.Fire("UpdateAppearance", "color")
    end)
    AF.SetPoint(thresholdCP1, "LEFT", gradientCB, "RIGHT", 5, 0)

    thresholdDropdown1 = AF.CreateDropdown(unitButtonPane, 50, 5, "vertical")
    AF.SetPoint(thresholdDropdown1, "LEFT", thresholdCP1, "RIGHT", 5, 0)
    do
        local values = {0, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5}
        local items = {}
        for _, v in pairs(values) do
            tinsert(items, {
                ["text"] = string.format("%d%%", v * 100),
                ["value"] = v,
                ["onClick"] = function()
                    CellDB["appearance"]["colorThresholds"][4] = v
                    Cell.Fire("UpdateAppearance", "color")
                end,
            })
        end
        thresholdDropdown1:SetItems(items)
    end

    thresholdCP2 = AF.CreateColorPicker(unitButtonPane, nil, false, function(r, g, b)
        CellDB["appearance"]["colorThresholds"][2][1] = r
        CellDB["appearance"]["colorThresholds"][2][2] = g
        CellDB["appearance"]["colorThresholds"][2][3] = b
        Cell.Fire("UpdateAppearance", "color")
    end)
    AF.SetPoint(thresholdCP2, "LEFT", thresholdDropdown1, "RIGHT", 5, 0)

    thresholdCP3 = AF.CreateColorPicker(unitButtonPane, nil, false, function(r, g, b)
        CellDB["appearance"]["colorThresholds"][3][1] = r
        CellDB["appearance"]["colorThresholds"][3][2] = g
        CellDB["appearance"]["colorThresholds"][3][3] = b
        Cell.Fire("UpdateAppearance", "color")
    end)
    AF.SetPoint(thresholdCP3, "LEFT", thresholdCP2, "RIGHT", 5, 0)

    thresholdDropdown2 = AF.CreateDropdown(unitButtonPane, 50, 5, "vertical")
    AF.SetPoint(thresholdDropdown2, "LEFT", thresholdCP3, "RIGHT", 5, 0)
    do
        local values = {1, 0.95, 0.9, 0.85, 0.8, 0.75, 0.7, 0.65, 0.6, 0.55, 0.5}
        local items = {}
        for _, v in pairs(values) do
            tinsert(items, {
                ["text"] = string.format("%d%%", v * 100),
                ["value"] = v,
                ["onClick"] = function()
                    CellDB["appearance"]["colorThresholds"][5] = v
                    Cell.Fire("UpdateAppearance", "color")
                end,
            })
        end
        thresholdDropdown2:SetItems(items)
    end

    -- loss color
    lossColorDropdown = AF.CreateDropdown(unitButtonPane, 150)
    -- AF.SetPoint(lossColorDropdown, "TOPLEFT", thresholdCP1, "BOTTOMLEFT", 0, -30)
    lossColorDropdown:SetLabel(L["Health Loss Color"])
    lossColorDropdown:SetItems({
        {
            ["text"] = L["Class Color"],
            ["value"] = "class_color",
            ["onClick"] = function()
                CellDB["appearance"]["lossColor"][1] = "class_color"
                UpdateColorPickers()
                Cell.Fire("UpdateAppearance", "color")
            end,
        },
        {
            ["text"] = L["Class Color (dark)"],
            ["value"] = "class_color_dark",
            ["onClick"] = function()
                CellDB["appearance"]["lossColor"][1] = "class_color_dark"
                UpdateColorPickers()
                Cell.Fire("UpdateAppearance", "color")
            end,
        },
        {
            ["text"] = L["Color Thresholds"] .. " A",
            ["value"] = "threshold1",
            ["onClick"] = function()
                CellDB["appearance"]["lossColor"][1] = "threshold1"
                UpdateColorPickers()
                Cell.Fire("UpdateAppearance", "color")
            end,
        },
        {
            ["text"] = L["Color Thresholds"] .. " B",
            ["value"] = "threshold2",
            ["onClick"] = function()
                CellDB["appearance"]["lossColor"][1] = "threshold2"
                UpdateColorPickers()
                Cell.Fire("UpdateAppearance", "color")
            end,
        },
        {
            ["text"] = L["Color Thresholds"] .. " C",
            ["value"] = "threshold3",
            ["onClick"] = function()
                CellDB["appearance"]["lossColor"][1] = "threshold3"
                UpdateColorPickers()
                Cell.Fire("UpdateAppearance", "color")
            end,
        },
        {
            ["text"] = L["Custom Color"],
            ["value"] = "custom",
            ["onClick"] = function()
                CellDB["appearance"]["lossColor"][1] = "custom"
                UpdateColorPickers()
                Cell.Fire("UpdateAppearance", "color")
            end,
        },
    })
    lossColorDropdown:SetTooltip(L["Color Thresholds"] .. " |cffff2727" .. L["HIGH CPU USAGE"], "|cff7777770% -> 100%",
        "|cffffb5c5" .. L["Color Thresholds"] .. " A:", "|cffffffff" .. L["Color"] .. "1 |cff777777->|r " .. L["Color"] .. "2 |cff777777->|r " .. L["Color"] .. "3",
        "|cffffb5c5" .. L["Color Thresholds"] .. " B:", "|cffffffff" .. L["Class Color"] .. " |cff777777->|r " .. L["Color"] .. "2 |cff777777->|r " .. L["Color"] .. "3",
        "|cffffb5c5" .. L["Color Thresholds"] .. " C:", "|cffffffff" .. L["Class Color (dark)"] .. " |cff777777->|r " .. L["Color"] .. "2 |cff777777->|r " .. L["Color"] .. "3")

    lossColorPicker = AF.CreateColorPicker(unitButtonPane, nil, false, function(r, g, b)
        CellDB["appearance"]["lossColor"][2][1] = r
        CellDB["appearance"]["lossColor"][2][2] = g
        CellDB["appearance"]["lossColor"][2][3] = b
        if CellDB["appearance"]["lossColor"][1] == "custom" then
            Cell.Fire("UpdateAppearance", "color")
        end
    end)
    AF.SetPoint(lossColorPicker, "LEFT", lossColorDropdown, "RIGHT", 5, 0)

    -- use gradient loss color
    gradientLossCB = AF.CreateCheckButton(unitButtonPane, nil, function(checked, self)
        CellDB["appearance"]["colorThresholdsLoss"][6] = checked
        Cell.Fire("UpdateAppearance", "color")
    end)
    gradientLossCB:SetTooltip(L["Enable Color Gradient"])
    AF.SetPoint(gradientLossCB, "TOPLEFT", lossColorDropdown, "BOTTOMLEFT", 0, -5)

    -- loss color thresholds
    thresholdLossCP1 = AF.CreateColorPicker(unitButtonPane, nil, false, function(r, g, b)
        CellDB["appearance"]["colorThresholdsLoss"][1][1] = r
        CellDB["appearance"]["colorThresholdsLoss"][1][2] = g
        CellDB["appearance"]["colorThresholdsLoss"][1][3] = b
        Cell.Fire("UpdateAppearance", "color")
    end)
    AF.SetPoint(thresholdLossCP1, "LEFT", gradientLossCB, "RIGHT", 5, 0)

    thresholdLossDropdown1 = AF.CreateDropdown(unitButtonPane, 50, 5, "vertical")
    AF.SetPoint(thresholdLossDropdown1, "LEFT", thresholdLossCP1, "RIGHT", 5, 0)
    do
        local values = {0, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5}
        local items = {}
        for _, v in pairs(values) do
            tinsert(items, {
                ["text"] = string.format("%d%%", v * 100),
                ["value"] = v,
                ["onClick"] = function()
                    CellDB["appearance"]["colorThresholdsLoss"][4] = v
                    Cell.Fire("UpdateAppearance", "color")
                end,
            })
        end
        thresholdLossDropdown1:SetItems(items)
    end

    thresholdLossCP2 = AF.CreateColorPicker(unitButtonPane, nil, false, function(r, g, b)
        CellDB["appearance"]["colorThresholdsLoss"][2][1] = r
        CellDB["appearance"]["colorThresholdsLoss"][2][2] = g
        CellDB["appearance"]["colorThresholdsLoss"][2][3] = b
        Cell.Fire("UpdateAppearance", "color")
    end)
    AF.SetPoint(thresholdLossCP2, "LEFT", thresholdLossDropdown1, "RIGHT", 5, 0)

    thresholdLossCP3 = AF.CreateColorPicker(unitButtonPane, nil, false, function(r, g, b)
        CellDB["appearance"]["colorThresholdsLoss"][3][1] = r
        CellDB["appearance"]["colorThresholdsLoss"][3][2] = g
        CellDB["appearance"]["colorThresholdsLoss"][3][3] = b
        Cell.Fire("UpdateAppearance", "color")
    end)
    AF.SetPoint(thresholdLossCP3, "LEFT", thresholdLossCP2, "RIGHT", 5, 0)

    thresholdLossDropdown2 = AF.CreateDropdown(unitButtonPane, 50, 5, "vertical")
    AF.SetPoint(thresholdLossDropdown2, "LEFT", thresholdLossCP3, "RIGHT", 5, 0)
    do
        local values = {1, 0.95, 0.9, 0.85, 0.8, 0.75, 0.7, 0.65, 0.6, 0.55, 0.5}
        local items = {}
        for _, v in pairs(values) do
            tinsert(items, {
                ["text"] = string.format("%d%%", v * 100),
                ["value"] = v,
                ["onClick"] = function()
                    CellDB["appearance"]["colorThresholdsLoss"][5] = v
                    Cell.Fire("UpdateAppearance", "color")
                end,
            })
        end
        thresholdLossDropdown2:SetItems(items)
    end

    -- death color
    deathColorCB = AF.CreateCheckButton(unitButtonPane, nil, function(checked, self)
        CellDB["appearance"]["deathColor"][1] = checked
        deathColorPicker:SetEnabled(checked)
        Cell.Fire("UpdateAppearance", "deathColor")
    end)
    deathColorCB:SetTooltip(L["Enable Death Color"])
    -- AF.SetPoint(deathColorCB, "TOPLEFT", lossColorPicker, "TOPRIGHT", 2, 0)

    deathColorPicker = AF.CreateColorPicker(unitButtonPane, nil, false, function(r, g, b)
        CellDB["appearance"]["deathColor"][2][1] = r
        CellDB["appearance"]["deathColor"][2][2] = g
        CellDB["appearance"]["deathColor"][2][3] = b
        if CellDB["appearance"]["deathColor"][1] then
            Cell.Fire("UpdateAppearance", "deathColor")
        end
    end)
    AF.SetPoint(deathColorPicker, "TOPLEFT", deathColorCB, "TOPRIGHT", 2, 0)

    -- power color
    powerColorDropdown = AF.CreateDropdown(unitButtonPane, 150)
    -- AF.SetPoint(powerColorDropdown, "TOPLEFT", lossColorDropdown, "BOTTOMLEFT", 0, -30)
    powerColorDropdown:SetLabel(L["Power Color"])
    powerColorDropdown:SetItems({
        {
            ["text"] = L["Power Color"],
            ["value"] = "power_color",
            ["onClick"] = function()
                CellDB["appearance"]["powerColor"][1] = "power_color"
                UpdateColorPickers()
                Cell.Fire("UpdateAppearance", "color")
            end,
        },
        {
            ["text"] = L["Power Color (dark)"],
            ["value"] = "power_color_dark",
            ["onClick"] = function()
                CellDB["appearance"]["powerColor"][1] = "power_color_dark"
                UpdateColorPickers()
                Cell.Fire("UpdateAppearance", "color")
            end,
        },
        {
            ["text"] = L["Class Color"],
            ["value"] = "class_color",
            ["onClick"] = function()
                CellDB["appearance"]["powerColor"][1] = "class_color"
                UpdateColorPickers()
                Cell.Fire("UpdateAppearance", "color")
            end,
        },
        {
            ["text"] = L["Custom Color"],
            ["value"] = "custom",
            ["onClick"] = function()
                CellDB["appearance"]["powerColor"][1] = "custom"
                UpdateColorPickers()
                Cell.Fire("UpdateAppearance", "color")
            end,
        },
    })

    powerColorPicker = AF.CreateColorPicker(unitButtonPane, nil, false, function(r, g, b)
        CellDB["appearance"]["powerColor"][2][1] = r
        CellDB["appearance"]["powerColor"][2][2] = g
        CellDB["appearance"]["powerColor"][2][3] = b
        if CellDB["appearance"]["powerColor"][1] == "custom" then
            Cell.Fire("UpdateAppearance", "color")
        end
    end)
    AF.SetPoint(powerColorPicker, "LEFT", powerColorDropdown, "RIGHT", 5, 0)

    -- bar animation
    barAnimationDropdown = AF.CreateDropdown(unitButtonPane, 150)
    AF.SetPoint(barAnimationDropdown, "TOPLEFT", powerColorDropdown, "BOTTOMLEFT", 0, -30)
    barAnimationDropdown:SetLabel(L["Bar Animation"])
    barAnimationDropdown:SetItems({
        {
            ["text"] = L["Flash"],
            ["onClick"] = function()
                CellDB["appearance"]["barAnimation"] = "Flash"
                Cell.Fire("UpdateAppearance", "animation")
            end,
        },
        {
            ["text"] = L["Smooth"],
            ["onClick"] = function()
                CellDB["appearance"]["barAnimation"] = "Smooth"
                Cell.Fire("UpdateAppearance", "animation")
            end,
        },
        {
            ["text"] = L["None"],
            ["onClick"] = function()
                CellDB["appearance"]["barAnimation"] = "None"
                Cell.Fire("UpdateAppearance", "animation")
            end,
        },
    })

    -- target highlight
    targetColorPicker = AF.CreateColorPicker(unitButtonPane, L["Target Highlight Color"], true, function(r, g, b, a)
        CellDB["appearance"]["targetColor"][1] = r
        CellDB["appearance"]["targetColor"][2] = g
        CellDB["appearance"]["targetColor"][3] = b
        CellDB["appearance"]["targetColor"][4] = a
        Cell.Fire("UpdateAppearance", "highlightColor")
    end)
    AF.SetPoint(targetColorPicker, "TOPLEFT", barAnimationDropdown, "BOTTOMLEFT", 0, -15)

    -- mouseover highlight
    mouseoverColorPicker = AF.CreateColorPicker(unitButtonPane, L["Mouseover Highlight Color"], true, function(r, g, b, a)
        CellDB["appearance"]["mouseoverColor"][1] = r
        CellDB["appearance"]["mouseoverColor"][2] = g
        CellDB["appearance"]["mouseoverColor"][3] = b
        CellDB["appearance"]["mouseoverColor"][4] = a
        Cell.Fire("UpdateAppearance", "highlightColor")
    end)
    AF.SetPoint(mouseoverColorPicker, "TOPLEFT", targetColorPicker, "BOTTOMLEFT", 0, -10)

    -- highlight size
    highlightSize = AF.CreateSlider(unitButtonPane, L["Highlight Size"], 150, -5, 5, 1, nil, true)
    AF.SetPoint(highlightSize, "TOPLEFT", mouseoverColorPicker, "BOTTOMLEFT", 0, -25)
    highlightSize:SetAfterValueChanged(function(value)
        CellDB["appearance"]["highlightSize"] = value
        Cell.Fire("UpdateAppearance", "highlightSize")
    end)

    -- icon options
    iconOptionsBtn = AF.CreateButton(unitButtonPane, L["Aura Icon Options"], "accent_hover", 160, 20)
    AF.SetPoint(iconOptionsBtn, "TOPLEFT", unitButtonPane, "TOPLEFT", 229, -40)
    iconOptionsBtn:SetScript("OnClick", function()
        if iconOptionsFrame:IsShown() then
            iconOptionsFrame:Hide()
        else
            iconOptionsFrame:Show()
        end
    end)

    -- bar alpha
    barAlpha = AF.CreateSlider(unitButtonPane, L["Health Bar Alpha"], 150, 0, 1, 0.01, true, true)
    AF.SetPoint(barAlpha, "TOPLEFT", iconOptionsBtn, "BOTTOMLEFT", 0, -30)
    barAlpha:SetOnValueChanged(function(value)
        CellDB["appearance"]["barAlpha"] = value
        Cell.Fire("UpdateAppearance", "alpha")
    end)

    -- loss alpha
    lossAlpha = AF.CreateSlider(unitButtonPane, L["Health Loss Alpha"], 150, 0, 1, 0.01, true, true)
    AF.SetPoint(lossAlpha, "TOPLEFT", barAlpha, "BOTTOMLEFT", 0, -40)
    lossAlpha:SetOnValueChanged(function(value)
        CellDB["appearance"]["lossAlpha"] = value
        Cell.Fire("UpdateAppearance", "alpha")
    end)

    -- bg alpha
    bgAlpha = AF.CreateSlider(unitButtonPane, L["Background Alpha"], 150, 0, 1, 0.01, true, true)
    AF.SetPoint(bgAlpha, "TOPLEFT", lossAlpha, "BOTTOMLEFT", 0, -40)
    bgAlpha:SetOnValueChanged(function(value)
        CellDB["appearance"]["bgAlpha"] = value
        Cell.Fire("UpdateAppearance", "alpha")
    end)

    -- out of range alpha
    oorAlpha = AF.CreateSlider(unitButtonPane, L["Out of Range Alpha"], 150, 0, 1, 0.01, true, true)
    AF.SetPoint(oorAlpha, "TOPLEFT", bgAlpha, "BOTTOMLEFT", 0, -40)
    oorAlpha:SetOnValueChanged(function(value)
        CellDB["appearance"]["outOfRangeAlpha"] = value
        Cell.Fire("UpdateAppearance", "outOfRangeAlpha")
    end)

    -- heal prediction
    predCB = AF.CreateCheckButton(unitButtonPane, L["Heal Prediction"], function(checked, self)
        CellDB["appearance"]["healPrediction"][1] = checked
        UpdateCheckButtons()
        Cell.Fire("UpdateAppearance", "shields")
    end)
    AF.SetPoint(predCB, "TOPLEFT", oorAlpha, "BOTTOMLEFT", 0, -35)

    -- heal prediction custom color
    predCustomCB = AF.CreateCheckButton(unitButtonPane, nil, function(checked, self)
        CellDB["appearance"]["healPrediction"][2] = checked
        UpdateCheckButtons()
        Cell.Fire("UpdateAppearance", "shields")
    end)
    AF.SetPoint(predCustomCB, "TOPLEFT", predCB, "BOTTOMRIGHT", 0, -7)

    predColorPicker = AF.CreateColorPicker(unitButtonPane, L["Custom Color"], true, function(r, g, b, a)
        CellDB["appearance"]["healPrediction"][3][1] = r
        CellDB["appearance"]["healPrediction"][3][2] = g
        CellDB["appearance"]["healPrediction"][3][3] = b
        CellDB["appearance"]["healPrediction"][3][4] = a
        Cell.Fire("UpdateAppearance", "shields")
    end)
    AF.SetPoint(predColorPicker, "TOPLEFT", predCustomCB, "TOPRIGHT", 5, 0)

    -- heal prediction use LibHealComm
    -- useLibCB = AF.CreateCheckButton(unitButtonPane, _G.USE.." LibHealComm", function(checked, self)
    --     CellDB["appearance"]["useLibHealComm"] = checked
    --     F.EnableLibHealComm(checked)
    -- end, L["LibHealComm needs to be installed"])
    -- AF.SetPoint(useLibCB, "TOPLEFT", predCustomCB, "BOTTOMLEFT", 0, -7)
    -- useLibCB:SetEnabled(Cell.isVanilla or Cell.isCata)

    -- heal absorb
    absorbCB = AF.CreateCheckButton(unitButtonPane, nil, function(checked, self)
        CellDB["appearance"]["healAbsorb"][1] = checked
        UpdateCheckButtons()
        Cell.Fire("UpdateAppearance", "shields")
    end)
    AF.SetPoint(absorbCB, "TOPLEFT", predCB, "BOTTOMLEFT", 0, -28)
    absorbCB:SetEnabled(Cell.isRetail)

    absorbColorPicker = AF.CreateColorPicker(unitButtonPane, L["Heal Absorb"], true, function(r, g, b, a)
        CellDB["appearance"]["healAbsorb"][2][1] = r
        CellDB["appearance"]["healAbsorb"][2][2] = g
        CellDB["appearance"]["healAbsorb"][2][3] = b
        CellDB["appearance"]["healAbsorb"][2][4] = a
        Cell.Fire("UpdateAppearance", "shields")
    end)
    AF.SetPoint(absorbColorPicker, "TOPLEFT", absorbCB, "TOPRIGHT", 5, 0)

    -- heal absorb invert color
    invertColorCB = AF.CreateCheckButton(unitButtonPane, L["Invert Color"], function(checked, self)
        CellDB["appearance"]["healAbsorbInvertColor"] = checked
        UpdateCheckButtons()
        Cell.Fire("UpdateAppearance", "shields")
    end)
    AF.SetPoint(invertColorCB, "TOPLEFT", absorbCB, "BOTTOMRIGHT", 0, -7)

    -- shield
    shieldCB = AF.CreateCheckButton(unitButtonPane, nil, function(checked, self)
        CellDB["appearance"]["shield"][1] = checked
        UpdateCheckButtons()
        Cell.Fire("UpdateAppearance", "shields")
    end)
    AF.SetPoint(shieldCB, "TOPLEFT", absorbCB, "BOTTOMLEFT", 0, -28)
    shieldCB:SetEnabled(not Cell.isVanilla)

    shieldColorPicker = AF.CreateColorPicker(unitButtonPane, L["Shield Texture"], true, function(r, g, b, a)
        CellDB["appearance"]["shield"][2][1] = r
        CellDB["appearance"]["shield"][2][2] = g
        CellDB["appearance"]["shield"][2][3] = b
        CellDB["appearance"]["shield"][2][4] = a
        Cell.Fire("UpdateAppearance", "shields")
    end)
    AF.SetPoint(shieldColorPicker, "TOPLEFT", shieldCB, "TOPRIGHT", 5, 0)

    -- overshield reverse fill
    reverseCB = AF.CreateCheckButton(unitButtonPane, L["Reverse Fill"], function(checked, self)
        CellDB["appearance"]["overshieldReverseFill"] = checked
        Cell.Fire("UpdateAppearance", "shields")
    end)
    AF.SetPoint(reverseCB, "TOPLEFT", shieldCB, "BOTTOMRIGHT", 0, -7)

    -- overshield
    oversCB = AF.CreateCheckButton(unitButtonPane, nil, function(checked, self)
        CellDB["appearance"]["overshield"][1] = checked
        UpdateCheckButtons()
        Cell.Fire("UpdateAppearance", "shields")
    end)
    AF.SetPoint(oversCB, "TOPLEFT", shieldCB, "BOTTOMLEFT", 0, -28)
    oversCB:SetEnabled(not Cell.isVanilla)

    oversColorPicker = AF.CreateColorPicker(unitButtonPane, L["Overshield Texture"], true, function(r, g, b, a)
        CellDB["appearance"]["overshield"][2][1] = r
        CellDB["appearance"]["overshield"][2][2] = g
        CellDB["appearance"]["overshield"][2][3] = b
        CellDB["appearance"]["overshield"][2][4] = a
        Cell.Fire("UpdateAppearance", "shields")
    end)
    AF.SetPoint(oversColorPicker, "TOPLEFT", oversCB, "TOPRIGHT", 5, 0)

    -- reset
    local resetBtn = AF.CreateButton(unitButtonPane, L["Reset All"], "accent", 77, 17)
    AF.SetPoint(resetBtn, "TOPRIGHT")
    resetBtn:SetTooltip(L["Reset All"], L["[Ctrl+Left-Click] to reset these settings"])
    resetBtn:SetScript("OnClick", function()
        if IsControlKeyDown() then
            F.ResetButtonStyle()

            -- load data
            textureDropdown:SetSelected("Cell " .. _G.DEFAULT, "Interface\\AddOns\\Cell\\Media\\statusbar.tga")
            LoadButtonStyle()

            Cell.Fire("UpdateAppearance", "reset")
        end
    end)
    AF.RegisterForCloseDropdown(resetBtn) -- close dropdown
end

---------------------------------------------------------------------
-- debuff type color
---------------------------------------------------------------------
local curseCP, diseaseCP, magicCP, poisonCP, bleedCP

local function CreateDebuffTypeColorPane()
    local dtcPane = AF.CreateTitledPane(appearanceTab, L["Debuff Type Color"], nil, 60)
    AF.SetPoint(dtcPane, "TOPLEFT", appearanceTab, 7, -595)
    AF.SetPoint(dtcPane, "TOPRIGHT", appearanceTab, -7, -595)

    -- curse
    curseCP = AF.CreateColorPicker(dtcPane, "|TInterface\\AddOns\\Cell\\Media\\Debuffs\\Curse:0|t" .. L["Curse"], false, nil, function(r, g, b)
        I.SetDebuffTypeColor("Curse", r, g, b)
        Cell.Fire("UpdateIndicators", F.GetNotifiedLayoutName(Cell.vars.currentLayout), "dispels", "debuffTypeColor")
    end)
    AF.SetPoint(curseCP, "TOPLEFT", 5, -27)

    -- disease
    diseaseCP = AF.CreateColorPicker(dtcPane, "|TInterface\\AddOns\\Cell\\Media\\Debuffs\\Disease:0|t" .. L["Disease"], false, nil, function(r, g, b)
        I.SetDebuffTypeColor("Disease", r, g, b)
        Cell.Fire("UpdateIndicators", F.GetNotifiedLayoutName(Cell.vars.currentLayout), "dispels", "debuffTypeColor")
    end)
    AF.SetPoint(diseaseCP, "TOPLEFT", curseCP, "TOPRIGHT", 95, 0)

    -- magic
    magicCP = AF.CreateColorPicker(dtcPane, "|TInterface\\AddOns\\Cell\\Media\\Debuffs\\Magic:0|t" .. L["Magic"], false, nil, function(r, g, b)
        I.SetDebuffTypeColor("Magic", r, g, b)
        Cell.Fire("UpdateIndicators", F.GetNotifiedLayoutName(Cell.vars.currentLayout), "dispels", "debuffTypeColor")
    end)
    AF.SetPoint(magicCP, "TOPLEFT", diseaseCP, "TOPRIGHT", 95, 0)

    -- poison
    poisonCP = AF.CreateColorPicker(dtcPane, "|TInterface\\AddOns\\Cell\\Media\\Debuffs\\Poison:0|t" .. L["Poison"], false, nil, function(r, g, b)
        I.SetDebuffTypeColor("Poison", r, g, b)
        Cell.Fire("UpdateIndicators", F.GetNotifiedLayoutName(Cell.vars.currentLayout), "dispels", "debuffTypeColor")
    end)
    AF.SetPoint(poisonCP, "TOPLEFT", magicCP, "TOPRIGHT", 95, 0)

    -- bleed
    bleedCP = AF.CreateColorPicker(dtcPane, "|TInterface\\AddOns\\Cell\\Media\\Debuffs\\Bleed:0|t" .. L["Bleed"], false, nil, function(r, g, b)
        I.SetDebuffTypeColor("Bleed", r, g, b)
        Cell.Fire("UpdateIndicators", F.GetNotifiedLayoutName(Cell.vars.currentLayout), "dispels", "debuffTypeColor")
    end)
    AF.SetPoint(bleedCP, "TOPLEFT", curseCP, "BOTTOMLEFT", 0, -7)

    -- reset
    local resetBtn = AF.CreateButton(dtcPane, L["Reset All"], "accent", 77, 17)
    AF.SetPoint(resetBtn, "TOPRIGHT")
    resetBtn:SetTooltip(L["Reset All"], L["[Ctrl+Left-Click] to reset these settings"])
    resetBtn:SetScript("OnClick", function()
        if IsControlKeyDown() then
            I.ResetDebuffTypeColor()
            LoadDebuffTypeColor()
            Cell.Fire("UpdateIndicators", F.GetNotifiedLayoutName(Cell.vars.currentLayout), "dispels", "debuffTypeColor")
        end
    end)
    AF.RegisterForCloseDropdown(resetBtn) -- close dropdown
end

---------------------------------------------------------------------
-- functions
---------------------------------------------------------------------
local init
LoadButtonStyle = function()
    if not init then CheckTextures() end

    UpdateColorPickers()
    UpdateCheckButtons()

    barColorDropdown:SetSelectedValue(CellDB["appearance"]["barColor"][1])
    barColorPicker:SetColor(CellDB["appearance"]["barColor"][2])

    fullColorCB:SetChecked(CellDB["appearance"]["fullColor"][1])
    fullColorPicker:SetColor(CellDB["appearance"]["fullColor"][2])
    fullColorPicker:SetEnabled(CellDB["appearance"]["fullColor"][1])

    lossColorDropdown:SetSelectedValue(CellDB["appearance"]["lossColor"][1])
    lossColorPicker:SetColor(CellDB["appearance"]["lossColor"][2])

    deathColorCB:SetChecked(CellDB["appearance"]["deathColor"][1])
    deathColorPicker:SetColor(CellDB["appearance"]["deathColor"][2])
    deathColorPicker:SetEnabled(CellDB["appearance"]["deathColor"][1])

    powerColorDropdown:SetSelectedValue(CellDB["appearance"]["powerColor"][1])
    powerColorPicker:SetColor(CellDB["appearance"]["powerColor"][2])

    barAnimationDropdown:SetSelected(L[CellDB["appearance"]["barAnimation"]])

    local c = CellDB["appearance"]["colorThresholds"]
    gradientCB:SetChecked(c[6])
    thresholdCP1:SetColor(c[1][1], c[1][2], c[1][3])
    thresholdCP2:SetColor(c[2][1], c[2][2], c[2][3])
    thresholdCP3:SetColor(c[3][1], c[3][2], c[3][3])
    thresholdDropdown1:SetSelectedValue(c[4])
    thresholdDropdown2:SetSelectedValue(c[5])

    local d = CellDB["appearance"]["colorThresholdsLoss"]
    gradientLossCB:SetChecked(d[6])
    thresholdLossCP1:SetColor(d[1][1], d[1][2], d[1][3])
    thresholdLossCP2:SetColor(d[2][1], d[2][2], d[2][3])
    thresholdLossCP3:SetColor(d[3][1], d[3][2], d[3][3])
    thresholdLossDropdown1:SetSelectedValue(d[4])
    thresholdLossDropdown2:SetSelectedValue(d[5])

    targetColorPicker:SetColor(CellDB["appearance"]["targetColor"])
    mouseoverColorPicker:SetColor(CellDB["appearance"]["mouseoverColor"])
    highlightSize:SetValue(CellDB["appearance"]["highlightSize"])
    oorAlpha:SetValue(CellDB["appearance"]["outOfRangeAlpha"])
    barAlpha:SetValue(CellDB["appearance"]["barAlpha"])
    lossAlpha:SetValue(CellDB["appearance"]["lossAlpha"])
    bgAlpha:SetValue(CellDB["appearance"]["bgAlpha"])

    predCB:SetChecked(CellDB["appearance"]["healPrediction"][1])
    -- useLibCB:SetChecked(CellDB["appearance"]["useLibHealComm"])
    absorbCB:SetChecked(CellDB["appearance"]["healAbsorb"][1])
    invertColorCB:SetChecked(CellDB["appearance"]["healAbsorbInvertColor"])
    shieldCB:SetChecked(CellDB["appearance"]["shield"][1])
    oversCB:SetChecked(CellDB["appearance"]["overshield"][1])
    reverseCB:SetChecked(CellDB["appearance"]["overshieldReverseFill"])

    predCustomCB:SetChecked(CellDB["appearance"]["healPrediction"][2])
    predColorPicker:SetColor(unpack(CellDB["appearance"]["healPrediction"][3]))
    absorbColorPicker:SetColor(unpack(CellDB["appearance"]["healAbsorb"][2]))
    shieldColorPicker:SetColor(unpack(CellDB["appearance"]["shield"][2]))
    oversColorPicker:SetColor(unpack(CellDB["appearance"]["overshield"][2]))

    -- icon options
    iconAnimationDropdown:SetSelectedValue(CellDB["appearance"]["auraIconOptions"]["animation"])
    durationRoundUpCB:SetChecked(CellDB["appearance"]["auraIconOptions"]["durationRoundUp"])
    AF.SetEnabled(not CellDB["appearance"]["auraIconOptions"]["durationRoundUp"], durationDecimalText1, durationDecimalText2, durationDecimalDropdown)
    durationDecimalDropdown:SetSelectedValue(CellDB["appearance"]["auraIconOptions"]["durationDecimal"])
    durationColorCB:SetChecked(CellDB["appearance"]["auraIconOptions"]["durationColorEnabled"])
    AF.SetEnabled(CellDB["appearance"]["auraIconOptions"]["durationColorEnabled"], durationNormalCP, durationPercentCP, durationPercentDD, durationSecondCP, durationSecondEB, durationSecondText)
    durationNormalCP:SetColor(CellDB["appearance"]["auraIconOptions"]["durationColors"][1])
    durationPercentCP:SetColor(CellDB["appearance"]["auraIconOptions"]["durationColors"][2][1], CellDB["appearance"]["auraIconOptions"]["durationColors"][2][2], CellDB["appearance"]["auraIconOptions"]["durationColors"][2][3])
    durationPercentDD:SetSelectedValue(CellDB["appearance"]["auraIconOptions"]["durationColors"][2][4])
    durationSecondCP:SetColor(CellDB["appearance"]["auraIconOptions"]["durationColors"][3][1], CellDB["appearance"]["auraIconOptions"]["durationColors"][3][2], CellDB["appearance"]["auraIconOptions"]["durationColors"][3][3])
    durationSecondEB:SetText(CellDB["appearance"]["auraIconOptions"]["durationColors"][3][4])
end

LoadDebuffTypeColor = function()
    curseCP:SetColor(I.GetDebuffTypeColor("Curse"))
    diseaseCP:SetColor(I.GetDebuffTypeColor("Disease"))
    magicCP:SetColor(I.GetDebuffTypeColor("Magic"))
    poisonCP:SetColor(I.GetDebuffTypeColor("Poison"))
    bleedCP:SetColor(I.GetDebuffTypeColor("Bleed"))
end

LoadData = function()
    scaleSlider:SetValue(CellDB["appearance"]["scale"])
    strataDropdown:SetSelected(CellDB["appearance"]["strata"])
    accentColorDropdown:SetSelected(CellDB["appearance"]["accentColor"][1])
    accentColorPicker:SetColor(CellDB["appearance"]["accentColor"][2])
    accentColorPicker:SetEnabled(CellDB["appearance"]["accentColor"][1] == "custom")
    -- optionsFontSizeOffset:SetValue(CellDB["appearance"]["optionsFontSizeOffset"])
    -- useGameFontCB:SetChecked(CellDB["appearance"]["useGameFont"])

    LoadButtonStyle()
    LoadDebuffTypeColor()
end

local function ShowTab(tab)
    if tab == "appearance" then
        if not init then
            CreatePreviewIcons()
            CreatePreviewButtons()
            CreateCellPane()
            CreateUnitButtonStylePane()
            CreateIconOptionsFrame()
            CreateDebuffTypeColorPane()
            AF.ApplyCombatProtectionToWidget(scaleSlider)
            AF.ApplyCombatProtectionToWidget(strataDropdown)
        end

        appearanceTab:Show()

        if init then return end

        UpdatePreviewButton()
        LoadData()
        init = true
    else
        appearanceTab:Hide()
    end
end
Cell.RegisterCallback("ShowOptionsTab", "AppearanceTab_ShowTab", ShowTab)

---------------------------------------------------------------------
-- update preivew
---------------------------------------------------------------------
local function UpdateLayout()
    if init and previewButton.loaded then
        UpdatePreviewButton("layout")
    end
end
Cell.RegisterCallback("UpdateLayout", "AppearanceTab_UpdateLayout", UpdateLayout)

--[[
local function UpdateIndicators(...)
    if init then
        UpdatePreviewIcons(...)
    end
end
Cell.RegisterCallback("UpdateIndicators", "AppearanceTab_UpdateIndicators", UpdateIndicators)
]]

---------------------------------------------------------------------
-- update appearance
---------------------------------------------------------------------
local function UpdateAppearance(which)
    F.Debug("|cff7f7fffUpdateAppearance:|r", which)

    if not which or which == "texture" or which == "color" or which == "fullColor" or which == "deathColor" or which == "alpha" or which == "outOfRangeAlpha" or which == "shields" or which == "animation" or which == "highlightColor" or which == "highlightSize" or which == "reset" then
        local tex
        if not which or which == "texture" or which == "reset" then tex = F.GetBarTexture() end

        if not which or which == "color" or which == "reset" then
            if strfind(CellDB["appearance"]["barColor"][1], "^threshold") or strfind(CellDB["appearance"]["lossColor"][1], "^threshold") then
                Cell.vars.useThresholdColor = true
            else
                Cell.vars.useThresholdColor = false
            end
        end

        if not which or which == "fullColor" or which == "reset" then
            Cell.vars.useFullColor = CellDB["appearance"]["fullColor"][1] and true or false
        end

        if not which or which == "deathColor" or which == "reset" then
            Cell.vars.useDeathColor = CellDB["appearance"]["deathColor"][1] and true or false
        end

        F.IterateAllUnitButtons(function(b)
            -- texture
            if not which or which == "texture" or which == "reset" then
                B.SetTexture(b, tex)
            end
            -- color
            if not which or which == "color" or which == "fullColor" or which == "deathColor" or which == "alpha" or which == "shields" or which == "reset" then
                B.UpdateColor(b)
            end
            -- outOfRangeAlpha
            if which == "outOfRangeAlpha" or which == "reset" then
                b.states.wasInRange = false
            end
            -- shields
            if not which or which == "shields" or which == "reset" then
                B.UpdateShields(b)
            end
            -- animation
            if not which or which == "animation" or which == "reset" then
                B.UpdateAnimation(b)
            end
            -- highlightColor
            if not which or which == "highlightColor" or which == "reset" then
                B.UpdateHighlightColor(b)
            end
            -- highlightColor
            if not which or which == "highlightSize" or which == "reset" then
                B.UpdateHighlightSize(b)
            end
        end)
    end

    -- icon options
    if not which or which == "icon" or which == "reset" then
        -- animation
        Cell.vars.iconAnimation = CellDB["appearance"]["auraIconOptions"]["animation"]

        -- round up
        Cell.vars.iconDurationRoundUp = CellDB["appearance"]["auraIconOptions"]["durationRoundUp"]

        -- decimal
        Cell.vars.iconDurationDecimal = CellDB["appearance"]["auraIconOptions"]["durationDecimal"]

        -- color
        if CellDB["appearance"]["auraIconOptions"]["durationColorEnabled"] then
            Cell.vars.iconDurationColors = CellDB["appearance"]["auraIconOptions"]["durationColors"]
        else
            Cell.vars.iconDurationColors = nil
        end
    end

    -- scale
    if not which or which == "scale" then
        CellMainFrame:SetScale(CellDB["appearance"]["scale"])

        CellTooltip:UpdatePixelPerfect()
        CellSpellTooltip:UpdatePixelPerfect()
        Cell.menu:UpdatePixelPerfect()

        if Cell.frames.changelogsFrame then
            Cell.frames.changelogsFrame:UpdatePixelPerfect()
        end

        if Cell.frames.codeSnippetsFrame then
            Cell.frames.codeSnippetsFrame:UpdatePixelPerfect()
        end

        if CellColorPicker then
            CellColorPicker:UpdatePixelPerfect()
        end
    end

    -- strata
    if not which or which == "strata" then
        CellMainFrame:SetFrameStrata(CellDB["appearance"]["strata"])
        CellOptionsFrame:SetFrameStrata("DIALOG")
        Cell.frames.raidRosterFrame:SetFrameStrata("DIALOG")
    end

    -- preview
    if which ~= "highlightColor" and which ~= "highlightSize" and init and previewButton:IsVisible() then
        UpdatePreviewButton(which)
    end
end
Cell.RegisterCallback("UpdateAppearance", "UpdateAppearance", UpdateAppearance)