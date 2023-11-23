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
    local unit = b.state.unit
    if not unit then return end
    
    if UnitIsPVP(unit) then
        b.widget.pvpStatusIcon:SetAtlas("worldquest-icon-pvp-ffa")
        b.widget.pvpStatusIcon:Show()
    else
        b.widget.pvpStatusIcon:Hide()
    end
end

Cell.funcs:IterateAllUnitButtons(function(b)
    local pvpStatusIcon = b.widget.overlayFrame:CreateTexture(b:GetName().."PvPStatusIcon", "ARTWORK", nil, -7)
    b.widget.pvpStatusIcon = pvpStatusIcon
    pvpStatusIcon:SetPoint(point, b.widget.overlayFrame, relativePoint, x, y)
    pvpStatusIcon:SetSize(size, size)
    pvpStatusIcon:Hide()

    b:HookScript("OnEvent", function(self, event)
        if event == "UNIT_FACTION" then
            UpdatePvPStatusIcon(self, event)
        end
    end)

    if b:IsShown() then UpdatePvPStatusIcon(b) end
end)