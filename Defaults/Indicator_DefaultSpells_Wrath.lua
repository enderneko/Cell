local _, Cell = ...
local L = Cell.L
local I = Cell.iFuncs
local F = Cell.funcs

-------------------------------------------------
-- dispelBlacklist
-------------------------------------------------
-- supress dispel highlight
local dispelBlacklist = {}

function I:GetDefaultDispelBlacklist()
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

function I:GetDefaultDebuffBlacklist()
    -- local temp = {}
    -- for i, id in pairs(debuffBlacklist) do
    --     temp[i] = GetSpellInfo(id)
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

function I:GetDefaultBigDebuffs()
    return bigDebuffs
end


-------------------------------------------------
-- aoeHealings
-------------------------------------------------
local aoeHealings = {
    -- druid
    740, -- 宁静

    -- priest
    596, -- 治疗祷言
    64843, -- 神圣赞美诗
    34866, -- 治疗之环

    -- shaman
    1064, -- 治疗链
}

do
    local temp = {}
    for _, id in pairs(aoeHealings) do
        temp[GetSpellInfo(id)] = true
    end
    aoeHealings = temp
end

function I:IsAoEHealing(name)
    if not name then return false end
    return aoeHealings[name]
end

local summonDuration = {

}

do
    local temp = {}
    for id, duration in pairs(summonDuration) do
        temp[GetSpellInfo(id)] = duration
    end
    summonDuration = temp
end

function I:GetSummonDuration(spellName)
    return summonDuration[spellName]
end

-------------------------------------------------
-- externalCooldowns
-------------------------------------------------
local externals = { -- true: track by name, false: track by id
    ["DEATHKNIGHT"] = {
        [51052] = true, -- 反魔法领域
    },

    ["PALADIN"] = {
        [1022] = true, -- 保护祝福
        [6940] = true, -- 牺牲祝福
        [64205] = true, -- 神圣牺牲
        [70940] = true, -- 神圣护卫者
        [19752] = true, -- 神圣干涉
        [31821] = true, -- 光环掌握
        [20236] = true, -- 强化圣疗术（天赋）
    },

    ["PRIEST"] = {
        [33206] = true, -- 痛苦压制
        [47788] = true, -- 守护之魂
    },

    ["WARRIOR"] = {
        [3411] = true, -- 援护
    },
}

function I:GetExternals()
    return externals
end

local builtInExternals = {}
local customExternals = {}

function I:UpdateExternals(t)
       -- user disabled
    wipe(builtInExternals)
    for class, spells in pairs(externals) do
        for id, trackByName in pairs(spells) do
            if not t["disabled"][id] then -- not disabled
                if trackByName then
                    local name = GetSpellInfo(id)
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
        local name = GetSpellInfo(id)
        if name then
            customExternals[name] = true
        end
    end
end

function I:IsExternalCooldown(name, id, source, target)
    return builtInExternals[name] or builtInExternals[id] or customExternals[name]
end

-------------------------------------------------
-- defensiveCooldowns
-------------------------------------------------
local defensives = { -- true: track by name, false: track by id
    ["DEATHKNIGHT"] = {
        [48707] = true, -- 反魔法护罩
        [48792] = true, -- 冰封之韧
        [55233] = true, -- 吸血鬼之血
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

    ["PALADIN"] = {
        [498] = true, -- 圣佑术
        [642] = true, -- 圣盾术
    },

    ["PRIEST"] = {
        [47585] = true, -- 消散
        [27827] = true, -- 救赎之魂
    },

    ["ROGUE"] = {
        [1966] = true, -- 佯攻
        [5277] = true, -- 闪避
        [31224] = true, -- 暗影斗篷
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

function I:GetDefensives()
    return defensives
end

local builtInDefensives = {}
local customDefensives = {}

function I:UpdateDefensives(t)
    -- user disabled
    wipe(builtInDefensives)
    for class, spells in pairs(defensives) do
        for id, trackByName in pairs(spells) do
            if not t["disabled"][id] then -- not disabled
                if trackByName then
                    local name = GetSpellInfo(id)
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
        local name = GetSpellInfo(id)
        if name then
            customDefensives[name] = true
        end
    end
end

local defensiveBlacklist = {
    [67378] = true,
    [67354] = true,
    [67380] = true,
}

function I:IsDefensiveCooldown(name, id)
    if defensiveBlacklist[id] then return end
    return builtInDefensives[name] or builtInDefensives[id] or customDefensives[name]
end

-------------------------------------------------
-- dispels
-------------------------------------------------
local dispellable = {
    -- DRUID ----------------
    [11] = {["Curse"] = true, ["Poison"] = true},
        
    -- MAGE -----------------
    [8] = {["Curse"] = true},
        
    -- PALADIN --------------
    [2] = {["Disease"] = true, ["Magic"] = true, ["Poison"] = true},
    
    -- PRIEST ---------------
    -- NOTE: 全心全意天赋可以解自己的毒
    [5] = {["Disease"] = true, ["Magic"] = true},

    -- SHAMAN ---------------
    [7] = {["Disease"] = true, ["Poison"] = true},
}

function I:CanDispel(dispelType)
    if not dispelType then return end
    
    if dispellable[Cell.vars.playerClassID] then
        if Cell.vars.playerClassID == 7 then -- 萨满
            -- NOTE: 净化灵魂天赋可以解除诅咒
            dispellable[Cell.vars.playerClassID]["Curse"] = IsSpellKnown(51886)
        end
        return dispellable[Cell.vars.playerClassID][dispelType]
    else
        return
    end
end

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
        temp[GetSpellInfo(id)] = true
    end
    drinks = temp
end

function I:IsDrinking(name)
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
    53601, -- 圣洁护盾
    -- priest
    139, -- 恢复
    41635, -- 愈合祷言
    17, -- 真言术：盾
    28276, -- 光明之泉恢复
    -- shaman
    974, -- 大地之盾
    61295, -- 激流
}

function F:FirstRun()
    local icons = "\n\n"
    for i, id in pairs(spells) do
        local icon = select(3, GetSpellInfo(id))
        icons = icons .. "|T"..icon..":0|t"
        if i % 11 == 0 then
            icons = icons .. "\n"    
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
            ["orientation"] = "right-to-left",
            ["font"] = {
                {"Cell ".._G.DEFAULT, 11, "Outline", "TOPRIGHT", 2, 1, {1, 1, 1}},
                {"Cell ".._G.DEFAULT, 11, "Outline", "BOTTOMRIGHT", 2, -1, {1, 1, 1}},
            },
            ["showStack"] = true,
            ["showDuration"] = false,
            ["showAnimation"] = true,
            ["auraType"] = "buff",
            ["castBy"] = "me",
            ["trackByName"] = true,
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
-- targetedSpells
-------------------------------------------------
local targetedSpells = {
    
}

function I:GetDefaultTargetedSpellsList()
    return targetedSpells
end

function I:GetDefaultTargetedSpellsGlow()
    return {"Pixel", {0.95,0.95,0.32,1}, 9, 0.25, 8, 2}
end

-------------------------------------------------
-- Consumables: Healing Potion & Healthstone
-------------------------------------------------
local consumables = {
    
}


function I:GetDefaultConsumables()
    return consumables
end

function I:ConvertConsumables(db)
    local temp = {}
    for _, t in pairs(db) do
        temp[t[1]] = t[2]
    end
    return temp
end

-------------------------------------------------
-- missing buffs, for indicator settings only
-------------------------------------------------
local buffsOrder = {"PWF", "AB", "DS", "MotW", "BoK", "BoM", "BoW", "BoS", "BS", "CS", "SP"}
local abbrToIndex = {}

local missingBuffs = {
    ["PWF"] = 1243,
    ["AB"] = 1459,
    ["DS"] = 14752,
    ["MotW"] = 1126,
    ["BoK"] = 20217,
    ["BoM"] = 19740,
    ["BoW"] = 19742,
    ["BoS"] = 20911,
    ["BS"] = 6673,
    ["CS"] = 469,
    ["SP"] = 976,
}

do
    local temp = {}
    for _, k in pairs(buffsOrder) do
        local id = missingBuffs[k]
        local name, _, icon = GetSpellInfo(id)
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

function I:GetDefaultMissingBuffs()
    return missingBuffs
end

function I:GetMissingBuffsString()
    local s = ""
    for _, t in pairs(missingBuffs) do
        s = s.."|T"..t["icon"]..":14:14:0:0:14:14:1:13:1:13|t".." "
    end
    return s
end

function I:GetMissingBuffsFilters()
    local indicies = {
        "PWF",
        "DS",
        "SP",
        "AB",
        "MotW",
        {"PALADIN", {"BoK", "BoM", "BoW", "BoS"}},
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
            tinsert(ret, {icons..F:GetLocalizedClassName(v[1]), v[1]})
        end
    end
    return ret
end