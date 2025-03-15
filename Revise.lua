local addonName, Cell = ...
local L = Cell.L
local F = Cell.funcs
local I = Cell.iFuncs

function F.Revise()
    local dbRevision = CellDB["revise"] and tonumber(string.match(CellDB["revise"], "%d+")) or 0
    F.Debug("DBRevision:", dbRevision)

    local charaDbRevision
    if CellCharacterDB then
        charaDbRevision = CellCharacterDB["revise"] and tonumber(string.match(CellCharacterDB["revise"], "%d+")) or 0
        F.Debug("CharaDBRevision:", charaDbRevision)
    end

    if CellDB["revise"] and dbRevision < Cell.MIN_VERSION then -- update from an unsupported version
        local f = CreateFrame("Frame")
        f:RegisterEvent("PLAYER_ENTERING_WORLD")
        f:SetScript("OnEvent", function()
            f:UnregisterAllEvents()
            local popup = Cell.CreateConfirmPopup(CellAnchorFrame, 260, L["RESET"].."\n"..L["RESET_YES_NO"], function()
                CellDB = nil
                CellCharacterDB = nil
                ReloadUI()
            end)
            popup:SetPoint("TOPLEFT")
        end)
        return
    end

    if CellCharacterDB and CellCharacterDB["revise"] and charaDbRevision < Cell.MIN_VERSION then -- update from an unsupported version
        local f = CreateFrame("Frame")
        f:RegisterEvent("PLAYER_ENTERING_WORLD")
        f:SetScript("OnEvent", function()
            f:UnregisterAllEvents()
            local popup = Cell.CreateConfirmPopup(CellAnchorFrame, 260, L["RESET_CHARACTER"].."\n|cFFB7B7B7"..L["RESET_INCLUDES"].."|r\n"..L["RESET_YES_NO"], function()
                CellCharacterDB = nil
                ReloadUI()
            end)
            popup:SetPoint("TOPLEFT")
        end)
        return
    end

    --[=[
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
                layout["textWidth"] = 0.75
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
        if not CellDB["appearance"]["targetColor"] then CellDB["appearance"]["targetColor"] = {1, 0.19, 0.19, 0.5} end
        if not CellDB["appearance"]["mouseoverColor"] then CellDB["appearance"]["mouseoverColor"] = {1, 1, 1, 0.5} end
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
            -- 		["alpha"] = 0.77,
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
                        ["alpha"] = 0.77,
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
                    ["alpha"] = 0.77,
                })
            end
        end
    end

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
        CellDB["debuffBlacklist"] = I.GetDefaultDebuffBlacklist()
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
    if CellDB["revise"] and dbRevision < 33 then
        for _, layout in pairs(CellDB["layouts"]) do
            -- move health text
            local healthTextIndicator
            if layout["indicators"][11] and layout["indicators"][11]["indicatorName"] == "healthText" then
                healthTextIndicator = F.Copy(layout["indicators"][11])
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
                    if layout["indicators"][15]["size"][1] == 20 then
                        layout["indicators"][15]["size"] = {22, 22}
                    end
                end
                if type(layout["indicators"][15]["onlyShowTopGlow"]) ~= "boolean" then
                    layout["indicators"][15]["onlyShowTopGlow"] = true
                end
            end
        end

        if not F.TContains(CellDB["debuffBlacklist"], 160029) then
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
                            sTable[4] = {color, 9, 0.25, 8, 2}
                        elseif sTable[3] == "Shine" then
                            sTable[4] = {color, 9, 0.5, 1}
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

    -- r36-release
    if CellDB["revise"] and dbRevision < 36 then
        for _, layout in pairs(CellDB["layouts"]) do
            -- rename Central Debuff
            if layout["indicators"][15] and layout["indicators"][15]["indicatorName"] == "centralDebuff" then
                layout["indicators"][15]["indicatorName"] = "raidDebuffs"
                layout["indicators"][15]["name"] = "Raid Debuffs"
            end

            -- add Name Text
            if layout["indicators"][1]["indicatorName"] ~= "nameText" then
                tinsert(layout["indicators"], 1, {
                    ["name"] = "Name Text",
                    ["indicatorName"] = "nameText",
                    ["type"] = "built-in",
                    ["enabled"] = true,
                    ["position"] = {"CENTER", "CENTER", 0, 0},
                    ["font"] = {"Cell ".._G.DEFAULT, 13, "Shadow"},
                    ["nameColor"] = {"Custom Color", {1, 1, 1}},
                    ["vehicleNamePosition"] = {"TOP", 0},
                    ["textWidth"] = 0.75,
                })
            end

            -- add Status Text
            if layout["indicators"][2]["indicatorName"] ~= "statusText" then
                tinsert(layout["indicators"], 2, {
                    ["name"] = "Status Text",
                    ["indicatorName"] = "statusText",
                    ["type"] = "built-in",
                    ["enabled"] = true,
                    ["position"] = {"BOTTOM", 0},
                    ["frameLevel"] = 30,
                    ["font"] = {"Cell ".._G.DEFAULT, 11, "Shadow"},
                })
            end

            -- add Shiled Bar
            if layout["indicators"][11]["indicatorName"] ~= "shieldBar" then
                tinsert(layout["indicators"], 11, {
                    ["name"] = "Shield Bar",
                    ["indicatorName"] = "shieldBar",
                    ["type"] = "built-in",
                    ["enabled"] = false,
                    ["position"] = {"BOTTOMLEFT", "BOTTOMLEFT", 0, 0},
                    ["frameLevel"] = 1,
                    ["height"] = 4,
                    ["color"] = {1, 1, 0, 1},
                })
            end
        end
    end

    -- r37-release
    if CellDB["revise"] and dbRevision < 37 then
        for _, layout in pairs(CellDB["layouts"]) do
            -- useCustomTexture
            if layout["indicators"][4] and layout["indicators"][4]["indicatorName"] == "roleIcon" then
                if type(layout["indicators"][4]["customTextures"]) ~= "table" then
                    layout["indicators"][4]["customTextures"] = {false, "Interface\\AddOns\\ElvUI\\Media\\Textures\\Tank.tga", "Interface\\AddOns\\ElvUI\\Media\\Textures\\Healer.tga", "Interface\\AddOns\\ElvUI\\Media\\Textures\\DPS.tga"}
                end
            end
        end
    end

    -- r38-release
    if CellDB["revise"] and dbRevision < 38 then
        if CellDB["raidTools"]["pullTimer"][1] == "ERT" then
            CellDB["raidTools"]["pullTimer"][1] = "ExRT"
        end

        for _, layout in pairs(CellDB["layouts"]) do
            if not layout["indicators"][19] or layout["indicators"][19]["indicatorName"] ~= "targetedSpells" then
                tinsert(layout["indicators"], 19, {
                    ["name"] = "Targeted Spells",
                    ["indicatorName"] = "targetedSpells",
                    ["type"] = "built-in",
                    ["enabled"] = false,
                    ["position"] = {"CENTER", "TOPLEFT", 7, -7},
                    ["frameLevel"] = 50,
                    ["size"] = {20, 20},
                    ["border"] = 2,
                    ["spells"] = {},
                    ["glow"] = {"Pixel", {0.95,0.95,0.32,1}, 9, 0.25, 8, 2},
                    ["font"] = {"Cell ".._G.DEFAULT, 12, "Outline", 2},
                })
            end
        end
    end

    -- r41-release
    if CellDB["revise"] and dbRevision < 41 then
        for _, layout in pairs(CellDB["layouts"]) do
            if layout["indicators"][19] and layout["indicators"][19]["indicatorName"] == "targetedSpells" then
                if #layout["indicators"][19]["spells"] == 0 then
                    layout["indicators"][19]["enabled"] = true
                    layout["indicators"][19]["spells"] = {320788, 344496, 319941}
                end
            end
        end
    end

    -- r44-release
    if CellDB["revise"] and dbRevision < 44 then
        for _, layout in pairs(CellDB["layouts"]) do
            if layout["indicators"][19] and layout["indicators"][19]["indicatorName"] == "targetedSpells" then
                if not F.TContains(layout["indicators"][19]["spells"], 320132) then -- 暗影之怒
                    tinsert(layout["indicators"][19]["spells"], 320132)
                end
                if not F.TContains(layout["indicators"][19]["spells"], 322614) then -- 心灵连接
                    tinsert(layout["indicators"][19]["spells"], 322614)
                end
            end
        end
    end

    -- r46-release
    if CellDB["revise"] and dbRevision < 46 then
        for _, layout in pairs(CellDB["layouts"]) do
            if layout["indicators"][13] and layout["indicators"][13]["indicatorName"] == "externalCooldowns" then
                layout["indicators"][13]["orientation"] = "right-to-left"
            end
            if layout["indicators"][14] and layout["indicators"][14]["indicatorName"] == "defensiveCooldowns" then
                layout["indicators"][14]["orientation"] = "left-to-right"
            end
            if layout["indicators"][17] and layout["indicators"][17]["indicatorName"] == "debuffs" then
                layout["indicators"][17]["orientation"] = "left-to-right"
            end
        end

        CellDB["general"]["tooltipsPosition"] = {"BOTTOMLEFT", "Unit Button", "TOPLEFT", 0, 15}
    end

    -- r47-release
    if CellDB["revise"] and dbRevision < 47 then
        for _, layout in pairs(CellDB["layouts"]) do
            if layout["indicators"][19] and layout["indicators"][19]["indicatorName"] == "targetedSpells" then
                if not F.TContains(layout["indicators"][19]["spells"], 334053) then -- 净化冲击波
                    tinsert(layout["indicators"][19]["spells"], 334053)
                end
            end
        end

        if type(CellDB["appearance"]["highlightSize"]) ~= "number" then
            CellDB["appearance"]["highlightSize"] = 1
        end
        if type(CellDB["appearance"]["outOfRangeAlpha"]) ~= "number" then
            CellDB["appearance"]["outOfRangeAlpha"] = 0.45
        end
    end

    -- r48-release
    if CellDB["revise"] and dbRevision < 48 then
        for _, layout in pairs(CellDB["layouts"]) do
            if layout["indicators"][19] and layout["indicators"][19]["indicatorName"] == "targetedSpells" then
                if not F.TContains(layout["indicators"][19]["spells"], 343556) then -- 病态凝视
                    tinsert(layout["indicators"][19]["spells"], 343556)
                end
                if not F.TContains(layout["indicators"][19]["spells"], 320596) then -- 深重呕吐
                    tinsert(layout["indicators"][19]["spells"], 320596)
                end
            end
        end
    end

    -- r49-release
    if CellDB["revise"] and dbRevision < 49 then
        if type(CellDB["appearance"]["barAnimation"]) ~= "string" then
            CellDB["appearance"]["barAnimation"] = "Flash"
        end
    end

    -- r50-release
    if CellDB["revise"] and dbRevision < 50 then
        for _, layout in pairs(CellDB["layouts"]) do
            -- add statusIcon
            if layout["indicators"][4] and layout["indicators"][4]["indicatorName"] ~= "statusIcon" then
                tinsert(layout["indicators"], 4, {
                    ["name"] = "Status Icon",
                    ["indicatorName"] = "statusIcon",
                    ["type"] = "built-in",
                    ["enabled"] = true,
                    ["position"] = {"TOP", "TOP", 0, -3},
                    ["frameLevel"] = 10,
                    ["size"] = {18, 18},
                })
            end

            -- update debuffs
            if layout["indicators"][18] and layout["indicators"][18]["indicatorName"] == "debuffs" then
                if type(layout["indicators"][18]["bigDebuffs"]) ~= "table" then
                    layout["indicators"][18]["bigDebuffs"] = {
                        209858, -- 死疽溃烂
                        46392, -- 专注打击
                    }
                    layout["indicators"][18]["size"] = {layout["indicators"][18]["size"], {17, 17}} -- normalSize, bigSize
                end
            end

            -- add targetCounter
            if (not layout["indicators"][21]) or (layout["indicators"][21] and layout["indicators"][21]["indicatorName"] ~= "targetCounter") then
                tinsert(layout["indicators"], 21, {
                    ["name"] = "Target Counter",
                    ["indicatorName"] = "targetCounter",
                    ["type"] = "built-in",
                    ["enabled"] = false,
                    ["position"] = {"TOP", "TOP", 0, 5},
                    ["frameLevel"] = 15,
                    ["font"] = {"Cell ".._G.DEFAULT, 15, "Outline", 0},
                    ["color"] = {1, 0.1, 0.1},
                })
            end
        end
    end

    -- r55-release
    if CellDB["revise"] and dbRevision < 55 then
        for _, layout in pairs(CellDB["layouts"]) do
            -- update debuffs
            if layout["indicators"][18] and layout["indicators"][18]["indicatorName"] == "debuffs" then
                --- 焚化者阿寇拉斯
                if not F.TContains(layout["indicators"][18]["bigDebuffs"], 355732) then
                    tinsert(layout["indicators"][18]["bigDebuffs"], 355732) -- 融化灵魂
                end
                if not F.TContains(layout["indicators"][18]["bigDebuffs"], 355738) then
                    tinsert(layout["indicators"][18]["bigDebuffs"], 355738) -- 灼热爆破
                end
                -- 凇心之欧罗斯
                if not F.TContains(layout["indicators"][18]["bigDebuffs"], 356667) then
                    tinsert(layout["indicators"][18]["bigDebuffs"], 356667) -- 刺骨之寒
                end
                -- 刽子手瓦卢斯
                if not F.TContains(layout["indicators"][18]["bigDebuffs"], 356925) then
                    tinsert(layout["indicators"][18]["bigDebuffs"], 356925) -- 屠戮
                end
                if not F.TContains(layout["indicators"][18]["bigDebuffs"], 356923) then
                    tinsert(layout["indicators"][18]["bigDebuffs"], 356923) -- 撕裂
                end
                if not F.TContains(layout["indicators"][18]["bigDebuffs"], 358973) then
                    tinsert(layout["indicators"][18]["bigDebuffs"], 358973) -- 恐惧浪潮
                end
                -- 粉碎者索苟冬
                if not F.TContains(layout["indicators"][18]["bigDebuffs"], 355806) then
                    tinsert(layout["indicators"][18]["bigDebuffs"], 355806) -- 重压
                end
                if not F.TContains(layout["indicators"][18]["bigDebuffs"], 358777) then
                    tinsert(layout["indicators"][18]["bigDebuffs"], 358777) -- 痛苦之链
                end
            end
        end
    end

    -- r56-release
    if CellDB["revise"] and dbRevision < 56 then
        for _, layout in pairs(CellDB["layouts"]) do
            if layout["indicators"][20] and layout["indicators"][20]["indicatorName"] == "targetedSpells" then
                if not F.TContains(layout["indicators"][20]["spells"], 356924) then
                    tinsert(layout["indicators"][20]["spells"], 356924)  -- 屠戮
                end
                if not F.TContains(layout["indicators"][20]["spells"], 356666) then -- 刺骨之寒
                    tinsert(layout["indicators"][20]["spells"], 356666)
                end
                if not F.TContains(layout["indicators"][20]["spells"], 319713) then -- 巨兽奔袭
                    tinsert(layout["indicators"][20]["spells"], 319713)
                end
            end
            if layout["indicators"][18] and layout["indicators"][18]["indicatorName"] == "debuffs" then
                if not F.TContains(layout["indicators"][18]["bigDebuffs"], 240559) then
                    tinsert(layout["indicators"][18]["bigDebuffs"], 240559)  -- 重伤
                end
            end
        end
    end

    -- r57-release
    if CellDB["revise"] and dbRevision < 57 then
        if type(CellDB["raidTools"]["deathReport"]) ~= "table" then
            CellDB["raidTools"]["deathReport"] = {false, 10}
        end
        if type(CellDB["raidTools"]["showBuffTracker"]) ~= "boolean" then
            CellDB["raidTools"]["showBuffTracker"] = false
        end
        if type(CellDB["raidTools"]["buffTrackerPosition"]) ~= "table" then
            CellDB["raidTools"]["buffTrackerPosition"] = {}
        end
    end

    -- r60-release
    if CellDB["revise"] and dbRevision < 60 then
        for _, layout in pairs(CellDB["layouts"]) do
            if layout["indicators"][20] and layout["indicators"][20]["indicatorName"] == "targetedSpells" then
                if not F.TContains(layout["indicators"][20]["spells"], 338606) then
                    tinsert(layout["indicators"][20]["spells"], 338606) -- 病态凝视
                end
                if not F.TContains(layout["indicators"][20]["spells"], 343556) then
                    tinsert(layout["indicators"][20]["spells"], 343556) -- 病态凝视
                end
            end
            if type(layout["petSize"]) ~= "table" then
                layout["petSize"] = {false, 66, 46}
            end
        end
    end

    -- r61-release
    if CellDB["revise"] and dbRevision < 61 then
        for _, layout in pairs(CellDB["layouts"]) do
            -- rename aggroIndicator
            if layout["indicators"][10] and layout["indicators"][10]["indicatorName"] == "aggroIndicator" then
                layout["indicators"][10]["name"] = "Aggro (blink)"
                layout["indicators"][10]["indicatorName"] = "aggroBlink"
            end
            -- rename aggroBar
            if layout["indicators"][11] and layout["indicators"][11]["indicatorName"] == "aggroBar" then
                layout["indicators"][11]["name"] = "Aggro (bar)"
            end
            -- add aggroBorder
            if layout["indicators"][12] and layout["indicators"][12]["indicatorName"] ~= "aggroBorder" then
                tinsert(layout["indicators"], 12, {
                    ["name"] = "Aggro (border)",
                    ["indicatorName"] = "aggroBorder",
                    ["type"] = "built-in",
                    ["enabled"] = false,
                    ["frameLevel"] = 1,
                    ["thickness"] = 3,
                })
            end
            -- update frameLevel
            for _, indicator in pairs(layout["indicators"]) do
                if indicator["indicatorName"] == "healthText" then
                    indicator["frameLevel"] = 2
                elseif indicator["indicatorName"] == "playerRaidIcon" then
                    indicator["frameLevel"] = 2
                elseif indicator["indicatorName"] == "targetRaidIcon" then
                    indicator["frameLevel"] = 2
                elseif indicator["indicatorName"] == "aggroBlink" then
                    indicator["frameLevel"] = 3
                elseif indicator["indicatorName"] == "shieldBar" then
                    indicator["frameLevel"] = 2
                elseif indicator["indicatorName"] == "tankActiveMitigation" then
                    indicator["frameLevel"] = 2
                elseif indicator["indicatorName"] == "debuffs" then
                    indicator["frameLevel"] = 2
                end
            end
        end
    end

    -- r63-release
    if CellDB["revise"] and dbRevision < 63 then
        -- 起伏机动
        if not F.TContains(CellDB["debuffBlacklist"], 352562) then
            tinsert(CellDB["debuffBlacklist"], 352562)
            Cell.vars.debuffBlacklist = F.ConvertTable(CellDB["debuffBlacklist"])
        end
    end

    -- r64-release
    if CellDB["revise"] and dbRevision < 64 then
        for _, layout in pairs(CellDB["layouts"]) do
            if layout["indicators"][21] and layout["indicators"][21]["indicatorName"] == "targetedSpells" then
                if not F.TContains(layout["indicators"][21]["spells"], 324079) then
                    tinsert(layout["indicators"][21]["spells"], 324079) -- 收割之镰
                end
                if not F.TContains(layout["indicators"][21]["spells"], 317963) then
                    tinsert(layout["indicators"][21]["spells"], 317963) -- 知识烦扰
                end
            end
            if layout["indicators"][19] and layout["indicators"][19]["indicatorName"] == "debuffs" then
                if not F.TContains(layout["indicators"][19]["bigDebuffs"], 240443) then
                    tinsert(layout["indicators"][19]["bigDebuffs"], 240443) -- 爆裂
                end
                if F.TContains(layout["indicators"][19]["bigDebuffs"], 243237) then
                    F.TRemove(layout["indicators"][19]["bigDebuffs"], 243237)
                end
            end
        end
        -- 审判灵魂
        if not F.TContains(CellDB["debuffBlacklist"], 356419) then
            tinsert(CellDB["debuffBlacklist"], 356419)
            Cell.vars.debuffBlacklist = F.ConvertTable(CellDB["debuffBlacklist"])
        end
    end

    -- r65-release
    if CellDB["revise"] and dbRevision < 65 then
        for _, layout in pairs(CellDB["layouts"]) do
            if layout["indicators"][21] and layout["indicators"][21]["indicatorName"] == "targetedSpells" then
                if not F.TContains(layout["indicators"][21]["spells"], 333861) then
                    tinsert(layout["indicators"][21]["spells"], 333861) -- 回旋利刃
                end
            end
        end
    end

    -- r66-release
    if CellDB["revise"] and dbRevision < 66 then
        -- always targeting
        if not CellDB["clickCastings"][Cell.vars.playerClass]["alwaysTargeting"] then
            CellDB["clickCastings"][Cell.vars.playerClass]["alwaysTargeting"] = {
                ["common"] = "disabled",
            }
            for sepcIndex = 1, GetNumSpecializationsForClassID(Cell.vars.playerClassID) do
                local specID = GetSpecializationInfoForClassID(Cell.vars.playerClassID, sepcIndex)
                CellDB["clickCastings"][Cell.vars.playerClass]["alwaysTargeting"][specID] = "disabled"
            end
        end
    end

    -- r68-release
    if CellDB["revise"] and dbRevision < 68 then
        if type(CellDB["appearance"]["iconAnimation"]) ~= "string" then
            CellDB["appearance"]["iconAnimation"] = "duration"
        end
    end

    -- r69-release
    if CellDB["revise"] and dbRevision < 69 then
        for _, layout in pairs(CellDB["layouts"]) do
            if layout["indicators"][20] and layout["indicators"][20]["indicatorName"] == "raidDebuffs" then
                layout["indicators"][20]["num"] = 1
                layout["indicators"][20]["orientation"] = "left-to-right"
            end
        end

        if type(CellDB["appearance"]["bgAlpha"]) ~= "number" then
            CellDB["appearance"]["bgAlpha"] = 1
        end
    end

    -- r70-release
    if CellDB["revise"] and dbRevision < 70 then
        for _, layout in pairs(CellDB["layouts"]) do
            -- check custom indicator
            for i = 23, #layout["indicators"] do
                if layout["indicators"][i]["type"] == "text" then
                    layout["indicators"][i]["showDuration"] = true
                end
            end
        end

        if type(CellDB["appearance"]["barAlpha"]) ~= "number" then
            CellDB["appearance"]["barAlpha"] = 1
        end

        if type(CellDB["appearance"]["lossAlpha"]) ~= "number" then
            CellDB["appearance"]["lossAlpha"] = 1
        end

        if type(CellDB["appearance"]["lossColor"]) ~= "table" then
            CellDB["appearance"]["lossColor"] = CellDB["appearance"]["bgColor"]
            CellDB["appearance"]["bgColor"] = nil
        end

        if type(CellDB["appearance"]["healPrediction"]) ~= "boolean" then
            CellDB["appearance"]["healPrediction"] = true
        end
        if type(CellDB["appearance"]["healAbsorb"]) ~= "boolean" then
            CellDB["appearance"]["healAbsorb"] = true
        end
        if type(CellDB["appearance"]["shield"]) ~= "boolean" then
            CellDB["appearance"]["shield"] = true
        end
        if type(CellDB["appearance"]["overshield"]) ~= "boolean" then
            CellDB["appearance"]["overshield"] = true
        end
    end

    -- r71-release
    if CellDB["revise"] and dbRevision < 71 then
        for _, layout in pairs(CellDB["layouts"]) do
            if layout["indicators"][2] and layout["indicators"][2]["indicatorName"] == "statusText" and not layout["indicators"][2]["colors"] then
                layout["indicators"][2]["colors"] = {
                    ["GHOST"] = {1, 0.19, 0.19},
                    ["DEAD"] = {1, 0.19, 0.19},
                    ["AFK"] = {1, 0.19, 0.19},
                    ["OFFLINE"] = {1, 0.19, 0.19},
                    ["FEIGN"] = {1, 1, 0.12},
                    ["DRINKING"] = {0.12, 0.75, 1},
                    ["PENDING"] = {1, 1, 0.12},
                    ["ACCEPTED"] = {0.12, 1, 0.12},
                    ["DECLINED"] = {1, 0.19, 0.19},
                }
            end

            if not layout["powerFilters"] then
                layout["powerFilters"] = {
                    ["DEATHKNIGHT"] = {["TANK"] = true, ["DAMAGER"] = true},
                    ["DEMONHUNTER"] = {["TANK"] = true, ["DAMAGER"] = true},
                    ["DRUID"] = {["TANK"] = true, ["DAMAGER"] = true, ["HEALER"] = true},
                    ["HUNTER"] = true,
                    ["MAGE"] = true,
                    ["MONK"] = {["TANK"] = true, ["DAMAGER"] = true, ["HEALER"] = true},
                    ["PALADIN"] = {["TANK"] = true, ["DAMAGER"] = true, ["HEALER"] = true},
                    ["PRIEST"] = {["DAMAGER"] = true, ["HEALER"] = true},
                    ["ROGUE"] = true,
                    ["SHAMAN"] = {["DAMAGER"] = true, ["HEALER"] = true},
                    ["WARLOCK"] = true,
                    ["WARRIOR"] = {["TANK"] = true, ["DAMAGER"] = true},
                    ["PET"] = true,
                    ["VEHICLE"] = true,
                    ["NPC"] = true,
                }
            end
        end
    end

    -- r74-release
    if CellDB["revise"] and dbRevision < 74 then
        --! add "Condition"
        for instance, iTable in pairs(CellDB["raidDebuffs"]) do
            for boss, bTable in pairs(iTable) do
                for spell, sTable in pairs(bTable) do
                    if type(sTable[3]) ~= "table" then
                        tinsert(sTable, 3, {"None"})
                    end
                end
            end
        end
    end

    -- r77-release
    if CellDB["revise"] and dbRevision < 77 then
        if type(CellDB["appearance"]["useGameFont"]) ~= "boolean" then
            CellDB["appearance"]["useGameFont"] = true
        end
    end

    -- r79-release
    if CellDB["revise"] and dbRevision < 79 then
        -- update name text width
        for _, layout in pairs(CellDB["layouts"]) do
            if layout["indicators"][1] and layout["indicators"][1]["indicatorName"] == "nameText" then
                if type(layout["indicators"][1]["textWidth"]) == "number" then
                    local oldWidth = layout["indicators"][1]["textWidth"]
                    if oldWidth == 0 then -- unlimited
                        layout["indicators"][1]["textWidth"] = "unlimited"
                    else
                        layout["indicators"][1]["textWidth"] = {"percentage", oldWidth}
                    end
                end
            end
        end
    end

    -- r80-release
    if CellDB["revise"] and dbRevision < 80 then
        -- update name text width
        for _, layout in pairs(CellDB["layouts"]) do
            if type(layout["npcAnchor"]) ~= "table" then
                layout["npcAnchor"] = {false, {}}
            end
        end
    end

    -- r81-release
    if CellDB["revise"] and dbRevision < 81 then
        -- update marks
        if type(CellDB["raidTools"]["marks"]) ~= "table" then
            local oldShowMarks = CellDB["raidTools"]["showMarks"]
            local oldMarks = CellDB["raidTools"]["marks"]
            CellDB["raidTools"]["marks"] = {oldShowMarks, oldMarks.."_h", CellDB["raidTools"]["marksPosition"]}
            -- remove old
            CellDB["raidTools"]["showMarks"] = nil
            CellDB["raidTools"]["marksPosition"] = nil
        end

        -- update buffTracker
        if type(CellDB["raidTools"]["buffTracker"]) ~= "table" then
            CellDB["raidTools"]["buffTracker"] = {CellDB["raidTools"]["showBuffTracker"], CellDB["raidTools"]["buffTrackerPosition"]}
            -- remove old
            CellDB["raidTools"]["showBuffTracker"] = nil
            CellDB["raidTools"]["buffTrackerPosition"] = nil
        end

        -- update readyAndPull
        if type(CellDB["raidTools"]["readyAndPull"]) ~= "table" then
            CellDB["raidTools"]["readyAndPull"] = {CellDB["raidTools"]["showButtons"], CellDB["raidTools"]["pullTimer"], CellDB["raidTools"]["buttonsPosition"]}
            -- remove old
            CellDB["raidTools"]["showButtons"] = nil
            CellDB["raidTools"]["pullTimer"] = nil
            CellDB["raidTools"]["buttonsPosition"] = nil
        end
    end

    -- r82-release
    if CellDB["revise"] and dbRevision < 82 then
        for _, layout in pairs(CellDB["layouts"]) do
            if layout["indicators"][19] and layout["indicators"][19]["indicatorName"] == "debuffs" then
                if not F.TContains(layout["indicators"][19]["bigDebuffs"], 366297) then
                    tinsert(layout["indicators"][19]["bigDebuffs"], 366297) -- 解构
                end
                if not F.TContains(layout["indicators"][19]["bigDebuffs"], 366288) then
                    tinsert(layout["indicators"][19]["bigDebuffs"], 366288) -- 猛力砸击
                end
            end
        end
    end

    -- r87-release
    if CellDB["revise"] and dbRevision < 87 then
        -- rename raid tools
        if CellDB["raidTools"] then
            -- update readyAndPull
            if CellDB["raidTools"]["readyAndPull"] and type(CellDB["raidTools"]["readyAndPull"][2]) == "table" then
                if CellDB["raidTools"]["readyAndPull"][2][1] == "ExRT" then
                    CellDB["raidTools"]["readyAndPull"][2][1] = "mrt"
                elseif CellDB["raidTools"]["readyAndPull"][2][1] == "DBM" then
                    CellDB["raidTools"]["readyAndPull"][2][1] = "dbm"
                elseif CellDB["raidTools"]["readyAndPull"][2][1] == "BW" then
                    CellDB["raidTools"]["readyAndPull"][2][1] = "bw"
                end
            end

            CellDB["tools"] = CellDB["raidTools"]
            CellDB["raidTools"] = nil
        end

        for _, layout in pairs(CellDB["layouts"]) do
            -- add barOrientation to layout
            if type(layout["barOrientation"]) ~= "table" then
                layout["barOrientation"] = {"horizontal", false}
            end
            -- rename powerHeight to powerSize
            if type(layout["powerSize"]) ~= "number" then
                layout["powerSize"] = layout["powerHeight"]
                layout["powerHeight"] = nil
            end
            -- rname npcAnchor to friendlyNPC
            if type(layout["npc"]) ~= "table" then
                layout["npc"] = {true, layout["npcAnchor"][1], layout["npcAnchor"][2]}
                layout["npcAnchor"] = nil
            end
            -- add showDuration to external
            if layout["indicators"][15] and layout["indicators"][15]["indicatorName"] == "externalCooldowns" then
                layout["indicators"][15]["showDuration"] = false
                layout["indicators"][15]["font"] = {"Cell ".._G.DEFAULT, 11, "Outline", 2}
            end
            -- add showDuration to defensive
            if layout["indicators"][16] and layout["indicators"][16]["indicatorName"] == "defensiveCooldowns" then
                layout["indicators"][16]["showDuration"] = false
                layout["indicators"][16]["font"] = {"Cell ".._G.DEFAULT, 11, "Outline", 2}
            end
            -- add showDuration to debuffs
            if layout["indicators"][19] and layout["indicators"][19]["indicatorName"] == "debuffs" then
                layout["indicators"][19]["showDuration"] = false
            end
        end
    end

    -- r90-release
    if CellDB["revise"] and dbRevision < 90 then
        -- separate glows from tools
        CellDB["tools"]["spellRequest"] = nil
        CellDB["tools"]["dispelRequest"] = nil

        -- add menuPosition
        if not CellDB["general"]["menuPosition"] then
            CellDB["general"]["menuPosition"] = "top_bottom"
        end

        -- update health color
        if CellDB["appearance"]["barColor"][1] == "Class Color" then
            CellDB["appearance"]["barColor"][1] = "class_color"
        elseif CellDB["appearance"]["barColor"][1] == "Class Color (dark)" then
            CellDB["appearance"]["barColor"][1] = "class_color_dark"
        elseif CellDB["appearance"]["barColor"][1] == "Gradient" then
            CellDB["appearance"]["barColor"][1] = "gradient"
        elseif CellDB["appearance"]["barColor"][1] == "Custom Color" then
            CellDB["appearance"]["barColor"][1] = "custom"
        end

        -- update loss color
        if CellDB["appearance"]["lossColor"][1] == "Class Color" then
            CellDB["appearance"]["lossColor"][1] = "class_color"
        elseif CellDB["appearance"]["lossColor"][1] == "Class Color (dark)" then
            CellDB["appearance"]["lossColor"][1] = "class_color_dark"
        elseif CellDB["appearance"]["lossColor"][1] == "Gradient" then
            CellDB["appearance"]["lossColor"][1] = "gradient"
        elseif CellDB["appearance"]["lossColor"][1] == "Custom Color" then
            CellDB["appearance"]["lossColor"][1] = "custom"
        end

        -- update power color
        if CellDB["appearance"]["powerColor"][1] == "Power Color" then
            CellDB["appearance"]["powerColor"][1] = "power_color"
        elseif CellDB["appearance"]["powerColor"][1] == "Power Color (dark)" then
            CellDB["appearance"]["powerColor"][1] = "power_color_dark"
        elseif CellDB["appearance"]["powerColor"][1] == "Class Color" then
            CellDB["appearance"]["powerColor"][1] = "class_color"
        elseif CellDB["appearance"]["powerColor"][1] == "Custom Color" then
            CellDB["appearance"]["powerColor"][1] = "custom"
        end
    end

    -- r91-release
    if CellDB["revise"] and dbRevision < 91 then
        -- update spellRequest dataStructure
        if CellDB["glows"]["spellRequest"] and #CellDB["glows"]["spellRequest"] == 8 then
            local srIndices = {"enabled", "checkIfExists", "knownSpellsOnly", "freeCooldownOnly", "replyCooldown", "responseType", "timeout", "spells"}
            local spellIndices = {"spellId", "buffId", "keywords", "glowOptions", "isBuiltIn"}
            local newSR = {}
            for i, v in pairs(CellDB["glows"]["spellRequest"]) do
                if i == 8 then -- spells
                    newSR["spells"] = {}
                    for j, st in pairs(v) do
                        newSR["spells"][j] = {}
                        for k, sv in pairs(st) do
                            newSR["spells"][j][spellIndices[k]] = sv
                        end
                    end
                else
                    newSR[srIndices[i]] = v
                end
            end
            CellDB["glows"]["spellRequest"] = newSR
        end

        -- update dispelRequest dataStructure
        if CellDB["glows"]["dispelRequest"] and #CellDB["glows"]["dispelRequest"] == 6 then
            local drIndices = {"enabled", "dispellableByMe", "responseType", "timeout", "debuffs", "glowOptions"}
            local newDR = {}
            for i, v in pairs(CellDB["glows"]["dispelRequest"]) do
                newDR[drIndices[i]] = v
            end
            CellDB["glows"]["dispelRequest"] = newDR
        end
    end

    -- r93-release
    if CellDB["revise"] and dbRevision < 93 then
        -- add layout auto switch for Mythic
        for role, t in pairs(CellDB["layoutAutoSwitch"]) do
            if not t["mythic"] then
                t["mythic"] = "default"
            end
        end

        -- add allCooldowns
        for _, layout in pairs(CellDB["layouts"]) do
            if layout["indicators"][17] and layout["indicators"][17]["indicatorName"] ~= "allCooldowns" then
                tinsert(layout["indicators"], 17, {
                    ["name"] = "Externals + Defensives",
                    ["indicatorName"] = "allCooldowns",
                    ["type"] = "built-in",
                    ["enabled"] = false,
                    ["position"] = {"LEFT", "LEFT", -2, 5},
                    ["frameLevel"] = 10,
                    ["size"] = {12, 20},
                    ["showDuration"] = false,
                    ["num"] = 2,
                    ["orientation"] = "left-to-right",
                    ["font"] = {"Cell ".._G.DEFAULT, 11, "Outline", 2},
                })
            end
        end
    end

    -- r94-release
    if CellDB["revise"] and dbRevision < 94 then
        -- add auraIconOptions
        if not CellDB["appearance"]["auraIconOptions"] then
            CellDB["appearance"]["auraIconOptions"] = {
                ["animation"] = CellDB["appearance"]["iconAnimation"],
                ["durationColorEnabled"] = false,
                ["durationColors"] = {{0,1,0}, {1,1,0,0.5}, {1,0,0,3}},
                ["durationDecimal"] = 0,
            }

            CellDB["appearance"]["iconAnimation"] = nil
        end

        -- add y offset
        local modifications = {
            [15] = "externalCooldowns",
            [16] = "defensiveCooldowns",
            [17] = "allCooldowns",
            [20] = "debuffs",
            [21] = "raidDebuffs",
            [22] = "targetedSpells"
        }

        for _, layout in pairs(CellDB["layouts"]) do
            for i, t in pairs(layout["indicators"]) do
                if i <= Cell.defaults.builtIns then -- built-ins
                    if t["indicatorName"] == modifications[i] and not t["font"][5] then
                        t["font"][5] = 1
                    end
                elseif t["type"] == "icon" or t["type"] == "icons" then -- custom icon/icons
                    if not t["font"][5] then
                        t["font"][5] = 1
                    end
                end
            end
        end
    end

    -- r95-release
    if CellDB["revise"] and dbRevision < 95 then
        -- add round up
        if type(CellDB["appearance"]["auraIconOptions"]["durationRoundUp"]) ~= "boolean" then
            CellDB["appearance"]["auraIconOptions"]["durationRoundUp"] = false
        end

        -- change showDuration to duration for custom TEXT indicators
        for _, layout in pairs(CellDB["layouts"]) do
            for i, t in pairs(layout["indicators"]) do
                if t["type"] == "text" then
                    if type(t["duration"]) ~= "table" then
                        -- add new
                        t["duration"] = {
                            t["showDuration"], -- show duration
                            false, -- round up duration
                            0, -- decimal
                        }
                        -- remove old
                        t["showDuration"] = nil
                    end
                end
            end
        end
    end

    -- r96-release
    if CellDB["revise"] and dbRevision < 96 then
        for _, layout in pairs(CellDB["layouts"]) do
            if layout["indicators"][22] and layout["indicators"][22]["indicatorName"] == "targetedSpells" then
                if not F.TContains(layout["indicators"][22]["spells"], 332234) then -- 挥发精油
                    tinsert(layout["indicators"][22]["spells"], 332234)
                end
            end
        end
    end

    -- r97-release
    -- if CellDB["revise"] and dbRevision < 97 then
    --     if not CellDB["general"]["nickname"] then
    --         CellDB["general"]["nickname"] = {false}
    --     end
    -- end

    -- r98-release
    if CellDB["revise"] and dbRevision < 98 then
        -- add deathColor
        if not CellDB["appearance"]["deathColor"] then
            CellDB["appearance"]["deathColor"] = {false, {0.545, 0, 0}}
        end

        for _, layout in pairs(CellDB["layouts"]) do
            -- update frame level of aggro border
            if layout["indicators"][12] and layout["indicators"][12]["indicatorName"] == "aggroBorder" and layout["indicators"][12]["frameLevel"] == 1 then
                layout["indicators"][12]["frameLevel"] = 3
            end

            -- update roleTexture
            if layout["indicators"][5] and layout["indicators"][5]["indicatorName"] == "roleIcon" and not layout["indicators"][5]["roleTexture"] then
                layout["indicators"][5]["roleTexture"] = {}
                layout["indicators"][5]["roleTexture"][1] = layout["indicators"][5]["customTextures"][1] and "custom" or "default"
                layout["indicators"][5]["roleTexture"][2] = layout["indicators"][5]["customTextures"][2]
                layout["indicators"][5]["roleTexture"][3] = layout["indicators"][5]["customTextures"][3]
                layout["indicators"][5]["roleTexture"][4] = layout["indicators"][5]["customTextures"][4]

                layout["indicators"][5]["customTextures"] = nil
            end
        end
    end

    -- r99-release
    if CellDB["revise"] and dbRevision < 99 then
        -- remove old nickname
        CellDB["general"]["nickname"] = nil

        for _, layout in pairs(CellDB["layouts"]) do
            if layout["indicators"][1] and layout["indicators"][1]["indicatorName"] == "nameText" then
                -- add Frame Level to Name Text indicator
                if not layout["indicators"][1]["frameLevel"] then
                    layout["indicators"][1]["frameLevel"] = 1
                end
                -- update color
                if layout["indicators"][1]["nameColor"][1] == "Class Color" then
                    layout["indicators"][1]["nameColor"][1] = "class_color"
                elseif layout["indicators"][1]["nameColor"][1] == "Custom Color" then
                    layout["indicators"][1]["nameColor"][1] = "custom"
                end
            end
        end
    end

    -- r103-release
    if CellDB["revise"] and dbRevision < 103 then
        if type(CellDB["appearance"]["accentColor"]) ~= "table" then
            CellDB["appearance"]["accentColor"] = {"class_color", {1, 0.26667, 0.4}}
        end
    end

    -- r107-release
    if CellDB["revise"] and dbRevision < 107 then
        -- add season 4 debuffs
        if not F.TContains(CellDB["bigDebuffs"], 373391) then
            tinsert(CellDB["bigDebuffs"], 373391) -- 梦魇
        end
        if not F.TContains(CellDB["bigDebuffs"], 373429) then
            tinsert(CellDB["bigDebuffs"], 373429) -- 腐臭虫群
        end
        Cell.vars.bigDebuffs = F.ConvertTable(CellDB["bigDebuffs"])
    end

    -- r117-release
    if CellDB["revise"] and dbRevision < 117 then
        -- enable shield in WotLK
        if Cell.isCata then
            CellDB["appearance"]["shield"] = true
            CellDB["appearance"]["overshield"] = true
        end
    end

    -- r118-release
    if CellDB["revise"] and dbRevision < 118 then
        -- fix default value in Wrath Classic
        if Cell.isCata and CellDB["tools"]["marks"][2] == "both_h" then
            CellDB["tools"]["marks"][2] = "target_h"
        end

        -- add size
        if not CellDB["tools"]["buffTracker"][3] then
            if Cell.isRetail then
                CellDB["tools"]["buffTracker"][3] = 32
            else
                CellDB["tools"]["buffTracker"][3] = 27
            end
        end
    end

    -- r119-release
    if CellDB["revise"] and dbRevision < 119 then
        -- spotlight
        for _, layout in pairs(CellDB["layouts"]) do
            if not layout["spotlight"] then
                layout["spotlight"] = {false, {}, {}} -- enabled, units, position
            end
        end
    end

    -- r128-release
    if CellDB["revise"] and dbRevision < 128 then
        -- spotlight
        for _, layout in pairs(CellDB["layouts"]) do
            if layout["spotlight"] and #layout["spotlight"] ~= 5 then
                -- sizeEnabled
                layout["spotlight"][4] = false
                -- size
                layout["spotlight"][5] = {66, 46}
            end
        end
    end

    -- r129-release
    if CellDB["revise"] and dbRevision < 129 then
        if type(CellDB["general"]["hideBlizzard"]) == "boolean" then
            CellDB["general"]["hideBlizzardParty"] = CellDB["general"]["hideBlizzard"]
            CellDB["general"]["hideBlizzardRaid"] = CellDB["general"]["hideBlizzard"]
            CellDB["general"]["hideBlizzard"] = nil
        end

        if type(CellDB["appearance"]["useLibHealComm"]) ~= "boolean" then
            CellDB["appearance"]["useLibHealComm"] = false
        end
    end

    -- r132-release (merge r114 r115 r117)
    if CellDB["revise"] and dbRevision < 132 then
        local healthThresholdsIndex = Cell.defaults.indicatorIndices.healthThresholds
        local shieldBarIndex = Cell.defaults.indicatorIndices.shieldBar
        local dispelsIndex = Cell.defaults.indicatorIndices.dispels
        local consumablesIndex = Cell.defaults.indicatorIndices.consumables

        for _, layout in pairs(CellDB["layouts"]) do
            -- add healthThresholds
            if layout["indicators"][healthThresholdsIndex]["indicatorName"] ~= "healthThresholds" then
                tinsert(layout["indicators"], healthThresholdsIndex, {
                    ["name"] = "Health Thresholds",
                    ["indicatorName"] = "healthThresholds",
                    ["type"] = "built-in",
                    ["enabled"] = false,
                    ["thickness"] = 1,
                    ["thresholds"] = {
                        {0.35, {1, 0, 0, 1}},
                    },
                })
            end

            -- add ShieldBar back (r117)
            if layout["indicators"][shieldBarIndex]["indicatorName"] ~= "shieldBar" then
                tinsert(layout["indicators"], shieldBarIndex, {
                    ["name"] = "Shield Bar",
                    ["indicatorName"] = "shieldBar",
                    ["type"] = "built-in",
                    ["enabled"] = false,
                    ["position"] = {"BOTTOMLEFT", "BOTTOMLEFT", 0, 0},
                    ["frameLevel"] = 2,
                    ["height"] = 4,
                    ["color"] = {1, 1, 0, 1},
                })
            end

            -- add Consumables (r114)
            if not layout["indicators"][consumablesIndex] or layout["indicators"][consumablesIndex]["indicatorName"] ~= "consumables" then
                tinsert(layout["indicators"], consumablesIndex, {
                    ["name"] = "Consumables",
                    ["indicatorName"] = "consumables",
                    ["type"] = "built-in",
                    ["enabled"] = true,
                    ["speed"] = 1,
                })
            end

            -- add speed to Consumables (r115)
            if not layout["indicators"][consumablesIndex]["speed"] then
                layout["indicators"][consumablesIndex]["speed"] = 1
            end

            -- add highlightType to Dispels (r115)
            if not layout["indicators"][dispelsIndex]["highlightType"] then
                layout["indicators"][dispelsIndex]["highlightType"] = "gradient"
            end

            -- add showDispelTypeIcons to Dispels (r115)
            if type(layout["indicators"][dispelsIndex]["showDispelTypeIcons"]) ~= "boolean" then
                layout["indicators"][dispelsIndex]["showDispelTypeIcons"] = true
            end
        end
    end

    -- r134-release add SILLY raid pets
    if CellDB["revise"] and dbRevision < 134 then
        for _, layout in pairs(CellDB["layouts"]) do
            if not layout["pet"] then
                layout["pet"] = {CellDB["general"]["showPartyPets"], false, {}, layout["petSize"][1], {layout["petSize"][2], layout["petSize"][3]}} -- partyPetsEnabled, raidPetsEnabled, raidPetsPosition, sizeEnabled, size
                layout["petSize"] = nil
            end
        end
        CellDB["general"]["showPartyPets"] = nil
    end

    -- r137-release
    if CellDB["revise"] and dbRevision < 137 then
        if not strfind(CellDB["snippets"][0]["code"], "^%-%- snippets can be found") then
            CellDB["snippets"][0]["code"] = "-- snippets can be found at https://github.com/enderneko/Cell/tree/master/.snippets\n"..CellDB["snippets"][0]["code"]
        end
    end

    -- r138-release
    if CellDB["revise"] and dbRevision < 138 then
        if Cell.isRetail then
            -- 邪甲术
            if not F.TContains(CellDB["debuffBlacklist"], 387847) then
                tinsert(CellDB["debuffBlacklist"], 387847)
                Cell.vars.debuffBlacklist = F.ConvertTable(CellDB["debuffBlacklist"])
            end
        end

        for _, layout in pairs(CellDB["layouts"]) do
            if layout["spacing"] then
                layout["spacingX"] = layout["spacing"]
                layout["spacingY"] = layout["spacing"]
                layout["spacing"] = nil
            end
            if not layout["powerFilters"]["EVOKER"] then
                layout["powerFilters"]["EVOKER"] = {["DAMAGER"] = true, ["HEALER"] = true}
            end
        end
    end

    -- r139-release
    if CellDB["revise"] and dbRevision < 139 then
        if Cell.isRetail then
            -- 筋疲力尽
            if not F.TContains(CellDB["debuffBlacklist"], 390435) then
                tinsert(CellDB["debuffBlacklist"], 390435)
                Cell.vars.debuffBlacklist = F.ConvertTable(CellDB["debuffBlacklist"])
            end
        end
    end

    -- r146-release
    if CellDB["revise"] and dbRevision < 146 then
        if Cell.isRetail then
            -- add "Initials"
            for class, t in pairs(CellDB["clickCastings"]) do
                -- fix alwaysTargeting
                if not t["alwaysTargeting"] then
                    t["alwaysTargeting"] = {["common"] = "disabled"}
                end
                -- set up initial spec
                local specID = GetSpecializationInfoForClassID(F.GetClassID(class), 5)
                t["alwaysTargeting"][specID] = "disabled"
                t[specID] = {
                    {"type1", "target"},
                    {"type2", "togglemenu"},
                }
            end
        end
    end

    -- r147-release
    if CellDB["revise"] and dbRevision < 147 then
        if Cell.isRetail then
            for role, t in pairs(CellDB["layoutAutoSwitch"]) do
                if t["raid"] then
                    t["raid_outdoor"] = t["raid"]
                    t["raid_instance"] = t["raid"]
                    t["raid"] = nil
                end
                if t["mythic"] then
                    t["raid_mythic"] = t["mythic"]
                    t["mythic"] = nil
                end
            end
        end

        -- appearance
        if type(CellDB["appearance"]["healPrediction"]) == "boolean" then
            CellDB["appearance"]["healPrediction"] = {CellDB["appearance"]["healPrediction"], false, {1, 1, 1, 0.4}}
        end
        if type(CellDB["appearance"]["shield"]) == "boolean" then
            CellDB["appearance"]["shield"] = {CellDB["appearance"]["shield"], {1, 1, 1, 0.4}}
        end
        if type(CellDB["appearance"]["healAbsorb"]) == "boolean" then
            CellDB["appearance"]["healAbsorb"] = {CellDB["appearance"]["healAbsorb"], {1, 0.1, 0.1, 0.9}}
        end

        -- custom indicator
        for _, layout in pairs(CellDB["layouts"]) do
            for _, indicator in pairs(layout["indicators"]) do
                if indicator["type"] == "bar" then
                    if not indicator["orientation"] then indicator["orientation"] = "horizontal" end
                    if type(indicator["showStack"]) ~= "boolean" then
                        indicator["showStack"] = false
                        indicator["font"] = {"Cell ".._G.DEFAULT, 11, "Outline", 0, 0}
                    end
                elseif indicator["type"] == "rect" then
                    if type(indicator["showStack"]) ~= "boolean" then
                        indicator["showStack"] = false
                        indicator["font"] = {"Cell ".._G.DEFAULT, 11, "Outline", 0, 0}
                    end
                end
            end
        end
    end

    -- r148-release
    if CellDB["revise"] and charaDbRevision and charaDbRevision < 148 then
        for role, t in pairs(CellCharacterDB["layoutAutoSwitch"]) do
            if not t["raid_outdoor"] then
                t["raid_outdoor"] = t["raid25"]
            end
        end
    end

    -- r149-release
    if CellDB["revise"] and dbRevision < 149 then
        -- friendlyNPC -> npc
        for _, layout in pairs(CellDB["layouts"]) do
            if not layout["npc"] then
                -- rename
                layout["npc"] = layout["friendlyNPC"]
                layout["friendlyNPC"] = nil
                -- add sizeEnabled and size
                layout["npc"][4] = false
                layout["npc"][5] = {66, 46}
            end
        end
    end

    -- r150-release
    if CellDB["revise"] and dbRevision < 150 then
        local healthThresholds = Cell.defaults.indicatorIndices["healthThresholds"]
        local dispels = Cell.defaults.indicatorIndices["dispels"]
        local mitigation = Cell.defaults.indicatorIndices["tankActiveMitigation"]
        local aggroBar = Cell.defaults.indicatorIndices["aggroBar"]

        for _, layout in pairs(CellDB["layouts"]) do
            --! check healthThresholds AGAIN
            if layout["indicators"][healthThresholds]["indicatorName"] ~= "healthThresholds" then
                tinsert(layout["indicators"], healthThresholds, {
                    ["name"] = "Health Thresholds",
                    ["indicatorName"] = "healthThresholds",
                    ["type"] = "built-in",
                    ["enabled"] = false,
                    ["thickness"] = 1,
                    ["thresholds"] = {
                        {0.35, {1, 0, 0, 1}},
                    },
                })
            end
            -- add orientation to Dispels
            if layout["indicators"][dispels] and not layout["indicators"][dispels]["orientation"] then
                layout["indicators"][dispels]["orientation"] = "right-to-left"
            end
            -- update bars
            if Cell.isRetail and mitigation and layout["indicators"][mitigation] then
                layout["indicators"][mitigation]["size"][1] = layout["indicators"][mitigation]["size"][1] + 2
                layout["indicators"][mitigation]["size"][2] = layout["indicators"][mitigation]["size"][2] + 2
                if layout["indicators"][mitigation]["position"][3] == 10 and layout["indicators"][mitigation]["position"][4] == -1 then
                    layout["indicators"][mitigation]["position"][3] = 9
                    layout["indicators"][mitigation]["position"][4] = 0
                end
            end
            if layout["indicators"][aggroBar] then
                layout["indicators"][aggroBar]["size"][1] = layout["indicators"][aggroBar]["size"][1] + 2
                layout["indicators"][aggroBar]["size"][2] = layout["indicators"][aggroBar]["size"][2] + 2
                if layout["indicators"][aggroBar]["position"][3] == 1 and layout["indicators"][aggroBar]["position"][4] == 0 then
                    layout["indicators"][aggroBar]["position"][3] = 0
                    layout["indicators"][aggroBar]["position"][4] = -1
                end
            end
        end

        if Cell.isRetail then
            -- targetedSpells
            -- 红玉新生法池
            if not F.TContains(CellDB["targetedSpellsList"], 372858) then -- 灼热打击
                tinsert(CellDB["targetedSpellsList"], 372858)
            end
            -- 奈萨鲁斯
            if not F.TContains(CellDB["targetedSpellsList"], 374533) then -- 炽热挥舞
                tinsert(CellDB["targetedSpellsList"], 374533)
            end
            if not F.TContains(CellDB["targetedSpellsList"], 377018) then -- 熔火真金
                tinsert(CellDB["targetedSpellsList"], 377018)
            end
            -- 蕨皮山谷
            if not F.TContains(CellDB["targetedSpellsList"], 381444) then -- 野蛮冲撞
                tinsert(CellDB["targetedSpellsList"], 381444)
            end
            if not F.TContains(CellDB["targetedSpellsList"], 373912) then -- 腐朽打击
                tinsert(CellDB["targetedSpellsList"], 373912)
            end
            -- 英灵殿
            if not F.TContains(CellDB["targetedSpellsList"], 193092) then -- 放血扫击
                tinsert(CellDB["targetedSpellsList"], 193092)
            end

            -- debuffBlacklist
            if not F.TContains(CellDB["debuffBlacklist"], 213213) then -- 伪装
                tinsert(CellDB["debuffBlacklist"], 213213)
            end

            -- bigDebuffs
            if not F.TContains(CellDB["bigDebuffs"], 240559) then -- 重伤
                tinsert(CellDB["bigDebuffs"], 240559)
            end
            if not F.TContains(CellDB["bigDebuffs"], 396369) then -- 闪电标记
                tinsert(CellDB["bigDebuffs"], 396369)
            end
            if not F.TContains(CellDB["bigDebuffs"], 396364) then -- 狂风标记
                tinsert(CellDB["bigDebuffs"], 396364)
            end
        end
    end

    -- r152-release
    if CellDB["revise"] and dbRevision < 152 then
        if Cell.isRetail then
            local found1, found2
            for _, t in pairs(CellDB["consumables"]) do
                if t[1] == 370511 then found1 = true end
                if t[1] == 371024 then found2 = true end
            end
            if not found1 then
                tinsert(CellDB["consumables"], {
                    370511, -- 振奋治疗药水
                    {"A", {1, 0.1, 0.1}},
                })
            end
            if not found2 then
                tinsert(CellDB["consumables"], {
                    371024, -- 元素强能药水
                    {"C3", {1, 1, 0}},
                })
            end
            Cell.vars.consumables = I.ConvertConsumables(CellDB["consumables"])

            -- 英灵殿
            if not F.TContains(CellDB["targetedSpellsList"], 193659) then -- 邪炽冲刺
                tinsert(CellDB["targetedSpellsList"], 193659)
            end
        end

        for _, layout in pairs(CellDB["layouts"]) do
            local nameText = Cell.defaults.indicatorIndices.healthText
            if layout["indicators"][nameText] and layout["indicators"][nameText]["indicatorName"] == "nameText" then
                if type(layout["indicators"][nameText]["hideFull"]) == "boolean" then
                    layout["indicators"][nameText]["hideIfEmptyOrFull"] = layout["indicators"][nameText]["hideFull"]
                    layout["indicators"][nameText]["hideFull"] = nil
                end
            end
        end
    end

    -- r153-release
    if CellDB["revise"] and dbRevision < 153 then
        if Cell.isRetail then
            -- targetedSpells
            -- 青龙寺
            if not F.TContains(CellDB["targetedSpellsList"], 106823) then -- 翔龙猛袭
                tinsert(CellDB["targetedSpellsList"], 106823)
            end
            if not F.TContains(CellDB["targetedSpellsList"], 106841) then -- 青龙猛袭
                tinsert(CellDB["targetedSpellsList"], 106841)
            end
            -- 群星庭院
            if not F.TContains(CellDB["targetedSpellsList"], 211473) then -- 暗影鞭笞
                tinsert(CellDB["targetedSpellsList"], 211473)
            end
            -- 英灵殿
            if not F.TContains(CellDB["targetedSpellsList"], 192018) then -- 光明之盾
                tinsert(CellDB["targetedSpellsList"], 192018)
            end
            -- 化身巨龙牢窟
            if not F.TContains(CellDB["targetedSpellsList"], 375870) then -- 致死石爪
                tinsert(CellDB["targetedSpellsList"], 375870)
            end
            if not F.TContains(CellDB["targetedSpellsList"], 395906) then -- 电化之颌
                tinsert(CellDB["targetedSpellsList"], 395906)
            end
            if not F.TContains(CellDB["targetedSpellsList"], 372158) then -- 破甲一击
                tinsert(CellDB["targetedSpellsList"], 372158)
            end
            if not F.TContains(CellDB["targetedSpellsList"], 372056) then -- 碾压
                tinsert(CellDB["targetedSpellsList"], 372056)
            end
            if not F.TContains(CellDB["targetedSpellsList"], 375580) then -- 西风猛击
                tinsert(CellDB["targetedSpellsList"], 375580)
            end
            if not F.TContains(CellDB["targetedSpellsList"], 376276) then -- 震荡猛击
                tinsert(CellDB["targetedSpellsList"], 376276)
            end
            -- 红玉新生法池
            if not F.TContains(CellDB["targetedSpellsList"], 381512) then -- 风暴猛击
                tinsert(CellDB["targetedSpellsList"], 381512)
            end
            -- 碧蓝魔馆
            if not F.TContains(CellDB["targetedSpellsList"], 374789) then -- 注能打击
                tinsert(CellDB["targetedSpellsList"], 374789)
            end
            if not F.TContains(CellDB["targetedSpellsList"], 372222) then -- 奥术顺劈
                tinsert(CellDB["targetedSpellsList"], 372222)
            end
            if not F.TContains(CellDB["targetedSpellsList"], 384978) then -- 巨龙打击
                tinsert(CellDB["targetedSpellsList"], 384978)
            end
            if not F.TContains(CellDB["targetedSpellsList"], 391136) then -- 肩部猛击
                tinsert(CellDB["targetedSpellsList"], 391136)
            end
            -- 诺库德阻击战
            if not F.TContains(CellDB["targetedSpellsList"], 376827) then -- 传导打击
                tinsert(CellDB["targetedSpellsList"], 376827)
            end
            if not F.TContains(CellDB["targetedSpellsList"], 376829) then -- 雷霆打击
                tinsert(CellDB["targetedSpellsList"], 376829)
            end
            if not F.TContains(CellDB["targetedSpellsList"], 375937) then -- 撕裂猛击
                tinsert(CellDB["targetedSpellsList"], 375937)
            end
            if not F.TContains(CellDB["targetedSpellsList"], 375929) then -- 野蛮打击
                tinsert(CellDB["targetedSpellsList"], 375929)
            end

            Cell.vars.targetedSpellsList = F.ConvertTable(CellDB["targetedSpellsList"])
        end
    end

    -- r154-release
    if CellDB["revise"] and dbRevision < 154 then
        if Cell.isRetail then
            -- 诺库德阻击战
            if not F.TContains(CellDB["targetedSpellsList"], 376644) then -- 钢铁之矛
                tinsert(CellDB["targetedSpellsList"], 376644)
            end
            if not F.TContains(CellDB["targetedSpellsList"], 376865) then -- 静电之矛
                tinsert(CellDB["targetedSpellsList"], 376865)
            end
            if not F.TContains(CellDB["targetedSpellsList"], 382836) then -- 残杀
                tinsert(CellDB["targetedSpellsList"], 382836)
            end
            -- 英灵殿
            if not F.TContains(CellDB["targetedSpellsList"], 196838) then -- 血之气息
                tinsert(CellDB["targetedSpellsList"], 196838)
            end
        end
    end

    -- r156-release
    if CellDB["revise"] and dbRevision < 156 then
        if CellDB["customDefensives"] then
            CellDB["defensives"]["custom"] = CellDB["customDefensives"]
            CellDB["customDefensives"] = nil
        end
        if CellDB["customExternals"] then
            CellDB["externals"]["custom"] = CellDB["customExternals"]
            CellDB["customExternals"] = nil
        end
    end

    -- r158-release
    if CellDB["revise"] and dbRevision < 158 then
        --! Missing Buffs indicator only works on Retail
        --! because it's difficult to check Blessings on Wrath
        if Cell.isRetail then
            local index = Cell.defaults.indicatorIndices.missingBuffs
            for _, layout in pairs(CellDB["layouts"]) do
                if not layout["indicators"][index] or layout["indicators"][index]["indicatorName"] ~= "missingBuffs" then
                    tinsert(layout.indicators, index, {
                        ["name"] = "Missing Buffs",
                        ["indicatorName"] = "missingBuffs",
                        ["type"] = "built-in",
                        ["enabled"] = false,
                        -- ["trackByName"] = Cell.isCata,
                        ["position"] = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 4},
                        ["frameLevel"] = 10,
                        ["size"] = {13, 13},
                        ["num"] = 3,
                        ["orientation"] = "right-to-left",
                    })
                end
            end
        end
    end

    -- r162-release
    if CellDB["revise"] and dbRevision < 162 then
        if type(CellDB["general"]["sortPartyByRole"]) == "boolean" then
            for _, layout in pairs(CellDB["layouts"]) do
                layout["sortByRole"] = CellDB["general"]["sortPartyByRole"]
            end
            CellDB["general"]["sortPartyByRole"] = nil
        end
    end

    -- r163-release
    if CellDB["revise"] and dbRevision < 163 then
        if type(CellDB["appearance"]["strata"]) ~= "string" then
            CellDB["appearance"]["strata"] = "MEDIUM"
        end
    end

    -- r164-release
    if CellDB["revise"] and dbRevision < 164 then
        for class, t in pairs(CellDB["clickCastings"]) do
            if type(t["smartResurrection"]) ~= "string" then
                t["smartResurrection"] = "disabled"
            end
        end
    end

    -- r168-release
    if CellDB["revise"] and dbRevision < 168 then
        if Cell.isRetail then
            -- targetedSpells
            -- 亚贝鲁斯，焰影熔炉
            if not F.TContains(CellDB["targetedSpellsList"], 401022) then -- 灾祸掠击
                tinsert(CellDB["targetedSpellsList"], 401022)
            end
            if not F.TContains(CellDB["targetedSpellsList"], 407790) then -- 身影碎离
                tinsert(CellDB["targetedSpellsList"], 407790)
            end
        end
    end

    -- r169-release
    if CellDB["revise"] and dbRevision < 169 then
        if Cell.isRetail then
            local privateAuras = Cell.defaults.indicatorIndices["privateAuras"]

            for _, layout in pairs(CellDB["layouts"]) do
                if layout["indicators"][privateAuras]["indicatorName"] ~= "privateAuras" then
                    tinsert(layout["indicators"], privateAuras, {
                        ["name"] = "Private Auras",
                        ["indicatorName"] = "privateAuras",
                        ["type"] = "built-in",
                        ["enabled"] = true,
                        ["position"] = {"TOP", "TOP", 0, 3},
                        ["frameLevel"] = 25,
                        ["size"] = {18, 18},
                        ["privateAuraOptions"] = {true, false},
                    })
                end
            end
        end
    end

    -- r170-release
    if CellDB["revise"] and dbRevision < 170 then
        if not strfind(CellDB["snippets"][0]["code"], "CELL_NICKTAG_ENABLED") then
            CellDB["snippets"][0]["code"] = CellDB["snippets"][0]["code"].."\n\n-- Use nicknames from Details! Damage Meter (boolean, NickTag-1.0 library)\nCELL_NICKTAG_ENABLED = false"
        end

        if Cell.isCata then
            local index = Cell.defaults.indicatorIndices.missingBuffs
            for _, layout in pairs(CellDB["layouts"]) do
                if not layout["indicators"][index] or layout["indicators"][index]["indicatorName"] ~= "missingBuffs" then
                    tinsert(layout.indicators, index, {
                        ["name"] = "Missing Buffs",
                        ["indicatorName"] = "missingBuffs",
                        ["type"] = "built-in",
                        ["enabled"] = false,
                        ["buffByMe"] = false,
                        ["position"] = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 4},
                        ["frameLevel"] = 10,
                        ["size"] = {13, 13},
                        ["num"] = 3,
                        ["orientation"] = "right-to-left",
                    })
                end
            end
        end
    end

    -- r171-release
    if CellDB["revise"] and dbRevision < 171 then
        if not strfind(CellDB["snippets"][0]["code"], "CELL_DISPEL_EVOKER_CAUTERIZING_FLAME") then
            CellDB["snippets"][0]["code"] = CellDB["snippets"][0]["code"].."\n\n-- Add Evoker spell Cauterizing Flame into dispel checker (boolean)\nCELL_DISPEL_EVOKER_CAUTERIZING_FLAME = false"
        end
    end

    -- r173-release
    if CellDB["revise"] and dbRevision < 173 then
        local leaderIcon = Cell.defaults.indicatorIndices["leaderIcon"]

        for _, layout in pairs(CellDB["layouts"]) do
            if type(layout["indicators"][leaderIcon]["hideInCombat"]) ~= "boolean" then
                layout["indicators"][leaderIcon]["hideInCombat"] = true
            end
        end
    end

    -- r174-release
    if CellDB["revise"] and dbRevision < 174 then
        for _, layout in pairs(CellDB["layouts"]) do
            for _, indicator in pairs(layout["indicators"]) do
                local name = indicator["indicatorName"]
                local type = indicator["type"]
                local font = indicator["font"]

                if font and #font == 5 then
                    if name == "debuffs" or name == "raidDebuffs" or name == "externalCooldowns" or name == "defensiveCooldowns" or name == "allCooldowns" or type == "icon" or type == "icons" then
                        indicator["font"] = {
                            {font[1], font[2], font[3], "TOPRIGHT", font[4], font[5], {1, 1, 1}}, -- stackFont
                            {font[1], font[2], font[3], "BOTTOMRIGHT", font[4], -font[5], {1, 1, 1}}, -- durationFont
                        }

                    elseif name == "targetedSpells" then
                        indicator["font"] = {font[1], font[2], font[3], "TOPRIGHT", font[4], font[5], {1, 1, 1}}

                    elseif type == "bar" or type == "rect" then
                        indicator["font"] = {font[1], font[2], font[3], "CENTER", font[4], font[5], {1, 1, 1}}
                    end
                end
            end
        end
    end

    -- r176-release
    if CellDB["revise"] and dbRevision < 176 then
        -- full hp color
        if type(CellDB["appearance"]["fullColor"]) ~= "table" then
            CellDB["appearance"]["fullColor"] = {false, {0.2, 0.2, 0.2}}
        end
    end

    -- r177-release
    if CellDB["revise"] and dbRevision < 177 then
        if Cell.isRetail then
            --! evoker Augmentation 1473
            if CellDB["clickCastings"]["EVOKER"] then
                if not CellDB["clickCastings"]["EVOKER"][1473] then
                    CellDB["clickCastings"]["EVOKER"]["alwaysTargeting"][1473] = "disabled"
                    CellDB["clickCastings"]["EVOKER"][1473] = {
                        {"type1", "target"},
                        {"type2", "togglemenu"},
                        {"type-shiftR", "spell", 361227},
                    }
                end
            end
        end
    end

    -- r178-release
    if CellDB["revise"] and dbRevision < 178 then
        if Cell.isCata then
            for _, layout in pairs(CellDB["layouts"]) do
                local index = Cell.defaults.indicatorIndices.powerWordShield
                if layout["indicators"][index]["indicatorName"] ~= "powerWordShield" then
                    tinsert(layout["indicators"], index, {
                        ["name"] = "PW:S",
                        ["indicatorName"] = "powerWordShield",
                        ["type"] = "built-in",
                        ["enabled"] = false,
                        ["position"] = {"CENTER", "BOTTOMRIGHT", -7, 7},
                        ["frameLevel"] = 10,
                        ["size"] = {20, 20},
                        ["shieldByMe"] = true,
                    })
                end
            end
        end
    end

    -- r181-release
    if CellDB["revise"] and dbRevision < 181 then
        if Cell.isCata then
            for _, layout in pairs(CellDB["layouts"]) do
                local index = Cell.defaults.indicatorIndices.powerWordShield
                if type(layout["indicators"][index]["shape"]) ~= "string" then
                    layout["indicators"][index]["shape"] = "circle"
                end
            end
        end
    end

    -- r182-release
    if CellDB["revise"] and dbRevision < 182 then
        if Cell.isCata then
            if CellDB["clickCastings"] and CellDB["clickCastings"][Cell.vars.playerClass] then
                if not CellCharacterDB["clickCastings"]["processed"] then
                    CellCharacterDB["clickCastings"] = CellDB["clickCastings"][Cell.vars.playerClass]
                    Cell.vars.clickCastings = CellCharacterDB["clickCastings"]
                    -- flag as processed
                    CellCharacterDB["clickCastings"]["processed"] = true
                end
            end
        end

        for _, layout in pairs(CellDB["layouts"]) do
            if not layout["main"] then
                layout["main"] = {
                    ["sortByRole"] = layout["sortByRole"],
                    ["hideSelf"] = layout["hideSelf"],
                    ["size"] = layout["size"],
                    ["position"] = layout["position"],
                    ["powerSize"] = layout["powerSize"],
                    ["orientation"] = layout["orientation"],
                    ["anchor"] = layout["anchor"],
                    ["spacingX"] = layout["spacingX"],
                    ["spacingY"] = layout["spacingY"],
                    ["columns"] = layout["columns"],
                    ["rows"] = layout["rows"],
                    ["groupSpacing"] = layout["groupSpacing"],
                }

                layout["pet"] = {
                    ["partyEnabled"] = layout["pet"][1],
                    ["raidEnabled"] = layout["pet"][2],
                    ["sameSizeAsMain"] = not layout["pet"][4],
                    ["sameArrangementAsMain"] = true,
                    ["size"] = layout["pet"][5],
                    ["position"] = layout["pet"][3],
                    ["powerSize"] = layout["powerSize"],
                    ["orientation"] = layout["orientation"],
                    ["anchor"] = layout["anchor"],
                    ["spacingX"] = layout["spacingX"],
                    ["spacingY"] = layout["spacingY"],
                }

                layout["npc"] = {
                    ["enabled"] = layout["npc"][1],
                    ["separate"] = layout["npc"][2],
                    ["sameSizeAsMain"] = not layout["npc"][4],
                    ["sameArrangementAsMain"] = true,
                    ["size"] = layout["npc"][5],
                    ["position"] = layout["npc"][3],
                    ["powerSize"] = layout["powerSize"],
                    ["orientation"] = layout["orientation"],
                    ["anchor"] = layout["anchor"],
                    ["spacingX"] = layout["spacingX"],
                    ["spacingY"] = layout["spacingY"],
                }

                layout["spotlight"] = {
                    ["enabled"] = layout["spotlight"][1],
                    ["units"] = layout["spotlight"][2],
                    ["sameSizeAsMain"] = not layout["spotlight"][4],
                    ["sameArrangementAsMain"] = true,
                    ["size"] = layout["spotlight"][5],
                    ["position"] = layout["spotlight"][3],
                    ["powerSize"] = layout["powerSize"],
                    ["orientation"] = layout["orientation"],
                    ["anchor"] = layout["anchor"],
                    ["spacingX"] = layout["spacingX"],
                    ["spacingY"] = layout["spacingY"],
                }
            end

            layout["size"] = nil
            layout["position"] = nil
            layout["powerSize"] = nil
            layout["spacingX"] = nil
            layout["spacingY"] = nil
            layout["orientation"] = nil
            layout["anchor"] = nil
            layout["columns"] = nil
            layout["rows"] = nil
            layout["groupSpacing"] = nil
            layout["sortByRole"] = nil
            layout["hideSelf"] = nil
        end
    end

    -- r186-release
    if CellDB["revise"] and dbRevision < 186 then
        if CellDB["glows"] then
            CellDB["spellRequest"] = CellDB["glows"]["spellRequest"]
            CellDB["dispelRequest"] = CellDB["glows"]["dispelRequest"]
            CellDB["glows"] = nil

            CellDB["spellRequest"]["sharedIconOptions"] = {
                "beat", -- [1] animation
                27, -- [2] size
                "BOTTOMRIGHT", -- [3] anchor
                "BOTTOMRIGHT", -- [4] anchorTo
                0, -- [5] x
                0, -- [6] y
            }

            for _, t in pairs(CellDB["spellRequest"]["spells"]) do
                t["type"] = "icon"
                t["icon"] = select(2, F.GetSpellInfo(t["spellId"]))
                t["iconColor"] = t["glowOptions"][2][1]
            end

            CellDB["dispelRequest"]["textOptions"] = {
                "A",
                {1, 0, 0, 1}, -- [1] color
                32, -- [2] size
                "TOPLEFT", -- [3] anchor
                "TOPLEFT", -- [4] anchorTo
                -1, -- [5] x
                5, -- [6] y
            }

            CellDB["dispelRequest"]["type"] = "text"
        end

        if Cell.isCata then
            CellCharacterDB["clickCastings"]["class"] = Cell.vars.playerClass
        end
    end

    -- r187-release
    if CellDB["revise"] and dbRevision < 187 then
        if type(CellDB["dispelRequest"]["textOptions"][1]) ~= "string" then
            tinsert(CellDB["dispelRequest"]["textOptions"][1], 1, "A")
        end

        if Cell.isRetail and type(CellDB["quickCast"]) == "table" then
            for class, classTbl in pairs(CellDB["quickCast"]) do
                for spec, specTbl in pairs(classTbl) do
                    if not specTbl["glowBuffsColor"] then
                        specTbl["glowBuffsColor"] = {1, 1, 0, 1}
                    end
                    if not specTbl["glowCasts"] then
                        specTbl["glowCasts"] = {}
                        specTbl["glowCastsColor"] = {1, 0, 1, 1}
                    end
                end
            end
        end
    end

    -- r188-release
    if CellDB["revise"] and dbRevision < 188 then
        if Cell.isRetail and type(CellDB["quickCast"]) == "table" then
            for class, classTbl in pairs(CellDB["quickCast"]) do
                for spec, specTbl in pairs(classTbl) do
                    if strfind(specTbl["orientation"], "^vertical") or strfind(specTbl["orientation"], "^horizontal") then
                        specTbl["orientation"] = specTbl["orientation"]:gsub("^vertical%-", "")
                        specTbl["orientation"] = specTbl["orientation"]:gsub("^horizontal%-", "")
                    end
                end
            end
        end
    end

    -- r190-beta
    if CellDB["revise"] and dbRevision < 190 then
        if not strfind(CellDB["snippets"][0]["code"], "CELL_TOOLTIP_REMOVE_RAID_SETUP_DETAILS") then
            CellDB["snippets"][0]["code"] = CellDB["snippets"][0]["code"].."\n\n-- remove raid setup details from the tooltip of the Raid button (boolean)\nCELL_TOOLTIP_REMOVE_RAID_SETUP_DETAILS = false"
        end

        if Cell.isRetail then
            for _, layout in pairs(CellDB["layouts"]) do
                local index = Cell.defaults.indicatorIndices.crowdControls
                if layout["indicators"][index]["indicatorName"] ~= "crowdControls" then
                    tinsert(layout["indicators"], index, {
                        ["name"] = "Crowd Controls",
                        ["indicatorName"] = "crowdControls",
                        ["type"] = "built-in",
                        ["enabled"] = false,
                        ["position"] = {"CENTER", "CENTER", 0, 0},
                        ["frameLevel"] = 20,
                        ["size"] = {22, 22},
                        ["border"] = 2,
                        ["num"] = 3,
                        ["font"] = {
                            {"Cell ".._G.DEFAULT, 11, "Outline", "TOPRIGHT", 2, 1, {1, 1, 1}},
                            {"Cell ".._G.DEFAULT, 11, "Outline", "BOTTOMRIGHT", 2, -1, {1, 1, 1}},
                        },
                        ["orientation"] = "left-to-right",
                    })
                end
            end
        end
    end

    -- r195-release
    if CellDB["revise"] and dbRevision < 195 then
        if not strfind(CellDB["snippets"][0]["code"], "CELL_BORDER_SIZE") then
            CellDB["snippets"][0]["code"] = CellDB["snippets"][0]["code"].."\n\n-- border thickness: unit button and icon (number)\nCELL_BORDER_SIZE = 1"
        end

        local filters

        if Cell.isRetail then
            filters = {
                ["PWF"] = true,
                ["MotW"] = true,
                ["AB"] = true,
                ["BS"] = true,
                ["BotB"] = true,
            }
        else
            filters = {
                ["PWF"] = true,
                ["DS"] = true,
                ["SP"] = true,
                ["AB"] = true,
                ["MotW"] = true,
                ["PALADIN"] = true,
                ["WARRIOR"] = true,
            }
        end

        for _, layout in pairs(CellDB["layouts"]) do
            local index = Cell.defaults.indicatorIndices.missingBuffs
            if type(layout["indicators"][index]["filters"]) ~= "table" then
                layout["indicators"][index]["filters"] = F.Copy(filters)
                layout["indicators"][index]["filters"]["buffByMe"] = layout["indicators"][index]["buffByMe"]
                layout["indicators"][index]["buffByMe"] = nil
            end
        end
    end

    -- r196-release
    if CellDB["revise"] and dbRevision < 196 then
        if not strfind(CellDB["snippets"][0]["code"], "CELL_BORDER_COLOR") then
            CellDB["snippets"][0]["code"] = CellDB["snippets"][0]["code"].."\n\n-- unit button border color ({r, g, b, a}, number: 0-1)\nCELL_BORDER_COLOR = {0, 0, 0, 1}"
        end
    end

    -- r197-release
    if CellDB["revise"] and dbRevision < 197 then
        if Cell.isRetail then
            for c, ct in pairs(CellDB["quickCast"]) do
                for s, st in pairs(ct) do
                    if type(st["spacing"]) == "number" then
                        st["spacingX"] = st["spacing"]
                        st["spacingY"] = st["spacing"]
                        st["spacing"] = nil
                        st["lines"] = 6
                    end
                end
            end
        end

        if type(CellDB["tools"]["marks"][2]) ~= "boolean" then
            tinsert(CellDB["tools"]["marks"], 2, false)
        end
    end

    -- r198-release
    -- if CellDB["revise"] and dbRevision < 198 then
    --     for _, layout in pairs(CellDB["layouts"]) do
    --         local index = Cell.defaults.indicatorIndices.targetCounter
    --         if type(layout["indicators"][index]["filters"]) ~= "table" then
    --             layout["indicators"][index]["filters"] = {
    --                 ["outdoor"] = false,
    --                 ["pve"] = false,
    --                 ["pvp"] = true,
    --             }
    --         end
    --     end
    -- end

    -- r199-release
    if CellDB["revise"] and dbRevision < 199 then
        if not strfind(CellDB["snippets"][0]["code"], "CELL_SHOW_RAID_PET_OWNER_NAME") then
            CellDB["snippets"][0]["code"] = CellDB["snippets"][0]["code"].."\n\n-- show raid pet owner name (\"VEHICLE\", \"NAME\", nil)\nCELL_SHOW_RAID_PET_OWNER_NAME = nil"
        end

        for _, layout in pairs(CellDB["layouts"]) do
            for i, t in ipairs(layout["indicators"]) do
                if type(t["castByMe"]) == "boolean" then
                    t["castBy"] = t["castByMe"] and "me" or "anyone"
                    t["castByMe"] = nil
                end
            end
        end
    end

    -- r200-release
    if CellDB["revise"] and dbRevision < 200 then
        if #CellDB["tools"]["buffTracker"] ~= 4 then
            -- move position from 2 to 4
            CellDB["tools"]["buffTracker"][4] = CellDB["tools"]["buffTracker"][2]
            -- add orientation
            CellDB["tools"]["buffTracker"][2] = "left-to-right"
        end
        if #CellDB["tools"]["readyAndPull"] ~= 4 then
            -- add style
            tinsert(CellDB["tools"]["readyAndPull"], 2, "text_button")
        end
    end

    -- r201-release
    if CellDB["revise"] and dbRevision < 201 then
        if Cell.isRetail then
            -- 阿梅达希尔，梦境之愿
            if not F.TContains(CellDB["targetedSpellsList"], 418637) then -- 狂怒冲锋
                tinsert(CellDB["targetedSpellsList"], 418637)
            end
        end
    end

    -- r202-release
    -- if CellDB["revise"] and dbRevision < 202 then
    --     -- custom indicator
    --     for _, layout in pairs(CellDB["layouts"]) do
    --         for _, indicator in pairs(layout["indicators"]) do
    --             if indicator["type"] == "icon" or indicator["type"] == "icons" then
    --                 if type(indicator["showStack"]) ~= "boolean" then
    --                     indicator["showStack"] = true
    --                 end
    --             end
    --         end
    --     end
    -- end

    -- r203-release
    if CellDB["revise"] and dbRevision < 203 then
        for _, layout in pairs(CellDB["layouts"]) do
            for i, t in pairs(layout["indicators"]) do
                if t["indicatorName"] == "targetCounter" then
                    if type(t["filters"]) ~= "table" then
                        t["filters"] = {
                            ["outdoor"] = false,
                            ["pve"] = false,
                            ["pvp"] = true,
                        }
                    end
                    break
                end
            end
        end
    end

    -- r205-release
    if CellDB["revise"] and dbRevision < 205 then
        for _, layout in pairs(CellDB["layouts"]) do
            for i, t in pairs(layout["indicators"]) do
                if t["indicatorName"] == "aggroBorder" then
                    if t["frameLevel"] == 3 then
                        t["frameLevel"] = 7
                    end
                    break
                end
            end
        end

        if not CellDB["general"]["framePriority"] then
            CellDB["general"]["framePriority"] = "normal_spotlight"
        end
    end

    -- r206-release
    if CellDB["revise"] and dbRevision < 206 then
        for _, layout in pairs(CellDB["layouts"]) do
            for _, t in pairs(layout["indicators"]) do
                -- fix showStack for custom indicators
                if t["type"] == "icon" or t["type"] == "icons" then
                    if type(t["showStack"]) ~= "boolean" then
                        t["showStack"] = true
                    end
                end

                if t["indicatorName"] == "statusText" then
                    -- add showTimer for statusText
                    if type(t["showTimer"]) ~= "boolean" then
                        t["showTimer"] = true
                    end
                    -- add showBackground for statusText
                    if type(t["showBackground"]) ~= "boolean" then
                        t["showBackground"] = true
                    end
                end

                if t["indicatorName"] == "nameText" then
                    -- swap en/non-en length for name text
                    if t["textWidth"][1] == "length" then
                        if not t["textWidth"][3] then -- en cilents
                            t["textWidth"][3] = 3
                        else -- aisan cilents
                            local temp = t["textWidth"][2]
                            t["textWidth"][2] = t["textWidth"][3]
                            t["textWidth"][3] = temp
                        end
                    end
                end
            end
        end

        if CellDB["general"]["framePriority"] == "normal_spotlight" then
            CellDB["general"]["framePriority"] = "normal_spotlight_quickassist"
        elseif CellDB["general"]["framePriority"] == "spotlight_normal" then
            CellDB["general"]["framePriority"] = "spotlight_normal_quickassist"
        end
    end

    -- r207-release
    if CellDB["revise"] and dbRevision < 207 then
        if Cell.isRetail then
            for spec, t in pairs(CellDB["quickAssist"]) do
                -- clickCastings -> buffs
                if not t["spells"]["mine"]["buffs"] then
                    t["spells"]["mine"]["buffs"] = t["spells"]["mine"]["clickCastings"]
                    t["spells"]["mine"]["clickCastings"] = nil
                    for _, st in pairs(t["spells"]["mine"]["buffs"]) do
                        if st[1] == -1 then st[1] = 0 end
                        tinsert(st, 2, "icon")
                    end
                end
                -- add bar options
                if not t["spells"]["mine"]["bar"] then
                    t["spells"]["mine"]["bar"] = {
                        ["position"] = {"TOPRIGHT", "BOTTOMRIGHT", 0, 1},
                        ["orientation"] = "top-to-bottom",
                        ["size"] = {75, 4},
                    }
                end
                -- add glow options
                if not t["spells"]["offensives"]["glow"] then
                    t["spells"]["offensives"]["glow"] = {
                        ["fadeOut"] = false,
                        ["options"] = {"None", {0.95,0.95,0.32,1}},
                    }
                end
                -- add filters
                if not t["layout"]["filters"] then
                    t["layout"]["filters"] = {
                        t["layout"]["filter"],
                        {"role", {["TANK"] = false, ["HEALER"] = false, ["DAMAGER"] = true}, false},
                        {"role", {["TANK"] = false, ["HEALER"] = false, ["DAMAGER"] = true}, false},
                        {"role", {["TANK"] = false, ["HEALER"] = false, ["DAMAGER"] = true}, false},
                        {"role", {["TANK"] = false, ["HEALER"] = false, ["DAMAGER"] = true}, false},
                        ["active"] = 1,
                    }
                    t["layout"]["filter"] = nil
                end
            end
        end
    end

    -- r209-release
    if CellDB["revise"] and dbRevision < 209 then
        -- add change-over-time to custom Color indicator
        for _, layout in pairs(CellDB["layouts"]) do
            for _, indicator in pairs(layout["indicators"]) do
                if indicator["type"] == "color" and #indicator["colors"] ~= 6 then
                    indicator["colors"][4] = {0,1,0} -- normal
                    indicator["colors"][5] = {1,1,0,0.5} -- percent
                    indicator["colors"][6] = {1,0,0,3} -- second
                end
            end
        end
    end

    -- r210-release
    if CellDB["revise"] and dbRevision < 210 then
        if not CellDB["debuffTypeColor"]["Bleed"] then
            CellDB["debuffTypeColor"]["Bleed"] = {r=1, g=0.2, b=0.6}
        end
    end

    -- r213-release
    if CellDB["revise"] and dbRevision < 213 then
        if Cell.isRetail then
            for spec, t in pairs(CellDB["quickAssist"]) do
                if not t["filters"] then
                    t["filters"] = t["layout"]["filters"]
                    t["filters"]["active"] = nil
                    t["filters"][6] = F.Copy(t["filters"][5])
                    t["filters"][7] = F.Copy(t["filters"][5])
                    t["layout"]["filters"] = nil
                end
                if not t["filterAutoSwitch"] then
                    t["filterAutoSwitch"] = {
                        ["party"] = 1,
                        ["raid"] = 1,
                        ["mythic"] = 1,
                        ["arena"] = 1,
                        ["battleground"] = 1,
                    }
                end
                for _, ft in pairs(t["filters"]) do
                    if ft[1] == "name" then
                        ft[3] = false
                    end
                end
            end
        end
    end

    -- r215-release
    if CellDB["revise"] and dbRevision < 215 then
        for _, layout in pairs(CellDB["layouts"]) do
            for i, t in pairs(layout["indicators"]) do
                -- add color for tankActiveMitigation
                if t["indicatorName"] == "tankActiveMitigation" then
                    if type(t["color"]) ~= "table" then
                        t["color"] = {"class_color", {0.25, 1, 0}}
                    end
                end

                -- rename nameColor to color
                if t["indicatorName"] == "nameText" then
                    if type(t["color"]) ~= "table" then
                        t["color"] = t["nameColor"]
                        if t["color"][1] == "custom" then
                            t["color"][1] = "custom_color"
                        end
                        t["nameColor"] = nil
                    end
                end
            end
        end

        -- set alwaysUpdateDebuffs default to true
        -- if not CellDB["general"]["alwaysUpdateDebuffs"] then
        --     CellDB["general"]["alwaysUpdateDebuffs"] = true
        -- end
    end

    -- r217-release
    if CellDB["revise"] and dbRevision < 217 then
        for _, layout in pairs(CellDB["layouts"]) do
            for _, i in pairs(layout["indicators"]) do
                if i.indicatorName == "externalCooldowns" or i.indicatorName == "defensiveCooldowns" or i.indicatorName == "allCooldowns" or i.indicatorName == "debuffs"
                    or i.type == "icon" or i.type == "icons" then

                    -- add showAnimation option
                    if type(i.showAnimation) ~= "boolean" then
                        i.showAnimation = true
                    end

                    -- update showDuration
                    if i.showDuration == 0 then
                        i.showDuration = true
                    end
                end
            end
        end

        if Cell.isRetail then
            for spec, t in pairs(CellDB["quickAssist"]) do
                -- update showDuration
                if t["spells"]["mine"]["icon"]["showDuration"] == 0 then
                    t["spells"]["mine"]["icon"]["showDuration"] = true
                end
                if t["spells"]["offensives"]["icon"]["showDuration"] == 0 then
                    t["spells"]["offensives"]["icon"]["showDuration"] = true
                end
                -- add showAnimation
                if type(t["spells"]["mine"]["icon"]["showAnimation"]) ~= "boolean" then
                    t["spells"]["mine"]["icon"]["showAnimation"] = true
                end
                if type(t["spells"]["offensives"]["icon"]["showAnimation"]) ~= "boolean" then
                    t["spells"]["offensives"]["icon"]["showAnimation"] = true
                end
            end
        end
    end

    -- r218-release
    if CellDB["revise"] and dbRevision < 218 then
        for _, layout in pairs(CellDB["layouts"]) do
            -- fix role order option
            if not layout["main"]["roleOrder"] then
                layout["main"]["roleOrder"] = {"TANK", "HEALER", "DAMAGER"}
            end
        end
    end

    -- r219-release
    if CellDB["revise"] and dbRevision < 219 then
        if not CellDB["appearance"]["gradientColors"] then
            CellDB["appearance"]["gradientColors"] = {{1,0,0}, {1,0.7,0}, {0.7,1,0}}
        end
    end

    -- r221-release
    if CellDB["revise"] and dbRevision < 221 then
        for _, layout in pairs(CellDB["layouts"]) do
            for _, i in pairs(layout["indicators"]) do
                if i.type == "icons" then
                    if not i.numPerLine then
                        i.numPerLine = i.num
                    end
                elseif i.type == "bar" then
                    if #i.colors ~= 4 then
                        tinsert(i.colors, {0.07,0.07,0.07,0.9})
                        tinsert(i.colors[2], 1, true)
                        tinsert(i.colors[3], 1, true)
                    end
                end
            end
        end
    end

    -- r222-release
    if CellDB["revise"] and dbRevision < 222 then
        for _, layout in pairs(CellDB["layouts"]) do
            -- add maxColumns, unitsPerColumn
            if not layout["main"]["maxColumns"] then
                if layout["main"]["orientation"] == "vertical" then
                    layout["main"]["maxColumns"] = layout["main"]["columns"]
                else
                    layout["main"]["maxColumns"] = layout["main"]["rows"]
                end
                layout["main"]["columns"] = nil
                layout["main"]["rows"] = nil
            end
            if not layout["main"]["unitsPerColumn"] then
                layout["main"]["unitsPerColumn"] = 5
            end

            -- update text/rect color
            for _, i in pairs(layout["indicators"]) do
                if i.type == "text" or i.type == "rect" then
                    if #i.colors[2] ~= 5 then
                        tinsert(i.colors[2], 1, true)
                        tinsert(i.colors[3], 1, true)
                    end
                end
            end
        end

        -- update layoutAutoSwitch
        if Cell.isRetail then
            if not CellDB["layoutAutoSwitch"]["role"] then
                CellDB["layoutAutoSwitch"]["role"] = {
                    ["TANK"] = CellDB["layoutAutoSwitch"]["TANK"],
                    ["HEALER"] = CellDB["layoutAutoSwitch"]["HEALER"],
                    ["DAMAGER"] = CellDB["layoutAutoSwitch"]["DAMAGER"],
                }
                F.RemoveElementsExceptKeys(CellDB["layoutAutoSwitch"], "role", Cell.vars.playerClass)
            end
        end
    end

    -- r223-release
    if CellDB["revise"] and dbRevision < 223 then
        -- debuffBlacklist
        if not F.TContains(CellDB["debuffBlacklist"], 89798) then -- 大冒险家奖励
            tinsert(CellDB["debuffBlacklist"], 89798)
            Cell.vars.debuffBlacklist = F.ConvertTable(CellDB["debuffBlacklist"])
        end
    end

    -- r224-release
    if CellDB["revise"] and dbRevision < 224 then
        for _, layout in pairs(CellDB["layouts"]) do
            for i, t in pairs(layout["indicators"]) do
                -- update health text color option
                if t["indicatorName"] == "healthText" then
                    if #t["color"] == 3 then
                        t["color"] = {"custom_color", t["color"]}
                    end
                end

                -- add frameLevel to Color and Overlay
                if t["type"] == "color" or t["type"] == "overlay" then
                    if not t["frameLevel"] then
                        t["frameLevel"] = 1
                    end
                end
            end

            -- add power text indicator
            local index = Cell.defaults.indicatorIndices.powerText
            if layout["indicators"][index]["indicatorName"] ~= "powerText" then
                tinsert(layout["indicators"], index, {
                    ["name"] = "Power Text",
                    ["indicatorName"] = "powerText",
                    ["type"] = "built-in",
                    ["enabled"] = false,
                    ["position"] = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 3},
                    ["frameLevel"] = 2,
                    ["font"] = {"Cell ".._G.DEFAULT, 10, "Shadow"},
                    ["color"] = {"custom_color", {1, 1, 1}},
                    ["format"] = "number",
                    ["hideIfEmptyOrFull"] = true,
                })
            end
        end

        -- move "use LibHealComm" to snippetVars
        if not strfind(CellDB["snippets"][0]["code"], "CELL_USE_LIBHEALCOMM") then
            CellDB["snippets"][0]["code"] = CellDB["snippets"][0]["code"].."\n\n-- use LibHealComm (boolean, non-retail)\nCELL_USE_LIBHEALCOMM = false"
        end

        -- update overshield
        if type(CellDB["appearance"]["overshield"]) ~= "table" then
            local enabled = CellDB["appearance"]["overshield"] and true or false
            CellDB["appearance"]["overshield"] = {enabled, {CellDB["appearance"]["shield"][2][1], CellDB["appearance"]["shield"][2][2], CellDB["appearance"]["shield"][2][3], 1}}
        end

        -- disable snippets
        F.DisableSnippets()
    end

    -- r226-release
    if CellDB["revise"] and dbRevision < 226 then
        local function AddAlpha(t)
            local temp = {}
            temp[1] = t[1]
            temp[2] = t[5]
            temp[3] = {t[2], t[3], t[4], 1}
            return temp
        end

        local function AddAlpha2(t)
            local temp = {}
            temp[1] = t[4]
            temp[2] = {t[1], t[2], t[3], 1}
            return temp
        end

        local function AddAlpha3(t)
            local temp = {}
            temp[1] = t[1]
            temp[2] = t[6]
            temp[3] = {t[2], t[3], t[4], t[5]}
            return temp
        end

        for _, layout in pairs(CellDB["layouts"]) do
            for _, i in pairs(layout["indicators"]) do
                if i.indicatorName == "raidDebuffs" then
                    i.showDuration = true
                end

                -- separate "Shadow" from "Outline"
                if type(i.font) == "table" then
                    if type(i.font[1]) == "table" then
                        if type(i.font[1][4]) ~= "boolean" then
                            if string.find(i.font[1][3], "^Shadow") then
                                i.font[1][3] = "None"
                                tinsert(i.font[1], 4, true)
                            else
                                tinsert(i.font[1], 4, false)
                            end
                            if string.find(i.font[2][3], "^Shadow") then
                                i.font[2][3] = "None"
                                tinsert(i.font[2], 4, true)
                            else
                                tinsert(i.font[2], 4, false)
                            end
                        end
                    else
                        if type(i.font[4]) ~= "boolean" then
                            if string.find(i.font[3], "^Shadow") then
                                i.font[3] = "None"
                                tinsert(i.font, 4, true)
                            else
                                tinsert(i.font, 4, false)
                            end
                        end
                    end
                end

                -- add alpha to "colors"
                if i.colors then
                    if i.type == "text" then
                        if #i.colors[1] == 3 then
                            i.colors[1][4] = 1
                            i.colors[2] = AddAlpha(i.colors[2])
                            i.colors[3] = AddAlpha(i.colors[3])
                        end
                    elseif i.type == "rect" then
                        if #i.colors[1] == 3 then
                            i.colors[1][4] = 1
                            i.colors[2] = AddAlpha(i.colors[2])
                            i.colors[3] = AddAlpha(i.colors[3])
                            i.colors[4] = {0, 0, 0, 1}
                        end
                    elseif i.type == "bar" then
                        if #i.colors[1] == 3 then
                            i.colors[1][4] = 1
                            i.colors[2] = AddAlpha(i.colors[2])
                            i.colors[3] = AddAlpha(i.colors[3])
                            i.colors[5] = i.colors[4]
                            i.colors[4] = {0, 0, 0, 1}
                        end
                    elseif i.type == "color" then
                        if #i.colors[4] == 3 then
                            i.colors[4][4] = 1
                            i.colors[5] = AddAlpha2(i.colors[5])
                            i.colors[6] = AddAlpha2(i.colors[6])
                        end
                    elseif i.type == "overlay" then
                        if #i.colors[2] == 6 then
                            i.colors[2] = AddAlpha3(i.colors[2])
                            i.colors[3] = AddAlpha3(i.colors[3])
                        end
                    end
                end

                -- add frameLevel
                if i.indicatorName == "roleIcon" then
                    if not i.frameLevel then
                        i.frameLevel = 1
                    end
                end
            end
        end

        -- disable snippets
        F.DisableSnippets()
    end

    -- r227-release
    if CellDB["revise"] and dbRevision < 227 then
        if Cell.isRetail then
            -- QuickAssist: separate "Shadow" from "Outline"
            local function FixShadow(t)
                if type(t[4]) ~= "boolean" then
                    if string.find(t[3], "^Shadow") then
                        t[3] = "None"
                        tinsert(t, 4, true)
                    else
                        tinsert(t, 4, false)
                    end
                end
            end

            for _, t in pairs(CellDB["quickAssist"]) do
                FixShadow(t.style.name.font)
                FixShadow(t.spells.mine.icon.font[1])
                FixShadow(t.spells.mine.icon.font[2])
                FixShadow(t.spells.offensives.icon.font[1])
                FixShadow(t.spells.offensives.icon.font[2])
            end
        end
    end

    -- r228-release
    if CellDB["revise"] and dbRevision < 228 then
        if type(CellDB["appearance"]["overshieldReverseFill"]) ~= "boolean" then
            CellDB["appearance"]["overshieldReverseFill"] = CellDB["appearance"]["overshieldReverseFilling"] or false
            CellDB["appearance"]["overshieldReverseFilling"] = nil
        end

        for _, layout in pairs(CellDB["layouts"]) do
            for _, i in pairs(layout["indicators"]) do
                if i.type == "bar" or i.type == "rect" then
                    -- add duration font for Bar/Rect
                    if #i.font ~= 2 then
                        i.showDuration = false
                        if i.showStack then
                            local stackFont = i.font
                            i.font = {
                                stackFont,
                                {"Cell ".._G.DEFAULT, 11, "Outline", false, "RIGHT", -1, 0, {1, 1, 1}},
                            }
                        else
                            i.font = {
                                {"Cell ".._G.DEFAULT, 11, "Outline", false, "LEFT", 1, 0, {1, 1, 1}},
                                {"Cell ".._G.DEFAULT, 11, "Outline", false, "RIGHT", -1, 0, {1, 1, 1}},
                            }
                        end
                    end

                elseif i.type == "icons" then
                    -- add spacing for icons
                    if type(i.spacing) ~= "table" then
                        i.spacing = {0, 0}
                    end

                elseif i.indicatorName == "targetedSpells" then
                    if not i.num then
                        i.num = 1
                        i.orientation = "left-to-right"
                    end
                end
            end
        end

        -- update RaidDebuffs structure
        local indices = {"order", "trackByID", "condition", "glowType", "glowOptions", "glowCondition"}
        for instanceId, iTable in pairs(CellDB["raidDebuffs"]) do
            for bossId, bTable in pairs(iTable) do
                for spellId, sTable in pairs(bTable) do
                    if #sTable ~= 0 then
                        local old = F.Copy(sTable)
                        wipe(sTable)
                        for i, index in pairs(indices) do
                            sTable[index] = old[i]
                        end
                    end
                end
            end
        end

        -- add "solo" for layout auto switch
        if Cell.isRetail then
            for role, t in pairs(CellDB["layoutAutoSwitch"]) do
                for _, st in pairs(t) do
                    if not st.solo then st.solo = st.party end
                end
            end
        end
    end

    if CellCharacterDB and CellCharacterDB["revise"] and charaDbRevision < 229 then
        for _, t in pairs(CellCharacterDB["layoutAutoSwitch"]) do
            if not t.solo then t.solo = t.party end
        end
    end

    -- r230-beta
    if CellDB["revise"] and dbRevision < 230 then
        for _, layout in pairs(CellDB["layouts"]) do
            for _, i in pairs(layout["indicators"]) do
                if i.type == "color" then
                    -- limit frameLevel to 50
                    if i.frameLevel > 50 then
                        i.frameLevel = 50
                    end
                end
            end
        end

        -- CELL_COOLDOWN_STYLE
        if not strfind(CellDB["snippets"][0]["code"], "CELL_COOLDOWN_STYLE") then
            CellDB["snippets"][0]["code"] = CellDB["snippets"][0]["code"].."\n\n-- cooldown style for icon/block indicators (\"VERTICAL\", \"CLOCK\")\nCELL_COOLDOWN_STYLE = \"VERTICAL\""
        end

        -- disable snippets
        F.DisableSnippets()
    end

    -- r231-release
    if CellDB["revise"] and dbRevision < 231 then
        -- consumables -> actions
        if CellDB["consumables"] then
            CellDB["actions"] = CellDB["consumables"]
            CellDB["consumables"] = nil
        end
        for _, layout in pairs(CellDB["layouts"]) do
            for _, i in pairs(layout["indicators"]) do
                if i.indicatorName == "consumables" then
                    i.name = "Actions"
                    i.indicatorName = "actions"
                    break
                end
            end
        end

        -- click-castings macro -> macrotext
        if Cell.isRetail then
            for _, classT in pairs(CellDB["clickCastings"]) do
                for k, t in pairs(classT) do
                    if type(k) == "number" or k == "common" then
                        for _, binding in pairs(t) do
                            if binding[2] == "macro" and binding[3] and strfind(strtrim(binding[3]), "^[/#]") then
                                binding[2] = "custom"
                            end
                        end
                    end
                end
            end
        else
            for _, t in pairs(CellCharacterDB["clickCastings"]) do
                if type(k) == "number" or k == "common" then
                    for _, binding in pairs(t) do
                        if binding[2] == "macro" and binding[3] and strfind(strtrim(binding[3]), "^[/#]") then
                            binding[2] = "custom"
                        end
                    end
                end
            end
        end

        for _, layout in pairs(CellDB["layouts"]) do
            for _, i in pairs(layout["indicators"]) do
                if i.type == "block" then
                    -- update block, add "colorBy"
                    if #i.colors == 4 then
                        tinsert(i.colors, 1, "duration")
                    end

                elseif i.indicatorName == "dispels" then
                    -- update Dispels filters
                    if not i.filters then
                        i.filters = {
                            ["dispellableByMe"] = i.dispellableByMe,
                            ["Curse"] = true,
                            ["Disease"] = true,
                            ["Magic"] = true,
                            ["Poison"] = true,
                            ["Bleed"] = true,
                        }
                    end
                    i.dispellableByMe = nil
                end
            end
        end
    end

    -- r234-release
    if CellDB["revise"] and dbRevision < 234 then
        for _, layout in pairs(CellDB["layouts"]) do
            for _, i in pairs(layout["indicators"]) do
                if i.indicatorName == "readyCheckIcon" then
                    if not i.position then
                        i.position = {"CENTER", "CENTER", 0, 0}
                    end
                end

                if i.type == "overlay" then
                    if i.frameLevel > 50 then
                        i.frameLevel = 50
                    end
                end
            end
        end
    end

    -- r235-release
    if CellDB["revise"] and dbRevision < 235 then
        for _, layout in pairs(CellDB["layouts"]) do
            for _, i in pairs(layout["indicators"]) do
                if i.indicatorName == "statusText" then
                    if #i.position ~= 3 then
                        i.position[3] = "justify"
                    end
                end
            end
        end

        if #CellDB["appearance"]["gradientColors"] ~= 5 then
            CellDB["appearance"]["gradientColors"][4] = 0.05
            CellDB["appearance"]["gradientColors"][5] = 0.95
        end

        if type(CellDB["general"]["showRaid"]) ~= "boolean" then
            CellDB["general"]["showRaid"] = true
        end
    end

    -- r237-release
    if CellDB["revise"] and dbRevision < 237 then
        if not CellDB["appearance"]["gradientColorsLoss"] then
            CellDB["appearance"]["gradientColorsLoss"] = F.Copy(Cell.defaults.appearance.gradientColorsLoss)
        end

        if type(CellDB["general"]["framePriority"]) ~= "table" then
            CellDB["general"]["framePriority"] = {
                {"Main", true},
                {"Spotlight", false},
                {"Quick Assist", false},
            }
        end
    end

    -- r239-release
    if CellDB["revise"] and dbRevision < 239 then
        for _, layout in pairs(CellDB["layouts"]) do
            for _, i in pairs(layout["indicators"]) do
                if i.indicatorName == "dispels" then
                    if not i.iconStyle then
                        i.iconStyle = i.showDispelTypeIcons and "blizzard" or "none"
                        i.showDispelTypeIcons = nil
                    end
                end
            end
        end
    end
    ]=]

    -- r240-release
    if CellDB["revise"] and dbRevision < 240 then
        CellDB["general"]["alwaysUpdateAuras"] = CellDB["general"]["alwaysUpdateBuffs"] or CellDB["general"]["alwaysUpdateDebuffs"]
    end


    -- r241-release
    if CellDB["revise"] and dbRevision < 241 then
        if type(CellDB["nicknames"]["blacklist"]) ~= "table" then
            CellDB["nicknames"]["blacklist"] = {}
        end

        if type(CellDB["appearance"]["colorThresholds"]) ~= "table" then
            CellDB["appearance"]["colorThresholds"] = CellDB["appearance"]["gradientColors"]
            CellDB["appearance"]["gradientColors"] = nil
            tinsert(CellDB["appearance"]["colorThresholds"], true)
            CellDB["appearance"]["colorThresholdsLoss"] = CellDB["appearance"]["gradientColorsLoss"]
            CellDB["appearance"]["gradientColorsLoss"] = nil
            tinsert(CellDB["appearance"]["colorThresholdsLoss"], true)
        end

        if CellDB["appearance"]["barColor"][1] == "gradient" then
            CellDB["appearance"]["barColor"][1] = "threshold1"
        elseif CellDB["appearance"]["barColor"][1] == "gradient2" then
            CellDB["appearance"]["barColor"][1] = "threshold2"
        elseif CellDB["appearance"]["barColor"][1] == "gradient3" then
            CellDB["appearance"]["barColor"][1] = "threshold3"
        end

        if CellDB["appearance"]["lossColor"][1] == "gradient" then
            CellDB["appearance"]["lossColor"][1] = "threshold1"
        elseif CellDB["appearance"]["lossColor"][1] == "gradient2" then
            CellDB["appearance"]["lossColor"][1] = "threshold2"
        elseif CellDB["appearance"]["lossColor"][1] == "gradient3" then
            CellDB["appearance"]["lossColor"][1] = "threshold3"
        end
    end

    -- r243-release
    if CellDB["revise"] and dbRevision < 243 then
        if Cell.isRetail then
            local spells = {
                439506, -- 钻地冲击
                429545, -- 噤声齿轮
                424888, -- 震地猛击
                463248, -- 排斥
                321828, -- 拍手手
                323057, -- 灵魂之箭
                333479, -- 吐疫
                454438, -- 艾泽里特炸药
                272571, -- 窒息之水
                257063, -- 盐渍飞弹
                431491, -- 污邪斩击
                451119, -- 深渊轰击
                428711, -- 火成岩锤
                459210, -- 暗影爪击
                256709, -- 钢刃之歌
                434786, -- 蛛网箭
                451971, -- 熔岩之拳
                451224, -- 暗影烈焰笼罩
                451364, -- 残忍打击
                451261, -- 大地之箭
                449444, -- 熔火乱舞
                450100, -- 碾碎
                463217, -- 心能挥砍
            }
            for _, spell in pairs(spells) do
                if not F.TContains(CellDB["targetedSpellsList"], spell) then
                    tinsert(CellDB["targetedSpellsList"], spell)
                end
            end
            Cell.vars.targetedSpellsList = F.ConvertTable(CellDB["targetedSpellsList"])
        end

        for _, layout in pairs(CellDB["layouts"]) do
            for _, i in pairs(layout["indicators"]) do
                if i.type == "text" then
                    if not i.stack then
                        i.stack = {
                            true,
                            i.circledStackNums,
                        }
                        i.circledStackNums = nil
                    end
                end
            end
        end
    end

    -- r244-release
    if CellDB["revise"] and dbRevision < 244 then
        for _, layout in pairs(CellDB["layouts"]) do
            for i, t in pairs(layout["indicators"]) do
                if t.indicatorName == "healthText" then
                    layout["indicators"][i] = F.Copy(Cell.defaults.layout.indicators[Cell.defaults.indicatorIndices.healthText])
                elseif t.indicatorName == "powerText" then
                    if not t.filters then
                        t.filters = F.Copy(Cell.defaults.layout.indicators[Cell.defaults.indicatorIndices.powerText].filters)
                    end
                end

                -- position
                if t.position and #t.position == 4 then
                    local relativeTo
                    if t.indicatorName == "nameText" then
                        relativeTo = "healthBar"
                    elseif t.indicatorName == "shieldBar" then
                        relativeTo = nil
                    else
                        relativeTo = "button"
                    end
                    tinsert(t.position, 2, relativeTo)
                end
            end

            if Cell.isVanilla then
                layout["powerFilters"] = F.Copy(Cell.defaults.layout.powerFilters)
            end
        end

        -- disable snippets
        F.DisableSnippets()
    end

    -- r245-release
    if CellDB["revise"] and dbRevision < 245 then
        for _, layout in pairs(CellDB["layouts"]) do
            for _, i in pairs(layout["indicators"]) do
                if i.indicatorName == "healthText" then
                    if not i.format.health2 then
                        i.format.health1 = i.format.health
                        i.format.health2 = {
                            ["format"] = "none",
                            ["color"] = {"custom_color", {1, 1, 1}},
                            ["hideIfEmptyOrFull"] = false,
                            ["delimiter"] = " ",
                        }
                        i.format.health = nil
                    end
                end
            end
        end
    end

    -- r246-release
    if CellDB["revise"] and dbRevision < 246 then
        for _, layout in pairs(CellDB["layouts"]) do
            if type(layout.pet.soloEnabled) ~= "boolean" then
                layout.pet.soloEnabled = true
            end

            for _, i in pairs(layout["indicators"]) do
                if i.indicatorName == "defensiveCooldowns" or i.indicatorName == "externalCooldowns" or i.indicatorName == "allCooldowns"
                or i.type == "icon" or i.type == "icons" or i.type == "bar" or i.type == "bars"
                or i.type == "rect" or i.type == "block" or i.type == "blocks"then
                    if not i.glowOptions then
                        i.glowOptions = {"None", {0.95, 0.95, 0.32, 1}}
                    end
                end

                if i.type == "bar" or i.type == "bars" then
                    if type(i.maxValue) ~= "table" or #i.maxValue ~= 3 then
                        i.maxValue = {false, 10, true}
                    end
                end
            end
        end

        for instanceId, iTable in pairs(CellDB["raidDebuffs"]) do
            for bossId, bTable in pairs(iTable) do
                for spellId, sTable in pairs(bTable) do
                    if not sTable["glowTarget"] then
                        sTable["glowTarget"] = "button"
                    end
                end
            end
        end

        if strfind(CellDB["snippets"][0]["code"], "CELL_SHOW_RAID_PET_OWNER_NAME") then
            CellDB["snippets"][0]["code"] = CellDB["snippets"][0]["code"]:gsub("CELL_SHOW_RAID_PET_OWNER_NAME", "CELL_SHOW_GROUP_PET_OWNER_NAME")
            CellDB["snippets"][0]["code"] = CellDB["snippets"][0]["code"]:gsub("show raid pet owner name", "show group pet owner name")
        elseif not strfind(CellDB["snippets"][0]["code"], "CELL_SHOW_GROUP_PET_OWNER_NAME") then
            CellDB["snippets"][0]["code"] = CellDB["snippets"][0]["code"].."\n\n-- show group pet owner name (\"VEHICLE\", \"NAME\", nil)\nCELL_SHOW_GROUP_PET_OWNER_NAME = nil"
        end

        if not CellDB["tools"]["battleResTimer"] then
            CellDB["tools"]["battleResTimer"] = {CellDB["tools"]["showBattleRes"] and true or false, false, {}}
            CellDB["tools"]["showBattleRes"] = nil
        end
    end

    -- r247-release
    if CellDB["revise"] and dbRevision < 247 then
        CellDB["appearance"]["scale"] = 1
    end

    -- r250-release
    if CellDB["revise"] and dbRevision < 250 then
        for _, layout in pairs(CellDB["layouts"]) do
            for _, i in pairs(layout["indicators"]) do
                if i.type == "icons" then -- fix Healers
                    if not i.glowOptions then
                        i.glowOptions = {"None", {0.95, 0.95, 0.32, 1}}
                    end
                end
            end
        end

        if Cell.isRetail then
            -- 伤逝剧场
            if not F.TContains(CellDB["targetedSpellsList"], 342675) then -- 骨矛
                tinsert(CellDB["targetedSpellsList"], 342675)
            end
            if not F.TContains(CellDB["targetedSpellsList"], 320644) then -- 残酷连击
                tinsert(CellDB["targetedSpellsList"], 320644)
            end
            if not F.TContains(CellDB["targetedSpellsList"], 323515) then -- 仇恨打击
                tinsert(CellDB["targetedSpellsList"], 323515)
            end
            if not F.TContains(CellDB["targetedSpellsList"], 1217138) then -- 通灵箭
                tinsert(CellDB["targetedSpellsList"], 1217138)
            end

            -- 圣焰隐修院
            if not F.TContains(CellDB["targetedSpellsList"], 424414) then -- 贯穿护甲
                tinsert(CellDB["targetedSpellsList"], 424414)
            end
            if not F.TContains(CellDB["targetedSpellsList"], 427583) then -- 忏悔
                tinsert(CellDB["targetedSpellsList"], 427583)
            end
            if not F.TContains(CellDB["targetedSpellsList"], 447270) then -- 掷矛
                tinsert(CellDB["targetedSpellsList"], 447270)
            end
            if not F.TContains(CellDB["targetedSpellsList"], 448515) then -- 神圣审判
                tinsert(CellDB["targetedSpellsList"], 448515)
            end

            -- 暗焰裂口
            if not F.TContains(CellDB["targetedSpellsList"], 421277) then -- 暗焰之锄
                tinsert(CellDB["targetedSpellsList"], 421277)
            end
            if not F.TContains(CellDB["targetedSpellsList"], 427011) then -- 暗影冲击
                tinsert(CellDB["targetedSpellsList"], 427011)
            end
            if not F.TContains(CellDB["targetedSpellsList"], 422245) then -- 穿岩凿
                tinsert(CellDB["targetedSpellsList"], 422245)
            end
            if not F.TContains(CellDB["targetedSpellsList"], 422116) then -- 鲁莽冲锋
                tinsert(CellDB["targetedSpellsList"], 422116)
            end

            -- 燧酿酒庄
            if not F.TContains(CellDB["targetedSpellsList"], 432229) then -- 醉酿投
                tinsert(CellDB["targetedSpellsList"], 432229)
            end
            if not F.TContains(CellDB["targetedSpellsList"], 439031) then -- 干杯勾拳
                tinsert(CellDB["targetedSpellsList"], 439031)
            end
            if not F.TContains(CellDB["targetedSpellsList"], 436592) then -- 点钞大炮
                tinsert(CellDB["targetedSpellsList"], 436592)
            end
            if not F.TContains(CellDB["targetedSpellsList"], 440134) then -- 蜂蜜料汁
                tinsert(CellDB["targetedSpellsList"], 440134)
            end
        end
    end

    -- ----------------------------------------------------------------------- --
    --            update from old versions, validate all indicators            --
    -- ----------------------------------------------------------------------- --
    if CellDB["revise"] and CellDB["revise"] ~=  Cell.version then
        for layoutName, layout in pairs(CellDB["layouts"]) do
            local toValidate = F.Copy(Cell.defaults.indicatorIndices)
            local temp = {}

            -- built-ins
            for i, t in ipairs(layout["indicators"]) do
                local name = t["indicatorName"]
                local correctIndex = toValidate[name]

                if t["type"] == "built-in" and correctIndex then
                    F.Debug(layoutName, "CORRECT_FOUND", correctIndex, name)
                    temp[correctIndex] = t
                    -- remove validated
                    toValidate[name] = nil
                end
            end

            -- fix missing indicators
            for name, index in pairs(toValidate) do
                F.Debug(layoutName, "FIXED_MISSING", index, name)
                temp[index] = F.Copy(Cell.defaults.layout.indicators[index])
            end

            --? check again
            local maxKey = 0
            for i in pairs(temp) do
                maxKey = max(maxKey, i)
            end
            for i = 1, maxKey do
                if i <= Cell.defaults.builtIns then
                    if not temp[i] or i ~= Cell.defaults.indicatorIndices[temp[i]["indicatorName"]] then
                        F.Debug(layoutName, "RESET_WRONG", i, name)
                        temp[i] = F.Copy(Cell.defaults.layout.indicators[i])
                    end
                else
                    temp[i] = nil
                end
            end

            -- customs
            for i, t in pairs(layout["indicators"]) do
                if t["type"] ~= "built-in" then
                    tinsert(temp, t)
                end
            end

            layout["indicators"] = temp
        end
    end

    --! update custom indicator names
    for _, layout in pairs(CellDB["layouts"]) do
        local index = 1
        for i, t in ipairs(layout["indicators"]) do
            if t["type"] ~= "built-in" then
                t["indicatorName"] = "indicator"..index
                index = index + 1
            end
        end
    end

    CellDB["revise"] = Cell.version
    if CellCharacterDB then
        CellCharacterDB["revise"] = Cell.version
    end
end