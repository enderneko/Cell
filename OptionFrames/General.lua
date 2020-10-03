local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local LPP = LibStub:GetLibrary("LibPixelPerfect")

local generalTab = Cell:CreateFrame("CellOptionsFrame_GeneralTab", Cell.frames.optionsFrame, nil, nil, true)
Cell.frames.generalTab = generalTab
generalTab:SetAllPoints(Cell.frames.optionsFrame)
generalTab:Hide()

-------------------------------------------------
-- texture
-------------------------------------------------
local textureText = Cell:CreateSeparator(L["Texture"], generalTab, 188)
textureText:SetPoint("TOPLEFT", 5, -5)

local textureDropdown = Cell:CreateDropdown(generalTab, 150, "texture")
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
                    CellDB["texture"] = name
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
                CellDB["texture"] = defaultTextureName
                Cell:Fire("UpdateAppearance", "texture")
            end,
        })
    end
    textureDropdown:SetItems(items)

    -- validation
    if textures[CellDB["texture"]] then
        textureDropdown:SetSelected(CellDB["texture"], textures[CellDB["texture"]])
    else
        textureDropdown:SetSelected(defaultTextureName, defaultTexture)
    end
end


-------------------------------------------------
-- scale
-------------------------------------------------
local scaleText = Cell:CreateSeparator(L["Scale"], generalTab, 188)
scaleText:SetPoint("TOPLEFT", 203, -5)

local scaleDropdown = Cell:CreateDropdown(generalTab, 150)
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
                CellDB["scale"] = value
                Cell:Fire("UpdateAppearance", "scale")
            end,
        })
    end
    scaleDropdown:SetItems(items)
end

-------------------------------------------------
-- font
-------------------------------------------------
local fontText = Cell:CreateSeparator(L["Font"], generalTab, 188)
fontText:SetPoint("TOPLEFT", 5, -90)

-- drop down
local fontDropdown = Cell:CreateDropdown(generalTab, 150, "font")
fontDropdown:SetPoint("TOPLEFT", fontText, "BOTTOMLEFT", 5, -12)

local function CheckFonts()
    local items, fonts, defaultFontName, defaultFont = F:GetFontItems()

    for _, item in pairs(items) do
        item["onClick"] = function()
            CellDB["font"] = item["text"]
            Cell:Fire("UpdateAppearance", "font")
        end
    end

    fontDropdown:SetItems(items)
    
    -- validation
    if fonts[CellDB["font"]] then
        fontDropdown:SetSelected(CellDB["font"], fonts[CellDB["font"]])
    else
        fontDropdown:SetSelected(defaultFontName, defaultFont)
    end
end

-------------------------------------------------
-- font outline
-------------------------------------------------
local fontOutlineText = Cell:CreateSeparator(L["Font Outline"], generalTab, 188)
fontOutlineText:SetPoint("TOPLEFT", 203, -90)

-- drop down
local fontOutlineDropdown = Cell:CreateDropdown(generalTab, 150)
fontOutlineDropdown:SetPoint("TOPLEFT", fontOutlineText, "BOTTOMLEFT", 5, -12)
fontOutlineDropdown:SetItems({
    {
        ["text"] = L["Shadow"],
        ["onClick"] = function()
            CellDB["outline"] = "Shadow"
            Cell:Fire("UpdateAppearance", "font")
        end,
    },
    {
        ["text"] = L["Outline"],
        ["onClick"] = function()
            CellDB["outline"] = "Outline"
            Cell:Fire("UpdateAppearance", "font")
        end,
    },
    {
        ["text"] = L["Monochrome Outline"],
        ["onClick"] = function()
            CellDB["outline"] = "Monochrome Outline"
            Cell:Fire("UpdateAppearance", "font")
        end,
    },
})

-------------------------------------------------
-- hide blizzard
-------------------------------------------------
local blizzardText = Cell:CreateSeparator(L["Blizzard Frames"], generalTab, 188)
blizzardText:SetPoint("TOPLEFT", 5, -175)

local hideBlizzardCB = Cell:CreateCheckButton(generalTab, L["Hide Blizzard Raid / Party"], function(checked, self)
    CellDB["hideBlizzard"] = checked
end, L["Hide Blizzard Frames"], L["Require reload of the UI"])
hideBlizzardCB:SetPoint("TOPLEFT", blizzardText, "BOTTOMLEFT", 5, -15)

-------------------------------------------------
-- tooltip
-------------------------------------------------
local tooltipsText = Cell:CreateSeparator(L["Tooltips"], generalTab, 188)
tooltipsText:SetPoint("TOPLEFT", 203, -175)

local disableTooltipsCB = Cell:CreateCheckButton(generalTab, L["Disable tooltips"], function(checked, self)
    CellDB["disableTooltips"] = checked
end)
disableTooltipsCB:SetPoint("TOPLEFT", tooltipsText, "BOTTOMLEFT", 5, -15)

-------------------------------------------------
-- raid setup
-------------------------------------------------
local setupText = Cell:CreateSeparator(L["Raid Setup"], generalTab, 188)
setupText:SetPoint("TOPLEFT", 5, -260)

local setupCB = Cell:CreateCheckButton(generalTab, L["Show Raid Setup"], function(checked, self)
    CellDB["showRaidSetup"] = checked
    if IsInRaid() then
        if checked then
            Cell.frames.raidSetupFrame:Show()
        else
            Cell.frames.raidSetupFrame:Hide()
        end
    end
end, L["Show Raid Setup"], L["Show the number of tanks/healers/damagers while in raid"])
setupCB:SetPoint("TOPLEFT", setupText, "BOTTOMLEFT", 5, -15)

-------------------------------------------------
-- pull timer
-------------------------------------------------
local pullText = Cell:CreateSeparator(L["Pull Timer"], generalTab, 188)
pullText:SetPoint("TOPLEFT", 203, -260)

local pullDropdown = Cell:CreateDropdown(generalTab, 75)
pullDropdown:SetPoint("TOPLEFT", pullText, "BOTTOMLEFT", 5, -12)
pullDropdown:SetItems({
    {
        ["text"] = "ERT",
        ["onClick"] = function()
            CellDB["pullTimer"][1] = "ERT"
            F:UpdatePullTimer()
        end,
    },
    {
        ["text"] = "DBM",
        ["onClick"] = function()
            CellDB["pullTimer"][1] = "DBM"
            F:UpdatePullTimer()
        end,
    },
    {
        ["text"] = "BW",
        ["onClick"] = function()
            CellDB["pullTimer"][1] = "BW"
            F:UpdatePullTimer()
        end,
    },
})

local secDropdown = Cell:CreateDropdown(generalTab, 70)
secDropdown:SetPoint("LEFT", pullDropdown, "RIGHT", 5, 0)
secDropdown:SetItems({
    {
        ["text"] = 5,
        ["onClick"] = function()
            CellDB["pullTimer"][2] = 5
            F:UpdatePullTimer()
        end,
    },
    {
        ["text"] = 7,
        ["onClick"] = function()
            CellDB["pullTimer"][2] = 7
            F:UpdatePullTimer()
        end,
    },
    {
        ["text"] = 10,
        ["onClick"] = function()
            CellDB["pullTimer"][2] = 10
            F:UpdatePullTimer()
        end,
    },
    {
        ["text"] = 15,
        ["onClick"] = function()
            CellDB["pullTimer"][2] = 15
            F:UpdatePullTimer()
        end,
    },
    {
        ["text"] = 20,
        ["onClick"] = function()
            CellDB["pullTimer"][2] = 20
            F:UpdatePullTimer()
        end,
    },
    {
        ["text"] = 25,
        ["onClick"] = function()
            CellDB["pullTimer"][2] = 25
            F:UpdatePullTimer()
        end,
    },
    {
        ["text"] = 30,
        ["onClick"] = function()
            CellDB["pullTimer"][2] = 30
            F:UpdatePullTimer()
        end,
    },
})

-------------------------------------------------
-- functions
-------------------------------------------------
local loaded
local function ShowTab(tab)
    if tab == "general" then
        generalTab:Show()
        if loaded then return end
        loaded = true

        -- load data
        CheckTextures()
        scaleDropdown:SetSelected(scales[CellDB["scale"]])
        CheckFonts()
        fontOutlineDropdown:SetSelected(L[CellDB["outline"]])
        hideBlizzardCB:SetChecked(CellDB["hideBlizzard"])
        disableTooltipsCB:SetChecked(CellDB["disableTooltips"])
        setupCB:SetChecked(CellDB["showRaidSetup"])
        pullDropdown:SetSelected(CellDB["pullTimer"][1])
        secDropdown:SetSelected(CellDB["pullTimer"][2])
    else
        generalTab:Hide()
    end
end
Cell:RegisterCallback("ShowOptionsTab", "GeneralTab_ShowTab", ShowTab)

-------------------------------------------------
-- update appearance
-------------------------------------------------
local function UpdateAppearance(which)
    F:Debug("|cff7f7fffUpdateAppearance:|r "..(which or "all"))
    
    if not which or which == "font" or which == "texture" then
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
        end)
    end

    -- scale
    if not which or which == "scale" then
        Cell.frames.mainFrame:SetScale(CellDB["scale"])
        CellTooltip:SetScale(LPP:GetPixelPerfectScale() * CellDB["scale"])
    end
end
Cell:RegisterCallback("UpdateAppearance", "UpdateAppearance", UpdateAppearance)