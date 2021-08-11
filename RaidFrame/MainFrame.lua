local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

Cell.unitButtons = {
    ["solo"] = {},
    ["party"] = {
        ["units"] = {}, -- NOTE: update in PartyFrame OnAttributeChanged
    },
    ["raid"] = {
        ["units"] = {}, -- NOTE: update in UnitButton_OnAttributeChanged
    },
    ["npc"] = {},
    ["arena"] = {},
}
-------------------------------------------------
-- CellMainFrame
-------------------------------------------------

local cellMainFrame = CreateFrame("Frame", "CellMainFrame", UIParent, "SecureFrameTemplate")
Cell.frames.mainFrame = cellMainFrame
cellMainFrame:SetIgnoreParentScale(true)
cellMainFrame:SetFrameStrata("LOW")
-- cellMainFrame:SetClampedToScreen(true)
-- cellMainFrame:SetClampRectInsets(0, 0, 15, 0)

local anchorFrame = CreateFrame("Frame", "CellAnchorFrame", cellMainFrame)
Cell.frames.anchorFrame = anchorFrame
anchorFrame:SetPoint("TOPLEFT", UIParent, "CENTER")
P:Size(anchorFrame, 20, 10)
anchorFrame:SetMovable(true)
anchorFrame:SetClampedToScreen(true)

local function RegisterDragForMainFrame(frame)
    -- frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function()
        anchorFrame:StartMoving()
        anchorFrame:SetUserPlaced(false)
    end)
    frame:SetScript("OnDragStop", function()
        anchorFrame:StopMovingOrSizing()
        P:SavePosition(anchorFrame, Cell.vars.currentLayoutTable["position"])
        P:PixelPerfectPoint(anchorFrame)
    end)
end

-------------------------------------------------
-- buttons
-------------------------------------------------
local menuFrame = CreateFrame("Frame", "CellMenuFrame", cellMainFrame)
Cell.frames.menuFrame = menuFrame
menuFrame:SetAllPoints(anchorFrame)

local options = Cell:CreateButton(menuFrame, "", "red", {20, 10}, false, true, nil, nil, nil, L["Options"])
P:Point(options, "TOPLEFT", menuFrame)
options:SetFrameStrata("MEDIUM")
RegisterDragForMainFrame(options)
options:SetScript("OnClick", function()
    F:ShowOptionsFrame()
end)

local raid = Cell:CreateButton(menuFrame, "", "blue", {20, 10}, false, true)
P:Point(raid, "LEFT", options, "RIGHT", 1, 0)
raid:SetFrameStrata("MEDIUM")
RegisterDragForMainFrame(raid)
raid:SetScript("OnClick", function()
    F:ShowRaidRosterFrame()
end)

function F:UpdateFrameLock(locked)
    if locked then
        options:RegisterForDrag()
        raid:RegisterForDrag()
    else
        options:RegisterForDrag("LeftButton")
        raid:RegisterForDrag("LeftButton")
    end
end

local fadingIn, fadedIn, fadingOut, fadedOut
menuFrame.fadeIn = menuFrame:CreateAnimationGroup()
menuFrame.fadeIn.alpha = menuFrame.fadeIn:CreateAnimation("alpha")
menuFrame.fadeIn.alpha:SetFromAlpha(0)
menuFrame.fadeIn.alpha:SetToAlpha(1)
menuFrame.fadeIn.alpha:SetDuration(.5)
menuFrame.fadeIn.alpha:SetSmoothing("OUT")
menuFrame.fadeIn:SetScript("OnPlay", function()
    menuFrame.fadeOut:Stop()
    fadingIn = true
    Cell.frames.battleResFrame:OnMenuShow()
end)
menuFrame.fadeIn:SetScript("OnFinished", function()
    fadingIn = false
    fadedIn = true
    fadedOut = false
    menuFrame:SetAlpha(1)
end)

menuFrame.fadeOut = menuFrame:CreateAnimationGroup()
menuFrame.fadeOut.alpha = menuFrame.fadeOut:CreateAnimation("alpha")
menuFrame.fadeOut.alpha:SetFromAlpha(1)
menuFrame.fadeOut.alpha:SetToAlpha(0)
menuFrame.fadeOut.alpha:SetDuration(.5)
menuFrame.fadeOut.alpha:SetSmoothing("OUT")
menuFrame.fadeOut:SetScript("OnPlay", function()
    menuFrame.fadeIn:Stop()
    fadingOut = true
    Cell.frames.battleResFrame:OnMenuHide()
end)
menuFrame.fadeOut:SetScript("OnFinished", function()
    fadingOut = false
    fadedOut = true
    fadedIn = false
    menuFrame:SetAlpha(0)
end)


function F:UpdateMenuFadeOut(fadeOut)
    if fadeOut then
        menuFrame.fadeOut:Play()
        menuFrame:SetScript("OnUpdate", function()
            if (options:IsShown() and options:IsMouseOver(20, -5, -20, 20)) or (raid:IsShown() and raid:IsMouseOver(20, -5, -20, 20)) then -- mouseover
                if not (fadingIn or fadedIn) then
                    menuFrame.fadeIn:Play()
                end
            else -- mouseout
                if not (fadingOut or fadedOut) then
                    menuFrame.fadeOut:Play()
                end
            end
        end)
    else
        menuFrame.fadeIn:Play()
        menuFrame:SetScript("OnUpdate", nil)
    end
end

-------------------------------------------------
-- raid setup
-------------------------------------------------
local tankIcon = "|TInterface\\AddOns\\Cell\\Media\\Roles\\TANK:0|t"
local healerIcon = "|TInterface\\AddOns\\Cell\\Media\\Roles\\HEALER:0|t"
local damagerIcon = "|TInterface\\AddOns\\Cell\\Media\\Roles\\DAMAGER:0|t"
raid:HookScript("OnEnter", function()
    CellTooltip:SetOwner(raid, "ANCHOR_TOPLEFT", 0, 3)
    CellTooltip:AddLine(L["Raid"])
    CellTooltip:AddLine(tankIcon.." |cffffffff"..Cell.vars.role["TANK"])
    CellTooltip:AddLine(healerIcon.." |cffffffff"..Cell.vars.role["HEALER"])
    CellTooltip:AddLine(damagerIcon.." |cffffffff"..Cell.vars.role["DAMAGER"])
    CellTooltip:Show()
end)
raid:HookScript("OnLeave", function()
    CellTooltip:Hide()
end)

function F:UpdateRaidSetup()
    if CellTooltip:GetOwner() == raid then
        CellTooltip:ClearLines()
        CellTooltip:AddLine(L["Raid"])
        CellTooltip:AddLine(tankIcon.." |cffffffff"..Cell.vars.role["TANK"])
        CellTooltip:AddLine(healerIcon.." |cffffffff"..Cell.vars.role["HEALER"])
        CellTooltip:AddLine(damagerIcon.." |cffffffff"..Cell.vars.role["DAMAGER"])
        CellTooltip:Show() -- resize
    end
end

-------------------------------------------------
-- group type changed
-------------------------------------------------
local function MainFrame_GroupTypeChanged(groupType)
    if groupType == "raid" then
        raid:Show()
    else
        raid:Hide()
    end

    if groupType == "solo" then
        if CellDB["general"]["showSolo"] then
            options:Show()
        else
            options:Hide()
        end
    elseif groupType == "party" then
        if CellDB["general"]["showParty"] then
            options:Show()
        else
            options:Hide()
        end
    else -- raid
        options:Show()
    end
end
Cell:RegisterCallback("GroupTypeChanged", "MainFrame_GroupTypeChanged", MainFrame_GroupTypeChanged)

local function MainFrame_UpdateVisibility()
    if Cell.vars.groupType == "solo" then
        if CellDB["general"]["showSolo"] then
            options:Show()
        else
            options:Hide()
        end
    elseif Cell.vars.groupType == "party" then
        if CellDB["general"]["showParty"] then
            options:Show()
        else
            options:Hide()
        end
    end
end
Cell:RegisterCallback("UpdateVisibility", "MainFrame_UpdateVisibility", MainFrame_UpdateVisibility)

-------------------------------------------------
-- event
-------------------------------------------------
cellMainFrame:RegisterEvent("PET_BATTLE_OPENING_START")
cellMainFrame:RegisterEvent("PET_BATTLE_OVER")
cellMainFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PET_BATTLE_OPENING_START" then
        cellMainFrame:Hide()
    elseif event == "PET_BATTLE_OVER" then
        cellMainFrame:Show()
    end
end)

-------------------------------------------------
-- load & update
-------------------------------------------------
local function MainFrame_UpdateLayout(layout, which)
    F:Debug("|cffffff7fUpdateLayout:|r layout:" .. (layout or "nil") .. " which:" .. (which or "nil"))
    
    layout = Cell.vars.currentLayoutTable
    
    if not which or which == "size" then
        P:Size(cellMainFrame, unpack(layout["size"]))
    end

    if not which or which == "anchor" then
        P:ClearPoints(cellMainFrame)
        P:ClearPoints(raid)

        if layout["anchor"] == "BOTTOMLEFT" then
            P:Point(cellMainFrame, "BOTTOMLEFT", anchorFrame, "TOPLEFT", 0, 4)
            P:Point(raid, "BOTTOMLEFT", options, "BOTTOMRIGHT", 1, 0)
            
        elseif layout["anchor"] == "BOTTOMRIGHT" then
            P:Point(cellMainFrame, "BOTTOMRIGHT", anchorFrame, "TOPRIGHT", 0, 4)
            P:Point(raid, "BOTTOMRIGHT", options, "BOTTOMLEFT", -1, 0)
            
        elseif layout["anchor"] == "TOPLEFT" then
            P:Point(cellMainFrame, "TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -4)
            P:Point(raid, "TOPLEFT", options, "TOPRIGHT", 1, 0)
            
        elseif layout["anchor"] == "TOPRIGHT" then
            P:Point(cellMainFrame, "TOPRIGHT", anchorFrame, "BOTTOMRIGHT", 0, -4)
            P:Point(raid, "TOPRIGHT", options, "TOPLEFT", -1, 0)
        end
    end

    -- load position
    P:LoadPosition(anchorFrame, Cell.vars.currentLayoutTable["position"])
end
Cell:RegisterCallback("UpdateLayout", "MainFrame_UpdateLayout", MainFrame_UpdateLayout)

local function UpdatePixelPerfect()
    P:Resize(cellMainFrame)
    P:Repoint(cellMainFrame)
    P:Resize(anchorFrame)
    options:UpdatePixelPerfect()
    raid:UpdatePixelPerfect()

    F:IterateAllUnitButtons(function(b)
        b.func.UpdatePixelPerfect()
    end)
end
Cell:RegisterCallback("UpdatePixelPerfect", "MainFrame_UpdatePixelPerfect", UpdatePixelPerfect)