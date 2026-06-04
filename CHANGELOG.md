# Changelog

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
