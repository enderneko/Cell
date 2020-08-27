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
font_name:SetShadowColor(0, 0, 0)
font_name:SetShadowOffset(1, -1)
font_name:SetJustifyH("CENTER")

local font_status = CreateFont("CELL_FONT_STATUS")
font_status:SetFont(GameFontNormal:GetFont(), 11)
font_status:SetTextColor(1, 1, 1, 1)
font_status:SetShadowColor(0, 0, 0)
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
    Cell:FireEvent("UpdateLayout", Cell.vars.currentLayout)
    
    -- local numGroupMembers = GetNumGroupMembers()
    -- if Cell.vars.numGroupMembers ~= numGroupMembers then
    --     Cell.vars.numGroupMembers = numGroupMembers
    --     -- Cell:FireEvent("GroupSizeChanged", numGroupMembers)
        
    --     if numGroupMembers <= 5 then
    --         if Cell.vars.currentLayout ~= 5 then
    --             F:Debug("UpdateLayout: 5")
    --             Cell.vars.currentLayout = 5
    --             Cell.vars.currentLayoutTable = CellDB["layouts"][5]
    --             Cell:FireEvent("UpdateLayout", 5)
    --         end
            
    --     elseif CellDB["layouts"][30]["enabled"] and numGroupMembers <= 30 then
    --         if Cell.vars.currentLayout ~= 30 then
    --             F:Debug("UpdateLayout: 30")
    --             Cell.vars.currentLayout = 30
    --             Cell.vars.currentLayoutTable = CellDB["layouts"][30]
    --             Cell:FireEvent("UpdateLayout", 30)
    --         end
            
    --     elseif CellDB["layouts"][40]["enabled"] and numGroupMembers <= 40 then
    --         if Cell.vars.currentLayout ~= 40 then
    --             F:Debug("UpdateLayout: 40")
    --             Cell.vars.currentLayout = 40
    --             Cell.vars.currentLayoutTable = CellDB["layouts"][40]
    --             Cell:FireEvent("UpdateLayout", 40)
    --         end
    --     end
    -- end
end

function F:UpdateFontSize()
    local layout = Cell.vars.currentLayoutTable
    font_name:SetFont(font_name:GetFont(), layout["font"]["name"])
    font_status:SetFont(font_status:GetFont(), layout["font"]["status"])
end

-------------------------------------------------
-- events
-------------------------------------------------
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

function eventFrame:ADDON_LOADED(arg1)
    if arg1 == addonName then
		eventFrame:UnregisterEvent("ADDON_LOADED")
        if type(CellDB) ~= "table" then CellDB = {} end

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
                },
            }
        end

        if type(CellDB["texture"]) ~= "string" then CellDB["texture"] = "Cell ".._G.DEFAULT end
        if type(CellDB["scale"]) ~= "number" then CellDB["scale"] = 1 end
        
        Cell.loaded = true
        F:UpdateLayout()
        Cell.vars.playerClass = select(2, UnitClass("player"))
    end
end

function eventFrame:GROUP_ROSTER_UPDATE()
    if IsInRaid() then
        if Cell.vars.groupType ~= "raid" then
            Cell.vars.groupType = "raid"
            Cell:FireEvent("GroupTypeChanged", "raid")
        end
    elseif IsInGroup() then
        if Cell.vars.groupType ~= "party" then
            Cell.vars.groupType = "party"
            Cell:FireEvent("GroupTypeChanged", "party")
        end
    else
        if Cell.vars.groupType ~= "solo" then
            Cell.vars.groupType = "solo"
            Cell:FireEvent("GroupTypeChanged", "solo")
        end
    end

    -- UpdateLayout()
end

function eventFrame:PLAYER_ENTERING_WORLD()
    eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    F:Debug("PLAYER_ENTERING_WORLD")
    eventFrame:GROUP_ROSTER_UPDATE()
    -- update texture
    Cell:FireEvent("UpdateLayout", nil, "texture")
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