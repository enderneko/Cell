---------------------------------------------------------------------
-- File: ExpansionDataOverrides.lua
-- Author: enderneko (enderneko-dev@outlook.com)
-- Created : 2025-03-31 16:35 +08:00
-- Modified: 2025-12-26 12:19 +08:00
---------------------------------------------------------------------

local _, Cell = ...
local F = Cell.funcs

local expansions = {
    ["Dragonflight"] = 1,
    ["Shadowlands"] = 2,
    ["Battle for Azeroth"] = 3,
    ["Legion"] = 4,
    ["Warlords of Draenor"] = 5,
    ["Mists of Pandaria"] = 6,
    ["Cataclysm"] = 7,
    ["Wrath of the Lich King"] = 8,
    ["Burning Crusade"] = 9,
    ["Classic"] = 10,
}

-------------------------------------------------
-- overrides
-------------------------------------------------
Cell_ExpansionDataOverrides = {
    -- [instanceId] = {
    --     from = "expansion",
    --     to = "expansion",
    --     bosses = {
    --         "boss1", ...
    --     }
    -- }
}

if Cell.isTBC or Cell.isVanilla then
    Cell_ExpansionDataOverrides[559] = {from = "Warlords of Draenor", to = "Classic"} -- UBRS
    Cell_ExpansionDataOverrides[229] = {from = "Classic", to = "Classic"} -- LBRS
end

-------------------------------------------------
-- do
-------------------------------------------------
for instanceId, data in pairs(Cell_ExpansionDataOverrides) do
    local from = Cell_ExpansionData.expansions[expansions[data.from]]
    local to = Cell_ExpansionData.expansions[expansions[data.to]]
    local bosses = data.bosses

    if Cell_ExpansionData["data"][from] then
        for i = 1, #Cell_ExpansionData["data"][from] do
            if Cell_ExpansionData["data"][from][i]["id"] == instanceId then
                local t = F.Copy(Cell_ExpansionData["data"][from][i])

                -- remove old
                tremove(Cell_ExpansionData["data"][from], i)

                -- replace bosses
                wipe(t.bosses)
                if bosses then
                    for j, name in ipairs(bosses) do
                        tinsert(t.bosses, {
                            id = j,
                            name = name,
                        })
                    end
                end

                -- insert
                tinsert(Cell_ExpansionData["data"][to], t)
                break
            end
        end
    end
end