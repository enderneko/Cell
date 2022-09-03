-- 在名字前显示队伍编号
local F = Cell.funcs

F:IterateAllUnitButtons(function(b)
    local nameText = b.indicators.nameText

    function nameText:UpdateName()
        local name
        
        -- only check nickname for players
        if b.state.isPlayer then
            if Cell.vars.nicknameCustomEnabled then
                name = Cell.vars.nicknameCustoms[b.state.fullName] or Cell.vars.nicknameCustoms[b.state.name] or Cell.vars.nicknames[b.state.fullName] or Cell.vars.nicknames[b.state.name] or b.state.name
            else
                name = Cell.vars.nicknames[b.state.fullName] or Cell.vars.nicknames[b.state.name] or b.state.name
            end
        else
            name = b.state.name
        end

        if IsInRaid() then
            local raidIndex = UnitInRaid(b.state.unit)
            if raidIndex and name then
                local subgroup = select(3, GetRaidRosterInfo(raidIndex))
                name = "|cffffffff"..subgroup.."-|r"..name
            end
        end

        F:UpdateTextWidth(nameText.name, name, nameText.width, b.widget.healthBar)
        nameText:SetSize(nameText.name:GetWidth(), nameText.name:GetHeight())
    end
end)