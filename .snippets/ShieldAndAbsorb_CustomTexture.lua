Cell.funcs:IterateAllUnitButtons(function(b)
    -- current health bar texture / 当前血条材质: Cell.vars.texture
    -- default health bar texture / 默认血条材质: Interface\\AddOns\\Cell\\Media\\statusbar.tga
    
    -- shield texture / 护盾材质
    -- default/默认: SetTexture("Interface\\AddOns\\Cell\\Media\\shield.tga", "REPEAT", "REPEAT")
    b.widget.shieldBar:SetTexture("Interface\\AddOns\\Cell\\Media\\shield.tga", "REPEAT", "REPEAT")
    -- absorb texture (retail) / 治疗吸收材质（正式服）
    -- default/默认: SetTexture("Interface\\AddOns\\Cell\\Media\\shield.tga", "REPEAT", "REPEAT")
    b.widget.absorbsBar:SetTexture("Interface\\AddOns\\Cell\\Media\\shield.tga", "REPEAT", "REPEAT")
end)