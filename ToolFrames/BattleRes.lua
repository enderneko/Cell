local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

-------------------------------------------------
-- battle res
-------------------------------------------------
local battleResFrame = CreateFrame("Frame", "CellBattleResFrame", Cell.frames.mainFrame, "BackdropTemplate")
Cell.frames.battleResFrame = battleResFrame
-- battleResFrame:SetPoint("BOTTOMLEFT", Cell.frames.mainFrame, "TOPLEFT", 0, 17)
battleResFrame:SetSize(75, 20)
battleResFrame:Hide()
Cell:StylizeFrame(battleResFrame, {.1, .1, .1, .7}, {0, 0, 0, .5})

---------------------------------
-- Animation
---------------------------------
local point, relativePoint, onShow, onHide
local relativeTo = Cell.frames.anchorFrame
local loaded = false

battleResFrame.onMenuShow = battleResFrame:CreateAnimationGroup()
battleResFrame.onMenuShow.trans = battleResFrame.onMenuShow:CreateAnimation("translation")
battleResFrame.onMenuShow.trans:SetDuration(.3)
battleResFrame.onMenuShow.trans:SetSmoothing("OUT")
battleResFrame.onMenuShow:SetScript("OnPlay", function()
    battleResFrame.onMenuHide:Stop()
end)
battleResFrame.onMenuShow:SetScript("OnFinished", function()
    battleResFrame:ClearAllPoints()
    battleResFrame:SetPoint(point, relativeTo, relativePoint, 0, onShow)
end)

function battleResFrame:OnMenuShow()
    if not loaded then return end

    if not battleResFrame:IsShown() then
        battleResFrame.onMenuShow:GetScript("OnFinished")()
        return
    end

    local currentY = select(5, battleResFrame:GetPoint(1))
    if type(currentY) ~= "number" then return end
    currentY = math.floor(currentY+.5)

    if onShow ~= currentY then
        local offset = onShow-currentY
        battleResFrame.onMenuShow.trans:SetOffset(0, offset)
        battleResFrame.onMenuShow:Play()
    end
end

battleResFrame.onMenuHide = battleResFrame:CreateAnimationGroup()
battleResFrame.onMenuHide.trans = battleResFrame.onMenuHide:CreateAnimation("translation")
battleResFrame.onMenuHide.trans:SetDuration(.3)
battleResFrame.onMenuHide.trans:SetSmoothing("OUT")
battleResFrame.onMenuHide:SetScript("OnPlay", function()
    battleResFrame.onMenuShow:Stop()
end)
battleResFrame.onMenuHide:SetScript("OnFinished", function()
    battleResFrame:ClearAllPoints()
    battleResFrame:SetPoint(point, relativeTo, relativePoint, 0, onHide)
end)

function battleResFrame:OnMenuHide()
    if not loaded then return end

    if not battleResFrame:IsShown() then
        battleResFrame.onMenuHide:GetScript("OnFinished")()
        return
    end

    local currentY = select(5, battleResFrame:GetPoint(1))
    if type(currentY) ~= "number" then return end
    currentY = math.floor(currentY+.5)

    if onHide ~= currentY then
        local offset = onHide-currentY
        battleResFrame.onMenuHide.trans:SetOffset(0, offset)
        battleResFrame.onMenuHide:Play()
    end
end

---------------------------------
-- Bar
---------------------------------
local bar = Cell:CreateStatusBar(battleResFrame, 10, 2, 100, false, nil, false, "Interface\\AddOns\\Cell\\Media\\statusbar", Cell:GetPlayerClassColorTable())
bar:SetPoint("BOTTOMLEFT", battleResFrame, 1, 1)
bar:SetPoint("BOTTOMRIGHT", battleResFrame, -1, 1)
-- bar:SetMinMaxValues(0, 100)
-- bar:SetValue(50)

---------------------------------
-- String
---------------------------------
local title = battleResFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
local stack = battleResFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
local rTime = battleResFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
local dummy = battleResFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET") -- used for updating width of battleResFrame
dummy:Hide()

title:SetFont(title:GetFont(), 13)
stack:SetFont(stack:GetFont(), 13)
rTime:SetFont(rTime:GetFont(), 13)
dummy:SetFont(dummy:GetFont(), 13)

title:SetJustifyH("LEFT")
stack:SetJustifyH("LEFT")
rTime:SetJustifyH("RIGHT")

title:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", 0, 2)
stack:SetPoint("LEFT", title, "RIGHT")
-- rTime:SetPoint("BOTTOMRIGHT", bar, "TOPRIGHT", -1, 2)
rTime:SetPoint("LEFT", stack, "RIGHT")
dummy:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", 0, 22)

title:SetTextColor(.66, .66, .66)
rTime:SetTextColor(.66, .66, .66)

title:SetText(L["BR"]..": ")
stack:SetText("")
rTime:SetText("")
dummy:SetText(L["BR"]..": |cffff00000|r  00:00 ")

battleResFrame:SetScript("OnShow", function()
    battleResFrame:SetWidth(math.floor(dummy:GetWidth()+.5))
end)

battleResFrame:SetScript("OnHide", function()
    stack:SetText("")
    rTime:SetText("")
end)

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
        
        -- Upon engaging a boss, all combat resurrection spells will have their cooldowns reset and begin with 1 charge.
        -- Charges will accumulate at a rate of 1 per (90/RaidSize) minutes.
        local charges, _, started, duration = GetSpellCharges(20484)
        if not charges then
            -- hide out of encounter
            battleResFrame:Hide()
            battleResFrame:RegisterEvent("SPELL_UPDATE_CHARGES")
            return
        end
        
        local color = (charges > 0) and "|cffffffff" or "|cffff0000"
        local remaining = duration - (GetTime() - started)
        local m = floor(remaining / 60)
        local s = mod(remaining, 60)

        stack:SetText(("%s%d|r  "):format(color, charges))
        rTime:SetText(("%d:%02d"):format(m, s))
        
        bar:SetMinMaxValues(0, duration)
        bar:SetValue(duration - remaining)
    end
end)

function battleResFrame:SPELL_UPDATE_CHARGES()
    local charges = GetSpellCharges(20484)
    if charges then
        battleResFrame:UnregisterEvent("SPELL_UPDATE_CHARGES")
        -- isMovable = false
        battleResFrame:Show()
    end
end

function battleResFrame:PLAYER_ENTERING_WORLD()
    battleResFrame:UnregisterEvent("SPELL_UPDATE_CHARGES")
    battleResFrame:Hide()
    
    local _, instanceType, difficulty = GetInstanceInfo()

    if instanceType == "raid" then -- raid
        if IsEncounterInProgress() then --如果 上线时/重载界面后 已在boss战中
            battleResFrame:Show()
        else
            battleResFrame:RegisterEvent("SPELL_UPDATE_CHARGES")
        end
    
    elseif difficulty == 8 then -- challenge mode
        battleResFrame:Show()
    end
end

function battleResFrame:CHALLENGE_MODE_START()
    battleResFrame:Show()
end

battleResFrame:SetScript("OnEvent", function(self, event, ...)
    battleResFrame[event](self, ...)
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

    if not loaded or which == "anchor" then
        battleResFrame:ClearAllPoints()

        if layout["anchor"] == "BOTTOMLEFT" then
            point, relativePoint = "TOPLEFT", "BOTTOMLEFT"
            onShow, onHide = -4, 10
            
        elseif layout["anchor"] == "BOTTOMRIGHT" then
            point, relativePoint = "TOPRIGHT", "BOTTOMRIGHT"
            onShow, onHide = -4, 10
            
        elseif layout["anchor"] == "TOPLEFT" then
            point, relativePoint = "BOTTOMLEFT", "TOPLEFT"
            onShow, onHide = 4, -10
            
        elseif layout["anchor"] == "TOPRIGHT" then
            point, relativePoint = "BOTTOMRIGHT", "TOPRIGHT"
            onShow, onHide = 4, -10
        end

        if CellDB["general"]["fadeOut"] then
            battleResFrame:SetPoint(point, relativeTo, relativePoint, 0, onHide)
        else
            battleResFrame:SetPoint(point, relativeTo, relativePoint, 0, onShow)
        end
        loaded = true
    end
end
Cell:RegisterCallback("UpdateLayout", "BattleRes_UpdateLayout", UpdateLayout)