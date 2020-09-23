local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

-------------------------------------------------
-- string
-------------------------------------------------
function F:UpperFirst(str)
    return (str:gsub("^%l", string.upper))
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

function F:RemoveElementsByKeys(tbl, keys, returnNewTable) -- keys is a table
	local newTbl = {}
	for k, v in pairs(tbl) do
		if not F:TContains(keys, k) then
			newTbl[k] = tbl[k]
		end
    end
    if returnNewTable then
        return newTbl
    else
        tbl = newTbl
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

function F:StringToTable(s, sep)
    local t = {}
    for i, v in pairs({string.split(sep, s)}) do
        v = strtrim(v)
        if v ~= "" then
            tinsert(t, v)
        end
    end
    return t
end

function F:TableToString(t, sep)
    return table.concat(t, sep)
end

function F:ConvertTable(t)
    local temp = {}
    for _, v in ipairs(t) do
        temp[v] = true
    end
    return temp
end

-------------------------------------------------
-- general
-------------------------------------------------
function F:GetRealmName()
	return string.gsub(GetRealmName(), " ", "")
end

function F:UnitName(unit)
    if not unit then return "" end

    local name = UnitName(unit)
    if not string.find(name, "-") then name = name .. "-" .. F:GetRealmName() end
    return name
end

function F:GetShortName(fullName)
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

-------------------------------------------------
-- unit buttons
-------------------------------------------------
function F:IterateAllUnitButtons(func)
    -- solo
    for _, b in pairs(Cell.unitButtons.solo) do
        func(b)
    end
    -- party
    for _, b in pairs(Cell.unitButtons.party) do
        func(b)
    end
    -- raid
    for _, header in pairs(Cell.unitButtons.raid) do
        for _, b in ipairs(header) do
            func(b)
        end
    end
end

function F:SetTextLimitWidth(fs, text, percent)
    if not text then return end

    local width = fs:GetParent():GetWidth() - 2
	for i = string.utf8len(text), 0, -1 do
		fs:SetText(string.utf8sub(text, 1, i))
		if fs:GetWidth() / width <= percent then
			break
		end
	end
end

local RAID_CLASS_COLORS = RAID_CLASS_COLORS
function F:GetClassColor(class)
    if class then
        return RAID_CLASS_COLORS[class]:GetRGB()
    else
        return 1, 1, 1
    end
end

function F:GetPowerColor(unit)
    local r, g, b, t
    -- https://wow.gamepedia.com/API_UnitPowerType
    local powerType, powerToken, altR, altG, altB = UnitPowerType(unit)
    t = powerType

    local info = PowerBarColor[powerToken]
    if powerType == 0 then -- MANA
        info = {r=0, g=.5, b=1} -- default mana color is too dark!
    elseif powerType == 13 then -- INSANITY
        info = {r=.6, g=.2, b=1}
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

local scriptObjects = {}
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_ENABLED" then
        for _, obj in pairs(scriptObjects) do
            obj:Show()
        end
    else
        for _, obj in pairs(scriptObjects) do
            obj:Hide()
        end
    end
end)
function F:SetHideInCombat(obj)
    tinsert(scriptObjects, obj)
end

-------------------------------------------------
-- units
-------------------------------------------------
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

function F:GetPetUnit(playerUnit)
    if Cell.vars.groupType == "party" then
        return "partypet"..strfind(playerUnit, "^party(%d+)$")
    elseif Cell.vars.groupType == "raid" then
        return "raidpet"..strfind(playerUnit, "^raid(%d+)$")
    else
        return "pet"
    end
end

-------------------------------------------------
-- LibSharedMedia
-------------------------------------------------
local LSM = LibStub("LibSharedMedia-3.0", true)
function F:GetBarTexture()
    --! update Cell.vars.texture for further use in UnitButton_OnLoad
    if LSM and LSM:IsValid("statusbar", CellDB["texture"]) then
        Cell.vars.texture = LSM:Fetch("statusbar", CellDB["texture"])
    else
        Cell.vars.texture = "Interface\\AddOns\\Cell\\Media\\statusbar.tga"
    end
    return Cell.vars.texture
end

function F:GetFont(font)
    if not font then font = CellDB["font"] end
    if LSM and LSM:IsValid("font", font) then
        return LSM:Fetch("font", font)
    else
        return GameFontNormal:GetFont()
    end
end

local defaultFont, defaultFontName = GameFontNormal:GetFont(), "Cell ".._G.DEFAULT
function F:GetFontItems()
    local items = {}
    local fonts, fontNames
    
    if LSM then
        fonts, fontNames = F:Copy(LSM:HashTable("font")), F:Copy(LSM:List("font"))
        -- insert default texture
        tinsert(fontNames, 1, defaultFontName)
        fonts[defaultFontName] = defaultFont

        for _, name in pairs(fontNames) do
            tinsert(items, {
                ["text"] = name,
                ["font"] = fonts[name],
                -- ["onClick"] = function()
                --     CellDB["font"] = name
                --     Cell:Fire("UpdateAppearance", "font")
                -- end,
            })
        end
    else
        fontNames = {defaultFontName}
        fonts = {[defaultFontName] = defaultFont}

        tinsert(items, {
            ["text"] = defaultFontName,
            ["font"] = defaultFont,
            -- ["onClick"] = function()
            --     CellDB["font"] = defaultFontName
            --     Cell:Fire("UpdateAppearance", "font")
            -- end,
        })
    end
    return items, fonts, defaultFontName, defaultFont 
end

-------------------------------------------------
-- texture
-------------------------------------------------
function F:GetTexCoord(width, height)
    -- ULx,ULy, LLx,LLy, URx,URy, LRx,LRy
    local texCoord = {.12, .12, .12, .88, .88, .12, .88, .88}
    local aspectRatio = width / height

    local xRatio = aspectRatio < 1 and aspectRatio or 1
    local yRatio = aspectRatio > 1 and 1 / aspectRatio or 1

    for i, coord in ipairs(texCoord) do
        local aspectRatio = (i % 2 == 1) and xRatio or yRatio
        texCoord[i] = (coord - 0.5) * aspectRatio + 0.5
    end
  
    return texCoord
  end