local _, Cell = ...
local F = Cell.funcs

local function HideBlizzardFrame(frame)
	if not frame then return end

	frame:UnregisterAllEvents()
	frame:SetScript("OnEvent", nil)
	frame:SetScript("OnUpdate", nil)
	frame:SetScript("OnSizeChanged", nil)
	frame:EnableMouse(false)
	frame:EnableKeyboard(false)
	frame:Hide()
	frame:SetAlpha(0)
	frame:SetScale(0.01)
	RegisterStateDriver(frame, "visibility", "hide")
end

local hider = CreateFrame("Frame")
hider:Hide()

function F:HideBlizzard()
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
        _G["PartyMemberFrame"..i..'HealthBar']:UnregisterAllEvents()
        _G["PartyMemberFrame"..i..'ManaBar']:UnregisterAllEvents()
    end
end