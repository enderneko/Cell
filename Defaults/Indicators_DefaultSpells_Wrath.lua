local _, Cell = ...
local L = Cell.L
local I = Cell.iFuncs
local F = Cell.funcs

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
local externalCooldowns = {
    -- death knight
    51052, -- 反魔法领域

    -- paladin
    1022, -- 保护祝福
    6940, -- 牺牲祝福
    64205, -- 神圣牺牲
    19752, -- 神圣干涉
    31821, -- 光环掌握

    -- priest
    33206, -- 痛苦压制
    47788, -- 守护之魂

    -- warrior
    3411, -- 援护
}

local externals = {}
for _, id in pairs(externalCooldowns) do
    externals[GetSpellInfo(id)] = true
end
externalCooldowns = F:Copy(externals)

function I:UpdateCustomExternals(t)
    -- reset
    externalCooldowns = F:Copy(externals)
    -- insert
    for _, id in pairs(t) do
        local name = GetSpellInfo(id)
        if name then
            externalCooldowns[name] = true
        end
    end
end

function I:IsExternalCooldown(name, source, target)
    return externalCooldowns[name]
end

-------------------------------------------------
-- defensiveCooldowns
-------------------------------------------------
local defensiveCooldowns = {
    -- death knight
    48707, -- 反魔法护罩
    48792, -- 冰封之韧
    55233, -- 吸血鬼之血

    -- druid
    22812, -- 树皮术
    22842, -- 狂暴回复
    61336, -- 生存本能

    -- hunter
    19263, -- 威慑

    -- mage
    45438, -- 寒冰屏障

    -- paladin
    498, -- 圣佑术
    642, -- 圣盾术

    -- priest
    47585, -- 消散

    -- rogue
    1966, -- 佯攻
    5277, -- 闪避
    31224, -- 暗影斗篷

    -- warrior
    871, -- 盾墙
    12975, -- 破釜沉舟
    23920, -- 法术反射
    55694, -- 狂怒回复
}

local defensives = {}
for _, id in pairs(defensiveCooldowns) do
    defensives[GetSpellInfo(id)] = true
end
defensiveCooldowns = F:Copy(defensives)

function I:UpdateCustomDefensives(t)
    -- reset
    defensiveCooldowns = F:Copy(defensives)
    -- insert
    for _, id in pairs(t) do
        local name = GetSpellInfo(id)
        if name then
            defensiveCooldowns[name] = true
        end
    end
end

function I:IsDefensiveCooldown(name)
    return defensiveCooldowns[name]
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
            indicatorName = "indicator"..(last+1)
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
            ["font"] = {"Cell ".._G.DEFAULT, 11, "Outline", 2, 1},
            ["showDuration"] = false,
            ["auraType"] = "buff",
            ["castByMe"] = true,
            ["trackByName"] = true,
            ["auras"] = spells,
        })
        Cell:Fire("UpdateIndicators", Cell.vars.currentLayout, indicatorName, "create", currentLayoutTable["indicators"][last+1])
        CellDB["firstRun"] = false
    end, function()
        CellDB["firstRun"] = false
    end)
    popup:SetPoint("TOPLEFT")
    popup:Show()
end