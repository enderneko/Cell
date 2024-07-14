local _, Cell = ...
local F = Cell.funcs
local I = Cell.iFuncs

-------------------------------------------------
-- custom indicator
-------------------------------------------------
function I.GetDefaultCustomIndicatorTable(name, indicatorName, type, auraType)
    local t
    if type == "icon" then
        t = {
            ["name"] = name,
            ["indicatorName"] = indicatorName,
            ["type"] = type,
            ["enabled"] = true,
            ["position"] = {"TOPRIGHT", "TOPRIGHT", 0, 3},
            ["frameLevel"] = 5,
            ["size"] = {13, 13},
            ["font"] = {
                {"Cell " .. _G.DEFAULT, 11, "Outline", false, "TOPRIGHT", 2, 1, {1, 1, 1}},
                {"Cell " .. _G.DEFAULT, 11, "Outline", false, "BOTTOMRIGHT", 2, -1, {1, 1, 1}},
            },
            ["showStack"] = true,
            ["showDuration"] = false,
            ["showAnimation"] = true,
            ["auraType"] = auraType,
            ["auras"] = {},
        }
    elseif type == "text" then
        t = {
            ["name"] = name,
            ["indicatorName"] = indicatorName,
            ["type"] = type,
            ["enabled"] = true,
            ["position"] = {"TOPRIGHT", "TOPRIGHT", 0, 3},
            ["frameLevel"] = 5,
            ["font"] = {"Cell " .. _G.DEFAULT, 12, "Outline", false},
            ["colors"] = {{0, 1, 0, 1}, {false, 0.5, {1, 1, 0, 1}}, {false, 3, {1, 0, 0, 1}}},
            ["auraType"] = auraType,
            ["auras"] = {},
            ["duration"] = {
                true, -- show duration
                false, -- round up duration
                0, -- decimal
            },
            ["circledStackNums"] = false,
        }
    elseif type == "bar" then
        t = {
            ["name"] = name,
            ["indicatorName"] = indicatorName,
            ["type"] = type,
            ["enabled"] = true,
            ["position"] = {"BOTTOMRIGHT", "TOPRIGHT", 0, -1},
            ["frameLevel"] = 5,
            ["size"] = {18, 4},
            ["colors"] = {{0, 1, 0, 1}, {false, 0.5, {1, 1, 0, 1}}, {false, 3, {1, 0, 0, 1}}, {0, 0, 0, 1}, {0.07, 0.07, 0.07, 0.9}},
            ["orientation"] = "horizontal",
            ["font"] = {
                {"Cell " .. _G.DEFAULT, 11, "Outline", false, "LEFT", 1, 0, {1, 1, 1}},
                {"Cell " .. _G.DEFAULT, 11, "Outline", false, "RIGHT", -1, 0, {1, 1, 1}},
            },
            ["showStack"] = false,
            ["showDuration"] = false,
            ["auraType"] = auraType,
            ["auras"] = {},
        }
    elseif type == "rect" then
        t = {
            ["name"] = name,
            ["indicatorName"] = indicatorName,
            ["type"] = type,
            ["enabled"] = true,
            ["position"] = {"TOPRIGHT", "TOPRIGHT", 0, 2},
            ["frameLevel"] = 5,
            ["size"] = {11, 4},
            ["colors"] = {{0, 1, 0, 1}, {false, 0.5, {1, 1, 0, 1}}, {false, 3, {1, 0, 0, 1}}, {0, 0, 0, 1}},
            ["font"] = {
                {"Cell " .. _G.DEFAULT, 11, "Outline", false, "LEFT", 1, 0, {1, 1, 1}},
                {"Cell " .. _G.DEFAULT, 11, "Outline", false, "RIGHT", -1, 0, {1, 1, 1}},
            },
            ["showStack"] = false,
            ["showDuration"] = false,
            ["auraType"] = auraType,
            ["auras"] = {},
        }
    elseif type == "icons" then
        t = {
            ["name"] = name,
            ["indicatorName"] = indicatorName,
            ["type"] = type,
            ["enabled"] = true,
            ["position"] = {"TOPRIGHT", "TOPRIGHT", 0, 3},
            ["frameLevel"] = 5,
            ["size"] = {13, 13},
            ["num"] = 5,
            ["numPerLine"] = 5,
            ["orientation"] = "right-to-left",
            ["spacing"] = {0, 0},
            ["font"] = {
                {"Cell " .. _G.DEFAULT, 11, "Outline", false, "TOPRIGHT", 2, 1, {1, 1, 1}},
                {"Cell " .. _G.DEFAULT, 11, "Outline", false, "BOTTOMRIGHT", 2, -1, {1, 1, 1}},
            },
            ["showStack"] = true,
            ["showDuration"] = false,
            ["showAnimation"] = true,
            ["auraType"] = auraType,
            ["auras"] = {},
        }
    elseif type == "color" then
        t = {
            ["name"] = name,
            ["indicatorName"] = indicatorName,
            ["type"] = type,
            ["enabled"] = true,
            ["anchor"] = "healthbar-current",
            ["frameLevel"] = 1,
            ["colors"] = {"gradient-vertical", {1, 0, 0.4, 1}, {0, 0, 0, 1}, {0, 1, 0, 1}, {0.5, {1, 1, 0, 1}}, {3, {1, 0, 0, 1}}},
            ["auraType"] = auraType,
            ["auras"] = {},
        }
    elseif type == "texture" then
        t = {
            ["name"] = name,
            ["indicatorName"] = indicatorName,
            ["type"] = type,
            ["enabled"] = true,
            ["position"] = {"TOP", "TOP", 0, 0},
            ["size"] = {16, 16},
            ["frameLevel"] = 10,
            ["texture"] = {"Interface\\AddOns\\Cell\\Media\\Shapes\\circle_blurred.tga", 0, {1, 1, 1, 1}},
            ["auraType"] = auraType,
            ["auras"] = {},
            ["fadeOut"] = true,
        }
    elseif type == "glow" then
        t = {
            ["name"] = name,
            ["indicatorName"] = indicatorName,
            ["type"] = type,
            ["enabled"] = true,
            ["frameLevel"] = 1,
            ["auraType"] = auraType,
            ["auras"] = {},
            ["glowOptions"] = {"Pixel", {0.95, 0.95, 0.32, 1}, 9, 0.25, 8, 2},
            ["fadeOut"] = true,
        }
    elseif type == "overlay" then
        t = {
            ["name"] = name,
            ["indicatorName"] = indicatorName,
            ["type"] = type,
            ["enabled"] = true,
            ["smooth"] = false,
            ["frameLevel"] = 1,
            ["colors"] = {{0, 0.61, 1, 0.55}, {false, 0.5, {1, 1, 0, 0.5}}, {false, 3, {1, 0, 0, 0.5}}},
            ["orientation"] = "horizontal",
            ["auraType"] = auraType,
            ["auras"] = {},
        }
    elseif type == "block" then
        t = {
            ["name"] = name,
            ["indicatorName"] = indicatorName,
            ["type"] = type,
            ["enabled"] = true,
            ["position"] = {"TOPRIGHT", "TOPRIGHT", 0, 3},
            ["frameLevel"] = 5,
            ["size"] = {10, 10},
            ["colors"] = {"duration", {0, 1, 0, 1}, {false, 0.5, {1, 1, 0, 1}}, {false, 3, {1, 0, 0, 1}}, {0, 0, 0, 1}},
            ["font"] = {
                {"Cell " .. _G.DEFAULT, 11, "Outline", false, "TOPRIGHT", 2, 1, {1, 1, 1}},
                {"Cell " .. _G.DEFAULT, 11, "Outline", false, "BOTTOMRIGHT", 2, -1, {1, 1, 1}},
            },
            ["showStack"] = false,
            ["showDuration"] = false,
            ["auraType"] = auraType,
            ["auras"] = {},
        }
    elseif type == "blocks" then
        t = {
            ["name"] = name,
            ["indicatorName"] = indicatorName,
            ["type"] = type,
            ["enabled"] = true,
            ["position"] = {"TOPRIGHT", "TOPRIGHT", 0, 3},
            ["frameLevel"] = 5,
            ["size"] = {10, 10},
            ["num"] = 5,
            ["numPerLine"] = 5,
            ["orientation"] = "right-to-left",
            ["spacing"] = {0, 0},
            ["font"] = {
                {"Cell " .. _G.DEFAULT, 11, "Outline", false, "TOPRIGHT", 2, 1, {1, 1, 1}},
                {"Cell " .. _G.DEFAULT, 11, "Outline", false, "BOTTOMRIGHT", 2, -1, {1, 1, 1}},
            },
            ["showStack"] = false,
            ["showDuration"] = false,
            ["auraType"] = auraType,
            ["auras"] = {},
        }
    end

    if auraType == "buff" then
        t["castBy"] = "me"
        if Cell.isRetail then
            t["trackByName"] = false
        else
            t["trackByName"] = true
        end
    end

    return t
end

-------------------------------------------------
-- dispels: custom debuff type color
-------------------------------------------------
function I.GetDebuffTypeColor(debuffType)
    if debuffType and CellDB["debuffTypeColor"][debuffType] then
        return CellDB["debuffTypeColor"][debuffType]["r"], CellDB["debuffTypeColor"][debuffType]["g"],
            CellDB["debuffTypeColor"][debuffType]["b"]
    else
        return 0, 0, 0
    end
end

function I.SetDebuffTypeColor(debuffType, r, g, b)
    if debuffType and CellDB["debuffTypeColor"][debuffType] then
        CellDB["debuffTypeColor"][debuffType]["r"] = r
        CellDB["debuffTypeColor"][debuffType]["g"] = g
        CellDB["debuffTypeColor"][debuffType]["b"] = b
    end
end

function I.ResetDebuffTypeColor()
    -- copy
    CellDB["debuffTypeColor"] = F:Copy(DebuffTypeColor)
    -- add Bleed
    CellDB["debuffTypeColor"]["Bleed"] = {r = 1, g = 0.2, b = 0.6}
    -- add cleu
    -- CellDB["debuffTypeColor"].cleu = {r=0, g=1, b=1}
end