local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local I = Cell.iFuncs

Cell.vars.playerFaction = UnitFactionGroup("player")

-------------------------------------------------
-- game version
-------------------------------------------------
Cell.isAsian = LOCALE_zhCN or LOCALE_zhTW or LOCALE_koKR

Cell.isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
Cell.isVanilla = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
-- Cell.isBCC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC and LE_EXPANSION_LEVEL_CURRENT == LE_EXPANSION_BURNING_CRUSADE
-- Cell.isWrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC and LE_EXPANSION_LEVEL_CURRENT == LE_EXPANSION_WRATH_OF_THE_LICH_KING
Cell.isWrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
Cell.isCata = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC

-------------------------------------------------
-- class
-------------------------------------------------
local localizedClass = {}
FillLocalizedClassList(localizedClass)

local sortedClasses = {}
local classFileToID = {}
local classIDToFile = {}

do
    -- WARRIOR = 1,
    -- PALADIN = 2,
    -- HUNTER = 3,
    -- ROGUE = 4,
    -- PRIEST = 5,
    -- DEATHKNIGHT = 6,
    -- SHAMAN = 7,
    -- MAGE = 8,
    -- WARLOCK = 9,
    -- MONK = 10,
    -- DRUID = 11,
    -- DEMONHUNTER = 12,
    -- EVOKER = 13,
    for i = 1, GetNumClasses() do --! returns the highest class ID
        local classFile = select(2, GetClassInfo(i))
        if classFile then --! returns nil for classes that don't exist in Classic.
            tinsert(sortedClasses, classFile)
            classFileToID[classFile] = i
            classIDToFile[i] = classFile
        end
    end
    sort(sortedClasses)
end

function F:GetClassID(classFile)
    return classFileToID[classFile]
end

function F:GetLocalizedClassName(classFileOrID)
    if type(classFileOrID) == "string" then
        return localizedClass[classFileOrID] or classFileOrID
    elseif type(classFileOrID) == "number" and classIDToFile[classFileOrID] then
        return localizedClass[classIDToFile[classFileOrID]] or classFileOrID
    end
    return ""
end

function F:IterateClasses()
    local i = 0
    return function()
        i = i + 1
        if i <= GetNumClasses() then
            return sortedClasses[i], classFileToID[sortedClasses[i]], i
        end
    end
end

function F:GetSortedClasses()
    return F:Copy(sortedClasses)
end

-------------------------------------------------
-- Classic
-------------------------------------------------
if Cell.isCata then
    function F:GetActiveTalentInfo()
        local which = GetActiveTalentGroup() == 1 and L["Primary Talents"] or L["Secondary Talents"]
        return which, Cell.vars.playerSpecIcon, Cell.vars.playerSpecName
    end

elseif Cell.isVanilla then
    function F:GetActiveTalentInfo()
        local which = GetActiveTalentGroup() == 1 and L["Primary Talents"] or L["Secondary Talents"]

        local maxPoints = 0
        local specName, specIcon, specFileName

        for i = 1, GetNumTalentTabs() do
            local name, texture, pointsSpent, fileName = GetTalentTabInfo(i)
            if pointsSpent > maxPoints then
                maxPoints = pointsSpent
                specIcon = texture
                specName = name
            elseif pointsSpent == maxPoints then
                specIcon = 132148
            end
        end

        return which, specIcon, specName
    end
end

-- local specRoles = {
--     ["DeathKnightBlood"] = "DAMAGER",
--     ["DeathKnightFrost"] = "TANK",
--     ["DeathKnightUnholy"] = "DAMAGER",

--     ["DruidRestoration"] = "HEALER",
--     ["DruidBalance"] = "DAMAGER",
--     -- ["DruidFeralCombat"] = nil,

--     ["HunterBeastMastery"] = "DAMAGER",
--     ["HunterSurvival"] = "DAMAGER",
--     ["HunterMarksmanship"] = "DAMAGER",
    
--     ["MageFrost"] = "DAMAGER",
--     ["MageArcane"] = "DAMAGER",
--     ["MageFire"] = "DAMAGER",

--     ["PaladinHoly"] = "HEALER",
--     ["PaladinCombat"] = "DAMAGER",
--     ["PaladinProtection"] = "TANK",

--     ["PriestShadow"] = "DAMAGER",
--     ["PriestHoly"] = "HEALER",
--     ["PriestDiscipline"] = "HEALER",

--     ["RogueCombat"] = "DAMAGER",
--     ["RogueSubtlety"] = "DAMAGER",
--     ["RogueAssassination"] = "DAMAGER",

--     ["ShamanElementalCombat"] = "DAMAGER",
--     ["ShamanEnhancement"] = "DAMAGER",
--     ["ShamanRestoration"] = "HEALER",

--     ["WarlockSummoning"] = "DAMAGER",
--     ["WarlockDestruction"] = "DAMAGER",
--     ["WarlockCurses"] = "DAMAGER",

--     ["WarriorArms"] = "DAMAGER",
--     ["WarriorFury"] = "DAMAGER",
--     ["WarriorProtection"] = "TANK",
-- }

-- function F:GetPlayerRole()

-- end

-------------------------------------------------
-- color
-------------------------------------------------
function F:ConvertRGB(r, g, b, desaturation)
    if not desaturation then desaturation = 1 end
    r = r / 255 * desaturation
    g = g / 255 * desaturation
    b = b / 255 * desaturation
    return r, g, b
end

function F:ConvertRGB_256(r, g, b)
    return floor(r * 255), floor(g * 255), floor(b * 255)
end

function F:ConvertRGBToHEX(r, g, b)
    local result = ""

    for key, value in pairs({r, g, b}) do
        local hex = ""

        while(value > 0)do
            local index = math.fmod(value, 16) + 1
            value = math.floor(value / 16)
            hex = string.sub("0123456789ABCDEF", index, index) .. hex
        end

        if(string.len(hex) == 0)then
            hex = "00"

        elseif(string.len(hex) == 1)then
            hex = "0" .. hex
        end

        result = result .. hex
    end

    return result
end

function F:ConvertHEXToRGB(hex)
    hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

-- https://wowpedia.fandom.com/wiki/ColorGradient
-- function F:ColorGradient(perc, r1,g1,b1, r2,g2,b2, r3,g3,b3)
--     perc = perc or 1
--     if perc >= 1 then
--         return r3, g3, b3
--     elseif perc <= 0 then
--         return r1, g1, b1
--     end
 
--     local segment, relperc = math.modf(perc * 2)
--     local rr1, rg1, rb1, rr2, rg2, rb2 = select((segment * 3) + 1, r1,g1,b1, r2,g2,b2, r3,g3,b3)
 
--     return rr1 + (rr2 - rr1) * relperc, rg1 + (rg2 - rg1) * relperc, rb1 + (rb2 - rb1) * relperc
-- end

function F:ColorGradient(perc, c1, c2, c3)
    local r1, g1, b1 = c1[1], c1[2], c1[3]
    local r2, g2, b2 = c2[1], c2[2], c2[3]
    local r3, g3, b3 = c3[1], c3[2], c3[3]

    perc = perc or 1
    if perc >= 1 then
        return r3, g3, b3
    elseif perc <= 0 then
        return r1, g1, b1
    end
 
    local segment, relperc = math.modf(perc * 2)
    local rr1, rg1, rb1, rr2, rg2, rb2 = select((segment * 3) + 1, r1,g1,b1, r2,g2,b2, r3,g3,b3)
 
    return rr1 + (rr2 - rr1) * relperc, rg1 + (rg2 - rg1) * relperc, rb1 + (rb2 - rb1) * relperc
end

--! From ColorPickerAdvanced by Feyawen-Llane
--[[ Convert RGB to HSV ---------------------------------------------------
    Inputs:
        r = Red [0, 1]
        g = Green [0, 1]
        b = Blue [0, 1]
    Outputs:
        H = Hue [0, 360]
        S = Saturation [0, 1]
        B = Brightness [0, 1]
]]--
function F:ConvertRGBToHSB(r, g, b)
    local colorMax = max(max(r, g), b)
    local colorMin = min(min(r, g), b)
    local delta = colorMax - colorMin
    local H, S, B
    
    -- WoW's LUA doesn't handle floating point numbers very well (Somehow 1.000000 != 1.000000   WTF?)
    -- So we do this weird conversion of, Number to String back to Number, to make the IF..THEN work correctly!
    colorMax = tonumber(format("%f", colorMax))
    r = tonumber(format("%f", r))
    g = tonumber(format("%f", g))
    b = tonumber(format("%f", b))
    
    if (delta > 0) then
        if (colorMax == r) then
            H = 60 * (((g - b) / delta) % 6)
        elseif (colorMax == g) then
            H = 60 * (((b - r) / delta) + 2)
        elseif (colorMax == b) then
            H = 60 * (((r - g) / delta) + 4)
        end
        
        if (colorMax > 0) then
            S = delta / colorMax
        else
            S = 0
        end
        
        B = colorMax
    else
        H = 0
        S = 0
        B = colorMax
    end
    
    if (H < 0) then
        H = H + 360
    end
    
    return H, S, B
end

--[[ Convert HSB to RGB ---------------------------------------------------
    Inputs:
        h = Hue [0, 360]
        s = Saturation [0, 1]
        b = Brightness [0, 1]
    Outputs:
        R = Red [0,1]
        G = Green [0,1]
        B = Blue [0,1]
]]--
function F:ConvertHSBToRGB(h, s, b)
    local chroma = b * s
    local prime = (h / 60) % 6
    local X = chroma * (1 - abs((prime % 2) - 1))
    local M = b - chroma
    local R, G, B

    if (0 <= prime) and (prime < 1) then
        R = chroma
        G = X
        B = 0
    elseif (1 <= prime) and (prime < 2) then
        R = X
        G = chroma
        B = 0
    elseif (2 <= prime) and (prime < 3) then
        R = 0
        G = chroma
        B = X
    elseif (3 <= prime) and (prime < 4) then
        R = 0
        G = X
        B = chroma
    elseif (4 <= prime) and (prime < 5) then
        R = X
        G = 0
        B = chroma
    elseif (5 <= prime) and (prime < 6) then
        R = chroma
        G = 0
        B = X
    else
        R = 0
        G = 0
        B = 0
    end
    
    R = R + M
    G = G + M
    B =  B + M
    
    return R, G, B
end

function F:InvertColor(r, g, b)
    return 1 - r, 1 - g, 1 - b
end

-------------------------------------------------
-- number
-------------------------------------------------
local symbol_1K, symbol_10K, symbol_1B
if LOCALE_zhCN then
    symbol_1K, symbol_10K, symbol_1B = "千", "万", "亿"
elseif LOCALE_zhTW then
    symbol_1K, symbol_10K, symbol_1B = "千", "萬", "億"
elseif LOCALE_koKR then
    symbol_1K, symbol_10K, symbol_1B = "천", "만", "억"
end

if Cell.isAsian then
    function F:FormatNumber(n)
        if abs(n) >= 100000000 then
            return string.format("%.3f"..symbol_1B, n/100000000)
        elseif abs(n) >= 10000 then
            return string.format("%.2f"..symbol_10K, n/10000)
        -- elseif abs(n) >= 1000 then
        --     return string.format("%.1f"..symbol_1K, n/1000)
        else
            return n
        end
    end
else
    function F:FormatNumber(n)
        if abs(n) >= 1000000000 then
            return string.format("%.3fB", n/1000000000)
        elseif abs(n) >= 1000000 then
            return string.format("%.2fM", n/1000000)
        elseif abs(n) >= 1000 then
            return string.format("%.1fK", n/1000)
        else
            return n
        end
    end
end

function F:KeepDecimals(num, n)
    if num < 0 then
        return -(abs(num) - abs(num) % 0.1 ^ n)
    else
        return num - num % 0.1 ^ n
    end
end

-------------------------------------------------
-- string
-------------------------------------------------
function F:UpperFirst(str, lowerOthers)
    if lowerOthers then
        str = strlower(str)
    end
    return (str:gsub("^%l", string.upper))
end

function F:SplitToNumber(sep, str)
    if not str then return end
    
    local ret = {strsplit(sep, str)}
    for i, v in ipairs(ret) do
        ret[i] = tonumber(v) or ret[i] -- keep non number
    end
    return unpack(ret)
end

local function Chsize(char)
    if not char then
        return 0
    elseif char > 240 then
        return 4
    elseif char > 225 then
        return 3
    elseif char > 192 then
        return 2
    else
        return 1
    end
end

function F:Utf8sub(str, startChar, numChars)
    if not str then return "" end
    local startIndex = 1
    while startChar > 1 do
        local char = string.byte(str, startIndex)
        startIndex = startIndex + Chsize(char)
        startChar = startChar - 1
    end
    
    local currentIndex = startIndex
    
    while numChars > 0 and currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + Chsize(char)
        numChars = numChars -1
    end
    return str:sub(startIndex, currentIndex - 1)
end

function F:FitWidth(fs, text, alignment)
    fs:SetText(text)

    if fs:IsTruncated() then
        for i = 1, string.utf8len(text) do
            if strlower(alignment) == "right" then
                fs:SetText("..."..string.utf8sub(text, i))
            else
                fs:SetText(string.utf8sub(text, i).."...")
            end
            
            if not fs:IsTruncated() then
                break
            end
        end
    end
end

-------------------------------------------------
-- table
-------------------------------------------------
function F:Getn(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

function F:GetIndex(t, e)
    for i, v in pairs(t) do
        if e == v then
            return i
        end
    end
    return nil
end

function F:GetKeys(t)
    local keys = {}
    for k in pairs(t) do
        tinsert(keys, k)
    end
    return keys
end

function F:Copy(t)
    local newTbl = {}
    for k, v in pairs(t) do
        if type(v) == "table" then  
            newTbl[k] = F:Copy(v)
        else  
            newTbl[k] = v  
        end  
    end
    return newTbl
end

function F:TContains(t, v)
    for _, value in pairs(t) do
        if value == v then return true end
    end
    return false
end

function F:TInsert(t, v)
    local i, done = 1
    repeat
        if not t[i] then
            t[i] = v
            done = true
        end
        i = i + 1
    until done
end

function F:TRemove(t, v)
    for i = #t, 1, -1 do
        if t[i] == v then
            table.remove(t, i)
        end
    end
end

function F:TMergeOverwrite(...)
    local tbls = {...}
    if #tbls == 0 then return {} end

    local temp = F:Copy(tbls[1])
    for i = 2, #tbls do
        for k, v in pairs(tbls[i]) do
            temp[k] = v
        end
    end
    return temp
end

function F:RemoveElementsExceptKeys(tbl, ...)
    local keys = {}

    for i = 1, select("#", ...) do
        local k = select(i, ...)
        keys[k] = true
    end

    for k in pairs(tbl) do
        if not keys[k] then
            tbl[k] = nil
        end
    end
end

function F:RemoveElementsByKeys(tbl, ...)
    for i = 1, select("#", ...) do
        local k = select(i, ...)
        tbl[k] = nil
    end
end

function F:Sort(t, k1, order1, k2, order2, k3, order3)
    table.sort(t, function(a, b)
        if a[k1] ~= b[k1] then
            if order1 == "ascending" then
                return a[k1] < b[k1]
            else -- "descending"
                return a[k1] > b[k1]
            end
        elseif k2 and order2 and a[k2] ~= b[k2] then
            if order2 == "ascending" then
                return a[k2] < b[k2]
            else -- "descending"
                return a[k2] > b[k2]
            end
        elseif k3 and order3 and a[k3] ~= b[k3] then
            if order3 == "ascending" then
                return a[k3] < b[k3]
            else -- "descending"
                return a[k3] > b[k3]
            end
        end
    end)
end

function F:StringToTable(s, sep, convertToNum)
    local t = {}
    for i, v in pairs({string.split(sep, s)}) do
        v = strtrim(v)
        if v ~= "" then
            if convertToNum then
                v = tonumber(v)
                if v then tinsert(t, v) end
            else
                tinsert(t, v)
            end
        end
    end
    return t
end

function F:TableToString(t, sep)
    return table.concat(t, sep)
end

function F:ConvertTable(t, value)
    local temp = {}
    for k, v in ipairs(t) do
        temp[v] = value or k
    end
    return temp
end

local GetSpellInfo = GetSpellInfo
function F:ConvertSpellTable(t, convertIdToName)
    if not convertIdToName then
        return F:ConvertTable(t)
    end

    local temp = {}
    for k, v in ipairs(t) do
        local name = GetSpellInfo(v)
        if name then
            temp[name] = k
        end
    end
    return temp
end

function F:ConvertSpellTable_WithClass(t)
    local temp = {}
    for class, ct in pairs(t) do
        for _, id in ipairs(ct) do
            local name = GetSpellInfo(id)
            if name then
                temp[id] = true
            end
        end
    end
    return temp
end

function F:ConvertSpellDurationTable(t, convertIdToName)
    local temp = {}
    for _, v in ipairs(t) do
        local id, duration = strsplit(":", v)
        local name = GetSpellInfo(id)
        if name then
            if convertIdToName then
                temp[name] = tonumber(duration)
            else
                temp[tonumber(id)] = tonumber(duration)
            end
        end
    end
    return temp
end

function F:ConvertSpellDurationTable_WithClass(t)
    local temp = {}
    for class, ct in pairs(t) do
        for k, v in ipairs(ct) do
            local id, duration = strsplit(":", v)
            local name, _, icon = GetSpellInfo(id)
            if name then
                temp[tonumber(id)] = {tonumber(duration), icon}
            end
        end
    end
    return temp
end

function F:CheckTableRemoved(previous, after)
    local aa = {}
    local ret = {}

    for k,v in pairs(previous) do aa[v] = true end
    for k,v in pairs(after) do aa[v] = nil end

    for k,v in pairs(previous) do
        if aa[v] then
            tinsert(ret, v)
        end
    end
    return ret
end

function F:FilterInvalidSpells(t)
    if not t then return end
    for i = #t, 1, -1 do
        local spellId
        if type(t[i]) == "number" then
            spellId = t[i]
        else -- consumables
            spellId = t[i][1]
        end
        if not GetSpellInfo(spellId) then
            tremove(t, i)
        end
    end
end

-------------------------------------------------
-- general
-------------------------------------------------
-- function F:GetRealmName()
--     return string.gsub(GetRealmName(), " ", "")
-- end

function F:UnitFullName(unit)
    if not unit or not UnitIsPlayer(unit) then return end

    local name = GetUnitName(unit, true)
    
    --? name might be nil in some cases?
    if name and not string.find(name, "-") then
        local server = GetNormalizedRealmName()
        --? server might be nil in some cases?
        if server then
            name = name.."-"..server
        end
    end
    
    return name
end

function F:ToShortName(fullName)
    if not fullName then return "" end
    local shortName = strsplit("-", fullName)
    return shortName
end

function F:FormatTime(s)
    if s >= 3600 then
        return "%dh", ceil(s / 3600)
    elseif s >= 60 then
        return "%dm", ceil(s / 60)
    end
    return "%ds", floor(s)
end

-- function F:SecondsToTime(seconds)
--     local m = seconds / 60
--     local s = seconds % 60
--     return format("%d:%02d", m, s)
-- end

local SEC = _G.SPELL_DURATION_SEC
local MIN = _G.SPELL_DURATION_MIN

local PATTERN_SEC
local PATTERN_MIN
if strfind(SEC, "1f") then
    PATTERN_SEC = "%.0"
elseif strfind(SEC, "2f") then
    PATTERN_SEC = "%.00"
end
if strfind(MIN, "1f") then
    PATTERN_MIN = "%.0"
elseif strfind(MIN, "2f") then
    PATTERN_MIN = "%.00"
end

function F:SecondsToTime(seconds)
    if seconds > 60 then
        return gsub(format(MIN, seconds / 60), PATTERN_MIN, "")
    else
        return gsub(format(SEC, seconds), PATTERN_SEC, "")
    end
end

-------------------------------------------------
-- unit buttons
-------------------------------------------------
local combinedHeader = "CellRaidFrameHeader0"
local separatedHeaders = {"CellRaidFrameHeader1", "CellRaidFrameHeader2", "CellRaidFrameHeader3", "CellRaidFrameHeader4", "CellRaidFrameHeader5", "CellRaidFrameHeader6", "CellRaidFrameHeader7", "CellRaidFrameHeader8"}

function F:IterateAllUnitButtons(func, updateCurrentGroupOnly, updateQuickAssist)
    -- solo
    if not updateCurrentGroupOnly or (updateCurrentGroupOnly and Cell.vars.groupType == "solo") then
        for _, b in pairs(Cell.unitButtons.solo) do
            func(b)
        end
    end

    -- party
    if not updateCurrentGroupOnly or (updateCurrentGroupOnly and Cell.vars.groupType == "party") then
        for index, b in pairs(Cell.unitButtons.party) do
            if index ~= "units" then
                func(b)
            end
        end
    end

    -- raid
    if not updateCurrentGroupOnly or (updateCurrentGroupOnly and Cell.vars.groupType == "raid") then
        if not updateCurrentGroupOnly or Cell.vars.currentLayoutTable.main.combineGroups then
            for _, b in ipairs(Cell.unitButtons.raid[combinedHeader]) do
                func(b)
            end
        end

        if not updateCurrentGroupOnly or not Cell.vars.currentLayoutTable.main.combineGroups then
            for _, header in ipairs(separatedHeaders) do
                for _, b in ipairs(Cell.unitButtons.raid[header]) do
                    func(b)
                end
            end
        end
        
        -- arena pet
        for _, b in pairs(Cell.unitButtons.arena) do
            func(b)
        end

        -- raid pet
        for index, b in pairs(Cell.unitButtons.raidpet) do
            if index ~= "units" then
                func(b)
            end
        end
    end

    -- npc
    for _, b in ipairs(Cell.unitButtons.npc) do
        func(b)
    end

    -- spotlight
    for _, b in pairs(Cell.unitButtons.spotlight) do
        func(b)
    end

    if Cell.isRetail and updateQuickAssist then
        for i = 1, 40 do
            func(Cell.unitButtons.quickAssist[i])
        end
    end
end

function F:IterateSharedUnitButtons(func)
    -- npc
    for _, b in ipairs(Cell.unitButtons.npc) do
        func(b)
    end

    -- spotlight
    for _, b in pairs(Cell.unitButtons.spotlight) do
        func(b)
    end
end

local spotlights = {}
function F:GetUnitButtonByUnit(unit, getSpotlights, getQuickAssist)
    if not unit then return end

    local normal, quickAssist

    if Cell.vars.groupType == "raid" then
        if Cell.vars.inBattleground == 5 then
            normal = Cell.unitButtons.raid.units[unit] or Cell.unitButtons.npc.units[unit] or Cell.unitButtons.arena[unit]
        else
            normal = Cell.unitButtons.raid.units[unit] or Cell.unitButtons.npc.units[unit] or Cell.unitButtons.raidpet.units[unit]
        end
    elseif Cell.vars.groupType == "party" then
        normal = Cell.unitButtons.party.units[unit] or Cell.unitButtons.npc.units[unit]
    else -- solo
        normal = Cell.unitButtons.solo[unit] or Cell.unitButtons.npc.units[unit]
    end

    if getSpotlights then
        wipe(spotlights)
        for _, b in pairs(Cell.unitButtons.spotlight) do
            if b.states.unit and UnitIsUnit(b.states.unit, unit) then
                tinsert(spotlights, b)
            end
        end
    end
    
    if getQuickAssist then
        quickAssist = Cell.unitButtons.quickAssist.units[unit]
    end

    return normal, spotlights, quickAssist
end

function F:GetUnitButtonByGUID(guid, getSpotlights)
    return F:GetUnitButtonByUnit(Cell.vars.guids[guid], getSpotlights)
end

function F:GetUnitButtonByName(name, getSpotlights)
    return F:GetUnitButtonByUnit(Cell.vars.names[name], getSpotlights)
end

function F:HandleUnitButton(type, unit, func, ...)
    if not unit then return end

    if type == "guid" then
        unit = Cell.vars.guids[unit]
    elseif type == "name" then
        unit = Cell.vars.names[unit]
    end

    if not unit then return end

    local handled, normal

    if Cell.vars.groupType == "raid" then
        if Cell.vars.inBattleground == 5 then
            normal = Cell.unitButtons.raid.units[unit] or Cell.unitButtons.npc.units[unit] or Cell.unitButtons.arena[unit]
        else
            normal = Cell.unitButtons.raid.units[unit] or Cell.unitButtons.npc.units[unit] or Cell.unitButtons.raidpet.units[unit]
        end
    elseif Cell.vars.groupType == "party" then
        normal = Cell.unitButtons.party.units[unit] or Cell.unitButtons.npc.units[unit]
    else -- solo
        normal = Cell.unitButtons.solo[unit] or Cell.unitButtons.npc.units[unit]
    end

    if normal then
        func(normal, ...)
        handled = true
    end
    
    for _, b in pairs(Cell.unitButtons.spotlight) do
        if b.states.unit and UnitIsUnit(b.states.unit, unit) then
            func(b, ...)
            handled = true
        end
    end

    return handled
end

function F:UpdateTextWidth(fs, text, width, relativeTo)
    if not text or not width then return end

    if width == "unlimited" then
        fs:SetText(text)
    elseif width[1] == "percentage" then
        local percent = width[2] or 0.75
        local width = relativeTo:GetWidth() - 2
        for i = string.utf8len(text), 0, -1 do
            fs:SetText(string.utf8sub(text, 1, i))
            if fs:GetWidth() / width <= percent then
                break
            end
        end
    elseif width[1] == "length" then
        if string.len(text) == string.utf8len(text) then -- en
            fs:SetText(string.utf8sub(text, 1, width[2]))
        else -- non-en
            fs:SetText(string.utf8sub(text, 1, width[3]))
        end
    end
end

function F:GetMarkEscapeSequence(index)
    index = index - 1
    local left, right, top, bottom
    local coordIncrement = 64 / 256
    left = mod(index , 4) * coordIncrement
    right = left + coordIncrement
    top = floor(index / 4) * coordIncrement
    bottom = top + coordIncrement
    return string.format("|TInterface\\TargetingFrame\\UI-RaidTargetingIcons:0:0:0:0:64:64:%d:%d:%d:%d|t", left*64, right*64, top*64, bottom*64)
end

-- local scriptObjects = {}
-- local frame = CreateFrame("Frame")
-- frame:RegisterEvent("PLAYER_REGEN_DISABLED")
-- frame:RegisterEvent("PLAYER_REGEN_ENABLED")
-- frame:SetScript("OnEvent", function(self, event)
--     if event == "PLAYER_REGEN_ENABLED" then
--         for _, obj in pairs(scriptObjects) do
--             obj:Show()
--         end
--     else
--         for _, obj in pairs(scriptObjects) do
--             obj:Hide()
--         end
--     end
-- end)
-- function F:SetHideInCombat(obj)
--     tinsert(scriptObjects, obj)
-- end

-------------------------------------------------
-- global functions
-------------------------------------------------
local UnitGUID = UnitGUID
local GetNumGroupMembers = GetNumGroupMembers
local GetRaidRosterInfo = GetRaidRosterInfo
local IsInRaid = IsInRaid
local IsInGroup = IsInGroup
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local UnitPlayerOrPetInParty = UnitPlayerOrPetInParty
local UnitPlayerOrPetInRaid = UnitPlayerOrPetInRaid
local UnitClass = UnitClass
local UnitClassBase = UnitClassBase
local UnitName = UnitName
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitIsGroupAssistant = UnitIsGroupAssistant
local UnitInPartyIsAI = UnitInPartyIsAI or function() end

-------------------------------------------------
-- frame colors
-------------------------------------------------
local RAID_CLASS_COLORS = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
function F:GetClassColor(class)
    if class and class ~= "" and RAID_CLASS_COLORS[class] then
        if CUSTOM_CLASS_COLORS then
            return CUSTOM_CLASS_COLORS[class].r, CUSTOM_CLASS_COLORS[class].g, CUSTOM_CLASS_COLORS[class].b
        else
            return RAID_CLASS_COLORS[class]:GetRGB()
        end
    else
        return 1, 1, 1
    end
end

function F:GetClassColorStr(class)
    if class and class ~= "" and RAID_CLASS_COLORS[class] then
        return "|c"..RAID_CLASS_COLORS[class].colorStr
    else
        return "|cffffffff"
    end
end

function F:GetUnitClassColor(unit, class, guid)
    class = class or select(2, UnitClass(unit))
    guid = guid or UnitGUID(unit)

    if UnitIsPlayer(unit) or UnitInPartyIsAI(unit) then -- player
        return F:GetClassColor(class)
    elseif F:IsPet(guid) then -- pet
        return 0.5, 0.5, 1
    else -- npc / vehicle
        return 0, 1, 0.2
    end
end


function F:GetPowerColor(unit)
    local r, g, b, t
    -- https://wow.gamepedia.com/API_UnitPowerType
    local powerType, powerToken, altR, altG, altB = UnitPowerType(unit)
    t = powerType

    local info = PowerBarColor[powerToken]
    if powerType == 0 then -- MANA
        info = {r=0, g=0.5, b=1} -- default mana color is too dark!
    elseif powerType == 13 then -- INSANITY
        info = {r=0.6, g=0.2, b=1}
    end

    if info then
        --The PowerBarColor takes priority
        r, g, b = info.r, info.g, info.b
    else
        if not altR then
            -- Couldn't find a power token entry. Default to indexing by power type or just mana if  we don't have that either.
            info = PowerBarColor[powerType] or PowerBarColor["MANA"]
            r, g, b = info.r, info.g, info.b
        else
            r, g, b = altR, altG, altB
        end
    end
    return r, g, b, t
end

function F:GetPowerBarColor(unit, class)
    local r, g, b, lossR, lossG, lossB, t
    r, g, b, t = F:GetPowerColor(unit)

    if not Cell.loaded then
        return r, g, b, r*0.2, g*0.2, b*0.2, t
    end
    
    if CellDB["appearance"]["powerColor"][1] == "power_color_dark" then
        lossR, lossG, lossB = r, g, b
        r, g, b = r*0.2, g*0.2, b*0.2
    elseif CellDB["appearance"]["powerColor"][1] == "class_color" then
        r, g, b = F:GetClassColor(class)
        lossR, lossG, lossB = r*0.2, g*0.2, b*0.2
    elseif CellDB["appearance"]["powerColor"][1] == "custom" then
        r, g, b = unpack(CellDB["appearance"]["powerColor"][2])
        lossR, lossG, lossB = r*0.2, g*0.2, b*0.2
    else
        lossR, lossG, lossB = r*0.2, g*0.2, b*0.2
    end
    return r, g, b, lossR, lossG, lossB, t
end

function F:GetHealthBarColor(percent, isDeadOrGhost, r, g, b)
    if not Cell.loaded then
        return r, g, b, r*0.2, g*0.2, b*0.2      
    end

    local barR, barG, barB, lossR, lossG, lossB
    
    -- bar
    if percent == 1 and Cell.vars.useFullColor then
        barR = CellDB["appearance"]["fullColor"][2][1]
        barG = CellDB["appearance"]["fullColor"][2][2]
        barB = CellDB["appearance"]["fullColor"][2][3]
    else
        if CellDB["appearance"]["barColor"][1] == "class_color" then
            barR, barG, barB = r, g, b
        elseif CellDB["appearance"]["barColor"][1] == "class_color_dark" then
            barR, barG, barB = r*0.2, g*0.2, b*0.2
        elseif CellDB["appearance"]["barColor"][1] == "gradient" then
            barR, barG, barB = F:ColorGradient(percent, CellDB["appearance"]["gradientColors"][1], CellDB["appearance"]["gradientColors"][2], CellDB["appearance"]["gradientColors"][3])
        elseif CellDB["appearance"]["barColor"][1] == "gradient2" then
            if percent == 1 then
                barR, barG, barB = r, g, b -- full: class color
            else
                barR, barG, barB = F:ColorGradient(percent, CellDB["appearance"]["gradientColors"][1], CellDB["appearance"]["gradientColors"][2], CellDB["appearance"]["gradientColors"][3])
            end
        else
            barR = CellDB["appearance"]["barColor"][2][1]
            barG = CellDB["appearance"]["barColor"][2][2]
            barB = CellDB["appearance"]["barColor"][2][3]
        end
    end

    -- loss
    if isDeadOrGhost and Cell.vars.useDeathColor then
        lossR = CellDB["appearance"]["deathColor"][2][1]
        lossG = CellDB["appearance"]["deathColor"][2][2]
        lossB = CellDB["appearance"]["deathColor"][2][3]
    else
        if CellDB["appearance"]["lossColor"][1] == "class_color" then
            lossR, lossG, lossB = r, g, b
        elseif CellDB["appearance"]["lossColor"][1] == "class_color_dark" then
            lossR, lossG, lossB = r*0.2, g*0.2, b*0.2
        elseif CellDB["appearance"]["lossColor"][1] == "gradient" then
            lossR, lossG, lossB = F:ColorGradient(percent, CellDB["appearance"]["gradientColors"][1], CellDB["appearance"]["gradientColors"][2], CellDB["appearance"]["gradientColors"][3])
        elseif CellDB["appearance"]["lossColor"][1] == "gradient2" then
            if isDeadOrGhost then
                lossR, lossG, lossB = r*0.2, g*0.2, b*0.2  -- dead: class color dark
            else
                lossR, lossG, lossB = F:ColorGradient(percent, CellDB["appearance"]["gradientColors"][1], CellDB["appearance"]["gradientColors"][2], CellDB["appearance"]["gradientColors"][3])
            end
        else
            lossR = CellDB["appearance"]["lossColor"][2][1]
            lossG = CellDB["appearance"]["lossColor"][2][2]
            lossB = CellDB["appearance"]["lossColor"][2][3]
        end
    end

    return barR, barG, barB, lossR, lossG, lossB
end

-------------------------------------------------
-- units
-------------------------------------------------
function F:GetNumSubgroupMembers(group)
    local n = 0
    for i = 1, GetNumGroupMembers() do
        local name, _, subgroup = GetRaidRosterInfo(i)
        if subgroup == group then
            n = n + 1
        end
    end
    return n
end

function F:GetUnitsInSubGroup(group)
    local units = {}
    for i = 1, GetNumGroupMembers() do
        -- name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(raidIndex)
        local name, _, subgroup = GetRaidRosterInfo(i)
        if subgroup == group then
            tinsert(units, "raid"..i)
        end
    end
    return units
end

function F:GetRaidInfoByName(fullName)
    for i = 1, GetNumGroupMembers() do
        -- rank: Returns 2 if the raid member is the leader of the raid, 1 if the raid member is promoted to assistant, and 0 otherwise.
        local name, rank, subgroup = GetRaidRosterInfo(i)
        if name == fullName then
            return i, subgroup, rank
        end
    end
end

function F:GetRaidInfoBySubgroupIndex(group, index)
    local currentIndex = 0
    for i = 1, GetNumGroupMembers() do
        local name, rank, subgroup = GetRaidRosterInfo(i)
        if subgroup == group then
            currentIndex = currentIndex + 1
            if currentIndex == index then
                return i, name, rank -- found
            end
        elseif subgroup > group and currentIndex ~= 0 then
            return -- nil if not found
        end
    end
end

function F:GetPetUnit(playerUnit)
    if Cell.vars.groupType == "party" then
        if playerUnit == "player" then
            return "pet"
        else
            return "partypet"..select(3, strfind(playerUnit, "^party(%d+)$"))
        end
    elseif Cell.vars.groupType == "raid" then
        return "raidpet"..select(3, strfind(playerUnit, "^raid(%d+)$"))
    else
        return "pet"
    end
end

function F:GetPlayerUnit(petUnit)
    if petUnit == "pet" then
        return "player"
    else
        return petUnit:gsub("pet", "")
    end
end

function F:IterateGroupMembers()
    local groupType = IsInRaid() and "raid" or "party"
    local numGroupMembers = GetNumGroupMembers()
    local i

    if groupType == "party" then
        i = 0
        numGroupMembers = numGroupMembers - 1
    else
        i = 1
    end

    return function()
        local ret
        if i == 0 then
            ret = "player"
        elseif i <= numGroupMembers and i > 0 then
            ret = groupType .. i
        end
        i = i + 1
        return ret
    end
end

function F:IterateGroupPets()
    local groupType = IsInRaid() and "raid" or "party"
    local numGroupMembers = GetNumGroupMembers()
    local i = groupType == "party" and 0 or 1

    return function()
        local ret
        if i == 0 and groupType == "party" then
            ret = "pet"
        elseif i <= numGroupMembers and i > 0 then
            ret = groupType .. "pet" .. i
        end
        i = i + 1
        return ret
    end
end

function F:GetGroupType()
    if IsInRaid() then
        return "raid"
    elseif IsInGroup() then
        return "party"
    else
        return "solo"
    end
end

function F:UnitInGroup(unit, ignorePets)
    if ignorePets then
        return UnitIsUnit(unit, "player") or UnitInParty(unit) or UnitInRaid(unit) or UnitInPartyIsAI(unit)
    else
        return UnitIsUnit(unit, "player") or UnitIsUnit(unit, "pet") or UnitPlayerOrPetInParty(unit) or UnitPlayerOrPetInRaid(unit) or UnitInPartyIsAI(unit)
    end
end

-- UnitTokenFromGUID
function F:GetTargetUnitID(target)
    if UnitIsUnit(target, "player") then
        return "player"
    elseif UnitIsUnit(target, "pet") then
        return "pet"
    end

    if not F:UnitInGroup(target) then return end

    if UnitIsPlayer(target) or UnitInPartyIsAI(target) then
        for unit in F:IterateGroupMembers() do
            if UnitIsUnit(target, unit) then
                return unit
            end
        end
    else
        for unit in F:IterateGroupPets() do
            if UnitIsUnit(target, unit) then
                return unit
            end
        end
    end
end

function F:GetTargetPetID(target)
    if UnitIsUnit(target, "player") then
        return "pet"
    end

    if not F:UnitInGroup(target) then return end

    if UnitIsPlayer(target) or UnitInPartyIsAI(target) then
        for unit in F:IterateGroupMembers() do
            if UnitIsUnit(target, unit) then
                return F:GetPetUnit(unit)
            end
        end
    end
end

-- https://wowpedia.fandom.com/wiki/UnitFlag
local OBJECT_AFFILIATION_MINE = 0x00000001
local OBJECT_AFFILIATION_PARTY = 0x00000002
local OBJECT_AFFILIATION_RAID = 0x00000004

function F:IsFriend(unitFlags)
    if not unitFlags then return false end
    return (bit.band(unitFlags, OBJECT_AFFILIATION_MINE) ~= 0) or (bit.band(unitFlags, OBJECT_AFFILIATION_RAID) ~= 0) or (bit.band(unitFlags, OBJECT_AFFILIATION_PARTY) ~= 0)
end

function F:IsPlayer(guid)
    if guid then
        return string.find(guid, "^Player")
    end
end

function F:IsPet(guid)
    if guid then
        return string.find(guid, "^Pet")
    end
end

function F:IsNPC(guid)
    if guid then
        return string.find(guid, "^Creature")
    end
end

function F:IsVehicle(guid)
    if guid then
        return string.find(guid, "^Vehicle")
    end
end

function F:GetTargetUnitInfo()
    if UnitIsUnit("target", "player") then
        return "player", UnitName("player"), UnitClassBase("player")
    elseif UnitIsUnit("target", "pet") then
        return "pet", UnitName("pet")
    end
    if not F:UnitInGroup("target") then return end

    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            if UnitIsUnit("target", "raid"..i) then
                return "raid"..i, UnitName("raid"..i), UnitClassBase("raid"..i)
            end
            if UnitIsUnit("target", "raidpet"..i) then
                return "raidpet"..i, UnitName("raidpet"..i)
            end
        end
    elseif IsInGroup() then
        for i = 1, GetNumGroupMembers()-1 do
            if UnitIsUnit("target", "party"..i) then
                return "party"..i, UnitName("party"..i), UnitClassBase("party"..i)
            end
            if UnitIsUnit("target", "partypet"..i) then
                return "partypet"..i, UnitName("partypet"..i)
            end
        end
    end
end

function F:HasPermission(isPartyMarkPermission)
    if isPartyMarkPermission and IsInGroup() and not IsInRaid() then return true end
    return UnitIsGroupLeader("player") or (IsInRaid() and UnitIsGroupAssistant("player"))
end

-------------------------------------------------
-- range checker
-------------------------------------------------
local UnitIsVisible = UnitIsVisible
local UnitInRange = UnitInRange
local UnitCanAssist = UnitCanAssist
local UnitCanAttack = UnitCanAttack
local UnitCanCooperate = UnitCanCooperate
local IsSpellInRange = IsSpellInRange
local IsItemInRange = IsItemInRange
local CheckInteractDistance = CheckInteractDistance
local UnitIsDead = UnitIsDead
local GetSpellTabInfo = GetSpellTabInfo
local GetNumSpellTabs = GetNumSpellTabs
local GetSpellBookItemName = GetSpellBookItemName
local BOOKTYPE_SPELL = BOOKTYPE_SPELL

local playerClass = UnitClassBase("player")

local friendSpells = {
    ["DEATHKNIGHT"] = 61999,
    -- ["DEMONHUNTER"] = ,
    ["DRUID"] = Cell.isRetail and 8936 or 5185,
    ["EVOKER"] = 361469,
    ["HUNTER"] = 136,
    ["MAGE"] = 1459,
    ["MONK"] = 116670,
    ["PALADIN"] = Cell.isRetail and 19750 or 635,
    ["PRIEST"] = Cell.isRetail and 2061 or 2050,
    ["ROGUE"] = 2764,
    ["SHAMAN"] = Cell.isRetail and 8004 or 331,
    ["WARLOCK"] = 20707,
    -- ["WARRIOR"] = ,
}

local harmSpells = {
    ["DEATHKNIGHT"] = 47541,
    ["DEMONHUNTER"] = 185123,
    ["DRUID"] = 5176,
    ["EVOKER"] = 361469,
    ["HUNTER"] = 75,
    ["MAGE"] = 116,
    ["MONK"] = 117952,
    ["PALADIN"] = 20271,
    ["PRIEST"] = Cell.isRetail and 589 or 585,
    -- ["ROGUE"] = ,
    ["SHAMAN"] = Cell.isRetail and 188196 or 403,
    ["WARLOCK"] = 686,
    ["WARRIOR"] = 355,
}

local friendItems = {
    ["DEATHKNIGHT"] = 34471,
    ["DEMONHUNTER"] = 34471,
    ["DRUID"] = 34471,
    ["EVOKER"] = 1180, -- 30y
    ["HUNTER"] = 34471,
    ["MAGE"] = 34471,
    ["MONK"] = 34471,
    ["PALADIN"] = 34471,
    ["PRIEST"] = 34471,
    ["ROGUE"] = 34471,
    ["SHAMAN"] = 34471,
    ["WARLOCK"] = 34471,
    ["WARRIOR"] = 34471,
}

local harmItems = {
    ["DEATHKNIGHT"] = 28767,
    ["DEMONHUNTER"] = 28767,
    ["DRUID"] = 28767,
    ["EVOKER"] = 24268, -- 25y
    ["HUNTER"] = 28767,
    ["MAGE"] = 28767,
    ["MONK"] = 28767,
    ["PALADIN"] = 28767,
    ["PRIEST"] = 28767,
    ["ROGUE"] = 28767,
    ["SHAMAN"] = 28767,
    ["WARLOCK"] = 28767,
    ["WARRIOR"] = 28767,
}

local function GetNumSpells()
    local _, _, offset, numSpells = GetSpellTabInfo(GetNumSpellTabs())
    return offset + numSpells
end

local function FindSpellIndex(spellName)
    if not spellName or spellName == "" then
        return nil
    end
    for i = 1, GetNumSpells() do
        local spell = GetSpellBookItemName(i, BOOKTYPE_SPELL)
        if spell == spellName then
            return i
        end
    end
    return nil
end

-- do
--     -- NOTE: convert ID to NAME then to INDEX
--     for k, id in pairs(friendSpells) do
--         friendSpells[k] = FindSpellIndex(GetSpellInfo(id))
--     end
--     for k, id in pairs(harmSpells) do
--         harmSpells[k] = FindSpellIndex(GetSpellInfo(id))
--     end
-- end

local function UnitInSpellRange(spellIndex, unit)
    if not spellIndex then return end
    return IsSpellInRange(spellIndex, BOOKTYPE_SPELL, unit) == 1
end

local rc = CreateFrame("Frame")
rc:RegisterEvent("SPELLS_CHANGED")

if playerClass == "EVOKER" then
    local spell_dead, spell_alive, spell_harm
    rc:SetScript("OnEvent", function()
        spell_dead = FindSpellIndex(GetSpellInfo(361227))
        spell_alive = FindSpellIndex(GetSpellInfo(361469))
        spell_harm = FindSpellIndex(GetSpellInfo(361469))
    end)

    -- NOTE: UnitInRange for evoker is around 50y
    function F:IsInRange(unit, check)
        if not UnitIsVisible(unit) then
            return false
        end
    
        if UnitIsUnit("player", unit) then
            return true
        -- elseif not check and F:UnitInGroup(unit) then
        --     -- NOTE: UnitInRange only works with group players/pets
        --     local checked
        --     inRange, checked = UnitInRange(unit)
        --     if not checked then
        --         return F:IsInRange(unit, true)
        --     end
        --     return inRange
        else
            -- UnitCanCooperate works with cross-faction, UnitCanAssist does not
            if UnitCanAssist("player", unit) or UnitCanCooperate("player", unit) then
                -- print("CanAssist", unit)
                if UnitIsDead(unit) then
                    return UnitInSpellRange(spell_dead, unit) -- 40y
                else
                    return UnitInSpellRange(spell_alive, unit) -- 25/30y
                end
            elseif UnitCanAttack("player", unit) then
                -- print("CanAttack", unit)
                return UnitInSpellRange(spell_harm, unit)
            end
           
            -- print("InRange", unit)
            return UnitInRange(unit)
        end
    end
else
    local spell_friend, spell_harm
    rc:SetScript("OnEvent", function()
        spell_friend = FindSpellIndex(GetSpellInfo(friendSpells[playerClass]))
        spell_harm = FindSpellIndex(GetSpellInfo(harmSpells[playerClass]))
    end)

    if Cell.isRetail then
        function F:IsInRange(unit, check)
            if not UnitIsVisible(unit) then
                return false
            end
        
            if UnitIsUnit("player", unit) then
                return true
            elseif not check and F:UnitInGroup(unit) then
                -- NOTE: UnitInRange only works with group players/pets --! but not available for PLAYER PET when SOLO
                local checked
                inRange, checked = UnitInRange(unit)
                if not checked then
                    return F:IsInRange(unit, true)
                end
                return inRange
            else
                if UnitCanAssist("player", unit) or UnitCanCooperate("player", unit) then
                    -- print("CanAssist", unit)
                    if spell_friend then
                        return UnitInSpellRange(spell_friend, unit)
                    end
                elseif UnitCanAttack("player", unit) then
                    -- print("CanAttack", unit)
                    if spell_harm then
                        return UnitInSpellRange(spell_harm, unit)
                    end
                end

                -- print("InRange", unit)
                return UnitInRange(unit)
            end
        end
    else
        function F:IsInRange(unit, check)
            if not UnitIsVisible(unit) then
                return false
            end
        
            if UnitIsUnit("player", unit) then
                return true
            elseif not check and F:UnitInGroup(unit) then
                -- NOTE: UnitInRange only works with group players/pets --! but not available for PLAYER PET when SOLO
                local checked
                inRange, checked = UnitInRange(unit)
                if not checked then
                    return F:IsInRange(unit, true)
                end
                return inRange
            else
                if UnitCanAssist("player", unit) then
                    -- print("CanAssist", unit)
                    if spell_friend then
                        return UnitInSpellRange(spell_friend, unit)
                    else
                        return IsItemInRange(friendItems[playerClass], unit)
                    end
                elseif UnitCanAttack("player", unit) then
                    -- print("CanAttack", unit)
                    if spell_harm then
                        return UnitInSpellRange(spell_harm, unit)
                    else
                        return IsItemInRange(harmItems[playerClass], unit)
                    end
                end
                
                -- print("CheckInteractDistance", unit)
                return CheckInteractDistance(unit, 4) -- 28 yards
            end
        end
    end
end

-------------------------------------------------
-- LibSharedMedia
-------------------------------------------------
Cell.vars.texture = "Interface\\AddOns\\Cell\\Media\\statusbar.tga"

local LSM = LibStub("LibSharedMedia-3.0", true)
LSM:Register("statusbar", "Cell ".._G.DEFAULT, Cell.vars.texture)
LSM:Register("font", "visitor", [[Interface\Addons\Cell\Media\Fonts\visitor.ttf]], 255) 

function F:GetBarTexture()
    --! update Cell.vars.texture for further use in UnitButton_OnLoad
    if LSM:IsValid("statusbar", CellDB["appearance"]["texture"]) then
        Cell.vars.texture = LSM:Fetch("statusbar", CellDB["appearance"]["texture"])
    else
        Cell.vars.texture = "Interface\\AddOns\\Cell\\Media\\statusbar.tga"
    end
    return Cell.vars.texture
end

function F:GetBarTextureByName(name)
    if LSM:IsValid("statusbar", name) then
        return LSM:Fetch("statusbar", name)
    end
    return "Interface\\AddOns\\Cell\\Media\\statusbar.tga"
end

function F:GetFont(font)
    if font and LSM:IsValid("font", font) then
        return LSM:Fetch("font", font)
    elseif type(font) == "string" and strfind(strlower(font), ".ttf$") then
        return font
    else
        if CellDB["appearance"]["useGameFont"] then
            return GameFontNormal:GetFont()
        else
            return "Interface\\AddOns\\Cell\\Media\\Fonts\\Accidental_Presidency.ttf"
        end
    end
end

local defaultFontName = "Cell ".._G.DEFAULT
local defaultFont
function F:GetFontItems()
    if CellDB["appearance"]["useGameFont"] then
        defaultFont = GameFontNormal:GetFont()
    else
        defaultFont = "Interface\\AddOns\\Cell\\Media\\Fonts\\Accidental_Presidency.ttf"
    end

    local items = {}
    local fonts, fontNames
    
    -- if LSM then
        fonts, fontNames = F:Copy(LSM:HashTable("font")), F:Copy(LSM:List("font"))
        -- insert default font
        tinsert(fontNames, 1, defaultFontName)
        fonts[defaultFontName] = defaultFont

        for _, name in pairs(fontNames) do
            tinsert(items, {
                ["text"] = name,
                ["font"] = fonts[name],
                -- ["onClick"] = function()
                --     CellDB["appearance"]["font"] = name
                --     Cell:Fire("UpdateAppearance", "font")
                -- end,
            })
        end
    -- else
    --     fontNames = {defaultFontName}
    --     fonts = {[defaultFontName] = defaultFont}

    --     tinsert(items, {
    --         ["text"] = defaultFontName,
    --         ["font"] = defaultFont,
    --         -- ["onClick"] = function()
    --         --     CellDB["appearance"]["font"] = defaultFontName
    --         --     Cell:Fire("UpdateAppearance", "font")
    --         -- end,
    --     })
    -- end
    return items, fonts, defaultFontName, defaultFont 
end

-------------------------------------------------
-- texture
-------------------------------------------------
function F:GetTexCoord(width, height)
    -- ULx,ULy, LLx,LLy, URx,URy, LRx,LRy
    local texCoord = {0.12, 0.12, 0.12, 0.88, 0.88, 0.12, 0.88, 0.88}
    local aspectRatio = width / height

    local xRatio = aspectRatio < 1 and aspectRatio or 1
    local yRatio = aspectRatio > 1 and 1 / aspectRatio or 1

    for i, coord in ipairs(texCoord) do
        local aspectRatio = (i % 2 == 1) and xRatio or yRatio
        texCoord[i] = (coord - 0.5) * aspectRatio + 0.5
    end
    
    return texCoord
end

-- function F:RotateTexture(tex, degrees)
--     local angle = math.rad(degrees)
--     local cos, sin = math.cos(angle), math.sin(angle)
--     tex:SetTexCoord((sin - cos), -(cos + sin), -cos, -sin, sin, -cos, 0, 0)
-- end

-- https://wowpedia.fandom.com/wiki/Applying_affine_transformations_using_SetTexCoord
local s2 = sqrt(2)
local function CalculateCorner(degrees)
    local r = math.rad(degrees)
    return 0.5 + math.cos(r) / s2, 0.5 + math.sin(r) / s2
end
function F:RotateTexture(texture, degrees)
    local LRx, LRy = CalculateCorner(degrees + 45)
    local LLx, LLy = CalculateCorner(degrees + 135)
    local ULx, ULy = CalculateCorner(degrees + 225)
    local URx, URy = CalculateCorner(degrees - 45)
    
    texture:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)
end

-- wow atlases
local wowAtlases = {
    "playerpartyblip",
    "Artifacts-PerkRing-WhiteGlow",
    "AftLevelup-WhiteIconGlow",
    "LootBanner-IconGlow",
    "AftLevelup-WhiteStarBurst",
    "ChallengeMode-WhiteSpikeyGlow",
    "UI-QuestPoiCampaign-OuterGlow",
    "vignettekill",
    "PetJournal-FavoritesIcon",
    "dungeonskull",
    "questnormal",
    "questturnin",
    "bags-icon-addslots",
    "communities-chat-icon-plus",
    "communities-chat-icon-minus",
}

-- wow textures
local wowTextures = {

}

-- shapes
local shapes = {
    "circle_blurred",
    "circle_filled",
    "circle_thin",
    "circle",
    "heart_filled",
    "heart",
    "rhombus",
    "rhombus_filled",
    "square_filled",
    "square",
    "star_filled",
    "star",
    "starburst_filled",
    "starburst",
    "triangle_filled",
    "triangle",
}

-- weakauras
local powaTextures = {
    9, 10, 12, 13, 14, 15, 21, 22, 25, 27, 29,
    37, 38, 39, 40, 41, 42, 43, 44,
    49, 51, 52, 53, 58, 78, 118, 84,
    96, 97, 98, 99, 100, 114, 115, 116, 132, 138, 143
}

function F:GetTextures()
    local builtIns = #wowAtlases + #wowTextures + #shapes

    local t = {}
    
    -- wow atlases
    for _, wa in pairs(wowAtlases) do
        tinsert(t, wa)
    end
    
    -- wow textures
    for _, wt in pairs(wowTextures) do
        tinsert(t, wt)
    end

    -- built-ins
    for _, s in pairs(shapes) do
        tinsert(t, "Interface\\AddOns\\Cell\\Media\\Shapes\\"..s..".tga")
    end
    
    -- add weakauras textures
    if WeakAuras then
        builtIns = builtIns + #powaTextures
        for _, powa in pairs(powaTextures) do
            tinsert(t, "Interface\\AddOns\\WeakAuras\\PowerAurasMedia\\Auras\\Aura"..powa..".tga")
        end
    end

    -- customs
    for _, path in pairs(CellDB["customTextures"]) do
        tinsert(t, path)
    end

    return builtIns, t
end

-------------------------------------------------
-- frame position
-------------------------------------------------
-- function F:SavePosition(frame, pTable)
--     local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint(1)
--     pTable[1], pTable[2], pTable[3], pTable[4] = point, relativePoint, xOfs, yOfs
-- end

-- function F:RestorePosition(frame, pTable)
--     frame:ClearAllPoints()
--     frame:SetPoint(pTable[1], UIParent, pTable[2], pTable[3], pTable[4])
-- end

-------------------------------------------------
-- instance
-------------------------------------------------
function F:GetInstanceName()
    if IsInInstance() then
        local name = GetInstanceInfo()
        if not name then name = GetRealZoneText() end
        return name
    else
        local mapID = C_Map.GetBestMapForUnit("player")
        if type(mapID) ~= "number" or mapID < 1 then
            return ""
        end

        local info = MapUtil.GetMapParentInfo(mapID, Enum.UIMapType.Continent, true)
        if info then
            return info.name, info.mapID
        end

        return ""
    end
end

-------------------------------------------------
-- spell description
-------------------------------------------------
-- https://wow.gamepedia.com/UIOBJECT_GameTooltip
-- local function EnumerateTooltipLines_helper(...)
--     for i = 1, select("#", ...) do
--        local region = select(i, ...)
--        if region and region:GetObjectType() == "FontString" then
--           local text = region:GetText() -- string or nil
--           print(region:GetName(), text)
--        end
--     end
-- end

-- https://wowpedia.fandom.com/wiki/Patch_10.0.2/API_changes
local lines = {}
function F:GetSpellInfo(spellId)
    wipe(lines)
    
    local name, _, icon = GetSpellInfo(spellId)
    if not name then return end

    local data = C_TooltipInfo.GetSpellByID(spellId)
    for i, line in ipairs(data.lines) do
        TooltipUtil.SurfaceArgs(line)
        -- line.leftText
        -- line.rightText
    end

    return name, icon, table.concat(lines, "\n")
end

-------------------------------------------------
-- auras
-------------------------------------------------
-- name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod = UnitAura
-- NOTE: FrameXML/AuraUtil.lua
-- AuraUtil.FindAura(predicate, unit, filter, predicateArg1, predicateArg2, predicateArg3)
-- predicate(predicateArg1, predicateArg2, predicateArg3, ...)
local function predicate(...)
    local idToFind = ...
    local id = select(13, ...)
    return idToFind == id
end

function F:FindAuraById(unit, type, spellId)
    if type == "BUFF" then
        return AuraUtil.FindAura(predicate, unit, "HELPFUL", spellId)
    else
        return AuraUtil.FindAura(predicate, unit, "HARMFUL", spellId)
    end
end

if Cell.isRetail then
    function F:FindDebuffByIds(unit, spellIds)
        local debuffs = {}
        AuraUtil.ForEachAura(unit, "HARMFUL", nil, function(name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId)
            if spellIds[spellId] then
                debuffs[spellId] = I.CheckDebuffType(debuffType, spellId)
            end
        end)
        return debuffs
    end

    function F:FindAuraByDebuffTypes(unit, types)
        local debuffs = {}
        AuraUtil.ForEachAura(unit, "HARMFUL", nil, function(name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId)
            if types == "all" or types[debuffType] then
                debuffs[spellId] = I.CheckDebuffType(debuffType, spellId)
            end
        end)
        return debuffs
    end
else
    function F:FindDebuffByIds(unit, spellIds)
        local debuffs = {}
        for i = 1, 40 do
            local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId = UnitDebuff(unit, i)
            if not name then
                break
            end

            if spellIds[spellId] then
                debuffs[spellId] = I.CheckDebuffType(debuffType, spellId)
            end
        end
        return debuffs
    end

    function F:FindAuraByDebuffTypes(unit, types)
        local debuffs = {}
        for i = 1, 40 do
            local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId = UnitDebuff(unit, i)
            if not name then
                break
            end

            if types == "all" or types[debuffType] then
                debuffs[spellId] = I.CheckDebuffType(s, spellId)
            end
        end
        return debuffs
    end
end

-------------------------------------------------
-- OmniCD
-------------------------------------------------
function F:UpdateOmniCDPosition(frame)
    if OmniCD and OmniCD[1].db.position.uf == frame then
        C_Timer.After(0.5, function()
            OmniCD[1].Party:UpdatePosition()
        end)
    end
end

-------------------------------------------------
-- LibGetFrame
-------------------------------------------------
-- function Cell.GetUnitFrame(unit)
--     local normal, spotlights, quickAssist = F:GetUnitButtonByUnit(unit, true, true)
--     if CellDB["general"]["framePriority"] == "normal_spotlight_quickassist" then
--         if normal then return normal end
--         if spotlights[1] then return spotlights[1] end
--         return quickAssist
--     elseif CellDB["general"]["framePriority"] == "spotlight_normal_quickassist" then
--         if spotlights[1] then return spotlights[1] end
--         if normal then return normal end
--         return quickAssist
--     else -- "quickassist_normal_spotlight"
--         if quickAssist then return quickAssist end
--         if normal then return normal end
--         return spotlights[1]
--     end
-- end

local WA_GetUnitFrame, LGF_GetUnitFrame

function Cell.GetUnitFrame(unit)
    local normal, spotlights, quickAssist = F:GetUnitButtonByUnit(unit, true, true)
    
    if CellDB["general"]["framePriority"] == "normal_spotlight_quickassist" then
        if normal and normal:IsVisible() then
            frame = normal
        elseif spotlights[1] and spotlights[1]:IsVisible() then
            frame = spotlights[1]
        else
            frame = quickAssist
        end
    elseif CellDB["general"]["framePriority"] == "spotlight_normal_quickassist" then
        if spotlights[1] and spotlights[1]:IsVisible() then
            frame = spotlights[1]
        elseif normal and normal:IsVisible() then
            frame = normal
        else
            frame = quickAssist
        end
    else -- "quickassist_normal_spotlight"
        if quickAssist and quickAssist:IsVisible() then
            frame = quickAssist
        elseif normal and normal:IsVisible() then
            frame = normal
        else
            frame = spotlights[1]
        end
    end

    if frame then
        return frame
    elseif WA_GetUnitFrame then
        return WA_GetUnitFrame(unit)
    elseif LGF_GetUnitFrame then
        return LGF_GetUnitFrame(unit)
    end
end

function F:OverrideLGF(override)
    if not override then return end

    -- override LGF
    local LGF = LibStub("LibGetFrame-1.0", true)
    if LGF then
        LGF_GetUnitFrame = LGF.GetUnitFrame
        LGF.GetUnitFrame = Cell.GetUnitFrame
        LGF.GetFrame = Cell.GetUnitFrame
    end
    -- override WA
    if WeakAuras then
        WA_GetUnitFrame = WeakAuras.GetUnitFrame
        WeakAuras.GetUnitFrame = Cell.GetUnitFrame
    end
end