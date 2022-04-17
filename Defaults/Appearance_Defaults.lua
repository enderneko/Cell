local addonName, Cell = ...

Cell.defaults.appearance = {
    ["scale"] = 1,
    ["optionsFontSizeOffset"] = 0,
    ["useGameFont"] = true,
    ["texture"] = "Cell ".._G.DEFAULT,
    ["barColor"] = {"class_color", {0.2, 0.2, 0.2}},
    ["lossColor"] = {"class_color_dark", {0.667, 0, 0}},
    ["powerColor"] = {"power_color", {0.7, 0.7, 0.7}},
    ["barAlpha"] = 1,
    ["lossAlpha"] = 1,
    ["bgAlpha"] = 1,
    ["barAnimation"] = "Flash",
    ["auraIconOptions"] = {
        ["animation"] = "duration",
        ["durationRoundUp"] = false,
        ["durationDecimal"] = 0,
        ["durationColorEnabled"] = false,
        ["durationColors"] = {{0,1,0}, {1,1,0,0.5}, {1,0,0,3}},
    },
    ["targetColor"] = {1, 0.31, 0.31, 1},
    ["mouseoverColor"] = {1, 1, 1, 0.6},
    ["highlightSize"] = 1,
    ["outOfRangeAlpha"] = 0.45,
    ["healPrediction"] = true,
    ["healAbsorb"] = true,
    ["shield"] = true,
    ["overshield"] = true,
}

local buttonStyleIndices = {
    "texture",
    "barColor",
    "lossColor",
    "powerColor",
    "barAlpha",
    "lossAlpha",
    "bgAlpha",
    "barAnimation",
    "auraIconOptions",
    "targetColor",
    "mouseoverColor",
    "highlightSize",
    "outOfRangeAlpha",
    "healPrediction",
    "healAbsorb",
    "shield",
    "overshield",
}
function Cell:ResetButtonStyle()
    for _, index in pairs(buttonStyleIndices) do
        CellDB["appearance"][index] = Cell.defaults.appearance[index]
    end
end