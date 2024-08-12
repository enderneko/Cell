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


local function UpdateClickCastings(noReload, onlyqueued)
    F:UpdateClickCastings(noReload, onlyqueued)
    local snippet = F:GetBindingSnippet()
    local ClickCastFrames = _G.ClickCastFrames or {}
    for frame, _ in pairs(ClickCastFrames) do
        F:UpdateClickCastOnFrame(frame, snippet)
    end
    for _, name in pairs(blizzardFrames) do
        F:UpdateClickCastOnFrame(_G[name], snippet)
    end
end
local function UpdateQueuedClickCastings()
    UpdateClickCastings(true, true)
end
Cell:UnregisterCallback("UpdateClickCastings",  "UpdateClickCastings")
Cell:UnregisterCallback("UpdateQueuedClickCastings",  "UpdateQueuedClickCastings")
Cell:RegisterCallback("UpdateQueuedClickCastings", "UpdateQueuedClickCastings", UpdateQueuedClickCastings)
Cell:RegisterCallback("UpdateClickCastings",  "UpdateClickCastings", UpdateClickCastings)

