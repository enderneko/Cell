local point, relativePoint, x, y = "TOPLEFT", "BOTTOMLEFT", 0, 2
local size = 11

local function UpdateAssignmentIcon(b, event)
    local unit = b.state.unit
    if not unit then return end
    
    if InCombatLockdown() or event == "PLAYER_REGEN_DISABLED" then
        b.widget.assignmentIcon:Hide()
    else
        if GetPartyAssignment("MAINTANK", unit) then
            b.widget.assignmentIcon:SetTexture("Interface\\GroupFrame\\UI-Group-MainTankIcon")
            b.widget.assignmentIcon:Show()
        elseif GetPartyAssignment("MAINASSIST", unit) then
            b.widget.assignmentIcon:SetTexture("Interface\\GroupFrame\\UI-Group-MainAssistIcon")
            b.widget.assignmentIcon:Show()
        else
            b.widget.assignmentIcon:Hide()
        end
    end
end

Cell.funcs:IterateAllUnitButtons(function(b)
    local assignmentIcon = b.widget.overlayFrame:CreateTexture(b:GetName().."AssignmentIcon", "ARTWORK", nil, -7)
    b.widget.assignmentIcon = assignmentIcon
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