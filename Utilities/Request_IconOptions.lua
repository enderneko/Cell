local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local B = Cell.bFuncs
local U = Cell.uFuncs
local P = Cell.pixelPerfectFuncs
local LCG = LibStub("LibCustomGlow-1.0")

local iconOptionsFrame, previewButton
local icon, iconColorTable

--------------------------------------------------
-- icon preview
--------------------------------------------------
local function CreatePreviewButton()
    previewButton = CreateFrame("Button", "CellIconPreviewButton", iconOptionsFrame, "CellPreviewButtonTemplate")
    -- previewButton.type = "main" -- layout setup
    previewButton:SetPoint("BOTTOMLEFT", iconOptionsFrame, "TOPLEFT", 0, 5)
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
    
    local previewButtonBG = Cell:CreateFrame("CellIconPreviewButtonBG", previewButton)
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
    local r, g, b = F:GetHealthColor(1, false, F:GetClassColor(Cell.vars.playerClass))
    previewButton.widgets.healthBar:SetStatusBarColor(r, g, b, CellDB["appearance"]["barAlpha"])
    
    -- power color
    r, g, b = F:GetPowerColor("player", Cell.vars.playerClass)
    previewButton.widgets.powerBar:SetStatusBarColor(r, g, b)

    -- alpha
    previewButton:SetBackdropColor(0, 0, 0, CellDB["appearance"]["bgAlpha"])

    previewButton:Show()

    Cell:Fire("UpdatePreview", previewButton)
end

Cell:RegisterCallback("UpdateLayout", "IconOptions_UpdateLayout", function()
    if previewButton then
        UpdatePreviewButton()
    end
end)

Cell:RegisterCallback("UpdateAppearance", "IconOptions_UpdateAppearance", function()
    if previewButton then
        UpdatePreviewButton()
    end
end)

-------------------------------------------------
-- icon options
-------------------------------------------------
local iconAnimation, iconAnchor, iconAnchorTo, iconiconGlowColor, size, xOffset, yOffset

local function UpdateIconPreview()
    local setting = CellDB["spellRequest"]["sharedIconOptions"]
    previewButton.widgets.srIcon:SetAnimationType(setting[1])
    P:Size(previewButton.widgets.srIcon, setting[2], setting[2])
    P:ClearPoints(previewButton.widgets.srIcon)
    P:Point(previewButton.widgets.srIcon, setting[3], previewButton.widgets.srGlowFrame, setting[4], setting[5], setting[6])
    previewButton.widgets.srIcon:Display(icon, iconColorTable)
end

local function LoadIconOptions()
    UpdateIconPreview()

    iconGlowColor:SetColor(unpack(iconColorTable))

    iconAnimation:SetSelectedValue(CellDB["spellRequest"]["sharedIconOptions"][1])
    size:SetValue(CellDB["spellRequest"]["sharedIconOptions"][2])
    iconAnchor:SetSelectedValue(CellDB["spellRequest"]["sharedIconOptions"][3])
    iconAnchorTo:SetSelectedValue(CellDB["spellRequest"]["sharedIconOptions"][4])
    xOffset:SetValue(CellDB["spellRequest"]["sharedIconOptions"][5])
    yOffset:SetValue(CellDB["spellRequest"]["sharedIconOptions"][6])
end

local function CreateIconOptionsFrame()
    iconOptionsFrame = CreateFrame("Frame", "CellOptionsFrame_IconOptions", Cell.frames.optionsFrame)
    iconOptionsFrame:SetPoint("BOTTOMLEFT", Cell.frames.optionsFrame, "BOTTOMRIGHT", 5, 0)
    P:Size(iconOptionsFrame, 127, 335)
    iconOptionsFrame:Hide()

    -- shared
    local sharedOptionsFrame = Cell:CreateFrame("CellOptionsFrame_IconOptions_Shared", iconOptionsFrame, 127, 300)
    sharedOptionsFrame:SetPoint("BOTTOMLEFT")
    sharedOptionsFrame:Show()

    -- iconAnimation
    iconAnimation = Cell:CreateDropdown(sharedOptionsFrame, 117)
    iconAnimation:SetPoint("TOPLEFT", 5, -20)
    iconAnimation:SetItems({
        {
            ["text"] = L["None"],
            ["value"] = "none",
            ["onClick"] = function()
                CellDB["spellRequest"]["sharedIconOptions"][1] = "none"
                UpdateIconPreview()
                Cell:Fire("UpdateRequests", "spellRequest_icon")
            end
        },
        {
            ["text"] = L["Beat"],
            ["value"] = "beat",
            ["onClick"] = function()
                CellDB["spellRequest"]["sharedIconOptions"][1] = "beat"
                UpdateIconPreview()
                Cell:Fire("UpdateRequests", "spellRequest_icon")
            end
        },
        {
            ["text"] = L["Bounce"],
            ["value"] = "bounce",
            ["onClick"] = function()
                CellDB["spellRequest"]["sharedIconOptions"][1] = "bounce"
                UpdateIconPreview()
                Cell:Fire("UpdateRequests", "spellRequest_icon")
            end
        },
        {
            ["text"] = L["Blink"],
            ["value"] = "blink",
            ["onClick"] = function()
                CellDB["spellRequest"]["sharedIconOptions"][1] = "blink"
                UpdateIconPreview()
                Cell:Fire("UpdateRequests", "spellRequest_icon")
            end
        }
    })

    local iconAnimationText = sharedOptionsFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    iconAnimationText:SetText(L["Animation"])
    iconAnimationText:SetPoint("BOTTOMLEFT", iconAnimation, "TOPLEFT", 0, 1)

    -- size
    size = Cell:CreateSlider(L["Size"], sharedOptionsFrame, 8, 64, 117, 1, function(value)
        CellDB["spellRequest"]["sharedIconOptions"][2] = value
        UpdateIconPreview()
        Cell:Fire("UpdateRequests", "spellRequest_icon")
    end)
    size:SetPoint("TOPLEFT", iconAnimation, "BOTTOMLEFT", 0, -30)

    -- anchor
    local anchorPoints = {"BOTTOM", "BOTTOMLEFT", "BOTTOMRIGHT", "CENTER", "LEFT", "RIGHT", "TOP", "TOPLEFT", "TOPRIGHT"}
    iconAnchor = Cell:CreateDropdown(sharedOptionsFrame, 117)
    iconAnchor:SetPoint("TOPLEFT", size, "BOTTOMLEFT", 0, -40)
    local items = {}
    for _, point in pairs(anchorPoints) do
        tinsert(items, {
            ["text"] = L[point],
            ["value"] = point,
            ["onClick"] = function()
                CellDB["spellRequest"]["sharedIconOptions"][3] = point
                UpdateIconPreview()
                Cell:Fire("UpdateRequests", "spellRequest_icon")
            end,
        })
    end
    iconAnchor:SetItems(items)

    local iconAnchorText = sharedOptionsFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    iconAnchorText:SetText(L["Anchor Point"])
    iconAnchorText:SetPoint("BOTTOMLEFT", iconAnchor, "TOPLEFT", 0, 1)

    -- anchorTo
    iconAnchorTo = Cell:CreateDropdown(sharedOptionsFrame, 117)
    iconAnchorTo:SetPoint("TOPLEFT", iconAnchor, "BOTTOMLEFT", 0, -30)
    local items = {}
    for _, point in pairs(anchorPoints) do
        tinsert(items, {
            ["text"] = L[point],
            ["value"] = point,
            ["onClick"] = function()
                CellDB["spellRequest"]["sharedIconOptions"][4] = point
                UpdateIconPreview()
                Cell:Fire("UpdateRequests", "spellRequest_icon")
            end,
        })
    end
    iconAnchorTo:SetItems(items)

    local iconAnchorToText = sharedOptionsFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    iconAnchorToText:SetText(L["To UnitButton's"])
    iconAnchorToText:SetPoint("BOTTOMLEFT", iconAnchorTo, "TOPLEFT", 0, 1)

    -- x
    xOffset = Cell:CreateSlider(L["X Offset"], sharedOptionsFrame, -100, 100, 117, 1, function(value)
        CellDB["spellRequest"]["sharedIconOptions"][5] = value
        UpdateIconPreview()
        Cell:Fire("UpdateRequests", "spellRequest_icon")
    end)
    xOffset:SetPoint("TOPLEFT", iconAnchorTo, "BOTTOMLEFT", 0, -30)

    -- y
    yOffset = Cell:CreateSlider(L["Y Offset"], sharedOptionsFrame, -100, 100, 117, 1, function(value)
        CellDB["spellRequest"]["sharedIconOptions"][6] = value
        UpdateIconPreview()
        Cell:Fire("UpdateRequests", "spellRequest_icon")
    end)
    yOffset:SetPoint("TOPLEFT", xOffset, "BOTTOMLEFT", 0, -40)

    -- individual
    local individualOptionsFrame = Cell:CreateFrame("CellOptionsFrame_IconOptions_Individual", iconOptionsFrame, 127, 30)
    individualOptionsFrame:SetPoint("BOTTOMLEFT", sharedOptionsFrame, "TOPLEFT", 0, 5)
    individualOptionsFrame:Show()

    -- iconGlowColor
    iconGlowColor = Cell:CreateColorPicker(individualOptionsFrame, L["Glow Color"], false, function(r, g, b)
        -- update db
        iconColorTable[1] = r
        iconColorTable[2] = g
        iconColorTable[3] = b
        iconColorTable[4] = 1
        -- update preview
        UpdateIconPreview()
    end)
    iconGlowColor:SetPoint("TOPLEFT", 5, -7)
end

-------------------------------------------------
-- functions
-------------------------------------------------
function U:ShowIconOptions(parent, tex, t)
    if not iconOptionsFrame then
        CreateIconOptionsFrame()
    end

    if iconOptionsFrame:IsShown() then
        iconOptionsFrame:Hide()
    else
        iconOptionsFrame:SetParent(parent)
        icon = tex
        iconColorTable = t
        UpdatePreviewButton()
        LoadIconOptions()
        iconOptionsFrame:Show()
    end
end

function U:HideIconOptions()
    if iconOptionsFrame then iconOptionsFrame:Hide() end
end