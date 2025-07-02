---@class Cell
local Cell = select(2, ...)
local L = Cell.L
local F = Cell.funcs
---@type AbstractFramework
local AF = _G.AbstractFramework

local aboutTab = CreateFrame("Frame", "CellOptionsFrame_AboutTab", CellOptionsFrame)
aboutTab:SetAllPoints(CellOptionsFrame)
aboutTab:Hide()

local authorText, specialThanksText, supportersText1, supportersText2
local translatorsTextCN, translatorsTextKR, translatorsTextPT, translatorsTextDE, translatorsTextRU, translatorsTextFR, translatorsTextES, translatorsTextIT
local UpdateFont

-------------------------------------------------
-- description
-------------------------------------------------
local descriptionPane
local function CreateDescriptionPane()
    descriptionPane = AF.CreateTitledPane(aboutTab, "Cell", nil, 120)
    AF.SetPoint(descriptionPane, "TOPLEFT", aboutTab, 7, -7)
    AF.SetPoint(descriptionPane, "TOPRIGHT", aboutTab, -7, -7)

    local changelogsBtn = AF.CreateButton(descriptionPane, L["Changelogs"], "Cell", 100, 17)
    changelogsBtn:SetPoint("TOPRIGHT")
    changelogsBtn:SetOnClick(function()
        F.CheckWhatsNew(true)
    end)

    local snippetsBtn = AF.CreateButton(descriptionPane, L["Code Snippets"], "Cell", 120, 17)
    AF.SetPoint(snippetsBtn, "TOPRIGHT", changelogsBtn, "TOPLEFT", 1, 0)
    snippetsBtn:SetOnClick(function()
        F.ShowCodeSnippets()
    end)

    local descText = descriptionPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    AF.SetPoint(descText, "TOPLEFT", 5, -27)
    AF.SetPoint(descText, "RIGHT", -10, 0)
    descText:SetJustifyH("LEFT")
    descText:SetSpacing(5)
    descText:SetText(L["ABOUT"])
end



-------------------------------------------------
-- author
-------------------------------------------------
local function CreateAuthorPane()
    local authorPane = AF.CreateTitledPane(aboutTab, L["Author"], 212, 50)
    AF.SetPoint(authorPane, "TOPLEFT", aboutTab, 7, -130)

    authorText = authorPane:CreateFontString(nil, "OVERLAY")
    AF.SetPoint(authorText, "TOPLEFT", 5, -27)
    authorText.font = "Interface\\AddOns\\Cell\\Media\\Fonts\\font.ttf"
    authorText.size = 12
    UpdateFont(authorText)

    authorText:SetText("篠崎-影之哀伤 (CN)")
end

-------------------------------------------------
-- slash
-------------------------------------------------
local function CreateSlashPane()
    local slashPane = AF.CreateTitledPane(aboutTab, L["Slash Commands"], 212, 50)
    AF.SetPoint(slashPane, "TOPRIGHT", aboutTab, -7, -130)

    local commandText = slashPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    AF.SetPoint(commandText, "TOPLEFT", 5, -27)
    commandText:SetText("/cell")
end

-------------------------------------------------
-- translators
-------------------------------------------------
local function CreateTranslatorsPane()
    local translatorsPane = AF.CreateTitledPane(aboutTab, L["Translators"], nil, 120)
    AF.SetPoint(translatorsPane, "TOPLEFT", aboutTab, 7, -185)
    AF.SetPoint(translatorsPane, "TOPRIGHT", aboutTab, -7, -185)

    -- zhTW
    translatorsTextCN = translatorsPane:CreateFontString(nil, "OVERLAY")
    translatorsTextCN.font = UNIT_NAME_FONT_CHINESE
    translatorsTextCN.size = 13
    UpdateFont(translatorsTextCN)

    AF.SetPoint(translatorsTextCN, "TOPLEFT", 5, -27)
    translatorsTextCN:SetSpacing(5)
    translatorsTextCN:SetJustifyH("LEFT")
    translatorsTextCN:SetText("|cff999999zhTW:|r RainbowUI, BNS333, Mili")

    -- koKR
    translatorsTextKR = translatorsPane:CreateFontString(nil, "OVERLAY")
    translatorsTextKR.font = UNIT_NAME_FONT_KOREAN
    translatorsTextKR.size = 12
    UpdateFont(translatorsTextKR)

    AF.SetPoint(translatorsTextKR, "TOPLEFT", translatorsTextCN, 215, 0)
    translatorsTextKR:SetSpacing(5)
    translatorsTextKR:SetJustifyH("LEFT")
    translatorsTextKR:SetText("|cff999999koKR:|r naragok79, netaras, 부패질")

    -- ptBR
    translatorsTextPT = translatorsPane:CreateFontString(nil, "OVERLAY")
    translatorsTextPT.font = UNIT_NAME_FONT_ROMAN
    translatorsTextPT.size = 12
    UpdateFont(translatorsTextPT)

    AF.SetPoint(translatorsTextPT, "TOPLEFT", translatorsTextCN, "BOTTOMLEFT", 0, -6)
    translatorsTextPT:SetSpacing(5)
    translatorsTextPT:SetJustifyH("LEFT")
    translatorsTextPT:SetText("|cff999999ptBR:|r cathtail")

    -- deDE
    translatorsTextDE = translatorsPane:CreateFontString(nil, "OVERLAY")
    translatorsTextDE.font = UNIT_NAME_FONT_ROMAN
    translatorsTextDE.size = 12
    UpdateFont(translatorsTextDE)

    AF.SetPoint(translatorsTextDE, "TOPLEFT", translatorsTextPT, 215, 0)
    translatorsTextDE:SetSpacing(5)
    translatorsTextDE:SetJustifyH("LEFT")
    translatorsTextDE:SetText("|cff999999deDE:|r CheersItsJulian")

    -- ruRU
    translatorsTextRU = translatorsPane:CreateFontString(nil, "OVERLAY")
    translatorsTextRU.font = UNIT_NAME_FONT_ROMAN
    translatorsTextRU.size = 12
    UpdateFont(translatorsTextRU)

    AF.SetPoint(translatorsTextRU, "TOPLEFT", translatorsTextPT, "BOTTOMLEFT", 0, -6)
    translatorsTextRU:SetSpacing(5)
    translatorsTextRU:SetJustifyH("LEFT")
    translatorsTextRU:SetText("|cff999999ruRU:|r KnewOne, SkywardenSylvanas, MORROSION")

    -- frFR
    translatorsTextFR = translatorsPane:CreateFontString(nil, "OVERLAY")
    translatorsTextFR.font = UNIT_NAME_FONT_ROMAN
    translatorsTextFR.size = 12
    UpdateFont(translatorsTextFR)

    AF.SetPoint(translatorsTextFR, "TOPLEFT", translatorsTextRU, "BOTTOMLEFT", 0, -6)
    translatorsTextFR:SetSpacing(5)
    translatorsTextFR:SetJustifyH("LEFT")
    translatorsTextFR:SetText("|cff999999frFR:|r epino46, elated_kalam86")

    -- esES
    translatorsTextES = translatorsPane:CreateFontString(nil, "OVERLAY")
    translatorsTextES.font = UNIT_NAME_FONT_ROMAN
    translatorsTextES.size = 12
    UpdateFont(translatorsTextES)

    AF.SetPoint(translatorsTextES, "TOPLEFT", translatorsTextFR, 215, 0)
    translatorsTextES:SetSpacing(5)
    translatorsTextES:SetJustifyH("LEFT")
    translatorsTextES:SetText("|cff999999esES:|r Zurent")

    -- itIT
    translatorsTextIT = translatorsPane:CreateFontString(nil, "OVERLAY")
    translatorsTextIT.font = UNIT_NAME_FONT_ROMAN
    translatorsTextIT.size = 12
    UpdateFont(translatorsTextIT)

    AF.SetPoint(translatorsTextIT, "TOPLEFT", translatorsTextFR, "BOTTOMLEFT", 0, -6)
    translatorsTextIT:SetSpacing(5)
    translatorsTextIT:SetJustifyH("LEFT")
    translatorsTextIT:SetText("|cff999999itIT:|r CeleDev")
end

-------------------------------------------------
-- special thanks
-------------------------------------------------
local function CreateSpecialThanksPane()
    local specialThanksPane = AF.CreateTitledPane(aboutTab, L["Special Thanks"], nil, 120)
    AF.SetPoint(specialThanksPane, "TOPLEFT", aboutTab, 7, -320)
    AF.SetPoint(specialThanksPane, "TOPRIGHT", aboutTab, -7, -320)

    specialThanksText = specialThanksPane:CreateFontString(nil, "OVERLAY")
    specialThanksText.font = UNIT_NAME_FONT_CHINESE
    specialThanksText.size = 13
    UpdateFont(specialThanksText)

    AF.SetPoint(specialThanksText, "TOPLEFT", 5, -27)
    AF.SetPoint(specialThanksText, "RIGHT", -5, 0)
    specialThanksText:SetSpacing(5)
    specialThanksText:SetJustifyH("LEFT")
    specialThanksText:SetText(
        "|cff00ffff露露缇娅, Reat TV(YouTube), 钛锬, warbaby(爱不易)|r\n" ..
        "|cffff0000Wago:|r Ora\n" ..
        "|cffff3333YouTube:|r AutomaticJak, JFunkGaming, yumytv\n" ..
        "|cff5662f6Discord:|r |cff7fff00clankz.|r, |cff7fff00DreadMesh|r, |cff7fff00Missgunst|r, |cff00ffffVollmerino|r, aba, BinarySunshine, Bruds, Gharr, honeyhoney, leaKsi, Serghei, swirl, Xepheris"
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
                return "|cff777777" .. s .. "|r"
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
        local name = t[i][1] .. " |cff777777(" .. t[i][2] .. ")|r"
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
    local supportersBtn = AF.CreateButton(aboutTab, L["Supporters"], "Cell", w, h)
    supportersBtn:SetToplevel(true)
    supportersBtn:SetPushedTextOffset(0, 0)

    -- supportersBtn:SetScript("OnHide", function()
    --     supportersBtn:SetBackdropColor(unpack(supportersBtn._color))
    -- end)

    supportersBtn:HookScript("OnEnter", function()
        F.HideUtilityList()
    end)

    AF.RainbowText_Start(supportersBtn:GetFontString())

    local iconSize = min(w, h) - 2

    local icon1 = supportersBtn:CreateTexture(nil, "ARTWORK")
    supportersBtn.icon1 = icon1
    AF.SetPoint(supportersBtn.icon1, "TOPLEFT", 1, -1)
    AF.SetSize(icon1, iconSize, iconSize)
    icon1:SetTexture(tex)
    icon1:SetVertexColor(0.5, 0.5, 0.5)

    local icon2 = supportersBtn:CreateTexture(nil, "ARTWORK")
    supportersBtn.icon2 = icon2
    AF.SetPoint(supportersBtn.icon2, "BOTTOMRIGHT", -1, 1)
    AF.SetSize(icon2, iconSize, iconSize)
    icon2:SetTexture(tex)
    icon2:SetVertexColor(0.5, 0.5, 0.5)

    CreateAnimation(supportersBtn)

    return supportersBtn
end

local function CreateSupportersPane()
    -- pane
    local supportersPane = AF.CreateTitledPane(aboutTab)
    AF.SetPoint(supportersPane, "TOPLEFT", aboutTab, "TOPRIGHT", 7, -7)
    AF.SetPoint(supportersPane, "BOTTOMLEFT", aboutTab, "BOTTOMRIGHT", 7, 7)
    supportersPane:Hide()

    CreateAnimation(supportersPane)

    local heartIcon = supportersPane:CreateTexture(nil, "OVERLAY")
    heartIcon:SetPoint("TOPRIGHT")
    heartIcon:SetSize(16, 16)
    heartIcon:SetTexture(AF.GetIcon("sparkling_heart", "Cell"), nil, nil, "TRILINEAR")

    local bgTex = supportersPane:CreateTexture(nil, "BACKGROUND", nil, 0)
    AF.SetPoint(bgTex, "TOPLEFT", -5, 5)
    AF.SetPoint(bgTex, "BOTTOMRIGHT", 5, -5)
    bgTex:SetTexture(AF.GetPlainTexture())
    bgTex:SetGradient("HORIZONTAL", CreateColor(0.1, 0.1, 0.1, 1), CreateColor(0.1, 0.1, 0.1, 0.7))

    local supportersFrame1 = AF.CreateScrollFrame(supportersPane)
    AF.SetPoint(supportersFrame1, "TOPLEFT", 0, -27)
    AF.SetPoint(supportersFrame1, "BOTTOMLEFT")
    supportersFrame1:SetScrollStep(50)
    supportersFrame1:SetBorderColor("none")
    supportersFrame1:SetBackgroundColor("none")

    supportersText1 = supportersFrame1.scrollContent:CreateFontString(nil, "OVERLAY")
    supportersText1.font = UNIT_NAME_FONT_CHINESE
    supportersText1.size = 13
    UpdateFont(supportersText1)

    supportersText1:SetPoint("TOPLEFT")
    supportersText1:SetSpacing(5)
    supportersText1:SetJustifyH("LEFT")
    supportersText1:SetText(GetSupporters(Cell.supporters1))

    local supportersFrame2 = AF.CreateScrollFrame(supportersPane)
    AF.SetPoint(supportersFrame2, "TOPLEFT", supportersFrame1, "TOPRIGHT", 10, 0)
    AF.SetPoint(supportersFrame2, "BOTTOMLEFT", supportersFrame1, "BOTTOMRIGHT")
    supportersFrame2:SetScrollStep(50)
    supportersFrame2:SetBorderColor("none")
    supportersFrame2:SetBackgroundColor("none")

    supportersText2 = supportersFrame2.scrollContent:CreateFontString(nil, "OVERLAY")
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
        supportersFrame1:SetContentHeight(supportersText1:GetStringHeight() + 5)
        supportersFrame2:SetWidth(supportersText2:GetWidth() + 10)
        supportersFrame2:SetContentHeight(supportersText2:GetStringHeight() + 5)
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
    AF.SetPoint(supportersBtn1, "TOPLEFT", aboutTab, "TOPRIGHT", 1, -5)

    local label = supportersBtn1:GetFontString()
    AF.ClearPoints(label)
    AF.SetPoint(label, "CENTER", 6, -5)
    label:SetRotation(-math.pi / 2)

    local supportersBtn2 = CreateButton(17, 17, [[Interface\AddOns\Cell\Media\Icons\left]])
    AF.SetPoint(supportersBtn2, "TOPLEFT", supportersPane)
    AF.SetPoint(supportersBtn2, "TOPRIGHT", supportersPane, -20, 0)
    supportersBtn2:Hide()

    supportersBtn1:SetOnClick(function()
        if supportersBtn1.fadeOut:IsPlaying() or supportersBtn1.fadeIn:IsPlaying() then return end
        supportersBtn1.fadeOut:Play()
        supportersBtn2.fadeIn:Play()
        supportersPane.fadeIn:Play()
    end)

    supportersBtn2:SetOnClick(function()
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
    local f = AF.CreateFrame(parent, nil, 34, 34)
    AF.ApplyDefaultBackdrop_NoBorder(f)
    f:SetBackdropColor(0, 0, 0, 1)

    links[id] = f

    f.icon = f:CreateTexture(nil, "ARTWORK")
    AF.SetPoint(f.icon, "TOPLEFT", 1, -1)
    AF.SetPoint(f.icon, "BOTTOMRIGHT", -1, 1)
    f.icon:SetTexture(icon)

    f:SetScript("OnEnter", function()
        f:SetBackdropColor(AF.GetColorRGB("Cell"))
        for _id, _f in pairs(links) do
            if _id ~= id then
                _f:SetBackdropColor(0, 0, 0, 1)
            end
        end
        if onEnter then onEnter() end
    end)

    f:SetScript("OnHide", function()
        f:SetBackdropColor(0, 0, 0, 1)
    end)

    AF.AddToPixelUpdater_OnShow(f, aboutTab, function()
        AF.ReSize(f)
        AF.RePoint(f)
        AF.RePoint(f.icon)
    end)

    return f
end

local function CreateLinksPane()
    local linksPane = AF.CreateTitledPane(aboutTab, L["Links"], nil, 100)
    AF.SetPoint(linksPane, "TOPLEFT", aboutTab, 7, -480)
    AF.SetPoint(linksPane, "TOPRIGHT", aboutTab, -7, -480)

    local current

    local linksEB = AF.CreateEditBox(linksPane, nil, nil, 20)
    AF.SetPoint(linksEB, "TOPLEFT", 5, -27)
    AF.SetPoint(linksEB, "RIGHT", -5, 0)
    linksEB:SetText("https://github.com/enderneko/Cell")
    linksEB:SetNotUserChangable(true)
    linksEB:SetScript("OnMouseUp", function(self)
        linksEB:HighlightText()
    end)

    --! github
    local github = CreateLink(linksPane, "github", AF.GetLogo("github"), function()
        current = "https://github.com/enderneko/Cell"
        linksEB:SetText(current)
        linksEB:ClearFocus()
    end)
    AF.SetPoint(github, "TOPLEFT", linksEB, "BOTTOMLEFT", 0, -7)

    linksEB:SetScript("OnShow", function()
        github:GetScript("OnEnter")()
    end)

    --! curseforge
    local curseforge = CreateLink(linksPane, "curseforge", AF.GetLogo("curseforge"), function()
        current = "https://www.curseforge.com/wow/addons/cell"
        linksEB:SetText(current)
        linksEB:ClearFocus()
    end)
    AF.SetPoint(curseforge, "TOPLEFT", github, "TOPRIGHT", 7, 0)

    --! wago
    local wago = CreateLink(linksPane, "wago", AF.GetLogo("wago"), function()
        current = "https://addons.wago.io/addons/cell"
        linksEB:SetText(current)
        linksEB:ClearFocus()
    end)
    AF.SetPoint(wago, "TOPLEFT", curseforge, "TOPRIGHT", 7, 0)

    --! discord
    local discord = CreateLink(linksPane, "discord", AF.GetLogo("discord"), function()
        current = "https://discord.gg/9PSe3fKQGJ"
        linksEB:SetText(current)
        linksEB:ClearFocus()
    end)
    AF.SetPoint(discord, "TOPLEFT", wago, "TOPRIGHT", 7, 0)

    --! kook
    local kook = CreateLink(linksPane, "kook", AF.GetLogo("kook"), function()
        current = "https://kook.top/q4T7yp"
        linksEB:SetText(current)
        linksEB:ClearFocus()
    end)
    AF.SetPoint(kook, "TOPLEFT", discord, "TOPRIGHT", 7, 0)

    --! nga
    local nga = CreateLink(linksPane, "nga", AF.GetLogo("nga"), function()
        current = "https://bbs.nga.cn/read.php?tid=23488341"
        linksEB:SetText(current)
        linksEB:ClearFocus()
    end)
    AF.SetPoint(nga, "TOPLEFT", kook, "TOPRIGHT", 7, 0)

    --! afdian
    local afdian = CreateLink(linksPane, "afdian", AF.GetLogo("afdian"), function()
        current = "https://afdian.com/a/enderneko"
        linksEB:SetText(current)
        linksEB:ClearFocus()
    end)
    AF.SetPoint(afdian, "TOPRIGHT", linksEB, "BOTTOMRIGHT", 0, -7)

    --! ko-fi
    local kofi = CreateLink(linksPane, "kofi", AF.GetLogo("ko-fi"), function()
        current = "https://ko-fi.com/enderneko"
        linksEB:SetText(current)
        linksEB:ClearFocus()
    end)
    AF.SetPoint(kofi, "TOPRIGHT", afdian, "TOPLEFT", -7, 0)
end

-------------------------------------------------
-- import & export
-------------------------------------------------
local function CreateImportExportPane()
    local iePane = AF.CreateTitledPane(aboutTab, L["Import & Export All Settings"], nil, 50)
    AF.SetPoint(iePane, "TOPLEFT", 7, -595)
    AF.SetPoint(iePane, "TOPRIGHT", -7, -595)

    local importBtn = AF.CreateButton(iePane, L["Import"], "Cell_hover", 138, 20)
    AF.SetPoint(importBtn, "TOPLEFT", 5, -27)
    importBtn:SetOnClick(F.ShowImportFrame)
    importBtn:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\import", {16, 16}, {"LEFT", 2, 0})

    local exportBtn = AF.CreateButton(iePane, L["Export"], "Cell_hover", 138, 20)
    AF.SetPoint(exportBtn, "TOPLEFT", importBtn, "TOPRIGHT", 6, 0)
    exportBtn:SetOnClick(F.ShowExportFrame)
    exportBtn:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\export", {16, 16}, {"LEFT", 2, 0})

    local backupBtn = AF.CreateButton(iePane, L["Backups"], "Cell_hover", 138, 20)
    AF.SetPoint(backupBtn, "TOPLEFT", exportBtn, "TOPRIGHT", 6, 0)
    backupBtn:SetOnClick(F.ShowBackupFrame)
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
        descriptionPane:SetTitle("Cell " .. Cell.version)
    else
        aboutTab:Hide()
    end
end
Cell.RegisterCallback("ShowOptionsTab", "AboutTab_ShowTab", ShowTab)

UpdateFont = function(fs)
    if not fs then return end

    fs:SetFont(fs.font, fs.size + CellDB["appearance"]["optionsFontSizeOffset"], "")
    fs:SetTextColor(1, 1, 1, 1)
    fs:SetShadowColor(0, 0, 0)
    fs:SetShadowOffset(1, -1)
end

function Cell.UpdateAboutFont()
    UpdateFont(authorText)
    UpdateFont(translatorsTextCN)
    UpdateFont(translatorsTextKR)
    UpdateFont(translatorsTextPT)
    UpdateFont(translatorsTextDE)
    UpdateFont(translatorsTextRU)
    UpdateFont(translatorsTextFR)
    UpdateFont(translatorsTextES)
    UpdateFont(specialThanksText)
    UpdateFont(supportersText1)
    UpdateFont(supportersText2)
end