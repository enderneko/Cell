local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local B = Cell.bFuncs
local U = Cell.uFuncs
local P = Cell.pixelPerfectFuncs

local textOptionsFrame, previewButton

--------------------------------------------------
-- icon preview
--------------------------------------------------
local function CreatePreviewButton()
    previewButton = CreateFrame("Button", "CellTextPreviewButton", textOptionsFrame, "CellPreviewButtonTemplate")
    -- previewButton.type = "main" -- layout setup
    previewButton:SetPoint("BOTTOMLEFT", textOptionsFrame, "TOPLEFT", 0, 5)
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
    
    local previewButtonBG = Cell:CreateFrame("CellTextPreviewButton", previewButton)
    previewButtonBG:SetPoint("TOPLEFT", previewButton, 0, 20)
    previewButtonBG:SetPoint("BOTTOMRIGHT", previewButton, "TOPRIGHT")
    Cell:StylizeFrame(previewButtonBG, {0.1, 0.1, 0.1, 0.77}, {0, 0, 0, 0})
    previewButtonBG:Show()
    
    local previewText = previewButtonBG:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET_TITLE")
    previewText:SetPoint("TOP", 0, -3)
    previewText:SetText(Cell:GetAccentColorString()..L["Preview"])

    Cell:Fire("CreatePreview", previewButton)
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

    P:Size(previewButton, Cell.vars.currentLayoutTable["main"]["size"][1], Cell.vars.currentLayoutTable["main"]["size"][2])
    B:SetOrientation(previewButton, Cell.vars.currentLayoutTable["barOrientation"][1], Cell.vars.currentLayoutTable["barOrientation"][2])
    B:SetPowerSize(previewButton, Cell.vars.currentLayoutTable["main"]["powerSize"])

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

    previewButton:Show()

    Cell:Fire("UpdatePreview", previewButton)
end

Cell:RegisterCallback("UpdateLayout", "TextOptions_UpdateLayout", function()
    if previewButton then
        UpdatePreviewButton()
    end
end)

Cell:RegisterCallback("UpdateAppearance", "TextOptions_UpdateAppearance", function()
    if previewButton then
        UpdatePreviewButton()
    end
end)

-------------------------------------------------
-- text options
-------------------------------------------------
local textType, textAnchor, textAnchorTo, textColor, size, xOffset, yOffset

local function UpdateTextPreview()
    local setting = CellDB["dispelRequest"]["textOptions"]
    previewButton.widgets.drText:SetType(setting[1])
    previewButton.widgets.drText:SetColor(setting[2])
    P:Size(previewButton.widgets.drText, setting[3] * 2, setting[3])
    P:ClearPoints(previewButton.widgets.drText)
    P:Point(previewButton.widgets.drText, setting[4], previewButton.widgets.drGlowFrame, setting[5], setting[6], setting[7])
    previewButton.widgets.drText:Display()
end

local function LoadTextOptions()
    UpdateTextPreview()

    textType:SetSelected(CellDB["dispelRequest"]["textOptions"][1])
    textColor:SetColor(unpack(CellDB["dispelRequest"]["textOptions"][2]))
    size:SetValue(CellDB["dispelRequest"]["textOptions"][3])
    textAnchor:SetSelectedValue(CellDB["dispelRequest"]["textOptions"][4])
    textAnchorTo:SetSelectedValue(CellDB["dispelRequest"]["textOptions"][5])
    xOffset:SetValue(CellDB["dispelRequest"]["textOptions"][6])
    yOffset:SetValue(CellDB["dispelRequest"]["textOptions"][7])
end

local function CreateTextOptionsFrame()
    textOptionsFrame = Cell:CreateFrame("CellOptionsFrame_TextOptions", textOptionsFrame, 127, 325)
    textOptionsFrame:SetPoint("BOTTOMLEFT", Cell.frames.optionsFrame, "BOTTOMRIGHT", 5, 0)

    -- textType
    textType = Cell:CreateDropdown(textOptionsFrame, 117)
    textType:SetPoint("TOPLEFT", 5, -20)
    textType:SetItems({
        {
            ["text"] = "A",
            ["onClick"] = function()
                CellDB["dispelRequest"]["textOptions"][1] = "A"
                UpdateTextPreview()
                Cell:Fire("UpdateRequests", "dispelRequest_text")
            end
        },
        {
            ["text"] = "B",
            ["onClick"] = function()
                CellDB["dispelRequest"]["textOptions"][1] = "B"
                UpdateTextPreview()
                Cell:Fire("UpdateRequests", "dispelRequest_text")
            end
        },
        {
            ["text"] = "C",
            ["onClick"] = function()
                CellDB["dispelRequest"]["textOptions"][1] = "C"
                UpdateTextPreview()
                Cell:Fire("UpdateRequests", "dispelRequest_text")
            end
        },
    })

    local textTypeText = textOptionsFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    textTypeText:SetText(L["Type"])
    textTypeText:SetPoint("BOTTOMLEFT", textType, "TOPLEFT", 0, 1)

    -- textColor
    textColor = Cell:CreateColorPicker(textOptionsFrame, L["Color"], false, function(r, g, b)
        -- update db
        CellDB["dispelRequest"]["textOptions"][2][1] = r
        CellDB["dispelRequest"]["textOptions"][2][2] = g
        CellDB["dispelRequest"]["textOptions"][2][3] = b
        CellDB["dispelRequest"]["textOptions"][2][4] = 1
        UpdateTextPreview()
        Cell:Fire("UpdateRequests", "dispelRequest_text")
    end)
    textColor:SetPoint("TOPLEFT", textType, "BOTTOMLEFT", 0, -10)

    -- size
    size = Cell:CreateSlider(L["Size"], textOptionsFrame, 8, 64, 117, 1, function(value)
        CellDB["dispelRequest"]["textOptions"][3] = value
        UpdateTextPreview()
        Cell:Fire("UpdateRequests", "dispelRequest_text")
    end)
    size:SetPoint("TOPLEFT", textColor, "BOTTOMLEFT", 0, -30)

    -- anchor
    local anchorPoints = {"BOTTOM", "BOTTOMLEFT", "BOTTOMRIGHT", "CENTER", "LEFT", "RIGHT", "TOP", "TOPLEFT", "TOPRIGHT"}
    textAnchor = Cell:CreateDropdown(textOptionsFrame, 117)
    textAnchor:SetPoint("TOPLEFT", size, "BOTTOMLEFT", 0, -40)
    local items = {}
    for _, point in pairs(anchorPoints) do
        tinsert(items, {
            ["text"] = L[point],
            ["value"] = point,
            ["onClick"] = function()
                CellDB["dispelRequest"]["textOptions"][4] = point
                UpdateTextPreview()
                Cell:Fire("UpdateRequests", "dispelRequest_text")
            end,
        })
    end
    textAnchor:SetItems(items)

    local textAnchorText = textOptionsFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    textAnchorText:SetText(L["Anchor Point"])
    textAnchorText:SetPoint("BOTTOMLEFT", textAnchor, "TOPLEFT", 0, 1)

    -- anchorTo
    textAnchorTo = Cell:CreateDropdown(textOptionsFrame, 117)
    textAnchorTo:SetPoint("TOPLEFT", textAnchor, "BOTTOMLEFT", 0, -30)
    local items = {}
    for _, point in pairs(anchorPoints) do
        tinsert(items, {
            ["text"] = L[point],
            ["value"] = point,
            ["onClick"] = function()
                CellDB["dispelRequest"]["textOptions"][5] = point
                UpdateTextPreview()
                Cell:Fire("UpdateRequests", "dispelRequest_text")
            end,
        })
    end
    textAnchorTo:SetItems(items)

    local textAnchorToText = textOptionsFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    textAnchorToText:SetText(L["To UnitButton's"])
    textAnchorToText:SetPoint("BOTTOMLEFT", textAnchorTo, "TOPLEFT", 0, 1)

    -- x
    xOffset = Cell:CreateSlider(L["X Offset"], textOptionsFrame, -100, 100, 117, 1, function(value)
        CellDB["dispelRequest"]["textOptions"][6] = value
        UpdateTextPreview()
        Cell:Fire("UpdateRequests", "dispelRequest_text")
    end)
    xOffset:SetPoint("TOPLEFT", textAnchorTo, "BOTTOMLEFT", 0, -30)

    -- y
    yOffset = Cell:CreateSlider(L["Y Offset"], textOptionsFrame, -100, 100, 117, 1, function(value)
        CellDB["dispelRequest"]["textOptions"][7] = value
        UpdateTextPreview()
        Cell:Fire("UpdateRequests", "dispelRequest_text")
    end)
    yOffset:SetPoint("TOPLEFT", xOffset, "BOTTOMLEFT", 0, -40)
end

-------------------------------------------------
-- functions
-------------------------------------------------
function U:ShowTextOptions(parent)
    if not textOptionsFrame then
        CreateTextOptionsFrame()
    end

    if textOptionsFrame:IsShown() then
        textOptionsFrame:Hide()
    else
        textOptionsFrame:SetParent(parent)
        UpdatePreviewButton()
        LoadTextOptions()
        textOptionsFrame:Show()
    end
end

function U:HideTextOptions()
    if textOptionsFrame then textOptionsFrame:Hide() end
end