local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

local debuffs = {
    -- Eye of Azshara
    [716] = {
        [1480] = { -- Warlord Parjesh
            192094, -- Impaling spear
			192131, -- throw-spear
        },
        [1490] = { -- Lady Hatecoil
            193597, -- static-nova
            193716, -- curse-of-the-witch
            197326, -- crackling-thunder
        },
        [1491] = { -- King Deepbeard
            193152, -- quake
            193171, -- aftershock
            193018, -- gaseous-bubbles
            193093, -- ground-slam
        },
        [1479] = { -- Serpentrix
            192050, -- poison-spit
            191855, -- toxic-wound
        },
        [1492] = { -- Wrath of Azshara
            192706, -- arcane-bomb
            192985, -- cry-of-wrath
            192675, -- mystic-tornado
            192794, -- lightning-strike
        },
    },
}
F:LoadBuiltInDebuffs(debuffs)