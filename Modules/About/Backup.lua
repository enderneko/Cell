---@class Cell
local Cell = select(2, ...)
local L = Cell.L
local F = Cell.funcs
---@type AbstractFramework
local AF = _G.AbstractFramework

local backupFrame
local buttons = {}
local LoadBackups
local DATE_FORMAT = "%Y-%m-%d %H:%M:%S"

---------------------------------------------------------------------
-- create item
---------------------------------------------------------------------
local function CreateItem(index)
    local b = AF.CreateButton(backupFrame.list.slotFrame, nil, "Cell_hover", 20, 20)

    b.version = AF.CreateFontString(b)
    b.version:SetJustifyH("LEFT")
    AF.SetPoint(b.version, "LEFT", 5, 0)

    b.text = AF.CreateFontString(b)
    b.text:SetJustifyH("LEFT")
    b.text:SetWordWrap(false)
    AF.SetPoint(b.text, "LEFT", 100, 0)
    AF.SetPoint(b.text, "RIGHT", -45, 0)

    -- restore
    b:SetScript("OnClick", function()
        if b.isInvalid then return end

        AF.SetFrameLevel(backupFrame, 20)
        AF.ShowMask(CellOptionsFrame_AboutTab)

        local text = "|cFFFF7070" .. L["Restore backup"] .. "?|r\n" .. CellDBBackup[index]["desc"] .. "\n|cFFB7B7B7" .. CellDBBackup[index]["version"]
        local dialog = AF.GetDialog(CellOptionsFrame_AboutTab, text)
        dialog:SetOnConfirm(function()
            AF.SetFrameLevel(backupFrame, 50)
            CellDB = CellDBBackup[index]["DB"]
            if CellCharacterDB then
                CellCharacterDB = CellDBBackup[index]["CharacterDB"]
            end
            ReloadUI()
        end)
        dialog:SetOnCancel(function()
            AF.SetFrameLevel(backupFrame, 50)
        end)
        AF.SetPoint(popup, "TOP", backupFrame, 0, -50)
    end)

    -- delete
    b.del = AF.CreateButton(b, nil, "none", 20, 20, nil, nil, "")
    b.del:SetTexture(AF.GetIcon("Close_Square"))
    b.del:SetPoint("RIGHT")
    b.del:SetTextureColor("gray")
    b.del:SetOnEnter(function()
        b:InvokeOnEnter()
        b.del:SetTextureColor("white")
    end)
    b.del:SetOnLeave(function()
        b:InvokeOnLeave()
        b.del:SetTextureColor("gray")
    end)
    b.del:SetOnClick(function()
        AF.SetFrameLevel(backupFrame, 20)
        AF.ShowMask(CellOptionsFrame_AboutTab)

        local text = AF.WrapTextInColor(L["Delete backup"] .. "?", "firebrick") .. "\n" .. CellDBBackup[index]["desc"]
        local dialog = AF.GetDialog(CellOptionsFrame_AboutTab, text)
        AF.SetPoint(dialog, "CENTER", backupFrame)
        dialog:SetOnConfirm(function()
            AF.SetFrameLevel(backupFrame, 50)
            tremove(CellDBBackup, index)
            LoadBackups()
        end)
        dialog:SetOnCancel(function()
            AF.SetFrameLevel(backupFrame, 50)
        end)
    end)

    -- rename
    b.rename = AF.CreateButton(b, nil, "none", 20, 20, nil, nil, "")
    AF.SetPoint(b.rename, "RIGHT", b.del, "LEFT", 1, 0)
    b.rename:SetTexture(AF.GetIcon("Rename"))
    b.rename:SetTextureColor("gray")
    b.rename:SetOnEnter(function()
        b:InvokeOnEnter()
        b.rename:SetTextureColor("white")
    end)
    b.rename:SetOnLeave(function()
        b:InvokeOnLeave()
        b.rename:SetTextureColor("gray")
    end)
    b.rename:SetOnClick(function()
        backupFrame.editbox:SetAllPoints(b)
        backupFrame.editbox:SetText(CellDBBackup[index]["desc"])
        AF.SetFrameLevel(backupFrame.editbox, 10, b)
        backupFrame.editbox:Show()
        backupFrame.editbox:SetFocus()

        backupFrame.editbox:SetOnEnterPressed(function(text)
            if AF.IsBlank(text) then text = date(DATE_FORMAT) end
            CellDBBackup[index]["desc"] = text
            b.text:SetText(text)
            backupFrame.editbox:Hide()
        end)
    end)

    return b
end

---------------------------------------------------------------------
-- create frame
---------------------------------------------------------------------
local function CreateBackupFrame()
    backupFrame = AF.CreateBorderedFrame(CellOptionsFrame_AboutTab, "CellOptionsFrame_Backup", nil, 210)
    backupFrame:Hide()
    backupFrame:SetBorderColor("Cell")
    backupFrame:EnableMouse(true)
    AF.SetFrameLevel(backupFrame, 50)
    AF.SetPoint(backupFrame, "BOTTOMLEFT", 1, 1)
    AF.SetPoint(backupFrame, "BOTTOMRIGHT", -1, 1)

    -- title
    local title = AF.CreateFontString(backupFrame, L["Backups"], "Cell")
    AF.SetPoint(title, "TOPLEFT", 5, -5)

    -- tips
    local tips = AF.CreateScrollingText(backupFrame)
    AF.SetPoint(tips, "TOPRIGHT", -30, -1)
    AF.SetPoint(tips, "LEFT", title, "RIGHT", 5, 0)
    tips:SetText(L["BACKUP_TIPS"], "gray")

    -- close
    local closeBtn = AF.CreateCloseButton(backupFrame, nil, 18, 18)
    AF.SetPoint(closeBtn, "TOPRIGHT", -5, -2)

    -- list
    local listFrame = AF.CreateScrollList(backupFrame, nil, 5, 5, 7, 20, 5)
    backupFrame.list = listFrame
    AF.SetPoint(listFrame, "TOPLEFT", 5, -25)
    AF.SetPoint(listFrame, "TOPRIGHT", -5, -25)

    -- create new
    local newBtn = AF.CreateButton(listFrame.slotFrame, nil, "Cell_hover")
    backupFrame.newBtn = newBtn
    newBtn:SetTexture(AF.GetIcon("Create_Square"), nil, {"LEFT", 2, 0})
    newBtn:SetScript("OnClick", function(self)
        backupFrame.editbox:SetAllPoints(self)
        backupFrame.editbox:SetText(date(DATE_FORMAT))
        AF.SetFrameLevel(backupFrame.editbox, 10, self)
        backupFrame.editbox:Show()
        backupFrame.editbox:SetFocus()

        backupFrame.editbox:SetOnEnterPressed(function(text)
            if AF.IsBlank(text) then text = date(DATE_FORMAT) end
            tinsert(CellDBBackup, {
                ["desc"] = text,
                ["version"] = Cell.version,
                ["versionNum"] = Cell.versionNum,
                ["DB"] = AF.Copy(CellDB),
                ["CharacterDB"] = CellCharacterDB and AF.Copy(CellCharacterDB),
            })
            LoadBackups()
            backupFrame.editbox:Hide()
        end)
    end)
    newBtn:SetTooltip(L["Create Backup"], L["BACKUP_TIPS2"])

    -- editbox
    local editbox = AF.CreateEditBox(backupFrame)
    backupFrame.editbox = editbox
    editbox:SetBorderColor("Cell")
    editbox:SetOnHide(function()
        editbox:Hide()
        editbox:Clear()
    end)
    editbox:Hide()

    -- OnHide
    backupFrame:SetOnHide(function()
        backupFrame:Hide()
        AF.HideMask(CellOptionsFrame_AboutTab)
    end)

    -- OnShow
    backupFrame:SetOnShow(function()
        -- raise frame level
        AF.SetFrameLevel(backupFrame, 50)
        AF.ShowMask(CellOptionsFrame_AboutTab)
    end)
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
LoadBackups = function()
    backupFrame.list:Reset()

    local widgets = {}

    -- backups
    for i, t in pairs(CellDBBackup) do
        if not buttons[i] then
            buttons[i] = CreateItem(i)
        end

        if t["versionNum"] < Cell.MIN_VERSION then
            buttons[i].version:SetText("|cffff2222" .. L["Invalid"])
            buttons[i].isInvalid = true
        else
            buttons[i].version:SetText(t["version"])
            buttons[i].isInvalid = nil
        end
        buttons[i].text:SetText(t["desc"])

        tinsert(widgets, buttons[i])
    end

    -- new button
    tinsert(widgets, backupFrame.newBtn)

    -- hide unused
    for i = #CellDBBackup + 1, #buttons do
        buttons[i]:Hide()
    end

    -- set
    backupFrame.list:SetWidgets(widgets)
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