---@class Cell
local Cell = select(2, ...)
local L = Cell.L
local F = Cell.funcs
local B = Cell.bFuncs
---@type AbstractFramework
local AF = _G.AbstractFramework

local generalTab = CreateFrame("Frame", "CellOptionsFrame_GeneralTab", CellOptionsFrame)
generalTab:SetAllPoints(CellOptionsFrame)
generalTab:Hide()

---------------------------------------------------------------------
-- visibility
---------------------------------------------------------------------
local hideBlizzardPartyCB, hideBlizzardRaidCB

local function CreateVisibilityPane()
    local visibilityPane = AF.CreateTitledPane(generalTab, L["Visibility"], 212, 80)
    AF.SetPoint(visibilityPane, "TOPLEFT", generalTab, "TOPLEFT", 7, -7)

    hideBlizzardPartyCB = AF.CreateCheckButton(visibilityPane, L["Hide Blizzard Party"], function(checked, self)
        CellDB["general"]["hideBlizzardParty"] = checked

        local dialog = AF.GetDialog(generalTab, L["A UI reload is required.\nDo it now?"])
        dialog:SetOnConfirm(ReloadUI)
        AF.SetPoint(dialog, "TOP", generalTab, 0, -77)
    end)
    hideBlizzardPartyCB:SetTooltip(L["Hide Blizzard Frames"], L["Require reload of the UI"])
    AF.SetPoint(hideBlizzardPartyCB, "TOPLEFT", visibilityPane, 5, -27)

    hideBlizzardRaidCB = AF.CreateCheckButton(visibilityPane, L["Hide Blizzard Raid"], function(checked, self)
        CellDB["general"]["hideBlizzardRaid"] = checked

        local dialog = AF.GetDialog(generalTab, L["A UI reload is required.\nDo it now?"])
        dialog:SetOnConfirm(ReloadUI)
        AF.SetPoint(dialog, "TOP", generalTab, 0, -77)
    end)
    hideBlizzardRaidCB:SetTooltip(L["Hide Blizzard Frames"], L["Require reload of the UI"])
    AF.SetPoint(hideBlizzardRaidCB, "TOPLEFT", hideBlizzardPartyCB, "BOTTOMLEFT", 0, -7)
end

---------------------------------------------------------------------
-- tooltip
---------------------------------------------------------------------
local enableTooltipsCB, hideTooltipsInCombatCB, tooltipsAnchorDD, tooltipsAnchoredToDD, tooltipsX, tooltipsY

local function UpdateTooltipsOptions()
    if strfind(CellDB["general"]["tooltipsPosition"][2], "Cursor") or CellDB["general"]["tooltipsPosition"][2] == "Default" then
        tooltipsAnchorDD:SetEnabled(false)
    else
        tooltipsAnchorDD:SetEnabled(true)
    end

    if CellDB["general"]["tooltipsPosition"][2] == "Cursor" or CellDB["general"]["tooltipsPosition"][2] == "Default" then
        tooltipsX:SetEnabled(false)
        tooltipsY:SetEnabled(false)
    else
        tooltipsX:SetEnabled(true)
        tooltipsY:SetEnabled(true)
    end
end

local function CreateTooltipsPane()
    local tooltipsPane = AF.CreateTitledPane(generalTab, L["Tooltips"], 212, 270)
    AF.SetPoint(tooltipsPane, "TOPRIGHT", generalTab, -7, -7)

    enableTooltipsCB = AF.CreateCheckButton(tooltipsPane, L["Enabled"], function(checked, self)
        CellDB["general"]["enableTooltips"] = checked
        hideTooltipsInCombatCB:SetEnabled(checked)
        tooltipsAnchorDD:SetEnabled(checked)
        tooltipsAnchoredToDD:SetEnabled(checked)
        tooltipsX:SetEnabled(checked)
        tooltipsY:SetEnabled(checked)
    end)
    AF.SetPoint(enableTooltipsCB, "TOPLEFT", tooltipsPane, "TOPLEFT", 5, -27)

    hideTooltipsInCombatCB = AF.CreateCheckButton(tooltipsPane, L["Hide in Combat"], function(checked, self)
        CellDB["general"]["hideTooltipsInCombat"] = checked
    end)
    hideTooltipsInCombatCB:SetTooltip(L["Hide in Combat"], L["Hide tooltips for units"], L["This will not affect aura tooltips"])
    AF.SetPoint(hideTooltipsInCombatCB, "TOPLEFT", enableTooltipsCB, "BOTTOMLEFT", 0, -7)

    -- position
    tooltipsAnchorDD = AF.CreateDropdown(tooltipsPane, 150)
    AF.SetPoint(tooltipsAnchorDD, "TOPLEFT", hideTooltipsInCombatCB, "BOTTOMLEFT", 0, -25)
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
    tooltipsAnchorDD:SetItems(anchorItems)
    tooltipsAnchorDD:SetLabel(L["Anchor Point"])

    tooltipsAnchoredToDD = AF.CreateDropdown(tooltipsPane, 150)
    AF.SetPoint(tooltipsAnchoredToDD, "TOPLEFT", tooltipsAnchorDD, "BOTTOMLEFT", 0, -25)
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
    tooltipsAnchoredToDD:SetItems(relativeToItems)
    tooltipsAnchoredToDD:SetLabel(L["Anchored To"])

    tooltipsX = AF.CreateSlider(tooltipsPane, L["X Offset"], 150, -100, 100, 1, nil, true)
    AF.SetPoint(tooltipsX, "TOPLEFT", tooltipsAnchoredToDD, "BOTTOMLEFT", 0, -25)
    tooltipsX:SetAfterValueChanged(function(value)
        CellDB["general"]["tooltipsPosition"][4] = value
    end)

    tooltipsY = AF.CreateSlider(tooltipsPane, L["Y Offset"], 150, -100, 100, 1, nil, true)
    AF.SetPoint(tooltipsY, "TOPLEFT", tooltipsX, "BOTTOMLEFT", 0, -40)
    tooltipsY:SetAfterValueChanged(function(value)
        CellDB["general"]["tooltipsPosition"][5] = value
    end)
end

---------------------------------------------------------------------
-- position
---------------------------------------------------------------------
local lockCB, fadeOutCB, menuPositionDD

local function CreatePositionPane()
    local positionPane = AF.CreateTitledPane(generalTab, L["Position"], 212, 120)
    AF.SetPoint(positionPane, "TOPLEFT", generalTab, 7, -120)

    lockCB = AF.CreateCheckButton(positionPane, L["Lock Cell Frames"], function(checked, self)
        CellDB["general"]["locked"] = checked
        Cell.Fire("UpdateMenu", "lock")
    end)
    AF.SetPoint(lockCB, "TOPLEFT", 5, -27)

    fadeOutCB = AF.CreateCheckButton(positionPane, L["Fade Out Menu"], function(checked, self)
        CellDB["general"]["fadeOut"] = checked
        Cell.Fire("UpdateMenu", "fadeOut")
    end, L["Fade Out Menu"], L["Fade out menu buttons on mouseout"])
    AF.SetPoint(fadeOutCB, "TOPLEFT", lockCB, "BOTTOMLEFT", 0, -7)

    menuPositionDD = AF.CreateDropdown(positionPane, 150)
    AF.SetPoint(menuPositionDD, "TOPLEFT", fadeOutCB, "BOTTOMLEFT", 0, -25)
    menuPositionDD:SetLabel(L["Menu Position"])
    menuPositionDD:SetItems({
        {
            ["text"] = L["TOP"].." / "..L["BOTTOM"],
            ["value"] = "top_bottom",
            ["onClick"] = function()
                CellDB["general"]["menuPosition"] = "top_bottom"
                Cell.Fire("UpdateMenu", "position")
            end,
        },
        {
            ["text"] = L["LEFT"].." / "..L["RIGHT"],
            ["value"] = "left_right",
            ["onClick"] = function()
                CellDB["general"]["menuPosition"] = "left_right"
                Cell.Fire("UpdateMenu", "position")
            end,
        },
    })
end

---------------------------------------------------------------------
-- nickname
---------------------------------------------------------------------
local nicknameEB, syncCB
local function CreateNicknamePane()
    local nicknamePane = AF.CreateTitledPane(generalTab, L["Nickname"], 212, 130)
    AF.SetPoint(nicknamePane, "TOPLEFT", generalTab, 7, -300)

    -- my nickname
    nicknameEB = AF.CreateEditBox(nicknamePane, L["My Nickname"], 150, 20, "trim")
    AF.SetPoint(nicknameEB, "TOPLEFT", 5, -27)
    nicknameEB:SetConfirmButton(function(text)
        CellDB["nicknames"]["mine"] = text
        Cell.Fire("UpdateNicknames", "mine", text)
    end)

    -- sync with others
    syncCB = AF.CreateCheckButton(nicknamePane, L["Nickname Sync"], function(checked, self)
        CellDB["nicknames"]["sync"] = checked
        Cell.Fire("UpdateNicknames", "sync", checked)
    end)
    AF.SetPoint(syncCB, "TOPLEFT", nicknameEB, "BOTTOMLEFT", 0, -7)

    -- custom nicknames
    local customNicknamesBtn = AF.CreateButton(nicknamePane, L["Custom Nicknames"], "Cell_hover", 150, 20)
    AF.SetPoint(customNicknamesBtn, "TOPLEFT", syncCB, "BOTTOMLEFT", 0, -7)
    generalTab.customNicknamesBtn = customNicknamesBtn
    customNicknamesBtn:SetOnClick(F.ShowCustomNicknames)

    -- custom
    local blacklistBtn = AF.CreateButton(nicknamePane, L["Nickname Blacklist"], "Cell_hover", 150, 20)
    AF.SetPoint(blacklistBtn, "TOPLEFT", customNicknamesBtn, "BOTTOMLEFT", 0, -7)
    generalTab.nicknameBlacklistBtn = blacklistBtn
    blacklistBtn:SetOnClick(F.ShowNicknameBlacklist)
end

---------------------------------------------------------------------
-- misc
---------------------------------------------------------------------
local alwaysUpdateAurasCB, useCleuCB, translitCB

local function CreateMiscPane()
    local miscPane = AF.CreateTitledPane(generalTab, L["Misc"], 212, 130)
    AF.SetPoint(miscPane, "TOPRIGHT", generalTab, -7, -300)

    alwaysUpdateAurasCB = AF.CreateCheckButton(miscPane, L["Always Update Auras"], function(checked, self)
        CellDB["general"]["alwaysUpdateAuras"] = checked
    end)
    alwaysUpdateAurasCB:SetTooltip(L["Ignore UNIT_AURA payloads"], L["This may help solve issues of indicators not updating correctly"])
    AF.SetPoint(alwaysUpdateAurasCB, "TOPLEFT", 5, -27)
    alwaysUpdateAurasCB:SetEnabled(Cell.isRetail)

    useCleuCB = AF.CreateCheckButton(miscPane, L["Faster Health Updates"], function(checked, self)
        CellDB["general"]["useCleuHealthUpdater"] = checked
        Cell.Fire("UpdateCLEU")
    end)
    useCleuCB:SetTooltip("|cffff2727"..L["HIGH CPU USAGE"].." (EXPERIMENTAL)", L["Use CLEU events to increase health update rate"])
    AF.SetPoint(useCleuCB, "TOPLEFT", alwaysUpdateAurasCB, "BOTTOMLEFT", 0, -7)

    translitCB = AF.CreateCheckButton(miscPane, L["Translit Cyrillic to Latin"], function(checked, self)
        CellDB["general"]["translit"] = checked
        Cell.Fire("TranslitNames")
    end)
    AF.SetPoint(translitCB, "TOPLEFT", useCleuCB, "BOTTOMLEFT", 0, -7)
end

---------------------------------------------------------------------
-- LibGetFrame
---------------------------------------------------------------------
local framePriorityWidget

local function CreateLibGetFramePane()
    local miscPane = AF.CreateTitledPane(generalTab, "LibGetFrame", nil, 80)
    AF.SetPoint(miscPane, "TOPLEFT", generalTab, 7, -450)
    AF.SetPoint(miscPane, "TOPRIGHT", generalTab, -7, -450)

    local framePriorityText = miscPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    AF.SetPoint(framePriorityText, "TOPLEFT", 5, -27)
    framePriorityText:SetText(L["Frame priorities for LibGetFrame"])

    framePriorityWidget = AF.CreateDragSorter(miscPane, nil, nil, 120)
    AF.SetPoint(framePriorityWidget, "TOPLEFT", 5, -45)

    local widgets = {}
    local names = {"Main", "Spotlight", "Quick Assist"}
    local values = {"^CellNormalUnitFrame$", "^CellSpotlightUnitFrame$", "^CellQuickAssistUnitFrame$"}

    for i = 1, 3 do
        local name = L[names[i]]
        local value = values[i]

        local b = AF.CreateButton(f, name, "Cell_hover")
        tinsert(widgets, b)

        b.cb = AF.CreateCheckButton(b, nil, function(checked)
            b:SetEnabled(checked)

            if checked then
                framePriorityWidget.configTable[b.index] = b.value
                local firstDisabled = AF.IndexOf(framePriorityWidget.configTable, "^CellPlaceholder$")
                if firstDisabled and firstDisabled < b.index then
                    AF.MoveElementToIndex(framePriorityWidget.configTable, b.index, firstDisabled)
                end
                b:InvokeOnEnter()
            else
                framePriorityWidget.configTable[b.index] = "^CellPlaceholder$"
                AF.MoveElementToEnd(framePriorityWidget.configTable, b.index)
                b:InvokeOnLeave()
            end

            F.UpdateFramePriority()
            framePriorityWidget:Refresh()
        end)
        AF.SetPoint(b.cb, "LEFT", b, 5, 0)

        AF.SetPoint(b.text, "LEFT", b.cb, "RIGHT", 5, 0)
        b.text:SetJustifyH("LEFT")

        b.cb:HookOnEnter(function() if b:IsEnabled() then b:InvokeOnEnter() end end)
        b.cb:HookOnLeave(b:GetOnLeave())

        b.value = value
        b.tipText = name
    end

    framePriorityWidget:SetWidgets(widgets)
    framePriorityWidget:SetCallback(F.UpdateFramePriority)
end

---------------------------------------------------------------------
-- functions
---------------------------------------------------------------------
local init
local function ShowTab(tab)
    if tab == "general" then
        if not init then
            CreateVisibilityPane()
            CreateTooltipsPane()
            CreatePositionPane()
            CreateNicknamePane()
            CreateMiscPane()
            CreateLibGetFramePane()

            -- mask
            AF.ApplyCombatProtectionToFrame(generalTab)
            Cell.CreateMask(generalTab, nil, {1, -1, -1, 1})
            generalTab.mask:Hide()
        end

        generalTab:Show()

        if init then return end
        init = true

        -- tooltips
        enableTooltipsCB:SetChecked(CellDB["general"]["enableTooltips"])
        hideTooltipsInCombatCB:SetEnabled(CellDB["general"]["enableTooltips"])
        hideTooltipsInCombatCB:SetChecked(CellDB["general"]["hideTooltipsInCombat"])
        tooltipsAnchorDD:SetEnabled(CellDB["general"]["enableTooltips"])
        tooltipsAnchorDD:SetSelectedValue(CellDB["general"]["tooltipsPosition"][1])
        tooltipsAnchoredToDD:SetEnabled(CellDB["general"]["enableTooltips"])
        tooltipsAnchoredToDD:SetSelectedValue(CellDB["general"]["tooltipsPosition"][2])
        tooltipsX:SetEnabled(CellDB["general"]["enableTooltips"])
        tooltipsX:SetValue(CellDB["general"]["tooltipsPosition"][4])
        tooltipsY:SetEnabled(CellDB["general"]["enableTooltips"])
        tooltipsY:SetValue(CellDB["general"]["tooltipsPosition"][5])
        if CellDB["general"]["enableTooltips"] then
            UpdateTooltipsOptions()
        end

        -- visibility
        hideBlizzardPartyCB:SetChecked(CellDB["general"]["hideBlizzardParty"])
        hideBlizzardRaidCB:SetChecked(CellDB["general"]["hideBlizzardRaid"])

        -- position
        lockCB:SetChecked(CellDB["general"]["locked"])
        fadeOutCB:SetChecked(CellDB["general"]["fadeOut"])
        menuPositionDD:SetSelectedValue(CellDB["general"]["menuPosition"])

        -- nickname
        nicknameEB:SetText(CellDB["nicknames"]["mine"])
        syncCB:SetChecked(CellDB["nicknames"]["sync"])

        -- misc
        alwaysUpdateAurasCB:SetChecked(CellDB["general"]["alwaysUpdateAuras"])
        useCleuCB:SetChecked(CellDB["general"]["useCleuHealthUpdater"])
        translitCB:SetChecked(CellDB["general"]["translit"])

        -- LibGetFrame
        framePriorityWidget:SetConfigTable(CellDB["general"]["framePriority"])
        for _, w in pairs(framePriorityWidget.widgets) do
            if AF.Contains(CellDB["general"]["framePriority"], w.value) then
                w:SetEnabled(true)
                w.cb:SetChecked(true)
            else
                w:SetEnabled(false)
                w.cb:SetChecked(false)
            end
        end
    else
        generalTab:Hide()
    end
end
Cell.RegisterCallback("ShowOptionsTab", "GeneralTab_ShowTab", ShowTab)