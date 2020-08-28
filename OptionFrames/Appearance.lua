local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

local appearanceTab = Cell:CreateFrame("CellOptionsFrame_AppearanceTab", Cell.frames.optionsFrame, nil, nil, true)
Cell.frames.appearanceTab = appearanceTab
appearanceTab:SetAllPoints(Cell.frames.optionsFrame)
appearanceTab:Hide()

local selectedLayout, selectedLayoutTable
-------------------------------------------------
-- preview frame
-------------------------------------------------
local previewFrame

local previewButton = CreateFrame("Button", appearanceTab:GetName().."_PreviewButton", appearanceTab, "CellUnitButtonTemplate")
previewButton:SetPoint("BOTTOMRIGHT", appearanceTab, "BOTTOMLEFT", -5, 0)
-- previewButton:SetAttribute("unit", "player")
previewButton:UnregisterAllEvents()
previewButton:SetScript("OnEnter", nil)
previewButton:SetScript("OnLeave", nil)
previewButton:SetScript("OnShow", nil)
previewButton:SetScript("OnHide", nil)

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

        previewButton.widget.nameText:SetFont(CELL_FONT_NAME:GetFont(), selectedLayoutTable["font"]["name"])
        previewButton.widget.vehicleText:SetFont(CELL_FONT_STATUS:GetFont(), selectedLayoutTable["font"]["status"])
        previewButton.widget.statusText:SetFont(CELL_FONT_STATUS:GetFont(), selectedLayoutTable["font"]["status"])

        previewButton:SetScript("OnSizeChanged", function(self)
            F:SetTextLimitWidth(self.widget.nameText, name, 0.75)
			F:SetTextLimitWidth(self.widget.vehicleText, vehicleName, 0.75)
        end)
    end

    if not which or which == "size" then
        previewButton:SetSize(unpack(selectedLayoutTable["size"]))
    end

    if not which or which == "texture" then
        previewButton.widget.healthBar:SetStatusBarTexture(which and value or Cell.vars.texture)
        previewButton.widget.powerBar:SetStatusBarTexture(which and value or Cell.vars.texture)
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
-- texture
-------------------------------------------------
local textureText = Cell:CreateSeparator(L["Texture"], appearanceTab, 188)
textureText:SetPoint("TOPLEFT", 5, -5)

local textureDropdown = Cell:CreateTextureDropdown(appearanceTab, 150)
textureDropdown:SetPoint("TOPLEFT", textureText, "BOTTOMLEFT", 5, -12)

local texturesLoaded
local function CheckTextures()
    if texturesLoaded then return end -- texture already loaded
    
    local items = {}
    local textures, textureNames
    local defaultTexture, defaultTextureName = "Interface\\AddOns\\Cell\\Media\\statusbar.tga", "Cell ".._G.DEFAULT
    
    local LSM = LibStub("LibSharedMedia-3.0")
    if LSM then
        textures, textureNames = F:Copy(LSM:HashTable("statusbar")), F:Copy(LSM:List("statusbar"))
        -- insert default texture
        tinsert(textureNames, 1, defaultTextureName)
        textures[defaultTextureName] = defaultTexture

        for _, name in pairs(textureNames) do
            tinsert(items, {
                ["text"] = name,
                ["texture"] = textures[name],
                ["onClick"] = function()
                    CellDB["texture"] = name
                    Cell:FireEvent("UpdateLayout", nil, "texture")
                    UpdatePreviewButton("texture", textures[name])
                end,
            })
        end
    else
        textureNames = {defaultTextureName}
        textures = {[defaultTextureName] = defaultTexture}

        tinsert(items, {
            ["text"] = defaultTextureName,
            ["texture"] = defaultTexture,
            ["onClick"] = function()
                CellDB["texture"] = defaultTextureName
                Cell:FireEvent("UpdateLayout", nil, "texture")
                UpdatePreviewButton("texture", textures[name])
            end,
        })
    end
    textureDropdown:SetItems(items)

    -- validation
    if textures[CellDB["texture"]] then
        textureDropdown:SetSelected(CellDB["texture"], textures[CellDB["texture"]])
    else
        textureDropdown:SetSelected(defaultTextureName, defaultTexture)
    end

    texturesLoaded = true
end


-------------------------------------------------
-- scale
-------------------------------------------------
local scaleText = Cell:CreateSeparator(L["Scale"], appearanceTab, 188)
scaleText:SetPoint("TOPLEFT", 203, -5)

local scaleDropdown = Cell:CreateDropdownMenu(appearanceTab, 150)
scaleDropdown:SetPoint("TOPLEFT", scaleText, "BOTTOMLEFT", 5, -12)

local scales = {
    [1] = "100%",
    [1.5] = "150%",
    [2] = "200%",
    [2.5] = "250%",
    [3] = "300%",
}

do
    local indices = {1, 1.5, 2, 2.5, 3}
    local items = {}
    for _, value in pairs(indices) do
        table.insert(items, {
            ["text"] = scales[value],
            ["onClick"] = function()
                CellDB["scale"] = value
                Cell:FireEvent("UpdateLayout", nil, "scale")
            end,
        })
    end
    scaleDropdown:SetItems(items)
end

-------------------------------------------------
-- font outline
-------------------------------------------------
local fontOutlineText = Cell:CreateSeparator(L["Font Outline"], appearanceTab, 188)
fontOutlineText:SetPoint("TOPLEFT", 5, -70)

-- drop down
local fontOutlineDropdown = Cell:CreateDropdownMenu(appearanceTab, 150)
fontOutlineDropdown:SetPoint("TOPLEFT", fontOutlineText, "BOTTOMLEFT", 5, -12)
fontOutlineDropdown:SetItems({
    {
        ["text"] = L["Shadow"],
        ["onClick"] = function()
            CellDB["outline"] = "Shadow"
            Cell:FireEvent("UpdateLayout", nil, "font")
            UpdatePreviewButton("font")
        end,
    },
    {
        ["text"] = L["Outline"],
        ["onClick"] = function()
            CellDB["outline"] = "Outline"
            Cell:FireEvent("UpdateLayout", nil, "font")
            UpdatePreviewButton("font")
        end,
    },
    {
        ["text"] = L["Monochrome Outline"],
        ["onClick"] = function()
            CellDB["outline"] = "Monochrome Outline"
            Cell:FireEvent("UpdateLayout", nil, "font")
            UpdatePreviewButton("font")
        end,
    },
})

-------------------------------------------------
-- hide blizzard
-------------------------------------------------
local blizzardText = Cell:CreateSeparator(L["Blizzard Raid Frame"], appearanceTab, 188)
blizzardText:SetPoint("TOPLEFT", 203, -70)

local hideBlizzardCB = Cell:CreateCheckButton(appearanceTab, L["Hide Blizzard Raid Frame"], function(checked, self)
    CellDB["hideBlizzard"] = checked
end, L["Hide Blizzard Raid Frame"], L["Require reload of the UI"])
hideBlizzardCB:SetPoint("TOPLEFT", blizzardText, "BOTTOMLEFT", 5, -15)

-------------------------------------------------
-- layout
-------------------------------------------------
local LoadLayoutDB, UpdateButtonStates

local layoutText = Cell:CreateSeparator(L["Layout"], appearanceTab, 387)
layoutText:SetPoint("TOPLEFT", 5, -135)

local enabledLayoutText = appearanceTab:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET_TITLE")
enabledLayoutText:SetPoint("LEFT", layoutText, "RIGHT", 5, 0)
enabledLayoutText:SetJustifyH("LEFT")

local function UpdateEnabledLayoutText()
    enabledLayoutText:SetText("|cFF777777"..L["currently enabled"]..": "..Cell.vars.currentLayout)
end

-- drop down
local layoutDropdown = Cell:CreateDropdownMenu(appearanceTab, 150)
layoutDropdown:SetPoint("TOPLEFT", layoutText, "BOTTOMLEFT", 5, -12)

local function LoadLayoutDropdown()
    local layout, layouts = CellDB["layout"], CellDB["layouts"]

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
    layoutDropdown:SetSelected(CellDB["layout"])
end

-- mask
Cell:CreateMask(appearanceTab, nil, {1, -75, -1, 1})
appearanceTab.mask:Hide()

-- apply
local applyBtn = Cell:CreateButton(appearanceTab, L["Apply"], "class-hover", {50, 20})
applyBtn:SetPoint("LEFT", layoutDropdown, "RIGHT", 20, 0)
applyBtn:SetScript("OnClick", function()
    CellDB["layout"] = selectedLayout
    F:UpdateLayout()
    UpdateButtonStates()
    UpdateEnabledLayoutText()
end)

-- rename
local renameBtn = Cell:CreateButton(appearanceTab, L["Rename"], "class-hover", {50, 20})
renameBtn:SetPoint("LEFT", applyBtn, "RIGHT", -1, 0)
renameBtn:SetScript("OnClick", function()
    local popup = Cell:CreateConfirmPopup(appearanceTab, 200, L["Rename layout"].." "..selectedLayout, function(self)
        local name = strtrim(self.editBox:GetText())
        if name ~= "" and not CellDB["layouts"][name] then
            -- update db
            CellDB["layouts"][name] = F:Copy(CellDB["layouts"][selectedLayout])
            CellDB["layouts"][selectedLayout] = nil

            if selectedLayout == Cell.vars.currentLayout then
                CellDB["layout"] = name
                
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
    popup:SetPoint("TOPLEFT", 100, -100)
end)

-- new
local newBtn = Cell:CreateButton(appearanceTab, L["New"], "class-hover", {50, 20})
newBtn:SetPoint("LEFT", renameBtn, "RIGHT", -1, 0)
newBtn:SetScript("OnClick", function()
    local popup = Cell:CreateConfirmPopup(appearanceTab, 200, L["Create new layout"], function(self)
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
    popup:SetPoint("TOPLEFT", 100, -100)
end)

-- delete
local deleteBtn = Cell:CreateButton(appearanceTab, L["Delete"], "class-hover", {50, 20})
deleteBtn:SetPoint("LEFT", newBtn, "RIGHT", -1, 0)
deleteBtn:SetScript("OnClick", function()
    local popup = Cell:CreateConfirmPopup(appearanceTab, 200, L["Delete layout"].." "..selectedLayout.."?", function(self)
        CellDB["layouts"][selectedLayout] = nil
        F:Print(L["Layout deleted: "]..selectedLayout..".")
        -- update dropdown
        layoutDropdown:RemoveCurrentItem()
        layoutDropdown:SetSelected(Cell.vars.currentLayout)
        LoadLayoutDB(Cell.vars.currentLayout)
        UpdateButtonStates()
    end, false, true)
    popup:SetPoint("TOPLEFT", 100, -100)
end)

UpdateButtonStates = function()
    if selectedLayout == Cell.vars.currentLayout then
        applyBtn:SetEnabled(false)
        deleteBtn:SetEnabled(false)
        
        if selectedLayout == "default" then
            renameBtn:SetEnabled(false)
        else
            renameBtn:SetEnabled(true)
        end

    else -- selectedLayout ~= Cell.vars.currentLayout
        applyBtn:SetEnabled(true)
        
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
local groupFilterText = Cell:CreateSeparator(L["Group Filter"], appearanceTab, 387)
groupFilterText:SetPoint("TOPLEFT", 5, -200)

local groupButtons = {}
for i = 1, 8 do
    groupButtons[i] = Cell:CreateButton(appearanceTab, i, "class-hover", {20, 20})
    
    if i == 1 then
        groupButtons[i]:SetPoint("TOPLEFT", groupFilterText, "BOTTOMLEFT", 5, -12)
    else
        groupButtons[i]:SetPoint("LEFT", groupButtons[i-1], "RIGHT", 3, 0)
    end
end

-------------------------------------------------
-- button size
-------------------------------------------------
local buttonSizeText = Cell:CreateSeparator(L["Unit Button Size"], appearanceTab, 122)
buttonSizeText:SetPoint("TOPLEFT", 5, -265)

-- width
local widthSlider = Cell:CreateSlider(L["Width"], appearanceTab, 40, 100, 100, 2, function(value)
    selectedLayoutTable["size"][1] = value
    if selectedLayout == Cell.vars.currentLayout then
        Cell:FireEvent("UpdateLayout", selectedLayout, "size")
    end
    UpdatePreviewButton("size")
end)
widthSlider:SetPoint("TOPLEFT", buttonSizeText, "BOTTOMLEFT", 5, -25)

-- height
local heightSlider = Cell:CreateSlider(L["Height"], appearanceTab, 20, 80, 100, 2, function(value)
    selectedLayoutTable["size"][2] = value
    if selectedLayout == Cell.vars.currentLayout then
        Cell:FireEvent("UpdateLayout", selectedLayout, "size")
    end
    UpdatePreviewButton("size")
end)
heightSlider:SetPoint("TOP", widthSlider, "BOTTOM", 0, -40)

-------------------------------------------------
-- font size
-------------------------------------------------
local fontSizeText = Cell:CreateSeparator(L["Font Size"], appearanceTab, 122)
fontSizeText:SetPoint("TOPLEFT", 137, -265)

-- name text
local nameFontSlider = Cell:CreateSlider(L["Name"], appearanceTab, 5, 20, 100, 1, function(value)
    selectedLayoutTable["font"]["name"] = value
    if selectedLayout == Cell.vars.currentLayout then
        Cell:FireEvent("UpdateLayout", selectedLayout, "font")
    end
    UpdatePreviewButton("nameFont", value)
end)
nameFontSlider:SetPoint("TOPLEFT", fontSizeText, "BOTTOMLEFT", 5, -25)

-- status text
local statusFontSlider = Cell:CreateSlider(L["Status"], appearanceTab, 5, 20, 100, 1, function(value)
    selectedLayoutTable["font"]["status"] = value
    if selectedLayout == Cell.vars.currentLayout then
        Cell:FireEvent("UpdateLayout", selectedLayout, "font")
    end
    UpdatePreviewButton("statusFont", value)
end)
statusFontSlider:SetPoint("TOP", nameFontSlider, "BOTTOM", 0, -40)

-------------------------------------------------
-- icon size
-------------------------------------------------
local iconSizeText = Cell:CreateSeparator(L["Icon Size"], appearanceTab, 122)
iconSizeText:SetPoint("TOPLEFT", 269, -265)

-- center
local centerIconSlider = Cell:CreateSlider(L["Center Icon"], appearanceTab, 15, 25, 100, 1, function(value)
    selectedLayoutTable["icon"]["center"] = value
    UpdatePreviewButton()
end)
centerIconSlider:SetPoint("TOPLEFT", iconSizeText, "BOTTOMLEFT", 5, -25)

-- debuff
local debuffIconSlider = Cell:CreateSlider(L["Debuff Icon"], appearanceTab, 10, 20, 100, 1, function(value)
    selectedLayoutTable["icon"]["debuff"] = value
    UpdatePreviewButton()
end)
debuffIconSlider:SetPoint("TOP", centerIconSlider, "BOTTOM", 0, -40)
debuffIconSlider:SetEnabled(false)

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

    centerIconSlider:SetValue(selectedLayoutTable["icon"]["center"])
    debuffIconSlider:SetValue(selectedLayoutTable["icon"]["debuff"])

    UpdatePreviewButton()
end

local function ShowTab(tab)
    if tab == "appearance" then
        appearanceTab:Show()
        if selectedLayout then return end
        
        -- load data
        CheckTextures()
        scaleDropdown:SetSelected(scales[CellDB["scale"]])
        fontOutlineDropdown:SetSelected(CellDB["outline"])
        hideBlizzardCB:SetChecked(CellDB["hideBlizzard"])

        -- layout related
        UpdateEnabledLayoutText()
        LoadLayoutDropdown()
        LoadLayoutDB(Cell.vars.currentLayout)
        UpdateButtonStates()
    else
        appearanceTab:Hide()
    end
end
Cell:RegisterEvent("ShowOptionsTab", "AppearanceTab_ShowTab", ShowTab)
