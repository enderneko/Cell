local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local I = Cell.iFuncs

-------------------------------------------------
-- events
-------------------------------------------------
local enemyTargets = {
    -- enemyGUID = targetFriendGUID,
}
local counter = {
    -- friendGUID = {enemyGUID=true, ...},
}

local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    self[event](self, ...)
end)

function eventFrame:UNIT_TARGET(unit)
    if not (string.find(unit, "nameplate") and UnitIsPlayer(unit) and UnitIsEnemy(unit, "player")) then return end
    -- if not string.find(unit, "nameplate") then return end

    local newTarget = UnitGUID(unit.."target")
    local unitGUID = UnitGUID(unit)
    if not unitGUID then return end

    if newTarget and not Cell.vars.guid[newTarget] then -- has target, but target no longer exists in player's group
        enemyTargets[unitGUID] = nil
        counter[newTarget] = nil
        return
    end

    local prevTarget = enemyTargets[unitGUID]

    -- update counter
    if newTarget then -- gain/change target
        -- check old target
        if prevTarget then
            if counter[prevTarget] then
                counter[prevTarget][unitGUID] = nil
            end
            -- enemyTargets[unitGUID] = nil
        end
        -- save new
        if counter[newTarget] then
            counter[newTarget][unitGUID] = true
        else
            counter[newTarget] = {[unitGUID] = true}
        end
    else -- lose target
        if prevTarget and counter[prevTarget] then
            counter[prevTarget][unitGUID] = nil
        end
    end

    -- update enemyTargets
    enemyTargets[unitGUID] = newTarget
    -- print(unitGUID, prevTarget, newTarget)

    -- update indicator
    if prevTarget and counter[prevTarget] then
        local prevB = F:GetUnitButtonByGUID(prevTarget)
        if prevB then prevB.indicators.targetCounter:SetCount(F:Getn(counter[prevTarget])) end
    end
    if newTarget and counter[newTarget] then
        local newB = F:GetUnitButtonByGUID(newTarget)
        if newB then newB.indicators.targetCounter:SetCount(F:Getn(counter[newTarget])) end
    end
end

local nameplates = {}
function eventFrame:NAME_PLATE_UNIT_REMOVED(unit)
    -- print("REMOVED: "..unit, UnitGUID(unit))
    if not (UnitIsPlayer(unit) and UnitIsEnemy(unit, "player")) then return end
    
    local unitGUID = UnitGUID(unit) or nameplates[unit]
    nameplates[unit] = nil
    local target = enemyTargets[unitGUID]
    
    if target and not Cell.vars.guid[target] then -- has target, but target no longer exists in player's group
        enemyTargets[unitGUID] = nil
        counter[target] = nil
        return
    end
    
    if target then -- already has target, remove
        enemyTargets[unitGUID] = nil
        counter[target][unitGUID] = nil
        
        -- update indicator
        local b = F:GetUnitButtonByGUID(target)
        if b then b.indicators.targetCounter:SetCount(F:Getn(counter[target])) end
    end
end

function eventFrame:NAME_PLATE_UNIT_ADDED(unit)
    -- print("ADDED: "..unit)
    if not (UnitIsPlayer(unit) and UnitIsEnemy(unit, "player")) then return end
    
    local target = UnitGUID(unit.."target")
    local unitGUID = UnitGUID(unit)

    if unitGUID ~= nameplates[unit] then --? nameplate unit changed
        counter[enemyTargets[unitGUID]][unitGUID] = nil
        enemyTargets[unitGUID] = nil
    end
    nameplates[unit] = unitGUID

    if target and not Cell.vars.guid[target] then -- has target, but target no longer exists in player's group
        enemyTargets[unitGUID] = nil
        counter[target] = nil
        return
    end

    if target then -- already has target, update
        if counter[target] then
            counter[target][unitGUID] = true
        else
            counter[target] = {[unitGUID] = true}
        end
        
        enemyTargets[unitGUID] = target

        -- update indicator
        local b = F:GetUnitButtonByGUID(target)
        if b then b.indicators.targetCounter:SetCount(F:Getn(counter[target])) end
    end
end

-- group type of arena & battleground == raid 
function eventFrame:GROUP_ROSTER_UPDATE()
    for i = 1, GetNumGroupMembers(LE_PARTY_CATEGORY_INSTANCE) do
        local guid = UnitGUID("raid"..i)
        local b = F:GetUnitButtonByGUID(guid)
        if b then
            if counter[guid] then
                b.indicators.targetCounter:SetCount(F:Getn(counter[guid]))
            else
                b.indicators.targetCounter:SetCount(0)
            end
        end
    end
end

-- function eventFrame:COMBAT_LOG_EVENT_UNFILTERED()
--     local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
--     if subevent == "UNIT_DIED" then
--         local b = F:GetUnitButtonByGUID(target)
--         if b then b.indicators.targetCounter:SetCount(0) end
--     end
-- end
-- function eventFrame:PLAYER_ALIVE()
--     for unit, guid in pairs(nameplateUnits) do
--         if UnitGUID(unit) ~= guid
--     end
-- end

local ticker
local function UpdateTicker(start)
    if start then
        if ticker then ticker:Cancel() end
        ticker = C_Timer.NewTicker(.1, function()
            for unit, guid in pairs(nameplates) do
                if UnitGUID(unit) ~= guid then
                    eventFrame:NAME_PLATE_UNIT_REMOVED(unit) --? NAME_PLATE_UNIT_REMOVED not triggered
                else
                    eventFrame:UNIT_TARGET(unit)
                end
            end
        end)
    else
        if ticker then
            ticker:Cancel()
            ticker = nil
        end
    end
end

local counterEnabled
function eventFrame:PLAYER_ENTERING_WORLD()
    -- reset
    wipe(enemyTargets)
    wipe(counter)
    wipe(nameplates)
    F:IterateAllUnitButtons(function(b)
        b.indicators.targetCounter:SetCount(0)
    end)

    local isIn, iType = IsInInstance()
    iType = "pvp"
    if counterEnabled and (iType == "pvp" or iType == "arena") then
        -- eventFrame:RegisterEvent("UNIT_TARGET")
        eventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        eventFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
        eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
        -- eventFrame:RegisterEvent("PLAYER_ALIVE")
        -- eventFrame:RegisterEvent("PLAYER_UNGHOST")
        -- eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        UpdateTicker(true)
    else
        -- eventFrame:UnregisterEvent("UNIT_TARGET")
        eventFrame:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
        eventFrame:UnregisterEvent("NAME_PLATE_UNIT_REMOVED")
        eventFrame:UnregisterEvent("GROUP_ROSTER_UPDATE")
        -- eventFrame:UnregisterEvent("PLAYER_ALIVE")
        -- eventFrame:UnregisterEvent("PLAYER_UNGHOST")
        -- eventFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        UpdateTicker()
    end
end

function I:EnableTargetCounter(enabled)
    if enabled then
        eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        counterEnabled = true
    else
        eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
        counterEnabled = false
    end
    eventFrame:PLAYER_ENTERING_WORLD() -- check now
    -- texplore(counter)
end

-------------------------------------------------
-- CreateTargetCounter
-------------------------------------------------
function I:CreateTargetCounter(parent)
    local targetCounter = CreateFrame("Frame", nil, parent)
    parent.indicators.targetCounter = targetCounter
    targetCounter:Hide()

    local text = targetCounter:CreateFontString(nil, "OVERLAY", "CELL_FONT_STATUS")
    targetCounter.text = text
    -- stack:SetJustifyH("RIGHT")
    text:SetPoint("CENTER", 1, 0)

    function targetCounter:SetFont(font, size, flags, horizontalOffset)
        if not string.find(font, ".ttf") then font = F:GetFont(font) end

        if flags == "Shadow" then
            text:SetFont(font, size)
            text:SetShadowOffset(1, -1)
            text:SetShadowColor(0, 0, 0, 1)
        else
            if flags == "None" then
                flags = ""
            elseif flags == "Outline" then
                flags = "OUTLINE"
            else
                flags = "OUTLINE, MONOCHROME"
            end
            text:SetFont(font, size, flags)
            text:SetShadowOffset(0, 0)
            text:SetShadowColor(0, 0, 0, 0)
        end

        local point = targetCounter:GetPoint(1)
        text:ClearAllPoints()
        if string.find(point, "LEFT") then
            text:SetPoint("LEFT", horizontalOffset, 0)
        elseif string.find(point, "RIGHT") then
            text:SetPoint("RIGHT", horizontalOffset, 0)
        else
            text:SetPoint("CENTER", horizontalOffset, 0)
        end
        targetCounter:SetSize(size+3, size+3)
    end

    targetCounter.OriginalSetPoint = targetCounter.SetPoint
    function targetCounter:SetPoint(point, relativeTo, relativePoint, x, y)
        local horizontalOffset = select(4, text:GetPoint(1))
        text:ClearAllPoints()
        if string.find(point, "LEFT") then
            text:SetPoint("LEFT", horizontalOffset, 0)
        elseif string.find(point, "RIGHT") then
            text:SetPoint("RIGHT", horizontalOffset, 0)
        else
            text:SetPoint("CENTER", horizontalOffset, 0)
        end
        targetCounter:OriginalSetPoint(point, relativeTo, relativePoint, x, y)
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