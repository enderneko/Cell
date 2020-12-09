local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local I = Cell.iFuncs

-- local LibCLHealth = LibStub("LibCombatLogHealth-1.0")

local UnitGUID = UnitGUID
-- local UnitHealth = LibCLHealth.UnitHealth
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitGetIncomingHeals = UnitGetIncomingHeals
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local UnitIsUnit = UnitIsUnit
local UnitIsConnected = UnitIsConnected
local UnitIsAFK = UnitIsAFK
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsGhost = UnitIsGhost
local UnitPowerType = UnitPowerType
local UnitPowerMax = UnitPowerMax
local UnitInRange = UnitInRange
local UnitIsVisible = UnitIsVisible
local SetRaidTargetIconTexture = SetRaidTargetIconTexture
local GetTime = GetTime
local GetRaidTargetIndex = GetRaidTargetIndex
local GetReadyCheckStatus = GetReadyCheckStatus
local UnitHasVehicleUI = UnitHasVehicleUI
-- local UnitInVehicle = UnitInVehicle
-- local UnitUsingVehicle = UnitUsingVehicle
local UnitIsCharmed = UnitIsCharmed
local UnitIsPlayer = UnitIsPlayer
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitThreatSituation = UnitThreatSituation
local GetThreatStatusColor = GetThreatStatusColor
local UnitExists = UnitExists
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitIsGroupAssistant = UnitIsGroupAssistant
local InCombatLockdown = InCombatLockdown
local UnitPhaseReason = UnitPhaseReason
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff
local IsInRaid = IsInRaid

-------------------------------------------------
-- unit button init indicators
-------------------------------------------------
local UnitButton_UpdateAuras
local indicatorsInitialized
local enabledIndicators, indicatorNums, indicatorCustoms = {}, {}, {}

local function UpdateIndicatorParentVisibility(b, indicatorName, enabled)
	if not (indicatorName == "debuffs" or indicatorName == "defensiveCooldowns" or indicatorName == "externalCooldowns" or indicatorName == "dispels") then
		return
	end

	if enabled then
		b.indicators[indicatorName]:Show()
	else
		b.indicators[indicatorName]:Hide()
	end
end

local function UpdateIndicators(layout, indicatorName, setting, value, value2)
	if layout and layout ~= Cell.vars.currentLayout then return end

	F:Debug("|cffff7777UpdateIndicators:|r ", layout, indicatorName, setting, value, value2)
	if not indicatorName then -- init
		wipe(enabledIndicators)
		wipe(indicatorNums)
		F:IterateAllUnitButtons(function(b)
			I:RemoveAllCustomIndicators(b)
		end)

		for _, t in pairs(Cell.vars.currentLayoutTable["indicators"]) do
			-- update enabled
			if t["enabled"] then
				enabledIndicators[t["indicatorName"]] = true
			end
			-- update num
			if t["num"] then
				indicatorNums[t["indicatorName"]] = t["num"]
			end
			-- update aoehealing
            if t["indicatorName"] == "aoeHealing" then
                I:EnableAoEHealing(t["enabled"])
            end
			-- update custom
			if t["dispellableByMe"] ~= nil then
				indicatorCustoms[t["indicatorName"]] = t["dispellableByMe"]
			elseif t["castByMe"] ~= nil then
				indicatorCustoms[t["indicatorName"]] = t["castByMe"]
			elseif t["hideFull"] ~= nil then
				indicatorCustoms[t["indicatorName"]] = t["hideFull"]
			end
			-- update indicators
			F:IterateAllUnitButtons(function(b)
				local indicator = b.indicators[t["indicatorName"]] or I:CreateIndicator(b, t)
				-- update position
				if t["position"] then
					indicator:ClearAllPoints()
					indicator:SetPoint(t["position"][1], b, t["position"][2], t["position"][3], t["position"][4])
				end
				-- update frameLevel
				if t["frameLevel"] then
					indicator:SetFrameLevel(b.widget.overlayFrame:GetFrameLevel()+t["frameLevel"])
				end
				-- update size
				if t["size"] then
					indicator:SetSize(unpack(t["size"]))
				end
				-- update height
				if t["height"] then
					indicator:SetHeight(t["height"])
				end
				-- update alpha
				if t["alpha"] then
					indicator:SetAlpha(t["alpha"])
				end
				-- update orientation
				if t["orientation"] then
					indicator:SetOrientation(t["orientation"])
				end
				-- update font
				if t["font"] then
					indicator:SetFont(unpack(t["font"]))
				end
				-- update format
				if t["format"] then
					indicator:SetFormat(t["format"])
					b.func.UpdateHealthText()
				end
				-- update color
				if t["color"] then
					indicator:SetColor(unpack(t["color"]))
				end
				-- update colors
				if t["colors"] then
					indicator:SetColors(t["colors"])
				end
				-- update dispel highlight
				if type(t["enableHighlight"]) == "boolean" then
					indicator:EnableHighlight(t["enableHighlight"])
				end
				-- update duration
				if type(t["showDuration"]) == "boolean" then
					indicator:ShowDuration(t["showDuration"])
				end
				-- init raid icons
				if t["indicatorName"] == "playerRaidIcon" then
					b.func.UpdatePlayerRaidIcon(t["enabled"])
				elseif t["indicatorName"] == "targetRaidIcon" then
					b.func.UpdateTargetRaidIcon(t["enabled"])
				else
					UpdateIndicatorParentVisibility(b, t["indicatorName"], t["enabled"])
				end
			end)
		end
		indicatorsInitialized = true
	else
		-- changed in IndicatorsTab
		if setting == "enabled" then
			enabledIndicators[indicatorName] = value
			-- update aoehealing
            if indicatorName == "aoeHealing" then
				I:EnableAoEHealing(value)
			elseif indicatorName == "playerRaidIcon" then
				F:IterateAllUnitButtons(function(b)
					b.func.UpdatePlayerRaidIcon(value)
				end)
			elseif indicatorName == "targetRaidIcon" then
				F:IterateAllUnitButtons(function(b)
					b.func.UpdateTargetRaidIcon(value)
				end)
			elseif indicatorName == "healthText" then
				F:IterateAllUnitButtons(function(b)
					b.func.UpdateHealthText()
				end)
			else
				-- refresh
				F:IterateAllUnitButtons(function(b)
					UpdateIndicatorParentVisibility(b, indicatorName, value)
					if not value then
						b.indicators[indicatorName]:Hide() -- hide indicators which is shown right now
					end
					UnitButton_UpdateAuras(b)
				end)
            end
		elseif setting == "position" then
			F:IterateAllUnitButtons(function(b)
				local indicator = b.indicators[indicatorName]
				indicator:ClearAllPoints()
				indicator:SetPoint(value[1], b, value[2], value[3], value[4])
			end)
		elseif setting == "frameLevel" then
			F:IterateAllUnitButtons(function(b)
				local indicator = b.indicators[indicatorName]
				indicator:SetFrameLevel(b.widget.overlayFrame:GetFrameLevel()+value)
			end)
		elseif setting == "size" then
			F:IterateAllUnitButtons(function(b)
				local indicator = b.indicators[indicatorName]
				indicator:SetSize(unpack(value))
			end)
		elseif setting == "height" then
			F:IterateAllUnitButtons(function(b)
				local indicator = b.indicators[indicatorName]
				indicator:SetHeight(value)
			end)
		elseif setting == "alpha" then
			F:IterateAllUnitButtons(function(b)
				local indicator = b.indicators[indicatorName]
				indicator:SetAlpha(value)
			end)
		elseif setting == "orientation" then
			F:IterateAllUnitButtons(function(b)
				local indicator = b.indicators[indicatorName]
				indicator:SetOrientation(value)
			end)
		elseif setting == "font" then
			F:IterateAllUnitButtons(function(b)
				local indicator = b.indicators[indicatorName]
				indicator:SetFont(unpack(value))
			end)
		elseif setting == "format" then
			F:IterateAllUnitButtons(function(b)
				local indicator = b.indicators[indicatorName]
				indicator:SetFormat(value)
				b.func.UpdateHealthText()
			end)
		elseif setting == "color" then
			F:IterateAllUnitButtons(function(b)
				local indicator = b.indicators[indicatorName]
				indicator:SetColor(unpack(value))
			end)
		elseif setting == "colors" then
			F:IterateAllUnitButtons(function(b)
				local indicator = b.indicators[indicatorName]
				indicator:SetColors(value)
			end)
		elseif setting == "num" then
			indicatorNums[indicatorName] = value
			-- refresh
			F:IterateAllUnitButtons(function(b)
				UnitButton_UpdateAuras(b)
			end)
		elseif setting == "checkbutton" then
			if value ~= "enableHighlight" and value ~= "showDuration" then
				indicatorCustoms[indicatorName] = value2
			end
			if value == "hideFull" then
				F:IterateAllUnitButtons(function(b)
					b.func.UpdateHealthText()
				end)
			else
				F:IterateAllUnitButtons(function(b)
					if value == "enableHighlight" then
						local indicator = b.indicators[indicatorName]
						indicator:EnableHighlight(value2)
					elseif value == "showDuration" then
						local indicator = b.indicators[indicatorName]
						indicator:ShowDuration(value2)
					end
					UnitButton_UpdateAuras(b)
				end)
			end
		elseif setting == "create" then
			F:IterateAllUnitButtons(function(b)
				local indicator = I:CreateIndicator(b, value)
				-- update position
				indicator:ClearAllPoints()
				indicator:SetPoint(value["position"][1], b, value["position"][2], value["position"][3], value["position"][4])
				-- update size
				if value["size"] then
					indicator:SetSize(unpack(value["size"]))
				end
				-- update orientation
				if value["orientation"] then
					indicator:SetOrientation(value["orientation"])
				end
				-- update font
				if value["font"] then
					indicator:SetFont(unpack(value["font"]))
				end
				-- update color
				if value["color"] then
					indicator:SetColor(unpack(value["color"]))
				end
				-- update colors
				if value["colors"] then
					indicator:SetColors(value["colors"])
				end
				-- update showDuration
				if value["showDuration"] then
					indicator:ShowDuration(value["showDuration"])
				end
			end)
		elseif setting == "remove" then
			F:IterateAllUnitButtons(function(b)
				I:RemoveIndicator(b, indicatorName, value)
			end)
		elseif setting == "auras" then
			-- indicator auras changed, hide them all, then recheck whether to show
			F:IterateAllUnitButtons(function(b)
				b.indicators[indicatorName]:Hide()
				UnitButton_UpdateAuras(b)
			end)
		elseif setting == "blacklist" then
			F:IterateAllUnitButtons(function(b)
				UnitButton_UpdateAuras(b)
			end)
		end
	end
end
Cell:RegisterCallback("UpdateIndicators", "UnitButton_UpdateIndicators", UpdateIndicators)

-------------------------------------------------
-- unit button
-------------------------------------------------
--[[
unitButton = {
    state = {
		class, color, inRange, isAssistant, isLeader, name, role,
        unit, displayedUnit, health, healthMax, healthPercent, powerType
    },
    widget = {
		background, mouseoverHighlight, targetHighlight, readyCheckHighlight,
		healthBar, healthBarBackground, absorbsBar, shieldBar, incomingHeal, damageFlashTex, overShieldGlow,
		powerBar, powerBarBackground,
		statusTextFrame, statusText, timerText
		overlayFrame, nameText, vehicleText,
		aggroIndicator, leaderIcon, phaseIcon, readyCheckIcon, roleIcon,
	},
	func = {
		ShowFlash, HideFlash,
		ShowTimer, HideTimer, UpdateTimer,
	},
	indicators = {},
	updateRequired,
	__updateElapsed,
}
]]

-------------------------------------------------
-- auras
-------------------------------------------------
local debuffs_cache = {}
-- local debuffs_cache_caster = {} -- FIXME: refreshing animation bug, auras with the SAME NAME applied on one unit at the SAME TIME: debuffs_cache --> debuffs_cache_caster --> expirationTime
local debuffs_cache_count = {}
local debuffs_current = {}
local debuffs_dispel = {}
local function UnitButton_UpdateDebuffs(self)
	local unit = self.state.displayedUnit
	if not debuffs_cache[unit] then debuffs_cache[unit] = {} end
	if not debuffs_cache_count[unit] then debuffs_cache_count[unit] = {} end
    if not debuffs_current[unit] then debuffs_current[unit] = {} end
    if not debuffs_dispel[unit] then debuffs_dispel[unit] = {} end

	-- user created indicators
	I:ResetCustomIndicators(unit, "debuff")

	local found, refreshing = 1
	local topOrder, topGlowType, topGlowColor, topId, topStart, topDuration, topType, topIcon, topCount, topRefreshing = 999
    for i = 1, 40 do
        -- name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod, ...
        local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId = UnitDebuff(unit, i)
		if not name then
			break
		end
		
		if Cell.vars.debuffBlacklist[spellId] then
			isValid = false
		else
			isValid = true
		end

		-- if duration and duration ~= 0 and duration <= 600 then
		if duration and duration <= 600 then
			if isValid then
				-- print(name, expirationTime-duration+.1>=GetTime()) -- NOTE: startTime ≈ now
				refreshing = debuffs_cache[unit][spellId] and ((expirationTime == 0 and debuffs_cache_count[unit][spellId] and count > debuffs_cache_count[unit][spellId]) or expirationTime-duration+.1>=GetTime())

				if enabledIndicators["debuffs"] and found <= indicatorNums["debuffs"] then
					-- start, duration, debuffType, texture, count, refreshing
					self.indicators.debuffs[found]:SetCooldown(expirationTime - duration, duration, debuffType or "", icon, count, refreshing)
					found = found + 1
				end
				
				-- user created indicators
				I:CheckCustomIndicators(unit, self, "debuff", spellId, expirationTime - duration, duration, debuffType or "", icon, count, refreshing)

				-- check top debuff
				if enabledIndicators["centralDebuff"] and I:GetDebuffOrder(name, spellId) and I:GetDebuffOrder(name, spellId) < topOrder then
					topOrder, topGlowType, topGlowColor = I:GetDebuffOrder(name, spellId)
					topId, topStart, topDuration, topType, topIcon, topCount, topRefreshing = spellId, expirationTime - duration, duration, debuffType or "", icon, count, refreshing
				end

				debuffs_cache[unit][spellId] = expirationTime
				debuffs_cache_count[unit][spellId] = count
				debuffs_current[unit][spellId] = i
			end

			if enabledIndicators["dispels"] and debuffType and debuffType ~= "" then
				if indicatorCustoms["dispels"] then
					if I:CanDispel(debuffType) then debuffs_dispel[unit][debuffType] = true end
				else
					debuffs_dispel[unit][debuffType] = true
				end
			end
		end
	end
	
	-- hide other debuff indicators
	for i = found, 5 do
		self.indicators.debuffs[i]:Hide()
	end

	-- update dispels
	self.indicators.dispels:SetDispels(debuffs_dispel[unit])

	-- update central debuff
	if topId then
		self.indicators.centralDebuff:SetCooldown(topStart, topDuration, topType, topIcon, topCount, topRefreshing, topGlowType, topGlowColor)
	else
		self.indicators.centralDebuff:Hide()
	end

	-- user created indicators
	I:ShowCustomIndicators(unit, self, "debuff")
	
	-- update debuffs_cache
    local t = GetTime()
    for spellId, expirationTime in pairs(debuffs_cache[unit]) do
        -- lost or expired
        if not debuffs_current[unit][spellId] or (expirationTime ~= 0 and t >= expirationTime) then -- expirationTime == 0: no duration 
			debuffs_cache[unit][spellId] = nil
			debuffs_cache_count[unit][spellId] = nil
        end
	end

	wipe(debuffs_current[unit])
	wipe(debuffs_dispel[unit])
end

local buffs_cache = {}
local buffs_cache_castByMe = {}
local buffs_current = {}
local buffs_current_castByMe = {}
local function UnitButton_UpdateBuffs(self)
	local unit = self.state.displayedUnit
	if not buffs_cache[unit] then buffs_cache[unit] = {} end
    if not buffs_current[unit] then buffs_current[unit] = {} end

	-- user created indicators
	I:ResetCustomIndicators(unit, "buff")

	local refreshing
	local defensiveFound, externalFound, tankActiveMitigationFound, drinkingFound = 1, 1, false, false
    for i = 1, 40 do
        -- name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod, ...
        local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId = UnitBuff(unit, i)
		if not name then
			break
		end
		
		if duration then
			refreshing = buffs_cache[unit][spellId] and expirationTime-duration+.1>=GetTime()
			-- defensiveCooldowns
			if enabledIndicators["defensiveCooldowns"] and I:IsDefensiveCooldown(name) and defensiveFound <= indicatorNums["defensiveCooldowns"] then
				-- start, duration, debuffType, texture, count, refreshing
				self.indicators.defensiveCooldowns[defensiveFound]:SetCooldown(expirationTime - duration, duration, nil, icon, count, refreshing)
				defensiveFound = defensiveFound + 1
			end

			-- externalCooldowns
			if enabledIndicators["externalCooldowns"] and I:IsExternalCooldown(name, source, unit) and externalFound <= indicatorNums["externalCooldowns"] then
				-- start, duration, debuffType, texture, count, refreshing
				self.indicators.externalCooldowns[externalFound]:SetCooldown(expirationTime - duration, duration, nil, icon, count, refreshing)
				externalFound = externalFound + 1
			end

			-- tankActiveMitigation
			if enabledIndicators["tankActiveMitigation"] and I:IsTankActiveMitigation(name) then
				self.indicators.tankActiveMitigation:SetCooldown(expirationTime - duration, duration)
				tankActiveMitigationFound = true
			end

			-- drinking
			if I:IsDrinking(name) then
				if not self.widget.statusText:GetText() then
					self.widget.statusText:SetText("|cff30BFFF"..L["DRINKING"])
					self.widget.statusTextFrame:Show()
				end
				drinkingFound = true
			end

			-- user created indicators
			I:CheckCustomIndicators(unit, self, "buff", spellId, expirationTime - duration, duration, nil, icon, count, refreshing, false)
			
            buffs_cache[unit][spellId] = expirationTime
            buffs_current[unit][spellId] = i
		end
	end
	
	-- hide other defensiveCooldowns
	for i = defensiveFound, 5 do
		self.indicators.defensiveCooldowns[i]:Hide()
	end
	
	-- hide other externalCooldowns
	for i = externalFound, 5 do
		self.indicators.externalCooldowns[i]:Hide()
	end
	
	-- hide tankActiveMitigation
	if not tankActiveMitigationFound then
		self.indicators.tankActiveMitigation:Hide()
	end
	
	-- hide drinking
	if not drinkingFound and self.widget.statusText:GetText() == "|cff30BFFF"..L["DRINKING"] then
		self.widget.statusTextFrame:Hide()
		self.widget.statusText:SetText("")
	end
	
	-- update buffs_cache
    local t = GetTime()
    for spellId, expirationTime in pairs(buffs_cache[unit]) do
        -- lost or expired
        if not buffs_current[unit][spellId] or (expirationTime ~= 0 and t >= expirationTime) then
			buffs_cache[unit][spellId] = nil
        end
	end
	wipe(buffs_current[unit])

	-- cast by me ---------------------------------------------------------------------
	if not buffs_cache_castByMe[unit] then buffs_cache_castByMe[unit] = {} end
    if not buffs_current_castByMe[unit] then buffs_current_castByMe[unit] = {} end
	for i = 1, 40 do
        -- name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod, ...
        local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId = UnitBuff(unit, i, "PLAYER")
		if not name then
			break
		end

		if duration then
			refreshing = buffs_cache_castByMe[unit][spellId] and expirationTime-duration+.1>=GetTime()
			I:CheckCustomIndicators(unit, self, "buff", spellId, expirationTime - duration, duration, nil, icon, count, refreshing, true)
			
            buffs_cache_castByMe[unit][spellId] = expirationTime
            buffs_current_castByMe[unit][spellId] = i
		end
	end

	-- update buffs_cache
    t = GetTime()
    for spellId, expirationTime in pairs(buffs_cache_castByMe[unit]) do
        -- lost or expired
        if not buffs_current_castByMe[unit][spellId] or (expirationTime ~= 0 and t >= expirationTime) then
			buffs_cache_castByMe[unit][spellId] = nil
        end
	end
	wipe(buffs_current_castByMe[unit])
	-----------------------------------------------------------------------------------

	I:ShowCustomIndicators(unit, self, "buff")
end

-------------------------------------------------
-- functions
-------------------------------------------------
local function UpdateUnitHealthState(button)
	local unit = button.state.displayedUnit

	local health = UnitHealth(unit)
	local healthMax = UnitHealthMax(unit)

	button.state.health = health
	button.state.healthMax = healthMax
	button.state.healthPercent = health / healthMax

	if enabledIndicators["healthText"] and healthMax ~= 0 and health ~= 0 then
		if health == healthMax then
			if not indicatorCustoms["healthText"] then
				button.indicators.healthText:SetHealth(health, healthMax)
				button.indicators.healthText:Show()
			else
				button.indicators.healthText:Hide()
			end
		else
			button.indicators.healthText:SetHealth(health, healthMax)
			button.indicators.healthText:Show()
		end
	else
		button.indicators.healthText:Hide()
	end
end

-------------------------------------------------
-- unit button functions
-------------------------------------------------
local function UnitButton_UpdateTarget(self)
	local unit = self.state.displayedUnit
	if not unit then return end

	if UnitIsUnit(unit, "target") then
		self.widget.targetHighlight:Show()
	else
		self.widget.targetHighlight:Hide()
	end
end

local function UnitButton_UpdateRole(self)
	local unit = self.state.unit
	if not unit then return end

	local roleIcon = self.widget.roleIcon
	local role = UnitGroupRolesAssigned(unit)
	self.state.role = role

	if role == "TANK" or role == "HEALER" or role == "DAMAGER" then
		roleIcon:SetTexture("Interface\\AddOns\\Cell\\Media\\UI-LFG-ICON-PORTRAITROLES.blp")
		roleIcon:SetTexCoord(GetTexCoordsForRoleSmallCircle(role))
		-- roleIcon:SetTexture("Interface\\AddOns\\Cell\\Media\\UI-LFG-ICON-ROLES.blp")
		-- roleIcon:SetTexCoord(GetTexCoordsForRole(role))
		roleIcon:Show()
	else
		roleIcon:Hide()
	end
end

local function UnitButton_UpdateLeader(self, event)
	local unit = self.state.unit
	if not unit then return end
	
	local leaderIcon = self.widget.leaderIcon
	if InCombatLockdown() or event == "PLAYER_REGEN_DISABLED" then
		leaderIcon:Hide()
		return
	end

	local isLeader = UnitIsGroupLeader(unit)
	self.state.isLeader = isLeader
	local isAssistant = UnitIsGroupAssistant(unit) and IsInRaid()
	self.state.isAssistant = isAssistant
	
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

local function UnitButton_UpdatePlayerRaidIcon(self)
	local unit = self.state.displayedUnit
	if not unit then return end

	local playerRaidIcon = self.indicators.playerRaidIcon

	local index = GetRaidTargetIndex(unit)

	if enabledIndicators["playerRaidIcon"] then
		if index then
			SetRaidTargetIconTexture(playerRaidIcon.tex, index)
			playerRaidIcon:Show()
		else
			playerRaidIcon:Hide()
		end
	else
		playerRaidIcon:Hide()
	end
end

local function UnitButton_UpdateTargetRaidIcon(self)
	local unit = self.state.displayedUnit
	if not unit then return end

	local targetRaidIcon = self.indicators.targetRaidIcon

	local index = GetRaidTargetIndex(unit.."target")

	if enabledIndicators["targetRaidIcon"] then
		if index then
			SetRaidTargetIconTexture(targetRaidIcon.tex, index)
			targetRaidIcon:Show()
		else
			targetRaidIcon:Hide()
		end
	else
		targetRaidIcon:Hide()
	end
end

local READYCHECK_STATUS = {
	ready = {t = READY_CHECK_READY_TEXTURE, c = {0, 1, 0, 1}},
	waiting = {t = READY_CHECK_WAITING_TEXTURE, c = {1, 1, 0, 1}},
	notready = {t = READY_CHECK_NOT_READY_TEXTURE, c = {1, 0, 0, 1}},
}
local function UnitButton_UpdateReadyCheck(self)
	local unit = self.state.unit
	if not unit then return end
	
	local status = GetReadyCheckStatus(unit)
	self.state.readyCheckStatus = status

	if status ~= nil then
		self.widget.readyCheckHighlight:SetVertexColor(unpack(READYCHECK_STATUS[status].c))
		self.widget.readyCheckHighlight:Show()
		self.widget.readyCheckIcon:SetTexture(READYCHECK_STATUS[status].t)
		self.widget.readyCheckIcon:Show()
	end
end

local function UnitButton_FinishReadyCheck(self)
	if self.state.readyCheckStatus == "waiting" then
		self.widget.readyCheckHighlight:SetVertexColor(unpack(READYCHECK_STATUS.notready.c))
		self.widget.readyCheckIcon:SetTexture(READYCHECK_STATUS.notready.t)
	end
	C_Timer.After(6, function()
		self.widget.readyCheckHighlight:Hide()
		self.widget.readyCheckIcon:Hide()
	end)
end

local function UnitButton_UpdatePowerMax(self)
	local unit = self.state.displayedUnit
	if not unit then return end

	local value = UnitPowerMax(unit)
	if value > 0 then
		self.widget.powerBar:SetMinMaxValues(0, value)
		self.widget.powerBar:Show()
		self.widget.powerBarBackground:Show()
	else
		self.widget.powerBar:Hide()
		self.widget.powerBarBackground:Hide()
	end
end

local function UnitButton_UpdatePower(self)
	local unit = self.state.displayedUnit
	if not unit then return end

	self.widget.powerBar:SetValue(UnitPower(unit))
end

local function UnitButton_UpdatePowerType(self)
	local unit = self.state.displayedUnit
	if not unit then return end

	local r, g, b
	if not UnitIsConnected(unit) then
		r, g, b = 0.5, 0.5, 0.5
	else
		r, g, b, self.state.powerType = F:GetPowerColor(unit)
		if Cell.loaded then
			if CellDB["appearance"]["powerColor"][1] == "Class Color" then
				r, g, b = F:GetClassColor(self.state.class)
			elseif CellDB["appearance"]["powerColor"][1] == "Custom Color" then
				r, g, b = unpack(CellDB["appearance"]["powerColor"][2])
			end
		end
	end

	self.widget.powerBar:SetStatusBarColor(r, g, b)
	self.widget.powerBarBackground:SetVertexColor(r * .2, g * .2, b * .2)
end

local function UnitButton_UpdateHealthMax(self)
	local unit = self.state.displayedUnit
	if not unit then return end

	UpdateUnitHealthState(self)

	self.widget.healthBar:SetMinMaxValues(0, self.state.healthMax)
end

local function UnitButton_UpdateHealth(self)
	local unit = self.state.displayedUnit
	if not unit then return end

	UpdateUnitHealthState(self)
	local healthPercent = self.state.healthPercent
	
	self.widget.healthBar:SetValue(self.state.health)

	local diff = healthPercent - (self.state.healthPercentOld or healthPercent)
	if diff >= 0 then
		self.func.HideFlash()
	elseif diff <= -0.02 and diff >= -1 then --! player (just joined) UnitHealthMax(unit) may be 1 ====> diff == -maxHealth
		self.func.ShowFlash(abs(diff), healthPercent)
	end

	self.state.healthPercentOld = healthPercent

end

local function UnitButton_UpdateHealthPrediction(self)
	local unit = self.state.displayedUnit
	if not unit then return end

	local value = UnitGetIncomingHeals(unit) or 0
	if value == 0 then 
		self.widget.incomingHeal:Hide()
		return
	end

	UpdateUnitHealthState(self)

	local barWidth = self.widget.healthBar:GetWidth()
	local incomingHealWidth = value / self.state.healthMax * barWidth
	local lostHealthWidth = barWidth * (1 - self.state.healthPercent)

	if lostHealthWidth == 0 then
		self.widget.incomingHeal:Hide()
	else
		if lostHealthWidth > incomingHealWidth then
			self.widget.incomingHeal:SetWidth(incomingHealWidth)
		else
			self.widget.incomingHeal:SetWidth(lostHealthWidth)
		end
		self.widget.incomingHeal:Show()
	end
end

local function UnitButton_UpdateShieldAbsorbs(self)
	local unit = self.state.displayedUnit
	if not unit then return end
	
	local value = UnitGetTotalAbsorbs(unit)
	if value > 0 then
		UpdateUnitHealthState(self)

		local barWidth = self.widget.healthBar:GetWidth()
		local shieldPercent = value / self.state.healthMax
		if shieldPercent + self.state.healthPercent > 1 then -- overshield
			local p = 1 - self.state.healthPercent
			if p ~= 0 then
				self.widget.shieldBar:SetWidth(p * barWidth)
				self.widget.shieldBar:Show()
			else
				self.widget.shieldBar:Hide()
			end
			self.widget.overShieldGlow:Show()
		else
			self.widget.shieldBar:SetWidth(shieldPercent * barWidth)
			self.widget.shieldBar:Show()
			self.widget.overShieldGlow:Hide()
		end
	else
		self.widget.shieldBar:Hide()
		self.widget.overShieldGlow:Hide()
	end
end

local function UnitButton_UpdateHealthAbsorbs(self)
	local unit = self.state.displayedUnit
	if not unit then return end
	
	local value = UnitGetTotalHealAbsorbs(unit)
	if value > 0 then
		UpdateUnitHealthState(self)

		local barWidth = self.widget.healthBar:GetWidth()
		local absorbsPercent = value / self.state.healthMax
		if absorbsPercent > self.state.healthPercent then
			absorbsPercent = self.state.healthPercent
		end
		self.widget.absorbsBar:SetWidth(absorbsPercent * barWidth)
		self.widget.absorbsBar:Show()
	else
		self.widget.absorbsBar:Hide()
	end
end

UnitButton_UpdateAuras = function(self)
	if not indicatorsInitialized then return end

	local unit = self.state.displayedUnit
	if not unit then return end

	UnitButton_UpdateDebuffs(self)
	UnitButton_UpdateBuffs(self)
end

local function UnitButton_UpdateThreat(self)
	local unit = self.state.displayedUnit
	if not unit then return end
	-- if not unit or not UnitExists(unit) then return end

	local status = UnitThreatSituation(unit)
	if status and status >= 2 then
		self.widget.aggroIndicator:SetBackdropColor(GetThreatStatusColor(status))
		self.widget.aggroIndicator:Show()
	else
		self.widget.aggroIndicator:Hide()
	end
end

local function UnitButton_UpdateThreatBar(self)
	if not enabledIndicators["aggroBar"] then 
		self.indicators.aggroBar:Hide()
		return
	end

	local unit = self.state.displayedUnit
	if not unit then return end

	-- isTanking, status, scaledPercentage, rawPercentage, threatValue = UnitDetailedThreatSituation(unit, mobUnit)
	local _, status, scaledPercentage, rawPercentage = UnitDetailedThreatSituation(unit, "target")
	if status then
		self.indicators.aggroBar:Show()
		self.indicators.aggroBar:SetValue(scaledPercentage)
		self.indicators.aggroBar:SetStatusBarColor(GetThreatStatusColor(status))
	else
		self.indicators.aggroBar:Hide()
	end
end

local function UnitButton_UpdateInRange(self)
	local unit = self.state.displayedUnit
	if not unit then return end

	local inRange, checked = UnitInRange(unit)
	if not checked then
		inRange = UnitIsVisible(unit)
	end

	self.state.inRange = inRange
	self:SetAlpha(inRange and 1 or .4)
end

local function UnitButton_UpdateVehicleStatus(self)
	local unit = self.state.unit
	if not unit then return end

	if UnitHasVehicleUI(unit) then -- or UnitInVehicle(unit) or UnitUsingVehicle(unit) then
		self.state.inVehicle = true
		if unit == "player" then
			self.state.displayedUnit = "vehicle"
		else
			local prefix, id, suffix = strmatch(unit, "([^%d]+)([%d]*)(.*)")
			self.state.displayedUnit = prefix.."pet"..id..suffix
		end
		F:UpdateTextWidth(self.widget.vehicleText, UnitName(self.state.displayedUnit))
	else
		self.state.inVehicle = nil
		self.state.displayedUnit = self.state.unit
		self.widget.vehicleText:SetText("")
	end
end

local function UnitButton_UpdatePhase(self)
	local unit = self.state.unit
	if not unit then return end

	local icon = self.widget.phaseIcon
	if UnitHasIncomingResurrection(unit) then
        icon:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		icon:Show()
	elseif UnitIsPlayer(unit) and UnitPhaseReason(unit) and not self.state.inVehicle then
		-- https://wow.gamepedia.com/API_UnitPhaseReason
		icon:SetTexture("Interface\\TargetingFrame\\UI-PhasingIcon")
		icon:SetTexCoord(0.15625, 0.84375, 0.15625, 0.84375)
		icon:Show()
	else
		icon:Hide()
	end
end

local function UnitButton_UpdateStatusText(self)
	local unit = self.state.unit
	if not unit then return end

	local statusTextFrame = self.widget.statusTextFrame
	local statusText = self.widget.statusText
	self.state.guid = UnitGUID(unit) -- update!
	if not self.state.guid then return end

	if not UnitIsConnected(unit) and UnitIsPlayer(unit) then
		statusTextFrame:Show()
		statusText:SetText(L["OFFLINE"])
		self.func.ShowTimer("offline")
	elseif UnitIsAFK(unit) then
		statusTextFrame:Show()
		statusText:SetText(L["AFK"])
		self.func.ShowTimer("afk")
	elseif UnitIsDeadOrGhost(unit) then
		statusTextFrame:Show()
		self.func.HideTimer(true)
		if UnitIsGhost(unit) then
			statusText:SetText(L["GHOST"])
		else
			statusText:SetText(L["DEAD"])
		end
	elseif C_IncomingSummon.HasIncomingSummon(unit) then
		statusTextFrame:Show()
		self.func.HideTimer()
		local status = C_IncomingSummon.IncomingSummonStatus(unit)
		if status == Enum.SummonStatus.Pending then
            statusText:SetText("|cffFFFF30"..L["PENDING"])
        elseif status == Enum.SummonStatus.Accepted then
			statusText:SetText("|cff30FF30"..L["ACCEPTED"])
			C_Timer.After(6, function() UnitButton_UpdateStatusText(self) end)
		elseif status == Enum.SummonStatus.Declined then
            statusText:SetText(L["DECLINED"])
			C_Timer.After(6, function() UnitButton_UpdateStatusText(self) end)
        end
	else
		statusTextFrame:Hide()
		self.func.HideTimer(true)
		statusText:SetText("")
	end
end

local function UnitButton_UpdateName(self)
	local unit = self.state.unit
	if not unit then return end

	self.state.name = UnitName(unit)
	self.state.class = select(2, UnitClass(unit))
	self.state.guid = UnitGUID(unit)

	local nameText = self.widget.nameText
	if self.state.name then F:UpdateTextWidth(nameText, self.state.name) end
end

local function GetColor(r, g, b)
	local barR, barG, barB, bgR, bgG, bgB
	-- bar
	if CellDB["appearance"]["barColor"][1] == "Class Color" then
		barR, barG, barB = r, g, b
	elseif CellDB["appearance"]["barColor"][1] == "Class Color (dark)" then
		barR, barG, barB = r*.2, g*.2, b*.2
	else
		barR, barG, barB = unpack(CellDB["appearance"]["barColor"][2])
	end
	-- bg
	if CellDB["appearance"]["bgColor"][1] == "Class Color" then
		bgR, bgG, bgB = r, g, b
	elseif CellDB["appearance"]["bgColor"][1] == "Class Color (dark)" then
		bgR, bgG, bgB = r*.2, g*.2, b*.2
	else
		bgR, bgG, bgB = unpack(CellDB["appearance"]["bgColor"][2])
	end
	return barR, barG, barB, bgR, bgG, bgB
end

local function UnitButton_UpdateColor(self)
	local unit = self.state.unit
	if not unit then return end

	self.state.class = select(2, UnitClass(unit)) --! update class or it may be nil
	local nameText = self.widget.nameText

	local barR, barG, barB
	local bgR, bgG, bgB
	
	if Cell.loaded then
		if CellDB["appearance"]["nameColor"][1] == "Class Color" then
			nameText:SetTextColor(F:GetClassColor(self.state.class))
		else
			nameText:SetTextColor(unpack(CellDB["appearance"]["nameColor"][2]))
		end
	else
		nameText:SetTextColor(1, 1, 1)
	end

	if UnitIsPlayer(unit) then -- player
		if not UnitIsConnected(unit) then
			barR, barG, barB = .4, .4, .4
			bgR, bgG, bgB = .4, .4, .4
			nameText:SetTextColor(F:GetClassColor(self.state.class))
		elseif UnitIsCharmed(unit) then
			barR, barG, barB = .5, 0, 1
			bgR, bgG, bgB = barR*.2, barG*.2, barB*.2
			nameText:SetTextColor(F:GetClassColor(self.state.class))
		elseif self.state.inVehicle then
			if Cell.loaded then
				barR, barG, barB, bgR, bgG, bgB = GetColor(0, 1, .2)
			else
				barR, barG, barB = 0, 1, .2
				bgR, bgG, bgB = barR*.2, barG*.2, barB*.2
			end
		else
			if Cell.loaded then
				barR, barG, barB, bgR, bgG, bgB = GetColor(F:GetClassColor(self.state.class))
			else
				barR, barG, barB = F:GetClassColor(self.state.class)
				bgR, bgG, bgB = barR*.2, barG*.2, barB*.2
			end
		end
	elseif string.find(unit, "pet") then -- pet
		if Cell.loaded then
			barR, barG, barB, bgR, bgG, bgB = GetColor(.5, .5, 1)
		else
			barR, barG, barB = .5, .5, 1
			bgR, bgG, bgB = barR*.2, barG*.2, barB*.2
		end
		if Cell.loaded and CellDB["appearance"]["nameColor"][1] == "Class Color" then
			nameText:SetTextColor(.5, .5, 1)
		end
	else -- npc
		if Cell.loaded then
			barR, barG, barB, bgR, bgG, bgB = GetColor(0, 1, .2)
		else
			barR, barG, barB =0, 1, .2
			bgR, bgG, bgB = barR*.2, barG*.2, barB*.2
		end
	end

	-- local r, g, b = RAID_CLASS_COLORS["DEATHKNIGHT"]:GetRGB()
	self.widget.healthBar:SetStatusBarColor(barR, barG, barB)
	self.widget.healthBarBackground:SetVertexColor(bgR, bgG, bgB)
	self.widget.incomingHeal:SetVertexColor(barR, barG, barB)
end

local function UnitButton_UpdateAll(self)
	if not self:IsVisible() then return end

	UnitButton_UpdateVehicleStatus(self)
	UnitButton_UpdateName(self)
	UnitButton_UpdateColor(self)
	UnitButton_UpdateHealthMax(self)
	UnitButton_UpdateHealth(self)
	UnitButton_UpdateHealthPrediction(self)
	UnitButton_UpdateStatusText(self)

	if Cell.loaded then
		if Cell.vars.currentLayoutTable["powerHeight"] ~= 0 then
			UnitButton_UpdatePowerType(self)
			UnitButton_UpdatePowerMax(self)
			UnitButton_UpdatePower(self)
		end
	else
		UnitButton_UpdatePowerType(self)
		UnitButton_UpdatePowerMax(self)
		UnitButton_UpdatePower(self)
	end
	
	UnitButton_UpdateTarget(self)
	UnitButton_UpdatePlayerRaidIcon(self)
	UnitButton_UpdateTargetRaidIcon(self)
	UnitButton_UpdateShieldAbsorbs(self)
	UnitButton_UpdateHealthAbsorbs(self)
	UnitButton_UpdateInRange(self)
	UnitButton_UpdateRole(self)
	UnitButton_UpdateLeader(self)
	UnitButton_UpdateReadyCheck(self)
	UnitButton_UpdateThreat(self)
	UnitButton_UpdateThreatBar(self)
	UnitButton_UpdatePhase(self)
	UnitButton_UpdateAuras(self)
end

-------------------------------------------------
-- unit button events
-------------------------------------------------
local function UnitButton_RegisterEvents(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
	
	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterEvent("UNIT_MAXHEALTH")
	
	if Cell.loaded then
		if Cell.vars.currentLayoutTable["powerHeight"] ~= 0 then
			self:RegisterEvent("UNIT_POWER_FREQUENT")
			self:RegisterEvent("UNIT_MAXPOWER")
			self:RegisterEvent("UNIT_DISPLAYPOWER")
		end
	else
		self:RegisterEvent("UNIT_POWER_FREQUENT")
		self:RegisterEvent("UNIT_MAXPOWER")
		self:RegisterEvent("UNIT_DISPLAYPOWER")
	end
	
	self:RegisterEvent("UNIT_AURA")
	
	self:RegisterEvent("UNIT_HEAL_PREDICTION")
	self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
	self:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
	
	self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
	self:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
	self:RegisterEvent("UNIT_ENTERED_VEHICLE")
	self:RegisterEvent("UNIT_EXITED_VEHICLE")
	
	self:RegisterEvent("INCOMING_SUMMON_CHANGED")
	self:RegisterEvent("UNIT_FLAGS") -- afk
	self:RegisterEvent("UNIT_FACTION") -- mind control
	
	self:RegisterEvent("UNIT_CONNECTION") -- offline
	self:RegisterEvent("PLAYER_FLAGS_CHANGED") -- afk
	self:RegisterEvent("UNIT_NAME_UPDATE") -- unknown target
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA") --? update status text

	-- self:RegisterEvent("PARTY_LEADER_CHANGED") -- GROUP_ROSTER_UPDATE
	-- self:RegisterEvent("PLAYER_ROLES_ASSIGNED") -- GROUP_ROSTER_UPDATE
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")

	self:RegisterEvent("PLAYER_TARGET_CHANGED")

	if Cell.loaded then
		if enabledIndicators["playerRaidIcon"] then
			self:RegisterEvent("RAID_TARGET_UPDATE")
		end
	else
		self:RegisterEvent("RAID_TARGET_UPDATE")
	end
	if Cell.loaded then
		if enabledIndicators["targetRaidIcon"] then
			self:RegisterEvent("UNIT_TARGET")
		end
	else
		self:RegisterEvent("UNIT_TARGET")
	end
	
	self:RegisterEvent("READY_CHECK")
	self:RegisterEvent("READY_CHECK_FINISHED")
	self:RegisterEvent("READY_CHECK_CONFIRM")
	
	self:RegisterEvent("UNIT_PHASE") -- warmode, traditional sources of phasing such as progress through quest chains
	self:RegisterEvent("PARTY_MEMBER_DISABLE")
	self:RegisterEvent("PARTY_MEMBER_ENABLE")
	self:RegisterEvent("INCOMING_RESURRECT_CHANGED")
	
	-- self:RegisterEvent("VOICE_CHAT_CHANNEL_ACTIVATED")
	-- self:RegisterEvent("VOICE_CHAT_CHANNEL_DEACTIVATED")
	
	-- self:RegisterEvent("UNIT_PET")
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE") -- pet summoned far away
	
	-- LibCLHealth.RegisterCallback(self, "COMBAT_LOG_HEALTH", function(event, unit, eventType)
	-- 	-- eventType - either nil when event comes from combat log, or "UNIT_HEALTH" to indicate events that can carry  update to death/ghost states
	-- 	-- print(event, unit, health)
	-- 	UnitButton_UpdateHealth(self)
	-- end)

	UnitButton_UpdateAll(self)
end

local function UnitButton_UnregisterEvents(self)
	self:UnregisterAllEvents()
end

local function UnitButton_OnEvent(self, event, unit)
	if unit and (self.state.displayedUnit == unit or self.state.unit == unit) then
		if  event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE" or event == "UNIT_CONNECTION" then
			self.updateRequired = 1
		
		elseif event == "UNIT_NAME_UPDATE" then
			UnitButton_UpdateName(self)
		
		elseif event == "UNIT_MAXHEALTH" then
			UnitButton_UpdateHealthMax(self)
			UnitButton_UpdateHealth(self)
			UnitButton_UpdateHealthPrediction(self)
			UnitButton_UpdateShieldAbsorbs(self)
			UnitButton_UpdateHealthAbsorbs(self)
	
		elseif event == "UNIT_HEALTH" then
			UnitButton_UpdateHealth(self)
			UnitButton_UpdateHealthPrediction(self)
			UnitButton_UpdateShieldAbsorbs(self)
			-- UnitButton_UpdateStatusText(self)
	
		elseif event == "UNIT_HEAL_PREDICTION" then
			UnitButton_UpdateHealthPrediction(self)
	
		elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
			UnitButton_UpdateShieldAbsorbs(self)
	
		elseif event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
			UnitButton_UpdateHealthAbsorbs(self)
	
		elseif event == "UNIT_MAXPOWER" then
			UnitButton_UpdatePowerMax(self)
			UnitButton_UpdatePower(self)
	
		elseif event == "UNIT_POWER_FREQUENT" then
			UnitButton_UpdatePower(self)
	
		elseif event == "UNIT_DISPLAYPOWER" then
			UnitButton_UpdatePowerMax(self)
			UnitButton_UpdatePower(self)
			UnitButton_UpdatePowerType(self)
	
		elseif event == "UNIT_AURA" then
			UnitButton_UpdateAuras(self)
	
		elseif event == "UNIT_TARGET" then
			UnitButton_UpdateTargetRaidIcon(self)
			
		elseif event == "PLAYER_FLAGS_CHANGED" or event == "UNIT_FLAGS" or event == "INCOMING_SUMMON_CHANGED" then
			UnitButton_UpdateStatusText(self)
			
		elseif event == "UNIT_FACTION" then
			UnitButton_UpdateColor(self) -- mind control
			
		elseif event == "UNIT_THREAT_SITUATION_UPDATE" then
			UnitButton_UpdateThreat(self)

		elseif event == "INCOMING_RESURRECT_CHANGED" or event == "UNIT_PHASE" or event == "PARTY_MEMBER_DISABLE" or event == "PARTY_MEMBER_ENABLE" then
			UnitButton_UpdatePhase(self)
	
		elseif event == "READY_CHECK_CONFIRM" then
			UnitButton_UpdateReadyCheck(self)

		elseif event == "UNIT_PORTRAIT_UPDATE" then -- pet summoned far away
			if self.state.healthMax == 0 then
				self.updateRequired = 1
			end
		end

	else
		if event == "PLAYER_ENTERING_WORLD" or event == "GROUP_ROSTER_UPDATE" then
			self.updateRequired = 1

		elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
			UnitButton_UpdateLeader(self, event)
	
		elseif event == "PLAYER_TARGET_CHANGED" then
			UnitButton_UpdateTarget(self)
			UnitButton_UpdateThreatBar(self)
		
		elseif event == "UNIT_THREAT_LIST_UPDATE" then
			UnitButton_UpdateThreatBar(self)
	
		elseif event == "RAID_TARGET_UPDATE" then
			UnitButton_UpdatePlayerRaidIcon(self)
			UnitButton_UpdateTargetRaidIcon(self)
	
		elseif event == "READY_CHECK" then
			UnitButton_UpdateReadyCheck(self)
	
		elseif event == "READY_CHECK_FINISHED" then
			UnitButton_FinishReadyCheck(self)
		
		elseif event == "ZONE_CHANGED_NEW_AREA" then
			UnitButton_UpdateStatusText(self)

		-- elseif event == "VOICE_CHAT_CHANNEL_ACTIVATED" or event == "VOICE_CHAT_CHANNEL_DEACTIVATED" then
		-- 	VOICE_CHAT_CHANNEL_MEMBER_SPEAKING_STATE_CHANGED
		end
	end
end

local function UnitButton_OnAttributeChanged(self, name, value)
	if name == "unit" then
		wipe(self.state)
		if type(value) == "string" then
			self.state.unit = value
			self.state.displayedUnit = value
			if string.find(value, "raid") then Cell.unitButtons.raid.units[value] = self end
		end
	end
end

-------------------------------------------------
-- unit button show/hide/enter/leave
-------------------------------------------------
local function UnitButton_OnShow(self)
	-- self.updateRequired = nil -- prevent UnitButton_UpdateAll twice. when convert party <-> raid, GROUP_ROSTER_UPDATE fired.
	UnitButton_RegisterEvents(self)
	-- Cell:Fire("UpdateClampRectInsets")
end

local function UnitButton_OnHide(self)
	UnitButton_UnregisterEvents(self)
	-- Cell:Fire("UpdateClampRectInsets")
end

local function UnitButton_OnEnter(self)
	self.widget.mouseoverHighlight:Show()
	
	if CellDB["general"]["disableTooltips"] or InCombatLockdown() then return end
	local unit = self.state.displayedUnit
	if not unit then return end
	
	-- TODO: user defined
	-- GameTooltip:SetOwner(Cell.frames.mainFrame, "ANCHOR_TOPLEFT", 0, 15)
	-- GameTooltip:SetUnit(unit)
	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 15)
	GameTooltip:SetUnit(unit)
end

local function UnitButton_OnLeave(self)
	self.widget.mouseoverHighlight:Hide()
	GameTooltip:Hide()
end

local function UnitButton_OnSizeChanged(self)
	if self.state.name then
		F:UpdateTextWidth(self.widget.nameText, self.state.name)
		
		if self.state.inVehicle then
			F:UpdateTextWidth(self.widget.vehicleText, UnitName(self.state.displayedUnit))
		end
	end
end

local function UnitButton_OnTick(self)
	local e = (self.__tickCount or 0) + 1
	if e >= 4 then -- every 1 second
		e = 0
		local guid = UnitGUID(self.state.displayedUnit or "")
		if guid ~= self.__displayedGuid then
			self.__displayedGuid = guid
			self.updateRequired = 1
		end
	end
	self.__tickCount = e

	UnitButton_UpdateInRange(self)
	
	if self.updateRequired then
		self.updateRequired = nil
		UnitButton_UpdateAll(self)
	end
end

local function UnitButton_OnUpdate(self, elapsed)
	local e = (self.__updateElapsed or 0) + elapsed
	if e > 0.25 then
		UnitButton_OnTick(self)
		e = 0
	end
	self.__updateElapsed = e
end

-------------------------------------------------
-- unit button init
-------------------------------------------------
Cell.vars.texture = "Interface\\AddOns\\Cell\\Media\\statusbar.tga"
-- local startTimeCache, statusCache = {}, {}
local startTimeCache = {}

-- Layer(statusTextFrame) -- frameLevel:27 ----------
-- ARTWORK 
--	statusText, timerText
-------------------------------------------------
-- Layer(overlayFrame) -- frameLevel:7 ----------
-- OVERLAY
--	-7 readyCheckIcon, phaseIcon
-- ARTWORK 
--	top nameText, statusText, timerText, vehicleText
--	-7 playerRaidIcon, roleIcon, leaderIcon
-------------------------------------------------

-- Layer(healthBar) -- frameLevel:5 -----------------
-- ARTWORK 
--	-5 overShieldGlow
--	-6 incomingHeal, damageFlash, absorbsBar
--	-7 shieldBar
-------------------------------------------------

-- Layer(button) -- frameLevel:3 -----------------
-- OVERLAY 
-- ARTWORK 
--	-6 healthBar, powerBar
--	-7 healthBarBackground, powerBarBackground
-- BORDER
--	0 background(button)
-- BACKGROUND
--	0 readyCheckHighlight
--	-1 mouseoverHighlight
--	-2 targetHighlight
-------------------------------------------------
-- BACKGROUND BORDER ARTWORK OVERLAY HIGHLIGHT

function F:UnitButton_OnLoad(button)
	local name = button:GetName()

	button.widget = {}
	button.state = {}
	button.func = {}
	button.indicators = {}

	-- background
	local background = button:CreateTexture(name.."Background", "BORDER")
	button.widget.background = background
	background:SetAllPoints(button)
	background:SetTexture("Interface\\BUTTONS\\WHITE8X8.BLP")
	background:SetVertexColor(0, 0, 0, 1)

    -- border
    -- button:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
	-- button:SetBackdropColor(0, 0, 0, 1)
	-- button:SetBackdropBorderColor(0, 0, 0, 1)
	
    -- healthbar
	local healthBar = CreateFrame("StatusBar", name.."HealthBar", button)
	button.widget.healthBar = healthBar
	healthBar:SetPoint("TOPLEFT", 1, -1)
	healthBar:SetPoint("BOTTOMRIGHT", -1, 4)
	healthBar:SetStatusBarTexture(Cell.vars.texture)
	healthBar:GetStatusBarTexture():SetDrawLayer("ARTWORK", -6)
	healthBar:SetFrameLevel(5)
	
    -- healthbar background 
    local healthBarBackground = button:CreateTexture(name.."HealthBarBackground", "ARTWORK", nil , -7)
	button.widget.healthBarBackground = healthBarBackground
	healthBarBackground:SetAllPoints(healthBar)
	healthBarBackground:SetTexture(Cell.vars.texture)

	-- powerbar
	local powerBar = CreateFrame("StatusBar", name.."PowerBar", button)
	button.widget.powerBar = powerBar
	powerBar:SetPoint("TOPLEFT", healthBar, "BOTTOMLEFT", 0, -1)
	powerBar:SetPoint("BOTTOMRIGHT", -1, 1)
	powerBar:SetStatusBarTexture(Cell.vars.texture)
	powerBar:GetStatusBarTexture():SetDrawLayer("ARTWORK", -6)

	-- powerbar background
	local powerBarBackground = button:CreateTexture(name.."PowerBarBackground", "ARTWORK", nil , -7)
	button.widget.powerBarBackground = powerBarBackground
	powerBarBackground:SetAllPoints(powerBar)
	powerBarBackground:SetTexture(Cell.vars.texture)

	button.func.SetPowerHeight = function(height)
		healthBar:ClearAllPoints()
		healthBar:SetPoint("TOPLEFT", 1, -1)
		healthBar:SetPoint("BOTTOMRIGHT", -1, height==0 and 1 or height+2)
		if height == 0 then
			button:UnregisterEvent("UNIT_POWER_FREQUENT")
			button:UnregisterEvent("UNIT_MAXPOWER")
			button:UnregisterEvent("UNIT_DISPLAYPOWER")
			powerBar:Hide()
			powerBarBackground:Hide()
		else
			if button:IsShown() and not button:IsEventRegistered("UNIT_DISPLAYPOWER") then
				button:RegisterEvent("UNIT_POWER_FREQUENT")
				button:RegisterEvent("UNIT_MAXPOWER")
				button:RegisterEvent("UNIT_DISPLAYPOWER")
				-- update now
				UnitButton_UpdatePowerMax(button)
				UnitButton_UpdatePower(button)
				UnitButton_UpdatePowerType(button)
			end
			powerBar:Show()
			powerBarBackground:Show()
		end
	end
	
	-- incoming heal
	local incomingHeal = healthBar:CreateTexture(name.."IncomingHealBar", "ARTWORK", nil, -6)
	button.widget.incomingHeal = incomingHeal
	incomingHeal:SetPoint("TOPLEFT", healthBar:GetStatusBarTexture(), "TOPRIGHT")
	incomingHeal:SetPoint("BOTTOMLEFT", healthBar:GetStatusBarTexture(), "BOTTOMRIGHT")
	incomingHeal:SetTexture(Cell.vars.texture)
	incomingHeal:SetAlpha(.4)
	incomingHeal:Hide()

	button.func.SetTexture = function(tex)
		healthBar:SetStatusBarTexture(tex)
		healthBarBackground:SetTexture(tex)
		powerBar:SetStatusBarTexture(tex)
		powerBarBackground:SetTexture(tex)
		incomingHeal:SetTexture(tex)
	end

	button.func.UpdateColor = function()
		UnitButton_UpdateColor(button)
		UnitButton_UpdatePowerType(button)
	end

	-- shield bar
	local shieldBar = healthBar:CreateTexture(name.."ShieldBar", "ARTWORK", nil, -7)
	button.widget.shieldBar = shieldBar
	shieldBar:SetPoint("TOPLEFT", healthBar:GetStatusBarTexture(), "TOPRIGHT")
	shieldBar:SetPoint("BOTTOMLEFT", healthBar:GetStatusBarTexture(), "BOTTOMRIGHT")
	shieldBar:SetTexture("Interface\\AddOns\\Cell\\Media\\shield.tga", "REPEAT", "REPEAT")
	shieldBar:SetHorizTile(true)
	shieldBar:SetVertTile(true)
	shieldBar:SetVertexColor(1, 1, 1, .4)
	shieldBar:Hide()

	-- over-shield glow
	local overShieldGlow = healthBar:CreateTexture(name.."OverShieldGlow", "ARTWORK", nil, -5)
	button.widget.overShieldGlow = overShieldGlow
	overShieldGlow:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
	overShieldGlow:SetBlendMode("ADD")
	overShieldGlow:SetPoint("BOTTOMLEFT", healthBar, "BOTTOMRIGHT", -4, 0)
	overShieldGlow:SetPoint("TOPLEFT", healthBar, "TOPRIGHT", -4, 0)
	overShieldGlow:SetWidth(8)
	overShieldGlow:Hide()

	-- absorbs bar
	local absorbsBar = healthBar:CreateTexture(name.."AbsorbsBar", "ARTWORK", nil, -6)
	button.widget.absorbsBar = absorbsBar
	absorbsBar:SetPoint("TOPRIGHT", healthBar:GetStatusBarTexture())
	absorbsBar:SetPoint("BOTTOMRIGHT", healthBar:GetStatusBarTexture())
	absorbsBar:SetTexture("Interface\\AddOns\\Cell\\Media\\shield.tga", "REPEAT", "REPEAT")
	absorbsBar:SetHorizTile(true)
    absorbsBar:SetVertTile(true)
	absorbsBar:SetVertexColor(.5, .1, .1, .7)
	absorbsBar:SetBlendMode("ADD")
	absorbsBar:Hide()

	-- damage flash tex
	do
		local damageFlashTex = healthBar:CreateTexture(name.."DamageFlash", "ARTWORK", nil, -6)
		button.widget.damageFlashTex = damageFlashTex
		damageFlashTex:SetTexture("Interface\\BUTTONS\\WHITE8X8")
		damageFlashTex:SetVertexColor(1, 1, 1, 1)
		damageFlashTex:SetPoint("TOPLEFT", healthBar:GetStatusBarTexture(), "TOPRIGHT")
		damageFlashTex:SetPoint("BOTTOMLEFT", healthBar:GetStatusBarTexture(), "BOTTOMRIGHT")
		damageFlashTex:Hide()

		-- damage flash animation group
		local damageFlashAG = damageFlashTex:CreateAnimationGroup()
		local alpha = damageFlashAG:CreateAnimation("Alpha")
		alpha:SetFromAlpha(1)
		alpha:SetToAlpha(0)
		alpha:SetDuration(0.2)
		damageFlashAG:SetScript("OnFinished", function(self)
			damageFlashTex:Hide()
		end)

		button.func.ShowFlash = function(lostPercent, currentPercent)
			local barWidth = healthBar:GetWidth()
			damageFlashTex:SetWidth(barWidth * lostPercent)
			damageFlashTex:Show()
			damageFlashAG:Play()
		end

		button.func.HideFlash = function()
			damageFlashAG:Finish()
		end
	end

	-- target highlight
	local targetHighlight = button:CreateTexture(name.."TargetHighlight", "BACKGROUND", nil, -2)
	button.widget.targetHighlight = targetHighlight
	targetHighlight:SetPoint("TOPLEFT", -1, 1)
	targetHighlight:SetPoint("BOTTOMRIGHT", 1, -1)
	targetHighlight:SetTexture("Interface\\Buttons\\WHITE8x8")
	targetHighlight:SetVertexColor(1, .19, .19, .5)
	targetHighlight:Hide()
	
	-- mouseover highlight
	local mouseoverHighlight = button:CreateTexture(name.."MouseoverHighlight", "BACKGROUND", nil, -1)
	button.widget.mouseoverHighlight = mouseoverHighlight
	mouseoverHighlight:SetPoint("TOPLEFT", -1, 1)
	mouseoverHighlight:SetPoint("BOTTOMRIGHT", 1, -1)
	mouseoverHighlight:SetTexture("Interface\\Buttons\\WHITE8x8")
	mouseoverHighlight:SetVertexColor(1, 1, 1, .5)
	mouseoverHighlight:Hide()

	button.func.UpdateHighlightColor = function()
		targetHighlight:SetVertexColor(unpack(CellDB["appearance"]["targetColor"]))
		mouseoverHighlight:SetVertexColor(unpack(CellDB["appearance"]["mouseoverColor"]))
	end

	-- readyCheck highlight
	local readyCheckHighlight = button:CreateTexture(name.."ReadyCheckHighlight", "BACKGROUND")
	button.widget.readyCheckHighlight = readyCheckHighlight
	readyCheckHighlight:SetPoint("TOPLEFT", -1, 1)
	readyCheckHighlight:SetPoint("BOTTOMRIGHT", 1, -1)
	readyCheckHighlight:SetTexture("Interface\\Buttons\\WHITE8x8")
	readyCheckHighlight:Hide()

	--* overlayFrame
	local overlayFrame = CreateFrame("Frame", name.."OverlayFrame", button)
	button.widget.overlayFrame = overlayFrame
	overlayFrame:SetFrameLevel(7) -- button:GetFrameLevel() == 3
	overlayFrame:SetAllPoints(button)

	-- name text
	local nameText = overlayFrame:CreateFontString(name.."NameText", "ARTWORK", "CELL_FONT_NAME")
	button.widget.nameText = nameText
	nameText:SetPoint("CENTER", healthBar)

	-- vehicle text
	local vehicleText = overlayFrame:CreateFontString(name.."VehicleText", "ARTWORK", "CELL_FONT_STATUS")
	button.widget.vehicleText = vehicleText
	vehicleText:SetPoint("TOP", healthBar, 0, -1)
	vehicleText:SetTextColor(.8, .8, .8, 1)

	-- status text
	local statusTextFrame = CreateFrame("Frame", name.."StatusTextFrame", overlayFrame)
	button.widget.statusTextFrame = statusTextFrame
	-- statusTextFrame:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
	-- statusTextFrame:SetBackdropColor(.1, .1, .1, .6)
	statusTextFrame:SetFrameLevel(27)
	statusTextFrame:Hide()

	local statusText = statusTextFrame:CreateFontString(name.."StatusText", "ARTWORK", "CELL_FONT_STATUS")
	button.widget.statusText = statusText
	statusText:SetPoint("BOTTOMLEFT", healthBar)
	statusText:SetTextColor(1, .19, .19)

	statusTextFrame:SetPoint("BOTTOMLEFT", healthBar)
	statusTextFrame:SetPoint("BOTTOMRIGHT", healthBar)
	statusTextFrame:SetPoint("TOP", statusText, 0, 2)

	-- afk/offline timer
	local timerText = statusTextFrame:CreateFontString(name.."TimerText", "ARTWORK", "CELL_FONT_STATUS")
	button.widget.timerText = timerText
	timerText:SetPoint("BOTTOMRIGHT", healthBar)
	timerText:SetTextColor(1, .19, .19)
	timerText:SetJustifyH("RIGHT")

	button.func.ShowTimer = function(status)
		timerText:Show()
		-- if statusCache[button.state.guid] ~= status then
		-- 	startTimeCache[button.state.guid] = GetTime()
		-- end
		-- statusCache[button.state.guid] = status
		if not startTimeCache[button.state.guid] then startTimeCache[button.state.guid] = GetTime() end
		
		button.func.UpdateTimer = C_Timer.NewTicker(1, function()
			if not button.state.guid and button.state.unit then -- ElvUI AFK mode
				button.state.guid = UnitGUID(button.state.unit)
			end
			if button.state.guid and startTimeCache[button.state.guid] then
				timerText:SetFormattedText(F:FormatTime(GetTime() - startTimeCache[button.state.guid]))
			else
				timerText:SetText("")
			end
		end)
	end

	button.func.HideTimer = function(reset)
		timerText:Hide()
		timerText:SetText("")
		if reset then
			if button.func.UpdateTimer then button.func.UpdateTimer:Cancel() end
			startTimeCache[button.state.guid] = nil
			-- statusCache[button.state.guid] = nil
		end
	end
	
	-- role icon
	local roleIcon = overlayFrame:CreateTexture(name.."RoleIcon", "ARTWORK", nil, -7)
	button.widget.roleIcon = roleIcon
	roleIcon:SetPoint("TOPLEFT", overlayFrame)
	roleIcon:SetSize(11, 11)

	-- leader icon
	local leaderIcon = overlayFrame:CreateTexture(name.."LeaderIcon", "ARTWORK", nil, -7)
	button.widget.leaderIcon = leaderIcon
	leaderIcon:SetPoint("TOP", roleIcon, "BOTTOM")
	leaderIcon:SetSize(11, 11)
	leaderIcon:Hide()

	-- Ready check icon
	local readyCheckIcon = overlayFrame:CreateTexture(name.."ReadyCheckIcon", "OVERLAY", nil, -7)
	button.widget.readyCheckIcon = readyCheckIcon
	readyCheckIcon:SetSize(16, 16)
	readyCheckIcon:SetPoint("CENTER", healthBar)
	readyCheckIcon:Hide()

	-- phase icon
	local phaseIcon = overlayFrame:CreateTexture(name.."PhaseIcon", "OVERLAY", nil, -7)
	button.widget.phaseIcon = phaseIcon
	phaseIcon:SetSize(16, 16)
	phaseIcon:SetPoint("TOP", healthBar)
	phaseIcon:Hide()

	-- aggro indicator
	local aggroIndicator = CreateFrame("Frame", name.."AggroIndicator", overlayFrame, "BackdropTemplate") -- framelevel 8
	button.widget.aggroIndicator = aggroIndicator
	aggroIndicator:SetPoint("TOPLEFT")
	aggroIndicator:SetSize(10, 10)
	aggroIndicator:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
	aggroIndicator:SetBackdropColor(1, 0, 0, 1)
	aggroIndicator:SetBackdropBorderColor(0, 0, 0, 1)
	aggroIndicator:Hide()

	do
		local blink = aggroIndicator:CreateAnimationGroup()
		aggroIndicator.blink = blink
		blink:SetLooping("REPEAT")

		local alpha = blink:CreateAnimation("Alpha")
		alpha:SetFromAlpha(1)
		alpha:SetToAlpha(0)
		alpha:SetDuration(0.5)
	end
	
	aggroIndicator:SetScript("OnShow", function(self)
		self.blink:Play()
	end)
	
	aggroIndicator:SetScript("OnHide", function(self)
		self.blink:Stop()
	end)

	local aggroBar = Cell:CreateStatusBar(overlayFrame, 18, 2, 100, true)
	button.indicators.aggroBar = aggroBar
	-- aggroBar:SetPoint("BOTTOMLEFT", overlayFrame, "TOPLEFT", 1, 0)
	aggroBar:Hide()

	-- raidIcons
	button.func.UpdatePlayerRaidIcon = function(enabled)
		UnitButton_UpdatePlayerRaidIcon(button)
		if enabled then
			button:RegisterEvent("RAID_TARGET_UPDATE")
		else
			button:UnregisterEvent("RAID_TARGET_UPDATE")
		end
	end
	button.func.UpdateTargetRaidIcon = function(enabled)
		UnitButton_UpdateTargetRaidIcon(button)
		if enabled then
			button:RegisterEvent("UNIT_TARGET")
		else
			button:UnregisterEvent("UNIT_TARGET")
		end
	end

	-- healthText
	button.func.UpdateHealthText = function()
		if button.state.displayedUnit then
			UpdateUnitHealthState(button)
		end
	end

	-- indicators
	I:CreatePlayerRaidIcon(button)
	I:CreateTargetRaidIcon(button)
	I:CreateAoEHealing(button)
	I:CreateDefensiveCooldowns(button)
	I:CreateExternalCooldowns(button)
	I:CreateTankActiveMitigation(button)
	I:CreateDebuffs(button)
	I:CreateDispels(button)
	I:CreateCentralDebuff(button)
	I:CreateHealthText(button)

	-- events
	button:SetScript("OnAttributeChanged", UnitButton_OnAttributeChanged) -- init
	button:HookScript("OnShow", UnitButton_OnShow)
	button:HookScript("OnHide", UnitButton_OnHide)
	button:HookScript("OnEnter", UnitButton_OnEnter) -- SecureHandlerEnterLeaveTemplate
	button:HookScript("OnLeave", UnitButton_OnLeave) -- SecureHandlerEnterLeaveTemplate
	button:SetScript("OnUpdate", UnitButton_OnUpdate)
	button:SetScript("OnEvent", UnitButton_OnEvent)
	button:SetScript("OnSizeChanged", UnitButton_OnSizeChanged)
	button:RegisterForClicks("AnyDown")
end