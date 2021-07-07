local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local I = Cell.iFuncs
local LCG = LibStub("LibCustomGlow-1.0")
local P = Cell.pixelPerfectFuncs

-------------------------------------------------
-- CreateDefensiveCooldowns
-------------------------------------------------
function I:CreateDefensiveCooldowns(parent)
    local defensiveCooldowns = CreateFrame("Frame", parent:GetName().."ExternalCooldownParent", parent.widget.overlayFrame)
    parent.indicators.defensiveCooldowns = defensiveCooldowns
    -- defensiveCooldowns:SetSize(20, 10)
    defensiveCooldowns:Hide()

    defensiveCooldowns.OriginalSetSize = defensiveCooldowns.SetSize

    function defensiveCooldowns:SetSize(width, height)
        defensiveCooldowns:OriginalSetSize(width, height)
        for i = 1, 5 do
            P:Size(defensiveCooldowns[i], width, height)
        end
    end

    function defensiveCooldowns:SetFont(font, ...)
        font = F:GetFont(font)
        for i = 1, 5 do
            defensiveCooldowns[i]:SetFont(font, ...)
        end
    end

    function defensiveCooldowns:SetOrientation(orientation)
        local point1, point2, x, y
        if orientation == "left-to-right" then
            point1 = "LEFT"
            point2 = "RIGHT"
            x = -1
            y = 0
        elseif orientation == "right-to-left" then
            point1 = "RIGHT"
            point2 = "LEFT"
            x = 1
            y = 0
        elseif orientation == "top-to-bottom" then
            point1 = "TOP"
            point2 = "BOTTOM"
            x = 0
            y = 1
        elseif orientation == "bottom-to-top" then
            point1 = "BOTTOM"
            point2 = "TOP"
            x = 0
            y = -1
        end
        
        for i = 2, 5 do
            P:ClearPoints(defensiveCooldowns[i])
            P:Point(defensiveCooldowns[i], point1, defensiveCooldowns[i-1], point2, x, y)
        end
    end

    for i = 1, 5 do
        local name = parent:GetName().."DefensiveCooldown"..i
        local frame = I:CreateAura_BarIcon(name, defensiveCooldowns)
        tinsert(defensiveCooldowns, frame)

        if i == 1 then
            P:Point(frame, "TOPLEFT")
        else
            P:Point(frame, "LEFT", defensiveCooldowns[i-1], "RIGHT", -1, 0)
        end
	end

    function defensiveCooldowns:UpdatePixelPerfect()
        P:Resize(defensiveCooldowns)
        P:Repoint(defensiveCooldowns)
        for i = 1, 5 do
            defensiveCooldowns[i]:UpdatePixelPerfect()
        end
    end
end

-------------------------------------------------
-- CreateExternalCooldowns
-------------------------------------------------
function I:CreateExternalCooldowns(parent)
    local externalCooldowns = CreateFrame("Frame", parent:GetName().."ExternalCooldownParent", parent.widget.overlayFrame)
    parent.indicators.externalCooldowns = externalCooldowns
    -- externalCooldowns:SetSize(20, 10)
    externalCooldowns:Hide()

    externalCooldowns.OriginalSetSize = externalCooldowns.SetSize

    function externalCooldowns:SetSize(width, height)
        externalCooldowns:OriginalSetSize(width, height)
        for i = 1, 5 do
            P:Size(externalCooldowns[i], width, height)
        end
    end

    function externalCooldowns:SetFont(font, ...)
        font = F:GetFont(font)
        for i = 1, 5 do
            externalCooldowns[i]:SetFont(font, ...)
        end
    end

    function externalCooldowns:SetOrientation(orientation)
        local point1, point2, x, y
        if orientation == "left-to-right" then
            point1 = "LEFT"
            point2 = "RIGHT"
            x = -1
            y = 0
        elseif orientation == "right-to-left" then
            point1 = "RIGHT"
            point2 = "LEFT"
            x = 1
            y = 0
        elseif orientation == "top-to-bottom" then
            point1 = "TOP"
            point2 = "BOTTOM"
            x = 0
            y = 1
        elseif orientation == "bottom-to-top" then
            point1 = "BOTTOM"
            point2 = "TOP"
            x = 0
            y = -1
        end
        
        for i = 2, 5 do
            P:ClearPoints(externalCooldowns[i])
            P:Point(externalCooldowns[i], point1, externalCooldowns[i-1], point2, x, y)
        end
    end

    for i = 1, 5 do
        local name = parent:GetName().."ExternalCooldown"..i
        local frame = I:CreateAura_BarIcon(name, externalCooldowns)
        tinsert(externalCooldowns, frame)

        if i == 1 then
            P:Point(frame, "TOPLEFT")
        else
            P:Point(frame, "RIGHT", externalCooldowns[i-1], "LEFT", 1, 0)
        end
	end

    function externalCooldowns:UpdatePixelPerfect()
        P:Resize(externalCooldowns)
        P:Repoint(externalCooldowns)
        for i = 1, 5 do
            externalCooldowns[i]:UpdatePixelPerfect()
        end
    end
end

-------------------------------------------------
-- CreateTankActiveMitigation
-------------------------------------------------
function I:CreateTankActiveMitigation(parent)
    local bar = Cell:CreateStatusBar(parent.widget.overlayFrame, 18, 4, 100)
    parent.indicators.tankActiveMitigation = bar
    bar:Hide()
    
    bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    bar:GetStatusBarTexture():SetAlpha(0)
    bar:SetReverseFill(true)

    local tex = bar:CreateTexture(nil, "ARTWORK")
    tex:SetColorTexture(.7, .7, .7)
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
        if not parent.state.class then parent.state.class = select(2, UnitClass(parent.state.unit)) end --? why sometimes parent.state.class == nil ???
        tex:SetColorTexture(F:GetClassColor(parent.state.class))
        bar:SetMinMaxValues(0, duration)
        bar:SetValue(GetTime()-start)
        bar:Show()
    end
end

-------------------------------------------------
-- CreateDebuffs
-------------------------------------------------
function I:CreateDebuffs(parent)
    local debuffs = CreateFrame("Frame", parent:GetName().."DebuffParent", parent.widget.overlayFrame)
    parent.indicators.debuffs = debuffs
    -- debuffs:SetSize(11, 11)
    debuffs:Hide()

    debuffs.hAlignment = ""
    debuffs.vAlignment = ""
    debuffs.OriginalSetPoint = debuffs.SetPoint
    function debuffs:SetPoint(point, relativeTo, relativePoint, x, y)
        debuffs:OriginalSetPoint(point, relativeTo, relativePoint, x, y)

        if string.find(point, "LEFT") then
            debuffs.hAlignment = "LEFT"
        elseif string.find(point, "RIGHT") then
            debuffs.hAlignment = "RIGHT"
        else
            debuffs.hAlignment = ""
        end

        if string.find(point, "TOP") then
            debuffs.vAlignment = "TOP"
        elseif string.find(point, "BOTTOM") then
            debuffs.vAlignment = "BOTTOM"
        else
            debuffs.vAlignment = ""
        end

        if debuffs.vAlignment == "" and debuffs.hAlignment == "" then
            debuffs.vAlignment = "CENTER"
        end

        debuffs[1]:ClearAllPoints()
        debuffs[1]:SetPoint(debuffs.vAlignment..debuffs.hAlignment)
        --! update others' position
        debuffs:SetOrientation(debuffs.orientation or "left-to-right")
    end

    debuffs.OriginalSetSize = debuffs.SetSize
    function debuffs:SetSize(normalSize, bigSize)
        debuffs:OriginalSetSize(unpack(normalSize))
        for i = 1, 10 do
            debuffs[i]:SetSize(unpack(normalSize))
        end
        -- store sizes for SetCooldown
        debuffs.normalSize = normalSize
        debuffs.bigSize = bigSize
        -- remove wrong data from UnitButton.lua (UpdateIndicators)
        debuffs.width = nil
        debuffs.height = nil
    end

    function debuffs:SetFont(font, ...)
        font = F:GetFont(font)
        for i = 1, 10 do
            debuffs[i]:SetFont(font, ...)
        end
    end

    function debuffs:SetOrientation(orientation)
        debuffs.orientation = orientation

        local point1, point2, v, h
        v = debuffs.vAlignment == "CENTER" and "" or debuffs.vAlignment
        h = debuffs.hAlignment

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
        
        for i = 2, 10 do
            debuffs[i]:ClearAllPoints()
            debuffs[i]:SetPoint(point1, debuffs[i-1], point2)
        end
    end

    for i = 1, 10 do
        local name = parent:GetName().."Debuff"..i
        local frame = I:CreateAura_BarIcon(name, debuffs)
        tinsert(debuffs, frame)

        frame.OriginalSetCooldown = frame.SetCooldown
        function frame:SetCooldown(start, duration, debuffType, texture, count, refreshing, isBigDebuff)
            frame:OriginalSetCooldown(start, duration, debuffType, texture, count, refreshing)
            if isBigDebuff then
                P:Size(frame, debuffs.bigSize[1], debuffs.bigSize[2])
            else
                P:Size(frame, debuffs.normalSize[1], debuffs.normalSize[2])
            end
        end

        -- if i == 1 then
        --     frame:SetPoint("TOPLEFT")
        -- else
        --     frame:SetPoint("LEFT", debuffs[i-1], "RIGHT")
        -- end
	end

    function debuffs:UpdatePixelPerfect()
        debuffs:OriginalSetSize(P:Scale(debuffs.normalSize[1]), P:Scale(debuffs.normalSize[2]))
        P:Repoint(debuffs)
    end
end

-------------------------------------------------
-- CreateDispels
-------------------------------------------------
function I:CreateDispels(parent)
    local dispels = CreateFrame("Frame", parent:GetName().."DispelParent", parent.widget.overlayFrame)
    parent.indicators.dispels = dispels
    dispels:Hide()

    dispels.highlight = parent.widget.healthBar:CreateTexture(parent:GetName().."DispelHighlight", "ARTWORK")
    -- dispels.highlight:SetAllPoints(parent.widget.healthBar)
    dispels.highlight:SetPoint("BOTTOMLEFT", parent.widget.healthBar)
    dispels.highlight:SetPoint("BOTTOMRIGHT", parent.widget.healthBar)
    dispels.highlight:SetPoint("TOP", parent.widget.healthBar, "CENTER")
    dispels.highlight:SetTexture("Interface\\Buttons\\WHITE8x8")
    dispels.highlight:Hide()

    dispels.OriginalSetSize = dispels.SetSize

    function dispels:SetSize(width, height)
        dispels:OriginalSetSize(width, height)
        for i = 1, 4 do
            dispels[i]:SetSize(width, height)
        end
    end

    function dispels:SetDispels(dispelTypes)
        local r, g, b, a = 0, 0, 0, 0

        local i = 1
        for dispelType, _ in pairs(dispelTypes) do
            dispels[i]:SetDispel(dispelType)
            i = i + 1
            if dispelType then
                r, g, b, a = DebuffTypeColor[dispelType].r, DebuffTypeColor[dispelType].g, DebuffTypeColor[dispelType].b, 1
            end
        end

        -- hide unused
        for j = i, 4 do
            dispels[j]:Hide()
        end

        -- highlight
        dispels.highlight:SetGradientAlpha("VERTICAL", r, g, b, a, r, g, b, 0)
    end

    function dispels:EnableHighlight(enabled)
        if enabled then
            dispels.highlight:Show()
        else
            dispels.highlight:Hide()
        end
    end

    for i = 1, 4 do
        local icon = dispels:CreateTexture(parent:GetName().."Dispel"..i, "ARTWORK")
        tinsert(dispels, icon)
        icon:Hide()

        if i == 1 then
            icon:SetPoint("TOPLEFT")
        else
            icon:SetPoint("RIGHT", dispels[i-1], "LEFT", 7, 0)
        end

        icon:SetTexCoord(.15, .85, .15, .85)
        icon:SetDrawLayer("ARTWORK", i)

        function icon:SetDispel(dispelType)
            icon:SetTexture("Interface\\RaidFrame\\Raid-Icon-Debuff"..dispelType)
            icon:Show()
        end
    end
end

-------------------------------------------------
-- CreateRaidDebuffs
-------------------------------------------------
local currentAreaDebuffs = {}
local eventFrame2 = CreateFrame("Frame")
eventFrame2:RegisterEvent("PLAYER_ENTERING_WORLD")

local function UpdateDebuffsForCurrentZone()
    F:Debug("|cffff77AARaidDebuffsChanged")

    wipe(currentAreaDebuffs)
    local iName = F:GetInstanceName()
    if iName ~= "" then
        currentAreaDebuffs = F:GetDebuffList(iName)
    end
end
Cell:RegisterCallback("RaidDebuffsChanged", "UpdateDebuffsForCurrentZone", UpdateDebuffsForCurrentZone)
eventFrame2:SetScript("OnEvent", UpdateDebuffsForCurrentZone)

function I:GetDebuffOrder(spellName, spellId, count)
    local t = currentAreaDebuffs[spellId] or currentAreaDebuffs[spellName]
    if not t then return end

    local showGlow
    if t["glowCondition"] then
        if t["glowCondition"][1] == "Stack" then
            if t["glowCondition"][2] == "=" then
                if count == t["glowCondition"][3] then showGlow = true end
            elseif t["glowCondition"][2] == ">" then
                if count > t["glowCondition"][3] then showGlow = true end
            elseif t["glowCondition"][2] == ">=" then
                if count >= t["glowCondition"][3] then showGlow = true end
            elseif t["glowCondition"][2] == "<" then
                if count < t["glowCondition"][3] then showGlow = true end
            elseif t["glowCondition"][2] == "<=" then
                if count <= t["glowCondition"][3] then showGlow = true end
            else -- ~=
                if count ~= t["glowCondition"][3] then showGlow = true end
            end
        end
    else
        showGlow = true
    end

    if showGlow then
        return t["order"], t["glowType"], t["glowOptions"]
    else
        return t["order"], "None", nil
    end
end

function I:CreateRaidDebuffs(parent)
    local frame = I:CreateAura_BorderIcon(parent:GetName().."RaidDebuffs", parent.widget.overlayFrame, 2)
    parent.indicators.raidDebuffs = frame
    frame:Hide()

    function frame:ShowGlow(glowType, glowOptions, noHiding)
        if glowType == "Normal" then
            if not noHiding then
                LCG.PixelGlow_Stop(parent)
                LCG.AutoCastGlow_Stop(parent)
            end
            LCG.ButtonGlow_Start(parent, glowOptions[1])
        elseif glowType == "Pixel" then
            if not noHiding then
                LCG.ButtonGlow_Stop(parent)
                LCG.AutoCastGlow_Stop(parent)
            end
            -- color, N, frequency, length, thickness
            LCG.PixelGlow_Start(parent, glowOptions[1], glowOptions[2], glowOptions[3], glowOptions[4], glowOptions[5])
        elseif glowType == "Shine" then
            if not noHiding then
                LCG.ButtonGlow_Stop(parent)
                LCG.PixelGlow_Stop(parent)
            end
            -- color, N, frequency, scale
            LCG.AutoCastGlow_Start(parent, glowOptions[1], glowOptions[2], glowOptions[3], glowOptions[4])
        else
            LCG.ButtonGlow_Stop(parent)
            LCG.PixelGlow_Stop(parent)
            LCG.AutoCastGlow_Stop(parent)
        end
    end

    function frame:HideGlow(glowType)
        if glowType == "Normal" then
            LCG.ButtonGlow_Stop(parent)
        elseif glowType == "Pixel" then
            LCG.PixelGlow_Stop(parent)
        elseif glowType == "Shine" then
            LCG.AutoCastGlow_Stop(parent)
        end
    end

    frame:SetScript("OnHide", function()
        LCG.ButtonGlow_Stop(parent)
        LCG.PixelGlow_Stop(parent)
        LCG.AutoCastGlow_Stop(parent)
    end)
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
function I:CreateNameText(parent)
    local nameText = parent.widget.overlayFrame:CreateFontString(parent:GetName().."NameText", "ARTWORK", "CELL_FONT_NAME")
    parent.indicators.nameText = nameText
    nameText:Hide()
    -- nameText:SetPoint("CENTER", healthBar)
    
    local vehicleText = parent.widget.overlayFrame:CreateFontString(parent:GetName().."VehicleText", "ARTWORK", "CELL_FONT_STATUS")
	parent.indicators.vehicleText = vehicleText
    vehicleText:SetTextColor(.8, .8, .8, 1)
    vehicleText:Hide()
	-- vehicleText:SetPoint("TOP", healthBar, 0, -1)

    hooksecurefunc(nameText, "Show", function()
        if vehicleText.enabled then
            vehicleText:Show()
        end
    end)
    hooksecurefunc(nameText, "Hide", function()
        vehicleText:Hide()
    end)
    hooksecurefunc(nameText, "SetAlpha", function(self, alpha)
        vehicleText:SetAlpha(alpha)
    end)


    nameText.OriginalSetFont = nameText.SetFont
    function nameText:SetFont(font, size, flags)
        if not string.find(font, ".ttf") then font = F:GetFont(font) end

        if flags == "Shadow" then
            nameText:OriginalSetFont(font, size)
            nameText:SetShadowOffset(1, -1)
            nameText:SetShadowColor(0, 0, 0, 1)
            vehicleText:SetFont(font, size-2)
            vehicleText:SetShadowOffset(1, -1)
            vehicleText:SetShadowColor(0, 0, 0, 1)
        else
            if flags == "None" then
                flags = ""
            elseif flags == "Outline" then
                flags = "OUTLINE"
            else
                flags = "OUTLINE, MONOCHROME"
            end
            nameText:OriginalSetFont(font, size, flags)
            nameText:SetShadowOffset(0, 0)
            nameText:SetShadowColor(0, 0, 0, 0)
            vehicleText:SetFont(font, size-2, flags)
            vehicleText:SetShadowOffset(0, 0)
            vehicleText:SetShadowColor(0, 0, 0, 0)
        end
        nameText:UpdateName()
        if parent.state.inVehicle or nameText.isPreview then
            nameText:UpdateVehicleName()
        end
    end

    nameText.OriginalSetPoint = nameText.SetPoint
    function nameText:SetPoint(point, relativeTo, relativePoint, x, y)
        -- override relativeTo
        nameText:OriginalSetPoint(point, parent.widget.healthBar, relativePoint, x, y)

        local vp, _, vrp, _, vy = vehicleText:GetPoint(1)
        if vp and vrp and vy then
            if string.find(vp, "TOP") then
                vp, vrp = "TOP", "BOTTOM"
            else -- BOTTOM
                vp, vrp = "BOTTOM", "TOP"
            end

            vehicleText:ClearAllPoints()
            if string.find(point, "LEFT") then
                vehicleText:SetPoint(vp.."LEFT", nameText, vrp.."LEFT", 0, vy)
            elseif string.find(point, "RIGHT") then
                vehicleText:SetPoint(vp.."RIGHT", nameText, vrp.."RIGHT", 0, vy)
            else -- "CENTER"
                vehicleText:SetPoint(vp, nameText, vrp, 0, vy)
            end
        end
    end

    function nameText:UpdateName()
        F:UpdateTextWidth(nameText, parent.state.name, nameText.width)
    end

    function nameText:UpdateVehicleName()
        F:UpdateTextWidth(vehicleText, nameText.isPreview and L["Vehicle Name"] or UnitName(parent.state.displayedUnit), nameText.width)
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

        vehicleText:ClearAllPoints()
        if pTable[1] == "TOP" then
            vehicleText:Show()
            vehicleText:SetPoint("BOTTOM"..p, nameText, "TOP"..p, 0, pTable[2])
            vehicleText.enabled = true
        elseif pTable[1] == "BOTTOM" then
            vehicleText:Show()
            vehicleText:SetPoint("TOP"..p, nameText, "BOTTOM"..p, 0, pTable[2])
            vehicleText.enabled = true
        else -- Hide
            vehicleText:Hide()
            vehicleText.enabled = false
        end
    end

    function nameText:UpdateTextWidth(width)
        nameText.width = width
        F:UpdateTextWidth(nameText, parent.state.name, width)
        if parent.state.inVehicle or nameText.isPreview then
            F:UpdateTextWidth(vehicleText, nameText.isPreview and L["Vehicle Name"] or UnitName(parent.state.displayedUnit), width)
        end
    end

    function nameText:UpdatePreviewColor(color)
        if color[1] == "Class Color" then
            nameText:SetTextColor(F:GetClassColor(Cell.vars.playerClass))
        else
            nameText:SetTextColor(unpack(color[2]))
        end
    end

    parent:SetScript("OnSizeChanged", function()
        if parent.state.name then
            nameText:UpdateName()
            
            if parent.state.inVehicle or nameText.isPreview then
                nameText:UpdateVehicleName()
            end
        end
    end)
end

-------------------------------------------------
-- status text
-------------------------------------------------
local startTimeCache = {}
function I:CreateStatusText(parent)
    local statusText = CreateFrame("Frame", parent:GetName().."StatusText", parent.widget.overlayFrame)
	parent.indicators.statusText = statusText
	statusText:Hide()

	local text = statusText:CreateFontString(nil, "ARTWORK", "CELL_FONT_STATUS")
	statusText.text = text
    text:SetTextColor(1, .19, .19)

    local timer = statusText:CreateFontString(nil, "ARTWORK", "CELL_FONT_STATUS")
	statusText.timer = timer
	timer:SetTextColor(1, .19, .19)
    
    function statusText:GetText()
        return text:GetText()
    end

    function statusText:SetText(s)
        text:SetText(s)
    end
    
    statusText.OriginalSetPoint = statusText.SetPoint
    function statusText:SetPoint(point, _, yOffset)
        statusText:ClearAllPoints()
        statusText:OriginalSetPoint("LEFT", parent.widget.healthBar)
        statusText:OriginalSetPoint("RIGHT", parent.widget.healthBar)
        statusText:OriginalSetPoint(point, parent.widget.healthBar, 0, yOffset)

        text:ClearAllPoints()
        text:SetPoint(point.."LEFT")
        timer:ClearAllPoints()
        timer:SetPoint(point.."RIGHT")

        statusText:SetHeight(text:GetHeight()+1)
    end
    
    hooksecurefunc(text, "SetText", function()
        statusText:SetHeight(text:GetHeight()+1)
    end)

    function statusText:SetFont(font, size, flags)
        if not string.find(font, ".ttf") then font = F:GetFont(font) end

        if flags == "Shadow" then
            text:SetFont(font, size)
            text:SetShadowOffset(1, -1)
            text:SetShadowColor(0, 0, 0, 1)
            timer:SetFont(font, size)
            timer:SetShadowOffset(1, -1)
            timer:SetShadowColor(0, 0, 0, 1)
        else
            if flags == "None" then
                flags = ""
            elseif flags == "Outline" then
                flags = "OUTLINE"
            else
                flags = "OUTLINE, MONOCHROME"
            end
            text:SetFont(font, size, flags)
            text:SetShadowOffset(0, 0)
            text:SetShadowColor(0, 0, 0, 0)
            timer:SetFont(font, size, flags)
            timer:SetShadowOffset(0, 0)
            timer:SetShadowColor(0, 0, 0, 0)
        end
    end

    function statusText:ShowTimer()
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
end

-------------------------------------------------
-- health text
-------------------------------------------------
function I:CreateHealthText(parent)
    local healthText = CreateFrame("Frame", parent:GetName().."HealthText", parent.widget.overlayFrame)
    parent.indicators.healthText = healthText
    healthText:Hide()

    local text = healthText:CreateFontString(nil, "OVERLAY", "CELL_FONT_STATUS")
    healthText.text = text

    function healthText:SetFont(font, size, flags, horizontalOffset)
        if not string.find(font, ".ttf") then font = F:GetFont(font) end

        if flags == "Shadow" then
            text:SetFont(font, size)
            text:SetShadowOffset(1, -1)
            text:SetShadowColor(0, 0, 0, 1)
        else
            if flags == "None" then
                flags = ""
            elseif flags == "Outline" then
                flags = "OUTLINE"
            else
                flags = "OUTLINE, MONOCHROME"
            end
            text:SetFont(font, size, flags)
            text:SetShadowOffset(0, 0)
            text:SetShadowColor(0, 0, 0, 0)
        end

        local point = healthText:GetPoint(1)
        text:ClearAllPoints()
        if string.find(point, "LEFT") then
            text:SetPoint("LEFT", horizontalOffset, 0)
        elseif string.find(point, "RIGHT") then
            text:SetPoint("RIGHT", horizontalOffset, 0)
        else
            text:SetPoint("CENTER", horizontalOffset, 0)
        end
        healthText:SetSize(text:GetStringWidth()+3, size+3)
    end

    healthText.OriginalSetPoint = healthText.SetPoint
    function healthText:SetPoint(point, relativeTo, relativePoint, x, y)
        local horizontalOffset = select(4, text:GetPoint(1))
        text:ClearAllPoints()
        if string.find(point, "LEFT") then
            text:SetPoint("LEFT", horizontalOffset, 0)
        elseif string.find(point, "RIGHT") then
            text:SetPoint("RIGHT", horizontalOffset, 0)
        else
            text:SetPoint("CENTER", horizontalOffset, 0)
        end
        healthText:OriginalSetPoint(point, relativeTo, relativePoint, x, y)
    end

    function healthText:SetFormat(format)
        healthText.format = format
    end

    function healthText:SetColor(r, g, b)
        text:SetTextColor(r, g, b)
    end

    function healthText:SetHealth(current, max)
        if healthText.format == "percentage" then
            text:SetText(string.format("%d%%", current/max*100))
        elseif healthText.format == "percentage-deficit" then
            text:SetText(string.format("%d%%", (current-max)/max*100))
        elseif healthText.format == "number" then
            text:SetText(current)
        elseif healthText.format == "number-short" then
            text:SetText(F:FormatNumer(current))
        elseif healthText.format == "number-deficit" then
            text:SetText(current-max)
        elseif healthText.format == "number-deficit-short" then
            text:SetText(F:FormatNumer(current-max))
        end
        healthText:SetWidth(text:GetStringWidth()+3)
    end
end

-------------------------------------------------
-- role icon
-------------------------------------------------
function I:CreateRoleIcon(parent)
    local roleIcon = parent.widget.overlayFrame:CreateTexture(parent:GetName().."RoleIcon", "ARTWORK", nil, -7)
	parent.indicators.roleIcon = roleIcon
	-- roleIcon:SetPoint("TOPLEFT", overlayFrame)
    -- roleIcon:SetSize(11, 11)
    
    function roleIcon:SetRole(role)
        if role == "TANK" or role == "HEALER" or role == "DAMAGER" then
            if roleIcon.useCustomTexture then
                roleIcon:SetTexture(roleIcon[role])
                roleIcon:SetTexCoord(0, 1, 0, 1)
            else
                roleIcon:SetTexture("Interface\\AddOns\\Cell\\Media\\UI-LFG-ICON-PORTRAITROLES.blp")
                roleIcon:SetTexCoord(GetTexCoordsForRoleSmallCircle(role))
                -- roleIcon:SetTexture("Interface\\AddOns\\Cell\\Media\\UI-LFG-ICON-ROLES.blp")
                -- roleIcon:SetTexCoord(GetTexCoordsForRole(role))
            end
            roleIcon:Show()
		else
			roleIcon:Hide()
		end
    end

    function roleIcon:SetCustomTexture(t)
        roleIcon.useCustomTexture = t[1]
        roleIcon.TANK = t[2]
        roleIcon.HEALER = t[3]
        roleIcon.DAMAGER = t[4]
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
end

-------------------------------------------------
-- ready check icon
-------------------------------------------------
function I:CreateReadyCheckIcon(parent)
    local readyCheckIcon = CreateFrame("Frame", parent:GetName().."ReadyCheckIcon", parent.widget.overlayFrame)
    parent.indicators.readyCheckIcon = readyCheckIcon
	-- readyCheckIcon:SetSize(16, 16)
	readyCheckIcon:SetPoint("CENTER", parent.widget.healthBar)
    readyCheckIcon:Hide()
    readyCheckIcon:SetIgnoreParentAlpha(true)
    
    readyCheckIcon.tex = readyCheckIcon:CreateTexture(nil, "ARTWORK")
    readyCheckIcon.tex:SetAllPoints(readyCheckIcon)
    
    function readyCheckIcon:SetTexture(tex)
        readyCheckIcon.tex:SetTexture(tex)
    end
end

-------------------------------------------------
-- aggro indicator
-------------------------------------------------
function I:CreateAggroIndicator(parent)
    local aggroIndicator = CreateFrame("Frame", parent:GetName().."AggroIndicator", parent.widget.overlayFrame, "BackdropTemplate")
	parent.indicators.aggroIndicator = aggroIndicator
	-- aggroIndicator:SetPoint("TOPLEFT")
	-- aggroIndicator:SetSize(10, 10)
	aggroIndicator:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
	aggroIndicator:SetBackdropColor(1, 0, 0, 1)
	aggroIndicator:SetBackdropBorderColor(0, 0, 0, 1)
	aggroIndicator:Hide()

    local blink = aggroIndicator:CreateAnimationGroup()
    aggroIndicator.blink = blink
    blink:SetLooping("REPEAT")

    local alpha = blink:CreateAnimation("Alpha")
    blink.alpha = alpha
    alpha:SetFromAlpha(1)
    alpha:SetToAlpha(0)
    alpha:SetDuration(0.5)
	
	aggroIndicator:SetScript("OnShow", function(self)
		self.blink:Play()
	end)
	
	aggroIndicator:SetScript("OnHide", function(self)
		self.blink:Stop()
	end)
end

-------------------------------------------------
-- shield bar
-------------------------------------------------
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

    function shieldBar:SetColor(r, g, b, a)
        tex:SetColorTexture(r, g, b)
        shieldBar:SetAlpha(a)
    end

    function shieldBar:SetValue(percent)
        local maxWidth = parent.widget.healthBar:GetWidth()
        local barWidth
        if percent >= 1 then
            barWidth = maxWidth
        else
            barWidth = maxWidth * percent
        end
        P:Width(shieldBar, barWidth)
    end

    function shieldBar:UpdatePixelPerfect()
        P:Resize(shieldBar)
        P:Repoint(shieldBar)
        P:Repoint(tex)
    end
end

-------------------------------------------------
-- status icon
-------------------------------------------------
function I:CreateStatusIcon(parent)
    local statusIcon = CreateFrame("Frame", parent:GetName().."StatusIcon", parent.widget.overlayFrame)
    parent.indicators.statusIcon = statusIcon
    statusIcon:Hide()
    statusIcon.tex = statusIcon:CreateTexture(nil, "OVERLAY")
    statusIcon.tex:SetAllPoints(statusIcon)

    function statusIcon:SetTexture(tex)
        statusIcon.tex:SetTexture(tex)
    end

    function statusIcon:SetTexCoord(...)
        statusIcon.tex:SetTexCoord(...)
    end

    function statusIcon:SetAtlas(...)
        statusIcon.tex:SetAtlas(...)
    end

    -- resurrection icon
    local resurrectionIcon = CreateFrame("Frame", parent:GetName().."ResurrectionIcon", parent.widget.overlayFrame)
    parent.indicators.resurrectionIcon = resurrectionIcon
    resurrectionIcon:SetAllPoints(statusIcon)
    resurrectionIcon:Hide()
    resurrectionIcon.icon = resurrectionIcon:CreateTexture(nil, "ARTWORK")
    resurrectionIcon.icon:SetAllPoints(resurrectionIcon)
    resurrectionIcon.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    resurrectionIcon.icon:SetDesaturated(true)
    resurrectionIcon.icon:SetVertexColor(.4, .4, .4, .5)
    resurrectionIcon.icon:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")

    function resurrectionIcon:SetTimer(start, duration)
        resurrectionIcon.bar:SetMinMaxValues(0, duration)
        resurrectionIcon.bar:SetValue(GetTime()-start)
        resurrectionIcon:Show()
    end

    local bar = CreateFrame("StatusBar", nil, resurrectionIcon)
    resurrectionIcon.bar = bar
    bar:SetAllPoints(resurrectionIcon)
    bar:SetOrientation("VERTICAL")
    bar:SetReverseFill(true)
    bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    bar:GetStatusBarTexture():SetAlpha(0)
    bar.elapsedTime = 0
    bar:SetScript("OnUpdate", function(self, elapsed)
        if bar.elapsedTime >= 0.25 then
            bar:SetValue(bar:GetValue() + bar.elapsedTime)
            bar.elapsedTime = 0
        end
        bar.elapsedTime = bar.elapsedTime + elapsed
    end)

    local mask = resurrectionIcon:CreateMaskTexture()
    mask:SetTexture("Interface\\Buttons\\WHITE8x8", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetPoint("TOPLEFT", bar:GetStatusBarTexture(), "BOTTOMLEFT")
    mask:SetPoint("BOTTOMRIGHT")

    local maskIcon = bar:CreateTexture(nil, "ARTWORK")
    maskIcon:SetAllPoints(resurrectionIcon)
    maskIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    maskIcon:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")
    maskIcon:AddMaskTexture(mask)

    statusIcon.OriginalSetFrameLevel = statusIcon.SetFrameLevel
    function statusIcon:SetFrameLevel(level)
        statusIcon:OriginalSetFrameLevel(level)
        resurrectionIcon:SetFrameLevel(level)
    end
end