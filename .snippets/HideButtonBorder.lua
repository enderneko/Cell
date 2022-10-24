-- do not forget to set highlight size to -1
-- 需要将高亮尺寸设置为 -1

Cell.funcs:IterateAllUnitButtons(function(b)
    hooksecurefunc(b.func, "UpdatePixelPerfect", function()
        b:SetBackdrop(nil)
    end)
end)