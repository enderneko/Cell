local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local U = Cell.uFuncs
local A = Cell.animations
local P = Cell.pixelPerfectFuncs

local LCG = LibStub("LibCustomGlow-1.0")
local LibTranslit = LibStub("LibTranslit-1.0")

-- ----------------------------------------------------------------------- --
--                                quick cast                               --
-- ----------------------------------------------------------------------- --
local quickCastTable
local previewButtons = {}
local UpdatePreview, CreateQuickCastButton

local defaultQuickCastTable = {
    ["enabled"] = false,
    ["namePosition"] = "RIGHT",
    ["num"] = 4,
    ["orientation"] = "top-to-bottom",
    ["size"] = 25,
    ["lines"] = 6,
    ["spacingX"] = 3,
    ["spacingY"] = 3,
    ["glowBuffsColor"] = {1, 1, 0, 1},
    ["glowBuffs"] = {},
    ["glowCastsColor"] = {1, 0, 1, 1},
    ["glowCasts"] = {},
    ["outerColor"] = {0.11, 0.74, 0.9},
    ["outerBuff"] = 0,
    ["innerColor"] = {0.95, 0.32, 0.37},
    ["innerBuff"] = 0,
    ["units"] = {},
    ["position"] = {},
}

-- ----------------------------------------------------------------------- --
--                              option widgets                             --
-- ----------------------------------------------------------------------- --
local qcPane, qcAddEB
local qcEnabledCB, qcNameDD, qcNameText, qcButtonsSlider, qcSizeSlider, qcOrientationDD, qcOrientationText, qcSpacingXSlider, qcSpacingYSlider, qcLinesSlider
local qcOuterCP, qcOuterBtn
local qcInnerCP, qcInnerBtn

local qcGlowBuffsButtons = {}
local qcGlowBuffsPane, qcGlowBuffsCP, qcGlowBuffsAddBtn

local qcGlowCastsButtons = {}
local qcGlowCastsPane, qcGlowCastsCP, qcGlowCastsAddBtn

local function UpdateWidgets()
    Cell:SetEnabled(quickCastTable["enabled"], qcNameDD, qcNameText, qcButtonsSlider, qcSizeSlider, qcOrientationDD, qcOrientationText, qcSpacingXSlider, qcSpacingYSlider, qcLinesSlider)
    Cell:SetEnabled(quickCastTable["enabled"], qcOuterCP, qcOuterBtn, qcInnerCP, qcInnerBtn, qcGlowBuffsCP, qcGlowBuffsAddBtn, qcGlowCastsCP, qcGlowCastsAddBtn)

    for _, b in pairs(qcGlowBuffsButtons) do
        b:SetEnabled(quickCastTable["enabled"])
    end

    for _, b in pairs(qcGlowCastsButtons) do
        b:SetEnabled(quickCastTable["enabled"])
    end
end

-- ----------------------------------------------------------------------- --
--                                main pane                                --
-- ----------------------------------------------------------------------- --
local function CreateQCPane()
    qcPane = Cell:CreateTitledPane(Cell.frames.utilitiesTab, L["Quick Cast"].." |cFF777777"..L["only in group"], 422, 250)
    qcPane:SetPoint("TOPLEFT", 5, -5)
    qcPane:SetPoint("BOTTOMRIGHT", -5, 5)
    qcPane:Hide()

    local qcTips = qcPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    qcTips:SetPoint("TOPLEFT", 5, -25)
    qcTips:SetJustifyH("LEFT")
    qcTips:SetSpacing(5)
    qcTips:SetText(L["Create several buttons for quick casting and buff monitoring"].."\n"..L["These settings are spec-specific"])

    -- enabled ----------------------------------------------------------------------
    qcEnabledCB = Cell:CreateCheckButton(qcPane, L["Enabled"], function(checked, self)
        if not CellDB["quickCast"][Cell.vars.playerClass] then
            CellDB["quickCast"][Cell.vars.playerClass] = {}
        end

        if not CellDB["quickCast"][Cell.vars.playerClass][Cell.vars.playerSpecID] then
            CellDB["quickCast"][Cell.vars.playerClass][Cell.vars.playerSpecID] = F:Copy(defaultQuickCastTable)
        end

        CellDB["quickCast"][Cell.vars.playerClass][Cell.vars.playerSpecID]["enabled"] = checked

        Cell:Fire("UpdateQuickCast")
        UpdateWidgets()
        UpdatePreview()
    end)
    qcEnabledCB:SetPoint("TOPLEFT", qcPane, 5, -75)

    -- name -------------------------------------------------------------------------
    qcNameDD = Cell:CreateDropdown(qcPane, 120)
    qcNameDD:SetPoint("TOPLEFT", qcPane, 297, -75)

    local anchorPoints = {"LEFT", "RIGHT", "TOP", "BOTTOM"}
    local items = {}
    tinsert(items, {
        ["text"] = L["None"],
        ["value"] = "none",
        ["onClick"] = function()
            quickCastTable["namePosition"] = "none"
            UpdatePreview()
            Cell:Fire("UpdateQuickCast")
        end
    })
    for _, point in pairs(anchorPoints) do
        tinsert(items, {
            ["text"] = L[point],
            ["value"] = point,
            ["onClick"] = function()
                quickCastTable["namePosition"] = point
                UpdatePreview()
                Cell:Fire("UpdateQuickCast")
            end
        })
    end
    qcNameDD:SetItems(items)

    qcNameText = qcPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    qcNameText:SetText(L["Name Text"])
    qcNameText:SetPoint("BOTTOMLEFT", qcNameDD, "TOPLEFT", 0, 1)

    -- buttons ----------------------------------------------------------------------
    qcButtonsSlider = Cell:CreateSlider(L["Max Buttons"], qcPane, 1, 6, 120, 1, function(value)
        quickCastTable["num"] = value
        UpdatePreview()
        Cell:Fire("UpdateQuickCast")
    end)
    qcButtonsSlider:SetPoint("TOPLEFT", qcEnabledCB, 0, -55)

    -- orientation ------------------------------------------------------------------
    qcOrientationDD = Cell:CreateDropdown(qcPane, 120)
    qcOrientationDD:SetPoint("TOPLEFT", qcButtonsSlider, 146, 0)
    qcOrientationDD:SetItems({
        {
            ["text"] = L["left-to-right"],
            ["value"] = "left-to-right",
            ["onClick"] = function()
                qcLinesSlider:SetLabel(L["Columns"])
                quickCastTable["orientation"] = "left-to-right"
                Cell:Fire("UpdateQuickCast")
            end
        },
        {
            ["text"] = L["right-to-left"],
            ["value"] = "right-to-left",
            ["onClick"] = function()
                qcLinesSlider:SetLabel(L["Columns"])
                quickCastTable["orientation"] = "right-to-left"
                Cell:Fire("UpdateQuickCast")
            end
        },
        {
            ["text"] = L["top-to-bottom"],
            ["value"] = "top-to-bottom",
            ["onClick"] = function()
                qcLinesSlider:SetLabel(L["Rows"])
                quickCastTable["orientation"] = "top-to-bottom"
                Cell:Fire("UpdateQuickCast")
            end
        },
        {
            ["text"] = L["bottom-to-top"],
            ["value"] = "bottom-to-top",
            ["onClick"] = function()
                qcLinesSlider:SetLabel(L["Rows"])
                quickCastTable["orientation"] = "bottom-to-top"
                Cell:Fire("UpdateQuickCast")
            end
        },
    })

    qcOrientationText = qcPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    qcOrientationText:SetText(L["Orientation"])
    qcOrientationText:SetPoint("BOTTOMLEFT", qcOrientationDD, "TOPLEFT", 0, 1)

    -- row/column -------------------------------------------------------------------
    qcLinesSlider = Cell:CreateSlider(L["Columns"], qcPane, 1, 6, 120, 1, function(value)
        quickCastTable["lines"] = value
        Cell:Fire("UpdateQuickCast")
    end)
    qcLinesSlider:SetPoint("TOPLEFT", qcOrientationDD, 146, 0)

    -- size -------------------------------------------------------------------------
    qcSizeSlider = Cell:CreateSlider(L["Size"], qcPane, 16, 64, 120, 1, function(value)
        quickCastTable["size"] = value
        UpdatePreview()
        Cell:Fire("UpdateQuickCast")
    end)
    qcSizeSlider:SetPoint("TOPLEFT", qcButtonsSlider, 0, -55)

    -- spacingX ---------------------------------------------------------------------
    qcSpacingXSlider = Cell:CreateSlider(L["Spacing"].." X", qcPane, 0, 64, 120, 1, function(value)
        quickCastTable["spacingX"] = value
        Cell:Fire("UpdateQuickCast")
    end)
    qcSpacingXSlider:SetPoint("TOPLEFT", qcSizeSlider, 146, 0)

    -- spacingY ---------------------------------------------------------------------
    qcSpacingYSlider = Cell:CreateSlider(L["Spacing"].." Y", qcPane, 0, 64, 120, 1, function(value)
        quickCastTable["spacingY"] = value
        Cell:Fire("UpdateQuickCast")
    end)
    qcSpacingYSlider:SetPoint("TOPLEFT", qcSpacingXSlider, 146, 0)

    -- input ------------------------------------------------------------------------
    qcAddEB = Cell:CreatePopupEditBox(qcPane)
    qcAddEB:SetNumeric(true)
    qcAddEB:SetFrameStrata("DIALOG")

    qcAddEB:SetScript("OnTextChanged", function()
        local spellId = tonumber(qcAddEB:GetText())
        if not spellId then
            CellSpellTooltip:Hide()
            return
        end

        local name, icon = F:GetSpellNameAndIcon(spellId)
        if not name then
            CellSpellTooltip:Hide()
            return
        end

        CellSpellTooltip:SetOwner(qcAddEB, "ANCHOR_NONE")
        CellSpellTooltip:SetPoint("TOPLEFT", qcAddEB, "BOTTOMLEFT", 0, -1)
        CellSpellTooltip:SetSpellByID(spellId, icon)
        CellSpellTooltip:Show()
    end)

    qcAddEB:HookScript("OnShow", function()
        qcAddEB:SetTips("|cffababab"..L["Input spell id"])
    end)

    qcAddEB:HookScript("OnHide", function()
        CellSpellTooltip:Hide()
    end)

    -- tips -------------------------------------------------------------------------
    local tips = qcPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    tips:SetText("|cffababab"..L["Tip: right-click to delete"])
    tips:SetPoint("BOTTOMLEFT")
end

-- ----------------------------------------------------------------------- --
--                                 preview                                 --
-- ----------------------------------------------------------------------- --
local previewFrame, previewPane, previewButton
UpdatePreview = function()
    if not previewButton then
        previewButton = CreateQuickCastButton(previewPane, "CellQuickCastPreviewButton", true)
        previewButton:SetPoint("TOP", previewPane, 0, -55)

        local _r, _g, _b = F:GetClassColor(Cell.vars.playerClass)
        previewButton._r, previewButton._g, previewButton._b = _r, _g, _b
        previewButton.nameText:SetTextColor(_r, _g, _b)

        local name = Cell.vars.playerNameShort
        name = Cell.vars.nicknameCustoms[name] or Cell.vars.nicknames[name] or name
        if string.len(name) == string.utf8len(name) then -- en
            previewButton.nameText:SetText(string.utf8sub(name, 1, 3))
        else
            previewButton.nameText:SetText(string.utf8sub(name, 1, 1))
        end

        local timer
        previewButton:SetScript("OnUpdate", function(self, elapsed)
            self.glowBuffElapsed = (self.glowBuffElapsed or 0) + elapsed
            self.outerElapsed = (self.outerElapsed or 0) + elapsed
            self.innerElapsed = (self.innerElapsed or 0) + elapsed

            if self.glowBuffElapsed >= 20 then
                self.glowBuffElapsed = 0
                self:SetGlowBuffCooldown(GetTime(), 5)
                timer = C_Timer.NewTimer(10, function()
                    self:SetGlowCastCooldown(GetTime(), 5)
                end)
            end

            if self.outerElapsed >= 10 then
                self.outerElapsed = 0
                self:SetOuterCooldown(GetTime(), 7)
            end

            if self.innerElapsed >= 10 then
                self.innerElapsed = 0
                self:SetInnerCooldown(GetTime(), 10)
            end
        end)

        previewButton:SetScript("OnHide", function(self)
            if timer then
                timer:Cancel()
                timer = nil
            end
        end)

        previewButton:SetScript("OnShow", function(self)
            self.glowBuffElapsed = 0
            self.outerElapsed = 0
            self.innerElapsed = 0
            self:SetGlowBuffCooldown(GetTime(), 5)
            self:SetGlowCastCooldown()
            timer = C_Timer.NewTimer(10, function()
                self:SetGlowCastCooldown(GetTime(), 5)
            end)
            self:SetOuterCooldown(GetTime(), 7)
            self:SetInnerCooldown(GetTime(), 10)
        end)
    end

    previewButton:SetSize(quickCastTable["size"])
    previewButton:SetNamePosition(quickCastTable["namePosition"])
    previewButton:SetColor(quickCastTable["glowBuffsColor"],  quickCastTable["glowCastsColor"], quickCastTable["outerColor"], quickCastTable["innerColor"])
    previewButton:Show()

    P:Size(previewFrame, 100+quickCastTable["size"], 100+quickCastTable["size"])

    for i, p in pairs(previewButtons) do
        if quickCastTable["enabled"] and i <= quickCastTable["num"] then
            p:Show()
        else
            p:Hide()
        end
    end
end

local function CreatePreviewFrame()
    previewFrame = Cell:CreateFrame(nil, qcPane, 130, 130)
    previewFrame:SetPoint("TOPLEFT", CellOptionsFrame, "TOPRIGHT", 5, -80)
    previewFrame:Show()

    previewPane = Cell:CreateTitledPane(previewFrame, L["Preview"], 130, 130)
    previewPane:SetPoint("TOPLEFT", 5, -5)
    previewPane:SetPoint("BOTTOMRIGHT", -5, 5)

    -- tips
    local tips = Cell:CreateTipsButton(previewPane, 17, {"TOPLEFT", previewPane, "TOPRIGHT", 10, 0},
        L["Quick Cast"],
        {"|cffffb5c5"..L["Left-Click"]..":", L["cast Outer spell"]},
        {"|cffffb5c5"..L["Right-Click"]..":", L["cast Inner spell"]},
        {"|cffffb5c5Shift+"..L["Left-Drag"]..":", L["set unit"]},
        {"|cffffb5c5Shift+"..L["Right-Click"]..":", L["clear unit"]},
        {"|cffffb5c5Alt+"..L["Left-Drag"]..":", L["move"]}
    )
end

-- ----------------------------------------------------------------------- --
--                        outer / inner spell button                       --
-- ----------------------------------------------------------------------- --
local function CreateSpellButton(parent, func)
    local b = Cell:CreateButton(parent, " ", "accent-hover", {195, 20})
    b:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\create", {16, 16}, {"LEFT", 2, 0})
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    b:GetFontString():SetJustifyH("LEFT")

    b:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            local popup = Cell:CreatePopupEditBox(qcPane, function(text)
                local spellId = tonumber(text)
                local spellName, spellIcon = F:GetSpellNameAndIcon(spellId)
                if spellId and spellName then
                    b.id = spellId
                    b.icon = spellIcon
                    b:SetText(spellName)
                    b.tex:SetTexture(spellIcon)
                    b.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                    func(spellId)
                    Cell:Fire("UpdateQuickCast")
                else
                    F:Print(L["Invalid spell id."])
                end
            end)
            popup:ClearAllPoints()
            popup:SetAllPoints(b)
            popup:ShowEditBox("")
        else
            b.id = nil
            b.icon = nil
            b:SetText("")
            b.tex:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\create")
            b.tex:SetTexCoord(0, 1, 0, 1)
            func(0)
            Cell:Fire("UpdateQuickCast")
        end
    end)

    b:HookScript("OnEnter", function(self)
        if self.id and self.icon then
            CellSpellTooltip:SetOwner(self, "ANCHOR_NONE")
            CellSpellTooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 2)
            CellSpellTooltip:SetSpellByID(self.id, self.icon)
            CellSpellTooltip:Show()
        end
    end)

    b:HookScript("OnLeave", function(self)
        CellSpellTooltip:Hide()
    end)

    return b
end

-- ----------------------------------------------------------------------- --
--                                  outer                                  --
-- ----------------------------------------------------------------------- --
local function CreateOuterPane()
    local qcOuterPane = Cell:CreateTitledPane(qcPane, L["Outer Buff"], 205, 80)
    qcOuterPane:SetPoint("TOPLEFT", 0, -250)

    local tip = qcOuterPane:CreateTexture(nil, "ARTWORK")
    tip:SetPoint("BOTTOMRIGHT", qcOuterPane.line, "TOPRIGHT", 0, P:Scale(2))
    tip:SetSize(16, 16)
    tip:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\left-click")

    qcOuterCP = Cell:CreateColorPicker(qcOuterPane, L["Color"], false, nil, function(r, g, b)
        quickCastTable["outerColor"][1] = r
        quickCastTable["outerColor"][2] = g
        quickCastTable["outerColor"][3] = b
        UpdatePreview()
        Cell:Fire("UpdateQuickCast")
    end)
    qcOuterCP:SetPoint("TOPLEFT", 5, -27)

    -- spell ------------------------------------------------------------------------
    qcOuterBtn = CreateSpellButton(qcOuterPane, function(spellId)
        quickCastTable["outerBuff"] = spellId
    end)
    qcOuterBtn:SetPoint("TOPLEFT", qcOuterCP, "BOTTOMLEFT", 0, -10)
end

-- ----------------------------------------------------------------------- --
--                                  inner                                  --
-- ----------------------------------------------------------------------- --
local function CreateInnerPane()
    local qcInnerPane = Cell:CreateTitledPane(qcPane, L["Inner Buff"], 205, 80)
    qcInnerPane:SetPoint("TOPLEFT", 217, -250)

    local tip = qcInnerPane:CreateTexture(nil, "ARTWORK")
    tip:SetPoint("BOTTOMRIGHT", qcInnerPane.line, "TOPRIGHT", 0, P:Scale(2))
    tip:SetSize(16, 16)
    tip:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\right-click")

    qcInnerCP = Cell:CreateColorPicker(qcInnerPane, L["Color"], false, nil, function(r, g, b)
        quickCastTable["innerColor"][1] = r
        quickCastTable["innerColor"][2] = g
        quickCastTable["innerColor"][3] = b
        UpdatePreview()
        Cell:Fire("UpdateQuickCast")
    end)
    qcInnerCP:SetPoint("TOPLEFT", 5, -27)

    -- spell ------------------------------------------------------------------------
    qcInnerBtn = CreateSpellButton(qcInnerPane, function(spellId)
        quickCastTable["innerBuff"] = spellId
    end)
    qcInnerBtn:SetPoint("TOPLEFT", qcInnerCP, "BOTTOMLEFT", 0, -10)
end

-- ----------------------------------------------------------------------- --
--                             glow list shared                            --
-- ----------------------------------------------------------------------- --
local BUTTONS_PER_ROW = 9
local BUTTONS_SPACING = 2
local BUTTONS_MAX = 27

local function LoadGlowList(parent, buttons, addBtn, anchorTo, t, separator)
    for i, id in pairs(t) do
        if not buttons[i] then
            buttons[i] = Cell:CreateButton(parent, nil, "accent-hover", {20, 20})
            buttons[i]:RegisterForClicks("RightButtonUp")

            buttons[i]:SetTexture(134400, {16, 16}, {"CENTER", 0, 0})
            buttons[i].tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)

            if separator then
                buttons[i].duration = buttons[i]:CreateFontString(nil, "OVERLAY")
                buttons[i].duration:SetFont(GameFontNormal:GetFont(), 12, "OUTLINE")
                buttons[i].duration:SetTextColor(1, 1, 1, 1)
                buttons[i].duration:SetShadowColor(0, 0, 0, 0)
                buttons[i].duration:SetShadowOffset(0, 0)
                buttons[i].duration:SetJustifyH("CENTER")
                buttons[i].duration:SetPoint("BOTTOMRIGHT")
            end

            buttons[i]:HookScript("OnEnter", function(self)
                if self.id and self.icon then
                    CellSpellTooltip:SetOwner(self, "ANCHOR_NONE")
                    CellSpellTooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 2)
                    CellSpellTooltip:SetSpellByID(self.id, self.icon)
                    CellSpellTooltip:Show()
                end
            end)

            buttons[i]:HookScript("OnLeave", function(self)
                CellSpellTooltip:Hide()
            end)

            buttons[i]:SetScript("OnClick", function()
                tremove(t, i)
                LoadGlowList(parent, buttons, addBtn, anchorTo, t, separator)
                Cell:Fire("UpdateQuickCast")
            end)
        end

        if separator then
            id, duration = strsplit(separator, id)
            buttons[i].duration:SetText(duration)
        end

        local name, icon = F:GetSpellNameAndIcon(id)
        if not name then icon = 134400 end
        buttons[i].id = id
        buttons[i].icon = icon

        buttons[i].tex:SetTexture(icon)

        buttons[i]:ClearAllPoints()
        if i == 1 then
            buttons[i]:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT", 0, -10)
        elseif (i - 1) % BUTTONS_PER_ROW == 0 then
            buttons[i]:SetPoint("TOPLEFT", buttons[i-BUTTONS_PER_ROW], "BOTTOMLEFT", 0, -BUTTONS_SPACING)
        else
            buttons[i]:SetPoint("TOPLEFT", buttons[i-1], "TOPRIGHT", BUTTONS_SPACING, 0)
        end

        buttons[i]:Show()
    end

    local n = #t

    -- hide
    for i = n+1, #buttons do
        buttons[i]:Hide()
    end

    -- update add button
    if n == BUTTONS_MAX then --max
        addBtn:Hide()
    else
        addBtn:ClearAllPoints()
        if n == 0 then
            addBtn:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT", 0, -10)
        elseif n % BUTTONS_PER_ROW == 0 then
            addBtn:SetPoint("TOPLEFT", buttons[n-BUTTONS_PER_ROW+1], "BOTTOMLEFT", 0, -BUTTONS_SPACING)
        else
            addBtn:SetPoint("TOPLEFT", buttons[n], "TOPRIGHT", BUTTONS_SPACING, 0)
        end
        addBtn:Show()
    end
end

-- ----------------------------------------------------------------------- --
--                                glow buffs                               --
-- ----------------------------------------------------------------------- --
local function CreateGlowBuffsPane()
    qcGlowBuffsPane = Cell:CreateTitledPane(qcPane, L["Glow Buffs"], 205, 130)
    qcGlowBuffsPane:SetPoint("TOPLEFT", 0, -355)

    Cell:CreateTipsButton(qcGlowBuffsPane, 17, "BOTTOMRIGHT", "UNIT_AURA")

    -- color ------------------------------------------------------------------------
    qcGlowBuffsCP = Cell:CreateColorPicker(qcGlowBuffsPane, L["Color"], false, nil, function(r, g, b)
        quickCastTable["glowBuffsColor"][1] = r
        quickCastTable["glowBuffsColor"][2] = g
        quickCastTable["glowBuffsColor"][3] = b
        UpdatePreview()
        Cell:Fire("UpdateQuickCast")
    end)
    qcGlowBuffsCP:SetPoint("TOPLEFT", 5, -27)

    -- buffs ------------------------------------------------------------------------
    qcGlowBuffsAddBtn = Cell:CreateButton(qcGlowBuffsPane, nil, "accent-hover", {20, 20})
    qcGlowBuffsAddBtn:SetPoint("TOPLEFT", qcGlowBuffsCP, "BOTTOMLEFT", 0, -10)
    qcGlowBuffsAddBtn:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\create", {16, 16}, {"CENTER", 0, 0})
    qcGlowBuffsAddBtn:SetScript("OnClick", function()
        local popup = Cell:CreatePopupEditBox(qcPane, function(text)
            local spellId = tonumber(text)
            local spellName = F:GetSpellNameAndIcon(spellId)
            if spellId and spellName then
                tinsert(quickCastTable["glowBuffs"], spellId)
                LoadGlowList(qcGlowBuffsPane, qcGlowBuffsButtons, qcGlowBuffsAddBtn, qcGlowBuffsCP, quickCastTable["glowBuffs"])
                Cell:Fire("UpdateQuickCast")
            else
                F:Print(L["Invalid spell id."])
            end
        end)
        popup:ClearAllPoints()
        popup:SetPoint("LEFT", qcGlowBuffsPane, 5, 0)
        popup:SetPoint("RIGHT", qcGlowBuffsPane, -4, 0)
        popup:SetPoint("TOP", qcGlowBuffsAddBtn)
        popup:ShowEditBox("")
    end)
end

-- ----------------------------------------------------------------------- --
--                                glow casts                               --
-- ----------------------------------------------------------------------- --
local function CreateGlowCastsPane()
    qcGlowCastsPane = Cell:CreateTitledPane(qcPane, L["Glow Casts"], 205, 130)
    qcGlowCastsPane:SetPoint("TOPLEFT", 217, -355)

    Cell:CreateTipsButton(qcGlowCastsPane, 17, "BOTTOMRIGHT", "UNIT_SPELLCAST_SUCCEEDED")

    -- color ------------------------------------------------------------------------
    qcGlowCastsCP = Cell:CreateColorPicker(qcGlowCastsPane, L["Color"], false, nil, function(r, g, b)
        quickCastTable["glowCastsColor"][1] = r
        quickCastTable["glowCastsColor"][2] = g
        quickCastTable["glowCastsColor"][3] = b
        UpdatePreview()
        Cell:Fire("UpdateQuickCast")
    end)
    qcGlowCastsCP:SetPoint("TOPLEFT", 5, -27)

    -- editbox
    local popup = Cell:CreateDualPopupEditBox(qcGlowCastsPane, "ID", L["Duration"], true)
    popup.left:HookScript("OnTextChanged", function(self)
        local spellId = tonumber(self:GetText())
        if not spellId then
            CellSpellTooltip:Hide()
            return
        end

        local name, icon = F:GetSpellNameAndIcon(spellId)
        if not name then
            CellSpellTooltip:Hide()
            return
        end

        CellSpellTooltip:SetOwner(self, "ANCHOR_NONE")
        CellSpellTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -1)
        CellSpellTooltip:SetSpellByID(spellId, icon)
        CellSpellTooltip:Show()
    end)
    popup:HookScript("OnHide", function()
        CellSpellTooltip:Hide()
    end)

    -- casts ------------------------------------------------------------------------
    qcGlowCastsAddBtn = Cell:CreateButton(qcGlowCastsPane, nil, "accent-hover", {20, 20})
    qcGlowCastsAddBtn:SetPoint("TOPLEFT", qcGlowCastsCP, "BOTTOMLEFT", 0, -10)
    qcGlowCastsAddBtn:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\create", {16, 16}, {"CENTER", 0, 0})
    qcGlowCastsAddBtn:SetScript("OnClick", function()
        local popup = Cell:CreateDualPopupEditBox(qcGlowCastsPane, "ID", L["Duration"], true, function(spellId, duration)
            local spellName = F:GetSpellNameAndIcon(spellId)
            if spellId and spellName and duration then
                tinsert(quickCastTable["glowCasts"], spellId..":"..duration)
                LoadGlowList(qcGlowCastsPane, qcGlowCastsButtons, qcGlowCastsAddBtn, qcGlowCastsCP, quickCastTable["glowCasts"], ":")
                Cell:Fire("UpdateQuickCast")
            else
                F:Print(L["Invalid"])
            end
        end)
        popup.left:SetWidth(P:Scale(90))
        popup:SetPoint("LEFT", qcGlowCastsPane, 5, 0)
        popup:SetPoint("RIGHT", qcGlowCastsPane, -4, 0)
        popup:SetPoint("TOP", qcGlowCastsAddBtn)
        popup:ShowEditBox()
    end)
end

-- ----------------------------------------------------------------------- --
--                                   load                                  --
-- ----------------------------------------------------------------------- --
local function LoadSpellButton(b, value)
    b.id = nil
    b.icon = nil
    if value == 0 then
        b:SetText("")
        b.tex:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\create")
        b.tex:SetTexCoord(0, 1, 0, 1)
    else
        local name, icon = F:GetSpellNameAndIcon(value)
        if name and icon then
            b:SetText(name)
            b.tex:SetTexture(icon)
            b.id = value
            b.icon = icon
        else
            b:SetText("|cffff2222"..L["Invalid"])
            b.tex:SetTexture(134400)
        end
        b.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end
end

local function LoadDB()
    qcEnabledCB:SetChecked(quickCastTable["enabled"])
    qcNameDD:SetSelectedValue(quickCastTable["namePosition"])
    qcButtonsSlider:SetValue(quickCastTable["num"])
    qcOrientationDD:SetSelectedValue(quickCastTable["orientation"])
    if strfind(quickCastTable["orientation"], "top") then
        qcLinesSlider:SetLabel(L["Rows"])
    else
        qcLinesSlider:SetLabel(L["Columns"])
    end
    qcLinesSlider:SetValue(quickCastTable["lines"])
    qcSizeSlider:SetValue(quickCastTable["size"])
    qcSpacingXSlider:SetValue(quickCastTable["spacingX"])
    qcSpacingYSlider:SetValue(quickCastTable["spacingY"])

    UpdatePreview()

    -- glow
    qcGlowBuffsCP:SetColor(unpack(quickCastTable["glowBuffsColor"]))
    LoadGlowList(qcGlowBuffsPane, qcGlowBuffsButtons, qcGlowBuffsAddBtn, qcGlowBuffsCP, quickCastTable["glowBuffs"])
    qcGlowCastsCP:SetColor(unpack(quickCastTable["glowCastsColor"]))
    LoadGlowList(qcGlowCastsPane, qcGlowCastsButtons, qcGlowCastsAddBtn, qcGlowCastsCP, quickCastTable["glowCasts"], ":")

    -- outer
    qcOuterCP:SetColor(unpack(quickCastTable["outerColor"]))
    LoadSpellButton(qcOuterBtn, quickCastTable["outerBuff"])

    -- inner
    qcInnerCP:SetColor(unpack(quickCastTable["innerColor"]))
    LoadSpellButton(qcInnerBtn, quickCastTable["innerBuff"])

    UpdateWidgets()
end

-- ----------------------------------------------------------------------- --
--                                   show                                  --
-- ----------------------------------------------------------------------- --
local init
local function ShowUtilitySettings(which)
    if which == "quickCast" then
        if not init then
            init = true
            CreateQCPane()
            CreatePreviewFrame()
            CreateOuterPane()
            CreateInnerPane()
            CreateGlowBuffsPane()
            CreateGlowCastsPane()

            F:ApplyCombatProtectionToFrame(qcPane, -4, 4, 4, -4)

            qcPane:SetScript("OnShow", function()
                if quickCastTable["enabled"] then
                    for i, p in pairs(previewButtons) do
                        if quickCastTable and i <= quickCastTable["num"] then
                            p.fadeOut:Stop()
                            p:FadeIn()
                        end
                    end
                end
            end)

            qcPane:SetScript("OnHide", function()
                for i, p in pairs(previewButtons) do
                    if quickCastTable and i <= quickCastTable["num"] then
                        p.fadeIn:Stop()
                        p:FadeOut()
                    end
                end
            end)
        end

        LoadDB()
        qcPane:Show()

    elseif init then
        qcPane:Hide()
    end
end
Cell:RegisterCallback("ShowUtilitySettings", "QuickCast_ShowUtilitySettings", ShowUtilitySettings)




















-- ----------------------------------------------------------------------- --
--                             quick cast frame                            --
-- ----------------------------------------------------------------------- --
local quickCastButtons
local glowBuffs, glowCasts = {}, {}
local outerBuff, innerBuff
local borderSize, glowBuffsColor, glowCastsColor

local quickCastFrame = CreateFrame("Frame", "CellQuickCastFrame", Cell.frames.mainFrame, "SecureHandlerAttributeTemplate")
PixelUtil.SetPoint(quickCastFrame, "TOPLEFT", UIParent, "CENTER", -1, -1)
quickCastFrame:SetSize(16, 16)
quickCastFrame:SetClampedToScreen(true)
quickCastFrame:SetMovable(true)
quickCastFrame:Hide()

-- quickCastFrame:SetScript("OnEvent", function(self, event, ...)
--     self[event](self, ...)
-- end)

-- function quickCastFrame:PLAYER_ENTERING_WORLD()
--     quickCastFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
--     quickCastFrame:GROUP_ROSTER_UPDATE()
-- end

-- function quickCastFrame:GROUP_ROSTER_UPDATE()
--     if IsInGroup() then
--         quickCastFrame:Show()
--     else
--         quickCastFrame:Hide()
--     end
-- end

-- ----------------------------------------------------------------------- --
--                        target frame: drag and set                       --
-- ----------------------------------------------------------------------- --
local targetFrame = Cell:CreateFrame(nil, quickCastFrame, 50, 20)
targetFrame.label = targetFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
targetFrame.label:SetPoint("CENTER")
targetFrame:EnableMouse(false)
targetFrame:SetFrameStrata("TOOLTIP")

function targetFrame:StartMoving()
    targetFrame:Show()
    local scale = P:GetEffectiveScale()
    targetFrame:SetScript("OnUpdate", function()
        local x, y = GetCursorPosition()
        targetFrame:SetPoint("BOTTOMLEFT", UIParent, x/scale, y/scale)
        targetFrame:SetWidth(targetFrame.label:GetWidth() + 10)
    end)
end

function targetFrame:StopMoving()
    targetFrame:Hide()
    targetFrame:ClearAllPoints()
end

local function RegisterDrag(frame)
    frame:RegisterForDrag("LeftButton")

    frame:SetScript("OnDragStart", function()
        if IsShiftKeyDown() then --! set unit
            targetFrame.isMoving = true
            targetFrame:StartMoving()
            LCG.PixelGlow_Start(b, Cell:GetAccentColorTable(), 9, 0.25, 8, 2) -- color, N, frequency, length, thickness

            targetFrame.label:SetText(L["Unit"])

        elseif IsAltKeyDown() then --! move
            quickCastFrame:StartMoving()
            quickCastFrame:SetUserPlaced(false)
        end
    end)

    frame:SetScript("OnDragStop", function()
        quickCastFrame:StopMovingOrSizing()
        if not InCombatLockdown() then P:PixelPerfectPoint(quickCastFrame) end
        P:SavePosition(quickCastFrame, quickCastTable["position"])

        --! target
        if targetFrame.isMoving then
            targetFrame.isMoving = false
            targetFrame:StopMoving()

            if InCombatLockdown() then
                F:Print(L["You can't do that while in combat."])
                return
            end

            local f = F:GetMouseFoci()
            if f and f.states and f.states.displayedUnit and F:UnitInGroup(f.states.displayedUnit) then
                quickCastTable["units"][frame.index] = f.states.displayedUnit
                frame:SetUnit(f.states.displayedUnit, outerBuff, innerBuff)
            end
        end
    end)
end

-- ----------------------------------------------------------------------- --
--                            quick cast events                            --
-- ----------------------------------------------------------------------- --
local function QuickCast_UpdateAuras(self)
    if not self.unit then return end

    local glowBuffFound, outerBuffFound, innerBuffFound

    AuraUtil.ForEachAura(self.unit, "HELPFUL", nil, function(name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId)
        if glowBuffs[name] then
            glowBuffFound = true
            self:SetGlowBuffCooldown(expirationTime - duration, duration)
        end

        if source == "player" then
            if name == outerBuff then
                outerBuffFound = true
                self:SetOuterCooldown(expirationTime - duration, duration)
            end

            if name == innerBuff then
                innerBuffFound = true
                self:SetInnerCooldown(expirationTime - duration, duration)
            end
        end
    end)

    if not glowBuffFound then self:SetGlowBuffCooldown() end
    if not outerBuffFound then self:SetOuterCooldown() end
    if not innerBuffFound then self:SetInnerCooldown() end
end

local function QuickCast_UpdateCasts(self, spellId)
    if glowCasts[spellId] then
        self:SetGlowCastCooldown(GetTime(), glowCasts[spellId])
    end
end

local function QuickCast_UpdateInRange(self, ir)
    if not self.unit then return end

    if ir then
        A:FrameFadeIn(self, 0.25, self:GetAlpha(), 1)
    else
        A:FrameFadeOut(self, 0.25, self:GetAlpha(), 0.25)
    end
end

local function QuickCast_UpdateStatus(self)
    if UnitIsDeadOrGhost(self.unit) or not UnitIsConnected(self.unit) then
        self.invalidTex:Show()
    else
        self.invalidTex:Hide()
    end
end

local function QuickCast_UpdateName(self)
    if not self.unit then return end

    local name = F:GetNickname(UnitName(self.unit), F:UnitFullName(self.unit))

    if CellDB["general"]["translit"] then
        name = LibTranslit:Transliterate(name)
    end

    if string.len(name) == string.utf8len(name) then -- en
        self.nameText:SetText(string.utf8sub(name, 1, 3))
    else
        self.nameText:SetText(string.utf8sub(name, 1, 1))
    end
end

-- FIXME: sync others name
Cell:RegisterCallback("UpdateNicknames", "QuickCast_UpdateNicknames", function()
    if quickCastButtons then
        C_Timer.After(1, function()
            for _, b in pairs(quickCastButtons) do
                QuickCast_UpdateName(b)
            end
        end)
    end
end)

Cell:RegisterCallback("TranslitNames", "QuickCast_TranslitNames", function()
    if quickCastButtons then
        for _, b in pairs(quickCastButtons) do
            QuickCast_UpdateName(b)
        end
    end
end)

local function QuickCast_OnEvent(self, event, unit, arg1, arg2)
    if unit and self.unit == unit then
        if event == "UNIT_AURA" then
            QuickCast_UpdateAuras(self)
        elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
            QuickCast_UpdateCasts(self, arg2)
        elseif event == "UNIT_IN_RANGE_UPDATE" then
            QuickCast_UpdateInRange(self, arg1)
        elseif event == "UNIT_FLAGS" then
            QuickCast_UpdateStatus(self)
        elseif event == "UNIT_NAME_UPDATE" then
            QuickCast_UpdateName(self)
        end
    else
        if event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
            self:CheckUnit()
        end
    end
end

local function QuickCast_OnShow(self)
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    -- self:RegisterEvent("PLAYER_ENTERING_WORLD")
    -- update all now
    self:CheckUnit()
end

local function QuickCast_OnHide(self)
    self:UnregisterAllEvents()
end

-- ----------------------------------------------------------------------- --
--                            create quick cast                            --
-- ----------------------------------------------------------------------- --
local function CreatePreviewButton(b)
    local p = CreateFrame("Frame", nil, CellMainFrame, "BackdropTemplate")
    p:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
    p:SetBackdropColor(0.5, 0.5, 0.5, 0.7)
    p:SetAllPoints(b)
    p:SetFrameStrata("LOW")
    p:Hide()
    tinsert(previewButtons, p)

    p.s = p:CreateFontString(nil, "OVERLAY", "CELL_FONT_CLASS_TITLE")
    p.s:SetPoint("CENTER")
    p.s:SetText(#previewButtons)

    A:CreateFadeIn(p, 0, 1, 0.5)
    A:CreateFadeOut(p, 1, 0, 0.5)

    p:RegisterForDrag("LeftButton")
    p:EnableMouse(true)

    p:SetScript("OnDragStart", function()
        quickCastFrame:StartMoving()
        quickCastFrame:SetUserPlaced(false)
    end)

    p:SetScript("OnDragStop", function()
        quickCastFrame:StopMovingOrSizing()
        if not InCombatLockdown() then P:PixelPerfectPoint(quickCastFrame) end
        P:SavePosition(quickCastFrame, quickCastTable["position"])
    end)
end

CreateQuickCastButton = function(parent, name, isPreview)
    local b
    if isPreview then
        b = CreateFrame("Button", name, parent, "BackdropTemplate")
    else
        b = CreateFrame("Button", name, parent, "BackdropTemplate,SecureUnitButtonTemplate")
        CreatePreviewButton(b)
    end
    b:RegisterForClicks("AnyDown")
    b:Hide()
    b._r, b._g, b._b = 0, 0, 0

    -- name -------------------------------------------------------------------------
    local nameText = b:CreateFontString(nil, "OVERLAY")
    b.nameText = nameText
    nameText:Hide()
    nameText:SetFont(GameFontNormal:GetFont(), 13, "Outline")

    -- invalid ----------------------------------------------------------------------
    local invalidTex = b:CreateTexture(nil, "ARTWORK")
    b.invalidTex = invalidTex
    invalidTex:Hide()
    invalidTex:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\close")
    invalidTex:SetVertexColor(0.7, 0.7, 0.7, 1)

    -- glow buff --------------------------------------------------------------------
    local glowBuffCD = CreateFrame("Frame", name.."GlowBuffCD", b)
    b.glowBuffCD = glowBuffCD
    glowBuffCD:Hide()
    glowBuffCD:SetScript("OnShow", function()
        LCG.ButtonGlow_Start(glowBuffCD, glowBuffsColor)
    end)
    glowBuffCD:SetScript("OnHide", function()
        LCG.ButtonGlow_Stop(glowBuffCD)
    end)

    -- glow cast --------------------------------------------------------------------
    local glowCastCD = CreateFrame("Frame", name.."GlowCastCD", b)
    b.glowCastCD = glowCastCD
    glowCastCD:Hide()
    glowCastCD:SetScript("OnShow", function()
        LCG.ButtonGlow_Start(glowCastCD, glowCastsColor)
    end)
    glowCastCD:SetScript("OnHide", function()
        LCG.ButtonGlow_Stop(glowCastCD)
    end)

    -- outer ------------------------------------------------------------------------
    local outerCD = CreateFrame("Cooldown", name.."OuterCD", b, "BackdropTemplate,CooldownFrameTemplate")
    b.outerCD = outerCD
    outerCD:SetFrameLevel(b:GetFrameLevel() + 1)
    outerCD:SetSwipeTexture("Interface\\Buttons\\WHITE8x8")
    outerCD:SetDrawEdge(true)
    -- outerCD:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
    -- outerCD:SetBackdropColor(0, 0, 0, 0.5)
    outerCD.noCooldownCount = true -- disable omnicc
    outerCD:SetHideCountdownNumbers(true)
    outerCD:Hide()
    outerCD:SetScript("OnCooldownDone", function()
        outerCD:Hide()
    end)
    outerCD:SetScript("OnShow", function()
        b:Update()
    end)
    outerCD:SetScript("OnHide", function()
        b:Update()
    end)

    -- inner ------------------------------------------------------------------------
    local innerCD = CreateFrame("Cooldown", name.."InnerCD", b, "BackdropTemplate,CooldownFrameTemplate")
    b.innerCD = innerCD
    innerCD:SetFrameLevel(b:GetFrameLevel() + 2)
    innerCD:SetSwipeTexture("Interface\\Buttons\\WHITE8x8")
    innerCD:SetDrawEdge(true)
    innerCD:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
    innerCD:SetBackdropColor(0, 0, 0, 0.4)
    innerCD.noCooldownCount = true -- disable omnicc
    innerCD:SetHideCountdownNumbers(true)
    innerCD:Hide()
    innerCD:SetScript("OnCooldownDone", function()
        innerCD:Hide()
    end)

    -- cooldowns --------------------------------------------------------------------
    function b:SetGlowBuffCooldown(start, duration)
        if start and duration then
            glowBuffCD:SetScript("OnUpdate", function(self, elapsed)
                self.elapsed = (self.elapsed or 0) + elapsed
                if self.elapsed >= 0.1 then
                    local remain = duration - (GetTime() - start)
                    if remain <= 0 then
                        glowBuffCD:SetAlpha(0.1)
                        glowBuffCD:Hide()
                    elseif remain >= duration then
                        glowBuffCD:SetAlpha(1)
                    else
                        glowBuffCD:SetAlpha(remain / duration * 0.9 + 0.1)
                    end
                    self.elapsed = 0
                end
            end)
            glowBuffCD:Show()
        else
            glowBuffCD:SetScript("OnUpdate", nil)
            glowBuffCD:Hide()
        end
    end

    function b:SetGlowCastCooldown(start, duration)
        if start and duration then
            glowCastCD:SetScript("OnUpdate", function(self, elapsed)
                self.elapsed = (self.elapsed or 0) + elapsed
                if self.elapsed >= 0.1 then
                    local remain = duration - (GetTime() - start)
                    if remain <= 0 then
                        glowCastCD:SetAlpha(0.1)
                        glowCastCD:Hide()
                    elseif remain >= duration then
                        glowCastCD:SetAlpha(1)
                    else
                        glowCastCD:SetAlpha(remain / duration * 0.9 + 0.1)
                    end
                    self.elapsed = 0
                end
            end)
            glowCastCD:Show()
        else
            glowCastCD:SetScript("OnUpdate", nil)
            glowCastCD:Hide()
        end
    end

    function b:Update()
        P:ClearPoints(innerCD)
        if outerCD:IsShown() then
            P:Point(innerCD, "CENTER")
        else
            P:Point(innerCD, "TOPLEFT", borderSize+1, -borderSize-1)
            P:Point(innerCD, "BOTTOMRIGHT", -borderSize-1, borderSize+1)
        end
    end

    function b:SetOuterCooldown(start, duration)
        if start and duration then
            outerCD:Show()
            outerCD:SetCooldown(start, duration)
        else
            outerCD:Hide()
        end
    end

    function b:SetInnerCooldown(start, duration)
        if start and duration then
            b:Update()
            innerCD:Show()
            innerCD:SetCooldown(start, duration)
        else
            innerCD:Hide()
        end
    end

    -- setup ------------------------------------------------------------------------
    b._SetSize = b.SetSize
    function b:SetSize(size)
        b:_SetSize(P:Scale(size), P:Scale(size))

        borderSize = floor(size/8)
        b:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = P:Scale(borderSize)})
        b:SetBackdropColor(b._r*0.2, b._g*0.2, b._b*0.2, 0.7)
        b:SetBackdropBorderColor(b._r, b._g, b._b, 0.9)

        P:ClearPoints(invalidTex)
        P:Point(invalidTex, "TOPLEFT", borderSize, -borderSize)
        P:Point(invalidTex, "BOTTOMRIGHT", -borderSize, borderSize)

        P:ClearPoints(outerCD)
        outerCD:SetPoint("TOPLEFT", P:Scale(borderSize)+P:Scale(1), -P:Scale(borderSize)-P:Scale(1))
        outerCD:SetPoint("BOTTOMRIGHT", -P:Scale(borderSize)-P:Scale(1), P:Scale(borderSize)+P:Scale(1))
        P:Size(innerCD, floor(size-borderSize*4-2), floor(size-borderSize*4-2))

        P:ClearPoints(glowBuffCD)
        P:Point(glowBuffCD, "TOPLEFT", -borderSize, borderSize)
        P:Point(glowBuffCD, "BOTTOMRIGHT", borderSize, -borderSize)

        P:ClearPoints(glowCastCD)
        P:Point(glowCastCD, "TOPLEFT", -borderSize, borderSize)
        P:Point(glowCastCD, "BOTTOMRIGHT", borderSize, -borderSize)

        nameText:SetFont(GameFontNormal:GetFont(), max(13, floor(size/2)), "Outline")
        nameText:SetShadowColor(0, 0, 0)
        nameText:SetShadowOffset(0, 0)

        b:Update()
    end

    function b:SetNamePosition(position)
        nameText:Show()
        nameText:ClearAllPoints()

        if position == "LEFT" then
            nameText:SetPoint("RIGHT", b, "LEFT", -3, 0)
        elseif position == "RIGHT" then
            nameText:SetPoint("LEFT", b, "RIGHT", 3, 0)
        elseif position == "TOP" then
            nameText:SetPoint("BOTTOM", b, "TOP", 0, 3)
        elseif position == "BOTTOM" then
            nameText:SetPoint("TOP", b, "BOTTOM", 0, -3)
        else
            nameText:Hide()
        end
    end

    function b:SetColor(_glowBuffsColor, _glowCastsColor, _outerColor, _innerColor)
        if glowBuffCD:IsShown() then
            LCG.ButtonGlow_Start(glowBuffCD, _glowBuffsColor)
        end
        if glowCastCD:IsShown() then
            LCG.ButtonGlow_Start(glowCastCD, _glowCastsColor)
        end
        outerCD:SetSwipeColor(unpack(_outerColor))
        innerCD:SetSwipeColor(unpack(_innerColor))
    end

    --! NOTE: GROUP_ROSTER_UPDATE or PLAYER_LOGIN or MANUALLY CALLED
    function b:CheckUnit()
        local unit = b.unit

        if unit and UnitExists(unit) then
            b:SetAlpha(1)

            -- local _r, _g, _b
            -- if UnitIsConnected(unit) then
            --     local class = UnitClassBase(unit)
            --     _r, _g, _b = F:GetClassColor(class)
            -- else
            --     _r, _g, _b = 0.4, 0.4, 0.4
            -- end

            local class = UnitClassBase(unit)
            local _r, _g, _b = F:GetClassColor(class)
            b._r, b._g, b._b = _r, _g, _b
            b:SetBackdropColor(_r*0.2, _g*0.2, _b*0.2, 0.7)
            b:SetBackdropBorderColor(_r, _g, _b, 0.9)
            nameText:SetTextColor(_r, _g, _b)

            --! update name
            b:RegisterEvent("UNIT_NAME_UPDATE")
            QuickCast_UpdateName(b)

            --! check range now
            b:RegisterUnitEvent("UNIT_IN_RANGE_UPDATE", unit)
            QuickCast_UpdateInRange(b, UnitInRange(unit))

            --! check buffs now
            b:RegisterEvent("UNIT_AURA")
            QuickCast_UpdateAuras(b)

            --! casts glow
            b:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
            b:SetGlowCastCooldown()

            --! check dead / offline
            b:RegisterEvent("UNIT_FLAGS")
            QuickCast_UpdateStatus(b)
        else
            b:SetAlpha(0.4)
            b:SetBackdropColor(0, 0, 0, 0.7)
            b:SetBackdropBorderColor(0, 0, 0, 0.9)
            nameText:SetTextColor(0.7, 0.7, 0.7)
            nameText:SetText(unit)

            invalidTex:Hide()
            glowBuffCD:Hide()
            glowCastCD:Hide()
            outerCD:Hide()
            innerCD:Hide()
        end

        F:UpdateOmniCDPosition("Cell-QuickCast")
    end

    --! NOTE: PLAYER_LOGIN or MANUALLY CALLED
    function b:SetUnit(unit, leftCast, rightCast)
        F:Debug("[QuickCast] SetUnit:", unit, leftCast, rightCast)

        b.unit = unit

        if unit then
            b:SetAttribute("unit", unit)
            if leftCast then
                b:SetAttribute("type1", "macro")
                b:SetAttribute("macrotext1", "/cast [@"..unit..",nodead] "..leftCast)
            end
            if rightCast then
                b:SetAttribute("type2", "macro")
                b:SetAttribute("macrotext2", "/cast [@"..unit..",nodead] "..rightCast)
            end

            -- RegisterAttributeDriver(b, "state-visibility", "[@"..unit..",exists] show; hide")
        else
            b:SetAttribute("unit", nil)
            b:SetAttribute("type1", nil)
            b:SetAttribute("macrotext1", nil)
            b:SetAttribute("type2", nil)
            b:SetAttribute("macrotext2", nil)

            -- UnregisterAttributeDriver(b, "state-visibility")
            -- b:Hide()
        end

        b:CheckUnit()
    end

    --! shift right-click to clear unit
    -- NOTE: if unit and unit ~= "none" and not UnitExists(unit) then THESE CODE WILL NOT RUN
    -- b:SetAttribute("shift-type2", "clearunit")
    -- b:SetAttribute("_clearunit", function()
    --     if InCombatLockdown() then
    --         F:Print(L["You can't do that while in combat."])
    --         return
    --     end

    --     b.unit = nil
    --     b:CheckUnit()

    --     b:SetAttribute("unit", nil)
    --     b:SetAttribute("type1", nil)
    --     b:SetAttribute("spell1", nil)
    --     b:SetAttribute("type2", nil)
    --     b:SetAttribute("spell2", nil)

    --     quickCastTable["units"][b.index] = nil
    -- end)

    b:SetScript("PostClick", function(self, button, down)
        if button == "RightButton" and IsShiftKeyDown() then
            if InCombatLockdown() then
                F:Print(L["You can't do that while in combat."])
                return
            end

            b.unit = nil
            b:CheckUnit()

            b:SetAttribute("unit", nil)
            b:SetAttribute("type1", nil)
            b:SetAttribute("spell1", nil)
            b:SetAttribute("type2", nil)
            b:SetAttribute("spell2", nil)

            quickCastTable["units"][b.index] = nil
        end
    end)

    b:SetScript("OnShow", QuickCast_OnShow)
    b:SetScript("OnHide", QuickCast_OnHide)
    b:SetScript("OnEvent", QuickCast_OnEvent)

    return b
end

-- ----------------------------------------------------------------------- --
--                                callbacks                                --
-- ----------------------------------------------------------------------- --
local function UpdateQuickCast()
    if CellDB["quickCast"][Cell.vars.playerClass] and CellDB["quickCast"][Cell.vars.playerClass][Cell.vars.playerSpecID] then
        quickCastTable = CellDB["quickCast"][Cell.vars.playerClass][Cell.vars.playerSpecID]
    else
        quickCastTable = defaultQuickCastTable
    end

    -- prepare others
    borderSize = floor(quickCastTable["size"]/8)
    glowBuffsColor = quickCastTable["glowBuffsColor"]
    glowCastsColor = quickCastTable["glowCastsColor"]

    if quickCastTable["enabled"] then
        RegisterAttributeDriver(quickCastFrame, "state-visibility", "[@raid1,exists] show;[@party1,exists] show;hide")
        targetFrame:UpdatePixelPerfect()
        -- quickCastFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        -- quickCastFrame:RegisterEvent("GROUP_ROSTER_UPDATE")

        -- update parent size
        P:Size(quickCastFrame, quickCastTable["size"], quickCastTable["size"])
        -- if strfind(quickCastTable["orientation"], "top") then
        --     P:Size(quickCastFrame, quickCastTable["size"], quickCastTable["size"] * quickCastTable["num"] + quickCastTable["spacing"] * (quickCastTable["num"] - 1))
        -- else
        --     P:Size(quickCastFrame, quickCastTable["size"] * quickCastTable["num"] + quickCastTable["spacing"] * (quickCastTable["num"] - 1), quickCastTable["size"])
        -- end

        -- position
        P:LoadPosition(quickCastFrame, quickCastTable["position"])

        -- prepare buffs
        glowBuffs = F:ConvertSpellTable(quickCastTable["glowBuffs"], true)
        glowCasts = F:ConvertSpellDurationTable(quickCastTable["glowCasts"])
        outerBuff = F:GetSpellNameAndIcon(quickCastTable["outerBuff"])
        innerBuff = F:GetSpellNameAndIcon(quickCastTable["innerBuff"])

        -- create
        if not quickCastButtons then
            quickCastButtons = {}
            for i = 1, 6 do
                quickCastButtons[i] = CreateQuickCastButton(quickCastFrame, "CellQuickCastButton"..i)
                quickCastButtons[i].index = i -- for save
                RegisterDrag(quickCastButtons[i])
            end
        end

        -- show
        for i = 1, quickCastTable["num"] do
            quickCastButtons[i]:SetSize(quickCastTable["size"])
            quickCastButtons[i]:SetNamePosition(quickCastTable["namePosition"])
            quickCastButtons[i]:SetColor(quickCastTable["glowBuffsColor"], quickCastTable["glowCastsColor"], quickCastTable["outerColor"], quickCastTable["innerColor"])
            quickCastButtons[i]:SetUnit(quickCastTable["units"][i], outerBuff, innerBuff)
            quickCastButtons[i]:Show()

            P:ClearPoints(quickCastButtons[i])
            if quickCastTable["orientation"] == "left-to-right" then
                if i == 1 then
                    P:Point(quickCastButtons[i], "TOPLEFT")
                else
                    if quickCastTable["lines"] == 6 then
                        P:Point(quickCastButtons[i], "TOPLEFT", quickCastButtons[i-1], "TOPRIGHT", quickCastTable["spacingX"], 0)
                    else
                        if (i-1) % quickCastTable["lines"] == 0 then
                            P:Point(quickCastButtons[i], "TOPLEFT", quickCastButtons[i-quickCastTable["lines"]], "BOTTOMLEFT", 0, -quickCastTable["spacingY"])
                        else
                            P:Point(quickCastButtons[i], "TOPLEFT", quickCastButtons[i-1], "TOPRIGHT", quickCastTable["spacingX"], 0)
                        end
                    end
                end
            elseif quickCastTable["orientation"] == "right-to-left" then
                if i == 1 then
                    P:Point(quickCastButtons[i], "TOPRIGHT")
                else
                    if quickCastTable["lines"] == 6 then
                        P:Point(quickCastButtons[i], "TOPRIGHT", quickCastButtons[i-1], "TOPLEFT", -quickCastTable["spacingX"], 0)
                    else
                        if (i-1) % quickCastTable["lines"] == 0 then
                            P:Point(quickCastButtons[i], "TOPRIGHT", quickCastButtons[i-quickCastTable["lines"]], "BOTTOMRIGHT", 0, -quickCastTable["spacingY"])
                        else
                            P:Point(quickCastButtons[i], "TOPRIGHT", quickCastButtons[i-1], "TOPLEFT", -quickCastTable["spacingX"], 0)
                        end
                    end
                end
            elseif quickCastTable["orientation"] == "top-to-bottom" then
                if i == 1 then
                    P:Point(quickCastButtons[i], "TOPLEFT")
                else
                    if quickCastTable["lines"] == 6 then
                        P:Point(quickCastButtons[i], "TOPLEFT", quickCastButtons[i-1], "BOTTOMLEFT", 0, -quickCastTable["spacingY"])
                    else
                        if (i-1) % quickCastTable["lines"] == 0 then
                            P:Point(quickCastButtons[i], "TOPLEFT", quickCastButtons[i-quickCastTable["lines"]], "TOPRIGHT", quickCastTable["spacingX"], 0)
                        else
                            P:Point(quickCastButtons[i], "TOPLEFT", quickCastButtons[i-1], "BOTTOMLEFT", 0, -quickCastTable["spacingY"])
                        end
                    end
                end
            elseif quickCastTable["orientation"] == "bottom-to-top" then
                if i == 1 then
                    P:Point(quickCastButtons[i], "BOTTOMLEFT")
                else
                    if quickCastTable["lines"] == 6 then
                        P:Point(quickCastButtons[i], "BOTTOMLEFT", quickCastButtons[i-1], "TOPLEFT", 0, quickCastTable["spacingY"])
                    else
                        if (i-1) % quickCastTable["lines"] == 0 then
                            P:Point(quickCastButtons[i], "BOTTOMLEFT", quickCastButtons[i-quickCastTable["lines"]], "BOTTOMRIGHT", quickCastTable["spacingX"], 0)
                        else
                            P:Point(quickCastButtons[i], "BOTTOMLEFT", quickCastButtons[i-1], "TOPLEFT", 0, quickCastTable["spacingY"])
                        end
                    end
                end
            end
        end

        -- hide
        for i = quickCastTable["num"] + 1, 6 do
            quickCastButtons[i]:Hide()
        end
    else
        UnregisterAttributeDriver(quickCastFrame, "state-visibility")
        quickCastFrame:Hide()
        wipe(glowBuffs)
        wipe(glowCasts)
        outerBuff = nil
        innerBuff = nil
    end

    F:UpdateOmniCDPosition("Cell-QuickCast")
end
Cell:RegisterCallback("UpdateQuickCast", "QuickCast_UpdateQuickCast", UpdateQuickCast)

local function SpecChanged()
    UpdateQuickCast()
    if init and qcPane:IsShown() then
        LoadDB()
    end
end
Cell:RegisterCallback("SpecChanged", "QuickCast_SpecChanged", SpecChanged)