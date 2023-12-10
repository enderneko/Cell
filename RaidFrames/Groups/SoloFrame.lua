local _, Cell = ...
local F = Cell.funcs
local B = Cell.bFuncs
local P = Cell.pixelPerfectFuncs

local soloFrame = CreateFrame("Frame", "CellSoloFrame", Cell.frames.mainFrame, "SecureFrameTemplate")
Cell.frames.soloFrame = soloFrame
soloFrame:SetAllPoints(Cell.frames.mainFrame)
-- RegisterAttributeDriver(soloFrame, "state-visibility", "[group] hide; show")

local playerButton = CreateFrame("Button", soloFrame:GetName().."Player", soloFrame, "CellUnitButtonTemplate")
-- playerButton.type = "main" -- layout setup
playerButton:SetAttribute("unit", "player")
playerButton:SetPoint("TOPLEFT")
playerButton:Show()
Cell.unitButtons.solo["player"] = playerButton

local petButton = CreateFrame("Button", soloFrame:GetName().."Pet", soloFrame, "CellUnitButtonTemplate")
-- petButton.type = "pet" -- layout setup
petButton:SetAttribute("unit", "pet")
RegisterAttributeDriver(petButton, "state-visibility", "[nopet] hide; [vehicleui] hide; show")
Cell.unitButtons.solo["pet"] = petButton

local init, previousLayout
local function SoloFrame_UpdateLayout(layout, which)
    if Cell.vars.groupType ~= "solo" and init then return end
    init = true

    -- if previousLayout == layout and not which then return end
    -- previousLayout = layout

    layout = CellDB["layouts"][layout]

    if not which or strfind(which, "size$") then
        local width, height = unpack(layout["main"]["size"])
        P:Size(playerButton, width, height)
        if layout["pet"]["sameSizeAsMain"] then
            P:Size(petButton, width, height)
        else
            P:Size(petButton, layout["pet"]["size"][1], layout["pet"]["size"][2])
        end
    end

    -- NOTE: SetOrientation BEFORE SetPowerSize
    if not which or which == "barOrientation" then
        B:SetOrientation(playerButton, layout["barOrientation"][1], layout["barOrientation"][2])
        B:SetOrientation(petButton, layout["barOrientation"][1], layout["barOrientation"][2])
    end
    
    if not which or strfind(which, "power$") or which == "barOrientation" or which == "powerFilter" then
        B:SetPowerSize(playerButton, layout["main"]["powerSize"])
        if layout["pet"]["sameSizeAsMain"] then
            B:SetPowerSize(petButton, layout["main"]["powerSize"])
        else
            B:SetPowerSize(petButton, layout["pet"]["powerSize"])
        end
    end

    if not which or which == "main-arrangement" then
        petButton:ClearAllPoints()
        if layout["main"]["orientation"] == "vertical" then
            -- anchor
            local point, anchorPoint, unitSpacing
            if layout["main"]["anchor"] == "BOTTOMLEFT" then
                point, anchorPoint = "BOTTOMLEFT", "TOPLEFT"
                unitSpacing = layout["main"]["spacingY"]
            elseif layout["main"]["anchor"] == "BOTTOMRIGHT" then
                point, anchorPoint = "BOTTOMRIGHT", "TOPRIGHT"
                unitSpacing = layout["main"]["spacingY"]
            elseif layout["main"]["anchor"] == "TOPLEFT" then
                point, anchorPoint = "TOPLEFT", "BOTTOMLEFT"
                unitSpacing = -layout["main"]["spacingY"]
            elseif layout["main"]["anchor"] == "TOPRIGHT" then
                point, anchorPoint = "TOPRIGHT", "BOTTOMRIGHT"
                unitSpacing = -layout["main"]["spacingY"]
            end

            petButton:SetPoint(point, playerButton, anchorPoint, 0, unitSpacing)
        else
            -- anchor
            local point, anchorPoint, unitSpacing
            if layout["main"]["anchor"] == "BOTTOMLEFT" then
                point, anchorPoint = "BOTTOMLEFT", "BOTTOMRIGHT"
                unitSpacing = layout["main"]["spacingX"]
            elseif layout["main"]["anchor"] == "BOTTOMRIGHT" then
                point, anchorPoint = "BOTTOMRIGHT", "BOTTOMLEFT"
                unitSpacing = -layout["main"]["spacingX"]
            elseif layout["main"]["anchor"] == "TOPLEFT" then
                point, anchorPoint = "TOPLEFT", "TOPRIGHT"
                unitSpacing = layout["main"]["spacingX"]
            elseif layout["main"]["anchor"] == "TOPRIGHT" then
                point, anchorPoint = "TOPRIGHT", "TOPLEFT"
                unitSpacing = -layout["main"]["spacingX"]
            end

            petButton:SetPoint(point, playerButton, anchorPoint, unitSpacing, 0)
        end
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