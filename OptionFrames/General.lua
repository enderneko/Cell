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
-- raid tools
-------------------------------------------------
local toolsText = Cell:CreateSeparator(L["Raid Tools"], generalTab, 387)
toolsText:SetPoint("TOPLEFT", 5, -260)

local unlockBtn = Cell:CreateButton(generalTab, L["Unlock"], "class-hover", {50, 17})
unlockBtn:SetPoint("RIGHT", -5, 0)
unlockBtn:SetPoint("TOP", toolsText, 0, 1)
unlockBtn.locked = true
unlockBtn:SetScript("OnClick", function(self)
    if self.locked then
        unlockBtn:SetText(L["Lock"])
        self.locked = false
        Cell:Fire("ShowMover", true)
    else
        unlockBtn:SetText(L["Unlock"])
        self.locked = true
        Cell:Fire("ShowMover", false)
    end
end)

-- raid setup
local setupCB = Cell:CreateCheckButton(generalTab, L["Show Raid Setup"], function(checked, self)
    CellDB["raidTools"]["showRaidSetup"] = checked
    if IsInRaid() then
        if checked then
            Cell.frames.raidSetupFrame:Show()
        else
            Cell.frames.raidSetupFrame:Hide()
        end
    end
end, L["Show Raid Setup"], L["Show the number of tanks/healers/damagers while in raid"])
setupCB:SetPoint("TOPLEFT", toolsText, "BOTTOMLEFT", 5, -15)

-- battle res
local resCB = Cell:CreateCheckButton(generalTab, L["Show Battle Res"], function(checked, self)

end)
resCB:SetPoint("LEFT", setupCB, "RIGHT", 110, 0)

-- ready & pull
local pullText, pullDropdown, secDropdown
local readyPullCB = Cell:CreateCheckButton(generalTab, L["Show ReadyCheck and PullTimer buttons"], function(checked, self)
    CellDB["raidTools"]["showButtons"] = checked
    pullDropdown:SetEnabled(checked)
    secDropdown:SetEnabled(checked)
    if checked then
        pullText:SetTextColor(1, 1, 1)
    else
        pullText:SetTextColor(.4, .4, .4)
    end
    Cell:Fire("UpdateRaidTools", "buttons")
end, L["Show ReadyCheck and PullTimer buttons"], L["Only show when you have permission to do this"], L["pullTimerTips"])
readyPullCB:SetPoint("TOPLEFT", setupCB, "BOTTOMLEFT", 0, -10)

pullText = generalTab:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
pullText:SetText(L["Pull Timer"])
pullText:SetPoint("TOPLEFT", readyPullCB, "BOTTOMRIGHT", 5, -10)

pullDropdown = Cell:CreateDropdown(generalTab, 75)
pullDropdown:SetPoint("LEFT", pullText, "RIGHT", 10, 0)
pullDropdown:SetItems({
    {
        ["text"] = "ERT",
        ["onClick"] = function()
            CellDB["raidTools"]["pullTimer"][1] = "ERT"
            Cell:Fire("UpdateRaidTools", "pullTimer")
        end,
    },
    {
        ["text"] = "DBM",
        ["onClick"] = function()
            CellDB["raidTools"]["pullTimer"][1] = "DBM"
            Cell:Fire("UpdateRaidTools", "pullTimer")
        end,
    },
    {
        ["text"] = "BW",
        ["onClick"] = function()
            CellDB["raidTools"]["pullTimer"][1] = "BW"
            Cell:Fire("UpdateRaidTools", "pullTimer")
        end,
    },
})

secDropdown = Cell:CreateDropdown(generalTab, 70)
secDropdown:SetPoint("LEFT", pullDropdown, "RIGHT", 5, 0)
secDropdown:SetItems({
    {
        ["text"] = 5,
        ["onClick"] = function()
            CellDB["raidTools"]["pullTimer"][2] = 5
            Cell:Fire("UpdateRaidTools", "pullTimer")
        end,
    },
    {
        ["text"] = 7,
        ["onClick"] = function()
            CellDB["raidTools"]["pullTimer"][2] = 7
            Cell:Fire("UpdateRaidTools", "pullTimer")
        end,
    },
    {
        ["text"] = 10,
        ["onClick"] = function()
            CellDB["raidTools"]["pullTimer"][2] = 10
            Cell:Fire("UpdateRaidTools", "pullTimer")
        end,
    },
    {
        ["text"] = 15,
        ["onClick"] = function()
            CellDB["raidTools"]["pullTimer"][2] = 15
            Cell:Fire("UpdateRaidTools", "pullTimer")
        end,
    },
    {
        ["text"] = 20,
        ["onClick"] = function()
            CellDB["raidTools"]["pullTimer"][2] = 20
            Cell:Fire("UpdateRaidTools", "pullTimer")
        end,
    },
    {
        ["text"] = 25,
        ["onClick"] = function()
            CellDB["raidTools"]["pullTimer"][2] = 25
            Cell:Fire("UpdateRaidTools", "pullTimer")
        end,
    },
    {
        ["text"] = 30,
        ["onClick"] = function()
            CellDB["raidTools"]["pullTimer"][2] = 30
            Cell:Fire("UpdateRaidTools", "pullTimer")
        end,
    },
})

-- marks bar
local marksCB, worldMarksCB, bothCB
local marksBarCB = Cell:CreateCheckButton(generalTab, L["Show Marks Bar"], function(checked, self)
    CellDB["raidTools"]["showMarks"] = checked
    marksCB:SetEnabled(checked)
    worldMarksCB:SetEnabled(checked)
    bothCB:SetEnabled(checked)
    Cell:Fire("UpdateRaidTools", "marks")
end, L["Show Marks Bar"], L["Only show when you have permission to do this"], L["marksTips"])
marksBarCB:SetPoint("TOPLEFT", readyPullCB, "BOTTOMLEFT", 0, -35)

marksCB = Cell:CreateCheckButton(generalTab, L["Target Marks"], function(checked, self)
    CellDB["raidTools"]["marks"] = "target"
    marksCB:SetChecked(true)
    worldMarksCB:SetChecked(false)
    bothCB:SetChecked(false)
    Cell:Fire("UpdateRaidTools", "marks")
end)
marksCB:SetPoint("LEFT", marksBarCB, "RIGHT", 110, 0)

worldMarksCB = Cell:CreateCheckButton(generalTab, L["World Marks"], function(checked, self)
    CellDB["raidTools"]["marks"] = "world"
    marksCB:SetChecked(false)
    worldMarksCB:SetChecked(true)
    bothCB:SetChecked(false)
    Cell:Fire("UpdateRaidTools", "marks")
end)
worldMarksCB:SetPoint("LEFT", marksCB, "RIGHT", 80, 0)

bothCB = Cell:CreateCheckButton(generalTab, L["Both"], function(checked, self)
    CellDB["raidTools"]["marks"] = "both"
    marksCB:SetChecked(false)
    worldMarksCB:SetChecked(false)
    bothCB:SetChecked(true)
    Cell:Fire("UpdateRaidTools", "marks")
end)
bothCB:SetPoint("LEFT", worldMarksCB, "RIGHT", 80, 0)

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

        -- raid tools
        setupCB:SetChecked(CellDB["raidTools"]["showRaidSetup"])

        readyPullCB:SetChecked(CellDB["raidTools"]["showButtons"])
        pullDropdown:SetSelected(CellDB["raidTools"]["pullTimer"][1])
        secDropdown:SetSelected(CellDB["raidTools"]["pullTimer"][2])
        pullDropdown:SetEnabled(CellDB["raidTools"]["showButtons"])
        secDropdown:SetEnabled(CellDB["raidTools"]["showButtons"])
        if CellDB["raidTools"]["showButtons"] then
            pullText:SetTextColor(1, 1, 1)
        else
            pullText:SetTextColor(.4, .4, .4)
        end

        marksBarCB:SetChecked(CellDB["raidTools"]["showMarks"])
        marksCB:SetEnabled(CellDB["raidTools"]["showMarks"])
        worldMarksCB:SetEnabled(CellDB["raidTools"]["showMarks"])
        bothCB:SetEnabled(CellDB["raidTools"]["showMarks"])
        if CellDB["raidTools"]["marks"] == "target" then
            marksCB:SetChecked(true)
        elseif CellDB["raidTools"]["marks"] == "world" then
            worldMarksCB:SetChecked(true)
        else
            bothCB:SetChecked(true)
        end
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