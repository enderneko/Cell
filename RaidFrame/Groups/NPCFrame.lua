local _, Cell = ...
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

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

-- NOTE: update each npc unit button
local pointUpdater = [[
    local orientation, point, anchorPoint, unitSpacing = ...
    -- print(point, anchorPoint, unitSpacing)
    local last
    for i = 1, 8 do
        local button = self:GetFrameRef("button"..i)
        if button:IsVisible() then
            button:ClearAllPoints()
            if last then
                -- NOTE: anchor to last
                if orientation == "vertical" then
                    button:SetPoint(point, last, anchorPoint, 0, unitSpacing)
                else
                    button:SetPoint(point, last, anchorPoint, unitSpacing, 0)
                end
            else
                button:SetPoint("TOPLEFT", self)
            end
            last = button
        end
    end
]]
npcFrame:SetAttribute("pointUpdater", pointUpdater)

for i = 1, 8 do
    local button = CreateFrame("Button", npcFrame:GetName().."Button"..i, npcFrame, "CellUnitButtonTemplate")
    tinsert(Cell.unitButtons.npc, button)

    button:SetAttribute("unit", "boss"..i)
    RegisterAttributeDriver(button, "state-visibility", "[@boss"..i..", help] show; hide")
    
    -- for testing ------------------------------
    -- if i == 1 or i == 7 then
    --     button:SetAttribute("unit", "player")
    --     RegisterUnitWatch(button)
    -- elseif i == 3 then
    --     button:SetAttribute("unit", "target")
    --     RegisterUnitWatch(button)
    -- else
    --     button:SetAttribute("unit", "boss"..i)
    --     RegisterAttributeDriver(button, "state-visibility", "[@boss"..i..", help] show; hide")
    -- end
    ---------------------------------------------

    -- NOTE: save reference for re-point
    npcFrame:SetFrameRef("button"..i, button)

    -- NOTE: update each npc unitbutton's point on show/hide
    button.helper = CreateFrame("Frame", nil, button, "SecureHandlerShowHideTemplate")
	button.helper:SetFrameRef("npcFrame", npcFrame)
    button.helper:SetAttribute("pointUpdater", [[
        local orientation = self:GetAttribute("orientation")
        local point = self:GetAttribute("point")
        local anchorPoint = self:GetAttribute("anchorPoint")
        local unitSpacing = self:GetAttribute("unitSpacing")
        
        local npcFrame = self:GetFrameRef("npcFrame")
        self:RunFor(npcFrame, npcFrame:GetAttribute("pointUpdater"), orientation, point, anchorPoint, unitSpacing)
    ]])
	button.helper:SetAttribute("_onshow", [[ self:RunAttribute("pointUpdater") ]])
	button.helper:SetAttribute("_onhide", [[ self:RunAttribute("pointUpdater") ]])
end

-- update point when group type changed
npcFrame:SetAttribute("_onstate-groupstate", [[
    -- print("groupstate", newstate)
    self:SetAttribute("group", newstate)
    
    local petstate = self:GetAttribute("pet")
    local anchor = self:GetFrameRef(newstate)
    local orientation = self:GetAttribute("orientation")
    local point = self:GetAttribute("point")
    local anchorPoint = self:GetAttribute("anchorPoint")
    local groupAnchorPoint = self:GetAttribute("groupAnchorPoint")
    local unitSpacing = self:GetAttribute("unitSpacing")
    local groupSpacing = self:GetAttribute("groupSpacing")

    self:ClearAllPoints()

    if orientation == "vertical" then
        if newstate == "raid" then
            self:SetPoint(point, anchor)
    
        elseif newstate == "party" then
            -- NOTE: at first time petstate == nil 
            if petstate == "nopet" then
                self:SetPoint(point, self:GetFrameRef("solo"), groupAnchorPoint, groupSpacing, 0)
            else
                self:SetPoint(point, self:GetFrameRef("party"), groupAnchorPoint, groupSpacing, 0)
            end
    
        else -- solo
            self:SetPoint(point, anchor, groupAnchorPoint, groupSpacing, 0)
        end
    else
        if newstate == "raid" then
            self:SetPoint(point, anchor)
    
        elseif newstate == "party" then
            -- NOTE: at first time petstate == nil 
            if petstate == "nopet" then
                self:SetPoint(point, self:GetFrameRef("solo"), groupAnchorPoint, 0, groupSpacing)
            else
                self:SetPoint(point, self:GetFrameRef("party"), groupAnchorPoint, 0, groupSpacing)
            end
    
        else -- solo
            self:SetPoint(point, anchor, groupAnchorPoint, 0, groupSpacing)
        end
    end

    -- NOTE: update each npc button
    self:RunAttribute("pointUpdater", orientation, point, anchorPoint, unitSpacing)
]])
-- RegisterStateDriver(npcFrame, "groupstate", "[group:raid] raid; [group:party] party; solo")

-- update point when pet state changed
npcFrame:SetAttribute("_onstate-petstate", [[
    -- print("petstate", newstate)
    self:SetAttribute("pet", newstate)

    if self:GetAttribute("group") == "party" then
        local orientation = self:GetAttribute("orientation")
        local point = self:GetAttribute("point")
        local anchorPoint = self:GetAttribute("anchorPoint")
        local groupAnchorPoint = self:GetAttribute("groupAnchorPoint")
        local unitSpacing = self:GetAttribute("unitSpacing")
        local groupSpacing = self:GetAttribute("groupSpacing")

        self:ClearAllPoints()

        if orientation == "vertical" then
            if newstate == "nopet" then
                self:SetPoint(point, self:GetFrameRef("solo"), groupAnchorPoint, groupSpacing, 0)
            else
                self:SetPoint(point, self:GetFrameRef("party"), groupAnchorPoint, groupSpacing, 0)
            end
        else
            if newstate == "nopet" then
                self:SetPoint(point, self:GetFrameRef("solo"), groupAnchorPoint, 0, groupSpacing)
            else
                self:SetPoint(point, self:GetFrameRef("party"), groupAnchorPoint, 0, groupSpacing)
            end
        end
    end
]])
-- RegisterStateDriver(npcFrame, "petstate", "[@pet,exists] pet; [@partypet1,exists] pet1; [@partypet2,exists] pet2; [@partypet3,exists] pet3; [@partypet4,exists] pet4; nopet")

local separateAnchor = CreateFrame("Frame", nil, Cell.frames.mainFrame, "BackdropTemplate")
Cell.frames.separateNpcFrameAnchor = separateAnchor
P:Size(separateAnchor, 20, 10)
separateAnchor:SetPoint("TOPLEFT", UIParent, "CENTER")
-- Cell:StylizeFrame(separateAnchor, {0, 1, 0, 0.4})

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

    if not which or which == "spacing" or which == "orientation" or which == "anchor" or which == "npc" then
        local groupType = F:GetGroupType()
        npcFrame:ClearAllPoints()

        -- anchors
        local point, anchorPoint, groupAnchorPoint, unitSpacing, groupSpacing
        
        if layout["orientation"] == "vertical" then
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

            if not Cell.vars.currentLayoutTable["npcAnchor"][1] then
                -- update whole NPCFrame point
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
            end
        else
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

            if not Cell.vars.currentLayoutTable["npcAnchor"][1] then
                -- update whole NPCFrame point
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
            end
        end

        -- save point data
        npcFrame:SetAttribute("orientation", layout["orientation"])
        npcFrame:SetAttribute("point", point)
        npcFrame:SetAttribute("anchorPoint", anchorPoint)
        npcFrame:SetAttribute("groupAnchorPoint", groupAnchorPoint)
        npcFrame:SetAttribute("unitSpacing", unitSpacing)
        npcFrame:SetAttribute("groupSpacing", groupSpacing)
    
        local last
        for i = 1, 8 do
            local button = Cell.unitButtons.npc[i]
            button.helper:SetAttribute("orientation", layout["orientation"])
            button.helper:SetAttribute("point", point)
            button.helper:SetAttribute("anchorPoint", anchorPoint)
            button.helper:SetAttribute("unitSpacing", unitSpacing)
            
            -- update each npc button now
            if button:IsVisible() then
                button:ClearAllPoints()
                if last then
                    if layout["orientation"] == "vertical" then
                        button:SetPoint(point, last, anchorPoint, 0, unitSpacing)
                    else
                        button:SetPoint(point, last, anchorPoint, unitSpacing, 0)
                    end
                else
                    button:SetPoint("TOPLEFT", npcFrame)
                end
                last = button
            end
        end

        -- update npcFrame anchor if separate from main 
        if Cell.vars.currentLayoutTable["npcAnchor"][1] then
            if layout["anchor"] == "BOTTOMLEFT" then
                npcFrame:SetPoint("BOTTOMLEFT", separateAnchor, "TOPLEFT", 0, 4)
            elseif layout["anchor"] == "BOTTOMRIGHT" then
                npcFrame:SetPoint("BOTTOMRIGHT", separateAnchor, "TOPRIGHT", 0, 4)
            elseif layout["anchor"] == "TOPLEFT" then
                npcFrame:SetPoint("TOPLEFT", separateAnchor, "BOTTOMLEFT", 0, -4)
            elseif layout["anchor"] == "TOPRIGHT" then
                npcFrame:SetPoint("TOPRIGHT", separateAnchor, "BOTTOMRIGHT", 0, -4)
            end
        end
    end

    if not which or which == "npc" then
        if Cell.vars.currentLayoutTable["npcAnchor"][1] then
            UnregisterStateDriver(npcFrame, "groupstate")
            UnregisterStateDriver(npcFrame, "petstate")
            -- load separate npc frame position
            P:LoadPosition(separateAnchor, Cell.vars.currentLayoutTable["npcAnchor"][2])
        else
            RegisterStateDriver(npcFrame, "groupstate", "[group:raid] raid; [group:party] party; solo")
            RegisterStateDriver(npcFrame, "petstate", "[@pet,exists] pet; [@partypet1,exists] pet1; [@partypet2,exists] pet2; [@partypet3,exists] pet3; [@partypet4,exists] pet4; nopet")
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