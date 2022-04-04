local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

local generalTab = Cell:CreateFrame("CellOptionsFrame_GeneralTab", Cell.frames.optionsFrame, nil, nil, true)
Cell.frames.generalTab = generalTab
generalTab:SetAllPoints(Cell.frames.optionsFrame)
generalTab:Hide()

-------------------------------------------------
-- visibility
-------------------------------------------------
local showSoloCB, showPartyCB, showPartyPetsCB

local function CreateVisibilityPane()
    local visibilityPane = Cell:CreateTitledPane(generalTab, L["Visibility"], 205, 100)
    visibilityPane:SetPoint("TOPLEFT", generalTab, "TOPLEFT", 5, -5)
    
    showSoloCB = Cell:CreateCheckButton(visibilityPane, L["Show Solo"], function(checked, self)
        CellDB["general"]["showSolo"] = checked
        Cell:Fire("UpdateVisibility", "solo")
    end, L["Show Solo"], L["Show while not in a group"], L["To open options frame, use /cell options"])
    showSoloCB:SetPoint("TOPLEFT", visibilityPane, "TOPLEFT", 5, -27)
    
    showPartyCB = Cell:CreateCheckButton(visibilityPane, L["Show Party"], function(checked, self)
        CellDB["general"]["showParty"] = checked
        Cell:Fire("UpdateVisibility", "party")
        showPartyPetsCB:SetEnabled(checked)
    end, L["Show Party"], L["Show while in a party"], L["To open options frame, use /cell options"])
    showPartyCB:SetPoint("TOPLEFT", showSoloCB, "BOTTOMLEFT", 0, -7)
    
    showPartyPetsCB = Cell:CreateCheckButton(visibilityPane, L["Show Party Pets"], function(checked, self)
        CellDB["general"]["showPartyPets"] = checked
        Cell:Fire("UpdateVisibility", "pets")
    end, L["Show Party Pets"], L["Show pets while in a party"])
    showPartyPetsCB:SetPoint("TOPLEFT", showPartyCB, "BOTTOMLEFT", 0, -7)
end

-------------------------------------------------
-- tooltip
-------------------------------------------------
local enableTooltipsCB, hideTooltipsInCombatCB, tooltipsAnchor, tooltipsAnchorText, tooltipsAnchoredTo, tooltipsAnchoredToText, tooltipsX, tooltipsY

local function UpdateTooltipsOptions()
    if strfind(CellDB["general"]["tooltipsPosition"][2], "Cursor") or CellDB["general"]["tooltipsPosition"][2] == "Default" then
        tooltipsAnchor:SetEnabled(false)
        tooltipsAnchorText:SetTextColor(0.4, 0.4, 0.4)
    else
        tooltipsAnchor:SetEnabled(true)
        tooltipsAnchorText:SetTextColor(1, 1, 1)
    end

    if CellDB["general"]["tooltipsPosition"][2] == "Cursor" or CellDB["general"]["tooltipsPosition"][2] == "Default" then
        tooltipsX:SetEnabled(false)
        tooltipsY:SetEnabled(false)
    else
        tooltipsX:SetEnabled(true)
        tooltipsY:SetEnabled(true)
    end
end

function F:ShowTooltips(anchor, tooltipType, value)
    if not CellDB["general"]["enableTooltips"] or (CellDB["general"]["hideTooltipsInCombat"] and InCombatLockdown()) then return end
    
    if CellDB["general"]["tooltipsPosition"][2] == "Default" then
        GameTooltip_SetDefaultAnchor(GameTooltip, anchor)
    elseif CellDB["general"]["tooltipsPosition"][2] == "Cell" then
        GameTooltip:SetOwner(Cell.frames.mainFrame, "ANCHOR_NONE")
        GameTooltip:SetPoint(CellDB["general"]["tooltipsPosition"][1], Cell.frames.mainFrame, CellDB["general"]["tooltipsPosition"][3], CellDB["general"]["tooltipsPosition"][4], CellDB["general"]["tooltipsPosition"][5])
    elseif CellDB["general"]["tooltipsPosition"][2] == "Unit Button" then
        GameTooltip:SetOwner(anchor, "ANCHOR_NONE")
        GameTooltip:SetPoint(CellDB["general"]["tooltipsPosition"][1], anchor, CellDB["general"]["tooltipsPosition"][3], CellDB["general"]["tooltipsPosition"][4], CellDB["general"]["tooltipsPosition"][5])
    elseif CellDB["general"]["tooltipsPosition"][2] == "Cursor" then
        GameTooltip:SetOwner(anchor, "ANCHOR_CURSOR")
    elseif CellDB["general"]["tooltipsPosition"][2] == "Cursor Left" then
        GameTooltip:SetOwner(anchor, "ANCHOR_CURSOR_LEFT", CellDB["general"]["tooltipsPosition"][4], CellDB["general"]["tooltipsPosition"][5])
    elseif CellDB["general"]["tooltipsPosition"][2] == "Cursor Right" then
        GameTooltip:SetOwner(anchor, "ANCHOR_CURSOR_RIGHT", CellDB["general"]["tooltipsPosition"][4], CellDB["general"]["tooltipsPosition"][5])
    end

    if tooltipType == "unit" then
        GameTooltip:SetUnit(value)
    elseif tooltipType == "spell" then
        GameTooltip:SetSpellByID(value)
    end
end

local function CreateTooltipsPane()
    local tooltipsPane = Cell:CreateTitledPane(generalTab, L["Tooltips"], 205, 200)
    tooltipsPane:SetPoint("TOPLEFT", generalTab, "TOPLEFT", 222, -5)

    enableTooltipsCB = Cell:CreateCheckButton(tooltipsPane, L["Enabled"], function(checked, self)
        CellDB["general"]["enableTooltips"] = checked
        hideTooltipsInCombatCB:SetEnabled(checked)
        -- enableAuraTooltipsCB:SetEnabled(checked)
        tooltipsAnchor:SetEnabled(checked)
        tooltipsAnchoredTo:SetEnabled(checked)
        tooltipsX:SetEnabled(checked)
        tooltipsY:SetEnabled(checked)
        if checked then
            tooltipsAnchorText:SetTextColor(1, 1, 1)
            tooltipsAnchoredToText:SetTextColor(1, 1, 1)
            UpdateTooltipsOptions()
        else
            tooltipsAnchorText:SetTextColor(.4, .4, .4)
            tooltipsAnchoredToText:SetTextColor(.4, .4, .4)
        end
    end)
    enableTooltipsCB:SetPoint("TOPLEFT", tooltipsPane, "TOPLEFT", 5, -27)

    hideTooltipsInCombatCB = Cell:CreateCheckButton(tooltipsPane, L["Hide in Combat"], function(checked, self)
        CellDB["general"]["hideTooltipsInCombat"] = checked
    end)
    hideTooltipsInCombatCB:SetPoint("TOPLEFT", enableTooltipsCB, "BOTTOMLEFT", 0, -7)

    -- auras tooltips
    enableAuraTooltipsCB = Cell:CreateCheckButton(tooltipsPane, L["Enable Auras Tooltips"], function(checked, self)
    end)
    enableAuraTooltipsCB:SetPoint("TOPLEFT", hideTooltipsInCombatCB, "BOTTOMLEFT", 0, -7)
    enableAuraTooltipsCB:SetEnabled(false)

    -- position
    tooltipsAnchor = Cell:CreateDropdown(tooltipsPane, 97)
    tooltipsAnchor:SetPoint("TOPLEFT", enableAuraTooltipsCB, "BOTTOMLEFT", 0, -30)
    local points = {"BOTTOM", "BOTTOMLEFT", "BOTTOMRIGHT", "LEFT", "RIGHT", "TOP", "TOPLEFT", "TOPRIGHT"}
    local relativePoints = {"TOP", "TOPLEFT", "TOPRIGHT", "RIGHT", "LEFT", "BOTTOM", "BOTTOMLEFT", "BOTTOMRIGHT"}
    local anchorItems = {}
    for i, point in pairs(points) do
        tinsert(anchorItems, {
            ["text"] = L[point],
            ["value"] = point,
            ["onClick"] = function()
                CellDB["general"]["tooltipsPosition"][1] = point
                CellDB["general"]["tooltipsPosition"][3] = relativePoints[i]
            end,
        })
    end
    tooltipsAnchor:SetItems(anchorItems)

    tooltipsAnchorText = tooltipsPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    tooltipsAnchorText:SetText(L["Anchor Point"])
    tooltipsAnchorText:SetPoint("BOTTOMLEFT", tooltipsAnchor, "TOPLEFT", 0, 1)

    tooltipsAnchoredTo = Cell:CreateDropdown(tooltipsPane, 97)
    tooltipsAnchoredTo:SetPoint("TOPLEFT", tooltipsAnchor, "TOPRIGHT", 5, 0)
    local relatives = {"Default", "Cell", "Unit Button", "Cursor", "Cursor Left", "Cursor Right"}
    local relativeToItems = {}
    for _, relative in pairs(relatives) do
        tinsert(relativeToItems, {
            ["text"] = L[relative],
            ["value"] = relative,
            ["onClick"] = function()
                CellDB["general"]["tooltipsPosition"][2] = relative
                UpdateTooltipsOptions()
            end,
        })
    end
    tooltipsAnchoredTo:SetItems(relativeToItems)

    tooltipsAnchoredToText = tooltipsPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    tooltipsAnchoredToText:SetText(L["Anchored To"])
    tooltipsAnchoredToText:SetPoint("BOTTOMLEFT", tooltipsAnchoredTo, "TOPLEFT", 0, 1)

    tooltipsX = Cell:CreateSlider(L["X Offset"], tooltipsPane, -99, 99, 97, 1)
    tooltipsX:SetPoint("TOPLEFT", tooltipsAnchor, "BOTTOMLEFT", 0, -25)
    tooltipsX.afterValueChangedFn = function(value)
        CellDB["general"]["tooltipsPosition"][4] = value
    end

    tooltipsY = Cell:CreateSlider(L["Y Offset"], tooltipsPane, -99, 99, 97, 1)
    tooltipsY:SetPoint("TOPLEFT", tooltipsAnchoredTo, "BOTTOMLEFT", 0, -25)
    tooltipsY.afterValueChangedFn = function(value)
        CellDB["general"]["tooltipsPosition"][5] = value
    end
end

-------------------------------------------------
-- misc
-------------------------------------------------
local hideBlizzardCB, lockCB, fadeoutCB, sortByRoleCB

local function CreateMiscPane()
    local miscPane = Cell:CreateTitledPane(generalTab, L["Misc"], 205, 120)
    miscPane:SetPoint("TOPLEFT", generalTab, "TOPLEFT", 5, -120)
    
    -- local blizzardText = Cell:CreateSeparator(L["Blizzard Frames"], generalTab, 205)
    -- blizzardText:SetPoint("TOPLEFT", 5, -5)
    hideBlizzardCB = Cell:CreateCheckButton(miscPane, L["Hide Blizzard Raid / Party"], function(checked, self)
        CellDB["general"]["hideBlizzard"] = checked
    
        local popup = Cell:CreateConfirmPopup(generalTab, 200, L["A UI reload is required.\nDo it now?"], function()
            ReloadUI()
        end, nil, true)
        popup:SetPoint("TOPLEFT", generalTab, "TOPLEFT", 117, -170)
    end, L["Hide Blizzard Frames"], L["Require reload of the UI"])
    hideBlizzardCB:SetPoint("TOPLEFT", miscPane, "TOPLEFT", 5, -27)
    
    lockCB = Cell:CreateCheckButton(miscPane, L["Lock Cell Frame"], function(checked, self)
        CellDB["general"]["locked"] = checked
        F:UpdateFrameLock(checked)
    end)
    lockCB:SetPoint("TOPLEFT", hideBlizzardCB, "BOTTOMLEFT", 0, -7)
    
    fadeoutCB = Cell:CreateCheckButton(miscPane, L["Fade Out Menu"], function(checked, self)
        CellDB["general"]["fadeOut"] = checked
        F:UpdateMenuFadeOut(checked)
    end, L["Fade Out Menu"], L["Fade out menu buttons on mouseout"])
    fadeoutCB:SetPoint("TOPLEFT", lockCB, "BOTTOMLEFT", 0, -7)
    
    sortByRoleCB = Cell:CreateCheckButton(miscPane, L["Sort Party By Role"], function(checked, self)
        CellDB["general"]["sortPartyByRole"] = checked
        Cell:Fire("UpdateSortMethod")
    end)
    sortByRoleCB:SetPoint("TOPLEFT", fadeoutCB, "BOTTOMLEFT", 0, -7)
end

-------------------------------------------------
-- functions
-------------------------------------------------
local init
local function ShowTab(tab)
    if tab == "general" then
        if not init then
            CreateVisibilityPane()
            CreateTooltipsPane()
            CreateMiscPane()
        end 

        generalTab:Show()

        if init then return end
        init = true

        -- tooltips
        enableTooltipsCB:SetChecked(CellDB["general"]["enableTooltips"])
        hideTooltipsInCombatCB:SetEnabled(CellDB["general"]["enableTooltips"])
        hideTooltipsInCombatCB:SetChecked(CellDB["general"]["hideTooltipsInCombat"])
        -- enableAuraTooltipsCB:SetEnabled(CellDB["general"]["enableTooltips"])
        -- enableAuraTooltipsCB:SetChecked(CellDB["general"]["enableAurasTooltips"])
        tooltipsAnchor:SetEnabled(CellDB["general"]["enableTooltips"])
        tooltipsAnchor:SetSelectedValue(CellDB["general"]["tooltipsPosition"][1])
        tooltipsAnchoredTo:SetEnabled(CellDB["general"]["enableTooltips"])
        tooltipsAnchoredTo:SetSelectedValue(CellDB["general"]["tooltipsPosition"][2])
        tooltipsX:SetEnabled(CellDB["general"]["enableTooltips"])
        tooltipsX:SetValue(CellDB["general"]["tooltipsPosition"][4])
        tooltipsY:SetEnabled(CellDB["general"]["enableTooltips"])
        tooltipsY:SetValue(CellDB["general"]["tooltipsPosition"][5])
        if CellDB["general"]["enableTooltips"] then
            tooltipsAnchorText:SetTextColor(1, 1, 1)
            tooltipsAnchoredToText:SetTextColor(1, 1, 1)
            UpdateTooltipsOptions()
        else
            tooltipsAnchorText:SetTextColor(.4, .4, .4)
            tooltipsAnchoredToText:SetTextColor(.4, .4, .4)
        end

        -- visibility
        showSoloCB:SetChecked(CellDB["general"]["showSolo"])
        showPartyCB:SetChecked(CellDB["general"]["showParty"])
        showPartyPetsCB:SetChecked(CellDB["general"]["showPartyPets"])
        showPartyPetsCB:SetEnabled(CellDB["general"]["showParty"])

        -- misc
        hideBlizzardCB:SetChecked(CellDB["general"]["hideBlizzard"])
        lockCB:SetChecked(CellDB["general"]["locked"])
        fadeoutCB:SetChecked(CellDB["general"]["fadeOut"])
        sortByRoleCB:SetChecked(CellDB["general"]["sortPartyByRole"])
    else
        generalTab:Hide()
    end
end
Cell:RegisterCallback("ShowOptionsTab", "GeneralTab_ShowTab", ShowTab)