local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

local raidRosterFrame = Cell:CreateFrame("CellRaidRosterFrame", Cell.frames.mainFrame, 202, 69)
Cell.frames.raidRosterFrame = raidRosterFrame
Cell:StylizeFrame(raidRosterFrame, {.1, .1, .1, .5})
raidRosterFrame:SetPoint("BOTTOMLEFT", Cell.frames.mainFrame, "TOPLEFT", 0, 18)
raidRosterFrame:Hide()

function F:ShowRaidRosterFrame()
    if raidRosterFrame:IsShown() then
        raidRosterFrame:Hide()
    else
        raidRosterFrame:Show()
    end
    Cell.frames.toolsFrame:Hide()
end