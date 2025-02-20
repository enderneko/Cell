local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

local powerFilters = Cell.CreateFrame("CellOptionsFrame_PowerFilters", Cell.frames.layoutsTab, 285, 205)
Cell.frames.powerFilters = powerFilters
powerFilters:SetFrameLevel(Cell.frames.layoutsTab:GetFrameLevel() + 50)

local selectedLayout, selectedLayoutTable

-----------------------------------------
-- power filter
-----------------------------------------
local CreatePowerFilter

if Cell.isVanilla then
    local function UpdateButton(b, enabled)
        b.tex:SetDesaturated(not enabled)
        if enabled then
            b.fs:SetTextColor(unpack(b.classColor))
        else
            b.fs:SetTextColor(0.4, 0.4, 0.4)
        end
    end

    CreatePowerFilter = function(parent, class, buttons, width, height, color, bgColor)
        local filter = Cell.CreateButton(parent, class, "accent-hover", {width, height})
        filter:SetTexture("classicon-"..strlower(class), {height-4, height-4}, {"LEFT", 2, 0}, true, true)
        P.Size(filter, width, height)


        if class == "VEHICLE" or class == "PET" or class == "NPC" then
            filter:SetText(L[class])
            filter.classColor = {0, 1, 0.2}
        else
            filter.classColor = {F.GetClassColor(class)}
            filter:SetText(F.GetLocalizedClassName(class))
        end

        filter:SetScript("OnClick", function()
            selectedLayoutTable["powerFilters"][class] = not selectedLayoutTable["powerFilters"][class]
            UpdateButton(filter, selectedLayoutTable["powerFilters"][class])
            -- update now, if selectedLayout == currentLayout
            if selectedLayout == Cell.vars.currentLayout then
                Cell.Fire("UpdateLayout", selectedLayout, "powerFilter")
            end
        end)

        function filter:Load()
            UpdateButton(filter, selectedLayoutTable["powerFilters"][class])
        end

        return filter
    end

else

    local function UpdateButton(b, enabled)
        b.tex:SetDesaturated(not enabled)
        if enabled then
            b:SetBackdropColor(unpack(b.hoverColor))
            b:SetScript("OnEnter", nil)
            b:SetScript("OnLeave", nil)
        else
            b:SetBackdropColor(unpack(b.color))
            b:SetScript("OnEnter", function()
                b:SetBackdropColor(unpack(b.hoverColor))
            end)
            b:SetScript("OnLeave", function()
                b:SetBackdropColor(unpack(b.color))
            end)
        end
    end

    CreatePowerFilter = function(parent, class, buttons, width, height, color, bgColor)
        local filter = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        Cell.StylizeFrame(filter, color, bgColor)
        P.Size(filter, width, height)

        filter.text = filter:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
        filter.text:SetPoint("LEFT", 5, 0)
        if class == "VEHICLE" or class == "PET" or class == "NPC" then
            filter.text:SetText("|cff00ff33"..L[class])
        else
            filter.text:SetText(F.GetClassColorStr(class)..F.GetLocalizedClassName(class))
        end

        filter.buttons = {}
        local last
        for i = #buttons, 1, -1 do
            local b = Cell.CreateButton(filter, nil, "accent-hover", {height, height})
            filter.buttons[buttons[i]] = b
            b:SetTexture(F.GetDefaultRoleIcon(buttons[i]), {height-4, height-4}, {"CENTER", 0, 0})

            if last then
                b:SetPoint("BOTTOMRIGHT", last, "BOTTOMLEFT", P.Scale(1), 0)
            else
                b:SetPoint("BOTTOMRIGHT", filter)
            end
            last = b

            b:SetScript("OnClick", function()
                local selected
                if type(selectedLayoutTable["powerFilters"][class]) == "boolean" then
                    selectedLayoutTable["powerFilters"][class] = not selectedLayoutTable["powerFilters"][class]
                    selected = selectedLayoutTable["powerFilters"][class]
                else
                    selectedLayoutTable["powerFilters"][class][buttons[i]] = not selectedLayoutTable["powerFilters"][class][buttons[i]]
                    selected = selectedLayoutTable["powerFilters"][class][buttons[i]]
                end
                UpdateButton(b, selected)
                -- update now, if selectedLayout == currentLayout
                if selectedLayout == Cell.vars.currentLayout then
                    Cell.Fire("UpdateLayout", selectedLayout, "powerFilter")
                end
            end)
        end

        function filter:Load()
            if type(selectedLayoutTable["powerFilters"][class]) == "boolean" then
                UpdateButton(filter.buttons["DAMAGER"], selectedLayoutTable["powerFilters"][class])
            else
                for role, b in pairs(filter.buttons) do
                    UpdateButton(b, selectedLayoutTable["powerFilters"][class][role])
                end
            end
        end

        return filter
    end
end

-------------------------------------------------
-- filters
-------------------------------------------------
local dkF, dhF, druidF, evokerF, hunterF, mageF, monkF, paladinF, priestF, rogueF, shamanF, warlockF, warriorF, petF, vehicleF, npcF

local function CreateFilters()
    druidF = CreatePowerFilter(powerFilters, "DRUID", {"TANK", "HEALER", "DAMAGER"}, 135, 20)
    hunterF = CreatePowerFilter(powerFilters, "HUNTER", {"DAMAGER"}, 135, 20)
    mageF = CreatePowerFilter(powerFilters, "MAGE", {"DAMAGER"}, 135, 20)
    paladinF = CreatePowerFilter(powerFilters, "PALADIN", {"TANK", "HEALER", "DAMAGER"}, 135, 20)
    priestF = CreatePowerFilter(powerFilters, "PRIEST", {"HEALER", "DAMAGER"}, 135, 20)
    rogueF = CreatePowerFilter(powerFilters, "ROGUE", {"DAMAGER"}, 135, 20)
    shamanF = CreatePowerFilter(powerFilters, "SHAMAN", {"HEALER", "DAMAGER"}, 135, 20)
    warlockF = CreatePowerFilter(powerFilters, "WARLOCK", {"DAMAGER"}, 135, 20)
    warriorF = CreatePowerFilter(powerFilters, "WARRIOR", {"TANK", "DAMAGER"}, 135, 20)
    petF = CreatePowerFilter(powerFilters, "PET", {"DAMAGER"}, 135, 20)
    vehicleF = CreatePowerFilter(powerFilters, "VEHICLE", {"DAMAGER"}, 135, 20)
    npcF = CreatePowerFilter(powerFilters, "NPC", {"DAMAGER"}, 135, 20)

    if Cell.isRetail then
        P.Height(powerFilters, 205)

        dkF =  CreatePowerFilter(powerFilters, "DEATHKNIGHT", {"TANK", "DAMAGER"}, 135, 20)
        dhF = CreatePowerFilter(powerFilters, "DEMONHUNTER", {"TANK", "DAMAGER"}, 135, 20)
        monkF = CreatePowerFilter(powerFilters, "MONK", {"TANK", "HEALER", "DAMAGER"}, 135, 20)
        evokerF = CreatePowerFilter(powerFilters, "EVOKER", {"HEALER", "DAMAGER"}, 135, 20)

        dkF:SetPoint("TOPLEFT", 5, -5)
        dhF:SetPoint("TOPLEFT", 145, -5)
        druidF:SetPoint("TOPLEFT", dkF, "BOTTOMLEFT", 0, -5)
        evokerF:SetPoint("TOPLEFT", dhF, "BOTTOMLEFT", 0, -5)
        hunterF:SetPoint("TOPLEFT", druidF, "BOTTOMLEFT", 0, -5)
        mageF:SetPoint("TOPLEFT", evokerF, "BOTTOMLEFT", 0, -5)
        monkF:SetPoint("TOPLEFT", hunterF, "BOTTOMLEFT", 0, -5)
        paladinF:SetPoint("TOPLEFT", mageF, "BOTTOMLEFT", 0, -5)
        priestF:SetPoint("TOPLEFT", monkF, "BOTTOMLEFT", 0, -5)
        rogueF:SetPoint("TOPLEFT", paladinF, "BOTTOMLEFT", 0, -5)
        shamanF:SetPoint("TOPLEFT", priestF, "BOTTOMLEFT", 0, -5)
        warlockF:SetPoint("TOPLEFT", rogueF, "BOTTOMLEFT", 0, -5)
        warriorF:SetPoint("TOPLEFT", shamanF, "BOTTOMLEFT", 0, -5)
        petF:SetPoint("TOPLEFT", warlockF, "BOTTOMLEFT", 0, -5)
        vehicleF:SetPoint("TOPLEFT", warriorF, "BOTTOMLEFT", 0, -5)
        npcF:SetPoint("TOPLEFT", petF, "BOTTOMLEFT", 0, -5)

    elseif Cell.isCata or Cell.isWrath then
        P.Height(powerFilters, 180)

        dkF =  CreatePowerFilter(powerFilters, "DEATHKNIGHT", {"TANK", "DAMAGER"}, 135, 20)

        dkF:SetPoint("TOPLEFT", 5, -5)
        druidF:SetPoint("TOPLEFT", 145, -5)
        hunterF:SetPoint("TOPLEFT", dkF, "BOTTOMLEFT", 0, -5)
        mageF:SetPoint("TOPLEFT", druidF, "BOTTOMLEFT", 0, -5)
        paladinF:SetPoint("TOPLEFT", hunterF, "BOTTOMLEFT", 0, -5)
        priestF:SetPoint("TOPLEFT", mageF, "BOTTOMLEFT", 0, -5)
        rogueF:SetPoint("TOPLEFT", paladinF, "BOTTOMLEFT", 0, -5)
        shamanF:SetPoint("TOPLEFT", priestF, "BOTTOMLEFT", 0, -5)
        warlockF:SetPoint("TOPLEFT", rogueF, "BOTTOMLEFT", 0, -5)
        warriorF:SetPoint("TOPLEFT", shamanF, "BOTTOMLEFT", 0, -5)
        petF:SetPoint("TOPLEFT", warlockF, "BOTTOMLEFT", 0, -5)
        vehicleF:SetPoint("TOPLEFT", warriorF, "BOTTOMLEFT", 0, -5)
        npcF:SetPoint("TOPLEFT", petF, "BOTTOMLEFT", 0, -5)

    elseif Cell.isVanilla then
        P.Height(powerFilters, 155)

        druidF:SetPoint("TOPLEFT", 5, -5)
        hunterF:SetPoint("TOPLEFT", 145, -5)
        mageF:SetPoint("TOPLEFT", druidF, "BOTTOMLEFT", 0, -5)
        paladinF:SetPoint("TOPLEFT", hunterF, "BOTTOMLEFT", 0, -5)
        priestF:SetPoint("TOPLEFT", mageF, "BOTTOMLEFT", 0, -5)
        rogueF:SetPoint("TOPLEFT", paladinF, "BOTTOMLEFT", 0, -5)
        shamanF:SetPoint("TOPLEFT", priestF, "BOTTOMLEFT", 0, -5)
        warlockF:SetPoint("TOPLEFT", rogueF, "BOTTOMLEFT", 0, -5)
        warriorF:SetPoint("TOPLEFT", shamanF, "BOTTOMLEFT", 0, -5)
        petF:SetPoint("TOPLEFT", warlockF, "BOTTOMLEFT", 0, -5)
        vehicleF:SetPoint("TOPLEFT", warriorF, "BOTTOMLEFT", 0, -5)
        npcF:SetPoint("TOPLEFT", petF, "BOTTOMLEFT", 0, -5)
    end
end

-------------------------------------------------
-- scripts
-------------------------------------------------
powerFilters:SetScript("OnHide", function()
    powerFilters:Hide()
    Cell.frames.layoutsTab.mask:Hide()
    Cell.frames.layoutsTab.powerFilterBtn:SetFrameLevel(Cell.frames.layoutsTab:GetFrameLevel() + 1)
end)

local init
function F.ShowPowerFilters(l, lt)
    selectedLayout, selectedLayoutTable = l, lt

    if not init then
        init = true
        powerFilters:UpdatePixelPerfect()
        powerFilters:SetBackdropBorderColor(unpack(Cell.GetAccentColorTable()))
        CreateFilters()
    end

    if powerFilters:IsShown() then
        powerFilters:Hide()
        Cell.frames.layoutsTab.powerFilterBtn:SetFrameLevel(Cell.frames.layoutsTab:GetFrameLevel() + 2)
    else
        powerFilters:Show()
        Cell.frames.layoutsTab.powerFilterBtn:SetFrameLevel(Cell.frames.layoutsTab:GetFrameLevel() + 50)
        Cell.frames.layoutsTab.mask:Show()

        -- load db
        druidF:Load()
        hunterF:Load()
        mageF:Load()
        paladinF:Load()
        priestF:Load()
        rogueF:Load()
        shamanF:Load()
        warlockF:Load()
        warriorF:Load()
        petF:Load()
        vehicleF:Load()
        npcF:Load()

        if Cell.isRetail or Cell.isCata or Cell.isWrath then
            dkF:Load()
        end

        if Cell.isRetail then
            dhF:Load()
            monkF:Load()
            evokerF:Load()
        end
    end
end

function F.HidePowerFilters()
    powerFilters:Hide()
end