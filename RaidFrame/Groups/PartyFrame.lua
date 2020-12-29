local _, Cell = ...
local F = Cell.funcs

local partyFrame = CreateFrame("Frame", "CellPartyFrame", Cell.frames.mainFrame, "SecureFrameTemplate")
Cell.frames.partyFrame = partyFrame
partyFrame:SetAllPoints(Cell.frames.mainFrame)
-- RegisterAttributeDriver(partyFrame, "state-visibility", "[group:raid] hide; [group:party] show; hide")

local petFrame = CreateFrame("Frame", "CellPartyFramePetFrame", partyFrame, "SecureFrameTemplate")
partyFrame.petFrame = petFrame

local playerButtonUnits, petButtonUnits = {}, {}
for i = 0, 4 do
	local playerName = (i == 0 and "Player" or "Party"..i)
	local petName = (i == 0 and "Pet" or "PartyPet"..i)

	local playerUnit, petUnit = strlower(playerName), strlower(petName)

	local playerButton = CreateFrame("Button", partyFrame:GetName()..playerName, partyFrame, "CellUnitButtonTemplate")
	playerButton:SetAttribute("unit", playerUnit)

	local petButton = CreateFrame("Button", partyFrame:GetName()..petName, petFrame, "CellUnitButtonTemplate")
    petButton:SetAttribute("unit", petUnit)

	Cell.unitButtons.party[playerUnit] = playerButton
	Cell.unitButtons.party[petUnit] = petButton
    
	tinsert(playerButtonUnits, playerUnit)
	tinsert(petButtonUnits, petUnit)

	if i == 0 then
		playerButton:Show()
		RegisterAttributeDriver(petButton, "state-visibility", "[nopet] hide; [vehicleui] hide; show")
	else
		RegisterUnitWatch(playerButton)
		RegisterAttributeDriver(petButton, "state-visibility", "[@"..petUnit..",noexists] hide; [@"..playerUnit..",unithasvehicleui] hide; show")
	end

	-- OmniCD
	_G["CellPartyFrameMember"..(i+1)] = playerButton
	playerButton.unitid = playerUnit
end

local init
local function PartyFrame_UpdateLayout(layout, which)
	-- if layout ~= Cell.vars.currentLayout then return end
	if Cell.vars.groupType ~= "party" and init then return end
    init = true
    layout = CellDB["layouts"][CellCharacterDB["party"]]

	local buttons = Cell.unitButtons.party

	-- anchor
	local point, playerAnchorPoint, petAnchorPoint, playerSpacing, petSpacing
	if not which or which == "spacing" or which == "orientation" or which == "anchor" then
		if layout["orientation"] == "vertical" then
			if layout["anchor"] == "BOTTOMLEFT" then
				point, playerAnchorPoint, petAnchorPoint = "BOTTOMLEFT", "TOPLEFT", "BOTTOMRIGHT"
				playerSpacing = layout["spacing"]
				petSpacing = layout["spacing"]
			elseif layout["anchor"] == "BOTTOMRIGHT" then
				point, playerAnchorPoint, petAnchorPoint = "BOTTOMRIGHT", "TOPRIGHT", "BOTTOMLEFT"
				playerSpacing = layout["spacing"]
				petSpacing = -layout["spacing"]
			elseif layout["anchor"] == "TOPLEFT" then
				point, playerAnchorPoint, petAnchorPoint = "TOPLEFT", "BOTTOMLEFT", "TOPRIGHT"
				playerSpacing = -layout["spacing"]
				petSpacing = layout["spacing"]
			elseif layout["anchor"] == "TOPRIGHT" then
				point, playerAnchorPoint, petAnchorPoint = "TOPRIGHT", "BOTTOMRIGHT", "TOPLEFT"
				playerSpacing = -layout["spacing"]
				petSpacing = -layout["spacing"]
			end
		else
			-- anchor
            if layout["anchor"] == "BOTTOMLEFT" then
                point, playerAnchorPoint, petAnchorPoint = "BOTTOMLEFT", "BOTTOMRIGHT", "TOPLEFT"
				playerSpacing = layout["spacing"]
				petSpacing = layout["spacing"]
            elseif layout["anchor"] == "BOTTOMRIGHT" then
                point, playerAnchorPoint, petAnchorPoint = "BOTTOMRIGHT", "BOTTOMLEFT", "TOPRIGHT"
                playerSpacing = -layout["spacing"]
				petSpacing = layout["spacing"]
            elseif layout["anchor"] == "TOPLEFT" then
                point, playerAnchorPoint, petAnchorPoint = "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT"
                playerSpacing = layout["spacing"]
				petSpacing = -layout["spacing"]
            elseif layout["anchor"] == "TOPRIGHT" then
                point, playerAnchorPoint, petAnchorPoint = "TOPRIGHT", "TOPLEFT", "BOTTOMRIGHT"
                playerSpacing = -layout["spacing"]
				petSpacing = -layout["spacing"]
            end
		end
	end

	for i, playerUnit in pairs(playerButtonUnits) do
		if not which or which == "size" then
			buttons[playerUnit]:SetSize(unpack(layout["size"]))
		end

		if not which or which == "power" then
			buttons[playerUnit].func.SetPowerHeight(layout["powerHeight"])
		end

		if not which or which == "spacing" or which == "orientation" or which == "anchor" then
			buttons[playerUnit]:ClearAllPoints()
			if i == 1 then
				buttons[playerUnit]:SetPoint(point)
			else
				if layout["orientation"] == "vertical" then
					buttons[playerUnit]:SetPoint(point, buttons[playerButtonUnits[i - 1]], playerAnchorPoint, 0, playerSpacing)
				else
					buttons[playerUnit]:SetPoint(point, buttons[playerButtonUnits[i - 1]], playerAnchorPoint, playerSpacing, 0)
				end
			end
		end

		if which == "textWidth" then -- textWidth already initialized in UnitButton.lua
			buttons[playerUnit]:GetScript("OnSizeChanged")(buttons[playerUnit])
		end
    end
	
	for i, petUnit in pairs(petButtonUnits) do
		if not which or which == "size" then
			buttons[petUnit]:SetSize(unpack(layout["size"]))
		end

		if not which or which == "power" then
			buttons[petUnit].func.SetPowerHeight(layout["powerHeight"])
		end

		if not which or which == "spacing" or which == "orientation" or which == "anchor" then
			buttons[petUnit]:ClearAllPoints()
			if layout["orientation"] == "vertical" then
				buttons[petUnit]:SetPoint(point, buttons[playerButtonUnits[i]], petAnchorPoint, petSpacing, 0)
			else
				buttons[petUnit]:SetPoint(point, buttons[playerButtonUnits[i]], petAnchorPoint, 0, petSpacing)
			end
		end

		if which == "textWidth" then -- textWidth already initialized in UnitButton.lua
			buttons[petUnit]:GetScript("OnSizeChanged")(buttons[petUnit])
		end
    end
end
Cell:RegisterCallback("UpdateLayout", "PartyFrame_UpdateLayout", PartyFrame_UpdateLayout)

local function PartyFrame_UpdateVisibility(which)
	if not which or which == "party" then
		if CellDB["general"]["showParty"] then
			RegisterAttributeDriver(partyFrame, "state-visibility", "[group:raid] hide; [group:party] show; hide")
		else
			UnregisterAttributeDriver(partyFrame, "state-visibility")
			partyFrame:Hide()
		end
	end

	if not which or which == "pets" then
		if CellDB["general"]["showPartyPets"] then
			petFrame:Show()
		else
			petFrame:Hide()
		end
    end
end
Cell:RegisterCallback("UpdateVisibility", "PartyFrame_UpdateVisibility", PartyFrame_UpdateVisibility)