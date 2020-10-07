local addonName, Cell = ...
local L = Cell.L
local F = Cell.funcs

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, arg1, ...)
	if arg1 == addonName then
		-- r4-alpha add "castByMe"
		if not(CellDB["revise"]) or CellDB["revise"] < "r4-alpha" then
			for _, layout in pairs(CellDB["layouts"]) do
				for _, indicator in pairs(layout["indicators"]) do
					if indicator["auraType"] == "buff" then
						if indicator["castByMe"] == nil then
							indicator["castByMe"] = true
						end
					elseif indicator["indicatorName"] == "dispels" then
						if indicator["checkbutton"] then
							indicator["dispellableByMe"] = indicator["checkbutton"][2]
							indicator["checkbutton"] = nil
						end
					end
				end
			end
		end

		-- r6-alpha add "textWidth"
		if not(CellDB["revise"]) or CellDB["revise"] < "r6-alpha" then
			for _, layout in pairs(CellDB["layouts"]) do
				if not layout["textWidth"] then
					layout["textWidth"] = .75
				end
			end
		end
		CellDB["revise"] = Cell.version
    end
end)