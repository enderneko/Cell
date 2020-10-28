local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local LPP = LibStub:GetLibrary("LibPixelPerfect")

local appearanceTab = Cell:CreateFrame("CellOptionsFrame_AppearanceTab", Cell.frames.optionsFrame, nil, nil, true)
Cell.frames.appearanceTab = appearanceTab
appearanceTab:SetAllPoints(Cell.frames.optionsFrame)
appearanceTab:Hide()

-------------------------------------------------
-- texture
-------------------------------------------------
local textureText = Cell:CreateSeparator(L["Texture"], appearanceTab, 188)
textureText:SetPoint("TOPLEFT", 5, -5)

local textureDropdown = Cell:CreateDropdown(appearanceTab, 150, "texture")
textureDropdown:SetPoint("TOPLEFT", textureText, "BOTTOMLEFT", 5, -12)

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


-------------------------------------------------
-- scale
-------------------------------------------------
local scaleText = Cell:CreateSeparator(L["Scale"], appearanceTab, 188)
scaleText:SetPoint("TOPLEFT", 203, -5)

local scaleDropdown = Cell:CreateDropdown(appearanceTab, 150)
scaleDropdown:SetPoint("TOPLEFT", scaleText, "BOTTOMLEFT", 5, -12)

local scales = {
    [1] = "100%",
    [1.5] = "150%",
    [2] = "200%",
    [2.5] = "250%",
    [3] = "300%",
}

do
    local indices = {1, 1.5, 2, 2.5, 3}
    local items = {}
    for _, value in pairs(indices) do
        table.insert(items, {
            ["text"] = scales[value],
            ["onClick"] = function()
                CellDB["appearance"]["scale"] = value
                Cell:Fire("UpdateAppearance", "scale")
            end,
        })
    end
    scaleDropdown:SetItems(items)
end

-------------------------------------------------
-- font
-------------------------------------------------
local fontText = Cell:CreateSeparator(L["Font"], appearanceTab, 188)
fontText:SetPoint("TOPLEFT", 5, -90)

-- drop down
local fontDropdown = Cell:CreateDropdown(appearanceTab, 150, "font")
fontDropdown:SetPoint("TOPLEFT", fontText, "BOTTOMLEFT", 5, -12)

local function CheckFonts()
    local items, fonts, defaultFontName, defaultFont = F:GetFontItems()

    for _, item in pairs(items) do
        item["onClick"] = function()
            CellDB["appearance"]["font"] = item["text"]
            Cell:Fire("UpdateAppearance", "font")
        end
    end

    fontDropdown:SetItems(items)
    
    -- validation
    if fonts[CellDB["appearance"]["font"]] then
        fontDropdown:SetSelected(CellDB["appearance"]["font"], fonts[CellDB["appearance"]["font"]])
    else
        fontDropdown:SetSelected(defaultFontName, defaultFont)
    end
end

-------------------------------------------------
-- font outline
-------------------------------------------------
local fontOutlineText = Cell:CreateSeparator(L["Font Outline"], appearanceTab, 188)
fontOutlineText:SetPoint("TOPLEFT", 203, -90)

-- drop down
local fontOutlineDropdown = Cell:CreateDropdown(appearanceTab, 150)
fontOutlineDropdown:SetPoint("TOPLEFT", fontOutlineText, "BOTTOMLEFT", 5, -12)
fontOutlineDropdown:SetItems({
    {
        ["text"] = L["Shadow"],
        ["onClick"] = function()
            CellDB["appearance"]["outline"] = "Shadow"
            Cell:Fire("UpdateAppearance", "font")
        end,
    },
    {
        ["text"] = L["Outline"],
        ["onClick"] = function()
            CellDB["appearance"]["outline"] = "Outline"
            Cell:Fire("UpdateAppearance", "font")
        end,
    },
    {
        ["text"] = L["Monochrome Outline"],
        ["onClick"] = function()
            CellDB["appearance"]["outline"] = "Monochrome Outline"
            Cell:Fire("UpdateAppearance", "font")
        end,
    },
})

-------------------------------------------------
-- unitbutton color
-------------------------------------------------
local unitButtonColorText = Cell:CreateSeparator(L["UnitButton Color"], appearanceTab, 387)
unitButtonColorText:SetPoint("TOPLEFT", 5, -175)

-- bar color
local barColorDropdown = Cell:CreateDropdown(appearanceTab, 131)
barColorDropdown:SetPoint("TOPLEFT", unitButtonColorText, "BOTTOMLEFT", 5, -27)
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
        ["text"] = L["Custom Color"],
        ["onClick"] = function()
            CellDB["appearance"]["barColor"][1] = "Custom Color"
            Cell:Fire("UpdateAppearance", "color")
        end,
    },
})

local barColorText = appearanceTab:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
barColorText:SetPoint("BOTTOMLEFT", barColorDropdown, "TOPLEFT", 0, 1)
barColorText:SetText(L["Bar Color"])

local barColorPicker = Cell:CreateColorPicker(appearanceTab, "", false, function(r, g, b)
    CellDB["appearance"]["barColor"][2][1] = r
    CellDB["appearance"]["barColor"][2][2] = g
    CellDB["appearance"]["barColor"][2][3] = b
    if CellDB["appearance"]["barColor"][1] == "Custom Color" then
        Cell:Fire("UpdateAppearance", "color")
    end
end)
barColorPicker:SetPoint("LEFT", barColorDropdown, "RIGHT", 5, 0)

-- bg color
local bgColorDropdown = Cell:CreateDropdown(appearanceTab, 131)
bgColorDropdown:SetPoint("TOPLEFT", unitButtonColorText, "BOTTOMLEFT", 203, -27)
bgColorDropdown:SetItems({
    {
        ["text"] = L["Class Color"],
        ["onClick"] = function()
            CellDB["appearance"]["bgColor"][1] = "Class Color"
            Cell:Fire("UpdateAppearance", "color")
        end,
    },
    {
        ["text"] = L["Class Color (dark)"],
        ["onClick"] = function()
            CellDB["appearance"]["bgColor"][1] = "Class Color (dark)"
            Cell:Fire("UpdateAppearance", "color")
        end,
    },
    {
        ["text"] = L["Custom Color"],
        ["onClick"] = function()
            CellDB["appearance"]["bgColor"][1] = "Custom Color"
            Cell:Fire("UpdateAppearance", "color")
        end,
    },
})

local bgColorText = appearanceTab:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
bgColorText:SetPoint("BOTTOMLEFT", bgColorDropdown, "TOPLEFT", 0, 1)
bgColorText:SetText(L["Background Color"])

local bgColorPicker = Cell:CreateColorPicker(appearanceTab, "", false, function(r, g, b)
    CellDB["appearance"]["bgColor"][2][1] = r
    CellDB["appearance"]["bgColor"][2][2] = g
    CellDB["appearance"]["bgColor"][2][3] = b
    if CellDB["appearance"]["bgColor"][1] == "Custom Color" then
        Cell:Fire("UpdateAppearance", "color")
    end
end)
bgColorPicker:SetPoint("LEFT", bgColorDropdown, "RIGHT", 5, 0)

-- name color
local nameColorDropdown = Cell:CreateDropdown(appearanceTab, 131)
nameColorDropdown:SetPoint("TOPLEFT", barColorDropdown, "BOTTOMLEFT", 0, -30)
nameColorDropdown:SetItems({
    {
        ["text"] = L["Class Color"],
        ["onClick"] = function()
            CellDB["appearance"]["nameColor"][1] = "Class Color"
            Cell:Fire("UpdateAppearance", "color")
        end,
    },
    {
        ["text"] = L["Custom Color"],
        ["onClick"] = function()
            CellDB["appearance"]["nameColor"][1] = "Custom Color"
            Cell:Fire("UpdateAppearance", "color")
        end,
    },
})

local nameColorText = appearanceTab:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
nameColorText:SetPoint("BOTTOMLEFT", nameColorDropdown, "TOPLEFT", 0, 1)
nameColorText:SetText(L["Name Color"])

local nameColorPicker = Cell:CreateColorPicker(appearanceTab, "", false, function(r, g, b)
    CellDB["appearance"]["nameColor"][2][1] = r
    CellDB["appearance"]["nameColor"][2][2] = g
    CellDB["appearance"]["nameColor"][2][3] = b
    if CellDB["appearance"]["nameColor"][1] == "Custom Color" then
        Cell:Fire("UpdateAppearance", "color")
    end
end)
nameColorPicker:SetPoint("LEFT", nameColorDropdown, "RIGHT", 5, 0)

-- reset
local resetBtn = Cell:CreateButton(appearanceTab, L["Reset"], "class-hover", {50, 17})
resetBtn:SetPoint("RIGHT", -5, 0)
resetBtn:SetPoint("TOP", unitButtonColorText, 0, 1)
resetBtn:SetScript("OnClick", function()
    CellDB["appearance"]["barColor"] = {"Class Color", {.125, .125, .125}}
    CellDB["appearance"]["bgColor"] = {"Class Color (dark)", {.667, 0, 0}}
    CellDB["appearance"]["nameColor"] = {"Custom Color", {1, 1, 1}}

    barColorDropdown:SetSelected(L["Class Color"])
    barColorPicker:SetColor({.125, .125, .125})

    bgColorDropdown:SetSelected(L["Class Color (dark)"])
    bgColorPicker:SetColor({.667, 0, 0})

    nameColorDropdown:SetSelected(L["Custom Color"])
    nameColorPicker:SetColor({1, 1, 1})

    Cell:Fire("UpdateAppearance", "color")
end)

-------------------------------------------------
-- functions
-------------------------------------------------
local loaded
local function ShowTab(tab)
    if tab == "appearance" then
        appearanceTab:Show()
        if loaded then return end
        loaded = true

        -- load data
        CheckTextures()
        scaleDropdown:SetSelected(scales[CellDB["appearance"]["scale"]])
        CheckFonts()
        fontOutlineDropdown:SetSelected(L[CellDB["appearance"]["outline"]])

        barColorDropdown:SetSelected(L[CellDB["appearance"]["barColor"][1]])
        barColorPicker:SetColor(CellDB["appearance"]["barColor"][2])

        bgColorDropdown:SetSelected(L[CellDB["appearance"]["bgColor"][1]])
        bgColorPicker:SetColor(CellDB["appearance"]["bgColor"][2])

        nameColorDropdown:SetSelected(L[CellDB["appearance"]["nameColor"][1]])
        nameColorPicker:SetColor(CellDB["appearance"]["nameColor"][2])
    else
        appearanceTab:Hide()
    end
end
Cell:RegisterCallback("ShowOptionsTab", "AppearanceTab_ShowTab", ShowTab)

-------------------------------------------------
-- update appearance
-------------------------------------------------
local function UpdateAppearance(which)
    F:Debug("|cff7f7fffUpdateAppearance:|r "..(which or "all"))
    
    if not which or which == "font" or which == "texture" or which == "color" then
        F:UpdateFont()
        local tex = F:GetBarTexture()

        F:IterateAllUnitButtons(function(b)
            -- font width
            if not which or which == "font" then
                b:GetScript("OnSizeChanged")(b)
            end
            -- texture
            if not which or which == "texture" then
                b.func.SetTexture(tex)
            end
            -- color
            if not which or which == "color" then
                b.func.UpdateColor(b)
            end
        end)
    end

    -- scale
    if not which or which == "scale" then
        Cell.frames.mainFrame:SetScale(CellDB["appearance"]["scale"])
        CellTooltip:SetScale(LPP:GetPixelPerfectScale() * CellDB["appearance"]["scale"])
        CellScanningTooltip:SetScale(LPP:GetPixelPerfectScale() * CellDB["appearance"]["scale"])
    end
end
Cell:RegisterCallback("UpdateAppearance", "UpdateAppearance", UpdateAppearance)