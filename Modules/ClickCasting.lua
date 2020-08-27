local _, Cell = ...
local F = Cell.funcs

local b = Cell.unitButtons.party.player
b:SetAttribute("type2", "togglemenu")
b:SetAttribute("type1", "target")
-- b:SetAttribute("target", b.state.unit)
b:SetAttribute("type3", "spell")
b:SetAttribute("spell", "真言术：盾")

local b2 = Cell.unitButtons.party.party1
b2:SetAttribute("type2", "togglemenu")
b2:SetAttribute("type1", "target")
b2:SetAttribute("type3", "spell")
b2:SetAttribute("spell", "真言术：盾")
