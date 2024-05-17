-------------------------------------------------
-- 2024-05-18 02:08:24 GMT+8
-- config
-------------------------------------------------
local point = "TOPRIGHT"
local relativePoint = "TOPLEFT"
local relativeTo = CellMainFrame
local offsetX = -5
local offsetY = 0

-------------------------------------------------
-- function codes
-------------------------------------------------
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

local tooltip = CreateFrame("GameTooltip", "CellClickCastingTips", CellMainFrame, "CellTooltipTemplate,BackdropTemplate")
tooltip:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = P:Scale(1)})
tooltip:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
tooltip:SetBackdropBorderColor(Cell:GetAccentColorRGB())
tooltip:SetOwner(UIParent, "ANCHOR_NONE")

local modifiers = {"", "shift-", "ctrl-", "alt-", "ctrl-shift-", "alt-shift-", "alt-ctrl-", "alt-ctrl-shift-"}
local modifiersDisplay = {"", "Shift|cff777777+|r", "Ctrl|cff777777+|r", "Alt|cff777777+|r", "Ctrl|cff777777+|rShift|cff777777+|r", "Alt|cff777777+|rShift|cff777777+|r", "Alt|cff777777+|rCtrl|cff777777+|r", "Alt|cff777777+|rCtrl|cff777777+|rShift|cff777777+|r"}
local mouseKeyIDs = {
    ["Left"] = 1,
    ["Right"] = 2,
    ["Middle"] = 3,
    ["Button4"] = 4,
    ["Button5"] = 5,
}

local function DecodeKeyboard(fullKey)
    fullKey = string.gsub(fullKey, "alt", "alt-")
    fullKey = string.gsub(fullKey, "ctrl", "ctrl-")
    fullKey = string.gsub(fullKey, "shift", "shift-")
    local modifier, key = strmatch(fullKey, "^(.*-)(.+)$")
    if not modifier then -- no modifier
        modifier = ""
        key = fullKey
    end
    return modifier, key
end

local function DecodeDB(t)
    local modifier, bindKey, bindType, bindAction
    
    if t[1] ~= "notBound" then
        local dash, key
        modifier, dash, key = strmatch(t[1], "^(.*)type(-*)(.+)$")

        if dash == "-" then
            if key == "SCROLLUP" then
                bindKey = "ScrollUp"
            elseif key == "SCROLLDOWN" then
                bindKey = "ScrollDown"
            else
                modifier, bindKey = DecodeKeyboard(key)
            end
        else -- normal mouse button
            bindKey = F:GetIndex(mouseKeyIDs, tonumber(key))
        end
    else
        modifier, bindKey = "", "notBound"
    end

    if not t[3] then
        bindType = "general"
        bindAction = t[2]
    else
        bindType = t[2]
        bindAction = t[3]
    end

    return modifier, bindKey, bindType, bindAction
end

local function ShowTips()
    tooltip:SetOwner(CellMainFrame, "ANCHOR_NONE")
    tooltip:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY)

    local clickCastingTable = Cell.vars.clickCastings["useCommon"] and Cell.vars.clickCastings["common"] or Cell.vars.clickCastings[Cell.vars.playerSpecID]
    for i, t in pairs(clickCastingTable) do
        local modifier, bindKey, bindType, bindAction = DecodeDB(t)

        if bindType == "spell" then
            local modifierDisplay = modifiersDisplay[F:GetIndex(modifiers, modifier)]
            local bindKeyDisplay = strlen(bindKey) == 1 and bindKey or L[bindKey]
            
            local bindActionDisplay, icon
            bindAction, _, icon = GetSpellInfo(bindAction)
            if bindAction then
                bindActionDisplay = bindAction.." |T"..icon..":0|t"
            else
                bindActionDisplay = "|cFFFF3030"..L["Invalid"]
            end
            tooltip:AddDoubleLine(modifierDisplay..bindKeyDisplay, "|cFFFFFFFF"..bindActionDisplay)
        end

    end

    tooltip:Show()
end

local function HideTips()
    tooltip:Hide()
end

F:IterateAllUnitButtons(function(b)
    b:HookScript("OnEnter", ShowTips)
    b:HookScript("OnLeave", HideTips)
end)