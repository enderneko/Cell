Cell.funcs.IterateAllUnitButtons(function(b)
    b:HookScript("OnAttributeChanged", function(self, name, value)
        if name == "unit" and type(value) == "string" then
            if not b.indicators.nameText.highlight then
                b.indicators.nameText.highlight = b.indicators.nameText:CreateTexture(nil, "BACKGROUND")
                b.indicators.nameText.highlight:SetColorTexture(1, 0, 0, 0.5)
                b.indicators.nameText.highlight:SetAllPoints(b.indicators.nameText)
                b.indicators.nameText.highlight:Hide()
            end

            if UnitIsUnit(value, "player") then
                b.indicators.nameText.highlight:Show()
            else
                b.indicators.nameText.highlight:Hide()
            end
        end
    end)
end)