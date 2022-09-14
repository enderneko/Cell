-- show dispel highlight with solid color (current health)
-- 使用纯色材质（而非血条材质）
local USE_SOLID_COLOR_TEXTURE = false

local F = Cell.funcs

-- custom dispel type color
-- 自定义颜色
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
                r, g, b, a = debuffTypeColor[dispelType].r, debuffTypeColor[dispelType].g, debuffTypeColor[dispelType].b, 1
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