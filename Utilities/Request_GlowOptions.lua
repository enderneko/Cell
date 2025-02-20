local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local B = Cell.bFuncs
local U = Cell.uFuncs
local P = Cell.pixelPerfectFuncs

local LCG = LibStub("LibCustomGlow-1.0")

local glowOptionsTable
local glowOptionsFrame, previewButton

--------------------------------------------------
-- glow preview
--------------------------------------------------
local function CreatePreviewButton()
    previewButton = CreateFrame("Button", "CellGlowsPreviewButton", glowOptionsFrame, "CellPreviewButtonTemplate")
    -- previewButton.type = "main" -- layout setup
    previewButton:SetPoint("BOTTOMLEFT", glowOptionsFrame, "TOPLEFT", 0, 5)
    previewButton:UnregisterAllEvents()
    previewButton:SetScript("OnEnter", nil)
    previewButton:SetScript("OnLeave", nil)
    previewButton:SetScript("OnShow", nil)
    previewButton:SetScript("OnHide", nil)
    previewButton:SetScript("OnUpdate", nil)

    previewButton.widgets.healthBar:SetMinMaxValues(0, 1)
    previewButton.widgets.healthBar:SetValue(1)
    previewButton.widgets.powerBar:SetMinMaxValues(0, 1)
    previewButton.widgets.powerBar:SetValue(1)

    local previewButtonBG = Cell.CreateFrame("CellGlowsPreviewButtonBG", previewButton)
    previewButtonBG:SetPoint("TOPLEFT", previewButton, 0, 20)
    previewButtonBG:SetPoint("BOTTOMRIGHT", previewButton, "TOPRIGHT")
    Cell.StylizeFrame(previewButtonBG, {0.1, 0.1, 0.1, 0.77}, {0, 0, 0, 0})
    previewButtonBG:Show()

    local previewText = previewButtonBG:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET_TITLE")
    previewText:SetPoint("TOP", 0, -3)
    previewText:SetText(Cell.GetAccentColorString()..L["Preview"])

    Cell.Fire("CreatePreview", previewButton)
end

local function UpdatePreviewButton()
    if not previewButton then
        CreatePreviewButton()
    end

    local iTable = Cell.vars.currentLayoutTable["indicators"][1]
    if iTable["enabled"] then
        previewButton.indicators.nameText:Show()
        previewButton.states.name = UnitName("player")
        previewButton.indicators.nameText:UpdateName()
        previewButton.indicators.nameText:UpdatePreviewColor(iTable["color"])
        previewButton.indicators.nameText:UpdateTextWidth(iTable["textWidth"])
        previewButton.indicators.nameText:SetFont(unpack(iTable["font"]))
        previewButton.indicators.nameText:ClearAllPoints()
        previewButton.indicators.nameText:SetPoint(unpack(iTable["position"]))
    else
        previewButton.indicators.nameText:Hide()
    end

    P.Size(previewButton, Cell.vars.currentLayoutTable["main"]["size"][1], Cell.vars.currentLayoutTable["main"]["size"][2])
    B.SetOrientation(previewButton, Cell.vars.currentLayoutTable["barOrientation"][1], Cell.vars.currentLayoutTable["barOrientation"][2])
    B.SetPowerSize(previewButton, Cell.vars.currentLayoutTable["main"]["powerSize"])

    previewButton.widgets.healthBar:SetStatusBarTexture(Cell.vars.texture)
    previewButton.widgets.powerBar:SetStatusBarTexture(Cell.vars.texture)

    -- health color
    local r, g, b = F.GetHealthBarColor(1, false, F.GetClassColor(Cell.vars.playerClass))
    previewButton.widgets.healthBar:SetStatusBarColor(r, g, b, CellDB["appearance"]["barAlpha"])

    -- power color
    r, g, b = F.GetPowerBarColor("player", Cell.vars.playerClass)
    previewButton.widgets.powerBar:SetStatusBarColor(r, g, b)

    -- alpha
    previewButton:SetBackdropColor(0, 0, 0, CellDB["appearance"]["bgAlpha"])

    previewButton:Show()

    Cell.Fire("UpdatePreview", previewButton)
end

-------------------------------------------------
-- glow options
-------------------------------------------------
local glowTypeDropdown, glowColor, glowLines, glowParticles, glowDuration, glowFrequency, glowLength, glowThickness, glowScale, glowOffsetX, glowOffsetY

local function UpdateGlowPreview(refresh)
    local glowType, glowOptions = unpack(glowOptionsTable)

    if glowType == "normal" then
        LCG.PixelGlow_Stop(previewButton)
        LCG.AutoCastGlow_Stop(previewButton)
        LCG.ProcGlow_Stop(previewButton)
        LCG.ButtonGlow_Start(previewButton, glowOptions[1])
    elseif glowType == "pixel" then
        LCG.ButtonGlow_Stop(previewButton)
        LCG.AutoCastGlow_Stop(previewButton)
        LCG.ProcGlow_Stop(previewButton)
        -- color, N, frequency, length, thickness, x, y
        LCG.PixelGlow_Start(previewButton, glowOptions[1], glowOptions[4], glowOptions[5], glowOptions[6], glowOptions[7], glowOptions[2], glowOptions[3])
    elseif glowType == "shine" then
        LCG.ButtonGlow_Stop(previewButton)
        LCG.PixelGlow_Stop(previewButton)
        LCG.ProcGlow_Stop(previewButton)
        if refresh then LCG.AutoCastGlow_Stop(previewButton) end
        -- color, N, frequency, scale, x, y
        LCG.AutoCastGlow_Start(previewButton, glowOptions[1], glowOptions[4], glowOptions[5], glowOptions[6], glowOptions[2], glowOptions[3])
    elseif glowType == "proc" then
        LCG.ButtonGlow_Stop(previewButton)
        LCG.PixelGlow_Stop(previewButton)
        LCG.AutoCastGlow_Stop(previewButton)
        -- color, duration
        LCG.ProcGlow_Start(previewButton, {color=glowOptions[1], xOffset=glowOptions[2], yOffset=glowOptions[3], duration=glowOptions[4], startAnim=false})
    end
end

local function LoadGlowOptions()
    UpdateGlowPreview()

    local glowType, glowOptions = unpack(glowOptionsTable)
    glowTypeDropdown:SetSelectedValue(glowType)
    glowColor:SetColor(glowOptions[1])

    glowOffsetX:SetEnabled(glowType ~= "normal")
    glowOffsetY:SetEnabled(glowType ~= "normal")
    glowLines:SetEnabled(glowType ~= "normal")
    glowFrequency:SetEnabled(glowType ~= "normal")
    glowLength:SetEnabled(glowType ~= "normal")
    glowThickness:SetEnabled(glowType ~= "normal")

    if glowType == "normal" then
        glowLines:Show()
        glowFrequency:Show()
        glowLength:Show()
        glowThickness:Show()

        glowParticles:Hide()
        glowDuration:Hide()
        glowScale:Hide()

    elseif glowType == "pixel" then
        glowLines:Show()
        glowFrequency:Show()
        glowLength:Show()
        glowThickness:Show()

        glowParticles:Hide()
        glowDuration:Hide()
        glowScale:Hide()

        glowOffsetX:SetValue(glowOptions[2])
        glowOffsetY:SetValue(glowOptions[3])
        glowLines:SetValue(glowOptions[4])
        glowFrequency:SetValue(glowOptions[5])
        glowLength:SetValue(glowOptions[6])
        glowThickness:SetValue(glowOptions[7])

    elseif glowType == "shine" then
        glowParticles:Show()
        glowFrequency:Show()
        glowScale:Show()

        glowLines:Hide()
        glowDuration:Hide()
        glowLength:Hide()
        glowThickness:Hide()

        glowOffsetX:SetValue(glowOptions[2])
        glowOffsetY:SetValue(glowOptions[3])
        glowParticles:SetValue(glowOptions[4])
        glowFrequency:SetValue(glowOptions[5])
        glowScale:SetValue(glowOptions[6]*100)

    elseif glowType == "proc" then
        glowDuration:Show()

        glowLines:Hide()
        glowParticles:Hide()
        glowFrequency:Hide()
        glowLength:Hide()
        glowThickness:Hide()
        glowScale:Hide()

        glowOffsetX:SetValue(glowOptions[2])
        glowOffsetY:SetValue(glowOptions[3])
        glowDuration:SetValue(glowOptions[4])
    end
end

local function UpdateGlowType(glowType)
    glowOptionsTable[1] = glowType

    if glowType == "normal" then
        glowOptionsTable[2] = {glowOptionsTable[2][1]}
    elseif glowType == "pixel" then
        glowOptionsTable[2] = {glowOptionsTable[2][1], 0, 0, 9, 0.25, 8, 2}
    elseif glowType == "shine" then
        glowOptionsTable[2] = {glowOptionsTable[2][1], 0, 0, 9, 0.5, 1}
    elseif glowType == "proc" then
        glowOptionsTable[2] = {glowOptionsTable[2][1], 0, 0, 1}
    end

    LoadGlowOptions()
end

local function SliderValueChanged(index, value, refresh)
    -- update db
    glowOptionsTable[2][index] = value
    -- update preview
    UpdateGlowPreview(refresh)
end

local function CreateGlowOptionsFrame()
    glowOptionsFrame = Cell.CreateFrame("CellOptionsFrame_GlowOptions", Cell.frames.optionsFrame, 127, 371)
    glowOptionsFrame:SetPoint("BOTTOMLEFT", Cell.frames.optionsFrame, "BOTTOMRIGHT", 5, 0)

    local glowTypeText = glowOptionsFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    glowTypeText:SetText(L["Glow Type"])
    glowTypeText:SetPoint("TOPLEFT", 5, -5)

    glowTypeDropdown = Cell.CreateDropdown(glowOptionsFrame, 117)
    glowTypeDropdown:SetPoint("TOPLEFT", 5, -22)
    glowTypeDropdown:SetItems({
        {
            ["text"] = L["Normal"],
            ["value"] = "normal",
            ["onClick"] = function()
                UpdateGlowType("normal")
            end,
        },
        {
            ["text"] = L["Pixel"],
            ["value"] = "pixel",
            ["onClick"] = function()
                UpdateGlowType("pixel")
            end,
        },
        {
            ["text"] = L["Shine"],
            ["value"] = "shine",
            ["onClick"] = function()
                UpdateGlowType("shine")
            end,
        },
        {
            ["text"] = L["Proc"],
            ["value"] = "proc",
            ["onClick"] = function()
                UpdateGlowType("proc")
            end,
        },
    })

    -- glowColor
    glowColor = Cell.CreateColorPicker(glowOptionsFrame, L["Glow Color"], false, function(r, g, b)
        -- update db
        glowOptionsTable[2][1][1] = r
        glowOptionsTable[2][1][2] = g
        glowOptionsTable[2][1][3] = b
        glowOptionsTable[2][1][4] = 1
        -- update preview
        UpdateGlowPreview()
    end)
    -- glowColor:SetPoint("TOPLEFT", glowOptionsFrame, 5, 0)
    glowColor:SetPoint("TOPLEFT", glowTypeDropdown, "BOTTOMLEFT", 0, -10)

    -- x
    glowOffsetX = Cell.CreateSlider(L["X Offset"], glowOptionsFrame, -100, 100, 117, 1, function(value)
        SliderValueChanged(2, value)
    end)
    glowOffsetX:SetPoint("TOPLEFT", glowColor, "BOTTOMLEFT", 0, -25)

    -- y
    glowOffsetY = Cell.CreateSlider(L["Y Offset"], glowOptionsFrame, -100, 100, 117, 1, function(value)
        SliderValueChanged(3, value)
    end)
    glowOffsetY:SetPoint("TOPLEFT", glowOffsetX, "BOTTOMLEFT", 0, -40)

    -- glowNumber
    glowLines = Cell.CreateSlider(L["Lines"], glowOptionsFrame, 1, 30, 117, 1, function(value)
        SliderValueChanged(4, value)
    end)
    glowLines:SetPoint("TOPLEFT", glowOffsetY, "BOTTOMLEFT", 0, -40)

    glowParticles = Cell.CreateSlider(L["Particles"], glowOptionsFrame, 1, 30, 117, 1, function(value)
        SliderValueChanged(4, value, true)
    end)
    glowParticles:SetPoint("TOPLEFT", glowOffsetY, "BOTTOMLEFT", 0, -40)

    -- duration
    glowDuration = Cell.CreateSlider(L["Duration"], glowOptionsFrame, 0.1, 3, 117, 0.1, function(value)
        SliderValueChanged(4, value, true)
    end)
    glowDuration:SetPoint("TOPLEFT", glowOffsetY, "BOTTOMLEFT", 0, -40)

    -- glowFrequency
    glowFrequency = Cell.CreateSlider(L["Frequency"], glowOptionsFrame, -2, 2, 117, 0.01, function(value)
        SliderValueChanged(5, value)
    end)
    glowFrequency:SetPoint("TOPLEFT", glowLines, "BOTTOMLEFT", 0, -40)

    -- glowLength
    glowLength = Cell.CreateSlider(L["Length"], glowOptionsFrame, 1, 20, 117, 1, function(value)
        SliderValueChanged(6, value)
    end)
    glowLength:SetPoint("TOPLEFT", glowFrequency, "BOTTOMLEFT", 0, -40)

    -- glowThickness
    glowThickness = Cell.CreateSlider(L["Thickness"], glowOptionsFrame, 1, 20, 117, 1, function(value)
        SliderValueChanged(7, value)
    end)
    glowThickness:SetPoint("TOPLEFT", glowLength, "BOTTOMLEFT", 0, -40)

    -- glowScale
    glowScale = Cell.CreateSlider(L["Scale"], glowOptionsFrame, 50, 500, 117, 1, function(value)
        SliderValueChanged(6, value/100)
    end, nil, true)
    glowScale:SetPoint("TOPLEFT", glowFrequency, "BOTTOMLEFT", 0, -40)

    glowOptionsFrame:SetScript("OnHide", function()
        glowOptionsFrame:Hide()
    end)
end

-------------------------------------------------
-- functions
-------------------------------------------------
function U.ShowGlowOptions(parent, t)
    if not glowOptionsFrame then
        CreateGlowOptionsFrame()
    end

    if glowOptionsFrame:IsShown() then
        glowOptionsFrame:Hide()
    else
        glowOptionsFrame:SetParent(parent)
        glowOptionsTable = t
        UpdatePreviewButton()
        LoadGlowOptions()
        glowOptionsFrame:Show()
    end
end

function U.HideGlowOptions()
    if glowOptionsFrame then glowOptionsFrame:Hide() end
end

-------------------------------------------------
-- callbacks
-------------------------------------------------
local function UpdateLayout()
    if previewButton then
        UpdatePreviewButton()
    end
end
Cell.RegisterCallback("UpdateLayout", "GlowOptions_UpdateLayout", UpdateLayout)

local function UpdateAppearance()
    if previewButton then
        UpdatePreviewButton()
    end
end
Cell.RegisterCallback("UpdateAppearance", "GlowOptions_UpdateAppearance", UpdateAppearance)