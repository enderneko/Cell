-------------------------------------------------
-- 
-- remove icons border
-------------------------------------------------
hooksecurefunc(Cell.iFuncs, "CreateAura_BarIcon", function(name, parent)
    print(name, parent)
end)