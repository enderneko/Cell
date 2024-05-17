-- hide button border, a negative highlight size is recommended
-- 隐藏按钮边框，建议将高亮尺寸设定为负值

hooksecurefunc(Cell.bFuncs, "UpdatePixelPerfect", function(self, b)
    b:SetBackdrop(nil)
end)