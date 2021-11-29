local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

local powerFilters = Cell:CreateFrame("CellOptionsFrame_PowerFilters", Cell.frames.layoutsTab, 270, 205)
Cell.frames.powerFilters = powerFilters
powerFilters:SetFrameStrata("DIALOG")
powerFilters:SetPoint("BOTTOMLEFT", Cell.frames.layoutsTab.powerFilterBtn, "TOPLEFT", -5, 5)
powerFilters:SetFrameLevel(50)

-------------------------------------------------
-- filters
-------------------------------------------------
local dkF =  Cell:CreatePowerFilter(powerFilters, "DEATHKNIGHT", {"TANK", "DAMAGER"}, 125, 20, 20)
dkF:SetPoint("TOPLEFT", 5, -5)

local dhF = Cell:CreatePowerFilter(powerFilters, "DEMONHUNTER", {"TANK", "DAMAGER"}, 125, 20, 20)
dhF:SetPoint("TOPLEFT", 140, -5)

local druidF = Cell:CreatePowerFilter(powerFilters, "DRUID", {"TANK", "HEALER", "DAMAGER"}, 125, 20, 20)
druidF:SetPoint("TOPLEFT", dkF, "BOTTOMLEFT", 0, -5)

local hunterF = Cell:CreatePowerFilter(powerFilters, "HUNTER", {"DAMAGER"}, 125, 20, 20)
hunterF:SetPoint("TOPLEFT", dhF, "BOTTOMLEFT", 0, -5)

local mageF = Cell:CreatePowerFilter(powerFilters, "MAGE", {"DAMAGER"}, 125, 20, 20)
mageF:SetPoint("TOPLEFT", druidF, "BOTTOMLEFT", 0, -5)

local monkF = Cell:CreatePowerFilter(powerFilters, "MONK", {"TANK", "HEALER", "DAMAGER"}, 125, 20, 20)
monkF:SetPoint("TOPLEFT", hunterF, "BOTTOMLEFT", 0, -5)

local paladinF = Cell:CreatePowerFilter(powerFilters, "PALADIN", {"TANK", "HEALER", "DAMAGER"}, 125, 20, 20)
paladinF:SetPoint("TOPLEFT", mageF, "BOTTOMLEFT", 0, -5)

local priestF = Cell:CreatePowerFilter(powerFilters, "PRIEST", {"HEALER", "DAMAGER"}, 125, 20, 20)
priestF:SetPoint("TOPLEFT", monkF, "BOTTOMLEFT", 0, -5)

local rogueF = Cell:CreatePowerFilter(powerFilters, "ROGUE", {"DAMAGER"}, 125, 20, 20)
rogueF:SetPoint("TOPLEFT", paladinF, "BOTTOMLEFT", 0, -5)

local shamanF = Cell:CreatePowerFilter(powerFilters, "SHAMAN", {"HEALER", "DAMAGER"}, 125, 20, 20)
shamanF:SetPoint("TOPLEFT", priestF, "BOTTOMLEFT", 0, -5)

local warlockF = Cell:CreatePowerFilter(powerFilters, "WARLOCK", {"DAMAGER"}, 125, 20, 20)
warlockF:SetPoint("TOPLEFT", rogueF, "BOTTOMLEFT", 0, -5)

local warriorF = Cell:CreatePowerFilter(powerFilters, "WARRIOR", {"TANK", "DAMAGER"}, 125, 20, 20)
warriorF:SetPoint("TOPLEFT", shamanF, "BOTTOMLEFT", 0, -5)

local petF = Cell:CreatePowerFilter(powerFilters, "PET", {"DAMAGER"}, 125, 20, 20)
petF:SetPoint("TOPLEFT", warlockF, "BOTTOMLEFT", 0, -5)

local vehicleF = Cell:CreatePowerFilter(powerFilters, "VEHICLE", {"DAMAGER"}, 125, 20, 20)
vehicleF:SetPoint("TOPLEFT", warriorF, "BOTTOMLEFT", 0, -5)

local npcF = Cell:CreatePowerFilter(powerFilters, "NPC", {"DAMAGER"}, 125, 20, 20)
npcF:SetPoint("TOPLEFT", petF, "BOTTOMLEFT", 0, -5)

-------------------------------------------------
-- scripts
-------------------------------------------------
powerFilters:SetScript("OnHide", function()
    powerFilters:Hide()
    Cell.frames.layoutsTab.mask:Hide()
end)

function F:ShowPowerFilters(selectedLayout, selectedLayoutTable)
    if powerFilters:IsShown() then
        powerFilters:Hide()
        Cell.frames.layoutsTab.powerFilterBtn:SetFrameStrata("HIGH")
    else
        powerFilters:Show()
        Cell.frames.layoutsTab.powerFilterBtn:SetFrameStrata("DIALOG")
        Cell:CreateMask(Cell.frames.layoutsTab)
        -- load db
        dkF:LoadConfig(selectedLayout, selectedLayoutTable)
        dhF:LoadConfig(selectedLayout, selectedLayoutTable)
        druidF:LoadConfig(selectedLayout, selectedLayoutTable)
        hunterF:LoadConfig(selectedLayout, selectedLayoutTable)
        mageF:LoadConfig(selectedLayout, selectedLayoutTable)
        monkF:LoadConfig(selectedLayout, selectedLayoutTable)
        paladinF:LoadConfig(selectedLayout, selectedLayoutTable)
        priestF:LoadConfig(selectedLayout, selectedLayoutTable)
        rogueF:LoadConfig(selectedLayout, selectedLayoutTable)
        shamanF:LoadConfig(selectedLayout, selectedLayoutTable)
        warlockF:LoadConfig(selectedLayout, selectedLayoutTable)
        warriorF:LoadConfig(selectedLayout, selectedLayoutTable)
        petF:LoadConfig(selectedLayout, selectedLayoutTable)
        vehicleF:LoadConfig(selectedLayout, selectedLayoutTable)
        npcF:LoadConfig(selectedLayout, selectedLayoutTable)
    end
end