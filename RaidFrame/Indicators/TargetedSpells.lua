local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local I = Cell.iFuncs

-------------------------------------------------
-- targeted spells
-------------------------------------------------
local castsOnTargets, spells = {}, {}
spells[5176] = true

local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(_, event, sourceUnit)
    if event == "ENCOUNTER_END" then
        F:IterateAllUnitButtons(function(b)
            b.indicators.targetedSpells:Hide()
        end)
        return
    end

    if sourceUnit then -- and UnitIsEnemy(sourceUnit, "player") then
        local sourceGUID = UnitGUID(sourceUnit)
        local currentCast = castsOnTargets[sourceGUID]

        if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_DELAYED"  or event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" or event == "UNIT_TARGET" then
            if not currentCast then
                -- name, text, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible, spellId
                local name, _, texture, startTimeMS, endTimeMS, _, _, notInterruptible, spellId = UnitCastingInfo(sourceUnit)
                if not name then
                    -- name, text, texture, startTimeMS, endTimeMS, isTradeSkill, notInterruptible, spellId
                    name, _, texture, startTimeMS, endTimeMS, _, notInterruptible, spellId = UnitChannelInfo(sourceUnit)
                end
                
                if spellId and spells[spellId] then
                    local targetUnit = sourceUnit.."target"
                    if UnitExists(targetUnit) then
                        if IsInRaid() then -- raid
                            for i = 1, GetNumGroupMembers() do
                                -- UnitIsUnit(targetUnit, )
                            end
                        elseif IsInGroup() then -- party

                        else -- solo

                        end
                        -- for unit in WA_IterateGroupMembers() do
                            -- if UnitIsUnit(targetUnit, unit) then
                                local targetGUID = UnitGUID(groupmember)
                                casts[sourceGUID] = {
                                    ["name"] = name,
                                    ["icon"] = texture,
                                    ["startTime"] = startTimeMS/1000,
                                    ["endTime"] = endTimeMS/1000,
                                    ["spellId"] = spellId,
                                    ["target"] = groupmember,
                                    ["targetGUID"] = unit,
                                }
                            -- end
                        -- end
                    end
                end
            else
                if UnitExists(sourceUnit) then
                    if event == "UNIT_SPELLCAST_DELAYED" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" or event == "UNIT_SPELLCAST_CHANNEL_START" then
                        local castType
                        local name, _, _, startTimeMS, endTimeMS, _, _, notInterruptible,spellId = UnitCastingInfo(sourceUnit)
                        if name then
                            castType = "cast"
                        else
                            name,  _, _, startTimeMS, endTimeMS, _, notInterruptible, spellId = UnitChannelInfo(sourceUnit)
                            if name then
                                castType = "channel"
                            end
                        end
                        if spellId then
                            cast["startTime"] = startTimeMS/1000
                            cast["endTime"] = endTimeMS/1000
                        end

                    -- elseif event == "UNIT_TARGET" then
                    --     local targetUnit = sourceUnit.."target"
                    --     if UnitExists(targetUnit) then
                    --         -- for groupmember in WA_IterateGroupMembers() do
                    --         --     if UnitIsUnit(targetUnit, groupmember) then
                    --                 local targetGUID = UnitGUID(groupmember)
                    --                 local targeted = targetGUID == WeakAuras.myGUID
                    --                 local spellId = cast.spellId
                    --                 cast.changed = true
                    --                 cast.target = groupmember
                    --                 cast.targetGUID = targetGUID
                    --                 cast.targeted = targeted
                                    
                    --                 iconChanged = true
                    --         --     end
                    --         -- end
                    --     end
                    end
                end
            end
        elseif cast then
            if event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_FAILED_QUIET" or event == "UNIT_SPELLCAST_CHANNEL_STOP" then
                casts[sourceGUID] = nil
            end
        end
        
        if iconChanged then
            local change = false
            -- update allstates from allcasts
            for sourceGUID, cast in pairs(allcasts) do
                -- index for allstates is "spellId_targetGUID"
                local index = ("%s_%s"):format(cast.spellId, cast.targetGUID)
                
                local state = allstates[index]
                
                if state and state.show then
                    state.casts[sourceGUID] = true
                    if cast.expirationTime > state.expirationTime then
                        state.expirationTime = cast.expirationTime
                        state.changed = true
                        change = true
                    end
                else
                    allstates[index] = {
                        show = true,
                        name = cast.name,
                        icon = cast.icon,
                        changed = true,
                        autoHide = true,
                        progressType = "timed",
                        duration = cast.expirationTime - cast.start,
                        expirationTime = cast.expirationTime,
                        spellId = cast.spellId,
                        castType = cast.castType,
                        notInterruptible = cast.notInterruptible,
                        target = cast.target,
                        unit = cast.showIcon and cast.target,
                        targetGUID = cast.targetGUID,
                        casts = {
                            [sourceGUID] = true
                        },
                        targeted = cast.targeted,
                        showGlow = cast.showGlow,
                        playSound = cast.playSound,
                        bigIcon = cast.bigIcon,
                        showIcon = cast.showIcon,
                    }
                    change = true
                end
            end
            
            -- count how much of the same cast is showing each icon
            -- remove casts stopped from state.casts
            -- remove state if state.casts is empty
            for index, state in pairs(allstates) do 
                if state.show and state.showIcon then
                    local countcasts = 0
                    for sourceGUID,_ in pairs(state.casts) do
                        local cast = allcasts[sourceGUID]
                        if not cast
                        or (cast and cast.targetGUID ~= state.targetGUID)
                        then
                            state.casts[sourceGUID] = nil
                        else 
                            countcasts = countcasts + 1
                        end
                    end
                    if state.stacks ~= countcasts then
                        state.stacks = countcasts
                        state.changed = true
                        change = true
                    end
                    -- hide if no cast
                    if countcasts == 0 then
                        state.show = false 
                        state.changed = true
                        change = true
                    end
                end
            end
            if change then
                return true 
            end
        end
    end
end)

function I:CreateTargetedSpells(parent)
    local frame = I:CreateAura_BorderIcon(parent:GetName().."TargetedSpells", parent.widget.overlayFrame, 2)
    parent.indicators.targetedSpells = frame
    frame:Hide()

    function frame:SetCooldown(start, duration, debuffType, texture, count, refreshing)
        frame.stack:Hide()
        frame.duration:Hide()

        frame.border:Show()
        frame.cooldown:Show()
        frame.cooldown:SetSwipeColor(1, 1, 0)
        frame.cooldown:SetCooldown(start, duration)
        frame.icon:SetTexture(texture)
        frame:Show()
    end

    function frame:ShowGlow(glowType, glowOptions)
        if glowType == "Normal" then
            LCG.PixelGlow_Stop(parent)
            LCG.AutoCastGlow_Stop(parent)
            LCG.ButtonGlow_Start(parent, glowOptions[1])
        elseif glowType == "Pixel" then
            LCG.ButtonGlow_Stop(parent)
            LCG.AutoCastGlow_Stop(parent)
            -- color, N, frequency, length, thickness
            LCG.PixelGlow_Start(parent, glowOptions[1], glowOptions[2], glowOptions[3], glowOptions[4], glowOptions[5])
        elseif glowType == "Shine" then
            LCG.ButtonGlow_Stop(parent)
            LCG.PixelGlow_Stop(parent)
            -- color, N, frequency, scale
            LCG.AutoCastGlow_Start(parent, glowOptions[1], glowOptions[2], glowOptions[3], glowOptions[4])
        else
            LCG.ButtonGlow_Stop(parent)
            LCG.PixelGlow_Stop(parent)
            LCG.AutoCastGlow_Stop(parent)
        end
    end

    function frame:HideGlow(glowType)
        if glowType == "Normal" then
            LCG.ButtonGlow_Stop(parent)
        elseif glowType == "Pixel" then
            LCG.PixelGlow_Stop(parent)
        elseif glowType == "Shine" then
            LCG.AutoCastGlow_Stop(parent)
        end
    end

    frame:SetScript("OnHide", function()
        LCG.ButtonGlow_Stop(parent)
        LCG.PixelGlow_Stop(parent)
        LCG.AutoCastGlow_Stop(parent)
    end)
end

function I:EnableTargetedSpells(enabled)
    if enabled then
        -- UNIT_SPELLCAST_DELAYED UNIT_SPELLCAST_FAILED UNIT_SPELLCAST_FAILED_QUIET UNIT_SPELLCAST_INTERRUPTED UNIT_SPELLCAST_START UNIT_SPELLCAST_STOP
        -- UNIT_SPELLCAST_CHANNEL_START UNIT_SPELLCAST_CHANNEL_STOP UNIT_SPELLCAST_CHANNEL_UPDATE
        -- UNIT_TARGET ENCOUNTER_END

        -- eventFrame:RegisterEvent("UNIT_SPELLCAST_START")
        -- eventFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
        -- eventFrame:RegisterEvent("UNIT_SPELLCAST_DELAYED")
        -- eventFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
        -- eventFrame:RegisterEvent("UNIT_SPELLCAST_FAILED_QUIET")
        -- eventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
        -- eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
        -- eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
        -- eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
        -- -- eventFrame:RegisterEvent("UNIT_TARGET")
        -- eventFrame:RegisterEvent("ENCOUNTER_END")
    else
        eventFrame:UnregisterAllEvents()
    end
end