--------------------------------------------
-- http://wow.gamepedia.com/UI_Scale
-- http://www.wowinterface.com/forums/showthread.php?t=31813
--------------------------------------------
local _, addon = ...
addon.pixelPerfectFuncs = {}

---@class PixelPerfectFuncs
local P = addon.pixelPerfectFuncs

function P.GetResolution()
    -- return string.match(({GetScreenResolutions()})[GetCurrentResolution()], "(%d+)x(%d+)")
    return GetPhysicalScreenSize()
end

-- The UI P.Scale goes from 1 to 0.64.
-- At 768y we see pixel-per-pixel accurate representation of our texture,
-- and again at 1200y if at 0.64 scale.
function P.GetPixelPerfectScale()
    local hRes, vRes = P.GetResolution()
    if vRes then
        return 768 / vRes
    else -- windowed mode before 8.0, or maybe something goes wrong?
        return 1
    end
end

-- scale perfect!
function P.PixelPerfectScale(frame)
    frame:SetScale(P.GetPixelPerfectScale())
end

-- position perfect!
function P.PixelPerfectPoint(frame)
    local left = frame:GetLeft()
    local top = frame:GetTop()

    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", math.floor(left + 0.5), math.floor(top + 0.5))
end

--------------------------------------------
-- PixelUtil
--------------------------------------------
-- local effectiveScale = 1
-- function P.SetRelativeScale(scale)
--     effectiveScale = scale
-- end

-- function P.GetEffectiveScale()
--     return effectiveScale
-- end

-- function P.SetEffectiveScale(frame)
--     frame:SetScale(effectiveScale)
-- end

-- function P.Scale(uiUnitSize)
--     if uiUnitSize == 0 then
--         return 0
--     end

--     local uiUnitFactor = PixelUtil.GetPixelToUIUnitFactor()
--     local numPixels = Round((uiUnitSize * effectiveScale) / uiUnitFactor)
--     if uiUnitSize < 0.0 then
--         if numPixels > -1 then
--             numPixels = -1
--         end
--     else
--         if numPixels < 1 then
--             numPixels = 1
--         end
--     end

--     return numPixels * uiUnitFactor / effectiveScale
-- end

--------------------------------------------
-- some are stolen from ElvUI
--------------------------------------------
-- local function GetUIParentScale()
--     local scale = UIParent:GetScale()
--     return scale - scale % 0.1 ^ 2
-- end

local scale = 1
local mult = 1
function P.SetRelativeScale(s)
    mult = 1 / s
    scale = s
end

---@deprecated
function P.GetEffectiveScale()
    return P.GetPixelPerfectScale() / mult
end

---@deprecated
function P.SetEffectiveScale(frame)
    frame:SetScale(P.GetEffectiveScale())
end

--[[
local trunc = function(s) return s >= 0 and s-s%01 or s-s%-1 end
local round = function(s) return s >= 0 and s-s%-1 or s-s%01 end
function P.Scale(n)
    return (mult == 1 or n == 0) and n or ((mult < 1 and trunc(n/mult) or round(n/mult)) * mult)
end
]]
-- function P.Scale(n)
--     if mult == 1 or n == 0 then
--         return n
--     else
--         local x = mult > 1 and mult or -mult
--         return n - n % (n < 0 and x or -x)
--     end
-- end

local GetNearestPixelSize = PixelUtil.GetNearestPixelSize

function P.Scale(desiredPixels)
    return GetNearestPixelSize(desiredPixels, UIParent:GetScale() * scale)
end

function P.Size(frame, width, height)
    frame.width = width
    frame.height = height
    frame:SetSize(P.Scale(width), P.Scale(height))
end

function P.Width(frame, width)
    frame.width = width
    frame:SetWidth(P.Scale(width))
end

function P.Height(frame, height)
    frame.height = height
    frame:SetHeight(P.Scale(height))
end

function P.SetGridSize(region, gridWidth, gridHeight, gridSpacingH, gridSpacingV, columns, rows)
    region._size_grid = true
    region._gridWidth = gridWidth
    region._gridHeight = gridHeight
    region._gridSpacingH = gridSpacingH
    region._gridSpacingV = gridSpacingV
    region._rows = rows
    region._columns = columns

    if columns == 0 then
        region:SetWidth(0.001)
    else
        region:SetWidth(P.Scale(gridWidth) * columns + P.Scale(gridSpacingH) * (columns - 1))
    end

    if rows == 0 then
        region:SetHeight(0.001)
    else
        region:SetHeight(P.Scale(gridHeight) * rows + P.Scale(gridSpacingV) * (rows - 1))
    end
end

function P.Point(frame, ...)
    if not frame.points then frame.points = {} end
    local point, anchorTo, anchorPoint, x, y

    local n = select("#", ...)
    if n == 1 then
        point = ...
    elseif n == 3 and type(select(2, ...)) == "number" then
        point, x, y = ...
    elseif n == 4 then
        point, anchorTo, x, y = ...
    else
        point, anchorTo, anchorPoint, x, y = ...
    end

    tinsert(frame.points, {point, anchorTo or frame:GetParent(), anchorPoint or point, x or 0, y or 0})
    local n = #frame.points
    frame:SetPoint(frame.points[n][1], frame.points[n][2], frame.points[n][3], P.Scale(frame.points[n][4]), P.Scale(frame.points[n][5]))
end

function P.ClearPoints(frame)
    frame:ClearAllPoints()
    if frame.points then wipe(frame.points) end
end

--------------------------------------------
-- scale changed
--------------------------------------------
function P.Resize(frame)
    if frame._size_grid then
        P.SetGridSize(frame, frame._gridWidth, frame._gridHeight, frame._gridSpacingH, frame._gridSpacingV, frame._columns, frame._rows)
    else
        if frame.width then
            frame:SetWidth(P.Scale(frame.width))
        end
        if frame.height then
            frame:SetHeight(P.Scale(frame.height))
        end
    end
end

function P.Reborder(frame, ignoreSnippetVar)
    if not frame.backdropInfo then return end

    local _r, _g, _b, _a = frame:GetBackdropColor()
    local r, g, b, a = frame:GetBackdropBorderColor()

    if ignoreSnippetVar then
        frame.backdropInfo.edgeSize = P.Scale(1)
    else
        if CELL_BORDER_SIZE == 0 then
            frame.backdropInfo.edgeFile = nil
            frame.backdropInfo.edgeSize = nil
        else
            frame.backdropInfo.edgeSize = P.Scale(CELL_BORDER_SIZE or 1)
        end
    end
    frame:ApplyBackdrop()

    if _r then frame:SetBackdropColor(_r, _g, _b, _a) end
    if r then frame:SetBackdropBorderColor(r, g, b, a) end
end

function P.Repoint(frame)
    if not frame.points or #frame.points == 0 then return end
    frame:ClearAllPoints()
    for _, t in pairs(frame.points) do
        frame:SetPoint(t[1], t[2], t[3], P.Scale(t[4]), P.Scale(t[5]))
    end
end

-- local frames = {}
-- function P.SetPixelPerfect(frame)
--     tinsert(frames, frame)
-- end

-- function P.UpdatePixelPerfectFrames()
--     for _, f in pairs(frames) do
--         f:UpdatePixelPerfect()
--     end
-- end

--------------------------------------------
-- save & load position
--------------------------------------------
function P.SavePosition(frame, positionTable)
    wipe(positionTable)
    positionTable[1], _, positionTable[2], positionTable[3], positionTable[4] = frame:GetPoint(1)
    -- local left = math.floor(frame:GetLeft() + 0.5)
    -- local top = math.floor(frame:GetTop() + 0.5)
    -- positionTable[1], positionTable[2] = left, top
end

function P.LoadPosition(frame, positionTable)
    if type(positionTable) ~= "table" then return end

    if #positionTable == 2 then
        P.ClearPoints(frame)
        P.Point(frame, "TOPLEFT", UIParent, "BOTTOMLEFT", positionTable[1], positionTable[2])
        return true
    elseif #positionTable == 4 then
        P.ClearPoints(frame)
        frame:SetPoint(positionTable[1], UIParent, positionTable[2], positionTable[3], positionTable[4])
        return true
    end
end

---------------------------------------------------------------------
-- pixel perfect (ElvUI)
---------------------------------------------------------------------
local function CheckPixelSnap(frame, snap)
    if (frame and not frame:IsForbidden()) and frame.PixelSnapDisabled and snap then
        frame.PixelSnapDisabled = nil
    end
end

local function DisablePixelSnap(frame)
    if (frame and not frame:IsForbidden()) and not frame.PixelSnapDisabled then
        if frame.SetSnapToPixelGrid then
            frame:SetSnapToPixelGrid(false)
            frame:SetTexelSnappingBias(0)
            frame.PixelSnapDisabled = true
        elseif frame.GetStatusBarTexture then
            local texture = frame:GetStatusBarTexture()
            if type(texture) == "table" and texture.SetSnapToPixelGrid then
                texture:SetSnapToPixelGrid(false)
                texture:SetTexelSnappingBias(0)
                frame.PixelSnapDisabled = true
            end
        end
    end
end

local function UpdateMetatable(obj)
    local t = getmetatable(obj).__index

    if not obj.DisabledPixelSnap and (t.SetSnapToPixelGrid or t.SetStatusBarTexture or t.SetColorTexture or t.SetVertexColor or t.CreateTexture or t.SetTexCoord or t.SetTexture) then
        if t.SetSnapToPixelGrid then hooksecurefunc(t, "SetSnapToPixelGrid", CheckPixelSnap) end
        if t.SetStatusBarTexture then hooksecurefunc(t, "SetStatusBarTexture", DisablePixelSnap) end
        if t.SetColorTexture then hooksecurefunc(t, "SetColorTexture", DisablePixelSnap) end
        if t.SetVertexColor then hooksecurefunc(t, "SetVertexColor", DisablePixelSnap) end
        if t.CreateTexture then hooksecurefunc(t, "CreateTexture", DisablePixelSnap) end
        if t.SetTexCoord then hooksecurefunc(t, "SetTexCoord", DisablePixelSnap) end
        if t.SetTexture then hooksecurefunc(t, "SetTexture", DisablePixelSnap) end

        t.DisabledPixelSnap = true
    end
end

local obj = CreateFrame("Frame")
UpdateMetatable(CreateFrame("StatusBar"))
UpdateMetatable(obj:CreateTexture())
UpdateMetatable(obj:CreateMaskTexture())