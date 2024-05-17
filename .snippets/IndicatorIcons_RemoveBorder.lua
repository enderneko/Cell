-------------------------------------------------
-- 2024-05-18 03:09:08 GMT+8
-- remove icons border
-- 删除图标指示器的边框
-------------------------------------------------
hooksecurefunc(Cell.iFuncs, "CreateAura_BarIcon", function(name, parent)
    local f = _G[name]
    hooksecurefunc(f, "SetCooldown", function()
        f:SetBackdropColor(0, 0, 0, 0)
    end)
end)