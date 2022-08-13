---------------------------------------------------------------------
-- 在当前赛季的大秘境副本中，通过“副本减益”指示器显示这些减益
-- 且这些减益的优先级为最高
local debuffs = {
    373391, -- 梦魇
    373429, -- 腐臭虫群
    373509, -- 暗影利爪
}
-- 在下列副本中也启用上述减益
local instances = {
    [1190] = true, -- 纳斯利亚堡
    [1193] = true, -- 统御圣所
    [1195] = true, -- 初诞者圣墓
}
---------------------------------------------------------------------

local F = Cell.funcs
local offset = #debuffs
local instanceNameMapping = Cell.snippetVars.instanceNameMapping
local loadedDebuffs = Cell.snippetVars.loadedDebuffs

function F:GetDebuffList(instanceName)
    local list = {}
    local eName, iIndex, iId = F:SplitToNumber(":", instanceNameMapping[instanceName])

    if eName == "Current Season" or instances[iId] then
        for i, id in pairs(debuffs) do
            list[id] = {["order"]=i, ["condition"]={"None"}}
        end
    end
    
    if iId and loadedDebuffs[iId] then
        local n = 0
        -- check general
        if loadedDebuffs[iId]["general"] then
            n = #loadedDebuffs[iId]["general"]["enabled"]
            for _, t in ipairs(loadedDebuffs[iId]["general"]["enabled"]) do
                local spellName = GetSpellInfo(t["id"])
                if spellName then
                    -- list[spellName/spellId] = {order, glowType, glowOptions}
                    if t["trackByID"] then
                        list[t["id"]] = {["order"]=t["order"]+offset, ["condition"]=t["condition"], ["glowType"]=t["glowType"], ["glowOptions"]=t["glowOptions"], ["glowCondition"]=t["glowCondition"]}
                    else
                        list[spellName] = {["order"]=t["order"]+offset, ["condition"]=t["condition"], ["glowType"]=t["glowType"], ["glowOptions"]=t["glowOptions"], ["glowCondition"]=t["glowCondition"]}
                    end
                end
            end
        end
        -- check boss
        for bId, bTable in pairs(loadedDebuffs[iId]) do
            if bId ~= "general" then
                for _, st in pairs(bTable["enabled"]) do
                    local spellName = GetSpellInfo(st["id"])
                    if spellName then -- check again
                        if st["trackByID"] then
                            list[st["id"]] = {["order"]=st["order"]+n+offset, ["condition"]=st["condition"], ["glowType"]=st["glowType"], ["glowOptions"]=st["glowOptions"], ["glowCondition"]=st["glowCondition"]}
                        else
                            list[spellName] = {["order"]=st["order"]+n+offset, ["condition"]=st["condition"], ["glowType"]=st["glowType"], ["glowOptions"]=st["glowOptions"], ["glowCondition"]=st["glowCondition"]}
                        end
                    end
                end
            end
        end
    end
    -- texplore(list)

    return list
end