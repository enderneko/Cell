local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

local aboutTab = Cell:CreateFrame("CellOptionsFrame_AboutTab", Cell.frames.optionsFrame, nil, nil, true)
Cell.frames.aboutTab = aboutTab
aboutTab:SetAllPoints(Cell.frames.optionsFrame)
aboutTab:Hide()

-------------------------------------------------
-- description
-------------------------------------------------
local descriptionPane
local function CreateDescriptionPane()
    descriptionPane = Cell:CreateTitledPane(aboutTab, "Cell", 422, 170)
    descriptionPane:SetPoint("TOPLEFT", aboutTab, "TOPLEFT", 5, -5)

    local changeLogsBtn = Cell:CreateButton(descriptionPane, L["Change Logs"], "class", {100, 17})
    changeLogsBtn:SetPoint("TOPRIGHT")
    changeLogsBtn:SetScript("OnClick", function()
        if Cell.frames.changeLogsFrame:IsVisible() then
            Cell.frames.changeLogsFrame:Hide()
        else
            Cell.frames.changeLogsFrame:Show()
        end
    end)

    local descText = descriptionPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    descText:SetPoint("TOPLEFT", 5, -27)
    descText:SetPoint("RIGHT", -10, 0)
    descText:SetJustifyH("LEFT")
    descText:SetSpacing(5)
    descText:SetText(L["ABOUT"])
end



-------------------------------------------------
-- author
-------------------------------------------------
local function CreateAuthorPane()
    local authorPane = Cell:CreateTitledPane(aboutTab, L["Author"], 205, 50)
    authorPane:SetPoint("TOPLEFT", aboutTab, "TOPLEFT", 5, -190)
    
    local authorNameText = authorPane:CreateFontString(nil, "OVERLAY")
    authorNameText:SetPoint("TOPLEFT", 5, -27)
    authorNameText:SetFont("Interface\\AddOns\\Cell\\Media\\font.ttf", 12)
    authorNameText:SetText("篠崎-影之哀伤(CN)")
end

-------------------------------------------------
-- slash
-------------------------------------------------
local function CreateSlashPane()
    local slashPane = Cell:CreateTitledPane(aboutTab, L["Slash Commands"], 205, 50)
    slashPane:SetPoint("TOPLEFT", aboutTab, "TOPLEFT", 222, -190)
    
    local commandText = slashPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    commandText:SetPoint("TOPLEFT", 5, -27)
    commandText:SetText("/cell")
end

-------------------------------------------------
-- special thanks
-------------------------------------------------
local function CreateSpecialThanksPane()
    local specialThanksPane = Cell:CreateTitledPane(aboutTab, L["Special Thanks"], 205, 80)
    specialThanksPane:SetPoint("TOPLEFT", aboutTab, "TOPLEFT", 5, -255)

    local thanksText = specialThanksPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    thanksText:SetPoint("TOPLEFT", 5, -27)
    thanksText:SetSpacing(5)
    thanksText:SetJustifyH("LEFT")
    thanksText:SetText("夕曦 (NGA)")
end

-------------------------------------------------
-- translators
-------------------------------------------------
local function CreateTranslatorsPane()
    local translatorsPane = Cell:CreateTitledPane(aboutTab, L["Translators"], 205, 80)
    translatorsPane:SetPoint("TOPLEFT", aboutTab, "TOPLEFT", 222, -255)

    local translatorsText = translatorsPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    translatorsText:SetPoint("TOPLEFT", 5, -27)
    translatorsText:SetSpacing(5)
    translatorsText:SetJustifyH("LEFT")
    translatorsText:SetText("RainbowUI (zhTW)\nnaragok79 (koKR)\nBNS333 (zhTW)")
end

-------------------------------------------------
-- bugreport
-------------------------------------------------
local function CreateBugReportPane()
    local bugReportPane = Cell:CreateTitledPane(aboutTab, L["Bug Report & Suggestion"], 422, 73)
    bugReportPane:SetPoint("TOPLEFT", aboutTab, "TOPLEFT", 5, -355)

    local bugReportEB = Cell:CreateEditBox(bugReportPane, 412, 20)
    bugReportEB:SetPoint("TOPLEFT", 5, -27)
    bugReportEB:SetText("https://github.com/enderneko/Cell/issues")
    bugReportEB:SetScript("OnTextChanged", function(self, userChanged)
        if userChanged then
            bugReportEB:SetText("https://github.com/enderneko/Cell/issues")
            bugReportEB:HighlightText()
        end
    end)
    
    if LOCALE_zhCN then
        local cnbugReportEB = Cell:CreateEditBox(bugReportPane, 412, 20)
        cnbugReportEB:SetPoint("TOPLEFT", bugReportEB, "BOTTOMLEFT", 0, -5)
        cnbugReportEB:SetText("https://bbs.nga.cn/read.php?tid=23488341")
        cnbugReportEB:SetScript("OnTextChanged", function(self, userChanged)
            if userChanged then
                cnbugReportEB:SetText("https://bbs.nga.cn/read.php?tid=23488341")
                cnbugReportEB:HighlightText()
            end
        end)
        
    end
end

local init
local function ShowTab(tab)
    if tab == "about" then
        if not init then
            init = true
            CreateDescriptionPane()
            CreateAuthorPane()
            CreateSlashPane()
            CreateSpecialThanksPane()
            CreateTranslatorsPane()
            CreateBugReportPane()
        end
        aboutTab:Show()
        descriptionPane:SetTitle("Cell "..Cell.version)
    else
        aboutTab:Hide()
    end
end
Cell:RegisterCallback("ShowOptionsTab", "AboutTab_ShowTab", ShowTab)