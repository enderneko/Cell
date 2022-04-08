local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

local layoutsTab = Cell:CreateFrame("CellOptionsFrame_LayoutsTab", Cell.frames.optionsFrame, nil, nil, true)
Cell.frames.layoutsTab = layoutsTab
layoutsTab:SetAllPoints(Cell.frames.optionsFrame)
layoutsTab:Hide()

local selectedRole, selectedLayout, selectedLayoutTable
-------------------------------------------------
-- preview frame
-------------------------------------------------
local previewButton

local function CreatePreviewButton()
    previewButton = CreateFrame("Button", "CellLayoutsPreviewButton", layoutsTab, "CellUnitButtonTemplate")
    previewButton:SetPoint("TOPRIGHT", layoutsTab, "TOPLEFT", -5, -20)
    previewButton:UnregisterAllEvents()
    previewButton:SetScript("OnEnter", nil)
    previewButton:SetScript("OnLeave", nil)
    previewButton:SetScript("OnShow", nil)
    previewButton:SetScript("OnHide", nil)
    previewButton:SetScript("OnUpdate", nil)
    previewButton:Show()
    
    local previewButtonBG = Cell:CreateFrame("LayoutsPreviewButtonBG", layoutsTab)
    previewButtonBG:SetPoint("TOPLEFT", previewButton, 0, 20)
    previewButtonBG:SetPoint("BOTTOMRIGHT", previewButton, "TOPRIGHT")
    previewButtonBG:SetFrameStrata("BACKGROUND")
    Cell:StylizeFrame(previewButtonBG, {.1, .1, .1, .77}, {0, 0, 0, 0})
    previewButtonBG:Show()
    
    local previewText = previewButtonBG:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET_TITLE")
    previewText:SetPoint("TOP", 0, -3)
    previewText:SetText(Cell:GetPlayerClassColorString()..L["Preview"])
end

local function UpdatePreviewButton(which, value)
    if not previewButton then
        CreatePreviewButton()
    end

    if not which or which == "nameText" then
        local iTable = selectedLayoutTable["indicators"][1]
        if iTable["enabled"] then
            previewButton.indicators.nameText:Show()
            previewButton.indicators.nameText.isPreview = true
            previewButton.state.name = UnitName("player")
            previewButton.indicators.nameText:UpdateName()
            previewButton.indicators.nameText:UpdatePreviewColor(iTable["nameColor"])
            previewButton.indicators.nameText:UpdateTextWidth(iTable["textWidth"])
            previewButton.indicators.nameText:SetFont(unpack(iTable["font"]))
            previewButton.indicators.nameText:ClearAllPoints()
            previewButton.indicators.nameText:SetPoint(unpack(iTable["position"]))

            -- previewButton.indicators.nameText:UpdateVehicleName()
            -- previewButton.indicators.nameText:UpdateVehicleNamePosition(iTable["vehicleNamePosition"])
        else
            previewButton.indicators.nameText:Hide()
        end
    end

    -- if not which or which == "statusText" then
    --     local iTable = selectedLayoutTable["indicators"][2]
    --     if iTable["enabled"] then
    --         previewButton.indicators.statusText:Show()
    --         previewButton.indicators.statusText:SetFont(unpack(iTable["font"]))
    --         previewButton.indicators.statusText:ClearAllPoints()
    --         previewButton.indicators.statusText:SetPoint(iTable["position"][1], nil, iTable["position"][2])
    --         previewButton.indicators.statusText.text:SetText(L["OFFLINE"])
    --         previewButton.indicators.statusText.timer:SetText("13m")
    --     else
    --         previewButton.indicators.statusText:Hide()
    --     end
    -- end

    if not which or which == "appearance" then
        previewButton.widget.healthBar:SetStatusBarTexture(Cell.vars.texture)
        previewButton.widget.powerBar:SetStatusBarTexture(Cell.vars.texture)

        -- health color
        local r, g, b = F:GetHealthColor(1, F:GetClassColor(Cell.vars.playerClass))
        previewButton.widget.healthBar:SetStatusBarColor(r, g, b, CellDB["appearance"]["barAlpha"])
        
        -- power color
        r, g, b = F:GetPowerColor("player", Cell.vars.playerClass)
        previewButton.widget.powerBar:SetStatusBarColor(r, g, b)

        -- alpha
        previewButton:SetBackdropColor(0, 0, 0, CellDB["appearance"]["bgAlpha"])
    end
    
    if not which or which == "size" then
        P:Size(previewButton, selectedLayoutTable["size"][1], selectedLayoutTable["size"][2])
    end

    if not which or which == "barOrientation" then
        previewButton.func.SetOrientation(unpack(selectedLayoutTable["barOrientation"]))
    end

    if not which or which == "power" or which == "barOrientation" then
        previewButton.func.SetPowerSize(selectedLayoutTable["powerSize"])
    end
end

-------------------------------------------------
-- layout preview
-------------------------------------------------
local previewMode = 0
local layoutPreview = Cell:CreateFrame("CellLayoutPreviewFrame", Cell.frames.mainFrame, nil, nil, true)
layoutPreview:EnableMouse(false)
layoutPreview:SetFrameStrata("MEDIUM")
layoutPreview:SetToplevel(true)
layoutPreview:Hide()

local layoutPreviewAnchor = CreateFrame("Frame", "CellLayoutPreviewAnchorFrame", layoutPreview, "BackdropTemplate")
-- layoutPreviewAnchor:SetPoint("TOPLEFT", UIParent, "CENTER")
P:Size(layoutPreviewAnchor, 20, 10)
layoutPreviewAnchor:SetMovable(true)
layoutPreviewAnchor:EnableMouse(true)
layoutPreviewAnchor:RegisterForDrag("LeftButton")
layoutPreviewAnchor:SetClampedToScreen(true)
Cell:StylizeFrame(layoutPreviewAnchor, {0, 1, 0, 0.4})
layoutPreviewAnchor:Hide()
layoutPreviewAnchor:SetScript("OnDragStart", function()
    layoutPreviewAnchor:StartMoving()
    layoutPreviewAnchor:SetUserPlaced(false)
end)
layoutPreviewAnchor:SetScript("OnDragStop", function()
    layoutPreviewAnchor:StopMovingOrSizing()
    P:SavePosition(layoutPreviewAnchor, selectedLayoutTable["position"])
end)

local layoutPreviewName = layoutPreviewAnchor:CreateFontString(nil, "OVERLAY", "CELL_FONT_CLASS_TITLE")
-- layoutPreviewName:SetFont(GameFontNormal:GetFont(), 14, "OUTLINE")
-- layoutPreviewName:SetShadowOffset(0, 0)
-- Cell:ColorFontStringByPlayerClass(layoutPreviewName)

-- init raid preview
do
    layoutPreview.fadeIn = layoutPreview:CreateAnimationGroup()
    local fadeIn = layoutPreview.fadeIn:CreateAnimation("alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(.5)
    fadeIn:SetSmoothing("OUT")
    fadeIn:SetScript("OnPlay", function()
        layoutPreview:Show()
    end)
    
    layoutPreview.fadeOut = layoutPreview:CreateAnimationGroup()
    local fadeOut = layoutPreview.fadeOut:CreateAnimation("alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.5)
    fadeOut:SetSmoothing("IN")
    fadeOut:SetScript("OnFinished", function()
        layoutPreview:Hide()
    end)

    local desaturation = {
        [1] = 1,
        [2] = .85,
        [3] = .7,
        [4] = .55,
        [5] = .4,
    }

    -- headers
    layoutPreview.headers = {}
    for i = 1, 8 do
        local header = CreateFrame("Frame", "CellLayoutPreviewFrameHeader"..i, layoutPreview)
        layoutPreview.headers[i] = header

        for j = 1, 5 do
            header[j] = header:CreateTexture(nil, "BACKGROUND")
            header[j]:SetColorTexture(0, 0, 0)
            header[j]:SetAlpha(0.555)
            -- header[j]:SetSize(30, 20)

            header[j].tex = header:CreateTexture(nil, "ARTWORK")
            header[j].tex:SetTexture("Interface\\Buttons\\WHITE8x8")
    
            P:Point(header[j].tex, "TOPLEFT", header[j], "TOPLEFT", 1, -1)
            P:Point(header[j].tex, "BOTTOMRIGHT", header[j], "BOTTOMRIGHT", -1, 1)

            if i == 1 then
                header[j].tex:SetVertexColor(F:ConvertRGB(255, 0, 0, 1, desaturation[j])) -- Red
            elseif i == 2 then
                header[j].tex:SetVertexColor(F:ConvertRGB(255, 127, 0, 1, desaturation[j])) -- Orange
            elseif i == 3 then
                header[j].tex:SetVertexColor(F:ConvertRGB(255, 255, 0, 1, desaturation[j])) -- Yellow
            elseif i == 4 then
                header[j].tex:SetVertexColor(F:ConvertRGB(0, 255, 0, 1, desaturation[j])) -- Green
            elseif i == 5 then
                header[j].tex:SetVertexColor(F:ConvertRGB(0, 127, 255, 1, desaturation[j])) -- Blue
            elseif i == 6 then
                header[j].tex:SetVertexColor(F:ConvertRGB(127, 0, 255, 1, desaturation[j])) -- Indigo
            elseif i == 7 then
                header[j].tex:SetVertexColor(F:ConvertRGB(238, 130, 238, 1, desaturation[j])) -- Violet
            elseif i == 8 then
                header[j].tex:SetVertexColor(F:ConvertRGB(255, 255, 255, 1, desaturation[j])) -- White
            end
            header[j].tex:SetAlpha(0.555)
        end
    end
end

local function UpdateLayoutPreview()
    -- update layoutPreview point
    P:Size(layoutPreview, selectedLayoutTable["size"][1], selectedLayoutTable["size"][2])
    P:ClearPoints(layoutPreview)
    layoutPreviewName:ClearAllPoints()
    if selectedLayoutTable["anchor"] == "BOTTOMLEFT" then
        P:Point(layoutPreview, "BOTTOMLEFT", layoutPreviewAnchor, "TOPLEFT", 0, 4)
        layoutPreviewName:SetPoint("LEFT", layoutPreviewAnchor, "RIGHT", 5, 0)
    elseif selectedLayoutTable["anchor"] == "BOTTOMRIGHT" then
        P:Point(layoutPreview, "BOTTOMRIGHT", layoutPreviewAnchor, "TOPRIGHT", 0, 4)
        layoutPreviewName:SetPoint("RIGHT", layoutPreviewAnchor, "LEFT", -5, 0)
    elseif selectedLayoutTable["anchor"] == "TOPLEFT" then
        P:Point(layoutPreview, "TOPLEFT", layoutPreviewAnchor, "BOTTOMLEFT", 0, -4)
        layoutPreviewName:SetPoint("LEFT", layoutPreviewAnchor, "RIGHT", 5, 0)
    elseif selectedLayoutTable["anchor"] == "TOPRIGHT" then
        P:Point(layoutPreview, "TOPRIGHT", layoutPreviewAnchor, "BOTTOMRIGHT", 0, -4)
        layoutPreviewName:SetPoint("RIGHT", layoutPreviewAnchor, "LEFT", -5, 0)
    end

    -- update layoutPreviewAnchor point
    if selectedLayout == Cell.vars.currentLayout then
        layoutPreviewAnchor:SetAllPoints(Cell.frames.anchorFrame)
        layoutPreviewAnchor:Hide()
        layoutPreviewName:Hide()
    else
        if #selectedLayoutTable["position"] == 2 then
            P:LoadPosition(layoutPreviewAnchor, selectedLayoutTable["position"])
        else
            layoutPreviewAnchor:ClearAllPoints()
            layoutPreviewAnchor:SetPoint("TOPLEFT", UIParent, "CENTER")
        end
        layoutPreviewAnchor:Show()
        layoutPreviewName:SetText(L["Layout"]..": "..selectedLayout)
        layoutPreviewName:Show()
    end

    -- re-arrange
    local shownGroups = {}
    for i, isShown in ipairs(selectedLayoutTable["groupFilter"]) do
        if isShown then
            tinsert(shownGroups, i)
        end
    end

    for i, group in ipairs(shownGroups) do
        local header = layoutPreview.headers[group]
        local spacing = selectedLayoutTable["spacing"]
        
        header:ClearAllPoints()

        if selectedLayoutTable["orientation"] == "vertical" then
            -- anchor
            local point, anchorPoint, groupAnchorPoint, unitSpacing, groupSpacing, verticalSpacing
            if selectedLayoutTable["anchor"] == "BOTTOMLEFT" then
                point, anchorPoint, groupAnchorPoint = "BOTTOMLEFT", "TOPLEFT", "BOTTOMRIGHT"
                unitSpacing = spacing
                groupSpacing = spacing
                verticalSpacing = spacing+selectedLayoutTable["groupSpacing"]
            elseif selectedLayoutTable["anchor"] == "BOTTOMRIGHT" then
                point, anchorPoint, groupAnchorPoint = "BOTTOMRIGHT", "TOPRIGHT", "BOTTOMLEFT"
                unitSpacing = spacing
                groupSpacing = -spacing
                verticalSpacing = spacing+selectedLayoutTable["groupSpacing"]
            elseif selectedLayoutTable["anchor"] == "TOPLEFT" then
                point, anchorPoint, groupAnchorPoint = "TOPLEFT", "BOTTOMLEFT", "TOPRIGHT"
                unitSpacing = -spacing
                groupSpacing = spacing
                verticalSpacing = -spacing-selectedLayoutTable["groupSpacing"]
            elseif selectedLayoutTable["anchor"] == "TOPRIGHT" then
                point, anchorPoint, groupAnchorPoint = "TOPRIGHT", "BOTTOMRIGHT", "TOPLEFT"
                unitSpacing = -spacing
                groupSpacing = -spacing
                verticalSpacing = -spacing-selectedLayoutTable["groupSpacing"]
            end

            P:Size(header, selectedLayoutTable["size"][1], selectedLayoutTable["size"][2]*5+abs(unitSpacing)*4)
            for j = 1, 5 do
                P:Size(header[j], selectedLayoutTable["size"][1], selectedLayoutTable["size"][2])
                header[j]:ClearAllPoints()

                if j == 1 then
                    header[j]:SetPoint(point)
                else
                    header[j]:SetPoint(point, header[j-1], anchorPoint, 0, unitSpacing)
                end
            end

            if i == 1 then
                header:SetPoint(point)
            else
                if i / selectedLayoutTable["columns"] > 1 then -- not the first row
                    header:SetPoint(point, layoutPreview.headers[shownGroups[i-selectedLayoutTable["columns"]]], anchorPoint, 0, verticalSpacing)
                else
                    header:SetPoint(point, layoutPreview.headers[shownGroups[i-1]], groupAnchorPoint, groupSpacing, 0)
                end
            end
        else
            -- anchor
            local point, anchorPoint, groupAnchorPoint, unitSpacing, groupSpacing, horizontalSpacing
            if selectedLayoutTable["anchor"] == "BOTTOMLEFT" then
                point, anchorPoint, groupAnchorPoint = "BOTTOMLEFT", "BOTTOMRIGHT", "TOPLEFT"
                unitSpacing = spacing
                groupSpacing = spacing
                horizontalSpacing = spacing+selectedLayoutTable["groupSpacing"]
            elseif selectedLayoutTable["anchor"] == "BOTTOMRIGHT" then
                point, anchorPoint, groupAnchorPoint = "BOTTOMRIGHT", "BOTTOMLEFT", "TOPRIGHT"
                unitSpacing = -spacing
                groupSpacing = spacing
                horizontalSpacing = -spacing-selectedLayoutTable["groupSpacing"]
            elseif selectedLayoutTable["anchor"] == "TOPLEFT" then
                point, anchorPoint, groupAnchorPoint = "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT"
                unitSpacing = spacing
                groupSpacing = -spacing
                horizontalSpacing = spacing+selectedLayoutTable["groupSpacing"]
            elseif selectedLayoutTable["anchor"] == "TOPRIGHT" then
                point, anchorPoint, groupAnchorPoint = "TOPRIGHT", "TOPLEFT", "BOTTOMRIGHT"
                unitSpacing = -spacing
                groupSpacing = -spacing
                horizontalSpacing = -spacing-selectedLayoutTable["groupSpacing"]
            end

            P:Size(header, selectedLayoutTable["size"][1]*5+abs(unitSpacing)*4, selectedLayoutTable["size"][2])
            for j = 1, 5 do
                P:Size(header[j], selectedLayoutTable["size"][1], selectedLayoutTable["size"][2])
                header[j]:ClearAllPoints()

                if j == 1 then
                    header[j]:SetPoint(point)
                else
                    header[j]:SetPoint(point, header[j-1], anchorPoint, unitSpacing, 0)
                end
            end

            if i == 1 then
                header:SetPoint(point)
            else
                if i / selectedLayoutTable["rows"] > 1 then -- not the first column
                    header:SetPoint(point, layoutPreview.headers[shownGroups[i-selectedLayoutTable["rows"]]], anchorPoint, horizontalSpacing, 0)
                else
                    header:SetPoint(point, layoutPreview.headers[shownGroups[i-1]], groupAnchorPoint, 0, groupSpacing)
                end
            end
        end
    end

    -- update group filter
    if previewMode ~= 1 then
        for i = 1, 8 do
            if selectedLayoutTable["groupFilter"][i] then
                layoutPreview.headers[i]:Show()
            else
                layoutPreview.headers[i]:Hide()
            end
        end
    else -- party
        layoutPreview.headers[1]:Show()
        for i = 2, 8 do
            layoutPreview.headers[i]:Hide()
        end
    end

    if layoutPreview.fadeIn:IsPlaying() then
        layoutPreview.fadeIn:Restart()
    else
        layoutPreview.fadeIn:Play()
    end
    
    if layoutPreview.fadeOut:IsPlaying() then
        layoutPreview.fadeOut:Stop()
    end

    if layoutPreview.timer then
        layoutPreview.timer:Cancel()
    end

    if previewMode == 0 then
        layoutPreview.timer = C_Timer.NewTimer(1, function()
            layoutPreview.fadeOut:Play()
            layoutPreview.timer = nil
        end)
    end
end

-------------------------------------------------
-- npc preview
-------------------------------------------------
local npcPreview = Cell:CreateFrame("CellNPCPreviewFrame", Cell.frames.mainFrame, nil, nil, true)
npcPreview:EnableMouse(false)
npcPreview:SetFrameStrata("MEDIUM")
npcPreview:SetToplevel(true)
npcPreview:Hide()

local npcPreviewAnchor = CreateFrame("Frame", "CellNPCPreviewAnchorFrame", npcPreview, "BackdropTemplate")
P:Size(npcPreviewAnchor, 20, 10)
npcPreviewAnchor:SetMovable(true)
npcPreviewAnchor:EnableMouse(true)
npcPreviewAnchor:RegisterForDrag("LeftButton")
npcPreviewAnchor:SetClampedToScreen(true)
Cell:StylizeFrame(npcPreviewAnchor, {0, 1, 0, 0.4})
npcPreviewAnchor:Hide()
npcPreviewAnchor:SetScript("OnDragStart", function()
    npcPreviewAnchor:StartMoving()
    npcPreviewAnchor:SetUserPlaced(false)
end)
npcPreviewAnchor:SetScript("OnDragStop", function()
    npcPreviewAnchor:StopMovingOrSizing()
    P:SavePosition(npcPreviewAnchor, selectedLayoutTable["friendlyNPC"][3])
end)

local npcPreviewName = npcPreviewAnchor:CreateFontString(nil, "OVERLAY", "CELL_FONT_CLASS_TITLE")

do
    npcPreview.fadeIn = npcPreview:CreateAnimationGroup()
    local fadeIn = npcPreview.fadeIn:CreateAnimation("alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(.5)
    fadeIn:SetSmoothing("OUT")
    fadeIn:SetScript("OnPlay", function()
        npcPreview:Show()
    end)
    
    npcPreview.fadeOut = npcPreview:CreateAnimationGroup()
    local fadeOut = npcPreview.fadeOut:CreateAnimation("alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.5)
    fadeOut:SetSmoothing("IN")
    fadeOut:SetScript("OnFinished", function()
        npcPreview:Hide()
    end)

    local desaturation = {
        [1] = 1,
        [2] = .85,
        [3] = .7,
        [4] = .55,
        [5] = .4,
    }


    npcPreview.header = CreateFrame("Frame", "CellNPCPreviewFrameHeader", npcPreview)
    for i = 1, 5 do
        npcPreview.header[i] = npcPreview.header:CreateTexture(nil, "BACKGROUND")
        npcPreview.header[i]:SetColorTexture(0, 0, 0)
        npcPreview.header[i]:SetAlpha(0.555)

        npcPreview.header[i].tex = npcPreview.header:CreateTexture(nil, "ARTWORK")
        npcPreview.header[i].tex:SetTexture("Interface\\Buttons\\WHITE8x8")

        P:Point(npcPreview.header[i].tex, "TOPLEFT", npcPreview.header[i], "TOPLEFT", 1, -1)
        P:Point(npcPreview.header[i].tex, "BOTTOMRIGHT", npcPreview.header[i], "BOTTOMRIGHT", -1, 1)

        npcPreview.header[i].tex:SetVertexColor(F:ConvertRGB(0, 255, 255, 1, desaturation[i])) -- cyan
        npcPreview.header[i].tex:SetAlpha(0.555)
    end
end

local function UpdateNPCPreview()
    if not selectedLayoutTable["friendlyNPC"][1] or not selectedLayoutTable["friendlyNPC"][2] then
        if npcPreview.timer then
            npcPreview.timer:Cancel()
            npcPreview.timer = nil
        end
        if npcPreview.fadeIn:IsPlaying() then
            npcPreview.fadeIn:Stop()
        end
        if not npcPreview.fadeOut:IsPlaying() then
            npcPreview.fadeOut:Play()
        end
        return
    end

    -- update npcPreview point
    P:Size(npcPreview, selectedLayoutTable["size"][1], selectedLayoutTable["size"][2])
    P:ClearPoints(npcPreview)
    npcPreviewName:ClearAllPoints()
    
    if selectedLayoutTable["anchor"] == "BOTTOMLEFT" then
        P:Point(npcPreview, "BOTTOMLEFT", npcPreviewAnchor, "TOPLEFT", 0, 4)
        npcPreviewName:SetPoint("LEFT", npcPreviewAnchor, "RIGHT", 5, 0)
    elseif selectedLayoutTable["anchor"] == "BOTTOMRIGHT" then
        P:Point(npcPreview, "BOTTOMRIGHT", npcPreviewAnchor, "TOPRIGHT", 0, 4)
        npcPreviewName:SetPoint("RIGHT", npcPreviewAnchor, "LEFT", -5, 0)
    elseif selectedLayoutTable["anchor"] == "TOPLEFT" then
        P:Point(npcPreview, "TOPLEFT", npcPreviewAnchor, "BOTTOMLEFT", 0, -4)
        npcPreviewName:SetPoint("LEFT", npcPreviewAnchor, "RIGHT", 5, 0)
    elseif selectedLayoutTable["anchor"] == "TOPRIGHT" then
        P:Point(npcPreview, "TOPRIGHT", npcPreviewAnchor, "BOTTOMRIGHT", 0, -4)
        npcPreviewName:SetPoint("RIGHT", npcPreviewAnchor, "LEFT", -5, 0)
    end

    -- update npcAnchor point
    if selectedLayout == Cell.vars.currentLayout then
        -- NOTE: move separate npc anchor with preview
        Cell.frames.separateNpcFrameAnchor:SetAllPoints(npcPreviewAnchor)
    else
        P:LoadPosition(Cell.frames.separateNpcFrameAnchor, Cell.vars.currentLayoutTable["friendlyNPC"][3])
    end

    if #selectedLayoutTable["friendlyNPC"][3] == 2 then
        P:LoadPosition(npcPreviewAnchor, selectedLayoutTable["friendlyNPC"][3])
    else
        npcPreviewAnchor:ClearAllPoints()
        npcPreviewAnchor:SetPoint("TOPLEFT", UIParent, "CENTER")
    end
    npcPreviewAnchor:Show()
    npcPreviewName:SetText(L["Layout"]..": "..selectedLayout.." (NPC)")
    npcPreviewName:Show()

    -- re-arrange
    local header = npcPreview.header
    header:ClearAllPoints()

    local spacing = selectedLayoutTable["spacing"]

    if selectedLayoutTable["orientation"] == "vertical" then
        -- anchor
        local point, anchorPoint, unitSpacing
        if selectedLayoutTable["anchor"] == "BOTTOMLEFT" then
            point, anchorPoint = "BOTTOMLEFT", "TOPLEFT"
            unitSpacing = spacing
        elseif selectedLayoutTable["anchor"] == "BOTTOMRIGHT" then
            point, anchorPoint = "BOTTOMRIGHT", "TOPRIGHT"
            unitSpacing = spacing
        elseif selectedLayoutTable["anchor"] == "TOPLEFT" then
            point, anchorPoint = "TOPLEFT", "BOTTOMLEFT"
            unitSpacing = -spacing
        elseif selectedLayoutTable["anchor"] == "TOPRIGHT" then
            point, anchorPoint = "TOPRIGHT", "BOTTOMRIGHT"
            unitSpacing = -spacing
        end

        P:Size(header, selectedLayoutTable["size"][1], selectedLayoutTable["size"][2]*5+abs(unitSpacing)*4)
        header:SetPoint(point)
        
        for i = 1, 5 do
            P:Size(header[i], selectedLayoutTable["size"][1], selectedLayoutTable["size"][2])
            header[i]:ClearAllPoints()

            if i == 1 then
                header[i]:SetPoint(point)
            else
                header[i]:SetPoint(point, header[i-1], anchorPoint, 0, unitSpacing)
            end
        end
    else
        -- anchor
        local point, anchorPoint, unitSpacing
        if selectedLayoutTable["anchor"] == "BOTTOMLEFT" then
            point, anchorPoint = "BOTTOMLEFT", "BOTTOMRIGHT"
            unitSpacing = spacing
        elseif selectedLayoutTable["anchor"] == "BOTTOMRIGHT" then
            point, anchorPoint = "BOTTOMRIGHT", "BOTTOMLEFT"
            unitSpacing = -spacing
        elseif selectedLayoutTable["anchor"] == "TOPLEFT" then
            point, anchorPoint = "TOPLEFT", "TOPRIGHT"
            unitSpacing = spacing
        elseif selectedLayoutTable["anchor"] == "TOPRIGHT" then
            point, anchorPoint = "TOPRIGHT", "TOPLEFT"
            unitSpacing = -spacing
        end

        P:Size(header, selectedLayoutTable["size"][1]*5+abs(unitSpacing)*4, selectedLayoutTable["size"][2])
        header:SetPoint(point)

        for i = 1, 5 do
            P:Size(header[i], selectedLayoutTable["size"][1], selectedLayoutTable["size"][2])
            header[i]:ClearAllPoints()

            if i == 1 then
                header[i]:SetPoint(point)
            else
                header[i]:SetPoint(point, header[i-1], anchorPoint, unitSpacing, 0)
            end
        end
    end

    if npcPreview.fadeIn:IsPlaying() then
        npcPreview.fadeIn:Restart()
    else
        npcPreview.fadeIn:Play()
    end
    
    if npcPreview.fadeOut:IsPlaying() then
        npcPreview.fadeOut:Stop()
    end

    if npcPreview.timer then
        npcPreview.timer:Cancel()
    end

    if previewMode == 0 then
        npcPreview.timer = C_Timer.NewTimer(1, function()
            npcPreview.fadeOut:Play()
            npcPreview.timer = nil
        end)
    end
end

-------------------------------------------------
-- OnHide
-------------------------------------------------
layoutsTab:SetScript("OnHide", function()
    if layoutPreview.timer then
        layoutPreview.timer:Cancel()
        layoutPreview.timer = nil
    end
    if layoutPreview.fadeIn:IsPlaying() then
        layoutPreview.fadeIn:Stop()
    end
    if not layoutPreview.fadeOut:IsPlaying() then
        layoutPreview.fadeOut:Play()
    end
   
    if npcPreview.timer then
        npcPreview.timer:Cancel()
        npcPreview.timer = nil
    end
    if npcPreview.fadeIn:IsPlaying() then
        npcPreview.fadeIn:Stop()
    end
    if not npcPreview.fadeOut:IsPlaying() then
        npcPreview.fadeOut:Play()
    end
end)

-------------------------------------------------
-- layout
-------------------------------------------------
local layoutDropdown, roleDropdown, partyDropdown, raidDropdown, arenaDropdown, bg15Dropdown, bg40Dropdown
local LoadLayoutDropdown, LoadAutoSwitchDropdowns
local LoadLayoutDB, UpdateButtonStates, LoadLayoutAutoSwitchDB

local enabledLayoutText

local function CreateLayoutPane()
    local layoutPane = Cell:CreateTitledPane(layoutsTab, L["Layout"], 205, 100)
    layoutPane:SetPoint("TOPLEFT", 5, -5)

    enabledLayoutText = layoutPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET_TITLE")
    enabledLayoutText:SetPoint("BOTTOMRIGHT", layoutPane.line, "TOPRIGHT", 0, P:Scale(2))
    enabledLayoutText:SetPoint("LEFT", layoutPane.title, "RIGHT", 5, 0)
    enabledLayoutText:SetWordWrap(false)
    enabledLayoutText:SetJustifyH("LEFT")

    layoutDropdown = Cell:CreateDropdown(layoutPane, 163)
    layoutDropdown:SetPoint("TOPLEFT", 5, -27)

    -- new
    local newBtn = Cell:CreateButton(layoutPane, L["New"], "class-hover", {55, 20})
    newBtn:SetPoint("TOPLEFT", layoutDropdown, "BOTTOMLEFT", 0, -10)
    newBtn:SetScript("OnClick", function()
        local popup = Cell:CreateConfirmPopup(layoutsTab, 200, L["Create new layout"], function(self)
            local name = strtrim(self.editBox:GetText())
            local inherit = self.dropdown1:GetSelected()

            if name ~= "" and strlower(name) ~= "default" and name ~= _G.DEFAULT and not CellDB["layouts"][name] then
                -- update db copy current layout
                if inherit == "cell-default-layout" then
                    CellDB["layouts"][name] = F:Copy(Cell.defaults.layout)
                else
                    CellDB["layouts"][name] = F:Copy(CellDB["layouts"][inherit])
                end
                -- update dropdown
                layoutDropdown:AddItem({
                    ["text"] = name,
                    ["onClick"] = function()
                        LoadLayoutDB(name)
                        UpdateButtonStates()
                    end,
                })
                layoutDropdown:SetSelected(name)
                LoadAutoSwitchDropdowns()
                LoadLayoutDB(name)
                UpdateButtonStates()
                F:Print(L["Layout added: "]..name..".")
            else
                F:Print(L["Invalid layout name."])
            end
        end, nil, true, true, 1)
        popup:SetPoint("TOPLEFT", 117, -70)

        -- layout inherits
        local inherits = {
            {
                ["text"] = L["Default layout"],
                ["value"] = "cell-default-layout",
            }
        }

        for name in pairs(CellDB["layouts"]) do
            tinsert(inherits, {
                ["text"] = L["Inherit: "] .. name,
                ["value"] = name, 
            })
        end

        popup.dropdown1:SetItems(inherits)
        popup.dropdown1:SetSelectedItem(1)
    end)
    Cell:RegisterForCloseDropdown(newBtn)

    -- rename
    local renameBtn = Cell:CreateButton(layoutPane, L["Rename"], "class-hover", {55, 20})
    renameBtn:SetPoint("TOPLEFT", newBtn, "TOPRIGHT", P:Scale(-1), 0)
    renameBtn:SetScript("OnClick", function()
        local popup = Cell:CreateConfirmPopup(layoutsTab, 200, L["Rename layout"].." "..selectedLayout, function(self)
            local name = strtrim(self.editBox:GetText())
            if name ~= "" and strlower(name) ~= "default" and name ~= _G.DEFAULT and not CellDB["layouts"][name] then
                -- update db
                CellDB["layouts"][name] = F:Copy(CellDB["layouts"][selectedLayout])
                CellDB["layouts"][selectedLayout] = nil
                -- check auto switch related
                for role, t in pairs(CellDB["layoutAutoSwitch"]) do
                    for groupType, layout in pairs(t) do
                        if layout == selectedLayout then
                            CellDB["layoutAutoSwitch"][role][groupType] = name
                        end
                    end
                end
                
                -- check current
                if selectedLayout == Cell.vars.currentLayout then
                    -- update vars
                    Cell.vars.currentLayout = name
                    Cell.vars.currentLayoutTable = CellDB["layouts"][name]
                    -- update text
                    UpdateEnabledLayoutText()
                end

                -- update dropdown
                layoutDropdown:SetCurrentItem({
                    ["text"] = name,
                    ["onClick"] = function()
                        LoadLayoutDB(name)
                        UpdateButtonStates()
                    end,
                })
                layoutDropdown:SetSelected(name)
                
                F:Print(L["Layout renamed: "].." "..selectedLayout.." "..L["to"].." "..name..".")

                -- reload
                LoadAutoSwitchDropdowns()
                LoadLayoutDB(name)
            else
                F:Print(L["Invalid layout name."])
            end
        end, nil, true, true)
        popup:SetPoint("TOPLEFT", 117, -185)
    end)
    Cell:RegisterForCloseDropdown(renameBtn)

    -- delete
    local deleteBtn = Cell:CreateButton(layoutPane, L["Delete"], "class-hover", {55, 20})
    deleteBtn:SetPoint("TOPLEFT", renameBtn, "TOPRIGHT", P:Scale(-1), 0)
    deleteBtn:SetScript("OnClick", function()
        local popup = Cell:CreateConfirmPopup(layoutsTab, 200, L["Delete layout"].." "..selectedLayout.."?", function(self)
            -- update db
            CellDB["layouts"][selectedLayout] = nil
            F:Print(L["Layout deleted: "]..selectedLayout..".")
            -- check auto switch related
            for role, t in pairs(CellDB["layoutAutoSwitch"]) do
                for groupType, layout in pairs(t) do
                    if layout == selectedLayout then
                        CellDB["layoutAutoSwitch"][role][groupType] = "default"
                    end
                end
            end

            -- set current to default
            if selectedLayout == Cell.vars.currentLayout then
                -- update vars
                Cell.vars.currentLayout = "default"
                Cell.vars.currentLayoutTable = CellDB["layouts"]["default"]
                Cell:Fire("UpdateLayout", "default")
                -- update text
                UpdateEnabledLayoutText()
            end

            -- update dropdown
            layoutDropdown:RemoveCurrentItem()
            layoutDropdown:SetSelected(_G.DEFAULT)

            -- reload
            LoadAutoSwitchDropdowns()
            LoadLayoutDB("default")
            UpdateButtonStates()
        end, nil, true)
        popup:SetPoint("TOPLEFT", 117, -185)
    end)
    Cell:RegisterForCloseDropdown(deleteBtn)

    -- import
    local importBtn = Cell:CreateButton(layoutPane, L["Import"], "class-hover", {55, 20})
    importBtn:SetPoint("TOPLEFT", newBtn, "BOTTOMLEFT", 0, P:Scale(1))
    importBtn:SetScript("OnClick", function()
        F:ShowLayoutImportFrame()
    end)

    -- export
    local exportBtn = Cell:CreateButton(layoutPane, L["Export"], "class-hover", {55, 20})
    exportBtn:SetPoint("TOPLEFT", importBtn, "TOPRIGHT", P:Scale(-1), 0)
    exportBtn:SetScript("OnClick", function()
        F:ShowLayoutExportFrame(selectedLayout, selectedLayoutTable)
    end)

    UpdateButtonStates = function()
        if selectedLayout == "default" then
            deleteBtn:SetEnabled(false)
            renameBtn:SetEnabled(false)
        else
            deleteBtn:SetEnabled(true)
            renameBtn:SetEnabled(true)
        end
    end

    -- copy & paste
    local shareBtn = Cell:CreateButton(layoutPane, L["Share"], "class-hover", {55, 20})
    shareBtn:SetPoint("TOPLEFT", exportBtn, "TOPRIGHT", P:Scale(-1), 0)
    shareBtn:SetScript("OnClick", function()
        local editbox = ChatEdit_ChooseBoxForSend()
        ChatEdit_ActivateChat(editbox)
        editbox:SetText("[Cell:Layout: "..selectedLayout.." - "..Cell.vars.playerName.."]")
    end)
end

local function UpdateEnabledLayoutText()
    enabledLayoutText:SetText("|cFF777777"..L["Current"]..": "..(Cell.vars.currentLayout == "default" and _G.DEFAULT or Cell.vars.currentLayout))
end

-- drop down
LoadLayoutDropdown = function()
    local indices = {}
    for name, _ in pairs(CellDB["layouts"]) do
        if name ~= "default" then
            tinsert(indices, name)
        end
    end
    table.sort(indices)
    tinsert(indices, 1, "default") -- make default first

    local items = {}
    for _, value in pairs(indices) do
        table.insert(items, {
            ["text"] = value == "default" and _G.DEFAULT or value,
            ["onClick"] = function()
                LoadLayoutDB(value)
                UpdateButtonStates()
            end,
        })
    end
    layoutDropdown:SetItems(items)
end

-------------------------------------------------
-- layout auto switch
-------------------------------------------------
local partyText, raidText, arenaText, bg15Text, bg40Text

local function CreateAutoSwitchPane()
    local autoSwitchPane = Cell:CreateTitledPane(layoutsTab, L["Layout Auto Switch"], 205, 200)
    autoSwitchPane:SetPoint("TOPLEFT", 222, -5)

    -- role
    roleDropdown = Cell:CreateDropdown(autoSwitchPane, 163)
    roleDropdown:SetPoint("TOPLEFT", 5, -27)
    roleDropdown:SetItems({
        {
            ["text"] = "|TInterface\\AddOns\\Cell\\Media\\Roles\\TANK:11|t "..TANK,
            ["value"] = "TANK",
            ["onClick"] = function()
                selectedRole = "TANK"
                LoadLayoutAutoSwitchDB(selectedRole)
            end,
        },
        {
            ["text"] = "|TInterface\\AddOns\\Cell\\Media\\Roles\\HEALER:11|t "..HEALER,
            ["value"] = "HEALER",
            ["onClick"] = function()
                selectedRole = "HEALER"
                LoadLayoutAutoSwitchDB(selectedRole)
            end,
        },
        {
            ["text"] = "|TInterface\\AddOns\\Cell\\Media\\Roles\\DAMAGER:11|t "..DAMAGER,
            ["value"] = "DAMAGER",
            ["onClick"] = function()
                selectedRole = "DAMAGER"
                LoadLayoutAutoSwitchDB(selectedRole)
            end,
        },
    })
    
    -- party
    partyDropdown = Cell:CreateDropdown(autoSwitchPane, 90)
    partyDropdown:SetPoint("TOPLEFT", roleDropdown, "BOTTOMLEFT", 0, -25)
    
    partyText = autoSwitchPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    partyText:SetPoint("BOTTOMLEFT", partyDropdown, "TOPLEFT", 0, 1)
    partyText:SetText(L["Solo/Party"])
    
    -- raid
    raidDropdown = Cell:CreateDropdown(autoSwitchPane, 90)
    raidDropdown:SetPoint("TOPLEFT", partyDropdown, "BOTTOMLEFT", 0, -30)
    
    raidText = autoSwitchPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    raidText:SetPoint("BOTTOMLEFT", raidDropdown, "TOPLEFT", 0, 1)
    raidText:SetText(L["Raid"])
    
    -- arena
    arenaDropdown = Cell:CreateDropdown(autoSwitchPane, 90)
    arenaDropdown:SetPoint("TOPLEFT", partyDropdown, "TOPRIGHT", 10, 0)
    
    arenaText = autoSwitchPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    arenaText:SetPoint("BOTTOMLEFT", arenaDropdown, "TOPLEFT", 0, 1)
    arenaText:SetText(L["Arena"])
    
    -- battleground 15
    bg15Dropdown = Cell:CreateDropdown(autoSwitchPane, 90)
    bg15Dropdown:SetPoint("TOPLEFT", arenaDropdown, "BOTTOMLEFT", 0, -30)
    
    bg15Text = autoSwitchPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    bg15Text:SetPoint("BOTTOMLEFT", bg15Dropdown, "TOPLEFT", 0, 1)
    bg15Text:SetText(L["BG 1-15"])
    
    -- battleground 40
    bg40Dropdown = Cell:CreateDropdown(autoSwitchPane, 90)
    bg40Dropdown:SetPoint("TOPLEFT", bg15Dropdown, "BOTTOMLEFT", 0, -30)
    
    bg40Text = autoSwitchPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    bg40Text:SetPoint("BOTTOMLEFT", bg40Dropdown, "TOPLEFT", 0, 1)
    bg40Text:SetText(L["BG 16-40"])
end

LoadAutoSwitchDropdowns = function()
    local indices = {}
    for name, _ in pairs(CellDB["layouts"]) do
        if name ~= "default" then
            tinsert(indices, name)
        end
    end
    table.sort(indices)
    tinsert(indices, 1, "default") -- make default first

    -- partyDropdown
    local partyItems = {}
    for _, value in pairs(indices) do
        table.insert(partyItems, {
            ["text"] = value == "default" and _G.DEFAULT or value,
            ["onClick"] = function()
                CellDB["layoutAutoSwitch"][selectedRole]["party"] = value
                if not Cell.vars.inBattleground and (Cell.vars.groupType == "solo" or Cell.vars.groupType == "party") and (selectedRole == Cell.vars.playerSpecRole) then
                    F:UpdateLayout("party")
                    Cell:Fire("UpdateIndicators")
                    LoadLayoutDB(Cell.vars.currentLayout)
                    UpdateButtonStates()
                    UpdateEnabledLayoutText()
                end
            end,
        })
    end
    partyDropdown:SetItems(partyItems)

    -- raidDropdown
    local raidItems = {}
    for _, value in pairs(indices) do
        table.insert(raidItems, {
            ["text"] = value == "default" and _G.DEFAULT or value,
            ["onClick"] = function()
                CellDB["layoutAutoSwitch"][selectedRole]["raid"] = value
                if not Cell.vars.inBattleground and Cell.vars.groupType == "raid" and selectedRole == Cell.vars.playerSpecRole then
                    F:UpdateLayout("raid")
                    Cell:Fire("UpdateIndicators")
                    LoadLayoutDB(Cell.vars.currentLayout)
                    UpdateButtonStates()
                    UpdateEnabledLayoutText()
                end
            end,
        })
    end
    raidDropdown:SetItems(raidItems)

    -- arenaDropdown
    local arenaItems = {}
    for _, value in pairs(indices) do
        table.insert(arenaItems, {
            ["text"] = value == "default" and _G.DEFAULT or value,
            ["onClick"] = function()
                CellDB["layoutAutoSwitch"][selectedRole]["arena"] = value
                if Cell.vars.inBattleground == 5 and selectedRole == Cell.vars.playerSpecRole then
                    F:UpdateLayout("arena")
                    Cell:Fire("UpdateIndicators")
                    LoadLayoutDB(Cell.vars.currentLayout)
                    UpdateButtonStates()
                    UpdateEnabledLayoutText()
                end
            end,
        })
    end
    arenaDropdown:SetItems(arenaItems)

    -- bg15Dropdown
    local bg15Items = {}
    for _, value in pairs(indices) do
        table.insert(bg15Items, {
            ["text"] = value == "default" and _G.DEFAULT or value,
            ["onClick"] = function()
                CellDB["layoutAutoSwitch"][selectedRole]["battleground15"] = value
                if Cell.vars.inBattleground == 15 and selectedRole == Cell.vars.playerSpecRole then
                    F:UpdateLayout("battleground15")
                    Cell:Fire("UpdateIndicators")
                    LoadLayoutDB(Cell.vars.currentLayout)
                    UpdateButtonStates()
                    UpdateEnabledLayoutText()
                end
            end,
        })
    end
    bg15Dropdown:SetItems(bg15Items)

    -- bg40Dropdown
    local bg40Items = {}
    for _, value in pairs(indices) do
        table.insert(bg40Items, {
            ["text"] = value == "default" and _G.DEFAULT or value,
            ["onClick"] = function()
                CellDB["layoutAutoSwitch"][selectedRole]["battleground40"] = value
                if Cell.vars.inBattleground == 40 and selectedRole == Cell.vars.playerSpecRole then
                    F:UpdateLayout("battleground40")
                    Cell:Fire("UpdateIndicators")
                    LoadLayoutDB(Cell.vars.currentLayout)
                    UpdateButtonStates()
                    UpdateEnabledLayoutText()
                end
            end,
        })
    end
    bg40Dropdown:SetItems(bg40Items)
end

-------------------------------------------------
-- group filter
-------------------------------------------------
local function UpdateButtonBorderColor(flag, b)
    local borderColor 
    if flag then
        borderColor = {b.hoverColor[1], b.hoverColor[2], b.hoverColor[3], 1}
    else
        borderColor = {0, 0, 0, 1}
    end
    b:SetBackdropBorderColor(unpack(borderColor))
end

local groupButtons = {}
local function CreateGroupFilterPane()
    local groupFilterPane = Cell:CreateTitledPane(layoutsTab, L["Group Filter"], 205, 55)
    groupFilterPane:SetPoint("TOPLEFT", 5, -123)

    for i = 1, 8 do
        groupButtons[i] = Cell:CreateButton(groupFilterPane, i, "class-hover", {20, 20})
        groupButtons[i]:SetScript("OnClick", function()
            selectedLayoutTable["groupFilter"][i] = not selectedLayoutTable["groupFilter"][i]
            UpdateButtonBorderColor(selectedLayoutTable["groupFilter"][i], groupButtons[i])
    
            if selectedLayout == Cell.vars.currentLayout then
                Cell:Fire("UpdateLayout", selectedLayout, "groupFilter")
            end
            UpdateLayoutPreview()
        end)
        
        if i == 1 then
            groupButtons[i]:SetPoint("TOPLEFT", 5, -27)
        -- elseif i == 5 then
        --     groupButtons[i]:SetPoint("TOPLEFT", groupButtons[1], "BOTTOMLEFT", 0, -3)
        else
            groupButtons[i]:SetPoint("TOPLEFT", groupButtons[i-1], "TOPRIGHT", 3, 0)
        end
    end
end

local function UpdateGroupFilter()
    for i = 1, 8 do
        UpdateButtonBorderColor(selectedLayoutTable["groupFilter"][i], groupButtons[i])
    end
end

-------------------------------------------------
-- button size
-------------------------------------------------
local widthSlider, heightSlider, powerSizeSlider, petSizeCB, petWidthSlider, petHeightSlider, switch

local function CreateButtonSizePane()
    local buttonSizePane = Cell:CreateTitledPane(layoutsTab, L["Unit Button"], 139, 170)
    buttonSizePane:SetPoint("TOPLEFT", 5, -210)
    
    -- width
    widthSlider = Cell:CreateSlider(L["Width"], buttonSizePane, 20, 300, 117, 2, function(value)
        selectedLayoutTable["size"][1] = value
        if selectedLayout == Cell.vars.currentLayout then
            Cell:Fire("UpdateLayout", selectedLayout, "size")
        end
        UpdatePreviewButton("size")
        UpdateLayoutPreview()
        UpdateNPCPreview()
    end)
    widthSlider:SetPoint("TOPLEFT", 5, -40)
    
    -- height
    heightSlider = Cell:CreateSlider(L["Height"], buttonSizePane, 20, 300, 117, 2, function(value)
        selectedLayoutTable["size"][2] = value
        if selectedLayout == Cell.vars.currentLayout then
            Cell:Fire("UpdateLayout", selectedLayout, "size")
        end
        UpdatePreviewButton("size")
        UpdateLayoutPreview()
        UpdateNPCPreview()
    end)
    heightSlider:SetPoint("TOPLEFT", widthSlider, "BOTTOMLEFT", 0, -40)
    
    -- power height
    powerSizeSlider = Cell:CreateSlider(L["Power Size"], buttonSizePane, 0, 20, 117, 1, function(value)
        selectedLayoutTable["powerSize"] = value
        if selectedLayout == Cell.vars.currentLayout then
            Cell:Fire("UpdateLayout", selectedLayout, "power")
        end
        UpdatePreviewButton("power")
    end)
    powerSizeSlider:SetPoint("TOPLEFT", heightSlider, "BOTTOMLEFT", 0, -40)
    
    -- petSize
    petSizeCB = Cell:CreateCheckButton(buttonSizePane, L["Pet Button Size"], function(checked, self)
        if checked then
            petWidthSlider:SetEnabled(true)
            petHeightSlider:SetEnabled(true)
        else
            petWidthSlider:SetEnabled(false)
            petHeightSlider:SetEnabled(false)
        end
        selectedLayoutTable["petSize"][1] = checked
        if selectedLayout == Cell.vars.currentLayout then
            Cell:Fire("UpdateLayout", selectedLayout, "petSize")
        end
    end)
    petSizeCB:SetPoint("TOPLEFT", buttonSizePane, 5, -40)
    
    -- petWidth
    petWidthSlider = Cell:CreateSlider(L["Width"].." ("..PET..")", buttonSizePane, 40, 300, 117, 2, function(value)
        selectedLayoutTable["petSize"][2] = value
        if selectedLayout == Cell.vars.currentLayout then
            Cell:Fire("UpdateLayout", selectedLayout, "petSize")
        end
    end)
    petWidthSlider:SetPoint("TOPLEFT", petSizeCB, "BOTTOMLEFT", 0, -36)
    
    -- petHeight
    petHeightSlider = Cell:CreateSlider(L["Height"].." ("..PET..")", buttonSizePane, 20, 300, 117, 2, function(value)
        selectedLayoutTable["petSize"][3] = value
        if selectedLayout == Cell.vars.currentLayout then
            Cell:Fire("UpdateLayout", selectedLayout, "petSize")
        end
    end)
    petHeightSlider:SetPoint("TOPLEFT", petWidthSlider, "BOTTOMLEFT", 0, -40)
    
    -- player/pet switch
    switch = Cell:CreateSwitch(buttonSizePane, {22, 10}, "", "player", "", "pet", function(which)
        if which == "player" then
            widthSlider:Show()
            heightSlider:Show()
            powerSizeSlider:Show()
            petSizeCB:Hide()
            petWidthSlider:Hide()
            petHeightSlider:Hide()
        else
            widthSlider:Hide()
            heightSlider:Hide()
            powerSizeSlider:Hide()
            petSizeCB:Show()
            petWidthSlider:Show()
            petHeightSlider:Show()
        end
    end)
    switch:SetPoint("BOTTOMRIGHT", buttonSizePane.line, "TOPRIGHT", 0, P:Scale(2))
    switch:SetSelected("player", true)
end

-------------------------------------------------
-- group arrangement
-------------------------------------------------
local orientationDropdown, anchorDropdown, spacingSlider, rcSlider, groupSpacingSlider

local function CreateGroupArrangementPane()
    local groupArrangementPane = Cell:CreateTitledPane(layoutsTab, L["Group Arrangement"], 271, 170)
    groupArrangementPane:SetPoint("TOPLEFT", 156, -210)

    -- orientation
    orientationDropdown = Cell:CreateDropdown(groupArrangementPane, 117)
    orientationDropdown:SetPoint("TOPLEFT", 5, -40)
    orientationDropdown:SetItems({
        {
            ["text"] = L["Vertical"],
            ["value"] = "vertical",
            ["onClick"] = function()
                selectedLayoutTable["orientation"] = "vertical"
                if selectedLayout == Cell.vars.currentLayout then
                    Cell:Fire("UpdateLayout", selectedLayout, "orientation")
                end
                rcSlider:SetName(L["Group Columns"])
                rcSlider:SetValue(selectedLayoutTable["columns"])
                if selectedLayoutTable["columns"] == 8 then
                    groupSpacingSlider:SetEnabled(false)
                else
                    groupSpacingSlider:SetEnabled(true)
                end
                UpdateLayoutPreview()
                UpdateNPCPreview()
            end,
        },
        {
            ["text"] = L["Horizontal"],
            ["value"] = "horizontal",
            ["onClick"] = function()
                selectedLayoutTable["orientation"] = "horizontal"
                if selectedLayout == Cell.vars.currentLayout then
                    Cell:Fire("UpdateLayout", selectedLayout, "orientation")
                end
                rcSlider:SetName(L["Group Rows"])
                rcSlider:SetValue(selectedLayoutTable["rows"])
                if selectedLayoutTable["rows"] == 8 then
                    groupSpacingSlider:SetEnabled(false)
                else
                    groupSpacingSlider:SetEnabled(true)
                end
                UpdateLayoutPreview()
                UpdateNPCPreview()
            end,
        },
    })
    
    local orientationText = groupArrangementPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    orientationText:SetPoint("BOTTOMLEFT", orientationDropdown, "TOPLEFT", 0, 1)
    orientationText:SetText(L["Orientation"])
    
    -- anchor
    anchorDropdown = Cell:CreateDropdown(groupArrangementPane, 117)
    anchorDropdown:SetPoint("TOPLEFT", orientationDropdown, "BOTTOMLEFT", 0, -30)
    anchorDropdown:SetItems({
        {
            ["text"] = L["BOTTOMLEFT"],
            ["value"] = "BOTTOMLEFT",
            ["onClick"] = function()
                selectedLayoutTable["anchor"] = "BOTTOMLEFT"
                if selectedLayout == Cell.vars.currentLayout then
                    Cell:Fire("UpdateLayout", selectedLayout, "anchor")
                end
                UpdateLayoutPreview()
                UpdateNPCPreview()
            end,
        },
        {
            ["text"] = L["BOTTOMRIGHT"],
            ["value"] = "BOTTOMRIGHT",
            ["onClick"] = function()
                selectedLayoutTable["anchor"] = "BOTTOMRIGHT"
                if selectedLayout == Cell.vars.currentLayout then
                    Cell:Fire("UpdateLayout", selectedLayout, "anchor")
                end
                UpdateLayoutPreview()
                UpdateNPCPreview()
            end,
        },
        {
            ["text"] = L["TOPLEFT"],
            ["value"] = "TOPLEFT",
            ["onClick"] = function()
                selectedLayoutTable["anchor"] = "TOPLEFT"
                if selectedLayout == Cell.vars.currentLayout then
                    Cell:Fire("UpdateLayout", selectedLayout, "anchor")
                end
                UpdateLayoutPreview()
                UpdateNPCPreview()
            end,
        },
        {
            ["text"] = L["TOPRIGHT"],
            ["value"] = "TOPRIGHT",
            ["onClick"] = function()
                selectedLayoutTable["anchor"] = "TOPRIGHT"
                if selectedLayout == Cell.vars.currentLayout then
                    Cell:Fire("UpdateLayout", selectedLayout, "anchor")
                end
                UpdateLayoutPreview()
                UpdateNPCPreview()
            end,
        },
    })
    
    local anchorText = groupArrangementPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    anchorText:SetPoint("BOTTOMLEFT", anchorDropdown, "TOPLEFT", 0, 1)
    anchorText:SetText(L["Anchor Point"])
    
    -- preview mode
    previewModeBtn = Cell:CreateButton(groupArrangementPane, "|cff777777"..L["OFF"], "class", {117, 20})
    previewModeBtn:SetPoint("TOPLEFT", anchorDropdown, "BOTTOMLEFT", 0, -30)
    previewModeBtn:SetScript("OnClick", function()
        previewMode = (previewMode == 2) and 0 or (previewMode + 1)
    
        if previewMode == 0 then
            previewModeBtn:SetText("|cff777777"..L["OFF"])
            layoutPreview.fadeOut:Play()
            if npcPreview:IsShown() then
                npcPreview.fadeOut:Play()
            end
        elseif previewMode == 1 then
            previewModeBtn:SetText(L["Party"])
            UpdateLayoutPreview()
            UpdateNPCPreview()
        else
            previewModeBtn:SetText(L["Raid"])
            UpdateLayoutPreview()
            UpdateNPCPreview()
        end
    end)
    previewModeBtn:SetScript("OnHide", function()
        previewMode = 0
        previewModeBtn:SetText("|cff777777"..L["OFF"])
    end)
    
    local previewModeText = groupArrangementPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    previewModeText:SetPoint("BOTTOMLEFT", previewModeBtn, "TOPLEFT", 0, 1)
    previewModeText:SetText(L["Preview"])
    
    -- spacing
    spacingSlider = Cell:CreateSlider(L["Unit Spacing"], groupArrangementPane, 0, 10, 117, 1, function(value)
        selectedLayoutTable["spacing"] = value
        if selectedLayout == Cell.vars.currentLayout then
            Cell:Fire("UpdateLayout", selectedLayout, "spacing")
        end
        -- preview
        UpdateLayoutPreview()
        UpdateNPCPreview()
    end)
    spacingSlider:SetPoint("TOPLEFT", orientationDropdown, "TOPRIGHT", 23, 0)
    
    -- rows/columns
    rcSlider = Cell:CreateSlider("", groupArrangementPane, 1, 8, 117, 1, function(value)
        if selectedLayoutTable["orientation"] == "vertical" then
            selectedLayoutTable["columns"] = value
        else -- horizontal
            selectedLayoutTable["rows"] = value
        end
        if value == 8 then
            groupSpacingSlider:SetEnabled(false)
        else
            groupSpacingSlider:SetEnabled(true)
        end
        if selectedLayout == Cell.vars.currentLayout then
            Cell:Fire("UpdateLayout", selectedLayout, "rows_columns")
        end
        -- preview
        UpdateLayoutPreview()
    end)
    rcSlider:SetPoint("TOPLEFT", spacingSlider, "BOTTOMLEFT", 0, -40)
    
    -- group spacing
    groupSpacingSlider = Cell:CreateSlider(L["Group Spacing"], groupArrangementPane, 0, 20, 117, 1, function(value)
        selectedLayoutTable["groupSpacing"] = value
        if selectedLayout == Cell.vars.currentLayout then
            Cell:Fire("UpdateLayout", selectedLayout, "groupSpacing")
        end
        -- preview
        UpdateLayoutPreview()
    end)
    groupSpacingSlider:SetPoint("TOPLEFT", rcSlider, "BOTTOMLEFT", 0, -40)
end

-------------------------------------------------
-- bar orientation
-------------------------------------------------
local orientationSwitch, rotateTexCB

local function CreateBarOrientationPane()
    local barOrientationPane = Cell:CreateTitledPane(layoutsTab, L["Bar Orientation"], 205, 80)
    barOrientationPane:SetPoint("TOPLEFT", 5, -395)

    orientationSwitch = Cell:CreateSwitch(barOrientationPane, {163, 20}, L["Horizontal"], "horizontal", L["Vertical"], "vertical", function(which)
        selectedLayoutTable["barOrientation"][1] = which
        if selectedLayout == Cell.vars.currentLayout then
            Cell:Fire("UpdateLayout", selectedLayout, "barOrientation")
        end
        UpdatePreviewButton("barOrientation")
    end)
    orientationSwitch:SetPoint("TOPLEFT", 5, -27)
    
    rotateTexCB = Cell:CreateCheckButton(barOrientationPane, L["Rotate Texture"], function(checked)
        selectedLayoutTable["barOrientation"][2] = checked
        if selectedLayout == Cell.vars.currentLayout then
            Cell:Fire("UpdateLayout", selectedLayout, "barOrientation")
        end
        UpdatePreviewButton("barOrientation")
    end)
    rotateTexCB:SetPoint("TOPLEFT", orientationSwitch, "BOTTOMLEFT", 0, -10)
end

-------------------------------------------------
-- npc frame
-------------------------------------------------
local separateNPCCB, showNPCCB

local function CreateNPCPane()
    local npcPane = Cell:CreateTitledPane(layoutsTab, L["Friendly NPC Frame"], 205, 70)
    npcPane:SetPoint("TOPLEFT", 222, -395)

    showNPCCB = Cell:CreateCheckButton(npcPane, L["Show NPC Frame"], function(checked)
        selectedLayoutTable["friendlyNPC"][1] = checked
        if checked then
            if previewMode ~= 0 then
                UpdateNPCPreview()
            end
        else
            if npcPreview:IsShown() then
                UpdateNPCPreview()
            end
        end
        if selectedLayout == Cell.vars.currentLayout then
            Cell:Fire("UpdateLayout", selectedLayout, "npc")
        end
    end)
    showNPCCB:SetPoint("TOPLEFT", 5, -27)

    separateNPCCB = Cell:CreateCheckButton(npcPane, L["Separate NPC Frame"], function(checked)
        selectedLayoutTable["friendlyNPC"][2] = checked
        if checked then
            if previewMode ~= 0 then
                UpdateNPCPreview()
            end
        else
            if npcPreview:IsShown() then
                UpdateNPCPreview()
            end
        end
        if selectedLayout == Cell.vars.currentLayout then
            Cell:Fire("UpdateLayout", selectedLayout, "npc")
        end
    end, L["Separate NPC Frame"], L["Show friendly NPCs in a separate frame"], L["You can move it in Preview mode"])
    separateNPCCB:SetPoint("TOPLEFT", showNPCCB, "BOTTOMLEFT", 0, -8)
end

-------------------------------------------------
-- misc
-------------------------------------------------
local function CreateMiscPane()
    local miscPane = Cell:CreateTitledPane(layoutsTab, L["Misc"], 205, 50)
    miscPane:SetPoint("TOPLEFT", 222, -480)

    local powerFilterBtn = Cell:CreateButton(miscPane, L["Power Bar Filters"], "class-hover", {163, 20})
    Cell.frames.layoutsTab.powerFilterBtn = powerFilterBtn
    powerFilterBtn:SetPoint("TOPLEFT", 5, -27)
    powerFilterBtn:SetScript("OnClick", function ()
        F:ShowPowerFilters(selectedLayout, selectedLayoutTable)
    end)

    Cell.frames.powerFilters:SetPoint("BOTTOM", powerFilterBtn, "TOP", 0, P:Scale(5))
    Cell.frames.powerFilters:SetPoint("RIGHT", miscPane)
end

-------------------------------------------------
-- tips
-------------------------------------------------
local tips = layoutsTab:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
tips:SetPoint("BOTTOMLEFT", 5, 5)
tips:SetJustifyH("LEFT")
tips:SetText("|cff777777"..L["Tip: Every layout has its own position setting"])

-------------------------------------------------
-- functions
-------------------------------------------------
local init
LoadLayoutDB = function(layout)
    F:Debug("LoadLayoutDB: "..layout)

    selectedLayout = layout
    selectedLayoutTable = CellDB["layouts"][layout]

    layoutDropdown:SetSelected(selectedLayout == "default" and _G.DEFAULT or selectedLayout)

    widthSlider:SetValue(selectedLayoutTable["size"][1])
    heightSlider:SetValue(selectedLayoutTable["size"][2])
    powerSizeSlider:SetValue(selectedLayoutTable["powerSize"])

    petSizeCB:SetChecked(selectedLayoutTable["petSize"][1])
    petWidthSlider:SetValue(selectedLayoutTable["petSize"][2])
    petHeightSlider:SetValue(selectedLayoutTable["petSize"][3])
    if selectedLayoutTable["petSize"][1] then
        petWidthSlider:SetEnabled(true)
        petHeightSlider:SetEnabled(true)
    else
        petWidthSlider:SetEnabled(false)
        petHeightSlider:SetEnabled(false)
    end

    spacingSlider:SetValue(selectedLayoutTable["spacing"])
    
    if selectedLayoutTable["orientation"] == "vertical" then
        rcSlider:SetName(L["Group Columns"])
        rcSlider:SetValue(selectedLayoutTable["columns"])
        if selectedLayoutTable["columns"] == 8 then
            groupSpacingSlider:SetEnabled(false)
        else
            groupSpacingSlider:SetEnabled(true)
        end
    else
        rcSlider:SetName(L["Group Rows"])
        rcSlider:SetValue(selectedLayoutTable["rows"])
        if selectedLayoutTable["rows"] == 8 then
            groupSpacingSlider:SetEnabled(false)
        else
            groupSpacingSlider:SetEnabled(true)
        end
    end
    groupSpacingSlider:SetValue(selectedLayoutTable["groupSpacing"])

    -- group arrangement
    orientationDropdown:SetSelectedValue(selectedLayoutTable["orientation"])
    anchorDropdown:SetSelectedValue(selectedLayoutTable["anchor"])

    -- bar orientation
    orientationSwitch:SetSelected(selectedLayoutTable["barOrientation"][1])
    rotateTexCB:SetChecked(selectedLayoutTable["barOrientation"][2])

    -- npc frame
    showNPCCB:SetChecked(selectedLayoutTable["friendlyNPC"][1])
    separateNPCCB:SetChecked(selectedLayoutTable["friendlyNPC"][2])

    UpdateGroupFilter()
    UpdatePreviewButton()
    UpdateLayoutPreview()
    UpdateNPCPreview()
end

LoadLayoutAutoSwitchDB = function(role)
    selectedRole = role

    roleDropdown:SetSelectedValue(role)
    partyDropdown:SetSelected(CellDB["layoutAutoSwitch"][role]["party"] == "default" and _G.DEFAULT or CellDB["layoutAutoSwitch"][role]["party"])
    raidDropdown:SetSelected(CellDB["layoutAutoSwitch"][role]["raid"] == "default" and _G.DEFAULT or CellDB["layoutAutoSwitch"][role]["raid"])
    arenaDropdown:SetSelected(CellDB["layoutAutoSwitch"][role]["arena"] == "default" and _G.DEFAULT or CellDB["layoutAutoSwitch"][role]["arena"])
    bg15Dropdown:SetSelected(CellDB["layoutAutoSwitch"][role]["battleground15"] == "default" and _G.DEFAULT or CellDB["layoutAutoSwitch"][role]["battleground15"])
    bg40Dropdown:SetSelected(CellDB["layoutAutoSwitch"][role]["battleground40"] == "default" and _G.DEFAULT or CellDB["layoutAutoSwitch"][role]["battleground40"])
end

local function UpdateLayoutAutoSwitchText()
    if not init then return end
    if Cell.vars.inBattleground then
        if Cell.vars.inBattleground == 15 then
            partyText:SetText(L["Solo/Party"])
            raidText:SetText(L["Raid"])
            arenaText:SetText(L["Arena"])
            bg15Text:SetText(Cell:GetPlayerClassColorString()..L["BG 1-15"].."*")
            bg40Text:SetText(L["BG 16-40"])
        elseif Cell.vars.inBattleground == 40 then
            partyText:SetText(L["Solo/Party"])
            raidText:SetText(L["Raid"])
            arenaText:SetText(L["Arena"])
            bg15Text:SetText(L["BG 1-15"])
            bg40Text:SetText(Cell:GetPlayerClassColorString()..L["BG 16-40"].."*")
        else -- 5 arena
            partyText:SetText(L["Solo/Party"])
            raidText:SetText(L["Raid"])
            arenaText:SetText(Cell:GetPlayerClassColorString()..L["Arena"].."*")
            bg15Text:SetText(L["BG 1-15"])
            bg40Text:SetText(L["BG 16-40"])
        end
    else
        if Cell.vars.groupType == "solo" or Cell.vars.groupType == "party" then
            partyText:SetText(Cell:GetPlayerClassColorString()..L["Solo/Party"].."*")
            raidText:SetText(L["Raid"])
            arenaText:SetText(L["Arena"])
            bg15Text:SetText(L["BG 1-15"])
            bg40Text:SetText(L["BG 16-40"])
        else
            partyText:SetText(L["Solo/Party"])
            raidText:SetText(Cell:GetPlayerClassColorString()..L["Raid"].."*")
            arenaText:SetText(L["Arena"])
            bg15Text:SetText(L["BG 1-15"])
            bg40Text:SetText(L["BG 16-40"])
        end
    end
end
Cell:RegisterCallback("UpdateLayout", "LayoutsTab_UpdateLayout", UpdateLayoutAutoSwitchText)

local function UpdateAppearance()
    if previewButton and selectedLayout == Cell.vars.currentLayout then
        UpdatePreviewButton("appearance")
    end
end
Cell:RegisterCallback("UpdateAppearance", "LayoutsTab_UpdateAppearance", UpdateAppearance)

local function UpdateIndicators(layout, indicatorName, setting, value)
    if previewButton and selectedLayout == Cell.vars.currentLayout then
        if not layout or indicatorName == "nameText" then
            UpdatePreviewButton("nameText")
        end
        if not layout or indicatorName == "statusText" then
            UpdatePreviewButton("statusText")
        end
    end
end
Cell:RegisterCallback("UpdateIndicators", "LayoutsTab_UpdateIndicators", UpdateIndicators)

local function LayoutImported(name)
    if Cell.vars.currentLayout == name then -- update overwrite
        if Cell.vars.inBattleground then 
            if Cell.vars.inBattleground == 5 then
                F:UpdateLayout("arena")
            elseif Cell.vars.inBattleground == 15 then
                F:UpdateLayout("battleground15")
            elseif Cell.vars.inBattleground == 40 then
                F:UpdateLayout("battleground40")
            end
        else 
            if Cell.vars.groupType == "solo" or Cell.vars.groupType == "party" then
                F:UpdateLayout("party")
            elseif Cell.vars.groupType == "raid" then
                F:UpdateLayout("raid")
            end
        end
        Cell:Fire("UpdateIndicators")
        LoadLayoutDB(name)
        UpdateButtonStates()

    else -- load new
        -- update dropdown
        layoutDropdown:AddItem({
            ["text"] = name,
            ["onClick"] = function()
                LoadLayoutDB(name)
                UpdateButtonStates()
            end,
        })
        LoadAutoSwitchDropdowns()
        LoadLayoutDB(name)
        UpdateButtonStates()
    end
end
Cell:RegisterCallback("LayoutImported", "LayoutsTab_LayoutImported", LayoutImported)

local function ShowTab(tab)
    if tab == "layouts" then
        if not init then
            init = true

            -- mask
            Cell:CreateMask(layoutsTab, nil, {1, -1, -1, 1})
            layoutsTab.mask:Hide()

            CreateLayoutPane()
            CreateAutoSwitchPane()
            UpdateLayoutAutoSwitchText()
            CreateGroupFilterPane()
            CreateButtonSizePane()
            CreateGroupArrangementPane()
            CreateBarOrientationPane()
            CreateNPCPane()
            CreateMiscPane()

            LoadLayoutDropdown()
            LoadAutoSwitchDropdowns()
        end
        
        UpdateEnabledLayoutText()
        
        if selectedLayout ~= Cell.vars.currentLayout then
            LoadLayoutDB(Cell.vars.currentLayout)
        end
        if selectedRole ~= Cell.vars.playerSpecRole then
            LoadLayoutAutoSwitchDB(Cell.vars.playerSpecRole)
        end
        UpdateButtonStates()
        
        layoutsTab:Show()
    else
        layoutsTab:Hide()
    end
end
Cell:RegisterCallback("ShowOptionsTab", "LayoutsTab_ShowTab", ShowTab)

-------------------------------------------------
-- sharing functions
-------------------------------------------------
function F:ShowLayout(name)
    F:Print(L["Layout imported: %s."]:format(name))
    F:ShowLayousTab()
    LoadLayoutDropdown()
    LoadAutoSwitchDropdowns()
    LoadLayoutDB(name)
    UpdateButtonStates()
end