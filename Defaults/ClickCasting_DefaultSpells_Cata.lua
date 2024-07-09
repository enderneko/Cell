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
            "49016T", -- 邪恶狂热
        },
    },

    ["DRUID"] = {
        ["common"] = {
            -- Balance
            29166, -- 激活
            -- Restoration
            774, -- 回春术
            8936, -- 愈合
            5185, -- 治疗之触
            33763, -- 生命绽放
            50464, -- 滋养
            "18562T", -- 迅捷治愈
            "48438T", -- 野性成长
            -- dispel
            2782, -- 净化腐蚀
            -- resurrect
            20484, -- 复生
            50769, -- 起死回生
            450759, -- 新生
            -- buff
            467, -- 荆棘术
            1126, -- 野性印记
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

    ["PALADIN"] = {
        ["common"] = {
            -- Holy
            635, -- 圣光术
            19750, -- 圣光闪现
            82326, -- 神圣之光
            633, -- 圣疗术
            85673, -- 荣耀圣令
            "20473T", -- 神圣震击
            "53563T", -- 圣光道标
            -- Protection
            31789, -- 正义防御
            1044, -- 自由之手
            1038, -- 拯救之手
            6940, -- 牺牲之手
            1022, -- 保护之手
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
            -- Discipline
            17, -- 真言术：盾
            "47540T", -- 苦修
            -- Holy
            2061, -- 快速治疗
            2050, -- 治疗术
            2060, -- 强效治疗术
            32546, -- 联结治疗
            139, -- 恢复
            33076, -- 愈合祷言
            596, -- 治疗祷言
            "34861T", -- 治疗之环
            "47788T", -- 守护之魂
            73325, -- 信仰飞跃
            -- dispel
            527, -- 驱散魔法
            528, -- 祛病术
            -- resurrect
            2006, -- 复活术
            83968, -- 群体复活
            -- buff
            "10060T", -- 能量灌注
            "33206T", -- 痛苦压制
            1706, -- 漂浮术
            6346, -- 防护恐惧结界
            21562, -- 真言术：韧
            27683, -- 暗影防护
            -- other
            2096, -- 心灵视界
        },
    },

    ["ROGUE"] = {
        ["common"] = {
            57934, -- 嫁祸诀窍
        },
    },

    ["SHAMAN"] = {
        ["common"] = {
            -- Restoration
            8004, -- 治疗之涌
            331, -- 治疗波
            77472, -- 强效治疗波
            1064, -- 治疗链
            "974T", -- 大地之盾
            "61295T", -- 激流
            -- dispel
            51886, -- 净化灵魂
            -- resurrect
            2008, -- 先祖之魂
            450762, -- 先祖视界
            -- buff
            546, -- 水上行走
            131, -- 水下呼吸
        },
    },

    ["WARLOCK"] = {
        ["common"] = {
            -- buff
            5697, -- 无尽呼吸
            80398, -- 黑暗意图
        },
    },

    ["WARRIOR"] = {
        ["common"] = {
            3411, -- 援护
            "50720T", -- 警戒
        },
    },
}

function F:GetClickCastingSpellList(class)
    local spells = defaultSpells[class]["common"] and F:Copy(defaultSpells[class]["common"]) or {}

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

        local name, icon = F:GetSpellInfo(spellId)
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
        temp[F:GetSpellInfo(id)] = true
    end
    resurrections_for_dead = temp
end

function F:IsSoulstone()
    return false
end

function F:IsResurrectionForDead(spellId)
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

function F:GetResurrectionClickCastings(class)
    return resurrection_click_castings[class] or {}
end

-------------------------------------------------
-- smart resurrection
-------------------------------------------------
local normalResurrection = {
    ["DRUID"] = 50769,
    ["PALADIN"] = 7328,
    ["PRIEST"] = 2006,
    ["SHAMAN"] = 2008,
}

do
    for class, spell in pairs(normalResurrection) do
        normalResurrection[class] = F:GetSpellInfo(spell)
    end
end

function F:GetNormalResurrection(class)
    return normalResurrection[class]
end

local combatResurrection = {
    ["DEATHKNIGHT"] = 61999,
    ["DRUID"] = 20484,
}

do
    for class, spell in pairs(combatResurrection) do
        combatResurrection[class] = F:GetSpellInfo(spell)
    end
end

function F:GetCombatResurrection(class)
    return combatResurrection[class]
end