local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

local utilitiesTab = Cell:CreateFrame("CellOptionsFrame_UtilitiesTab", Cell.frames.optionsFrame, nil, nil, true)
Cell.frames.utilitiesTab = utilitiesTab
utilitiesTab:SetAllPoints(Cell.frames.optionsFrame)
utilitiesTab:Hide()

-------------------------------------------------
-- list
-------------------------------------------------
local listFrame, lastShown

local function UpdateFontString(b)
    local fs = b:GetFontString()
    fs:ClearAllPoints()
    fs:SetPoint("LEFT", 3, 0)
    fs:SetPoint("RIGHT", -3, 0)
    fs:SetWordWrap(true)
    fs:SetSpacing(3)
end

function F:ShowUtilityList()
    if not listFrame then
        listFrame = CreateFrame("Frame", nil, Cell.frames.optionsFrame, "BackdropTemplate")
        Cell:StylizeFrame(listFrame, {0,1,0,0.1}, {0,0,0,1})
        listFrame:SetPoint("TOPLEFT", utilitiesTab, "TOPRIGHT", 1, 0)
        listFrame:SetFrameStrata("TOOLTIP")

        -- update width to show full text
        local dumbFS1 = listFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
        dumbFS1:SetText(L["Quick Cast"])
        local dumbFS2 = listFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
        dumbFS2:SetText(L["Dispel Request"])

        P:Size(listFrame, ceil(max(dumbFS1:GetStringWidth(), dumbFS2:GetStringWidth())) + 13, 20*4+2)
        Cell:StylizeFrame(listFrame, nil, Cell:GetAccentColorTable())

        -- buttons
        local raidToolsBtn = Cell:CreateButton(listFrame, L["Raid Tools"], "transparent-accent", {20, 20}, true)
        raidToolsBtn:SetPoint("TOPLEFT")
        raidToolsBtn:SetPoint("TOPRIGHT")
        raidToolsBtn:SetScript("OnClick", function()
            Cell:Fire("ShowUtilitySettings", "raidTools")
            listFrame:Hide()
        end)
        
        local spellRequestBtn = Cell:CreateButton(listFrame, L["Spell Request"], "transparent-accent", {20, 20}, true)
        spellRequestBtn:SetPoint("TOPLEFT", raidToolsBtn, "BOTTOMLEFT")
        spellRequestBtn:SetPoint("TOPRIGHT", raidToolsBtn, "BOTTOMRIGHT")
        spellRequestBtn:SetScript("OnClick", function()
            Cell:Fire("ShowUtilitySettings", "spellRequest")
            listFrame:Hide()
        end)
        
        local dispelRequestBtn = Cell:CreateButton(listFrame, L["Dispel Request"], "transparent-accent", {20, 20}, true)
        dispelRequestBtn:SetPoint("TOPLEFT", spellRequestBtn, "BOTTOMLEFT")
        dispelRequestBtn:SetPoint("TOPRIGHT", spellRequestBtn, "BOTTOMRIGHT")
        dispelRequestBtn:SetScript("OnClick", function()
            Cell:Fire("ShowUtilitySettings", "dispelRequest")
            listFrame:Hide()
        end)

        local quickCastBtn = Cell:CreateButton(listFrame, L["Quick Cast"], "transparent-accent", {20, 20}, true)
        quickCastBtn:SetPoint("TOPLEFT", dispelRequestBtn, "BOTTOMLEFT")
        quickCastBtn:SetPoint("TOPRIGHT", dispelRequestBtn, "BOTTOMRIGHT")
        quickCastBtn:SetEnabled(false)
        quickCastBtn:SetScript("OnClick", function()
            Cell:Fire("ShowUtilitySettings", "quickCast")
            listFrame:Hide()
        end)
    end

    listFrame:Show()
end 

function F:HideUtilityList()
    if listFrame then listFrame:Hide() end
end

function F:IsUtilityListMouseover()
    return listFrame and listFrame:IsMouseOver()
end

-------------------------------------------------
-- show
-------------------------------------------------
local init
local function ShowTab(tab)
    if tab == "utilities" then
        if not init then
            init = true
            Cell:Fire("ShowUtilitySettings", "raidTools")
        end
        utilitiesTab:Show()
    else
        utilitiesTab:Hide()
    end
end
Cell:RegisterCallback("ShowOptionsTab", "UtilitiesTab_ShowTab", ShowTab)