local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
---@type PixelPerfectFuncs
local P = Cell.pixelPerfectFuncs

local battleResMover

-------------------------------------------------
-- battle res
-------------------------------------------------
local battleResFrame = CreateFrame("Frame", "CellBattleResFrame", Cell.frames.mainFrame, "BackdropTemplate")
Cell.frames.battleResFrame = battleResFrame
battleResFrame:SetFrameLevel(5)
P.Size(battleResFrame, 80, 20)
battleResFrame:Hide()
Cell.StylizeFrame(battleResFrame, {0.1, 0.1, 0.1, 0.7}, {0, 0, 0, 0.5})

--------------------------------------------------
-- animation
--------------------------------------------------
local point, relativePoint, onShow, onHide
local loaded = false

battleResFrame.onMenuShow = battleResFrame:CreateAnimationGroup()
battleResFrame.onMenuShow.trans = battleResFrame.onMenuShow:CreateAnimation("translation")
battleResFrame.onMenuShow.trans:SetDuration(0.3)
battleResFrame.onMenuShow.trans:SetSmoothing("OUT")
battleResFrame.onMenuShow:SetScript("OnPlay", function()
    battleResFrame.onMenuHide:Stop()
end)
battleResFrame.onMenuShow:SetScript("OnFinished", function()
    battleResFrame:ClearAllPoints()
    battleResFrame:SetPoint(point, CellAnchorFrame, relativePoint, 0, onShow)
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
battleResFrame.onMenuHide.trans:SetDuration(0.3)
battleResFrame.onMenuHide.trans:SetSmoothing("OUT")
battleResFrame.onMenuHide:SetScript("OnPlay", function()
    battleResFrame.onMenuShow:Stop()
end)
battleResFrame.onMenuHide:SetScript("OnFinished", function()
    battleResFrame:ClearAllPoints()
    battleResFrame:SetPoint(point, CellAnchorFrame, relativePoint, 0, onHide)
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

--------------------------------------------------
-- bar
--------------------------------------------------
local bar = Cell.CreateStatusBar("CellBattleResBar", battleResFrame, 10, 4, 100, false, nil, false, "Interface\\AddOns\\Cell\\Media\\statusbar", Cell.GetAccentColorTable())
bar:SetPoint("BOTTOMLEFT")
bar:SetPoint("BOTTOMRIGHT")
-- P.Point(bar, "BOTTOMLEFT", battleResFrame, "BOTTOMLEFT", 1, 1)
-- P.Point(bar, "BOTTOMRIGHT", battleResFrame, "BOTTOMRIGHT", -1, 1)
-- bar:SetMinMaxValues(0, 100)
-- bar:SetValue(50)

--------------------------------------------------
-- texts
--------------------------------------------------
local title = battleResFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
local stack = battleResFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
local rTime = battleResFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
local dummy = battleResFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET") -- used for updating width of battleResFrame
dummy:Hide()

title:SetFont(title:GetFont(), 13, "")
stack:SetFont(stack:GetFont(), 13, "")
rTime:SetFont(rTime:GetFont(), 13, "")
dummy:SetFont(dummy:GetFont(), 13, "")

title:SetJustifyH("LEFT")
stack:SetJustifyH("LEFT")
rTime:SetJustifyH("RIGHT")

P.Point(title, "BOTTOMLEFT", bar, "TOPLEFT", 2, 1)
stack:SetPoint("LEFT", title, "RIGHT")
rTime:SetPoint("LEFT", stack, "RIGHT")
P.Point(dummy, "BOTTOMLEFT", bar, "TOPLEFT", 2, 1)
-- dummy:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", 0, 22)

title:SetTextColor(0.66, 0.66, 0.66)
rTime:SetTextColor(0.66, 0.66, 0.66)

title:SetText(L["BR"]..": ")
stack:SetText("")
rTime:SetText("")
dummy:SetText(L["BR"]..": |cffff00000|r  00:00 ")

battleResFrame:SetScript("OnShow", function()
    battleResFrame.elapsed = 0.25
    battleResFrame:SetWidth(math.ceil(dummy:GetWidth()))
    battleResMover:SetWidth(math.ceil(dummy:GetWidth()))
end)

battleResFrame:SetScript("OnHide", function()
    stack:SetText("")
    rTime:SetText("")
end)

--------------------------------------------------
-- Update
--------------------------------------------------
local GetSpellCharges = C_Spell.GetSpellCharges
local function GetBRInfo()
    local info = GetSpellCharges(20484)
    if info then
        return info.currentCharges, info.cooldownStartTime, info.cooldownDuration
    end
end

battleResFrame.elapsed = 0.25
battleResFrame.onUpdate = function(self, elapsed)
    battleResFrame.elapsed = battleResFrame.elapsed + elapsed
    if battleResFrame.elapsed >= 0.25 then
        battleResFrame.elapsed = 0

        -- Upon engaging a boss, all combat resurrection spells will have their cooldowns reset and begin with 1 charge.
        -- Charges will accumulate at a rate of 1 per (90/RaidSize) minutes.
        local charges, started, duration = GetBRInfo()
        if not charges then
            -- hide out of encounter
            battleResFrame:Hide()
            battleResFrame:RegisterEvent("SPELL_UPDATE_CHARGES")
            return
        end

        local color = (charges > 0) and "|cff00ff00" or "|cffff0000"
        local remaining = duration - (GetTime() - started)
        local m = floor(remaining / 60)
        local s = mod(remaining, 60)

        stack:SetFormattedText("%s%d|r  ", color, charges)
        rTime:SetFormattedText("%d:%02d", m, s)

        if bar.maxVlue ~= duration then
            bar:SetMinMaxValues(0, duration)
            bar.maxVlue = duration
        end
        bar:SetValue(duration - remaining)
    end
end

battleResFrame:SetScript("OnUpdate", battleResFrame.onUpdate)

function battleResFrame:SPELL_UPDATE_CHARGES()
    local charges = GetBRInfo()
    if charges then
        battleResFrame:UnregisterEvent("SPELL_UPDATE_CHARGES")
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

-------------------------------------------------
-- mover
-------------------------------------------------
battleResMover = CreateFrame("Frame", nil, Cell.frames.mainFrame, "BackdropTemplate")
P.Size(battleResMover, 80, 40)
Cell.StylizeFrame(battleResMover, {0, 1, 0, 0.4}, {0, 0, 0, 0})
battleResMover:SetClampedToScreen(true)
-- battleResMover:SetClampRectInsets(0, 0, -20, 0)
battleResMover:SetFrameLevel(1)
battleResMover:SetMovable(true)
battleResMover:EnableMouse(true)
battleResMover:RegisterForDrag("LeftButton")
battleResMover:Hide()

battleResMover:SetScript("OnDragStart", function()
    battleResMover:StartMoving()
    battleResMover:SetUserPlaced(false)
end)

battleResMover:SetScript("OnDragStop", function()
    battleResMover:StopMovingOrSizing()
    P.SavePosition(battleResMover, CellDB["tools"]["battleResTimer"][3])
end)

battleResMover.text = battleResMover:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
battleResMover.text:SetPoint("TOP", 0, -3)
battleResMover.text:SetText(L["Mover"])

local function MoverShow()
    battleResMover:Show()
    if not battleResFrame:IsShown() then
        battleResFrame:SetScript("OnUpdate", nil)
        battleResFrame:Show()
        dummy:Show()
        title:Hide()
        stack:Hide()
        rTime:Hide()
    end
end

local function MoverHide()
    battleResMover:Hide()
    dummy:Hide()
    title:Show()
    stack:Show()
    rTime:Show()
    battleResFrame:SetScript("OnUpdate", battleResFrame.onUpdate)
end

local function ShowMover(show)
    shouldShowMover = show

    if show then
        if CellDB["tools"]["battleResTimer"][1] and CellDB["tools"]["battleResTimer"][2] then
            MoverShow()
        end
    else
        MoverHide()
    end
end
Cell.RegisterCallback("ShowMover", "BattleResTimer_ShowMover", ShowMover)

--------------------------------------------------
-- position
--------------------------------------------------
local function UpdatePosition()
    if CellDB["tools"]["battleResTimer"][2] then return end
    loaded = true

    local anchor = Cell.vars.currentLayoutTable["main"]["anchor"]
    battleResFrame:ClearAllPoints()

    if anchor == "BOTTOMLEFT" then
        point, relativePoint = "TOPLEFT", "BOTTOMLEFT"
        onShow, onHide = -4, 10

    elseif anchor == "BOTTOMRIGHT" then
        point, relativePoint = "TOPRIGHT", "BOTTOMRIGHT"
        onShow, onHide = -4, 10

    elseif anchor == "TOPLEFT" then
        point, relativePoint = "BOTTOMLEFT", "TOPLEFT"
        onShow, onHide = 4, -10

    elseif anchor == "TOPRIGHT" then
        point, relativePoint = "BOTTOMRIGHT", "TOPRIGHT"
        onShow, onHide = 4, -10
    end

    if CellDB["general"]["menuPosition"] == "top_bottom" then
        if CellDB["general"]["fadeOut"] then
            battleResFrame:SetPoint(point, CellAnchorFrame, relativePoint, 0, onHide)
        else
            battleResFrame:SetPoint(point, CellAnchorFrame, relativePoint, 0, onShow)
        end
    else
        battleResFrame:SetPoint(point, CellMainFrame, relativePoint, 0, onShow)
    end
end

--------------------------------------------------
-- callbacks
--------------------------------------------------
local function UpdateTools(which)
    if not which or which == "battleResTimer" then
        if CellDB["tools"]["battleResTimer"][1] then
            battleResFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
            battleResFrame:RegisterEvent("CHALLENGE_MODE_START")
            battleResFrame:RegisterEvent("SPELL_UPDATE_CHARGES")

            if CellDB["tools"]["battleResTimer"][2] then
                if shouldShowMover then
                    MoverShow()
                end
                P.ClearPoints(battleResFrame)
                battleResFrame:SetPoint("BOTTOMLEFT", battleResMover)
                if not P.LoadPosition(battleResMover, CellDB["tools"]["battleResTimer"][3]) then
                    PixelUtil.SetPoint(battleResMover, "TOPLEFT", CellParent, "CENTER", 1, -100)
                end
            else
                MoverHide()
                UpdatePosition()
            end
        else
            battleResFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
            battleResFrame:UnregisterEvent("CHALLENGE_MODE_START")
            battleResFrame:UnregisterEvent("SPELL_UPDATE_CHARGES")
            MoverHide()
        end
    end
end
Cell.RegisterCallback("UpdateTools", "BattleResTimer_UpdateTools", UpdateTools)

local function UpdateMenu(which)
    if which == "position" then
        UpdatePosition()
    end
end
Cell.RegisterCallback("UpdateMenu", "BattleRes_UpdateMenu", UpdateMenu)

local function UpdateLayout(layout, which)
    if not which or which == "anchor" then
        UpdatePosition()
    end
end
Cell.RegisterCallback("UpdateLayout", "BattleRes_UpdateLayout", UpdateLayout)

local function UpdatePixelPerfect()
    P.Resize(battleResFrame)
    P.Resize(battleResMover)
    Cell.StylizeFrame(battleResFrame, {0.1, 0.1, 0.1, 0.7}, {0, 0, 0, 0.5})
    bar:UpdatePixelPerfect()
    P.Repoint(title)
    P.Repoint(dummy)
end
Cell.RegisterCallback("UpdatePixelPerfect", "BattleRes_UpdatePixelPerfect", UpdatePixelPerfect)