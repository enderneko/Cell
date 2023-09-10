local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local I = Cell.iFuncs
local P = Cell.pixelPerfectFuncs
local LCG = LibStub("LibCustomGlow-1.0")
-- local LGI = LibStub:GetLibrary("LibGroupInfo")
local A = Cell.animations

local UnitIsConnected = UnitIsConnected
local UnitIsVisible = UnitIsVisible
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsUnit = UnitIsUnit
local UnitIsPlayer = UnitIsPlayer
local UnitGUID = UnitGUID
local UnitClassBase = UnitClassBase
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid

-------------------------------------------------
-- buffs
-------------------------------------------------
local buffs = {
    -- 1243: Power Word: Fortitude
    -- 21562: Prayer of Fortitude
    ["PWF"] = {1243, 21562, glowColor={F:GetClassColor("PRIEST")}, provider="PRIEST"},

    -- 14752: Divine Spirit
    -- 27681: Prayer of Spirit
    ["DS"] = {14752, 27681, glowColor={F:GetClassColor("PRIEST")}, provider="PRIEST"},

    -- 976: Shadow Protection
    -- 27683: Prayer of Shadow Protection
    ["SP"] = {976, 27683, glowColor={F:GetClassColor("PRIEST")}, provider="PRIEST"},

    -- 1459: Arcane Intellect
    -- 23028: Arcane Brilliance
    ["AB"] = {1459, 23028, glowColor={F:GetClassColor("MAGE")}, provider="MAGE"},

    -- 6673: Battle Shout
    ["BS"] = {6673, glowColor={F:GetClassColor("WARRIOR")}, provider="WARRIOR"},

    -- 469: Commanding Shout
    ["CS"] = {469, glowColor={F:GetClassColor("WARRIOR")}, provider="WARRIOR"},

    -- 1126: Mark of the Wild
    -- 21849: Gift of the Wild
    ["MotW"] = {1126, 21849, glowColor={F:GetClassColor("DRUID")}, provider="DRUID"},

    -- 20217: Blessing of Kings
    -- 25898: Greater Blessing of Kings
    ["BoK"] = {20217, 25898, glowColor={F:GetClassColor("PALADIN")}, provider="PALADIN"},

    -- 19740: Blessing of Might
    -- 25782: Greater Blessing of Might
    ["BoM"] = {19740, 25782, glowColor={F:GetClassColor("PALADIN")}, provider="PALADIN"},

    -- 19742: Blessing of Wisdom
    -- 25894: Greater Blessing of Wisdom
    ["BoW"] = {19742, 25894, glowColor={F:GetClassColor("PALADIN")}, provider="PALADIN"},

    -- 20911: Blessing of Sanctuary
    -- 25899: Greater Blessing of Sanctuary
    ["BoS"] = {20911, 25899, glowColor={F:GetClassColor("PALADIN")}, provider="PALADIN"},
}

do
    for _, t in pairs(buffs) do
        for i, id in ipairs(t) do
            local name, _, icon = GetSpellInfo(id)
            t[i] = {
                -- ["id"] = id,
                ["name"] = name,
                ["icon"] = icon,
            }
        end
    end
end

local order = {"PWF", "AB", "DS", "MotW", "BoK", "BoM", "BoW", "BoS", "BS", "CS", "SP"}

-------------------------------------------------
-- required buffs
-------------------------------------------------
local requiredBuffs = {
    ["WARRIOR"] = {["PWF"]=true, ["MotW"]=true, ["BoK"]=true, ["BoM"]=true, ["BoS"]=true, ["BS"]=true, ["CS"]=true, ["SP"]=true},
    ["PALADIN"] = {["PWF"]=true, ["AB"]=true, ["DS"]=true, ["MotW"]=true, ["BoK"]=true, ["BoM"]=true, ["BoW"]=true, ["BoS"]=true, ["BS"]=true, ["CS"]=true, ["SP"]=true},
    ["HUNTER"] = {["PWF"]=true, ["MotW"]=true, ["BoK"]=true, ["BoM"]=true, ["BoS"]=true, ["BS"]=true, ["CS"]=true, ["SP"]=true},
    ["ROGUE"] = {["PWF"]=true, ["MotW"]=true, ["BoK"]=true, ["BoM"]=true, ["BoS"]=true, ["BS"]=true, ["CS"]=true, ["SP"]=true},
    ["PRIEST"] = {["PWF"]=true, ["AB"]=true, ["DS"]=true, ["MotW"]=true, ["BoK"]=true, ["BoW"]=true, ["BoS"]=true, ["CS"]=true, ["SP"]=true},
    ["DEATHKNIGHT"] = {["PWF"]=true, ["MotW"]=true, ["BoK"]=true, ["BoM"]=true, ["BoS"]=true, ["BS"]=true, ["CS"]=true, ["SP"]=true},
    ["SHAMAN"] = {["PWF"]=true, ["AB"]=true, ["DS"]=true, ["MotW"]=true, ["BoK"]=true, ["BoM"]=true, ["BoW"]=true, ["BoS"]=true, ["BS"]=true, ["CS"]=true, ["SP"]=true},
    ["MAGE"] = {["PWF"]=true, ["AB"]=true, ["MotW"]=true, ["BoK"]=true, ["BoW"]=true, ["BoS"]=true, ["CS"]=true, ["SP"]=true},
    ["WARLOCK"] = {["PWF"]=true, ["AB"]=true, ["MotW"]=true, ["BoK"]=true, ["BoW"]=true, ["BoS"]=true, ["CS"]=true, ["SP"]=true},
    ["DRUID"] = {["PWF"]=true, ["AB"]=true, ["DS"]=true, ["MotW"]=true, ["BoK"]=true, ["BoM"]=true, ["BoW"]=true, ["BoS"]=true, ["BS"]=true, ["CS"]=true, ["SP"]=true},
}

-------------------------------------------------
-- vars
-------------------------------------------------
local enabled
local myUnit = ""
local hasBuffProvider

local available = {
    ["PWF"] = false,
    ["AB"] = false,
    ["DS"] = false,
    ["MotW"] = false,
    ["BoK"] = false,
    ["BoM"] = false,
    ["BoW"] = false,
    ["BoS"] = false,
    ["BS"] = false,
    ["CS"] = false,
    ["SP"] = false,
}

local unaffected = {
    ["PWF"] = {},
    ["AB"] = {},
    ["DS"] = {},
    ["MotW"] = {},
    ["BoK"] = {},
    ["BoM"] = {},
    ["BoW"] = {},
    ["BoS"] = {},
    ["BS"] = {},
    ["CS"] = {},
    ["SP"] = {},
}

local function Reset(which)
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

function F:GetUnaffectedString(spell)
    local list = unaffected[spell]
    local buff = buffs[spell][1]["name"]

    local players = {}
    for unit in pairs(list) do
        local name = UnitName(unit)
        tinsert(players, name)
    end

    if #players == 0 then
        return
    elseif #players <= 10 then
        return L["Missing Buff"].." ("..buff.."): "..table.concat(players, ", ")
    else
        return L["Missing Buff"].." ("..buff.."): "..L["many"]
    end
end

-------------------------------------------------
-- frame
-------------------------------------------------
local buffTrackerFrame = CreateFrame("Frame", "CellBuffTrackerFrame", Cell.frames.mainFrame, "BackdropTemplate")
Cell.frames.buffTrackerFrame = buffTrackerFrame
P:Size(buffTrackerFrame, 102, 50)
buffTrackerFrame:SetPoint("BOTTOMLEFT", UIParent, "CENTER")
buffTrackerFrame:SetClampedToScreen(true)
buffTrackerFrame:SetMovable(true)
buffTrackerFrame:RegisterForDrag("LeftButton")
buffTrackerFrame:SetScript("OnDragStart", function()
    buffTrackerFrame:StartMoving()
    buffTrackerFrame:SetUserPlaced(false)
end)
buffTrackerFrame:SetScript("OnDragStop", function()
    buffTrackerFrame:StopMovingOrSizing()
    P:SavePosition(buffTrackerFrame, CellDB["tools"]["buffTracker"][2])
end)

-------------------------------------------------
-- mover
-------------------------------------------------
buffTrackerFrame.moverText = buffTrackerFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
buffTrackerFrame.moverText:SetPoint("TOP", 0, -3)
buffTrackerFrame.moverText:SetText(L["Mover"])
buffTrackerFrame.moverText:Hide()

local fakeIconsFrame = CreateFrame("Frame", nil, buffTrackerFrame)
P:Point(fakeIconsFrame, "BOTTOMLEFT", buffTrackerFrame)
P:Point(fakeIconsFrame, "TOPRIGHT", buffTrackerFrame, "BOTTOMRIGHT", 0, 32)
fakeIconsFrame:EnableMouse(true)
fakeIconsFrame:SetFrameLevel(buffTrackerFrame:GetFrameLevel()+10)
fakeIconsFrame:Hide()

local fakeIcons = {}
local function CreateFakeIcon(spellIcon)
    local bg = fakeIconsFrame:CreateTexture(nil, "BORDER")
    bg:SetColorTexture(0, 0, 0, 1)
    P:Size(bg, 32, 32)
    
    local icon = fakeIconsFrame:CreateTexture(nil, "ARTWORK")
    icon:SetTexture(spellIcon)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    P:Point(icon, "TOPLEFT", bg, "TOPLEFT", 1, -1)
    P:Point(icon, "BOTTOMRIGHT", bg, "BOTTOMRIGHT", -1, 1)

    function bg:UpdatePixelPerfect()
        P:Resize(bg)
        P:Repoint(bg)
        P:Repoint(icon)
    end

    return bg
end

do
    for _, k in ipairs(order) do
        tinsert(fakeIcons, CreateFakeIcon(buffs[k][1]["icon"]))
        local i = #fakeIcons
        
        if i == 1 then
            P:Point(fakeIcons[i], "BOTTOMLEFT")
        else
            P:Point(fakeIcons[i], "BOTTOMLEFT", fakeIcons[i-1], "BOTTOMRIGHT", 3, 0)
        end
    end
end

local function ShowMover(show)
    if show then
        if not CellDB["tools"]["buffTracker"][1] then return end
        buffTrackerFrame:EnableMouse(true)
        buffTrackerFrame.moverText:Show()
        Cell:StylizeFrame(buffTrackerFrame, {0, 1, 0, 0.4}, {0, 0, 0, 0})
        fakeIconsFrame:Show()
        buffTrackerFrame:SetAlpha(1)
    else
        buffTrackerFrame:EnableMouse(false)
        buffTrackerFrame.moverText:Hide()
        Cell:StylizeFrame(buffTrackerFrame, {0, 0, 0, 0}, {0, 0, 0, 0})
        fakeIconsFrame:Hide()
        buffTrackerFrame:SetAlpha(CellDB["tools"]["fadeOut"] and 0 or 1)
    end
end
Cell:RegisterCallback("ShowMover", "BuffTracker_ShowMover", ShowMover)

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

local function CreateBuffButton(parent, size, spell1, spell2, icon, index)
    local b = CreateFrame("Button", nil, parent, "SecureActionButtonTemplate,BackdropTemplate")
    if parent then b:SetFrameLevel(parent:GetFrameLevel()+1) end
    P:Size(b, size[1], size[2])
    
    b:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = P:Scale(1)})
    b:SetBackdropBorderColor(0, 0, 0, 1)

    b:RegisterForClicks("LeftButtonUp", "RightButtonUp", "LeftButtonDown", "RightButtonDown") -- NOTE: ActionButtonUseKeyDown will affect this
    b:SetAttribute("type1", "spell")
    b:SetAttribute("spell", spell2 or spell1)
    b:SetAttribute("shift-type1", "spell")
    b:SetAttribute("shift-spell1", spell1)
    b:HookScript("OnClick", function(self, button, down)
        if button == "RightButton" and (down == GetCVarBool("ActionButtonUseKeyDown")) then
            local msg = F:GetUnaffectedString(index)
            if msg then
                UpdateSendChannel()
                SendChatMessage(msg, sendChannel)
            end
        end
    end)

    b.texture = b:CreateTexture(nil, "OVERLAY")
    P:Point(b.texture, "TOPLEFT", b, "TOPLEFT", 1, -1)
    P:Point(b.texture, "BOTTOMRIGHT", b, "BOTTOMRIGHT", -1, 1)
    b.texture:SetTexture(icon)
    b.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    b.count = b:CreateFontString(nil, "OVERLAY")
    P:Point(b.count, "TOPLEFT", b.texture, "TOPLEFT", 2, -2)
    b.count:SetFont(GameFontNormal:GetFont(), 14, "OUTLINE")
    b.count:SetShadowColor(0, 0, 0)
    b.count:SetShadowOffset(0, 0)
    b.count:SetTextColor(1, 0, 0)

    b:SetScript("OnLeave", function()
        CellTooltip:Hide()
    end)

    function b:SetTooltips(list)
        b:SetScript("OnEnter", function()
            if F:Getn(list) ~= 0 then
                CellTooltip:SetOwner(b, "ANCHOR_TOPLEFT", 0, 3)
                CellTooltip:AddLine(L["Unaffected"])
                for unit in pairs(list) do
                    local class = UnitClassBase(unit)
                    local name = UnitName(unit)
                    if class and name then
                        CellTooltip:AddLine(F:GetClassColorStr(class)..name.."|r")
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
        P:Resize(b)
        P:Repoint(b)
        b:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = P:Scale(1)})
        b:SetBackdropBorderColor(0, 0, 0, 1)

        P:Repoint(b.texture)
        P:Repoint(b.count)
    end

    return b
end

local buttons = {}

do
    for _, k in ipairs(order) do
        buttons[k] = CreateBuffButton(buffTrackerFrame, {32, 32}, buffs[k][1]["name"], buffs[k][2] and buffs[k][2]["name"], buffs[k][1]["icon"], k)
        buttons[k]:Hide()
        buttons[k]:SetTooltips(unaffected[k])
    end
end

local paladinBuffs = {"BoK", "BoM", "BoW", "BoS"}
local warriorBuffs = {"BS", "CS"}
local function UpdateButtons()
    -- NOTE: check paladin buffs
    local paladinBuffsFound = 0
    for _, k in pairs(paladinBuffs) do
        if AuraUtil.FindAuraByName(buffs[k][1]["name"], "player", "BUFF") or (buffs[k][2] and AuraUtil.FindAuraByName(buffs[k][2]["name"], "player", "BUFF")) then
            paladinBuffsFound = paladinBuffsFound + 1
        end
    end
    
    -- NOTE: check warrior buffs
    local warriorBuffsFound = 0
    for _, k in pairs(warriorBuffs) do
        if AuraUtil.FindAuraByName(buffs[k][1]["name"], "player", "BUFF") then
            warriorBuffsFound = warriorBuffsFound + 1
        end
    end

    for _, k in ipairs(order) do
        if available[k] then
            local n = F:Getn(unaffected[k])
            if n == 0 then
                buttons[k].count:SetText("")
                buttons[k]:SetAlpha(0.5)
                buttons[k]:StopGlow()
            else
                buttons[k].count:SetText(n)
                buttons[k]:SetAlpha(1)
                if unaffected[k][myUnit] then
                    local showGlow
                    if strfind(k, "^Bo") then
                        showGlow = paladinBuffsFound < available[k]
                    elseif k == "BS" or k == "CS" then
                        showGlow = warriorBuffsFound < available[k]
                    else
                        showGlow = true
                    end

                    if showGlow then
                        -- color, N, frequency, length, thickness
                        buttons[k]:StartGlow("Pixel", buffs[k]["glowColor"], 8, 0.25, P:Scale(8), P:Scale(2))
                    else
                        buttons[k]:StopGlow()
                    end
                else
                    buttons[k]:StopGlow()
                end
            end
        end
    end
end

local function AnchorButtons()
    if InCombatLockdown() then
        buffTrackerFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    else
        local last
        for _, k in pairs(order) do
            buttons[k]:ClearAllPoints()
            if available[k] then
                buttons[k]:Show()
                if last then
                    buttons[k]:SetPoint("BOTTOMLEFT", last, "BOTTOMRIGHT", 3, 0)
                else
                    buttons[k]:SetPoint("BOTTOMLEFT")
                end
                last = buttons[k]
            else
                buttons[k]:Hide()
                buttons[k]:Reset()
            end
        end
    end
end

local function ResizeButtons()
    if InCombatLockdown() then
        buffTrackerFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    else
        local size = CellDB["tools"]["buffTracker"][3]
        for _, i in pairs(fakeIcons) do
            P:Size(i, size, size)
        end
        for _, b in pairs(buttons) do
            P:Size(b, size, size)
        end

        local n = F:Getn(buttons)
        P:Size(buffTrackerFrame, n * size + (n - 1) * 3, size + 18)
    end
end

-------------------------------------------------
-- fade out
-------------------------------------------------
local fadeOuts = {}
for _, b in pairs(buttons) do
    tinsert(fadeOuts, b)
end
A:ApplyFadeInOutToParent(buffTrackerFrame, function()
    return CellDB["tools"]["fadeOut"] and not buffTrackerFrame.moverText:IsShown()
end, unpack(fadeOuts))

-------------------------------------------------
-- check
-------------------------------------------------
local function HasMyBuff(unit, _buffs)
    for _, b in pairs(_buffs) do
        local source = select(7, AuraUtil.FindAuraByName(buffs[b][1]["name"], unit, "BUFF,PLAYER"))
        if source == "player" then
            return true
        end

        if buffs[b][2] then
            source = select(7, AuraUtil.FindAuraByName(buffs[b][2]["name"], unit, "BUFF,PLAYER"))
            if source == "player" then
                return true
            end
        end
    end
end

local function CheckUnit(unit, updateBtn)
    I:HideMissingBuffs(unit)

    -- print("CheckUnit", unit)
    if not hasBuffProvider then return end

    if UnitIsConnected(unit) and UnitIsVisible(unit) and not UnitIsDeadOrGhost(unit) then
        local required = requiredBuffs[UnitClassBase(unit)]
        for k, v in pairs(available) do
            if v ~= false and required[k] then
                if not (AuraUtil.FindAuraByName(buffs[k][1]["name"], unit, "BUFF") or (buffs[k][2] and AuraUtil.FindAuraByName(buffs[k][2]["name"], unit, "BUFF"))) then
                    unaffected[k][unit] = true
                    
                    -- NOTE: don't check paladin/warrior shit here
                    if not strfind(k, "^Bo") and k ~= "BS" and k ~= "CS" then
                        I:ShowMissingBuff(unit, k, buffs[k][1]["icon"], Cell.vars.playerClass == buffs[k]["provider"])
                    end
                else
                    unaffected[k][unit] = nil
                end
            end
        end

        -- NOTE: check shits
        if Cell.vars.playerClass == "PALADIN" then
            if not HasMyBuff(unit, paladinBuffs) then
                I:ShowMissingBuff(unit, "PALADIN", 254882, true)
            end
        elseif Cell.vars.playerClass == "WARRIOR" then
            if not HasMyBuff(unit, warriorBuffs) then
                I:ShowMissingBuff(unit, "WARRIOR", 254882, true)
            end
        end
        
    else
        for k, t in pairs(unaffected) do
            t[unit] = nil
        end
    end

    if updateBtn then UpdateButtons() end
end

local function IterateAllUnits()
    Reset("available")
    myUnit = ""

    for unit in F:IterateGroupMembers() do
        if UnitIsConnected(unit) and UnitIsVisible(unit) then
            if UnitClassBase(unit) == "PRIEST" then
                available["PWF"] = true
                available["DS"] = true
                available["SP"] = true
                hasBuffProvider = true
            
            elseif UnitClassBase(unit) == "MAGE" then
                available["AB"] = true
                hasBuffProvider = true
            
            elseif UnitClassBase(unit) == "WARRIOR" then
                available["BS"] = (available["BS"] or 0) + 1
                available["CS"] = (available["CS"] or 0) + 1
                hasBuffProvider = true

            elseif UnitClassBase(unit) == "PALADIN" then
                available["BoK"] = (available["BoK"] or 0) + 1
                available["BoM"] = (available["BoM"] or 0) + 1
                available["BoW"] = (available["BoW"] or 0) + 1
                available["BoS"] = (available["BoS"] or 0) + 1
                hasBuffProvider = true

            elseif UnitClassBase(unit) == "DRUID" then
                available["MotW"] = true
                hasBuffProvider = true
            end

            if UnitIsUnit("player", unit) then
                myUnit = unit
            end
        end
    end

    AnchorButtons()
    
    Reset("unaffected")
    
    for unit in F:IterateGroupMembers() do
        CheckUnit(unit)
    end

    UpdateButtons()
end

-------------------------------------------------
-- events
-------------------------------------------------
-- function buffTrackerFrame:UnitUpdated(event, guid, unit, info)
--     if unit == "player" then 
--         if UnitIsUnit("player", myUnit) then CheckUnit(myUnit, true) end
--     elseif UnitIsPlayer(unit) then -- ignore pets
--         CheckUnit(unit, true)
--     end
-- end

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
        buffTrackerFrame:RegisterEvent("PARTY_MEMBER_ENABLE")
        buffTrackerFrame:RegisterEvent("PARTY_MEMBER_DISABLE")
    else
        buffTrackerFrame:UnregisterEvent("READY_CHECK")
        buffTrackerFrame:UnregisterEvent("UNIT_FLAGS")
        buffTrackerFrame:UnregisterEvent("PLAYER_UNGHOST")
        buffTrackerFrame:UnregisterEvent("UNIT_AURA")
        buffTrackerFrame:UnregisterEvent("PARTY_MEMBER_ENABLE")
        buffTrackerFrame:UnregisterEvent("PARTY_MEMBER_DISABLE")

        Reset()
        AnchorButtons()
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

function buffTrackerFrame:PARTY_MEMBER_ENABLE()
    buffTrackerFrame:GROUP_ROSTER_UPDATE()
end

function buffTrackerFrame:PARTY_MEMBER_DISABLE()
    buffTrackerFrame:GROUP_ROSTER_UPDATE()
end

function buffTrackerFrame:UNIT_AURA(unit)
    if IsInRaid() then
        if string.match(unit, "raid%d") then
            CheckUnit(unit, true)
        end
    else
        if string.match(unit, "party%d") or unit=="player" then
            CheckUnit(unit, true)
        end
    end
end

function buffTrackerFrame:PLAYER_REGEN_ENABLED()
    buffTrackerFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
    AnchorButtons()
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
            -- LGI.RegisterCallback(buffTrackerFrame, "GroupInfo_UpdateBase", "UnitUpdated") 

            if not enabled and which == "buffTracker" then -- already in world, manually enabled
                buffTrackerFrame:GROUP_ROSTER_UPDATE(true)
            end
            enabled = true
            if Cell.vars.showMover then
                ShowMover(true)
            end
        else
            buffTrackerFrame:UnregisterAllEvents()
            -- LGI.UnregisterCallback(buffTrackerFrame, "GroupInfo_UpdateBase")
            
            Reset()
            myUnit = ""
            AnchorButtons()

            enabled = false
            ShowMover(false)

            -- missingBuffs indicator
            for unit in F:IterateGroupMembers() do
                I:HideMissingBuffs(unit, true)
            end
        end

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
        P:LoadPosition(buffTrackerFrame, CellDB["tools"]["buffTracker"][2])
    end
end
Cell:RegisterCallback("UpdateTools", "BuffTracker_UpdateTools", UpdateTools)

local function UpdatePixelPerfect()
    P:Resize(buffTrackerFrame)

    for _, i in pairs(fakeIcons) do
        i:UpdatePixelPerfect()
    end

    for _, b in pairs(buttons) do
        b:UpdatePixelPerfect()
    end
end
Cell:RegisterCallback("UpdatePixelPerfect", "BuffTracker_UpdatePixelPerfect", UpdatePixelPerfect)