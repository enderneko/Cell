local P = Cell.pixelPerfectFuncs

local class = select(2, UnitClass("player"))
local classColor = {.7, .7, .7, 1}
if class then
	classColor[1], classColor[2], classColor[3] = GetClassColor(class)
end

-----------------------------------------
-- Tooltip
-----------------------------------------
local function CreateTooltip(name)
	local tooltip = CreateFrame("GameTooltip", name, nil, "CellTooltipTemplate,BackdropTemplate")
	tooltip:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
	tooltip:SetBackdropColor(.1, .1, .1, .9)
	tooltip:SetBackdropBorderColor(unpack(classColor))
	tooltip:SetOwner(UIParent, "ANCHOR_NONE")
	tooltip:SetScript("OnTooltipCleared", function()
		-- reset border color
		tooltip:SetBackdropBorderColor(unpack(classColor))
	end)

	tooltip:SetScript("OnTooltipSetItem", function()
		-- color border with item quality color
		tooltip:SetBackdropBorderColor(_G[name.."TextLeft1"]:GetTextColor())
	end)

	tooltip:SetScript("OnHide", function()
		-- SetX with invalid data may or may not clear the tooltip's contents.
		tooltip:ClearLines()
	end)

	function tooltip:UpdatePixelPerfect()
		tooltip:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = P:Scale(1)})
		tooltip:SetBackdropColor(.1, .1, .1, .9)
		tooltip:SetBackdropBorderColor(unpack(classColor))
	end
end


CreateTooltip("CellTooltip")
CreateTooltip("CellScanningTooltip")