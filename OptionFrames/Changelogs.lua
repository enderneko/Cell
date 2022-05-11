local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

local changelogsFrame

local function CreateChangelogsFrame()
    changelogsFrame = Cell:CreateMovableFrame("Cell "..L["Changelogs"], "CellChangelogsFrame", 370, 430, "DIALOG", 1, true)
    Cell.frames.changelogsFrame = changelogsFrame
    changelogsFrame:SetToplevel(true)

    P:SetEffectiveScale(changelogsFrame)

    changelogsFrame.header.closeBtn:HookScript("OnClick", function()
        CellDB["changelogsViewed"] = Cell.version
    end)

    Cell:CreateScrollFrame(changelogsFrame)
    changelogsFrame.scrollFrame:SetScrollStep(37)

    local content = CreateFrame("SimpleHTML", "CellChangelogsContent", changelogsFrame.scrollFrame.content)
    content:SetSpacing("h1", 9)
    content:SetSpacing("h2", 7)
    content:SetSpacing("p", 5)
    content:SetFontObject("h1", "CELL_FONT_CLASS_TITLE")
    content:SetFontObject("h2", "CELL_FONT_CLASS")
    content:SetFontObject("p", "CELL_FONT_WIDGET")
    content:SetPoint("TOP", 0, -10)
    content:SetWidth(changelogsFrame:GetWidth() - 30)

    changelogsFrame:SetScript("OnShow", function()
        content:SetText("<html><body>" .. L["CHANGELOGS"] .. "</body></html>")
        local height = content:GetContentHeight()
        content:SetHeight(height)
        changelogsFrame.scrollFrame.content:SetHeight(height + 30)
        P:PixelPerfectPoint(changelogsFrame)
    end)
end

function F:CheckWhatsNew(show)
    if show or CellDB["changelogsViewed"] ~= Cell.version then
        if not init then
            init = true
            CreateChangelogsFrame()
        end

        if changelogsFrame:IsShown() then
            changelogsFrame:Hide()
        else
            changelogsFrame:ClearAllPoints()
            changelogsFrame:SetPoint("CENTER")
            changelogsFrame:Show()
        end
    end
end