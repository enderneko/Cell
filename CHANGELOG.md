# r276-beta: WoW 12.0.5 Compatibility

Interface bumped to 120005. Without these fixes Cell showed static white health bars, missing health/power text, and taint errors in PvP/M+.

## API Updates

- Added required `isContainer = false` to `C_UnitAuras.AddPrivateAuraAnchor` args (new in 12.0.5).

## Secret-Value Guards

12.0.5 decoupled Secret Value restrictions from the aura-restriction context flag, so `F.IsAuraRestricted()` context-guards miss real secrets. Replaced with per-value `F.IsSecretValue` / `issecretvalue` checks at the use site:

- `Indicators/Custom.lua`: `auraInfo.sourceUnit` comparison for the cast-by-me filter.
- `Indicators/TargetedSpells.lua`: `UnitCastingInfo` / `UnitChannelInfo` returns (`spellId`, timestamps, `texture`).
- `RaidFrames/UnitButton.lua`: `UnitGUID` comparisons in `UnitButton_OnTick`; `powerMax` in `UnitButton_UpdatePowerStates`.
- `Utilities/BuffTracker.lua`: LGI cache lookup by GUID.
- `Utilities/DeathReport.lua`: `reportedDead[guid]` table key.

## Text Indicators on Secret Values

`UnitHealPredictionCalculator` returns secret-flagged numbers even in normal gameplay. Lua arithmetic and comparisons throw, but C-implemented formatters (`string.format`, `AbbreviateNumbers`, `BreakUpLargeNumbers`) pass secrets through to non-secret strings. Percentages come from calculator curve methods.

- **Health Text**: new `midnightFormatter` table backed by calculator methods, plus `GetMidnightCurves` factory (two reusable `C_CurveUtil` curves for positive and negative percentage scales). `HealthText_SetFormat` stashes format names for lookup; `HealthText_SetValue` takes a new `calc` arg and routes each slot when values are secret. Caller in `RaidFrames/UnitButton.lua` passes the unit's `healthCalculator`.
- **Power Text**: `SetPower_Percentage` calls `UnitPowerPercent(unit, nil, true, CurveConstants.ScaleTo100)` (wrapped in `pcall`) to get a plain 0-100 value when Cell's context would otherwise return a secret `UnitPower`. Caller at `UnitButton_UpdatePowerText` passes `self.states.displayedUnit` so the formatter has a unit to query. `SetPower_Number` uses `string.format("%d", current)`, `SetPower_Number_Short` uses `AbbreviateNumbers`. Non-secret paths moved to `SafeTextWidth` because `GetStringWidth` stays tainted after the FontString held secret text.
- **Power bar**: `UnitButton_UpdatePowerMax` and `UnitButton_UpdatePower` now use native `SetMinMaxValues` and `SetValue` on Midnight unconditionally, bypassing `SmoothStatusBarMixin`. The mixin caches min/max and its per-frame `Clamp()` throws every tick if either value was ever secret, even after the current value is plain. Matches what the health bar already does on Midnight.
- **`SafeTextWidth` helper**: font-proportional fallback when `GetStringWidth` returns a secret-flagged width. Used by both text indicators' secret paths and their `SetFont` paths.
- **QuickAssist**: no change; `StatusBar:SetValue` / `:SetMinMaxValues` accept secrets natively.

### Supported formats on secret values

Health Text: `health`, `health_short`, `health_percent`, `deficit`, `deficit_short`, `deficit_percent`, `shields`, `shields_short`, `healabsorbs`, `healabsorbs_short`. `effective_*` degrades to matching `health_*` (no `GetEffectiveHealth` method). `*_percent` on shields/healabsorbs degrades to short absolute (no matching curve method).

Power Text: `number`, `number-short`, `percentage`. Percent uses `UnitPowerPercent` with `CurveConstants.ScaleTo100` and renders correctly even when raw `UnitPower` is secret. Falls back to `AbbreviateNumbers` only if `UnitPowerPercent` is unavailable or the pcall fails.

### Limitations

- `hideIfEmptyOrFull` is a no-op on secret values (needs comparisons).
- `effective`-format on health diverges from true effective only when shields or heal absorbs are active.

## Aura Classification

12.0.5 un-secreted `isHelpful`, `isHarmful`, `isRaid`, `isNameplateOnly`, `isFromPlayerOrPlayerPet`. Removed the `issecretvalue(auraInfo.isHelpful)` early-return in `Indicators/Custom.lua` and the classification-secret fallback in `RaidFrames/UnitButton.lua`'s incremental aura fast path.

# r275.5 Added Midnight Raid Debuffs

## Raid Debuffs

- Added initial Midnight expansion raid debuffs for all 12 instances (6 raids, 6 dungeons) and 41 bosses.
- Boss ability spell IDs sourced from the Encounter Journal via wago.tools DB2 tables.
- General (trash mob) debuffs still need to be collected in-game and added in a future update.
- Spells may need further in-game curation to filter out non-debuff abilities.

# r275-release — WoW 12.0.0 (Midnight) Compatibility

Comprehensive compatibility update for WoW Patch 12.0.0 (Midnight), addressing the removal of `COMBAT_LOG_EVENT_UNFILTERED`, the introduction of Secret Values, blocked addon communications during restricted contexts, and spell/API removals. Interface bumped to 120001.

## Secret Values (12.0.0+)

- Add `Cell.isMidnight` detection flag and `F.IsSecretValue()`, `F.IsAuraRestricted()`, `F.IsCooldownRestricted()` utility functions
- Add per-aura `F.IsAuraNonSecret()`, `F.IsSpellAuraNonSecret()`, `F.IsValueNonSecret()` helpers — non-secret (whitelisted) auras now get real countdown timers, source detection, and duration display; secret auras gracefully degrade
- UnitButton: major dual-path refactor — Midnight uses `UnitHealPredictionCalculator`, `C_CurveUtil.CreateCurve()`, and StatusBar overlays for health/prediction/shields; pre-Midnight retains arithmetic-based paths
- Appearance: IncomingHeal widget uses `SetStatusBarTexture` on Midnight (StatusBar) vs `SetTexture` pre-Midnight (Texture)
- Indicator_Defaults: local `DebuffTypeColor` fallback for when the WoW global is removed
- Per-field `F.IsValueNonSecret()` guards before every arithmetic operation on temporal aura fields (`expirationTime`, `duration`, `applications`, and cached `old*` variants)

## CLEU Removal

- AoEHealing: disabled on Midnight (CLEU unavailable); frame still exists for potential future non-CLEU API
- StatusIcon: soulstone/resurrection tracking switches to `UNIT_AURA` + `UNIT_HEALTH` on Midnight
- NPCFrame: boss6-8 health/aura tracking switches to unit events on Midnight
- DeathReport: full refactor — Midnight uses `UNIT_HEALTH` + `UnitIsDeadOrGhost()` for death detection
- UnitButton: removed `CombatLogGetCurrentEventInfo` dependency and `CheckCLEURequired`
- General: removed `useCleuHealthUpdater` checkbox (CLEU health updater obsolete)
- Revise: r275 migration removes `useCleuHealthUpdater` from saved variables

## Comm Restrictions

- Comm: `IsCommRestricted()` detects encounters/M+/PvP; all `SendCommMessage` calls guarded; pending queue with flush on `ENCOUNTER_END`
- Nicknames: all nickname sync sends guarded with `F.IsCommRestricted()`

## Heal Prediction & Health Bar Fixes

- Created a dedicated `healPredictionCalculator` separate from the shared `healthCalculator` — the heal prediction function's `SetIncomingHealClampMode(0)` and `SetIncomingHealOverflowPercent(1.0)` were persisting on the shared calculator and corrupting health/absorb reads
- Incoming heal bar is now a StatusBar (instead of Texture) anchored to the health fill texture edge
- Fixed health bar loss color stuck on white/full-health — `self.states.healthPercent` was never set on the Midnight path; now populated from `calculator:GetCurrentHealthPercent()` with a secret-safe fallback
- Dispels now show correctly because `HandleDebuff` completes to the dispel detection code (string/boolean fields, not temporal arithmetic)

## Spell & Default Updates

- Removed: Engulf, Renew, Power Word: Life, Void Shift, Shadow Covenant, Divine Star, Cloudburst Totem, Minor Cenarion Ward, Premonition of Solace
- Added: Plea (200829, Disc Priest)
- Added missing healing spells to default indicator list (Evoker, Monk, Paladin, Priest)
- Moved: Prayer of Mending from class-wide to Holy spec only
- Fixed: Shaman Poison dispel node IDs (103609 -> 103599)

## Defensive Nil Guards & Fixes

- MainFrame: nil guards for `currentLayoutTable` and `tooltipPoint`
- HideBlizzard: guards for `PartyMemberFramePool`, `CompactPartyFrame`, `PartyMemberBackground`
- RaidDebuffs: nil guard for encounter journal expansion data
- TargetedSpells: skip enemy spell tracking during restricted periods
- BuffTracker: guard `GetAuraDataBySpellName` when auras are restricted; per-aura `sourceUnit` check
- QuickCast: skip only secret auras in `ForEachAura`
- Custom indicators: per-aura secret check for duration/start
- Appearance: ticker nil guard in preview `OnHide`

## Infrastructure

- All 22 XML files updated from `FrameXML/UI_shared.xsd` -> `Blizzard_SharedXML/UI.xsd`
- Core: version constants bumped to 275, `GetBattlegroundInfo` guard added

---

# r274-release

[View Full Changelog](https://github.com/enderneko/Cell/compare/r273-release...c376c32494926a90b93cc63bfc564234fb6e5cd6)

- Update Molten Core debuffs
- Fix boss unit button mapping
