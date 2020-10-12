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

local debuffList = {
    -- ["expansionName"] = {
    --     [instanceId] = {
    --         ["name"] = "instanceName",
    --         ["general"] = { -- priority higher than bosses
    --             [spellId] = {enabled, trackById, glow, glowColor},
    --         },
    --         [bossId] = {
    --             ["name"] = "bossName",
    --             ["image"] = image,
    --             ["debuffs"] = {
    --                 [spellId] = {enabled, trackById, glow, glowColor},
    --             },
    --         },
    --     }
    -- }
}

local instanceIds = { -- used for GetInstanceInfo/GetRealZoneText --> instanceId
    -- [instanceName] = instanceId,
}

local instanceOrders = { -- used for sorting instance list buttons
    -- [expansionName] = {instanceId1, instance2, ...}
}

local bossOders = { -- used for sorting boss list buttons
    -- [instanceId] = {bossId1, bossId2, ...}
}

local debuffOrders = {} -- loaded from db

local function LoadBossList(instanceId, list, orderTable)
    EJ_SelectInstance(instanceId)
    for index = 1, 77 do
		local name, _, id = EJ_GetEncounterInfoByIndex(index)
		if not name or not id then
			break
        end
        
        tinsert(orderTable, id) -- bossOrders

        -- id, name, description, displayInfo, iconImage, uiModelSceneID = EJ_GetCreatureInfo(index [, encounterID])
        local image = select(5, EJ_GetCreatureInfo(1, id))
        list[id] = {["name"]=name, ["image"]=image, ["debuffs"]={}}
	end
end

local function LoadInstanceList(tier, instanceType, list, orderTable)
    local isRaid = instanceType == "raid"
    for index = 1, 77 do
        EJ_SelectTier(tier)
        local id, name = EJ_GetInstanceByIndex(index, isRaid)
        if not id or not name then
            break
        end

        instanceIds[name] = id
        tinsert(orderTable, id) -- instanceOrders
        bossOders[id] = {}

        list[id] = {["name"]=name, ["general"]={}}

        LoadBossList(id, list[id], bossOders[id])
    end
end

local function LoadList()
    for tier = 1, EJ_GetNumTiers() do
        local name = EJ_GetTierInfo(tier)
        debuffList[name] = {}
        instanceOrders[name] = {}

        LoadInstanceList(tier, "raid", debuffList[name], instanceOrders[name])
        LoadInstanceList(tier, "party", debuffList[name], instanceOrders[name])

        newestExpansion = name
    end
end

LoadExpansion = function(eName)
    if loadedExpansion == eName then return end
    loadedExpansion = eName
    -- show then first boss of the first instance of the expansion
    ShowInstances(eName)

end

local loadedDebuffs = {}
function F:LoadBuiltInDebuffs(tier, debuffs)
    local eName = EJ_GetTierInfo(tier)
    loadedDebuffs[eName] = debuffs
end

local function LoadDBDebuffs()

end

local function UpdateRaidDebuffs()
    LoadList()
    -- update from built-in
    for instanceId, iTable in pairs(loadedDebuffs[eName]) do
        if debuffList[eName][instanceId] then -- valid instance
            for encounterId, debuffTable in pairs(iTable) do
                if encounterId == "general" then -- general debuffs

                elseif debuffList[eName][instanceId][encounterId] then -- valid boss
                    for _, spellId in pairs(debuffTable) do
                        debuffList[eName][instanceId][encounterId][spellId] = {true}
                    end
                end
            end                 
        end
    end

    -- update from db
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

    for i, instanceId in pairs(instanceOrders[eName]) do
        if not instanceButtons[i] then
            instanceButtons[i] = Cell:CreateButton(instancesFrame.scrollFrame.content, debuffList[eName][instanceId]["name"], "transparent-class", {20, 20})
        else
            instanceButtons[i]:SetText(debuffList[eName][instanceId]["name"])
            instanceButtons[i]:Show()
        end

        instanceButtons[i].id = instanceId -- send instanceId to ShowBosses
        
        -- open encounter journal
        instanceButtons[i]:SetScript("OnDoubleClick", function()
            OpenEncounterJournal(instanceId)
        end)

        if i == 1 then
            instanceButtons[i]:SetPoint("TOPLEFT")
        else
            instanceButtons[i]:SetPoint("TOPLEFT", instanceButtons[i-1], "BOTTOMLEFT", 0, 1)
        end
        instanceButtons[i]:SetPoint("RIGHT")
    end

    -- update scrollFrame content height
    instancesFrame.scrollFrame:SetContentHeight(20, #instanceOrders[eName], -1)

    -- hide unused instance buttons
    for i = #instanceOrders[eName]+1, #instanceButtons do
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
    if loadedInstance == instanceId then return end
    loadedInstance = instanceId

    bossesFrame.scrollFrame:ResetScroll()

    -- instance general debuff
    if not bossButtons[0] then
        bossButtons[0] = Cell:CreateButton(bossesFrame.scrollFrame.content, L["General"], "transparent-class", {20, 20})
        bossButtons[0].id = 0
        bossButtons[0]:SetPoint("TOPLEFT")
        bossButtons[0]:SetPoint("RIGHT")
    end

    -- bosses
    local n
    for i, bossId in pairs(bossOders[instanceId]) do
        local bName = debuffList[loadedExpansion][instanceId][bossId]["name"]
        if not bossButtons[i] then
            bossButtons[i] = Cell:CreateButton(bossesFrame.scrollFrame.content, bName, "transparent-class", {20, 20})
        else
            bossButtons[i]:SetText(bName)
            bossButtons[i]:Show()
        end

        bossButtons[i].id = bossId
        n = i

        bossButtons[i]:SetPoint("TOPLEFT", bossButtons[i-1], "BOTTOMLEFT", 0, 1)
        bossButtons[i]:SetPoint("RIGHT")
    end

    -- update scrollFrame content height
    bossesFrame.scrollFrame:SetContentHeight(20, n+1, -1)

    -- hide unused instance buttons
    for i = n+1, #bossButtons do
        bossButtons[i]:Hide()
        bossButtons[i]:ClearAllPoints()
    end

    -- set onclick/onenter
    Cell:CreateButtonGroup(bossButtons, ShowDebuffs, nil, nil, function(b)
        if b.id ~= 0 then
            ShowImage(debuffList[loadedExpansion][instanceId][b.id]["image"], b)
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
    if loadedBoss == loadedInstance..bossId then return end
    loadedBoss = loadedInstance..bossId

    bossesFrame.scrollFrame:ResetScroll()
    
    local t
    if bossId == 0 then
        t = debuffList[loadedExpansion][loadedInstance]["general"]
    else
        t = debuffList[loadedExpansion][loadedInstance][bossId]["debuffs"]
    end

    for i, spellId in pairs(debuffOrders) do
        -- if not debuffButtons[i] then
        --     debuffButtons[i] = Cell:CreateButton(debuffListFrame.scrollFrame.content, t[i], "transparent-class", {20, 20})
        -- else
        --     debuffButtons[i]:SetText(t[i])
        --     debuffButtons[i]:Show()
        -- end

        -- debuffButtons[i].id = i -- send spellIndex to ShowDetails

        -- if i == 1 then
        --     debuffButtons[i]:SetPoint("TOPLEFT")
        -- else
        --     debuffButtons[i]:SetPoint("TOPLEFT", debuffButtons[i-1], "BOTTOMLEFT", 0, 1)
        -- end
        -- debuffButtons[i]:SetPoint("RIGHT")
    end

    -- set onclick
    Cell:CreateButtonGroup(debuffButtons, ShowDetails, nil, nil, function(b)
    end, function(b)
    end)

    -- if debuffButtons[1] then debuffButtons[1]:Click() end
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

ShowDetails = function()

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
        
        if not loadedExpansion then
            LoadExpansion(newestExpansion)
        end
    else
        debuffsTab:Hide()
    end
end
Cell:RegisterCallback("ShowOptionsTab", "RaidDebuffsTab_ShowTab", ShowTab)