-- 高亮当前血量显示可驱散效果

-- 使用纯色材质（而非血条材质）
local USE_SOLID_COLOR_TEXTURE = false

local F = Cell.funcs

F:IterateAllUnitButtons(function(b)
    local dispels = b.indicators.dispels

    dispels.highlight:ClearAllPoints()
    dispels.highlight:SetAllPoints(b.widget.healthBar:GetStatusBarTexture())
    if USE_SOLID_COLOR_TEXTURE then
        dispels.highlight:SetTexture("Interface\\Buttons\\WHITE8x8")
    else
        dispels.highlight:SetTexture(Cell.vars.texture)
    end

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
        dispels.highlight:SetVertexColor(r, g, b, a)
    end

    -- 修改护盾材质
    -- b.widget.shieldBar:SetTexture(Cell.vars.texture)
end)