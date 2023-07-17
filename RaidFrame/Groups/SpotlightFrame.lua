local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local B = Cell.bFuncs
local P = Cell.pixelPerfectFuncs

local LCG = LibStub("LibCustomGlow-1.0")

local placeholders, assignmentButtons = {}, {}
local menu, target, targettarget, focus, unit, unitpet, unittarget, clear
local tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY
local NONE = strlower(_G.NONE)
-------------------------------------------------
-- spotlightFrame
-------------------------------------------------
local spotlightFrame = CreateFrame("Frame", "CellSpotlightFrame", Cell.frames.mainFrame, "SecureFrameTemplate")
Cell.frames.spotlightFrame = spotlightFrame

local anchorFrame = CreateFrame("Frame", "CellSpotlightAnchorFrame", spotlightFrame)
Cell.frames.spotlightFrameAnchor = anchorFrame
anchorFrame:SetPoint("TOPLEFT", UIParent, "CENTER")
anchorFrame:SetMovable(true)
anchorFrame:SetClampedToScreen(true)

local hoverFrame = CreateFrame("Frame", nil, spotlightFrame, "BackdropTemplate")
hoverFrame:SetPoint("TOP", anchorFrame, 0, 1)
hoverFrame:SetPoint("BOTTOM", anchorFrame, 0, -1)
hoverFrame:SetPoint("LEFT", anchorFrame, -1, 0)
hoverFrame:SetPoint("RIGHT", anchorFrame, 1, 0)
-- Cell:StylizeFrame(hoverFrame, {1,0,0,0.3}, {0,0,0,0})

local config = Cell:CreateButton(anchorFrame, nil, "accent", {20, 10}, false, true, nil, nil, "SecureHandlerAttributeTemplate,SecureHandlerClickTemplate")
config:SetFrameStrata("MEDIUM")
config:SetAllPoints(anchorFrame)
config:RegisterForDrag("LeftButton")
config:SetScript("OnDragStart", function()
    anchorFrame:StartMoving()
    anchorFrame:SetUserPlaced(false)
end)
config:SetScript("OnDragStop", function()
    anchorFrame:StopMovingOrSizing()
    P:SavePosition(anchorFrame, Cell.vars.currentLayoutTable["spotlight"]["position"])
end)
config:SetAttribute("_onclick", [[
    for i = 1, 5 do
        local b = self:GetFrameRef("assignment"..i)
        if b:IsShown() then
            b:Hide()
        else
            b:Show()
        end
    end

    self:GetFrameRef("menu"):Hide()
]])
config:HookScript("OnEnter", function()
    hoverFrame:GetScript("OnEnter")(hoverFrame)
    CellTooltip:SetOwner(config, "ANCHOR_NONE")
    CellTooltip:SetPoint(tooltipPoint, config, tooltipRelativePoint, tooltipX, tooltipY)
    CellTooltip:AddLine(L["Spotlight Frame"])
    CellTooltip:AddLine(L["spotlightTips"])
    CellTooltip:Show()
end)
config:HookScript("OnLeave", function()
    hoverFrame:GetScript("OnLeave")(hoverFrame)
    CellTooltip:Hide()
end)

-------------------------------------------------
-- fadeIn & fadeOut
-------------------------------------------------
local fadingIn, fadedIn, fadingOut, fadedOut
anchorFrame.fadeIn = anchorFrame:CreateAnimationGroup()
anchorFrame.fadeIn.alpha = anchorFrame.fadeIn:CreateAnimation("alpha")
anchorFrame.fadeIn.alpha:SetFromAlpha(0)
anchorFrame.fadeIn.alpha:SetToAlpha(1)
anchorFrame.fadeIn.alpha:SetDuration(0.5)
anchorFrame.fadeIn.alpha:SetSmoothing("OUT")
anchorFrame.fadeIn:SetScript("OnPlay", function()
    anchorFrame.fadeOut:Finish()
    fadingIn = true
end)
anchorFrame.fadeIn:SetScript("OnFinished", function()
    fadingIn = false
    fadingOut = false
    fadedIn = true
    fadedOut = false
    anchorFrame:SetAlpha(1)

    if CellDB["general"]["fadeOut"] and not hoverFrame:IsMouseOver() then
        anchorFrame.fadeOut:Play()
    end
end)

anchorFrame.fadeOut = anchorFrame:CreateAnimationGroup()
anchorFrame.fadeOut.alpha = anchorFrame.fadeOut:CreateAnimation("alpha")
anchorFrame.fadeOut.alpha:SetFromAlpha(1)
anchorFrame.fadeOut.alpha:SetToAlpha(0)
anchorFrame.fadeOut.alpha:SetDuration(0.5)
anchorFrame.fadeOut.alpha:SetSmoothing("OUT")
anchorFrame.fadeOut:SetScript("OnPlay", function()
    anchorFrame.fadeIn:Finish()
    fadingOut = true
end)
anchorFrame.fadeOut:SetScript("OnFinished", function()
    fadingIn = false
    fadingOut = false
    fadedIn = false
    fadedOut = true
    anchorFrame:SetAlpha(0)

    if hoverFrame:IsMouseOver() then
        anchorFrame.fadeIn:Play()
    end
end)

hoverFrame:SetScript("OnEnter", function()
    if not CellDB["general"]["fadeOut"] then return end
    if not (fadingIn or fadedIn) then
        anchorFrame.fadeIn:Play()
    end
end)
hoverFrame:SetScript("OnLeave", function()
    if not CellDB["general"]["fadeOut"] then return end
    if hoverFrame:IsMouseOver() then return end
    if not (fadingOut or fadedOut) then
        anchorFrame.fadeOut:Play()
    end
end)

-------------------------------------------------
-- target frame: drag and set
-------------------------------------------------
local targetFrame = Cell:CreateFrame(nil, spotlightFrame, 50, 20)
targetFrame.label = targetFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
targetFrame.label:SetPoint("CENTER")
targetFrame:EnableMouse(false)

function targetFrame:StartMoving()
    targetFrame:Show()
    local scale = P:GetEffectiveScale()
    targetFrame:SetScript("OnUpdate", function()
        local x, y = GetCursorPosition()
        targetFrame:SetPoint("BOTTOMLEFT", UIParent, x/scale, y/scale)
        targetFrame:SetWidth(targetFrame.label:GetWidth() + 10)
    end)
end

function targetFrame:StopMoving()
    targetFrame:Hide()
    targetFrame:ClearAllPoints()
end

-------------------------------------------------
-- assignment buttons
-------------------------------------------------
local function CreateAssignmentButton(index)
    local b = Cell:CreateButton(spotlightFrame, NONE, "accent-hover", {20, 20}, false, false, nil, nil, "SecureHandlerAttributeTemplate,SecureHandlerClickTemplate")
    b:GetFontString():SetNonSpaceWrap(true)
    b:GetFontString():SetWordWrap(true)
    b:SetToplevel(true)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    b:SetAttribute("index", index)
    b:Hide()

    b:SetAttribute("_onclick", [[
        local menu = self:GetFrameRef("menu")
        
        if button == "LeftButton" then --! show menu
            if menu:IsShown() and menu:GetAttribute("index") == self:GetAttribute("index") then
                menu:Hide()
            else
                menu:ClearAllPoints()
                menu:SetPoint(menu:GetAttribute("point"), self, menu:GetAttribute("anchorPoint"), menu:GetAttribute("xOffset"), menu:GetAttribute("yOffset"))
                menu:Show()
            end
        end

        local index = self:GetAttribute("index")
        -- print(index)
        menu:SetAttribute("index", index)

        if button == "RightButton" then --! clear
            local spotlight = menu:GetFrameRef("spotlight"..index)
            spotlight:SetAttribute("unit", nil)
            spotlight:SetAttribute("refreshOnUpdate", nil)
            menu:GetFrameRef("assignment"..index):SetAttribute("text", "none")
            menu:Hide()

            menu:CallMethod("Save", index, nil)
        end
    ]])

    b:SetScript("OnAttributeChanged", function(self, name, value)
        if name ~= "text" then return end
        b:SetText(value == "none" and NONE or value)
    end)

    --! drag and set
    b:RegisterForDrag("LeftButton", "RightButton")
    b:SetScript("OnDragStart", function(self, button)
        if InCombatLockdown() then return end

        menu:Hide()
        targetFrame:StartMoving()
        -- color, N, frequency, length, thickness
        LCG.PixelGlow_Start(b, Cell:GetAccentColorTable(), 9, 0.25, 8, 2)

        if button == "LeftButton" then
            targetFrame.label:SetText(L["Unit"])
            targetFrame.type = "unit"
        else
            targetFrame.label:SetText(L["Unit's Pet"])
            targetFrame.type = "pet"
        end
    end)
    
    b:SetScript("OnDragStop", function()
        targetFrame:StopMoving()
        LCG.PixelGlow_Stop(b)

        if InCombatLockdown() then return end

        local f = GetMouseFocus()
        if f and f.state and f.state.displayedUnit then
            if targetFrame.type == "unit" then
                unit:SetUnit(b:GetAttribute("index"), f.state.displayedUnit)
            elseif targetFrame.type == "pet" then
                unitpet:SetUnit(b:GetAttribute("index"), f.state.displayedUnit)
            end
        end
    end)

    return b
end

-------------------------------------------------
-- placeholders
-------------------------------------------------
local function CreatePlaceHolder(index)
    local placeholder = CreateFrame("Frame", "CellSpotlightFramePlaceholder"..index, spotlightFrame, "BackdropTemplate")
    placeholder:Hide()
    Cell:StylizeFrame(placeholder, {0, 0, 0, 0.27})

    placeholder.text = placeholder:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    placeholder.text:SetPoint("LEFT")
    placeholder.text:SetPoint("RIGHT")
    placeholder.text:SetWordWrap(true)
    placeholder.text:SetNonSpaceWrap(true)

    return placeholder
end

-------------------------------------------------
-- unitbuttons
-------------------------------------------------
local wrapFrame = CreateFrame("Frame", "CellSpotlightWrapFrame", nil, "SecureHandlerBaseTemplate")

for i = 1, 5 do
    -- placeholder
    placeholders[i] = CreatePlaceHolder(i)

    -- assignment button
    assignmentButtons[i] = CreateAssignmentButton(i)
    assignmentButtons[i]:SetAllPoints(placeholders[i])
    SecureHandlerSetFrameRef(config, "assignment"..i, assignmentButtons[i])
    
    -- unit button
    local b = CreateFrame("Button", "CellSpotlightFrameUnitButton"..i, spotlightFrame, "CellUnitButtonTemplate")
    Cell.unitButtons.spotlight[i] = b
    -- b.type = "spotlight" -- layout setup
    -- b:SetAttribute("unit", "player")
    -- RegisterUnitWatch(b)
    b:SetAllPoints(placeholders[i])
    b.isSpotlight = true --! NOTE: prevent overwrite Cell.vars.guids and Cell.vars.names

    --! 天杀的 Secure Codes
    SecureHandlerSetFrameRef(b, "placeholder", placeholders[i])
    wrapFrame:WrapScript(b, "OnShow", [[
        self:GetFrameRef("placeholder"):Hide()
    ]])
    wrapFrame:WrapScript(b, "OnHide", [[
        if self:GetAttribute("unit") then
            self:GetFrameRef("placeholder"):Show()
        end
    ]])
    wrapFrame:WrapScript(b, "OnAttributeChanged", [[
        if name ~= "unit" then return end
        if self:GetAttribute("unit") and not self:IsShown() then
            self:GetFrameRef("placeholder"):Show()
        else
            self:GetFrameRef("placeholder"):Hide()
        end
    ]])

    b:HookScript("OnAttributeChanged", function(self, name, value)
        if name ~= "unit" then return end
        if type(value) == "string" then
            placeholders[i].text:SetText("|cffA7A7A7"..value)
        else
            placeholders[i].text:SetText("|cffA7A7A7"..NONE)
        end
    end)
end

-------------------------------------------------
-- menu
-------------------------------------------------
menu = CreateFrame("Frame", "CellSpotlightAssignmentMenu", spotlightFrame, "BackdropTemplate,SecureHandlerAttributeTemplate,SecureHandlerShowHideTemplate")
menu:SetFrameStrata("TOOLTIP")
menu:SetClampedToScreen(true)
menu:Hide()

--! assignmentBtn -> spotlightButton
for i = 1, 5 do
    -- assignmentBtn -> menu
    SecureHandlerSetFrameRef(assignmentButtons[i], "menu", menu)
    -- menu -> spotlightButton
    SecureHandlerSetFrameRef(menu, "spotlight"..i, Cell.unitButtons.spotlight[i])
    -- menu -> assignmentBtn
    SecureHandlerSetFrameRef(menu, "assignment"..i, assignmentButtons[i])
end

-- hide
SecureHandlerSetFrameRef(menu, "config", config)
SecureHandlerSetFrameRef(config, "menu", menu)
-- menu:SetAttribute("_onhide", [[
--     for i = 1, 5 do
--         self:GetFrameRef("assignment"..i):Hide()
--     end
-- ]])

-- menu items
target = Cell:CreateButton(menu, L["Target"], "transparent-accent", {20, 20}, true, false, nil, nil, "SecureHandlerAttributeTemplate,SecureHandlerClickTemplate")
P:Point(target, "TOPLEFT", menu, "TOPLEFT", 1, -1)
P:Point(target, "RIGHT", menu, "RIGHT", -1, 0)
target:SetAttribute("_onclick", [[
    local menu = self:GetParent()
    local index = menu:GetAttribute("index")
    local spotlight = menu:GetFrameRef("spotlight"..index)
    spotlight:SetAttribute("unit", "target")
    spotlight:SetAttribute("refreshOnUpdate", nil)
    menu:GetFrameRef("assignment"..index):SetAttribute("text", "target")
    menu:Hide()

    menu:CallMethod("Save", index, "target")
]])

-- NOTE: no EVENT for this kind of targets， use OnUpdate
targettarget = Cell:CreateButton(menu, L["Target of Target"], "transparent-accent", {20, 20}, true, false, nil, nil, "SecureHandlerAttributeTemplate,SecureHandlerClickTemplate")
P:Point(targettarget, "TOPLEFT", target, "BOTTOMLEFT")
P:Point(targettarget, "TOPRIGHT", target, "BOTTOMRIGHT")
targettarget:SetAttribute("_onclick", [[
    local menu = self:GetParent()
    local index = menu:GetAttribute("index")
    local spotlight = menu:GetFrameRef("spotlight"..index)
    spotlight:SetAttribute("unit", "targettarget")
    spotlight:SetAttribute("refreshOnUpdate", true)
    menu:GetFrameRef("assignment"..index):SetAttribute("text", "targettarget")
    menu:Hide()

    menu:CallMethod("Save", index, "targettarget")
]])

focus = Cell:CreateButton(menu, L["Focus"], "transparent-accent", {20, 20}, true, false, nil, nil, "SecureHandlerAttributeTemplate,SecureHandlerClickTemplate")
P:Point(focus, "TOPLEFT", targettarget, "BOTTOMLEFT")
P:Point(focus, "TOPRIGHT", targettarget, "BOTTOMRIGHT")
focus:SetAttribute("_onclick", [[
    local menu = self:GetParent()
    local index = menu:GetAttribute("index")
    local spotlight = menu:GetFrameRef("spotlight"..index)
    spotlight:SetAttribute("unit", "focus")
    spotlight:SetAttribute("refreshOnUpdate", nil)
    menu:GetFrameRef("assignment"..index):SetAttribute("text", "focus")
    menu:Hide()

    menu:CallMethod("Save", index, "focus")
]])

unit = Cell:CreateButton(menu, L["Unit"], "transparent-accent", {20, 20}, true, false, nil, nil, "SecureHandlerAttributeTemplate,SecureHandlerClickTemplate")
P:Point(unit, "TOPLEFT", focus, "BOTTOMLEFT")
P:Point(unit, "TOPRIGHT", focus, "BOTTOMRIGHT")
unit:SetAttribute("_onclick", [[
    local menu = self:GetParent()
    local index = menu:GetAttribute("index")
    menu:GetFrameRef("spotlight"..index):SetAttribute("refreshOnUpdate", nil)
    self:CallMethod("SetUnit", index, "target")
    menu:Hide()
]])
function unit:SetUnit(index, target)
    local unit = F:GetTargetUnitID(target)
    if unit then
        Cell.unitButtons.spotlight[index]:SetAttribute("unit", unit)
        assignmentButtons[index]:SetText(unit)
        menu:Save(index, unit)
    else
        F:Print(L["Invalid unit."])
    end
end

unitpet = Cell:CreateButton(menu, L["Unit's Pet"], "transparent-accent", {20, 20}, true, false, nil, nil, "SecureHandlerAttributeTemplate,SecureHandlerClickTemplate")
P:Point(unitpet, "TOPLEFT", unit, "BOTTOMLEFT")
P:Point(unitpet, "TOPRIGHT", unit, "BOTTOMRIGHT")
unitpet:SetAttribute("_onclick", [[
    local menu = self:GetParent()
    local index = menu:GetAttribute("index")
    menu:GetFrameRef("spotlight"..index):SetAttribute("refreshOnUpdate", nil)
    self:CallMethod("SetUnit", index, "target")
    menu:Hide()
]])
function unitpet:SetUnit(index, target)
    local unit = F:GetTargetPetID(target)
    if unit then
        Cell.unitButtons.spotlight[index]:SetAttribute("unit", unit)
        assignmentButtons[index]:SetText(unit)
        menu:Save(index, unit)
    else
        F:Print(L["Invalid unit."])
    end
end

unittarget = Cell:CreateButton(menu, L["Unit's Target"], "transparent-accent", {20, 20}, true, false, nil, nil, "SecureHandlerAttributeTemplate,SecureHandlerClickTemplate")
P:Point(unittarget, "TOPLEFT", unitpet, "BOTTOMLEFT")
P:Point(unittarget, "TOPRIGHT", unitpet, "BOTTOMRIGHT")
unittarget:SetAttribute("_onclick", [[
    local menu = self:GetParent()
    local index = menu:GetAttribute("index")
    menu:GetFrameRef("spotlight"..index):SetAttribute("refreshOnUpdate", true)
    self:CallMethod("SetUnit", index, "target")
    menu:Hide()
]])
function unittarget:SetUnit(index, target)
    local unit = F:GetTargetUnitID(target)
    if unit then
        if unit == "player" then
            unit = "target"
            Cell.unitButtons.spotlight[index]:SetAttribute("refreshOnUpdate", nil)
        else
            unit = unit.."target"
            -- NOTE: no EVENT for this kind of targets， use OnUpdate
            Cell.unitButtons.spotlight[index]:SetAttribute("refreshOnUpdate", true)
        end
        Cell.unitButtons.spotlight[index]:SetAttribute("unit", unit)
        assignmentButtons[index]:SetText(unit)
        menu:Save(index, unit)
    else
        F:Print(L["Invalid unit."])
    end
end

clear = Cell:CreateButton(menu, L["Clear"], "transparent-accent", {20, 20}, true, false, nil, nil, "SecureHandlerAttributeTemplate,SecureHandlerClickTemplate")
P:Point(clear, "TOPLEFT", unittarget, "BOTTOMLEFT")
P:Point(clear, "TOPRIGHT", unittarget, "BOTTOMRIGHT")
clear:SetAttribute("_onclick", [[
    local menu = self:GetParent()
    local index = menu:GetAttribute("index")
    local spotlight = menu:GetFrameRef("spotlight"..index)
    spotlight:SetAttribute("unit", nil)
    spotlight:SetAttribute("refreshOnUpdate", nil)
    menu:GetFrameRef("assignment"..index):SetAttribute("text", "none")
    menu:Hide()

    menu:CallMethod("Save", index, nil)
]])

menu:RegisterEvent("PLAYER_REGEN_ENABLED")
menu:RegisterEvent("PLAYER_REGEN_DISABLED")
menu:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_DISABLED" then
        unit:SetEnabled(false)
        unittarget:SetEnabled(false)
        unitpet:SetEnabled(false)
    else
        unit:SetEnabled(true)
        unittarget:SetEnabled(true)
        unitpet:SetEnabled(true)
    end
end)

function menu:Save(index, unit)
    Cell.vars.currentLayoutTable["spotlight"]["units"][index] = unit
end

-- update width to show full text
local dumbFS1 = menu:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
dumbFS1:SetText(L["Target of Target"])
local dumbFS2 = menu:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
dumbFS2:SetText(L["Unit's Target"])

function menu:UpdatePixelPerfect()
    P:Size(menu, ceil(max(dumbFS1:GetStringWidth(), dumbFS2:GetStringWidth())) + 13, 20*7+2)

    Cell:StylizeFrame(menu, nil, Cell:GetAccentColorTable())
    target:UpdatePixelPerfect()
    focus:UpdatePixelPerfect()
    targettarget:UpdatePixelPerfect()
    unit:UpdatePixelPerfect()
    unitpet:UpdatePixelPerfect()
    clear:UpdatePixelPerfect()
end

-------------------------------------------------
-- functions
-------------------------------------------------
local function UpdatePosition()
    local layout = Cell.vars.currentLayoutTable
    
    local anchor
    if layout["spotlight"]["sameArrangementAsMain"] then
        anchor = layout["main"]["anchor"]
    else
        anchor = layout["spotlight"]["anchor"]
    end
    
    spotlightFrame:ClearAllPoints()
    -- NOTE: detach from spotlightPreviewAnchor
    P:LoadPosition(anchorFrame, layout["spotlight"]["position"])

    if CellDB["general"]["menuPosition"] == "top_bottom" then
        P:Size(anchorFrame, 20, 10)
        
        if anchor == "BOTTOMLEFT" then
            spotlightFrame:SetPoint("BOTTOMLEFT", anchorFrame, "TOPLEFT", 0, 4)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "TOPLEFT", "BOTTOMLEFT", 0, -3
        elseif anchor == "BOTTOMRIGHT" then
            spotlightFrame:SetPoint("BOTTOMRIGHT", anchorFrame, "TOPRIGHT", 0, 4)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "TOPRIGHT", "BOTTOMRIGHT", 0, -3
        elseif anchor == "TOPLEFT" then
            spotlightFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -4)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "BOTTOMLEFT", "TOPLEFT", 0, 3
        elseif anchor == "TOPRIGHT" then
            spotlightFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT", 0, -4)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "BOTTOMRIGHT", "TOPRIGHT", 0, 3
        end
    else -- left_right
        P:Size(anchorFrame, 10, 20)

        if anchor == "BOTTOMLEFT" then
            spotlightFrame:SetPoint("BOTTOMLEFT", anchorFrame, "BOTTOMRIGHT", 4, 0)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "BOTTOMRIGHT", "BOTTOMLEFT", -3, 0
        elseif anchor == "BOTTOMRIGHT" then
            spotlightFrame:SetPoint("BOTTOMRIGHT", anchorFrame, "BOTTOMLEFT", -4, 0)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "BOTTOMLEFT", "BOTTOMRIGHT", 3, 0
        elseif anchor == "TOPLEFT" then
            spotlightFrame:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT", 4, 0)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "TOPRIGHT", "TOPLEFT", -3, 0
        elseif anchor == "TOPRIGHT" then
            spotlightFrame:SetPoint("TOPRIGHT", anchorFrame, "TOPLEFT", -4, 0)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "TOPLEFT", "TOPRIGHT", 3, 0
        end
    end
end

local function UpdateMenu(which)
    if not which or which == "lock" then
        if CellDB["general"]["locked"] then
            config:RegisterForDrag()
        else
            config:RegisterForDrag("LeftButton")
        end
    end

    if not which or which == "fadeOut" then
        if CellDB["general"]["fadeOut"] then
            anchorFrame.fadeOut:Play()
        else
            anchorFrame.fadeIn:Play()
        end
    end

    if which == "position" then
        UpdatePosition()
    end
end
Cell:RegisterCallback("UpdateMenu", "SpotlightFrame_UpdateMenu", UpdateMenu)

local function UpdateLayout(layout, which)
    layout = Cell.vars.currentLayoutTable

    if not which or strfind(which, "size$") then
        local width, height
        if layout["spotlight"]["sameSizeAsMain"] then
            width, height = unpack(layout["main"]["size"])
        else
            width, height = unpack(layout["spotlight"]["size"])
        end

        P:Size(spotlightFrame, width, height)

        for _, f in pairs(placeholders) do
            P:Size(f, width, height)
        end
    end

    if not which or strfind(which, "arrangement$") then
        local orientation, anchor, spacingX, spacingY
        if layout["spotlight"]["sameArrangementAsMain"] then
            orientation = layout["main"]["orientation"]
            anchor = layout["main"]["anchor"]
            spacingX = layout["main"]["spacingX"]
            spacingY = layout["main"]["spacingY"]
        else
            orientation = layout["spotlight"]["orientation"]
            anchor = layout["spotlight"]["anchor"]
            spacingX = layout["spotlight"]["spacingX"]
            spacingY = layout["spotlight"]["spacingY"]
        end

        -- anchors
        local point, anchorPoint, unitSpacing
        local menuAnchorPoint, menuX, menuY
        
        if orientation == "vertical" then
            if anchor == "BOTTOMLEFT" then
                point, anchorPoint = "BOTTOMLEFT", "TOPLEFT"
                unitSpacing = spacingX
                menuAnchorPoint = "BOTTOMRIGHT"
                menuX, menuY = 4, 0
            elseif anchor == "BOTTOMRIGHT" then
                point, anchorPoint = "BOTTOMRIGHT", "TOPRIGHT"
                unitSpacing = spacingX
                menuAnchorPoint = "BOTTOMLEFT"
                menuX, menuY = -4, 0
            elseif anchor == "TOPLEFT" then
                point, anchorPoint = "TOPLEFT", "BOTTOMLEFT"
                unitSpacing = -spacingX
                menuAnchorPoint = "TOPRIGHT"
                menuX, menuY = 4, 0
            elseif anchor == "TOPRIGHT" then
                point, anchorPoint = "TOPRIGHT", "BOTTOMRIGHT"
                unitSpacing = -spacingX
                menuAnchorPoint = "TOPLEFT"
                menuX, menuY = -4, 0
            end
        else
            if anchor == "BOTTOMLEFT" then
                point, anchorPoint = "BOTTOMLEFT", "BOTTOMRIGHT"
                unitSpacing = spacingX
                menuAnchorPoint = "TOPLEFT"
                menuX, menuY = 0, 4
            elseif anchor == "BOTTOMRIGHT" then
                point, anchorPoint = "BOTTOMRIGHT", "BOTTOMLEFT"
                unitSpacing = -spacingX
                menuAnchorPoint = "TOPRIGHT"
                menuX, menuY = 0, 4
            elseif anchor == "TOPLEFT" then
                point, anchorPoint = "TOPLEFT", "TOPRIGHT"
                unitSpacing = spacingX
                menuAnchorPoint = "BOTTOMLEFT"
                menuX, menuY = 0, -4
            elseif anchor == "TOPRIGHT" then
                point, anchorPoint = "TOPRIGHT", "TOPLEFT"
                unitSpacing = -spacingX
                menuAnchorPoint = "BOTTOMRIGHT"
                menuX, menuY = 0, -4
            end
        end

        menu:SetAttribute("point", point)
        menu:SetAttribute("anchorPoint", menuAnchorPoint)
        menu:SetAttribute("xOffset", menuX)
        menu:SetAttribute("yOffset", menuY)
        menu:Hide()

        local last
        for i, f in pairs(placeholders) do
            f:ClearAllPoints()
            if last then
                if orientation == "vertical" then
                    f:SetPoint(point, last, anchorPoint, 0, unitSpacing)
                else
                    f:SetPoint(point, last, anchorPoint, unitSpacing, 0)
                end
            else
                f:SetPoint("TOPLEFT", spotlightFrame)
            end
            last = f
        end

        UpdatePosition()
    end

    -- NOTE: SetOrientation BEFORE SetPowerSize
    if not which or which == "barOrientation" then
        for _, b in pairs(Cell.unitButtons.spotlight) do
            B:SetOrientation(b, layout["barOrientation"][1], layout["barOrientation"][2])
        end
    end
    
    if not which or strfind(which, "power$") or which == "barOrientation" then
        for _, b in pairs(Cell.unitButtons.spotlight) do
            if layout["spotlight"]["sameSizeAsMain"] then
                B:SetPowerSize(b, layout["main"]["powerSize"])
            else
                B:SetPowerSize(b, layout["spotlight"]["powerSize"])
            end
        end
    end

    if not which or which == "spotlight" then
        if layout["spotlight"]["enabled"] then
            for i = 1, 5 do
                local unit = layout["spotlight"]["units"][i]
                Cell.unitButtons.spotlight[i]:SetAttribute("unit", unit)
                if unit and strfind(unit, "^.+target$") then
                    Cell.unitButtons.spotlight[i]:SetAttribute("refreshOnUpdate", true)
                end
                RegisterUnitWatch(Cell.unitButtons.spotlight[i])
                assignmentButtons[i]:SetText(unit or NONE)
            end
            spotlightFrame:Show()
        else
            for i = 1, 5 do
                Cell.unitButtons.spotlight[i]:SetAttribute("unit", nil)
                Cell.unitButtons.spotlight[i]:SetAttribute("refreshOnUpdate", nil)
                UnregisterUnitWatch(Cell.unitButtons.spotlight[i])
                assignmentButtons[i]:SetText(NONE)
                Cell.unitButtons.spotlight[i]:Hide()
            end
            spotlightFrame:Hide()
            menu:Hide()
        end
    end

    -- load position
    if not P:LoadPosition(anchorFrame, layout["spotlight"]["position"]) then
        P:ClearPoints(anchorFrame)
        -- no position, use default
        anchorFrame:SetPoint("TOPLEFT", UIParent, "CENTER")
    end
end
Cell:RegisterCallback("UpdateLayout", "SpotlightFrame_UpdateLayout", UpdateLayout)

local function UpdatePixelPerfect()
    P:Resize(spotlightFrame)
    P:Resize(anchorFrame)
    targetFrame:UpdatePixelPerfect()
    config:UpdatePixelPerfect()
    menu:UpdatePixelPerfect()

    for _, p in pairs(placeholders) do
        Cell:StylizeFrame(p, {0, 0, 0, 0.27})
    end

    for _, b in pairs(assignmentButtons) do
        b:UpdatePixelPerfect()
    end
end
Cell:RegisterCallback("UpdatePixelPerfect", "SpotlightFrame_UpdatePixelPerfect", UpdatePixelPerfect)

local function UpdateAppearance(which)
    if not which or which == "strata" then
        C_Timer.After(1, function()
            targetFrame:SetFrameStrata("TOOLTIP")
        end)
    end
end
Cell:RegisterCallback("UpdateAppearance", "SpotlightFrame_UpdateAppearance", UpdateAppearance)