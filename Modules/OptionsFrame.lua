---@class Cell
local Cell = select(2, ...)
local L = Cell.L
---@class CellFuncs
local F = Cell.funcs
---@type AbstractFramework
local AF = _G.AbstractFramework

local lastShownTab

local optionsFrame = AF.CreateBorderedFrame(CellMainFrame, "CellOptionsFrame", 450, 535) -- 432, 401
optionsFrame:Hide()
optionsFrame:SetPoint("RIGHT", AF.UIParent, "CENTER", -100, 0)
optionsFrame:SetFrameStrata("DIALOG")
optionsFrame:SetFrameLevel(777)
optionsFrame:SetClampedToScreen(true)
optionsFrame:SetClampRectInsets(0, 0, 40, 0)
optionsFrame:SetMovable(true)

optionsFrame:SetScript("OnHide", function()
    if not (InCombatLockdown() or IsFalling()) then
        AF.Debug("|cffbbbbbbCellOptionsFrame_OnHide: |cffff7777collectgarbage")
        collectgarbage("collect")
        -- UpdateAddOnMemoryUsage() -- stuck like hell
    end
end)

local function RegisterDragForOptionsFrame(frame)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function()
        optionsFrame:StartMoving()
        optionsFrame:SetUserPlaced(false)
    end)
    frame:SetScript("OnDragStop", function()
        optionsFrame:StopMovingOrSizing()
        AF.SavePositionAsTable(optionsFrame, CellDB["optionsFramePosition"])
        AF.ReAnchorRegion(optionsFrame, "TOPLEFT")
    end)
end

-------------------------------------------------
-- button group
-------------------------------------------------
local generalBtn, appearanceBtn, clickCastingsBtn, aboutBtn, layoutsBtn, indicatorsBtn, debuffsBtn, utilitiesBtn, closeBtn

local function InitOptionsFrame()
    -- row 1
    layoutsBtn = AF.CreateButton(optionsFrame, L["Layouts"], "Cell_hover", 110, 20, nil, nil, nil, "AF_FONT_TITLE")
    indicatorsBtn = AF.CreateButton(optionsFrame, L["Indicators"], "Cell_hover", 110, 20, nil, nil, nil, "AF_FONT_TITLE")
    debuffsBtn = AF.CreateButton(optionsFrame, L["Raid Debuffs"], "Cell_hover", 120, 20, nil, nil, nil, "AF_FONT_TITLE")
    utilitiesBtn = AF.CreateButton(optionsFrame, L["Utilities"], "Cell_hover", nil, 20, nil, nil, nil, "AF_FONT_TITLE")

    AF.SetPoint(layoutsBtn, "BOTTOMLEFT", optionsFrame, "TOPLEFT", 0, -1)
    AF.SetPoint(indicatorsBtn, "BOTTOMLEFT", layoutsBtn, "BOTTOMRIGHT", -1, 0)
    AF.SetPoint(debuffsBtn, "BOTTOMLEFT", indicatorsBtn, "BOTTOMRIGHT", -1, 0)
    AF.SetPoint(utilitiesBtn, "BOTTOMLEFT", debuffsBtn, "BOTTOMRIGHT", -1, 0)
    AF.SetPoint(utilitiesBtn, "BOTTOMRIGHT", optionsFrame, "TOPRIGHT", 0, -1)

    -- row 2
    generalBtn = AF.CreateButton(optionsFrame, L["General"], "Cell_hover", 110, 20, nil, nil, nil, "AF_FONT_TITLE")
    appearanceBtn = AF.CreateButton(optionsFrame, L["Appearance"], "Cell_hover", 110, 20, nil, nil, nil, "AF_FONT_TITLE")
    clickCastingsBtn = AF.CreateButton(optionsFrame, L["Click-Castings"], "Cell_hover", 120, 20, nil, nil, nil, "AF_FONT_TITLE")
    aboutBtn = AF.CreateButton(optionsFrame, L["About"], "Cell_hover", nil, 20, nil, nil, nil, "AF_FONT_TITLE")
    closeBtn = AF.CreateCloseButton(optionsFrame, optionsFrame, 20, 20)

    AF.SetPoint(generalBtn, "BOTTOMLEFT", layoutsBtn, "TOPLEFT", 0, -1)
    AF.SetPoint(appearanceBtn, "BOTTOMLEFT", generalBtn, "BOTTOMRIGHT", -1, 0)
    AF.SetPoint(clickCastingsBtn, "BOTTOMLEFT", appearanceBtn, "BOTTOMRIGHT", -1, 0)
    AF.SetPoint(aboutBtn, "BOTTOMLEFT", clickCastingsBtn, "BOTTOMRIGHT", -1, 0)
    AF.SetPoint(aboutBtn, "BOTTOMRIGHT", closeBtn, "BOTTOMLEFT", 1, 0)
    AF.SetPoint(closeBtn, "BOTTOMRIGHT", utilitiesBtn, "TOPRIGHT", 0, -1)

    -- frame shadow
    AF.ShowNormalGlow(optionsFrame, "shadow", 2)
    AF.ClearPoints(optionsFrame.normalGlow)
    AF.SetPoint(optionsFrame.normalGlow, "TOPLEFT", generalBtn, -2, 2)
    AF.SetPoint(optionsFrame.normalGlow, "BOTTOMRIGHT", f, 2, -2)

    -- button group
    local buttons = {
        generalBtn,
        appearanceBtn,
        layoutsBtn,
        clickCastingsBtn,
        indicatorsBtn,
        debuffsBtn,
        utilitiesBtn,
        aboutBtn,
    }

    for _, b in pairs(buttons) do
        RegisterDragForOptionsFrame(b)
    end

    generalBtn.id = "general"
    appearanceBtn.id = "appearance"
    layoutsBtn.id = "layouts"
    clickCastingsBtn.id = "clickCastings"
    indicatorsBtn.id = "indicators"
    debuffsBtn.id = "debuffs"
    utilitiesBtn.id = "utilities"
    aboutBtn.id = "about"

    local tabHeight = {
        ["general"] = 535,
        ["appearance"] = 665,
        ["layouts"] = 550,
        ["clickCastings"] = 592,
        ["indicators"] = 607,
        ["debuffs"] = 521,
        ["utilities"] = 400,
        ["about"] = 650,
    }

    local function ShowTab(tab)
        if lastShownTab ~= tab then
            AF.SetHeight(optionsFrame, tabHeight[tab])
            Cell.Fire("ShowOptionsTab", tab)
            lastShownTab = tab
        end
    end

    local function OnEnter(b)
        if b.id == utilitiesBtn.id then
            F.ShowUtilityList(b)
        else
            F.HideUtilityList()
        end
        if utilitiesBtn.timer then
            utilitiesBtn.timer:Cancel()
            utilitiesBtn.timer = nil
        end
    end

    local function OnLeave(b)
        if b.id == utilitiesBtn.id then
            utilitiesBtn.timer = C_Timer.NewTicker(0.5, function()
                if not F.IsUtilityListMouseover() then
                    F.HideUtilityList()
                    utilitiesBtn.timer:Cancel()
                    utilitiesBtn.timer = nil
                end
            end)
        end
    end

    AF.CreateButtonGroup(buttons, ShowTab, nil, nil, OnEnter, OnLeave)

    F.CreateUtilityList(utilitiesBtn)
end

-------------------------------------------------
-- show & hide
-------------------------------------------------
local init
local function Init()
    if not init then
        init = true
        InitOptionsFrame()
        AF.LoadPosition(optionsFrame, CellDB["optionsFramePosition"], AF.UIParent)
        optionsFrame:UpdatePixels()
        AF.ReAnchorRegion(optionsFrame, "TOPLEFT")
        print(optionsFrame:GetPoint(1))
    end
end

function F.ShowOptionsFrame()
    Init()

    if optionsFrame:IsShown() then
        optionsFrame:Hide()
        return
    end

    if not lastShownTab then
        generalBtn:SilentClick()
    end

    optionsFrame:Show()
end

-- for Raid Debuffs import
function F.ShowRaidDebuffsTab()
    Init()
    optionsFrame:Show()
    debuffsBtn:SilentClick()
end

-- for layout import
function F.ShowLayousTab()
    Init()
    optionsFrame:Show()
    layoutsBtn:SilentClick()
end

function F.ShowUtilitiesTab()
    Init()
    optionsFrame:Show()
    utilitiesBtn:SilentClick()
end