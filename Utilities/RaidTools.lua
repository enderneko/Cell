local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs
local LCG = LibStub("LibCustomGlow-1.0")

-------------------------------------------------
-- raid tools
-------------------------------------------------
local rtPane
local resCB, reportCB, buffCB, buffDropdown, sizeEditBox, readyPullCB, styleDropdown, pullDropdown, secEditBox, marksBarCB, marksDropdown, marksShowSoloCB, fadeOutToolsCB

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
        buffDropdown:SetEnabled(checked)
        sizeEditBox:SetEnabled(checked)
        Cell:Fire("UpdateTools", "buffTracker")
    end, L["Buff Tracker"].." |cffff7727"..L["MODERATE CPU USAGE"], L["Check if your group members need some raid buffs"], 
    Cell.isRetail and L["|cffffb5c5Left-Click:|r cast the spell"] or "|cffffb5c5(Shift)|r "..L["|cffffb5c5Left-Click:|r cast the spell"], 
    L["|cffffb5c5Right-Click:|r report unaffected"])
    -- L["Use |cFFFFB5C5/cell buff X|r to set icon size"], 
    -- "|cffffffff" .. L["Current"]..": |cFFFFB5C5"..CellDB["tools"]["buffTracker"][3])
    buffCB:SetPoint("TOPLEFT", reportCB, "BOTTOMLEFT", 0, -15)

    buffDropdown = Cell:CreateDropdown(rtPane, 120)
    buffDropdown:SetPoint("TOPLEFT", buffCB, "BOTTOMRIGHT", 5, -5)
    buffDropdown:SetItems({
        {
            ["text"] = L["left-to-right"],
            ["value"] = "left-to-right",
            ["onClick"] = function()
                CellDB["tools"]["buffTracker"][2] = "left-to-right"
                Cell:Fire("UpdateTools", "buffTracker")
            end,
        },
        {
            ["text"] = L["right-to-left"],
            ["value"] = "right-to-left",
            ["onClick"] = function()
                CellDB["tools"]["buffTracker"][2] = "right-to-left"
                Cell:Fire("UpdateTools", "buffTracker")
            end,
        },
        {
            ["text"] = L["top-to-bottom"],
            ["value"] = "top-to-bottom",
            ["onClick"] = function()
                CellDB["tools"]["buffTracker"][2] = "top-to-bottom"
                Cell:Fire("UpdateTools", "buffTracker")
            end,
        },
        {
            ["text"] = L["bottom-to-top"],
            ["value"] = "bottom-to-top",
            ["onClick"] = function()
                CellDB["tools"]["buffTracker"][2] = "bottom-to-top"
                Cell:Fire("UpdateTools", "buffTracker")
            end,
        },
    })

    sizeEditBox = Cell:CreateEditBox(rtPane, 38, 20, false, false, true)
    sizeEditBox:SetPoint("TOPLEFT", buffDropdown, "TOPRIGHT", 5, 0)
    sizeEditBox:SetMaxLetters(3)

    sizeEditBox.confirmBtn = Cell:CreateButton(rtPane, "OK", "accent", {27, 20})
    sizeEditBox.confirmBtn:SetPoint("TOPLEFT", sizeEditBox, "TOPRIGHT", P:Scale(-1), 0)
    sizeEditBox.confirmBtn:Hide()
    sizeEditBox.confirmBtn:SetScript("OnHide", function()
        sizeEditBox.confirmBtn:Hide()
    end)
    sizeEditBox.confirmBtn:SetScript("OnClick", function()
        CellDB["tools"]["buffTracker"][3] = tonumber(sizeEditBox:GetText())
        Cell:Fire("UpdateTools", "buffTracker")
        sizeEditBox.confirmBtn:Hide()
        sizeEditBox:ClearFocus()
    end)

    sizeEditBox:SetScript("OnTextChanged", function(self, userChanged)
        if userChanged then
            local newSize = tonumber(self:GetText())
            if newSize and newSize > 0 and newSize ~= CellDB["tools"]["buffTracker"][3] then
                sizeEditBox.confirmBtn:Show()
            else
                sizeEditBox.confirmBtn:Hide()
            end
        end
    end)

    -- ready & pull
    readyPullCB = Cell:CreateCheckButton(rtPane, L["ReadyCheck and PullTimer buttons"], function(checked, self)
        CellDB["tools"]["readyAndPull"][1] = checked
        styleDropdown:SetEnabled(checked)
        pullDropdown:SetEnabled(checked)
        secEditBox:SetEnabled(checked)
        Cell:Fire("UpdateTools", "buttons")
    end, L["ReadyCheck and PullTimer buttons"], L["Only show when you have permission to do this"], L["readyCheckTips"], L["pullTimerTips"])
    readyPullCB:SetPoint("TOPLEFT", buffCB, "BOTTOMLEFT", 0, -43)
    Cell:RegisterForCloseDropdown(readyPullCB)

    styleDropdown = Cell:CreateDropdown(rtPane, 120)
    styleDropdown:SetPoint("TOPLEFT", readyPullCB, "BOTTOMRIGHT", 5, -5)
    styleDropdown:SetItems({
        {
            ["text"] = L["Ready"].." / "..L["Pull"],
            ["value"] = "text_button",
            ["onClick"] = function()
                CellDB["tools"]["readyAndPull"][2] = "text_button"
                Cell:Fire("UpdateTools", "readyAndPull")
            end,
        },
        {
            ["text"] = "|TInterface\\AddOns\\Cell\\Media\\Icons\\ready:14|t / |TInterface\\AddOns\\Cell\\Media\\Icons\\pull:14|t A",
            ["value"] = "icon_button_h",
            ["onClick"] = function()
                CellDB["tools"]["readyAndPull"][2] = "icon_button_h"
                Cell:Fire("UpdateTools", "readyAndPull")
            end,
        },
        {
            ["text"] = "|TInterface\\AddOns\\Cell\\Media\\Icons\\ready:14|t / |TInterface\\AddOns\\Cell\\Media\\Icons\\pull:14|t B",
            ["value"] = "icon_button_v",
            ["onClick"] = function()
                CellDB["tools"]["readyAndPull"][2] = "icon_button_v"
                Cell:Fire("UpdateTools", "readyAndPull")
            end,
        },
    })

    pullDropdown = Cell:CreateDropdown(rtPane, 109)
    pullDropdown:SetPoint("TOPLEFT", styleDropdown, "TOPRIGHT", 5, 0)
    pullDropdown:SetItems({
        {
            ["text"] = L["Default"],
            ["value"] = "default",
            ["onClick"] = function()
                CellDB["tools"]["readyAndPull"][3][1] = "default"
                Cell:Fire("UpdateTools", "readyAndPull")
            end,
        },
        {
            ["text"] = "MRT",
            ["value"] = "mrt",
            ["onClick"] = function()
                CellDB["tools"]["readyAndPull"][3][1] = "mrt"
                Cell:Fire("UpdateTools", "readyAndPull")
            end,
        },
        {
            ["text"] = "DBM",
            ["value"] = "dbm",
            ["onClick"] = function()
                CellDB["tools"]["readyAndPull"][3][1] = "dbm"
                Cell:Fire("UpdateTools", "readyAndPull")
            end,
        },
        {
            ["text"] = "BigWigs",
            ["value"] = "bw",
            ["onClick"] = function()
                CellDB["tools"]["readyAndPull"][3][1] = "bw"
                Cell:Fire("UpdateTools", "readyAndPull")
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
        CellDB["tools"]["readyAndPull"][3][2] = tonumber(secEditBox:GetText())
        Cell:Fire("UpdateTools", "readyAndPull")
        secEditBox.confirmBtn:Hide()
    end)

    secEditBox:SetScript("OnTextChanged", function(self, userChanged)
        if userChanged then
            local newSec = tonumber(self:GetText())
            if newSec and newSec > 0 and newSec ~= CellDB["tools"]["readyAndPull"][3][2] then
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
            ["disabled"] = Cell.isVanilla or Cell.isCata,
            ["onClick"] = function()
                CellDB["tools"]["marks"][3] = "world_h"
                Cell:Fire("UpdateTools", "marks")
            end,
        },
        {
            ["text"] = L["World Marks"].." ("..L["Vertical"]..")",
            ["value"] = "world_v",
            ["disabled"] = Cell.isVanilla or Cell.isCata,
            ["onClick"] = function()
                CellDB["tools"]["marks"][3] = "world_v"
                Cell:Fire("UpdateTools", "marks")
            end,
        },
        {
            ["text"] = L["Both"].." ("..L["Horizontal"]..")",
            ["value"] = "both_h",
            ["disabled"] = Cell.isVanilla or Cell.isCata,
            ["onClick"] = function()
                CellDB["tools"]["marks"][3] = "both_h"
                Cell:Fire("UpdateTools", "marks")
            end,
        },
        {
            ["text"] = L["Both"].." ("..L["Vertical"]..")",
            ["value"] = "both_v",
            ["disabled"] = Cell.isVanilla or Cell.isCata,
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
        
        -- if init then return end
        init = true

        -- raid tools
        resCB:SetChecked(CellDB["tools"]["showBattleRes"])
        reportCB:SetChecked(CellDB["tools"]["deathReport"][1])
        
        buffCB:SetChecked(CellDB["tools"]["buffTracker"][1])
        buffDropdown:SetSelectedValue(CellDB["tools"]["buffTracker"][2])
        sizeEditBox:SetText(CellDB["tools"]["buffTracker"][3])
        Cell:SetEnabled(CellDB["tools"]["buffTracker"][1], buffDropdown, sizeEditBox)

        readyPullCB:SetChecked(CellDB["tools"]["readyAndPull"][1])
        styleDropdown:SetSelectedValue(CellDB["tools"]["readyAndPull"][2])
        pullDropdown:SetSelectedValue(CellDB["tools"]["readyAndPull"][3][1])
        secEditBox:SetText(CellDB["tools"]["readyAndPull"][3][2])
        Cell:SetEnabled(CellDB["tools"]["readyAndPull"][1], styleDropdown, pullDropdown, secEditBox)

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