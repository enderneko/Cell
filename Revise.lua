local addonName, Cell = ...
local L = Cell.L
local F = Cell.funcs
local I = Cell.iFuncs

local function Revise()
    local dbRevision = CellDB["revise"] and tonumber(string.match(CellDB["revise"], "%d+")) or 0
    F:Debug("DBRevision:", dbRevision)

    --[[
    -- r4-alpha add "castByMe"
    if not(CellDB["revise"]) or CellDB["revise"] < "r4-alpha" then
        for _, layout in pairs(CellDB["layouts"]) do
            for _, indicator in pairs(layout["indicators"]) do
                if indicator["auraType"] == "buff" then
                    if indicator["castByMe"] == nil then
                        indicator["castByMe"] = true
                    end
                elseif indicator["indicatorName"] == "dispels" then
                    if indicator["checkbutton"] then
                        indicator["dispellableByMe"] = indicator["checkbutton"][2]
                        indicator["checkbutton"] = nil
                    end
                end
            end
        end
    end

    -- r6-alpha
    if not(CellDB["revise"]) or CellDB["revise"] < "r6-alpha" then
        -- add "textWidth"
        for _, layout in pairs(CellDB["layouts"]) do
            if not layout["textWidth"] then
                layout["textWidth"] = .75
            end
        end
        -- remove old raid tools related
        if CellDB["showRaidSetup"] then CellDB["showRaidSetup"] = nil end
        if CellDB["pullTimer"] then CellDB["pullTimer"] = nil end
    end

    -- r13-release: fix all
    if not(CellDB["revise"]) or dbRevision < 13 then
        -- r8-beta: add "centralDebuff"
        for _, layout in pairs(CellDB["layouts"]) do
            if not layout["indicators"][8] or layout["indicators"][8]["indicatorName"] ~= "centralDebuff" then
                tinsert(layout["indicators"], 8, {
                    ["name"] = "Central Debuff",
                    ["indicatorName"] = "centralDebuff",
                    ["type"] = "built-in",
                    ["enabled"] = true,
                    ["position"] = {"CENTER", "CENTER", 0, 3},
                    ["size"] = {20, 20},
                    ["font"] = {"Cell ".._G.DEFAULT, 11, "Outline", 2},
                })
            end
        end

        -- r9-beta: fix raidtool db
        if type(CellDB["raidTools"]["showBattleRes"]) ~= "boolean" then CellDB["raidTools"]["showBattleRes"] = true end
        if not CellDB["raidTools"]["buttonsPosition"] then CellDB["raidTools"]["buttonsPosition"] = {"TOPRIGHT", "CENTER", 0, 0} end
        if not CellDB["raidTools"]["marksPosition"] then CellDB["raidTools"]["marksPosition"] = {"BOTTOMRIGHT", "CENTER", 0, 0} end

        -- r11-release: add horizontal layout
        for _, layout in pairs(CellDB["layouts"]) do
            if type(layout["orientation"]) ~= "string" then
                layout["orientation"] = "vertical"
            end
        end

        -- r13 release: CellDB["appearance"]
        if CellDB["texture"] then CellDB["appearance"]["texture"] = CellDB["texture"] end
        if CellDB["scale"] then CellDB["appearance"]["scale"] = CellDB["scale"] end
        if CellDB["font"] then CellDB["appearance"]["font"] = CellDB["font"] end
        if CellDB["outline"] then CellDB["appearance"]["outline"] = CellDB["outline"] end
        CellDB["texture"] = nil
        CellDB["scale"] = nil
        CellDB["font"] = nil
        CellDB["outline"] = nil
    end

    -- r14-release: CellDB["general"]
    if not(CellDB["revise"]) or dbRevision < 14 then
        if CellDB["hideBlizzard"] then CellDB["general"]["hideBlizzard"] = CellDB["hideBlizzard"] end
        if CellDB["disableTooltips"] then CellDB["general"]["disableTooltips"] = CellDB["disableTooltips"] end
        if CellDB["showSolo"] then CellDB["general"]["showSolo"] = CellDB["showSolo"] end
        CellDB["hideBlizzard"] = nil
        CellDB["disableTooltips"] = nil
        CellDB["showSolo"] = nil
    end
    
    -- r15-release
    if not(CellDB["revise"]) or dbRevision < 15 then
        for _, layout in pairs(CellDB["layouts"]) do
            -- add powerHeight
            if type(layout["powerHeight"]) ~= "number" then
                layout["powerHeight"] = 2
            end
            -- add dispel highlight
            if layout["indicators"][6] and layout["indicators"][6]["indicatorName"] == "dispels" then
                if type(layout["indicators"][6]["enableHighlight"]) ~= "boolean" then
                    layout["indicators"][6]["enableHighlight"] = true
                end
            end
        end
        -- change showPets to showPartyPets
        if type(CellDB["general"]["showPartyPets"]) ~= "boolean" then
            CellDB["general"]["showPartyPets"] = CellDB["general"]["showPets"]
            CellDB["general"]["showPets"] = nil
        end
    end

    -- r22-release
    if not(CellDB["revise"]) or dbRevision < 22 then
        -- highlight color
        if not CellDB["appearance"]["targetColor"] then CellDB["appearance"]["targetColor"] = {1, .19, .19, .5} end
        if not CellDB["appearance"]["mouseoverColor"] then CellDB["appearance"]["mouseoverColor"] = {1, 1, 1, .5} end
        for _, layout in pairs(CellDB["layouts"]) do
            -- columns/rows
            if type(layout["columns"]) ~= "number" then layout["columns"] = 8 end
            if type(layout["rows"]) ~= "number" then layout["rows"] = 8 end
            if type(layout["groupSpacing"]) ~= "number" then layout["groupSpacing"] = 0 end
            -- targetMarker
            -- if layout["indicators"][1] and layout["indicators"][1]["indicatorName"] ~= "targetMarker" then
            -- 	tinsert(layout["indicators"], 1, {
            -- 		["name"] = "Target Marker",
            -- 		["indicatorName"] = "targetMarker",
            -- 		["type"] = "built-in",
            -- 		["enabled"] = true,
            -- 		["position"] = {"TOP", "TOP", 0, 3},
            -- 		["size"] = {14, 14},
            -- 		["alpha"] = .77,
            -- 	})
            -- end
        end
    end

    -- r23-release
    if not(CellDB["revise"]) or dbRevision < 23 then
        for _, layout in pairs(CellDB["layouts"]) do
            -- rename targetMarker to playerRaidIcon
            if layout["indicators"][1] then
                if layout["indicators"][1]["indicatorName"] == "targetMarker" then -- r22
                    layout["indicators"][1]["name"] = "Raid Icon (player)"
                    layout["indicators"][1]["indicatorName"] = "playerRaidIcon"
                elseif layout["indicators"][1]["indicatorName"] == "aggroBar" then
                    tinsert(layout["indicators"], 1, {
                        ["name"] = "Raid Icon (player)",
                        ["indicatorName"] = "playerRaidIcon",
                        ["type"] = "built-in",
                        ["enabled"] = true,
                        ["position"] = {"TOP", "TOP", 0, 3},
                        ["size"] = {14, 14},
                        ["alpha"] = .77,
                    })
                end
            end
            if layout["indicators"][2] and layout["indicators"][2]["indicatorName"] ~= "targetRaidIcon" then
                tinsert(layout["indicators"], 2, {
                    ["name"] = "Raid Icon (target)",
                    ["indicatorName"] = "targetRaidIcon",
                    ["type"] = "built-in",
                    ["enabled"] = false,
                    ["position"] = {"TOP", "TOP", -14, 3},
                    ["size"] = {14, 14},
                    ["alpha"] = .77,
                })
            end
        end
    end
    ]]

    -- r25-release
    if not(CellDB["revise"]) or dbRevision < 25 then
        -- position for raidTools
        if #CellDB["raidTools"]["marksPosition"] == 4 then CellDB["raidTools"]["marksPosition"] = {} end
        if #CellDB["raidTools"]["buttonsPosition"] == 4 then CellDB["raidTools"]["buttonsPosition"] = {} end
        -- position & anchor for layouts
        for _, layout in pairs(CellDB["layouts"]) do
            if type(layout["position"]) ~= "table" then
                layout["position"] = {}
            end
            if type(layout["anchor"]) ~= "string" then
                layout["anchor"] = "TOPLEFT"
            end
        end
        -- reset CellDB["debuffBlacklist"]
        CellDB["debuffBlacklist"] = I:GetDefaultDebuffBlacklist()
        -- update click-castings
        -- self:SetBindingClick(true, "MOUSEWHEELUP", self, "Button6")
        -- self:SetBindingClick(true, "SHIFT-MOUSEWHEELUP", self, "Button7")
        -- self:SetBindingClick(true, "CTRL-MOUSEWHEELUP", self, "Button8")
        -- self:SetBindingClick(true, "ALT-MOUSEWHEELUP", self, "Button9")
        -- self:SetBindingClick(true, "CTRL-SHIFT-MOUSEWHEELUP", self, "Button10")
        -- self:SetBindingClick(true, "ALT-SHIFT-MOUSEWHEELUP", self, "Button11")
        -- self:SetBindingClick(true, "ALT-CTRL-MOUSEWHEELUP", self, "Button12")
        -- self:SetBindingClick(true, "ALT-CTRL-SHIFT-MOUSEWHEELUP", self, "Button13")

        -- self:SetBindingClick(true, "MOUSEWHEELDOWN", self, "Button14")
        -- self:SetBindingClick(true, "SHIFT-MOUSEWHEELDOWN", self, "Button15")
        -- self:SetBindingClick(true, "CTRL-MOUSEWHEELDOWN", self, "Button16")
        -- self:SetBindingClick(true, "ALT-MOUSEWHEELDOWN", self, "Button17")
        -- self:SetBindingClick(true, "CTRL-SHIFT-MOUSEWHEELDOWN", self, "Button18")
        -- self:SetBindingClick(true, "ALT-SHIFT-MOUSEWHEELDOWN", self, "Button19")
        -- self:SetBindingClick(true, "ALT-CTRL-MOUSEWHEELDOWN", self, "Button20")
        -- self:SetBindingClick(true, "ALT-CTRL-SHIFT-MOUSEWHEELDOWN", self, "Button21")
        local replacements = {
            [6] = "type-SCROLLUP",
            [7] = "shift-type-SCROLLUP",
            [8] = "ctrl-type-SCROLLUP",
            [9] = "alt-type-SCROLLUP",
            [10] = "ctrl-shift-type-SCROLLUP",
            [11] = "alt-shift-type-SCROLLUP",
            [12] = "alt-ctrl-type-SCROLLUP",
            [13] = "alt-ctrl-shift-type-SCROLLUP",

            [14] = "type-SCROLLDOWN",
            [15] = "shift-type-SCROLLDOWN",
            [16] = "ctrl-type-SCROLLDOWN",
            [17] = "alt-type-SCROLLDOWN",
            [18] = "ctrl-shift-type-SCROLLDOWN",
            [19] = "alt-shift-type-SCROLLDOWN",
            [20] = "alt-ctrl-type-SCROLLDOWN",
            [21] = "alt-ctrl-shift-type-SCROLLDOWN",
        }
        for class, classTable in pairs(CellDB["clickCastings"]) do
            for spec, specTable in pairs(classTable) do
                if type(specTable) == "table" then -- not "useCommon"
                    for _, clickCastingTable in pairs(specTable) do
                        local keyID = tonumber(strmatch(clickCastingTable[1], "%d+"))
                        if keyID and keyID > 5 then
                            clickCastingTable[1] = replacements[keyID]
                        end
                    end
                end
            end
        end
    end

    -- r29-release
    if not(CellDB["revise"]) or dbRevision < 29 then
        for _, layout in pairs(CellDB["layouts"]) do
            for _, indicator in pairs(layout["indicators"]) do
                if indicator["type"] == "built-in" then
                    if indicator["indicatorName"] == "playerRaidIcon" then
                        indicator["frameLevel"] = 1
                    elseif indicator["indicatorName"] == "targetRaidIcon" then
                        indicator["frameLevel"] = 1
                    elseif indicator["indicatorName"] == "aggroBar" then
                        indicator["frameLevel"] = 1
                    elseif indicator["indicatorName"] == "externalCooldowns" then
                        indicator["frameLevel"] = 10
                    elseif indicator["indicatorName"] == "defensiveCooldowns" then
                        indicator["frameLevel"] = 10
                    elseif indicator["indicatorName"] == "tankActiveMitigation" then
                        indicator["frameLevel"] = 1
                    elseif indicator["indicatorName"] == "dispels" then
                        indicator["frameLevel"] = 15
                    elseif indicator["indicatorName"] == "debuffs" then
                        indicator["frameLevel"] = 1
                    elseif indicator["indicatorName"] == "centralDebuff" then
                        indicator["frameLevel"] = 20
                    end
                else
                    indicator["frameLevel"] = 5
                end
            end
        end
    end

    -- r33-release
    if not(CellDB["revise"]) or dbRevision < 33 then
        for _, layout in pairs(CellDB["layouts"]) do
            -- move health text
            local healthTextIndicator
            if layout["indicators"][11] and layout["indicators"][11]["indicatorName"] == "healthText" then
                healthTextIndicator = F:Copy(layout["indicators"][11])
                layout["indicators"][11] = nil
            else
                healthTextIndicator = {
                    ["name"] = "Health Text",
                    ["indicatorName"] = "healthText",
                    ["type"] = "built-in",
                    ["enabled"] = false,
                    ["position"] = {"TOP", "CENTER", 0, -5},
                    ["frameLevel"] = 1,
                    ["font"] = {"Cell ".._G.DEFAULT, 10, "Shadow", 0},
                    ["color"] = {1, 1, 1},
                    ["format"] = "percentage",
                    ["hideFull"] = true,
                }
            end

            -- add new
            if layout["indicators"][1]["indicatorName"] ~= "healthText" then
                tinsert(layout["indicators"], 1, healthTextIndicator)
                tinsert(layout["indicators"], 2, {
                    ["name"] = "Role Icon",
                    ["indicatorName"] = "roleIcon",
                    ["type"] = "built-in",
                    ["enabled"] = true,
                    ["position"] = {"TOPLEFT", "TOPLEFT", 0, 0},
                    ["size"] = {11, 11},
                })
                tinsert(layout["indicators"], 3, {
                    ["name"] = "Leader Icon",
                    ["indicatorName"] = "leaderIcon",
                    ["type"] = "built-in",
                    ["enabled"] = true,
                    ["position"] = {"TOPLEFT", "TOPLEFT", 0, -11},
                    ["size"] = {11, 11},
                })
                tinsert(layout["indicators"], 4, {
                    ["name"] = "Ready Check Icon",
                    ["indicatorName"] = "readyCheckIcon",
                    ["type"] = "built-in",
                    ["enabled"] = true,
                    ["frameLevel"] = 100,
                    ["size"] = {16, 16},
                })
                tinsert(layout["indicators"], 7, {
                    ["name"] = "Aggro Indicator",
                    ["indicatorName"] = "aggroIndicator",
                    ["type"] = "built-in",
                    ["enabled"] = true,
                    ["position"] = {"TOPLEFT", "TOPLEFT", 0, 0},
                    ["frameLevel"] = 2,
                    ["size"] = {10, 10},
                })
            end

            -- update centralDebuff border
            if layout["indicators"][15] and layout["indicators"][15]["indicatorName"] == "centralDebuff" then
                if not layout["indicators"][15]["border"] then
                    layout["indicators"][15]["border"] = 2
                end
                if layout["indicators"][15]["size"][1] == 20 then
                    layout["indicators"][15]["size"] = {22, 22}
                end
            end
        end

        if not F:TContains(CellDB["debuffBlacklist"], 160029) then
            tinsert(CellDB["debuffBlacklist"], 2, 160029)
        end

        -- glow options for raidDebuffs
        for instance, iTable in pairs(CellDB["raidDebuffs"]) do
            for boss, bTable in pairs(iTable) do
                for spell, sTable in pairs(bTable) do
                    if type(sTable[2]) ~= "boolean" then
                        tinsert(sTable, 2, false)
                    end
                    if sTable[3] and sTable[4] and type(sTable[4][1]) == "number" then
                        local color = {sTable[4][1], sTable[4][2], sTable[4][3], 1}
                        if sTable[3] == "None" or sTable[3] == "Normal" then
                            sTable[4] = {color}
                        elseif sTable[3] == "Pixel" then
                            sTable[4] = {color, 9, .25, 8, 2}
                        elseif sTable[3] == "Shine" then
                            sTable[4] = {color, 7, 0.5, 1}
                        else

                        end
                    end
                end
            end
        end

        -- options ui font size
        if not CellDB["appearance"]["optionsFontSizeOffset"] then
            CellDB["appearance"]["optionsFontSizeOffset"] = 0
        end

        -- tooltips
        if type(CellDB["general"]["disableTooltips"]) == "boolean" then
            CellDB["general"]["enableTooltips"] = not CellDB["general"]["disableTooltips"]
            CellDB["general"]["disableTooltips"] = nil
        end
    end

    CellDB["revise"] = Cell.version
end
Cell:RegisterCallback("Revise", "Revise", Revise)