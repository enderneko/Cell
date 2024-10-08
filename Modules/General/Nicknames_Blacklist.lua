local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

local nicknameBlacklistFrame
local list
local LoadList
local customs = {}

local function CreateNicknameBlacklistFrame()
    nicknameBlacklistFrame = CreateFrame("Frame", "CellOptionsFrame_Nicknames", Cell.frames.generalTab, "BackdropTemplate")
    Cell:StylizeFrame(nicknameBlacklistFrame, nil, Cell:GetAccentColorTable())
    nicknameBlacklistFrame:SetFrameLevel(Cell.frames.generalTab:GetFrameLevel() + 50)
    nicknameBlacklistFrame:Hide()

    nicknameBlacklistFrame:SetPoint("LEFT", Cell.frames.generalTab.customNicknamesBtn, "RIGHT", 5, 0)
    nicknameBlacklistFrame:SetPoint("BOTTOMRIGHT", -5, 5)
    nicknameBlacklistFrame:SetHeight(412)

    nicknameBlacklistFrame:SetScript("OnHide", function()
        nicknameBlacklistFrame:Hide()
        Cell.frames.generalTab.mask:Hide()
        Cell.frames.generalTab.customNicknamesBtn:SetFrameLevel(Cell.frames.generalTab:GetFrameLevel() + 2)
    end)

    -- button
    local button = Cell:CreateButton(nicknameBlacklistFrame, L["Blacklist Target Player"], "red", {20, 20})
    button:SetPoint("TOPLEFT", 10, -10)
    button:SetPoint("TOPRIGHT", -10, -10)
    button:SetScript("OnClick", function()
        local name = F:UnitFullName("target")
        if name and not F:TContains(CellDB["nicknames"]["blacklist"], name) then
            tinsert(CellDB["nicknames"]["blacklist"], name)
            Cell:Fire("UpdateNicknames", "blacklist-add", name)
            LoadList()
        end
    end)

    -- list
    list = Cell:CreateFrame(nil, nicknameBlacklistFrame)
    list:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 0, -10)
    list:SetPoint("BOTTOMRIGHT", -10, 10)
    list:Show()

    -- list scroll
    Cell:CreateScrollFrame(list)
    list.scrollFrame:SetScrollStep(19)
end

-------------------------------------------------
-- functions
-------------------------------------------------
LoadList = function()
    list.scrollFrame:Reset()

    for i, name in ipairs(CellDB["nicknames"]["blacklist"]) do
        if not customs[i] then
            customs[i] = Cell:CreateButton(list.scrollFrame.content, "", "accent-hover", {20, 20})

            -- del
            customs[i].del = Cell:CreateButton(customs[i], "", "none", {18, 20}, true, true)
            customs[i].del:SetTexture("Interface\\AddOns\\Cell\\Media\\Icons\\delete", {16, 16}, {"CENTER", 0, 0})
            customs[i].del:SetPoint("RIGHT")
            customs[i].del.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
            customs[i].del:SetScript("OnEnter", function()
                customs[i]:GetScript("OnEnter")(customs[i])
                customs[i].del.tex:SetVertexColor(1, 1, 1, 1)
            end)
            customs[i].del:SetScript("OnLeave",  function()
                customs[i]:GetScript("OnLeave")(customs[i])
                customs[i].del.tex:SetVertexColor(0.6, 0.6, 0.6, 1)
            end)

            -- playerName
            customs[i].playerName = customs[i]:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
            customs[i].playerName:SetPoint("LEFT", 5, 0)
            customs[i].playerName:SetPoint("RIGHT", customs[i].del, "LEFT", -5, 0)
            customs[i].playerName:SetJustifyH("LEFT")
            customs[i].playerName:SetWordWrap(false)
        end

        customs[i].playerName:SetText(name)

        customs[i].del:SetScript("OnClick", function()
            tremove(CellDB["nicknames"]["blacklist"], i)
            Cell:Fire("UpdateNicknames", "blacklist-delete", name)
            LoadList()
        end)

        customs[i]:SetParent(list.scrollFrame.content)
        customs[i]:Show()

        customs[i]:SetPoint("RIGHT")
        if i == 1 then
            customs[i]:SetPoint("TOPLEFT")
        else
            customs[i]:SetPoint("TOPLEFT", customs[i-1], "BOTTOMLEFT", 0, 1)
        end
    end

    list.scrollFrame:SetContentHeight(20, #CellDB["nicknames"]["blacklist"], -1)
end

function F:ShowNicknameBlacklist()
    if not nicknameBlacklistFrame then
        CreateNicknameBlacklistFrame()
    end

    if nicknameBlacklistFrame:IsShown() then
        nicknameBlacklistFrame:Hide()
        Cell.frames.generalTab.nicknameBlacklistBtn:SetFrameLevel(Cell.frames.generalTab:GetFrameLevel() + 2)
    else
        nicknameBlacklistFrame:Show()
        Cell.frames.generalTab.nicknameBlacklistBtn:SetFrameLevel(Cell.frames.generalTab:GetFrameLevel() + 50)
        Cell.frames.generalTab.mask:Show()
        LoadList()
    end
end