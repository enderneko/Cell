# WoW 12.0.5 Compatibility

Interface bumped to 120005. Without these fixes Cell showed static white health bars, missing health/power text, and taint errors in PvP/M+. (thanks @matthewjenner)

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

## Add the Raiddebuffs for Lei Shen

Thanks @EkklesN for the contribution!
