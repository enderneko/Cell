local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
-- local LPP = LibStub:GetLibrary("LibPixelPerfect")

Cell.unitButtons = {
    ["solo"] = {},
    ["party"] = {},
    ["raid"] = {},
}
-------------------------------------------------
-- CellMainFrame
-------------------------------------------------

local cellMainFrame = CreateFrame("Frame", "CellMainFrame", UIParent, "SecureFrameTemplate")
Cell.frames.mainFrame = cellMainFrame
cellMainFrame:SetFrameStrata("LOW")
cellMainFrame:SetClampedToScreen(true)

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
local options = Cell:CreateButton(cellMainFrame, "", "red", {20, 10}, false, nil, nil, L["Options"])
options:SetPoint("BOTTOMLEFT", cellMainFrame, "TOPLEFT", 0, 3)
RegisterDragForMainFrame(options)
options:SetScript("OnClick", function()
    F:ShowOptionsFrame()
end)

local tools = Cell:CreateButton(cellMainFrame, "", "blue", {20, 10}, false, nil, nil, L["Tools"])
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
-- Cell:RegisterEvent("GroupTypeChanged", "MainFrame_GroupTypeChanged", MainFrame_GroupTypeChanged)

-------------------------------------------------
-- load & update
-------------------------------------------------
local function MainFrame_UpdateClampRectInsets()
	if not Cell.loaded then return end
    -- F:Debug("UpdateClampRectInsets")

    local row, col = 1, 1
    if Cell.vars.groupType == "raid" then

    elseif Cell.vars.groupType == "party" then

    else
        row, col = F:GetSoloFrameMatrix()
    end

    local layout = Cell.vars.currentLayoutTable
    local width, height = unpack(layout["size"])
    local right, bottom
    right = width * col + layout["spacing"] * (col - 1) - width
    bottom = height - (height * row + layout["spacing"] * (row - 1))

    cellMainFrame:SetClampRectInsets(0, right, 20, bottom)
end
--! no need to SetClampRectInsets for now, but keep it here
-- Cell:RegisterEvent("UpdateClampRectInsets", "MainFrame_UpdateClampRectInsets", MainFrame_UpdateClampRectInsets)

local function MainFrame_UpdateLayout(layout, which)
    F:Debug("UpdateLayout layout:" .. (layout or "nil") .. " which:" .. (which or "nil"))
    
    --? cause SetSize in combat error? perhaps not
    cellMainFrame:SetSize(unpack(Cell.vars.currentLayoutTable["size"]))
    cellMainFrame:SetClampRectInsets(0, 0, 15, 0)

    if not which or which == "font" then
        F:UpdateFont()
        F:IterateAllUnitButtons(function(b)
            b:GetScript("OnSizeChanged")(b)
        end)
    end

    if not which or which == "scale" then
        cellMainFrame:SetScale(CellDB["scale"])
    end

    if which == "texture" then
        local tex = F:GetBarTexture() -- tex == Cell.vars.texture

        F:IterateAllUnitButtons(function(b)
            b.func.SetTexture(tex)
        end)
    end
end
Cell:RegisterEvent("UpdateLayout", "MainFrame_UpdateLayout", MainFrame_UpdateLayout)