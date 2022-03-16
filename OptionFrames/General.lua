local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

local generalTab = Cell:CreateFrame("CellOptionsFrame_GeneralTab", Cell.frames.optionsFrame, nil, nil, true)
Cell.frames.generalTab = generalTab
generalTab:SetAllPoints(Cell.frames.optionsFrame)
generalTab:Hide()

-------------------------------------------------
-- tooltip
-------------------------------------------------
local tooltipsText = Cell:CreateSeparator(L["Tooltips"], generalTab, 188)
tooltipsText:SetPoint("TOPLEFT", 203, -5)

local enableTooltipsCB, hideTooltipsInCombatCB, tooltipsAnchor, tooltipsAnchorText, tooltipsAnchoredTo, tooltipsAnchoredToText, tooltipsX, tooltipsY

local function UpdateTooltipsOptions()
    if strfind(CellDB["general"]["tooltipsPosition"][2], "Cursor") then
        tooltipsAnchor:SetEnabled(false)
        tooltipsAnchorText:SetTextColor(.4, .4, .4)
    else
        tooltipsAnchor:SetEnabled(true)
        tooltipsAnchorText:SetTextColor(1, 1, 1)
    end

    if CellDB["general"]["tooltipsPosition"][2] == "Cursor" then
        tooltipsX:SetEnabled(false)
        tooltipsY:SetEnabled(false)
    else
        tooltipsX:SetEnabled(true)
        tooltipsY:SetEnabled(true)
    end
end

function F:ShowTooltips(anchor, tooltipType, value)
    if not CellDB["general"]["enableTooltips"] or (CellDB["general"]["hideTooltipsInCombat"] and InCombatLockdown()) then return end
    
    if CellDB["general"]["tooltipsPosition"][2] == "Cell" then
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

enableTooltipsCB = Cell:CreateCheckButton(generalTab, L["Enabled"], function(checked, self)
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
enableTooltipsCB:SetPoint("TOPLEFT", tooltipsText, "BOTTOMLEFT", 5, -15)

hideTooltipsInCombatCB = Cell:CreateCheckButton(generalTab, L["Hide in Combat"], function(checked, self)
    CellDB["general"]["hideTooltipsInCombat"] = checked
end)
hideTooltipsInCombatCB:SetPoint("TOPLEFT", enableTooltipsCB, "BOTTOMLEFT", 0, -7)

-- auras tooltips
enableAuraTooltipsCB = Cell:CreateCheckButton(generalTab, L["Enable Auras Tooltips"], function(checked, self)
end)
enableAuraTooltipsCB:SetPoint("TOPLEFT", hideTooltipsInCombatCB, "BOTTOMLEFT", 0, -7)
enableAuraTooltipsCB:SetEnabled(false)

-- position
tooltipsAnchor = Cell:CreateDropdown(generalTab, 89)
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

tooltipsAnchorText = generalTab:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
tooltipsAnchorText:SetText(L["Anchor Point"])
tooltipsAnchorText:SetPoint("BOTTOMLEFT", tooltipsAnchor, "TOPLEFT", 0, 1)

tooltipsAnchoredTo = Cell:CreateDropdown(generalTab, 89)
tooltipsAnchoredTo:SetPoint("TOPLEFT", tooltipsAnchor, "TOPRIGHT", 5, 0)
local relatives = {"Cell", "Unit Button", "Cursor", "Cursor Left", "Cursor Right"}
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

tooltipsAnchoredToText = generalTab:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
tooltipsAnchoredToText:SetText(L["Anchored To"])
tooltipsAnchoredToText:SetPoint("BOTTOMLEFT", tooltipsAnchoredTo, "TOPLEFT", 0, 1)

tooltipsX = Cell:CreateSlider(L["X Offset"], generalTab, -99, 99, 89, 1)
tooltipsX:SetPoint("TOPLEFT", tooltipsAnchor, "BOTTOMLEFT", 0, -25)
tooltipsX.afterValueChangedFn = function(value)
    CellDB["general"]["tooltipsPosition"][4] = value
end

tooltipsY = Cell:CreateSlider(L["Y Offset"], generalTab, -99, 99, 89, 1)
tooltipsY:SetPoint("TOPLEFT", tooltipsAnchoredTo, "BOTTOMLEFT", 0, -25)
tooltipsY.afterValueChangedFn = function(value)
    CellDB["general"]["tooltipsPosition"][5] = value
end

-------------------------------------------------
-- visibility
-------------------------------------------------
local visibilityText = Cell:CreateSeparator(L["Visibility"], generalTab, 188)
visibilityText:SetPoint("TOPLEFT", 5, -5)

local showSoloCB, showPartyCB, showPartyPetsCB

showSoloCB = Cell:CreateCheckButton(generalTab, L["Show Solo"], function(checked, self)
    CellDB["general"]["showSolo"] = checked
    Cell:Fire("UpdateVisibility", "solo")
end, L["Show Solo"], L["Show while not in a group"], L["To open options frame, use /cell options"])
showSoloCB:SetPoint("TOPLEFT", visibilityText, "BOTTOMLEFT", 5, -15)

showPartyCB = Cell:CreateCheckButton(generalTab, L["Show Party"], function(checked, self)
    CellDB["general"]["showParty"] = checked
    Cell:Fire("UpdateVisibility", "party")
    showPartyPetsCB:SetEnabled(checked)
end, L["Show Party"], L["Show while in a party"], L["To open options frame, use /cell options"])
showPartyCB:SetPoint("TOPLEFT", showSoloCB, "BOTTOMLEFT", 0, -7)

showPartyPetsCB = Cell:CreateCheckButton(generalTab, L["Show Party Pets"], function(checked, self)
    CellDB["general"]["showPartyPets"] = checked
    Cell:Fire("UpdateVisibility", "pets")
end, L["Show Party Pets"], L["Show pets while in a party"])
showPartyPetsCB:SetPoint("TOPLEFT", showPartyCB, "BOTTOMLEFT", 0, -7)

-------------------------------------------------
-- misc
-------------------------------------------------
local miscText = Cell:CreateSeparator(L["Misc"], generalTab, 188)
miscText:SetPoint("TOPLEFT", 5, -120)

-- local blizzardText = Cell:CreateSeparator(L["Blizzard Frames"], generalTab, 188)
-- blizzardText:SetPoint("TOPLEFT", 5, -5)
local hideBlizzardCB = Cell:CreateCheckButton(generalTab, L["Hide Blizzard Raid / Party"], function(checked, self)
    CellDB["general"]["hideBlizzard"] = checked

    local popup = Cell:CreateConfirmPopup(generalTab, 200, L["A UI reload is required.\nDo it now?"], function()
        ReloadUI()
    end, nil, true)
    popup:SetPoint("TOPLEFT", 100, -170)
end, L["Hide Blizzard Frames"], L["Require reload of the UI"])
hideBlizzardCB:SetPoint("TOPLEFT", miscText, "BOTTOMLEFT", 5, -15)

local lockCB = Cell:CreateCheckButton(generalTab, L["Lock Cell Frame"], function(checked, self)
    CellDB["general"]["locked"] = checked
    F:UpdateFrameLock(checked)
end)
lockCB:SetPoint("TOPLEFT", hideBlizzardCB, "BOTTOMLEFT", 0, -7)

local fadeoutCB = Cell:CreateCheckButton(generalTab, L["Fade Out Menu"], function(checked, self)
    CellDB["general"]["fadeOut"] = checked
    F:UpdateMenuFadeOut(checked)
end, L["Fade Out Menu"], L["Fade out menu buttons on mouseout"])
fadeoutCB:SetPoint("TOPLEFT", lockCB, "BOTTOMLEFT", 0, -7)

local sortByRoleCB = Cell:CreateCheckButton(generalTab, L["Sort Party By Role"], function(checked, self)
    CellDB["general"]["sortPartyByRole"] = checked
    Cell:Fire("UpdateSortMethod")
end)
sortByRoleCB:SetPoint("TOPLEFT", fadeoutCB, "BOTTOMLEFT", 0, -7)

-------------------------------------------------
-- raid tools
-------------------------------------------------
local toolsText = Cell:CreateSeparator(L["Raid Tools"].." |cFF777777"..L["Only in Group"], generalTab, 387)
toolsText:SetPoint("TOPLEFT", 5, -255)

local unlockBtn = Cell:CreateButton(generalTab, L["Unlock"], "class", {60, 17})
unlockBtn:SetPoint("RIGHT", -5, 0)
unlockBtn:SetPoint("BOTTOM", toolsText)
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

-- battle res
local resCB = Cell:CreateCheckButton(generalTab, L["Battle Res Timer"], function(checked, self)
    CellDB["raidTools"]["showBattleRes"] = checked
    Cell:Fire("UpdateRaidTools", "battleRes")
end, L["Battle Res Timer"], L["Only show during encounter or in mythic+"])
resCB:SetPoint("TOPLEFT", toolsText, "BOTTOMLEFT", 5, -15)

-- death report
local reportCB = Cell:CreateCheckButton(generalTab, L["Death Report"], function(checked, self)
    CellDB["raidTools"]["deathReport"][1] = checked
    Cell:Fire("UpdateRaidTools", "deathReport")
end)
reportCB:SetPoint("TOPLEFT", resCB, "TOPRIGHT", 115, 0)
reportCB:HookScript("OnEnter", function()
    CellTooltip:SetOwner(reportCB, "ANCHOR_TOPLEFT", 0, 2)
    CellTooltip:AddLine(L["Death Report"].." |cffff2727"..L["HIGH CPU USAGE"])
    CellTooltip:AddLine("|cffff2727" .. L["Disabled in battlegrounds and arenas"])
    CellTooltip:AddLine("|cffffffff" .. L["Report deaths to group"])
    CellTooltip:AddLine("|cffffffff" .. L["Use |cFFFFB5C5/cell report X|r to set the number of reports during a raid encounter"])
    CellTooltip:AddLine("|cffffffff" .. L["Current"]..": |cFFFFB5C5"..(CellDB["raidTools"]["deathReport"][2]==0 and L["all"] or string.format(L["first %d"], CellDB["raidTools"]["deathReport"][2])))
    CellTooltip:Show()
end)
reportCB:HookScript("OnLeave", function()
    CellTooltip:Hide()
end)

-- buff tracker
local buffCB = Cell:CreateCheckButton(generalTab, L["Buff Tracker"], function(checked, self)
    CellDB["raidTools"]["buffTracker"][1] = checked
    Cell:Fire("UpdateRaidTools", "buffTracker")
end, L["Buff Tracker"].." |cffff7727"..L["MODERATE CPU USAGE"], L["Check if your group members need some raid buffs"], L["|cffffb5c5Left-Click:|r cast the spell"], L["|cffffb5c5Right-Click:|r report unaffected"]) -- L["|cffffb5c5Middle-Click:|r send custom message"]
buffCB:SetPoint("TOPLEFT", reportCB, "TOPRIGHT", 115, 0)

-- ready & pull
local pullText, pullDropdown, secDropdown
local readyPullCB = Cell:CreateCheckButton(generalTab, L["ReadyCheck and PullTimer buttons"], function(checked, self)
    CellDB["raidTools"]["readyAndPull"][1] = checked
    pullDropdown:SetEnabled(checked)
    secDropdown:SetEnabled(checked)
    if checked then
        pullText:SetTextColor(1, 1, 1)
    else
        pullText:SetTextColor(.4, .4, .4)
    end
    Cell:Fire("UpdateRaidTools", "buttons")
end, L["ReadyCheck and PullTimer buttons"], L["Only show when you have permission to do this"], L["pullTimerTips"])
readyPullCB:SetPoint("TOPLEFT", resCB, "BOTTOMLEFT", 0, -15)

pullText = generalTab:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
pullText:SetText(L["Pull Timer"])
pullText:SetPoint("TOPLEFT", readyPullCB, "BOTTOMRIGHT", 5, -9)

pullDropdown = Cell:CreateDropdown(generalTab, 75)
pullDropdown:SetPoint("LEFT", pullText, "RIGHT", 7, 0)
pullDropdown:SetItems({
    {
        ["text"] = "ExRT",
        ["onClick"] = function()
            CellDB["raidTools"]["readyAndPull"][2][1] = "ExRT"
            Cell:Fire("UpdateRaidTools", "pullTimer")
        end,
    },
    {
        ["text"] = "DBM",
        ["onClick"] = function()
            CellDB["raidTools"]["readyAndPull"][2][1] = "DBM"
            Cell:Fire("UpdateRaidTools", "pullTimer")
        end,
    },
    {
        ["text"] = "BW",
        ["onClick"] = function()
            CellDB["raidTools"]["readyAndPull"][2][1] = "BW"
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
            CellDB["raidTools"]["readyAndPull"][2][2] = 5
            Cell:Fire("UpdateRaidTools", "pullTimer")
        end,
    },
    {
        ["text"] = 7,
        ["onClick"] = function()
            CellDB["raidTools"]["readyAndPull"][2][2] = 7
            Cell:Fire("UpdateRaidTools", "pullTimer")
        end,
    },
    {
        ["text"] = 10,
        ["onClick"] = function()
            CellDB["raidTools"]["readyAndPull"][2][2] = 10
            Cell:Fire("UpdateRaidTools", "pullTimer")
        end,
    },
    {
        ["text"] = 15,
        ["onClick"] = function()
            CellDB["raidTools"]["readyAndPull"][2][2] = 15
            Cell:Fire("UpdateRaidTools", "pullTimer")
        end,
    },
    {
        ["text"] = 20,
        ["onClick"] = function()
            CellDB["raidTools"]["readyAndPull"][2][2] = 20
            Cell:Fire("UpdateRaidTools", "pullTimer")
        end,
    },
    {
        ["text"] = 25,
        ["onClick"] = function()
            CellDB["raidTools"]["readyAndPull"][2][2] = 25
            Cell:Fire("UpdateRaidTools", "pullTimer")
        end,
    },
    {
        ["text"] = 30,
        ["onClick"] = function()
            CellDB["raidTools"]["readyAndPull"][2][2] = 30
            Cell:Fire("UpdateRaidTools", "pullTimer")
        end,
    },
})

-- marks bar
local marksDropdown
local marksBarCB = Cell:CreateCheckButton(generalTab, L["Marks Bar"], function(checked, self)
    CellDB["raidTools"]["marks"][1] = checked
    marksDropdown:SetEnabled(checked)
    Cell:Fire("UpdateRaidTools", "marks")
end, L["Marks Bar"], L["Only show when you have permission to do this"], L["marksTips"])
marksBarCB:SetPoint("TOPLEFT", readyPullCB, "BOTTOMLEFT", 0, -38)

marksDropdown = Cell:CreateDropdown(generalTab, 150)
marksDropdown:SetPoint("TOPLEFT", marksBarCB, "BOTTOMRIGHT", 5, -5)
marksDropdown:SetItems({
    {
        ["text"] = L["Target Marks"].." (H)",
        ["value"] = "target_h",
        ["onClick"] = function()
            CellDB["raidTools"]["marks"][2] = "target_h"
            Cell:Fire("UpdateRaidTools", "marks")
        end,
    },
    {
        ["text"] = L["Target Marks"].." (V)",
        ["value"] = "target_v",
        ["onClick"] = function()
            CellDB["raidTools"]["marks"][2] = "target_v"
            Cell:Fire("UpdateRaidTools", "marks")
        end,
    },
    {
        ["text"] = L["World Marks"].." (H)",
        ["value"] = "world_h",
        ["onClick"] = function()
            CellDB["raidTools"]["marks"][2] = "world_h"
            Cell:Fire("UpdateRaidTools", "marks")
        end,
    },
    {
        ["text"] = L["World Marks"].." (V)",
        ["value"] = "world_v",
        ["onClick"] = function()
            CellDB["raidTools"]["marks"][2] = "world_v"
            Cell:Fire("UpdateRaidTools", "marks")
        end,
    },
    {
        ["text"] = L["Both"].." (H)",
        ["value"] = "both_h",
        ["onClick"] = function()
            CellDB["raidTools"]["marks"][2] = "both_h"
            Cell:Fire("UpdateRaidTools", "marks")
        end,
    },
    {
        ["text"] = L["Both"].." (V)",
        ["value"] = "both_v",
        ["onClick"] = function()
            CellDB["raidTools"]["marks"][2] = "both_v"
            Cell:Fire("UpdateRaidTools", "marks")
        end,
    }
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

        -- raid tools
        resCB:SetChecked(CellDB["raidTools"]["showBattleRes"])
        reportCB:SetChecked(CellDB["raidTools"]["deathReport"][1])
        buffCB:SetChecked(CellDB["raidTools"]["buffTracker"][1])

        readyPullCB:SetChecked(CellDB["raidTools"]["readyAndPull"][1])
        pullDropdown:SetSelected(CellDB["raidTools"]["readyAndPull"][2][1])
        secDropdown:SetSelected(CellDB["raidTools"]["readyAndPull"][2][2])
        pullDropdown:SetEnabled(CellDB["raidTools"]["readyAndPull"][1])
        secDropdown:SetEnabled(CellDB["raidTools"]["readyAndPull"][1])
        if CellDB["raidTools"]["readyAndPull"][1] then
            pullText:SetTextColor(1, 1, 1)
        else
            pullText:SetTextColor(.4, .4, .4)
        end

        marksDropdown:SetEnabled(CellDB["raidTools"]["marks"][1])
        marksBarCB:SetChecked(CellDB["raidTools"]["marks"][1])
        marksDropdown:SetSelectedValue(CellDB["raidTools"]["marks"][2])
    else
        generalTab:Hide()
    end
end
Cell:RegisterCallback("ShowOptionsTab", "GeneralTab_ShowTab", ShowTab)