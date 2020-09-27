local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

local aboutTab = Cell:CreateFrame("CellOptionsFrame_AboutTab", Cell.frames.optionsFrame, nil, nil, true)
Cell.frames.aboutTab = aboutTab
aboutTab:SetAllPoints(Cell.frames.optionsFrame)
aboutTab:Hide()

-------------------------------------------------
-- introduce
-------------------------------------------------
local nameText = Cell:CreateSeparator("Cell", aboutTab, 387)
nameText:SetPoint("TOPLEFT", 5, -5)

local introduceText = aboutTab:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
introduceText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 5, -12)
introduceText:SetPoint("RIGHT", -10, 0)
introduceText:SetJustifyH("LEFT")
introduceText:SetSpacing(5)
introduceText:SetText(L["ABOUT"])

-------------------------------------------------
-- author
-------------------------------------------------
local authorText = Cell:CreateSeparator(L["Author"], aboutTab, 387)
authorText:SetPoint("TOPLEFT", 5, -190)

local authorNameText = aboutTab:CreateFontString(nil, "OVERLAY")
authorNameText:SetPoint("TOPLEFT", authorText, "BOTTOMLEFT", 5, -12)
authorNameText:SetJustifyH("LEFT")
authorNameText:SetJustifyV("MIDDLE")
authorNameText:SetFont("Interface\\AddOns\\Cell\\Media\\font.ttf", 12)
authorNameText:SetText("篠崎-影之哀伤(CN)")

-------------------------------------------------
-- bugreport
-------------------------------------------------
local bugReportText = Cell:CreateSeparator(L["Bug Report & Suggestion"], aboutTab, 387)
bugReportText:SetPoint("TOPLEFT", 5, -280)

-- local bugReportText2 = aboutTab:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
-- bugReportText2:SetPoint("TOPLEFT", bugReportText, 5, -22)
-- bugReportText2:SetPoint("RIGHT", -10, 0)
-- bugReportText2:SetJustifyH("LEFT")

local bugReportEB = Cell:CreateEditBox(aboutTab, 377, 20)
bugReportEB:SetPoint("TOPLEFT", bugReportText, "BOTTOMLEFT", 5, -12)
bugReportEB:SetText("https://github.com/enderneko/Cell/issues")
bugReportEB:SetScript("OnTextChanged", function(self, userChanged)
    if userChanged then
        bugReportEB:SetText("https://github.com/enderneko/Cell/issues")
        bugReportEB:HighlightText()
    end
end)

if LOCALE_zhCN then
    local cnbugReportText = aboutTab:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    cnbugReportText:SetPoint("TOPLEFT", bugReportEB, "BOTTOMLEFT", 0, -20)
    cnbugReportText:SetText("也可以在NGA回帖反馈(但不一定能及时看到)")

    local cnbugReportEB = Cell:CreateEditBox(aboutTab, 377, 20)
    cnbugReportEB:SetPoint("TOPLEFT", cnbugReportText, "BOTTOMLEFT", 0, -5)
    cnbugReportEB:SetText("https://bbs.nga.cn/read.php?tid=23488341")
    cnbugReportEB:SetScript("OnTextChanged", function(self, userChanged)
        if userChanged then
            cnbugReportEB:SetText("https://bbs.nga.cn/read.php?tid=23488341")
            cnbugReportEB:HighlightText()
        end
    end)
    
end

local function ShowTab(tab)
    if tab == "about" then
        aboutTab:Show()
    else
        aboutTab:Hide()
    end
end
Cell:RegisterCallback("ShowOptionsTab", "AboutTab_ShowTab", ShowTab)