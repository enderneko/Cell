-- Trail of Light
local F = Cell.funcs
local LCG = LibStub("LibCustomGlow-1.0")
local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:SetScript("OnEvent", function(self, event)
    local _, subEvent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName = CombatLogGetCurrentEventInfo()

    if subEvent == "SPELL_HEAL" then
        if spellId == 2061 or spellId == 2060 then
            F:IterateAllUnitButtons(function(b)
                if b.state.guid == destGUID then
                    LCG.PixelGlow_Start(b)
                else
                    LCG.PixelGlow_Stop(b) 
                end
            end, true)
        end
        
        if spellId == 234946 then
            F:IterateAllUnitButtons(function(b)
                if b.state.guid == destGUID then
                    LCG.AutoCastGlow_Start(b)
                else
                    LCG.AutoCastGlow_Stop(b)
                end
            end, true)
        end    
    end
end)