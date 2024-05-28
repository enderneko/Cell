-------------------------------------------------
-- 2023-12-12 10:26:02 GMT+8
-- add a swingTimer bar for each unitbutton
-- 为单位按钮添加一个被普攻的计时条
-------------------------------------------------
local SOURCE = "target"
local ONLY_SHOW_SOURCE = false

local POINT1, POINT1_X, POINT1_Y = "TOPLEFT", 0, 0
local POINT2, POINT2_X, POINT2_Y = "TOPRIGHT", 0, -5
local FRAME_LEVEL = 10
local COLOR = {1, 0, 0}

-------------------------------------------------
-- function codes
-------------------------------------------------
local F = Cell.funcs
local I = Cell.iFuncs
local P = Cell.pixelPerfectFuncs

local timers = {}

local function Display(b, sourceGUID)
    local GUID = UnitGUID(SOURCE)

    -- check SOURCE
    if GUID == sourceGUID and UnitCanAttack("player", SOURCE) then
        b.swingTimer:Display(SOURCE)
        timers[sourceGUID] = b.swingTimer
        b.swingTimer.lock = true

    -- if SOURCE not exists then check all nameplates
    elseif not (ONLY_SHOW_SOURCE or b.swingTimer.lock) then
        -- no UnitTokenFromGUID in classic
        local plates = C_NamePlate.GetNamePlates()
        for _, p in pairs(plates) do
            local guid = UnitGUID(p.namePlateUnitToken)
            if guid == sourceGUID then
                b.swingTimer:Display(p.namePlateUnitToken)
                timers[sourceGUID] = b.swingTimer
                -- b.swingTimer.lock = true
                break
            end
        end
    end
end

F:IterateAllUnitButtons(function(b)
    local swingTimer = I.CreateAura_Bar(b:GetName().."SwingTimer", b.widgets.overlayFrame)
    b.swingTimer = swingTimer
    swingTimer:Hide()
    swingTimer:SetPoint(POINT1, P:Scale(POINT1_X), P:Scale(POINT1_Y))
    swingTimer:SetPoint(POINT2, P:Scale(POINT2_X), P:Scale(POINT2_Y))
    swingTimer:SetStatusBarColor(unpack(COLOR))
    swingTimer:SetFrameLevel(b.widgets.overlayFrame:GetFrameLevel()+FRAME_LEVEL)

    function swingTimer:Display(sourceUnit)
        local speed = UnitAttackSpeed(sourceUnit)
        swingTimer:SetMinMaxValues(0, speed)
        swingTimer:SetValue(speed)

        local start = GetTime()
        swingTimer:SetScript("OnUpdate", function()
            local remain = speed-(GetTime()-start)
            if remain >= 0 then
                swingTimer:SetValue(remain)
            else
                swingTimer.lock = nil
                swingTimer:Hide()
            end
        end)
        swingTimer:Show()
    end
end)

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
eventFrame:SetScript("OnEvent", function(self, event)
    local _, subEvent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
    if subEvent == "SWING_DAMAGE" or subEvent == "SWING_MISSED" then
        F:HandleUnitButton("guid", destGUID, Display, sourceGUID)
    elseif subEvent == "UNIT_DIED" then
        if timers[destGUID] then
            timers[destGUID]:Hide()
            timers[destGUID] = nil
        end
    end
end)

Cell:RegisterCallback("LeaveInstance", "CellSwingTimer_LeaveInstance", function()
    for _, t in pairs(timers) do
        t:Hide()
    end
    wipe(timers)
end)