-- PARTY ONLY, RETAIL ONLY
-- sort units by SPEC_PRIORITY ↓↓↓
-- slash command (not in combat): /csort
-- new party members won't be shown, unless a re-sort is called 
-- reload to restore

-- 仅小队，仅正式服
-- 将单位按专精优先级排序 ↓↓↓
-- 斜杠命令（非战斗中）：/csort, /px
-- 必须重新执行排序，否则新成员不会显示
-- 重载界面以恢复

local SPEC_PRIORITY = {
    -- Tank
    250, -- Death Knight - Blood 鲜血
    581, -- Demon Hunter - Vengeance 复仇
    104, -- Druid - Guardian 守护
    268, -- Monk - Brewmaster 酒仙
    66, -- Paladin - Protection 防护
    73, -- Warrior - Protection 防护

    -- Healer
    105, -- Druid - Restoration 恢复
    1468, -- Evoker - Preservation 恩护
    270, -- Monk - Mistweaver 织雾
    65, -- Paladin - Holy 神圣
    256, -- Priest - Discipline 戒律
    257, -- Priest - Holy 神圣
    264, -- Shaman - Restoration 恢复

    -- Support
    1473, -- Evoker - Augmentation 增辉

    -- Melee
    251, -- Death Knight - Frost 冰霜
    252, -- Death Knight - Unholy 邪恶
    577, -- Demon Hunter - Havoc 浩劫
    103, -- Druid - Feral 野性
    255, -- Hunter - Survival 生存
    269, -- Monk - Windwalker 踏风
    70, -- Paladin - Retribution 惩戒
    259, -- Rogue - Assassination 奇袭
    260, -- Rogue - Combat 狂徒
    261, -- Rogue - Subtlety 敏锐
    263, -- Shaman - Enhancement 增强
    71, -- Warrior - Arms 武器
    72, -- Warrior - Fury 狂怒

    -- Ranged
    253, -- Hunter - Beast Mastery 野兽控制
    254, -- Hunter - Marksmanship 射击
    102, -- Druid - Balance 平衡
    1467, -- Evoker - Devastation 湮灭
    62, -- Mage - Arcane 奥术
    63, -- Mage - Fire 火焰
    64, -- Mage - Frost 冰霜
    258, -- Priest - Shadow 暗影
    262, -- Shaman - Elemental 元素
    265, -- Warlock - Affliction 痛苦
    266, -- Warlock - Demonology 恶魔
    267, -- Warlock - Destruction 毁灭
}

-------------------------------------------------
local function GetPriority(specId)
    if not specId then return 999 end
    
    for i, s in pairs(SPEC_PRIORITY) do
        if specId == s then
            return i
        end
    end

    return 999 -- initials
end

local F = Cell.funcs
local LGI = LibStub:GetLibrary("LibGroupInfo")

local nameList = {}
local nameToPriority = {}

SLASH_CELLSORT1 = "/csort"
SLASH_CELLSORT2 = "/px"
function SlashCmdList.CELLSORT()
    if InCombatLockdown() then return end

    wipe(nameList)
    wipe(nameToPriority)

    for unit in F:IterateGroupMembers() do
        local name = UnitName(unit)
        tinsert(nameList, name)
    
        local guid = UnitGUID(unit)
        local info = LGI:GetCachedInfo(guid)
        if info then
            nameToPriority[name] = GetPriority(info.specId)
        else
            nameToPriority[name] = 999
        end
    end

    sort(nameList, function(a, b)
        if nameToPriority[a] ~= nameToPriority[b] then
            return nameToPriority[a] < nameToPriority[b]
        else
            return a < b
        end
    end)

    CellPartyFrameHeader:SetAttribute("groupingOrder", "")
    CellPartyFrameHeader:SetAttribute("groupBy", nil)
    CellPartyFrameHeader:SetAttribute("nameList", F:TableToString(nameList, ","))
    CellPartyFrameHeader:SetAttribute("sortMethod", "NAMELIST")
    --texplore(nameList)
    F:Print("re-sorted.")
end