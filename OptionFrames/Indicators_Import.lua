local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local Serializer = LibStub:GetLibrary("LibSerialize")
local LibDeflate = LibStub:GetLibrary("LibDeflate")
local deflateConfig = {level = 9}

local toLayout, toLayoutName
local imported

-------------------------------------------------
-- import frame
-------------------------------------------------
local importFrame = Cell:CreateFrame("CellOptionsFrame_IndicatorsImport", Cell.frames.indicatorsTab, 397, 183)
importFrame:SetFrameLevel(Cell.frames.indicatorsTab:GetFrameLevel()+20)
importFrame:SetFrameStrata("DIALOG")
Cell:StylizeFrame(importFrame, nil, Cell:GetPlayerClassColorTable())
importFrame:SetPoint("BOTTOMLEFT", 0, 24)

-- title
local title = importFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_CLASS")
title:SetPoint("TOPLEFT", 5, -5)

-------------------------------------------------
-- list
-------------------------------------------------
local listFrame = CreateFrame("Frame", nil, importFrame, "BackdropTemplate")
Cell:StylizeFrame(listFrame, {0, 0, 0, 0}, Cell:GetPlayerClassColorTable())
listFrame:SetPoint("TOPLEFT", 5, -20)
listFrame:SetPoint("BOTTOMRIGHT", importFrame, "BOTTOMLEFT", 127, 29)
Cell:CreateScrollFrame(listFrame)
listFrame.scrollFrame:SetScrollStep(19)

-------------------------------------------------
-- buttons
-------------------------------------------------
local importBtn = Cell:CreateButton(importFrame, L["Import"], "green", {62, 20})
importBtn:SetPoint("BOTTOMLEFT", 5, 5)
importBtn:SetEnabled(false)
importBtn:SetScript("OnClick", function()
    -- lower frame level
    importFrame:SetFrameStrata("HIGH")

    local text = L["Import"].." > "..Cell:GetPlayerClassColorString()..toLayoutName.."|r\n"
        ..L["This may overwrite built-in indicators"].."\n"
        ..L["|cff1Aff1AYes|r - Overwrite"].."\n|cffff1A1A"..L["No"].."|r - "..L["Cancel"]

    local popup = Cell:CreateConfirmPopup(Cell.frames.indicatorsTab, 250, text, function(self)
        local toLayoutTable = CellDB["layouts"][toLayout]
        -- last custom index
        local lastIndex
        local last = #toLayoutTable["indicators"]
        if toLayoutTable["indicators"][last]["type"] == "built-in" then
            lastIndex = last
        else
            lastIndex = tonumber(strmatch(toLayoutTable["indicators"][last]["indicatorName"], "%d+"))
        end

        -- import!
        for i, t in pairs(imported) do
            if i > Cell.defaults.builtIns then
                -- NOTE: add customs
                lastIndex = lastIndex + 1
                t["indicatorName"] = "indicator"..lastIndex
                tinsert(toLayoutTable["indicators"], t)
            else
                -- NOTE: overwrite built-ins
                toLayoutTable["indicators"][i] = t
            end
        end

        -- fire events
        Cell:Fire("UpdateIndicators", toLayout)
        Cell:Fire("IndicatorsChanged", toLayout)

        importFrame:Hide()
    end, function(self)
        importFrame:Hide()
    end, true)
    popup:SetPoint("TOPLEFT", importFrame, 75, -40)
end)

local closeBtn = Cell:CreateButton(importFrame, L["Close"], "red", {62, 20})
closeBtn:SetPoint("BOTTOMLEFT", importBtn, "BOTTOMRIGHT", -1, 0)
closeBtn:SetScript("OnClick", function()
    importFrame:Hide()
end)

-------------------------------------------------
-- content
-------------------------------------------------
local function Failed(reason)
    title:SetText(L["Import"].." > "..toLayoutName..": |cffff2222"..reason)
    importBtn:SetEnabled(false)
    listFrame.scrollFrame:Reset()
end

local textArea = Cell:CreateScrollEditBox(importFrame, function(eb, userChanged)
    if userChanged then
        listFrame.scrollFrame:Reset()
        local text = eb:GetText()
        -- check
        local version, count, data = string.match(text, "^!CELL:(%d+):debuffs:(%d+)!(.+)$")
        version = tonumber(version)
        count = tonumber(count)

        if version and count and data then
            if version >= Cell.MIN_INDICATORS_VERSION then
                local success
                data = LibDeflate:DecodeForPrint(data) -- decode
                success, data = pcall(LibDeflate.DecompressDeflate, LibDeflate, data) -- decompress
                success, data = Serializer:Deserialize(data) -- deserialize
                
                if success and data then
                    -- check data
                    local builtIn, custom = 0, 0
                    for i, t in pairs(data) do
                        if t["type"] == "built-in" then
                            builtIn = builtIn + 1
                        else
                            custom = custom + 1
                        end
                    end
                    
                    if builtIn + custom == count then
                        title:SetText(L["Import"].." > "..toLayoutName..": |cff90EE90"..builtIn.." "..L["built-in(s)"].."|r, |cffFFB5C5"..custom.." "..L["custom(s)"].."|r")
                        importBtn:SetEnabled(true)
                        imported = data
                        
                        -- create buttons, update list
                        local last
                        for i, t in pairs(data) do
                            local b
                            if t["type"] == "built-in" then
                                b = Cell:CreateButton(listFrame.scrollFrame.content, L[t["name"]], "transparent-class", {20, 20})
                            else
                                b = Cell:CreateButton(listFrame.scrollFrame.content, t["name"], "transparent-class", {20, 20})
                                b.typeIcon = b:CreateTexture(nil, "ARTWORK")
                                b.typeIcon:SetPoint("RIGHT", -2, 0)
                                b.typeIcon:SetSize(16, 16)
                                b.typeIcon:SetTexture("Interface\\AddOns\\Cell\\Media\\Indicators\\indicator-"..t["type"])
                                b.typeIcon:SetAlpha(.5)
                    
                                b:GetFontString():ClearAllPoints()
                                b:GetFontString():SetPoint("LEFT", 5, 0)
                                b:GetFontString():SetPoint("RIGHT", b.typeIcon, "LEFT", -2, 0)
                            end

                            b:HookScript("OnEnter", function()
                                print(b:GetFontString():IsTruncated())
                                if b:GetFontString():IsTruncated() then
                                    CellTooltip:SetOwner(b, "ANCHOR_NONE")
                                    CellTooltip:SetPoint("RIGHT", b, "LEFT", -1, 0)
                                    CellTooltip:AddLine(b:GetText())
                                    CellTooltip:Show()
                                end
                            end)
                    
                            b:HookScript("OnLeave", function()
                                CellTooltip:Hide()
                            end)

                            b:SetPoint("RIGHT")
                            if last then
                                b:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, 1)
                            else
                                b:SetPoint("TOPLEFT")
                            end
                            last = b
                        end
                        listFrame.scrollFrame:SetContentHeight(20, count, -1)
                    else
                        Failed(L["Error"])
                    end
                else
                    Failed(L["Error"])
                end
            else -- incompatible version
                Failed(L["Incompatible Version"])
            end
        else
            Failed(L["Error"])
        end
    end
end)
Cell:StylizeFrame(textArea.scrollFrame, {0, 0, 0, 0}, Cell:GetPlayerClassColorTable())
textArea:SetPoint("TOPLEFT", listFrame, "TOPRIGHT", 5, 0)
textArea:SetPoint("BOTTOMRIGHT", -5, 5)

-- highlight text
textArea.eb:SetScript("OnEditFocusGained", function() textArea.eb:HighlightText() end)
textArea.eb:SetScript("OnMouseUp", function()
    if not isImport then
        textArea.eb:HighlightText()
    end
end)

-------------------------------------------------
-- functions
-------------------------------------------------
importFrame:SetScript("OnHide", function()
    importFrame:Hide()
    Cell.frames.indicatorsTab.mask:Hide()
    textArea:SetText("")
    listFrame.scrollFrame:Reset()
    importBtn:SetEnabled(false)
end)

importFrame:SetScript("OnShow", function()
    -- raise frame level
    importFrame:SetFrameStrata("DIALOG")
    Cell.frames.indicatorsTab.mask:Show()
end)

function F:ShowIndicatorsImportFrame(layout)
    importFrame:Show()
    toLayout = layout
    toLayoutName = toLayout == "default" and _G.DEFAULT or toLayout
    title:SetText(L["Import"].." > "..toLayoutName)
end