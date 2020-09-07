local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local LPP = LibStub:GetLibrary("LibPixelPerfect")

local optionsFrame = Cell:CreateFrame("CellOptionsFrame", Cell.frames.mainFrame, 397, 401)
Cell.frames.optionsFrame = optionsFrame
-- optionsFrame:SetPoint("BOTTOMLEFT", Cell.frames.mainFrame, "TOPLEFT", 0, 16)
optionsFrame:SetPoint("CENTER", UIParent)
optionsFrame:SetFrameStrata("MEDIUM")
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
    end)
end

-------------------------------------------------
-- button group
-------------------------------------------------
local appearanceBtn = Cell:CreateButton(optionsFrame, L["Appearance"], "class-hover", {133, 20}, nil, "CELL_FONT_WIDGET_TITLE", "CELL_FONT_WIDGET_TITLE_DISABLE")
local clickCastingsBtn = Cell:CreateButton(optionsFrame, L["Click-Castings"], "class-hover", {133, 20}, nil, "CELL_FONT_WIDGET_TITLE", "CELL_FONT_WIDGET_TITLE_DISABLE")
local layoutsBtn = Cell:CreateButton(optionsFrame, L["Layouts"], "class-hover", {133, 20}, nil, "CELL_FONT_WIDGET_TITLE", "CELL_FONT_WIDGET_TITLE_DISABLE")
local indicatorsBtn = Cell:CreateButton(optionsFrame, L["Indicators"], "class-hover", {133, 20}, nil, "CELL_FONT_WIDGET_TITLE", "CELL_FONT_WIDGET_TITLE_DISABLE")
local debuffsBtn = Cell:CreateButton(optionsFrame, L["Debuffs"], "class-hover", {133, 20}, nil, "CELL_FONT_WIDGET_TITLE", "CELL_FONT_WIDGET_TITLE_DISABLE")
local aboutBtn = Cell:CreateButton(optionsFrame, L["About"], "class-hover", {114, 20}, nil, "CELL_FONT_WIDGET_TITLE", "CELL_FONT_WIDGET_TITLE_DISABLE")
local closeBtn = Cell:CreateButton(optionsFrame, L["×"], "red", {20, 20}, nil, "CELL_FONT_SPECIAL", "CELL_FONT_SPECIAL")
closeBtn:SetScript("OnClick", function()
    optionsFrame:Hide()
end)

layoutsBtn:SetPoint("BOTTOMLEFT", optionsFrame, "TOPLEFT", 0, -1)
indicatorsBtn:SetPoint("LEFT", layoutsBtn, "RIGHT", -1, 0)
debuffsBtn:SetPoint("LEFT", indicatorsBtn, "RIGHT", -1, 0)
appearanceBtn:SetPoint("BOTTOMLEFT", layoutsBtn, "TOPLEFT", 0, -1)
clickCastingsBtn:SetPoint("LEFT", appearanceBtn, "RIGHT", -1, 0)
aboutBtn:SetPoint("LEFT", clickCastingsBtn, "RIGHT", -1, 0)
closeBtn:SetPoint("LEFT", aboutBtn, "RIGHT", -1, 0)

RegisterDragForOptionsFrame(appearanceBtn)
RegisterDragForOptionsFrame(clickCastingsBtn)
RegisterDragForOptionsFrame(indicatorsBtn)
RegisterDragForOptionsFrame(debuffsBtn)
RegisterDragForOptionsFrame(layoutsBtn)
RegisterDragForOptionsFrame(aboutBtn)

appearanceBtn.target = "appearance"
clickCastingsBtn.target = "clickCastings"
layoutsBtn.target = "layouts"
indicatorsBtn.target = "indicators"
debuffsBtn.target = "debuffs"
aboutBtn.target = "about"

local lastShownTab
local function ShowTab(tab)
    if lastShownTab ~= tab then
        Cell:Fire("ShowOptionsTab", tab)
        lastShownTab = tab
    end
end

local buttonGroup = Cell:CreateButtonGroup(ShowTab, appearanceBtn, clickCastingsBtn, layoutsBtn, indicatorsBtn, debuffsBtn, aboutBtn)

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
        ShowTab("appearance")
        buttonGroup.HighlightButton("appearance")
    end
    
    LPP:PixelPerfectPoint(optionsFrame)
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

optionsFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
optionsFrame:SetScript("OnEvent", function()
    optionsFrame:Hide()
end)