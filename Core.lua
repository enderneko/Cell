local addonName, Cell = ...
_G.Cell = Cell
Cell.frames = {}
Cell.vars = {}
Cell.funcs = {}
Cell.iFuncs = {}

local F = Cell.funcs
local I = Cell.iFuncs
local P = Cell.pixelPerfectFuncs
local L = Cell.L

--@debug@
local debugMode = true
--@end-debug@
function F:Debug(arg, ...)
	if debugMode then
		if type(arg) == "string" or type(arg) == "number" then
			print(arg, ...)
		elseif type(arg) == "function" then
			arg(...)
		elseif arg == nil then
			return true
		end
	end
end

function F:Print(msg)
	print("|cFFFF3030[Cell]|r " .. msg)
end

local IsInRaid = IsInRaid
local IsInGroup = IsInGroup
local GetNumGroupMembers = GetNumGroupMembers
local GetRaidRosterInfo = GetRaidRosterInfo
local UnitGUID = UnitGUID
-- local IsInBattleGround = C_PvP.IsBattleground -- NOTE: can't get valid value immediately after PLAYER_ENTERING_WORLD

-------------------------------------------------
-- fonts -- used by old versions only
-------------------------------------------------
local font_name = CreateFont("CELL_FONT_NAME")
font_name:SetFont(GameFontNormal:GetFont(), 13)

local font_status = CreateFont("CELL_FONT_STATUS")
font_status:SetFont(GameFontNormal:GetFont(), 11)

-------------------------------------------------
-- layout
-------------------------------------------------
local delayedGroupType, delayedGroupChanged, delayedRoleChanged
local delayedFrame = CreateFrame("Frame")
delayedFrame:SetScript("OnEvent", function()
    delayedFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
    F:UpdateLayout(delayedGroupType, delayedGroupChanged, delayedRoleChanged)
end)

function F:UpdateLayout(groupType, groupChanged, roleChanged)
    if InCombatLockdown() then
        F:Debug("|cffbbbbbbF:UpdateLayout(\""..groupType.."\") DELAYED")
        delayedGroupType, delayedGroupChanged, delayedRoleChanged = groupType, groupChanged, roleChanged
        delayedFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    else
        F:Debug("|cffbbbbbbF:UpdateLayout(\""..groupType.."\")")
        Cell.vars.layoutGroupType = groupType
        local layout = CellDB["layoutAutoSwitch"][Cell.vars.playerSpecRole][groupType]
        Cell.vars.currentLayout = layout
        Cell.vars.currentLayoutTable = CellDB["layouts"][layout]
        Cell:Fire("UpdateLayout", Cell.vars.currentLayout)
        if groupChanged or roleChanged then
            Cell:Fire("UpdateIndicators")
        end
    end
end

local bgMaxPlayers = {
    [2197] = 40, -- 科尔拉克的复仇
}

-- layout auto switch
local instanceType
local function GroupTypeChanged()
    if instanceType == "pvp" then
        local name, _, _, _, _, _, _, id = GetInstanceInfo()
        if bgMaxPlayers[id] then
            if bgMaxPlayers[id] <= 15 then
                Cell.vars.inBattleground = 15
                F:UpdateLayout("battleground15", true)
            else
                Cell.vars.inBattleground = 40
                F:UpdateLayout("battleground40", true)
            end
        else
            Cell.vars.inBattleground = 15
            F:UpdateLayout("battleground15", true)
        end
    elseif instanceType == "arena" then
        Cell.vars.inBattleground = 5 -- treat as bg 5
        F:UpdateLayout("arena", true)
    else
        if Cell.vars.groupType == "solo" or Cell.vars.groupType == "party" then
            F:UpdateLayout("party", true)
        else
            F:UpdateLayout("raid", true)
        end
        Cell.vars.inBattleground = false
    end
end
Cell:RegisterCallback("GroupTypeChanged", "Core_GroupTypeChanged", GroupTypeChanged)

-------------------------------------------------
-- events
-------------------------------------------------
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")

-- local cellLoaded, omnicdLoaded
function eventFrame:ADDON_LOADED(arg1)
    if arg1 == addonName then
        -- cellLoaded = true
        eventFrame:UnregisterEvent("ADDON_LOADED")
        
        if type(CellDB) ~= "table" then CellDB = {} end

        if type(CellDB["indicatorPreviewAlpha"]) ~= "number" then CellDB["indicatorPreviewAlpha"] = .5 end

        -- general --------------------------------------------------------------------------------
        if type(CellDB["general"]) ~= "table" then
            CellDB["general"] = {
                ["enableTooltips"] = false,
                ["hideTooltipsInCombat"] = true,
                -- ["enableAurasTooltips"] = false,
                ["tooltipsPosition"] = {"BOTTOMLEFT", "Unit Button", "TOPLEFT", 0, 15},
                ["showSolo"] = true,
                ["showParty"] = true,
                ["showPartyPets"] = true,
                ["hideBlizzard"] = true,
                ["locked"] = false,
                ["fadeOut"] = false,
                ["sortPartyByRole"] = false,
            }
        end

        -- raidTools --------------------------------------------------------------------------------
        if type(CellDB["raidTools"]) ~= "table" then
            CellDB["raidTools"] = {
                ["showBuffTracker"] = false,
                ["showBattleRes"] = true,
                ["deathReport"] = {false, 10},
                ["showButtons"] = false,
                ["pullTimer"] = {"ExRT", 7},
                ["showMarks"] = false,
                ["marks"] = "both",
                ["buttonsPosition"] = {},
                ["marksPosition"] = {},
                ["buffTrackerPosition"] = {},
            }
        end
        -- if type(CellDB["clamped"]) ~= "boolean" then CellDB["clamped"] = false end

        -- appearance -----------------------------------------------------------------------------
        if type(CellDB["appearance"]) ~= "table" then
            CellDB["appearance"] = {
                ["scale"] = 1,
                ["optionsFontSizeOffset"] = 0,
                ["texture"] = "Cell ".._G.DEFAULT,
                ["barColor"] = {"Class Color", {.2, .2, .2}},
                ["bgColor"] = {"Class Color (dark)", {.667, 0, 0}},
                ["powerColor"] = {"Power Color", {.7, .7, .7}},
                ["barAnimation"] = "Flash",
                ["targetColor"] = {1, .31, .31, 1},
                ["mouseoverColor"] = {1, 1, 1, .6},
                ["highlightSize"] = 1,
                ["outOfRangeAlpha"] = .45,
            }
        end
        P:SetRelativeScale(CellDB["appearance"]["scale"])

        -- click-casting --------------------------------------------------------------------------
        if type(CellDB["clickCastings"]) ~= "table" then CellDB["clickCastings"] = {} end
        Cell.vars.playerClass, Cell.vars.playerClassID = select(2, UnitClass("player"))

        if type(CellDB["clickCastings"][Cell.vars.playerClass]) ~= "table" then
            CellDB["clickCastings"][Cell.vars.playerClass] = {
                ["useCommon"] = true,
                ["common"] = {
                    {"type1", "target"},
                    {"type2", "togglemenu"},
                },
            }
            -- https://wow.gamepedia.com/SpecializationID
            for sepcIndex = 1, GetNumSpecializationsForClassID(Cell.vars.playerClassID) do
                local specID = GetSpecializationInfoForClassID(Cell.vars.playerClassID, sepcIndex)
                CellDB["clickCastings"][Cell.vars.playerClass][specID] = {
                    {"type1", "target"},
                    {"type2", "togglemenu"},
                } 
            end
        end
        Cell.vars.clickCastingTable = CellDB["clickCastings"][Cell.vars.playerClass]

        -- layouts --------------------------------------------------------------------------------
        if type(CellDB["layouts"]) ~= "table" then
            CellDB["layouts"] = {
                ["default"] = {
                    ["size"] = {66, 46},
                    ["petSize"] = {false, 66, 46},
                    ["position"] = {},
                    ["powerHeight"] = 2,
                    ["spacing"] = 3,
                    ["orientation"] = "vertical",
                    ["anchor"] = "TOPLEFT",
                    ["columns"] = 8,
                    ["rows"] = 8,
                    ["groupSpacing"] = 0,
                    ["groupFilter"] = {true, true, true, true, true, true, true, true},
                    ["indicators"] = {
                        {
                            ["name"] = "Name Text",
                            ["indicatorName"] = "nameText",
                            ["type"] = "built-in",
                            ["enabled"] = true,
                            ["position"] = {"CENTER", "CENTER", 0, 0},
                            ["font"] = {"Cell ".._G.DEFAULT, 13, "Shadow"},
                            ["nameColor"] = {"Custom Color", {1, 1, 1}},
                            ["vehicleNamePosition"] = {"TOP", 0},
                            ["textWidth"] = .75,
                        }, -- 1
                        {
                            ["name"] = "Status Text",
                            ["indicatorName"] = "statusText",
                            ["type"] = "built-in",
                            ["enabled"] = true,
                            ["position"] = {"BOTTOM", 0},
                            ["frameLevel"] = 30,
                            ["font"] = {"Cell ".._G.DEFAULT, 11, "Shadow"},
                        }, -- 2
                        {
                            ["name"] = "Health Text",
                            ["indicatorName"] = "healthText",
                            ["type"] = "built-in",
                            ["enabled"] = false,
                            ["position"] = {"TOP", "CENTER", 0, -5},
                            ["frameLevel"] = 2,
                            ["font"] = {"Cell ".._G.DEFAULT, 10, "Shadow", 0},
                            ["color"] = {1, 1, 1},
                            ["format"] = "percentage",
                            ["hideFull"] = true,
                        }, -- 3
                        {
                            ["name"] = "Status Icon",
                            ["indicatorName"] = "statusIcon",
                            ["type"] = "built-in",
                            ["enabled"] = true,
                            ["position"] = {"TOP", "TOP", 0, -3},
                            ["frameLevel"] = 10,
                            ["size"] = {18, 18},
                        }, -- 4
                        {
                            ["name"] = "Role Icon",
                            ["indicatorName"] = "roleIcon",
                            ["type"] = "built-in",
                            ["enabled"] = true,
                            ["position"] = {"TOPLEFT", "TOPLEFT", 0, 0},
                            ["size"] = {11, 11},
                            ["customTextures"] = {false, "Interface\\AddOns\\ElvUI\\Media\\Textures\\Tank.tga", "Interface\\AddOns\\ElvUI\\Media\\Textures\\Healer.tga", "Interface\\AddOns\\ElvUI\\Media\\Textures\\DPS.tga"},
                        }, -- 5
                        {
                            ["name"] = "Leader Icon",
                            ["indicatorName"] = "leaderIcon",
                            ["type"] = "built-in",
                            ["enabled"] = true,
                            ["position"] = {"TOPLEFT", "TOPLEFT", 0, -11},
                            ["size"] = {11, 11},
                        }, -- 6
                        {
                            ["name"] = "Ready Check Icon",
                            ["indicatorName"] = "readyCheckIcon",
                            ["type"] = "built-in",
                            ["enabled"] = true,
                            ["frameLevel"] = 100,
                            ["size"] = {16, 16},
                        }, -- 7
                        {
                            ["name"] = "Raid Icon (player)",
                            ["indicatorName"] = "playerRaidIcon",
                            ["type"] = "built-in",
                            ["enabled"] = true,
                            ["position"] = {"TOP", "TOP", 0, 3},
                            ["frameLevel"] = 2,
                            ["size"] = {14, 14},
                            ["alpha"] = .77,
                        }, -- 8
                        {
                            ["name"] = "Raid Icon (target)",
                            ["indicatorName"] = "targetRaidIcon",
                            ["type"] = "built-in",
                            ["enabled"] = false,
                            ["position"] = {"TOP", "TOP", -14, 3},
                            ["frameLevel"] = 2,
                            ["size"] = {14, 14},
                            ["alpha"] = .77,
                        }, -- 9
                        {
                            ["name"] = "Aggro (blink)",
                            ["indicatorName"] = "aggroBlink",
                            ["type"] = "built-in",
                            ["enabled"] = true,
                            ["position"] = {"TOPLEFT", "TOPLEFT", 0, 0},
                            ["frameLevel"] = 3,
                            ["size"] = {10, 10},
                        }, -- 10
                        {
                            ["name"] = "Aggro (bar)",
                            ["indicatorName"] = "aggroBar",
                            ["type"] = "built-in",
                            ["enabled"] = true,
                            ["position"] = {"BOTTOMLEFT", "TOPLEFT", 1, 0},
                            ["frameLevel"] = 1,
                            ["size"] = {18, 2},
                        }, -- 11
                        {
                            ["name"] = "Aggro (border)",
                            ["indicatorName"] = "aggroBorder",
                            ["type"] = "built-in",
                            ["enabled"] = false,
                            ["frameLevel"] = 1,
                            ["thickness"] = 3,
                        }, -- 12
                        {
                            ["name"] = "Shield Bar",
                            ["indicatorName"] = "shieldBar",
                            ["type"] = "built-in",
                            ["enabled"] = false,
                            ["position"] = {"BOTTOMLEFT", "BOTTOMLEFT", 0, 0},
                            ["frameLevel"] = 2,
                            ["height"] = 4,
                            ["color"] = {1, 1, 0, 1},
                        }, -- 13
                        {
                            ["name"] = "AoE Healing",
                            ["indicatorName"] = "aoeHealing",
                            ["type"] = "built-in",
                            ["enabled"] = true,
                            ["height"] = 15,
                            ["color"] = {1, 1, 0},
                        }, -- 14
                        {
                            ["name"] = "External Cooldowns",
                            ["indicatorName"] = "externalCooldowns",
                            ["type"] = "built-in",
                            ["enabled"] = true,
                            ["position"] = {"RIGHT", "RIGHT", 2, 5},
                            ["frameLevel"] = 10,
                            ["size"] = {12, 20},
                            ["num"] = 2,
                            ["orientation"] = "right-to-left",
                        }, -- 15
                        {
                            ["name"] = "Defensive Cooldowns",
                            ["indicatorName"] = "defensiveCooldowns",
                            ["type"] = "built-in",
                            ["enabled"] = true,
                            ["position"] = {"LEFT", "LEFT", -2, 5},
                            ["frameLevel"] = 10,
                            ["size"] = {12, 20},
                            ["num"] = 2,
                            ["orientation"] = "left-to-right",
                        }, -- 16
                        {
                            ["name"] = "Tank Active Mitigation",
                            ["indicatorName"] = "tankActiveMitigation",
                            ["type"] = "built-in",
                            ["enabled"] = true,
                            ["position"] = {"TOPLEFT", "TOPLEFT", 10, -1},
                            ["frameLevel"] = 2,
                            ["size"] = {18, 4},
                        }, -- 17
                        {
                            ["name"] = "Dispels",
                            ["indicatorName"] = "dispels",
                            ["type"] = "built-in",
                            ["enabled"] = true,
                            ["position"] = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 4},
                            ["frameLevel"] = 15,
                            ["size"] = {12, 12},
                            ["dispellableByMe"] = true,
                            ["enableHighlight"] = false,
                        }, -- 18
                        {
                            ["name"] = "Debuffs",
                            ["indicatorName"] = "debuffs",
                            ["type"] = "built-in",
                            ["enabled"] = true,
                            ["position"] = {"BOTTOMLEFT", "BOTTOMLEFT", 1, 4},
                            ["frameLevel"] = 2,
                            ["size"] = {{13, 13}, {17, 17}},
                            ["num"] = 3,
                            ["font"] = {"Cell ".._G.DEFAULT, 11, "Outline", 2},
                            ["dispellableByMe"] = false,
                            ["orientation"] = "left-to-right",
                            ["bigDebuffs"] = {
                                209858, -- 死疽溃烂
                                46392, -- 专注打击
                                -- 焚化者阿寇拉斯
                                355732, -- 融化灵魂
                                355738, -- 灼热爆破
                                -- 凇心之欧罗斯
                                356667, -- 刺骨之寒
                                -- 刽子手瓦卢斯
                                356925, -- 屠戮
                                356923, -- 撕裂
                                358973, -- 恐惧浪潮
                                -- 粉碎者索苟冬
                                355806, -- 重压
                                358777, -- 痛苦之链
                            },
                        }, -- 19
                        {
                            ["name"] = "Raid Debuffs",
                            ["indicatorName"] = "raidDebuffs",
                            ["type"] = "built-in",
                            ["enabled"] = true,
                            ["position"] = {"CENTER", "CENTER", 0, 3},
                            ["frameLevel"] = 20,
                            ["size"] = {22, 22},
                            ["border"] = 2,
                            ["font"] = {"Cell ".._G.DEFAULT, 11, "Outline", 2},
                            ["onlyShowTopGlow"] = true,
                        }, -- 20
                        {
                            ["name"] = "Targeted Spells",
                            ["indicatorName"] = "targetedSpells",
                            ["type"] = "built-in",
                            ["enabled"] = true,
                            ["position"] = {"CENTER", "TOPLEFT", 7, -7},
                            ["frameLevel"] = 50,
                            ["size"] = {20, 20},
                            ["border"] = 2,
                            ["spells"] = {
                                320788, -- 冻结之缚
                                344496, -- 震荡爆发
                                319941, -- 碎石之跃
                                322614, -- 心灵连接
                                320132, -- 暗影之怒
                                334053, -- 净化冲击波
                                343556, -- 病态凝视
                                320596, -- 深重呕吐
                                356924, -- 屠戮
                                338606, -- 病态凝视
                                343556, -- 病态凝视
                                -- 328429, -- 窒息勒压
                            },
                            ["glow"] = {"Pixel", {0.95,0.95,0.32,1}, 9, .25, 8, 2},
                            ["font"] = {"Cell ".._G.DEFAULT, 12, "Outline", 2},
                        }, -- 21
                        {
                            ["name"] = "Target Counter",
                            ["indicatorName"] = "targetCounter",
                            ["type"] = "built-in",
                            ["enabled"] = false,
                            ["position"] = {"TOP", "TOP", 0, 5},
                            ["frameLevel"] = 15,
                            ["font"] = {"Cell ".._G.DEFAULT, 15, "Outline", 0},
                            ["color"] = {1, .1, .1},
                        }, -- 22
                    },
                },
            }
        end

        -- init enabled layout
        if type(CellDB["layoutAutoSwitch"]) ~= "table" then
            CellDB["layoutAutoSwitch"] = {
                ["TANK"] = {
                    ["party"] = "default",
                    ["raid"] = "default",
                    ["arena"] = "default",
                    ["battleground15"] = "default",
                    ["battleground40"] = "default",
                },
                ["HEALER"] = {
                    ["party"] = "default",
                    ["raid"] = "default",
                    ["arena"] = "default",
                    ["battleground15"] = "default",
                    ["battleground40"] = "default",
                },
                ["DAMAGER"] = {
                    ["party"] = "default",
                    ["raid"] = "default",
                    ["arena"] = "default",
                    ["battleground15"] = "default",
                    ["battleground40"] = "default",
                },
            }
        end

        -- validate layout
        for role, t in pairs(CellDB["layoutAutoSwitch"]) do
            for groupType, layout in pairs(t) do
                if not CellDB["layouts"][layout] then
                    CellDB["layoutAutoSwitch"][role][groupType] = "default"
                end
            end
        end

        -- debuffBlacklist ------------------------------------------------------------------------
        if type(CellDB["debuffBlacklist"]) ~= "table" then
            CellDB["debuffBlacklist"] = I:GetDefaultDebuffBlacklist()
        end
        Cell.vars.debuffBlacklist = F:ConvertTable(CellDB["debuffBlacklist"])
        
        -- raid debuffs ---------------------------------------------------------------------------
        if type(CellDB["raidDebuffs"]) ~= "table" then CellDB["raidDebuffs"] = {} end
        -- CellDB["raidDebuffs"] = {
        --     [instanceId] = {
        --         ["general"] = {
        --             [spellId] = {order, glowType, glowColor},
        --         },
        --         [bossId] = {
        --             [spellId] = {order, glowType, glowColor},
        --         },
        --     }
        -- }
        
        -- misc ---------------------------------------------------------------------------------
        Cell.loaded = true
        Cell.version = GetAddOnMetadata(addonName, "version")
        Cell:Fire("Revise")
        F:CheckWhatsNew()

    end

    -- omnicd ---------------------------------------------------------------------------------
    -- if arg1 == "OmniCD" then
    --     omnicdLoaded = true

    --     local E = OmniCD[1]
    --     tinsert(E.unitFrameData, 1, {
    --         [1] = "Cell",
    --         [2] = "CellPartyFrameMember",
    --         [3] = "unitid",
    --         [4] = 1,
    --     })

    --     local function UnitFrames()
    --         if not E.customUF.optionTable.Cell then
    --             E.customUF.optionTable.Cell = "Cell"
    --             E.customUF.optionTable.enabled.Cell = {
    --                 ["delay"] = 1,
    --                 ["frame"] = "CellPartyFrameMember",
    --                 ["unit"] = "unitid",
    --             }
    --         end
    --     end
    --     hooksecurefunc(E, "UnitFrames", UnitFrames)
    -- end

    -- if cellLoaded and omnicdLoaded then
    --     eventFrame:UnregisterEvent("ADDON_LOADED")
    -- end
end

Cell.vars.guid = {}
Cell.vars.role = {["TANK"]=0, ["HEALER"]=0, ["DAMAGER"]=0}
function eventFrame:GROUP_ROSTER_UPDATE()
    wipe(Cell.vars.guid)
    if IsInRaid() then
        if Cell.vars.groupType ~= "raid" then
            Cell.vars.groupType = "raid"
            Cell:Fire("GroupTypeChanged", "raid")
        end
        -- reset raid setup
        Cell.vars.role["TANK"] = 0
        Cell.vars.role["HEALER"] = 0
        Cell.vars.role["DAMAGER"] = 0
        -- update guid & raid setup
        for i = 1, GetNumGroupMembers() do
            -- update guid
            local playerGUID = UnitGUID("raid"..i)
            if playerGUID then
                Cell.vars.guid[playerGUID] = "raid"..i
            end
            -- update raid setup
            local role = select(12, GetRaidRosterInfo(i))
            if role and Cell.vars.role[role] then
                Cell.vars.role[role] = Cell.vars.role[role] + 1
            end
        end
        -- update Cell.unitButtons.raid.units
        for i = GetNumGroupMembers()+1, 40 do
            Cell.unitButtons.raid.units["raid"..i] = nil
            _G["CellRaidFrameMember"..i] = nil
        end
        F:UpdateRaidSetup()
        -- update Cell.unitButtons.party.units
        Cell.unitButtons.party.units["player"] = nil
        Cell.unitButtons.party.units["pet"] = nil
        for i = 1, 4 do
            Cell.unitButtons.party.units["party"..i] = nil
            Cell.unitButtons.party.units["partypet"..i] = nil
        end

    elseif IsInGroup() then
        if Cell.vars.groupType ~= "party" then
            Cell.vars.groupType = "party"
            Cell:Fire("GroupTypeChanged", "party")
        end
        -- update guid
        Cell.vars.guid[UnitGUID("player")] = "player"
        if UnitGUID("pet") then
            Cell.vars.guid[UnitGUID("pet")] = "pet"
        end
        for i = 1, 4 do
            local playerGUID = UnitGUID("party"..i)
            if playerGUID then
                Cell.vars.guid[playerGUID] = "party"..i
            else
                break
            end

            local petGUID = UnitGUID("partypet"..i)
            if petGUID then
                Cell.vars.guid[petGUID] = "partypet"..i
            end
        end
        -- update Cell.unitButtons.raid.units
        for i = 1, 40 do
            Cell.unitButtons.raid.units["raid"..i] = nil
            _G["CellRaidFrameMember"..i] = nil
        end
        -- update Cell.unitButtons.party.units
        for i = GetNumGroupMembers(), 4 do
            Cell.unitButtons.party.units["party"..i] = nil
            Cell.unitButtons.party.units["partypet"..i] = nil
        end

    else
        if Cell.vars.groupType ~= "solo" then
            Cell.vars.groupType = "solo"
            Cell:Fire("GroupTypeChanged", "solo")
        end
        -- update guid
        Cell.vars.guid[UnitGUID("player")] = "player"
        if UnitGUID("pet") then
            Cell.vars.guid[UnitGUID("pet")] = "pet"
        end
        -- update Cell.unitButtons.raid.units
        for i = 1, 40 do
            Cell.unitButtons.raid.units["raid"..i] = nil
            _G["CellRaidFrameMember"..i] = nil
        end
        -- update Cell.unitButtons.party.units
        Cell.unitButtons.party.units["player"] = nil
        Cell.unitButtons.party.units["pet"] = nil
        for i = 1, 4 do
            Cell.unitButtons.party.units["party"..i] = nil
            Cell.unitButtons.party.units["partypet"..i] = nil
        end
    end

    if Cell.vars.hasPermission ~= F:HasPermission() or Cell.vars.hasPartyMarkPermission ~= F:HasPermission(true) then
        Cell.vars.hasPermission = F:HasPermission()
        Cell.vars.hasPartyMarkPermission = F:HasPermission(true)
        Cell:Fire("PermissionChanged")
        F:Debug("|cffbb00bbPermissionChanged")
    end
end

function eventFrame:UNIT_PET()
    if not IsInRaid() then
        eventFrame:GROUP_ROSTER_UPDATE()
    end
end

local inInstance
function eventFrame:PLAYER_ENTERING_WORLD()
    -- eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    F:Debug("PLAYER_ENTERING_WORLD")

    local isIn, iType = IsInInstance()
    instanceType = iType
    if isIn then
        F:Debug("|cffff1111Entered Instance:|r", iType)
        GroupTypeChanged()
        inInstance = true
    elseif inInstance then -- left insntance
        F:Debug("|cffff1111Left Instance|r")
        GroupTypeChanged()
        inInstance = false
    end
end

local prevSpec
function eventFrame:PLAYER_LOGIN()
    F:Debug("PLAYER_LOGIN")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("UNIT_PET")
    eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    eventFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    
    --! init bgMaxPlayers
    for i = 1, GetNumBattlegroundTypes() do
        local bgName, _, _, _, _, _, bgId, maxPlayers = GetBattlegroundInfo(i)
        bgMaxPlayers[bgId] = maxPlayers
    end

    if not prevSpec then prevSpec = GetSpecialization() end
    Cell.vars.playerGUID = UnitGUID("player")
    -- update spec vars
    Cell.vars.playerSpecID, Cell.vars.playerSpecName, _, Cell.vars.playerSpecIcon, Cell.vars.playerSpecRole = GetSpecializationInfo(prevSpec)
    --! init Cell.vars.currentLayout and Cell.vars.currentLayoutTable 
    eventFrame:GROUP_ROSTER_UPDATE()
    -- update visibility
    Cell:Fire("UpdateVisibility")
    -- update sortMethod
    Cell:Fire("UpdateSortMethod")
    -- update click-castings
    Cell:Fire("UpdateClickCastings")
    -- update indicators
    -- Cell:Fire("UpdateIndicators") -- NOTE: already update in GROUP_ROSTER_UPDATE -> GroupTypeChanged -> F:UpdateLayout
    -- update texture and font
    Cell:Fire("UpdateAppearance")
    Cell:UpdateOptionsFont(CellDB["appearance"]["optionsFontSizeOffset"])
    Cell:Fire("UpdatePixelPerfect")
    -- update raid tools
    Cell:Fire("UpdateRaidTools")
    -- update raid debuff list
    Cell:Fire("UpdateRaidDebuffs")
    -- hide blizzard
    if CellDB["general"]["hideBlizzard"] then F:HideBlizzard() end
    -- lock
    F:UpdateFrameLock(CellDB["general"]["locked"])
    -- fade out
    F:UpdateMenuFadeOut(CellDB["general"]["fadeOut"])
end

local forceRecheck
local checkSpecFrame = CreateFrame("Frame")
checkSpecFrame:SetScript("OnEvent", function()
    eventFrame:ACTIVE_TALENT_GROUP_CHANGED()
end)
-- PLAYER_SPECIALIZATION_CHANGED fires when level up, ACTIVE_TALENT_GROUP_CHANGED usually fire twice.
-- NOTE: ACTIVE_TALENT_GROUP_CHANGED fires before PLAYER_LOGIN, but can't GetSpecializationInfo before PLAYER_LOGIN
function eventFrame:ACTIVE_TALENT_GROUP_CHANGED()
    -- not in combat & spec CHANGED
    if not InCombatLockdown() and (prevSpec and prevSpec ~= GetSpecialization() or forceRecheck) then
        prevSpec = GetSpecialization()
        -- update spec vars
        Cell.vars.playerSpecID, Cell.vars.playerSpecName, _, Cell.vars.playerSpecIcon, Cell.vars.playerSpecRole = GetSpecializationInfo(prevSpec)
        if not Cell.vars.playerSpecID then -- NOTE: when join in battleground, spec auto switched, during loading, can't get info from GetSpecializationInfo, until PLAYER_ENTERING_WORLD
            forceRecheck = true
            checkSpecFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        else
            forceRecheck = false
            checkSpecFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
            if not CellDB["clickCastings"][Cell.vars.playerClass]["useCommon"] then
                Cell:Fire("UpdateClickCastings")
            end
            F:Debug("|cffbbbbbbRoleChanged:", Cell.vars.playerSpecRole)
            F:UpdateLayout(Cell.vars.layoutGroupType, false, true)
            -- Cell:Fire("RoleChanged", Cell.vars.playerSpecRole)
        end
    end
end

eventFrame:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)

-------------------------------------------------
-- slash command
-------------------------------------------------
SLASH_CELL1 = "/cell"
function SlashCmdList.CELL(msg, editbox)
    local command, rest = msg:match("^(%S*)%s*(.-)$")
    if command == "options" or command == "opt" then
        F:ShowOptionsFrame()

    elseif command == "reset" then
        if rest == "position" then
            Cell.frames.anchorFrame:ClearAllPoints()
            Cell.frames.anchorFrame:SetPoint("TOPLEFT", UIParent, "CENTER")
            Cell.vars.currentLayoutTable["position"] = {}
            Cell.frames.raidButtonsFrame:ClearAllPoints()
            Cell.frames.raidButtonsFrame:SetPoint("TOPRIGHT", UIParent, "CENTER")
            CellDB["raidTools"]["buttonsPosition"] = {}
            Cell.frames.raidMarksFrame:ClearAllPoints()
            Cell.frames.raidMarksFrame:SetPoint("BOTTOMRIGHT", UIParent, "CENTER")
            CellDB["raidTools"]["marksPosition"] = {}

        elseif rest == "all" then
            Cell.frames.anchorFrame:ClearAllPoints()
            Cell.frames.anchorFrame:SetPoint("TOPLEFT", UIParent, "CENTER")
            Cell.frames.raidButtonsFrame:ClearAllPoints()
            Cell.frames.raidButtonsFrame:SetPoint("TOPRIGHT", UIParent, "CENTER")
            Cell.frames.raidMarksFrame:ClearAllPoints()
            Cell.frames.raidMarksFrame:SetPoint("BOTTOMRIGHT", UIParent, "CENTER")
            CellDB = nil
            ReloadUI()

        elseif rest == "layouts" then
            CellDB["layouts"] = nil
            ReloadUI()

        elseif rest == "raidDebuffs" then
            CellDB["raidDebuffs"] = nil
            ReloadUI()
            
        elseif rest == "clickCastings" then
            CellDB["clickCastings"] = nil
            ReloadUI()
        end

    elseif command == "report" then
        rest = tonumber(rest:format("%d"))
        if rest and rest>=0 and rest<=40 then
            if rest == 0 then
                F:Print(L["Cell will report all deaths during a raid encounter."])
            else
                F:Print(string.format(L["Cell will report first %d deaths during a raid encounter."], rest))
            end
            CellDB["raidTools"]["deathReport"][2] = rest
            Cell:Fire("UpdateRaidTools", "deathReport")
        else
            F:Print(L["A 0-40 integer is required."])
        end

    else
        F:Print(L["Available slash commands"]..":\n"..
            "|cFFFFB5C5/cell options|r, |cFFFFB5C5/cell opt|r: "..L["show Cell options frame"]..".\n"..
            "|cFFFF7777"..L["These \"reset\" commands below affect all your characters in this account"]..".|r\n"..
            "|cFFFFB5C5/cell reset position|r: "..L["reset Cell position"]..".\n"..
            "|cFFFFB5C5/cell reset layouts|r: "..L["reset all Layouts and Indicators"]..".\n"..
            "|cFFFFB5C5/cell reset clickCastings|r: "..L["reset all Click-Castings"]..".\n"..
            "|cFFFFB5C5/cell reset raidDebuffs|r: "..L["reset all Raid Debuffs"]..".\n"..
            "|cFFFFB5C5/cell reset all|r: "..L["reset all Cell settings"].."."
        )
    end
end