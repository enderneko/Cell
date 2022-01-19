local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

local marks, worldMarks

local marksFrame = CreateFrame("Frame", "CellRaidMarksFrame", Cell.frames.mainFrame, "BackdropTemplate")
Cell.frames.raidMarksFrame = marksFrame
P:Size(marksFrame, 196, 40)
marksFrame:SetPoint("BOTTOMRIGHT", UIParent, "CENTER")
marksFrame:SetClampedToScreen(true)
marksFrame:SetMovable(true)
marksFrame:RegisterForDrag("LeftButton")
marksFrame:SetScript("OnDragStart", function()
    marksFrame:StartMoving()
    marksFrame:SetUserPlaced(false)
end)
marksFrame:SetScript("OnDragStop", function()
    marksFrame:StopMovingOrSizing()
    P:SavePosition(marksFrame, CellDB["raidTools"]["marksPosition"])
end)

-------------------------------------------------
-- mover
-------------------------------------------------
marksFrame.moverText = marksFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
marksFrame.moverText:SetPoint("TOP", 0, -3)
marksFrame.moverText:SetText(L["Mover"])
marksFrame.moverText:Hide()

local function ShowMover(show)
    if show then
        if not CellDB["raidTools"]["showMarks"] then return end
        marksFrame:EnableMouse(true)
        marksFrame.moverText:Show()
        Cell:StylizeFrame(marksFrame, {0, 1, 0, 0.4}, {0, 0, 0, 0})
        if not F:HasPermission(true) then -- button not shown
            if CellDB["raidTools"]["marks"] == "target" then
                marks:Show()
            elseif CellDB["raidTools"]["marks"] == "world" then
                worldMarks:Show()
            else
                marks:Show()
                worldMarks:Show()
            end
        end
    else
        marksFrame:EnableMouse(false)
        marksFrame.moverText:Hide()
        Cell:StylizeFrame(marksFrame, {0, 0, 0, 0}, {0, 0, 0, 0})
        if not F:HasPermission(true) then -- button should not shown
            marks:Hide()
            worldMarks:Hide()
        end
    end
end
Cell:RegisterCallback("ShowMover", "RaidMarks_ShowMover", ShowMover)

-------------------------------------------------
-- colors
-------------------------------------------------
local markColors = {
    {1, 1, 0}, -- star
    {1, .5, 0}, -- circle
    {.5, 0, 1}, -- diamond
    {0, 1, .2}, -- triangle
    {.5, .5, .5}, -- moon
    {0, .5, 1}, -- square
    {1, 0, 0}, -- cross
    {1, 1, 1}, -- skull
    {1, .19, .19}, -- clear
}

-------------------------------------------------
-- marks
-------------------------------------------------
marks = Cell:CreateFrame("CellRaidMarksFrame_Marks", marksFrame, 196, 20, true)
marks:SetPoint("BOTTOMLEFT")
marks:Hide()

local ticker
local markButtons = {}
for i = 1, 9 do
    markButtons[i] = Cell:CreateButton(marks, "", "class-hover", {20, 20})
    markButtons[i].texture = markButtons[i]:CreateTexture(nil, "ARTWORK")
    markButtons[i].texture:SetPoint("TOPLEFT", 2, -2)
    markButtons[i].texture:SetPoint("BOTTOMRIGHT", -2, 2)
    
    if i == 9 then
        -- clear all marks
        markButtons[i].texture:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
        markButtons[i]:SetScript("OnClick", function()
            markButtons[i]:SetEnabled(false)
            markButtons[i].texture:SetDesaturated(true)
            for j = 1, 8 do
                SetRaidTarget("player", j)
            end
            C_Timer.After(.5, function()
                SetRaidTarget("player", 0)
                markButtons[i]:SetEnabled(true)
                markButtons[i].texture:SetDesaturated(false)
            end)
        end)
    else
        markButtons[i].texture:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
        SetRaidTargetIconTexture(markButtons[i].texture, i)
        markButtons[i]:RegisterForClicks("LeftButtonDown", "RightButtonDown")
        markButtons[i]:SetScript("OnClick", function(self, button)
            if button == "LeftButton" then
                -- set raid target icon
                if GetRaidTargetIndex("target") == i then
                    SetRaidTarget("target", 0)
                else
                    SetRaidTarget("target", i)
                end
            elseif button == "RightButton" then -- TODO:
                -- lock raid target icon
                local unit, name, class = F:GetTargetUnitInfo()
                if unit and name then
                    if markButtons[i].locked then
                        F:NotifyMarkUnlock(i, name, class)
                        SetRaidTarget(markButtons[i].locked, 0)
                        markButtons[i]:SetBackdropBorderColor(0, 0, 0, 1)
                        markButtons[i].locked = nil
                        if markButtons[i].ticker then
                            markButtons[i].ticker:Cancel()
                            markButtons[i].ticker = nil
                        end
                    else
                        F:NotifyMarkLock(i, name, class)
                        SetRaidTarget(unit, i)
                        markButtons[i]:SetBackdropBorderColor(markColors[i][1], markColors[i][2], markColors[i][3], 1)
                        markButtons[i].locked = unit
                        markButtons[i].ticker = C_Timer.NewTicker(1.5, function()
                            if UnitName(unit) == name then
                                if GetRaidTargetIndex(unit) ~= i then
                                    SetRaidTarget(unit, i)
                                end
                            else
                                markButtons[i].locked = nil
                                markButtons[i].ticker:Cancel()
                                markButtons[i].ticker = nil
                                markButtons[i]:SetBackdropBorderColor(0, 0, 0, 1)
                            end
                        end)
                    end
                end
            end
        end)
    end

    markButtons[i].bg:SetColorTexture(0.1, 0.1, 0.1, 0.7)
    markButtons[i]:SetBackdropColor(0, 0, 0, 0)
    markButtons[i].color = {0, 0, 0, 0}
    markButtons[i].hoverColor = {markColors[i][1], markColors[i][2], markColors[i][3], 0.35}

    if i == 1 then
        P:Point(markButtons[i], "TOPLEFT")
    else
        P:Point(markButtons[i], "LEFT", markButtons[i-1], "RIGHT", 2, 0)
    end
end

marks:SetScript("OnHide", function()
    for i = 1, 8 do
        markButtons[i].locked = nil
        if markButtons[i].ticker then
            markButtons[i].ticker:Cancel()
            markButtons[i].ticker = nil
        end
        markButtons[i]:SetBackdropBorderColor(0, 0, 0, 1)
    end
end)

-------------------------------------------------
-- world marks
-------------------------------------------------
worldMarks = Cell:CreateFrame("CellRaidMarksFrame_WorldMarks", marksFrame, 196, 20, true)
worldMarks:SetPoint("BOTTOMLEFT")
worldMarks:Hide()

local worldMarkIndices = {5, 6, 3, 2, 7, 1, 4, 8}
local worldMarkButtons = {}
for i = 1, 9 do
    worldMarkButtons[i] = Cell:CreateButton(worldMarks, "", "class-hover", {20, 20}, false, false, nil, nil, "SecureActionButtonTemplate")
    worldMarkButtons[i].texture = worldMarkButtons[i]:CreateTexture(nil, "ARTWORK")
    
    if i == 9 then
        -- clear all marks
        worldMarkButtons[i].texture:SetPoint("TOPLEFT", 2, -2)
        worldMarkButtons[i].texture:SetPoint("BOTTOMRIGHT", -2, 2)
        worldMarkButtons[i].texture:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
        worldMarkButtons[i]:SetAttribute("type", "worldmarker")
        worldMarkButtons[i]:SetAttribute("action", "clear")
    else
        worldMarkButtons[i].texture:SetPoint("TOPLEFT", 1, -1)
        worldMarkButtons[i].texture:SetPoint("BOTTOMRIGHT", -1, 1)
        worldMarkButtons[i].texture:SetColorTexture(markColors[i][1], markColors[i][2], markColors[i][3], .4)
        worldMarkButtons[i]:SetAttribute("type", "worldmarker")
        worldMarkButtons[i]:SetAttribute("marker", worldMarkIndices[i])
        -- worldMarkButtons[i]:SetAttribute("type", "macro")
        -- worldMarkButtons[i]:SetAttribute("macrotext", "/wm "..worldMarkIndices[i])
    end

    worldMarkButtons[i].bg:SetColorTexture(0.1, 0.1, 0.1, 0.7)
    worldMarkButtons[i]:SetBackdropColor(0, 0, 0, 0)
    worldMarkButtons[i].color = {0, 0, 0, 0}
    worldMarkButtons[i].hoverColor = {markColors[i][1], markColors[i][2], markColors[i][3], 0.35}

    if i == 1 then
        P:Point(worldMarkButtons[i], "TOPLEFT")
    else
        P:Point(worldMarkButtons[i], "LEFT", worldMarkButtons[i-1], "RIGHT", 2, 0)
    end
end

local worldMarksTimer
worldMarks:SetScript("OnShow", function()
    worldMarksTimer = C_Timer.NewTicker(.5, function()
        for i = 1, 8 do
            if IsRaidMarkerActive(worldMarkIndices[i]) then
                worldMarkButtons[i]:SetBackdropBorderColor(markColors[i][1], markColors[i][2], markColors[i][3], 1)
            else
                worldMarkButtons[i]:SetBackdropBorderColor(0, 0, 0, 1)
            end
        end
    end)
end)
worldMarks:SetScript("OnHide", function()
    if worldMarksTimer then
        worldMarksTimer:Cancel()
        worldMarksTimer = nil
    end
end)

-------------------------------------------------
-- functions
-------------------------------------------------
local function CheckPermission()
    if InCombatLockdown() then
        marksFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    else
        marksFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
        if CellDB["raidTools"]["showMarks"] then
            if CellDB["raidTools"]["marks"] == "target" then
                worldMarks:Hide()
                P:Height(marksFrame, 40)
                marks:ClearAllPoints()
                marks:SetPoint("BOTTOMLEFT")

                if marksFrame.moverText:IsShown() or Cell.vars.hasPartyMarkPermission then
                    marks:Show()
                else
                    marks:Hide()
                end
                
            elseif CellDB["raidTools"]["marks"] == "world" then
                marks:Hide()
                worldMarks:ClearAllPoints()
                worldMarks:SetPoint("BOTTOMLEFT")
                P:Height(marksFrame, 40)
                if marksFrame.moverText:IsShown() or Cell.vars.hasPartyMarkPermission then
                    worldMarks:Show()
                else
                    worldMarks:Hide()
                end

            else -- both
                worldMarks:ClearAllPoints()
                worldMarks:SetPoint("BOTTOMLEFT")
                marks:ClearAllPoints()
                P:Point(marks, "BOTTOMLEFT", worldMarks, "TOPLEFT", 0, 2)
                P:Height(marksFrame, 60)
                if marksFrame.moverText:IsShown() or Cell.vars.hasPartyMarkPermission then
                    marks:Show()
                    worldMarks:Show()
                else
                    marks:Hide()
                    worldMarks:Hide()
                end
            end
        else
            marks:Hide()
            worldMarks:Hide()
        end
    end
end

marksFrame:SetScript("OnEvent", function()
    CheckPermission()
end)

Cell:RegisterCallback("PermissionChanged", "RaidMarks_PermissionChanged", CheckPermission)

local function UpdateRaidTools(which)
    if not which or which == "marks" then
        CheckPermission()
    end

    if not which then -- position
        P:LoadPosition(marksFrame, CellDB["raidTools"]["marksPosition"])
    end
end
Cell:RegisterCallback("UpdateRaidTools", "RaidMarks_UpdateRaidTools", UpdateRaidTools)

local function UpdatePixelPerfect()
    P:Resize(marksFrame)
    P:Resize(marks)
    P:Repoint(marks) -- only marks needs to repoint
    P:Resize(worldMarks)

    for i = 1, 9 do
        markButtons[i]:UpdatePixelPerfect()
        worldMarkButtons[i]:UpdatePixelPerfect()
    end
end
Cell:RegisterCallback("UpdatePixelPerfect", "Marks_UpdatePixelPerfect", UpdatePixelPerfect)