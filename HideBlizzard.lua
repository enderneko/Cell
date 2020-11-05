local _, Cell = ...
local F = Cell.funcs

local empty = function() end
local hider = CreateFrame("Frame", nil, nil, "SecureFrameTemplate")
hider:Hide()

local function HideBlizzardFrame(frame)
	if not frame then return end

	frame:UnregisterAllEvents()
	frame:SetScript("OnEvent", nil)
	frame:SetScript("OnUpdate", nil)
	frame:SetScript("OnSizeChanged", nil)
	frame:EnableMouse(false)
	frame:EnableKeyboard(false)
    frame:Hide()
    frame:SetParent(hider)
	frame:SetAlpha(0)
    frame.Show = empty
	RegisterStateDriver(frame, "visibility", "hide")
end

function F:HideBlizzard()
    if (not CompactRaidFrameManager) then return end

    HideBlizzardFrame(CompactRaidFrameManager)
    HideBlizzardFrame(CompactRaidFrameContainer)
    UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE")

    if CompactUnitFrameProfiles then CompactUnitFrameProfiles:UnregisterAllEvents() end

    -- hide party frames
    for i = 1, 4 do
        local frame = _G["PartyMemberFrame"..i]
        frame:SetParent(hider)
        frame:Hide()
        frame:UnregisterAllEvents()
        frame.Show = empty
        _G["PartyMemberFrame"..i..'HealthBar']:UnregisterAllEvents()
        _G["PartyMemberFrame"..i..'ManaBar']:UnregisterAllEvents()
    end
end