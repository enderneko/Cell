-- 在名字前显示队伍编号
local F = Cell.funcs

F:IterateAllUnitButtons(function(b)
    local nameText = b.indicators.nameText

    function nameText:UpdateName()
        local name

        -- only check nickname for players
        if b.states.isPlayer then
            if Cell.vars.nicknameCustomEnabled then
                name = Cell.vars.nicknameCustoms[b.states.fullName] or Cell.vars.nicknameCustoms[b.states.name] or Cell.vars.nicknames[b.states.fullName] or Cell.vars.nicknames[b.states.name] or b.states.name
            else
                name = Cell.vars.nicknames[b.states.fullName] or Cell.vars.nicknames[b.states.name] or b.states.name
            end
        else
            name = b.states.name
        end

        F:UpdateTextWidth(nameText.name, name, nameText.width, b.widgets.healthBar)

        if IsInRaid() then
            local raidIndex = UnitInRaid(b.states.unit)
            if raidIndex and name then
                local subgroup = select(3, GetRaidRosterInfo(raidIndex))
                nameText.name:SetText("|cffffffff"..subgroup.."-|r"..nameText.name:GetText())
            end
        end

        nameText:SetSize(nameText.name:GetWidth(), nameText.name:GetHeight())
    end
end)