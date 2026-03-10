local _, Cell = ...
local L = Cell.L
---@type CellFuncs
local F = Cell.funcs
---@class CellIndicatorFuncs
local I = Cell.iFuncs

-------------------------------------------------
-- CreateAoEHealing -- not support for npc
-------------------------------------------------
-- NOTE: This indicator relied on COMBAT_LOG_EVENT_UNFILTERED (SPELL_HEAL /
-- SPELL_PERIODIC_HEAL / SPELL_SUMMON) to detect AoE healing events.
-- COMBAT_LOG_EVENT_UNFILTERED is removed in Midnight (WoW 12.0.0).
-- When Cell.isMidnight is true the eventFrame is never registered, so no
-- flash animation will trigger. The indicator frame still exists and can be
-- re-enabled if a suitable non-CLEU API becomes available in a future build.

local function Display(b)
    b.indicators.aoeHealing:Display()
end

local eventFrame = CreateFrame("Frame")

if not Cell.isMidnight then
    local playerSummoned = {}
    eventFrame:SetScript("OnEvent", function()
        local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName = CombatLogGetCurrentEventInfo()
        -- if subevent == "SPELL_SUMMON" then print(subevent, sourceName, sourceGUID, destName, destGUID, spellName) end
        if subevent == "SPELL_SUMMON" then
            if sourceGUID == Cell.vars.playerGUID and destGUID and I.IsAoEHealing(spellName, spellId) then
                local duration = I.GetSummonDuration(spellName)
                if duration then
                    playerSummoned[destGUID] = GetTime() + duration -- expirationTime
                    C_Timer.After(duration, function()
                        playerSummoned[destGUID] = nil
                    end)
                end
            end
        end
        if subevent == "SPELL_HEAL" or subevent == "SPELL_PERIODIC_HEAL" then
            if destGUID then
                if (sourceGUID == Cell.vars.playerGUID and I.IsAoEHealing(spellName, spellId)) or playerSummoned[sourceGUID] then
                    F.HandleUnitButton("guid", destGUID, Display)
                end
            end
        end
    end)
end

function I.CreateAoEHealing(parent)
    local aoeHealing = CreateFrame("Frame", parent:GetName().."AoEHealing", parent.widgets.indicatorFrame)
    parent.indicators.aoeHealing = aoeHealing
    aoeHealing:SetPoint("TOPLEFT", parent.widgets.healthBar)
    aoeHealing:SetPoint("TOPRIGHT", parent.widgets.healthBar)
    aoeHealing:Hide()

    aoeHealing.tex = aoeHealing:CreateTexture(nil, "ARTWORK")
    aoeHealing.tex:SetAllPoints(aoeHealing)
    aoeHealing.tex:SetTexture(Cell.vars.whiteTexture)

    local ag = aoeHealing:CreateAnimationGroup()
    local a1 = ag:CreateAnimation("Alpha")
    a1:SetFromAlpha(0)
    a1:SetToAlpha(1)
    a1:SetDuration(0.5)
    a1:SetOrder(1)
    a1:SetSmoothing("OUT")
    local a2 = ag:CreateAnimation("Alpha")
    a2:SetFromAlpha(1)
    a2:SetToAlpha(0)
    a2:SetDuration(0.5)
    a2:SetOrder(2)
    a2:SetSmoothing("IN")

    ag:SetScript("OnPlay", function()
        aoeHealing:Show()
    end)
    ag:SetScript("OnFinished", function()
        aoeHealing:Hide()
    end)

    function aoeHealing:SetColor(r, g, b)
        aoeHealing.tex:SetGradient("VERTICAL", CreateColor(r, g, b, 0), CreateColor(r, g, b, 0.77))
    end

    function aoeHealing:Display()
        -- if ag:IsPlaying() then
        --     ag:Restart()
        -- else
            ag:Play()
        -- end
    end
end

function I.EnableAoEHealing(enabled)
    -- On Midnight (12.0.0+) COMBAT_LOG_EVENT_UNFILTERED is unavailable;
    -- the eventFrame has no OnEvent script in that case, so registration
    -- is intentionally skipped.
    if Cell.isMidnight then return end
    if enabled then
        eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    else
        eventFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end
end