[Full Changelog](https://github.com/enderneko/Cell/compare/r189-release...aad8a8f2288968b4bde2af868948d2eb9ae22383)

- Implement Crowd Controls
- Implement layout auto switch for spec
- Optimize layout switch
- Improve indicator compatibility with spotlight frames
- Update Quick Cast
- Update UNIT_AURA related functions
- Update raid setup tooltip
- Fix Spell Request
- Update role icons
- Update indicator shared functions
- Update zhTW
- [snippet] CustomIndicator_AuraFilters

If you want to revert to previous version, use the macro below.
```lua
/run for _, layout in pairs(CellDB.layouts) do if layout.indicators[26].indicatorName=="crowdControls" then tremove(layout.indicators,26) end end ReloadUI()
```