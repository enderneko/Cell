local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

local helpFrame = Cell:CreateMovableFrame("Cell "..GAMEMENU_HELP, "CellHelpFrame", 500, 400, "DIALOG", 1, true)
Cell.frames.helpFrame = helpFrame
helpFrame:SetToplevel(true)

helpFrame.header.closeBtn:HookScript("OnClick", function()
    -- CellDB["helpViewed"] = Cell.version
end)

Cell:CreateScrollFrame(helpFrame)
helpFrame.scrollFrame:SetScrollStep(37)

local content = CreateFrame("SimpleHTML", "CellChangeLogsContent", helpFrame.scrollFrame.content)
content:SetSpacing("h1", 9)
content:SetSpacing("h2", 7)
content:SetSpacing("p", 5)
content:SetFontObject("h1", "CELL_FONT_CLASS_TITLE")
content:SetFontObject("h2", "CELL_FONT_CLASS")
content:SetFontObject("p", "CELL_FONT_WIDGET")
content:SetPoint("TOP", 0, -10)
content:SetWidth(helpFrame:GetWidth() - 30)

helpFrame:SetScript("OnShow", function()
    content:SetText("<html><body>" .. L["CHANGE LOGS"] .. "</body></html>")
    local height = content:GetContentHeight()
    content:SetHeight(height)
    helpFrame.scrollFrame.content:SetHeight(height + 30)
end)