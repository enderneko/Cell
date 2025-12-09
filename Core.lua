---@class Cell
local Cell = select(2, ...)
_G.Cell = Cell

---@class Cell
---@field defaults table
---@field frames table
---@field vars table
---@field snippetVars table
---@field funcs CellFuncs
---@field iFuncs CellIndicatorFuncs
---@field bFuncs CellUnitButtonFuncs
---@field uFuncs CellUtilityFuncs
---@field animations CellAnimations

Cell.defaults = {}
Cell.frames = {}
Cell.vars = {}
Cell.snippetVars = {}
Cell.funcs = {}
Cell.iFuncs = {}
Cell.bFuncs = {}
Cell.uFuncs = {}
Cell.animations = {}

---@class CellFuncs
local F = Cell.funcs
local I = Cell.iFuncs
---@type PixelPerfectFuncs
local P = Cell.pixelPerfectFuncs
local L = Cell.L

-- sharing version check
Cell.MIN_VERSION = 246
Cell.MIN_CLICKCASTINGS_VERSION = 246
Cell.MIN_LAYOUTS_VERSION = 246
Cell.MIN_INDICATORS_VERSION = 246
Cell.MIN_DEBUFFS_VERSION = 246
Cell.MIN_QUICKASSIST_VERSION = 246

--@debug@
local debugMode = true
--@end-debug@
function F.Debug(arg, ...)
    if debugMode then
        if type(arg) == "string" or type(arg) == "number" then
            print(arg, ...)
        elseif type(arg) == "table" then
            DevTools_Dump(arg)
        elseif type(arg) == "function" then
            arg(...)
        elseif arg == nil then
            return true
        end
    end
end

function F.Print(msg)
    print("|cFFFF3030[Cell]|r " .. msg)
end

--------------------------------------------------
-- CellParent
--------------------------------------------------
local CellParent = CreateFrame("Frame", "CellParent", UIParent)
CellParent:SetAllPoints(UIParent)
CellParent:SetFrameLevel(0)

-------------------------------------------------
-- layout
-------------------------------------------------
local delayedLayoutGroupType
local delayedFrame = CreateFrame("Frame")
delayedFrame:SetScript("OnEvent", function()
    delayedFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
    F.UpdateLayout(delayedLayoutGroupType)
end)

function F.UpdateLayout(layoutGroupType)
    if InCombatLockdown() then
        F.Debug("|cFF7CFC00F.UpdateLayout(\""..layoutGroupType.."\") DELAYED")
        delayedLayoutGroupType = layoutGroupType
        delayedFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    else
        F.Debug("|cFF7CFC00F.UpdateLayout(\""..layoutGroupType.."\")")

        if CellDB["layoutAutoSwitch"][Cell.vars.playerClass][Cell.vars.playerSpecID] then
            Cell.vars.layoutAutoSwitchBy = "spec"
            Cell.vars.layoutAutoSwitch = CellDB["layoutAutoSwitch"][Cell.vars.playerClass][Cell.vars.playerSpecID]
        else
            Cell.vars.layoutAutoSwitchBy = "role"
            Cell.vars.layoutAutoSwitch = CellDB["layoutAutoSwitch"]["role"][Cell.vars.playerSpecRole]
        end

        local layout = Cell.vars.layoutAutoSwitch[layoutGroupType]
        Cell.vars.layoutGroupType = layoutGroupType

        if layout == "hide" then
            Cell.vars.isHidden = true
            Cell.vars.currentLayout = "default"
            Cell.vars.currentLayoutTable = CellDB["layouts"]["default"]
        else
            Cell.vars.isHidden = false
            Cell.vars.currentLayout = layout
            Cell.vars.currentLayoutTable = CellDB["layouts"][layout]
        end

        F.IterateAllUnitButtons(function(b)
            b._indicatorsReady = nil
        end, true)

        Cell.Fire("UpdateLayout", layout)
        Cell.Fire("UpdateIndicators")
    end
end

local bgMaxPlayers = {
    [2197] = 40, -- 科尔拉克的复仇
}

-- layout auto switch
local instanceType
local function PreUpdateLayout()
    if not (Cell.vars.playerSpecID and Cell.vars.playerSpecRole) then return end

    if instanceType == "pvp" then
        local name, _, _, _, _, _, _, id = GetInstanceInfo()
        if bgMaxPlayers[id] then
            if bgMaxPlayers[id] <= 15 then
                Cell.vars.inBattleground = 15
                F.UpdateLayout("battleground15")
            else
                Cell.vars.inBattleground = 40
                F.UpdateLayout("battleground40")
            end
        else
            Cell.vars.inBattleground = 15
            F.UpdateLayout("battleground15")
        end
    elseif instanceType == "arena" then
        Cell.vars.inBattleground = 5 -- treat as bg 5
        F.UpdateLayout("arena")
    else
        Cell.vars.inBattleground = false
        if Cell.vars.groupType == "solo" then
            F.UpdateLayout("solo")
        elseif Cell.vars.groupType == "party" then
            F.UpdateLayout("party")
        else -- raid
            if Cell.vars.inMythic then
                F.UpdateLayout("raid_mythic")
            elseif Cell.vars.inInstance then
                F.UpdateLayout("raid_instance")
            else
                F.UpdateLayout("raid_outdoor")
            end
        end
    end
end
Cell.RegisterCallback("GroupTypeChanged", "Core_GroupTypeChanged", PreUpdateLayout)
Cell.RegisterCallback("SpecChanged", "Core_SpecChanged", PreUpdateLayout)
Cell.RegisterCallback("LayoutAutoSwitchChanged", "Core_LayoutAutoSwitchChanged", PreUpdateLayout)

-------------------------------------------------
-- events
-------------------------------------------------
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("VARIABLES_LOADED")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
-- eventFrame:RegisterEvent("LOADING_SCREEN_DISABLED")

-- function eventFrame:LOADING_SCREEN_DISABLED()
--     if not InCombatLockdown() and not UnitAffectingCombat("player") then
--         F.Debug("|cffbbbbbbLOADING_SCREEN_DISABLED: |cffff7777collectgarbage")
--         collectgarbage("collect")
--     end
-- end

function eventFrame:VARIABLES_LOADED()
    SetCVar("predictedHealth", 1)
end

local IsInRaid = IsInRaid
local IsInGroup = IsInGroup
local GetNumGroupMembers = GetNumGroupMembers
local GetRaidRosterInfo = GetRaidRosterInfo
local UnitGUID = UnitGUID
-- local IsInBattleGround = C_PvP.IsBattleground -- NOTE: can't get valid value immediately after PLAYER_ENTERING_WORLD
local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata

-- local cellLoaded, omnicdLoaded
function eventFrame:ADDON_LOADED(arg1)
    if arg1 == "Cell" then
        -- cellLoaded = true
        eventFrame:UnregisterEvent("ADDON_LOADED")

        if type(CellDB) ~= "table" then CellDB = {} end
        if type(CellDBBackup) ~= "table" then CellDBBackup = {} end

        if type(CellDB["optionsFramePosition"]) ~= "table" then CellDB["optionsFramePosition"] = {} end

        if type(CellDB["indicatorPreview"]) ~= "table" then
            CellDB["indicatorPreview"] = {
                ["scale"] = 2,
                ["showAll"] = false,
            }
        end

        if type(CellDB["customTextures"]) ~= "table" then CellDB["customTextures"] = {} end

        if type(CellDB["snippets"]) ~= "table" then CellDB["snippets"] = {} end
        if not CellDB["snippets"][0] then CellDB["snippets"][0] = F.GetDefaultSnippet() end

        Cell.vars.playerClass, Cell.vars.playerClassID = UnitClassBase("player")

        -- general --------------------------------------------------------------------------------
        if type(CellDB["general"]) ~= "table" then
            CellDB["general"] = {
                ["enableTooltips"] = false,
                ["hideTooltipsInCombat"] = true,
                ["tooltipsPosition"] = {"BOTTOMLEFT", "Default", "TOPLEFT", 0, 15},
                ["hideBlizzardParty"] = true,
                ["hideBlizzardRaid"] = true,
                ["hideBlizzardRaidManager"] = true,
                ["locked"] = false,
                ["fadeOut"] = false,
                ["menuPosition"] = "top_bottom",
                ["alwaysUpdateAuras"] = false,
                ["framePriority"] = {
                    {"Main", true},
                    {"Spotlight", false},
                    {"Quick Assist", false},
                },
                ["useCleuHealthUpdater"] = false,
                ["translit"] = false,
            }
        end
        Cell.vars.alwaysUpdateAuras = CellDB["general"]["alwaysUpdateAuras"]

        -- nicknames ------------------------------------------------------------------------------
        if type(CellDB["nicknames"]) ~= "table" then
            CellDB["nicknames"] = {
                ["mine"] = "",
                ["sync"] = false,
                ["custom"] = false,
                ["list"] = {},
                ["blacklist"] = {},
            }
        end

        -- tools ----------------------------------------------------------------------------------
        if type(CellDB["tools"]) ~= "table" then
            CellDB["tools"] = {
                ["battleResTimer"] = {true, false, {}},
                ["buffTracker"] = {false, "left-to-right", 32, {}, {}},
                ["deathReport"] = {false, 10},
                ["readyAndPull"] = {false, "text_button", {"default", 7}, {}},
                ["marks"] = {false, false, "both_h", {}},
                ["fadeOut"] = false,
            }
        end

        -- spellRequest ---------------------------------------------------------------------------
        if type(CellDB["spellRequest"]) ~= "table" then
            local POWER_INFUSION, POWER_INFUSION_ICON = F.GetSpellInfo(10060)
            local INNERVATE, INNERVATE_ICON = F.GetSpellInfo(29166)

            CellDB["spellRequest"] = {
                ["enabled"] = false,
                ["checkIfExists"] = true,
                ["knownSpellsOnly"] = true,
                ["freeCooldownOnly"] = true,
                ["replyCooldown"] = true,
                ["responseType"] = "me",
                ["timeout"] = 10,
                -- ["replyAfterCast"] = nil,
                ["sharedIconOptions"] = {
                    "beat", -- [1] animation
                    27, -- [2] size
                    "BOTTOMRIGHT", -- [3] anchor
                    "BOTTOMRIGHT", -- [4] anchorTo
                    0, -- [5] x
                    0, -- [6] y
                },
                ["spells"] = {
                    {
                        ["spellId"] = 10060,
                        ["buffId"] = 10060,
                        ["keywords"] = POWER_INFUSION,
                        ["icon"] = POWER_INFUSION_ICON,
                        ["type"] = "icon",
                        ["iconColor"] = {1, 1, 0, 1},
                        ["glowOptions"] = {
                            "pixel", -- [1] glow type
                            {
                                {1,1,0,1}, -- [1] color
                                0, -- [2] x
                                0, -- [3] y
                                9, -- [4] N
                                0.25, -- [5] frequency
                                8, -- [6] length
                                2 -- [7] thickness
                            } -- [2] glowOptions
                        },
                        ["isBuiltIn"] = true
                    },
                    {
                        ["spellId"] = 29166,
                        ["buffId"] = 29166,
                        ["keywords"] = INNERVATE,
                        ["icon"] = INNERVATE_ICON,
                        ["type"] = "icon",
                        ["iconColor"] = {0, 1, 1, 1},
                        ["glowOptions"] = {
                            "pixel", -- [1] glow type
                            {
                                {0, 1, 1, 1}, -- [1] color
                                0, -- [2] x
                                0, -- [3] y
                                9, -- [4] N
                                0.25, -- [5] frequency
                                8, -- [6] length
                                2 -- [7] thickness
                            } -- [2] glowOptions
                        },
                        ["isBuiltIn"] = true
                    },
                },
            }
        end

        -- dispelRequest --------------------------------------------------------------------------
        if type(CellDB["dispelRequest"]) ~= "table" then
            CellDB["dispelRequest"] = {
                ["enabled"] = false,
                ["dispellableByMe"] = true,
                ["responseType"] = "all",
                ["timeout"] = 10,
                ["debuffs"] = {},
                ["type"] = "text",
                ["textOptions"] = {
                    "A",
                    {1, 1, 1, 1}, -- [1] color
                    32, -- [2] size
                    "TOPLEFT", -- [3] anchor
                    "TOPLEFT", -- [4] anchorTo
                    -1, -- [5] x
                    5, -- [6] y
                },
                ["glowOptions"] = {
                    "shine", -- [1] glow type
                    {
                        {1, 0, 0.4, 1}, -- [1] color
                        0, -- [2] x
                        0, -- [3] y
                        9, -- [4] N
                        0.5, -- [5] frequency
                        2, -- [6] scale
                    } -- [2] glowOptions
                }
            }
        end

        -- quickAssist ----------------------------------------------------------------------------
        if type(CellDB["quickAssist"]) ~= "table" then CellDB["quickAssist"] = {} end

        -- quickCast ------------------------------------------------------------------------------
        if type(CellDB["quickCast"]) ~= "table" then CellDB["quickCast"] = {} end
        -- remove unused quick cast table
        for c, ct in pairs(CellDB["quickCast"]) do
            for s, st in pairs(ct) do
                if not st["enabled"] and st["outerBuff"] == 0 and st["innerBuff"] == 0 then
                    ct[s] = nil
                end
            end
            if F.Getn(ct) == 0 then
                CellDB["quickCast"][c] = nil
            end
        end

        -- appearance -----------------------------------------------------------------------------
        if type(CellDB["appearance"]) ~= "table" then
            CellDB["appearance"] = F.Copy(Cell.defaults.appearance)
        end

        -- color ---------------------------------------------------------------------------------
        if CellDB["appearance"]["accentColor"] then -- version < r103
            if CellDB["appearance"]["accentColor"][1] == "custom" then
                Cell.OverrideAccentColor(CellDB["appearance"]["accentColor"][2])
            end
        end

        -- click-casting --------------------------------------------------------------------------
        if type(CellDB["clickCastings"]) ~= "table" then CellDB["clickCastings"] = {} end

        if type(CellDB["clickCastings"][Cell.vars.playerClass]) ~= "table" then
            CellDB["clickCastings"][Cell.vars.playerClass] = {
                ["useCommon"] = true,
                ["smartResurrection"] = "disabled",
                ["alwaysTargeting"] = {
                    ["common"] = "disabled",
                },
                ["common"] = {
                    {"type1", "target"},
                    {"type2", "togglemenu"},
                },
            }

            -- add resurrections for "common"
            for _, t in pairs(F.GetResurrectionClickCastings(Cell.vars.playerClass)) do
                tinsert(CellDB["clickCastings"][Cell.vars.playerClass]["common"], t)
            end

            -- https://wow.gamepedia.com/SpecializationID
            local specs = {}
            do
                local specID
                --! GetNumSpecializations / GetSpecializationInfo returns NOTHING at this time
                for i = 1, GetNumSpecializationsForClassID(Cell.vars.playerClassID) do
                    specID = GetSpecializationInfoForClassID(Cell.vars.playerClassID, i)
                    tinsert(specs, specID)
                end
                specID = GetSpecializationInfoForClassID(Cell.vars.playerClassID, 5)
                tinsert(specs, specID) -- "Initial" (no spec)
            end

            for _, specID in pairs(specs) do
                CellDB["clickCastings"][Cell.vars.playerClass]["alwaysTargeting"][specID] = "disabled"
                CellDB["clickCastings"][Cell.vars.playerClass][specID] = {
                    {"type1", "target"},
                    {"type2", "togglemenu"},
                }
                -- add resurrections for each spec
                for _, t in pairs(F.GetResurrectionClickCastings(Cell.vars.playerClass)) do
                    tinsert(CellDB["clickCastings"][Cell.vars.playerClass][specID], t)
                end
            end
        end
        Cell.vars.clickCastings = CellDB["clickCastings"][Cell.vars.playerClass]

        -- layouts --------------------------------------------------------------------------------
        if type(CellDB["layouts"]) ~= "table" then
            CellDB["layouts"] = {
                ["default"] = F.Copy(Cell.defaults.layout)
            }
        end

        -- layoutAutoSwitch -----------------------------------------------------------------------
        if type(CellDB["layoutAutoSwitch"]) ~= "table" then
            CellDB["layoutAutoSwitch"] = {
                ["role"] = {
                    ["TANK"] = F.Copy(Cell.defaults.layoutAutoSwitch),
                    ["HEALER"] = F.Copy(Cell.defaults.layoutAutoSwitch),
                    ["DAMAGER"] = F.Copy(Cell.defaults.layoutAutoSwitch),
                }
            }
        end

        if type(CellDB["layoutAutoSwitch"][Cell.vars.playerClass]) ~= "table" then
            CellDB["layoutAutoSwitch"][Cell.vars.playerClass] = {}
        end

        -- dispelBlacklist ------------------------------------------------------------------------
        if type(CellDB["dispelBlacklist"]) ~= "table" then
            CellDB["dispelBlacklist"] = I.GetDefaultDispelBlacklist()
        end
        Cell.vars.dispelBlacklist = F.ConvertTable(CellDB["dispelBlacklist"])

        -- debuffBlacklist ------------------------------------------------------------------------
        if type(CellDB["debuffBlacklist"]) ~= "table" then
            CellDB["debuffBlacklist"] = I.GetDefaultDebuffBlacklist()
        end
        Cell.vars.debuffBlacklist = F.ConvertTable(CellDB["debuffBlacklist"])

        -- bigDebuffs -----------------------------------------------------------------------------
        if type(CellDB["bigDebuffs"]) ~= "table" then
            CellDB["bigDebuffs"] = I.GetDefaultBigDebuffs()
        end
        Cell.vars.bigDebuffs = F.ConvertTable(CellDB["bigDebuffs"])

        -- debuffTypeColor ------------------------------------------------------------------------
        if type(CellDB["debuffTypeColor"]) ~= "table" then
            I.ResetDebuffTypeColor()
        end

        -- aoeHealings ----------------------------------------------------------------------------
        if type(CellDB["aoeHealings"]) ~= "table" then CellDB["aoeHealings"] = {["disabled"]={}, ["custom"]={}} end

        -- defensives/externals -------------------------------------------------------------------
        if type(CellDB["defensives"]) ~= "table" then CellDB["defensives"] = {["disabled"]={}, ["custom"]={}} end
        if type(CellDB["externals"]) ~= "table" then CellDB["externals"] = {["disabled"]={}, ["custom"]={}} end

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

        -- if type(CellDB["cleuAuras"]) ~= "table" then CellDB["cleuAuras"] = {} end
        -- I.UpdateCleuAuras(CellDB["cleuAuras"])

        -- if type(CellDB["cleuGlow"]) ~= "table" then
        --     CellDB["cleuGlow"] = {"Pixel", {{0, 1, 1, 1}, 9, 0.25, 8, 2}}
        -- end

        -- targetedSpells -------------------------------------------------------------------------
        if type(CellDB["targetedSpellsList"]) ~= "table" then
            CellDB["targetedSpellsList"] = I.GetDefaultTargetedSpellsList()
        end
        Cell.vars.targetedSpellsList = F.ConvertTable(CellDB["targetedSpellsList"])

        if type(CellDB["targetedSpellsGlow"]) ~= "table" then
            CellDB["targetedSpellsGlow"] = I.GetDefaultTargetedSpellsGlow()
        end
        Cell.vars.targetedSpellsGlow = CellDB["targetedSpellsGlow"]

        -- crowdControls --------------------------------------------------------------------------
        if type(CellDB["crowdControls"]) ~= "table" then CellDB["crowdControls"] = {["disabled"]={}, ["custom"]={}} end

        -- actions --------------------------------------------------------------------------------
        if type(CellDB["actions"]) ~= "table" then
            CellDB["actions"] = I.GetDefaultActions()
        end
        Cell.vars.actions = I.ConvertActions(CellDB["actions"])

        -- misc -----------------------------------------------------------------------------------
        Cell.version = GetAddOnMetadata("Cell", "version")
        Cell.versionNum = tonumber(string.match(Cell.version, "%d+"))
        if not CellDB["revise"] then CellDB["firstRun"] = true end
        F.Revise()
        F.CheckWhatsNew()
        F.RunSnippets()

        -- validation -----------------------------------------------------------------------------
        -- validate layout
        for _, roleOrClass in pairs(CellDB["layoutAutoSwitch"]) do
            for _, t in pairs(roleOrClass) do
                for groupType, layout in pairs(t) do
                    if layout ~= "hide" and not CellDB["layouts"][layout] then
                        t[groupType] = "default"
                    end
                end
            end
        end

        Cell.loaded = true
        Cell.Fire("AddonLoaded")
    end

    -- omnicd -------------------------------------------------------------------------------------
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

Cell.vars.raidSetup = {
    ["TANK"]={["ALL"]=0},
    ["HEALER"]={["ALL"]=0},
    ["DAMAGER"]={["ALL"]=0},
}

function eventFrame:GROUP_ROSTER_UPDATE(skipFallbackUpdate)
    if IsInRaid() then
        if Cell.vars.groupType ~= "raid" then
            Cell.vars.groupType = "raid"
            F.Debug("|cffffbb77GroupTypeChanged:|r raid")
            Cell.Fire("GroupTypeChanged", "raid")
        end

        -- reset raid setup
        for _, t in pairs(Cell.vars.raidSetup) do
            for class in pairs(t) do
                if class == "ALL" then
                    t["ALL"] = 0
                else
                    t[class] = nil
                end
            end
        end

        -- update guid & raid setup
        for i = 1, GetNumGroupMembers() do
            -- update raid setup
            local _, _, _, _, _, class, _, _, _, _, _, role = GetRaidRosterInfo(i)
            if not role or role == "NONE" then role = "DAMAGER" end
            -- update ALL
            Cell.vars.raidSetup[role]["ALL"] = Cell.vars.raidSetup[role]["ALL"] + 1
            -- update for each class
            if class then
                if not Cell.vars.raidSetup[role][class] then
                    Cell.vars.raidSetup[role][class] = 1
                else
                    Cell.vars.raidSetup[role][class] = Cell.vars.raidSetup[role][class] + 1
                end
            end
        end

        -- update Cell.unitButtons.raid.units
        for i = GetNumGroupMembers()+1, 40 do
            Cell.unitButtons.raid.units["raid"..i] = nil
            _G["CellRaidFrameMember"..i] = nil
        end
        F.UpdateRaidSetup()

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
            F.Debug("|cffffbb77GroupTypeChanged:|r party")
            Cell.Fire("GroupTypeChanged", "party")
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
            F.Debug("|cffffbb77GroupTypeChanged:|r solo")
            Cell.Fire("GroupTypeChanged", "solo")
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

    if Cell.vars.hasPermission ~= F.HasPermission() or Cell.vars.hasPartyMarkPermission ~= F.HasPermission(true) then
        Cell.vars.hasPermission = F.HasPermission()
        Cell.vars.hasPartyMarkPermission = F.HasPermission(true)
        Cell.Fire("PermissionChanged")
        F.Debug("|cffbb00bbPermissionChanged")
    end

    if not skipFallbackUpdate then
        CellDB.fallbackGroupType = Cell.vars.groupType
    end
end

local inInstance

local function UpdateFallbackGroupType()
    if IsInRaid() then
        CellDB.fallbackGroupType = "raid"
    elseif IsInGroup() then
        CellDB.fallbackGroupType = "party"
    else
        CellDB.fallbackGroupType = "solo"
    end

    if Cell.vars.groupType ~= CellDB.fallbackGroupType then
        Cell.vars.groupType = CellDB.fallbackGroupType
        F.Debug("|cffffbb77GroupTypeChanged:|r", Cell.vars.groupType, "(fallback validation)")
        Cell.Fire("GroupTypeChanged", Cell.vars.groupType)
    end
end

function eventFrame:PLAYER_ENTERING_WORLD(isInitialLogin, isReloadingUi)
    -- eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    F.Debug("|cffbbbbbb=== PLAYER_ENTERING_WORLD ===")
    Cell.vars.inMythic = false

    local isIn, iType = IsInInstance()
    instanceType = iType
    Cell.vars.inInstance = isIn
    Cell.vars.instanceType = iType

    C_Timer.After(1, UpdateFallbackGroupType)

    if isIn then
        F.Debug("|cffff1111*** Entered Instance:|r", iType)
        Cell.Fire("EnterInstance", iType)

        --! NOTE: for PLAYER_LOGIN/PLAYER_ENTERING_WORLD(initial) event, IsInRaid/IsInGroup always return false
        if (isInitialLogin or isReloadingUi) and CellDB.fallbackGroupType then
            F.Debug("|cffff1111*** Fallback:|r", Cell.vars.groupType, "->", CellDB.fallbackGroupType, CellDB.fallbackInMythic)
            Cell.vars.groupType = CellDB.fallbackGroupType
            Cell.vars.inMythic = CellDB.fallbackInMythic
            CellDB.fallbackGroupType = nil
            CellDB.fallbackInMythic = nil
            Cell.Fire("GroupTypeChanged", Cell.vars.groupType)
        else
            PreUpdateLayout()
        end
        inInstance = true

        -- NOTE: delayed check mythic raid
        if iType == "raid" and Cell.vars.groupType == "raid" then
            C_Timer.After(0.5, function()
                local difficultyID, difficultyName = select(3, GetInstanceInfo()) --! can't get difficultyID, difficultyName immediately after entering an instance
                Cell.vars.inMythic = difficultyID == 16
                CellDB.fallbackInMythic = Cell.vars.inMythic

                if Cell.vars.inMythic and Cell.vars.layoutGroupType ~= "raid_mythic" then
                    F.Debug("|cffff1111*** Switch to Mythic Raid layout|r")
                    Cell.Fire("EnterInstance", iType)
                    PreUpdateLayout()
                end
            end)
        else
            Cell.vars.inMythic = nil
        end

    elseif inInstance then -- left insntance
        F.Debug("|cffff1111*** Left Instance|r")
        Cell.Fire("LeaveInstance")
        PreUpdateLayout()
        inInstance = false

        if not InCombatLockdown() and not UnitAffectingCombat("player") then
            F.Debug("|cffbbbbbb--- LeftInstance: |cffff7777collectgarbage")
            collectgarbage("collect")
        end
    end

    if CellDB["firstRun"] then
        F.FirstRun()
    end
end

-- REVIEW:
-- local function RegisterGlobalClickCastings()
--     ClickCastFrames = ClickCastFrames or {}

--     if ClickCastFrames then
--         for frame, options in pairs(ClickCastFrames) do
--             F.RegisterFrame(frame)
--         end
--     end

--     ClickCastFrames = setmetatable({}, {__newindex = function(t, k, v)
--         if v == nil or v == false then
--             F.UnregisterFrame(k)
--         else
--             F.RegisterFrame(k)
--         end
--     end})

--     F.IterateAllUnitButtons(function (b)
--         ClickCastFrames[b] = true
--     end)
-- end

local function UpdateSpecVars()
    Cell.vars.playerSpecID, Cell.vars.playerSpecName, _, Cell.vars.playerSpecIcon, Cell.vars.playerSpecRole = GetSpecializationInfo(GetSpecialization())
    if not Cell.vars.playerSpecName or Cell.vars.playerSpecName == "" then
        Cell.vars.playerSpecName = L["No Spec"]
        Cell.vars.playerSpecIcon = 134400
    end
end

function eventFrame:PLAYER_LOGIN()
    F.Debug("|cffbbbbbb=== PLAYER_LOGIN ===")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    eventFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    eventFrame:RegisterEvent("UI_SCALE_CHANGED")

    Cell.vars.playerNameShort = GetUnitName("player")
    Cell.vars.playerNameFull = F.UnitFullName("player")

    --! init bgMaxPlayers
    for i = 1, GetNumBattlegroundTypes() do
        local bgName, _, _, _, _, _, bgId, maxPlayers = GetBattlegroundInfo(i)
        bgMaxPlayers[bgId] = maxPlayers
    end

    Cell.vars.playerGUID = UnitGUID("player")

    -- update spec vars
    UpdateSpecVars()

    --! init Cell.vars.currentLayout and Cell.vars.currentLayoutTable
    eventFrame:GROUP_ROSTER_UPDATE(true)
    -- REVIEW: register unitframes for click casting
    -- RegisterGlobalClickCastings()
    -- update click-castings
    Cell.Fire("UpdateClickCastings")
    -- update indicators
    -- Cell.Fire("UpdateIndicators") -- NOTE: already update in GROUP_ROSTER_UPDATE -> GroupTypeChanged -> F.UpdateLayout
    -- update texture and font
    Cell.Fire("UpdateAppearance")
    Cell.UpdateOptionsFont(CellDB["appearance"]["optionsFontSizeOffset"], CellDB["appearance"]["useGameFont"])
    Cell.UpdateAboutFont(CellDB["appearance"]["optionsFontSizeOffset"])
    -- update tools
    Cell.Fire("UpdateTools")
    -- update requests
    Cell.Fire("UpdateRequests")
    -- update quick assist
    -- Cell.Fire("UpdateQuickAssist") -- NOTE: update in GroupTypeChanged/SpecChanged
    -- update quick cast
    Cell.Fire("UpdateQuickCast")
    -- update raid debuff list
    Cell.Fire("UpdateRaidDebuffs")
    -- hide blizzard
    if CellDB["general"]["hideBlizzardParty"] then F.HideBlizzardParty() end
    if CellDB["general"]["hideBlizzardRaid"] then F.HideBlizzardRaid() end
    if CellDB["general"]["hideBlizzardRaidManager"] then F.HideBlizzardRaidManager() end
    -- lock & menu
    Cell.Fire("UpdateMenu")
    -- update CLEU health
    Cell.Fire("UpdateCLEU")
    -- update builtIns and customs
    I.UpdateAoEHealings(CellDB["aoeHealings"])
    I.UpdateDefensives(CellDB["defensives"])
    I.UpdateExternals(CellDB["externals"])
    I.UpdateCrowdControls(CellDB["crowdControls"])
    -- update pixel perfect
    Cell.Fire("UpdatePixelPerfect")
    -- update LGF
    F.UpdateFramePriority()
end

local function UpdatePixels()
    if not InCombatLockdown() then
        F.Debug("UI_SCALE_CHANGED: ", UIParent:GetScale(), CellParent:GetEffectiveScale())
        Cell.Fire("UpdatePixelPerfect")
        Cell.Fire("UpdateAppearance", "scale")
    end
end

local updatePixelsTimer
local function DelayedUpdatePixels()
    if updatePixelsTimer then
        updatePixelsTimer:Cancel()
    end
    updatePixelsTimer = C_Timer.NewTimer(1, UpdatePixels)
end

function eventFrame:UI_SCALE_CHANGED()
    DelayedUpdatePixels()
end

hooksecurefunc(UIParent, "SetScale", DelayedUpdatePixels)

-------------------------------------------------
-- ACTIVE_TALENT_GROUP_CHANGED
-------------------------------------------------
local checkSpecFrame = CreateFrame("Frame")
checkSpecFrame:SetScript("OnEvent", function()
    eventFrame:ACTIVE_TALENT_GROUP_CHANGED()
end)

-- ACTIVE_TALENT_GROUP_CHANGED fires twice
-- PLAYER_SPECIALIZATION_CHANGED fires when level up
-- ACTIVE_PLAYER_SPECIALIZATION_CHANGED only fires when player manually change spec
-- NOTE: ACTIVE_TALENT_GROUP_CHANGED fires before PLAYER_LOGIN, but can't GetSpecializationInfo before PLAYER_LOGIN
local prevSpec
function eventFrame:ACTIVE_TALENT_GROUP_CHANGED()
    -- not in combat
    if InCombatLockdown() then
        checkSpecFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end

    --  fires twice
    local spec = GetSpecialization()
    if prevSpec ~= spec then
        prevSpec = spec
        F.Debug("|cffbbbbbb=== ACTIVE_TALENT_GROUP_CHANGED ===")

        -- update spec vars
        UpdateSpecVars()

        if not Cell.vars.playerSpecID or Cell.vars.playerSpecID == 0 then
            -- NOTE: when join in battleground, spec auto switched, during loading, can't get info from GetSpecializationInfo, until PLAYER_ENTERING_WORLD
            prevSpec = nil
            checkSpecFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
            F.Debug("|cffffbb77SpecChanged:|r FAILED")
        else
            checkSpecFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
            checkSpecFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
            F.Debug("|cffffbb77SpecChanged:|r", Cell.vars.playerSpecID, Cell.vars.playerSpecRole)
            if not CellDB["clickCastings"][Cell.vars.playerClass]["useCommon"] then
                Cell.Fire("UpdateClickCastings")
            end
            Cell.Fire("SpecChanged", Cell.vars.playerSpecID, Cell.vars.playerSpecRole)
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
    command = strlower(command or "")
    rest = strlower(rest or "")

    if command == "options" or command == "opt" then
        F.ShowOptionsFrame()

    elseif command == "healers" then
        F.FirstRun()

    elseif command == "rescale" then
        CellDB["appearance"]["scale"] = P.GetRecommendedScale()
        ReloadUI()

    elseif command == "reset" then
        if rest == "position" then
            Cell.frames.anchorFrame:ClearAllPoints()
            Cell.frames.anchorFrame:SetPoint("TOPLEFT", CellParent, "CENTER")
            Cell.vars.currentLayoutTable["position"] = {}
            P.ClearPoints(Cell.frames.readyAndPullFrame)
            Cell.frames.readyAndPullFrame:SetPoint("TOPRIGHT", CellParent, "CENTER")
            CellDB["tools"]["readyAndPull"][4] = {}
            P.ClearPoints(Cell.frames.raidMarksFrame)
            Cell.frames.raidMarksFrame:SetPoint("BOTTOMRIGHT", CellParent, "CENTER")
            CellDB["tools"]["marks"][4] = {}
            P.ClearPoints(Cell.frames.buffTrackerFrame)
            Cell.frames.buffTrackerFrame:SetPoint("BOTTOMLEFT", CellParent, "CENTER")
            CellDB["tools"]["buffTracker"][4] = {}

        elseif rest == "all" then
            Cell.frames.anchorFrame:ClearAllPoints()
            Cell.frames.anchorFrame:SetPoint("TOPLEFT", CellParent, "CENTER")
            Cell.frames.readyAndPullFrame:ClearAllPoints()
            Cell.frames.readyAndPullFrame:SetPoint("TOPRIGHT", CellParent, "CENTER")
            Cell.frames.raidMarksFrame:ClearAllPoints()
            Cell.frames.raidMarksFrame:SetPoint("BOTTOMRIGHT", CellParent, "CENTER")
            Cell.frames.buffTrackerFrame:ClearAllPoints()
            Cell.frames.buffTrackerFrame:SetPoint("BOTTOMLEFT", CellParent, "CENTER")
            CellDB = nil
            ReloadUI()

        elseif rest == "layouts" then
            CellDB["layouts"] = nil
            ReloadUI()

        elseif rest == "clickcastings" then
            CellDB["clickCastings"] = nil
            ReloadUI()

        elseif rest == "raiddebuffs" then
            CellDB["raidDebuffs"] = nil
            ReloadUI()

        elseif rest == "snippets" then
            CellDB["snippets"] = {}
            CellDB["snippets"][0] = F.GetDefaultSnippet()
            ReloadUI()

        elseif rest == "quickassist" then
            CellDB["quickAssist"][Cell.vars.playerSpecID] = nil
            ReloadUI()
        end

    elseif command == "report" then
        rest = tonumber(rest:format("%d"))
        if rest and rest >= 0 and rest <= 40 then
            if rest == 0 then
                F.Print(L["Cell will report all deaths during a raid encounter."])
            else
                F.Print(string.format(L["Cell will report first %d deaths during a raid encounter."], rest))
            end
            CellDB["tools"]["deathReport"][2] = rest
            Cell.Fire("UpdateTools", "deathReport")
        else
            F.Print(L["A 0-40 integer is required."])
        end

    -- elseif command == "buff" then
    --     rest = tonumber(rest:format("%d"))
    --     if rest and rest > 0 then
    --         CellDB["tools"]["buffTracker"][3] = rest
    --         F.Print(string.format(L["Buff Tracker icon size is set to %d."], rest))
    --         Cell.Fire("UpdateTools", "buffTracker")
    --     else
    --         F.Print(L["A positive integer is required."])
    --     end

    else
        F.Print(L["Available slash commands"]..":\n"..
            "|cFFFFB5C5/cell options|r, |cFFFFB5C5/cell opt|r: "..L["show Cell options frame"]..".\n"..
            "|cFFFFB5C5/cell healers|r: "..L["create a \"Healers\" indicator"]..".\n"..
            "|cFFFFB5C5/cell rescale|r: "..strlower(L["Apply Recommended Scale"])..".\n"..
            "|cFFFF7777"..L["These \"reset\" commands below affect all your characters in this account"]..".|r\n"..
            "|cFFFFB5C5/cell reset position|r: "..L["reset Cell position"]..".\n"..
            "|cFFFFB5C5/cell reset layouts|r: "..L["reset all Layouts and Indicators"]..".\n"..
            "|cFFFFB5C5/cell reset clickcastings|r: "..L["reset all Click-Castings"]..".\n"..
            "|cFFFFB5C5/cell reset raiddebuffs|r: "..L["reset all Raid Debuffs"]..".\n"..
            "|cFFFFB5C5/cell reset snippets|r: "..L["reset all Code Snippets"]..".\n"..
            "|cFFFFB5C5/cell reset quickassist|r: "..L["reset Quick Assist for current spec"]..".\n"..
            "|cFFFFB5C5/cell reset all|r: "..L["reset all Cell settings"].."."
        )
    end
end

function Cell_OnAddonCompartmentClick()
    F.ShowOptionsFrame()
end