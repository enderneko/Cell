local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local U = Cell.uFuncs
local P = Cell.pixelPerfectFuncs

local debuffItems = {}
local LoadList

-------------------------------------------------
-- dispel request
-------------------------------------------------
local drPane
local drEnabledCB, drDispellableCB, drResponseDD, drResponseText, drTimeoutDD, drTimeoutText, drMacroText, drMacroEB, drDebuffsText, drDebuffsList, drTypeDD, drTypeText, drTypeOptionsBtn
local drType

local function UpdateDRWidgets()
    Cell:SetEnabled(CellDB["dispelRequest"]["enabled"], drDispellableCB, drResponseDD, drResponseText, drTimeoutDD, drTimeoutText, drMacroText, drMacroEB, drTypeDD, drTypeText, drTypeOptionsBtn)
    Cell:SetEnabled(CellDB["dispelRequest"]["enabled"] and CellDB["dispelRequest"]["responseType"] == "specific", drDebuffsText)
    if CellDB["dispelRequest"]["enabled"] and CellDB["dispelRequest"]["responseType"] == "specific" then
        drDebuffsList.mask:Hide()
    else
        drDebuffsList.mask:Show()
    end
end

local function CreateDRPane()
    drPane = Cell:CreateTitledPane(Cell.frames.utilitiesTab, L["Dispel Request"], 422, 183)
    drPane:SetPoint("TOPLEFT", 5, -5)
    drPane:SetPoint("BOTTOMRIGHT", -5, 5)
    drPane:SetScript("OnHide", function()
        U:HideGlowOptions()
        U:HideTextOptions()
    end)

    local drTips = drPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    drTips:SetPoint("TOPLEFT", 5, -25)
    drTips:SetJustifyH("LEFT")
    drTips:SetSpacing(5)
    drTips:SetText(L["Glow unit button when a group member sends a %s request"]:format(Cell:GetAccentColorString()..L["DISPEL"].."|r"))

    -- enabled ----------------------------------------------------------------------
    drEnabledCB = Cell:CreateCheckButton(drPane, L["Enabled"], function(checked, self)
        CellDB["dispelRequest"]["enabled"] = checked
        UpdateDRWidgets()
        Cell:Fire("UpdateRequests", "dispelRequest")
        CellDropdownList:Hide()

        U:HideGlowOptions()
        U:HideTextOptions()
        Cell:StopRainbowText(drTypeOptionsBtn:GetFontString())
    end)
    drEnabledCB:SetPoint("TOPLEFT", drPane, "TOPLEFT", 5, -80)
    ---------------------------------------------------------------------------------

    -- dispellable ------------------------------------------------------------------
    drDispellableCB = Cell:CreateCheckButton(drPane, L["Dispellable By Me"], function(checked, self)
        CellDB["dispelRequest"]["dispellableByMe"] = checked
        Cell:Fire("UpdateRequests", "dispelRequest")
    end)
    drDispellableCB:SetPoint("TOPLEFT", drEnabledCB, "TOPLEFT", 200, 0)
    ---------------------------------------------------------------------------------

    -- response ---------------------------------------------------------------------
    drResponseDD = Cell:CreateDropdown(drPane, 345)
    drResponseDD:SetPoint("TOPLEFT", drEnabledCB, "BOTTOMLEFT", 0, -37)
    drResponseDD:SetItems({
        {
            ["text"] = L["Respond to all dispellable debuffs"],
            ["value"] = "all",
            ["onClick"] = function()
                CellDB["dispelRequest"]["responseType"] = "all"
                UpdateDRWidgets()
                Cell:Fire("UpdateRequests", "dispelRequest")
            end
        },
        {
            ["text"] = L["Respond to specific dispellable debuffs"],
            ["value"] = "specific",
            ["onClick"] = function()
                CellDB["dispelRequest"]["responseType"] = "specific"
                UpdateDRWidgets()
                Cell:Fire("UpdateRequests", "dispelRequest")
            end
        },
    })

    drResponseText = drPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    drResponseText:SetPoint("BOTTOMLEFT", drResponseDD, "TOPLEFT", 0, 1)
    drResponseText:SetText(L["Response Type"])
    ---------------------------------------------------------------------------------

    -- timeout ----------------------------------------------------------------------
    drTimeoutDD = Cell:CreateDropdown(drPane, 60)
    drTimeoutDD:SetPoint("TOPLEFT", drResponseDD, "TOPRIGHT", 7, 0)

    local items = {}
    local secs = {1, 2, 3, 4, 5, 10, 15, 20, 25, 30}
    for _, s in ipairs(secs) do
        tinsert(items, {
            ["text"] = s,
            ["value"] = s,
            ["onClick"] = function()
                CellDB["dispelRequest"]["timeout"] = s
                Cell:Fire("UpdateRequests", "dispelRequest")
            end
        })
    end
    drTimeoutDD:SetItems(items)

    drTimeoutText = drPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    drTimeoutText:SetPoint("BOTTOMLEFT", drTimeoutDD, "TOPLEFT", 0, 1)
    drTimeoutText:SetText(L["Timeout"])
    ---------------------------------------------------------------------------------

    -- macro ------------------------------------------------------------------------
    drMacroEB = Cell:CreateEditBox(drPane, 412, 20)
    drMacroEB:SetPoint("TOPLEFT", drResponseDD, "BOTTOMLEFT", 0, -27)

    drMacroEB:SetText("/run C_ChatInfo.SendAddonMessage(\"CELL_REQ_D\",\"D\",\"RAID\")")
    drMacroEB:SetCursorPosition(0)

    drMacroEB:SetScript("OnTextChanged", function(self, userChanged)
        if userChanged then
            drMacroEB:SetText("/run C_ChatInfo.SendAddonMessage(\"CELL_REQ_D\",\"D\",\"RAID\")")
            drMacroEB:SetCursorPosition(0)
            drMacroEB:HighlightText()
        end
    end)

    drMacroEB.gauge = drMacroEB:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    drMacroEB.gauge:SetText(drMacroEB:GetText())

    drMacroEB:SetScript("OnEditFocusGained", function()
        local requiredWidth = drMacroEB.gauge:GetStringWidth()
        if requiredWidth > drMacroEB:GetWidth() then
            P:Width(drMacroEB, requiredWidth + 20)
        end
        drMacroEB:HighlightText()
    end)

    drMacroEB:SetScript("OnEditFocusLost", function()
        P:Width(drMacroEB, 412)
        drMacroEB:SetCursorPosition(0)
        drMacroEB:HighlightText(0, 0)
    end)

    drMacroText = drPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    drMacroText:SetPoint("BOTTOMLEFT", drMacroEB, "TOPLEFT", 0, 1)
    drMacroText:SetText(L["Macro"])

    ---------------------------------------------------------------------------------

    -- debuffs ----------------------------------------------------------------------
    drDebuffsList = CreateFrame("Frame", nil, drPane)
    drDebuffsList:SetPoint("TOPLEFT", drMacroEB, "BOTTOMLEFT", 0, -35)
    drDebuffsList:SetSize(270, 172)
    Cell:CreateScrollFrame(drDebuffsList)
    Cell:StylizeFrame(drDebuffsList.scrollFrame)
    drDebuffsList.scrollFrame:SetScrollStep(19)

    Cell:CreateMask(drDebuffsList)
    drDebuffsList.mask:Hide()

    local popup = Cell:CreatePopupEditBox(drDebuffsList)
    popup:SetNumeric(true)
    popup:SetScript("OnTextChanged", function()
        local spellId = tonumber(popup:GetText())
        if not spellId then
            CellSpellTooltip:Hide()
            return
        end

        local name, tex = F:GetSpellInfo(spellId)
        if not name then
            CellSpellTooltip:Hide()
            return
        end

        CellSpellTooltip:SetOwner(popup, "ANCHOR_NONE")
        CellSpellTooltip:SetPoint("TOPLEFT", popup, "BOTTOMLEFT", 0, -1)
        CellSpellTooltip:SetSpellByID(spellId, tex)
        CellSpellTooltip:Show()
    end)

    popup:HookScript("OnHide", function()
        CellSpellTooltip:Hide()
    end)

    debuffItems[0] = Cell:CreateButton(drDebuffsList.scrollFrame.content, "", "transparent-accent", {20, 20})
    debuffItems[0]:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\new", {16, 16}, {"RIGHT", -1, 0})
    debuffItems[0]:SetScript("OnClick", function(self)
        local popup = Cell:CreatePopupEditBox(drDebuffsList, function(text)
            local spellId = tonumber(text)
            local spellName = F:GetSpellInfo(spellId)
            if spellId and spellName then
                -- update db
                tinsert(CellDB["dispelRequest"]["debuffs"], spellId)
                LoadList(true)
            else
                F:Print(L["Invalid spell id."])
            end
        end)
        popup:SetPoint("TOPLEFT", self)
        popup:SetPoint("BOTTOMRIGHT", self)
        popup:ShowEditBox("")
        popup:SetFrameStrata("DIALOG")
        popup:SetTips("|cffababab"..L["Input spell id"])
    end)

    drDebuffsText = drPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    drDebuffsText:SetPoint("BOTTOMLEFT", drDebuffsList, "TOPLEFT", 0, 1)
    drDebuffsText:SetText(L["Debuffs"])
    ---------------------------------------------------------------------------------

    -- type -------------------------------------------------------------------------
    drTypeDD = Cell:CreateDropdown(drPane, 135)
    drTypeDD:SetPoint("TOPLEFT", drDebuffsList, "TOPRIGHT", 7, 0)
    drTypeDD:SetItems({
        {
            ["text"] = L["Text"],
            ["value"] = "text",
            ["onClick"] = function()
                U:HideGlowOptions()
                U:HideTextOptions()
                Cell:StopRainbowText(drTypeOptionsBtn:GetFontString())
                drTypeOptionsBtn:SetText(L["Text Options"])
                CellDB["dispelRequest"]["type"] = "text"
                drType = "text"
                Cell:Fire("UpdateRequests", "dispelRequest")
            end
        },
        {
            ["text"] = L["Glow"],
            ["value"] = "glow",
            ["onClick"] = function()
                U:HideGlowOptions()
                U:HideTextOptions()
                Cell:StopRainbowText(drTypeOptionsBtn:GetFontString())
                drTypeOptionsBtn:SetText(L["Glow Options"])
                CellDB["dispelRequest"]["type"] = "glow"
                drType = "glow"
                Cell:Fire("UpdateRequests", "dispelRequest")
            end
        },
    })

    drTypeText = drPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    drTypeText:SetPoint("BOTTOMLEFT", drTypeDD, "TOPLEFT", 0, 1)
    drTypeText:SetText(L["Type"])

    ---------------------------------------------------------------------------------

    -- type option ------------------------------------------------------------------
    drTypeOptionsBtn = Cell:CreateButton(drPane, L["Glow Options"], "accent", {135, 20})
    drTypeOptionsBtn:SetPoint("TOPLEFT", drTypeDD, "BOTTOMLEFT", 0, -15)
    drTypeOptionsBtn:SetScript("OnClick", function()
        local fs = drTypeOptionsBtn:GetFontString()
        if fs.rainbow then
            Cell:StopRainbowText(fs)
        else
            Cell:StartRainbowText(fs)
        end

        if drType == "text" then
            U:ShowTextOptions(Cell.frames.utilitiesTab)
        else
            U:ShowGlowOptions(Cell.frames.utilitiesTab, CellDB["dispelRequest"]["glowOptions"])
        end
    end)
    drTypeOptionsBtn:SetScript("OnHide", function()
        Cell:StopRainbowText(drTypeOptionsBtn:GetFontString())
    end)
    Cell:RegisterForCloseDropdown(drTypeOptionsBtn)
    ---------------------------------------------------------------------------------
end

LoadList = function(scrollToBottom)
    drDebuffsList.scrollFrame:Reset()

    debuffItems[0]:SetParent(drDebuffsList.scrollFrame.content)
    debuffItems[0]:Show()
    debuffItems[0]:SetPoint("BOTTOMLEFT")
    debuffItems[0]:SetPoint("RIGHT")

    for i, id in ipairs(CellDB["dispelRequest"]["debuffs"]) do
        if not debuffItems[i] then
            debuffItems[i] = Cell:CreateButton(drDebuffsList.scrollFrame.content, "", "transparent-accent", {20, 20})

            -- icon
            debuffItems[i].spellIconBg = debuffItems[i]:CreateTexture(nil, "BORDER")
            debuffItems[i].spellIconBg:SetSize(16, 16)
            debuffItems[i].spellIconBg:SetPoint("TOPLEFT", 2, -2)
            debuffItems[i].spellIconBg:SetColorTexture(0, 0, 0, 1)
            debuffItems[i].spellIconBg:Hide()

            debuffItems[i].spellIcon = debuffItems[i]:CreateTexture(nil, "OVERLAY")
            debuffItems[i].spellIcon:SetPoint("TOPLEFT", debuffItems[i].spellIconBg, 1, -1)
            debuffItems[i].spellIcon:SetPoint("BOTTOMRIGHT", debuffItems[i].spellIconBg, -1, 1)
            debuffItems[i].spellIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            debuffItems[i].spellIcon:Hide()

            -- spellId text
            debuffItems[i].spellIdText = debuffItems[i]:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
            debuffItems[i].spellIdText:SetPoint("LEFT", debuffItems[i].spellIconBg, "RIGHT", 5, 0)
            debuffItems[i].spellIdText:SetPoint("RIGHT", debuffItems[i], "LEFT", 80, 0)
            debuffItems[i].spellIdText:SetWordWrap(false)
            debuffItems[i].spellIdText:SetJustifyH("LEFT")

            -- spellName text
            debuffItems[i].spellNameText = debuffItems[i]:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
            debuffItems[i].spellNameText:SetPoint("LEFT", debuffItems[i].spellIdText, "RIGHT", 5, 0)
            debuffItems[i].spellNameText:SetPoint("RIGHT", -20, 0)
            debuffItems[i].spellNameText:SetWordWrap(false)
            debuffItems[i].spellNameText:SetJustifyH("LEFT")

            -- del
            debuffItems[i].del = Cell:CreateButton(debuffItems[i], "", "none", {18, 20}, true, true)
            debuffItems[i].del:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\delete", {16, 16}, {"CENTER", 0, 0})
            debuffItems[i].del:SetPoint("RIGHT")
            debuffItems[i].del.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
            debuffItems[i].del:SetScript("OnEnter", function()
                debuffItems[i]:GetScript("OnEnter")(debuffItems[i])
                debuffItems[i].del.tex:SetVertexColor(1, 1, 1, 1)
            end)
            debuffItems[i].del:SetScript("OnLeave",  function()
                debuffItems[i]:GetScript("OnLeave")(debuffItems[i])
                debuffItems[i].del.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
            end)

            -- tooltip
            debuffItems[i]:HookScript("OnEnter", function(self)
                if not drDebuffsList.popupEditBox:IsShown() then
                    local name, icon = F:GetSpellInfo(self.spellId)
                    if not name then
                        CellSpellTooltip:Hide()
                        return
                    end

                    CellSpellTooltip:SetOwner(debuffItems[i], "ANCHOR_NONE")
                    CellSpellTooltip:SetPoint("TOPRIGHT", debuffItems[i], "TOPLEFT", -1, 0)
                    CellSpellTooltip:SetSpellByID(self.spellId, icon)
                    CellSpellTooltip:Show()
                end
            end)
            debuffItems[i]:HookScript("OnLeave", function()
                if not drDebuffsList.popupEditBox:IsShown() then
                    CellSpellTooltip:Hide()
                end
            end)
        end

        local name, icon = F:GetSpellInfo(id)

        debuffItems[i].spellId = id
        debuffItems[i].spellIdText:SetText(id)
        debuffItems[i].spellNameText:SetText(name or "|cffff2222"..L["Invalid"])

        if icon then
            debuffItems[i].spellIcon:SetTexture(icon)
            debuffItems[i].spellIcon:Show()
            debuffItems[i].spellIconBg:Show()
        else
            debuffItems[i].spellIcon:Hide()
            debuffItems[i].spellIconBg:Hide()
        end


        debuffItems[i].del:SetScript("OnClick", function()
            tremove(CellDB["dispelRequest"]["debuffs"], i)
            Cell:Fire("UpdateRequests", "dispelRequest")
            LoadList()
        end)

        debuffItems[i]:SetParent(drDebuffsList.scrollFrame.content)
        debuffItems[i]:Show()

        debuffItems[i]:SetPoint("RIGHT")
        if i == 1 then
            debuffItems[i]:SetPoint("TOPLEFT")
        else
            debuffItems[i]:SetPoint("TOPLEFT", debuffItems[i-1], "BOTTOMLEFT", 0, 1)
        end
    end

    drDebuffsList.scrollFrame:SetContentHeight(20, #CellDB["dispelRequest"]["debuffs"]+1, -1)

    if scrollToBottom then
        drDebuffsList.scrollFrame:ScrollToBottom()
    end
end

-------------------------------------------------
-- create text
-------------------------------------------------
function U:CreateDispelRequestText(parent)
    local drText = CreateFrame("Frame", parent:GetName().."DispelRequestText", parent.widgets.indicatorFrame)
    parent.widgets.drText = drText
    drText:SetIgnoreParentAlpha(true)
    drText:Hide()

    local tex = drText:CreateTexture(nil, "ARTWORK")
    -- tex:SetTexture("Interface/AddOns/Cell/Media/FlipBooks/dispel.png")
    --tex:SetAtlas("UI-HUD-ActionBar-GCD-Flipbook")
    --tex:SetTexture("interface/hud/uiactionbarfx")
    --tex:SetTexCoord(0.412598, 0.458496, 0.393555, 0.898438) -- NOTE: SetTexCoord will NOT work
    tex:SetAllPoints(drText)
    tex:SetParentKey("Flipbook")

    local ag = drText:CreateAnimationGroup()
    ag:SetLooping("REPEAT")

    local flip = ag:CreateAnimation("FlipBook")
    flip:SetDuration(1)
    flip:SetFlipBookRows(8)
    flip:SetFlipBookColumns(2)
    flip:SetFlipBookFrames(16)
    --flip:SetFlipBookFrameWidth(0)
    --flip:SetFlipBookFrameHeight(0)
    flip:SetChildKey("Flipbook")

    function drText:Display()
        drText:Show()
        ag:Play()
    end

    function drText:SetType(type)
        tex:SetTexture("Interface/AddOns/Cell/Media/FlipBooks/dispel_"..type..".png")
    end

    function drText:SetColor(color)
        tex:SetVertexColor(unpack(color))
    end
end

-------------------------------------------------
-- show
-------------------------------------------------
local init
local function ShowUtilitySettings(which)
    if which == "dispelRequest" then
        if not init then
            CreateDRPane()
        end

        drPane:Show()

        if init then return end
        init = true

        -- dispel request
        drEnabledCB:SetChecked(CellDB["dispelRequest"]["enabled"])
        drDispellableCB:SetChecked(CellDB["dispelRequest"]["dispellableByMe"])
        drResponseDD:SetSelectedValue(CellDB["dispelRequest"]["responseType"])
        drTimeoutDD:SetSelected(CellDB["dispelRequest"]["timeout"])
        drTypeDD:SetSelectedValue(CellDB["dispelRequest"]["type"])
        UpdateDRWidgets()
        LoadList()

        drType = CellDB["dispelRequest"]["type"]
        if drType == "text" then
            drTypeOptionsBtn:SetText(L["Text Options"])
        else
            drTypeOptionsBtn:SetText(L["Glow Options"])
        end

    elseif init then
        drPane:Hide()
    end
end
Cell:RegisterCallback("ShowUtilitySettings", "DispelRequest_ShowUtilitySettings", ShowUtilitySettings)