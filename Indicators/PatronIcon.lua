local _, Cell = ...
local F = Cell.funcs
local A = Cell.animations

-------------------------------------------------
-- pool
-------------------------------------------------
local pool

local function creationFunc()
    local f = CreateFrame("Frame")
    f:Hide()

    local tex = f:CreateTexture(nil, "ARTWORK")
    tex:SetTexture("Interface/AddOns/Cell/Media/FlipBooks/heart.png")
    tex:SetAllPoints(f)
    tex:SetParentKey("Flipbook")

    local ag = f:CreateAnimationGroup()
    ag:SetLooping("REPEAT")

    local flip = ag:CreateAnimation("FlipBook")
    flip:SetDuration(1.6)
    flip:SetFlipBookColumns(2)
    flip:SetFlipBookRows(8)
    flip:SetFlipBookFrames(16)
    flip:SetChildKey("Flipbook")

    f:SetScript("OnShow", function()
        ag:Play()
    end)

    A:CreateFadeIn(f, 0, 1, 0.2)
    A:CreateFadeOut(f, 1, 0, 0.2)

	return f
end

local function resetterFunc(_, f)
	f:Hide()
end

pool = CreateObjectPool(creationFunc, resetterFunc)

-------------------------------------------------
-- show
-------------------------------------------------
function ShowPatronIcon(b)
    local f = pool:Acquire()
    f:SetParent(b.widget.overlayFrame)
    f:SetPoint("CENTER")

    local size = min(b:GetHeight()-10, b:GetWidth()-10, 64)
    f:SetSize(size, size)
    
    f:FadeIn()
    C_Timer.After(3, f.FadeOut)
end

local function Display(unit)
    local b = F:GetUnitButtonByUnit(unit)
    if b then
        ShowPatronIcon(b)
    end
end

-- local function StopRainbow(unit)
--     local b = F:GetUnitButtonByUnit(unit)
--     if b then
--         local fs = b.indicators.nameText.name
--         -- stop rainbow
--         fs.rainbow = nil
--         if fs.updater then
--             fs.updater:SetScript("OnUpdate", nil)
--             fs:GetParent():UpdateName()
--         end
--         -- stop timer
--         if fs.timer then
--             fs.timer:Cancel()
--             fs.timer = nil
--         end
--     end
-- end

-- local function StartRainbow(unit)
--     local b = F:GetUnitButtonByUnit(unit)
--     if b then
--         local fs = b.indicators.nameText.name
--         Cell:StartRainbowText(fs)
--         -- reset timer
--         if fs.timer then
--             fs.timer:Cancel()
--         end
--         fs.timer = C_Timer.NewTimer(3, function()
--             StopRainbow(unit)
--         end)
--     end
-- end

-------------------------------------------------
-- events
-------------------------------------------------
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("FIRST_FRAME_RENDERED")

local function Check()
    pool:ReleaseAll()
    
    if IsInGroup() then
        for unit in F:IterateGroupMembers() do
            local fullName = F:UnitFullName(unit)
            if Cell.wowPatrons[fullName] then
                Display(unit)
            end
        end
    else
        if Cell.wowPatrons[Cell.vars.playerNameFull] then
            Display("player")
        end
    end
end

local timer, members
eventFrame:SetScript("OnEvent", function(self, event)
    if event == "FIRST_FRAME_RENDERED" then
        eventFrame:UnregisterEvent("FIRST_FRAME_RENDERED")
        eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    end

    if timer then
        timer:Cancel()
        timer = nil
    end

    if InCombatLockdown() then return end

    local newMembers = GetNumGroupMembers()
    if members ~= newMembers then
        members = newMembers
        timer = C_Timer.NewTimer(5, Check)
    end
end)