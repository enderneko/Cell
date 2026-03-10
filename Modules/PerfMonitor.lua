local _, Cell = ...
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

-------------------------------------------------
-- config
-------------------------------------------------
local OVERLAY_UPDATE_INTERVAL = 0.5   -- seconds between overlay refreshes
local MEMORY_UPDATE_INTERVAL  = 3.0   -- memory queries are expensive, run less often
local HISTORY_SIZE            = 120   -- rolling history samples (60s at 0.5s interval)
local PROFILER_UPDATE_INTERVAL = 0.5  -- function profiler display refresh

-- color thresholds (milliseconds)
local THRESH_GREEN  = 0.5
local THRESH_YELLOW = 2.0
-- anything above THRESH_YELLOW is red

local ADDON_NAME = "Cell"

-------------------------------------------------
-- state
-------------------------------------------------
local perfFrame           -- movable overlay frame
local history = {}        -- rolling stat history
local historyIndex = 0
local profiling = {}      -- function-level profiling data
local profilingEnabled = false
local eventCounter = 0    -- events processed since last tick
local eventsPerSec = 0
local memoryKB = 0

-------------------------------------------------
-- helpers
-------------------------------------------------
local function ColorByThreshold(value, greenMax, yellowMax)
    if value < greenMax then
        return "|cff00ff00"
    elseif value < yellowMax then
        return "|cffffff00"
    else
        return "|cffff4444"
    end
end

local function FormatMs(value)
    if value < 0.01 then
        return "0.00"
    elseif value < 10 then
        return format("%.2f", value)
    else
        return format("%.1f", value)
    end
end

local function FormatMemory(kb)
    if kb >= 1024 then
        return format("%.1f MB", kb / 1024)
    else
        return format("%.0f KB", kb)
    end
end

-------------------------------------------------
-- C_AddOnProfiler integration (modern API, zero overhead)
-------------------------------------------------
local hasProfilerAPI = C_AddOnProfiler and C_AddOnProfiler.GetAddOnMetric and Enum and Enum.AddOnProfilerMetric
local profilerMetrics = {}

local function UpdateProfilerMetrics()
    if not hasProfilerAPI then return end

    local ok, recent = pcall(C_AddOnProfiler.GetAddOnMetric, ADDON_NAME, Enum.AddOnProfilerMetric.RecentAverageTime)
    profilerMetrics.recentAvg = ok and (recent * 1000) or 0  -- convert seconds to ms

    ok, recent = pcall(C_AddOnProfiler.GetAddOnMetric, ADDON_NAME, Enum.AddOnProfilerMetric.PeakTime)
    profilerMetrics.peak = ok and (recent * 1000) or 0

    ok, recent = pcall(C_AddOnProfiler.GetAddOnMetric, ADDON_NAME, Enum.AddOnProfilerMetric.LastTime)
    profilerMetrics.lastTick = ok and (recent * 1000) or 0

    ok, recent = pcall(C_AddOnProfiler.GetAddOnMetric, ADDON_NAME, Enum.AddOnProfilerMetric.EncounterAverageTime)
    profilerMetrics.encounterAvg = ok and (recent * 1000) or 0

    -- spike counters
    ok, recent = pcall(C_AddOnProfiler.GetAddOnMetric, ADDON_NAME, Enum.AddOnProfilerMetric.CountTimeOver5Ms)
    profilerMetrics.spikesOver5ms = ok and recent or 0

    ok, recent = pcall(C_AddOnProfiler.GetAddOnMetric, ADDON_NAME, Enum.AddOnProfilerMetric.CountTimeOver10Ms)
    profilerMetrics.spikesOver10ms = ok and recent or 0
end

-------------------------------------------------
-- memory tracking (legacy API, always available)
-------------------------------------------------
local function UpdateMemory()
    UpdateAddOnMemoryUsage()
    memoryKB = GetAddOnMemoryUsage(ADDON_NAME)
end

-------------------------------------------------
-- event counting (hooked externally)
-------------------------------------------------
function F.PerfCountEvent()
    eventCounter = eventCounter + 1
end

-------------------------------------------------
-- history
-------------------------------------------------
local function PushHistory()
    historyIndex = historyIndex + 1
    if historyIndex > HISTORY_SIZE then historyIndex = 1 end

    history[historyIndex] = {
        time      = GetTime(),
        recentAvg = profilerMetrics.recentAvg or 0,
        peak      = profilerMetrics.peak or 0,
        memoryKB  = memoryKB,
        events    = eventsPerSec,
    }
end

local function GetHistoryStats()
    local count = min(#history, HISTORY_SIZE)
    if count == 0 then return nil end

    local sumTick, maxTick, sumMem = 0, 0, 0
    for i = 1, count do
        local h = history[i]
        if h then
            sumTick = sumTick + h.recentAvg
            if h.recentAvg > maxTick then maxTick = h.recentAvg end
            sumMem = sumMem + h.memoryKB
        end
    end

    return {
        avgTick = sumTick / count,
        maxTick = maxTick,
        avgMem  = sumMem / count,
        samples = count,
    }
end

-------------------------------------------------
-- function-level profiling (opt-in, uses debugprofilestop)
-------------------------------------------------
function F.ProfileWrap(name, fn)
    if not profilingEnabled then return fn end
    if not profiling[name] then
        profiling[name] = { calls = 0, totalTime = 0, maxTime = 0 }
    end
    return function(...)
        local start = debugprofilestop()
        local r1, r2, r3, r4, r5 = fn(...)
        local dt = debugprofilestop() - start
        local p = profiling[name]
        p.calls = p.calls + 1
        p.totalTime = p.totalTime + dt
        if dt > p.maxTime then p.maxTime = dt end
        return r1, r2, r3, r4, r5
    end
end

function F.ProfileReset()
    wipe(profiling)
end

function F.GetProfilingData()
    return profiling
end

function F.SetProfilingEnabled(enabled)
    profilingEnabled = enabled
    if not enabled then
        wipe(profiling)
    end
end

-------------------------------------------------
-- overlay frame
-------------------------------------------------
local function CreateOverlayFrame()
    perfFrame = Cell.CreateMovableFrame("Cell Perf Monitor", "CellPerfMonitorFrame", 200, 110, "HIGH", 500, true)

    -- status indicator (colored dot)
    local statusDot = perfFrame:CreateTexture(nil, "OVERLAY")
    statusDot:SetSize(8, 8)
    statusDot:SetPoint("TOPRIGHT", perfFrame, "TOPRIGHT", -8, -8)
    statusDot:SetColorTexture(0, 1, 0, 1)
    perfFrame.statusDot = statusDot

    -- font strings for each metric line
    local y = -8
    local function AddLine(label)
        local labelFS = perfFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
        labelFS:SetPoint("TOPLEFT", perfFrame, "TOPLEFT", 8, y)
        labelFS:SetTextColor(0.6, 0.6, 0.6)
        labelFS:SetText(label)

        local valueFS = perfFrame:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
        valueFS:SetPoint("TOPRIGHT", perfFrame, "TOPRIGHT", -8, y)
        valueFS:SetJustifyH("RIGHT")

        y = y - 16
        return valueFS
    end

    perfFrame.tickAvgFS    = AddLine("Tick Avg:")
    perfFrame.tickPeakFS   = AddLine("Peak:")
    perfFrame.encounterFS  = AddLine("Encounter:")
    perfFrame.memoryFS     = AddLine("Memory:")
    perfFrame.eventsFS     = AddLine("Events/s:")
    perfFrame.spikesFS     = AddLine("Spikes (>5ms):")

    -- resize to fit
    P.Size(perfFrame, 200, (-y) + 8)

    -- update loop
    local elapsed = 0
    local memElapsed = 0
    perfFrame:SetScript("OnUpdate", function(self, dt)
        elapsed = elapsed + dt
        memElapsed = memElapsed + dt

        if elapsed < OVERLAY_UPDATE_INTERVAL then return end
        elapsed = 0

        -- compute events/sec
        eventsPerSec = eventCounter / OVERLAY_UPDATE_INTERVAL
        eventCounter = 0

        -- update profiler metrics (zero-cost API)
        UpdateProfilerMetrics()

        -- update memory (less frequently)
        if memElapsed >= MEMORY_UPDATE_INTERVAL then
            memElapsed = 0
            UpdateMemory()
        end

        -- push history sample
        PushHistory()

        -- update display
        local avgMs = profilerMetrics.recentAvg or 0
        local peakMs = profilerMetrics.peak or 0
        local encMs = profilerMetrics.encounterAvg or 0

        self.tickAvgFS:SetText(ColorByThreshold(avgMs, THRESH_GREEN, THRESH_YELLOW) .. FormatMs(avgMs) .. " ms|r")
        self.tickPeakFS:SetText(ColorByThreshold(peakMs, THRESH_GREEN, THRESH_YELLOW) .. FormatMs(peakMs) .. " ms|r")
        self.encounterFS:SetText(ColorByThreshold(encMs, THRESH_GREEN, THRESH_YELLOW) .. FormatMs(encMs) .. " ms|r")
        self.memoryFS:SetText(FormatMemory(memoryKB))
        self.eventsFS:SetText(format("%.0f", eventsPerSec))
        self.spikesFS:SetText(format("%d / %d (>10ms)", profilerMetrics.spikesOver5ms or 0, profilerMetrics.spikesOver10ms or 0))

        -- status dot color
        if avgMs < THRESH_GREEN then
            self.statusDot:SetColorTexture(0, 1, 0, 1) -- green
        elseif avgMs < THRESH_YELLOW then
            self.statusDot:SetColorTexture(1, 1, 0, 1) -- yellow
        else
            self.statusDot:SetColorTexture(1, 0, 0, 1) -- red
        end
    end)

    -- save/restore position
    perfFrame:SetScript("OnShow", function(self)
        if CellDB["perfMonitor"] and CellDB["perfMonitor"]["position"] then
            local pos = CellDB["perfMonitor"]["position"]
            if pos[1] then
                self:ClearAllPoints()
                self:SetPoint(pos[1], UIParent, pos[2], pos[3], pos[4])
            end
        end
    end)

    perfFrame.header:HookScript("OnDragStop", function()
        if CellDB["perfMonitor"] then
            local point, _, relPoint, x, y = perfFrame:GetPoint()
            CellDB["perfMonitor"]["position"] = {point, relPoint, x, y}
        end
    end)

    -- right-click menu: print stats to chat
    perfFrame:SetScript("OnMouseUp", function(self, button)
        if button == "RightButton" then
            F.PerfPrintStats()
        end
    end)
end

-------------------------------------------------
-- toggle function (slash command entry point)
-------------------------------------------------
function F.TogglePerfMonitor()
    if not perfFrame then
        CreateOverlayFrame()
    end

    if perfFrame:IsShown() then
        perfFrame:Hide()
        if CellDB["perfMonitor"] then
            CellDB["perfMonitor"]["enabled"] = false
        end
    else
        -- initial memory snapshot
        UpdateMemory()
        UpdateProfilerMetrics()
        perfFrame:Show()
        if CellDB["perfMonitor"] then
            CellDB["perfMonitor"]["enabled"] = true
        end
    end
end

function F.ShowPerfMonitor()
    if not perfFrame then
        CreateOverlayFrame()
    end
    if not perfFrame:IsShown() then
        UpdateMemory()
        UpdateProfilerMetrics()
        perfFrame:Show()
    end
end

-------------------------------------------------
-- print stats to chat
-------------------------------------------------
function F.PerfPrintStats()
    local stats = GetHistoryStats()
    F.Print("|cff00ccffCell Performance Report|r")
    F.Print(format("  Current tick: %s ms  |  Peak: %s ms",
        FormatMs(profilerMetrics.recentAvg or 0),
        FormatMs(profilerMetrics.peak or 0)))
    F.Print(format("  Encounter avg: %s ms", FormatMs(profilerMetrics.encounterAvg or 0)))
    F.Print(format("  Memory: %s", FormatMemory(memoryKB)))
    F.Print(format("  Spikes: %d (>5ms)  %d (>10ms)",
        profilerMetrics.spikesOver5ms or 0,
        profilerMetrics.spikesOver10ms or 0))

    if stats then
        F.Print(format("  History (%d samples): avg tick %.2f ms, max %.2f ms",
            stats.samples, stats.avgTick, stats.maxTick))
    end

    if hasProfilerAPI then
        F.Print("  Source: C_AddOnProfiler (zero overhead)")
    else
        F.Print("  Source: legacy memory API only (C_AddOnProfiler not available)")
    end

    -- function profiling data
    if profilingEnabled and next(profiling) then
        F.Print("|cff00ccffFunction Profiling:|r")
        -- sort by total time descending
        local sorted = {}
        for name, data in pairs(profiling) do
            tinsert(sorted, { name = name, calls = data.calls, totalTime = data.totalTime, maxTime = data.maxTime })
        end
        table.sort(sorted, function(a, b) return a.totalTime > b.totalTime end)
        for _, entry in ipairs(sorted) do
            local avg = entry.calls > 0 and (entry.totalTime / entry.calls) or 0
            F.Print(format("  %s: %d calls, total %.1f ms, avg %.3f ms, max %.3f ms",
                entry.name, entry.calls, entry.totalTime / 1000, avg / 1000, entry.maxTime / 1000))
        end
    end
end

-------------------------------------------------
-- About tab integration (diagnostics pane)
-------------------------------------------------
local aboutPaneCreated = false

local function CreateDiagnosticsPane()
    if aboutPaneCreated then return end
    aboutPaneCreated = true

    local aboutTab = Cell.frames.aboutTab

    local diagPane = Cell.CreateTitledPane(aboutTab, "Performance Monitor", 422, 160)
    diagPane:SetPoint("TOPLEFT", 5, -520)

    -- description
    local descFS = diagPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    descFS:SetPoint("TOPLEFT", 5, -27)
    descFS:SetPoint("RIGHT", -5, 0)
    descFS:SetJustifyH("LEFT")
    descFS:SetSpacing(3)
    descFS:SetTextColor(0.7, 0.7, 0.7)
    descFS:SetText("Monitor Cell's impact on your UI performance.\nUses WoW's built-in C_AddOnProfiler API (zero overhead).\nRight-click the overlay to print stats to chat.")

    -- toggle overlay button
    local toggleBtn = Cell.CreateButton(diagPane, "Toggle Overlay", "accent-hover", {130, 20})
    toggleBtn:SetPoint("TOPLEFT", 5, -75)
    toggleBtn:SetScript("OnClick", function()
        F.TogglePerfMonitor()
    end)

    -- print stats button
    local printBtn = Cell.CreateButton(diagPane, "Print Stats", "accent-hover", {130, 20})
    printBtn:SetPoint("LEFT", toggleBtn, "RIGHT", 5, 0)
    printBtn:SetScript("OnClick", function()
        if not perfFrame or not perfFrame:IsShown() then
            -- need at least one snapshot
            UpdateMemory()
            UpdateProfilerMetrics()
        end
        F.PerfPrintStats()
    end)

    -- GC button
    local gcBtn = Cell.CreateButton(diagPane, "Force GC", "accent-hover", {130, 20})
    gcBtn:SetPoint("LEFT", printBtn, "RIGHT", 5, 0)
    gcBtn:SetScript("OnClick", function()
        local before = collectgarbage("count")
        collectgarbage("collect")
        local after = collectgarbage("count")
        local freed = before - after
        F.Print(format("|cff00ccffGarbage Collection:|r freed %.1f KB (%.2f MB -> %.2f MB)",
            freed, before / 1024, after / 1024))
        -- refresh memory display
        UpdateMemory()
    end)

    -- function profiling toggle
    local profilerCB = Cell.CreateCheckButton(diagPane, "Enable function-level profiling (adds overhead)", function(checked)
        F.SetProfilingEnabled(checked)
        if checked then
            F.Print("|cff00ccffFunction profiling enabled.|r Hot-path functions will be timed on next reload.")
        else
            F.Print("|cff00ccffFunction profiling disabled.|r")
        end
    end)
    profilerCB:SetPoint("TOPLEFT", 5, -105)

    -- live stats display
    local liveFS = diagPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    liveFS:SetPoint("TOPLEFT", 5, -135)
    liveFS:SetJustifyH("LEFT")
    liveFS:SetTextColor(0.5, 0.5, 0.5)
    diagPane.liveFS = liveFS

    -- update live stats when about tab is shown
    local liveElapsed = 0
    diagPane:SetScript("OnUpdate", function(self, dt)
        if not self:IsVisible() then return end
        liveElapsed = liveElapsed + dt
        if liveElapsed < 1.0 then return end
        liveElapsed = 0

        UpdateProfilerMetrics()
        local avgMs = profilerMetrics.recentAvg or 0
        local peakMs = profilerMetrics.peak or 0
        local statusColor = ColorByThreshold(avgMs, THRESH_GREEN, THRESH_YELLOW)

        liveFS:SetText(format("%s%s|r tick avg | %s peak | %s | overlay %s",
            statusColor, FormatMs(avgMs) .. " ms",
            FormatMs(peakMs) .. " ms",
            FormatMemory(memoryKB),
            (perfFrame and perfFrame:IsShown()) and "|cff00ff00ON|r" or "|cff999999OFF|r"))
    end)
end

-- hook into About tab display
Cell.RegisterCallback("ShowOptionsTab", "PerfMonitor_ShowTab", function(tab)
    if tab == "about" then
        CreateDiagnosticsPane()
    end
end)

-------------------------------------------------
-- init: restore overlay if it was enabled
-------------------------------------------------
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")

    if type(CellDB["perfMonitor"]) ~= "table" then
        CellDB["perfMonitor"] = {
            ["enabled"] = false,
            ["position"] = {},
        }
    end

    if CellDB["perfMonitor"]["enabled"] then
        C_Timer.After(3, function()
            F.ShowPerfMonitor()
        end)
    end
end)
