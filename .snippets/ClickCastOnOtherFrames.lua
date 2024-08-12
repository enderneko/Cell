F = Cell.funcs

local blizzardFrames = {
    "PlayerFrame",
    "TargetFrame",
    "PetFrame",
    "PartyMemberFrame1",
    "PartyMemberFrame2",
    "PartyMemberFrame3",
    "PartyMemberFrame4",
    "PartyMemberFrame1PetFrame",
    "PartyMemberFrame2PetFrame",
    "PartyMemberFrame3PetFrame",
    "PartyMemberFrame4PetFrame",
}

local function UpdateClickCastFrame(frame, snippet)
    if frame then
        F:ClearClickCastings(frame)
        frame:SetAttribute("snippet", snippet)
        F:SetBindingClicks(frame)
        F:ApplyClickCastings(frame)
    end
end

local function UpdateClickCastings(noReload, onlyqueued)
    F:UpdateClickCastings(noReload, onlyqueued)
    local snippet = F:GetBindingSnippet()
    local ClickCastFrames = _G.ClickCastFrames or {}
    for frame, _ in pairs(ClickCastFrames) do
        UpdateClickCastFrame(frame, snippet)
    end
    for _, name in pairs(blizzardFrames) do
        UpdateClickCastFrame(_G[name], snippet)
    end
end
Cell:UnregisterCallback("UpdateClickCastings",  "ThirdPartyClickCastings")
Cell:RegisterCallback("UpdateClickCastings",  "ThirdPartyClickCastings", UpdateClickCastings)

