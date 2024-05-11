-- 在单位按钮的角色名下方显示服务器名
local F = Cell.funcs

local function GetServerName(unit)
    if not UnitIsPlayer(unit) then return "" end

    local _, serverName = UnitNameUnmodified(unit)
    if not serverName then
        serverName = GetNormalizedRealmName()
    end
    return serverName
end

local function CreateServerName(parent)
    local serverName = parent.indicators.nameText:CreateFontString(nil, "OVERLAY")

    local font = parent.indicators.nameText.name:GetFont()
    serverName:SetFont(font, 11, "") -- font, size, flags
    serverName:SetShadowOffset(1, -1)
    serverName:SetShadowColor(0, 0, 0, 1)
    serverName:SetPoint("TOP", parent.indicators.nameText, "BOTTOM", 0, -1)

    hooksecurefunc(parent.indicators.nameText, "UpdateName", function()
        serverName:SetText(GetServerName(parent.states.unit))
    end)
end

F:IterateAllUnitButtons(function(b)
    CreateServerName(b)
end)