local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

local whatsNewFrame = Cell:CreateMovableFrame(L["What's New"], "CellWhatsNewFrame", 350, 400, "DIALOG")
Cell.frames.whatsNewFrame = whatsNewFrame
whatsNewFrame:SetToplevel(true)

whatsNewFrame.header.closeBtn:HookScript("OnClick", function()
    CellDB["whatsNewViewed"] = Cell.version
end)

Cell:CreateScrollFrame(whatsNewFrame)
whatsNewFrame.scrollFrame:SetScrollStep(27)

local content = CreateFrame("SimpleHTML", nil, whatsNewFrame.scrollFrame.content)
content:SetSpacing("h1", 7)
content:SetSpacing("p", 7)
content:SetFontObject("h1", "CELL_FONT_CLASS_TITLE")
content:SetFontObject("p", "CELL_FONT_WIDGET")
content:SetPoint("TOP", 0, -10)
content:SetWidth(whatsNewFrame:GetWidth() - 30)

whatsNewFrame:SetScript("OnShow", function()
    content:SetText("<html><body>" .. L[Cell.version] .. "</body></html>")
    local height = content:GetContentHeight()
    content:SetHeight(height)
    whatsNewFrame.scrollFrame.content:SetHeight(height + 30)
end)

function F:CheckWhatsNew()
    if CellDB["whatsNewViewed"] ~= Cell.version then
    
        -- current version has whatsNew content
        if L[Cell.version] ~= Cell.version then
            whatsNewFrame:Show()
            whatsNewFrame:SetPoint("CENTER")
            whatsNewFrame.header.text:SetText(L["What's New in"] .. " " .. Cell.version)
        end
    end
end