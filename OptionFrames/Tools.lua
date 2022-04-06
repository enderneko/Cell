local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

local toolsTab = Cell:CreateFrame("CellOptionsFrame_ToolsTab", Cell.frames.optionsFrame, nil, nil, true)
Cell.frames.toolsTab = toolsTab
toolsTab:SetAllPoints(Cell.frames.optionsFrame)
toolsTab:Hide()

local pirGlowOptionsBtn, drGlowOptionsBtn

-------------------------------------------------
-- raid tools
-------------------------------------------------
local resCB, reportCB, buffCB, readyPullCB, pullDropdown, secEditBox, marksBarCB, marksDropdown

local function CreateToolsPane()
    local toolsPane = Cell:CreateTitledPane(toolsTab, L["Raid Tools"].." |cFF777777"..L["only in group"], 422, 107)
    toolsPane:SetPoint("TOPLEFT", 5, -5)

    local unlockBtn = Cell:CreateButton(toolsPane, L["Unlock"], "class", {60, 17})
    unlockBtn:SetPoint("TOPRIGHT", toolsPane)
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
    resCB = Cell:CreateCheckButton(toolsPane, L["Battle Res Timer"], function(checked, self)
        CellDB["tools"]["showBattleRes"] = checked
        Cell:Fire("UpdateTools", "battleRes")
    end, L["Battle Res Timer"], L["Only show during encounter or in mythic+"])
    resCB:SetPoint("TOPLEFT", toolsPane, "TOPLEFT", 5, -27)

    -- death report
    reportCB = Cell:CreateCheckButton(toolsPane, L["Death Report"], function(checked, self)
        CellDB["tools"]["deathReport"][1] = checked
        Cell:Fire("UpdateTools", "deathReport")
    end)
    reportCB:SetPoint("TOPLEFT", resCB, "TOPLEFT", 139, 0)
    reportCB:HookScript("OnEnter", function()
        CellTooltip:SetOwner(reportCB, "ANCHOR_TOPLEFT", 0, 2)
        CellTooltip:AddLine(L["Death Report"].." |cffff2727"..L["HIGH CPU USAGE"])
        CellTooltip:AddLine("|cffff2727" .. L["Disabled in battlegrounds and arenas"])
        CellTooltip:AddLine("|cffffffff" .. L["Report deaths to group"])
        CellTooltip:AddLine("|cffffffff" .. L["Use |cFFFFB5C5/cell report X|r to set the number of reports during a raid encounter"])
        CellTooltip:AddLine("|cffffffff" .. L["Current"]..": |cFFFFB5C5"..(CellDB["tools"]["deathReport"][2]==0 and L["all"] or string.format(L["first %d"], CellDB["tools"]["deathReport"][2])))
        CellTooltip:Show()
    end)
    reportCB:HookScript("OnLeave", function()
        CellTooltip:Hide()
    end)

    -- buff tracker
    buffCB = Cell:CreateCheckButton(toolsPane, L["Buff Tracker"], function(checked, self)
        CellDB["tools"]["buffTracker"][1] = checked
        Cell:Fire("UpdateTools", "buffTracker")
    end, L["Buff Tracker"].." |cffff7727"..L["MODERATE CPU USAGE"], L["Check if your group members need some raid buffs"], L["|cffffb5c5Left-Click:|r cast the spell"], L["|cffffb5c5Right-Click:|r report unaffected"]) -- L["|cffffb5c5Middle-Click:|r send custom message"]
    buffCB:SetPoint("TOPLEFT", reportCB, "TOPLEFT", 139, 0)

    -- ready & pull
    readyPullCB = Cell:CreateCheckButton(toolsPane, L["ReadyCheck and PullTimer buttons"], function(checked, self)
        CellDB["tools"]["readyAndPull"][1] = checked
        pullDropdown:SetEnabled(checked)
        secEditBox:SetEnabled(checked)
        Cell:Fire("UpdateTools", "buttons")
    end, L["ReadyCheck and PullTimer buttons"], L["Only show when you have permission to do this"], L["pullTimerTips"])
    readyPullCB:SetPoint("TOPLEFT", resCB, "BOTTOMLEFT", 0, -15)

    pullDropdown = Cell:CreateDropdown(toolsPane, 90)
    pullDropdown:SetPoint("TOP", readyPullCB, 0, 3)
    pullDropdown:SetPoint("LEFT", readyPullCB.label, "RIGHT", 5, 0)
    pullDropdown:SetItems({
        {
            ["text"] = L["Default"],
            ["value"] = "default",
            ["onClick"] = function()
                CellDB["tools"]["readyAndPull"][2][1] = "default"
                Cell:Fire("UpdateTools", "pullTimer")
            end,
        },
        {
            ["text"] = "MRT",
            ["value"] = "mrt",
            ["onClick"] = function()
                CellDB["tools"]["readyAndPull"][2][1] = "mrt"
                Cell:Fire("UpdateTools", "pullTimer")
            end,
        },
        {
            ["text"] = "DBM",
            ["value"] = "dbm",
            ["onClick"] = function()
                CellDB["tools"]["readyAndPull"][2][1] = "dbm"
                Cell:Fire("UpdateTools", "pullTimer")
            end,
        },
        {
            ["text"] = "BigWigs",
            ["value"] = "bw",
            ["onClick"] = function()
                CellDB["tools"]["readyAndPull"][2][1] = "bw"
                Cell:Fire("UpdateTools", "pullTimer")
            end,
        },
    })

    secEditBox = Cell:CreateEditBox(toolsPane, 38, 20, false, false, true)
    secEditBox:SetPoint("TOPLEFT", pullDropdown, "TOPRIGHT", 5, 0)
    secEditBox:SetMaxLetters(3)

    secEditBox.confirmBtn = Cell:CreateButton(toolsPane, "OK", "class", {27, 20})
    secEditBox.confirmBtn:SetPoint("TOPLEFT", secEditBox, "TOPRIGHT", P:Scale(-1), 0)
    secEditBox.confirmBtn:Hide()
    secEditBox.confirmBtn:SetScript("OnHide", function()
        secEditBox.confirmBtn:Hide()
    end)
    secEditBox.confirmBtn:SetScript("OnClick", function()
        CellDB["tools"]["readyAndPull"][2][2] = tonumber(secEditBox:GetText())
        Cell:Fire("UpdateTools", "pullTimer")
        secEditBox.confirmBtn:Hide()
    end)

    secEditBox:SetScript("OnTextChanged", function(self, userChanged)
        if userChanged then
            local newSec = tonumber(self:GetText())
            if newSec and newSec > 0 and newSec ~= CellDB["tools"]["readyAndPull"][2][2] then
                secEditBox.confirmBtn:Show()
            else
                secEditBox.confirmBtn:Hide()
            end
        end
    end)

    -- marks bar
    marksBarCB = Cell:CreateCheckButton(toolsPane, L["Marks Bar"], function(checked, self)
        CellDB["tools"]["marks"][1] = checked
        marksDropdown:SetEnabled(checked)
        Cell:Fire("UpdateTools", "marks")
    end, L["Marks Bar"], L["Only show when you have permission to do this"], L["marksTips"])
    marksBarCB:SetPoint("TOPLEFT", readyPullCB, "BOTTOMLEFT", 0, -15)

    marksDropdown = Cell:CreateDropdown(toolsPane, 200)
    -- marksDropdown:SetPoint("TOPLEFT", marksBarCB, "BOTTOMRIGHT", 5, -5)
    marksDropdown:SetPoint("TOP", marksBarCB, 0, 3)
    marksDropdown:SetPoint("LEFT", marksBarCB.label, "RIGHT", 5, 0)
    marksDropdown:SetItems({
        {
            ["text"] = L["Target Marks"].." ("..L["Horizontal"]..")",
            ["value"] = "target_h",
            ["onClick"] = function()
                CellDB["tools"]["marks"][2] = "target_h"
                Cell:Fire("UpdateTools", "marks")
            end,
        },
        {
            ["text"] = L["Target Marks"].." ("..L["Vertical"]..")",
            ["value"] = "target_v",
            ["onClick"] = function()
                CellDB["tools"]["marks"][2] = "target_v"
                Cell:Fire("UpdateTools", "marks")
            end,
        },
        {
            ["text"] = L["World Marks"].." ("..L["Horizontal"]..")",
            ["value"] = "world_h",
            ["onClick"] = function()
                CellDB["tools"]["marks"][2] = "world_h"
                Cell:Fire("UpdateTools", "marks")
            end,
        },
        {
            ["text"] = L["World Marks"].." ("..L["Vertical"]..")",
            ["value"] = "world_v",
            ["onClick"] = function()
                CellDB["tools"]["marks"][2] = "world_v"
                Cell:Fire("UpdateTools", "marks")
            end,
        },
        {
            ["text"] = L["Both"].." ("..L["Horizontal"]..")",
            ["value"] = "both_h",
            ["onClick"] = function()
                CellDB["tools"]["marks"][2] = "both_h"
                Cell:Fire("UpdateTools", "marks")
            end,
        },
        {
            ["text"] = L["Both"].." ("..L["Vertical"]..")",
            ["value"] = "both_v",
            ["onClick"] = function()
                CellDB["tools"]["marks"][2] = "both_v"
                Cell:Fire("UpdateTools", "marks")
            end,
        }
    })
end

-------------------------------------------------
-- power infusion request
-------------------------------------------------
local pirEnabledCB, onlyPriestCB, onlyFreeCooldownCB, pirResponseDD, pirTimeoutDD, pirMacroText, pirMacroEB, pirResponseText, pirTimeoutText

local function UpdatePIRText()
    local macroText

    if CellDB["tools"]["PIRequest"][4] == "all" then
        pirMacroText:SetText(L["Macro"])
        macroText = "/run C_ChatInfo.SendAddonMessage(\"CELL_REQ_PI\", \"ALL\", \"RAID\")"
    elseif CellDB["tools"]["PIRequest"][4] == "me" then
        pirMacroText:SetText(L["Macro"])
        macroText = "/run C_ChatInfo.SendAddonMessage(\"CELL_REQ_PI\", \""..GetUnitName("player").."\", \"RAID\")"
    else -- whisper
        pirMacroText:SetText(L["Contains"])
        pirMacroEB:SetText(CellDB["tools"]["PIRequest"][6])
    end

    if macroText then
        pirMacroEB:SetText(macroText)
        pirMacroEB:SetScript("OnTextChanged", function(self, userChanged)
            if userChanged then
                pirMacroEB:SetText(macroText)
                pirMacroEB:HighlightText()
            end
        end)
    else
        pirMacroEB:SetScript("OnTextChanged", function(self, userChanged)
            if userChanged then
                CellDB["tools"]["PIRequest"][6] = strtrim(self:GetText())
                Cell:Fire("UpdateTools", "pirequest")
            end
        end)
    end

    pirMacroEB:SetCursorPosition(0)
end

local function UpdatePIRWidgets()
    Cell:SetEnabled(CellDB["tools"]["PIRequest"][1], onlyPriestCB, pirResponseDD, pirTimeoutDD, pirMacroText, pirMacroEB, pirResponseText, pirTimeoutText)
    Cell:SetEnabled(CellDB["tools"]["PIRequest"][1] and CellDB["tools"]["PIRequest"][2], onlyFreeCooldownCB)
end

local function CreatePIRPane()
    local pirPane = Cell:CreateTitledPane(toolsTab, L["Power Infusion Request"].." ("..L["Glow"]..")", 422, 140)
    pirPane:SetPoint("TOPLEFT", 5, -132)

    pirGlowOptionsBtn = Cell:CreateButton(pirPane, L["Glow Options"], "class", {105, 17})
    pirGlowOptionsBtn:SetPoint("TOPRIGHT", pirPane)
    pirGlowOptionsBtn:SetScript("OnClick", function()
        Cell:StopRainbowText(drGlowOptionsBtn:GetFontString())
        local fs = pirGlowOptionsBtn:GetFontString()
        if fs.rainbow then
            Cell:StopRainbowText(fs)
        else
            Cell:StartRainbowText(fs)
        end
        F:ShowGlowOptions(toolsTab, "PIRequest", 7)
    end)
    pirGlowOptionsBtn:SetScript("OnHide", function()
        Cell:StopRainbowText(pirGlowOptionsBtn:GetFontString())
    end)

    local pirTips = pirPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    pirTips:SetPoint("TOPLEFT", 5, -25)
    pirTips:SetText(L["Glow unit button when a group member send a %s request"]:format(Cell:GetPlayerClassColorString()..L["PI"].."|r"))

    -- enabled ----------------------------------------------------------------------
    pirEnabledCB = Cell:CreateCheckButton(pirPane, L["Enabled"], function(checked, self)
        CellDB["tools"]["PIRequest"][1] = checked
        UpdatePIRWidgets()
        Cell:Fire("UpdateTools", "pirequest")
    end)
    pirEnabledCB:SetPoint("TOPLEFT", pirPane, "TOPLEFT", 5, -45)
    ---------------------------------------------------------------------------------
    
    -- priest ----------------------------------------------------------------------
    onlyPriestCB = Cell:CreateCheckButton(pirPane, L["Priest Only"], function(checked, self)
        CellDB["tools"]["PIRequest"][2] = checked
        UpdatePIRWidgets()
        Cell:Fire("UpdateTools", "pirequest")
    end)
    onlyPriestCB:SetPoint("TOPLEFT", pirEnabledCB, "TOPLEFT", 127, 0)
    ---------------------------------------------------------------------------------
    
    -- free cooldown ----------------------------------------------------------------------
    onlyFreeCooldownCB = Cell:CreateCheckButton(pirPane, L["Free Cooldown Only"], function(checked, self)
        CellDB["tools"]["PIRequest"][3] = checked
        Cell:Fire("UpdateTools", "pirequest")
    end)
    onlyFreeCooldownCB:SetPoint("TOPLEFT", onlyPriestCB, "TOPLEFT", 127, 0)
    ---------------------------------------------------------------------------------

    -- response ----------------------------------------------------------------------
    pirResponseDD = Cell:CreateDropdown(pirPane, 345)
    pirResponseDD:SetPoint("TOPLEFT", pirEnabledCB, "BOTTOMLEFT", 0, -27)
    pirResponseDD:SetItems({
        {
            ["text"] = L["Respond to all requests from group members"],
            ["value"] = "all",
            ["onClick"] = function()
                CellDB["tools"]["PIRequest"][4] = "all"
                UpdatePIRText()
                Cell:Fire("UpdateTools", "pirequest")
            end
        },
        {
            ["text"] = L["Respond to requests that are only sent to me"],
            ["value"] = "me",
            ["onClick"] = function()
                CellDB["tools"]["PIRequest"][4] = "me"
                UpdatePIRText()
                Cell:Fire("UpdateTools", "pirequest")
            end
        },
        {
            ["text"] = L["Respond to whispers"],
            ["value"] = "whisper",
            ["onClick"] = function()
                CellDB["tools"]["PIRequest"][4] = "whisper"
                UpdatePIRText()
                Cell:Fire("UpdateTools", "pirequest")
            end
        },
    })

    pirResponseText = pirPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    pirResponseText:SetPoint("BOTTOMLEFT", pirResponseDD, "TOPLEFT", 0, 1)
    pirResponseText:SetText(L["Response Type"])
    ---------------------------------------------------------------------------------

    -- timeout ----------------------------------------------------------------------
    pirTimeoutDD = Cell:CreateDropdown(pirPane, 60)
    pirTimeoutDD:SetPoint("TOPLEFT", pirResponseDD, "TOPRIGHT", 7, 0)

    local items = {}
    local secs = {1, 2, 3, 4, 5, 10, 15, 20, 25, 30}
    for _, s in ipairs(secs) do
        tinsert(items, {
            ["text"] = s,
            ["value"] = s,
            ["onClick"] = function()
                CellDB["tools"]["PIRequest"][5] = s
                Cell:Fire("UpdateTools", "pirequest")
            end
        })
    end
    pirTimeoutDD:SetItems(items)

    pirTimeoutText = pirPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    pirTimeoutText:SetPoint("BOTTOMLEFT", pirTimeoutDD, "TOPLEFT", 0, 1)
    pirTimeoutText:SetText(L["Timeout"])
    ---------------------------------------------------------------------------------

    -- macro ------------------------------------------------------------------------
    pirMacroText = pirPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    pirMacroText:SetPoint("TOPLEFT", pirResponseDD, "BOTTOMLEFT", 0, -10)
    pirMacroText:SetText(L["Macro"])

    pirMacroEB = Cell:CreateEditBox(pirPane, 357, 20)
    pirMacroEB:SetPoint("TOP", pirResponseDD, "BOTTOM", 0, -7)
    pirMacroEB:SetPoint("LEFT", pirMacroText, "RIGHT", 5, 0)
    pirMacroEB:SetPoint("RIGHT", -5, 0)
    ---------------------------------------------------------------------------------
end

-------------------------------------------------
-- dispel request
-------------------------------------------------
local drEnabledCB, drDispellableCB, drResponseDD, drResponseText, drTimeoutDD, drTimeoutText, drMacroText, drMacroEB, drDebuffsText, drDebuffsEB

local function UpdateDRWidgets()
    Cell:SetEnabled(CellDB["tools"]["DRequest"][1], drDispellableCB, drResponseDD, drResponseText, drTimeoutDD, drTimeoutText, drMacroText, drMacroEB)
    Cell:SetEnabled(CellDB["tools"]["DRequest"][1] and CellDB["tools"]["DRequest"][3] == "specific", drDebuffsText, drDebuffsEB)
end

local function CreateDRPane()
    local drPane = Cell:CreateTitledPane(toolsTab, L["Dispel Request"].." ("..L["Glow"]..")", 422, 183)
    drPane:SetPoint("TOPLEFT", 5, -292)

    drGlowOptionsBtn = Cell:CreateButton(drPane, L["Glow Options"], "class", {105, 17})
    drGlowOptionsBtn:SetPoint("TOPRIGHT", drPane)
    drGlowOptionsBtn:SetScript("OnClick", function()
        Cell:StopRainbowText(pirGlowOptionsBtn:GetFontString())
        local fs = drGlowOptionsBtn:GetFontString()
        if fs.rainbow then
            Cell:StopRainbowText(fs)
        else
            Cell:StartRainbowText(fs)
        end
        F:ShowGlowOptions(toolsTab, "DRequest", 6)
    end)
    drGlowOptionsBtn:SetScript("OnHide", function()
        Cell:StopRainbowText(drGlowOptionsBtn:GetFontString())
    end)

    local drTips = drPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    drTips:SetPoint("TOPLEFT", 5, -25)
    drTips:SetText(L["Glow unit button when a group member send a %s request"]:format(Cell:GetPlayerClassColorString()..L["DISPEL"].."|r"))

    -- enabled ----------------------------------------------------------------------
    drEnabledCB = Cell:CreateCheckButton(drPane, L["Enabled"], function(checked, self)
        CellDB["tools"]["DRequest"][1] = checked
        UpdateDRWidgets()
        Cell:Fire("UpdateTools", "drequest")
    end)
    drEnabledCB:SetPoint("TOPLEFT", drPane, "TOPLEFT", 5, -45)
    ---------------------------------------------------------------------------------

    -- dispellable ------------------------------------------------------------------
    drDispellableCB = Cell:CreateCheckButton(drPane, L["Dispellable By Me"], function(checked, self)
        CellDB["tools"]["DRequest"][2] = checked
        Cell:Fire("UpdateTools", "drequest")
    end)
    drDispellableCB:SetPoint("TOPLEFT", drEnabledCB, "TOPLEFT", 127, 0)
    ---------------------------------------------------------------------------------

    -- response ---------------------------------------------------------------------
    drResponseDD = Cell:CreateDropdown(drPane, 345)
    drResponseDD:SetPoint("TOPLEFT", drEnabledCB, "BOTTOMLEFT", 0, -27)
    drResponseDD:SetItems({
        {
            ["text"] = L["Respond to all dispellable debuffs"],
            ["value"] = "all",
            ["onClick"] = function()
                CellDB["tools"]["DRequest"][3] = "all"
                UpdateDRWidgets()
                Cell:Fire("UpdateTools", "drequest")
            end
        },
        {
            ["text"] = L["Respond to specific dispellable debuffs"],
            ["value"] = "specific",
            ["onClick"] = function()
                CellDB["tools"]["DRequest"][3] = "specific"
                UpdateDRWidgets()
                Cell:Fire("UpdateTools", "drequest")
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
                CellDB["tools"]["DRequest"][4] = s
                Cell:Fire("UpdateTools", "drequest")
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
    drMacroEB:SetText("/run C_ChatInfo.SendAddonMessage(\"CELL_REQ_D\", \"D\", \"RAID\")")
    drMacroEB:SetCursorPosition(0)
    drMacroEB:SetScript("OnTextChanged", function(self, userChanged)
        if userChanged then
            drMacroEB:SetText("/run C_ChatInfo.SendAddonMessage(\"CELL_REQ_D\", \"D\", \"RAID\")")
            drMacroEB:SetCursorPosition(0)
            drMacroEB:HighlightText()
        end
    end)
    ---------------------------------------------------------------------------------

    -- debuffs ----------------------------------------------------------------------
    drDebuffsEB = Cell:CreateEditBox(drPane, 357, 20)
    drDebuffsEB:SetPoint("TOP", drMacroEB, "BOTTOM", 0, -25)
    drDebuffsEB:SetPoint("RIGHT", -5, 0)
    drDebuffsEB:SetPoint("LEFT", 5, 0)
    drDebuffsEB:SetScript("OnTextChanged", function(self, userChanged)
        if userChanged then
            CellDB["tools"]["DRequest"][5] = F:StringToTable(drDebuffsEB:GetText(), " ", true)
            Cell:Fire("UpdateTools", "drequest")
        end
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
local function ShowTab(tab)
    if tab == "tools" then
        if not init then
            CreateToolsPane()
            CreatePIRPane()
            CreateDRPane()
        end
        
        toolsTab:Show()

        if init then return end
        init = true

        -- raid tools
        resCB:SetChecked(CellDB["tools"]["showBattleRes"])
        reportCB:SetChecked(CellDB["tools"]["deathReport"][1])
        buffCB:SetChecked(CellDB["tools"]["buffTracker"][1])

        readyPullCB:SetChecked(CellDB["tools"]["readyAndPull"][1])
        pullDropdown:SetSelectedValue(CellDB["tools"]["readyAndPull"][2][1])
        secEditBox:SetText(CellDB["tools"]["readyAndPull"][2][2])
        pullDropdown:SetEnabled(CellDB["tools"]["readyAndPull"][1])
        secEditBox:SetEnabled(CellDB["tools"]["readyAndPull"][1])

        marksDropdown:SetEnabled(CellDB["tools"]["marks"][1])
        marksBarCB:SetChecked(CellDB["tools"]["marks"][1])
        marksDropdown:SetSelectedValue(CellDB["tools"]["marks"][2])

        -- power infusion request
        pirEnabledCB:SetChecked(CellDB["tools"]["PIRequest"][1])
        onlyPriestCB:SetChecked(CellDB["tools"]["PIRequest"][2])
        onlyFreeCooldownCB:SetChecked(CellDB["tools"]["PIRequest"][3])
        pirResponseDD:SetSelectedValue(CellDB["tools"]["PIRequest"][4])
        pirTimeoutDD:SetSelected(CellDB["tools"]["PIRequest"][5])
        UpdatePIRText()
        UpdatePIRWidgets()
        
        -- dispel request
        drEnabledCB:SetChecked(CellDB["tools"]["DRequest"][1])
        drDispellableCB:SetChecked(CellDB["tools"]["DRequest"][2])
        drResponseDD:SetSelectedValue(CellDB["tools"]["DRequest"][3])
        drTimeoutDD:SetSelected(CellDB["tools"]["DRequest"][4])
        drDebuffsEB:SetText(F:TableToString(CellDB["tools"]["DRequest"][5], " "))
        UpdateDRWidgets()
    else
        toolsTab:Hide()
    end
end
Cell:RegisterCallback("ShowOptionsTab", "ToolsTab_ShowTab", ShowTab)