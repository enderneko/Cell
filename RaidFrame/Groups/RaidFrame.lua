local _, Cell = ...
local F = Cell.funcs

local raidFrame = CreateFrame("Frame", "CellRaidFrame", Cell.frames.mainFrame, "SecureHandlerAttributeTemplate")
Cell.frames.raidFrame = raidFrame
raidFrame:SetAllPoints(Cell.frames.mainFrame)

local npcFrameAnchor = CreateFrame("Frame", "CellNPCFrameAnchor", raidFrame, "SecureFrameTemplate")
npcFrameAnchor:Hide()
raidFrame:SetFrameRef("npcanchor", npcFrameAnchor)

raidFrame:SetAttribute("_onattributechanged", [[
	if name ~= "visibility" then
		return
    end

    local maxGroup
	for i = 1, 8 do
		if self:GetFrameRef("visibilityhelper"..i):IsVisible() then
			maxGroup = i
		end
    end

    if not maxGroup then return end -- NOTE: empty subgroup will cause maxGroup == nil
    
    local header = self:GetFrameRef("subgroup"..maxGroup)
    local npcFrameAnchor = self:GetFrameRef("npcanchor")
    local spacing = self:GetAttribute("spacing") or 0

	npcFrameAnchor:ClearAllPoints()
    npcFrameAnchor:SetPoint("TOPLEFT", header, "TOPRIGHT", spacing, 0)
]])

--[[ Interface\FrameXML\SecureGroupHeaders.lua
List of the various configuration attributes
======================================================
showRaid = [BOOLEAN] -- true if the header should be shown while in a raid
showParty = [BOOLEAN] -- true if the header should be shown while in a party and not in a raid
showPlayer = [BOOLEAN] -- true if the header should show the player when not in a raid
showSolo = [BOOLEAN] -- true if the header should be shown while not in a group (implies showPlayer)
nameList = [STRING] -- a comma separated list of player names (not used if 'groupFilter' is set)
groupFilter = [1-8, STRING] -- a comma seperated list of raid group numbers and/or uppercase class names and/or uppercase roles
roleFilter = [STRING] -- a comma seperated list of MT/MA/Tank/Healer/DPS role strings
strictFiltering = [BOOLEAN] 
-- if true, then 
---- if only groupFilter is specified then characters must match both a group and a class from the groupFilter list
---- if only roleFilter is specified then characters must match at least one of the specified roles
---- if both groupFilter and roleFilters are specified then characters must match a group and a class from the groupFilter list and a role from the roleFilter list
point = [STRING] -- a valid XML anchoring point (Default: "TOP")
xOffset = [NUMBER] -- the x-Offset to use when anchoring the unit buttons (Default: 0)
yOffset = [NUMBER] -- the y-Offset to use when anchoring the unit buttons (Default: 0)
sortMethod = ["INDEX", "NAME", "NAMELIST"] -- defines how the group is sorted (Default: "INDEX")
sortDir = ["ASC", "DESC"] -- defines the sort order (Default: "ASC")
template = [STRING] -- the XML template to use for the unit buttons
templateType = [STRING] - specifies the frame type of the managed subframes (Default: "Button")
groupBy = [nil, "GROUP", "CLASS", "ROLE", "ASSIGNEDROLE"] - specifies a "grouping" type to apply before regular sorting (Default: nil)
groupingOrder = [STRING] - specifies the order of the groupings (ie. "1,2,3,4,5,6,7,8")
maxColumns = [NUMBER] - maximum number of columns the header will create (Default: 1)
unitsPerColumn = [NUMBER or nil] - maximum units that will be displayed in a singe column, nil is infinite (Default: nil)
startingIndex = [NUMBER] - the index in the final sorted unit list at which to start displaying units (Default: 1)
columnSpacing = [NUMBER] - the amount of space between the rows/columns (Default: 0)
columnAnchorPoint = [STRING] - the anchor point of each new column (ie. use LEFT for the columns to grow to the right)
--]]
local groupHeaders = {}
local function CreateGroupHeader(group)
    local headerName = "CellGroupHeaderSubGroup"..group
	local header = CreateFrame("Frame", headerName, raidFrame, "SecureGroupHeaderTemplate")
    groupHeaders[group] = header
    Cell.unitButtons.raid[headerName] = header

	header:SetAttribute("initialConfigFunction", [[
        RegisterUnitWatch(self)

        local header = self:GetParent()
		self:SetWidth(header:GetAttribute("buttonWidth") or 66)
        self:SetHeight(header:GetAttribute("buttonHeight") or 46)
    ]])
    
	header:SetAttribute("template", "CellUnitButtonTemplate")
	header:SetAttribute("point", "TOP")
	header:SetAttribute("columnAnchorPoint", "LEFT")
    header:SetAttribute("groupFilter", group)
	header:SetAttribute("xOffset", 0)
	header:SetAttribute("yOffset", -1)
	header:SetAttribute("unitsPerColumn", 5)
	header:SetAttribute("columnSpacing", 1)
    header:SetAttribute("maxColumns", 1)
    header:SetAttribute("startingIndex", 1)
	header:SetAttribute("showRaid", true)

	return header
end

for i = 1, 8 do
    local header = CreateGroupHeader(i)

    --[[ Interface\FrameXML\SecureGroupHeaders.lua line 150
        local loopStart = startingIndex;
        local loopFinish = min((startingIndex - 1) + unitsPerColumn * numColumns, unitCount)
        -- ensure there are enough buttons
        local needButtons = max(1, numDisplayed); --! to make needButtons == 5
    ]]
    
    --! to make needButtons == 5 cheat configureChildren in SecureGroupHeaders.lua
    header:SetAttribute("startingIndex", -4)
	header:Show()
    header:SetAttribute("startingIndex", 1)

    -- for npcFrame's point
    raidFrame:SetFrameRef("subgroup"..i, header)
    
    local helper = CreateFrame("Frame", nil, header[1], "SecureHandlerShowHideTemplate")
	helper:SetFrameRef("raidframe", raidFrame)
	raidFrame:SetFrameRef("visibilityhelper"..i, helper)
	helper:SetAttribute("_onshow", [[ self:GetFrameRef("raidframe"):SetAttribute("visibility", 1) ]])
	helper:SetAttribute("_onhide", [[ self:GetFrameRef("raidframe"):SetAttribute("visibility", 0) ]])
end

local function RaidFrame_UpdateLayout(layout, which)
    if layout ~= Cell.vars.currentLayout then return end
    layout = Cell.vars.currentLayoutTable

    local width, height = unpack(layout["size"])

    for i, header in ipairs(groupHeaders) do
        if not which or which == "size" then
            for j, b in ipairs({header:GetChildren()}) do
                b:SetWidth(width)
                b:SetHeight(height)
                b:ClearAllPoints()
            end
            --! important new button size depend on buttonWidth & buttonHeight
            header:SetAttribute("buttonWidth", width)
            header:SetAttribute("buttonHeight", height)

            npcFrameAnchor:SetSize(width, height)
        end

        if not which or which == "spacing" then
            header:ClearAllPoints()
            if i == 1 then
                header:SetPoint("TOPLEFT")
            else
                header:SetPoint("TOPLEFT",  groupHeaders[i - 1], "TOPRIGHT", layout["spacing"], 0)
            end
            header:SetAttribute("point", "TOP")
            header:SetAttribute("yOffset", -layout["spacing"])

            raidFrame:SetAttribute("spacing", layout["spacing"])
            raidFrame:SetAttribute("visibility", 1) -- NOTE: trigger _onattributechanged to set npcFrameAnchor point!
        end

        if which == "textWidth" then -- textWidth already initialized in UnitButton.lua
            for j, b in ipairs({header:GetChildren()}) do
                b:GetScript("OnSizeChanged")(b)
            end
        end

        if not which or which == "groupFilter" then
            if layout["groupFilter"][i] then
                header:Show()
            else
                header:Hide()
            end
        end
        -- header:SetAttribute("unitsPerColumn", 5)
    end
end
Cell:RegisterCallback("UpdateLayout", "RaidFrame_UpdateLayout", RaidFrame_UpdateLayout)