local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

local clickCastingsTab = Cell:CreateFrame("CellOptionsFrame_ClickCastingsTab", Cell.frames.optionsFrame, nil, nil, true)
Cell.frames.clickCastingsTab = clickCastingsTab
clickCastingsTab:SetAllPoints(Cell.frames.optionsFrame)
clickCastingsTab:Hide()

local listPane
local bindingsFrame
local listButtons = {}
local clickCastingTable
local loaded
local LoadProfile
local alwaysTargeting, smartResurrection
-------------------------------------------------
-- changes
-------------------------------------------------
local saveBtn, discardBtn
local deleted, changed = {}, {}
local function CheckChanges()
    if F:Getn(deleted) == 0 and F:Getn(changed) == 0 then
        saveBtn:SetEnabled(false)
        discardBtn:SetEnabled(false)
        for _, b in pairs(listButtons) do
            b.unmovable = nil
        end
    else
        saveBtn:SetEnabled(true)
        discardBtn:SetEnabled(true)
        for _, b in pairs(listButtons) do
            b.unmovable = true
        end
    end
end

-------------------------------------------------
-- db
-------------------------------------------------
-- https://wow.gamepedia.com/SecureActionButtonTemplate
-- {"shift-type1", "macro", "shift-macrotext1", "/cast [@mouseover] 回春术"}

-- local modifiers = {"", "shift-", "ctrl-", "alt-", "ctrl-shift-", "alt-shift-", "alt-ctrl-", "alt-ctrl-shift-"}
-- local modifiersDisplay = {"", "Shift|cff777777+|r", "Ctrl|cff777777+|r", "Alt|cff777777+|r", "Ctrl|cff777777+|rShift|cff777777+|r", "Alt|cff777777+|rShift|cff777777+|r", "Alt|cff777777+|rCtrl|cff777777+|r", "Alt|cff777777+|rCtrl|cff777777+|rShift|cff777777+|r"}
-- local keys = {"Left", "Right", "Middle", "Button4", "Button5", "ScrollUp", "ScrollDown"}
local mouseKeyIDs = {
    ["Left"] = 1,
    ["Right"] = 2,
    ["Middle"] = 3,
    ["Button4"] = 4,
    ["Button5"] = 5,
    -- ["ScrollUp"] = 6,
    -- ["ScrollDown"]= 14,
}

local function GetBindingDisplay(modifier, key)
    modifier = modifier:gsub("%-", "|cff777777+|r")
    modifier = modifier:gsub("alt", "Alt")
    modifier = modifier:gsub("ctrl", "Ctrl")
    modifier = modifier:gsub("shift", "Shift")
    modifier = modifier:gsub("meta", "Command")

    if strfind(key, "^NUM") then
        key = _G["KEY_"..key]
    elseif strlen(key) ~= 1 then
        key = L[key]
    end

    return modifier..key
end

-- shift-Left -> shift-type1
local function GetAttributeKey(modifier, bindKey)
    if mouseKeyIDs[bindKey] then -- normal mouse button
        return modifier.."type"..mouseKeyIDs[bindKey]
    elseif bindKey == "ScrollUp" or bindKey == "ScrollDown" then -- mouse wheel
        return modifier.."type-"..strupper(bindKey)
    else -- keyboard
        modifier = string.gsub(modifier, "alt%-", "alt")
        modifier = string.gsub(modifier, "ctrl%-", "ctrl")
        modifier = string.gsub(modifier, "shift%-", "shift")
        return "type-"..modifier..bindKey
    end
end

local function EncodeDB(modifier, bindKey, bindType, bindAction)
    local attrType, attrAction
    if bindType == "spell" then
        attrType = "spell"
        attrAction = bindAction

    elseif bindType == "macro" then
        attrType = "macro"
        attrAction = bindAction

    else -- general
        attrType = bindAction
        -- attrAction = nil
    end

    if bindKey == "notBound" then
        return {"notBound", attrType, attrAction}
    else
        return {GetAttributeKey(modifier, bindKey), attrType, attrAction}
    end
end

local function DecodeKeyboard(fullKey)
    fullKey = string.gsub(fullKey, "alt", "alt-")
    fullKey = string.gsub(fullKey, "ctrl", "ctrl-")
    fullKey = string.gsub(fullKey, "shift", "shift-")
    local modifier, key = strmatch(fullKey, "^(.*-)(.+)$")
    if not modifier then -- no modifier
        modifier = ""
        key = fullKey
    end
    return modifier, key
end

local function DecodeDB(t)
    local modifier, bindKey, bindType, bindAction

    if t[1] ~= "notBound" then
        local dash, key
        modifier, dash, key = strmatch(t[1], "^(.*)type(-*)(.+)$")

        if dash == "-" then
            if key == "SCROLLUP" then
                bindKey = "ScrollUp"
            elseif key == "SCROLLDOWN" then
                bindKey = "ScrollDown"
            else
                modifier, bindKey = DecodeKeyboard(key)
            end
        else -- normal mouse button
            bindKey = F:GetIndex(mouseKeyIDs, tonumber(key))
        end
    else
        modifier, bindKey = "", "notBound"
    end

    if not t[3] then
        bindType = "general"
        bindAction = t[2]
    else
        bindType = t[2]
        bindAction = t[3]
    end

    return modifier, bindKey, bindType, bindAction
end

-------------------------------------------------
-- mouse wheel & keyboard
-------------------------------------------------
local wrapFrame = CreateFrame("Frame", "CellWrapFrame", nil, "SecureHandlerStateTemplate")
wrapFrame:SetAttribute("_onstate-mouseoverstate", [[
    -- print("mouseoverstate", newstate)
    if newstate == "false" and mouseoverbutton then
        if not mouseoverbutton:IsUnderMouse() then
            mouseoverbutton:ClearBindings()
            mouseoverbutton = nil
        end
    end
]])
--! NOTE: not available for unit far away (different map)
RegisterStateDriver(wrapFrame, "mouseoverstate", "[@mouseover, exists] true; false")

--! update togglemenu_nocombat
wrapFrame:SetAttribute("_onstate-combatstate", [[
    -- print("combatstate", newstate)
    if mouseoverbutton then
        local menuKey = mouseoverbutton:GetAttribute("menu")
        if menuKey then
            if newstate == "true" then
                mouseoverbutton:SetAttribute(menuKey, nil)
            else
                mouseoverbutton:SetAttribute(menuKey, "togglemenu")
            end
        end
    end
]])
RegisterStateDriver(wrapFrame, "combatstate", "[combat] true; false")

local SetBindingClicks
if Cell.isRetail then
    SetBindingClicks = function (b)
        b:SetAttribute("_onenter", [[
            -- print("_onenter")
            self:ClearBindings()
            self:Run(self:GetAttribute("snippet"))

            -- self:SetBindingClick(true, "SHIFT-MOUSEWHEELUP", self, "shiftSCROLLUP")
            -- FIXME: --! 如果游戏按键设置（比如“视角”“载具控制”）中绑定了滚轮，那么 self:SetBindingClick(true, "MOUSEWHEELUP", self, "SCROLLUP") 会失效
            -- self:SetBindingClick(true, "MOUSEWHEELUP", self, "SCROLLUP")
            -- self:SetBindingClick(true, "MOUSEWHEELDOWN", self, "SCROLLDOWN")

            -- self:SetBindingClick(true, "SHIFT-B", self, "shiftB")
            -- self:SetBindingClick(true, "SHIFT-C", self, "shiftC")

            --! update click-casting unit
            -- local attrs = self:GetAttribute("cell")
            -- -- print(attrs)
            -- if attrs then
            --     for _, k in pairs(table.new(strsplit("|", attrs))) do
            --         self:SetAttribute(k, string.gsub(self:GetAttribute(k), "@%w+", "@"..self:GetAttribute("unit")))
            --     end
            -- end

            --! update togglemenu
            local menuKey = self:GetAttribute("menu")
            if menuKey then
                if PlayerInCombat() then
                    self:SetAttribute(menuKey, nil)
                else
                    self:SetAttribute(menuKey, "togglemenu")
                end
            end
        ]])

        wrapFrame:WrapScript(b, "OnEnter", [[
            -- print("OnEnter")
            if mouseoverbutton then mouseoverbutton:ClearBindings() end --! NOTE: 鼠标放在过远单位上->被挡住->移走->移至可用单位再移出，会发现之前的不可用单位的按键绑定仍未取消
            mouseoverbutton = self
        ]])

        --! NOTE: if another frame shows in front of b, _onleave will NOT trigger. Use WrapScript to solve this issue.
        b:SetAttribute("_onleave", [[
            -- print("_onleave")
            self:ClearBindings()
        ]])

        -- wrapFrame:WrapScript(b, "OnLeave", [[
        --     -- print("OnLeave")
        --     mouseoverbutton = nil
        -- ]])

        b:SetAttribute("_onhide", [[
            self:ClearBindings()
        ]])
    end
else
    SetBindingClicks = function(b)
        b:SetAttribute("_onenter", [[
            -- print("_onenter")
            self:ClearBindings()
            self:Run(self:GetAttribute("snippet"))

            -- self:SetBindingClick(true, "SHIFT-MOUSEWHEELUP", self, "shiftSCROLLUP")
            -- FIXME: --! 如果游戏按键设置（比如“视角”“载具控制”）中绑定了滚轮，那么 self:SetBindingClick(true, "MOUSEWHEELUP", self, "SCROLLUP") 会失效
            -- self:SetBindingClick(true, "MOUSEWHEELUP", self, "SCROLLUP")
            -- self:SetBindingClick(true, "MOUSEWHEELDOWN", self, "SCROLLDOWN")

            -- self:SetBindingClick(true, "SHIFT-B", self, "shiftB")
            -- self:SetBindingClick(true, "SHIFT-C", self, "shiftC")

            --! vehicle
            local unit = self:GetAttribute("unit")
            local vehicle
            if UnitHasVehicleUI(unit) then
                if unit == "player" then
                    vehicle = "pet"
                elseif strfind(unit, "^party%d+$") then
                    vehicle = string.gsub(unit, "party", "partypet")
                elseif strfind(unit, "^raid%d+$") then
                    vehicle = string.gsub(unit, "raid", "raidpet")
                end
            end

            --! update click-casting unit
            local clickCastingUnit = vehicle or unit
            local attrs = self:GetAttribute("cell")
            -- print(attrs)
            if attrs then
                for _, k in pairs(table.new(strsplit("|", attrs))) do
                    self:SetAttribute(k, string.gsub(self:GetAttribute(k), "@%w+", "@"..clickCastingUnit))
                    -- print(self:GetAttribute(k))
                end
            end

            --! update togglemenu
            local menuKey = self:GetAttribute("menu")
            if menuKey then
                if PlayerInCombat() then
                    self:SetAttribute(menuKey, nil)
                else
                    self:SetAttribute(menuKey, "togglemenu")
                end
            end
        ]])

        wrapFrame:WrapScript(b, "OnEnter", [[
            -- print("OnEnter")
            if mouseoverbutton then
                --! NOTE: 鼠标放在过远单位上->被挡住->移走->移至可用单位再移出，会发现之前的不可用单位的按键绑定仍未取消
                mouseoverbutton:ClearBindings()

                --! vehicle (previous button)
                local oldUnit = mouseoverbutton:GetAttribute("oldUnit")
                if oldUnit then
                    -- print("wrap restore unit")
                    mouseoverbutton:SetAttribute("unit", oldUnit)
                    mouseoverbutton:SetAttribute("oldUnit", nil)
                end
            end
            mouseoverbutton = self
        ]])

        --! NOTE: if another frame shows in front of b, _onleave will NOT trigger. Use WrapScript to solve this issue.
        b:SetAttribute("_onleave", [[
            -- print("_onleave")
            self:ClearBindings()
        ]])

        -- wrapFrame:WrapScript(b, "OnLeave", [[
        --     -- print("OnLeave")
        --     mouseoverbutton = nil
        -- ]])

        b:SetAttribute("_onhide", [[
            self:ClearBindings()

            --! vehicle
            local oldUnit = self:GetAttribute("oldUnit")
            if oldUnit then
                -- print("restore unit")
                self:SetAttribute("oldUnit", nil)
                self:SetAttribute("unit", oldUnit)
            end
        ]])
    end
end

-- FIXME: hope BLZ fix this bug
local function GetMouseWheelBindKey(fullKey, noTypePrefix)
    local modifier, key = strmatch(fullKey, "^(.*)type%-(.+)$")
    modifier = string.gsub(modifier, "-", "")

    if noTypePrefix then
        return modifier..key
    else
        return "type-"..modifier..key -- type-ctrlSCROLLUP
    end
end

local function GetBindingSnippet()
    local bindingClicks = {}
    for _, t in pairs(clickCastingTable) do
        if t[1] ~= "notBound" then
            local modifier, key = strmatch(t[1], "^(.*)type%-(.+)$")
            if key then
                -- if key == "SCROLLUP" then
                --     bindingClicks[key] = [[self:SetBindingClick(true, "MOUSEWHEELUP", self, "SCROLLUP")]]
                -- elseif key == "SCROLLDOWN" then
                --     bindingClicks[key] = [[self:SetBindingClick(true, "MOUSEWHEELDOWN", self, "SCROLLDOWN")]]
                if key == "SCROLLUP" or key == "SCROLLDOWN" then
                    key = GetMouseWheelBindKey(t[1], true) -- ctrlSCROLLUP
                    if not bindingClicks[key] then
                        local m, k = DecodeKeyboard(key)
                        k = k == "SCROLLUP" and "MOUSEWHEELUP" or "MOUSEWHEELDOWN"
                        bindingClicks[key] = [[self:SetBindingClick(true, "]]..strupper(m..k)..[[", self, "]]..key..[[")]]
                    end
                elseif not bindingClicks[key] then
                    local m, k = DecodeKeyboard(key)
                    -- override keyboard to click
                    if k == [[\]] then
                        key = key:gsub([[\]], [[\\]])
                        bindingClicks[key] = [[self:SetBindingClick(true, "]]..strupper(m)..[[\\", self, "]]..key..[[")]]
                    else
                        bindingClicks[key] = [[self:SetBindingClick(true, "]]..strupper(m..k)..[[", self, "]]..key..[[")]]
                    end
                end
            end
        end
    end

    local snippet = ""
    for _, bindingClick in pairs(bindingClicks) do
        snippet = snippet..bindingClick.."\n"
    end
    return snippet
end

-------------------------------------------------
-- update click-castings
-------------------------------------------------
local previousClickCastings
local function ClearClickCastings(b)
    if not previousClickCastings then return end
    b:SetAttribute("cell", nil)
    b:SetAttribute("menu", nil)
    for _, t in pairs(previousClickCastings) do
        local bindKey = t[1]
        if strfind(bindKey, "SCROLL") then
            bindKey = GetMouseWheelBindKey(t[1])
        end

        b:SetAttribute(bindKey, nil)
        local attr = string.gsub(bindKey, "type", "spell")
        b:SetAttribute(attr, nil)
        attr = string.gsub(bindKey, "type", "macrotext")
        b:SetAttribute(attr, nil)
        -- if t[2] == "spell" then
        --     local attr = string.gsub(bindKey, "type", "spell")
        --     b:SetAttribute(attr, nil)
        -- elseif t[2] == "macro" then
        --     local attr = string.gsub(bindKey, "type", "macrotext")
        --     b:SetAttribute(attr, nil)
        -- end
    end
end

--! store attribute keys, update them in _onenter
--! NOTE: 尝试用于修复距离过远目标的点击施法问题，但没有卵用，确认是游戏问题。
--! NOTE: 当目标为敌对时，@范围内/距离稍微超出一点儿的 > 自动自我施法的优先级 > @距离过远的
local function UpdatePlaceholder(b, attr)
    if not b:GetAttribute("cell") then
        b:SetAttribute("cell", attr)
    else
        b:SetAttribute("cell", b:GetAttribute("cell").."|"..attr)
    end
end

local function ApplyClickCastings(b)
    for i, t in pairs(clickCastingTable) do
        local bindKey = t[1]
        if strfind(bindKey, "SCROLL") then
            bindKey = GetMouseWheelBindKey(t[1])
        end

        if t[2] == "togglemenu_nocombat" then
            b:SetAttribute("menu", bindKey)
        ------------------------------------------------------------------
        --* 已修复：实际上载具（宠物按钮）无法选中的原因是没有 SetAttribute("toggleForVehicle", false)
        -- elseif Cell.isCata and t[2] == "target" then
        --     b:SetAttribute(bindKey, "macro")
        --     local attr = string.gsub(bindKey, "type", "macrotext")
        --     b:SetAttribute(attr, "/tar [@cell]")
        --     UpdatePlaceholder(b, attr)
        ------------------------------------------------------------------
        else
            b:SetAttribute(bindKey, t[2])
        end

        if t[2] == "spell" then
            local spellName = F:GetSpellNameAndIcon(t[3]) or ""

            -- NOTE: spell 在无效/过远的目标上会处于“等待选中目标”的状态，即鼠标指针有一圈灰色材质。用 macrotext 可以解决这个问题
            -- NOTE: 但对于尸体状态（未释放）的目标，需要额外判断
            local condition = ""
            if not F:IsSoulstone(spellName) then
                condition = F:IsResurrectionForDead(spellName) and ",dead" or ",nodead"
            end

            local unit = Cell.isRetail and "@mouseover" or "@cell"

            -- "sMaRt" resurrection
            local sMaRt = ""
            if smartResurrection ~= "disabled" and not (F:IsResurrectionForDead(spellName) or F:IsSoulstone(spellName)) then
                if strfind(smartResurrection, "^normal") then
                    local normalResurrection = F:GetNormalResurrection(Cell.vars.playerClass)
                    if normalResurrection then
                        if Cell.isRetail then -- mass resurrections
                            for condition, spell in pairs(normalResurrection) do
                                sMaRt = sMaRt .. ";["..unit..",dead,nocombat,"..condition.."] "..spell
                            end
                        else
                            sMaRt = sMaRt .. ";["..unit..",dead,nocombat] "..normalResurrection
                        end
                    end
                end
                if strfind(smartResurrection, "combat$") then
                    if F:GetCombatResurrection(Cell.vars.playerClass) then
                        sMaRt = sMaRt .. ";["..unit..",dead,combat] "..F:GetCombatResurrection(Cell.vars.playerClass)
                    end
                end
            end

            if (alwaysTargeting == "left" and bindKey == "type1") or alwaysTargeting == "any" then
                b:SetAttribute(bindKey, "macro")
                local attr = string.gsub(bindKey, "type", "macrotext")
                b:SetAttribute(attr, "/tar ["..unit.."]\n/cast ["..unit..condition.."] "..spellName..sMaRt)
                if not Cell.isRetail then UpdatePlaceholder(b, attr) end
            else
                -- local attr = string.gsub(bindKey, "type", "spell")
                -- b:SetAttribute(attr, spellName)
                b:SetAttribute(bindKey, "macro")
                local attr = string.gsub(bindKey, "type", "macrotext")
                if F:IsSoulstone(spellName) then
                    b:SetAttribute(attr, "/tar ["..unit.."]\n/cast ["..unit.."] "..spellName.."\n/targetlasttarget")
                else
                    b:SetAttribute(attr, "/cast ["..unit..condition.."] "..spellName..sMaRt)
                end
                if not Cell.isRetail then UpdatePlaceholder(b, attr) end
            end
        elseif t[2] == "macro" then
            local attr = string.gsub(bindKey, "type", "macrotext")
            b:SetAttribute(attr, t[3])
        end
    end
end

local function UpdateClickCastings(noReload)
    F:Debug("|cff77ff77UpdateClickCastings:|r useCommon:", Cell.vars.clickCastings["useCommon"])
    clickCastingTable = Cell.vars.clickCastings["useCommon"] and Cell.vars.clickCastings["common"] or Cell.vars.clickCastings[Cell.vars.playerSpecID]

    -- FIXME: remove this determine statement
    if Cell.vars.clickCastings["alwaysTargeting"] then
        alwaysTargeting = Cell.vars.clickCastings["alwaysTargeting"][Cell.vars.clickCastings["useCommon"] and "common" or Cell.vars.playerSpecID]
    else
        alwaysTargeting = "disabled"
    end

    smartResurrection = Cell.vars.clickCastings["smartResurrection"]

    if not noReload then
        if clickCastingsTab:IsVisible() then
            LoadProfile(Cell.vars.clickCastings["useCommon"])
        else
            loaded = false
        end
    end

    local snippet = GetBindingSnippet()
    F:Debug(snippet)

    F:IterateAllUnitButtons(function(b)
        -- clear if attribute already set
        ClearClickCastings(b)

        -- update bindingClicks
        b:SetAttribute("snippet", snippet)
        SetBindingClicks(b)

        -- load db and set attribute
        ApplyClickCastings(b)
    end, false, true)
    previousClickCastings = F:Copy(clickCastingTable)
end
Cell:RegisterCallback("UpdateClickCastings", "UpdateClickCastings", UpdateClickCastings)

-------------------------------------------------
-- profiles dropdown
-------------------------------------------------
local profileDropdown

local function CreateProfilePane()
    local profilePane = Cell:CreateTitledPane(clickCastingsTab, L["Profiles"], 422, 50)
    profilePane:SetPoint("TOPLEFT", 5, -5)

    profileDropdown = Cell:CreateDropdown(profilePane, 412)
    profileDropdown:SetPoint("TOPLEFT", profilePane, "TOPLEFT", 5, -27)
    profileDropdown:SetEnabled(not Cell.isVanilla)

    profileDropdown:SetItems({
        {
            ["text"] = L["Use common profile"],
            ["onClick"] = function()
                Cell.vars.clickCastings["useCommon"] = true
                Cell:Fire("UpdateClickCastings")
                LoadProfile(true)
            end,
        },
        {
            ["text"] = L["Use separate profile for each spec"],
            ["onClick"] = function()
                Cell.vars.clickCastings["useCommon"] = false
                Cell:Fire("UpdateClickCastings")
                LoadProfile(false)
            end,
        }
    })
end


-------------------------------------------------
-- always targeting
-------------------------------------------------
local targetingDropdown

local function CreateTargetingPane()
    local targetingPane = Cell:CreateTitledPane(clickCastingsTab, L["Always Targeting"], 205, 50)
    targetingPane:SetPoint("TOPLEFT", clickCastingsTab, "TOPLEFT", 5, -70)

    targetingDropdown = Cell:CreateDropdown(targetingPane, 195)
    targetingDropdown:SetPoint("TOPLEFT", targetingPane, "TOPLEFT", 5, -27)

    targetingDropdown:SetItems({
        {
            ["text"] = L["Disabled"],
            ["value"] = "disabled",
            ["onClick"] = function()
                local spec = Cell.vars.clickCastings["useCommon"] and "common" or Cell.vars.playerSpecID
                Cell.vars.clickCastings["alwaysTargeting"][spec] = "disabled"
                alwaysTargeting = "disabled"
                Cell:Fire("UpdateClickCastings", true)
            end,
        },
        {
            ["text"] = L["Left Spell"],
            ["value"] = "left",
            ["onClick"] = function()
                local spec = Cell.vars.clickCastings["useCommon"] and "common" or Cell.vars.playerSpecID
                Cell.vars.clickCastings["alwaysTargeting"][spec] = "left"
                alwaysTargeting = "left"
                Cell:Fire("UpdateClickCastings", true)
            end,
        },
        {
            ["text"] = L["Any Spells"],
            ["value"] = "any",
            ["onClick"] = function()
                local spec = Cell.vars.clickCastings["useCommon"] and "common" or Cell.vars.playerSpecID
                Cell.vars.clickCastings["alwaysTargeting"][spec] = "any"
                alwaysTargeting = "any"
                Cell:Fire("UpdateClickCastings", true)
            end,
        },
    })
    Cell:SetTooltips(targetingDropdown, "ANCHOR_TOPLEFT", 0, 2, L["Always Targeting"], L["Only available for Spells"])
end

-------------------------------------------------
-- sMaRt resurrection
-------------------------------------------------
local smartResDropdown

local function CreateSmartResPane()
    local smartResPane = Cell:CreateTitledPane(clickCastingsTab, L["Smart Resurrection"], 205, 50)
    smartResPane:SetPoint("TOPLEFT", clickCastingsTab, "TOPLEFT", 222, -70)

    smartResDropdown = Cell:CreateDropdown(smartResPane, 195)
    smartResDropdown:SetPoint("TOPLEFT", smartResPane, "TOPLEFT", 5, -27)

    smartResDropdown:SetItems({
        {
            ["text"] = L["Disabled"],
            ["value"] = "disabled",
            ["onClick"] = function()
                Cell.vars.clickCastings["smartResurrection"] = "disabled"
                Cell:Fire("UpdateClickCastings", true)
            end
        },
        {
            ["text"] = L["Normal"],
            ["value"] = "normal",
            ["onClick"] = function()
                Cell.vars.clickCastings["smartResurrection"] = "normal"
                Cell:Fire("UpdateClickCastings", true)
            end
        },
        {
            ["text"] = L["Normal + Combat Res"],
            ["value"] = "normal+combat",
            ["onClick"] = function()
                Cell.vars.clickCastings["smartResurrection"] = "normal+combat"
                Cell:Fire("UpdateClickCastings", true)
            end
        },
    })
    Cell:SetTooltips(smartResDropdown, "ANCHOR_TOPLEFT", 0, 2, L["Smart Resurrection"], L["Replace click-castings of Spell type with resurrection spells on dead units"])
end

-------------------------------------------------
-- menu
-------------------------------------------------
local menu = Cell.menu
local bindingButton

local function CheckChanged(index, b)
    if F:Getn(changed[index]) == 1 then -- nothing changed
        changed[index] = nil
        b:SetChanged(false)
    else
        b:SetChanged(true)
    end
end

local function ShowBindingMenu(index, b)
    -- if already in deleted, do nothing
    if deleted[index] then return end

    P:ClearPoints(bindingButton)
    P:Point(bindingButton, "TOPLEFT", b.keyGrid)
    bindingButton:Show()
    menu:Hide()

    bindingButton:SetFunc(function(modifier, key)
        F:Debug(modifier, key)
        b.keyGrid:SetText(GetBindingDisplay(modifier, key))

        changed[index] = changed[index] or {b}
        -- check modifier
        if modifier ~= b.modifier then
            changed[index]["modifier"] = modifier
        else
            changed[index]["modifier"] = nil
        end
        -- check bindKey
        if key ~= b.bindKey then
            changed[index]["bindKey"] = key
        else
            changed[index]["bindKey"] = nil
        end

        CheckChanged(index, b)
        CheckChanges()
    end)
end

local function ShowTypesMenu(index, b)
    local parent = select(2, menu:GetPoint(1))
    if parent == b.typeGrid and menu:IsShown() then
        menu:Hide()
        return
    end

    -- if already in deleted, do nothing
    if deleted[index] then return end

    local items = {
        {
            ["text"] = L["General"],
            ["onClick"] = function()
                b.typeGrid:SetText(L["General"])
                if clickCastingsTab.popupEditBox then clickCastingsTab.popupEditBox:Hide() end

                changed[index] = changed[index] or {b}
                -- check type
                if b.bindType ~= "general" then
                    changed[index]["bindType"] = "general"
                    changed[index]["bindAction"] = "target"
                    b.actionGrid:SetText(L["target"])
                else
                    changed[index]["bindType"] = nil
                    changed[index]["bindAction"] = nil
                    b.actionGrid:SetText(L[b.bindAction])
                end
                CheckChanged(index, b)
                CheckChanges()
                b:HideSpellIcon()
            end,
        },
        {
            ["text"] = L["Macro"],
            ["onClick"] = function()
                b.typeGrid:SetText(L["Macro"])
                if clickCastingsTab.popupEditBox then clickCastingsTab.popupEditBox:Hide() end

                changed[index] = changed[index] or {b}
                -- check type
                if b.bindType ~= "macro" then
                    changed[index]["bindType"] = "macro"
                    changed[index]["bindAction"] = ""
                    b.actionGrid:SetText("")
                else
                    changed[index]["bindType"] = nil
                    changed[index]["bindAction"] = nil
                    b.actionGrid:SetText(b.bindAction)
                end
                CheckChanged(index, b)
                CheckChanges()
                b:HideSpellIcon()
            end,
        },
        {
            ["text"] = L["Spell"],
            ["onClick"] = function()
                b.typeGrid:SetText(L["Spell"])
                if clickCastingsTab.popupEditBox then clickCastingsTab.popupEditBox:Hide() end

                changed[index] = changed[index] or {b}
                -- check type
                if b.bindType ~= "spell" then
                    changed[index]["bindType"] = "spell"
                    changed[index]["bindAction"] = ""
                    b.actionGrid:SetText("")
                    b:HideSpellIcon()
                else
                    changed[index]["bindType"] = nil
                    changed[index]["bindAction"] = nil
                    b.actionGrid:SetText(b.bindActionDisplay)
                    b:ShowSpellIcon(b.bindAction)
                end
                CheckChanged(index, b)
                CheckChanges()
            end,
        },
    }

    menu:SetItems(items)
    P:ClearPoints(menu)
    P:Point(menu, "TOPLEFT", b.typeGrid, "BOTTOMLEFT", 0, -1)
    menu:SetWidths(70)
    menu:ShowMenu()
    bindingButton:Hide()
end

local function ShowActionsMenu(index, b)
    local parent = select(2, menu:GetPoint(1))
    if parent == b.actionGrid and menu:IsShown() then
        menu:Hide()
        return
    end

    -- if already in deleted, do nothing
    if deleted[index] then return end

    local items

    local bindType
    if changed[index] and changed[index]["bindType"] then -- changed
        bindType = changed[index]["bindType"]
    else -- use original
        bindType = b.bindType
    end

    if bindType == "general" then
        items = {
            {
                ["text"] = L["Target"],
                ["onClick"] = function()
                    changed[index] = changed[index] or {b}
                    if b.bindAction ~= "target" then
                        changed[index]["bindAction"] = "target"
                        b.actionGrid:SetText(L["Target"])
                    else
                        changed[index]["bindAction"] = nil
                        b.actionGrid:SetText(L[b.bindAction])
                    end
                    CheckChanged(index, b)
                    CheckChanges()
                end,
            },
            {
                ["text"] = L["Focus"],
                ["onClick"] = function()
                    changed[index] = changed[index] or {b}
                    if b.bindAction ~= "focus" then
                        changed[index]["bindAction"] = "focus"
                        b.actionGrid:SetText(L["Focus"])
                    else
                        changed[index]["bindAction"] = nil
                        b.actionGrid:SetText(L[b.bindAction])
                    end
                    CheckChanged(index, b)
                    CheckChanges()
                end,
            },
            {
                ["text"] = L["Assist"],
                ["onClick"] = function()
                    changed[index] = changed[index] or {b}
                    if b.bindAction ~= "assist" then
                        changed[index]["bindAction"] = "assist"
                        b.actionGrid:SetText(L["Assist"])
                    else
                        changed[index]["bindAction"] = nil
                        b.actionGrid:SetText(L[b.bindAction])
                    end
                    CheckChanged(index, b)
                    CheckChanges()
                end,
            },
            {
                ["text"] = L["Menu"],
                ["onClick"] = function()
                    changed[index] = changed[index] or {b}
                    if b.bindAction ~= "togglemenu" then
                        changed[index]["bindAction"] = "togglemenu"
                        b.actionGrid:SetText(L["Menu"])
                    else
                        changed[index]["bindAction"] = nil
                        b.actionGrid:SetText(L[b.bindAction])
                    end
                    CheckChanged(index, b)
                    CheckChanges()
                end,
            },
            {
                ["text"] = L["togglemenu_nocombat"],
                ["onClick"] = function()
                    changed[index] = changed[index] or {b}
                    if b.bindAction ~= "togglemenu_nocombat" then
                        changed[index]["bindAction"] = "togglemenu_nocombat"
                        b.actionGrid:SetText(L["togglemenu_nocombat"])
                    else
                        changed[index]["bindAction"] = nil
                        b.actionGrid:SetText(L[b.bindAction])
                    end
                    CheckChanged(index, b)
                    CheckChanges()
                end,
            },
        }

    elseif bindType == "macro" then
        items = {
            {
                ["text"] = L["Edit"],
                ["onClick"] = function()
                    local peb = Cell:CreatePopupEditBox(clickCastingsTab, function(text)
                        changed[index] = changed[index] or {b}
                        if b.bindAction ~= text then
                            changed[index]["bindAction"] = text
                            b.actionGrid:SetText(text)
                        else
                            changed[index]["bindAction"] = nil
                            b.actionGrid:SetText(b.bindAction)
                        end
                        CheckChanged(index, b)
                        CheckChanges()
                    end, true)
                    peb:SetPoint("TOPLEFT", b.actionGrid)
                    peb:SetPoint("TOPRIGHT", b.actionGrid)
                    P:Height(peb, 20)
                    -- peb:SetPoint("BOTTOMRIGHT", b.actionGrid)
                    peb:SetTips("|cffababab"..L["Shift+Enter: add a new line"].."\n"..L["Enter: apply\nESC: discard"])
                    if b.bindType == "macro" then
                        if changed[index] and changed[index]["bindAction"] then
                            peb:ShowEditBox(changed[index]["bindAction"])
                        else
                            peb:ShowEditBox(b.bindAction)
                        end
                    elseif changed[index] and changed[index]["bindType"] == "macro" then
                        if changed[index]["bindAction"] then
                            peb:ShowEditBox(changed[index]["bindAction"])
                        else
                            peb:ShowEditBox("")
                        end
                    else
                        peb:ShowEditBox("")
                    end
                    peb:SetNumeric(false)
                end,
            },
            {
                ["text"] = L["Extra Action Button"],
                ["onClick"] = function()
                    changed[index] = changed[index] or {b}
                    local macrotext = "/stopcasting\n/target mouseover\n/click ExtraActionButton1\n/targetlasttarget"
                    if b.bindAction ~= macrotext then
                        changed[index]["bindAction"] = macrotext
                        b.actionGrid:SetText(macrotext)
                    else
                        changed[index]["bindAction"] = nil
                        b.actionGrid:SetText(b.bindAction)
                    end
                    CheckChanged(index, b)
                    CheckChanges()
                end,
            },
            {
                ["text"] = _G.INVTYPE_TRINKET.." 1",
                ["onClick"] = function()
                    changed[index] = changed[index] or {b}
                    local macrotext = "/use [@mouseover] 13"
                    if b.bindAction ~= macrotext then
                        changed[index]["bindAction"] = macrotext
                        b.actionGrid:SetText(macrotext)
                    else
                        changed[index]["bindAction"] = nil
                        b.actionGrid:SetText(b.bindAction)
                    end
                    CheckChanged(index, b)
                    CheckChanges()
                end,
            },
            {
                ["text"] = _G.INVTYPE_TRINKET.." 2",
                ["onClick"] = function()
                    changed[index] = changed[index] or {b}
                    local macrotext = "/use [@mouseover] 14"
                    if b.bindAction ~= macrotext then
                        changed[index]["bindAction"] = macrotext
                        b.actionGrid:SetText(macrotext)
                    else
                        changed[index]["bindAction"] = nil
                        b.actionGrid:SetText(b.bindAction)
                    end
                    CheckChanged(index, b)
                    CheckChanges()
                end,
            },
            {
                ["text"] = _G.INVTYPE_WRIST,
                ["onClick"] = function()
                    changed[index] = changed[index] or {b}
                    local macrotext = "/use [@mouseover] 9"
                    if b.bindAction ~= macrotext then
                        changed[index]["bindAction"] = macrotext
                        b.actionGrid:SetText(macrotext)
                    else
                        changed[index]["bindAction"] = nil
                        b.actionGrid:SetText(b.bindAction)
                    end
                    CheckChanged(index, b)
                    CheckChanges()
                end,
            },
            {
                ["text"] = _G.INVTYPE_HAND,
                ["onClick"] = function()
                    changed[index] = changed[index] or {b}
                    local macrotext = "/use [@mouseover] 10"
                    if b.bindAction ~= macrotext then
                        changed[index]["bindAction"] = macrotext
                        b.actionGrid:SetText(macrotext)
                    else
                        changed[index]["bindAction"] = nil
                        b.actionGrid:SetText(b.bindAction)
                    end
                    CheckChanged(index, b)
                    CheckChanges()
                end,
            },
        }

        if (Cell.isVanilla or Cell.isCata) and Cell.vars.playerClass == "WARLOCK" then
            tinsert(items, {
                ["text"] = F:GetSpellNameAndIcon(20707),
                ["onClick"] = function()
                    changed[index] = changed[index] or {b}
                    local macrotext = "/stopcasting\n/target mouseover\n/use item:36895\n/targetlasttarget"
                    if b.bindAction ~= macrotext then
                        changed[index]["bindAction"] = macrotext
                        b.actionGrid:SetText(macrotext)
                    else
                        changed[index]["bindAction"] = nil
                        b.actionGrid:SetText(b.bindAction)
                    end
                    CheckChanged(index, b)
                    CheckChanges()
                end,
            })
        end

    else -- spell
        items = {
            {
                ["text"] = L["Edit"],
                ["onClick"] = function()
                    local peb = Cell:CreatePopupEditBox(clickCastingsTab, function(text)
                        changed[index] = changed[index] or {b}
                        text = tonumber(text) or ""
                        if b.bindAction ~= text then
                            changed[index]["bindAction"] = text
                            if text == "" then
                                b.actionGrid:SetText("")
                                b:HideSpellIcon()
                            else
                                b.actionGrid:SetText(F:GetSpellNameAndIcon(text) or "|cFFFF3030"..L["Invalid"])
                                b:ShowSpellIcon(text)
                            end
                        else
                            changed[index]["bindAction"] = nil
                            if text == "" then
                                b.actionGrid:SetText("")
                                b:HideSpellIcon()
                            else
                                b.actionGrid:SetText(b.bindActionDisplay)
                                b:ShowSpellIcon(b.bindAction)
                            end
                        end
                        CheckChanged(index, b)
                        CheckChanges()
                    end)
                    P:Point(peb, "TOPLEFT", b.actionGrid)
                    P:Point(peb, "BOTTOMRIGHT", b.actionGrid)
                    peb:SetTips("|cffababab"..L["Input spell id"].."\n"..L["Enter: apply\nESC: discard"])
                    peb:ShowEditBox(b.bindAction or "")
                    peb:SetNumeric(true)
                    if not peb.tooltipAdded then
                        peb.tooltipAdded = true
                        peb:SetScript("OnTextChanged", function()
                            local spellId = tonumber(peb:GetText())
                            if not spellId then
                                CellSpellTooltip:Hide()
                                return
                            end

                            local name, icon = F:GetSpellNameAndIcon(spellId)
                            if not name then
                                CellSpellTooltip:Hide()
                                return
                            end

                            CellSpellTooltip:SetOwner(peb, "ANCHOR_NONE")
                            CellSpellTooltip:SetPoint("TOPLEFT", peb, "BOTTOMLEFT", 0, -1)
                            CellSpellTooltip:SetSpellByID(spellId, icon)
                            CellSpellTooltip:Show()
                        end)
                        peb:HookScript("OnHide", function()
                            CellSpellTooltip:Hide()
                        end)
                    end
                end,
            },
        }

        -- default spells
        local spells = F:GetClickCastingSpellList(Cell.vars.playerClass, Cell.vars.playerSpecID)
        -- {icon, name, type(C/S/P), id}

        for _, t in ipairs(spells) do
            tinsert(items, {
                --! CANNOT use "|T****|t", if too many items (over 10?), it will cause game stuck!! I don't know why!
                -- ["text"] = "|T"..t[1]..":12:12:0:0:12:12:1:11:1:11|t "..t[2]..(t[3] and (" |cff777777("..t[3]..")") or ""),
                ["text"] = t[2]..(t[3] and (" |cff777777("..t[3]..")") or ""),
                ["icon"] = t[1],
                ["onClick"] = function()
                    changed[index] = changed[index] or {b}
                    if b.bindAction ~= t[4] then
                        changed[index]["bindAction"] = t[4]
                        b.actionGrid:SetText(t[2])
                        b:ShowSpellIcon(t[4])
                    else
                        changed[index]["bindAction"] = nil
                        b.actionGrid:SetText(b.bindActionDisplay)
                        b:ShowSpellIcon(b.bindAction)
                    end
                    CheckChanged(index, b)
                    CheckChanges()
                end,
            })
        end
    end

    menu:SetWidths(b.actionGrid:GetWidth())
    menu:SetItems(items, 15)
    P:ClearPoints(menu)
    P:Point(menu, "TOPLEFT", b.actionGrid, "BOTTOMLEFT", 0, -1)
    menu:ShowMenu()
    bindingButton:Hide()
end

-------------------------------------------------
-- list pane
-------------------------------------------------
local CreateBindingListButton
local last

local function UpdateCurrentText(isCommon)
    if isCommon then
        listPane:SetTitle(L["Current Profile"]..": "..L["Common"])
    else
        if Cell.isRetail then
            listPane:SetTitle(L["Current Profile"]..": ".."|T"..Cell.vars.playerSpecIcon..":12:12:0:1:12:12:1:11:1:11|t "..Cell.vars.playerSpecName)
        elseif Cell.isCata then
            local name, icon = F:GetActiveTalentInfo()
            listPane:SetTitle(L["Current Profile"]..": ".."|T"..icon..":12:12:0:1:12:12:1:11:1:11|t "..name)
        end
    end
end

local function CreateListPane()
    listPane = Cell:CreateTitledPane(clickCastingsTab, L["Current Profile"], 422, 451)
    listPane:SetPoint("BOTTOMLEFT", clickCastingsTab, 5, 5)

    local hint = Cell:CreateButton(listPane, nil, "accent-hover", {17, 17}, nil, nil, nil, nil, nil, L["Click-Castings"], L["clickcastingsHints"])
    hint:SetPoint("TOPRIGHT")
    hint.tex = hint:CreateTexture(nil, "ARTWORK")
    hint.tex:SetAllPoints(hint)
    hint.tex:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\info2.tga")

    local export = Cell:CreateButton(listPane, nil, "accent-hover", {27, 17}, nil, nil, nil, nil, nil, L["Export"])
    export:SetPoint("TOPRIGHT", hint, "TOPLEFT", -1, 0)
    export:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\export", {15, 15}, {"CENTER", 0, 0})
    export:SetScript("OnClick", function()
        F:ShowClickCastingExportFrame(clickCastingTable)
    end)

    local import = Cell:CreateButton(listPane, nil, "accent-hover", {27, 17}, nil, nil, nil, nil, nil, L["Import"])
    import:SetPoint("TOPRIGHT", export, "TOPLEFT", -1, 0)
    import:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\import", {15, 15}, {"CENTER", 0, 0})
    import:SetScript("OnClick", function()
        F:ShowClickCastingImportFrame()
    end)

    bindingButton = Cell:CreateBindingButton(listPane, 130)

    -- bindings frame
    bindingsFrame = Cell:CreateFrame("ClickCastingsTab_BindingsFrame", listPane)
    bindingsFrame:SetPoint("TOPLEFT", 0, -27)
    bindingsFrame:SetPoint("BOTTOMRIGHT", 0, 19)
    bindingsFrame:Show()

    Cell:CreateScrollFrame(bindingsFrame, -5, 5)
    bindingsFrame.scrollFrame:SetScrollStep(25)

    -- new & save & discard
    local newBtn = Cell:CreateButton(listPane, L["New"], "blue-hover", {141, 20})
    newBtn:SetPoint("TOPLEFT", bindingsFrame, "BOTTOMLEFT", 0, P:Scale(1))
    newBtn:SetScript("OnClick", function()
        local index = #clickCastingTable+1
        local b = CreateBindingListButton("", "notBound", "general", "target", index)
        tinsert(clickCastingTable, EncodeDB("", "notBound", "general", "target"))

        b:SetPoint("TOP", 0, P:Scale(-20)*(index-1)+P:Scale(-5)*(index-1))

        menu:Hide()
        bindingButton:Hide()

        -- scroll
        bindingsFrame.scrollFrame:SetContentHeight(P:Scale(20), #clickCastingTable, P:Scale(5))
        bindingsFrame.scrollFrame:ScrollToBottom()
    end)

    saveBtn = Cell:CreateButton(listPane, L["Save"], "green-hover", {142, 20})
    saveBtn:SetPoint("TOPLEFT", newBtn, "TOPRIGHT", P:Scale(-1), 0)
    saveBtn:SetEnabled(false)
    saveBtn:SetScript("OnClick", function()
        -- deleted
        local deletedIndices = {}
        for index, b in pairs(deleted) do
            if changed[index] then changed[index] = nil end -- if duplicated in changed, remove it
            -- clickCastingTable[index] = nil -- update db
            tinsert(deletedIndices, index)
        end

        -- changed
        for index, t in pairs(changed) do
            local b = t[1]
            local modifier = t["modifier"] or b.modifier
            local bindKey = t["bindKey"] or b.bindKey
            local bindType = t["bindType"] or b.bindType
            local bindAction = t["bindAction"] or b.bindAction
            clickCastingTable[index] = EncodeDB(modifier, bindKey, bindType, bindAction)
            -- texplore(clickCastingTable[index])
        end

        -- delete!
        table.sort(deletedIndices)
        for i, index in pairs(deletedIndices) do
            tremove(clickCastingTable, index-i+1) -- continuous table index
        end

        -- reload
        Cell:Fire("UpdateClickCastings")
        wipe(deleted)
        wipe(changed)
        CheckChanges()
        menu:Hide()
        if clickCastingsTab.popupEditBox then clickCastingsTab.popupEditBox:Hide() end
    end)

    discardBtn = Cell:CreateButton(listPane, L["Discard"], "red-hover", {141, 20})
    discardBtn:SetPoint("TOPLEFT", saveBtn, "TOPRIGHT", P:Scale(-1), 0)
    discardBtn:SetEnabled(false)
    discardBtn:SetScript("OnClick", function()
        -- deleted
        for index, b in pairs(deleted) do
            b:SetAlpha(1)
            b:SetChanged(false)
        end
        -- changed
        for index, t in pairs(changed) do
            t[1]:SetChanged(false)

            t[1].keyGrid:SetText(GetBindingDisplay(t[1].modifier, t[1].bindKey))
            t[1].typeGrid:SetText(L[F:UpperFirst(t[1].bindType)])
            t[1].actionGrid:SetText(t[1].bindActionDisplay)
            -- restore icon
            if t[1].bindType == "spell" then
                t[1]:ShowSpellIcon(t[1].bindAction)
            else
                t[1]:HideSpellIcon()
            end
        end
        wipe(deleted)
        wipe(changed)
        CheckChanges()
        menu:Hide()
        if clickCastingsTab.popupEditBox then clickCastingsTab.popupEditBox:Hide() end
    end)
end

-------------------------------------------------
-- bindings frame
-------------------------------------------------
CreateBindingListButton = function(modifier, bindKey, bindType, bindAction, i)
    if not listButtons[i] then
        listButtons[i] = Cell:CreateBindingListButton(bindingsFrame.scrollFrame.content, "", "", "", "")
    end
    local b = listButtons[i]
    b:SetParent(bindingsFrame.scrollFrame.content)
    b:SetAlpha(1)
    b:SetChanged(false)
    b:Show()

    b.modifier, b.bindKey, b.bindType, b.bindAction = modifier, bindKey, bindType, bindAction
    b.clickCastingIndex = i

    if bindType == "general" then
        b.bindActionDisplay = L[bindAction]
        b:HideSpellIcon()
    elseif bindType == "spell" then
        if bindAction ~= "" then
            if type(bindAction) ~= "number" then
                b.bindActionDisplay = "|cFFFF3030"..L["Invalid"]
                b:ShowSpellIcon()
            else
                b.bindActionDisplay = F:GetSpellNameAndIcon(bindAction) or "|cFFFF3030"..L["Invalid"]
                b:ShowSpellIcon(bindAction)
            end
        else
            b.bindActionDisplay = ""
            b:HideSpellIcon()
        end
    else
        b.bindActionDisplay = bindAction
        b:HideSpellIcon()
    end

    b.keyGrid:SetText(GetBindingDisplay(modifier, bindKey))
    b.typeGrid:SetText(L[F:UpperFirst(bindType)])
    b.actionGrid:SetText(b.bindActionDisplay)

    b:SetPoint("LEFT", 5, 0)
    b:SetPoint("RIGHT", -5, 0)

    b:SetScript("OnClick", function(self, button, down)
        if button == "RightButton" then
            if deleted[i] then
                deleted[i] = nil
                if not changed[i] then
                    b:SetChanged(false)
                end
                b:SetAlpha(1)
            else
                deleted[i] = b
                b:SetChanged(true)
                b:SetAlpha(0.3)
            end
            CheckChanges()
        end
    end)

    b.keyGrid:SetScript("OnClick", function(self, button, down)
        if button == "RightButton" then
            b:GetScript("OnClick")(b, button, down)
        else
            ShowBindingMenu(i, b)
        end
    end)

    b.typeGrid:SetScript("OnClick", function(self, button, down)
        if button == "RightButton" then
            b:GetScript("OnClick")(b, button, down)
        else
            ShowTypesMenu(i, b)
        end
    end)

    b.actionGrid:SetScript("OnClick", function(self, button, down)
        if button == "RightButton" then
            b:GetScript("OnClick")(b, button, down)
        else
            ShowActionsMenu(i, b)
        end
    end)

    return b
end

LoadProfile = function(isCommon)
    targetingDropdown:SetSelectedValue(alwaysTargeting)
    UpdateCurrentText(isCommon)

    last = nil
    bindingsFrame.scrollFrame:Reset()
    -- F:Debug("-- Load clickCastings start --------------")
    for i, t in pairs(clickCastingTable) do
        -- F:Debug(table.concat(t, ","))
        local modifier, bindKey, bindType, bindAction = DecodeDB(t)
        local b = CreateBindingListButton(modifier, bindKey, bindType, bindAction, i)

        b:SetPoint("TOP", 0, P:Scale(-20)*(i-1)+P:Scale(-5)*(i-1))
    end
    -- hide unused
    for i = #clickCastingTable+1, #listButtons do
        listButtons[i]:Hide()
    end
    -- F:Debug("-- Load clickCastings end ----------------")
    bindingsFrame.scrollFrame:SetContentHeight(P:Scale(20), #clickCastingTable, P:Scale(5))
    menu:Hide()
    wipe(deleted)
    wipe(changed)
end

function F:MoveClickCastings(from, to)
    F:Debug(from, "->", to)
    if from and to then
        local temp = clickCastingTable[from]
        tremove(clickCastingTable, from)
        tinsert(clickCastingTable, to, temp)
    end
    LoadProfile(Cell.vars.clickCastings["useCommon"])
end

-------------------------------------------------
-- check conflicts
-------------------------------------------------
function CheckConflicts()
    local selfCast = GetModifiedClick("SELFCAST")
    -- local focusCast = GetModifiedClick("FOCUSCAST")

    local selfCastMsg, focusCastMsg
    if selfCast ~= "NONE" then
        selfCastMsg = AUTO_SELF_CAST_KEY_TEXT..": |cFFFFD100"..selfCast.."|r\n"
    end
    -- if focusCast ~= "NONE" then
    --     focusCastMsg = FOCUS_CAST_KEY_TEXT..": |cFFFFD100"..focusCast.."|r\n"
    -- end

    if selfCastMsg or focusCastMsg then
        local msg = "|cFFFF3030"..L["Conflicts Detected!"].."|r\n"..(selfCastMsg or "")..(focusCastMsg or "")..
            "\n|cFFFF3030"..L["Yes"].."|r - "..L["Remove"].."\n".."|cFFFF3030"..L["No"].."|r - "..L["Cancel"]

        local popup = Cell:CreateConfirmPopup(clickCastingsTab, 200, msg, function(self)
            if Cell.isRetail then
                --! NOTE: show-set-hide or commit
                -- ShowUIPanel(SettingsPanel)
                -- Settings.OpenToCategory(8)
                Settings.SetValue("SELFCAST", "NONE", true)
                -- HideUIPanel(SettingsPanel)
                SettingsPanel:Commit()
            else
                SetModifiedClick("SELFCAST", "NONE")
                -- SetModifiedClick("FOCUSCAST", "NONE")
                SaveBindings(GetCurrentBindingSet())
            end
        end, nil, true)
        popup:SetPoint("TOPLEFT", 117, -90)
    end
end

-------------------------------------------------
-- functions
-------------------------------------------------
local init
local function ShowTab(tab)
    if tab == "clickCastings" then
        if not init then
            init = true
            CreateProfilePane()
            CreateTargetingPane()
            CreateSmartResPane()
            CreateListPane()
            F:ApplyCombatProtectionToFrame(clickCastingsTab)
        end
        clickCastingsTab:Show()
    else
        clickCastingsTab:Hide()
    end
end
Cell:RegisterCallback("ShowOptionsTab", "ClickCastingsTab_ShowTab", ShowTab)

clickCastingsTab:SetScript("OnShow", function()
    CheckConflicts()

    if loaded then return end

    loaded = true

    local isCommon = Cell.vars.clickCastings["useCommon"]
    profileDropdown:SetSelectedItem(isCommon and 1 or 2)
    -- UpdateCurrentText(isCommon)
    LoadProfile(isCommon)

    smartResDropdown:SetSelectedValue(Cell.vars.clickCastings["smartResurrection"])

    menu:SetMenuParent(clickCastingsTab)
    -- texplore(changed)
end)

function F:UpdateClickCastingProfileLabel()
    if loaded then
        UpdateCurrentText(Cell.vars.clickCastings["useCommon"])
    end
end