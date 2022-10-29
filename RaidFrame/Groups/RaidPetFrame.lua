local _, Cell = ...
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

local raidPetFrame = CreateFrame("Frame", "CellRaidPetFrame", Cell.frames.mainFrame, "SecureHandlerAttributeTemplate")
Cell.frames.raidPetFrame = raidPetFrame

local anchorFrame = CreateFrame("Frame", "CellRaidPetAnchorFrame", raidPetFrame, "BackdropTemplate")
Cell.frames.raidPetFrameAnchor = anchorFrame
anchorFrame:SetPoint("TOPLEFT", UIParent, "CENTER")
anchorFrame:SetMovable(true)
anchorFrame:SetClampedToScreen(true)
-- Cell:StylizeFrame(anchorFrame, {1, 0, 0, 0.4})

local header = CreateFrame("Frame", "CellRaidPetFrameHeader", raidPetFrame, "SecureGroupPetHeaderTemplate")
header:SetAllPoints(raidPetFrame)

-- header:SetAttribute("initialConfigFunction", [[
--     -- print(self:GetName())
--     RegisterUnitWatch(self)
    
--     local header = self:GetParent()
--     self:SetWidth(header:GetAttribute("buttonWidth") or 66)
--     self:SetHeight(header:GetAttribute("buttonHeight") or 46)
-- ]])

function header:UpdateButtonUnits(bName, unit)
    if not unit then return end
    Cell.unitButtons.raidpet.units[unit] = _G[bName]
end

header:SetAttribute("_initialAttributeNames", "refreshUnitChange")
header:SetAttribute("_initialAttribute-refreshUnitChange", [[
    self:GetParent():CallMethod("UpdateButtonUnits", self:GetName(), self:GetAttribute("unit"))
]])
    
header:SetAttribute("template", "CellUnitButtonTemplate")
header:SetAttribute("point", "TOP")
header:SetAttribute("columnAnchorPoint", "LEFT")
header:SetAttribute("maxColumns", 8)
header:SetAttribute("unitsPerColumn", 5)
-- header:SetAttribute("xOffset", 0)
-- header:SetAttribute("yOffset", -1)
-- header:SetAttribute("columnSpacing", 1)

--! to make needButtons == 20
header:SetAttribute("startingIndex", -19)
header:Show()
header:SetAttribute("startingIndex", 1)

for i, b in ipairs({header:GetChildren()}) do
    Cell.unitButtons.raidpet[i] = b
end

-------------------------------------------------
-- functions
-------------------------------------------------
local function UpdatePosition()
    raidPetFrame:ClearAllPoints()
    -- NOTE: detach from spotlightPreviewAnchor
    P:LoadPosition(anchorFrame, Cell.vars.currentLayoutTable["pet"][3])

    local anchor = Cell.vars.currentLayoutTable["anchor"]
    
    if CellDB["general"]["menuPosition"] == "top_bottom" then
        P:Size(anchorFrame, 20, 10)
        if anchor == "BOTTOMLEFT" then
            raidPetFrame:SetPoint("BOTTOMLEFT", anchorFrame, "TOPLEFT", 0, 4)
        elseif anchor == "BOTTOMRIGHT" then
            raidPetFrame:SetPoint("BOTTOMRIGHT", anchorFrame, "TOPRIGHT", 0, 4)
        elseif anchor == "TOPLEFT" then
            raidPetFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -4)
        elseif anchor == "TOPRIGHT" then
            raidPetFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT", 0, -4)
        end
    else
        P:Size(anchorFrame, 10, 20)
        if anchor == "BOTTOMLEFT" then
            raidPetFrame:SetPoint("BOTTOMLEFT", anchorFrame, "BOTTOMRIGHT", 4, 0)
        elseif anchor == "BOTTOMRIGHT" then
            raidPetFrame:SetPoint("BOTTOMRIGHT", anchorFrame, "BOTTOMLEFT", -4, 0)
        elseif anchor == "TOPLEFT" then
            raidPetFrame:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT", 4, 0)
        elseif anchor == "TOPRIGHT" then
            raidPetFrame:SetPoint("TOPRIGHT", anchorFrame, "TOPLEFT", -4, 0)
        end
    end
end

local function UpdateMenu(which)
    if which == "position" then
        UpdatePosition()
    end
end
Cell:RegisterCallback("UpdateMenu", "RaidPetFrame_UpdateMenu", UpdateMenu)

local init
local function RaidPetFrame_UpdateLayout(layout, which)
    if Cell.vars.groupType ~= "raid" and init then return end
    init = true
    
    if Cell.vars.inBattleground == 5 then
        layout = CellLayoutAutoSwitchTable[Cell.vars.playerSpecRole]["arena"]
    elseif Cell.vars.inBattleground == 15 or Cell.vars.inBattleground == 40 then
        layout = CellLayoutAutoSwitchTable[Cell.vars.playerSpecRole]["battleground"..Cell.vars.inBattleground]
    elseif Cell.vars.inMythic then -- NOTE: retail
        layout = CellLayoutAutoSwitchTable[Cell.vars.playerSpecRole]["mythic"]
    elseif Cell.isWrath then -- NOTE: wrath
        layout = CellLayoutAutoSwitchTable[Cell.vars.playerSpecRole][Cell.vars.raidType]
    else
        layout = CellLayoutAutoSwitchTable[Cell.vars.playerSpecRole]["raid"]
    end
    layout = CellDB["layouts"][layout]

    if not which or which == "size" or which == "petSize" or which == "power" or which == "barOrientation" then
        local width, height
        
        if layout["pet"][4] then
            width, height = unpack(layout["pet"][5])
        else
            width, height = unpack(layout["size"])
        end

        P:Size(raidPetFrame, width, height)

        header:SetAttribute("buttonWidth", P:Scale(width))
        header:SetAttribute("buttonHeight", P:Scale(height))

        for i, b in ipairs({header:GetChildren()}) do
            if not which or which == "size" or which == "petSize" then
                P:Size(b, width, height)
            end

            -- NOTE: SetOrientation BEFORE SetPowerSize
            if not which or which == "barOrientation" then
                b.func.SetOrientation(unpack(layout["barOrientation"]))
            end
           
            if not which or which == "power" or which == "barOrientation" then
                b.func.SetPowerSize(layout["powerSize"])
            end
        end
    end

    if not which or which == "spacing" or which == "orientation" or which == "anchor" then
        local point, anchorPoint, unitSpacing, headerPoint, headerColumnAnchorPoint
        if layout["orientation"] == "vertical" then
            -- anchor
            if layout["anchor"] == "BOTTOMLEFT" then
                point, anchorPoint = "BOTTOMLEFT", "TOPLEFT"
                headerPoint, headerColumnAnchorPoint = "BOTTOM", "LEFT"
                unitSpacing = layout["spacing"]
            elseif layout["anchor"] == "BOTTOMRIGHT" then
                point, anchorPoint = "BOTTOMRIGHT", "TOPRIGHT"
                headerPoint, headerColumnAnchorPoint = "BOTTOM", "RIGHT"
                unitSpacing = layout["spacing"]
            elseif layout["anchor"] == "TOPLEFT" then
                point, anchorPoint = "TOPLEFT", "BOTTOMLEFT"
                headerPoint, headerColumnAnchorPoint = "TOP", "LEFT"
                unitSpacing = -layout["spacing"]
            elseif layout["anchor"] == "TOPRIGHT" then
                point, anchorPoint = "TOPRIGHT", "BOTTOMRIGHT"
                headerPoint, headerColumnAnchorPoint = "TOP", "RIGHT"
                unitSpacing = -layout["spacing"]
            end

            header:SetAttribute("columnSpacing", unitSpacing)
            header:SetAttribute("xOffset", 0)
            header:SetAttribute("yOffset", unitSpacing)
        else
            -- anchor
            if layout["anchor"] == "BOTTOMLEFT" then
                point, anchorPoint = "BOTTOMLEFT", "BOTTOMRIGHT"
                headerPoint, headerColumnAnchorPoint = "LEFT", "BOTTOM"
                unitSpacing = layout["spacing"]
            elseif layout["anchor"] == "BOTTOMRIGHT" then
                point, anchorPoint = "BOTTOMRIGHT", "BOTTOMLEFT"
                headerPoint, headerColumnAnchorPoint = "RIGHT", "BOTTOM"
                unitSpacing = -layout["spacing"]
            elseif layout["anchor"] == "TOPLEFT" then
                point, anchorPoint = "TOPLEFT", "TOPRIGHT"
                headerPoint, headerColumnAnchorPoint = "LEFT", "TOP"
                unitSpacing = layout["spacing"]
            elseif layout["anchor"] == "TOPRIGHT" then
                point, anchorPoint = "TOPRIGHT", "TOPLEFT"
                headerPoint, headerColumnAnchorPoint = "RIGHT", "TOP"
                unitSpacing = -layout["spacing"]
            end

            header:SetAttribute("columnSpacing", unitSpacing)
            header:SetAttribute("xOffset", unitSpacing)
            header:SetAttribute("yOffset", 0)
        end
        
        -- header:ClearAllPoints()
        -- header:SetPoint(point)
        header:SetAttribute("point", headerPoint)
        header:SetAttribute("columnAnchorPoint", headerColumnAnchorPoint)

        --! force update unitbutton's point
        for i, b in ipairs({header:GetChildren()}) do
            b:ClearAllPoints()
        end
        header:SetAttribute("unitsPerColumn", 5)
        header:SetAttribute("maxColumns", 8)
    end

    if not which or which == "anchor" then
        UpdatePosition()
    end

    if not which or which == "pet" then
        if layout["pet"][2] and Cell.vars.inBattleground ~= 5 then
            header:SetAttribute("showRaid", true)
            RegisterAttributeDriver(raidPetFrame, "state-visibility", "[group:raid] show; [group:party] hide; hide")
        else
            header:SetAttribute("showRaid", false)
            UnregisterAttributeDriver(raidPetFrame, "state-visibility")
            raidPetFrame:Hide()
        end
    end
end
Cell:RegisterCallback("UpdateLayout", "RaidPetFrame_UpdateLayout", RaidPetFrame_UpdateLayout)