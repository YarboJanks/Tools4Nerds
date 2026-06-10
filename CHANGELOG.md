# Changelog

## [3.5.0] - 2026-06-11
### Added
- Debuff Counter — live count of negative effects on the player; flashes when 6 or more are active; draggable widget with saved position, color picker, and font size setting
- Mara's Balm Tracker — shows MARAS in green when ready, red with countdown while on cooldown; auto-shows when 5+ Mara's Balm pieces are equipped and hides when the set is removed; draggable widget with saved position
- Gorethief Stack Tracker — tracks Gorethief stacks (buff 260047); shows yellow while building (THIEF x7) and red at max (THIEF x10); auto-shows on first stack, hides at zero; draggable widget with saved position
- `/t4n debug` — print live combat state, CC tracking, debuff count, Mara's equip status, and Gorethief stacks
- `/t4n debugplayer` — log all effect changes on the player for 60 seconds (includes ability ID and stack count)
- `/t4n debugsets` — print every equipped item set with name, set ID, and piece count
- `/t4n debugcombat` — log all combat events involving the player for 60 seconds
- `/t4n debugfx` — capture the next 15 `EVENT_EFFECT_CHANGED` events on any unit
### Fixed
- Guard Protection now uses an explicit exclusion list of all 16 trials and arenas (GROUP_INSTANCE_ZONES) so it never misfires inside group content where sub-location names differ from zone names
### Improved
- Protector Hunter detects Ordinated Protectors the instant they spawn via the "Find Turret" ability (EVENT_EFFECT_CHANGED, ability 64508) rather than waiting for Static Shield to appear on Saint Olms — alert fires significantly earlier
- Protector Hunter adds a secondary nameplate hook as a fallback spawn signal
- Both co-authors restored in addon manifest and settings panel

## [3.4.0] - 2026-06-04
### Added
- Protector Hunter — displays a persistent on-screen alert when an Ordinated Protector is active in Veteran Asylum Sanctorium; clears automatically when the protector is killed

## [3.3.0] - 2026-06-04
### Changed
- Guard Protection simplified to a single universal toggle covering all criminal ability types (Necromancer, Werewolf, Vampire); per-ability checkboxes removed

## [3.2.0] - 2026-06-04
### Added
- Guard Protection extended to cover Werewolf (Werewolf Transformation, Werewolf Berserker, Pack Leader) and Vampire (Blood Scion, Perfect Blood Scion) abilities

## [3.1.1] - 2026-06-04
### Fixed
- Guard Protection hard-block implemented via ZO_PreHook on ZO_ActionBar_CanUseActionSlots — prevents the ability from firing rather than just playing the fail sound
- Justice zone detection uses GetPlayerLocationName instead of GetMapName to correctly identify towns and cities

## [3.1.0] - 2026-06-01
### Added
- Guard Protection — hard-blocks Necromancer raise-undead abilities (Skeletal Mage, Blastbones, Grave Grasp, Bone Golem, Frozen Colossus and morphs) in towns and cities, preventing accidental guard aggro

## [3.0.0] - 2026-05-25
### Added
- Global Cooldown (GCD) Overlay — hooks ESO's native cooldown animation onto each action bar slot during the global cooldown; configurable animation style (ascending, descending, radial), icon desaturation, ready flash, and optional potion slot coverage

## [2.7.0] - 2026-05-27
### Added
- GCD overlay — hooks ESO's native cooldown animation onto each action bar slot during the global cooldown
- GCD animation style setting — Ascending (bottom to top), Descending (top to bottom), or Radial
- Icon desaturation during GCD (configurable)
- Ready animation on GCD expiry (configurable, off by default)
- Option to extend the GCD overlay to consumable/potion slots (off by default)
- GCD settings are included in account-wide sync

## [2.6.0] - 2026-05-17
### Added
- Mara's Balm tracker auto-shows when 5 or more pieces of the set are equipped (including backbar weapons) and hides when the set is removed
- `/t4n debugsets` slash command — prints all equipped set IDs, names, and piece counts
### Fixed
- Mara's Balm set detection now correctly counts pieces across all equipment slots including backbar (slots 0–25)

## [2.5.0] - 2026-05-17
### Added
- Mara's Balm tracker now shows a live countdown (e.g. "MARAS 24s") while on cooldown, returning to "MARAS" in green when ready
- Mara's Balm test button counts down visibly and remains visible while the settings panel is open

## [2.4.0] - 2026-05-17
### Added
- Mara's Balm tracker — displays MARAS in green when ready, red when on cooldown (28s); draggable and resizable with its own settings section
- `/t4n debugplayer` slash command — logs all effect changes on the player
- `/t4n debugcombat` slash command — logs all combat events involving the player
### Fixed
- Debuff counter could drift out of sync when effects expired without firing a fade event; now uses per-slot tracking and resets cleanly on zone load

## [2.3.0] - 2026-05-17
### Added
- Debuff counter — live count of negative effects currently on the player; draggable, resizable, and color-configurable with a settings section and test button
- Debuff counter flashes rapidly when 6 or more debuffs are active as a visual warning

## [2.2.0] - 2026-05-16
### Added
- Test buttons for CC immunity and block indicators in the settings panel
- `/t4n debug` slash command to print live diagnostic info (combat state, unit type, buff count, CC tracking state)

## [2.1.0] - 2026-05-15
### Added
- Account-wide settings sync — optionally share one settings profile across all characters
### Fixed
- LAM compatibility issue causing errors on panel refresh

## [2.0.0] - 2026-05-15
### Changed
- Rebranded from CCTracker to Tools4Nerds
### Added
- Block indicator — briefly displays when your attack is blocked
- Crit hit marker — animated overlay when you land a critical hit
- Auto queue accept — automatically accepts dungeon and PvP queue pop-ups
- LibAddonMenu settings panel with color pickers, sliders, and per-feature toggles
- Keybinding to toggle the addon on/off
- Nameplate immunity dot — shows a marker on enemy nameplates during CC immunity
- CC immunity inference from combat events as fallback when buff reading is unavailable

## [1.0.0] - 2026-05-14
### Added
- Initial release as CCTracker
- CC immunity countdown when targeting a player with CC immunity buff
