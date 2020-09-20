-- self == L
-- rawset(t, key, value)
-- Sets the value associated with a key in a table without invoking any metamethods
-- t - A table (table)
-- key - A key in the table (cannot be nil) (value)
-- value - New value to set for the key (value)
select(2, ...).L = setmetatable({
	["target"] = "Target",
	["focus"] = "Focus",
	["assist"] = "Assist",
	["togglemenu"] = "Menu",
	["T"] = "Talent",
	["P"] = "PvP Talent",

	["BOTTOM"] = "Bottom",
	["BOTTOMLEFT"] = "Bottom Left",
	["BOTTOMRIGHT"] = "Bottom Right",
	["CENTER"] = "Center",
	["LEFT"] = "Left",
	["RIGHT"] = "Right",
	["TOP"] = "Top",
	["TOPLEFT"] = "Top Left",
	["TOPRIGHT"] = "Top Right",
}, {
	__index = function(self, Key)
		if (Key ~= nil) then
			rawset(self, Key, Key)
			return Key
		end
	end
})