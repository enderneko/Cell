local addonName, Cell = ...

-- number of built-in indicators
Cell.defaults.builtIns = 25

Cell.defaults.indicatorIndices = {
    ["nameText"] = 1,
    ["statusText"] = 2,
    ["healthText"] = 3,
    ["powerText"] = 4,
    ["healthThresholds"] = 5,
    ["statusIcon"] = 6,
    ["partyAssignmentIcon"] = 7,
    ["leaderIcon"] = 8,
    ["readyCheckIcon"] = 9,
    ["playerRaidIcon"] = 10,
    ["targetRaidIcon"] = 11,
    ["aggroBlink"] = 12,
    ["aggroBar"] = 13,
    ["aggroBorder"] = 14,
    ["aoeHealing"] = 15,
    ["externalCooldowns"] = 16,
    ["defensiveCooldowns"] = 17,
    ["allCooldowns"] = 18,
    ["dispels"] = 19,
    ["debuffs"] = 20,
    ["raidDebuffs"] = 21,
    ["targetedSpells"] = 22,
    ["targetCounter"] = 23,
    ["actions"] = 24,
    ["missingBuffs"] = 25,
}

Cell.defaults.layout = {
    -- ["syncWith"] = "layoutName",
    ["main"] = {
        ["combineGroups"] = false,
        ["sortByRole"] = false,
        ["roleOrder"] = {"TANK", "HEALER", "DAMAGER"},
        ["hideSelf"] = false,
        ["size"] = {66, 46},
        ["position"] = {},
        ["powerSize"] = 2,
        ["orientation"] = "vertical",
        ["anchor"] = "TOPLEFT",
        ["spacingX"] = 3,
        ["spacingY"] = 3,
        ["maxColumns"] = 8,
        ["unitsPerColumn"] = 5,
        ["groupSpacing"] = 0,
    },
    ["pet"] = {
        ["partyEnabled"] = true,
        ["raidEnabled"] = false,
        ["sameSizeAsMain"] = true,
        ["sameArrangementAsMain"] = true,
        ["size"] = {66, 46},
        ["position"] = {},
        ["powerSize"] = 2,
        ["orientation"] = "vertical",
        ["anchor"] = "TOPLEFT",
        ["spacingX"] = 3,
        ["spacingY"] = 3,
    },
    ["npc"] = {
        ["enabled"] = true,
        ["separate"] = false,
        ["sameSizeAsMain"] = true,
        ["sameArrangementAsMain"] = true,
        ["size"] = {66, 46},
        ["position"] = {},
        ["powerSize"] = 2,
        ["orientation"] = "vertical",
        ["anchor"] = "TOPLEFT",
        ["spacingX"] = 3,
        ["spacingY"] = 3,
    },
    ["spotlight"] = {
        ["enabled"] = false,
        ["hidePlaceholder"] = false,
        ["units"] = {},
        ["sameSizeAsMain"] = true,
        ["sameArrangementAsMain"] = true,
        ["size"] = {66, 46},
        ["position"] = {},
        ["powerSize"] = 2,
        ["orientation"] = "vertical",
        ["anchor"] = "TOPLEFT",
        ["spacingX"] = 3,
        ["spacingY"] = 3,
    },
    ["barOrientation"] = {"horizontal", false},
    ["groupFilter"] = {true, true, true, true, true, true, true, true},
    ["powerFilters"] = {
        ["DRUID"] = true,
        ["HUNTER"] = true,
        ["MAGE"] = true,
        ["PALADIN"] = true,
        ["PRIEST"] = true,
        ["ROGUE"] = true,
        ["SHAMAN"] = true,
        ["WARLOCK"] = true,
        ["WARRIOR"] = true,
        ["PET"] = true,
        ["VEHICLE"] = true,
        ["NPC"] = true,
    },
    ["indicators"] = {
        {
            ["name"] = "Name Text",
            ["indicatorName"] = "nameText",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["position"] = {"CENTER", "CENTER", 0, 0},
            ["frameLevel"] = 1,
            ["font"] = {"Cell ".._G.DEFAULT, 13, "None", true},
            ["color"] = {"custom_color", {1, 1, 1}},
            ["vehicleNamePosition"] = {"TOP", 0},
            ["textWidth"] = {"percentage", 0.75},
            ["showGroupNumber"] = false,
        }, -- 1
        {
            ["name"] = "Status Text",
            ["indicatorName"] = "statusText",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["position"] = {"BOTTOM", 0, "justify"},
            ["frameLevel"] = 30,
            ["font"] = {"Cell ".._G.DEFAULT, 11, "None", true},
            ["showTimer"] = true,
            ["showBackground"] = true,
            ["colors"] = {
                ["AFK"] = {1, 0.19, 0.19, 1},
                ["OFFLINE"] = {1, 0.19, 0.19, 1},
                ["DEAD"] = {1, 0.19, 0.19, 1},
                ["GHOST"] = {1, 0.19, 0.19, 1},
                ["FEIGN"] = {1, 1, 0.12, 1},
                ["DRINKING"] = {0.12, 0.75, 1, 1},
                ["PENDING"] = {1, 1, 0.12, 1},
                ["ACCEPTED"] = {0.12, 1, 0.12, 1},
                ["DECLINED"] = {1, 0.19, 0.19, 1},
            },
        }, -- 2
        {
            ["name"] = "Health Text",
            ["indicatorName"] = "healthText",
            ["type"] = "built-in",
            ["enabled"] = false,
            ["position"] = {"TOP", "CENTER", 0, -6},
            ["frameLevel"] = 2,
            ["font"] = {"Cell ".._G.DEFAULT, 10, "None", true},
            ["format"] = {
                ["health"] = {
                    ["format"] = "effective_percent",
                    ["color"] = {"custom_color", {1, 1, 1}},
                    ["hideIfEmptyOrFull"] = false,
                },
                ["shields"] = {
                    ["format"] = "none",
                    ["color"] = {"custom_color", {0, 1, 0}},
                    ["delimiter"] = "+",
                },
                ["healAbsorbs"] = {
                    ["format"] = "none",
                    ["color"] = {"custom_color", {1, 0, 0}},
                    ["delimiter"] = "-",
                },
            },
        }, -- 3
        {
            ["name"] = "Power Text",
            ["indicatorName"] = "powerText",
            ["type"] = "built-in",
            ["enabled"] = false,
            ["position"] = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 3},
            ["frameLevel"] = 2,
            ["font"] = {"Cell ".._G.DEFAULT, 10, "None", true},
            ["color"] = {"custom_color", {1, 1, 1}},
            ["format"] = "number",
            ["hideIfEmptyOrFull"] = true,
            ["filters"] = {
                ["DRUID"] = true,
                ["HUNTER"] = true,
                ["MAGE"] = true,
                ["PALADIN"] = true,
                ["PRIEST"] = true,
                ["ROGUE"] = true,
                ["SHAMAN"] = true,
                ["WARLOCK"] = true,
                ["WARRIOR"] = true,
                ["PET"] = true,
                ["VEHICLE"] = true,
                ["NPC"] = true,
            },
        }, -- 4
        {
            ["name"] = "Health Thresholds",
            ["indicatorName"] = "healthThresholds",
            ["type"] = "built-in",
            ["enabled"] = false,
            ["thickness"] = 1,
            ["thresholds"] = {
                {0.35, {1, 0, 0, 1}},
            },
        }, -- 5
        {
            ["name"] = "Status Icon",
            ["indicatorName"] = "statusIcon",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["position"] = {"TOP", "TOP", 0, -3},
            ["frameLevel"] = 10,
            ["size"] = {18, 18},
        }, -- 6
        {
            ["name"] = "Party Assignment Icon",
            ["indicatorName"] = "partyAssignmentIcon",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["position"] = {"TOPLEFT", "TOPLEFT", 1, -1},
            ["size"] = {11, 11},
        }, -- 7
        {
            ["name"] = "Leader Icon",
            ["indicatorName"] = "leaderIcon",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["hideInCombat"] = true,
            ["position"] = {"TOPLEFT", "TOPLEFT", 1, -10},
            ["size"] = {11, 11},
        }, -- 8
        {
            ["name"] = "Ready Check Icon",
            ["indicatorName"] = "readyCheckIcon",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["position"] = {"CENTER", "CENTER", 0, 0},
            ["frameLevel"] = 100,
            ["size"] = {16, 16},
        }, -- 9
        {
            ["name"] = "Raid Icon (player)",
            ["indicatorName"] = "playerRaidIcon",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["position"] = {"TOP", "TOP", 0, 3},
            ["frameLevel"] = 5,
            ["size"] = {14, 14},
            ["alpha"] = 0.77,
        }, -- 10
        {
            ["name"] = "Raid Icon (target)",
            ["indicatorName"] = "targetRaidIcon",
            ["type"] = "built-in",
            ["enabled"] = false,
            ["position"] = {"TOP", "TOP", -14, 3},
            ["frameLevel"] = 5,
            ["size"] = {14, 14},
            ["alpha"] = 0.77,
        }, -- 11
        {
            ["name"] = "Aggro (blink)",
            ["indicatorName"] = "aggroBlink",
            ["type"] = "built-in",
            ["enabled"] = false,
            ["position"] = {"TOPLEFT", "TOPLEFT", 0, 0},
            ["frameLevel"] = 7,
            ["size"] = {11, 11},
        }, -- 12
        {
            ["name"] = "Aggro (bar)",
            ["indicatorName"] = "aggroBar",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["position"] = {"BOTTOMLEFT", "TOPLEFT", 0, -1},
            ["frameLevel"] = 1,
            ["size"] = {20, 4},
        }, -- 13
        {
            ["name"] = "Aggro (border)",
            ["indicatorName"] = "aggroBorder",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["frameLevel"] = 3,
            ["thickness"] = 2,
        }, -- 14
        {
            ["name"] = "AoE Healing",
            ["indicatorName"] = "aoeHealing",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["height"] = 10,
            ["color"] = {1, 1, 0},
        }, -- 15
        {
            ["name"] = "External Cooldowns",
            ["indicatorName"] = "externalCooldowns",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["position"] = {"RIGHT", "RIGHT", 2, 5},
            ["frameLevel"] = 10,
            ["size"] = {12, 20},
            ["showDuration"] = false,
            ["showAnimation"] = true,
            ["num"] = 2,
            ["orientation"] = "right-to-left",
            ["font"] = {
                {"Cell ".._G.DEFAULT, 11, "Outline", false, "TOPRIGHT", 2, 1, {1, 1, 1}},
                {"Cell ".._G.DEFAULT, 11, "Outline", false, "BOTTOMRIGHT", 2, -1, {1, 1, 1}},
            },
        }, -- 16
        {
            ["name"] = "Defensive Cooldowns",
            ["indicatorName"] = "defensiveCooldowns",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["position"] = {"LEFT", "LEFT", -2, 5},
            ["frameLevel"] = 10,
            ["size"] = {12, 20},
            ["showDuration"] = false,
            ["showAnimation"] = true,
            ["num"] = 2,
            ["orientation"] = "left-to-right",
            ["font"] = {
                {"Cell ".._G.DEFAULT, 11, "Outline", false, "TOPRIGHT", 2, 1, {1, 1, 1}},
                {"Cell ".._G.DEFAULT, 11, "Outline", false, "BOTTOMRIGHT", 2, -1, {1, 1, 1}},
            },
        }, -- 17
        {
            ["name"] = "Externals + Defensives",
            ["indicatorName"] = "allCooldowns",
            ["type"] = "built-in",
            ["enabled"] = false,
            ["position"] = {"LEFT", "LEFT", -2, 5},
            ["frameLevel"] = 10,
            ["size"] = {12, 20},
            ["showDuration"] = false,
            ["showAnimation"] = true,
            ["num"] = 2,
            ["orientation"] = "left-to-right",
            ["font"] = {
                {"Cell ".._G.DEFAULT, 11, "Outline", false, "TOPRIGHT", 2, 1, {1, 1, 1}},
                {"Cell ".._G.DEFAULT, 11, "Outline", false, "BOTTOMRIGHT", 2, -1, {1, 1, 1}},
            },
        }, -- 18
        {
            ["name"] = "Dispels",
            ["indicatorName"] = "dispels",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["position"] = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 4},
            ["frameLevel"] = 15,
            ["size"] = {12, 12},
            ["filters"] = {
                ["dispellableByMe"] = true,
                ["Curse"] = true,
                ["Disease"] = true,
                ["Magic"] = true,
                ["Poison"] = true,
                ["Bleed"] = true,
            },
            ["highlightType"] = "gradient-half",
            ["iconStyle"] = "blizzard",
            ["orientation"] = "right-to-left",
        }, -- 19
        {
            ["name"] = "Debuffs",
            ["indicatorName"] = "debuffs",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["position"] = {"BOTTOMLEFT", "BOTTOMLEFT", 1, 4},
            ["frameLevel"] = 5,
            ["size"] = {{13, 13}, {17, 17}},
            ["showDuration"] = false,
            ["showAnimation"] = true,
            ["showTooltip"] = false,
            ["enableBlacklistShortcut"] = false,
            ["num"] = 3,
            ["font"] = {
                {"Cell ".._G.DEFAULT, 11, "Outline", false, "TOPRIGHT", 2, 1, {1, 1, 1}},
                {"Cell ".._G.DEFAULT, 11, "Outline", false, "BOTTOMRIGHT", 2, -1, {1, 1, 1}},
            },
            ["dispellableByMe"] = false,
            ["orientation"] = "left-to-right",
        }, -- 20
        {
            ["name"] = "Raid Debuffs",
            ["indicatorName"] = "raidDebuffs",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["position"] = {"CENTER", "CENTER", 0, 3},
            ["frameLevel"] = 20,
            ["size"] = {22, 22},
            ["border"] = 2,
            ["num"] = 1,
            ["showDuration"] = true,
            ["font"] = {
                {"Cell ".._G.DEFAULT, 11, "Outline", false, "TOPRIGHT", 2, 1, {1, 1, 1}},
                {"Cell ".._G.DEFAULT, 11, "Outline", false, "BOTTOMRIGHT", 2, -1, {1, 1, 1}},
            },
            ["onlyShowTopGlow"] = true,
            ["orientation"] = "left-to-right",
            ["showTooltip"] = false,
        }, -- 21
        {
            ["name"] = "Targeted Spells",
            ["indicatorName"] = "targetedSpells",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["showAllSpells"] = false,
            ["position"] = {"TOPLEFT", "TOPLEFT", -4, 4},
            ["frameLevel"] = 50,
            ["size"] = {20, 20},
            ["border"] = 2,
            ["num"] = 1,
            ["font"] = {"Cell ".._G.DEFAULT, 12, "Outline", false, "TOPRIGHT", 2, 1, {1, 1, 1}},
            ["orientation"] = "left-to-right",
        }, -- 22
        {
            ["name"] = "Target Counter",
            ["indicatorName"] = "targetCounter",
            ["type"] = "built-in",
            ["enabled"] = false,
            ["position"] = {"TOP", "TOP", 0, 5},
            ["frameLevel"] = 15,
            ["font"] = {"Cell ".._G.DEFAULT, 15, "Outline", false},
            ["color"] = {1, 0.1, 0.1},
            ["filters"] = {
                ["outdoor"] = false,
                ["pve"] = false,
                ["pvp"] = true,
            },
        }, -- 23
        {
            ["name"] = "Actions",
            ["indicatorName"] = "actions",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["speed"] = 1,
        }, -- 24
        {
            ["name"] = "Missing Buffs",
            ["indicatorName"] = "missingBuffs",
            ["type"] = "built-in",
            ["enabled"] = false,
            ["filters"] = {
                ["buffByMe"] = true,
                ["PWF"] = true,
                ["DS"] = true,
                ["SP"] = true,
                ["AB"] = true,
                ["MotW"] = true,
                ["BS"] = true,
                ["PALADIN"] = true,
            },
            ["position"] = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 4},
            ["frameLevel"] = 10,
            ["size"] = {13, 13},
            ["num"] = 3,
            ["orientation"] = "right-to-left",
        }, -- 25
    },
}

Cell.defaults.layoutAutoSwitch = {
    ["solo"] = "default",
    ["party"] = "default",
    ["raid_outdoor"] = "default",
    ["raid_instance"] = "default",
    ["arena"] = "default",
    ["battleground"] = "default",
}