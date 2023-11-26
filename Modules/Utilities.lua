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

function F:ShowUtilityList(anchor)
    if not listFrame then
        listFrame = CreateFrame("Frame", nil, Cell.frames.optionsFrame, "BackdropTemplate")
        Cell:StylizeFrame(listFrame, {0,1,0,0.1}, {0,0,0,1})
        listFrame:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 1, 0)
        listFrame:SetFrameStrata("TOOLTIP")
        
        Cell:StylizeFrame(listFrame, nil, Cell:GetAccentColorTable())

        -- update width to show full text
        local dumbFS1 = listFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
        dumbFS1:SetText(L["Quick Cast"])
        local dumbFS2 = listFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
        dumbFS2:SetText(L["Dispel Request"])

        -- buttons
        local buttons = {}

        buttons["raidTools"] = Cell:CreateButton(listFrame, L["Raid Tools"], "transparent-accent", {20, 20}, true)
        buttons["raidTools"].id = "raidTools"
        buttons["raidTools"]:SetPoint("TOPLEFT")
        buttons["raidTools"]:SetPoint("TOPRIGHT")
        
        buttons["spellRequest"] = Cell:CreateButton(listFrame, L["Spell Request"], "transparent-accent", {20, 20}, true)
        buttons["spellRequest"].id = "spellRequest"
        buttons["spellRequest"]:SetPoint("TOPLEFT", buttons["raidTools"], "BOTTOMLEFT")
        buttons["spellRequest"]:SetPoint("TOPRIGHT", buttons["raidTools"], "BOTTOMRIGHT")
        
        buttons["dispelRequest"] = Cell:CreateButton(listFrame, L["Dispel Request"], "transparent-accent", {20, 20}, true)
        buttons["dispelRequest"].id = "dispelRequest"
        buttons["dispelRequest"]:SetPoint("TOPLEFT", buttons["spellRequest"], "BOTTOMLEFT")
        buttons["dispelRequest"]:SetPoint("TOPRIGHT", buttons["spellRequest"], "BOTTOMRIGHT")

        if Cell.isRetail then
            buttons["quickCast"] = Cell:CreateButton(listFrame, L["Quick Cast"], "transparent-accent", {20, 20}, true)
            buttons["quickCast"].id = "quickCast"
            buttons["quickCast"]:SetPoint("TOPLEFT", buttons["dispelRequest"], "BOTTOMLEFT")
            buttons["quickCast"]:SetPoint("TOPRIGHT", buttons["dispelRequest"], "BOTTOMRIGHT")
            P:Size(listFrame, ceil(max(dumbFS1:GetStringWidth(), dumbFS2:GetStringWidth())) + 13, 20*4)
        else
            P:Size(listFrame, ceil(max(dumbFS1:GetStringWidth(), dumbFS2:GetStringWidth())) + 13, 20*3)
        end

        local highlight = Cell:CreateButtonGroup({buttons["raidTools"], buttons["spellRequest"], buttons["dispelRequest"], buttons["quickCast"]}, function(id)
            lastShown = id
            anchor:Click()
            Cell:Fire("ShowUtilitySettings", id)
            listFrame:Hide()
        end)
        highlight("raidTools")
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
local utilityHeight = {
    ["raidTools"] = 320,
    ["spellRequest"] = 400,
    ["dispelRequest"] = 420,
    ["quickCast"] = 510,
}

local init
local function ShowTab(tab)
    if tab == "utilities" then
        if not init then
            init = true
            lastShown = "raidTools"
        end
        Cell:Fire("ShowUtilitySettings", lastShown)
        utilitiesTab:Show()
    else
        utilitiesTab:Hide()
    end
end
Cell:RegisterCallback("ShowOptionsTab", "UtilitiesTab_ShowTab", ShowTab)

Cell:RegisterCallback("ShowUtilitySettings", "UtilitiesTab_ShowUtilitySettings", function(which)
    P:Height(Cell.frames.optionsFrame, utilityHeight[which])
end)