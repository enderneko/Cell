--[[
	Copyright (c) 2013 Bastien Clément

	Permission is hereby granted, free of charge, to any person obtaining a
	copy of this software and associated documentation files (the
	"Software"), to deal in the Software without restriction, including
	without limitation the rights to use, copy, modify, merge, publish,
	distribute, sublicense, and/or sell copies of the Software, and to
	permit persons to whom the Software is furnished to do so, subject to
	the following conditions:

	The above copyright notice and this permission notice shall be included
	in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
	CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
	TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

-- Port of oUF Smooth Update by Xuerian
-- http://www.wowinterface.com/downloads/info11503-oUFSmoothUpdate.html

--[[
Functions:

- SmoothBar(bar)
    Enables smooth animation for the bar.
	The bar:SetValue() method will be overloaded to handle animation.

  Parameters:
    bar - StatusBar frame - The StatusBar to be animated

- ResetBar(bar)
    Restores the bar to its original state. Disabling animation.

  Parameters:
    bar - StatusBar frame - The StatusBar to be restored
]]

local MAJOR = "LibSmoothStatusBar-1.0"
local MINOR = 1

local lib, upgrade = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

lib.frame     = lib.frame     or CreateFrame('Frame')
lib.smoothing = lib.smoothing or {}

-------------------------------------------------------------------------------

local abs = math.abs

local function AnimationTick()
	for bar, value in pairs(lib.smoothing) do
		local cur = bar:GetValue()
		local new = cur + ((value - cur) / 3)
		if new ~= new then
			new = value
		end
		if cur == value or abs(new - value) < 2 then
			bar:SetValue_(value)
			lib.smoothing[bar] = nil
		else
			bar:SetValue_(new)
		end
	end
end

lib.frame:SetScript("OnUpdate", AnimationTick)

local function SmoothSetValue(self, value)
	local _, max = self:GetMinMaxValues()
	if value == self:GetValue() or (self._max and self._max ~= max) then
		lib.smoothing[self] = nil
		self:SetValue_(value)
	else
		lib.smoothing[self] = value
	end
	self._max = max
end

if upgrade then
	for bar, value in pairs(lib.smoothing) do
		if bar.SetValue_ then
			bar.SetValue = SmoothSetValue
		end
	end
end

function lib:SmoothBar(bar)
	if not bar.SetValue_ then
		bar.SetValue_ = bar.SetValue;
		bar.SetValue = SmoothSetValue;
	end
end

function lib:ResetBar(bar)
	if bar.SetValue_ then
		bar.SetValue = bar.SetValue_;
		bar.SetValue_ = nil;
	end
end
