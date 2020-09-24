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

-- local layouts = Cell:CreateButton(cellMainFrame, "", "blue", {20, 10}, false, L["Layouts"])
-- layouts:SetPoint("LEFT", tools, "RIGHT", 1, 0)
-- layouts:Hide()
-- RegisterDragForMainFrame(layouts)

-- local function MainFrame_GroupTypeChanged(group)
--     if group == "raid" then
--         layouts:Show()
--     else
--         layouts:Hide()
--     end
-- end
-- Cell:RegisterCallback("GroupTypeChanged", "MainFrame_GroupTypeChanged", MainFrame_GroupTypeChanged)

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