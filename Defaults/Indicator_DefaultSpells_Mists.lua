local _, Cell = ...
local L = Cell.L
local I = Cell.iFuncs
local F = Cell.funcs

-------------------------------------------------
-- dispelBlacklist
-------------------------------------------------
-- supress dispel highlight
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
    89798, -- 大冒险家奖励
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
    46392, -- 专注打击
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
    },
    ["PALADIN"] = {
        [85222] = true, -- 黎明圣光
        [82327] = true, -- 圣光普照
    },
    ["PRIEST"] = {
        [596]   = true, -- 治疗祷言
        [64843] = true, -- 神圣赞美诗
        [34861] = true, -- 治疗之环
        [15237] = true, -- 神圣新星
        [81751] = true, -- 救赎
        [15290] = true, -- 吸血鬼的拥抱
    },
    ["SHAMAN"] = {
        [1064]  = true, -- 治疗链
        [73920] = true, -- 治疗之雨
        -- [52042] = true, -- 治疗之泉图腾
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

local summonDuration = {}

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

    ["MONK"] = {
        [116849] = true, -- 作茧缚命 - Life Cocoon
    },

    ["PALADIN"] = {
        [1022] = true, -- 保护祝福
        [6940] = true, -- 牺牲祝福
        [64205] = true, -- 神圣牺牲
        [70940] = true, -- 神圣护卫者
        [31821] = true, -- 光环掌握
    },

    ["PRIEST"] = {
        [33206] = true, -- 痛苦压制
        [47788] = true, -- 守护之魂
        [62618] = true, -- 真言术：障
    },

    ["SHAMAN"] = {
        [98008] = true, -- 灵魂链接图腾
    },

    ["WARRIOR"] = {
        [3411] = true, -- 援护
    },
}

function I.GetExternals()
    return externals
end

local builtInExternals = {}
local customExternals = {}

function I.UpdateExternals(t)
       -- user disabled
    wipe(builtInExternals)
    for class, spells in pairs(externals) do
        for id, trackByName in pairs(spells) do
            if not t["disabled"][id] then -- not disabled
                if trackByName then
                    local name = F.GetSpellInfo(id)
                    if name then
                        builtInExternals[name] = true
                    end
                else
                    builtInExternals[id] = true
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

function I.IsExternalCooldown(name, id, source, target)
    return builtInExternals[name] or builtInExternals[id] or customExternals[id]
end

-------------------------------------------------
-- defensiveCooldowns
-------------------------------------------------
local defensives = { -- true: track by name, false: track by id
    ["DEATHKNIGHT"] = {
        [48707] = true, -- 反魔法护罩
        [48792] = true, -- 冰封之韧
        [55233] = true, -- 吸血鬼之血
        [49028] = true, -- 符文刃舞
        [49039] = true, -- 巫妖之躯
        [81162] = true, -- 大墓地的意志
    },

    ["DRUID"] = {
        [22812] = true, -- 树皮术
        [22842] = true, -- 狂暴回复
        [61336] = true, -- 生存本能
    },

    ["HUNTER"] = {
        [19263] = true, -- 威慑
    },

    ["MAGE"] = {
        [45438] = true, -- 寒冰屏障
    },

    ["MONK"] = {
        -- TODO: Add defensives
        [115]
    },

    ["PALADIN"] = {
        [498] = true, -- 圣佑术
        [642] = true, -- 圣盾术
        [86150] = true, -- 远古列王守卫
    },

    ["PRIEST"] = {
        [47585] = true, -- 消散
        [27827] = true, -- 救赎之魂
    },

    ["ROGUE"] = {
        [1966] = true, -- 佯攻
        [5277] = true, -- 闪避
        [31224] = false, -- 暗影斗篷
    },

    ["SHAMAN"] = {
        [30823] = true, -- 萨满之怒
    },

    ["WARRIOR"] = {
        [871] = true, -- 盾墙
        [12975] = true, -- 破釜沉舟
        [23920] = true, -- 法术反射
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

local defensiveBlacklist = {
    [67378] = true,
    [67354] = true,
    [67380] = true,
}

function I.IsDefensiveCooldown(name, id)
    if defensiveBlacklist[id] then return end
    return builtInDefensives[name] or builtInDefensives[id] or customDefensives[id]
end

-------------------------------------------------
-- dispels
-------------------------------------------------
local dispellable = {}

function I.CanDispel(dispelType)
    if not dispelType then return end
    return dispellable[dispelType]
end

local dispels = {
    -- DRUID ----------------
    [11] = {["Curse"] = true, ["Magic"] = "3,15", ["Poison"] = true},

    -- MAGE -----------------
    [8] = {["Curse"] = true},

    -- PALADIN --------------
    [2] = {["Disease"] = true, ["Magic"] = "1,7", ["Poison"] = true, ["Bleed"] = true},

    -- PRIEST ---------------
    -- TODO: 身心合一天赋可以解自己的毒
    [5] = {["Disease"] = true, ["Magic"] = true},

    -- SHAMAN ---------------
    [7] = {["Curse"] = true, ["Magic"] = "3,14"},
}

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
eventFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

local function UpdateDispellable()
    wipe(dispellable)
    if dispels[Cell.vars.playerClassID] then
        for dispelType, value in pairs(dispels[Cell.vars.playerClassID]) do
            if type(value) == "boolean" then
                dispellable[dispelType] = value
            elseif select(5, GetTalentInfo(strsplit(",", value))) == 1 then
                dispellable[dispelType] = true
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

-------------------------------------------------
-- drinking
-------------------------------------------------
local drinks = {
    430, -- 喝水
    43182, -- 饮水
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
local spells =  {
    -- druid
    774, -- 回春术
    8936, -- 愈合
    33763, -- 生命绽放
    48438, -- 野性成长
    50464, -- 滋养
    -- paladin
    53563, -- 圣光道标
    -- priest
    139, -- 恢复
    41635, -- 愈合祷言
    17, -- 真言术：盾
    7001, -- 光明之泉恢复
    -- shaman
    974, -- 大地之盾
    61295, -- 激流
    51945, -- 大地生命
}

function F.FirstRun()
    local icons = "\n\n"
    for i, id in pairs(spells) do
        local icon = select(2, F.GetSpellInfo(id))
        icons = icons .. "|T"..icon..":0|t"
        if i % 11 == 0 then
            icons = icons .. "\n"
        end
    end

    local popup = Cell.CreateConfirmPopup(Cell.frames.anchorFrame, 200, L["Would you like Cell to create a \"Healers\" indicator (icons)?"]..icons, function(self)
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
            ["position"] = {"TOPRIGHT", "button", "TOPRIGHT", 0, 3},
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
            ["glowOptions"] = {"None", {0.95, 0.95, 0.32, 1}},
            ["auraType"] = "buff",
            ["castBy"] = "me",
            ["trackByName"] = true,
            ["auras"] = spells,
        })
        Cell.Fire("UpdateIndicators", Cell.vars.currentLayout, indicatorName, "create", currentLayoutTable["indicators"][last+1])
        CellDB["firstRun"] = false
        F.ReloadIndicatorList()
    end, function()
        CellDB["firstRun"] = false
    end)
    popup:SetPoint("TOPLEFT")
    popup:Show()
end

-------------------------------------------------
-- targetedSpells
-------------------------------------------------
local targetedSpells = {

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
local buffsOrder = {"PWF", "AB", "MotW", "BoK", "LotE", "BoM", "BS", "CS"}
local abbrToIndex = {}

local missingBuffs = {
    ["PWF"] = 21562,
    ["AB"] = 1459,
    ["MotW"] = 1126,
    ["BoK"] = 20217,
    ["LotE"] = 117666,
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
        s = s.."|T"..t["icon"]..":14:14:0:0:14:14:1:13:1:13|t".." "
    end
    return s
end

function I.GetMissingBuffsFilters()
    local indicies = {
        "PWF",
        "AB",
        "MotW",
        {"PALADIN", {"BoK", "BoM"}},
        "LotE",
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