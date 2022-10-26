local F = Cell.funcs

-- 自定义驱散类型颜色 custom dispel type color
local debuffTypeColor = {
    [""] = {r = 0.8, g = 0, b = 0},
    ["Curse"] = {r = 0.6, g = 0, b = 1},
    ["Disease"] = {r = 0.6, g = 0.4, b = 0},
    ["Magic"] = {r = 0.2, g = 0.6, b = 1},
    ["Poison"] = {r = 0, g = 0.6, b = 0},
    ["none"] = {r = 0.8, g = 0, b = 0},
}

F:IterateAllUnitButtons(function(b)
    local dispels = b.indicators.dispels

    function dispels:SetDispels(dispelTypes)
        local r, g, b, a = 0, 0, 0, 0

        local i = 1
        for dispelType, _ in pairs(dispelTypes) do
            if a == 0 and dispelType then
                r, g, b, a = debuffTypeColor[dispelType].r, debuffTypeColor[dispelType].g, debuffTypeColor[dispelType].b, 1
            end
            if dispels.showIcons then
                dispels[i]:SetDispel(dispelType)
                i = i + 1
            end
        end

        -- hide unused
        for j = i, 4 do
            dispels[j]:Hide()
        end

        -- highlight
        if dispels.highlightType == "entire" then
            dispels.highlight:SetVertexColor(r, g, b, a ~= 0 and 0.5 or 0)
        elseif dispels.highlightType == "current" then
            dispels.highlight:SetVertexColor(r, g, b, a)
        else
            if Cell.isRetail then
                dispels.highlight:SetGradient("VERTICAL", CreateColor(r, g, b, a), CreateColor(r, g, b, 0))
            else
                dispels.highlight:SetGradientAlpha("VERTICAL", r, g, b, a, r, g, b, 0)
            end
        end
    end

    -- 修改护盾材质
    -- b.widget.shieldBar:SetTexture(Cell.vars.texture)
end)