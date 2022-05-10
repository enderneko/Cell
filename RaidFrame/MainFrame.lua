local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

Cell.unitButtons = {
    ["solo"] = {},
    ["party"] = {
        ["units"] = {}, -- NOTE: update in PartyFrame _initialAttribute-refreshUnitChange
    },
    ["raid"] = {
        ["units"] = {}, -- NOTE: update in UnitButton_OnAttributeChanged
    },
    ["npc"] = {
        ["units"] = {}, -- NOTE: update on creation
    },
    ["arena"] = {},
}

local hoverTop, hoverBottom, hoverLeft, hoverRight
local tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY
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
        -- if not InCombatLockdown() then
            -- P:PixelPerfectPoint(anchorFrame)
        -- end
    end)
end

-------------------------------------------------
-- buttons
-------------------------------------------------
local menuFrame = CreateFrame("Frame", "CellMenuFrame", cellMainFrame)
Cell.frames.menuFrame = menuFrame
menuFrame:SetAllPoints(anchorFrame)

local options = Cell:CreateButton(menuFrame, "", "red", {20, 10}, false, true)
P:Point(options, "TOPLEFT", menuFrame)
options:SetFrameStrata("MEDIUM")
RegisterDragForMainFrame(options)
options:SetScript("OnClick", function()
    F:ShowOptionsFrame()
end)
options:HookScript("OnEnter", function()
    CellTooltip:SetOwner(options, "ANCHOR_NONE")
    CellTooltip:SetPoint(tooltipPoint, options, tooltipRelativePoint, tooltipX, tooltipY)
    CellTooltip:AddLine(L["Options"])
    CellTooltip:Show()
end)
options:HookScript("OnLeave", function()
    CellTooltip:Hide()
end)

local raid = Cell:CreateButton(menuFrame, "", "blue", {20, 10}, false, true)
P:Point(raid, "LEFT", options, "RIGHT", 1, 0)
raid:SetFrameStrata("MEDIUM")
RegisterDragForMainFrame(raid)
raid:SetScript("OnClick", function()
    F:ShowRaidRosterFrame()
end)

-- REVIEW: raid tool button
--[===[
local frame = CreateFrame("Frame", nil, cellMainFrame, "BackdropTemplate")
Cell:StylizeFrame(frame)
frame:SetSize(100, 100)
frame:SetPoint("BOTTOMLEFT", cellMainFrame, "TOPLEFT", 0, 30)
frame:Hide()

local mark = Cell:CreateButton(frame, "", "accent-hover", {20, 20}, false, false, nil, nil, "SecureActionButtonTemplate")
mark:SetPoint("CENTER")
mark:SetSize(20, 20)
mark.texture = mark:CreateTexture(nil, "ARTWORK")
mark.texture:SetColorTexture(1, 0, 0, 0.4)
mark.texture:SetAllPoints(mark)
mark:SetAttribute("type", "worldmarker")
mark:SetAttribute("marker", 1)

-- local tools = Cell:CreateButton(menuFrame, "", "chartreuse", {20, 10}, false, true, nil, nil, "SecureHandlerAttributeTemplate,SecureHandlerClickTemplate")
local tools = CreateFrame("Frame", nil, menuFrame, "BackdropTemplate,SecureHandlerMouseUpDownTemplate")
Cell:StylizeFrame(tools)
tools:SetSize(20, 10)
tools:EnableMouse(true)
P:Point(tools, "LEFT", raid, "RIGHT", 1, 0)
tools:SetFrameStrata("MEDIUM")
RegisterDragForMainFrame(tools)
-- tools:SetScript("_onclick", function()
--     print(frame:IsShown())
-- end)
tools:SetFrameRef("frame", frame)

tools:SetAttribute("_onmousedown", [=[
    -- self, button
    local frame = self:GetFrameRef("frame")
    local raidMarksFrame = self:GetFrameRef("raidMarksFrame")
    if frame:IsShown() then
        frame:Hide()
        raidMarksFrame:Hide()
    else
        frame:Show()
        raidMarksFrame:Show()
    end
]=])
]===]

-------------------------------------------------
-- fadeIn & fadeOut
-------------------------------------------------
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
    if CellDB["general"]["menuPosition"] == "top_bottom" then
        Cell.frames.battleResFrame:OnMenuShow()
    end
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
    if CellDB["general"]["menuPosition"] == "top_bottom" then
        Cell.frames.battleResFrame:OnMenuHide()
    end
end)
menuFrame.fadeOut:SetScript("OnFinished", function()
    fadingOut = false
    fadedOut = true
    fadedIn = false
    menuFrame:SetAlpha(0)
end)

-------------------------------------------------
-- raid setup
-------------------------------------------------
local tankIcon = "|TInterface\\AddOns\\Cell\\Media\\Roles\\TANK:0|t"
local healerIcon = "|TInterface\\AddOns\\Cell\\Media\\Roles\\HEALER:0|t"
local damagerIcon = "|TInterface\\AddOns\\Cell\\Media\\Roles\\DAMAGER:0|t"
raid:HookScript("OnEnter", function()
    CellTooltip:SetOwner(raid, "ANCHOR_NONE")
    CellTooltip:SetPoint(tooltipPoint, raid, tooltipRelativePoint, tooltipX, tooltipY)
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
-- cellMainFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
cellMainFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PET_BATTLE_OPENING_START" then
        cellMainFrame:Hide()
    elseif event == "PET_BATTLE_OVER" then
        cellMainFrame:Show()
    -- elseif event == "PLAYER_ENTERING_WORLD" then
    --     tools:SetFrameRef("raidMarksFrame", Cell.frames.raidMarksFrame)
    end
end)

-------------------------------------------------
-- load & update
-------------------------------------------------
local function UpdatePosition()
    local anchor = Cell.vars.currentLayoutTable["anchor"]
    
    cellMainFrame:ClearAllPoints()
    P:ClearPoints(raid)

    if CellDB["general"]["menuPosition"] == "top_bottom" then
        P:Size(anchorFrame, 20, 10)
        P:Size(options, 20, 10)
        P:Size(raid, 20, 10)

        
        if anchor == "BOTTOMLEFT" then
            cellMainFrame:SetPoint("BOTTOMLEFT", anchorFrame, "TOPLEFT", 0, 4)
            P:Point(raid, "BOTTOMLEFT", options, "BOTTOMRIGHT", 1, 0)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "TOPLEFT", "BOTTOMLEFT", 0, -3
            hoverTop, hoverBottom, hoverLeft, hoverRight = 5, -20, -20, 20
            
        elseif anchor == "BOTTOMRIGHT" then
            cellMainFrame:SetPoint("BOTTOMRIGHT", anchorFrame, "TOPRIGHT", 0, 4)
            P:Point(raid, "BOTTOMRIGHT", options, "BOTTOMLEFT", -1, 0)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "TOPRIGHT", "BOTTOMRIGHT", 0, -3
            hoverTop, hoverBottom, hoverLeft, hoverRight = 5, -20, -20, 20
            
        elseif anchor == "TOPLEFT" then
            cellMainFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -4)
            P:Point(raid, "TOPLEFT", options, "TOPRIGHT", 1, 0)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "BOTTOMLEFT", "TOPLEFT", 0, 3
            hoverTop, hoverBottom, hoverLeft, hoverRight = 20, -5, -20, 20
            
        elseif anchor == "TOPRIGHT" then
            cellMainFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT", 0, -4)
            P:Point(raid, "TOPRIGHT", options, "TOPLEFT", -1, 0)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "BOTTOMRIGHT", "TOPRIGHT", 0, 3
            hoverTop, hoverBottom, hoverLeft, hoverRight = 20, -5, -20, 20
        end
    else -- left_right
        P:Size(anchorFrame, 10, 20)
        P:Size(options, 10, 20)
        P:Size(raid, 10, 20)

        if anchor == "BOTTOMLEFT" then
            cellMainFrame:SetPoint("BOTTOMLEFT", anchorFrame, "BOTTOMRIGHT", 4, 0)
            P:Point(raid, "BOTTOMLEFT", options, "TOPLEFT", 0, 1)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "BOTTOMRIGHT", "BOTTOMLEFT", -3, 0
            hoverTop, hoverBottom, hoverLeft, hoverRight = 20, -20, -20, 5
            
        elseif anchor == "BOTTOMRIGHT" then
            cellMainFrame:SetPoint("BOTTOMRIGHT", anchorFrame, "BOTTOMLEFT", -4, 0)
            P:Point(raid, "BOTTOMRIGHT", options, "TOPRIGHT", 0, 1)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "BOTTOMLEFT", "BOTTOMRIGHT", 3, 0
            hoverTop, hoverBottom, hoverLeft, hoverRight = 20, -20, -5, 20
            
        elseif anchor == "TOPLEFT" then
            cellMainFrame:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT", 4, 0)
            P:Point(raid, "TOPLEFT", options, "BOTTOMLEFT", 0, -1)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "TOPRIGHT", "TOPLEFT", -3, 0
            hoverTop, hoverBottom, hoverLeft, hoverRight = 20, -20, -20, 5
            
        elseif anchor == "TOPRIGHT" then
            cellMainFrame:SetPoint("TOPRIGHT", anchorFrame, "TOPLEFT", -4, 0)
            P:Point(raid, "TOPRIGHT", options, "BOTTOMRIGHT", 0, -1)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "TOPLEFT", "TOPRIGHT", 3, 0
            hoverTop, hoverBottom, hoverLeft, hoverRight = 20, -20, -5, 20
        end
    end
end

local function UpdateMenu(which)
    F:Debug("|cff00bfffUpdateMenu:|r " .. (which or "nil"))

    if not which or which == "lock" then
        if CellDB["general"]["locked"] then
            options:RegisterForDrag()
            raid:RegisterForDrag()
            -- tools:RegisterForDrag()
        else
            options:RegisterForDrag("LeftButton")
            raid:RegisterForDrag("LeftButton")
            -- tools:RegisterForDrag("LeftButton")
        end
    end

    if not which or which == "fadeOut" then
        if CellDB["general"]["fadeOut"] then
            menuFrame.fadeOut:Play()
            local totalElapsed = 0
            menuFrame:SetScript("OnUpdate", function(self, elapsed)
                totalElapsed = totalElapsed + elapsed
                if totalElapsed >= 0.25 then
                    totalElapsed = 0
                    if (options:IsShown() and options:IsMouseOver(hoverTop, hoverBottom, hoverLeft, hoverRight)) or (raid:IsShown() and raid:IsMouseOver(hoverTop, hoverBottom, hoverLeft, hoverRight)) then -- mouseover
                        if not (fadingIn or fadedIn) then
                            menuFrame.fadeIn:Play()
                        end
                    else -- mouseout
                        if not (fadingOut or fadedOut) then
                            menuFrame.fadeOut:Play()
                        end
                    end
                end
            end)
        else
            menuFrame.fadeIn:Play()
            menuFrame:SetScript("OnUpdate", nil)
        end
    end

    if which == "position" then
        UpdatePosition()
    end
end
Cell:RegisterCallback("UpdateMenu", "MainFrame_UpdateMenu", UpdateMenu)

local function MainFrame_UpdateLayout(layout, which)
    F:Debug("|cffff0066UpdateLayout:|r layout:" .. (layout or "nil") .. " which:" .. (which or "nil"))
    
    layout = Cell.vars.currentLayoutTable
    
    if not which or which == "size" then
        P:Size(cellMainFrame, unpack(layout["size"]))
    end

    if not which or which == "anchor" then
        UpdatePosition()
    end

    -- load position
    if not P:LoadPosition(anchorFrame, Cell.vars.currentLayoutTable["position"]) then
        P:ClearPoints(anchorFrame)
        -- no position, use default
        anchorFrame:SetPoint("TOPLEFT", UIParent, "CENTER")
    end
end
Cell:RegisterCallback("UpdateLayout", "MainFrame_UpdateLayout", MainFrame_UpdateLayout)

local function UpdatePixelPerfect()
    F:Debug("|cffffff7fUpdatePixelPerfect")
    P:Resize(cellMainFrame)
    -- P:Repoint(cellMainFrame)
    P:Resize(anchorFrame)
    options:UpdatePixelPerfect()
    raid:UpdatePixelPerfect()

    -- NOTE: update pixel perfect for each button moved to UpdateIndicators
    -- F:IterateAllUnitButtons(function(b)
    --     b.func.UpdatePixelPerfect()
    -- end)
end
Cell:RegisterCallback("UpdatePixelPerfect", "MainFrame_UpdatePixelPerfect", UpdatePixelPerfect)