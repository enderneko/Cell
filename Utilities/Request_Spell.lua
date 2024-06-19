local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local U = Cell.uFuncs
local P = Cell.pixelPerfectFuncs
local LCG = LibStub("LibCustomGlow-1.0")

-------------------------------------------------
-- spell request
-------------------------------------------------
local srPane, srTypeOptionsBtn
local ShowSpellEditFrame
local waTips, srEnabledCB, srExistsCB, srKnownOnlyCB, srFreeCDOnlyCB, srReplyCDCB, srReplyCastEB, srResponseDD, srResponseText, srTimeoutDD, srTimeoutText
local srSpellsDD, srSpellsText, srAddBtn, srDeleteBtn, srMacroText, srMacroEB, srTypeDD, srTypeText
local srSelectedSpell, canEdit, srType

local function ShowSpellOptions(index)
    U:HideGlowOptions()
    U:HideIconOptions()
    Cell:StopRainbowText(srTypeOptionsBtn:GetFontString())

    srSelectedSpell = index

    local responseType = CellDB["spellRequest"]["responseType"]
    local spellId = CellDB["spellRequest"]["spells"][index]["spellId"]
    local macroText, keywords

    if responseType == "all" then
        srMacroText:SetText(L["Macro"])
        macroText = "/run C_ChatInfo.SendAddonMessage(\"CELL_REQ_S\",\""..spellId.."\",\"RAID\")"
    elseif responseType == "me" then
        srMacroText:SetText(L["Macro"])
        macroText = "/run C_ChatInfo.SendAddonMessage(\"CELL_REQ_S\",\""..spellId..":"..GetUnitName("player").."\",\"RAID\")"
    else -- whisper
        srMacroText:SetText(L["Contains"])
        keywords = CellDB["spellRequest"]["spells"][index]["keywords"]
    end

    if macroText then
        srMacroEB:SetText(macroText)
        srMacroEB.gauge:SetText(macroText)
        srMacroEB:SetScript("OnTextChanged", function(self, userChanged)
            if userChanged then
                srMacroEB:SetText(macroText)
                srMacroEB:HighlightText()
            end
        end)
    else
        srMacroEB:SetText(keywords)
        srMacroEB.gauge:SetText(keywords)
        srMacroEB:SetScript("OnTextChanged", function(self, userChanged)
            if userChanged then
                CellDB["spellRequest"]["spells"][index]["keywords"] = strtrim(self:GetText())
                Cell:Fire("UpdateRequests", "spellRequest_spells")
            end
        end)
    end

    canEdit = not CellDB["spellRequest"]["spells"][index]["isBuiltIn"] -- not built-in
    srDeleteBtn:SetEnabled(canEdit)

    srMacroText:Show()
    srMacroEB:SetCursorPosition(0)
    srMacroEB:Show()

    srType = CellDB["spellRequest"]["spells"][index]["type"]

    srTypeText:Show()
    srTypeDD:Show()
    srTypeDD:SetSelectedValue(srType)

    srTypeOptionsBtn:Show()
    if srType == "icon" then
        srTypeOptionsBtn:SetText(L["Icon Options"])
    else
        srTypeOptionsBtn:SetText(L["Glow Options"])
    end
end

local function HideSpellOptions()
    U:HideGlowOptions()
    U:HideIconOptions()
    Cell:StopRainbowText(srTypeOptionsBtn:GetFontString())

    srSelectedSpell = nil
    canEdit = nil
    srType = nil
    srSpellsDD:ClearSelected()
    srDeleteBtn:SetEnabled(false)
    srTypeOptionsBtn:Hide()
    CellDropdownList:Hide()
    srMacroText:Hide()
    srMacroEB:Hide()
    srTypeDD:Hide()
    srTypeText:Hide()
end

local function LoadSpellsDropdown()
    local items = {}
    for i, t in pairs(CellDB["spellRequest"]["spells"]) do
        local name, icon = F:GetSpellNameAndIcon(t["spellId"])
        tinsert(items, {
            ["text"] = "|T"..icon..":0::0:0:16:16:1:15:1:15|t "..name,
            ["value"] = t["spellId"],
            ["onClick"] = function()
                ShowSpellOptions(i)
            end
        })
    end
    srSpellsDD:SetItems(items)
end

local function UpdateSRWidgets()
    Cell:SetEnabled(CellDB["spellRequest"]["enabled"], waTips, srExistsCB, srKnownOnlyCB, srResponseDD, srResponseText, srTimeoutDD, srTimeoutText, srSpellsDD, srSpellsText, srAddBtn, srDeleteBtn)
    Cell:SetEnabled(CellDB["spellRequest"]["enabled"] and CellDB["spellRequest"]["knownSpellsOnly"], srFreeCDOnlyCB)
    Cell:SetEnabled(CellDB["spellRequest"]["enabled"] and CellDB["spellRequest"]["knownSpellsOnly"] and CellDB["spellRequest"]["responseType"] ~= "all", srReplyCDCB)
    Cell:SetEnabled(CellDB["spellRequest"]["enabled"] and CellDB["spellRequest"]["knownSpellsOnly"], srReplyCastEB)
end

local function CreateSRPane()
    if not Cell.frames.utilitiesTab.mask then
        Cell:CreateMask(Cell.frames.utilitiesTab, nil, {1, -1, -1, 1})
        Cell.frames.utilitiesTab.mask:Hide()
    end

    srPane = Cell:CreateTitledPane(Cell.frames.utilitiesTab, L["Spell Request"], 422, 250)
    srPane:SetPoint("TOPLEFT", 5, -5)
    srPane:SetPoint("BOTTOMRIGHT", -5, 5)
    srPane:SetScript("OnHide", function()
        HideSpellOptions()
    end)

    waTips = Cell:CreateButton(srPane, "WA", "accent", {50, 17})
    waTips:SetPoint("TOPRIGHT")
    waTips:HookScript("OnEnter", function()
        CellTooltip:SetOwner(waTips, "ANCHOR_NONE")
        CellTooltip:SetPoint("TOPLEFT", waTips, "TOPRIGHT", 6, 0)
        CellTooltip:AddLine("WeakAuras Custom Events")
        CellTooltip:AddLine("|cffffffff"..[[eventName: "CELL_NOTIFY"]])
        CellTooltip:AddLine("|cffffffff".."arg1:\n    \"SPELL_REQ_RECEIVED\"\n    \"SPELL_REQ_APPLIED\"")
        CellTooltip:AddLine("|cffffffff".."arg2: unitId")
        CellTooltip:AddLine("|cffffffff".."arg3: buffId")
        CellTooltip:AddLine("|cffffffff".."arg4: timeout")
        CellTooltip:AddLine("|cffffffff".."arg5: caster")
        CellTooltip:Show()
    end)
    waTips:HookScript("OnLeave", function()
        CellTooltip:Hide()
    end)


    local srTips = srPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    srTips:SetPoint("TOPLEFT", 5, -25)
    srTips:SetJustifyH("LEFT")
    srTips:SetSpacing(5)
    srTips:SetText(L["Glow unit button when a group member sends a %s request"]:format(Cell:GetAccentColorString()..L["SPELL"].."|r").."\n"..
        L["Shows only one spell request on a unit button at a time"]
    )

    -- enabled ----------------------------------------------------------------------
    srEnabledCB = Cell:CreateCheckButton(srPane, L["Enabled"], function(checked, self)
        CellDB["spellRequest"]["enabled"] = checked
        UpdateSRWidgets()
        HideSpellOptions()
        Cell:Fire("UpdateRequests", "spellRequest")
    end)
    srEnabledCB:SetPoint("TOPLEFT", srPane, "TOPLEFT", 5, -100)
    ---------------------------------------------------------------------------------

    -- check exists -----------------------------------------------------------------
    srExistsCB = Cell:CreateCheckButton(srPane, L["Check If Exists"], function(checked, self)
        CellDB["spellRequest"]["checkIfExists"] = checked
        Cell:Fire("UpdateRequests", "spellRequest")
    end, L["Do nothing if requested spell/buff already exists on requester"])
    srExistsCB:SetPoint("TOPLEFT", srEnabledCB, "TOPLEFT", 200, 0)
    ---------------------------------------------------------------------------------

    -- known only -------------------------------------------------------------------
    srKnownOnlyCB = Cell:CreateCheckButton(srPane, L["Known Spells Only"], function(checked, self)
        CellDB["spellRequest"]["knownSpellsOnly"] = checked
        UpdateSRWidgets()
        HideSpellOptions()
        Cell:Fire("UpdateRequests", "spellRequest")
    end, L["If disabled, no check, no reply, just glow"])
    srKnownOnlyCB:SetPoint("TOPLEFT", srEnabledCB, "BOTTOMLEFT", 0, -15)
    ---------------------------------------------------------------------------------

    -- free cooldown ----------------------------------------------------------------
    srFreeCDOnlyCB = Cell:CreateCheckButton(srPane, L["Free Cooldown Only"], function(checked, self)
        CellDB["spellRequest"]["freeCooldownOnly"] = checked
        Cell:Fire("UpdateRequests", "spellRequest")
    end)
    srFreeCDOnlyCB:SetPoint("TOPLEFT", srKnownOnlyCB, "TOPLEFT", 200, 0)
    ---------------------------------------------------------------------------------

    -- reply cd ---------------------------------------------------------------------
    srReplyCDCB = Cell:CreateCheckButton(srPane, L["Reply With Cooldown"], function(checked, self)
        CellDB["spellRequest"]["replyCooldown"] = checked
        Cell:Fire("UpdateRequests", "spellRequest")
    end)
    srReplyCDCB:SetPoint("TOPLEFT", srKnownOnlyCB, "BOTTOMLEFT", 0, -15)
    ---------------------------------------------------------------------------------

    -- reply after cast -------------------------------------------------------------
    srReplyCastEB = Cell:CreateEditBox(srPane, 20, 20)
    srReplyCastEB:SetPoint("TOPLEFT", srFreeCDOnlyCB, "BOTTOMLEFT", 0, -12)
    srReplyCastEB:SetPoint("RIGHT", -5, 0)
    srReplyCastEB:SetScript("OnTextChanged", function(self, userChanged)
        if userChanged then
            local text = strtrim(self:GetText())
            if text ~= "" then
                CellDB["spellRequest"]["replyAfterCast"] = text
                srReplyCastEB.tip:Hide()
            else
                CellDB["spellRequest"]["replyAfterCast"] = nil
                srReplyCastEB.tip:Show()
            end
            Cell:Fire("UpdateRequests", "spellRequest")
        end
    end)

    srReplyCastEB.tip = srReplyCastEB:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    srReplyCastEB.tip:SetPoint("LEFT", 5, 0)
    srReplyCastEB.tip:SetTextColor(0.4, 0.4, 0.4, 1)
    srReplyCastEB.tip:SetText(L["Reply After Cast"])
    srReplyCastEB.tip:Hide()
    ---------------------------------------------------------------------------------

    -- response ----------------------------------------------------------------------
    srResponseDD = Cell:CreateDropdown(srPane, 345)
    srResponseDD:SetPoint("TOPLEFT", srReplyCDCB, "BOTTOMLEFT", 0, -37)
    srResponseDD:SetItems({
        {
            ["text"] = L["Respond to all requests from group members"],
            ["value"] = "all",
            ["onClick"] = function()
                HideSpellOptions()
                CellDB["spellRequest"]["responseType"] = "all"
                Cell:Fire("UpdateRequests", "spellRequest")
                UpdateSRWidgets()
            end
        },
        {
            ["text"] = L["Respond to requests that are only sent to me"],
            ["value"] = "me",
            ["onClick"] = function()
                HideSpellOptions()
                CellDB["spellRequest"]["responseType"] = "me"
                Cell:Fire("UpdateRequests", "spellRequest")
                UpdateSRWidgets()
            end
        },
        {
            ["text"] = L["Respond to whispers"],
            ["value"] = "whisper",
            ["onClick"] = function()
                HideSpellOptions()
                CellDB["spellRequest"]["responseType"] = "whisper"
                Cell:Fire("UpdateRequests", "spellRequest")
                UpdateSRWidgets()
            end
        },
    })

    srResponseText = srPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    srResponseText:SetPoint("BOTTOMLEFT", srResponseDD, "TOPLEFT", 0, 1)
    srResponseText:SetText(L["Response Type"])
    ---------------------------------------------------------------------------------

    -- timeout ----------------------------------------------------------------------
    srTimeoutDD = Cell:CreateDropdown(srPane, 60)
    srTimeoutDD:SetPoint("TOPLEFT", srResponseDD, "TOPRIGHT", 7, 0)

    local items = {}
    local secs = {1, 2, 3, 4, 5, 10, 15, 20, 25, 30}
    for _, s in ipairs(secs) do
        tinsert(items, {
            ["text"] = s,
            ["value"] = s,
            ["onClick"] = function()
                CellDB["spellRequest"]["timeout"] = s
                Cell:Fire("UpdateRequests", "spellRequest")
            end
        })
    end
    srTimeoutDD:SetItems(items)

    srTimeoutText = srPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    srTimeoutText:SetPoint("BOTTOMLEFT", srTimeoutDD, "TOPLEFT", 0, 1)
    srTimeoutText:SetText(L["Timeout"])
    ---------------------------------------------------------------------------------

    -- spells -----------------------------------------------------------------------
    srSpellsDD = Cell:CreateDropdown(srPane, 268)
    srSpellsDD:SetPoint("TOPLEFT", srResponseDD, "BOTTOMLEFT", 0, -37)

    srSpellsText = srPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    srSpellsText:SetPoint("BOTTOMLEFT", srSpellsDD, "TOPLEFT", 0, 1)
    srSpellsText:SetText(L["Spells"])
    ---------------------------------------------------------------------------------

    -- create -----------------------------------------------------------------------
    srAddBtn = Cell:CreateButton(srPane, L["Add"], "green-hover", {65, 20}, nil, nil, nil, nil, nil,
        L["Add new spell"], L["[Alt+LeftClick] to edit"], L["The spell is required to apply a buff on the target"], L["SpellId and BuffId are the same in most cases"])
    srAddBtn:SetPoint("TOPLEFT", srSpellsDD, "TOPRIGHT", 7, 0)
    srAddBtn:SetScript("OnUpdate", function(self, elapsed)
        srAddBtn.elapsed = (srAddBtn.elapsed or 0) + elapsed
        if srAddBtn.elapsed >= 0.25 then
            if IsAltKeyDown() and canEdit then
                srAddBtn:SetText(L["Edit"])
            else
                srAddBtn:SetText(L["Add"])
            end
        end
    end)
    srAddBtn:SetScript("OnClick", function()
        if IsAltKeyDown() and canEdit then
            ShowSpellEditFrame(srSelectedSpell)
        else
            ShowSpellEditFrame()
        end
    end)
    Cell:RegisterForCloseDropdown(srAddBtn)
    ---------------------------------------------------------------------------------

    -- delete -----------------------------------------------------------------------
    srDeleteBtn = Cell:CreateButton(srPane, L["Delete"], "red-hover", {65, 20})
    srDeleteBtn:SetPoint("TOPLEFT", srAddBtn, "TOPRIGHT", 7, 0)
    srDeleteBtn:SetScript("OnClick", function()
        local name, icon = F:GetSpellNameAndIcon(CellDB["spellRequest"]["spells"][srSelectedSpell]["spellId"])
        local spellEditFrame = Cell:CreateConfirmPopup(Cell.frames.utilitiesTab, 200, L["Delete spell?"].."\n".."|T"..icon..":0::0:0:16:16:1:15:1:15|t "..name, function(self)
            tremove(CellDB["spellRequest"]["spells"], srSelectedSpell)
            srSpellsDD:RemoveCurrentItem()
            HideSpellOptions()
            Cell:Fire("UpdateRequests", "spellRequest_spells")
        end, nil, true)
        spellEditFrame:SetPoint("LEFT", 117, 0)
        spellEditFrame:SetPoint("BOTTOM", srDeleteBtn, 0, 0)
    end)
    Cell:RegisterForCloseDropdown(srDeleteBtn)
    ---------------------------------------------------------------------------------

    -- macro ------------------------------------------------------------------------
    srMacroEB = Cell:CreateEditBox(srPane, 412, 20)
    srMacroEB:SetPoint("TOPLEFT", srSpellsDD, "BOTTOMLEFT", 0, -27)

    srMacroText = srPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    srMacroText:SetPoint("BOTTOMLEFT", srMacroEB, "TOPLEFT", 0, 1)
    srMacroText:SetText(L["Macro"])

    srMacroEB.gauge = srMacroEB:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    srMacroEB:SetScript("OnEditFocusGained", function()
        local requiredWidth = srMacroEB.gauge:GetStringWidth()
        if requiredWidth > srMacroEB:GetWidth() then
            P:Width(srMacroEB, requiredWidth + 20)
        end
        srMacroEB:HighlightText()
    end)
    srMacroEB:SetScript("OnEditFocusLost", function()
        P:Width(srMacroEB, 412)
        srMacroEB:SetCursorPosition(0)
        srMacroEB:HighlightText(0, 0)
    end)
    ---------------------------------------------------------------------------------

    -- type -------------------------------------------------------------------------
    srTypeDD = Cell:CreateDropdown(srPane, 131)
    srTypeDD:SetPoint("TOPLEFT", srMacroEB, "BOTTOMLEFT", 0, -27)
    srTypeDD:SetItems({
        {
            ["text"] = L["Icon"],
            ["value"] = "icon",
            ["onClick"] = function()
                U:HideGlowOptions()
                U:HideIconOptions()
                Cell:StopRainbowText(srTypeOptionsBtn:GetFontString())
                srTypeOptionsBtn:SetText(L["Icon Options"])
                CellDB["spellRequest"]["spells"][srSelectedSpell]["type"] = "icon"
                srType = "icon"
                Cell:Fire("UpdateRequests", "spellRequest")
                Cell:Fire("UpdateRequests", "spellRequest_spells")
            end
        },
        {
            ["text"] = L["Glow"],
            ["value"] = "glow",
            ["onClick"] = function()
                U:HideGlowOptions()
                U:HideIconOptions()
                Cell:StopRainbowText(srTypeOptionsBtn:GetFontString())
                srTypeOptionsBtn:SetText(L["Glow Options"])
                CellDB["spellRequest"]["spells"][srSelectedSpell]["type"] = "glow"
                srType = "glow"
                Cell:Fire("UpdateRequests", "spellRequest")
                Cell:Fire("UpdateRequests", "spellRequest_spells")
            end
        },
    })

    srTypeText = srPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    srTypeText:SetPoint("BOTTOMLEFT", srTypeDD, "TOPLEFT", 0, 1)
    srTypeText:SetText(L["Type"])

    ---------------------------------------------------------------------------------

    -- type option ------------------------------------------------------------------
    srTypeOptionsBtn = Cell:CreateButton(srPane, L["Glow Options"], "accent", {130, 20})
    srTypeOptionsBtn:SetPoint("TOPLEFT", srTypeDD, "TOPRIGHT", 7, 0)
    srTypeOptionsBtn:SetScript("OnClick", function()
        local fs = srTypeOptionsBtn:GetFontString()
        if fs.rainbow then
            Cell:StopRainbowText(fs)
        else
            Cell:StartRainbowText(fs)
        end

        if srType == "icon" then
            U:ShowIconOptions(Cell.frames.utilitiesTab, CellDB["spellRequest"]["spells"][srSelectedSpell]["icon"], CellDB["spellRequest"]["spells"][srSelectedSpell]["iconColor"])
        else
            U:ShowGlowOptions(Cell.frames.utilitiesTab, CellDB["spellRequest"]["spells"][srSelectedSpell]["glowOptions"])
        end
    end)
    srTypeOptionsBtn:SetScript("OnHide", function()
        Cell:StopRainbowText(srTypeOptionsBtn:GetFontString())
    end)
    Cell:RegisterForCloseDropdown(srTypeOptionsBtn)
    ---------------------------------------------------------------------------------
end

-------------------------------------------------
-- spell edit frame
-------------------------------------------------
local spellId, buffId, spellName, spellIcon
local spellEditFrame, title, spellIdEB, buffIdEB, addBtn, cancelBtn

local function CreateSpellEditFrame()
    spellEditFrame = CreateFrame("Frame", nil, Cell.frames.utilitiesTab, "BackdropTemplate")
    spellEditFrame:Hide()
    Cell:StylizeFrame(spellEditFrame, {0.1, 0.1, 0.1, 0.95}, Cell:GetAccentColorTable())
    spellEditFrame:SetFrameLevel(Cell.frames.utilitiesTab:GetFrameLevel() + 50)
    spellEditFrame:SetSize(200, 100)
    spellEditFrame:SetPoint("LEFT", 117, 0)
    spellEditFrame:SetPoint("BOTTOM", srAddBtn, 0, 0)
    spellEditFrame:SetScript("OnHide", function()
        CellSpellTooltip:Hide()
        Cell.frames.utilitiesTab.mask:Hide()
        spellEditFrame:Hide()
        spellIdEB:SetText("")
        buffIdEB:SetText("")
        spellId, buffId, spellName, spellIcon = nil, nil, nil, nil
    end)

    -- title
    title = spellEditFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET_TITLE")
    title:SetWordWrap(true)
    title:SetJustifyH("CENTER")
    title:SetPoint("TOPLEFT", 5, -8)
    title:SetPoint("TOPRIGHT", -5, -8)
    title:SetText(L["Add new spell"])

    -- spllId editbox
    spellIdEB = Cell:CreateEditBox(spellEditFrame, 20, 20)
    spellIdEB:SetPoint("TOPLEFT", spellEditFrame, 10, -30)
    spellIdEB:SetPoint("TOPRIGHT", spellEditFrame, -10, -30)
    spellIdEB:SetNumeric(true)
    spellIdEB:SetScript("OnTabPressed", function()
        buffIdEB:SetFocus()
    end)
    spellIdEB:SetScript("OnTextChanged", function()
        local id = tonumber(spellIdEB:GetText())
        if not id then
            CellSpellTooltip:Hide()
            spellId = nil
            addBtn:SetEnabled(false)
            spellIdEB.tip:SetTextColor(1, 0, 0, 0.777)
            return
        end

        local name, icon = F:GetSpellNameAndIcon(id)
        if not name then
            CellSpellTooltip:Hide()
            spellId = nil
            addBtn:SetEnabled(false)
            spellIdEB.tip:SetTextColor(1, 0, 0, 0.777)
            return
        end

        C_Timer.After(0.1, function()
            CellSpellTooltip:SetOwner(spellEditFrame, "ANCHOR_NONE")
            CellSpellTooltip:SetPoint("TOPLEFT", spellEditFrame, "BOTTOMLEFT", 0, -1)
            CellSpellTooltip:SetSpellByID(id)
            CellSpellTooltip:Show()
        end)

        spellId = id
        spellName = name
        spellIcon = icon
        addBtn:SetEnabled(spellId and buffId)
        spellIdEB.tip:SetTextColor(0, 1, 0, 0.777)
    end)

    spellIdEB.tip = spellIdEB:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    spellIdEB.tip:SetTextColor(0.4, 0.4, 0.4, 1)
    spellIdEB.tip:SetText(L["Spell"].." ID")
    spellIdEB.tip:SetPoint("RIGHT", -5, 0)

    -- buffId editbox
    buffIdEB = Cell:CreateEditBox(spellEditFrame, 20, 20)
    buffIdEB:SetPoint("TOPLEFT", spellIdEB, "BOTTOMLEFT", 0, -5)
    buffIdEB:SetPoint("TOPRIGHT", spellIdEB, "BOTTOMRIGHT", 0, -5)
    buffIdEB:SetNumeric(true)
    buffIdEB:SetScript("OnTabPressed", function()
        if spellIdEB:IsEnabled() then
            spellIdEB:SetFocus()
        end
    end)
    buffIdEB:SetScript("OnTextChanged", function()
        local id = tonumber(buffIdEB:GetText())
        if not id then
            buffId = nil
            addBtn:SetEnabled(false)
            buffIdEB.tip:SetTextColor(1, 0, 0, 0.777)
            return
        end

        local name = F:GetSpellNameAndIcon(id)
        if not name then
            buffId = nil
            addBtn:SetEnabled(false)
            buffIdEB.tip:SetTextColor(1, 0, 0, 0.777)
            return
        end

        buffId = id
        addBtn:SetEnabled(spellId and buffId)
        buffIdEB.tip:SetTextColor(0, 1, 0, 0.777)
    end)

    buffIdEB.tip = buffIdEB:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    buffIdEB.tip:SetTextColor(0.4, 0.4, 0.4, 1)
    buffIdEB.tip:SetText(L["Buff"].." ID")
    buffIdEB.tip:SetPoint("RIGHT", -5, 0)

    -- cancel
    cancelBtn = Cell:CreateButton(spellEditFrame, L["Cancel"], "red", {50, 15})
    cancelBtn:SetPoint("BOTTOMRIGHT")
    cancelBtn:SetBackdropBorderColor(unpack(Cell:GetAccentColorTable()))
    cancelBtn:SetScript("OnClick", function()
        spellEditFrame:Hide()
    end)

    -- add
    addBtn = Cell:CreateButton(spellEditFrame, L["Add"], "green", {50, 15})
    addBtn:SetPoint("BOTTOMRIGHT", cancelBtn, "BOTTOMLEFT", P:Scale(1), 0)
    addBtn:SetBackdropBorderColor(unpack(Cell:GetAccentColorTable()))
    addBtn:SetScript("OnClick", function()
        spellEditFrame:Hide()
    end)
end

ShowSpellEditFrame = function(index)
    Cell.frames.utilitiesTab.mask:Show()
    spellEditFrame:Show()

    if not index then -- add
        spellIdEB:SetEnabled(true)
        spellIdEB:SetFocus()

        title:SetText(L["Add new spell"])
        addBtn:SetText(L["Add"])

        addBtn:SetScript("OnClick", function()
            if spellId and buffId then
                -- check if exists
                for _, t in pairs(CellDB["spellRequest"]["spells"]) do
                    if t["spellId"] == spellId then
                        F:Print(L["Spell already exists."])
                        return
                    end
                end

                -- update db
                tinsert(CellDB["spellRequest"]["spells"], {
                    ["spellId"] = spellId,
                    ["buffId"] = buffId,
                    ["keywords"] = spellName,
                    ["icon"] = spellIcon,
                    ["type"] = "icon",
                    ["iconColor"] = {1, 1, 0, 1},
                    ["glowOptions"] = {
                        "pixel", -- [1] glow type
                        {
                            {0,1,0.5,1}, -- [1] color
                            0, -- [2] x
                            0, -- [3] y
                            9, -- [4] N
                            0.25, -- [5] frequency
                            8, -- [6] length
                            2 -- [7] thickness
                        } -- [2] glowOptions
                    }
                })
                Cell:Fire("UpdateRequests", "spellRequest_spells")

                local index = #CellDB["spellRequest"]["spells"]

                -- update dropdown
                srSpellsDD:AddItem({
                    ["text"] = "|T"..spellIcon..":0::0:0:16:16:1:15:1:15|t "..spellName,
                    ["value"] = spellId,
                    ["onClick"] = function()
                        ShowSpellOptions(index)
                    end
                })
                srSpellsDD:SetSelectedValue(spellId)
                ShowSpellOptions(index)
            else
                F:Print(L["Invalid spell id."])
            end
            spellEditFrame:Hide()
        end)
    else
        spellIdEB:SetEnabled(false)
        buffIdEB:SetFocus()

        spellIdEB:SetText(CellDB["spellRequest"]["spells"][index]["spellId"])
        buffIdEB:SetText(CellDB["spellRequest"]["spells"][index]["buffId"])

        title:SetText(L["Edit spell"])
        addBtn:SetText(L["Save"])

        addBtn:SetScript("OnClick", function()
            if spellId and buffId then
                -- update db
                CellDB["spellRequest"]["spells"][index]["buffId"] = buffId
                Cell:Fire("UpdateRequests", "spellRequest_spells")

                -- update dropdown
                srSpellsDD:SetCurrentItem({
                    ["text"] = "|T"..spellIcon..":0::0:0:16:16:1:15:1:15|t "..spellName,
                    ["value"] = spellId,
                    ["onClick"] = function()
                        ShowSpellOptions(index)
                    end
                })
                srSpellsDD:SetSelectedValue(spellId)
                ShowSpellOptions(index)
            else
                F:Print(L["Invalid spell id."])
            end
            spellEditFrame:Hide()
        end)
    end
end

-------------------------------------------------
-- create icon
-------------------------------------------------
local function GetValue(progress, start, delta)
    local angle = (progress * 2 * math.pi) - (math.pi / 2)
    return start + ((math.sin(angle) + 1) / 2) * delta
end

-- local function GetSineValue(progress, scale)
--     return math.sin(progress * 2 * math.pi) * scale
-- end

function U:CreateSpellRequestIcon(parent)
    local srIcon = CreateFrame("Frame", parent:GetName().."SpellRequestIcon", parent.widgets.srGlowFrame)
    parent.widgets.srIcon = srIcon
    srIcon:SetIgnoreParentAlpha(true)
    srIcon:Hide()

    -- srIcon:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
    -- srIcon:SetBackdropColor(0, 0, 0, 1)

    srIcon.icon = srIcon:CreateTexture(nil, "ARTWORK")
    srIcon.icon:SetTexCoord(0.12, 0.88, 0.12, 0.88)
    P:Point(srIcon.icon, "TOPLEFT", srIcon, "TOPLEFT", 2, -2)
    P:Point(srIcon.icon, "BOTTOMRIGHT", srIcon, "BOTTOMRIGHT", -2, 2)

    function srIcon:Display(tex, color)
        -- srIcon:SetBackdropColor(unpack(color))
        srIcon.icon:SetTexture(tex)

        -- reset
        srIcon:SetScale(1)
        srIcon:SetAlpha(1)
        P:Repoint(srIcon)
        srIcon.elapsed = 0

        LCG.ButtonGlow_Start(srIcon, color)

        srIcon:Show()
    end

    srIcon:SetScript("OnHide", function()
        LCG.ButtonGlow_Stop(srIcon)
    end)

    function srIcon:SetAnimationType(type)
        if type == "beat" then
            srIcon:SetScript("OnUpdate", function(self, elapsed)
                srIcon.elapsed = (srIcon.elapsed or 0) + elapsed * 2
                srIcon:SetScale(GetValue(srIcon.elapsed, 0.9, 0.1))
                if srIcon.elapsed >= 1 then
                    srIcon.elapsed = 0
                end
            end)
        elseif type == "bounce" then
            srIcon:SetScript("OnUpdate", function(self, elapsed)
                srIcon.elapsed = (srIcon.elapsed or 0) + elapsed * 2
                srIcon:SetPoint(
                    CellDB["spellRequest"]["sharedIconOptions"][3],
                    parent.widgets.srGlowFrame,
                    CellDB["spellRequest"]["sharedIconOptions"][4],
                    CellDB["spellRequest"]["sharedIconOptions"][5],
                    CellDB["spellRequest"]["sharedIconOptions"][6] + GetValue(srIcon.elapsed / 1, 0, 7)
                )
            end)
        elseif type == "blink" then
            srIcon:SetScript("OnUpdate", function(self, elapsed)
                srIcon.elapsed = (srIcon.elapsed or 0) + elapsed * 2
                srIcon:SetAlpha(GetValue(srIcon.elapsed, 0.75, 0.25))
                if srIcon.elapsed >= 1 then
                    srIcon.elapsed = 0
                end
            end)
        else
            srIcon:SetScript("OnUpdate", nil)
        end
    end

    function srIcon:UpdatePixelPerfect()
        P:Resize(srIcon)
        P:Repoint(srIcon)
        P:Repoint(srIcon.icon)
    end
end

-------------------------------------------------
-- show
-------------------------------------------------
local init
local function ShowUtilitySettings(which)
    if which == "spellRequest" then
        if not init then
            CreateSRPane()
            CreateSpellEditFrame()
        end

        srPane:Show()

        if init then return end
        init = true

        -- spell request
        srEnabledCB:SetChecked(CellDB["spellRequest"]["enabled"])
        srExistsCB:SetChecked(CellDB["spellRequest"]["checkIfExists"])
        srKnownOnlyCB:SetChecked(CellDB["spellRequest"]["knownSpellsOnly"])
        srFreeCDOnlyCB:SetChecked(CellDB["spellRequest"]["freeCooldownOnly"])
        srReplyCDCB:SetChecked(CellDB["spellRequest"]["replyCooldown"])
        srReplyCastEB:SetText(CellDB["spellRequest"]["replyAfterCast"] or "")
        if not CellDB["spellRequest"]["replyAfterCast"] then
            srReplyCastEB.tip:Show()
        end
        srResponseDD:SetSelectedValue(CellDB["spellRequest"]["responseType"])
        srTimeoutDD:SetSelected(CellDB["spellRequest"]["timeout"])
        UpdateSRWidgets()
        HideSpellOptions()
        LoadSpellsDropdown()

    elseif init then
        srPane:Hide()
    end
end
Cell:RegisterCallback("ShowUtilitySettings", "SpellRequest_ShowUtilitySettings", ShowUtilitySettings)