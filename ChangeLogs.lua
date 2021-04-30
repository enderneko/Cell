local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

local changeLogsFrame = Cell:CreateMovableFrame(L["Change Logs"], "CellChangeLogsFrame", 370, 400, "DIALOG", 1, true)
Cell.frames.changeLogsFrame = changeLogsFrame
changeLogsFrame:SetToplevel(true)

changeLogsFrame.header.closeBtn:HookScript("OnClick", function()
    CellDB["changeLogsViewed"] = Cell.version
end)

Cell:CreateScrollFrame(changeLogsFrame)
changeLogsFrame.scrollFrame:SetScrollStep(37)

local content = CreateFrame("SimpleHTML", nil, changeLogsFrame.scrollFrame.content)
content:SetSpacing("h1", 9)
content:SetSpacing("h2", 7)
content:SetSpacing("p", 5)
content:SetFontObject("h1", "CELL_FONT_CLASS_TITLE")
content:SetFontObject("h2", "CELL_FONT_CLASS")
content:SetFontObject("p", "CELL_FONT_WIDGET")
content:SetPoint("TOP", 0, -10)
content:SetWidth(changeLogsFrame:GetWidth() - 30)

changeLogsFrame:SetScript("OnShow", function()
    content:SetText("<html><body>" .. L["CHANGE LOGS"] .. "</body></html>")
    local height = content:GetContentHeight()
    content:SetHeight(height)
    changeLogsFrame.scrollFrame.content:SetHeight(height + 30)
end)

function F:CheckWhatsNew()
    if CellDB["changeLogsViewed"] ~= Cell.version then
        changeLogsFrame:Show()
        changeLogsFrame:ClearAllPoints()
        changeLogsFrame:SetPoint("CENTER")
    end
end