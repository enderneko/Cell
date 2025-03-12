local _, Cell = ...
local L = Cell.L
---@type CellFuncs
local F = Cell.funcs
---@type CellUnitButtonFuncs
local B = Cell.bFuncs
---@type PixelPerfectFuncs
local P = Cell.pixelPerfectFuncs

local layoutsTab = Cell.CreateFrame("CellOptionsFrame_LayoutsTab", Cell.frames.optionsFrame, nil, nil, true)
Cell.frames.layoutsTab = layoutsTab
layoutsTab:SetAllPoints(Cell.frames.optionsFrame)
layoutsTab:Hide()

local selectedLayout, selectedLayoutTable
local selectedPage = "main"
-------------------------------------------------
-- preview frame
-------------------------------------------------
local previewButton

local function CreatePreviewButton()
    previewButton = CreateFrame("Button", "CellLayoutsPreviewButton", layoutsTab, "CellPreviewButtonTemplate")
    B.UpdateBackdrop(previewButton)
    previewButton:SetPoint("TOPRIGHT", layoutsTab, "TOPLEFT", -5, -20)
    previewButton:UnregisterAllEvents()
    previewButton:SetScript("OnEnter", nil)
    previewButton:SetScript("OnLeave", nil)
    previewButton:SetScript("OnShow", nil)
    previewButton:SetScript("OnHide", nil)
    previewButton:SetScript("OnUpdate", nil)
    previewButton:Show()

    previewButton.widgets.healthBar:SetMinMaxValues(0, 1)
    previewButton.widgets.healthBar:SetValue(1)
    previewButton.widgets.powerBar:SetMinMaxValues(0, 1)
    previewButton.widgets.powerBar:SetValue(1)
    previewButton.isPreview = true

    local previewButtonBG = Cell.CreateFrame("CellLayoutsPreviewButtonBG", layoutsTab)
    previewButtonBG:SetPoint("TOPLEFT", previewButton, 0, 20)
    previewButtonBG:SetPoint("BOTTOMRIGHT", previewButton, "TOPRIGHT")
    Cell.StylizeFrame(previewButtonBG, {0.1, 0.1, 0.1, 0.77}, {0, 0, 0, 0})
    previewButtonBG:Show()

    local previewText = previewButtonBG:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET_TITLE")
    previewText:SetPoint("TOP", 0, -3)
    previewText:SetText(Cell.GetAccentColorString()..L["Preview"])

    Cell.Fire("CreatePreview", previewButton)
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
            previewButton.states.name = UnitName("player")
            previewButton.indicators.nameText:UpdateName()
            previewButton.indicators.nameText:UpdatePreviewColor(iTable["color"])
            previewButton.indicators.nameText:UpdateTextWidth(iTable["textWidth"])
            previewButton.indicators.nameText:SetFont(unpack(iTable["font"]))
            previewButton.indicators.nameText:ClearAllPoints()
            local relativeTo = iTable["position"][2] == "healthBar" and previewButton.widgets.healthBar or previewButton
            previewButton.indicators.nameText:SetPoint(iTable["position"][1], relativeTo, iTable["position"][3], iTable["position"][4], iTable["position"][5])

            -- previewButton.indicators.nameText:UpdateVehicleName()
            -- previewButton.indicators.nameText:UpdateVehicleNamePosition(iTable["vehicleNamePosition"])
        else
            previewButton.indicators.nameText:Hide()
        end
    end

    if not which or which == "appearance" then
        previewButton.widgets.healthBar:SetStatusBarTexture(Cell.vars.texture)
        previewButton.widgets.powerBar:SetStatusBarTexture(Cell.vars.texture)

        -- health color
        local r, g, b = F.GetHealthBarColor(1, false, F.GetClassColor(Cell.vars.playerClass))
        previewButton.widgets.healthBar:SetStatusBarColor(r, g, b, CellDB["appearance"]["barAlpha"])

        -- power color
        r, g, b = F.GetPowerBarColor("player", Cell.vars.playerClass)
        previewButton.widgets.powerBar:SetStatusBarColor(r, g, b)

        -- alpha
        previewButton:SetBackdropColor(0, 0, 0, CellDB["appearance"]["bgAlpha"])
    end

    if not which or which == "size" then
        P.Size(previewButton, selectedLayoutTable["main"]["size"][1], selectedLayoutTable["main"]["size"][2])
    end

    if not which or which == "barOrientation" then
        B.SetOrientation(previewButton, selectedLayoutTable["barOrientation"][1], selectedLayoutTable["barOrientation"][2])
    end

    if not which or which == "power" or which == "barOrientation" then
        B.SetPowerSize(previewButton, selectedLayoutTable["main"]["powerSize"])
    end

    Cell.Fire("UpdatePreview", previewButton)
end

-------------------------------------------------
-- layout preview
-------------------------------------------------
local previewMode = 0
local layoutPreview, layoutPreviewAnchor, layoutPreviewName

local desaturation = {
    [1] = 1,
    [2] = 0.85,
    [3] = 0.7,
    [4] = 0.55,
    [5] = 0.4,
}

local function CreateLayoutPreview()
    layoutPreview = Cell.CreateFrame("CellLayoutPreviewFrame", Cell.frames.mainFrame, nil, nil, true)
    layoutPreview:EnableMouse(false)
    layoutPreview:SetFrameStrata("HIGH")
    layoutPreview:SetToplevel(true)
    layoutPreview:Hide()

    layoutPreviewAnchor = CreateFrame("Frame", "CellLayoutPreviewAnchorFrame", layoutPreview, "BackdropTemplate")
    -- layoutPreviewAnchor:SetPoint("TOPLEFT", CellParent, "CENTER")
    P.Size(layoutPreviewAnchor, 20, 10)
    layoutPreviewAnchor:SetMovable(true)
    layoutPreviewAnchor:EnableMouse(true)
    layoutPreviewAnchor:RegisterForDrag("LeftButton")
    layoutPreviewAnchor:SetClampedToScreen(true)
    Cell.StylizeFrame(layoutPreviewAnchor, {0, 1, 0, 0.4})

    layoutPreviewAnchor:SetScript("OnDragStart", function()
        if selectedLayout == Cell.vars.currentLayout then
            Cell.frames.anchorFrame:StartMoving()
            Cell.frames.anchorFrame:SetUserPlaced(false)
        else
        layoutPreviewAnchor:StartMoving()
        layoutPreviewAnchor:SetUserPlaced(false)
        end
    end)

    layoutPreviewAnchor:SetScript("OnDragStop", function()
        if selectedLayout == Cell.vars.currentLayout then
            Cell.frames.anchorFrame:StopMovingOrSizing()
        else
        layoutPreviewAnchor:StopMovingOrSizing()
        end
        P.SavePosition(layoutPreviewAnchor, selectedLayoutTable["main"]["position"])
    end)

    layoutPreviewName = layoutPreviewAnchor:CreateFontString(nil, "OVERLAY", "CELL_FONT_CLASS_TITLE")

    -- init raid preview
    layoutPreview.fadeIn = layoutPreview:CreateAnimationGroup()
    local fadeIn = layoutPreview.fadeIn:CreateAnimation("alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(0.5)
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

    -- separatedHeaders
    layoutPreview.separatedHeaders = {}
    for i = 1, 8 do
        local header = CreateFrame("Frame", "CellLayoutPreviewSeparatedHeader"..i, layoutPreview)
        layoutPreview.separatedHeaders[i] = header

        for j = 1, 5 do
            header[j] = header:CreateTexture(nil, "BACKGROUND")
            header[j]:SetColorTexture(0, 0, 0)
            header[j]:SetAlpha(0.555)
            -- header[j]:SetSize(30, 20)

            header[j].tex = header:CreateTexture(nil, "ARTWORK")
            header[j].tex:SetTexture(Cell.vars.whiteTexture)
            header[j].tex:SetPoint("TOPLEFT", header[j], "TOPLEFT", P.Scale(1), P.Scale(-1))
            header[j].tex:SetPoint("BOTTOMRIGHT", header[j], "BOTTOMRIGHT", P.Scale(-1), P.Scale(1))

            header[j].label = header:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET_SMALL")
            header[j].label:SetPoint("BOTTOMRIGHT", header[j].tex, -2, 2)
            header[j].label:SetText(i.."-"..j)
            header[j].label:SetTextColor(0.5, 0.5, 0.5)

            if i == 1 then
                header[j].tex:SetVertexColor(F.ConvertRGB(255, 0, 0, desaturation[j])) -- Red
            elseif i == 2 then
                header[j].tex:SetVertexColor(F.ConvertRGB(255, 127, 0, desaturation[j])) -- Orange
            elseif i == 3 then
                header[j].tex:SetVertexColor(F.ConvertRGB(255, 255, 0, desaturation[j])) -- Yellow
            elseif i == 4 then
                header[j].tex:SetVertexColor(F.ConvertRGB(0, 255, 0, desaturation[j])) -- Green
            elseif i == 5 then
                header[j].tex:SetVertexColor(F.ConvertRGB(0, 127, 255, desaturation[j])) -- Blue
            elseif i == 6 then
                header[j].tex:SetVertexColor(F.ConvertRGB(127, 0, 255, desaturation[j])) -- Indigo
            elseif i == 7 then
                header[j].tex:SetVertexColor(F.ConvertRGB(238, 130, 238, desaturation[j])) -- Violet
            elseif i == 8 then
                header[j].tex:SetVertexColor(F.ConvertRGB(0, 255, 255, desaturation[j])) -- Cyan
            end
            header[j].tex:SetAlpha(0.555)
        end
    end

    -- combinedHeader
    layoutPreview.combinedHeader = CreateFrame("Frame", "CellLayoutPreviewCombinedHeader", layoutPreview)
    for i = 1, 40 do
        local f = layoutPreview.combinedHeader:CreateTexture(nil, "BACKGROUND")
        layoutPreview.combinedHeader[i] = f

        f:SetColorTexture(0, 0, 0)
        f:SetAlpha(0.555)

        f.tex = layoutPreview.combinedHeader:CreateTexture(nil, "ARTWORK")
        f.tex:SetTexture(Cell.vars.whiteTexture)
        f.tex:SetPoint("TOPLEFT", f, "TOPLEFT", P.Scale(1), P.Scale(-1))
        f.tex:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", P.Scale(-1), P.Scale(1))
        f.tex:SetVertexColor(F.ConvertRGB(255, 0, 0, 1 + ((1 - i) * 0.02)))
        f.tex:SetAlpha(0.555)

        f.label = layoutPreview.combinedHeader:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET_SMALL")
        f.label:SetPoint("BOTTOMRIGHT", f.tex, -2, 2)
        f.label:SetText(i)
        f.label:SetTextColor(0.5, 0.5, 0.5)
    end
end

local function UpdateLayoutPreview()
    if not layoutPreview then
        CreateLayoutPreview()
    end

    -- update layoutPreview point
    P.Size(layoutPreview, selectedLayoutTable["main"]["size"][1], selectedLayoutTable["main"]["size"][2])
    layoutPreview:ClearAllPoints()
    layoutPreviewName:ClearAllPoints()
    if CellDB["general"]["menuPosition"] == "top_bottom" then
        P.Size(layoutPreviewAnchor, 20, 10)
        if selectedLayoutTable["main"]["anchor"] == "BOTTOMLEFT" then
            layoutPreview:SetPoint("BOTTOMLEFT", layoutPreviewAnchor, "TOPLEFT", 0, 4)
            layoutPreviewName:SetPoint("LEFT", layoutPreviewAnchor, "RIGHT", 5, 0)
        elseif selectedLayoutTable["main"]["anchor"] == "BOTTOMRIGHT" then
            layoutPreview:SetPoint("BOTTOMRIGHT", layoutPreviewAnchor, "TOPRIGHT", 0, 4)
            layoutPreviewName:SetPoint("RIGHT", layoutPreviewAnchor, "LEFT", -5, 0)
        elseif selectedLayoutTable["main"]["anchor"] == "TOPLEFT" then
            layoutPreview:SetPoint("TOPLEFT", layoutPreviewAnchor, "BOTTOMLEFT", 0, -4)
            layoutPreviewName:SetPoint("LEFT", layoutPreviewAnchor, "RIGHT", 5, 0)
        elseif selectedLayoutTable["main"]["anchor"] == "TOPRIGHT" then
            layoutPreview:SetPoint("TOPRIGHT", layoutPreviewAnchor, "BOTTOMRIGHT", 0, -4)
            layoutPreviewName:SetPoint("RIGHT", layoutPreviewAnchor, "LEFT", -5, 0)
        end
    else
        P.Size(layoutPreviewAnchor, 10, 20)
        if selectedLayoutTable["main"]["anchor"] == "BOTTOMLEFT" then
            layoutPreview:SetPoint("BOTTOMLEFT", layoutPreviewAnchor, "BOTTOMRIGHT", 4, 0)
            layoutPreviewName:SetPoint("TOPLEFT", layoutPreviewAnchor, "BOTTOMLEFT", 0, -5)
        elseif selectedLayoutTable["main"]["anchor"] == "BOTTOMRIGHT" then
            layoutPreview:SetPoint("BOTTOMRIGHT", layoutPreviewAnchor, "BOTTOMLEFT", -4, 0)
            layoutPreviewName:SetPoint("TOPRIGHT", layoutPreviewAnchor, "BOTTOMRIGHT", 0, -5)
        elseif selectedLayoutTable["main"]["anchor"] == "TOPLEFT" then
            layoutPreview:SetPoint("TOPLEFT", layoutPreviewAnchor, "TOPRIGHT", 4, 0)
            layoutPreviewName:SetPoint("BOTTOMLEFT", layoutPreviewAnchor, "TOPLEFT", 0, 5)
        elseif selectedLayoutTable["main"]["anchor"] == "TOPRIGHT" then
            layoutPreview:SetPoint("TOPRIGHT", layoutPreviewAnchor, "TOPLEFT", -4, 0)
            layoutPreviewName:SetPoint("BOTTOMRIGHT", layoutPreviewAnchor, "TOPRIGHT", 0, 5)
        end
    end

    -- update layoutPreviewAnchor point
    layoutPreviewAnchor:ClearAllPoints()
    if selectedLayout == Cell.vars.currentLayout then
        layoutPreviewAnchor:SetAllPoints(Cell.frames.anchorFrame)
    else
        if not P.LoadPosition(layoutPreviewAnchor, selectedLayoutTable["main"]["position"]) then
            layoutPreviewAnchor:ClearAllPoints()
            layoutPreviewAnchor:SetPoint("TOPLEFT", CellParent, "CENTER")
        end
    end
    layoutPreviewName:SetText(L["Layout"]..": "..selectedLayout)

    -- re-arrange
    local point, anchorPoint, groupAnchorPoint, unitSpacing, groupSpacing, _, _, verticalSpacing, horizontalSpacing = F.GetRaidFramePoints(selectedLayoutTable["main"])

    if selectedLayoutTable["main"]["combineGroups"] and previewMode ~= 1 then
        -- hide separatedHeaders
        for i = 1, 8 do
            layoutPreview.separatedHeaders[i]:Hide()
        end

        -- show combinedHeader
        layoutPreview.combinedHeader:Show()
        layoutPreview.combinedHeader:ClearAllPoints()
        layoutPreview.combinedHeader:SetPoint(point)

        local maxColumns = selectedLayoutTable["main"]["maxColumns"]
        local unitsPerColumn = selectedLayoutTable["main"]["unitsPerColumn"]
        local units = maxColumns * unitsPerColumn

        -- party preview
        -- if previewMode == 1 then
        --     units = min(5, units)
        -- end

        if selectedLayoutTable["main"]["orientation"] == "vertical" then
            layoutPreview.combinedHeader:SetSize(
                P.Scale(selectedLayoutTable["main"]["size"][1]) * maxColumns + abs(groupSpacing) * (maxColumns - 1),
                P.Scale(selectedLayoutTable["main"]["size"][2]) * unitsPerColumn + abs(unitSpacing) * (unitsPerColumn - 1))

            for i = 1, min(40, units) do
                local header = layoutPreview.combinedHeader
                header[i]:ClearAllPoints()

                if i == 1 then
                    header[i]:SetPoint(point)
                elseif i % selectedLayoutTable["main"]["unitsPerColumn"] == 1 then
                    header[i]:SetPoint(point, header[i-selectedLayoutTable["main"]["unitsPerColumn"]], groupAnchorPoint, groupSpacing, 0)
                else
                    header[i]:SetPoint(point, header[i-1], anchorPoint, 0, unitSpacing)
                end
            end
        else
            layoutPreview.combinedHeader:SetSize(
                P.Scale(selectedLayoutTable["main"]["size"][1]) * unitsPerColumn + abs(unitSpacing) * (unitsPerColumn - 1),
                P.Scale(selectedLayoutTable["main"]["size"][2]) * maxColumns + abs(groupSpacing) * (maxColumns - 1))

            for i = 1, min(40, units) do
                local header = layoutPreview.combinedHeader
                header[i]:ClearAllPoints()

                if i == 1 then
                    header[i]:SetPoint(point)
                elseif i % selectedLayoutTable["main"]["unitsPerColumn"] == 1 then
                    header[i]:SetPoint(point, header[i-selectedLayoutTable["main"]["unitsPerColumn"]], groupAnchorPoint, 0, groupSpacing)
                else
                    header[i]:SetPoint(point, header[i-1], anchorPoint, unitSpacing, 0)
                end
            end
        end

        -- hide unused
        for i = 1, 40 do
            P.Size(layoutPreview.combinedHeader[i], selectedLayoutTable["main"]["size"][1], selectedLayoutTable["main"]["size"][2])
            if i > units then
                layoutPreview.combinedHeader[i]:Hide()
                layoutPreview.combinedHeader[i].tex:Hide()
                layoutPreview.combinedHeader[i].label:Hide()
            else
                layoutPreview.combinedHeader[i]:Show()
                layoutPreview.combinedHeader[i].tex:Show()
                layoutPreview.combinedHeader[i].label:Show()
            end
        end

    else
        -- update group filter
        if previewMode ~= 1 then
            for i = 1, 8 do
                if selectedLayoutTable["groupFilter"][i] then
                    layoutPreview.separatedHeaders[i]:Show()
                else
                    layoutPreview.separatedHeaders[i]:Hide()
                end
            end
        else -- party
            layoutPreview.separatedHeaders[1]:Show()
            for i = 2, 8 do
                layoutPreview.separatedHeaders[i]:Hide()
            end
        end
        layoutPreview.combinedHeader:Hide()

        local shownGroups = {}
        for i, isShown in ipairs(selectedLayoutTable["groupFilter"]) do
            if isShown then
                tinsert(shownGroups, i)
            end
        end

        for i, group in ipairs(shownGroups) do
            local header = layoutPreview.separatedHeaders[group]
            header:ClearAllPoints()

            if selectedLayoutTable["main"]["orientation"] == "vertical" then
                header:SetSize(P.Scale(selectedLayoutTable["main"]["size"][1]), P.Scale(selectedLayoutTable["main"]["size"][2]) * 5 + abs(unitSpacing) * 4)
                for j = 1, 5 do
                    P.Size(header[j], selectedLayoutTable["main"]["size"][1], selectedLayoutTable["main"]["size"][2])
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
                    local headersPerRow = selectedLayoutTable["main"]["maxColumns"]
                    local headerCol = i % headersPerRow
                    headerCol = headerCol == 0 and headersPerRow or headerCol

                    if headerCol == 1 then -- first column on each row
                        header:SetPoint(point, layoutPreview.separatedHeaders[shownGroups[i-headersPerRow]], 0, verticalSpacing)
                    else
                        header:SetPoint(point, layoutPreview.separatedHeaders[shownGroups[i-1]], groupAnchorPoint, groupSpacing, 0)
                    end
                end
            else
                header:SetSize(P.Scale(selectedLayoutTable["main"]["size"][1]) * 5 + abs(unitSpacing) * 4, P.Scale(selectedLayoutTable["main"]["size"][2]))
                for j = 1, 5 do
                    P.Size(header[j], selectedLayoutTable["main"]["size"][1], selectedLayoutTable["main"]["size"][2])
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
                    local headersPerCol = selectedLayoutTable["main"]["maxColumns"]
                    local headerRow = i % headersPerCol
                    headerRow = headerRow == 0 and headersPerCol or headerRow

                    if headerRow == 1 then -- first row on each column
                        header:SetPoint(point, layoutPreview.separatedHeaders[shownGroups[i-headersPerCol]], horizontalSpacing, 0)
                    else
                        header:SetPoint(point, layoutPreview.separatedHeaders[shownGroups[i-1]], groupAnchorPoint, 0, groupSpacing)
                    end
                end
            end
        end
    end

    if not layoutPreview:IsShown() then
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
local npcPreview, npcPreviewAnchor, npcPreviewName
local function CreateNPCPreview()
    npcPreview = Cell.CreateFrame("CellNPCPreviewFrame", Cell.frames.mainFrame, nil, nil, true)
    npcPreview:EnableMouse(false)
    npcPreview:SetFrameStrata("HIGH")
    npcPreview:SetToplevel(true)
    npcPreview:Hide()

    npcPreviewAnchor = CreateFrame("Frame", "CellNPCPreviewAnchorFrame", npcPreview, "BackdropTemplate")
    P.Size(npcPreviewAnchor, 20, 10)
    npcPreviewAnchor:SetMovable(true)
    npcPreviewAnchor:EnableMouse(true)
    npcPreviewAnchor:RegisterForDrag("LeftButton")
    npcPreviewAnchor:SetClampedToScreen(true)
    Cell.StylizeFrame(npcPreviewAnchor, {0, 1, 0, 0.4})
    npcPreviewAnchor:Hide()
    npcPreviewAnchor:SetScript("OnDragStart", function()
        npcPreviewAnchor:StartMoving()
        npcPreviewAnchor:SetUserPlaced(false)
    end)
    npcPreviewAnchor:SetScript("OnDragStop", function()
        npcPreviewAnchor:StopMovingOrSizing()
        P.SavePosition(npcPreviewAnchor, selectedLayoutTable["npc"]["position"])
    end)

    npcPreviewName = npcPreviewAnchor:CreateFontString(nil, "OVERLAY", "CELL_FONT_CLASS_TITLE")

    npcPreview.fadeIn = npcPreview:CreateAnimationGroup()
    local fadeIn = npcPreview.fadeIn:CreateAnimation("alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(0.5)
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

    npcPreview.header = CreateFrame("Frame", "CellNPCPreviewFrameHeader", npcPreview)
    for i = 1, 5 do
        npcPreview.header[i] = npcPreview.header:CreateTexture(nil, "BACKGROUND")
        npcPreview.header[i]:SetColorTexture(0, 0, 0)
        npcPreview.header[i]:SetAlpha(0.555)

        npcPreview.header[i].tex = npcPreview.header:CreateTexture(nil, "ARTWORK")
        npcPreview.header[i].tex:SetTexture(Cell.vars.whiteTexture)

        npcPreview.header[i].tex:SetPoint("TOPLEFT", npcPreview.header[i], "TOPLEFT", P.Scale(1), P.Scale(-1))
        npcPreview.header[i].tex:SetPoint("BOTTOMRIGHT", npcPreview.header[i], "BOTTOMRIGHT", P.Scale(-1), P.Scale(1))

        npcPreview.header[i].tex:SetVertexColor(F.ConvertRGB(255, 255, 255, desaturation[i])) -- White
        npcPreview.header[i].tex:SetAlpha(0.555)
    end
end

local function UpdateNPCPreview()
    if not npcPreview then
        CreateNPCPreview()
    end

    if not selectedLayoutTable["npc"]["enabled"] or not selectedLayoutTable["npc"]["separate"] then
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

    -- size
    local width, height
    if selectedLayoutTable["npc"]["sameSizeAsMain"] then
        width, height = unpack(selectedLayoutTable["main"]["size"])
    else
        width, height = unpack(selectedLayoutTable["npc"]["size"])
    end
    P.Size(npcPreview, width, height)

    -- arrangement
    local orientation, anchor, spacingX, spacingY
    if selectedLayoutTable["npc"]["sameArrangementAsMain"] then
        orientation = selectedLayoutTable["main"]["orientation"]
        anchor = selectedLayoutTable["main"]["anchor"]
        spacingX = selectedLayoutTable["main"]["spacingX"]
        spacingY = selectedLayoutTable["main"]["spacingY"]
    else
        orientation = selectedLayoutTable["npc"]["orientation"]
        anchor = selectedLayoutTable["npc"]["anchor"]
        spacingX = selectedLayoutTable["npc"]["spacingX"]
        spacingY = selectedLayoutTable["npc"]["spacingY"]
    end

    -- update npcPreview point
    npcPreview:ClearAllPoints()
    npcPreviewName:ClearAllPoints()

    if CellDB["general"]["menuPosition"] == "top_bottom" then
        P.Size(npcPreviewAnchor, 20, 10)
        if anchor == "BOTTOMLEFT" then
            npcPreview:SetPoint("BOTTOMLEFT", npcPreviewAnchor, "TOPLEFT", 0, 4)
            npcPreviewName:SetPoint("LEFT", npcPreviewAnchor, "RIGHT", 5, 0)
        elseif anchor == "BOTTOMRIGHT" then
            npcPreview:SetPoint("BOTTOMRIGHT", npcPreviewAnchor, "TOPRIGHT", 0, 4)
            npcPreviewName:SetPoint("RIGHT", npcPreviewAnchor, "LEFT", -5, 0)
        elseif anchor == "TOPLEFT" then
            npcPreview:SetPoint("TOPLEFT", npcPreviewAnchor, "BOTTOMLEFT", 0, -4)
            npcPreviewName:SetPoint("LEFT", npcPreviewAnchor, "RIGHT", 5, 0)
        elseif anchor == "TOPRIGHT" then
            npcPreview:SetPoint("TOPRIGHT", npcPreviewAnchor, "BOTTOMRIGHT", 0, -4)
            npcPreviewName:SetPoint("RIGHT", npcPreviewAnchor, "LEFT", -5, 0)
        end
    else
        P.Size(npcPreviewAnchor, 10, 20)
        if anchor == "BOTTOMLEFT" then
            npcPreview:SetPoint("BOTTOMLEFT", npcPreviewAnchor, "BOTTOMRIGHT", 4, 0)
            npcPreviewName:SetPoint("TOPLEFT", npcPreviewAnchor, "BOTTOMLEFT", 0, -5)
        elseif anchor == "BOTTOMRIGHT" then
            npcPreview:SetPoint("BOTTOMRIGHT", npcPreviewAnchor, "BOTTOMLEFT", -4, 0)
            npcPreviewName:SetPoint("TOPRIGHT", npcPreviewAnchor, "BOTTOMRIGHT", 0, -5)
        elseif anchor == "TOPLEFT" then
            npcPreview:SetPoint("TOPLEFT", npcPreviewAnchor, "TOPRIGHT", 4, 0)
            npcPreviewName:SetPoint("BOTTOMLEFT", npcPreviewAnchor, "TOPLEFT", 0, 5)
        elseif anchor == "TOPRIGHT" then
            npcPreview:SetPoint("TOPRIGHT", npcPreviewAnchor, "TOPLEFT", -4, 0)
            npcPreviewName:SetPoint("BOTTOMRIGHT", npcPreviewAnchor, "TOPRIGHT", 0, 5)
        end
    end

    -- update npcAnchor point
    if selectedLayout == Cell.vars.currentLayout then
        -- NOTE: move separate npc anchor with preview
        Cell.frames.separateNpcFrameAnchor:SetAllPoints(npcPreviewAnchor)
    else
        P.LoadPosition(Cell.frames.separateNpcFrameAnchor, Cell.vars.currentLayoutTable["npc"]["position"])
    end

    if not P.LoadPosition(npcPreviewAnchor, selectedLayoutTable["npc"]["position"]) then
        npcPreviewAnchor:ClearAllPoints()
        npcPreviewAnchor:SetPoint("TOPLEFT", CellParent, "CENTER")
    end
    npcPreviewAnchor:Show()
    npcPreviewName:SetText(L["Layout"]..": "..selectedLayout.." (NPC)")
    npcPreviewName:Show()

    -- re-arrange
    local header = npcPreview.header
    header:ClearAllPoints()

    if orientation == "vertical" then
        -- anchor
        local point, anchorPoint, unitSpacing
        if anchor == "BOTTOMLEFT" then
            point, anchorPoint = "BOTTOMLEFT", "TOPLEFT"
            unitSpacing = spacingY
        elseif anchor == "BOTTOMRIGHT" then
            point, anchorPoint = "BOTTOMRIGHT", "TOPRIGHT"
            unitSpacing = spacingY
        elseif anchor == "TOPLEFT" then
            point, anchorPoint = "TOPLEFT", "BOTTOMLEFT"
            unitSpacing = -spacingY
        elseif anchor == "TOPRIGHT" then
            point, anchorPoint = "TOPRIGHT", "BOTTOMRIGHT"
            unitSpacing = -spacingY
        end

        header:SetSize(P.Scale(width), P.Scale(height) * 5 + abs(P.Scale(unitSpacing)) * 4)
        header:SetPoint(point)

        for i = 1, 5 do
            P.Size(header[i], width, height)
            header[i]:ClearAllPoints()

            if i == 1 then
                header[i]:SetPoint(point)
            else
                header[i]:SetPoint(point, header[i-1], anchorPoint, 0, P.Scale(unitSpacing))
            end
        end
    else
        -- anchor
        local point, anchorPoint, unitSpacing
        if anchor == "BOTTOMLEFT" then
            point, anchorPoint = "BOTTOMLEFT", "BOTTOMRIGHT"
            unitSpacing = spacingX
        elseif anchor == "BOTTOMRIGHT" then
            point, anchorPoint = "BOTTOMRIGHT", "BOTTOMLEFT"
            unitSpacing = -spacingX
        elseif anchor == "TOPLEFT" then
            point, anchorPoint = "TOPLEFT", "TOPRIGHT"
            unitSpacing = spacingX
        elseif anchor == "TOPRIGHT" then
            point, anchorPoint = "TOPRIGHT", "TOPLEFT"
            unitSpacing = -spacingX
        end

        header:SetSize(P.Scale(width) * 5 + abs(P.Scale(unitSpacing)) * 4, P.Scale(height))
        header:SetPoint(point)

        for i = 1, 5 do
            P.Size(header[i], width, height)
            header[i]:ClearAllPoints()

            if i == 1 then
                header[i]:SetPoint(point)
            else
                header[i]:SetPoint(point, header[i-1], anchorPoint, P.Scale(unitSpacing), 0)
            end
        end
    end

    if not npcPreview:IsShown() then
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
-- pet preview
-------------------------------------------------
local petPreview, petPreviewAnchor, petPreviewName
local petNums = Cell.isRetail and 20 or 25
local function CreatePetPreview()
    petPreview = Cell.CreateFrame("CellPetPreviewFrame", Cell.frames.mainFrame, nil, nil, true)
    petPreview:EnableMouse(false)
    petPreview:SetFrameStrata("HIGH")
    petPreview:SetToplevel(true)
    petPreview:Hide()

    petPreviewAnchor = CreateFrame("Frame", "CellPetPreviewAnchorFrame", petPreview, "BackdropTemplate")
    P.Size(petPreviewAnchor, 20, 10)
    petPreviewAnchor:SetMovable(true)
    petPreviewAnchor:EnableMouse(true)
    petPreviewAnchor:RegisterForDrag("LeftButton")
    petPreviewAnchor:SetClampedToScreen(true)
    Cell.StylizeFrame(petPreviewAnchor, {0, 1, 0, 0.4})
    petPreviewAnchor:Hide()
    petPreviewAnchor:SetScript("OnDragStart", function()
        petPreviewAnchor:StartMoving()
        petPreviewAnchor:SetUserPlaced(false)
    end)
    petPreviewAnchor:SetScript("OnDragStop", function()
        petPreviewAnchor:StopMovingOrSizing()
        P.SavePosition(petPreviewAnchor, selectedLayoutTable["pet"]["position"])
    end)

    petPreviewName = petPreviewAnchor:CreateFontString(nil, "OVERLAY", "CELL_FONT_CLASS_TITLE")

    petPreview.fadeIn = petPreview:CreateAnimationGroup()
    local fadeIn = petPreview.fadeIn:CreateAnimation("alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(0.5)
    fadeIn:SetSmoothing("OUT")
    fadeIn:SetScript("OnPlay", function()
        petPreview:Show()
    end)

    petPreview.fadeOut = petPreview:CreateAnimationGroup()
    local fadeOut = petPreview.fadeOut:CreateAnimation("alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.5)
    fadeOut:SetSmoothing("IN")
    fadeOut:SetScript("OnFinished", function()
        petPreview:Hide()
    end)

    petPreview.header = CreateFrame("Frame", "CellPetPreviewFrameHeader", petPreview)

    for i = 1, petNums do
        petPreview.header[i] = petPreview.header:CreateTexture(nil, "BACKGROUND")
        petPreview.header[i]:SetColorTexture(0, 0, 0)
        petPreview.header[i]:SetAlpha(0.555)

        petPreview.header[i].tex = petPreview.header:CreateTexture(nil, "ARTWORK")
        petPreview.header[i].tex:SetTexture(Cell.vars.whiteTexture)

        petPreview.header[i].tex:SetPoint("TOPLEFT", petPreview.header[i], "TOPLEFT", P.Scale(1), P.Scale(-1))
        petPreview.header[i].tex:SetPoint("BOTTOMRIGHT", petPreview.header[i], "BOTTOMRIGHT", P.Scale(-1), P.Scale(1))

        petPreview.header[i].tex:SetVertexColor(F.ConvertRGB(127, 127, 255, desaturation[i%5==0 and 5 or i%5]))
        petPreview.header[i].tex:SetAlpha(0.555)
    end
end

local function UpdatePetPreview()
    if not petPreview then
        CreatePetPreview()
    end

    if (not (selectedLayoutTable["pet"]["partyEnabled"] and selectedLayoutTable["pet"]["partyDetached"]) and not selectedLayoutTable["pet"]["raidEnabled"])
    or ((previewMode == 1) and not (selectedLayoutTable["pet"]["partyEnabled"] and selectedLayoutTable["pet"]["partyDetached"]))
    or ((previewMode == 2) and not selectedLayoutTable["pet"]["raidEnabled"]) then
        if petPreview.timer then
            petPreview.timer:Cancel()
            petPreview.timer = nil
        end
        if petPreview.fadeIn:IsPlaying() then
            petPreview.fadeIn:Stop()
        end
        if not petPreview.fadeOut:IsPlaying() then
            petPreview.fadeOut:Play()
        end
        return
    end

    -- size
    local width, height
    if selectedLayoutTable["pet"]["sameSizeAsMain"] then
        width, height = unpack(selectedLayoutTable["main"]["size"])
    else
        width, height = unpack(selectedLayoutTable["pet"]["size"])
    end
    P.Size(petPreview, width, height)

    -- arrangement
    local orientation, anchor, spacingX, spacingY
    if selectedLayoutTable["pet"]["sameArrangementAsMain"] then
        orientation = selectedLayoutTable["main"]["orientation"]
        anchor = selectedLayoutTable["main"]["anchor"]
        spacingX = selectedLayoutTable["main"]["spacingX"]
        spacingY = selectedLayoutTable["main"]["spacingY"]
    else
        orientation = selectedLayoutTable["pet"]["orientation"]
        anchor = selectedLayoutTable["pet"]["anchor"]
        spacingX = selectedLayoutTable["pet"]["spacingX"]
        spacingY = selectedLayoutTable["pet"]["spacingY"]
    end

    -- update petPreview point
    petPreview:ClearAllPoints()
    petPreviewName:ClearAllPoints()

    if CellDB["general"]["menuPosition"] == "top_bottom" then
        P.Size(petPreviewAnchor, 20, 10)
        if anchor == "BOTTOMLEFT" then
            petPreview:SetPoint("BOTTOMLEFT", petPreviewAnchor, "TOPLEFT", 0, 4)
            petPreviewName:SetPoint("LEFT", petPreviewAnchor, "RIGHT", 5, 0)
        elseif anchor == "BOTTOMRIGHT" then
            petPreview:SetPoint("BOTTOMRIGHT", petPreviewAnchor, "TOPRIGHT", 0, 4)
            petPreviewName:SetPoint("RIGHT", petPreviewAnchor, "LEFT", -5, 0)
        elseif anchor == "TOPLEFT" then
            petPreview:SetPoint("TOPLEFT", petPreviewAnchor, "BOTTOMLEFT", 0, -4)
            petPreviewName:SetPoint("LEFT", petPreviewAnchor, "RIGHT", 5, 0)
        elseif anchor == "TOPRIGHT" then
            petPreview:SetPoint("TOPRIGHT", petPreviewAnchor, "BOTTOMRIGHT", 0, -4)
            petPreviewName:SetPoint("RIGHT", petPreviewAnchor, "LEFT", -5, 0)
        end
    else
        P.Size(petPreviewAnchor, 10, 20)
        if anchor == "BOTTOMLEFT" then
            petPreview:SetPoint("BOTTOMLEFT", petPreviewAnchor, "BOTTOMRIGHT", 4, 0)
            petPreviewName:SetPoint("TOPLEFT", petPreviewAnchor, "BOTTOMLEFT", 0, -5)
        elseif anchor == "BOTTOMRIGHT" then
            petPreview:SetPoint("BOTTOMRIGHT", petPreviewAnchor, "BOTTOMLEFT", -4, 0)
            petPreviewName:SetPoint("TOPRIGHT", petPreviewAnchor, "BOTTOMRIGHT", 0, -5)
        elseif anchor == "TOPLEFT" then
            petPreview:SetPoint("TOPLEFT", petPreviewAnchor, "TOPRIGHT", 4, 0)
            petPreviewName:SetPoint("BOTTOMLEFT", petPreviewAnchor, "TOPLEFT", 0, 5)
        elseif anchor == "TOPRIGHT" then
            petPreview:SetPoint("TOPRIGHT", petPreviewAnchor, "TOPLEFT", -4, 0)
            petPreviewName:SetPoint("BOTTOMRIGHT", petPreviewAnchor, "TOPRIGHT", 0, 5)
        end
    end

    -- update anchor point
    if selectedLayout == Cell.vars.currentLayout then
        -- NOTE: move anchor with preview
        CellPetAnchorFrame:SetAllPoints(petPreviewAnchor)
    else
        P.LoadPosition(CellPetAnchorFrame, Cell.vars.currentLayoutTable["pet"]["position"])
    end

    if not P.LoadPosition(petPreviewAnchor, selectedLayoutTable["pet"]["position"]) then
        petPreviewAnchor:ClearAllPoints()
        petPreviewAnchor:SetPoint("TOPLEFT", CellParent, "CENTER")
    end
    petPreviewAnchor:Show()
    petPreviewName:SetText(L["Layout"]..": "..selectedLayout.." ("..L["Pets"]..")")
    petPreviewName:Show()

    -- re-arrange
    local header = petPreview.header
    header:ClearAllPoints()

    if orientation == "vertical" then
        -- anchor
        local point, anchorPoint, groupAnchorPoint, unitSpacing, groupSpacing
        if anchor == "BOTTOMLEFT" then
            point, anchorPoint, groupAnchorPoint = "BOTTOMLEFT", "TOPLEFT", "BOTTOMRIGHT"
            unitSpacing = spacingY
            groupSpacing = spacingX
        elseif anchor == "BOTTOMRIGHT" then
            point, anchorPoint, groupAnchorPoint = "BOTTOMRIGHT", "TOPRIGHT", "BOTTOMLEFT"
            unitSpacing = spacingY
            groupSpacing = -spacingX
        elseif anchor == "TOPLEFT" then
            point, anchorPoint, groupAnchorPoint = "TOPLEFT", "BOTTOMLEFT", "TOPRIGHT"
            unitSpacing = -spacingY
            groupSpacing = spacingX
        elseif anchor == "TOPRIGHT" then
            point, anchorPoint, groupAnchorPoint = "TOPRIGHT", "BOTTOMRIGHT", "TOPLEFT"
            unitSpacing = -spacingY
            groupSpacing = -spacingX
        end

        header:SetSize(P.Scale(width) * 4 + abs(P.Scale(unitSpacing)) * 3, P.Scale(height) * 5 + abs(P.Scale(unitSpacing))*4)
        header:SetPoint(point)

        for i = 1, petNums do
            P.Size(header[i], width, height)
            header[i]:ClearAllPoints()

            if i == 1 then
                header[i]:SetPoint(point)
            elseif i % 5 == 1 then
                header[i]:SetPoint(point, header[i-5], groupAnchorPoint, P.Scale(groupSpacing), 0)
            else
                header[i]:SetPoint(point, header[i-1], anchorPoint, 0, P.Scale(unitSpacing))
            end
        end
    else
        -- anchor
        local point, anchorPoint, groupAnchorPoint, unitSpacing, groupSpacing
            if anchor == "BOTTOMLEFT" then
                point, anchorPoint, groupAnchorPoint = "BOTTOMLEFT", "BOTTOMRIGHT", "TOPLEFT"
                unitSpacing = spacingX
                groupSpacing = spacingY
            elseif anchor == "BOTTOMRIGHT" then
                point, anchorPoint, groupAnchorPoint = "BOTTOMRIGHT", "BOTTOMLEFT", "TOPRIGHT"
                unitSpacing = -spacingX
                groupSpacing = spacingY
            elseif anchor == "TOPLEFT" then
                point, anchorPoint, groupAnchorPoint = "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT"
                unitSpacing = spacingX
                groupSpacing = -spacingY
            elseif anchor == "TOPRIGHT" then
                point, anchorPoint, groupAnchorPoint = "TOPRIGHT", "TOPLEFT", "BOTTOMRIGHT"
                unitSpacing = -spacingX
                groupSpacing = -spacingY
            end

        header:SetSize(P.Scale(width) * 5 + abs(P.Scale(unitSpacing)) * 4, P.Scale(height) * 4 + abs(P.Scale(unitSpacing)) * 3)
        header:SetPoint(point)

        for i = 1, petNums do
            P.Size(header[i], width, height)
            header[i]:ClearAllPoints()

            if i == 1 then
                header[i]:SetPoint(point)
            elseif i % 5 == 1 then
                header[i]:SetPoint(point, header[i-5], groupAnchorPoint, 0, P.Scale(groupSpacing))
            else
                header[i]:SetPoint(point, header[i-1], anchorPoint, P.Scale(unitSpacing), 0)
            end
        end
    end

    for i = 6, petNums do
        if previewMode == 0 then
            if selectedLayoutTable["pet"]["raidEnabled"] then
                header[i]:Show()
                header[i].tex:Show()
            else
                header[i]:Hide()
                header[i].tex:Hide()
            end
        elseif previewMode == 1 then
            header[i]:Hide()
            header[i].tex:Hide()
        else
            header[i]:Show()
            header[i].tex:Show()
        end
    end

    if not petPreview:IsShown() then
        petPreview.fadeIn:Play()
    end

    if petPreview.fadeOut:IsPlaying() then
        petPreview.fadeOut:Stop()
    end

    if petPreview.timer then
        petPreview.timer:Cancel()
    end

    if previewMode == 0 then
        petPreview.timer = C_Timer.NewTimer(1, function()
            petPreview.fadeOut:Play()
            petPreview.timer = nil
        end)
    end
end

-------------------------------------------------
-- spotlight preview
-------------------------------------------------
local spotlightPreview, spotlightPreviewAnchor, spotlightPreviewName
local function CreateSpotlightPreview()
    spotlightPreview = Cell.CreateFrame("CellSpotlightPreviewFrame", Cell.frames.mainFrame, nil, nil, true)
    spotlightPreview:EnableMouse(false)
    spotlightPreview:SetFrameStrata("HIGH")
    spotlightPreview:SetToplevel(true)
    spotlightPreview:Hide()

    spotlightPreviewAnchor = CreateFrame("Frame", "CellSpotlightPreviewAnchorFrame", spotlightPreview, "BackdropTemplate")
    P.Size(spotlightPreviewAnchor, 20, 10)
    spotlightPreviewAnchor:SetMovable(true)
    spotlightPreviewAnchor:EnableMouse(true)
    spotlightPreviewAnchor:RegisterForDrag("LeftButton")
    spotlightPreviewAnchor:SetClampedToScreen(true)
    Cell.StylizeFrame(spotlightPreviewAnchor, {0, 1, 0, 0.4})
    spotlightPreviewAnchor:Hide()
    spotlightPreviewAnchor:SetScript("OnDragStart", function()
        spotlightPreviewAnchor:StartMoving()
        spotlightPreviewAnchor:SetUserPlaced(false)
    end)
    spotlightPreviewAnchor:SetScript("OnDragStop", function()
        spotlightPreviewAnchor:StopMovingOrSizing()
        P.SavePosition(spotlightPreviewAnchor, selectedLayoutTable["spotlight"]["position"])
    end)

    spotlightPreviewName = spotlightPreviewAnchor:CreateFontString(nil, "OVERLAY", "CELL_FONT_CLASS_TITLE")

    spotlightPreview.fadeIn = spotlightPreview:CreateAnimationGroup()
    local fadeIn = spotlightPreview.fadeIn:CreateAnimation("alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(0.5)
    fadeIn:SetSmoothing("OUT")
    fadeIn:SetScript("OnPlay", function()
        spotlightPreview:Show()
    end)

    spotlightPreview.fadeOut = spotlightPreview:CreateAnimationGroup()
    local fadeOut = spotlightPreview.fadeOut:CreateAnimation("alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.5)
    fadeOut:SetSmoothing("IN")
    fadeOut:SetScript("OnFinished", function()
        spotlightPreview:Hide()
    end)

    spotlightPreview.header = CreateFrame("Frame", "CellSpotlightPreviewFrameHeader", spotlightPreview)
    for i = 1, 15 do
        spotlightPreview.header[i] = spotlightPreview.header:CreateTexture(nil, "BACKGROUND")
        spotlightPreview.header[i]:SetColorTexture(0, 0, 0)
        spotlightPreview.header[i]:SetAlpha(0.555)

        spotlightPreview.header[i].tex = spotlightPreview.header:CreateTexture(nil, "ARTWORK")
        spotlightPreview.header[i].tex:SetTexture(Cell.vars.whiteTexture)

        spotlightPreview.header[i].tex:SetPoint("TOPLEFT", spotlightPreview.header[i], "TOPLEFT", P.Scale(1), P.Scale(-1))
        spotlightPreview.header[i].tex:SetPoint("BOTTOMRIGHT", spotlightPreview.header[i], "BOTTOMRIGHT", P.Scale(-1), P.Scale(1))

        spotlightPreview.header[i].tex:SetVertexColor(F.ConvertRGB(255, 0, 102, i % 5 == 0 and desaturation[5] or desaturation[i-floor(i/5)*5]))
        spotlightPreview.header[i].tex:SetAlpha(0.555)
    end
end

local function UpdateSpotlightPreview()
    if not spotlightPreview then
        CreateSpotlightPreview()
    end

    if not selectedLayoutTable["spotlight"]["enabled"] then
        if spotlightPreview.timer then
            spotlightPreview.timer:Cancel()
            spotlightPreview.timer = nil
        end
        if spotlightPreview.fadeIn:IsPlaying() then
            spotlightPreview.fadeIn:Stop()
        end
        if not spotlightPreview.fadeOut:IsPlaying() then
            spotlightPreview.fadeOut:Play()
        end
        return
    end

    -- size
    local width, height
    if selectedLayoutTable["spotlight"]["sameSizeAsMain"] then
        width, height = unpack(selectedLayoutTable["main"]["size"])
    else
        width, height = unpack(selectedLayoutTable["spotlight"]["size"])
    end

    -- arrangement
    local orientation, anchor, spacingX, spacingY
    if selectedLayoutTable["spotlight"]["sameArrangementAsMain"] then
        orientation = selectedLayoutTable["main"]["orientation"]
        anchor = selectedLayoutTable["main"]["anchor"]
        spacingX = selectedLayoutTable["main"]["spacingX"]
        spacingY = selectedLayoutTable["main"]["spacingY"]
    else
        orientation = selectedLayoutTable["spotlight"]["orientation"]
        anchor = selectedLayoutTable["spotlight"]["anchor"]
        spacingX = selectedLayoutTable["spotlight"]["spacingX"]
        spacingY = selectedLayoutTable["spotlight"]["spacingY"]
    end

    -- update spotlightPreview point
    P.Size(spotlightPreview, width, height)
    spotlightPreview:ClearAllPoints()
    spotlightPreviewName:ClearAllPoints()

    if CellDB["general"]["menuPosition"] == "top_bottom" then
        P.Size(spotlightPreviewAnchor, 20, 10)
        if anchor == "BOTTOMLEFT" then
            spotlightPreview:SetPoint("BOTTOMLEFT", spotlightPreviewAnchor, "TOPLEFT", 0, 4)
            spotlightPreviewName:SetPoint("LEFT", spotlightPreviewAnchor, "RIGHT", 5, 0)
        elseif anchor == "BOTTOMRIGHT" then
            spotlightPreview:SetPoint("BOTTOMRIGHT", spotlightPreviewAnchor, "TOPRIGHT", 0, 4)
            spotlightPreviewName:SetPoint("RIGHT", spotlightPreviewAnchor, "LEFT", -5, 0)
        elseif anchor == "TOPLEFT" then
            spotlightPreview:SetPoint("TOPLEFT", spotlightPreviewAnchor, "BOTTOMLEFT", 0, -4)
            spotlightPreviewName:SetPoint("LEFT", spotlightPreviewAnchor, "RIGHT", 5, 0)
        elseif anchor == "TOPRIGHT" then
            spotlightPreview:SetPoint("TOPRIGHT", spotlightPreviewAnchor, "BOTTOMRIGHT", 0, -4)
            spotlightPreviewName:SetPoint("RIGHT", spotlightPreviewAnchor, "LEFT", -5, 0)
        end
    else
        P.Size(spotlightPreviewAnchor, 10, 20)
        if anchor == "BOTTOMLEFT" then
            spotlightPreview:SetPoint("BOTTOMLEFT", spotlightPreviewAnchor, "BOTTOMRIGHT", 4, 0)
            spotlightPreviewName:SetPoint("TOPLEFT", spotlightPreviewAnchor, "BOTTOMLEFT", 0, -5)
        elseif anchor == "BOTTOMRIGHT" then
            spotlightPreview:SetPoint("BOTTOMRIGHT", spotlightPreviewAnchor, "BOTTOMLEFT", -4, 0)
            spotlightPreviewName:SetPoint("TOPRIGHT", spotlightPreviewAnchor, "BOTTOMRIGHT", 0, -5)
        elseif anchor == "TOPLEFT" then
            spotlightPreview:SetPoint("TOPLEFT", spotlightPreviewAnchor, "TOPRIGHT", 4, 0)
            spotlightPreviewName:SetPoint("BOTTOMLEFT", spotlightPreviewAnchor, "TOPLEFT", 0, 5)
        elseif anchor == "TOPRIGHT" then
            spotlightPreview:SetPoint("TOPRIGHT", spotlightPreviewAnchor, "TOPLEFT", -4, 0)
            spotlightPreviewName:SetPoint("BOTTOMRIGHT", spotlightPreviewAnchor, "TOPRIGHT", 0, 5)
        end
    end

    -- update preview anchor
    spotlightPreviewAnchor:ClearAllPoints()
    if selectedLayout == Cell.vars.currentLayout then
        spotlightPreviewAnchor:EnableMouse(false)
        spotlightPreviewAnchor:SetAllPoints(Cell.frames.spotlightFrameAnchor)
    else
        spotlightPreviewAnchor:EnableMouse(true)
        if not P.LoadPosition(spotlightPreviewAnchor, selectedLayoutTable["spotlight"]["position"]) then
            spotlightPreviewAnchor:SetPoint("TOPLEFT", CellParent, "CENTER")
        end
    end
    spotlightPreviewAnchor:Show()
    spotlightPreviewName:SetText(L["Layout"]..": "..selectedLayout.." ("..L["Spotlight Frame"]..")")
    spotlightPreviewName:Show()

    -- re-arrange
    local header = spotlightPreview.header
    header:ClearAllPoints()

    local point, anchorPoint, groupPoint, unitSpacingX, unitSpacingY
    if strfind(orientation, "^vertical") then
        if anchor == "BOTTOMLEFT" then
            point, anchorPoint = "BOTTOMLEFT", "TOPLEFT"
            groupPoint = "BOTTOMRIGHT"
            unitSpacingX = spacingX
            unitSpacingY = spacingY
        elseif anchor == "BOTTOMRIGHT" then
            point, anchorPoint = "BOTTOMRIGHT", "TOPRIGHT"
            groupPoint = "BOTTOMLEFT"
            unitSpacingX = -spacingX
            unitSpacingY = spacingY
        elseif anchor == "TOPLEFT" then
            point, anchorPoint = "TOPLEFT", "BOTTOMLEFT"
            groupPoint = "TOPRIGHT"
            unitSpacingX = spacingX
            unitSpacingY = -spacingY
        elseif anchor == "TOPRIGHT" then
            point, anchorPoint = "TOPRIGHT", "BOTTOMRIGHT"
            groupPoint = "TOPLEFT"
            unitSpacingX = -spacingX
            unitSpacingY = -spacingY
        end
    else
        if anchor == "BOTTOMLEFT" then
            point, anchorPoint = "BOTTOMLEFT", "BOTTOMRIGHT"
            groupPoint = "TOPLEFT"
            unitSpacingX = spacingX
            unitSpacingY = spacingY
        elseif anchor == "BOTTOMRIGHT" then
            point, anchorPoint = "BOTTOMRIGHT", "BOTTOMLEFT"
            groupPoint = "TOPRIGHT"
            unitSpacingX = -spacingX
            unitSpacingY = spacingY
        elseif anchor == "TOPLEFT" then
            point, anchorPoint = "TOPLEFT", "TOPRIGHT"
            groupPoint = "BOTTOMLEFT"
            unitSpacingX = spacingX
            unitSpacingY = -spacingY
        elseif anchor == "TOPRIGHT" then
            point, anchorPoint = "TOPRIGHT", "TOPLEFT"
            groupPoint = "BOTTOMRIGHT"
            unitSpacingX = -spacingX
            unitSpacingY = -spacingY
        end
    end

    P.Size(header, width, height)
    header:SetPoint(point)

    for i = 1, 15 do
        P.Size(header[i], width, height)
        header[i]:ClearAllPoints()
        if i == 1 then
            header[i]:SetPoint(point)
        else
            if strfind(orientation, "^vertical") then
                if i % 5 == 1 and orientation == "vertical" then
                    header[i]:SetPoint(point, header[i-5], groupPoint, P.Scale(unitSpacingX), 0)
                else
                    header[i]:SetPoint(point, header[i-1], anchorPoint, 0, P.Scale(unitSpacingY))
                end
            else
                if i % 5 == 1 and orientation == "horizontal" then
                    header[i]:SetPoint(point, header[i-5], groupPoint, 0, P.Scale(unitSpacingY))
                else
                    header[i]:SetPoint(point, header[i-1], anchorPoint, P.Scale(unitSpacingX), 0)
                end
            end
        end
    end

    if not spotlightPreview:IsShown() then
        spotlightPreview.fadeIn:Play()
    end

    if spotlightPreview.fadeOut:IsPlaying() then
        spotlightPreview.fadeOut:Stop()
    end

    if spotlightPreview.timer then
        spotlightPreview.timer:Cancel()
    end

    if previewMode == 0 then
        spotlightPreview.timer = C_Timer.NewTimer(1, function()
            spotlightPreview.fadeOut:Play()
            spotlightPreview.timer = nil
        end)
    end
end

-------------------------------------------------
-- hide previews
-------------------------------------------------
local function HidePreviews()
    if not layoutPreview then
        return
    end

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

    if petPreview.timer then
        petPreview.timer:Cancel()
        petPreview.timer = nil
    end
    if petPreview.fadeIn:IsPlaying() then
        petPreview.fadeIn:Stop()
    end
    if not petPreview.fadeOut:IsPlaying() then
        petPreview.fadeOut:Play()
    end

    if spotlightPreview.timer then
        spotlightPreview.timer:Cancel()
        spotlightPreview.timer = nil
    end
    if spotlightPreview.fadeIn:IsPlaying() then
        spotlightPreview.fadeIn:Stop()
    end
    if not spotlightPreview.fadeOut:IsPlaying() then
        spotlightPreview.fadeOut:Play()
    end
end

-------------------------------------------------
-- layout
-------------------------------------------------
local autoSwitchFrame
local typeSwitch, currentProfileBox
local layoutDropdown, soloDropdown, partyDropdown, raidOutdoorDropdown, raidInstanceDropdown, raidMythicDropdown, arenaDropdown, bg15Dropdown, bg40Dropdown
local raid10Dropdown, raid25Dropdown -- wrath
local bgDropdown -- vanilla
local LoadLayoutDropdown, LoadAutoSwitchDropdowns
local LoadLayoutDB, UpdateButtonStates, LoadLayoutAutoSwitchDB

-- local enabledLayoutText
-- local function UpdateEnabledLayoutText()
--     enabledLayoutText:SetText("|cFF777777"..L["Current"]..": "..(Cell.vars.currentLayout == "default" and _G.DEFAULT or Cell.vars.currentLayout))
-- end

local function IsValidLayoutName(name)
    return name and name ~= ""
        and strlower(name) ~= "default" and name ~= _G.DEFAULT
        and strlower(name) ~= "hide"
        -- and not strfind(name, ":") and not strfind(name, "!")
        and not CellDB["layouts"][name]
end

local function CreateLayoutPane()
    local layoutPane = Cell.CreateTitledPane(layoutsTab, L["Layout"], 205, 80)
    layoutPane:SetPoint("TOPLEFT", 5, -5)

    -- enabledLayoutText = layoutPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET_TITLE")
    -- enabledLayoutText:SetPoint("BOTTOMRIGHT", layoutPane.line, "TOPRIGHT", 0, P.Scale(2))
    -- enabledLayoutText:SetPoint("LEFT", layoutPane.title, "RIGHT", 5, 0)
    -- enabledLayoutText:SetWordWrap(false)
    -- enabledLayoutText:SetJustifyH("LEFT")

    layoutDropdown = Cell.CreateDropdown(layoutPane, 193)
    layoutDropdown:SetPoint("TOPLEFT", 5, -27)

    -- new
    local newBtn = Cell.CreateButton(layoutPane, nil, "green-hover", {33, 20}, nil, nil, nil, nil, nil, L["New"])
    newBtn:SetPoint("TOPLEFT", layoutDropdown, "BOTTOMLEFT", 0, -10)
    newBtn:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\create", {16, 16}, {"CENTER", 0, 0})
    newBtn:SetScript("OnClick", function()
        local popup = Cell.CreateConfirmPopup(layoutsTab, 200, L["Create new layout"], function(self)
            local name = strtrim(self.editBox:GetText())
            local inherit = self.dropdown1:GetSelected()

            if IsValidLayoutName(name) then
                -- update db copy current layout
                if inherit == "cell-default-layout" then
                    CellDB["layouts"][name] = F.Copy(Cell.defaults.layout)
                else
                    CellDB["layouts"][name] = F.Copy(CellDB["layouts"][inherit])
                end
                -- update dropdown
                layoutDropdown:AddItem({
                    ["text"] = name,
                    ["value"] = name,
                    ["onClick"] = function()
                        LoadLayoutDB(name)
                        UpdateButtonStates()
                    end,
                })
                layoutDropdown:SetSelected(name)
                LoadAutoSwitchDropdowns()
                LoadLayoutDB(name)
                UpdateButtonStates()
                F.Print(L["Layout added: %s."]:format(name))
            else
                F.Print(L["Invalid layout name."])
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

        -- add "Inherit: default" to second
        tinsert(inherits, {
            ["text"] = L["Inherit: "] .. _G.DEFAULT,
            ["value"] = "default",
        })

        for name in pairs(CellDB["layouts"]) do
            if name ~= "default" then
                tinsert(inherits, {
                    ["text"] = L["Inherit: "] .. name,
                    ["value"] = name,
                })
            end
        end

        popup.dropdown1:SetItems(inherits)
        popup.dropdown1:SetSelectedItem(1)
    end)
    Cell.RegisterForCloseDropdown(newBtn)

    -- rename
    local renameBtn = Cell.CreateButton(layoutPane, nil, "blue-hover", {33, 20}, nil, nil, nil, nil, nil, L["Rename"])
    renameBtn:SetPoint("TOPLEFT", newBtn, "TOPRIGHT", P.Scale(-1), 0)
    renameBtn:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\rename", {16, 16}, {"CENTER", 0, 0})
    renameBtn:SetScript("OnClick", function()
        local popup = Cell.CreateConfirmPopup(layoutsTab, 200, L["Rename layout"].." "..selectedLayout, function(self)
            local name = strtrim(self.editBox:GetText())
            if IsValidLayoutName(name) then
                -- update db
                CellDB["layouts"][name] = CellDB["layouts"][selectedLayout]
                CellDB["layouts"][selectedLayout] = nil
                F.Print(L["Layout renamed: %s to %s."]:format(selectedLayout, name))

                -- update auto switch dropdowns
                LoadAutoSwitchDropdowns()
                for groupType, layout in pairs(Cell.vars.layoutAutoSwitch) do
                    if layout == selectedLayout then
                        -- NOTE: rename
                        Cell.vars.layoutAutoSwitch[groupType] = name
                        -- update its dropdown selection
                        if groupType == "party" then
                            partyDropdown:SetSelected(name)
                        elseif groupType == "raid_outdoor" then
                            raidOutdoorDropdown:SetSelected(name)
                        elseif groupType == "raid_instance" then
                            raidInstanceDropdown:SetSelected(name)
                        elseif groupType == "raid_mythic" then
                            raidMythicDropdown:SetSelected(name)
                        elseif groupType == "raid10" then
                            raid10Dropdown:SetSelected(name)
                        elseif groupType == "raid25" then
                            raid25Dropdown:SetSelected(name)
                        elseif groupType == "arena" then
                            arenaDropdown:SetSelected(name)
                        elseif groupType == "battleground15" then
                            bg15Dropdown:SetSelected(name)
                        elseif groupType == "battleground40" then
                            bg40Dropdown:SetSelected(name)
                        elseif groupType == "battleground" then
                            bgDropdown:SetSelected(name)
                        end
                    end
                end

                -- update master-slave
                for layout, t in pairs(CellDB["layouts"]) do
                    if t["syncWith"] == selectedLayout then
                        t["syncWith"] = name
                    end
                end

                -- update if current
                if selectedLayout == Cell.vars.currentLayout then
                    -- update vars
                    Cell.vars.currentLayout = name
                    Cell.vars.currentLayoutTable = CellDB["layouts"][name]
                    -- update text
                    -- UpdateEnabledLayoutText()
                end

                -- update dropdown
                layoutDropdown:SetCurrentItem({
                    ["text"] = name,
                    ["value"] = name,
                    ["onClick"] = function()
                        LoadLayoutDB(name)
                        UpdateButtonStates()
                    end,
                })
                layoutDropdown:SetSelected(name)

                -- reload
                LoadLayoutDB(name)
            else
                F.Print(L["Invalid layout name."])
            end
        end, nil, true, true)
        popup:SetPoint("TOPLEFT", 117, -97)
    end)
    Cell.RegisterForCloseDropdown(renameBtn)

    -- delete
    local deleteBtn = Cell.CreateButton(layoutPane, nil, "red-hover", {33, 20}, nil, nil, nil, nil, nil, L["Delete"])
    deleteBtn:SetPoint("TOPLEFT", renameBtn, "TOPRIGHT", P.Scale(-1), 0)
    deleteBtn:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\trash", {16, 16}, {"CENTER", 0, 0})
    deleteBtn:SetScript("OnClick", function()
        local popup = Cell.CreateConfirmPopup(layoutsTab, 200, L["Delete layout"].." "..selectedLayout.."?", function(self)
            -- update db
            CellDB["layouts"][selectedLayout] = nil
            F.Print(L["Layout deleted: %s."]:format(selectedLayout))

            -- update auto switch dropdowns
            LoadAutoSwitchDropdowns()
            for groupType, layout in pairs(Cell.vars.layoutAutoSwitch) do
                if layout == selectedLayout then
                    -- NOTE: set to default
                    Cell.vars.layoutAutoSwitch[groupType] = "default"
                    -- update its dropdown selection
                    if groupType == "party" then
                        partyDropdown:SetSelectedValue("default")
                    elseif groupType == "raid_outdoor" then
                        raidOutdoorDropdown:SetSelectedValue("default")
                    elseif groupType == "raid_instance" then
                        raidInstanceDropdown:SetSelectedValue("default")
                    elseif groupType == "raid_mythic" then
                        raidMythicDropdown:SetSelectedValue("default")
                    elseif groupType == "raid10" then
                        raid10Dropdown:SetSelectedValue("default")
                    elseif groupType == "raid25" then
                        raid25Dropdown:SetSelectedValue("default")
                    elseif groupType == "arena" then
                        arenaDropdown:SetSelectedValue("default")
                    elseif groupType == "battleground15" then
                        bg15Dropdown:SetSelectedValue("default")
                    elseif groupType == "battleground40" then
                        bg40Dropdown:SetSelectedValue("default")
                    elseif groupType == "battleground" then
                        bgDropdown:SetSelectedValue("default")
                    end
                end
            end

            -- update master-slave
            for layout, t in pairs(CellDB["layouts"]) do
                if t["syncWith"] == selectedLayout then
                    t["syncWith"] = nil
                end
            end

            -- set current to default
            if selectedLayout == Cell.vars.currentLayout then
                -- update vars
                Cell.vars.currentLayout = "default"
                Cell.vars.currentLayoutTable = CellDB["layouts"]["default"]
                Cell.Fire("UpdateLayout", "default")
                -- update text
                -- UpdateEnabledLayoutText()
            end

            -- update dropdown
            layoutDropdown:RemoveCurrentItem()
            layoutDropdown:SetSelectedValue("default")

            -- reload
            LoadLayoutDB("default")
            UpdateButtonStates()
        end, nil, true)
        popup:SetPoint("TOPLEFT", 117, -97)
    end)
    Cell.RegisterForCloseDropdown(deleteBtn)

    -- import
    local importBtn = Cell.CreateButton(layoutPane, nil, "accent-hover", {33, 20}, nil, nil, nil, nil, nil, L["Import"])
    importBtn:SetPoint("TOPLEFT", deleteBtn, "TOPRIGHT", P.Scale(-1), 0)
    importBtn:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\import", {16, 16}, {"CENTER", 0, 0})
    importBtn:SetScript("OnClick", function()
        F.ShowLayoutImportFrame()
    end)

    -- export
    local exportBtn = Cell.CreateButton(layoutPane, nil, "accent-hover", {33, 20}, nil, nil, nil, nil, nil, L["Export"])
    exportBtn:SetPoint("TOPLEFT", importBtn, "TOPRIGHT", P.Scale(-1), 0)
    exportBtn:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\export", {16, 16}, {"CENTER", 0, 0})
    exportBtn:SetScript("OnClick", function()
        F.ShowLayoutExportFrame(selectedLayout, selectedLayoutTable)
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
    local shareBtn = Cell.CreateButton(layoutPane, nil, "accent-hover", {33, 20}, nil, nil, nil, nil, nil, L["Share"])
    shareBtn:SetPoint("TOPLEFT", exportBtn, "TOPRIGHT", P.Scale(-1), 0)
    shareBtn:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\share", {16, 16}, {"CENTER", 0, 0})
    shareBtn:SetScript("OnClick", function()
        local editbox = ChatEdit_ChooseBoxForSend()
        ChatEdit_ActivateChat(editbox)
        editbox:SetText("[Cell.Layout: "..selectedLayout.." - "..Cell.vars.playerNameFull.."]")
    end)
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
            ["value"] = value,
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
local soloText, partyText, raidOutdoorText, raidInstanceText, raidMythicText
local arenaText, bg15Text, bg40Text
local raid10Text, raid25Text -- wrath
local bgText -- vanilla

local raidOutdoor = L["Raid"].." "..L["Outdoor"]
local raidInstance = L["Raid"].." ".._G.INSTANCE
local raidMythic = L["Raid"].." ".._G.PLAYER_DIFFICULTY6

local function CreateAutoSwitchPane()
    autoSwitchFrame = Cell.CreateFrame("CellLayoutAutoSwitchFrame", layoutsTab, 160, 465)
    autoSwitchFrame:SetPoint("TOPLEFT", layoutsTab, "TOPRIGHT", 5, 0)
    autoSwitchFrame:Show()

    local autoSwitchPane = Cell.CreateTitledPane(autoSwitchFrame, L["Layout Auto Switch"], 150, 400)
    autoSwitchPane:SetPoint("TOPLEFT", 5, -5)

    if Cell.isRetail then
        -- type switch
        typeSwitch = Cell.CreateSwitch(autoSwitchPane, {140, 20}, L["Role"], "role", L["Spec"], "spec", function(value)
            if value == "role" then
                CellDB["layoutAutoSwitch"][Cell.vars.playerClass][Cell.vars.playerSpecID] = nil
            else
                CellDB["layoutAutoSwitch"][Cell.vars.playerClass][Cell.vars.playerSpecID] = F.Copy(CellDB["layoutAutoSwitch"]["role"][Cell.vars.playerSpecRole])
            end
            Cell.Fire("LayoutAutoSwitchChanged")
            LoadLayoutAutoSwitchDB()
        end)
        typeSwitch:SetPoint("TOPLEFT", 5, -27)

        typeSwitch:HookScript("OnEnter", function()
            CellTooltip:SetOwner(typeSwitch, "ANCHOR_NONE")
            CellTooltip:SetPoint("TOPLEFT", typeSwitch, "TOPRIGHT", 15, 0)
            CellTooltip:AddLine(L["Layout Auto Switch"])
            CellTooltip:AddLine(L["Role"]..": |cffffffff"..strlower(L["Use common profile"]) .. " " ..
                F.GetDefaultRoleIconEscapeSequence("TANK", 12) .. " " ..
                F.GetDefaultRoleIconEscapeSequence("HEALER", 12) .. " " ..
                F.GetDefaultRoleIconEscapeSequence("DAMAGER", 12)
            )
            CellTooltip:AddLine(L["Spec"]..": |cffffffff"..L["use separate profile for current spec"])
            CellTooltip:Show()
        end)

        typeSwitch:HookScript("OnLeave", function()
            CellTooltip:Hide()
        end)
    end

    -- current profile box
    currentProfileBox = CreateFrame("Frame", nil, autoSwitchPane, "BackdropTemplate")
    Cell.StylizeFrame(currentProfileBox, {0.115, 0.115, 0.115, 1})
    P.Size(currentProfileBox, 140, 20)

    currentProfileBox.text = currentProfileBox:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    currentProfileBox.text:SetPoint("LEFT", P.Scale(5), 0)
    currentProfileBox.text:SetPoint("RIGHT", P.Scale(-5), 0)
    currentProfileBox.text:SetJustifyH("LEFT")

    if Cell.isRetail then
        currentProfileBox:SetPoint("TOPLEFT", typeSwitch, "BOTTOMLEFT", 0, -30)
    else
        currentProfileBox:SetPoint("TOPLEFT", 5, -42)
        P.Height(autoSwitchFrame, 430)
    end

    local currentProfileText = autoSwitchPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    currentProfileText:SetPoint("BOTTOMLEFT", currentProfileBox, "TOPLEFT", 0, 1)
    currentProfileText:SetTextColor(Cell.GetAccentColorRGB())
    currentProfileText:SetText(L["Current Profile"])

    -- solo
    soloDropdown = Cell.CreateDropdown(autoSwitchPane, 140)
    soloDropdown:SetPoint("TOPLEFT", currentProfileBox, "BOTTOMLEFT", 0, -30)

    soloText = autoSwitchPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    soloText:SetPoint("BOTTOMLEFT", soloDropdown, "TOPLEFT", 0, 1)
    soloText.text = L["Solo"]

    -- party
    partyDropdown = Cell.CreateDropdown(autoSwitchPane, 140)
    partyDropdown:SetPoint("TOPLEFT", soloDropdown, "BOTTOMLEFT", 0, -30)

    partyText = autoSwitchPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    partyText:SetPoint("BOTTOMLEFT", partyDropdown, "TOPLEFT", 0, 1)
    partyText.text = L["Party"]

    -- outdoor
    raidOutdoorDropdown = Cell.CreateDropdown(autoSwitchPane, 140)
    raidOutdoorDropdown:SetPoint("TOPLEFT", partyDropdown, "BOTTOMLEFT", 0, -30)

    raidOutdoorText = autoSwitchPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    raidOutdoorText:SetPoint("BOTTOMLEFT", raidOutdoorDropdown, "TOPLEFT", 0, 1)
    raidOutdoorText.text = raidOutdoor

    if Cell.isRetail then
        -- instance
        raidInstanceDropdown = Cell.CreateDropdown(autoSwitchPane, 140)
        raidInstanceDropdown:SetPoint("TOPLEFT", raidOutdoorDropdown, "BOTTOMLEFT", 0, -30)

        raidInstanceText = autoSwitchPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
        raidInstanceText:SetPoint("BOTTOMLEFT", raidInstanceDropdown, "TOPLEFT", 0, 1)
        raidInstanceText.text = raidInstance

        -- mythic
        raidMythicDropdown = Cell.CreateDropdown(autoSwitchPane, 140)
        raidMythicDropdown:SetPoint("TOPLEFT", raidInstanceDropdown, "BOTTOMLEFT", 0, -30)

        raidMythicText = autoSwitchPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
        raidMythicText:SetPoint("BOTTOMLEFT", raidMythicDropdown, "TOPLEFT", 0, 1)
        raidMythicText.text = raidMythic

    elseif Cell.isCata or Cell.isWrath then
        -- raid10
        raid10Dropdown = Cell.CreateDropdown(autoSwitchPane, 140)
        raid10Dropdown:SetPoint("TOPLEFT", raidOutdoorDropdown, "BOTTOMLEFT", 0, -30)

        raid10Text = autoSwitchPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
        raid10Text:SetPoint("BOTTOMLEFT", raid10Dropdown, "TOPLEFT", 0, 1)
        raid10Text.text = L["Raid"].." 10"

        -- raid25
        raid25Dropdown = Cell.CreateDropdown(autoSwitchPane, 140)
        raid25Dropdown:SetPoint("TOPLEFT", raid10Dropdown, "BOTTOMLEFT", 0, -30)

        raid25Text = autoSwitchPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
        raid25Text:SetPoint("BOTTOMLEFT", raid25Dropdown, "TOPLEFT", 0, 1)
        raid25Text.text = L["Raid"].." 25"

    elseif Cell.isVanilla then
        -- instance
        raidInstanceDropdown = Cell.CreateDropdown(autoSwitchPane, 140)
        raidInstanceDropdown:SetPoint("TOPLEFT", raidOutdoorDropdown, "BOTTOMLEFT", 0, -30)

        raidInstanceText = autoSwitchPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
        raidInstanceText:SetPoint("BOTTOMLEFT", raidInstanceDropdown, "TOPLEFT", 0, 1)
        raidInstanceText.text = raidInstance
    end

    -- arena
    arenaDropdown = Cell.CreateDropdown(autoSwitchPane, 140)
    if Cell.isRetail then
        arenaDropdown:SetPoint("TOPLEFT", raidMythicDropdown, "BOTTOMLEFT", 0, -30)
    elseif Cell.isCata or Cell.isWrath then
        arenaDropdown:SetPoint("TOPLEFT", raid25Dropdown, "BOTTOMLEFT", 0, -30)
    elseif Cell.isVanilla then
        arenaDropdown:SetPoint("TOPLEFT", raidInstanceDropdown, "BOTTOMLEFT", 0, -30)
    end

    arenaText = autoSwitchPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    arenaText:SetPoint("BOTTOMLEFT", arenaDropdown, "TOPLEFT", 0, 1)
    arenaText.text = L["Arena"]

    if Cell.isVanilla then
        -- battleground (vanilla)
        bgDropdown = Cell.CreateDropdown(autoSwitchPane, 140)
        bgDropdown:SetPoint("TOPLEFT", arenaDropdown, "BOTTOMLEFT", 0, -30)

        bgText = autoSwitchPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
        bgText:SetPoint("BOTTOMLEFT", bgDropdown, "TOPLEFT", 0, 1)
        bgText.text = _G.BATTLEGROUND
    else
        -- battleground 15
        bg15Dropdown = Cell.CreateDropdown(autoSwitchPane, 140)
        bg15Dropdown:SetPoint("TOPLEFT", arenaDropdown, "BOTTOMLEFT", 0, -30)

        bg15Text = autoSwitchPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
        bg15Text:SetPoint("BOTTOMLEFT", bg15Dropdown, "TOPLEFT", 0, 1)
        bg15Text.text = L["BG 1-15"]

        -- battleground 40
        bg40Dropdown = Cell.CreateDropdown(autoSwitchPane, 140)
        bg40Dropdown:SetPoint("TOPLEFT", bg15Dropdown, "BOTTOMLEFT", 0, -30)

        bg40Text = autoSwitchPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
        bg40Text:SetPoint("BOTTOMLEFT", bg40Dropdown, "TOPLEFT", 0, 1)
        bg40Text.text = L["BG 16-40"]
    end
end

local function GetDropdownItems(indices, groupType)
    local items = {}
    for _, value in pairs(indices) do
        local name
        if value == "default" then
            name = _G.DEFAULT
        elseif value == "hide" then
            name = "|cffababab" .. L["Hide"] .. "|r"
        else
            name = value
        end

        table.insert(items, {
            ["text"] = name,
            ["value"] = value,
            ["onClick"] = function()
                Cell.vars.layoutAutoSwitch[groupType] = value
                if Cell.vars.layoutGroupType == groupType then
                    F.UpdateLayout(groupType, true)
                    -- LoadLayoutDB(Cell.vars.currentLayout)
                    UpdateButtonStates()
                    -- UpdateEnabledLayoutText()
                end
            end,
        })
    end
    return items
end

LoadAutoSwitchDropdowns = function()
    local indices = {}
    for name, _ in pairs(CellDB["layouts"]) do
        if name ~= "default" then
            tinsert(indices, name)
        end
    end
    table.sort(indices)
    tinsert(indices, 1, "hide") -- make hide first
    tinsert(indices, 2, "default") -- make default second

    -- soloDropdown
    soloDropdown:SetItems(GetDropdownItems(indices, "solo"))
    -- partyDropdown
    partyDropdown:SetItems(GetDropdownItems(indices, "party"))
    -- raidOutdoorDropdown
    raidOutdoorDropdown:SetItems(GetDropdownItems(indices, "raid_outdoor"))

    if Cell.isRetail then
        -- raidInstanceDropdown
        raidInstanceDropdown:SetItems(GetDropdownItems(indices, "raid_instance"))
        -- raidMythicDropdown
        raidMythicDropdown:SetItems(GetDropdownItems(indices, "raid_mythic"))

    elseif Cell.isCata or Cell.isWrath then
        -- raid10Dropdown
        raid10Dropdown:SetItems(GetDropdownItems(indices, "raid10"))
        -- raid25Dropdown
        raid25Dropdown:SetItems(GetDropdownItems(indices, "raid25"))

    elseif Cell.isVanilla then
        -- raidInstanceDropdown
        raidInstanceDropdown:SetItems(GetDropdownItems(indices, "raid_instance"))
    end

    -- arenaDropdown
    arenaDropdown:SetItems(GetDropdownItems(indices, "arena"))

    if Cell.isVanilla then
        -- bgDropdown
        bgDropdown:SetItems(GetDropdownItems(indices, "battleground"))
    else
        -- bg15Dropdown
        bg15Dropdown:SetItems(GetDropdownItems(indices, "battleground15"))
        -- bg40Dropdown
        bg40Dropdown:SetItems(GetDropdownItems(indices, "battleground40"))
    end
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
    local groupFilterPane = Cell.CreateTitledPane(layoutsTab, L["Group Filters"], 205, 80)
    groupFilterPane:SetPoint("TOPLEFT", 222, -5)

    for i = 1, 8 do
        groupButtons[i] = Cell.CreateButton(groupFilterPane, i, "accent-hover", {20, 20})
        groupButtons[i]:SetScript("OnClick", function()
            selectedLayoutTable["groupFilter"][i] = not selectedLayoutTable["groupFilter"][i]
            UpdateButtonBorderColor(selectedLayoutTable["groupFilter"][i], groupButtons[i])

            if selectedLayout == Cell.vars.currentLayout then
                Cell.Fire("UpdateLayout", selectedLayout, "groupFilter")
            end
            UpdateLayoutPreview()
        end)

        if i == 1 then
            groupButtons[i]:SetPoint("TOPLEFT", 5, -27)
        -- elseif i == 5 then
        --     groupButtons[i]:SetPoint("TOPLEFT", groupButtons[1], "BOTTOMLEFT", 0, -3)
        else
            groupButtons[i]:SetPoint("TOPLEFT", groupButtons[i-1], "TOPRIGHT", 5, 0)
        end
    end

    -- preview mode
    local previewModeButton = Cell.CreateButton(groupFilterPane, L["Preview"]..": |cff777777"..L["OFF"], "accent", {195, 20})
    previewModeButton:SetPoint("TOPLEFT", groupButtons[1], "BOTTOMLEFT", 0, -10)
    previewModeButton:SetScript("OnClick", function()
        previewMode = (previewMode == 2) and 0 or (previewMode + 1)

        if previewMode == 0 then
            previewModeButton:SetText(L["Preview"]..": |cff777777"..L["OFF"])
            layoutPreview.fadeOut:Play()
            if npcPreview:IsShown() then
                npcPreview.fadeOut:Play()
            end
            if petPreview:IsShown() then
                petPreview.fadeOut:Play()
            end
            if spotlightPreview:IsShown() then
                spotlightPreview.fadeOut:Play()
            end
        elseif previewMode == 1 then
            previewModeButton:SetText(L["Preview"]..": "..L["Party"])
            UpdateLayoutPreview()
            UpdateNPCPreview()
            UpdatePetPreview()
            UpdateSpotlightPreview()
        else
            previewModeButton:SetText(L["Preview"]..": "..L["Raid"])
            UpdateLayoutPreview()
            UpdateNPCPreview()
            UpdatePetPreview()
            UpdateSpotlightPreview()
        end
    end)
    previewModeButton:SetScript("OnHide", function()
        previewMode = 0
        previewModeButton:SetText(L["Preview"]..": |cff777777"..L["OFF"])
    end)
end

local function UpdateGroupFilter()
    for i = 1, 8 do
        UpdateButtonBorderColor(selectedLayoutTable["groupFilter"][i], groupButtons[i])
    end
end

-------------------------------------------------
-- layout setup
-------------------------------------------------
local widthSlider, heightSlider, powerSizeSlider

local rcSlider, groupSpacingSlider, unitsSlider
local orientationDropdown, anchorDropdown, spacingXSlider, spacingYSlider

local sameSizeAsMainCB, sameArrangementAsMainCB
local combineGroupsCB, sortByRoleCB, roleOrderWidget, hideSelfCB
local showNpcCB, separateNpcCB, spotlightCB, hidePlaceholderCB, spotlightOrientationDropdown
local soloPetCB, partyPetsCB, partyPetsDetachedCB, raidPetsCB

local function UpdateSize()
    if selectedLayout == Cell.vars.currentLayout then
        Cell.Fire("UpdateLayout", selectedLayout, selectedPage.."-size")
    end

    if selectedPage == "main" then
        UpdatePreviewButton("size")
        UpdateLayoutPreview()
        if selectedLayoutTable["pet"]["sameSizeAsMain"] then
            UpdatePetPreview()
        end
        if selectedLayoutTable["npc"]["sameSizeAsMain"] then
            UpdateNPCPreview()
        end
        if selectedLayoutTable["spotlight"]["sameSizeAsMain"] then
            UpdateSpotlightPreview()
        end
    elseif selectedPage == "pet" then
        UpdatePetPreview()
    elseif selectedPage == "npc" then
        UpdateNPCPreview()
    elseif selectedPage == "spotlight" then
        UpdateSpotlightPreview()
    end
end

local function UpdateArrangement()
    if selectedLayout == Cell.vars.currentLayout then
        Cell.Fire("UpdateLayout", selectedLayout, selectedPage.."-arrangement")
    end

    if selectedPage == "main" then
        UpdateLayoutPreview()
        if selectedLayoutTable["pet"]["sameArrangementAsMain"] then
            UpdatePetPreview()
        end
        if selectedLayoutTable["npc"]["sameArrangementAsMain"] then
            UpdateNPCPreview()
        end
        if selectedLayoutTable["spotlight"]["sameArrangementAsMain"] then
            UpdateSpotlightPreview()
        end
    elseif selectedPage == "pet" then
        UpdatePetPreview()
    elseif selectedPage == "npc" then
        UpdateNPCPreview()
    elseif selectedPage == "spotlight" then
        UpdateSpotlightPreview()
    end
end

local function UpdateSliderStatus()
    if selectedLayoutTable["main"]["orientation"] == "vertical" then
        rcSlider:SetLabel(L["Group Columns"])
        unitsSlider:SetLabel(L["Units Per Column"])
    else
        unitsSlider:SetLabel(L["Units Per Row"])
        rcSlider:SetLabel(L["Group Rows"])
    end

    if selectedLayoutTable["main"]["combineGroups"] then
        unitsSlider:Show()
        groupSpacingSlider:Hide()
    else
        unitsSlider:Hide()
        groupSpacingSlider:Show()
    end

    if selectedLayoutTable["main"]["maxColumns"] == 8 then
        groupSpacingSlider:SetEnabled(false)
    else
        groupSpacingSlider:SetEnabled(true)
    end
end

-- TODO: move to Widgets.lua
local function CreateRoleOrderWidget(parent)
    local f = CreateFrame("Frame", nil, parent)
    P.Size(f, 66, 20)

    local buttons = {}
    for _, role in pairs({"TANK", "HEALER", "DAMAGER"}) do
        buttons[role] = Cell.CreateButton(f, nil, "accent-hover", {20, 20})
        buttons[role]:SetTexture(F.GetDefaultRoleIcon(role), {16, 16}, {"CENTER", 0, 0}, false, true)
        buttons[role]._role = role

        buttons[role]:SetMovable(true)
        buttons[role]:RegisterForDrag("LeftButton")

        buttons[role]:SetScript("OnDragStart", function(self)
            self:SetFrameStrata("TOOLTIP")
            self:StartMoving()
            self:SetUserPlaced(false)
        end)

        buttons[role]:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            self:SetFrameStrata("LOW")
            -- self:Hide() --! Hide() will cause OnDragStop trigger TWICE!!!
            C_Timer.After(0.05, function()
                local b = F.GetMouseFocus()
                if b ~= self and b and b._role then
                    local roleToIndex = F.ConvertTable(selectedLayoutTable["main"]["roleOrder"])
                    -- print(self._role, "->", b._role)

                    local oldIndex = roleToIndex[self._role]
                    tremove(selectedLayoutTable["main"]["roleOrder"], oldIndex)

                    local newIndex = roleToIndex[b._role]
                    tinsert(selectedLayoutTable["main"]["roleOrder"], newIndex, self._role)

                    Cell.Fire("UpdateLayout", selectedLayout, "sort")
                end
                f:Load(selectedLayoutTable["main"]["roleOrder"])
            end)
        end)
    end

    function f:Load(t)
        for i, role in pairs(t) do
            buttons[role]:SetFrameStrata("DIALOG")
            buttons[role]:Show()
            buttons[role]:ClearAllPoints()
            buttons[role]:SetPoint("TOPLEFT", (i-1)*(P.Scale(20)+P.Scale(3)), 0)
        end
    end

    return f
end

local function CreateLayoutSetupPane()
    local layoutSetupPane = Cell.CreateTitledPane(layoutsTab, L["Layout Setup"], 422, 290)
    layoutSetupPane:SetPoint("TOPLEFT", 5, -110)

    -- buttons
    local spotlight = Cell.CreateButton(layoutSetupPane, L["Spotlight"], "accent-hover", {85, 17})
    spotlight:SetPoint("TOPRIGHT", layoutSetupPane)
    spotlight.id = "spotlight"

    local npc = Cell.CreateButton(layoutSetupPane, "NPC", "accent-hover", {70, 17})
    npc:SetPoint("TOPRIGHT", spotlight, "TOPLEFT", P.Scale(1), 0)
    npc.id = "npc"

    local pet = Cell.CreateButton(layoutSetupPane, L["Pet"], "accent-hover", {70, 17})
    pet:SetPoint("TOPRIGHT", npc, "TOPLEFT", P.Scale(1), 0)
    pet.id = "pet"

    local main = Cell.CreateButton(layoutSetupPane, L["Main"], "accent-hover", {70, 17})
    main:SetPoint("TOPRIGHT", pet, "TOPLEFT", P.Scale(1), 0)
    main.id = "main"

    -- same size as main
    sameSizeAsMainCB = Cell.CreateCheckButton(layoutSetupPane, L["Use Same Size As Main"], function(checked, self)
        selectedLayoutTable[selectedPage]["sameSizeAsMain"] = checked
        widthSlider:SetEnabled(not checked)
        heightSlider:SetEnabled(not checked)
        powerSizeSlider:SetEnabled(not checked)
        -- update size and power
        UpdateSize()
        if selectedLayout == Cell.vars.currentLayout then
            Cell.Fire("UpdateLayout", selectedLayout, selectedPage.."-power")
        end
    end)
    sameSizeAsMainCB:Hide()

    -- same arrangement as main
    sameArrangementAsMainCB = Cell.CreateCheckButton(layoutSetupPane, L["Use Same Arrangement As Main"], function(checked, self)
        selectedLayoutTable[selectedPage]["sameArrangementAsMain"] = checked
        if selectedPage == "spotlight" then
            spotlightOrientationDropdown:SetEnabled(not checked)
        else
            orientationDropdown:SetEnabled(not checked)
        end
        anchorDropdown:SetEnabled(not checked)
        spacingXSlider:SetEnabled(not checked)
        spacingYSlider:SetEnabled(not checked)
        UpdateArrangement()
    end)
    sameArrangementAsMainCB:SetPoint("TOPLEFT", sameSizeAsMainCB, "BOTTOMLEFT", 0, -8)
    sameArrangementAsMainCB:Hide()

    -- width
    widthSlider = Cell.CreateSlider(L["Width"], layoutSetupPane, 20, 500, 117, 1, function(value)
        selectedLayoutTable[selectedPage]["size"][1] = value
        UpdateSize()
    end)

    -- height
    heightSlider = Cell.CreateSlider(L["Height"], layoutSetupPane, 20, 500, 117, 1, function(value)
        selectedLayoutTable[selectedPage]["size"][2] = value
        UpdateSize()
    end)
    heightSlider:SetPoint("TOPLEFT", widthSlider, 0, -55)

    -- power height
    powerSizeSlider = Cell.CreateSlider(L["Power Size"], layoutSetupPane, 0, 100, 117, 1, function(value)
        selectedLayoutTable[selectedPage]["powerSize"] = value
        if selectedLayout == Cell.vars.currentLayout then
            Cell.Fire("UpdateLayout", selectedLayout, selectedPage.."-power")
        end
        UpdatePreviewButton("power")
    end)
    powerSizeSlider:SetPoint("TOPLEFT", heightSlider, 0, -55)

    -- orientation
    orientationDropdown = Cell.CreateDropdown(layoutSetupPane, 117)
    orientationDropdown:SetPoint("TOPLEFT", widthSlider, "TOPRIGHT", 30, 0)
    orientationDropdown:SetItems({
        {
            ["text"] = L["Horizontal"],
            ["value"] = "horizontal",
            ["onClick"] = function()
                selectedLayoutTable[selectedPage]["orientation"] = "horizontal"
                UpdateArrangement()

                if selectedPage == "main" then
                    UpdateSliderStatus()
                end
            end,
        },
        {
            ["text"] = L["Vertical"],
            ["value"] = "vertical",
            ["onClick"] = function()
                selectedLayoutTable[selectedPage]["orientation"] = "vertical"
                UpdateArrangement()

                if selectedPage == "main" then
                    UpdateSliderStatus()
                end
            end,
        },
    })

    local orientationText = orientationDropdown:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    orientationText:SetPoint("BOTTOMLEFT", orientationDropdown, "TOPLEFT", 0, 1)
    orientationText:SetText(L["Orientation"])

    hooksecurefunc(orientationDropdown, "SetEnabled", function(self, enabled)
        if enabled then
            orientationText:SetTextColor(1, 1, 1)
        else
            orientationText:SetTextColor(0.4, 0.4, 0.4)
        end
    end)

    -- anchor
    anchorDropdown = Cell.CreateDropdown(layoutSetupPane, 117)
    anchorDropdown:SetPoint("TOPLEFT", orientationDropdown, "TOPRIGHT", 30, 0)
    anchorDropdown:SetItems({
        {
            ["text"] = L["BOTTOMLEFT"],
            ["value"] = "BOTTOMLEFT",
            ["onClick"] = function()
                selectedLayoutTable[selectedPage]["anchor"] = "BOTTOMLEFT"
                UpdateArrangement()
            end,
        },
        {
            ["text"] = L["BOTTOMRIGHT"],
            ["value"] = "BOTTOMRIGHT",
            ["onClick"] = function()
                selectedLayoutTable[selectedPage]["anchor"] = "BOTTOMRIGHT"
                UpdateArrangement()
            end,
        },
        {
            ["text"] = L["TOPLEFT"],
            ["value"] = "TOPLEFT",
            ["onClick"] = function()
                selectedLayoutTable[selectedPage]["anchor"] = "TOPLEFT"
                UpdateArrangement()
            end,
        },
        {
            ["text"] = L["TOPRIGHT"],
            ["value"] = "TOPRIGHT",
            ["onClick"] = function()
                selectedLayoutTable[selectedPage]["anchor"] = "TOPRIGHT"
                UpdateArrangement()
            end,
        },
    })

    local anchorText = layoutSetupPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    anchorText:SetPoint("BOTTOMLEFT", anchorDropdown, "TOPLEFT", 0, 1)
    anchorText:SetText(L["Anchor Point"])

    hooksecurefunc(anchorDropdown, "SetEnabled", function(self, enabled)
        if enabled then
            anchorText:SetTextColor(1, 1, 1)
        else
            anchorText:SetTextColor(0.4, 0.4, 0.4)
        end
    end)

     -- spacing
    spacingXSlider = Cell.CreateSlider(L["Unit Spacing"].." X", layoutSetupPane, -1, 500, 117, 1, function(value)
        selectedLayoutTable[selectedPage]["spacingX"] = value
        UpdateArrangement()
    end)
    spacingXSlider:SetPoint("TOPLEFT", orientationDropdown, 0, -55)

    spacingYSlider = Cell.CreateSlider(L["Unit Spacing"].." Y", layoutSetupPane, -1, 500, 117, 1, function(value)
        selectedLayoutTable[selectedPage]["spacingY"] = value
        UpdateArrangement()
    end)
    spacingYSlider:SetPoint("TOPLEFT", anchorDropdown, 0, -55)

    -- pages
    local pages = {}

    --* main ------------------------------------
    pages.main = CreateFrame("Frame", nil, layoutsTab)
    pages.main:SetAllPoints(layoutSetupPane)
    pages.main:Hide()

    -- combine groups
    combineGroupsCB = Cell.CreateCheckButton(pages.main, L["Combine Groups"].." ("..L["Raid"]..")", function(checked, self)
        selectedLayoutTable["main"]["combineGroups"] = checked
        Cell.Fire("UpdateLayout", selectedLayout, "header")
        UpdateSliderStatus()
        -- preview
        UpdateLayoutPreview()
    end)
    combineGroupsCB:SetPoint("TOPLEFT", 5, -27)
    Cell.RegisterForCloseDropdown(combineGroupsCB)

    -- sort by role
    sortByRoleCB = Cell.CreateCheckButton(pages.main, L["Sort By Role"], function(checked, self)
        selectedLayoutTable["main"]["sortByRole"] = checked
        if checked then
            roleOrderWidget:Show()
        else
            roleOrderWidget:Hide()
        end
        Cell.Fire("UpdateLayout", selectedLayout, "sort")
    end, L["Sort By Role"], "|cffffb5c5"..L["Left-Drag"]..":|r "..L["change the order"]) -- L["%s is required"]:format("|cffffb5c5"..L["Combine Groups"].."|r").." ("..L["Raid"]..")"
    sortByRoleCB:SetPoint("TOPLEFT", combineGroupsCB, "BOTTOMLEFT", 0, -10)
    Cell.RegisterForCloseDropdown(sortByRoleCB)

    -- role order
    roleOrderWidget = CreateRoleOrderWidget(pages.main)
    roleOrderWidget:SetPoint("TOPLEFT", sortByRoleCB, sortByRoleCB.label:GetWidth()+25, 3)

    -- hide self
    hideSelfCB = Cell.CreateCheckButton(pages.main, L["Hide Self"].." ("..L["Party"]..")", function(checked, self)
        selectedLayoutTable["main"]["hideSelf"] = checked
        Cell.Fire("UpdateLayout", selectedLayout, "hideSelf")
    end)
    hideSelfCB:SetPoint("TOPLEFT", sortByRoleCB, "BOTTOMLEFT", 0, -10)

    -- rows/columns
    rcSlider = Cell.CreateSlider("", pages.main, 1, 8, 117, 1, function(value)
        if selectedLayoutTable["main"]["orientation"] == "vertical" then
            selectedLayoutTable["main"]["maxColumns"] = value
        else -- horizontal
            selectedLayoutTable["main"]["maxColumns"] = value
        end
        if value == 8 then
            groupSpacingSlider:SetEnabled(false)
        else
            groupSpacingSlider:SetEnabled(true)
        end
        if selectedLayout == Cell.vars.currentLayout then
            Cell.Fire("UpdateLayout", selectedLayout, "rows_columns")
        end
        -- preview
        UpdateLayoutPreview()
    end)
    rcSlider:SetPoint("TOPLEFT", spacingXSlider, 0, -55)

    -- group spacing
    groupSpacingSlider = Cell.CreateSlider(L["Group Spacing"], pages.main, 0, 500, 117, 1, function(value)
        selectedLayoutTable["main"]["groupSpacing"] = value
        if selectedLayout == Cell.vars.currentLayout then
            Cell.Fire("UpdateLayout", selectedLayout, "groupSpacing")
        end
        -- preview
        UpdateLayoutPreview()
    end)
    groupSpacingSlider:SetPoint("TOPLEFT", spacingYSlider, 0, -55)

    -- unitsPerColumn
    unitsSlider = Cell.CreateSlider(L["Units Per Column"], pages.main, 2, Cell.isRetail and 20 or 25, 117, 1, function(value)
        selectedLayoutTable["main"]["unitsPerColumn"] = value
        if selectedLayout == Cell.vars.currentLayout then
            Cell.Fire("UpdateLayout", selectedLayout, "unitsPerColumn")
        end
        -- preview
        UpdateLayoutPreview()
    end)
    unitsSlider:SetPoint("TOPLEFT", spacingYSlider, 0, -55)

    --* pet -------------------------------------
    pages.pet = CreateFrame("Frame", nil, layoutsTab)
    pages.pet:SetAllPoints(layoutSetupPane)
    pages.pet:Hide()

    soloPetCB = Cell.CreateCheckButton(pages.pet, L["Show Solo Pet"], function(checked)
        selectedLayoutTable["pet"]["soloEnabled"] = checked
        if selectedLayout == Cell.vars.currentLayout then
            Cell.Fire("UpdateLayout", selectedLayout, "pet")
        end
    end)
    soloPetCB:SetPoint("TOPLEFT", 5, -27)

    partyPetsCB = Cell.CreateCheckButton(pages.pet, L["Show Party/Arena Pets"], function(checked)
        selectedLayoutTable["pet"]["partyEnabled"] = checked
        partyPetsDetachedCB:SetEnabled(checked)
        if checked and selectedLayoutTable["pet"]["partyDetached"] then
            UpdatePetPreview()
        else
            if petPreview:IsShown() then
                UpdatePetPreview()
            end
        end
        if selectedLayout == Cell.vars.currentLayout then
            Cell.Fire("UpdateLayout", selectedLayout, "pet")
        end
    end)
    partyPetsCB:SetPoint("TOPLEFT", soloPetCB, "BOTTOMLEFT", 0, -8)

    partyPetsDetachedCB = Cell.CreateCheckButton(pages.pet, L["Detached"], function(checked)
        selectedLayoutTable["pet"]["partyDetached"] = checked
        if checked and selectedLayoutTable["pet"]["partyEnabled"] then
            UpdatePetPreview()
        else
            if petPreview:IsShown() then
                UpdatePetPreview()
            end
        end
        if selectedLayout == Cell.vars.currentLayout then
            Cell.Fire("UpdateLayout", selectedLayout, "pet")
        end
    end, L["Detached"], L["Show pets in a separate frame"], L["You can move it in Preview mode"])
    partyPetsDetachedCB:SetPoint("TOPLEFT", partyPetsCB, "TOPRIGHT", 203, 0)

    raidPetsCB = Cell.CreateCheckButton(pages.pet, L["Show Raid Pets"], function(checked)
        selectedLayoutTable["pet"]["raidEnabled"] = checked
        if checked then
            UpdatePetPreview()
        else
            if petPreview:IsShown() then
                UpdatePetPreview()
            end
        end
        if selectedLayout == Cell.vars.currentLayout then
            Cell.Fire("UpdateLayout", selectedLayout, "pet")
        end
    end, L["Show Raid Pets"], L["Show pets in a separate frame"], L["You can move it in Preview mode"])
    raidPetsCB:SetPoint("TOPLEFT", partyPetsCB, "BOTTOMLEFT", 0, -8)

    --* npc -------------------------------------
    pages.npc = CreateFrame("Frame", nil, layoutsTab)
    pages.npc:SetAllPoints(layoutSetupPane)
    pages.npc:Hide()

    showNpcCB = Cell.CreateCheckButton(pages.npc, L["Show NPC Frame"], function(checked)
        selectedLayoutTable["npc"]["enabled"] = checked
        if checked then
            UpdateNPCPreview()
        else
            if npcPreview:IsShown() then
                UpdateNPCPreview()
            end
        end
        separateNpcCB:SetEnabled(checked)
        if selectedLayout == Cell.vars.currentLayout then
            Cell.Fire("UpdateLayout", selectedLayout, "npc")
        end
    end)
    showNpcCB:SetPoint("TOPLEFT", 5, -27)

    separateNpcCB = Cell.CreateCheckButton(pages.npc, L["Separate NPC Frame"], function(checked)
        selectedLayoutTable["npc"]["separate"] = checked
        if checked then
            UpdateNPCPreview()
        else
            if npcPreview:IsShown() then
                UpdateNPCPreview()
            end
        end
        if selectedLayout == Cell.vars.currentLayout then
            Cell.Fire("UpdateLayout", selectedLayout, "npc")
        end
    end, L["Separate NPC Frame"], L["Show friendly NPCs in a separate frame"], L["You can move it in Preview mode"])
    separateNpcCB:SetPoint("TOPLEFT", showNpcCB, "BOTTOMLEFT", 0, -8)

    --* spotlight -------------------------------
    pages.spotlight = CreateFrame("Frame", nil, layoutsTab)
    pages.spotlight:SetAllPoints(layoutSetupPane)
    pages.spotlight:Hide()

    spotlightCB = Cell.CreateCheckButton(pages.spotlight, L["Enable Spotlight Frame"], function(checked)
        selectedLayoutTable["spotlight"]["enabled"] = checked
        if checked then
            UpdateSpotlightPreview()
        else
            if spotlightPreview:IsShown() then
                UpdateSpotlightPreview()
            end
        end
        if selectedLayout == Cell.vars.currentLayout then
            Cell.Fire("UpdateLayout", selectedLayout, "spotlight")
        end
    end, L["Spotlight Frame"], L["Show units you care about more in a separate frame"],
    "|cffffb5c5"..L["Target"]..", "..L["Target of Target"]..", "..L["Focus"],
    "|cffffb5c5"..L["Unit"]..", "..L["Unit's Pet"]..", "..L["Unit's Target"])
    spotlightCB:SetPoint("TOPLEFT", 5, -27)

    hidePlaceholderCB = Cell.CreateCheckButton(pages.spotlight, L["Hide Placeholder Frames"], function(checked)
        selectedLayoutTable["spotlight"]["hidePlaceholder"] = checked
        if selectedLayout == Cell.vars.currentLayout then
            Cell.Fire("UpdateLayout", selectedLayout, "spotlight")
        end
    end)
    hidePlaceholderCB:SetPoint("TOPLEFT", spotlightCB, "BOTTOMLEFT", 0, -8)

    -- spotlight orientation
    spotlightOrientationDropdown = Cell.CreateDropdown(pages.spotlight, 117)
    spotlightOrientationDropdown:SetPoint("TOPLEFT", widthSlider, "TOPRIGHT", 30, 0)
    spotlightOrientationDropdown:SetItems({
        {
            ["text"] = L["Vertical"].." A",
            ["value"] = "vertical",
            ["onClick"] = function()
                selectedLayoutTable[selectedPage]["orientation"] = "vertical"
                UpdateArrangement()
            end,
        },
        {
            ["text"] = L["Vertical"].." B",
            ["value"] = "vertical2",
            ["onClick"] = function()
                selectedLayoutTable[selectedPage]["orientation"] = "vertical2"
                UpdateArrangement()
            end,
        },
        {
            ["text"] = L["Horizontal"].." A",
            ["value"] = "horizontal",
            ["onClick"] = function()
                selectedLayoutTable[selectedPage]["orientation"] = "horizontal"
                UpdateArrangement()
            end,
        },
        {
            ["text"] = L["Horizontal"].." B",
            ["value"] = "horizontal2",
            ["onClick"] = function()
                selectedLayoutTable[selectedPage]["orientation"] = "horizontal2"
                UpdateArrangement()
            end,
        },
    })

    local spotlightOrientationText = spotlightOrientationDropdown:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    spotlightOrientationText:SetPoint("BOTTOMLEFT", spotlightOrientationDropdown, "TOPLEFT", 0, 1)
    spotlightOrientationText:SetText(L["Orientation"])

    hooksecurefunc(spotlightOrientationDropdown, "SetEnabled", function(self, enabled)
        if enabled then
            spotlightOrientationText:SetTextColor(1, 1, 1)
        else
            spotlightOrientationText:SetTextColor(0.4, 0.4, 0.4)
        end
    end)

    -- button group
    Cell.CreateButtonGroup({main, pet, npc, spotlight}, function(tab)
        selectedPage = tab

        -- load
        LoadPageDB(tab)

        -- repoint
        sameSizeAsMainCB:ClearAllPoints()
        if tab == "main" then
        elseif tab == "pet" then
            sameSizeAsMainCB:SetPoint("TOPLEFT", raidPetsCB, "BOTTOMLEFT", 0, -14)
        elseif tab == "npc" then
            sameSizeAsMainCB:SetPoint("TOPLEFT", separateNpcCB, "BOTTOMLEFT", 0, -14)
        elseif tab == "spotlight" then
            sameSizeAsMainCB:SetPoint("TOPLEFT", hidePlaceholderCB, "BOTTOMLEFT", 0, -14)
        end

        widthSlider:ClearAllPoints()
        if tab == "main" then
            sameSizeAsMainCB:Hide()
            sameArrangementAsMainCB:Hide()
            widthSlider:SetPoint("TOPLEFT", hideSelfCB, 0, -50)
        else
            sameSizeAsMainCB:Show()
            sameArrangementAsMainCB:Show()
            widthSlider:SetPoint("TOPLEFT", sameArrangementAsMainCB, 0, -50)
        end

        if tab == "spotlight" then
            orientationDropdown:Hide()
        else
            orientationDropdown:Show()
        end

        -- show & hide
        for name, page in pairs(pages) do
            if name == tab then
                page:Show()
            else
                page:Hide()
            end
        end
    end)

    layoutSetupPane:SetScript("OnShow", function()
        if layoutSetupPane.shown then return end
        layoutSetupPane.shown = true
        main:Click()
    end)
end


-------------------------------------------------
-- bar orientation
-------------------------------------------------
local barOrientationDropdown, rotateTexCB

local function CreateBarOrientationPane()
    local barOrientationPane = Cell.CreateTitledPane(layoutsTab, L["Bar Orientation"], 205, 80)
    barOrientationPane:SetPoint("TOPLEFT", 5, -445)

    local function SetOrientation(orientation)
        selectedLayoutTable["barOrientation"][1] = orientation
        if selectedLayout == Cell.vars.currentLayout then
            Cell.Fire("UpdateLayout", selectedLayout, "barOrientation")
        end
        UpdatePreviewButton("barOrientation")
    end

    barOrientationDropdown = Cell.CreateDropdown(barOrientationPane, 193)
    barOrientationDropdown:SetPoint("TOPLEFT", 5, -27)
    barOrientationDropdown:SetItems({
        {
            ["text"] = L["Horizontal"],
            ["value"] = "horizontal",
            ["onClick"] = function()
                SetOrientation("horizontal")
            end,
        },
        {
            ["text"] = L["Vertical"].." A",
            ["value"] = "vertical",
            ["onClick"] = function()
                SetOrientation("vertical")
            end,
        },
        {
            ["text"] = L["Vertical"].." B",
            ["value"] = "vertical_health",
            ["onClick"] = function()
                SetOrientation("vertical_health")
            end,
        },
    })

    -- orientationSwitch = Cell.CreateSwitch(barOrientationPane, {163, 20}, L["Horizontal"], "horizontal", L["Vertical"], "vertical", function(which)
    --     selectedLayoutTable["barOrientation"][1] = which
    --     if selectedLayout == Cell.vars.currentLayout then
    --         Cell.Fire("UpdateLayout", selectedLayout, "barOrientation")
    --     end
    --     UpdatePreviewButton("barOrientation")
    -- end)
    -- orientationSwitch:SetPoint("TOPLEFT", 5, -27)

    rotateTexCB = Cell.CreateCheckButton(barOrientationPane, L["Rotate Texture"], function(checked)
        selectedLayoutTable["barOrientation"][2] = checked
        if selectedLayout == Cell.vars.currentLayout then
            Cell.Fire("UpdateLayout", selectedLayout, "barOrientation")
        end
        UpdatePreviewButton("barOrientation")
    end)
    rotateTexCB:SetPoint("TOPLEFT", barOrientationDropdown, "BOTTOMLEFT", 0, -10)
end

-------------------------------------------------
-- misc
-------------------------------------------------
local function CreateMiscPane()
    local miscPane = Cell.CreateTitledPane(layoutsTab, L["Misc"], 205, 80)
    miscPane:SetPoint("TOPLEFT", 222, -445)

    local powerFilterBtn = Cell.CreateButton(miscPane, L["Power Bar Filters"], "accent-hover", {195, 20})
    Cell.frames.layoutsTab.powerFilterBtn = powerFilterBtn
    powerFilterBtn:SetPoint("TOPLEFT", 5, -27)
    powerFilterBtn:SetScript("OnClick", function ()
        F.ShowPowerFilters(selectedLayout, selectedLayoutTable)
    end)

    Cell.frames.powerFilters:SetPoint("BOTTOMRIGHT", powerFilterBtn, "TOPRIGHT", 0, P.Scale(5))
end

-------------------------------------------------
-- tips
-------------------------------------------------
local tips = layoutsTab:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
tips:SetPoint("BOTTOMLEFT", 5, 5)
tips:SetJustifyH("LEFT")
tips:SetText("|cffababab"..L["Tip: Every layout has its own position setting"])

-------------------------------------------------
-- functions
-------------------------------------------------
local init

LoadPageDB = function(page)
    -- size
    widthSlider:SetValue(selectedLayoutTable[page]["size"][1])
    heightSlider:SetValue(selectedLayoutTable[page]["size"][2])
    powerSizeSlider:SetValue(selectedLayoutTable[page]["powerSize"])

    spacingXSlider:SetValue(selectedLayoutTable[page]["spacingX"])
    spacingYSlider:SetValue(selectedLayoutTable[page]["spacingY"])

    -- group arrangement
    orientationDropdown:SetSelectedValue(selectedLayoutTable[page]["orientation"])
    spotlightOrientationDropdown:SetSelectedValue(selectedLayoutTable[page]["orientation"])
    anchorDropdown:SetSelectedValue(selectedLayoutTable[page]["anchor"])

    -- same as main
    if page ~= "main" then
        sameSizeAsMainCB:SetChecked(selectedLayoutTable[page]["sameSizeAsMain"])
        sameArrangementAsMainCB:SetChecked(selectedLayoutTable[page]["sameArrangementAsMain"])
    end

    if page == "main" then
        widthSlider:SetEnabled(true)
        heightSlider:SetEnabled(true)
        powerSizeSlider:SetEnabled(true)
        orientationDropdown:SetEnabled(true)
        anchorDropdown:SetEnabled(true)
        spacingXSlider:SetEnabled(true)
        spacingYSlider:SetEnabled(true)
    else
        widthSlider:SetEnabled(not selectedLayoutTable[page]["sameSizeAsMain"])
        heightSlider:SetEnabled(not selectedLayoutTable[page]["sameSizeAsMain"])
        powerSizeSlider:SetEnabled(not selectedLayoutTable[page]["sameSizeAsMain"])
        anchorDropdown:SetEnabled(not selectedLayoutTable[page]["sameArrangementAsMain"])
        spacingXSlider:SetEnabled(not selectedLayoutTable[page]["sameArrangementAsMain"])
        spacingYSlider:SetEnabled(not selectedLayoutTable[page]["sameArrangementAsMain"])
    end

    if page == "spotlight" then
        orientationDropdown:Hide()
        spotlightOrientationDropdown:Show()
        spotlightOrientationDropdown:SetEnabled(not selectedLayoutTable[page]["sameArrangementAsMain"])
    else
        orientationDropdown:Show()
        spotlightOrientationDropdown:Hide()
        orientationDropdown:SetEnabled(not selectedLayoutTable[page]["sameArrangementAsMain"])
    end
end

LoadLayoutDB = function(layout, dontShowPreview)
    if layout == "hide" then
        selectedLayout = "default"
        selectedLayoutTable = CellDB["layouts"]["default"]
        dontShowPreview = true
    else
        selectedLayout = layout
        selectedLayoutTable = CellDB["layouts"][layout]
    end

    F.Debug("LoadLayoutDB:", layout, dontShowPreview)

    layoutDropdown:SetSelectedValue(selectedLayout)

    UpdateSliderStatus()

    -- maxColumns
    rcSlider:SetValue(selectedLayoutTable["main"]["maxColumns"])

    -- groupSpacing, unitsPerColumn
    unitsSlider:SetValue(selectedLayoutTable["main"]["unitsPerColumn"])
    groupSpacingSlider:SetValue(selectedLayoutTable["main"]["groupSpacing"])

    -- bar orientation
    barOrientationDropdown:SetSelectedValue(selectedLayoutTable["barOrientation"][1])
    rotateTexCB:SetChecked(selectedLayoutTable["barOrientation"][2])

    -- pages
    LoadPageDB(selectedPage)
    combineGroupsCB:SetChecked(selectedLayoutTable["main"]["combineGroups"])
    sortByRoleCB:SetChecked(selectedLayoutTable["main"]["sortByRole"])
    if selectedLayoutTable["main"]["sortByRole"] then
        roleOrderWidget:Show()
    else
        roleOrderWidget:Hide()
    end
    roleOrderWidget:Load(selectedLayoutTable["main"]["roleOrder"])
    hideSelfCB:SetChecked(selectedLayoutTable["main"]["hideSelf"])
    soloPetCB:SetChecked(selectedLayoutTable["pet"]["soloEnabled"])
    partyPetsCB:SetChecked(selectedLayoutTable["pet"]["partyEnabled"])
    partyPetsDetachedCB:SetEnabled(selectedLayoutTable["pet"]["partyEnabled"])
    partyPetsDetachedCB:SetChecked(selectedLayoutTable["pet"]["partyDetached"])
    raidPetsCB:SetChecked(selectedLayoutTable["pet"]["raidEnabled"])
    showNpcCB:SetChecked(selectedLayoutTable["npc"]["enabled"])
    separateNpcCB:SetChecked(selectedLayoutTable["npc"]["separate"])
    separateNpcCB:SetEnabled(selectedLayoutTable["npc"]["enabled"])
    spotlightCB:SetChecked(selectedLayoutTable["spotlight"]["enabled"])
    hidePlaceholderCB:SetChecked(selectedLayoutTable["spotlight"]["hidePlaceholder"])

    UpdateGroupFilter()
    UpdatePreviewButton()
    if not dontShowPreview then
        UpdateLayoutPreview()
        UpdateNPCPreview()
        UpdatePetPreview()
        UpdateSpotlightPreview()
    end
end

LoadLayoutAutoSwitchDB = function()
    if Cell.isRetail then
        P.Height(autoSwitchFrame, 513)
        if Cell.vars.layoutAutoSwitchBy == "spec" then
            currentProfileBox.text:SetText("|T"..Cell.vars.playerSpecIcon..":12:12:0:0:12:12:1:11:1:11|t "..Cell.vars.playerSpecName)
        else
            currentProfileBox.text:SetText(F.GetDefaultRoleIconEscapeSequence(Cell.vars.playerSpecRole, 12).." ".._G[Cell.vars.playerSpecRole])
        end

        typeSwitch:SetSelected(Cell.vars.layoutAutoSwitchBy)
        raidInstanceDropdown:SetSelectedValue(Cell.vars.layoutAutoSwitch["raid_instance"])
        raidMythicDropdown:SetSelectedValue(Cell.vars.layoutAutoSwitch["raid_mythic"])
        bg15Dropdown:SetSelectedValue(Cell.vars.layoutAutoSwitch["battleground15"])
        bg40Dropdown:SetSelectedValue(Cell.vars.layoutAutoSwitch["battleground40"])

    elseif Cell.isCata or Cell.isWrath then
        P.Height(autoSwitchFrame, 478)
        if Cell.vars.activeTalentGroup == 1 then
            currentProfileBox.text:SetText("|TInterface\\AddOns\\Cell\\Media\\Icons\\1:13|t "..L["Primary Talents"])
        else
            currentProfileBox.text:SetText("|TInterface\\AddOns\\Cell\\Media\\Icons\\2:13|t "..L["Secondary Talents"])
        end
        raid10Dropdown:SetSelectedValue(Cell.vars.layoutAutoSwitch["raid10"])
        raid25Dropdown:SetSelectedValue(Cell.vars.layoutAutoSwitch["raid25"])
        bg15Dropdown:SetSelectedValue(Cell.vars.layoutAutoSwitch["battleground15"])
        bg40Dropdown:SetSelectedValue(Cell.vars.layoutAutoSwitch["battleground40"])

    elseif Cell.isVanilla then
        P.Height(autoSwitchFrame, 378)
        currentProfileBox.text:SetText("|TInterface\\AddOns\\Cell\\Media\\Icons\\1:13|t "..L["Primary Talents"])
        raidInstanceDropdown:SetSelectedValue(Cell.vars.layoutAutoSwitch["raid_instance"])
        bgDropdown:SetSelectedValue(Cell.vars.layoutAutoSwitch["battleground"])
    end

    soloDropdown:SetSelectedValue(Cell.vars.layoutAutoSwitch["solo"])
    partyDropdown:SetSelectedValue(Cell.vars.layoutAutoSwitch["party"])
    raidOutdoorDropdown:SetSelectedValue(Cell.vars.layoutAutoSwitch["raid_outdoor"])
    arenaDropdown:SetSelectedValue(Cell.vars.layoutAutoSwitch["arena"])
end

local function UpdateLayoutAutoSwitch(layout, which)
    if not init then return end
    if which then return end

    if layoutsTab:IsVisible() then
        -- NOTE: group type changed / spec changed
        LoadLayoutDB(Cell.vars.currentLayout)
        LoadLayoutAutoSwitchDB()
        F.HidePowerFilters()
    end

    soloText:SetText(soloText.text)
    partyText:SetText(partyText.text)
    raidOutdoorText:SetText(raidOutdoorText.text)
    arenaText:SetText(arenaText.text)
    if raidInstanceText then raidInstanceText:SetText(raidInstanceText.text) end
    if raidMythicText then raidMythicText:SetText(raidMythicText.text) end
    if raid10Text then raid10Text:SetText(raid10Text.text) end
    if raid25Text then raid25Text:SetText(raid25Text.text) end
    if bg15Text then bg15Text:SetText(bg15Text.text) end
    if bg40Text then bg40Text:SetText(bg40Text.text) end
    if bgText then bgText:SetText(bgText.text) end

    if Cell.vars.inBattleground then
        if Cell.vars.inBattleground == 15 then
            bg15Text:SetText(Cell.GetAccentColorString()..bg15Text.text.."*")
        elseif Cell.vars.inBattleground == 40 then
            bg40Text:SetText(Cell.GetAccentColorString()..bg40Text.text.."*")
        elseif Cell.vars.inBattleground == 5 then -- arena
            arenaText:SetText(Cell.GetAccentColorString()..arenaText.text.."*")
        else
            bgText:SetText(Cell.GetAccentColorString()..bgText.text.."*")
        end
    else
        if Cell.vars.groupType == "solo" then
            soloText:SetText(Cell.GetAccentColorString()..soloText.text.."*")
        elseif Cell.vars.groupType == "party" then
            partyText:SetText(Cell.GetAccentColorString()..partyText.text.."*")
        else
            if Cell.vars.inInstance then
                if Cell.isRetail then
                    if Cell.vars.inMythic then
                        raidMythicText:SetText(Cell.GetAccentColorString()..raidMythicText.text.."*")
                    else
                        raidInstanceText:SetText(Cell.GetAccentColorString()..raidInstanceText.text.."*")
                    end
                elseif Cell.isCata or Cell.isWrath then
                    if Cell.vars.raidType == "raid10" then
                        raid10Text:SetText(Cell.GetAccentColorString()..raid10Text.text.."*")
                    else
                        raid25Text:SetText(Cell.GetAccentColorString()..raid25Text.text.."*")
                    end
                elseif Cell.isVanilla then
                    raidInstanceText:SetText(Cell.GetAccentColorString()..raidInstanceText.text.."*")
                end
            else
                raidOutdoorText:SetText(Cell.GetAccentColorString()..raidOutdoorText.text.."*")
            end
        end
    end
end
Cell.RegisterCallback("UpdateLayout", "LayoutsTab_UpdateLayout", UpdateLayoutAutoSwitch)

local function UpdateAppearance()
    if previewButton and selectedLayout == Cell.vars.currentLayout then
        UpdatePreviewButton("appearance")
    end
end
Cell.RegisterCallback("UpdateAppearance", "LayoutsTab_UpdateAppearance", UpdateAppearance)

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
Cell.RegisterCallback("UpdateIndicators", "LayoutsTab_UpdateIndicators", UpdateIndicators)

local function LayoutImported(name)
    if Cell.vars.currentLayout == name then -- update overwrite
        F.UpdateLayout(Cell.vars.layoutGroupType, true)
    elseif init then -- load new
        -- update dropdown
        layoutDropdown:AddItem({
            ["text"] = name,
            ["value"] = name,
            ["onClick"] = function()
                LoadLayoutDB(name)
                UpdateButtonStates()
            end,
        })
        LoadAutoSwitchDropdowns()
    end

    if init then
        LoadLayoutDB(name)
        UpdateButtonStates()
    end
end
Cell.RegisterCallback("LayoutImported", "LayoutsTab_LayoutImported", LayoutImported)

local function ShowTab(tab)
    if tab == "layouts" then
        if not init then
            init = true

            CreateLayoutPane()
            CreateAutoSwitchPane()
            UpdateLayoutAutoSwitch()
            CreateGroupFilterPane()
            CreateLayoutSetupPane()
            CreateBarOrientationPane()
            CreateMiscPane()

            LoadLayoutDropdown()
            LoadAutoSwitchDropdowns()

            -- mask
            F.ApplyCombatProtectionToFrame(layoutsTab)
            F.ApplyCombatProtectionToFrame(autoSwitchFrame)
            Cell.CreateMask(layoutsTab, nil, {1, -1, -1, 1})
            layoutsTab.mask:Hide()
            Cell.CreateMask(autoSwitchFrame, nil, {1, -1, -1, 1})
            autoSwitchFrame.mask:Hide()
            layoutsTab.mask:SetScript("OnShow", function()
                autoSwitchFrame.mask:Show()
            end)
            layoutsTab.mask:SetScript("OnHide", function()
                autoSwitchFrame.mask:Hide()
            end)
        end

        -- UpdateEnabledLayoutText()

        -- if selectedLayout ~= Cell.vars.currentLayout then
            LoadLayoutDB(Cell.vars.currentLayout)
        -- end

        LoadLayoutAutoSwitchDB()

        UpdateButtonStates()

        layoutsTab:Show()
    else
        layoutsTab:Hide()
    end
end
Cell.RegisterCallback("ShowOptionsTab", "LayoutsTab_ShowTab", ShowTab)

layoutsTab:SetScript("OnHide", function()
    if layoutsTab:IsShown() then
        layoutsTab:SetScript("OnShow", function()
            LoadLayoutDB(Cell.vars.currentLayout)
            LoadLayoutAutoSwitchDB()
            UpdateButtonStates()
        end)
    else
        layoutsTab:SetScript("OnShow", nil)
    end
    HidePreviews()
end)

-------------------------------------------------
-- sharing functions
-------------------------------------------------
function F.ShowLayout(name)
    F.Print(L["Layout imported: %s."]:format(name))
    F.ShowLayousTab()
    LoadLayoutDropdown()
    LoadAutoSwitchDropdowns()
    LoadLayoutDB(name)
    UpdateButtonStates()
end