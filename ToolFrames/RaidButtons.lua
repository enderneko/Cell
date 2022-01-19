local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

local readyBtn, pullBtn

local buttonsFrame = CreateFrame("Frame", "CellRaidButtonsFrame", Cell.frames.mainFrame, "BackdropTemplate")
Cell.frames.raidButtonsFrame = buttonsFrame
P:Size(buttonsFrame, 60, 55)
buttonsFrame:SetPoint("TOPRIGHT", UIParent, "CENTER")
buttonsFrame:SetClampedToScreen(true)
buttonsFrame:SetMovable(true)
buttonsFrame:RegisterForDrag("LeftButton")
buttonsFrame:SetScript("OnDragStart", function()
    buttonsFrame:StartMoving()
    buttonsFrame:SetUserPlaced(false)
end)
buttonsFrame:SetScript("OnDragStop", function()
    buttonsFrame:StopMovingOrSizing()
    P:SavePosition(buttonsFrame, CellDB["raidTools"]["buttonsPosition"])
end)

-------------------------------------------------
-- mover
-------------------------------------------------
buttonsFrame.moverText = buttonsFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
buttonsFrame.moverText:SetPoint("TOP", 0, -3)
buttonsFrame.moverText:SetText(L["Mover"])
buttonsFrame.moverText:Hide()

local function ShowMover(show)
    if show then
        if not CellDB["raidTools"]["showButtons"] then return end
        buttonsFrame:EnableMouse(true)
        buttonsFrame.moverText:Show()
        Cell:StylizeFrame(buttonsFrame, {0, 1, 0, .4}, {0, 0, 0, 0})
        if not F:HasPermission() then -- button not shown
            readyBtn:Show()
            pullBtn:Show()
        end
    else
        buttonsFrame:EnableMouse(false)
        buttonsFrame.moverText:Hide()
        Cell:StylizeFrame(buttonsFrame, {0, 0, 0, 0}, {0, 0, 0, 0})
        if not F:HasPermission() then -- button should not shown
            readyBtn:Hide()
            pullBtn:Hide()
        end
    end
end
Cell:RegisterCallback("ShowMover", "RaidButtons_ShowMover", ShowMover)

-------------------------------------------------
-- buttons
-------------------------------------------------
pullBtn = Cell:CreateStatusBarButton(buttonsFrame, L["Pull"], {60, 17}, 7, "SecureActionButtonTemplate")
pullBtn:SetPoint("BOTTOMLEFT")
-- pullBtn:SetPoint("BOTTOMRIGHT")
pullBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
pullBtn:SetAttribute("type1", "macro")
pullBtn:SetAttribute("type2", "macro")
pullBtn:Hide()

local pullTicker
pullBtn:RegisterEvent("CHAT_MSG_ADDON")
pullBtn:SetScript("OnEvent", function(self, event, prefix, text)
    if prefix == "D4" then -- DBM
        local pre, timer = strsplit("\t", text)
        timer = tonumber(timer)
        if pre == "PT" and timer > 0 then -- start
            pullBtn:SetMaxValue(timer)
            pullBtn:Start()
            
            -- update button text
            pullBtn:SetText(timer)
            if pullTicker then
                pullTicker:Cancel()
                pullTicker = nil
            end
            pullBtn.timer = timer
            pullTicker = C_Timer.NewTicker(1, function()
                pullBtn.timer = pullBtn.timer - 1
                if pullBtn.timer == 0 then
                    pullBtn:SetText(L["Go!"])
                elseif pullBtn.timer == -1 then
                    pullBtn:SetText(L["Pull"])
                else
                    pullBtn:SetText(pullBtn.timer)
                end
            end, timer+1)

        elseif pre == "PT" and timer  == 0 then -- cancel
            pullBtn:Stop()
           
            -- update button text
            pullBtn:SetText(L["Pull"])
            if pullTicker then
                pullTicker:Cancel()
                pullTicker = nil
            end
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

readyBtn = Cell:CreateStatusBarButton(buttonsFrame, L["Ready"], {60, 17}, 35)
P:Point(readyBtn, "BOTTOMLEFT", pullBtn, "TOPLEFT", 0, 3)
-- P:Point(readyBtn, "BOTTOMRIGHT", pullBtn, "TOPRIGHT", 0, 3)
readyBtn:Hide()

readyBtn:SetScript("OnClick", function()
    DoReadyCheck()
end)
readyBtn:RegisterEvent("READY_CHECK")
readyBtn:RegisterEvent("READY_CHECK_FINISHED")
readyBtn:RegisterEvent("READY_CHECK_CONFIRM")

local ready = {}
readyBtn:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "READY_CHECK" then
        readyBtn:SetMaxValue(arg2)
        readyBtn:Start()
        wipe(ready)
        tinsert(ready, "player")
        readyBtn:SetText("1 / "..GetNumGroupMembers())
    elseif event == "READY_CHECK_FINISHED" then
        readyBtn:Stop()
        readyBtn:SetText(L["Ready"])
    else
        if arg2 then -- isReady
            if IsInRaid() then
                if string.find(arg1, "raid") then tinsert(ready, arg1) end
            else
                tinsert(ready, arg1)
            end
            readyBtn:SetText(#ready.." / "..GetNumGroupMembers())
        end
    end
end)

-------------------------------------------------
-- functions
-------------------------------------------------
local function CheckPermission()
    if InCombatLockdown() then
        buttonsFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    else
        buttonsFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
        if F:HasPermission() and CellDB["raidTools"]["showButtons"] then
            readyBtn:Show()
            readyBtn:SetEnabled(true)
            pullBtn:Show()
            pullBtn:SetEnabled(true)
        else
            readyBtn:Hide()
            readyBtn:SetEnabled(false)
            pullBtn:Hide()
            pullBtn:SetEnabled(false)
        end
    end
end

buttonsFrame:SetScript("OnEvent", function()
    CheckPermission()
end)

Cell:RegisterCallback("PermissionChanged", "RaidButtons_PermissionChanged", CheckPermission)

local function UpdateRaidTools(which)
    if not which or which == "buttons" then
        CheckPermission()
    end

    if not which or which == "pullTimer" then
        if CellDB["raidTools"]["pullTimer"][1] == "ExRT" then
            pullBtn:SetAttribute("macrotext1", "/ert pull "..CellDB["raidTools"]["pullTimer"][2])
            pullBtn:SetAttribute("macrotext2", "/ert pull 0")
        elseif CellDB["raidTools"]["pullTimer"][1] == "DBM" then
            pullBtn:SetAttribute("macrotext1", "/dbm pull "..CellDB["raidTools"]["pullTimer"][2])
            pullBtn:SetAttribute("macrotext2", "/dbm pull 0")
        else -- BW
            pullBtn:SetAttribute("macrotext1", "/pull "..CellDB["raidTools"]["pullTimer"][2])
            pullBtn:SetAttribute("macrotext2", "/pull 0")
        end
    end

    if not which then -- position
        P:LoadPosition(buttonsFrame, CellDB["raidTools"]["buttonsPosition"])
    end
end
Cell:RegisterCallback("UpdateRaidTools", "RaidButtons_UpdateRaidTools", UpdateRaidTools)

local function UpdatePixelPerfect()
    P:Resize(buttonsFrame)
    readyBtn:UpdatePixelPerfect()
    pullBtn:UpdatePixelPerfect()
end
Cell:RegisterCallback("UpdatePixelPerfect", "RaidButtons_UpdatePixelPerfect", UpdatePixelPerfect)