local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

local toolsFrame = Cell:CreateFrame("CellToolsFrame", Cell.frames.mainFrame, 202, 69)
Cell.frames.toolsFrame = toolsFrame
Cell:StylizeFrame(toolsFrame, {.1, .1, .1, .5})
toolsFrame:SetPoint("BOTTOMLEFT", Cell.frames.mainFrame, "TOPLEFT", 0, 18)
toolsFrame:Hide()

-------------------------------------------------
-- tips
-------------------------------------------------
local tips = Cell:CreateFrame("CellToolsFrame_Tips", toolsFrame, 202, 150)
tips:SetPoint("BOTTOMLEFT", toolsFrame, "TOPLEFT", 0, 5)

tips.close = Cell:CreateButton(tips, L["×"], "red", {17, 17}, false, false, "CELL_FONT_SPECIAL", "CELL_FONT_SPECIAL")
tips.close:SetPoint("TOPRIGHT")
tips.close:SetScript("OnClick", function()
    CellDB["ToolsTipsViewed"] = true
    tips:Hide()
end)

tips.text = tips:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
tips.text:SetPoint("LEFT", 5, 0)
tips.text:SetPoint("RIGHT", -5, 0)
tips.text:SetJustifyH("LEFT")
tips.text:SetText(L["TOOLSTIPS"])

-------------------------------------------------
-- buttons
-------------------------------------------------
local readyBtn = Cell:CreateStatusBarButton(toolsFrame, READY_CHECK, {97, 17}, 35)
readyBtn:SetPoint("TOPLEFT", 3, -3)
readyBtn:SetScript("OnClick", function()
    DoReadyCheck()
end)
readyBtn:RegisterEvent("READY_CHECK")
readyBtn:RegisterEvent("READY_CHECK_FINISHED")
readyBtn:RegisterEvent("READY_CHECK_CONFIRM")
readyBtn:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "READY_CHECK" then
        readyBtn:SetMaxValue(arg2)
        readyBtn.bar:Show()
        readyBtn.ready = 1
        readyBtn:SetText(readyBtn.ready.." / "..GetNumGroupMembers())
    elseif event == "READY_CHECK_FINISHED" then
        readyBtn.bar:Hide()
        readyBtn:SetText(READY_CHECK)
    else
        if arg2 then -- isReady
            readyBtn.ready = readyBtn.ready + 1
            readyBtn:SetText(readyBtn.ready.." / "..GetNumGroupMembers())
        end
    end
end)

local pullBtn = Cell:CreateStatusBarButton(toolsFrame, L["Pull Timer"], {97, 17}, 7, "SecureActionButtonTemplate")
pullBtn:SetPoint("TOPRIGHT", -3, -3)
pullBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
pullBtn:SetAttribute("type1", "macro")
pullBtn:SetAttribute("type2", "macro")

pullBtn:RegisterEvent("CHAT_MSG_ADDON")
pullBtn:SetScript("OnEvent", function(self, event, prefix, text)
    if prefix == "D4" then -- DBM
        local pre, timer = strsplit("\t", text)
        timer = tonumber(timer)
        if pre == "PT" and timer > 0 then -- start
            pullBtn:SetMaxValue(timer)
            pullBtn.bar:Show()
        elseif pre == "PT" and timer  == 0 then -- cancel
            pullBtn.bar:Hide()
        end

    -- elseif prefix == "BigWigs" then
    --     local _, pre, timer = strsplit("^", text)
    --     timer = tonumber(timer)
    --     if pre == "Pull" and timer > 0 then -- start
    --         pullBtn:SetMaxValue(timer)
    --         pullBtn.bar:Show()
    --     elseif pre == "Pull" and timer  == 0 then -- cancel
    --         pullBtn.bar:Hide()
    --     end
    end
end)

function F:UpdatePullTimer()
    if CellDB["pullTimer"][1] == "ERT" then
        pullBtn:SetAttribute("macrotext1", "/ert pull "..CellDB["pullTimer"][2])
        pullBtn:SetAttribute("macrotext2", "/ert pull 0")
    elseif CellDB["pullTimer"][1] == "DBM" then
        pullBtn:SetAttribute("macrotext1", "/dbm pull "..CellDB["pullTimer"][2])
        pullBtn:SetAttribute("macrotext2", "/dbm pull 0")
    else -- BW
        pullBtn:SetAttribute("macrotext1", "/pull "..CellDB["pullTimer"][2])
        pullBtn:SetAttribute("macrotext2", "/pull 0")
    end
end

-------------------------------------------------
-- colors
-------------------------------------------------
local markColors = {
    {1, 1, 0}, -- star
    {1, .5, 0}, -- circle
    {.5, 0, 1}, -- diamond
    {0, 1, .2}, -- triangle
    {.5, .5, .5}, -- moon
    {0, .5, 1}, -- square
    {1, 0, 0}, -- cross
    {1, 1, 1}, -- skull
    {1, .19, .19}, -- clear
}

-------------------------------------------------
-- marks
-------------------------------------------------
local marks = Cell:CreateFrame("CellToolsFrame_Marks", toolsFrame, 192, 20, true)
marks:SetPoint("TOPLEFT", 3, -22)
marks:SetPoint("TOPRIGHT", -3, -22)
marks:Show()

local ticker
local markButtons = {}
for i = 1, 9 do
    markButtons[i] = Cell:CreateButton(marks, "", "class-hover", {20, 20})
    markButtons[i].texture = markButtons[i]:CreateTexture(nil, "ARTWORK")
    markButtons[i].texture:SetPoint("TOPLEFT", 2, -2)
    markButtons[i].texture:SetPoint("BOTTOMRIGHT", -2, 2)
    
    if i == 9 then
        -- clear all marks
        markButtons[i].texture:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
        markButtons[i]:SetScript("OnClick", function()
            markButtons[i]:SetEnabled(false)
            markButtons[i].texture:SetDesaturated(true)
            for j = 1, 8 do
                SetRaidTarget("player", j)
            end
            C_Timer.After(.5, function()
                SetRaidTarget("player", 0)
                markButtons[i]:SetEnabled(true)
                markButtons[i].texture:SetDesaturated(false)
            end)
        end)
    else
        markButtons[i].texture:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
        SetRaidTargetIconTexture(markButtons[i].texture, i)
        markButtons[i]:RegisterForClicks("LeftButtonDown", "RightButtonDown")
        markButtons[i]:SetScript("OnClick", function(self, button)
            if button == "LeftButton" then
                -- set raid target icon
                -- if GetRaidTargetIndex("target") == i then
                --     SetRaidTarget("target", 0)
                -- else
                    SetRaidTarget("target", i)
                -- end
            elseif button == "RightButton" then
                -- lock raid target icon
                local target = F:GetTargetUnitId()
                if target then
                    if markButtons[i].locked then
                        SetRaidTarget(markButtons[i].locked, 0)
                        markButtons[i]:SetBackdropBorderColor(0, 0, 0, 1)
                        markButtons[i].locked = nil
                        if markButtons[i].ticker then
                            markButtons[i].ticker:Cancel()
                            markButtons[i].ticker = nil
                        end
                    else
                        SetRaidTarget(target, i)
                        markButtons[i]:SetBackdropBorderColor(markColors[i][1], markColors[i][2], markColors[i][3], 1)
                        markButtons[i].locked = target
                        markButtons[i].ticker = C_Timer.NewTicker(1, function()
                            if GetRaidTargetIndex("target") ~= i then
                                SetRaidTarget(target, i)
                            end
                        end)
                    end
                end
            end
        end)
    end

    markButtons[i].hoverColor = {markColors[i][1], markColors[i][2], markColors[i][3], .35}

    if i == 1 then
        markButtons[i]:SetPoint("TOPLEFT")
    else
        markButtons[i]:SetPoint("LEFT", markButtons[i-1], "RIGHT", 2, 0)
    end
end

-------------------------------------------------
-- world marks
-------------------------------------------------
local worldMarks = Cell:CreateFrame("CellToolsFrame_WorldMarks", toolsFrame, 190, 20, true)
worldMarks:SetPoint("BOTTOMLEFT", 3, 3)
worldMarks:SetPoint("BOTTOMRIGHT", -3, 3)
worldMarks:Show()

local worldMarkIndices = {5, 6, 3, 2, 7, 1, 4, 8}
local worldMarkButtons = {}
for i = 1, 9 do
    worldMarkButtons[i] = Cell:CreateButton(worldMarks, "", "class-hover", {20, 20}, false, false, nil, nil, "SecureActionButtonTemplate")
    worldMarkButtons[i].texture = worldMarkButtons[i]:CreateTexture(nil, "ARTWORK")
    
    if i == 9 then
        -- clear all marks
        worldMarkButtons[i].texture:SetPoint("TOPLEFT", 2, -2)
        worldMarkButtons[i].texture:SetPoint("BOTTOMRIGHT", -2, 2)
        worldMarkButtons[i].texture:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
        worldMarkButtons[i]:SetAttribute("type", "worldmarker")
        worldMarkButtons[i]:SetAttribute("action", "clear")
    else
        worldMarkButtons[i].texture:SetPoint("TOPLEFT", 1, -1)
        worldMarkButtons[i].texture:SetPoint("BOTTOMRIGHT", -1, 1)
        worldMarkButtons[i].texture:SetColorTexture(markColors[i][1], markColors[i][2], markColors[i][3], .45)
        worldMarkButtons[i]:SetAttribute("type", "worldmarker")
        worldMarkButtons[i]:SetAttribute("marker", worldMarkIndices[i])
        -- worldMarkButtons[i]:SetAttribute("type", "macro")
        -- worldMarkButtons[i]:SetAttribute("macrotext", "/wm "..worldMarkIndices[i])
    end

    worldMarkButtons[i].hoverColor = {markColors[i][1], markColors[i][2], markColors[i][3], .35}

    if i == 1 then
        worldMarkButtons[i]:SetPoint("TOPLEFT")
    else
        worldMarkButtons[i]:SetPoint("LEFT", worldMarkButtons[i-1], "RIGHT", 2, 0)
    end
end

worldMarks:SetScript("OnUpdate", function()
    for i = 1, 8 do
        if IsRaidMarkerActive(worldMarkIndices[i]) then
            worldMarkButtons[i]:SetBackdropBorderColor(markColors[i][1], markColors[i][2], markColors[i][3], 1)
        else
            worldMarkButtons[i]:SetBackdropBorderColor(0, 0, 0, 1)
        end
    end
end)

-------------------------------------------------
-- functions
-------------------------------------------------
Cell:CreateMask(toolsFrame, L["You don't have permission to do this"])
toolsFrame.mask:Hide()
toolsFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
local function CheckPermission()
    if IsInRaid() then
        if UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
            toolsFrame.mask:Hide()
            readyBtn:SetEnabled(true)
            pullBtn:SetEnabled(true)
        else
            toolsFrame.mask:Show()
            readyBtn:SetEnabled(false)
            pullBtn:SetEnabled(false)
        end
    elseif IsInGroup() then
        toolsFrame.mask:Hide()
        if UnitIsGroupLeader("player") then
            readyBtn:SetEnabled(true)
            pullBtn:SetEnabled(true)
        else
            readyBtn:SetEnabled(false)
            pullBtn:SetEnabled(false)
        end
    else
        toolsFrame.mask:Hide()
    end
end
toolsFrame:SetScript("OnEvent", CheckPermission)

local function GroupTypeChanged(groupType)
    if groupType == "solo" then
        toolsFrame:SetHeight(26)
        readyBtn:Hide()
        pullBtn:Hide()
        marks:ClearAllPoints()
        marks:SetPoint("TOPLEFT", 3, -3)
        marks:SetPoint("TOPRIGHT", -3, -3)
        worldMarks:Hide()
    else
        toolsFrame:SetHeight(67)
        readyBtn:Show()
        pullBtn:Show()
        marks:ClearAllPoints()
        marks:SetPoint("TOPLEFT", 3, -22)
        marks:SetPoint("TOPRIGHT", -3, -22)
        worldMarks:Show()
    end
    CheckPermission()
end
Cell:RegisterCallback("GroupTypeChanged", "ToolsFrame_GroupTypeChanged", GroupTypeChanged)

function F:ShowToolsFrame()
    if toolsFrame:IsShown() then
        toolsFrame:Hide()
    else
        toolsFrame:Show()
        F:UpdatePullTimer()
        if not CellDB["ToolsTipsViewed"] then
            tips:Show()
        end
    end
    Cell.frames.raidRosterFrame:Hide()
end