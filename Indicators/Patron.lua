local _, Cell = ...
local F = Cell.funcs
local A = Cell.animations

-------------------------------------------------
-- pool
-------------------------------------------------
local pool

-- local function creationFunc()
--     local f = CreateFrame("Frame")
--     f:Hide()

--     local tex = f:CreateTexture(nil, "ARTWORK")
--     tex:SetTexture("Interface/AddOns/Cell/Media/FlipBooks/heart.png")
--     tex:SetAllPoints(f)
--     tex:SetParentKey("Flipbook")

--     local ag = f:CreateAnimationGroup()
--     ag:SetLooping("REPEAT")

--     local flip = ag:CreateAnimation("FlipBook")
--     flip:SetDuration(1.6)
--     flip:SetFlipBookColumns(2)
--     flip:SetFlipBookRows(8)
--     flip:SetFlipBookFrames(16)
--     flip:SetChildKey("Flipbook")

--     f:SetScript("OnShow", function()
--         ag:Play()
--     end)

--     A:CreateFadeIn(f, 0, 1, 0.2)
--     A:CreateFadeOut(f, 1, 0, 0.2)

-- 	return f
-- end

local function creationFunc()
    local f = CreateFrame("Frame")
    f:Hide()

    local tex = f:CreateTexture(nil, "ARTWORK")
    tex:SetTexture("Interface/AddOns/Cell/Media/star.png")
    tex:SetAllPoints(f)

    local ag = f:CreateAnimationGroup()
    ag:SetScript("OnFinished", function()
        pool:Release(f)
    end)

    -- in -------------------------------------------------------------------- --
    local in_t = ag:CreateAnimation("Translation")
    in_t:SetOrder(1)
    in_t:SetDuration(0.3)
    in_t:SetSmoothing("IN_OUT")

    local in_s = ag:CreateAnimation("Scale")
    in_s:SetOrder(1)
    in_s:SetScaleFrom(0, 0)
    in_s:SetScaleTo(1, 1)
    in_s:SetDuration(0.3)

    local in_a = ag:CreateAnimation("Alpha")
    in_a:SetOrder(1)
    in_a:SetFromAlpha(0)
    in_a:SetToAlpha(1)
    in_a:SetDuration(0.3)

    local in_spinning = ag:CreateAnimation("Rotation")
    in_spinning:SetOrder(1)
    in_spinning:SetDegrees(-360)
    in_spinning:SetDuration(0.5)
    in_spinning:SetEndDelay(0.5)

    -- main ------------------------------------------------------------------ --
    local main_s1 = ag:CreateAnimation("Scale")
    main_s1:SetOrder(2)
    main_s1:SetScaleTo(1.25, 1.25)
    main_s1:SetDuration(0.2)

    local main_t1 = ag:CreateAnimation("Translation")
    main_t1:SetOffset(0, 5)
    main_t1:SetDuration(0.1)
    main_t1:SetOrder(2)
    main_t1:SetSmoothing("OUT")

    local main_t2 = ag:CreateAnimation("Translation")
    main_t2:SetOffset(0, -5)
    main_t2:SetDuration(0.1)
    main_t2:SetOrder(2)
    main_t2:SetSmoothing("IN")
    main_t2:SetStartDelay(0.1)
    main_t2:SetEndDelay(0.25)

    local main_s2 = ag:CreateAnimation("Scale")
    main_s2:SetOrder(3)
    main_s2:SetScaleTo(1.25, 1.25)
    main_s2:SetDuration(0.2)

    local main_t3 = ag:CreateAnimation("Translation")
    main_t3:SetOffset(0, 5)
    main_t3:SetDuration(0.1)
    main_t3:SetOrder(3)
    main_t3:SetSmoothing("OUT")

    local main_t4 = ag:CreateAnimation("Translation")
    main_t4:SetOffset(0, -5)
    main_t4:SetDuration(0.1)
    main_t4:SetOrder(3)
    main_t4:SetSmoothing("IN")
    main_t4:SetStartDelay(0.1)
    main_t4:SetEndDelay(0.5)

    -- out ------------------------------------------------------------------- --
    local out_s = ag:CreateAnimation("Scale")
    out_s:SetOrder(4)
    out_s:SetScaleTo(0, 0)
    out_s:SetDuration(0.5)
    out_s:SetSmoothing("IN")

    local out_spinning = ag:CreateAnimation("Rotation")
    out_spinning:SetOrder(4)
    out_spinning:SetDegrees(-360)
    out_spinning:SetDuration(0.5)

    local out_t = ag:CreateAnimation("Translation")
    out_t:SetOrder(4)
    out_t:SetStartDelay(0.2)
    out_t:SetDuration(0.3)
    out_t:SetSmoothing("IN_OUT")

    local out_a = ag:CreateAnimation("Alpha")
    out_a:SetOrder(4)
    out_a:SetFromAlpha(1)
    out_a:SetToAlpha(0)
    out_a:SetStartDelay(0.2)
    out_a:SetDuration(0.3)

    function f:Display(x, y)
        in_t:SetOffset(x, y)
        out_t:SetOffset(x, -y)
        f:Show()
        ag:Play()
    end

    return f
end

local function resetterFunc(_, f)
    f:Hide()
end

pool = CreateObjectPool(creationFunc, resetterFunc)

-------------------------------------------------
-- show
-------------------------------------------------
local function Display(b)
    local f = pool:Acquire()
    f:SetParent(b.widgets.overlayFrame)
    -- f:SetFrameLevel(b:GetFrameLevel()+200)
    f:SetPoint("CENTER", b, "BOTTOMLEFT")

    local size = max(min(b:GetHeight(), b:GetWidth()), 64)
    f:SetSize(size, size)

    f:Display(ceil(b:GetWidth()/2), ceil(b:GetHeight()/2))
    -- f:FadeIn()
    -- C_Timer.After(3, f.FadeOut)
end
-- CellPatronDisplay = Display

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

    -- Cell.wowPatrons[Cell.vars.playerNameFull] = true

    if IsInGroup() then
        for unit in F:IterateGroupMembers() do
            local fullName = F:UnitFullName(unit)
            if Cell.wowPatrons[fullName] then
                F:HandleUnitButton("unit", unit, Display)
            end
        end
    else
        if Cell.wowPatrons[Cell.vars.playerNameFull] then
            F:HandleUnitButton("unit", "player", Display)
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
