-------------------------------------------------
-- 2024-05-18 02:24:20 GMT+8
-- repoint party/arena pets
-- 修改小队/竞技场宠物的位置
-------------------------------------------------
local point = "TOPLEFT"
local anchorPoint = "BOTTOMLEFT"
local x = 0
local y = -3

local groupPoint = "TOPLEFT"
local groupAnchorTo = CellMainFrame
local groupAnchorPoint = "TOPRIGHT"
local groupX = 100
local groupY = 0

-------------------------------------------------
local func = function() end
local function Repoint(t, k)
    local last
    for i = 1, 5 do
        local pet = t[k..i]
        if pet then
            pet._ClearAllPoints = pet.ClearAllPoints
            pet.ClearAllPoints = func
            pet._SetPoint = pet.SetPoint
            pet.SetPoint = func

            pet:_ClearAllPoints()
            if last then
                pet:_SetPoint(point, last, anchorPoint, x, y)
            else
                pet:_SetPoint(groupPoint, groupAnchorTo, groupAnchorPoint, groupX, groupY)
            end
            last = pet
        end
    end
end

Repoint(Cell.unitButtons.party, "pet")
Repoint(Cell.unitButtons.arena, "raidpet")