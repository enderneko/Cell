-- CompactUnitFrame_OpenMenu
function CellUnitFrame_OpenMenu()
    local button = Cell.funcs.GetUnitButtonByGUID(UnitGUID("mouseover") or "")
    if not button then return end

    local unit = button.states.unit
    if not unit then return end

    local which, name

    if UnitIsUnit(unit, "player") then
        which = "SELF"
    elseif UnitIsUnit(unit, "vehicle") then
        which = "VEHICLE"
    elseif UnitIsUnit(unit, "pet") then
        which = "PET"
    elseif UnitIsPlayer(unit) then
        if UnitInRaid(unit) then
            which = "RAID_PLAYER"
        elseif UnitInParty(unit) then
            which = "PARTY"
        else
            which = "PLAYER"
        end
    else
        which = "TARGET"
        name = RAID_TARGET_ICON
    end

    if which then
        local contextData = {
            unit = unit,
            name = name,
        }
        UnitPopup_OpenMenu(which, contextData)
    end
end