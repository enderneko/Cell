local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

local layoutsTab = Cell:CreateFrame("CellOptionsFrame_LayoutsTab", Cell.frames.optionsFrame, nil, nil, true)
Cell.frames.layoutsTab = layoutsTab
layoutsTab:SetAllPoints(Cell.frames.optionsFrame)
layoutsTab:Hide()

local selectedLayout, selectedLayoutTable
-------------------------------------------------
-- preview frame
-------------------------------------------------
local previewButton = CreateFrame("Button", "LayoutPreviewButton", layoutsTab, "CellUnitButtonTemplate")
previewButton:SetPoint("TOPRIGHT", layoutsTab, "TOPLEFT", -5, -20)
-- previewButton:SetAttribute("unit", "player")
previewButton:UnregisterAllEvents()
previewButton:SetScript("OnEnter", nil)
previewButton:SetScript("OnLeave", nil)
previewButton:SetScript("OnShow", nil)
previewButton:SetScript("OnHide", nil)
previewButton:SetScript("OnUpdate", nil)
previewButton:Show()

local previewButtonBG = Cell:CreateFrame(layoutsTab:GetName().."_PreviewButtonBG", layoutsTab)
previewButtonBG:SetPoint("TOPLEFT", previewButton, 0, 20)
previewButtonBG:SetPoint("BOTTOMRIGHT", previewButton, "TOPRIGHT")
previewButtonBG:SetFrameStrata("BACKGROUND")
Cell:StylizeFrame(previewButtonBG, {.1, .1, .1, .7}, {0, 0, 0, 0})
previewButtonBG:Show()

local previewText = previewButtonBG:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET_TITLE")
previewText:SetPoint("TOP", 0, -3)
previewText:SetText(L["Preview"])

local function UpdatePreviewButton(which, value)
    if not previewButton.loaded then
        previewButton.loaded = true
        
        -- bar
        previewButton.widget.healthBar:SetStatusBarColor(F:GetClassColor(Cell.vars.playerClass))
        local r, g, b = F:GetPowerColor("player")
        previewButton.widget.powerBar:SetStatusBarColor(r, g, b)
        
        -- text
        local name, vehicleName, status = UnitName("player"), L["vehicle name"], L["DEAD"]
        
        previewButton.widget.nameText:SetText(name)
        previewButton.widget.vehicleText:SetText(vehicleName)
        previewButton.widget.statusText:SetText(status)
        previewButton.widget.statusTextFrame:Show()

        previewButton.widget.nameText:SetFont(CELL_FONT_NAME:GetFont(), selectedLayoutTable["font"]["name"])
        previewButton.widget.vehicleText:SetFont(CELL_FONT_STATUS:GetFont(), selectedLayoutTable["font"]["status"])
        previewButton.widget.statusText:SetFont(CELL_FONT_STATUS:GetFont(), selectedLayoutTable["font"]["status"])

        previewButton:SetScript("OnSizeChanged", function(self)
            F:SetTextLimitWidth(self.widget.nameText, name, 0.75)
			F:SetTextLimitWidth(self.widget.vehicleText, vehicleName, 0.75)
        end)
    end

    if not which or which == "texture" then
        previewButton.widget.healthBar:SetStatusBarTexture(Cell.vars.texture)
        previewButton.widget.powerBar:SetStatusBarTexture(Cell.vars.texture)
    end
    
    if not which or which == "size" then
        previewButton:SetSize(unpack(selectedLayoutTable["size"]))
    end

    local flags
    if CellDB["outline"] == "Outline" then
        flags = "OUTLINE"
    elseif CellDB["outline"] == "Monochrome Outline" then
        flags = "OUTLINE, MONOCHROME"
    end    

    if not which or which == "font" or which == "nameFont" then
        previewButton.widget.nameText:SetFont(CELL_FONT_NAME:GetFont(), value or selectedLayoutTable["font"]["name"], flags)
        previewButton:GetScript("OnSizeChanged")(previewButton)
    end
    
    if not which or which == "font" or which == "statusFont" then
        previewButton.widget.vehicleText:SetFont(CELL_FONT_NAME:GetFont(), value or selectedLayoutTable["font"]["status"], flags)
        previewButton.widget.statusText:SetFont(CELL_FONT_NAME:GetFont(), value or selectedLayoutTable["font"]["status"], flags)
        previewButton:GetScript("OnSizeChanged")(previewButton)
    end
end

-------------------------------------------------
-- layout
-------------------------------------------------
local LoadLayoutDB, UpdateButtonStates

local layoutText = Cell:CreateSeparator(L["Layout"], layoutsTab, 387)
layoutText:SetPoint("TOPLEFT", 5, -5)

local enabledLayoutText = layoutsTab:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET_TITLE")
enabledLayoutText:SetPoint("LEFT", layoutText, "RIGHT", 5, 0)
enabledLayoutText:SetJustifyH("LEFT")

local function UpdateEnabledLayoutText()
    enabledLayoutText:SetText("|cFF777777"..L["Currently Enabled"]..": "..Cell.vars.currentLayout)
end

-- drop down
local layoutDropdown = Cell:CreateDropdown(layoutsTab, 160)
layoutDropdown:SetPoint("TOPLEFT", layoutText, "BOTTOMLEFT", 5, -12)

local function LoadLayoutDropdown()
    local layout, layouts = CellCharacterDB["layout"], CellDB["layouts"]

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
            ["text"] = value,
            ["onClick"] = function()
                LoadLayoutDB(value)
                UpdateButtonStates()
            end,
        })
    end
    layoutDropdown:SetItems(items)
    layoutDropdown:SetSelected(CellCharacterDB["layout"])
end

-- mask
Cell:CreateMask(layoutsTab, nil, {1, -1, -1, 1})
layoutsTab.mask:Hide()

-- enable
local enableBtn = Cell:CreateButton(layoutsTab, L["Enable"], "class-hover", {50, 20})
enableBtn:SetPoint("LEFT", layoutDropdown, "RIGHT", 20, 0)
enableBtn:SetScript("OnClick", function()
    CellCharacterDB["layout"] = selectedLayout
    F:UpdateLayout()
    Cell:Fire("UpdateAppearance", "font")
    Cell:Fire("UpdateIndicators")
    UpdateButtonStates()
    UpdateEnabledLayoutText()
end)
Cell:RegisterForCloseDropdown(enableBtn)

-- rename
local renameBtn = Cell:CreateButton(layoutsTab, L["Rename"], "class-hover", {50, 20})
renameBtn:SetPoint("LEFT", enableBtn, "RIGHT", -1, 0)
renameBtn:SetScript("OnClick", function()
    local popup = Cell:CreateConfirmPopup(layoutsTab, 200, L["Rename layout"].." "..selectedLayout, function(self)
        local name = strtrim(self.editBox:GetText())
        if name ~= "" and not CellDB["layouts"][name] then
            -- update db
            CellDB["layouts"][name] = F:Copy(CellDB["layouts"][selectedLayout])
            CellDB["layouts"][selectedLayout] = nil
            
            if selectedLayout == Cell.vars.currentLayout then
                CellCharacterDB["layout"] = name
                
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
            
            LoadLayoutDB(name)
            UpdateButtonStates()
            F:Print(L["Layout renamed: "].." "..selectedLayout.." "..L["to"].." "..name..".")
        else
            F:Print(L["Invalid layout name."])
        end
    end, true, true)
    popup:SetPoint("TOPLEFT", 100, -185)
end)
Cell:RegisterForCloseDropdown(renameBtn)

-- new
local newBtn = Cell:CreateButton(layoutsTab, L["New"], "class-hover", {50, 20})
newBtn:SetPoint("LEFT", renameBtn, "RIGHT", -1, 0)
newBtn:SetScript("OnClick", function()
    local popup = Cell:CreateConfirmPopup(layoutsTab, 200, L["Create new layout"], function(self)
        local name = strtrim(self.editBox:GetText())
        if name ~= "" and not CellDB["layouts"][name] then
            -- update db copy current layout
            CellDB["layouts"][name] = F:Copy(CellDB["layouts"][Cell.vars.currentLayout])
            -- update dropdown
            layoutDropdown:AddItem({
                ["text"] = name,
                ["onClick"] = function()
                    LoadLayoutDB(name)
                    UpdateButtonStates()
                end,
            })
            layoutDropdown:SetSelected(name)
            LoadLayoutDB(name)
            UpdateButtonStates()
            F:Print(L["Layout added: "]..name..".")
        else
            F:Print(L["Invalid layout name."])
        end
    end, true, true)
    popup:SetPoint("TOPLEFT", 100, -70)
end)
Cell:RegisterForCloseDropdown(newBtn)

-- delete
local deleteBtn = Cell:CreateButton(layoutsTab, L["Delete"], "class-hover", {50, 20})
deleteBtn:SetPoint("LEFT", newBtn, "RIGHT", -1, 0)
deleteBtn:SetScript("OnClick", function()
    local popup = Cell:CreateConfirmPopup(layoutsTab, 200, L["Delete layout"].." "..selectedLayout.."?", function(self)
        CellDB["layouts"][selectedLayout] = nil
        F:Print(L["Layout deleted: "]..selectedLayout..".")
        -- update dropdown
        layoutDropdown:RemoveCurrentItem()
        layoutDropdown:SetSelected(Cell.vars.currentLayout)
        LoadLayoutDB(Cell.vars.currentLayout)
        UpdateButtonStates()
    end, false, true)
    popup:SetPoint("TOPLEFT", 100, -185)
end)
Cell:RegisterForCloseDropdown(deleteBtn)

UpdateButtonStates = function()
    if selectedLayout == Cell.vars.currentLayout then
        enableBtn:SetEnabled(false)
        deleteBtn:SetEnabled(false)
        
        if selectedLayout == "default" then
            renameBtn:SetEnabled(false)
        else
            renameBtn:SetEnabled(true)
        end

    else -- selectedLayout ~= Cell.vars.currentLayout
        enableBtn:SetEnabled(true)
        
        if selectedLayout == "default" then
            deleteBtn:SetEnabled(false)
            renameBtn:SetEnabled(false)
        else
            deleteBtn:SetEnabled(true)
            renameBtn:SetEnabled(true)
        end
    end
end

-------------------------------------------------
-- group filter
-------------------------------------------------
local groupFilterText = Cell:CreateSeparator(L["Group Filter"], layoutsTab, 387)
groupFilterText:SetPoint("TOPLEFT", 5, -90)

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
for i = 1, 8 do
    groupButtons[i] = Cell:CreateButton(layoutsTab, i, "class-hover", {20, 20})
    groupButtons[i]:SetScript("OnClick", function()
        selectedLayoutTable["groupFilter"][i] = not selectedLayoutTable["groupFilter"][i]
        UpdateButtonBorderColor(selectedLayoutTable["groupFilter"][i], groupButtons[i])

        if selectedLayout == Cell.vars.currentLayout then
            Cell:Fire("UpdateLayout", selectedLayout, "groupFilter")
        end
    end)
    
    if i == 1 then
        groupButtons[i]:SetPoint("TOPLEFT", groupFilterText, "BOTTOMLEFT", 5, -12)
    else
        groupButtons[i]:SetPoint("LEFT", groupButtons[i-1], "RIGHT", 3, 0)
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
local buttonSizeText = Cell:CreateSeparator(L["Unit Button Size"], layoutsTab, 122)
buttonSizeText:SetPoint("TOPLEFT", 5, -175)

-- width
local widthSlider = Cell:CreateSlider(L["Width"], layoutsTab, 40, 100, 100, 2, function(value)
    selectedLayoutTable["size"][1] = value
    if selectedLayout == Cell.vars.currentLayout then
        Cell:Fire("UpdateLayout", selectedLayout, "size")
    end
    UpdatePreviewButton("size")
end)
widthSlider:SetPoint("TOPLEFT", buttonSizeText, "BOTTOMLEFT", 5, -25)

-- height
local heightSlider = Cell:CreateSlider(L["Height"], layoutsTab, 20, 80, 100, 2, function(value)
    selectedLayoutTable["size"][2] = value
    if selectedLayout == Cell.vars.currentLayout then
        Cell:Fire("UpdateLayout", selectedLayout, "size")
    end
    UpdatePreviewButton("size")
end)
heightSlider:SetPoint("TOP", widthSlider, "BOTTOM", 0, -40)

-------------------------------------------------
-- font size
-------------------------------------------------
local fontSizeText = Cell:CreateSeparator(L["Font Size"], layoutsTab, 122)
fontSizeText:SetPoint("TOPLEFT", 137, -175)

-- name text
local nameFontSlider = Cell:CreateSlider(L["Name"], layoutsTab, 5, 20, 100, 1, function(value)
    selectedLayoutTable["font"]["name"] = value
    if selectedLayout == Cell.vars.currentLayout then
        Cell:Fire("UpdateAppearance", "font")
    end
    UpdatePreviewButton("nameFont", value)
end)
nameFontSlider:SetPoint("TOPLEFT", fontSizeText, "BOTTOMLEFT", 5, -25)

-- status text
local statusFontSlider = Cell:CreateSlider(L["Status"], layoutsTab, 5, 20, 100, 1, function(value)
    selectedLayoutTable["font"]["status"] = value
    if selectedLayout == Cell.vars.currentLayout then
        Cell:Fire("UpdateAppearance", "font")
    end
    UpdatePreviewButton("statusFont", value)
end)
statusFontSlider:SetPoint("TOP", nameFontSlider, "BOTTOM", 0, -40)

-------------------------------------------------
-- spacing
-------------------------------------------------
local miscText = Cell:CreateSeparator(L["Spacing"], layoutsTab, 122)
miscText:SetPoint("TOPLEFT", 269, -175)

-- spacing
local spacingSlider = Cell:CreateSlider(L["Spacing"], layoutsTab, 3, 7, 100, 1, function(value)
    selectedLayoutTable["spacing"] = value
    if selectedLayout == Cell.vars.currentLayout then
        Cell:Fire("UpdateLayout", selectedLayout, "spacing")
    end
end)
spacingSlider:SetPoint("TOPLEFT", miscText, "BOTTOMLEFT", 5, -25)

-------------------------------------------------
-- tips
-------------------------------------------------
local tipsText = layoutsTab:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
tipsText:SetPoint("BOTTOMLEFT", 5, 5)
tipsText:SetText("|cff777777"..L["Tips: You can use Shift+Scroll to change a slider's value."])

-------------------------------------------------
-- functions
-------------------------------------------------
LoadLayoutDB = function(layout)
    F:Debug("LoadLayoutDB: "..layout)

    selectedLayout = layout
    selectedLayoutTable = CellDB["layouts"][layout]

    widthSlider:SetValue(selectedLayoutTable["size"][1])
    heightSlider:SetValue(selectedLayoutTable["size"][2])

    nameFontSlider:SetValue(selectedLayoutTable["font"]["name"])
    statusFontSlider:SetValue(selectedLayoutTable["font"]["status"])

    spacingSlider:SetValue(selectedLayoutTable["spacing"])

    UpdateGroupFilter()
    UpdatePreviewButton()
end

local function ShowTab(tab)
    if tab == "layouts" then
        layoutsTab:Show()
        
        if selectedLayout then
            UpdatePreviewButton()
            return
        end
        
        -- layout related
        UpdateEnabledLayoutText()
        LoadLayoutDropdown()
        LoadLayoutDB(Cell.vars.currentLayout)
        UpdateButtonStates()
    else
        layoutsTab:Hide()
    end
end
Cell:RegisterCallback("ShowOptionsTab", "LayoutsTab_ShowTab", ShowTab)