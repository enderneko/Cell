local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs
local LGIST = LibStub:GetLibrary("LibGroupInSpecT-1.1")

local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local UnitIsConnected = UnitIsConnected
local UnitIsVisible = UnitIsVisible
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitGUID = UnitGUID
local UnitClass = UnitClass
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local AuraUtil_FindAura = AuraUtil.FindAura

-- 21562: Power Word: Fortitude
-- 1459: Arcane Brilliance
-- 6673: Battle Shout
local enabled
local buttons = {}
local available = {}
local myUnit = ""
-------------------------------------------------
-- required buffs
-------------------------------------------------

local requiredBuffs = {
    [250] = "BS", -- Blood
    [251] = "BS", -- Frost
    [252] = "BS", -- Unholy

    [577] = "BS", -- Havoc
    [581] = "BS", -- Vengeance

    [102] = "AB", -- Balance
    [103] = "BS", -- Feral
    [104] = "BS", -- Guardian
    [105] = "AB", -- Restoration

    [253] = "BS", -- Beast Mastery
    [254] = "BS", -- Marksmanship
    [255] = "BS", -- Survival

    [62] = "AB", -- Arcane
    [63] = "AB", -- Fire
    [64] = "AB", -- Frost

    [268] = "BS", -- Brewmaster
    [269] = "BS", -- Windwalker
    [270] = "AB", -- Mistweaver

    [65] = "AB", -- Holy
    [66] = "BS", -- Protection
    [70] = "BS", -- Retribution

    [256] = "AB", -- Discipline
    [257] = "AB", -- Holy
    [258] = "AB", -- Shadow

    [259] = "BS", -- Assassination
    [260] = "BS", -- Outlaw
    [261] = "BS", -- Subtlety

    [262] = "AB", -- Elemental
    [263] = "BS", -- Enhancement
    [264] = "AB", -- Restoration

    [265] = "AB", -- Affliction
    [266] = "AB", -- Demonology
    [267] = "AB", -- Destruction

    [71] = "BS", -- Arms
    [72] = "BS", -- Fury
    [73] = "BS", -- Protection
}

local unaffected = {
    ["PWF"] = {},
    ["AB"] = {},
    ["BS"] = {},
}
CELL_UNAFFECTED = unaffected

-------------------------------------------------
-- frame
-------------------------------------------------
local buffTrackerFrame = CreateFrame("Frame", "CellBuffTrackerFrame", Cell.frames.mainFrame, "BackdropTemplate")
Cell.frames.buffTrackerFrame = buffTrackerFrame
buffTrackerFrame:SetSize(102, 50)
buffTrackerFrame:SetPoint("BOTTOMLEFT", UIParent, "CENTER")
buffTrackerFrame:SetClampedToScreen(true)
buffTrackerFrame:SetMovable(true)
buffTrackerFrame:RegisterForDrag("LeftButton")
buffTrackerFrame:SetScript("OnDragStart", function()
    buffTrackerFrame:StartMoving()
    buffTrackerFrame:SetUserPlaced(false)
end)
buffTrackerFrame:SetScript("OnDragStop", function()
    buffTrackerFrame:StopMovingOrSizing()
    P:SavePosition(buffTrackerFrame, CellDB["raidTools"]["buffTrackerPosition"])
end)

-------------------------------------------------
-- mover
-------------------------------------------------
buffTrackerFrame.moverText = buffTrackerFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
buffTrackerFrame.moverText:SetPoint("TOP", 0, -3)
buffTrackerFrame.moverText:SetText(L["Mover"])
buffTrackerFrame.moverText:Hide()

local function ShowMover(show)
    if show then
        if not CellDB["raidTools"]["showBuffTracker"] then return end
        buffTrackerFrame:EnableMouse(true)
        buffTrackerFrame.moverText:Show()
        Cell:StylizeFrame(buffTrackerFrame, {0, 1, 0, .4}, {0, 0, 0, 0})
        if not IsInGroup() then
            buttons["PWF"]:Reset()
            buttons["AB"]:Reset()
            buttons["BS"]:Reset()
            buttons["PWF"]:Show()
            buttons["AB"]:Show()
            buttons["BS"]:Show()
        end
    else
        buffTrackerFrame:EnableMouse(false)
        buffTrackerFrame.moverText:Hide()
        Cell:StylizeFrame(buffTrackerFrame, {0, 0, 0, 0}, {0, 0, 0, 0})
        if not (enabled and IsInGroup()) then
            buttons["PWF"]:Hide()
            buttons["AB"]:Hide()
            buttons["BS"]:Hide()
        end
    end
end
Cell:RegisterCallback("ShowMover", "BuffTracker_ShowMover", ShowMover)

-------------------------------------------------
-- buttons
-------------------------------------------------
buttons["PWF"] = Cell:CreateBuffButton(buffTrackerFrame, {32, 32}, 21562)
buttons["PWF"]:SetPoint("BOTTOMLEFT")
buttons["PWF"]:Hide()
buttons["PWF"]:SetTooltip(unaffected["PWF"])
buttons["PWF"].glowColor = {1, 1, 1}

buttons["AB"] = Cell:CreateBuffButton(buffTrackerFrame, {32, 32}, 1459)
buttons["AB"]:SetPoint("BOTTOMLEFT", buttons["PWF"], "BOTTOMRIGHT", 3, 0)
buttons["AB"]:Hide()
buttons["AB"]:SetTooltip(unaffected["AB"])
buttons["AB"].glowColor = {.25, .78, .92}

buttons["BS"] = Cell:CreateBuffButton(buffTrackerFrame, {32, 32}, 6673)
buttons["BS"]:SetPoint("BOTTOMLEFT", buttons["AB"], "BOTTOMRIGHT", 3, 0)
buttons["BS"]:Hide()
buttons["BS"]:SetTooltip(unaffected["BS"])
buttons["BS"].glowColor = {.78, .61, .43}

local function UpdateButton(name)
    if not available[name] then
        buttons[name]:SetDesaturated(true)
        buttons[name]:SetAlpha(.5)
        return
    end

    buttons[name]:SetDesaturated(false)

    local n = F:Getn(unaffected[name])
    if n == 0 then
        buttons[name].count:SetText("")
        buttons[name]:SetAlpha(.7)
        buttons[name]:StopGlow()
    else
        buttons[name].count:SetText(n)
        buttons[name]:SetAlpha(1)
        if unaffected[name][myUnit] then
            -- color, N, frequency, length, thickness
            buttons[name]:StartGlow("Pixel", buttons[name].glowColor, 8, 0.25, 8, 2)
        else
            buttons[name]:StopGlow()
        end
    end
end

-------------------------------------------------
-- check
-------------------------------------------------
local unitSpecs = {}

local function predicate(...)
    local idToFind = ...
    local id = select(13, ...)
    return idToFind == id
end

local function CheckUnit(unit, updateBtn)
    if not (available["PWF"] or available["AB"] or available["BS"]) then return end

    if UnitIsConnected(unit) and UnitIsVisible(unit) and not UnitIsDeadOrGhost(unit) then
        local guid = UnitGUID(unit)
        local required = unitSpecs[unit] and requiredBuffs[unitSpecs[unit]] or ""
        if available["PWF"] then
            -- if class then
            --     name = RAID_CLASS_COLORS[class]:WrapTextInColorCode(Ambiguate(i, "short"))
            -- end
            -- name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod = UnitAura
            -- NOTE: FrameXML/AuraUtil.lua
            -- AuraUtil.FindAura(predicate, unit, filter, predicateArg1, predicateArg2, predicateArg3)
            -- predicate(predicateArg1, predicateArg2, predicateArg3, ...)
            if not AuraUtil_FindAura(predicate, unit, "HELPFUL", 21562) then
                unaffected["PWF"][unit] = true
            else
                unaffected["PWF"][unit] = nil
            end
        end
        if available["AB"] then
            if not AuraUtil_FindAura(predicate, unit, "HELPFUL", 1459) then
                unaffected["AB"][unit] = true
            else
                unaffected["AB"][unit] = nil
            end
        end
        if available["BS"] then
            if not AuraUtil_FindAura(predicate, unit, "HELPFUL", 6673) then
                unaffected["BS"][unit] = true
            else
                unaffected["BS"][unit] = nil
            end
        end
    else
        unaffected["PWF"][unit] = nil
        unaffected["AB"][unit] = nil
        unaffected["BS"][unit] = nil
    end
    
    if updateBtn then
        UpdateButton("PWF")
        UpdateButton("AB")
        UpdateButton("BS")
    end
end

local function IterateAllUnits()
    available["PWF"], available["AB"], available["BS"] = false, false, false
    myUnit = ""

    for unit in F:IterateGroupMembers() do
        if UnitIsConnected(unit) and UnitIsVisible(unit) and not UnitIsDeadOrGhost(unit) then
            if select(2, UnitClass(unit)) == "PRIEST" then
                available["PWF"] = true
            end
            if select(2, UnitClass(unit)) == "MAGE" then
                available["AB"] = true
            end
            if select(2, UnitClass(unit)) == "WARRIOR" then
                available["BS"] = true
            end
            -- if available["PWF"] and available["AB"] and available["BS"] then break end
            if UnitIsUnit("player", unit) then
                myUnit = unit
            end
        end
    end
    
    wipe(unaffected["PWF"])
    wipe(unaffected["AB"])
    wipe(unaffected["BS"])
    for unit in F:IterateGroupMembers() do
        CheckUnit(unit)
    end

    UpdateButton("PWF")
    UpdateButton("AB")
    UpdateButton("BS")
end

-------------------------------------------------
-- events
-------------------------------------------------
function buffTrackerFrame:UnitUpdated(event, guid, unit, info)
    --    print(event, guid, unit, info.global_spec_id)
    if unitSpecs[unit] ~= info.global_spec_id then
        unitSpecs[unit] = info.global_spec_id
        if unit == "player" and UnitIsUnit("player", myUnit) then
            CheckUnit(myUnit, true)
        end
    end
end

function buffTrackerFrame:PLAYER_ENTERING_WORLD()
    buffTrackerFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    buffTrackerFrame:GROUP_ROSTER_UPDATE()
end

local timer
function buffTrackerFrame:GROUP_ROSTER_UPDATE(immediate)
    if timer then timer:Cancel() end
    if IsInGroup() then
        buffTrackerFrame:RegisterEvent("READY_CHECK")
        buffTrackerFrame:RegisterEvent("UNIT_FLAGS")
        buffTrackerFrame:RegisterEvent("PLAYER_UNGHOST")
        buffTrackerFrame:RegisterEvent("UNIT_AURA")
    else
        buffTrackerFrame:UnregisterEvent("READY_CHECK")
        buffTrackerFrame:UnregisterEvent("UNIT_FLAGS")
        buffTrackerFrame:UnregisterEvent("PLAYER_UNGHOST")
        buffTrackerFrame:UnregisterEvent("UNIT_AURA")
        return
    end

    if immediate then
        IterateAllUnits()
    else
        timer = C_Timer.NewTimer(2, IterateAllUnits)
    end
end

function buffTrackerFrame:READY_CHECK()
    buffTrackerFrame:GROUP_ROSTER_UPDATE(true)
end

function buffTrackerFrame:UNIT_FLAGS()
    buffTrackerFrame:GROUP_ROSTER_UPDATE()
end

function buffTrackerFrame:PLAYER_UNGHOST()
    buffTrackerFrame:GROUP_ROSTER_UPDATE()
end

function buffTrackerFrame:UNIT_AURA(unit)
    if IsInRaid() then
        if string.find(unit, "raid") then
            CheckUnit(unit, true)
        end
    else
        if string.find(unit, "party") or unit=="player" then
            CheckUnit(unit, true)
        end
    end
end

buffTrackerFrame:SetScript("OnEvent", function(self, event, ...)
    self[event](self, ...)
end)

-------------------------------------------------
-- functions
-------------------------------------------------
local function UpdateRaidTools(which)
    if not which or which == "buffTracker" then
        if CellDB["raidTools"]["showBuffTracker"] then
            buffTrackerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
            buffTrackerFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
            LGIST.RegisterCallback(buffTrackerFrame, "GroupInSpecT_Update", "UnitUpdated") 

            for _, b in pairs(buttons) do
                b:SetEnabled(true)
                RegisterAttributeDriver(b, "state-visibility", "[group] show; hide")
            end
            
            if not enabled and which == "buffTracker" then -- already in world, manually enabled
                buffTrackerFrame:GROUP_ROSTER_UPDATE(true)
            end
            enabled = true
        else
            buffTrackerFrame:UnregisterAllEvents()
            LGIST.UnregisterCallback(buffTrackerFrame, "GroupInSpecT_Update")
            
            for _, b in pairs(buttons) do
                UnregisterAttributeDriver(b, "state-visibility")
                b:SetEnabled(false)
                b:Hide()
                b:Reset()
            end

            wipe(unaffected["PWF"])
            wipe(unaffected["AB"])
            wipe(unaffected["BS"])

            enabled = false
        end
    end

    if not which then -- position
        P:LoadPosition(buffTrackerFrame, CellDB["raidTools"]["buffTrackerPosition"])
    end
end
Cell:RegisterCallback("UpdateRaidTools", "BuffTracker_UpdateRaidTools", UpdateRaidTools)