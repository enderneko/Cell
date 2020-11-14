local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local I = Cell.iFuncs

-------------------------------------------------
-- CreateAoEHealing -- not support for npc
-------------------------------------------------
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function()
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName = CombatLogGetCurrentEventInfo()
    if (subevent == "SPELL_HEAL" or subevent == "SPELL_PERIODIC_HEAL") and sourceGUID == Cell.vars.playerGUID and destGUID and F:IsAoEHealing(spellName) then
        if Cell.vars.groupType and Cell.vars.guid[destGUID] then
            Cell.unitButtons[Cell.vars.groupType][Cell.vars.guid[destGUID]].indicators.aoeHealing:ShowUp()
        end
    end
end)

function I:CreateAoEHealing(parent)
    local aoeHealing = CreateFrame("Frame", nil, parent)
	parent.indicators.aoeHealing = aoeHealing
	aoeHealing:SetPoint("TOPLEFT", parent.widget.healthBar)
    aoeHealing:SetPoint("TOPRIGHT", parent.widget.healthBar)
    aoeHealing:SetFrameLevel(5)
    -- aoeHealing:SetHeight(15)
	aoeHealing:Hide()

	aoeHealing.tex = aoeHealing:CreateTexture(nil, "ARTWORK")
    aoeHealing.tex:SetAllPoints(aoeHealing)
	aoeHealing.tex:SetTexture("Interface\\Buttons\\WHITE8x8")
    
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
		aoeHealing.tex:SetGradientAlpha("VERTICAL", r, g, b, 0, r, g, b, .77)
    end

    function aoeHealing:ShowUp()
        -- if ag:IsPlaying() then
        --     ag:Restart()
        -- else
            ag:Play()
        -- end
    end
end

function I:EnableAoEHealing(enabled)
    if enabled then
        eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    else
        eventFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end
end