local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

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

function F:IsExternalCooldown(name)
    return externalCooldowns[name]
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