local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

local copyFrame = Cell:CreateFrame("CellOptionsFrame_IndicatorsCopy", Cell.frames.indicatorsTab, 129, 368)
-- Cell.frames.indicatorsCopyFrame = copyFrame
copyFrame:SetFrameStrata("DIALOG")
copyFrame:SetPoint("BOTTOMLEFT", 5, 24)
copyFrame:Hide()

-- title
-- L["Copy selected indicators to another layout"]

local fromDropdown, toDropdown, fromList, copyBtn, closeBtn, allBtn, invertBtn
local Toggle, Validate
local from, to
local indicatorButtons = {}
local selectedIndicators = {}
-------------------------------------------------
-- dropdowns
-------------------------------------------------
fromDropdown = Cell:CreateDropdown(copyFrame, 119)
fromDropdown:SetPoint("TOPLEFT", 5, -24)

toDropdown = Cell:CreateDropdown(copyFrame, 119)
toDropdown:SetPoint("TOPLEFT", fromDropdown, "BOTTOMLEFT", 0, -22)

local fromText = copyFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_CLASS")
fromText:SetPoint("BOTTOMLEFT", fromDropdown, "TOPLEFT", 0, 1)
fromText:SetText(L["From"])

local toText = copyFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_CLASS")
toText:SetPoint("BOTTOMLEFT", toDropdown, "TOPLEFT", 0, 1)
toText:SetText(L["To"])

-------------------------------------------------
-- list
-------------------------------------------------
fromList = CreateFrame("Frame", nil, copyFrame, "BackdropTemplate")
Cell:StylizeFrame(fromList)
fromList:SetPoint("TOPLEFT", toDropdown, "BOTTOMLEFT", 0, -5)
fromList:SetPoint("TOPRIGHT", toDropdown, "BOTTOMRIGHT", 0, -5)
-- fromList:SetPoint("BOTTOM", 0, 34)
fromList:SetHeight(229)

Cell:CreateScrollFrame(fromList)
fromList.scrollFrame:SetScrollStep(19)

-------------------------------------------------
-- buttons
-------------------------------------------------
copyBtn = Cell:CreateButton(copyFrame, L["Copy"], "green", {60, 20})
copyBtn:SetPoint("BOTTOMLEFT", 5, 5)
copyBtn:SetEnabled(false)
copyBtn:SetScript("OnClick", function()
    local last = #CellDB["layouts"][to]["indicators"]
    last = tonumber(string.match(CellDB["layouts"][to]["indicators"][last]["indicatorName"], "%d+")) or last

    for i in pairs(selectedIndicators) do
        if i <= 22 then -- built-in
            CellDB["layouts"][to]["indicators"][i] = F:Copy(CellDB["layouts"][from]["indicators"][i])
        else -- user-created
            last = last + 1
            local indicator = F:Copy(CellDB["layouts"][from]["indicators"][i])
            indicator["indicatorName"] = "indicator"..last
            tinsert(CellDB["layouts"][to]["indicators"], indicator)
        end
    end
    Cell:Fire("UpdateIndicators", to)
    Cell:Fire("IndicatorsCopied", to)
    copyFrame:Hide()
end)

closeBtn = Cell:CreateButton(copyFrame, L["Close"], "red", {60, 20})
closeBtn:SetPoint("BOTTOMLEFT", copyBtn, "BOTTOMRIGHT", -1, 0)
closeBtn:SetScript("OnClick", function()
    copyFrame:Hide()
end)

allBtn = Cell:CreateButton(copyFrame, L["ALL"], "class-hover", {60, 20})
allBtn:SetPoint("BOTTOMLEFT", copyBtn, "TOPLEFT", 0, -1)
allBtn:SetScript("OnClick", function()
    for i = 1, #indicatorButtons do
        Toggle(i, true)
    end
    Validate()
end)

invertBtn = Cell:CreateButton(copyFrame, L["INVERT"], "class-hover", {60, 20})
invertBtn:SetPoint("BOTTOMLEFT", closeBtn, "TOPLEFT", 0, -1)
invertBtn:SetScript("OnClick", function()
    for i = 1, #indicatorButtons do
        if selectedIndicators[i] then
            Toggle(i, false, true)
        else
            Toggle(i, true)
        end
    end
    Validate()
end)

-------------------------------------------------
-- functions
-------------------------------------------------
Validate = function()
    from, to = fromDropdown:GetSelected(), toDropdown:GetSelected()
    if from and to and from ~= to and F:Getn(selectedIndicators) ~= 0 then
        copyBtn:SetEnabled(true)
    else
        copyBtn:SetEnabled(false)
    end
end

Toggle = function(index, isSelect, unhighlight)
    b = indicatorButtons[index]
    if isSelect then
        selectedIndicators[index] = true
        b:SetBackdropColor(unpack(b.hoverColor))
        b:SetScript("OnEnter", nil)
        b:SetScript("OnLeave", nil)
        b:SetTextColor(0, 1, 0)
        b.selected = true
    else
        selectedIndicators[index] = nil
        b:SetScript("OnEnter", function(self) self:SetBackdropColor(unpack(self.hoverColor)) end)
        b:SetScript("OnLeave", function(self) self:SetBackdropColor(unpack(self.color)) end)
        b:SetTextColor(1, 1, 1)
        b.selected = false
        if unhighlight then
            b:SetBackdropColor(0, 0, 0, 0)
        end
    end
end

local function LoadIndicators(layout)
    wipe(selectedIndicators)
    fromList.scrollFrame:Reset()

    local last, n
    for i, t in pairs(CellDB["layouts"][layout]["indicators"]) do
        local b = indicatorButtons[i]
        if not b then
            b = Cell:CreateButton(fromList.scrollFrame.content, " ", "transparent-class", {20, 20})
            indicatorButtons[i] = b
            b.selected = false
            b:SetScript("OnClick", function()
                b.selected = not b.selected
                Toggle(i, b.selected)
                Validate()
            end)
        else
            -- reset
            b:Show()
            b:SetParent(fromList.scrollFrame.content)
            b.selected = false
            b:SetScript("OnEnter", function(self) self:SetBackdropColor(unpack(self.hoverColor)) end)
            b:SetScript("OnLeave", function(self) self:SetBackdropColor(unpack(self.color)) end)
            b:SetTextColor(1, 1, 1)
            b:SetBackdropColor(0, 0, 0, 0)
        end

        if t["type"] == "built-in" then
            b:SetText(L[t["name"]])
        else
            b:SetText(t["name"])
            if not b.typeIcon then
                b.typeIcon = b:CreateTexture(nil, "ARTWORK")
                b.typeIcon:SetPoint("RIGHT", -2, 0)
                b.typeIcon:SetSize(16, 16)
                b.typeIcon:SetAlpha(.5)
                b:GetFontString():ClearAllPoints()
                b:GetFontString():SetPoint("LEFT", 5, 0)
                b:GetFontString():SetPoint("RIGHT", b.typeIcon, "LEFT", -2, 0)
            end
            b.typeIcon:SetTexture("Interface\\AddOns\\Cell\\Media\\Indicators\\indicator-"..t["type"])
        end

        b:SetPoint("RIGHT")
        if last then
            b:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, 1)
        else
            b:SetPoint("TOPLEFT")
        end
        last = b
        n = i
    end

    fromList.scrollFrame:SetContentHeight(20, n, -1)
end

local function LoadDropdowns()
    local fromItems, toItems = {}, {}
    
    tinsert(fromItems, {
        ["text"] = _G.DEFAULT,
        ["value"] = "default",
        ["onClick"] = function()
            LoadIndicators("default")
            Validate()
        end,
    })

    tinsert(toItems, {
        ["text"] = _G.DEFAULT,
        ["value"] = "default",
        ["onClick"] = function()
            Validate()
        end,
    })

    for l, t in pairs(CellDB["layouts"]) do
        if l ~= "default" then
            tinsert(fromItems, {
                ["text"] = l,
                ["onClick"] = function()
                    LoadIndicators(l)
                    Validate()
                end,
            })

            tinsert(toItems, {
                ["text"] = l,
                ["onClick"] = function()
                    Validate()
                end,
            })
        end
    end

    fromDropdown:SetItems(fromItems)
    toDropdown:SetItems(toItems)
end

-------------------------------------------------
-- scripts
-------------------------------------------------
copyFrame:SetScript("OnShow", function()
    Cell:CreateMask(Cell.frames.indicatorsTab)
end)

copyFrame:SetScript("OnHide", function()
    copyFrame:Hide()
    Cell.frames.indicatorsTab.mask:Hide()
    fromList.scrollFrame:Reset()
    fromDropdown:SetSelected()
    toDropdown:SetSelected()
    copyBtn:SetEnabled(false)
    wipe(selectedIndicators)
    from, to = nil, nil
end)

function F:ShowIndicatorsCopyFrame()
    -- texplore(selectedIndicators)
    LoadDropdowns()
    copyFrame:Show()
end