--------------------------------------------
-- LibPixelPerfect
-- fyhcslb 2020-09-05 07:21:47
-- http://wow.gamepedia.com/UI_Scale
-- http://www.wowinterface.com/forums/showthread.php?t=31813
--------------------------------------------
local lib = LibStub:NewLibrary("LibPixelPerfect", "1.0")
if not lib then return end

function lib:GetResolution()
	-- local res = select(GetCurrentResolution(), GetScreenResolutions())
	-- local hRes, vRes = string.split("x", res)
	if GetCurrentResolution() == 0 then
		-- windowed mode before 8.0, or maybe something goes wrong?
		return
	else
		return string.match(({GetScreenResolutions()})[GetCurrentResolution()], "(%d+)x(%d+)")
	end
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
function lib:PixelPerfectPoint(frame, anchorTo)
	local _, vRes = lib:GetResolution()
	
	local left, bottom, width, height = frame:GetRect()
	local top = frame:GetTop()
	
	frame:ClearAllPoints()
	if frame.scaleFactor and vRes then
		frame:SetPoint("TOPLEFT", anchorTo or UIParent, math.floor(left + .5), -math.floor((vRes - top * frame.scaleFactor) / frame.scaleFactor + .5))
	else
		frame:SetPoint("BOTTOMLEFT", anchorTo or UIParent, math.floor(left + .5), math.floor(bottom + .5))
	end
end