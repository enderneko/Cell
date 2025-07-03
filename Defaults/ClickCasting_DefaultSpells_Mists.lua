local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

-------------------------------------------------
-- click-castings
-------------------------------------------------
local defaultSpells = {
    ["DEATHKNIGHT"] = {
        ["common"] = {
            61999, -- 复活盟友
            47541, -- 凋零缠绕
            49016, -- 邪恶狂热
        },
    },

    ["DRUID"] = {
        ["common"] = {
            774, -- 回春术
            8936, -- 愈合
            5185, -- 治疗之触
            33763, -- 生命绽放
            50464, -- 滋养
            18562, -- 迅捷治愈
            48438, -- 野性成长
            145205, -- 野性蘑菇
            102351, -- 塞纳里奥结界
            -- dispel
            88423, -- 自然之愈
            2782, -- 净化腐蚀
            -- resurrect
            20484, -- 复生
            50769, -- 起死回生
            450759, -- 新生
            -- buff
            29166, -- 激活
            102342, -- 铁木树皮
            110309, -- 共生术
            1126, -- 野性印记
            -- others
            102401, -- 野性冲锋
        },
    },

    ["HUNTER"] = {
        ["common"] = {
            34477, -- 误导
            53271, -- 主人的召唤
        },
    },

    ["MAGE"] = {
        ["common"] = {
            -- dispel
            475, -- 解除诅咒
            -- buff
            130, -- 缓落术
            1459, -- 奥术光辉
        },
    },

    ["MONK"] = {
        ["common"] = {
            115151, -- 复苏之雾
            124682, -- 氤氲之雾
            115175, -- 抚慰之雾
            116694, -- 升腾之雾
            116849, -- 作茧缚命
            "115098T", -- 真气波
            "124081T", -- 禅意珠
            -- dispel
            115450, -- 化瘀术
            -- resurrect
            115178, -- 轮回转世
            1245934, -- 死而复生
            -- buff
            "116841T", -- 迅如猛虎
            115921, -- 帝王传承
        },
    },

    ["PALADIN"] = {
        ["common"] = {
            -- Holy
            635, -- 圣光术
            19750, -- 圣光闪现
            82326, -- 神圣之光
            82327, -- 圣光普照
            633, -- 圣疗术
            85673, -- 荣耀圣令
            20473, -- 神圣震击
            53563, -- 圣光道标
            "20925T", -- 圣洁护盾
            "114165T", -- 神圣棱镜
            "114157T", -- 处决宣判
            -- Protection
            1044, -- 自由之手
            1038, -- 拯救之手
            6940, -- 牺牲之手
            1022, -- 保护之手
            "114039T", -- 纯净之手
            -- dispel
            4987, -- 清洁术
            -- resurrect
            7328, -- 救赎
            450761, -- 赦免
            -- buff
            20217, -- 王者祝福
            19740, -- 力量祝福
        },
    },

    ["PRIEST"] = {
        ["common"] = {
            17, -- 真言术：盾
            47540, -- 苦修
            2061, -- 快速治疗
            2050, -- 治疗术
            2060, -- 强效治疗术
            32546, -- 联结治疗
            139, -- 恢复
            33076, -- 愈合祷言
            596, -- 治疗祷言
            34861, -- 治疗之环
            88625, -- 圣言术：罚 -> 圣言术：静
            108968, -- 虚空转移
            -- dispel
            527, -- 纯净术
            -- resurrect
            2006, -- 复活术
            83968, -- 群体复活
            -- buff
            "10060T", -- 能量灌注
            33206, -- 痛苦压制
            47788, -- 守护之魂
            1706, -- 漂浮术
            6346, -- 防护恐惧结界
            21562, -- 真言术：韧
            -- other
            2096, -- 心灵视界
            73325, -- 信仰飞跃
        },
    },

    ["ROGUE"] = {
        ["common"] = {
            57934, -- 嫁祸诀窍
        },
    },

    ["SHAMAN"] = {
        ["common"] = {
            61295, -- 激流
            8004, -- 治疗之涌
            331, -- 治疗波
            77472, -- 强效治疗波
            1064, -- 治疗链
            73680, -- 元素释放
            -- dispel
            51886, -- 净化灵魂
            -- resurrect
            2008, -- 先祖之魂
            450762, -- 先祖视界
            -- buff
            974, -- 大地之盾
            546, -- 水上行走
        },
    },

    ["WARLOCK"] = {
        ["common"] = {
            5697, -- 无尽呼吸
            109773, -- 黑暗意图
            89808, -- 烧灼驱魔
        },
    },

    ["WARRIOR"] = {
        ["common"] = {
            3411, -- 援护
            "114030T", -- 警戒
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
        spells[i] = {icon, name, spellType, spellId}
    end

    -- texplore(spells)
    return spells
end

-------------------------------------------------
-- resurrections
-------------------------------------------------
local resurrections_for_dead = {
    -- DEATHKNIGHT
    61999, -- 复活盟友

    -- DRUID
    20484, -- 复生
    50769, -- 起死回生
    450759, -- 新生

    -- MONK
    115178, -- 轮回转世
    1245934, -- 死而复生

    -- PALADIN
    7328, -- 救赎
    450761, -- 赦免

    -- PRIEST
    2006, -- 复活术
    83968, -- 群体复活

    -- SHAMAN
    2008, -- 先祖之魂
    450762, -- 先祖视界
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
    ["DEATHKNIGHT"] = {
        {"type-altR", "spell", 61999},
    },
    ["DRUID"] = {
        {"type-altR", "spell", 20484},
        {"type-shiftR", "spell", 50769},
    },
    ["MONK"] = {
        {"type-shiftR", "spell", 115178},
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
    ["DRUID"] = 450759,
    ["MONK"] = 1245934,
    ["PALADIN"] = 450761,
    ["PRIEST"] = 83968,
    ["SHAMAN"] = 450762,
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
    ["DEATHKNIGHT"] = 61999,
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
