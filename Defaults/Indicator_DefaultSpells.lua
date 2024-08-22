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
    8326, -- 鬼魂 - Ghost
    160029, -- 正在复活 - Resurrecting
    255234, -- 图腾复生 - Totemic Revival
    225080, -- 复生 - Reincarnation
    57723, -- 筋疲力尽 - Exhaustion
    57724, -- 心满意足 - Sated
    80354, -- 时空错位 - Temporal Displacement
    264689, -- 疲倦 - Fatigued
    390435, -- 筋疲力尽 - Exhaustion
    206151, -- 挑战者的负担 - Challenger's Burden
    195776, -- 月羽疫病 - Moonfeather Fever
    352562, -- 起伏机动 - Undulating Maneuvers
    356419, -- 审判灵魂 - Judge Soul
    387847, -- 邪甲术 - Fel Armor
    213213, -- 伪装 - Masquerade
}

function I.GetDefaultDebuffBlacklist()
    -- local temp = {}
    -- for i, id in pairs(debuffBlacklist) do
    --     temp[i] = F:GetSpellInfo(id)
    -- end
    -- return temp
    return debuffBlacklist
end

-------------------------------------------------
-- bigDebuffs
-------------------------------------------------
local bigDebuffs = {
    46392, -- 专注打击 - Focused Assault
    -----------------------------------------------
    240443, -- 爆裂 - Burst
    209858, -- 死疽溃烂 - Necrotic Wound
    240559, -- 重伤 - Grievous Wound
    -- 226512, -- 鲜血脓液（血池）
    -----------------------------------------------
    -- NOTE: Thundering Affix - Dragonflight Season 1
    -- 396369, -- 闪电标记
    -- 396364, -- 狂风标记
    -----------------------------------------------
    -- NOTE: Shrouded Affix - Shadowlands Season 4
    -- 373391, -- 梦魇
    -- 373429, -- 腐臭虫群
    -----------------------------------------------
    -- NOTE: Encrypted Affix - Shadowlands Season 3
    -- 尤型拆卸者
    -- 366297, -- 解构
    -- 366288, -- 猛力砸击
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
}

function I.GetDefaultBigDebuffs()
    return bigDebuffs
end

-------------------------------------------------
-- aoeHealings
-------------------------------------------------
local aoeHealings = {
    -- druid
    740, -- Tranquility - 宁静
    145205, -- Efflorescence - 百花齐放

    -- evoker
    355916, -- Emerald Blossom - 翡翠之花
    361361, -- Fluttering Seedlings - 婆娑幼苗
    363534, -- Rewind - 回溯
    367230, -- Spiritbloom - 精神之花
    370984, -- Emerald Communion - 翡翠交融
    371441, -- Life-Giver's Flame - 赐命者之焰
    371879, -- Cycle of Life - 生生不息

    -- monk
    115098, -- Chi Wave - 真气波
    123986, -- Chi Burst - 真气爆裂
    115310, -- Revival - 还魂术
    322118, -- Invoke Yu'lon, the Jade Serpent - 青龙下凡 (SUMMON)
    388193, -- 碧火踏 - Jadefire Stomp
    443028, -- Celestial Conduit - 天神御身

    -- paladin
    85222, -- Light of Dawn - 黎明之光
    119952, -- Arcing Light - 弧形圣光
    114165, -- Holy Prism - 神圣棱镜
    200654, -- Tyr's Deliverance - 提尔的拯救
    216371, -- Avenging Crusader - 复仇十字军

    -- priest
    120517, -- Halo - 光晕
    34861, -- Holy Word: Sanctify - 圣言术：灵
    596, -- Prayer of Healing - 治疗祷言
    64843, -- Divine Hymn - 神圣赞美诗
    110744, -- Divine Star - 神圣之星
    204883, -- Circle of Healing - 治疗之环
    281265, -- Holy Nova - 神圣新星
    314867, -- Shadow Covenant - 暗影盟约
    15290, -- Vampiric Embrace - 吸血鬼的拥抱
    372787, -- Divine Word: Sanctuary-- 神言术：佑

    -- shaman
    1064, -- Chain Heal - 治疗链
    73920, -- Healing Rain - 治疗之雨
    108280, -- Healing Tide Totem - 治疗之潮图腾 (SUMMON)
    52042, -- Healing Stream Totem - 治疗之泉图腾 (SUMMON)
    197995, -- Wellspring - 奔涌之流
    157503, -- Cloudburst - 暴雨图腾
    114911, -- Ancestral Guidance - 先祖指引
    382311, -- Ancestral Awakening - 先祖复苏
    207778, -- Downpour - 倾盆大雨
    114083, -- Restorative Mists - 恢复迷雾 (升腾)
}

local aoeHealingIDs = {
    [343819] = true, -- 朱鹤下凡，朱鹤产生的“迷雾之风”的施法者是玩家
    [377509] = true, -- 梦境投影（pvp）
}

do
    local temp = {}
    for _, id in pairs(aoeHealings) do
        temp[F:GetSpellInfo(id)] = true
    end
    aoeHealings = temp
end

function I.IsAoEHealing(nameOrID)
    if not nameOrID then return false end
    return aoeHealings[nameOrID] or aoeHealingIDs[nameOrID]
end

local summonDuration = {
    -- evoker
    [377509] = 6, -- 梦境投影（pvp）- Dream Projection

    -- monk
    [322118] = 25, -- 青龙下凡 - Invoke Yu'lon, the Jade Serpent

    -- shaman
    [108280] = 12, -- 治疗之潮图腾 - Healing Tide Totem
    [52042] = 15, -- 治疗之泉图腾 - Healing Stream Totem
}

do
    local temp = {}
    for id, duration in pairs(summonDuration) do
        temp[F:GetSpellInfo(id)] = duration
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
        [51052] = true, -- Anti-Magic Zone - 反魔法领域
    },

    ["DEMONHUNTER"] = {
        [196718] = true, -- Darkness - 黑暗
    },

    ["DRUID"] = {
        [102342] = true, -- Ironbark - 铁木树皮
    },

    ["EVOKER"] = {
        [374227] = true, -- Zephyr - 微风
        [357170] = true, -- Time Dilation - 时间膨胀
        [378441] = true, -- Time Stop (pvp) - 时间停止
        [374348] = true, -- Renewing blaze - 新生光焰
    },

    ["MAGE"] = {
        [198158] = true, -- Mass Invisibility - 群体隐形
        [414660] = { -- Mass Barrier - 群体屏障
            [414661] = false, -- Ice Barrier - 寒冰护体
            [414662] = false, -- Blazing Barrier - 烈焰护体
            [414663] = false, -- Prismatic Barrier - 棱光护体
            -- [11426] = false, -- 寒冰护体 (self)
            -- [235313] = false, -- 烈焰护体 (self)
            -- [235450] = false, -- 棱光护体 (self)
        },
    },

    ["MONK"] = {
        [116849] = true, -- Life Cocoon - 作茧缚命
        [202248] = false, -- Guided Meditation - 偏转冥想
    },

    ["PALADIN"] = {
        [1022] = true, -- Blessing of Protection - 保护祝福
        [6940] = true, -- Blessing of Sacrifice - 牺牲祝福
        [204018] = true, -- Blessing of Spellwarding-- 破咒祝福
        [31821] = true, -- Aura Mastery - 光环掌握
        [210256] = true, -- Blessing of Sanctuary - 庇护祝福
        [228050] = false, -- Divine Shield - 圣盾术 (被遗忘的女王护卫)
        -- [211210] = true, -- 提尔的保护
        -- [216328] = true, -- 光之优雅
    },

    ["PRIEST"] = {
        [33206] = true, -- Pain Suppression - 痛苦压制
        [47788] = true, -- Guardian Spirit - 守护之魂
        [62618] = true, -- Power Word: Barrier - 真言术：障
        [213610] = true, -- Holy Ward - 神圣守卫
        [197268] = true, -- Ray of Hope - 希望之光
    },

    ["ROGUE"] = {
        [114018] = true, -- Shroud of Concealment - 潜伏帷幕
    },

    ["SHAMAN"] = {
        [98008] = true, -- Spirit Link Totem - 灵魂链接图腾
        [201633] = true, -- Earthen Wall - 大地之墙图腾
        [8178] = true, -- Grounding Totem - 根基图腾
        [383018] = true, -- Stoneskin - 石肤图腾
    },

    ["WARRIOR"] = {
        [97462] = true, -- Rallying Cry - 集结呐喊
        [3411] = true, -- Intervene - 援护
        [213871] = true, -- Bodyguard - 护卫
    },
}

function I.GetExternals()
    return externals
end

local builtInExternals = {}
local customExternals = {}

local function UpdateExternals(id, trackByName)
    if trackByName then
        local name = F:GetSpellInfo(id)
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
        -- local name = F:GetSpellInfo(id)
        -- if name then
        --     customExternals[name] = true
        -- end
        customExternals[id] = true
    end
end

local UnitIsUnit = UnitIsUnit
local bos = F:GetSpellInfo(6940) -- 牺牲祝福
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
        [48707] = true, -- 反魔法护罩 - Anti-Magic Shell
        [48792] = true, -- 冰封之韧 - Icebound Fortitude
        [49028] = true, -- 符文刃舞 - Dancing Rune Weapon
        [55233] = true, -- 吸血鬼之血 - Vampiric Blood
        [49039] = true, -- 巫妖之躯 - Lichborne
        [194679] = true, -- 符文分流 - Rune Tap
    },

    ["DEMONHUNTER"] = {
        [196555] = true, -- 虚空行走 - Netherwalk
        [198589] = true, -- 疾影 - Blur
        [187827] = false, -- 恶魔变形 162264(DPS) - Metamorphosis
    },

    ["DRUID"] = {
        [22812] = true, -- 树皮术 - Barkskin
        [61336] = true, -- 生存本能 - Survival Instincts
        [200851] = true, -- 沉睡者之怒 - Rage of the Sleeper
        [102558] = true, -- 化身：乌索克的守护者 - Incarnation: Guardian of Ursoc
        [22842] = true, -- 狂暴回复 - Frenzied Regeneration
    },

    ["EVOKER"] = {
        [363916] = true, -- 黑曜鳞片 - Obsidian Scales
        [374348] = true, -- 新生光焰 - Renewing Blaze
        [370960] = true, -- 翡翠交融 - Emerald Communion
        [431872] = false, -- Temporality (Chronowarden Hero Talent)
        [377088] = false, -- Rush of Vitality
    },

    ["HUNTER"] = {
        [186265] = true, -- 灵龟守护 - Aspect of the Turtle
        [264735] = true, -- 优胜劣汰 - Survival of the Fittest
    },

    ["MAGE"] = {
        [45438] = true, -- 寒冰屏障 - Ice Block
        [414658] = true, -- 深寒凝冰 - Ice Cold
        [113862] = false, -- Greater Invisibility - 强化隐形术
        [55342] = false, -- 镜像，使用 CLEU 而非 UNIT_AURA - Mirror Image
        [342246] = true, -- 操控时间 - Alter Time
    },

    ["MONK"] = {
        [115176] = false, -- 禅悟冥想 - Zen Meditation
        [115203] = true, -- 壮胆酒 - Fortifying Brew
        [122278] = true, -- 躯不坏 - Dampen Harm
        [122783] = true, -- 散魔功 - Diffuse Magic
        [125174] = true, -- 业报之触 - Touch of Karma
    },

    ["PALADIN"] = {
        [498] = true, -- 圣佑术 - Divine Protection
        [642] = true, -- 圣盾术 - Divine Shield
        [31850] = true, -- 炽热防御者 - Ardent Defender
        [212641] = true, -- 远古列王守卫 - Guardian of Ancient Kings
        [205191] = true, -- 以眼还眼 - Eye for an Eye
        [389539] = true, -- 戒卫 - Sentinel
        [184662] = true, -- 复仇之盾 - Shield of Vengeance
    },

    ["PRIEST"] = {
        [47585] = true, -- 消散 - Dispersion
        [19236] = true, -- 绝望祷言 - Desperate Prayer
        [586] = true, -- 渐隐术 -- TODO: 373446 通透影像 - Fade
        [193065] = true, -- 防护圣光 - Protective Light
        [27827] = true, -- 救赎之魂 - Spirit of Redemption
    },

    ["ROGUE"] = {
        [1966] = true, -- 佯攻 - Feint
        [5277] = true, -- 闪避 - Evasion
        [31224] = false, -- 暗影斗篷 - Cloak of Shadows
    },

    ["SHAMAN"] = {
        [108271] = true, -- 星界转移 - Astral Shift
        [409293] = true, -- 掘地三尺 - Burrow (PVP)
        [114893] = true, -- Stone Bulwark
    },

    ["WARLOCK"] = {
        [104773] = true, -- 不灭决心 - Unending Resolve
        [212295] = true, -- 虚空守卫 - Nether Ward (PVP)
        [108416] = true, -- 黑暗契约 - Dark Pact
    },

    ["WARRIOR"] = {
        [871] = true, -- 盾墙 - Shield Wall
        [12975] = true, -- 破釜沉舟 - Last Stand
        [23920] = true, -- 法术反射 - Spell Reflection
        [118038] = true, -- 剑在人在 - Die by the Sword
        [184364] = true, -- 狂怒回复 - Enraged Regeneration
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
                    local name = F:GetSpellInfo(id)
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
        -- local name = F:GetSpellInfo(id)
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
    -- 77535, -- 鲜血护盾
    195181, -- 白骨之盾 - Bone Shield

    -- demon hunter
    203720, -- 恶魔尖刺 - Demon Spikes

    -- druid
    192081, -- 铁鬃 - Ironfur

    -- monk
    215479, -- 酒醒入定 - Shuffle

    -- paladin
    132403, -- 正义盾击 - Shield of the Righteous

    -- warrior
    2565, -- 盾牌格挡 - Shield Block
}

local tankActiveMitigationNames = {
    -- death knight
    -- F:GetClassColorStr("DEATHKNIGHT")..F:GetSpellInfo(77535).."|r", -- 鲜血护盾
    F:GetClassColorStr("DEATHKNIGHT")..F:GetSpellInfo(195181).."|r", -- 白骨之盾

    -- demon hunter
    F:GetClassColorStr("DEMONHUNTER")..F:GetSpellInfo(203720).."|r", -- 恶魔尖刺

    -- druid
    F:GetClassColorStr("DRUID")..F:GetSpellInfo(192081).."|r", -- 铁鬃

    -- monk
    F:GetClassColorStr("MONK")..F:GetSpellInfo(215479).."|r", -- 铁骨酒

    -- paladin
    F:GetClassColorStr("PALADIN")..F:GetSpellInfo(132403).."|r", -- 正义盾击

    -- warrior
    F:GetClassColorStr("WARRIOR")..F:GetSpellInfo(2565).."|r", -- 盾牌格挡
}

do
    local temp = {}
    for _, id in pairs(tankActiveMitigations) do
        temp[F:GetSpellInfo(id)] = true
    end
    tankActiveMitigations = temp
end

function I.IsTankActiveMitigation(name)
    return tankActiveMitigations[name]
end

function I.GetTankActiveMitigationString()
    return table.concat(tankActiveMitigationNames, ", ").."."
end

-------------------------------------------------
-- dispels
-------------------------------------------------
local dispellable = {}

function I.CanDispel(dispelType)
    if not dispelType then return end
    return dispellable[dispelType]
end

local dispelNodeIDs = {
    -- DRUID ----------------
        -- 102 - Balance
        [102] = {["Curse"] = 82205, ["Poison"] = 82205},
        -- 103 - Feral
        [103] = {["Curse"] = 82204, ["Poison"] = 82204},
        -- 104 - Guardian
        [104] = {["Curse"] = 82215, ["Poison"] = 82215},
        -- Restoration
        [105] = {["Curse"] = 82203, ["Magic"] = true, ["Poison"] = 82203},
    -------------------------

    -- EVOKER ---------------
        -- 1467 - Devastation
        [1467] = {["Curse"] = 93294, ["Disease"] = 93294, ["Poison"] = {93306, 93294}, ["Bleed"] = 93294},
        -- 1468	- Preservation
        [1468] = {["Curse"] = 93294, ["Disease"] = 93294, ["Magic"] = true, ["Poison"] = true, ["Bleed"] = 93294},
        -- 1473 - Augmentation
        [1473] = {["Curse"] = 93294, ["Disease"] = 93294, ["Poison"] = {93306, 93294}, ["Bleed"] = 93294},
    -------------------------

    -- MAGE -----------------
        -- 62 - Arcane
        [62] = {["Curse"] = 62116},
        -- 63 - Fire
        [63] = {["Curse"] = 62116},
        -- 64 - Frost
        [64] = {["Curse"] = 62116},
    -------------------------

    -- MONK -----------------
        -- 268 - Brewmaster
        [268] = {["Disease"] = 101090, ["Poison"] = 101090},
        -- 269 - Windwalker
        [269] = {["Disease"] = 101150, ["Poison"] = 101150},
        -- 270 - Mistweaver
        [270] = {["Disease"] = 101089, ["Magic"] = true, ["Poison"] = 101089},
    -------------------------

    -- PALADIN --------------
        -- 65 - Holy
        [65] = {["Disease"] = 81508, ["Magic"] = true, ["Poison"] = 81508, ["Bleed"] = 81616},
        -- 66 - Protection
        [66] = {["Disease"] = 81507, ["Poison"] = 81507, ["Bleed"] = 81616},
        -- 70 - Retribution
        [70] = {["Disease"] = 81507, ["Poison"] = 81507, ["Bleed"] = 81616},
    -------------------------

    -- PRIEST ---------------
        -- 256 - Discipline
        [256] = {["Disease"] = 82705, ["Magic"] = true},
        -- 257 - Holy
        [257] = {["Disease"] = 82705, ["Magic"] = true},
        -- 258 - Shadow
        [258] = {["Disease"] = 82704, ["Magic"] = 82699},
    -------------------------

    -- SHAMAN ---------------
        -- 262 - Elemental
        [262] = {["Curse"] = 103608, ["Poison"] = 103609},
        -- 263 - Enhancement
        [263] = {["Curse"] = 103608, ["Poison"] = 103609},
        -- 264 - Restoration
        [264] = {["Curse"] = 81073, ["Magic"] = true, ["Poison"] = 103609},
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
    eventFrame:RegisterEvent("TRAIT_CONFIG_UPDATED")
    -- eventFrame:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED")

    local function UpdateDispellable()
        -- update dispellable
        wipe(dispellable)
        local activeConfigID = C_ClassTalents.GetActiveConfigID()
        if activeConfigID and dispelNodeIDs[Cell.vars.playerSpecID] then
            for dispelType, value in pairs(dispelNodeIDs[Cell.vars.playerSpecID]) do
                if type(value) == "boolean" then
                    dispellable[dispelType] = value
                elseif type(value) == "table" then -- more than one trait
                    for _, v in pairs(value) do
                        local nodeInfo = C_Traits.GetNodeInfo(activeConfigID, v)
                        if nodeInfo and nodeInfo.ranksPurchased ~= 0 then
                            dispellable[dispelType] = true
                            break
                        end
                    end
                else -- number: check node info
                    local nodeInfo = C_Traits.GetNodeInfo(activeConfigID, value)
                    if nodeInfo and nodeInfo.ranksPurchased ~= 0 then
                        dispellable[dispelType] = true
                    end
                end
            end
        end

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

    Cell:RegisterCallback("SpecChanged", "Dispellable_SpecChanged", function()
        if timer then timer:Cancel() end
        timer = C_Timer.NewTimer(1, UpdateDispellable)
    end)
end

-------------------------------------------------
-- drinking
-------------------------------------------------
local drinks = {
    170906, -- 食物和饮水 - Food & Drink
    167152, -- 进食饮水 - Refreshment
    430, -- 喝水 - Drink
    43182, -- 饮水 - Drink
    172786, -- 饮料 - Drink
    308433, -- 食物和饮料 - Food & Drink
    369162, -- 饮用 - Drink
}

do
    local temp = {}
    for _, id in pairs(drinks) do
        temp[F:GetSpellInfo(id)] = true
    end
    drinks = temp
end

function I.IsDrinking(name)
    return drinks[name]
end

-------------------------------------------------
-- healer
-------------------------------------------------
local spells =  {
    -- druid
    8936, -- Regrowth - 愈合
    774, -- Rejuvenation - 回春术
    155777, -- Rejuvenation (Germination) - 回春术（萌芽）
    33763, -- Lifebloom - 生命绽放
    188550, -- Lifebloom - 生命绽放
    48438, -- Wild Growth - 野性成长
    102351, -- Cenarion Ward - 塞纳里奥结界
    102352, -- Cenarion Ward - 塞纳里奥结界
    391891, -- Adaptive Swarm - 激变蜂群
    145205, -- Efflorescence - 百花齐放
    383193, -- Grove Tending - 林地护理
    439530, -- Symbiotic Blooms - 共生绽华
    429224, -- Minor Cenarion Ward - 次级塞纳里奥结界

    -- evoker
    363502, -- Dream Flight - 梦境飞行
    370889, -- Twin Guardian - 双生护卫
    364343, -- Echo - 回响
    355941, -- Dream Breath - 梦境吐息
    376788, -- Dream Breath (Echo) - 梦境吐息（回响）
    366155, -- Reversion - 逆转
    367364, -- Reversion (Echo) - 逆转（回响）
    373862, -- Temporal Anomaly - 时空畸体
    378001, -- Dream Projection (pvp) - 梦境投影（pvp）
    373267, -- Lifebind - 缚誓生命
    395296, -- Ebon Might - 黑檀之力 (self)
    395152, -- Ebon Might - 黑檀之力
    360827, -- Blistering Scales - 炽火龙鳞
    410089, -- Prescience - 先知先觉
    406732, -- Spatial Paradox - 空间悖论 (self)
    406789, -- Spatial Paradox - 空间悖论
    445740, -- Enkindle- 纵焰
    409895, -- Spiritbloom (Reverberations, Chronowarden Hero Talent)

    -- monk
    119611, -- Renewing Mist - 复苏之雾
    124682, -- Enveloping Mist - 氤氲之雾
    325209, -- Enveloping Breath - 氤氲之息
    406139, -- Chi Cocoon - 真气之茧
    -- 386276, -- 骨尘酒
    -- 115175, -- 抚慰之雾
    -- 198533, -- 抚慰之雾
    -- 387766, -- 滋养真气
    -- 196725, -- Refreshing Jade Wind - 碧愈疾风
    450805, -- Purified Spirit - 净化之魂
    423439, -- Chi Harmony

    -- paladin
    53563, -- Beacon of Light - 圣光道标
    223306, -- Bestow Faith - 赋予信仰
    148039, -- Barrier of Faith - 信仰屏障
    156910, -- Beacon of Faith - 信仰道标
    200025, -- Beacon of Virtue - 美德道标
    287280, -- Glimmer of Light - 圣光闪烁
    156322, -- Eternal Flame - 永恒之火
    431381, -- Dawnlight - 晨光
    388013, -- Blessing of Spring - 阳春祝福
    388007, -- Blessing of Summer - 仲夏祝福
    388010, -- Blessing of Autumn - 暮秋祝福
    388011, -- Blessing of Winter - 凛冬祝福
    200654, -- Tyr's Deliverance - 提尔的拯救

    -- priest
    139, -- Renew - 恢复
    41635, -- Prayer of Mending - 愈合祷言
    17, -- Power Word: Shield - 真言术：盾
    194384, -- Atonement - 救赎
    77489, -- Echo of Light - 圣光回响
    372847, -- Blessed Bolt - 光明之泉恢复
    443526, -- Premonition of Solace -- 慰藉预兆

    -- shaman
    974, -- Earth Shield - 大地之盾
    383648, -- Earth Shield - 大地之盾（天赋）
    61295, -- Riptide - 激流
    382024, -- Earthliving Weapon - 大地生命武器
    375986, -- Primordial Wave - 始源之潮
    444490, -- Hydrobubble - 源水气泡
    -- 73920, -- Healing Rain - 治疗之雨
    -- 456366, -- Healing Rain - 治疗之雨
}

function F:FirstRun()
    local icons = "\n\n"
    for i, id in pairs(spells) do
        local icon = select(2, F:GetSpellInfo(id))
        if icon then
            icons = icons .. "|T"..icon..":0|t"
            if i % 11 == 0 then
                icons = icons .. "\n"
            end
        end
    end

    local popup = Cell:CreateConfirmPopup(Cell.frames.anchorFrame, 200, L["Would you like Cell to create a \"Healers\" indicator (icons)?"]..icons, function(self)
        local currentLayoutTable = Cell.vars.currentLayoutTable

        local last = #currentLayoutTable["indicators"]
        if currentLayoutTable["indicators"][last]["type"] == "built-in" then
            indicatorName = "indicator1"
        else
            indicatorName = "indicator"..(tonumber(strmatch(currentLayoutTable["indicators"][last]["indicatorName"], "%d+"))+1)
        end

        tinsert(currentLayoutTable["indicators"], {
            ["name"] = "Healers",
            ["indicatorName"] = indicatorName,
            ["type"] = "icons",
            ["enabled"] = true,
            ["position"] = {"TOPRIGHT", "TOPRIGHT", 0, 3},
            ["frameLevel"] = 5,
            ["size"] = {13, 13},
            ["num"] = 5,
            ["numPerLine"] = 5,
            ["orientation"] = "right-to-left",
            ["spacing"] = {0, 0},
            ["font"] = {
                {"Cell ".._G.DEFAULT, 11, "Outline", false, "TOPRIGHT", 2, 1, {1, 1, 1}},
                {"Cell ".._G.DEFAULT, 11, "Outline", false, "BOTTOMRIGHT", 2, -1, {1, 1, 1}},
            },
            ["showStack"] = true,
            ["showDuration"] = false,
            ["showAnimation"] = true,
            ["auraType"] = "buff",
            ["castBy"] = "me",
            ["auras"] = spells,
        })
        Cell:Fire("UpdateIndicators", Cell.vars.currentLayout, indicatorName, "create", currentLayoutTable["indicators"][last+1])
        CellDB["firstRun"] = false
        F:ReloadIndicatorList()
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
--         local icon = select(2, F:GetSpellInfo(c[1]))
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
    -- Mists of Pandaria -----------
    -- 青龙寺 - Temple of the Jade Serpent
    106823, -- 翔龙猛袭 - Serpent Strike
    106841, -- 青龙猛袭 - Jade Serpent Strike

    -- Legion ----------------------
    -- 群星庭院 - Court of Stars
    211473, -- 暗影鞭笞 - Shadow Slash
    -- 英灵殿 - Halls of Valor
    193092, -- 放血扫击 - Bloodletting Sweep
    193659, -- 邪炽冲刺 - Felblaze Rush
    192018, -- 光明之盾 - Shield of Light
    196838, -- 血之气息 - Scent of Blood

    -- Shadowlands -----------------
    -- Necrotic Wake
    320788, -- 冻结之缚 - Frozen Binds
    320596, -- 深重呕吐 - Heaving Retch
    338606, -- 病态凝视 - Morbid Fixation
    343556, -- 病态凝视 - Morbid Fixation
    -- Castle Nathria
    344496, -- 震荡爆发 - Reverberating Eruption
    -- Halls of Atonement
    319941, -- 碎石之跃 - Stone Shattering Leap
    -- Mists of Tirna Scithe
    322614, -- 心灵连接 - Mind Link
    -- De Other Side
    320132, -- 暗影之怒 - Shadowfury
    332234, -- 挥发精油 - Essential Oil
    -- Spires of Ascenscion
    334053, -- 净化冲击波 - Purifying Blast
    317963, -- 知识烦扰 - Burden of Knowledge
    -- Sanguine Depths
    319713, -- 巨兽奔袭 - Juggernaut Rush
    -- Theater of Pain
    324079, -- 收割之镰 - Reaping Scythe
    333861, -- 回旋利刃 - Ricocheting Blade
    -- Plaguefall
    -- 328429, -- 窒息勒压
    356924, -- 屠戮 - Carnage
    356666, -- 刺骨之寒 - Biting Cold

    -- Dragonflight ----------------
    -- 化身巨龙牢窟 - Vault of the Incarnates
    375870, -- 致死石爪 - Mortal Stoneclaws
    395906, -- 电化之颌 - Electrified Jaws
    372158, -- 破甲一击 - Sundering Strike
    372056, -- 碾压 - Crush
    375580, -- 西风猛击 - Zephyr Slam
    376276, -- 震荡猛击 - Concussive Slam
    -- 亚贝鲁斯，焰影熔炉 - Aberrus, the Shadowed Crucible
    401022, -- 灾祸掠击 - Calamitous Strike
    407790, -- 身影碎离 - Sunder Shadow
    -- 阿梅达希尔，梦境之愿 - Amirdrassil, the Dream's Hope
    418637, -- 狂怒冲锋 - Furious Charge
    -- 红玉新生法池 - Ruby Life Pools
    372858, -- 灼热打击 - Searing Blows
    381512, -- 风暴猛击 - Stormslam
    -- 奈萨鲁斯 - Neltharus
    374533, -- 炽热挥舞 - Heated Swings
    377018, -- 熔火真金 - Molten Gold
    -- 蕨皮山谷 - Brackenhid Hollow
    381444, -- 野蛮冲撞 - Savage Charge
    373912, -- 腐朽打击 - Decaystrike
    -- 碧蓝魔馆 - Azure Vault
    374789, -- 注能打击 - Infused Strike
    372222, -- 奥术顺劈 - Arcane Cleave
    384978, -- 巨龙打击 - Dragon Strike
    391136, -- 肩部猛击 - Shoulder Slam
    -- 诺库德阻击战 - The Nokhud Offensive
    376827, -- 传导打击 - Conductive Strike
    376829, -- 雷霆打击 - Thunder Strike
    375937, -- 撕裂猛击 - Rending Strike
    375929, -- 野蛮打击 - Savage Strike
    376644, -- 钢铁之矛 - Iron Spear
    376865, -- 静电之矛 - Static Spear
    382836, -- 残杀 - Brutalize
}

function I.GetDefaultTargetedSpellsList()
    return targetedSpells
end

function I.GetDefaultTargetedSpellsGlow()
    return {"Pixel", {0.95,0.95,0.32,1}, 9, 0.25, 8, 2}
end

-------------------------------------------------
-- Actions: Healing Potion & Healthstone ...
-------------------------------------------------
local actions = {
    {
        6262, -- 治疗石 - Healthstone
        {"A", {0.4, 1, 0}},
    },
    {
        431416, -- Algari Healing Potion
        {"A", {1, 0.1, 0.1}},
    },
    {
        431932, -- Tempered Potion
        {"C3", {1, 1, 0}},
    },
    -- {
    --     370511, -- 振奋治疗药水 - Refreshing Healing Potion
    --     {"A", {1, 0.1, 0.1}},
    -- },
    -- {
    --     371024, -- 元素强能药水 - Elemental Potion of Power
    --     {"C3", {1, 1, 0}},
    -- },
    -- {
    --     359867, -- 宇宙治疗药水
    --     {"A", {1, 0.1, 0.1}},
    -- },
    -- {
    --     307192, -- 灵魂治疗药水
    --     {"A", {1, 0.1, 0.1}},
    -- },
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
local buffsOrder = {"PWF", "MotW", "AB", "BS", "BotB", "SF"}

local missingBuffs = {
    ["PWF"] = 21562,
    ["MotW"] = 1126,
    ["AB"] = 1459,
    ["BS"] = 6673,
    ["BotB"] = 364342,
    ["SF"] = 462854
}

do
    local temp = {}
    for _, k in pairs(buffsOrder) do
        local id = missingBuffs[k]
        local name, icon = F:GetSpellInfo(id)
        if name then
            tinsert(temp, {
                ["id"] = id,
                ["name"] = name,
                ["icon"] = icon,
                ["index"] = k,
            })
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
        s = s.."|T"..t["icon"]..":14:14:0:0:14:14:1:13:1:13|t".." "
    end
    return s
end

function I.GetMissingBuffsFilters()
    local ret = {}
    for _, t in pairs(missingBuffs) do
        tinsert(ret, {"|T"..t["icon"]..":14:14:0:0:14:14:1:13:1:13|t "..t["name"], t["index"]})
    end
    return ret
end

-------------------------------------------------
-- crowdControls
-------------------------------------------------
local crowdControls = { -- true: track by name, false: track by id
    ["DEATHKNIGHT"] = {
        [47476] = true, -- 绞袭 - Strangulate (PVP)
        [91800] = true, -- 撕扯 - Gnaw
        [207167] = true, -- 致盲冰雨 - Blinding Sleet
        [210128] = true, -- 复苏 - Reanimation
        [221562] = true, -- 窒息 - Asphyxiate
        [287254] = false, -- 寒冬死神 - Dead of Winter
        [377048] = true, -- 绝对零度 - Absolute Zero
    },

    ["DEMONHUNTER"] = {
        [179057] = true, -- 混乱新星 - Chaos Nova
        [205630] = true, -- 伊利丹之握 - Illidan's Grasp
        [204490] = true, -- 沉默咒符 - Sigil of Silence
        [207684] = true, -- 悲苦咒符 - Sigil of Misery
        [211881] = true, -- 邪能爆发 - Fel Eruption
        [217832] = true, -- 禁锢 - Imprison
        -- [213491] = true, -- 恶魔践踏
    },

    ["DRUID"] = {
        [99] = true, -- 夺魂咆哮 - Incapacitating Roar
        [2637] = true, -- 休眠 - Hibernate
        [5211] = true, -- 蛮力猛击 - Mighty Bash
        [22570] = true, -- 割碎 - Maim
        [33786] = true, -- 旋风 - Cyclone
        [81261] = true, -- 日光术 - Solar Beam
        [127797] = true, -- 乌索尔旋风 - Ursol's Vortex
        [163505] = false, -- 斜掠 - Rake
        [209749] = true, -- 精灵虫群 - Faerie Swarm
        [202244] = true, -- 蛮力冲锋 - Overrun
        [410065] = false, -- 活性树脂 - Reactive Resin
    },

    ["EVOKER"] = {
        [360806] = true, -- 梦游 - Sleep Walk
        [372245] = true, -- 天空霸主 - Terror of the Skies
        [408544] = true, -- 震地猛击 - Seismic Slam
    },

    ["HUNTER"] = {
        [1513] = true, -- 恐吓野兽 - Scare Beast
        [3355] = true, -- 冰冻陷阱 - Freezing Trap
        [24394] = true, -- 胁迫 - Intimidation
        [117526] = true, -- 束缚射击 - Binding Shot
        [213691] = true, -- 驱散射击 - Scatter Shot
        [357021] = false, -- 连续震荡 - Consecutive Concussion
        [407032] = true, -- 粘稠焦油炸弹 - Sticky Tar Bomb
    },

    ["MAGE"] = {
        [118] = true, -- 变形术 - Polymorph
        [31661] = true, -- 龙息术 - Dragon's Breath
        [82691] = true, -- 冰霜之环 - Ring of Frost
        [383121] = true, -- 群体变形 - Mass Polymorph
        [389831] = false, -- 积雪 - Snowdrift
    },

    ["MONK"] = {
        [115078] = true, -- 分筋错骨 - Paralysis
        [119381] = true, -- 扫堂腿 - Leg Sweep
        [198909] = true, -- 赤精之歌 - Song of Chi-Ji
        [202274] = true, -- 热酿 - Hot Trub
        [202346] = true, -- 醉上加醉 - Double Barrel
        [233759] = true, -- 抓钩武器 - Grapple Weapon (PVP)
    },

    ["PALADIN"] = {
        [853] = true, -- 制裁之锤 - Hammer of Justice
        [10326] = true, -- 超度邪恶 - Turn Evil
        [20066] = true, -- 忏悔 - Repentance
        [105421] = true, -- 盲目之光 - Blinding Light
        [234299] = true, -- 制裁之拳 - Fist of Justice
        [255941] = false, -- 灰烬觉醒 - Wake of Ashes
    },

    ["PRIEST"] = {
        [605] = true, -- 精神控制 - Mind Control
        [8122] = true, -- 心灵尖啸 - Psychic Scream
        [9484] = true, -- 束缚亡灵 - Shackle Undead
        [15487] = true, -- 沉默 - Silence
        [64044] = true, -- 心灵惊骇 - Psychic Horror
        [88625] = true, -- 圣言术-罚 - Holy Word: Chastise
        -- [226943] = true, -- 心灵炸弹
    },

    ["ROGUE"] = {
        [408] = true, -- 肾击 - Kidney Shot
        [1776] = true, -- 凿击 - Gouge
        [1833] = true, -- 偷袭 - Cheap Shot
        [2094] = true, -- 致盲 - Blind
        [6770] = true, -- 闷棍 - Sap
        [207777] = true, -- 卸除武装 - Dismantle (PVP)
        [212183] = true, -- 烟雾弹 - Smoke Bomb
    },

    ["SHAMAN"] = {
        [51514] = true, -- 妖术 - Hex
        [77505] = true, -- 地震术 - Earthquake
        [118345] = true, -- 粉碎 - Pulverize
        [118905] = true, -- 静电充能 - Static Charge
        [197214] = true, -- 裂地术 - Sundering
        [305485] = true, -- 闪电磁索 - Lightning Lasso
    },

    ["WARLOCK"] = {
        [710] = true, -- 放逐术 - Banish
        [5484] = true, -- 恐惧嚎叫 - Howl of Terror
        [5782] = true, -- 恐惧 - Fear
        [6358] = true, -- 诱惑 - Seduction
        [6789] = true, -- 死亡缠绕 - Mortal Coil
        [22703] = true, -- 地狱火觉醒 - Infernal Awakening
        [30283] = true, -- 暗影之怒 - Shadowfury
        [89766] = true, -- 巨斧投掷 - Axe Toss
        [196364] = false, -- 痛苦无常 - Unstable Affliction
        [213688] = true, -- 邪能顺劈 - Fel Cleave
    },

    ["WARRIOR"] = {
        [5246] = true, -- 破胆怒吼 - Intimidating Shout
        [132168] = true, -- 震荡波 - Shockwave
        [132169] = true, -- 风暴之锤 - Storm Bolt
        [236077] = true, -- 缴械 - Disarm (PVP)
    },

    ["UNCATEGORIZED"] = {
        [20549] = true, -- 战争践踏 - War Stomp
        [107079] = true, -- 震山掌 - Quaking Palm
        [255723] = true, -- 蛮牛冲撞 - Bull Rush
        [287712] = true, -- 强力一击 - Haymaker
    }
}

function I.GetCrowdControls()
    return crowdControls
end

local builtInCrowdControls = {}
local customCrowdControls = {}

function I.UpdateCrowdControls(t)
    -- user disabled
    wipe(builtInCrowdControls)
    for class, spells in pairs(crowdControls) do
        for id, trackByName in pairs(spells) do
            if not t["disabled"][id] then -- not disabled
                if trackByName then
                    local name = F:GetSpellInfo(id)
                    if name then
                        builtInCrowdControls[name] = true
                    end
                else
                    builtInCrowdControls[id] = true
                end
            end
        end
    end

    -- user created
    wipe(customCrowdControls)
    for _, id in pairs(t["custom"]) do
        local name = F:GetSpellInfo(id)
        if name then
            customCrowdControls[name] = true
        end
    end
end

function I.IsCrowdControls(name, id)
    return builtInCrowdControls[name] or builtInCrowdControls[id] or customCrowdControls[name]
end
