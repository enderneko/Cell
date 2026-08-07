---------------------------------------------------------------------
-- File: Cell\Libs\LibShields.lua
-- Description: Tracks absorb shield amounts for Vanilla/TBC Classic
--              via combat log events. Supports multiple shield types
--              with category-based grouping.
-- Author: kamirendawkins (kamiren@dawkins.dev)
-- Created: 2026-04-27
-- Modified: 2026-04-27
---------------------------------------------------------------------

local addonName, Cell = ...

local lib = {}
Cell.LibShields = lib

local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo

-------------------------------------------------
-- Shield Registry
-- [spellId] = { category = "...", base = N }
--   category: groups related ranks for querying
--   base: estimated absorb amount (before +healing/talents)
-------------------------------------------------
local SHIELD_DATA = {
    -- Power Word: Shield (Priest)
    [17]    = { category = "powerWordShield", base = 44 },
    [592]   = { category = "powerWordShield", base = 88 },
    [600]   = { category = "powerWordShield", base = 158 },
    [3747]  = { category = "powerWordShield", base = 234 },
    [6065]  = { category = "powerWordShield", base = 301 },
    [6066]  = { category = "powerWordShield", base = 381 },
    [10898] = { category = "powerWordShield", base = 484 },
    [10899] = { category = "powerWordShield", base = 605 },
    [10900] = { category = "powerWordShield", base = 763 },
    [10901] = { category = "powerWordShield", base = 942 },
    [25217] = { category = "powerWordShield", base = 1125 },
    [25218] = { category = "powerWordShield", base = 1265 },

    -- Ice Barrier (Mage - Frost talent, self-only)
    [11426] = { category = "iceBarrier", base = 438 },
    [13031] = { category = "iceBarrier", base = 549 },
    [13032] = { category = "iceBarrier", base = 678 },
    [13033] = { category = "iceBarrier", base = 818 },
    [27134] = { category = "iceBarrier", base = 925 },
    [33405] = { category = "iceBarrier", base = 1075 },

    -- Mana Shield (Mage, self-only)
    [1463]  = { category = "manaShield", base = 120 },
    [8494]  = { category = "manaShield", base = 210 },
    [8495]  = { category = "manaShield", base = 300 },
    [10191] = { category = "manaShield", base = 390 },
    [10192] = { category = "manaShield", base = 480 },
    [10193] = { category = "manaShield", base = 570 },
    [27131] = { category = "manaShield", base = 715 },

    -- Sacrifice (Warlock Voidwalker, applied to warlock)
    [7812]  = { category = "sacrifice", base = 305 },
    [19438] = { category = "sacrifice", base = 510 },
    [19440] = { category = "sacrifice", base = 770 },
    [19441] = { category = "sacrifice", base = 1095 },
    [19442] = { category = "sacrifice", base = 1470 },
    [19443] = { category = "sacrifice", base = 1905 },
    [27273] = { category = "sacrifice", base = 2855 },

    -- Fire Ward (Mage, self-only, fire damage only)
    [543]   = { category = "fireWard", base = 165 },
    [8457]  = { category = "fireWard", base = 290 },
    [8458]  = { category = "fireWard", base = 470 },
    [10223] = { category = "fireWard", base = 675 },
    [10225] = { category = "fireWard", base = 875 },
    [27128] = { category = "fireWard", base = 1125 },

    -- Frost Ward (Mage, self-only, frost damage only)
    [6143]  = { category = "frostWard", base = 165 },
    [8461]  = { category = "frostWard", base = 290 },
    [8462]  = { category = "frostWard", base = 470 },
    [10177] = { category = "frostWard", base = 675 },
    [28609] = { category = "frostWard", base = 875 },
    [32796] = { category = "frostWard", base = 1125 },
}

-- Fast lookup set for SPELL_ABSORBED routing
local SHIELD_SPELLS = {}
for spellId in pairs(SHIELD_DATA) do
    SHIELD_SPELLS[spellId] = true
end

-------------------------------------------------
-- State
-- shields[guid] = {
--     [category] = {
--         amount = N,      -- current remaining absorb
--         max = N,         -- initial absorb value (estimate)
--         spellId = N,     -- which rank is active
--         sourceGUID = "", -- who cast it
--     },
-- }
-------------------------------------------------
local shields = {}

-------------------------------------------------
-- Callbacks
-- Signature: function(guid, totalAbsorbs, changedCategory, info)
--   guid            - unit GUID
--   totalAbsorbs    - sum of all active shields on this GUID
--   changedCategory - which shield type changed (e.g. "powerWordShield")
--   info            - the category's current state table, or nil if removed
-------------------------------------------------
local callbacks = {}

function lib:RegisterCallback(key, func)
    callbacks[key] = func
end

function lib:UnregisterCallback(key)
    callbacks[key] = nil
end

local function FireCallbacks(guid, changedCategory, info)
    local total = lib:GetTotalAbsorbs(guid)
    for _, func in pairs(callbacks) do
        func(guid, total, changedCategory, info)
    end
end

-------------------------------------------------
-- Public API
-------------------------------------------------

--- Get total absorbs across all shield types for a GUID.
--- @param guid string
--- @return number
function lib:GetTotalAbsorbs(guid)
    local data = shields[guid]
    if not data then return 0 end

    local total = 0
    for _, info in pairs(data) do
        total = total + (info.amount or 0)
    end
    return total
end

--- Get absorb amount for a specific shield category.
--- @param guid string
--- @param category string e.g. "powerWordShield", "iceBarrier"
--- @return number amount, number|nil max
function lib:GetShieldAmount(guid, category)
    local data = shields[guid]
    if not data or not data[category] then return 0, nil end
    return data[category].amount, data[category].max
end

--- Get all active shields for a GUID.
--- @param guid string
--- @return table|nil { [category] = { amount, max, spellId, sourceGUID } }
function lib:GetAllShields(guid)
    return shields[guid]
end

--- Check if a spell ID is a tracked shield.
--- @param spellId number
--- @return boolean
function lib:IsShieldSpell(spellId)
    return SHIELD_SPELLS[spellId] or false
end

--- Get the category for a shield spell ID.
--- @param spellId number
--- @return string|nil
function lib:GetCategory(spellId)
    local data = SHIELD_DATA[spellId]
    return data and data.category
end

--- Reset all shield tracking for a specific GUID.
--- @param guid string
function lib:ResetGUID(guid)
    if guid then
        shields[guid] = nil
    end
end

--- Wipe all tracked data.
function lib:ResetAll()
    wipe(shields)
end

-------------------------------------------------
-- Combat Log Handler
-------------------------------------------------
local cleu = CreateFrame("Frame")
cleu:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

cleu:SetScript("OnEvent", function()
    local timestamp, subEvent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
          destGUID, destName, destFlags, destRaidFlags,
          arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22
          = CombatLogGetCurrentEventInfo()

    if subEvent == "SPELL_AURA_APPLIED" then
        local shieldData = SHIELD_DATA[arg12]
        if not shieldData then return end
        if not Cell.funcs.IsFriend(destFlags) then return end

        local category = shieldData.category
        local baseAbsorb = shieldData.base or 0

        if not shields[destGUID] then
            shields[destGUID] = {}
        end

        shields[destGUID][category] = {
            amount = baseAbsorb,
            max = baseAbsorb,
            spellId = arg12,
            sourceGUID = sourceGUID,
        }

        FireCallbacks(destGUID, category, shields[destGUID][category])

    elseif subEvent == "SPELL_ABSORBED" then
        if not Cell.funcs.IsFriend(destFlags) then return end

        local absorbSpellId, absorbAmount
        if arg21 then -- spell damage
            absorbSpellId, absorbAmount = arg19, arg22
        else -- swing damage
            absorbSpellId, absorbAmount = arg16, arg19
        end

        if not SHIELD_SPELLS[absorbSpellId] then return end

        local shieldData = SHIELD_DATA[absorbSpellId]
        local category = shieldData.category
        local guidData = shields[destGUID]

        if guidData and guidData[category] then
            guidData[category].amount = guidData[category].amount - absorbAmount
            if guidData[category].amount <= 0 then
                guidData[category] = nil
                if not next(guidData) then
                    shields[destGUID] = nil
                end
            end
        end

        FireCallbacks(destGUID, category, guidData and guidData[category])

    elseif subEvent == "SPELL_AURA_REMOVED" then
        local shieldData = SHIELD_DATA[arg12]
        if not shieldData then return end

        local category = shieldData.category
        local guidData = shields[destGUID]

        if guidData then
            guidData[category] = nil
            if not next(guidData) then
                shields[destGUID] = nil
            end
        end

        FireCallbacks(destGUID, category, nil)
    end
end)
