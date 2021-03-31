local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

local raidRosterFrame = CreateFrame("Frame", "CellRaidRosterFrame", Cell.frames.mainFrame, "BackdropTemplate")
Cell.frames.raidRosterFrame = raidRosterFrame
-- raidRosterFrame:SetPoint("BOTTOMLEFT", Cell.frames.mainFrame, "TOPLEFT", 0, 18)
Cell:StylizeFrame(raidRosterFrame, {.1, .1, .1, .9})
raidRosterFrame:SetSize(405, 230)
raidRosterFrame:EnableMouse(true)
raidRosterFrame:SetFrameStrata("HIGH")
raidRosterFrame:Hide()

local tips = raidRosterFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
tips:SetPoint("BOTTOMLEFT", raidRosterFrame, 5, 5)
tips:SetText("|cff777777"..L["Alt+Right-Click to remove a player"])

-------------------------------------------------
-- sort TODO:
-------------------------------------------------
-- local sortText = Cell:CreateSeparator(L["Raid Sort"], raidRosterFrame, raidRosterFrame:GetWidth()-10)
-- sortText:SetPoint("TOPLEFT", 5, -5)

-- local function SetSubgroup(subgroup, index)

-- end

-- local members = {}
-- local function Sort(maxSubgroup)
--     for i = 1, GetNumGroupMembers() do
--         local name, _, subgroup, _, _, classFileName, _, _, _, _, _, combatRole = GetRaidRosterInfo(i)
--         if subgroup > maxSubgroup then break end

--     end
-- end

-------------------------------------------------
-- roster
-------------------------------------------------
local rosterContainer = CreateFrame("Frame", "CellRaidRosterFrame_Container", raidRosterFrame)
-- Cell:StylizeFrame(rosterContainer, {.1, .1, .1, .5})
-- rosterContainer:SetPoint("BOTTOMLEFT", 5, 5)
rosterContainer:SetPoint("TOPLEFT", 5, -5)
rosterContainer:SetPoint("BOTTOMRIGHT", raidRosterFrame, "TOPRIGHT", -5, -207)

local groups, changed = {}, {}
local movingGrid
local function CreateRaidRosterGrid(parent, index)
    local grid = CreateFrame("Button", parent:GetName().."Unit"..index, parent, "BackdropTemplate")
    grid:SetSize(100, 17)
    Cell:StylizeFrame(grid, {.1, .1, .1, .5})
    grid.color = {.5, .5, .5}

    grid:SetFrameLevel(7)
    
    local roleIcon = grid:CreateTexture(nil, "ARTWORK")
    roleIcon:SetPoint("LEFT", 2, 0)
    roleIcon:SetSize(13, 13)

    local nameText = grid:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    nameText:SetPoint("LEFT", roleIcon, "RIGHT", 2, 0)
    nameText:SetPoint("RIGHT", -2, 0)
    nameText:SetWordWrap(false)
    nameText:SetJustifyH("LEFT")

    -- click
    grid:RegisterForClicks("RightButtonUp")
    grid:SetScript("OnClick", function()
        if IsAltKeyDown() then
            UninviteUnit(grid.name)
        end
    end)

    -- drag
    grid:SetMovable(true)
    grid:RegisterForDrag("LeftButton")
    grid:SetScript("OnDragStart", function()
        grid:SetFrameLevel(9)
        grid:StartMoving()
        grid:SetUserPlaced(false)
        grid:SetBackdropBorderColor(unpack(grid.color))
        grid:SetBackdropColor(.1, .1, .1, .9)
        grid.isMoving = true
        movingGrid = grid
    end)
    grid:SetScript("OnDragStop", function()
        grid:SetFrameLevel(7)
        grid:StopMovingOrSizing()
        grid:ClearAllPoints()
        grid:SetPoint(unpack(grid.point1))
        grid:SetPoint(unpack(grid.point2))
        grid:SetBackdropBorderColor(0, 0, 0, 1)
        grid:SetBackdropColor(.1, .1, .1, .5)
        grid.isMoving = nil
    end)
    
    -- swap
    grid:SetScript("OnShow", function()
        grid:RegisterEvent("GLOBAL_MOUSE_UP")
    end)
    grid:SetScript("OnHide", function()
        grid:UnregisterEvent("GLOBAL_MOUSE_UP")
    end)
    grid:SetScript("OnEvent", function(self, event)
        if movingGrid and movingGrid ~= self and self:IsMouseOver() and not InCombatLockdown() then
            -- immediate mode
            if self.hasUnit then
                -- print("SWAP "..self:GetName().." WITH "..movingGrid:GetName())
                SwapRaidSubgroup(movingGrid.raidIndex, self.raidIndex)
            else
                SetRaidSubgroup(movingGrid.raidIndex, self.subgroup)
            end
            -- TODO: preset mode
            -- if self.hasUnit then
            --     self:SetText(movingGrid.name)
            --     self:SetTextColor(unpack(movingGrid.color))
            --     movingGrid:SetText(self.name)
            --     movingGrid:SetTextColor(unpack(self.color))
            -- end

            movingGrid = nil
        end
    end)

    -- onupdate
    grid:SetScript("OnUpdate", function()
        if not grid.isMoving then
            if grid:IsMouseOver() then
                grid:SetBackdropColor(grid.color[1], grid.color[2], grid.color[3], .2)
            else
                grid:SetBackdropColor(.1, .1, .1, .5)
            end
        end
    end)

    function grid:Set(name, color, role)
        grid.color[1], grid.color[2], grid.color[3] = color[1], color[2], color[3]
        nameText:SetText(name)
        nameText:SetTextColor(unpack(color))
        if role == "NONE" then
            roleIcon:Hide()
        else
            roleIcon:SetTexture("Interface\\AddOns\\Cell\\Media\\Roles\\"..role)
            roleIcon:Show()
        end
    end

    function grid:Reset()
        grid.hasUnit = nil
        grid.raidIndex = nil
        grid.name = nil
        grid.color[1], grid.color[2], grid.color[3] = .5, .5, .5

        nameText:SetText("")
        nameText:SetTextColor(1, 1, 1)
        roleIcon:Hide()

        grid:EnableMouse(false)

        -- reset click
        -- grid:SetAttribute("unit", nil)
        -- grid:SetAttribute("type1", nil)
    end

    function grid:SetInfo(name, classFileName, combatRole, raidIndex)
        if not name then
            -- unknown target, retry
            C_Timer.After(.5, function()
                local name, _, subgroup, _, _, classFileName, _, _, _, _, _, combatRole = GetRaidRosterInfo(raidIndex)
                grid:SetInfo(name, classFileName, combatRole, raidIndex)
            end)
            return
        end
        
        if string.find(name, "-") then name = strsplit("-", name) end

        grid.hasUnit = true
        grid.raidIndex = raidIndex
        grid.name = name
        grid.role = combatRole
        grid.color[1], grid.color[2], grid.color[3] = F:GetClassColor(classFileName)
        
        grid:Set(name, grid.color, combatRole)

        grid:EnableMouse(true)

        -- click
        -- grid:SetAttribute("unit", "raid"..raidIndex)
        -- grid:SetAttribute("type1", "target")
    end

    return grid
end

local function CreateRaidRosterGroup(parent, groupIndex)
    local group = CreateFrame("Frame", parent:GetName().."_Subgroup"..groupIndex, parent, "BackdropTemplate")
    group:SetSize(95, 81)
    Cell:StylizeFrame(group, {.1, .1, .1, .5})

    local headerText = group:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    headerText:SetPoint("BOTTOM", group, "TOP", 0, 1)
    headerText:SetText("|cFFEEC900"..GROUP.." "..groupIndex)

    for i = 1, 5 do
        group[i] = CreateRaidRosterGrid(group, i)
        group[i].point1 = {"TOPLEFT", 0, -(i-1)*16}
        group[i]:SetPoint(unpack(group[i].point1))
        group[i].point2 = {"TOPRIGHT", 0, -(i-1)*16}
        group[i]:SetPoint(unpack(group[i].point2))
        group[i].subgroup = groupIndex
    end

    group.numMembers = 0

    function group:Reset()
        group.numMembers = 0
        for i = 1, 5 do
            group[i]:Reset()
        end
    end

    function group:Insert(name, classFileName, combatRole, raidIndex)
        group.numMembers = group.numMembers + 1
        group[group.numMembers]:SetInfo(name, classFileName, combatRole, raidIndex)
    end

    return group
end

for i = 1, 8 do
    groups[i] = CreateRaidRosterGroup(rosterContainer, i)

    if i % 4 == 1 then
        groups[i]:SetPoint("TOPLEFT", 0, -20-(math.modf(i/4)*(groups[i]:GetHeight()+20)))
    else
        groups[i]:SetPoint("LEFT", groups[i-1], "RIGHT", 5, 0)
    end
end

-------------------------------------------------
-- functions
-------------------------------------------------
Cell:CreateMask(raidRosterFrame, L["You don't have permission to do this"])
raidRosterFrame.mask:Hide()

local function UpdateRoster()
    if movingGrid then
        movingGrid:GetScript("OnDragStop")()
    end

    for i = 1, 8 do
        groups[i]:Reset()
    end

    for i = 1, GetNumGroupMembers() do
        local name, _, subgroup, _, _, classFileName, _, _, _, _, _, combatRole = GetRaidRosterInfo(i)
        groups[subgroup]:Insert(name, classFileName, combatRole, i)
    end
end

local function CheckPermission()
    if UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
        raidRosterFrame.mask:Hide()
    else
        raidRosterFrame.mask:Show()
    end
end

raidRosterFrame:SetScript("OnEvent", function()
    UpdateRoster()
    CheckPermission()
end)

raidRosterFrame:SetScript("OnShow", function()
    raidRosterFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    UpdateRoster()
    CheckPermission()
end)
raidRosterFrame:SetScript("OnHide", function()
    raidRosterFrame:UnregisterEvent("GROUP_ROSTER_UPDATE")
end)

local function GroupTypeChanged(groupType)
    raidRosterFrame:Hide()
end
Cell:RegisterCallback("GroupTypeChanged", "RaidRosterFrame_GroupTypeChanged", GroupTypeChanged)

local function UpdateLayout(layout, which)
    layout = Cell.vars.currentLayoutTable
    if not which or which == "anchor" then
        raidRosterFrame:ClearAllPoints()
        raidRosterFrame:SetPoint(layout["anchor"], Cell.frames.mainFrame)
    end
end
Cell:RegisterCallback("UpdateLayout", "RaidRosterFrame_UpdateLayout", UpdateLayout)

function F:ShowRaidRosterFrame()
    if raidRosterFrame:IsShown() then
        raidRosterFrame:Hide()
    else
        raidRosterFrame:Show()
    end
end