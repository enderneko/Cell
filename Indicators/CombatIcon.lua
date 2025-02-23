local _, Cell = ...
---@type CellFuncs
local F = Cell.funcs
---@class CellIndicatorFuncs
local I = Cell.iFuncs
---@type PixelPerfectFuncs
local P = Cell.pixelPerfectFuncs

local UnitAffectingCombat = UnitAffectingCombat

--------------------------------------------------
-- combat icon
--------------------------------------------------
local function CombatIcon_Update(self)
    local unit = self.root.states.displayedUnit
    print(unit)
    if unit and UnitAffectingCombat(unit) then
        self:Show()
    else
        self:Hide()
    end
end

local function CombatIcon_StopTicker(self)
    if self.ticker then
        self.ticker:Cancel()
        self.ticker = nil
    end
end

local function CombatIcon_StartTicker(self)
    CombatIcon_StopTicker(self)
    self.ticker = C_Timer.NewTicker(0.2, function()
        CombatIcon_Update(self)
    end)
end

local function CombatIcon_Enable(self)
    if self.onlyOutOfCombat then
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        self:RegisterEvent("PLAYER_REGEN_DISABLED")
        if not InCombatLockdown() then
            CombatIcon_StartTicker(self)
        end
    else
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        self:UnregisterEvent("PLAYER_REGEN_DISABLED")
        CombatIcon_StartTicker(self)
    end
end

local function CombatIcon_Disable(self)
    CombatIcon_StopTicker(self)
    self:Hide()
end

local function CombatIcon_OnEvent(self, event)
    if event == "PLAYER_REGEN_ENABLED" then
        CombatIcon_StartTicker(self)
    elseif event == "PLAYER_REGEN_DISABLED" then
        CombatIcon_StopTicker(self)
        self:Hide()
    end
end

local function CombatIcon_LoadConfig(self, config)
    P.Size(self, config.size[1], config.size[2])
    P.Point(self, config.position[1], self.root, config.position[2], config.position[3], config.position[4])
    self.onlyOutOfCombat = config.onlyOutOfCombat
end

local function CombatIcon_UpdatePixelPerfect(self)
    P.Resize(self)
    P.Repoint(self)
end

function I.CreateCombatIcon(parent)
    local combatIcon = CreateFrame("Frame", parent:GetName() .. "CombatIcon", parent.widgets.indicatorFrame)
    parent.indicators.combatIcon = combatIcon
    combatIcon.root = parent
    combatIcon:Hide()

    combatIcon.tex = combatIcon:CreateTexture(nil, "ARTWORK")
    combatIcon.tex:SetAllPoints()
    combatIcon.tex:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\combat")

    combatIcon:SetScript("OnEvent", CombatIcon_OnEvent)

    combatIcon.Enable = CombatIcon_Enable
    combatIcon.Disable = CombatIcon_Disable
    combatIcon.Update = CombatIcon_Update
    combatIcon.LoadConfig = CombatIcon_LoadConfig
    combatIcon.UpdatePixelPerfect = CombatIcon_UpdatePixelPerfect

    return combatIcon
end