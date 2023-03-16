local _, Cell = ...
local F = Cell.funcs
local I = Cell.iFuncs

-------------------------------------------------
-- dispels: custom debuff type color
-------------------------------------------------
function I:GetDebuffTypeColor(debuffType)
    if debuffType and CellDB["debuffTypeColor"][debuffType] then
        return CellDB["debuffTypeColor"][debuffType]["r"], CellDB["debuffTypeColor"][debuffType]["g"], CellDB["debuffTypeColor"][debuffType]["b"]
    else
        return 0, 0, 0
    end
end

function I:SetDebuffTypeColor(debuffType, r, g, b)
    if debuffType and CellDB["debuffTypeColor"][debuffType] then
        CellDB["debuffTypeColor"][debuffType]["r"] = r
        CellDB["debuffTypeColor"][debuffType]["g"] = g
        CellDB["debuffTypeColor"][debuffType]["b"] = b
    end
end

function I:ResetDebuffTypeColor()
    -- copy
    CellDB["debuffTypeColor"] = F:Copy(DebuffTypeColor)
    -- add cleu
    CellDB["debuffTypeColor"].cleu = {r=0, g=1, b=1}
end