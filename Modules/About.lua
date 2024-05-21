local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

local aboutTab = Cell:CreateFrame("CellOptionsFrame_AboutTab", Cell.frames.optionsFrame, nil, nil, true)
Cell.frames.aboutTab = aboutTab
aboutTab:SetAllPoints(Cell.frames.optionsFrame)
aboutTab:Hide()

local authorText, translatorsTextCN, translatorsTextKR, specialThanksText, patronsText1, patronsText2
local UpdateFont

-------------------------------------------------
-- description
-------------------------------------------------
local descriptionPane
local function CreateDescriptionPane()
    descriptionPane = Cell:CreateTitledPane(aboutTab, "Cell", 422, 140)
    descriptionPane:SetPoint("TOPLEFT", aboutTab, "TOPLEFT", 5, -5)

    local changelogsBtn = Cell:CreateButton(descriptionPane, L["Changelogs"], "accent", {100, 17})
    changelogsBtn:SetPoint("TOPRIGHT")
    changelogsBtn:SetScript("OnClick", function()
        F:CheckWhatsNew(true)
    end)

    local snippetsBtn = Cell:CreateButton(descriptionPane, L["Code Snippets"], "accent", {120, 17})
    snippetsBtn:SetPoint("TOPRIGHT", changelogsBtn, "TOPLEFT", 1, 0)
    snippetsBtn:SetScript("OnClick", function()
        F:ShowCodeSnippets()
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
    authorPane:SetPoint("TOPLEFT", aboutTab, "TOPLEFT", 5, -165)

    authorText = authorPane:CreateFontString(nil, "OVERLAY")
    authorText:SetPoint("TOPLEFT", 5, -27)
    authorText.font = "Interface\\AddOns\\Cell\\Media\\Fonts\\font.ttf"
    authorText.size = 12
    UpdateFont(authorText)

    authorText:SetText("篠崎-影之哀伤 (CN)")
end

-------------------------------------------------
-- slash
-------------------------------------------------
local function CreateSlashPane()
    local slashPane = Cell:CreateTitledPane(aboutTab, L["Slash Commands"], 205, 50)
    slashPane:SetPoint("TOPLEFT", aboutTab, "TOPLEFT", 222, -165)

    local commandText = slashPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    commandText:SetPoint("TOPLEFT", 5, -27)
    commandText:SetText("/cell")
end

-------------------------------------------------
-- translators
-------------------------------------------------
local function CreateTranslatorsPane()
    local translatorsPane = Cell:CreateTitledPane(aboutTab, L["Translators"], 205, 120)
    translatorsPane:SetPoint("TOPLEFT", aboutTab, "TOPLEFT", 5, -235)

    translatorsTextCN = translatorsPane:CreateFontString(nil, "OVERLAY")
    translatorsTextCN.font = UNIT_NAME_FONT_CHINESE
    translatorsTextCN.size = 13
    UpdateFont(translatorsTextCN)

    translatorsTextCN:SetPoint("TOPLEFT", 5, -27)
    translatorsTextCN:SetPoint("TOPRIGHT", -5, -27)
    translatorsTextCN:SetSpacing(5)
    translatorsTextCN:SetJustifyH("LEFT")
    translatorsTextCN:SetText("zhTW: RainbowUI, BNS333, Mili")

    translatorsTextKR = translatorsPane:CreateFontString(nil, "OVERLAY")
    translatorsTextKR.font = UNIT_NAME_FONT_KOREAN
    translatorsTextKR.size = 12
    UpdateFont(translatorsTextKR)

    if translatorsTextCN:GetNumLines() == 1 then
        translatorsTextKR:SetPoint("TOPLEFT", 5, -45)
        translatorsTextKR:SetPoint("TOPRIGHT", -5, -45)
    else
        translatorsTextKR:SetPoint("TOPLEFT", 5, -73)
        translatorsTextKR:SetPoint("TOPRIGHT", -5, -73)
    end
    translatorsTextKR:SetSpacing(5)
    translatorsTextKR:SetJustifyH("LEFT")
    translatorsTextKR:SetText("koKR: naragok79, netaras, 부패질")
end

-------------------------------------------------
-- special thanks
-------------------------------------------------
local function CreateSpecialThanksPane()
    local specialThanksPane = Cell:CreateTitledPane(aboutTab, L["Special Thanks"], 205, 120)
    specialThanksPane:SetPoint("TOPLEFT", aboutTab, "TOPLEFT", 222, -235)

    specialThanksText = specialThanksPane:CreateFontString(nil, "OVERLAY")
    specialThanksText.font = UNIT_NAME_FONT_CHINESE
    specialThanksText.size = 13
    UpdateFont(specialThanksText)

    specialThanksText:SetPoint("TOPLEFT", 5, -27)
    specialThanksText:SetSpacing(5)
    specialThanksText:SetJustifyH("LEFT")
    specialThanksText:SetText("warbaby (爱不易)\n钛锬 (NGA)\nJFunkGaming (YouTube)\nBruds (Discord)")
end

-------------------------------------------------
-- patrons
-------------------------------------------------
local function GetPatrons(t)
    local str = ""
    local n = #t
    for i = 1, n do
        for _, name in pairs(t[i]) do
            name = name:gsub("%(.+%)", function(s)
                return "|cff777777"..s.."|r"
            end)
            str = str .. name
            if i ~= n then
                str = str .. "\n"
            end
        end
    end
    return str
end

local function GetPatrons2(t)
    local str = ""
    local n = #t
    for i = 1, n do
        local name = t[i][1] .. " |cff777777("..t[i][2]..")|r"
        str = str .. name
        if i ~= n then
            str = str .. "\n"
        end
    end
    return str
end

local function CreateAnimation(frame)
    local fadeOut = frame:CreateAnimationGroup()
    frame.fadeOut = fadeOut
    fadeOut.alpha = fadeOut:CreateAnimation("Alpha")
    fadeOut.alpha:SetFromAlpha(1)
    fadeOut.alpha:SetToAlpha(0)
    fadeOut.alpha:SetDuration(0.3)
    fadeOut:SetScript("OnFinished", function()
        frame:Hide()
    end)

    local fadeIn = frame:CreateAnimationGroup()
    frame.fadeIn = fadeIn
    fadeIn.alpha = fadeIn:CreateAnimation("Alpha")
    fadeIn.alpha:SetFromAlpha(0)
    fadeIn.alpha:SetToAlpha(1)
    fadeIn.alpha:SetDuration(0.3)
    fadeIn:SetScript("OnPlay", function()
        frame:Show()
    end)
end

local function CreateButton(w, h, tex)
    local patronsBtn = Cell:CreateButton(aboutTab, L["Patrons"], "accent", {w, h})
    patronsBtn:SetToplevel(true)
    patronsBtn:SetPushedTextOffset(0, 0)

    patronsBtn:SetScript("OnHide", function()
        patronsBtn:SetBackdropColor(unpack(patronsBtn.color))
    end)

    patronsBtn:HookScript("OnEnter", function()
        F:HideUtilityList()
    end)

    Cell:StartRainbowText(patronsBtn:GetFontString())

    local iconSize = min(w, h) - 2

    local icon1 = patronsBtn:CreateTexture(nil, "ARTWORK")
    patronsBtn.icon1 = icon1
    P:Point(patronsBtn.icon1, "TOPLEFT", 1, -1)
    P:Size(icon1, iconSize, iconSize)
    icon1:SetTexture(tex)
    icon1:SetVertexColor(0.5, 0.5, 0.5)

    local icon2 = patronsBtn:CreateTexture(nil, "ARTWORK")
    patronsBtn.icon2 = icon2
    P:Point(patronsBtn.icon2, "BOTTOMRIGHT", -1, 1)
    P:Size(icon2, iconSize, iconSize)
    icon2:SetTexture(tex)
    icon2:SetVertexColor(0.5, 0.5, 0.5)

    CreateAnimation(patronsBtn)

    return patronsBtn
end

local function CreatePatronsPane()
    -- pane
    local patronsPane = Cell:CreateTitledPane(aboutTab, "", 100, 100)
    patronsPane:SetPoint("TOPLEFT", aboutTab, "TOPRIGHT", 6, -5)
    patronsPane:SetPoint("BOTTOMLEFT", aboutTab, "BOTTOMRIGHT", 6, 5)
    patronsPane:Hide()

    CreateAnimation(patronsPane)

    local heartIcon = patronsPane:CreateTexture(nil, "OVERLAY")
    heartIcon:SetPoint("TOPRIGHT")
    heartIcon:SetSize(16, 16)
    heartIcon:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\sparkling_heart")

    local bgTex = patronsPane:CreateTexture(nil, "BACKGROUND", nil, 0)
    bgTex:SetPoint("TOPLEFT", -5, 5)
    bgTex:SetPoint("BOTTOMRIGHT", 5, -5)
    bgTex:SetTexture("Interface\\Buttons\\WHITE8x8")
    bgTex:SetGradient("HORIZONTAL", CreateColor(0.1, 0.1, 0.1, 1), CreateColor(0.1, 0.1, 0.1, 0.7))

    local patronsFrame1 = CreateFrame("Frame", nil, patronsPane)
    patronsFrame1:SetPoint("TOPLEFT", 0, -27)
    patronsFrame1:SetPoint("BOTTOMLEFT")
    patronsFrame1.scroll = Cell:CreateScrollFrame(patronsFrame1)
    patronsFrame1.scroll:SetScrollStep(50)

    patronsText1 = patronsFrame1.scroll.content:CreateFontString(nil, "OVERLAY")
    patronsText1.font = UNIT_NAME_FONT_CHINESE
    patronsText1.size = 13
    UpdateFont(patronsText1)

    patronsText1:SetPoint("TOPLEFT")
    patronsText1:SetSpacing(5)
    patronsText1:SetJustifyH("LEFT")
    patronsText1:SetText(GetPatrons(Cell.patrons1))

    local patronsFrame2 = CreateFrame("Frame", nil, patronsPane)
    patronsFrame2:SetPoint("TOPLEFT", patronsFrame1, "TOPRIGHT", 10, 0)
    patronsFrame2:SetPoint("BOTTOMLEFT", patronsFrame1, "BOTTOMRIGHT")
    patronsFrame2.scroll = Cell:CreateScrollFrame(patronsFrame2)
    patronsFrame2.scroll:SetScrollStep(50)

    patronsText2 = patronsFrame2.scroll.content:CreateFontString(nil, "OVERLAY")
    patronsText2.font = UNIT_NAME_FONT_CHINESE
    patronsText2.size = 13
    UpdateFont(patronsText2)

    patronsText2:SetPoint("TOPLEFT")
    patronsText2:SetSpacing(5)
    patronsText2:SetJustifyH("LEFT")
    patronsText2:SetText(GetPatrons2(Cell.patrons2))

    -- update width
    local elapsedTime = 0
    local function updateFunc(self, elapsed)
        elapsedTime = elapsedTime + elapsed

        patronsFrame1:SetWidth(patronsText1:GetWidth() + 10)
        patronsFrame1.scroll:SetContentHeight(patronsText1:GetHeight() + 5)
        patronsFrame2:SetWidth(patronsText2:GetWidth() + 10)
        patronsFrame2.scroll:SetContentHeight(patronsText2:GetHeight() + 5)
        patronsPane:SetWidth(patronsFrame1:GetWidth() + patronsFrame2:GetWidth() + 10)

        if elapsedTime >= 0.5 then
            patronsPane:SetScript("OnUpdate", nil)
        end
    end
    patronsPane:SetScript("OnShow", function()
        elapsedTime = 0
        patronsPane:SetScript("OnUpdate", updateFunc)
    end)

    -- button
    local patronsBtn1 = CreateButton(17, 157, [[Interface\AddOns\Cell\Media\Icons\right]])
    patronsBtn1:SetPoint("TOPLEFT", aboutTab, "TOPRIGHT", 1, -5)

    local label = patronsBtn1:GetFontString()
    -- if Cell.isRetail then
        label:ClearAllPoints()
        label:SetPoint("CENTER", 6, -5)
        label:SetRotation(-math.pi/2)
    -- else
    --     Cell:StopRainbowText(label)
    --     label:SetWordWrap(true)
    --     label:SetSpacing(0)
    --     label:ClearAllPoints()
    --     label:SetPoint("CENTER")
    --     label:SetText("P\na\nt\nr\no\nn\ns")
    --     Cell:StartRainbowText(label)
    -- end

    local patronsBtn2 = CreateButton(17, 17, [[Interface\AddOns\Cell\Media\Icons\left]])
    -- patronsBtn2:SetPoint("TOPLEFT", aboutTab, "TOPRIGHT", 6, -5)
    patronsBtn2:SetPoint("TOPLEFT", patronsPane)
    patronsBtn2:SetPoint("TOPRIGHT", patronsPane, P:Scale(-20), 0)
    patronsBtn2:Hide()

    patronsBtn1:SetScript("OnClick", function()
        if patronsBtn1.fadeOut:IsPlaying() or patronsBtn1.fadeIn:IsPlaying() then return end
        patronsBtn1.fadeOut:Play()
        patronsBtn2.fadeIn:Play()
        patronsPane.fadeIn:Play()
    end)

    patronsBtn2:SetScript("OnClick", function()
        if patronsBtn2.fadeOut:IsPlaying() or patronsBtn2.fadeIn:IsPlaying() then return end
        patronsBtn1.fadeIn:Play()
        patronsBtn2.fadeOut:Play()
        patronsPane.fadeOut:Play()
    end)
end

-------------------------------------------------
-- links
-------------------------------------------------
local links = {}
local function CreateLink(parent, id, icon, onEnter)
    local f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    P:Size(f, 34, 34)
    f:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
    f:SetBackdropColor(0, 0, 0, 1)

    links[id] = f

    f.icon = f:CreateTexture(nil, "ARTWORK")
    P:Point(f.icon, "TOPLEFT", 1, -1)
    P:Point(f.icon, "BOTTOMRIGHT", -1, 1)
    f.icon:SetTexture(icon)

    f:SetScript("OnEnter", function()
        f:SetBackdropColor(Cell:GetAccentColorRGB())
        for  _id, _f in pairs(links) do
            if _id ~= id then
                _f:SetBackdropColor(0, 0, 0, 1)
            end
        end
        if onEnter then onEnter() end
    end)

    f:SetScript("OnHide", function()
        f:SetBackdropColor(0, 0, 0, 1)
    end)

    return f
end

local function CreateLinksPane()
    local linksPane = Cell:CreateTitledPane(aboutTab, L["Links"], 422, 100)
    linksPane:SetPoint("TOPLEFT", aboutTab, "TOPLEFT", 5, -370)

    local current

    local linksEB = Cell:CreateEditBox(linksPane, 412, 20)
    linksEB:SetPoint("TOPLEFT", 5, -27)
    linksEB:SetText("https://github.com/enderneko/Cell")
    linksEB:SetScript("OnTextChanged", function(self, userChanged)
        if userChanged then
            linksEB:SetText(current)
            linksEB:HighlightText()
        end
        linksEB:SetCursorPosition(0)
    end)
    linksEB:SetScript("OnMouseUp", function(self)
        linksEB:HighlightText()
    end)

    --! github
    local github = CreateLink(linksPane, "github", "Interface\\AddOns\\Cell\\Media\\Links\\github.tga", function()
        current = "https://github.com/enderneko/Cell"
        linksEB:SetText(current)
        linksEB:ClearFocus()
    end)
    github:SetPoint("TOPLEFT", linksEB, "BOTTOMLEFT", 0, -7)

    linksEB:SetScript("OnShow", function()
        github:GetScript("OnEnter")()
    end)

    --! curseforge
    local curseforge = CreateLink(linksPane, "curseforge", "Interface\\AddOns\\Cell\\Media\\Links\\curseforge.tga", function()
        current = "https://www.curseforge.com/wow/addons/cell"
        linksEB:SetText(current)
        linksEB:ClearFocus()
    end)
    curseforge:SetPoint("TOPLEFT", github, "TOPRIGHT", 7, 0)

    --! discord
    local discord = CreateLink(linksPane, "discord", "Interface\\AddOns\\Cell\\Media\\Links\\discord.tga", function()
        current = "https://discord.gg/9PSe3fKQGJ"
        linksEB:SetText(current)
        linksEB:ClearFocus()
    end)
    discord:SetPoint("TOPLEFT", curseforge, "TOPRIGHT", 7, 0)

    --! kook
    local kook = CreateLink(linksPane, "kook", "Interface\\AddOns\\Cell\\Media\\Links\\kook.tga", function()
        current = "https://kook.top/q4T7yp"
        linksEB:SetText(current)
        linksEB:ClearFocus()
    end)
    kook:SetPoint("TOPLEFT", discord, "TOPRIGHT", 7, 0)

    --! nga
    local nga = CreateLink(linksPane, "nga", "Interface\\AddOns\\Cell\\Media\\Links\\nga.tga", function()
        current = "https://bbs.nga.cn/read.php?tid=23488341"
        linksEB:SetText(current)
        linksEB:ClearFocus()
    end)
    nga:SetPoint("TOPLEFT", kook, "TOPRIGHT", 7, 0)

    --! afdian
    local afdian = CreateLink(linksPane, "afdian", "Interface\\AddOns\\Cell\\Media\\Links\\afdian.tga", function()
        current = "https://afdian.net/a/enderneko"
        linksEB:SetText(current)
        linksEB:ClearFocus()
    end)
    afdian:SetPoint("TOPRIGHT", linksEB, "BOTTOMRIGHT", 0, -7)

    --! ko-fi
    local kofi = CreateLink(linksPane, "kofi", "Interface\\AddOns\\Cell\\Media\\Links\\ko-fi.tga", function()
        current = "https://ko-fi.com/enderneko"
        linksEB:SetText(current)
        linksEB:ClearFocus()
    end)
    kofi:SetPoint("TOPRIGHT", afdian, "TOPLEFT", -7, 0)
end

-------------------------------------------------
-- import & export
-------------------------------------------------
local function CreateImportExportPane()
    local iePane = Cell:CreateTitledPane(aboutTab, L["Import & Export All Settings"], 422, 50)
    iePane:SetPoint("TOPLEFT", 5, -485)

    local importBtn = Cell:CreateButton(iePane, L["Import"], "accent-hover", {200, 20})
    importBtn:SetPoint("TOPLEFT", 5, -27)
    importBtn:SetScript("OnClick", F.ShowImportFrame)

    local exportBtn = Cell:CreateButton(iePane, L["Export"], "accent-hover", {200, 20})
    exportBtn:SetPoint("TOPRIGHT", -5, -27)
    exportBtn:SetScript("OnClick", F.ShowExportFrame)
end

-------------------------------------------------
-- functions
-------------------------------------------------
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
            CreateLinksPane()
            CreateImportExportPane()
            CreatePatronsPane()
        end
        aboutTab:Show()
        descriptionPane:SetTitle("Cell "..Cell.version)
    else
        aboutTab:Hide()
    end
end
Cell:RegisterCallback("ShowOptionsTab", "AboutTab_ShowTab", ShowTab)

UpdateFont = function(fs)
    if not fs then return end

    fs:SetFont(fs.font, fs.size + CellDB["appearance"]["optionsFontSizeOffset"], "")
    fs:SetTextColor(1, 1, 1, 1)
    fs:SetShadowColor(0, 0, 0)
    fs:SetShadowOffset(1, -1)
end

function Cell:UpdateAboutFont()
    UpdateFont(authorText)
    UpdateFont(translatorsTextCN)
    UpdateFont(translatorsTextKR)
    UpdateFont(specialThanksText)
    UpdateFont(patronsText1)
    UpdateFont(patronsText2)
end