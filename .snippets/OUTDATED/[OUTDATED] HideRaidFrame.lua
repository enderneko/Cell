-------------------------------------------------
-- 2024-05-18 02:10:40 GMT+8
-- Hide Cell raid frame (not ideal)
-- 隐藏 Cell 的团队框体（不太好使）
-------------------------------------------------
local function Hide()
    if Cell.vars.groupType == "raid" then
        for i = 0, 8 do
            local header = _G["CellRaidFrameHeader"..i]
            header:SetAttribute("showRaid", false)
        end
        C_Timer.After(0.2, function()
            CellMenuFrame:Hide()
        end)
    end
end

Cell.RegisterCallback("GroupTypeChanged", "MainFrame_GroupTypeChanged2", Hide)
Cell.RegisterCallback("UpdateLayout", "RaidFrame_UpdateLayout", Hide)