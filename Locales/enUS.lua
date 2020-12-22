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
    ["notBound"] = "|cff777777".._G.NOT_BOUND,

    ["dispellableByMe"] = "Only show debuffs dispellable by me",
    ["castByMe"] = "Only show buffs cast by me",
    ["showDuration"] = "Show duration text",
    ["enableHighlight"] = "Highlight unit button",
    ["hideFull"] = "Hide while HP is full",
    ["onlyShowTopGlow"] = "Only show glow for top debuffs",

    ["BOTTOM"] = "Bottom",
    ["BOTTOMLEFT"] = "Bottom Left",
    ["BOTTOMRIGHT"] = "Bottom Right",
    ["CENTER"] = "Center",
    ["LEFT"] = "Left",
    ["RIGHT"] = "Right",
    ["TOP"] = "Top",
    ["TOPLEFT"] = "Top Left",
    ["TOPRIGHT"] = "Top Right",

    ["left-to-right"] = "Left-to-Right",
    ["right-to-left"] = "Right-to-Left",
    ["top-to-bottom"] = "Top-to-Bottom",
    ["bottom-to-top"] = "Bottom-to-Top",

    ["ABOUT"] = "Cell is a unique raid frame addon inspired by CompactRaid.\nI love CompactRaid so much, but it seems to be abandoned. And I made Cell, hope you enjoy.\nSome ideas are from other great raid frame addons, such as Aptechka, Grid2.\nCell is not meant to be a lightweight or powerful (like VuhDo, Grid2) raid frames addon. It's easy to use and good enough for you (hope so).",
    
    ["pullTimerTips"] = "\n|rPull Timer\nLeft-Click: |cffffffffstart timer|r\nRight-Click: |cffffffffcancel timer|r",
    ["marksTips"] = "\n|rTarget marker\nLeft-Click: |cffffffffset raid marker on target|r\nRight-Click: |cfffffffflock raid marker on target (in your group)|r",

    ["r26-release"] = [[
        <h1>Click-Castings</h1>
        <p>Keyboard/multi-button mouse support for Click-Castings comes.</p> 
        <p>Due to code changes, you might have to reconfigure Key Bindings.</p>
        <br/>
        <h1>Indicators</h1>
        <p>Aura List has been updated. Now all custom indicators will check spell IDs instead of NAMEs.</p>
        <p>Custom Indicators won't work until the Buff/Debuff List has been reconfigured.</p>
        <br/>
        <h1>Indicator Preview Alpha</h1>
        <p>Now you can set alpha of non-selected indicators. This might make it easier to arrange your indicators.</p>
        <p>To adjust alpha, use the alpha slider in "Indicators", it can be found at the top right corner.</p>
        <br/>
        <h1>Frame Position</h1>
        <p>Every layout has its own position setting now.</p>
        <p>The positions of Cell Main Frame, Marks, Ready &amp; Pull have been reset.</p>
        <br/>
        <h1>Misc</h1>
        <p>Party/Raid Preview Mode will help you adjust layouts.</p>
        <p>Group Anchor Point comes, go check it out in Layouts -&gt; Group Arrangement.</p>
        <br/>
    ]],

    ["r32-release"] = [[
        <h1>Indicators</h1>
        <p>New indicator: Health Text.</p>
        <p>New option: Frame Level.</p>
        <br/>
        <h1>Raid Debuffs (Beta)</h1>
        <p>Added instance debuffs for Shadowlands. For now, these debuffs are tracked by NAME. "Track By ID" option will be added later.</p>
        <p>All debuffs are enabled by default, you might want to disable some less important debuffs.</p>
        <br/>
        <h1>Misc</h1>
        <p>Fixed: Marks Bar, Click-Castings.</p>
        <p>Moved "Raid Setup" text to the tooltips of "Raid" button.</p>
        <p>Added Fade Out Menu option.</p>
        <br/>
    ]],

    ["r34-release"] = [[
        <h1>Indicators</h1>
        <p>Some built-in indicators are now configurable: Role Icon, Leader Icon, Ready Check Icon, Aggro Indicator.</p>
        <p>Added "Border" and "Only show glow for top debuffs" options for Central Debuff indicator.</p>
        <br/>
        <h1>Raid Debuffs (Beta)</h1>
        <p>All debuffs are enabled by default, you might want to disable some less important debuffs.</p>
        <p>Added "Track by ID" option.</p>
        <p>Updated glow options for Raid Debuffs.</p>
        <br/>
        <h1>General</h1>
        <p>Updated tooltips options.</p>
        <br/>
        <h1>Layouts</h1>
        <p>Added "Hide" option for "Text Width".</p>
        <br/>
    ]],
}, {
    __index = function(self, Key)
        if (Key ~= nil) then
            rawset(self, Key, Key)
            return Key
        end
    end
})