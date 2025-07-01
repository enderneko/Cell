-------------------------------------------------
-- 2024-06-27 14:00:54 GMT+8
-- 光明尾迹
-------------------------------------------------
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs
local AF = _G.AbstractFramework

local icon = CreateFrame("Frame", nil, CellMainFrame, "BackdropTemplate")
icon:SetBackdrop({bgFile = AF.GetPlainTexture()})
icon:SetBackdropColor(0, 0, 0, 1)
icon:SetSize(13, 13) -- 尺寸
icon:Hide()

icon.tex = icon:CreateTexture(nil, "ARTWORK")
icon.tex:SetTexCoord(0.12, 0.88, 0.12, 0.88)
P.Point(icon.tex, "TOPLEFT", icon, "TOPLEFT", 1, -1)
P.Point(icon.tex, "BOTTOMRIGHT", icon, "BOTTOMRIGHT", -1, 1)

icon.tex:SetTexture(1022951)

local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:SetScript("OnEvent", function(self, event)
    local _, subEvent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName = CombatLogGetCurrentEventInfo()

    if subEvent == "SPELL_HEAL" then
        if spellId == 234946 then
            local b = F.GetUnitButtonByGUID(destGUID)
            if b then
                icon:SetParent(b.widgets.indicatorFrame)
                icon:SetFrameLevel(5) -- 层级
                icon:ClearAllPoints()
                icon:SetPoint("TOP") -- 位置
                icon:Show()
            else
                icon:Hide()
            end
        end
    end
end)