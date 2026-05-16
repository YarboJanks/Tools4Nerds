<div align="center">
  <img src="header.svg" alt="Tools 4 Nerds" width="860"/>
</div>

A PvP-focused Elder Scrolls Online addon that surfaces combat information you'd otherwise have to guess at — CC immunity windows, blocked attacks, critical hits, and queue pop-ups.

## Features

### CC Immunity Tracker
Displays a countdown when your target is immune to crowd control, so you know exactly when it's safe to land your next CC. Works via buff detection in duels and open world, and via combat event inference in Battlegrounds and Cyrodiil.

### Block Indicator
Briefly shows a "Blocking" label when your attack is blocked, giving you immediate feedback to adjust your rotation.

### Crit Hit Marker
Plays an animated overlay on your screen when you land a critical hit. Size and color are configurable.

### Auto Queue Accept
Automatically accepts dungeon and PvP queue pop-ups so you never miss a ready check.

## Installation

1. Download and extract the `Tools4Nerds` folder into:
   ```
   Documents/Elder Scrolls Online/live/AddOns/
   ```
2. Ensure [LibAddonMenu-2.0](https://www.esoui.com/downloads/info7-LibAddonMenu.html) is also installed — it is required.
3. Launch ESO and enable **Tools 4 Nerds** in the AddOns menu.

## Usage

### Settings Panel
Open **Settings → AddOns → Tools 4 Nerds** to configure each feature:

| Setting | Description |
|---------|-------------|
| Account-Wide Sync | Share one settings profile across all characters |
| Text Size | Font size for CC and block indicator text |
| Enable CC Immunity Tracking | Toggle the CC countdown |
| CC Immunity Color | Color of the CC countdown text |
| Enable Block Tracking | Toggle the block indicator |
| Block Color | Color of the block indicator text |
| Enable Crit Hit Marker | Toggle the crit overlay |
| Marker Size | Size of the crit marker in pixels |
| Marker Color | Color tint of the crit marker (white = no tint) |
| Auto Accept Queue | Toggle automatic queue acceptance |

Each section also has a **Test** button to preview how that indicator looks without needing to be in combat.

### Keybinding
Assign a key to **Toggle Tools 4 Nerds** under **Settings → Controls → AddOns** to enable/disable the addon on the fly.

### Slash Commands
| Command | Description |
|---------|-------------|
| `/t4n debug` | Prints current state to chat — combat flag, target type, buff count, CC tracking status, and tick state. Useful for diagnosing why an indicator isn't showing. |

## Notes

- The CC immunity tracker only activates when you are in combat and have a player targeted.
- In Battlegrounds and Cyrodiil, CC immunity is tracked via combat events (when you land a CC on your target) rather than buff reading, which may not be available in all PvP contexts.
- The nameplate immunity dot uses the same combat-event inference and will appear on enemy nameplates during their CC immunity window.
