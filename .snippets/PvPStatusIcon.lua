-------------------------------------------------
-- config
-------------------------------------------------
-- relative to unit button
local point, relativePoint, x, y = "CENTER", "BOTTOMRIGHT", -2, 3
local size = 11

-------------------------------------------------
-- function codes
-------------------------------------------------
local function UpdatePvPStatusIcon(b, event)
    local unit = b.states.unit
    if not unit then return end
    
    if UnitIsPVP(unit) then
        b.widgets.pvpStatusIcon:SetAtlas("worldquest-icon-pvp-ffa")
        b.widgets.pvpStatusIcon:Show()
    else
        b.widgets.pvpStatusIcon:Hide()
    end
end

Cell.funcs:IterateAllUnitButtons(function(b)
    local pvpStatusIcon = b.widgets.overlayFrame:CreateTexture(b:GetName().."PvPStatusIcon", "ARTWORK", nil, -7)
    b.widgets.pvpStatusIcon = pvpStatusIcon
    pvpStatusIcon:SetPoint(point, b.widgets.overlayFrame, relativePoint, x, y)
    pvpStatusIcon:SetSize(size, size)
    pvpStatusIcon:Hide()

    b:HookScript("OnEvent", function(self, event)
        if event == "UNIT_FACTION" then
            UpdatePvPStatusIcon(self, event)
        end
    end)

    if b:IsShown() then UpdatePvPStatusIcon(b) end
end)