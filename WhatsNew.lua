local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

local whatsNewFrame = Cell:CreateMovableFrame("What's New", "CellWhatsNewFrame", 370, 400, "DIALOG", 1, true)
Cell.frames.whatsNewFrame = whatsNewFrame
whatsNewFrame:SetToplevel(true)

whatsNewFrame.header.closeBtn:HookScript("OnClick", function()
    CellDB["whatsNewViewed"] = Cell.version
end)

Cell:CreateScrollFrame(whatsNewFrame)
whatsNewFrame.scrollFrame:SetScrollStep(37)

local content = CreateFrame("SimpleHTML", nil, whatsNewFrame.scrollFrame.content)
content:SetSpacing("h1", 9)
content:SetSpacing("h2", 7)
content:SetSpacing("p", 5)
content:SetFontObject("h1", "CELL_FONT_CLASS_TITLE")
content:SetFontObject("h2", "CELL_FONT_CLASS")
content:SetFontObject("p", "CELL_FONT_WIDGET")
content:SetPoint("TOP", 0, -10)
content:SetWidth(whatsNewFrame:GetWidth() - 30)

whatsNewFrame:SetScript("OnShow", function()
    content:SetText("<html><body>" .. L["WHAT'S NEW"] .. "</body></html>")
    local height = content:GetContentHeight()
    content:SetHeight(height)
    whatsNewFrame.scrollFrame.content:SetHeight(height + 30)
end)

function F:CheckWhatsNew()
    if CellDB["whatsNewViewed"] ~= Cell.version then
        whatsNewFrame:Show()
        whatsNewFrame:ClearAllPoints()
        whatsNewFrame:SetPoint("CENTER")
    end
end