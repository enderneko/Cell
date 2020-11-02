local addonName, Cell = ...
local L = Cell.L
local F = Cell.funcs

local function Revise()
	local dbRevision = CellDB["revise"] and tonumber(string.match(CellDB["revise"], "%d+")) or 0
	F:Debug("DBRevision:", dbRevision)

	--[[
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
	]]

	-- r13-release: fix all
	if not(CellDB["revise"]) or dbRevision < 13 then
		-- r8-beta: add "centralDebuff"
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

		-- r9-beta: fix raidtool db
		if type(CellDB["raidTools"]["showBattleRes"]) ~= "boolean" then CellDB["raidTools"]["showBattleRes"] = true end
		if not CellDB["raidTools"]["buttonsPosition"] then CellDB["raidTools"]["buttonsPosition"] = {"TOPRIGHT", "CENTER", 0, 0} end
		if not CellDB["raidTools"]["marksPosition"] then CellDB["raidTools"]["marksPosition"] = {"BOTTOMRIGHT", "CENTER", 0, 0} end

		-- r11-release: add horizontal layout
		for _, layout in pairs(CellDB["layouts"]) do
			if type(layout["orientation"]) ~= "string" then
				layout["orientation"] = "vertical"
			end
		end

		-- r13 release: CellDB["appearance"]
		if CellDB["texture"] then CellDB["appearance"]["texture"] = CellDB["texture"] end
		if CellDB["scale"] then CellDB["appearance"]["scale"] = CellDB["scale"] end
		if CellDB["font"] then CellDB["appearance"]["font"] = CellDB["font"] end
		if CellDB["outline"] then CellDB["appearance"]["outline"] = CellDB["outline"] end
		CellDB["texture"] = nil
		CellDB["scale"] = nil
		CellDB["font"] = nil
		CellDB["outline"] = nil
	end

	-- r14-release: CellDB["general"]
	if not(CellDB["revise"]) or dbRevision < 14 then
		if CellDB["hideBlizzard"] then CellDB["general"]["hideBlizzard"] = CellDB["hideBlizzard"] end
		if CellDB["disableTooltips"] then CellDB["general"]["disableTooltips"] = CellDB["disableTooltips"] end
		if CellDB["showSolo"] then CellDB["general"]["showSolo"] = CellDB["showSolo"] end
		CellDB["hideBlizzard"] = nil
		CellDB["disableTooltips"] = nil
		CellDB["showSolo"] = nil
	end
	
	-- r15-release
	if not(CellDB["revise"]) or dbRevision < 15 then
		-- add powerHeight
		for _, layout in pairs(CellDB["layouts"]) do
			if type(layout["powerHeight"]) ~= "number" then
				layout["powerHeight"] = 2
			end
		end
	end

	CellDB["revise"] = Cell.version
end
Cell:RegisterCallback("Revise", "Revise", Revise)