local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

-------------------------------------------------
-- click-castings
-------------------------------------------------
local defaultSpells = {
    ["DRUID"] = {
        ["common"] = {
            -- Balance
            29166, -- 激活
            26992, -- 荆棘术
            -- Restoration
            774, -- 回春术
            8936, -- 愈合
            5185, -- 治疗之触
            33763, -- 生命绽放
            "18562T", -- 迅捷治愈
            -- dispel
            8946, -- 消毒术
            2893, -- 驱毒术
            2782, -- 解除诅咒
            -- resurrect
            20484, -- 复生
            -- buff
            1126, -- 野性印记
            21849, -- 野性赐福
        },
    },

    ["HUNTER"] = {
        ["common"] = {
            34477, -- 误导
        },
    },

    ["MAGE"] = {
        ["common"] = {
            -- dispel
            475, -- 解除诅咒
            -- buff
            130, -- 缓落术
            1008, -- 魔法增效
            604, -- 魔法抑制
            1459, -- 奥术智慧
            23028, -- 奥术光辉
        },
    },

    ["PALADIN"] = {
        ["common"] = {
            -- Holy
            635, -- 圣光术
            19750, -- 圣光闪现
            633, -- 圣疗术
            "20473T", -- 神圣震击
            -- Protection
            31789, -- 正义防御
            1044, -- 自由祝福
            6940, -- 牺牲祝福
            1022, -- 保护祝福
            -- dispel
            4987, -- 清洁术
            1152, -- 纯净术
            -- resurrect
            7328, -- 救赎
            19752, -- 神圣干涉
            -- buff
            "20217T", -- 王者祝福
            "25898T", -- 强效王者祝福
            19740, -- 力量祝福
            25782, -- 强效力量祝福
            19742, -- 智慧祝福
            25894, -- 强效智慧祝福
            19977, -- 光明祝福
            25890, -- 强效光明祝福
            1038, -- 拯救祝福
            25895, -- 强效拯救祝福
            "20911T", -- 庇护祝福
            "25899T", -- 强效庇护祝福
        },
    },

    ["PRIEST"] = {
        ["common"] = {
            -- Discipline
            17, -- 真言术：盾
            -- Holy
            2061, -- 快速治疗
            2050, -- 次级治疗术
            2054, -- 治疗术
            2060, -- 强效治疗术
            139, -- 恢复
            596, -- 治疗祷言
            "34861T", -- 治疗之环
            -- dispel
            527, -- 驱散魔法
            552, -- 驱除疾病
            528, -- 祛病术
            -- resurrect
            2006, -- 复活术
            -- buff
            "10060T", -- 能量灌注
            "33206T", -- 痛苦压制
            1706, -- 漂浮术
            6346, -- 防护恐惧结界
            1243, -- 真言术：韧
            21562, -- 坚韧祷言
            14752, -- 神圣之灵
            27681, -- 精神祷言
            976, -- 暗影防护
            27683, -- 暗影防护祷言
            -- other
            2096, -- 心灵视界
        },
    },

    ["ROGUE"] = {
        ["common"] = {
        },
    },

    ["SHAMAN"] = {
        ["common"] = {
            -- Restoration
            8004, -- 次级治疗波
            331, -- 治疗波
            1064, -- 治疗链
            "974T", -- "大地之盾"
            -- dispel
            526, -- 驱毒术
            2870, -- 祛病术
            -- resurrect
            2008, -- 先祖之魂
            -- buff
            546, -- 水上行走
            131, -- 水下呼吸
        },
    },

    ["WARLOCK"] = {
        ["common"] = {
            -- buff
            132, -- 侦测隐形
            5697, -- 魔息术
        },
    },

    ["WARRIOR"] = {
        ["common"] = {
            3411, -- 援护
        },
    },
}

function F.GetClickCastingSpellList(class)
    local spells = defaultSpells[class]["common"] and F.Copy(defaultSpells[class]["common"]) or {}

    -- fill data
    for i, v in pairs(spells) do
        local spellId, spellType

        if type(v) == "number" then
            spellId = v
        else -- string
            spellId, spellType = strmatch(v, "(%d+)(%a)")
            spellId = tonumber(spellId)
            spellType = L[spellType]
        end

        local name, icon = F.GetSpellInfo(spellId)
        spells[i] = {icon, name, spellType, spellId, F.GetMaxSpellRank(spellId)}
    end

    -- texplore(spells)
    return spells
end

-------------------------------------------------
-- resurrections
-------------------------------------------------
local resurrections_for_dead = {
    -- DRUID
    20484, -- 复生

    -- PALADIN
    7328, -- 救赎

    -- PRIEST
    2006, -- 复活术

    -- SHAMAN
    2008, -- 先祖之魂
}

do
    local temp = {}
    for _, id in pairs(resurrections_for_dead) do
        temp[F.GetSpellInfo(id)] = true
    end
    resurrections_for_dead = temp
end

function F.IsSoulstone()
    return false
end

function F.IsResurrectionForDead(spellId)
    return resurrections_for_dead[spellId]
end

local resurrection_click_castings = {
    ["DRUID"] = {
        {"type-altR", "spell", 20484},
    },
    ["PALADIN"] = {
        {"type-shiftR", "spell", 7328},
    },
    ["PRIEST"] = {
        {"type-shiftR", "spell", 2006},
    },
    ["SHAMAN"] = {
        {"type-shiftR", "spell", 2008},
    },
}

function F.GetResurrectionClickCastings(class)
    return resurrection_click_castings[class] or {}
end

-------------------------------------------------
-- smart resurrection
-------------------------------------------------
local normalResurrection = {
    ["PALADIN"] = 7328,
    ["PRIEST"] = 2006,
    ["SHAMAN"] = 2008,
}

do
    for class, spell in pairs(normalResurrection) do
        normalResurrection[class] = F.GetSpellInfo(spell)
    end
end

function F.GetNormalResurrection(class)
    return normalResurrection[class]
end

local combatResurrection = {
    ["DRUID"] = 20484,
}

do
    for class, spell in pairs(combatResurrection) do
        combatResurrection[class] = F.GetSpellInfo(spell)
    end
end

function F.GetCombatResurrection(class)
    return combatResurrection[class]
end