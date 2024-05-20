-- relative to Leader Icon indicator
local point, relativePoint, x, y = "TOPLEFT", "BOTTOMLEFT", 0, 2
local size = 11

local function UpdateAssignmentIcon(b, event)
    local unit = b.states.unit
    if not unit then return end

    if InCombatLockdown() or event == "PLAYER_REGEN_DISABLED" then
        b.widgets.assignmentIcon:Hide()
    else
        if GetPartyAssignment("MAINTANK", unit) then
            b.widgets.assignmentIcon:SetTexture("Interface\\GroupFrame\\UI-Group-MainTankIcon")
            b.widgets.assignmentIcon:Show()
        elseif GetPartyAssignment("MAINASSIST", unit) then
            b.widgets.assignmentIcon:SetTexture("Interface\\GroupFrame\\UI-Group-MainAssistIcon")
            b.widgets.assignmentIcon:Show()
        else
            b.widgets.assignmentIcon:Hide()
        end
    end
end

Cell.funcs:IterateAllUnitButtons(function(b)
    local assignmentIcon = b.widgets.overlayFrame:CreateTexture(b:GetName().."AssignmentIcon", "ARTWORK", nil, -7)
    b.widgets.assignmentIcon = assignmentIcon
    assignmentIcon:SetPoint(point, b.indicators.leaderIcon, relativePoint, x, y)
    assignmentIcon:SetSize(size, size)
    assignmentIcon:Hide()

    b:HookScript("OnEvent", function(self, event)
        if event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
            UpdateAssignmentIcon(self, event)
        end
    end)

    if b:IsShown() then UpdateAssignmentIcon(b) end
end)
