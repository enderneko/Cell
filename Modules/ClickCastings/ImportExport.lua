---@class Cell
local Cell = select(2, ...)
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

local Serializer = LibStub:GetLibrary("LibSerialize")
local LibDeflate = LibStub:GetLibrary("LibDeflate")
local deflateConfig = {level = 9}

local isImport, imported, exported = false, {}, ""

local importExportFrame, importBtn, title, textArea

local function DoImport()
    if Cell.vars.clickCastings["useCommon"] then
        Cell.vars.clickCastings["common"] = imported
    else
        Cell.vars.clickCastings[Cell.vars.playerSpecID] = imported
    end

    Cell.Fire("UpdateClickCastings")
    importExportFrame:Hide()
end

local function CreateClickCastingImportExportFrame()
    importExportFrame = CreateFrame("Frame", "CellOptionsFrame_ClickCastingsImportExport", Cell.frames.clickCastingsTab, "BackdropTemplate")
    importExportFrame:Hide()
    Cell.StylizeFrame(importExportFrame, nil, Cell.GetAccentColorTable())
    importExportFrame:EnableMouse(true)
    importExportFrame:SetFrameLevel(Cell.frames.clickCastingsTab:GetFrameLevel() + 50)
    P.Size(importExportFrame, 430, 170)
    importExportFrame:SetPoint("TOPLEFT", P.Scale(1), -160)

    if not Cell.frames.clickCastingsTab.mask then
        Cell.CreateMask(Cell.frames.clickCastingsTab, nil, {1, -1, -1, 1})
        Cell.frames.clickCastingsTab.mask:Hide()
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
        importExportFrame:SetFrameLevel(Cell.frames.clickCastingsTab:GetFrameLevel() + 20)

        local popup = Cell.CreateConfirmPopup(Cell.frames.clickCastingsTab, 200, L["Overwrite Click-Casting"].."?", function(self)
            DoImport()
        end, nil, true)
        popup:SetPoint("TOPLEFT", importExportFrame, 117, -50)
        textArea.eb:ClearFocus()
    end)

    -- title
    title = importExportFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_CLASS")
    title:SetPoint("TOPLEFT", 5, -5)

    -- textArea
    textArea = Cell.CreateScrollEditBox(importExportFrame, function(eb, userChanged)
        if userChanged then
            if isImport then
                imported = {}
                local text = eb:GetText()
                -- check
                local version, class, data = string.match(text, "^!CELL:(%d+):CLICKCASTING:(.+)!(.+)$")
                version = tonumber(version)

                if class and version and data then
                    if version >= Cell.MIN_CLICKCASTINGS_VERSION then
                        local success
                        data = LibDeflate:DecodeForPrint(data) -- decode
                        success, data = pcall(LibDeflate.DecompressDeflate, LibDeflate, data) -- decompress
                        success, data = Serializer:Deserialize(data) -- deserialize

                        if success and data then
                            title:SetText(L["Import"]..": "..F.GetClassColorStr(class)..F.GetLocalizedClassName(class))
                            imported = data
                            importBtn:SetEnabled(class == Cell.vars.playerClass)
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
    textArea:SetPoint("TOPLEFT", P.Scale(5), P.Scale(-20))
    textArea:SetPoint("BOTTOMRIGHT", P.Scale(-5), P.Scale(5))

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
        imported = {}
        -- hide mask
        Cell.frames.clickCastingsTab.mask:Hide()
    end)

    importExportFrame:SetScript("OnShow", function()
        -- raise frame level
        importExportFrame:SetFrameLevel(Cell.frames.clickCastingsTab:GetFrameLevel() + 50)
        Cell.frames.clickCastingsTab.mask:Show()
    end)
end

local init
function F.ShowClickCastingImportFrame()
    if not init then
        init = true
        CreateClickCastingImportExportFrame()
    end

    importExportFrame:Show()
    isImport = true
    importBtn:Show()
    importBtn:SetEnabled(false)

    exported = ""
    title:SetText(L["Import"])
    textArea:SetText("")
    textArea.eb:SetFocus(true)
end

function F.ShowClickCastingExportFrame(clickCastingTable)
    if not init then
        init = true
        CreateClickCastingImportExportFrame()
    end

    importExportFrame:Show()
    isImport = false
    importBtn:Hide()

    title:SetText(L["Export"]..": "..F.GetClassColorStr(Cell.vars.playerClass)..F.GetLocalizedClassName(Cell.vars.playerClass))

    local prefix = "!CELL:"..Cell.versionNum..":CLICKCASTING:"..Cell.vars.playerClass.."!"

    exported = Serializer:Serialize(clickCastingTable) -- serialize
    exported = LibDeflate:CompressDeflate(exported, deflateConfig) -- compress
    exported = LibDeflate:EncodeForPrint(exported) -- encode
    exported = prefix..exported

    textArea:SetText(exported)
    textArea.eb:SetFocus(true)
end