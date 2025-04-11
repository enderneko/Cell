-------------------------------------------------
-- 2025-04-11 17:11:18 GMT+8
-- remove icons border
-- 删除图标指示器的边框
-------------------------------------------------
local create = Cell.iFuncs.CreateAura_BarIcon
Cell.iFuncs.CreateAura_BarIcon = function(name, parent)
    local f = create(name, parent)
    hooksecurefunc(f, "SetCooldown", function()
        f:SetBackdropColor(0, 0, 0, 0)
    end)
    return f
end