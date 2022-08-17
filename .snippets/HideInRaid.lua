-- 在团队中彻底隐藏 Cell
for i = 1, 8 do
    local header = _G["CellRaidFrameHeader"..i]
    header:SetAttribute("showRaid", false)
end

local function MainFrame_GroupTypeChanged(groupType)
    if groupType == "raid" then
        CellMenuFrame:Hide()
    else
        CellMenuFrame:Show()
    end
end
Cell:RegisterCallback("GroupTypeChanged", "MainFrame_GroupTypeChanged2", MainFrame_GroupTypeChanged)