local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

local appearanceTab = Cell:CreateFrame("CellOptionsFrame_AppearanceTab", Cell.frames.optionsFrame, nil, nil, true)
Cell.frames.appearanceTab = appearanceTab
appearanceTab:SetAllPoints(Cell.frames.optionsFrame)
appearanceTab:Hide()

-------------------------------------------------
-- scale
-------------------------------------------------
local scaleSlider

local function CreateScalePane()
    local scalePane = Cell:CreateTitledPane(appearanceTab, L["Scale"], 205, 60)
    scalePane:SetPoint("TOPLEFT", appearanceTab, "TOPLEFT", 5, -5)
    
    scaleSlider = Cell:CreateSlider("", scalePane, 0.5, 4, 160, 0.1, nil, nil, nil, L["Scale"], L["Non-integer scaling may result in abnormal display of options UI"])
    scaleSlider:SetPoint("TOPLEFT", scalePane, "TOPLEFT", 5, -27)
    scaleSlider.afterValueChangedFn = function(value)
        CellDB["appearance"]["scale"] = value
        Cell:Fire("UpdateAppearance", "scale")
        Cell:Fire("UpdatePixelPerfect")
    
        local popup = Cell:CreateConfirmPopup(appearanceTab, 200, L["A UI reload is required.\nDo it now?"], function()
            ReloadUI()
        end, nil, true)
        popup:SetPoint("TOPLEFT", appearanceTab, "TOPLEFT", 117, -70)
    end
    Cell:RegisterForCloseDropdown(scaleSlider)
end

-------------------------------------------------
-- font
-------------------------------------------------
local optionsFontSizeOffset, useGameFontCB

local function CreateFontPane()
    local fontPane = Cell:CreateTitledPane(appearanceTab, L["Options UI Font Size"], 205, 60)
    fontPane:SetPoint("TOPLEFT", appearanceTab, "TOPLEFT", 222, -5)
    
    optionsFontSizeOffset = Cell:CreateSlider("", fontPane, -5, 5, 160, 1)
    optionsFontSizeOffset:SetPoint("TOPLEFT", fontPane, "TOPLEFT", 5, -27)
    
    optionsFontSizeOffset.afterValueChangedFn = function(value)
        CellDB["appearance"]["optionsFontSizeOffset"] = value
        Cell:UpdateOptionsFont(value, CellDB["appearance"]["useGameFont"])
    end
    
    useGameFontCB = Cell:CreateCheckButton(fontPane, "", function(checked)
        CellDB["appearance"]["useGameFont"] = checked
        Cell:UpdateOptionsFont(CellDB["appearance"]["optionsFontSizeOffset"], checked)
    end, "Use Game Font")
    useGameFontCB:SetPoint("TOPRIGHT")
    if F:IsAsian() then
        useGameFontCB:Hide()
    end
end

-------------------------------------------------
-- preview button
-------------------------------------------------
local previewButton, previewButton2

local function CreatePreviewButtons()
    previewButton = CreateFrame("Button", "CellAppearancePreviewButton", appearanceTab, "CellUnitButtonTemplate")
    previewButton:SetPoint("TOPLEFT", appearanceTab, "TOPRIGHT", 5, -200)
    previewButton:UnregisterAllEvents()
    previewButton:SetScript("OnEnter", nil)
    previewButton:SetScript("OnLeave", nil)
    previewButton:SetScript("OnUpdate", nil)
    previewButton:Show()
    
    local previewButtonBG = Cell:CreateFrame("AppearancePreviewButtonBG", appearanceTab)
    previewButtonBG:SetPoint("TOPLEFT", previewButton, 0, 20)
    previewButtonBG:SetPoint("BOTTOMRIGHT", previewButton, "TOPRIGHT")
    previewButtonBG:SetFrameStrata("BACKGROUND")
    Cell:StylizeFrame(previewButtonBG, {.1, .1, .1, .77}, {0, 0, 0, 0})
    previewButtonBG:Show()
    
    local previewText = previewButtonBG:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET_TITLE")
    previewText:SetPoint("TOP", 0, -3)
    previewText:SetText(Cell:GetPlayerClassColorString()..L["Preview"].." 1")
    
    previewButton2 = CreateFrame("Button", "AppearancePreviewButton2", appearanceTab, "CellUnitButtonTemplate")
    previewButton2:SetPoint("BOTTOMLEFT", appearanceTab, "BOTTOMRIGHT", 5, 20)
    previewButton2:UnregisterAllEvents()
    previewButton2:SetScript("OnEnter", nil)
    previewButton2:SetScript("OnLeave", nil)
    previewButton2:SetScript("OnUpdate", nil)
    previewButton2:Show()
    
    local previewButtonBG2 = Cell:CreateFrame("AppearancePreviewButtonBG", appearanceTab)
    previewButtonBG2:SetPoint("TOPLEFT", previewButton2, 0, 20)
    previewButtonBG2:SetPoint("BOTTOMRIGHT", previewButton2, "TOPRIGHT")
    previewButtonBG2:SetFrameStrata("BACKGROUND")
    Cell:StylizeFrame(previewButtonBG2, {.1, .1, .1, .77}, {0, 0, 0, 0})
    previewButtonBG2:Show()
    
    local previewText2 = previewButtonBG2:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET_TITLE")
    previewText2:SetPoint("TOP", 0, -3)
    previewText2:SetText(Cell:GetPlayerClassColorString()..L["Preview"].." 2")

    -- animation
    local states = {-30, -60, 50, -40, 80}
    local ticker
    previewButton:SetScript("OnShow", function()
        previewButton.perc = 1
        previewButton.widget.healthBar:SetValue(100)
        local health, healthPercent, healthPercentOld, currentState = 100, 1, 1, 1

        ticker = C_Timer.NewTicker(1, function()
            health = health + states[currentState]
            healthPercent = health / 100
            previewButton.perc = healthPercent

            if CellDB["appearance"]["barAnimation"] == "Flash" then
                previewButton.widget.healthBar:SetValue(health)

                local diff = healthPercent - (healthPercentOld or healthPercent)
                if diff >= 0 then
                    previewButton.func.HideFlash()
                    -- previewButton.widget.damageFlashTex:Hide()
                elseif diff <= -0.05 and diff >= -1 then
                    previewButton.func.ShowFlash(abs(diff))
                    -- print(abs(diff))
                    -- previewButton.widget.damageFlashTex:SetWidth((Cell.vars.currentLayoutTable["size"][1] - 2) * abs(diff))
                    -- previewButton.widget.damageFlashTex:Show()
                end
            elseif CellDB["appearance"]["barAnimation"] == "Smooth" then
                previewButton.widget.healthBar:SetSmoothedValue(health)
            else
                previewButton.widget.healthBar:SetValue(health)
            end

            if CellDB["appearance"]["barColor"][1] == "Gradient" or CellDB["appearance"]["lossColor"][1] == "Gradient" then
                local r, g, b, lossR, lossG, lossB = F:GetHealthColor(healthPercent, F:GetClassColor(Cell.vars.playerClass))
                previewButton.widget.healthBar:SetStatusBarColor(r, g, b, CellDB["appearance"]["barAlpha"])
                previewButton.widget.healthBarLoss:SetVertexColor(lossR, lossG, lossB, CellDB["appearance"]["lossAlpha"])
            end

            healthPercentOld = healthPercent
            currentState = currentState == 5 and 1 or (currentState + 1)
        end)
    end)

    previewButton:SetScript("OnHide", function()
        previewButton.perc = 100
        ticker:Cancel()
        ticker = nil
    end)
end

local function UpdatePreviewShields()
    if CellDB["appearance"]["healPrediction"] then
        previewButton2.widget.incomingHeal:SetValue(0.2)
    else
        previewButton2.widget.incomingHeal:Hide()
    end

    if CellDB["appearance"]["healAbsorb"] then
        previewButton2.widget.absorbsBar:SetValue(0.3)
    else
        previewButton2.widget.absorbsBar:Hide()
    end

    if CellDB["appearance"]["shield"] then
        previewButton2.widget.shieldBar:SetValue(0.4)
    else
        previewButton2.widget.shieldBar:Hide()
    end

    if CellDB["appearance"]["overshield"] then
        previewButton2.widget.overShieldGlow:Show()
    else
        previewButton2.widget.overShieldGlow:Hide()
    end
end

local function UpdatePreviewButton()
    previewButton.widget.healthBar:SetStatusBarTexture(Cell.vars.texture)
    previewButton.widget.healthBarLoss:SetTexture(Cell.vars.texture)
    previewButton.widget.powerBar:SetStatusBarTexture(Cell.vars.texture)
    previewButton.widget.powerBarLoss:SetTexture(Cell.vars.texture)
    previewButton.widget.incomingHeal:SetTexture(Cell.vars.texture)
    previewButton.widget.damageFlashTex:SetTexture(Cell.vars.texture)

    previewButton2.widget.healthBar:SetStatusBarTexture(Cell.vars.texture)
    previewButton2.widget.healthBarLoss:SetTexture(Cell.vars.texture)
    previewButton2.widget.powerBar:SetStatusBarTexture(Cell.vars.texture)
    previewButton2.widget.powerBarLoss:SetTexture(Cell.vars.texture)
    previewButton2.widget.incomingHeal:SetTexture(Cell.vars.texture)
    previewButton2.widget.damageFlashTex:SetTexture(Cell.vars.texture)

    -- power color
    local r, g, b = F:GetPowerColor("player", Cell.vars.playerClass)
    previewButton.widget.powerBar:SetStatusBarColor(r, g, b)
    previewButton2.widget.powerBar:SetStatusBarColor(r, g, b)

    -- alpha
    previewButton:SetBackdropColor(0, 0, 0, CellDB["appearance"]["bgAlpha"])
    previewButton2:SetBackdropColor(0, 0, 0, CellDB["appearance"]["bgAlpha"])
    
    -- barOrientation
    previewButton.func.SetOrientation(unpack(Cell.vars.currentLayoutTable["barOrientation"]))
    previewButton2.func.SetOrientation(unpack(Cell.vars.currentLayoutTable["barOrientation"]))

    -- size
    P:Size(previewButton, Cell.vars.currentLayoutTable["size"][1], Cell.vars.currentLayoutTable["size"][2])
    previewButton.func.SetPowerSize(Cell.vars.currentLayoutTable["powerSize"])
    P:Size(previewButton2, Cell.vars.currentLayoutTable["size"][1], Cell.vars.currentLayoutTable["size"][2])
    previewButton2.func.SetPowerSize(Cell.vars.currentLayoutTable["powerSize"])

    -- value
    if CellDB["appearance"]["barAnimation"] == "Smooth" then
        previewButton.widget.healthBar:SetMinMaxSmoothedValue(0, 100)
    else
        previewButton.widget.healthBar:SetMinMaxValues(0, 100)
    end
    
    previewButton2.widget.healthBar:SetMinMaxValues(0, 100)
    previewButton2.widget.healthBar:SetValue(60)
    previewButton2.state.healthMax = 100
    previewButton2.state.healthPercent = 0.6


    -- health color
    local r, g, b, lossR, lossG, lossB 
    r, g, b, lossR, lossG, lossB = F:GetHealthColor(previewButton.perc or 1, F:GetClassColor(Cell.vars.playerClass))
    previewButton.widget.healthBar:SetStatusBarColor(r, g, b, CellDB["appearance"]["barAlpha"])
    previewButton.widget.healthBarLoss:SetVertexColor(lossR, lossG, lossB, CellDB["appearance"]["lossAlpha"])

    r, g, b, lossR, lossG, lossB = F:GetHealthColor(0.6, F:GetClassColor(Cell.vars.playerClass))
    previewButton2.widget.healthBar:SetStatusBarColor(r, g, b, CellDB["appearance"]["barAlpha"])
    previewButton2.widget.healthBarLoss:SetVertexColor(lossR, lossG, lossB, CellDB["appearance"]["lossAlpha"])

    UpdatePreviewShields()

    previewButton.loaded = true
end

-------------------------------------------------
-- unitbutton
-------------------------------------------------
local textureDropdown, barColorDropdown, barColorPicker, lossColorDropdown, lossColorPicker, powerColorDropdown, powerColorPicker, barAnimationDropdown, targetColorPicker, mouseoverColorPicker, highlightSize
local iconAnimationDropdown, barAlpha, lossAlpha, bgAlpha, oorAlpha, predCB, absorbCB, shieldCB, oversCB, resetBtn

local function CheckTextures()
    local items = {}
    local textures, textureNames
    local defaultTexture, defaultTextureName = "Interface\\AddOns\\Cell\\Media\\statusbar.tga", "Cell ".._G.DEFAULT
    
    local LSM = LibStub("LibSharedMedia-3.0", true)
    if LSM then
        textures, textureNames = F:Copy(LSM:HashTable("statusbar")), F:Copy(LSM:List("statusbar"))
        -- insert default texture
        tinsert(textureNames, 1, defaultTextureName)
        textures[defaultTextureName] = defaultTexture

        for _, name in pairs(textureNames) do
            tinsert(items, {
                ["text"] = name,
                ["texture"] = textures[name],
                ["onClick"] = function()
                    CellDB["appearance"]["texture"] = name
                    F:GetBarTexture() -- update Cell.vars.texture NOW
                    Cell:Fire("UpdateAppearance", "texture")
                end,
            })
        end
    else
        textureNames = {defaultTextureName}
        textures = {[defaultTextureName] = defaultTexture}

        tinsert(items, {
            ["text"] = defaultTextureName,
            ["texture"] = defaultTexture,
            ["onClick"] = function()
                CellDB["appearance"]["texture"] = defaultTextureName
                F:GetBarTexture() -- update Cell.vars.texture NOW
                Cell:Fire("UpdateAppearance", "texture")
            end,
        })
    end
    textureDropdown:SetItems(items)

    -- validation
    if textures[CellDB["appearance"]["texture"]] then
        textureDropdown:SetSelected(CellDB["appearance"]["texture"], textures[CellDB["appearance"]["texture"]])
    else
        textureDropdown:SetSelected(defaultTextureName, defaultTexture)
    end
end

local function CreateUnitButtonStylePane()
    local unitButtonPane = Cell:CreateTitledPane(appearanceTab, L["Unit Button Style"], 422, 366)
    unitButtonPane:SetPoint("TOPLEFT", appearanceTab, "TOPLEFT", 5, -80)
    
    -- texture
    textureDropdown = Cell:CreateDropdown(unitButtonPane, 160, "texture")
    textureDropdown:SetPoint("TOPLEFT", unitButtonPane, "TOPLEFT", 5, -42)
    
    local textureText = unitButtonPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    textureText:SetPoint("BOTTOMLEFT", textureDropdown, "TOPLEFT", 0, 1)
    textureText:SetText(L["Texture"])
    
    -- bar color
    barColorDropdown = Cell:CreateDropdown(unitButtonPane, 141)
    barColorDropdown:SetPoint("TOPLEFT", textureDropdown, "BOTTOMLEFT", 0, -30)
    barColorDropdown:SetItems({
        {
            ["text"] = L["Class Color"],
            ["onClick"] = function()
                CellDB["appearance"]["barColor"][1] = "Class Color"
                Cell:Fire("UpdateAppearance", "color")
            end,
        },
        {
            ["text"] = L["Class Color (dark)"],
            ["onClick"] = function()
                CellDB["appearance"]["barColor"][1] = "Class Color (dark)"
                Cell:Fire("UpdateAppearance", "color")
            end,
        },
        {
            ["text"] = L["Gradient"],
            ["onClick"] = function()
                CellDB["appearance"]["barColor"][1] = "Gradient"
                Cell:Fire("UpdateAppearance", "color")
            end,
        },
        {
            ["text"] = L["Custom Color"],
            ["onClick"] = function()
                CellDB["appearance"]["barColor"][1] = "Custom Color"
                Cell:Fire("UpdateAppearance", "color")
            end,
        },
    })
    
    local barColorText = unitButtonPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    barColorText:SetPoint("BOTTOMLEFT", barColorDropdown, "TOPLEFT", 0, 1)
    barColorText:SetText(L["Health Bar Color"])
    
    barColorPicker = Cell:CreateColorPicker(unitButtonPane, "", false, function(r, g, b)
        CellDB["appearance"]["barColor"][2][1] = r
        CellDB["appearance"]["barColor"][2][2] = g
        CellDB["appearance"]["barColor"][2][3] = b
        if CellDB["appearance"]["barColor"][1] == "Custom Color" then
            Cell:Fire("UpdateAppearance", "color")
        end
    end)
    barColorPicker:SetPoint("LEFT", barColorDropdown, "RIGHT", 5, 0)
    
    -- loss color
    lossColorDropdown = Cell:CreateDropdown(unitButtonPane, 141)
    lossColorDropdown:SetPoint("TOPLEFT", barColorDropdown, "BOTTOMLEFT", 0, -30)
    lossColorDropdown:SetItems({
        {
            ["text"] = L["Class Color"],
            ["onClick"] = function()
                CellDB["appearance"]["lossColor"][1] = "Class Color"
                Cell:Fire("UpdateAppearance", "color")
            end,
        },
        {
            ["text"] = L["Class Color (dark)"],
            ["onClick"] = function()
                CellDB["appearance"]["lossColor"][1] = "Class Color (dark)"
                Cell:Fire("UpdateAppearance", "color")
            end,
        },
        {
            ["text"] = L["Gradient"],
            ["onClick"] = function()
                CellDB["appearance"]["lossColor"][1] = "Gradient"
                Cell:Fire("UpdateAppearance", "color")
            end,
        },
        {
            ["text"] = L["Custom Color"],
            ["onClick"] = function()
                CellDB["appearance"]["lossColor"][1] = "Custom Color"
                Cell:Fire("UpdateAppearance", "color")
            end,
        },
    })
    
    local lossColorText = unitButtonPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    lossColorText:SetPoint("BOTTOMLEFT", lossColorDropdown, "TOPLEFT", 0, 1)
    lossColorText:SetText(L["Health Loss Color"])
    
    lossColorPicker = Cell:CreateColorPicker(unitButtonPane, "", false, function(r, g, b)
        CellDB["appearance"]["lossColor"][2][1] = r
        CellDB["appearance"]["lossColor"][2][2] = g
        CellDB["appearance"]["lossColor"][2][3] = b
        if CellDB["appearance"]["lossColor"][1] == "Custom Color" then
            Cell:Fire("UpdateAppearance", "color")
        end
    end)
    lossColorPicker:SetPoint("LEFT", lossColorDropdown, "RIGHT", 5, 0)
    
    -- power color
    powerColorDropdown = Cell:CreateDropdown(unitButtonPane, 141)
    powerColorDropdown:SetPoint("TOPLEFT", lossColorDropdown, "BOTTOMLEFT", 0, -30)
    powerColorDropdown:SetItems({
        {
            ["text"] = L["Power Color"],
            ["onClick"] = function()
                CellDB["appearance"]["powerColor"][1] = "Power Color"
                Cell:Fire("UpdateAppearance", "color")
            end,
        },
        {
            ["text"] = L["Power Color (dark)"],
            ["onClick"] = function()
                CellDB["appearance"]["powerColor"][1] = "Power Color (dark)"
                Cell:Fire("UpdateAppearance", "color")
            end,
        },
        {
            ["text"] = L["Class Color"],
            ["onClick"] = function()
                CellDB["appearance"]["powerColor"][1] = "Class Color"
                Cell:Fire("UpdateAppearance", "color")
            end,
        },
        {
            ["text"] = L["Custom Color"],
            ["onClick"] = function()
                CellDB["appearance"]["powerColor"][1] = "Custom Color"
                Cell:Fire("UpdateAppearance", "color")
            end,
        },
    })
    
    local powerColorText = unitButtonPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    powerColorText:SetPoint("BOTTOMLEFT", powerColorDropdown, "TOPLEFT", 0, 1)
    powerColorText:SetText(L["Power Color"])
    
    powerColorPicker = Cell:CreateColorPicker(unitButtonPane, "", false, function(r, g, b)
        CellDB["appearance"]["powerColor"][2][1] = r
        CellDB["appearance"]["powerColor"][2][2] = g
        CellDB["appearance"]["powerColor"][2][3] = b
        if CellDB["appearance"]["powerColor"][1] == "Custom Color" then
            Cell:Fire("UpdateAppearance", "color")
        end
    end)
    powerColorPicker:SetPoint("LEFT", powerColorDropdown, "RIGHT", 5, 0)
    
    -- bar animation
    barAnimationDropdown = Cell:CreateDropdown(unitButtonPane, 141)
    barAnimationDropdown:SetPoint("TOPLEFT", powerColorDropdown, "BOTTOMLEFT", 0, -30)
    barAnimationDropdown:SetItems({
        {
            ["text"] = L["Flash"],
            ["onClick"] = function()
                CellDB["appearance"]["barAnimation"] = "Flash"
                Cell:Fire("UpdateAppearance", "animation")
            end,
        },
        {
            ["text"] = L["Smooth"],
            ["onClick"] = function()
                CellDB["appearance"]["barAnimation"] = "Smooth"
                Cell:Fire("UpdateAppearance", "animation")
            end,
        },
        {
            ["text"] = L["None"],
            ["onClick"] = function()
                CellDB["appearance"]["barAnimation"] = "None"
                Cell:Fire("UpdateAppearance", "animation")
            end,
        },
    })
    
    local barAnimationText = unitButtonPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    barAnimationText:SetPoint("BOTTOMLEFT", barAnimationDropdown, "TOPLEFT", 0, 1)
    barAnimationText:SetText(L["Bar Animation"])
    
    -- target highlight
    targetColorPicker = Cell:CreateColorPicker(unitButtonPane, L["Target Highlight Color"], true, function(r, g, b, a)
        CellDB["appearance"]["targetColor"][1] = r
        CellDB["appearance"]["targetColor"][2] = g
        CellDB["appearance"]["targetColor"][3] = b
        CellDB["appearance"]["targetColor"][4] = a
        Cell:Fire("UpdateAppearance", "highlightColor")
    end)
    targetColorPicker:SetPoint("TOPLEFT", barAnimationDropdown, "BOTTOMLEFT", 0, -15)
    
    -- mouseover highlight
    mouseoverColorPicker = Cell:CreateColorPicker(unitButtonPane, L["Mouseover Highlight Color"], true, function(r, g, b, a)
        CellDB["appearance"]["mouseoverColor"][1] = r
        CellDB["appearance"]["mouseoverColor"][2] = g
        CellDB["appearance"]["mouseoverColor"][3] = b
        CellDB["appearance"]["mouseoverColor"][4] = a
        Cell:Fire("UpdateAppearance", "highlightColor")
    end)
    mouseoverColorPicker:SetPoint("TOPLEFT", targetColorPicker, "BOTTOMLEFT", 0, -10)
    
    -- highlight size
    highlightSize = Cell:CreateSlider(L["Highlight Size"], unitButtonPane, -5, 5, 141, 1)
    highlightSize:SetPoint("TOPLEFT", mouseoverColorPicker, "BOTTOMLEFT", 0, -25)
    highlightSize.afterValueChangedFn = function(value)
        CellDB["appearance"]["highlightSize"] = value
        Cell:Fire("UpdateAppearance", "highlightSize")
    end
    
    -- icon animation
    iconAnimationDropdown = Cell:CreateDropdown(unitButtonPane, 160)
    iconAnimationDropdown:SetPoint("TOPLEFT", unitButtonPane, "TOPLEFT", 222, -42)
    iconAnimationDropdown:SetItems({
        {
            ["text"] = L["+ Stack & Duration"],
            ["value"] = "duration",
            ["onClick"] = function()
                CellDB["appearance"]["iconAnimation"] = "duration"
    
            end,
        },
        {
            ["text"] = L["+ Stack"],
            ["value"] = "stack",
            ["onClick"] = function()
                CellDB["appearance"]["iconAnimation"] = "stack"
            end,
        },
        {
            ["text"] = L["Never"],
            ["value"] = "never",
            ["onClick"] = function()
                CellDB["appearance"]["iconAnimation"] = "never"
            end,
        },
    })
    
    local iconAnimationText = unitButtonPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    iconAnimationText:SetPoint("BOTTOMLEFT", iconAnimationDropdown, "TOPLEFT", 0, 1)
    iconAnimationText:SetText(L["Play Icon Animation When"])
    
    -- bar alpha
    barAlpha = Cell:CreateSlider(L["Health Bar Alpha"], unitButtonPane, 0, 100, 141, 5, function(value)
        CellDB["appearance"]["barAlpha"] = value/100
        Cell:Fire("UpdateAppearance", "alpha")
    end, nil, true)
    barAlpha:SetPoint("TOPLEFT", iconAnimationDropdown, "BOTTOMLEFT", 0, -30)
    
    -- loss alpha
    lossAlpha = Cell:CreateSlider(L["Health Loss Alpha"], unitButtonPane, 0, 100, 141, 5, function(value)
        CellDB["appearance"]["lossAlpha"] = value/100
        Cell:Fire("UpdateAppearance", "alpha")
    end, nil, true)
    lossAlpha:SetPoint("TOPLEFT", barAlpha, "BOTTOMLEFT", 0, -40)
    
    -- bg alpha
    bgAlpha = Cell:CreateSlider(L["Background Alpha"], unitButtonPane, 0, 100, 141, 5, function(value)
        CellDB["appearance"]["bgAlpha"] = value/100
        Cell:Fire("UpdateAppearance", "alpha")
    end, nil, true)
    bgAlpha:SetPoint("TOPLEFT", lossAlpha, "BOTTOMLEFT", 0, -40)
    
    -- out of range alpha
    oorAlpha = Cell:CreateSlider(L["Out of Range Alpha"], unitButtonPane, 0, 100, 141, 5, function(value)
        CellDB["appearance"]["outOfRangeAlpha"] = value/100
        Cell:Fire("UpdateAppearance", "outOfRangeAlpha")
    end, nil, true)
    oorAlpha:SetPoint("TOPLEFT", bgAlpha, "BOTTOMLEFT", 0, -40)
    
    -- heal prediction
    predCB = Cell:CreateCheckButton(unitButtonPane, L["Heal Prediction"], function(checked, self)
        CellDB["appearance"]["healPrediction"] = checked
        Cell:Fire("UpdateAppearance", "shields")
    end)
    predCB:SetPoint("TOPLEFT", oorAlpha, "BOTTOMLEFT", 0, -35)
    
    -- heal absorb
    absorbCB = Cell:CreateCheckButton(unitButtonPane, L["Heal Absorb"], function(checked, self)
        CellDB["appearance"]["healAbsorb"] = checked
        Cell:Fire("UpdateAppearance", "shields")
    end)
    absorbCB:SetPoint("TOPLEFT", predCB, "BOTTOMLEFT", 0, -7)
    
    -- shield
    shieldCB = Cell:CreateCheckButton(unitButtonPane, L["Shield Texture"], function(checked, self)
        CellDB["appearance"]["shield"] = checked
        Cell:Fire("UpdateAppearance", "shields")
    end)
    shieldCB:SetPoint("TOPLEFT", absorbCB, "BOTTOMLEFT", 0, -7)
    
    -- overshield
    oversCB = Cell:CreateCheckButton(unitButtonPane, L["Overshield Texture"], function(checked, self)
        CellDB["appearance"]["overshield"] = checked
        Cell:Fire("UpdateAppearance", "shields")
    end)
    oversCB:SetPoint("TOPLEFT", shieldCB, "BOTTOMLEFT", 0, -7)
    
    
    -- reset
    resetBtn = Cell:CreateButton(unitButtonPane, L["Reset All"], "class", {77, 17}, nil, nil, nil, nil, nil, L["Reset All"], L["[Ctrl+LeftClick] to reset these settings"])
    resetBtn:SetPoint("TOPRIGHT")
    resetBtn:SetScript("OnClick", function()
        if IsControlKeyDown() then
            CellDB["appearance"]["texture"] = "Cell ".._G.DEFAULT
            CellDB["appearance"]["barColor"] = {"Class Color", {.2, .2, .2}}
            CellDB["appearance"]["lossColor"] = {"Class Color (dark)", {.667, 0, 0}}
            CellDB["appearance"]["barAlpha"] = 1
            CellDB["appearance"]["lossAlpha"] = 1
            CellDB["appearance"]["bgAlpha"] = 1
            CellDB["appearance"]["powerColor"] = {"Power Color", {.7, .7, .7}}
            CellDB["appearance"]["barAnimation"] = "Flash"
            CellDB["appearance"]["iconAnimation"] = "duration"
            CellDB["appearance"]["targetColor"] = {1, .31, .31, 1}
            CellDB["appearance"]["mouseoverColor"] = {1, 1, 1, .6}
            CellDB["appearance"]["highlightSize"] = 1
            CellDB["appearance"]["outOfRangeAlpha"] = .45
            CellDB["appearance"]["healPrediction"] = true
            CellDB["appearance"]["healAbsorb"] = true
            CellDB["appearance"]["shield"] = true
            CellDB["appearance"]["overshield"] = true
    
            textureDropdown:SetSelected("Cell ".._G.DEFAULT, "Interface\\AddOns\\Cell\\Media\\statusbar.tga")
    
            barColorDropdown:SetSelected(L["Class Color"])
            barColorPicker:SetColor({.2, .2, .2})
    
            lossColorDropdown:SetSelected(L["Class Color (dark)"])
            lossColorPicker:SetColor({.667, 0, 0})
    
            powerColorDropdown:SetSelected(L["Power Color"])
            powerColorPicker:SetColor({.7, .7, .7})
    
            barAnimationDropdown:SetSelected(L["Flash"])
            iconAnimationDropdown:SetSelectedValue("duration")
    
            targetColorPicker:SetColor({1, .31, .31, 1})
            mouseoverColorPicker:SetColor({1, 1, 1, .6})
            highlightSize:SetValue(1)
            oorAlpha:SetValue(45)
            barAlpha:SetValue(100)
            lossAlpha:SetValue(100)
            bgAlpha:SetValue(100)
    
            predCB:SetChecked(true)
            absorbCB:SetChecked(true)
            shieldCB:SetChecked(true)
            oversCB:SetChecked(true)
    
            Cell:Fire("UpdateAppearance")
        end
    end)
    Cell:RegisterForCloseDropdown(resetBtn) -- close dropdown
end

-------------------------------------------------
-- functions
-------------------------------------------------
local init
local function ShowTab(tab)
    if tab == "appearance" then
        if not init then
            CreatePreviewButtons()
            CreateScalePane()
            CreateFontPane()
            CreateUnitButtonStylePane()
        end

        appearanceTab:Show()
        
        if init then return end
        init = true

        UpdatePreviewButton()

        -- load data
        scaleSlider:SetValue(CellDB["appearance"]["scale"])
        optionsFontSizeOffset:SetValue(CellDB["appearance"]["optionsFontSizeOffset"])
        useGameFontCB:SetChecked(CellDB["appearance"]["useGameFont"])
        
        CheckTextures()
        barColorDropdown:SetSelected(L[CellDB["appearance"]["barColor"][1]])
        barColorPicker:SetColor(CellDB["appearance"]["barColor"][2])

        lossColorDropdown:SetSelected(L[CellDB["appearance"]["lossColor"][1]])
        lossColorPicker:SetColor(CellDB["appearance"]["lossColor"][2])

        powerColorDropdown:SetSelected(L[CellDB["appearance"]["powerColor"][1]])
        powerColorPicker:SetColor(CellDB["appearance"]["powerColor"][2])

        barAnimationDropdown:SetSelected(L[CellDB["appearance"]["barAnimation"]])
        iconAnimationDropdown:SetSelectedValue(CellDB["appearance"]["iconAnimation"])

        targetColorPicker:SetColor(CellDB["appearance"]["targetColor"])
        mouseoverColorPicker:SetColor(CellDB["appearance"]["mouseoverColor"])
        highlightSize:SetValue(CellDB["appearance"]["highlightSize"])
        oorAlpha:SetValue(CellDB["appearance"]["outOfRangeAlpha"]*100)
        barAlpha:SetValue(CellDB["appearance"]["barAlpha"]*100)
        lossAlpha:SetValue(CellDB["appearance"]["lossAlpha"]*100)
        bgAlpha:SetValue(CellDB["appearance"]["bgAlpha"]*100)

        predCB:SetChecked(CellDB["appearance"]["healPrediction"])
        absorbCB:SetChecked(CellDB["appearance"]["healAbsorb"])
        shieldCB:SetChecked(CellDB["appearance"]["shield"])
        oversCB:SetChecked(CellDB["appearance"]["overshield"])
    else
        appearanceTab:Hide()
    end
end
Cell:RegisterCallback("ShowOptionsTab", "AppearanceTab_ShowTab", ShowTab)

local function UpdateLayout()
    if init and previewButton.loaded then
        UpdatePreviewButton()
    end
end
Cell:RegisterCallback("UpdateLayout", "AppearanceTab_UpdateLayout", UpdateLayout)

-------------------------------------------------
-- update appearance
-------------------------------------------------
local function UpdateAppearance(which)
    F:Debug("|cff7f7fffUpdateAppearance:|r "..(which or "all"))
    
    if not which or which == "texture" or which == "color" or which == "alpha" or which == "outOfRangeAlpha" or which == "shields" or which == "animation" or which == "highlightColor" or which == "highlightSize" then
        local tex
        if not which or which == "texture" then tex = F:GetBarTexture() end

        F:IterateAllUnitButtons(function(b)
            -- texture
            if not which or which == "texture" then
                b.func.SetTexture(tex)
            end
            -- color
            if not which or which == "color" or which == "alpha" then
                b.func.UpdateColor()
            end
            -- outOfRangeAlpha
            if which == "outOfRangeAlpha" then
                b.state.wasInRange = nil
            end
            -- shields
            if not which or which == "shields" then
                b.func.UpdateShields()
            end
            -- animation
            if not which or which == "animation" then
                b.func.UpdateAnimation()
            end
            -- highlightColor
            if not which or which == "highlightColor" then
                b.func.UpdateHighlightColor()
            end
            -- highlightColor
            if not which or which == "highlightSize" then
                b.func.UpdateHighlightSize()
            end
        end)
    end

    -- scale
    if not which or which == "scale" then
        P:SetRelativeScale(CellDB["appearance"]["scale"])
        P:SetEffectiveScale(Cell.frames.mainFrame)
        if Cell.frames.changeLogsFrame then P:SetEffectiveScale(Cell.frames.changeLogsFrame) end
        P:SetEffectiveScale(CellTooltip)
        P:SetEffectiveScale(CellScanningTooltip)
        CellTooltip:UpdatePixelPerfect()
        CellScanningTooltip:UpdatePixelPerfect()
    end

    -- preview
    if init and previewButton:IsVisible() then
        UpdatePreviewButton()
    end
end
Cell:RegisterCallback("UpdateAppearance", "UpdateAppearance", UpdateAppearance)