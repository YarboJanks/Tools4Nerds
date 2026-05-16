# Changelog

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
