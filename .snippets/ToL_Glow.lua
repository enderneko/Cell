-------------------------------------------------
-- 2022-06-03 20:29:22 GMT+8
-- 光明尾迹（单位按钮高亮）
-------------------------------------------------
local F = Cell.funcs
local LCG = LibStub("LibCustomGlow-1.0")
local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:SetScript("OnEvent", function(self, event)
    local _, subEvent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName = CombatLogGetCurrentEventInfo()

    if subEvent == "SPELL_HEAL" then
        if spellId == 2061 or spellId == 2060 then
            F:IterateAllUnitButtons(function(b)
                if b.states.guid == destGUID then
                    LCG.PixelGlow_Start(b)
                else
                    LCG.PixelGlow_Stop(b)
                end
            end, true)
        end

        if spellId == 234946 then
            F:IterateAllUnitButtons(function(b)
                if b.states.guid == destGUID then
                    LCG.AutoCastGlow_Start(b)
                else
                    LCG.AutoCastGlow_Stop(b)
                end
            end, true)
        end
    end
end)