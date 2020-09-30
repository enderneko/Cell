local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local LPP = LibStub:GetLibrary("LibPixelPerfect")

Cell.unitButtons = {
    ["solo"] = {},
    ["party"] = {},
    ["raid"] = {},
    ["npc"] = {},
}
-------------------------------------------------
-- CellMainFrame
-------------------------------------------------

local cellMainFrame = CreateFrame("Frame", "CellMainFrame", UIParent, "SecureFrameTemplate")
Cell.frames.mainFrame = cellMainFrame
cellMainFrame:SetFrameStrata("LOW")
cellMainFrame:SetClampedToScreen(true)
cellMainFrame:SetClampRectInsets(0, 0, 15, 0)

local anchorFrame = CreateFrame("Frame", "CellAnchorFrame", cellMainFrame)
Cell.frames.anchorFrame = anchorFrame
anchorFrame:SetPoint("CENTER", UIParent)
anchorFrame:SetSize(10, 10)
anchorFrame:SetMovable(true)

cellMainFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMRIGHT")

local function RegisterDragForMainFrame(frame)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function()
        anchorFrame:StartMoving()
    end)
    frame:SetScript("OnDragStop", function()
        anchorFrame:StopMovingOrSizing()
    end)
end

-------------------------------------------------
-- buttons
-------------------------------------------------
local options = Cell:CreateButton(cellMainFrame, "", "red", {20, 10}, false, true, nil, nil, L["Options"])
options:SetPoint("BOTTOMLEFT", cellMainFrame, "TOPLEFT", 0, 4)
RegisterDragForMainFrame(options)
options:SetScript("OnClick", function()
    F:ShowOptionsFrame()
end)

local tools = Cell:CreateButton(cellMainFrame, "", "blue", {20, 10}, false, true, nil, nil, L["Tools"])
tools:SetPoint("LEFT", options, "RIGHT", 1, 0)
RegisterDragForMainFrame(tools)

-------------------------------------------------
-- raid setup
-------------------------------------------------
local raidSetupFrame = CreateFrame("Frame", "CellRaidSetupFrame", cellMainFrame)
Cell.frames.raidSetupFrame = raidSetupFrame
raidSetupFrame:SetPoint("LEFT", tools, "RIGHT", 5, 0)
raidSetupFrame:SetSize(50, 15)
raidSetupFrame:Hide()

local raidSetupText = raidSetupFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
raidSetupText:SetFont(raidSetupText:GetFont(), 12, "OUTLINE")
raidSetupText:SetShadowColor(0, 0, 0)
raidSetupText:SetShadowOffset(0, 0)
raidSetupText:SetPoint("LEFT")

local tankIcon = "|TInterface\\AddOns\\Cell\\Media\\Roles\\TANK:10:10:0:0:10:10:1:9:1:9|t"
local healerIcon = "|TInterface\\AddOns\\Cell\\Media\\Roles\\HEALER:10:10:0:0:10:10:1:9:1:9|t"
local damagerIcon = "|TInterface\\AddOns\\Cell\\Media\\Roles\\DAMAGER:10:10:0:0:10:10:1:9:1:9|t"

function F:UpdateRaidSetup()
    raidSetupText:SetText(tankIcon..Cell.vars.role["TANK"]..healerIcon..Cell.vars.role["HEALER"]..damagerIcon..Cell.vars.role["DAMAGER"])
end

-------------------------------------------------
-- group type changed
-------------------------------------------------
local function MainFrame_GroupTypeChanged(groupType)
    if groupType == "raid" then
        if CellDB["showRaidSetup"] then raidSetupFrame:Show() end
    else
        raidSetupFrame:Hide()
    end
end
Cell:RegisterCallback("GroupTypeChanged", "MainFrame_GroupTypeChanged", MainFrame_GroupTypeChanged)

-------------------------------------------------
-- load & update
-------------------------------------------------
local function MainFrame_UpdateLayout(layout, which)
    F:Debug("|cffffff7fUpdateLayout:|r layout:" .. (layout or "nil") .. " which:" .. (which or "nil"))
    
    --? cause SetSize in combat error? perhaps not
    cellMainFrame:SetSize(unpack(Cell.vars.currentLayoutTable["size"]))

    -- if which == "texture" then
    --     local tex = F:GetBarTexture() -- tex == Cell.vars.texture

    --     F:IterateAllUnitButtons(function(b)
    --         b.func.SetTexture(tex)
    --     end)
    -- end
end
Cell:RegisterCallback("UpdateLayout", "MainFrame_UpdateLayout", MainFrame_UpdateLayout)