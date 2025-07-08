local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local I = Cell.iFuncs
local P = Cell.pixelPerfectFuncs
local LCG = LibStub("LibCustomGlow-1.0")
local LGI = LibStub:GetLibrary("LibGroupInfo")
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

local tinsert = table.insert

---------------------------------------------------------------------
-- data
---------------------------------------------------------------------
local buffs = {}
local requiredBuffs = {}
local requiredByEveryone = {}
local available = {}
local unaffected = {}

if Cell.isRetail then
    buffs = {
        stamina = {
            tag = ITEM_MOD_STAMINA_SHORT, -- Stamina
            icon = 135987,
            order = 1,
            provider = {
                PRIEST = {id = 21562, level = 6}, -- Power Word: Fortitude - 真言术：韧
            }
        },
        versatility = {
            tag = STAT_VERSATILITY, -- Versatility
            icon = 136078,
            order = 2,
            provider = {
                DRUID = {id = 1126, level = 9}, -- Mark of the Wild - 野性印记
            }
        },
        mastery = {
            tag = STAT_MASTERY, -- Mastery
            icon = 4630367,
            order = 3,
            provider = {
                SHAMAN = {id = 462854, level = 16}, -- Skyfury - 天怒
            }
        },
        intellect = {
            tag = ITEM_MOD_INTELLECT_SHORT, -- Intellect
            icon = 135932,
            order = 4,
            provider = {
                MAGE = {id = 1459, level = 8}, -- Arcane Brilliance - 奥术智慧
            }
        },
        attackPower = {
            tag = RAID_BUFF_3, -- Attack Power
            icon = 132333,
            order = 5,
            provider = {
                WARRIOR = {id = 6673, level = 10}, -- Battle Shout - 战斗怒吼
            }
        },
        movement = {
            tag = TUTORIAL_TITLE2, -- Movement
            icon = 4622448,
            order = 6,
            provider = {
                EVOKER = {id = 364342, level = 30}, -- Blessing of the Bronze - 青铜龙的祝福
            }
        }
    }

    requiredBuffs = {
        [250] = "attackPower", -- Blood
        [251] = "attackPower", -- Frost
        [252] = "attackPower", -- Unholy

        [577] = "attackPower", -- Havoc
        [581] = "attackPower", -- Vengeance

        [102] = "intellect", -- Balance
        [103] = "attackPower", -- Feral
        [104] = "attackPower", -- Guardian
        [105] = "intellect", -- Restoration

        [1467] = "intellect", -- Devastation
        [1468] = "intellect", -- Preservation

        [253] = "attackPower", -- Beast Mastery
        [254] = "attackPower", -- Marksmanship
        [255] = "attackPower", -- Survival

        [62] = "intellect", -- Arcane
        [63] = "intellect", -- Fire
        [64] = "intellect", -- Frost

        [268] = "attackPower", -- Brewmaster
        [269] = "attackPower", -- Windwalker
        [270] = "intellect", -- Mistweaver

        [65] = "intellect", -- Holy
        [66] = "attackPower", -- Protection
        [70] = "attackPower", -- Retribution

        [256] = "intellect", -- Discipline
        [257] = "intellect", -- Holy
        [258] = "intellect", -- Shadow

        [259] = "attackPower", -- Assassination
        [260] = "attackPower", -- Outlaw
        [261] = "attackPower", -- Subtlety

        [262] = "intellect", -- Elemental
        [263] = "attackPower", -- Enhancement
        [264] = "intellect", -- Restoration

        [265] = "intellect", -- Affliction
        [266] = "intellect", -- Demonology
        [267] = "intellect", -- Destruction

        [71] = "attackPower", -- Arms
        [72] = "attackPower", -- Fury
        [73] = "attackPower", -- Protection
    }

    requiredByEveryone = {
        stamina = true,
        versatility = true,
        mastery = true,
        movement = true,
    }

    available = {
        stamina = false,
        versatility = false,
        mastery = false,
        intellect = false,
        attackPower = false,
        movement = false,
    }

    unaffected = {
        stamina = {},
        versatility = {},
        mastery = {},
        intellect = {},
        attackPower = {},
        movement = {},
    }

elseif Cell.isMists then
    buffs = {
        stamina = {
            tag = RAID_BUFF_2, -- Stamina
            icon = 135987,
            order = 1,
            provider = {
                PRIEST = {id = 21562, level = 22}, -- Power Word: Fortitude
                WARLOCK = {id = 109773, level = 82}, -- Dark Intent
                WARRIOR = {id = 469, level = 68}, -- Commanding Shout
            },
        },
        stats = {
            tag = RAID_BUFF_1, -- Stats
            icon = 136078,
            order = 2,
            provider = {
                DRUID = {id = 1126, level = 62}, -- Mark of the Wild
                MONK = {id = 115921, level = 22}, -- Legacy of the Emperor
                PALADIN = {id = 20217, level = 30}, -- Blessing of Kings
            }
        },
        spellPower = {
            tag = RAID_BUFF_5, -- Spell Power
            icon = 135932,
            order = 3,
            provider = {
                MAGE = {id = {1459, 61316}, level = 58}, -- Arcane Brilliance / Dalaran Brilliance
                SHAMAN = {id = 77747, level = 40}, -- Burning Wrath
                WARLOCK = {id = 109773, level = 82}, -- Dark Intent
            }
        },
        attackPower = {
            tag = RAID_BUFF_3, -- Attack Power
            icon = 132333,
            order = 4,
            provider = {
                DEATHKNIGHT = {id = 57330, level = 65}, -- Horn of Winter
                HUNTER = {id = 19506, level = 39}, -- Trueshot Aura
                WARRIOR = {id = 6673, level = 42}, -- Battle Shout
            }
        },
        mastery = {
            tag = RAID_BUFF_7, -- Mastery
            icon = 135908,
            order = 5,
            provider = {
                PALADIN = {id = 19740, level = 81}, -- Blessing of Might
                SHAMAN = {id = 116956, level = 80}, -- Grace of Air
            }
        }
    }

    requiredBuffs = {
        [250] = "attackPower", -- Blood
        [251] = "attackPower", -- Frost
        [252] = "attackPower", -- Unholy

        [102] = "spellPower", -- Balance
        [103] = "attackPower", -- Feral
        [104] = "attackPower", -- Guardian
        [105] = "spellPower", -- Restoration

        [253] = "attackPower", -- Beast Mastery
        [254] = "attackPower", -- Marksmanship
        [255] = "attackPower", -- Survival

        [62] = "spellPower", -- Arcane
        [63] = "spellPower", -- Fire
        [64] = "spellPower", -- Frost

        [268] = "attackPower", -- Brewmaster
        [269] = "attackPower", -- Windwalker
        [270] = "spellPower", -- Mistweaver

        [65] = "spellPower", -- Holy
        [66] = "attackPower", -- Protection
        [70] = "attackPower", -- Retribution

        [256] = "spellPower", -- Discipline
        [257] = "spellPower", -- Holy
        [258] = "spellPower", -- Shadow

        [259] = "attackPower", -- Assassination
        [260] = "attackPower", -- Outlaw
        [261] = "attackPower", -- Subtlety

        [262] = "spellPower", -- Elemental
        [263] = "attackPower", -- Enhancement
        [264] = "spellPower", -- Restoration

        [265] = "spellPower", -- Affliction
        [266] = "spellPower", -- Demonology
        [267] = "spellPower", -- Destruction

        [71] = "attackPower", -- Arms
        [72] = "attackPower", -- Fury
        [73] = "attackPower", -- Protection
    }

    requiredByEveryone = {
        stamina = true,
        stats = true,
        mastery = true,
    }

    available = {
        stamina = false,
        stats = false,
        spellPower = false,
        attackPower = false,
        mastery = false,
    }

    unaffected = {
        stamina = {},
        stats = {},
        spellPower = {},
        attackPower = {},
        mastery = {},
    }
end

---------------------------------------------------------------------
-- prepare
---------------------------------------------------------------------
local classBuffs = {
    -- class = {
    --     buff = level,
    -- }
}
local buffOrder = {}
local buffsProvidedByMe = {}

do
    local myClass = UnitClassBase("player")
    local myLevel = UnitLevel("player")

    local function Insert(class, buffKey, name, icon)
        tinsert(buffs[buffKey]["names"], name)
        if myClass == class and myLevel >= classBuffs[class][buffKey] then
            buffsProvidedByMe[buffKey] = {name, icon}
        end
    end

    for buffKey, buffData in pairs(buffs) do
        tinsert(buffOrder, buffKey)
        buffData.names = {}

        for class, info in pairs(buffData.provider) do
            classBuffs[class] = classBuffs[class] or {}
            classBuffs[class][buffKey] = info.level

            if type(info.id) == "table" then
                for _, spellId in ipairs(info.id) do
                    local name, icon = F.GetSpellInfo(spellId)
                    if name then
                        Insert(class, buffKey, name, icon)
                    end
                end
            else
                local name, icon = F.GetSpellInfo(info.id)
                if name then
                    Insert(class, buffKey, name, icon)
                end
            end
        end
    end

    table.sort(buffOrder, function(a, b)
        return buffs[a]["order"] < buffs[b]["order"]
    end)
end

-------------------------------------------------
-- vars
-------------------------------------------------
local enabled
local myUnit = ""
local hasBuffProvider

local fl function Reset(which)
    if not which or which == "available" then
        for k, v in pairs(available) do
            available[k] = false
        end
        hasBuffProvider = false
    end

    if not which or which == "unaffected" then
        for k, v in pairs(unaffected) do
            wipe(unaffected[k])
        end
    end
end

local function GetUnaffectedString(buff)
    local list = unaffected[buff]
    local name = buffs[buff]["tag"]

    local players = {}
    for unit in pairs(list) do
        local name = UnitName(unit)
        tinsert(players, name)
    end

    if #players == 0 then
        return
    elseif #players <= 10 then
        return L["Missing Buff"] .. " (" .. name .. "): " .. table.concat(players, ", ")
    else
        return L["Missing Buff"] .. " (" .. name .. "): " .. L["many"]
    end
end

-------------------------------------------------
-- frame
-------------------------------------------------
local buffTrackerFrame = CreateFrame("Frame", "CellBuffTrackerFrame", Cell.frames.mainFrame, "BackdropTemplate")
Cell.frames.buffTrackerFrame = buffTrackerFrame
P.Size(buffTrackerFrame, 102, 50)
PixelUtil.SetPoint(buffTrackerFrame, "BOTTOMLEFT", CellParent, "CENTER", 1, 1)
buffTrackerFrame:SetClampedToScreen(true)
-- buffTrackerFrame:SetClampRectInsets(0, 0, -20, 0)
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

-------------------------------------------------
-- mover
-------------------------------------------------
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
        tinsert(fakeIcons, CreateFakeIcon(buffs[k]["icon"]))
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

-------------------------------------------------
-- buttons
-------------------------------------------------
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

local function CreateBuffButton(parent, buff)
    local b = CreateFrame("Button", nil, parent, "SecureActionButtonTemplate,BackdropTemplate")
    if parent then b:SetFrameLevel(parent:GetFrameLevel() + 1) end
    P.Size(b, 32, 32)

    b:SetBackdrop({edgeFile = Cell.vars.whiteTexture, edgeSize = P.Scale(1)})
    b:SetBackdropBorderColor(0, 0, 0, 1)

    b:RegisterForClicks("LeftButtonUp", "RightButtonUp", "LeftButtonDown", "RightButtonDown") -- NOTE: ActionButtonUseKeyDown will affect this

    -- cast
    if buffsProvidedByMe[buff] then
        b:SetAttribute("type1", "macro")
        b:SetAttribute("macrotext1", "/cast [@player] " .. buffsProvidedByMe[buff][1])
    end

    -- chat
    b:HookScript("OnClick", function(self, button, down)
        if button == "RightButton" and (down == GetCVarBool("ActionButtonUseKeyDown")) then
            local msg = GetUnaffectedString(buff)
            if msg then
                UpdateSendChannel()
                SendChatMessage(msg, sendChannel)
            end
        end
    end)

    b.texture = b:CreateTexture(nil, "OVERLAY")
    P.Point(b.texture, "TOPLEFT", b, "TOPLEFT", 1, -1)
    P.Point(b.texture, "BOTTOMRIGHT", b, "BOTTOMRIGHT", -1, 1)
    b.texture:SetTexture(buffs[buff]["icon"])
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
                CellTooltip:AddLine(L["Unaffected"] .. " |cffb7b7b7" .. buffs[buff]["tag"])
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
        if glowType == "Normal" then
            LCG.PixelGlow_Stop(b)
            LCG.AutoCastGlow_Stop(b)
            LCG.ButtonGlow_Start(b, ...)
        elseif glowType == "Pixel" then
            LCG.ButtonGlow_Stop(b)
            LCG.AutoCastGlow_Stop(b)
            -- color, N, frequency, length, thickness
            LCG.PixelGlow_Start(b, ...)
        elseif glowType == "Shine" then
            LCG.ButtonGlow_Stop(b)
            LCG.PixelGlow_Stop(b)
            LCG.AutoCastGlow_Stop(b)
            -- color, N, frequency, scale
            LCG.AutoCastGlow_Start(b, ...)
        end
    end

    function b:StopGlow()
        LCG.ButtonGlow_Stop(b)
        LCG.PixelGlow_Stop(b)
        LCG.AutoCastGlow_Stop(b)
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
    for _, buff in ipairs(buffOrder) do
        buttons[buff] = CreateBuffButton(buffTrackerFrame, buff)
        buttons[buff]:Hide()
        buttons[buff]:SetTooltips(unaffected[buff])
    end
end

local function UpdateButtons()
    for _, buff in pairs(buffOrder) do
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

-------------------------------------------------
-- fade out
-------------------------------------------------
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
    local names = buffs[buff]["names"]
    local aura
    for _, name in next, names do
        aura = GetAuraDataBySpellName(unit, name, "HELPFUL")
        if aura then
            return true, aura.sourceUnit == "player"
        end
    end
end

---------------------------------------------------------------------
-- missing buffs
---------------------------------------------------------------------
-- local numBuffsProvidedByMe = F.Getn(buffsProvidedByMe)

-- local function CheckSimple(unit)
--     for buff, t in buffsProvidedByMe do
--         local aura = GetAuraDataBySpellName(unit, t[1], "HELPFUL")
--         if not aura then
--             I.ShowMissingBuff(unit, t[2])
--         end
--     end
-- end

-- local function CheckComplex(unit)
--     local allBuffed = true
--     local myBuff = false

--     for buff, t in buffsProvidedByMe do
--         local aura = GetAuraDataBySpellName(unit, t[1], "HELPFUL")
--         if aura then
--             if aura.sourceUnit == "player" then
--                 myBuff = true
--             end
--         else
--             allBuffed = false
--         end
--     end

--     if not allBuffed and not myBuff then
--         I.ShowMissingBuff(unit, 254882)
--     end
-- end

-- local function UpdateMissingBuffs(unit)
--     if not numBuffsProvidedByMe == 0 then return end
--     I.HideMissingBuffs(unit)

--     if numBuffsProvidedByMe == 1 or Cell.vars.playerClass == "PRIEST" then
--         CheckSimple(unit)
--     else
--         CheckComplex(unit)
--     end
-- end

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

    if Cell.vars.playerClass == "PALADIN" or Cell.vars.playerClass == "WARRIOR" then
        if hasBuffFromMe[unit] then return end
    end

    if num == 1 or Cell.vars.playerClass == "PRIEST" then
        for _, buff in next, missingBuffsFromMe[unit] do
            I.ShowMissingBuff(unit, buffsProvidedByMe[buff][2])
        end
    else
        I.ShowMissingBuff(unit, 254882)
    end
end

-------------------------------------------------
-- check
-------------------------------------------------
local function CheckUnit(unit, updateBtn)
    -- print("CheckUnit", unit)
    if not hasBuffProvider then return end

    if missingBuffsFromMe[unit] then wipe(missingBuffsFromMe[unit]) end
    hasBuffFromMe[unit] = nil

    if UnitIsConnected(unit) and UnitIsVisible(unit) and not UnitIsDeadOrGhost(unit) then
        local info = LGI:GetCachedInfo(UnitGUID(unit))
        local spec = info and info.specId
        local required = spec and requiredBuffs[spec]

        for buff, hasProvider in next, available do
            if hasProvider then
                if required == buff or requiredByEveryone[buff] then
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
            else
                unaffected[buff][unit] = nil
            end
        end
    else
        for k, t in next, unaffected do
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
                    if not available[buff] and level >= lvl then
                        available[buff] = true
                        hasBuffProvider = true
                    end
                end
            end

            if UnitIsUnit("player", unit) then
                myUnit = unit
            end
        end
    end

    RepointButtons()
    Reset("unaffected")

    for unit in F.IterateGroupMembers() do
        CheckUnit(unit)
    end

    UpdateButtons()
end

-------------------------------------------------
-- events
-------------------------------------------------
function buffTrackerFrame:UnitUpdated(event, guid, unit, info)
    -- print(event, guid, unit, info.specId)
    if unit == "player" then
        if UnitIsUnit("player", myUnit) then CheckUnit(myUnit, true) end
    elseif UnitIsPlayer(unit) then -- ignore pets
        CheckUnit(unit, true)
    end
end

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
    else
        buffTrackerFrame:UnregisterEvent("READY_CHECK")
        buffTrackerFrame:UnregisterEvent("UNIT_FLAGS")
        buffTrackerFrame:UnregisterEvent("PLAYER_UNGHOST")
        buffTrackerFrame:UnregisterEvent("UNIT_AURA")

        Reset()
        RepointButtons()
        return
    end

    if immediate then
        IterateAllUnits()
    else
        timer = C_Timer.NewTimer(3, IterateAllUnits)
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

-------------------------------------------------
-- functions
-------------------------------------------------
local function UpdateTools(which)
    if not which or which == "buffTracker" then
        if CellDB["tools"]["buffTracker"][1] then
            buffTrackerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
            buffTrackerFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
            LGI.RegisterCallback(buffTrackerFrame, "GroupInfo_Update", "UnitUpdated")

            if not enabled and which == "buffTracker" then -- already in world, manually enabled
                buffTrackerFrame:GROUP_ROSTER_UPDATE(true)
            end
            enabled = true
            if Cell.vars.showMover then
                ShowMover(true)
            end
        else
            buffTrackerFrame:UnregisterAllEvents()
            LGI.UnregisterCallback(buffTrackerFrame, "GroupInfo_Update")

            Reset()
            myUnit = ""

            enabled = false
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