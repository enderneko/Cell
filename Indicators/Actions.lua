local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local B = Cell.bFuncs
local I = Cell.iFuncs

local orientation

-------------------------------------------------
-- events
-------------------------------------------------
-- CLEU: subevent, source, target, spellId, spellName
-- [15:10] SPELL_HEAL 秋静葉 秋静葉 6262 治疗石
-- [15:10] SPELL_CAST_SUCCESS 秋静葉 nil 6262 治疗石
-- [15:13] SPELL_HEAL 秋静葉 秋静葉 307192 灵魂治疗药水
-- [15:13] SPELL_CAST_SUCCESS 秋静葉 nil 307192 灵魂治疗药水

-- UNIT_SPELLCAST_SUCCEEDED
-- unit, castGUID, spellID

local function Display(b, ...)
    b.indicators.actions:Display(...)
end

local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(self, event, unit, castGUID, spellID)
    -- filter out players not in your group
    if not (UnitInRaid(unit) or UnitInParty(unit) or unit == "player" or unit == "pet") then return end

    if Cell.vars.actionsDebugModeEnabled then
        local name = F:GetSpellInfo(spellID)
        print("|cFFFF3030[Cell]|r |cFFB2B2B2"..event..":|r", unit, "|cFF00FF00"..(spellID or "nil").."|r", name)
    end

    if Cell.vars.actions[spellID] then
        F:HandleUnitButton("unit", unit, Display, unpack(Cell.vars.actions[spellID]))
    end
end)

-- local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
-- eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
-- eventFrame:SetScript("OnEvent", function()
--     local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName = CombatLogGetCurrentEventInfo()
--     print(subevent, sourceName, destName, spellId, spellName)
-- end)

-------------------------------------------------
-- animations
-------------------------------------------------
--! Type A
local function CreateAnimationGroup_TypeA(parent)
    -- frame
    local f = CreateFrame("Frame", parent:GetName().."_TypeA", parent)
    f:Hide()

    -- texture
    local tex = f:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints(f)
    tex:SetTexture(Cell.vars.whiteTexture)

    tex:AddMaskTexture(parent.mask)

    -- animation
    local ag = f:CreateAnimationGroup()

    local a1 = ag:CreateAnimation("Alpha")
    a1.duration = 0.6
    a1:SetFromAlpha(0)
    a1:SetToAlpha(1)
    a1:SetOrder(1)
    a1:SetDuration(a1.duration)
    a1:SetSmoothing("OUT")

    local t1 = ag:CreateAnimation("Translation")
    t1.duration = 0.6
    t1:SetOrder(1)
    t1:SetSmoothing("OUT")
    t1:SetDuration(t1.duration)

    local a2 = ag:CreateAnimation("Alpha")
    a2.duration = 0.5
    a2:SetFromAlpha(1)
    a2:SetToAlpha(0)
    a2:SetDuration(a2.duration)
    a2:SetOrder(2)
    -- a2:SetSmoothing("IN")

    ag:SetScript("OnPlay", function()
        f:Show()
    end)

    ag:SetScript("OnFinished", function()
        f:Hide()
    end)

    function ag:Display(r, g, b)
        if orientation == "horizontal" then
            t1:SetOffset(parent:GetWidth(), 0)
            tex:SetGradient("HORIZONTAL", CreateColor(r, g, b, 0), CreateColor(r, g, b, 1))
        else
            t1:SetOffset(0, parent:GetHeight())
            tex:SetGradient("VERTICAL", CreateColor(r, g, b, 0), CreateColor(r, g, b, 1))
        end

        if ag:IsPlaying() then
            ag:Restart()
        else
            ag:Play()
        end
    end

    function ag:UpdateOrientation()
        if orientation == "horizontal" then
            f:ClearAllPoints()
            f:SetPoint("TOPRIGHT", parent, "TOPLEFT")
            f:SetPoint("BOTTOMRIGHT", parent, "BOTTOMLEFT")
            f:SetWidth(15)
        else
            f:ClearAllPoints()
            f:SetPoint("TOPLEFT", parent, "BOTTOMLEFT")
            f:SetPoint("TOPRIGHT", parent, "BOTTOMRIGHT")
            f:SetHeight(15)
        end
    end

    function ag:SetSpeedMultiplier(s)
        a1:SetDuration(a1.duration/s)
        t1:SetDuration(t1.duration/s)
        a2:SetDuration(a2.duration/s)
    end

    return ag
end

--! Type B
local function CreateAnimationGroup_TypeB(parent)
    local WIDTH = 20

    -- frame
    local f = CreateFrame("Frame", parent:GetName().."_TypeB", parent)
    f:SetPoint("BOTTOMRIGHT", parent, "BOTTOMLEFT")
    f:SetPoint("TOPRIGHT", parent, "TOPLEFT")
    f:SetWidth(WIDTH)
    f:Hide()

    -- texture
    local tex = f:CreateTexture(nil, "ARTWORK")
    tex:SetPoint("BOTTOMRIGHT")
    tex:SetWidth(WIDTH)
    tex:SetRotation(45 * math.pi / 180, CreateVector2D(1, 0))

    tex:AddMaskTexture(parent.mask)

    -- animation
    local ag = f:CreateAnimationGroup()

    local a1 = ag:CreateAnimation("Alpha")
    a1.duration = 0.35
    a1:SetFromAlpha(0)
    a1:SetToAlpha(0.7)
    a1:SetDuration(a1.duration)
    -- a1:SetSmoothing("IN")

    local t1 = ag:CreateAnimation("Translation")
    t1.duration = 0.7
    t1:SetSmoothing("IN_OUT")
    t1:SetDuration(t1.duration)

    -- local a2 = ag:CreateAnimation("Alpha")
    -- a2.duration = 0.3
    -- a2:SetFromAlpha(0.7)
    -- a2:SetToAlpha(0)
    -- a2:SetDuration(a2.duration)
    -- a2:SetStartDelay(t1.duration - a2.duration)

    ag:SetScript("OnPlay", function()
        f:Show()
    end)

    ag:SetScript("OnFinished", function()
        f:Hide()
    end)

    function ag:Display(r, g, b)
        t1:SetOffset(parent:GetWidth() + math.tan(math.pi/4)*parent:GetHeight() + WIDTH/math.cos(math.pi/4), 0)
        tex:SetHeight(parent:GetHeight()/math.sin(math.pi/4) + WIDTH)
        tex:SetColorTexture(r, g, b)

        if ag:IsPlaying() then
            ag:Restart()
        else
            ag:Play()
        end
    end

    function ag:UpdateOrientation()
        -- do nothing
    end

    function ag:SetSpeedMultiplier(s)
        a1:SetDuration(a1.duration/s)
        t1:SetDuration(t1.duration/s)
        -- a2:SetDuration(a2.duration/s)
        -- a2:SetStartDelay((t1.duration-a2.duration)/s)
    end

    return ag
end

--! Type C
local function CreateAnimationGroup_TypeC(parent, subType)
    -- frame
    local f = CreateFrame("Frame", parent:GetName().."_TypeC"..subType, parent)
    f:Hide()
    if subType == 1 then
        f:SetPoint("BOTTOMLEFT")
        f:SetPoint("TOPLEFT", parent, "LEFT")
    elseif subType == 2 then
        f:SetPoint("BOTTOM")
        f:SetPoint("TOP", parent, "CENTER")
    else
        f:SetPoint("BOTTOMRIGHT")
        f:SetPoint("TOPRIGHT", parent, "RIGHT")

    end

    -- texture
    local tex = f:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints(f)
    tex:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\upgrade.tga")

    -- tex:AddMaskTexture(parent.mask)

    -- animation
    local ag = f:CreateAnimationGroup()

    local a1 = ag:CreateAnimation("Alpha")
    a1.duration = 0.5
    a1:SetFromAlpha(0)
    a1:SetToAlpha(1)
    a1:SetOrder(1)
    a1:SetDuration(a1.duration)
    a1:SetSmoothing("OUT")

    local t1 = ag:CreateAnimation("Translation")
    t1.duration = 0.5
    t1:SetOrder(1)
    t1:SetSmoothing("OUT")
    t1:SetDuration(t1.duration)

    local a2 = ag:CreateAnimation("Alpha")
    a2.duration = 0.5
    a2:SetFromAlpha(1)
    a2:SetToAlpha(0)
    a2:SetDuration(a2.duration)
    a2:SetOrder(2)
    a2:SetSmoothing("IN")

    ag:SetScript("OnPlay", function()
        f:Show()
    end)

    ag:SetScript("OnFinished", function()
        f:Hide()
    end)

    function ag:Display(r, g, b)
        f:SetWidth(parent:GetParent():GetHeight()/2)
        t1:SetOffset(0, parent:GetHeight()/2)
        tex:SetGradient("VERTICAL", CreateColor(r, g, b, 0), CreateColor(r, g, b, 1))

        if ag:IsPlaying() then
            ag:Restart()
        else
            ag:Play()
        end
    end

    function ag:UpdateOrientation()
        -- f:SetWidth(parent:GetParent():GetHeight()/2)
    end

    function ag:SetSpeedMultiplier(s)
        a1:SetDuration(a1.duration/s)
        t1:SetDuration(t1.duration/s)
        a2:SetDuration(a2.duration/s)
    end

    return ag
end

--! Type D
local function CreateAnimationGroup_TypeD(parent)
    -- frame
    local f = CreateFrame("Frame", parent:GetName().."_TypeD", parent)
    f:SetAllPoints(parent)
    f:Hide()

    -- texture
    local tex = f:CreateTexture(nil, "ARTWORK")
    tex:SetPoint("CENTER")

    local mask = f:CreateMaskTexture()
    mask:SetAllPoints(tex)
    mask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    tex:AddMaskTexture(mask)

    tex:AddMaskTexture(parent.mask)

    -- animation
    local ag = f:CreateAnimationGroup()

    local a1 = ag:CreateAnimation("Alpha")
    a1.duration = 0.5
    a1:SetFromAlpha(0)
    a1:SetToAlpha(1)
    a1:SetOrder(1)
    a1:SetDuration(a1.duration)
    a1:SetSmoothing("OUT")

    local s1 = ag:CreateAnimation("Scale")
    s1.duration = 0.5
    s1:SetScaleFrom(0,0)
    s1:SetScaleTo(1,1)
    s1:SetOrder(1)
    s1:SetDuration(s1.duration)

    local a2 = ag:CreateAnimation("Alpha")
    a2.duration = 0.5
    a2:SetFromAlpha(1)
    a2:SetToAlpha(0)
    a2:SetDuration(a2.duration)
    a2:SetOrder(2)
    a2:SetSmoothing("IN")

    ag:SetScript("OnPlay", function()
        f:Show()
    end)

    ag:SetScript("OnFinished", function()
        f:Hide()
    end)

    function ag:Display(r, g, b)
        local l = math.sqrt((parent:GetHeight()/2)^2 + (parent:GetWidth()/2)^2) * 2
        tex:SetSize(l, l)
        tex:SetColorTexture(r, g, b, 0.5)

        if ag:IsPlaying() then
            ag:Restart()
        else
            ag:Play()
        end
    end

    function ag:UpdateOrientation()
        -- do nothing
    end

    function ag:SetSpeedMultiplier(s)
        a1:SetDuration(a1.duration/s)
        s1:SetDuration(s1.duration/s)
        a2:SetDuration(a2.duration/s)
    end

    return ag
end

--! Type E
local function CreateAnimationGroup_TypeE(parent)
    -- frame
    local f = CreateFrame("Frame", parent:GetName().."_TypeE", parent)
    f:SetPoint("TOPRIGHT", parent, "TOPLEFT")
    f:SetPoint("BOTTOMRIGHT", parent, "BOTTOMLEFT")
    f:Hide()

    -- texture
    local tex = f:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints(f)
    tex:SetTexture("Interface/AddOns/Cell/Media/Icons/arrow.tga")

    tex:AddMaskTexture(parent.mask)

    -- animation
    local ag = f:CreateAnimationGroup()

    -- local a1 = ag:CreateAnimation("Alpha")
    -- a1:SetFromAlpha(0)
    -- a1:SetToAlpha(0.7)
    -- a1:SetDuration(0.3)
    -- a1:SetSmoothing("OUT")

    local t1 = ag:CreateAnimation("Translation")
    t1.duration = 0.8
    t1:SetSmoothing("IN_OUT")
    t1:SetDuration(t1.duration)

    -- local a2 = ag:CreateAnimation("Alpha")
    -- a2:SetFromAlpha(0.7)
    -- a2:SetToAlpha(0)
    -- a2:SetDuration(0.3)
    -- a2:SetStartDelay(0.5)
    -- a2:SetSmoothing("IN")

    ag:SetScript("OnPlay", function()
        f:Show()
    end)

    ag:SetScript("OnFinished", function()
        f:Hide()
    end)

    function ag:Display(r, g, b)
        local l = parent:GetHeight()*2
        f:SetWidth(l)
        t1:SetOffset(l+parent:GetWidth(), 0)

        tex:SetVertexColor(r, g, b, 0.5)

        if ag:IsPlaying() then
            ag:Restart()
        else
            ag:Play()
        end
    end

    function ag:UpdateOrientation()
    end

    function ag:SetSpeedMultiplier(s)
        t1:SetDuration(t1.duration/s)
    end

    return ag
end

-------------------------------------------------
-- indicator
-------------------------------------------------
local previews = {}
local previewOrientation

function I.CreateActions(parent, isPreview)
    local actions = CreateFrame("Frame", parent:GetName().."ActionsParent", isPreview and parent or parent.widgets.indicatorFrame)

    -- mask
    local mask = actions:CreateMaskTexture()
    actions.mask = mask
    mask:SetTexture("Interface/Tooltips/UI-Tooltip-Background", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints(actions)
    mask:SetSnapToPixelGrid(true)

    -- animation groups
    local animations = {}
    actions.animations = animations
    animations.A = CreateAnimationGroup_TypeA(actions)
    animations.B = CreateAnimationGroup_TypeB(actions)
    animations.C1 = CreateAnimationGroup_TypeC(actions, 1)
    animations.C2 = CreateAnimationGroup_TypeC(actions, 2)
    animations.C3 = CreateAnimationGroup_TypeC(actions, 3)
    animations.D = CreateAnimationGroup_TypeD(actions)
    animations.E = CreateAnimationGroup_TypeE(actions)

    if isPreview then
        parent.actions = actions
        tinsert(previews, parent)
        actions:SetPoint("TOPLEFT", 1, -1)
        actions:SetPoint("BOTTOMRIGHT", -1, 1)
        for _, a in pairs(animations) do
            a:UpdateOrientation()
        end
    else
        parent.indicators.actions = actions
        actions:SetAllPoints(parent.widgets.healthBar)
    end

    -- speed
    function actions:SetSpeed(speed)
        for _, a in pairs(animations) do
            a:SetSpeedMultiplier(speed)
        end
    end

    -- show
    function actions:Display(animationType, color)
        animations[animationType]:Display(unpack(color))
    end
end

function I.UpdateActionsOrientation(parent, barOrientation)
    orientation = barOrientation
    for _, a in pairs(parent.indicators.actions.animations) do
        a:UpdateOrientation()
    end

    if previewOrientation ~= barOrientation then
        previewOrientation = barOrientation
        for _, p in pairs(previews) do
            for _, a in pairs(p.actions.animations) do
                a:UpdateOrientation()
            end
        end
    end
end

function I.EnableActions(enabled)
    if enabled then
        eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    else
        eventFrame:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    end
end