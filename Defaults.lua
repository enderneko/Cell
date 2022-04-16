local addonName, Cell = ...

-- number of built-in indicators
Cell.defaults.builtIns = 23

Cell.defaults.layout = {
    ["size"] = {66, 46},
    ["petSize"] = {false, 66, 46},
    ["position"] = {},
    ["powerSize"] = 2,
    ["spacing"] = 3,
    ["orientation"] = "vertical",
    ["barOrientation"] = {"horizontal", false},
    ["anchor"] = "TOPLEFT",
    ["columns"] = 8,
    ["rows"] = 8,
    ["groupSpacing"] = 0,
    ["groupFilter"] = {true, true, true, true, true, true, true, true},
    ["friendlyNPC"] = {true, false, {}},
    ["powerFilters"] = {
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
    },
    ["indicators"] = {
        {
            ["name"] = "Name Text",
            ["indicatorName"] = "nameText",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["position"] = {"CENTER", "CENTER", 0, 0},
            ["font"] = {"Cell ".._G.DEFAULT, 13, "Shadow"},
            ["nameColor"] = {"Custom Color", {1, 1, 1}},
            ["vehicleNamePosition"] = {"TOP", 0},
            ["textWidth"] = {"percentage", 0.75},
        }, -- 1
        {
            ["name"] = "Status Text",
            ["indicatorName"] = "statusText",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["position"] = {"BOTTOM", 0},
            ["frameLevel"] = 30,
            ["font"] = {"Cell ".._G.DEFAULT, 11, "Shadow"},
            ["colors"] = {
                ["AFK"] = {1, 0.19, 0.19},
                ["OFFLINE"] = {1, 0.19, 0.19},
                ["DEAD"] = {1, 0.19, 0.19},
                ["GHOST"] = {1, 0.19, 0.19},
                ["FEIGN"] = {1, 1, 0.12},
                ["DRINKING"] = {0.12, 0.75, 1},
                ["PENDING"] = {1, 1, 0.12},
                ["ACCEPTED"] = {0.12, 1, 0.12},
                ["DECLINED"] = {1, 0.19, 0.19},
            },
        }, -- 2
        {
            ["name"] = "Health Text",
            ["indicatorName"] = "healthText",
            ["type"] = "built-in",
            ["enabled"] = false,
            ["position"] = {"TOP", "CENTER", 0, -5},
            ["frameLevel"] = 2,
            ["font"] = {"Cell ".._G.DEFAULT, 10, "Shadow"},
            ["color"] = {1, 1, 1},
            ["format"] = "percentage",
            ["hideFull"] = true,
        }, -- 3
        {
            ["name"] = "Status Icon",
            ["indicatorName"] = "statusIcon",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["position"] = {"TOP", "TOP", 0, -3},
            ["frameLevel"] = 10,
            ["size"] = {18, 18},
        }, -- 4
        {
            ["name"] = "Role Icon",
            ["indicatorName"] = "roleIcon",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["position"] = {"TOPLEFT", "TOPLEFT", 0, 0},
            ["size"] = {11, 11},
            ["customTextures"] = {false, "Interface\\AddOns\\ElvUI\\Core\\Media\\Textures\\Tank.tga", "Interface\\AddOns\\ElvUI\\Core\\Media\\Textures\\Healer.tga", "Interface\\AddOns\\ElvUI\\Core\\Media\\Textures\\DPS.tga"},
        }, -- 5
        {
            ["name"] = "Leader Icon",
            ["indicatorName"] = "leaderIcon",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["position"] = {"TOPLEFT", "TOPLEFT", 0, -11},
            ["size"] = {11, 11},
        }, -- 6
        {
            ["name"] = "Ready Check Icon",
            ["indicatorName"] = "readyCheckIcon",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["frameLevel"] = 100,
            ["size"] = {16, 16},
        }, -- 7
        {
            ["name"] = "Raid Icon (player)",
            ["indicatorName"] = "playerRaidIcon",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["position"] = {"TOP", "TOP", 0, 3},
            ["frameLevel"] = 2,
            ["size"] = {14, 14},
            ["alpha"] = .77,
        }, -- 8
        {
            ["name"] = "Raid Icon (target)",
            ["indicatorName"] = "targetRaidIcon",
            ["type"] = "built-in",
            ["enabled"] = false,
            ["position"] = {"TOP", "TOP", -14, 3},
            ["frameLevel"] = 2,
            ["size"] = {14, 14},
            ["alpha"] = .77,
        }, -- 9
        {
            ["name"] = "Aggro (blink)",
            ["indicatorName"] = "aggroBlink",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["position"] = {"TOPLEFT", "TOPLEFT", 0, 0},
            ["frameLevel"] = 3,
            ["size"] = {10, 10},
        }, -- 10
        {
            ["name"] = "Aggro (bar)",
            ["indicatorName"] = "aggroBar",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["position"] = {"BOTTOMLEFT", "TOPLEFT", 1, 0},
            ["frameLevel"] = 1,
            ["size"] = {18, 2},
        }, -- 11
        {
            ["name"] = "Aggro (border)",
            ["indicatorName"] = "aggroBorder",
            ["type"] = "built-in",
            ["enabled"] = false,
            ["frameLevel"] = 1,
            ["thickness"] = 3,
        }, -- 12
        {
            ["name"] = "Shield Bar",
            ["indicatorName"] = "shieldBar",
            ["type"] = "built-in",
            ["enabled"] = false,
            ["position"] = {"BOTTOMLEFT", "BOTTOMLEFT", 0, 0},
            ["frameLevel"] = 2,
            ["height"] = 4,
            ["color"] = {1, 1, 0, 1},
        }, -- 13
        {
            ["name"] = "AoE Healing",
            ["indicatorName"] = "aoeHealing",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["height"] = 15,
            ["color"] = {1, 1, 0},
        }, -- 14
        {
            ["name"] = "External Cooldowns",
            ["indicatorName"] = "externalCooldowns",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["position"] = {"RIGHT", "RIGHT", 2, 5},
            ["frameLevel"] = 10,
            ["size"] = {12, 20},
            ["showDuration"] = false,
            ["num"] = 2,
            ["orientation"] = "right-to-left",
            ["font"] = {"Cell ".._G.DEFAULT, 11, "Outline", 2},
        }, -- 15
        {
            ["name"] = "Defensive Cooldowns",
            ["indicatorName"] = "defensiveCooldowns",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["position"] = {"LEFT", "LEFT", -2, 5},
            ["frameLevel"] = 10,
            ["size"] = {12, 20},
            ["showDuration"] = false,
            ["num"] = 2,
            ["orientation"] = "left-to-right",
            ["font"] = {"Cell ".._G.DEFAULT, 11, "Outline", 2},
        }, -- 16
        {
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
        }, -- 17
        {
            ["name"] = "Tank Active Mitigation",
            ["indicatorName"] = "tankActiveMitigation",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["position"] = {"TOPLEFT", "TOPLEFT", 10, -1},
            ["frameLevel"] = 2,
            ["size"] = {18, 4},
        }, -- 18
        {
            ["name"] = "Dispels",
            ["indicatorName"] = "dispels",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["position"] = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 4},
            ["frameLevel"] = 15,
            ["size"] = {12, 12},
            ["dispellableByMe"] = true,
            ["enableHighlight"] = true,
        }, -- 19
        {
            ["name"] = "Debuffs",
            ["indicatorName"] = "debuffs",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["position"] = {"BOTTOMLEFT", "BOTTOMLEFT", 1, 4},
            ["frameLevel"] = 2,
            ["size"] = {{13, 13}, {17, 17}},
            ["showDuration"] = false,
            ["num"] = 3,
            ["font"] = {"Cell ".._G.DEFAULT, 11, "Outline", 2},
            ["dispellableByMe"] = false,
            ["orientation"] = "left-to-right",
            ["bigDebuffs"] = {
                240443, -- 爆裂
                209858, -- 死疽溃烂
                46392, -- 专注打击
                -----------------------------------------------
                -- NOTE: Encrypted Affix - Shadowlands Season 3
                -- 尤型拆卸者
                366297, -- 解构
                366288, -- 猛力砸击
                -----------------------------------------------
                -----------------------------------------------
                -- NOTE: Tormented Affix - Shadowlands Season 2
                -- 焚化者阿寇拉斯
                -- 355732, -- 融化灵魂
                -- 355738, -- 灼热爆破
                -- 凇心之欧罗斯
                -- 356667, -- 刺骨之寒
                -- 刽子手瓦卢斯
                -- 356925, -- 屠戮
                -- 356923, -- 撕裂
                -- 358973, -- 恐惧浪潮
                -- 粉碎者索苟冬
                -- 355806, -- 重压
                -- 358777, -- 痛苦之链
                -----------------------------------------------
            },
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
            ["font"] = {"Cell ".._G.DEFAULT, 11, "Outline", 2},
            -- ["durationFont"] = {true, "Cell ".._G.DEFAULT, 11, "Outline", "RIGHT", 2, 0},
            -- ["stackFont"] = {"Cell ".._G.DEFAULT, 11, "Outline", "RIGHT", 2, 0},
            ["onlyShowTopGlow"] = true,
            ["orientation"] = "left-to-right",
        }, -- 21
        {
            ["name"] = "Targeted Spells",
            ["indicatorName"] = "targetedSpells",
            ["type"] = "built-in",
            ["enabled"] = true,
            ["position"] = {"CENTER", "TOPLEFT", 7, -7},
            ["frameLevel"] = 50,
            ["size"] = {20, 20},
            ["border"] = 2,
            ["spells"] = {
                320788, -- 冻结之缚
                344496, -- 震荡爆发
                319941, -- 碎石之跃
                322614, -- 心灵连接
                320132, -- 暗影之怒
                334053, -- 净化冲击波
                320596, -- 深重呕吐
                356924, -- 屠戮
                356666, -- 刺骨之寒
                319713, -- 巨兽奔袭
                338606, -- 病态凝视
                343556, -- 病态凝视
                324079, -- 收割之镰
                317963, -- 知识烦扰
                333861, -- 回旋利刃
                -- 328429, -- 窒息勒压
            },
            ["glow"] = {"Pixel", {0.95,0.95,0.32,1}, 9, .25, 8, 2},
            ["font"] = {"Cell ".._G.DEFAULT, 12, "Outline", 2},
        }, -- 22
        {
            ["name"] = "Target Counter",
            ["indicatorName"] = "targetCounter",
            ["type"] = "built-in",
            ["enabled"] = false,
            ["position"] = {"TOP", "TOP", 0, 5},
            ["frameLevel"] = 15,
            ["font"] = {"Cell ".._G.DEFAULT, 15, "Outline"},
            ["color"] = {1, .1, .1},
        }, -- 23
    },
}