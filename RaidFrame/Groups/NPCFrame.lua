local _, Cell = ...
local F = Cell.funcs

local npcFrame = CreateFrame("Frame", "CellNPCFrame", Cell.frames.mainFrame, "SecureHandlerStateTemplate")
Cell.frames.npcFrame = npcFrame
-- Cell:StylizeFrame(npcFrame, {1, .5, .5})

local anchors = {
	["solo"] = CellSoloFramePlayer,
	["party"] = CellPartyFramePet,
	["raid"] = CellNPCFrameAnchor,
}

for k, v in pairs(anchors) do
    npcFrame:SetFrameRef(k, v)
end

for i = 1, 5 do
	local button = CreateFrame("Button", npcFrame:GetName().."Button"..i, npcFrame, "CellUnitButtonTemplate")
	tinsert(Cell.unitButtons.npc, button)
    
	button:SetAttribute("unit", "boss"..i)
    RegisterAttributeDriver(button, "state-visibility", "[@boss"..i..", help] show; hide")
    
    -- for testing ------------------------------
    -- button:SetAttribute("unit", "player")
    -- RegisterUnitWatch(button)
    ---------------------------------------------

	if i == 1 then
		button:SetPoint("TOPLEFT")
	end
end

-- update point when group type changed
npcFrame:SetAttribute("_onstate-groupstate", [[
    self:SetAttribute("group", newstate)

    -- print("groupstate", newstate)

    local spacing = self:GetAttribute("spacing") or 0
    local orientation = self:GetAttribute("orientation") or "vertical"
    local anchor = self:GetFrameRef(newstate)
    local petstate = self:GetAttribute("pet")

    self:ClearAllPoints()

    if newstate == "raid" then
        self:SetPoint("TOPLEFT", anchor)

    elseif newstate == "party" then
        -- NOTE: at first time petstate == nil 
        if orientation == "vertical" then
            if petstate == "nopet" then
                self:SetPoint("TOPLEFT", self:GetFrameRef("solo"), "TOPRIGHT", spacing, 0)
            else
                self:SetPoint("TOPLEFT", self:GetFrameRef("party"), "TOPRIGHT", spacing, 0)
            end
        else
            if petstate == "nopet" then
                self:SetPoint("TOPLEFT", self:GetFrameRef("solo"), "BOTTOMLEFT", 0, -spacing)
            else
                self:SetPoint("TOPLEFT", self:GetFrameRef("party"), "BOTTOMLEFT", 0, -spacing)
            end
        end

    else -- solo
        if orientation == "vertical" then
            self:SetPoint("TOPLEFT", anchor, "TOPRIGHT", spacing, 0)
        else
            self:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -spacing)
        end
    end
]])
RegisterStateDriver(npcFrame, "groupstate", "[group:raid] raid; [group:party] party; solo")

-- update point when pet state changed
npcFrame:SetAttribute("_onstate-petstate", [[
    self:SetAttribute("pet", newstate)
    
    -- print("petstate", newstate)

    if self:GetAttribute("group") == "party" then
        -- self:CallMethod("UpdatePoint")

        local spacing = self:GetAttribute("spacing") or 0
        local orientation = self:GetAttribute("orientation") or "vertical"

        self:ClearAllPoints()

        if orientation == "vertical" then
            if newstate == "nopet" then
                self:SetPoint("TOPLEFT", self:GetFrameRef("solo"), "TOPRIGHT", spacing, 0)
            else
                self:SetPoint("TOPLEFT", self:GetFrameRef("party"), "TOPRIGHT", spacing, 0)
            end
        else
            if newstate == "nopet" then
                self:SetPoint("TOPLEFT", self:GetFrameRef("solo"), "BOTTOMLEFT", 0, -spacing)
            else
                self:SetPoint("TOPLEFT", self:GetFrameRef("party"), "BOTTOMLEFT", 0, -spacing)
            end
        end
    end
]])
RegisterStateDriver(npcFrame, "petstate", "[@pet,exists] pet; [@partypet1,exists] pet1; [@partypet2,exists] pet2; [@partypet3,exists] pet3; [@partypet4,exists] pet4; nopet")

local function NPCFrame_UpdateLayout(layout, which)
	if layout ~= Cell.vars.currentLayout then return end
	layout = Cell.vars.currentLayoutTable

    if not which or which == "size" then
        npcFrame:SetSize(unpack(layout["size"]))
        for _, b in pairs(Cell.unitButtons.npc) do
            b:SetSize(unpack(layout["size"]))
        end
    end

    if not which or which == "spacing" then
        npcFrame:SetAttribute("spacing", layout["spacing"])
        npcFrame:SetAttribute("orientation", layout["orientation"])
        
        local groupType = F:GetGroupType()
        npcFrame:ClearAllPoints()
        if groupType == "raid" then
            npcFrame:SetPoint("TOPLEFT", anchors["raid"])
    
        elseif groupType == "party" then
            if layout["orientation"] == "vertical" then
                if npcFrame:GetAttribute("pet") == "nopet" then
                    npcFrame:SetPoint("TOPLEFT", anchors["solo"], "TOPRIGHT", layout["spacing"], 0)
                else
                    npcFrame:SetPoint("TOPLEFT", anchors["party"], "TOPRIGHT", layout["spacing"], 0)
                end
            else
                if npcFrame:GetAttribute("pet") == "nopet" then
                    npcFrame:SetPoint("TOPLEFT", anchors["solo"], "BOTTOMLEFT", 0, -layout["spacing"])
                else
                    npcFrame:SetPoint("TOPLEFT", anchors["party"], "BOTTOMLEFT", 0, -layout["spacing"])
                end
            end
    
        else -- solo
            if layout["orientation"] == "vertical" then
                npcFrame:SetPoint("TOPLEFT", anchors["solo"], "TOPRIGHT", layout["spacing"], 0)
            else
                npcFrame:SetPoint("TOPLEFT", anchors["solo"], "BOTTOMLEFT", 0, -layout["spacing"])
            end
        end

        for i = 2, 5 do
            Cell.unitButtons.npc[i]:ClearAllPoints()
            if layout["orientation"] == "vertical" then
                Cell.unitButtons.npc[i]:SetPoint("TOPLEFT", Cell.unitButtons.npc[i-1], "BOTTOMLEFT", 0, -layout["spacing"])
            else
                Cell.unitButtons.npc[i]:SetPoint("TOPLEFT", Cell.unitButtons.npc[i-1], "TOPRIGHT", layout["spacing"], 0)
            end
        end
    end

    if which == "textWidth" then -- textWidth already initialized in UnitButton.lua
        for _, b in pairs(Cell.unitButtons.npc) do
            b:GetScript("OnSizeChanged")(b)
        end
    end
end
Cell:RegisterCallback("UpdateLayout", "NPCFrame_UpdateLayout", NPCFrame_UpdateLayout)

local function NPCFrame_UpdateVisibility(which)
    if not which or which == "solo" or which == "party" then
        local showSolo = CellDB["general"]["showSolo"] and "show" or "hide"
        local showParty = CellDB["general"]["showParty"] and "show" or "hide"
        RegisterAttributeDriver(npcFrame, "state-visibility", "[group:raid] show; [group:party] "..showParty.."; "..showSolo)
    end

    if not which or which == "pets" then
        if CellDB["general"]["showPets"] then
            npcFrame:SetFrameRef("party", CellPartyFramePet)
            anchors["party"] = CellPartyFramePet
        else
            npcFrame:SetFrameRef("party", CellPartyFramePlayer)
            anchors["party"] = CellPartyFramePlayer
        end
        -- update now if current in a party
        if Cell.vars.groupType == "party" then
            NPCFrame_UpdateLayout(Cell.vars.currentLayout, "spacing")
        end
    end
end
Cell:RegisterCallback("UpdateVisibility", "NPCFrame_UpdateVisibility", NPCFrame_UpdateVisibility)