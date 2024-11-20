local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local B = Cell.bFuncs
local A = Cell.animations
local P = Cell.pixelPerfectFuncs

local LCG = LibStub("LibCustomGlow-1.0")

local placeholders, assignmentButtons = {}, {}
local menu, target, targettarget, focus, focustarget, unit, unitname, unitpet, unittarget, tank, boss1target, clear
local tanks, names = {}, {}
local UpdateTanks, UpdateNames
local tankUpdateRequired, nameUpdateRequired
local tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY
local NONE = strlower(_G.NONE)
-------------------------------------------------
-- spotlightFrame
-------------------------------------------------
local spotlightFrame = CreateFrame("Frame", "CellSpotlightFrame", Cell.frames.mainFrame, "SecureFrameTemplate")
Cell.frames.spotlightFrame = spotlightFrame

local anchorFrame = CreateFrame("Frame", "CellSpotlightAnchorFrame", spotlightFrame)
Cell.frames.spotlightFrameAnchor = anchorFrame
PixelUtil.SetPoint(anchorFrame, "TOPLEFT", UIParent, "CENTER", 1, -1)
anchorFrame:SetMovable(true)
anchorFrame:SetClampedToScreen(true)

local hoverFrame = CreateFrame("Frame", nil, spotlightFrame, "BackdropTemplate")
hoverFrame:SetPoint("TOP", anchorFrame, 0, 1)
hoverFrame:SetPoint("BOTTOM", anchorFrame, 0, -1)
hoverFrame:SetPoint("LEFT", anchorFrame, -1, 0)
hoverFrame:SetPoint("RIGHT", anchorFrame, 1, 0)
-- Cell:StylizeFrame(hoverFrame, {1,0,0,0.3}, {0,0,0,0})

A:ApplyFadeInOutToMenu(anchorFrame, hoverFrame)

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
    for i = 1, 15 do
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

    local tips = {
        {L["Left-Click"]..":", L["menu"]},
        {L["Right-Click"]..":", L["clear"]},
        {L["Left-Drag"]..":", L["set unit"].." ("..L["not in combat"]..")"},
        {"Shift+"..L["Left-Drag"]..":", L["set unit's name"].." ("..L["not in combat"]..")"},
        {L["Right-Drag"]..":", L["set unit's pet"].." ("..L["not in combat"]..")"},
    }
    for i = 1, 5 do
        CellTooltip:AddDoubleLine("|cffffb5c5"..tips[i][1], "|cffffffff"..tips[i][2])
    end
    CellTooltip:Show()
end)
config:HookScript("OnLeave", function()
    hoverFrame:GetScript("OnLeave")(hoverFrame)
    CellTooltip:Hide()
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
    local b = Cell:CreateButton(spotlightFrame, "|cffababab"..NONE, "accent-hover", {20, 20}, false, false, nil, nil, "SecureHandlerAttributeTemplate,SecureHandlerClickTemplate")
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
            spotlight:SetAttribute("updateOnTargetChanged", nil)
            menu:GetFrameRef("assignment"..index):SetAttribute("text", "none")
            menu:Hide()

            menu:CallMethod("Save", index, nil)
        end
    ]])

    b:SetScript("OnAttributeChanged", function(self, name, value)
        if name ~= "text" then return end
        b:SetText(value == "none" and "|cffababab"..NONE or value)
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
            if IsShiftKeyDown() then
                targetFrame.label:SetText(L["Unit's Name"])
                targetFrame.type = "name"
            else
                targetFrame.label:SetText(L["Unit"])
                targetFrame.type = "unit"
            end
        else
            targetFrame.label:SetText(L["Unit's Pet"])
            targetFrame.type = "pet"
        end
    end)

    b:SetScript("OnDragStop", function()
        targetFrame:StopMoving()
        LCG.PixelGlow_Stop(b)

        if InCombatLockdown() then return end

        local f = F:GetMouseFocus()

        if f == WorldFrame then
            f = F:GetUnitButtonByGUID(UnitGUID("mouseover") or "")
        end

        if not f then return end -- cursor outside wow window

        local unitId
        if f.states and f.states.displayedUnit then -- Cell
            unitId = f.states.displayedUnit
        elseif f.unit then
            unitId = f.unit
        end

        if unitId then
            if targetFrame.type == "unit" then
                unit:SetUnit(b:GetAttribute("index"), unitId)
            elseif targetFrame.type == "name" then
                unitname:SetUnit(b:GetAttribute("index"), unitId)
            elseif targetFrame.type == "pet" then
                unitpet:SetUnit(b:GetAttribute("index"), unitId)
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

for i = 1, 15 do
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
        if self:GetAttribute("unit") and not self:GetAttribute("hidePlaceholder") then
            self:GetFrameRef("placeholder"):Show()
        end
    ]])
    wrapFrame:WrapScript(b, "OnAttributeChanged", [[
        if name ~= "unit" then return end
        if self:GetAttribute("unit") and not self:IsShown() and not self:GetAttribute("hidePlaceholder") then
            self:GetFrameRef("placeholder"):Show()
        else
            self:GetFrameRef("placeholder"):Hide()
        end
    ]])

    b:HookScript("OnAttributeChanged", function(self, name, value)
        if name ~= "unit" then return end
        if type(value) == "string" then
            placeholders[i].text:SetText("|cffababab"..value)
        else
            placeholders[i].text:SetText("|cffababab"..NONE)
        end

        self.unit = value
        F:UpdateOmniCDPosition("Cell-Spotlight")
    end)
end

-------------------------------------------------
-- menu
-------------------------------------------------
menu = CreateFrame("Frame", "CellSpotlightAssignmentMenu", spotlightFrame, "BackdropTemplate,SecureHandlerAttributeTemplate,SecureHandlerShowHideTemplate")
menu:SetFrameStrata("FULLSCREEN_DIALOG")
menu:SetToplevel(true)
menu:SetClampedToScreen(true)
menu:Hide()

--! assignmentBtn -> spotlightButton
for i = 1, 15 do
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
--     for i = 1, 15 do
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
    spotlight:SetAttribute("updateOnTargetChanged", true)
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
    spotlight:SetAttribute("updateOnTargetChanged", nil)
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
    spotlight:SetAttribute("updateOnTargetChanged", nil)
    menu:GetFrameRef("assignment"..index):SetAttribute("text", "focus")
    menu:Hide()

    menu:CallMethod("Save", index, "focus")
]])

focustarget = Cell:CreateButton(menu, L["Focus Target"], "transparent-accent", {20, 20}, true, false, nil, nil, "SecureHandlerAttributeTemplate,SecureHandlerClickTemplate")
P:Point(focustarget, "TOPLEFT", focus, "BOTTOMLEFT")
P:Point(focustarget, "TOPRIGHT", focus, "BOTTOMRIGHT")
focustarget:SetAttribute("_onclick", [[
    local menu = self:GetParent()
    local index = menu:GetAttribute("index")
    local spotlight = menu:GetFrameRef("spotlight"..index)
    spotlight:SetAttribute("unit", "focustarget")
    spotlight:SetAttribute("refreshOnUpdate", true)
    spotlight:SetAttribute("updateOnTargetChanged", nil)
    menu:GetFrameRef("assignment"..index):SetAttribute("text", "focustarget")
    menu:Hide()

    menu:CallMethod("Save", index, "focustarget")
]])

unit = Cell:CreateButton(menu, L["Unit"], "transparent-accent", {20, 20}, true, false, nil, nil, "SecureHandlerAttributeTemplate,SecureHandlerClickTemplate")
P:Point(unit, "TOPLEFT", focustarget, "BOTTOMLEFT")
P:Point(unit, "TOPRIGHT", focustarget, "BOTTOMRIGHT")
unit:SetAttribute("_onclick", [[
    local menu = self:GetParent()
    local index = menu:GetAttribute("index")
    local spotlight = menu:GetFrameRef("spotlight"..index)
    spotlight:SetAttribute("refreshOnUpdate", nil)
    spotlight:SetAttribute("updateOnTargetChanged", nil)
    self:CallMethod("SetUnit", index, "target")
    menu:Hide()
]])
function unit:SetUnit(index, target)
    local unitId = F:GetTargetUnitID(target)
    if unitId then
        Cell.unitButtons.spotlight[index]:SetAttribute("unit", unitId)
        assignmentButtons[index]:SetText(unitId)
        menu:Save(index, unitId)
    else
        F:Print(L["Invalid unit."])
    end
end
function spotlightFrame:ToggleUnit(target)
    local firstAvailable
    for i, f in pairs(Cell.unitButtons.spotlight) do
        local unit = f:GetAttribute("unit")
        if not unit and not firstAvailable then
            firstAvailable = i
        end
        if unit and unit == target then
            f:SetAttribute("unit", nil)
            f:SetAttribute("refreshOnUpdate", nil)
            f:SetAttribute("updateOnTargetChanged", nil)
            assignmentButtons[i]:SetText("none")
            menu:Save(i, nil)
            return
        end
    end
    unit:SetUnit(firstAvailable, target)
end

unitname = Cell:CreateButton(menu, L["Unit's Name"], "transparent-accent", {20, 20}, true, false, nil, nil, "SecureHandlerAttributeTemplate,SecureHandlerClickTemplate")
P:Point(unitname, "TOPLEFT", unit, "BOTTOMLEFT")
P:Point(unitname, "TOPRIGHT", unit, "BOTTOMRIGHT")
unitname:SetAttribute("_onclick", [[
    local menu = self:GetParent()
    local index = menu:GetAttribute("index")
    local spotlight = menu:GetFrameRef("spotlight"..index)
    spotlight:SetAttribute("refreshOnUpdate", nil)
    spotlight:SetAttribute("updateOnTargetChanged", nil)
    self:CallMethod("SetUnit", index, "target")
    menu:Hide()
]])
function unitname:SetUnit(index, target)
    local unitId = F:GetTargetUnitID(target)
    if unitId and (UnitIsPlayer(unitId) or UnitInPartyIsAI(unitId)) then
        local name = GetUnitName(unitId, true)
        Cell.unitButtons.spotlight[index]:SetAttribute("unit", unitId)
        assignmentButtons[index]:SetText(name)
        menu:Save(index, ":"..name)

        local previous = names[name]
        names[name] = index

        if previous and previous ~= index then -- exists, remove previous
            Cell.unitButtons.spotlight[previous]:SetAttribute("unit", nil)
            assignmentButtons[previous]:SetText("|cffababab"..NONE)
            menu:Save(previous, nil)
        end
    else
        F:Print(L["Invalid unit."])
    end
end
function spotlightFrame:ToggleUnitName(target)
    local unitId = F:GetTargetUnitID(target)
    if unitId and (UnitIsPlayer(unitId) or UnitInPartyIsAI(unitId)) then
        local name = GetUnitName(unitId, true)
        local existing = names[name]
        if existing then
            local f = Cell.unitButtons.spotlight[existing]
            f:SetAttribute("unit", nil)
            f:SetAttribute("refreshOnUpdate", nil)
            f:SetAttribute("updateOnTargetChanged", nil)
            assignmentButtons[existing]:SetText("none")
            menu:Save(existing, nil)
            return
        end

        for i, f in pairs(Cell.unitButtons.spotlight) do
            local unit = f:GetAttribute("unit")
            if not unit then
                unitname:SetUnit(i, target)
                return
            end
        end
    else
        F:Print(L["Invalid unit."])
    end
end

unitpet = Cell:CreateButton(menu, L["Unit's Pet"], "transparent-accent", {20, 20}, true, false, nil, nil, "SecureHandlerAttributeTemplate,SecureHandlerClickTemplate")
P:Point(unitpet, "TOPLEFT", unitname, "BOTTOMLEFT")
P:Point(unitpet, "TOPRIGHT", unitname, "BOTTOMRIGHT")
unitpet:SetAttribute("_onclick", [[
    local menu = self:GetParent()
    local index = menu:GetAttribute("index")
    local spotlight = menu:GetFrameRef("spotlight"..index)
    spotlight:SetAttribute("refreshOnUpdate", nil)
    spotlight:SetAttribute("updateOnTargetChanged", nil)
    self:CallMethod("SetUnit", index, "target")
    menu:Hide()
]])
function unitpet:SetUnit(index, target)
    local unitId = F:GetTargetPetID(target)
    if unitId then
        Cell.unitButtons.spotlight[index]:SetAttribute("unit", unitId)
        assignmentButtons[index]:SetText(unitId)
        menu:Save(index, unitId)
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
    self:CallMethod("SetUnit", index, "target")
    menu:Hide()
]])
function unittarget:SetUnit(index, target)
    local unitId = F:GetTargetUnitID(target)
    if unitId then
        if unitId == "player" then
            unitId = "target"
            Cell.unitButtons.spotlight[index]:SetAttribute("refreshOnUpdate", nil)
            Cell.unitButtons.spotlight[index]:SetAttribute("updateOnTargetChanged", true)
        else
            unitId = unitId.."target"
            -- NOTE: no EVENT for this kind of targets， use OnUpdate
            Cell.unitButtons.spotlight[index]:SetAttribute("refreshOnUpdate", true)
            Cell.unitButtons.spotlight[index]:SetAttribute("updateOnTargetChanged", nil)
        end
        Cell.unitButtons.spotlight[index]:SetAttribute("unit", unitId)
        assignmentButtons[index]:SetText(unitId)
        menu:Save(index, unitId)
    else
        F:Print(L["Invalid unit."])
    end
end

tank = Cell:CreateButton(menu, _G.TANK, "transparent-accent", {20, 20}, true, false, nil, nil, "SecureHandlerAttributeTemplate,SecureHandlerClickTemplate")
P:Point(tank, "TOPLEFT", unittarget, "BOTTOMLEFT")
P:Point(tank, "TOPRIGHT", unittarget, "BOTTOMRIGHT")
tank:SetEnabled(not Cell.isVanilla)
tank:SetAttribute("_onclick", [[
    local menu = self:GetParent()
    local index = menu:GetAttribute("index")
    local spotlight = menu:GetFrameRef("spotlight"..index)
    spotlight:SetAttribute("refreshOnUpdate", nil)
    spotlight:SetAttribute("updateOnTargetChanged", nil)
    menu:GetFrameRef("assignment"..index):SetAttribute("text", "tank")
    self:CallMethod("SetUnit", index)
    menu:Hide()
]])
function tank:SetUnit(index)
    tanks[index] = true
    tankUpdateRequired = true
    UpdateTanks()
    menu:Save(index, "tank")
end

boss1target = Cell:CreateButton(menu, L["Boss1 Target"], "transparent-accent", {20, 20}, true, false, nil, nil, "SecureHandlerAttributeTemplate,SecureHandlerClickTemplate")
P:Point(boss1target, "TOPLEFT", tank, "BOTTOMLEFT")
P:Point(boss1target, "TOPRIGHT", tank, "BOTTOMRIGHT")
boss1target:SetEnabled(not Cell.isVanilla)
boss1target:SetAttribute("_onclick", [[
    local menu = self:GetParent()
    local index = menu:GetAttribute("index")
    local spotlight = menu:GetFrameRef("spotlight"..index)
    spotlight:SetAttribute("unit", "boss1target")
    spotlight:SetAttribute("refreshOnUpdate", true)
    spotlight:SetAttribute("updateOnTargetChanged", nil)
    menu:GetFrameRef("assignment"..index):SetAttribute("text", "boss1target")
    menu:Hide()

    menu:CallMethod("Save", index, "boss1target")
]])

clear = Cell:CreateButton(menu, L["Clear"], "transparent-accent", {20, 20}, true, false, nil, nil, "SecureHandlerAttributeTemplate,SecureHandlerClickTemplate")
P:Point(clear, "TOPLEFT", boss1target, "BOTTOMLEFT")
P:Point(clear, "TOPRIGHT", boss1target, "BOTTOMRIGHT")
clear:SetAttribute("_onclick", [[
    local menu = self:GetParent()
    local index = menu:GetAttribute("index")
    local spotlight = menu:GetFrameRef("spotlight"..index)
    spotlight:SetAttribute("unit", nil)
    spotlight:SetAttribute("refreshOnUpdate", nil)
    spotlight:SetAttribute("updateOnTargetChanged", nil)
    menu:GetFrameRef("assignment"..index):SetAttribute("text", "none")
    menu:Hide()

    menu:CallMethod("Save", index, nil)
]])

-------------------------------------------------
-- functions
-------------------------------------------------
UpdateTanks = function()
    if not tankUpdateRequired then return end

    -- search for tanks
    local units = {}
    for unit in F:IterateGroupMembers() do
        if UnitGroupRolesAssigned(unit) == "TANK" then
            tinsert(units, unit)
        end
    end

    -- assign
    local n = 1
    for index = 1, 15 do
        if InCombatLockdown() then
            tankUpdateRequired = true
            return
        end

        if tanks[index] then
            if units[n] then
                Cell.unitButtons.spotlight[index]:SetAttribute("unit", units[n])
            else
                Cell.unitButtons.spotlight[index]:SetAttribute("unit", nil)
            end
            n = n + 1
        end
    end

    tankUpdateRequired = nil
end

UpdateNames = function()
    if not nameUpdateRequired then return end

    -- search for names
    local found = {}
    for unit in F:IterateGroupMembers() do
        if InCombatLockdown() then
            nameUpdateRequired = true
            return
        end
        local name = GetUnitName(unit, true)
        if names[name] then
            Cell.unitButtons.spotlight[names[name]]:SetAttribute("unit", unit)
            found[name] = true
        end
    end

    -- hide not found
    for name, index in pairs(names) do
        if InCombatLockdown() then
            nameUpdateRequired = true
            return
        end
        if not found[name] then
            Cell.unitButtons.spotlight[index]:SetAttribute("unit", nil)
        end
    end

    nameUpdateRequired = nil
end

local timer
local function UpdateAll()
    timer = nil
    tankUpdateRequired = true
    UpdateTanks()
    nameUpdateRequired = true
    UpdateNames()
end

menu:RegisterEvent("GROUP_ROSTER_UPDATE")
menu:RegisterEvent("PLAYER_REGEN_ENABLED")
menu:RegisterEvent("PLAYER_REGEN_DISABLED")
menu:SetScript("OnEvent", function(self, event)
    if event == "GROUP_ROSTER_UPDATE" then
        if timer then
            timer:Cancel()
        end
        timer = C_Timer.NewTimer(1, UpdateAll)
    elseif event == "PLAYER_REGEN_DISABLED" then
        unit:SetEnabled(false)
        unitname:SetEnabled(false)
        unittarget:SetEnabled(false)
        unitpet:SetEnabled(false)
        tank:SetEnabled(false)
    elseif event == "PLAYER_REGEN_ENABLED" then
        unit:SetEnabled(true)
        unitname:SetEnabled(true)
        unittarget:SetEnabled(true)
        unitpet:SetEnabled(true)
        tank:SetEnabled(not Cell.isVanilla)
        UpdateTanks()
        UpdateNames()
    end
end)

function menu:Save(index, unit)
    Cell.vars.currentLayoutTable["spotlight"]["units"][index] = unit

    -- clear
    if unit ~= "tank" then
        tanks[index] = nil
    end
    for n, i in pairs(names) do
        if i == index then
            names[n] = nil
        end
    end
end

-- update width to show full text
local dumbFS1 = menu:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
dumbFS1:SetText(L["Target of Target"])
local dumbFS2 = menu:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
dumbFS2:SetText(L["Unit's Target"])

function menu:UpdatePixelPerfect()
    P:Size(menu, ceil(max(dumbFS1:GetStringWidth(), dumbFS2:GetStringWidth())) + 13, 20*11+2)

    Cell:StylizeFrame(menu, nil, Cell:GetAccentColorTable())
    target:UpdatePixelPerfect()
    focus:UpdatePixelPerfect()
    targettarget:UpdatePixelPerfect()
    unit:UpdatePixelPerfect()
    unitpet:UpdatePixelPerfect()
    clear:UpdatePixelPerfect()
end

-------------------------------------------------
-- callbacks
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

local previousLayout
local function UpdateLayout(layout, which)
    -- if previousLayout == layout and not which then return end
    -- previousLayout = layout

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
        local point, anchorPoint, groupPoint, unitSpacingX, unitSpacingY
        local menuAnchorPoint, menuX, menuY

        if strfind(orientation, "^vertical") then
            if anchor == "BOTTOMLEFT" then
                point, anchorPoint = "BOTTOMLEFT", "TOPLEFT"
                groupPoint = "BOTTOMRIGHT"
                unitSpacingX = spacingX
                unitSpacingY = spacingY
                menuAnchorPoint = "BOTTOMRIGHT"
                menuX, menuY = 4, 0
            elseif anchor == "BOTTOMRIGHT" then
                point, anchorPoint = "BOTTOMRIGHT", "TOPRIGHT"
                groupPoint = "BOTTOMLEFT"
                unitSpacingX = -spacingX
                unitSpacingY = spacingY
                menuAnchorPoint = "BOTTOMLEFT"
                menuX, menuY = -4, 0
            elseif anchor == "TOPLEFT" then
                point, anchorPoint = "TOPLEFT", "BOTTOMLEFT"
                groupPoint = "TOPRIGHT"
                unitSpacingX = spacingX
                unitSpacingY = -spacingY
                menuAnchorPoint = "TOPRIGHT"
                menuX, menuY = 4, 0
            elseif anchor == "TOPRIGHT" then
                point, anchorPoint = "TOPRIGHT", "BOTTOMRIGHT"
                groupPoint = "TOPLEFT"
                unitSpacingX = -spacingX
                unitSpacingY = -spacingY
                menuAnchorPoint = "TOPLEFT"
                menuX, menuY = -4, 0
            end
        else
            if anchor == "BOTTOMLEFT" then
                point, anchorPoint = "BOTTOMLEFT", "BOTTOMRIGHT"
                groupPoint = "TOPLEFT"
                unitSpacingX = spacingX
                unitSpacingY = spacingY
                menuAnchorPoint = "TOPLEFT"
                menuX, menuY = 0, 4
            elseif anchor == "BOTTOMRIGHT" then
                point, anchorPoint = "BOTTOMRIGHT", "BOTTOMLEFT"
                groupPoint = "TOPRIGHT"
                unitSpacingX = -spacingX
                unitSpacingY = spacingY
                menuAnchorPoint = "TOPRIGHT"
                menuX, menuY = 0, 4
            elseif anchor == "TOPLEFT" then
                point, anchorPoint = "TOPLEFT", "TOPRIGHT"
                groupPoint = "BOTTOMLEFT"
                unitSpacingX = spacingX
                unitSpacingY = -spacingY
                menuAnchorPoint = "BOTTOMLEFT"
                menuX, menuY = 0, -4
            elseif anchor == "TOPRIGHT" then
                point, anchorPoint = "TOPRIGHT", "TOPLEFT"
                groupPoint = "BOTTOMRIGHT"
                unitSpacingX = -spacingX
                unitSpacingY = -spacingY
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
                if strfind(orientation, "^vertical") then
                    if i % 5 == 1 and orientation == "vertical" then
                        f:SetPoint(point, placeholders[i-5], groupPoint, unitSpacingX, 0)
                    else
                        f:SetPoint(point, last, anchorPoint, 0, unitSpacingY)
                    end
                else
                    if i % 5 == 1 and orientation == "horizontal" then
                        f:SetPoint(point, placeholders[i-5], groupPoint, 0, unitSpacingY)
                    else
                        f:SetPoint(point, last, anchorPoint, unitSpacingX, 0)
                    end
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

    if not which or strfind(which, "power$") or which == "barOrientation" or which == "powerFilter" then
        for _, b in pairs(Cell.unitButtons.spotlight) do
            if layout["spotlight"]["sameSizeAsMain"] then
                B:SetPowerSize(b, layout["main"]["powerSize"])
            else
                B:SetPowerSize(b, layout["spotlight"]["powerSize"])
            end
        end
    end

    if not which or which == "spotlight" then
        wipe(tanks)
        wipe(names)

        if layout["spotlight"]["enabled"] then
            for i = 1, 15 do
                local unit = layout["spotlight"]["units"][i]
                Cell.unitButtons.spotlight[i]:SetAttribute("hidePlaceholder", layout["spotlight"]["hidePlaceholder"])

                Cell.unitButtons.spotlight[i]:SetAttribute("refreshOnUpdate", nil)
                Cell.unitButtons.spotlight[i]:SetAttribute("updateOnTargetChanged", nil)

                if unit == "tank" then -- tank
                    tanks[i] = true
                elseif unit and strfind(unit, "^:") then -- name
                    unit = strsub(unit, 2)
                    names[unit] = i
                else -- unitid
                    Cell.unitButtons.spotlight[i]:SetAttribute("unit", unit)
                    if unit and strfind(unit, "^.+target$") then
                        Cell.unitButtons.spotlight[i]:SetAttribute("refreshOnUpdate", true)
                    elseif unit == "target" then
                        Cell.unitButtons.spotlight[i]:SetAttribute("updateOnTargetChanged", true)
                    end
                end
                RegisterUnitWatch(Cell.unitButtons.spotlight[i])
                assignmentButtons[i]:SetText(unit or "|cffababab"..NONE)
            end
            tankUpdateRequired = true
            UpdateTanks()
            nameUpdateRequired = true
            UpdateNames()
            spotlightFrame:Show()
        else
            for i = 1, 15 do
                Cell.unitButtons.spotlight[i]:SetAttribute("unit", nil)
                Cell.unitButtons.spotlight[i]:SetAttribute("refreshOnUpdate", nil)
                Cell.unitButtons.spotlight[i]:SetAttribute("updateOnTargetChanged", nil)
                UnregisterUnitWatch(Cell.unitButtons.spotlight[i])
                assignmentButtons[i]:SetText("|cffababab"..NONE)
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
        C_Timer.After(0.5, function()
            targetFrame:SetFrameStrata("TOOLTIP")
            if not InCombatLockdown() then
                menu:SetFrameStrata("FULLSCREEN_DIALOG")
                menu:SetToplevel(true)
            end
        end)
    end
end
Cell:RegisterCallback("UpdateAppearance", "SpotlightFrame_UpdateAppearance", UpdateAppearance)
