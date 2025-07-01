---@class Cell
local Cell = select(2, ...)
local L = Cell.L
local F = Cell.funcs
---@class CellIndicatorFuncs
local I = Cell.iFuncs
---@type AbstractFramework
local AF = _G.AbstractFramework

local UnitGUID = UnitGUID
local UnitCanAttack = UnitCanAttack
local UnitIsOtherPlayersPet = UnitIsOtherPlayersPet

-------------------------------------------------
-- events
-------------------------------------------------
local nameplates = {
    -- nameplateUnitId = true,
}

local nameplateTargets = {
    -- nameplateUnitId = targetGUID,
}

local counter = {
    -- friendGUID = {enemyGUID=true, ...},
}

local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    self[event](self, ...)
end)


function eventFrame:NAME_PLATE_UNIT_REMOVED(unit)
    nameplates[unit] = nil
    nameplateTargets[unit] = nil
end

function eventFrame:NAME_PLATE_UNIT_ADDED(unit)
    if not unit or not UnitCanAttack(unit, "player") or UnitIsOtherPlayersPet(unit) then return end
    nameplates[unit] = true
end

local function ScanNameplates()
    for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
        eventFrame:NAME_PLATE_UNIT_ADDED(nameplate.namePlateUnitToken)
    end
end

local function SetCount(b, count)
    b.indicators.targetCounter:SetCount(count)
end

local ticker
local function StartTicker()
    if ticker then ticker:Cancel() end
    ticker = C_Timer.NewTicker(0.25, function()
        -- reset
        for _, ct in pairs(counter) do
            wipe(ct)
        end

        -- check & calculate
        for unit in pairs(nameplates) do
            local target = UnitGUID(unit.."target")

            if not target then -- no target
                nameplateTargets[unit] = nil
            elseif not Cell.vars.guids[target] then -- target doesn't exists in player's group
                nameplateTargets[unit] = nil
                counter[target] = nil
            else
                nameplateTargets[unit] = target
            end

            target = nameplateTargets[unit]
            if target and Cell.vars.guids[target] then -- valid target exists
                if not counter[target] then counter[target] = {} end -- init
                counter[target][unit] = true
            end
        end

        -- update indicator
        for guid in pairs(Cell.vars.guids) do
            F.HandleUnitButton("guid", guid, SetCount, counter[guid] and F.Getn(counter[guid]) or 0)
        end
    end)
end

local function StopTicker()
    if ticker then ticker:Cancel() end
    ticker = nil
end

local counterEnabled, zoneFilters = false, {}
function eventFrame:PLAYER_ENTERING_WORLD()
    -- reset
    wipe(nameplates)
    wipe(counter)
    F.IterateAllUnitButtons(function(b)
        b.indicators.targetCounter:SetCount(0)
    end, true)

    local isIn, iType = IsInInstance()

    local isValidZone
    if not isIn or iType == "none" then
        isValidZone = zoneFilters["outdoor"]
    elseif iType == "pvp" or iType == "arena" then
        isValidZone = zoneFilters["pvp"]
    else -- party, raid, scenario
        isValidZone = zoneFilters["pve"]
    end

    if counterEnabled and isValidZone then
        eventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        eventFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
        ScanNameplates()
        StartTicker()
    else
        eventFrame:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
        eventFrame:UnregisterEvent("NAME_PLATE_UNIT_REMOVED")
        StopTicker()
    end
end

function I.EnableTargetCounter(enabled)
    if enabled then
        eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        counterEnabled = true
    else
        eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
        counterEnabled = false
    end
    eventFrame:PLAYER_ENTERING_WORLD() -- check now
    -- texplore(nameplateTargets)
end

function I.UpdateTargetCounterFilters(filters, noUpdate)
    if filters then zoneFilters = filters end
    if not noUpdate and counterEnabled then
        eventFrame:PLAYER_ENTERING_WORLD()
    end
end

-------------------------------------------------
-- CreateTargetCounter
-------------------------------------------------
function I.CreateTargetCounter(parent)
    local targetCounter = CreateFrame("Frame", parent:GetName().."TargetCounter", parent)
    parent.indicators.targetCounter = targetCounter
    targetCounter:Hide()

    local text = targetCounter:CreateFontString(nil, "OVERLAY", "CELL_FONT_STATUS")
    targetCounter.text = text
    -- stack:SetJustifyH("RIGHT")
    text:SetPoint("CENTER", 1, 0)

    function targetCounter:SetFont(font, size, outline, shadow)
        AF.SetFont(text, font, size, outline, shadow)

        local point = targetCounter:GetPoint(1)
        text:ClearAllPoints()
        if string.find(point, "LEFT") then
            text:SetPoint("LEFT")
        elseif string.find(point, "RIGHT") then
            text:SetPoint("RIGHT")
        else
            text:SetPoint("CENTER")
        end
        targetCounter:SetSize(size+3, size+3)
    end

    targetCounter._SetPoint = targetCounter.SetPoint
    function targetCounter:SetPoint(point, relativeTo, relativePoint, x, y)
        text:ClearAllPoints()
        if string.find(point, "LEFT") then
            text:SetPoint("LEFT")
        elseif string.find(point, "RIGHT") then
            text:SetPoint("RIGHT")
        else
            text:SetPoint("CENTER")
        end
        targetCounter:_SetPoint(point, relativeTo, relativePoint, x, y)
    end

    function targetCounter:SetCount(n)
        if n == 0 then
            targetCounter:Hide()
        else
            targetCounter:Show()
        end
        text:SetText(n)
    end

    function targetCounter:SetColor(r, g, b)
        text:SetTextColor(r, g, b)
    end
end
