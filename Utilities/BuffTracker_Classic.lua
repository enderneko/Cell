local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local I = Cell.iFuncs
local U = Cell.uFuncs
local P = Cell.pixelPerfectFuncs
local LCG = LibStub("LibCustomGlow-1.0")
local A = Cell.animations

local UnitIsConnected = UnitIsConnected
local UnitIsVisible = UnitIsVisible
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsUnit = UnitIsUnit
local UnitIsPlayer = UnitIsPlayer
local UnitGUID = UnitGUID
local UnitClassBase = UnitClassBase
local UnitLevel = UnitLevel
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid

local sort, tinsert, tconcat = table.sort, table.insert, table.concat

---------------------------------------------------------------------
-- data
---------------------------------------------------------------------
local buffs = {}
local requiredBuffs = {}
local available = {}
local unaffected = {}

if Cell.isTBC or Cell.isVanilla then
    buffs = {
        -- 1243: Power Word: Fortitude
        -- 21562: Prayer of Fortitude
        ["PWF"] = {buff1 = 1243, buff2 = 21562, provider = "PRIEST", order = 1},

        -- 14752: Divine Spirit
        -- 27681: Prayer of Spirit
        ["DS"] = {buff1 = 14752, buff2 = 27681, provider = "PRIEST", order = 8},

        -- 976: Shadow Protection
        -- 27683: Prayer of Shadow Protection
        ["SP"] = {buff1 = 976, buff2 = 27683, provider = "PRIEST", order = 9},

        -- 1459: Arcane Intellect
        -- 23028: Arcane Brilliance
        ["AB"] = {buff1 = 1459, buff2 = 23028, provider = "MAGE", order = 2},

        -- 6673: Battle Shout
        -- ["BS"] = {buff1 = 6673, provider = "WARRIOR", order = 3},

        -- 1126: Mark of the Wild
        -- 21849: Gift of the Wild
        ["MotW"] = {buff1 = 1126, buff2 = 21849, provider = "DRUID", order = 3},

        -- 20217: Blessing of Kings
        -- 25898: Greater Blessing of Kings
        ["BoK"] = {buff1 = 20217, buff2 = 25898, provider = "PALADIN", order = 4},

        -- 19740: Blessing of Might
        -- 25782: Greater Blessing of Might
        ["BoM"] = {buff1 = 19740, buff2 = 25782, provider = "PALADIN", order = 5},

        -- 19742: Blessing of Wisdom
        -- 25894: Greater Blessing of Wisdom
        ["BoW"] = {buff1 = 19742, buff2 = 25894, provider = "PALADIN", order = 6},

        -- 20911: Blessing of Sanctuary
        -- 25899: Greater Blessing of Sanctuary
        ["BoS"] = {buff1 = 20911, buff2 = 25899, provider = "PALADIN", order = 7},
    }

    requiredBuffs = {
        ["WARRIOR"] = {["PWF"] = true, ["MotW"] = true, ["BoK"] = true, ["BoM"] = true, ["BoS"] = true, ["SP"] = true},
        ["PALADIN"] = {["PWF"] = true, ["AB"] = true, ["DS"] = true, ["MotW"] = true, ["BoK"] = true, ["BoM"] = true, ["BoW"] = true, ["BoS"] = true, ["SP"] = true},
        ["HUNTER"] = {["PWF"] = true, ["AB"] = true, ["MotW"] = true, ["BoK"] = true, ["BoM"] = true, ["BoS"] = true, ["SP"] = true},
        ["ROGUE"] = {["PWF"] = true, ["MotW"] = true, ["BoK"] = true, ["BoM"] = true, ["BoS"] = true, ["SP"] = true},
        ["PRIEST"] = {["PWF"] = true, ["AB"] = true, ["DS"] = true, ["MotW"] = true, ["BoK"] = true, ["BoW"] = true, ["BoS"] = true, ["SP"] = true},
        ["DEATHKNIGHT"] = {["PWF"] = true, ["MotW"] = true, ["BoK"] = true, ["BoM"] = true, ["BoS"] = true, ["SP"] = true},
        ["SHAMAN"] = {["PWF"] = true, ["AB"] = true, ["DS"] = true, ["MotW"] = true, ["BoK"] = true, ["BoM"] = true, ["BoW"] = true, ["BoS"] = true, ["SP"] = true},
        ["MAGE"] = {["PWF"] = true, ["AB"] = true, ["MotW"] = true, ["BoK"] = true, ["BoW"] = true, ["BoS"] = true, ["SP"] = true},
        ["WARLOCK"] = {["PWF"] = true, ["AB"] = true, ["MotW"] = true, ["BoK"] = true, ["BoW"] = true, ["BoS"] = true, ["SP"] = true},
        ["DRUID"] = {["PWF"] = true, ["AB"] = true, ["DS"] = true, ["MotW"] = true, ["BoK"] = true, ["BoM"] = true, ["BoW"] = true, ["BoS"] = true, ["SP"] = true},
    }

    unaffected = {
        ["PWF"] = {},
        ["AB"] = {},
        ["DS"] = {},
        ["MotW"] = {},
        ["BoK"] = {},
        ["BoM"] = {},
        ["BoW"] = {},
        ["BoS"] = {},
        ["SP"] = {},
    }

elseif Cell.isWrath then
    buffs = {
        -- 1243: Power Word: Fortitude
        -- 21562: Prayer of Fortitude
        ["PWF"] = {buff1 = 1243, buff2 = 21562, provider = "PRIEST", order = 1},

        -- 14752: Divine Spirit
        -- 27681: Prayer of Spirit
        ["DS"] = {buff1 = 14752, buff2 = 27681, provider = "PRIEST", order = 8},

        -- 976: Shadow Protection
        -- 27683: Prayer of Shadow Protection
        ["SP"] = {buff1 = 976, buff2 = 27683, provider = "PRIEST", order = 9},

        -- 1459: Arcane Intellect
        -- 23028: Arcane Brilliance
        ["AB"] = {buff1 = 1459, buff2 = 23028, provider = "MAGE", order = 2},

        -- 6673: Battle Shout
        -- ["BS"] = {buff1 = 6673, provider="WARRIOR"},

        -- 469: Commanding Shout
        -- ["CS"] = {buff1 = 469, provider="WARRIOR"},

        -- 1126: Mark of the Wild
        -- 21849: Gift of the Wild
        ["MotW"] = {buff1 = 1126, buff2 = 21849, provider = "DRUID", order = 3},

        -- 20217: Blessing of Kings
        -- 25898: Greater Blessing of Kings
        ["BoK"] = {buff1 = 20217, buff2 = 25898, provider = "PALADIN", order = 4},

        -- 19740: Blessing of Might
        -- 25782: Greater Blessing of Might
        ["BoM"] = {buff1 = 19740, buff2 = 25782, provider = "PALADIN", order = 5},

        -- 19742: Blessing of Wisdom
        -- 25894: Greater Blessing of Wisdom
        ["BoW"] = {buff1 = 19742, buff2 = 25894, provider = "PALADIN", order = 6},

        -- 20911: Blessing of Sanctuary
        -- 25899: Greater Blessing of Sanctuary
        ["BoS"] = {buff1 = 20911, buff2 = 25899, provider = "PALADIN", order = 7},
    }

    requiredBuffs = {
        ["WARRIOR"] = {["PWF"] = true, ["MotW"] = true, ["BoK"] = true, ["BoM"] = true, ["BoS"] = true, ["SP"] = true},
        ["PALADIN"] = {["PWF"] = true, ["AB"] = true, ["DS"] = true, ["MotW"] = true, ["BoK"] = true, ["BoM"] = true, ["BoW"] = true, ["BoS"] = true, ["SP"] = true},
        ["HUNTER"] = {["PWF"] = true, ["MotW"] = true, ["BoK"] = true, ["BoM"] = true, ["BoS"] = true, ["SP"] = true},
        ["ROGUE"] = {["PWF"] = true, ["MotW"] = true, ["BoK"] = true, ["BoM"] = true, ["BoS"] = true, ["SP"] = true},
        ["PRIEST"] = {["PWF"] = true, ["AB"] = true, ["DS"] = true, ["MotW"] = true, ["BoK"] = true, ["BoW"] = true, ["BoS"] = true, ["SP"] = true},
        ["DEATHKNIGHT"] = {["PWF"] = true, ["MotW"] = true, ["BoK"] = true, ["BoM"] = true, ["BoS"] = true, ["SP"] = true},
        ["SHAMAN"] = {["PWF"] = true, ["AB"] = true, ["DS"] = true, ["MotW"] = true, ["BoK"] = true, ["BoM"] = true, ["BoW"] = true, ["BoS"] = true, ["SP"] = true},
        ["MAGE"] = {["PWF"] = true, ["AB"] = true, ["MotW"] = true, ["BoK"] = true, ["BoW"] = true, ["BoS"] = true, ["SP"] = true},
        ["WARLOCK"] = {["PWF"] = true, ["AB"] = true, ["MotW"] = true, ["BoK"] = true, ["BoW"] = true, ["BoS"] = true, ["SP"] = true},
        ["DRUID"] = {["PWF"] = true, ["AB"] = true, ["DS"] = true, ["MotW"] = true, ["BoK"] = true, ["BoM"] = true, ["BoW"] = true, ["BoS"] = true, ["SP"] = true},
    }

    unaffected = {
        ["PWF"] = {},
        ["AB"] = {},
        ["DS"] = {},
        ["MotW"] = {},
        ["BoK"] = {},
        ["BoM"] = {},
        ["BoW"] = {},
        ["BoS"] = {},
        ["SP"] = {},
    }

elseif Cell.isCata then
    buffs = {
        -- 21562: Power Word: Fortitude
        ["PWF"] = {buff1 = 21562, provider = "PRIEST", level = 14, order = 1},

        -- 27683: Shadow Protection
        ["SP"] = {buff1 = 27683, provider = "PRIEST", level = 52, order = 6},

        -- 1459: Arcane Brilliance
        ["AB"] = {buff1 = 1459, buff2 = 79058, provider = "MAGE", level = 58, order = 2},

        -- 6673: Battle Shout
        -- ["BS"] = {buff1 = 6673, provider = "WARRIOR", level = 20},

        -- 469: Commanding Shout
        -- ["CS"] = {buff1 = 469, provider = "WARRIOR", level = 68},

        -- 1126: Mark of the Wild
        ["MotW"] = {buff1 = 1126, provider = "DRUID", level = 30, order = 3},

        -- 20217: Blessing of Kings
        ["BoK"] = {buff1 = 20217, provider = "PALADIN", level = 22, order = 4},

        -- 19740: Blessing of Might
        ["BoM"] = {buff1 = 19740, provider = "PALADIN", level = 56, order = 5},
    }

    requiredBuffs = {
        ["WARRIOR"] = {["PWF"] = true, ["MotW"] = true, ["BoK"] = true, ["BoM"] = true, ["SP"] = true},
        ["PALADIN"] = {["PWF"] = true, ["AB"] = true, ["MotW"] = true, ["BoK"] = true, ["BoM"] = true, ["SP"] = true},
        ["HUNTER"] = {["PWF"] = true, ["MotW"] = true, ["BoK"] = true, ["BoM"] = true, ["SP"] = true},
        ["ROGUE"] = {["PWF"] = true, ["MotW"] = true, ["BoK"] = true, ["BoM"] = true, ["SP"] = true},
        ["PRIEST"] = {["PWF"] = true, ["AB"] = true, ["MotW"] = true, ["BoK"] = true, ["SP"] = true},
        ["DEATHKNIGHT"] = {["PWF"] = true, ["MotW"] = true, ["BoK"] = true, ["BoM"] = true, ["SP"] = true},
        ["SHAMAN"] = {["PWF"] = true, ["AB"] = true, ["MotW"] = true, ["BoK"] = true, ["BoM"] = true, ["SP"] = true},
        ["MAGE"] = {["PWF"] = true, ["AB"] = true, ["MotW"] = true, ["BoK"] = true, ["SP"] = true},
        ["WARLOCK"] = {["PWF"] = true, ["AB"] = true, ["MotW"] = true, ["BoK"] = true, ["SP"] = true},
        ["DRUID"] = {["PWF"] = true, ["AB"] = true, ["MotW"] = true, ["BoK"] = true, ["BoM"] = true, ["SP"] = true},
    }

    unaffected = {
        ["PWF"] = {},
        ["AB"] = {},
        ["MotW"] = {},
        ["BoK"] = {},
        ["BoM"] = {},
        ["SP"] = {},
    }
end

---------------------------------------------------------------------
-- prepare
---------------------------------------------------------------------
local classBuffs = {}
local buffOrder = {}
local buffsProvidedByMe = {}
local myClass = UnitClassBase("player")

do
    local function Handle(buff, t, k)
        local name, icon = F.GetSpellInfo(t[k])
        t[k] = {
            ["id"] = t[k],
            ["name"] = name,
            ["icon"] = icon,
        }

        classBuffs[t["provider"]] = classBuffs[t["provider"]] or {}
        classBuffs[t["provider"]][buff] = t.level or true

        if myClass == t["provider"] and not buffsProvidedByMe[buff] then
            buffsProvidedByMe[buff] = {name, icon}
        end
    end

    for k, t in pairs(buffs) do
        if t.buff1 then Handle(k, t, "buff1") end
        if t.buff2 then Handle(k, t, "buff2") end

        tinsert(buffOrder, k)
    end

    sort(buffOrder, function(a, b)
        return buffs[a].order < buffs[b].order
    end)
end

function U.GetBuffTrackerDefaults()
    local t = {}
    for k in pairs(buffs) do
        t[k] = true
    end
    return t
end

function U.GetBuffTrackerInfo()
    return buffOrder, buffs
end

---------------------------------------------------------------------
-- vars
---------------------------------------------------------------------
local myUnit = ""
local hasBuffProvider

local function Reset(which)
    if not which or which == "available" then
        wipe(available)
        hasBuffProvider = false
    end

    if not which or which == "unaffected" then
        for k, v in pairs(unaffected) do
            wipe(unaffected[k])
        end
    end
end

function F.GetUnaffectedString(spell)
    local list = unaffected[spell]
    local buff = buffs[spell]["buff1"]["name"]

    local players = {}
    for unit in pairs(list) do
        local name = UnitName(unit)
        tinsert(players, name)
    end

    if #players == 0 then
        return
    elseif #players <= 10 then
        return L["Missing Buff"] .. " (" .. buff .. "): " .. tconcat(players, ", ")
    else
        return L["Missing Buff"] .. " (" .. buff .. "): " .. L["many"]
    end
end

---------------------------------------------------------------------
-- frame
---------------------------------------------------------------------
local buffTrackerFrame = CreateFrame("Frame", "CellBuffTrackerFrame", Cell.frames.mainFrame, "BackdropTemplate")
Cell.frames.buffTrackerFrame = buffTrackerFrame
P.Size(buffTrackerFrame, 102, 50)
PixelUtil.SetPoint(buffTrackerFrame, "BOTTOMLEFT", CellParent, "CENTER", 1, 1)
buffTrackerFrame:SetClampedToScreen(true)
buffTrackerFrame:SetMovable(true)
buffTrackerFrame:RegisterForDrag("LeftButton")
buffTrackerFrame:SetScript("OnDragStart", function()
    buffTrackerFrame:StartMoving()
    buffTrackerFrame:SetUserPlaced(false)
end)
buffTrackerFrame:SetScript("OnDragStop", function()
    buffTrackerFrame:StopMovingOrSizing()
    P.SavePosition(buffTrackerFrame, CellDB["tools"]["buffTracker"][4])
end)

---------------------------------------------------------------------
-- mover
---------------------------------------------------------------------
buffTrackerFrame.moverText = buffTrackerFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
buffTrackerFrame.moverText:SetPoint("TOP", 0, -3)
buffTrackerFrame.moverText:SetText(L["Mover"])
buffTrackerFrame.moverText:Hide()

local fakeIconsFrame = CreateFrame("Frame", nil, buffTrackerFrame)
P.Point(fakeIconsFrame, "BOTTOMRIGHT", buffTrackerFrame)
P.Point(fakeIconsFrame, "TOPLEFT", buffTrackerFrame, "TOPLEFT", 0, -18)
fakeIconsFrame:EnableMouse(true)
fakeIconsFrame:SetFrameLevel(buffTrackerFrame:GetFrameLevel() + 10)
fakeIconsFrame:Hide()

local fakeIcons = {}
local function CreateFakeIcon(spellIcon)
    local bg = fakeIconsFrame:CreateTexture(nil, "BORDER")
    bg:SetColorTexture(0, 0, 0, 1)
    P.Size(bg, 32, 32)

    local icon = fakeIconsFrame:CreateTexture(nil, "ARTWORK")
    icon:SetTexture(spellIcon)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    P.Point(icon, "TOPLEFT", bg, "TOPLEFT", 1, -1)
    P.Point(icon, "BOTTOMRIGHT", bg, "BOTTOMRIGHT", -1, 1)

    function bg:UpdatePixelPerfect()
        P.Resize(bg)
        P.Repoint(bg)
        P.Repoint(icon)
    end

    return bg
end

do
    for _, k in ipairs(buffOrder) do
        tinsert(fakeIcons, CreateFakeIcon(buffs[k]["buff1"]["icon"]))
    end
end

local function ShowMover(show)
    if show then
        if not CellDB["tools"]["buffTracker"][1] then return end
        buffTrackerFrame:EnableMouse(true)
        buffTrackerFrame.moverText:Show()
        Cell.StylizeFrame(buffTrackerFrame, {0, 1, 0, 0.4}, {0, 0, 0, 0})
        fakeIconsFrame:Show()
        buffTrackerFrame:SetAlpha(1)
    else
        buffTrackerFrame:EnableMouse(false)
        buffTrackerFrame.moverText:Hide()
        Cell.StylizeFrame(buffTrackerFrame, {0, 0, 0, 0}, {0, 0, 0, 0})
        fakeIconsFrame:Hide()
        buffTrackerFrame:SetAlpha(CellDB["tools"]["fadeOut"] and 0 or 1)
    end
end
Cell.RegisterCallback("ShowMover", "BuffTracker_ShowMover", ShowMover)

---------------------------------------------------------------------
-- buttons
---------------------------------------------------------------------
local sendChannel
local function UpdateSendChannel()
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        sendChannel = "INSTANCE_CHAT"
    elseif IsInRaid() then
        sendChannel = "RAID"
    else
        sendChannel = "PARTY"
    end
end

local function CreateBuffButton(parent, size, spell1, spell2, icon, index)
    local b = CreateFrame("Button", nil, parent, "SecureActionButtonTemplate,BackdropTemplate")
    if parent then b:SetFrameLevel(parent:GetFrameLevel() + 1) end
    P.Size(b, size[1], size[2])

    b:SetBackdrop({edgeFile = Cell.vars.whiteTexture, edgeSize = P.Scale(1)})
    b:SetBackdropBorderColor(0, 0, 0, 1)

    b:RegisterForClicks("LeftButtonUp", "RightButtonUp", "LeftButtonDown", "RightButtonDown") -- NOTE: ActionButtonUseKeyDown will affect this
    b:SetAttribute("type1", "spell")
    b:SetAttribute("spell", spell1)
    b:SetAttribute("shift-type1", "spell")
    b:SetAttribute("shift-spell1", spell2)
    b:HookScript("OnClick", function(self, button, down)
        if button == "RightButton" and (down == GetCVarBool("ActionButtonUseKeyDown")) then
            local msg = F.GetUnaffectedString(index)
            if msg then
                UpdateSendChannel()
                SendChatMessage(msg, sendChannel)
            end
        end
    end)

    b.texture = b:CreateTexture(nil, "OVERLAY")
    P.Point(b.texture, "TOPLEFT", b, "TOPLEFT", 1, -1)
    P.Point(b.texture, "BOTTOMRIGHT", b, "BOTTOMRIGHT", -1, 1)
    b.texture:SetTexture(icon)
    b.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    b.count = b:CreateFontString(nil, "OVERLAY")
    P.Point(b.count, "TOPLEFT", b.texture, "TOPLEFT", 2, -2)
    b.count:SetFont(GameFontNormal:GetFont(), 14, "OUTLINE")
    b.count:SetShadowColor(0, 0, 0)
    b.count:SetShadowOffset(0, 0)
    b.count:SetTextColor(1, 0, 0)

    b:SetScript("OnLeave", function()
        CellTooltip:Hide()
    end)

    function b:SetTooltips(list)
        b:SetScript("OnEnter", function()
            if F.Getn(list) ~= 0 then
                CellTooltip:SetOwner(b, "ANCHOR_TOPLEFT", 0, 3)
                CellTooltip:AddLine(L["Unaffected"])
                for unit in pairs(list) do
                    local class = UnitClassBase(unit)
                    local name = UnitName(unit)
                    if class and name then
                        CellTooltip:AddLine(F.GetClassColorStr(class) .. name .. "|r")
                    end
                end
                CellTooltip:Show()
            end
        end)
    end

    function b:SetDesaturated(flag)
        b.texture:SetDesaturated(flag)
    end

    function b:StartGlow(glowType, ...)
        LCG.PixelGlow_Start(b, ...)
    end

    function b:StopGlow()
        LCG.PixelGlow_Stop(b)
    end

    function b:Reset()
        b.texture:SetDesaturated(false)
        b.count:SetText("")
        b:SetAlpha(1)
        b:StopGlow()
    end

    function b:UpdatePixelPerfect()
        P.Resize(b)
        P.Repoint(b)
        b:SetBackdrop({edgeFile = Cell.vars.whiteTexture, edgeSize = P.Scale(1)})
        b:SetBackdropBorderColor(0, 0, 0, 1)

        P.Repoint(b.texture)
        P.Repoint(b.count)
    end

    return b
end

local buttons = {}

do
    for _, k in ipairs(buffOrder) do
        buttons[k] = CreateBuffButton(buffTrackerFrame, {32, 32}, buffs[k]["buff1"]["name"], buffs[k]["buff2"] and buffs[k]["buff2"]["name"], buffs[k]["buff1"]["icon"], k)
        buttons[k]:Hide()
        buttons[k]:SetTooltips(unaffected[k])
    end
end

local function UpdateButtons()
    for _, buff in ipairs(buffOrder) do
        if available[buff] then
            local n = F.Getn(unaffected[buff])
            if n == 0 then
                buttons[buff].count:SetText("")
                buttons[buff]:SetAlpha(0.5)
                buttons[buff]:StopGlow()
            else
                buttons[buff].count:SetText(n)
                buttons[buff]:SetAlpha(1)
                if unaffected[buff][myUnit] then
                    -- color, N, frequency, length, thickness
                    buttons[buff]:StartGlow("Pixel", {1, 0.19, 0.19, 1}, 8, 0.25, P.Scale(8), P.Scale(2))
                else
                    buttons[buff]:StopGlow()
                end
            end
        end
    end
end

local function RepointButtons()
    if InCombatLockdown() then
        buffTrackerFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    else
        local point, relativePoint, offsetX, offsetY, firstX, firstY
        if CellDB["tools"]["buffTracker"][2] == "left-to-right" then
            point, relativePoint = "BOTTOMLEFT", "BOTTOMRIGHT"
            offsetX, offsetY = 3, 0
            firstX, firstY = 0, 0
        elseif CellDB["tools"]["buffTracker"][2] == "right-to-left" then
            point, relativePoint = "BOTTOMRIGHT", "BOTTOMLEFT"
            offsetX, offsetY = -3, 0
            firstX, firstY = 0, 0
        elseif CellDB["tools"]["buffTracker"][2] == "top-to-bottom" then
            point, relativePoint = "TOPLEFT", "BOTTOMLEFT"
            offsetX, offsetY = 0, -3
            firstX, firstY = 0, -18
        elseif CellDB["tools"]["buffTracker"][2] == "bottom-to-top" then
            point, relativePoint = "BOTTOMLEFT", "TOPLEFT"
            offsetX, offsetY = 0, 3
            firstX, firstY = 0, 0
        end

        local last
        for _, k in pairs(buffOrder) do
            P.ClearPoints(buttons[k])
            if available[k] then
                buttons[k]:Show()
                if last then
                    P.Point(buttons[k], point, last, relativePoint, offsetX, offsetY)
                else
                    P.Point(buttons[k], point, firstX, firstY)
                end
                last = buttons[k]
            else
                buttons[k]:Hide()
                buttons[k]:Reset()
            end
        end

        last = nil
        for _, icon in pairs(fakeIcons) do
            P.ClearPoints(icon)
            if last then
                P.Point(icon, point, last, relativePoint, offsetX, offsetY)
            else
                P.Point(icon, point, buffTrackerFrame, point, firstX, firstY)
            end
            last = icon
        end
    end
end

local function ResizeButtons()
    if InCombatLockdown() then
        buffTrackerFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    else
        local size = CellDB["tools"]["buffTracker"][3]
        for _, i in pairs(fakeIcons) do
            P.Size(i, size, size)
        end
        for _, b in pairs(buttons) do
            P.Size(b, size, size)
        end

        local n = F.Getn(buttons)
        if strfind(CellDB["tools"]["buffTracker"][2], "left") then
            buffTrackerFrame:SetSize(n * P.Scale(size) + (n - 1) * P.Scale(3), P.Scale(size + 18))
        else
            buffTrackerFrame:SetSize(P.Scale(size), n * P.Scale(size) + (n - 1) * P.Scale(3) + P.Scale(18))
        end
    end
end

---------------------------------------------------------------------
-- fade out
---------------------------------------------------------------------
local fadeOuts = {}
for _, b in pairs(buttons) do
    tinsert(fadeOuts, b)
end
A.ApplyFadeInOutToParent(buffTrackerFrame, function()
    return CellDB["tools"]["fadeOut"] and not buffTrackerFrame.moverText:IsShown()
end, unpack(fadeOuts))

---------------------------------------------------------------------
-- find aura
---------------------------------------------------------------------
local GetAuraDataBySpellName = C_UnitAuras.GetAuraDataBySpellName

local function UnitBuffExists(unit, buff)
    local name = buffs[buff]["buff1"]["name"]
    local aura

    aura = GetAuraDataBySpellName(unit, name, "HELPFUL")
    if aura then
        return true, aura.sourceUnit == "player"
    end

    if buffs[buff]["buff2"] then
        name = buffs[buff]["buff2"]["name"]
        aura = GetAuraDataBySpellName(unit, name, "HELPFUL")
        if aura then
            return true, aura.sourceUnit == "player"
        end
    end
end

---------------------------------------------------------------------
-- missing buffs
---------------------------------------------------------------------
local missingBuffsFromMe = {}
local hasBuffFromMe = {}

local function UpdateMissingBuffs(unit, buff)
    missingBuffsFromMe[unit] = missingBuffsFromMe[unit] or {}
    tinsert(missingBuffsFromMe[unit], buff)
end

local function ShowMissingBuffs(unit)
    I.HideMissingBuffs(unit)

    if not missingBuffsFromMe[unit] then return end

    local num = #missingBuffsFromMe[unit]
    if num == 0 then return end

    if myClass == "PALADIN" then
        if hasBuffFromMe[unit] then return end
    end

    if num == 1 or myClass == "PRIEST" then
        for _, buff in next, missingBuffsFromMe[unit] do
            I.ShowMissingBuff(unit, buffsProvidedByMe[buff][2])
        end
    else
        I.ShowMissingBuff(unit, 254882)
    end
end

---------------------------------------------------------------------
-- check
---------------------------------------------------------------------
local function CheckUnit(unit, updateBtn)
    -- print("CheckUnit", unit)
    if not hasBuffProvider then return end

    if missingBuffsFromMe[unit] then wipe(missingBuffsFromMe[unit]) end
    hasBuffFromMe[unit] = nil

    if UnitIsConnected(unit) and UnitIsVisible(unit) and not UnitIsDeadOrGhost(unit) then
        local required = requiredBuffs[UnitClassBase(unit)]
        for buff in pairs(available) do
            if required[buff] then
                local exists, providedByMe = UnitBuffExists(unit, buff)
                if exists then
                    unaffected[buff][unit] = nil
                    if providedByMe then
                        hasBuffFromMe[unit] = true
                    end
                else
                    unaffected[buff][unit] = true
                    if buffsProvidedByMe[buff] then
                        UpdateMissingBuffs(unit, buff)
                    end
                end
            end
        end
    else
        for k, t in pairs(unaffected) do
            t[unit] = nil
        end
    end

    ShowMissingBuffs(unit)

    if updateBtn then UpdateButtons() end
end

local function IterateAllUnits()
    Reset("available")
    myUnit = ""

    local class, level
    for unit in F.IterateGroupMembers() do
        if UnitIsConnected(unit) and UnitIsVisible(unit) then
            class = UnitClassBase(unit)
            level = UnitLevel(unit)
            if classBuffs[class] then
                for buff, lvl in pairs(classBuffs[class]) do
                    if not available[buff] and (type(lvl) ~= "number" or level >= lvl) then
                        available[buff] = true
                    end
                end
            end

            if UnitIsUnit("player", unit) then
                myUnit = unit
            end
        end
    end

    for buff, enabled in pairs(CellDB["tools"]["buffTracker"][5]) do
        if enabled then
            available[buff] = available[buff] and true
        else
            available[buff] = nil
        end
    end

    if next(available) then
        hasBuffProvider = true
    else
        hasBuffProvider = false
    end

    RepointButtons()

    Reset("unaffected")

    for unit in F.IterateGroupMembers() do
        CheckUnit(unit)
    end

    UpdateButtons()
end

---------------------------------------------------------------------
-- events
---------------------------------------------------------------------
function buffTrackerFrame:PLAYER_ENTERING_WORLD()
    buffTrackerFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    buffTrackerFrame:GROUP_ROSTER_UPDATE()
end

local timer
function buffTrackerFrame:GROUP_ROSTER_UPDATE(immediate)
    if timer then timer:Cancel() end
    if IsInGroup() then
        buffTrackerFrame:RegisterEvent("READY_CHECK")
        buffTrackerFrame:RegisterEvent("UNIT_FLAGS")
        buffTrackerFrame:RegisterEvent("PLAYER_UNGHOST")
        buffTrackerFrame:RegisterEvent("UNIT_AURA")
        -- buffTrackerFrame:RegisterEvent("PARTY_MEMBER_ENABLE")
        -- buffTrackerFrame:RegisterEvent("PARTY_MEMBER_DISABLE")
    else
        buffTrackerFrame:UnregisterEvent("READY_CHECK")
        buffTrackerFrame:UnregisterEvent("UNIT_FLAGS")
        buffTrackerFrame:UnregisterEvent("PLAYER_UNGHOST")
        buffTrackerFrame:UnregisterEvent("UNIT_AURA")
        -- buffTrackerFrame:UnregisterEvent("PARTY_MEMBER_ENABLE")
        -- buffTrackerFrame:UnregisterEvent("PARTY_MEMBER_DISABLE")

        Reset()
        RepointButtons()
        return
    end

    if immediate then
        IterateAllUnits()
    else
        timer = C_Timer.NewTimer(2, IterateAllUnits)
    end
end

function buffTrackerFrame:READY_CHECK()
    buffTrackerFrame:GROUP_ROSTER_UPDATE(true)
end

function buffTrackerFrame:UNIT_FLAGS()
    buffTrackerFrame:GROUP_ROSTER_UPDATE()
end

function buffTrackerFrame:PLAYER_UNGHOST()
    buffTrackerFrame:GROUP_ROSTER_UPDATE()
end

-- function buffTrackerFrame:PARTY_MEMBER_ENABLE()
--     buffTrackerFrame:GROUP_ROSTER_UPDATE()
-- end

-- function buffTrackerFrame:PARTY_MEMBER_DISABLE()
--     buffTrackerFrame:GROUP_ROSTER_UPDATE()
-- end

function buffTrackerFrame:UNIT_AURA(unit)
    if IsInRaid() then
        if unit:find("^raid%d+$") then
            CheckUnit(unit, true)
        end
    else
        if unit:find("^party%d$") or unit == "player" then
            CheckUnit(unit, true)
        end
    end
end

function buffTrackerFrame:PLAYER_REGEN_ENABLED()
    buffTrackerFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
    RepointButtons()
    ResizeButtons()
end

buffTrackerFrame:SetScript("OnEvent", function(self, event, ...)
    self[event](self, ...)
end)

---------------------------------------------------------------------
-- functions
---------------------------------------------------------------------
local function UpdateTools(which)
    if not which or which == "buffTracker" then
        if CellDB["tools"]["buffTracker"][1] then
            buffTrackerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
            buffTrackerFrame:RegisterEvent("GROUP_ROSTER_UPDATE")

            if which == "buffTracker" then -- already in world, manually enabled
                buffTrackerFrame:GROUP_ROSTER_UPDATE(true)
            end
            if Cell.vars.showMover then
                ShowMover(true)
            end
        else
            buffTrackerFrame:UnregisterAllEvents()

            Reset()
            myUnit = ""

            ShowMover(false)

            -- missingBuffs indicator
            for unit in F.IterateGroupMembers() do
                I.HideMissingBuffs(unit, true)
            end
        end

        RepointButtons()
        ResizeButtons()
    end

    if not which or which == "fadeOut" then
        if CellDB["tools"]["fadeOut"] and not buffTrackerFrame.moverText:IsShown() then
            buffTrackerFrame:SetAlpha(0)
        else
            buffTrackerFrame:SetAlpha(1)
        end
    end

    if not which then -- position
        P.LoadPosition(buffTrackerFrame, CellDB["tools"]["buffTracker"][4])
    end
end
Cell.RegisterCallback("UpdateTools", "BuffTracker_UpdateTools", UpdateTools)

local function UpdatePixelPerfect()
    -- P.Resize(buffTrackerFrame)

    for _, i in pairs(fakeIcons) do
        i:UpdatePixelPerfect()
    end

    for _, b in pairs(buttons) do
        b:UpdatePixelPerfect()
    end
end
Cell.RegisterCallback("UpdatePixelPerfect", "BuffTracker_UpdatePixelPerfect", UpdatePixelPerfect)