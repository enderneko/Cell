local _, Cell = ...
local F = Cell.funcs
local B = Cell.bFuncs
local P = Cell.pixelPerfectFuncs

local raidFrame = CreateFrame("Frame", "CellRaidFrame", Cell.frames.mainFrame, "SecureHandlerAttributeTemplate")
Cell.frames.raidFrame = raidFrame
raidFrame:SetAllPoints(Cell.frames.mainFrame)

local npcFrameAnchor = CreateFrame("Frame", "CellNPCFrameAnchor", raidFrame, "SecureFrameTemplate,BackDropTemplate")
raidFrame:SetFrameRef("npcAnchor", npcFrameAnchor)
-- npcFrameAnchor:Hide()
-- Cell:StylizeFrame(npcFrameAnchor)

raidFrame:SetAttribute("_onattributechanged", [[
    if not (name == "combinegroups" or name == "visibility") then
        return
    end

    local header
    local combineGroups = self:GetAttribute("combineGroups")

    if combineGroups then
        header = self:GetFrameRef("combinedHeader")
    else
        local maxGroup
        for i = 1, 8 do
            if self:GetFrameRef("visibilityHelper"..i):IsVisible() then
                maxGroup = i
            end
        end
        if not maxGroup then return end -- NOTE: empty subgroup will cause maxGroup == nil
        header = self:GetFrameRef("subgroup"..maxGroup)
    end

    local npcFrameAnchor = self:GetFrameRef("npcAnchor")
    local spacing = self:GetAttribute("spacing") or 0
    local orientation = self:GetAttribute("orientation") or "vertical"
    local anchor = self:GetAttribute("anchor") or "TOPLEFT"

    npcFrameAnchor:ClearAllPoints()
    local point, anchorPoint
    if orientation == "vertical" then
        if anchor == "BOTTOMLEFT" then
            point, anchorPoint = "BOTTOMLEFT", "BOTTOMRIGHT"
        elseif anchor == "BOTTOMRIGHT" then
            point, anchorPoint = "BOTTOMRIGHT", "BOTTOMLEFT"
        elseif anchor == "TOPLEFT" then
            point, anchorPoint = "TOPLEFT", "TOPRIGHT"
        elseif anchor == "TOPRIGHT" then
            point, anchorPoint = "TOPRIGHT", "TOPLEFT"
        end

        npcFrameAnchor:SetPoint(point, header, anchorPoint, spacing, 0)
    else
        if anchor == "BOTTOMLEFT" then
            point, anchorPoint = "BOTTOMLEFT", "TOPLEFT"
        elseif anchor == "BOTTOMRIGHT" then
            point, anchorPoint = "BOTTOMRIGHT", "TOPRIGHT"
        elseif anchor == "TOPLEFT" then
            point, anchorPoint = "TOPLEFT", "BOTTOMLEFT"
        elseif anchor == "TOPRIGHT" then
            point, anchorPoint = "TOPRIGHT", "BOTTOMRIGHT"
        end

        npcFrameAnchor:SetPoint(point, header, anchorPoint, 0, spacing)
    end
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

-------------------------------------------------
-- combinedHeader
-------------------------------------------------
local combinedHeader
do
    local headerName = "CellRaidFrameHeader0"
    combinedHeader = CreateFrame("Frame", headerName, raidFrame, "SecureGroupHeaderTemplate")
    Cell.unitButtons.raid[headerName] = combinedHeader

    combinedHeader:SetAttribute("template", "CellUnitButtonTemplate")
    combinedHeader:SetAttribute("columnAnchorPoint", "LEFT")
    combinedHeader:SetAttribute("point", "TOP")
    combinedHeader:SetAttribute("groupFilter", "1,2,3,4,5,6,7,8")
    -- combinedHeader:SetAttribute("groupingOrder", "TANK,HEALER,DAMAGER,NONE")
    -- combinedHeader:SetAttribute("groupBy", "ASSIGNEDROLE")
    combinedHeader:SetAttribute("xOffset", 0)
    combinedHeader:SetAttribute("yOffset", -1)
    combinedHeader:SetAttribute("unitsPerColumn", 5)
    combinedHeader:SetAttribute("maxColumns", 8)
    -- combinedHeader:SetAttribute("showRaid", true)

    combinedHeader:SetAttribute("startingIndex", -39)
    combinedHeader:Show()
    combinedHeader:SetAttribute("startingIndex", 1)

    -- for npcFrame's point
    raidFrame:SetFrameRef("combinedHeader", combinedHeader)
end

-------------------------------------------------
-- separatedHeaders
-------------------------------------------------
local separatedHeaders = {}
local function CreateGroupHeader(group)
    local headerName = "CellRaidFrameHeader"..group
    local header = CreateFrame("Frame", headerName, raidFrame, "SecureGroupHeaderTemplate")
    separatedHeaders[group] = header
    Cell.unitButtons.raid[headerName] = header

    -- header:SetAttribute("initialConfigFunction", [[
    --     RegisterUnitWatch(self)

    --     local header = self:GetParent()
    --     self:SetWidth(header:GetAttribute("buttonWidth") or 66)
    --     self:SetHeight(header:GetAttribute("buttonHeight") or 46)
    -- ]])

    header:SetAttribute("template", "CellUnitButtonTemplate")
    header:SetAttribute("columnAnchorPoint", "LEFT")
    header:SetAttribute("point", "TOP")
    header:SetAttribute("groupFilter", group)
    header:SetAttribute("xOffset", 0)
    header:SetAttribute("yOffset", -1)
    header:SetAttribute("unitsPerColumn", 5)
    header:SetAttribute("columnSpacing", 1)
    header:SetAttribute("maxColumns", 1)
    -- header:SetAttribute("startingIndex", 1)
    header:SetAttribute("showRaid", true)

    --[[ Interface\FrameXML\SecureGroupHeaders.lua line 150
        local loopStart = startingIndex;
        local loopFinish = min((startingIndex - 1) + unitsPerColumn * numColumns, unitCount)
        -- ensure there are enough buttons
        numDisplayed = loopFinish - (loopStart - 1)
        local needButtons = max(1, numDisplayed); --! to make needButtons == 5
    ]]

    --! to make needButtons == 5 cheat configureChildren in SecureGroupHeaders.lua
    header:SetAttribute("startingIndex", -4)
    header:Show()
    header:SetAttribute("startingIndex", 1)

    -- for i, b in ipairs(header) do
    --     b.type = "main" -- layout setup
    -- end

    -- for npcFrame's point
    raidFrame:SetFrameRef("subgroup"..group, header)

    local helper = CreateFrame("Frame", nil, header[1], "SecureHandlerShowHideTemplate")
    helper:SetFrameRef("raidframe", raidFrame)
    raidFrame:SetFrameRef("visibilityHelper"..group, helper)
    helper:SetAttribute("_onshow", [[ self:GetFrameRef("raidframe"):SetAttribute("visibility", 1) ]])
    helper:SetAttribute("_onhide", [[ self:GetFrameRef("raidframe"):SetAttribute("visibility", 0) ]])
end

for i = 1, 8 do
    CreateGroupHeader(i)
end

-- arena pet
local arenaPetButtons = {}
for i = 1, (Cell.isRetail and 3 or 5) do
    arenaPetButtons[i] = CreateFrame("Button", "CellArenaPet"..i, raidFrame, "CellUnitButtonTemplate")
    arenaPetButtons[i]:SetAttribute("unit", "raidpet"..i)

    Cell.unitButtons.arena["raidpet"..i] = arenaPetButtons[i]
end

-------------------------------------------------
-- update
-------------------------------------------------
local function GetPoints(layout)
    local orientation = layout["main"]["orientation"]
    local anchor = layout["main"]["anchor"]
    local spacingX = layout["main"]["spacingX"]
    local spacingY = layout["main"]["spacingY"]

    local point, anchorPoint, groupAnchorPoint, unitSpacing, groupSpacing, verticalSpacing, horizontalSpacing, headerPoint, headerColumnAnchorPoint

    if orientation == "vertical" then
        if anchor == "BOTTOMLEFT" then
            point, anchorPoint, groupAnchorPoint = "BOTTOMLEFT", "TOPLEFT", "BOTTOMRIGHT"
            headerPoint, headerColumnAnchorPoint = "BOTTOM", "LEFT"
            unitSpacing = spacingY
            groupSpacing = spacingX
            unitSpacingX, unitSpacingY = spacingX, spacingY
            verticalSpacing = spacingY+layout["main"]["groupSpacing"]
        elseif anchor == "BOTTOMRIGHT" then
            point, anchorPoint, groupAnchorPoint = "BOTTOMRIGHT", "TOPRIGHT", "BOTTOMLEFT"
            headerPoint, headerColumnAnchorPoint = "BOTTOM", "RIGHT"
            unitSpacing = spacingY
            groupSpacing = -spacingX
            unitSpacingX, unitSpacingY = spacingX, spacingY
            verticalSpacing = spacingY+layout["main"]["groupSpacing"]
        elseif anchor == "TOPLEFT" then
            point, anchorPoint, groupAnchorPoint = "TOPLEFT", "BOTTOMLEFT", "TOPRIGHT"
            headerPoint, headerColumnAnchorPoint = "TOP", "LEFT"
            unitSpacing = -spacingY
            groupSpacing = spacingX
            unitSpacingX, unitSpacingY = spacingX, -spacingY
            verticalSpacing = -spacingY-layout["main"]["groupSpacing"]
        elseif anchor == "TOPRIGHT" then
            point, anchorPoint, groupAnchorPoint = "TOPRIGHT", "BOTTOMRIGHT", "TOPLEFT"
            headerPoint, headerColumnAnchorPoint = "TOP", "RIGHT"
            unitSpacing = -spacingY
            groupSpacing = -spacingX
            unitSpacingX, unitSpacingY = spacingX, -spacingY
            verticalSpacing = -spacingY-layout["main"]["groupSpacing"]
        end
    else
        if anchor == "BOTTOMLEFT" then
            point, anchorPoint, groupAnchorPoint = "BOTTOMLEFT", "BOTTOMRIGHT", "TOPLEFT"
            headerPoint, headerColumnAnchorPoint = "LEFT", "BOTTOM"
            unitSpacing = spacingX
            groupSpacing = spacingY
            unitSpacingX, unitSpacingY = spacingX, spacingY
            horizontalSpacing = spacingX+layout["main"]["groupSpacing"]
        elseif anchor == "BOTTOMRIGHT" then
            point, anchorPoint, groupAnchorPoint = "BOTTOMRIGHT", "BOTTOMLEFT", "TOPRIGHT"
            headerPoint, headerColumnAnchorPoint = "RIGHT", "BOTTOM"
            unitSpacing = -spacingX
            groupSpacing = spacingY
            unitSpacingX, unitSpacingY = -spacingX, spacingY
            horizontalSpacing = -spacingX-layout["main"]["groupSpacing"]
        elseif anchor == "TOPLEFT" then
            point, anchorPoint, groupAnchorPoint = "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT"
            headerPoint, headerColumnAnchorPoint = "LEFT", "TOP"
            unitSpacing = spacingX
            groupSpacing = -spacingY
            unitSpacingX, unitSpacingY = spacingX, spacingY
            horizontalSpacing = spacingX+layout["main"]["groupSpacing"]
        elseif anchor == "TOPRIGHT" then
            point, anchorPoint, groupAnchorPoint = "TOPRIGHT", "TOPLEFT", "BOTTOMRIGHT"
            headerPoint, headerColumnAnchorPoint = "RIGHT", "TOP"
            unitSpacing = -spacingX
            groupSpacing = -spacingY
            unitSpacingX, unitSpacingY = -spacingX, spacingY
            horizontalSpacing = -spacingX-layout["main"]["groupSpacing"]
        end
    end

    return point, anchorPoint, groupAnchorPoint, unitSpacing, groupSpacing, unitSpacingX, unitSpacingY, verticalSpacing, horizontalSpacing, headerPoint, headerColumnAnchorPoint
end

local function UpdateHeadersShowRaidAttribute()
    local shouldShowRaid = CellDB["general"]["showRaid"]

    if Cell.vars.currentLayoutTable["main"]["combineGroups"] then
        combinedHeader:SetAttribute("showRaid", shouldShowRaid)
        for _, header in ipairs(separatedHeaders) do
            header:SetAttribute("showRaid", nil)
        end
    else
        combinedHeader:SetAttribute("showRaid", nil)
        for _, header in ipairs(separatedHeaders) do
            header:SetAttribute("showRaid", shouldShowRaid)
        end
    end
end

local function UpdateHeader(header, layout, which)
    if not which or which == "header" or which == "main-size" or which == "main-power" or which == "groupFilter" or which == "barOrientation" or which == "powerFilter" then
        local width, height = unpack(layout["main"]["size"])

        for _, b in ipairs(header) do
            if not which or which == "header" or which == "main-size" or which == "groupFilter" then
                P:Size(b, width, height)
                b:ClearAllPoints()
            end
            -- NOTE: SetOrientation BEFORE SetPowerSize
            if not which or which == "header" or which == "barOrientation" then
                B:SetOrientation(b, layout["barOrientation"][1], layout["barOrientation"][2])
            end
            if not which or which == "header" or which == "main-power" or which == "groupFilter" or which == "barOrientation" or which == "powerFilter" then
                B:SetPowerSize(b, layout["main"]["powerSize"])
            end
        end

        if not which or which == "header" or which == "main-size" or which == "groupFilter" then
            -- 确保按钮在“一定程度上”对齐
            header:SetAttribute("minWidth", P:Scale(width))
            header:SetAttribute("minHeight", P:Scale(height))

            P:Size(npcFrameAnchor, width, height) -- REVIEW: check same as main
        end
    end

    -- REVIEW: fix name width
    if which == "header" or which == "groupFilter" then
        for j, b in ipairs(header) do
            b.widgets.healthBar:GetScript("OnSizeChanged")(b.widgets.healthBar)
        end
        for k, arenaPet in ipairs(arenaPetButtons) do
            arenaPet.widgets.healthBar:GetScript("OnSizeChanged")(arenaPet.widgets.healthBar)
        end
    end
end

local init, previousLayout
local function RaidFrame_UpdateLayout(layout, which)
    if Cell.vars.groupType ~= "raid" and init then return end
    init = true

    -- if previousLayout == layout and not which then return end
    -- previousLayout = layout

    layout = CellDB["layouts"][layout]

    -- arena pets
    if Cell.vars.inBattleground == 5 and layout["pet"]["partyEnabled"] then
        for i, arenaPet in ipairs(arenaPetButtons) do
            RegisterAttributeDriver(arenaPet, "state-visibility", "[@raidpet"..i..", exists] show;hide")
        end
    else
        for i, arenaPet in ipairs(arenaPetButtons) do
            UnregisterAttributeDriver(arenaPet, "state-visibility")
            arenaPet:Hide()
        end
    end

    local point, anchorPoint, groupAnchorPoint, unitSpacing, groupSpacing, unitSpacingX, unitSpacingY, verticalSpacing, horizontalSpacing, headerPoint, headerColumnAnchorPoint = GetPoints(layout)

    if not which or which == "main-arrangement" or which == "rows_columns" or which == "groupSpacing" or which == "groupFilter" then
        -- arena pets
        for k in ipairs(arenaPetButtons) do
            arenaPetButtons[k]:ClearAllPoints()
            if k == 1 then
                arenaPetButtons[k]:SetPoint(point, npcFrameAnchor)
            else
                if layout["main"]["orientation"] == "vertical" then
                    arenaPetButtons[k]:SetPoint(point, arenaPetButtons[k-1], anchorPoint, 0, unitSpacing)
                else
                    arenaPetButtons[k]:SetPoint(point, arenaPetButtons[k-1], anchorPoint, unitSpacing, 0)
                end
            end
        end
    end

    local shownGroups = {}
    for i, isShown in ipairs(layout["groupFilter"]) do
        if isShown then
            UpdateHeader(separatedHeaders[i], layout, which)
            tinsert(shownGroups, i)
        end
    end

    if not which or which == "header" then
        UpdateHeadersShowRaidAttribute()
    end

    if layout["main"]["combineGroups"] then
        UpdateHeader(combinedHeader, layout, which)

        if not which or which == "header" or which == "main-arrangement" or which == "rows_columns" or which == "groupSpacing" or which == "unitsPerColumn" then
            combinedHeader:ClearAllPoints()

            if layout["main"]["orientation"] == "vertical" then
                combinedHeader:SetAttribute("columnAnchorPoint", headerColumnAnchorPoint)
                combinedHeader:SetAttribute("point", headerPoint)
                combinedHeader:SetAttribute("xOffset", 0)
                combinedHeader:SetAttribute("yOffset", unitSpacingY)
                combinedHeader:SetAttribute("columnSpacing", unitSpacingX)
                combinedHeader:SetAttribute("maxColumns", layout["main"]["maxColumns"])
            else
                combinedHeader:SetAttribute("columnAnchorPoint", headerColumnAnchorPoint)
                combinedHeader:SetAttribute("point", headerPoint)
                combinedHeader:SetAttribute("xOffset", unitSpacingX)
                combinedHeader:SetAttribute("yOffset", 0)
                combinedHeader:SetAttribute("columnSpacing", unitSpacingY)
                combinedHeader:SetAttribute("maxColumns", layout["main"]["maxColumns"])
            end

            --! force update unitbutton's point
            for _, b in ipairs(combinedHeader) do
                b:ClearAllPoints()
            end

            combinedHeader:SetAttribute("unitsPerColumn", layout["main"]["unitsPerColumn"])
            combinedHeader:SetPoint(point)

            raidFrame:SetAttribute("spacing", groupSpacing)
            raidFrame:SetAttribute("orientation", layout["main"]["orientation"])
            raidFrame:SetAttribute("anchor", layout["main"]["anchor"])
            raidFrame:SetAttribute("combineGroups", true) -- NOTE: trigger _onattributechanged to set npcFrameAnchor point!
        end

        if not which or which == "header" or which == "sort" then
            if layout["main"]["sortByRole"] then
                combinedHeader:SetAttribute("sortMethod", "NAME")
                local order = table.concat(layout["main"]["roleOrder"], ",")..",NONE"
                combinedHeader:SetAttribute("groupingOrder", order)
                combinedHeader:SetAttribute("groupBy", "ASSIGNEDROLE")
            else
                combinedHeader:SetAttribute("sortMethod", "INDEX")
                combinedHeader:SetAttribute("groupingOrder", "")
                combinedHeader:SetAttribute("groupBy", nil)
            end
        end

        if not which or which == "header" or which == "groupFilter" then
            combinedHeader:SetAttribute("groupFilter", F:TableToString(shownGroups, ","))
        end

    else
        if not which or which == "header" or which == "main-arrangement" or which == "rows_columns" or which == "groupSpacing" or which == "groupFilter" then
            for i, group in ipairs(shownGroups) do
                local header = separatedHeaders[group]
                header:ClearAllPoints()

                if layout["main"]["orientation"] == "vertical" then
                    header:SetAttribute("columnAnchorPoint", headerColumnAnchorPoint)
                    header:SetAttribute("point", headerPoint)
                    header:SetAttribute("xOffset", 0)
                    header:SetAttribute("yOffset", unitSpacing)

                    --! force update unitbutton's point
                    for j = 1, 5 do
                        header[j]:ClearAllPoints()
                    end
                    header:SetAttribute("unitsPerColumn", 5)

                    if i == 1 then
                        header:SetPoint(point)
                    else
                        local headersPerRow = layout["main"]["maxColumns"]
                        local headerCol = i % layout["main"]["maxColumns"]
                        headerCol = headerCol == 0 and headersPerRow or headerCol

                        if headerCol == 1 then -- first column on each row
                            header:SetPoint(point, separatedHeaders[shownGroups[i-headersPerRow]], anchorPoint, 0, verticalSpacing)
                        else
                            header:SetPoint(point, separatedHeaders[shownGroups[i-1]], groupAnchorPoint, groupSpacing, 0)
                        end
                    end
                else
                    header:SetAttribute("columnAnchorPoint", headerColumnAnchorPoint)
                    header:SetAttribute("point", headerPoint)
                    header:SetAttribute("xOffset", unitSpacing)
                    header:SetAttribute("yOffset", 0)

                    --! force update unitbutton's point
                    for j = 1, 5 do
                        header[j]:ClearAllPoints()
                    end
                    header:SetAttribute("unitsPerColumn", 5)

                    if i == 1 then
                        header:SetPoint(point)
                    else
                        local headersPerCol = layout["main"]["maxColumns"]
                        local headerRow = i % layout["main"]["maxColumns"]
                        headerRow = headerRow == 0 and headersPerCol or headerRow

                        if headerRow == 1 then -- first row on each column
                            header:SetPoint(point, separatedHeaders[shownGroups[i-headersPerCol]], anchorPoint, horizontalSpacing, 0)
                        else
                            header:SetPoint(point, separatedHeaders[shownGroups[i-1]], groupAnchorPoint, 0, groupSpacing)
                        end
                    end
                end
            end

            raidFrame:SetAttribute("spacing", groupSpacing)
            raidFrame:SetAttribute("orientation", layout["main"]["orientation"])
            raidFrame:SetAttribute("anchor", layout["main"]["anchor"])
            raidFrame:SetAttribute("combineGroups", false) -- NOTE: trigger _onattributechanged to set npcFrameAnchor point!
        end

        if not which or which == "header" or which == "sort" then
            if layout["main"]["sortByRole"] then
                for i = 1, 8 do
                    separatedHeaders[i]:SetAttribute("sortMethod", "NAME")
                    local order = table.concat(layout["main"]["roleOrder"], ",")..",NONE"
                    separatedHeaders[i]:SetAttribute("groupingOrder", order)
                    separatedHeaders[i]:SetAttribute("groupBy", "ASSIGNEDROLE")
                end
            else
                for i = 1, 8 do
                    separatedHeaders[i]:SetAttribute("sortMethod", "INDEX")
                    separatedHeaders[i]:SetAttribute("groupingOrder", "")
                    separatedHeaders[i]:SetAttribute("groupBy", nil)
                end
            end
        end

        -- show/hide groups
        if not which or which == "header" or which == "groupFilter" then
            for i = 1, 8 do
                if layout["groupFilter"][i] then
                    separatedHeaders[i]:Show()
                else
                    separatedHeaders[i]:Hide()
                end
            end
        end
    end

    -- raid pets
    if not which or strfind(which, "size$") or strfind(which, "power$") or which == "barOrientation" or which == "powerFilter" then
        local width, height = unpack(layout["main"]["size"])

        for i, arenaPet in ipairs(arenaPetButtons) do
            -- NOTE: SetOrientation BEFORE SetPowerSize
            B:SetOrientation(arenaPet, layout["barOrientation"][1], layout["barOrientation"][2])

            if layout["pet"]["sameSizeAsMain"] then
                P:Size(arenaPet, width, height)
                B:SetPowerSize(arenaPet, layout["main"]["powerSize"])
            else
                P:Size(arenaPet, layout["pet"]["size"][1], layout["pet"]["size"][2])
                B:SetPowerSize(arenaPet, layout["pet"]["powerSize"])
            end
        end
    end
end
Cell:RegisterCallback("UpdateLayout", "RaidFrame_UpdateLayout", RaidFrame_UpdateLayout)

local function RaidFrame_UpdateVisibility(which)
    if not which or which == "raid" then
        UpdateHeadersShowRaidAttribute()

        if CellDB["general"]["showRaid"] then
            RegisterAttributeDriver(raidFrame, "state-visibility", "show")
        else
            UnregisterAttributeDriver(raidFrame, "state-visibility")
            raidFrame:Hide()
        end
    end
end
Cell:RegisterCallback("UpdateVisibility", "RaidFrame_UpdateVisibility", RaidFrame_UpdateVisibility)