local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

local GetSpellInfo = GetSpellInfo

local defaultSpells = {
    ["DEATHKNIGHT"] = {
        ["common"] = {
            61999, -- Raise Ally - 复活盟友
        },
        -- 250 - Blood
        -- 251 - Frost
        -- 252 - Unholy
    },

    ["DEMONHUNTER"] = {
        -- 577 - Havoc
        -- 581 - Vengeance
    },

    ["DRUID"] = {
        ["common"] = {
            8936, -- Regrowth - 愈合
            "102401T", -- Wild Charge - 野性冲锋
            20484, -- Rebirth - 复生
            50769, -- Revive - 起死回生
        },
        -- 102 - Balance
        [102] = {
            2782, -- Remove Corruption - 清除腐蚀
            29166, -- Innervate - 激活
            774, -- Rejuvenation - 回春术
            "305497P", -- pvp - Thorns - 荆棘术
        },
        -- 103 - Feral
        [103] = {
            2782, -- Remove Corruption - 清除腐蚀
            "305497P", -- pvp - Thorns - 荆棘术
        },
        -- 104 - Guardian
        [104] = {
            2782, -- Remove Corruption - 清除腐蚀
        },
        -- Restoration
        [105] = {
            88423, -- Nature's Cure - 自然之愈
            29166, -- Innervate - 激活
            774, -- Rejuvenation - 回春术
            18562, -- Swiftmend - 迅捷治愈
            33763, -- Lifebloom - 生命绽放
            48438, -- Wild Growth - 野性成长
            102342, -- Ironbark - 铁木树皮
            "289022T", -- Nourish - 滋养
            "102351T", -- Cenarion Ward - 塞纳里奥结界
            "203651T", -- Overgrowth - 过度生长
            212040, -- Revitalize - 新生
            "305497P", -- pvp - Thorns - 荆棘术
            "289318P", -- pvp - Mark of the Wild - 野性印记
        },
    },

    ["HUNTER"] = {
        ["common"] = {
            34477, -- Misdirection - 误导
            "53480P", -- pvp - Roar of Sacrifice - 牺牲咆哮
        },
        -- 253 - Beast Mastery
        [253] = {
            90361, -- Spirit Mend - 灵魂治愈
            "248518P", -- pvp - Interlope - 干涉
        },
        -- 254 - Marksmanship
        -- 255 - Survival
        [255] = {
            "212640P", -- pvp - Mending Bandage - 治疗绷带
        },
    },

    ["MAGE"] = {
        ["common"] = {
            475, -- Remove Curse - 解除诅咒
            130, -- Slow Fall - 缓落术
            1459, -- Arcane Intellect - 奥术智慧
        },
        -- 62 - Arcane
        -- 63 - Fire
        -- 64 - Frost
    },

    ["MONK"] = {
        ["common"] = {
            115450, -- Detox - 清创生血
            115178, -- Resuscitate - 轮回转世
            116670, -- Vivify - 活血术
            "115098T", -- Chi Wave - 真气波
        },
        -- 268 - Brewmaster
        -- 269 - Windwalker
        -- 270 - Mistweaver
        [270] = {
            115151, -- Renewing Mist - 复苏之雾
            115175, -- Soothing Mist - 抚慰之雾
            116849, -- Life Cocoon - 作茧缚命
            124682, -- Enveloping Mist - 氤氲之雾
            212051, -- Reawaken - 死而复生
            "227344P", -- pvp - Surging Mist - 升腾之雾
        },
    },

    ["PALADIN"] = {
        ["common"] = {
            19750, -- Flash of Light - 圣光闪现
            85673, -- Word of Glory - 荣耀圣令
            633, -- Lay on Hands - 圣疗术
            1022, -- Blessing of Protection - 保护祝福
            1044, -- Blessing of Freedom - 自由祝福
            6940, -- Blessing of Sacrifice - 牺牲祝福
            7328, -- Redemption - 救赎
        },
        -- 65 - Holy
        [65] = {
            183998, -- Light of the Martyr -- 殉道者之光
            82326, -- Holy Light - 圣光术
            20473, -- Holy Shock - 神圣震击
            53563, -- Beacon of Light - 圣光道标
            "156910T", -- Beacon of Faith - 信仰道标
            -- "200025T", -- Beacon of Virtue -- 美德道标
            "223306T", -- Bestow Faith -- 赋予信仰
            "114165T", -- Holy Prism - 神圣棱镜
            4987, -- Cleanse - 清洁术
            212056, -- Absolution - 宽恕
        },
        -- 66 - Protection
        [66] = {
            213644, -- Cleanse Toxins - 清毒术
            "228049P", -- pvp - Guardian of the Forgotten Queen - 被遗忘的女王护卫
        },
        -- 70 - Retribution
        [70] = {
            213644, -- Cleanse Toxins - 清毒术
            "210256P", -- pvp - Blessing of Sanctuary - 庇护祝福
        },
    },

    ["PRIEST"] = {
        ["common"] = {
            10060, -- 能量灌注
            21562, -- Power Word: Fortitude - 真言术：韧
            17, -- Power Word: Shield - 真言术：盾
            1706, -- Levitate - 漂浮术
            73325, -- Leap of Faith - 信仰飞跃
            2006, -- Resurrection - 复活术
        },
        -- 256 - Discipline
        [256] = {
            47540, -- Penance - 苦修
            186263, -- Shadow Mend - 暗影愈合
            194509, -- Power Word: Radiance - 真言术：耀
            47536, -- Rapture - 全神贯注
            33206, -- Pain Suppression - 痛苦压制
            "204263T", -- Shining Force - 闪光力场
            "314867T", -- Shadow Covenant - 暗影盟约
            527, -- Purify - 纯净术
            212036, -- Mass Resurrection - 群体复活
        },
        -- 257 - Holy
        [257] = {
            2050, -- Holy Word: Serenity - 圣言术：静
            139, -- Renew - 恢复
            33076, -- Prayer of Mending - 愈合祷言
            2061, -- Flash Heal - 快速治疗
            2060, -- Heal - 治疗术
            596, -- Prayer of Healing - 治疗祷言
            204883, -- Circle of Healing - 治疗之环
            47788, -- Guardian Spirit - 守护之魂
            "204263T", -- Shining Force - 闪光力场
            527, -- Purify - 纯净术
            212036, -- Mass Resurrection - 群体复活
            "213610P", -- pvp - Holy Ward - 神圣守卫
            "289666P", -- pvp - Greater Heal - 强效治疗术
            "197268P", -- pvp - Ray of Hope - 希望之光
        },
        -- 258 - Shadow
        [258] = {
            186263, -- Shadow Mend - 暗影愈合
            213634, -- Purify Disease - 净化疾病
            "108968P", -- pvp - Void Shift - 虚空转移
        },
    },

    ["ROGUE"] = {
        ["common"] = {
            57934, -- Tricks of the Trade - 嫁祸诀窍
        },
        -- 259 - Assassination
        [259] = {
            36554, -- Shadowstep - 暗影步
        },
        -- 260 - Outlaw
        -- 261 - Subtlety
        [261] = {
            36554, -- Shadowstep - 暗影步
        },
    },

    ["SHAMAN"] = {
        ["common"] = {
            8004, -- Healing Surge - 治疗之涌
            1064, -- Chain Heal - 治疗链
            546, -- Water Walking - 水上行走
            2008, -- Ancestral Spirit - 先祖之魂
        },
        -- 262 - Elemental
        [262] = {
            "974T", -- Earth Shield - 大地之盾
            51886, -- Cleanse Spirit - 净化灵魂
        },
        -- 263 - Enhancement
        [263] = {
            "974T", -- Earth Shield - 大地之盾
            51886, -- Cleanse Spirit - 净化灵魂
        },
        -- 264 - Restoration
        [264] = {
            77472, -- Healing Wave - 治疗波
            61295, -- Riptide - 激流
            974, -- Earth Shield - 大地之盾
            "73685T", -- Unleash Life - 生命释放
            77130, -- Purify Spirit - 净化灵魂
            212048, -- Ancestral Vision - 先祖视界
        },
    },

    ["WARLOCK"] = {
        ["common"] = {
            5697, -- Unending Breath - 无尽呼吸
            20707, -- Soulstone - 灵魂石
            89808, -- Singe Magic - 烧灼驱魔
        },
        -- 265 - Affliction
        -- 266 - Demonology
        -- 267 - Destruction
    },

    ["WARRIOR"] = {
        ["common"] = {
            3411, -- Intervene - 援护
        },
        -- 71 - Arms
        -- 72 - Fury
        -- 73 - Protection
        [73] = {
            "213871P", -- pvp - Bodyguard - 护卫
        },
    },
}

function F:GetSpellList(class, spec)
    local spells = defaultSpells[class]["common"] and F:Copy(defaultSpells[class]["common"]) or {}
    
    -- check spec
    if spec and defaultSpells[class][spec] then
        for _, v in pairs(defaultSpells[class][spec]) do
            tinsert(spells, v)
        end
    end

    -- fill data
    for i, v in pairs(spells) do
        local spellId, spellType
        
        if type(v) == "number" then
            spellId = v
        else -- string
            spellId, spellType = strmatch(v, "(%d+)(%a)")
            spellType = L[spellType]
        end

        local name, _, icon = GetSpellInfo(spellId)
        spells[i] = {icon, name, spellType}
    end

    -- texplore(spells)
    return spells
end