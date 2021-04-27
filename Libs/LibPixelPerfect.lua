--------------------------------------------
-- LibPixelPerfect
-- fyhcslb 2021-04-27 23:54:19
-- http://wow.gamepedia.com/UI_Scale
-- http://www.wowinterface.com/forums/showthread.php?t=31813
--------------------------------------------
local lib = LibStub:NewLibrary("LibPixelPerfect", 4)
if not lib then return end

function lib:GetResolution()
    -- return string.match(({GetScreenResolutions()})[GetCurrentResolution()], "(%d+)x(%d+)")
    return GetPhysicalScreenSize()
end

-- The UI Scale goes from 1 to 0.64. 
-- At 768y we see pixel-per-pixel accurate representation of our texture, 
-- and again at 1200y if at 0.64 scale.
function lib:GetPixelPerfectScale()
    local hRes, vRes = lib:GetResolution()
    if vRes then
        return 768/vRes
    else -- windowed mode before 8.0, or maybe something goes wrong?
        return 1
    end
end

-- scale perfect!
function lib:PixelPerfectScale(frame)
    frame:SetScale(lib:GetPixelPerfectScale())
end

-- position perfect!
function lib:PixelPerfectPoint(frame)
    local left = frame:GetLeft()
    local top = frame:GetTop()
    
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", math.floor(left + .5), math.floor(top + .5))
end

function lib:SavePixelPerfectPosition(frame, positionTable)
    local left = math.floor(frame:GetLeft() + .5)
    local top = math.floor(frame:GetTop() + .5)
    positionTable[1], positionTable[2] = left, top
end

function lib:LoadPixelPerfectPosition(frame, positionTable)
    if type(positionTable) ~= "table" or #positionTable ~= 2 then return end

    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", positionTable[1], positionTable[2])
end