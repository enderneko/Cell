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

local init
local function SoloFrame_UpdateLayout(layout, which)
    -- if layout ~= Cell.vars.currentLayout then return end
    if Cell.vars.groupType ~= "solo" and init then return end
    init = true
    layout = CellDB["layouts"][CellCharacterDB["party"]]

    if not which or which == "size" then
        local width, height = unpack(layout["size"])
        playerButton:SetSize(width, height)
        petButton:SetSize(width, height)
    end
    
    if not which or which == "power" then
        playerButton.func.SetPowerHeight(layout["powerHeight"])
        petButton.func.SetPowerHeight(layout["powerHeight"])
    end


    if not which or which == "spacing" or which == "orientation" or which == "anchor" then
        petButton:ClearAllPoints()
        if layout["orientation"] == "vertical" then
            -- anchor
            local point, anchorPoint, unitSpacing
            if layout["anchor"] == "BOTTOMLEFT" then
                point, anchorPoint = "BOTTOMLEFT", "TOPLEFT"
                unitSpacing = layout["spacing"]
            elseif layout["anchor"] == "BOTTOMRIGHT" then
                point, anchorPoint = "BOTTOMRIGHT", "TOPRIGHT"
                unitSpacing = layout["spacing"]
            elseif layout["anchor"] == "TOPLEFT" then
                point, anchorPoint = "TOPLEFT", "BOTTOMLEFT"
                unitSpacing = -layout["spacing"]
            elseif layout["anchor"] == "TOPRIGHT" then
                point, anchorPoint = "TOPRIGHT", "BOTTOMRIGHT"
                unitSpacing = -layout["spacing"]
            end

            petButton:SetPoint(point, playerButton, anchorPoint, 0, unitSpacing)
        else
            -- anchor
            local point, anchorPoint, unitSpacing
            if layout["anchor"] == "BOTTOMLEFT" then
                point, anchorPoint = "BOTTOMLEFT", "BOTTOMRIGHT"
                unitSpacing = layout["spacing"]
            elseif layout["anchor"] == "BOTTOMRIGHT" then
                point, anchorPoint = "BOTTOMRIGHT", "BOTTOMLEFT"
                unitSpacing = -layout["spacing"]
            elseif layout["anchor"] == "TOPLEFT" then
                point, anchorPoint = "TOPLEFT", "TOPRIGHT"
                unitSpacing = layout["spacing"]
            elseif layout["anchor"] == "TOPRIGHT" then
                point, anchorPoint = "TOPRIGHT", "TOPLEFT"
                unitSpacing = -layout["spacing"]
            end

            petButton:SetPoint(point, playerButton, anchorPoint, unitSpacing, 0)
        end
    end

    if which == "textWidth" then -- textWidth already initialized in UnitButton.lua
        playerButton:GetScript("OnSizeChanged")(playerButton)
        petButton:GetScript("OnSizeChanged")(petButton)
    end
end
Cell:RegisterCallback("UpdateLayout", "SoloFrame_UpdateLayout", SoloFrame_UpdateLayout)

local function SoloFrame_UpdateVisibility(which)
    F:Debug("|cffff7fffUpdateVisibility:|r "..(which or "all"))

    if not which or which == "solo" then
        if CellDB["general"]["showSolo"] then
            RegisterAttributeDriver(soloFrame, "state-visibility", "[group] hide; show")
        else
            UnregisterAttributeDriver(soloFrame, "state-visibility")
            soloFrame:Hide()
        end
    end
end
Cell:RegisterCallback("UpdateVisibility", "SoloFrame_UpdateVisibility", SoloFrame_UpdateVisibility)