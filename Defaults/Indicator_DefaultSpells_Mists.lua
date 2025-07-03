local _, Cell = ...
local L = Cell.L
local I = Cell.iFuncs
local F = Cell.funcs

-------------------------------------------------
-- dispelBlacklist
-------------------------------------------------
-- suppress dispel highlight
local dispelBlacklist = {}

function I.GetDefaultDispelBlacklist()
    return dispelBlacklist
end

-------------------------------------------------
-- debuffBlacklist
-------------------------------------------------
local debuffBlacklist = {
    8326, -- 鬼魂
    57723, -- 筋疲力尽
    57724, -- 心满意足
}

function I.GetDefaultDebuffBlacklist()
    -- local temp = {}
    -- for i, id in pairs(debuffBlacklist) do
    --     temp[i] = F.GetSpellInfo(id)
    -- end
    -- return temp
    return debuffBlacklist
end

-------------------------------------------------
-- bigDebuffs
-------------------------------------------------
local bigDebuffs = {
}

function I.GetDefaultBigDebuffs()
    return bigDebuffs
end

-------------------------------------------------
-- aoeHealings
-------------------------------------------------
local aoeHealings = {
    ["DRUID"] = {
        [740] = true, -- 宁静
        [81269] = true, -- 百花齐放
        [102792] = true, -- 野性蘑菇：绽放
    },

    ["MONK"] = {
        [132463] = true, -- 真气波
        [130654] = true, -- 真气爆裂
        [115310] = true, -- 还魂术
        [126890] = true, -- 龙威显赫
        [124101] = true, -- 禅意珠：爆炸
        [115464] = true, -- 疗伤珠（消失时：135914）
        [117640] = true, -- 神鹤引项踢
        [116670] = true, -- 振魂引
    },

    ["PALADIN"] = {
        [85222] = true, -- 黎明圣光
        [82327] = true, -- 圣光普照
        [114165] = true, -- 神圣棱镜
        [119952] = true, -- 弧形圣光
    },

    ["PRIEST"] = {
        [120517] = true, -- 光晕
        [110744] = true, -- 神圣之星
        [121135] = true, -- 瀑流
        [23455] = true, -- 神圣新星
        [88686] = true, -- 圣言术：佑
        [596] = true, -- 治疗祷言
        [64843] = true, -- 神圣赞美诗
        [34861] = true, -- 治疗之环
        [15290] = true, -- 吸血鬼的拥抱
    },

    ["SHAMAN"] = {
        [1064] = true, -- 治疗链
        [73921] = true, -- 治疗之雨
        [114942] = true, -- 治疗之潮图腾
        [52042] = true, -- 治疗之泉图腾
    },
}

function I.GetAoEHealings()
    return aoeHealings
end

local builtInAoEHealings = {}
local customAoEHealings = {}

function I.UpdateAoEHealings(t)
    -- user disabled
    wipe(builtInAoEHealings)
    for class, spells in pairs(aoeHealings) do
        for id, trackByName in pairs(spells) do
            if not t["disabled"][id] then -- not disabled
                if trackByName then
                    local name = F.GetSpellInfo(id)
                    if name then
                        builtInAoEHealings[name] = true
                    end
                else
                    builtInAoEHealings[id] = true
                end
            end
        end
    end

    -- user created
    wipe(customAoEHealings)
    for _, id in pairs(t["custom"]) do
        customAoEHealings[id] = true
    end
end

function I.IsAoEHealing(name, id)
    return builtInAoEHealings[name] or builtInAoEHealings[id] or customAoEHealings[id]
end

local summonDuration = {

}

do
    local temp = {}
    for id, duration in pairs(summonDuration) do
        temp[F.GetSpellInfo(id)] = duration
    end
    summonDuration = temp
end

function I.GetSummonDuration(spellName)
    return summonDuration[spellName]
end

-------------------------------------------------
-- externalCooldowns
-------------------------------------------------
local externals = { -- true: track by name, false: track by id
    ["DEATHKNIGHT"] = {
        [51052] = true, -- 反魔法领域
    },

    ["DRUID"] = {
        [102342] = true, -- 铁木树皮
    },

    ["MONK"] = {
        [116849] = true, -- 作茧缚命
        [115213] = true, -- 慈悲庇护
    },

    ["PALADIN"] = {
        [1022] = true, -- 保护之手
        [6940] = true, -- 牺牲之手
        [1038] = true, -- 拯救之手
        [31821] = true, -- 虔诚光环
    },

    ["PRIEST"] = {
        [33206] = true, -- 痛苦压制
        [47788] = true, -- 守护之魂
        [62618] = true, -- 真言术：障
    },

    ["ROGUE"] = {
        [114018] = true, -- 潜伏帷幕
    },

    ["SHAMAN"] = {
        [98007] = true, -- 灵魂链接图腾
        [8178] = true, -- 根基图腾
    },

    ["WARRIOR"] = {
        [97463] = true, -- 集结呐喊
        [147833] = true, -- 援护
        [46947] = true, -- 捍卫
        [114028] = true, -- 群体反射
    },
}

function I.GetExternals()
    return externals
end

local builtInExternals = {}
local customExternals = {}

local function UpdateExternals(id, trackByName)
    if trackByName then
        local name = F.GetSpellInfo(id)
        if name then
            builtInExternals[name] = true
        end
    else
        builtInExternals[id] = true
    end
end

function I.UpdateExternals(t)
    -- user disabled
    wipe(builtInExternals)
    for class, spells in pairs(externals) do
        for id, v in pairs(spells) do
            if not t["disabled"][id] then -- not disabled
                if type(v) == "table" then
                    builtInExternals[id] = true -- for I.IsExternalCooldown()
                    for subId, subTrackByName in pairs(v) do
                        UpdateExternals(subId, subTrackByName)
                    end
                else
                    UpdateExternals(id, v)
                end
            end
        end
    end

    -- user created
    wipe(customExternals)
    for _, id in pairs(t["custom"]) do
        -- local name = F.GetSpellInfo(id)
        -- if name then
        --     customExternals[name] = true
        -- end
        customExternals[id] = true
    end
end

local UnitIsUnit = UnitIsUnit
local bos = F.GetSpellInfo(6940) -- 牺牲祝福
function I.IsExternalCooldown(name, id, source, target)
    if name == bos then
        if source and target then
            -- NOTE: hide bos on caster
            return not UnitIsUnit(source, target)
        else
            return true
        end
    else
        return builtInExternals[name] or builtInExternals[id] or customExternals[id]
    end
end

-------------------------------------------------
-- defensiveCooldowns
-------------------------------------------------
local defensives = { -- true: track by name, false: track by id
    ["DEATHKNIGHT"] = {
        [48707] = true, -- 反魔法护罩
        [48792] = true, -- 冰封之韧
        [49028] = true, -- 符文刃舞
        [55233] = true, -- 吸血鬼之血
        [49039] = false, -- 巫妖之躯
    },

    ["DRUID"] = {
        [22812] = true, -- 树皮术
        [61336] = true, -- 生存本能
        [106922] = true, -- 乌索克之力
    },

    ["HUNTER"] = {
        [19263] = true, -- 威慑
    },

    ["MAGE"] = {
        [45438] = true, -- 寒冰屏障
        [113862] = false, -- 强化隐形术
        [108978] = true, -- 操控时间
        [115610] = true, -- 时光护盾
    },

    ["MONK"] = {
        [131523] = false, -- 禅悟冥想
        [115203] = true, -- 壮胆酒
        [122278] = true, -- 躯不坏
        [122783] = true, -- 散魔功
        [125174] = true, -- 业报之触
    },

    ["PALADIN"] = {
        [498] = true, -- 圣佑术
        [642] = true, -- 圣盾术
        [31850] = true, -- 炽热防御者
        [86659] = false, -- 远古列王守卫
    },

    ["PRIEST"] = {
        [47585] = true, -- 消散
        [27827] = true, -- 救赎之魂
    },

    ["ROGUE"] = {
        [1966] = true, -- 佯攻
        [5277] = true, -- 闪避
        [31224] = false, -- 暗影斗篷
        [73651] = true, -- 复原
    },

    ["SHAMAN"] = {
        [114893] = true, -- 石壁
        [108271] = true, -- 星界转移
    },

    ["WARLOCK"] = {
        [104773] = true, -- 不灭决心
        [108359] = true, -- 黑暗再生
    },

    ["WARRIOR"] = {
        [871] = true, -- 盾墙
        [12975] = true, -- 破釜沉舟
        [23920] = true, -- 法术反射
        [118038] = true, -- 剑在人在
        [55694] = true, -- 狂怒回复
    },
}

function I.GetDefensives()
    return defensives
end

local builtInDefensives = {}
local customDefensives = {}

function I.UpdateDefensives(t)
    -- user disabled
    wipe(builtInDefensives)
    for class, spells in pairs(defensives) do
        for id, trackByName in pairs(spells) do
            if not t["disabled"][id] then -- not disabled
                if trackByName then
                    local name = F.GetSpellInfo(id)
                    if name then
                        builtInDefensives[name] = true
                    end
                else
                    builtInDefensives[id] = true
                end
            end
        end
    end

    -- user created
    wipe(customDefensives)
    for _, id in pairs(t["custom"]) do
        -- local name = F.GetSpellInfo(id)
        -- if name then
        --     customDefensives[name] = true
        -- end
        customDefensives[id] = true
    end
end

function I.IsDefensiveCooldown(name, id)
    return builtInDefensives[name] or builtInDefensives[id] or customDefensives[id]
end

-------------------------------------------------
-- tankActiveMitigation
-------------------------------------------------
local tankActiveMitigations = {
    -- death knight
    49222, -- 白骨之盾

    -- druid
    62606, -- 野蛮防御

    -- monk
    115308, -- 飘渺酒

    -- paladin
    132403, -- 正义盾击

    -- warrior
    132404, -- 盾牌格挡
}

local tankActiveMitigationNames = {
    -- death knight
    F.GetClassColorStr("DEATHKNIGHT")..F.GetSpellInfo(49222).."|r", -- 白骨之盾

    -- druid
    F.GetClassColorStr("DRUID")..F.GetSpellInfo(62606).."|r", -- 野蛮防御

    -- monk
    F.GetClassColorStr("MONK")..F.GetSpellInfo(115308).."|r", -- 飘渺酒

    -- paladin
    F.GetClassColorStr("PALADIN") .. F.GetSpellInfo(132403) .. "|r", -- 正义盾击

    -- warrior
    F.GetClassColorStr("WARRIOR") .. F.GetSpellInfo(132404) .. "|r", -- 盾牌格挡
}

do
    local temp = {}
    for _, id in pairs(tankActiveMitigations) do
        -- temp[F.GetSpellInfo(id)] = true
        temp[id] = true
    end
    tankActiveMitigations = temp
end

function I.IsTankActiveMitigation(spellId)
    return tankActiveMitigations[spellId]
end

function I.GetTankActiveMitigationString()
    return table.concat(tankActiveMitigationNames, ", ") .. "."
end

-------------------------------------------------
-- dispels
-------------------------------------------------
local dispellable = {}

function I.CanDispel(dispelType)
    if not dispelType then return end
    return dispellable[dispelType]
end

local specDispellables = {
    -- DRUID ----------------
    -- 102 - Balance
    [102] = {["Curse"] = true, ["Poison"] = true},
    -- 103 - Feral
    [103] = {["Curse"] = true, ["Poison"] = true},
    -- 104 - Guardian
    [104] = {["Curse"] = true, ["Poison"] = true},
    -- Restoration
    [105] = {["Curse"] = true, ["Magic"] = true, ["Poison"] = true},
    -------------------------

    -- MAGE -----------------
    -- 62 - Arcane
    [62] = {["Curse"] = true},
    -- 63 - Fire
    [63] = {["Curse"] = true},
    -- 64 - Frost
    [64] = {["Curse"] = true},
    -------------------------

    -- MONK -----------------
    -- 268 - Brewmaster
    [268] = {["Disease"] = true, ["Poison"] = true},
    -- 269 - Windwalker
    [269] = {["Disease"] = true, ["Poison"] = true},
    -- 270 - Mistweaver
    [270] = {["Disease"] = true, ["Magic"] = true, ["Poison"] = true},
    -------------------------

    -- PALADIN --------------
    -- 65 - Holy
    [65] = {["Disease"] = true, ["Magic"] = true, ["Poison"] = true, ["Bleed"] = true},
    -- 66 - Protection
    [66] = {["Disease"] = true, ["Poison"] = true, ["Bleed"] = true},
    -- 70 - Retribution
    [70] = {["Disease"] = true, ["Poison"] = true, ["Bleed"] = true},
    -------------------------

    -- PRIEST ---------------
    -- 256 - Discipline
    [256] = {["Disease"] = true, ["Magic"] = true},
    -- 257 - Holy
    [257] = {["Disease"] = true, ["Magic"] = true},
    -- 258 - Shadow
    [258] = {["Magic"] = true},
    -------------------------

    -- SHAMAN ---------------
    -- 262 - Elemental
    [262] = {["Curse"] = true},
    -- 263 - Enhancement
    [263] = {["Curse"] = true},
    -- 264 - Restoration
    [264] = {["Curse"] = true, ["Magic"] = true},
    -------------------------

    -- WARLOCK --------------
    -- 265 - Affliction
    -- [265] = {["Magic"] = function() return IsSpellKnown(89808, true) end},
    -- 266 - Demonology
    -- [266] = {["Magic"] = function() return IsSpellKnown(89808, true) end},
    -- 267 - Destruction
    -- [267] = {["Magic"] = function() return IsSpellKnown(89808, true) end},
    -------------------------
}

local eventFrame = CreateFrame("Frame")
--Whenever anything is committed to the configID, e.g. when saving talents, switching talent loadouts, spending profession points, etc

if UnitClassBase("player") == "WARLOCK" then
    eventFrame:RegisterEvent("UNIT_PET")

    local timer
    eventFrame:SetScript("OnEvent", function(self, event, unit)
        if unit ~= "player" then return end

        if timer then
            timer:Cancel()
        end
        timer = C_Timer.NewTimer(1, function()
            -- update dispellable
            dispellable["Magic"] = IsSpellKnown(89808, true)
            -- texplore(dispellable)
        end)
    end)
else
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

    local GetSpecialization = C_SpecializationInfo.GetSpecialization
    local GetSpecializationInfo = C_SpecializationInfo.GetSpecializationInfo

    local function UpdateDispellable()
        local specId = GetSpecializationInfo(GetSpecialization())
        dispellable = specDispellables[specId] or {}
        -- texplore(dispellable)
    end

    local timer

    eventFrame:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_ENTERING_WORLD" then
            eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
        end

        if timer then timer:Cancel() end
        timer = C_Timer.NewTimer(1, UpdateDispellable)
    end)

    Cell.RegisterCallback("SpecChanged", "Dispellable_SpecChanged", function()
        if timer then timer:Cancel() end
        timer = C_Timer.NewTimer(1, UpdateDispellable)
    end)
end

-------------------------------------------------
-- drinking
-------------------------------------------------
local drinks = {
    430, -- 喝水 - Drink
    43182, -- 饮水 - Drink
}

do
    local temp = {}
    for _, id in pairs(drinks) do
        temp[F.GetSpellInfo(id)] = true
    end
    drinks = temp
end

function I.IsDrinking(name)
    return drinks[name]
end

-------------------------------------------------
-- healer
-------------------------------------------------
local spells = {
    -- druid
    8936, -- 愈合
    774, -- 回春术
    33763, -- 生命绽放
    48438, -- 野性成长
    102351, -- 塞纳里奥结界
    102352, -- 塞纳里奥结界
    48504, -- 生命之种

    -- monk
    119611, -- 复苏之雾
    132120, -- 氤氲之雾
    124081, -- 禅意珠
    115175, -- 抚慰之雾
    125950, -- 抚慰之雾

    -- paladin
    53563, -- 圣光道标

    -- priest
    17, -- 真言术：盾
    114908, -- 灵魂护壳
    139, -- 恢复
    41635, -- 愈合祷言
    77489, -- 圣光回响
    126154, -- 光明之泉恢复

    -- shaman
    974, -- 大地之盾
    61295, -- 激流
    51945, -- 大地生命
}

function F.FirstRun()
    local icons = "\n\n"
    for i, id in pairs(spells) do
        local icon = select(2, F.GetSpellInfo(id))
        if icon then
            icons = icons .. "|T" .. icon .. ":0|t"
            if i % 11 == 0 then
                icons = icons .. "\n"
            end
        end
    end

    local popup = Cell.CreateConfirmPopup(Cell.frames.anchorFrame, 200, L["Would you like Cell to create a \"Healers\" indicator (icons)?"] .. icons, function(self)
        local currentLayoutTable = Cell.vars.currentLayoutTable

        local last = #currentLayoutTable["indicators"]
        if currentLayoutTable["indicators"][last]["type"] == "built-in" then
            indicatorName = "indicator1"
        else
            indicatorName = "indicator" .. (tonumber(strmatch(currentLayoutTable["indicators"][last]["indicatorName"], "%d+")) + 1)
        end

        tinsert(currentLayoutTable["indicators"], {
            ["name"] = "Healers",
            ["indicatorName"] = indicatorName,
            ["type"] = "icons",
            ["enabled"] = true,
            ["position"] = {"TOPRIGHT", "button", "TOPRIGHT", 0, 3},
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
            ["glowOptions"] = {"None", {0.95, 0.95, 0.32, 1}},
            ["auraType"] = "buff",
            ["castBy"] = "me",
            ["auras"] = spells,
        })
        Cell.Fire("UpdateIndicators", Cell.vars.currentLayout, indicatorName, "create", currentLayoutTable["indicators"][last + 1])
        CellDB["firstRun"] = false
        F.ReloadIndicatorList()
    end, function()
        CellDB["firstRun"] = false
    end)
    popup:SetPoint("TOPLEFT")
    popup:Show()
end

-------------------------------------------------
-- cleuAuras
-------------------------------------------------
-- local cleuAuras = {}

-- function I.UpdateCleuAuras(t)
--     -- reset
--     wipe(cleuAuras)
--     -- insert
--     for _, c in pairs(t) do
--         local icon = select(2, F.GetSpellInfo(c[1]))
--         cleuAuras[c[1]] = {c[2], icon}
--     end
-- end

-- function I.CheckCleuAura(id)
--     return cleuAuras[id]
-- end

-------------------------------------------------
-- targetedSpells
-------------------------------------------------
local targetedSpells = {
}

function I.GetDefaultTargetedSpellsList()
    return targetedSpells
end

function I.GetDefaultTargetedSpellsGlow()
    return {"Pixel", {0.95, 0.95, 0.32, 1}, 9, 0.25, 8, 2}
end

-------------------------------------------------
-- Actions
-------------------------------------------------
local actions = {
    {
        6262, -- 治疗石 - Healthstone
        {"A", {0.4, 1, 0}},
    },
}


function I.GetDefaultActions()
    return actions
end

function I.ConvertActions(db)
    local temp = {}
    for _, t in pairs(db) do
        temp[t[1]] = t[2]
    end
    return temp
end

-------------------------------------------------
-- missing buffs, for indicator settings only
-------------------------------------------------
local buffsOrder = {"PWF", "AB", "MotW", "LotE", "BoK", "BoM", "BS", "CS"}
local abbrToIndex = {}

local missingBuffs = {
    ["PWF"] = 21562,
    ["AB"] = 1459,
    ["MotW"] = 1126,
    ["LotE"] = 117666,
    ["BoK"] = 20217,
    ["BoM"] = 19740,
    ["BS"] = 6673,
    ["CS"] = 469,
}

do
    local temp = {}
    for _, k in pairs(buffsOrder) do
        local id = missingBuffs[k]
        local name, icon = F.GetSpellInfo(id)
        if name then
            tinsert(temp, {
                ["id"] = id,
                ["name"] = name,
                ["icon"] = icon,
                ["index"] = k,
            })
            abbrToIndex[k] = #temp
        end
    end
    missingBuffs = temp
end

function I.GetDefaultMissingBuffs()
    return missingBuffs
end

function I.GetMissingBuffsString()
    local s = ""
    for _, t in pairs(missingBuffs) do
        s = s .. "|T" .. t["icon"] .. ":14:14:0:0:14:14:1:13:1:13|t" .. " "
    end
    return s
end

function I.GetMissingBuffsFilters()
    local indicies = {
        "PWF",
        "AB",
        "MotW",
        "LotE",
        {"PALADIN", {"BoK", "BoM"}},
        {"WARRIOR", {"BS", "CS"}},
    }

    local ret = {}
    for _, v in pairs(indicies) do
        if type(v) == "string" then
            local icon = missingBuffs[abbrToIndex[v]]["icon"]
            local name = missingBuffs[abbrToIndex[v]]["name"]
            local index = missingBuffs[abbrToIndex[v]]["index"]
            tinsert(ret, {"|T"..icon..":14:14:0:0:14:14:1:13:1:13|t "..name, index})
        else -- table
            local icons = ""
            for _, abbr in pairs(v[2]) do
                local icon = missingBuffs[abbrToIndex[abbr]]["icon"]
                icons = icons.."|T"..icon..":14:14:0:0:14:14:1:13:1:13|t "
            end
            tinsert(ret, {icons..F.GetLocalizedClassName(v[1]), v[1]})
        end
    end
    return ret
end