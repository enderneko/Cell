local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

local optionsFrame = Cell:CreateFrame("CellOptionsFrame", Cell.frames.mainFrame, 397, 401)
Cell.frames.optionsFrame = optionsFrame
-- optionsFrame:SetPoint("BOTTOMLEFT", Cell.frames.mainFrame, "TOPLEFT", 0, 16)
optionsFrame:SetPoint("CENTER", UIParent)
optionsFrame:SetFrameStrata("HIGH")
optionsFrame:SetClampedToScreen(true)
optionsFrame:SetClampRectInsets(0, 0, 40, 0)
optionsFrame:SetMovable(true)

local function RegisterDragForOptionsFrame(frame)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function()
        optionsFrame:StartMoving()
    end)
    frame:SetScript("OnDragStop", function()
        optionsFrame:StopMovingOrSizing()
        P:PixelPerfectPoint(optionsFrame)
    end)
end

-------------------------------------------------
-- button group
-------------------------------------------------
local generalBtn = Cell:CreateButton(optionsFrame, L["General"], "class-hover", {105, 20}, false, false, "CELL_FONT_WIDGET_TITLE", "CELL_FONT_WIDGET_TITLE_DISABLE")
local appearanceBtn = Cell:CreateButton(optionsFrame, L["Appearance"], "class-hover", {105, 20}, false, false, "CELL_FONT_WIDGET_TITLE", "CELL_FONT_WIDGET_TITLE_DISABLE")
local layoutsBtn = Cell:CreateButton(optionsFrame, L["Layouts"], "class-hover", {105, 20}, false, false, "CELL_FONT_WIDGET_TITLE", "CELL_FONT_WIDGET_TITLE_DISABLE")
local clickCastingsBtn = Cell:CreateButton(optionsFrame, L["Click-Castings"], "class-hover", {133, 20}, false, false, "CELL_FONT_WIDGET_TITLE", "CELL_FONT_WIDGET_TITLE_DISABLE")
local indicatorsBtn = Cell:CreateButton(optionsFrame, L["Indicators"], "class-hover", {133, 20}, false, false, "CELL_FONT_WIDGET_TITLE", "CELL_FONT_WIDGET_TITLE_DISABLE")
local debuffsBtn = Cell:CreateButton(optionsFrame, L["Raid Debuffs"], "class-hover", {133, 20}, false, false, "CELL_FONT_WIDGET_TITLE", "CELL_FONT_WIDGET_TITLE_DISABLE")
local aboutBtn = Cell:CreateButton(optionsFrame, L["About"], "class-hover", {66, 20}, false, false, "CELL_FONT_WIDGET_TITLE", "CELL_FONT_WIDGET_TITLE_DISABLE")
local closeBtn = Cell:CreateButton(optionsFrame, "×", "red", {20, 20}, false, false, "CELL_FONT_SPECIAL", "CELL_FONT_SPECIAL")
closeBtn:SetScript("OnClick", function()
    optionsFrame:Hide()
end)

-- line 1
clickCastingsBtn:SetPoint("BOTTOMLEFT", optionsFrame, "TOPLEFT", 0, -1)
indicatorsBtn:SetPoint("LEFT", clickCastingsBtn, "RIGHT", -1, 0)
debuffsBtn:SetPoint("LEFT", indicatorsBtn, "RIGHT", -1, 0)
-- line 2
generalBtn:SetPoint("BOTTOMLEFT", clickCastingsBtn, "TOPLEFT", 0, -1)
appearanceBtn:SetPoint("LEFT", generalBtn, "RIGHT", -1, 0)
layoutsBtn:SetPoint("LEFT", appearanceBtn, "RIGHT", -1, 0)
aboutBtn:SetPoint("LEFT", layoutsBtn, "RIGHT", -1, 0)
closeBtn:SetPoint("LEFT", aboutBtn, "RIGHT", -1, 0)

RegisterDragForOptionsFrame(generalBtn)
RegisterDragForOptionsFrame(appearanceBtn)
RegisterDragForOptionsFrame(layoutsBtn)
RegisterDragForOptionsFrame(clickCastingsBtn)
RegisterDragForOptionsFrame(indicatorsBtn)
RegisterDragForOptionsFrame(debuffsBtn)
RegisterDragForOptionsFrame(aboutBtn)

generalBtn.id = "general"
appearanceBtn.id = "appearance"
layoutsBtn.id = "layouts"
clickCastingsBtn.id = "clickCastings"
indicatorsBtn.id = "indicators"
debuffsBtn.id = "debuffs"
aboutBtn.id = "about"

local tabHeight = {
    ["general"] = 411,
    ["appearance"] = 451,
    ["layouts"] = 480,
    ["clickCastings"] = 401,
    ["indicators"] = 421,
    ["debuffs"] = 401,
    ["about"] = 431,
}

local lastShownTab
local function ShowTab(tab)
    if lastShownTab ~= tab then
        optionsFrame:SetHeight(tabHeight[tab])
        Cell:Fire("ShowOptionsTab", tab)
        lastShownTab = tab
    end
end

local buttonGroup = Cell:CreateButtonGroup({generalBtn, appearanceBtn, layoutsBtn, clickCastingsBtn, indicatorsBtn, debuffsBtn, aboutBtn}, ShowTab)

-------------------------------------------------
-- show & hide
-------------------------------------------------
function F:ShowOptionsFrame()
    if InCombatLockdown() then
        F:Print(L["Can't change options in combat."])
        return
    end

    if optionsFrame:IsShown() then
        optionsFrame:Hide()
        return
    end

    if not lastShownTab then
        generalBtn:Click()
    end
    
    P:PixelPerfectPoint(optionsFrame)
    optionsFrame:Show()
end

optionsFrame:SetScript("OnHide", function()
    -- stolen from dbm
    if not InCombatLockdown() and not UnitAffectingCombat("player") and not IsFalling() then
        F:Debug("|cffff7777collectgarbage")
        collectgarbage("collect")
        -- UpdateAddOnMemoryUsage() -- stuck like hell
    end
end)

optionsFrame:SetScript("OnShow", function()
    P:PixelPerfectPoint(optionsFrame)
end)

optionsFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
optionsFrame:SetScript("OnEvent", function()
    optionsFrame:Hide()
end)

-- for Raid Debuffs import
function F:ShowRaidDebuffsTab()
    optionsFrame:Show()
    ShowTab("debuffs")
end