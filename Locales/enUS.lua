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
    ["togglemenu_nocombat"] = "Menu (not in combat)",
    ["T"] = "Talent",
    ["C"] = "Class",
    ["S"] = "Spec",
    ["H"] = "Hero",
    ["P"] = "PvP",
    ["notBound"] = "|cff777777".._G.NOT_BOUND,

    ["PET"] = "Pet",
    ["VEHICLE"] = "Vehicle",

    ["showGroupNumber"] = "Show group number",
    ["showTimer"] = "Show timer",
    ["showBackground"] = "Show background",
    ["dispellableByMe"] = "Only show debuffs dispellable by me",
    ["showDispelTypeIcons"] = "Show dispel type icons",
    ["castByMe"] = "Only show buffs cast by me",
    ["buffByMe"] = "Only show buffs I can apply",
    ["trackByName"] = "Track by name",
    ["showDuration"] = "Show duration text",
    ["showAnimation"] = "Show animation",
    ["showStack"] = "Show stack text",
    ["showTooltip"] = "Show aura tooltip",
    ["enableHighlight"] = "Highlight unit button",
    ["hideIfEmptyOrFull"] = "Hide if empty/full",
    ["onlyShowTopGlow"] = "Only show glow for the first debuff",
    ["circledStackNums"] = "Circled stack numbers",
    ["hideDamager"] = "Hide Damager",
    ["hideInCombat"] = "Hide in combat",
    ["stackFont"] = "Stack Font",
    ["durationFont"] = "Duration Font",
    ["fadeOut"] = "Fade out over time",
    ["shieldByMe"] = "Only show PW:S cast by me",
    ["onlyShowOvershields"] = "Only show overshields",
    ["showAllSpells"] = "Show all spells",
    ["enableBlacklistShortcut"] = "Blacklist: Alt+Ctrl+RightClick",
    ["smooth"] = "Smooth",
    ["onlyEnableNotInCombat"] = "Only when I'm not in combat",

    ["BOTTOM"] = "Bottom",
    ["BOTTOMLEFT"] = "Bottom Left",
    ["BOTTOMRIGHT"] = "Bottom Right",
    ["CENTER"] = "Center",
    ["LEFT"] = "Left",
    ["RIGHT"] = "Right",
    ["TOP"] = "Top",
    ["TOPLEFT"] = "Top Left",
    ["TOPRIGHT"] = "Top Right",

    ["left-to-right"] = "Left to Right",
    ["right-to-left"] = "Right to Left",
    ["top-to-bottom"] = "Top to Bottom",
    ["bottom-to-top"] = "Bottom to Top",

    ["ALL"] = "All",
    ["INVERT"] = "Invert",
    ["Default"] = _G.DEFAULT,

    ["ABOUT"] = "Cell is a nice raid frame addon inspired by several great addons, such as CompactRaid, Grid2, Aptechka and VuhDo.\nWith a more human-friendly interface, Cell can provide a better user experience, better than ever.\nHope you enjoy.",
    ["RESET"] = "Cell requires a full reset after updating from a very old version",
    ["RESET_CHARACTER"] = "Cell requires a character profile reset after updating from a very old version",
    ["RESET_INCLUDES"] = "Only Click-Castings and Layout Auto Switch are included",
    ["RESET_YES_NO"] = "|cff22ff22Yes|r - Reset Cell\n|cffff2222No|r - I'll fix it myself",

    ["syncTips"] = "Set the master layout here\nAll indicators of slave layout are fully in-sync with the master\nIt's a two-way sync, but all indicators of slave layout will be lost when set a master",
    ["readyCheckTips"] = "\n|rReady Check\nLeft-Click: |cffffffffinitiate a ready check|r\nRight-Click: |cffffffffstart a role check|r",
    ["pullTimerTips"] = "\n|rPull Timer\nLeft-Click: |cffffffffstart timer|r\nRight-Click: |cffffffffcancel timer|r",
    ["marksTips"] = "\n|rTarget marker\nLeft-Click: |cffffffffset raid marker on target|r\nRight-Click: |cfffffffflock raid marker on target (in your group)|r",
    ["cleuAurasTips"] = "Check CLEU events for invisible auras",
    ["raidRosterTips"] = "[Right-Click] promote/demote (assistant). [Alt+Right-Click] uninvite.",

    ["RAID_DEBUFFS_TIPS"] = "Tips: [Drag & Drop] to change debuff order. [Double-Click] on instance name to open Encounter Journal. [Shift+Left Click] on instance/boss name to share debuffs. [Alt+Left Click] on instance/boss name to reset debuffs. The priority of General Debuffs is higher than Boss Debuffs.",
    ["SNIPPETS_TIPS"] = "[Double-Click] to rename. [Shift-Click] to delete. All checked snippets will be automatically invoked at the end of Cell initialization process (in ADDON_LOADED event).",
    ["BACKUP_TIPS"] = "Backups are not always reliable, especially when they are too old. It is recommended to backup often. When sharing profiles, backups are not included.",
    ["BACKUP_TIPS2"] = "Note for Classic players: Backups do not include Click-Castings and Layout Auto Switch of other characters",

    ["CHANGELOGS"] = [[
        <h1>If there are any issues after an update, check through all code snippets first.</h1>
        <p>(Retail) Enable "Always Update Auras" in General tab, if indicators do not update correctly.</p>
        <br/>

        <h1>r243-release (Oct 13, 2024, 21:37 GMT+8)</h1>
        <p>* Fixed power filters for Wrath(CN).</p>
        <p>* Fixed indicator revision process.</p>
        <p>+ Added stack options for custom text indicators.</p>
        <p>* Updated health text format option.</p>
        <p>* Updated bleed list.</p>
        <p>* Reverted some changes.</p>
        <br/>

        <h1>r242-release (Oct 9, 2024, 10:30 GMT+8)</h1>
        <p>* Fixed for Classic.</p>
        <p>* Updated deDE, esES, zhTW.</p>
        <br/>

        <h1>r241-release (Oct 8, 2024, 18:25 GMT+8)</h1>
        <p>+ Implemented Nickname Blacklist and a hardcoded bad words list.</p>
        <p>* Fixed Cell.GetUnitFramesForLGF.</p>
        <p>* Fixed Power Text.</p>
        <p>* Changed Gradient Color related options.</p>
        <p>* Updated raid debuffs.</p>
        <p>* Updated locales. Added esES (thanks Zurent!).</p>
        <br/>

        <h1>r240-release (Sep 9, 2024, 19:00 GMT+8)</h1>
        <p>* Updated bleedList for TWW (PR #215).</p>
        <p>+ Implemented Backups.</p>
        <p>* Updated profile import.</p>
        <p>* Fixed aura import/export.</p>
        <p>* Fixed layout auto switch.</p>
        <p>* Updated locales.</p>
        <br/>

        <h1>r239-release (Aug 23, 2024, 22:00 GMT+8)</h1>
        <p>+ Snippet for enabled click cast on non-cell frames (PR #199).</p>
        <p>* Updated default indicator spells (PR #208).</p>
        <p>* Fixed an issue if CELL_BORDER_SIZE = 0.</p>
        <p>* (TWW) Fixed range check for Evokers.</p>
        <p>* Fixed blacklist shortcut for Debuffs indicator.</p>
        <p>* Fixed "Bars" indicators.</p>
        <p>* Fixed "Texture" indicators.</p>
        <p>* Fixed indicator list (especially the amount and order).</p>
        <p>* Fixed Cell.GetUnitFramesForLGF for Spotlights.</p>
        <p>* Macro click-castings are now bound by name.</p>
        <p>* Refactored Actions using ObjectPool.</p>
        <p>* Updated appearance of power filter option buttons.</p>
        <p>* (TWW) Updated debuffs for Nerub-ar Palace (Thanks Reat).</p>
        <p>* (TWW) Update dungeon debuffs.</p>
        <p>+ Added a new dispel icon style.</p>
        <p>+ Updated locales: deDE, frFR, ptBR, ruRU, zhTW.</p>
        <br/>

        <h1>r238-release (Aug 7, 2024, 15:25 GMT+8)</h1>
        <p>* Fixed missing indicators.</p>
        <p>* Updated deDE and zhTW.</p>
        <br/>

        <h1>r237-release (Aug 6, 2024, 21:30 GMT+8)</h1>
        <p>* (TWW) Updated default indicator spells (PR #165).</p>
        <p>* Updated gradient colors (PR #181).</p>
        <p>+ New snippet var CELL_RANGE_CHECK_*. Custom spells can now be used for range checking.</p>
        <p>+ New custom indicator type: Bars.</p>
        <p>+ Added "Health Bar (Loss)" option to Color indicator.</p>
        <p>+ (TWW) Added Skyfury to Buff Tracker.</p>
        <p>* Updated layer of Health Thresholds indicator.</p>
        <p>* Slightly optimized Cell.GetUnitFramesForLGF.</p>
        <p>* Fixed an indicator loading issue.</p>
        <p>* Fixed some click-casting issues.</p>
        <p>* (TWW) Fixed dispel check.</p>
        <p>* (Classic) Fixed Spell Request.</p>
        <p>* Updated deDE and zhTW.</p>
        <br/>

        <h1>r236-release (Jul 24, 2024, 16:10 GMT+8)</h1>
        <p>* Fixed appearance/layout tab.</p>
        <p>* Updated locales.</p>
        <p>* Updated world marks for cata.</p>
        <br/>

        <h1>r235-release (Jul 23, 2024, 20:00 GMT+8)</h1>
        <p>+ Added "Show Raid" option (PR #176).</p>
        <p>* Fixed full health color (PR #175).</p>
        <p>* (TWW) Fixed BR timer, QuickAssist, Spell/Dispel Request.</p>
        <p>* Fixed icon aspect ratio.</p>
        <p>* Fixed raid debuff creation on classic.</p>
        <p>* Fixed vehicle icon.</p>
        <p>* Fixed stack text.</p>
        <p>* Fixed size of indicator group.</p>
        <p>* Updated gradient color options for health bar.</p>
        <p>* Updated LibGetFrame related functions (Cell.GetUnitFrame -> Cell.GetUnitFramesForLGF).</p>
        <p>+ Added an option to adjust StatusText alignment.</p>
        <p>+ Added expansion data for ruRU.</p>
        <p>+ New custom indicator type: Border.</p>
        <br/>

        <h1>r234-release (Jul 13, 2024, 17:37 GMT+8)</h1>
        <p>+ Added "position" for Ready Check Icon indicator.</p>
        <p>* "Override LibGetFrame" is now enabled by default.</p>
        <p>* Increased the frame level of AoE Healing indicator.</p>
        <p>* Update range check.</p>
        <p>* Updated deDE, zhTW.</p>
        <br/>

        <h1>r233-release (Jul 11, 2024, 16:10 GMT+8)</h1>
        <p>+ Added a dispel highlight option "current+".</p>
        <p>* Fixed click-casting for evoker spell "Rescue".</p>
        <p>* Fixed layout preview.</p>
        <p>* Fixed creation of raid debuffs.</p>
        <p>* Fixed "Invert Color" option.</p>
        <p>* Fixed "Track by name" option.</p>
        <p>* Fixed color options for Block indicators.</p>
        <p>* Fixed a wrong PWS id.</p>
        <p>* Updated range check.</p>
        <p>* Updated frame level of Actions indicator.</p>
        <p>* Updated buff tracker for CN WotLK.</p>
        <p>* Updated locales.</p>
        <br/>

        <h1>r232-release (Jul 7, 2024, 02:40 GMT+8)</h1>
        <p>* Fixed a critical issue that removes all custom indicators.</p>
        <br/>

        <h1>r231-release (Jul 6, 2024, 21:00 GMT+8)</h1>
        <p>* Updated for TWW (#142,#144,#145).</p>
        <p>* Updated for CN WotLK.</p>
        <p>* Renamed "Consumables" to "Actions".</p>
        <p>* Updated locales. Added deDE (by CheersItsJulian), ruRU (by SkywardenSylvanas).</p>
        <p>+ Added "Filters" for Dispels indicator.</p>
        <p>+ Added "Color By Duration/Stack" for "Block" indicators.</p>
        <p>* Fixed BigDebuffs.</p>
        <p>* Fixed Click-Castings.</p>
        <br/>

        <h1>r230-beta (Jul 2, 2024, 00:27 GMT+8)</h1>
        <p>* Updated for TWW (#139,#120), not fully compatible though.</p>
        <p>* Updated bleedList (#119).</p>
        <p>+ Introduced new snippet var "CELL_COOLDOWN_STYLE", the old snippet "CooldownIcons_BlizzardStyle" is now OUTDATED.</p>
        <p>+ Custom indicators can be reordered by dragging and dropping now.</p>
        <p>+ New custom indicator type "Blocks" ("CELL_COOLDOWN_STYLE" can affect this type of indicators).</p>
        <p>+ Added "Show Duration" for Crowd Controls indicator.</p>
        <p>* Updated frame level of Dispels and "Color" indicators.</p>
        <p>* Updated range check.</p>
        <p>* Updated texture of Role Icon indicator.</p>
        <p>* Fixed "Text" alignment.</p>
        <p>* Fixed "Dispels" check for Cata.</p>
        <br/>

        <h1>r229-release (Jun 11, 2024, 20:11 GMT+8)</h1>
        <p>* Bug fixes.</p>
        <p>* Updated zhTW.</p>
        <p>+ Added ptBR (by cathtail).</p>
        <br/>

        <h1>r228-release (Jun 10, 2024, 23:38 GMT+8)</h1>
        <h2>Click-Castings</h2>
        <p>* Fixed Click-Castings issues, some settings may be "Invalid", just re-set them.</p>
        <h2>Indicators</h2>
        <p>* Updated indicator preview, added "Show All", removed "Alpha" (#125).</p>
        <p>* Updated BleedList (#119).</p>
        <p>+ Added "Spacing" for Icons indicators.</p>
        <p>+ New custom indicator: (color) Block.</p>
        <p>+ Added duration text for Rect/Bar.</p>
        <p>* Updated Targeted Spells, now it supports up to 3 icons and is more stable.</p>
        <p>* Increased frame level of Dispel Highlight.</p>
        <p>* Fixed dispel checker on Cata.</p>
        <h2>Raid Debuffs</h2>
        <p>+ Added "Use Elapsed Time" option for Raid Debuffs.</p>
        <p>* Updated Cata Raid Debuffs.</p>
        <h2>Layouts</h2>
        <p>+ Added "Solo" for Layout Auto Switch.</p>
        <p>* Updated "Sort by Role", now it supports separated group headers.</p>
        <p>* Fixed frame level of Spotlight menu.</p>
        <h2>Misc</h2>
        <p>* Improved usability of Custom Nicknames.</p>
        <br/>

        <h1>r227-release (May 21, 2024, 01:08 GMT+8)</h1>
        <p>* Fixed Quick Assist.</p>
        <p>* Fixed a layout switch issue.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r226-release (May 20, 2024, 02:33 GMT+8)</h1>
        <p>* Added a separated "Shadow" option for fonts (#110).</p>
        <p>* Fixed Shield Bar alpha in preview (#111).</p>
        <p>+ Implemented "Reverse Fill" for overshields.</p>
        <p>+ Added "Frame Level" option for Role Icon indicator.</p>
        <p>+ Added "Show Duration" for Raid Debuffs indicator.</p>
        <p>* Updated color options for custom Text/Rect/Bar/Color/Overlay indicators (added ALPHAs).</p>
        <br/>

        <h1>r225-release (May 13, 2024, 03:50 GMT+8)</h1>
        <p>* Bug fixes.</p>
        <br/>

        <h1>r224-release (May 13, 2024, 01:00 GMT+8)</h1>
        <p>+ New indicator: Power Text.</p>
        <p>* The custom Icons indicators now have an ordered spell list.</p>
        <p>+ Added "Class Color" for custom Color indicators and Health Text indicator.</p>
        <p>+ Added "Frame Level" for custom Color/Overlay indicators.</p>
        <p>+ Added "Invert Color" for Heal Absorb.</p>
        <p>+ Added a "30%" for some duration related options.</p>
        <p>* Fixed anchor of NPC frame while using combined groups.</p>
        <p>* Fixed Power Filters when solo.</p>
        <p>* Fixed Layout Auto Switch for Cata.</p>
        <p>* Fixed issues with AI followers.</p>
        <p>* Moved "Use LibHealComm" to Code Snippets.</p>
        <br/>

        <h1>r223-release (May 6, 2024, 00:05 GMT+8)</h1>
        <p>* Updated Cata debuffs.</p>
        <br/>

        <h1>r222-release (May 4, 2024, 00:40 GMT+8)</h1>
        <p>+ Updated for Cata.</p>
        <p>+ Implemented "Combine Groups" (support sorting by role), check it out on Layouts tab.</p>
        <p>+ New custom indicator type: Overlay (bar).</p>
        <p>+ Added Clear/Import/Export for indicator aura list.</p>
        <p>* Expanded Spotlight Frame to 15 buttons.</p>
        <p>* Fixed colors of AI followers.</p>
        <p>* Fixed colors for custom Text/Rect/Bar indicators.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r221-release (Apr 6, 2024, 22:00 GMT+8)</h1>
        <p>+ Added multi-line support for custom "Icons" indicators.</p>
        <p>* Updated color options for custom "Bar" indicators.</p>
        <p>+ Added Right-Click refreshing feature for Main/QuickAssist option button.</p>
        <p>* Improved reliability of LibGroupInfo (QuickAssist filters may work better).</p>
        <p>* Fixed QuickAssist cooldown icons.</p>
        <br/>

        <h1>r220-release (Jan 25, 2024, 19:06 GMT+8)</h1>
        <p>* Fixed Spotlight config button.</p>
        <p>* Updated range checker.</p>
        <p>* Updated Cell.GetUnitFrame.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r219-release (Jan 24, 2024, 10:56 GMT+8)</h1>
        <p>* Fixed range check for Quick Assist (now uses OnUpdate).</p>
        <p>+ Added custom Gradient Colors (Appearance).</p>
        <br/>

        <h1>r218-release (Jan 20, 2024, 18:49 GMT+8)</h1>
        <p>* (Wrath/Vanilla) Fixed a layout issue.</p>
        <br/>

        <h1>r217-release (Jan 18, 2024, 17:01 GMT+8)</h1>
        <p>* Fixed duration text visibility.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r216-release (Jan 18, 2024, 12:31 GMT+8)</h1>
        <p>* Fixed an icon preview issue in Appearance.</p>
        <p>* Fixed icon animation of Quick Assist.</p>
        <br/>

        <h1>r215-release (Jan 18, 2024, 11:31 GMT+8)</h1>
        <p>+ Implemented blacklist shortcut for Debuffs: Alt + Ctrl + LeftClick (disabled by default).</p>
        <p>+ Added "Show animation" option for some indicators.</p>
        <p>+ (Retail) Added "Color" option for Tank Active Mitigation.</p>
        <p>* Updated party role order option (PR #102, thanks abazilla).</p>
        <p>* (Retail) Set the default value of "Always Update Debuffs" to true.</p>
        <p>* Fixed a Spec Filter issue for Quick Assist.</p>
        <p>* Fixed layout preview mover.</p>
        <br/>

        <h1>r214-release (Dec 30, 2023, 20:35 GMT+8)</h1>
        <p>* Fixed Spell Request, updated CELL_NOTIFY payloads.</p>
        <p>* Updated the priority of dispel types: Magic &gt; Curse &gt; Disease &gt; Poison &gt; Bleed.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r213-release (Dec 26, 2023, 04:04 GMT+8)</h1>
        <p>+ (Retail) Updated Quick Assist, new Spec Filter and Filter Auto Switch.</p>
        <p>* (Retail) Updated Smart Resurrection, added support for mass resurrections.</p>
        <p>* Increased maximum size for indicators.</p>
        <p>* Fixed a power bar issue.</p>
        <p>* Fixed utilities submenu.</p>
        <p>* Fixed duration text color.</p>
        <br/>

        <h1>r212-release (Dec 18, 2023, 19:54 GMT+8)</h1>
        <p>* Fixed a issue that newly created indicators did not show up when solo or in a party.</p>
        <p>* Updated overshield texture. Now it uses the color of shield texture.</p>
        <br/>

        <h1>r211-release (Dec 16, 2023, 17:57 GMT+8)</h1>
        <p>* Updated dispel checker, removed snippet var: CELL_DISPEL_EVOKER_CAUTERIZING_FLAME.</p>
        <p>* When enter/leave instance, all visible unit buttons will be refreshed.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r210-release (Dec 15, 2023, 23:55 GMT+8)</h1>
        <p>+ Implemented Bleed debuff type (using data from https://wago.tools/db2/SpellEffect, EffectMechanic=15).</p>
        <p>* Fixed Quick Assist config/preview.</p>
        <p>* (Wrath) Fixed PW:S indicator.</p>
        <br/>

        <h1>r209-release (Dec 14, 2023, 11:20 GMT+8)</h1>
        <p>* Fixed issues with newly created custom Color indicators.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r208-release (Dec 14, 2023, 00:43 GMT+8)</h1>
        <p>* The order of click-casting items can now be adjusted by dragging them.</p>
        <p>* Fixed click-castings for Quick Assist.</p>
        <br/>

        <h1>r207-release (Dec 13, 2023, 17:02 GMT+8)</h1>
        <p>* (Retail) Updated Quick Assist, removed stand-alone click-castings, added bars/glows and filter switcher.</p>
        <p>+ Updated Spotlights, added "Tank" and "Unit's Name".</p>
        <p>+ Updated support for 1.15 Classic.</p>
        <p>+ Added "Change Over Time" option for custom Color indicators.</p>
        <p>+ Added role icon for vehicles.</p>
        <p>* Fixed LibHealComm support.</p>
        <p>* Updated locales.</p>
        <br/>

        <h1>r206-release (Dec 9, 2023, 00:50 GMT+8)</h1>
        <p>+ (Retail) New utility: Quick Assist. Thanks 钛锬(NGA) for offensive spells and testing.</p>
        <p>* Updated raid debuffs.</p>
        <p>* Updated Cell.GetUnitFrame.</p>
        <p>* (Retail) Updated dispel checker for Shaman.</p>
        <p>+ Added "Show Background" and "Show Timer" for Status Text indicator.</p>
        <p>* Updated locales.</p>
        <p>* Bug fixes.</p>
        <br/>

        <h1>r205-release (Nov 27, 2023, 12:27 GMT+8)</h1>
        <p>* Updated raid debuffs, thanks to 钛锬(NGA) and Ulu2005(GitHub) for collecting and providing debuffs.</p>
        <p>+ New custom indicator type: Glow.</p>
        <p>+ (Retail) Added "Track by name" option for custom buff indicator.</p>
        <p>+ Added "Hide Placeholder Frames" for Spotlights.</p>
        <p>+ Added option to override LibGetFrame.</p>
        <p>* Spotlight shortcuts now supports Blizzard and ElvUI.</p>
        <p>* Updated frame level: Aggro (border), Dispels and custom Color indicator.</p>
        <br/>

        <h1>r204-release (Nov 21, 2023, 07:02 GMT+8)</h1>
        <p>* Updated range checker (Retail).</p>
        <p>+ Added "Always Update Buffs/Debuffs" options (Retail).</p>
        <br/>

        <h1>r203-release (Nov 14, 2023, 21:15 GMT+8)</h1>
        <p>* Fixed Target Counter.</p>
        <p>* Fixed a health bar issue occured when value is 0.</p>
        <br/>

        <h1>r202-release (Nov 14, 2023, 07:16 GMT+8)</h1>
        <p>+ Added support for Ping System (Retail).</p>
        <p>* Expanded Spotlight Frame to 10 buttons.</p>
        <p>+ Added "Show stack text" option for custom icon(s) indicators.</p>
        <p>* Updated OmniCD support (requires the upcoming OmniCD update): Spotlights and QuickCasts.</p>
        <p>* Bug fixes.</p>
        <br/>

        <h1>r201-release (Nov 9, 2023, 05:04 GMT+8)</h1>
        <p>* Updated Amirdrassil debuffs.</p>
        <p>* Updated Health Text indicator.</p>
        <br/>

        <h1>r200-release (Nov 4, 2023, 08:04 GMT+8)</h1>
        <p>* Updated Raid Tools.</p>
        <p>* Updated Defensive CDs indicator.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <p><a href="older">Click to view older changelogs</a></p>
        <br/>
    ]],

    ["OLDER_CHANGELOGS"] = [[
        <h1>r199-release (Oct 21, 2023, 15:40 GMT+8)</h1>
        <p>* Updated spells of Defensives and Externals.</p>
        <p>+ Added "Cast By" option to custom buff indicators.</p>
        <p>* Fixed raid tools.</p>
        <p>+ Code Snippets var: CELL_SHOW_RAID_PET_OWNER_NAME.</p>
        <br/>

        <h1>r198-release (Oct 7, 2023, 06:54 GMT+8)</h1>
        <p>* Updated indicators: Target Counter, Shield Bar.</p>
        <br/>

        <h1>r197-release (Sep 20, 2023, 08:08 GMT+8)</h1>
        <p>* Added a "Show Solo" option for Marks Bar.</p>
        <p>* Added Ice Cold to Defensive CDs indicator.</p>
        <p>* Updated ICC debuffs, thanks to 大胖宝.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r196-release (Sep 16, 2023, 09:32 GMT+8)</h1>
        <p>* Updated Quick Cast and Spell Request.</p>
        <p>* Fix Status Text indicator.</p>
        <p>+ Code Snippets vars: CELL_BORDER_SIZE, CELL_BORDER_COLOR.</p>
        <br/>

        <h1>r195-release (Sep 12, 2023, 06:52 GMT+8)</h1>
        <p>* Updated Missing Buffs indicator.</p>
        <br/>

        <h1>r194-release (Sep 3, 2023, 20:41 GMT+8)</h1>
        <p>* Updated expansion data, which is used to match Raid Debuffs based on the instance you are in on Wrath. Currently, deDE, frFR, koKR, zhCN and zhTW are supported.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r193-release (Sep 1, 2023, 05:57 GMT+8)</h1>
        <p>* Fixed layout switch.</p>
        <p>* Fixed Defensive Cooldowns indicator (Mirror Image).</p>
        <p>* Fixed issues with CVar "ActionButtonUseKeyDown" on Wrath.</p>
        <p>* Updated locales.</p>
        <br/>

        <h1>r192-release (Aug 25, 2023, 20:41 GMT+8)</h1>
        <p>* Added indicator validator to ensure all indicators are in the right order.</p>
        <p>* Fixed expansion data for frFR.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r191-release (Aug 22, 2023, 09:50 GMT+8)</h1>
        <p>* Updated expansion data for frFR (Thanks to Zuvila).</p>
        <p>* Updated Targeted Spells, Quick Cast.</p>
        <br/>

        <h1>r190-beta (Aug 18, 2023, 21:30 GMT+8)</h1>
        <p>+ New indicator: Crowd Controls (Retail).</p>
        <p>* Updated Layout Auto Switch, now support spec profile (Retail).</p>
        <p>* Optimized UNIT_AURA related functions.</p>
        <p>* Fixed indicators issues with Spotlight frames.</p>
        <p>* Updated Quick Cast, Spell Request.</p>
        <p>* Updated raid setup tooltip.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r189-release (Aug 9, 2023, 08:27 GMT+8)</h1>
        <p>* Fixed custom indicators: Color and Texture.</p>
        <br/>

        <h1>r188-release (Aug 7, 2023, 19:42 GMT+8)</h1>
        <p>* Fixed raid setup tooltip on Wrath.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r187-release (Aug 5, 2023, 06:25 GMT+8)</h1>
        <p>+ New utility: Quick Cast (Retail only).</p>
        <p>+ Added Proc Glow.</p>
        <p>+ Added "Premade Mode" to raid roster utility.</p>
        <p>* Fixed Dispel Request on Wrath.</p>
        <br/>

        <h1>r186-release (Jul 24, 2023, 21:06 GMT+8)</h1>
        <p>* Fixed import &amp; export.</p>
        <p>* Updated Dispel/Spell Request.</p>
        <p>* Updated Health Text indicator.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r185-release (Jul 21, 2023, 20:57 GMT+8)</h1>
        <p>* Updated Options UI (wip).</p>
        <p>+ Added "Only show overshields" to Shield Bar indicator.</p>
        <p>+ Added "Focus Target" to spotlight frame.</p>
        <p>* Fixed Raid Debuffs tab on Wrath.</p>
        <br/>

        <h1>r184-release (Jul 19, 2023, 23:12 GMT+8)</h1>
        <p>* Fixed range checker for Evokers.</p>
        <p>* Fixed several layout issues.</p>
        <p>+ Added "Boss1 Target" to spotlight frame.</p>
        <br/>

        <h1>r183-release (Jul 18, 2023, 15:09 GMT+8)</h1>
        <p>* Fixed layout: sort by role, hide self.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r182-release (Jul 18, 2023, 05:07 GMT+8)</h1>
        <p>* Refactored Layouts.</p>
        <p>* Updated debuffs for Dawn of the Infinite, thanks to 钛锬(NGA).</p>
        <p>+ Implemented import &amp; export for Click-Castings.</p>
        <br/>

        <h1>r181-release (Jul 15, 2023, 03:12 GMT+8)</h1>
        <p>+ Added a "Shape" option for PW:S indicator.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r180-release (Jul 14, 2023, 05:48 GMT+8)</h1>
        <p>+ Added "Highlight Filter (blacklist)" for Dispel indicator.</p>
        <p>* Fixed dispel checker for Evokers.</p>
        <p>* Fixed Ready Check Icon indicator.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r179-release (Jul 13, 2023, 12:38 GMT+8)</h1>
        <p>* Updated PW:S indicator.</p>
        <p>+ Added a "Translit Cyrillic to Latin" option in General tab.</p>
        <br/>

        <h1>r178-release (Jul 13, 2023, 02:08 GMT+8)</h1>
        <p>+ New indicator: "PW:S" (Wrath).</p>
        <p>* Bumped up toc.</p>
        <br/>

        <h1>r177-release (Jul 10, 2023, 16:41 GMT+8)</h1>
        <p>+ Updated for Augmentation Evokers.</p>
        <p>+ Added a "Fade out over time" option for custom texture indicators.</p>
        <p>+ Added "Unit's Target" to spotlight frame.</p>
        <p>- Removed "CLEU auras" from Raid Debuffs indicator.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r176-release (Jul 6, 2023, 14:34 GMT+8)</h1>
        <p>+ Added full health color options in Appearance.</p>
        <p>* Updated zhTW.</p>
        <p>* Updated Cell discord link.</p>
        <br/>

        <h1>r175-release (Jun 20, 2023, 11:22 GMT+8)</h1>
        <p>* Fixed Power Bar Filters.</p>
        <p>* Fixed animation Type A of Consumables indicator (Wrath).</p>
        <br/>

        <h1>r174-release (Jun 18, 2023, 17:25 GMT+8)</h1>
        <p>* Updated font options for some indicators. The stack font and duration font can be set separately. And if you use CooldownIcons_BlizzardStyle snippet, an update is required.</p>
        <p>* Health Text indicator: added options to show shield value.</p>
        <p>* Dispels indicator: updated Highlight Type option.</p>
        <p>* Fixed Private Auras indicator.</p>
        <p>* Updated raid debuffs.</p>
        <br/>

        <h1>r173-release (Jun 2, 2023, 18:36 GMT+8)</h1>
        <p>* Added a "Hide in combat" option for Leader Icon indicator.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r172-release (May 31, 2023, 16:46 GMT+8)</h1>
        <p>* Fixed Click-Castings. If your bindings (especially the General type) don't work, remove them and then re-add them.</p>
        <br/>

        <h1>r171-release (May 26, 2023, 19:27 GMT+8)</h1>
        <p>* Removed Cauterizing Flame (Evoker) from dispel checker. You can add it back by setting CELL_DISPEL_EVOKER_CAUTERIZING_FLAME to true in Code Snippets.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r170-release (May 26, 2023, 00:21 GMT+8)</h1>
        <p>* Updated raid debuffs: Aberrus and M+. (Thanks to 钛锬)</p>
        <p>* Updated raid debuffs: ToC. (Thanks to 橘子味橙汁)</p>
        <p>* Added support for NickTag. To display nicknames from Details!, set CELL_NICKTAG_ENABLED to true in Code Snippets.</p>
        <p>* Updated Missing Buffs indicator and brought it to Wrath.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r169-release (May 20, 2023, 04:18 GMT+8)</h1>
        <h2>Retail</h2>
        <p>+ New indicator: Private Auras.</p>
        <p>* Updated dispel checker.</p>
        <br/>

        <h1>r168-release (May 13, 2023, 19:23 GMT+8)</h1>
        <p>! Click-castings are now saved as spell id instead of name. This can make click-casting profiles work on clients in various languages (reconfiguration of click-casting spells is required).</p>
        <p>* Update Aberrus debuffs.</p>
        <p>* Fixed "Hide Damager" for Role Icon indicator on wrath.</p>
        <br/>

        <h1>r167-release (May 10, 2023, 00:59 GMT+8)</h1>
        <p>* Fixed strata of Spotlight Frame.</p>
        <br/>

        <h1>r166-release (May 5, 2023, 16:48 GMT+8)</h1>
        <p>* Fixed import on wrath.</p>
        <p>* Bumped retail toc to 100100.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r165-release (May 1, 2023, 19:37 GMT+8)</h1>
        <p>+ Added an option to make raid tools show on mouseover.</p>
        <p>* Tried to fix raid pet frame issue during some encounters.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r164-release (Apr 24, 2023, 05:55 GMT+8)</h1>
        <p>+ Added a "Smart Resurrection" option in Click-Castings.</p>
        <p>* Fixed menu strata.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r163-release (Apr 22, 2023, 20:07 GMT+8)</h1>
        <p>+ Updated Cell frame strata, added a "Strata" option in Appearance.</p>
        <p>* Fixed a null indicatorName issue.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r162-release (Apr 14, 2023, 19:00 GMT+8)</h1>
        <p>* Moved "Sort By Role" to Layouts.</p>
        <p>* Added "Hide Self" in Layouts.</p>
        <p>* Fixed "Track by name" for custom indicators (wrath).</p>
        <br/>

        <h1>r161-release (Apr 8, 2023, 20:00 GMT+8)</h1>
        <p>* Fixed dispellable debuff type checker (retail).</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r160-release (Apr 6, 2023, 21:00 GMT+8)</h1>
        <p>* Moved "Debuff Type Color" options to Appearance.</p>
        <p>* Fixed a "font is nil" issue.</p>
        <p>* Bumped retail toc to 100007.</p>
        <br/>

        <h1>r159-release (Mar 28, 2023, 22:59 GMT+8)</h1>
        <p>+ Added Self Cast Key checker for Wrath.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r158-release (Mar 17, 2023, 20:17 GMT+8)</h1>
        <p>+ New indicator: Missing Buffs (Retail only).</p>
        <p>+ Added custom dispel type color options for Dispels indicator.</p>
        <p>* Update raid debuffs checker.</p>
        <p>* Update initialConfigFunction of each group header.</p>
        <br/>

        <h1>r157-release (Mar 7, 2023, 18:31 GMT+8)</h1>
        <p>* Bug fixes.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r156-release (Feb 10, 2023, 10:52 GMT+8)</h1>
        <p>+ Add toggles for built-in spells (Defensives and Externals).</p>
        <p>* Fix raid type checker on Wrath.</p>
        <br/>

        <h1>r155-release (Jan 28, 2023, 10:30 GMT+8)</h1>
        <p>* Fixed click-castings on Wrath.</p>
        <p>* Fixed aura refreshing animation on Wrath.</p>
        <br/>

        <h1>r154-release (Jan 19, 2023, 12:34 GMT+8)</h1>
        <p>* Bug fixes.</p>
        <p>* Update for 3.4.1.</p>
        <br/>

        <h1>r153-release (Jan 6, 2023, 02:37 GMT+8)</h1>
        <p>* Tried to fix: fonts and Aggro (Border) indicator.</p>
        <p>* Updated Targeted Spells list.</p>
        <p>* Updated raid debuffs: Ulduar.</p>
        <br/>

        <h1>r152-release (Dec 29, 2022, 19:40 GMT+8)</h1>
        <p>* Updated raid debuffs.</p>
        <p>* Updated duration text options (related code snippets needs to be updated).</p>
        <p>* Fixed buff tracker.</p>
        <br/>

        <h1>r151-release (Dec 17, 2022, 10:18 GMT+8)</h1>
        <p>* Updated VotI debuffs.</p>
        <p>* Fixed range checker for evoker.</p>
        <p>* Fixed dispellable checker.</p>
        <p>* Updated locales.</p>
        <br/>

        <h1>r150-release (Dec 12, 2022, 07:55 GMT+8)</h1>
        <p>* Updated Dragonflight debuffs.</p>
        <p>* Updated BAR indicators.</p>
        <p>* Updated Dispel indicator.</p>
        <p>* Updated range checker, removed LibRangeCheck.</p>
        <p>* Removed LibHealComm (if you would like to use it, install the standalone library instead).</p>
        <p>* Bug fixes.</p>
        <br/>

        <h1>r149-release (Nov 29, 2022, 06:35 GMT+8)</h1>
        <p>* Added NPC button size options.</p>
        <p>* Added a bar orientation option "Vertical B".</p>
        <br/>

        <h1>r148-release (Nov 27, 2022, 22:07 GMT+8)</h1>
        <p>* Fixed layout auto switch on Wrath.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r147-release (Nov 27, 2022, 18:02 GMT+8)</h1>
        <p>* Updated layout auto switch, added a "Raid Outdoor" type.</p>
        <p>* Added color options: Heal Prediction, Heal Absorb and Shield Texture.</p>
        <p>* Updated Status Icon indicator (resurrections related).</p>
        <p>* Updated Targeted Spells indicator.</p>
        <p>* Updated custom indicators (Bar/Rect), added stack text.</p>
        <p>* Fixed range checker.</p>
        <p>* Other bug fixes.</p>
        <br/>

        <h1>r146-release (Nov 25, 2022, 05:15 GMT+8)</h1>
        <p>* Updated click-castings.</p>
        <p>* Bug fixes.</p>
        <br/>

        <h1>r145-release (Nov 24, 2022, 00:15 GMT+8)</h1>
        <p>* Bug fixes.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r144-release (Nov 20, 2022, 05:02 GMT+8)</h1>
        <p>+ Added several shortcuts to spotlight frame.</p>
        <p>* Bug fixes.</p>
        <br/>

        <h1>r143-release (Nov 19, 2022, 15:02 GMT+8)</h1>
        <p>* Updated range check for evoker (30y).</p>
        <p>* Fixed appearance reset.</p>
        <br/>

        <h1>r142-release (Nov 18, 2022, 03:16 GMT+8)</h1>
        <p>* Options frame is now accessible while in combat.</p>
        <p>* Updated koKR.</p>
        <br/>

        <h1>r141-release (Nov 16, 2022, 06:17 GMT+8)</h1>
        <p>* Fixed tooltips (Wrath Classic).</p>
        <br/>

        <h1>r140-release (Nov 16, 2022, 05:40 GMT+8)</h1>
        <p>* Updated tooltips related functions.</p>
        <p>* Updated zhTW and koKR.</p>
        <br/>

        <h1>r139-release (Nov 13, 2022, 23:10 GMT+8)</h1>
        <p>* Updated evoker spells.</p>
        <p>* Updated slash commands.</p>
        <p>* Updated spotlight.</p>
        <p>* Updated zhTW and koKR.</p>
        <p>* Fixed aura tooltips.</p>
        <br/>

        <h1>r138-release (Nov 12, 2022, 04:56 GMT+8)</h1>
        <p>* Updated import &amp; export.</p>
        <p>* Split "Unit Spacing" into "Unit Spacing X" and "Unit Spacing Y".</p>
        <p>* Bug fixes.</p>
        <br/>

        <h1>r137-release (Nov 4, 2022, 18:07 GMT+8)</h1>
        <p>* Added movers for NPCs and raid pets.</p>
        <p>* Updated zhTW.</p>
        <p>* Bug fixes.</p>
        <br/>

        <h1>r136-release (Nov 2, 2022, 17:59 GMT+8)</h1>
        <p>+ Added an option to increase health update rate (but not recommended).</p>
        <p>* Bug fixes.</p>
        <br/>

        <h1>r135-release (Nov 1, 2022, 06:27 GMT+8)</h1>
        <p>* Fixed arena pets.</p>
        <p>* Updated shields on Wrath Classic.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r134-release (Oct 30, 2022, 19:20 GMT+8)</h1>
        <p>+ Implemented raid pets (limited to 20 buttons).</p>
        <p>* Added a "Hide Damager" option to Role Icon indicator.</p>
        <p>* Bug fixes.</p>
        <br/>

        <h1>r133-release (Oct 28, 2022, 05:15 GMT+8)</h1>
        <p>* Bug fixes.</p>
        <br/>

        <h1>r132-release (Oct 27, 2022, 19:07 GMT+8)</h1>
        <p>+ New indicator: Health Thresholds.</p>
        <p>* Updated spells for DF.</p>
        <p>* Bug fixes.</p>
        <br/>

        <h1>r131-beta (Oct 26, 2022, 18:37 GMT+8)</h1>
        <p>* Temporary fix for Dragonflight.</p>
        <br/>

        <h1>r130-release (Oct 24, 2022, 22:00 GMT+8)</h1>
        <p>* Bug fixes.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r129-release (Oct 22, 2022, 19:37 GMT+8)</h1>
        <p>* Added an option to disable LibHealComm.</p>
        <p>* Split "Hide Blizzard Raid / Party" into two options.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r128-release (Oct 21, 2022, 18:57 GMT+8)</h1>
        <p>* Updated alignment of indicators with multiple icons. Horizontal/Vertical centering is supported.</p>
        <p>* Added alpha to each status of StatusText.</p>
        <p>+ Added spotlight button size. You can find this in Layouts -> Unit Button Size (3rd page).</p>
        <p>* Updated raid debuffs.</p>
        <p>* Updated defensives and externals.</p>
        <br/>

        <h1>r127-release (Oct 19, 2022, 02:45 GMT+8)</h1>
        <p>* Fixed heal prediction in WotLK.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r126-release (Oct 17, 2022, 16:35 GMT+8)</h1>
        <p>* Fixed icon duration text.</p>
        <p>* Added "Show group number" to Name Text indicator.</p>
        <p>* Made spotlight menu always on-screen.</p>
        <p>* Updated default spell list of Defensives and Externals.</p>
        <p>* Updated raid roster frame, right-click on a member to set assistant.</p>
        <p>* Updated Ready button, right-click on it to start a role check.</p>
        <br/>

        <h1>r125-release (Oct 15, 2022, 16:30 GMT+8)</h1>
        <p>* Updated locales.</p>
        <br/>

        <h1>r124-release (Oct 15, 2022, 15:27 GMT+8)</h1>
        <p>* Fixed menu (Options button) visibility.</p>
        <p>* Updated menu fade in/out.</p>
        <br/>

        <h1>r123-release (Oct 15, 2022, 03:22 GMT+8)</h1>
        <p>* Update default click-castings spells list.</p>
        <p>* Update zhTW.</p>
        <br/>

        <h1>r122-release (Oct 14, 2022, 04:25 GMT+8)</h1>
        <p>* Fixed Click-Castings.</p>
        <br/>

        <h1>r121-release (Oct 13, 2022, 14:40 GMT+8)</h1>
        <p>* Bug fixes.</p>
        <br/>

        <h1>r120-release (Oct 12, 2022, 20:45 GMT+8)</h1>
        <p>* Fixed Click-Castings.</p>
        <p>* Updated locales.</p>
        <br/>

        <h1>r119-release (Oct 12, 2022, 18:10 GMT+8)</h1>
        <p>+ Spotlight Frame (new): Shows up to 5 units you care about more. Each button can be set to target, target of target, focus, a group member or pet.</p>
        <p>* Update Click-Castings.</p>
        <p>* Update menu fade-in and fade-out.</p>
        <p>* Update zhTW.</p>
        <br/>

        <h1>r118-release (Oct 9, 2022, 23:30 GMT+8)</h1>
        <p>* Updated Buff Tracker.</p>
        <p>* Fixed vehicle targeting in WotLK.</p>
        <br/>

        <h1>r117-release (Oct 7, 2022, 10:37 GMT+8)</h1>
        <h2>Wrath Classic</h2>
        <p>* Updated shields: Shield Bar indicator, Shield / Overshield textures. (PWS with Glyph of PWS and Divine Aegis (from yourself) are supported.)</p>
        <br/>

        <h1>r116-release (Oct 5, 2022, 00:27 GMT+8)</h1>
        <p>* Updated heal prediction in Wrath Classic (using LibHealComm-4.0).</p>
        <p>* Updated locales.</p>
        <br/>

        <h1>r115-release (Oct 2, 2022, 07:35 GMT+8)</h1>
        <p>* Updated indicators: Dispels and Consumables.</p>
        <p>* Updated zhTW.</p>
        <p>* Fixed Consumables indicator in WotLK.</p>
        <br/>

        <h1>r114-release (Oct 1, 2022, 04:00 GMT+8)</h1>
        <p>+ New indicator: Consumables.</p>
        <p>* Updated indicators: AoEHealing, TargetedSpells and Debuffs.</p>
        <p>* Updated zhTW.</p>
        <h2>Retail</h2>
        <p>* Fixed CLEU auras and Mirror Image.</p>
        <h2>Wrath Classic</h2>
        <p>* Updated raid debuffs.</p>
        <br/>

        <h1>r113-release (Sep 22, 2022, 16:30 GMT+8)</h1>
        <p>* Fixed custom defensives and externals.</p>
        <h2>Retail</h2>
        <p>+ Implemented CLEU auras (check Raid Debuffs indicator).</p>
        <h2>Wrath Classic</h2>
        <p>* Updated debuffs.</p>
        <p>* Fixed health bar color.</p>
        <br/>

        <h1>r112-release (Sep 11, 2022, 19:00 GMT+8)</h1>
        <p>* Add custom auras support to Defensives and Externals.</p>
        <p>* Add Mirror Image to Defensives.</p>
        <p>* Add Cell default texture to LibSharedMedia.</p>
        <h2>Wrath Classic</h2>
        <p>* Updated raid debuffs.</p>
        <p>* Fixed power filter.</p>
        <br/>

        <h1>r111-release (Sep 3, 2022, 12:07 GMT+8)</h1>
        <p>* Fixed game version check.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r110-release (Sep 1, 2022, 19:50 GMT+8)</h1>
        <p>* Fixed pull button.</p>
        <p>* Fixed tooltips for checkbuttons.</p>
        <p>* Updated locales.</p>
        <br/>

        <h1>r109-release (Aug 27, 2022, 03:10 GMT+8)</h1>
        <h2>Retail</h2>
        <p>* The "Weakened Soul" debuff from other players will not be visible anymore.</p>
        <p>* Updated M+ debuffs.</p>
        <h2>Wrath Classic</h2>
        <p>* Cell should work on Wrath Classic now (not all Retail features are available).</p>
        <br/>

        <h1>r108-release (Aug 17, 2022, 18:20 GMT+8)</h1>
        <p>* Updated M+ debuffs.</p>
        <p>* Fixed several bugs.</p>
        <br/>

        <h1>r107-release (Aug 6, 2022, 19:50 GMT+8)</h1>
        <p>* Updated M+ season 4 related debuffs.</p>
        <p>* Added a "Current Season" item to expansion dropdown in Raid Debuffs.</p>
        <br/>

        <h1>r106-beta (Aug 3, 2022, 00:45 GMT+8)</h1>
        <p>* Bug fixes.</p>
        <br/>

        <h1>r105-beta (Aug 1, 2022, 23:00 GMT+8)</h1>
        <p>* Removed LibGroupInSpecT.</p>
        <br/>

        <h1>r104-release (Jun 3, 2022, 20:30 GMT+8)</h1>
        <p>* Bump up toc.</p>
        <br/>

        <h1>r103-release (May 11, 2022, 08:10 GMT+8)</h1>
        <p>+ Implemented accent color for options UI.</p>
        <br/>

        <h1>r102-beta (May 8, 2022, 21:45 GMT+8)</h1>
        <p>* Updated raid debuffs.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r101-beta (May 8, 2022, 06:10 GMT+8)</h1>
        <p>* Updated settings export.</p>
        <p>* Updated raid debuffs.</p>
        <p>* Fixed name text length.</p>
        <br/>

        <h1>r100-release (May 7, 2022, 01:07 GMT+8)</h1>
        <p>* Fixed several bugs.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r99-release (May 5, 2022, 14:10 GMT+8)</h1>
        <p>* Rewrote nicknames.</p>
        <p>* Added frame level to Name Text indicator.</p>
        <p>* Updated Status Icon indicator.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r98-release (Apr 24, 2022, 16:10 GMT+8)</h1>
        <p>+ Implemented indicator sync.</p>
        <p>+ Implemented custom death color.</p>
        <p>* Updated Role Icon indicator.</p>
        <p>* Lowered the frame level of Aggro (border) indicator.</p>
        <p>* Updated indicator preview.</p>
        <p>* Updated zhTW.</p>
        <p>* Bug fixes.</p>
        <br/>

        <h1>r97-release (Apr 19, 2022, 20:10 GMT+8)</h1>
        <p>+ Added nicknames (beta).</p>
        <p>* Updated locales.</p>
        <p>* Bug fixes.</p>
        <br/>

        <h1>r96-release (Apr 19, 2022, 11:55 GMT+8)</h1>
        <p>* Bug fixes.</p>
        <p>* Updated locales.</p>
        <br/>

        <h1>r95-release (Apr 18, 2022, 09:17 GMT+8)</h1>
        <p>+ Added a "Round Up Duration" option into Aura Icon Options.</p>
        <p>* Updated duration text options for custom TEXT indicators.</p>
        <p>* Updated zhTW.</p>
        <p>* Bug fixes.</p>
        <br/>

        <h1>r94-release (Apr 17, 2022, 08:10 GMT+8)</h1>
        <p>+ Added Aura Icon Options in Appearance tab.</p>
        <p>+ Added Show aura tooltip options: Debuffs and RaidDebuffs.</p>
        <p>* Added yOffset for indicator font options: icon and icons.</p>
        <p>* Updated zhTW.</p>
        <p>* Fixed some bugs.</p>
        <br/>

        <h1>r93-release (Apr 16, 2022, 06:45 GMT+8)</h1>
        <p>+ Added an indicator: Externals + Defensives.</p>
        <p>+ Added a new custom indicator type: texture.</p>
        <p>+ Implemented import &amp; export for all settings (check About tab).</p>
        <p>+ Implemented layout auto switch for Mythic (raid).</p>
        <p>* Updated zhTW.</p>
        <p>* Fixed some bugs.</p>
        <br/>

        <h1>r92-release (Apr 12, 2022, 14:30 GMT+8)</h1>
        <p>* Fixed health color (gradient).</p>
        <br/>

        <h1>r91-release (Apr 12, 2022, 08:35 GMT+8)</h1>
        <p>* Fixed Targeted Spells indicator.</p>
        <p>* Updated Spell Request.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r90-release (Apr 11, 2022, 01:10 GMT+8)</h1>
        <p>+ Added a Menu Position option.</p>
        <p>* Updated Spell Request, deleted old settings.</p>
        <p>* Fixed unit buttons initialization issue.</p>
        <p>* Updated Layout Preview.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r89-release (Apr 8, 2022, 09:22 GMT+8)</h1>
        <p>* Implemented Spell Request (replace PI Request), it's way better.</p>
        <p>* Fixed bugs.</p>
        <p>* Updated locales.</p>
        <br/>

        <h1>r88-release (Apr 7, 2022, 16:45 GMT+8)</h1>
        <p>* Fixed heal prediction and request glow.</p>
        <br/>

        <h1>r87-release (Apr 7, 2022, 04:40 GMT+8)</h1>
        <h2>Tools</h2>
        <p>+ Implemented Power Infusion Request.</p>
        <p>+ Implemented Dispel Request.</p>
        <h2>Layouts</h2>
        <p>+ Added Show NPC Frame option.</p>
        <p>+ Implemented vertical unit button.</p>
        <h2>Indicators</h2>
        <p>* Added Show Duration option to debuffs, externals and defensives.</p>
        <h2>Misc</h2>
        <p>* Rewrote Options UI.</p>
        <p>* Fixed range check for NPCs.</p>
        <p>* Update zhTW.</p>
        <br/>

        <h1>r86-release (Mar 27, 2022, 15:00 GMT+8)</h1>
        <p>* Added a "Default" anchor option for tooltips.</p>
        <br/>

        <h1>r85-release (Mar 26, 2022, 18:00 GMT+8)</h1>
        <p>* Fixed bugs (occured when scale ~= 1).</p>
        <br/>

        <h1>r84-release (Mar 26, 2022, 15:45 GMT+8)</h1>
        <p>+ Implemented layout sharing.</p>
        <p>+ Added new custom indicator type: Color.</p>
        <p>* Updated SotFO debuffs.</p>
        <br/>

        <h1>r83-release (Mar 18, 2022, 13:50 GMT+8)</h1>
        <p>+ Implemented indicators import/export.</p>
        <p>* Fixed Health Text indicator.</p>
        <br/>

        <h1>r82-release (Mar 16, 2022, 13:20 GMT+8)</h1>
        <p>+ Implemented unitbutton fadeIn &amp; fadeOut.</p>
        <p>* Updated BigDebuffs.</p>
        <p>* Try to fix boss6/7/8 health updating issues with CLEU.</p>
        <br/>

        <h1>r81-release (Mar 12, 2022, 14:00 GMT+8)</h1>
        <p>* Marks Bar: added vertical layout.</p>
        <p>* Updated SotFO debuffs.</p>
        <br/>

        <h1>r80-release (Mar 10, 2022, 17:00 GMT+8)</h1>
        <p>* Fixed NPC frame (horizontal layout).</p>
        <p>+ Implemented separate NPC frame.</p>
        <br/>

        <h1>r79-release (Mar 10, 2022, 10:35 GMT+8)</h1>
        <p>* Updated NPC frame (5 -> 8).</p>
        <p>* Updated name text width options.</p>
        <br/>

        <h1>r78-release (Mar 9, 2022, 00:45 GMT+8)</h1>
        <p>+ Implemented Raid Debuffs import/export/reset, check out the tips in Raid Debuffs.</p>
        <p>* Updated SotFO debuffs.</p>
        <p>* Updated zhCN.</p>
        <br/>

        <h1>r77-release (Mar 3, 2022, 08:21 GMT+8)</h1>
        <p>* Bug fixes: click-castings (priest).</p>
        <p>+ Added "Use Game Font" option in Appearance.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r76-release (Feb 24, 2022, 11:20 GMT+8)</h1>
        <p>+ Updated raid debuffs: Sepulcher of the First Ones.</p>
        <p>* Bug fixes: appearance preview.</p>
        <br/>

        <h1>r75-release (Feb 17, 2022, 00:22 GMT+8)</h1>
        <h2>Appearance</h2>
        <p>* Updated button highlight size option: negative size.</p>
        <p>+ New power color: Power Color (dark).</p>
        <h2>General</h2>
        <p>* Updated pixel perfect: raid tools.</p>
        <p>* Disabled Death Report in battlegrounds and arenas.</p>
        <h2>Layouts</h2>
        <p>* Updated layout creation.</p>
        <h2>Raid Debuffs</h2>
        <p>+ New raid debuffs sharing feature (beta): shift + left click on instance/boss to share debuffs via chat link.</p>
        <br/>

        <h1>r74-release (Jan 12, 2022, 22:20 GMT+8)</h1>
        <p>* Bugs fix: layout auto switch, health text indicator.</p>
        <p>+ New "Condition" option in Raid Debuffs.</p>
        <br/>

        <h1>r73-release (Dec 8, 2021, 22:22 GMT+8)</h1>
        <p>* Defect fixes.</p>
        <br/>

        <h1>r72-release (Dec 7, 2021, 15:20 GMT+8)</h1>
        <p>* Fixed Debuffs indicator delayed refreshing issue.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r71-release (Nov 30, 2021, 04:15 GMT+8)</h1>
        <p>+ Added "Circled Stack Numbers" option to custom text indicator.</p>
        <p>+ Added status color options to Status Text indicator.</p>
        <p>+ Implemented power bar filters (Layouts).</p>
        <p>* Bug fixes (indicator preview).</p>
        <p>* Updated the default spell list of Defensive Cooldowns indicator.</p>
        <p>* Updated zhTW.</p>
        <p>+ Cell can provide a "Healers" indicator on first run.</p>
        <br/>

        <h1>r70-release (Nov 18, 2021, 09:20 GMT+8)</h1>
        <p>+ Added several new options in Appearance.</p>
        <p>+ Added "Show Duration" option to custom TEXT indicator.</p>
        <br/>

        <h1>r69-release (Nov 16, 2021, 09:10 GMT+8)</h1>
        <p>+ Added "Background Alpha" in Appearance.</p>
        <p>* Updated Raid Debuffs indicator, it can show up to 3 debuffs now.</p>
        <br/>

        <h1>r68-release (Nov 5, 2021, 22:40 GMT+8)</h1>
        <p>+ Added an Icon Animation option in Appearance.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r67-release (Oct 8, 2021, 02:55 GMT+8)</h1>
        <p>* Bug fixes.</p>
        <br/>

        <h1>r66-release (Oct 7, 2021, 23:30 GMT+8)</h1>
        <p>+ Added support for Class Colors addon.</p>
        <p>+ Implemented Always Targeting (Click-Castings).</p>
        <br/>

        <h1>r65-release (Sep 23, 2021, 10:00 GMT+8)</h1>
        <p>* Bug fixes.</p>
        <p>* Updated Targeted Spells.</p>
        <p>+ Added spell icons for indicator aura list.</p>
        <br/>

        <h1>r64-release (Sep 1, 2021, 08:18 GMT+8)</h1>
        <p>* Updated Big Debuffs, Targeted Spells and Raid Debuffs.</p>
        <br/>

        <h1>r63-release (Aug 24, 2021, 03:06 GMT+8)</h1>
        <p>* Debuff blacklist will not affect other indicators any more.</p>
        <p>* Updated Big Debuffs and Raid Debuffs.</p>
        <br/>

        <h1>r62-release (Aug 20, 2021, 06:05 GMT+8)</h1>
        <p>+ Added a Rename button for indicators.</p>
        <p>* Fixed Layout Auto Switch (battleground &amp; arena).</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r61-release (Aug 16, 2021, 22:30 GMT+8)</h1>
        <p>+ New Indicator: Aggro (border).</p>
        <p>* Renamed Indicators: Aggro Indicator -> Aggro (blink), Aggro Bar -> Aggro (bar).</p>
        <p>* Updated zhCN, zhTW.</p>
        <br/>

        <h1>r60-release (Aug 16, 2021, 04:08 GMT+8)</h1>
        <p>+ Added spellId 0 for ICONS indicator to match all auras.</p>
        <p>+ Added pet button size options.</p>
        <p>* Updated party frame UnitIds, made them more reliable.</p>
        <p>* Updated anchors of indicators.</p>
        <p>* Updated Death Report, Buff Tracker and Targeted Spells.</p>
        <br/>

        <h1>r59-release (Aug 7, 2021, 18:23 GMT+8)</h1>
        <p>* Implemented Copy Indicators.</p>
        <p>* Updated Layout Auto Switch.</p>
        <p>* Updated Raid Debuffs, Targeted Spells, Death Report.</p>
        <br/>

        <h1>r58-release (Jul 26, 2021, 18:25 GMT+8)</h1>
        <p>* Updated support for OmniCD (raid frame).</p>
        <p>* Updated zhTW, koKR.</p>
        <br/>

        <h1>r57-release (Jul 26, 2021, 00:52 GMT+8)</h1>
        <p>+ New features: Death Report &amp; Buff Tracker.</p>
        <p>* Updated RaidDebuffs.</p>
        <br/>

        <h1>r56-release (Jul 16, 2021, 01:20 GMT+8)</h1>
        <p>* Updated TargetedSpells and BigDebuffs.</p>
        <p>* Fixed unit button border.</p>
        <p>* Fixed status text "DEAD".</p>
        <br/>

        <h1>r55-release (Jul 13, 2021, 17:35 GMT+8)</h1>
        <p>* Updated RaidDebuffs (Tazavesh).</p>
        <p>* Updated BigDebuffs (tormented affix related).</p>
        <p>* Fixed button backdrop in options frame.</p>
        <br/>

        <h1>r54-release (Jul 9, 2021, 01:49 GMT+8)</h1>
        <p>* Fixed BattleRes timer.</p>
        <br/>

        <h1>r53-release (Jul 8, 2021, 16:48 GMT+8)</h1>
        <p>* Updated RaidDebuffs (SoD).</p>
        <br/>

        <h1>r52-release (Jul 8, 2021, 5:50 GMT+8)</h1>
        <p>- Removed an invalid spell from Click-Castings: 204293 "Spirit Link" (restoration shaman pvp talent).</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r51-release (Jul 7, 2021, 13:50 GMT+8)</h1>
        <p>* Updated Cell scaling. Cell main frame is now pixel perfect.</p>
        <p>* Updated RaidDebuffs.</p>
        <br/>

        <h1>r50-release (May 1, 2021, 03:20 GMT+8)</h1>
        <h2>Indicators</h2>
        <P>+ New indicators: Status Icon, Target Counter (BG &amp; Arena only).</P>
        <P>+ New indicator feature: Big Debuffs (Debuffs indicator).</P>
        <p>* Increased indicator max icons: Debuffs, custom indicators.</p>
        <p>* Changed dispel highlight to a smaller size.</p>
        <h2>Misc</h2>
        <p>* Fixed a Cell scaling issue.</p>
        <p>* Fixed the position of BattleRes again.</p>
        <p>+ Added a "None" option for font outline.</p>
        <br/>

        <h1>r49-release (Apr 5, 2021, 16:10 GMT+8)</h1>
        <p>+ Added "Bar Animation" option in Appearance.</p>
        <p>* Updated "Health Text" (zhCN, zhTW and koKR numeral system).</p>
        <br/>

        <h1>r48-release (Apr 1, 2021, 16:03 GMT+8)</h1>
        <p>* Updated "Targeted Spells" and "Battle Res Timer".</p>
        <p>* Fixed some bugs (unit button backdrop and size).</p>
        <br/>

        <h1>r47-release (Mar 24, 2021, 18:30 GMT+8)</h1>
        <p>+ Added "Highlight Size" and "Out of Range Alpha" options.</p>
        <p>- Removed ready check highlight.</p>
        <p>* Cooldown animation will be disabled when "Show duration text" is checked.</p>
        <br/>

        <h1>r46-release (Mar 16, 2021, 9:25 GMT+8)</h1>
        <p>* Fixed Click-Castings (mouse wheel) AGAIN.</p>
        <p>+ Added Orientation options for Defensive/External Cooldowns and Debuffs indicators.</p>
        <p>* Updated Tooltips options.</p>
        <br/>

        <h1>r45-release (Mar 11, 2021, 13:00 GMT+8)</h1>
        <p>* Fixed Click-Castings (mouse wheel).</p>
        <br/>

        <h1>r44-release (Mar 8, 2021, 12:07 GMT+8)</h1>
        <p>* Fixed BattleRes text not showing up.</p>
        <p>* Updated default spell list of Targeted Spells.</p>
        <p>* Updated Import&amp;Export.</p>
        <p>* Updated zhTW.</p>
        <br/>

        <h1>r43-release (Mar 3, 2021, 2:18 GMT+8)</h1>
        <p>+ New feature: Layout Import/Export.</p>
        <br/>

        <h1>r42-release (Feb 22, 2021, 17:43 GMT+8)</h1>
        <p>* Fixed unitbuttons' updating issues.</p>
        <br/>

        <h1>r41-release (Feb 21, 2021, 10:23 GMT+8)</h1>
        <p>* Updated Targeted Spells indicator.</p>
        <br/>

        <h1>r40-release (Feb 21, 2021, 9:22 GMT+8)</h1>
        <h2>Party Frame</h2>
        <p>* Rewrote PartyFrame, now it supports two sorting methods: index and role.</p>
        <h2>Indicators</h2>
        <p>* Debuffs indicator will not show the SAME debuff shown by RaidDebuffs indicator.</p>
        <p>* Fixed indicator preview.</p>
        <p>* Fixed Targeted Spells indicator.</p>
        <p>* Updated External/Defensive Cooldowns.</p>
        <p>+ Added Glow Condition for RaidDebuffs.</p>
        <h2>Misc</h2>
        <p>* Fixed a typo in Click-Castings.</p>
        <p>+ Added koKR.</p>
        <br/>

        <h1>r39-release (Jan 22, 2021, 13:24 GMT+8)</h1>
        <h2>Indicators</h2>
        <p>+ New indicator: Targeted Spells.</p>
        <h2>Layouts</h2>
        <p>+ Added pets for arena layout.</p>
        <h2>Misc</h2>
        <p>* OmniCD should work well, even though the author of OmniCD doesn't add support for Cell.</p>
        <p>! Use /cell to reset Cell. It can be useful when Cell goes wrong.</p>
        <br/>

        <h1>r37-release (Jan 4, 2021, 10:10 GMT+8)</h1>
        <h2>Indicators</h2>
        <p>+ Some built-in indicators are now configurable: Name Text, Status Text.</p>
        <p>+ New indicator: Shield Bar</p>
        <p>+ Added "Only show debuffs dispellable by me" option for Debuffs indicator.</p>
        <p>+ Added "Use Custom Textures" options for Role Icon indicator.</p>
        <h2>Misc</h2>
        <p>- Due to indicator changes, some font related options have been removed.</p>
        <p>* Fixed frame width of BattleResTimer.</p>
        <p>+ Added support for OmniCD (party frame).</p>
        <br/>

        <h1>r35-release (Dec 23, 2020, 0:01 GMT+8)</h1>
        <h2>Indicators</h2>
        <p>+ Some built-in indicators are now configurable: Role Icon, Leader Icon, Ready Check Icon, Aggro Indicator.</p>
        <p>+ Added "Border" and "Only show glow for top debuffs" options for Central Debuff indicator.</p>
        <h2>Raid Debuffs (Beta)</h2>
        <p>! All debuffs are enabled by default, you might want to disable some less important debuffs.</p>
        <p>+ Added "Track by ID" option.</p>
        <p>+ Updated glow options for Raid Debuffs.</p>
        <h2>General</h2>
        <p>+ Updated tooltips options.</p>
        <h2>Layouts</h2>
        <p>+ Added "Hide" option for "Text Width".</p>
        <br/>

        <h1>r32-release (Dec 10, 2020, 7:29 GMT+8)</h1>
        <h2>Indicators</h2>
        <p>+ New indicator: Health Text.</p>
        <p>+ New option: Frame Level.</p>
        <h2>Raid Debuffs (Beta)</h2>
        <p>+ Added instance debuffs for Shadowlands. For now, these debuffs are tracked by NAME. "Track By ID" option will be added later.</p>
        <p>! All debuffs are enabled by default, you might want to disable some less important debuffs.</p>
        <h2>Misc</h2>
        <p>* Fixed: Marks Bar, Click-Castings.</p>
        <p>* Moved "Raid Setup" text to the tooltips of "Raid" button.</p>
        <p>+ Added Fade Out Menu option.</p>
        <br/>

        <h1>r26-release (Nov 23, 2020, 21:25 GMT+8)</h1>
        <h2>Click-Castings</h2>
        <p>+ Keyboard/multi-button mouse support for Click-Castings comes.</p>
        <p>! Due to code changes, you might have to reconfigure Key Bindings.</p>
        <h2>Indicators</h2>
        <p>* Aura List has been updated. Now all custom indicators will check spell IDs instead of NAMEs.</p>
        <p>! Custom Indicators won't work until the Buff/Debuff List has been reconfigured.</p>
        <h2>Indicator Preview Alpha</h2>
        <p>+ Now you can set alpha of non-selected indicators. This might make it easier to arrange your indicators.</p>
        <p>! To adjust alpha, use the alpha slider in "Indicators", it can be found at the top right corner.</p>
        <h2>Frame Position</h2>
        <p>+ Every layout has its own position setting now.</p>
        <p>! The positions of Cell Main Frame, Marks, Ready &amp; Pull have been reset.</p>
        <h2>Misc</h2>
        <p>+ Party/Raid Preview Mode will help you adjust layouts.</p>
        <p>+ Group Anchor Point comes, go check it out in Layouts -&gt; Group Arrangement.</p>
        <br/>

        <p><a href="recent">Click to view recent changelogs</a></p>
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