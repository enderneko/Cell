local _, Cell = ...
local F = Cell.funcs
local B = Cell.bFuncs
local P = Cell.pixelPerfectFuncs

local soloFrame = CreateFrame("Frame", "CellSoloFrame", Cell.frames.mainFrame, "SecureFrameTemplate")
Cell.frames.soloFrame = soloFrame
soloFrame:SetAllPoints(Cell.frames.mainFrame)

local playerButton = CreateFrame("Button", soloFrame:GetName().."Player", soloFrame, "CellUnitButtonTemplate")
-- playerButton.type = "main" -- layout setup
playerButton:SetAttribute("unit", "player")
playerButton:SetPoint("TOPLEFT")
playerButton:Show()
Cell.unitButtons.solo["player"] = playerButton

local petButton = CreateFrame("Button", soloFrame:GetName().."Pet", soloFrame, "CellUnitButtonTemplate")
-- petButton.type = "pet" -- layout setup
petButton:SetAttribute("unit", "pet")
Cell.unitButtons.solo["pet"] = petButton

local init, previousLayout
local function SoloFrame_UpdateLayout(layout, which)
    if Cell.vars.groupType ~= "solo" and init then return end

    -- visibility
    if layout == "hide" then
        UnregisterAttributeDriver(soloFrame, "state-visibility")
        soloFrame:Hide()
        if init then
            return
        else
            layout = "default"
        end
    else
        RegisterAttributeDriver(soloFrame, "state-visibility", "[@raid1,exists] hide;[@party1,exists] hide;[group] hide;show")
    end

    -- update
    init = true
    layout = CellDB["layouts"][layout]

    if not which or strfind(which, "size$") then
        local width, height = unpack(layout["main"]["size"])
        P.Size(playerButton, width, height)
        if layout["pet"]["sameSizeAsMain"] then
            P.Size(petButton, width, height)
        else
            P.Size(petButton, layout["pet"]["size"][1], layout["pet"]["size"][2])
        end
    end

    -- NOTE: SetOrientation BEFORE SetPowerSize
    if not which or which == "barOrientation" then
        B.SetOrientation(playerButton, layout["barOrientation"][1], layout["barOrientation"][2])
        B.SetOrientation(petButton, layout["barOrientation"][1], layout["barOrientation"][2])
    end

    if not which or strfind(which, "power$") or which == "barOrientation" or which == "powerFilter" then
        B.SetPowerSize(playerButton, layout["main"]["powerSize"])
        if layout["pet"]["sameSizeAsMain"] then
            B.SetPowerSize(petButton, layout["main"]["powerSize"])
        else
            B.SetPowerSize(petButton, layout["pet"]["powerSize"])
        end
    end

    if not which or which == "main-arrangement" or which == "pet-arrangement" then
        petButton:ClearAllPoints()
        if layout["main"]["orientation"] == "vertical" then
            -- anchor
            local point, anchorPoint
            local petSpacing = layout["pet"]["sameArrangementAsMain"] and layout["main"]["spacingY"] or layout["pet"]["spacingY"]

            if layout["main"]["anchor"] == "BOTTOMLEFT" then
                point, anchorPoint = "BOTTOMLEFT", "TOPLEFT"
            elseif layout["main"]["anchor"] == "BOTTOMRIGHT" then
                point, anchorPoint = "BOTTOMRIGHT", "TOPRIGHT"
            elseif layout["main"]["anchor"] == "TOPLEFT" then
                point, anchorPoint = "TOPLEFT", "BOTTOMLEFT"
                petSpacing = -petSpacing
            elseif layout["main"]["anchor"] == "TOPRIGHT" then
                point, anchorPoint = "TOPRIGHT", "BOTTOMRIGHT"
                petSpacing = -petSpacing
            end

            petButton:SetPoint(point, playerButton, anchorPoint, 0, petSpacing)
        else
            -- anchor
            local point, anchorPoint
            local petSpacing = layout["pet"]["sameArrangementAsMain"] and layout["main"]["spacingX"] or layout["pet"]["spacingX"]

            if layout["main"]["anchor"] == "BOTTOMLEFT" then
                point, anchorPoint = "BOTTOMLEFT", "BOTTOMRIGHT"
            elseif layout["main"]["anchor"] == "BOTTOMRIGHT" then
                point, anchorPoint = "BOTTOMRIGHT", "BOTTOMLEFT"
                petSpacing = -petSpacing
            elseif layout["main"]["anchor"] == "TOPLEFT" then
                point, anchorPoint = "TOPLEFT", "TOPRIGHT"
            elseif layout["main"]["anchor"] == "TOPRIGHT" then
                point, anchorPoint = "TOPRIGHT", "TOPLEFT"
                petSpacing = -petSpacing
            end

            petButton:SetPoint(point, playerButton, anchorPoint, petSpacing, 0)
        end
    end

    if not which or which == "pet" then
        if layout["pet"]["soloEnabled"] then
            RegisterAttributeDriver(petButton, "state-visibility", "[nopet] hide; [vehicleui] hide; show")
        else
            UnregisterAttributeDriver(petButton, "state-visibility")
            petButton:Hide()
        end
    end
end
Cell.RegisterCallback("UpdateLayout", "SoloFrame_UpdateLayout", SoloFrame_UpdateLayout)

-- local function SoloFrame_UpdateVisibility(which)
--     F.Debug("|cffff7fffUpdateVisibility:|r "..(which or "all"))

--     if not which or which == "solo" then
--         if CellDB["general"]["showSolo"] then
--             RegisterAttributeDriver(soloFrame, "state-visibility", "[@raid1,exists] hide;[@party1,exists] hide;[group] hide;show")
--         else
--             UnregisterAttributeDriver(soloFrame, "state-visibility")
--             soloFrame:Hide()
--         end
--     end
-- end
-- Cell.RegisterCallback("UpdateVisibility", "SoloFrame_UpdateVisibility", SoloFrame_UpdateVisibility)