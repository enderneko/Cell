local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs
local LGIST = LibStub:GetLibrary("LibGroupInSpecT-1.1")

local UnitIsConnected = UnitIsConnected
local UnitIsVisible = UnitIsVisible
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsUnit = UnitIsUnit
local UnitIsPlayer = UnitIsPlayer
local UnitGUID = UnitGUID
local UnitClass = UnitClass
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local AuraUtil_FindAura = AuraUtil.FindAura

-- 21562: Power Word: Fortitude
-- 1459: Arcane Brilliance
-- 6673: Battle Shout
-------------------------------------------------
-- vars
-------------------------------------------------
local enabled
local buttons = {}
local available = {}
local order = {"PWF", "AB", "BS"}
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
-- CELL_UNAFFECTED = unaffected

function F:GetUnaffectedString(spellId)
    local list, buff
    local ret = {}
    if spellId == 21562 then
        list = unaffected["PWF"]
        buff = ITEM_MOD_STAMINA_SHORT
    elseif spellId == 1459 then
        list = unaffected["AB"]
        buff = ITEM_MOD_INTELLECT_SHORT
    elseif spellId == 6673 then
        list = unaffected["BS"]
        buff = ITEM_MOD_ATTACK_POWER_SHORT
    end
    for unit in pairs(list) do
        local name = UnitName(unit)
        tinsert(ret, name)
    end
    if #ret == 0 then
        return
    elseif #ret <= 10 then
        return L["Missing Buff"].." ("..buff.."): "..table.concat(ret, ", ")
    else
        return L["Missing Buff"].." ("..buff.."): "..L["many"]
    end
end

-------------------------------------------------
-- frame
-------------------------------------------------
local buffTrackerFrame = CreateFrame("Frame", "CellBuffTrackerFrame", Cell.frames.mainFrame, "BackdropTemplate")
Cell.frames.buffTrackerFrame = buffTrackerFrame
P:Size(buffTrackerFrame, 102, 50)
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

local fakeButtonFrame = CreateFrame("Frame", nil, buffTrackerFrame)
P:Point(fakeButtonFrame, "BOTTOMLEFT", buffTrackerFrame)
P:Point(fakeButtonFrame, "TOPRIGHT", buffTrackerFrame, "BOTTOMRIGHT", 0, 32)
fakeButtonFrame:EnableMouse(true)
fakeButtonFrame:SetFrameLevel(buffTrackerFrame:GetFrameLevel()+10)
fakeButtonFrame:Hide()

local fakeIcons = {}
local function CreateFakeIcon(spellId)
    local spellName, _, spellIcon = GetSpellInfo(spellId)
    local bg = fakeButtonFrame:CreateTexture(nil, "BORDER")
    bg:SetColorTexture(0, 0, 0, 1)
    P:Size(bg, 32, 32)
    
    local icon = fakeButtonFrame:CreateTexture(nil, "ARTWORK")
    icon:SetTexture(spellIcon)
    icon:SetTexCoord(.08, .92, .08, .92)
    P:Point(icon, "TOPLEFT", bg, "TOPLEFT", 1, -1)
    P:Point(icon, "BOTTOMRIGHT", bg, "BOTTOMRIGHT", -1, 1)

    function bg:UpdatePixelPerfect()
        P:Resize(bg)
        P:Repoint(bg)
        P:Repoint(icon)
    end

    return bg
end

local fakePWF = CreateFakeIcon(21562)
P:Point(fakePWF, "BOTTOMLEFT")
local fakeAB = CreateFakeIcon(1459)
P:Point(fakeAB, "BOTTOMLEFT",fakePWF, "BOTTOMRIGHT", 3, 0)
local fakeBS = CreateFakeIcon(6673)
P:Point(fakeBS, "BOTTOMLEFT", fakeAB, "BOTTOMRIGHT", 3, 0)

local function ShowMover(show)
    if show then
        if not CellDB["raidTools"]["showBuffTracker"] then return end
        buffTrackerFrame:EnableMouse(true)
        buffTrackerFrame.moverText:Show()
        Cell:StylizeFrame(buffTrackerFrame, {0, 1, 0, .4}, {0, 0, 0, 0})
        fakeButtonFrame:Show()
    else
        buffTrackerFrame:EnableMouse(false)
        buffTrackerFrame.moverText:Hide()
        Cell:StylizeFrame(buffTrackerFrame, {0, 0, 0, 0}, {0, 0, 0, 0})
        fakeButtonFrame:Hide()
    end
end
Cell:RegisterCallback("ShowMover", "BuffTracker_ShowMover", ShowMover)

-------------------------------------------------
-- buttons
-------------------------------------------------
buttons["PWF"] = Cell:CreateBuffButton(buffTrackerFrame, {32, 32}, 21562)
P:Point(buttons["PWF"], "BOTTOMLEFT")
buttons["PWF"]:Hide()
buttons["PWF"]:SetTooltip(unaffected["PWF"])
buttons["PWF"].glowColor = {1, 1, 1}

buttons["AB"] = Cell:CreateBuffButton(buffTrackerFrame, {32, 32}, 1459)
P:Point(buttons["AB"], "BOTTOMLEFT", buttons["PWF"], "BOTTOMRIGHT", 3, 0)
buttons["AB"]:Hide()
buttons["AB"]:SetTooltip(unaffected["AB"])
buttons["AB"].glowColor = {.25, .78, .92}

buttons["BS"] = Cell:CreateBuffButton(buffTrackerFrame, {32, 32}, 6673)
P:Point(buttons["BS"], "BOTTOMLEFT", buttons["AB"], "BOTTOMRIGHT", 3, 0)
buttons["BS"]:Hide()
buttons["BS"]:SetTooltip(unaffected["BS"])
buttons["BS"].glowColor = {.78, .61, .43}

local function UpdateButtons()
    for _, name in pairs(order) do
        if available[name] then
            local n = F:Getn(unaffected[name])
            if n == 0 then
                buttons[name].count:SetText("")
                buttons[name]:SetAlpha(0.5)
                buttons[name]:StopGlow()
            else
                buttons[name].count:SetText(n)
                buttons[name]:SetAlpha(1)
                if unaffected[name][myUnit] then
                    -- color, N, frequency, length, thickness
                    buttons[name]:StartGlow("Pixel", buttons[name].glowColor, 8, 0.25, P:Scale(8), P:Scale(2))
                else
                    buttons[name]:StopGlow()
                end
            end
        end
    end
end

local function AnchorButtons()
    if InCombatLockdown() then
        buffTrackerFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    else
        local last
        for _, name in pairs(order) do
            buttons[name]:ClearAllPoints()
            if available[name] then
                buttons[name]:Show()
                if last then
                    buttons[name]:SetPoint("BOTTOMLEFT", last, "BOTTOMRIGHT", 3, 0)
                else
                    buttons[name]:SetPoint("BOTTOMLEFT")
                end
                last = buttons[name]
            else
                buttons[name]:Hide()
                buttons[name]:Reset()
            end
        end
    end
end

-------------------------------------------------
-- check
-------------------------------------------------
-- name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod = UnitAura
-- NOTE: FrameXML/AuraUtil.lua
-- AuraUtil.FindAura(predicate, unit, filter, predicateArg1, predicateArg2, predicateArg3)
-- predicate(predicateArg1, predicateArg2, predicateArg3, ...)
local function predicate(...)
    local idToFind = ...
    local id = select(13, ...)
    return idToFind == id
end

local function CheckUnit(unit, updateBtn)
    -- print("CheckUnit", unit)
    if not (available["PWF"] or available["AB"] or available["BS"]) then return end

    if UnitIsConnected(unit) and UnitIsVisible(unit) and not UnitIsDeadOrGhost(unit) then
        local info = LGIST:GetCachedInfo(UnitGUID(unit))
        local spec = info and info.global_spec_id or ""
        local required = requiredBuffs[spec]
        if available["PWF"] then
            if not AuraUtil_FindAura(predicate, unit, "HELPFUL", 21562) then
                unaffected["PWF"][unit] = true
            else
                unaffected["PWF"][unit] = nil
            end
        end
        if available["AB"] then
            if required == "AB" and not AuraUtil_FindAura(predicate, unit, "HELPFUL", 1459) then
                unaffected["AB"][unit] = true
            else
                unaffected["AB"][unit] = nil
            end
        end
        if available["BS"] then
            if required == "BS" and not AuraUtil_FindAura(predicate, unit, "HELPFUL", 6673) then
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
    
    if updateBtn then UpdateButtons() end
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

    AnchorButtons()
    
    wipe(unaffected["PWF"])
    wipe(unaffected["AB"])
    wipe(unaffected["BS"])
    for unit in F:IterateGroupMembers() do
        CheckUnit(unit)
    end

    UpdateButtons()
end

-------------------------------------------------
-- events
-------------------------------------------------
function buffTrackerFrame:UnitUpdated(event, guid, unit, info)
    --    print(event, guid, unit, info.global_spec_id)
    if unit == "player" then 
        if UnitIsUnit("player", myUnit) then CheckUnit(myUnit, true) end
    elseif UnitIsPlayer(unit) then -- ignore pets
        CheckUnit(unit, true)
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

        available["PWF"], available["AB"], available["BS"] = false, false, false
        wipe(unaffected["PWF"])
        wipe(unaffected["AB"])
        wipe(unaffected["BS"])
        AnchorButtons()
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
        if string.match(unit, "raid%d") then
            CheckUnit(unit, true)
        end
    else
        if string.match(unit, "party%d") or unit=="player" then
            CheckUnit(unit, true)
        end
    end
end

function buffTrackerFrame:PLAYER_REGEN_ENABLED()
    buffTrackerFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
    AnchorButtons()
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

            if not enabled and which == "buffTracker" then -- already in world, manually enabled
                buffTrackerFrame:GROUP_ROSTER_UPDATE(true)
            end
            enabled = true
        else
            buffTrackerFrame:UnregisterAllEvents()
            LGIST.UnregisterCallback(buffTrackerFrame, "GroupInSpecT_Update")
            
            wipe(unaffected["PWF"])
            wipe(unaffected["AB"])
            wipe(unaffected["BS"])
            available["PWF"], available["AB"], available["BS"] = false, false, false
            myUnit = ""
            AnchorButtons()

            enabled = false
        end
    end

    if not which then -- position
        P:LoadPosition(buffTrackerFrame, CellDB["raidTools"]["buffTrackerPosition"])
    end
end
Cell:RegisterCallback("UpdateRaidTools", "BuffTracker_UpdateRaidTools", UpdateRaidTools)

local function UpdatePixelPerfect()
    P:Resize(buffTrackerFrame)
    fakePWF:UpdatePixelPerfect()
    fakeAB:UpdatePixelPerfect()
    fakeBS:UpdatePixelPerfect()

    for _, b in pairs(buttons) do
        b:UpdatePixelPerfect()
    end
end
Cell:RegisterCallback("UpdatePixelPerfect", "BuffTracker_UpdatePixelPerfect", UpdatePixelPerfect)