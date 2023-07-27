local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local U = Cell.uFuncs
local A = Cell.animations
local P = Cell.pixelPerfectFuncs
local LCG = LibStub("LibCustomGlow-1.0")

-- ----------------------------------------------------------------------- --
--                                quick cast                               --
-- ----------------------------------------------------------------------- --
local quickCastTable
local UpdatePreview, CreateQuickCastButton

-- ----------------------------------------------------------------------- --
--                              option widgets                             --
-- ----------------------------------------------------------------------- --
local qcPane, qcAddEB
local qcEnabledCB, qcNameDD, qcNameText, qcButtonsSlider, qcSizeSlider, qcOrientationDD, qcOrientationText, qcSpacingSlider
local qcOuterCP, qcOuterBtn
local qcInnerCP, qcInnerBtn

local qcGlowBuffsButtons = {}
local qcGlowBuffsPane, qcGlowBuffsCP, qcGlowBuffsAddBtn

local qcGlowCastsButtons = {}
local qcGlowCastsPane, qcGlowCastsCP, qcGlowCastsAddBtn

local function UpdateWidgets()
    Cell:SetEnabled(quickCastTable["enabled"], qcNameDD, qcNameText, qcButtonsSlider, qcSizeSlider, qcOrientationDD, qcOrientationText, qcSpacingSlider)
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

    local qcTips = qcPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    qcTips:SetPoint("TOPLEFT", 5, -25)
    qcTips:SetJustifyH("LEFT")
    qcTips:SetSpacing(5)
    qcTips:SetText(L["Create several buttons for quick casting and buff monitoring"].."\n"..L["These settings are spec-specific"])

    -- enabled ----------------------------------------------------------------------
    qcEnabledCB = Cell:CreateCheckButton(qcPane, L["Enabled"], function(checked, self)
        quickCastTable["enabled"] = checked
        UpdateWidgets()
        Cell:Fire("UpdateQuickCast")
    end)
    qcEnabledCB:SetPoint("TOPLEFT", qcPane, 5, -85)

    -- name -------------------------------------------------------------------------
    qcNameDD = Cell:CreateDropdown(qcPane, 120)
    qcNameDD:SetPoint("TOPLEFT", qcPane, 151, -85)
    
    local anchorPoints = {"LEFT", "RIGHT", "TOP", "BOTTOM"}
    local items = {}
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
    tinsert(items, {
        ["text"] = L["None"],
        ["value"] = "none",
        ["onClick"] = function()
            quickCastTable["namePosition"] = "none"
            UpdatePreview()
            Cell:Fire("UpdateQuickCast")
        end
    })
    qcNameDD:SetItems(items)

    qcNameText = qcPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    qcNameText:SetText(L["Name Text"])
    qcNameText:SetPoint("BOTTOMLEFT", qcNameDD, "TOPLEFT", 0, 1)

    -- buttons ----------------------------------------------------------------------
    qcButtonsSlider = Cell:CreateSlider(L["Max Buttons"], qcPane, 1, 5, 120, 1, function(value)
        quickCastTable["num"] = value
        Cell:Fire("UpdateQuickCast")
    end)
    qcButtonsSlider:SetPoint("TOPLEFT", qcEnabledCB, 0, -50)
    
    -- size -------------------------------------------------------------------------
    qcSizeSlider = Cell:CreateSlider(L["Size"], qcPane, 16, 64, 120, 1, function(value)
        quickCastTable["size"] = value
        UpdatePreview()
        Cell:Fire("UpdateQuickCast")
    end)
    qcSizeSlider:SetPoint("TOPLEFT", qcButtonsSlider, 0, -55)

    -- orientation ------------------------------------------------------------------
    qcOrientationDD = Cell:CreateDropdown(qcPane, 120)
    qcOrientationDD:SetPoint("TOPLEFT", qcNameDD, 0, -50)
    qcOrientationDD:SetItems({
        {
            ["text"] = L["Horizontal"].." →",
            ["value"] = "horizontal-left-to-right",
            ["onClick"] = function()
                quickCastTable["orientation"] = "horizontal-left-to-right"
                Cell:Fire("UpdateQuickCast")
            end
        },
        {
            ["text"] = L["Horizontal"].." ←",
            ["value"] = "horizontal-right-to-left",
            ["onClick"] = function()
                quickCastTable["orientation"] = "horizontal-right-to-left"
                Cell:Fire("UpdateQuickCast")
            end
        },
        {
            ["text"] = L["Vertical"].." ↓",
            ["value"] = "vertical-top-to-bottom",
            ["onClick"] = function()
                quickCastTable["orientation"] = "vertical-top-to-bottom"
                Cell:Fire("UpdateQuickCast")
            end
        },
        {
            ["text"] = L["Vertical"].." ↑",
            ["value"] = "vertical-bottom-to-top",
            ["onClick"] = function()
                quickCastTable["orientation"] = "vertical-bottom-to-top"
                Cell:Fire("UpdateQuickCast")
            end
        },
    })

    qcOrientationText = qcPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    qcOrientationText:SetText(L["Orientation"])
    qcOrientationText:SetPoint("BOTTOMLEFT", qcOrientationDD, "TOPLEFT", 0, 1)

    -- spacing ----------------------------------------------------------------------
    qcSpacingSlider = Cell:CreateSlider(L["Spacing"], qcPane, 0, 16, 120, 1, function(value)
        quickCastTable["spacing"] = value
        Cell:Fire("UpdateQuickCast")
    end)
    qcSpacingSlider:SetPoint("TOPLEFT", qcOrientationDD, 0, -55)

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

        local name, _, icon = GetSpellInfo(spellId)
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
local previewPane, previewButton
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
end

local function CreatePreviewPane()
    previewPane = Cell:CreateTitledPane(qcPane, L["Preview"], 130, 155)
    previewPane:SetPoint("TOPRIGHT", 0, -85)

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

    b:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            local popup = Cell:CreatePopupEditBox(qcPane, function(text)
                local spellId = tonumber(text)
                local spellName, _, spellIcon = GetSpellInfo(spellId)
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

        local name, _, icon = GetSpellInfo(id)
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
            local spellName = GetSpellInfo(spellId)
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

        local name, _, icon = GetSpellInfo(spellId)
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
            local spellName = GetSpellInfo(spellId)
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
        local name, _, icon = GetSpellInfo(value)
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
    qcSizeSlider:SetValue(quickCastTable["size"])
    qcSpacingSlider:SetValue(quickCastTable["spacing"])
    
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
            CreatePreviewPane()
            CreateOuterPane()
            CreateInnerPane()
            CreateGlowBuffsPane()
            CreateGlowCastsPane()

            F:ApplyCombatProtectionToFrame(qcPane)
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
quickCastFrame:SetPoint("TOPLEFT", UIParent, "CENTER")
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

            local f = GetMouseFocus()
            if f and f.state and f.state.displayedUnit and F:UnitInGroup(f.state.displayedUnit) then
                quickCastTable["units"][frame.index] = f.state.displayedUnit
                frame:SetUnit(f.state.displayedUnit, outerBuff, innerBuff)
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
        A:FrameFadeOut(self, 0.25, self:GetAlpha(), 0.5)
    end
end

local function QuickCast_OnEvent(self, event, unit, arg1, arg2)
    if unit and self.unit == unit then
        if event == "UNIT_AURA" then
            QuickCast_UpdateAuras(self)
        elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
            QuickCast_UpdateCasts(self, arg2)
        elseif event == "UNIT_IN_RANGE_UPDATE" then
            QuickCast_UpdateInRange(self, arg1)
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
CreateQuickCastButton = function(parent, name, isPreview)
    local b
    if isPreview then
        b = CreateFrame("Button", name, parent, "BackdropTemplate")
    else
        b = CreateFrame("Button", name, parent, "BackdropTemplate,SecureUnitButtonTemplate")
    end
    b:RegisterForClicks("AnyDown")
    b:Hide()
    b._r, b._g, b._b = 0, 0, 0

    -- name -------------------------------------------------------------------------
    local nameText = b:CreateFontString(nil, "OVERLAY")
    b.nameText = nameText
    nameText:Hide()
    nameText:SetFont(GameFontNormal:GetFont(), 13, "Outline")
    
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
                    if remain < 0 then
                        remain = 0
                        glowBuffCD:Hide()
                    end
                    glowBuffCD:SetAlpha(remain / duration * 0.9 + 0.1)
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
                    if remain < 0 then
                        remain = 0
                        glowCastCD:Hide()
                    end
                    glowCastCD:SetAlpha(remain / duration * 0.9 + 0.1)
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
            P:Point(innerCD, "TOPLEFT", borderSize, -borderSize)
            P:Point(innerCD, "BOTTOMRIGHT", -borderSize, borderSize)
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

        P:ClearPoints(outerCD)
        P:Point(outerCD, "TOPLEFT", borderSize, -borderSize)
        P:Point(outerCD, "BOTTOMRIGHT", -borderSize, borderSize)
        -- P:Size(outerCD, size-borderSize*2, size-borderSize*2)
        P:Size(innerCD, ceil(size-borderSize*4), ceil(size-borderSize*4))

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

            local _r, _g, _b
            if UnitIsConnected(unit) then
                local class = UnitClassBase(unit)
                _r, _g, _b = F:GetClassColor(class)
            else
                _r, _g, _b = 0.4, 0.4, 0.4
            end
            b._r, b._g, b._b = _r, _g, _b
            b:SetBackdropColor(_r*0.2, _g*0.2, _b*0.2, 0.7)
            b:SetBackdropBorderColor(_r, _g, _b, 0.9)
            nameText:SetTextColor(_r, _g, _b)

            local name = UnitName(unit)
            name = Cell.vars.nicknameCustoms[name] or Cell.vars.nicknames[name] or name
            if string.len(name) == string.utf8len(name) then -- en
                nameText:SetText(string.utf8sub(name, 1, 3))
            else
                nameText:SetText(string.utf8sub(name, 1, 1))
            end

            --! check range now
            b:RegisterUnitEvent("UNIT_IN_RANGE_UPDATE", unit)
            QuickCast_UpdateInRange(b, UnitInRange(unit))

            --! check buffs now
            b:RegisterEvent("UNIT_AURA")
            QuickCast_UpdateAuras(b)

            --! casts glow
            b:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
            b:SetGlowCastCooldown()
        else
            b:SetAlpha(0.5)
            b:SetBackdropColor(0, 0, 0, 0.7)
            b:SetBackdropBorderColor(0, 0, 0, 0.9)
            nameText:SetText(unit)

            glowBuffCD:Hide()
            glowCastCD:Hide()
            outerCD:Hide()
            innerCD:Hide()
        end
    end

    --! NOTE: PLAYER_LOGIN or MANUALLY CALLED
    function b:SetUnit(unit, leftCast, rightCast)
        F:Debug("[QuickCast] SetUnit:", unit, leftCast, rightCast)
        
        b.unit = unit

        if unit then
            b:SetAttribute("unit", unit)
            b:SetAttribute("type1", "spell")
            b:SetAttribute("spell1", leftCast)
            b:SetAttribute("type2", "spell")
            b:SetAttribute("spell2", rightCast)

            -- RegisterAttributeDriver(b, "state-visibility", "[@"..unit..",exists] show; hide")
        else
            b:SetAttribute("unit", nil)
            b:SetAttribute("type1", nil)
            b:SetAttribute("spell1", nil)
            b:SetAttribute("type2", nil)
            b:SetAttribute("spell2", nil)

            -- UnregisterAttributeDriver(b, "state-visibility")
            -- b:Hide()
        end

        b:CheckUnit()
    end

    --! shift right-click to clear unit
    b:SetAttribute("shift-type2", "clear")
    b:SetAttribute("_clear", function()
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
    if not quickCastTable then
        quickCastTable = CellDB["quickCast"][Cell.vars.playerClass][Cell.vars.playerSpecID]
    end

    -- prepare others
    borderSize = floor(quickCastTable["size"]/8)
    glowBuffsColor = quickCastTable["glowBuffsColor"]
    glowCastsColor = quickCastTable["glowCastsColor"]

    if quickCastTable["enabled"] then
        RegisterAttributeDriver(quickCastFrame, "state-visibility", "[group] show; hide")
        targetFrame:UpdatePixelPerfect()
        -- quickCastFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        -- quickCastFrame:RegisterEvent("GROUP_ROSTER_UPDATE")

        -- update parent size
        if strfind(quickCastTable["orientation"], "^vertical") then
            P:Size(quickCastFrame, quickCastTable["size"], quickCastTable["size"] * quickCastTable["num"] + quickCastTable["spacing"] * (quickCastTable["num"] - 1))
        else
            P:Size(quickCastFrame, quickCastTable["size"] * quickCastTable["num"] + quickCastTable["spacing"] * (quickCastTable["num"] - 1), quickCastTable["size"])
        end

        -- position
        P:LoadPosition(quickCastFrame, quickCastTable["position"])

        -- prepare buffs
        glowBuffs = F:ConvertSpellTable(quickCastTable["glowBuffs"], true)
        glowCasts = F:ConvertSpellDurationTable(quickCastTable["glowCasts"])
        outerBuff = GetSpellInfo(quickCastTable["outerBuff"])
        innerBuff = GetSpellInfo(quickCastTable["innerBuff"])

        -- create
        if not quickCastButtons then
            quickCastButtons = {}
            for i = 1, 5 do
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
            if quickCastTable["orientation"] == "horizontal-left-to-right" then
                if i == 1 then
                    P:Point(quickCastButtons[i], "TOPLEFT")
                else
                    P:Point(quickCastButtons[i], "TOPLEFT", quickCastButtons[i-1], "TOPRIGHT", quickCastTable["spacing"], 0)
                end
            elseif quickCastTable["orientation"] == "horizontal-right-to-left" then
                if i == 1 then
                    P:Point(quickCastButtons[i], "TOPRIGHT")
                else
                    P:Point(quickCastButtons[i], "TOPRIGHT", quickCastButtons[i-1], "TOPLEFT", -quickCastTable["spacing"], 0)
                end
            elseif quickCastTable["orientation"] == "vertical-top-to-bottom" then
                if i == 1 then
                    P:Point(quickCastButtons[i], "TOPLEFT")
                else
                    P:Point(quickCastButtons[i], "TOPLEFT", quickCastButtons[i-1], "BOTTOMLEFT", 0, -quickCastTable["spacing"])
                end
            elseif quickCastTable["orientation"] == "vertical-bottom-to-top" then
                if i == 1 then
                    P:Point(quickCastButtons[i], "BOTTOMLEFT")
                else
                    P:Point(quickCastButtons[i], "BOTTOMLEFT", quickCastButtons[i-1], "TOPLEFT", 0, quickCastTable["spacing"])
                end
            end
        end
    
        -- hide
        for i = quickCastTable["num"] + 1, 5 do
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

end
Cell:RegisterCallback("UpdateQuickCast", "QuickCast_UpdateQuickCast", UpdateQuickCast)

local function SpecChanged()
    quickCastTable = CellDB["quickCast"][Cell.vars.playerClass][Cell.vars.playerSpecID]
    if init and qcPane:IsShown() then
        LoadDB()
    end
    UpdateQuickCast()
end
Cell:RegisterCallback("SpecChanged", "QuickCast_SpecChanged", SpecChanged)