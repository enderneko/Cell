local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

local copyFrame = Cell:CreateFrame("CellOptionsFrame_CopyFrame", Cell.frames.layoutsTab, 134, 356)
Cell.frames.copyFrame = copyFrame
copyFrame:SetFrameStrata("DIALOG")
copyFrame:SetPoint("TOPLEFT", 179, -22)
copyFrame:Hide()

local fromDropdown, toDropdown, fromList, copyBtn, closeBtn
local from, to
local selectedIndicators = {}
-------------------------------------------------
-- dropdowns
-------------------------------------------------
fromDropdown = Cell:CreateDropdown(copyFrame, 120)
fromDropdown:SetPoint("TOPLEFT", 7, -24)

toDropdown = Cell:CreateDropdown(copyFrame, 120)
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
fromList:SetPoint("TOPLEFT", toDropdown, "BOTTOMLEFT", 0, -7)
fromList:SetPoint("TOPRIGHT", toDropdown, "BOTTOMRIGHT", 0, -7)
fromList:SetPoint("BOTTOM", 0, 34)

Cell:CreateScrollFrame(fromList)
fromList.scrollFrame:SetScrollStep(19)

-------------------------------------------------
-- buttons
-------------------------------------------------
copyBtn = Cell:CreateButton(copyFrame, L["Copy"], "green", {60, 20})
copyBtn:SetPoint("BOTTOMLEFT", 7, 7)
copyBtn:SetEnabled(false)
copyBtn:SetScript("OnClick", function()
    local last = #CellDB["layouts"][to]["indicators"]
    last = tonumber(string.match(CellDB["layouts"][to]["indicators"][last]["indicatorName"], "%d+")) or last

    for i in pairs(selectedIndicators) do
        if i <= 21 then -- built-in
            CellDB["layouts"][to]["indicators"][i] = F:Copy(CellDB["layouts"][from]["indicators"][i])
        else -- user-created
            last = last + 1
            local indicator = F:Copy(CellDB["layouts"][from]["indicators"][i])
            indicator["indicatorName"] = "indicator"..last
            tinsert(CellDB["layouts"][to]["indicators"], indicator)
        end
    end
    Cell:Fire("UpdateIndicators", to)
    copyFrame:Hide()
end)

closeBtn = Cell:CreateButton(copyFrame, L["Close"], "red", {60, 20})
closeBtn:SetPoint("LEFT", copyBtn, "RIGHT", -1, 0)
closeBtn:SetScript("OnClick", function()
    copyFrame:Hide()
end)

-------------------------------------------------
-- functions
-------------------------------------------------
local function Validate()
    from, to = fromDropdown:GetSelected(), toDropdown:GetSelected()
    if from and to and from ~= to and F:Getn(selectedIndicators) ~= 0 then
        copyBtn:SetEnabled(true)
    else
        copyBtn:SetEnabled(false)
    end
end

local fromIdicators = {}
local function LoadIndicators(layout, frame, buttons)
    wipe(selectedIndicators)
    frame.scrollFrame:Reset()

    local last, n
    for i, t in pairs(CellDB["layouts"][layout]["indicators"]) do
        local b = buttons[i]
        if not b then
            b = Cell:CreateButton(frame.scrollFrame.content, " ", "transparent-class", {20, 20})
            buttons[i] = b
            b.selected = false
            b:SetScript("OnClick", function()
                b.selected = not b.selected
                if b.selected then
                    selectedIndicators[i] = true
                    b:SetBackdropColor(unpack(b.hoverColor))
                    b:SetScript("OnEnter", nil)
                    b:SetScript("OnLeave", nil)
                    b:SetTextColor(0, 1, 0)
                else
                    selectedIndicators[i] = nil
                    b:SetScript("OnEnter", function(self) self:SetBackdropColor(unpack(self.hoverColor)) end)
                    b:SetScript("OnLeave", function(self) self:SetBackdropColor(unpack(self.color)) end)
                    b:SetTextColor(1, 1, 1)
                end
                Validate()
            end)
        else
            -- reset
            b:Show()
            b:SetParent(frame.scrollFrame.content)
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

    frame.scrollFrame:SetContentHeight(20, n, -1)
end

local function LoadDropdowns()
    local fromItems, toItems = {}, {}
    
    tinsert(fromItems, {
        ["text"] = _G.DEFAULT,
        ["value"] = "default",
        ["onClick"] = function()
            LoadIndicators("default", fromList, fromIdicators)
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
                    LoadIndicators(l, fromList, fromIdicators)
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
    Cell:CreateMask(Cell.frames.layoutsTab)
end)

copyFrame:SetScript("OnHide", function()
    copyFrame:Hide()
    Cell.frames.layoutsTab.mask:Hide()
    fromList.scrollFrame:Reset()
    fromDropdown:SetSelected()
    toDropdown:SetSelected()
    copyBtn:SetEnabled(false)
    wipe(selectedIndicators)
    from, to = nil, nil
end)

function F:ShowCopyFrame()
    LoadDropdowns()
    copyFrame:Show()
end