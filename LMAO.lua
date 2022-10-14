if not LOCALE_zhCN or Cell.isRetail then return end

local function CreateLMAOFrame()
    local lmao = CreateFrame("Frame", "请用正版插件", CellMainFrame, "BackdropTemplate")
    Cell:StylizeFrame(lmao, nil, {1, 0, 0, 1})
    lmao:SetSize(700, 320)
    lmao:EnableMouse(true)
    lmao:SetFrameStrata("DIALOG")
    lmao:SetPoint("CENTER", UIParent)
    lmao:Hide()

    local text = lmao:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET_TITLE")
    text:SetPoint("CENTER")
    text:SetSpacing(5)
    text:SetJustifyH("LEFT")
    text:SetText([[
    检测到你正在使用 |cffff8888RaidAlerter|r 团队报警系统插件！
    它可能造成了插件污染，并使得团队框架插件的部分功能无法正常工作（例如小队框体）！

    |cffffff00解决方案一：|r
        禁用 RaidAlerter
    |cffffff00解决方案二：|r
        将 RaidAlerter.lua 第|cff88ff8815|r行
            UnitGroupRolesAssigned = UnitGroupRolesAssigned or function() return "" end
        修改为
            |cff88ff88local|r UnitGroupRolesAssigned = UnitGroupRolesAssigned or function() return "" end

    |cffff8888鉴于经常被问到为什么 Cell 小队框体无法在怀旧服显示，特此做出说明|r
    请自行向该整合插件发布方反馈，本插件不对此状况负责
    （整合插件包制作者可删除此文件 LMAO.lua）
    ]])

    local button = Cell:CreateButton(lmao, "知道了！知道了！知道了！", "red", {20, 20}, nil)
    button:SetPoint("BOTTOMLEFT", 1, 1)
    button:SetPoint("BOTTOMRIGHT", -1, 1)
    button:SetScript("OnClick", function()
        CellDB.lmao = true
        lmao:Hide()
    end)

    if not CellDB.lmao then
        lmao:RegisterEvent("PLAYER_ENTERING_WORLD")
        lmao:SetScript("OnEvent", function()
            lmao:UnregisterEvent("PLAYER_ENTERING_WORLD")
            if IsAddOnLoaded("RaidAlerter") then
                lmao:Show()
                lmao:SetHeight(text:GetStringHeight() + 39)
                lmao:SetWidth(text:GetStringWidth() + 11)
                Cell.pixelPerfectFuncs:PixelPerfectPoint(lmao)
            end
        end)
    end
end
Cell:RegisterCallback("UpdatePixelPerfect", "CreateLMAOFrame", CreateLMAOFrame)