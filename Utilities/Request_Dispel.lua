local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local U = Cell.uFuncs
local P = Cell.pixelPerfectFuncs

-------------------------------------------------
-- dispel request
-------------------------------------------------
local drPane, drGlowOptionsBtn
local drEnabledCB, drDispellableCB, drResponseDD, drResponseText, drTimeoutDD, drTimeoutText, drMacroText, drMacroEB, drDebuffsText, drDebuffsEB

local function UpdateDRWidgets()
    Cell:SetEnabled(CellDB["dispelRequest"]["enabled"], drDispellableCB, drResponseDD, drResponseText, drTimeoutDD, drTimeoutText, drMacroText, drMacroEB, drGlowOptionsBtn)
    Cell:SetEnabled(CellDB["dispelRequest"]["enabled"] and CellDB["dispelRequest"]["responseType"] == "specific", drDebuffsText, drDebuffsEB)
end

local function CreateDRPane()
    drPane = Cell:CreateTitledPane(Cell.frames.utilitiesTab, L["Dispel Request"], 422, 183)
    drPane:SetPoint("TOPLEFT", 5, -5)
    drPane:SetPoint("BOTTOMRIGHT", -5, 5)

    drGlowOptionsBtn = Cell:CreateButton(drPane, L["Glow Options"], "accent", {105, 17})
    drGlowOptionsBtn:SetPoint("TOPRIGHT", drPane)
    drGlowOptionsBtn:SetScript("OnClick", function()
        local fs = drGlowOptionsBtn:GetFontString()
        if fs.rainbow then
            Cell:StopRainbowText(fs)
        else
            Cell:StartRainbowText(fs)
        end
        U:ShowGlowOptions(Cell.frames.utilitiesTab, "dispelRequest", CellDB["dispelRequest"]["glowOptions"])
    end)
    drGlowOptionsBtn:SetScript("OnHide", function()
        Cell:StopRainbowText(drGlowOptionsBtn:GetFontString())
    end)
    Cell:RegisterForCloseDropdown(drGlowOptionsBtn)

    local drTips = drPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    drTips:SetPoint("TOPLEFT", 5, -25)
    drTips:SetText(L["Glow unit button when a group member sends a %s request"]:format(Cell:GetAccentColorString()..L["DISPEL"].."|r"))

    -- enabled ----------------------------------------------------------------------
    drEnabledCB = Cell:CreateCheckButton(drPane, L["Enabled"], function(checked, self)
        CellDB["dispelRequest"]["enabled"] = checked
        UpdateDRWidgets()
        Cell:Fire("UpdateRequests", "dispelRequest")
        CellDropdownList:Hide()
        
        U:HideGlowOptions()
        Cell:StopRainbowText(drGlowOptionsBtn:GetFontString())
    end)
    drEnabledCB:SetPoint("TOPLEFT", drPane, "TOPLEFT", 5, -50)
    ---------------------------------------------------------------------------------

    -- dispellable ------------------------------------------------------------------
    drDispellableCB = Cell:CreateCheckButton(drPane, L["Dispellable By Me"], function(checked, self)
        CellDB["dispelRequest"]["dispellableByMe"] = checked
        Cell:Fire("UpdateRequests", "dispelRequest")
    end)
    drDispellableCB:SetPoint("TOPLEFT", drEnabledCB, "TOPLEFT", 200, 0)
    ---------------------------------------------------------------------------------

    -- response ---------------------------------------------------------------------
    drResponseDD = Cell:CreateDropdown(drPane, 345)
    drResponseDD:SetPoint("TOPLEFT", drEnabledCB, "BOTTOMLEFT", 0, -27)
    drResponseDD:SetItems({
        {
            ["text"] = L["Respond to all dispellable debuffs"],
            ["value"] = "all",
            ["onClick"] = function()
                CellDB["dispelRequest"]["responseType"] = "all"
                UpdateDRWidgets()
                Cell:Fire("UpdateRequests", "dispelRequest")
            end
        },
        {
            ["text"] = L["Respond to specific dispellable debuffs"],
            ["value"] = "specific",
            ["onClick"] = function()
                CellDB["dispelRequest"]["responseType"] = "specific"
                UpdateDRWidgets()
                Cell:Fire("UpdateRequests", "dispelRequest")
            end
        },
    })

    drResponseText = drPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    drResponseText:SetPoint("BOTTOMLEFT", drResponseDD, "TOPLEFT", 0, 1)
    drResponseText:SetText(L["Response Type"])
    ---------------------------------------------------------------------------------

    -- timeout ----------------------------------------------------------------------
    drTimeoutDD = Cell:CreateDropdown(drPane, 60)
    drTimeoutDD:SetPoint("TOPLEFT", drResponseDD, "TOPRIGHT", 7, 0)

    local items = {}
    local secs = {1, 2, 3, 4, 5, 10, 15, 20, 25, 30}
    for _, s in ipairs(secs) do
        tinsert(items, {
            ["text"] = s,
            ["value"] = s,
            ["onClick"] = function()
                CellDB["dispelRequest"]["timeout"] = s
                Cell:Fire("UpdateRequests", "dispelRequest")
            end
        })
    end
    drTimeoutDD:SetItems(items)

    drTimeoutText = drPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    drTimeoutText:SetPoint("BOTTOMLEFT", drTimeoutDD, "TOPLEFT", 0, 1)
    drTimeoutText:SetText(L["Timeout"])
    ---------------------------------------------------------------------------------

    -- macro ------------------------------------------------------------------------
    drMacroText = drPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    drMacroText:SetPoint("TOPLEFT", drResponseDD, "BOTTOMLEFT", 0, -10)
    drMacroText:SetText(L["Macro"])

    drMacroEB = Cell:CreateEditBox(drPane, 357, 20)
    drMacroEB:SetPoint("TOP", drResponseDD, "BOTTOM", 0, -7)
    drMacroEB:SetPoint("LEFT", drMacroText, "RIGHT", 5, 0)
    drMacroEB:SetPoint("RIGHT", -5, 0)
    drMacroEB:SetText("/run C_ChatInfo.SendAddonMessage(\"CELL_REQ_D\",\"D\",\"RAID\")")
    drMacroEB:SetCursorPosition(0)
    drMacroEB:SetScript("OnTextChanged", function(self, userChanged)
        if userChanged then
            drMacroEB:SetText("/run C_ChatInfo.SendAddonMessage(\"CELL_REQ_D\",\"D\",\"RAID\")")
            drMacroEB:SetCursorPosition(0)
            drMacroEB:HighlightText()
        end
    end)
    drMacroEB.gauge = drMacroEB:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    drMacroEB.gauge:SetText(drMacroEB:GetText())
    drMacroEB:SetScript("OnEditFocusGained", function()
        local requiredWidth = drMacroEB.gauge:GetStringWidth()
        if requiredWidth > drMacroEB:GetWidth() then
            drMacroEB:ClearAllPoints()
            drMacroEB:SetPoint("TOP", drResponseDD, "BOTTOM", 0, -7)
            drMacroEB:SetPoint("LEFT", drMacroText, "RIGHT", 5, 0)
            drMacroEB:SetWidth(requiredWidth + 20)
            drMacroEB:HighlightText()
        end
    end)
    drMacroEB:SetScript("OnEditFocusLost", function()
        drMacroEB:ClearAllPoints()
        drMacroEB:SetPoint("TOP", drResponseDD, "BOTTOM", 0, -7)
        drMacroEB:SetPoint("LEFT", drMacroText, "RIGHT", 5, 0)
        drMacroEB:SetPoint("RIGHT", -5, 0)
        drMacroEB:SetCursorPosition(0)
        drMacroEB:HighlightText(0, 0)
    end)
    ---------------------------------------------------------------------------------

    -- debuffs ----------------------------------------------------------------------
    drDebuffsEB = Cell:CreateEditBox(drPane, 357, 20)
    drDebuffsEB:SetPoint("TOP", drMacroEB, "BOTTOM", 0, -25)
    drDebuffsEB:SetPoint("LEFT", 5, 0)
    drDebuffsEB:SetPoint("RIGHT", -5, 0)
    drDebuffsEB:SetScript("OnTextChanged", function(self, userChanged)
        if userChanged then
            CellDB["dispelRequest"]["debuffs"] = F:StringToTable(drDebuffsEB:GetText(), " ", true)
            drDebuffsEB.gauge:SetText(drDebuffsEB:GetText())
            Cell:Fire("UpdateRequests", "dispelRequest")
        end
    end)
    drDebuffsEB.gauge = drMacroEB:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    drDebuffsEB:SetScript("OnEditFocusGained", function()
        local requiredWidth = drDebuffsEB.gauge:GetStringWidth()
        if requiredWidth > drDebuffsEB:GetWidth() then
            drDebuffsEB:ClearAllPoints()
            drDebuffsEB:SetPoint("TOP", drMacroEB, "BOTTOM", 0, -25)
            drDebuffsEB:SetPoint("LEFT", 5, 0)
            drDebuffsEB:SetWidth(requiredWidth + 20)
            drDebuffsEB:HighlightText()
        end
    end)
    drDebuffsEB:SetScript("OnEditFocusLost", function()
        drDebuffsEB:ClearAllPoints()
        drDebuffsEB:SetPoint("TOP", drMacroEB, "BOTTOM", 0, -25)
        drDebuffsEB:SetPoint("LEFT", 5, 0)
        drDebuffsEB:SetPoint("RIGHT", -5, 0)
        drDebuffsEB:SetCursorPosition(0)
        drDebuffsEB:HighlightText(0, 0)
    end)

    drDebuffsText = drPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    drDebuffsText:SetPoint("BOTTOMLEFT", drDebuffsEB, "TOPLEFT", 0, 1)
    drDebuffsText:SetText(L["Debuffs"].." ("..L["IDs separated by whitespaces"]..")")
    ---------------------------------------------------------------------------------
end

-------------------------------------------------
-- show
-------------------------------------------------
local init
local function ShowUtilitySettings(which)
    if which == "dispelRequest" then
        if not init then
            CreateDRPane()
        end
        
        drPane:Show()
        
        if init then return end
        init = true

        -- dispel request
        drEnabledCB:SetChecked(CellDB["dispelRequest"]["enabled"])
        drDispellableCB:SetChecked(CellDB["dispelRequest"]["dispellableByMe"])
        drResponseDD:SetSelectedValue(CellDB["dispelRequest"]["responseType"])
        drTimeoutDD:SetSelected(CellDB["dispelRequest"]["timeout"])
        drDebuffsEB:SetText(F:TableToString(CellDB["dispelRequest"]["debuffs"], " "))
        drDebuffsEB.gauge:SetText(drDebuffsEB:GetText())
        drDebuffsEB:SetCursorPosition(0)
        UpdateDRWidgets()
        
    elseif init then
        drPane:Hide()
    end
end
Cell:RegisterCallback("ShowUtilitySettings", "DispelRequest_ShowUtilitySettings", ShowUtilitySettings)