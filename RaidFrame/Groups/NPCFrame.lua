local _, Cell = ...
local F = Cell.funcs

local npcFrame = CreateFrame("Frame", "CellNPCFrame", Cell.frames.mainFrame, "SecureHandlerStateTemplate")
Cell.frames.npcFrame = npcFrame
-- Cell:StylizeFrame(npcFrame, {1, .5, .5})

local anchors = {
	["solo"] = CellSoloFramePlayer,
	["party"] = CellPartyFrameHeaderUnitButton1Pet,
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
    local layoutAnchor = self:GetAttribute("anchor") or "TOPLEFT"
    local petstate = self:GetAttribute("pet")

    self:ClearAllPoints()

    if orientation == "vertical" then
        local point, anchorPoint, unitSpacing
        if layoutAnchor == "BOTTOMLEFT" then
            point, anchorPoint = "BOTTOMLEFT", "BOTTOMRIGHT"
            unitSpacing = spacing
        elseif layoutAnchor == "BOTTOMRIGHT" then
            point, anchorPoint = "BOTTOMRIGHT", "BOTTOMLEFT"
            unitSpacing = -spacing
        elseif layoutAnchor == "TOPLEFT" then
            point, anchorPoint = "TOPLEFT", "TOPRIGHT"
            unitSpacing = spacing
        elseif layoutAnchor == "TOPRIGHT" then
            point, anchorPoint = "TOPRIGHT", "TOPLEFT"
            unitSpacing = -spacing
        end

        if newstate == "raid" then
            self:SetPoint(point, anchor)
    
        elseif newstate == "party" then
            -- NOTE: at first time petstate == nil 
            if petstate == "nopet" then
                self:SetPoint(point, self:GetFrameRef("solo"), anchorPoint, unitSpacing, 0)
            else
                self:SetPoint(point, self:GetFrameRef("party"), anchorPoint, unitSpacing, 0)
            end
    
        else -- solo
            self:SetPoint(point, anchor, anchorPoint, unitSpacing, 0)
        end
    else
        local point, anchorPoint, unitSpacing
        if layoutAnchor == "BOTTOMLEFT" then
            point, anchorPoint = "BOTTOMLEFT", "TOPLEFT"
            unitSpacing = spacing
        elseif layoutAnchor == "BOTTOMRIGHT" then
            point, anchorPoint = "BOTTOMRIGHT", "TOPRIGHT"
            unitSpacing = spacing
        elseif layoutAnchor == "TOPLEFT" then
            point, anchorPoint = "TOPLEFT", "BOTTOMLEFT"
            unitSpacing = -spacing
        elseif layoutAnchor == "TOPRIGHT" then
            point, anchorPoint = "TOPRIGHT", "BOTTOMRIGHT"
            unitSpacing = -spacing
        end
        
        if newstate == "raid" then
            self:SetPoint(point, anchor)
    
        elseif newstate == "party" then
            -- NOTE: at first time petstate == nil 
            if petstate == "nopet" then
                self:SetPoint(point, self:GetFrameRef("solo"), anchorPoint, 0, unitSpacing)
            else
                self:SetPoint(point, self:GetFrameRef("party"), anchorPoint, 0, unitSpacing)
            end
    
        else -- solo
            self:SetPoint(point, anchor, anchorPoint, 0, unitSpacing)
        end
    end
]])
RegisterStateDriver(npcFrame, "groupstate", "[group:raid] raid; [group:party] party; solo")

-- update point when pet state changed
npcFrame:SetAttribute("_onstate-petstate", [[
    self:SetAttribute("pet", newstate)
    
    -- print("petstate", newstate)

    if self:GetAttribute("group") == "party" then
        local spacing = self:GetAttribute("spacing") or 0
        local orientation = self:GetAttribute("orientation") or "vertical"
        local layoutAnchor = self:GetAttribute("anchor") or "TOPLEFT"

        self:ClearAllPoints()

        if orientation == "vertical" then
            local point, anchorPoint, unitSpacing
            if layoutAnchor == "BOTTOMLEFT" then
                point, anchorPoint = "BOTTOMLEFT", "BOTTOMRIGHT"
                unitSpacing = spacing
            elseif layoutAnchor == "BOTTOMRIGHT" then
                point, anchorPoint = "BOTTOMRIGHT", "BOTTOMLEFT"
                unitSpacing = -spacing
            elseif layoutAnchor == "TOPLEFT" then
                point, anchorPoint = "TOPLEFT", "TOPRIGHT"
                unitSpacing = spacing
            elseif layoutAnchor == "TOPRIGHT" then
                point, anchorPoint = "TOPRIGHT", "TOPLEFT"
                unitSpacing = -spacing
            end

            if newstate == "nopet" then
                self:SetPoint(point, self:GetFrameRef("solo"), anchorPoint, unitSpacing, 0)
            else
                self:SetPoint(point, self:GetFrameRef("party"), anchorPoint, unitSpacing, 0)
            end
        else
            local point, anchorPoint, unitSpacing
            if layoutAnchor == "BOTTOMLEFT" then
                point, anchorPoint = "BOTTOMLEFT", "TOPLEFT"
                unitSpacing = spacing
            elseif layoutAnchor == "BOTTOMRIGHT" then
                point, anchorPoint = "BOTTOMRIGHT", "TOPRIGHT"
                unitSpacing = spacing
            elseif layoutAnchor == "TOPLEFT" then
                point, anchorPoint = "TOPLEFT", "BOTTOMLEFT"
                unitSpacing = -spacing
            elseif layoutAnchor == "TOPRIGHT" then
                point, anchorPoint = "TOPRIGHT", "BOTTOMRIGHT"
                unitSpacing = -spacing
            end

            if newstate == "nopet" then
                self:SetPoint(point, self:GetFrameRef("solo"), anchorPoint, 0, unitSpacing)
            else
                self:SetPoint(point, self:GetFrameRef("party"), anchorPoint, 0, unitSpacing)
            end
        end
    end
]])
RegisterStateDriver(npcFrame, "petstate", "[@pet,exists] pet; [@partypet1,exists] pet1; [@partypet2,exists] pet2; [@partypet3,exists] pet3; [@partypet4,exists] pet4; nopet")

local function NPCFrame_UpdateLayout(layout, which)
	-- if layout ~= Cell.vars.currentLayout then return end
	layout = Cell.vars.currentLayoutTable

    if not which or which == "size" or which == "power" then
        npcFrame:SetSize(unpack(layout["size"]))
        for _, b in pairs(Cell.unitButtons.npc) do
            if not which or which == "size" then
                b:SetSize(unpack(layout["size"]))
            end
            if not which or which == "power" then
                b.func.SetPowerHeight(layout["powerHeight"])
            end
        end
    end

    if not which or which == "spacing" or which == "orientation" or which == "anchor" then
        npcFrame:SetAttribute("spacing", layout["spacing"])
        npcFrame:SetAttribute("orientation", layout["orientation"])
        npcFrame:SetAttribute("anchor", layout["anchor"])
        
        local groupType = F:GetGroupType()
        npcFrame:ClearAllPoints()

        if layout["orientation"] == "vertical" then
            -- anchor
            local point, anchorPoint, groupAnchorPoint, unitSpacing, groupSpacing
            if layout["anchor"] == "BOTTOMLEFT" then
                point, anchorPoint, groupAnchorPoint = "BOTTOMLEFT", "TOPLEFT", "BOTTOMRIGHT"
                unitSpacing = layout["spacing"]
                groupSpacing = layout["spacing"]
            elseif layout["anchor"] == "BOTTOMRIGHT" then
                point, anchorPoint, groupAnchorPoint = "BOTTOMRIGHT", "TOPRIGHT", "BOTTOMLEFT"
                unitSpacing = layout["spacing"]
                groupSpacing = -layout["spacing"]
            elseif layout["anchor"] == "TOPLEFT" then
                point, anchorPoint, groupAnchorPoint = "TOPLEFT", "BOTTOMLEFT", "TOPRIGHT"
                unitSpacing = -layout["spacing"]
                groupSpacing = layout["spacing"]
            elseif layout["anchor"] == "TOPRIGHT" then
                point, anchorPoint, groupAnchorPoint = "TOPRIGHT", "BOTTOMRIGHT", "TOPLEFT"
                unitSpacing = -layout["spacing"]
                groupSpacing = -layout["spacing"]
            end

            if groupType == "raid" then
                npcFrame:SetPoint(point, anchors["raid"])

            elseif groupType == "party" then
                if npcFrame:GetAttribute("pet") == "nopet" then
                    npcFrame:SetPoint(point, anchors["solo"], groupAnchorPoint, groupSpacing, 0)
                else
                    npcFrame:SetPoint(point, anchors["party"], groupAnchorPoint, groupSpacing, 0)
                end
        
            else -- solo
                npcFrame:SetPoint(point, anchors["solo"], groupAnchorPoint, groupSpacing, 0)
            end

            for i = 2, 5 do
                Cell.unitButtons.npc[i]:ClearAllPoints()
                Cell.unitButtons.npc[i]:SetPoint(point, Cell.unitButtons.npc[i-1], anchorPoint, 0, unitSpacing)
            end
        else
            -- anchor
            local point, anchorPoint, groupAnchorPoint, unitSpacing, groupSpacing
            if layout["anchor"] == "BOTTOMLEFT" then
                point, anchorPoint, groupAnchorPoint = "BOTTOMLEFT", "BOTTOMRIGHT", "TOPLEFT"
                unitSpacing = layout["spacing"]
                groupSpacing = layout["spacing"]
            elseif layout["anchor"] == "BOTTOMRIGHT" then
                point, anchorPoint, groupAnchorPoint = "BOTTOMRIGHT", "BOTTOMLEFT", "TOPRIGHT"
                unitSpacing = -layout["spacing"]
                groupSpacing = layout["spacing"]
            elseif layout["anchor"] == "TOPLEFT" then
                point, anchorPoint, groupAnchorPoint = "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT"
                unitSpacing = layout["spacing"]
                groupSpacing = -layout["spacing"]
            elseif layout["anchor"] == "TOPRIGHT" then
                point, anchorPoint, groupAnchorPoint = "TOPRIGHT", "TOPLEFT", "BOTTOMRIGHT"
                unitSpacing = -layout["spacing"]
                groupSpacing = -layout["spacing"]
            end

            if groupType == "raid" then
                npcFrame:SetPoint(point, anchors["raid"])

            elseif groupType == "party" then
                if npcFrame:GetAttribute("pet") == "nopet" then
                    npcFrame:SetPoint(point, anchors["solo"], groupAnchorPoint, 0, groupSpacing)
                else
                    npcFrame:SetPoint(point, anchors["party"], groupAnchorPoint, 0, groupSpacing)
                end
        
            else -- solo
                npcFrame:SetPoint(point, anchors["solo"], groupAnchorPoint, 0, groupSpacing)
            end

            for i = 2, 5 do
                Cell.unitButtons.npc[i]:ClearAllPoints()
                Cell.unitButtons.npc[i]:SetPoint(point, Cell.unitButtons.npc[i-1], anchorPoint, unitSpacing, 0)
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
        if CellDB["general"]["showPartyPets"] then
            npcFrame:SetFrameRef("party", CellPartyFrameHeaderUnitButton1Pet)
            anchors["party"] = CellPartyFrameHeaderUnitButton1Pet
        else
            npcFrame:SetFrameRef("party", CellPartyFrameHeaderUnitButton1)
            anchors["party"] = CellPartyFrameHeaderUnitButton1
        end
        -- update now if current in a party
        if Cell.vars.groupType == "party" then
            NPCFrame_UpdateLayout(Cell.vars.currentLayout, "spacing")
        end
    end
end
Cell:RegisterCallback("UpdateVisibility", "NPCFrame_UpdateVisibility", NPCFrame_UpdateVisibility)