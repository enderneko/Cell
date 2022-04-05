local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

local changeLogsFrame

local function CreateChangeLogsFrame()
    changeLogsFrame = Cell:CreateMovableFrame("Cell "..L["Change Logs"], "CellChangeLogsFrame", 370, 400, "DIALOG", 1, true)
    Cell.frames.changeLogsFrame = changeLogsFrame
    changeLogsFrame:SetToplevel(true)

    P:SetEffectiveScale(changeLogsFrame)

    changeLogsFrame.header.closeBtn:HookScript("OnClick", function()
        CellDB["changeLogsViewed"] = Cell.version
    end)

    Cell:CreateScrollFrame(changeLogsFrame)
    changeLogsFrame.scrollFrame:SetScrollStep(37)

    local content = CreateFrame("SimpleHTML", "CellChangeLogsContent", changeLogsFrame.scrollFrame.content)
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
        P:PixelPerfectPoint(changeLogsFrame)
    end)
end

function F:CheckWhatsNew(show)
    if show or CellDB["changeLogsViewed"] ~= Cell.version then
        if not init then
            init = true
            CreateChangeLogsFrame()
        end

        if changeLogsFrame:IsShown() then
            changeLogsFrame:Hide()
        else
            changeLogsFrame:ClearAllPoints()
            changeLogsFrame:SetPoint("CENTER")
            changeLogsFrame:Show()
        end
    end
end