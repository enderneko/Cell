-- show dispel highlight with solid color (entire unit button)
-- 使用纯色而非渐变色显示驱散高亮
local ALPHA = 0.6

local F = Cell.funcs

F:IterateAllUnitButtons(function(b)
    local dispels = b.indicators.dispels

    dispels.highlight:ClearAllPoints()
    dispels.highlight:SetPoint("BOTTOMLEFT", b.widget.healthBar)
    dispels.highlight:SetPoint("BOTTOMRIGHT", b.widget.healthBar)
    dispels.highlight:SetPoint("TOP", b.widget.healthBar)

    function dispels:SetDispels(dispelTypes)
        local r, g, b, a = 0, 0, 0, 0

        local i = 1
        for dispelType, _ in pairs(dispelTypes) do
            if a == 0 and dispelType then
                r, g, b, a = DebuffTypeColor[dispelType].r, DebuffTypeColor[dispelType].g, DebuffTypeColor[dispelType].b, 1
            end
            dispels[i]:SetDispel(dispelType)
            i = i + 1
        end

        -- hide unused
        for j = i, 4 do
            dispels[j]:Hide()
        end

        -- highlight
        dispels.highlight:SetColorTexture(r, g, b, a ~= 0 and ALPHA or 0)
    end

    -- 修改护盾材质
    -- b.widget.shieldBar:SetTexture(Cell.vars.texture)
end)