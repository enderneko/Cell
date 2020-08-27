local _, Cell = ...
local F = Cell.funcs

local partyFrame = CreateFrame("Frame", "CellPartyFrame", Cell.frames.mainFrame, "SecureFrameTemplate")
Cell.frames.partyFrame = partyFrame
partyFrame:SetAllPoints(Cell.frames.mainFrame)
RegisterAttributeDriver(partyFrame, "state-visibility", "[group:raid] hide; [group:party] show; hide")

local playerButtonUnits, petButtonUnits = {}, {}
for i = 0, 4 do
	local playerName = (i == 0 and "Player" or "Party"..i)
	local petName = (i == 0 and "Pet" or "PartyPet"..i)

	local playerUnit, petUnit = strlower(playerName), strlower(petName)

	local playerButton = CreateFrame("Button", partyFrame:GetName()..playerName, partyFrame, "CellUnitButtonTemplate")
	playerButton:SetAttribute("unit", playerUnit)

	local petButton = CreateFrame("Button", partyFrame:GetName()..petUnit, partyFrame, "CellUnitButtonTemplate")
    petButton:SetAttribute("unit", petUnit)

	Cell.unitButtons.party[playerUnit] = playerButton
	Cell.unitButtons.party[petUnit] = petButton
    
	tinsert(playerButtonUnits, playerUnit)
	tinsert(petButtonUnits, petUnit)

	if i == 0 then
		playerButton:SetPoint("TOPLEFT")
		playerButton:Show()
		RegisterAttributeDriver(petButton, "state-visibility", "[nopet] hide; [vehicleui] hide; show")
	else
		RegisterUnitWatch(playerButton)
		RegisterAttributeDriver(petButton, "state-visibility", "[@"..petUnit..",noexists] hide; [@"..playerUnit..",unithasvehicleui] hide; show")
	end
end

function F:GetPartyFrameMatrix()
    return 1, 1
end

local function PartyFrame_UpdateLayout(layout, which)
	if layout ~= Cell.vars.currentLayout then return end
	layout = Cell.vars.currentLayoutTable

	local buttons = Cell.unitButtons.party

	for i, playerUnit in pairs(playerButtonUnits) do
		if not which or which == "size" then
			buttons[playerUnit]:SetSize(unpack(layout["size"]))
		end

		if not which or which == "spacing" then
			if i > 1 then
				buttons[playerUnit]:ClearAllPoints()
				buttons[playerUnit]:SetPoint("TOP", buttons[playerButtonUnits[i - 1]], "BOTTOM", 0, -layout["spacing"])
			end
		end
    end
	
	for i, petUnit in pairs(petButtonUnits) do
		if not which or which == "size" then
			buttons[petUnit]:SetSize(unpack(layout["size"]))
		end

		if not which or which == "spacing" then
			buttons[petUnit]:ClearAllPoints()
			buttons[petUnit]:SetPoint("LEFT", buttons[playerButtonUnits[i]], "RIGHT", layout["spacing"], 0)
		end
    end
end
Cell:RegisterEvent("UpdateLayout", "PartyFrame_UpdateLayout", PartyFrame_UpdateLayout)