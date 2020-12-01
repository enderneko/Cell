local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

-- NOTE: these spellIds ~= realSpellIds, spells are matched by names
local debuffBlacklist = {
    8326, -- 鬼魂
    57723, -- 筋疲力尽
    57724, -- 心满意足
    80354, -- 时空错位
    264689, -- 疲倦
    206151, -- 挑战者的负担
}

function F:GetDefaultDebuffBlacklist()
    -- local temp = {}
    -- for i, id in pairs(debuffBlacklist) do
    --     temp[i] = GetSpellInfo(id)
    -- end
    -- return temp
    return debuffBlacklist
end

-------------------------------------------------
-- aoeHealings
-------------------------------------------------
local aoeHealings = {
    -- druid
    740, -- 宁静
    145205, -- 百花齐放

    -- monk
    115098, -- 真气波
    123986, -- 真气爆裂
    115310, -- 还魂术

    -- paladin
    85222, -- 黎明之光
    119952, -- 弧形圣光
    114165, -- 神圣棱镜


    -- priest
    120517, -- 光晕
    34861, -- 圣言术：灵
    596, -- 治疗祷言
    64843, -- 神圣赞美诗
    110744, -- 神圣之星
    204883, -- 治疗之环

    -- shaman
    1064, -- 治疗链
    73920, -- 治疗之雨
    114942, -- 治疗之潮
}

do
    local temp = {}
    for _, id in pairs(aoeHealings) do
        temp[GetSpellInfo(id)] = true
    end
    aoeHealings = temp
end

function F:IsAoEHealing(name)
    if not name then return false end
    return aoeHealings[name]
end

-------------------------------------------------
-- externalCooldowns
-------------------------------------------------
local externalCooldowns = {
    -- demon hunter
    -- 196718, -- REVIEW:幻影打击

    -- druid
    102342, -- 铁木树皮

    -- monk
    116849, -- 作茧缚命

    -- paladin
    1022, -- 保护祝福
    6940, -- 牺牲祝福
    204018, -- 破咒祝福
    -- 204150, -- REVIEW:圣光护盾

    -- priest
    33206, -- 痛苦压制
    47788, -- 守护之魂
    62618, -- REVIEW:真言术：障

    -- shaman
    -- 98008, -- REVIEW:灵魂链接图腾

    -- warrior
    -- 97462, -- REVIEW:集结呐喊
    198304, -- 拦截
}

do
    local temp = {}
    for _, id in pairs(externalCooldowns) do
        temp[GetSpellInfo(id)] = true
    end
    externalCooldowns = temp
end

function F:IsExternalCooldown(name, source, target)
    if name == GetSpellInfo(6940) then -- 牺牲祝福
        return source ~= target
    else
        return externalCooldowns[name]
    end
end

-------------------------------------------------
-- defensiveCooldowns
-------------------------------------------------
local defensiveCooldowns = {
    -- death knight
    48707, -- 反魔法护罩
    48792, -- 冰封之韧
    49028, -- 符文刃舞
    55233, -- 吸血鬼之血

    -- demon hunter
    196555, -- 虚空行走
    198589, -- 疾影

    -- druid
    22812, -- 树皮术
    -- 22842, -- REVIEW:狂暴回复
    61336, -- 生存本能

    -- hunter
    186265, -- 灵龟守护

    -- mage
    45438, -- 寒冰屏障

    -- monk
    115176, -- 禅悟冥想
    115203, -- 壮胆酒
    122278, -- 躯不坏
    122783, -- 散魔功

    -- paladin
    498, -- 圣佑术
    642, -- 圣盾术
    31850, -- 炽热防御者
    212641, -- 远古列王守卫

    -- priest
    47585, -- 消散

    -- rogue
    1966, -- 佯攻
    5277, -- 闪避
    31224, -- 暗影斗篷

    -- shaman
    108271, -- 星界转移

    -- warlock
    104773, -- 不灭决心

    -- warrior
    871, -- 盾墙
    12975, -- 破釜沉舟
    23920, -- 法术反射
    118038, -- 剑在人在
    184364, -- 狂怒回复
}

do
    local temp = {}
    for _, id in pairs(defensiveCooldowns) do
        temp[GetSpellInfo(id)] = true
    end
    defensiveCooldowns = temp
end

function F:IsDefensiveCooldown(name)
    return defensiveCooldowns[name]
end

-------------------------------------------------
-- tankActiveMitigation
-------------------------------------------------
local tankActiveMitigations = {
    -- death knight
    77535, -- 鲜血护盾
    195181, -- 白骨之盾

    -- demon hunter
    203720, -- 恶魔尖刺

    -- druid
    192081, -- 铁鬃

    -- monk
    215479, -- 铁骨酒

    -- paladin
    132403, -- 正义盾击

    -- warrior
    2565, -- 盾牌格挡
}

do
    local temp = {}
    for _, id in pairs(tankActiveMitigations) do
        temp[GetSpellInfo(id)] = true
    end
    tankActiveMitigations = temp
end

function F:IsTankActiveMitigation(name)
    return tankActiveMitigations[name]
end

-------------------------------------------------
-- dispels
-------------------------------------------------
local dispellable = {
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
        [65] = {["Disease"] = true, ["Magic"] = true, ["Poison"] = true},
        -- 66 - Protection
        [66] = {["Disease"] = true, ["Poison"] = true},
        -- 70 - Retribution
        [70] = {["Disease"] = true, ["Poison"] = true},
    -------------------------
    
    -- PRIEST ---------------
        -- 256 - Discipline
        [256] = {["Disease"] = true, ["Magic"] = true},
        -- 257 - Holy
        [257] = {["Disease"] = true, ["Magic"] = true},
        -- 258 - Shadow
        [258] = {["Disease"] = true, ["Magic"] = true},
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
        [265] = {["Magic"] = true},
        -- 266 - Demonology
        [266] = {["Magic"] = true},
        -- 267 - Destruction
        [267] = {["Magic"] = true},
    -------------------------
}

function F:CanDispel(dispelType)
    if dispellable[Cell.vars.playerSpecID] then
        return dispellable[Cell.vars.playerSpecID][dispelType]
    else
        return
    end
end

-------------------------------------------------
-- drinking
-------------------------------------------------
local drinks = {
    170906, -- 食物和饮水
    167152, -- 进食饮水
    430, -- 喝水
    43182, -- 饮水
    172786, -- 饮料
    308433, -- 食物和饮料
}

do
    local temp = {}
    for _, id in pairs(drinks) do
        temp[GetSpellInfo(id)] = true
    end
    drinks = temp
end

function F:IsDrinking(name)
    return drinks[name]
end