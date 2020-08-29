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
			print("|cffbbbbbb" .. arg)
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
    Cell.vars.currentLayout = CellDB["layout"]
    Cell.vars.currentLayoutTable = CellDB["layouts"][CellDB["layout"]]
    Cell:Fire("UpdateLayout", Cell.vars.currentLayout)
    
    -- local numGroupMembers = GetNumGroupMembers()
    -- if Cell.vars.numGroupMembers ~= numGroupMembers then
    --     Cell.vars.numGroupMembers = numGroupMembers
    --     -- Cell:Fire("GroupSizeChanged", numGroupMembers)
        
    --     if numGroupMembers <= 5 then
    --         if Cell.vars.currentLayout ~= 5 then
    --             F:Debug("UpdateLayout: 5")
    --             Cell.vars.currentLayout = 5
    --             Cell.vars.currentLayoutTable = CellDB["layouts"][5]
    --             Cell:Fire("UpdateLayout", 5)
    --         end
            
    --     elseif CellDB["layouts"][30]["enabled"] and numGroupMembers <= 30 then
    --         if Cell.vars.currentLayout ~= 30 then
    --             F:Debug("UpdateLayout: 30")
    --             Cell.vars.currentLayout = 30
    --             Cell.vars.currentLayoutTable = CellDB["layouts"][30]
    --             Cell:Fire("UpdateLayout", 30)
    --         end
            
    --     elseif CellDB["layouts"][40]["enabled"] and numGroupMembers <= 40 then
    --         if Cell.vars.currentLayout ~= 40 then
    --             F:Debug("UpdateLayout: 40")
    --             Cell.vars.currentLayout = 40
    --             Cell.vars.currentLayoutTable = CellDB["layouts"][40]
    --             Cell:Fire("UpdateLayout", 40)
    --         end
    --     end
    -- end
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

    font_name:SetFont(font_name:GetFont(), layout["font"]["name"], flags)
    font_status:SetFont(font_status:GetFont(), layout["font"]["status"], flags)
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

        -- appearance -----------------------------------------------------------------------------
        if type(CellDB["layout"]) ~= "string" then CellDB["layout"] = "default" end
        if type(CellDB["layouts"]) ~= "table" then
            CellDB["layouts"] = {
                ["default"] = {
                    ["size"] = {66, 46},
                    ["spacing"] = 3,
                    ["font"] = {
                        ["name"] = 13,
                        ["status"] = 11,
                    },
                    ["icon"] = {
                        ["center"] = 20,
                        ["debuff"] = 16,
                    },
                    ["groupFilter"] = {true, true, true, true, true, true, true, true},
                },
            }
        end
        
        if type(CellDB["texture"]) ~= "string" then CellDB["texture"] = "Cell ".._G.DEFAULT end
        if type(CellDB["scale"]) ~= "number" then CellDB["scale"] = 1 end
        if type(CellDB["outline"]) ~= "string" then CellDB["outline"] = "Shadow" end
        if type(CellDB["hideBlizzard"]) ~= "boolean" then CellDB["hideBlizzard"] = "true" end
        -- if type(CellDB["clamped"]) ~= "boolean" then CellDB["clamped"] = "false" end
        
        Cell.loaded = true
        if CellDB["hideBlizzard"] then F:HideBlizzard() end
        F:UpdateLayout()
        
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
                CellDB["clickCastings"][Cell.vars.playerClass][specID] = {} 
            end
        end
        Cell.vars.clickCastingTable = CellDB["clickCastings"][Cell.vars.playerClass]
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

    -- UpdateLayout()
end

function eventFrame:PLAYER_ENTERING_WORLD()
    eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    F:Debug("PLAYER_ENTERING_WORLD")
    eventFrame:GROUP_ROSTER_UPDATE()
    -- update texture
    Cell:Fire("UpdateLayout", nil, "texture")
end

function eventFrame:PLAYER_LOGIN()
    -- update vars
    Cell.vars.playerSpecID, Cell.vars.playerSpecName, _, Cell.vars.playerSpecIcon = GetSpecializationInfo(GetSpecialization())
    Cell:Fire("UpdateClickCastings")
end

function eventFrame:ACTIVE_TALENT_GROUP_CHANGED()
    Cell:Fire("UpdateClickCastings")
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
        ReloadUI()

    else
        F:Print(L["Available slash commands"]..":\n"..
            "|cFFFFB5C5/cell resetposition|r: "..L["reset Cell position"]..".\n"..
            "|cFFFFB5C5/cell resetall|r: "..L["reset all Cell options and reload UI"].."."
        )
    end
end