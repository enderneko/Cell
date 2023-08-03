local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs
local A = Cell.animations
local LibTranslit = LibStub("LibTranslit-1.0")
local LCG = LibStub("LibCustomGlow-1.0")

local GetRaidRosterInfo = GetRaidRosterInfo
local SwapRaidSubgroup = SwapRaidSubgroup
local SetRaidSubgroup = SetRaidSubgroup

local LoadRoster, UpdateRoster
local UpdateMode
local PremadeSwap, PremadeSet, PremadeApply, ProcessNext

local groups = {} -- contains girds
local changes = {} -- store subgroup changed member indices
local queue
-- local premadeGroups = {} -- contains member nums of each sub group

local isInstantMode = true
local isProcessing = false
local modeBtn, assistantCB, processingFrame, progressBar, combatTips

local function Reset(reload)
    -- print("RESET", reload)
    queue = nil
    isInstantMode = true
    isProcessing = false
    wipe(changes)
    UpdateMode()

    if reload then
        LoadRoster()
    end
end

-------------------------------------------------
-- raid roster frame
-------------------------------------------------
local raidRosterFrame = Cell:CreateFrame("CellRaidRosterFrame", Cell.frames.mainFrame, 405, 230)
Cell.frames.raidRosterFrame = raidRosterFrame
raidRosterFrame:SetFrameStrata("DIALOG")
raidRosterFrame:SetFrameLevel(5)

local function CreateWidgets()
    -- mode
    modeBtn = Cell:CreateButton(raidRosterFrame, L["Instant Mode"], "accent", {127, 17})
    modeBtn:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\instant", {13, 13}, {"LEFT", 4, 0})
    modeBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    modeBtn:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then -- switch mode / apply changes
            if isInstantMode then
                isInstantMode = false
                UpdateMode()
            else
                if not isProcessing then
                    isProcessing = true
                    PremadeApply()
                end
            end
        
        else -- discard changes
            if isProcessing then
                processingFrame:Hide()
            else
                Reset(true)
            end
        end
    end)

    Cell:SetTooltips(modeBtn, "ANCHOR_TOPRIGHT", 0, 2, 
        "|cffff2727EXPERIMENTAL|r",
        L["No support for rearrangement of members within a same subgroup"],
        L["No guarantee of the order of members in each subgroup"],
        "|cffffb5c5"..L["Left-Click"]..":|r "..L["change mode / apply changes"],
        "|cffffb5c5"..L["Right-Click"]..":|r "..L["discard changes"]
    )

    -- SetEveryoneIsAssistant
    assistantCB = Cell:CreateCheckButton(raidRosterFrame, "|TInterface\\GroupFrame\\UI-Group-AssistantIcon:16:16|t", function(checked)
        SetEveryoneIsAssistant(checked)
    end)
    assistantCB:SetPoint("BOTTOMRIGHT", -25, 5)

    local tips = Cell:CreateScrollTextFrame(raidRosterFrame, "|cffb7b7b7"..L["raidRosterTips"], 0.02, nil, 2)
    tips:SetPoint("BOTTOMLEFT", raidRosterFrame, 5, 2)
    tips:SetPoint("RIGHT", assistantCB, "LEFT", -5, 0)
end

local function UpdateModeBtnPosition()
    local anchor = Cell.vars.currentLayoutTable.main.anchor
    modeBtn:ClearAllPoints()
    if anchor == "TOPLEFT" then
        modeBtn:SetPoint("BOTTOMRIGHT", raidRosterFrame, "TOPRIGHT", 0, 4)
    elseif anchor == "TOPRIGHT" then
        modeBtn:SetPoint("BOTTOMLEFT", raidRosterFrame, "TOPLEFT", 0, 4)
    elseif anchor == "BOTTOMLEFT" then
        modeBtn:SetPoint("TOPRIGHT", raidRosterFrame, "BOTTOMRIGHT", 0, -4)
    elseif anchor == "BOTTOMRIGHT" then
        modeBtn:SetPoint("TOPLEFT", raidRosterFrame, "BOTTOMLEFT", 0, -4)
    end
end

UpdateMode = function()
    -- update button
    if isInstantMode then
        raidRosterFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
        modeBtn:SetText(L["Instant Mode"])
        modeBtn.tex:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\instant")
        LCG.PixelGlow_Stop(modeBtn)
    else
        raidRosterFrame:UnregisterEvent("GROUP_ROSTER_UPDATE")
        modeBtn:SetText(L["Premade Mode"])
        modeBtn.tex:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\premade")
        LCG.PixelGlow_Start(modeBtn, Cell:GetAccentColorTable(1), 12, 0.25, 10, 1)
    end
end

local function CreateProcessingFrame()
    -- processing
    processingFrame = CreateFrame("Frame", nil, raidRosterFrame, "BackdropTemplate")
    processingFrame:SetPoint("TOPLEFT", P:Scale(1), P:Scale(-1))
    processingFrame:SetPoint("BOTTOMRIGHT", P:Scale(-1), P:Scale(1))
    Cell:StylizeFrame(processingFrame, {0.15, 0.15, 0.15, 0.7}, {0, 0, 0, 0})
    processingFrame:SetFrameLevel(raidRosterFrame:GetFrameLevel()+30)
    processingFrame:EnableMouse(true)
    processingFrame:Hide()

    processingFrame:SetScript("OnShow", function()
        processingFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
        ProcessNext()
    end)

    processingFrame:SetScript("OnHide", function()
        processingFrame:Hide()
        processingFrame:UnregisterAllEvents()
        Reset(true)
    end)

    processingFrame:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_REGEN_ENABLED" then
            processingFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
            combatTips:Hide()
        end
        ProcessNext()
    end)

    A:CreateFadeOut(processingFrame, 1, 0, 0.5, 0.5)

    -- progress bar
    progressBar = Cell:CreateStatusBar(nil, processingFrame, 1, 1, 100, true, nil, true, "Interface\\AddOns\\Cell\\Media\\statusbar", Cell:GetAccentColorTable())
    progressBar:SetPoint("TOPLEFT", 10, -103)
    progressBar:SetPoint("BOTTOMRIGHT", -10, 102)

    -- combat tips
    combatTips = processingFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    combatTips:SetPoint("TOP", progressBar, "BOTTOM", 0, -5)
    combatTips:SetTextColor(1, 0.2, 0.2)
    combatTips:SetText(L["Waiting for combat to end..."])
    combatTips:Hide()
end

-------------------------------------------------
-- premade
-------------------------------------------------
PremadeSwap = function(grid1, grid2)
    if grid1.subgroup == grid2.subgroup and grid1._subgroup == grid2._subgroup then
        -- NOTE: in same group, don't swap
        return
    end

    local tempPoint1 = grid1._point1 or grid1.point1
    local tempPoint2 = grid1._point2 or grid1.point2

    grid1._point1 = grid2._point1 or grid2.point1
    grid1._point2 = grid2._point2 or grid2.point2
    grid2._point1 = tempPoint1
    grid2._point2 = tempPoint2
    
    local anchor1 = grid1._subgroup and groups[grid1._subgroup] or groups[grid1.subgroup]
    local anchor2 = grid2._subgroup and groups[grid2._subgroup] or groups[grid2.subgroup]

    grid1._anchor = anchor2
    grid2._anchor = anchor1

    grid1:ClearAllPoints()
    grid1:SetPoint(grid1._point1[1], anchor2, grid1._point1[2], grid1._point1[3])
    grid1:SetPoint(grid1._point2[1], anchor2, grid1._point2[2], grid1._point2[3])
    
    grid2:ClearAllPoints()
    grid2:SetPoint(grid2._point1[1], anchor1, grid2._point1[2], grid2._point1[3])
    grid2:SetPoint(grid2._point2[1], anchor1, grid2._point2[2], grid2._point2[3])

    local subgroup = grid1._subgroup or grid1.subgroup
    grid1._subgroup = grid2._subgroup or grid2.subgroup
    grid2._subgroup = subgroup

    local index = grid1._index or grid1.index
    grid1._index = grid2._index or grid2.index
    grid2._index = index

    if grid1.hasUnit then
        if grid1._subgroup ~= grid1.subgroup then
            changes[grid1.fullName] = {grid1._subgroup, grid1._index, grid2.fullName}
        else
            changes[grid1.fullName] = nil
        end
    end

    if grid2.hasUnit then
        if grid2._subgroup ~= grid2.subgroup then
            changes[grid2.fullName] = {grid2._subgroup, grid2._index, grid1.fullName}
        else
            changes[grid2.fullName] = nil
        end
    end
end

PremadeSet = function(grid, emptyGrid)
    -- premadeGroups[grid._subgroup or grid.subgroup] = premadeGroups[grid._subgroup or grid.subgroup] - 1
    -- premadeGroups[emptyGrid._subgroup or emptyGrid.subgroup] = premadeGroups[emptyGrid._subgroup or emptyGrid.subgroup] + 1
    
    PremadeSwap(grid, emptyGrid)
end

ProcessNext = function()
    -- print("ProcessNext", queue and queue[1] or nil)
    if queue and queue[1] then
        local noAction = true

        local next = queue[1]
        local fromIndex, fromSubgroup = F:GetRaidInfoByName(next)

        local targetSubgroup = changes[next][1]
        local targetIndex = changes[next][2] -- index in subgroup, not raidIndex
        local targetPlayer = changes[next][3]

        if fromIndex then -- "next" still in raid
            local targetPlayerTarget = changes[targetPlayer] and changes[targetPlayer][3] or nil
            local toIndex, toName = F:GetRaidInfoBySubgroupIndex(targetSubgroup, targetIndex)

            -- print(next, "raidIndex:", fromIndex, "subgroup:", fromSubgroup.."->"..targetSubgroup, "targetIndex:", targetIndex, "targetPlayer:", targetPlayer, targetPlayerTarget)
            
            if toIndex and targetPlayerTarget == next then -- NOTE: unit to be swapped with exists, and requires a swap with "next"
                if fromIndex ~= toIndex then
                    if not InCombatLockdown() then
                        noAction = false
                        SwapRaidSubgroup(fromIndex, toIndex)
                    else
                        processingFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
                        combatTips:Show()
                        return
                    end
                end
            else  -- NOTE: non-full subgroup, set
                if fromSubgroup ~= targetSubgroup and F:GetNumSubgroupMembers(targetSubgroup) < 5 then
                    if not InCombatLockdown() then
                        noAction = false
                        SetRaidSubgroup(fromIndex, targetSubgroup)
                    else
                        processingFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
                        combatTips:Show()
                        return
                    end
                end
            end
        end

        tremove(queue, 1)
        progressBar.value = progressBar.value + 1
        progressBar:SetSmoothedValue(progressBar.value)

        -- NOTE: run next immediately
        if noAction then
            ProcessNext()
        end
    else
        processingFrame:FadeOut()
    end
end

PremadeApply = function()
    queue = F:GetKeys(changes)
    local n = #queue
    if n ~= 0 then
        progressBar:SetMaxValue(n)
        progressBar:SetValue(0)
        progressBar.value = 0
        -- texplore(queue)
        processingFrame:Show()
    else
        Reset(true)
    end
end

-------------------------------------------------
-- roster
-------------------------------------------------
local movingGrid
local function CreateRaidRosterGrid(parent, index)
    local grid = CreateFrame("Button", parent:GetName().."Unit"..index, parent, "BackdropTemplate")
    P:Size(grid, 100, 17)
    Cell:StylizeFrame(grid, {0.1, 0.1, 0.1, 0.5})
    grid.color = {0.5, 0.5, 0.5}

    grid:SetFrameLevel(7)
    
    local roleIconBg = grid:CreateTexture(nil, "BORDER")
    roleIconBg:SetPoint("TOPLEFT", 2, -2)
    roleIconBg:SetSize(13, 13)
    roleIconBg:SetColorTexture(0, 0, 0, 1)

    local roleIcon = grid:CreateTexture(nil, "ARTWORK")
    roleIcon:SetPoint("TOPLEFT", roleIconBg, P:Scale(1), P:Scale(-1))
    roleIcon:SetPoint("BOTTOMRIGHT", roleIconBg, P:Scale(-1), P:Scale(1))
    roleIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    local nameText = grid:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    nameText:SetPoint("LEFT", roleIcon, "RIGHT", 2, 0)
    nameText:SetPoint("RIGHT", -2, 0)
    nameText:SetWordWrap(false)
    nameText:SetJustifyH("LEFT")

    -- click
    grid:RegisterForClicks("RightButtonDown")
    grid:SetScript("OnClick", function()
        if IsAltKeyDown() then
            UninviteUnit(grid.name)
        else
            if not UnitIsGroupLeader("player") then return end
            
            if UnitIsGroupLeader(grid.unit) then return end

            if UnitIsGroupAssistant(grid.unit) then
                DemoteAssistant(grid.unit)
            else
                PromoteToAssistant(grid.unit)
            end
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
        grid:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
        grid.isMoving = true
        movingGrid = grid
    end)
    grid:SetScript("OnDragStop", function()
        grid:SetFrameLevel(7)
        grid:StopMovingOrSizing()
        grid:ClearAllPoints()
        if grid._anchor then
            grid:SetPoint(grid._point1[1], grid._anchor, grid._point1[2], grid._point1[3])
            grid:SetPoint(grid._point2[1], grid._anchor, grid._point2[2], grid._point2[3])
        else
            grid:SetPoint(unpack(grid.point1))
            grid:SetPoint(unpack(grid.point2))
        end
        grid:SetBackdropBorderColor(0, 0, 0, 1)
        grid:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
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
        if movingGrid and movingGrid ~= self and self:IsMouseOver() then
            if isInstantMode then
                if not InCombatLockdown() then
                    if self.hasUnit then
                        -- print("SWAP "..self:GetName().." WITH "..movingGrid:GetName())
                        SwapRaidSubgroup(movingGrid.raidIndex, self.raidIndex)
                    else
                        SetRaidSubgroup(movingGrid.raidIndex, self.subgroup)
                    end
                end
            else
                if self.hasUnit then
                    PremadeSwap(movingGrid, self)
                else
                    PremadeSet(movingGrid, self)
                end
            end
            movingGrid = nil
        end
    end)

    -- onupdate
    grid:SetScript("OnUpdate", function()
        if not grid.isMoving then
            if grid:IsMouseOver() then
                grid:SetBackdropColor(grid.color[1], grid.color[2], grid.color[3], 0.2)
            else
                grid:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
            end
        end
    end)

    function grid:Update()
        nameText:SetText(grid.name)
        nameText:SetTextColor(unpack(grid.color))

        roleIcon:Show()
        roleIconBg:Show()
        if role == "NONE" then
            roleIcon:SetTexture(134400)
        else
            roleIcon:SetTexture("Interface\\AddOns\\Cell\\Media\\Roles\\"..grid.role)
        end

        if grid.isLeader then
            roleIconBg:SetColorTexture(1, 0.84, 0, 1)
        elseif grid.isAssistant then
            roleIconBg:SetColorTexture(0.7, 0.7, 0.7, 1)
        else
            roleIconBg:SetColorTexture(0, 0, 0, 1)
        end
    end

    function grid:Reset()
        F:RemoveElementsByKeys(grid,
            "hasUnit", "raidIndex", "unit", "fullName", "name", "role", "isLeader", "isAssistant",
            "_subgroup", "_index", "_point1", "_point2", "_anchor" -- premade temps
        )
        grid.color[1], grid.color[2], grid.color[3] = 0.5, 0.5, 0.5

        nameText:SetText("")
        nameText:SetTextColor(1, 1, 1)
        roleIconBg:SetColorTexture(0, 0, 0, 1)
        roleIconBg:Hide()
        roleIcon:Hide()

        grid:ClearAllPoints()
        grid:SetPoint(unpack(grid.point1))
        grid:SetPoint(unpack(grid.point2))

        grid:EnableMouse(false)
    end

    function grid:Set(raidIndex)
        local name, _, subgroup, _, _, classFileName, _, _, _, _, _, combatRole = GetRaidRosterInfo(raidIndex)
        
        if not name then
            -- unknown target, retry
            C_Timer.After(0.5, function()
                grid:Set(raidIndex)
            end)
            return
        end
        

        
        -- save
        grid.fullName = name -- contains server name for cross-realm players
        
        if string.find(name, "-") then
            name = strsplit("-", name)
        end

        if CellDB["general"]["translit"] then
            name = LibTranslit:Transliterate(name)
        end
        
        grid.hasUnit = true
        grid.raidIndex = raidIndex
        grid.unit = "raid"..raidIndex
        grid.name = name
        grid.role = combatRole
        grid.color[1], grid.color[2], grid.color[3] = F:GetClassColor(classFileName)
        grid.isLeader = UnitIsGroupLeader(grid.unit)
        grid.isAssistant = UnitIsGroupAssistant(grid.unit)

        -- update
        grid:Update()
        grid:EnableMouse(true)
    end

    return grid
end

local function CreateRaidRosterGroup(parent, groupIndex)
    local group = CreateFrame("Frame", parent:GetName().."Subgroup"..groupIndex, parent, "BackdropTemplate")
    P:Size(group, 95, 81)
    Cell:StylizeFrame(group, {0.1, 0.1, 0.1, 0.5})

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
        group[i].index = i
    end

    group.numMembers = 0

    function group:Reset()
        group.numMembers = 0
        for i = 1, 5 do
            group[i]:Reset()
        end
    end

    function group:Insert(raidIndex)
        group.numMembers = group.numMembers + 1
        group[group.numMembers]:Set(raidIndex)
    end

    return group
end

local function CreateRosterContainer()
    local rosterContainer = CreateFrame("Frame", "CellRaidRosterFrameContainer", raidRosterFrame)
    rosterContainer:SetPoint("TOPLEFT", 5, -5)
    rosterContainer:SetPoint("BOTTOMRIGHT", raidRosterFrame, "TOPRIGHT", -5, -207)

    for i = 1, 8 do
        groups[i] = CreateRaidRosterGroup(rosterContainer, i)
    
        if i % 4 == 1 then
            groups[i]:SetPoint("TOPLEFT", 0, -20-(math.modf(i/4)*(groups[i]:GetHeight()+20)))
        else
            groups[i]:SetPoint("TOPLEFT", groups[i-1], "TOPRIGHT", 5, 0)
        end
    end
end

-------------------------------------------------
-- functions
-------------------------------------------------
LoadRoster = function()
    if movingGrid then
        movingGrid:GetScript("OnDragStop")()
    end

    -- reset
    for i = 1, 8 do
        groups[i]:Reset()
        -- premadeGroups[i] = 0
    end

    -- insert
    for i = 1, GetNumGroupMembers() do
        local subgroup = select(3, GetRaidRosterInfo(i))
        groups[subgroup]:Insert(i)
        -- premadeGroups[subgroup] = premadeGroups[subgroup] + 1
    end
end

UpdateRoster = function()

end

-------------------------------------------------
-- scripts
-------------------------------------------------
local function CheckPermission()
    if UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
        if raidRosterFrame.mask then raidRosterFrame.mask:Hide() end
    else
        Cell:CreateMask(raidRosterFrame, L["You don't have permission to do this"], {1, -1, -1, 1})
    end
end

raidRosterFrame:SetScript("OnEvent", function()
    LoadRoster()
    CheckPermission()
    assistantCB:SetChecked(IsEveryoneAssistant())
end)

raidRosterFrame:SetScript("OnShow", function()
    raidRosterFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    LoadRoster()
    CheckPermission()
    assistantCB:SetChecked(IsEveryoneAssistant())
end)

raidRosterFrame:SetScript("OnHide", function()
    raidRosterFrame:UnregisterEvent("GROUP_ROSTER_UPDATE")
    Reset()
end)

-------------------------------------------------
-- callbacks
-------------------------------------------------
local function GroupTypeChanged(groupType)
    raidRosterFrame:Hide()
end
Cell:RegisterCallback("GroupTypeChanged", "RaidRosterFrame_GroupTypeChanged", GroupTypeChanged)

local function UpdateLayout(layout, which)
    layout = Cell.vars.currentLayoutTable
    if not which or which == "main-arrangement" then
        raidRosterFrame:ClearAllPoints()
        raidRosterFrame:SetPoint(layout["main"]["anchor"], Cell.frames.mainFrame)

        if modeBtn then UpdateModeBtnPosition() end
    end
end
Cell:RegisterCallback("UpdateLayout", "RaidRosterFrame_UpdateLayout", UpdateLayout)

-------------------------------------------------
-- show
-------------------------------------------------
local init
function F:ShowRaidRosterFrame()
    if not init then
        init = true
        raidRosterFrame:UpdatePixelPerfect()
        CreateWidgets()
        CreateProcessingFrame()
        UpdateModeBtnPosition()
        CreateRosterContainer()
    end

    if raidRosterFrame:IsShown() then
        raidRosterFrame:Hide()
    else
        raidRosterFrame:Show()
        -- texplore(changes)
    end
end