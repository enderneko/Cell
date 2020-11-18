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
	]]

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
		for _, layout in pairs(CellDB["layouts"]) do
			-- add powerHeight
			if type(layout["powerHeight"]) ~= "number" then
				layout["powerHeight"] = 2
			end
			-- add dispel highlight
			if layout["indicators"][6] and layout["indicators"][6]["indicatorName"] == "dispels" then
				if type(layout["indicators"][6]["enableHighlight"]) ~= "boolean" then
					layout["indicators"][6]["enableHighlight"] = true
				end
			end
		end
		-- change showPets to showPartyPets
		if type(CellDB["general"]["showPartyPets"]) ~= "boolean" then
			CellDB["general"]["showPartyPets"] = CellDB["general"]["showPets"]
			CellDB["general"]["showPets"] = nil
		end
	end

	-- r22-release
	if not(CellDB["revise"]) or dbRevision < 22 then
		-- highlight color
		if not CellDB["appearance"]["targetColor"] then CellDB["appearance"]["targetColor"] = {1, .19, .19, .5} end
		if not CellDB["appearance"]["mouseoverColor"] then CellDB["appearance"]["mouseoverColor"] = {1, 1, 1, .5} end
		for _, layout in pairs(CellDB["layouts"]) do
			-- columns/rows
			if type(layout["columns"]) ~= "number" then layout["columns"] = 8 end
			if type(layout["rows"]) ~= "number" then layout["rows"] = 8 end
			if type(layout["groupSpacing"]) ~= "number" then layout["groupSpacing"] = 0 end
			-- targetMarker
			-- if layout["indicators"][1] and layout["indicators"][1]["indicatorName"] ~= "targetMarker" then
			-- 	tinsert(layout["indicators"], 1, {
			-- 		["name"] = "Target Marker",
			-- 		["indicatorName"] = "targetMarker",
			-- 		["type"] = "built-in",
			-- 		["enabled"] = true,
			-- 		["position"] = {"TOP", "TOP", 0, 3},
			-- 		["size"] = {14, 14},
			-- 		["alpha"] = .77,
			-- 	})
			-- end
		end
	end

	-- r23-release
	if not(CellDB["revise"]) or dbRevision < 23 then
		for _, layout in pairs(CellDB["layouts"]) do
			-- rename targetMarker to playerRaidIcon
			if layout["indicators"][1] then
				if layout["indicators"][1]["indicatorName"] == "targetMarker" then -- r22
					layout["indicators"][1]["name"] = "Raid Icon (player)"
					layout["indicators"][1]["indicatorName"] = "playerRaidIcon"
				elseif layout["indicators"][1]["indicatorName"] == "aggroBar" then
					tinsert(layout["indicators"], 1, {
						["name"] = "Raid Icon (player)",
						["indicatorName"] = "playerRaidIcon",
						["type"] = "built-in",
						["enabled"] = true,
						["position"] = {"TOP", "TOP", 0, 3},
						["size"] = {14, 14},
						["alpha"] = .77,
					})
				end
			end
			if layout["indicators"][2] and layout["indicators"][2]["indicatorName"] ~= "targetRaidIcon" then
				tinsert(layout["indicators"], 2, {
					["name"] = "Raid Icon (target)",
					["indicatorName"] = "targetRaidIcon",
					["type"] = "built-in",
					["enabled"] = false,
					["position"] = {"TOP", "TOP", -14, 3},
					["size"] = {14, 14},
					["alpha"] = .77,
				})
			end
		end
	end

	-- r25-release
	if not(CellDB["revise"]) or dbRevision < 25 then
		-- position for layouts
		local eventFrame = CreateFrame("Frame")
		eventFrame:RegisterEvent("VARIABLES_LOADED")
		eventFrame:SetScript("OnEvent", function()
			local point, relativeTo, relativePoint, xOfs, yOfs = CellAnchorFrame:GetPoint(1)
			for _, layout in pairs(CellDB["layouts"]) do
				if type(layout["position"]) ~= "table" then
					layout["position"] = {point, relativePoint, xOfs, yOfs}
				end
			end
		end)
	end

	CellDB["revise"] = Cell.version
end
Cell:RegisterCallback("Revise", "Revise", Revise)