local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

local backupFrame
local buttons = {}
local LoadBackups
local DATE_FORMAT = "%Y-%m-%d %H:%M:%S"

---------------------------------------------------------------------
-- create item
---------------------------------------------------------------------
local function CreateItem(index)
    local b = Cell.CreateButton(backupFrame.list.content, nil, "accent-hover", {20, 20})

    b.version = b:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    b.version:SetJustifyH("LEFT")
    b.version:SetPoint("LEFT", 5, 0)

    b.text = b:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    b.text:SetJustifyH("LEFT")
    b.text:SetWordWrap(false)
    b.text:SetPoint("LEFT", 100, 0)
    b.text:SetPoint("RIGHT", -45, 0)

    -- restore
    b:SetScript("OnClick", function()
        if b.isInvalid then return end

        backupFrame:SetFrameLevel(Cell.frames.aboutTab:GetFrameLevel() + 20)
        Cell.frames.aboutTab.mask:Show()

        local text = "|cFFFF7070"..L["Restore backup"].."?|r\n"..CellDBBackup[index]["desc"].."\n|cFFB7B7B7"..CellDBBackup[index]["version"]
        local popup = Cell.CreateConfirmPopup(Cell.frames.aboutTab, 200, text, function()
            backupFrame:SetFrameLevel(Cell.frames.aboutTab:GetFrameLevel() + 50)
            CellDB = CellDBBackup[index]["DB"]
            if CellCharacterDB then
                CellCharacterDB = CellDBBackup[index]["CharacterDB"]
            end
            ReloadUI()
        end, function()
            backupFrame:SetFrameLevel(Cell.frames.aboutTab:GetFrameLevel() + 50)
        end)
        popup:SetPoint("TOP", backupFrame, 0, -50)
    end)

    -- delete
    b.del = Cell.CreateButton(b, "", "none", {20, 20}, true, true)
    b.del:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\delete2", {18, 18}, {"CENTER", 0, 0})
    b.del:SetPoint("RIGHT")
    b.del.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
    b.del:SetScript("OnEnter", function()
        b:GetScript("OnEnter")(b)
        b.del.tex:SetVertexColor(1, 1, 1, 1)
    end)
    b.del:SetScript("OnLeave",  function()
        b:GetScript("OnLeave")(b)
        b.del.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
    end)
    b.del:SetScript("OnClick", function()
        backupFrame:SetFrameLevel(Cell.frames.aboutTab:GetFrameLevel() + 20)
        Cell.frames.aboutTab.mask:Show()

        local text = "|cFFFF7070"..L["Delete backup"].."?|r\n"..CellDBBackup[index]["desc"]
        local popup = Cell.CreateConfirmPopup(Cell.frames.aboutTab, 200, text, function()
            backupFrame:SetFrameLevel(Cell.frames.aboutTab:GetFrameLevel() + 50)
            tremove(CellDBBackup, index)
            LoadBackups()
        end, function()
            backupFrame:SetFrameLevel(Cell.frames.aboutTab:GetFrameLevel() + 50)
        end)
        popup:SetPoint("TOP", backupFrame, 0, -50)
    end)

    -- rename
    b.rename = Cell.CreateButton(b, "", "none", {20, 20}, true, true)
    b.rename:SetPoint("RIGHT", b.del, "LEFT", 1, 0)
    b.rename:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\rename", {18, 18}, {"CENTER", 0, 0})
    b.rename.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
    b.rename:SetScript("OnEnter", function()
        b:GetScript("OnEnter")(b)
        b.rename.tex:SetVertexColor(1, 1, 1, 1)
    end)
    b.rename:SetScript("OnLeave",  function()
        b:GetScript("OnLeave")(b)
        b.rename.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
    end)
    b.rename:SetScript("OnClick", function()
        local popup = Cell.CreatePopupEditBox(backupFrame, function(text)
            if strtrim(text) == "" then text = date() end
            CellDBBackup[index]["desc"] = text
            b.text:SetText(text)
        end)
        popup:SetPoint("TOPLEFT", b)
        popup:SetPoint("BOTTOMRIGHT", b)
        popup:ShowEditBox(CellDBBackup[index]["desc"])
    end)

    return b
end

---------------------------------------------------------------------
-- create frame
---------------------------------------------------------------------
local function CreateBackupFrame()
    backupFrame = CreateFrame("Frame", "CellOptionsFrame_Backup", Cell.frames.aboutTab, "BackdropTemplate")
    backupFrame:Hide()
    Cell.StylizeFrame(backupFrame, nil, Cell.GetAccentColorTable())
    backupFrame:EnableMouse(true)
    backupFrame:SetFrameLevel(Cell.frames.aboutTab:GetFrameLevel() + 50)
    P.Size(backupFrame, 430, 185)
    backupFrame:SetPoint("BOTTOMLEFT", P.Scale(1), 27)

    if not Cell.frames.aboutTab.mask then
        Cell.CreateMask(Cell.frames.aboutTab, nil, {1, -1, -1, 1})
        Cell.frames.aboutTab.mask:Hide()
    end

    -- title
    local title = backupFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_CLASS")
    title:SetPoint("TOPLEFT", 5, -5)
    title:SetText(L["Backups"])

    -- tips
    local tips = Cell.CreateScrollTextFrame(backupFrame, "|cffb7b7b7"..L["BACKUP_TIPS"], 0.02, nil, 2)
    tips:SetPoint("TOPRIGHT", -30, -1)
    tips:SetPoint("LEFT", title, "RIGHT", 5, 0)

    -- close
    local closeBtn = Cell.CreateButton(backupFrame, "×", "red", {18, 18}, false, false, "CELL_FONT_SPECIAL", "CELL_FONT_SPECIAL")
    closeBtn:SetPoint("TOPRIGHT", P.Scale(-5), P.Scale(-1))
    closeBtn:SetScript("OnClick", function() backupFrame:Hide() end)

    -- list
    local listFrame = Cell.CreateFrame(nil, backupFrame)
    listFrame:SetPoint("TOPLEFT", 5, -25)
    listFrame:SetPoint("BOTTOMRIGHT", -5, 5)
    listFrame:Show()

    Cell.CreateScrollFrame(listFrame)
    backupFrame.list = listFrame.scrollFrame
    Cell.StylizeFrame(listFrame.scrollFrame, {0, 0, 0, 0}, Cell.GetAccentColorTable())
    listFrame.scrollFrame:SetScrollStep(25)

    -- create new
    buttons[0] = Cell.CreateButton(listFrame.scrollFrame.content, " ", "accent-hover", {20, 20})
    buttons[0]:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\create", {18, 18}, {"LEFT", 2, 0})
    buttons[0]:SetScript("OnClick", function(self)
        local popup = Cell.CreatePopupEditBox(backupFrame, function(text)
            if strtrim(text) == "" then text = date(DATE_FORMAT) end
            tinsert(CellDBBackup, {
                ["desc"] = text,
                ["version"] = Cell.version,
                ["versionNum"] = Cell.versionNum,
                ["DB"] = F.Copy(CellDB),
                ["CharacterDB"] = CellCharacterDB and F.Copy(CellCharacterDB),
            })
            LoadBackups()
        end)
        popup:SetPoint("TOPLEFT", self)
        popup:SetPoint("BOTTOMRIGHT", self)
        popup:ShowEditBox(date(DATE_FORMAT))
    end)
    Cell.SetTooltips(buttons[0], "ANCHOR_TOPLEFT", 0, 3, L["Create Backup"], L["BACKUP_TIPS2"])

    -- OnHide
    backupFrame:SetScript("OnHide", function()
        backupFrame:Hide()
        -- hide mask
        Cell.frames.aboutTab.mask:Hide()
    end)

    -- OnShow
    backupFrame:SetScript("OnShow", function()
        -- raise frame level
        backupFrame:SetFrameLevel(Cell.frames.aboutTab:GetFrameLevel() + 50)
        Cell.frames.aboutTab.mask:Show()
    end)
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
function LoadBackups()
    backupFrame.list:ResetScroll()

    -- backups
    for i, t in pairs(CellDBBackup) do
        if not buttons[i] then
            buttons[i] = CreateItem(i)

            if i == 1 then
                buttons[i]:SetPoint("TOPLEFT", 5, -5)
            else
                buttons[i]:SetPoint("TOPLEFT", buttons[i-1], "BOTTOMLEFT", 0, -5)
            end
            buttons[i]:SetPoint("RIGHT", -5, 0)
        end

        if t["versionNum"] < Cell.MIN_VERSION then
            buttons[i].version:SetText("|cffff2222"..L["Invalid"])
            buttons[i].isInvalid = true
        else
            buttons[i].version:SetText(t["version"])
            buttons[i].isInvalid = nil
        end
        buttons[i].text:SetText(t["desc"])
        buttons[i]:Show()
    end

    local n = #CellDBBackup

    -- creation button
    buttons[0]:ClearAllPoints()
    buttons[0]:SetPoint("RIGHT", -5, 0)
    if n == 0 then
        buttons[0]:SetPoint("TOPLEFT", 5, -5)
    else
        buttons[0]:SetPoint("TOPLEFT", buttons[n], "BOTTOMLEFT", 0, -5)
    end

    -- hide unused
    for i = n + 1, #buttons do
        buttons[i]:Hide()
    end

    -- scroll range
    backupFrame.list:SetContentHeight((n + 1) * P.Scale(20) + (n + 2) * P.Scale(5))
end

---------------------------------------------------------------------
-- show
---------------------------------------------------------------------
function F.ShowBackupFrame()
    if not backupFrame then
        CreateBackupFrame()
    end

    LoadBackups()
    backupFrame:Show()
end