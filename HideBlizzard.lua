local _, Cell = ...
local F = Cell.funcs

-- stolen from elvui
local hiddenParent = CreateFrame("Frame", nil, _G.UIParent)
hiddenParent:SetAllPoints()
hiddenParent:Hide()

local function HideFrame(baseName, doNotReparent)
    local frame = _G[baseName]

    if frame then
        frame:UnregisterAllEvents()
        frame:Hide()

        if not doNotReparent then
            frame:SetParent(hiddenParent)
        end

        local health = frame.healthBar or frame.healthbar
        if health then
            health:UnregisterAllEvents()
        end

        local power = frame.manabar
        if power then
            power:UnregisterAllEvents()
        end

        local spell = frame.castBar or frame.spellbar
        if spell then
            spell:UnregisterAllEvents()
        end

        local altpowerbar = frame.powerBarAlt
        if altpowerbar then
            altpowerbar:UnregisterAllEvents()
        end

        local buffFrame = frame.BuffFrame
        if buffFrame then
            buffFrame:UnregisterAllEvents()
        end
    end
end

function F:HideBlizzardParty()
    for i = 1, 4 do
        HideFrame("PartyMemberFrame"..i)
    end
end

function F:HideBlizzardRaid()
    CompactRaidFrameManager_SetSetting("IsShown", "0")
    _G.UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE")
    _G.CompactRaidFrameManager:UnregisterAllEvents()
    _G.CompactRaidFrameManager:SetParent(hiddenParent)
end