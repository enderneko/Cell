local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

local aboutTab = Cell:CreateFrame("CellOptionsFrame_AboutTab", Cell.frames.optionsFrame, nil, nil, true)
Cell.frames.aboutTab = aboutTab
aboutTab:SetAllPoints(Cell.frames.optionsFrame)
aboutTab:Hide()

local authorText, specialThanksText, supportersText1, supportersText2
local translatorsTextCN, translatorsTextKR, translatorsTextPT, translatorsTextDE, translatorsTextRU, translatorsTextFR
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
    authorPane:SetPoint("TOPLEFT", aboutTab, "TOPLEFT", 5, -150)

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
    slashPane:SetPoint("TOPLEFT", aboutTab, "TOPLEFT", 222, -150)

    local commandText = slashPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    commandText:SetPoint("TOPLEFT", 5, -27)
    commandText:SetText("/cell")
end

-------------------------------------------------
-- translators
-------------------------------------------------
local function CreateTranslatorsPane()
    local translatorsPane = Cell:CreateTitledPane(aboutTab, L["Translators"], 422, 120)
    translatorsPane:SetPoint("TOPLEFT", aboutTab, "TOPLEFT", 5, -205)

    -- zhTW
    translatorsTextCN = translatorsPane:CreateFontString(nil, "OVERLAY")
    translatorsTextCN.font = UNIT_NAME_FONT_CHINESE
    translatorsTextCN.size = 13
    UpdateFont(translatorsTextCN)

    translatorsTextCN:SetPoint("TOPLEFT", 5, -27)
    translatorsTextCN:SetSpacing(5)
    translatorsTextCN:SetJustifyH("LEFT")
    translatorsTextCN:SetText("|cff999999zhTW:|r RainbowUI, BNS333, Mili")

    -- koKR
    translatorsTextKR = translatorsPane:CreateFontString(nil, "OVERLAY")
    translatorsTextKR.font = UNIT_NAME_FONT_KOREAN
    translatorsTextKR.size = 12
    UpdateFont(translatorsTextKR)

    translatorsTextKR:SetPoint("TOPLEFT", translatorsTextCN, 215, 0)
    translatorsTextKR:SetSpacing(5)
    translatorsTextKR:SetJustifyH("LEFT")
    translatorsTextKR:SetText("|cff999999koKR:|r naragok79, netaras, 부패질")

    -- ptBR
    translatorsTextPT = translatorsPane:CreateFontString(nil, "OVERLAY")
    translatorsTextPT.font = UNIT_NAME_FONT_ROMAN
    translatorsTextPT.size = 12
    UpdateFont(translatorsTextPT)

    translatorsTextPT:SetPoint("TOPLEFT", translatorsTextCN, "BOTTOMLEFT", 0, -5)
    translatorsTextPT:SetSpacing(5)
    translatorsTextPT:SetJustifyH("LEFT")
    translatorsTextPT:SetText("|cff999999ptBR:|r cathtail")

    -- deDE
    translatorsTextDE = translatorsPane:CreateFontString(nil, "OVERLAY")
    translatorsTextDE.font = UNIT_NAME_FONT_ROMAN
    translatorsTextDE.size = 12
    UpdateFont(translatorsTextDE)

    translatorsTextDE:SetPoint("TOPLEFT", translatorsTextPT, 215, 0)
    translatorsTextDE:SetSpacing(5)
    translatorsTextDE:SetJustifyH("LEFT")
    translatorsTextDE:SetText("|cff999999deDE:|r CheersItsJulian")

    -- ruRU
    translatorsTextRU = translatorsPane:CreateFontString(nil, "OVERLAY")
    translatorsTextRU.font = UNIT_NAME_FONT_ROMAN
    translatorsTextRU.size = 12
    UpdateFont(translatorsTextRU)

    translatorsTextRU:SetPoint("TOPLEFT", translatorsTextPT, "BOTTOMLEFT", 0, -5)
    translatorsTextRU:SetSpacing(5)
    translatorsTextRU:SetJustifyH("LEFT")
    translatorsTextRU:SetText("|cff999999ruRU:|r KnewOne, SkywardenSylvanas, MORROSION")

    -- frFR
    translatorsTextFR = translatorsPane:CreateFontString(nil, "OVERLAY")
    translatorsTextFR.font = UNIT_NAME_FONT_ROMAN
    translatorsTextFR.size = 12
    UpdateFont(translatorsTextFR)

    translatorsTextFR:SetPoint("TOPLEFT", translatorsTextRU, "BOTTOMLEFT", 0, -5)
    translatorsTextFR:SetSpacing(5)
    translatorsTextFR:SetJustifyH("LEFT")
    translatorsTextFR:SetText("|cff999999frFR:|r epino46")
end

-------------------------------------------------
-- special thanks
-------------------------------------------------
local function CreateSpecialThanksPane()
    local specialThanksPane = Cell:CreateTitledPane(aboutTab, L["Special Thanks"], 422, 120)
    specialThanksPane:SetPoint("TOPLEFT", aboutTab, "TOPLEFT", 5, -320)

    specialThanksText = specialThanksPane:CreateFontString(nil, "OVERLAY")
    specialThanksText.font = UNIT_NAME_FONT_CHINESE
    specialThanksText.size = 13
    UpdateFont(specialThanksText)

    specialThanksText:SetPoint("TOPLEFT", 5, -27)
    specialThanksText:SetPoint("RIGHT", -5, 0)
    specialThanksText:SetSpacing(5)
    specialThanksText:SetJustifyH("LEFT")
    specialThanksText:SetText(
        "|cffffff00Reat TV(YouTube), 钛锬, warbaby(爱不易)|r\n"..
        "|cffff0000Wago:|r Ora\n"..
        "|cffff3333YouTube:|r AutomaticJak, JFunkGaming, yumytv\n"..
        "|cff5662f6Discord:|r aba, BinarySunshine, Bruds, clankz., DreadMesh, Gharr, honeyhoney, leaKsi, Missgunst, Serghei, Vollmerino, Xepheris"
    )
end

-------------------------------------------------
-- supporters
-------------------------------------------------
local function GetSupporters(t)
    local str = ""
    local n = #t
    for i = 1, n do
        local total = #t[i]
        for j, name in ipairs(t[i]) do
            name = name:gsub("%(.+%)", function(s)
                return "|cff777777"..s.."|r"
            end)
            str = str .. name
            if j ~= total or i ~= n then
                str = str .. "\n"
            end
        end
    end
    return str
end

local function Getsupporters2(t)
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
    local supportersBtn = Cell:CreateButton(aboutTab, L["Supporters"], "accent", {w, h})
    supportersBtn:SetToplevel(true)
    supportersBtn:SetPushedTextOffset(0, 0)

    supportersBtn:SetScript("OnHide", function()
        supportersBtn:SetBackdropColor(unpack(supportersBtn.color))
    end)

    supportersBtn:HookScript("OnEnter", function()
        F:HideUtilityList()
    end)

    Cell:StartRainbowText(supportersBtn:GetFontString())

    local iconSize = min(w, h) - 2

    local icon1 = supportersBtn:CreateTexture(nil, "ARTWORK")
    supportersBtn.icon1 = icon1
    P:Point(supportersBtn.icon1, "TOPLEFT", 1, -1)
    P:Size(icon1, iconSize, iconSize)
    icon1:SetTexture(tex)
    icon1:SetVertexColor(0.5, 0.5, 0.5)

    local icon2 = supportersBtn:CreateTexture(nil, "ARTWORK")
    supportersBtn.icon2 = icon2
    P:Point(supportersBtn.icon2, "BOTTOMRIGHT", -1, 1)
    P:Size(icon2, iconSize, iconSize)
    icon2:SetTexture(tex)
    icon2:SetVertexColor(0.5, 0.5, 0.5)

    CreateAnimation(supportersBtn)

    return supportersBtn
end

local function CreateSupportersPane()
    -- pane
    local supportersPane = Cell:CreateTitledPane(aboutTab, "", 100, 100)
    supportersPane:SetPoint("TOPLEFT", aboutTab, "TOPRIGHT", 6, -5)
    supportersPane:SetPoint("BOTTOMLEFT", aboutTab, "BOTTOMRIGHT", 6, 5)
    supportersPane:Hide()

    CreateAnimation(supportersPane)

    local heartIcon = supportersPane:CreateTexture(nil, "OVERLAY")
    heartIcon:SetPoint("TOPRIGHT")
    heartIcon:SetSize(16, 16)
    heartIcon:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\sparkling_heart")

    local bgTex = supportersPane:CreateTexture(nil, "BACKGROUND", nil, 0)
    bgTex:SetPoint("TOPLEFT", -5, 5)
    bgTex:SetPoint("BOTTOMRIGHT", 5, -5)
    bgTex:SetTexture(Cell.vars.whiteTexture)
    bgTex:SetGradient("HORIZONTAL", CreateColor(0.1, 0.1, 0.1, 1), CreateColor(0.1, 0.1, 0.1, 0.7))

    local supportersFrame1 = CreateFrame("Frame", nil, supportersPane)
    supportersFrame1:SetPoint("TOPLEFT", 0, -27)
    supportersFrame1:SetPoint("BOTTOMLEFT")
    supportersFrame1.scroll = Cell:CreateScrollFrame(supportersFrame1)
    supportersFrame1.scroll:SetScrollStep(50)

    supportersText1 = supportersFrame1.scroll.content:CreateFontString(nil, "OVERLAY")
    supportersText1.font = UNIT_NAME_FONT_CHINESE
    supportersText1.size = 13
    UpdateFont(supportersText1)

    supportersText1:SetPoint("TOPLEFT")
    supportersText1:SetSpacing(5)
    supportersText1:SetJustifyH("LEFT")
    supportersText1:SetText(GetSupporters(Cell.supporters1))

    local supportersFrame2 = CreateFrame("Frame", nil, supportersPane)
    supportersFrame2:SetPoint("TOPLEFT", supportersFrame1, "TOPRIGHT", 10, 0)
    supportersFrame2:SetPoint("BOTTOMLEFT", supportersFrame1, "BOTTOMRIGHT")
    supportersFrame2.scroll = Cell:CreateScrollFrame(supportersFrame2)
    supportersFrame2.scroll:SetScrollStep(50)

    supportersText2 = supportersFrame2.scroll.content:CreateFontString(nil, "OVERLAY")
    supportersText2.font = UNIT_NAME_FONT_CHINESE
    supportersText2.size = 13
    UpdateFont(supportersText2)

    supportersText2:SetPoint("TOPLEFT")
    supportersText2:SetSpacing(5)
    supportersText2:SetJustifyH("LEFT")
    supportersText2:SetText(Getsupporters2(Cell.supporters2))

    -- update width
    local elapsedTime = 0
    local function updateFunc(self, elapsed)
        elapsedTime = elapsedTime + elapsed

        supportersFrame1:SetWidth(supportersText1:GetWidth() + 10)
        supportersFrame1.scroll:SetContentHeight(supportersText1:GetHeight() + 5)
        supportersFrame2:SetWidth(supportersText2:GetWidth() + 10)
        supportersFrame2.scroll:SetContentHeight(supportersText2:GetHeight() + 5)
        supportersPane:SetWidth(supportersFrame1:GetWidth() + supportersFrame2:GetWidth() + 10)

        if elapsedTime >= 0.5 then
            supportersPane:SetScript("OnUpdate", nil)
        end
    end
    supportersPane:SetScript("OnShow", function()
        elapsedTime = 0
        supportersPane:SetScript("OnUpdate", updateFunc)
    end)

    -- button
    local supportersBtn1 = CreateButton(17, 157, [[Interface\AddOns\Cell\Media\Icons\right]])
    supportersBtn1:SetPoint("TOPLEFT", aboutTab, "TOPRIGHT", 1, -5)

    local label = supportersBtn1:GetFontString()
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

    local supportersBtn2 = CreateButton(17, 17, [[Interface\AddOns\Cell\Media\Icons\left]])
    -- supportersBtn2:SetPoint("TOPLEFT", aboutTab, "TOPRIGHT", 6, -5)
    supportersBtn2:SetPoint("TOPLEFT", supportersPane)
    supportersBtn2:SetPoint("TOPRIGHT", supportersPane, P:Scale(-20), 0)
    supportersBtn2:Hide()

    supportersBtn1:SetScript("OnClick", function()
        if supportersBtn1.fadeOut:IsPlaying() or supportersBtn1.fadeIn:IsPlaying() then return end
        supportersBtn1.fadeOut:Play()
        supportersBtn2.fadeIn:Play()
        supportersPane.fadeIn:Play()
    end)

    supportersBtn2:SetScript("OnClick", function()
        if supportersBtn2.fadeOut:IsPlaying() or supportersBtn2.fadeIn:IsPlaying() then return end
        supportersBtn1.fadeIn:Play()
        supportersBtn2.fadeOut:Play()
        supportersPane.fadeOut:Play()
    end)
end

-------------------------------------------------
-- links
-------------------------------------------------
local links = {}
local function CreateLink(parent, id, icon, onEnter)
    local f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    P:Size(f, 34, 34)
    f:SetBackdrop({bgFile = Cell.vars.whiteTexture})
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
    linksPane:SetPoint("TOPLEFT", aboutTab, "TOPLEFT", 5, -460)

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
        current = "https://afdian.com/a/enderneko"
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
    iePane:SetPoint("TOPLEFT", 5, -575)

    local importBtn = Cell:CreateButton(iePane, L["Import"], "accent-hover", {134, 20})
    importBtn:SetPoint("TOPLEFT", 5, -27)
    importBtn:SetScript("OnClick", F.ShowImportFrame)
    importBtn:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\import", {16, 16}, {"LEFT", 2, 0})

    local exportBtn = Cell:CreateButton(iePane, L["Export"], "accent-hover", {134, 20})
    exportBtn:SetPoint("TOPLEFT", importBtn, "TOPRIGHT", 5, 0)
    exportBtn:SetScript("OnClick", F.ShowExportFrame)
    exportBtn:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\export", {16, 16}, {"LEFT", 2, 0})

    local backupBtn = Cell:CreateButton(iePane, L["Backups"], "accent-hover", {134, 20})
    backupBtn:SetPoint("TOPLEFT", exportBtn, "TOPRIGHT", 5, 0)
    backupBtn:SetScript("OnClick", F.ShowBackupFrame)
    backupBtn:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\backup", {16, 16}, {"LEFT", 2, 0})
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
            CreateSupportersPane()
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
    UpdateFont(translatorsTextPT)
    UpdateFont(translatorsTextDE)
    UpdateFont(translatorsTextRU)
    UpdateFont(translatorsTextFR)
    UpdateFont(specialThanksText)
    UpdateFont(supportersText1)
    UpdateFont(supportersText2)
end