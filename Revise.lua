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

		-- r6-alpha
		if not(CellDB["revise"]) or CellDB["revise"] < "r6-alpha" then
			-- add "textWidth"
			for _, layout in pairs(CellDB["layouts"]) do
				if not layout["textWidth"] then
					layout["textWidth"] = .75
				end
			end
			-- remove old raid tools related
			if CellDB["showRaidSetup"] then CellDB["showRaidSetup"] = nil end
			if CellDB["pullTimer"] then CellDB["pullTimer"] = nil end
		end
		
		-- r8-beta
		if not(CellDB["revise"]) or CellDB["revise"] < "r8-beta" then
			-- add "centralDebuff"
			for _, layout in pairs(CellDB["layouts"]) do
				if not layout["indicators"][8] or layout["indicators"][8]["indicatorName"] ~= "centralDebuff" then
					tinsert(layout["indicators"], 8, {
						["name"] = "Central Debuff",
						["indicatorName"] = "centralDebuff",
						["type"] = "built-in",
						["enabled"] = true,
						["position"] = {"CENTER", "CENTER", 0, 3},
						["size"] = {20, 20},
						["font"] = {"Cell ".._G.DEFAULT, 11, "Outline", 2},
					})
				end
			end
		end

		-- r9-beta: fix raidtool db
		if not(CellDB["revise"]) or CellDB["revise"] < "r9-beta" then
			if type(CellDB["raidTools"]["showBattleRes"]) ~= "boolean" then CellDB["raidTools"]["showBattleRes"] = true end
			if not CellDB["raidTools"]["buttonsPosition"] then CellDB["raidTools"]["buttonsPosition"] = {"TOPRIGHT", "CENTER", 0, 0} end
			if not CellDB["raidTools"]["marksPosition"] then CellDB["raidTools"]["marksPosition"] = {"BOTTOMRIGHT", "CENTER", 0, 0} end
		end

		CellDB["revise"] = Cell.version
    end
end)