---@class Cell
local Cell = select(2, ...)
local L = Cell.L
local F = Cell.funcs
---@type AbstractFramework
local AF = _G.AbstractFramework

local changelogsFrame

local function CreateChangelogsFrame()
    changelogsFrame = AF.CreateHeaderedFrame(CellMainFrame, "CellChangelogsFrame", "Cell " .. L["Changelogs"], 400, 450, "DIALOG")
    changelogsFrame:SetToplevel(true)
    changelogsFrame:Hide()

    changelogsFrame.header.closeBtn:HookScript("OnClick", function()
        CellDB["changelogsViewed"] = Cell.version
    end)

    local scrollFrame = AF.CreateScrollFrame(changelogsFrame, nil, nil, nil, "none", "none")
    scrollFrame:SetAllPoints()
    scrollFrame:SetScrollStep(37)

    local h1 = AF.CreateFont(nil, "CELL_FONT_CHANGELOG_H1", nil, 14, nil, true, "Cell", "LEFT", "TOP")
    local h2 = AF.CreateFont(nil, "CELL_FONT_CHANGELOG_H2", nil, 13, nil, true, "Cell", "LEFT", "TOP")
    local p = AF.CreateFont(nil, "CELL_FONT_CHANGELOG_P", nil, 12, nil, true, nil, "LEFT", "TOP")

    local content = CreateFrame("SimpleHTML", "CellChangelogsContent", scrollFrame.scrollContent)
    content:SetSpacing("h1", 9)
    content:SetSpacing("h2", 7)
    content:SetSpacing("p", 5)
    content:SetFontObject("h1", h1)
    content:SetFontObject("h2", h2)
    -- if LOCALE_zhCN then
    --     content:SetFontObject("p", "CELL_FONT_WIDGET")
    -- else
        content:SetFontObject("p", p)
    -- end
    AF.SetPoint(content, "TOP", 0, -10)
    -- AF.SetPoint(content, "LEFT", 15, 0)
    -- AF.SetPoint(content, "RIGHT", -15, 0)
    AF.SetWidth(content, 370) --! IMPORTANT
    content:SetHyperlinkFormat("|H%s|h" .. AF.GetColorStr("Cell") .. "%s|r|h")

    changelogsFrame:SetScript("OnShow", function()
        content:SetText("<html><body>" .. L["CHANGELOGS"] .. "</body></html>")
        C_Timer.After(0, function()
            local height = content:GetContentHeight()
            content:SetHeight(height)
            scrollFrame:SetContentHeight(height + 30)
            -- texplore(content:GetTextData())
        end)
    end)

    content:SetScript("OnHyperlinkClick", function(self, linkData, link, button)
        if linkData == "older" then
            content:SetText("<html><body>" .. L["OLDER_CHANGELOGS"] .. "</body></html>")
        elseif linkData == "recent" then
            content:SetText("<html><body>" .. L["CHANGELOGS"] .. "</body></html>")
        end

        C_Timer.After(0, function()
            local height = content:GetContentHeight()
            content:SetHeight(height)
            scrollFrame:SetContentHeight(height + 30)
        end)
    end)
end

function F.CheckWhatsNew(show)
    if show or CellDB["changelogsViewed"] ~= Cell.version then
        if not init then
            init = true
            CreateChangelogsFrame()
        end

        if changelogsFrame:IsShown() then
            changelogsFrame:Hide()
        else
            changelogsFrame:ClearAllPoints()
            changelogsFrame:SetPoint("CENTER", AF.UIParent)
            changelogsFrame:Show()
        end
    end
end