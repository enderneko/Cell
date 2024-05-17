-- 2023-10-07 07:16:43 GMT+8
-- by honeyhoney
local nameList = {
    -- "member1,member2,member3,..."
    "", -- Group 1
    "", -- Group 2
    "", -- Group 3
    "", -- Group 4
    "", -- Group 5
    "", -- Group 6
    "", -- Group 7
    "", -- Group 8
}

local F = Cell.funcs

SLASH_CELLSORT1 = "/csort"
-- SLASH_CELLSORT2 = "/px"

function SlashCmdList.CELLSORT()
    if InCombatLockdown() then return end
    
    for i = 1, 8 do
        local header = _G["CellRaidFrameHeader"..i]
        header:SetAttribute("groupingOrder", "")
        header:SetAttribute("groupFilter", nil)
        header:SetAttribute("groupBy", nil)
        header:SetAttribute("sortMethod", "NAMELIST")
        header:SetAttribute("nameList", nameList[i])
    end
    
    F:Print("re-sorted.")
end