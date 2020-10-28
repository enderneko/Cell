local addonName, Cell = ...
_G.Cell = Cell
Cell.frames = {}
Cell.vars = {}
Cell.funcs = {}

local F = Cell.funcs
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

-------------------------------------------------
-- fonts
-------------------------------------------------
local font_name = CreateFont("CELL_FONT_NAME")
font_name:SetFont(GameFontNormal:GetFont(), 13)
font_name:SetTextColor(1, 1, 1, 1)
font_name:SetShadowColor(0, 0, 0, 1)
font_name:SetShadowOffset(1, -1)
font_name:SetJustifyH("CENTER")

local font_status = CreateFont("CELL_FONT_STATUS")
font_status:SetFont(GameFontNormal:GetFont(), 11)
font_status:SetTextColor(1, 1, 1, 1)
font_status:SetShadowColor(0, 0, 0, 1)
font_status:SetShadowOffset(1, -1)
font_status:SetJustifyH("CENTER")

-- local font_icon_center = CreateFont("CELL_FONT_ICON_CENTER")
-- font_icon_center:SetFont(GameFontNormal:GetFont(), 11)
-- font_icon_center:SetTextColor(1, 1, 1, 1)
-- font_icon_center:SetShadowColor(0, 0, 0)
-- font_icon_center:SetShadowOffset(1, -1)
-- font_icon_center:SetJustifyH("CENTER")

-- local font_icon_buff = CreateFont("CELL_FONT_ICON_BUFF")
-- font_icon_buff:SetFont(GameFontNormal:GetFont(), 11)
-- font_icon_buff:SetTextColor(1, 1, 1, 1)
-- font_icon_buff:SetShadowColor(0, 0, 0)
-- font_icon_buff:SetShadowOffset(1, -1)
-- font_icon_buff:SetJustifyH("CENTER")

-- local font_icon_debuff = CreateFont("CELL_FONT_ICON_DEBUFF")
-- font_icon_debuff:SetFont(GameFontNormal:GetFont(), 11)
-- font_icon_debuff:SetTextColor(1, 1, 1, 1)
-- font_icon_debuff:SetShadowColor(0, 0, 0)
-- font_icon_debuff:SetShadowOffset(1, -1)
-- font_icon_debuff:SetJustifyH("CENTER")

-------------------------------------------------
-- functions
-------------------------------------------------
function F:UpdateLayout()
    Cell.vars.currentLayout = CellCharacterDB["layout"]
    Cell.vars.currentLayoutTable = CellDB["layouts"][CellCharacterDB["layout"]]
    Cell:Fire("UpdateLayout", Cell.vars.currentLayout)
end

function F:UpdateFont()
    local layout = Cell.vars.currentLayoutTable
    local flags

    if CellDB["outline"] == "Shadow" then
        font_name:SetShadowColor(0, 0, 0, 1)
        font_status:SetShadowColor(0, 0, 0, 1)
    else
        font_name:SetShadowColor(0, 0, 0, 0)
        font_status:SetShadowColor(0, 0, 0, 0)
        if CellDB["outline"] == "Outline" then
            flags = "OUTLINE"
        else -- Monochrome Outline
            flags = "OUTLINE,MONOCHROME"
        end
    end

    local font
    if CellDB["font"] == "Cell".._G.DEFAULT then
        font = GameFontNormal:GetFont()
    else
        font = F:GetFont()
    end


    font_name:SetFont(font, layout["font"]["name"], flags)
    font_status:SetFont(font, layout["font"]["status"], flags)
end

-------------------------------------------------
-- events
-------------------------------------------------
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
eventFrame:RegisterEvent("UNIT_PET")

function eventFrame:ADDON_LOADED(arg1)
    if arg1 == addonName then
		eventFrame:UnregisterEvent("ADDON_LOADED")
        if type(CellDB) ~= "table" then CellDB = {} end
        if type(CellCharacterDB) ~= "table" then CellCharacterDB = {} end

        -- general -----------------------------------------------------------------------------
        if type(CellDB["texture"]) ~= "string" then CellDB["texture"] = "Cell ".._G.DEFAULT end
        if type(CellDB["scale"]) ~= "number" then CellDB["scale"] = 1 end
        if type(CellDB["font"]) ~= "string" then CellDB["font"] = "Cell ".._G.DEFAULT end
        if type(CellDB["outline"]) ~= "string" then CellDB["outline"] = "Shadow" end
        if type(CellDB["hideBlizzard"]) ~= "boolean" then CellDB["hideBlizzard"] = true end
        if type(CellDB["disableTooltips"]) ~= "boolean" then CellDB["disableTooltips"] = false end
        if type(CellDB["raidTools"]) ~= "table" then
            CellDB["raidTools"] = {
                ["showRaidSetup"] = true,
                ["showBattleRes"] = true,
                ["showButtons"] = false,
                ["pullTimer"] = {"ERT", 7},
                ["showMarks"] = false,
                ["marks"] = "both",
                ["buttonsPosition"] = {"TOPRIGHT", "CENTER", 0, 0},
                ["marksPosition"] = {"BOTTOMRIGHT", "CENTER", 0, 0},
            }
        end
        -- if type(CellDB["clamped"]) ~= "boolean" then CellDB["clamped"] = false end
        
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
                    ["spacing"] = 4,
                    ["orientation"] = "vertical",
                    ["font"] = {
                        ["name"] = 13,
                        ["status"] = 11,
                    },
                    ["textWidth"] = .75,
                    ["groupFilter"] = {true, true, true, true, true, true, true, true},
                    ["indicators"] = {
                        {
                            ["name"] = "Aggro Bar",
                            ["indicatorName"] = "aggroBar",
                            ["type"] = "built-in",
                            ["enabled"] = true,
                            ["position"] = {"BOTTOMLEFT", "TOPLEFT", 1, 0},
                            ["size"] = {18, 2},
                        },
                        {
                            ["name"] = "AoE Healing",
                            ["indicatorName"] = "aoeHealing",
                            ["type"] = "built-in",
                            ["enabled"] = true,
                            ["height"] = 15,
                            ["color"] = {1, 1, 0},
                        },
                        {
                            ["name"] = "External Cooldowns",
                            ["indicatorName"] = "externalCooldowns",
                            ["type"] = "built-in",
                            ["enabled"] = true,
                            ["position"] = {"RIGHT", "RIGHT", 2, 5},
                            ["size"] = {12, 20},
                            ["num"] = 2,
                        },
                        {
                            ["name"] = "Defensive Cooldowns",
                            ["indicatorName"] = "defensiveCooldowns",
                            ["type"] = "built-in",
                            ["enabled"] = true,
                            ["position"] = {"LEFT", "LEFT", -2, 5},
                            ["size"] = {12, 20},
                            ["num"] = 2,
                        },
                        {
                            ["name"] = "Tank Active Mitigation",
                            ["indicatorName"] = "tankActiveMitigation",
                            ["type"] = "built-in",
                            ["enabled"] = true,
                            ["position"] = {"TOPLEFT", "TOPLEFT", 10, -1},
                            ["size"] = {18, 4},
                        },
                        {
                            ["name"] = "Dispels",
                            ["indicatorName"] = "dispels",
                            ["type"] = "built-in",
                            ["enabled"] = true,
                            ["position"] = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 4},
                            ["size"] = {12, 12},
                            ["dispellableByMe"] = true
                        },
                        {
                            ["name"] = "Debuffs",
                            ["indicatorName"] = "debuffs",
                            ["type"] = "built-in",
                            ["enabled"] = true,
                            ["position"] = {"BOTTOMLEFT", "BOTTOMLEFT", 1, 4},
                            ["size"] = {13, 13},
                            ["num"] = 3,
                            ["font"] = {"Cell ".._G.DEFAULT, 11, "Outline", 2},
                        },
                        {
                            ["name"] = "Central Debuff",
                            ["indicatorName"] = "centralDebuff",
                            ["type"] = "built-in",
                            ["enabled"] = true,
                            ["position"] = {"CENTER", "CENTER", 0, 3},
                            ["size"] = {20, 20},
                            ["font"] = {"Cell ".._G.DEFAULT, 11, "Outline", 2},
                        },
                        -- {
                        --     ["name"] = "233",
                        --     ["indicatorName"] = "indicator8",
                        --     ["type"] = "icon",
                        --     ["enabled"] = true,
                        --     ["position"] = {"TOPRIGHT", "TOPRIGHT", 0, 3},
                        --     ["size"] = {13, 13},
                        --     ["font"] = {"Cell ".._G.DEFAULT, 12, "Outline", 2},
                        --     ["auraType"] = "buff",
                        --     ["castByMe"] = true,
                        --     ["auras"] = {},
                        -- },
                        -- {
                        --     ["name"] = "233",
                        --     ["indicatorName"] = "indicator8",
                        --     ["type"] = "rectangle",
                        --     ["enabled"] = true,
                        --     ["position"] = {"CENTER", "CENTER", 0, 3},
                        --     ["size"] = {18, 18},
                        --     ["colors"] = {{0,1,0}, {1,1,0}, {1,0,0}},
                        --     ["auraType"] = "buff",
                        --     ["auras"] = {},
                        -- },
                    },
                },
            }
        end
        if type(CellCharacterDB["layout"]) ~= "string" then CellCharacterDB["layout"] = "default" end
        if not CellDB["layouts"][CellCharacterDB["layout"]] then CellCharacterDB["layout"] = "default" end

        -- debuffBlacklist ------------------------------------------------------------------------
        if type(CellDB["debuffBlacklist"]) ~= "table" then
            CellDB["debuffBlacklist"] = F:GetDefaultDebuffBlacklist()
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

        -- apply ----------------------------------------------------------------------------------
        F:UpdateLayout()
        Cell.version = GetAddOnMetadata(addonName, "version")
        
        -- revise ---------------------------------------------------------------------------------
        Cell:Fire("Revise")
    end
end

local IsInRaid = IsInRaid
local IsInGroup = IsInGroup
local GetNumGroupMembers = GetNumGroupMembers
local GetRaidRosterInfo = GetRaidRosterInfo
local UnitGUID = UnitGUID
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
        -- update guid
        for i = 1, GetNumGroupMembers() do
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
        F:UpdateRaidSetup()

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

function eventFrame:PLAYER_ENTERING_WORLD()
    eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    F:Debug("PLAYER_ENTERING_WORLD")
    eventFrame:GROUP_ROSTER_UPDATE()
end

local prevSpec
function eventFrame:PLAYER_LOGIN()
    if not prevSpec then prevSpec = GetSpecialization() end
    Cell.vars.playerGUID = UnitGUID("player")
    -- update spec vars
    Cell.vars.playerSpecID, Cell.vars.playerSpecName, _, Cell.vars.playerSpecIcon = GetSpecializationInfo(prevSpec)
    Cell:Fire("UpdateClickCastings")
    -- update indicators
    Cell:Fire("UpdateIndicators")
    -- update texture and font
    Cell:Fire("UpdateAppearance")
    -- update raid tools
    Cell:Fire("UpdateRaidTools")
    -- update raid debuff list
    Cell:Fire("UpdateRaidDebuffs")
    -- hide blizzard
    if CellDB["hideBlizzard"] then F:HideBlizzard() end
end

-- PLAYER_SPECIALIZATION_CHANGED fires when level up, ACTIVE_TALENT_GROUP_CHANGED usually fire twice.
-- NOTE: ACTIVE_TALENT_GROUP_CHANGED fires before PLAYER_LOGIN, but can't GetSpecializationInfo before PLAYER_LOGIN
function eventFrame:ACTIVE_TALENT_GROUP_CHANGED()
    -- not in combat & spec CHANGED
    if not InCombatLockdown() and prevSpec and prevSpec ~= GetSpecialization() then
        prevSpec = GetSpecialization()
        -- update spec vars
        Cell.vars.playerSpecID, Cell.vars.playerSpecName, _, Cell.vars.playerSpecIcon = GetSpecializationInfo(prevSpec)
        
        if not CellDB["clickCastings"][Cell.vars.playerClass]["useCommon"] then
            Cell:Fire("UpdateClickCastings")
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
    if command == "resetposition" then
        Cell.frames.anchorFrame:ClearAllPoints()
        Cell.frames.anchorFrame:SetPoint("TOPLEFT", UIParent, "CENTER")
        Cell.frames.raidButtonsFrame:ClearAllPoints()
        Cell.frames.raidButtonsFrame:SetPoint("TOPRIGHT", UIParent, "CENTER")
        Cell.frames.raidMarksFrame:ClearAllPoints()
        Cell.frames.raidMarksFrame:SetPoint("BOTTOMRIGHT", UIParent, "CENTER")
        
    elseif command == "resetall" then
        Cell.frames.anchorFrame:ClearAllPoints()
        Cell.frames.anchorFrame:SetPoint("TOPLEFT", UIParent, "CENTER")
        Cell.frames.raidButtonsFrame:ClearAllPoints()
        Cell.frames.raidButtonsFrame:SetPoint("TOPRIGHT", UIParent, "CENTER")
        Cell.frames.raidMarksFrame:ClearAllPoints()
        Cell.frames.raidMarksFrame:SetPoint("BOTTOMRIGHT", UIParent, "CENTER")
        CellDB = nil
        CellCharacterDB = nil
        ReloadUI()

    else
        F:Print(L["Available slash commands"]..":\n"..
            "|cFFFFB5C5/cell resetposition|r: "..L["reset Cell position"]..".\n"..
            "|cFFFFB5C5/cell resetall|r: "..L["reset all Cell options and reload UI"].."."
        )
    end
end