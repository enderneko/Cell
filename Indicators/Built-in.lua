local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local I = Cell.iFuncs
local P = Cell.pixelPerfectFuncs

local LCG = LibStub("LibCustomGlow-1.0")
local LibTranslit = LibStub("LibTranslit-1.0")

-------------------------------------------------
-- shared functions
-------------------------------------------------
local function Cooldowns_SetSize(self, width, height)
    self.width = width
    self.height = height

    for i = 1, #self do
        self[i]:SetSize(width, height)
    end

    self:UpdateSize()
end

local function Cooldowns_UpdateSize(self, iconsShown)
    if not (self.width and self.height and self.orientation) then return end -- not init
    
    if iconsShown then -- call from I:UnitButton_UpdateBuffs or preview
        for i = iconsShown + 1, #self do
            self[i]:Hide()
        end
        if iconsShown ~= 0 then
            if self.orientation == "horizontal" then
                self:_SetSize(self.width*iconsShown-P:Scale(iconsShown-1), self.height)
            else
                self:_SetSize(self.width, self.height*iconsShown-P:Scale(iconsShown-1))
            end
        end
    else
        for i = 1, #self do
            if self[i]:IsShown() then
                if self.orientation == "horizontal" then
                    self:_SetSize(self.width*i-P:Scale(i-1), self.height)
                else
                    self:_SetSize(self.width, self.height*i-P:Scale(i-1))
                end
            end
        end
    end
end

local function Cooldowns_UpdateSize_WithSpacing(self, iconsShown)
    if not (self.width and self.height and self.orientation) then return end -- not init
    
    if iconsShown then -- call from I:UnitButton_UpdateBuffs or preview
        for i = iconsShown + 1, #self do
            self[i]:Hide()
        end
        if iconsShown ~= 0 then
            if self.orientation == "horizontal" then
                self:_SetSize(self.width * iconsShown + P:Scale(iconsShown - 1), self.height)
            else
                self:_SetSize(self.width, self.height * iconsShown + P:Scale(iconsShown - 1))
            end
        end
    else
        for i = 1, #self do
            if self[i]:IsShown() then
                if self.orientation == "horizontal" then
                    self:_SetSize(self.width * i + P:Scale(i - 1), self.height)
                else
                    self:_SetSize(self.width, self.height * i + P:Scale(i - 1))
                end
            end
        end
    end
end

local function Cooldowns_SetBorder(self, border)
    for i = 1, #self do
        self[i]:SetBorder(border)
    end
end

local function Cooldowns_SetFont(self, ...)
    for i = 1, #self do
        self[i]:SetFont(...)
    end
end

local function Cooldowns_ShowDuration(self, show)
    for i = 1, #self do
        self[i]:ShowDuration(show)
    end
end

local function Cooldowns_UpdatePixelPerfect(self)
    P:Repoint(self)
    for i = 1, #self do
        self[i]:UpdatePixelPerfect()
    end
end

local function Cooldowns_SetOrientation(self, orientation)
    local point1, point2, x, y
    
    if orientation == "left-to-right" then
        point1 = "TOPLEFT"
        point2 = "TOPRIGHT"
        self.orientation = "horizontal"
        x = -1
        y = 0
    elseif orientation == "right-to-left" then
        point1 = "TOPRIGHT"
        point2 = "TOPLEFT"
        self.orientation = "horizontal"
        x = 1
        y = 0
    elseif orientation == "top-to-bottom" then
        point1 = "TOPLEFT"
        point2 = "BOTTOMLEFT"
        self.orientation = "vertical"
        x = 0
        y = 1
    elseif orientation == "bottom-to-top" then
        point1 = "BOTTOMLEFT"
        point2 = "TOPLEFT"
        self.orientation = "vertical"
        x = 0
        y = -1
    end
    
    for i = 1, #self do
        P:ClearPoints(self[i])
        if i == 1 then
            P:Point(self[i], point1)
        else
            P:Point(self[i], point1, self[i-1], point2, x, y)
        end
    end

    self:UpdateSize()
end

local function Cooldowns_SetOrientation_WithSpacing(self, orientation)
    local point1, point2, x, y

    if orientation == "left-to-right" then
        point1 = "TOPLEFT"
        point2 = "TOPRIGHT"
        self.orientation = "horizontal"
        x = 1
        y = 0
    elseif orientation == "right-to-left" then
        point1 = "TOPRIGHT"
        point2 = "TOPLEFT"
        self.orientation = "horizontal"
        x = -1
        y = 0
    elseif orientation == "top-to-bottom" then
        point1 = "TOPLEFT"
        point2 = "BOTTOMLEFT"
        self.orientation = "vertical"
        x = 0
        y = -1
    elseif orientation == "bottom-to-top" then
        point1 = "BOTTOMLEFT"
        point2 = "TOPLEFT"
        self.orientation = "vertical"
        x = 0
        y = 1
    end
    
    for i = 1, #self do
        P:ClearPoints(self[i])
        if i == 1 then
            P:Point(self[i], point1)
        else
            P:Point(self[i], point1, self[i-1], point2, x, y)
        end
    end

    self:UpdateSize()
end

-------------------------------------------------
-- CreateDefensiveCooldowns
-------------------------------------------------
function I:CreateDefensiveCooldowns(parent)
    local defensiveCooldowns = CreateFrame("Frame", parent:GetName().."DefensiveCooldownParent", parent.widget.overlayFrame)
    parent.indicators.defensiveCooldowns = defensiveCooldowns
    -- defensiveCooldowns:SetSize(20, 10)
    defensiveCooldowns:Hide()

    defensiveCooldowns._SetSize = defensiveCooldowns.SetSize
    defensiveCooldowns.SetSize = Cooldowns_SetSize
    defensiveCooldowns.UpdateSize = Cooldowns_UpdateSize
    defensiveCooldowns.SetFont = Cooldowns_SetFont
    defensiveCooldowns.SetOrientation = Cooldowns_SetOrientation
    defensiveCooldowns.ShowDuration = Cooldowns_ShowDuration
    defensiveCooldowns.UpdatePixelPerfect = Cooldowns_UpdatePixelPerfect

    for i = 1, 5 do
        local name = parent:GetName().."DefensiveCooldown"..i
        local frame = I:CreateAura_BarIcon(name, defensiveCooldowns)
        tinsert(defensiveCooldowns, frame)
    end
end

-------------------------------------------------
-- CreateExternalCooldowns
-------------------------------------------------
function I:CreateExternalCooldowns(parent)
    local externalCooldowns = CreateFrame("Frame", parent:GetName().."ExternalCooldownParent", parent.widget.overlayFrame)
    parent.indicators.externalCooldowns = externalCooldowns
    externalCooldowns:Hide()

    externalCooldowns._SetSize = externalCooldowns.SetSize
    externalCooldowns.SetSize = Cooldowns_SetSize
    externalCooldowns.UpdateSize = Cooldowns_UpdateSize
    externalCooldowns.SetFont = Cooldowns_SetFont
    externalCooldowns.SetOrientation = Cooldowns_SetOrientation
    externalCooldowns.ShowDuration = Cooldowns_ShowDuration
    externalCooldowns.UpdatePixelPerfect = Cooldowns_UpdatePixelPerfect

    for i = 1, 5 do
        local name = parent:GetName().."ExternalCooldown"..i
        local frame = I:CreateAura_BarIcon(name, externalCooldowns)
        tinsert(externalCooldowns, frame)
    end
end

-------------------------------------------------
-- CreateAllCooldowns
-------------------------------------------------
function I:CreateAllCooldowns(parent)
    local allCooldowns = CreateFrame("Frame", parent:GetName().."AllCooldownParent", parent.widget.overlayFrame)
    parent.indicators.allCooldowns = allCooldowns
    allCooldowns:Hide()

    allCooldowns._SetSize = allCooldowns.SetSize
    allCooldowns.SetSize = Cooldowns_SetSize
    allCooldowns.UpdateSize = Cooldowns_UpdateSize
    allCooldowns.SetFont = Cooldowns_SetFont
    allCooldowns.SetOrientation = Cooldowns_SetOrientation
    allCooldowns.ShowDuration = Cooldowns_ShowDuration
    allCooldowns.UpdatePixelPerfect = Cooldowns_UpdatePixelPerfect

    for i = 1, 5 do
        local name = parent:GetName().."ExternalCooldown"..i
        local frame = I:CreateAura_BarIcon(name, allCooldowns)
        tinsert(allCooldowns, frame)
    end
end

-------------------------------------------------
-- CreateTankActiveMitigation
-------------------------------------------------
function I:CreateTankActiveMitigation(parent)
    local bar = Cell:CreateStatusBar(parent:GetName().."TanckActiveMitigation", parent.widget.overlayFrame, 20, 6, 100)
    parent.indicators.tankActiveMitigation = bar
    bar:Hide()
    
    bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    bar:GetStatusBarTexture():SetAlpha(0)
    bar:SetReverseFill(true)

    local tex = bar:CreateTexture(nil, "BORDER", nil, -1)
    bar.tex = tex
    tex:SetColorTexture(F:GetClassColor(Cell.vars.playerClass))
    tex:SetPoint("TOPLEFT")
    tex:SetPoint("BOTTOMRIGHT", bar:GetStatusBarTexture(), "BOTTOMLEFT")

    local elapsedTime = 0
    bar:SetScript("OnUpdate", function(self, elapsed)
        if elapsedTime >= 0.1 then
            bar:SetValue(bar:GetValue() + elapsedTime)
            elapsedTime = 0
        end
        elapsedTime = elapsedTime + elapsed
    end)

    function bar:SetCooldown(start, duration)
        if bar.cType == "class_color" then
            if not parent.state.class then parent.state.class = UnitClassBase(parent.state.unit) end --? why sometimes parent.state.class == nil ???
            tex:SetColorTexture(F:GetClassColor(parent.state.class))
        else
            tex:SetColorTexture(bar.cTable[1], bar.cTable[2], bar.cTable[3])
        end
        bar:SetMinMaxValues(0, duration)
        bar:SetValue(GetTime()-start)
        bar:Show()
    end

    function bar:SetColor(cType, cTable)
        bar.cType = cType
        bar.cTable = cTable
    end
end

-------------------------------------------------
-- CreateDebuffs
-------------------------------------------------
local function Debuffs_SetSize(self, normalSize, bigSize)
    for i = 1, 10 do
        P:Size(self[i], normalSize[1], normalSize[2])
    end
    -- store sizes for SetCooldown
    self.normalSize = normalSize
    self.bigSize = bigSize
    -- remove wrong data from PixelPerfect
    self.width = nil
    self.height = nil

    self:UpdateSize()
end

local function Debuffs_UpdateSize(self, iconsShown)
    if not (self.normalSize and self.bigSize and self.orientation) then return end -- not init

    if iconsShown then
        for i = iconsShown + 1, 10 do
            self[i]:Hide()
        end
    end

    local size = 0
    for i = 1, 10 do
        if self[i]:IsShown() then
            size = size + self[i].width
        end
    end
    if self.orientation == "left-to-right" or self.orientation == "right-to-left"  then
        self:_SetSize(P:Scale(size), P:Scale(self.normalSize[2]))
    else
        self:_SetSize(P:Scale(self.normalSize[1]), P:Scale(size))
    end
end

local function Debuffs_SetFont(self, ...)
    for i = 1, 10 do
        self[i]:SetFont(...)
    end
end

local function Debuffs_SetPoint(self, point, relativeTo, relativePoint, x, y)
    self:_SetPoint(point, relativeTo, relativePoint, x, y)

    if string.find(point, "LEFT$") then
        self.hAlignment = "LEFT"
    elseif string.find(point, "RIGHT$") then
        self.hAlignment = "RIGHT"
    else
        self.hAlignment = ""
    end

    if string.find(point, "^TOP") then
        self.vAlignment = "TOP"
    elseif string.find(point, "^BOTTOM") then
        self.vAlignment = "BOTTOM"
    else
        self.vAlignment = ""
    end

    if self.hAlignment == "" and self.vAlignment == "" then
        self.vAlignment = "CENTER"
    end

    -- self[1]:ClearAllPoints()
    -- self[1]:SetPoint(self.vAlignment..self.hAlignment)
    -- --! update icons
    self:SetOrientation(self.orientation or "left-to-right")
end

--! NOTE: SetPoint must be invoked before SetOrientation
local function Debuffs_SetOrientation(self, orientation)
    self.orientation = orientation
    local point1, point2, v, h
    v = self.vAlignment == "CENTER" and "" or self.vAlignment
    h = self.hAlignment
    if orientation == "left-to-right" then
        point1 = v.."LEFT"
        point2 = v.."RIGHT"
    elseif orientation == "right-to-left" then
        point1 = v.."RIGHT"
        point2 = v.."LEFT"
    elseif orientation == "top-to-bottom" then
        point1 = "TOP"..h
        point2 = "BOTTOM"..h
    elseif orientation == "bottom-to-top" then
        point1 = "BOTTOM"..h
        point2 = "TOP"..h
    end
    
    for i = 1, 10 do
        P:ClearPoints(self[i])
        if i == 1 then
            P:Point(self[i], point1)
        else
            P:Point(self[i], point1, self[i-1], point2)
        end
    end

    self:UpdateSize()
end

local function Debuffs_ShowDuration(self, show)
    for i = 1, 10 do
        self[i]:ShowDuration(show)
    end
end

local function Debuffs_UpdatePixelPerfect(self)
    P:Repoint(self)
    for i = 1, 10 do
        self[i]:UpdatePixelPerfect()
    end
end

function I:CreateDebuffs(parent)
    local debuffs = CreateFrame("Frame", parent:GetName().."DebuffParent", parent.widget.overlayFrame)
    parent.indicators.debuffs = debuffs
    -- debuffs:SetSize(11, 11)
    debuffs:Hide()

    debuffs._SetSize = debuffs.SetSize
    debuffs.SetSize = Debuffs_SetSize
    debuffs.UpdateSize = Debuffs_UpdateSize
    debuffs.SetFont = Debuffs_SetFont

    debuffs.hAlignment = ""
    debuffs.vAlignment = ""
    debuffs._SetPoint = debuffs.SetPoint
    debuffs.SetPoint = Debuffs_SetPoint
    debuffs.SetOrientation = Debuffs_SetOrientation

    debuffs.ShowDuration = Debuffs_ShowDuration
    debuffs.UpdatePixelPerfect = Debuffs_UpdatePixelPerfect

    function debuffs:ShowTooltip(show)
        for i = 1, 10 do
            if show then
                debuffs[i]:SetScript("OnEnter", function()
                    F:ShowTooltips(parent, "spell", parent.state.displayedUnit, debuffs[i].index, "HARMFUL")
                end)
                debuffs[i]:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
            else
                debuffs[i]:SetScript("OnEnter", nil)
                debuffs[i]:SetScript("OnLeave", nil)
                debuffs[i]:EnableMouse(false)
            end
        end
    end

    for i = 1, 10 do
        local name = parent:GetName().."Debuff"..i
        local frame = I:CreateAura_BarIcon(name, debuffs)
        tinsert(debuffs, frame)

        frame._SetCooldown = frame.SetCooldown
        function frame:SetCooldown(start, duration, debuffType, texture, count, refreshing, isBigDebuff)
            frame:_SetCooldown(start, duration, debuffType, texture, count, refreshing)
            if isBigDebuff then
                P:Size(frame, debuffs.bigSize[1], debuffs.bigSize[2])
            else
                P:Size(frame, debuffs.normalSize[1], debuffs.normalSize[2])
            end
        end
    end
end

-------------------------------------------------
-- CreateDispels
-------------------------------------------------
local function Dispels_SetSize(self, width, height)
    self.width = width
    self.height = height

    self:_SetSize(width, height)
    for i = 1, 5 do
        self[i]:SetSize(width, height)
    end

    if self._orientation then
        self:SetOrientation(self._orientation)            
    else
        self:UpdateSize()
    end
end

local function Dispels_UpdateSize(self, iconsShown)
    if not (self.orientation and self.width and self.height) then return end
        
    local width, height = self.width, self.height
    if iconsShown then -- SetDispels
        iconsShown = iconsShown - 1
        if self.orientation == "horizontal"  then
            width = self.width + (iconsShown - 1) * floor(self.width / 2)
            height = self.height
        else
            width = self.width
            height = self.height + (iconsShown - 1) * floor(self.height / 2)
        end
    else
        for i = 1, 5 do
            if self[i]:IsShown() then
                if self.orientation == "horizontal"  then
                    width = self.width + (i - 1) * floor(self.width / 2)
                    height = self.height
                else
                    width = self.width
                    height = self.height + (i - 1) * floor(self.height / 2)
                end
            end
        end
    end

    self:_SetSize(width, height)
end

local dispelOrder = {"Magic", "Curse", "Disease", "Poison", "Bleed"}
local function Dispels_SetDispels(self, dispelTypes)
    local r, g, b = 0, 0, 0
    local found

    self.highlight:Hide()

    local i = 0
    for _, dispelType in ipairs(dispelOrder) do
        local showHighlight = dispelTypes[dispelType]
        if type(showHighlight) == "boolean" then
            -- highlight
            if not found and self.highlightType ~= "none" and dispelType and showHighlight then
                found = true
                local r, g, b = I:GetDebuffTypeColor(dispelType)
                if self.highlightType == "entire" then
                    self.highlight:SetVertexColor(r, g, b, 0.5)
                elseif self.highlightType == "current" then
                    self.highlight:SetVertexColor(r, g, b, 1)
                elseif self.highlightType == "gradient" or self.highlightType == "gradient-half" then
                    self.highlight:SetGradient("VERTICAL", CreateColor(r, g, b, 1), CreateColor(r, g, b, 0))
                end
                self.highlight:Show()
            end
            -- icons
            if self.showIcons then
                i = i + 1
                self[i]:SetDispel(dispelType)
            end
        end
    end

    self:UpdateSize(i)

    -- hide unused
    for j = i+1, 5 do
        self[j]:Hide()
    end
end

local function Dispels_ShowIcons(self, show)
    self.showIcons = show
end

--! SetSize must be invoked before this
local function Dispels_SetOrientation(self, orientation)
    self._orientation = orientation
    local point, x, y
    if orientation == "left-to-right" then
        point = "TOPLEFT"
        x = floor(self.width / 2)
        y = 0
        self.orientation = "horizontal"
    elseif orientation == "right-to-left" then
        point = "TOPRIGHT"
        x = -floor(self.width / 2)
        y = 0
        self.orientation = "horizontal"
    elseif orientation == "top-to-bottom" then
        point = "TOPLEFT"
        x = 0
        y = -floor(self.height / 2)
        self.orientation = "vertical"
    elseif orientation == "bottom-to-top" then
        point = "BOTTOMLEFT"
        x = 0
        y = floor(self.height / 2)
        self.orientation = "vertical"
    end
    
    for i = 1, 5 do
        self[i]:ClearAllPoints()
        if i == 1 then
            self[i]:SetPoint(point)
        else
            self[i]:SetPoint(point, self[i-1], point, x, y)
        end
    end

    self:UpdateSize()
end

function I:CreateDispels(parent)
    local dispels = CreateFrame("Frame", parent:GetName().."DispelParent", parent.widget.overlayFrame)
    parent.indicators.dispels = dispels
    dispels:Hide()

    dispels:SetScript("OnHide", function()
        dispels.highlight:Hide()
    end)

    dispels.highlight = parent.widget.healthBar:CreateTexture(parent:GetName().."DispelHighlight", "OVERLAY")
    dispels.highlight:Hide()

    dispels._SetSize = dispels.SetSize
    dispels.SetSize = Dispels_SetSize
    dispels.UpdateSize = Dispels_UpdateSize
    dispels.SetDispels = Dispels_SetDispels
    -- dispels.UpdateHighlight = Dispels_UpdateHighlight
    dispels.ShowIcons = Dispels_ShowIcons
    dispels.SetOrientation = Dispels_SetOrientation

    function dispels:UpdateHighlight(highlightType)
        dispels.highlightType = highlightType

        if highlightType == "none" then
            dispels.highlight:Hide()
        elseif highlightType == "gradient" then
            dispels.highlight:ClearAllPoints()
            dispels.highlight:SetAllPoints(parent.widget.healthBar)
            dispels.highlight:SetTexture("Interface\\Buttons\\WHITE8x8")
        elseif highlightType == "gradient-half" then
            dispels.highlight:ClearAllPoints()
            dispels.highlight:SetPoint("BOTTOMLEFT", parent.widget.healthBar)
            dispels.highlight:SetPoint("TOPRIGHT", parent.widget.healthBar, "RIGHT")
            dispels.highlight:SetTexture("Interface\\Buttons\\WHITE8x8")
        elseif highlightType == "entire" then
            dispels.highlight:ClearAllPoints()
            dispels.highlight:SetAllPoints(parent.widget.healthBar)
            dispels.highlight:SetTexture("Interface\\Buttons\\WHITE8x8")
        elseif highlightType == "current" then
            dispels.highlight:ClearAllPoints()
            dispels.highlight:SetAllPoints(parent.widget.healthBar:GetStatusBarTexture())
            dispels.highlight:SetTexture(Cell.vars.texture)
        end
    end

    for i = 1, 5 do
        local icon = dispels:CreateTexture(parent:GetName().."Dispel"..i, "ARTWORK")
        tinsert(dispels, icon)
        icon:Hide()

        icon:SetDrawLayer("ARTWORK", 6-i)

        function icon:SetDispel(dispelType)
            -- icon:SetTexture("Interface\\RaidFrame\\Raid-Icon-Debuff"..dispelType)
            icon:SetTexture("Interface\\AddOns\\Cell\\Media\\Debuffs\\"..dispelType)
            icon:Show()
        end
    end
end

-------------------------------------------------
-- CreateRaidDebuffs
-------------------------------------------------
local currentAreaDebuffs = {}
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

local function UpdateDebuffsForCurrentZone(instanceName)
    wipe(currentAreaDebuffs)
    local iName = F:GetInstanceName()
    if iName == "" then return end
    
    if iName == instanceName or instanceName == nil then
        currentAreaDebuffs = F:GetDebuffList(iName)
        F:Debug("|cffff77AARaidDebuffsChanged:|r", iName)
    end
end
Cell:RegisterCallback("RaidDebuffsChanged", "UpdateDebuffsForCurrentZone", UpdateDebuffsForCurrentZone)
eventFrame:SetScript("OnEvent", function()
    UpdateDebuffsForCurrentZone()
end)

local function CheckCondition(operator, checkedValue, currentValue)
    if operator == "=" then
        if currentValue == checkedValue then return true end
    elseif operator == ">" then
        if currentValue > checkedValue then return true end
    elseif operator == ">=" then
        if currentValue >= checkedValue then return true end
    elseif operator == "<" then
        if currentValue < checkedValue then return true end
    elseif operator == "<=" then
        if currentValue <= checkedValue then return true end
    else -- ~=
        if currentValue ~= checkedValue then return true end
    end
end

function I:GetDebuffOrder(spellName, spellId, count)
    local t = currentAreaDebuffs[spellId] or currentAreaDebuffs[spellName]
    if not t then return end

    -- check condition
    local show
    if t["condition"][1] == "Stack" then
        show = CheckCondition(t["condition"][2], t["condition"][3], count)
    else -- no condition
        show = true
    end

    if show then return t["order"] end
end

function I:GetDebuffGlow(spellName, spellId, count)
    local t = currentAreaDebuffs[spellId] or currentAreaDebuffs[spellName]
    if not t then return end

    local showGlow
    if t["glowCondition"] then
        if t["glowCondition"][1] == "Stack" then
            showGlow = CheckCondition(t["glowCondition"][2], t["glowCondition"][3], count)
        end
    else
        showGlow = true
    end

    if showGlow then
        return t["glowType"], t["glowOptions"]
    else
        return "None", nil
    end
end

function I:CreateRaidDebuffs(parent)
    local raidDebuffs = CreateFrame("Frame", parent:GetName().."RaidDebuffParent", parent.widget.overlayFrame)
    parent.indicators.raidDebuffs = raidDebuffs
    raidDebuffs:Hide()

    function raidDebuffs:ShowGlow(glowType, glowOptions, noHiding)
        if glowType == "Normal" then
            if not noHiding then
                LCG.PixelGlow_Stop(parent)
                LCG.AutoCastGlow_Stop(parent)
                LCG.ProcGlow_Stop(parent)
            end
            LCG.ButtonGlow_Start(parent, glowOptions[1])
        elseif glowType == "Pixel" then
            if not noHiding then
                LCG.ButtonGlow_Stop(parent)
                LCG.AutoCastGlow_Stop(parent)
                LCG.ProcGlow_Stop(parent)
            end
            -- color, N, frequency, length, thickness
            LCG.PixelGlow_Start(parent, glowOptions[1], glowOptions[2], glowOptions[3], glowOptions[4], glowOptions[5])
        elseif glowType == "Shine" then
            if not noHiding then
                LCG.ButtonGlow_Stop(parent)
                LCG.PixelGlow_Stop(parent)
                LCG.ProcGlow_Stop(parent)
            end
            -- color, N, frequency, scale
            LCG.AutoCastGlow_Start(parent, glowOptions[1], glowOptions[2], glowOptions[3], glowOptions[4])
        elseif glowType == "Proc" then
            if not noHiding then
                LCG.ButtonGlow_Stop(parent)
                LCG.PixelGlow_Stop(parent)
                LCG.AutoCastGlow_Stop(parent)
            end
            -- color, duration
            LCG.ProcGlow_Start(parent, {color=glowOptions[1], duration=glowOptions[2], startAnim=false})
        else
            LCG.ButtonGlow_Stop(parent)
            LCG.PixelGlow_Stop(parent)
            LCG.AutoCastGlow_Stop(parent)
        end
    end

    function raidDebuffs:HideGlow(glowType)
        if not glowType then
            -- hide all
            LCG.ButtonGlow_Stop(parent)
            LCG.PixelGlow_Stop(parent)
            LCG.AutoCastGlow_Stop(parent)
        else
            if glowType == "Normal" then
                LCG.ButtonGlow_Stop(parent)
            elseif glowType == "Pixel" then
                LCG.PixelGlow_Stop(parent)
            elseif glowType == "Shine" then
                LCG.AutoCastGlow_Stop(parent)
            end
        end
    end

    raidDebuffs:SetScript("OnHide", function()
        LCG.ButtonGlow_Stop(parent)
        LCG.PixelGlow_Stop(parent)
        LCG.AutoCastGlow_Stop(parent)
    end)

    raidDebuffs._SetSize = raidDebuffs.SetSize
    raidDebuffs.SetSize = Cooldowns_SetSize
    raidDebuffs.SetBorder = Cooldowns_SetBorder
    raidDebuffs.UpdateSize = Cooldowns_UpdateSize_WithSpacing
    raidDebuffs.SetOrientation = Cooldowns_SetOrientation_WithSpacing
    raidDebuffs.SetFont = Cooldowns_SetFont
    raidDebuffs.UpdatePixelPerfect = Cooldowns_UpdatePixelPerfect

    function raidDebuffs:ShowTooltip(show)
        for i = 1, 3 do
            if show then
                raidDebuffs[i]:SetScript("OnEnter", function()
                    F:ShowTooltips(parent, "spell", parent.state.displayedUnit, raidDebuffs[i].index, "HARMFUL")
                end)
                raidDebuffs[i]:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
            else
                raidDebuffs[i]:SetScript("OnEnter", nil)
                raidDebuffs[i]:SetScript("OnLeave", nil)
                raidDebuffs[i]:EnableMouse(false)
            end
        end
    end

    for i = 1, 3 do
        local frame = I:CreateAura_BorderIcon(parent:GetName().."RaidDebuff"..i, raidDebuffs, 2)
        tinsert(raidDebuffs, frame)
        frame:SetScript("OnShow", raidDebuffs.UpdateSize)
        frame:SetScript("OnHide", raidDebuffs.UpdateSize)
    end
end

-------------------------------------------------
-- private auras
-------------------------------------------------
local function PrivateAuras_UpdatePrivateAuraAnchor(self, unit)
    -- remove old
    if self.auraAnchorID then
        C_UnitAuras.RemovePrivateAuraAnchor(self.auraAnchorID)
        self.unit = nil
        self.auraAnchorID = nil
    end

    -- add new
    if unit then
        local _showCountdownFrame, _showCountdownNumbers = true, false
        if type(self.showCountdownFrame) == "boolean" then _showCountdownFrame = self.showCountdownFrame end
        if type(self.showCountdownNumbers) == "boolean" then _showCountdownNumbers = self.showCountdownNumbers end

        self.unit = unit
        self.auraAnchorID = C_UnitAuras.AddPrivateAuraAnchor({
            unitToken = unit,
            auraIndex = 1,
            parent = self,
            showCountdownFrame = _showCountdownFrame,
            showCountdownNumbers = _showCountdownNumbers,
            iconInfo = {
                iconWidth = self:GetWidth(),
                iconHeight = self:GetHeight(),
                iconAnchor = {
                    point = "CENTER",
                    relativeTo = self,
                    relativePoint = "CENTER",
                    offsetX = 0,
                    offsetY = 0,
                },
            },
            -- durationAnchor = {
            --     point = "BOTTOMRIGHT",
            --     relativeTo = self,
            --     relativePoint = "BOTTOMRIGHT",
            --     offsetX = 0,
            --     offsetY = 0,
            -- },
        })
    end
end

function I:CreatePrivateAuras(parent)
    local privateAuras = CreateFrame("Frame", parent:GetName().."PrivateAuraParent", parent.widget.overlayFrame)
    parent.indicators.privateAuras = privateAuras
    privateAuras:Hide()

    privateAuras.UpdatePrivateAuraAnchor = PrivateAuras_UpdatePrivateAuraAnchor
    privateAuras._SetSize = privateAuras.SetSize

    function privateAuras:SetSize(width, height)
        privateAuras:_SetSize(width, height)
        privateAuras:UpdatePrivateAuraAnchor(privateAuras.unit)
    end

    function privateAuras:UpdateOptions(t)
        self.showCountdownFrame = t[1]
        self.showCountdownNumbers = t[2]
        privateAuras:UpdatePrivateAuraAnchor(privateAuras.unit)
    end
end

-------------------------------------------------
-- player raid icon
-------------------------------------------------
function I:CreatePlayerRaidIcon(parent)
    -- local playerRaidIcon = parent.widget.overlayFrame:CreateTexture(parent:GetName().."PlayerRaidIcon", "ARTWORK", nil, -7)
    -- parent.indicators.playerRaidIcon = playerRaidIcon
    -- playerRaidIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    local playerRaidIcon = CreateFrame("Frame", parent:GetName().."PlayerRaidIcon", parent.widget.overlayFrame)
    parent.indicators.playerRaidIcon = playerRaidIcon
    playerRaidIcon.tex = playerRaidIcon:CreateTexture(nil, "ARTWORK")
    playerRaidIcon.tex:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    playerRaidIcon.tex:SetAllPoints(playerRaidIcon)
    playerRaidIcon:Hide()
end

-------------------------------------------------
-- target raid icon
-------------------------------------------------
function I:CreateTargetRaidIcon(parent)
    local targetRaidIcon = CreateFrame("Frame", parent:GetName().."TargetRaidIcon", parent.widget.overlayFrame)
    parent.indicators.targetRaidIcon = targetRaidIcon
    targetRaidIcon.tex = targetRaidIcon:CreateTexture(nil, "ARTWORK")
    targetRaidIcon.tex:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    targetRaidIcon.tex:SetAllPoints(targetRaidIcon)
    targetRaidIcon:Hide()
end

-------------------------------------------------
-- name text
-------------------------------------------------
local font_name = CreateFont("CELL_FONT_NAME")
font_name:SetFont(GameFontNormal:GetFont(), 13, "")

local font_status = CreateFont("CELL_FONT_STATUS")
font_status:SetFont(GameFontNormal:GetFont(), 11, "")

function I:CreateNameText(parent)
    local nameText = CreateFrame("Frame", parent:GetName().."NameText", parent.widget.overlayFrame)
    parent.indicators.nameText = nameText
    nameText:Hide()

    nameText.name = nameText:CreateFontString(parent:GetName().."NameText_Name", "OVERLAY", "CELL_FONT_NAME")
    
    nameText.vehicle = nameText:CreateFontString(parent:GetName().."NameText_Vehicle", "OVERLAY", "CELL_FONT_STATUS")
    nameText.vehicle:SetTextColor(0.8, 0.8, 0.8, 1)
    nameText.vehicle:Hide()

    nameText:SetScript("OnShow", function()
        if nameText.vehicleEnabled then
            nameText.vehicle:Show()
        end
    end)
    nameText:SetScript("OnHide", function()
        nameText.vehicle:Hide()
    end)

    function nameText:SetFont(font, size, flags)
        nameText.flags = flags
        font = F:GetFont(font)

        if flags == "Shadow" then
            nameText.name:SetFont(font, size, "")
            nameText.name:SetShadowOffset(1, -1)
            nameText.name:SetShadowColor(0, 0, 0, 1)
            nameText.vehicle:SetFont(font, size-2, "")
            nameText.vehicle:SetShadowOffset(1, -1)
            nameText.vehicle:SetShadowColor(0, 0, 0, 1)
        else
            if flags == "None" then
                flags = ""
            elseif flags == "Outline" then
                flags = "OUTLINE"
            else
                flags = "OUTLINE,MONOCHROME"
            end
            nameText.name:SetFont(font, size, flags)
            nameText.name:SetShadowOffset(0, 0)
            nameText.name:SetShadowColor(0, 0, 0, 0)
            nameText.vehicle:SetFont(font, size-2, flags)
            nameText.vehicle:SetShadowOffset(0, 0)
            nameText.vehicle:SetShadowColor(0, 0, 0, 0)
        end

        nameText:UpdateName()
        if parent.state.inVehicle or nameText.isPreview then
            nameText:UpdateVehicleName()
        end
    end

    nameText._SetPoint = nameText.SetPoint
    function nameText:SetPoint(point, relativeTo, relativePoint, x, y)
        -- override relativeTo
        nameText:_SetPoint(point, parent.widget.healthBar, relativePoint, x, y)

        -- update name
        nameText.name:ClearAllPoints()
        nameText.name:SetPoint(point)

        -- update vehicle
        local vp, _, vrp, _, vy = nameText.vehicle:GetPoint(1)
        if vp and vrp and vy then
            if string.find(vp, "TOP") then
                vp, vrp = "TOP", "BOTTOM"
            else -- BOTTOM
                vp, vrp = "BOTTOM", "TOP"
            end

            nameText.vehicle:ClearAllPoints()
            if string.find(point, "LEFT") then
                nameText.vehicle:SetPoint(vp.."LEFT", nameText.name, vrp.."LEFT", 0, vy)
            elseif string.find(point, "RIGHT") then
                nameText.vehicle:SetPoint(vp.."RIGHT", nameText.name, vrp.."RIGHT", 0, vy)
            else -- "CENTER"
                nameText.vehicle:SetPoint(vp, nameText.name, vrp, 0, vy)
            end
        end
    end

    function nameText:UpdateName()
        local name

        -- patron rainbow
        if nameText.name.rainbow then
            nameText.name.updater:SetScript("OnUpdate", nil)
            if nameText.name.timer then
                nameText.name.timer:Cancel()
                nameText.name.timer = nil
            end
        end
        
        -- only check nickname for players
        if parent.state.isPlayer then
            if CELL_NICKTAG_ENABLED and Cell.NickTag then
                name = Cell.NickTag:GetNickname(parent.state.name, nil, true)
            end
            name = name or F:GetNickname(parent.state.name, parent.state.fullName)
        else
            name = parent.state.name
        end

        if Cell.loaded and CellDB["general"]["translit"] then
            name = LibTranslit:Transliterate(name)
        end

        F:UpdateTextWidth(nameText.name, name, nameText.width, parent.widget.healthBar)

        if CELL_SHOW_RAID_PET_OWNER_NAME and parent.isRaidPet then
            local owner = F:GetPlayerUnit(parent.state.unit)
            owner = UnitName(owner)
            if CELL_SHOW_RAID_PET_OWNER_NAME == "VEHICLE" then
                F:UpdateTextWidth(nameText.vehicle, owner, nameText.width, parent.widget.healthBar)
            elseif CELL_SHOW_RAID_PET_OWNER_NAME == "NAME" then
                F:UpdateTextWidth(nameText.name, owner, nameText.width, parent.widget.healthBar)
            end
        end

        if nameText.name:GetText() then
            if nameText.isPreview then
                if nameText.showGroupNumber then
                    nameText.name:SetText("|cffbbbbbb7-|r"..nameText.name:GetText())
                end
            else
                if IsInRaid() and nameText.showGroupNumber then
                    local raidIndex = UnitInRaid(parent.state.unit)
                    if raidIndex then
                        local subgroup = select(3, GetRaidRosterInfo(raidIndex))
                        -- nameText.name:SetText("|TInterface\\AddOns\\Cell\\Media\\Icons\\group"..subgroup..":0:0:0:-1:64:64:6:58:6:58|t"..nameText.name:GetText())
                        nameText.name:SetText("|cffbbbbbb"..subgroup.."-|r"..nameText.name:GetText())
                    end
                end
            end
        end

        nameText:SetSize(nameText.name:GetWidth(), nameText.name:GetHeight())
    end

    function nameText:UpdateVehicleName()
        F:UpdateTextWidth(nameText.vehicle, nameText.isPreview and L["vehicle name"] or UnitName(parent.state.displayedUnit), nameText.width, parent.widget.healthBar)
    end

    function nameText:UpdateVehicleNamePosition(pTable)
        local p = nameText:GetPoint(1) or ""
        if string.find(p, "LEFT") then
            p = "LEFT"
        elseif string.find(p, "RIGHT") then
            p = "RIGHT"
        else -- "CENTER"
            p = ""
        end

        nameText.vehicle:ClearAllPoints()
        if pTable[1] == "TOP" then
            nameText.vehicle:Show()
            nameText.vehicle:SetPoint("BOTTOM"..p, nameText.name, "TOP"..p, 0, pTable[2])
            nameText.vehicleEnabled = true
        elseif pTable[1] == "BOTTOM" then
            nameText.vehicle:Show()
            nameText.vehicle:SetPoint("TOP"..p, nameText.name, "BOTTOM"..p, 0, pTable[2])
            nameText.vehicleEnabled = true
        else -- Hide
            nameText.vehicle:Hide()
            nameText.vehicleEnabled = false
        end
    end

    function nameText:UpdateTextWidth(width)
        nameText.width = width
        
        nameText:UpdateName()

        if parent.state.inVehicle or nameText.isPreview then
            F:UpdateTextWidth(nameText.vehicle, nameText.isPreview and L["Vehicle Name"] or UnitName(parent.state.displayedUnit), width, parent.widget.healthBar)
        end
    end

    function nameText:UpdatePreviewColor(color)
        if color[1] == "class_color" then
            nameText.name:SetTextColor(F:GetClassColor(Cell.vars.playerClass))
        else
            nameText.name:SetTextColor(unpack(color[2]))
        end
    end

    function nameText:SetColor(r, g, b)
        nameText.name:SetTextColor(r, g, b)
    end

    function nameText:ShowGroupNumber(show)
        nameText.showGroupNumber = show
        nameText:UpdateName()
    end

    parent.widget.healthBar:SetScript("OnSizeChanged", function()
        if parent.state.name then
            nameText:UpdateName()
            
            if parent.state.inVehicle or nameText.isPreview then
                nameText:UpdateVehicleName()
            end
        end
    end)

    function nameText:UpdatePixelPerfect()
        if nameText.flags == "Shadow" then
            -- NOTE: remove then add shadows back
            nameText.name:SetShadowOffset(0, 0)
            nameText.vehicle:SetShadowOffset(0, 0)

            nameText.name:SetShadowOffset(1, -1)
            nameText.name:SetShadowColor(0, 0, 0, 1)
            nameText.vehicle:SetShadowOffset(1, -1)
            nameText.vehicle:SetShadowColor(0, 0, 0, 1)
        end
    end
end

-------------------------------------------------
-- status text
-------------------------------------------------
local function StatusText_SetFont(self, font, size, flags)
    self.flags = flags
    font = F:GetFont(font)

    if flags == "Shadow" then
        self.text:SetFont(font, size, "")
        self.text:SetShadowOffset(1, -1)
        self.text:SetShadowColor(0, 0, 0, 1)
        self.timer:SetFont(font, size, "")
        self.timer:SetShadowOffset(1, -1)
        self.timer:SetShadowColor(0, 0, 0, 1)
    else
        if flags == "None" then
            flags = ""
        elseif flags == "Outline" then
            flags = "OUTLINE"
        else
            flags = "OUTLINE,MONOCHROME"
        end
        self.text:SetFont(font, size, flags)
        self.text:SetShadowOffset(0, 0)
        self.text:SetShadowColor(0, 0, 0, 0)
        self.timer:SetFont(font, size, flags)
        self.timer:SetShadowOffset(0, 0)
        self.timer:SetShadowColor(0, 0, 0, 0)
    end

    self:SetHeight(self.text:GetHeight()+P:Scale(1)*2)
end

local startTimeCache = {}
function I:CreateStatusText(parent)
    local statusText = CreateFrame("Frame", parent:GetName().."StatusText", parent.widget.overlayFrame)
    parent.indicators.statusText = statusText
    statusText:SetIgnoreParentAlpha(true)
    statusText:Hide()

    statusText.bg = statusText:CreateTexture(nil, "ARTWORK")
    statusText.bg:SetTexture("Interface\\Buttons\\WHITE8x8")
    statusText.bg:SetGradient("HORIZONTAL", CreateColor(0, 0, 0, 0.777), CreateColor(0, 0, 0, 0))
    statusText.bg:SetAllPoints(statusText)

    -- statusText:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
    -- statusText:SetBackdropColor(0, 0, 0, 0.3)

    local text = statusText:CreateFontString(nil, "ARTWORK", "CELL_FONT_STATUS")
    statusText.text = text

    local timer = statusText:CreateFontString(nil, "ARTWORK", "CELL_FONT_STATUS")
    statusText.timer = timer
    
    function statusText:GetStatus()
        return statusText.status
    end

    function statusText:SetStatus(status)
        -- print("status: " .. (status or "nil"))
        statusText.status = status
        if status then
            text:SetText(L[status])
            text:SetTextColor(unpack(statusText.colors[status]))
            timer:SetTextColor(unpack(statusText.colors[status]))
            statusText:SetHeight(text:GetHeight()+P:Scale(1)*2)
        else
            statusText:Hide()
        end
    end

    function statusText:SetColors(colors)
        statusText.colors = colors
    end
    
    statusText._SetPoint = statusText.SetPoint
    function statusText:SetPoint(point, _, yOffset)
        statusText:ClearAllPoints()
        statusText:_SetPoint("LEFT", parent.widget.healthBar)
        statusText:_SetPoint("RIGHT", parent.widget.healthBar)
        statusText:_SetPoint(point, parent.widget.healthBar, 0, yOffset)

        text:ClearAllPoints()
        text:SetPoint(point.."LEFT")
        timer:ClearAllPoints()
        timer:SetPoint(point.."RIGHT")

        statusText:SetHeight(text:GetHeight()+P:Scale(1)*2)
    end
    
    statusText.SetFont = StatusText_SetFont

    function statusText:SetShowTimer(show)
        statusText.showTimer = show
    end

    function statusText:ShowBackground(show)
        if show then
            statusText.bg:Show()
        else
            statusText.bg:Hide()
        end
    end

    function statusText:ShowTimer()
        if not statusText.showTimer then
            statusText:HideTimer(true)
            return
        end

        timer:Show()
        if not startTimeCache[parent.state.guid] then startTimeCache[parent.state.guid] = GetTime() end
        
        statusText.ticker = C_Timer.NewTicker(1, function()
            if not parent.state.guid and parent.state.unit then -- ElvUI AFK mode
                parent.state.guid = UnitGUID(parent.state.unit)
            end
            if parent.state.guid and startTimeCache[parent.state.guid] then
                timer:SetFormattedText(F:FormatTime(GetTime() - startTimeCache[parent.state.guid]))
            else
                timer:SetText("")
            end
        end)
    end

    function statusText:HideTimer(reset)
        timer:Hide()
        timer:SetText("")
        if reset then
            if statusText.ticker then statusText.ticker:Cancel() end
            startTimeCache[parent.state.guid] = nil
        end
    end

    function statusText:UpdatePixelPerfect()
        if statusText.flags == "Shadow" then
            -- NOTE: remove then add shadows back
            text:SetShadowOffset(0, 0)
            timer:SetShadowOffset(0, 0)

            text:SetShadowOffset(1, -1)
            text:SetShadowColor(0, 0, 0, 1)
            timer:SetShadowOffset(1, -1)
            timer:SetShadowColor(0, 0, 0, 1)
        end
    end
end

-------------------------------------------------
-- health text
-------------------------------------------------
local function SetHealth_Percentage(self, current, max, totalAbsorbs)
    self.text:SetFormattedText("%d%%", current/max*100)
    self:SetWidth(self.text:GetStringWidth()+3)
end

local function SetHealth_Percentage_Absorbs(self, current, max, totalAbsorbs)
    if totalAbsorbs == 0 then
        self.text:SetFormattedText("%d%%", current/max*100)
    else
        self.text:SetFormattedText("%d%%+%d%%", current/max*100, totalAbsorbs/max*100)
    end
    self:SetWidth(self.text:GetStringWidth()+3)
end

local function SetHealth_Percentage_Absorbs_Merged(self, current, max, totalAbsorbs)
    self.text:SetFormattedText("%d%%", (current+totalAbsorbs)/max*100)
    self:SetWidth(self.text:GetStringWidth()+3)
end

local function SetHealth_Percentage_Deficit(self, current, max, totalAbsorbs)
    self.text:SetFormattedText("%d%%", (current-max)/max*100)
    self:SetWidth(self.text:GetStringWidth()+3)
end

local function SetHealth_Number(self, current, max, totalAbsorbs)
    self.text:SetText(current)
    self:SetWidth(self.text:GetStringWidth()+3)
end

local function SetHealth_Number_Short(self, current, max, totalAbsorbs)
    self.text:SetText(F:FormatNumber(current))
    self:SetWidth(self.text:GetStringWidth()+3)
end

local function SetHealth_Number_Absorbs_Short(self, current, max, totalAbsorbs)
    if totalAbsorbs == 0 then
        self.text:SetText(F:FormatNumber(current))
    else
        self.text:SetFormattedText("%s+%s", F:FormatNumber(current), F:FormatNumber(totalAbsorbs))
    end
    self:SetWidth(self.text:GetStringWidth()+3)
end

local function SetHealth_Number_Absorbs_Merged_Short(self, current, max, totalAbsorbs)
    self.text:SetText(F:FormatNumber(current+totalAbsorbs))
    self:SetWidth(self.text:GetStringWidth()+3)
end

local function SetHealth_Number_Deficit(self, current, max, totalAbsorbs)
    self.text:SetText(current-max)
    self:SetWidth(self.text:GetStringWidth()+3)
end

local function SetHealth_Number_Deficit_Short(self, current, max, totalAbsorbs)
    self.text:SetText(F:FormatNumber(current-max))
    self:SetWidth(self.text:GetStringWidth()+3)
end

local function SetHealth_Current_Short_Percentage(self, current, max, totalAbsorbs)
    self.text:SetFormattedText("%s %d%%", F:FormatNumber(current), (current/max*100))
    self:SetWidth(self.text:GetStringWidth()+3)
end

local function SetHealth_Absorbs_Only(self, current, max, totalAbsorbs)
    if totalAbsorbs == 0 then
        self.text:SetText("")
    else
        self.text:SetText(totalAbsorbs)
    end
    self:SetWidth(self.text:GetStringWidth()+3)
end

local function SetHealth_Absorbs_Only_Short(self, current, max, totalAbsorbs)
    if totalAbsorbs == 0 then
        self.text:SetText("")
    else
        self.text:SetText(F:FormatNumber(totalAbsorbs))
    end
    self:SetWidth(self.text:GetStringWidth()+3)
end

local function SetHealth_Absorbs_Only_Percentage(self, current, max, totalAbsorbs)
    if totalAbsorbs == 0 then
        self.text:SetText("")
    else
        self.text:SetFormattedText("%d%%", totalAbsorbs/max*100)
    end
    self:SetWidth(self.text:GetStringWidth()+3)
end

function I:CreateHealthText(parent)
    local healthText = CreateFrame("Frame", parent:GetName().."HealthText", parent.widget.overlayFrame)
    parent.indicators.healthText = healthText
    healthText:Hide()

    local text = healthText:CreateFontString(nil, "OVERLAY", "CELL_FONT_STATUS")
    healthText.text = text

    function healthText:SetFont(font, size, flags)
        font = F:GetFont(font)

        if flags == "Shadow" then
            text:SetFont(font, size, "")
            text:SetShadowOffset(1, -1)
            text:SetShadowColor(0, 0, 0, 1)
        else
            if flags == "None" then
                flags = ""
            elseif flags == "Outline" then
                flags = "OUTLINE"
            else
                flags = "OUTLINE,MONOCHROME"
            end
            text:SetFont(font, size, flags)
            text:SetShadowOffset(0, 0)
            text:SetShadowColor(0, 0, 0, 0)
        end
        healthText:SetSize(text:GetStringWidth()+3, size+3)
    end

    healthText._SetPoint = healthText.SetPoint
    function healthText:SetPoint(point, relativeTo, relativePoint, x, y)
        text:ClearAllPoints()
        if string.find(point, "LEFT") then
            text:SetPoint("LEFT")
        elseif string.find(point, "RIGHT") then
            text:SetPoint("RIGHT")
        else
            text:SetPoint("CENTER")
        end
        healthText:_SetPoint(point, relativeTo, relativePoint, x, y)
    end

    function healthText:SetFormat(format)
        if format == "percentage" then
            healthText.SetHealth = SetHealth_Percentage
        elseif format == "percentage-absorbs" then
            healthText.SetHealth = SetHealth_Percentage_Absorbs
        elseif format == "percentage-absorbs-merged" then
            healthText.SetHealth = SetHealth_Percentage_Absorbs_Merged
        elseif format == "percentage-deficit" then
            healthText.SetHealth = SetHealth_Percentage_Deficit
        elseif format == "number" then
            healthText.SetHealth = SetHealth_Number
        elseif format == "number-short" then
            healthText.SetHealth = SetHealth_Number_Short
        elseif format == "number-absorbs-short" then
            healthText.SetHealth = SetHealth_Number_Absorbs_Short
        elseif format == "number-absorbs-merged-short" then
            healthText.SetHealth = SetHealth_Number_Absorbs_Merged_Short
        elseif format == "number-deficit" then
            healthText.SetHealth = SetHealth_Number_Deficit
        elseif format == "number-deficit-short" then
            healthText.SetHealth = SetHealth_Number_Deficit_Short
        elseif format == "current-short-percentage" then
            healthText.SetHealth = SetHealth_Current_Short_Percentage
        elseif format == "absorbs-only" then
            healthText.SetHealth = SetHealth_Absorbs_Only
        elseif format == "absorbs-only-short" then
            healthText.SetHealth = SetHealth_Absorbs_Only_Short
        elseif format == "absorbs-only-percentage" then
            healthText.SetHealth = SetHealth_Absorbs_Only_Percentage
        end
    end

    function healthText:SetColor(r, g, b)
        text:SetTextColor(r, g, b)
    end

    function healthText:SetHealth() end
end

-------------------------------------------------
-- role icon
-------------------------------------------------
local defaultRoleIcon = {
    TANK = "Interface\\AddOns\\Cell\\Media\\Roles\\TANK32",
    HEALER = "Interface\\AddOns\\Cell\\Media\\Roles\\HEALER32",
    DAMAGER = "Interface\\AddOns\\Cell\\Media\\Roles\\DAMAGER32",
}

function I:CreateRoleIcon(parent)
    local roleIcon = parent.widget.overlayFrame:CreateTexture(parent:GetName().."RoleIcon", "ARTWORK", nil, -7)
    parent.indicators.roleIcon = roleIcon
    -- roleIcon:SetPoint("TOPLEFT", overlayFrame)
    -- roleIcon:SetSize(11, 11)
    
    function roleIcon:SetRole(role)
        roleIcon:SetVertexColor(1, 1, 1)
        if role == "TANK" or role == "HEALER" or (not roleIcon.hideDamager and role == "DAMAGER") then
            if roleIcon.texture == "default" then
                -- roleIcon:SetTexture("Interface\\AddOns\\Cell\\Media\\Roles\\UI-LFG-ICON-PORTRAITROLES.blp")
                -- roleIcon:SetTexCoord(GetTexCoordsForRoleSmallCircle(role))
                roleIcon:SetTexture(defaultRoleIcon[role])
                roleIcon:SetTexCoord(0, 1, 0, 1)
            elseif roleIcon.texture == "default2" then
                roleIcon:SetTexture("Interface\\AddOns\\Cell\\Media\\Roles\\UI-LFG-ICON-ROLES.blp")
                roleIcon:SetTexCoord(GetTexCoordsForRole(role))
            elseif roleIcon.texture == "blizzard" then
                roleIcon:SetTexture("Interface\\LFGFRAME\\UI-LFG-ICON-PORTRAITROLES.blp")
                roleIcon:SetTexCoord(GetTexCoordsForRoleSmallCircle(role))
            elseif roleIcon.texture == "blizzard2" then
                roleIcon:SetTexture("Interface\\LFGFRAME\\UI-LFG-ICON-ROLES.blp")
                roleIcon:SetTexCoord(GetTexCoordsForRole(role))
            elseif roleIcon.texture == "ffxiv" then
                roleIcon:SetTexture("Interface\\AddOns\\Cell\\Media\\Roles\\FFXIV\\"..role)
                roleIcon:SetTexCoord(0, 1, 0, 1)
            elseif roleIcon.texture == "miirgui" then
                roleIcon:SetTexture("Interface\\AddOns\\Cell\\Media\\Roles\\MiirGui\\"..role)
                roleIcon:SetTexCoord(0, 1, 0, 1)
            elseif roleIcon.texture == "mattui" then
                roleIcon:SetTexture("Interface\\AddOns\\Cell\\Media\\Roles\\MattUI.blp")
                roleIcon:SetTexCoord(GetTexCoordsForRoleSmallCircle(role))
            elseif roleIcon.texture == "custom" then
                roleIcon:SetTexture(roleIcon[role])
                roleIcon:SetTexCoord(0, 1, 0, 1)
            end
            roleIcon:Show()
        elseif role == "VEHICLE-ROOT" then
            roleIcon:SetTexture("Interface\\AddOns\\Cell\\Media\\Roles\\VEHICLE")
            roleIcon:Show()
        elseif role == "VEHICLE" then
            roleIcon:SetTexture("Interface\\AddOns\\Cell\\Media\\Roles\\VEHICLE")
            roleIcon:SetVertexColor(0.6, 0.6, 1)
            roleIcon:Show()
        else
            roleIcon:Hide()
        end
    end

    function roleIcon:SetRoleTexture(t)
        roleIcon.texture = t[1]
        roleIcon.TANK = t[2]
        roleIcon.HEALER = t[3]
        roleIcon.DAMAGER = t[4]
    end

    function roleIcon:HideDamager(hide)
        roleIcon.hideDamager = hide
    end

    function roleIcon:UpdatePixelPerfect()
        P:Resize(roleIcon)
        P:Repoint(roleIcon)
    end
end

-------------------------------------------------
-- party assignment icon
-------------------------------------------------
function I:CreatePartyAssignmentIcon(parent)
    local partyAssignmentIcon = parent.widget.overlayFrame:CreateTexture(parent:GetName().."PartyAssignmentIcon", "ARTWORK", nil, -7)
    parent.indicators.partyAssignmentIcon = partyAssignmentIcon
    partyAssignmentIcon:Hide()

    function partyAssignmentIcon:UpdateAssignment(unit)
        if GetPartyAssignment("MAINTANK", unit) then
            partyAssignmentIcon:SetTexture("Interface\\GroupFrame\\UI-Group-MainTankIcon")
            partyAssignmentIcon:Show()
        elseif GetPartyAssignment("MAINASSIST", unit) then
            partyAssignmentIcon:SetTexture("Interface\\GroupFrame\\UI-Group-MainAssistIcon")
            partyAssignmentIcon:Show()
        else
            partyAssignmentIcon:Hide()
        end
    end
    
    function partyAssignmentIcon:UpdatePixelPerfect()
        P:Resize(partyAssignmentIcon)
        P:Repoint(partyAssignmentIcon)
    end
end

-------------------------------------------------
-- leader icon
-------------------------------------------------
function I:CreateLeaderIcon(parent)
    local leaderIcon = parent.widget.overlayFrame:CreateTexture(parent:GetName().."LeaderIcon", "ARTWORK", nil, -7)
    parent.indicators.leaderIcon = leaderIcon
    -- leaderIcon:SetPoint("TOPLEFT", roleIcon, "BOTTOM")
    -- leaderIcon:SetPoint("TOPLEFT", 0, -11)
    -- leaderIcon:SetSize(11, 11)
    leaderIcon:Hide()
    
    function leaderIcon:SetIcon(isLeader, isAssistant)
        if isLeader then
            leaderIcon:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
            leaderIcon:Show()
        elseif isAssistant then
            leaderIcon:SetTexture("Interface\\GroupFrame\\UI-Group-AssistantIcon")
            leaderIcon:Show()
        else
            leaderIcon:Hide()
        end
    end

    function leaderIcon:UpdatePixelPerfect()
        P:Resize(leaderIcon)
        P:Repoint(leaderIcon)
    end
end

-------------------------------------------------
-- ready check icon
-------------------------------------------------
-- READY_CHECK_WAITING_TEXTURE = "Interface\\RaidFrame\\ReadyCheck-Waiting";
-- READY_CHECK_READY_TEXTURE = "Interface\\RaidFrame\\ReadyCheck-Ready";
-- READY_CHECK_NOT_READY_TEXTURE = "Interface\\RaidFrame\\ReadyCheck-NotReady";
-- READY_CHECK_AFK_TEXTURE = "Interface\\RaidFrame\\ReadyCheck-NotReady";
-- ↓↓↓ since 10.1.5
-- READY_CHECK_WAITING_TEXTURE = "UI-LFG-PendingMark";
-- READY_CHECK_READY_TEXTURE = "UI-LFG-ReadyMark";
-- READY_CHECK_NOT_READY_TEXTURE = "UI-LFG-DeclineMark";
-- READY_CHECK_AFK_TEXTURE = "UI-LFG-DeclineMark";

local READY_CHECK_STATUS = {
    ready = {t = "Interface\\AddOns\\Cell\\Media\\Icons\\readycheck-ready", c = {0, 1, 0, 1}},
    waiting = {t = "Interface\\AddOns\\Cell\\Media\\Icons\\readycheck-waiting", c = {1, 1, 0, 1}},
    notready = {t = "Interface\\AddOns\\Cell\\Media\\Icons\\readycheck-notready", c = {1, 0, 0, 1}},
}

function I:CreateReadyCheckIcon(parent)
    local readyCheckIcon = CreateFrame("Frame", parent:GetName().."ReadyCheckIcon", parent.widget.overlayFrame)
    parent.indicators.readyCheckIcon = readyCheckIcon
    -- readyCheckIcon:SetSize(16, 16)
    readyCheckIcon:SetPoint("CENTER", parent.widget.healthBar)
    readyCheckIcon:Hide()
    readyCheckIcon:SetIgnoreParentAlpha(true)
    
    readyCheckIcon.tex = readyCheckIcon:CreateTexture(nil, "ARTWORK")
    readyCheckIcon.tex:SetAllPoints(readyCheckIcon)
    
    function readyCheckIcon:SetStatus(status)
        readyCheckIcon.tex:SetTexture(READY_CHECK_STATUS[status].t)
        -- readyCheckIcon.tex:SetAtlas(READY_CHECK_STATUS[status].t)
        readyCheckIcon:Show()

    end
end

-------------------------------------------------
-- aggro border
-------------------------------------------------
function I:CreateAggroBorder(parent)
    local aggroBorder = CreateFrame("Frame", parent:GetName().."AggroBorder", parent, "BackdropTemplate")
    parent.indicators.aggroBorder = aggroBorder
    P:Point(aggroBorder, "TOPLEFT", parent, "TOPLEFT", 1, -1)
    P:Point(aggroBorder, "BOTTOMRIGHT", parent, "BOTTOMRIGHT", -1, 1)
    aggroBorder:Hide()

    local top = aggroBorder:CreateTexture(nil, "BORDER")
    local bottom = aggroBorder:CreateTexture(nil, "BORDER")
    local left = aggroBorder:CreateTexture(nil, "BORDER")
    local right = aggroBorder:CreateTexture(nil, "BORDER")

    top:SetTexture("Interface\\Buttons\\WHITE8x8")
    top:SetPoint("TOPLEFT")
    top:SetPoint("TOPRIGHT")
    top:SetHeight(5)
    
    bottom:SetTexture("Interface\\Buttons\\WHITE8x8")
    bottom:SetPoint("BOTTOMLEFT")
    bottom:SetPoint("BOTTOMRIGHT")
    bottom:SetHeight(5)
    
    left:SetTexture("Interface\\Buttons\\WHITE8x8")
    left:SetPoint("TOPLEFT")
    left:SetPoint("BOTTOMLEFT")
    left:SetWidth(5)
    
    right:SetTexture("Interface\\Buttons\\WHITE8x8")
    right:SetPoint("TOPRIGHT")
    right:SetPoint("BOTTOMRIGHT")
    right:SetWidth(5)
    
    top:SetGradient("VERTICAL", CreateColor(1, 0.1, 0.1, 0.2), CreateColor(1, 0.1, 0.1, 1))
    bottom:SetGradient("VERTICAL", CreateColor(1, 0.1, 0.1, 1), CreateColor(1, 0.1, 0.1, 0.2))
    left:SetGradient("HORIZONTAL", CreateColor(1, 0.1, 0.1, 1), CreateColor(1, 0.1, 0.1, 0.2))
    right:SetGradient("HORIZONTAL", CreateColor(1, 0.1, 0.1, 0.2), CreateColor(1, 0.1, 0.1, 1))

    function aggroBorder:ShowAggro(r, g, b)
        top:SetGradient("VERTICAL", CreateColor(r, g, b, 0.2), CreateColor(r, g, b, 1))
        bottom:SetGradient("VERTICAL", CreateColor(r, g, b, 1), CreateColor(r, g, b, 0.2))
        left:SetGradient("HORIZONTAL", CreateColor(r, g, b, 1), CreateColor(r, g, b, 0.2))
        right:SetGradient("HORIZONTAL", CreateColor(r, g, b, 0.2), CreateColor(r, g, b, 1))
        aggroBorder:Show()
    end

    function aggroBorder:SetThickness(n)
        top:SetHeight(n)
        bottom:SetHeight(n)
        left:SetWidth(n)
        right:SetWidth(n)
    end

    function aggroBorder:UpdatePixelPerfect()
        P:Repoint(aggroBorder)
    end
end

-------------------------------------------------
-- aggro blink
-------------------------------------------------
function I:CreateAggroBlink(parent)
    local aggroBlink = CreateFrame("Frame", parent:GetName().."AggroBlink", parent.widget.overlayFrame, "BackdropTemplate")
    parent.indicators.aggroBlink = aggroBlink
    -- aggroBlink:SetPoint("TOPLEFT")
    -- aggroBlink:SetSize(10, 10)
    aggroBlink:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = P:Scale(1)})
    aggroBlink:SetBackdropColor(1, 0, 0, 1)
    aggroBlink:SetBackdropBorderColor(0, 0, 0, 1)
    aggroBlink:Hide()

    local blink = aggroBlink:CreateAnimationGroup()
    aggroBlink.blink = blink
    blink:SetLooping("REPEAT")

    local alpha = blink:CreateAnimation("Alpha")
    blink.alpha = alpha
    alpha:SetFromAlpha(1)
    alpha:SetToAlpha(0)
    alpha:SetDuration(0.5)
    
    aggroBlink:SetScript("OnShow", function(self)
        self.blink:Play()
    end)
    
    aggroBlink:SetScript("OnHide", function(self)
        self.blink:Stop()
    end)

    function aggroBlink:ShowAggro(r, g, b)
        aggroBlink:SetBackdropColor(r, g, b)
        aggroBlink:Show()
    end

    function aggroBlink:UpdatePixelPerfect()
        P:Resize(aggroBlink)
        P:Repoint(aggroBlink)
        aggroBlink:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = P:Scale(1)})
        aggroBlink:SetBackdropColor(1, 0, 0, 1)
        aggroBlink:SetBackdropBorderColor(0, 0, 0, 1)
    end
end

-------------------------------------------------
-- shield bar
-------------------------------------------------
local function ShieldBar_SetHorizontalValue(bar, percent)
    local maxWidth = bar.parentHealthBar:GetWidth()
    local barWidth
    if percent >= 1 then
        barWidth = maxWidth
    else
        barWidth = maxWidth * percent
    end
    bar:SetWidth(barWidth)
end

local function ShieldBar_SetVerticalValue(bar, percent)
    local maxHeight = bar.parentHealthBar:GetHeight()
    local barHeight
    if percent >= 1 then
        barHeight = maxHeight
    else
        barHeight = maxHeight * percent
    end
    bar:SetHeight(barHeight)
end

local function ShieldBar_SetPoint(bar, point, anchorTo, anchorPoint, x, y)
    -- if point == "HEALTH_BAR_HORIZONTAL" then
    --     bar:_SetPoint("TOPLEFT", b.widget.healthBar)
    --     bar:_SetPoint("BOTTOMLEFT", b.widget.healthBar)
    --     bar.SetValue = ShieldBar_SetHorizontalValue
    -- elseif point == "HEALTH_BAR_VERTICAL" then
    --     bar:_SetPoint("TOPLEFT", b.widget.healthBar)
    --     bar:_SetPoint("BOTTOMLEFT", b.widget.healthBar)
    --     bar.SetValue = ShieldBar_SetVerticalValue
    if point == "HEALTH_BAR" then
        bar:_SetPoint("TOPLEFT", bar.parentHealthBar, P:Scale(-1), P:Scale(1))
        bar:_SetPoint("BOTTOMLEFT", bar.parentHealthBar, P:Scale(-1), P:Scale(-1))
        bar.SetValue = ShieldBar_SetHorizontalValue
    else
        bar:_SetPoint(point, anchorTo, anchorPoint, x, y)
        bar.SetValue = ShieldBar_SetHorizontalValue
    end
end

function I:CreateShieldBar(parent)
    local shieldBar = CreateFrame("Frame", parent:GetName().."ShieldBar", parent.widget.overlayFrame, "BackdropTemplate")
    parent.indicators.shieldBar = shieldBar
    -- shieldBar:SetSize(4, 4)
    shieldBar:Hide()
    shieldBar:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
    shieldBar:SetBackdropColor(0, 0, 0, 1)

    local tex = shieldBar:CreateTexture(nil, "ARTWORK")
    P:Point(tex, "TOPLEFT", shieldBar, "TOPLEFT", 1, -1)
    P:Point(tex, "BOTTOMRIGHT", shieldBar, "BOTTOMRIGHT", -1, 1)

    shieldBar._SetPoint = shieldBar.SetPoint
    shieldBar.SetPoint = ShieldBar_SetPoint
    shieldBar.SetValue = ShieldBar_SetHorizontalValue

    shieldBar.parentHealthBar = parent.widget.healthBar

    function shieldBar:SetColor(r, g, b, a)
        tex:SetColorTexture(r, g, b)
        shieldBar:SetAlpha(a)
    end

    function shieldBar:UpdatePixelPerfect()
        P:Resize(shieldBar)
        P:Repoint(shieldBar)
        P:Repoint(tex)
    end
end

-------------------------------------------------
-- health threshold
-------------------------------------------------
function I:CreateHealthThresholds(parent)
    local healthThresholds = CreateFrame("Frame", parent:GetName().."HealthThresholds", parent.widget.healthBar)
    parent.indicators.healthThresholds = healthThresholds
    healthThresholds:SetAllPoints(parent.widget.healthBar)
    healthThresholds:SetFrameLevel(parent.widget.healthBar:GetFrameLevel()+1)
    
    healthThresholds.tex = healthThresholds:CreateTexture(nil, "ARTWORK")
    
    function healthThresholds:SetThickness(thickness)
        healthThresholds.thickness = thickness
        P:Size(healthThresholds.tex, thickness, thickness)
    end

    function healthThresholds:SetOrientation(orientation)
        healthThresholds.orientation = orientation
        healthThresholds.tex:ClearAllPoints()
        if orientation == "horizontal" then
            healthThresholds.tex:SetPoint("TOP")
            healthThresholds.tex:SetPoint("BOTTOM")
        else
            healthThresholds.tex:SetPoint("LEFT")
            healthThresholds.tex:SetPoint("RIGHT")
        end
    end
    
    function healthThresholds:CheckThreshold(percent)
        local found
        for i, t in ipairs(Cell.vars.healthThresholds) do
            if percent < t[1] then
                found = i
                break
            end
        end
        if found then
            if healthThresholds.orientation == "horizontal" then
                healthThresholds.tex:SetPoint("LEFT", Cell.vars.healthThresholds[found][1] * parent.widget.healthBar:GetWidth(), 0)
            else
                healthThresholds.tex:SetPoint("BOTTOM", 0, Cell.vars.healthThresholds[found][1] * parent.widget.healthBar:GetHeight())
            end
            healthThresholds.tex:SetColorTexture(unpack(Cell.vars.healthThresholds[found][2]))
            healthThresholds:Show()
        else
            healthThresholds:Hide()
        end
    end

    if parent == CellIndicatorsPreviewButton then
        healthThresholds.tex:Hide()

        function healthThresholds:UpdateThresholdsPreview()
            for i, t in ipairs(Cell.vars.healthThresholds) do
                healthThresholds[i] = healthThresholds[i] or healthThresholds:CreateTexture(nil, "ARTWORK")
                P:Size(healthThresholds[i], healthThresholds.thickness, healthThresholds.thickness)
                healthThresholds[i]:SetColorTexture(unpack(t[2]))
                -- healthThresholds[i]:SetBlendMode("ADD")
                
                healthThresholds[i]:ClearAllPoints()
                if healthThresholds.orientation == "horizontal" then
                    healthThresholds[i]:SetPoint("TOP")
                    healthThresholds[i]:SetPoint("BOTTOM")
                    healthThresholds[i]:SetPoint("LEFT", t[1] * parent.widget.healthBar:GetWidth(), 0)
                else
                    healthThresholds[i]:SetPoint("LEFT")
                    healthThresholds[i]:SetPoint("RIGHT")
                    healthThresholds[i]:SetPoint("BOTTOM", 0, t[1] * parent.widget.healthBar:GetHeight())
                end
                healthThresholds[i]:Show()
            end
            -- hide unused
            for i = #Cell.vars.healthThresholds+1, #healthThresholds do
                if healthThresholds[i] then
                    healthThresholds[i]:Hide()
                end
            end
        end
    end
end

-- sort and save
function I:UpdateHealthThresholds()
    Cell.vars.healthThresholds = Cell.vars.currentLayoutTable.indicators[Cell.defaults.indicatorIndices.healthThresholds].thresholds
    F:Sort(Cell.vars.healthThresholds, 1, "ascending")
end

-------------------------------------------------
-- missing buffs
-------------------------------------------------
function I:CreateMissingBuffs(parent)
    local missingBuffs = CreateFrame("Frame", parent:GetName().."MissingBuffParent", parent.widget.overlayFrame)
    parent.indicators.missingBuffs = missingBuffs
    missingBuffs:Hide()

    missingBuffs._SetSize = missingBuffs.SetSize
    missingBuffs.SetSize = Cooldowns_SetSize
    missingBuffs.UpdateSize = Cooldowns_UpdateSize
    missingBuffs.SetOrientation = Cooldowns_SetOrientation
    missingBuffs.UpdatePixelPerfect = Cooldowns_UpdatePixelPerfect

    for i = 1, 5 do
        local name = parent:GetName().."MissingBuff"..i
        local frame = I:CreateAura_BarIcon(name, missingBuffs)
        tinsert(missingBuffs, frame)
        frame:HookScript("OnSizeChanged", function()
            if frame.glow then
                LCG.ButtonGlow_Start(frame)
            else
                LCG.ButtonGlow_Stop(frame)
            end
        end)
    end
end

local missingBuffsEnabled, missingBuffsNum, missingBuffsFilters = false, 0, {}
function I:EnableMissingBuffs(enabled)
    missingBuffsEnabled = enabled

    if enabled and CellDB["tools"]["buffTracker"][1] then
        CellBuffTrackerFrame:GROUP_ROSTER_UPDATE(true)
    end
end

function I:UpdateMissingBuffsNum(num, noUpdate)
    missingBuffsNum = num

    if not noUpdate and missingBuffsEnabled and CellDB["tools"]["buffTracker"][1] then
        CellBuffTrackerFrame:GROUP_ROSTER_UPDATE(true)
    end
end

function I:UpdateMissingBuffsFilters(filters, noUpdate)
    if filters then missingBuffsFilters = filters end

    if not noUpdate and missingBuffsEnabled and CellDB["tools"]["buffTracker"][1] then
        CellBuffTrackerFrame:GROUP_ROSTER_UPDATE(true)
    end
end

local function HideMissingBuffs(b)
    for i = 1, 5 do
        b.indicators.missingBuffs[i]:Hide()
    end
end

local missingBuffsCounter = {}
function I:HideMissingBuffs(unit, force)
    if not (missingBuffsEnabled or force) then return end
    
    missingBuffsCounter[unit] = nil

    F:HandleUnitButton("unit", unit, HideMissingBuffs)
end

local function ShowMissingBuff(b, index, icon, buffByMe)
    b.indicators.missingBuffs:UpdateSize(index)
    
    local f = b.indicators.missingBuffs[index]
    
    f:SetCooldown(0, 0, nil, icon, 0)

    if buffByMe then
        LCG.ButtonGlow_Start(f)
        f.glow = true
    else
        LCG.ButtonGlow_Stop(f)
        f.glow = nil
    end
end

function I:ShowMissingBuff(unit, buff, icon, buffByMe)
    if not missingBuffsEnabled then return end
    if missingBuffsFilters["buffByMe"] and not buffByMe then return end
    if not missingBuffsFilters[buff] then return end
    
    missingBuffsCounter[unit] = (missingBuffsCounter[unit] or 0) + 1

    if missingBuffsCounter[unit] > missingBuffsNum then return end

    F:HandleUnitButton("unit", unit, ShowMissingBuff, missingBuffsCounter[unit], icon, buffByMe)
end

-------------------------------------------------
-- power word : shield 怀旧服API太落后，蛋疼！
-------------------------------------------------
function I:CreatePowerWordShield(parent)
    local powerWordShield = CreateFrame("Frame", parent:GetName().."PowerWordShield", parent.widget.overlayFrame, "BackdropTemplate")
    parent.indicators.powerWordShield = powerWordShield
    powerWordShield:Hide()

    powerWordShield:SetBackdrop({bgFile = [[Interface\AddOns\Cell\Media\Shapes\circle_filled.tga]]})
    powerWordShield:SetBackdropColor(0, 0, 0, 0.75)

    --! shield amount
    local shieldAmount = CreateFrame("Cooldown", parent:GetName().."PowerWordShieldAmount", powerWordShield)
    -- shieldAmount:SetAllPoints(powerWordShield)
    shieldAmount:SetSwipeTexture([[Interface\AddOns\Cell\Media\Shapes\circle_filled.tga]])
    -- shieldAmount:SetSwipeTexture("Interface\\Buttons\\WHITE8x8")
    shieldAmount:SetSwipeColor(1, 1, 0)
    shieldAmount.noCooldownCount = true -- disable omnicc
    shieldAmount:SetHideCountdownNumbers(true)

    --! innerBG
    local innerBG = shieldAmount:CreateTexture(nil, "OVERLAY")
    innerBG:SetPoint("CENTER")
    innerBG:SetTexture([[Interface\AddOns\Cell\Media\Shapes\circle_filled.tga]], "CLAMP", "CLAMP", "TRILINEAR")
    innerBG:SetVertexColor(0, 0, 0, 1)

    --! shield duration
    local shieldCooldown = CreateFrame("Cooldown", parent:GetName().."PowerWordShieldDuration", powerWordShield)
    shieldCooldown:SetFrameLevel(shieldAmount:GetFrameLevel() + 1)
    -- shieldCooldown:SetPoint("CENTER")
    shieldCooldown:SetPoint("TOPLEFT", P:Scale(1), P:Scale(-1))
    shieldCooldown:SetPoint("BOTTOMRIGHT", P:Scale(-1), P:Scale(1))
    shieldCooldown:SetSwipeTexture([[Interface\AddOns\Cell\Media\Shapes\circle_filled.tga]])
    shieldCooldown:SetSwipeColor(0, 1, 0)
    shieldCooldown.noCooldownCount = true -- disable omnicc
    shieldCooldown:SetHideCountdownNumbers(true)
    shieldCooldown:Hide()
    shieldCooldown:SetScript("OnCooldownDone", function()
        shieldCooldown:Hide()
    end)

    --! weakened soul duration
    local weakendedSoulCooldown = CreateFrame("Cooldown", parent:GetName().."WeakenedSoulDuration", powerWordShield)
    weakendedSoulCooldown:SetFrameLevel(shieldAmount:GetFrameLevel() + 2)
    -- weakendedSoulCooldown:SetPoint("CENTER")
    weakendedSoulCooldown:SetPoint("TOPLEFT", P:Scale(1), P:Scale(-1))
    weakendedSoulCooldown:SetPoint("BOTTOMRIGHT", P:Scale(-1), P:Scale(1))
    weakendedSoulCooldown:SetSwipeTexture([[Interface\AddOns\Cell\Media\Shapes\circle_filled.tga]])
    weakendedSoulCooldown:SetSwipeColor(1, 0, 0)
    weakendedSoulCooldown.noCooldownCount = true -- disable omnicc
    weakendedSoulCooldown:SetHideCountdownNumbers(true)
    weakendedSoulCooldown:Hide()
    weakendedSoulCooldown:SetScript("OnCooldownDone", function()
        weakendedSoulCooldown:Hide()
    end)

    powerWordShield._SetSize = powerWordShield.SetSize
    function powerWordShield:SetSize(width, height)
        powerWordShield.size = width
        powerWordShield:UpdatePixelPerfect()
    end

    function powerWordShield:UpdatePixelPerfect()
        local size = powerWordShield.size

        powerWordShield:_SetSize(P:Scale(size), P:Scale(size))
        innerBG:SetSize(P:Scale(ceil(size/2)+2), P:Scale(ceil(size/2)+2))
        
        shieldCooldown:SetSize(P:Scale(ceil(size/2)), P:Scale(ceil(size/2)))
        weakendedSoulCooldown:SetSize(P:Scale(ceil(size/2)), P:Scale(ceil(size/2)))

        shieldAmount:SetPoint("TOPLEFT", P:Scale(1), P:Scale(-1))
        shieldAmount:SetPoint("BOTTOMRIGHT", P:Scale(-1), P:Scale(1))
    end

    function powerWordShield:SetShape(shape)
        local tex = "Interface\\AddOns\\Cell\\Media\\Shapes\\"..shape.."_filled.tga"
        powerWordShield:SetBackdrop({bgFile = tex})
        powerWordShield:SetBackdropColor(0, 0, 0, 0.75)
        shieldAmount:SetSwipeTexture(tex)
        innerBG:SetTexture(tex, "CLAMP", "CLAMP", "TRILINEAR")
        shieldCooldown:SetSwipeTexture(tex)
        weakendedSoulCooldown:SetSwipeTexture(tex)
    end

    function powerWordShield:UpdateShield(value, max, resetMax)
        if resetMax then
            powerWordShield.max = nil
        elseif max then
            powerWordShield.max = max
        end
        -- print("remain:", value, "max:", powerWordShield.max, resetMax and "(reset)" or "")

        shieldCooldown:ClearAllPoints()
        weakendedSoulCooldown:ClearAllPoints()

        if value > 0 and powerWordShield.max then
            shieldAmount:SetCooldown(GetTime()-(powerWordShield.max-value), powerWordShield.max)
            shieldAmount:Pause()
            shieldCooldown:SetPoint("CENTER")
            weakendedSoulCooldown:SetPoint("CENTER")
        else
            shieldCooldown:SetPoint("TOPLEFT", P:Scale(1), P:Scale(-1))
            shieldCooldown:SetPoint("BOTTOMRIGHT", P:Scale(-1), P:Scale(1))
            weakendedSoulCooldown:SetPoint("TOPLEFT", P:Scale(1), P:Scale(-1))
            weakendedSoulCooldown:SetPoint("BOTTOMRIGHT", P:Scale(-1), P:Scale(1))
        end
    end

    local function Update()
        if not (shieldCooldown:IsShown() or weakendedSoulCooldown:IsShown()) then
            powerWordShield:Hide()
        end
    end

    function powerWordShield:SetShieldCooldown(start, duration)
        if start and duration then
            powerWordShield:Show()
            shieldCooldown:Show()
            shieldCooldown:SetCooldown(start, duration)
        else
            shieldCooldown:Hide()
            shieldAmount:Hide()
            Update()
        end
    end
    
    function powerWordShield:SetWeakenedSoulCooldown(start, duration, isMine)
        if start and duration then
            powerWordShield:Show()
            weakendedSoulCooldown:Show()
            weakendedSoulCooldown:SetCooldown(start, duration)
        else
            weakendedSoulCooldown:Hide()
            Update()
        end
    end
end

-------------------------------------------------
-- crowd controls
-------------------------------------------------
function I:CreateCrowdControls(parent)
    local crowdControls = CreateFrame("Frame", parent:GetName().."CrowdControlsParent", parent.widget.overlayFrame)
    parent.indicators.crowdControls = crowdControls
    crowdControls:Hide()
   
    crowdControls._SetSize = crowdControls.SetSize
    crowdControls.SetSize = Cooldowns_SetSize
    crowdControls.SetBorder = Cooldowns_SetBorder
    crowdControls.UpdateSize = Cooldowns_UpdateSize_WithSpacing
    crowdControls.SetOrientation = Cooldowns_SetOrientation_WithSpacing
    crowdControls.SetFont = Cooldowns_SetFont
    crowdControls.UpdatePixelPerfect = Cooldowns_UpdatePixelPerfect

    for i = 1, 3 do
        local frame = I:CreateAura_BorderIcon(parent:GetName().."CrowdControl"..i, crowdControls, 2)
        tinsert(crowdControls, frame)
        frame:SetScript("OnShow", crowdControls.UpdateSize)
        frame:SetScript("OnHide", crowdControls.UpdateSize)
    end
end