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
local clickCastingTable
local loaded
local LoadProfile
local alwaysTargeting
-------------------------------------------------
-- changes
-------------------------------------------------
local saveBtn, discardBtn
local deleted, changed = {}, {}
local function CheckChanges()
    if F:Getn(deleted) == 0 and F:Getn(changed) == 0 then
        saveBtn:SetEnabled(false)
        discardBtn:SetEnabled(false)
    else
        saveBtn:SetEnabled(true)
        discardBtn:SetEnabled(true)
    end
end

-------------------------------------------------
-- db
-------------------------------------------------
-- https://wow.gamepedia.com/SecureActionButtonTemplate
-- {"shift-type1", "macro", "shift-macrotext1", "/cast [@mouseover] 回春术"}

local modifiers = {"", "shift-", "ctrl-", "alt-", "ctrl-shift-", "alt-shift-", "alt-ctrl-", "alt-ctrl-shift-"}
local modifiersDisplay = {"", "Shift|cff777777+|r", "Ctrl|cff777777+|r", "Alt|cff777777+|r", "Ctrl|cff777777+|rShift|cff777777+|r", "Alt|cff777777+|rShift|cff777777+|r", "Alt|cff777777+|rCtrl|cff777777+|r", "Alt|cff777777+|rCtrl|cff777777+|rShift|cff777777+|r"}
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

-- local invalidCache = {}
-- local function UpdateInvalidCache()
--     wipe(invalidCache)
--     -- db
--     for i, t in pairs(clickCastingTable) do
--         invalidCache[t[1]] = i
--     end
--     -- changed
--     for i, t in pairs(changed) do
--         local key = GetAttributeKey(t.modifier or t[1].modifier, t.bindKey or t[1].bindKey)
--         -- update db with changed
--         local dbAttrKey = F:GetIndex(invalidCache, i)
--         if dbAttrKey then
--             invalidCache[dbAttrKey] = nil
--         end
--         invalidCache[key] = i
--     end
--     -- deleted
--     for i, _ in pairs(deleted) do
--         -- update db with deleted
--         local dbAttrKey = F:GetIndex(invalidCache, i)
--         if dbAttrKey then
--             invalidCache[dbAttrKey] = nil
--         end
--     end
-- end

-- local function IsBindKeyValid(modifier, bindKey, useCache)
--     local key = GetAttributeKey(modifier, bindKey)

--     if useCache then
--         if invalidCache[key] then
--             return false, invalidCache[key]
--         end
--     else
--         -- check db
--         for i, t in pairs(clickCastingTable) do
--             if t[1] == key then
--                 return false, i
--             end
--         end
--     end

--     return true, key
-- end

-- local function GetAValidBindKey()
--     UpdateInvalidCache()
--     local validModifier, validKey
--     for key, _ in pairs(mouseKeyIDs) do
--         for _, modifier in pairs(modifiers) do
--             local isValid, value = IsBindKeyValid(modifier, key, true)
--             if isValid then
--                 validModifier, validKey = modifier, key
--                 break
--             end
--         end
--         if validModifier and validKey then break end
--     end
--     return validModifier, validKey
-- end

-------------------------------------------------
-- mouse wheel & keyboard
-------------------------------------------------
local wrapFrame = CreateFrame("Frame", "CellWrapFrame", nil, "SecureHandlerStateTemplate")
wrapFrame:SetAttribute("_onstate-mouseoverstate", [[
    -- print(newstate)
    if newstate == "false" and mouseoverbutton then
        if not mouseoverbutton:IsUnderMouse() then
            mouseoverbutton:ClearBindings()
            mouseoverbutton = nil
        end
    end
]])
--! NOTE: not available for unit far away (different map)
RegisterStateDriver(wrapFrame, "mouseoverstate", "[@mouseover, exists] true; false")

local function SetBindingClicks(b)
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
                    bindingClicks[key] = [[self:SetBindingClick(true, "]]..strupper(m..k)..[[", self, "]]..key..[[")]]
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

local function ApplyClickCastings(b)
    for _, t in pairs(clickCastingTable) do
        local bindKey = t[1]
        if strfind(bindKey, "SCROLL") then
            bindKey = GetMouseWheelBindKey(t[1])
        end

        b:SetAttribute(bindKey, t[2])
        if t[2] == "spell" then
            if (alwaysTargeting == "left" and bindKey == "type1") or alwaysTargeting == "any" then
                --NOTE: as macro
                b:SetAttribute(bindKey, "macro")
                local attr = string.gsub(bindKey, "type", "macrotext")
                b:SetAttribute(attr, "/cast [@mouseover] ".. t[3].."\n/target [@mouseover]")
            else
                local attr = string.gsub(bindKey, "type", "spell")
                b:SetAttribute(attr, t[3])
            end
        elseif t[2] == "macro" then
            local attr = string.gsub(bindKey, "type", "macrotext")
            b:SetAttribute(attr, t[3])
        end
    end
end

local function UpdateClickCastings(noLoad)
    F:Debug("|cff77ff77UpdateClickCastings:|r useCommon: "..tostring(Cell.vars.clickCastingTable["useCommon"]))
    clickCastingTable = Cell.vars.clickCastingTable["useCommon"] and Cell.vars.clickCastingTable["common"] or Cell.vars.clickCastingTable[Cell.vars.playerSpecID]
    -- FIXME: remove this determine statement
    if Cell.vars.clickCastingTable["alwaysTargeting"] then
        alwaysTargeting = Cell.vars.clickCastingTable["alwaysTargeting"][Cell.vars.clickCastingTable["useCommon"] and "common" or Cell.vars.playerSpecID]
    else
        alwaysTargeting = "disabled"
    end
    
    if noLoad then -- create new
        bindingsFrame.scrollFrame:SetContentHeight(20, #clickCastingTable, 5)
        bindingsFrame.scrollFrame:ScrollToBottom()
    else
        if clickCastingsTab:IsVisible() then
            LoadProfile(Cell.vars.clickCastingTable["useCommon"])
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
    end)
    previousClickCastings = F:Copy(clickCastingTable)
end
Cell:RegisterCallback("UpdateClickCastings", "UpdateClickCastings", UpdateClickCastings)

-------------------------------------------------
-- profiles dropdown
-------------------------------------------------
local profileDropdown

local function CreateProfilePane()
    local profilePane = Cell:CreateTitledPane(clickCastingsTab, L["Profiles"], 250, 50)
    profilePane:SetPoint("TOPLEFT", 5, -5)
    
    profileDropdown = Cell:CreateDropdown(profilePane, 240)
    profileDropdown:SetPoint("TOPLEFT", profilePane, "TOPLEFT", 5, -27)
    
    profileDropdown:SetItems({
        {
            ["text"] = L["Use common profile"],
            ["onClick"] = function()
                Cell.vars.clickCastingTable["useCommon"] = true
                Cell:Fire("UpdateClickCastings")
                LoadProfile(true)
            end,
        },
        {
            ["text"] = L["Use separate profile for each spec"],
            ["onClick"] = function()
                Cell.vars.clickCastingTable["useCommon"] = false
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
    local targetingPane = Cell:CreateTitledPane(clickCastingsTab, L["Always Targeting"], 160, 50)
    targetingPane:SetPoint("TOPLEFT", clickCastingsTab, "TOPLEFT", 267, -5)

    targetingDropdown = Cell:CreateDropdown(targetingPane, 150)
    targetingDropdown:SetPoint("TOPLEFT", targetingPane, "TOPLEFT", 5, -27)

    targetingDropdown:SetItems({
        {
            ["text"] = L["Disabled"],
            ["value"] = "disabled",
            ["onClick"] = function()
                local spec = Cell.vars.clickCastingTable["useCommon"] and "common" or Cell.vars.playerSpecID
                CellDB["clickCastings"][Cell.vars.playerClass]["alwaysTargeting"][spec] = "disabled"
                alwaysTargeting = "disabled"
                Cell:Fire("UpdateClickCastings", true)
            end,
        },
        {
            ["text"] = L["Left Spell"],
            ["value"] = "left",
            ["onClick"] = function()
                local spec = Cell.vars.clickCastingTable["useCommon"] and "common" or Cell.vars.playerSpecID
                CellDB["clickCastings"][Cell.vars.playerClass]["alwaysTargeting"][spec] = "left"
                alwaysTargeting = "left"
                Cell:Fire("UpdateClickCastings", true)
            end,
        },
        {
            ["text"] = L["Any Spells"],
            ["value"] = "any",
            ["onClick"] = function()
                local spec = Cell.vars.clickCastingTable["useCommon"] and "common" or Cell.vars.playerSpecID
                CellDB["clickCastings"][Cell.vars.playerClass]["alwaysTargeting"][spec] = "any"
                alwaysTargeting = "any"
                Cell:Fire("UpdateClickCastings", true)
            end,
        },
    })
    Cell:SetTooltips(targetingDropdown, "ANCHOR_TOPLEFT", 0, 2, L["Always Targeting"], L["Only available for Spells"])
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
        local modifierDisplay = modifiersDisplay[F:GetIndex(modifiers, modifier)]
        b.keyGrid:SetText(modifierDisplay..L[key])

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
    -- if already in deleted, do nothing
    if deleted[index] then return end
    
    local items = {
        {
            ["text"] = L["General"],
            ["onClick"] = function()
                b.typeGrid:SetText(L["General"])

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
                    b.actionGrid:SetText(b.bindAction)
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
        }

    elseif bindType == "macro" then
        items = {
            {
                ["text"] = L["Edit"],
                ["onClick"] = function()
                    local peb = Cell:CreatePopupEditBox(clickCastingsTab, 77, function(text)
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
                    peb:SetTips("|cff777777"..L["Shift+Enter: add a new line"].."\n"..L["Enter: apply\nESC: discard"])
                    peb:ShowEditBox(b.bindType == "macro" and b.bindAction or "")
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
        }

    else -- spell
        items = {
            {
                ["text"] = L["Edit"],
                ["onClick"] = function()
                    local peb = Cell:CreatePopupEditBox(clickCastingsTab, 77, function(text)
                        changed[index] = changed[index] or {b}
                        if b.bindAction ~= text then
                            changed[index]["bindAction"] = text
                            b.actionGrid:SetText(text)
                            b:ShowSpellIcon(text)
                        else
                            changed[index]["bindAction"] = nil
                            b.actionGrid:SetText(b.bindAction)
                            b:ShowSpellIcon(b.bindAction)
                        end
                        CheckChanged(index, b)
                        CheckChanges()
                    end)
                    P:Point(peb, "TOPLEFT", b.actionGrid)
                    P:Point(peb, "TOPRIGHT", b.actionGrid)
                    peb:SetTips("|cff777777"..L["Enter: apply\nESC: discard"])
                    peb:ShowEditBox(b.bindType == "spell" and b.bindAction or "")
                end,
            },
        }
        local spells = F:GetSpellList(Cell.vars.playerClass, Cell.vars.playerSpecID)
        -- default spells
        for _, t in ipairs(spells) do
            tinsert(items, {
                --! CANNOT use "|T****|t", if too many items (over 10?), it will cause game stuck!! I don't know why!
                -- ["text"] = "|T"..t[1]..":12:12:0:0:12:12:1:11:1:11|t "..t[2]..(t[3] and (" |cff777777("..t[3]..")") or ""),
                ["text"] = t[2]..(t[3] and (" |cff777777("..t[3]..")") or ""),
                ["icon"] = t[1],
                ["onClick"] = function()
                    changed[index] = changed[index] or {b}
                    if b.bindAction ~= t[2] then
                        changed[index]["bindAction"] = t[2]
                        b.actionGrid:SetText(t[2])
                        b:ShowSpellIcon(t[2])
                    else
                        changed[index]["bindAction"] = nil
                        b.actionGrid:SetText(b.bindAction)
                        b:ShowSpellIcon(b.bindAction)
                    end
                    CheckChanged(index, b)
                    CheckChanges()
                end,
            })
        end
    end

    menu:SetWidths(b.actionGrid:GetWidth())
    menu:SetItems(items)
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
        listPane:SetTitle(L["Current Profile"]..": ".."|T"..Cell.vars.playerSpecIcon..":12:12:0:0:12:12:1:11:1:11|t "..Cell.vars.playerSpecName)
    end
end

local function CreateListPane()
    listPane = Cell:CreateTitledPane(clickCastingsTab, L["Current Profile"], 422, 351)
    listPane:SetPoint("TOPLEFT", clickCastingsTab, "TOPLEFT", 5, -70)
    
    local hintText = listPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET_TITLE")
    hintText:SetPoint("BOTTOMRIGHT", listPane.line, "TOPRIGHT", 0, P:Scale(2))
    hintText:SetText("|cFF777777"..L["left-click: edit"].."    "..L["right-click: delete"])
    
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
        local b = CreateBindingListButton("", "notBound", "general", "target", #clickCastingTable+1)
        tinsert(clickCastingTable, EncodeDB("", "notBound", "general", "target"))

        if last then
            b:SetPoint("TOP", last, "BOTTOM", 0, -5)
        else
            b:SetPoint("TOP")
        end
        last = b
        Cell:Fire("UpdateClickCastings", true)
        menu:Hide()
        bindingButton:Hide()
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

            local modifierDisplay = modifiersDisplay[F:GetIndex(modifiers, t[1].modifier)]
            t[1].keyGrid:SetText(modifierDisplay..L[t[1].bindKey])
            t[1].typeGrid:SetText(L[F:UpperFirst(t[1].bindType)])
            t[1].actionGrid:SetText(t[1].bindType == "general" and L[t[1].bindAction] or t[1].bindAction)
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
    local modifierDisplay = modifiersDisplay[F:GetIndex(modifiers, modifier)]

    local b = Cell:CreateBindingListButton(bindingsFrame.scrollFrame.content, modifierDisplay, (bindKey=="P" or bindKey=="T") and bindKey or L[bindKey], L[F:UpperFirst(bindType)], bindType == "general" and L[bindAction] or bindAction)
    b.modifier, b.bindKey, b.bindType, b.bindAction = modifier, bindKey, bindType, bindAction

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

    -- spell icon
    if bindType == "spell" then
        b:ShowSpellIcon(bindAction)
    else
        b:HideSpellIcon()
    end

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

        if last then
            b:SetPoint("TOP", last, "BOTTOM", 0, -5)
        else
            b:SetPoint("TOP")
        end
        last = b
    end
    -- F:Debug("-- Load clickCastings end ----------------")
    bindingsFrame.scrollFrame:SetContentHeight(20, #clickCastingTable, 5)
    menu:Hide()
    wipe(deleted)
    wipe(changed)
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
            CreateListPane()
        end
        clickCastingsTab:Show()
    else
        clickCastingsTab:Hide()
    end
end
Cell:RegisterCallback("ShowOptionsTab", "ClickCastingsTab_ShowTab", ShowTab)

clickCastingsTab:SetScript("OnShow", function()
    if loaded then return end

    loaded = true
    
    local isCommon = Cell.vars.clickCastingTable["useCommon"]
    profileDropdown:SetSelectedItem(isCommon and 1 or 2)
    UpdateCurrentText(isCommon)
    LoadProfile(isCommon)

    menu:SetMenuParent(clickCastingsTab)
    -- texplore(changed)
end)