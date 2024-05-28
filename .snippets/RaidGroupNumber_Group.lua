-------------------------------------------------
-- 2024-05-18 02:22:11 GMT+8
-- 在团队中显示队伍编号（可能会被菜单按钮挡住）
-------------------------------------------------
for i = 1, 8 do
    local header = _G["CellRaidFrameHeader"..i]
    header.groupNumber = header[1]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header.groupNumber:SetPoint("BOTTOM", header, "TOP", 0, 2)
    header.groupNumber:SetText("队伍"..i)
end