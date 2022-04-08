local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs
local LCG = LibStub("LibCustomGlow-1.0")

local toolsTab = Cell:CreateFrame("CellOptionsFrame_ToolsTab", Cell.frames.optionsFrame, nil, nil, true)
Cell.frames.toolsTab = toolsTab
toolsTab:SetAllPoints(Cell.frames.optionsFrame)
toolsTab:Hide()

local whichGlowOption, srGlowOptionsBtn, drGlowOptionsBtn

-------------------------------------------------
-- raid tools
-------------------------------------------------
local resCB, reportCB, buffCB, readyPullCB, pullDropdown, secEditBox, marksBarCB, marksDropdown

local function CreateToolsPane()
    local toolsPane = Cell:CreateTitledPane(toolsTab, L["Raid Tools"].." |cFF777777"..L["only in group"], 422, 107)
    toolsPane:SetPoint("TOPLEFT", 5, -5)

    local unlockBtn = Cell:CreateButton(toolsPane, L["Unlock"], "class", {70, 17})
    unlockBtn:SetPoint("TOPRIGHT", toolsPane)
    unlockBtn.locked = true
    unlockBtn:SetScript("OnClick", function(self)
        if self.locked then
            unlockBtn:SetText(L["Lock"])
            self.locked = false
            Cell.vars.showMover = true
            LCG.PixelGlow_Start(unlockBtn, {0,1,0,1}, 9, 0.25, 8, 1)
        else
            unlockBtn:SetText(L["Unlock"])
            self.locked = true
            Cell.vars.showMover = false
            LCG.PixelGlow_Stop(unlockBtn)
        end
        Cell:Fire("ShowMover", Cell.vars.showMover)
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
-- spell request
-------------------------------------------------
local srEnabledCB, knownOnlyCB, freeCDOnlyCB, replyCDCB, srResponseDD, srResponseText, srTimeoutDD, srTimeoutText, srSpellsDD, srSpellsText, srAddBtn, srDeleteBtn, srMacroText, srMacroEB
local srSelectedSpell

local function ShowSpellOptions(index)
    if whichGlowOption == "spellRequest" then
        F:HideGlowOptions()
        Cell:StopRainbowText(srGlowOptionsBtn:GetFontString())
    end

    srSelectedSpell = index

    local responseType = CellDB["tools"]["spellRequest"][5]
    local spellId = CellDB["tools"]["spellRequest"][7][index][1]
    local macroText, keywords
    
    if responseType == "all" then
        srMacroText:SetText(L["Macro"])
        macroText = "/run C_ChatInfo.SendAddonMessage(\"CELL_REQ_S\", \""..spellId.."\", \"RAID\")"
    elseif responseType == "me" then
        srMacroText:SetText(L["Macro"])
        macroText = "/run C_ChatInfo.SendAddonMessage(\"CELL_REQ_S\", \""..spellId..":"..GetUnitName("player").."\", \"RAID\")"
    else -- whisper
        srMacroText:SetText(L["Contains"])
        keywords = CellDB["tools"]["spellRequest"][7][index][3]
    end

    if macroText then
        srMacroEB:SetText(macroText)
        srMacroEB.gauge:SetText(macroText)
        srMacroEB:SetScript("OnTextChanged", function(self, userChanged)
            if userChanged then
                srMacroEB:SetText(macroText)
                srMacroEB:HighlightText()
            end
        end)
    else
        srMacroEB:SetText(keywords)
        srMacroEB.gauge:SetText(keywords)
        srMacroEB:SetScript("OnTextChanged", function(self, userChanged)
            if userChanged then
                CellDB["tools"]["spellRequest"][7][index][3] = strtrim(self:GetText())
                Cell:Fire("UpdateTools", "spellRequest")
            end
        end)
    end

    srDeleteBtn:SetEnabled(not CellDB["tools"]["spellRequest"][7][index][5]) -- not built-in
    srGlowOptionsBtn:SetEnabled(true)
    srMacroText:Show()
    srMacroEB:SetCursorPosition(0)
    srMacroEB:Show()
end

local function HideSpellOptions()
    if whichGlowOption == "spellRequest" then
        F:HideGlowOptions()
        Cell:StopRainbowText(srGlowOptionsBtn:GetFontString())
    end
    srSelectedSpell = nil
    srMacroText:Hide()
    srMacroEB:Hide()
    srSpellsDD:SetSelected()
    srDeleteBtn:SetEnabled(false)
    srGlowOptionsBtn:SetEnabled(false)
end

local function LoadSpellsDropdown()
    local items = {}
    for i, t in pairs(CellDB["tools"]["spellRequest"][7]) do
        local name, _, icon = GetSpellInfo(t[1])
        tinsert(items, {
            ["text"] = "|T"..icon..":0::0:0:16:16:1:15:1:15|t "..name,
            ["value"] = t[1],
            ["onClick"] = function()
                ShowSpellOptions(i)
            end
        })
    end
    srSpellsDD:SetItems(items)
end

local function UpdateSRWidgets()
    Cell:SetEnabled(CellDB["tools"]["spellRequest"][1], knownOnlyCB, srResponseDD, srResponseText, srTimeoutDD, srTimeoutText, srSpellsDD, srSpellsText, srAddBtn, srDeleteBtn, srGlowOptionsBtn, srMacroText, srMacroEB)
    Cell:SetEnabled(CellDB["tools"]["spellRequest"][1] and CellDB["tools"]["spellRequest"][2], freeCDOnlyCB, replyCDCB)
end

local function CreateSRPane()
    if not Cell.frames.toolsTab.mask then
        Cell:CreateMask(Cell.frames.toolsTab, nil, {1, -1, -1, 1})
        Cell.frames.toolsTab.mask:Hide()
    end

    local srPane = Cell:CreateTitledPane(toolsTab, L["Spell Request"].." ("..L["Glow"]..")", 422, 227)
    srPane:SetPoint("TOPLEFT", 5, -130)
    srPane:SetScript("OnHide", function()
        whichGlowOption = nil
        HideSpellOptions()
    end)

    local pirTips = srPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    pirTips:SetPoint("TOPLEFT", 5, -25)
    pirTips:SetJustifyH("LEFT")
    pirTips:SetSpacing(5)
    pirTips:SetText(L["Glow unit button when a group member sends a %s request"]:format(Cell:GetPlayerClassColorString()..L["SPELL"].."|r").."\n"..L["Shows only one spell glow on a unit button at a time"])
    -- NOTE: only shows one glow effect on a unit button at a time

    -- enabled ----------------------------------------------------------------------
    srEnabledCB = Cell:CreateCheckButton(srPane, L["Enabled"], function(checked, self)
        CellDB["tools"]["spellRequest"][1] = checked
        UpdateSRWidgets()
        HideSpellOptions()
        Cell:Fire("UpdateTools", "spellRequest")
        CellDropdownList:Hide()
    end)
    srEnabledCB:SetPoint("TOPLEFT", srPane, "TOPLEFT", 5, -65)
    ---------------------------------------------------------------------------------
    
    -- known only -------------------------------------------------------------------
    knownOnlyCB = Cell:CreateCheckButton(srPane, L["Known Spells Only"], function(checked, self)
        CellDB["tools"]["spellRequest"][2] = checked
        UpdateSRWidgets()
        Cell:Fire("UpdateTools", "spellRequest")
    end)
    knownOnlyCB:SetPoint("TOPLEFT", srEnabledCB, "TOPLEFT", 200, 0)
    ---------------------------------------------------------------------------------
    
    -- free cooldown ----------------------------------------------------------------
    freeCDOnlyCB = Cell:CreateCheckButton(srPane, L["Free Cooldown Only"], function(checked, self)
        CellDB["tools"]["spellRequest"][3] = checked
        Cell:Fire("UpdateTools", "spellRequest")
    end)
    freeCDOnlyCB:SetPoint("TOPLEFT", srEnabledCB, "BOTTOMLEFT", 0, -8)
    ---------------------------------------------------------------------------------

    -- reply cd ---------------------------------------------------------------------
    replyCDCB = Cell:CreateCheckButton(srPane, L["Reply With Cooldown"], function(checked, self)
        CellDB["tools"]["spellRequest"][4] = checked
        Cell:Fire("UpdateTools", "spellRequest")
    end)
    replyCDCB:SetPoint("TOPLEFT", freeCDOnlyCB, "TOPLEFT", 200, 0)
    ---------------------------------------------------------------------------------

    -- response ----------------------------------------------------------------------
    srResponseDD = Cell:CreateDropdown(srPane, 345)
    srResponseDD:SetPoint("TOPLEFT", freeCDOnlyCB, "BOTTOMLEFT", 0, -27)
    srResponseDD:SetItems({
        {
            ["text"] = L["Respond to all requests from group members"],
            ["value"] = "all",
            ["onClick"] = function()
                HideSpellOptions()
                CellDB["tools"]["spellRequest"][5] = "all"
                Cell:Fire("UpdateTools", "spellRequest")
            end
        },
        {
            ["text"] = L["Respond to requests that are only sent to me"],
            ["value"] = "me",
            ["onClick"] = function()
                HideSpellOptions()
                CellDB["tools"]["spellRequest"][5] = "me"
                Cell:Fire("UpdateTools", "spellRequest")
            end
        },
        {
            ["text"] = L["Respond to whispers"],
            ["value"] = "whisper",
            ["onClick"] = function()
                HideSpellOptions()
                CellDB["tools"]["spellRequest"][5] = "whisper"
                Cell:Fire("UpdateTools", "spellRequest")
            end
        },
    })

    srResponseText = srPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    srResponseText:SetPoint("BOTTOMLEFT", srResponseDD, "TOPLEFT", 0, 1)
    srResponseText:SetText(L["Response Type"])
    ---------------------------------------------------------------------------------

    -- timeout ----------------------------------------------------------------------
    srTimeoutDD = Cell:CreateDropdown(srPane, 60)
    srTimeoutDD:SetPoint("TOPLEFT", srResponseDD, "TOPRIGHT", 7, 0)

    local items = {}
    local secs = {1, 2, 3, 4, 5, 10, 15, 20, 25, 30}
    for _, s in ipairs(secs) do
        tinsert(items, {
            ["text"] = s,
            ["value"] = s,
            ["onClick"] = function()
                CellDB["tools"]["spellRequest"][6] = s
                Cell:Fire("UpdateTools", "spellRequest")
            end
        })
    end
    srTimeoutDD:SetItems(items)

    srTimeoutText = srPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    srTimeoutText:SetPoint("BOTTOMLEFT", srTimeoutDD, "TOPLEFT", 0, 1)
    srTimeoutText:SetText(L["Timeout"])
    ---------------------------------------------------------------------------------
    
    -- spells -----------------------------------------------------------------------
    srSpellsDD = Cell:CreateDropdown(srPane, 182)
    srSpellsDD:SetPoint("TOPLEFT", srResponseDD, "BOTTOMLEFT", 0, -27)

    srSpellsText = srPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    srSpellsText:SetPoint("BOTTOMLEFT", srSpellsDD, "TOPLEFT", 0, 1)
    srSpellsText:SetText(L["Spells"])
    ---------------------------------------------------------------------------------
    
    -- create -----------------------------------------------------------------------
    srAddBtn = Cell:CreateButton(srPane, L["Add"], "green-hover", {60, 20}, nil, nil, nil, nil, nil,
        L["The spell is required to apply a buff on the target"])
    srAddBtn:SetPoint("TOPLEFT", srSpellsDD, "TOPRIGHT", 7, 0)
    srAddBtn:SetScript("OnClick", function()
        local popup = Cell:CreateConfirmPopup(toolsTab, 200, L["Add new spell"], function(self)
            CellTooltip:Hide()
            if self.spellId and self.buffId then
                -- check if exists
                for _, t in pairs(CellDB["tools"]["spellRequest"][7]) do
                    if t[1] == spellId then
                        F:Print(L["Spell already exists."])
                        return
                    end
                end

                -- update db
                tinsert(CellDB["tools"]["spellRequest"][7], {
                    self.spellId,
                    self.buffId,
                    self.spellName,
                    {
                        "pixel", -- [1] glow type
                        {
                            {0,1,0.5,1}, -- [1] color
                            0, -- [2] x
                            0, -- [3] y
                            9, -- [4] N
                            0.25, -- [5] frequency
                            8, -- [6] length
                            2 -- [7] thickness
                        } -- [2] glowOptions
                    }
                })
                Cell:Fire("UpdateTools", "spellRequest")

                local index = #CellDB["tools"]["spellRequest"][7]

                -- update dropdown
                srSpellsDD:AddItem({
                    ["text"] = "|T"..self.spellIcon..":0::0:0:16:16:1:15:1:15|t "..self.spellName,
                    ["value"] = self.spellId,
                    ["onClick"] = function()
                        ShowSpellOptions(index)
                    end
                })
                srSpellsDD:SetSelectedValue(self.spellId)
                ShowSpellOptions(index)
            else
                F:Print(L["Invalid spell id."])
            end
        end, function()
            CellTooltip:Hide()
        end, true, true, 1)
        popup:SetPoint("TOPLEFT", 117, -220)
        popup.editBox:SetNumeric(true)
        popup.editBox:SetScript("OnTextChanged", function()
            local spellId = tonumber(popup.editBox:GetText())
            if not spellId then
                CellTooltip:Hide()
                popup.validSpell = false
                popup.button1:SetEnabled(false)
                return
            end
    
            local name, _, icon = GetSpellInfo(spellId)
            if not name then
                CellTooltip:Hide()
                popup.validSpell = false
                popup.button1:SetEnabled(false)
                return
            end

            CellTooltip:SetOwner(popup, "ANCHOR_NONE")
            CellTooltip:SetPoint("TOPLEFT", popup, "BOTTOMLEFT", 0, -1)
            CellTooltip:SetHyperlink("spell:"..spellId)
            CellTooltip:Show()

            popup.validSpell = true
            popup.button1:SetEnabled(popup.validSpell and popup.validBuff)

            popup.spellId = spellId
            popup.spellName = name
            popup.spellIcon = icon
        end)
        -- buff id
        if not popup.editBox2 then
            popup.editBox2 = Cell:CreateEditBox(popup, 20, 20)
            popup.editBox2:SetNumeric(true)
            popup.editBox2:SetPoint("TOPLEFT", popup.editBox, "BOTTOMLEFT", 0, -5)
            popup.editBox2:SetPoint("TOPRIGHT", popup.editBox, "BOTTOMRIGHT", 0, -5)
            popup.editBox2:SetScript("OnTextChanged", function()
                local spellId = tonumber(popup.editBox2:GetText())
                if not spellId then
                    popup.validBuff = false
                    popup.button1:SetEnabled(false)
                    return
                end
        
                local name = GetSpellInfo(spellId)
                if not name then
                    popup.validBuff = false
                    popup.button1:SetEnabled(false)
                    return
                end

                popup.validBuff = true
                popup.button1:SetEnabled(popup.validSpell and popup.validBuff)

                popup.buffId = spellId
            end)

            popup.tip1 = popup.editBox:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
            popup.tip1:SetTextColor(0.4, 0.4, 0.4, 1)
            popup.tip1:SetText(L["Spell"].." ID")
            popup.tip1:SetPoint("RIGHT", -5, 0)
            
            popup.tip2 = popup.editBox2:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
            popup.tip2:SetTextColor(0.4, 0.4, 0.4, 1)
            popup.tip2:SetText(L["Buff"].." ID")
            popup.tip2:SetPoint("RIGHT", -5, 0)
        end
        popup.editBox2:SetText("")
        popup.dropdown1:Hide()
        popup.button1:SetEnabled(false)
    end)
    Cell:RegisterForCloseDropdown(srAddBtn)
    ---------------------------------------------------------------------------------
    
    -- delete -----------------------------------------------------------------------
    srDeleteBtn = Cell:CreateButton(srPane, L["Delete"], "red-hover", {60, 20})
    srDeleteBtn:SetPoint("TOPLEFT", srAddBtn, "TOPRIGHT", P:Scale(-1), 0)
    srDeleteBtn:SetScript("OnClick", function()
        local name, _, icon = GetSpellInfo(CellDB["tools"]["spellRequest"][7][srSelectedSpell][1])
        local popup = Cell:CreateConfirmPopup(toolsTab, 200, L["Delete spell?"].."\n".."|T"..icon..":0::0:0:16:16:1:15:1:15|t "..name, function(self)
            tremove(CellDB["tools"]["spellRequest"][7], srSelectedSpell)
            srSpellsDD:RemoveCurrentItem()
            HideSpellOptions()
            Cell:Fire("UpdateTools", "spellRequest")
        end, nil, true)
        popup:SetPoint("TOPLEFT", 117, -250)
    end)
    Cell:RegisterForCloseDropdown(srDeleteBtn)
    ---------------------------------------------------------------------------------
    
    -- glow -------------------------------------------------------------------------
    srGlowOptionsBtn = Cell:CreateButton(srPane, L["Glow Options"], "class", {105, 20})
    srGlowOptionsBtn:SetPoint("TOPLEFT", srDeleteBtn, "TOPRIGHT", P:Scale(-1), 0)
    srGlowOptionsBtn:SetScript("OnClick", function()
        whichGlowOption = "spellRequest"
        Cell:StopRainbowText(drGlowOptionsBtn:GetFontString())
        local fs = srGlowOptionsBtn:GetFontString()
        if fs.rainbow then
            Cell:StopRainbowText(fs)
        else
            Cell:StartRainbowText(fs)
        end
        F:ShowGlowOptions(toolsTab, "spellRequest", CellDB["tools"]["spellRequest"][7][srSelectedSpell][4])
    end)
    srGlowOptionsBtn:SetScript("OnHide", function()
        Cell:StopRainbowText(srGlowOptionsBtn:GetFontString())
    end)
    Cell:RegisterForCloseDropdown(srGlowOptionsBtn)
    ---------------------------------------------------------------------------------

    -- macro ------------------------------------------------------------------------
    srMacroText = srPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    srMacroText:SetPoint("TOPLEFT", srSpellsDD, "BOTTOMLEFT", 0, -10)
    srMacroText:SetText(L["Macro"])

    srMacroEB = Cell:CreateEditBox(srPane, 357, 20)
    srMacroEB:SetPoint("TOP", srSpellsDD, "BOTTOM", 0, -7)
    srMacroEB:SetPoint("LEFT", srMacroText, "RIGHT", 5, 0)
    srMacroEB:SetPoint("RIGHT", -5, 0)

    srMacroEB.gauge = srMacroEB:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    srMacroEB:SetScript("OnEditFocusGained", function()
        local requiredWidth = srMacroEB.gauge:GetStringWidth()
        if requiredWidth > srMacroEB:GetWidth() then
            srMacroEB:ClearAllPoints()
            srMacroEB:SetPoint("TOP", srSpellsDD, "BOTTOM", 0, -7)
            srMacroEB:SetPoint("LEFT", srMacroText, "RIGHT", 5, 0)
            srMacroEB:SetWidth(requiredWidth + 20)
        end
        srMacroEB:HighlightText()
    end)
    srMacroEB:SetScript("OnEditFocusLost", function()
        srMacroEB:ClearAllPoints()
        srMacroEB:SetPoint("TOP", srSpellsDD, "BOTTOM", 0, -7)
        srMacroEB:SetPoint("LEFT", srMacroText, "RIGHT", 5, 0)
        srMacroEB:SetPoint("RIGHT", -5, 0)
        srMacroEB:SetCursorPosition(0)
        srMacroEB:HighlightText(0, 0)
    end)
    ---------------------------------------------------------------------------------
end

-------------------------------------------------
-- dispel request
-------------------------------------------------
local drEnabledCB, drDispellableCB, drResponseDD, drResponseText, drTimeoutDD, drTimeoutText, drMacroText, drMacroEB, drDebuffsText, drDebuffsEB

local function UpdateDRWidgets()
    Cell:SetEnabled(CellDB["tools"]["dispelRequest"][1], drDispellableCB, drResponseDD, drResponseText, drTimeoutDD, drTimeoutText, drMacroText, drMacroEB, drGlowOptionsBtn)
    Cell:SetEnabled(CellDB["tools"]["dispelRequest"][1] and CellDB["tools"]["dispelRequest"][3] == "specific", drDebuffsText, drDebuffsEB)
end

local function CreateDRPane()
    local drPane = Cell:CreateTitledPane(toolsTab, L["Dispel Request"].." ("..L["Glow"]..")", 422, 183)
    drPane:SetPoint("TOPLEFT", 5, -377)

    drGlowOptionsBtn = Cell:CreateButton(drPane, L["Glow Options"], "class", {105, 17})
    drGlowOptionsBtn:SetPoint("TOPRIGHT", drPane)
    drGlowOptionsBtn:SetScript("OnClick", function()
        whichGlowOption = "dispelRequest"
        Cell:StopRainbowText(srGlowOptionsBtn:GetFontString())
        local fs = drGlowOptionsBtn:GetFontString()
        if fs.rainbow then
            Cell:StopRainbowText(fs)
        else
            Cell:StartRainbowText(fs)
        end
        F:ShowGlowOptions(toolsTab, "dispelRequest", CellDB["tools"]["dispelRequest"][6])
    end)
    drGlowOptionsBtn:SetScript("OnHide", function()
        Cell:StopRainbowText(drGlowOptionsBtn:GetFontString())
    end)
    Cell:RegisterForCloseDropdown(drGlowOptionsBtn)

    local drTips = drPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    drTips:SetPoint("TOPLEFT", 5, -25)
    drTips:SetText(L["Glow unit button when a group member sends a %s request"]:format(Cell:GetPlayerClassColorString()..L["DISPEL"].."|r"))

    -- enabled ----------------------------------------------------------------------
    drEnabledCB = Cell:CreateCheckButton(drPane, L["Enabled"], function(checked, self)
        CellDB["tools"]["dispelRequest"][1] = checked
        UpdateDRWidgets()
        Cell:Fire("UpdateTools", "dispelRequest")
        CellDropdownList:Hide()
        
        if whichGlowOption == "dispelRequest" then
            F:HideGlowOptions()
            Cell:StopRainbowText(drGlowOptionsBtn:GetFontString())
        end
    end)
    drEnabledCB:SetPoint("TOPLEFT", drPane, "TOPLEFT", 5, -45)
    ---------------------------------------------------------------------------------

    -- dispellable ------------------------------------------------------------------
    drDispellableCB = Cell:CreateCheckButton(drPane, L["Dispellable By Me"], function(checked, self)
        CellDB["tools"]["dispelRequest"][2] = checked
        Cell:Fire("UpdateTools", "dispelRequest")
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
                CellDB["tools"]["dispelRequest"][3] = "all"
                UpdateDRWidgets()
                Cell:Fire("UpdateTools", "dispelRequest")
            end
        },
        {
            ["text"] = L["Respond to specific dispellable debuffs"],
            ["value"] = "specific",
            ["onClick"] = function()
                CellDB["tools"]["dispelRequest"][3] = "specific"
                UpdateDRWidgets()
                Cell:Fire("UpdateTools", "dispelRequest")
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
                CellDB["tools"]["dispelRequest"][4] = s
                Cell:Fire("UpdateTools", "dispelRequest")
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
    drMacroEB.gauge = srMacroEB:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
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
            CellDB["tools"]["dispelRequest"][5] = F:StringToTable(drDebuffsEB:GetText(), " ", true)
            drDebuffsEB.gauge:SetText(drDebuffsEB:GetText())
            Cell:Fire("UpdateTools", "dispelRequest")
        end
    end)
    drDebuffsEB.gauge = srMacroEB:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
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
local function ShowTab(tab)
    if tab == "tools" then
        if not init then
            CreateToolsPane()
            CreateSRPane()
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

        -- spell request
        srEnabledCB:SetChecked(CellDB["tools"]["spellRequest"][1])
        knownOnlyCB:SetChecked(CellDB["tools"]["spellRequest"][2])
        freeCDOnlyCB:SetChecked(CellDB["tools"]["spellRequest"][3])
        replyCDCB:SetChecked(CellDB["tools"]["spellRequest"][4])
        srResponseDD:SetSelectedValue(CellDB["tools"]["spellRequest"][5])
        srTimeoutDD:SetSelected(CellDB["tools"]["spellRequest"][6])
        UpdateSRWidgets()
        HideSpellOptions()
        LoadSpellsDropdown()
        
        -- dispel request
        drEnabledCB:SetChecked(CellDB["tools"]["dispelRequest"][1])
        drDispellableCB:SetChecked(CellDB["tools"]["dispelRequest"][2])
        drResponseDD:SetSelectedValue(CellDB["tools"]["dispelRequest"][3])
        drTimeoutDD:SetSelected(CellDB["tools"]["dispelRequest"][4])
        drDebuffsEB:SetText(F:TableToString(CellDB["tools"]["dispelRequest"][5], " "))
        drDebuffsEB.gauge:SetText(drDebuffsEB:GetText())
        drDebuffsEB:SetCursorPosition(0)
        UpdateDRWidgets()
    else
        toolsTab:Hide()
    end
end
Cell:RegisterCallback("ShowOptionsTab", "ToolsTab_ShowTab", ShowTab)