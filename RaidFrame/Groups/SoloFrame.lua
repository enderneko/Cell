local _, Cell = ...
local F = Cell.funcs

local soloFrame = CreateFrame("Frame", "CellSoloFrame", Cell.frames.mainFrame, "SecureFrameTemplate")
Cell.frames.soloFrame = soloFrame
soloFrame:SetAllPoints(Cell.frames.mainFrame)
-- RegisterAttributeDriver(soloFrame, "state-visibility", "[group] hide; show")

local playerButton = CreateFrame("Button", soloFrame:GetName().."Player", soloFrame, "CellUnitButtonTemplate")
playerButton:SetAttribute("unit", "player")
playerButton:SetPoint("TOPLEFT")
playerButton:Show()
Cell.unitButtons.solo["player"] = playerButton

local petButton = CreateFrame("Button", soloFrame:GetName().."Pet", soloFrame, "CellUnitButtonTemplate")
petButton:SetAttribute("unit", "pet")
RegisterAttributeDriver(petButton, "state-visibility", "[nopet] hide; [vehicleui] hide; show")
Cell.unitButtons.solo["pet"] = petButton

local function SoloFrame_UpdateLayout(layout, which)
    if layout ~= Cell.vars.currentLayout then return end
    layout = Cell.vars.currentLayoutTable

    if not which or which == "size" then
        local width, height = unpack(layout["size"])
        playerButton:SetSize(width, height)
        petButton:SetSize(width, height)
    end

    if not which or which == "spacing" then
        petButton:ClearAllPoints()
        if layout["orientation"] == "vertical" then
            petButton:SetPoint("TOPLEFT", playerButton, "BOTTOMLEFT", 0, -layout["spacing"])
        else
            petButton:SetPoint("TOPLEFT", playerButton, "TOPRIGHT", layout["spacing"], 0)
        end
    end

    if which == "textWidth" then -- textWidth already initialized in UnitButton.lua
        playerButton:GetScript("OnSizeChanged")(playerButton)
        petButton:GetScript("OnSizeChanged")(petButton)
    end
end
Cell:RegisterCallback("UpdateLayout", "SoloFrame_UpdateLayout", SoloFrame_UpdateLayout)

local function SoloFrame_UpdateVisibility()
    if CellDB["showSolo"] then
        RegisterAttributeDriver(soloFrame, "state-visibility", "[group] hide; show")
    else
        RegisterAttributeDriver(soloFrame, "state-visibility", "hide")
    end
end
Cell:RegisterCallback("UpdateVisibility", "SoloFrame_UpdateVisibility", SoloFrame_UpdateVisibility)