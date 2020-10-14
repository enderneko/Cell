local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

local debuffsTab = Cell:CreateFrame("CellOptionsFrame_RaidDebuffsTab", Cell.frames.optionsFrame, nil, nil, true)
Cell.frames.raidDebuffsTab = debuffsTab
debuffsTab:SetAllPoints(Cell.frames.optionsFrame)
debuffsTab:Hide()

local newestExpansion, loadedExpansion, loadedInstance, loadedBoss
local LoadExpansion, ShowInstances, ShowBosses, ShowDebuffs, ShowDetails, ShowImage, HideImage, OpenEncounterJournal
-------------------------------------------------
-- prepare debuff list
-------------------------------------------------
-- NOTE: instanceId is instanceEncounterJournalId
-- mapId = C_Map.GetBestMapForUnit("player")
-- instanceId = EJ_GetInstanceForMap(mapId)
-- instanceName, ... = EJ_GetInstanceInfo(instanceId)

-- used for sort list buttons
local encounterJournalList = {
    -- ["expansionName"] = {
    --     {
    --         ["name"] = instanceName,
    --         ["id"] = instanceId,
    --         ["bosses"] = {
    --             {["name"]=name, ["id"]=id, ["image"]=image},
    --         },
    --     },
    -- },
}

local instanceIds = { -- used for GetInstanceInfo/GetRealZoneText --> instanceId
    -- [instanceName] = expansionName:instanceId,
}

local function LoadBossList(instanceId, list)
    EJ_SelectInstance(instanceId)
    for index = 1, 77 do
		local name, _, id = EJ_GetEncounterInfoByIndex(index)
		if not name or not id then
			break
        end
        
        -- id, name, description, displayInfo, iconImage, uiModelSceneID = EJ_GetCreatureInfo(index [, encounterID])
        local image = select(5, EJ_GetCreatureInfo(1, id))
        tinsert(list, {["name"]=name, ["id"]=id, ["image"]=image})
	end
end

local function LoadInstanceList(tier, instanceType, list)
    local isRaid = instanceType == "raid"
    for index = 1, 77 do
        EJ_SelectTier(tier)
        local id, name = EJ_GetInstanceByIndex(index, isRaid)
        if not id or not name then
            break
        end

        local eName = EJ_GetTierInfo(tier)
        instanceIds[name] = eName..":"..id -- NOTE: used for searching current zone debuffs
        local instanceTable = {["name"]=name, ["id"]=id, ["bosses"]={}}
        tinsert(list, instanceTable)

        LoadBossList(id, instanceTable["bosses"])
    end
end

local function LoadList()
    for tier = 1, EJ_GetNumTiers() do
        local name = EJ_GetTierInfo(tier)
        encounterJournalList[name] = {}

        LoadInstanceList(tier, "raid", encounterJournalList[name])
        LoadInstanceList(tier, "party", encounterJournalList[name])

        newestExpansion = name
    end
end

LoadExpansion = function(eName)
    if loadedExpansion == eName then return end
    loadedExpansion = eName
    -- show then first boss of the first instance of the expansion
    ShowInstances(eName)

end

local unsortedDebuffs = {}
function F:LoadBuiltInDebuffs(debuffs)
    for instanceId, iTable in pairs(debuffs) do
        unsortedDebuffs[instanceId] = iTable
    end
end

-- local function LoadBuiltInDebuffs()
--     for eName, eTable in pairs(loadedDebuffs) do
--         for instanceId, iTable in pairs(eTable) do
--             if encounterJournalList[eName][instanceId] then -- valid instance
--                 for encounterId, debuffTable in pairs(iTable) do
--                     if encounterId == "general" then -- general debuffs
                        
--                     elseif encounterJournalList[eName][instanceId][encounterId] then -- valid boss
--                         for _, spellId in pairs(debuffTable) do
--                             encounterJournalList[eName][instanceId][encounterId][spellId] = {true}
--                         end
--                     end
--                 end                 
--             end
--         end
--     end
-- end

local loadedDebuffs = {
    -- [instanceId] = {
    --     ["general"] = {
    --         {["id"]=spellId, ["trackById"]=trackById, ["glow"]=glow, ["glowColor"]=glowColor}
    --     },
    --     [bossId] = {
    --         {["id"]=spellId, ["trackById"]=trackById, ["glow"]=glow, ["glowColor"]=glowColor}
    --     },
    -- },
}

local function LoadDebuffs()
    -- check db
    for instanceId, iTable in pairs(CellDB["raidDebuffs"]) do
        if not loadedDebuffs[instanceId] then loadedDebuffs[instanceId] = {} end

        for bossId, bTable in pairs(iTable) do
            if not loadedDebuffs[instanceId][bossId] then loadedDebuffs[instanceId][bossId] = {} end
            -- load from db and set its order
            for spellId, sTable in pairs(bTable) do
                local t = {["id"]=spellId, ["order"]=sTable[1], ["trackById"]=sTable[2], ["glow"]=sTable[3], ["glowColor"]=sTable[4]}
                if sTable[1] == 0 then
                    tinsert(loadedDebuffs[instanceId][bossId], 100, t) -- disabled
                else
                    tinsert(loadedDebuffs[instanceId][bossId], sTable[1], t)
                end
            end
        end
    end

    -- check built-in
    for instanceId, iTable in pairs(unsortedDebuffs) do
        if not loadedDebuffs[instanceId] then loadedDebuffs[instanceId] = {} end

        for bossId, bTable in pairs(iTable) do
            if not loadedDebuffs[instanceId][bossId] then loadedDebuffs[instanceId][bossId] = {} end
            -- load
            for i, spellId in pairs(bTable) do
                if not (CellDB["raidDebuffs"][instanceId] and CellDB["raidDebuffs"][instanceId][bossId] and CellDB["raidDebuffs"][instanceId][bossId][spellId]) then
                    tinsert(loadedDebuffs[instanceId][bossId], {["id"]=spellId})
                end
            end
        end
    end

    -- if unsortedDebuffs[instanceId] and unsortedDebuffs[instanceId][bossId] then -- exists in built-in
    --     for i, spellId in pairs(unsortedDebuffs[instanceId][bossId]) do
            
    --     end
    -- end
end

local function UpdateRaidDebuffs()
    LoadList()
    LoadDebuffs()
end
Cell:RegisterCallback("UpdateRaidDebuffs", "RaidDebuffsTab_UpdateRaidDebuffs", UpdateRaidDebuffs)

-------------------------------------------------
-- expansion dropdown
-------------------------------------------------
local expansionDropdown = Cell:CreateDropdown(debuffsTab, 120)
expansionDropdown:SetPoint("TOPLEFT", 5, -5)

local expansionItems = {}
for i = 1, EJ_GetNumTiers() do
    local eName = EJ_GetTierInfo(i)
    tinsert(expansionItems, {
        ["text"] = eName,
        ["onClick"] = function()
            LoadExpansion(eName)
        end,
    })
end
expansionDropdown:SetItems(expansionItems)
expansionDropdown:SetSelectedItem(#expansionItems)

local tips = Cell:CreateScrollTextFrame(debuffsTab, "|cff777777"..L["Tips: Double-click on instance name to open Encounter Journal. These debuffs will be displayed with the Central Debuff indicator. The priority of General Debuffs is higher than Boss Debuffs."], 0.02)
tips:SetPoint("TOPLEFT", expansionDropdown, "TOPRIGHT", 5, 0)
tips:SetPoint("RIGHT", -5, 0)

-------------------------------------------------
-- onEnter, onLeave
-------------------------------------------------
local function SetOnEnterLeave(frame)
    frame:SetScript("OnEnter", function()
        frame:SetBackdropBorderColor(unpack(Cell:GetPlayerClassColor()))
        frame.scrollFrame.scrollbar:SetBackdropBorderColor(unpack(Cell:GetPlayerClassColor()))
        -- frame.scrollFrame.scrollThumb:SetBackdropBorderColor(0, 0, 0, .5)
    end)
    frame:SetScript("OnLeave", function()
        frame:SetBackdropBorderColor(0, 0, 0, 1)
        frame.scrollFrame.scrollbar:SetBackdropBorderColor(0, 0, 0, 1)
        frame.scrollFrame.scrollThumb:SetBackdropBorderColor(0, 0, 0, 1)
    end)
end

-------------------------------------------------
-- instances frame
-------------------------------------------------
local instancesFrame = Cell:CreateFrame("RaidDebuffsTab_Instances", debuffsTab, 120, 172)
instancesFrame:SetPoint("TOPLEFT", expansionDropdown, "BOTTOMLEFT", 0, -5)
-- instancesFrame:SetPoint("BOTTOMLEFT", 5, 5)
instancesFrame:Show()
Cell:CreateScrollFrame(instancesFrame)
instancesFrame.scrollFrame:SetScrollStep(19)
SetOnEnterLeave(instancesFrame)

local instanceButtons = {}
ShowInstances = function(eName)
    instancesFrame.scrollFrame:ResetScroll()

    for i, iTable in pairs(encounterJournalList[eName]) do
        if not instanceButtons[i] then
            instanceButtons[i] = Cell:CreateButton(instancesFrame.scrollFrame.content, iTable["name"], "transparent-class", {20, 20})
        else
            instanceButtons[i]:SetText(iTable["name"])
            instanceButtons[i]:Show()
        end

        instanceButtons[i].id = iTable["id"].."-"..i -- send instanceId-instanceIndex to ShowBosses
        
        -- open encounter journal
        instanceButtons[i]:SetScript("OnDoubleClick", function()
            OpenEncounterJournal(iTable["id"])
        end)

        if i == 1 then
            instanceButtons[i]:SetPoint("TOPLEFT")
        else
            instanceButtons[i]:SetPoint("TOPLEFT", instanceButtons[i-1], "BOTTOMLEFT", 0, 1)
        end
        instanceButtons[i]:SetPoint("RIGHT")
    end

    local n = #encounterJournalList[eName]

    -- update scrollFrame content height
    instancesFrame.scrollFrame:SetContentHeight(20, n, -1)

    -- hide unused instance buttons
    for i = n+1, #instanceButtons do
        instanceButtons[i]:Hide()
        instanceButtons[i]:ClearAllPoints()
    end

    -- set onclick
    Cell:CreateButtonGroup(instanceButtons, ShowBosses, nil, nil, instancesFrame:GetScript("OnEnter"), instancesFrame:GetScript("OnLeave"))
    instanceButtons[1]:Click()
end

-------------------------------------------------
-- bosses frame
-------------------------------------------------
local bossesFrame = Cell:CreateFrame("RaidDebuffsTab_Bosses", debuffsTab, 120, 191)
-- bossesFrame:SetPoint("TOPLEFT", instancesFrame, "BOTTOMLEFT", 0, -5)
bossesFrame:SetPoint("BOTTOMLEFT", 5, 5)
bossesFrame:Show()
Cell:CreateScrollFrame(bossesFrame)
bossesFrame.scrollFrame:SetScrollStep(19)
SetOnEnterLeave(bossesFrame)

local bossButtons = {}
ShowBosses = function(instanceId)
    local iId, iIndex = F:SplitToNumber("-", instanceId)

    if loadedInstance == iId then return end
    loadedInstance = iId

    bossesFrame.scrollFrame:ResetScroll()

    -- instance general debuff
    if not bossButtons[0] then
        bossButtons[0] = Cell:CreateButton(bossesFrame.scrollFrame.content, L["General"], "transparent-class", {20, 20})
        bossButtons[0]:SetPoint("TOPLEFT")
        bossButtons[0]:SetPoint("RIGHT")
    end
    bossButtons[0].id = iId
    
    -- bosses
    for i, bTable in pairs(encounterJournalList[loadedExpansion][iIndex]["bosses"]) do
        if not bossButtons[i] then
            bossButtons[i] = Cell:CreateButton(bossesFrame.scrollFrame.content, bTable["name"], "transparent-class", {20, 20})
        else
            bossButtons[i]:SetText(bTable["name"])
            bossButtons[i]:Show()
        end

        bossButtons[i].id = bTable["id"].."-"..i -- send bossId-bossIndex to ShowDebuffs

        bossButtons[i]:SetPoint("TOPLEFT", bossButtons[i-1], "BOTTOMLEFT", 0, 1)
        bossButtons[i]:SetPoint("RIGHT")
    end

    local n = #encounterJournalList[loadedExpansion][iIndex]["bosses"]

    -- update scrollFrame content height
    bossesFrame.scrollFrame:SetContentHeight(20, n+1, -1)

    -- hide unused instance buttons
    for i = n+1, #bossButtons do
        bossButtons[i]:Hide()
        bossButtons[i]:ClearAllPoints()
    end

    -- set onclick/onenter
    Cell:CreateButtonGroup(bossButtons, ShowDebuffs, nil, nil, function(b)
        if b.id ~= iId then -- not General
            local _, bIndex = F:SplitToNumber("-", b.id)
            ShowImage(encounterJournalList[loadedExpansion][iIndex]["bosses"][bIndex]["image"], b)
        end
        bossesFrame:GetScript("OnEnter")()
    end, function(b)
        HideImage()
        bossesFrame:GetScript("OnLeave")()
    end)

    -- show General by default
    bossButtons[0]:Click()
end

-------------------------------------------------
-- boss image frame
-------------------------------------------------
local imageFrame = Cell:CreateFrame("RaidDebuffsTab_Image", debuffsTab, 128, 64, true)
imageFrame.bg = imageFrame:CreateTexture(nil, "BACKGROUND")
imageFrame.bg:SetTexture("Interface\\Buttons\\WHITE8x8")
imageFrame.bg:SetGradientAlpha("HORIZONTAL", .1, .1, .1, 0, .1, .1, .1, 1)
imageFrame.bg:SetAllPoints(imageFrame)

imageFrame.tex = imageFrame:CreateTexture(nil, "ARTWORK")
imageFrame.tex:SetSize(128, 64)
imageFrame.tex:SetPoint("TOPRIGHT")

ShowImage = function(image, b)
    imageFrame.tex:SetTexture(image)
    imageFrame:ClearAllPoints()
    imageFrame:SetPoint("BOTTOMRIGHT", b, "BOTTOMLEFT", -5, 0)
    imageFrame:Show()
end

HideImage = function()
    imageFrame:Hide()
end

-------------------------------------------------
-- debuff list frame
-------------------------------------------------
local debuffListFrame = Cell:CreateFrame("RaidDebuffsTab_Debuffs", debuffsTab, 120, 341)
debuffListFrame:SetPoint("TOPLEFT", instancesFrame, "TOPRIGHT", 5, 0)
debuffListFrame:Show()
Cell:CreateScrollFrame(debuffListFrame)
debuffListFrame.scrollFrame:SetScrollStep(19)
SetOnEnterLeave(debuffListFrame)


local create = Cell:CreateButton(debuffsTab, L["Create"], "class-hover", {58, 20})
create:SetPoint("TOPLEFT", debuffListFrame, "BOTTOMLEFT", 0, -5)

local delete = Cell:CreateButton(debuffsTab, L["Delete"], "class-hover", {57, 20})
delete:SetPoint("LEFT", create, "RIGHT", 5, 0)
delete:SetEnabled(false)

local enableAll = Cell:CreateButton(debuffsTab, L["Enable All"], "class-hover", {66, 20})
enableAll:SetPoint("LEFT", delete, "RIGHT", 5, 0)

local disableAll = Cell:CreateButton(debuffsTab, L["Disable All"], "class-hover", {66, 20})
disableAll:SetPoint("LEFT", enableAll, "RIGHT", 5, 0)

local debuffButtons = {}
ShowDebuffs = function(bossId)
    local bId, bIndex = F:SplitToNumber("-", bossId)

    if loadedBoss == bId then return end
    loadedBoss = bId

    debuffListFrame.scrollFrame:ResetScroll()
    
    local t, debuffsFound
    if loadedDebuffs[loadedInstance] then
        if bId == loadedInstance then -- General
            t = loadedDebuffs[loadedInstance]["general"]
            if t then debuffsFound = true end
        else
            t = loadedDebuffs[loadedInstance][bId]
            if t then debuffsFound = true end
        end
    end

    local n = 0
    if debuffsFound then
        for i, sTable in pairs(t) do
            if not debuffButtons[i] then
                debuffButtons[i] = Cell:CreateButton(debuffListFrame.scrollFrame.content, sTable["id"], "transparent-class", {20, 20})

                debuffButtons[i]:SetMovable(true)
                debuffButtons[i]:RegisterForDrag("LeftButton")
                debuffButtons[i]:SetScript("OnDragStart", function(self)
                    self:SetFrameLevel(9)
                    self:StartMoving()
                    self:SetUserPlaced(false)
                    -- self:SetBackdropBorderColor(unpack(self.color))
                    -- self:SetBackdropColor(.1, .1, .1, .9)
                    self.isMoving = true
                    -- movingGrid = self
                end)
                debuffButtons[i]:SetScript("OnDragStop", function(self)
                    self:SetFrameLevel(7)
                    self:StopMovingOrSizing()
                    self:ClearAllPoints()
                    self:SetPoint(unpack(self.point1))
                    self:SetPoint(self.point2)
                    -- self:SetBackdropBorderColor(0, 0, 0, 1)
                    -- self:SetBackdropColor(.1, .1, .1, .5)
                    self.isMoving = nil
                end)
            else
                debuffButtons[i]:SetText(sTable["id"])
                debuffButtons[i]:Show()
            end

            debuffButtons[i].id = sTable["id"].."-"..i -- send spellId-spellIndex to ShowDetails

            if i == 1 then
                debuffButtons[i]:SetPoint("TOPLEFT")
                debuffButtons[i].point1 = {"TOPLEFT"}
            else
                debuffButtons[i]:SetPoint("TOPLEFT", debuffButtons[i-1], "BOTTOMLEFT", 0, 1)
                debuffButtons[i].point1 = {"TOPLEFT", debuffButtons[i-1], "BOTTOMLEFT", 0, 1}
            end
            debuffButtons[i]:SetPoint("RIGHT")
            debuffButtons[i].point2 = "RIGHT"

        end
        n = #t
    end
    
    -- update scrollFrame content height
    debuffListFrame.scrollFrame:SetContentHeight(20, n, -1)

    -- hide unused instance buttons
    for i = n+1, #debuffButtons do
        debuffButtons[i]:Hide()
        debuffButtons[i]:ClearAllPoints()
    end

    -- set onclick
    Cell:CreateButtonGroup(debuffButtons, ShowDetails, nil, nil, function(b)
    end, function(b)
    end)

    if debuffButtons[1] then debuffButtons[1]:Click() end
end

-------------------------------------------------
-- debuff details frame
-------------------------------------------------
local detailsFrame = Cell:CreateFrame("RaidDebuffsTab_DebuffDetails", debuffsTab)
detailsFrame:SetPoint("TOPLEFT", debuffListFrame, "TOPRIGHT", 5, 0)
detailsFrame:SetPoint("BOTTOMRIGHT", -5, 30)
detailsFrame:Show()
Cell:CreateScrollFrame(detailsFrame)
SetOnEnterLeave(detailsFrame)

ShowDetails = function(spellId)

end

-------------------------------------------------
-- open encounter journal -- from grid2
-------------------------------------------------
OpenEncounterJournal = function(instanceId)
    if not IsAddOnLoaded("Blizzard_EncounterJournal") then LoadAddOn("Blizzard_EncounterJournal") end
    
	local difficulty
	if IsInInstance() then
		difficulty = select(3,GetInstanceInfo())
	else
		difficulty = 14
    end

	ShowUIPanel(EncounterJournal)
	EJ_ContentTab_Select(EncounterJournal.instanceSelect.dungeonsTab.id)
	EncounterJournal_DisplayInstance(instanceId)
    EncounterJournal.lastInstance = instanceId
    
	if not EJ_IsValidInstanceDifficulty(difficulty) then
		difficulty = (difficulty==14 and 1) or (difficulty==15 and 2) or (difficulty==16 and 23) or (difficulty==17 and 7) or 0
		if not EJ_IsValidInstanceDifficulty(difficulty) then
			return
		end
	end
	EJ_SetDifficulty(difficulty)
	EncounterJournal.lastDifficulty = difficulty
end


-------------------------------------------------
-- register for current instance
-------------------------------------------------
local function GetInstanceDebuffs(mapId)
    
end

local function GetInstanceName(instanceId)

end

local list = {}
local function GetList()

end

local function GetCurrentInstanceId()
    
end

-------------------------------------------------
-- show
-------------------------------------------------
local function ShowTab(tab)
    if tab == "debuffs" then
        debuffsTab:Show()
        
        -- local ei = instanceIds[F:GetInstanceName()]
        -- if ei then
        --     local expansionName, instanceId = strsplit(":", ei)
        --     instanceId = tonumber(instanceId)
        --     if loadedInstance ~= instanceId then -- current loaded instance is not where player is.
        --         F:Debug("ShowDebuffs: "..expansionName..":"..instanceId)
        --         LoadExpansion(expansionName)
        --         for i, iTable in pairs(encounterJournalList[expansionName]) do
        --             if iTable["id"] == instanceId then
        --                 C_Timer.After(.5, function() instanceButtons[i]:Click() end)
        --                 break
        --             end
        --         end
        --     end
        if not loadedExpansion then
            LoadExpansion(newestExpansion)
        end
    else
        debuffsTab:Hide()
    end
end
Cell:RegisterCallback("ShowOptionsTab", "RaidDebuffsTab_ShowTab", ShowTab)