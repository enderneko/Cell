local P = Cell.pixelPerfectFuncs
local B = Cell.bFuncs

hooksecurefunc(B, "SetOrientation", function(button, orientation)
    local healthBar = button.widgets.healthBar:GetStatusBarTexture()
    local shieldBarR = button.widgets.shieldBarR

    if orientation == "horizontal" then
        P.ClearPoints(shieldBarR)
        P.Point(shieldBarR, "TOPLEFT", healthBar)
        P.Point(shieldBarR, "BOTTOMLEFT", healthBar)
    else
        P.ClearPoints(shieldBarR)
        P.Point(shieldBarR, "BOTTOMLEFT", healthBar)
        P.Point(shieldBarR, "BOTTOMRIGHT", healthBar)
    end
end)