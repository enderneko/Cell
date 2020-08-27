local addonName, addon = ...

local callbacks = {}

function addon:RegisterEvent(eventName, onEventFuncName, onEventFunc)
    if not callbacks[eventName] then callbacks[eventName] = {} end
    callbacks[eventName][onEventFuncName] = onEventFunc
end

function addon:UnregisterEvent(eventName, onEventFuncName)
    if not callbacks[eventName] then return end
    callbacks[eventName][onEventFuncName] = nil
end

function addon:UnregisterAllEvents(eventName)
    if not callbacks[eventName] then return end
    callbacks[eventName] = nil
end

function addon:FireEvent(eventName, ...)
    if not callbacks[eventName] then return end

    for onEventFuncName, onEventFunc in pairs(callbacks[eventName]) do
        onEventFunc(...)
    end
end