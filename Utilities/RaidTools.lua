local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs
local LCG = LibStub("LibCustomGlow-1.0")

-------------------------------------------------
-- raid tools
-------------------------------------------------
local rtPane
local resCB, reportCB, buffCB, readyPullCB, pullDropdown, secEditBox, marksBarCB, marksDropdown, marksShowSoloCB, fadeOutToolsCB

local function CreateRTPane()
    rtPane = Cell:CreateTitledPane(Cell.frames.utilitiesTab, L["Raid Tools"].." |cFF777777"..L["only in group"], 422, 167)
    rtPane:SetPoint("TOPLEFT", 5, -5)
    rtPane:SetPoint("BOTTOMRIGHT", -5, 5)

    local unlockBtn = Cell:CreateButton(rtPane, L["Unlock"], "accent", {77, 17})
    unlockBtn:SetPoint("TOPRIGHT", rtPane)
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
    resCB = Cell:CreateCheckButton(rtPane, L["Battle Res Timer"], function(checked, self)
        CellDB["tools"]["showBattleRes"] = checked
        Cell:Fire("UpdateTools", "battleRes")
    end, L["Battle Res Timer"], L["Only show during encounter or in mythic+"])
    resCB:SetPoint("TOPLEFT", rtPane, "TOPLEFT", 5, -27)
    resCB:SetEnabled(Cell.isRetail)

    -- death report
    reportCB = Cell:CreateCheckButton(rtPane, L["Death Report"], function(checked, self)
        CellDB["tools"]["deathReport"][1] = checked
        Cell:Fire("UpdateTools", "deathReport")
    end)
    reportCB:SetPoint("TOPLEFT", resCB, "BOTTOMLEFT", 0, -15)
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
    buffCB = Cell:CreateCheckButton(rtPane, L["Buff Tracker"], function(checked, self)
        CellDB["tools"]["buffTracker"][1] = checked
        Cell:Fire("UpdateTools", "buffTracker")
    end, L["Buff Tracker"].." |cffff7727"..L["MODERATE CPU USAGE"], L["Check if your group members need some raid buffs"], 
    Cell.isRetail and L["|cffffb5c5Left-Click:|r cast the spell"] or "|cffffb5c5(Shift)|r "..L["|cffffb5c5Left-Click:|r cast the spell"], 
    L["|cffffb5c5Right-Click:|r report unaffected"], 
    L["Use |cFFFFB5C5/cell buff X|r to set icon size"], 
    "|cffffffff" .. L["Current"]..": |cFFFFB5C5"..CellDB["tools"]["buffTracker"][3])
    buffCB:SetPoint("TOPLEFT", reportCB, "BOTTOMLEFT", 0, -15)

    -- ready & pull
    readyPullCB = Cell:CreateCheckButton(rtPane, L["ReadyCheck and PullTimer buttons"], function(checked, self)
        CellDB["tools"]["readyAndPull"][1] = checked
        pullDropdown:SetEnabled(checked)
        secEditBox:SetEnabled(checked)
        Cell:Fire("UpdateTools", "buttons")
    end, L["ReadyCheck and PullTimer buttons"], L["Only show when you have permission to do this"], L["readyCheckTips"], L["pullTimerTips"])
    readyPullCB:SetPoint("TOPLEFT", buffCB, "BOTTOMLEFT", 0, -15)
    Cell:RegisterForCloseDropdown(readyPullCB)

    pullDropdown = Cell:CreateDropdown(rtPane, 90)
    pullDropdown:SetPoint("TOPLEFT", readyPullCB, "BOTTOMRIGHT", 5, -5)
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

    secEditBox = Cell:CreateEditBox(rtPane, 38, 20, false, false, true)
    secEditBox:SetPoint("TOPLEFT", pullDropdown, "TOPRIGHT", 5, 0)
    secEditBox:SetMaxLetters(3)

    secEditBox.confirmBtn = Cell:CreateButton(rtPane, "OK", "accent", {27, 20})
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
    marksBarCB = Cell:CreateCheckButton(rtPane, L["Marks Bar"], function(checked, self)
        CellDB["tools"]["marks"][1] = checked
        marksDropdown:SetEnabled(checked)
        marksShowSoloCB:SetEnabled(checked)
        Cell:Fire("UpdateTools", "marks")
    end, L["Marks Bar"], L["Only show when you have permission to do this"], L["marksTips"])
    marksBarCB:SetPoint("TOPLEFT", readyPullCB, "BOTTOMLEFT", 0, -43)
    Cell:RegisterForCloseDropdown(marksBarCB)

    marksDropdown = Cell:CreateDropdown(rtPane, 217)
    marksDropdown:SetPoint("TOPLEFT", marksBarCB, "BOTTOMRIGHT", 5, -5)
    marksDropdown:SetItems({
        {
            ["text"] = L["Target Marks"].." ("..L["Horizontal"]..")",
            ["value"] = "target_h",
            ["onClick"] = function()
                CellDB["tools"]["marks"][3] = "target_h"
                Cell:Fire("UpdateTools", "marks")
            end,
        },
        {
            ["text"] = L["Target Marks"].." ("..L["Vertical"]..")",
            ["value"] = "target_v",
            ["onClick"] = function()
                CellDB["tools"]["marks"][3] = "target_v"
                Cell:Fire("UpdateTools", "marks")
            end,
        },
        {
            ["text"] = L["World Marks"].." ("..L["Horizontal"]..")",
            ["value"] = "world_h",
            ["disabled"] = Cell.isWrath,
            ["onClick"] = function()
                CellDB["tools"]["marks"][3] = "world_h"
                Cell:Fire("UpdateTools", "marks")
            end,
        },
        {
            ["text"] = L["World Marks"].." ("..L["Vertical"]..")",
            ["value"] = "world_v",
            ["disabled"] = Cell.isWrath,
            ["onClick"] = function()
                CellDB["tools"]["marks"][3] = "world_v"
                Cell:Fire("UpdateTools", "marks")
            end,
        },
        {
            ["text"] = L["Both"].." ("..L["Horizontal"]..")",
            ["value"] = "both_h",
            ["disabled"] = Cell.isWrath,
            ["onClick"] = function()
                CellDB["tools"]["marks"][3] = "both_h"
                Cell:Fire("UpdateTools", "marks")
            end,
        },
        {
            ["text"] = L["Both"].." ("..L["Vertical"]..")",
            ["value"] = "both_v",
            ["disabled"] = Cell.isWrath,
            ["onClick"] = function()
                CellDB["tools"]["marks"][3] = "both_v"
                Cell:Fire("UpdateTools", "marks")
            end,
        }
    })

    marksShowSoloCB = Cell:CreateCheckButton(rtPane, L["Show Solo"], function(checked, self)
        CellDB["tools"]["marks"][2] = checked
        Cell:Fire("UpdateTools", "marks")
    end)
    marksShowSoloCB:SetPoint("TOPLEFT", marksDropdown, "BOTTOMLEFT", 0, -8)

    -- fadeOut
    fadeOutToolsCB = Cell:CreateCheckButton(rtPane, L["Fade Out These Buttons"], function(checked, self)
        CellDB["tools"]["fadeOut"] = checked
        Cell:Fire("UpdateTools", "fadeOut")
    end)
    fadeOutToolsCB:SetPoint("TOPLEFT", marksBarCB, "BOTTOMLEFT", 0, -70)

    local region = CreateFrame("Frame", nil, rtPane)
    region:SetPoint("TOPLEFT", buffCB, -5, 5)
    region:SetPoint("BOTTOM", marksShowSoloCB, 0, -5)
    region:SetPoint("RIGHT", -5, 0)

    fadeOutToolsCB:HookScript("OnEnter", function()
        LCG.PixelGlow_Start(region, Cell:GetAccentColorTable(1), 27, 0.1, 17, 1)
    end)
    fadeOutToolsCB:HookScript("OnLeave", function()
        LCG.PixelGlow_Stop(region)
    end)
end

-------------------------------------------------
-- show
-------------------------------------------------
local init
local function ShowUtilitySettings(which)
    if which == "raidTools" then
        if not init then
            CreateRTPane()
            F:ApplyCombatProtectionToFrame(rtPane, -4, 4, 4, -4)
        end
        
        rtPane:Show()
        
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
        marksDropdown:SetSelectedValue(CellDB["tools"]["marks"][3])
        marksShowSoloCB:SetChecked(CellDB["tools"]["marks"][2])

        fadeOutToolsCB:SetChecked(CellDB["tools"]["fadeOut"])
        
    elseif init then
        rtPane:Hide()
    end
end
Cell:RegisterCallback("ShowUtilitySettings", "RaidTools_ShowUtilitySettings", ShowUtilitySettings)