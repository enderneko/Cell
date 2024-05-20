---------------------------------------------------------------------
-- 2024-05-18 02:09:39 GMT+8
---------------------------------------------------------------------
-- show these debuffs as Raid Debuffs in M+ with HIGHEST priority
-- 在当前赛季的大秘境副本中，通过“副本减益”指示器显示这些减益，且这些减益的优先级为最高
local debuffs = {
    -- 373509, -- Shadow Claws 暗影利爪
}

-- enabled in these instances as well
-- 在下列副本中也启用上述减益
local instances = {
    -- [1207] = true, -- Amirdrassil, the Dream's Hope 阿梅达希尔，梦境之愿
}
---------------------------------------------------------------------

local F = Cell.funcs
local offset = #debuffs
local instanceNameMapping = Cell.snippetVars.instanceNameMapping
local loadedDebuffs = Cell.snippetVars.loadedDebuffs
local mythicPlusDungeons = EJ_GetTierInfo(EJ_GetNumTiers())

function F:GetDebuffList(instanceName)
    local list = {}
    local eName, iIndex, iId = F:SplitToNumber(":", instanceNameMapping[instanceName])

    if eName == mythicPlusDungeons or instances[iId] then
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
