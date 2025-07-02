---@class Cell
local Cell = select(2, ...)
local L = Cell.L
local F = Cell.funcs
---@type AbstractFramework
local AF = _G.AbstractFramework

local codeSnippetsFrame
local topPane, codePane, bottomPane, newBtn, errorPopup
local buttons = {}
local selected, forceLoadSelected = 0, true
local LoadList, LoadSnippet, RunSnippet

local function CreateCodeSnippetsFrame()
    codeSnippetsFrame = AF.CreateHeaderedFrame(CellMainFrame, "CellCodeSnippetsFrame", "Cell " .. L["Code Snippets"], 641, 550, "DIALOG")
    codeSnippetsFrame:SetToplevel(true)
    codeSnippetsFrame:SetPoint("CENTER", AF.UIParent)
    codeSnippetsFrame:Hide()

    local reloadBtn = AF.CreateButton(codeSnippetsFrame.header, "Reload", "blue", 70, 20)
    AF.SetPoint(reloadBtn, "TOPRIGHT", codeSnippetsFrame.header.closeBtn, "TOPLEFT", 1, 0)
    reloadBtn:SetOnClick(ReloadUI)

    local tips = AF.CreateScrollingText(codeSnippetsFrame)
    tips:SetText(L["SNIPPETS_TIPS"], "gray")
    AF.SetPoint(tips, "TOPLEFT", 10, -10)
    AF.SetPoint(tips, "TOPRIGHT", -10, -10)

    -- top
    topPane = CreateFrame("Frame", nil, codeSnippetsFrame)
    AF.SetPoint(topPane, "TOPLEFT", 10, -40)
    AF.SetPoint(topPane, "TOPRIGHT", -10, -40)
    AF.SetHeight(topPane, 20)

    -- add
    newBtn = AF.CreateButton(topPane, nil, "Cell_hover", 156, 20)
    newBtn:SetTexture(AF.GetIcon("Plus"))
    newBtn:SetScript("OnClick", function()
        tinsert(CellDB["snippets"], {
            ["name"] = L["unnamed"],
            ["autorun"] = false,
            ["code"] = "\n\n", -- NOTE: FAIAP
        })
        selected = #CellDB["snippets"]
        forceLoadSelected = true
        LoadList()
    end)

    -- bottom
    bottomPane = CreateFrame("Frame", nil, codeSnippetsFrame)
    AF.SetPoint(bottomPane, "BOTTOMLEFT", 10, 10)
    AF.SetPoint(bottomPane, "BOTTOMRIGHT", -10, 10)
    AF.SetHeight(bottomPane, 20)

    local runBtn = AF.CreateButton(bottomPane, L["Run"], "Cell", 200, 20)
    bottomPane.runBtn = runBtn
    runBtn:SetPoint("BOTTOMLEFT")
    runBtn:SetEnabled(false)
    runBtn:SetScript("OnClick", function()
        local errorMsg = RunSnippet(codePane:GetText())
        if errorMsg then
            errorPopup.text:SetText(errorMsg)
            errorPopup.count = 1
            errorPopup:SetScript("OnUpdate", function(self, elapsed)
                errorPopup.count = errorPopup.count + 1
                errorPopup:SetHeight(errorPopup.text:GetStringHeight() + 40)
                if errorPopup.count >= 5 then
                    errorPopup:SetScript("OnUpdate", nil)
                end
            end)
            errorPopup:Show()
        end
    end)

    local cancelBtn = AF.CreateButton(bottomPane, L["Cancel"], "Cell", 200, 20)
    bottomPane.cancelBtn = cancelBtn
    cancelBtn:SetPoint("BOTTOMRIGHT")
    cancelBtn:SetEnabled(false)
    cancelBtn:SetScript("OnClick", function()
        codePane:SetText(CellDB["snippets"][selected]["code"])
        cancelBtn:SetEnabled(false)
        bottomPane.saveBtn:SetEnabled(false)
    end)

    local saveBtn = AF.CreateButton(bottomPane, L["Save"], "Cell")
    bottomPane.saveBtn = saveBtn
    AF.SetPoint(saveBtn, "TOPLEFT", runBtn, "TOPRIGHT", 10, 0)
    AF.SetPoint(saveBtn, "BOTTOMRIGHT", cancelBtn, "BOTTOMLEFT", -10, 0)
    saveBtn:SetEnabled(false)
    saveBtn:SetScript("OnClick", function()
        CellDB["snippets"][selected]["code"] = codePane:GetText()
        saveBtn:SetEnabled(false)
        bottomPane.cancelBtn:SetEnabled(false)
    end)

    -- current line number
    local lineNumber = AF.CreateFontString(codeSnippetsFrame.header, nil, "Cell")
    AF.SetPoint(lineNumber, "LEFT", 5, 0)

    -- code
    codePane = AF.CreateScrollEditBox(codeSnippetsFrame, nil, nil, nil, nil, 3)
    codePane.eb:SetFontObject(ChatFontNormal)
    AF.SetPoint(codePane, "TOPLEFT", topPane, "BOTTOMLEFT", 0, -10)
    AF.SetPoint(codePane, "BOTTOMRIGHT", bottomPane, "TOPRIGHT", 0, 10)

    codePane:SetOnTextChanged(function(self, userChanged)
        local changed = CellDB["snippets"][selected]["code"] ~= codePane:GetText()
        saveBtn:SetEnabled(changed)
        cancelBtn:SetEnabled(changed)
    end)

    codePane:SetOnEditFocusGained(function()
        lineNumber:Show()
    end)
    codePane:SetOnEditFocusLost(function()
        lineNumber:Hide()
    end)

    codePane.OriginalGetText = codePane.eb.GetText -- NOTE: FAIAP overrides GetText
    codePane.eb:HookScript("OnCursorChanged", function(self, x, y)
        if not codePane.eb:HasFocus() then return end

        local cursorPosition = codePane.eb:GetCursorPosition()
        local next = -1
        local line = 0
        while (next and cursorPosition >= next) do
            next = codePane.OriginalGetText(codePane.eb):find("[\n]", next + 1)
            line = line + 1
        end

        lineNumber:SetText(line)
    end)

    -- NOTE: indentation
    Cell.IndentationLib.enable(codePane.eb)

    -- errorPopup
    errorPopup = AF.CreateBorderedFrame(codePane, nil, nil, nil, {0.15, 0.1, 0.1, 0.95})
    AF.SetFrameLevel(errorPopup, 30)
    errorPopup:SetPoint("BOTTOMLEFT")
    errorPopup:SetPoint("BOTTOMRIGHT")
    errorPopup:Hide()

    errorPopup.close = AF.CreateCloseButton(errorPopup, nil, 18, 18)
    errorPopup.close:SetPoint("TOPRIGHT")

    errorPopup.text = AF.CreateFontString(errorPopup, nil, "firebrick")
    AF.SetPoint(errorPopup.text, "TOPLEFT", 20, -20)
    AF.SetPoint(errorPopup.text, "TOPRIGHT", -20, -20)
    errorPopup.text:SetJustifyH("LEFT")
    errorPopup.text:SetWordWrap(true)
    errorPopup.text:SetSpacing(3)
end

LoadList = function()
    -- built-in
    if not buttons[0] then
        buttons[0] = AF.CreateButton(topPane, nil, "Cell_hover", 156, 20)
        buttons[0].id = 0 -- for highlight
        buttons[0]:SetPoint("TOPLEFT")

        -- checkbox
        buttons[0].cb = AF.CreateCheckButton(buttons[0], nil, function(checked)
            CellDB["snippets"][0]["autorun"] = checked
        end)
        AF.SetPoint(buttons[0].cb, "LEFT", 3, 0)
        buttons[0].cb:HookScript("OnEnter", function()
            buttons[0]:GetScript("OnEnter")(buttons[0])
        end)
        buttons[0].cb:HookScript("OnLeave", function()
            buttons[0]:GetScript("OnLeave")(buttons[0])
        end)

        -- label
        buttons[0].label = AF.CreateFontString(buttons[0])
        AF.SetPoint(buttons[0].label, "LEFT", buttons[0].cb, "RIGHT", 3, 0)
        AF.SetPoint(buttons[0].label, "RIGHT", -3, 0)
        buttons[0].label:SetJustifyH("LEFT")
        buttons[0].label:SetWordWrap(false)
        buttons[0].label:SetText("Cell")
    end

    buttons[0].cb:SetChecked(CellDB["snippets"][0]["autorun"])

    -- user created
    for i, t in ipairs(CellDB["snippets"]) do
        if not buttons[i] then
            buttons[i] = AF.CreateButton(topPane, nil, "Cell_hover", 156, 20)
            buttons[i].id = i -- for highlight

            -- rename
            buttons[i]:SetScript("OnDoubleClick", function(self)
                local eb = AF.GetEditBox(self)
                eb:SetBorderColor("Cell")
                eb:SetAllPoints(self)
                eb:SetText(CellDB["snippets"][i]["name"])
                eb:SetOnEnterPressed(function(text)
                    CellDB["snippets"][i]["name"] = text
                    buttons[i].label:SetText(i .. "." .. CellDB["snippets"][i]["name"])
                end)
            end)

            -- checkbox
            buttons[i].cb = AF.CreateCheckButton(buttons[i], nil, function(checked)
                CellDB["snippets"][i]["autorun"] = checked
            end)
            AF.SetPoint(buttons[i].cb, "LEFT", 3, 0)
            buttons[i].cb:HookOnEnter(buttons[i]:GetOnEnter())
            buttons[i].cb:HookOnLeave(buttons[i]:GetOnLeave())

            -- delete
            buttons[i].del = AF.CreateIconButton(buttons[i], AF.GetIcon("Close"), 12, 12, nil, "darkgray")
            AF.SetPoint(buttons[i].del, "RIGHT", -2, 0)
            buttons[i].del:SetOnClick(function()
                if IsShiftKeyDown() then
                    tremove(CellDB["snippets"], i)
                    if selected == i then -- delete selected
                        selected = 0
                        forceLoadSelected = true
                    elseif selected > i then -- before selected
                        selected = selected - 1
                    end
                    LoadList()
                end
            end)

            -- label
            buttons[i].label = AF.CreateFontString(buttons[i])
            AF.SetPoint(buttons[i].label, "LEFT", buttons[i].cb, "RIGHT", 3, 0)
            AF.SetPoint(buttons[i].label, "RIGHT", buttons[i].del, "LEFT", -3, 0)
            buttons[i].label:SetJustifyH("LEFT")
            buttons[i].label:SetWordWrap(false)
        end

        buttons[i].cb:SetChecked(t["autorun"])
        buttons[i].label:SetText(i .. "." .. t["name"])

        AF.ClearPoints(buttons[i])
        if i % 4 == 0 then
            AF.SetPoint(buttons[i], "TOPLEFT", buttons[i - 4], "BOTTOMLEFT", 0, 1)
        else
            AF.SetPoint(buttons[i], "TOPLEFT", buttons[i - 1], "TOPRIGHT", -1, 0)
        end

        buttons[i]:Show()
    end

    -- update NEW button
    local total = #CellDB["snippets"]
    if total == 0 then
        AF.ClearPoints(newBtn)
        AF.SetPoint(newBtn, "TOPLEFT", buttons[0], "TOPRIGHT", -1, 0)
        newBtn:Show()
    elseif total == 19 then
        AF.ClearPoints(newBtn)
        newBtn:Hide()
    elseif (total + 1) % 4 == 0 then
        AF.ClearPoints(newBtn)
        AF.SetPoint(newBtn, "TOPLEFT", buttons[total - 3], "BOTTOMLEFT", 0, 1)
        newBtn:Show()
    else
        AF.ClearPoints(newBtn)
        AF.SetPoint(newBtn, "TOPLEFT", buttons[total], "TOPRIGHT", -1, 0)
        newBtn:Show()
    end

    -- highlight
    AF.CreateButtonGroup(buttons, function(index)
        LoadSnippet(index)
    end, nil, nil, function(self)
        if self.label:IsTruncated() then
            AF.ShowTooltip(self, "ANCHOR_TOPLEFT", 0, 2, {self.label:GetText()})
        end
    end, AF.HideTooltip)
    buttons[selected]:SilentClick()

    -- update height
    local rows
    if total == 19 then
        rows = 5
    else
        rows = math.ceil((total + 2) / 4)
    end
    AF.SetListHeight(topPane, rows, 20, -1)

    -- hide spare buttons
    for i = total + 1, #buttons do
        AF.ClearPoints(buttons[i])
        buttons[i]:Hide()
    end
end

LoadSnippet = function(index)
    if selected ~= index or forceLoadSelected then
        selected = index
        forceLoadSelected = false
        codePane:SetText(CellDB["snippets"][index]["code"])
        codePane:SetEnabled(true)
        bottomPane.runBtn:SetEnabled(true)
        bottomPane.saveBtn:SetEnabled(false)
        bottomPane.cancelBtn:SetEnabled(false)
        errorPopup:Hide()
    end
end

RunSnippet = function(snippet)
    -- https://wowpedia.fandom.com/wiki/API_loadstring
    local func, errorMessage = loadstring(snippet)
    if (not func) then
        return errorMessage
    end
    local success, errorMessage = pcall(func)
    if (not success) then
        return errorMessage
    end
end

function F.ShowCodeSnippets()
    if not codeSnippetsFrame then
        CreateCodeSnippetsFrame()
        LoadList()
    end

    codeSnippetsFrame:Toggle()
end

function F.RunSnippets()
    for i = 0, #CellDB["snippets"] do
        local t = CellDB["snippets"][i]
        if t["autorun"] then
            local errorMsg = RunSnippet(t["code"])
            if errorMsg then
                AF.Print("|cFFFF3030Snippet Error (" .. i .. "." .. (t["name"] or "Cell") .. "):|r " .. errorMsg)
            end
        end
    end
end

function F.GetDefaultSnippet()
    return {
        ["autorun"] = true,
        ["code"] = "-- snippets can be found at https://github.com/enderneko/Cell/tree/master/.snippets\n" ..
            "-- use \"/run CellDB['snippets'][0]=nil ReloadUI()\" to reset this snippet\n\n" ..
            "-- cooldown style for icon/block indicators (\"VERTICAL\", \"CLOCK\")\n" ..
            "CELL_COOLDOWN_STYLE = \"VERTICAL\"\n\n" ..
            "-- fade out unit button if hp percent > (number: 0-1)\n" ..
            "CELL_FADE_OUT_HEALTH_PERCENT = nil\n\n" ..
            "-- add summon icons to Status Icon indicator (boolean, retail only)\n" ..
            "CELL_SUMMON_ICONS_ENABLED = false\n\n" ..
            "-- use separate width and height for custom indicator icons (boolean)\n" ..
            "CELL_RECTANGULAR_CUSTOM_INDICATOR_ICONS = false\n\n" ..
            "-- Use nicknames from Details! Damage Meter (boolean, NickTag-1.0 library)\n" ..
            "CELL_NICKTAG_ENABLED = false\n\n" ..
            "-- remove raid setup details from the tooltip of the Raid button (boolean)\n" ..
            "CELL_TOOLTIP_REMOVE_RAID_SETUP_DETAILS = false\n\n" ..
            "-- border thickness: unit button and icon (number)\n" ..
            "CELL_BORDER_SIZE = 1\n\n" ..
            "-- unit button border color ({r, g, b, a}, number: 0-1)\n" ..
            "CELL_BORDER_COLOR = {0, 0, 0, 1}\n\n" ..
            "-- show raid pet owner name (\"VEHICLE\", \"NAME\", nil)\n" ..
            "CELL_SHOW_GROUP_PET_OWNER_NAME = nil\n\n" ..
            "-- use LibHealComm (boolean, non-retail)\n" ..
            "CELL_USE_LIBHEALCOMM = false"
    }
end

function F.DisableSnippets()
    for i = 1, #CellDB["snippets"] do
        CellDB["snippets"][i]["autorun"] = false
    end

    local dialog = AF.GetMessageDialog(CellAnchorFrame, L["All snippets have been disabled, due to the version update"])
    dialog:RegisterEvent("PLAYER_ENTERING_WORLD")
    dialog:SetScript("OnEvent", function()
        dialog:UnregisterAllEvents()
        dialog:SetScript("OnEvent", nil)
        dialog:SetPoint(Cell.vars.currentLayoutTable.main.anchor)
        dialog:Show()
    end)
end