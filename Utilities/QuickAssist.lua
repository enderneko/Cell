local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local I = Cell.iFuncs
local U = Cell.uFuncs
local A = Cell.animations
local P = Cell.pixelPerfectFuncs

local UnitIsConnected = UnitIsConnected
local InCombatLockdown = InCombatLockdown
local GetUnitName = GetUnitName
local UnitGUID = UnitGUID

local LGI = LibStub:GetLibrary("LibGroupInfo")
local LCG = LibStub("LibCustomGlow-1.0")
local LibTranslit = LibStub("LibTranslit-1.0")

local quickAssistTable, layoutTable, styleTable, spellTable, quickAssistReady
local myBuffs_icon, myBuffs_bar = {}, {}
local offensiveBuffs, offensiveCasts = {}, {}
local offensivesEnabled, offensiveIconGlowType, offensiveIconGlowColor, buffsGlowType
local tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY

-- ----------------------------------------------------------------------- --
--                            quick assist frame                           --
-- ----------------------------------------------------------------------- --
local quickAssistFrame = CreateFrame("Frame", "CellQuickAssistFrame", Cell.frames.mainFrame, "SecureFrameTemplate")
Cell.frames.quickAssistFrame = quickAssistFrame

local anchorFrame = CreateFrame("Frame", "CellQuickAssistAnchorFrame", quickAssistFrame)
PixelUtil.SetPoint(anchorFrame, "TOPLEFT", UIParent, "CENTER", 1, -1)
anchorFrame:SetMovable(true)
anchorFrame:SetClampedToScreen(true)

local hoverFrame = CreateFrame("Frame", nil, quickAssistFrame, "BackdropTemplate")
hoverFrame:SetPoint("TOP", anchorFrame, 0, 1)
hoverFrame:SetPoint("BOTTOM", anchorFrame, 0, -1)
hoverFrame:SetPoint("LEFT", anchorFrame, -1, 0)
hoverFrame:SetPoint("RIGHT", anchorFrame, 1, 0)
-- Cell:StylizeFrame(hoverFrame, {1,0,0,0.3}, {0,0,0,0})

A:ApplyFadeInOutToMenu(anchorFrame, hoverFrame)

local config = Cell:CreateButton(anchorFrame, nil, "accent", {20, 10}, false, true)
config:SetFrameStrata("MEDIUM")
config:SetAllPoints(anchorFrame)
config:RegisterForDrag("LeftButton")
config:RegisterForClicks("LeftButtonUp", "RightButtonUp")
config:SetScript("OnClick", function(self, button)
    if button == "LeftButton" then
        F:ShowUtilitiesTab()
        F:ShowQuickAssistTab()
    elseif button == "RightButton" then
        if not InCombatLockdown() then
            F:Print(L["Refreshing unit buttons (%s)..."]:format(L["Quick Assist"]))
            LGI:ForceUpdate()
        end
    end
end)

config:SetScript("OnDragStart", function()
    anchorFrame:StartMoving()
    anchorFrame:SetUserPlaced(false)
end)

config:SetScript("OnDragStop", function()
    anchorFrame:StopMovingOrSizing()
    P:SavePosition(anchorFrame, layoutTable["position"])
end)

config:HookScript("OnEnter", function()
    hoverFrame:GetScript("OnEnter")(hoverFrame)
    CellTooltip:SetOwner(config, "ANCHOR_NONE")
    CellTooltip:SetPoint(tooltipPoint, config, tooltipRelativePoint, tooltipX, tooltipY)
    CellTooltip:AddLine(L["Quick Assist"])
    CellTooltip:AddLine("|cffffb5c5"..L["Right-Click"]..": |cffffffff"..L["refresh unit buttons"])
    CellTooltip:AddLine("|cffababab("..L["not in combat"]..")")
    CellTooltip:Show()
end)

config:HookScript("OnLeave", function()
    hoverFrame:GetScript("OnLeave")(hoverFrame)
    CellTooltip:Hide()
end)

local function UpdateAnchor()
    local show
    if layoutTable then
        show = Cell.unitButtons.quickAssist[1]:IsShown()
    end
    
    hoverFrame:EnableMouse(show)
    if show then
        config:Show()
        if CellDB["general"]["fadeOut"] then
            if hoverFrame:IsMouseOver() then
                anchorFrame.fadeIn:Play()
            else
                anchorFrame.fadeOut:GetScript("OnFinished")(anchorFrame.fadeOut)
            end
        end
    else
        config:Hide()
    end
end

-- ----------------------------------------------------------------------- --
--                           apply click-castings                          --
-- ----------------------------------------------------------------------- --
-- local function ClearClickCastings(b)
--     for i = 1, 5 do
--         b:SetAttribute("type"..i, nil)
--     end
-- end

-- local function ApplyClickCastings(b)
--     for i, t in pairs(spellTable["mine"]["clickCastings"]) do
--         if t[1] == 0 then
--             b:SetAttribute("type"..i, "target")
--         elseif t[1] ~= -1 then
--             local spellName = GetSpellInfo(t[1])

--             b:SetAttribute("type"..i, "macro")
--             b:SetAttribute("macrotext"..i, "/cast [@mouseover] "..spellName)
--         end
--     end
-- end

-------------------------------------------------
-- aura tables
-------------------------------------------------
local function InitAuraTables(self)
    -- vars
    self._casts = {}
    self._timers = {}

    -- for icon animation only
    self._buffs_cache = {}
    self._buffs_count_cache = {}
end

local function ResetAuraTables(self)
    wipe(self._casts)
    wipe(self._timers)
    wipe(self._buffs_cache)
    wipe(self._buffs_count_cache)
end

-------------------------------------------------
-- ForEachAura
-------------------------------------------------
local function ForEachAuraHelper(button, func, continuationToken, ...)
    -- continuationToken is the first return value of UnitAuraSlots()
    local n = select('#', ...)
    local index = 1
    for i = 1, n do
        local slot = select(i, ...)
        local auraInfo = C_UnitAuras.GetAuraDataBySlot(button.unit, slot)
        local done = func(button, auraInfo, index)
        if done then
            -- if func returns true then no further slots are needed, so don't return continuationToken
            return nil
        end
        index = index + 1
    end
    return continuationToken
end

local function ForEachAura(button, filter, func)
    local continuationToken
    repeat
        -- continuationToken is the first return value of UnitAuraSltos
        continuationToken = ForEachAuraHelper(button, func, UnitAuraSlots(button.unit, filter, nil, continuationToken))
    until continuationToken == nil
end

-- ----------------------------------------------------------------------- --
--                                functions                                --
-- ----------------------------------------------------------------------- --
local function HandleBuff(self, auraInfo)
    local auraInstanceID = auraInfo.auraInstanceID
    local name = auraInfo.name
    local icon = auraInfo.icon
    local count = auraInfo.applications
    -- local debuffType = auraInfo.isHarmful and auraInfo.dispelName
    local expirationTime = auraInfo.expirationTime or 0
    local start = expirationTime - auraInfo.duration
    local duration = auraInfo.duration
    local source = auraInfo.sourceUnit
    local spellId = auraInfo.spellId
    -- local attribute = auraInfo.points[1] -- UnitAura:arg16

    local refreshing = false

    if duration then
        if Cell.vars.iconAnimation == "duration" then
            local timeIncreased = self._buffs_cache[auraInstanceID] and (expirationTime - self._buffs_cache[auraInstanceID] >= 0.5) or false
            local countIncreased = self._buffs_count_cache[auraInstanceID] and (count > self._buffs_count_cache[auraInstanceID]) or false
            refreshing = timeIncreased or countIncreased
        elseif Cell.vars.iconAnimation == "stack" then
            refreshing = self._buffs_count_cache[auraInstanceID] and (count > self._buffs_count_cache[auraInstanceID]) or false
        else
            refreshing = false
        end
        
        if (source == "player" and (myBuffs_icon[name] or myBuffs_bar[name])) or offensiveBuffs[spellId] then
            self._buffs_cache[auraInstanceID] = expirationTime
            self._buffs_count_cache[auraInstanceID] = count
        end
        
        if myBuffs_icon[name] and source == "player" and self._buffIconsFound < 5 then
            self._buffIconsFound = self._buffIconsFound + 1
            self.buffIcons[self._buffIconsFound]:SetCooldown(start, duration, nil, icon, count, refreshing, myBuffs_icon[name], buffsGlowType)
        end
        
        if myBuffs_bar[name] and source == "player" and self._buffBarsFound < 5 then
            self._buffBarsFound = self._buffBarsFound + 1
            self.buffBars[self._buffBarsFound]:SetCooldown(start, duration, myBuffs_bar[name])
        end

        if offensiveBuffs[spellId] and self._offensivesFound < 5 then
            self._offensivesFound = self._offensivesFound + 1
            self.offensiveIcons[self._offensivesFound]:SetCooldown(start, duration, nil, icon, count, refreshing, offensiveIconGlowColor, offensiveIconGlowType)
            self.offensiveGlow:SetCooldown(start, duration)
        end
    end
end

local function QuickAssist_UpdateAuras(self, updateInfo)
    local unit = self.unit
    if not unit then return end

    local buffsChanged

    if not updateInfo or updateInfo.isFullUpdate then
        wipe(self._buffs_cache)
        wipe(self._buffs_count_cache)
        buffsChanged = true
    else
        if updateInfo.addedAuras then
            for _, aura in pairs(updateInfo.addedAuras) do
                if aura.isHelpful then buffsChanged = true end
            end
        end

        if updateInfo.updatedAuraInstanceIDs then
            for _, auraInstanceID in pairs(updateInfo.updatedAuraInstanceIDs) do
                if self._buffs_cache[auraInstanceID] then buffsChanged = true end
            end
        end

        if updateInfo.removedAuraInstanceIDs then
            for _, auraInstanceID in pairs(updateInfo.removedAuraInstanceIDs) do
                if self._buffs_cache[auraInstanceID] then
                    self._buffs_cache[auraInstanceID] = nil
                    self._buffs_count_cache[auraInstanceID] = nil
                    buffsChanged = true
                end
            end
        end

        if Cell.loaded then
            if CellDB["general"]["alwaysUpdateBuffs"] then buffsChanged = true end
        end
    end
    
    if buffsChanged then
        self._buffIconsFound = 0
        self._buffBarsFound = 0
        self._offensivesFound = 0

        self.offensiveGlow:Hide()

        -- update myBuffs_icon and offensiveBuffs
        ForEachAura(self, "HELPFUL", HandleBuff)
        self.buffIcons:UpdateSize(self._buffIconsFound)
        self.buffBars:UpdateSize(self._buffBarsFound)

        -- update offensiveCasts
        if offensivesEnabled then
            for spellId, start in pairs(self._casts) do
                local duration = offensiveCasts[spellId][1]
                -- if start + duration <= GetTime() then
                --     self._casts[spellId] = nil
                -- else
                    if self._offensivesFound < 5 then
                        self._offensivesFound = self._offensivesFound + 1
                        self.offensiveIcons[self._offensivesFound]:SetCooldown(start, duration, nil, offensiveCasts[spellId][2], 0, false, offensiveIconGlowColor, offensiveIconGlowType)
                        self.offensiveGlow:SetCooldown(start, duration)
                    end
                -- end
            end
        end
        self.offensiveIcons:UpdateSize(self._offensivesFound)
    end
end

local function QuickAssist_UpdateCasts(self, spellId)
    if not self.unit then return end
    if not offensiveCasts[spellId] then return end
    
    self._casts[spellId] = GetTime()
    QuickAssist_UpdateAuras(self)

    if self._timers[spellId] then self._timers[spellId]:Cancel() end
    self._timers[spellId] = C_Timer.NewTimer(offensiveCasts[spellId][1], function()
        -- print("TIMER:QuickAssist_UpdateAuras", spellId)
        self._timers[spellId] = nil
        self._casts[spellId] = nil
        QuickAssist_UpdateAuras(self)
    end)
end

local function QuickAssist_UpdateName(self)
    if not self.unit then return end

    self.name = UnitName(self.unit)
    self.fullName = F:UnitFullName(self.unit)

    self.nameText:UpdateName()
end

local function QuickAssist_UpdateNameColor(self)
    if not self.unit then return end

    self.class = UnitClassBase(self.unit) --! update class or it may be nil

    if not styleTable then
        self.nameText:SetTextColor(1, 1, 1)
        return 
    end
    
    if not UnitIsConnected(self.unit) then
        self.nameText:SetTextColor(F:GetClassColor(self.class))
    else
        if styleTable["name"]["color"][1] == "class_color" then
            self.nameText:SetTextColor(F:GetClassColor(self.class))
        else
            self.nameText:SetTextColor(unpack(styleTable["name"]["color"][2]))
        end
    end
end

local function GetHealthColor(r, g, b)
    if not styleTable then
        return r, g, b, 1, r*0.2, g*0.2, b*0.2, 1
    end

    local hpR, hpG, hpB, lossR, lossG, lossB
    
    -- hp
    if styleTable["hpColor"][1] == "class_color" then
        hpR, hpG, hpB = r, g, b
    elseif styleTable["hpColor"][1] == "class_color_dark" then
        hpR, hpG, hpB = r*0.2, g*0.2, b*0.2
    else
        hpR = styleTable["hpColor"][2][1]
        hpG = styleTable["hpColor"][2][2]
        hpB = styleTable["hpColor"][2][3]
    end

    -- bg
    if styleTable["lossColor"][1] == "class_color" then
        lossR, lossG, lossB = r, g, b
    elseif styleTable["lossColor"][1] == "class_color_dark" then
        lossR, lossG, lossB = r*0.2, g*0.2, b*0.2
    else
        lossR = styleTable["lossColor"][2][1]
        lossG = styleTable["lossColor"][2][2]
        lossB = styleTable["lossColor"][2][3]
    end

    -- alpha
    hpA =  styleTable["hpColor"][1] == "custom" and styleTable["hpColor"][2][4] or 1
    lossA =  styleTable["lossColor"][1] == "custom" and styleTable["lossColor"][2][4] or 1

    return hpR, hpG, hpB, hpA, lossR, lossG, lossB, lossA
end

local function QuickAssist_UpdateHealthColor(self)
    if not self.unit then return end

    self.class = UnitClassBase(self.unit) --! update class or it may be nil

    local hpR, hpG, hpB
    local lossR, lossG, lossB
    local hpA, lossA = 1, 1
    
    if not UnitIsConnected(self.unit) then
        hpR, hpG, hpB = 0.4, 0.4, 0.4
        lossR, lossG, lossB = 0.4, 0.4, 0.4
    else
        hpR, hpG, hpB, hpA, lossR, lossG, lossB, lossA = GetHealthColor(F:GetClassColor(self.class))
    end

    self.healthBar:SetStatusBarColor(hpR, hpG, hpB, hpA)
    self.healthLoss:SetVertexColor(lossR, lossG, lossB, lossA)
end

local function QuickAssist_UpdateHealthMax(self)
    if not self.unit then return end
    self.healthBar:SetMinMaxValues(0, UnitHealthMax(self.unit))
end

local function QuickAssist_UpdateHealth(self)
    if not self.unit then return end

    self.healthBar:SetValue(UnitHealth(self.unit))

    if UnitIsDeadOrGhost(self.unit) then
        self.deadTex:Show()
    else
        self.deadTex:Hide()
    end
end

local function QuickAssist_UpdateTarget(self)
    if not self.unit then return end

    if UnitIsUnit(self.unit, "target") then
        if styleTable["highlightSize"] ~= 0 then self.targetHighlight:Show() end
    else
        self.targetHighlight:Hide()
    end
end

-- FIXME: BLIZZARD, IT'S BUGGY!
-- UNIT_IN_RANGE_UPDATE: unit, inRange
local function QuickAssist_UpdateInRange(self, ir)
    if not self.unit then return end

    if ir then
        A:FrameFadeIn(self, 0.25, self:GetAlpha(), 1)
    else
        A:FrameFadeOut(self, 0.25, self:GetAlpha(), styleTable["oorAlpha"] or 0.25)
    end
end

local function QuickAssist_UpdateInRange_OnTick(self)
    if not self.unit then return end

    local inRange = F:IsInRange(self.unit)

    self.inRange = inRange
    if Cell.loaded then
        if self.inRange ~= self.wasInRange then
            if inRange then
                A:FrameFadeIn(self, 0.25, self:GetAlpha(), 1)
            else
                A:FrameFadeOut(self, 0.25, self:GetAlpha(), styleTable["oorAlpha"] or 0.25)
            end
        end
        self.wasInRange = inRange
    end
end

local function QuickAssist_UpdateAll(self)
    if not self:IsVisible() then return end

    QuickAssist_UpdateName(self)
    QuickAssist_UpdateNameColor(self)
    QuickAssist_UpdateHealthMax(self)
    QuickAssist_UpdateHealth(self)
    QuickAssist_UpdateHealthColor(self)
    QuickAssist_UpdateTarget(self)
    -- QuickAssist_UpdateInRange(self, F:IsInRange(self.unit))
    QuickAssist_UpdateInRange_OnTick(self)
    QuickAssist_UpdateAuras(self)
end

local function QuickAssist_RegisterEvents(self)
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    
    self:RegisterEvent("UNIT_HEALTH")
    self:RegisterEvent("UNIT_MAXHEALTH")
    
    self:RegisterEvent("UNIT_AURA")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    
    self:RegisterEvent("UNIT_CONNECTION") -- offline
    self:RegisterEvent("UNIT_NAME_UPDATE") -- unknown target

    self:RegisterEvent("PLAYER_TARGET_CHANGED")

    if quickAssistReady then
        QuickAssist_UpdateAll(self)
    end
end

local function QuickAssist_UnregisterEvents(self)
    self:UnregisterAllEvents()
end

local function QuickAssist_OnEvent(self, event, unit, arg, arg2)
    if unit and self.unit == unit then
        if event == "UNIT_AURA" then
            QuickAssist_UpdateAuras(self, arg)

        elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
            QuickAssist_UpdateCasts(self, arg2)
        
        elseif event == "UNIT_HEALTH" then
            QuickAssist_UpdateHealth(self)
        
        elseif event == "UNIT_MAXHEALTH" then
            QuickAssist_UpdateHealthMax(self)
            QuickAssist_UpdateHealth(self)

        elseif event == "UNIT_CONNECTION" then
            self._updateRequired = 1
        
        elseif event == "UNIT_NAME_UPDATE" then
            QuickAssist_UpdateName(self)
            QuickAssist_UpdateNameColor(self)
            QuickAssist_UpdateHealthColor(self)

        elseif event == "UNIT_IN_RANGE_UPDATE" then
            QuickAssist_UpdateInRange(self, arg)
        end

    else
        if event == "GROUP_ROSTER_UPDATE" then
            self._updateRequired = 1

        elseif event == "PLAYER_TARGET_CHANGED" then
            QuickAssist_UpdateTarget(self)
        end
    end
end

local function QuickAssist_OnShow(self)
    -- print(GetTime(), "OnShow", self:GetName())
    self._updateRequired = nil -- prevent QuickAssist_UpdateAll twice. when convert party <-> raid, GROUP_ROSTER_UPDATE fired.
    QuickAssist_RegisterEvents(self)
end

local function QuickAssist_OnHide(self)
    -- print(GetTime(), "OnHide", self:GetName())
    QuickAssist_UnregisterEvents(self)
    ResetAuraTables(self)
end

local function QuickAssist_OnEnter(self)
    if styleTable["highlightSize"] ~= 0 then
        self.mouseoverHighlight:Show()
    end
end

local function QuickAssist_OnLeave(self)
    self.mouseoverHighlight:Hide()
end

local function QuickAssist_OnTick(self)
    -- print(GetTime(), "OnTick", self._updateRequired, self:GetAttribute("refreshOnUpdate"), self:GetName())
    local e = (self.__tickCount or 0) + 1
    if e >= 2 then -- every 0.5 second
        e = 0
        
        if self.unit then
            local guid = UnitGUID(self.unit)
            if guid ~= self.__guid then
                self.__guid = guid
                self._updateRequired = 1
            end
        end
    end

    self.__tickCount = e

    QuickAssist_UpdateInRange_OnTick(self)

    if self._updateRequired then
        self._updateRequired = nil
        QuickAssist_UpdateAll(self)
    end
end

local function QuickAssist_OnUpdate(self, elapsed)
    local e = (self.__updateElapsed or 0) + elapsed
    if e > 0.25 then
        QuickAssist_OnTick(self)
        e = 0
    end
    self.__updateElapsed = e
end

local function QuickAssist_OnSizeChanged(self)
    if not self.unit then return end
    self.nameText:UpdateName()
end

local function QuickAssist_OnAttributeChanged(self, name, value)
    if name == "unit" then
        if self.unit ~= value then
            self.unit = value
            -- self:RegisterUnitEvent("UNIT_IN_RANGE_UPDATE", value)
            ResetAuraTables(self)
        end

        if value then
            Cell.unitButtons.quickAssist.units[value] = self
        end
    end
end

-- ----------------------------------------------------------------------- --
--                                  OnLoad                                 --
-- ----------------------------------------------------------------------- --
function CellQuickAssist_OnLoad(button)
    InitAuraTables(button)

    -- ping system
    Mixin(button, PingableType_UnitFrameMixin)
    button:SetAttribute("ping-receiver", true)

    function button:GetTargetPingGUID()
        return button.__unitGuid
    end

    -- healthBar
    local healthBar = CreateFrame("StatusBar", nil, button)
    button.healthBar = healthBar
   
    healthBar:SetStatusBarTexture(Cell.vars.texture)
    healthBar:SetFrameLevel(button:GetFrameLevel()+5)

    -- heathLoss
    local healthLoss = healthBar:CreateTexture(nil, "ARTWORK", nil , -7)
    button.healthLoss = healthLoss
    healthLoss:SetPoint("TOPLEFT", healthBar:GetStatusBarTexture(), "TOPRIGHT")
    healthLoss:SetPoint("BOTTOMRIGHT")

    -- dead texture
    local deadTex = healthBar:CreateTexture(nil, "OVERLAY")
    button.deadTex = deadTex
    deadTex:SetAllPoints(healthBar)
    deadTex:SetTexture("Interface\\Buttons\\WHITE8x8")
    deadTex:SetGradient("VERTICAL", CreateColor(0.545, 0, 0, 1), CreateColor(0, 0, 0, 1))
    deadTex:Hide()

    -- nameText
    local nameText = healthBar:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    button.nameText = nameText
    nameText.width = {"percentage", 0.75}

    function nameText:UpdateName()
        local name

        if CELL_NICKTAG_ENABLED and Cell.NickTag then
            name = Cell.NickTag:GetNickname(button.name, nil, true)
        end
        name = name or F:GetNickname(button.name, button.fullName)

        if Cell.loaded and CellDB["general"]["translit"] then
            name = LibTranslit:Transliterate(name)
        end

        F:UpdateTextWidth(nameText, name, nameText.width, button)

        -- nameText:SetSize(nameText:GetWidth(), nameText:GetHeight())
    end

    -- targetHighlight
    local targetHighlight = CreateFrame("Frame", nil, button, "BackdropTemplate")
    button.targetHighlight = targetHighlight
    targetHighlight:SetIgnoreParentAlpha(true)
    targetHighlight:SetFrameLevel(button:GetFrameLevel()+6)
    targetHighlight:Hide()
    
    -- mouseoverHighlight
    local mouseoverHighlight = CreateFrame("Frame", nil, button, "BackdropTemplate")
    button.mouseoverHighlight = mouseoverHighlight
    mouseoverHighlight:SetIgnoreParentAlpha(true)
    mouseoverHighlight:SetFrameLevel(button:GetFrameLevel()+7)
    mouseoverHighlight:Hide()

    -- overlayFrame
    local overlayFrame = CreateFrame("Frame", button:GetName().."OverlayFrame", button)
    button.overlayFrame = overlayFrame
    overlayFrame:SetFrameLevel(button:GetFrameLevel()+8)
    overlayFrame:SetAllPoints(button)

    -- script
    button:SetScript("OnAttributeChanged", QuickAssist_OnAttributeChanged) -- init
    button:HookScript("OnShow", QuickAssist_OnShow)
    button:HookScript("OnHide", QuickAssist_OnHide) -- click-castings: _onhide
    button:HookScript("OnEnter", QuickAssist_OnEnter) -- click-castings: _onenter
    button:HookScript("OnLeave", QuickAssist_OnLeave) -- click-castings: _onleave
    button:SetScript("OnUpdate", QuickAssist_OnUpdate)
    button:SetScript("OnSizeChanged", QuickAssist_OnSizeChanged)
    button:SetScript("OnEvent", QuickAssist_OnEvent)
    button:RegisterForClicks("AnyDown")
end

-- ----------------------------------------------------------------------- --
--                              create header                              --
-- ----------------------------------------------------------------------- --
local header = CreateFrame("Frame", "CellQuickAssistHeader", quickAssistFrame, "SecureGroupHeaderTemplate")

-- function header:UpdateButtonUnit(bName, unit)
--     local b = _G[bName]
--     b.unit = unit
--     b:RegisterUnitEvent("UNIT_IN_RANGE_UPDATE", unit)
--     ResetAuraTables(b)

--     if not unit then return end

--     Cell.unitButtons.quickAssist.units[unit] = b
-- end

-- header:SetAttribute("_initialAttributeNames", "refreshUnitChange")
-- header:SetAttribute("_initialAttribute-refreshUnitChange", [[
--     self:GetParent():CallMethod("UpdateButtonUnit", self:GetName(), self:GetAttribute("unit"))
-- ]])

-- header:SetAttribute("initialConfigFunction", [[
--     local header = self:GetParent()
--     self:SetWidth(header:GetAttribute("minWidth") or 70)
--     self:SetHeight(header:GetAttribute("minHeight") or 25)
-- ]])

header:SetAttribute("template", "CellQuickAssistButtonTemplate")

-- header:SetAttribute("showRaid", true)
-- header:SetAttribute("showParty", true)

--! to make needButtons == 40 cheat configureChildren in SecureGroupHeaders.lua
header:SetAttribute("startingIndex", -39)
header:Show()
header:SetAttribute("startingIndex", 1)

for i, b in ipairs(header) do
    Cell.unitButtons.quickAssist[i] = b
end

-- update mover
header[1]:HookScript("OnShow", function()
    UpdateAnchor()
end)
header[1]:HookScript("OnHide", function()
    UpdateAnchor()
end)

-- ----------------------------------------------------------------------- --
--                                   glow                                  --
-- ----------------------------------------------------------------------- --
local function ShowGlow(indicator, glowType, glowColor)
    if glowType == "Normal" then
        LCG.PixelGlow_Stop(indicator)
        LCG.AutoCastGlow_Stop(indicator)
        LCG.ProcGlow_Stop(indicator)
        LCG.ButtonGlow_Start(indicator, glowColor)
    elseif glowType == "Pixel" then
        LCG.ButtonGlow_Stop(indicator)
        LCG.AutoCastGlow_Stop(indicator)
        LCG.ProcGlow_Stop(indicator)
        -- color, N, frequency, length, thickness
        LCG.PixelGlow_Start(indicator, glowColor, 7, 0.5, 4, 1)
    elseif glowType == "Shine" then
        LCG.ButtonGlow_Stop(indicator)
        LCG.PixelGlow_Stop(indicator)
        LCG.ProcGlow_Stop(indicator)
        -- color, N, frequency, scale
        LCG.AutoCastGlow_Start(indicator, glowColor, 7, 0.5, 0.7)
    elseif glowType == "Proc" then
        LCG.ButtonGlow_Stop(indicator)
        LCG.PixelGlow_Stop(indicator)
        LCG.AutoCastGlow_Stop(indicator)
        -- color, duration
        LCG.ProcGlow_Start(indicator, {color=glowColor, duration=0.6, startAnim=false})
    else
        LCG.ButtonGlow_Stop(indicator)
        LCG.PixelGlow_Stop(indicator)
        LCG.AutoCastGlow_Stop(indicator)
        LCG.ProcGlow_Stop(indicator)
    end
end

-- ----------------------------------------------------------------------- --
--                               spec filter                               --
-- ----------------------------------------------------------------------- --
local specFrame = CreateFrame("Frame")

local specFilter
local nameList = {}
local nameToPriority = {}

local function GetPriority(class, specId)
    if not class then return end
    if not specId or specId == 0 then return end
    
    local priority
    for ci, ct in pairs(specFilter[2]) do
        if class == ct[1] then  -- class
            priority = ci*10
            for si, st in pairs(ct[2]) do
                if specId == st[1] then  -- spec
                    if st[2] then -- enabled
                        priority = priority + si
                    else
                        priority = nil
                    end
                    break
                end                
            end
            break
        end
    end

    return priority
end

local function UpdateAllUnits()
    if InCombatLockdown() then
        specFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end

    wipe(nameList)
    wipe(nameToPriority)

    for unit in F:IterateGroupMembers() do
        if UnitIsConnected(unit) then
            local name = GetUnitName(unit, true)
            local guid = UnitGUID(unit)
            local info = LGI:GetCachedInfo(guid)
            if info then
                nameToPriority[name] = GetPriority(info.class, info.specId)
                -- print(name, nameToPriority[name], info.class, info.specId)
            end
            if nameToPriority[name] then
                tinsert(nameList, name)
            end
        end
    end

    -- check hide self
    if specFilter[3] then
        F:TRemove(nameList, Cell.vars.playerNameShort)
        nameToPriority[Cell.vars.playerNameShort] = nil
    end

    -- sort by class, spec, name
    sort(nameList, function(a, b)
        if nameToPriority[a] ~= nameToPriority[b] then
            return nameToPriority[a] < nameToPriority[b]
        else
            return a < b
        end
    end)

    -- texplore(nameList)
    -- texplore(nameToPriority)

    header:SetAttribute("groupingOrder", "")
    header:SetAttribute("groupFilter", nil)
    header:SetAttribute("groupBy", nil)
    header:SetAttribute("nameList", F:TableToString(nameList, ","))
    header:SetAttribute("sortMethod", "NAMELIST")
end

local timer
function specFrame:PrepareUpdate(self, ...)
    specFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")

    if timer then timer:Cancel() end
    timer = C_Timer.NewTimer(1, UpdateAllUnits)
end
specFrame:SetScript("OnEvent", specFrame.PrepareUpdate)

local function EnableSpecFilter(enable)
    if enable then
        specFrame:PrepareUpdate()
        specFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
        LGI.RegisterCallback(specFrame, "GroupInfo_Update", "PrepareUpdate")
    else
        specFrame:UnregisterAllEvents()
        LGI.UnregisterCallback(specFrame, "GroupInfo_Update")
    end
end

-- ----------------------------------------------------------------------- --
--                                callbacks                                --
-- ----------------------------------------------------------------------- --
local function UpdatePosition()
    if not layoutTable then return end
    
    local anchor = layoutTable["anchor"]
    
    quickAssistFrame:ClearAllPoints()
    P:LoadPosition(anchorFrame, layoutTable["position"])

    if CellDB["general"]["menuPosition"] == "top_bottom" then
        P:Size(anchorFrame, 20, 10)
        
        if anchor == "BOTTOMLEFT" then
            quickAssistFrame:SetPoint("BOTTOMLEFT", anchorFrame, "TOPLEFT", 0, 4)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "TOPLEFT", "BOTTOMLEFT", 0, -3
        elseif anchor == "BOTTOMRIGHT" then
            quickAssistFrame:SetPoint("BOTTOMRIGHT", anchorFrame, "TOPRIGHT", 0, 4)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "TOPRIGHT", "BOTTOMRIGHT", 0, -3
        elseif anchor == "TOPLEFT" then
            quickAssistFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -4)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "BOTTOMLEFT", "TOPLEFT", 0, 3
        elseif anchor == "TOPRIGHT" then
            quickAssistFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT", 0, -4)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "BOTTOMRIGHT", "TOPRIGHT", 0, 3
        end
    else -- left_right
        P:Size(anchorFrame, 10, 20)

        if anchor == "BOTTOMLEFT" then
            quickAssistFrame:SetPoint("BOTTOMLEFT", anchorFrame, "BOTTOMRIGHT", 4, 0)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "BOTTOMRIGHT", "BOTTOMLEFT", -3, 0
        elseif anchor == "BOTTOMRIGHT" then
            quickAssistFrame:SetPoint("BOTTOMRIGHT", anchorFrame, "BOTTOMLEFT", -4, 0)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "BOTTOMLEFT", "BOTTOMRIGHT", 3, 0
        elseif anchor == "TOPLEFT" then
            quickAssistFrame:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT", 4, 0)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "TOPRIGHT", "TOPLEFT", -3, 0
        elseif anchor == "TOPRIGHT" then
            quickAssistFrame:SetPoint("TOPRIGHT", anchorFrame, "TOPLEFT", -4, 0)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "TOPLEFT", "TOPRIGHT", 3, 0
        end
    end
end

local function UpdateMenu(which)
    if not which or which == "lock" then
        if CellDB["general"]["locked"] then
            config:RegisterForDrag()
        else
            config:RegisterForDrag("LeftButton")
        end
    end

    if not which or which == "fadeOut" then
        if CellDB["general"]["fadeOut"] then
            anchorFrame.fadeOut:Play()
        else
            anchorFrame.fadeIn:Play()
        end
        UpdateAnchor()
    end

    if which == "position" then
        UpdatePosition()
    end
end
Cell:RegisterCallback("UpdateMenu", "QuickAssist_UpdateMenu", UpdateMenu)

local function UpdateQuickAssist(which)
    F:Debug("|cff33937FUpdateQuickAssist:|r", which)

    quickAssistTable = CellDB["quickAssist"][Cell.vars.playerSpecID]
    local groupType = Cell.vars.quickAssistGroupType

    if not (quickAssistTable and quickAssistTable["enabled"]) then
        quickAssistFrame:Hide()
        layoutTable = nil
        styleTable = nil
        spellTable = nil
        quickAssistReady = nil
        F:UpdateOmniCDPosition("Cell-QuickAssist")
        return
    end

    quickAssistFrame:Show()
    layoutTable = quickAssistTable["layout"]
    styleTable = quickAssistTable["style"]
    spellTable = quickAssistTable["spells"]
    quickAssistReady = true

    if not which or which == "layout" then
        UpdatePosition()
        header:ClearAllPoints()
        header:SetPoint(layoutTable["anchor"])

        local width, height = layoutTable["size"][1], layoutTable["size"][2]
        P:Size(quickAssistFrame, width, height)
        
        header:SetAttribute("_ignore", true) --! NOTE: prevent multi-invoke SecureGroupHeader_OnAttributeChanged

        header:SetAttribute("minWidth", P:Scale(width))
        header:SetAttribute("minHeight", P:Scale(height))

        local point, groupRelativePoint, unitSpacing, groupSpacing
        local spacing, x, y = layoutTable["spacingX"], layoutTable["spacingY"]

        if layoutTable["orientation"] == "horizontal" then
            if layoutTable["anchor"] == "BOTTOMLEFT" then
                point, groupRelativePoint = "LEFT", "BOTTOM"
                unitSpacing = layoutTable["spacingX"]
                groupSpacing = layoutTable["spacingY"]
            elseif layoutTable["anchor"] == "BOTTOMRIGHT" then
                point, groupRelativePoint = "RIGHT", "BOTTOM"
                unitSpacing = -layoutTable["spacingX"]
                groupSpacing = layoutTable["spacingY"]
            elseif layoutTable["anchor"] == "TOPLEFT" then
                point, groupRelativePoint = "LEFT", "TOP"
                unitSpacing = layoutTable["spacingX"]
                groupSpacing = layoutTable["spacingY"]
            elseif layoutTable["anchor"] == "TOPRIGHT" then
                point, groupRelativePoint = "RIGHT", "TOP"
                unitSpacing = -layoutTable["spacingX"]
                groupSpacing = layoutTable["spacingY"]
            end

            header:SetAttribute("xOffset", P:Scale(unitSpacing))
            header:SetAttribute("yOffset", 0)
        else
            if layoutTable["anchor"] == "BOTTOMLEFT" then
                point, groupRelativePoint = "BOTTOM", "LEFT"
                unitSpacing = layoutTable["spacingY"]
                groupSpacing = layoutTable["spacingX"]
            elseif layoutTable["anchor"] == "BOTTOMRIGHT" then
                point, groupRelativePoint = "BOTTOM", "RIGHT"
                unitSpacing = layoutTable["spacingY"]
                groupSpacing = -layoutTable["spacingX"]
            elseif layoutTable["anchor"] == "TOPLEFT" then
                point, groupRelativePoint = "TOP", "LEFT"
                unitSpacing = -layoutTable["spacingY"]
                groupSpacing = layoutTable["spacingX"]
            elseif layoutTable["anchor"] == "TOPRIGHT" then
                point, groupRelativePoint = "TOP", "RIGHT"
                unitSpacing = -layoutTable["spacingY"]
                groupSpacing = layoutTable["spacingX"]
            end

            header:SetAttribute("xOffset", 0)
            header:SetAttribute("yOffset", P:Scale(unitSpacing))
        end

        for i = 1, 40 do
            P:Size(header[i], width, height)
            header[i]:ClearAllPoints()
            header[i]:Hide()
        end

        header:SetAttribute("point", point)
        header:SetAttribute("columnAnchorPoint", groupRelativePoint)
        header:SetAttribute("columnSpacing", P:Scale(groupSpacing))
        header:SetAttribute("maxColumns", layoutTable["maxColumns"])

        header:SetAttribute("_ignore", false) --! NOTE: restore SecureGroupHeader_OnAttributeChanged
        header:SetAttribute("unitsPerColumn", layoutTable["unitsPerColumn"])

        -- C_Timer.After(0.5, function()
        --     for i = 1, 40 do
        --         header[i]:ClearAllPoints()
        --     end
        --     header:SetAttribute("_ignore", false)
        --     header:SetAttribute("unitsPerColumn", layoutTable["unitsPerColumn"])
        -- end)
    end

    if not which or which == "filter" then
        local selectedFilter = groupType and quickAssistTable["filterAutoSwitch"][groupType] or 0
        
        EnableSpecFilter(false)
        specFilter = nil

        if selectedFilter == 0 then -- hide
            header:SetAttribute("showRaid", false)
            header:SetAttribute("showParty", false)
            header:SetAttribute("showPlayer", false)
        else
            header:SetAttribute("showRaid", true)
            header:SetAttribute("showParty", true)
            header:SetAttribute("showPlayer", not quickAssistTable["filters"][selectedFilter][3])
            
            if quickAssistTable["filters"][selectedFilter][1] == "role" then
                local groupFilter = {}
                for k, v in pairs(quickAssistTable["filters"][selectedFilter][2]) do
                    if v then
                        tinsert(groupFilter, k)
                    end
                end
                groupFilter = table.concat(groupFilter, ",")
    
                header:SetAttribute("groupingOrder", "TANK,HEALER,DAMAGER")
                header:SetAttribute("groupBy", "ASSIGNEDROLE")
                header:SetAttribute("sortMethod", "NAME")
                header:SetAttribute("groupFilter", groupFilter)
    
            elseif quickAssistTable["filters"][selectedFilter][1] == "class" then
                local groupFilter = {}
                for k, v in pairs(quickAssistTable["filters"][selectedFilter][2]) do
                    if v[2] then
                        tinsert(groupFilter, v[1])
                    end
                end
                groupFilter = table.concat(groupFilter, ",")
    
                header:SetAttribute("groupingOrder", groupFilter)
                header:SetAttribute("groupBy", "CLASS")
                header:SetAttribute("sortMethod", "NAME")
                header:SetAttribute("groupFilter", groupFilter)

            elseif quickAssistTable["filters"][selectedFilter][1] == "spec" then
                specFilter = quickAssistTable["filters"][selectedFilter]
                EnableSpecFilter(true)
    
            elseif quickAssistTable["filters"][selectedFilter][1] == "name" then
                header:SetAttribute("sortMethod", "NAMELIST")
                header:SetAttribute("nameList", table.concat(quickAssistTable["filters"][selectedFilter][2], ","))
                header:SetAttribute("groupingOrder", "")
                header:SetAttribute("groupFilter", nil)
                header:SetAttribute("groupBy", nil)
            end
        end

        F:UpdateOmniCDPosition("Cell-QuickAssist")
    end

    if not which or which == "style" then
        for i = 1, 40 do
            -- if header[i]:IsVisible() then
            --     QuickAssist_UpdateInRange(header[i], F:IsInRange(header[i].unit))
            -- end

            -- color ----------------------------------------------------------------- --
            local tex = F:GetBarTextureByName(styleTable["texture"])
            header[i].healthBar:SetStatusBarTexture(tex)
            header[i].healthLoss:SetTexture(tex)
            QuickAssist_UpdateHealthColor(header[i])
            QuickAssist_UpdateNameColor(header[i])

            -- update nameText ------------------------------------------------------- --
            header[i].nameText:ClearAllPoints()
            header[i].nameText:SetPoint(unpack(styleTable["name"]["position"]))

            local font, fontSize, fontOutline, fontShadow = unpack(styleTable["name"]["font"])
            font = F:GetFont(font)

            local fontFlags
            if fontOutline == "None" then
                fontFlags = ""
            elseif fontOutline == "Outline" then
                fontFlags = "OUTLINE"
            else
                fontFlags = "OUTLINE,MONOCHROME"
            end

            header[i].nameText:SetFont(font, fontSize, fontFlags)

            if fontShadow then
                header[i].nameText:SetShadowOffset(1, -1)
                header[i].nameText:SetShadowColor(0, 0, 0, 1)
            else
                header[i].nameText:SetShadowOffset(0, 0)
                header[i].nameText:SetShadowColor(0, 0, 0, 0)
            end

            header[i].nameText.width = styleTable["name"]["width"]
            header[i].nameText:UpdateName()

            -- update highlights ----------------------------------------------------- --
            local targetHighlight = header[i].targetHighlight
            local mouseoverHighlight = header[i].mouseoverHighlight
            local size = styleTable["highlightSize"]

            -- update point
            if size == 0 then
                targetHighlight:Hide()
                mouseoverHighlight:Hide()
            else
                P:ClearPoints(targetHighlight)
                P:ClearPoints(mouseoverHighlight)
                
                if size < 0 then
                    size = abs(size)
                    P:Point(targetHighlight, "TOPLEFT", header[i], "TOPLEFT")
                    P:Point(targetHighlight, "BOTTOMRIGHT", header[i], "BOTTOMRIGHT")
                    P:Point(mouseoverHighlight, "TOPLEFT", header[i], "TOPLEFT")
                    P:Point(mouseoverHighlight, "BOTTOMRIGHT", header[i], "BOTTOMRIGHT")
                else
                    P:Point(targetHighlight, "TOPLEFT", header[i], "TOPLEFT", -size, size)
                    P:Point(targetHighlight, "BOTTOMRIGHT", header[i], "BOTTOMRIGHT", size, -size)
                    P:Point(mouseoverHighlight, "TOPLEFT", header[i], "TOPLEFT", -size, size)
                    P:Point(mouseoverHighlight, "BOTTOMRIGHT", header[i], "BOTTOMRIGHT", size, -size)
                end

                QuickAssist_UpdateTarget(header[i])
            end

            -- update thickness
            targetHighlight:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = P:Scale(size)})
            mouseoverHighlight:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = P:Scale(size)})

            -- update color
            targetHighlight:SetBackdropBorderColor(unpack(styleTable["targetColor"]))
            mouseoverHighlight:SetBackdropBorderColor(unpack(styleTable["mouseoverColor"]))
        end
    end

    if not which or which == "mine" then
        wipe(myBuffs_icon)
        wipe(myBuffs_bar)

        for _, t in pairs(spellTable["mine"]["buffs"]) do
            if t[1] > 0 then
                local spellName = GetSpellInfo(t[1])
                if spellName then
                    if t[2] == "icon" then
                        myBuffs_icon[spellName] = t[3]
                    else -- bar
                        myBuffs_bar[spellName] = t[3]
                    end
                end
            end
        end

        -- for i = 1, 40 do
        --     ClearClickCastings(header[i])
        --     ApplyClickCastings(header[i])
        -- end
    end

    if not which or which == "mine-indicator" then
        local bit = spellTable["mine"]["icon"]
        buffsGlowType = bit["glow"]

        local bbt = spellTable["mine"]["bar"]

        for i = 1, 40 do
            -- icon
            local indicator = header[i].buffIcons
            -- point
            P:ClearPoints(indicator)
            P:Point(indicator, bit["position"][1], header[i], bit["position"][2], bit["position"][3], bit["position"][4])
            -- size
            P:Size(indicator, bit["size"][1], bit["size"][2])
            -- orientation
            indicator:SetOrientation(bit["orientation"])
            -- font
            indicator:SetFont(unpack(bit["font"]))
            indicator:ShowDuration(bit["showDuration"])
            indicator:ShowAnimation(bit["showAnimation"])
            indicator:ShowStack(bit["showStack"])

            -- bar
            indicator = header[i].buffBars
            -- point
            P:ClearPoints(indicator)
            P:Point(indicator, bbt["position"][1], header[i], bbt["position"][2], bbt["position"][3], bbt["position"][4])
            -- size
            P:Size(indicator, bbt["size"][1], bbt["size"][2])
            -- orientation
            indicator:SetOrientation(bbt["orientation"])
        end
    end

    if not which or which == "offensives" then
        wipe(offensiveBuffs)
        wipe(offensiveCasts)

        if spellTable["offensives"]["enabled"] then
            offensiveBuffs = F:ConvertSpellTable_WithClass(spellTable["offensives"]["buffs"], true)
            offensiveCasts = F:ConvertSpellDurationTable_WithClass(spellTable["offensives"]["casts"])
        end

        offensivesEnabled = spellTable["offensives"]["enabled"]
    end

    if not which or which == "offensives-indicator" then
        local oit = spellTable["offensives"]["icon"]
        offensiveIconGlowType = oit["glow"]
        offensiveIconGlowColor = oit["glowColor"]

        local ogt = spellTable["offensives"]["glow"]

        for i = 1, 40 do
            -- icon
            local indicator = header[i].offensiveIcons
            -- point
            P:ClearPoints(indicator)
            P:Point(indicator, oit["position"][1], header[i], oit["position"][2], oit["position"][3], oit["position"][4])
            -- size
            P:Size(indicator, oit["size"][1], oit["size"][2])
            -- orientation
            indicator:SetOrientation(oit["orientation"])
            -- font
            indicator:SetFont(unpack(oit["font"]))
            indicator:ShowDuration(oit["showDuration"])
            indicator:ShowAnimation(oit["showAnimation"])
            indicator:ShowStack(oit["showStack"])
            
            -- glow
            indicator = header[i].offensiveGlow
            indicator:SetFadeOut(ogt["fadeOut"])
            indicator:UpdateGlowOptions(ogt["options"])
        end
    end

    if which == "mine" or which == "offensives" or which == "mine-indicator" or which == "offensives-indicator" then
        for i = 1, 40 do
            QuickAssist_UpdateAuras(header[i])
        end
    end
end
Cell:RegisterCallback("UpdateQuickAssist", "UpdateQuickAssist", UpdateQuickAssist)

local function QuickAssist_CreateIndicators(button)
    -- buffs indicator (icon)
    local buffIcons = I.CreateAura_Icons(button:GetName().."BuffIcons", button.overlayFrame, 5)
    button.buffIcons = buffIcons
    buffIcons:Show()
    -- indicator color
    for i = 1, 5 do
        if buffIcons[i].cooldown:IsObjectType("StatusBar") then
            buffIcons[i].cooldown:GetStatusBarTexture():SetAlpha(1)
            buffIcons[i].tex = buffIcons[i]:CreateTexture(nil, "OVERLAY")
            buffIcons[i].tex:SetAllPoints(buffIcons[i].icon)

            hooksecurefunc(buffIcons[i], "SetCooldown", function(self, _, _, _, _, _, _, color, glow)
                self.tex:SetColorTexture(unpack(color))
                self.spark:SetColorTexture(color[1], color[2], color[3], 1) -- ignore alpha
                -- elseif self.cooldown:IsObjectType("Cooldown") then
                --     self.cooldown:SetSwipeTexture(0)
                --     self.cooldown:SetSwipeColor(unpack(color))
                ShowGlow(self, glow, color)
            end)
        end
    end

    -- buffs indicator (bar)
    local buffBars = I.CreateAura_Bars(button:GetName().."BuffBars", button.overlayFrame, 5)
    button.buffBars = buffBars
    buffBars:Show()

    -- offensives indicator (icon)
    local offensiveIcons = I.CreateAura_Icons(button:GetName().."OffensiveIcons", button.overlayFrame, 5)
    button.offensiveIcons = offensiveIcons
    offensiveIcons:Show()
    for i = 1, 5 do
        hooksecurefunc(offensiveIcons[i], "SetCooldown", function(self, _, _, _, _, _, _, color, glow)
            ShowGlow(self, glow, color)
        end)
    end
    
    -- offensives indicator (glow)
    local offensiveGlow = I.CreateAura_Glow(button:GetName().."OffensiveGlow", button)
    button.offensiveGlow = offensiveGlow
end
U.QuickAssist_CreateIndicators = QuickAssist_CreateIndicators

local function AddonLoaded()
    for i = 1, 40 do
        QuickAssist_CreateIndicators(header[i])
    end
end
Cell:RegisterCallback("AddonLoaded", "QuickAssist_AddonLoaded", AddonLoaded)

local function UpdatePixelPerfect()
    for i = 1, 40 do
        header[i]:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = P:Scale(CELL_BORDER_SIZE)})
        header[i]:SetBackdropBorderColor(unpack(CELL_BORDER_COLOR))

        header[i].healthBar:SetPoint("TOPLEFT", header[i], "TOPLEFT", P:Scale(1), P:Scale(-1))
        header[i].healthBar:SetPoint("BOTTOMRIGHT", header[i], "BOTTOMRIGHT", P:Scale(-1), P:Scale(1))
    end
end
Cell:RegisterCallback("UpdatePixelPerfect", "QuickAssist_UpdatePixelPerfect", UpdatePixelPerfect)

-- ----------------------------------------------------------------------- --
--                            filter auto switch                           --
-- ----------------------------------------------------------------------- --
local delayedFrame = CreateFrame("Frame")
delayedFrame:SetScript("OnEvent", function()
    delayedFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
    Cell:Fire("UpdateQuickAssist")
end)

local function PreUpdateQuickAssist()
    if Cell.vars.instanceType == "pvp" then
        Cell.vars.quickAssistGroupType = "battleground"
    elseif Cell.vars.instanceType == "arena" then
        Cell.vars.quickAssistGroupType = "arena"
    else
        if Cell.vars.groupType == "party" then
            Cell.vars.quickAssistGroupType = "party"
        elseif Cell.vars.groupType == "raid" then
            if Cell.vars.inMythic then
                Cell.vars.quickAssistGroupType = "mythic"
            else
                Cell.vars.quickAssistGroupType = "raid"
            end
        else
            Cell.vars.quickAssistGroupType = nil
        end
    end

    if InCombatLockdown() then
        delayedFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    else
        Cell:Fire("UpdateQuickAssist")
    end
end
Cell:RegisterCallback("EnterInstance", "QuickAssist_EnterInstance", PreUpdateQuickAssist)
Cell:RegisterCallback("LeaveInstance", "QuickAssist_LeaveInstance", PreUpdateQuickAssist)
Cell:RegisterCallback("GroupTypeChanged", "QuickAssist_GroupTypeChanged", PreUpdateQuickAssist)
Cell:RegisterCallback("SpecChanged", "QuickAssist_SpecChanged", PreUpdateQuickAssist)
