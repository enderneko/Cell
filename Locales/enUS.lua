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

	["dispellableByMe"] = "Only show debuffs dispellable by me",
	["castByMe"] = "Only show buffs cast by me",

	["BOTTOM"] = "Bottom",
	["BOTTOMLEFT"] = "Bottom Left",
	["BOTTOMRIGHT"] = "Bottom Right",
	["CENTER"] = "Center",
	["LEFT"] = "Left",
	["RIGHT"] = "Right",
	["TOP"] = "Top",
	["TOPLEFT"] = "Top Left",
	["TOPRIGHT"] = "Top Right",

	["ABOUT"] = "Cell is a unique raid frame addon inspired by CompactRaid.\nI love CompactRaid so much, but it seems to be abandoned. And I made Cell, hope you enjoy.\nSome ideas are from other great raid frame addons, such as Aptechka, Grid2.\nCell is not meant to be a lightweight or powerful (like VuhDo, Grid2) raid frames addon. It's easy to use and good enough for you (hope so).",
	["TOOLSTIPS"] = "|cffff00ffPull Timer|r\n|cffffff00Left-Click:|r start timer\n|cffffff00Right-Click:|r cancel timer\n\n|cffff00ffTarget marker|r\n|cffffff00Left-Click:|r set raid marker on target\n|cffffff00Right-Click:|r lock raid marker on target (in group)",
}, {
	__index = function(self, Key)
		if (Key ~= nil) then
			rawset(self, Key, Key)
			return Key
		end
	end
})