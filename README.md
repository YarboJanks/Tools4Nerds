<div align="center">
  <img src="header.svg" alt="Tools 4 Nerds" width="860"/>
</div>

A PvP-focused Elder Scrolls Online addon that surfaces combat information you'd otherwise have to guess at — CC immunity windows, blocked attacks, critical hits, queue pop-ups, global cooldown tracking, and criminal ability blocking for Necromancer, Werewolf, and Vampire.

## Features

### CC Immunity Tracker
Displays a countdown when your target is immune to crowd control, so you know exactly when it's safe to land your next CC. Works via buff detection in duels and open world, and via combat event inference in Battlegrounds and Cyrodiil.

### Block Indicator
Briefly shows a "Blocking" label when your attack is blocked, giving you immediate feedback to adjust your rotation.

### Crit Hit Marker
Plays an animated overlay on your screen when you land a critical hit. Size and color are configurable.

### Auto Queue Accept
Automatically accepts dungeon and PvP queue pop-ups so you never miss a ready check.

### Global Cooldown (GCD) Overlay
Adds a cooldown animation directly over each action bar slot during the global cooldown, giving you a clear visual indicator of when your next ability is available.

- **Animation style** — Ascending (bottom to top), Descending (top to bottom), or Radial
- **Icon desaturation** — greys out ability icons during the GCD
- **Ready animation** — flashes the slot when the GCD expires
- **Potion cooldown** — optionally extends the overlay to consumable slots (off by default)

### Guard Protection
Hard-blocks criminal abilities from firing while you are in a town or city, preventing accidental bounties and guard aggro. When you press a blocked ability's keybind, it plays the ability-failed sound and does nothing. Each creature type has its own master toggle and per-ability-group sub-toggles.

**Necromancer** (raise undead abilities — Necromancer class only):
- **Skeletal Mage** — Skeletal Mage, Skeletal Archer, Skeletal Arcanist
- **Blastbones** — Blastbones, Stalking Blastbones, Viscous Blastbones
- **Grave Grasp** — Grave Grasp, Ghostly Embrace, Empowering Grasp
- **Bone Golem** — Bone Golem, Pummeling Golem, Ravenous Golem
- **Frozen Colossus** — Frozen Colossus, Glacial Colossus, Pestilent Colossus

**Werewolf** (any class with lycanthropy):
- **Transformation** — Werewolf Transformation, Werewolf Berserker, Pack Leader

**Vampire** (any class with vampirism):
- **Blood Scion** — Blood Scion, Perfect Blood Scion

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
| Enable GCD Overlay | Toggle the global cooldown animation on action bar slots |
| GCD Animation Style | Ascending, Descending, or Radial cooldown animation |
| Desaturate Icons | Grey out ability icons during the GCD |
| Ready Animation | Flash the slot when the GCD expires |
| Show Potion Cooldown | Extend the GCD overlay to consumable slots |
| Enable Guard Protection (Necro) | Block criminal Necromancer abilities in towns |
| Block Skeletal Mage | Block Skeletal Mage and morphs near witnesses |
| Block Blastbones | Block Blastbones and morphs near witnesses |
| Block Grave Grasp | Block Grave Grasp and morphs near witnesses |
| Block Bone Golem | Block Bone Golem and morphs near witnesses |
| Block Frozen Colossus | Block Frozen Colossus and morphs near witnesses |
| Enable Werewolf Protection | Block Werewolf Transformation in towns (any class) |
| Block Transformation | Block Werewolf Transformation and morphs |
| Enable Vampire Protection | Block Vampire transformation in towns (any class) |
| Block Blood Scion | Block Blood Scion and Perfect Blood Scion |

### Keybinding
Assign a key to **Toggle Tools 4 Nerds** under **Settings → Controls → AddOns** to enable/disable the addon on the fly.

## Notes

- The CC immunity tracker only activates when you are in combat and have a player targeted.
- In Battlegrounds and Cyrodiil, CC immunity is tracked via combat events (when you land a CC on your target) rather than buff reading, which may not be available in all PvP contexts.
- The nameplate immunity dot uses the same combat-event inference and will appear on enemy nameplates during their CC immunity window.
- Guard protection detects towns and cities by checking whether your current sub-location name differs from the zone map name. It does not block in dungeons, trials, or arenas. If you are at a named keep or outpost in Cyrodiil, the block may fire there too — disable the relevant toggle before PvP if needed.
