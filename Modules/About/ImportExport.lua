local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

local Serializer = LibStub:GetLibrary("LibSerialize")
local LibDeflate = LibStub:GetLibrary("LibDeflate")
local deflateConfig = {level = 9}

local isImport, imported, exported = false, nil, ""

local importExportFrame, importBtn, title, textArea, includeNicknamesCB, includeCharacterCB
local confirmationFrame
local ignoredIndices = {}

---------------------------------------------------------------------
-- do import
---------------------------------------------------------------------
local function DoImport(noReload)
    -- raid debuffs
    for instanceID in pairs(imported["raidDebuffs"]) do
        if not Cell.snippetVars.loadedDebuffs[instanceID] then
            imported["raidDebuffs"][instanceID] = nil
        end
    end

    -- deal with invalid
    if Cell.isRetail then
        imported["appearance"]["useLibHealComm"] = false
    elseif Cell.isVanilla or Cell.isWrath or Cell.isCata then
        imported["quickCast"] = nil
        imported["quickAssist"] = nil
        imported["appearance"]["healAbsorb"][1] = false
    end

    -- layouts
    local builtInFound = {}
    for _, layout in pairs(imported["layouts"]) do
        -- indicators
        for i =  #layout["indicators"], 1, -1 do
            if layout["indicators"][i]["type"] == "built-in" then -- remove unsupported built-in
                local indicatorName = layout["indicators"][i]["indicatorName"]
                builtInFound[indicatorName] = true
                if not Cell.defaults.indicatorIndices[indicatorName] then
                    tremove(layout["indicators"], i)
                end
            else -- remove invalid spells from custom indicators
                F.FilterInvalidSpells(layout["indicators"][i]["auras"])
            end
        end

        -- powerFilters
        for class, t in pairs(Cell.defaults.layout.powerFilters) do
            if type(layout["powerFilters"][class]) ~= type(t) then
                if type(t) == "table" then
                    layout["powerFilters"][class] = F.Copy(t)
                else
                    layout["powerFilters"][class] = true
                end
            end
        end
    end

    -- add missing indicators
    if F.Getn(builtInFound) ~= Cell.defaults.builtIns then
        for indicatorName, index in pairs(Cell.defaults.indicatorIndices) do
            if not builtInFound[indicatorName] then
                for _, layout in pairs(imported["layouts"]) do
                    tinsert(layout["indicators"], index, Cell.defaults.layout.indicators[index])
                end
            end
        end
    end

    -- click-castings
    local clickCastings
    if imported["clickCastings"] then
        if Cell.flavor == imported.flavor then -- same flavor
            clickCastings = imported["clickCastings"]
        else -- RETAIL -> CLASSIC
            clickCastings = nil
        end
        imported["clickCastings"] = nil

    elseif imported["characterDB"] and imported["characterDB"]["clickCastings"] then
        if (Cell.isVanilla or Cell.isWrath or Cell.isCata) and imported["characterDB"]["clickCastings"]["class"] == Cell.vars.playerClass then -- WRATH -> WRATH, same class
            clickCastings = imported["characterDB"]["clickCastings"]
            if Cell.isVanilla then -- no dual spec system
                clickCastings["useCommon"] = true
            end
        else -- WRATH -> RETAIL
            clickCastings = nil
        end
        imported["characterDB"]["clickCastings"] = nil
    end

    -- layout auto switch
    local layoutAutoSwitch
    if imported["layoutAutoSwitch"] then
        if Cell.flavor == imported.flavor then -- same flavor
            layoutAutoSwitch = imported["layoutAutoSwitch"]
        else -- RETAIL -> WRATH
            layoutAutoSwitch = nil
        end
        imported["layoutAutoSwitch"] = nil

    elseif imported["characterDB"] and imported["characterDB"]["layoutAutoSwitch"] then
        if Cell.isVanilla or Cell.isWrath or Cell.isCata then -- WRATH -> WRATH
            layoutAutoSwitch = imported["characterDB"]["layoutAutoSwitch"]
        else -- CLASSIC -> RETAIL
            layoutAutoSwitch = nil
        end
        imported["characterDB"]["layoutAutoSwitch"] = nil
    end

    -- remove characterDB
    imported["characterDB"] = nil

    -- remove invalid spells
    F.FilterInvalidSpells(imported["debuffBlacklist"])
    F.FilterInvalidSpells(imported["bigDebuffs"])
    F.FilterInvalidSpells(imported["actions"])
    F.FilterInvalidSpells(imported["aoeHealings"] and imported["aoeHealings"]["custom"])
    F.FilterInvalidSpells(imported["defensives"]["custom"])
    F.FilterInvalidSpells(imported["externals"]["custom"])
    F.FilterInvalidSpells(imported["targetedSpellsList"])
    -- F.FilterInvalidSpells(imported["cleuAuras"])

    -- disable autorun
    -- for i = 1, #imported["snippets"] do
    --     imported["snippets"][i]["autorun"] = false
    -- end

    --! filter out ignored
    for index, ignored in pairs(ignoredIndices) do
        if ignored then
            imported[index] = nil
        end
    end

    --! overwrite
    if Cell.isRetail then
        if not ignoredIndices["clickCastings"] then
            CellDB["clickCastings"] = clickCastings
        end
        if not ignoredIndices["layouts"] then
            CellDB["layoutAutoSwitch"] = layoutAutoSwitch
        end
    else
        if not ignoredIndices["clickCastings"] then
            CellCharacterDB["clickCastings"] = clickCastings
        end
        if not ignoredIndices["layouts"] then
            CellCharacterDB["layoutAutoSwitch"] = layoutAutoSwitch
        end
        CellCharacterDB["revise"] = imported["revise"]
    end

    for k, v in pairs(imported) do
        CellDB[k] = v
    end

    if noReload then
        F.Print(L["Profile imported successfully."])
        -- TODO: F.Print(L["Profile imported: %s."])
    else
        ReloadUI()
    end
end

---------------------------------------------------------------------
-- generate export string
---------------------------------------------------------------------
local function GetExportString(includeNicknames, includeCharacter)
    local prefix = "!CELL:"..Cell.versionNum..":ALL!"

    local db = F.Copy(CellDB)

    if not includeNicknames then
        db["nicknames"] = nil
    end

    if includeCharacter then
        db["characterDB"] = F.Copy(CellCharacterDB)
    end

    db["flavor"] = Cell.flavor

    local str = Serializer:Serialize(db) -- serialize
    str = LibDeflate:CompressDeflate(str, deflateConfig) -- compress
    str = LibDeflate:EncodeForPrint(str) -- encode

    return prefix..str
end

---------------------------------------------------------------------
-- import confirmation
---------------------------------------------------------------------
local function CreateImportConfirmationFrame()
    confirmationFrame = CreateFrame("Frame", nil, Cell.frames.aboutTab, "BackdropTemplate")
    confirmationFrame:SetSize(361, 165)
    Cell.StylizeFrame(confirmationFrame, {0.1, 0.1, 0.1, 0.95}, Cell.GetAccentColorTable())
    confirmationFrame:EnableMouse(true)
    confirmationFrame:SetFrameLevel(Cell.frames.aboutTab:GetFrameLevel() + 300)
    confirmationFrame:SetPoint("TOP", importExportFrame, 0, -25)
    confirmationFrame:Hide()

    -- no
    local button2 = Cell.CreateButton(confirmationFrame, L["No"], "red", {55, 17})
    button2:SetPoint("BOTTOMRIGHT")
    button2:SetBackdropBorderColor(Cell.GetAccentColorRGB())
    button2:SetScript("OnClick", function()
        confirmationFrame:Hide()
        importExportFrame:Hide()
    end)

    -- yes
    local button1 = Cell.CreateButton(confirmationFrame, L["Yes"], "green", {55, 17})
    button1:SetPoint("BOTTOMRIGHT", button2, "BOTTOMLEFT", P.Scale(1), 0)
    button1:SetBackdropBorderColor(Cell.GetAccentColorRGB())
    button1:SetScript("OnClick", function()
        DoImport()
        confirmationFrame:Hide()
        importExportFrame:Hide()
    end)

    -- message
    local text1 = confirmationFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET_TITLE")
    text1:SetPoint("LEFT", 10, 0)
    text1:SetPoint("RIGHT", -10, 0)
    text1:SetPoint("TOP", 0, -10)
    text1:SetSpacing(5)
    text1:SetText("|cFFFF7070"..L["Cell settings will be overwritten!"])

    local text2 = confirmationFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    text2:SetPoint("LEFT", 10, 0)
    text2:SetPoint("RIGHT", -10, 0)
    text2:SetPoint("TOP", text1, "BOTTOM", 0, -5)
    text2:SetSpacing(5)
    text2:SetText( "|cFFB7B7B7"..L["Unselected settings will remain"])

    local text3 = confirmationFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    text3:SetPoint("BOTTOMLEFT", 5, 5)
    text3:SetPoint("RIGHT", button1, "LEFT", -10, 0)
    text3:SetJustifyH("LEFT")
    text3:SetText( "|cFFABABAB"..L["Remember to backup your profile"])

    -- checkboxes
    local checkboxes = {}

    -- 1:general
    checkboxes.general = Cell.CreateCheckButton(confirmationFrame, L["General"], function(checked)
        ignoredIndices["general"] = not checked
    end)
    checkboxes.general:SetPoint("TOPLEFT", 15, -55)

    -- 2:appearance
    checkboxes.appearance = Cell.CreateCheckButton(confirmationFrame, L["Appearance"], function(checked)
        ignoredIndices["appearance"] = not checked
        ignoredIndices["debuffTypeColor"] = not checked
    end)
    checkboxes.appearance:SetPoint("TOPLEFT", checkboxes.general, 165, 0)

    -- 3:click-castings
    checkboxes.clickCastings = Cell.CreateCheckButton(confirmationFrame, L["Click-Castings"], function(checked)
        ignoredIndices["clickCastings"] = not checked
    end)
    checkboxes.clickCastings:SetPoint("TOPLEFT", checkboxes.general, "BOTTOMLEFT", 0, -7)

    -- 4:layouts
    checkboxes.layouts = Cell.CreateCheckButton(confirmationFrame, L["Layouts"] .. " & " .. L["Indicators"], function(checked)
        ignoredIndices["layouts"] = not checked
        ignoredIndices["layoutAutoSwitch"] = not checked
        ignoredIndices["dispelBlacklist"] = not checked
        ignoredIndices["debuffBlacklist"] = not checked
        ignoredIndices["bigDebuffs"] = not checked
        ignoredIndices["aoeHealings"] = not checked
        ignoredIndices["defensives"] = not checked
        ignoredIndices["externals"] = not checked
        ignoredIndices["targetedSpellsList"] = not checked
        ignoredIndices["targetedSpellsGlow"] = not checked
        ignoredIndices["crowdControls"] = not checked
        ignoredIndices["actions"] = not checked
        ignoredIndices["indicatorPreview"] = not checked
        ignoredIndices["customTextures"] = not checked
    end)
    checkboxes.layouts:SetPoint("TOPLEFT", checkboxes.appearance, "BOTTOMLEFT", 0, -7)

    -- 5:raid debuffs
    checkboxes.raidDebuffs = Cell.CreateCheckButton(confirmationFrame, L["Raid Debuffs"], function(checked)
        ignoredIndices["raidDebuffs"] = not checked
    end)
    checkboxes.raidDebuffs:SetPoint("TOPLEFT", checkboxes.clickCastings, "BOTTOMLEFT", 0, -7)

    -- 6:utilities
    checkboxes.utilities = Cell.CreateCheckButton(confirmationFrame, L["Utilities"], function(checked)
        ignoredIndices["tools"] = not checked
        ignoredIndices["spellRequest"] = not checked
        ignoredIndices["dispelRequest"] = not checked
        ignoredIndices["quickAssist"] = not checked
        ignoredIndices["quickCast"] = not checked
    end)
    checkboxes.utilities:SetPoint("TOPLEFT", checkboxes.layouts, "BOTTOMLEFT", 0, -7)

    -- 7:code snippets
    checkboxes.snippets = Cell.CreateCheckButton(confirmationFrame, L["Code Snippets"], function(checked)
        ignoredIndices["snippets"] = not checked
    end)
    checkboxes.snippets:SetPoint("TOPLEFT", checkboxes.raidDebuffs, "BOTTOMLEFT", 0, -7)

    -- 8:nickname
    checkboxes.nickname = Cell.CreateCheckButton(confirmationFrame, L["Nickname"], function(checked)
        ignoredIndices["nicknames"] = not checked
    end)
    checkboxes.nickname:SetPoint("TOPLEFT", checkboxes.utilities, "BOTTOMLEFT", 0, -7)

    -- OnHide
    confirmationFrame:SetScript("OnHide", function()
        confirmationFrame:Hide()
        if Cell.frames.aboutTab.mask then Cell.frames.aboutTab.mask:Hide() end
    end)

    -- OnShow
    confirmationFrame:SetScript("OnShow", function()
        wipe(ignoredIndices)
        ignoredIndices["nicknames"] = true

        for name, cb in pairs(checkboxes) do
            if name == "nickname" then
                cb:SetChecked(false)
                cb:SetEnabled(imported["nicknames"])
            else
                cb:SetChecked(true)
            end
        end
    end)
end

---------------------------------------------------------------------
-- import/export frame
---------------------------------------------------------------------
local function CreateImportExportFrame()
    importExportFrame = CreateFrame("Frame", "CellOptionsFrame_ImportExport", Cell.frames.aboutTab, "BackdropTemplate")
    importExportFrame:Hide()
    Cell.StylizeFrame(importExportFrame, nil, Cell.GetAccentColorTable())
    importExportFrame:EnableMouse(true)
    importExportFrame:SetFrameLevel(Cell.frames.aboutTab:GetFrameLevel() + 50)
    P.Size(importExportFrame, 430, 170)
    importExportFrame:SetPoint("BOTTOMLEFT", P.Scale(1), 27)

    if not Cell.frames.aboutTab.mask then
        Cell.CreateMask(Cell.frames.aboutTab, nil, {1, -1, -1, 1})
        Cell.frames.aboutTab.mask:Hide()
    end

    -- close
    local closeBtn = Cell.CreateButton(importExportFrame, "×", "red", {18, 18}, false, false, "CELL_FONT_SPECIAL", "CELL_FONT_SPECIAL")
    closeBtn:SetPoint("TOPRIGHT", P.Scale(-5), P.Scale(-1))
    closeBtn:SetScript("OnClick", function() importExportFrame:Hide() end)

    -- import
    importBtn = Cell.CreateButton(importExportFrame, L["Import"], "green", {57, 18})
    importBtn:Hide()
    importBtn:SetPoint("TOPRIGHT", closeBtn, "TOPLEFT", P.Scale(1), 0)
    importBtn:SetScript("OnClick", function()
        -- lower frame level
        importExportFrame:SetFrameLevel(Cell.frames.aboutTab:GetFrameLevel() + 20)

        confirmationFrame:Show()

        -- local text = "|cFFFF7070"..L["All Cell settings will be overwritten!"].."|r\n"..
        --     "|cFFB7B7B7"..L["Autorun will be disabled for all code snippets"].."|r\n"..
        --     L["|cff1Aff1AYes|r - Overwrite"].."\n".."|cffff1A1A"..L["No"].."|r - "..L["Cancel"]
        -- local popup = Cell.CreateConfirmPopup(Cell.frames.aboutTab, 200, text, function(self)
        --     DoImport()
        -- end, function()
        --     importExportFrame:Hide()
        -- end, true)
        -- popup:SetPoint("TOPLEFT", importExportFrame, 117, -25)

        textArea.eb:ClearFocus()
    end)

    -- title
    title = importExportFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_CLASS")
    title:SetPoint("TOPLEFT", 5, -5)

    -- export include nickname settings
    includeNicknamesCB = Cell.CreateCheckButton(importExportFrame, L["Include Nickname Settings"], function(checked)
        exported = GetExportString(checked, includeCharacterCB:GetChecked())
        textArea:SetText(exported)
    end)
    includeNicknamesCB:SetPoint("TOPLEFT", 5, -25)
    includeNicknamesCB:Hide()

    -- export include character settings
    includeCharacterCB = Cell.CreateCheckButton(importExportFrame, L["Include Character Settings"], function(checked)
        exported = GetExportString(includeNicknamesCB:GetChecked(), checked)
        textArea:SetText(exported)
    end)
    includeCharacterCB:SetPoint("TOPLEFT", includeNicknamesCB, "TOPRIGHT", 200, 0)
    includeCharacterCB:Hide()
    Cell.SetTooltips(includeCharacterCB, "ANCHOR_TOPLEFT", 0, 2, L["Click-Castings"]..", "..L["Layout Auto Switch"])

    -- textArea
    textArea = Cell.CreateScrollEditBox(importExportFrame, function(eb, userChanged)
        if userChanged then
            if isImport then
                imported = nil
                local text = eb:GetText()
                -- check
                local version, data = string.match(text, "^!CELL:(%d+):ALL!(.+)$")
                version = tonumber(version)

                if version and data then
                    if version >= Cell.MIN_VERSION and version <= Cell.versionNum then
                        local success
                        data = LibDeflate:DecodeForPrint(data) -- decode
                        success, data = pcall(LibDeflate.DecompressDeflate, LibDeflate, data) -- decompress
                        success, data = Serializer:Deserialize(data) -- deserialize

                        if success and data then
                            title:SetText(L["Import"]..": r"..version)
                            importBtn:SetEnabled(true)
                            imported = data
                        else
                            title:SetText(L["Import"]..": |cffff2222"..L["Error"])
                            importBtn:SetEnabled(false)
                        end
                    else -- incompatible version
                        title:SetText(L["Import"]..": |cffff2222"..L["Incompatible Version"])
                        importBtn:SetEnabled(false)
                    end
                else
                    title:SetText(L["Import"]..": |cffff2222"..L["Error"])
                    importBtn:SetEnabled(false)
                end
            else
                eb:SetText(exported)
                eb:SetCursorPosition(0)
                eb:HighlightText()
            end
        end
    end)
    Cell.StylizeFrame(textArea.scrollFrame, {0, 0, 0, 0}, Cell.GetAccentColorTable())
    textArea:SetPoint("TOPLEFT", 5, -20)
    textArea:SetPoint("BOTTOMRIGHT", -5, 5)

    -- highlight text
    textArea.eb:SetScript("OnEditFocusGained", function() textArea.eb:HighlightText() end)
    textArea.eb:SetScript("OnMouseUp", function()
        if not isImport then
            textArea.eb:HighlightText()
        end
    end)

    importExportFrame:SetScript("OnHide", function()
        importExportFrame:Hide()
        isImport = false
        exported = ""
        imported = nil
        -- hide mask
        Cell.frames.aboutTab.mask:Hide()
    end)

    importExportFrame:SetScript("OnShow", function()
        -- raise frame level
        importExportFrame:SetFrameLevel(Cell.frames.aboutTab:GetFrameLevel() + 50)
        Cell.frames.aboutTab.mask:Show()
    end)
end

---------------------------------------------------------------------
-- show import
---------------------------------------------------------------------
local init
function F.ShowImportFrame()
    if not init then
        init = true
        CreateImportExportFrame()
        CreateImportConfirmationFrame()
    end

    importExportFrame:Show()
    isImport = true
    importBtn:Show()
    importBtn:SetEnabled(false)

    exported = ""
    title:SetText(L["Import"])
    textArea:SetText("")
    textArea.eb:SetFocus(true)

    includeNicknamesCB:Hide()
    includeCharacterCB:Hide()
    textArea:SetPoint("TOPLEFT", 5, -20)
    P.Height(importExportFrame, 200)
end

---------------------------------------------------------------------
-- show export
---------------------------------------------------------------------
function F.ShowExportFrame()
    if not init then
        init = true
        CreateImportExportFrame()
        CreateImportConfirmationFrame()
    end

    importExportFrame:Show()
    isImport = false
    importBtn:Hide()

    title:SetText(L["Export"]..": "..Cell.version)

    exported = GetExportString(false)

    textArea:SetText(exported)
    textArea.eb:SetFocus(true)

    includeNicknamesCB:SetChecked(false)
    includeNicknamesCB:Show()
    if Cell.isVanilla or Cell.isWrath or Cell.isCata then
        includeCharacterCB:SetChecked(false)
        includeCharacterCB:Show()
    end
    textArea:SetPoint("TOPLEFT", 5, -50)
    P.Height(importExportFrame, 230)
end

---------------------------------------------------------------------
-- for "installer" addons
---------------------------------------------------------------------

---@param profileString string
---@param profileName string? not used for now
---@param ignoredIndicesExternal table?
---@return boolean success
function Cell.ImportProfile(profileString, profileName, ignoredIndicesExternal)
    imported = nil
    local version, data = string.match(profileString, "^!CELL:(%d+):ALL!(.+)$")
    version = tonumber(version)

    if version and data then
        if version >= Cell.MIN_VERSION and version <= Cell.versionNum then
            local success
            data = LibDeflate:DecodeForPrint(data) -- decode
            success, data = pcall(LibDeflate.DecompressDeflate, LibDeflate, data) -- decompress
            success, data = Serializer:Deserialize(data) -- deserialize

            if success and data then
                imported = data
            end
        end
    end

    if ignoredIndicesExternal then
      wipe(ignoredIndices)
      for index, value in pairs(ignoredIndicesExternal) do
        ignoredIndices[index] = value
      end
    end

    if imported then
        DoImport(true)
        return true
    end

    return false
end
