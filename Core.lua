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
local IsInRaid = IsInRaid
local IsInGroup = IsInGroup
local GetNumGroupMembers = GetNumGroupMembers

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
            flags = "OUTLINE, MONOCHROME"
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

function eventFrame:ADDON_LOADED(arg1)
    if arg1 == addonName then
		eventFrame:UnregisterEvent("ADDON_LOADED")
        if type(CellDB) ~= "table" then CellDB = {} end
        if type(CellCharacterDB) ~= "table" then CellCharacterDB = {} end

        -- appearance -----------------------------------------------------------------------------
        if type(CellDB["texture"]) ~= "string" then CellDB["texture"] = "Cell ".._G.DEFAULT end
        if type(CellDB["scale"]) ~= "number" then CellDB["scale"] = 1 end
        if type(CellDB["font"]) ~= "string" then CellDB["font"] = "Cell ".._G.DEFAULT end
        if type(CellDB["outline"]) ~= "string" then CellDB["outline"] = "Shadow" end
        if type(CellDB["hideBlizzard"]) ~= "boolean" then CellDB["hideBlizzard"] = true end
        if type(CellDB["disableTooltips"]) ~= "boolean" then CellDB["disableTooltips"] = false end
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
                    ["font"] = {
                        ["name"] = 13,
                        ["status"] = 11,
                    },
                    ["groupFilter"] = {true, true, true, true, true, true, true, true},
                    ["indicators"] = {
                        {
                            ["name"] = L["Aggro Bar"],
                            ["indicatorName"] = "aggroBar",
                            ["type"] = "built-in",
                            ["enabled"] = true,
                            ["position"] = {"BOTTOMLEFT", "TOPLEFT", 1, 0},
                            ["size"] = {18, 2},
                        },
                        {
                            ["name"] = L["External Cooldowns"],
                            ["indicatorName"] = "externalCooldowns",
                            ["type"] = "built-in",
                            ["enabled"] = true,
                            ["position"] = {"RIGHT", "RIGHT", 2, 2},
                            ["size"] = {12, 20},
                            ["num"] = 3,
                        },
                        {
                            ["name"] = L["Defensive Cooldowns"],
                            ["indicatorName"] = "defensiveCooldowns",
                            ["type"] = "built-in",
                            ["enabled"] = true,
                            ["position"] = {"LEFT", "LEFT", 0, 0},
                            ["size"] = {18, 2},
                            ["num"] = 3,
                        },
                        {
                            ["name"] = L["Tank Active Mitigation"],
                            ["indicatorName"] = "tankActiveMitigation",
                            ["type"] = "built-in",
                            ["enabled"] = true,
                            ["position"] = {"TOPLEFT", "TOPLEFT", 10, 0},
                            ["size"] = {18, 3},
                        },
                        {
                            ["name"] = L["Debuffs"],
                            ["indicatorName"] = "debuffs",
                            ["type"] = "built-in",
                            ["enabled"] = true,
                            ["position"] = {"BOTTOMLEFT", "BOTTOMLEFT", 1, 4},
                            ["size"] = {13, 13},
                            ["num"] = 3,
                            ["font"] = {"Cell ".._G.DEFAULT, 11, "Outline", 2},
                        },
                        {
                            ["name"] = L["Central Debuff"],
                            ["indicatorName"] = "centralDebuff",
                            ["type"] = "built-in",
                            ["enabled"] = true,
                            ["position"] = {"CENTER", "CENTER", 0, 3},
                            ["size"] = {18, 18},
                            ["font"] = {"Cell ".._G.DEFAULT, 12, "Outline", 2},
                        },
                    },
                },
            }
        end
        if type(CellCharacterDB["layout"]) ~= "string" then CellCharacterDB["layout"] = "default" end
        if not CellDB["layouts"][CellCharacterDB["layout"]] then CellCharacterDB["layout"] = "default" end

        -- debuffs --------------------------------------------------------------------------------
        if type(CellDB["debuffBlacklist"]) ~= "table" then
            CellDB["debuffBlacklist"] = {
                8326, -- 鬼魂
                57723, -- 筋疲力尽
                57724, -- 心满意足
                264689, -- 疲倦
            }
        end
        
        Cell.vars.debuffBlacklist = {}
        for _, id in pairs(CellDB["debuffBlacklist"]) do
            Cell.vars.debuffBlacklist[GetSpellInfo(id)] = true
        end

        -- apply ----------------------------------------------------------------------------------
        if CellDB["hideBlizzard"] then F:HideBlizzard() end
        F:UpdateLayout()
        Cell.version = GetAddOnMetadata(addonName, "version")
        Cell.loaded = true
    end
end

function eventFrame:GROUP_ROSTER_UPDATE()
    if IsInRaid() then
        if Cell.vars.groupType ~= "raid" then
            Cell.vars.groupType = "raid"
            Cell:Fire("GroupTypeChanged", "raid")
        end
    elseif IsInGroup() then
        if Cell.vars.groupType ~= "party" then
            Cell.vars.groupType = "party"
            Cell:Fire("GroupTypeChanged", "party")
        end
    else
        if Cell.vars.groupType ~= "solo" then
            Cell.vars.groupType = "solo"
            Cell:Fire("GroupTypeChanged", "solo")
        end
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
    -- update spec vars
    Cell.vars.playerSpecID, Cell.vars.playerSpecName, _, Cell.vars.playerSpecIcon = GetSpecializationInfo(prevSpec)
    Cell:Fire("UpdateClickCastings")
    Cell:Fire("UpdateIndicators")
    -- update texture and font
    Cell:Fire("UpdateAppearance")
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
        Cell.frames.anchorFrame:SetPoint("CENTER", UIParent)

    elseif command == "resetall" then
        Cell.frames.anchorFrame:ClearAllPoints()
        Cell.frames.anchorFrame:SetPoint("CENTER", UIParent)
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