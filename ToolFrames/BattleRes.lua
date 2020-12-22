local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

-------------------------------------------------
-- battle res
-------------------------------------------------
local battleResFrame = CreateFrame("Frame", "CellBattleResFrame", Cell.frames.mainFrame, "BackdropTemplate")
Cell.frames.battleResFrame = battleResFrame
-- battleResFrame:SetPoint("BOTTOMLEFT", Cell.frames.mainFrame, "TOPLEFT", 0, 17)
battleResFrame:SetSize(72, 20)
battleResFrame:Hide()
Cell:StylizeFrame(battleResFrame, {.1, .1, .1, .7}, {0, 0, 0, .5})

---------------------------------
-- Animation
---------------------------------
local onShow, onHide

battleResFrame.onMenuShow = battleResFrame:CreateAnimationGroup()
battleResFrame.onMenuShow.trans = battleResFrame.onMenuShow:CreateAnimation("translation")
battleResFrame.onMenuShow.trans:SetDuration(.3)
battleResFrame.onMenuShow.trans:SetSmoothing("OUT")
battleResFrame.onMenuShow:SetScript("OnPlay", function()
	battleResFrame.onMenuHide:Stop()
end)
battleResFrame.onMenuShow:SetScript("OnFinished", function()
	local p, rt, rp, x, y = battleResFrame:GetPoint(1)
	battleResFrame:ClearAllPoints()
	local yofs = select(2, battleResFrame.onMenuShow.trans:GetOffset())
	battleResFrame:SetPoint(p, rt, rp, x, y+yofs)
end)

function battleResFrame:OnMenuShow()
	local currentY = select(5, battleResFrame:GetPoint(1))
	if not currentY then return end
	currentY = math.floor(currentY+.5)
	battleResFrame.onMenuShow.trans:SetOffset(0, onShow-currentY)
	battleResFrame.onMenuShow:Play()
end

battleResFrame.onMenuHide = battleResFrame:CreateAnimationGroup()
battleResFrame.onMenuHide.trans = battleResFrame.onMenuHide:CreateAnimation("translation")
battleResFrame.onMenuHide.trans:SetDuration(.3)
battleResFrame.onMenuHide.trans:SetSmoothing("OUT")
battleResFrame.onMenuHide:SetScript("OnPlay", function()
	battleResFrame.onMenuShow:Stop()
end)
battleResFrame.onMenuHide:SetScript("OnFinished", function()
	local p, rt, rp, x, y = battleResFrame:GetPoint(1)
	battleResFrame:ClearAllPoints()
	local yofs = select(2, battleResFrame.onMenuHide.trans:GetOffset())
	battleResFrame:SetPoint(p, rt, rp, x, y+yofs)
end)

function battleResFrame:OnMenuHide()
	local currentY = select(5, battleResFrame:GetPoint(1))
	if not currentY then return end
	currentY = math.floor(currentY+.5)
	battleResFrame.onMenuHide.trans:SetOffset(0, onHide-currentY)
	battleResFrame.onMenuHide:Play()
end

---------------------------------
-- Bar
---------------------------------
local bar = Cell:CreateStatusBar(battleResFrame, 10, 2, 100, false, nil, false, "Interface\\Buttons\\WHITE8x8", Cell:GetPlayerClassColorTable())
bar:SetPoint("BOTTOMLEFT", battleResFrame, 1, 1)
bar:SetPoint("BOTTOMRIGHT", battleResFrame, -1, 1)
bar:SetAlpha(.5)

---------------------------------
-- String
---------------------------------
local title = battleResFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
local stack = battleResFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
local rTime = battleResFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")

title:SetFont(title:GetFont(), 13)
-- title:SetShadowColor(0, 0, 0)
-- title:SetShadowOffset(0, 0)
stack:SetFont(stack:GetFont(), 13)
-- stack:SetShadowColor(0, 0, 0)
-- stack:SetShadowOffset(0, 0)
rTime:SetFont(rTime:GetFont(), 13)
-- rTime:SetShadowColor(0, 0, 0)
-- rTime:SetShadowOffset(0, 0)

title:SetJustifyH("LEFT")
stack:SetJustifyH("LEFT")
rTime:SetJustifyH("RIGHT")

title:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", 0, 1)
stack:SetPoint("LEFT", title, "RIGHT")
-- stack:SetPoint("BOTTOM", bar, "TOP", 0, 1)
rTime:SetPoint("BOTTOMRIGHT", bar, "TOPRIGHT", 0, 1)

title:SetTextColor(.66, .66, .66)
rTime:SetTextColor(.66, .66, .66)

title:SetText(L["BR"]..": ")
stack:SetText("|cffff00000|r")
rTime:SetText("")

---------------------------------
-- Update
---------------------------------
local total = 0
-- local isMovable = false

battleResFrame:SetScript("OnUpdate", function(self, elapsed)
	-- if isMovable then return end --设置位置

	total = total + elapsed
	if total >= 0.25 then
		total = 0
		
		local charges, _, started, duration = GetSpellCharges(20484)
		if not charges then
			-- hide out of encounter
			self:Hide()
			self:RegisterEvent("SPELL_UPDATE_CHARGES")
			return
		end
		
		local color = (charges > 0) and "|cffffffff" or "|cffff0000"
		local remaining = duration - (GetTime() - started)
		local m = floor(remaining / 60)
		local s = mod(remaining, 60)

		rTime:SetText(("%d:%02d"):format(m, s))
		stack:SetText(("%s%d|r"):format(color, charges))
		bar:SetMinMaxValues(0, duration)
		bar:SetValue(duration - remaining)
	end
end)

function battleResFrame:SPELL_UPDATE_CHARGES()
	local charges = GetSpellCharges(20484)
	if charges then
		self:UnregisterEvent("SPELL_UPDATE_CHARGES")
		-- isMovable = false
		self:Show()
	end
end

function battleResFrame:PLAYER_ENTERING_WORLD()
	self:UnregisterEvent("SPELL_UPDATE_CHARGES")
    self:Hide()
    
	local _, instanceType, difficulty = GetInstanceInfo()
	-- raid
	if instanceType == "raid" then
		if IsEncounterInProgress() then --如果 上线时/重载界面后 已在boss战中
			self:Show()
		else
			self:RegisterEvent("SPELL_UPDATE_CHARGES")
		end
	end
	-- challenge mode
	if difficulty == 8 then
		self:Show()
	end
end

function battleResFrame:CHALLENGE_MODE_START()
	self:Show()
end

battleResFrame:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)

local function UpdateRaidTools(which)
    if not which or which == "battleRes" then
        if CellDB["raidTools"]["showBattleRes"] then
            battleResFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
            battleResFrame:RegisterEvent("CHALLENGE_MODE_START")
            battleResFrame:RegisterEvent("SPELL_UPDATE_CHARGES")
        else
            battleResFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
            battleResFrame:UnregisterEvent("CHALLENGE_MODE_START")
            battleResFrame:UnregisterEvent("SPELL_UPDATE_CHARGES")
        end
    end
end
Cell:RegisterCallback("UpdateRaidTools", "BattleRes_UpdateRaidTools", UpdateRaidTools)

local function UpdateLayout(layout, which)
    layout = Cell.vars.currentLayoutTable

	battleResFrame:ClearAllPoints()

    if not which or which == "anchor" then
        if layout["anchor"] == "BOTTOMLEFT" then
            battleResFrame:SetPoint("TOPLEFT", Cell.frames.anchorFrame, "BOTTOMLEFT", 0, -4)
			onShow, onHide = -4, 10
            
        elseif layout["anchor"] == "BOTTOMRIGHT" then
            battleResFrame:SetPoint("TOPRIGHT", Cell.frames.anchorFrame, "BOTTOMRIGHT", 0, -4)
			onShow, onHide = -4, 10
            
        elseif layout["anchor"] == "TOPLEFT" then
			battleResFrame:SetPoint("BOTTOMLEFT", Cell.frames.anchorFrame, "TOPLEFT", 0, 4)
			onShow, onHide = 4, -10
            
        elseif layout["anchor"] == "TOPRIGHT" then
            battleResFrame:SetPoint("BOTTOMRIGHT", Cell.frames.anchorFrame, "TOPRIGHT", 0, 4)
			onShow, onHide = 4, -10
        end
    end
end
Cell:RegisterCallback("UpdateLayout", "BattleRes_UpdateLayout", UpdateLayout)